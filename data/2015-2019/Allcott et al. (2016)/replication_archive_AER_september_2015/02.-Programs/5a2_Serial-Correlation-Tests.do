/* 5a2_Serial Correlation Tests.do */
	* Tests for serial correlation in state-by-year level data.

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
***************************************************************************
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"



include "$do/Subroutines/DefineGlobals.do"

global In = "C1Hydro_InstC_rr"
global Wt = "NumberofEstablishments"


******************************************************************************
/* Data prep */

use "$work/state-level dataset for first stages.dta", replace

	sort state year
	foreach var in C1Hydro_InstC_rr Hydro_Inst_Pcon Hydro_InstC_rr {
		forvalues e=1/5 {
			gen l`e'`var' = `var'[_n-`e'] if state==state[_n-`e']
			gen l`e'd`var' = d`var'[_n-`e'] if state==state[_n-`e']
		}
	}

label var l1Hydro_InstC_rr "1st Lag Z"
label var l2Hydro_InstC_rr "2nd Lag Z"
label var l3Hydro_InstC_rr "3rd Lag Z"
label var l4Hydro_InstC_rr "4th Lag Z"
label var l5Hydro_InstC_rr "5th Lag Z"
	
	
/* Test for serial correlation*/
outreg, clear(SerialCorr)

*foreach LHSVar in Shortage SGS lnFE_Y lnM lnY {
foreach var in $In { // Hydro_Inst_Pcon Hydro_InstC_rr
	reg `var' l1`var' [pw=$Wt], robust
	*reg `var' l1`var' $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust
		outreg using "$RegResults/SerialCorr", merge(SerialCorr) se replace varlabels tex fragment starlevels(10 5 1) ///
		summstat(N \ F \ r2) summtitles("Number of Obs." \ "F-Stat" \ "R-Squared") ///
		keep(l1`var') 

	reg `var' l1`var' l2`var' l3`var' l4`var' l5`var' [pw=$Wt], robust
	*reg `var' l1`var' l2`var' l3`var' l4`var' l5`var' $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust
		outreg using "$RegResults/SerialCorr", merge(SerialCorr) se replace varlabels tex fragment starlevels(10 5 1) ///
		summstat(N \ F \ r2) summtitles("Number of Obs." \ "F-Stat" \ "R-Squared") ///
		keep(l1`var' l2`var' l3`var' l4`var' l5`var') 
		
	
	
	** Difference estimator tests
	*reg d`var' l1d`var' $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust
	*reg d`var' l1d`var' l2d`var' l3d`var' l4d`var' l5d`var' $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust
}



	outreg using "$RegResults/SerialCorr", replay(SerialCorr) replace tex fragment ///
		summstat(N \ F \ r2) summtitles("Number of Obs." \ "F-Stat" \ "R-Squared") ///
		ctitles("","(1)","(2)") ///
			hlines(11{0}1)
			
