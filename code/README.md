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

For the SPARCC released maps, which reflect 2017 ACS data, navigate to `sparcc/code/sparcc_code` and execute the following commands in your terminal: 

```
python 2017_1_data.py Atlanta
python 2017_1_data.py Chicago
python 2017_1_data.py Denver
python 2017_1_data.py Memphis

Rscript 2017_2_create_lag_vars.r

python 2017_3_typology.py Atlanta
python 2017_3_typology.py Chicago
python 2017_3_typology.py Denver
python 2017_3_typology.py Memphis

Rscript 2017_4_SPARCC_Maps.r

```
For all updates, navigate to `sparcc/code/` and run the following scripts. Currently this is set to 2018 ACS pulls. *Any updates will require code edits for the respective city and year.* 

```
# 1. data download
python 1_data_download.py Atlanta
python 1_data_download.py Chicago
python 1_data_download.py Denver
python 1_data_download.py Memphis
python 1_data_download.py 'Los Angeles'
python 1_data_download.py 'San Francisco'
python 1_data_download.py Seattle
python 1_data_download.py Cleveland
python 1_data_download.py Boston 

# 2. data curation
python 2_data_curation.py Atlanta
python 2_data_curation.py Chicago
python 2_data_curation.py Denver
python 2_data_curation.py Memphis
python 2_data_curation.py 'Los Angeles'
python 2_data_curation.py 'San Francisco'
python 2_data_curation.py Seattle
python 2_data_curation.py Cleveland
python 2_data_curation.py Boston 


# 3. create lag variables
Rscript 2_create_lag_vars.r

# 4. create typologies
python 4_typology.py Atlanta
python 4_typology.py Chicago
python 4_typology.py Denver
<!-- python 4_typology.py Memphis -->
python 4_typology.py 'Los Angeles'
python 4_typology.py 'San Francisco'
python 4_typology.py Seattle
python 4_typology.py Cleveland
<!-- python 4_typology.py Boston -->

# 5. create maps
Rscript 5_SPARCC_Maps.r

# (optional) 6. Encrypt the maps
# To encrypt (on a mac)
# brew install npm
# npm install -g staticrypt # see https://github.com/robinmoisson/staticrypt/
staticrypt ../maps/atlanta_udp.html atlantasparcc -o ../maps/atlanta_udp.html
staticrypt ../maps/denver_udp.html denversparcc -o ../maps/denver_udp.html
staticrypt ../maps/memphis_udp.html memphissparcc -o ../maps/memphis_udp.html
staticrypt ../maps/chicago_udp.html chicagosparcc -o ../maps/chicago_udp.html
staticrypt ../maps/losangeles_udp.html lasparcc -o ../maps/losangeles_udp.html
staticrypt ../maps/sanfrancisco_udp.html sfsparcc -o ../maps/sanfrancisco_udp.html
staticrypt ../maps/seattle_udp.html seattlesparcc -o ../maps/seattle_udp.html
staticrypt ../maps/cleveland_udp.html clevelandsparcc -o ../maps/cleveland_udp.html
staticrypt ../maps/boston_udp.html bostonsparcc -o ../maps/boston_udp.html
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
    Visit the URL https://dsl.richmond.edu/panorama/redlining/. 
    Navigate to Downloads & Data and select all GEOJSON files within the region of your choice 
    (note that there may be more than one relevant map, and relevant maps may come from more than one state).

Zillow Data:
    Visit the URL https://www.zillow.com/research/data/. 
    Under "Home values," select "ZHVI All Homes (SFR, Condo/Co-op) Time Series ($)" as Data Type and ZIP Code as Geography, then download. 
        ***^note that this data has changed since our original download: our team needs to update the code to reflect this!***

Transit Data:
    Visit the URL https://toddata.cnt.org/downloads.php (you will need to register).  
    Select and download "All US Stations".

LIHTC Properties Data:
    Visit the URL http://hudgis-hud.opendata.arcgis.com/datasets/907edabaf7974f7fb59beef14c4b82f6_0.
    Download as "Spreadsheet".

Public Housing Buildings Data:
    Visit the URL https://hudgis-hud.opendata.arcgis.com/datasets/public-housing-buildings.
    Download as "Spreadsheet". 
    Compress as a .gz file.

Hospitals Data:
    Visit the URL https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals. 
    Download as "Spreadsheet".

Universities Data:
    Visit the URL https://nces.ed.gov/ipeds/use-the-data/download-access-database. 
    Download "2016-2017 Access".

ZIP Codes to Census Tracts Crosswalk:
    Visit the URL http://mcdc.missouri.edu/applications/geocorr2014.html. 
    Select the whole list of states as "state(s) to process".
    Set the source geography as "2010 Geographies: ZIP/ZCTA." 
    Set the target geography as "2010 Geographies: Census Tract." 
    Set the weighting variable as "Population (2010 census)." 
        ***^need to confirm this variable***
    Download as a CSV.
        ***^need to update: they then need to follow steps outlined in a do-file***
        
Crosswalks from 1990 and 2000 to 2010:
    Visit the URL https://s4.ad.brown.edu/projects/diversity/Researcher/LTBDDload/DataList.aspx.
    Under User Tools, select Excel as format type and download two files: one for 1990-2010, and one for 2000-2010.

PUMS Data:
    Visit the URL https://data2.nhgis.org/main. 
    Select Years: 5-Year Ranges --> 2013-2017. 
        ***^update to 2014-2018?***
    Select Geographic Levels: Census Tract.
    Download two datasets: B25063 (Gross Rent) and B25094 (Selected Monthly Owner Costs).


# Strong, Prosperous, and Resilient Communities Challenge (SPARCC) Project <a href='https://www.urbandisplacement.org/'><img src ="./assets/images/blue_UDP_logo.png" align="right" height="120" />
</a>
 
## Overview
 
This repository holds all the code needed to produce the [SPARCC maps](https://urbandisplacement.org) visualizing neighborhood change in several US regions. We provide this code so that you may be able to replicate this work in your own state/city.
 
*Any modified code that is taken from this repo and not reviewed by the Urban Displacement Project is not endorsed by us and should be documented accordingly as not endorsed by the Urban Displacement Project.*
 
## Code & Usage
 
To run the code, fork this repository and navigate to `code/README.md` file. You will have to edit the files to include your state and city accordingly. Once completed, follow the instructions in the readme to download all external datasets for your specific region that will be required, then run the five consecutive files of code in a terminal window, as indicated in the readme replacing your state/city name.
 
## Contact
 
Please feel free to reach out to us for questions, help, or suggestions.
 
# SPARCC Project <a href='https://www.urbandisplacement.org/'><img src ="./assets/images/blue_UDP_logo.png" align="right" height="120" />
</a>

