* Define the location of the main folder on your computer *
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\main-tables-figures\kenya_regressions\data-preparation-main-tables-figures\"

* This dofile creates the three data sets we use to run the main regressions for Kenya *
* - One data set ("kenya_roads_exp.dta") with road development expenditure as the dependent variable
* - One data set ("kenya_roads_pav.dta") with paved road construction as the dependent variable
* - One data set ("kenya_roads_cabinet.dta") with the cabinet share as the dependent variable

*********************************************************************************
* 1st DATA SET, WITH ROAD DEVELOPMENT EXPENDITURE AS THE DEPENDENT VARIABLE *****
*********************************************************************************

*** Main structure of the panel data set: 41 districts x 49 years (1963-2011) = 2009 observations ***
clear
import excel "$mypath\observations.xls", sheet("Sheet1") firstrow
label var province "Province"
* There are 8 provinces
label var distname_1979 "District name in 1979 (41 districts)"
* We use the 41 districts at independence, with their name in 1979 
label var distnum "District number"
label var year "Year"
* There are 49 years 
label var yearnum "Year number"
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Road development expenditure ***

clear
import excel "$mypath\road_development_expenditure.xls", sheet("Sheet1") firstrow
sort distname_1979 year
save "$mypath\road_development_expenditure", replace

use "$mypath\kenya_roads", clear
sort distname_1979 year
merge distname_1979 year using "$mypath\road_development_expenditure"
tab _m
drop _m
label var droadexp_tot "Development road expenditure (2000 USD) in year t"
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Ethnic shares ***
clear
import excel "$mypath\ethnic_shares.xls", sheet("Sheet1") firstrow
sort distname_1979 
save "$mypath\ethnic_shares", replace

use "$mypath\kenya_roads", clear
sort distname_1979
merge distname_1979 using "$mypath\ethnic_shares"
tab _m
drop _m
foreach X in kikuyu embu meru kamba luhya kisii coast luo kalenjin maasai turkana_samburu somali other {
label var `X'_share62 "Population share of `X's in 1962" 
}
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Controls: Demography ***
clear
import excel "$mypath\controls_demography.xls", sheet("Sheet1") firstrow
sort distname_1979
save "$mypath\controls_demography", replace

use "$mypath\kenya_roads", clear
sort distname_1979
merge distname_1979 using "$mypath\controls_demography"
tab _m
drop _m
label var pop1962 "Population in 1962"
label var area "Area in sq.km."
label var urbrate1962 "Urbanization rate in 1962 (towns > 2000 inh.)"
gen pop1962_t = pop1962*year
gen area_t = area*year
gen urbrate1962_t = urbrate1962*year
label var pop1962_t "Population in 1962 x trend"
label var area_t "Area in sq.km. x trend"
label var urbrate1962_t "Urbanization rate in 1962 (towns > 2000 inh.) x trend"
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Controls: Economic Activity ***

clear
import excel "$mypath\controls_economic_activity.xls", sheet("Sheet1") firstrow
sort distname_1979
save "$mypath\controls_economic_activity", replace

use "$mypath\kenya_roads", clear
sort distname_1979
merge distname_1979 using "$mypath\controls_economic_activity"
tab _m
drop _m
replace earnings = earnings / 1000000
* earnings in millions
replace wage_employment = wage_employment/1000
* wage employment in thousands
replace value_cashcrops = value_cashcrops / 1000000
* value of cash crop production in millions
label var earnings "Earnings (million 2000 USD) from wage employment in 1966"
label var wage_employment "Wage employment (thousands) in 1963"
label var value_cashcrops "Value of cash crop production (million 2000 USD) in 1965"
label var five_richest "District is among five richest districts in 1962"
* cash crops = coffee, tea and sisal
gen earnings_t = earnings*year
gen wage_employment_t = wage_employment*year
gen value_cashcrops_t = value_cashcrops*year
label var earnings_t "Earnings (million 2000 USD) from wage employment in 1966 x trend"
label var wage_employment_t "Wage employment (thousands) in 1963"
label var value_cashcrops_t "Value of cash crop production (million 2000 USD) in 1965 x trend"
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Controls: Economic Geography ***

