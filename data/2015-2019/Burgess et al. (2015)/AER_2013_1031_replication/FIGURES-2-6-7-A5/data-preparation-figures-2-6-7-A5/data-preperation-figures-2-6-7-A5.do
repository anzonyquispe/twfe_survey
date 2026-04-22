* define the location of the main folder on your computer
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\FIGURES\FIGURES-2-6-7-A5\Data-Preparation-Figures-2-6-7-A5"


*** THIS DO FILE BRINGS TOGETHER ALL THE INDIVIDUAL DATASETS TO CONSTRUCT MAIN FIGURES 2, 6, 7 AND APPENDIX FIGURE A5 ***

***1. POPULATION DATA FOR EACH COUNTRY c IN EACH YEAR t ***
* SOURCE DATA: "wdi_pop_all.csv"
* SOURCE OF DATA: World Bank World Development Indicators 2013
* LOCATION OF DATA: http://data.worldbank.org/data-catalog/world-development-indicators
clear
insheet using "$mypath\wdi_pop_all.csv"
ren countryname country
drop if country == ""
keep country y*
reshape long y, i(country) j(year)
ren y pop
sort country year
save pop_all, replace

***2. LIST OF COUNTRIES IN SUB-SAHARAN AFRICA OBTAINED FROM WORLD BANK AFRICA REGION PAGE ***
*** LOCATION OF DATA: http://www.worldbank.org/en/region/afr ***
use "$mypath\list_countries_africa", clear
sort country
save "$mypath\list_countries_africa", replace

***3. POLITY IV DATA FOR EACH COUNTRY c IN EACH YEAR t ***
* SOURCE DATA: "p4v2011_all.csv"
* SOURCE OF DATA: Polity IV (2013). Polity IV Project, Political Regime Characteristics and Transitions, 1800-2013. Vienna, VA: Center for Systemic Peace.  
* LOCATION OF DATA: http://www.systemicpeace.org/inscrdata.html
clear
insheet using "$mypath\p4v2011_all.csv"


***4.  To merge with population data from WDU - rename country names *
keep if year >= 1960
replace country = "Cote d'Ivoire" if country == "Ivory Coast"
replace country = "Gambia, The" if country == "Gambia"
replace country = "Congo, Rep." if country == "Congo Brazzaville"
replace country = "Congo, Dem. Rep." if country == "Congo Kinshasa"
replace country = "Korea, Dem. Rep." if country == "Korea North"
replace country = "Korea, Rep." if country == "Korea South"
replace country = "Iran, Islamic Rep." if country == "Iran"
replace country = "Syrian Arab Republic" if country == "Syria"
replace country = "Myanmar" if country == "Myanmar (Burma)"
replace country = "Lao PDR" if country == "Laos"
replace country = "Dominican Republic" if country == "Dominican Rep"
replace country = "Timor-Leste" if country == "East Timor"
replace country = "Venezuela, RB" if country == "Venezuela"
replace country = "United Arab Emirates" if country == "UAE"
replace country = "Trinidad and Tobago" if country == "Trinidad"
replace country = "Egypt, Arab Rep." if country == "Egypt"
replace country = "Germany" if country == "Germany East" | country == "Germany West"
replace country = "Yemen, Rep." if country == "Yemen" | country == "Yemen North" | country == "Yemen South"
replace country = "Vietnam" if country == "Vietnam South" | country == "Vietnam North"
replace country = "Kyrgyz Republic" if country == "Kyrgyzstan"
replace country = "Russian Federation" if country == "Russia"
sort country year
merge country year using pop_all
tab _m
drop if _m == 2

* NOTE: Several country-year observations of the population data set (obtained from the World Bank ) that we do not have in the polity IV data set either because the country/region is missing for the whole period, or for a few years **
drop _m
sort country year

*** 5. We create our measure of democracy: Democracy [c,t], 
** Defined as an indicator variable equal to one if country c is not an autocracy (combined polity score superior or equal to -5) in decade t
gen democracy = (polity2 >= -5) if polity2 != .
sort country 
merge country using "$mypath\list_countries_africa"
tab _m 
gen ssa = 0
replace ssa = 1 if _m == 3
drop _m

save "$mypath\polityIV_all", replace

*** 6. GDP PER CAPITA DATA FOR EACH COUNTRY c IN EACH YEAR t ***
* SOURCE DATA: imports the raw data from "gdppc.csv"
* SOURCE OF DATA: World Bank World Development Indicators 2013
* LOCATION OF DATA: http://data.worldbank.org/data-catalog/world-development-indicators
* We use the World Bank's online interface to obtain per capita GDP (PPP, constant 2005 US$) for Kenya and the rest of Sub-Saharan Africa 

clear
insheet using "$mypath\gdppc.csv"
sort year
save "$mypath\gdppc", replace

