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


# ### Set API key



key = '4c26aa6ebbaef54a55d3903212eabbb506ade381'
c = census.Census(key)


# ### Choose city and census tracts of interest



city_name = 'Atlanta'
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
    FIPS = ['037']

else:
    print ('There is not information for the selected city')




if city_name != 'Memphis':
    sql_query='state:{} county:*'.format(state)
else:
    sql_query_1='state:{} county:*'.format(state[0])
    sql_query_2='state:{} county:*'.format(state[1])


# ### Creates filter function
# Note - Memphis is different bc it's located in 2 states



def filter_FIPS(df):
    if city_name != 'Memphis':
        df = df[df['county'].isin(FIPS)]

    else:
        fips_list = []
        for i in state:
            county = FIPS[i]
            a = list((df['FIPS'][(df['county'].isin(county))&(df['state']==i)]))
            fips_list = fips_list + a
        df = df[df['FIPS'].isin(fips_list)]
    return df


# ### Download ACS 2017 5-Year Estimates



df_vars_17=['B03002_001E',
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
df_vars_17 = df_vars_17 + var_list

# Migration - see notes
var_str = 'B07010'
var_list = []
for i in list(range(25,34))+list(range(36, 45))+list(range(47, 56))+list(range(58, 67)):
    var_list.append(var_str+'_'+str(i).zfill(3)+'E')
df_vars_17 = df_vars_17 + var_list


# #### Run API query
# NOTE: Memphis is located in two states so the query looks different



if city_name != 'Memphis':
    var_dict_acs5 = c.acs5.get(df_vars_17, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2017)
else:
    var_dict_1 = c.acs5.get(df_vars_17, geo = {'for': 'tract:*',
                                 'in': sql_query_1} , year=2017)
    var_dict_2 = (c.acs5.get(df_vars_17, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2017))
    var_dict_acs5 = var_dict_1+var_dict_2


# #### Converts variables into dataframe and filters only FIPS of interest



df_vars_17 = pd.DataFrame.from_dict(var_dict_acs5)
df_vars_17['FIPS']=df_vars_17['state']+df_vars_17['county']+df_vars_17['tract']
df_vars_17 = filter_FIPS(df_vars_17)


# #### Renames variables



df_vars_17 = df_vars_17.rename(columns = {'B03002_001E':'pop_17',
                                          'B03002_003E':'white_17',
                                          'B19001_001E':'hh_17',
                                          'B19013_001E':'hinc_17',
                                          'B25077_001E':'mhval_17',
                                          'B25077_001M':'mhval_17_se',
                                          'B25064_001E':'mrent_17',
                                          'B25064_001M':'mrent_17_se',
                                          'B25003_002E':'ohu_17',
                                          'B25003_003E':'rhu_17',
                                          'B25105_001E':'mmhcosts_17',
                                          'B15003_001E':'total_25_17',
                                          'B15003_022E':'total_25_col_bd_17',
                                          'B15003_023E':'total_25_col_md_17',
                                          'B15003_024E':'total_25_col_pd_17',
                                          'B15003_025E':'total_25_col_phd_17',
                                          'B25034_001E':'tot_units_built_17',
                                          'B25034_010E':'units_40_49_built_17',
                                          'B25034_011E':'units_39_early_built_17',
                                          'B07010_025E':'mov_wc_w_income_17',
                                          'B07010_026E':'mov_wc_9000_17',
                                          'B07010_027E':'mov_wc_15000_17',
                                          'B07010_028E':'mov_wc_25000_17',
                                          'B07010_029E':'mov_wc_35000_17',
                                          'B07010_030E':'mov_wc_50000_17',
                                          'B07010_031E':'mov_wc_65000_17',
                                          'B07010_032E':'mov_wc_75000_17',
                                          'B07010_033E':'mov_wc_76000_more_17',
                                          'B07010_036E':'mov_oc_w_income_17',
                                          'B07010_037E':'mov_oc_9000_17',
                                          'B07010_038E':'mov_oc_15000_17',
                                          'B07010_039E':'mov_oc_25000_17',
                                          'B07010_040E':'mov_oc_35000_17',
                                          'B07010_041E':'mov_oc_50000_17',
                                          'B07010_042E':'mov_oc_65000_17',
                                          'B07010_043E':'mov_oc_75000_17',
                                          'B07010_044E':'mov_oc_76000_more_17',
                                          'B07010_047E':'mov_os_w_income_17',
                                          'B07010_048E':'mov_os_9000_17',
                                          'B07010_049E':'mov_os_15000_17',
                                          'B07010_050E':'mov_os_25000_17',
                                          'B07010_051E':'mov_os_35000_17',
                                          'B07010_052E':'mov_os_50000_17',
                                          'B07010_053E':'mov_os_65000_17',
                                          'B07010_054E':'mov_os_75000_17',
                                          'B07010_055E':'mov_os_76000_more_17',
                                          'B07010_058E':'mov_fa_w_income_17',
                                          'B07010_059E':'mov_fa_9000_17',
                                          'B07010_060E':'mov_fa_15000_17',
                                          'B07010_061E':'mov_fa_25000_17',
                                          'B07010_062E':'mov_fa_35000_17',
                                          'B07010_063E':'mov_fa_50000_17',
                                          'B07010_064E':'mov_fa_65000_17',
                                          'B07010_065E':'mov_fa_75000_17',
                                          'B07010_066E':'mov_fa_76000_more_17',
                                          'B06011_001E':'iinc_17',
                                          'B19001_002E':'I_10000_17',
                                          'B19001_003E':'I_15000_17',
                                          'B19001_004E':'I_20000_17',
                                          'B19001_005E':'I_25000_17',
                                          'B19001_006E':'I_30000_17',
                                          'B19001_007E':'I_35000_17',
                                          'B19001_008E':'I_40000_17',
                                          'B19001_009E':'I_45000_17',
                                          'B19001_010E':'I_50000_17',
                                          'B19001_011E':'I_60000_17',
                                          'B19001_012E':'I_75000_17',
                                          'B19001_013E':'I_100000_17',
                                          'B19001_014E':'I_125000_17',
                                          'B19001_015E':'I_150000_17',
                                          'B19001_016E':'I_200000_17',
                                          'B19001_017E':'I_201000_17'})


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



if city_name != 'Memphis':
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



# SF1
if city_name != 'Memphis':
    var_dict_sf1 = c.sf1.get(var_sf1, geo = {'for': 'tract:*',
                                 'in': sql_query}, year=2000)
else:
    var_dict_1 = c.sf1.get(var_sf1, geo = {'for': 'tract:*',
                                 'in': sql_query_1}, year=2000)
    var_dict_2 = (c.sf1.get(var_sf1, geo = {'for': 'tract:*',
                                 'in': sql_query_2}, year=2000))
    var_dict_sf1 = var_dict_1+var_dict_2
    
# SF3
if city_name != 'Memphis':
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



# SF1 - All of the variables are found in the SF3
# SF3
if city_name != 'Memphis':
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



# Merge 2010 & 2017 files - same geometry
# df_vars_summ = df_vars_17.merge(df_vars_10, on = 'FIPS').merge(df_vars_12, on ='FIPS')
df_vars_summ = df_vars_17.merge(df_vars_12, on ='FIPS')

#Export files to CSV
df_vars_summ.to_csv('~/git/sparcc/data/'+city_name+'census_summ.csv')
df_vars_90.to_csv('~/git/sparcc/data/'+city_name+'census_90.csv')
df_vars_00.to_csv('~/git/sparcc/data/'+city_name+'census_00.csv')


# ==========================================================================
# ==========================================================================
# ==========================================================================
# Crosswalk Files
# ==========================================================================
# ==========================================================================
# ==========================================================================

# ### Read files
# 
# Most of the input files are located on google drive and . I suggest downloading [Google's Drive File Stream](https://support.google.com/a/answer/7491144?utm_medium=et&utm_source=aboutdrive&utm_content=getstarted&utm_campaign=en_us) app, which doesn't download all Google Drive items to your computer, but rather pulls them as necessary. This will save a lot of space but compromises speed. 



# Data files

# Google File Drive Stream pathway for a mac. 
input_path = '~/git/sparcc/data/inputs/'
output_path = '~/git/sparcc/data/'

census_90 = pd.read_csv(output_path+city_name+'census_90.csv', index_col = 0)
census_00 = pd.read_csv(output_path+city_name+'census_00.csv', index_col = 0)

# Crosswalk files
xwalk_90_10 = pd.read_csv(input_path+'crosswalk_1990_2010.csv')
xwalk_00_10 = pd.read_csv(input_path+'crosswalk_2000_2010.csv')


# ### Choose city and census tracts of interest



#add elif for your city here

if city_name == 'Chicago':
    state = '17'
    FIPS = ['031', '043', '089', '093', '097', '111', '197']

elif city_name == 'Atlanta':
    state = '13'
    FIPS = ['057', '063', '067', '089', '097', '113', '121', '135', '151', '247']
# add an LA elif    
elif city_name == 'Denver':
    state = '08'
    FIPS = ['001', '005', '013', '014', '019', '031', '035', '047', '059']
    
elif city_name == 'Memphis':
    state = ['28', '47']
    FIPS = {'28':['033', '093'], '47': ['047', '157']}
    
elif city_name == 'Los Angeles':
    state = '06'
    FIPS = ['037']

else:
    print ('There is no information for the selected city')


# ### Creates filter function
# Note - Memphis is different bc it's located in 2 states



def filter_FIPS(df):
    if city_name != 'Memphis':
        df = df[df['county'].isin(FIPS)].reset_index(drop = True)

    else:
        fips_list = []
        for i in state:
            county = FIPS[i]
            a = list((df['FIPS'][(df['county'].isin(county))&(df['state']==i)]))
            fips_list = fips_list + a
        df = df[df['FIPS'].isin(fips_list)].reset_index(drop = True)
    return df


# ### Creates crosswalking function



def crosswalk_files (df, xwalk, counts, medians, df_fips_base, xwalk_fips_base, xwalk_fips_horizon):

    # merge dataframe with xwalk file
    df_merge = df.merge(xwalk[['weight', xwalk_fips_base, xwalk_fips_horizon]], left_on = df_fips_base, right_on = xwalk_fips_base, how='left')                             

    df = df_merge
    
    # apply interpolation weight
    new_var_list = list(counts)+(medians)
    for var in new_var_list:
        df[var] = df[var]*df['weight']

    # aggregate by horizon census tracts fips
    df = df.groupby(xwalk_fips_horizon).sum().reset_index()
    
    # rename trtid10 to FIPS & FIPS to trtid_base
    df = df.rename(columns = {'FIPS':'trtid_base',
                              'trtid10':'FIPS'})
    
    # fix state, county and fips code
    df ['state'] = df['FIPS'].astype('int64').astype(str).str.zfill(11).str[0:2]
    df ['county'] = df['FIPS'].astype('int64').astype(str).str.zfill(11).str[2:5]
    df ['tract'] = df['FIPS'].astype('int64').astype(str).str.zfill(11).str[5:]
    
    # drop weight column
    df = df.drop(columns = ['weight'])
    
    return df


# ### Crosswalking

# ###### 1990 Census Data



counts = census_90.columns.drop(['county', 'state', 'tract', 'mrent_90', 'mhval_90', 'hinc_90', 'FIPS'])
medians = ['mrent_90', 'mhval_90', 'hinc_90']
df_fips_base = 'FIPS'
xwalk_fips_base = 'trtid90'
xwalk_fips_horizon = 'trtid10'
census_90_xwalked = crosswalk_files (census_90, xwalk_90_10,  counts, medians, df_fips_base, xwalk_fips_base, xwalk_fips_horizon )


# ###### 2000 Census Data



counts = census_00.columns.drop(['county', 'state', 'tract', 'mrent_00', 'mhval_00', 'hinc_00', 'FIPS'])
medians = ['mrent_00', 'mhval_00', 'hinc_00']
df_fips_base = 'FIPS'
xwalk_fips_base = 'trtid00'
xwalk_fips_horizon = 'trtid10'
census_00_xwalked = crosswalk_files (census_00, xwalk_00_10,  counts, medians, df_fips_base, xwalk_fips_base, xwalk_fips_horizon )


# ###### Filters and exports data



census_90_filtered = filter_FIPS(census_90_xwalked)
census_00_filtered = filter_FIPS(census_00_xwalked)




census_90_filtered.to_csv('~/git/sparcc/data/'+city_name+'census_90_10.csv')
census_00_filtered.to_csv('~/git/sparcc/data/'+city_name+'census_00_10.csv')


# ==========================================================================
# ==========================================================================
# ==========================================================================
# Variable Creation
# ==========================================================================
# ==========================================================================
# ==========================================================================

import geopandas as gpd
from shapely.geometry import Point
from pyproj import Proj
import matplotlib.pyplot as plt

# Below is the Google File Drive Stream pathway for a mac. 
input_path = '/Volumes/GoogleDrive/My Drive/Data/Inputs/'
output_path = '~/git/sparcc/data/'
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
#https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.2017.html
if city_name == 'Memphis':
    shp_name = 'cb_2017_47_tract_500k.shp'
elif city_name == 'Chicago':
    shp_name = 'cb_2017_17_tract_500k.shp'
elif city_name == 'Atlanta':
    shp_name = 'cb_2017_13_tract_500k.shp'
elif city_name == 'Denver':
    shp_name = 'cb_2017_08_tract_500k.shp'
elif city_name == 'Los Angeles':
    shp_name = 'cb_2017_06_tract_500k.shp'
city_shp = gpd.read_file(shp_folder+shp_name)


# ### Choose city and define city specific variables



if city_name == 'Chicago':
    state = '17'
    state_init = ['IL']
    FIPS = ['031', '043', '089', '093', '097', '111', '197']
    rail_agency = 'CTA'
    zone = '16T'
    
# Add elif for your city here
elif city_name == 'Atlanta':
    state = '13'
    state_init = ['GA']
    FIPS = ['057', '063', '067', '089', '097', '113', '121', '135', '151', '247']
    rail_agency = 'MARTA'
    zone = '16S'
    
elif city_name == 'Denver':
    state = '08'
    state_init = ['CO']
    FIPS = ['001', '005', '013', '014', '019', '031', '035', '047', '059']
    rail_agency = 'RTD'
    zone = '13S'
    
elif city_name == 'Memphis':
    state = ['28', '47']
    state_init = ['MS', 'TN']
    FIPS = {'28':['033', '093'], '47': ['047', '157']}
    rail_agency = np.nan
    zone = '15S'
    
elif city_name == 'Los Angeles':
    state = '06'
    state_init = ['CA']
    FIPS = ['037']
    rail_agency = 'Metro'
    zone = '11S'
    
else:
    print ('There is no information for the selected city')


# ### Merge census data in single file



census = acs_data.merge(data_2000, on = 'FIPS', how = 'outer').merge(data_1990, on = 'FIPS', how = 'outer')


# ### Compute census variables

# #### CPI indexing values



### This is based on the yearly CPI average
CPI_89_17 = 1.977
CPI_99_17 = 1.472

### This is used for the Zillow data, where january values are compared
CPI_0115_0119 = 1.077


# #### Income



census['hinc_17'][census['hinc_17']<0]=np.nan
census['hinc_00'][census['hinc_00']<0]=np.nan
census['hinc_90'][census['hinc_90']<0]=np.nan




### These are not indexed
rm_hinc_17 = np.nanmedian(census['hinc_17'])
rm_hinc_00 = np.nanmedian(census['hinc_00'])
rm_hinc_90 = np.nanmedian(census['hinc_90'])

rm_iinc_17 = np.nanmedian(census['iinc_17'])
rm_iinc_12 = np.nanmedian(census['iinc_12'])

print(rm_hinc_17, rm_hinc_00, rm_hinc_90, rm_iinc_17, rm_iinc_12)




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




census = income_interpolation (census, '17', 0.8, rm_hinc_17, 'hh_17', 'I', 'inc')
census =income_interpolation (census, '17', 1.2, rm_hinc_17, 'hh_17', 'I', 'inc')
census = income_interpolation (census, '00', 0.8, rm_hinc_00, 'hh_00', 'I', 'inc')
census =income_interpolation (census, '00', 1.2, rm_hinc_00, 'hh_00', 'I', 'inc')
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




census = income_categories(census, '17', rm_hinc_17, 'hinc_17')
census = income_categories(census, '00', rm_hinc_00, 'hinc_00')




census.groupby('inc_cat_medhhinc_00').count()['FIPS']




census.groupby('inc_cat_medhhinc_17').count()['FIPS']




### Percentage & total low-income households - under 80% AMI
census ['per_all_li_90'] = census['inc80_90']
census ['per_all_li_00'] = census['inc80_00']
census ['per_all_li_17'] = census['inc80_17']

census['all_li_count_90'] = census['per_all_li_90']*census['hh_90']
census['all_li_count_00'] = census['per_all_li_00']*census['hh_00']
census['all_li_count_17'] = census['per_all_li_17']*census['hh_17']




len(census)


# #### Index all values to 2017



census['real_mhval_90'] = census['mhval_90']*CPI_89_17
census['real_mrent_90'] = census['mrent_90']*CPI_89_17
census['real_hinc_90'] = census['hinc_90']*CPI_89_17

census['real_mhval_00'] = census['mhval_00']*CPI_99_17
census['real_mrent_00'] = census['mrent_00']*CPI_99_17
census['real_hinc_00'] = census['hinc_00']*CPI_99_17

census['real_mhval_17'] = census['mhval_17']
census['real_mrent_17'] = census['mrent_17']
census['real_hinc_17'] = census['hinc_17']


# #### Demographics



df = census

### % of non-white

###
df['per_nonwhite_17'] = 1 - df['white_17']/df['pop_17']

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

### 2017
df['hu_17'] = df['ohu_17']+df['rhu_17']
df['per_rent_17'] = df['rhu_17']/df['hu_17']


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

### 2017
df['per_col_17'] = (df['total_25_col_bd_17']+
                    df['total_25_col_md_17']+
                    df['total_25_col_pd_17']+
                    df['total_25_col_phd_17'])/df['total_25_17']

### Housing units built
df['per_units_pre50_17'] = (df['units_40_49_built_17']+df['units_39_early_built_17'])/df['tot_units_built_17']


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




census = income_interpolation_movein (census, '17', 0.8, rm_iinc_17)
census = income_interpolation_movein (census, '12', 0.8, rm_iinc_12)




len(census)


# #### Housing Affordability



def filter_PUMS(df, FIPS):
    if city_name != 'Memphis':
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




pums = pums.rename(columns = {"AH5QE002":"rhu_17_wcash",
                                "AH5QE003":"R_100_17",
                                "AH5QE004":"R_150_17",
                                "AH5QE005":"R_200_17",
                                "AH5QE006":"R_250_17",
                                "AH5QE007":"R_300_17",
                                "AH5QE008":"R_350_17",
                                "AH5QE009":"R_400_17",
                                "AH5QE010":"R_450_17",
                                "AH5QE011":"R_500_17",
                                "AH5QE012":"R_550_17",
                                "AH5QE013":"R_600_17",
                                "AH5QE014":"R_650_17",
                                "AH5QE015":"R_700_17",
                                "AH5QE016":"R_750_17",
                                "AH5QE017":"R_800_17",
                                "AH5QE018":"R_900_17",
                                "AH5QE019":"R_1000_17",
                                "AH5QE020":"R_1250_17",
                                "AH5QE021":"R_1500_17",
                                "AH5QE022":"R_2000_17",
                                "AH5QE023":"R_2500_17",
                                "AH5QE024":"R_3000_17",
                                "AH5QE025":"R_3500_17",
                                "AH5QE026":"R_3600_17",
                                "AH5QE027":"rhu_17_wocash",
                                "AIMUE001":"ohu_tot_17",
                                "AIMUE002":"O_200_17",
                                "AIMUE003":"O_300_17",
                                "AIMUE004":"O_400_17",
                                "AIMUE005":"O_500_17",
                                "AIMUE006":"O_600_17",
                                "AIMUE007":"O_700_17",
                                "AIMUE008":"O_800_17",
                                "AIMUE009":"O_900_17",
                                "AIMUE010":"O_1000_17",
                                "AIMUE011":"O_1250_17",
                                "AIMUE012":"O_1500_17",
                                "AIMUE013":"O_2000_17",
                                "AIMUE014":"O_2500_17",
                                "AIMUE015":"O_3000_17",
                                "AIMUE016":"O_3500_17",
                                "AIMUE017":"O_4000_17",
                                "AIMUE018":"O_4100_17"})




aff_17 = rm_hinc_17*0.3/12
pums = income_interpolation (pums, '17', 0.6, aff_17, 'rhu_17_wcash', 'R', 'rent')
pums = income_interpolation (pums, '17', 1.2, aff_17, 'rhu_17_wcash', 'R', 'rent')

pums = income_interpolation (pums, '17', 0.6, aff_17, 'ohu_tot_17', 'O', 'own')
pums = income_interpolation (pums, '17', 1.2, aff_17, 'ohu_tot_17', 'O', 'own')




pums['FIPS'] = pums['FIPS'].astype(float).astype('int64')
pums = pums.merge(census[['FIPS', 'mmhcosts_17']], on = 'FIPS')

pums['rlow_17'] = pums['rent60_17']*pums['rhu_17_wcash']+pums['rhu_17_wocash'] ### includes no cash rent
pums['rmod_17'] = pums['rent120_17']*pums['rhu_17_wcash']-pums['rent60_17']*pums['rhu_17_wcash']
pums['rhigh_17'] = pums['rhu_17_wcash']-pums['rent120_17']*pums['rhu_17_wcash']

pums['olow_17'] = pums['own60_17']*pums['ohu_tot_17']
pums['omod_17'] = pums['own120_17']*pums['ohu_tot_17'] - pums['own60_17']*pums['ohu_tot_17']
pums['ohigh_17'] = pums['ohu_tot_17'] - pums['own120_17']*pums['ohu_tot_17']

pums['hu_tot_17'] = pums['rhu_17_wcash']+pums['rhu_17_wocash']+pums['ohu_tot_17']

pums['low_tot_17'] = pums['rlow_17']+pums['olow_17']
pums['mod_tot_17'] = pums['rmod_17']+pums['omod_17']
pums['high_tot_17'] = pums['rhigh_17']+pums['ohigh_17']

pums['pct_low_17'] = pums['low_tot_17']/pums['hu_tot_17']
pums['pct_mod_17'] = pums['mod_tot_17']/pums['hu_tot_17']
pums['pct_high_17'] = pums['high_tot_17']/pums['hu_tot_17']


### Low income
pums['predominantly_LI'] = np.where((pums['pct_low_17']>=0.55)&
                                       (pums['pct_mod_17']<0.45)&
                                       (pums['pct_high_17']<0.45),1,0)

## High income
pums['predominantly_HI'] = np.where((pums['pct_low_17']<0.45)&
                                       (pums['pct_mod_17']<0.45)&
                                       (pums['pct_high_17']>=0.55),1,0)

### Moderate income
pums['predominantly_MI'] = np.where((pums['pct_low_17']<0.45)&
                                       (pums['pct_mod_17']>=0.55)&
                                       (pums['pct_high_17']<0.45),1,0)

### Mixed-Low income
pums['mixed_low'] = np.where((pums['predominantly_LI']==0)&
                              (pums['predominantly_MI']==0)&
                              (pums['predominantly_HI']==0)&
                              (pums['mmhcosts_17']<aff_17*0.6),1,0)

### Mixed-Moderate income
pums['mixed_mod'] = np.where((pums['predominantly_LI']==0)&
                              (pums['predominantly_MI']==0)&
                              (pums['predominantly_HI']==0)&
                              (pums['mmhcosts_17']>=aff_17*0.6)&
                              (pums['mmhcosts_17']<aff_17*1.2),1,0)

### Mixed-High income
pums['mixed_high'] = np.where((pums['predominantly_LI']==0)&
                              (pums['predominantly_MI']==0)&
                              (pums['predominantly_HI']==0)&
                              (pums['mmhcosts_17']>=aff_17*1.2),1,0)

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



census['pctch_real_mhval_00_17'] = (census['real_mhval_17']-census['real_mhval_00'])/census['real_mhval_00']
census['pctch_real_mrent_00_17'] = (census['real_mrent_17']-census['real_mrent_00'])/census['real_mrent_00']

rm_pctch_real_mhval_00_17_increase=np.nanmedian(census['pctch_real_mhval_00_17'][census['pctch_real_mhval_00_17']>0.05])
rm_pctch_real_mrent_00_17_increase=np.nanmedian(census['pctch_real_mrent_00_17'][census['pctch_real_mrent_00_17']>0.05])

# rm_pctch_real_mhval_00_17_increase=np.nanmedian(census['pctch_real_mhval_00_17'])
# rm_pctch_real_mrent_00_17_increase=np.nanmedian(census['pctch_real_mrent_00_17'])




census['rent_decrease'] = np.where((census['pctch_real_mrent_00_17']<=-0.05), 1, 0)

census['rent_marginal'] = np.where((census['pctch_real_mrent_00_17']>-0.05)&
                                          (census['pctch_real_mrent_00_17']<0.05), 1, 0)

census['rent_increase'] = np.where((census['pctch_real_mrent_00_17']>=0.05)&
                                          (census['pctch_real_mrent_00_17']<rm_pctch_real_mrent_00_17_increase), 1, 0)

census['rent_rapid_increase'] = np.where((census['pctch_real_mrent_00_17']>=0.05)&
                                          (census['pctch_real_mrent_00_17']>=rm_pctch_real_mrent_00_17_increase), 1, 0)


census['house_decrease'] = np.where((census['pctch_real_mhval_00_17']<=-0.05), 1, 0)

census['house_marginal'] = np.where((census['pctch_real_mhval_00_17']>-0.05)&
                                          (census['pctch_real_mhval_00_17']<0.05), 1, 0)

census['house_increase'] = np.where((census['pctch_real_mhval_00_17']>=0.05)&
                                          (census['pctch_real_mhval_00_17']<rm_pctch_real_mhval_00_17_increase), 1, 0)

census['house_rapid_increase'] = np.where((census['pctch_real_mhval_00_17']>=0.05)&
                                          (census['pctch_real_mhval_00_17']>=rm_pctch_real_mhval_00_17_increase), 1, 0)

census['tot_decrease'] = np.where((census['rent_decrease']==1)|(census['house_decrease']), 1, 0)
census['tot_marginal'] = np.where((census['rent_marginal']==1)|(census['house_marginal']), 1, 0)
census['tot_increase'] = np.where((census['rent_increase']==1)|(census['house_increase']), 1, 0)
census['tot_rapid_increase'] = np.where((census['rent_rapid_increase']==1)|(census['house_rapid_increase']), 1, 0)

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


# ###### Load Zillow data



def filter_ZILLOW(df, FIPS):
    if city_name != 'Memphis':
        FIPS_pre = [state+county for county in FIPS]
        df = df[(df['FIPS'].astype(str).str.zfill(11).str[:5].isin(FIPS_pre))].reset_index(drop = True)

    else:
        fips_list = []
        for i in state:
            county = FIPS[str(i)]
            FIPS_pre = [str(i)+county for county in county]         
        df = df[(df['FIPS'].astype(str).str.zfill(11).str[:5].isin(FIPS_pre))].reset_index(drop = True)
    return df




### Zillow data
zillow = pd.read_csv(input_path+'Zip_Zhvi_AllHomes.csv', encoding = "ISO-8859-1")
zillow_xwalk = pd.read_csv(input_path+'TRACT_ZIP_032015.csv')

## Compute change over time
zillow['ch_zillow_15_19'] = zillow['2019-01'] - zillow['2015-01']*CPI_0115_0119
zillow['per_ch_zillow_15_19'] = zillow['ch_zillow_15_19']/zillow['2015-01']
zillow = zillow[zillow['State'].isin(state_init)].reset_index(drop = True)

####### CHANGE HERE: original code commented out below; changed from outer to inner merge

zillow = zillow_xwalk[['TRACT', 'ZIP', 'RES_RATIO']].merge(zillow[['RegionName', 'ch_zillow_15_19', 'per_ch_zillow_15_19']], left_on = 'ZIP', right_on = 'RegionName', how = 'outer')
#zillow = zillow_xwalk[['TRACT', 'ZIP', 'RES_RATIO']].merge(zillow[['RegionName', 'ch_zillow_15_19', 'per_ch_zillow_15_19']], left_on = 'ZIP', right_on = 'RegionName', how = 'inner')
zillow = zillow.rename(columns = {'TRACT':'FIPS'})

# Filter only data of interest
zillow = filter_ZILLOW(zillow, FIPS)

### Keep only data for largest xwalk value, based on residential ratio
zillow = zillow.sort_values(by = ['FIPS', 'RES_RATIO'], ascending = False).groupby('FIPS').first().reset_index(drop = False)

### Compute 90th percentile change in region
percentile_90 = zillow['per_ch_zillow_15_19'].quantile(q = 0.9)
print(percentile_90)

### Create flags
### Change over 50% of change in region
zillow['ab_50pct_ch'] = np.where(zillow['per_ch_zillow_15_19']>0.5, 1, 0)
### Change over 90th percentile change
zillow['ab_90percentile_ch'] = np.where(zillow['per_ch_zillow_15_19']>percentile_90, 1, 0)




census = census.merge(zillow[['FIPS', 'ab_50pct_ch', 'ab_90percentile_ch']], on = 'FIPS')


# #### Regional medians



rm_per_all_li_90 = np.nanmedian(census['per_all_li_90'])
rm_per_all_li_00 = np.nanmedian(census['per_all_li_00'])
rm_per_all_li_17 = np.nanmedian(census['per_all_li_17'])
rm_per_nonwhite_90 = np.nanmedian(census['per_nonwhite_90'])
rm_per_nonwhite_00 = np.nanmedian(census['per_nonwhite_00'])
rm_per_nonwhite_17 = np.nanmedian(census['per_nonwhite_17'])
rm_per_col_90 = np.nanmedian(census['per_col_90'])
rm_per_col_00 = np.nanmedian(census['per_col_00'])
rm_per_col_17 = np.nanmedian(census['per_col_17'])
rm_per_rent_90= np.nanmedian(census['per_rent_90'])
rm_per_rent_00= np.nanmedian(census['per_rent_00'])
rm_per_rent_17= np.nanmedian(census['per_rent_17'])
rm_real_mrent_90 = np.nanmedian(census['real_mrent_90'])
rm_real_mrent_00 = np.nanmedian(census['real_mrent_00'])
rm_real_mrent_17 = np.nanmedian(census['real_mrent_17'])
rm_real_mhval_90 = np.nanmedian(census['real_mhval_90'])
rm_real_mhval_00 = np.nanmedian(census['real_mhval_00'])
rm_real_mhval_17 = np.nanmedian(census['real_mhval_17'])
rm_real_hinc_90 = np.nanmedian(census['real_hinc_90'])
rm_real_hinc_00 = np.nanmedian(census['real_hinc_00'])
rm_real_hinc_17 = np.nanmedian(census['real_hinc_17'])
rm_per_units_pre50_17 = np.nanmedian(census['per_units_pre50_17'])


# #### Percent changes



census['pctch_real_mhval_90_00'] = (census['real_mhval_00']-census['real_mhval_90'])/census['real_mhval_90']
census['pctch_real_mrent_90_00'] = (census['real_mrent_00']-census['real_mrent_90'])/census['real_mrent_90']
census['pctch_real_hinc_90_00'] = (census['real_hinc_00']-census['real_hinc_90'])/census['real_hinc_90']

census['pctch_real_mhval_00_17'] = (census['real_mhval_17']-census['real_mhval_00'])/census['real_mhval_00']
census['pctch_real_mrent_00_17'] = (census['real_mrent_17']-census['real_mrent_00'])/census['real_mrent_00']
census['pctch_real_hinc_00_17'] = (census['real_hinc_17']-census['real_hinc_00'])/census['real_hinc_00']

### Regional Medians
pctch_rm_real_mhval_90_00 = (rm_real_mhval_00-rm_real_mhval_90)/rm_real_mhval_90
pctch_rm_real_mrent_90_00 = (rm_real_mrent_00-rm_real_mrent_90)/rm_real_mrent_90
pctch_rm_real_mhval_00_17 = (rm_real_mhval_17-rm_real_mhval_00)/rm_real_mhval_00
pctch_rm_real_mrent_00_17 = (rm_real_mrent_17-rm_real_mrent_00)/rm_real_mrent_00
pctch_rm_real_hinc_90_00 = (rm_real_hinc_00-rm_real_hinc_90)/rm_real_hinc_90
pctch_rm_real_hinc_00_17 = (rm_real_hinc_17-rm_real_hinc_00)/rm_real_hinc_00


# #### Absolute changes



census['ch_all_li_count_90_00'] = census['all_li_count_00']-census['all_li_count_90']
census['ch_all_li_count_00_17'] = census['all_li_count_17']-census['all_li_count_00']
census['ch_per_col_90_00'] = census['per_col_00']-census['per_col_90']
census['ch_per_col_00_17'] = census['per_col_17']-census['per_col_00']
census['ch_per_limove_12_17'] = census['per_limove_17'] - census['per_limove_12']

### Regional Medians
ch_rm_per_col_90_00 = rm_per_col_00-rm_per_col_90
ch_rm_per_col_00_17 = rm_per_col_17-rm_per_col_00


# #### Flags



df = census
df['pop00flag'] = np.where(df['pop_00']>500, 1, 0)
df['aboverm_per_all_li_90'] = np.where(df['per_all_li_90']>=rm_per_all_li_90, 1, 0)
df['aboverm_per_all_li_00'] = np.where(df['per_all_li_00']>=rm_per_all_li_00, 1, 0)
df['aboverm_per_all_li_17'] = np.where(df['per_all_li_17']>=rm_per_all_li_17, 1, 0)
df['aboverm_per_nonwhite_17'] = np.where(df['per_nonwhite_17']>=rm_per_nonwhite_17, 1, 0)
df['aboverm_per_nonwhite_90'] = np.where(df['per_nonwhite_90']>=rm_per_nonwhite_90, 1, 0)
df['aboverm_per_nonwhite_00'] = np.where(df['per_nonwhite_00']>=rm_per_nonwhite_00, 1, 0)
df['aboverm_per_rent_90'] = np.where(df['per_rent_90']>=rm_per_rent_90, 1, 0)
df['aboverm_per_rent_00'] = np.where(df['per_rent_00']>=rm_per_rent_00, 1, 0)
df['aboverm_per_rent_17'] = np.where(df['per_rent_17']>=rm_per_rent_17, 1, 0)
df['aboverm_per_col_90'] = np.where(df['per_col_90']>=rm_per_col_90, 1, 0)
df['aboverm_per_col_00'] = np.where(df['per_col_00']>=rm_per_col_00, 1, 0)
df['aboverm_per_col_17'] = np.where(df['per_col_17']>=rm_per_col_17, 1, 0)
df['aboverm_real_mrent_90'] = np.where(df['real_mrent_90']>=rm_real_mrent_90, 1, 0)
df['aboverm_real_mrent_00'] = np.where(df['real_mrent_00']>=rm_real_mrent_00, 1, 0)
df['aboverm_real_mrent_17'] = np.where(df['real_mrent_17']>=rm_real_mrent_17, 1, 0)
df['aboverm_real_mhval_90'] = np.where(df['real_mhval_90']>=rm_real_mhval_90, 1, 0)
df['aboverm_real_mhval_00'] = np.where(df['real_mhval_00']>=rm_real_mhval_00, 1, 0)
df['aboverm_real_mhval_17'] = np.where(df['real_mhval_17']>=rm_real_mhval_17, 1, 0)
df['aboverm_pctch_real_mhval_00_17'] = np.where(df['pctch_real_mhval_00_17']>=pctch_rm_real_mhval_00_17, 1, 0)
df['aboverm_pctch_real_mrent_00_17'] = np.where(df['pctch_real_mrent_00_17']>=pctch_rm_real_mrent_00_17, 1, 0)
df['aboverm_pctch_real_mhval_90_00'] = np.where(df['pctch_real_mhval_90_00']>=pctch_rm_real_mhval_90_00, 1, 0)
df['aboverm_pctch_real_mrent_90_00'] = np.where(df['pctch_real_mrent_90_00']>=pctch_rm_real_mrent_90_00, 1, 0)
df['lostli_00'] = np.where(df['ch_all_li_count_90_00']<0, 1, 0)
df['lostli_17'] = np.where(df['ch_all_li_count_00_17']<0, 1, 0)
df['aboverm_pctch_real_hinc_90_00'] = np.where(df['pctch_real_hinc_90_00']>pctch_rm_real_hinc_90_00, 1, 0)
df['aboverm_pctch_real_hinc_00_17'] = np.where(df['pctch_real_hinc_00_17']>pctch_rm_real_hinc_00_17, 1, 0)
df['aboverm_ch_per_col_90_00'] = np.where(df['ch_per_col_90_00']>ch_rm_per_col_90_00, 1, 0)
df['aboverm_ch_per_col_00_17'] = np.where(df['ch_per_col_00_17']>ch_rm_per_col_00_17, 1, 0)
df['aboverm_per_units_pre50_17'] = np.where(df['per_units_pre50_17']>rm_per_units_pre50_17, 1, 0)


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

### Filter by city
rail = rail[rail['Agency'] == rail_agency].reset_index(drop = True)
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




if city_name != 'Memphis':
    ax = city_shp.plot('rail')
    rail.plot(ax = ax, color = 'red')
    plt.show()


# ###### Anchor institution



### Hospitals
hospitals = pd.read_csv(input_path+'Hospitals.csv')

### Universities
university = pd.read_csv(input_path+'university_HD2016.csv')




### Filter for state of interest
hospitals = hospitals[hospitals['STATE'].isin(state_init)]




### Convert to geodataframe
hospitals = gpd.GeoDataFrame(hospitals, geometry=[Point(xy) for xy in zip (hospitals['X'], hospitals['Y'])])

### Filter to hospitals with 100+ beds
hospitals = hospitals[hospitals['BEDS']>=100].reset_index(drop = True)
hosp_type = ["GENERAL MEDICAL AND SURGICAL HOSPITALS", "CHILDREN'S HOSPITALS, GENERAL"]
hospitals = hospitals[hospitals['NAICS_DESC'].isin(hosp_type)]
hospitals = hospitals[['geometry']]
hospitals = hospitals.reset_index(drop = True)




### Filter for state of interest
university = university[university['STABBR'].isin(state_init)]
    
### Convert to geodataframe
university = gpd.GeoDataFrame(university, geometry=[Point(xy) for xy in zip (university['LONGITUD'], university['LATITUDE'])])

### Filter by institution size
university = university[university['INSTSIZE']>1].reset_index(drop = True)

### Keep only geometry type
university = university[['geometry']]




### Keep only records within shapefile
### this step optimizes the flagging of census tracts that contain the point of interest

### Hospitals
hospitals = hospitals[hospitals['geometry'].within(city_poly.loc[0, 'geometry'])].reset_index(drop = True)

### Universities
university = university[university['geometry'].within(city_poly.loc[0, 'geometry'])].reset_index(drop = True)




### Create anchor institution variable
anchor_institutions = university.append(hospitals).reset_index(drop = True)




### Create half mile buffer

### sets coordinate system to WGS84
anchor_institutions.crs = {'init' :'epsg:4326'}

### creates UTM projection
### zone is defined under define city specific variables
projection = '+proj=utm +zone='+zone+', +ellps=WGS84 +datum=WGS84 +units=m +no_defs'

### project to UTM coordinate system
anchor_institutions_proj = anchor_institutions.to_crs(projection)

### create buffer around anchor institution in meters
anchor_institutions_buffer = anchor_institutions_proj.buffer(804.672)

### convert buffer back to WGS84
anchor_institutions_buffer_wgs = anchor_institutions_buffer.to_crs(epsg=4326)




### check whether census tract contains hospital station
### and create anchor institution flag
city_shp['anchor_institution'] = city_shp.intersects(anchor_institutions_buffer_wgs.unary_union)




ax = city_shp.plot(column = 'anchor_institution')
anchor_institutions_buffer_wgs.plot(ax = ax)
plt.show()


# ###### Subsidized housing



### LIHTC
lihtc = pd.read_csv(input_path+'LowIncome_Housing_Tax_Credit_Properties.csv')

### Public housing
pub_hous = pd.read_csv(input_path+'Public_Housing_Buildings.csv')




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




ax = city_shp.plot(color = 'grey')
city_shp.plot(ax = ax, column = 'presence_ph_LIHTC')
presence_ph_LIHTC.plot(ax = ax)
plt.show()




city_shp['GEOID'] = city_shp['GEOID'].astype('int64')




census = census.merge(city_shp[['GEOID','geometry','rail', 'anchor_institution', 'presence_ph_LIHTC']], right_on = 'GEOID', left_on = 'FIPS')


# ### Export csv file



census.to_csv(output_path+city_name+'_database.csv')

# ==========================================================================
# ==========================================================================
# ==========================================================================
# Typology Classification
# ==========================================================================
# ==========================================================================
# ==========================================================================

#
# Run create_lag_vars.r to create lag variables
# --------------------------------------------------------------------------
# Note: If additional cities are added, make sure to change create_lag_vars.r
# accordingly. 

lag = pd.read_csv('~/git/sparcc/data/test.csv')

from shapely import wkt

# Below is the Google File Drive Stream pathway for a mac. 
input_path = '/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Inputs/'
output_path = '~/git/sparcc/data/'

typology_input = pd.read_csv(output_path+city_name+'_database.csv', index_col = 0) ### Read file
typology_input['geometry'] = typology_input['geometry'].apply(wkt.loads) ### Read geometry as a shp attribute
geo_typology_input  = gpd.GeoDataFrame(typology_input, geometry='geometry') ### Create the gdf
data = geo_typology_input.copy(deep=True)




data.plot()
plt.show()


# ## Summarize Income Categorization Data



data.groupby('inc_cat_medhhinc_17').count()['FIPS']




data.groupby('inc_cat_medhhinc_00').count()['FIPS']


# ## Run Typology Method

# ### Additional variable treatment

# #### Flag for sufficient pop in tract by 2000



### The input file has a flag for 2017 population, but this step will generate the same flag for 2000
data['pop00flag'] = np.where((data['pop_00'] >500), 1, 0)




print('POPULATION OVER 500 FOR YEAR 2000')
ax = data.plot(color = 'white')
ax = data.plot(ax = ax, column = 'pop00flag', legend = True)
plt.show()
print('There are ', len(data[data['pop00flag']==0]), 'census tract with pop<500 in 2000')


# ### Vulnerability to Gentrification



### Vulnerable to gentrification index, for both '90 and '00 - make it a flag

### ***** 1990 *****
### 3/4 Criteria that needs to be met
data['vul_gent_90'] = np.where(((data['aboverm_real_mrent_90']==0)|(data['aboverm_real_mhval_90']==0))&
                                 ((data['aboverm_per_all_li_90']+
                                   data['aboverm_per_nonwhite_90']+
                                   data['aboverm_per_rent_90']+
                                   (1-data['aboverm_per_col_90']))>2), 1, 0)


# ### ***** 2000 *****
# ### 3/4 Criteria that needs to be met
data['vul_gent_00'] = np.where(((data['aboverm_real_mrent_00']==0)|(data['aboverm_real_mhval_00']==0))&
                                 ((data['aboverm_per_all_li_00']+
                                   data['aboverm_per_nonwhite_00']+
                                   data['aboverm_per_rent_00']+
                                   (1-data['aboverm_per_col_00']))>2), 1, 0)

# ### ***** 2017 *****
# ### 3/4 Criteria that needs to be met
data['vul_gent_17'] = np.where(((data['aboverm_real_mrent_17']==0)|(data['aboverm_real_mhval_17']==0))&
                                 ((data['aboverm_per_all_li_17']+
                                   data['aboverm_per_nonwhite_17']+
                                   data['aboverm_per_rent_17']+
                                   (1-data['aboverm_per_col_17']))>2), 1, 0)




print('VULNERABLE IN 1990')
ax = data.plot(color = 'grey')
ax = data[~data['vul_gent_90'].isna()].plot(ax = ax, column = 'vul_gent_90', legend = True)
plt.show()
print('There are ', data['vul_gent_90'].isna().sum(), 'census tract with NaN as data')
print('There are ', (data['vul_gent_90']==1).sum(), 'census tracts vulnerable in 1990')




print('VULNERABLE IN 2000')
ax = data.plot(color = 'grey')
ax = data[~data['vul_gent_00'].isna()].plot(ax = ax, column = 'vul_gent_00', legend = True)
plt.show()
print('There are ', data['vul_gent_00'].isna().sum(), 'census tract with NaN as data')
print('There are ', (data['vul_gent_00']==1).sum(), 'census tracts vulnerable in 2000')




print('VULNERABLE IN 2017')
ax = data.plot(color = 'grey')
ax = data[~data['vul_gent_17'].isna()].plot(ax = ax, column = 'vul_gent_17', legend = True)
plt.show()
print('There are ', data['vul_gent_17'].isna().sum(), 'census tract with NaN as data')
print('There are ', (data['vul_gent_17']==1).sum(), 'census tracts vulnerable in 2017')


# ###### Out of curiosity



### Out of curiosity
data['vulnerable'] = data['vul_gent_90']*data['vul_gent_00']




print('VULNERABLE IN BOTH YEARS')
ax = data.plot(color = 'grey')
ax = data[~data['vulnerable'].isna()].plot(ax = ax, column = 'vulnerable', legend = True)
plt.show()
print('There are ', data['vulnerable'].isna().sum(), 'census tract with NaN as data')
print('There are ', (data['vulnerable']==1).sum(), 'census tracts vulnerable in both years')


# ### Hot Market



### Hot market in '00 and '17 - make it a flag:
### Using old methodology for now, will update later
### New methodology would be rapid increase (2013-2017)

data['hotmarket_00'] = np.where((data['aboverm_pctch_real_mhval_90_00']==1)|
                                  (data['aboverm_pctch_real_mrent_90_00']==1), 1, 0)
data['hotmarket_00'] = np.where((data['aboverm_pctch_real_mhval_90_00'].isna())|
                                  (data['aboverm_pctch_real_mrent_90_00'].isna()), np.nan, data['hotmarket_00'])

data['hotmarket_17'] = np.where((data['aboverm_pctch_real_mhval_00_17']==1)|
                                  (data['aboverm_pctch_real_mrent_00_17']==1), 1, 0)
data['hotmarket_17'] = np.where((data['aboverm_pctch_real_mhval_00_17'].isna())|
                                  (data['aboverm_pctch_real_mrent_00_17'].isna()), np.nan, data['hotmarket_17'])




print('HOT MARKET 2017')
ax = data.plot(color = 'white')
ax = data[~data['hotmarket_17'].isna()].plot(ax = ax, column = 'hotmarket_17', legend = True)
plt.show()
print('There are ', data['hotmarket_17'].isna().sum(), 'census tract with NaN as data')
print('There are ', (data['hotmarket_17']==1).sum(), 'census tracts with hot market in 2017')




print('HOT MARKET 2000')
ax = data.plot(color = 'white')
ax = data[~data['hotmarket_00'].isna()].plot(ax = ax, column = 'hotmarket_00', legend = True)
plt.show()
print('There are ', data['hotmarket_00'].isna().sum(), 'census tract with NaN as data')
print('There are ', (data['hotmarket_00']==1).sum(), 'census tracts with hot market in 2000')


# ### Gentrification



### 2 out of 3 required
### 1990 - 2000
# data['gent_90_00'] = np.where((data['vul_gent_90']==1)&
#                                 ((data['aboverm_ch_per_col_90_00']+
#                                 data['aboverm_pctch_real_hinc_90_00']+
#                                 data['lostli_00'])>1)&
#                                 (data['hotmarket_00']==1), 1, 0)

# # 2000 - 2017
# data['gent_00_17'] = np.where((data['vul_gent_00']==1)&
#                                 ((data['aboverm_ch_per_col_00_17']+
#                                 data['aboverm_pctch_real_hinc_00_17']+
#                                 data['lostli_17'])>1)&
#                                 (data['ch_per_limove_12_17']<0)&
#                                 (data['hotmarket_17']==1), 1, 0)


### all required
### 1990 - 2000
data['gent_90_00'] = np.where((data['vul_gent_90']==1)&
                                (data['aboverm_ch_per_col_90_00']==1)&
                                (data['aboverm_pctch_real_hinc_90_00']==1)&
                                (data['lostli_00']==1)&
                                (data['hotmarket_00']==1), 1, 0)


# # 2000 - 2017
data['gent_00_17'] = np.where((data['vul_gent_00']==1)&
                                (data['aboverm_ch_per_col_00_17']==1)&
                                (data['aboverm_pctch_real_hinc_00_17']==1)&
                                (data['lostli_17']==1)&
                                (data['ch_per_limove_12_17']<0)&
                                (data['hotmarket_17']==1), 1, 0)




print('GENTRIFICATION 1990 - 2000')
ax = data.plot(color = 'white')
ax = data[~data['gent_90_00'].isna()].plot(ax = ax, column = 'gent_90_00', legend = True)
plt.show()
print('There are ', data['gent_90_00'].isna().sum(), 'census tract with NaN as data')
print(str((data['gent_90_00']==1).sum()), 'census tracts were gentrified 1990-2000')




print('GENTRIFICATION 2000 - 2017')
ax = data.plot(color = 'white')
ax = data[~data['gent_00_17'].isna()].plot(ax = ax, column = 'gent_00_17', legend = True)
plt.show()
print('There are ', data['gent_00_17'].isna().sum(), 'census tract with NaN as data')
print(str((data['gent_00_17']==1).sum()), 'census tracts were gentrified 2000-2017')




(data['gent_00_17']*data['gent_90_00']).sum()


# ### Typology definitions
# 
# Make flags for each typology definition - goal is to make them flags so we can compare across typologies to check if any are being double counted or missed. Note on missing data: will code it so that the typology is missing if any of the core data elements are missing, but for any additional risk or stability criteria, will be coded so that it pulls from a shorter list if any are missing so as not to throw it all out
# 

# #### Stable/Advanced Exclusive



### ********* Stable/advanced exclusive *************
df = data
df['SAE'] = 0
df['SAE'] = np.where((df['pop00flag']==1)&
                     (df['high_pdmt_medhhinc_00'] == 1)&
                     (df['high_pdmt_medhhinc_17'] == 1)&                 
                     (df['lmh_flag_encoded'] == 3)&
                     ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2)|
                     (df['change_flag_encoded'] == 3)), 1, 0)

