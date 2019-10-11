clear all
set more off
cd "/Users/LAUREN/Documents/Berkeley/UDP/Typologies/Run typologies 08_13_19/Denver"
* PREP FOR MERGE * 
*begin by uploading datasets to identify the format of the FIPS code variable, 
*often labeled FIPS or trtid10 (meaning tract id are 2010 values). For ease of merging
* preferable that the tractid/FIPS code is a string, not numeric value &  has 11 digits, with a leading zero for single digit
* state codes
clear
use 1990_111618
	* contains 1990 household by race, tenure, housing unit, commute, college & building data (pre 1950)

use incomeinterpolated
rename FIPS trtid10 
save incomeinterpolated_mastermod,replace
	* contains 90,2017 and 200 houshold income data & income interpolation according to older methodology
	
use 2017

use 2000_111618

use mrent_mhval_10

use 2002_emp_co

use 2017_mover_interpolated

use larea_downtown

use 2009_movers

use 22000_mh
tostring trtid10, replace format("%011.0f")
save 22000_mh_mastermodified, replace 

use 21990_mh
tostring trtid10, replace format("%011.0f")
save 21990_mh_mastermodified, replace 

*  MERGE * 
use 1990_111618
merge 1:1 trtid10 using incomeinterpolated_mastermod
rename _merge _incomeinterp

merge 1:1 trtid10 using 2017
rename _merge _merge17

merge 1:1 trtid10 using 2000_111618
rename _merge _merge00

merge 1:1 trtid10 using mrent_mhval_10
rename _merge _merge_mrent10
	* merge in 2010 median rental and home values


merge 1:1 trtid10 using 2002_emp_co
rename _merge _merge_emp

save Denver_merge_0805aff_approach,replace

use Denver_merge_0805aff_approach
merge 1:1 trtid10 using 2017_mover_interpolated
rename _merge _merge_moverinterp

merge 1:1 trtid10 using larea_downtown
rename _merge _merge_lareadt

merge 1:1 trtid10 using 2009_movers
rename _merge _merge09move

merge 1:1 trtid10 using 22000_mh_mastermodified
rename _merge _merge00mh

merge 1:1 trtid10 using 21990_mh_mastermodified
rename _merge _merge90mh

save Denver_merge_0805aff_approach,replace


* * then clip to regions 

gen stcty=substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
drop stcty

save Denver_merge_0805aff_approach,replace


* prep for merge of new flags 

* recent move-in (2010)
use YearHouseholderMovedIn_Denver2010
tostring FIPS, replace format ("%011.0f")
rename FIPS trtid10

* rename standard error variables so they are more intuitive while retaining
* original variable name in the label 
rename B25038001s se_occupiedunits 
label variable se_occupiedunits "SE Occupied Housing Units B25038001s" 

rename B25038002s se_owneroccunits
label variable se_owneroccunits "SE Occupied Housing Units(OHU) - Owner Occ B25038002s" 

rename B25038003s se_ownerocc_2015orlater
label variable se_ownerocc_2015orlater "Std Error OHU - Owner Occ 2015orlater B25038003s" 

rename B25038004s se_ownerocc_2010to2014 
label variable se_ownerocc_2010to2014 "Std Error OHU - Owner Occ Movein2010-2014 B25038004s" 

rename B25038005s se_ownerocc_2000to2009
label variable se_ownerocc_2000to2009 "Std Error OHU - Owner Occ Movein2000-2009 B25038005s" 

rename B25038006s se_ownerocc_1990to1999
label variable se_ownerocc_1990to1999 "Std Error OHU - Owner Occ Movein1990-1999 B25038006s" 

rename B25038007s se_ownerocc_1980to1989
label variable se_ownerocc_1980to1989 "Std Error OHU - Owner Occ Movein1980-1989 B25038007s" 

rename B25038008s se_ownerocc_1979orearlier
label variable se_ownerocc_1979orearlier "Std Error OHU - Owner Occ Movein1979or earlier B25038008s" 

rename B25038009s se_renteroccunits
label variable se_renteroccunits "Std Error OHU - Renter Occ B25038009s" 

rename B25038010s se_renterocc_2015orlater
label variable se_renterocc_2015orlater "Std Error OHU - Renter Occ 2015orlater B25038010s" 

rename B25038011s se_renterocc_2010to2014
label variable se_renterocc_2010to2014 "Std Error OHU - Renter Occ 2010-2014 B25038011s" 

rename B25038012s se_renterocc_2000to2009 
label variable se_renterocc_2000to2009 "Std Error OHU - Renter Occ 2000-2009 B25038012s" 

rename B25038013s se_renterocc_1990to1999
label variable se_renterocc_1990to1999 "Std Error OHU - Renter Occ 1990-1999 B25038013s" 

rename B25038014s se_renterocc_1980to1989
label variable se_renterocc_1980to1989 "Std Error OHU - Renter Occ 1980-1989 B25038014s" 

rename B25038015s se_renterocc_1979orearlier
label variable se_renterocc_1979orearlier "Std Error OHU - Renter Occ 1979orearlier B25038015s" 

