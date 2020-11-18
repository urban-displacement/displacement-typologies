# ==========================================================================
# ==========================================================================
# ==========================================================================
# Data Download
# ==========================================================================
# ==========================================================================
# ==========================================================================

#!/usr/bin/env python
# coding: utf-8

# ### Import libraries
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
input_path = home+'/git/sparcc/data/inputs/'
output_path = home+'/git/sparcc/data/outputs/'

# ### Set API key
# key = '4c26aa6ebbaef54a55d3903212eabbb506ade381'
key = '63217a192c5803bfc72aab537fe4bf19f6058326'
c = census.Census(key)


# ### Choose city and census tracts of interest
# To get city data, run the following code in the terminal
# `python data.py <city name>`
# Example: python data.py Atlanta

city_name = str(sys.argv[1])
# city_name = "San Francisco"
# These are the counties
#If reproducing for another city, add elif for that city & desired counties here

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

# ### Creates filter function
# Note - Memphis is different bc it's located in 2 states
# Same for Boston

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

# ### Download ACS 2018 5-Year Estimates

df_vars_18=['B03002_001E',
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
df_vars_18 = df_vars_18 + var_list

# Migration - see notes
var_str = 'B07010'
var_list = []
for i in list(range(25,34))+list(range(36, 45))+list(range(47, 56))+list(range(58, 67)):
    var_list.append(var_str+'_'+str(i).zfill(3)+'E')
df_vars_18 = df_vars_18 + var_list

# #### Run API query
# NOTE: Memphis is located in two states so the query looks different
# same for Boston

if (city_name not in ('Memphis', 'Boston')):
    var_dict_acs5 = c.acs5.get(df_vars_18, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2018)
else:
    var_dict_1 = c.acs5.get(df_vars_18, geo = {'for': 'tract:*',
                                 'in': sql_query_1} , year=2018)
    var_dict_2 = (c.acs5.get(df_vars_18, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2018))
    var_dict_acs5 = var_dict_1+var_dict_2

# #### Converts variables into dataframe and filters only FIPS of interest

df_vars_18 = pd.DataFrame.from_dict(var_dict_acs5)
df_vars_18['FIPS']=df_vars_18['state']+df_vars_18['county']+df_vars_18['tract']
df_vars_18 = filter_FIPS(df_vars_18)

# #### Renames variables

df_vars_18 = df_vars_18.rename(columns = {'B03002_001E':'pop_18',
                                          'B03002_003E':'white_18',
                                          'B19001_001E':'hh_18',
                                          'B19013_001E':'hinc_18',
                                          'B25077_001E':'mhval_18',
                                          'B25077_001M':'mhval_18_se',
                                          'B25064_001E':'mrent_18',
                                          'B25064_001M':'mrent_18_se',
                                          'B25003_002E':'ohu_18',
                                          'B25003_003E':'rhu_18',
                                          'B25105_001E':'mmhcosts_18',
                                          'B15003_001E':'total_25_18',
                                          'B15003_022E':'total_25_col_bd_18',
                                          'B15003_023E':'total_25_col_md_18',
                                          'B15003_024E':'total_25_col_pd_18',
                                          'B15003_025E':'total_25_col_phd_18',
                                          'B25034_001E':'tot_units_built_18',
                                          'B25034_010E':'units_40_49_built_18',
                                          'B25034_011E':'units_39_early_built_18',
                                          'B07010_025E':'mov_wc_w_income_18',
                                          'B07010_026E':'mov_wc_9000_18',
                                          'B07010_027E':'mov_wc_15000_18',
                                          'B07010_028E':'mov_wc_25000_18',
                                          'B07010_029E':'mov_wc_35000_18',
                                          'B07010_030E':'mov_wc_50000_18',
                                          'B07010_031E':'mov_wc_65000_18',
                                          'B07010_032E':'mov_wc_75000_18',
                                          'B07010_033E':'mov_wc_76000_more_18',
                                          'B07010_036E':'mov_oc_w_income_18',
                                          'B07010_037E':'mov_oc_9000_18',
                                          'B07010_038E':'mov_oc_15000_18',
                                          'B07010_039E':'mov_oc_25000_18',
                                          'B07010_040E':'mov_oc_35000_18',
                                          'B07010_041E':'mov_oc_50000_18',
                                          'B07010_042E':'mov_oc_65000_18',
                                          'B07010_043E':'mov_oc_75000_18',
                                          'B07010_044E':'mov_oc_76000_more_18',
                                          'B07010_047E':'mov_os_w_income_18',
                                          'B07010_048E':'mov_os_9000_18',
                                          'B07010_049E':'mov_os_15000_18',
                                          'B07010_050E':'mov_os_25000_18',
                                          'B07010_051E':'mov_os_35000_18',
                                          'B07010_052E':'mov_os_50000_18',
                                          'B07010_053E':'mov_os_65000_18',
                                          'B07010_054E':'mov_os_75000_18',
                                          'B07010_055E':'mov_os_76000_more_18',
                                          'B07010_058E':'mov_fa_w_income_18',
                                          'B07010_059E':'mov_fa_9000_18',
                                          'B07010_060E':'mov_fa_15000_18',
                                          'B07010_061E':'mov_fa_25000_18',
                                          'B07010_062E':'mov_fa_35000_18',
                                          'B07010_063E':'mov_fa_50000_18',
                                          'B07010_064E':'mov_fa_65000_18',
                                          'B07010_065E':'mov_fa_75000_18',
                                          'B07010_066E':'mov_fa_76000_more_18',
                                          'B06011_001E':'iinc_18',
                                          'B19001_002E':'I_10000_18',
                                          'B19001_003E':'I_15000_18',
                                          'B19001_004E':'I_20000_18',
                                          'B19001_005E':'I_25000_18',
                                          'B19001_006E':'I_30000_18',
                                          'B19001_007E':'I_35000_18',
                                          'B19001_008E':'I_40000_18',
                                          'B19001_009E':'I_45000_18',
                                          'B19001_010E':'I_50000_18',
                                          'B19001_011E':'I_60000_18',
                                          'B19001_012E':'I_75000_18',
                                          'B19001_013E':'I_100000_18',
                                          'B19001_014E':'I_125000_18',
                                          'B19001_015E':'I_150000_18',
                                          'B19001_016E':'I_200000_18',
                                          'B19001_017E':'I_201000_18'})

# ### Download ACS 2012 5-Year Estimates

# #### List variables of interest
# 
# H061A001 - median house value,
# H043A001 - median rent

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


# #### Run API query
# NOTE: Memphis is located in two states so the query looks different
# same for Boston

if (city_name not in ('Memphis','Boston')):
    var_dict_acs5 = c.acs5.get(df_vars_12, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2012)
else:
    var_dict_1 = c.acs5.get(df_vars_12, geo = {'for': 'tract:*',
                                 'in': sql_query_1} , year=2012)
    var_dict_2 = (c.acs5.get(df_vars_12, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2012))
    var_dict_acs5 = var_dict_1+var_dict_2


# #### Converts variables into dataframe and filters only FIPS of interest

df_vars_12 = pd.DataFrame.from_dict(var_dict_acs5)
df_vars_12['FIPS']=df_vars_12['state']+df_vars_12['county']+df_vars_12['tract']
df_vars_12 = filter_FIPS(df_vars_12)

# #### Renames variables

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

# ### Download ACS 2010 5-Year Estimates

# df_vars_10=[]

# # Migration - see notes
# var_str = 'B07010'
# var_list = ['B19013_001E']
# for i in list(range(25,34))+list(range(36, 45))+list(range(47, 56))+list(range(58, 67)):
#     var_list.append(var_str+'_'+str(i).zfill(3)+'E')
# df_vars_10 = df_vars_10 + var_list

# #### Run API query
# NOTE: Memphis is located in two states so the query looks different

# if city_name != 'Memphis':
#     var_dict_acs5 = c.acs5.get(df_vars_10, geo = {'for': 'tract:*',
#                                  'in': sql_query}, year=2010)
# else:
#     var_dict_1 = c.acs5.get(df_vars_10, geo = {'for': 'tract:*',
#                                  'in': sql_query_1} , year=2010)
#     var_dict_2 = (c.acs5.get(df_vars_10, geo = {'for': 'tract:*',
#                                  'in': sql_query_2}, year=2010))
#     var_dict_acs5 = var_dict_1+var_dict_2

# #### Converts variables into dataframe and filters only FIPS of interest

# df_vars_10 = pd.DataFrame.from_dict(var_dict_acs5)
# df_vars_10['FIPS']=df_vars_10['state']+df_vars_10['county']+df_vars_10['tract']
# df_vars_10 = filter_FIPS(df_vars_10)

# #### Renames variables

# df_vars_10 = df_vars_10.rename(columns = {'B07010_025E':'mov_wc_w_income_10',
#                                           'B07010_026E':'mov_wc_9000_10',
#                                           'B07010_027E':'mov_wc_15000_10',
#                                           'B07010_028E':'mov_wc_25000_10',
#                                           'B07010_029E':'mov_wc_35000_10',
#                                           'B07010_030E':'mov_wc_50000_10',
#                                           'B07010_031E':'mov_wc_65000_10',
#                                           'B07010_032E':'mov_wc_75000_10',
#                                           'B07010_033E':'mov_wc_76000_more_10',
#                                           'B07010_036E':'mov_oc_w_income_10',
#                                           'B07010_037E':'mov_oc_9000_10',
#                                           'B07010_038E':'mov_oc_15000_10',
#                                           'B07010_039E':'mov_oc_25000_10',
#                                           'B07010_040E':'mov_oc_35000_10',
#                                           'B07010_041E':'mov_oc_50000_10',
#                                           'B07010_042E':'mov_oc_65000_10',
#                                           'B07010_043E':'mov_oc_75000_10',
#                                           'B07010_044E':'mov_oc_76000_more_10',
#                                           'B07010_047E':'mov_os_w_income_10',
#                                           'B07010_048E':'mov_os_9000_10',
#                                           'B07010_049E':'mov_os_15000_10',
#                                           'B07010_050E':'mov_os_25000_10',
#                                           'B07010_051E':'mov_os_35000_10',
#                                           'B07010_052E':'mov_os_50000_10',
#                                           'B07010_053E':'mov_os_65000_10',
#                                           'B07010_054E':'mov_os_75000_10',
#                                           'B07010_055E':'mov_os_76000_more_10',
#                                           'B07010_058E':'mov_fa_w_income_10',
#                                           'B07010_059E':'mov_fa_9000_10',
#                                           'B07010_060E':'mov_fa_15000_10',
#                                           'B07010_061E':'mov_fa_25000_10',
#                                           'B07010_062E':'mov_fa_35000_10',
#                                           'B07010_063E':'mov_fa_50000_10',
#                                           'B07010_064E':'mov_fa_65000_10',
#                                           'B07010_065E':'mov_fa_75000_10',
#                                           'B07010_066E':'mov_fa_76000_more_10',
#                                           'B19013_001E':'hinc_10',})


# ### Decennial Census 2000 Variables

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


# #### Run API query
# NOTE: Memphis is located in two states so the query looks different
# same for Boston



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

# #### Converts variables into dataframe and filters only FIPS of interest

df_vars_sf1 = pd.DataFrame.from_dict(var_dict_sf1)
df_vars_sf3 = pd.DataFrame.from_dict(var_dict_sf3)
df_vars_sf1['FIPS']=df_vars_sf1['state']+df_vars_sf1['county']+df_vars_sf1['tract']
df_vars_sf3['FIPS']=df_vars_sf3['state']+df_vars_sf3['county']+df_vars_sf3['tract']
df_vars_sf1 = filter_FIPS(df_vars_sf1)
df_vars_sf3 = filter_FIPS(df_vars_sf3)

# #### Renames variables

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

# ### Download Decennial Census 1990 Variables

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

# #### Run API query
# NOTE: Memphis is located in two states so the query looks different
# Same for Boston

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

# #### Converts variables into dataframe and filters only FIPS of interest

df_vars_90 = pd.DataFrame.from_dict(var_dict_sf3)
df_vars_90['FIPS']=df_vars_90['state']+df_vars_90['county']+df_vars_90['tract']
df_vars_90 = filter_FIPS(df_vars_90)

# #### Renames variables

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

# ### Export files
# 
# All output files will be exported into your personal repo. However, the .gitignore prevents these files from being uploaded to the online Github repo. The reason being that 
# * It's bad practice to store data on github
# * Github has a file upload limit of 100mb and a repo size limit of 2gb. 
# 
# The input file folder is about 1gb in size and will be pulled from the Google Drive. You will see the path in the next notebook. 



# Merge 2010 & 2018 files - same geometry
# df_vars_summ = df_vars_18.merge(df_vars_10, on = 'FIPS').merge(df_vars_12, on ='FIPS')
df_vars_summ = df_vars_18.merge(df_vars_12, on ='FIPS')



home = str(Path.home())

#Export files to CSV
df_vars_summ.to_csv(output_path+city_name+'census_summ.csv')
df_vars_90.to_csv(output_path+city_name+'census_90.csv')
df_vars_00.to_csv(output_path+city_name+'census_00.csv')


# ==========================================================================
# ==========================================================================
# ==========================================================================
# Crosswalk Files
# ==========================================================================
# ==========================================================================
# ==========================================================================

# ### Read files
# ccsv('~/git/sparcc/data/'+city_name+'census_90_10.csv')
census_00_filtered.to_csv(output_path+city_name+'census_00_10.csv')


# ==========================================================================
# ==========================================================================
# ==========================================================================
# Variable Creation
# ==========================================================================
# ==========================================================================
# ==========================================================================

shp_folder = input_path+'shp/'+city_name+'/'
data_1990 = pd.read_csv(output_path+city_name+'census_90_10.csv', index_col = 0) 
data_2000 = pd.read_csv(output_path+city_name+'census_00_10.csv', index_col = 0)
acs_data = pd.read_csv(output_path+city_name+'census_summ.csv', index_col = 0)
acs_data = acs_data.drop(columns = ['county_y', 'state_y', 'tract_y'])
acs_data = acs_data.rename(columns = {'county_x': 'county',
                                    'state_x': 'state',
                                    'tract_x': 'tract'})


### PUMS
pums_r = pd.read_csv(input_path+'nhgis0002_ds233_20175_2017_tract.csv', encoding = "ISO-8859-1")
pums_o = pd.read_csv(input_path+'nhgis0002_ds234_20175_2017_tract.csv', encoding = "ISO-8859-1")
pums = pums_r.merge(pums_o, on = 'GISJOIN')
pums = pums.rename(columns = {'YEAR_x':'YEAR',
                               'STATE_x':'STATE',
                               'STATEA_x':'STATEA',
                               'COUNTY_x':'COUNTY',
                               'COUNTYA_x':'COUNTYA',
                               'TRACTA_x':'TRACTA',
                               'NAME_E_x':'NAME_E'})
pums = pums.dropna(axis = 1)


### Zillow data
zillow = pd.read_csv(input_path+'Zip_Zhvi_AllHomes.csv', encoding = "ISO-8859-1")
zillow_xwalk = pd.read_csv(input_path+'TRACT_ZIP_032015.csv')

### Rail data
rail = pd.read_csv(input_path+'tod_database_download.csv')

### Hospitals
hospitals = pd.read_csv(input_path+'Hospitals.csv')

### Universities
university = pd.read_csv(input_path+'university_HD2016.csv')
### LIHTC
lihtc = pd.read_csv(input_path+'LowIncome_Housing_Tax_Credit_Properties.csv')

### Public housing
pub_hous = pd.read_csv(input_path+'Public_Housing_Buildings.csv.gz')

### SHP data
#add elif for your city here
#Pull cartographic boundary files from here: 
#https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.2018.html
if city_name == 'Memphis':
    shp_name = 'cb_2018_47_tract_500k.shp'
elif city_name == 'Chicago':
    shp_name = 'cb_2018_17_tract_500k.shp'
elif city_name == 'Atlanta':
    shp_name = 'cb_2018_13_tract_500k.shp'
elif city_name == 'Denver':
    shp_name = 'cb_2018_08_tract_500k.shp'
elif city_name == 'Los Angeles':
    shp_name = 'cb_2018_06_tract_500k.shp'
elif city_name == 'San Francisco':
    shp_name = 'cb_2018_06_tract_500k.shp'
elif city_name == 'Seattle':
    shp_name = 'cb_2018_53_tract_500k.shp'
elif city_name == 'Cleveland':
    shp_name = 'cb_2018_39_tract_500k.shp'
elif city_name == 'Boston':
    shp_name = 'cb_2018_25_tract_500k.shp'

city_shp = gpd.read_file(shp_folder+shp_name)


# ### Choose city and define city specific variables
# Add elif for your city here
# 2020.07.20 change: make rail agencies a list for calls later in the code


if city_name == 'Chicago':
    state = '17'
    state_init = ['IL']
    FIPS = ['031', '043', '089', '093', '097', '111', '197']
    rail_agency = ['CTA']
    zone = '16T'  
elif city_name == 'Atlanta':
    state = '13'
    state_init = ['GA']
    FIPS = ['057', '063', '067', '089', '097', '113', '121', '135', '151', '247']
    rail_agency = ['MARTA']
    zone = '16S' 
elif city_name == 'Denver':
    state = '08'
    state_init = ['CO']
    FIPS = ['001', '005', '013', '014', '019', '031', '035', '047', '059']
    rail_agency = ['RTD']
    zone = '13S'
elif city_name == 'Memphis':
    state = ['28', '47']
    state_init = ['MS', 'TN']
    FIPS = {'28':['033', '093'], '47': ['047', '157']}
    rail_agency = [np.nan]
    zone = '15S'
elif city_name == 'Los Angeles':
    state = '06'
    state_init = ['CA']
    FIPS = ['037', '059', '073']
    rail_agency = ['Metro', 'MTS', 'Metrolink']
    zone = '11S'
elif city_name == 'San Francisco':
    state = '06'
    state_init = ['CA']
    FIPS = ['001', '013', '041', '055', '067', '075', '077', '081', '085', '087', '095', '097', '113']
    rail_agency = ['ACE ', 'ACE , Capitol Corridor Joint Powers Authority', 'BART', 'Caltrain', 'Capitol Corridor Joint Powers Authority', 'RT', 'San Francisco Municipal Transportation Agency', 'VTA', 'Alameda/Oakland Ferry', 'Blue & Gold Fleet', 'Golden Gate Ferry', 'Harbor Bay Ferry', 'Baylink']
    zone = '10S'
elif city_name == 'Seattle':
    state = '53'
    state_init = ['WA']
    FIPS = ['033', '053', '061']
    rail_agency = ['City of Seattle', 'Sound Transit', 'Washington State Ferries', 'King County Marine Division']
    zone = '10T'
elif city_name == 'Cleveland':
    state = '39'
    state_init = ['OH']
    FIPS = ['035', '055', '085', '093', '103']
    rail_agency = ['GCRTA']
    zone = '17T'
elif city_name == 'Boston':
    state = ['25', '33']
    state_init = ['MA', 'NH']
    FIPS = {'25': ['009', '017', '021', '023', '025'], '33': ['015', '017']}
    rail_agency = ['MBTA', 'Amtrak', 'Salem Ferry', 'Boston Harbor Islands Ferries']
    zone = '19T'
else:
    print ('There is no information for the selected city')


# ### Merge census data in single file

census = acs_data.merge(data_2000, on = 'FIPS', how = 'outer').merge(data_1990, on = 'FIPS', how = 'outer')


# ### Compute census variables

# #### CPI indexing values



### This is based on the yearly CPI average - see https://www.bls.gov/data/inflation_calculator.htm for updates. 
CPI_89_18 = 2.04
CPI_99_18 = 1.51
CPI_12_18 = 1.09

### This is used for the Zillow data, where january values are compared
CPI_0115_0119 = 1.06


# #### Income



census['hinc_18'][census['hinc_18']<0]=np.nan
census['hinc_00'][census['hinc_00']<0]=np.nan
census['hinc_90'][census['hinc_90']<0]=np.nan




### These are not indexed
rm_hinc_18 = np.nanmedian(census['hinc_18'])
rm_hinc_00 = np.nanmedian(census['hinc_00'])
rm_hinc_90 = np.nanmedian(census['hinc_90'])
rm_iinc_18 = np.nanmedian(census['iinc_18'])
rm_iinc_12 = np.nanmedian(census['iinc_12'])

print(rm_hinc_18, rm_hinc_00, rm_hinc_90, rm_iinc_18, rm_iinc_12)




def income_interpolation (census, year, cutoff, mhinc, tot_var, var_suffix, out):
    name = []
    for c in list(census.columns):
        if (c[0]==var_suffix):
            if c.split('_')[2]==year:
                name.append(c)
    name.append('FIPS')
    name.append(tot_var)
    income_cat = census[name]
    income_group = income_cat.drop(columns = ['FIPS', tot_var]).columns
    income_group = income_group.str.split('_')
    number = []
    for i in range (0, len(income_group)):
        number.append(income_group[i][1])
    column = []
    for i in number:
        column.append('prop_'+str(i))
        income_cat['prop_'+str(i)] = income_cat[var_suffix+'_'+str(i)+'_'+year]/income_cat[tot_var]          
    reg_median_cutoff = cutoff*mhinc
    cumulative = out+str(int(cutoff*100))+'_cumulative'
    income = out+str(int(cutoff*100))+'_'+year 
    df = income_cat
    df[cumulative] = 0
    df[income] = 0
    for i in range(0,(len(number)-1)):
        a = (number[i])
        b = float(number[i+1])-0.01
        prop = str(number[i+1])
        df[cumulative] = df[cumulative]+df['prop_'+a]
        if (reg_median_cutoff>=int(a))&(reg_median_cutoff<b):
            df[income] = ((reg_median_cutoff - int(a))/(b-int(a)))*df['prop_'+prop] + df[cumulative] 
    df = df.drop(columns = [cumulative])
    prop_col = df.columns[df.columns.str[0:4]=='prop'] 
    df = df.drop(columns = prop_col)     
    census = census.merge (df[['FIPS', income]], on = 'FIPS')
    return census

census = income_interpolation (census, '18', 0.8, rm_hinc_18, 'hh_18', 'I', 'inc')
census = income_interpolation (census, '18', 1.2, rm_hinc_18, 'hh_18', 'I', 'inc')
census = income_interpolation (census, '00', 0.8, rm_hinc_00, 'hh_00', 'I', 'inc')
census = income_interpolation (census, '00', 1.2, rm_hinc_00, 'hh_00', 'I', 'inc')
census = income_interpolation (census, '90', 0.8, rm_hinc_90, 'hh_00', 'I', 'inc')

income_col = census.columns[census.columns.str[0:2]=='I_'] 
census = census.drop(columns = income_col)


# ###### Generate income categories



def income_categories (df, year, mhinc, hinc):
    df['hinc_'+year] = np.where(df['hinc_'+year]<0, 0, df['hinc_'+year])  
    reg_med_inc80 = 0.8*mhinc
    reg_med_inc120 = 1.2*mhinc
    low = 'low_80120_'+year 
    mod = 'mod_80120_'+year
    high = 'high_80120_'+year
    df[low] = df['inc80_'+year]
    df[mod] = df['inc120_'+year] - df['inc80_'+year]
    df[high] = 1 - df['inc120_'+year]  
    ### Low income
    df['low_pdmt_medhhinc_'+year] = np.where((df['low_80120_'+year]>=0.55)&(df['mod_80120_'+year]<0.45)&(df['high_80120_'+year]<0.45),1,0)
    ## High income
    df['high_pdmt_medhhinc_'+year] = np.where((df['low_80120_'+year]<0.45)&(df['mod_80120_'+year]<0.45)&(df['high_80120_'+year]>=0.55),1,0)
    ### Moderate income
    df['mod_pdmt_medhhinc_'+year] = np.where((df['low_80120_'+year]<0.45)&(df['mod_80120_'+year]>=0.55)&(df['high_80120_'+year]<0.45),1,0)
    ### Mixed-Low income
    df['mix_low_medhhinc_'+year] = np.where((df['low_pdmt_medhhinc_'+year]==0)&
                                                  (df['mod_pdmt_medhhinc_'+year]==0)&
                                                  (df['high_pdmt_medhhinc_'+year]==0)&
                                                  (df[hinc]<reg_med_inc80),1,0)
    ### Mixed-Moderate income
    df['mix_mod_medhhinc_'+year] = np.where((df['low_pdmt_medhhinc_'+year]==0)&
                                                  (df['mod_pdmt_medhhinc_'+year]==0)&
                                                  (df['high_pdmt_medhhinc_'+year]==0)&
                                                  (df[hinc]>=reg_med_inc80)&
                                                  (df[hinc]<reg_med_inc120),1,0)
    ### Mixed-High income
    df['mix_high_medhhinc_'+year] = np.where((df['low_pdmt_medhhinc_'+year]==0)&
                                                  (df['mod_pdmt_medhhinc_'+year]==0)&
                                                  (df['high_pdmt_medhhinc_'+year]==0)&
                                                  (df[hinc]>=reg_med_inc120),1,0)   
    df['inc_cat_medhhinc_'+year] = 0
    df.loc[df['low_pdmt_medhhinc_'+year]==1, 'inc_cat_medhhinc_'+year] = 1
    df.loc[df['mix_low_medhhinc_'+year]==1, 'inc_cat_medhhinc_'+year] = 2
    df.loc[df['mod_pdmt_medhhinc_'+year]==1, 'inc_cat_medhhinc_'+year] = 3
    df.loc[df['mix_mod_medhhinc_'+year]==1, 'inc_cat_medhhinc_'+year] = 4
    df.loc[df['mix_high_medhhinc_'+year]==1, 'inc_cat_medhhinc_'+year] = 5
    df.loc[df['high_pdmt_medhhinc_'+year]==1, 'inc_cat_medhhinc_'+year] = 6    
    df['inc_cat_medhhinc_encoded'+year] = 0
    df.loc[df['low_pdmt_medhhinc_'+year]==1, 'inc_cat_medhhinc_encoded'+year] = 'low_pdmt'
    df.loc[df['mix_low_medhhinc_'+year]==1, 'inc_cat_medhhinc_encoded'+year] = 'mix_low'
    df.loc[df['mod_pdmt_medhhinc_'+year]==1, 'inc_cat_medhhinc_encoded'+year] = 'mod_pdmt'
    df.loc[df['mix_mod_medhhinc_'+year]==1, 'inc_cat_medhhinc_encoded'+year] = 'mix_mod'
    df.loc[df['mix_high_medhhinc_'+year]==1, 'inc_cat_medhhinc_encoded'+year] = 'mix_high'
    df.loc[df['high_pdmt_medhhinc_'+year]==1, 'inc_cat_medhhinc_encoded'+year] = 'high_pdmt'
    df.loc[df['hinc_'+year]==0, 'low_pdmt_medhhinc_'+year] = np.nan
    df.loc[df['hinc_'+year]==0, 'mix_low_medhhinc_'+year] = np.nan
    df.loc[df['hinc_'+year]==0, 'mod_pdmt_medhhinc_'+year] = np.nan
    df.loc[df['hinc_'+year]==0, 'mix_mod_medhhinc_'+year] = np.nan
    df.loc[df['hinc_'+year]==0, 'mix_high_medhhinc_'+year] = np.nan
    df.loc[df['hinc_'+year]==0, 'high_pdmt_medhhinc_'+year] = np.nan
    df.loc[df['hinc_'+year]==0, 'inc_cat_medhhinc_'+year] = np.nan
    return census

census = income_categories(census, '18', rm_hinc_18, 'hinc_18')
census = income_categories(census, '00', rm_hinc_00, 'hinc_00')




census.groupby('inc_cat_medhhinc_00').count()['FIPS']

census.groupby('inc_cat_medhhinc_18').count()['FIPS']

### Percentage & total low-income households - under 80% AMI
census ['per_all_li_90'] = census['inc80_90']
census ['per_all_li_00'] = census['inc80_00']
census ['per_all_li_18'] = census['inc80_18']

census['all_li_count_90'] = census['per_all_li_90']*census['hh_90']
census['all_li_count_00'] = census['per_all_li_00']*census['hh_00']
census['all_li_count_18'] = census['per_all_li_18']*census['hh_18']

len(census)

# #### Index all values to 2018

# ==========================================================================
# change: 
# 2020.03.29 - adding 2012 rent and homevalue
# start change
# ==========================================================================

census['real_mhval_90'] = census['mhval_90']*CPI_89_18
census['real_mrent_90'] = census['mrent_90']*CPI_89_18
census['real_hinc_90'] = census['hinc_90']*CPI_89_18

census['real_mhval_00'] = census['mhval_00']*CPI_99_18
census['real_mrent_00'] = census['mrent_00']*CPI_99_18
census['real_hinc_00'] = census['hinc_00']*CPI_99_18

census['real_mhval_12'] = census['mhval_12']*CPI_12_18
census['real_mrent_12'] = census['mrent_12']*CPI_12_18
# census['real_hinc_12'] = census['hinc_12']*CPI_12_18 # this isn't calculated yet (2020.03.29)

census['real_mhval_18'] = census['mhval_18']
census['real_mrent_18'] = census['mrent_18']
census['real_hinc_18'] = census['hinc_18']

# end change
# ==========================================================================



# #### Demographics

# bk - bookmark

df = census

### % of non-white

###
df['per_nonwhite_18'] = 1 - df['white_18']/df['pop_18']

### 1990
df['per_nonwhite_90'] = 1 - df['white_90']/df['pop_90']

### 2000
df['per_nonwhite_00'] = 1 - df['white_00']/df['pop_00']


### % of owner and renter-occupied housing units
### 1990
df['hu_90'] = df['ohu_90']+df['rhu_90']
df['per_rent_90'] = df['rhu_90']/df['hu_90']

### 2000
df['per_rent_00'] = df['rhu_00']/df['hu_00']

### 2018
df['hu_18'] = df['ohu_18']+df['rhu_18']
df['per_rent_18'] = df['rhu_18']/df['hu_18']


### % of college educated

### 1990
var_list = ['total_25_col_9th_90',
            'total_25_col_12th_90',
            'total_25_col_hs_90',
            'total_25_col_sc_90',
            'total_25_col_ad_90',
            'total_25_col_bd_90',
            'total_25_col_gd_90']
df['total_25_90'] = df[var_list].sum(axis = 1)
df['per_col_90'] = (df['total_25_col_bd_90']+df['total_25_col_gd_90'])/(df['total_25_90'])

### 2000
df['male_25_col_00'] = (df['male_25_col_bd_00']+
                        df['male_25_col_md_00']+
#                         df['male_25_col_psd_00']+
                        df['male_25_col_phd_00'])
df['female_25_col_00'] = (df['female_25_col_bd_00']+
                          df['female_25_col_md_00']+
#                           df['female_25_col_psd_00']+
                          df['female_25_col_phd_00'])
df['total_25_col_00'] = df['male_25_col_00']+df['female_25_col_00']
df['per_col_00'] = df['total_25_col_00']/df['total_25_00']

### 2018
df['per_col_18'] = (df['total_25_col_bd_18']+
                    df['total_25_col_md_18']+
                    df['total_25_col_pd_18']+
                    df['total_25_col_phd_18'])/df['total_25_18']

### Housing units built
df['per_units_pre50_18'] = (df['units_40_49_built_18']+df['units_39_early_built_18'])/df['tot_units_built_18']


# #### Percent of people who have moved who are low-income



def income_interpolation_movein (census, year, cutoff, rm_iinc):
    # SUM EVERY CATEGORY BY INCOME
    ### Filter only move-in variables
    name = []
    for c in list(census.columns):
        if (c[0:3] == 'mov') & (c[-2:]==year):
            name.append(c)
    name.append('FIPS')
    income_cat = census[name]
    ### Pull income categories
    income_group = income_cat.drop(columns = ['FIPS']).columns
    number = []
    for c in name[:9]:
        number.append(c.split('_')[2])
    ### Sum move-in in last 5 years by income category, including total w/ income
    column_name_totals = []
    for i in number:
        column_name = []
        for j in income_group:
            if j.split('_')[2] == i:
                column_name.append(j)
        if i == 'w':
            i = 'w_income'
        income_cat['mov_tot_'+i+'_'+year] = income_cat[column_name].sum(axis = 1)
        column_name_totals.append('mov_tot_'+i+'_'+year)
    # DO INCOME INTERPOLATION
    column = []
    number = [n for n in number if n != 'w'] ### drop total
    for i in number:
        column.append('prop_mov_'+i)
        income_cat['prop_mov_'+i] = income_cat['mov_tot_'+i+'_'+year]/income_cat['mov_tot_w_income_'+year]
    reg_median_cutoff = cutoff*rm_iinc
    cumulative = 'inc'+str(int(cutoff*100))+'_cumulative'
    per_limove = 'per_limove_'+year
    df = income_cat
    df[cumulative] = 0
    df[per_limove] = 0
    for i in range(0,(len(number)-1)):
        a = (number[i])
        b = float(number[i+1])-0.01
        prop = str(number[i+1])
        df[cumulative] = df[cumulative]+df['prop_mov_'+a]
        if (reg_median_cutoff>=int(a))&(reg_median_cutoff<b):
            df[per_limove] = ((reg_median_cutoff - int(a))/(b-int(a)))*df['prop_mov_'+prop] + df[cumulative]           
    df = df.drop(columns = [cumulative])
    prop_col = df.columns[df.columns.str[0:4]=='prop'] 
    df = df.drop(columns = prop_col)     
    col_list = [per_limove]+['mov_tot_w_income_'+year]
    census = census.merge (df[['FIPS'] + col_list], on = 'FIPS')
    return census

census = income_interpolation_movein (census, '18', 0.8, rm_iinc_18)
census = income_interpolation_movein (census, '12', 0.8, rm_iinc_12)

len(census)

# #### Housing Affordability: note exceptions for Memphis & Boston that have 2 states

def filter_PUMS(df, FIPS):
    if (city_name not in ('Memphis', 'Boston')):
        FIPS = [int(x) for x in FIPS]
        df = df[(df['STATEA'] == int(state))&(df['COUNTYA'].isin(FIPS))].reset_index(drop = True)
    else:
        fips_list = []
        for i in state:
            county = FIPS[i]
            county = [int(x) for x in county]
            a = list((df['GISJOIN'][(pums['STATEA']==int(i))&(df['COUNTYA'].isin(county))]))
            fips_list += a
        df = df[df['GISJOIN'].isin(fips_list)].reset_index(drop = True)
    return df

pums = filter_PUMS(pums, FIPS)
pums['FIPS'] = ((pums['STATEA'].astype(str).str.zfill(2))+
                (pums['COUNTYA'].astype(str).str.zfill(3))+
                (pums['TRACTA'].astype(str).str.zfill(6)))

pums = pums.rename(columns = {"AH5QE002":"rhu_18_wcash",
                                "AH5QE003":"R_100_18",
                                "AH5QE004":"R_150_18",
                                "AH5QE005":"R_200_18",
                                "AH5QE006":"R_250_18",
                                "AH5QE007":"R_300_18",
                                "AH5QE008":"R_350_18",
                                "AH5QE009":"R_400_18",
                                "AH5QE010":"R_450_18",
                                "AH5QE011":"R_500_18",
                                "AH5QE012":"R_550_18",
                                "AH5QE013":"R_600_18",
                                "AH5QE014":"R_650_18",
                                "AH5QE015":"R_700_18",
                                "AH5QE016":"R_750_18",
                                "AH5QE017":"R_800_18",
                                "AH5QE018":"R_900_18",
                                "AH5QE019":"R_1000_18",
                                "AH5QE020":"R_1250_18",
                                "AH5QE021":"R_1500_18",
                                "AH5QE022":"R_2000_18",
                                "AH5QE023":"R_2500_18",
                                "AH5QE024":"R_3000_18",
                                "AH5QE025":"R_3500_18",
                                "AH5QE026":"R_3600_18",
                                "AH5QE027":"rhu_18_wocash",
                                "AIMUE001":"ohu_tot_18",
                                "AIMUE002":"O_200_18",
                                "AIMUE003":"O_300_18",
                                "AIMUE004":"O_400_18",
                                "AIMUE005":"O_500_18",
                                "AIMUE006":"O_600_18",
                                "AIMUE007":"O_700_18",
                                "AIMUE008":"O_800_18",
                                "AIMUE009":"O_900_18",
                                "AIMUE010":"O_1000_18",
                                "AIMUE011":"O_1250_18",
                                "AIMUE012":"O_1500_18",
                                "AIMUE013":"O_2000_18",
                                "AIMUE014":"O_2500_18",
                                "AIMUE015":"O_3000_18",
                                "AIMUE016":"O_3500_18",
                                "AIMUE017":"O_4000_18",
                                "AIMUE018":"O_4100_18"})

aff_18 = rm_hinc_18*0.3/12
pums = income_interpolation (pums, '18', 0.6, aff_18, 'rhu_18_wcash', 'R', 'rent')
pums = income_interpolation (pums, '18', 1.2, aff_18, 'rhu_18_wcash', 'R', 'rent')

pums = income_interpolation (pums, '18', 0.6, aff_18, 'ohu_tot_18', 'O', 'own')
pums = income_interpolation (pums, '18', 1.2, aff_18, 'ohu_tot_18', 'O', 'own')


pums['FIPS'] = pums['FIPS'].astype(float).astype('int64')
pums = pums.merge(census[['FIPS', 'mmhcosts_18']], on = 'FIPS')

pums['rlow_18'] = pums['rent60_18']*pums['rhu_18_wcash']+pums['rhu_18_wocash'] ### includes no cash rent
pums['rmod_18'] = pums['rent120_18']*pums['rhu_18_wcash']-pums['rent60_18']*pums['rhu_18_wcash']
pums['rhigh_18'] = pums['rhu_18_wcash']-pums['rent120_18']*pums['rhu_18_wcash']

pums['olow_18'] = pums['own60_18']*pums['ohu_tot_18']
pums['omod_18'] = pums['own120_18']*pums['ohu_tot_18'] - pums['own60_18']*pums['ohu_tot_18']
pums['ohigh_18'] = pums['ohu_tot_18'] - pums['own120_18']*pums['ohu_tot_18']

pums['hu_tot_18'] = pums['rhu_18_wcash']+pums['rhu_18_wocash']+pums['ohu_tot_18']

pums['low_tot_18'] = pums['rlow_18']+pums['olow_18']
pums['mod_tot_18'] = pums['rmod_18']+pums['omod_18']
pums['high_tot_18'] = pums['rhigh_18']+pums['ohigh_18']

pums['pct_low_18'] = pums['low_tot_18']/pums['hu_tot_18']
pums['pct_mod_18'] = pums['mod_tot_18']/pums['hu_tot_18']
pums['pct_high_18'] = pums['high_tot_18']/pums['hu_tot_18']


### Low income
pums['predominantly_LI'] = np.where((pums['pct_low_18']>=0.55)&
                                       (pums['pct_mod_18']<0.45)&
                                       (pums['pct_high_18']<0.45),1,0)

## High income
pums['predominantly_HI'] = np.where((pums['pct_low_18']<0.45)&
                                       (pums['pct_mod_18']<0.45)&
                                       (pums['pct_high_18']>=0.55),1,0)

### Moderate income
pums['predominantly_MI'] = np.where((pums['pct_low_18']<0.45)&
                                       (pums['pct_mod_18']>=0.55)&
                                       (pums['pct_high_18']<0.45),1,0)

### Mixed-Low income
pums['mixed_low'] = np.where((pums['predominantly_LI']==0)&
                              (pums['predominantly_MI']==0)&
                              (pums['predominantly_HI']==0)&
                              (pums['mmhcosts_18']<aff_18*0.6),1,0)

### Mixed-Moderate income
pums['mixed_mod'] = np.where((pums['predominantly_LI']==0)&
                              (pums['predominantly_MI']==0)&
                              (pums['predominantly_HI']==0)&
                              (pums['mmhcosts_18']>=aff_18*0.6)&
                              (pums['mmhcosts_18']<aff_18*1.2),1,0)

### Mixed-High income
pums['mixed_high'] = np.where((pums['predominantly_LI']==0)&
                              (pums['predominantly_MI']==0)&
                              (pums['predominantly_HI']==0)&
                              (pums['mmhcosts_18']>=aff_18*1.2),1,0)

pums['lmh_flag_encoded'] = 0
pums.loc[pums['predominantly_LI']==1, 'lmh_flag_encoded'] = 1
pums.loc[pums['predominantly_MI']==1, 'lmh_flag_encoded'] = 2
pums.loc[pums['predominantly_HI']==1, 'lmh_flag_encoded'] = 3
pums.loc[pums['mixed_low']==1, 'lmh_flag_encoded'] = 4
pums.loc[pums['mixed_mod']==1, 'lmh_flag_encoded'] = 5
pums.loc[pums['mixed_high']==1, 'lmh_flag_encoded'] = 6

pums['lmh_flag_category'] = 0
pums.loc[pums['lmh_flag_encoded']==1, 'lmh_flag_category'] = 'aff_predominantly_LI'
pums.loc[pums['lmh_flag_encoded']==2, 'lmh_flag_category'] = 'aff_predominantly_MI'
pums.loc[pums['lmh_flag_encoded']==3, 'lmh_flag_category'] = 'aff_predominantly_HI'
pums.loc[pums['lmh_flag_encoded']==4, 'lmh_flag_category'] = 'aff_mix_low'
pums.loc[pums['lmh_flag_encoded']==5, 'lmh_flag_category'] = 'aff_mix_mod'
pums.loc[pums['lmh_flag_encoded']==6, 'lmh_flag_category'] = 'aff_mix_high'




pums.groupby('lmh_flag_category').count()['FIPS']




census = census.merge(pums[['FIPS', 'lmh_flag_encoded', 'lmh_flag_category']], on = 'FIPS')




len(census)


# #### Market Type

# ==========================================================================
# Change: 
# 2020.03.29 - add 2012 to 2018 changes - tim thomas
# bk
# start change
# ==========================================================================

# census['pctch_real_mhval_00_18'] = (census['real_mhval_18']-census['real_mhval_00'])/census['real_mhval_00']
# census['pctch_real_mrent_00_18'] = (census['real_mrent_18']-census['real_mrent_00'])/census['real_mrent_00']
census['pctch_real_mhval_00_18'] = (census['real_mhval_18']-census['real_mhval_00'])/census['real_mhval_00']
# census['pctch_real_mhval_12_18'] = (census['real_mhval_18']-census['real_mhval_12'])/census['real_mhval_12']
census['pctch_real_mrent_12_18'] = (census['real_mrent_18']-census['real_mrent_12'])/census['real_mrent_12']

# rm_pctch_real_mhval_00_18_increase=np.nanmedian(census['pctch_real_mhval_00_18'][census['pctch_real_mhval_00_18']>0.05])
# rm_pctch_real_mrent_00_18_increase=np.nanmedian(census['pctch_real_mrent_00_18'][census['pctch_real_mrent_00_18']>0.05])
rm_pctch_real_mhval_00_18_increase=np.nanmedian(census['pctch_real_mhval_00_18'][census['pctch_real_mhval_00_18']>0.05])
# rm_pctch_real_mhval_12_18_increase=np.nanmedian(census['pctch_real_mhval_12_18'][census['pctch_real_mhval_12_18']>0.05])
rm_pctch_real_mrent_12_18_increase=np.nanmedian(census['pctch_real_mrent_12_18'][census['pctch_real_mrent_12_18']>0.05])

# rm_pctch_real_mhval_00_18_increase=np.nanmedian(census['pctch_real_mhval_00_18'])
# rm_pctch_real_mrent_00_18_increase=np.nanmedian(census['pctch_real_mrent_00_18'])




# census['rent_decrease'] = np.where((census['pctch_real_mrent_00_18']<=-0.05), 1, 0)

# census['rent_marginal'] = np.where((census['pctch_real_mrent_00_18']>-0.05)&
#                                           (census['pctch_real_mrent_00_18']<0.05), 1, 0)

# census['rent_increase'] = np.where((census['pctch_real_mrent_00_18']>=0.05)&
#                                           (census['pctch_real_mrent_00_18']<rm_pctch_real_mrent_00_18_increase), 1, 0)

# census['rent_rapid_increase'] = np.where((census['pctch_real_mrent_00_18']>=0.05)&
#                                           (census['pctch_real_mrent_00_18']>=rm_pctch_real_mrent_00_18_increase), 1, 0)

census['rent_decrease'] = np.where((census['pctch_real_mrent_12_18']<=-0.05), 1, 0)

census['rent_marginal'] = np.where((census['pctch_real_mrent_12_18']>-0.05)&
                                          (census['pctch_real_mrent_12_18']<0.05), 1, 0)

census['rent_increase'] = np.where((census['pctch_real_mrent_12_18']>=0.05)&
                                          (census['pctch_real_mrent_12_18']<rm_pctch_real_mrent_12_18_increase), 1, 0)

census['rent_rapid_increase'] = np.where((census['pctch_real_mrent_12_18']>=0.05)&
                                          (census['pctch_real_mrent_12_18']>=rm_pctch_real_mrent_12_18_increase), 1, 0)

# end change
# ==========================================================================
# Note:
# We're keeping 2000 to 2018 because it's a one year decennial change vs a 5 year change from 2013 to 2018. 
# I'm afraid using 2 acs 5-years back to back will not be sufficent in capturing change. 
# ==========================================================================

census['house_decrease'] = np.where((census['pctch_real_mhval_00_18']<=-0.05), 1, 0)

census['house_marginal'] = np.where((census['pctch_real_mhval_00_18']>-0.05)&
                                          (census['pctch_real_mhval_00_18']<0.05), 1, 0)

census['house_increase'] = np.where((census['pctch_real_mhval_00_18']>=0.05)&
                                          (census['pctch_real_mhval_00_18']<rm_pctch_real_mhval_00_18_increase), 1, 0)

census['house_rapid_increase'] = np.where((census['pctch_real_mhval_00_18']>=0.05)&
                                          (census['pctch_real_mhval_00_18']>=rm_pctch_real_mhval_00_18_increase), 1, 0)

## Note change: original didn't have house*** == 1
census['tot_decrease'] = np.where((census['rent_decrease']==1)|(census['house_decrease']==1), 1, 0)
census['tot_marginal'] = np.where((census['rent_marginal']==1)|(census['house_marginal']==1), 1, 0)
census['tot_increase'] = np.where((census['rent_increase']==1)|(census['house_increase']==1), 1, 0)
census['tot_rapid_increase'] = np.where((census['rent_rapid_increase']==1)|(census['house_rapid_increase']==1), 1, 0)

census['change_flag_encoded'] = 0
census.loc[(census['tot_decrease']==1)|(census['tot_marginal']==1), 'change_flag_encoded'] = 1
census.loc[census['tot_increase']==1, 'change_flag_encoded'] = 2
census.loc[census['tot_rapid_increase']==1, 'change_flag_encoded'] = 3

census['change_flag_category'] = 0
census.loc[census['change_flag_encoded']==1, 'change_flag_category'] = 'ch_decrease_marginal'
census.loc[census['change_flag_encoded']==2, 'change_flag_category'] = 'ch_increase'
census.loc[census['change_flag_encoded']==3, 'change_flag_category'] = 'ch_rapid_increase'




census.groupby('change_flag_category').count()['FIPS']




census.groupby(['change_flag_category', 'lmh_flag_category']).count()['FIPS']




len(census)


# ###### Load Zillow data: note change for Memphis/Boston



def filter_ZILLOW(df, FIPS):
    if (city_name not in ('Memphis', 'Boston')):
        FIPS_pre = [state+county for county in FIPS]
        df = df[(df['FIPS'].astype(str).str.zfill(11).str[:5].isin(FIPS_pre))].reset_index(drop = True)
    else:
        fips_list = []
        for i in state:
            county = FIPS[str(i)]
            FIPS_pre = [str(i)+county for county in county]         
        df = df[(df['FIPS'].astype(str).str.zfill(11).str[:5].isin(FIPS_pre))].reset_index(drop = True)
    return df


# ==========================================================================
# Begin change
# shifting zillow to 2012 values
# ==========================================================================

### Zillow data
zillow = pd.read_csv(input_path+'Zip_Zhvi_AllHomes.csv', encoding = "ISO-8859-1")
zillow_xwalk = pd.read_csv(input_path+'TRACT_ZIP_032015.csv')

## Compute change over time
zillow['ch_zillow_12_18'] = zillow['2018-01'] - zillow['2012-01']*CPI_12_18
zillow['per_ch_zillow_12_18'] = zillow['ch_zillow_12_18']/zillow['2012-01']
zillow = zillow[zillow['State'].isin(state_init)].reset_index(drop = True)

####### CHANGE HERE: original code commented out below; changed from outer to inner merge

# zillow = zillow_xwalk[['TRACT', 'ZIP', 'RES_RATIO']].merge(zillow[['RegionName', 'ch_zillow_12_18', 'per_ch_zillow_12_18']], left_on = 'ZIP', right_on = 'RegionName', how = 'inner')
zillow = zillow_xwalk[['TRACT', 'ZIP', 'RES_RATIO']].merge(zillow[['RegionName', 'ch_zillow_12_18', 'per_ch_zillow_12_18']], left_on = 'ZIP', right_on = 'RegionName', how = 'outer')
zillow = zillow.rename(columns = {'TRACT':'FIPS'})

# Filter only data of interest
zillow = filter_ZILLOW(zillow, FIPS)

### Keep only data for largest xwalk value, based on residential ratio
zillow = zillow.sort_values(by = ['FIPS', 'RES_RATIO'], ascending = False).groupby('FIPS').first().reset_index(drop = False)

### Compute 90th percentile change in region
percentile_90 = zillow['per_ch_zillow_12_18'].quantile(q = 0.9)
print(percentile_90)

### Create flags
### Change over 50% of change in region
zillow['ab_50pct_ch'] = np.where(zillow['per_ch_zillow_12_18']>0.5, 1, 0)
### Change over 90th percentile change
zillow['ab_90percentile_ch'] = np.where(zillow['per_ch_zillow_12_18']>percentile_90, 1, 0)

census = census.merge(zillow[['FIPS', 'per_ch_zillow_12_18', 'ab_50pct_ch', 'ab_90percentile_ch']], on = 'FIPS')

### Create 90th percentile for rent - 
# census['rent_percentile_90'] = census['pctch_real_mrent_12_18'].quantile(q = 0.9)
census['rent_50pct_ch'] = np.where(census['pctch_real_mrent_12_18']>=0.5, 1, 0)
census['rent_90percentile_ch'] = np.where(census['pctch_real_mrent_12_18']>=0.9, 1, 0)

# census[['rent_90percentile_ch', 'real_mrent_12', 'real_mrent_18']]

# End change
# ==========================================================================

# #### Regional medians

# ==========================================================================
# Begin Change regional median rent for 2012
# ==========================================================================

rm_per_all_li_90 = np.nanmedian(census['per_all_li_90'])
rm_per_all_li_00 = np.nanmedian(census['per_all_li_00'])
rm_per_all_li_18 = np.nanmedian(census['per_all_li_18'])
rm_per_nonwhite_90 = np.nanmedian(census['per_nonwhite_90'])
rm_per_nonwhite_00 = np.nanmedian(census['per_nonwhite_00'])
rm_per_nonwhite_18 = np.nanmedian(census['per_nonwhite_18'])
rm_per_col_90 = np.nanmedian(census['per_col_90'])
rm_per_col_00 = np.nanmedian(census['per_col_00'])
rm_per_col_18 = np.nanmedian(census['per_col_18'])
rm_per_rent_90= np.nanmedian(census['per_rent_90'])
rm_per_rent_00= np.nanmedian(census['per_rent_00'])
rm_per_rent_18= np.nanmedian(census['per_rent_18'])
rm_real_mrent_90 = np.nanmedian(census['real_mrent_90'])
rm_real_mrent_00 = np.nanmedian(census['real_mrent_00'])
rm_real_mrent_12 = np.nanmedian(census['real_mrent_12'])
rm_real_mrent_18 = np.nanmedian(census['real_mrent_18'])
rm_real_mhval_90 = np.nanmedian(census['real_mhval_90'])
rm_real_mhval_00 = np.nanmedian(census['real_mhval_00'])
rm_real_mhval_18 = np.nanmedian(census['real_mhval_18'])
rm_real_hinc_90 = np.nanmedian(census['real_hinc_90'])
rm_real_hinc_00 = np.nanmedian(census['real_hinc_00'])
rm_real_hinc_18 = np.nanmedian(census['real_hinc_18'])
rm_per_units_pre50_18 = np.nanmedian(census['per_units_pre50_18'])
rm_per_ch_zillow_12_18 = np.nanmedian(census['per_ch_zillow_12_18'])
rm_pctch_real_mrent_12_18 = np.nanmedian(census['pctch_real_mrent_12_18'])  

# Above regional median change home value and rent
census['hv_abrm_ch'] = np.where(census['per_ch_zillow_12_18'] > rm_per_ch_zillow_12_18, 1, 0)
census['rent_abrm_ch'] = np.where(census['pctch_real_mrent_12_18'] > rm_pctch_real_mrent_12_18, 1, 0)

# #### Percent changes



census['pctch_real_mhval_90_00'] = (census['real_mhval_00']-census['real_mhval_90'])/census['real_mhval_90']
census['pctch_real_mrent_90_00'] = (census['real_mrent_00']-census['real_mrent_90'])/census['real_mrent_90']
census['pctch_real_hinc_90_00'] = (census['real_hinc_00']-census['real_hinc_90'])/census['real_hinc_90']

census['pctch_real_mhval_00_18'] = (census['real_mhval_18']-census['real_mhval_00'])/census['real_mhval_00']
census['pctch_real_mrent_00_18'] = (census['real_mrent_18']-census['real_mrent_00'])/census['real_mrent_00']
census['pctch_real_mrent_12_18'] = (census['real_mrent_18']-census['real_mrent_12'])/census['real_mrent_12']
census['pctch_real_hinc_00_18'] = (census['real_hinc_18']-census['real_hinc_00'])/census['real_hinc_00']

### Regional Medians
pctch_rm_real_mhval_90_00 = (rm_real_mhval_00-rm_real_mhval_90)/rm_real_mhval_90
pctch_rm_real_mrent_90_00 = (rm_real_mrent_00-rm_real_mrent_90)/rm_real_mrent_90
pctch_rm_real_mhval_00_18 = (rm_real_mhval_18-rm_real_mhval_00)/rm_real_mhval_00
pctch_rm_real_mrent_00_18 = (rm_real_mrent_18-rm_real_mrent_00)/rm_real_mrent_00
pctch_rm_real_mrent_12_18 = (rm_real_mrent_18-rm_real_mrent_12)/rm_real_mrent_12
pctch_rm_real_hinc_90_00 = (rm_real_hinc_00-rm_real_hinc_90)/rm_real_hinc_90
pctch_rm_real_hinc_00_18 = (rm_real_hinc_18-rm_real_hinc_00)/rm_real_hinc_00

# End Change
# ==========================================================================


# #### Absolute changes



census['ch_all_li_count_90_00'] = census['all_li_count_00']-census['all_li_count_90']
census['ch_all_li_count_00_18'] = census['all_li_count_18']-census['all_li_count_00']
census['ch_per_col_90_00'] = census['per_col_00']-census['per_col_90']
census['ch_per_col_00_18'] = census['per_col_18']-census['per_col_00']
census['ch_per_limove_12_18'] = census['per_limove_18'] - census['per_limove_12']

### Regional Medians
ch_rm_per_col_90_00 = rm_per_col_00-rm_per_col_90
ch_rm_per_col_00_18 = rm_per_col_18-rm_per_col_00


# #### Flags



df = census
df['pop00flag'] = np.where(df['pop_00']>500, 1, 0)
df['aboverm_per_all_li_90'] = np.where(df['per_all_li_90']>=rm_per_all_li_90, 1, 0)
df['aboverm_per_all_li_00'] = np.where(df['per_all_li_00']>=rm_per_all_li_00, 1, 0)
df['aboverm_per_all_li_18'] = np.where(df['per_all_li_18']>=rm_per_all_li_18, 1, 0)
df['aboverm_per_nonwhite_18'] = np.where(df['per_nonwhite_18']>=rm_per_nonwhite_18, 1, 0)
df['aboverm_per_nonwhite_90'] = np.where(df['per_nonwhite_90']>=rm_per_nonwhite_90, 1, 0)
df['aboverm_per_nonwhite_00'] = np.where(df['per_nonwhite_00']>=rm_per_nonwhite_00, 1, 0)
df['aboverm_per_rent_90'] = np.where(df['per_rent_90']>=rm_per_rent_90, 1, 0)
df['aboverm_per_rent_00'] = np.where(df['per_rent_00']>=rm_per_rent_00, 1, 0)
df['aboverm_per_rent_18'] = np.where(df['per_rent_18']>=rm_per_rent_18, 1, 0)
df['aboverm_per_col_90'] = np.where(df['per_col_90']>=rm_per_col_90, 1, 0)
df['aboverm_per_col_00'] = np.where(df['per_col_00']>=rm_per_col_00, 1, 0)
df['aboverm_per_col_18'] = np.where(df['per_col_18']>=rm_per_col_18, 1, 0)
df['aboverm_real_mrent_90'] = np.where(df['real_mrent_90']>=rm_real_mrent_90, 1, 0)
df['aboverm_real_mrent_00'] = np.where(df['real_mrent_00']>=rm_real_mrent_00, 1, 0)
df['aboverm_real_mrent_12'] = np.where(df['real_mrent_12']>=rm_real_mrent_12, 1, 0)
df['aboverm_real_mrent_18'] = np.where(df['real_mrent_18']>=rm_real_mrent_18, 1, 0)
df['aboverm_real_mhval_90'] = np.where(df['real_mhval_90']>=rm_real_mhval_90, 1, 0)
df['aboverm_real_mhval_00'] = np.where(df['real_mhval_00']>=rm_real_mhval_00, 1, 0)
df['aboverm_real_mhval_18'] = np.where(df['real_mhval_18']>=rm_real_mhval_18, 1, 0)
df['aboverm_pctch_real_mhval_00_18'] = np.where(df['pctch_real_mhval_00_18']>=pctch_rm_real_mhval_00_18, 1, 0)
df['aboverm_pctch_real_mrent_00_18'] = np.where(df['pctch_real_mrent_00_18']>=pctch_rm_real_mrent_00_18, 1, 0)
df['aboverm_pctch_real_mrent_12_18'] = np.where(df['pctch_real_mrent_12_18']>=pctch_rm_real_mrent_12_18, 1, 0)
df['aboverm_pctch_real_mhval_90_00'] = np.where(df['pctch_real_mhval_90_00']>=pctch_rm_real_mhval_90_00, 1, 0)
df['aboverm_pctch_real_mrent_90_00'] = np.where(df['pctch_real_mrent_90_00']>=pctch_rm_real_mrent_90_00, 1, 0)
df['lostli_00'] = np.where(df['ch_all_li_count_90_00']<0, 1, 0)
df['lostli_18'] = np.where(df['ch_all_li_count_00_18']<0, 1, 0)
df['aboverm_pctch_real_hinc_90_00'] = np.where(df['pctch_real_hinc_90_00']>pctch_rm_real_hinc_90_00, 1, 0)
df['aboverm_pctch_real_hinc_00_18'] = np.where(df['pctch_real_hinc_00_18']>pctch_rm_real_hinc_00_18, 1, 0)
df['aboverm_ch_per_col_90_00'] = np.where(df['ch_per_col_90_00']>ch_rm_per_col_90_00, 1, 0)
df['aboverm_ch_per_col_00_18'] = np.where(df['ch_per_col_00_18']>ch_rm_per_col_00_18, 1, 0)
df['aboverm_per_units_pre50_18'] = np.where(df['per_units_pre50_18']>rm_per_units_pre50_18, 1, 0)


# ### Spatial Analysis Variables



### Filter only census tracts of interest from shp
census_tract_list = census['FIPS'].astype(str).str.zfill(11)
city_shp = city_shp[city_shp['GEOID'].isin(census_tract_list)].reset_index(drop = True)

# Create subset of points for faster running
### Create single region polygon
city_poly = city_shp.dissolve(by = 'STATEFP')
city_poly = city_poly.reset_index(drop = True)




census_tract_list.describe()


# ###### Rail



### Filter only existing rail
rail = rail[rail['Year Opened']=='Pre-2000'].reset_index(drop = True)
# rail.Agency.unique()
### Filter by city
rail = rail[rail['Agency'].isin(rail_agency)].reset_index(drop = True)
rail = gpd.GeoDataFrame(rail, geometry=[Point(xy) for xy in zip (rail['Longitude'], rail['Latitude'])])




### check whether census tract contains rail station
### and create rail flag

### Create half mile buffer

### sets coordinate system to WGS84
rail.crs = {'init' :'epsg:4269'}

### creates UTM projection
### zone is defined under define city specific variables
projection = '+proj=utm +zone='+zone+', +ellps=WGS84 +datum=WGS84 +units=m +no_defs'

### project to UTM coordinate system
rail_proj = rail.to_crs(projection)

### create buffer around anchor institution in meters
rail_buffer = rail_proj.buffer(804.672)

### convert buffer back to WGS84
rail_buffer_wgs = rail_buffer.to_crs(epsg=4326)

### crate flag
city_shp['rail'] = np.where(city_shp.intersects(rail_buffer_wgs.unary_union) == True, 1, 0)




# if city_name != 'Memphis':
    # ax = city_shp.plot('rail')
    # rail.plot(ax = ax, color = 'red')
    # plt.show()


# ###### Anchor institution



### Hospitals
#hospitals = pd.read_csv(input_path+'Hospitals.csv')

### Universities
#university = pd.read_csv(input_path+'university_HD2016.csv')




### Filter for state of interest
#hospitals = hospitals[hospitals['STATE'].isin(state_init)]




### Convert to geodataframe
#hospitals = gpd.GeoDataFrame(hospitals, geometry=[Point(xy) for xy in zip (hospitals['X'], hospitals['Y'])])

### Filter to hospitals with 100+ beds
#hosp_type = ["GENERAL MEDICAL AND SURGICAL HOSPITALS", "CHILDREN'S HOSPITALS, GENERAL"]
#hospitals = hospitals[hospitals['NAICS_DESC'].isin(hosp_type)]
#hospitals = hospitals[['geometry']]
#hospitals = hospitals.reset_index(drop = True)




### Filter for state of interest
#university = university[university['STABBR'].isin(state_init)]
    
### Convert to geodataframe
#university = gpd.GeoDataFrame(university, geometry=[Point(xy) for xy in zip (university['LONGITUD'], university['LATITUDE'])])

### Filter by institution size
#university = university[university['INSTSIZE']>1].reset_index(drop = True)

### Keep only geometry type
#university = university[['geometry']]




### Keep only records within shapefile
### this step optimizes the flagging of census tracts that contain the point of interest

### Hospitals
#hospitals = hospitals[hospitals['geometry'].within(city_poly.loc[0, 'geometry'])].reset_index(drop = True)

### Universities
#university = university[university['geometry'].within(city_poly.loc[0, 'geometry'])].reset_index(drop = True)




### Create anchor institution variable
#anchor_institutions = university.append(hospitals).reset_index(drop = True)




### Create half mile buffer

### sets coordinate system to WGS84
#anchor_institutions.crs = {'init' :'epsg:4326'}

### creates UTM projection
### zone is defined under define city specific variables
#projection = '+proj=utm +zone='+zone+', +ellps=WGS84 +datum=WGS84 +units=m +no_defs'

### project to UTM coordinate system
#anchor_institutions_proj = anchor_institutions.to_crs(projection)

### create buffer around anchor institution in meters
#anchor_institutions_buffer = anchor_institutions_proj.buffer(804.672)

### convert buffer back to WGS84
#anchor_institutions_buffer_wgs = anchor_institutions_buffer.to_crs(epsg=4326)




### check whether census tract contains hospital station
### and create anchor institution flag
#city_shp['anchor_institution'] = city_shp.intersects(anchor_institutions_buffer_wgs.unary_union)




# ax = city_shp.plot(column = 'anchor_institution')
# anchor_institutions_buffer_wgs.plot(ax = ax)
# plt.show()


# ###### Subsidized housing



### LIHTC
lihtc = pd.read_csv(input_path+'LowIncome_Housing_Tax_Credit_Properties.csv')

### Public housing
pub_hous = pd.read_csv(input_path+'Public_Housing_Buildings.csv.gz')




# Convert to geodataframe
lihtc = gpd.GeoDataFrame(lihtc, geometry=[Point(xy) for xy in zip (lihtc['X'], lihtc['Y'])])
pub_hous = gpd.GeoDataFrame(pub_hous, geometry=[Point(xy) for xy in zip (pub_hous['X'], pub_hous['Y'])])

### Clip point to only region of interest
### LIHTC
lihtc = lihtc[lihtc['geometry'].within(city_poly.loc[0, 'geometry'])].reset_index(drop = True)

### Public housing
pub_hous = pub_hous[pub_hous['geometry'].within(city_poly.loc[0, 'geometry'])].reset_index(drop = True)

### merge datasets
presence_ph_LIHTC = lihtc[['geometry']].append(pub_hous[['geometry']])




### check whether census tract contains public housing or LIHTC station
### and create public housing flag
city_shp['presence_ph_LIHTC'] = city_shp.intersects(presence_ph_LIHTC.unary_union)




# ax = city_shp.plot(color = 'grey')
# city_shp.plot(ax = ax, column = 'presence_ph_LIHTC')
# presence_ph_LIHTC.plot(ax = ax)
# plt.show()




city_shp['GEOID'] = city_shp['GEOID'].astype('int64')




census = census.merge(city_shp[['GEOID','geometry','rail', 
	# 'anchor_institution', 
	'presence_ph_LIHTC']], right_on = 'GEOID', left_on = 'FIPS')


# ### Export csv file



census.to_csv(output_path+city_name+'_database.csv')
# pq.write_table(output_path+city_name+'_database.parquet')
