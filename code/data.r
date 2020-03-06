# ==========================================================================
# SPARCC data setup
# ==========================================================================

if(!require(pacman)) install.packages("pacman")
pacman::p_load(colorout, data.table, tigris, tidycensus, tidyverse, spdep)
options(width = Sys.getenv('COLUMNS'))

# ==========================================================================
# Pull in data
# ==========================================================================

df <- 
    bind_rows(
            read_csv("~/git/sparcc/data/Atlanta_typology_output.csv") %>% 
            select(!X1) %>% 
            mutate(city = "Atlanta"),
            read_csv("~/git/sparcc/data/Denver_typology_output.csv") %>% 
            select(!X1) %>% 
            mutate(city = "Denver"),
            read_csv("~/git/sparcc/data/Chicago_typology_output.csv") %>% 
            select(!X1) %>% 
            mutate(city = "Chicago"),
            read_csv("~/git/sparcc/data/Memphis_typology_output.csv") %>% 
            select(!X1) %>% 
            mutate(city = "Memphis")
    )

# ==========================================================================
# Create rent gap and extra local change in rent
# ==========================================================================

#
# Tract data
# --------------------------------------------------------------------------

### Tract data extraction function
st <- c("IL","GA","AR","TN","CO","MS","AL","KY","MO","IN")

tr_rent <- function(year, state){
    get_acs(
        geography = "tract",
        variables = c('medrent' = 'B25064_001'),
        state = state,
        county = NULL,
        geometry = FALSE,
        cache_table = TRUE,
        output = "tidy",
        year = year,
        keep_geo_vars = TRUE
        ) %>%
    select(-moe) %>% 
    rename(medrent = estimate) %>% 
    mutate(
        county = str_sub(GEOID, 3,5), 
        state = str_sub(GEOID, 1,2),
        year = str_sub(year, 3,4) 
    )
}

tr_rents17 <- 
    map_dfr(st, function(state){
        tr_rent(year = 2017, state) %>% 
        mutate(COUNTY = substr(GEOID, 1, 5))
    })

tr_rents12 <- 
    map_dfr(st, function(state){
        tr_rent(year = 2012, state) %>% 
        mutate(
            COUNTY = substr(GEOID, 1, 5),
            medrent = medrent*1.07)
    })


tr_rents <- 
    bind_rows(tr_rents17, tr_rents12) %>% 
    unite("variable", c(variable,year), sep = "") %>% 
    group_by(variable) %>% 
    spread(variable, medrent) %>% 
    group_by(COUNTY) %>%
    mutate(
        tr_medrent17 = 
            case_when(
                is.na(medrent17) ~ median(medrent17, na.rm = TRUE),
                TRUE ~ medrent17
            ),
        tr_medrent12 = 
            case_when(
                is.na(medrent12) ~ median(medrent12, na.rm = TRUE),
                TRUE ~ medrent12),
        tr_chrent = tr_medrent17 - tr_medrent12,
        tr_pchrent = (tr_medrent17 - tr_medrent12)/tr_medrent12, 
### CHANGE THIS TO INCLUDE RM of region rather than county
        rm_medrent17 = median(tr_medrent17, na.rm = TRUE), 
        rm_medrent12 = median(tr_medrent12, na.rm = TRUE)) %>% 
    select(-medrent12, -medrent17) %>% 
    distinct() %>% 
    group_by(GEOID) %>% 
    filter(row_number()==1) %>% 
    ungroup()

# Pull in state tracts shapefile and merge them - this is a rough way to do it. 
states <- 
    raster::union(
    raster::union(
    raster::union(
    raster::union(
    raster::union(
    raster::union(
    raster::union(
    raster::union(
    raster::union(tracts("IL", cb = TRUE), tracts("GA", cb = TRUE)), 
        tracts("AR", cb = TRUE)), 
        tracts("TN", cb = TRUE)), 
        tracts("CO", cb = TRUE)), 
        tracts("MS", cb = TRUE)), 
        tracts("AL", cb = TRUE)), 
        tracts("KY", cb = TRUE)), 
        tracts("MO", cb = TRUE)), 
        tracts("IN", cb = TRUE))
    
stsp <- states

# join data to these tracts
stsp@data <-
    left_join(
        stsp@data %>% 
        mutate(GEOID = case_when(
            !is.na(GEOID.1) ~ GEOID.1, 
            !is.na(GEOID.2) ~ GEOID.2, 
            !is.na(GEOID.1.1) ~ GEOID.1.1, 
            !is.na(GEOID.1.2) ~ GEOID.1.2, 
            !is.na(GEOID.1.3) ~ GEOID.1.3)), 
        tr_rents, 
        by = "GEOID") %>% 
    select(GEOID:rm_medrent12)


#
# Create neighbor matrix
# --------------------------------------------------------------------------
    coords <- coordinates(stsp)
    IDs <- row.names(as(stsp, "data.frame"))
    stsp_nb <- poly2nb(stsp) # nb
    lw_bin <- nb2listw(stsp_nb, style = "W", zero.policy = TRUE)

    kern1 <- knn2nb(knearneigh(coords, k = 1), row.names=IDs)
    dist <- unlist(nbdists(kern1, coords)); summary(dist)
    max_1nn <- max(dist)
    dist_nb <- dnearneigh(coords, d1=0, d2 = .1*max_1nn, row.names = IDs)
    spdep::set.ZeroPolicyOption(TRUE)
    spdep::set.ZeroPolicyOption(TRUE)
    dists <- nbdists(dist_nb, coordinates(stsp))
    idw <- lapply(dists, function(x) 1/(x^2))
    lw_dist_idwW <- nb2listw(dist_nb, glist = idw, style = "W")
    

#
# Create select lag variables
# --------------------------------------------------------------------------

    stsp$tr_pchrent.lag <- lag.listw(lw_dist_idwW,stsp$tr_pchrent)
    stsp$tr_chrent.lag <- lag.listw(lw_dist_idwW,stsp$tr_chrent)
    stsp$tr_medrent17.lag <- lag.listw(lw_dist_idwW,stsp$tr_medrent17)

# ==========================================================================
# Join lag vars with df
# ==========================================================================