keep trtid10 se_occupiedunits se_owneroccunits se_ownerocc_2015orlater se_ownerocc_2010to2014 se_ownerocc_2000to2009 se_ownerocc_1990to1999 se_ownerocc_1980to1989 se_ownerocc_1979orearlier se_renteroccunits se_renterocc_2015orlater se_renterocc_2010to2014 se_renterocc_2000to2009 se_renterocc_1990to1999 se_renterocc_1980to1989 se_renterocc_1979orearlier pct_renter_recentmovein pct_owner_recentmovein pct_tot_recentmovein pct_renter_recentmovein2010 pct_owner_recentmovein2010 pct_tot_recentmovein2010 rm_pct_recentmovein aboverm_pct_recentmovein rm_pct_recentmovein2010 aboverm_pct_recentmovein2010 occupiedunits owneroccunits ownerocc_2015orlater ownerocc_2010to2014 ownerocc_2000to2009 ownerocc_1990to1999 ownerocc_1980to1989 ownerocc_1979orearlier renteroccunits renterocc_2015orlater renterocc_2010to2014 renterocc_2000to2009 renterocc_1990to1999 renterocc_1980to1989 renterocc_1979orearlier     
save YearHouseholderMovedIn_Denver2010_mastermod, replace


 

* mortgage denial rate / appl rate
use Denver_HMDA_Denial_Application_Rates
keep trtid10 owneroccunits renterocc_units per_own_17 per_rent_17 tot_units applicationrate high_dr20 high_dr25 high_dr30 low_app_rate
tostring trtid10, replace format ("%011.0f")
save Denver_HMDA_mastermod ,replace

* PROXIMITY 
clear
insheet using Denver_Proximity.csv 
tostring trtid10, replace format ("%011.0f")
keep trtid10 proximity excli
rename excli exclusive 
order trtid10
gen stcty=substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
drop stcty
save Denver_Proximity_mastermod, replace


* PRISON 

use DenverPrison_Processed
tostring FIPS, gen(trtid10) format ("%011.0f")
order trtid10
keep trtid10 prison_pct prison_flag highprisonpop_flag
save DenverPrison_mastermod, replace

* PH-LIHTC
use ph-LIHTC_merge_denver_062519
keep trtid10 presence_ph_LIHTC
save ph_LIHTC_mastermod, replace

* foreclosure
use Denver_Foreclosure_072019
rename tractcode trtid10
keep trtid10 estimated_foreclosure_rate rm_foreclosure_rate aboverm_foreclosurerate
save Denver_Foreclosure_mastermodified, replace


* LI home ownership 
use homeownershipflag_LIneighbs
keep if stcty==08001 | stcty==08005 | stcty==08013 | stcty==08014 | stcty==08019 | stcty==08031 | stcty==08035 | stcty==08047 | stcty==08059

keep trtid10 LItract homeownership_rm_LItracts aboverm_homeownership_LItracts
rename trtid10 trtid
tostring trtid, gen(trtid10) format ("%011.0f")
drop trtid
save homeownershipflag_LIneighbs_mastermodified, replace


* Neighborhood Income Level 
use neighb_inc_level_053119
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
rename stctytrct trtid10
keep trtid10 reg_med_inc60_17 reg_med_inc120_17 reg_med_inc80_17 low_pdmt_80120 mod_pdmt_80120 high_pdmt_80120 low_pdmt_55cut_80120_medhhinc high_pdmt_55cut_80120_medhhinc mod_pdmt_55cut_80120_medhhinc mix_low_55cut_80120_medhhinc mix_mod_55cut_80120_medhhinc mix_high_55cut_80120_medhhinc inc_cat_55cut_80120_medhhinc 
save neighb_inc_level_070519, replace
save den_neighb_inc_level_mastermod, replace 

* Vacancy 
use CO_20175YR_vacancyrate
tostring trtid10, replace format ("%011.0f")
gen stcty= substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
save den_20175YR_vacancyrate_update,replace

keep trtid10 vacancy_rate rm_vacancy vacancy_rm_flag
save den_2017_vacancyrate_mastermod, replace



* housing units 
clear
use 2010_2017_units_v_HHs

* EDIT FOR PERCENT CHANGE, NOT SIMPLY VALUE CHANGE
*drop flags 
drop flag_units_v_HHs
drop rm_units_2010_2017
drop flag_rm_units_change

**** calculate PERCENT CHANGE in households *****
gen per_change_HHs_2010_2017 = ((A10008_001 - T058_001)/T058_001)*100
gen per_change_units_2010_2017 = ((A10001_001 - T068_001)/T068_001)*100

save den_2010_2017_units_v_HHs, replace 

* make a flag for if units increased no more than households over this time period
* in other words, if households increased as much as or more than units
* coded so that change in HHs is greater than 0
gen flag_units_v_HHs =0 if per_change_units_2010_2017 >= per_change_HHs_2010_2017
replace flag_units_v_HHs =1 if per_change_units_2010_2017 < per_change_HHs_2010_2017
replace flag_units_v_HHs =0 if per_change_HHs_2010_2017 <= 0

* make a flag for if the units increased more than the regional median
egen rm_units_2010_2017 = median(per_change_units_2010_2017)
gen flag_rm_units_change =1 if change_units_2010_2017 >= rm_units_2010_2017
replace flag_rm_units_change =0 if change_units_2010_2017 < rm_units_2010_2017

rename FIPS trtid10
keep trtid10 per_change_HHs_2010_2017 per_change_units_2010_2017 flag_units_v_HHs rm_units_2010_2017 flag_rm_units_change
save den_2010-17_units_v_HHs_mastermod, replace 


*    *      *

* * MERGE cleaned variables  *  * 

*    *      * 

use Denver_merge_0805aff_approach
	* open the memphis master merge file to merge cleaned data 


