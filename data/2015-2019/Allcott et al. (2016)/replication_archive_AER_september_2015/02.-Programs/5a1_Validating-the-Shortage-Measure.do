/* 6c_Validating the Shortage Measure.do */
* Sampling methodology: http://www.enterprisesurveys.org/~/media/FPDKM/EnterpriseSurveys/Documents/Methodology/Sampling_Note.pdf
* Questions: http://www.enterprisesurveys.org/nada/index.php/catalog/444/datafile/F1/?offset=100&limit=100

* Note: average duration of cut appears to be sometimes reported in minutes and other times reported in hours. Don't use this, and thus don't use the TotalCutHours variable.

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************

outreg,clear
local size = "small"

/* Cross-sectional correlations: WBES */
use "$work/WBES2005.dta", clear
replace SGS=SGS/100 // To get in units common with ASI.
reg ElectricityTopGrowthProblem Shortage _I* , robust cluster(state)
	outreg using "$RegResults/ShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) ///
		keep(Shortage) summstat(N) 
	sum ElectricityTopGrowthProblem if e(sample)
	local mean1 = round(r(mean),0.01)

reg QualityofPower Shortage _I* , robust cluster(state)
	outreg using "$RegResults/ShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) ///
	keep(Shortage) summstat(N)
	sum QualityofPower if e(sample)
	local mean2 = round(r(mean),0.01)
	
reg SGS Shortage _I* , robust cluster(state), if OwnGenerator==1
	outreg using "$RegResults/ShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) ///
	keep(Shortage) summstat(N)
	
	sum QualityofPower if e(sample)
	local mean3 = round(r(mean),0.1)


*** Confirm that the standard errors are similar when collapsing data to the state level.
replace SGS=. if OwnGenerator!=1
collapse (first) Shortage (mean) ElectricityTopGrowthProblem SGS QualityofPower, by(state)

reg ElectricityTopGrowthProblem Shortage, robust
reg QualityofPower Shortage, robust
reg SGS Shortage, robust
	
/* COAL PLANT UTILIZATION RATES */
use "$work/UtilizationRatesMicrodata.dta", replace
encode name, gen(PlantID)
rename state stateLocation
rename OriginalState state
*merge m:1 state year using "$work\PDPM-PSP Merged.dta", keepusing(req avail shortageMU Shortage pd pm shortagePDPM PeakShortage) keep(match master) 
merge m:1 state year using "$work\state-level indicators 1992-2010.dta", keepusing(Shortage SplitGroup) keep(match master) 

encode state, gen(statenum)
gen cf = gen/cap/8.760

areg cf Shortage i.year i.SplitGroup, absorb(PlantID) robust cluster(statenum)
	outreg using "$RegResults/ShortageCorrelations", se replace merge varlabels tex fragment starlevels(10 5 1) ///
	keep(Shortage) summstat(N)
	
	sum cf if e(sample)
	local mean4 = round(r(mean),0.01)
	
	
	
	outreg using "$RegResults/ShortageCorrelations", replay replace tex fragment ///
		summstat(N) summtitles("Number of Obs.") ///
		ctitles("","(1)","(2)","(3)","(4)" \ "","1(Largest","Power","Self-Gen","Capacity" \ ///
			"","Barrier)","Quality","Share","Factor") ///
			addrows("Dependent Var. Mean","`mean1'","`mean2'","`mean3'","`mean4'" \ ///
			"Sample","WBES","WBES","WBES","Coal" \ ///
			"","Firms","Firms","Firms","Plants") ///
			hlines(1101{0}1) statfont(`size')