lag <-  
    left_join(
        df, 
        stsp@data %>% 
            mutate(GEOID = as.numeric(GEOID)) %>%
            select(GEOID, tr_medrent17:tr_medrent17.lag)) %>%
    mutate(
        tr_rent_gap = tr_medrent17.lag - tr_medrent17, 
        tr_rent_gapprop = tr_rent_gap/((tr_medrent17 + tr_medrent17.lag)/2),
        rm_rent_gap = median(tr_rent_gap, na.rm = TRUE), 
        rm_rent_gapprop = median(tr_rent_gapprop, na.rm = TRUE), 
        rm_pchrent = median(tr_pchrent, na.rm = TRUE),
        rm_pchrent.lag = median(tr_pchrent.lag, na.rm = TRUE),
        rm_chrent.lag = median(tr_chrent.lag, na.rm = TRUE),
        rm_medrent17.lag = median(tr_medrent17.lag, na.rm = TRUE), 
        dp_PChRent = case_when(tr_pchrent > 0 & 
                               tr_pchrent > rm_pchrent ~ 1, # ∆ within tract
                               tr_pchrent.lag > rm_pchrent ~ 1, # ∆ nearby tracts
                               TRUE ~ 0),
        dp_RentGap = case_when(tr_rent_gapprop > 0 & tr_rent_gapprop > rm_rent_gapprop ~ 1,
                               TRUE ~ 0),
    ) # %>% 

# ==========================================================================
# At risk of gentrification (ARG)
# Risk = Vulnerability, cheap housing, hot market (rent-gap & extra local change)
# ==========================================================================

    # group_by(GEOID) %>% 
    # mutate(
    #     ARG2 = 
    #         case_when(
    #             pop00flag == 1 & 
    #             (low_pdmt_medhhinc_17 == 1 | mix_low_medhhinc_17 == 1) & 
    #             (lmh_flag_encoded == 1 | lmh_flag_encoded == 4) & 
    #             (change_flag_encoded == 1 | change_flag_encoded == 2) &
    #             gent_90_00 == 0 &
    #             (dp_PChRent == 1 | dp_RentGap == 1) & # new
    #             vul_gent_00 == 1 & # new
    #             gent_00_17 == 0 ~ 1, 
    #             TRUE ~ 0), 
    #     # trueARG = case_when(ARG == ARG2 ~ TRUE, TRUE ~ FALSE)
    #     typ_cat2 = 
    #         case_when(
    #             SLI == 1 ~ "SLI",
    #             OD == 1 ~ "OD",
    #             ARG2 == 1 ~ "ARG", # ARG2!!
    #             EOG == 1 ~ "EOG",
    #             AdvG == 1 ~ "AdvG",
    #             SMMI == 1 ~ "SMMI",
    #             ARE == 1 ~ "ARE",
    #             BE == 1 ~ "BE",
    #             SAE == 1 ~ "SAE",
    #             double_counted > 1 ~ "double_counted"
    #         )
    # )

# saveRDS(df2, "~/git/sparcc/data/rentgap.rds")
fwrite(lag, "~/git/sparcc/data/lag.csv")

# df2 %>% filter(GEOID == 13121006000) %>% glimpse()


# ==========================================================================
# ==========================================================================
# ==========================================================================
# ==========================================================================
# EXCESS CODE
# ==========================================================================
# ==========================================================================
# ==========================================================================
# ==========================================================================

    #  %>% 
    # select(GEOID, ARG, ARG2, trueARG) %>% 
    # filter(trueARG == FALSE) %>% glimpse()

# ==========================================================================
# Data creation
# ==========================================================================

#
# Mixed income
# Modified version of The Proportions of Families in Poor and affluent Neighborhoods from 
# Bischoff, Kendra, and Sean F Reardon. “Residential Segregation by Income, 1970–2009,” 28, n.d.
# --------------------------------------------------------------------------

# inc_vars <- 
#     c(
#         'HHInc_Total' = 'B19001_001', # Total HOUSEHOLD INCOME
#         'HHInc_10000' = 'B19001_002', # Less than $10,000 HOUSEHOLD INCOME
#         'HHInc_14999' = 'B19001_003', # $10,000 to $14,999 HOUSEHOLD INCOME
#         'HHInc_19999' = 'B19001_004', # $15,000 to $19,999 HOUSEHOLD INCOME
#         'HHInc_24999' = 'B19001_005', # $20,000 to $24,999 HOUSEHOLD INCOME
#         'HHInc_29999' = 'B19001_006', # $25,000 to $29,999 HOUSEHOLD INCOME
#         'HHInc_34999' = 'B19001_007', # $30,000 to $34,999 HOUSEHOLD INCOME
#         'HHInc_39999' = 'B19001_008', # $35,000 to $39,999 HOUSEHOLD INCOME
#         'HHInc_44999' = 'B19001_009', # $40,000 to $44,999 HOUSEHOLD INCOME
#         'HHInc_49999' = 'B19001_010', # $45,000 to $49,999 HOUSEHOLD INCOME
#         'HHInc_59999' = 'B19001_011', # $50,000 to $59,999 HOUSEHOLD INCOME
#         'HHInc_74999' = 'B19001_012', # $60,000 to $74,999 HOUSEHOLD INCOME
#         'HHInc_99999' = 'B19001_013', # $75,000 to $99,999 HOUSEHOLD INCOME
#         'HHInc_124999' = 'B19001_014', # $100,000 to $124,999 HOUSEHOLD INCOME
#         'HHInc_149999' = 'B19001_015', # $125,000 to $149,999 HOUSEHOLD INCOME
#         'HHInc_199999' = 'B19001_016', # $150,000 to $199,999 HOUSEHOLD INCOME
#         'HHInc_200000' = 'B19001_017', # $200,000 or more HOUSEHOLD INCOME
#         'mhhinc' = 'B19013_001'
#     )

# df <- 
#     data.frame(
#         state = c(rep('17', 7), rep('13', 10), rep('08',9), rep('28',2), rep('47', 2)), 
#         county = c('031', '043', '089', '093', '097', '111', '197', '057', '063', '067', '089', '097', '113', '121', '135', '151', '247', '001', '005', '013', '014', '019', '031', '035', '047', '059', '033', '093', '047', '157'), 
#         city = c(rep('chicago',7), rep('atlanta', 10), rep('denver', 9), rep('memphis', 4)),
#         stringsAsFactors=FALSE)

# counties <- c('17031', '17043', '17089', '17093', '17097', '17111', '17197', '13057', '13063', '13067', '13089', '13097', '13113', '13121', '13135', '13151', '13247', '08001', '08005', '08013', '08014', '08019', '08031', '08035', '08047', '08059', '28033', '28093', '47047', '47157')

# #
# # Download data
# # --------------------------------------------------------------------------

# hh_inc_df_17 <- 
#     map_dfr(counties, function(x){
#     county <- str_sub(x, 3,5)
#     state <- str_sub(x, 1,2)
#     get_acs(
#         geography = "tract", 
#         state = state, 
#         county = county, 
#         variables = inc_vars,  
#         year = 2017,
#         geometry = FALSE, 
#         cache = TRUE
#     ) %>%
#     select(-moe) %>% 
#     spread(variable, estimate) %>% 
#     mutate(
#         county = str_sub(GEOID, 3,5), 
#         state = str_sub(GEOID, 1,2)) %>% 
#     left_join(., df)  
# })