clear
import excel "$mypath\controls_economic_geography.xls", sheet("Sheet1") firstrow
sort distname_1979
save "$mypath\controls_economic_geography", replace

use "$mypath\kenya_roads", clear
sort distname_1979
merge distname_1979 using "$mypath\controls_economic_geography"
tab _m
drop _m
label var border "District bordering Uganda or Tanzania"
label var MomKam "District on the Mombasa-Kampala road"
label var dist2nairobi "Distance in km to Nairobi"
label var NaiKam "District on the Nairobi-Kampala highway"
label var highlands "More than 50% of district area is in the former White Highlands"
label var nairobidist "Nairobi district or district adjacent to Nairobi district"
label var centroidx "Longitude of the centroid of the district"
label var centroidy "Latitude of the centroid of the district"
gen border_t = border*year
gen MomKam_t = MomKam*year
gen dist2nairobi_t = dist2nairobi*year
label var border_t "District bordering Uganda or Tanzania x trend"
label var MomKam_t "District on the Mombasa-Kampala road x trend"
label var dist2nairobi_t "Distance in km to Nairobi x trend"
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Elections 1992 ***

clear
import excel "$mypath\elections1992.xls", sheet("Sheet1") firstrow
sort distname_1979
save "$mypath\elections1992", replace

use "$mypath\kenya_roads", clear
sort distname_1979
merge distname_1979 using "$mypath\elections1992"
tab _m
drop _m
label var margin_victory "Margin of victory between the winner and the runner-up party (%) in 1992 elections [d,1992]"
label var votes_hh_index "Herfindahl Index of the voting shares of all parties in 1992 elections [d,1992]"
* increase in hhindex = concentration = less competition
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Number of road articles in the Daily Nation and The Standard Newspapers ***

clear
import excel "$mypath\nation_standard.xls", sheet("stata") firstrow
sort year
save "$mypath\nation_standard", replace

use "$mypath\kenya_roads", clear
sort year
merge year using "$mypath\nation_standard"
tab _m
drop _m
label var nation "Number of Road Articles in The Daily Nation, 1985-2010"
label var standard "Number of Road Articles in The Standard, 1985-2010"
sort distname_1979 year
save "$mypath\kenya_roads", replace

*** Counterfactuals ***

* counterfactual (expenditure 1964-2002) for paved road construction, based on population

* We use "bilateral_connections_six_counterfactuals.xls" to obtain the ranking of the 1155 bilateral connections based on population
clear
import excel "$mypath\counterfactual_reallocation_exp_pop.xls", sheet ("Feuil1") firstrow
collapse (sum) length_km, by(distname_1979 year)
drop if distname_1979 == ""
drop if year == .
sort distname_1979 year
gen change_paved_exp_pop_6402 = length_km
gen droadexp_tot2 = length_km/5286*100
replace droadexp_tot2= 2870267451.105/100*length_km
drop length
sort distname_1979 year
save "$mypath\counterfactual_exp_pop_raw", replace

use "$mypath\kenya_roads_exp", clear
keep if year >= 1964 & year <= 2002
keep distname_1979 year pop1962
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_exp_pop_raw"
tab _m
drop _m
replace droad = 0 if droad == .
sort distname_1979 year
bysort year: egen droadexp_country = sum(droadexp_tot)
gen roadexp_share = droadexp_tot / droadexp_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen exp_dens_share = roadexp_share / pop1962_share
ren exp_dens_share exp_dens_share_pop_6402
keep distname_1979 year exp_dens_share_pop_6402 change_paved_exp_pop_6402
sort distname_1979 year
save "$mypath\counterfactual_exp_pop", replace

* counterfactual (expenditure 1964-2002) for paved road construction, based on distance

