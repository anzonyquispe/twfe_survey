/* Long-Run Effects.do */

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************

clear
clear matrix
clear programs
clear mata
set matsize 8000
set maxvar 20000

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
include "$do/Subroutines/DefineGlobals.do"


capture log close

log using "$logs/Long-Run Effects $date $time.log", replace



*******************************************************************************
*******************************************************************************

/* DATA PREP */
/* Data prep */
use "$intdata/ASIpanel for ASI Regressions.dta", clear

*gen lambda_dev = medianlambda - snicmedlambda if lambda_flag<3.5
*gen E_M_dev = E_M - snicmedE_M if E_M_flag<3.5 // Note: lambda_dev and E_M_dev are highly correlated but very low R2.
*gen E_K_dev = E_K - snicmedE_K if E_K_flag<3.5

keep if inityr>=1992&inityr<=2010

* Rescaling
replace sniclambda = sniclambda*100
gen lnsniclambda = ln(sniclambda)

foreach var in lnK lnL lnM lnY lnW {
	replace `var' = . if `var'_flag>=3.5 // >0
}

foreach j in K L M {
	gen ln`j'_Y = ln`j' - lnY
}

foreach var in K L M {
	gen `var' = exp(ln`var')
}
gen Y = exp(lnY)

** Collapse to the plant level 
	* Note: taking ln then collapsing is helpful relative to collapsing the mean inputs, then taking ln. The reason is because it keeps us from overweighting observations towards outlying years. And when we collapse to the state level, it helps us to avoid weighting large plants too heavily. Plus this also helps so that the collapsed state-level regression has the mean of the outcome variable.
collapse (mean) K L M Y Shortage lnK lnK_Y lnL_Y lnM_Y  /// (median) medlambda_dev=lambda_dev medE_M_dev=E_M_dev medE_K_dev=E_K_dev medlnK = lnK medlnL = lnL medlnW = lnW 
	(first) betak_matls_fuels_noSG Rs_kWh_median anyyearEprod lnsniclambda sniclambda sniclnK state mult statenum inityr InitYrShortage LInitYrShortage snic, by(panelgroup) // 

gen lnmY = ln(Y)
foreach var in K L M {
	gen lnm`var' = ln(`var')
	gen lnm`var'_Y = lnm`var' - lnmY
}


*****************
** Get split groups
	* Notice that these are different than for the main estimates. Need to deal with the fact that there
		* is a one-year lag in the Shortage measure. Remember that for Shortage, MP/CH split in 2001, while the other two split beginning in 2002.

	rename inityr year		
gen SplitGroup = 0
replace SplitGroup = 1 if state=="MADHYA PRADESH" & year>=2001
replace SplitGroup = 2 if state=="CHHATTISGARH" & year>=2001

replace SplitGroup = 11 if state=="UTTAR PRADESH" & year>=2002
replace SplitGroup = 12 if state=="UTTARANCHAL" & year>=2002
replace SplitGroup = 13 if state=="BIHAR" & year>=2002
replace SplitGroup = 14 if state=="JHARKHAND" & year>=2002
replace SplitGroup = 15 if state=="MADHYA PRADESH" & year>=2002
replace SplitGroup = 16 if state=="CHHATTISGARH" & year>=2002


replace SplitGroup = 21 if state=="BIHAR" & year>=2003
replace SplitGroup = 22 if state=="JHARKHAND" & year>=2003
replace SplitGroup = 23 if state=="UTTAR PRADESH" & year>=2003
replace SplitGroup = 24 if state=="UTTARANCHAL" & year>=2003

*** Split groups
levelsof SplitGroup, local(levels)
foreach g in `levels' {
	gen _G`g' = cond(SplitGroup==`g',1,0)
}
* drop the constant
drop _G0

	rename year inityr
**************
egen snicxinityr = group(snic inityr)
label var LInitYrShortage "Shortage at Entry"
	
save "$intdata/Plant-Level ASI.dta", replace

** Collapse to the state-by-inityr level
collapse (mean) anyyearEprod betak_matls_fuels_noSG lnsniclambda sniclambda sniclnK ///
	lnK lnK_Y lnL_Y lnM_Y lnmK lnmK_Y lnmL_Y lnmM_Y /// lambda_dev E_M_dev E_K_dev lnK lnL (median) stmed_lambda_dev = lambda_dev stmed_E_M_dev = E_M_dev stmed_E_K_dev = E_K_dev stmed_lnK=lnK stmed_lnL=lnL stmed_sniclambda=sniclambda ///
	(first) InitYrShortage LInitYrShortage Rs_kWh_median statenum SplitGroup _G* ///
	(rawsum) NumberofEstablishments = mult [pw=mult], by(state inityr)