*** ETHNIC FAVORITISM, THETA ***
*** 7. Imports theta, our estimate of ethnic favoritism, from "theta.csv" 
*** SOURCE: AUTHOR'S CALCULATIONS
clear
insheet using "$mypath\theta.csv"
sort year
save "$mypath\theta", replace

**************************************************************************************************************

*** CREATION OF "COMBINED POLITY SCORE" FOR "KENYA" AND "SUB-SAHARAN AFRICA" (POPULATION-WEIGHTED AVERAGE) ***

use "$mypath\polityIV_all", clear
gen indexpop = polity2*pop
keep if ssa == 1
drop if country == "Kenya"
* we consider the rest of Sub-Saharan Africa for Figure 2
collapse (sum) indexpop pop (count) numobs = indexpop, by(year)
gen polity_ssa = indexpop/pop
keep year  polity_ssa
sort year
** This creates a Sub-Saharan Africa dataset (and excludes Kenya)
save "$mypath\polity_ssa", replace

use "$mypath\polityIV_all", clear
keep if country == "Kenya"
gen polity_kenya = polity2
keep year polity_kenya
sort year
save "$mypath\polity_kenya", replace

*** CREATION OF "GDP PER CAPITA GROWTH" FOR "KENYA" AND "SUB-SAHARAN AFRICA" (POPULATION-WEIGHTED AVERAGE) ***

* SOURCE DATA: imports the raw data from gdp.csv  
* SOURCE OF DATA: World Bank World Development Indicators 2013
* LOCATION OF DATA: http://data.worldbank.org/data-catalog/world-development-indicators
* We use the World Bank's online interface to obtain per capita GDP () for Kenya and the rest of Sub-Saharan Africa 

use "$mypath\gdppc", clear
gen growth_kenya = (gdppc00_kenya - gdppc00_kenya[_n-1])/gdppc00_kenya[_n-1]*100
gen growth_ssa = (gdppc00_ssa - gdppc00_ssa[_n-1])/gdppc00_ssa[_n-1]*100
gen gr_ssa_5yma = (growth_ssa[_n-2] + growth_ssa[_n-1] + growth_ssa + growth_ssa[_n+1] + growth_ssa[_n+2])/5
gen gr_kenya_5yma = (growth_kenya[_n-2] + growth_kenya[_n-1] + growth_kenya + growth_kenya[_n+1] + growth_kenya[_n+2])/5
keep year gr*5yma
sort year 
save "$mypath\gdpgrowth_kenya_ssa", replace

*** CREATION OF "SHARE OF DEMOCRACIES" (POPULATION-WEIGHTED AVERAGES) FOR "SUB-SAHARAN AFRICA" AND "WORLD" ***
use "$mypath\polityIV_all", clear
gen indexpop = democracy*pop
collapse (sum) indexpop pop (count) numobs = indexpop, by(year)
gen democ_world = indexpop/pop
keep year democ_world
sort year
save "$mypath\democ_world", replace

use "$mypath\polityIV_all", clear
gen indexpop = democracy*pop
keep if ssa == 1
collapse (sum) indexpop pop (count) numobs = indexpop, by(year)
gen democ_ssa = indexpop/pop
keep year democ_ssa
sort year
save "$mypath\democ_ssa", replace

**************************************************************************************
*** THE INDIVIDUAL DATASETS ARE NOW READY TO BE MERGED ***
**************************************************************************************

use "$mypath\democ_world", clear
sort year 
merge year using "$mypath\democ_ssa"
tab _m
drop _m
sort year 
merge year using "$mypath\polity_ssa"
tab _m
drop _m
sort year 
merge year using "$mypath\polity_kenya"
tab _m
drop _m
sort year 
merge year using "$mypath\gdpgrowth_kenya_ssa"
tab _m
drop _m
sort year 
merge year using "$mypath\theta"
tab _m
drop _m
label var year "Year"
label var democ_world "Share of democracies in the world (%, pop.-weighted average)"
label var democ_ssa "Share of democracies in Sub-Saharan Africa (%, pop.-weighted average)"
label var polity_kenya "Combined polity score in Kenya"
label var polity_ssa "Combined polity score in rest of Sub-Saharan Africa (pop.-weighted average)"
label var gr_kenya "Real GDP per capita growth in Kenya (%, 5-yr moving av.)"
label var gr_ssa "Real GDP per capita growth in rest of Sub-Saharan Africa (%, 5-yr moving av.)"
label var theta "Theta, our estimate of ethnic favoritism"
order year polity* gr* theta democ* 
save "$mypath\figures-2-6-7-A5", replace

****************************************************************************
*** TO CREATE FIGURES 2, 6, 7 AND A5 PLEASE REFER TO FIGURES-2-6-7-A5.DO ***
****************************************************************************
