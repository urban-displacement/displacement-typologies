# ==========================================================================
# Data Download
# Goal: pull census data and prepare for curation
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
# Lists
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

# ==========================================================================
# Download yearly data
# ==========================================================================

#
# 1990 Decenial Census Variables
# --------------------------------------------------------------------------

census_90 <-
	read_csv('~/git/displacement-typologies/data/inputs/US_90_sf3.csv') %>% 
	select(
		pop_90 = STF3_P001_001,
		white_90 = STF3_P012_001,
		hh_90 = STF3_P005_001,
		total_25_col_9th_90 = STF3_P057_001,
		total_25_col_12th_90 = STF3_P057_002,
		total_25_col_hs_90 = STF3_P057_003,
		total_25_col_sc_90 = STF3_P057_004,
		total_25_col_ad_90 = STF3_P057_005,
		total_25_col_bd_90 = STF3_P057_006,
		total_25_col_gd_90 = STF3_P057_007,
		mhval_90 = STF3_H061A_001,
		mrent_90 = STF3_H043A_001,
		hinc_90 = STF3_P080A_001,
		ohu_90 = STF3_H008_001,
		rhu_90 = STF3_H008_002,
		I_5000_90 = STF3_P080_001,
		I_10000_90 = STF3_P080_002,
		I_12500_90 = STF3_P080_003,
		I_15000_90 = STF3_P080_004,
		I_17500_90 = STF3_P080_005,
		I_20000_90 = STF3_P080_006,
		I_22500_90 = STF3_P080_007,
		I_25000_90 = STF3_P080_008,
		I_27500_90 = STF3_P080_009,
		I_30000_90 = STF3_P080_010,
		I_32500_90 = STF3_P080_011,
		I_35000_90 = STF3_P080_012,
		I_37500_90 = STF3_P080_013,
		I_40000_90 = STF3_P080_014,
		I_42500_90 = STF3_P080_015,
		I_45000_90 = STF3_P080_016,
		I_47500_90 = STF3_P080_017,
		I_50000_90 = STF3_P080_018,
		I_55000_90 = STF3_P080_019,
		I_60000_90 = STF3_P080_020,
		I_75000_90 = STF3_P080_021,
		I_100000_90 = STF3_P080_022,
		I_125000_90 = STF3_P080_023,
		I_150000_90 = STF3_P080_024,
		I_150001_90 = STF3_P080_025,
		state = Geo_STATE,
		county = Geo_COUNTY,
		tract = Geo_TRACT,
		FIPS = Geo_FIPS
	) %>% 
	filter(state == state_fips)

#
# 2000 Census Variables
# --------------------------------------------------------------------------

census_00 <- 
	read_csv('~/git/displacement-typologies/data/inputs/US_00_sf1_sf3.csv') %>% 
	select(
		pop_00 = SF1_P004001,
		white_00 = SF1_P004005,
		hu_00 = SF1_H004001,
		ohu_00 = SF1_H004002,
		rhu_00 = SF1_H004003,
		total_25_00 = SF3_P037001,
		male_25_col_bd_00 = SF3_P037015,
		male_25_col_md_00 = SF3_P037016,
		male_25_col_psd_00 = SF3_P037017,
		male_25_col_phd_00 = SF3_P037018,
		female_25_col_bd_00 = SF3_P037032,
		female_25_col_md_00 = SF3_P037033,
		female_25_col_psd_00 = SF3_P037034,
		female_25_col_phd_00 = SF3_P037035,
		mhval_00 = SF3_H085001,
		mrent_00 = SF3_H063001,
		hh_00 = SF3_P052001,
		hinc_00 = SF3_P053001,
		I_10000_00 = SF3_P052002,
		I_15000_00 = SF3_P052003,
		I_20000_00 = SF3_P052004,
		I_25000_00 = SF3_P052005,
		I_30000_00 = SF3_P052006,
		I_35000_00 = SF3_P052007,
		I_40000_00 = SF3_P052008,
		I_45000_00 = SF3_P052009,
		I_50000_00 = SF3_P052010,
		I_60000_00 = SF3_P052011,
		I_75000_00 = SF3_P052012,
		I_100000_00 = SF3_P052013,
		I_125000_00 = SF3_P052014,
		I_150000_00 = SF3_P052015,
		I_200000_00 = SF3_P052016,
		I_201000_00 = SF3_P052017,
		state = Geo_STATE,
		county = Geo_COUNTY,
		tract = Geo_TRACT,
		FIPS = Geo_FIPS
	) %>% 
	filter(state == state_fips)

