/* 5cFE_ASI Regressions.do */
* This file tests first stages, then FE and FEIV estimates for the ASI Regressions

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************

clear
clear matrix
clear mata
set matsize 800
set maxvar 20000

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"


include "$do/Subroutines/DefineGlobals.do"

capture log close
log using "$logs/ASIFixedEffectsRegressions $date $time.log", replace


*******************************************
local i = 0
foreach LHSVar in SGS lnF_Y lnFE_Y lnlambda lnM lnL lnWage lnY lnW { 

	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
	** Drop if only one observation
	drop if NumObs==1
		
	* Only look for effects on SGS and fuels for electricity producers
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y" | "`LHSVar'"=="lnFE_Y" {
		drop if anyyearEprod == 0
	}
		
	local i = `i'+1 
	
	**** Fixed Effects OLS
		* Need to use xtivreg2 because xtreg doesn't allow weights to vary within panelgroup
			* Note: _S* gets dropped, as we should expect.
	xtivreg2 `LHSVar' Shortage $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) ffirst, if `LHSVar'_flag<3.5
			
			est store BaseFEOLS`i'

			
	**** FE IV
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) first savefirst, if `LHSVar'_flag<3.5
			
			est store BaseFEIV`i'
		
		
	* Store first stage
	est restore _xtivreg2_Shortage

		est store BaseFE1st`i'
		
}

/* Outreg to combined table */
	esttab BaseFEOLS? using "$RegResults/BaseFEOLS.csv", replace ///
			keep(Shortage) title(OLS) se scalars(N_clust1 N_clust2) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	
	esttab BaseFEIV? using "$RegResults/BaseFEIV.csv", replace ///
			keep(Shortage) title(IV) se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	
	esttab BaseFE1st? using "$RegResults/BaseFE1st.csv", replace ///
			keep($Inst) title(1st) se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	



log close 

*