# hh_inc_df_09 <- 
#     map_dfr(counties, function(x){
#     county <- str_sub(x, 3,5)
#     state <- str_sub(x, 1,2)
#     get_acs(
#         geography = "tract", 
#         state = state, 
#         county = county, 
#         variables = inc_vars,  
#         year = 2009,
#         geometry = FALSE, 
#         cache = TRUE
#     ) %>%
#     select(-moe) %>% 
#     spread(variable, estimate) %>% 
#     mutate(
#         county = str_sub(GEOID, 3,5), 
#         state = str_sub(GEOID, 1,2)) %>% 
#     left_join(., df)  
# })

# #
# # Merge data
# # --------------------------------------------------------------------------

# hh_inc <- 
#     bind_rows(
#         hh_inc_df_17 %>% mutate(year = 2017),
#         hh_inc_df_09 %>% mutate(year = 2009)
#     ) %>% 
#     mutate(
#         city_ami = median(mhhinc, na.rm = TRUE), 
#         city_50_ami = city_ami*.5, 
#         city_80_ami = city_ami*.8, 
#         city_120_ami = city_ami*1.2, 
#         city_150_ami = city_ami*1.5, 
#     ) %>% 
#     gather(var, tr_inc_count, HHInc_10000:HHInc_99999) %>% 
#     separate(var, c("type", "tr_hh_inc")) %>% 
#     mutate(
#         tr_hh_inc = as.numeric(tr_hh_inc), 
#         tr_hh_count = HHInc_Total, 
#         tr_p_50 = case_when(tr_hh_inc <= city_50_ami ~ tr_inc_count/tr_hh_count), 
#         tr_p_50_80 = case_when(tr_hh_inc > city_50_ami & tr_hh_inc <= city_80_ami ~ tr_inc_count/tr_hh_count), 
#         tr_p_80_120 = case_when(tr_hh_inc > city_80_ami & tr_hh_inc <= city_120_ami ~ tr_inc_count/tr_hh_count), 
#         tr_p_120_150 = case_when(tr_hh_inc > city_120_ami & tr_hh_inc <= city_150_ami ~ tr_inc_count/tr_hh_count), 
#         tr_p_150 = case_when(tr_hh_inc > city_150_ami ~ tr_inc_count/tr_hh_count), 
#     ) %>% 
#     replace(is.na(.), 0) %>% 
#     arrange(year, GEOID, tr_hh_inc) %>% 
#     group_by(GEOID, year) %>% 
#     mutate_at(vars(tr_p_50:tr_p_150), sum) %>% 
#     select(GEOID, year, county:city, city_ami:city_150_ami, tr_mhhinc = mhhinc, tr_hh_count:tr_p_150) %>% 
#     distinct() %>% 
#     ungroup() 

# #
# # summary graphs
# # --------------------------------------------------------------------------

# summary(hh_inc)

# hh_inc %>% 
#     gather(var, p, tr_p_50:tr_p_150) %>% 
#     filter(year == 2009) %>%
#     ggplot(aes(x = var, y = p)) + 
#     geom_boxplot()

# hh_inc %>% 
# filter(year == 2017) %>%
# ggplot() + 
# geom_point(aes(x = reorder(GEOID, tr_p_150), y = tr_p_150), color = "red", alpha = .2) +
# geom_point(aes(x = GEOID, y = tr_p_50), color = "blue", alpha = .2) + 
# geom_point(aes(x = GEOID, y = tr_p_50_80), color = "green", alpha = .2) + 
# geom_point(aes(x = GEOID, y = tr_p_80_120), color = "orange", alpha = .2) + 
# geom_point(aes(x = GEOID, y = tr_p_120_150), alpha = .2)

# ggplot(hh_inc)  + 
#     geom_histogram(aes(x = (tr_p_50_120)), color = "blue", alpha = .5, binwidth = 0.0005) + 
#     geom_histogram(aes(x = (tr_p_120)), color = "red", alpha = .5, binwidth = 0.0005) + 
#     geom_histogram(aes(x = (tr_p_50)), binwidth = 0.0005)

# #
# # Latent class mixture model look over time to identify trajectories
# # --------------------------------------------------------------------------

# s2 <- multlcmm(tr_p_80+tr_p_120~1+year,random=~1+year,subject="GEOID",link="linear",ng=2,mixture=~1+year,data=hh_inc %>% select(tr_p_80, tr_p_120, year, GEOID) %>% mutate(GEOID = as.numeric(GEOID)) %>% data.frame())
# s3 <- multlcmm(tr_p_80+tr_p_120~1+year,random=~1+year,subject="GEOID",link="linear",ng=3,mixture=~1+year,data=hh_inc %>% select(tr_p_80, tr_p_120, year, GEOID) %>% mutate(GEOID = as.numeric(GEOID)) %>% data.frame())
# s4 <- multlcmm(tr_p_80+tr_p_120~1+year,random=~1+year,subject="GEOID",link="linear",ng=4,mixture=~1+year,data=hh_inc %>% select(tr_p_80, tr_p_120, year, GEOID) %>% mutate(GEOID = as.numeric(GEOID)) %>% data.frame())
# s5 <- multlcmm(tr_p_80+tr_p_120~1+year,random=~1+year,subject="GEOID",link="linear",ng=5,mixture=~1+year,data=hh_inc %>% select(tr_p_80, tr_p_120, year, GEOID) %>% mutate(GEOID = as.numeric(GEOID)) %>% data.frame())
# s6 <- multlcmm(tr_p_80+tr_p_120~1+year,random=~1+year,subject="GEOID",link="linear",ng=6,mixture=~1+year,data=hh_inc %>% select(tr_p_80, tr_p_120, year, GEOID) %>% mutate(GEOID = as.numeric(GEOID)) %>% data.frame())
# s7 <- multlcmm(tr_p_80+tr_p_120~1+year,random=~1+year,subject="GEOID",link="linear",ng=7,mixture=~1+year,data=hh_inc %>% select(tr_p_80, tr_p_120, year, GEOID) %>% mutate(GEOID = as.numeric(GEOID)) %>% data.frame())

# s2$BIC # -26127.57
# s3$BIC # -26381.95 ###
# s4$BIC # -26323.41 ##
# s5$BIC # -26045.76
# s6$BIC # -26319.01 #
# s7$BIC # -26178.86

# summary(s2)
# postprob(s2)
# plot(s2,which="linkfunction")

# summary(s3)
# postprob(s3)
# plot(s3,which="linkfunction")

# summary(s4)
# postprob(s4)
# plot(s4,which="linkfunction")

# summary(s5)
# postprob(s5)
# plot(s5,which="linkfunction")

# summary(s6)
# postprob(s6)
# plot(s6,which="linkfunction")

# summary(s7)
# postprob(s7)
# plot(s7,which="linkfunction")

# # ==========================================================================
# # Affordability 
# # ==========================================================================



