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
log using "$logs/ASIRegressionsLog $date $time.log", replace

include "$do/Subroutines/DefineGlobals.do"


***********************************************************
***********************************************************

local i = 0
foreach LHSVar in SGS lnF_Y lnFE_Y lnlambda lnM lnL lnWage lnY lnW {

	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
	* Only look for effects on SGS and fuels for electricity producers!
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y"| "`LHSVar'"=="lnFE_Y" { // | "`LHSVar'"=="lnlambda" 
		drop if anyyearEprod == 0
	}
	
	local i = `i'+1
	**** OLS
		* Need to use ivreg2 because cluster2 doesn't allow weights
	ivreg2 d`LHSVar' dShortage $dRainfallBins dCDD65 _DY* _DS* _DN* _dG* [pweight=Weight], cluster($ClusterVars), /// _DY _DN
		if `LHSVar'_flag<3.5&l`LHSVar'_flag<3.5
		
		est store BaseOLS`i'
	
	**** IV 
	ivreg2 d`LHSVar' (dShortage = d$Inst) $dRainfallBins dCDD65 _DY* _DS* _DN* _dG* [pweight=Weight], ///
		cluster($ClusterVars) first savefirst, if `LHSVar'_flag<3.5&l`LHSVar'_flag<3.5		

		est store BaseIV`i'
	
	* Store first stage	
	est restore _ivreg2_dShortage
		est store Base1st`i'
	
	
	

}

/* Outreg to combined table */
	esttab BaseOLS? using "$RegResults/BaseOLS.csv", replace ///
			keep(dShortage) title(OLS) se scalars(N_clust N_clust2) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	
	esttab BaseIV? using "$RegResults/BaseIV.csv", replace ///
			keep(dShortage) title(IV) se scalars(N_clust N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	
	esttab Base1st? using "$RegResults/Base1st.csv", replace ///
			keep(d$Inst) title(1st) se scalars(N_clust N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	



log close
*