merge 1:1 trtid10 using YearHouseholderMovedIn_Denver2010_mastermod
rename _merge _merge_2010movein
	* merge in householder move-in data from 2010 (includes low income move-in)


merge 1:1 trtid10 using Denver_HMDA_mastermod
rename _merge _merge_HMDAdenial_appl_rate
	* application and denial rates merge 

merge 1:1 trtid10 using Denver_Proximity_mastermod
rename _merge _merge_proximity
	* merge in proximity to exclusive zones
	
merge 1:1 trtid10 using ph_LIHTC_mastermod
rename _merge _merge_subsidizedhousing
	* merge in subsidized housing flag (presence of public housing or LIHTC units)
	
merge 1:1 trtid10 using Denver_Foreclosure_mastermodified
rename _merge _merge_forclosure
	* merge foreclosure rates 

merge 1:1 trtid10 using homeownershipflag_LIneighbs_mastermodified
rename _merge _merge_LI_homeowner
	* merge low income home ownership

merge 1:1 trtid10 using DenverPrison_mastermod
rename _merge _merge_prison
	*merge prison tracts flags 

merge 1:1 trtid10 using den_neighb_inc_level_mastermod
rename _merge _merge_inclevel
	* merge in neighborhood income level (55 % cut off for AMI predominance & 80-120AMI cut offs)

merge 1:1 trtid10 using den_2017_vacancyrate_mastermod
rename _merge _merge_vacancyrate17
	* merge in vacancy rate data 

merge 1:1 trtid10 using den_2010-17_units_v_HHs_mastermod
rename _merge _merge_units_v_HHs
	* merge in data with growth of housing units compared to growth of households

save Denver_merge_0805aff_approach,replace


* prepare & merge zillow/affordability variables

/* initially used older version of affordability data
use aff_ACSchange_zillowrecent
tostring trtid10, replace format ("%011.0f")
keep trtid10 aff_change_cat_full ab_50pct_ch lmh_flag_new
gen stcty= substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
drop stcty

merge 1:1 trtid10 using den_aff_ACSchange_zillowrecent
rename _merge _merge_denver_aff
save Denver_070219,replace 
*/



/* New Market Approach file for affordability/market rate 

use 0705_aff_ACSchange_zillowrecent_60120_55cut_newapproach
tostring trtid10, replace format ("%011.0f")

keep trtid10 aff_change_cat_full ab_30pct_ch ab_50pct_ch ab_90percentile_ch lmh_flag_new
gen stcty= substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
drop stcty
save den_new_affordability_approach,replace 

use Denver_070219
merge 1:1 trtid10 using den_new_affordability_approach
rename _merge _merge_denver_aff
save Denver_070219,replace 

*/

* NEWER Market Approach file for affordability/market rate 

*use new version of rental/home value change data that is more permissive than prior version (above) 
use 0805_aff_ACSchange_zillowrecent_60120_55cut_newapproach
tostring trtid10, replace format ("%011.0f")

keep trtid10 lmh_flag_new aff_change_cat_full ab_30pct_ch ab_50pct_ch ab_90percentile_ch
gen stcty= substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
drop stcty
save den_0805_affordability_approach,replace 

use Denver_merge_0805aff_approach
merge 1:1 trtid10 using den_0805_affordability_approach
rename _merge _merge_aff
save Denver_merge_0805aff_approach,replace


* prepare & merge proximity to rail variables 
use Denver_Rail_02052019
tostring geoid, gen(trtid10) format ("%011.0f")
keep rail trtid10 shape_length shape_area
save Denver_Rail_mastermod, replace 

use Denver_merge_0805aff_approach
merge 1:1 trtid10 using Denver_Rail_mastermod
rename _merge _merge_rail
save Denver_merge_0805aff_approach,replace


* percent owner - create variables for 2000 & 1990; rename 2017
rename per_own_17 per_owners_17

gen per_owners_90 = (ohu_90/hu_90)*100
label var per_owners_90 "(ohu_90/hu_90)*100"

gen per_owners_00 = (ohu_00/hu_00)*100
label var per_owners_00 "(ohu_00/hu_00)*100"

save Denver_merge_0805aff_approach,replace

* merge 2010 Low Income Inmigration 

use Denver_merge_0805aff_approach
merge 1:1 trtid10 using Denver_2010_mover_interpolated
rename _merge _merge_2010mover_interp
save Denver_merge_0805aff_approach,replace

* prepare & merge anchor instiutions (presence of hospitals & universities)
clear 
use RR_042919

gen achor_institution =1 if hosp_fl >0 | uni_fl >0
replace achor_institution=0 if missing(achor_institution)
keep trtid10 hosp_fl uni_fl achor_institution
gen stcty= substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
drop stcty 
save den_anchor_institutions, replace 

use Denver_merge_0805aff_approach
merge 1:1 trtid10 using den_anchor_institutions
rename _merge _merge_anchor
save Denver_merge_0805aff_approach, replace 


* changing for all one region
gen region = 1



** Generate real income variables
*CPI in 2017 vs 90
* gen real_hinc_90 = hinc_90 * (240.007/130.7) (already adjusted)
gen real_hinc_90 = hinc_90 * (245.120/240.007)
gen real_mhval_90 = mhval_90 * (245.120/130.7)
gen real_mrent_90 = mrent_90 * (245.120/130.7)


*CPI in 2017 vs 00
* gen real_hinc_00 = hinc_00 * (240.007/172.2) (already adjusted)
gen real_hinc_00 = hinc_00 * (245.120/240.007)
gen real_mhval_00 = mhval_00 * (245.120/172.2)
gen real_mrent_00 = mrent_00 * (245.120/172.2)