#
# < 2012 acs variables
# --------------------------------------------------------------------------

acs_vars_12 <- c(
	'mhval_12' = 'B25077_001E',
	'mhval_12_se' = 'B25077_001M',
	'mrent_12' = 'B25064_001E',
	'mrent_12_se' = 'B25064_001M',
	'mov_wc_w_income_12' = 'B07010_025E',
	'mov_wc_9000_12' = 'B07010_026E',
	'mov_wc_15000_12' = 'B07010_027E',
	'mov_wc_25000_12' = 'B07010_028E',
	'mov_wc_35000_12' = 'B07010_029E',
	'mov_wc_50000_12' = 'B07010_030E',
	'mov_wc_65000_12' = 'B07010_031E',
	'mov_wc_75000_12' = 'B07010_032E',
	'mov_wc_76000_more_12' = 'B07010_033E',
	'mov_oc_w_income_12' = 'B07010_036E',
	'mov_oc_9000_12' = 'B07010_037E',
	'mov_oc_15000_12' = 'B07010_038E',
	'mov_oc_25000_12' = 'B07010_039E',
	'mov_oc_35000_12' = 'B07010_040E',
	'mov_oc_50000_12' = 'B07010_041E',
	'mov_oc_65000_12' = 'B07010_042E',
	'mov_oc_75000_12' = 'B07010_043E',
	'mov_oc_76000_more_12' = 'B07010_044E',
	'mov_os_w_income_12' = 'B07010_047E',
	'mov_os_9000_12' = 'B07010_048E',
	'mov_os_15000_12' = 'B07010_049E',
	'mov_os_25000_12' = 'B07010_050E',
	'mov_os_35000_12' = 'B07010_051E',
	'mov_os_50000_12' = 'B07010_052E',
	'mov_os_65000_12' = 'B07010_053E',
	'mov_os_75000_12' = 'B07010_054E',
	'mov_os_76000_more_12' = 'B07010_055E',
	'mov_fa_w_income_12' = 'B07010_058E',
	'mov_fa_9000_12' = 'B07010_059E',
	'mov_fa_15000_12' = 'B07010_060E',
	'mov_fa_25000_12' = 'B07010_061E',
	'mov_fa_35000_12' = 'B07010_062E',
	'mov_fa_50000_12' = 'B07010_063E',
	'mov_fa_65000_12' = 'B07010_064E',
	'mov_fa_75000_12' = 'B07010_065E',
	'mov_fa_76000_more_12' = 'B07010_066E',
	'iinc_12' = 'B06011_001E'
)

# Download 2012 ACS variables
census_12 <- 
	get_acs(
		geography = 'tract', 
		state = states, 
		variables = acs_vars_12, 
		year = 2012, 
		output = 'wide'
	) %>% 
	select(-starts_with('B'))

#
# Recent year ACS variables
# --------------------------------------------------------------------------