# # ==========================================================================
# # ==========================================================================
# # ==========================================================================
# # EXCESS CODE
# # ==========================================================================
# # ==========================================================================
# # ==========================================================================


# # ==========================================================================
# # Income by tenure
# # ==========================================================================


# hh_inc_vars <- 
#     c('HHIncTen_Total' = 'B25118_001', # Total
#     'HHIncTenOwn' = 'B25118_002', # Owner occupied
#     'HHIncTenOwn_4999' = 'B25118_003', # Owner occupied!!Less than $5,000
#     'HHIncTenOwn_9999' = 'B25118_004', # Owner occupied!!$5,000 to $9,999
#     'HHIncTenOwn_14999' = 'B25118_005', # Owner occupied!!$10,000 to $14,999
#     'HHIncTenOwn_19999' = 'B25118_006', # Owner occupied!!$15,000 to $19,999
#     'HHIncTenOwn_24999' = 'B25118_007', # Owner occupied!!$20,000 to $24,999
#     'HHIncTenOwn_34999' = 'B25118_008', # Owner occupied!!$25,000 to $34,999
#     'HHIncTenOwn_49999' = 'B25118_009', # Owner occupied!!$35,000 to $49,999
#     'HHIncTenOwn_74999' = 'B25118_010', # Owner occupied!!$50,000 to $74,999
#     'HHIncTenOwn_99999' = 'B25118_011', # Owner occupied!!$75,000 to $99,999
#     'HHIncTenOwn_149999' = 'B25118_012', # Owner occupied!!$100,000 to $149,999
#     'HHIncTenOwn_150000' = 'B25118_013', # Owner occupied!!$150,000 or more
#     'HHIncTenRent' = 'B25118_014', # Renter occupied
#     'HHIncTenRent_4999' = 'B25118_015', # Renter occupied!!Less than $5,000
#     'HHIncTenRent_9999' = 'B25118_016', # Renter occupied!!$5,000 to $9,999
#     'HHIncTenRent_14999' = 'B25118_017', # Renter occupied!!$10,000 to $14,999
#     'HHIncTenRent_19999' = 'B25118_018', # Renter occupied!!$15,000 to $19,999
#     'HHIncTenRent_24999' = 'B25118_019', # Renter occupied!!$20,000 to $24,999
#     'HHIncTenRent_34999' = 'B25118_020', # Renter occupied!!$25,000 to $34,999
#     'HHIncTenRent_49999' = 'B25118_021', # Renter occupied!!$35,000 to $49,999
#     'HHIncTenRent_74999' = 'B25118_022', # Renter occupied!!$50,000 to $74,999
#     'HHIncTenRent_99999' = 'B25118_023', # Renter occupied!!$75,000 to $99,999
#     'HHIncTenRent_149999' = 'B25118_024', # Renter occupied!!$100,000 to $149,999
#     'HHIncTenRent_150000' = 'B25118_025', # Renter occupied!!$150,000 or more
#     'mhhinc' = 'B19013_001'
#     )

# df <- 
#     data.frame(
#         state = c(rep('17', 7), rep('13', 10), rep('08',9), rep('28',2), rep('47', 2)), 
#         county = c('031', '043', '089', '093', '097', '111', '197', '057', '063', '067', '089', '097', '113', '121', '135', '151', '247', '001', '005', '013', '014', '019', '031', '035', '047', '059', '033', '093', '047', '157'), 
#         city = c(rep('chicago',7), rep('atlanta', 10), rep('denver', 9), rep('memphis', 4)),
#         stringsAsFactors=FALSE)

# counties <- c('17031', '17043', '17089', '17093', '17097', '17111', '17197', '13057', '13063', '13067', '13089', '13097', '13113', '13121', '13135', '13151', '13247', '08001', '08005', '08013', '08014', '08019', '08031', '08035', '08047', '08059', '28033', '28093', '47047', '47157')

# hh_inc_df_17 <- 
#     map_dfr(counties, function(x){
#     county <- str_sub(x, 3,5)
#     state <- str_sub(x, 1,2)
#     get_acs(
#         geography = "tract", 
#         state = state, 
#         county = county, 
#         variables = hh_inc_vars,  
#         year = 2017,
#         geomotry = TRUE, 
#         cache = TRUE
#     ) %>%
#     select(-moe) %>% 
#     spread(variable, estimate) %>% 
#     mutate(
#         county = str_sub(GEOID, 3,5), 
#         state = str_sub(GEOID, 1,2)) %>% 
#     left_join(., df)  
# })

# hh_inc_df_09 <- 
#     map_dfr(counties, function(x){
#     county <- str_sub(x, 3,5)
#     state <- str_sub(x, 1,2)
#     get_acs(
#         geography = "tract", 
#         state = state, 
#         county = county, 
#         variables = hh_inc_vars,  
#         year = 2009,
#         geomotry = TRUE, 
#         cache = TRUE
#     ) %>%
#     select(-moe) %>% 
#     spread(variable, estimate) %>% 
#     mutate(
#         county = str_sub(GEOID, 3,5), 
#         state = str_sub(GEOID, 1,2)) %>% 
#     left_join(., df)  
# })

# #
# # Merge data
# # --------------------------------------------------------------------------

# hh_inc_own17 <-     
#     hh_inc_df_17 %>% 
#     ungroup() %>% 
#     gather(inc_cat, inc_own_count, HHIncTenOwn_14999:HHIncTenOwn_99999) %>% 
#     mutate(inc_cat = 
#         as.numeric(
#             case_when(
#                 inc_cat == 'HHIncTenOwn_4999' ~ 4999, 
#                 inc_cat == 'HHIncTenOwn_9999' ~ 9999,
#                 inc_cat == 'HHIncTenOwn_14999' ~ 14999, 
#                 inc_cat == 'HHIncTenOwn_19999' ~ 19999,
#                 inc_cat == 'HHIncTenOwn_24999' ~ 24999,
#                 inc_cat == 'HHIncTenOwn_34999' ~ 34999,
#                 inc_cat == 'HHIncTenOwn_49999' ~ 49999, 
#                 inc_cat == 'HHIncTenOwn_74999' ~ 74999,
#                 inc_cat == 'HHIncTenOwn_99999' ~ 99999, 
#                 inc_cat == 'HHIncTenOwn_149999' ~ 149999,
#                 inc_cat == 'HHIncTenOwn_150000' ~ 150000)
#         )
#         ) %>% 
#     select(GEOID, tr_mhhinc = mhhinc, tr_inc_cat = inc_cat, tr_inc_own_count = inc_own_count, tr_tot_own = HHIncTenOwn, tr_tot_hh = HHIncTen_Total)

