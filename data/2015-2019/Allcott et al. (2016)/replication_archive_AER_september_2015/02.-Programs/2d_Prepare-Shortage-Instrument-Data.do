/* Prepare Shortage Instrument Data.do */
* Note about capacity change data: from 1990-1999, capacity addition is net capacity addition, which includes additions and deletions.
* After 2000, capacity addition is just capacity addition. However, retirements and rerates are small. We therefore can combine the data.
************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
global InstrumentData "$root/01. Data/CEA"

include "$do/Subroutines/DefineGlobals.do"
************************************************************************************
************************************************************************************


/* PREPARATORY STUFF */
***merge programs
cap program drop mergebase
program define mergebase
	syntax using
	use "$work/shortages_base", clear
	merge 1:1 state year `using', keep(1 3) 
	tab state if _m==1
	drop _m
	save "$work/shortages_base", replace
end

/* set up base file to merge in to */
set obs 19
g year=_n+1991
tempfile temp
save `temp'
use state using "$work/statelist.dta",clear 
duplicates drop
cross using `temp'

include "$do/subroutines/DefinePowerRegions.do"

save "$work/shortages_base", replace

/* Get CEA state crosswalk */
insheet using "../01. Data/CEA/CEA Exec Sum PDFs/MonthlyShortages/CEAstate_crosswalk.csv", comma clear case names
save "$intdata/CEAstate_crosswalk.dta",replace

/* Clean State Names */
insheet using "$InstrumentData/CorrectedCEAstates.csv", comma clear case names
save "$intdata/CorrectedCEAstates.dta",replace

/* Clean Hydro Scheme Names */
insheet using "$data/CEA/Hydro/CorrectedResSchemes.csv", comma names case clear
drop Notes
save "$intdata/CorrectedResSchemes.dta",replace


/* Get crosswalk from reservoir scheme to state */
* Note that ResCapMW is a recent capacity (either 2010 or 2006) but in practice this changes over time.
insheet using "$data/CEA/Hydro/ResScheme_State_crosswalk.csv", comma names case clear
drop Notes CapacitySource
rename ResCapMW RecentResCapMW
save "$intdata/ResScheme_State_crosswalk.dta", replace


************************************************************************************
************************************************************************************


/* ELECTRICITY CONSUMPTION BY CATEGORY */
* Used for AgriShare and also fitted state consumption
/* Data prep */
insheet using "$data/CEA/Consumption by Category/ConsumptionbyCategory.csv", comma names clear case
rename State CEAstate
merge m:1 CEAstate using "$intdata/CorrectedCEAstates.dta", keep(match master) nogen
replace CEAstate=CEAstate_corrected if CEAstate_corrected != ""
drop CEAstate_corrected

merge m:1 CEAstate using "$intdata/CEAstate_crosswalk.dta", keep(match master)
	assert CEAstate=="Sub Total" if _m==1
	drop _m 

******CORRECT FOR GOA DAMAN AND DIU
drop if state=="DAMAN & DIU"
replace state = "GOA DAMAN AND DIU" if state=="GOA"
***********************************


**
rename BeginYear year
drop EndYear
destring Domestic Commercial  IndustrialPowerLowMedVoltage IndustrialPowerHighVoltage PublicLighting Traction Agriculture PublicWaterWorksSewagePumping Miscellaneous, replace force ignore(",","(A)","(B)") 
* One data error
replace TotalEnergySold = 24912.45 if year==1998 & CEAstate=="Andhra Pradesh"
replace Commercial = 577.75 if year==1992 & CEAstate=="Madhya Pradesh"

*** Test for data errors
* Sums within region correct
bysort Region year: egen TotalGWh_Region_temp = sum(TotalEnergySold) if CEAstate!="Sub Total" // This sums across all states within a region, plus the "Central Sector"
bysort Region year: egen TotalGWh_Region = mean(TotalGWh_Region_temp) // This sums across all states within a region

gen flag = ((TotalGWh_Region>TotalEnergySold+100|TotalGWh_Region<TotalEnergySold-100) & CEAstate=="Sub Total")
sum flag 
assert r(mean)==0 
drop flag TotalGWh_Region_temp TotalGWh_Region

* Sums across rows within state correct
gen TotalGWhCheck =  Domestic+Commercial+IndustrialPowerLowMedVoltage+IndustrialPowerHighVoltage+PublicLighting+Traction+Agriculture+PublicWaterWorksSewagePumping+Miscellaneous
gen flag = (TotalGWhCheck>TotalEnergySold+10|TotalGWhCheck<TotalEnergySold-10)
sum flag if year<=2003 // After 2003 we don't have the sub-categories in the data
assert r(mean)==0 
drop flag TotalGWhCheck

drop if state==""


** Get NationalTotalEnergySold, then merge just below
	* Do this so that the pre-split states also get NationalTotalEnergySold
forvalues year = 1985/2013 {
	sum TotalEnergySold if CEAstate=="All" & year==`year'
	local NationalTotalEnergySold`year' =  r(mean)
}

keep state year TotalEnergySold
compress


save "$work/ConsumptionbyCategory.dta", replace
mergebase using "$work/ConsumptionbyCategory.dta"

/* Predicted GWh */
gen NationalTotalEnergySold = .
forvalues year = 1985/2013 {
	replace NationalTotalEnergySold = `NationalTotalEnergySold`year'' if year==`year'
}