label var LInitYrShortage "Shortage at Entry"

gen one = 1
xtset statenum inityr
save "$intdata/State-by-InitYr ASI.dta", replace

***********************************

/* REGRESSIONS */
outreg, clear(LongRunEffects)
outreg, clear(LongRunEffects1)
outreg, clear(LREffectsPlantLevel)
outreg, clear(LREffectsPlantLevel1)


local i = 0
foreach var in sniclambda anyyearEprod lnmK_Y lnmL_Y lnmM_Y { // betak_matls_fuels_noSG lnK sniclnK  lnK_Y lnL_Y lnM_Y lnK lnmK
				* Note: using mean of logs within plant (which is the lnK_Y, lnL_Y, and lnM_Y variables) gives the same result.
			
	/* State-by-year level regressions */
	use "$intdata/State-by-InitYr ASI.dta", replace
	global Wt = "Num"
	
	* Controlling for state
	*areg `var' LInitYrShortage i.statenum _G* [pw=$Wt], absorb(inityr) robust cluster(state)
	xi: newey2 `var' LInitYrShortage i.statenum i.inityr _G* [aw=$Wt], lag(5) force
		
		outreg, merge(LongRunEffects) se replace varlabels tex fragment starlevels(10 5 1) ///
		summstat(N) summtitles("Number of Obs.") ///
		keep(LInitYrShortage)
	
	* Without controlling for state
	*areg `var' LInitYrShortage _G* [pw=$Wt], absorb(inityr) robust cluster(state)
	xi: newey2 `var' LInitYrShortage i.inityr _G* [aw=$Wt], lag(5) force
		
		outreg, merge(LongRunEffects1) se replace varlabels tex fragment starlevels(10 5 1) ///
		summstat(N) summtitles("Number of Obs.") ///
		keep(LInitYrShortage)

	local i = `i'+1
	sum `var' if e(sample) [aw=$Wt]
	local mean`i'=round(r(mean),0.01)
	
	/* Plant-level regressions */
	use "$intdata/Plant-Level ASI.dta", replace
	keep if inityr>=1992
	
	* Control for snic only when not looking at sniclambda
	if "`var'" == "sniclambda"|"`var'" == "snicalpha_K"|"`var'" == "sniclnK" {
		local absorb = "inityr"
	}
	else {
		local absorb = "snicxinityr"
	}
	* Controlling for state
	areg `var' LInitYrShortage i.statenum _G* [pw=mult], absorb(`absorb') robust cluster(state)
		
		outreg, merge(LREffectsPlantLevel) se replace varlabels tex fragment starlevels(10 5 1) ///
		summstat(N) summtitles("Number of Obs.") ///
		keep(LInitYrShortage)
	
	* Without controlling for state
	areg `var' LInitYrShortage _G* [pw=mult], absorb(`absorb') robust cluster(state)
		
		outreg, merge(LREffectsPlantLevel1) se replace varlabels tex fragment starlevels(10 5 1) ///
		summstat(N) summtitles("Number of Obs.") ///
		keep(LInitYrShortage)
	
	
}

