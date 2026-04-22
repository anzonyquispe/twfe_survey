/* 5c3_ASI Weather Specs.do */
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
log using "$logs/ASI FE Regressions Alt Weather Log $date $time.log", replace

global first = "first savefirst" //
*global first = "" // determines if the first stage is run

************************************************************************





/* ROBUSTNESS CHECKS FOR WEATHER CONTROLS */	
foreach LHSVar in SGS lnF_Y lnFE_Y lnlambda lnM lnL lnWage lnY lnW {
	
	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
	** Drop if only one observation
	drop if NumObs==1
	
	* Only look for effects on SGS and fuels for electricity producers!
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y" | "`LHSVar'"=="lnFE_Y" { // | "`LHSVar'"=="lnlambda" {
		drop if anyyearEprod == 0
	}
	
	local i = 1

	** Not controlling for rainfall or CDD
	xtivreg2 `LHSVar' (Shortage = $Inst) _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5

			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'	
		

	local i = `i'+1
	** Controlling for rainfall bins but not CDD
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5

			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'
			
		
	local i = `i'+1
	** Linear rainfall controls
	xtivreg2 `LHSVar' (Shortage = $Inst) rainU CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5

			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'
			
		
	local i = `i'+1	
	** Natural log rainfall controls
	xtivreg2 `LHSVar' (Shortage = $Inst) lnrainU CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5

			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'

	
	local i = `i'+1	
	** Linear above/below mean controls for rainfall
	xtivreg2 `LHSVar' (Shortage = $Inst) PD_rainU ND_rainU AboveMean_rainU CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5
		
			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'
			
			
	local i = `i'+1
	** 100mm bin widths
	xtivreg2 `LHSVar' (Shortage = $Inst) $Alt100RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5
		
			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'
		
	
	local i = `i'+1
	** 60mm bin widths
	xtivreg2 `LHSVar' (Shortage = $Inst) $Alt60RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5
		
			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'

			
	local i = `i'+1
	** NCC rainfall bins
	xtivreg2 `LHSVar' (Shortage = $Inst) $AltSRainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5
		
			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'
	
	local i = `i'+1
	** NCC rainfall linear
	rename rainU rainU_temp
	replace rainU = rain
	
	xtivreg2 `LHSVar' (Shortage = $Inst) rainU CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5

			local widstat`i'`LHSVar'=round(e(widstat),0.01)
			
		est store `LHSVar'`i'
			
	replace rainU = rainU_temp
	drop rainU_temp
		
	/* Outreg to combined table */
	if "`LHSVar'" == "SGS" { // start new table
		esttab `LHSVar'? using "$RegResults/WeatherFEIV.csv", replace ///
			keep(Shortage rainU lnrainU CDD65) title(`LHSVar') se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
	else { // append to previous table
		esttab `LHSVar'? using "$RegResults/WeatherFEIV.csv", append ///
			keep(Shortage rainU lnrainU CDD65) title(`LHSVar') se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
			
}	


log close

*
