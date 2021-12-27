# ==========================================================================
# ==========================================================================
# ==========================================================================
# Data Download
# Note: As of 2020, the Census API has been somewhat unreliable. We encourage
# everyone to save all their downloads so you don't run into delays while
# working on your project. Don't rely on the API to download everyday.
# ==========================================================================
# ==========================================================================
# ==========================================================================

#!/usr/bin/env python
# coding: utf-8

# ==========================================================================
# Import Libraries
# ==========================================================================

#pip install census==0.8.15 ## Last census version with SF3

import census
import pandas as pd
import numpy as np
import sys
from pathlib import Path
import geopandas as gpd
from shapely.geometry import Point
from pyproj import Proj
import matplotlib.pyplot as plt

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.options.display.float_format = '{:.2f}'.format # avoid scientific notation

home = str(Path.home())
input_path = home+'/git/displacement-typologies/data/inputs/'
output_path = home+'/git/displacement-typologies/data/outputs/'

# ==========================================================================
# Set API Key
# ==========================================================================

key = '4c26aa6ebbaef54a55d3903212eabbb506ade381' #insert your API key here!
c = census.Census(key)

# ==========================================================================
# Choose Cities
# ==========================================================================

# Choose City and Census Tracts of Interest
# --------------------------------------------------------------------------
# To get city data, run the following code in the terminal
# `python data.py <city name>`
# Example: python data.py Atlanta

city_name = str(sys.argv[1])
# city_name = 'Atlanta'
#If reproducing for another city, add elif for
#that city & desired counties after last line

if city_name == 'Chicago':
    state = '17'
    FIPS = ['031', '043', '089', '093', '097', '111', '197']
elif city_name == 'Atlanta':
    state = '13'
    FIPS = ['057', '063', '067', '089', '097', '113', '121', '135', '151', '247']
elif city_name == 'Denver':
    state = '08'
    FIPS = ['001', '005', '013', '014', '019', '031', '035', '047', '059']
elif city_name == 'Memphis':
    state = ['28', '47']
    FIPS = {'28':['033', '093'], '47': ['047', '157']}
elif city_name == 'Los Angeles':
    state = '06'
    FIPS = ['037', '059', '073']
elif city_name == 'San Francisco':
    state = '06'
    FIPS = ['001', '013', '041', '055', '067', '075', '077', '081', '085', '087', '095', '097', '113']
elif city_name == 'Seattle':
    state = '53'
    FIPS = ['033', '053', '061']
elif city_name == 'Cleveland':
    state = '39'
    FIPS = ['035', '055', '085', '093', '103']
elif city_name == 'Boston':
    state = ['25', '33']
    FIPS = {'25': ['009', '017', '021', '023', '025'], '33': ['015', '017']}
else:
    print ('There is not information for the selected city')

if (city_name not in ('Memphis', 'Boston')):
    sql_query='state:{} county:*'.format(state)
else:
    sql_query_1='state:{} county:*'.format(state[0])
    sql_query_2='state:{} county:*'.format(state[1])

# Create Filter Function
# --------------------------------------------------------------------------
# Note - Memphis and Boston is different
# because they're located in 2 states

def filter_FIPS(df):
    if (city_name not in ('Memphis', 'Boston')):
        df = df[df['county'].isin(FIPS)]
    else:
        fips_list = []
        for i in state:
            county = FIPS[i]
            a = list((df['FIPS'][(df['county'].isin(county))&(df['state']==i)]))
            fips_list = fips_list + a
        df = df[df['FIPS'].isin(fips_list)]
    return df

# ==========================================================================
# Download Raw Data
# ==========================================================================

# Download ACS 2019 5-Year Estimates
# --------------------------------------------------------------------------

df_vars_19=['B03002_001E',
            'B03002_003E',
            'B19001_001E',
            'B19013_001E',
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
            'B06011_001E']

# Income categories - see notes
var_str = 'B19001'
var_list = []
for i in range (1, 18):
    var_list.append(var_str+'_'+str(i).zfill(3)+'E')
df_vars_19 = df_vars_19 + var_list

# Migration - see notes
var_str = 'B07010'
var_list = []
for i in list(range(25,34))+list(range(36, 45))+list(range(47, 56))+list(range(58, 67)):
    var_list.append(var_str+'_'+str(i).zfill(3)+'E')
df_vars_19 = df_vars_19 + var_list


# Run API query
# --------------------------------------------------------------------------
# NOTE: Memphis is located in two states so the query looks different
# same for Boston

