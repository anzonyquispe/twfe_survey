/* Stylized Facts.do */

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
*******************************************************************************
*******************************************************************************

* No correlation between shortages and median electricity price
use "$work/state-level dataset for first stages.dta", replace
* Differences
reg dlnRs_kWh_median dShortage i.statenum i.year _dG* [pw=NumberofEstablishments], robust  
reg dlnRs_kWh_median dShortage i.statenum i.year _dG*, robust

* Fixed effects
reg lnRs_kWh_median Shortage i.statenum i.year i.statenum#c.year i.SplitGroup [pw=NumberofEstablishments], robust cluster(statenum) 
reg lnRs_kWh_median Shortage i.statenum i.year i.statenum#c.year i.SplitGroup, robust cluster(statenum)


*********************************************************************************

/* TABLE OF SHORTAGES AND SUPPLY IN MAJOR STATES */
use "$work\state-level indicators 1992-2010.dta", clear
foreach stat in min max mean {	
	bysort state: egen `stat'Shortage=`stat'(Shortage)
}
keep if year==2010&TotalMW>=4500 //1700

keep statelabel meanShortage minShortage maxShortage TotalMW HydroShare
order statelabel meanShortage minShortage maxShortage TotalMW HydroShare
sort statelabel
outsheet using "$analyses/SupplyStats.csv", comma names replace



/* CROSS-SECTIONAL ASSOCIATION BETWEEN GDP GROWTH AND SHORTAGES */
use "$work\state-level indicators 1992-2010.dta", clear
gen pcgdp_growthrate = .
levelsof state, local(states)
foreach state in `states' {
	sum pcgdp_const if year==1992 & state=="`state'"
	local pcgdp_1992 = r(mean)
	sum pcgdp_const if year==2010 & state=="`state'"
	local pcgdp_2010 = r(mean)
	replace pcgdp_growthrate = (`pcgdp_2010'/`pcgdp_1992')^(1/19)-1 if state=="`state'"
}
bysort state: egen meanShortage=mean(Shortage)
keep if year==2010

gen statelabel0 = statelabel
replace statelabel0 = "Him. Prd." if statelabel=="Himachal Pradesh"
replace statelabel0 = "Pondi." if statelabel=="Pondicherry"

gen statelabel1 = ""
replace statelabel1 = statelabel0 if inlist(statelabel,"Manipur","Gujarat","West Bengal" ) // 
replace statelabel0 = "" if inlist(statelabel,"Manipur","Gujarat","West Bengal") // 

gen statelabel2 = ""
replace statelabel2 = statelabel0 if inlist(statelabel,"Jammu and Kashmir","Nagaland")
replace statelabel0 = "" if inlist(statelabel,"Jammu and Kashmir","Nagaland")

twoway (scatter Shortage pcgdp_growthrate, mlabel(statelabel) mcolor(navy) mlabc(navy) mlabgap(0)) ///
	(scatter Shortage pcgdp_growthrate, mlabel(statelabel1) mlabp(12) mcolor(navy) mlabc(navy) mlabgap(0)) ///
	(scatter Shortage pcgdp_growthrate, mlabel(statelabel2) mlabp(6) mcolor(navy) mlabc(navy) mlabgap(0)), ///
	graphregion(color(white) lwidth(medium)) legend(off) ///
	xtitle("1992-2010 Annualized per Capita GDP Growth") ytitle("2010 Shortage")
	*graph export "$analyses/ShortagesandProductionbyState.pdf", as(pdf) replace
	graph export "$analyses/Shortage2010andGDPGrowth.pdf", as(pdf) replace


** Negative association
reg Shortage pcgdp_growthrate, robust
reg Shortage pcgdp_growthrate, robust, if state!="ANDAMAN AND NICOBAR ISLANDS"&state!="PONDICHERRY"
reg Shortage pcgdp_growthrate [pweight=pcgdp_const], robust


/* Average over study period and GDP growth rate */
drop statelabel0 statelabel1 statelabel2
gen statelabel0 = statelabel
*replace statelabel0 = "Him. Prd." if statelabel=="Himachal Pradesh"
*replace statelabel0 = "Pondi." if statelabel=="Pondicherry"

gen statelabel1 = ""
replace statelabel1 = statelabel0 if inlist(statelabel,"Nagaland" ) // "West Bengal",
replace statelabel0 = "" if inlist(statelabel,"Nagaland") // "West Bengal",