* We use "bilateral_connections_six_counterfactuals.xls" to obtain the ranking of the 1155 bilateral connections based on distance
clear
import excel "$mypath\counterfactual_reallocation_exp_dist.xls", sheet ("Feuil1") firstrow
collapse (sum) length_km, by(distname_1979 year)
drop if distname_1979 == ""
drop if year == .
sort distname_1979 year
gen change_paved_exp_dist_6402 = length_km
gen droadexp_tot2 = length_km/5286*100
replace length_km = 2870267451.105/100*length_km
drop length
sort distname_1979 year
save "$mypath\counterfactual_exp_dist_raw", replace

use "$mypath\kenya_roads_exp", clear
keep if year >= 1964 & year <= 2002
keep distname_1979 year pop1962
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_exp_dist_raw" 
tab _m
drop _m
replace droad = 0 if droad == .
sort distname_1979 year
bysort year: egen droadexp_country = sum(droadexp_tot)
gen roadexp_share = droadexp_tot / droadexp_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen exp_dens_share = roadexp_share / pop1962_share
ren exp_dens_share exp_dens_share_dist_6402
keep distname_1979 year exp_dens_share_dist change_paved_exp_dist_6402
sort distname_1979 year
save "$mypath\counterfactual_exp_distance", replace

* counterfactual (expenditure 1964-2002) for paved road construction, based on population and distance

* We use "bilateral_connections_six_counterfactuals.xls" to obtain the ranking of the 1155 bilateral connections based on population and distance
clear
import excel "$mypath\counterfactual_reallocation_exp_mp.xls", sheet ("Feuil1") firstrow
collapse (sum) length_km, by(distname_1979 year)
drop if distname_1979 == ""
drop if year == .
sort distname_1979 year
gen change_paved_exp_mp_6402 = length_km
gen droadexp_tot2 = length_km/5286*100
replace length_km = 2870267451.105/100*length_km
drop length
sort distname_1979 year
save "$mypath\counterfactual_exp_mp_raw", replace

use "$mypath\kenya_roads_exp", clear
keep if year >= 1964 & year <= 2002
keep distname_1979 year pop1962
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_exp_mp_raw" 
tab _m
drop _m
replace droad = 0 if droad == .
sort distname_1979 year
bysort year: egen droadexp_country = sum(droadexp_tot)
gen roadexp_share = droadexp_tot / droadexp_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen exp_dens_share = roadexp_share / pop1962_share
ren exp_dens_share exp_dens_share_mp_6402
keep distname_1979 year exp_dens_share_mp_6402 change_paved_exp_mp_6402
sort distname_1979 year
save "$mypath\counterfactual_exp_pop_distance", replace

*************************************************************************************

*** Creation of dependent variables ***

use "$mypath\kenya_roads", clear

* main dependent variable (expenditure): Share of road development expenditure [d,t] / population share [d,1962]

bysort year: egen droadexp_country = sum(droadexp_tot)
label var droadexp_country "Development road expenditure (2000 USD) for the country in year t"
gen roadexp_share = droadexp_tot / droadexp_country*100
label var roadexp_share "Share of road development expenditure in district d in year t"
bysort year: egen pop1962_country = sum(pop1962)
label var pop1962_country "Population of the country in 1962"
gen pop1962_share = pop1962/pop1962_country*100
label var pop1962_share "Population share of district d in 1962"
gen exp_dens_share = roadexp_share / pop1962_share
label var exp_dens_share "Share of road development expenditure [d,t] / population share [d,1962]"

* other dependent variable (expenditure): Share of road development expenditure [d,t] / area share [d]

bysort year: egen area_country = sum(area)
label var area_country "Area in sq.km. of the country"
gen area_share = area/area_country*100
label var area_share "Area share of district d"
gen exp_dens_share2 = roadexp_share / area_share
label var exp_dens_share2 "Share of road development expenditure [d,t] / area share [d]"

save "$mypath\kenya_roads", replace

*** Creation of main variable of interest ***

use "$mypath\kenya_roads", clear

* Democracy [t]

gen multiparty = 0
replace multiparty = 1 if (year >= 1963 & year <= 1969) | (year >= 1993)
label var multiparty "Democracy dummy [d,t]"

