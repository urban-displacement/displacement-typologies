#!/usr/bin/env python
# coding: utf-8

# ==========================================================================
# Import Libraries
# ==========================================================================

import pandas as pd
from shapely import wkt
import geopandas as gpd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import sys

# ==========================================================================
# Choose City to Run (inputs needed)
# ==========================================================================
# Note: Code is set up to run one city at a time

### Choose city and census tracts of interest
# To get city data, run the following code in the terminal
# `python data.py <city name>`
# Example: python data.py Atlanta

city_name = str(sys.argv[1])
###
# When testing city analysis, use: 
# city_name = "San Francisco"
# Run create_lag_vars.r to create lag variables
# --------------------------------------------------------------------------
# Note: If additional cities are added, make sure to change create_lag_vars.r
# accordingly. 

lag = pd.read_csv('~/git/displacement-typologies/data/outputs/lags/lag.csv')

home = str(Path.home())

input_path = home+'/git/displacement-typologies/data/inputs/'
output_path = home+'/git/displacement-typologies/data/outputs/'

typology_input = pd.read_csv(output_path+'/databases/'+city_name.replace(" ", "")+'_database_2018.csv', index_col = 0) ### Read file
typology_input['geometry'] = typology_input['geometry'].apply(wkt.loads) ### Read geometry as a shp attribute
geo_typology_input  = gpd.GeoDataFrame(typology_input, geometry='geometry') ### Create the gdf
data = geo_typology_input.copy(deep=True)

## Summarize Income Categorization Data
# --------------------------------------------------------------------------

data.groupby('inc_cat_medhhinc_18').count()['FIPS']

data.groupby('inc_cat_medhhinc_00').count()['FIPS']

#### Flag for sufficient pop in tract by 2000
data['pop00flag'] = np.where((data['pop_00'] >500), 1, 0)

####
# Begin Test
####
# print('POPULATION OVER 500 FOR YEAR 2000')
# ax = data.plot(color = 'white')
# ax = data.plot(ax = ax, column = 'pop00flag', legend = True)
# plt.show()
# print('There are ', len(data[data['pop00flag']==0]), 'census tract with pop<500 in 2000')
####
# End Test
####

# ==========================================================================
# Define Vulnerability to Gentrification Variable
# ==========================================================================
# Note: Code is set up to run one city at a time

# Vulnerable to gentrification index, for both '90 and '00 - make it a flag
# --------------------------------------------------------------------------

### ***** 1990 *****
### 3/4 Criteria that needs to be met
data['vul_gent_90'] = np.where(((data['aboverm_real_mrent_90']==0)|(data['aboverm_real_mhval_90']==0))&
                                 ((data['aboverm_per_all_li_90']+
                                   data['aboverm_per_nonwhite_90']+
                                   data['aboverm_per_rent_90']+
                                   (1-data['aboverm_per_col_90']))>2), 1, 0)


### ***** 2000 *****
### 3/4 Criteria that needs to be met
data['vul_gent_00'] = np.where(((data['aboverm_real_mrent_00']==0)|(data['aboverm_real_mhval_00']==0))&
                                 ((data['aboverm_per_all_li_00']+
                                   data['aboverm_per_nonwhite_00']+
                                   data['aboverm_per_rent_00']+
                                   (1-data['aboverm_per_col_00']))>2), 1, 0)

### ***** 2018 *****
### 3/4 Criteria that needs to be met
data['vul_gent_18'] = np.where(((data['aboverm_real_mrent_18']==0)|(data['aboverm_real_mhval_18']==0))&
                                 ((data['aboverm_per_all_li_18']+
                                   data['aboverm_per_nonwhite_18']+
                                   data['aboverm_per_rent_18']+
                                   (1-data['aboverm_per_col_18']))>2), 1, 0)

####
# Begin Test
####
# print('VULNERABLE IN 1990')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_90'].isna()].plot(ax = ax, column = 'vul_gent_90', legend = True)
# plt.show()
# print('There are ', data['vul_gent_90'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_90']==1).sum(), 'census tracts vulnerable in 1990')
####
# End Test
####

####
# Begin Test
####
# print('VULNERABLE IN 2000')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_00'].isna()].plot(ax = ax, column = 'vul_gent_00', legend = True)
# plt.show()
# print('There are ', data['vul_gent_00'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_00']==1).sum(), 'census tracts vulnerable in 2000')
####
# End Test
####

