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
python3 sparcc-2017-1-data-download.py Atlanta
python3 sparcc-2017-1-data-download.py Chicago
python3 sparcc-2017-1-data-download.py Denver
python3 sparcc-2017-1-data-download.py Memphis

python3 sparcc-2017-2-data-curation.py Atlanta
python3 sparcc-2017-2-data-curation.py Chicago
python3 sparcc-2017-2-data-curation.py Denver
python3 sparcc-2017-2-data-curation.py Memphis

Rscript sparcc-2017-3-create-lag-vars.r

python3 sparcc-2017-4-typology.py Atlanta
python3 sparcc-2017-4-typology.py Chicago
python3 sparcc-2017-4-typology.py Denver
python3 sparcc-2017-4-typology.py Memphis

Rscript sparcc-2017-5-SPARCC-Maps.r

```
For the latest typologies using 2018 Census data, navigate to `sparcc/code/` and run the following scripts. Currently this is set to 2018 ACS pulls. *Any updates will require code edits for the respective city and year.* It is highly advised to save all your API data, the US Census API and US Gov data is unstable as of 2020. 

```
# 1. data download
python3 1_data_download.py Atlanta
python3 1_data_download.py Chicago
python3 1_data_download.py Denver
python3 1_data_download.py Memphis
python3 1_data_download.py 'Los Angeles'
python3 1_data_download.py 'San Francisco'
python3 1_data_download.py Seattle
python3 1_data_download.py Cleveland
<!-- python3 1_data_download.py Boston  -->

# 2. data curation
python3 2_data_curation.py Atlanta
python3 2_data_curation.py Chicago
python3 2_data_curation.py Denver
python3 2_data_curation.py Memphis
python3 2_data_curation.py 'Los Angeles'
python3 2_data_curation.py 'San Francisco'
python3 2_data_curation.py Seattle
python3 2_data_curation.py Cleveland
<!-- python3 2_data_curation.py Boston --> 


# 3. create lag variables
Rscript 3_create_lag_vars.r

# 4. create typologies
python3 4_typology.py Atlanta
python3 4_typology.py Chicago
python3 4_typology.py Denver
<!-- python3 4_typology.py Memphis -->
python3 4_typology.py 'Los Angeles'
python3 4_typology.py 'San Francisco'
python3 4_typology.py Seattle
python3 4_typology.py Cleveland
<!-- python3 4_typology.py Boston -->

# 5. create maps
Rscript 5_map_creation.r

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

<!-- ## Adding cities

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


 -->
## Downloading external datasets

While much of the data used in this methodology is pulled from an API, others will need to be downloaded separately, as follows:

**Redlining Data:**  
    Visit the URL https://dsl.richmond.edu/panorama/redlining/. 
    Navigate to Downloads & Data and select all GEOJSON files within the region of your choice 
    (note that there may be more than one relevant map, and relevant maps may come from more than one state).

**Zillow Data:**  
    Visit the URL https://www.zillow.com/research/data/. 
    Under "Home values," select "ZHVI All Homes (SFR, Condo/Co-op) Time Series ($)" as Data Type and ZIP Code as Geography, then download. 
        ***^note that this data has changed since our original download: be sure to update the code to reflect any changes in column names, etc!***

**Transit Data:**  
    Visit the URL https://toddata.cnt.org/downloads.php (you will need to register).  
    Select and download "All US Stations".

**LIHTC Properties Data:**  
    Visit the URL http://hudgis-hud.opendata.arcgis.com/datasets/907edabaf7974f7fb59beef14c4b82f6_0.
    Download as "Spreadsheet".

**Public Housing Buildings Data:**  
    Visit the URL https://hudgis-hud.opendata.arcgis.com/datasets/public-housing-buildings.
    Download as "Spreadsheet". 
    Compress as a .gz file.

**Hospitals Data:**  
    Visit the URL https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals. 
    Download as "Spreadsheet".

**Universities Data:**
    Visit the URL https://nces.ed.gov/ipeds/use-the-data/download-access-database. 
    Download "2016-2017 Access".

**ZIP Codes to Census Tracts Crosswalk:**  
    Visit the URL http://mcdc.missouri.edu/applications/geocorr2014.html. 
    Select the whole list of states as "state(s) to process".
    Set the source geography as "2010 Geographies: ZIP/ZCTA." 
    Set the target geography as "2010 Geographies: Census Tract." 
    Set the weighting variable as "Population (2010 census)." 
    Download as a CSV.
        ***note: you will need to clean this data before using***
        
**Crosswalks from 1990 and 2000 to 2010:**  
    Visit the URL https://s4.ad.brown.edu/projects/diversity/Researcher/LTBDDload/DataList.aspx.
    Under User Tools, select Excel as format type and download two files: one for 1990-2010, and one for 2000-2010.

**PUMS Data:**  
    Visit the URL https://data2.nhgis.org/main. 
    Select Years: 5-Year Ranges --> 2013-2017.
        ***should be updated to 2014-2018*** 
    Select Geographic Levels: Census Tract.
    Download two datasets: B25063 (Gross Rent) and B25094 (Selected Monthly Owner Costs).

**Industrial Sites Data:**  
    ***As of 2019, the original data file used for this overlay is no longer available***
    ***(Tim is checking this for non-SPARCC sites)***

**Opportunity Zones Data:**  
    Visit the URL https://www.cdfifund.gov/Pages/Opportunity-Zones.aspx.
    Download the linked spreadsheet called "List of designated Qualified Opportunity Zones".
    ***note: you will need to clean this data before using***

**BeltLine Overlay (Atlanta maps only):**  
    Visit the URL https://beltline.org/map/.
    Take a screenshot of the map of the BeltLine found at this URL.
    Georeference the image and trace over the BeltLine. Save as a shapefile.

