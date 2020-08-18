# ==========================================================================
# Develop data for displacement and vulnerability measures
# Author: Tim Thomas - timthomas@berkeley.edu
# Created: 2019.10.13
# 1.0 code: 2019.12.1
# ==========================================================================

# Encrypt with: https://robinmoisson.github.io/staticrypt/

# Clear the session
rm(list = ls())
options(scipen = 10) # avoid scientific notation

# ==========================================================================
# Libraries
# ==========================================================================

#
# Load packages and install them if they're not installed.
# --------------------------------------------------------------------------

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fst, rmapshaper, sf, geojsonsf, scales, data.table, tidyverse, tigris, tidycensus, leaflet, update = TRUE)

# Cache downloaded tiger files
options(tigris_use_cache = TRUE)
census_api_key('4c26aa6ebbaef54a55d3903212eabbb506ade381')
# ==========================================================================
# Data
# ==========================================================================

#
# Pull in data (change this when there's new data): add your city here
# --------------------------------------------------------------------------

data <- 
    bind_rows( # pull in data
        read_csv('~/git/sparcc/data/outputs/typologies/Atlanta_typology_output.csv') %>% 
        mutate(city = 'Atlanta'),
        read_csv('~/git/sparcc/data/outputs/typologies/Denver_typology_output.csv') %>%
        mutate(city = 'Denver'),
        read_csv('~/git/sparcc/data/outputs/typologies/Chicago_typology_output.csv') %>% 
        mutate(city = 'Chicago'),
    #     read_csv('~/git/sparcc/data/outputs/typologies/Memphis_typology_output.csv') %>% 
    #     mutate(city = 'Memphis'),
        read_csv('~/git/sparcc/data/outputs/typologies/LosAngeles_typology_output.csv') %>% 
        mutate(city = 'Los Angeles'),
        read_csv('~/git/sparcc/data/outputs/typologies/SanFrancisco_typology_output.csv') %>% 
        mutate(city = 'San Francisco'),
        read_csv('~/git/sparcc/data/outputs/typologies/Seattle_typology_output.csv') %>% 
        mutate(city = 'Seattle'),
        read_csv('~/git/sparcc/data/outputs/typologies/Cleveland_typology_output.csv') %>% 
        mutate(city = 'Cleveland')#,
        # read_csv('~/git/sparcc/data/outputs/typologies/Boston_typology_output.csv') %>% 
        # mutate(city = 'Boston')                      
    ) %>% 
    left_join(., 
        read_csv('~/git/sparcc/data/overlays/oppzones.csv') %>% 
        select(
        	GEOID = geoid, 
        	opp_zone = tract_type
        	) %>%
        mutate(GEOID = as.numeric(GEOID)) 
    ) %>% 
    select(!X1)

#
# Prep dataframe for mapping
# --------------------------------------------------------------------------