if (city_name not in ('Memphis', 'Boston')):
    var_dict_acs5 = c.acs5.get(df_vars_19, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2019)
else:
    var_dict_1 = c.acs5.get(df_vars_19, geo = {'for': 'tract:*',
                                 'in': sql_query_1} , year=2019)
    var_dict_2 = (c.acs5.get(df_vars_19, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2019))
    var_dict_acs5 = var_dict_1+var_dict_2

# Convert and Rename Variables
# --------------------------------------------------------------------------

### Converts variables into dataframe and filters only FIPS of interest

df_vars_19 = pd.DataFrame.from_dict(var_dict_acs5)
df_vars_19['FIPS']=df_vars_19['state']+df_vars_19['county']+df_vars_19['tract']
df_vars_19 = filter_FIPS(df_vars_19)

### Renames variables

df_vars_19 = df_vars_19.rename(columns = {'B03002_001E':'pop_19',
                                          'B03002_003E':'white_19',
                                          'B19001_001E':'hh_19',
                                          'B19013_001E':'hinc_19',
                                          'B25077_001E':'mhval_19',
                                          'B25077_001M':'mhval_19_se',
                                          'B25064_001E':'mrent_19',
                                          'B25064_001M':'mrent_19_se',
                                          'B25003_002E':'ohu_19',
                                          'B25003_003E':'rhu_19',
                                          'B25105_001E':'mmhcosts_19',
                                          'B15003_001E':'total_25_19',
                                          'B15003_022E':'total_25_col_bd_19',
                                          'B15003_023E':'total_25_col_md_19',
                                          'B15003_024E':'total_25_col_pd_19',
                                          'B15003_025E':'total_25_col_phd_19',
                                          'B25034_001E':'tot_units_built_19',
                                          'B25034_010E':'units_40_49_built_19',
                                          'B25034_011E':'units_39_early_built_19',
                                          'B07010_025E':'mov_wc_w_income_19',
                                          'B07010_026E':'mov_wc_9000_19',
                                          'B07010_027E':'mov_wc_15000_19',
                                          'B07010_028E':'mov_wc_25000_19',
                                          'B07010_029E':'mov_wc_35000_19',
                                          'B07010_030E':'mov_wc_50000_19',
                                          'B07010_031E':'mov_wc_65000_19',
                                          'B07010_032E':'mov_wc_75000_19',
                                          'B07010_033E':'mov_wc_76000_more_19',
                                          'B07010_036E':'mov_oc_w_income_19',
                                          'B07010_037E':'mov_oc_9000_19',
                                          'B07010_038E':'mov_oc_15000_19',
                                          'B07010_039E':'mov_oc_25000_19',
                                          'B07010_040E':'mov_oc_35000_19',
                                          'B07010_041E':'mov_oc_50000_19',
                                          'B07010_042E':'mov_oc_65000_19',
                                          'B07010_043E':'mov_oc_75000_19',
                                          'B07010_044E':'mov_oc_76000_more_19',
                                          'B07010_047E':'mov_os_w_income_19',
                                          'B07010_048E':'mov_os_9000_19',
                                          'B07010_049E':'mov_os_15000_19',
                                          'B07010_050E':'mov_os_25000_19',
                                          'B07010_051E':'mov_os_35000_19',
                                          'B07010_052E':'mov_os_50000_19',
                                          'B07010_053E':'mov_os_65000_19',
                                          'B07010_054E':'mov_os_75000_19',
                                          'B07010_055E':'mov_os_76000_more_19',
                                          'B07010_058E':'mov_fa_w_income_19',
                                          'B07010_059E':'mov_fa_9000_19',
                                          'B07010_060E':'mov_fa_15000_19',
                                          'B07010_061E':'mov_fa_25000_19',
                                          'B07010_062E':'mov_fa_35000_19',
                                          'B07010_063E':'mov_fa_50000_19',
                                          'B07010_064E':'mov_fa_65000_19',
                                          'B07010_065E':'mov_fa_75000_19',
                                          'B07010_066E':'mov_fa_76000_more_19',
                                          'B06011_001E':'iinc_19',
                                          'B19001_002E':'I_10000_19',
                                          'B19001_003E':'I_15000_19',
                                          'B19001_004E':'I_20000_19',
                                          'B19001_005E':'I_25000_19',
                                          'B19001_006E':'I_30000_19',
                                          'B19001_007E':'I_35000_19',
                                          'B19001_008E':'I_40000_19',
                                          'B19001_009E':'I_45000_19',
                                          'B19001_010E':'I_50000_19',
                                          'B19001_011E':'I_60000_19',
                                          'B19001_012E':'I_75000_19',
                                          'B19001_013E':'I_100000_19',
                                          'B19001_014E':'I_125000_19',
                                          'B19001_015E':'I_150000_19',
                                          'B19001_016E':'I_200000_19',
                                          'B19001_017E':'I_201000_19'})

