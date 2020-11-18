# Output files from `~/git/sparcc/code/.`

## NOTE
Each file is appended with the census year from which it was pulled (e.g. 2017 for ACS 5-year census). All code updates should update this scheme accordingly. 

### crosswalks (legacy)
Deprecated files from `2017_1_data.py` for the SPARCC project and earlier development code runs. Current iteration skips saving these files to disk. 

### databases
Primary file used for lags.

### downloads
Census API download from `1_data_download.py`. Avoid liberally repeating this script as the Census API seems to have a limited number of pulls. We ran into a 404 error when we were pulling 2012 census data too many times. *Only run if data is being updated or there are missing files.*

### lags
Created by the R lag script.

### typologies 
Created by the python typologies script.

