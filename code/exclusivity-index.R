# ==========================================================================
# Exclusivity index dev
# Developed by Alex Ramiller and Tim Thomas
# 2020.09.18
# ==========================================================================

# ==========================================================================
# Load libraries
# ==========================================================================

if(!require(pacman)) install.packages("pacman")
p_load(tigris, tidycensus, yaml, tidyverse)
options(tigris_class = "sf",
        tigris_use_cache = TRUE)

# census_api_key(read_yaml("/Users/ajramiller/census.yaml"))
census_api_key('4c26aa6ebbaef54a55d3903212eabbb506ade381')

# Census variables
acs2018 <- load_variables(2018, "acs5", cache = TRUE)

closest <- function(x, limits) {
  limits[which.min(abs(limits - x))]
}

exclusivity_measure <- function(state, counties) {
  income <- 
    get_acs(geography = "county",
            table = "B19001",
            state = state,
            year = 2018,
            cache_table = TRUE) %>% 
    filter(GEOID %in% paste0(state, counties)) %>%
    left_join(acs2018, by = c("variable" = "name"))
  
  med_inc <-
    get_acs(geography = "tract",
            variables = "B19013_001",
            state = state,
            county = counties,
            year = 2018,
            cache_table = TRUE)
  
  price <- bind_rows(
    get_acs(geography = "tract",
            variables = c("B25085_001", "B25085_002", "B25085_003", "B25085_004", "B25085_005",
                          "B25085_006", "B25085_007", "B25085_008", "B25085_009", "B25085_010",
                          "B25085_011", "B25085_012", "B25085_013", "B25085_014", "B25085_015",
                          "B25085_016", "B25085_017", "B25085_018", "B25085_019", "B25085_020",
                          "B25085_021", "B25085_022", "B25085_023", "B25085_024"),
            state = state,
            county = counties,
            year = 2018,
            cache_table = TRUE),
    get_acs(geography = "tract",
            variables = c("B25085_025", "B25085_026", "B25085_027"),
            state = state,
            county = counties,
            year = 2018,
            cache_table = TRUE)) %>%
    left_join(acs2018, by = c("variable" = "name")) %>%
    arrange(GEOID, variable)
  
  
  value <- bind_rows(
    get_acs(geography = "tract",
            variables = c("B25075_001", "B25075_002", "B25075_003", "B25075_004", "B25075_005",
                          "B25075_006", "B25075_007", "B25075_008", "B25075_009", "B25075_010",
                          "B25075_011", "B25075_012", "B25075_013", "B25075_014", "B25075_015",
                          "B25075_016", "B25075_017", "B25075_018", "B25075_019", "B25075_020",
                          "B25075_021", "B25075_022", "B25075_023", "B25075_024"),
            state = state,
            county = counties,
            year = 2018,
            cache_table = TRUE),
    get_acs(geography = "tract",
            variables = c("B25075_025", "B25075_026", "B25075_027"),
            state = state,
            county = counties,
            year = 2018,
            cache_table = TRUE)) %>%
    left_join(acs2018, by = c("variable" = "name")) %>%
    arrange(GEOID, variable)
  
  income_limit <- c(0, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 45000, 
                    50000, 60000, 75000, 100000, 125000, 150000, 200000, Inf)
  income$limit <- rep(income_limit, times = nrow(income)/17)
  price_limit <- c(0, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 
                   50000, 60000, 70000, 80000, 90000, 100000, 125000, 150000, 175000, 200000, 
                   250000, 300000, 400000, 500000, 750000, 1000000, 1500000, 2000000, Inf)
  price$limit <- rep(price_limit, times = nrow(price)/27)
  value$limit <- rep(price_limit, times = nrow(price)/27)
  
  #ami <- closest(median(med_inc$estimate, na.rm = TRUE), income$income_limit)
  ami <- median(med_inc$estimate, na.rm = TRUE)
  
  price$income_limit <- price$limit*0.188
  value$income_limit <- value$limit*0.188
  
  price_counts <- 
    price %>% 
    filter(income_limit > 0) %>%
    group_by(GEOID) %>%
    summarize(high = sum(estimate)) %>%
    left_join(
      price %>% 
        filter(income_limit <= closest(1.2*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(middle = sum(estimate))
    ) %>%
    left_join(
      price %>% 
        filter(income_limit <= closest(0.8*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(low = sum(estimate))
    ) %>%
    left_join(
      price %>% 
        filter(income_limit <= closest(0.5*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(very_low = sum(estimate))
    ) %>%
    left_join(
      price %>% 
        filter(income_limit <= closest(0.3*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(extremely_low = sum(estimate))
    ) %>%
    left_join(
      price %>%
        filter(income_limit == 0) %>%
        select(GEOID, total = estimate)
    )
  
  value_counts <- 
    value %>% 
    filter(income_limit > 0) %>%
    group_by(GEOID) %>%
    summarize(high = sum(estimate)) %>%
    left_join(
      value %>% 
        filter(income_limit <= closest(1.2*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(middle = sum(estimate))
    ) %>%
    left_join(
      value %>% 
        filter(income_limit <= closest(0.8*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(low = sum(estimate))
    ) %>%
    left_join(
      value %>% 
        filter(income_limit <= closest(0.5*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(very_low = sum(estimate))
    ) %>%
    left_join(
      value %>% 
        filter(income_limit <= closest(0.3*ami, price_limit) &
                 income_limit > 0) %>%
        group_by(GEOID) %>%
        summarize(extremely_low = sum(estimate))
    ) %>%
    left_join(
      value %>%
        filter(income_limit == 0) %>%
        select(GEOID, total = estimate)
    )
  
  high_income <- sum(income %>% 
                       filter(limit > closest(1.2*ami, income$limit)) %>%
                       select(estimate))/sum(income$estimate[income$limit == 0])
  
  middle_income <- sum(income %>% 
                          filter(limit <= closest(1.2*ami, income$limit) &
                                   limit > 0) %>%
                          select(estimate))/sum(income$estimate[income$limit == 0])
  
  low_income <- sum(income %>% 
                      filter(limit <= closest(0.8*ami, income$limit) &
                               limit > 0) %>%
                      select(estimate))/sum(income$estimate[income$limit == 0])
  
  very_low_income <- sum(income %>% 
                           filter(limit <= closest(0.5*ami, income$limit) &
                                    limit > 0) %>%
                           select(estimate))/sum(income$estimate[income$limit == 0])
  
  extremely_low_income <- sum(income %>% 
                                filter(limit <= closest(0.3*ami, income$limit) &
                                         limit > 0) %>%
                                select(estimate))/sum(income$estimate[income$limit == 0])
  
  tract_counts <- bind_rows(price_counts, value_counts) %>%
    group_by(GEOID) %>% summarize_all(~sum(.)) %>%
    mutate(high = (total - middle)/total,
           middle = middle/total,
           low = low/total,
           very_low = very_low/total,
           extremely_low = extremely_low/total) %>%
    mutate(high_ratio = high/high_income,
           middle_ratio = middle/middle_income,
           low_ratio = low/low_income,
           very_low_ratio = very_low/very_low_income,
           extremely_low_ratio = extremely_low/extremely_low_income,
           high_access = high*high_income,
           middle_access = middle*middle_income,
           low_access = low*low_income,
           very_low_access = very_low*very_low_income,
           extremely_low_access = extremely_low*extremely_low_income)
  
  tracts(state, counties) %>% left_join(tract_counts)
}

king <- exclusivity_measure("53", "033")
puget <- exclusivity_measure("53", c("033", "053", "061"))
bay5 <- exclusivity_measure("06", c("001", "013", "041", "075", "081"))
bay9 <- exclusivity_measure("06", c("001", "013", "041", "055", "075", "081", "085", "095", "097"))


plot_exclusivity_ratio <- function(data, variable){
  plot(data[variable], 
       breaks = c(0, 0.5, 1, 1.5, max(data %>% st_drop_geometry() %>% select(variable), na.rm = TRUE)),
       pal = brewer.pal(4, "RdBu"), lwd = 0.25)                     
}

plot_exclusivity_access <- function(data, variable, title){
  plot(data[variable], lwd = 0.25, main = title)                  
}

plot_exclusivity_access(puget, "high_access", "Access (>120% of AMI)")
plot_exclusivity_access(puget, "middle_access", "Access (<120% of AMI)")
plot_exclusivity_access(puget, "low_access", "Access (<80% of AMI)")
plot_exclusivity_access(puget, "very_low_access", "Access (<50% of AMI)")
plot_exclusivity_access(puget, "extremely_low_access", "Access (<30% of AMI)")

plot_exclusivity_access(bay9, "high_access", "Access (>120% of AMI)")
plot_exclusivity_access(bay9, "middle_access", "Access (<120% of AMI)")
plot_exclusivity_access(bay9, "low_access", "Access (<80% of AMI)")
plot_exclusivity_access(bay9, "very_low_access", "Access (<50% of AMI)")
plot_exclusivity_access(bay9, "extremely_low_access", "Access (<30% of AMI)")