####
# Begin Test
####
# print('VULNERABLE IN 2018')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_18'].isna()].plot(ax = ax, column = 'vul_gent_18', legend = True)
# plt.show()
# print('There are ', data['vul_gent_18'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_18']==1).sum(), 'census tracts vulnerable in 2018')
####
# End Test
####

####
# Begin Test
####
# print('VULNERABLE IN 2018')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_18'].isna()].plot(ax = ax, column = 'vul_gent_18', legend = True)
# plt.show()
# print('There are ', data['vul_gent_18'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_18']==1).sum(), 'census tracts vulnerable in 2018')
####
# End Test
####

####
# Begin Test
####
# print('VULNERABLE IN BOTH YEARS')
# ax = data.plot(color = 'grey')
# ax = data[~data['vulnerable'].isna()].plot(ax = ax, column = 'vulnerable', legend = True)
# plt.show()
# print('There are ', data['vulnerable'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vulnerable']==1).sum(), 'census tracts vulnerable in both years')
####
# End Test
####

####
# Begin Test
####
# print('VULNERABLE IN 2018')
# ax = data.plot(color = 'grey')
# ax = data[~data['vul_gent_18'].isna()].plot(ax = ax, column = 'vul_gent_18', legend = True)
# plt.show()
# print('There are ', data['vul_gent_18'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['vul_gent_18']==1).sum(), 'census tracts vulnerable in 2018')
####
# End Test
####

# ==========================================================================
# Define Hot Market Variable
# ==========================================================================

# Hot market in '00 and '18 - make it a flag
# --------------------------------------------------------------------------
# Note: Hot market in '00 and '18 - make it a flag:
# Using old methodology for now, will update later
# New methodology would be rapid increase (2013-2018)

data['hotmarket_00'] = np.where((data['aboverm_pctch_real_mhval_90_00']==1)|
                                  (data['aboverm_pctch_real_mrent_90_00']==1), 1, 0)
data['hotmarket_00'] = np.where((data['aboverm_pctch_real_mhval_90_00'].isna())|
                                  (data['aboverm_pctch_real_mrent_90_00'].isna()), np.nan, data['hotmarket_00'])

data['hotmarket_18'] = np.where((data['aboverm_pctch_real_mhval_00_18']==1)|
                                  (data['aboverm_pctch_real_mrent_12_18']==1), 1, 0)
data['hotmarket_18'] = np.where((data['aboverm_pctch_real_mhval_00_18'].isna())|
                                  (data['aboverm_pctch_real_mrent_12_18'].isna()), np.nan, data['hotmarket_18'])

####
# Begin Test
####
# print('HOT MARKET 2018')
# ax = data.plot(color = 'white')
# ax = data[~data['hotmarket_18'].isna()].plot(ax = ax, column = 'hotmarket_18', legend = True)
# plt.show()
# print('There are ', data['hotmarket_18'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['hotmarket_18']==1).sum(), 'census tracts with hot market in 2018')
####
# End Test
####

####
# Begin Test
####
# print('HOT MARKET 2000')
# ax = data.plot(color = 'white')
# ax = data[~data['hotmarket_00'].isna()].plot(ax = ax, column = 'hotmarket_00', legend = True)
# plt.show()
# print('There are ', data['hotmarket_00'].isna().sum(), 'census tract with NaN as data')
# print('There are ', (data['hotmarket_00']==1).sum(), 'census tracts with hot market in 2000')
####
# End Test
####

# ==========================================================================
# Define Experienced Gentrification Variable
# ==========================================================================

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


# # 2000 - 2018
data['gent_00_18'] = np.where((data['vul_gent_00']==1)&
                                (data['aboverm_ch_per_col_00_18']==1)&
                                (data['aboverm_pctch_real_hinc_00_18']==1)&
                                (data['lostli_18']==1)&
                                # (data['ch_per_limove_12_18']<0)&
                                (data['hotmarket_18']==1), 1, 0)

data['gent_00_18_urban'] = np.where((data['vul_gent_00']==1)&
                                (data['aboverm_ch_per_col_00_18']==1)&
                                (data['aboverm_pctch_real_hinc_00_18']==1)&
                                # (data['lostli_18']==1)&
                                # (data['ch_per_limove_12_18']<0)&
                                (data['hotmarket_18']==1), 1, 0)


# Add lag variables
data = pd.merge(data,lag[['dp_PChRent','dp_RentGap','GEOID', 'tr_rent_gap', 'rm_rent_gap', 'dense']],on='GEOID')