# Download ACS 2012 5-Year Estimates
# --------------------------------------------------------------------------
# Note: If additional cities are added, make sure to change create_lag_vars.r
# accordingly.

### List variables of interest

df_vars_12=['B25077_001E',
            'B25077_001M',
            'B25064_001E',
            'B25064_001M',
            'B07010_025E',
            'B07010_026E',
            'B07010_027E',
            'B07010_028E',
            'B07010_029E',
            'B07010_030E',
            'B07010_031E',
            'B07010_032E',
            'B07010_033E',
            'B07010_036E',
            'B07010_037E',
            'B07010_038E',
            'B07010_039E',
            'B07010_040E',
            'B07010_041E',
            'B07010_042E',
            'B07010_043E',
            'B07010_044E',
            'B07010_047E',
            'B07010_048E',
            'B07010_049E',
            'B07010_050E',
            'B07010_051E',
            'B07010_052E',
            'B07010_053E',
            'B07010_054E',
            'B07010_055E',
            'B07010_058E',
            'B07010_059E',
            'B07010_060E',
            'B07010_061E',
            'B07010_062E',
            'B07010_063E',
            'B07010_064E',
            'B07010_065E',
            'B07010_066E',
            'B06011_001E']

# Run API query
# --------------------------------------------------------------------------
# NOTE: Memphis is located in two states so the query looks different

if (city_name not in ('Memphis', 'Boston')):
    var_dict_acs5 = c.acs5.get(df_vars_12, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2012)
else:
    var_dict_1 = c.acs5.get(df_vars_12, geo = {'for': 'tract:*',
                                 'in': sql_query_1} , year=2012)
    var_dict_2 = (c.acs5.get(df_vars_12, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2012))
    var_dict_acs5 = var_dict_1+var_dict_2

# Convert and Rename Variabls
# --------------------------------------------------------------------------

### Converts variables into dataframe and filters only FIPS of interest

df_vars_12 = pd.DataFrame.from_dict(var_dict_acs5)
df_vars_12['FIPS']=df_vars_12['state']+df_vars_12['county']+df_vars_12['tract']
df_vars_12 = filter_FIPS(df_vars_12)

### Renames variables

df_vars_12 = df_vars_12.rename(columns = {'B25077_001E':'mhval_12',
                                          'B25077_001M':'mhval_12_se',
                                          'B25064_001E':'mrent_12',
                                          'B25064_001M':'mrent_12_se',
                                          'B07010_025E':'mov_wc_w_income_12',
                                          'B07010_026E':'mov_wc_9000_12',
                                          'B07010_027E':'mov_wc_15000_12',
                                          'B07010_028E':'mov_wc_25000_12',
                                          'B07010_029E':'mov_wc_35000_12',
                                          'B07010_030E':'mov_wc_50000_12',
                                          'B07010_031E':'mov_wc_65000_12',
                                          'B07010_032E':'mov_wc_75000_12',
                                          'B07010_033E':'mov_wc_76000_more_12',
                                          'B07010_036E':'mov_oc_w_income_12',
                                          'B07010_037E':'mov_oc_9000_12',
                                          'B07010_038E':'mov_oc_15000_12',
                                          'B07010_039E':'mov_oc_25000_12',
                                          'B07010_040E':'mov_oc_35000_12',
                                          'B07010_041E':'mov_oc_50000_12',
                                          'B07010_042E':'mov_oc_65000_12',
                                          'B07010_043E':'mov_oc_75000_12',
                                          'B07010_044E':'mov_oc_76000_more_12',
                                          'B07010_047E':'mov_os_w_income_12',
                                          'B07010_048E':'mov_os_9000_12',
                                          'B07010_049E':'mov_os_15000_12',
                                          'B07010_050E':'mov_os_25000_12',
                                          'B07010_051E':'mov_os_35000_12',
                                          'B07010_052E':'mov_os_50000_12',
                                          'B07010_053E':'mov_os_65000_12',
                                          'B07010_054E':'mov_os_75000_12',
                                          'B07010_055E':'mov_os_76000_more_12',
                                          'B07010_058E':'mov_fa_w_income_12',
                                          'B07010_059E':'mov_fa_9000_12',
                                          'B07010_060E':'mov_fa_15000_12',
                                          'B07010_061E':'mov_fa_25000_12',
                                          'B07010_062E':'mov_fa_35000_12',
                                          'B07010_063E':'mov_fa_50000_12',
                                          'B07010_064E':'mov_fa_65000_12',
                                          'B07010_065E':'mov_fa_75000_12',
                                          'B07010_066E':'mov_fa_76000_more_12',
                                          'B06011_001E':'iinc_12'})

