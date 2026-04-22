/* 2c1_Collapse hydro plant microdata to state level.do */


************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

*****************************************************************************

use "$work/Hydro Plant Generation Microdata.dta", replace

/* IMPUTE MISSING DATA USING RAINFALL */
** Merge rainfall data
merge 1:1 station state year using "$work/hydrobasin-year MWMeters.dta", keep(match master) nogen keepusing(_rainfall)


egen stationstate = group(station state)
gen CF_Complete = CF
gen actualgenerationmu_Complete = actualgenerationmu

levelsof stationstate, local(levels)

foreach stst in `levels' {
	display "`stst'"
	
	** Address missing data: Predict generation using rainfall
	** CF
	capture noisily reg CF _rainfall if stationstate == `stst' 
	if _rc != 2000 & _rc!=2001 {
		predict CFHat
		replace CF_Complete = CFHat if stationstate==`stst' & CF_Complete==.
		drop CFHat
	}
	
	** actualgenerationmu
	capture noisily reg actualgenerationmu _rainfall if stationstate == `stst' 
	if _rc != 2000 & _rc!=2001 {
		predict actualgenerationmuHat
		replace actualgenerationmu_Complete = actualgenerationmuHat if stationstate==`stst' & actualgenerationmu_Complete==.
		drop actualgenerationmuHat
	}
	
}




bysort station: egen meanCF=mean(CF_Complete)
g HydroCF_all_dev = CF_Complete-meanCF

g HydroCF_run_dev = HydroCF_all_dev if RunOfRiver==1
g HydroMW_micro_run = HydroMW_micro if RunOfRiver==1

gen HydroGWh_micro_all = actualgenerationmu
gen HydroGWh_micro_run = actualgenerationmu if RunOfRiver==1

gen HydroGWh_micro_all_Complete = actualgenerationmu_Complete
gen HydroGWh_micro_run_Complete = actualgenerationmu_Complete if RunOfRiver==1

* about 6% of observations are imputed.
sum actualgenerationmu_Complete actualgenerationmu 



/* GET STATE ALLOCATIONS BASED ON CONTRACTS */
*** Import state allocations
merge m:1 station using "$work/HydroStationList_withStateAllocations.dta", nogen assert(1 3) //  this assert holds


/* Allocate state shares of the projects before collapsing */
replace Pctstate1 = 100 if state1==""
replace state1 = state if state1==""

drop state
reshape long state Pctstate, i(station year xcoord ycoord) j(num) string
drop if state==""

* when collapsing to the state level, weight each dam by capacity x state share
foreach var in HydroMW_micro HydroMW_micro_run HydroGWh_micro_all HydroGWh_micro_run {
	gen Allocated`var' = `var'*(Pctstate/100)
}
* For the raw sums (not allocated) need to collapse summing only over the first observation, without the duplicate GWh and MW created by the reshape long.
foreach var in HydroMW_micro HydroMW_micro_run HydroGWh_micro_all HydroGWh_micro_run HydroGWh_micro_all_Complete HydroGWh_micro_run_Complete {
	replace `var' = . if num!="1"
}

*get allocated MW capacity
gsort station state -year
bys station state: g hydro_MW_max = AllocatedHydroMW_micro if _n==1
bys state station: egen hydro_MW_final = mean(hydro_MW_max)
drop hydro_MW_max


label var HydroMW_micro "Capacity (MW)"
label var actualgenerationmu "Generation (GWh)"
label var actualgenerationmu_Complete "Generation (GWh)"
label var CF_Complete "Capacity Factor"
label var RunOfRiver "1(Run of River)"


save "$work/Hydro Plant Generation Microdata Allocated.dta", replace




****************************

/* COLLAPSE TO STATE LEVEL */
	* Preserve missing as missing, not zero
foreach var of varlist Allocated* HydroMW_micro HydroMW_micro_run HydroGWh_micro_all HydroGWh_micro_run HydroGWh_micro_all_Complete HydroGWh_micro_run_Complete {
	gen m_`var' = missing(`var')
}
collapse (rawsum) Allocated* HydroMW_micro HydroMW_micro_run HydroGWh_micro_all HydroGWh_micro_run HydroGWh_micro_all_Complete HydroGWh_micro_run_Complete ///
	(mean) m_*  HydroCF_all_dev  HydroCF_run_dev [pweight=AllocatedHydroMW_micro], by(state year)

foreach var of varlist Allocated* HydroMW_micro HydroMW_micro_run HydroGWh_micro_all HydroGWh_micro_run HydroGWh_micro_all_Complete HydroGWh_micro_run_Complete {
	replace `var' = . if m_`var' == 1
	drop m_`var'
}

	
	
label var HydroMW_micro "Capacity (MW)"
label var HydroGWh_micro_all "Generation (GWh)"
label var HydroGWh_micro_all_Complete "Generation (GWh)"
label var HydroGWh_micro_run "Run-of-River Generation (GWh)"
label var HydroGWh_micro_run_Complete "Run-of-River Generation (GWh)"


save "$work/stateXyear_hydrogen_CFdeviations.dta", replace


/* Get run-of-river generation share and capacity by state */
use "$work/Hydro Plant Generation Microdata Allocated.dta", replace
collapse (sum) HydroGWh_micro_all HydroGWh_micro_run HydroMW_micro HydroMW_micro_run, by(state year)
collapse (mean) HydroGWh_micro_all HydroGWh_micro_run HydroMW_micro HydroMW_micro_run, by(state)
gen GWhShareRun = HydroGWh_micro_run/HydroGWh_micro_all
save "$work/State RunOfRiver Share.dta", replace


* 


	/* Graphs to check data for all states 
	 
		use "$work/stateXyear_hydrogen_CFdeviations.dta", replace
		levelsof state, local(levels)
		sort state year
		foreach state in `levels' {
			local trimname = subinstr("`state'"," ","",.)
			*local trimname = subinstr("`state'",".","",.)
			/* 
			twoway (line HydroGWh_micro_all year if state=="`state'",yaxis(1)) ///
			(line HydroGWh_micro_run year if state=="`state'",yaxis(2)), title("`state'") name("`trimname'", replace)
			 
			twoway (line HydroMW_micro year if state=="`state'",yaxis(1)) ///
			(line HydroMW_micro_run year if state=="`state'",yaxis(2)), title("`state'") name("`trimname'", replace)
			*/
			twoway (line HydroCF_all_dev year if state=="`state'",yaxis(1)) ///
			(line HydroCF_run_dev year if state=="`state'",yaxis(2)), title("`state'") name("`trimname'", replace)
			
		}
		
*/



