/* 5c2_ASI Alternative Instruments.do */

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



capture log close
log using "$logs/ASI FE Alternative Instruments Log $date $time.log", replace

include "$do/Subroutines/DefineGlobals.do"
***********************************************************************
global InstrumentstoTest = "Hydro_Inst_Pcon C1Hydro_InstC_rr C1Hydro_Inst_Pcon"


/* WITH SHORTAGE AS THE ENDOGENOUS VARIABLE */	
foreach LHSVar in SGS lnF_Y lnFE_Y lnlambda lnM lnL lnWage lnY lnW { // 

	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
		** Drop if only one observation
		drop if NumObs==1
	
	* Only look for effects on SGS and fuels for electricity producers!
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y" | "`LHSVar'"=="lnFE_Y" {
		drop if anyyearEprod == 0
	}
	
	local i = 0
	
	foreach Inst in $InstrumentstoTest { 
		local i = `i'+1

		**
		xtivreg2 `LHSVar' (Shortage = `Inst') $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
			fe cluster($FEClusterVars) first savefirst, if `LHSVar'_flag<3.5
	
		est store `LHSVar'`i'	
		
	}
		
	
			
		/* Outreg to combined table */
		if "`LHSVar'" == "SGS" { // start new table
		esttab `LHSVar'? using "$RegResults/AltInstFE.csv", replace ///
				keep(Shortage) title(`LHSVar') se scalars(N_clust1 N_clust2 widstat) ///
				nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps
		}
		else { // append to previous table
			esttab `LHSVar'? using "$RegResults/AltInstFE.csv", append ///
				keep(Shortage) title(`LHSVar') se scalars(N_clust1 N_clust2 widstat) ///
				nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps
		}


}


log close



*
