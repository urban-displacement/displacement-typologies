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
pacman::p_load(sf, geojsonsf, tidyverse, tigris, tidycensus, leaflet)

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
        read_csv('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Outputs/atlanta_typology_2020.2.29.csv') %>% 
        mutate(city = 'Atlanta'),
        read_csv('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Outputs/denver_typology_2020.2.29.csv') %>%
        mutate(city = 'Denver'),
        read_csv('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Outputs/chicago_typology_2020.2.29.csv') %>% 
        mutate(city = 'Chicago'),
        read_csv('/Volumes/GoogleDrive/My Drive/CCI Docs/Current Projects/SPARCC/Data/Outputs/memphis_typology_2020.2.29.csv') %>% 
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
		)) %>% 
    group_by(GEOID) %>% 
    mutate( 
        per_ch_li = (all_li_count_17-all_li_count_00)/all_li_count_00,
        popup = # What to include in the popup 
          str_c(
              "<b>Tract: ", GEOID, "</b>",
              "<br>", 
              Typology, 
            # Market
              "<br><br>",
              "<b>Market Dynamics<b><br>",
              Tract median home value: real_mhval_17<br>
              Change from 2000 to 2017: pctch_real_mhval_00_17,<br>
              Regional median home value: rm_real_mhval_17<br>
              <br>
              Tract median rent: real_mrent_17<br>
              Change from 2000 to 2017: pctch_real_mrent_00_17<br>
              Regional median rent: rm_real_mrent_17<br>
              <br>
            # demographics
             "<b>Demographics<b/><br>", 
             Tract population: pop_17
             Tract household count: hh_17
             Tract median income: real_hinc_17
             Percent low income hh: per_all_li_17
             Percent change in LI: per_ch_li

             Percent non-White: per_nonwhite_17
             Regional median non-White: rm_per_nonwhite_17

             Percent college educated: per_col_17
             Regainal median educated: rm_per_col_17
            
            # risk factors
            
            
          )
	) %>% 
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

# ==========================================================================
# Maps
# ==========================================================================

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

redpal <- 
	colorFactor(
		c("#4ac938", "#2b83ba", "#ff8c1c", "#ff1c1c"), 
		domain = red$Grade, 
		na.color = "transparent"
	)

# pal1 <- 
#     colorFactor(
#         c("#E4E0EB","#AAC2F0","#CAC2D7","#8B7EBE","#5C4B77","#FAEBDC","#F5D6B9","#ECB476","#D5722D"), 
#         domain = df$Typology, 
#         na.color = "transparent"
#     )

# pal2 <- 
# 	colorFactor(
# 		c("#CCCCCC","#99CCff","#CCCCFF","#6666CC","#663399","#FFFFCC","#FFCC99","#FF9933","#FF6600"), 
# 		domain = df$Typology, 
# 		na.color = "transparent"
# 	)

pal3 <- 
	colorFactor(
		c("#f2f0f7",
            "#6699cc","#cbc9e2",
            # "#9e9ac8",
            "#756bb1","#54278f","#ffffd4","#fed98e","#fe9929","#cc4c02", "#ffffff"), 
		domain = df$Typology, 
		na.color = "transparent"
	)


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
# houseicon <- awesomeIcons(
#   icon = 'home',
#   iconColor = 'white',
#   library = 'fa',
#   markerColor = 'blue'
# )

# getColor <- function(industrial) {
#   sapply(industrial$site, function(site) {
#     if(site == "Superfund") {
#         "orange"
#     } else if(site == "TRI") {
#             "red"
#         }
#     })
# }

# indcons <- 
#     awesomeIcons(
#         icon = 'industry', 
#         iconColor = 'black', 
#         library = 'fa', 
#         markerColor = getColor(industrial)
#     )

indpal <- 
    colorFactor(c("navy", "red"), domain = c("Superfund", "TRI"))
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
	addPolygons(
		data = data, 
		group = "SPARCC Typology", 
		fillOpacity = .5, 
		color = ~pal3(Typology), 
		stroke = TRUE, 
		weight = .5, 
		opacity = .60, 
		highlightOptions = highlightOptions(
							color = "#ff4a4a", 
							weight = 5,
      						bringToFront = TRUE
      						), 
		popup = ~popup
	) %>% 	
	addLegend(
		pal = pal3, 
		values = ~Typology, 
		group = "SPARCC Typology"
	) %>% 
    addPolygons(
        data = red %>% filter(city == city_name), 
        group = "Redlined Areas", 
        fillOpacity = .3, 
        color = ~redpal(Grade), 
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
        pal = redpal, 
        values = ~Grade, 
        group = "Redlined Areas",
        title = "Redline Zones"
    ) %>%     
# Public Housing
    # addAwesomeMarkers(
    #     data = hud %>% filter(state == st), 
    #     lng = ~longitude, 
    #     lat = ~latitude, 
    #     icon = houseicon, 
    #     clusterOptions = markerClusterOptions(), 
    #     group = 'Public Housing'
    # ) %>%     
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
    # addLegend(
    #     data = hud, 
    #     color = ~colorFactor("green"), 
    #     values = "Public Housing", 
    #     group = "Public Housing", 
    #     title = ""
    # ) %>%    
# Public Housing
    addCircleMarkers(
        data = industrial %>% filter(state == st), 
        radius = 5, 
        lng = ~longitude, 
        lat = ~latitude, 
        color = ~indpal(site),
        # clusterOptions = markerClusterOptions(), 
        group = 'Industrial Sites', 
        popup = ~site,
        fillOpacity = .5, 
        stroke = FALSE
    ) %>%     
    # addAwesomeMarkers(
    #     data = industrial %>% filter(state == st), 
    #     lng = ~longitude, 
    #     lat = ~latitude, 
    #     icon = indcons, 
    #     clusterOptions = markerClusterOptions(), 
    #     group = 'Industrial Sites', 
    #     popup = ~site
    # ) %>% 
    addLegend(
        data = industrial, 
        pal = indpal, 
        values = ~site, 
        group = "Industrial Sites", 
        title = "Industrial Sites"
    ) %>%    
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