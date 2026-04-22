**************************************************************
**************************************************************
*****   	do-file 0_GewerbDat_G.do       		 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Preparation of external municipal data 
** Aggregation level: Municipalities 
 
//  Preliminaries 
pause on
set more off
local sound qui
capture log close
log using "${log}/0_GewerbDat_${pro}.log", replace

`sound' {

	use "${orig}/gewerb_gem_stand2010", clear
	xtset ao_gem jahr
	sort ao_gem jahr

	// Administrative jurisdictions
	gen bl = floor(ao_gem/1000000)
	label var bl "state"
	gen west = bl <= 10
	gen kreis = floor(ao_gem/1000)
	label var kreis "district"
	label var amr "CZ"
	
	// Merged munis
	by ao_gem: egen merged_muni = max(averaged)
	
	// Controls
	gen lpopul = ln(popul)
	label var lpopul "log population"
		
	replace expenses = . if expenses < 0
	replace revenues = . if revenues < 0

	replace expenses = expenses/1000000 	// expenses in millions 
	replace revenues = revenues/1000000 	// revenues in millions
	replace bip = bip/1000 			// bip in millions (was already in thousands)
	
	replace alq = alq*100
	gen L2_alq = ln(L2.alq)
	gen L2_popul = ln(L2.popul)
	gen L2_bip = ln(L2.bip)
	gen L2_grundb = ln(L2.grundb)	
	gen L2_expenses = ln(L2.expenses)

	gen F1_expenses = ln(F1.expenses)
	gen F2_expenses = ln(F2.expenses)
	gen L0_expenses = ln(expenses)

	// Tax variables 
	gen taxhike = gewerb > L.gewerb & L.gewerb != .
	replace taxhike = . if L.gewerb == .

	gen taxdrop = gewerb < L.gewerb & L.gewerb != .
	replace taxdrop = . if L.gewerb == .

	gen 	messzahl = 0.05
	replace messzahl = 0.035 if jahr >= 2008
	gen taxrate = (gewerb/100 * messzahl) * 100
	gen taxchange = taxrate - L.taxrate  if L.taxrate != .

	gen muntaxchange = gewerb - L.gewerb  if L.gewerb != .
	replace taxchange = 0 if muntaxchange == 0  // only want scaling factor induced changes 

	sum muntaxchange if !mi(muntaxchange) & muntaxchange >0, d

	gen p50taxhike = muntaxchange > r(p50) & L.gewerb != . & !mi(muntaxchange)
	replace p50taxhike = . if L.gewerb == .

	gen p75taxhike = muntaxchange > r(p75) & L.gewerb != . & !mi(muntaxchange)
	replace p75taxhike = . if L.gewerb == .

	drop muntaxchange

	foreach v in taxhike taxdrop p50taxhike p75taxhike {
		forval f = 4(-1)1 {
			sort ao_gem jahr
			qui gen F`f'_`v' = F`f'.`v'
			gsort ao_gem -jahr
			if `f' == 4 bys ao_gem: gen sum_F`f'_`v' = sum(F`f'_`v')
		} //f

		forval l = 0/5  {
			sort ao_gem jahr
			qui gen L`l'_`v' = L`l'.`v'
			if `l' == 5 bys ao_gem: gen sum_L`l'_`v' = sum(L`l'_`v')
		} //l
		
		
		egen sum`v' = rowtotal(F?_`v' L?_`v') 

		replace F4_`v' = sum_F4_`v' if F4_`v' != .
		replace L5_`v' = sum_L5_`v' if L5_`v' != .

		drop sum_*_`v' F1_`v'
		
	} // v

	gen changes = taxdrop + taxhike
	bysort ao_gem: egen totalchanges = total(changes)
	bysort ao_gem: egen totalhikes = total(taxhike)    
	bysort ao_gem: egen totaldrops = total(taxdrop)
	foreach pp in p50 p75 {	
		bysort ao_gem: egen total`pp'hikes = total(`pp'taxhike)
	} //

	sort ao_gem jahr	
	forval f = 4(-1)1 {
		qui gen F`f'_taxrate = ln(100-F`f'.taxrate)
	}
	forval l = 0/6  {
		qui gen L`l'_taxrate = ln(100-L`l'.taxrate)
	} //l
	
	// Drop few muni with unplausible obs: legal minimum of 200 for local scaling factor
	sort ao_gem
	egen min_gewerb = rowmin(gewerb)
	by ao_gem: egen mingew = min(min_gewerb)
	drop if mingew <  200
	
	keep 	ao_gem name jahr bl west kreis amr ///
		*popul *revenues *expenses *alq *bip ///
		*tax* total* merged gewerb

	compress
	noi summ
	save "${data}\gewerb_gem_stand2010_aufb_${pro}", replace

} // sound

log close
****
