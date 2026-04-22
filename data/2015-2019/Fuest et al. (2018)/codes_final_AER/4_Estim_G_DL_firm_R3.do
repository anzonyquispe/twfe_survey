**************************************************************
**************************************************************
*****        do-file 4_Estim_G_DL_firm_R3.do    	 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Distributed lag models on firm level 
** Aggregation level: Firm

//  Preliminaries 
pause on
set mo off
capture log close
local sound qui 

log using "${log}/4_Estim_${pro}_${sam}_DL_firm_R3.log", replace

`sound' {
	// Load data
	use if inrange(jahr,1999,2008) using "${data}/3_Comb_F_${pro}_${sam}_longjim.dta" , clear

	// Regression command
	local regn reg
	local opt vce(cluster ao_gem) noomitted noemptycells

	// Sample restriction
	local xvars1 F?_taxhike L?_taxhike
	local X_com2 L2_bip L2_alq L2_popul L2_expenses 	
	local baseif if norfswitch == 1 & numbw > 3	
	reg `yvar' `xvars1' `X_com2' `baseif' & merged_muni == 0
	gen basesamp = e(sample)
	keep if basesamp == 1

	/* **************************************************************
	********************* Distributed lag model *********************
	************************************************************** */
	
	// First differences
	gen D_lwage = D.lwage_ft_p50

	gen F4_taxchange = F4_taxrate-F3_taxrate
	gen F3_taxchange = F3_taxrate-F2_taxrate      
	gen F2_taxchange = F2_taxrate-F1_taxrate
	gen F1_taxchange = F1_taxrate-L0_taxrate
	gen L0_taxchange = L0_taxrate-L1_taxrate
	gen L1_taxchange = L1_taxrate-L2_taxrate
	gen L2_taxchange = L2_taxrate-L3_taxrate
	gen L3_taxchange = L3_taxrate-L4_taxrate
	gen L4_taxchange = L4_taxrate-L5_taxrate
	gen L5_taxchange = L5_taxrate-L6_taxrate

	/* Figure 3b and Table D.13 */
	eststo clear

	noi di "Results from Figure 3b and Table D.13"

	** Lead/lag model
	eststo, title(D_leadlag): ///
		reg D_lwage 	F4_taxchange F3_taxchange F2_taxchange F1_taxchange ///
				L0_taxchange L1_taxchange L2_taxchange L3_taxchange L4_taxchange L5_taxchange bl#jahr ///
			    	`baseif' & basesamp == 1 & nogew_base == 0 & totaldrops==0 , `opt'

	* Cumulative effects via noi lincom
	noi di "Lincom: lead/lag"

	noi lincom F4_taxchange
	noi lincom F4_taxchange + F3_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange 
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange + L5_taxchange

	** Lag only model
	eststo, title(D_lag): ///
		reg D_lwage 	L0_taxchange L1_taxchange L2_taxchange L3_taxchange L4_taxchange L5_taxchange bl#jahr ///
				`baseif' & basesamp == 1 & nogew_base == 0 & totaldrops==0 , `opt'

	* Cumulative effects via noi lincom
	noi di "Lincom: lag only"

	noi lincom L0_taxchange
	noi lincom L0_taxchange+ L1_taxchange
	noi lincom L0_taxchange+ L1_taxchange + L2_taxchange
	noi lincom L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange
	noi lincom L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange 
	noi lincom L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange + L5_taxchange

	noi di "Estimates"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Figure D.3 and Table D.14 */
	eststo clear
	noi di "Results from Figure D.3 and Table D.14"

	** All munis

	eststo, title(D_leadlag_all): ///
		reg D_lwage 	F4_taxchange F3_taxchange F2_taxchange F1_taxchange ///
				L0_taxchange L1_taxchange L2_taxchange L3_taxchange L4_taxchange L5_taxchange bl#jahr ///
			    	`baseif' & basesamp == 1 & nogew_base == 0 , `opt'
			    	
	noi di "Lincom: all firms"
	* Cumulative effects via noi lincom
	noi lincom F4_taxchange
	noi lincom F4_taxchange + F3_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange 
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange + L5_taxchange

	** Munis with zero drops (baseline)

	eststo, title(D_leadlag_0D): ///
		reg D_lwage 	F4_taxchange F3_taxchange F2_taxchange F1_taxchange ///
				L0_taxchange L1_taxchange L2_taxchange L3_taxchange L4_taxchange L5_taxchange bl#jahr ///
			    	`baseif' & basesamp == 1 & nogew_base == 0 & totaldrops==0 , `opt'

	* Cumulative effects via noi lincom
	noi di "Lincom: zero drops"
	noi lincom F4_taxchange
	noi lincom F4_taxchange + F3_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange 
	noi lincom F4_taxchange + F3_taxchange+  F2_taxchange + F1_taxchange + L0_taxchange+ L1_taxchange + L2_taxchange + L3_taxchange + L4_taxchange + L5_taxchange

	noi di "Estimates"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev

} // sound
log close

***








