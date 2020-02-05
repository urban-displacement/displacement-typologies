# ==========================================================================
# SPARCC Analysis
# ==========================================================================

if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, tidycensus, stringr, RColorBrewer, gridExtra)
options(java.parameters = "-Xmx8g") # set the ram to 8gb
library(bartMachine)
set_bart_machine_num_cores(8)
set.seed(100)

# ==========================================================================
# Installation assistance: 2020.02.04
# by: Tim Thomas
    #  In the case that rJava won't install or bartMachine won't work in macOS 
    #   10.15 Catalina
    #       1. go to https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase11-5116896.html and download and install 11.0.1
    #       2. in terminal do `nano ~/.zshrc`
    #       3. add `export JAVA_HOME=`/usr/libexec/java_home -v 11.0.1`
    #       4. then `source ~/.zshrc` this changes the java_home path
    #       5. Go into R and library(bartMachine)
# ==========================================================================

# ==========================================================================
# Pull in data
# ==========================================================================

data <- 
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
# EDA
# Data dictionary: https://docs.google.com/spreadsheets/d/1A_Tk0EjN-ORTGmt41Fzykbh-4JRB38jwWwtn-pMO8C4/edit#gid=664440995
# ==========================================================================

#
# Gentrification 
# --------------------------------------------------------------------------

data %>% 
    group_by(city) %>% 
    summarise(
        count = n(), 
        p_gent_17 = sum(gent_00_17)/count, 
        p_gent_00 = sum(gent_90_00)/count, 
        dif = p_gent_17 - p_gent_00
    ) %>% 
    ggplot(.) +
    geom_point(aes(x = reorder(city, p_gent_17), y = p_gent_17), pch = 21, color = 'grey10', alpha = 1, size = 5) +
    geom_point(aes(x = city, y = p_gent_00), pch = 21, color = 'grey70', alpha = 1, size = 5) +
    theme_minimal() +
    ylab('proportion of tracts that gentrified\n1990 to 2000 & 2000 to 2017') +
    xlab('') +
    coord_flip()

    ####
    # Note: 
    # Chicago had the smalles increase in gentrified tracts, followed by Atlanta. 
    # Atlanta has the smallest proportion of gentrified neighborhoods
    #   * could this be consolidated concentration in the Atlanta area?  
    # Denver and Memphis had the biggest gains (13% and 12%) while 
    #   Atlanta and Chicago had the smallest gains (5% and 6%)
    ####

#
# LI
# --------------------------------------------------------------------------

data %>%
    ggplot(., aes(x = city, y = ch_all_li_count_00_17*-1)) +
    geom_jitter(alpha = .3) +
    geom_violin(draw_quantiles = c(0.5), alpha = .6) +
    theme_minimal() +
    ylab('Tract LI absolute losses (-) and gains (+)\n2000 to 2017') +
    xlab('') + 
    geom_hline(yintercept = 0, color = "red", linetype = "dotted") +
    coord_flip()

    ### 
    # Atlanta had the most tracts with the highest absolute losses as 
    # well as the biggest variation. 
    ###

# ==========================================================================
# Model setup 
# ==========================================================================
eda1 <- 
    data %>% 
    filter(!is.na(gent_00_17)) 

mod_y = eda1$gent_00_17
mod_x = 
    eda1 %>% 
    select(

        # left off
        real_hinc_00,
        hinc_00,
        per_nhblk_00,
        per_hisp_00,
        per_asian_00,
        per_rent_00,
        per_units_pre_50_00,
        per_built_00_17,
        i.lihtc_fl_00,
        i.downtown,
        i.rail_00,
        vac_00,
        i.ph_fl,
        i.hosp_fl,
        i.uni_fl,
        per_carcommute_00
)    

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