******************

/* Predicted GWh using nationwide average (without leaving out state) */
	* This is the approach from the original March 2014 version

** Original prediction (without jackknifing)
gen State_India = TotalEnergySold/NationalTotalEnergySold
bysort state: egen meanState_India_pre2000 = mean(State_India) if year<=2000
bysort state: egen meanState_India_post2001 = mean(State_India) if year>=2001
bysort state: egen meanState_India= mean(State_India)
* for states that do not split, use the average across all years
gen PredGWhSold_orig = meanState_India*NationalTotalEnergySold

* for states that do split, use the average for the relevant years
replace PredGWhSold_orig = cond(year>=2001,meanState_India_post2001*NationalTotalEnergySold,meanState_India_pre2000*NationalTotalEnergySold) ///
	if state == "BIHAR"|state=="JHARKHAND"|state=="UTTAR PRADESH"|state=="UTTARANCHAL"|state=="MADHYA PRADESH"|state=="CHHATTISGARH"

*****************
drop State_India meanState_India*


** Jackknifed prediction, treating pre-split as combined states
gen RestofIndia = NationalTotalEnergySold-TotalEnergySold
gen State_RestofIndia = TotalEnergySold/RestofIndia
bysort state: egen meanState_RestofIndia = mean(State_RestofIndia)
bysort state: egen meanState_RestofIndia_pre2000 = mean(State_RestofIndia) if year<=2000
bysort state: egen meanState_RestofIndia_post2001 = mean(State_RestofIndia) if year>=2001
* for state that do not split, use the average across all years
gen PredGWhSold_comb = meanState_RestofIndia * RestofIndia

* for states that do split, use the average for the relevant years
	* Ch, Jh, and Uttaranchal all begin in 2001.
replace PredGWhSold_comb = cond(year>=2001,meanState_RestofIndia_post2001*RestofIndia,meanState_RestofIndia_pre2000*RestofIndia) ///
	if state == "BIHAR"|state=="JHARKHAND"|state=="UTTAR PRADESH"|state=="UTTARANCHAL"|state=="MADHYA PRADESH"|state=="CHHATTISGARH"
	
** Jackknifed prediction for the balanced set of states
gen PredGWhSold_bal=PredGWhSold_comb

* for newly-created states, impute based on post-2001 share
replace PredGWhSold_bal = meanState_RestofIndia * (NationalTotalEnergySold*(1-meanState_RestofIndia)) ///
	if inlist(state,"JHARKHAND","UTTARANCHAL","CHHATTISGARH")&year<=2000

* for the states that were split from, subtract the amount imputed to their new states
forvalues year=1992/2000 {
	sum PredGWhSold_bal if state=="CHHATTISGARH"&year==`year'
	replace PredGWhSold_bal=PredGWhSold_bal-r(mean) if state=="MADHYA PRADESH"&year==`year'
	
	sum PredGWhSold_bal if state=="JHARKHAND"&year==`year'
	replace PredGWhSold_bal=PredGWhSold_bal-r(mean) if state=="BIHAR"&year==`year'
	
	sum PredGWhSold_bal if state=="UTTARANCHAL"&year==`year'
	replace PredGWhSold_bal=PredGWhSold_bal-r(mean) if state=="UTTAR PRADESH"&year==`year'
	
}
drop meanState_RestofIndia meanState_RestofIndia_pre2000 meanState_RestofIndia_post2001 State_RestofIndia RestofIndia
	
save "$work/shortages_base", replace


************************************************************
************************************************************

/* RAINFALL AND TEMPERATURES */
** NCC rainfall
mergebase using "$work/state-year NCC rainfall temp.dta"

** UDel rainfall
mergebase using "$work/state-year UDel rainfall.dta"

** MW-meters rainfall from UDel
mergebase using "$work/state-year hydrobasin MWMeters.dta"
replace annual_rainfallMWMeters_mm = 0 if annual_rainfallMWMeters_mm==. // Missing for five states that have no dams.

drop HDD* CDD55 CDD60 CDD70 CDD75 CDD80
save "$work/shortages_base", replace

**********************************************************


/* COAL PLANT OUTAGE RATES */
	* comment out because not currently using
