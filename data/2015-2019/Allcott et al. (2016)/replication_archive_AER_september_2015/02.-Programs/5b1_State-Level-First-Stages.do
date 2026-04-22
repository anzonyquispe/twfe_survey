/* 5b1_State-Level First Stages.do */
* This file tests first stages using state level data

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

include "$do/Subroutines/DefineGlobals.do"

log using "$logs/State-Level First Stages $date $time.log", replace


***********************************************************************
/* STATE-LEVEL FIRST-STAGES */
use "$work/state-level dataset for first stages.dta", replace

outreg, clear(StateLevelFirstStage)
outreg, clear(StateLevelFirstStageFE)


*global In = "C1Hydro_InstC_rr" // From second revision.
global In = "Hydro_InstC_rr"
global Wt = "NumberofEstablishments"
global FEClust = ""


*** Conditional on rainfall and temps
* Differences
reg dShortage d$In $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust
	outreg, merge(StateLevelFirstStage) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep(d$In)


* Fixed effects
reg Shortage $In $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust cluster($FEClust)
	outreg, merge(StateLevelFirstStageFE) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep($In)

	
*** Supply
* Differences
reg dlnavail d$In $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust  
	outreg, merge(StateLevelFirstStage) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep(d$In)

* Fixed effects
reg lnavail $In $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust cluster($FEClust) 
	outreg, merge(StateLevelFirstStageFE) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep($In)

	
*** Demand
* Differences
reg dlnreq d$In $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust  
	outreg, merge(StateLevelFirstStage) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep(d$In)

* Fixed effects
reg lnreq $In $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust cluster($FEClust) 
	outreg, merge(StateLevelFirstStageFE) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep($In)
	
*** Correlation with agricultural production
	reg dlnagprod000ton drainU dCDD65 i.statenum i.year _dG* [pw=$Wt], robust  
	reg dlnagprod000ton d$In i.statenum i.year _dG* [pw=$Wt], robust  

	
* Differences
reg dlnagprod000ton d$In $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust  
	outreg, merge(StateLevelFirstStage) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep(d$In)

* Fixed effects
reg lnagprod000ton $In $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust cluster($FEClust) 
	outreg, merge(StateLevelFirstStageFE) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep($In)


*** Prices
* Differences
reg dlnRs_kWh_med d$In $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust  
	outreg, merge(StateLevelFirstStage) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep(d$In)

* Fixed effects
reg lnRs_kWh_med $In $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust cluster($FEClust)
	outreg, merge(StateLevelFirstStageFE) se replace varlabels tex fragment starlevels(10 5 1) ///
	summstat(N) summtitles("Number of Obs.") ///
	keep($In)


	outreg using "$RegResults/StateLevelFirstStage", replay(StateLevelFirstStage) replace tex fragment ///
		summstat(N) summtitles("Number of Obs.") ///
		ctitles("","(1)","(2)","(3)","(4)","(5)"  \ "","","ln(Energy","ln(Assessed","ln(Agri","ln(Median" \ ///
		"Dependent Variable:","Shortage","Available)","Demand)","Output)","Price)") /// addrows("Weather Controls","No","Yes","Yes","Yes","Yes","Yes") ///
			hlines(1101{0}1)

		outreg using "$RegResults/StateLevelFirstStageFE", replay(StateLevelFirstStageFE) replace tex fragment ///
		summstat(N) summtitles("Number of Obs.") ///
		ctitles("","(1)","(2)","(3)","(4)","(5)" \ "","","ln(Energy","ln(Assessed","ln(Agri","ln(Median" \ ///
		"Dependent Variable:","Shortage","Available)","Demand)","Output)","Price)") ///
			hlines(1101{0}1)

*** Test first stages with clustering
* Differences
reg dShortage d$In $dRainfallBins dCDD65 i.statenum i.year _dG* [pw=$Wt], robust cluster(statenum)

* Fixed effects
reg Shortage $In $RainfallBins CDD65 i.statenum i.year i.statenum#c.year i.SplitGroup [pw=$Wt], robust cluster(statenum)

			
***********************************************************************
***********************************************************************
***********************************************************************
	


log close



