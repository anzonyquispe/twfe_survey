**************************************************************
**************************************************************
*****        do-file 4_Estim_G_ES_firm_R3.do    	 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Event study regressions on firm level 
** Aggregation level: Firm

//  Preliminaries 
pause on
set mo off
capture log close
local sound qui 

log using "${log}/4_Estim_${pro}_${sam}_ES_firm_R3.log", replace

`sound' {
	* Load data
	use if inrange(jahr,1999,2008) using "${data}/3_Comb_F_${pro}_${sam}_longjim.dta" , clear

	// Regression command
	local regn xtreg
	local opt fe i(grouper) vce(cluster ao_gem) nonest noomitted noemptycells

	// LHS Variable
	local yvar lwage_ft_p50

	// Regressors
	local xvars1 F?_taxhike L?_taxhike
	local xvars2 F?_p75taxhike L?_p75taxhike
	local xvars3 F?_taxdrop L?_taxdrop

	local X_busi bl#jahr	
	local X_com2 L2_bip L2_alq L2_popul L2_expenses 

	// Sample restriction
	local baseif if norfswitch == 1 & numbw > 3
	reg `yvar' `xvars1' `X_com2' `baseif' & merged_muni == 0
	gen basesamp = e(sample)
	keep if basesamp == 1

	/* **************************************************************
	*********************   Event study design  *********************
	************************************************************** */

	/* Figure 3a and Table D.10 */
	eststo clear

	eststo, title(hikes_0D):      `regn' `yvar' `xvars1' `X_busi' 	`baseif' & basesamp == 1 & nogew_base == 0 & (totaldrops==0) , `opt'
	eststo, title(hikes_p75_0D):  `regn' `yvar' `xvars2' `X_busi' 	`baseif' & basesamp == 1 & nogew_base == 0 & (totaldrops==0) , `opt'
	eststo, title(drops_0H):      `regn' `yvar' `xvars3' `X_busi' 	`baseif' & basesamp == 1 & nogew_base == 0 & (totalhikes==0) , `opt'

	noi di "Results from Figure 3a and Table D.10"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""
	
	/* Figure D.1 and Table D.11 */
	eststo clear

	eststo, title(hikes_p75):       `regn' `yvar' `xvars2' `X_busi'        `baseif' & basesamp == 1 & nogew_base == 0 					, `opt' 
	eststo, title(hikes_p75_0D):    `regn' `yvar' `xvars2' `X_busi'        `baseif' & basesamp == 1 & nogew_base == 0 & (totaldrops==0) 			, `opt'
	eststo, title(hikes_p75_1W0D):  `regn' `yvar' `xvars2' `X_busi'        `baseif' & basesamp == 1 & nogew_base == 0 & (sump75taxhike<=1 & totaldrops==0) 	, `opt'   
	eststo, title(hikes_p75_1H0D):  `regn' `yvar' `xvars2' `X_busi'        `baseif' & basesamp == 1 & nogew_base == 0 & (totalp75hikes<=1 & totaldrops==0) 	, `opt'

	noi di "Results from Figure D.1 and Table D.11"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Figure D.2 and Table D.12 */
	eststo clear

	eststo, title(hikes_all_0D):    `regn' `yvar' `xvars2' `X_busi'      `baseif' & basesamp == 1 & (totaldrops==0) 			, `opt'
	eststo, title(hikes_liab_0D):   `regn' `yvar' `xvars2' `X_busi'      `baseif' & basesamp == 1 & nogew_base == 0 & (totaldrops==0) 	, `opt'
	eststo, title(hikes_nliab_0D):  `regn' `yvar' `xvars2' `X_busi'      `baseif' & basesamp == 1 & nogew_base == 1 & (totaldrops==0) 	, `opt'

	noi di "Results from Figure D.2 and Table D.12"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""
	
} // sound
log close

***