gen statelabel2 = ""
replace statelabel2 = statelabel0 if inlist(statelabel,"Assam","Himachal Pradesh") // "Jammu and Kashmir",
replace statelabel0 = "" if inlist(statelabel,"Assam","Himachal Pradesh") // "Jammu and Kashmir",

gen statelabel3 = ""
replace statelabel3 = statelabel0 if inlist(statelabel,"Pondicherry")
replace statelabel0 = "" if inlist(statelabel,"Pondicherry")

*drop if state=="ANDAMAN AND NICOBAR ISLANDS"
twoway (scatter meanShortage pcgdp_growthrate, mlabel(statelabel0) mcolor(navy) mlabc(gs12) mlabgap(0)) ///
	(scatter meanShortage pcgdp_growthrate, mlabel(statelabel1) mlabp(12) mcolor(navy) mlabc(gs12) mlabgap(0)) ///
	(scatter meanShortage pcgdp_growthrate, mlabel(statelabel2) mlabp(6) mcolor(navy) mlabc(gs12) mlabgap(0)) ///
	(scatter meanShortage pcgdp_growthrate, mlabel(statelabel3) mlabp(9) mcolor(navy) mlabc(gs12) mlabgap(0)), ///
	graphregion(color(white) lwidth(medium)) legend(off) ///
	xtitle("1992-2010 Annualized per Capita GDP Growth") ytitle("Average 1992-2010 Shortage")
	*graph export "$analyses/ShortagesandProductionbyState.pdf", as(pdf) replace
	graph export "$analyses/ShortagesandGDPGrowth.pdf", as(pdf) replace

reg meanShortage pcgdp_growthrate, robust
reg meanShortage pcgdp_growthrate, robust, if state!="ANDAMAN AND NICOBAR ISLANDS"&state!="PONDICHERRY"
reg meanShortage pcgdp_growthrate [pweight=pcgdp_const], robust



********************************************************************


/* WITHIN-STATE VARIATION IN SHORTAGES */
/* Time-Series Variation in Shortages for Five Largest Mfg States */
use "$work/state-level dataset for first stages.dta", replace

keep if Shortage!=.
sort state year


/* Time-Series Variation in Shortages for Large States */
use "$work/state-level dataset for first stages.dta", replace

bysort year:egen meanShortage=mean(Shortage)

*** States in different regions
	* WB, UP, Guj, KN, TN, All
keep if Shortage!=.
sort state year

twoway (line Shortage year, lp(l) lwidth(medthick) lcolor(purple), if state=="ANDHRA PRADESH") ///
	(line Shortage year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line Shortage year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="KARNATAKA") ///
	(line Shortage year, lp(-) lwidth(medthick) lcolor(blue), if state=="UTTAR PRADESH") ///
	(line Shortage year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="WEST BENGAL") ///
	(line meanShortage year,lp(line) lwidth(thick) lcolor(black), if state=="ANDHRA PRADESH"), ///
	graphregion(color(white) lwidth(medium)) ///
	ytitle(Shortage) xtitle("") ///
	legend(label(1 "Andhra Pradesh") label(2 "Gujarat") label(3 "Karnataka") ///
	label(4 "Uttar Pradesh") label(5 "West Bengal") label(6 "India Average"))
	
	graph export "$analyses/ShortagesOverTime.pdf", as(pdf) replace




keep if Shortage!=.
sort state year
twoway (line Shortage year, lp(l) lwidth(medthick) lcolor(purple), if state=="MAHARASHTRA") (line Shortage year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line Shortage year, lp(-) lwidth(medthick) lcolor(blue), if state=="ANDHRA PRADESH") (line Shortage year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="KARNATAKA") ///
	(line Shortage year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="WEST BENGAL"), /// title(Shortages in Five Large States) ///
	graphregion(color(white) lwidth(medium)) ///
	legend(label(1 "Maharashtra") label(2 "Gujarat") label(3 "Andhra Pradesh") label(4 "Karnataka") label(5 "West Bengal"))

	graph export "$analyses/ShortagesOverTime.pdf", as(pdf) replace


	

keep if Shortage!=.
sort state year
twoway (line Shortage year, lp(l) lwidth(medthick) lcolor(purple), if state=="MAHARASHTRA") (line Shortage year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line Shortage year, lp(-) lwidth(medthick) lcolor(blue), if state=="TAMIL NADU") (line Shortage year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="KARNATAKA") ///
	(line Shortage year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="WEST BENGAL"), /// title(Shortages in Five Large States) ///
	graphregion(color(white) lwidth(medium)) ///
	legend(label(1 "Maharashtra") label(2 "Gujarat") label(3 "Tamil Nadu") label(4 "Karnataka") label(5 "West Bengal"))

	graph export "$analyses/ShortagesOverTime.pdf", as(pdf) replace


	
