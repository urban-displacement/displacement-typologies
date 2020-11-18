#!/usr/bin/env python
# coding: utf-8

# ==========================================================================
# ==========================================================================
# ==========================================================================
# Typology Classification
# ==========================================================================
# ==========================================================================
# ==========================================================================

import pandas as pd
import geopandas as gpd
import numpy as np
import matplotlib.pyplot as plt
from shapely import wkt
from pathlib import Path
from shapely import wkt
import sys

# ### Choose city and census tracts of interest
# To get city data, run the following code in the terminal
# `python data.py <city name>`
# Example: python data.py Atlanta

city_name = str(sys.argv[1])
# city_name = "Memphis"

#
# Run create_lag_vars.r to create lag variables
# --------------------------------------------------------------------------
# Note: If additional cities are added, make sure to change create_lag_vars.r
# accordingly. 

lag = pd.read_csv('~/git/displacement-typologies/data/outputs/lags/lag_2017.csv')

home = str(Path.home())
input_path = home+'/git/displacement-typologies/data/inputs/'
output_path = home+'/git/displacement-typologies/data/outputs/'

typology_input = pd.read_csv(output_path+'databases/'+city_name+'_database_2017.csv', index_col = 0) ### Read file
typology_input['geometry'] = typology_input['geometry'].apply(wkt.loads) ### Read geometry as a shp attribute
geo_typology_input  = gpd.GeoDataFrame(typology_input, geometry='geometry') ### Create the gdf
data = geo_typology_input.copy(deep=True)




# data.plot()
# plt.show()


# ## Summarize Income Categorization Data

data.groupby('inc_cat_medhhinc_17').count()['FIPS']

data.groupby('inc_cat_medhhinc_00').count()['FIPS']

# ## Run Typology Method

# ### Additional variable treatment

# #### Flag for sufficient pop in tract by 2000

### The input file has a flag for 2017 population, but this step will generate the same flag for 2000
data['pop00flag'] = np.where((data['pop_00'] >500), 1, 0)

# print('POPULATION OVER 500 FOR YEAR 2000')
# ax = data.plot(color = 'white')
# ax = data.plot(ax = ax, column = 'pop00flag', legend = True)
# plt.show()
# print('There are ', len(data[data['pop00flag']==0]), 'census tract with pop<500 in 2000')

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




# print('VULNERABLE IN 1990')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_90'].isna()].plot(ax = ax, column = 'vul_gent_90', legend = True)
# plt.show()
# print('There are ', data['vul_gent_90'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_90']==1).sum(), 'census tracts vulnerable in 1990')




# print('VULNERABLE IN 2000')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_00'].isna()].plot(ax = ax, column = 'vul_gent_00', legend = True)
# plt.show()
# print('There are ', data['vul_gent_00'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_00']==1).sum(), 'census tracts vulnerable in 2000')




# print('VULNERABLE IN 2017')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_17'].isna()].plot(ax = ax, column = 'vul_gent_17', legend = True)
# plt.show()
# print('There are ', data['vul_gent_17'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_17']==1).sum(), 'census tracts vulnerable in 2017')


# ###### Out of curiosity



### Out of curiosity
# data['vulnerable'] = data['vul_gent_90']*data['vul_gent_00']




# print('VULNERABLE IN BOTH YEARS')
# ax = data.plot(color = 'grey')
# ax = data[~data['vulnerable'].isna()].plot(ax = ax, column = 'vulnerable', legend = True)
# plt.show()
# print('There are ', data['vulnerable'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vulnerable']==1).sum(), 'census tracts vulnerable in both years')


# ### Hot Market



### Hot market in '00 and '17 - make it a flag:
### Using old methodology for now, will update later
### New methodology would be rapid increase (2013-2017)

data['hotmarket_00'] = np.where((data['aboverm_pctch_real_mhval_90_00']==1)|
                                  (data['aboverm_pctch_real_mrent_90_00']==1), 1, 0)
data['hotmarket_00'] = np.where((data['aboverm_pctch_real_mhval_90_00'].isna())|
                                  (data['aboverm_pctch_real_mrent_90_00'].isna()), np.nan, data['hotmarket_00'])