df <- 
    data %>% 
    mutate( # create typology for maps
        Typology = 
            factor( # turn to factor for mapping 
                case_when(
                    typ_cat == "['AdvG']" ~ 'Advanced Gentrification',
                    typ_cat == "['ARE']" ~ 'At Risk of Becoming Exclusive',
                    typ_cat == "['ARG']" ~ 'At Risk of Gentrification',
                    typ_cat == "['BE']" ~ 'Becoming Exclusive', 
                    typ_cat == "['EOG']" ~ 'Early/Ongoing Gentrification',
                    typ_cat == "['OD']" ~ 'Ongoing Displacement',
                    typ_cat == "['SAE']" ~ 'Stable/Advanced Exclusive', 
                    typ_cat == "['SLI']" ~ 'Low-Income/Susceptible to Displacement',
                    typ_cat == "['SMMI']" ~ 'Stable Moderate/Mixed Income',
                    TRUE ~ "Unavailable or Unreliable Data"
                ), 
                levels = 
                    c(
                        'Low-Income/Susceptible to Displacement',
                        'Ongoing Displacement',
                        'At Risk of Gentrification',
                        'Early/Ongoing Gentrification',
                        'Advanced Gentrification',
                        'Stable Moderate/Mixed Income',
                        'At Risk of Becoming Exclusive',
                        'Becoming Exclusive',
                        'Stable/Advanced Exclusive',
                        'Unavailable or Unreliable Data'
                    )
            ), 
        real_mhval_18 = case_when(real_mhval_18 > 0 ~ real_mhval_18),
        real_mrent_18 = case_when(real_mrent_18 > 0 ~ real_mrent_18)
    ) %>% 
    group_by(city) %>% 
    mutate(
        rm_real_mhval_18 = median(real_mhval_18, na.rm = TRUE), 
        rm_real_mrent_18 = median(real_mrent_18, na.rm = TRUE), 
        rm_per_nonwhite_18 = median(per_nonwhite_18, na.rm = TRUE), 
        rm_per_col_18 = median(per_col_18, na.rm = TRUE)
    ) %>% 
    group_by(GEOID) %>% 
    mutate(
        per_ch_li = (all_li_count_18-all_li_count_00)/all_li_count_00,
        popup = # What to include in the popup 
          str_c(
              '<b>Tract: ', GEOID, '<br>', 
              Typology, '</b>',
            # Market
              '<br><br>',
              '<b><i><u>Market Dynamics</u></i></b><br>',
              'Tract median home value: ', case_when(!is.na(real_mhval_18) ~ dollar(real_mhval_18), TRUE ~ 'No data'), '<br>',
              'Tract home value change from 2000 to 2018: ', case_when(is.na(real_mhval_18) ~ 'No data', TRUE ~ percent(pctch_real_mhval_00_18)),'<br>',
              'Regional median home value: ', dollar(rm_real_mhval_18), '<br>',
              '<br>',
              'Tract median rent: ', case_when(!is.na(real_mrent_18) ~ dollar(real_mrent_18), TRUE ~ 'No data'), '<br>', 
              'Regional median rent: ', case_when(is.na(real_mrent_18) ~ 'No data', TRUE ~ dollar(rm_real_mrent_18)), '<br>', 
              'Tract rent change from 2012 to 2018: ', percent(pctch_real_mrent_12_18), '<br>',
              '<br>',
              'Rent gap (nearby - local): ', dollar(tr_rent_gap), '<br>',
              'Regional median rent gap: ', dollar(rm_rent_gap), '<br>',
              '<br>',
            # demographics
             '<b><i><u>Demographics</u></i></b><br>', 
             'Tract population: ', comma(pop_18), '<br>', 
             'Tract household count: ', comma(hh_18), '<br>', 
             'Tract median income: ', dollar(real_hinc_18), '<br>', 
             'Percent low income hh: ', percent(per_all_li_18), '<br>', 
             'Percent change in LI: ', percent(per_ch_li), '<br>',
             '<br>',
             'Percent non-White: ', percent(per_nonwhite_18), '<br>',
             'Regional median non-White: ', percent(rm_per_nonwhite_18), '<br>',
             '<br>',
             'Percent college educated: ', percent(per_col_18), '<br>',
             'Regional median educated: ', percent(rm_per_col_18), '<br>',
            '<br>',
            # risk factors
             '<b><i><u>Risk Factors</u></i></b><br>', 
             'Mostly low income: ', case_when(low_pdmt_medhhinc_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Mix low income: ', case_when(mix_low_medhhinc_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent change: ', case_when(dp_PChRent == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent gap: ', case_when(dp_RentGap == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Hot Market: ', case_when(hotmarket_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Vulnerable to gentrification: ', case_when(vul_gent_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>', 
             'Gentrified from 1990 to 2000: ', case_when(gent_90_00 == 1 | gent_90_00_urban == 1 ~ 'Yes', TRUE ~ 'No'), '<br>', 
             'Gentrified from 2000 to 2018: ', case_when(gent_00_18 == 1 | gent_00_18_urban == 1 ~ 'Yes', TRUE ~ 'No')
          )
    ) %>% 
    ungroup() %>% 
    data.frame()

# State codes for downloading tract polygons; add your state here
states <- c("06", "17", "13", "08", "25", "28", "47", "53", "39", "25", "33")

# Download tracts in each of the shapes in sf (simple feature) class
tracts <- 
    reduce(
        map(states, function(x) # purr loop
            get_acs(
                geography = "tract", 
                variables = "B01003_001", 
                state = x, 
                geometry = TRUE)
        ), 
        rbind # bind each of the dataframes together
    ) %>% 
    select(GEOID) %>% 
    mutate(GEOID = as.numeric(GEOID)) %>% 
    st_transform(st_crs(4326)) 

# Join the tracts to the dataframe

df_sf <- 
    right_join(tracts, df) 

#
# Explore problem areas
# --------------------------------------------------------------------------


ct <- 
    fread('~/git/sparcc/data/inputs/sparcc_community_tracts.csv') %>% 
    rename(city = City) %>% 
    mutate(GEOID = as.numeric(GEOID), 
    	cs = "Community Suggested Change") %>% 
    left_join(df_sf, .) %>% 
    st_set_geometry(value = "geometry") %>% 
    group_by(GEOID) %>% 
    mutate(
        popup_cs = # What to include in the popup 
          str_c(
              '<b>Tract: ', GEOID, '<br>
              UDP Typology: ', Typology, '</b>',
            # Market
              '<br><br>',
              '<b>Community Suggested Change<br>
              Site Notes</b>: <br>', CommunityComments,
              '<br><br>',
              '<b><i><u>Market Dynamics</u></i></b><br>',
              'Tract median home value: ', case_when(!is.na(real_mhval_18) ~ dollar(real_mhval_18), TRUE ~ 'No data'), '<br>',
              'Tract home value change from 2000 to 2018: ', case_when(is.na(real_mhval_18) ~ 'No data', TRUE ~ percent(pctch_real_mhval_00_18)),'<br>',
              'Regional median home value: ', dollar(rm_real_mhval_18), '<br>',
              '<br>',
              'Tract median rent: ', case_when(!is.na(real_mrent_18) ~ dollar(real_mrent_18), TRUE ~ 'No data'), '<br>', 
              'Regional median rent: ', case_when(is.na(real_mrent_18) ~ 'No data', TRUE ~ dollar(rm_real_mrent_18)), '<br>', 
              'Tract rent change from 2012 to 2018: ', percent(pctch_real_mrent_12_18), '<br>',
              '<br>',
              'Rent gap (nearby - local): ', dollar(tr_rent_gap), '<br>',
              'Regional median rent gap: ', dollar(rm_rent_gap), '<br>',
              '<br>',
            # demographics
             '<b><i><u>Demographics</u></i></b><br>', 
             'Tract population: ', comma(pop_18), '<br>', 
             'Tract household count: ', comma(hh_18), '<br>', 
             'Tract median income: ', dollar(real_hinc_18), '<br>', 
             'Percent low income hh: ', percent(per_all_li_18), '<br>', 
             'Percent change in LI: ', percent(per_ch_li), '<br>',
             '<br>',
             'Percent non-White: ', percent(per_nonwhite_18), '<br>',
             'Regional median non-White: ', percent(rm_per_nonwhite_18), '<br>',
             '<br>',
             'Percent college educated: ', percent(per_col_18), '<br>',
             'Regional median educated: ', percent(rm_per_col_18), '<br>',
            '<br>',
            # risk factors
             '<b><i><u>Risk Factors</u></i></b><br>', 
             'Mostly low income: ', case_when(low_pdmt_medhhinc_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Mix low income: ', case_when(mix_low_medhhinc_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent change: ', case_when(dp_PChRent == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent gap: ', case_when(dp_RentGap == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Hot Market: ', case_when(hotmarket_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Vulnerable to gentrification: ', case_when(vul_gent_18 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>', 
             'Gentrified from 1990 to 2000: ', case_when(gent_90_00 == 1 | gent_90_00_urban == 1 ~ 'Yes', TRUE ~ 'No'), '<br>', 
             'Gentrified from 2000 to 2018: ', case_when(gent_00_18 == 1 | gent_00_18_urban == 1 ~ 'Yes', TRUE ~ 'No')
          )
    ) 
    

# ==========================================================================
# overlays
# ==========================================================================

### Redlining

    ###add your city here
red <- 
    rbind(
        geojson_sf('~/git/sparcc/data/overlays/CODenver1938_1.geojson') %>% 
          mutate(city = 'Denver'),
        geojson_sf('~/git/sparcc/data/overlays/GAAtlanta1938_1.geojson') %>% 
          mutate(city = 'Atlanta'),
        geojson_sf('~/git/sparcc/data/overlays/ILChicago1940_1.geojson') %>% 
          mutate(city = 'Chicago'),
        geojson_sf('~/git/sparcc/data/overlays/TNMemphis19XX_1.geojson') %>% 
          mutate(city = 'Memphis'),
        geojson_sf('~/git/sparcc/data/overlays/CAOakland1937.geojson') %>% 
          mutate(city = 'San Francisco'),
        geojson_sf('~/git/sparcc/data/overlays/CASacramento1937.geojson') %>% 
          mutate(city = 'San Francisco'),
        geojson_sf('~/git/sparcc/data/overlays/CASanFrancisco1937.geojson') %>% 
          mutate(city = 'San Francisco'),
        geojson_sf('~/git/sparcc/data/overlays/CASanJose1937.geojson') %>% 
          mutate(city = 'San Francisco'),
        geojson_sf('~/git/sparcc/data/overlays/CAStockton1938.geojson') %>% 
          mutate(city = 'San Francisco'),
        geojson_sf('~/git/sparcc/data/overlays/CALosAngeles1939.geojson') %>% 
          mutate(city = 'Los Angeles'),
        geojson_sf('~/git/sparcc/data/overlays/WASeattle1936.geojson') %>% 
          mutate(city = 'Seattle'), 
        geojson_sf('~/git/sparcc/data/overlays/WATacoma1937.geojson') %>% 
          mutate(city = 'Seattle'),
        geojson_sf('~/git/sparcc/data/overlays/OHCleveland1939.geojson') %>% 
          mutate(city = 'Cleveland'),
        geojson_sf('~/git/sparcc/data/overlays/OHLorain1937.geojson') %>% 
          mutate(city = 'Cleveland'),
        geojson_sf('~/git/sparcc/data/overlays/MAArlington1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MABelmont1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MABoston1938.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MABraintree1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MABrockton1937.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MABrookline1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MACambridge1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAChelsea1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MADedham1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAEverett19XX.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAHaverhill1937.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MALexington19XX.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAMalden19XX.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAMedford19XX.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAMelrose1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAMilton1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MANeedham1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MANewton1937.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAQuincy1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MARevere19XX.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MASaugus19XX.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MASomerville1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAWaltham1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAWatertown1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAWinchester1939.geojson') %>% 
          mutate(city = 'Boston'),
        geojson_sf('~/git/sparcc/data/overlays/MAWinthrop1939.geojson') %>% 
          mutate(city = 'Boston')
    ) %>%
    mutate(
        Grade = 
            factor(
                case_when(
                    holc_grade == 'A' ~ 'A "Best"',
                    holc_grade == 'B' ~ 'B "Still Desirable"',
                    holc_grade == 'C' ~ 'C "Definitely Declining"',
                    holc_grade == 'D' ~ 'D "Hazardous"'
                ), 
                levels = c(
                    'A "Best"',
                    'B "Still Desirable"',
                    'C "Definitely Declining"',
                    'D "Hazardous"')
            ), 
        popup = # What to include in the popup 
          str_c(
              'Redline Grade: ', Grade
          )
    ) 

### Industrial points

industrial <- st_read('~/git/sparcc/data/overlays/industrial.shp') %>% 
    mutate(site = 
        case_when(
            site_type == 0 ~ "Superfund", 
            site_type == 1 ~ "TRI", 
        )) %>% 
    filter(state != "CO") %>% 
    st_as_sf() 

hud <- st_read('~/git/sparcc/data/overlays/HUDhousing.shp') %>% 
    st_as_sf() 

### Rail data
rail <- 
    st_join(
        fread('~/git/sparcc/data/inputs/tod_database_download.csv') %>% 
            st_as_sf(
                coords = c('Longitude', 'Latitude'), 
                crs = 4269
            ) %>% 
            st_transform(4326), 
        df_sf %>% select(city), 
        join = st_intersects
    ) %>% 
    filter(!is.na(city))

### Hospitals
hospitals <- 
    st_join(
        fread('~/git/sparcc/data/inputs/Hospitals.csv') %>% 
            st_as_sf(
                coords = c('X', 'Y'), 
                crs = 4269
            ) %>% 
            st_transform(4326), 
        df_sf %>% select(city), 
        join = st_intersects
    ) %>% 
    mutate(
        popup = str_c(NAME, "<br>", NAICS_DESC), 
        legend = "Hospitals"
    ) %>% 
    filter(!is.na(city), grepl("GENERAL", NAICS_DESC))
    # Describe NAME, TYPE, and NAICS_DESC in popup

### Universities
university <- 
    st_join(
        fread('~/git/sparcc/data/inputs/university_HD2016.csv') %>% 
            st_as_sf(
                coords = c('LONGITUD', 'LATITUDE'), 
                crs = 4269
            ) %>% 
            st_transform(4326), 
        df_sf %>% select(city), 
        join = st_intersects
    ) %>% 
    filter(ICLEVEL == 1, SECTOR < 3) %>% # filters to significant universities and colleges
    mutate(
        legend = case_when(
            SECTOR == 1 ~ 'Major University', 
            SECTOR == 2 ~ 'Medium University or College')
    ) %>% 
    filter(!is.na(city))

### Road map; add your state here
states <- 
    c('GA', 'CO', 'TN', 'MS', 'AR', 'IL', 'CA', 'MA', 'NH', 'OH', 'WA')

###
# Run below if file is missing in "~/git/sparcc/data/overlays/road_map.rds" or needs
#   an update
# ---
# road_map <- 
#     reduce(
#         map(states, function(state){
#             primary_secondary_roads(state, class = 'sf')
#         }),
#         rbind
#     ) %>% 
#     filter(RTTYP %in% c('I','U')) %>% 
#     ms_simplify(keep = 0.1) %>% 
#     st_transform(st_crs(df_sf)) %>%
#     st_join(., df_sf %>% select(city), join = st_intersects) %>% 
#     mutate(rt = case_when(RTTYP == 'I' ~ 'Interstate', RTTYP == 'U' ~ 'US Highway')) %>% 
#     filter(!is.na(city)) 
# saveRDS(road_map, "~/git/sparcc/data/overlays/road_map.rds")
###

readRDS("~/git/sparcc/data/overlays/road_map.rds")

### Atlanta Beltline
beltline <- 
	st_read("~/git/sparcc/data/overlays/beltline.shp") %>% 
	mutate(name = "Beltline", 
		name2 = "Possible Gentrifier")

### Opportunity Zones
opp_zone <- 
  st_read("~/git/sparcc/data/overlays/OpportunityZones/OpportunityZones.gpkg") %>%
  st_transform(st_crs(ct)) %>% 
  st_join(., df_sf %>% select(city), join = st_intersects) %>% 
  filter(!is.na(city))


# ==========================================================================
# Maps
# ==========================================================================

#
# Color palettes 
# --------------------------------------------------------------------------

redline_pal <- 
    colorFactor(
        c("#4ac938", "#2b83ba", "#ff8c1c", "#ff1c1c"), 
        domain = red$Grade, 
        na.color = "transparent"
    )

sparcc_pal <- 
    colorFactor(
        c(
            # '#e3dcf5',
            '#cbc9e2', # "#f2f0f7", 
            '#9e9ac8', #D9D7E8', #"#cbc9e2", #D9D7E8
            '#5b88b5', #"#6699cc",            
            # "#9e9ac8",
            '#756bb1', #B7B6D3', #"#756bb1", #B7B6D3
            '#54278f', #8D82B6', #"#54278f", #8D82B6
            '#FBEDE0', #"#ffffd4", #FBEDE0
            # '#ffff85',
            '#F4C08D', #"#fed98e", #EE924F
            '#EE924F', #"#fe9929", #EE924F
            '#C95123', #"#cc4c02", #C75023
            "#ffffff"), 
        domain = df$Typology, 
        na.color = "transparent"
    )

industrial_pal <- 
    colorFactor(c("#a65628", "#999999"), domain = c("Superfund", "TRI"))

rail_pal <- 
    colorFactor(
        c(
            '#377eb8',
            '#4daf4a',
            '#984ea3'
        ), 
        domain = c("Proposed Transit", "Planned Transit", "Existing Transit"))

road_pal <- 
    colorFactor(
        c(
            '#333333',
            '#666666'
        ), 
        domain = c("Interstate", "US Highway"))

## Atlanta Beltline

# make map

map_it <- function(data, city_name, st){
	leaflet(data %>% filter(city == city_name)) %>% 
    addMapPane(name = "polygons", zIndex = 410) %>% 
    addMapPane(name = "maplabels", zIndex = 420) %>% # higher zIndex rendered on top
    addProviderTiles("CartoDB.PositronNoLabels") %>%
    addProviderTiles("CartoDB.PositronOnlyLabels", 
                   options = leafletOptions(pane = "maplabels"),
                   group = "map labels") %>% # see: http://leaflet-extras.github.io/leaflet-providers/preview/index.html
    addEasyButton(
        easyButton(
            icon="fa-crosshairs", 
            title="My Location",
            onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
  # SPARCC typology
    addPolygons(
        data = data %>% filter(city == city_name), 
        group = "SPARCC Typology", 
        label = ~Typology,
        labelOptions = labelOptions(textsize = "12px"),
        fillOpacity = .5, 
        color = ~sparcc_pal(Typology), 
        stroke = TRUE, 
        weight = .7, 
        opacity = .60, 
        popup = ~popup, 
        popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
    ) %>%   
    addLegend(
        pal = sparcc_pal, 
        values = ~Typology, 
        group = "SPARCC Typology"
    ) %>% 
# Redlined areas
    addPolygons(
        data = red %>% filter(city == city_name), 
        group = "Redlined Areas", 
        label = ~Grade,
        labelOptions = labelOptions(textsize = "12px"),
        fillOpacity = .3, 
        color = ~redline_pal(Grade), 
        stroke = TRUE, 
        weight = 1, 
        opacity = .8, 
        highlightOptions = highlightOptions(
                            color = "#ff4a4a", 
                            weight = 5,
                            bringToFront = TRUE
                            ), 
        popup = ~popup
    ) %>%   
    addLegend(
        data = red, 
        pal = redline_pal, 
        values = ~Grade, 
        group = "Redlined Areas",
        title = "Redline Zones"
    ) %>%  
# Roads
    addPolylines(
        data = road_map %>% filter(city == city_name), 
        group = "Highways", 
        # label = ~rt,
        # labelOptions = labelOptions(textsize = "12px"),
        # fillOpacity = .3, 
        color = ~road_pal(rt), 
        stroke = TRUE, 
        weight = 1, 
        opacity = .1    
    ) %>%
    # addLegend(
    #     data = road_map, 
    #     pal = road_pal, 
    #     values = ~rt, 
    #     group = "Highways",
    #     title = "Highways"
    # ) %>%     
# Public Housing
    addCircleMarkers(
        data = hud %>% filter(state == st), #add your state here
        radius = 5, 
        lng = ~longitude, 
        lat = ~latitude, 
        color = ~"#ff7f00",
        # clusterOptions = markerClusterOptions(), 
        group = 'Public Housing', 
        # popup = ~site,
        fillOpacity = .5, 
        stroke = FALSE
    ) %>%     
# Rail
    addCircleMarkers(
        data = rail %>% filter(city == city_name), 
        label = ~Buffer, 
        radius = 5, 
        color = ~rail_pal(Buffer),
        group = 'Transit Stations', 
        popup = ~Buffer,
        fillOpacity = .8, 
        stroke = TRUE, 
        weight = .6
    ) %>%     
    addLegend(
        data = rail, 
        pal = rail_pal, 
        values = ~Buffer, 
        group = "Transit Stations", 
        title = "Transit Stations"
    ) %>%  
# University
    addCircleMarkers(
        data = university %>% filter(city == city_name), 
        label = ~INSTNM, 
        radius = 5, 
        color = ~'#39992b',
        group = 'Universities & Colleges', 
        popup = ~INSTNM,
        fillOpacity = .8, 
        stroke = TRUE, 
        weight = .6
    ) %>%     
# Hospitals
    addCircleMarkers(
        data = hospitals %>% filter(city == city_name), 
        label = ~NAME, 
        radius = 5, 
        color = ~"#e41a1c",
        group = 'Hospitals', 
        popup = ~popup,
        fillOpacity = .8, 
        stroke = TRUE, 
        weight = .6
    )}

 # Industrial
 ind <- function(st, map = .){
 	map %>% 
  	# leaflet(industrial %>% filter(state %in% st))
     addCircleMarkers(
         data = industrial %>% filter(state %in% st), 
         label = ~site, 
         radius = 5, 
         # lng = ~longitude, 
         # lat = ~latitude, 
         color = ~industrial_pal(site),
         # clusterOptions = markerClusterOptions(), 
         group = 'Industrial Sites', 
         popup = ~site,
         fillOpacity = .8, 
         stroke = TRUE, 
         weight = .6
     ) %>%     
     addLegend(
         data = industrial, 
         pal = industrial_pal, 
         values = ~site, 
         group = "Industrial Sites", 
         title = "Industrial Sites"
     )}  

# Beltline
 belt <- function(map = .){
 	map %>% 
addPolylines(
        data = beltline, 
        group = "Beltline", 
        color = "#2ca25f",
        stroke = TRUE, 
        weight = 5, 
        # opacity = .1    
    )}  

# Community Input
  ci <- function(map = ., data, city_name){
    map %>% 
    addPolygons(
        data = data %>% filter(city == city_name, !is.na(cs)), 
        group = "Community Input", 
        label = ~cs,
        labelOptions = labelOptions(textsize = "12px"),
        fillOpacity = .1, 
        color = "#ff4a4a", 
        stroke = TRUE, 
        weight = 1, 
        opacity = .9, 
        highlightOptions = highlightOptions(
                          color = "#ff4a4a", 
                          weight = 5,
                              bringToFront = TRUE
                              ), 
        popup = ~popup_cs, 
        popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
    )
    } 
     # addLegend(
         # pal = "#ff4a4a", 
         # values = ~cs, 
         # group = "Community Input"
     # ) %>% 

# Opportunity Zones
  oz <- function(map = ., city_name){
  map %>% 
    addPolygons(
        data = opp_zone %>% filter(city == city_name, !is.na(opp_zone)), 
        group = "Opportunity Zones", 
        label = "Opportunity Zone",
        labelOptions = labelOptions(textsize = "12px"),
        fillOpacity = .1, 
        color = "#c51b8a", 
        stroke = TRUE, 
        weight = 1, 
        opacity = .9, 
        highlightOptions = highlightOptions(
                          color = "#c51b8a", 
                          weight = 5,
                              bringToFront = FALSE
                              ), 
        # popup = ~opp_zone, 
        popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
    ) 
  }
    # addLegend(
    #     pal = "#c51b8a", 
    #     values = ~opp_zone, 
    #     group = "Opportunity Zones"
    # ) %>% 

# Options
 options <- function(map = ., belt = NULL, ci = NULL, oz = NULL, ph = NULL, is = NULL){
 	map %>% 
  	addLayersControl(
         overlayGroups = 
             c(ci, #
             	oz,#
                 "Redlined Areas", 
                 "Hospitals", 
                 "Universities & Colleges", 
                 ph, #?
                 "Transit Stations", 
                 is, #
                 belt,
                 "Highways",
                 "SPARCC Typology"),
         options = layersControlOptions(collapsed = FALSE)) %>% 
     hideGroup(
         c(ci, 
         	oz,
         	"Redlined Areas", 
             "Hospitals", 
             "Universities & Colleges", 
             ph, 
             "Transit Stations", 
             belt,
             is))
 }

#
# City specific SPARCC map; add your city here
# --------------------------------------------------------------------------

# Atlanta, GA
atlanta <- 
    map_it(ct, "Atlanta", 'GA') %>% 
    ind(st = "GA") %>% 
    ci(data = ct, city_name = "Atlanta") %>% 
    oz(city_name = "Atlanta") %>% 
    belt() %>% 
    options(belt = "Beltline",ci = "Community Input", oz = "Opportunity Zones", ph = "Public Housing", is = "Industrial Sites") %>% 
    setView(lng = -84.3, lat = 33.749, zoom = 10)

# save map
# htmlwidgets::saveWidget(atlanta, file="~/git/sparcc/maps/atlanta_udp.html")

# Chicago, IL
chicago <- 
    map_it(ct, "Chicago", 'IL') %>% 
    ind(st = "IL") %>% 
    ci(data = ct, city_name = "Chicago") %>% 
    oz(city_name = "Chicago") %>% 
    options(ci = "Community Input", oz = "Opportunity Zones", ph = "Public Housing", is = "Industrial Sites") %>% 
    setView(lng = -87.7, lat = 41.9, zoom = 10)
# save map
# htmlwidgets::saveWidget(chicago, file="~/git/sparcc/maps/chicago_udp.html")

# Denver, CO
denver <- 
    map_it(ct, "Denver", 'CO') %>% 
    ci(data = ct, city_name = "Denver") %>% 
    oz(city_name = "Denver") %>% 
    options(ci = "Community Input", oz = "Opportunity Zones", ph = "Public Housing", is = "Industrial Sites") %>% 
    setView(lng = -104.9, lat = 39.7, zoom = 10)
# # save map
# htmlwidgets::saveWidget(denver, file="~/git/sparcc/maps/denver_udp.html")

# Memphis, TN
memphis <- 
    map_it(ct, "Memphis", 'TN') %>% 
    ind(st = "TN") %>% 
    ci(data = ct, city_name = "Memphis") %>% 
    oz(city_name = "Memphis") %>% 
    options(ci = "Community Input", oz = "Opportunity Zones", ph = "Public Housing", is = "Industrial Sites") %>% 
    setView(lng = -89.9, lat = 35.2, zoom = 10)
# # save map
# htmlwidgets::saveWidget(memphis, file="~/git/sparcc/maps/memphis_2018.html")

# Los Angeles, CA
losangeles <- 
    map_it(df_sf, "Los Angeles", 'CA') %>% 
    # ind(st = 'CA') %>% # change ind file to include LA if you want this. 
    oz(city_name = "Los Angeles") %>% 
    options(oz = "Opportunity Zones") %>% 
    setView(lng = -118.244, lat = 34.052, zoom = 10) #set an appropriate view for LA
# # save map
# htmlwidgets::saveWidget(losangeles, file="~/git/sparcc/maps/losangeles_udp.html")

# San Francisco, CA
sanfrancisco <- 
    map_it(df_sf, "San Francisco", 'CA') %>% 
    # ind(st = 'CA') %>% # change ind file to include SF if you want this. 
    oz(city_name = "San Francisco") %>% 
    options(oz = "Opportunity Zones") %>% 
    setView(lng = -122.443, lat = 37.756, zoom = 10) #set an appropriate view for SF
# # save map
# htmlwidgets::saveWidget(sanfrancisco, file="~/git/sparcc/maps/sanfrancisco_udp.html")

# Seattle, WA
seattle <- 
    map_it(df_sf, "Seattle", 'WA') %>% 
    # ind(st = 'WA') %>% 
    oz(city_name = "Seattle") %>% 
    options(oz = "Opportunity Zones") %>% 
    setView(lng = -122.334, lat = 47.605, zoom = 10) #set an appropriate view for Seattle
# # save map
htmlwidgets::saveWidget(seattle, file="~/git/sparcc/maps/seattle_udp.html")

# Cleveland, OH
cleveland <- 
    map_it(df_sf, "Cleveland", 'OH') %>% 
    # ind(st = 'OH') %>% 
    oz(city_name = "Cleveland") %>% 
    options(oz = "Opportunity Zones") %>% 
    setView(lng = -81.686, lat = 41.504, zoom = 10) #set an appropriate view for Cleveland
# # save map
htmlwidgets::saveWidget(cleveland, file="~/git/sparcc/maps/cleveland_udp.html")

# Boston, MA
boston <- 
    map_it("Boston", 'MA') %>% 
    # ind(st = 'MA') %>% 
    oz(city_name = "Boston") %>% 
    options(oz = "Opportunity Zones") %>% 
    setView(lng = -71.060, lat = 42.360, zoom = 10) #set an appropriate view for Boston
# # save map
htmlwidgets::saveWidget(boston, file="~/git/sparcc/maps/boston_2018.html")
