/* DataSection.do */
* This file gives descriptive statistics and other data checks.
************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
*************************************************
/* Descriptive Stats for state-by-year data */
*use "$work\state-level indicators 1992-2010.dta", replace
use  "$work/state-level dataset for first stages.dta", replace
** Report only for the sample used for regressions
reg Shortage Hydro_Inst if NumberofEstablishments>0
keep if e(sample)

* replace with joint state pre-split

	local splitvars = "TotalEnergySold HydroGWh HydroMW TotalMW CapAdd0 CapAdd1"
	include "$do/subroutines/ReplaceWithJointPreSplit.do"



gen HydroTWh = HydroGWh/1000
label var HydroTWh "Hydro Generation (TWh)"
gen reqTWh = req/1000
label var reqTWh "Assessed Demand (TWh)"
gen availTWh = avail/1000
label var availTWh "Energy Available (TWh)"
gen TotalEnergySoldTWh = TotalEnergySold/1000
label var TotalEnergySoldTWh "Total Electricity Sold (TWh)
replace ResInflows_Complete = 0 if ResInflows_Complete==.
replace HydroGWh_micro_run_Complete = 0 if HydroGWh_micro_run_Complete == .
gen HydroTWh_micro_run_Complete = HydroGWh_micro_run_Complete/1000
label var HydroTWh_micro_run_Complete "Run-of-River Generation (TWh)"

global SumVarList = "rainU CDD65 reqTWh availTWh Shortage PeakShortage TotalEnergySoldTWh HydroTWh HydroMW TotalMW ResInflows_Complete HydroTWh_micro_run_Complete CapAdd1"
sum $SumVarList
describe $SumVarList

eststo clear
estpost sum $SumVarList 
esttab .,  cells("mean sd min max count") noobs label
esttab . using "$analyses/StateSummaryStats.csv",  cells("mean sd min max count") noobs label replace


* Calculate R2
reg Shortage PeakShortage


* Get growth rates (growth by a factor of 2.9 from 1992 to 2010) 
use "$work\PDPM-PSP Merged.dta", replace
collapse (sum) avail req, by(year)
*twoway line (avail req year)
sum req avail if year==1992|year==2010


***************************************************************************
/* DESCRIPTIVE STATS FOR RESERVOIR AND HYDRO GENERATION MICRODATA */
/* Reservoir Microdata */
use "$work/ResInflowsandGWh.dta", replace

** Statements in text
tab year
sum RecentResCapMW if year==2010
display r(sum)
display r(sum)/36918.42 // 36918.42 is the total capacity as of March 31, 2010, from 2012 GR page 33.

bysort ResScheme: gen NumObs = _N
replace NumObs = . if ResScheme==ResScheme[_n-1]

label var NumObs "Reservoir Years Observed"

global SumVarList = "NumObs ResInflows ResGWh RecentResCapMW PredResCF" // ResRainfall
sum $SumVarList
describe $SumVarList

eststo clear
estpost sum $SumVarList 
esttab .,  cells("mean sd min max count") noobs label
esttab . using "$analyses/ReservoirSummaryStats.csv",  cells("mean sd min max count") noobs label replace



/* Hydro Plant Generation Microdata */
use "$work/Hydro Plant Generation Microdata.dta", replace

bysort station: gen NumObs = _N
replace NumObs = . if station==station[_n-1]
replace RunOfRiver = . if station==station[_n-1]

label var NumObs "Plant Years Observed"
label var RunOfRiver "Run-of-River Plant"
label var actualgenerationmu "Generation (GWh)"
label var HydroMW_micro "Capacity (MW)"
label var CF "Capacity Factor"

** Descriptive stats
global SumVarList = "NumObs RunOfRiver actualgenerationmu HydroMW_micro CF"
sum $SumVarList
describe $SumVarList

eststo clear
estpost sum $SumVarList 
esttab .,  cells("mean sd min max count") noobs label
esttab . using "$analyses/HydroMicrodataSummaryStats.csv",  cells("mean sd min max count") noobs label replace






*************************************************************************
***********************************************************************

/* ASI */
/* Generator ownership compared to WBES */

use "$work/WBES2005.dta", clear
sum OwnGenerator

sum OwnGenerator if Large==1
sum OwnGenerator if Large==0


use "$intdata/ASIpanel for ASI Regressions.dta", clear
sum anyyearEprod [aweight=mult] if year==2005

sum anyyearEprod [aweight=mult] if year==2005 & totp<100
sum anyyearEprod [aweight=mult] if year==2005 & totp>=100

***************************************************************************

/* Descriptive Stats for ASI */

use "$intdata/ASIpanel for ASI Regressions.dta", clear

bys panelgroup: g NPlantObs=_N
replace NPlantObs = . if panelgroup==panelgroup[_n-1]


foreach var in grsale_defl fcapclose_defl labcost_defl matls_defl fuelelec_defl fuels_defl velecpur_defl qeleccons qelecpur qelecprod {
	replace `var' = `var'/10^6
}
label var grsale_defl "Revenues (million Rupees)"
label var fcapclose_defl "Capital Stock (million Rupees)"
label var totpersons "Number of Employees"
label var labcost_defl "Labor Cost (million Rupees)"
label var matls_defl "Materials Purchased (million Rupees)"
label var fuels_defl "Fuels Purchased (million Rupees)"
label var fuelelec_defl "Energy Purchased (million Rupees)"
label var velecpur_defl "Electricity Purchased (million Rupees)"
label var qeleccons "Electricity Consumed (GWh)"
label var qelecpur "Electricity Purchased (GWh)"
label var qelecprod "Electricity Self-Generated (GWh)"
label var SGS "Self-Generation Share"
label var F_Y "Fuel Revenue Share"
label var FE_Y "Energy Revenue Share"
label var lambda "Electric Intensity (kWh/Rs)"
label var scheme_final "1(Census Scheme)"
label var NPlantObs "Plant Number of Observations"


/* Implement flags */
replace grsale_defl = . if lnY_flag >= 3.5
replace totpersons = . if lnL_flag >= 3.5
replace labcost_defl = . if lnlabcost_defl_flag >= 3.5
replace matls_defl = . if lnM_flag >= 3.5
replace fuels_defl = . if lnF_flag >= 3.5
replace fuelelec_defl = . if lnFE_flag >= 3.5
replace qeleccons = . if lnE_flag >= 3.5
replace qelecpur = . if lnqelecpur_flag >= 3.5
replace qelecprod = . if lnqelecprod_flag >= 3.5
replace SGS = . if SGS_flag >= 3.5
replace FE_Y = . if lnFE_flag >= 3.5
replace F_Y = . if lnF_flag >= 3.5
replace lambda = . if lambda_flag >= 3.5

global SumVarList = "NPlantObs grsale_defl fcapclose_defl totpersons labcost_defl matls_defl fuels_defl velecpur_defl qelecpur qelecprod qeleccons anyyearEprod SGS F_Y lambda scheme_final"


eststo clear
estpost sum $SumVarList [aw=mult]
esttab .,  cells("mean sd min max count") noobs label
esttab . using "$analyses/ASISummaryStats.csv",  cells("mean sd min max count") noobs label replace

sum scheme_final NPlantObs

** Descriptive stats for data
sum grsale_defl, detail
sum totpersons, detail
tab NPlantObs

sum lambda
display r(mean)*4.5

* 60 percent of intervals are one year, while 91 percent are five years or less:
tab dyear