** Cleaning
gen popflag17=.
replace popflag17=1 if pop_17>=500 & pop_17~=.
replace popflag17=0 if pop_17<500 & pop_17~=.

gen popflag00=.
replace popflag00=1 if pop_00>=500 & pop_00~=.
replace popflag00=0 if pop_00<500 & pop_00~=.

gen popflag90=.
replace popflag90=1 if pop_90>=500 & pop_90~=.
replace popflag90=0 if pop_90<500 & pop_90~=.


* Flag VLI tracts
rename vli1990 vli_90
rename vli2000 vli_00
rename vli2017 vli_17
rename li1990 li_90
rename li2000 li_00
rename li2017 li_17
rename mi1990 mi_90
rename mi2000 mi_00
rename mi2017 mi_17
rename hmi1990 hmi_90
rename hmi2000 hmi_00
rename hmi2017 hmi_17
rename hi1990 hi_90
rename hi2000 hi_00
rename hi2017 hi_17
rename vhi1990 vhi_90
rename vhi2000 vhi_00
rename vhi2017 vhi_17

gen vli_flag = 0
replace vli_flag = 1 if vli_17>=.50


tostring trtid10, replace format(%11.0f)


*Weird thing about LI data is that li=50-80% AMI since vli=<50%AMI, need a var for all<80%
egen per_all_li_17 = rowtotal (vli_17 li_17), missing
label var per_all_li_17 "Proportion < 80% AMI"
egen per_all_li_00 = rowtotal (vli_00 li_00), missing
label var per_all_li_00 "Proportion < 80% AMI"
egen per_all_li_90 = rowtotal (vli_90 li_90), missing
label var per_all_li_90 "Proportion < 80% AMI"



* keep trtid10 vli_00 vhi_90
* save den_inc_032419.dta, replace



rename mrent_10 real_mrent_10
rename mhval_10 real_mhval_10

* keep trtid10 real_mrent* real_mhval* 
* save ACS_change.dta, replace

*The low-inc vars are also proportions, so need to make them counts
gen all_li_count_17 = per_all_li_17*hh_17
gen all_li_count_00 = per_all_li_00*hh_00
gen all_li_count_90 = per_all_li_90*hh_90

*for ease of looping, relabel the 2017 vars as "real" as well.
gen real_hinc_17 = hinc_17
gen real_mhval_17 = mhval_17 
gen real_mrent_17 = mrent_17

		
gen empd_17 = tot_jobs/larea
label var empd_17 "2017 employment density (over land area)"

gen density_17 = hu_17/larea



*** CV - coefficient of variation **** 

gen mhval_17_cv = mhval_17_se/mhval_17_se
gen mhval_17_flag30 =0
replace mhval_17_flag30 = 1 if mhval_17_cv > .30

gen mhval_17_flag15 =0
replace mhval_17_flag15 = 1 if mhval_17_cv > .15

* 
gen mrent_17_cv = mrent_17_se/mrent_17
gen mrent_17_flag30 =0
replace mrent_17_flag30 = 1 if mrent_17_cv > .30

gen mrent_17_flag15 =0
replace mrent_17_flag15 = 1 if mrent_17_cv > .15

*
gen per_rent_17_cv = per_rent_17_se/per_rent_17
gen per_rent_17_flag30 = 0
replace per_rent_17_flag30 = 1 if per_rent_17_cv > .3

gen per_rent_17_flag15 = 0
replace per_rent_17_flag15 = 1 if per_rent_17_cv > .15

gen per_col_17_cv = per_col_17_se/per_col_17
gen per_col_17_flag30 = 0 
replace per_col_17_flag30 = 1 if per_col_17_cv >.3

gen per_col_17_flag15 = 0
replace per_col_17_flag15 = 1 if per_col_17_cv >.15

*
gen rhu_17_cv = rhu_17_se/rhu_17
gen rhu_17_flag30 = 0 
replace rhu_17_flag30 = 1 if rhu_17_cv >.3

gen rhu_17_flag15 = 0
replace rhu_17_flag15 = 1 if rhu_17_cv >.15

*
gen pop_17_cv = pop_17_se/pop_17
gen pop_17_flag30 = 0
replace pop_17_flag30 = 1 if pop_17_cv >.3

gen pop_17_flag15 = 0
replace pop_17_flag15 = 1 if pop_17_cv >.15


*
gen hinc_17_cv = hinc_17_se/hinc_17

gen hinc_17_flag30 = 0
replace hinc_17_flag30 = 1 if hinc_17_cv > .30

gen hinc_17_flag15 = 0
replace hinc_17_flag15 = 1 if hinc_17_cv > .15


save Denver_merge_0805aff_approach,replace 





