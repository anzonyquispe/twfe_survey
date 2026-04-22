**************************************************************
**************************************************************
*****   	do-file 3_Combine_G.do         		 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Combination of separate muni (from 0_GewerbDat_G.do), worker (from 1_PersDat_G.do), firm (from 2_BetrDat_G.do) data 
**	    to estimation samples on worker, firm and municipal level 	
** Aggregation levels: Worker, firms, muni (see below)

//  Preliminaries 
local sound qui 
set more off
pause on
capture log close

log using "${log}/3_Combine_${pro}_${sam}.log", replace

`sound' {

	/* **************************************************************
	*********************   Worker-level data   *********************
	************************************************************** */

	// Combine datasets and generate worker data 	
	
	* Load worker panel 
	use "${data}/1_PersDat_panelI_${pro}_${sam}.dta", replace
	
	* Merge firm panel
	merge m:1 idnum jahr using "${data}/2_BetrDat_panelF_${pro}.dta" , keep(match) nogen
	preserve

	* Merge muni panel
	merge m:1 ao_gem jahr using "${data}/gewerb_gem_stand2010_aufb_${pro}.dta", nogen keep(match) 
	
	* Generate some dummy / FE variables 
	egen muniyear = group(ao_gem jahr)
	egen grouper = group(persnr idnum ao_gem)
	egen grouper_emp = group(grouper emp_gr)
	qui tab ski_gr, g(D_ski)
	qui tab occ_gr, g(D_occ)
	bys idnum jahr: gen numbw = _N
	
	* Save data
	qui compress
	xtset persnr jahr
	sort persnr jahr
	noi summ
	
	save  "${data}/3_Comb_I_${pro}_${sam}_long.dta" , replace

	/* **************************************************************
	*********************   Firm-level data     *********************
	************************************************************** */
	
	* Load worker-firm data
	restore
	preserve
	sort idnum jahr

	* Generate individual shares 
	qui tab ski_gr, gen(skill_sh)
	qui tab emp_gr, gen(emp_sh)
	qui tab occ_gr, gen(occ_sh)
	local firmmean age male nevercens skill_sh* emp_sh* occ_sh*
	gen tmp_wage_full = wage if emp_gr == 1

	local usevars_firm   		singlefirm* foreignowned* profit* nocommswitch norfswitch firmsize*  ///
					*employees* tarif* rechtsform* nogew* broad_sec* branche* 
	
	* Collapse data on firm level
	collapse ///
		(mean) 	  wage_ft_mean=tmp_wage_full `firmmean'  ///
		(median)  wage_ft_p50 =tmp_wage_full   ///
		(p25)     wage_ft_p25 =tmp_wage_full ///
		(p75)     wage_ft_p75 =tmp_wage_full ///
		(first) ao_gem bl west `usevars_firm'  ///
		(count) numbwork=persnr ///
		, by(idnum jahr) fast
	
	* Generate log firm wages after collapsing
	qui ds wage_*
	foreach wa in `r(varlist)' {
		cap gen l`wa' = ln(`wa')
	} // wa

	* Merge muni vars
	noi merge m:1 ao_gem jahr using "${data}/gewerb_gem_stand2010_aufb_${pro}.dta", nogen keep(matched)

	xtset idnum jahr

	* Generate some variables

	* Local labor market power
	bys amr jahr: egen totpop = total(popul)
	gen relsize = employees_l/totpop

	qui levelsof jahr,l(yearlev)

	gen marketpower = .
	foreach j of local yearlev {
		xtile tmp_marketpower = relsize if jahr == `j',n(3) 
		replace marketpower = tmp_marketpower if jahr == `j'
		drop tmp_marketpower
	} // foreach j

	bysort idnum (jahr): replace marketpower = . if _n > 1
	by idnum: egen marketpower_base = mean(marketpower)
	drop totpop marketpower

	* Muni-year indicator 
	egen muniyear = group(ao_gem jahr)
	
	* Full-time firm median wage (for descriptive table)
	gen wage = exp(lwage_ft_p50)
	
	* Firm-muni identicator
	egen grouper = group(idnum ao_gem)
	
	* Save data
	qui compress
	xtset idnum jahr
	sort idnum jahr
	noi summ

	save  "${data}/3_Comb_F_${pro}_${sam}_longjim.dta" , replace

	/* **************************************************************
	*********************   Muni-level data	    *********************
	************************************************************** */
	
	* Main estimation sample
	keep if merged_muni == 0
	keep if norfswit == 1
	bys ao_gem jahr: egen totwork = total(employees_lev)
	keep if totwork > 3
	keep if nocomm == 1 	
	bysort idnum: keep if _N >= 5 
	
	* Collapse data
	gen firms = 1 	// weight for regression
	local munis L2_popul L2_bip L2_alq L2_expenses revenues expenses bip alq popul *taxhike* *taxdrop* total*
	collapse (mean) wage_ft_p50 *_lev `munis' bl west amr L0_taxrate (rawsum) firms , by(ao_gem jahr) fast

	* Generate log wage after collapsing
	gen lwage = ln(wage_ft_p50)

	* Save muni panel
	sort ao_gem jahr
	qui compress
	noi summ
	save "${data}/3_CombineM_${pro}_${sam}.dta", replace

} // sound

cap log close

***