foreach spec in LongRunEffects LongRunEffects1 { 
	outreg using "$RegResults/`spec'", replay(`spec') replace tex fragment ///
		summstat(N) summtitles("Number of Obs.") ///
		ctitles("","(1)","(2)","(3)","(4)","(5)"  \ ///
		"","Ind. Elec/","1(Self","ln(Capital/","ln(Labor/","ln(Matls/" \ ///
		"Dependent Variable:","Rev","Gen)","Rev)","Rev)","Rev)") /// addrows("Dependent Var. Mean","`mean1'","`mean2'","`mean3'","`mean4'","`mean5'") //
			hlines(1101{0}1)
}

foreach spec in LREffectsPlantLevel LREffectsPlantLevel1 {
	outreg using "$RegResults/`spec'", replay(`spec') replace tex fragment ///
		summstat(N) summtitles("Number of Obs.") ///
		ctitles("","(1)","(2)","(3)","(4)","(5)"  \ ///
		"","Ind. Elec/","1(Self","ln(Capital/","ln(Labor/","ln(Matls/" \ ///
		"Dependent Variable:","Rev","Gen)","Rev)","Rev)","Rev)") /// addrows("Dependent Var. Mean","`mean1'","`mean2'","`mean3'","`mean4'","`mean5'") //
		addrows("Industry-by-year controls","No","Yes","Yes","Yes","Yes") ///
			hlines(1101{0}1)
}





* 
** Show that the effect on capital share is stronger for plants without generators.
areg lnmK_Y LInitYrShortage i.statenum _G* [pw=mult], absorb(snicxinityr) robust cluster(state)
areg lnmK_Y LInitYrShortage i.statenum _G* [pw=mult], absorb(snicxinityr) robust cluster(state), if anyyearEprod==1
areg lnmK_Y LInitYrShortage i.statenum _G* [pw=mult], absorb(snicxinityr) robust cluster(state), if anyyearEprod==0

** Effect on sniclambda: 
areg sniclambda LInitYrShortage i.statenum _G* [pw=mult], absorb(inityr) robust cluster(state)
areg sniclambda LInitYrShortage i.statenum _G* [pw=mult], absorb(inityr) robust cluster(state), if anyyearEprod==1
areg sniclambda LInitYrShortage i.statenum _G* [pw=mult], absorb(inityr) robust cluster(state), if anyyearEprod==0

areg lnmK_Y anyyearEprod i.statenum _G* [pw=mult], absorb(inityr) robust cluster(state)
areg lnmL_Y anyyearEprod i.statenum _G* [pw=mult], absorb(inityr) robust cluster(state)
areg lnmM_Y anyyearEprod i.statenum _G* [pw=mult], absorb(inityr) robust cluster(state)

log close   
	*********************************************************************
	/* old graphs
	/* DATA PREP */
** Get state mean: Shortage
use "$work\PDPM-PSP Merged.dta", clear
keep if year>=1992&year<=2010
collapse (mean) Shortage,by(state)
save "$work/MeanShortage.dta", replace


** Get state means: electricity price and SGS
use "$intdata/ASIpanel for ASI Regressions.dta", clear
gen SGS_gen = cond(SGS!=0,SGS,.)
gen lambda_dev = medianlambda - snicmedlambda if lambda_flag<3.5
gen NumberofEstablishments = 1
collapse (median) statemedianRs_kWh = Rs_kWh_it (sum) NumberofEstablishments ///
	(mean) lambda SGS SGS_gen anyyearEprod lambda_dev sniclambda [pweight=mult], by(state)

* Rescaling
replace lambda_dev = lambda_dev*100
replace sniclambda = sniclambda*100

	
save "$work/stateMeans.dta", replace


merge 1:1 state using "$work/MeanShortage.dta", nogen keep(1 3)

save "$work/State-Level Long-Run Dataset.dta", replace


***************************************************

/* Graphs */
graph drop _all
use "$work/State-Level Long-Run Dataset.dta", replace
foreach var in SGS_gen anyyearEprod lambda_dev sniclambda {
	capture erase `var'.gph
	if "`var'" == "SGS_gen" {
		local ytitle = "Self-Generation Share|Self-Generator"
		local title = "Panel A: Self-Generation"
	}
	if "`var'" == "anyyearEprod" {
		local ytitle = "Share Self-Generators"
		local title = "Panel B: Generator Ownership"
	}
	if "`var'" == "lambda_dev" {
		local ytitle = "Difference from Industry Elec/Rev"
		local title = "Panel C: Plant Electric Intensity"
	}
	if "`var'" == "sniclambda" {
		local ytitle = "Industry Elec/Rev"
		local title = "Panel D: Industry Electric Intensity"
	}

	graph twoway (scatter `var' Shortage), ///
	graphregion(color(white) lwidth(medium)) legend(off) ///
	xtitle("State Average Shortage") ytitle("`ytitle'") title("`title'") /// ytitle("`ytitle'") ///
	saving(`var') 
}

graph combine SGS_gen.gph anyyearEprod.gph lambda_dev.gph sniclambda.gph, ///
	graphregion(color(white)) // title("Associations with State Average Shortage")
graph export "$analyses/AssociationswithStateAverageShortage.pdf", as(pdf) replace


/* Regressions */
	* Could weight by NumberofEstablishments but reduces power and is also not reflected in the graph.
reg SGS_gen Shortage, robust
*reg SGS_gen Shortage [pw=Num], robust

/* Generator Adoption by State */
reg anyyearEprod Shortage, robust
*reg anyyearEprod Shortage [pweight=Num], robust


/* Plant electric intensity */
reg lambda_dev Shortage, robust
*reg lambda_dev Shortage [pweight=Num], robust


/* Industry electric intensity */
	* statemedianRs_kWh
reg sniclambda Shortage, robust
*reg sniclambda Shortage [pweight=Num], robust



	 

	 *****************************************************************

/* old stuff on generator adoption

use "$intdata/Plant-Level ASI.dta", replace


** Within industries, the larger and more productive firms are more likely to adopt generators
areg anyyearEprod medlambda_dev medlnK medlnW [pw=mult], robust absorb(snic)

** Across industries, generator adoption rates are lower for electricity-intensive industries
reg anyyearEprod sniclambda medlambda_dev medlnK medlnW [pw=mult], robust cluster(snic)

** Across states, shortages and electricity prices don't explain much of generator adoption - they are not correlated with anyyearEprod and explain much less than productivity and industry electric intensity
reg anyyearEprod  InitYrShortage Rs_kWh_m [pw=mult], robust cluster(statenum)
reg anyyearEprod sniclambda medlambda_dev medlnK medlnW InitYrShortage Rs_kWh_m [pw=mult], robust cluster(statenum)




/* OLD
/* Compare factor shares in high- vs. low- shortage states */
include "$do/Subroutines/DefineGlobals.do"
use "$intdata/ASIpanel for ASI Regressions.dta", clear

	** Drop if only one observation
	* drop if NumObs==1 // Not needed because we aren't using fixed effects.

foreach j in K L M {
	gen ln`j'_Y = ln`j' - lnY
	gen ln`j'_Y_flag = ln`j'_flag+lnY_flag
}

foreach LHSVar in lnK_Y lnL_Y lnM_Y lnlambda {
		local i = 0
	
	** Short-run effects
	*ivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _S* _Y* _G* _N* _R* [pweight=Weight], /// 
	*	cluster(statenum) first savefirst, if `LHSVar'_flag<3.5
	*	local i = `i'+1
	*	est store `LHSVar'`i'
	
	** Long-run effects without controlling for current shortage or state
	reg `LHSVar' InitYrShortage $RainfallBins CDD65 _Y* _G* _N* [pweight=Weight], /// 
		robust cluster(statenum), if `LHSVar'_flag<3.5
		
		local i = `i'+1
		est store `LHSVar'`i'
	
	** Long-run effects without controlling for current shortage but controlling for state
	reg `LHSVar' InitYrShortage $RainfallBins CDD65 _S* _Y* _G* _N* [pweight=Weight], /// 
		robust cluster(statenum), if `LHSVar'_flag<3.5
		
		local i = `i'+1
		est store `LHSVar'`i'
		
	** Same but using only post-1992 (where InitYrShortage is observed)
	reg `LHSVar' InitYrShortage $RainfallBins CDD65 _S* _Y* _G* _N* [pweight=Weight], /// 
		robust cluster(statenum), if `LHSVar'_flag<3.5 & inityr>=1992

		local i = `i'+1
		est store `LHSVar'`i'

		
	** Long-run effects controlling for current shortage
		* This includes state fixed effects but not state trends because they are not needed here because there is no instrument.
	reg `LHSVar' InitYrShortage Shortage $RainfallBins CDD65 _S* _Y* _G* _N* [pweight=Weight], /// 
		robust cluster(statenum), if `LHSVar'_flag<3.5

		local i = `i'+1
		est store `LHSVar'`i'

		
	** Long-run effects instrumenting for current shortage
	ivreg2 `LHSVar' InitYrShortage (Shortage = $Inst) $RainfallBins CDD65 _S* _Y* _G* _N* _R* [pweight=Weight], /// 
		robust cluster(statenum) first savefirst, if `LHSVar'_flag<3.5

		local i = `i'+1
		est store `LHSVar'`i'

	/* esttab to combined table */
	if "`LHSVar'" == "lnK_Y" { // start new table
	esttab `LHSVar'? using "$RegResults/FactorShareEffects.csv", replace ///
			keep(InitYrShortage Shortage) title(`LHSVar') se scalars(N_clust widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
	else { // append to previous table
		esttab `LHSVar'? using "$RegResults/FactorShareEffects.csv", append ///
			keep(InitYrShortage Shortage) title(`LHSVar') se scalars(N_clust widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
}



