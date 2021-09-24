
# SCAG Region Displacement and Gentrification Typologies



## Table of Contents

* [Typologies](#typologies)
* [Maps and Downloads](#Maps-and-Downloads)
* [Findings](#Findings)
* [Contact](#CONTACT)





<!-- TYPOLOGIES -->
## Typologies

This repository is a continuation of the [Urban Displacement Replication Project](https://www.urbandisplacement.org/sites/default/files/udp_replication_project_methodology_10.16.2020-converted.pdf). **These maps have not been groundtruthed to verify accuracy in accordance with UDP's methodology and therefore cannot be officially endorsed by the UDP.** However, because they are based on the original UDP code, they are largely reflective of past UDP results.  You can read the last report that UDP conducted with SPARCC [here](https://www.urbandisplacement.org/sites/default/files/udp_replication_project_methodology_10.16.2020-converted.pdf) to learn more about this projects methodology and typologies.

UDP's Displacement Typologies use housing and demographic data from the US Census, as well as real estate market data from Zillow to classify a metropolitan area's census tracts into eight distinct categories. Each category represents a stage of neighborhood change, although should not be taken to represent a linear trajectory or to predetermine neighborhood outcomes. Instead, typologies allow practitioners and researchers to see patterns in their regions over a specified time period, and are meant to start conversations about how policy interventions and investment could respond and support more equitable development.

UDP's typologies are divided into 9 categories that may be generalized into three broad groups: displacement, gentrification, and exclusion. Because UDP findings indicate that displacement precedes gentrification, the first two typologies on the chart below indicate tracts that are in danger or are currently experiencing a loss in low income households. Following Displacement, the next three categories indicate the danger of gentrification, indicated by both demographic and housing market changes. Finally, the four categories in orange indicate exclusivity, indicating difficulty for low income households to enter a tract.

It is important to note that in considering the entire metropolitan region, UDP's typologies classify both low- and middle-income neighborhoods at risk of or experiencing displacement or gentrification, as well as high-income neighborhoods where housing markets are becoming increasingly 'exclusive' to low income residents. UDP believes that classifying tracts in such a way allows practitioners to get a broader picture of neighborhood dynamics, specifically the concentration of poverty and wealth within a region.

UDP's Typologies have evolved over time in response to community and partner feedback and the availability of new data sources. This code represents the code's most recent iteration. It makes use of data from the 2013-2018 American Community Survey; 1990, 2010 and 2000 Decennial Census; and 2012-2017 Zillow Home Value and Rent Indices. Overlay data comes from a variety of sources, detailed in `code/README.md`.


**Typologies Graphic**


<a href="www.urbandisplacement.org"><img src="https://www.urbandisplacement.org/sites/default/files/typology_sheet_2018_0.png" ></a>



<!-- Maps and Downloads -->
## Maps and Downloads


[SCAG Map](https://urban-displacement.github.io/displacement-typologies/maps/SCAG_udp_dense_rural.html)

* GeoPackages (similar to shapefiles) & CSV's with GEOID & Typologies: [Download](https://github.com/urban-displacement/displacement-typologies/blob/main/data/downloads_for_public/scag.gpkg)
* Full Typology as Shapefile: [Download](https://github.com/urban-displacement/displacement-typologies/blob/main/data/downloads_for_public/scag.zip)
* Full typology data as CSV: [Download](https://github.com/urban-displacement/displacement-typologies/blob/main/data/downloads_for_public/scag.csv)
* Codebook for full typology dataset: [link](https://github.com/urban-displacement/displacement-typologies/blob/main/data/outputs/typologies/typologies_codebook.md)

<!-- Findings -->
## Findings

The SCAG region represents an extremely wide variety of locations, from the high-rise density of downtown Los Angeles to sparsely inhabited desert in northern San Bernardino County. Because the Displacement Typologies are designed with urban areas in mind, more rural areas such as in Imperial, Riverside, San Bernardino Counties may represent structural dynamics that UDP has not yet had the opportunity to account for. For example, some neighborhoods in Palm Springs and Cathedral City in Riverside County appear to be retirement communities for high-income households. However, because the UDP typologies do not account for retirement income, these areas may be more likely to be classified as "Low-Income/Susceptible to Displacement".

Furthermore, without a more robust approach to analysis in low density rural areas, some typology categorizations may be ill-suited to existing conditions. In Ventura county, some tracts in the hills outside of Ojai were initially classified as "Advanced Gentrification". However, because gentrification is a de facto 'urban' phenomenon, this classification was determined to be a result of the limitations of the Displacement Typology methodology. Similar phenomena occurred in cities such as Lancaster, Victorville, and Palmdale. In response to these apparent mis-classifications, we modified the typology methodology to account for "dense" and "urban" tracts when classifying tracts. Though these alterations improved classification, a more comprehensive review of the methodology to address these contexts would ensure the typologies' accuracy moving forward.



<!-- CONTACT -->
## Contact or issues

This is a work in progress and we happily invite community feedback and collaboration in improving this work. If you find a bug or have questions about our code, analysis, or anything else regarding this repo/project, please create an [issue](https://github.com/urban-displacement/displacement-typologies/issues) and ping `@timathomas`. You're also welcome to reach out via email at <info@urbandisplacement.org> to ask us for questions, help, or suggestions.


## Citation
Tim Thomas, Anna Cash, Anna Driscoll, Gabriela Picado Aguilar, Carson Hartman, Julia Greenberg, Alex Ramiller, Emery Reifsnyder, Miriam Zuk, and Karen Chapple. “Urban-displacement/displacement-typologies: Release 1.1”. https://github.com/urban-displacement/displacement-typologies. doi:10.5281/zenodo.4356684.