* Coethnic district [d,t]

gen president = 0
replace president = 1 if kikuyu_share62 >= 0.5 & ((year >= 1963 & year <= 1978) | year >= 2003)
replace president = 1 if kalenjin_share62 >= 0.5 & year >= 1979 & year <= 2002
label var president "Coethnic district dummy [d,t]"

* Coethnic district [d,t] x Democracy [t]

gen presidentMP = (president == 1 & multiparty == 1)
label var presidentMP "Coethnic district dummy [d,t] x Democracy dummy [t]"

* Coethnic share [d,t]

gen presshare = 0
replace presshare = kikuyu_share62 if kikuyu_share62 >= 0.5 & ((year >= 1963 & year <= 1978) | year >= 2003)
replace presshare = kalenjin_share62 if kalenjin_share62 >= 0.5 & year >= 1979 & year <= 2002
label var presshare "Coethnic share [d,t]"

* Coethnic share [d,t] x Democracy [t]

gen presshareMP = presshare*multiparty
label var presshareMP "Coethnic share [d,t] x Democracy dummy [t]"

* Number of years coethnic district

gen president_yrs = 0
replace president_yrs = year - 1963 if year <= 1978 & kikuyu_share62 >= 0.5
replace president_yrs = year - 1979 if year >= 1979 & year <= 2002 & kalenjin_share62 >= 0.5
replace president_yrs = year + 15 - 2003 if year >= 2003 & kikuyu_share62 >= 0.5
label var president_yrs "Number of years coethnic distrit [d,t]"

* VP-Coethnic district [d,t]

gen vp = 0
replace vp = 1 if luo_share62 >= 0.50 & year >= 1964 & year <=1966
replace vp = 1 if maasai_share62 >= 0.50 & year >= 1967 & year <= 1967
replace vp = 1 if kalenjin_share62 >= 0.50 & year >= 1968 & year <= 1978
replace vp = 1 if kikuyu_share62 >= 0.50 & year >= 1979 & year <= 1988
replace vp = 1 if kikuyu_share62 >= 0.50 & year >= 1989 & year <= 1992
replace vp = 1 if (kikuyu_share62+maasai_share62) >= 0.50 & year >= 1993 & year <= 2002
replace vp = 1 if luhya_share62 >= 0.50 & year >= 2003 & year <= 2005
replace vp = 1 if luhya_share62 >= 0.50 & year >= 2006 & year <= 2008
replace vp = 1 if luo_share62 >= 0.50 & year >= 2009 & year <= 2011
replace vp = 1 if kamba_share62 >= 0.50 & year >= 2009 & year <= 2011
label var vp "VP-Coethnic district dummy [d,t]"

* VP-Coethnic district [d,t] x Democracy [t]

gen vpMP = (vp == 1 & multiparty == 1)
label var vpMP "VP-Coethnic district dummy [d,t] x Democracy dummy [t]"

* Kikuyu district [d,1962]

gen kikuyu = (kikuyu_share62 >= 0.5)
label var kikuyu "Kikuyu district dummy [d,1962]"

* Kalenjin district [d,1962]

gen kalenjin = (kalenjin_share62 >= 0.5)
label var kalenjin "Kalenjin district dummy [d,1962]"

* Kamba district [d,1962]

gen kamba = (kamba_share62 >= 0.5)
label var kamba "Kamba district dummy [d,1962]"

* Kamba district [d,1962] x Democracy [t]

gen kambaMP = (kamba == 1 & multiparty == 1)
label var kambaMP "Kamba district dummy [d,1962] x Democracy [t]"

* Luhya district [d,1962]

gen luhya = (luhya_share62 >= 0.5)
label var luhya "Luhya district dummy [d,1962]"

* Luhya district [d,1962] x Democracy [t]

gen luhyaMP = (luhya == 1 & multiparty == 1)
label var luhyaMP "Luhya district dummy [d,1962] x Democracy [t]"

* Luo district [d,1962]

