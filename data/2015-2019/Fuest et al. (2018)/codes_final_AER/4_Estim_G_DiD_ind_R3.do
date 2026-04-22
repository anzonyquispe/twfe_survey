**************************************************************
**************************************************************
*****        do-file 4_Estim_G_DiD_ind_R3.do    	 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Difference-in-difference estimations on worker level 
** Aggregation level: Workers

//  Preliminaries 
pause on
set more off
local sound qui
capture log close

log  using "${log}/4_Estim_${pro}_${sam}_DiD_ind_R3.log", replace

`sound' {
	// Load data
	use if inrange(jahr,1999,2008) using  "${data}/3_Comb_I_${pro}_${sam}_long.dta" , clear

	// Regression command
	local regn xtreg
	local opt fe i(grouper) vce(cluster ao_gem) nonest noomitted noemptycells

	// Variables
	local yvar lwage
	local xvar L0_taxrate
	local X_busi bl#jahr
	local X_com2 L2_bip L2_alq L2_popul L2_expenses 
	local X_firm2 L2_employees 
	local X_ind tenure i.emp_gr i.ski_gr i.occ_gr i.branche

	// Sample restriction
	`qui' reg `yvar' `xvar' `X_com2' 
	local baseif  if norfswitch == 1 & numbw >3 
	gen basesamp = e(sample)
	keep if basesamp == 1

	/**************************
	* Summary statistics 
	***************************/ 
	xtset persnr jahr
	sort persnr jahr

	local sumstats wage gewerb taxrate expenses revenues popul alq bip west ///
			employees_lev nogew age male D_ski* D_occ* nevercens  

	noi di " Summary statistics (Table C.6)
	noi di ""
	noi xtsum persnr if basesamp == 1  & emp_gr == 1 & merged_muni == 0  
	noi tabstat `sumstats' ,  s(mean p50 sd min max N) c(stat) save labelwidth(30), if basesamp == 1  & emp_gr == 1 & merged_muni == 0  
	noi di ""

	/**************************
	* DiD analysis
	***************************/

	local mainspec if   basesamp == 1 & merged_muni == 0 & nogew_base == 0 & emp_gr == 1

	/* Table D.6 */
	eststo clear
	eststo, title(baseline):   `regn' `yvar' `xvar' `X_busi'      				`mainspec'  							, `opt'
	eststo, title(year):   	   `regn' `yvar' `xvar'  i.jahr    				`mainspec'  							, `opt'
	eststo, title(czXj):       `regn' `yvar' `xvar'  amr#jahr 				`mainspec'  							, `opt'
	eststo, title(blXjMC):     `regn' `yvar' `xvar' `X_busi' `X_com2'     			`mainspec'  							, `opt'
	eststo, title(blXjFC):     `regn' `yvar' `xvar' `X_busi' `X_firm2'     			`mainspec'  							, `opt'
	eststo, title(blXjWC):     `regn' `yvar' `xvar' `X_busi' `X_ind'     			`mainspec'  							, `opt'
	eststo, title(nevercens):  `regn' `yvar' `xvar' `X_busi'     				`mainspec' & nevercens == 1 					, `opt'
	eststo, title(ft+pt):      `regn' `yvar' `xvar' `X_busi' emp_gr#jahr  			if  basesamp == 1  & merged_muni == 0 & nogew_base == 0		, fe i(grouper_emp) vce(cluster ao_gem) nonest noomitted noemptycells  

	noi di "Table D.6"
	noi esttab *, keep(*taxrate*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""


	// From here only main sample
	keep `mainspec'

	/* Table 4 and D.8 */
	eststo clear

	foreach IA in ski_gr male occ_gr age_gr {
		forval c = 1/2{
			if `c' == 1 {
				local cif 
				local cname 
			}
			if `c' == 2 {
				local cif if nevercens == 1
				local cname _nc		
			}
			eststo, title(IA_`IA'`cname'): `regn' `yvar' c.`xvar'#`IA' `X_busi' `IA'#jahr  `cif' , `opt' 
		} // c
	} // IA

	noi di "Tables 4 and D.8"
	noi esttab *, keep(*taxrate*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""
	
} // sound

log close
***