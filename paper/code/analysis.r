# ==========================================================================
# Displacement Typologies Methods Paper
# Notes: https://docs.google.com/document/d/1WKuu3LoRlHzKtGBzmytRni5kzdUc--_BboicjcoNTfs/edit
# Modeling Strategy 1: 
# 	displacement typology = eviction + disinvestment + gentrification typology
# ==========================================================================

pacman::p_load(foreign, nnet, reshape2, tidyverse)
options(scipen = 10, width=Sys.getenv("COLUMNS")) # avoid scientific notation

ml <- read.dta("https://stats.idre.ucla.edu/stat/data/hsbdemo.dta")

with(ml, table(ses, prog))

ml$prog2 <- relevel(ml$prog, ref = "academic")
test <- multinom(prog2 ~ ses + write, data = ml)

summary(test)

z <- summary(test)$coefficients/summary(test)$standard.errors
z

p <- (1 - pnorm(abs(z), 0, 1)) * 2
p

# ==========================================================================
# DT data
# ==========================================================================

sea_dt <- 
	read_csv("~/git/displacement-typologies/data/outputs/typologies/Seattle_typology_output.csv") %>% 
	left_join(read_csv('/Users/timthomas/git/displacement-typologies/data/downloads_for_public/seattle.csv')) %>% 
	mutate(Typology = factor(Typology))

sea_ev <- 
	read_csv("/Volumes/GoogleDrive/My Drive/data/hprm_data/evictions/wa_eviction_data.csv") %>% 
	filter(Year == 2017, Race == 'total')

df <- left_join(sea_dt, sea_ev)

# ==========================================================================
# Multi-nomial Modeling and Analysis
# ==========================================================================

#
# Determine most frequent typology
# --------------------------------------------------------------------------

df %>% group_by(Typology) %>% count() 

#
# Relevel for Stable Moderate/Mixed Income and test
# --------------------------------------------------------------------------

df$Typology2 <- relevel(df$Typology, ref = 'Stable Moderate/Mixed Income')
test <- multinom(Typology2 ~ Eviction + real_mrent_18 + real_mhval_18 + white_18, data = df)
summary(test)

z <- summary(test)$coefficients/summary(test)$standard.errors
z

p <- (1 - pnorm(abs(z), 0, 1)) * 2
p

exp(coef(test))

#
# Predicted values
# --------------------------------------------------------------------------
head(pp <- fitted(test))

dses <- data.frame(Eviction = rep(mean(df$Eviction, na.rm = TRUE)), real_mrent_18 = mean(df$real_mrent_18), real_mhval_18 = mean(df$real_mhval_18), white_18 = mean(df$white_18))
predict(test, newdata = dses, "probs")

dwrite <- data.frame(Eviction = rep(c(1,7,15), each = length(df)), write = rep(c(30:70),
    3))

## store the predicted probabilities for each value of ses and write
pp.write <- cbind(dwrite, predict(test, newdata = dwrite, type = "probs", se = TRUE))

## calculate the mean probabilities within each level of ses
by(pp.write[, 3:5], pp.write$ses, colMeans)


# ==========================================================================
# 
# ==========================================================================
test2 <- glm(Rate ~ Typology2, data = df)
summary(test2)

test3 <- glm(Rate ~ Typology2 + tr_rent_gap + real_mrent_18 + real_mhval_18 + white_18, data = df)
summary(test3)

#### Does prior displacement in 90's predict gentrification in the teens or vice versa 


