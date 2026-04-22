/* 5c4FE_ASI Additional Internal Robustness Checks.do */


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
log using "$logs/FE Internal Checks $date $time.log", replace



*******************************************
local i = 0
foreach LHSVar in lnProfit { 

	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
	** Drop if only one observation
	drop if NumObs==1
		
	* Only look for effects on SGS and fuels for electricity producers
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y" | "`LHSVar'"=="lnFE_Y" {
		drop if anyyearEprod == 0
	}
		
	local i = `i'+1 
			
	**** FE IV
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) first savefirst, if `LHSVar'_flag<3.5
			
			est store IntCheckFEIV`i'

		
}

/* Outreg to combined table */

	
	esttab IntCheckFEIV? using "$RegResults/IntCheckFEIV.csv", replace ///
			keep(Shortage) title(IV) se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 



