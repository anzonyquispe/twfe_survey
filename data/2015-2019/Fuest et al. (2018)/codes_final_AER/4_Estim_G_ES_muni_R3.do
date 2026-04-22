**************************************************************
**************************************************************
*****        do-file 4_Estim_G_ES_muni_R3.do    	 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Descriptive statistics and event study regressions on municipal level 
** Aggregation level: Municipality 

//  Preliminaries 
pause on
set more off
local sound qui
capture log close

log using "${log}/4_Estim_${pro}_${sam}_ES_muni_R3.log", replace

`sound' {

	/* **************************************************************
	*********************   Generate Panel      *********************
	************************************************************** */

	use "${data}/3_Comb_F_${pro}_${sam}_longjim.dta" , replace

	keep if merged == 0
	keep if numbw > 3
	keep if norfswitch == 1

	bys ao_gem: keep if _n == 1
	gen idi = 1
	keep ao_gem idi
	tempfile idi
	save `idi', replace

	use "${data}\gewerb_gem_stand2010_aufb_${pro}", clear
	merge m:1 ao_gem using `idi', keep(3) nogen
		
	/* **************************************************************
	*********************   Descriptives        *********************
	************************************************************** */
	
	// Share of tax changes by size 
	local cut = 5
	qui count if taxchange < -`cut' | (taxchange > `cut' & taxchange < .)
	local dropped = r(N)
	qui count if taxchange <. 
	local tot = r(N) 
	local share = round(100*(`dropped'/`tot'),0.1)

	count 
	local tabobs = r(N)

	su taxchange if taxchange > 0 & taxchange <. , d
	local mean = r(mean)
	local p75 = r(p75)

	noi di "Descriptives of muni sample"
	noi di ""
	noi di "Desitributional measures of tax increases" 
	noi tabstat taxchange if taxchange > 0 & taxchange <. , s(mean p50 p75 min max N)

	gen tc_grp = . 
	replace tc_grp = -4.75 if taxchange >= -5.0 & taxchange < -4.5
	replace tc_grp = -4.25 if taxchange >= -4.5 & taxchange < -4.0
	replace tc_grp = -3.75 if taxchange >= -4.0 & taxchange < -3.5
	replace tc_grp = -3.25 if taxchange >= -3.5 & taxchange < -3.0
	replace tc_grp = -2.75 if taxchange >= -3.0 & taxchange < -2.5
	replace tc_grp = -2.25 if taxchange >= -2.5 & taxchange < -2.0
	replace tc_grp = -1.75 if taxchange >= -2.0 & taxchange < -1.5
	replace tc_grp = -1.25 if taxchange >= -1.5 & taxchange < -1.0
	replace tc_grp = -0.75 if taxchange >= -1.0 & taxchange < -0.5
	replace tc_grp = -0.25 if taxchange >= -0.5 & taxchange <  0.0

	replace tc_grp =  0.25 if taxchange > 0.0 & taxchange <=  0.5		
	replace tc_grp =  0.75 if taxchange > 0.5 & taxchange <=  1.0
	replace tc_grp =  1.25 if taxchange > 1.0 & taxchange <=  1.5
	replace tc_grp =  1.75 if taxchange > 1.5 & taxchange <=  2.0
	replace tc_grp =  2.25 if taxchange > 2.0 & taxchange <=  2.5
	replace tc_grp =  2.75 if taxchange > 2.5 & taxchange <=  3.0
	replace tc_grp =  3.25 if taxchange > 3.0 & taxchange <=  3.5
	replace tc_grp =  3.75 if taxchange > 3.5 & taxchange <=  4.0
	replace tc_grp =  4.25 if taxchange > 4.0 & taxchange <=  4.5
	replace tc_grp =  4.75 if taxchange > 4.5 & taxchange <=  5.0

	tab tc_grp ,g(D_tc_grp)
	tabstat D_tc* ,  s(mean) c(s) save 
	cap tabstatmat A 
	mat A = A'
	noi di "Die following number is the share of municipality-year observations"
	noi di "with very large (>5 pp) or very small (<-5pp) tax rate changes: `share'"
	noi di "The total number of municipality-year observations is N=`tabobs', while each municipality has at least 4 workers (s. line 32)"
	noi di 
	noi di "The following table describes the intensity of tax rate changes within size groups" 
	noi di "as above: N=`tabobs' and in each municipality-year there are four or more workers."
	noi mat list A

	// Number of reforms in sample
	sort ao_gem jahr	
	replace gewerb = gewerb/100	
	gen changers = D.gewerb != 0 & L.gewerb != .
	gen uppchangers = D.gewerb > 0 & L.gewerb != .
	gen downchangers = D.gewerb < 0 & L.gewerb != .

	sum changers, d
	local all_reform = r(mean)*r(N)
	sum changers, d, if merged_muni == 0
	local nm_reform = r(mean)*r(N)

	noi di ""
	noi di "Number of tax reforms in sample: `all_reform' (N=`tabobs')"
	noi di ""

	// Share of munis with increases, decreases and any change plus avg. size of change
	local fpy = 1993 
	local lpy = 2012
	local levjahr : subinstr local levjahr "`fpy'" ""

	cap mat drop changersmat uppchangersmat downchangersmat allchange

	foreach v in changers uppchangers downchangers {

		su `v' if jahr > `fpy'
		scalar appendsa = round(r(mean)*100,0.1)
		scalar appendNa = r(N)
		su D.gewerb if `v' == 1 & jahr > `fpy',mean
		scalar appendma = round(r(mean),0.01)

		mat `v'mat = appendsa, appendma, appendNa  // \ appendsn, appendmn, appendNn  \ appendsm, appendmm , appendNm

		if "`v'" == "changers"      mat coln `v'mat = share avechange obs
		if "`v'" == "uppchangers"   mat coln `v'mat = share aveincrease obs
		if "`v'" == "downchangers"  mat coln `v'mat = share avedecrease obs

		foreach j of local levjahr {
		su `v' if jahr > `fpy' & jahr == `j' & merged_muni == 0,mean
			scalar appends = round(r(mean)*100,0.1)
		su D.gewerb if `v' == 1 & jahr > `fpy' & jahr == `j' & merged_muni == 0,mean
		scalar appendm = round(r(mean),0.01)
		 if "`v'" == "downchangers" {
		    su emtr if jahr >`fpy' & jahr == `j',mean
		    scalar appende = round(r(mean)*100,0.01)
		}
		mat append = appends, appendm
			mat `v'mat = `v'mat \ append
		}

		mat rown `v'mat = allmunis // nonmergedmunis mergedmunis `levjahr'

		mat allchange = nullmat(allchange) , `v'mat

	}
	
	noi di ""
	noi di "Distribution of overall tax changes and respective sizes" 
	
	noi di "The following table shows the share of municipality-year observations with tax rate change and the average size of the tax change"
	noi di "There are three blocks with three column each." 
	noi di "Block 1 [cols 1-3] summarizes all changes (positive and negative)"
	noi di "Block 2 [cols 4-6] summarizes positive changes only"
	noi di "Block 3 [cols 7-9] summarizes negative changes only"
	noi di "In each block, the number of observations is listed in the third column"
	noi mat list allchange


	// Number of (large) increases by municipality
	gen changing = taxchange > 0 & taxchange < . 
	bysort ao_gem: egen totchangers = total(changing)
	gen bigchange = taxchange >= `p75' & taxchange < .
	bysort ao_gem: egen totbigchangers = total(bigchange)

	replace totchangers = 4 if totchangers > 4 & totchangers < .
	replace totbigchangers = 4 if totbigchangers > 4 & totbigchangers < .
	label define totchangeslb 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+" 
	label define totbchangeslb 1 "1" 2 "2" 3 "3" 4 "4+" 
	label value totchangers totchangeslb
	label value totbigchangers totbchangeslb

	noi di ""
	noi di "Distribution of municipalities by tax changes" 
	noi di ""
	noi di "The following table lists the the number of tax increases in the municipality-year sample" 
	noi di "The first tables counts all tax increases, the second only large tax increases"
	foreach c in totchangers totbigchangers {
		noi tabstat jahr if inrange(jahr,1999,2008), s(N) by(`c')          
	} // c


	/* **************************************************************
	*********************   Event study design  *********************
	************************************************************** */
	
	// Wage sample
	keep if inrange(jahr,1999,2008) 

	// Regression command	
	local regn xtreg
	local opt fe i(ao_gem) vce(cluster ao_gem) nonest noomitted noemptycells
	
	// LHS variables	
	gen lbip_pc = ln(bip/popul)
	gen lalq = ln(alq)
	gen lrevenues_pc = ln(revenues/popul)
	gen lexpenses_pc = ln(expenses/popul)
	gen surplus_pc = 1000*(revenues-expenses)/(popul)  // fiscal surplus per 1000 inhabitants

	// RHS Variables
	local xvars1 F?_taxhike L?_taxhike
	local xvars2 F?_p75taxhike L?_p75taxhike
	local xvars3 F?_taxdrop L?_taxdrop
	local X_busi bl#jahr

	/* Figures 4A, D.4A and Table D.15*/
	eststo clear
	eststo, title(hikes_0D): 	`regn' lbip_pc `xvars1' `X_busi'	if totaldrops==0 , `opt'
	eststo, title(hikes_p75_0D): 	`regn' lbip_pc `xvars2' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(drops_0H): 	`regn' lbip_pc `xvars3' `X_busi' 	if totalhikes==0 , `opt'

	noi di "Results from Figures 4A, D.4A and Table D.15"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Figures 4B, D.4B and Table D.16*/
	eststo clear
	eststo, title(hikes_0D): 	`regn' lalq `xvars1' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(hikes_p75_0D): 	`regn' lalq `xvars2' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(drops_0H): 	`regn' lalq `xvars3' `X_busi' 	if totalhikes==0 , `opt'

	noi di "Results from Figures 4B, D.4B and Table D.16"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Figures D.5A and Table D.17*/
	eststo clear
	eststo, title(hikes_0D): 	`regn' lrevenues_pc `xvars1' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(hikes_p75_0D): 	`regn' lrevenues_pc `xvars2' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(drops_0H): 	`regn' lrevenues_pc `xvars3' `X_busi' 	if totalhikes==0 , `opt'

	noi di "Results from Figures D.5A and Table D.17"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Figures D.5B and Table D.18*/
	eststo clear
	eststo, title(hikes_0D): 	`regn' lexpenses_pc `xvars1' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(hikes_p75_0D): 	`regn' lexpenses_pc `xvars2' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(drops_0H): 	`regn' lexpenses_pc `xvars3' `X_busi' 	if totalhikes==0 , `opt'

	noi di "Results from Figures D.5B and Table D.17"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

	/* Figures D.5C and Table D.19*/
	eststo clear
	eststo, title(hikes_0D): 	`regn' surplus_pc `xvars1' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(hikes_p75_0D): 	`regn' surplus_pc `xvars2' `X_busi' 	if totaldrops==0 , `opt'
	eststo, title(drops_0H): 	`regn' surplus_pc `xvars3' `X_busi' 	if totalhikes==0 , `opt'

	noi di "Results from Figures D.5C and Table D.19"
	noi esttab *, keep(*tax*) star(* 0.1 ** 0.05 *** 0.01) se scalar(N_clust) mtitles compress noabbrev
	noi di ""

 } // sound

log close 
 **
 
 
