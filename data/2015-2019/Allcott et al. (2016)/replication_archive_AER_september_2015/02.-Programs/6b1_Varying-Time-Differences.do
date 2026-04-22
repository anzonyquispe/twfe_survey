/* 5c1_ASI Alternative Specs.do */
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
log using "$logs/Varying Time Differences Log $date $time.log", replace

global first = "first savefirst" //
*global first = "" // determines if the first stage is run

************************************************************************


/* ROBUSTNESS CHECKS FOR MAIN TABLE */	

foreach LHSVar in SGS lnF_Y lnFE_Y lnlambda lnM lnL lnWage lnY lnW { 
	
	local i = 0
	
	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	* Only look for effects on SGS and fuels for electricity producers!
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y" | "`LHSVar'"=="lnFE_Y" { // | "`LHSVar'"=="lnlambda" {
		drop if anyyearEprod == 0
	}
	
	** All
	ivreg2 d`LHSVar' (dShortage = d$Inst) $dRainfallBins dCDD65 _DY* _DS* _DN* _dG* [pweight=Weight], ///
		cluster($ClusterVars) $first, if `LHSVar'_flag<3.5&l`LHSVar'_flag<3.5		
		local i = `i'+1
		est store `LHSVar'`i'
		
	** dyear==1
	ivreg2 d`LHSVar' (dShortage = d$Inst) $dRainfallBins dCDD65 _DY* _DS* _DN* _dG* [pweight=Weight], ///
		cluster($ClusterVars) $first, if `LHSVar'_flag<3.5&l`LHSVar'_flag<3.5&dyear==1	
		local i = `i'+1
		est store `LHSVar'`i'
		
	** dyear==2 or 3
	ivreg2 d`LHSVar' (dShortage = d$Inst) $dRainfallBins dCDD65 _DY* _DS* _DN* _dG* [pweight=Weight], ///
		cluster($ClusterVars) $first, if `LHSVar'_flag<3.5&l`LHSVar'_flag<3.5&(dyear==2|dyear==3)	
		local i = `i'+1
		est store `LHSVar'`i'
		
	** dyear>=4
	ivreg2 d`LHSVar' (dShortage = d$Inst) $dRainfallBins dCDD65 _DY* _DS* _DN* _dG* [pweight=Weight], ///
		cluster($ClusterVars) $first, if `LHSVar'_flag<3.5&l`LHSVar'_flag<3.5&dyear>=4&dyear!=.
		local i = `i'+1
		est store `LHSVar'`i'
			
			
	/* Outreg to combined table */
	if "`LHSVar'" == "SGS" { // start new table
	esttab `LHSVar'? using "$RegResults/TimeDiff.csv", replace ///
			keep(dShortage) title(`LHSVar') se scalars(N_clust N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
	else { // append to previous table
		esttab `LHSVar'? using "$RegResults/TimeDiff.csv", append ///
			keep(dShortage) title(`LHSVar') se scalars(N_clust N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
		
}


log close
*