gen luo = (luo_share62 >= 0.5)
label var luo "Luo district dummy [d,1962]"

* Luo district [d,1962] x Democracy [t]

gen luoMP = (luo == 1 & multiparty == 1)
label var luoMP "Luo district dummy [d,1962] x Democracy [t]"

* Kamba-Luhya-Luo district [d,1962] 

gen kll = (kamba_share62 >= 0.50 | luhya_share62 >= 0.50 | luo_share62 >= 0.50)
label var kll "Kamba, Luhya or Luo district [d,1962]"

* Kamba-Luhya-Luo district [d,1962] x Democracy [t] 

gen kllMP = (kll == 1 & multiparty == 1)
label var kllMP "Kamba, Luhya or Luo district [d,1962] x Democracy dummy [t]"

* Non-Coethnic majority < 80% [d,1962] 

egen maj_share62 = rmax(kikuyu_share62-somali_share62)
gen swing = (maj_share62 < 0.80)
drop maj_share62 
label var swing "Non-Coethnic majority < 80% [d,1962]"

* Non-Coethnic majority < 80% [d,1962] x Democracy [t] 

gen swingMP = (swing == 1 & multiparty == 1)
replace swingMP = 0 if presidentMP == 1
* only swing group if not presidential already
label var swingMP "Non-Coethnic majority < 80% [d,1962] x Democracy dummy [t]"

* Margin of Victory [d,1992] x Democracy [t]

gen margin_victoryMP = margin_victory*multiparty
label var margin_victoryMP "Margin of victory between the winner and the runner-up party (%) in 1992 elections [d,1992] x Democracy [t]"

* Party Competition Herfindahl Index [d,1992] x Democracy [t]

gen votes_hh_indexMP = votes_hh_index*multiparty
label var votes_hh_indexMP "Herfindahl Index of the voting shares of all parties in 1992 elections [d,1992] x Democracy [t]"

order province distname* distnum year* exp_dens_share droadexp* roadexp* pop1962_* exp_dens_share2 area_* multiparty president* presshare* president_yrs vp* kikuyu* kalenjin* kamba luhya luo kll swing margin_victory votes_hh_index kambaMP luhyaMP luoMP kllMP swingMP margin_victoryMP votes_hh_indexMP *share62 pop1962 area urbrate1962 earnings wage_employment value_cashcrops MomKam border dist2nairobi nairobidist NaiKam highlands five_richest centroidx centroidy pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t MomKam_t border_t dist2nairobi_t

* Counterfactuals 

sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_exp_pop"
tab _m
drop _m
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_exp_distance"
tab _m
drop _m
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_exp_pop_distance"
tab _m
drop _m

label var exp_dens_share_pop_6402 "Share of road dvt. expenditure(pop.counterfactual)[d,t]/Pop.share[d,1962]"
label var exp_dens_share_dist_6402 "Share of road dvt. expenditure(dist.counterfactual)[d,t]/Pop.share[d,1962]"
label var exp_dens_share_mp_6402 "Share of road dvt. expenditure(pop.dist.counterfactual)[d,t]/Pop.share[d,1962]"

label var change_paved_exp_pop_6402 "Paved road construction (pop.counterfactual)[d,t]"
label var change_paved_exp_dist_6402 "Paved road construction (dist.counterfactual)[d,t]"
label var change_paved_exp_mp_6402 "Paved road construction (pop.dist.counterfactual)[d,t]"

save "$mypath\kenya_roads_exp", replace
* creates "kenya_roads_exp", the data set with road development expenditure as the dependent variable
* the data set is saved in the main folder


*********************************************************************************
* 2nd DATA SET, WITH PAVED ROAD CONSTRUCTION AS THE DEPENDENT VARIABLE *
*********************************************************************************


clear
import excel "$mypath\paved_road_construction.xls", sheet("Sheet1") firstrow
* since our maim dependent variable is the change in the stock of the paved road constructed, the year 1964 is not necessary, we drop it *
drop if year < 1967 
sort distname_1979 year
save "$mypath\paved_road_construction", replace