# hh_inc_rent17 <- 
#     hh_inc_df_17 %>% 
#     ungroup() %>% 
#     gather(inc_cat, inc_rent_count, HHIncTenRent_14999:HHIncTenRent_99999) %>% 
#     mutate(inc_cat = 
#         as.numeric(
#             case_when(
#                 inc_cat == 'HHIncTenRent_4999' ~ 4999, 
#                 inc_cat == 'HHIncTenRent_9999' ~ 9999,
#                 inc_cat == 'HHIncTenRent_14999' ~ 14999, 
#                 inc_cat == 'HHIncTenRent_19999' ~ 19999,
#                 inc_cat == 'HHIncTenRent_24999' ~ 24999,
#                 inc_cat == 'HHIncTenRent_34999' ~ 34999,
#                 inc_cat == 'HHIncTenRent_49999' ~ 49999, 
#                 inc_cat == 'HHIncTenRent_74999' ~ 74999,
#                 inc_cat == 'HHIncTenRent_99999' ~ 99999, 
#                 inc_cat == 'HHIncTenRent_149999' ~ 149999,
#                 inc_cat == 'HHIncTenRent_150000' ~ 150000)
#         )
#         ) %>% 
#     select(GEOID, tr_mhhinc = mhhinc, tr_inc_cat = inc_cat, tr_inc_rent_count = inc_rent_count, tr_tot_rent = HHIncTenRent, tr_tot_hh = HHIncTen_Total)

# hh_inc_df_17_2 <-
#     left_join(hh_inc_own17, hh_inc_rent17) %>%
#     arrange(GEOID, tr_inc_cat) %>% 
#     mutate(
#         city_mhhinc = median(tr_mhhinc, na.rm = TRUE), 
#         city_50_ami = city_mhhinc*.5, 
#         city_80_ami = city_mhhinc*.8, 
#         city_120_ami = city_mhhinc*1.2, 
#         city_150_ami = city_mhhinc*1.5, 
#         # tr_p_50_own = case_when(tr_inc_cat <= city_50_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_80_own = case_when(tr_inc_cat > city_50_ami & tr_inc_cat <= city_80_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_100_own = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_mhhinc ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_120_own = case_when(tr_inc_cat > city_mhhinc & tr_inc_cat <= city_120_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_150_own = case_when(tr_inc_cat > city_120_ami & tr_inc_cat <= city_150_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_150p_own = case_when(tr_inc_cat > city_150_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_50_rent = case_when(tr_inc_cat <= city_50_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_80_rent = case_when(tr_inc_cat > city_50_ami & tr_inc_cat <= city_80_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_100_rent = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_mhhinc ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_120_rent = case_when(tr_inc_cat > city_mhhinc & tr_inc_cat <= city_120_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_150_rent = case_when(tr_inc_cat > city_120_ami & tr_inc_cat <= city_150_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_150p_rent = case_when(tr_inc_cat > city_150_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         tr_p_80_own = case_when(tr_inc_cat <= city_80_ami ~ tr_inc_own_count/tr_tot_hh), 
#         tr_p_80_120_own = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_120_ami ~ tr_inc_own_count/tr_tot_hh), 
#         tr_p_120_own = case_when(tr_inc_cat > city_120_ami ~ tr_inc_own_count/tr_tot_hh), 
#         tr_p_80_rent = case_when(tr_inc_cat <= city_80_ami ~ tr_inc_rent_count/tr_tot_hh), 
#         tr_p_80_120_rent = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_120_ami ~ tr_inc_rent_count/tr_tot_hh), 
#         tr_p_120_rent = case_when(tr_inc_cat > city_120_ami ~ tr_inc_rent_count/tr_tot_hh), 
#         year = 2017) %>%
#     replace(is.na(.), 0) %>%
#     group_by(GEOID, year) %>% 
#     summarise_at(vars(tr_p_80_own:tr_p_120_rent), sum)

# hh_inc_own09 <-     
#     hh_inc_df_09 %>% 
#     ungroup() %>% 
#     gather(inc_cat, inc_own_count, HHIncTenOwn_14999:HHIncTenOwn_99999) %>% 
#     mutate(inc_cat = 
#         as.numeric(
#             case_when(
#                 inc_cat == 'HHIncTenOwn_4999' ~ 4999, 
#                 inc_cat == 'HHIncTenOwn_9999' ~ 9999,
#                 inc_cat == 'HHIncTenOwn_14999' ~ 14999, 
#                 inc_cat == 'HHIncTenOwn_19999' ~ 19999,
#                 inc_cat == 'HHIncTenOwn_24999' ~ 24999,
#                 inc_cat == 'HHIncTenOwn_34999' ~ 34999,
#                 inc_cat == 'HHIncTenOwn_49999' ~ 49999, 
#                 inc_cat == 'HHIncTenOwn_74999' ~ 74999,
#                 inc_cat == 'HHIncTenOwn_99999' ~ 99999, 
#                 inc_cat == 'HHIncTenOwn_149999' ~ 149999,
#                 inc_cat == 'HHIncTenOwn_150000' ~ 150000)
#         )
#         ) %>% 
#     select(GEOID, tr_mhhinc = mhhinc, tr_inc_cat = inc_cat, tr_inc_own_count = inc_own_count, tr_tot_own = HHIncTenOwn, tr_tot_hh = HHIncTen_Total)

# hh_inc_rent09 <- 
#     hh_inc_df_09 %>% 
#     ungroup() %>% 
#     gather(inc_cat, inc_rent_count, HHIncTenRent_14999:HHIncTenRent_99999) %>% 
#     mutate(inc_cat = 
#         as.numeric(
#             case_when(
#                 inc_cat == 'HHIncTenRent_4999' ~ 4999, 
#                 inc_cat == 'HHIncTenRent_9999' ~ 9999,
#                 inc_cat == 'HHIncTenRent_14999' ~ 14999, 
#                 inc_cat == 'HHIncTenRent_19999' ~ 19999,
#                 inc_cat == 'HHIncTenRent_24999' ~ 24999,
#                 inc_cat == 'HHIncTenRent_34999' ~ 34999,
#                 inc_cat == 'HHIncTenRent_49999' ~ 49999, 
#                 inc_cat == 'HHIncTenRent_74999' ~ 74999,
#                 inc_cat == 'HHIncTenRent_99999' ~ 99999, 
#                 inc_cat == 'HHIncTenRent_149999' ~ 149999,
#                 inc_cat == 'HHIncTenRent_150000' ~ 150000)
#         )
#         ) %>% 
#     select(GEOID, tr_mhhinc = mhhinc, tr_inc_cat = inc_cat, tr_inc_rent_count = inc_rent_count, tr_tot_rent = HHIncTenRent, tr_tot_hh = HHIncTen_Total)

