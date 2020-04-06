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
pacman::p_load(colorout, fst, sf, geojsonsf, scales, data.table, tidyverse, tigris, tidycensus, leaflet)

# Cache downloaded tiger files
options(tigris_use_cache = TRUE)

# ==========================================================================
# Data
# ==========================================================================

#
# Pull in data (change this when there's new data)
# --------------------------------------------------------------------------

data <- 
    bind_rows( # pull in data
        read_csv('~/git/sparcc/data/Atlanta_typology_output.csv') %>% 
        mutate(city = 'Atlanta'),
        read_csv('~/git/sparcc/data/Denver_typology_output.csv') %>%
        mutate(city = 'Denver'),
        read_csv('~/git/sparcc/data/Chicago_typology_output.csv') %>% 
        mutate(city = 'Chicago'),
        read_csv('~/git/sparcc/data/Memphis_typology_output.csv') %>% 
        mutate(city = 'Memphis')
    ) %>% 
    left_join(., 
        read_csv('/Users/timothythomas/git/sparcc/data/overlays/oppzones.csv') %>% 
        select(GEOID = geoid, opp_zone = tract_type) %>%
        mutate(GEOID = as.numeric(GEOID)) 
    )

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
                    typ_cat == "['SLI']" ~ 'Stable/Low-Income',
                    typ_cat == "['SMMI']" ~ 'Stable Moderate/Mixed Income',
                    TRUE ~ "Insufficient Data"
                ), 
                levels = 
                    c(
                        'Stable/Low-Income',
                        'Ongoing Displacement',
                        'At Risk of Gentrification',
                        'Early/Ongoing Gentrification',
                        'Advanced Gentrification',
                        'Stable Moderate/Mixed Income',
                        'At Risk of Becoming Exclusive',
                        'Becoming Exclusive',
                        'Stable/Advanced Exclusive',
                        'Insufficient Data'
                    )
            ), 
        real_mhval_17 = case_when(real_mhval_17 > 0 ~ real_mhval_17),
        real_mrent_17 = case_when(real_mrent_17 > 0 ~ real_mrent_17)
    ) %>% 
    group_by(city) %>% 
    mutate(
        rm_real_mhval_17 = median(real_mhval_17, na.rm = TRUE), 
        rm_real_mrent_17 = median(real_mrent_17, na.rm = TRUE), 
        rm_per_nonwhite_17 = median(per_nonwhite_17, na.rm = TRUE), 
        rm_per_col_17 = median(per_col_17, na.rm = TRUE)
    ) %>% 
    group_by(GEOID) %>% 
    mutate(
        per_ch_li = (all_li_count_17-all_li_count_00)/all_li_count_00,
        popup = # What to include in the popup 
          str_c(
              '<b>Tract: ', GEOID, '<br>', 
              Typology, '</b>',
            # Market
              '<br><br>',
              '<b><i><u>Market Dynamics</u></i></b><br>',
              'Tract median home value: ', case_when(!is.na(real_mhval_17) ~ dollar(real_mhval_17), TRUE ~ 'No data'), '<br>',
              'Tract home value change from 2000 to 2017: ', case_when(is.na(real_mhval_17) ~ 'No data', TRUE ~ percent(pctch_real_mhval_00_17)),'<br>',
              'Regional median home value: ', dollar(rm_real_mhval_17), '<br>',
              '<br>',
              'Tract median rent: ', case_when(!is.na(real_mrent_17) ~ dollar(real_mrent_17), TRUE ~ 'No data'), '<br>', 
              'Regional median rent: ', case_when(is.na(real_mrent_17) ~ 'No data', TRUE ~ dollar(rm_real_mrent_17)), '<br>', 
              'Tract rent change from 2012 to 2017: ', percent(pctch_real_mrent_12_17), '<br>',
              '<br>',
              'Rent gap (nearby - local): ', dollar(tr_rent_gap), '<br>',
              'Regional median rent gap: ', dollar(rm_rent_gap), '<br>',
              '<br>',
            # demographics
             '<b><i><u>Demographics</u></i></b><br>', 
             'Tract population: ', comma(pop_17), '<br>', 
             'Tract household count: ', comma(hh_17), '<br>', 
             'Tract median income: ', dollar(real_hinc_17), '<br>', 
             'Percent low income hh: ', percent(per_all_li_17), '<br>', 
             'Percent change in LI: ', percent(per_ch_li), '<br>',
             '<br>',
             'Percent non-White: ', percent(per_nonwhite_17), '<br>',
             'Regional median non-White: ', percent(rm_per_nonwhite_17), '<br>',
             '<br>',
             'Percent college educated: ', percent(per_col_17), '<br>',
             'Regional median educated: ', percent(rm_per_col_17), '<br>',
            '<br>',
            # risk factors
             '<b><i><u>Risk Factors</u></i></b><br>', 
             'Mostly low income: ', case_when(low_pdmt_medhhinc_17 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Mix low income: ', case_when(mix_low_medhhinc_17 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent change: ', case_when(dp_PChRent == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent gap: ', case_when(dp_RentGap == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Hot Market: ', case_when(hotmarket_17 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Vulnerable to gentrification: ', case_when(vul_gent_17 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>', 
             'Gentrified from 2000 to 2017: ', case_when(gent_00_17 == 1 ~ 'Yes', TRUE ~ 'No')
          )
    ) %>% 
    ungroup() %>% 
    data.frame()

# State codes for downloading tract polygons
states <- c("17", "13", "08", "28", "47")

# Download tracts in each of the shapes in sf (simple feature) class
tracts <- 
    reduce(
        map(states, function(x) # purr loop
            get_acs(
                geography = "tract", 
                variables = "B01003_001", 
                state = x, 
                geometry = TRUE, 
                year = 2017)
        ), 
        rbind # bind each of the dataframes together
    ) %>% 
    select(GEOID) %>% 
    mutate(GEOID = as.numeric(GEOID)) %>% 
    st_transform(st_crs(4326)) 

# Join the tracts to the dataframe
df_sf <- 
    right_join(tracts, df) 

# ==========================================================================
# overlays
# ==========================================================================

### Redlining
red <- 
    rbind(
        geojson_sf('/Users/timothythomas/git/sparcc/data/overlays/CODenver1938_1.geojson') %>% 
        mutate(city = 'Denver'),
        geojson_sf('/Users/timothythomas/git/sparcc/data/overlays/GAAtlanta1938_1.geojson') %>% 
        mutate(city = 'Atlanta'),
        geojson_sf('/Users/timothythomas/git/sparcc/data/overlays/ILChicago1940_1.geojson') %>% 
        mutate(city = 'Chicago'),
        geojson_sf('/Users/timothythomas/git/sparcc/data/overlays/TNMemphis19XX_1.geojson') %>% 
        mutate(city = 'Memphis')
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

industrial <- st_read('/Users/timothythomas/git/sparcc/data/overlays/industrial.shp') %>% 
    mutate(site = 
        case_when(
            site_type == 0 ~ "Superfund", 
            site_type == 1 ~ "TRI", 
        )) %>% 
    filter(state != "CO") %>% 
    st_as_sf() 

hud <- st_read('/Users/timothythomas/git/sparcc/data/overlays/HUDhousing.shp') %>% 
    st_as_sf() 

### Rail data
rail <- 
    st_join(
        fread('/Users/timothythomas/git/sparcc/data/inputs/tod_database_download.csv') %>% 
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
        fread('/Users/timothythomas/git/sparcc/data/inputs/Hospitals.csv') %>% 
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
        fread('/Users/timothythomas/git/sparcc/data/inputs/university_HD2016.csv') %>% 
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

### Roads
# state_co <- 
#     df_sf %>% 
#     filter(!is.na(state)) %>% 
#     mutate(
#         state = str_pad(state, 2, pad = '0'), 
#         county = str_pad(county, 3, pad = '0'), 
#         state_co = paste0(state, county, city)
#     ) %>% 
#     pull(state_co) %>% 
#     unique()

# road_map <- 
#     map_dfr(state_co, function(x){
#         roads(state = substr(x, 1,2), county = substr(x, 3, 5), class = 'sf') %>% 
#         mutate(city = substr(x, 6, nchar(x)))
#     })

# road_map <- 
#     reduce(
#         map(state_co, function(x){
#             roads(
#                 state = substr(x, 1,2), 
#                 county = substr(x, 3, 5), 
#                 class = 'sf'
#             ) %>% 
#             mutate(city = substr(x, 6, nchar(x)))
#         })
#     )

states <- 
    c('GA', 'CO', 'TN', 'MS', 'AR', 'IL')

road_map <- 
    reduce(
        map(states, function(state){
            primary_secondary_roads(state, class = 'sf')
        }),
        rbind
    ) %>% 
    filter(RTTYP %in% c('I','U')) %>% 
    st_simplify() %>% 
    st_transform(st_crs(df_sf)) %>%
    st_join(., df_sf %>% select(city), join = st_intersects) %>% 
    mutate(rt = case_when(RTTYP == 'I' ~ 'Interstate', RTTYP == 'U' ~ 'US Highway')) %>% 
    filter(!is.na(city))

# osm_lines <- osm$osm_lines
# names(osm_lines$geometry) <- NULL
# leaflet(osm_lines) %>%
#   addPolylines()

### places
# place_pop <- 
#     reduce(
#         map(states, function(state){
#             get_acs(
#                 geography = "place", 
#                 variables = "B01003_001", 
#                 state = state)
#         }), 
#         rbind
#     )

# place <- 
#     reduce(
#         map(states, function(state){
#             places(state, class = 'sf') %>% 
#             st_centroid() %>% 
#             st_transform(st_crs(df_sf))
#         }), 
#         rbind
#     ) %>% 
#     st_intersection(., df_sf %>% select(city)) %>% 
#     left_join(., place_pop %>% select(GEOID, pop = estimate))

### LIHTC
# lihtc <- fread('~/git/sparcc/data/LowIncome_Housing_Tax_Credit_Properties.csv')

### Public housing
# pub_hous <- fread('~/git/sparcc/data/Public_Housing_Buildings.csv')

# ==========================================================================
# Maps
# ==========================================================================

#
# City specific SPARCC data
# --------------------------------------------------------------------------

atl_df <- 
    df_sf %>% 
    filter(city == "Atlanta") 

den_df <- 
    df_sf %>% 
    filter(city == "Denver") 

chi_df <- 
    df_sf %>% 
    filter(city == "Chicago") 

mem_df <- 
    df_sf %>% 
    filter(city == "Memphis") 

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
            '#5b88b5', #"#6699cc",
            '#9e9ac8', #D9D7E8', #"#cbc9e2", #D9D7E8
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


#e41a1c # red - hospital ###
#377eb8 # blue - rail
#4daf4a # green - rail
#984ea3 # purple - rail
#ff7f00 # orange - HUD 
#ffff33 # yellow
#a65628 # brown - industrial
#39992b # pink - universities ###
#999999 # grey - industrial

# make map

map_it <- function(data, city_name, st){
    leaflet(data = data) %>% 
    addMapPane(name = "polygons", zIndex = 410) %>% 
    addMapPane(name = "maplabels", zIndex = 420) %>% # higher zIndex rendered on top
    # addProviderTiles("CartoDB.VoyagerNoLabels") %>%
    # addProviderTiles("CartoDB.VoyagerOnlyLabels", 
    addProviderTiles("CartoDB.PositronNoLabels") %>%
    addProviderTiles("CartoDB.PositronOnlyLabels", 
                   options = leafletOptions(pane = "maplabels"),
                   group = "map labels") %>%
    # addProviderTiles(providers$CartoDB.Positron) %>% 
    # http://leaflet-extras.github.io/leaflet-providers/preview/index.html
    # addMiniMap(tiles = providers$CartoDB.Positron, 
    #          toggleDisplay = TRUE) %>% 
    addEasyButton(
        easyButton(
            icon="fa-crosshairs", 
            title="My Location",
            onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
# SPARCC typology
    addPolygons(
        data = data, 
        group = "SPARCC Typology", 
        label = ~Typology,
        labelOptions = labelOptions(textsize = "12px"),
        fillOpacity = .5, 
        color = ~sparcc_pal(Typology), 
        stroke = TRUE, 
        weight = .7, 
        opacity = .60, 
        # highlightOptions = highlightOptions(
        #                   color = "#ff4a4a", 
        #                   weight = 5,
  #                             bringToFront = TRUE
  #                             ), 
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
    addLegend(
        data = road_map, 
        pal = road_pal, 
        values = ~rt, 
        group = "Highways",
        title = "Highways"
    ) %>%     
# # Public Housing
    addCircleMarkers(
        data = hud %>% filter(state %in% st), 
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
# Industrial
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
    # addLegend(
    #     data = university, 
    #     pal = ~'#39992b', 
    #     values = ~legend,
    #     group = "Universities & Colleges", 
    #     title = "Universities & Colleges"
    # ) %>%    
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
    ) %>%     
    # addLegend(
    #     data = rail, 
    #     pal = ~"#e41a1c", 
    #     values = ~legend,
    #     group = "Hospitals", 
    #     title = "Hospitals"
    # ) %>%    
# Options
    addLayersControl(
        overlayGroups = 
            c("Redlined Areas", 
                "Hospitals", 
                "Universities & Colleges", 
                "Public Housing", 
                "Transit Stations", 
                "Industrial Sites", 
                "Highways",
                "SPARCC Typology"),
        options = layersControlOptions(collapsed = FALSE)) %>% 
    hideGroup(
        c("Redlined Areas", 
            "Hospitals", 
            "Universities & Colleges", 
            "Public Housing", 
            "Transit Stations", 
            "Industrial Sites"))
}

## Map without industry for Denver
map_it2 <- function(data, city_name, st){
    leaflet(data = data) %>% 
    addMapPane(name = "polygons", zIndex = 410) %>% 
    addMapPane(name = "maplabels", zIndex = 420) %>% # higher zIndex rendered on top
    # addProviderTiles("CartoDB.VoyagerNoLabels") %>%
    # addProviderTiles("CartoDB.VoyagerOnlyLabels", 
    addProviderTiles("CartoDB.PositronNoLabels") %>%
    addProviderTiles("CartoDB.PositronOnlyLabels", 
                   options = leafletOptions(pane = "maplabels"),
                   group = "map labels") %>%
    # addProviderTiles(providers$CartoDB.Positron) %>% 
    # http://leaflet-extras.github.io/leaflet-providers/preview/index.html
    # addMiniMap(tiles = providers$CartoDB.Positron, 
    #          toggleDisplay = TRUE) %>% 
    addEasyButton(
        easyButton(
            icon="fa-crosshairs", 
            title="My Location",
            onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
# SPARCC typology
    addPolygons(
        data = data, 
        group = "SPARCC Typology", 
        label = ~Typology,
        labelOptions = labelOptions(textsize = "12px"),
        fillOpacity = .5, 
        color = ~sparcc_pal(Typology), 
        stroke = TRUE, 
        weight = .7, 
        opacity = .60, 
        # highlightOptions = highlightOptions(
        #                   color = "#ff4a4a", 
        #                   weight = 5,
  #                             bringToFront = TRUE
  #                             ), 
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
    addLegend(
        data = road_map, 
        pal = road_pal, 
        values = ~rt, 
        group = "Highways",
        title = "Highways"
    ) %>%     
# # Public Housing
    addCircleMarkers(
        data = hud %>% filter(state %in% st), 
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
    # addLegend(
    #     data = university, 
    #     pal = ~'#39992b', 
    #     values = ~legend,
    #     group = "Universities & Colleges", 
    #     title = "Universities & Colleges"
    # ) %>%    
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
    ) %>%     
    # addLegend(
    #     data = rail, 
    #     pal = ~"#e41a1c", 
    #     values = ~legend,
    #     group = "Hospitals", 
    #     title = "Hospitals"
    # ) %>%    
# Options
    addLayersControl(
        overlayGroups = 
            c("Redlined Areas", 
                "Hospitals", 
                "Universities & Colleges", 
                "Public Housing", 
                "Transit Stations",
                "Highways",
                "SPARCC Typology"),
        options = layersControlOptions(collapsed = FALSE)) %>% 
    hideGroup(
        c("Redlined Areas", 
            "Hospitals", 
            "Universities & Colleges", 
            "Public Housing", 
            "Transit Stations"))
}

# Atlanta, GA
atlanta <- 
    map_it(atl_df, "Atlanta", 'GA') %>% 
    setView(lng = -84.3, lat = 33.749, zoom = 10)

# save map
htmlwidgets::saveWidget(atlanta, file="~/git/sparcc/maps/atlanta.html")

# Chicago, IL
chicago <- 
    map_it(chi_df, "Chicago", 'IL') %>% 
    setView(lng = -87.7, lat = 41.9, zoom = 10)
# save map
htmlwidgets::saveWidget(chicago, file="~/git/sparcc/maps/chicago.html")

# Denver, CO
denver <- 
    map_it2(den_df, "Denver", 'CO') %>% 
    setView(lng = -104.9, lat = 39.7, zoom = 10)
# # save map
htmlwidgets::saveWidget(denver, file="~/git/sparcc/maps/denver.html")

# Memphis, TN
memphis <- 
    map_it(mem_df, "Memphis", c('TN', 'MS')) %>% 
    setView(lng = -89.9, lat = 35.2, zoom = 10)
# # save map
htmlwidgets::saveWidget(memphis, file="~/git/sparcc/maps/memphis.html")