####
# Begin Test
####
# print('GENTRIFICATION 1990 - 2000')
# ax = data.plot(color = 'white')
# ax = data[~data['gent_90_00'].isna()].plot(ax = ax, column = 'gent_90_00', legend = True)
# plt.show()
# print('There are ', data['gent_90_00'].isna().sum(), 'census tract with NaN as data')
# print(str((data['gent_90_00']==1).sum()), 'census tracts were gentrified 1990-2000')
####
# End Test
####


####
# Begin Test
####
# print('GENTRIFICATION 2000 - 2018')
# ax = data.plot(color = 'white')
# ax = data[~data['gent_00_18'].isna()].plot(ax = ax, column = 'gent_00_18', legend = True)
# plt.show()
# print('There are ', data['gent_00_18'].isna().sum(), 'census tract with NaN as data')
# print(str((data['gent_00_18']==1).sum()), 'census tracts were gentrified 2000-2018')
####
# End Test
####


# ==========================================================================
# ==========================================================================
# ==========================================================================
# Construct Typology
# ==========================================================================
# ==========================================================================
# ==========================================================================
# Note: Make flags for each typology definition
# goal is to make them flags so we can compare across typologies to check 
# if any are being double counted or missed. 
# Note on missing data: will code it so that the typology is missing if any 
# of the core data elements are missing, but for any additional risk or stability 
# criteria, will be coded so that it pulls from a shorter list 
# if any are missing so as not to throw it all out

# ==========================================================================
# Stable/Advanced Exclusive
# ==========================================================================

### ********* Stable/advanced exclusive *************
df = data
df['SAE'] = 0
df['SAE'] = np.where((df['pop00flag']==1)&
                     (df['high_pdmt_medhhinc_00'] == 1)&
                     (df['high_pdmt_medhhinc_18'] == 1)&                 
                     ((df['lmh_flag_encoded'] == 3)|(df['lmh_flag_encoded'] == 6))&
                     ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2)|
                     (df['change_flag_encoded'] == 3)), 1, 0)

df['SAE'] = np.where((df['pop00flag'].isna())|
                     (df['high_pdmt_medhhinc_00'].isna())|
                     (df['high_pdmt_medhhinc_18'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna()), np.nan, df['SAE'])

# replace SAE=1 if A==1 & (A==1) & (B==1) & (C==5| D==6)& (E==18 | F==19 | G==20)


####
# Begin Test
####
# print('STABLE ADVANCED EXCLUSIVE')
# ax = data.plot(color = 'white')
# ax = data[~data['SAE'].isna()].plot(ax = ax, column = 'SAE', legend = True)
# plt.show()
# print('There are ', data['SAE'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['SAE']==1).sum()), 'Stable Advanced Exclusive CT')
####
# End Test
####

### Filters only exclusive tracts
exclusive = data[data['SAE']==1].reset_index(drop=True)

### Flags census tracts that touch exclusive tracts (excluding exclusive)
proximity = df[df.geometry.touches(exclusive.unary_union)]

####
# Begin Test
####
# ax = data.plot()
# exclusive.plot(ax = ax, color = 'grey')
# proximity.plot(ax = ax, color = 'yellow')
# plt.show()
####
# End Test
####

# ==========================================================================
# Advanced Gentrification
# ==========================================================================

### ************* Advanced gentrification **************
# df = data
df['AdvG'] = 0
df['AdvG'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_18'] == 1)|(df['mix_mod_medhhinc_18'] == 1)|
                     (df['mix_high_medhhinc_18'] == 1)|(df['high_pdmt_medhhinc_18'] == 1))&                    
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                    ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2)|(df['change_flag_encoded'] == 3))&
                    ((df['pctch_real_mhval_00_18'] > 0) | (df['pctch_real_mrent_12_18'] > 0)) & 
                     (
                        # (df['gent_90_00']==1)|
                        # (df['gent_00_18']==1)
                        ((df['dense'] == 0) & (df['gent_90_00'] == 1))|
                        ((df['dense'] == 0) & (df['gent_00_18'] == 1))|
                        ((df['dense'] == 1) & (df['gent_90_00_urban'] == 1))|
                        ((df['dense'] == 1) & (df['gent_00_18_urban'] == 1))
                    ), 1, 0)

