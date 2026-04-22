**************************************************************
**************************************************************
*****        do-file 4_Estim_G_DiD_firm_R3.do    	 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Difference-in-difference estimations on firm level 
** Aggregation level: Firm

//  Preliminaries 
pause on
set mo off
capture log close
local sound qui 

log using "${log}/4_Estim_${pro}_${sam}_DiD_firm_R3.log", replace

`sound' {
	
	// Load dtaa
	use if inrange(jahr,1999,2008) using "${data}/3_Comb_F_${pro}_${sam}_longjim.dta" , clear

	// Regression command
	local regn xtreg
	local opt fe i(grouper) vce(cluster ao_gem) nonest noomitted noemptycells
		
	// Variables
	local yvar lwage_ft_p50
	local xvar L0_taxrate
	local X_busi bl#jahr
	local X_com2 L2_bip L2_alq L2_popul L2_expenses 
	local X_fir2 L2_employees
	local X_comp skill_sh1 skill_sh2 male age emp_sh1 occ_sh1
	
	// Baseline restriction
	reg `yvar' `xvar' `X_com2' 
	gen basesamp = e(sample)
	local baseif if norfswitch == 1  & numbw > 3
	
	// Summary statistics for several merged muni and merged_muni-liab sample 
	** Set up summary statistics
	local cats  nogew tarif branche profit singlefirm foreignowned firmsize marketpower 
	local catvars
	foreach v of local cats {
		qui tab `v', gen(D_`v')
		local catvars `catvars' D_`v'*
	}

	local sumstats wage gewerb taxrate expenses revenues popul alq bip west ///
		employees_lev D_nogew* D_tarif* D_branche* D_profit* D_singlefirm* D_foreignowned* D_firmsize* D_marketpower*

	xtset idnum jahr
	sort idnum jahr
	
	/**************************
	* Summary statistics 
	***************************/

	noi di ""
	noi di ""
	noi di " Summary statistics (Table C.5)"
	noi di ""
	noi xtsum idnum `baseif' &  basesamp == 1 & merged_muni == 0  
	noi tabstat `sumstats' ,  s(mean p50 sd min max N) c(stat) save labelwidth(30), `baseif' &  basesamp == 1 & merged_muni == 0  
	noi di ""

	noi di ""
	noi di " Percentiles of share of non-censored workers (Table C.4)"
	noi di ""
	noi tab broad_sec `baseif' &  basesamp == 1 & merged_muni == 0 & nogew_base == 0  
	noi tabstat nevercens, s(p1 p5 p10 p25 p50 p75 p90 p95 p99) by(broad_sec),  `baseif' &  basesamp == 1 & merged_muni == 0 & nogew_base == 0  
	drop `catvars' 


	/**************************
	* DiD analysis
	***************************/
	
	local mainspec `baseif' & basesamp == 1 &  merged_muni == 0 & nogew_base == 0  

	/* Table 1 */
	eststo clear
	eststo, title(baseline):  `regn' `yvar' `xvar' `X_busi' 		`mainspec' , `opt'
	eststo, title(jahr):      `regn' `yvar' `xvar' i.jahr         		`mainspec' , `opt'
	eststo, title(czXj):      `regn' `yvar' `xvar' amr#jahr         	`mainspec' , `opt' 
	eststo, title(blXjMC):    `regn' `yvar' `xvar' `X_busi' `X_com2' 	`mainspec' , `opt'
	eststo, title(emp2):      `regn' `yvar' `xvar' `X_busi' `X_fir2'    	`mainspec' , `opt'            
	eststo, title(compo):     `regn' `yvar' `xvar' `X_busi' `X_comp'        `mainspec' , `opt' 
	noi di "Table 1"
	noi esttab *, keep(`xvar') star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Table 3 */
	eststo clear
	eststo, title(baseline):  	`regn' `yvar' `xvar' `X_busi' 					`baseif' &  basesamp == 1 &  merged_muni == 0 & nogew_base == 0 , `opt'
	eststo, title(nliab):     	`regn' `yvar' `xvar' `X_busi'               	  		`baseif' &  basesamp == 1 &  merged_muni == 0 & nogew_base == 1 , `opt'        
	eststo, title(IA_liab):   	`regn' `yvar' c.`xvar'#nogew_base `X_busi' nogew_base#i.jahr 	`baseif' &  basesamp == 1 &  merged_muni == 0			, `opt'

	foreach IA in branche tarif profit firmsize marketpower singlefirm foreignowned {
		eststo, title(IA_`IA'):	`regn' `yvar' c.`xvar'#`IA'_base `X_busi' `IA'_base#jahr	`mainspec' , `opt'
	}
	noi di "Table 3"
	noi esttab *, keep(*taxrate*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Table D.2 */ 
	foreach com of varlist skill_sh1 skill_sh2 male emp_sh1 occ_sh1 {
		replace `com' = `com' * 100
		replace `com' = ln(`com')   	// Each worker share in percent to have elasticity
	} // com
	replace age = ln(age)

	eststo clear
	foreach com of varlist skill_sh1 skill_sh2 male emp_sh1 occ_sh1 age {
		eststo, title(`com'): `regn' `com' `xvar' `X_busi'    `mainspec' , `opt'  
	}
	noi di "Table D.2"
	noi esttab *, keep(`xvar') star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""


	/* Table D.3 */     
	eststo clear
	eststo, title(baseline):  `regn' `yvar' `xvar' `X_busi' 					 `mainspec' , `opt'
	eststo, title(b_spend):   `regn' `yvar' `xvar' `X_busi' L0_expenses F1_expenses  F2_expenses     `mainspec' , `opt'
	eststo, title(b_nevcens): `regn' `yvar' `xvar' `X_busi' nevercens                                `mainspec' , `opt'
	noi di "Table D.3"
	noi esttab *, keep(`xvar') star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Table D.4 */     
	eststo clear
	foreach wage of varlist `yvar' lwage_ft_mean lwage_ft_p25 lwage_ft_p75    {
		eststo, title(`wage'): `regn' `wage' `xvar' `X_busi'         `mainspec' , `opt'           
	} // wage
	noi di "Table D.4"
	noi esttab *, keep(`xvar') star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""


	/* Table D.5*/
	eststo clear
	eststo, title(baseline):     `regn' `yvar' `xvar' `X_busi'       `mainspec' 												, `opt'
	eststo, title(nonmerged):    `regn' `yvar' `xvar' `X_busi'       `baseif' 			&  basesamp == 1 &  merged_muni == 0                       		, `opt'
	eststo, title(all):          `regn' `yvar' `xvar' `X_busi'       `baseif' 			&  basesamp == 1   			& nogew == 0         		, `opt'
	eststo, title(zerodrop):     `regn' `yvar' `xvar' `X_busi'       `baseif' 			&  basesamp == 1 &  merged_muni == 0  	& nogew == 0 & totaldrops==0    , `opt'
	eststo, title(ch_incorp):    `regn' `yvar' `xvar' `X_busi'       if numbw > 3 			&  basesamp == 1 &  merged_muni == 0  	& nogew == 0     		, `opt'
	eststo, title(tinyfirms):    `regn' `yvar' `xvar' `X_busi'       if norfswitch == 1 & numbw > 0	&  basesamp == 1 &  merged_muni == 0  	& nogew == 0     		, `opt'
	eststo, title(yr99-07):      `regn' `yvar' `xvar' `X_busi'       `baseif' 			&  basesamp == 1 &  merged_muni == 0  	& nogew == 0 & jahr <=2007	, `opt'
	noi di "Table D.5"
	noi esttab *, keep(`xvar') star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Table D.7*/
	eststo clear
	eststo, title(muni):  	`regn' `yvar' `xvar' `X_busi'   `mainspec' , fe i(grouper) vce(cluster ao_gem)   nonest noomitted noemptycells
	eststo, title(muni-yr): `regn' `yvar' `xvar' `X_busi'   `mainspec' , fe i(grouper) vce(cluster muniyear) nonest noomitted noemptycells
	eststo, title(county):  `regn' `yvar' `xvar' `X_busi'   `mainspec' , fe i(grouper) vce(cluster kreis)    nonest noomitted noemptycells 
	eststo, title(CZ):     	`regn' `yvar' `xvar' `X_busi'   `mainspec' , fe i(grouper) vce(cluster amr)      nonest noomitted noemptycells 
	eststo, title(state):   `regn' `yvar' `xvar' `X_busi'   `mainspec' , fe i(grouper) vce(cluster bl)       nonest noomitted noemptycells 
	eststo, title(firm):   	`regn' `yvar' `xvar' `X_busi'   `mainspec' , fe i(grouper) vce(cluster idnum)    nonest noomitted noemptycells
	noi di "Table D.7"
	noi esttab *, keep(`xvar') star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

} // sound
log close
***