use "$data/Forced Outages/IndiaPowerPlant ForcedOutage.dta", clear
keep if unit==0
replace state = "CHHATTISGARH" if state=="CHATTISGARH"

*** Drop units with missing data
* Some units missing significant data. Drop all years before 1992. Then drop all years before which data are missing for a plant.
drop if year<1992
gen missing = cond(pm==.|pm==.m,1,0)
gsort name -year
gen missing_plant = missing
replace missing_plant = 1 if missing_plant[_n-1]==1&name==name[_n-1]
drop if missing_plant ==1 
drop missing missing_plant
drop if name=="JOJOBERA"|name=="SURAT LIGNITE" // all but the 2009 observations of these are missing.

* Also - at least a couple of plants have high forced outage rates in their first year of operation only. Drop this.
sort name year
drop if year>1992&name!=name[_n-1]&fo>=50

* Note: Hunt checked on 5-8-2013 and the unit names appear to be consistent, and they are certainly consistent for MP, Chhatt, Bihar, and Jharkhand.
** Get true state locations by rolling back later state names (some plants are in states that split)
gen OriginalState = state
gsort name -year
bys name: g rank=_n
bys name: g rank2=_N
tab state
replace state=state[_n-1] if name==name[_n-1] & rank!=1  
tab state

gen ThermalCF = gen/(cap*8.760)
bysort name: egen meanCF=mean(ThermalCF)
gen ThermalCF_dev = ThermalCF-meanCF

save "$work/UtilizationRatesMicrodata.dta", replace

*** Collapse to state level
* Get unavailability in MW
gen PartialUnavail = puvl*cap/100
gen PlannedOutage = pm*cap/100
gen ForcedOutage = fo*cap/100
gen CoalCap = cap



collapse (rawsum)  PartialUnavail PlannedOutage ForcedOutage CoalCap ///
	(mean) ThermalCF ThermalCF_dev [pweight=CoalCap], by(state year)

compress
save "$work/OutageRates.dta", replace
mergebase using "$work/OutageRates.dta"




************************************************************************************
************************************************************************************


/* MERGE HYDRO GENERATION MICRODATA */
	* Including run-of-river
/* Merge the hydro capacity factor deviations */
	use "$work/shortages_base", clear
	merge 1:1 state year using "$work/stateXyear_hydrogen_CFdeviations.dta", keep(1 3) keepusing(HydroCF_run_dev AllocatedHydroMW_micro_run HydroGWh_micro_all_Complete HydroGWh_micro_run_Complete)
	tab state if _m==1
	drop _m
	save "$work/shortages_base", replace
	
*foreach var in AllocatedHydroMW_micro_run HydroGWh_micro_all_Complete HydroGWh_micro_run_Complete {
*	replace `var' = 0 if `var'==.
*}


************************************************************************************
************************************************************************************

/* INSHEET AND MERGE RESERVOIR INFLOWS */
* In the file ResScheme_State_crosswalk.dta, "Complete" means that the plant appears in the data in all years after it was commissioned, and "Balanced" means that the plant began operation before 1992.
insheet using "$data/CEA/Hydro/Inflows.csv", comma names clear
keep if year>=1992&year<=2010
rename reservoirscheme ResScheme_Original
*destring inflowsmcm, gen(ResInflows) force
rename inflowsmcm ResInflows
*drop inflowsmcm
destring generationgwh, gen(ResGWh)

merge m:1 ResScheme_Original using "$intdata/CorrectedResSchemes.dta", assert(3) nogen keep(match master)
drop ResScheme_Original
replace ResInflows=. if ResInflows==-99999
replace ResGWh=. if ResGWh==-99999
replace ResInflows = 19025 if ResScheme == "Almatti" & year==2006 // Data error in the 2006 book, but it's printed correctly in the 2007 book

replace ResInflows = ResInflows/1000 // Now in BCM (billion cubic meters)


merge m:1 ResScheme using "$intdata/ResScheme_State_crosswalk.dta", assert(3) nogen keep(match master)
** Merge rainfall
merge 1:1 ResScheme year using "$work/Reservoir Rainfall.dta", nogen keep(match master) keepusing(ResRainfall) // _m==1 is only Medhaputty, which Steve could not find a match for. _m==2 are for reservoirs where there is rainfall but not yet in the Inflows data.

*** For each reservoir, use ResInflows to predict CFdev
	* Note: Hunt spot-checked these using the code below and the data for GWh and Inflows both seem to be good.
	/*
		levelsof ResScheme, local(levels)
		sort ResScheme year
		foreach ResScheme in `levels' {
			local trimname = subinstr("`ResScheme'"," ","",.)
			local trimname = subinstr("`trimname'",".","",.)
			twoway (line ResInflows year if ResScheme=="`ResScheme'",yaxis(1)) ///
			(line ResGWh year if ResScheme=="`ResScheme'",yaxis(2)), title("`ResScheme'") name("`trimname'", replace)
		}
		*/
	
	* Note that in two cases the predictions have negative slopes. When slopes are negative: this still helps us to best-fit that reservoir's production of GWh, although it may be worse at predicting what other dams in the state would be producing. Because the state-level CFs are capacity-weighted, small-capacity reservoirs will matter less if more than one reservoir in a state.
	* Note: in a couple of cases, the dams on these reservoirs expand. Because we are using CF based on a recent capacity, we may understate CF, but because it's based on inflows, the variation in CF is entirely exogenous.