df['AdvG'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_18'].isna())|
                     (df['mix_mod_medhhinc_18'].isna())|
                     (df['mix_high_medhhinc_18'].isna())|
                     (df['high_pdmt_medhhinc_18'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['gent_90_00_urban'].isna())|
                     (df['gent_00_18_urban'].isna())|
                     (df['pctch_real_mhval_00_18'].isna())|
                     (df['pctch_real_mrent_12_18'].isna())|
                     (df['gent_00_18'].isna()), np.nan, df['AdvG'])

df['AdvG'] = np.where((df['AdvG'] == 1)&(df['SAE']==1), 0, df['AdvG']) ### This is to account for double classification

####
# Begin Test
####
# print('ADVANCED GENTRIFICATION')
# ax = data.plot(color = 'white')
# ax = data[~data['AdvG'].isna()].plot(ax = ax, column = 'AdvG', legend = True)
# plt.show()
# print('There are ', data['AdvG'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['AdvG']==1).sum()), 'Advanced Gentrification CT')
####
# End Test
####

# ==========================================================================
# At Risk of Becoming Exclusive 
# ==========================================================================

# df = data
df['ARE'] = 0
df['ARE'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_18'] == 1)|(df['mix_mod_medhhinc_18'] == 1)|
                     (df['mix_high_medhhinc_18'] == 1)|(df['high_pdmt_medhhinc_18'] == 1))&                    
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                    ((df['change_flag_encoded'] == 1)|(df['change_flag_encoded'] == 2)), 1, 0)

