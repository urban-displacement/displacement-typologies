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

### CHANGE AS NEEDED ###
states <- c("CA")
counties <- c("Santa Cruz", "Monterey", "San Luis Obispo", "Santa Barbara", "Ventura")

# ==========================================================================
# Download yearly data
# ==========================================================================

#
# 1990 Decenial Census Variables
# --------------------------------------------------------------------------

# LTDB data source - https://s4.ad.brown.edu/projects/diversity/Researcher/LTBDDload/DataList.aspx

ltdb_90 <- 
	left_join(
		readRDS('~/git/displacement-typologies/data/inputs/LTDB_Std_1990_fullcount.rds') %>% glimpse()
		select(
			FIPS = tractid, 
			POP90,
			white90 = nhwht90,
			MRENT90,
			ohu90,
			rent90, 
			own90, 
			MHMVAL90), 
		readRDS('~/git/displacement-typologies/data/inputs/ltdb_std_1990_sample.rds') %>% 
		select(
			state:tract, 
			FIPS = tractid,
			hh90,
			AG25UP90,
			COL90,
			HINC90
		)
	)


# Income breakdowns are missing from the LTDB so we turn to the 
# NHGIS to supplement  - https://www.nhgis.org
nhgis_90 <- 
	readRDS('~/git/displacement-typologies/data/inputs/nhgis_hhincome_1990.rds') %>% 
	mutate(
		FIPS = paste0(STATEA, COUNTYA, TRACTA)
		# FIPS = str_sub(GISJOIN, 2, 12), 
		# state = as.numeric(str_sub(FIPS, 1, 2)), 
		# county = as.numeric(COUNTYA), 
		# tract = as.numeric(TRACTA)
	) %>% 
	select(
	FIPS, 
	'I_5000_90' = 'E4T001', # Less than $5,000
	'I_10000_90' = 'E4T002', # $5,000 to $9,999
	'I_12500_90' = 'E4T003', # $10,000 to $12,499
	'I_15000_90' = 'E4T004', # $12,500 to $14,999
	'I_17500_90' = 'E4T005', # $15,000 to $17,499
	'I_20000_90' = 'E4T006', # $17,500 to $19,999
	'I_22500_90' = 'E4T007', # $20,000 to $22,499
	'I_25000_90' = 'E4T008', # $22,500 to $24,999
	'I_27500_90' = 'E4T009', # $25,000 to $27,499
	'I_30000_90' = 'E4T010', # $27,500 to $29,999
	'I_32500_90' = 'E4T011', # $30,000 to $32,499
	'I_35000_90' = 'E4T012', # $32,500 to $34,999
	'I_37500_90' = 'E4T013', # $35,000 to $37,499
	'I_40000_90' = 'E4T014', # $37,500 to $39,999
	'I_42500_90' = 'E4T015', # $40,000 to $42,499
	'I_45000_90' = 'E4T016', # $42,500 to $44,999
	'I_47500_90' = 'E4T017', # $45,000 to $47,499
	'I_50000_90' = 'E4T018', # $47,500 to $49,999
	'I_55000_90' = 'E4T019', # $50,000 to $54,999
	'I_60000_90' = 'E4T020', # $55,000 to $59,999
	'I_75000_90' = 'E4T021', # $60,000 to $74,999
	'I_100000_90' = 'E4T022', # $75,000 to $99,999
	'I_125000_90' = 'E4T023', # $100,000 to $124,999
	'I_150000_90' = 'E4T024', # $125,000 to $149,999
	'I_150001_90' = 'E4T025' # $150,000 or more
)

# Merge data
census_90 <- left_join(nhgis_90, ltdb_90, by = 'FIPS')

# 	'state' = 'Geo_STATE',
# 	'county' = 'Geo_COUNTY',
# 	'tract' = 'Geo_TRACT',
# 	'FIPS' = 'Geo_FIPS'
# )

#
# 2000 Census Variables
# --------------------------------------------------------------------------

# SF1 variables
dec_vars_00_sf1 <- c(
	'pop_00' = 'P004001',
	'white_00' = 'P004005',
	'hu_00' = 'H004001',
	'ohu_00' = 'H004002',
	'rhu_00' = 'H004003'#,
	# 'state' = 'Geo_STATE',
	# 'county' = 'Geo_COUNTY',
	# 'tract' = 'Geo_TRACT',
	# 'FIPS' = 'Geo_FIPS'
)

# SF3 variables
dec_vars_00_sf3 <- c(
	'total_25_00' = 'P037001',
	'male_25_col_bd_00' = 'P037015',
	'male_25_col_md_00' = 'P037016',
	'male_25_col_psd_00' = 'P037017',
	'male_25_col_phd_00' = 'P037018',
	'female_25_col_bd_00' = 'P037032',
	'female_25_col_md_00' = 'P037033',
	'female_25_col_psd_00' = 'P037034',
	'female_25_col_phd_00' = 'P037035',
	'mhval_00' = 'H085001',
	'mrent_00' = 'H063001',
	'hh_00' = 'P052001',
	'hinc_00' = 'P053001',
	'I_10000_00' = 'P052002',
	'I_15000_00' = 'P052003',
	'I_20000_00' = 'P052004',
	'I_25000_00' = 'P052005',
	'I_30000_00' = 'P052006',
	'I_35000_00' = 'P052007',
	'I_40000_00' = 'P052008',
	'I_45000_00' = 'P052009',
	'I_50000_00' = 'P052010',
	'I_60000_00' = 'P052011',
	'I_75000_00' = 'P052012',
	'I_100000_00' = 'P052013',
	'I_125000_00' = 'P052014',
	'I_150000_00' = 'P052015',
	'I_200000_00' = 'P052016',
	'I_201000_00' = 'P052017' # ,
	 # 'state' = 'Geo_STATE',
	 # 'county' = 'Geo_COUNTY',
	 # 'tract' = 'Geo_TRACT',
	 # 'FIPS' = 'Geo_FIPS'
)

# download SF1
census_00_sf1 <- 
	get_decennial(
		geography = 'tract', 
		state = states, 
		variables = dec_vars_00_sf1, 
		year = 2000, 
		geometry = FALSE, 
		output = 'wide'
	)

# download sf3
census_00_sf3 <- 
	get_decennial(
		geography = 'tract', 
		state = states, 
		variables = dec_vars_00_sf3, 
		year = 2000, 
		geometry = FALSE, 
		output = 'wide'
	)

# Merge SF1 and SF3 variables
census_00 <- 
	left_join(census_00_sf1, census_00_sf3) 

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
		output = 'wide'
	) %>% 
	select(-starts_with('B')) %>% 
	left_join(census_12)

# ==========================================================================
# Save variables
# ==========================================================================

saveRDS(census, paste0('~/git/displacement-typologies/data/outputs/downloads/census_', states, '.rds'))
saveRDS(census_00, paste0('~/git/displacement-typologies/data/outputs/downloads/census_00_', states, '.rds'))
saveRDS(census_90, paste0('~/git/displacement-typologies/data/outputs/downloads/census_90_', states, '.rds'))