### Decennial Census 2000 Variables

var_sf1=['P004001',
         'P004005',
         'H004001',
         'H004002',
         'H004003']

var_sf3=['P037001',
         'P037015',
         'P037016',
         'P037017',
         'P037018',
         'P037032',
         'P037033',
         'P037034',
         'P037035',
         'H085001',
         'H063001',
         'P052001',
         'P053001']

var_str = 'P0'
var_list = []
for i in range (2, 18):
    var_list.append(var_str+str(52000+i))

var_sf3 = var_sf3 + var_list

# Run API query
# --------------------------------------------------------------------------
# NOTE: on certain days, Census API may argue about too many queries and this section
# may get hung up.

# SF1
if (city_name not in ('Memphis', 'Boston')):
    var_dict_sf1 = c.sf1.get(var_sf1, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2000)
else:
    var_dict_1 = c.sf1.get(var_sf1, geo = {'for': 'tract:*',
                                 'in': sql_query_1}, year=2000)
    var_dict_2 = (c.sf1.get(var_sf1, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2000))
    var_dict_sf1 = var_dict_1+var_dict_2

# SF3
if (city_name not in ('Memphis', 'Boston')):
    var_dict_sf3 = c.sf3.get(var_sf3, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2000)
else:
    var_dict_1 = c.sf3.get(var_sf3, geo = {'for': 'tract:*',
                                 'in': sql_query_1}, year=2000)
    var_dict_2 = (c.sf3.get(var_sf3, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2000))
    var_dict_sf3 = var_dict_1+var_dict_2

# Convert and Rename Variables
# --------------------------------------------------------------------------

### Converts variables into dataframe and filters only FIPS of interest

df_vars_sf1 = pd.DataFrame.from_dict(var_dict_sf1)
df_vars_sf3 = pd.DataFrame.from_dict(var_dict_sf3)
df_vars_sf1['FIPS']=df_vars_sf1['state']+df_vars_sf1['county']+df_vars_sf1['tract']
df_vars_sf3['FIPS']=df_vars_sf3['state']+df_vars_sf3['county']+df_vars_sf3['tract']
df_vars_sf1 = filter_FIPS(df_vars_sf1)
df_vars_sf3 = filter_FIPS(df_vars_sf3)

### Renames variables

df_vars_sf1 = df_vars_sf1.rename(columns = {'P004001':'pop_00',
                                            'P004005':'white_00',
                                            'H004001':'hu_00',
                                            'H004002':'ohu_00',
                                            'H004003':'rhu_00'})

df_vars_sf3 = df_vars_sf3.rename(columns = {'P037001':'total_25_00',
                                            'P037015':'male_25_col_bd_00',
                                            'P037016':'male_25_col_md_00',
                                            'P037017':'male_25_col_psd_00',
                                            'P037018':'male_25_col_phd_00',
                                            'P037032':'female_25_col_bd_00',
                                            'P037033':'female_25_col_md_00',
                                            'P037034':'female_25_col_psd_00',
                                            'P037035':'female_25_col_phd_00',
                                            'H085001':'mhval_00',
                                            'H063001':'mrent_00',
                                            'P052001':'hh_00',
                                            'P053001':'hinc_00',
                                            'P052002':'I_10000_00',
                                            'P052003':'I_15000_00',
                                            'P052004':'I_20000_00',
                                            'P052005':'I_25000_00',
                                            'P052006':'I_30000_00',
                                            'P052007':'I_35000_00',
                                            'P052008':'I_40000_00',
                                            'P052009':'I_45000_00',
                                            'P052010':'I_50000_00',
                                            'P052011':'I_60000_00',
                                            'P052012':'I_75000_00',
                                            'P052013':'I_100000_00',
                                            'P052014':'I_125000_00',
                                            'P052015':'I_150000_00',
                                            'P052016':'I_200000_00',
                                            'P052017':'I_201000_00'})

