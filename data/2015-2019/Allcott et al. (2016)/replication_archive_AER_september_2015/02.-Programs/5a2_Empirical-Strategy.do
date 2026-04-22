/* Empirical Strategy.do */
* This file provides graphs and descriptive stats for the instruments, 
	* for use in the Empirical Strategy section.

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

capture log close
log using "$logs/Empirical Strategy $date $time.log", replace

include "$do/Subroutines/DefineGlobals.do"


*************************************************************************
***
* "No rainfall bin contains more than 12 percent of state-by-year observations
use "$work/state-level dataset for first stages.dta", replace
sum rainU,detail
sum PD_rainU_b006-ND_rainU_b24



*************************************************************************

/* HYDRO SHARE BY STATE GRAPHS */
/* Against Rainfall */
use "$work/state-level dataset for first stages.dta", replace
keep if year==2010
gen statelabel1=statelabel
replace statelabel1 = "" if inlist(statelabel,"Dadra and Nagar Haveli","Jharkhand","Pondicherry")
replace statelabel1 = "UP" if statelabel1=="Uttar Pradesh"
replace statelabel1 = "CG" if statelabel1=="Chhattisgarh"
replace statelabel1 = "MH" if statelabel1=="Maharashtra"
replace statelabel1 = "GA" if statelabel1=="Goa, Daman, and Diu"
replace statelabel1 = "UK" if statelabel1=="Uttarakhand"
twoway (scatter mean_rainfall_UDel HydroShare, mlabel(statelabel1) mcolor(navy) mlabc(gs12) mlabgap(0)), ///
	graphregion(color(white) lwidth(medium)) legend(off) ///
	xtitle("1992-2010 Mean of Hydro Generation/Total Consumption") ytitle("1992-2010 Mean Rainfall (meters)")
	graph export "$analyses/RainfallandHydroShare.pdf", as(pdf) replace

reg mean_rainfall_UDel HydroShare, robust
	
/* Bar chart: Hydro Share by State */
graph hbar (mean) HydroShare, over(statelabel) ///
	ytitle(Mean of Hydro Generation/Total Consumption) /// // title(Hydro Share of Electricity by State) ///
	graphregion(color(white) lwidth(medium))
	
	graph export "$analyses/HydroSharebyState.pdf", as(pdf) replace

	
/* HYDRO OVER TIME */	
use "$work/state-level dataset for first stages.dta", replace
bysort year: egen sumHydroGWh = sum(HydroGWh)
bysort year: egen sumTotalEnergySold = sum(TotalEnergySold)
gen sumH_Q = sumHydroGWh/sumTotalEnergySold
gen H_Q = HydroGWh/TotalEnergySold

twoway (line H_Q year, lp(l) lwidth(medthick) lcolor(purple), if state=="ANDHRA PRADESH") ///
	(line H_Q year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line H_Q year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="KARNATAKA") ///
	(line H_Q year, lp(-) lwidth(medthick) lcolor(blue), if state=="UTTAR PRADESH") ///
	(line H_Q year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="WEST BENGAL") ///
	(line sumH_Q year,lp(line) lwidth(thick) lcolor(black)), ///
	graphregion(color(white) lwidth(medium)) ///
	ytitle(Hydro Generation/Total Consumption) xtitle("") ///
	legend(label(1 "Andhra Pradesh") label(2 "Gujarat") label(3 "Karnataka") ///
	label(4 "Uttar Pradesh") label(5 "West Bengal") label(6 "India Average"))

graph export "$analyses/Hydro_InstbyState.pdf", as(pdf) replace


use "$work/state-level dataset for first stages.dta", replace
local In = "Hydro_Inst"
bysort year: egen mean`In' = mean(`In')