# hh_inc_df_09_2 <-
#     left_join(hh_inc_own09, hh_inc_rent09) %>%
#     arrange(GEOID, tr_inc_cat) %>% 
#     mutate(
#         city_mhhinc = median(tr_mhhinc, na.rm = TRUE), 
#         city_50_ami = city_mhhinc*.5, 
#         city_80_ami = city_mhhinc*.8, 
#         city_120_ami = city_mhhinc*1.2, 
#         city_150_ami = city_mhhinc*1.5, 
#         # tr_p_50_own = case_when(tr_inc_cat <= city_50_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_80_own = case_when(tr_inc_cat > city_50_ami & tr_inc_cat <= city_80_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_100_own = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_mhhinc ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_120_own = case_when(tr_inc_cat > city_mhhinc & tr_inc_cat <= city_120_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_150_own = case_when(tr_inc_cat > city_120_ami & tr_inc_cat <= city_150_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_150p_own = case_when(tr_inc_cat > city_150_ami ~ tr_inc_own_count/tr_tot_own), 
#         # tr_p_50_rent = case_when(tr_inc_cat <= city_50_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_80_rent = case_when(tr_inc_cat > city_50_ami & tr_inc_cat <= city_80_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_100_rent = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_mhhinc ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_120_rent = case_when(tr_inc_cat > city_mhhinc & tr_inc_cat <= city_120_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_150_rent = case_when(tr_inc_cat > city_120_ami & tr_inc_cat <= city_150_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         # tr_p_150p_rent = case_when(tr_inc_cat > city_150_ami ~ tr_inc_rent_count/tr_tot_rent), 
#         tr_p_80_own = case_when(tr_inc_cat <= city_80_ami ~ tr_inc_own_count/tr_tot_hh), 
#         tr_p_80_120_own = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_120_ami ~ tr_inc_own_count/tr_tot_hh), 
#         tr_p_120_own = case_when(tr_inc_cat > city_120_ami ~ tr_inc_own_count/tr_tot_hh), 
#         tr_p_80_rent = case_when(tr_inc_cat <= city_80_ami ~ tr_inc_rent_count/tr_tot_hh), 
#         tr_p_80_120_rent = case_when(tr_inc_cat > city_80_ami & tr_inc_cat <= city_120_ami ~ tr_inc_rent_count/tr_tot_hh), 
#         tr_p_120_rent = case_when(tr_inc_cat > city_120_ami ~ tr_inc_rent_count/tr_tot_hh), 
#         year = 2009) %>%
#     replace(is.na(.), 0) %>% 
#     group_by(GEOID, year) %>% 
#     summarise_at(vars(tr_p_80_own:tr_p_120_rent), sum)



# hh_inc_df_fin <- 
#     bind_rows(hh_inc_df_17_2, 
#               hh_inc_df_09_2) %>% 
#     distinct() %>% 
#     left_join(., bind_rows(
#                     hh_inc_df_17 %>% mutate(year = 2017), 
#                     hh_inc_df_09 %>% mutate(year = 2009)
#                 ) %>% 
#                 select(GEOID, HHIncTen_Total, HHIncTenOwn, HHIncTenRent, tr_mhhinc= mhhinc, county:city, year) %>% 
#                 ungroup() %>% 
#                 mutate(tr_p_rent = HHIncTenRent/HHIncTen_Total) %>% 
#                 distinct()
#     ) %>% 
#     ungroup()

# # ==========================================================================
# # Affordability
# # ==========================================================================

# #
# # Review what we have
# # --------------------------------------------------------------------------

# ggplot(hh_inc_df_09_2 %>% gather(est, val, tr_p_80_rent:tr_p_120_rent), aes(x = est, y = val)) + 
# geom_boxplot()

# # Neighborhood income type graph
# hh_inc_df_17_2 %>% 
# group_by(GEOID) %>% 
# summarise_at(vars(tr_p_80_own:tr_p_120_rent), sum) %>% 
# ggplot() + 
# geom_point(aes(x = reorder(GEOID, tr_p_80_120_rent), y = tr_p_80_120_rent), color = "red") +
# geom_point(aes(x = GEOID, y = tr_p_80_rent), color = "blue") + 
# geom_point(aes(x = GEOID, y = tr_p_120_rent), color = "green")

# ggplot(hh_inc_df_17_2)  + 
#     geom_histogram(aes(x = (tr_p_80_120_rent)), color = "blue", alpha = .5, binwidth = 0.0005) + 
#     geom_histogram(aes(x = (tr_p_120_rent)), color = "red", alpha = .5, binwidth = 0.0005) + 
#     geom_histogram(aes(x = (tr_p_80_rent)), binwidth = 0.0005)

# check <- 
# hh_inc_df_17_2 %>% 
# mutate(
#     sc_tr_p_80_120_rent = scale(tr_p_80_120_rent, na.omit = TRUE),
#     sc_tr_p_80_120_rent = scale(tr_p_80_120_rent, na.omit = TRUE),
#     sc_tr_p_120_rent = scale(tr_p_120_rent, na.omit = TRUE), 
#     index = sum(sc_tr_p_80_120_rent, sc_tr_p_80_120_rent, sc_tr_p_120_rent)
# ) %>% glimpse()


# hh_inc_df2 %>% filter(GEOID == "08001008402") %>% data.frame()

# library(mclust)
# fit <- Mclust(hh_inc_df2 %>% select(GEOID, tr_p_50_rent:tr_p_150p_rent) %>% replace(is.na(.), 0))

# ## Example ## 

#     %>% 
#     mutate(
#         GEOID = factor(GEOID), 
#         p_HHIncTenRent_5 = HHIncTenRent_5/HHIncTenRent,         
#         p_HHIncTenRent_10 = HHIncTenRent_10/HHIncTenRent, 
#         p_HHIncTenRent_15 = HHIncTenRent_15/HHIncTenRent, 
#         p_HHIncTenRent_20 = HHIncTenRent_20/HHIncTenRent,   
#         p_HHIncTenRent_25 = HHIncTenRent_25/HHIncTenRent,   
#         p_HHIncTenRent_35 = HHIncTenRent_35/HHIncTenRent, 
#         p_HHIncTenRent_50 = HHIncTenRent_50/HHIncTenRent,   
#         p_HHIncTenRent_75 = HHIncTenRent_75/HHIncTenRent,
#         p_HHIncTenRent_100 = HHIncTenRent_100/HHIncTenRent, 
#         p_HHIncTenRent_150 = HHIncTenRent_150/HHIncTenRent, 
#         p_HHIncTenRent_151 = HHIncTenRent_151/HHIncTenRent, 




