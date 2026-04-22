
clear *
clear all
set more off


use replication_maindata1,replace

	




/*** Baseline OLS results for Table 2 ***/

local outregfile "table2.out"
local replace replace

local year=2005	
local x=5

/* TABLE 2 (with and without sections)*/


	local restrict "UNCONSTRAINED"
	
	
	local s=3
	
/*ADVALOREM*/


	local difX unc_pre dif_advalorem_mfn_`x' dif_ln_tcost_`x'
	
	
	
	local restrict "UNCONSTRAINED"	
	constraint 1 dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
	
	reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  , r  
	
	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

	
	
	
	outreg2   `difX'  using `outregfile',  `replace' /*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
	local replace
	
	
	
	local restrict "CONSTRAINED"
	cnsreg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  , r  constraint(1)
	
	


	
	outreg2   `difX'  using `outregfile',  `replace' /*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", 1 )
				
	local restrict "UNCONSTRAINED"	

	reg dif_ln_imp_`x' `difX' i.section /*
		*/ if year==2005  , r  
	
	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
	
	
	
	outreg2   `difX'  using `outregfile',  `replace' /*
				*/cttop(`restrict', `year', sigma=`s',section dummies) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
	local replace
	
	
	
	local restrict "CONSTRAINED"
	cnsreg dif_ln_imp_`x' `difX' i.section /*
		*/ if year==2005  , r  constraint(1)
	
	

	
	outreg2   `difX'  using `outregfile',  `replace' /*
				*/cttop(`restrict', `year', sigma=`s', section dummies) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", 1 )
	

	
	exit
	
	