gen PredResGWh = ResGWh // Notice that in the five observations where ResInflows are missing, this means that we use the true ResGWh.
gen PredResCF = .
gen HydroCF_res_dev = . 
gen RainfallPredResInflows = .
gen dmRainfallPredResInflows = .
gen dmResInflows = .
gen ResInflows_Complete=ResInflows
levelsof ResScheme, local(levels)
foreach ResScheme in `levels' {
	display "`ResScheme'"
	
	** Address missing year: Predict inflows using rainfall
	capture noisily reg ResInflows ResRainfall if ResScheme == "`ResScheme'"
	if _rc != 2000 {
		predict ResInflowsRainfallHat
		replace RainfallPredResInflows = ResInflowsRainfallHat if ResScheme=="`ResScheme'" & ResInflowsRainfallHat!=.
		sum ResInflowsRainfallHat if ResScheme=="`ResScheme'" 
		replace dmRainfallPredResInflows = ResInflowsRainfallHat - r(mean) if ResScheme=="`ResScheme'" & ResInflowsRainfallHat!=.
		drop ResInflowsRainfallHat
		sum ResInflows if ResScheme=="`ResScheme'" 
		replace dmResInflows = ResInflows-r(mean) if ResScheme=="`ResScheme'" 
		*sum year if ResScheme=="`ResScheme'" 
		*local Resminyear=r(min)
	}
	
	* replace ResInflows with ResInflowsRainfallHat if missing (year 2000) in order to predict the capacity factor. Thus there will be no missing data in capacity factor.
	replace ResInflows_Complete = RainfallPredResInflows if ResScheme=="`ResScheme'" & year==2000
	
	** Get ResGWh predicted by inflows
	reg ResGWh ResInflows_Complete if ResScheme == "`ResScheme'"
		*reg ResGWh ResInflows if ResScheme == "`ResScheme'" // This would not use the rainfall-predicted data.
	predict ResGWhHat
	replace PredResGWh = ResGWhHat if ResScheme=="`ResScheme'" & ResGWhHat!=.
	drop ResGWhHat
	*sum PredResGWh if ResScheme=="`ResScheme'"
	*replace MaxPredResGWh = r(max) if ResScheme=="`ResScheme'" // Proxy for capacity
	*replace PredResCF = PredResGWh/MaxPredResGWh if ResScheme=="`ResScheme'"
	
	** Get ResCF predicted by ResGWh
	replace PredResCF = PredResGWh/(RecentResCapMW*8.760) if ResScheme=="`ResScheme'"
	* Get CF_res_dev by de-meaning in order to deal with unbalanced panel of reservoirs
	sum PredResCF if ResScheme=="`ResScheme'"
	replace HydroCF_res_dev = PredResCF-r(mean) if ResScheme=="`ResScheme'"
	

}

label var ResInflows "Reservoir Inflows (billion cubic meters)"
label var ResGWh "Reservoir-Level Generation (GWh)"
label var RecentResCapMW "Reservoir-Level Generation Capacity (MW)"
label var PredResCF "Capacity Factor Predicted by Inflows"

save "$work/ResInflowsandGWh.dta", replace


*** Collapse to state level
replace Pctstate1 = 100 if state1==""
replace state1 = state if state1==""

keep year ResScheme PredResGWh ResRainfall RecentResCapMW PredResCF HydroCF_res_dev ResInflows ResInflows_Complete ResGWh state? Pctstate?
reshape long state Pctstate, i(ResScheme year) j(num) string
drop if state==""

* when collapsing to the state level, weight each reservoir by capacity x state share
gen AllocatedRecentResCapMW = RecentResCapMW*(Pctstate/100)
collapse (rawsum) AllocatedRecentResCapMW ResInflows_Complete (mean) HydroCF_res_dev [pw=AllocatedRecentResCapMW],by(state year)

save "$work/ResInflowsandGWh_state.dta", replace
mergebase using "$work/ResInflowsandGWh_state.dta"


************************************************************************************
************************************************************************************


/* CAPACITY AND CAPACITY ADDITIONS */
	* Note: several Northeastern states go to zero hydro capacity in 2008 that were non-zero in 2007, losing about 80 MW of total capacity. This may be an error, as it does not show up in the derates/decommissionings in 2007 (General Review 2009 page 47) but it is not clear what to do. HydroGWh reported also goes to zero in 2007 for these states. I will assume that the data are correct, so we get zero CF in 2007 and undefined CF in 2008.