# df3 <- 
#     df2 %>% 
#     group_by(GEOID) %>% 
#     mutate(
#         `5` = p_HHIncTenRent_5,         
#         `10` = p_HHIncTenRent_10 + `5`,
#         `15` = p_HHIncTenRent_15 + `10`,
#         `20` = p_HHIncTenRent_20 + `15`,
#         `25` = p_HHIncTenRent_25 + `20`,
#         `35` = p_HHIncTenRent_35 + `25`,
#         `50` = p_HHIncTenRent_50 + `35`,
#         `75` = p_HHIncTenRent_75 + `50`,
#         `100` = p_HHIncTenRent_100 + `75`,
#         `150` = p_HHIncTenRent_150 + `100`,
#         `151` = p_HHIncTenRent_151 + `150`
#     ) %>% 
# gather(var, p, `5`:`151`) %>% 
# arrange(GEOID) %>% 
# data.frame()

# mutate(var = factor(var, levels = c("p_0", "p_5","p_10","p_15","p_20","p_25","p_35","p_50","p_75","p_100","p_150","p_151")), 
#        p_num = as.numeric())

# df3 %>% 
# filter(city == "chicago") %>% 
# ggplot(aes(x = var, y = p, group = GEOID)) + 
#     geom_line(alpha = .1, size = .2) + 
#     geom_abline(aes(intercept=-.09, slope=1/11), color = "red")

# ### Left off, see if this seperates the data appropriatly. 

# s2 <- lcmm(var~1+p,random=p,subject="GEOID",link="linear",ng=2,mixture=p,data=df3 %>% mutate(var = as.numeric(var)) %>% select(GEOID, var, p))


# s3 <- lcmm(var~1+p,random=p,subject="GEOID",link="linear",ng=3,mixture=p,data=df3)
# s4 <- lcmm(var~1+p,random=~1+p,subject="GEOID",link="linear",ng=4,mixture=~1+p,data=df3)
# s5 <- lcmm(var~1+p,random=~1+p,subject="GEOID",link="linear",ng=5,mixture=~1+p,data=df3)
# s6 <- lcmm(var~1+p,random=~1+p,subject="GEOID",link="linear",ng=6,mixture=~1+p,data=df3)
# # s2 <- lcmm(var~1+p,random=~1+p,subject="GEOID",link="linear",ng=2,mixture=~1+p,data=df3)
# # s2 <- lcmm(var~1+p,random=~1+p,subject="GEOID",link="linear",ng=2,mixture=~1+p,data=df3)


# # ==========================================================================
# # EDA
# # Data dictionary: https://docs.google.com/spreadsheets/d/1A_Tk0EjN-ORTGmt41Fzykbh-4JRB38jwWwtn-pMO8C4/edit#gid=664440995
# # ==========================================================================

# #
# # Gentrification 
# # --------------------------------------------------------------------------

# data %>% 
#     group_by(city) %>% 
#     summarise(
#         count = n(), 
#         p_gent_17 = sum(gent_00_17)/count, 
#         p_gent_00 = sum(gent_90_00)/count, 
#         dif = p_gent_17 - p_gent_00
#     ) %>% 
#     ggplot(.) +
#     geom_point(aes(x = reorder(city, p_gent_17), y = p_gent_17), pch = 21, color = 'grey10', alpha = 1, size = 5) +
#     geom_point(aes(x = city, y = p_gent_00), pch = 21, color = 'grey70', alpha = 1, size = 5) +
#     theme_minimal() +
#     ylab('proportion of tracts that gentrified\n1990 to 2000 & 2000 to 2017') +
#     xlab('') +
#     coord_flip()

#     ####
#     # Note: 
#     # Chicago had small increase in gentrified tracts, followed by Atlanta. 
#     # Atlanta has the smallest proportion of gentrified neighborhoods
#     #   * could this be consolidated concentration in the Atlanta area?  
#     # Denver and Memphis had the biggest gains (13% and 12%) while 
#     #   Atlanta and Chicago had the smallest gains (5% and 6%)
#     ####

# #
# # LI
# # --------------------------------------------------------------------------

# data %>%
#     ggplot(., aes(x = city, y = ch_all_li_count_00_17*-1)) +
#     geom_jitter(alpha = .3) +
#     geom_violin(draw_quantiles = c(0.5), alpha = .6) +
#     theme_minimal() +
#     ylab('Tract LI absolute losses (-) and gains (+)\n2000 to 2017') +
#     xlab('') + 
#     geom_hline(yintercept = 0, color = "red", linetype = "dotted") +
#     coord_flip()

#     ### 
#     # Atlanta had the most tracts with the highest absolute losses as 
#     # well as the biggest variation. 
#     ###

# # ==========================================================================
# # Model setup 
# # ==========================================================================
# eda1 <-  
#     data %>% 
#     filter(!is.na(gent_00_17)) 

# mod_y1 = eda1$gent_00_17
# mod_x1 = 
#     eda1 %>% 
#     select(
#         real_hinc_00,
#         hinc_00,
#         per_nonwhite_00,
#         per_rent_00,
#         per_units_pre50_17,
#         city,
#         # per_built_00_17,
#         # i.lihtc_fl_00,
#         # i.downtown,
#         # i.rail_00,
#         # vac_00,
#         # i.ph_fl,
#         # i.hosp_fl,
#         # i.uni_fl,
#         # per_carcommute_00
# ) %>% 
#     data.frame()

# m1 =
#     bartMachine(
#         X = mod_x2, y = mod_y2, 
#         num_trees = 200, 
#         k = 1, 
#         num_iterations_after_burn_in = 2000,
#         use_missing_data = TRUE
#         )

# # ... Look at the variable of importance
# investigate_var_importance(m1)

# #
# # Predict
# # --------------------------------------------------------------------------

# funR = function(sim.model, 
#                 sim.real_hinc, 
#                 sim.hinc, 
#                 sim.nonwhite, 
#                 sim.rent, 
#                 sim.units, 
#                 sim.city){
#     sim_A = data.frame(real_hinc_00  = sim.real_hinc,
#                        hinc_00 = sim.hinc,  
#                        per_nonwhite_00  = rev(seq(0, 1, .01)),
#                        per_rent_00 = sim.rent,
#                        per_units_pre50_17  = sim.units,
#                        city = sim.city[1])

#     sim_B = sim_A %>% mutate(city = sim.city[2])
#     sim_C = sim_A %>% mutate(city = sim.city[3])
#     sim_D = sim_A %>% mutate(city = sim.city[4])

#     sims = bind_rows(sim_A, sim_B, sim_C, sim_D)

#     preds = predict(sim.model, sims) %>% data.frame(pred = .)
#     ints  = calc_credible_intervals(sim.model, sims) %>% data.frame()

#     sim.dat = bind_cols(preds, ints) %>%
#               rename(lwr = ci_lower_bd, upr = ci_upper_bd) %>%
#               bind_cols(sims) %>%
#               tbl_df()

#     return(sim.dat)
# }

# cities <- c("Atlanta", "Chicago", "Denver", "Memphis")
# # .... run and store
# eda_sims = funR(m1, 0, 0, seq(0, 1, .01), 0, 0, cities)

