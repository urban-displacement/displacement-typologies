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
pacman::p_load(sf, geojsonsf, scales, data.table, tidyverse, tigris, tidycensus, leaflet)

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
        read_csv('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/oppzones.csv') %>% 
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
                # typ_cat2 == 'AdvG' ~ 'Advanced Gentrification', 
                # typ_cat2 == 'ARE' ~ 'At Risk of Becoming Exclusive', 
                # typ_cat2 == 'ARG' ~ 'At Risk of Gentrification', 
                # typ_cat2 == 'BE' ~ 'Becoming Exclusive', #
                # typ_cat2 == 'EOG' ~ 'Early/Ongoing Gentrification', 
                # typ_cat2 == 'OD' ~ 'Ongoing Displacement', 
                # typ_cat2 == 'SAE' ~ 'Stable/Advanced Exclusive', #
                # typ_cat2 == 'SLI' ~ 'Stable/Low-Income',
                # typ_cat2 == 'SMMI' ~ 'Stable Moderate/Mixed Income', 
				typ_cat == "['AdvG']" ~ 'Advanced Gentrification', #
				typ_cat == "['ARE']" ~ 'At Risk of Becoming Exclusive', #
				typ_cat == "['ARG']" ~ 'At Risk of Gentrification', #
				typ_cat == "['BE']" ~ 'Becoming Exclusive', # 
				typ_cat == "['EOG']" ~ 'Early/Ongoing Gentrification', #
				typ_cat == "['OD']" ~ 'Ongoing Displacement', #
				typ_cat == "['SAE']" ~ 'Stable/Advanced Exclusive', # 
				typ_cat == "['SLI']" ~ 'Stable/Low-Income',
				typ_cat == "['SMMI']" ~ 'Stable Moderate/Mixed Income', #
				TRUE ~ "Insufficient Data"
			), 
			levels = 
				c(
					'Stable/Low-Income', #E4E0EB
					'Ongoing Displacement', #AAC2F0
					'At Risk of Gentrification', #CAC2D7
					'Early/Ongoing Gentrification', #8B7EBE
					'Advanced Gentrification', #5C4B77
					'Stable Moderate/Mixed Income', #FAEBDC
					'At Risk of Becoming Exclusive', #F5D6B9
					'Becoming Exclusive', #ECB476
					'Stable/Advanced Exclusive', 
                    'Insufficient Data' #D5722D
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
              'Tract change from 2000 to 2017: ', case_when(is.na(real_mhval_17) ~ 'No data', TRUE ~ percent(pctch_real_mhval_00_17)),'<br>',
              'Regional median home value: ', dollar(rm_real_mhval_17), '<br>',
              '<br>',
              'Tract median rent: ', case_when(!is.na(real_mrent_17) ~ dollar(real_mrent_17), TRUE ~ 'No data'), '<br>', 
              'Regional median rent: ', case_when(is.na(real_mrent_17) ~ 'No data', TRUE ~ dollar(rm_real_mrent_17)), '<br>', 
              'Change from 2000 to 2017: ', percent(pctch_real_mrent_00_17), '<br>',
              '<br>',
              'Rent gap: ', dollar(tr_rent_gap), '<br>',
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
             'Regainal median educated: ', percent(rm_per_col_17), '<br>',
            '<br>',
            # risk factors
             '<b><i><u>Risk Factors</u></i></b><br>', 
             'Mostly low income: ', case_when(low_pdmt_medhhinc_17 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Mix low income: ', case_when(mix_low_medhhinc_17 == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent change: ', case_when(dp_PChRent == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Rent gap: ', case_when(dp_RentGap == 1 ~ 'Yes', TRUE ~ 'No'), '<br>',
             'Vulnerable to gentrification: ', case_when(vul_gent_17 == 1 ~ 'Yes', TRUE ~ 'No')
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

red <- 
    rbind(
        geojson_sf('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/CODenver1938_1.geojson') %>% 
        mutate(city = 'Denver'),
        geojson_sf('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/GAAtlanta1938_1.geojson') %>% 
        mutate(city = 'Atlanta'),
        geojson_sf('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/ILChicago1940_1.geojson') %>% 
        mutate(city = 'Chicago'),
        geojson_sf('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/TNMemphis19XX_1.geojson') %>% 
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

industrial <- st_read('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/industrial.shp') %>% 
    mutate(site = 
        case_when(
            site_type == 0 ~ "Superfund", 
            site_type == 1 ~ "TRI", 
        )) %>%
    st_as_sf() 

hud <- st_read('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Overlays/HUDhousing.shp') %>% 
    st_as_sf() 

### Rail data
rail <- fread('~/git/sparcc/data/tod_database_download.csv')
rail %>% group_by(Buffer) %>% count()

### Hospitals
hospitals <- fread('~/git/sparcc/data/Hospitals.csv')
hospitals %>% group_by(TYPE) %>% count()
# Describe tye in popup

### Universities
university <- fread('~/git/sparcc/data/university_HD2016.csv')
glimpse(university)

### LIHTC
lihtc <- fread('~/git/sparcc/data/LowIncome_Housing_Tax_Credit_Properties.csv')

### Public housing
pub_hous <- fread('~/git/sparcc/data/Public_Housing_Buildings.csv')

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
		c("#f2f0f7",
            "#6699cc","#cbc9e2",
            # "#9e9ac8",
            "#756bb1","#54278f","#ffffd4","#fed98e","#fe9929","#cc4c02", "#ffffff"), 
		domain = df$Typology, 
		na.color = "transparent"
	)

industrial_pal <- 
    colorFactor(c("orange", "red"), domain = c("Superfund", "TRI"))


# make map

map_it <- function(data, city_name, st){
	leaflet(data = data) %>% 
	addProviderTiles(providers$CartoDB.Positron) %>% 
	# addMiniMap(tiles = providers$CartoDB.Positron, 
	# 		   toggleDisplay = TRUE) %>% 
    addEasyButton(
        easyButton(
            icon="fa-crosshairs", 
            title="My Location",
            onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
# SPARCC typology
	addPolygons(
		data = data, 
		group = "SPARCC Typology", 
        label = ~paste(sep = '<br/>', Typology, '(click for more)'),
        labelOptions = labelOptions(textsize = "12px"),
		fillOpacity = .5, 
		color = ~sparcc_pal(Typology), 
		stroke = TRUE, 
		weight = .5, 
		opacity = .60, 
		highlightOptions = highlightOptions(
							color = "#ff4a4a", 
							weight = 5,
      						bringToFront = TRUE
      						), 
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
# Public Housing
    addCircleMarkers(
        data = hud %>% filter(state == st), 
        radius = 5, 
        lng = ~longitude, 
        lat = ~latitude, 
        color = ~"green",
        # clusterOptions = markerClusterOptions(), 
        group = 'Public Housing', 
        # popup = ~site,
        fillOpacity = .5, 
        stroke = FALSE
    ) %>%     
# Industrial
    addCircleMarkers(
        data = industrial %>% filter(state == st), 
        radius = 5, 
        lng = ~longitude, 
        lat = ~latitude, 
        color = ~industrial_pal(site),
        # clusterOptions = markerClusterOptions(), 
        group = 'Industrial Sites', 
        popup = ~site,
        fillOpacity = .5, 
        stroke = FALSE
    ) %>%     
    addLegend(
        data = industrial, 
        pal = industrial_pal, 
        values = ~site, 
        group = "Industrial Sites", 
        title = "Industrial Sites"
    ) %>%    
# Options
    addLayersControl(
        overlayGroups = c("SPARCC Typology", "Redlined Areas", "Public Housing", "Industrial Sites"),
        options = layersControlOptions(collapsed = FALSE)) %>% 
    hideGroup(c('Redlined Areas', 'Industrial Sites', 'Public Housing'))
}

# Atlanta, GA
atlanta <- 
    map_it(atl_df, "Atlanta", 'GA') %>% 
    setView(lng = -84.3, lat = 33.749, zoom = 10)
atlanta
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
    map_it(den_df, "Denver", 'CO') %>% 
    setView(lng = -104.9, lat = 39.7, zoom = 10)
# # save map
htmlwidgets::saveWidget(denver, file="~/git/sparcc/maps/denver.html")

# Memphis, TN
memphis <- 
    map_it(mem_df, "Memphis", 'TN') %>% 
    setView(lng = -89.9, lat = 35.2, zoom = 11)
# # save map
htmlwidgets::saveWidget(memphis, file="~/git/sparcc/maps/memphis.html")

# ==========================================================================
# ==========================================================================
# Mapping example below
# ==========================================================================
# ==========================================================================


# 	addPolygons(
# 		data = df_tiers, 
# 		group = "Heightened Sensitivity",
# 		fillOpacity = .5, 
# 		color = ~pal1(tier1),
# 		stroke = TRUE, 
# 		weight = .5, # border thickness
# 		opacity = .45, 
# 		highlightOptions = highlightOptions(
# 							color = "#ff4a4a", 
# 							weight = 5,
#       						bringToFront = TRUE
#       						), 
# 		popup = ~popup, 
# 		popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
# 	) %>% 
# 	addLegend(
# 		pal = pal1, 
# 		values = ~tier1, 
# 		title = ""
# 	) %>% 
# 	addLayersControl(overlayGroups = c("Heightened Sensitivity", "Vulnerable", "Bus", "Rail"),
# 					 options = layersControlOptions(collapsed = TRUE)) %>% 
# 	hideGroup(c("Bus", "Vulnerable"))
# 	# addEasyButton(
# 	# 	easyButton(
# 	# 	    icon="fa-crosshairs", 
# 	# 	    title="My Location",
# 	# 	    onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>% 
# 	# setView(-122.2712, 37.8044, zoom = 10) %>% 
# # Bus layer
# 	addPolygons(data = Bus, 
# 				label = "label", 
# 				color = "#000000", 
# 				fillColor="#CCCCCC", 
# 				weight = .5, 
# 				opacity = .45, 
# 				fillOpacity = .1, 
# 				stroke = TRUE, 
# 				group = "Bus") %>% 	
# 	addLegend(
# 		color = "#CCCCCC", 
# 		labels = Bus$label, 
# 		group = "Bus"
# 	) %>% 
# # Rail layer
# 	addPolygons(data = Rail, 
# 				layerId = "label", 
# 				color = "#000000", 
# 				fillColor="#CCCCCC", 
# 				weight = .5, 
# 				opacity = .45, 
# 				fillOpacity = .1, 
# 				stroke = TRUE, 
# 				group = "Rail"
# 	) %>% 
# 	addLegend(
# 		color = "#CCCCCC", 
# 		labels = Rail$label, 
# 		group = "Rail"
# 	) %>% 
# # Vulnerable layer
# 	addPolygons(
# 		data = df_tier2, 
# 		group = "Vulnerable",
# 		fillOpacity = .5, 
# 		color = ~pal2(tier2),
# 		stroke = TRUE, 
# 		weight = .5, # border thickness
# 		opacity = .45, 
# 		highlightOptions = highlightOptions(
# 							color = "#ff4a4a", 
# 							weight = 5,
#       						bringToFront = TRUE
#       						), 
# 		popup = ~popup, 
# 		popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
# 	) %>% 
# 	addLegend(
# 		pal = pal2, 
# 		values = ~tier2, 
# 		group = "Vulnerable", 
# 		title = ""
# 	) %>% 
# # Heightened Sensitivity layer
# 	addPolygons(
# 		data = df_tiers, 
# 		group = "Heightened Sensitivity",
# 		fillOpacity = .5, 
# 		color = ~pal1(tier1),
# 		stroke = TRUE, 
# 		weight = .5, # border thickness
# 		opacity = .45, 
# 		highlightOptions = highlightOptions(
# 							color = "#ff4a4a", 
# 							weight = 5,
#       						bringToFront = TRUE
#       						), 
# 		popup = ~popup, 
# 		popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
# 	) %>% 
# 	addLegend(
# 		pal = pal1, 
# 		values = ~tier1, 
# 		title = ""
# 	) %>% 
# 	addLayersControl(overlayGroups = c("Heightened Sensitivity", "Vulnerable", "Bus", "Rail"),
# 					 options = layersControlOptions(collapsed = TRUE)) %>% 
# 	hideGroup(c("Bus", "Vulnerable"))

# # save map
# htmlwidgets::saveWidget(map, file="~/git/sensitive_communities/docs/map.html")



# df_tiers <- 
# 	df_final.RB50VLI %>%
# 	select(GEOID, tr_population, tr_households, v_VLI, tr_VLI_prop, co_VLI_prop, tr_pstudents, v_POC, tr_pPOC, co_pPOC, tr_POC_rank, v_Renters, tr_prenters, co_prenters, v_RB50VLI, tr_irVLI_50p, co_irVLI_50p, dp_PChRent, tr_pchrent, tr_pchrent.lag, co_pchrent, dp_RentGap, tr_rentgap, co_rentgap, tr_medrent, tr_medrent.lag, NeighType, tr_pWhite, tr_pBlack, tr_pAsian, tr_pLatinx, tr_pOther, tier1, tier2) %>% 
# 	mutate(popup = 
# 		str_c(
# 			"<h3>Tract: ", GEOID, "</h3>", 

# 			"<b>Total population</b><br>", 
# 				comma(tr_population), 
# 				"<br>", 
			 		    
# 			"<b>Total households</b><br>", 
# 				comma(tr_households),
# 				"<br>", 
# 				"<br>",		

# 			"<b><i><u>Vulnerable Population Measures Met</b></i></u>", 
# 				"<br>", 
			
# 			"<b>Very low income</b><br>", 
# 				case_when(v_VLI == 1 ~ "Yes", TRUE ~ "No"), 
# 			 	"<br>(<i>",
# 			 		percent(tr_VLI_prop, accuracy = .1), " tract VLI, ",
# 			 		percent(co_VLI_prop, accuracy = .1), " county VLI, & ",
# 			 		percent(tr_pstudents, accuracy = .1), " students</i>)", 
# 			 	"<br>",

# 			"<b>Persons of color</b><br>", 
# 			  	case_when(v_POC == 1 ~ "Yes", TRUE ~ "No"), 
# 			 	" (<i>",
# 			 		percent(tr_pPOC, accuracy = .1), " tract & ",
# 			 		percent(co_pPOC, accuracy = .1), " county</i>)", 
# 			 	"<br>",

# 			"<b>Renting household percentage</b><br>    ", 
# 			  	case_when(v_Renters == 1 ~ "Yes", TRUE ~ "No"), 
# 			 	" (<i>",
# 			 		percent(tr_prenters, accuracy = .1), " tract & ",
# 			 		percent(co_prenters, accuracy = .1), " county</i>)", 
# 				"<br>", 

# 			"<b>Very low income renters paying<br>over 50% of income to rent</b><br>    ", 
# 			  	case_when(v_RB50VLI == 1 ~ "Yes", TRUE ~ "No"), 
# 			 	" (<i>",
# 			 		percent(tr_irVLI_50p, accuracy = .1), " tract & ",
# 			 		percent(co_irVLI_50p, accuracy = .1), " county</i>)", 
# 				"<br>", 			  
# 				"<br>",

# 			"<b><i><u>Displacement Pressures Met</b></i></u>", 
# 			  "<br>", 
# 			  "<b>Change in rent</b><br>    ", 
# 			  	case_when(dp_PChRent == 1 ~ "Yes", TRUE ~ "No"), 
# 			 	" (<i>",
# 			 		percent(tr_pchrent, accuracy = .1), " tract, ",
# 			 		percent(tr_pchrent.lag, accuracy = .1), " nearby, & ",
# 			 		percent(co_pchrent, accuracy = .1), " county</i>)", 
# 			 	"<br>",
	  
# 			"<b>Rent gap</b><br>     ", 
# 			  	case_when(dp_RentGap == 1 ~ "Yes", TRUE ~ "No"), 
# 			 	" (<i>",
# 			 		dollar(tr_rentgap), " tract & ",
# 			 		dollar(co_rentgap), " county</i>)", 
# 				"<br>", 			  
# 				"<br>",

# 			"<b><i><u>Rent</b></i></u>", 
# 				"<br>", 
# 					"<b>Local</b>","<br>", 
# 					dollar(tr_medrent), "<br>", 
# 					"<b>Nearby</b>", "<br>", 
# 					dollar(tr_medrent.lag), "<br>", 
# 				"<br>", 

# 			"<b><i><u>Racial composition</b></i></u>", "<br>", 
# 				"<b>Neighborhood Type</b>", "<br>", 
# 				NeighType, "<br>", 
# 				"<b>White alone</b>", "<br>",  
# 				percent(tr_pWhite, accuracy = .1), "<br>", 
# 				"<b>Black or African American alone</b>", "<br>", 
# 				percent(tr_pBlack, accuracy = .1), "<br>", 
# 				"<b>Asian alone</b>", "<br>", 
# 				percent(tr_pAsian, accuracy = .1), "<br>", 
# 				"<b>Latinx</b>", "<br>", 
# 				percent(tr_pLatinx, accuracy = .1), "<br>", 
# 				"<b>Other</b>", "<br>", 
# 				percent(tr_pOther, accuracy = .1), "<br>"
# 			  )) # %>% ms_simplify(.) # prefer the detail 

# df_tier2 <- 
# 	df_tiers %>% 
# 	filter(!is.na(tier2))

# # color scheme 1
# pal1 <- 
# 	colorFactor(
# 		c("#FF6633", "#CCCCCC"), 
# 		domain = df_tiers$tier1, 
# 		na.color = "transparent"
# 	)

# # color scheme 2
# pal2 <- 
# 	colorFactor(
# 		c("#6699FF", "#CCCCCC"), 
# 		domain = df_tiers$tier2, 
# 		na.color = "transparent"
# 	)

# # make map
# map <- 
# 	leaflet(data = c(df_tiers, df_tier2)) %>% 
# 	addProviderTiles(providers$CartoDB.Positron) %>% 
# 	addMiniMap(tiles = providers$CartoDB.Positron, 
# 			   toggleDisplay = TRUE) %>% 
# 	addEasyButton(
# 		easyButton(
# 		    icon="fa-crosshairs", 
# 		    title="My Location",
# 		    onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>% 
# 	setView(-122.2712, 37.8044, zoom = 10) %>% 
# # Bus layer
# 	addPolygons(data = Bus, 
# 				label = "label", 
# 				color = "#000000", 
# 				fillColor="#CCCCCC", 
# 				weight = .5, 
# 				opacity = .45, 
# 				fillOpacity = .1, 
# 				stroke = TRUE, 
# 				group = "Bus") %>% 	
# 	addLegend(
# 		color = "#CCCCCC", 
# 		labels = Bus$label, 
# 		group = "Bus"
# 	) %>% 
# # Rail layer
# 	addPolygons(data = Rail, 
# 				layerId = "label", 
# 				color = "#000000", 
# 				fillColor="#CCCCCC", 
# 				weight = .5, 
# 				opacity = .45, 
# 				fillOpacity = .1, 
# 				stroke = TRUE, 
# 				group = "Rail"
# 	) %>% 
# 	addLegend(
# 		color = "#CCCCCC", 
# 		labels = Rail$label, 
# 		group = "Rail"
# 	) %>% 
# # Vulnerable layer
# 	addPolygons(
# 		data = df_tier2, 
# 		group = "Vulnerable",
# 		fillOpacity = .5, 
# 		color = ~pal2(tier2),
# 		stroke = TRUE, 
# 		weight = .5, # border thickness
# 		opacity = .45, 
# 		highlightOptions = highlightOptions(
# 							color = "#ff4a4a", 
# 							weight = 5,
#       						bringToFront = TRUE
#       						), 
# 		popup = ~popup, 
# 		popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
# 	) %>% 
# 	addLegend(
# 		pal = pal2, 
# 		values = ~tier2, 
# 		group = "Vulnerable", 
# 		title = ""
# 	) %>% 
# # Heightened Sensitivity layer
# 	addPolygons(
# 		data = df_tiers, 
# 		group = "Heightened Sensitivity",
# 		fillOpacity = .5, 
# 		color = ~pal1(tier1),
# 		stroke = TRUE, 
# 		weight = .5, # border thickness
# 		opacity = .45, 
# 		highlightOptions = highlightOptions(
# 							color = "#ff4a4a", 
# 							weight = 5,
#       						bringToFront = TRUE
#       						), 
# 		popup = ~popup, 
# 		popupOptions = popupOptions(maxHeight = 215, closeOnClick = TRUE)
# 	) %>% 
# 	addLegend(
# 		pal = pal1, 
# 		values = ~tier1, 
# 		title = ""
# 	) %>% 
# 	addLayersControl(overlayGroups = c("Heightened Sensitivity", "Vulnerable", "Bus", "Rail"),
# 					 options = layersControlOptions(collapsed = TRUE)) %>% 
# 	hideGroup(c("Bus", "Vulnerable"))

# # save map
# htmlwidgets::saveWidget(map, file="~/git/sensitive_communities/docs/map.html")
# # run in terminal, not in rstudio