data['hotmarket_17'] = np.where((data['aboverm_pctch_real_mhval_00_17']==1)|
                                  (data['aboverm_pctch_real_mrent_12_17']==1), 1, 0)
data['hotmarket_17'] = np.where((data['aboverm_pctch_real_mhval_00_17'].isna())|
                                  (data['aboverm_pctch_real_mrent_12_17'].isna()), np.nan, data['hotmarket_17'])

# print('HOT MARKET 2017')
# ax = data.plot(color = 'white')
# ax = data[~data['hotmarket_17'].isna()].plot(ax = ax, column = 'hotmarket_17', legend = True)
# plt.show()
# print('There are ', data['hotmarket_17'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['hotmarket_17']==1).sum(), 'census tracts with hot market in 2017')

# print('HOT MARKET 2000')
# ax = data.plot(color = 'white')
# ax = data[~data['hotmarket_00'].isna()].plot(ax = ax, column = 'hotmarket_00', legend = True)
# plt.show()
# print('There are ', data['hotmarket_00'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['hotmarket_00']==1).sum(), 'census tracts with hot market in 2000')


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

data['gent_90_00_urban'] = np.where((data['vul_gent_90']==1)&
                                (data['aboverm_ch_per_col_90_00']==1)&
                                (data['aboverm_pctch_real_hinc_90_00']==1)&
                                # (data['lostli_00']==1)&
                                (data['hotmarket_00']==1), 1, 0)


# # 2000 - 2017
data['gent_00_17'] = np.where((data['vul_gent_00']==1)&
                                (data['aboverm_ch_per_col_00_17']==1)&
                                (data['aboverm_pctch_real_hinc_00_17']==1)&
                                (data['lostli_17']==1)&
                                # (data['ch_per_limove_12_17']<0)&
                                (data['hotmarket_17']==1), 1, 0)

data['gent_00_17_urban'] = np.where((data['vul_gent_00']==1)&
                                (data['aboverm_ch_per_col_00_17']==1)&
                                (data['aboverm_pctch_real_hinc_00_17']==1)&
                                # (data['lostli_17']==1)&
                                # (data['ch_per_limove_12_17']<0)&
                                (data['hotmarket_17']==1), 1, 0)


# Add lag variables
data = pd.merge(data,lag[['dp_PChRent','dp_RentGap','GEOID', 'tr_rent_gap', 'rm_rent_gap', 'dense']],on='GEOID')


# print('GENTRIFICATION 1990 - 2000')
# ax = data.plot(color = 'white')
# ax = data[~data['gent_90_00'].isna()].plot(ax = ax, column = 'gent_90_00', legend = True)
# plt.show()
# print('There are ', data['gent_90_00'].isna().sum(), 'census tract with NaN as data')
# print(str((data['gent_90_00']==1).sum()), 'census tracts were gentrified 1990-2000')




# print('GENTRIFICATION 2000 - 2017')
# ax = data.plot(color = 'white')
# ax = data[~data['gent_00_17'].isna()].plot(ax = ax, column = 'gent_00_17', legend = True)
# plt.show()
# print('There are ', data['gent_00_17'].isna().sum(), 'census tract with NaN as data')
# print(str((data['gent_00_17']==1).sum()), 'census tracts were gentrified 2000-2017')




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




# print('STABLE ADVANCED EXCLUSIVE')
# ax = data.plot(color = 'white')
# ax = data[~data['SAE'].isna()].plot(ax = ax, column = 'SAE', legend = True)
# plt.show()
# print('There are ', data['SAE'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['SAE']==1).sum()), 'Stable Advanced Exclusive CT')




### Creates flag for proximity to exclusive neighborhood
### THIS IS NOT CURRENTLY BEING USED, BUT WILL BE USEFUL WHEN RISK FACTORS ARE INCLUDED

### Filters only exclusive tracts
exclusive = data[data['SAE']==1].reset_index(drop=True)

### Flags census tracts that touch exclusive tracts (excluding exclusive)
proximity = df[df.geometry.touches(exclusive.unary_union)]

# ax = data.plot()
# exclusive.plot(ax = ax, color = 'grey')
# proximity.plot(ax = ax, color = 'yellow')
# plt.show()


# #### Advanced Gentrification



