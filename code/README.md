# Code processing outline

Currently, the SPARCC typology is set up for:

* Atlanta
* Chicago
* Denver
* Memphis

Each of the files are named in order of operation. To run the code, do the following in a terminal window. 

```
# 1. data download
python 1_data.py Atlanta
python 1_data.py Chicago
python 1_data.py Denver
python 1_data.py Memphis

# 2. create lag variables
Rscript 2_create_lag_vars.r

# 3. create typologies
python 3_typology.py Atlanta
python 3_typology.py Chicago
python 3_typology.py Denver
python 3_typology.py Memphis

# 4. create maps
Rscript 4_SPARCC_Maps.r
```

## To edit

To add other cities, you will have to edit the following files accordingly

* `1_data.py`
* `2_create_lag_vars.r`
* `3_typology.py`
* `4_SPARCC_Maps.r`