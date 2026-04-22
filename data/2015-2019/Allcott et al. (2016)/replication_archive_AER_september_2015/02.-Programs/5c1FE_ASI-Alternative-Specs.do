*/* 5c1FE_ASI Alternative Specs.do */
* Alternative specs in fixed effects estimator
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
log using "$logs/ASI FE Regressions Alt Specs Log $date $time.log", replace

global first = "first savefirst" //
*global first = "" // determines if the first stage is run

************************************************************************


/* ROBUSTNESS CHECKS FOR MAIN TABLE */	
foreach LHSVar in SGS lnF_Y lnFE_Y lnlambda lnM lnL lnWage lnY lnW { 

	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
	** Drop if only one observation
	drop if NumObs==1
	
	* Only look for effects on SGS and fuels for electricity producers!
	if "`LHSVar'"=="SGS" | "`LHSVar'"=="lnF_Y" | "`LHSVar'"=="lnFE_Y" { 
		drop if anyyearEprod == 0
	}
	
	local i = 1
	
	
	** Without nic2num x year FEs
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5	
		
		est store `LHSVar'`i'
			
	local i = `i'+1
	** With 1.5 flags
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<1.5	
		
		est store `LHSVar'`i'
		
	
	local i = `i'+1
	** With no flags
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first
		
		est store `LHSVar'`i'
		
				
	local i = `i'+1
	** Using (negative) quantity supplied
	
	rename Shortage Shortage_temp
	rename Neglnavail Shortage
	
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5
		
		est store `LHSVar'`i'


	local i = `i'+1
	** Using Peak Shortage
	drop Shortage
	rename PeakShortage Shortage
	
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) $first, if `LHSVar'_flag<3.5			
			
		est store `LHSVar'`i'	
		
	drop Shortage
	rename Shortage_temp Shortage 
	
	local i = `i'+1
	** Cluster by state
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster(statenum) $first, if `LHSVar'_flag<3.5	
		
		est store `LHSVar'`i'
		
			

	/* esttab to combined table */
	if "`LHSVar'" == "SGS" { // start new table
	esttab `LHSVar'? using "$RegResults/CheckFEIV.csv", replace ///
			keep(Shortage) title(`LHSVar') se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
	else { // append to previous table
		esttab `LHSVar'? using "$RegResults/CheckFEIV.csv", append ///
			keep(Shortage) title(`LHSVar') se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
		
}


********************************************************************************






*********************************************************************************
*********************************************************************************


/* ALTERNATIVE TFPR ESTIMATES */
outreg, clear(AltTFPFEIV)

global AltTFPRVars = "lnW_M_fuels lnW_M_nofuels lnW_CDwCRS lnW_leontief_CRS lnW_CDwCRS_unc lnW_CDnoCRS_sizetrend"

local i = 0
foreach LHSVar in $AltTFPRVars {

	use "$intdata/ASIpanel for ASI Regressions.dta", clear

		** Drop if only one observation
		drop if NumObs==1
		
	local i = `i'+1	
	xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
		fe cluster($FEClusterVars) first savefirst, if `LHSVar'_flag<3.5		
				
			est store AltTFPFEIV`i'	
	
		local widstat`i'=round(e(widstat),0.01)
		outreg, merge(AltTFPFEIV) se replace varlabels tex fragment starlevels(10 5 1) /// 
			summstat(N \ N_clust1 \ N_clust2) summtitles("Number of Obs." \ "Number of Clusters"  \ "Number of Clusters (2)") ///
			keep(Shortage)
		
		
}
/* Outreg */
		esttab AltTFPFEIV? using "$RegResults/AltTFPFEIV.csv", append ///
			keep(Shortage) title(AltTFPFEIV) se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
			
			
foreach spec in IV {
	outreg using "$RegResults/AltTFPFE`spec'", replay(AltTFPFE`spec') replace tex fragment ///
		summstat(N \ N_clust1 \ N_clust2) summtitles("Number of Obs." \ "Number of Clusters"  \ "Number of Clusters (2)") ///
		ctitles("","(1)","(2)","(3)","(4)","(5)","(6)" \ "","Include","Include","No Time","$\alpha$ Varies","","Leontief" \   ///
			"","All Fuels","No Fuels","Trend","by Size","CRS","CRS") ///
			addrows("First Stage F-Stat","`widstat1'","`widstat2'","`widstat3'","`widstat4'","`widstat5'","`widstat6'") ///
			hlines(1101{0}1) //
}


log close



**