** Graph of six other large states
twoway (line Shortage year, lp(l) lwidth(medthick), if state=="ANDHRA PRADESH") (line Shortage year,lp(_) lwidth(medthick), if state=="HARYANA") ///
	(line Shortage year, lp(-) lwidth(medthick), if state=="JAMMU AND KASHMIR") (line Shortage year,lp(shortdash) lwidth(medthick), if state=="MADHYA PRADHESH") ///
	(line Shortage year,lp(dash_dot) lwidth(medthick), if state=="PUNJAB") (line Shortage year,lp(dash_dot) lwidth(medthick), if state=="UTTAR PRADESH"), ///
	title(Shortages in Six Example States) ///
	graphregion(color(white) lwidth(medium)) ///
	legend(label(1 "Andhra Pradesh") label(2 "Haryana") label(3 "J-K") label(4 "MP") label(5 "Punjab") label(6 "UP"))
	graph export "$analyses/ShortagesOverTime1.pdf", as(pdf) replace
	*graph export "$analyses/ShortagesOverTime1.emf", as(emf) replace



	
** For five largest mfg states
twoway (line Shortage year,lp(shortdash) lwidth(medthick) lcolor(green), if state=="ANDHRA PRADESH") ///
	(line Shortage year,lp(_) lcolor(red) lwidth(medthick), if state=="GUJARAT") ///
	(line Shortage year, lp(l) lwidth(medthick) lcolor(purple), if state=="MAHARASHTRA") ///
	(line Shortage year, lp(-) lwidth(medthick) lcolor(blue), if state=="TAMIL NADU") ///
	(line Shortage year,lp(dash_dot) lwidth(medthick) lcolor(orange), if state=="UTTAR PRADESH"), /// title(Shortages in Five Large States) ///
	graphregion(color(white) lwidth(medium)) ///
	legend(label(1 "Andhra Pradesh") label(2 "Gujarat") label(3 "Maharashtra") label(4 "Tamil Nadu") label(5 "Uttar Pradesh"))

	graph export "$analyses/ShortagesOverTime2.pdf", as(pdf) replace

	












********************************************************************************
*** BELOW HERE IS INTERESTING GRAPHS WHICH ARE NO LONGER USED ***
/* OVERVIEW OF THE POWER SECTOR */
/* Installed Capacity by Owner */
insheet using "$data/CEA/Installed Capacity by Owner.csv", comma names case clear
drop if Owner=="Total"
graph pie Capacity, over(Owner) ///
	plabel(_all name, size(large)) legend(off) ///
	graphregion(color(white) lwidth(medium)) ///
	title(Generation Capacity by Owner)
*graph export "$analyses/InstalledCapacitybyOwner.pdf", as(pdf) replace
graph export "$analyses/InstalledCapacitybyOwner.emf", as(emf) replace


/* Generation Technology Shares */
insheet using "$data/CEA/Installed Capacity by Type.csv", comma names case clear
drop if Type=="Total"
graph pie Capacity, over(Type) ///
	plabel(_all name, size(large)) legend(off) ///
	graphregion(color(white) lwidth(medium)) ///
	title(Generation Capacity by Type)
*graph export "$analyses/InstalledCapacitybyType.pdf", as(pdf) replace
graph export "$analyses/InstalledCapacitybyType.emf", as(emf) replace


/* Prices */
insheet using "$data/Tariffs/Category-Wise/2010.csv", comma nonames clear
keep if _n==38
rename v2 Domestic
rename v3 Commercial
rename v4 Agriculture
rename v5 Industrial
*rename v6 Railway
rename v8 Average
drop v1 v6 v7

destring  Domestic Commercial Agriculture Industrial Average, replace force
foreach var in Domestic Commercial Agriculture Industrial Average {
	replace `var' = `var'/100
}
graph bar (asis)  Domestic Commercial Agriculture Industrial Average, ascategory ///
	graphregion(color(white) lwidth(medium)) ///
	title(Electricity Prices by Consumer Category) ///
	ytitle(2010 Nationwide Average Electricity Price (Rs/kWh))
*graph export "$analyses/PricesbyConsumerCategory.pdf", as(pdf) replace
graph export "$analyses/PricesbyConsumerCategory.emf", as(emf) replace



/* SHORTAGES: SYSTEMIC REASONS */
/* Shortages Over Time */
use "$work/State-Level Dataset_ASI&Indicators.dta", clear
collapse (mean) Shortage PeakShortage [pweight=avail],by(year)