df_vars_00 = df_vars_sf1.merge(df_vars_sf3.drop(columns=['county', 'state', 'tract']), on = 'FIPS')

### Download Decennial Census 1990 Variables

var_sf3=['P0010001',
         'P0120001',
         'P0050001',
         'P0570001',
         'P0570002',
         'P0570003',
         'P0570004',
         'P0570005',
         'P0570006',
         'P0570007',
         'H061A001',
         'H043A001',
         'P080A001',
         'H0080001',
         'H0080002']

var_str = 'P0'
var_list = []
for i in range (1, 26):
    var_list.append(var_str+str(800000+i))

var_sf3 = var_sf3 + var_list

# Run API Query
# --------------------------------------------------------------------------
# NOTE: Memphis is located in two states so the query looks different

# SF1 - All of the variables are found in the SF3
# SF3
if (city_name not in ('Memphis', 'Boston')):
    var_dict_sf3 = c.sf3.get(var_sf3, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=1990)
else:
    var_dict_1 = c.sf3.get(var_sf3, geo = {'for': 'tract:*',
                                 'in': sql_query_1} , year=1990)
    var_dict_2 = (c.sf3.get(var_sf3, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=1990))
    var_dict_sf3 = var_dict_1+var_dict_2

# Convert and Rename Variables
# --------------------------------------------------------------------------

### Converts variables into dataframe and filters only FIPS of interest

df_vars_90 = pd.DataFrame.from_dict(var_dict_sf3)
df_vars_90['FIPS']=df_vars_90['state']+df_vars_90['county']+df_vars_90['tract']
df_vars_90 = filter_FIPS(df_vars_90)

### Renames variables

df_vars_90 = df_vars_90.rename(columns = {'P0010001':'pop_90',
                                            'P0120001':'white_90',
                                            'P0050001':'hh_90',
                                            'P0570001':'total_25_col_9th_90',
                                            'P0570002':'total_25_col_12th_90',
                                            'P0570003':'total_25_col_hs_90',
                                            'P0570004':'total_25_col_sc_90',
                                            'P0570005':'total_25_col_ad_90',
                                            'P0570006':'total_25_col_bd_90',
                                            'P0570007':'total_25_col_gd_90',
                                            'H061A001':'mhval_90',
                                            'H043A001':'mrent_90',
                                            'P080A001':'hinc_90',
                                            'H0080001':'ohu_90',
                                            'H0080002':'rhu_90',
                                            'P0800001':'I_5000_90',
                                            'P0800002':'I_10000_90',
                                            'P0800003':'I_12500_90',
                                            'P0800004':'I_15000_90',
                                            'P0800005':'I_17500_90',
                                            'P0800006':'I_20000_90',
                                            'P0800007':'I_22500_90',
                                            'P0800008':'I_25000_90',
                                            'P0800009':'I_27500_90',
                                            'P0800010':'I_30000_90',
                                            'P0800011':'I_32500_90',
                                            'P0800012':'I_35000_90',
                                            'P0800013':'I_37500_90',
                                            'P0800014':'I_40000_90',
                                            'P0800015':'I_42500_90',
                                            'P0800016':'I_45000_90',
                                            'P0800017':'I_47500_90',
                                            'P0800018':'I_50000_90',
                                            'P0800019':'I_55000_90',
                                            'P0800020':'I_60000_90',
                                            'P0800021':'I_75000_90',
                                            'P0800022':'I_100000_90',
                                            'P0800023':'I_125000_90',
                                            'P0800024':'I_150000_90',
                                            'P0800025':'I_150001_90'})

# ==========================================================================
# Export Files
# ==========================================================================
# Note: ouput paths can be altered by changing the 'output path variable above'

# Merge 2012 & 2019 files - same geometry
df_vars_summ = df_vars_19.merge(df_vars_12, on ='FIPS')

from pathlib import Path

#Export files to CSV
df_vars_summ.to_csv(output_path+"downloads/"+city_name.replace(" ", "")+'census_summ_2019.csv')
df_vars_90.to_csv(output_path+"downloads/"+city_name.replace(" ", "")+'census_90_2019.csv')
df_vars_00.to_csv(output_path+"downloads/"+city_name.replace(" ", "")+'census_00_2019.csv')