/* Data checks */
	* Make sure that capacity data line up across rows
insheet using "$InstrumentData/Capacity.csv", comma names clear case
foreach var in Hydro Steam Diesel Wind Gas Nuclear BiomassPower BiomassGasifier UI RES {
	replace `var'MW = 0 if `var'MW==.
}
gen TotalMWCheck = Hydro+Steam+Diesel+Wind+Gas+Nuclear+BiomassPower+BiomassGasifier+UI+RESMW
gen flag = (TotalMWCheck>TotalMW+1|TotalMWCheck<TotalMW-1)
sum flag if Year<2009 // We did not enter the fuel-specific MW for 2010 and 2011.
assert r(mean)==0


** Regional capacity
bysort Region Year: egen HydroMW_Region = sum(HydroMW) if State!="Sub Total" // This sums across all states within a region, plus the "Central Sector"

	* Test
	sort Region Year State 
	replace HydroMW_Region = HydroMW_Region[_n-1] if Region==Region[_n-1]&Year==Year[_n-1]&State=="Sub Total"
	gen flag1 = ((HydroMW_Region>HydroMW+1|HydroMW_Region<HydroMW-1)&State=="Sub Total")
	sum flag1
	assert r(mean)==0

	
/* Data prep */
* Note that this is capacity at the BEGINNING of the year.
*** Start with capacity data
insheet using "$InstrumentData/Capacity.csv", comma names clear case
rename State CEAstate 
merge m:1 CEAstate using "$intdata/CorrectedCEAstates.dta", keep(match master) nogen
replace CEAstate=CEAstate_corrected if CEAstate_corrected != ""
drop CEAstate_corrected
rename Year year // Note: this will be capacity at beginning of the fiscal year.

**** Capacity data corrections 
* Missing decimal
replace DieselMW = 53.59 if year==1993 & Region=="Eastern" & CEAstate=="Sub Total"
replace TotalMW = 10245.24 if year==1993 & Region=="Eastern" & CEAstate=="Sub Total"

* Apparent typing error
replace HydroMW = 255.01 if year==1993 & Region=="North Eastern" & CEAstate=="Central Sector"
replace TotalMW = 255.01 if year==1993 & Region=="North Eastern" & CEAstate=="Central Sector"

* Goa is listed with 0.050 MW of Hydro, but only 2003 and before, and zero HydroGWh generation in the generation data. So will make this zero.
replace HydroMW = 0 if CEAstate=="Goa"

* Assam has 2 HydroMW listed, but zero production
replace HydroMW = 0 if CEAstate=="Assam"&year<=2006

*******


** India-wide capacity
gen tempIndiaHydroMW = HydroMW if CEAstate=="All"
bysort year: egen IndiaHydroMW = mean(tempIndiaHydroMW)
drop tempIndiaHydroMW

gen tempIndiaMW = TotalMW if CEAstate=="All"
bysort year: egen IndiaMW = mean(tempIndiaMW)
drop tempIndiaMW

** Regional capacity
bysort Region year: egen HydroMW_Region = sum(HydroMW) if CEAstate!="Sub Total" // This sums across all states within a region, plus the "Central Sector"


** Get annual capacity change
	* Note: this will be capacity change over the fiscal year beginning in `year'.
		* (Because TotalMW is the capacity at the beginning of the year)
sort Region CEAstate year
gen NetCapacityChange = cond(Region==Region[_n+1]&CEAstate==CEAstate[_n+1]&year==year[_n+1]-1,TotalMW[_n+1]-TotalMW,.)

keep year Region CEAstate *MW NetCapacityChange HydroMW_Region
save "$intdata/Total Capacity by State and Year.dta", replace

*** Enter capacity change data 
insheet using "$InstrumentData/Capacity Addition-Deletion.csv", comma names clear case
rename BeginYear year // Note: this will be capacity change over the fiscal year beginning in `year'.
rename State CEAstate 
rename CapacityMW CapacityAddMW
merge m:1 CEAstate using "$intdata/CorrectedCEAstates.dta", keep(match master) nogen
replace CEAstate=CEAstate_corrected if CEAstate_corrected != ""
drop CEAstate_corrected

merge 1:1 Region CEAstate year using "$intdata/Total Capacity by State and Year.dta", nogen

** Fix data errors
* 405 MW capacity plant is misclassified here - it should be Central Sector
replace CapacityAddMW = 0 if CEAstate=="Arunachal Pradesh"&year==2001
replace CapacityAddMW = 405 if CEAstate=="Central Sector" & Region=="North Eastern" & year==2001

* One negative
replace CapacityAddMW = -1*CapacityAddMW if NetCapacityChange == -1*CapacityAddMW