# data %>% ggplot(., aes(x = per_nonwhite_00)) + geom_freqpoly() + theme_minimal()

# eda2 <- 
#     data %>% 
#     filter(!is.na(ch_all_li_count_00_17)) 

# mod_y2 = eda2$ch_all_li_count_00_17
# mod_x2 = 
#     eda2 %>% 
#     select(

#         # left off
#         real_hinc_00,
#         hinc_00,
#         per_nonwhite_00,
#         per_rent_00,
#         per_units_pre50_17#,
#         # per_built_00_17,
#         # i.lihtc_fl_00,
#         # i.downtown,
#         # i.rail_00,
#         # vac_00,
#         # i.ph_fl,
#         # i.hosp_fl,
#         # i.uni_fl,
#         # per_carcommute_00
# ) %>% 
#     data.frame()

# m2 =
#     bartMachine(
#         X = mod_x2, 
#         y = mod_y2, 
#         num_trees = 200, 
#         k = 1, 
#         num_iterations_after_burn_in = 2000,
#         use_missing_data = TRUE
#         )

# investigate_var_importance(m2)

# #
# # rankseg example
# # --------------------------------------------------------------------------

# x1 <- matrix(nrow = 4, ncol = 7)
# x1[1,] <- c( 10, 10, 10, 20, 30, 40, 50) 
# x1[2,] <- c( 0, 20, 10, 10, 10, 20, 20) 
# x1[3,] <- c(10, 20, 10, 10, 10, 0, 0 ) 
# x1[4,] <- c(30, 30, 20, 10, 10, 0, 0 ) 

# x2 <- x1
# x2[,c(3,4,6,7)] <- x1[,c(6,7,3,4)]
# rankorderseg(x1)
# rankorderseg(x2, pred = seq(0, 1, 0.1))




# hhinc <- 
#     c('HHIncTen_Total' = 'B25118_001', # Total
#     'HHIncTenOwn' = 'B25118_002', # Owner occupied
#     'HHIncTenOwn_5' = 'B25118_003', # Owner occupied!!Less than $5,000
#     'HHIncTenOwn_10' = 'B25118_004', # Owner occupied!!$5,000 to $9,999
#     'HHIncTenOwn_15' = 'B25118_005', # Owner occupied!!$10,000 to $14,999
#     'HHIncTenOwn_20' = 'B25118_006', # Owner occupied!!$15,000 to $19,999
#     'HHIncTenOwn_25' = 'B25118_007', # Owner occupied!!$20,000 to $24,999
#     'HHIncTenOwn_35' = 'B25118_008', # Owner occupied!!$25,000 to $34,999
#     'HHIncTenOwn_50' = 'B25118_009', # Owner occupied!!$35,000 to $49,999
#     'HHIncTenOwn_75' = 'B25118_010', # Owner occupied!!$50,000 to $74,999
#     'HHIncTenOwn_100' = 'B25118_011', # Owner occupied!!$75,000 to $99,999
#     'HHIncTenOwn_150' = 'B25118_012', # Owner occupied!!$100,000 to $149,999
#     'HHIncTenOwn_151' = 'B25118_013', # Owner occupied!!$150,000 or more
#     'HHIncTenRent' = 'B25118_014', # Renter occupied
#     'HHIncTenRent_5' = 'B25118_015', # Renter occupied!!Less than $5,000
#     'HHIncTenRent_10' = 'B25118_016', # Renter occupied!!$5,000 to $9,999
#     'HHIncTenRent_15' = 'B25118_017', # Renter occupied!!$10,000 to $14,999
#     'HHIncTenRent_20' = 'B25118_018', # Renter occupied!!$15,000 to $19,999
#     'HHIncTenRent_25' = 'B25118_019', # Renter occupied!!$20,000 to $24,999
#     'HHIncTenRent_35' = 'B25118_020', # Renter occupied!!$25,000 to $34,999
#     'HHIncTenRent_50' = 'B25118_021', # Renter occupied!!$35,000 to $49,999
#     'HHIncTenRent_75' = 'B25118_022', # Renter occupied!!$50,000 to $74,999
#     'HHIncTenRent_100' = 'B25118_023', # Renter occupied!!$75,000 to $99,999
#     'HHIncTenRent_150' = 'B25118_024', # Renter occupied!!$100,000 to $149,999
#     'HHIncTenRent_151' = 'B25118_025' # Renter occupied!!$150,000 or more
#     )

# oak <- 
#     get_acs(
#         geography = "tract", 
#         state = "ca", 
#         county = "Alameda", 
#         variables = hhinc, 
#         geomotry = TRUE, 
#         cache = TRUE
#     ) %>%
#     select(-moe) %>% 
#     spread(variable, estimate) 

# oak2 <- oak %>% 
#     mutate(
#         GEOID = factor(GEOID), 
#         p_HHIncTenRent_10 = HHIncTenRent_10/HHIncTenRent, 
#         p_HHIncTenRent_100 = HHIncTenRent_100/HHIncTenRent, 
#         p_HHIncTenRent_15 = HHIncTenRent_15/HHIncTenRent, 
#         p_HHIncTenRent_150 = HHIncTenRent_150/HHIncTenRent, 
#         p_HHIncTenRent_151 = HHIncTenRent_151/HHIncTenRent, 
#         p_HHIncTenRent_20 = HHIncTenRent_20/HHIncTenRent, 
#         p_HHIncTenRent_25 = HHIncTenRent_25/HHIncTenRent, 
#         p_HHIncTenRent_35 = HHIncTenRent_35/HHIncTenRent, 
#         p_HHIncTenRent_5 = HHIncTenRent_5/HHIncTenRent, 
#         p_HHIncTenRent_50 = HHIncTenRent_50/HHIncTenRent, 
#         p_HHIncTenRent_75 = HHIncTenRent_75/HHIncTenRent
#     ) %>%
#     select(GEOID, starts_with("p_"))

# glimpse(oak2)

# # ==========================================================================
# # lcmm model for just the variables
# # ==========================================================================

# s3 <- multlcmm(
#     p_HHIncTenRent_10 + p_HHIncTenRent_100 + p_HHIncTenRent_15 + p_HHIncTenRent_150 + p_HHIncTenRent_151 + p_HHIncTenRent_20 + p_HHIncTenRent_25 + p_HHIncTenRent_35 + p_HHIncTenRent_5 + p_HHIncTenRent_50 + p_HHIncTenRent_75~1,random=~1,subject="GEOID",link="linear",ng=3,mixture=~1,data=oak2)
# s4 <- multlcmm(dis+pbl+pot~1+year,random=~1+year,subject="GEO2010",link="linear",ng=4,mixture=~1+year,data=l.dt)
# s5 <- multlcmm(dis+pbl+pot~1+year,random=~1+year,subject="GEO2010",link="linear",ng=5,mixture=~1+year,data=l.dt)
