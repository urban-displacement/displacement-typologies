# ==========================================================================
# Data Curation
# Goal: Clean data and prepare for lag variables and typology
# Author: Tim Thomas - timthomas@berkeley
# Created: 2021.11.01
# ==========================================================================
# ==========================================================================
# Libraries
# ==========================================================================
source('~/git/displacement-typologies/code/dev/functions.r')
ipak_gh(c("timathomas/neighborhood", "jalvesaq/colorout"))
ipak(c('tidycensus', 'tidyverse'))

options(tigris_use_cache = TRUE)
census_api_key('4c26aa6ebbaef54a55d3903212eabbb506ade381') #enter your own key 

# ==========================================================================
# Pull in data
# ==========================================================================

#
# Study Area Definition
# --------------------------------------------------------------------------

### CHANGE AS NEEDED -- use abbreviated state name ###

####
# NOTE: If you are working with cities that are within a 100 miles
# of another state, go a ahead and add bordering states to your `states` 
# funtion below. Example: Memphis is on the Tennessee and Arkansas border, 
# in which case you would use `states <- c('TN', 'AR')`
####

states <- c("CA")

# get state fips codes
data(fips_codes)
state_fips <- fips_codes %>% filter(state %in% states) %>% pull(state_code) %>% unique()

#
# Data
# --------------------------------------------------------------------------

census <- readRDS(paste0('~/git/displacement-typologies/data/outputs/downloads/census_', states[1], '.rds'))
census_00 <- readRDS(paste0('~/git/displacement-typologies/data/outputs/downloads/census_00_', states[1], '.rds'))
census_90 <- readRDS(paste0('~/git/displacement-typologies/data/outputs/downloads/census_90_', states[1], '.rds'))


xwalk_00_10 <- read_csv('~/git/displacement-typologies/data/inputs/crosswalk_2000_2010.csv')
xwalk_90_10 <- read_csv('~/git/displacement-typologies/data/inputs/crosswalk_1990_2010.csv')

# ==========================================================================
# Croswalk data
# ==========================================================================

census_00_x <- 
	left_join(census_00, xwalk_00_10, by = c('FIPS' = 'trtid00')) %>% 
	mutate_at(vars(pop_00:I_201000_00), list(~ .*weight)) %>% 
	group_by(trtid10) %>% 
	summarize_at(vars(pop_00:I_201000_00), list(sum)) %>% 
	rename(GEOID = trtid10)

census_90_x <- 
	left_join(census_90, xwalk_90_10, by = c('FIPS' = 'trtid90')) %>% 
	mutate_at(vars(pop_90:I_150001_90), list(~ .*weight)) %>% 
	group_by(trtid10) %>% 
	summarize_at(vars(pop_90:I_150001_90), list(sum)) %>% 
	rename(GEOID = trtid10)

# ==========================================================================
# PUMS data
# ==========================================================================

pums <- 
	left_join(
		read_csv('~/git/displacement-typologies/data/inputs/nhgis0002_ds233_20175_2017_tract.csv'), 
		read_csv('~/git/displacement-typologies/data/inputs/nhgis0002_ds234_20175_2017_tract.csv'), 
		by = 'GISJOIN'
	) %>% 
	rename(
		YEAR = YEAR_x,
		STATE = STATE_x,
		STATEA = STATEA_x,
		COUNTY = COUNTY_x,
		COUNTYA = COUNTYA_x,
		TRACTA = TRACTA_x,
		NAME_E = NAME_E_x
	)


# ==========================================================================
# Save variables
# ==========================================================================

saveRDS(census, paste0('~/git/displacement-typologies/data/outputs/downloads/census_', states, '.rds'))
saveRDS(census_00, paste0('~/git/displacement-typologies/data/outputs/downloads/census_00_', states, '.rds'))
saveRDS(census_90, paste0('~/git/displacement-typologies/data/outputs/downloads/census_90_', states, '.rds'))