df['SAE'] = np.where((df['pop00flag'].isna())|
                     (df['high_pdmt_medhhinc_00'].isna())|
                     (df['high_pdmt_medhhinc_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna()), np.nan, df['SAE'])

# replace SAE=1 if A==1 & (A==1) & (B==1) & (C==5| D==6)& (E==18 | F==19 | G==20)




print('STABLE ADVANCED EXCLUSIVE')
ax = data.plot(color = 'white')
ax = data[~data['SAE'].isna()].plot(ax = ax, column = 'SAE', legend = True)
plt.show()
print('There are ', data['SAE'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['SAE']==1).sum()), 'Stable Advanced Exclusive CT')




### Creates flag for proximity to exclusive neighborhood
### THIS IS NOT CURRENTLY BEING USED, BUT WILL BE USEFUL WHEN RISK FACTORS ARE INCLUDED

### Filters only exclusive tracts
exclusive = data[data['SAE']==1].reset_index(drop=True)

### Flags census tracts that touch exclusive tracts (excluding exclusive)
proximity = df[df.geometry.touches(exclusive.unary_union)]

ax = data.plot()
exclusive.plot(ax = ax, color = 'grey')
proximity.plot(ax = ax, color = 'yellow')
plt.show()


# #### Advanced Gentrification



### ************* Advanced gentrification **************
df = data
df['AdvG'] = 0
df['AdvG'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_17'] == 1)|(df['mix_mod_medhhinc_17'] == 1)|
                     (df['mix_high_medhhinc_17'] == 1)|(df['high_pdmt_medhhinc_17'] == 1))&                    
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                    ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2))&
                     ((df['gent_90_00']==1)|(df['gent_00_17']==1)), 1, 0)