### ************* Advanced gentrification **************
# df = data
df['AdvG'] = 0
df['AdvG'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_17'] == 1)|(df['mix_mod_medhhinc_17'] == 1)|
                     (df['mix_high_medhhinc_17'] == 1)|(df['high_pdmt_medhhinc_17'] == 1))&                    
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                    ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2))&
                    ((df['pctch_real_mhval_00_17'] > 0) | (df['pctch_real_mrent_12_17'] > 0)) & 
                     (
                        # (df['gent_90_00']==1)|
                        # (df['gent_00_17']==1)
                        ((df['dense'] == 0) & (df['gent_90_00'] == 1))|
                        ((df['dense'] == 0) & (df['gent_00_17'] == 1))|
                        ((df['dense'] == 1) & (df['gent_90_00_urban'] == 1))|
                        ((df['dense'] == 1) & (df['gent_00_17_urban'] == 1))
                    ), 1, 0)

df['AdvG'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_17'].isna())|
                     (df['mix_mod_medhhinc_17'].isna())|
                     (df['mix_high_medhhinc_17'].isna())|
                     (df['high_pdmt_medhhinc_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['gent_90_00_urban'].isna())|
                     (df['gent_00_17_urban'].isna())|
                     (df['pctch_real_mhval_00_17'].isna())|
                     (df['pctch_real_mrent_12_17'].isna())|
                     (df['gent_00_17'].isna()), np.nan, df['AdvG'])

df['AdvG'] = np.where((df['AdvG'] == 1)&(df['SAE']==1), 0, df['AdvG']) ### This is to account for double classification




# print('ADVANCED GENTRIFICATION')
# ax = data.plot(color = 'white')
# ax = data[~data['AdvG'].isna()].plot(ax = ax, column = 'AdvG', legend = True)
# plt.show()
# print('There are ', data['AdvG'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['AdvG']==1).sum()), 'Advanced Gentrification CT')


# #### At Risk of Becoming Exclusive



# df = data
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




# print('AT RISK OF BECOMING EXCLUSIVE')
# ax = data.plot(color = 'white')
# ax = data[~data['ARE'].isna()].plot(ax = ax, column = 'ARE', legend = True)
# plt.show()
# print('There are ', data['ARE'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['ARE']==1).sum()), 'At Risk of Exclusive CT')


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




# print('BECOMING EXCLUSIVE')
# ax = data.plot(color = 'white')
# ax = data[~data['BE'].isna()].plot(ax = ax, column = 'BE', legend = True)
# plt.show()
# print('There are ', data['BE'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['BE']==1).sum()), 'Becoming Exclusive CT')


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




# print('Stable Moderate/Mixed Income')
# ax = data.plot(color = 'white')
# ax = data[~data['SMMI'].isna()].plot(ax = ax, column = 'SMMI', legend = True)
# plt.show()
# print('There are ', data['SMMI'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['SMMI']==1).sum()), 'Stable Moderate/Mixed Income CT')

# #### At Risk of Gentrification


### Needs to run exclusive code for analysis of risk factors
### ****ARG ****
df['ARG'] = 0
df['ARG'] = np.where((df['pop00flag']==1)&
                    ((df['low_pdmt_medhhinc_17']==1)|(df['mix_low_medhhinc_17']==1))&
                    ((df['lmh_flag_encoded']==1)|(df['lmh_flag_encoded']==4))&
                    ((df['change_flag_encoded'] == 1)|(df['ab_90percentile_ch']==1)|(df['rent_90percentile_ch']==1))&
                    (df['gent_90_00']==0)&
                    ((df['dp_PChRent'] == 1)|(df['dp_RentGap'] == 1)) &
                    (df['vul_gent_17']==1)&
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




# print('AT RISK OF GENTRIFICATION')
# ax = data.plot(color = 'white')
# ax = data[~df['ARG'].isna()].plot(ax = ax, column = 'ARG', legend = True)
# plt.show()
# print('There are ', data['ARG'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['ARG']==1).sum()), 'At Risk of Gentrification CT')


# #### Early/Ongoing Gentrification



###************* Early/ongoing gentrification **************
### ****EOG ****
df['EOG'] = 0
df['EOG'] = np.where((df['pop00flag']==1)& # pop > 500
                    ((df['low_pdmt_medhhinc_17']==1)|(df['mix_low_medhhinc_17']==1))& # low and mix low income households. 
                     # (df['ch_per_limove_12_17']<0)& # percent change in low income movers              
                    ( 
                        # (df['lmh_flag_encoded'] == 1)| # affordable to low income households
                        (df['lmh_flag_encoded'] == 2)| # predominantly middle income
                        # (df['lmh_flag_encoded'] == 4)| # Mixed low
                        (df['lmh_flag_encoded'] == 5) # mixed mod
                        )&
                    (
                        (df['change_flag_encoded'] == 2)| # change increase
                        (df['change_flag_encoded'] == 3)| # rapid change increase
                        # (df['ab_50pct_ch'] == 1)| # housing above 50%
                        # (df['rent_50pct_ch'] == 1) # rent above 50%
                        (df['hv_abrm_ch'] == 1)| # housing value above regional median
                        (df['rent_abrm_ch'] == 1) # rent above regional median
                        )&
                     (
                        # (df['gent_90_00']==1)|
                        # (df['gent_00_17']==1)
                        ((df['dense'] == 0) & (df['gent_90_00'] == 1))|
                        ((df['dense'] == 0) & (df['gent_00_17'] == 1))|
                        ((df['dense'] == 1) & (df['gent_90_00_urban'] == 1))|
                        ((df['dense'] == 1) & (df['gent_00_17_urban'] == 1))
                    ), 1, 0) # gentrified (includes hotmarket)

df['EOG'] = np.where((df['pop00flag'].isna())|
                     (df['low_pdmt_medhhinc_17'].isna())|
                     (df['mix_low_medhhinc_17'].isna())|
                     (df['ch_per_limove_12_17'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['gent_00_17'].isna())|                     
                     (df['gent_90_00_urban'].isna())|
                     (df['gent_00_17_urban'].isna())|
                     (df['ab_50pct_ch'].isna())|
                     (df['hv_abrm_ch'].isna())|
                     (df['rent_abrm_ch'].isna())|
                     (df['rent_50pct_ch'].isna()), np.nan, df['EOG'])




# print('EARLY/ONGOING GENTRIFICATION')
# ax = data.plot(color = 'white')
# ax = data[~data['EOG'].isna()].plot(ax = ax, column = 'EOG', legend = True)
# plt.show()
# print('There are ', data['EOG'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['EOG']==1).sum()), 'Early/Ongoing Gentrification CT')


# #### Ongoing Displacement



# df = data

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




# print('ONGOING DISPLACEMENT')
# ax = data.plot(color = 'white')
# ax = data[~data['OD'].isna()].plot(ax = ax, column = 'OD', legend = True)
# plt.show()
# print('There are ', data['OD'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['OD']==1).sum()), 'Ongoing Displacement CT')


# #### Stable/Low-Income



df['SLI'] = 0
df['SLI'] = np.where((df['pop00flag'] == 1)&
                     ((df['low_pdmt_medhhinc_17'] == 1)|(df['mix_low_medhhinc_17'] == 1))&
                     (df['OD']!=1) & (df['ARG']!=1) & (df['EOG']!=1), 1, 0)




# print('STABLE LOW INCOME TRACTS')
# ax = data.plot(color = 'white')
# ax = data[~data['SLI'].isna()].plot(ax = ax, column = 'SLI', legend = True)
# plt.show()
# print('There are ', data['SLI'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['SLI']==1).sum()), 'Stable Low Income CT')


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

# df = data
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

# f, ax = plt.subplots(1, figsize=(8, 8))
# data.plot(ax=ax, color = 'lightgrey')
# lims = plt.axis('equal')
# df[~data['typology'].isna()].plot(ax = ax, column = 'typ_cat', legend = True)
# plt.show()
# print('There are ', data['typology'].isna().sum(), 'census tract with NaN as data')




# df.to_file(city_name+'_typology_output.csv')




df['FIPS'] = df['FIPS'].astype(str)
df = df.drop(columns = 'geometry')
df.to_csv(output_path+'typologies/'+city_name+'_typology_output_2017.csv')