use "$mypath\kenya_roads_exp", clear
sort distname_1979 
keep province distname_1979 distnum pop1962 pop1962_share area area_share urbrate1962 earnings wage_employment value_cashcrops dist2nairobi border MomKam *share62
bysort distname: keep if _n == 1
sort distname
save "$mypath\controls", replace

* counterfactual for paved road construction, based on population

* We use "bilateral_connections_six_counterfactuals.xls" to obtain the ranking of the 1155 bilateral connections based on population
clear
import excel "$mypath\counterfactual_reallocation_pav_pop.xls", sheet ("Sheet1") firstrow
collapse (sum) length_km, by(distname_1979 year)
drop if distname_1979 == ""
drop if year == .
sort distname_1979 year
*collapse (sum) length_km
*perfect, 5286 km
save "$mypath\counterfactual_pav_pop_raw", replace

use "$mypath\kenya_roads_pav", clear
keep distname_1979 year pop1962
sort distname_1979 year 
merge distname_1979 year using "$mypath\counterfactual_pav_pop_raw"
drop if _m == 2
tab _m
drop _m
replace length_km = 0 if length_km == .
sort distname_1979 year
gen change_paved = length_km
bysort year: egen change_paved_country = sum(change_paved)
gen chpaved_share = change_paved / change_paved_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen change_paved_share = chpaved_share / pop1962_share
keep distname_1979 year change_paved_share length_km
ren change_paved_sh change_paved_sh_pop
ren length_km change_paved_pop
keep distname_1979 year change_paved_sh_pop change_paved_pop
sort distname_1979 year
save "$mypath\counterfactual_pop", replace

* counterfactual for paved road construction, based on distance

* We use "bilateral_connections_six_counterfactuals.xls" to obtain the ranking of the 1155 bilateral connections based on distance
clear
import excel "$mypath\counterfactual_reallocation_pav_dist.xls", sheet ("Feuil1") firstrow
collapse (sum) length_km, by(distname_1979 year)
sort distname_1979 year
*collapse (sum) length_km
*perfect, 5286
ren length_km changed_paved_dist
save "$mypath\counterfactual_pav_dist_raw", replace

use "$mypath\kenya_roads_pav", clear
keep distname_1979 year pop1962
sort distname_1979 year 
merge distname_1979 year using "$mypath\counterfactual_dist_raw"
drop if _m == 2
tab _m
drop _m
replace length_km = 0 if length_km == .
sort distname_1979 year
gen change_paved = length_km
bysort year: egen change_paved_country = sum(change_paved)
gen chpaved_share = change_paved / change_paved_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen change_paved_share = chpaved_share / pop1962_share
keep distname_1979 year change_paved_share length_km
ren change_paved_sh change_paved_sh_dist
ren length_km change_paved_dist
keep distname_1979 year change_paved_sh_dist change_paved_dist
sort distname_1979 year
save "$mypath\counterfactual_distance", replace

* counterfactual for paved road construction, based on population and distance 

* We use "bilateral_connections_six_counterfactuals.xls" to obtain the ranking of the 1155 bilateral connections based on population and distance
clear
import excel "$mypath\counterfactual_reallocation_pav_mp.xls", sheet ("Feuil1") firstrow
collapse (sum) length_km, by(distname_1979 year)
sort distname_1979 year
*collapse (sum) length_km
*perfect, 5286
ren length_km changed_paved_mp
save "$mypath\counterfactual_pav_mp_raw", replace

use "$mypath\kenya_roads_pav", clear
keep distname_1979 year pop1962
sort distname_1979 year 
merge distname_1979 year using "$mypath\counterfactual_mp_raw"
drop if _m == 2
tab _m
drop _m
replace length_km = 0 if length_km == .
sort distname_1979 year
gen change_paved = length_km
bysort year: egen change_paved_country = sum(change_paved)
gen chpaved_share = change_paved / change_paved_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen change_paved_share = chpaved_share / pop1962_share
keep distname_1979 year change_paved_share length_km
ren change_paved_sh change_paved_sh_mp
ren length_km change_paved_mp
keep distname_1979 year change_paved_sh_mp change_paved_mp
sort distname_1979 year
save "$mypath\counterfactual_pop_distance", replace

