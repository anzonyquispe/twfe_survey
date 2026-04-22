**************************************************************
**************************************************************
*****        do-file 4_Estim_G_DiD_muni_R3.do    	 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Difference-in-difference estimations on municipal level 
** Aggregation level: Municipalities

//  Preliminaries 
pause on
set more off
local sound qui
capture log close

log using "${log}/4_Estim_${pro}_${sam}_DiD_muni_R3.log", replace

`sound' {
	// Load data
	use if inrange(jahr,1999,2008) using "${data}/3_CombineM_${pro}_${sam}.dta", clear
	  
	// Regression command
	local regn reghdfe
	local FE ao_gem
	local clusvar ao_gem

	// Variables
	local yvar lwage
	local xvar L0_taxrate
	local X_com2 L2_bip L2_alq L2_popul L2_expenses

	// Sample
	noi reg `yvar' `xvar' `X_com2'
	gen basesamp = e(sample)
	keep if basesamp == 1

	/* Table D.1 -- muni-level results */ 
	eststo clear
	eststo, title(baseline):   `regn' `yvar' `xvar'             [aw=firms]  , absorb(`FE' bl#jahr) vce(cluster `clusvar')
	eststo, title(year):   	   `regn' `yvar' `xvar'             [aw=firms]  , absorb(`FE' jahr)    vce(cluster `clusvar')
	eststo, title(czXyr):  	   `regn' `yvar' `xvar'             [aw=firms]  , absorb(`FE' amr#jahr) vce(cluster `clusvar')
	eststo, title(blXjMC): 	   `regn' `yvar' `xvar' `X_com2'    [aw=firms]  , absorb(`FE' bl#jahr) vce(cluster `clusvar')
	// Note that we use reghdfe here because the weights may vary within panel which is not allowed with xtreg
	// The use-written command reghdfe yields identical point estimates and minimally more conservative standard errors
	
	
	noi di "Table D.1"
	noi esttab *, keep(*taxrate*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

} // sound

cap log close

***
