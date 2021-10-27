# ==========================================================================
# Data Download
# ==========================================================================

# ==========================================================================
# Libraries
# ==========================================================================

if (!require("pacman")) install.packages("pacman")
if (!require("tidyverse")) install.packages("tidyverse")
pacman::p_install_gh("timathomas/neighborhood", "jalvesaq/colorout")
pacman::p_load(tidycensus, tidyverse)

options(tigris_use_cache = TRUE)
census_api_key('4c26aa6ebbaef54a55d3903212eabbb506ade381') #enter your own key 

# ==========================================================================
# Lists
# ==========================================================================

#
# Area location
# --------------------------------------------------------------------------
states <- c("CA")
counties <- c("Santa Cruz", "Monterey", "San Luis Obispo", "Santa Barbara", "Ventura")

#
# ACS variables
# --------------------------------------------------------------------------

acs_vars <-
	c(
	'totrace' = 'B03002_001',
	'White' = 'B03002_003',
	'HHInc_Total' = 'B19001_001', # Total HOUSEHOLD INCOME
	'medhhinc' = 'B19013_001',
	'B25077_001E',
	'B25077_001M',
	'B25064_001E',
	'B25064_001M',
	'B15003_001E',
	'B15003_022E',
	'B15003_023E',
	'B15003_024E',
	'B15003_025E',
	'B25034_001E',
	'B25034_010E',
	'B25034_011E',
	'B25003_002E',
	'B25003_003E',
	'B25105_001E',
	'B06011_001E'
	)



	