* creation of dependent variables and varianles of interest

use "$mypath\paved_road_construction", clear
sort distname_1979
merge distname_1979 using "$mypath\controls"
tab _m
drop _m

* dependent variable: Share of paved road construction [d,t] / Population share [d,1962]

bysort year: egen change_paved_country = sum(change_paved)
label var change_paved_country "Paved road construction for the country as whole in year t"
gen chpaved_share = change_paved / change_paved_country*100
label var chpaved_share "Share of paved road construction [d,t]"
gen change_paved_share = chpaved_share / pop1962_share
label var change_paved_share "Share of paved road construction [d,t] / Population share [d,1962]"

* other dependent variable: Share of paved road construction [d,t] / Area share [d]

gen change_paved_share2 = chpaved_share / area_share
label var change_paved_share2 "Share of paved road construction [d,t] / Area share [d]"

* Democracy [t]

gen multiparty = 0
replace multiparty = 1 if (year >= 1963 & year <= 1969) | (year >= 1993)
label var multiparty "Democracy [t]"

* Coethnic district dummy [d,t]

gen president = 0
replace president = 1 if kikuyu_share62 >= 0.5 & year >= 1963 & year <= 1979
replace president = 1 if kalenjin_share62 >= 0.5 & year >= 1981 & year <= 2002
label var president "Coethnic district dummy [d,t]"

* Coethnic district dummy [d,t] x Democracy [t]
 
gen presidentMP = (president == 1 & multiparty == 1)
label var presidentMP "Coethnic district dummy [d,t] x Democracy [t]"

* Coethnic share [d,t]

gen presshare = 0
replace presshare = kikuyu_share62 if kikuyu_share62 >= 0.5 & ((year >= 1963 & year <= 1978) | year >= 2003)
replace presshare = kalenjin_share62 if kalenjin_share62 >= 0.5 & year >= 1979 & year <= 2002
label var presshare "Coethnic share [d,t]"

* Coethnic share [d,t] x Democracy [t]

gen presshareMP = presshare*multiparty
label var presshareMP "Coethnic share [d,t] x x Democracy [t]"

* Controls x trends

foreach X of varlist pop1962 area urbrate1962 earnings wage_employment value_cashcrops dist2nairobi border MomKam {
gen `X'_t = `X'*year
}
label var pop1962_t "Population in 1962 x trend"
label var area_t "Area in sq.km. x trend"
label var urbrate1962_t "Urbanization rate in 1962 (towns > 2000 inh.) x trend"
label var earnings_t "Warnings (million 2000 USD) from wage employment in 1966 x trend"
label var wage_employment_t "Wage employment (thousands) in 1963"
label var value_cashcrops_t "Value of cash crop production (million 2000 USD) in 1965 x trend"
label var border_t "District bordering Uganda or Tanzania x trend"
label var MomKam_t "District on the Mombasa-Kampala road x trend"
label var dist2nairobi_t "Distance in km to Nairobi x trend"

* Counterfactuals 

sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_pop"
tab _m
keep if _m == 3
drop _m
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_distance"
tab _m
keep if _m == 3
drop _m
sort distname_1979 year
merge distname_1979 year using "$mypath\counterfactual_pop_distance"
tab _m
keep if _m == 3
drop _m

label var change_paved_sh_pop "Share of paved road construction(pop.counterfactual)[d,t]/Pop.share[d,1962]"
label var change_paved_sh_dist "Share of paved road construction(dist.counterfactual)[d,t]/Pop.share[d,1962]"
label var change_paved_sh_mp "Share of paved road construction(pop.dist.counterfactual)[d,t]/Pop.share[d,1962]"

label var change_paved_pop "Paved road construction (pop.counterfactual)[d,t]"
label var change_paved_dist "Paved road construction (dist.counterfactual)[d,t]"
label var change_paved_mp "Paved road construction (pop.dist.counterfactual)[d,t]"

