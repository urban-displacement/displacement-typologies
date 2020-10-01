# ==========================================================================
# displacement-typologies data setup
# ==========================================================================

if(!require(pacman)) install.packages("pacman")
devtools::install_github('walkerke/tigris')
devtools::install_github('walkerke/tidycensus')
pacman::p_load(R.utils, bit64, rgeos, data.table, tigris, tidycensus, tidyverse, spdep)
# options(width = Sys.getenv('COLUMNS'))

census_api_key("4c26aa6ebbaef54a55d3903212eabbb506ade381")
# census_api_key("your_api_key_here", install = TRUE)

#
# Pull in Data
# --------------------------------------------------------------------------# Note: Adjust the cities below if there are additional cities - add your city here

databases <- 
    bind_rows(
        # Atlanta
            fread("~/git/displacement-typologies/data/outputs/databases/Atlanta_database_2017.csv", integer64 = "double") %>% 
            mutate(city = "Atlanta"),
        # Denver
            fread("~/git/displacement-typologies/data/outputs/databases/Denver_database_2017.csv", integer64 = "double") %>% 
            mutate(city = "Denver"),
        # Chicago
            fread("~/git/displacement-typologies/data/outputs/databases/Chicago_database_2017.csv", integer64 = "double") %>% 
            mutate(city = "Chicago"),
        # Memphis
            fread("~/git/displacement-typologies/data/outputs/databases/Memphis_database_2017.csv", integer64 = "double") %>% 
            mutate(city = "Memphis")
    )

# ==========================================================================
# Create rent gap and extra local change in rent
# ==========================================================================

#
# Tract data
# --------------------------------------------------------------------------
# Note: Make sure to extract tracts that surround cities. For example, in 
# Memphis and Chicago, TN, MO, MS, and AL are within close proximity of 
# Memphis and IN is within close proximity of Chicago. 

### Tract data extraction function: add your state here
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

# ==========================================================================
# Begin save 2012 & 2017 tract data
# ==========================================================================
### Loop (map) across different states
#
# tr_rents17 <- 
#     map_dfr(st, function(state){
#         tr_rent(year = 2017, state) %>% 
#         mutate(COUNTY = substr(GEOID, 1, 5))
#     })
# saveRDS(tr_rents17, "~/git/displacement-typologies/data/outputs/downloads/tr_rents17.rds")
#
# tr_rents12 <- 
#     map_dfr(st, function(state){
#         tr_rent(year = 2012, state) %>% 
#         mutate(
#             COUNTY = substr(GEOID, 1, 5),
#             medrent = medrent*1.07)
#     })
# saveRDS(tr_rents12, "~/git/displacement-typologies/data/outputs/downloads/tr_rents12.rds")
# ==========================================================================
# End save
# ==========================================================================
tr_rents12 <- readRDS("~/git/displacement-typologies/data/outputs/downloads/tr_rents12.rds")
tr_rents17 <- readRDS("~/git/displacement-typologies/data/outputs/downloads/tr_rents17.rds")


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

# ==========================================================================
# Begin download state tracts and union
# ==========================================================================
# Pull in state tracts shapefile and unite them into one shapefile
# Add your state here
# states <- 
#     raster::union(
#         tracts("IL", cb = TRUE, class = 'sp'), 
#         tracts("GA", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("AR", cb = TRUE, class = 'sp')) %>%  
#     raster::union(tracts("TN", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("CO", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("MS", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("AL", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("KY", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("MO", cb = TRUE, class = 'sp')) %>%
#     raster::union(tracts("IN", cb = TRUE, class = 'sp'))
#
# saveRDS(states, "~/git/displacement-typologies/data/outputs/downloads/states.rds")
# ==========================================================================
# End download
# ==========================================================================

stsp <- readRDS("~/git/displacement-typologies/data/outputs/downloads/states.rds")

# join data to these tracts
stsp@data <-
    left_join(
        stsp@data %>% 
        mutate(GEOID = case_when(
            !is.na(GEOID.1) ~ GEOID.1, 
            !is.na(GEOID.2) ~ GEOID.2, 
            !is.na(GEOID.1.1) ~ GEOID.1.1, 
            !is.na(GEOID.1.2) ~ GEOID.1.2, 
            !is.na(GEOID.1.3) ~ GEOID.1.3), 
    ), 
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
# Join lag vars with databases
# ==========================================================================

lag <-  
    left_join(
        databases, 
        stsp@data %>% 
            mutate(GEOID = as.numeric(GEOID)) %>%
            select(GEOID, tr_medrent17:tr_medrent17.lag)
            ) %>%
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
                               tr_pchrent.lag > rm_pchrent.lag ~ 1, # ∆ nearby tracts
                               TRUE ~ 0),
        dp_RentGap = case_when(tr_rent_gapprop > 0 & tr_rent_gapprop > rm_rent_gapprop ~ 1,
                               TRUE ~ 0),
    ) 

# ==========================================================================
# PUMA
# ==========================================================================

# ==========================================================================
# Begin download puma
# ==========================================================================
# puma <-
#     get_acs(
#         geography = "public use microdata area", 
#         variable = "B05006_001", 
#         year = 2017, 
#         geometry = TRUE,
#         keep_geo_vars = TRUE, 
#         state = c("GA", "TN", "IL", "CO")) %>% 
#     mutate(
#         sqmile = ALAND10/2589988, 
#         puma_density = estimate/sqmile
#         ) %>% 
#     st_as_sf() %>% 
#     select(puma_density)
#
# saveRDS(puma, "~/git/displacement-typologies/data/outputs/downloads/puma_2017.rds")
# ==========================================================================
# End download puma
# ==========================================================================

puma <- readRDS("~/git/displacement-typologies/data/outputs/downloads/puma_2017.rds")

stsf <- 
    stsp %>% 
    st_as_sf() %>% 
    st_transform(4269) %>% 
    st_centroid() %>% 
    st_join(puma) %>% 
    mutate(dense = case_when(puma_density >= 3000 ~ 1, TRUE ~ 0)) %>% 
    st_drop_geometry() %>% 
    select(GEOID, puma_density, dense) %>% 
    mutate(GEOID = as.numeric(GEOID))

lag <- 
    left_join(lag, stsf)

fwrite(lag, "~/git/displacement-typologies/data/outputs/lags/lag_2017.csv")