df['AdvG'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_17'].isna())|
                     (df['mix_mod_medhhinc_17'].isna())|
                     (df['mix_high_medhhinc_17'].isna())|
                     (df['high_pdmt_medhhinc_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['gent_00_17'].isna()), np.nan, df['AdvG'])

df['AdvG'] = np.where((df['AdvG'] == 1)&(df['SAE']==1), 0, df['AdvG']) ### This is to account for double classification




print('ADVANCED GENTRIFICATION')
ax = data.plot(color = 'white')
ax = data[~data['AdvG'].isna()].plot(ax = ax, column = 'AdvG', legend = True)
plt.show()
print('There are ', data['AdvG'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['AdvG']==1).sum()), 'Advanced Gentrification CT')


# #### At Risk of Becoming Exclusive



df = data
df['ARE'] = 0
df['ARE'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_17'] == 1)|(df['mix_mod_medhhinc_17'] == 1)|
                     (df['mix_high_medhhinc_17'] == 1)|(df['high_pdmt_medhhinc_17'] == 1))&                    
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                    ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2)), 1, 0)

df['ARE'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_17'].isna())|
                     (df['mix_mod_medhhinc_17'].isna())|
                     (df['mix_high_medhhinc_17'].isna())|
                     (df['high_pdmt_medhhinc_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna()), np.nan, df['ARE'])

df['ARE'] = np.where((df['ARE'] == 1)&(df['AdvG']==1), 0, df['ARE']) ### This is to account for double classification
df['ARE'] = np.where((df['ARE'] == 1)&(df['SAE']==1), 0, df['ARE']) ### This is to account for double classification




print('AT RISK OF BECOMING EXCLUSIVE')
ax = data.plot(color = 'white')
ax = data[~data['ARE'].isna()].plot(ax = ax, column = 'ARE', legend = True)
plt.show()
print('There are ', data['ARE'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['ARE']==1).sum()), 'At Risk of Exclusive CT')


# #### Becoming Exclusive



### *********** Becoming exclusive *************
df['BE'] = 0
df['BE'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_17'] == 1)|(df['mix_mod_medhhinc_17'] == 1)|
                     (df['mix_high_medhhinc_17'] == 1)|(df['high_pdmt_medhhinc_17'] == 1))&
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                     (df['change_flag_encoded'] == 3)&
                     (df['lostli_17']==1)&
                     (df['per_limove_17']<df['per_limove_12'])&
                     (df['real_hinc_17']>df['real_hinc_00']), 1, 0)

df['BE'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_17'].isna())|
                     (df['mix_mod_medhhinc_17'].isna())|
                     (df['mix_high_medhhinc_17'].isna())|
                     (df['high_pdmt_medhhinc_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['lostli_17'].isna())|
                     (df['per_limove_17'].isna())|
                     (df['per_limove_12'].isna())|
                     (df['real_hinc_17'].isna())|
                     (df['real_hinc_00'].isna()), np.nan, df['BE'])

df['BE'] = np.where((df['BE'] == 1)&(df['SAE']==1), 0, df['BE']) ### This is to account for double classification




print('BECOMING EXCLUSIVE')
ax = data.plot(color = 'white')
ax = data[~data['BE'].isna()].plot(ax = ax, column = 'BE', legend = True)
plt.show()
print('There are ', data['BE'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['BE']==1).sum()), 'Becoming Exclusive CT')


# #### Stable Moderate/Mixed Income



df['SMMI'] = 0
df['SMMI'] = np.where((df['pop00flag']==1)&
                     ((df['mod_pdmt_medhhinc_17'] == 1)|(df['mix_mod_medhhinc_17'] == 1)|
                      (df['mix_high_medhhinc_17'] == 1)|(df['high_pdmt_medhhinc_17'] == 1))&             
                     (df['ARE']==0)&(df['BE']==0)&(df['SAE']==0)&(df['AdvG']==0), 1, 0)

df['SMMI'] = np.where((df['pop00flag'].isna())|
                      (df['mod_pdmt_medhhinc_17'].isna())|
                      (df['mix_mod_medhhinc_17'].isna())|
                      (df['mix_high_medhhinc_17'].isna())|
                      (df['high_pdmt_medhhinc_17'].isna()), np.nan, df['SMMI'])




print('Stable Moderate/Mixed Income')
ax = data.plot(color = 'white')
ax = data[~data['SMMI'].isna()].plot(ax = ax, column = 'SMMI', legend = True)
plt.show()
print('There are ', data['SMMI'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['SMMI']==1).sum()), 'Stable Moderate/Mixed Income CT')

# #### At Risk of Gentrification

data = pd.merge(data,lag[['dp_PChRent','dp_RentGap','GEOID']],on='GEOID')





### Needs to run exclusive code for analysis of risk factors
### ****ARG ****
df['ARG'] = 0
df['ARG'] = np.where((df['pop00flag']==1)&
                    ((df['low_pdmt_medhhinc_17']==1)|(df['mix_low_medhhinc_17']==1))&
                    ((df['lmh_flag_encoded']==1)|(df['lmh_flag_encoded']==4))&
                    ((df['change_flag_encoded'] == 1))&
                     (df['gent_90_00']==0)&
                     ((df['dp_PChRent'] == 1)|(df['dp_RentGap'] == 1)) &
                     (df['gent_00_17']==0), 1, 0)

df['ARG'] = np.where((df['pop00flag'].isna())|
                     (df['low_pdmt_medhhinc_17'].isna())|
                     (df['mix_low_medhhinc_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['vul_gent_00'].isna())|
                     (df['dp_PChRent'].isna())|
                     (df['dp_RentGap'].isna())|
                     (df['gent_00_17'].isna()), np.nan, df['ARG'])




print('AT RISK OF GENTRIFICATION')
ax = data.plot(color = 'white')
ax = data[~df['ARG'].isna()].plot(ax = ax, column = 'ARG', legend = True)
plt.show()
print('There are ', data['ARG'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['ARG']==1).sum()), 'At Risk of Gentrification CT')


# #### Early/Ongoing Gentrification



###************* Early/ongoing gentrification **************
### ****EOG ****
df['EOG'] = 0
df['EOG'] = np.where((df['pop00flag']==1)&
                    ((df['low_pdmt_medhhinc_17']==1)|(df['mix_low_medhhinc_17']==1))&
                     (df['ch_per_limove_12_17']<0)&                     
                    ((df['lmh_flag_encoded'] == 1)|(df['lmh_flag_encoded'] == 2)|
                     (df['lmh_flag_encoded'] == 4)|(df['lmh_flag_encoded'] == 5))&
                    ((df['change_flag_encoded'] == 2)|(df['change_flag_encoded'] == 3)|
                     (df['ab_50pct_ch'] == 1))&
                     ((df['gent_90_00']==1)|(df['gent_00_17']==1)), 1, 0)

df['EOG'] = np.where((df['pop00flag'].isna())|
                     (df['low_pdmt_medhhinc_17'].isna())|
                     (df['mix_low_medhhinc_17'].isna())|
                     (df['ch_per_limove_12_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['gent_00_17'].isna())|
                     (df['ab_50pct_ch'].isna()), np.nan, df['EOG'])




print('EARLY/ONGOING GENTRIFICATION')
ax = data.plot(color = 'white')
ax = data[~data['EOG'].isna()].plot(ax = ax, column = 'EOG', legend = True)
plt.show()
print('There are ', data['EOG'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['EOG']==1).sum()), 'Early/Ongoing Gentrification CT')


# #### Ongoing Displacement



df = data

df['OD'] = 0
df['OD'] = np.where((df['pop00flag']==1)&
                          ((df['low_pdmt_medhhinc_17']==1)|(df['mix_low_medhhinc_17']==1))&
                          (df['lostli_17']==1), 1, 0)

df['OD_loss'] = np.where((df['pop00flag'].isna())|
                    (df['low_pdmt_medhhinc_17'].isna())|
                    (df['mix_low_medhhinc_17'].isna())|
                    (df['lostli_17'].isna()), np.nan, df['OD'])

df['OD'] = np.where((df['OD'] == 1)&(df['ARG']==1), 0, df['OD']) ### This is to account for double classification
df['OD'] = np.where((df['OD'] == 1)&(df['EOG']==1), 0, df['OD']) ### This is to account for double classification




print('ONGOING DISPLACEMENT')
ax = data.plot(color = 'white')
ax = data[~data['OD'].isna()].plot(ax = ax, column = 'OD', legend = True)
plt.show()
print('There are ', data['OD'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['OD']==1).sum()), 'Ongoing Displacement CT')


# #### Stable/Low-Income



df['SLI'] = 0
df['SLI'] = np.where((df['pop00flag'] == 1)&
                     ((df['low_pdmt_medhhinc_17'] == 1)|(df['mix_low_medhhinc_17'] == 1))&
                     (df['OD']!=1) & (df['ARG']!=1) *(df['EOG']!=1), 1, 0)




print('STABLE LOW INCOME TRACTS')
ax = data.plot(color = 'white')
ax = data[~data['SLI'].isna()].plot(ax = ax, column = 'SLI', legend = True)
plt.show()
print('There are ', data['SLI'].isna().sum(), 'census tract with NaN as data')
print('There are ',str((data['SLI']==1).sum()), 'Stable Low Income CT')


# ## Create Typology variables from all the dummies



df['double_counted'] = (df['SLI'].fillna(0) + df['OD'].fillna(0) + df['ARG'].fillna(0) + df['EOG'].fillna(0) +
                       df['AdvG'].fillna(0) + df['ARE'].fillna(0) + df['BE'].fillna(0) + df['SAE'] + df['SMMI'])
    
df['typology'] = np.nan
df['typology'] = np.where(df['SLI'] == 1, 1, df['typology'])
df['typology'] = np.where(df['OD'] == 1, 2, df['typology'])
df['typology'] = np.where(df['ARG'] == 1, 3, df['typology'])
df['typology'] = np.where(df['EOG'] == 1, 4, df['typology'])
df['typology'] = np.where(df['AdvG'] == 1, 5, df['typology'])
df['typology'] = np.where(df['SMMI'] == 1, 6, df['typology'])
df['typology'] = np.where(df['ARE'] == 1, 7, df['typology'])
df['typology'] = np.where(df['BE'] == 1, 8, df['typology'])
df['typology'] = np.where(df['SAE'] == 1, 9, df['typology'])
df['typology'] = np.where(df['double_counted']>1, 99, df['typology'])


# #### Double Classification



cat_i = list()

df = data
for i in range (0, len (df)):
    categories = list()
    if df['SLI'][i] == 1:
        categories.append('SLI')
    if df['OD'][i] == 1:
        categories.append('OD')
    if df['ARG'][i] == 1:
        categories.append('ARG')
    if df['EOG'][i] == 1:
        categories.append('EOG')
    if df['AdvG'][i] == 1:
        categories.append('AdvG')
    if df['SMMI'][i] == 1:
        categories.append('SMMI')
    if df['ARE'][i] == 1:
        categories.append('ARE')
    if df['BE'][i] == 1:
        categories.append('BE')
    if df['SAE'][i] == 1:
        categories.append('SAE')
    cat_i.append(str(categories))
    
df['typ_cat'] = cat_i




df.groupby('typ_cat').count()['FIPS']




print('TYPOLOGIES')

f, ax = plt.subplots(1, figsize=(8, 8))
data.plot(ax=ax, color = 'lightgrey')
lims = plt.axis('equal')
df[~data['typology'].isna()].plot(ax = ax, column = 'typ_cat', legend = True)
plt.show()
print('There are ', data['typology'].isna().sum(), 'census tract with NaN as data')




data.to_file(city_name+'_typology_output.shp')




#data['FIPS'] = data['FIPS'].astype(str)
#data = data.drop(columns = 'geometry')
#data.to_csv(output_path+city_name+'_typology_output.csv')

