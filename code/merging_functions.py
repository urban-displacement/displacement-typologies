
# coding: utf-8

# In[]:

import numpy as np
def trtid10_to_FIPS (dataframe):

    ### renames trtid10 to FIPS
    new_dataframe = dataframe.rename(columns = {'trtid10':'FIPS'})
    ### formats the FIPS code into a 12 digit str
    new_dataframe['FIPS'] = new_dataframe['FIPS'].apply(np.int).apply(lambda x: '{:011}'.format(x))

    return new_dataframe

### Check for repeated data
# temp = city_shp_merge.merge(tenure_2017, on = 'FIPS')
def repeated_columns(dataframe):
    column = list()
    for i in range (0, len(dataframe.columns)):
        name = dataframe.columns[i].split('_')
        length = len(name)
        if name[length-1] == 'x':
            column.append(dataframe.columns[i])
    return column