* 1996 Capacity Add/Deletion Data are missing. Use net capacity change data there instead. This is a good approximation - the two data series line up very closely.
replace CapacityAddMW = NetCapacityChange if year==1996 


* Uttaranchal is missing CapacityAddMW in 2002 and 2004, and Chhattisgarh is missing in 2004
replace CapacityAddMW = NetCapacityChange if ((year == 2002|year==2004)&CEAstate=="Uttaranchal"&CapacityAddMW==.)
replace CapacityAddMW = NetCapacityChange if (year==2004&CEAstate=="Chhattisgarh"&CapacityAddMW==.)



* Three state splits
replace NetCapacityChange = CapacityAddMW if year == 2001 & (CEAstate=="Bihar"|CEAstate=="Uttar Pradesh"|CEAstate=="Madhya Pradesh")


* Notes: 
* Outlier negative capacity change is Assam from 2007 to 2008. They drop from 721 to 446 MW. This seems to be correct: the regional numbers also drop, and this all matches the pdfs that we have. So it looks like a plant was retired.

/*
** Make sure that total capacity difference across years = the capacity change
	* Note: this is untrue; see note at top of this do file.
	* Before 2000, there are three errors, of 10MW being added in the wrong year in the Eastern subtotal in 1991 vs. 1992, and a the third is in West Bengal in 1995, missing 10MW. Not a big deal.
gen flag = ( (CapacityAddMW>NetCapacityChange+1|CapacityAddMW<NetCapacityChange-1) & CapacityAddMW!=. & NetCapacityChange!=. )
sum flag
tab year flag
drop flag
*/

drop if CEAstate == "Sub Total"
foreach var in NetCapacityChange TotalMW CapacityAddMW {
	bysort Region year: egen `var'_Region = sum(`var') // This sums across all states within a region, plus the "Central Sector"
}

merge m:1 CEAstate using "$intdata/CEAstate_crosswalk.dta", keep(match master) nogen
drop if state=="" // This drops Central Sector

******CORRECT FOR GOA DAMAN AND DIU
drop if state=="DAMAN & DIU"
replace state = "GOA DAMAN AND DIU" if state=="GOA"
***********************************

keep year state Region NetCapacityChange TotalMW CapacityAddMW NetCapacityChange_Region TotalMW_Region HydroMW_Region CapacityAddMW_Region SteamMW HydroMW IndiaHydroMW IndiaMW

*********** Merge
save "$intdata/Capacity Instruments.dta", replace

	use "$work/shortages_base", clear
	merge 1:1 state year using "$intdata/Capacity Instruments.dta", keep(1 2 3) // keeping all here (will erase _m==2 later) because need the 1991 values of CapAdditionMW to construct CapAdd lags.
	save "$work/shortages_base", replace


*** Additional prep
local splitvars = "HydroMW_Region IndiaHydroMW IndiaMW"
include "$do/subroutines/ReplaceWithJointPreSplit.do"


*** Correct for split states. 
	* Manual checks of capacity addition for 2000 and 2001 in the new states
	replace CapacityAddMW = 0 if (year==2000|year==2001)&state=="CHHATTISGARH" // There is capacity addition in MP in those years but it is at a dam that is located in MP.
	
	* Jojobera power plant is built in 2000. It is listed in Bihar in 2000, but it is located in the eventual state of Jharkhand.
	replace CapacityAddMW = 120 if year==2000&state=="JHARKHAND"
	replace CapacityAddMW = 0 if year==2000&state=="BIHAR" 
	
	* UP has zero new capacity in 2000 or 2001
	replace CapacityAddMW = 0 if (year==2000|year==2001)&state=="UTTARANCHAL"
	
	
	
	* In 2001, make Capacity equal to end of year capacity for the split states, so that the CFs are not understated for the split years. (GWh for a year are allocated separately to the two states that split)
	sort state year
	foreach var in TotalMW HydroMW {
		replace `var' = `var'[_n+1] if year==2001&state==state[_n+1]&inlist(state,"BIHAR","MADHYA PRADESH","UTTAR PRADESH","CHHATTISGARH","JHARKHAND","UTTARANCHAL")
	}
	
/* Get sum of capacity change in last two years */
	* Use CapacityAddMW instead of NetCapacityChange because it is an explicit measure of additions and deletions. (For example, the capacity change in the split states is due to the split.)
sort state year
gen CapAdd = CapacityAddMW+CapacityAddMW[_n-1] if state==state[_n-1]
gen CapAdd0 = CapacityAddMW
gen CapAdd1 = CapacityAddMW[_n-1] if state==state[_n-1]

drop CapacityAddMW

* Need to drop the extra observations kept in the merge above.
drop if _m==2 
drop _m

save "$work/shortages_base", replace