*** CLIP TO REGION  
gen stcty= substr(trtid10,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 

save Denver_merge_0805aff_approach,replace







****************************************************

** **** ADD 2000 Neighborhood Income Level Data **** 

****************************************************


* check out income file - contains income breakdowns for this region in year 2000
clear
use 2000_incomedata
* not going to use the county median income " use 2000_countymi" , will use set reg. median income values provided in "inc_groups_hh by income_testing cutoffs_053119" ///
* do file located in neighborhood income file. base files taken from Master Datasets >> Region >> Income
* madeline defined regional median for 2017, but not for base years. will county median income be what we use. or how did she find it?

******************************

* File 2000_income_data which will be used for interpolation doesn't have a ///
* medium household income var ("med_inc" in neighborhood income code) which is ///
* needed for mix-low  & mix-mod creation
** merge hhinc file to 2000_incomedata file, save, and run again


clear
use hhinc_010319
	* from income folder under Typologies> Master > Chicago > Income_Int 
	* contains median household incomes for year 2000 

keep FIPS hinc_00
rename hinc_00 med_inc
save hhinc_for_2000_neighb_inc_level, replace
	* editing this file keep only year 2000 household median incomes & prepare for merge with income breakdown dataset (viewed above)
	* rename hinc_00 med_inc because this variable is named accordingly in the latter part of neighb income typology code below 

 
use 2000_incomedata
merge 1:1 FIPS using hhinc_for_2000_neighb_inc_level
rename _merge _merge_2000hinc
save 2000_incomedata_modified,replace
	* open income breakdown dataset & merge to year 2000 median household dataset 

****** DETERMINING AMI *********
* issue - how do I assign AMI - use Madeline's median of median method (mentioned in Neighb income read.me)
* accidentally deleted a file from Neighb Income Level Archive file while looking for median-of-tract-medians method
* intended to run my own median-of-medians method to determine 2000 AMI >> Do file to be found in: 
	* Typologies > Master Datasets > Updated Typologies Summer 2019 /// 
		* > Accessory Typology Processing> Regional AMIs - Median of Medians Method

*Kamene definition: Atlanta - $ 51,760.11
*Kamene definition: Chicago - $ 42,917
*Kamene definition: Denver - $ 65,785.05
*Kamene definition: Memphis - $ 44,560.60


* CODE from Income Interpolation 1990 2000 2016.do 

rename T090_001 denominator_00
rename T090_002 I_10000
rename T090_003 I_15000
rename T090_004 I_20000
rename T090_005 I_25000
rename T090_006 I_30000
rename T090_007 I_35000
rename T090_008 I_40000
rename T090_009 I_45000
rename T090_010 I_50000
rename T090_011 I_60000
rename T090_012 I_75000
rename T090_013 I_100000
rename T090_014 I_125000
rename T090_015 I_150000
rename T090_016 I_200000
rename T090_017 I_201


gen reg_med_inc_00 = 0
replace reg_med_inc_00 = 65785.05 



**80120 cutoffs**

*80 percent of the regional median income*

gen reg_med_inc80_00 = 0.8 * reg_med_inc_00





foreach number in 10000 15000 20000 25000 30000 35000 40000 45000 50000 60000 75000 100000 125000 150000 200000{

	gen prop_`number'=I_`number'/denominator_00

}









*80 percent cutoff*

gen inc80_cumulative=0

gen inc80_00=.

foreach number in 10000 15000 20000 25000 30000 35000 40000 45000 {

	local a=`number'

	local b=`number'+4999.99

	local prop = `number' + 5000

	

	replace inc80_cumulative=inc80_cumulative+prop_`a'

	

	replace inc80_00 = ((reg_med_inc80_00 - `a')/(`b'-`a'))*(prop_`prop') + inc80_cumulative if reg_med_inc80_00>=`a' & reg_med_inc80_00 < `b'

	

}

	

*have to continue looping code since the pattern for the numbers changes - code after the macro creation is idential. all that changes is the numbers it runs over

*50k and 60k have to run by themselves since they each have a unique jump to the next income category

foreach number in 50000 {

	local a=`number'

	local b=`number'+9999.99

	local prop = `number' + 10000

	

	replace inc80_cumulative=inc80_cumulative+prop_`a'

	

	replace inc80_00 = ((reg_med_inc80_00 - `a')/(`b'-`a'))*(prop_`prop') + inc80_cumulative if reg_med_inc80_00>=`a' & reg_med_inc80_00 < `b'

	

}



foreach number in 60000 {

	local a=`number'

	local b=`number'+14999.99

	local prop = `number' + 15000

	

	replace inc80_cumulative=inc80_cumulative+prop_`a'

	

	replace inc80_00 = ((reg_med_inc80_00 - `a')/(`b'-`a'))*(prop_`prop') + inc80_cumulative if reg_med_inc80_00>=`a' & reg_med_inc80_00 < `b'

	

}	



foreach number in 75000 100000 125000 {

	local a=`number'

	local b=`number'+24999.99

	local prop = `number' + 25000

	

	replace inc80_cumulative=inc80_cumulative+prop_`a'

	

	replace inc80_00 = ((reg_med_inc80_00 - `a')/(`b'-`a'))*(prop_`prop') + inc80_cumulative if reg_med_inc80_00>=`a' & reg_med_inc80_00 < `b'

	

}

foreach number in 150000 {

	local a=`number'

	local b=`number'+49999.99

	local prop = `number' + 50000

	

	replace inc80_cumulative=inc80_cumulative+prop_`a'

	

	replace inc80_00 = ((reg_med_inc80_00 - `a')/(`b'-`a'))*(prop_`prop') + inc80_cumulative if reg_med_inc80_00>=`a' & reg_med_inc80_00 < `b'

	

}		







*drop prop_15000 prop_20000 prop_25000 prop_30000 prop_35000 prop_40000 prop_45000 prop_50000 prop_60000 prop_75000 prop_125000 prop_150000 prop_200000

drop inc80_cumulative




*120 percent cutoff*

gen reg_med_inc120_00 = 1.2 * reg_med_inc_00

gen inc120_cumulative=0

gen inc120_00=.

foreach number in 10000 15000 20000 25000 30000 35000 40000 45000 {

	local a=`number'

	local b=`number'+4999.99

	local prop = `number' + 5000

	

	replace inc120_cumulative=inc120_cumulative+prop_`a'

	

	replace inc120_00 = ((reg_med_inc120_00 - `a')/(`b'-`a'))*(prop_`prop') + inc120_cumulative if reg_med_inc120_00>=`a' & reg_med_inc120_00< `b'

	

}

	

*have to continue looping code since the pattern for the numbers changes - code after the macro creation is idential. all that changes is the numbers it runs over

*50k and 60k have to run by themselves since they each have a unique jump to the next income category

foreach number in 50000 {

	local a=`number'

	local b=`number'+9999.99

	local prop = `number' + 10000

	

	replace inc120_cumulative=inc120_cumulative+prop_`a'

	

	replace inc120_00 = ((reg_med_inc120_00 - `a')/(`b'-`a'))*(prop_`prop') + inc120_cumulative if reg_med_inc120_00>=`a' & reg_med_inc120_00 < `b'

	

}



foreach number in 60000 {

	local a=`number'

	local b=`number'+14999.99

	local prop = `number' + 15000

	

	replace inc120_cumulative=inc120_cumulative+prop_`a'

	

	replace inc120_00 = ((reg_med_inc120_00 - `a')/(`b'-`a'))*(prop_`prop') + inc120_cumulative if reg_med_inc120_00>=`a' & reg_med_inc120_00 < `b'

	

}	



foreach number in 75000 100000 125000 {

	local a=`number'

	local b=`number'+24999.99

	local prop = `number' + 25000

	

	replace inc120_cumulative=inc120_cumulative+prop_`a'

	

	replace inc120_00 = ((reg_med_inc120_00 - `a')/(`b'-`a'))*(prop_`prop') + inc120_cumulative if reg_med_inc120_00>=`a' & reg_med_inc120_00 < `b'

	

}

foreach number in 150000 {

	local a=`number'

	local b=`number'+49999.99

	local prop = `number' + 50000

	

	replace inc120_cumulative=inc120_cumulative+prop_`a'

	

	replace inc120_00 = ((reg_med_inc120_00 - `a')/(`b'-`a'))*(prop_`prop') + inc120_cumulative if reg_med_inc120_00>=`a' & reg_med_inc120_00 < `b'

	
} 

drop inc120_cumulative








*generate share of each income group*

gen low_80120_00 = inc80_00

gen mod_80120_00 = inc120_00 - inc80_00

gen high_80120_00 = 1 - inc120_00



label var low_80120_00 "proportion .8 regional mhi or less"

label var mod_80120_00 "proportion .8 to 1.2 regional mhi"

label var high_80120_00 "proportion 1.2 regional mhi or more"


*valid sample includes tracts with income data only*

*25 tracts without income data are excluded*

gen validsample = 1
replace validsample = 0 if inc80_00==. | inc120_00==.
*adapted from neighb income do file


*generate income categories*

gen low_pdmt_80120 = 0

replace low_pdmt_80120 = 1 if low_80120_00 >= 0.5 & mod_80120_00 < 0.4 & high_80120_00 < 0.4

replace low_pdmt_80120 = . if validsample==0

gen high_pdmt_80120 = 0

replace high_pdmt_80120 = 1 if high_80120_00 >= 0.5 & low_80120_00 < 0.4 & mod_80120_00 < 0.4

replace high_pdmt_80120 = . if validsample==0

gen mod_pdmt_80120 = 0

replace mod_pdmt_80120 = 1 if mod_80120_00 >= 0.5 & low_80120_00 < 0.4 & high_80120_00 < 0.4

replace mod_pdmt_80120 = . if validsample==0



gen mix_low_80120 = 0

replace mix_low_80120 = 1 if low_80120_00 >= 0.4 & mod_80120_00 < 0.35 & high_80120_00 < 0.35 & low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0

replace mix_low_80120 = . if validsample==0

gen mix_mod_80120 = 0

replace mix_mod_80120 = 1 if mod_80120_00 >= 0.4 & low_80120_00 < 0.35 & high_80120_00 < 0.35& low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0

replace mix_mod_80120 = . if validsample==0

gen mix_high_80120 = 0

replace mix_high_80120 = 1 if high_80120_00 >= 0.4 & low_80120_00 < 0.35 & mod_80120_00 < 0.35& low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0

replace mix_high_80120 = . if validsample==0



gen mix_l_m_80120 = 0

replace mix_l_m_80120 = 1 if low_80120_00 >= 0.35 & mod_80120_00 >= 0.35 & low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0 & mix_low_80120==0 & mix_mod_80120==0 & mix_high_80120==0

replace mix_l_m_80120 = . if validsample==0

gen mix_m_h_80120 = 0

replace mix_m_h_80120 = 1 if mod_80120_00 >= 0.35 & high_80120_00 >= 0.35 & low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0 & mix_low_80120==0 & mix_mod_80120==0 & mix_high_80120==0

replace mix_m_h_80120 = . if validsample==0

gen mix_l_h_80120 = 0

replace mix_l_h_80120 = 1 if low_80120_00 >= 0.35 & high_80120_00 >= 0.35 & low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0 & mix_low_80120==0 & mix_mod_80120==0 & mix_high_80120==0

replace mix_l_h_80120 = . if validsample==0



gen mix_uni_80120 = 0

replace mix_uni_80120 = 1 if low_pdmt_80120==0 & high_pdmt_80120==0 & mod_pdmt_80120==0 & mix_low_80120==0 & mix_mod_80120==0 & mix_high_80120==0 & mix_l_m_80120==0 & mix_m_h_80120==0 & mix_l_h_80120==0

replace mix_uni_80120 = . if validsample==0





gen inc_cat_80120 = 0

replace inc_cat_80120 = 1 if low_pdmt_80120==1

replace inc_cat_80120 = 2 if mix_low_80120==1

replace inc_cat_80120 = 3 if mix_l_m_80120==1

replace inc_cat_80120 = 4 if mix_l_h_80120==1

replace inc_cat_80120 = 5 if mix_uni_80120==1

replace inc_cat_80120 = 6 if mod_pdmt_80120==1

replace inc_cat_80120 = 7 if mix_mod_80120==1

replace inc_cat_80120 = 8 if mix_m_h_80120==1

replace inc_cat_80120 = 9 if mix_high_80120==1

replace inc_cat_80120 = 10 if high_pdmt_80120==1

replace inc_cat_80120 = . if validsample==0

drop prop_10000 prop_15000 prop_20000 prop_25000 prop_30000 prop_35000 prop_40000 prop_45000 prop_50000 prop_60000 prop_75000 prop_100000 prop_125000 prop_150000 prop_200000



**new methodology (on 80/120) where we use 55%+ to define predominantly low/predominantly mod/predominantly high; then if % is no greater than X, define category based on median hh income*

gen low_pdmt_55cut_80120_medhhinc = 0

replace low_pdmt_55cut_80120_medhhinc = 1 if low_80120_00 >= 0.55 & mod_80120_00 < 0.45 & high_80120_00 < 0.45

replace low_pdmt_55cut_80120_medhhinc = . if validsample==0

gen high_pdmt_55cut_80120_medhhinc = 0

replace high_pdmt_55cut_80120_medhhinc = 1 if high_80120_00 >= 0.55 & low_80120_00 < 0.45 & mod_80120_00 < 0.45

replace high_pdmt_55cut_80120_medhhinc = . if validsample==0

gen mod_pdmt_55cut_80120_medhhinc = 0

replace mod_pdmt_55cut_80120_medhhinc = 1 if mod_80120_00 >= 0.55 & low_80120_00 < 0.45 & high_80120_00 < 0.45

replace mod_pdmt_55cut_80120_medhhinc = . if validsample==0



gen mix_low_55cut_80120_medhhinc = 0

replace mix_low_55cut_80120_medhhinc = 1 if low_pdmt_55cut_80120==0 & high_pdmt_55cut_80120==0 & mod_pdmt_55cut_80120==0 & med_inc < reg_med_inc80_00

replace mix_low_55cut_80120_medhhinc = . if validsample==0



gen mix_mod_55cut_80120_medhhinc = 0

replace mix_mod_55cut_80120_medhhinc = 1 if low_pdmt_55cut_80120==0 & high_pdmt_55cut_80120==0 & mod_pdmt_55cut_80120==0 & med_inc >= reg_med_inc80_00 & med_inc < reg_med_inc120_00

replace mix_mod_55cut_80120_medhhinc = . if validsample==0



gen mix_high_55cut_80120_medhhinc = 0

replace mix_high_55cut_80120_medhhinc = 1 if low_pdmt_55cut_80120==0 & high_pdmt_55cut_80120==0 & mod_pdmt_55cut_80120==0 & med_inc >= reg_med_inc120_00

replace mix_high_55cut_80120_medhhinc = . if validsample==0


gen inc_cat_55cut_80120_medhhinc = 0

replace inc_cat_55cut_80120_medhhinc = 1 if low_pdmt_55cut_80120==1

replace inc_cat_55cut_80120_medhhinc = 2 if mix_low_55cut_80120_medhhinc==1

replace inc_cat_55cut_80120_medhhinc = 3 if mod_pdmt_55cut_80120_medhhinc==1

replace inc_cat_55cut_80120_medhhinc = 4 if mix_mod_55cut_80120_medhhinc==1

replace inc_cat_55cut_80120_medhhinc = 5 if mix_high_55cut_80120_medhhinc==1

replace inc_cat_55cut_80120_medhhinc = 6 if high_pdmt_55cut_80120_medhhinc==1

replace inc_cat_55cut_80120_medhhinc = . if validsample==0



save den_2000_neighb_inc_level_072019, replace


* process to merge with Denver_master_merge file so that typology can be run with new 20000 income level vars 
clear 
use den_2000_neighb_inc_level_072019
gen stcty = substr(FIPS,1,5)
keep if stcty=="08001" | stcty=="08005" | stcty=="08013" | stcty=="08014" | stcty=="08019" | stcty=="08031" | stcty=="08035" | stcty=="08047" | stcty=="08059" 
rename FIPS trtid10
keep trtid10 reg_med_inc120_00 reg_med_inc80_00 low_pdmt_80120 mod_pdmt_80120 high_pdmt_80120 low_pdmt_55cut_80120_medhhinc high_pdmt_55cut_80120_medhhinc mod_pdmt_55cut_80120_medhhinc mix_low_55cut_80120_medhhinc mix_mod_55cut_80120_medhhinc mix_high_55cut_80120_medhhinc inc_cat_55cut_80120_medhhinc 
save den_2000_neighb_inc_level_mastermod, replace 


*** rename 2000 vars to differentiate them from 2017
clear
use den_2000_neighb_inc_level_mastermod
rename low_pdmt_80120 low_pdmt_80120_00
rename high_pdmt_80120 high_pdmt_80120_00
rename mod_pdmt_80120 mod_pdmt_80120_00
rename inc_cat_55cut_80120_medhhinc inc_cat_55cut_80120_medhhinc_00
rename mix_mod_55cut_80120_medhhinc mix_mod_55cut_80120_medhhinc_00
rename mix_low_55cut_80120_medhhinc mix_low_55cut_80120_medhhinc_00
rename mod_pdmt_55cut_80120_medhhinc mod_pdmt_55cut_80120_medhhinc_00
rename mix_high_55cut_80120_medhhinc mix_high_55cut_80120_medhhinc_00
rename high_pdmt_55cut_80120_medhhinc high_pdmt_55cut_80120_00
rename low_pdmt_55cut_80120_medhhinc low_pdmt_55cut_80120_medhhinc_00
save den_2000_neighb_inc_level_mastermod, replace 



* merge cleaned 2000 neighborhood income data to the Atlanta master merge file for typology run
use Denver_merge_0805aff_approach
merge 1:1 trtid10 using den_2000_neighb_inc_level_mastermod
rename _merge _merge_inclevel_2000
save Denver_merge_081319,replace

*MATCHED = 677 
* NOT MATCHED = 155 <- these tracts zeroed out in from the crosswalk

************************************************************************************
*** Editing and cleaning ******
*CLEAN DENVER 
clear 
use Denver_merge_081319
drop hhwchild_17 per_hhwchild_17
rename high_dr20 high_denialrate20
rename high_dr25 high_denialrate25
rename high_dr30 high_denialrate30

rename per_owners_90 per_own_90
rename per_owners_00 per_own_00
rename per_owners_17 per_own_17

rename exclusive exclusive_tract 

* encode str variables as numeric (bytes/long) to address "type mismatch" error 
* in first typology run


*********
*******edit zillow/affordability data to assign numeric code 
*********
tab lmh_flag_new
gen lmh_flag_new_encoded = .
replace lmh_flag_new_encoded=1 if  lmh_flag_new=="predominantly LI"
replace lmh_flag_new_encoded=2 if  lmh_flag_new=="mixed_low"
replace lmh_flag_new_encoded=3 if  lmh_flag_new=="predominantly MI"
replace lmh_flag_new_encoded=4 if  lmh_flag_new=="mixed_mod"
replace lmh_flag_new_encoded=5 if  lmh_flag_new=="predominantly HI"
replace lmh_flag_new_encoded=6 if  lmh_flag_new=="mixed_high"

tab aff_change_cat_full
gen aff_change_cat_full_encoded=.
replace aff_change_cat_full_encoded=1 if aff_change_cat_full=="low_neg"	
replace aff_change_cat_full_encoded=2 if aff_change_cat_full=="low_marginal"
replace aff_change_cat_full_encoded=3 if aff_change_cat_full=="low_increase"
replace aff_change_cat_full_encoded=4 if aff_change_cat_full=="low_rapid_increase"
replace aff_change_cat_full_encoded=5 if aff_change_cat_full=="mixed_low_neg"	
replace aff_change_cat_full_encoded=6 if aff_change_cat_full=="mixed_low_marginal"
replace aff_change_cat_full_encoded=7 if aff_change_cat_full=="mixed_low_increase"
replace aff_change_cat_full_encoded=8 if aff_change_cat_full=="mixed_low_rapid_increase"		
replace aff_change_cat_full_encoded=9 if aff_change_cat_full=="mod_neg"	
replace aff_change_cat_full_encoded=10 if aff_change_cat_full=="mod_marginal"
replace aff_change_cat_full_encoded=11 if aff_change_cat_full=="mod_increase"
replace aff_change_cat_full_encoded=12 if aff_change_cat_full=="mod_rapid_increase"
replace aff_change_cat_full_encoded=13 if aff_change_cat_full=="mixed_mod_neg"	
replace aff_change_cat_full_encoded=14 if aff_change_cat_full=="mixed_mod_marginal"
replace aff_change_cat_full_encoded=15 if aff_change_cat_full=="mixed_mod_increase"
replace aff_change_cat_full_encoded=16 if aff_change_cat_full=="mixed_mod_rapid_increase"			
replace aff_change_cat_full_encoded=17 if aff_change_cat_full=="high_neg"	
replace aff_change_cat_full_encoded=18 if aff_change_cat_full=="high_marginal"
replace aff_change_cat_full_encoded=19 if aff_change_cat_full=="high_increase"
replace aff_change_cat_full_encoded=20 if aff_change_cat_full=="high_rapid_increase"
replace aff_change_cat_full_encoded=21 if aff_change_cat_full=="mixed_high_neg"	
replace aff_change_cat_full_encoded=22 if aff_change_cat_full=="mixed_high_marginal"
replace aff_change_cat_full_encoded=23 if aff_change_cat_full=="mixed_high_increase"
replace aff_change_cat_full_encoded=24 if aff_change_cat_full=="mixed_high_rapid_increase"
tab aff_change_cat_full_encoded, m


drop if _merge17==.
	* 155 dropped vars. Dropping observations (census tracts) for which there is no 
	* data across any of the variables. These census tracts are remnants after crosswalking
	
save clean_Denver_merge_081319, replace

* NOTES ON EDITS 
	* missing  rm_per_units_pre50_17 , aboverm_per_units_pre50_17
	* has per_rent for all years and std error for 2017
	* has per_limove 09 & 17, NOT per_limove_10 
	*real_mhval_10 in all regions?? 


