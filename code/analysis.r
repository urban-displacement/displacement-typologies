# ==========================================================================
# SPARCC Analysis
# ==========================================================================

pacman::p_load(tidyverse, tidycensus, stringr, ggplot2, RColorBrewer, gridExtra, lcmm)
options(java.parameters = "-Xmx30g")
library(bartMachine)
set_bart_machine_num_cores(8)
set.seed(100)

hhinc <- 
    c('HHIncTen_Total' = 'B25118_001', # Total
    'HHIncTenOwn' = 'B25118_002', # Owner occupied
    'HHIncTenOwn_5' = 'B25118_003', # Owner occupied!!Less than $5,000
    'HHIncTenOwn_10' = 'B25118_004', # Owner occupied!!$5,000 to $9,999
    'HHIncTenOwn_15' = 'B25118_005', # Owner occupied!!$10,000 to $14,999
    'HHIncTenOwn_20' = 'B25118_006', # Owner occupied!!$15,000 to $19,999
    'HHIncTenOwn_25' = 'B25118_007', # Owner occupied!!$20,000 to $24,999
    'HHIncTenOwn_35' = 'B25118_008', # Owner occupied!!$25,000 to $34,999
    'HHIncTenOwn_50' = 'B25118_009', # Owner occupied!!$35,000 to $49,999
    'HHIncTenOwn_75' = 'B25118_010', # Owner occupied!!$50,000 to $74,999
    'HHIncTenOwn_100' = 'B25118_011', # Owner occupied!!$75,000 to $99,999
    'HHIncTenOwn_150' = 'B25118_012', # Owner occupied!!$100,000 to $149,999
    'HHIncTenOwn_151' = 'B25118_013', # Owner occupied!!$150,000 or more
    'HHIncTenRent' = 'B25118_014', # Renter occupied
    'HHIncTenRent_5' = 'B25118_015', # Renter occupied!!Less than $5,000
    'HHIncTenRent_10' = 'B25118_016', # Renter occupied!!$5,000 to $9,999
    'HHIncTenRent_15' = 'B25118_017', # Renter occupied!!$10,000 to $14,999
    'HHIncTenRent_20' = 'B25118_018', # Renter occupied!!$15,000 to $19,999
    'HHIncTenRent_25' = 'B25118_019', # Renter occupied!!$20,000 to $24,999
    'HHIncTenRent_35' = 'B25118_020', # Renter occupied!!$25,000 to $34,999
    'HHIncTenRent_50' = 'B25118_021', # Renter occupied!!$35,000 to $49,999
    'HHIncTenRent_75' = 'B25118_022', # Renter occupied!!$50,000 to $74,999
    'HHIncTenRent_100' = 'B25118_023', # Renter occupied!!$75,000 to $99,999
    'HHIncTenRent_150' = 'B25118_024', # Renter occupied!!$100,000 to $149,999
    'HHIncTenRent_151' = 'B25118_025' # Renter occupied!!$150,000 or more
    )

oak <- 
    get_acs(
        geography = "tract", 
        state = "ca", 
        county = "Alameda", 
        variables = hhinc, 
        geomotry = TRUE, 
        cache = TRUE
    ) %>%
    select(-moe) %>% 
    spread(variable, estimate) 

oak2 <- oak %>% 
    mutate(
        GEOID = factor(GEOID), 
        p_HHIncTenRent_10 = HHIncTenRent_10/HHIncTenRent, 
        p_HHIncTenRent_100 = HHIncTenRent_100/HHIncTenRent, 
        p_HHIncTenRent_15 = HHIncTenRent_15/HHIncTenRent, 
        p_HHIncTenRent_150 = HHIncTenRent_150/HHIncTenRent, 
        p_HHIncTenRent_151 = HHIncTenRent_151/HHIncTenRent, 
        p_HHIncTenRent_20 = HHIncTenRent_20/HHIncTenRent, 
        p_HHIncTenRent_25 = HHIncTenRent_25/HHIncTenRent, 
        p_HHIncTenRent_35 = HHIncTenRent_35/HHIncTenRent, 
        p_HHIncTenRent_5 = HHIncTenRent_5/HHIncTenRent, 
        p_HHIncTenRent_50 = HHIncTenRent_50/HHIncTenRent, 
        p_HHIncTenRent_75 = HHIncTenRent_75/HHIncTenRent
    ) %>%
    select(GEOID, starts_with("p_"))

glimpse(oak2)

# ==========================================================================
# lcmm model for just the variables
# ==========================================================================

s3 <- multlcmm(
    p_HHIncTenRent_10 + p_HHIncTenRent_100 + p_HHIncTenRent_15 + p_HHIncTenRent_150 + p_HHIncTenRent_151 + p_HHIncTenRent_20 + p_HHIncTenRent_25 + p_HHIncTenRent_35 + p_HHIncTenRent_5 + p_HHIncTenRent_50 + p_HHIncTenRent_75~1,random=~1,subject="GEOID",link="linear",ng=3,mixture=~1,data=oak2)
s4 <- multlcmm(dis+pbl+pot~1+year,random=~1+year,subject="GEO2010",link="linear",ng=4,mixture=~1+year,data=l.dt)
s5 <- multlcmm(dis+pbl+pot~1+year,random=~1+year,subject="GEO2010",link="linear",ng=5,mixture=~1+year,data=l.dt)