order province distname* distnum year* change_paved_share change_paved* chpaved_share km_paved pop1962_* change_paved_share2 area_* multiparty president* presshare* *share62 pop1962 area urbrate1962 earnings wage_employment value_cashcrops MomKam border dist2nairobi pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t MomKam_t border_t dist2nairobi_t

save "$mypath\kenya_roads_pav", replace
* creates "kenya_roads_pav", the data set with paved road construction as the dependent variable
* the data set is saved in the main folder

*********************************************************************************
* 3rd DATA SET, WITH CABINET SHARE AS THE DEPENDENT VARIABLE *
*********************************************************************************

* We import the data set on the cabinet shares of 13 ethnic groups x 13 cabinet years = 169 observations
clear
import excel "$mypath\cabinet_shares.xls", sheet("Sheet1") firstrow
label var ethnic_group "Ethnic group"
label var year "Cabinet Year (Election Year)"
label var cabinet_sh "Ethnic share of cabinet [e,t]"
order ethnic_group* year cabinet*
sort ethnic_group year
save "$mypath\cabinet_shares", replace

* We import the data on the population shares of each ethnic group in 1962
clear
import excel "$mypath\ethnic_pop_shares.xls", sheet("Sheet1") firstrow
sort ethnic_group 
save "$mypath\ethnic_pop_shares", replace

* We create several dependent variables and variables of interest

use "$mypath\cabinet_shares", clear
sort ethnic_group
merge ethnic_group using "$mypath\ethnic_pop_shares"
tab _m
drop _m
label var popshare1962 "Population share [e,1962]"

* Dependent variable: Ethnic share of cabinet [e,t] / Population share [e,1962] 

gen cabinet_index = cabinet_sh / popshare1962
sum cabinet_index, d
label var cabinet_index "Ethnic share of cabinet [e,t] / Population share [e,1962]"

* Democracy [t]

gen multiparty = 0
replace multiparty = 1 if (year >= 1963 & year <= 1966) | (year >= 1993)
label var multiparty "Democracy dummy [t]" 

* Coethnic group [e,t]

gen president = 0
replace president = 1 if ethnic_group == "kikuyu" & year >= 1963 & year <= 1974
replace president = 1 if ethnic_group == "kalenjin" & year >= 1979 & year <= 1998
replace president = 1 if ethnic_group == "kikuyu" & year >= 2003 
label var president "Coethnic group dummy [e,t]"

* Coethnic group [e,t] x democracy [t]

gen presidentMP = (president == 1 & multiparty == 1)
label var presidentMP "Coethnic group dummy [e,t] x Democracy dummy [t]"

* VP-Coethnic group [e,t]

gen vp = 0
replace vp = 1 if ethnic_group == "luo" & year == 1964
replace vp = 1 if ethnic_group == "maasai" & year == 1966
replace vp = 1 if ethnic_group == "kalenjin" & year >= 1969 & year <= 1974
replace vp = 1 if ethnic_group == "kikuyu" & year >= 1979 & year <= 1988
replace vp = 1 if (ethnic_group == "kikuyu" | ethnic_group == "maasai") & year >= 1993 & year <= 1998
replace vp = 1 if ethnic_group == "luhya" & year == 2003
replace vp = 1 if ethnic_group == "luhya" & year == 2005
replace vp = 1 if (ethnic_group == "luo" | ethnic_group == "kamba") & year == 2008
label var vp "VP-Coethnic group dummy [e,t]"

* VP-Coethnic group [e,t] x democracy [t]
 
gen vpMP = vp*multiparty
label var vpMP "VP-Coethnic group dummy [e,t] x Democracy dummy [t]"

order ethnic_group year cabinet_index cabinet_sh popshare*

save "$mypath\kenya_roads_cabinet", replace
* creates "kenya_roads_cabinet", the data set with the cabinet share as the dependent variable
* the data set is saved in the main folder

**********************************************************