twoway (line Shortage PeakShortage year), ///
	graphregion(color(white) lwidth(medium)) ///
	title(National Average Electricity Shortages Over Time) ///
	ytitle(Mean of State Shortages) ///
	yscale(range(0(0.05)0.25)) ///
	legend(label(1 "Shortage") label(2 "Peak Shortage")) 
*graph export "$analyses/NationalShortagesOverTime.pdf", as(pdf) replace
graph export "$analyses/NationalShortagesOverTime.emf", as(emf) replace


/* Losses by SEBs */
insheet using "$data/PFC Performance Reports/LossesbySEBs.csv", comma names case clear
* Import deflators
gen state = "KARNATAKA" 
merge 1:1 state year using "$work/state gdp and gdppc figs_const & curr.dta", keepusing(pcgdp_const pcgdp_curr) keep(match master) nogen
gen Deflator = pcgdp_const/pcgdp_curr
sum Deflator if year == 2004
replace Deflator = Deflator/r(mean)
gen LossesCrore_Real = LossesCrore*Deflator
gen Gapwithoutsubsidy_Real = Gapwithoutsubsidy*Deflator

gen LossesBillions = LossesCrore_Real/100/45
* Comparison: 2004 total income is 100k Crore, so these losses are 1% to 20% of total income 

* Total losses figure for text.
sum LossesBillions
display r(mean)*r(N)

	// Rs 45 to the dollar in 2004 http://en.wikipedia.org/wiki/Tables_of_historical_exchange_rates_to_the_United_States_dollar
twoway (line Gapwithoutsubsidy year, yaxis(1)) (line LossesBillions year, yaxis(2)), ///
	graphregion(color(white) lwidth(medium)) ///
	title(Utilities' Losses by Year) ///
	ytitle(Cost-Revenue (Rs/kWh), axis(1)) ytitle(Losses (Billions of dollars), axis(2)) ///
	legend(label(1 "Cost-Revenue") label(2 "Losses")) 
*graph export "$analyses/UtilitiesLossesbyYear.pdf", as(pdf) replace
graph export "$analyses/UtilitiesLossesbyYear.emf", as(emf) replace

*** AT&C Losses
twoway (line ATCLosses year if year>=2002&year<=2009), ///
	graphregion(color(white) lwidth(medium)) ///
	title(Technical and Commercial Losses) ///
	ytitle(Aggregate Technical and Commercial Loss (Percent)) ///
	yscale(range(0(5)40)) ylabel(0(5)40)
*graph export "$analyses/ATCLosses.pdf", as(pdf) replace
graph export "$analyses/ATCLosses.emf", as(emf) replace


/* Capacity Target and Achievement */
insheet using "$data/CEA/Capacity Addition/Planwise Capacity Addition.csv", comma names case clear
drop if Plan==""|Plan=="6"
replace Target=Target/1000
replace Actual=Actual/1000
graph bar Target Actual , over(FiscalYears) ///
	graphregion(color(white) lwidth(medium)) ///
	title(Capacity Addition by Plan) ///
	ytitle(Capacity (gigawatts)) ///
	legend(label(1 "Target") label(2 "Actual")) 
*graph export "$analyses/PlanwiseCapacityAddition.pdf", as(pdf) replace
graph export "$analyses/PlanwiseCapacityAddition.emf", as(emf) replace


/* Utilization */
use "$work/OutageRates.dta", clear
collapse (mean) ForcedOutage Outage [fweight=round(CoalCap)],by(year) 
twoway (line ForcedOutage year) (line Outage year), ///
	graphregion(color(white) lwidth(medium)) ///
	title(Coal Plant Outage Rates Over Time) ytitle(Outage Rate) ///
	legend(label(1 "Forced Outage") label(2 "Forced, Planned, and Partial Outages")) 
*graph export "$analyses/OutagesOverTime.pdf", as(pdf) replace
graph export "$analyses/OutagesOverTime.emf", as(emf) replace

sum Outage



	
/* Data for graphs */
use "$work/State-Level Dataset_ASI&Indicators.dta", clear
gen shortagepctPSP_allyears = Shortage
gen shortagepctPSP_2011 = Shortage if year==2011
*gen shortagepctPSP_2007 = shortagepctPSP if year==2007

collapse (mean) shortagepctPSP_* (first) Region, by(state)
drop if state==""|shortagepctPSP_all==.
outsheet using "$work/CrossSectionalShortagesforMap.csv", replace comma names



	
