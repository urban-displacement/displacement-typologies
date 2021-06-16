
# SCAG Region Displacement and Gentrification Typologies



## Table of Contents

* [Project Overview](#Project-Overview)
* [Typologies](#typologies)
* [Code & Usage](#Code-&-Usage)
* [Maps and Downloads](#Maps-and-Downloads)
* [Download Data](#download-data)
* [Cite the Code](#citation)

<!-- Project Overview -->
## Project Overview




Since 2011, UC Berkeley's [Urban Displacement Project](https://urbandisplacement.org) has partnered with universities, government agencies, philanthropy, and local organizations, in an effort to understand unique dynamics of displacement and potential negative impacts of gentrification on communities across the United States.  These efforts have culminated in the creation of interactive [typology maps](https://urbandisplacement.org), which summarize housing market dynamics and displacement and gentrification risk into eight distinct categories. 
 
This repository holds all the code needed to produce [UDP's Displacement Typology maps](https://urbandisplacement.org). By making annotated codebooks available online, UDP hopes to provide an opportunity for others to improve and build upon past research, in order to better capture dynamics in jurisdictions we’ve previously researched. Our Jupyter notebooks will make it possible for us to crowdsource the local knowledge about places that our secondary data sources often fail to capture. We also hope that methods can be more easily adapted and applied to other cities and regions, starting conversations around local dynamics of neighborhood change.  
 
*Any modified code that is taken from this repo and not reviewed by the Urban Displacement Project is not endorsed by us and should be documented accordingly as not endorsed by the Urban Displacement Project.*
 
<!-- TYPOLOGIES -->
## Typologies

This repository is a continuation of the [Urban Displacement Replication Project](https://www.urbandisplacement.org/sites/default/files/udp_replication_project_methodology_10.16.2020-converted.pdf). **Because these maps have not been groundtruthed to verify accuracy in accordance with UDP's methodology, they are not officially endorsed by the UDP.**  You can read the last report that UDP conducted with SPARCC [here](https://www.urbandisplacement.org/sites/default/files/udp_replication_project_methodology_10.16.2020-converted.pdf) to learn more about this projects methodology and typologies. 

UDP's Displacement Typologies use housing and demographic data from the US Census, as well as real estate market data from Zillow to classify a metropolitain area's census tracts into eight distinct categories. Each category represents a stage of neighborhood change, although should not be taken to represent a linear trajectory or to predetermine neighborhood outcomes. Instead, typologies allow practictionners and researchers to see patterns in their regions over a specified time period, and are meant to start conversations about how policy interventions and investment could respond and support more equitable development.


It is important to note that in considering the entire metropolitan region, UDP's typologies classify both low- and middle-income neighborhods at risk of or experiencing displacement or gentrification, as well as high-income neighborhoods where housing markets are becoming increasingly 'exclusive' to low income residents. UDP believes that classifying tracts in such a way allows practionners to get a broader picture of neighborhood dynamics, specifically the concentration of poverty and wealth within a region. 

UDP's Typologies have evovled over time in response to community and partner feedback and the availability of new data sources. This code represents the code's most recent iteration. It makes use of data from the 2013-2018 American Community Survey; 1990, 2010 and 2000 Dicennial Census; and 2012-2017 Zillow Home Value and Rent Indices. Overlay data comes from a variety of sources, detailed in `code/README.md`.

**Typologies Graphic**

<a href='https://www.urbandisplacement.org/'><imgsrc='.assets/images/typology_sheet_2018.png'/><a>


 
<!-- Maps and Downloads -->
## Maps and Downloads


[SCAG Map](https://ereifsnyder.github.io/displacement-typologies/maps/SCAG_udp_dense_rural.html)

* GeoPackages (similar to shapefiles) & CSV's with GEOID & Typologies: [Download](https://github.com/ereifsnyder/displacement-typologies/blob/main/data/downloads_for_public/scag.gpkg)
* Full Typology as Shapefile: [Download](https://github.com/ereifsnyder/displacement-typologies/blob/main/data/downloads_for_public/scag.zip)
* Full typology data as CSV: [Download](https://github.com/ereifsnyder/displacement-typologies/blob/main/data/downloads_for_public/scag.csv)
* Codebook for full typology dataset: [link](https://github.com/urban-displacement/displacement-typologies/blob/main/data/outputs/typologies/typologies_codebook.md)


## Citation
Tim Thomas, Anna Cash, Anna Driscoll, Gabriela Picado Aguilar, Carson Hartman, Julia Greenberg, Alex Ramiller, Emery Reifsnyder, Miriam Zuk, and Karen Chapple. “Urban-displacement/displacement-typologies: Release 1.1”. https://github.com/ereifsnyder/displacement-typologies. doi:10.5281/zenodo.4356684.