acs_vars <-
	c(
		'pop' = 'B03002_001E',
		'white' = 'B03002_003E',
		'hh' = 'B19001_001E',
		'hinc' = 'B19013_001E',
		'mhval' = 'B25077_001E',
		'mhval_se' = 'B25077_001M',
		'mrent' = 'B25064_001E',
		'mrent_se' = 'B25064_001M',
		'ohu' = 'B25003_002E',
		'rhu' = 'B25003_003E',
		'mmhcosts' = 'B25105_001E',
		'total_25' = 'B15003_001E',
		'total_25_col_bd' = 'B15003_022E',
		'total_25_col_md' = 'B15003_023E',
		'total_25_col_pd' = 'B15003_024E',
		'total_25_col_phd' = 'B15003_025E',
		'tot_units_built' = 'B25034_001E',
		'units_40_49_built' = 'B25034_010E',
		'units_39_early_built' = 'B25034_011E',
		'mov_wc_w_income' = 'B07010_025E',
		'mov_wc_9000' = 'B07010_026E',
		'mov_wc_15000' = 'B07010_027E',
		'mov_wc_25000' = 'B07010_028E',
		'mov_wc_35000' = 'B07010_029E',
		'mov_wc_50000' = 'B07010_030E',
		'mov_wc_65000' = 'B07010_031E',
		'mov_wc_75000' = 'B07010_032E',
		'mov_wc_76000_more' = 'B07010_033E',
		'mov_oc_w_income' = 'B07010_036E',
		'mov_oc_9000' = 'B07010_037E',
		'mov_oc_15000' = 'B07010_038E',
		'mov_oc_25000' = 'B07010_039E',
		'mov_oc_35000' = 'B07010_040E',
		'mov_oc_50000' = 'B07010_041E',
		'mov_oc_65000' = 'B07010_042E',
		'mov_oc_75000' = 'B07010_043E',
		'mov_oc_76000_more' = 'B07010_044E',
		'mov_os_w_income' = 'B07010_047E',
		'mov_os_9000' = 'B07010_048E',
		'mov_os_15000' = 'B07010_049E',
		'mov_os_25000' = 'B07010_050E',
		'mov_os_35000' = 'B07010_051E',
		'mov_os_50000' = 'B07010_052E',
		'mov_os_65000' = 'B07010_053E',
		'mov_os_75000' = 'B07010_054E',
		'mov_os_76000_more' = 'B07010_055E',
		'mov_fa_w_income' = 'B07010_058E',
		'mov_fa_9000' = 'B07010_059E',
		'mov_fa_15000' = 'B07010_060E',
		'mov_fa_25000' = 'B07010_061E',
		'mov_fa_35000' = 'B07010_062E',
		'mov_fa_50000' = 'B07010_063E',
		'mov_fa_65000' = 'B07010_064E',
		'mov_fa_75000' = 'B07010_065E',
		'mov_fa_76000_more' = 'B07010_066E',
		'iinc' = 'B06011_001E',
		'I_10000' = 'B19001_002E',
		'I_15000' = 'B19001_003E',
		'I_20000' = 'B19001_004E',
		'I_25000' = 'B19001_005E',
		'I_30000' = 'B19001_006E',
		'I_35000' = 'B19001_007E',
		'I_40000' = 'B19001_008E',
		'I_45000' = 'B19001_009E',
		'I_50000' = 'B19001_010E',
		'I_60000' = 'B19001_011E',
		'I_75000' = 'B19001_012E',
		'I_100000' = 'B19001_013E',
		'I_125000' = 'B19001_014E',
		'I_150000' = 'B19001_015E',
		'I_200000' = 'B19001_016E',
		'I_201000' = 'B19001_017E'	
	)

# Download recent years ACS
# Note: this line of code was developed for the most recent year of data. 
# To change the year, add
census <- 
	get_acs(
		geography = 'tract', 
		state = states, 
		variables = acs_vars, 
		output = 'wide', 
		# year = NULL # uncomment and change if you need another year
	) %>% 
	select(-starts_with('B')) %>% 
	left_join(census_12)

# ==========================================================================
# Save variables
# ==========================================================================

saveRDS(census, paste0('~/git/displacement-typologies/data/outputs/downloads/census_', states[1], '.rds'))
saveRDS(census_00, paste0('~/git/displacement-typologies/data/outputs/downloads/census_00_', states[1], '.rds'))
saveRDS(census_90, paste0('~/git/displacement-typologies/data/outputs/downloads/census_90_', states[1], '.rds'))