df['ARE'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_18'].isna())|
                     (df['mix_mod_medhhinc_18'].isna())|
                     (df['mix_high_medhhinc_18'].isna())|
                     (df['high_pdmt_medhhinc_18'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna()), np.nan, df['ARE'])

df['ARE'] = np.where((df['ARE'] == 1)&(df['AdvG']==1), 0, df['ARE']) ### This is to account for double classification
df['ARE'] = np.where((df['ARE'] == 1)&(df['SAE']==1), 0, df['ARE']) ### This is to account for double classification

####
# Begin Test
####
# print('AT RISK OF BECOMING EXCLUSIVE')
# ax = data.plot(color = 'white')
# ax = data[~data['ARE'].isna()].plot(ax = ax, column = 'ARE', legend = True)
# plt.show()
# print('There are ', data['ARE'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['ARE']==1).sum()), 'At Risk of Exclusive CT')
####
# End Test
####

# ==========================================================================
# Becoming Exclusive
# ==========================================================================

### *********** Becoming exclusive *************
df['BE'] = 0
df['BE'] = np.where((df['pop00flag']==1)&
                    ((df['mod_pdmt_medhhinc_18'] == 1)|(df['mix_mod_medhhinc_18'] == 1)|
                     (df['mix_high_medhhinc_18'] == 1)|(df['high_pdmt_medhhinc_18'] == 1))&
                    ((df['lmh_flag_encoded'] == 2)|(df['lmh_flag_encoded'] == 3)|
                     (df['lmh_flag_encoded'] == 5)|(df['lmh_flag_encoded'] == 6))&
                     (df['change_flag_encoded'] == 3)&
                     (df['lostli_18']==1)&
                     (df['per_limove_18']<df['per_limove_12'])&
                     (df['real_hinc_18']>df['real_hinc_00']), 1, 0)

df['BE'] = np.where((df['pop00flag'].isna())|
                     (df['mod_pdmt_medhhinc_18'].isna())|
                     (df['mix_mod_medhhinc_18'].isna())|
                     (df['mix_high_medhhinc_18'].isna())|
                     (df['high_pdmt_medhhinc_18'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['lostli_18'].isna())|
                     (df['per_limove_18'].isna())|
                     (df['per_limove_12'].isna())|
                     (df['real_hinc_18'].isna())|
                     (df['real_hinc_00'].isna()), np.nan, df['BE'])

df['BE'] = np.where((df['BE'] == 1)&(df['SAE']==1), 0, df['BE']) ### This is to account for double classification

####
# Begin Test
####
# print('BECOMING EXCLUSIVE')
# ax = data.plot(color = 'white')
# ax = data[~data['BE'].isna()].plot(ax = ax, column = 'BE', legend = True)
# plt.show()
# print('There are ', data['BE'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['BE']==1).sum()), 'Becoming Exclusive CT')
####
# End Test
####

# ==========================================================================
# Stable Moderate/Mixed Income
# ==========================================================================

df['SMMI'] = 0
df['SMMI'] = np.where((df['pop00flag']==1)&
                     ((df['mod_pdmt_medhhinc_18'] == 1)|(df['mix_mod_medhhinc_18'] == 1)|
                      (df['mix_high_medhhinc_18'] == 1)|(df['high_pdmt_medhhinc_18'] == 1))&             
                     (df['ARE']==0)&(df['BE']==0)&(df['SAE']==0)&(df['AdvG']==0), 1, 0)

df['SMMI'] = np.where((df['pop00flag'].isna())|
                      (df['mod_pdmt_medhhinc_18'].isna())|
                      (df['mix_mod_medhhinc_18'].isna())|
                      (df['mix_high_medhhinc_18'].isna())|
                      (df['high_pdmt_medhhinc_18'].isna()), np.nan, df['SMMI'])
####
# Begin Test
####
# print('Stable Moderate/Mixed Income')
# ax = data.plot(color = 'white')
# ax = data[~data['SMMI'].isna()].plot(ax = ax, column = 'SMMI', legend = True)
# plt.show()
# print('There are ', data['SMMI'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['SMMI']==1).sum()), 'Stable Moderate/Mixed Income CT')
####
# End Test
####

# ==========================================================================
# At Risk of Gentrification
# ==========================================================================

### ****ARG ****
df['ARG'] = 0
df['ARG'] = np.where((df['pop00flag']==1)&
                    ((df['low_pdmt_medhhinc_18']==1)|(df['mix_low_medhhinc_18']==1))&
                    ((df['lmh_flag_encoded']==1)|(df['lmh_flag_encoded']==4))&
                    ((df['change_flag_encoded'] == 1)|(df['ab_90percentile_ch']==1)|(df['rent_90percentile_ch']==1))&
                    (df['gent_90_00']==0)&
                    ((df['dp_PChRent'] == 1)|(df['dp_RentGap'] == 1)) &
                    (df['vul_gent_18']==1)&
                    (df['gent_00_18']==0), 1, 0)

df['ARG'] = np.where((df['pop00flag'].isna())|
                     (df['low_pdmt_medhhinc_18'].isna())|
                     (df['mix_low_medhhinc_18'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['rent_90percentile_ch'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['vul_gent_00'].isna())|
                     (df['dp_PChRent'].isna())|
                     (df['dp_RentGap'].isna())|
                     (df['gent_00_18'].isna()), np.nan, df['ARG'])



####
# Begin Test
####
# print('AT RISK OF GENTRIFICATION')
# ax = data.plot(color = 'white')
# ax = data[~df['ARG'].isna()].plot(ax = ax, column = 'ARG', legend = True)
# plt.show()
# print('There are ', data['ARG'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['ARG']==1).sum()), 'At Risk of Gentrification CT')
####
# End Test
####

# ==========================================================================
# Early/Ongoing Gentrification
# ==========================================================================

###************* Early/ongoing gentrification **************
### ****EOG ****
df['EOG'] = 0
df['EOG'] = np.where((df['pop00flag']==1)& # pop > 500
                    ((df['low_pdmt_medhhinc_18']==1)|(df['mix_low_medhhinc_18']==1))& # low and mix low income households. 
                     # (df['ch_per_limove_12_18']<0)& # percent change in low income movers              
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
                        # (df['gent_00_18']==1)
                        ((df['dense'] == 0) & (df['gent_90_00'] == 1))|
                        ((df['dense'] == 0) & (df['gent_00_18'] == 1))|
                        ((df['dense'] == 1) & (df['gent_90_00_urban'] == 1))|
                        ((df['dense'] == 1) & (df['gent_00_18_urban'] == 1))
                    ), 1, 0) # gentrified (includes hotmarket)

df['EOG'] = np.where((df['pop00flag'].isna())|
                     (df['low_pdmt_medhhinc_18'].isna())|
                     (df['mix_low_medhhinc_18'].isna())|
                     (df['ch_per_limove_12_18'].isna())|
                     (df['lmh_flag_encoded'].isna())|
                     (df['change_flag_encoded'].isna())|
                     (df['gent_90_00'].isna())|
                     (df['gent_00_18'].isna())|                     
                     (df['gent_90_00_urban'].isna())|
                     (df['gent_00_18_urban'].isna())|
                     (df['ab_50pct_ch'].isna())|
                     (df['hv_abrm_ch'].isna())|
                     (df['rent_abrm_ch'].isna())|
                     (df['rent_50pct_ch'].isna()), np.nan, df['EOG'])

######
# Begin Test
######
# print('EARLY/ONGOING GENTRIFICATION')
# ax = data.plot(color = 'white')
# ax = data[~data['EOG'].isna()].plot(ax = ax, column = 'EOG', legend = True)
# plt.show()
# print('There are ', data['EOG'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['EOG']==1).sum()), 'Early/Ongoing Gentrification CT')
######
# End Test
######

# ==========================================================================
# Ongoing Displacement
# ==========================================================================

# df = data

df['OD'] = 0
df['OD'] = np.where((df['pop00flag']==1)&
                ((df['low_pdmt_medhhinc_18']==1)|(df['mix_low_medhhinc_18']==1))&
                (df['lostli_18']==1), 1, 0)

df['OD_loss'] = np.where((df['pop00flag'].isna())|
                    (df['low_pdmt_medhhinc_18'].isna())|
                    (df['mix_low_medhhinc_18'].isna())|
                    (df['lostli_18'].isna()), np.nan, df['OD'])

df['OD'] = np.where((df['OD'] == 1)&(df['ARG']==1), 0, df['OD']) ### This is to account for double classification
df['OD'] = np.where((df['OD'] == 1)&(df['EOG']==1), 0, df['OD']) ### This is to account for double classification

######
# Begin Test
######
# print('ONGOING DISPLACEMENT')
# ax = data.plot(color = 'white')
# ax = data[~data['OD'].isna()].plot(ax = ax, column = 'OD', legend = True)
# plt.show()
# print('There are ', data['OD'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['OD']==1).sum()), 'Ongoing Displacement CT')
######
# End Test
######

# ==========================================================================
# Low-Income/Susceptible to Displacement
# ==========================================================================

df['LISD'] = 0
df['LISD'] = np.where((df['pop00flag'] == 1)&
                     ((df['low_pdmt_medhhinc_18'] == 1)|(df['mix_low_medhhinc_18'] == 1))&
                     (df['OD']!=1) & (df['ARG']!=1) & (df['EOG']!=1), 1, 0)

######
# Begin Test
######
# print('STABLE LOW INCOME TRACTS')
# ax = data.plot(color = 'white')
# ax = data[~data['LISD'].isna()].plot(ax = ax, column = 'LISD', legend = True)
# plt.show()
# print('There are ', data['LISD'].isna().sum(), 'census tract with NaN as data')
# print('There are ',str((data['LISD']==1).sum()), 'Stable Low Income CT')
######
# End Test
######

# ==========================================================================
# Create Typology Variables for All Dummies
# ==========================================================================

df['double_counted'] = (df['LISD'].fillna(0) + df['OD'].fillna(0) + df['ARG'].fillna(0) + df['EOG'].fillna(0) +
                       df['AdvG'].fillna(0) + df['ARE'].fillna(0) + df['BE'].fillna(0) + df['SAE'] + df['SMMI'])
    
df['typology'] = np.nan
df['typology'] = np.where(df['LISD'] == 1, 1, df['typology'])
df['typology'] = np.where(df['OD'] == 1, 2, df['typology'])
df['typology'] = np.where(df['ARG'] == 1, 3, df['typology'])
df['typology'] = np.where(df['EOG'] == 1, 4, df['typology'])
df['typology'] = np.where(df['AdvG'] == 1, 5, df['typology'])
df['typology'] = np.where(df['SMMI'] == 1, 6, df['typology'])
df['typology'] = np.where(df['ARE'] == 1, 7, df['typology'])
df['typology'] = np.where(df['BE'] == 1, 8, df['typology'])
df['typology'] = np.where(df['SAE'] == 1, 9, df['typology'])
df['typology'] = np.where(df['double_counted']>1, 99, df['typology'])


# Double Classification Check
# --------------------------------------------------------------------------

cat_i = list()

# df = data
for i in range (0, len (df)):
    categories = list()
    if df['LISD'][i] == 1:
        categories.append('LISD')
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

######
# Begin Test
######
# f, ax = plt.subplots(1, figsize=(8, 8))
# data.plot(ax=ax, color = 'lightgrey')
# lims = plt.axis('equal')
# df[~data['typology'].isna()].plot(ax = ax, column = 'typ_cat', legend = True)
# plt.show()
# print('There are ', data['typology'].isna().sum(), 'census tract with NaN as data')
######
# End Test
######

# ==========================================================================
# Export Date
# ==========================================================================
# Note: You'll need to change the 'output path' variable above in order to output 
# to your desired location

df['FIPS'] = df['FIPS'].astype(str)
df = df.drop(columns = 'geometry')
df.to_csv(output_path+'/typologies/'+city_name.replace(" ", "")+'_typology_output.csv')

