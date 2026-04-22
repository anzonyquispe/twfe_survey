//////////////////////////////////////////////////////
// Master - Figure 3 - Event Study of first complaint	 
//////////////////////////////////////////////////////
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/

** [1] Prepare data for event study around the first time a firm receives a complaint

do "$MainDir\Codes\_doFigure3_dataprep_AER.do"


** [2] Use propensity score for re-weighting

do "$MainDir\Codes\_doFigure3_weights_AER.do"


** [3] Analysis: Figure 3 and coefficient estimation 

do "$MainDir\Codes\_doFigure3_analysis_AER.do"