************************************************************************************
************************************************************************************
/* ENERGY GENERATION */
/* Data check */
* Makes sure that the data line up across rows
insheet using "$InstrumentData/Energy Generation.csv", comma names clear case
replace Wind = 878.51 if Region=="Western" & BeginYear==2002 & State=="Sub Total"

foreach var in Hydro Steamcoal Diesel Wind Gas Nuclear BiomassPower BiomassGasifier UI RES {
	replace `var' = 0 if `var'==.
}

gen TotalGWhCheck = Hydro+Steamcoal+Diesel+Wind+Gas+Nuclear+BiomassPower+BiomassGasifier+UI+RES
gen flag = (TotalGWhCheck>TotalGWh+1|TotalGWhCheck<TotalGWh-1)
sum flag if EndYear<2009 //for 2009+ years, we entered in only the hydro column so the totals wont match
assert r(mean)==0 // 


/* Data Prep */
insheet using "$InstrumentData/Energy Generation.csv", comma names clear case
** Clean state names
rename State CEAstate
merge m:1 CEAstate using "$intdata/CorrectedCEAstates.dta", keep(match master) nogen
replace CEAstate=CEAstate_corrected if CEAstate_corrected != ""
drop CEAstate_corrected

** Fix data errors
replace Wind = 878.51 if Region=="Western" & BeginYear==2002 & CEAstate=="Sub Total"
replace Hydro = 8.37 if BeginYear==2007 & CEAstate=="A. & N. Islands" // This is zero in the General Review book, but the Performance of Hydro Plants microdata has this at 8.37. So this change is supported by data. Capacity in the GR book is also 5.25
*replace Hydro = . if (BeginYear==2002|BeginYear>=2008) & CEAstate=="A. & N. Islands" // This is listed as zero in GR book, but that appears to actually be missing.

************
** Data check 2: Make sure sums are correct within regions
bysort Region BeginYear: egen TotalGWh_Region_temp = sum(TotalGWh) if CEAstate!="Sub Total" // This sums across all states within a region, plus the "Central Sector"
bysort Region BeginYear: egen TotalGWh_Region = mean(TotalGWh_Region_temp) // This sums across all states within a region, plus the "Central Sector"

gen flag = ((TotalGWh_Region>TotalGWh+1000|TotalGWh_Region<TotalGWh-1000) & CEAstate=="Sub Total")
sum flag 
assert r(mean)==0 


*bysort Region BeginYear: egen maxflag = max(flag)
*sort maxf Region BeginYear 
* drop maxflag
 
drop flag TotalGWh_Region_temp TotalGWh_Region
**********

rename BeginYear year
rename Hydro HydroGWh
rename Steamcoal CoalGWh

** Get regional and India-wide stats
drop if CEAstate == "Sub Total" | (CEAstate=="Central Sector"&Region=="All India") // These are duplicates so we don't want them to enter the sums below.

bysort Region year: egen HydroGWh_Region = sum(HydroGWh) // This sums across all states within a region, plus the "Central Sector"
*bysort Region year: egen CoalGWh_Region = sum(CoalGWh)
bysort Region year: egen TotalGWh_Region = sum(TotalGWh)


gen IndiaGWh = .
forvalues year = 1985/2013 {
	sum TotalGWh if CEAstate=="All" & year==`year'
	replace IndiaGWh = r(mean) if year==`year'
}


** Merge state names
merge m:1 CEAstate using "$intdata/CEAstate_crosswalk.dta", keep(match master) nogen
drop if state=="" // This drops central sector. Regional totals must be calculated first (above).

******CORRECT FOR GOA DAMAN AND DIU
drop if state=="DAMAN & DIU"
replace state = "GOA DAMAN AND DIU" if state=="GOA"
***********************************

** Save and merge into the main file
keep year state HydroGWh HydroGWh_Region CoalGWh TotalGWh IndiaGWh  //  lnHydroGWh lnHydroGWh_Region Hydro_Inst HydroInflow_Inst Hydro_Inst_Region HydroInflow_Inst_Region 


save "$intdata/Energy Generation.dta", replace
mergebase using "$intdata/Energy Generation.dta"
	
local splitvars = "HydroGWh_Region"
include "$do/subroutines/ReplaceWithJointPreSplit.do"



/* HydroMW_bal variable */
** Generate a new HydroMW variable that is HydroMW, but adjusting for the true MW for the pre-split states
gen HydroMW_bal = HydroMW
replace HydroMW_bal = 954.15 if state=="UTTARANCHAL"&year<=2000 // The microdata HydroMW_micro show that capacity didn't change between 1992 and 2002. In the CEA state-level data, it looks like a partial transition in 2001, then full by 2002.
replace HydroMW_bal = 555.6 if state=="UTTAR PRADESH"&year<=2000

