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
log using "$logs/ASI FE Moderators Log $date $time.log", replace

include "$do/Subroutines/DefineGlobals.do"


/* REPLICATE PREVIOUS MODERATORS TABLE */
forvalues num = 1/1 {
	outreg, clear(ModeratorsFE`num') 
}	

foreach LHSVar in SGS lnF_Y lnY lnW {

	use "$intdata/ASIpanel for ASI Regressions.dta", clear
	
		
	** Drop if only one observation
	drop if NumObs==1

	rename $InstxElecIntensive Inst1
	
	**** Original moderators table
	xtivreg2 `LHSVar' (Shortage ShortagexElecIntensive ShortagexanyyearEprod ///
		= $Inst Inst1 $InstxanyyearEprod) ///
		$RainfallBins CDD65 _Y* _G* _N* _R* ///
		_?f_*_Elec* _?f_*_anyy* /// "?" wildcard means that this includes all yf, gf, and rf controls
		[pweight=Weight], /// 
		fe cluster($FEClusterVars), if `LHSVar'_flag<3.5
	
		outreg, merge(ModeratorsFE1) se replace varlabels tex fragment starlevels(10 5 1) ///
			summstat(N \ N_clust1 \ N_clust2) summtitles("Number of Obs." \ "Number of Clusters" \ "Number of Clusters (2)") ///
			keep(Shortage ShortagexElecIntensive ShortagexanyyearEprod)

}

forvalues num = 1/1 {
	foreach spec in FE {
		outreg using "$RegResults/Moderators`spec'`num'", replay(Moderators`spec'`num') replace tex fragment ///
			summstat(N \ N_clust \ N_clust2) summtitles("Number of Obs." \ "Number of Clusters" \ "Number of Clusters (2)") ///
					ctitles("","(1)","(2)","(3)","(4)"\ "","Self-Gen","ln(Fuel","",""  \ ///
					"Dependent Variable:","Share","Rev Share)","ln(Revenue)","ln(TFPR)") ///
				hlines(1101{0}1)
	}
}




*******************************************************************************
*******************************************************************************


/* SEPARATE ESTIMATES (SPLIT SAMPLES) FOR DIFFERENT BINARY MODERATORS */

foreach RHSVar in anyyearEprod SelfGen2 LargeK ElecIntensive  { //  somehow is giving r(504) error which is completely unexplained
	local r = 1 

	forvalues R = 0/1 {
		use "$intdata/ASIpanel for ASI Regressions.dta", clear
		** Drop if only one observation
		drop if NumObs==1
	
		if "`RHSVar'" == "SelfGen2" {
			bysort panelgroup: egen maxSGS = max(SGS)
			bysort panelgroup: egen maxqeleccons = max(qeleccons)
			bysort panelgroup: egen maxqelecprod = max(qelecprod)
			gen SelfGen2 = cond((maxSGS>0.02&maxSGS!=.)|( (maxqeleccons==0|maxqeleccons==.) & maxqelecprod>0&maxqelecprod!=. ) ,1,0) // Note: the OR doesn't do anything - this is the same as just cond((maxSGS>0.02&maxSGS!=.),1,0)
		}
	
		keep if `RHSVar'==`R' 
	
		foreach LHSVar in SGS lnF_Y lnM lnL lnY lnW {
			capture noisily xtivreg2 `LHSVar' (Shortage = $Inst) $RainfallBins CDD65 _Y* _G* _N* _R* [pweight=Weight], /// 
			fe cluster($FEClusterVars) first savefirst, if `LHSVar'_flag<3.5 // first savefirst  $FEClusterVars  (clustering by this gives a rare matrix inversion error)
			
			if _rc != 504 { // if no matrix inversion error
				est store `RHSVar'`LHSVar'`R'
			}
		}
	}

			
	/* esttab to combined table */
	if `r'==1 { // Start new table
		esttab `RHSVar'*1 using "$RegResults/Modby`RHSVar'.csv", replace ///
			keep(Shortage) title("`RHSVar'=1") se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
	else {
		esttab `RHSVar'*1 using "$RegResults/Modby`RHSVar'.csv", append ///
			keep(Shortage) title("`RHSVar'=1") se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
	}
	
	* append the RHSVar==0 results
		esttab `RHSVar'*0 using "$RegResults/Modby`RHSVar'.csv", append ///
			keep(Shortage) title("`RHSVar'=0") se scalars(N_clust1 N_clust2 widstat) ///
			nonotes staraux star(* 0.10 ** 0.05 *** 0.01) nogaps 
			
	local r = `r'+1
}


log close 
*******************************************************************
*******************************************************************

	
