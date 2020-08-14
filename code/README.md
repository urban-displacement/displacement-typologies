# Code processing outline

Currently, the SPARCC typology is set up for:

* Atlanta
* Chicago
* Denver
* Memphis
* Los Angeles
* San Francisco (in progress)
* Seattle (in progress)
* Cleveland (in progress)
* Boston (in progress)


Each of the files are named in order of operation. To run the code, do the following in a terminal window. 

```
# 1. data download
python 1_data.py Atlanta
python 1_data.py Chicago
python 1_data.py Denver
python 1_data.py Memphis
python 1_data.py 'Los Angeles'
python 1_data.py 'San Francisco'
<!-- on hold below -->
python 1_data.py Seattle
python 1_data.py Cleveland
python 1_data.py Boston 
* notes: Boston Geometry is not running

# 2. create lag variables
Rscript 2_create_lag_vars.r

# 3. create typologies
python 3_typology.py Atlanta
python 3_typology.py Chicago
python 3_typology.py Denver
python 3_typology.py Memphis
python 3_typology.py 'Los Angeles'
python 3_typology.py 'San Francisco'
python 3_typology.py Seattle
python 3_typology.py Cleveland
python 3_typology.py Boston

# 4. create maps
Rscript 4_SPARCC_Maps.r

# 5. Encrypt the maps
# To encrypt (on a mac)
# brew install npm
# npm install -g staticrypt # see https://github.com/robinmoisson/staticrypt/
staticrypt ../maps/atlanta.html atlantasparcc -o ../maps/atlanta.html
staticrypt ../maps/denver.html denversparcc -o ../maps/denver.html
staticrypt ../maps/memphis.html memphissparcc -o ../maps/memphis.html
staticrypt ../maps/chicago.html chicagosparcc -o ../maps/chicago.html
staticrypt ../maps/losangeles_check.html lasparcc -o ../maps/losangeles_check.html
staticrypt ../maps/sanfrancisco_check.html sfsparcc -o ../maps/sanfrancisco_check.html
staticrypt ../maps/seattle_check.html seattlesparcc -o ../maps/seattle_check.html
staticrypt ../maps/cleveland_check.html clevelandsparcc -o ../maps/cleveland_check.html
staticrypt ../maps/boston_check.html bostonsparcc -o ../maps/boston_check.html
```

## Adding cities

To add other cities, you will have to edit the following files accordingly

* `1_data.py`
* `2_create_lag_vars.r`
* `3_typology.py`
* `4_SPARCC_Maps.r`

## Changes: 2020.04.01
ab_90percentile_ch = 
    * zillow 2012 to 2017 home value, 
    * ARG

rent_90percentile_ch = 
    * ACS rent 2012 to 2017, 
    * ARG

ab_50pct_ch = 
    * zillow 2012 t0 2017 home value, 
    * EOG

rent_50pct_ch = 
    * ACS rent 2012 to 2017, 
    * EOG

aboverm_pctch_real_mrent_12_17 = 
    * ACS 2012 to 2017, 
    * Hot Market, 
    * gent_00_17, 
    * AdvG == 1 & ARG == 0 & EOG == 1

advg requires that either home value percent change or rent percent change are positive



## Downloading external datasets

While much of the data used in this methodology is pulled from an API, others will need to be downloaded separately, as follows:

Redlining Data:
    Visit the URL https://dsl.richmond.edu/panorama/redlining/, then navigate to Downloads & Data and select all GEOJSON files within the region of your choice (note that there may be more than one relevant map, and relevant maps may come from more than one state)

Zillow Data:
    Visit the URL https://www.zillow.com/research/data/. under "Home values," select "ZHVI All Homes (SFR, Condo/Co-op) Time Series ($)" as Data Type and ZIP Code as Geography, then download. 

Transit Data:
    Visit the URL https://toddata.cnt.org/downloads.php (you will need to register), then click All US Stations and download.

LIHTC Properties Data:
    Visit the URL http://hudgis-hud.opendata.arcgis.com/datasets/907edabaf7974f7fb59beef14c4b82f6_0, then download as "Spreadsheet"

Public Housing Buildings Data:
    Visit the URL https://hudgis-hud.opendata.arcgis.com/datasets/public-housing-buildings, then download as "Spreadsheet"
****then compress via gzip? need to finalize this****

Hospitals Data:
    Visit the URL https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals, then download as "Spreadsheet"

Universities Data:
    Visit the URL https://nces.ed.gov/ipeds/use-the-data/download-access-database, then download the file called "2016-2017 Access"