replace HydroMW_bal = 120 if state=="CHHATTISGARH"&year<=2000 // Microdata show no changes for 1992-2001.
replace HydroMW_bal = HydroMW-120 if state=="MADHYA PRADESH"&year<=2000

replace HydroMW_bal = 130 if state=="JHARKHAND"&year<=2000 // Microdata show no changes for 1992-2001.
replace HydroMW_bal = HydroMW-130 if state=="BIHAR"&year<=2000



/* Capacity Factors */
**** Actual
gen HydroCF_act = HydroGWh/HydroMW/8.760 // _act for actual
gen HydroCF_Region_act = HydroGWh_Region/HydroMW_Region/8.760 // _act for actual


**********************************************************
/* Merge Shortage Data */

merge m:1 state year using "$work\PDPM-PSP Merged.dta", keep(match master) keepusing(Shortage PeakShortage req avail pd pm) 
	
tab state if _m==1 //these state years do not have shortage data (they are either small or nonexistent as of the year observed missing)
drop _m
	
	*replace state=state_orig
	*drop state_orig 	
	
/* Get predicted avail */
include "$do/subroutines/GetPredicted.do"


** Replace Shortage variables with joint pre-split.
	* Must do this _after_ doing the predictions above

	local splitvars = "Shortage PeakShortage req avail pd pm"
	include "$do/subroutines/ReplaceWithJointPreSplit.do"
****


/* Get HydroShare */
	* This is hydro share of total consumption
	* It's not used to construct the instrument, but it is used for the graph.
bysort state: egen meanTotalEnergySold = mean(TotalEnergySold)
bysort state: egen meanTotalGWh = mean(TotalGWh)
bysort state: egen meanHydroGWh = mean(HydroGWh)
gen HydroShare = meanHydroGWh/meanTotalEnergySold 
*gen HydroShare = meanHydroGWh/meanTotalGWh 
drop meanTotalEnergySold meanTotalGWh meanHydroGWh


************************************************************************************
************************************************************************************

/* Mark Observations where states split */ 
** Generate SplitGroup variable
	* This is inserted into the fixed effect estimator to address state splits
	* Some of the GR variables split cleanly beginning 2001, but LGBR variables split in 2002 for UP/UT/BH/JK, and there is one variable (hydro I think) that doesn't split fully for Bihar/Jharkhand until 2003
gen SplitGroup = 0
replace SplitGroup = 1 if state=="MADHYA PRADESH" & year>=2001
replace SplitGroup = 2 if state=="CHHATTISGARH" & year>=2001
replace SplitGroup = 3 if state=="UTTAR PRADESH" & year>=2001
replace SplitGroup = 4 if state=="UTTARANCHAL" & year>=2001
replace SplitGroup = 5 if state=="BIHAR" & year>=2001
replace SplitGroup = 6 if state=="JHARKHAND" & year>=2001

replace SplitGroup = 11 if state=="UTTAR PRADESH" & year>=2002
replace SplitGroup = 12 if state=="UTTARANCHAL" & year>=2002
replace SplitGroup = 13 if state=="BIHAR" & year>=2002
replace SplitGroup = 14 if state=="JHARKHAND" & year>=2002

replace SplitGroup = 21 if state=="BIHAR" & year>=2003
replace SplitGroup = 22 if state=="JHARKHAND" & year>=2003



*** Split groups
levelsof SplitGroup, local(levels)
foreach g in `levels' {
	gen _G`g' = cond(SplitGroup==`g',1,0)
}
* drop the constant
drop _G0


*gen SmallState = cond(state=="ANDAMAN AND NICOBAR ISLANDS"|state=="ARUNACHAL PRADESH"|state=="CHANDIGARH"|state=="DADRA AND NAGAR HAVELI"|state=="DAMAN AND DIU"|state=="GOA" |state=="GOA DAMAN AND DIU"|state=="LAKSHADWEEP"|state=="MANIPUR"|state=="MIZORAM"|state=="NAGALAND"|state=="PONDICHERRY"|state=="SIKKIM"|state=="TRIPURA" , 1 , 0)


/* Label Variables */
label var ResInflows "Reservoir Inflows (billion cubic meters)"
label var HydroGWh "Hydro Generation (GWh)"
label var TotalGWh "Total Generation (GWh)"
label var NetCapacityChange "Net Capacity Change (MW)"
label var rain "Rainfall (meters)"
label var rainU "Rainfall (meters)"
label var HydroGWh_micro_run "Run-of-River Generation (GWh)"
label var CDD65 "Average Cooling Degrees (F)"
label var CapAdd0 "Capacity Added (MW)"
label var CapAdd1 "Capacity Added in Previous Year (MW)"
label var HydroMW "Hydro Capacity (MW)"
label var TotalMW "Total Capacity (MW)"

/* Save */
compress
sort state year

save "$work/shortages_base.dta", replace