twoway (line `In' year, lp(l) lwidth(medthick) lcolor(purple), if state=="ANDHRA PRADESH") ///
	(line `In' year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line `In' year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="KARNATAKA") ///
	(line `In' year, lp(-) lwidth(medthick) lcolor(blue), if state=="UTTAR PRADESH") ///
	(line `In' year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="WEST BENGAL") ///
	(line mean`In' year,lp(line) lwidth(thick) lcolor(black)), ///
	graphregion(color(white) lwidth(medium)) ///
	ytitle(Hydro Generation/Predicted Consumption) xtitle("") ///
	legend(label(1 "Andhra Pradesh") label(2 "Gujarat") label(3 "Karnataka") ///
	label(4 "Uttar Pradesh") label(5 "West Bengal") label(6 "India Average"))

graph export "$analyses/InstbyState.pdf", as(pdf) replace

use "$work/state-level dataset for first stages.dta", replace
local In = "lnavail"
bysort year: egen mean`In' = mean(`In') 


twoway (line `In' year, lp(l) lwidth(medthick) lcolor(purple), if state=="ANDHRA PRADESH") ///
	(line `In' year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line `In' year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="KARNATAKA") ///
	(line `In' year, lp(-) lwidth(medthick) lcolor(blue), if state=="UTTAR PRADESH") ///
	(line `In' year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="WEST BENGAL"), /// 	(line mean`In' year,lp(line) lwidth(thick) lcolor(black)), //
	graphregion(color(white) lwidth(medium)) ///
	ytitle(ln(Energy Available)) xtitle("") ///
	legend(label(1 "Andhra Pradesh") label(2 "Gujarat") label(3 "Karnataka") ///
	label(4 "Uttar Pradesh") label(5 "West Bengal") ) // label(6 "India Average")

graph export "$analyses/lnAvailbyState.pdf", as(pdf) replace




/* Show that hydro generation is primarily driven by reservoir inflows */
use "$work/State-Level Dataset_ASI&Indicators.dta", clear
*use "$work\state-level indicators 1992-2010.dta", replace
keep if year>=1990

** All states: predicted and actual
	* Make ResGWh!=HydroGWh because when the reservoir inflows data is not available, we substitute ResGWhHat with HydroGWh so as not to have missing data.
scatter HydroGWh ResGWhHat if state!="INDIA"& ResGWhHat!=HydroGWh, /// title("State Reservoir Inflows and Hydro Production") ///
	ytitle("Actual Hydro Production (GWh/year)") ///
	xtitle("Production Predicted by Inflows (GWh/year)") ///
	graphregion(color(white) lwidth(medium))
	
graph export "$analyses/PredictedHydroProduction.pdf", as(pdf) replace

* Get R2 for text
reg HydroGWh ResGWhHat if state!="INDIA"& ResGWhHat!=HydroGWh, robust

* Show the share of observations that have inflows data:
sum HydroGWh if NumberofEstablishments>0&NumberofEstablishments!=.&HydroGWh!=0
sum ResInflows if NumberofEstablishments>0&NumberofEstablishments!=.&ResGWhHat!=HydroGWh


/* Additional graphs for presentation only */
*** Correlation with electricity demand:
reg HydroGWh req i.statenum, robust
avplot req , rlopts(lp(blank) lwidth(medthick)) ///
	title("Hydro Production vs. Predicted Demand") ///
	ytitle("Hydro Production (GWh/year)|state effects") ///
	xtitle("Demand(GWh/year)|state effects") ///
	graphregion(color(white) lwidth(medium))
	
graph export "$analyses/HydroProductionvsDemand.emf", as(emf) replace




/* KARNATAKA CASE STUDY */
use "$work/state-level dataset for first stages.dta", replace
*use "$work/State-Level Dataset_ASI&Indicators.dta", clear
label var Hydro_Inst_con "Hydro Generation/Total Consumption"
twoway (line Shortage year, lwidth(medthick) lp(_)) ///
	(line Hydro_Inst_con year, lwidth(medthick)) if state=="KARNATAKA",  /// title("Hydro Instrument and Shortages in Karnataka") ///
	ytitle("") ///
	xtitle("year") ///
	graphregion(color(white) lwidth(medium))
	
graph export "$analyses/KarnatakaFirstStage.pdf", as(pdf) replace

log close

