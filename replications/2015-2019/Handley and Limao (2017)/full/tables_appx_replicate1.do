
clear *
clear all
set more off


	
local x=5
	
	
/*** Robustness Across Sigma=2,3,4 Assumption Table A3, top panel ***/
	
	use replication_appxdata1, clear
	
	
	local outregfile "tableA3_panelA.out"
	local replace replace
	foreach s in 3 2 4{
	
	
	local difX unc_pre_sig`s' dif_advalorem_mfn_`x' dif_ln_tcost_`x'
		
	local restrict "UNCONSTRAINED"	
	
	reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  , r  
	
		test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

	
	
	
	outreg2    using `outregfile',  `replace' keep(unc_pre_sig`s') /*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br nocons  /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
	local replace
	
	reg dif_ln_imp_`x' `difX' i.section/*
		*/ if year==2005  , r  
	
		test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

	
	
	
	outreg2   using `outregfile',  `replace' keep(unc_pre_sig`s') /*
				*/cttop(`restrict', `year', sigma=`s',section dummies) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
	
	}
	
	
	*** now use Broda Weinstein median sigmas ***
	
	*create transformed tariff measure and then test equaility of coeffs*
	gen dif_advalorem_mfn_bwsig_5=(median_sig/(median_sig-1))*dif_advalorem_mfn_5
	
	local difXsig2 unc_pre_bwsig dif_advalorem_mfn_bwsig_5 dif_ln_tcost_5
	
	
	
	
	reg dif_ln_imp_5 `difXsig2' /*
		*/ if year==2005  , r  
	
	test dif_advalorem_mfn_bwsig_5=dif_ln_tcost_5
	outreg2     using `outregfile',  `replace' keep(unc_pre_bwsig)/*
				*/cttop(Variable Sigma, `year', sigma from Broda-Weinstein, ) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				

	
	reg dif_ln_imp_5 `difXsig2' i.section/*
		*/ if year==2005  , r  
	test dif_advalorem_mfn_bwsig_5=dif_ln_tcost_5
	
	outreg2     using `outregfile',  `replace' keep(unc_pre_bwsig)/*
				*/cttop(Variable Sigma, `year', sigma from Broda-Weinstein, section dummies ) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
	
	
	
	
	/*** Table A2, Robustness to NTBs  ***/
	
	local outregfile "tableA2.out"
	local restrict "UNCONSTRAINED"
	local replace replace 

local s=3
	
	
/*ADVALOREM*/


*ADV base

local difX unc_pre dif_advalorem_mfn_5  dif_ln_tcost_5
	
	xi: reg dif_ln_imp_5 `difX' /*
		*/ if year==2005  , r  
		
		test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
	
	outreg2   `difX'  using `outregfile', nolabel `replace' /*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
	local replace
					
*ADV base + TTB, MFA
	local difX unc_pre dif_advalorem_mfn_5 dif_MFA_5 dif_TTB_5 dif_ln_tcost_5
	
	xi: reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  , r  

	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
	
	outreg2   `difX'  using `outregfile', nolabel `replace' /*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", `r(p)')
				
* ADV base + TTB, MFA + SECTION

reg dif_ln_imp_5 `difX' /*
		*/ i.section /*
		*/ if year==2005  , r  

	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
	
	outreg2   `difX'  using `outregfile', nolabel `replace' /*
				*/cttop(`restrict', `year', sigma=`s',sections) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )
				
/*ADV base + TTB, MFA + SECTION: IV TTB W/ 2 LEVEL LAGS (L6, L7):*/

local difX unc_pre dif_advalorem_mfn_5 dif_MFA_5 dif_ln_tcost_5

	
xi: ivreg2 dif_ln_imp_5 `difX' (dif_TTB_5=lag6_TTB lag7_TTB) /*
		*/ i.section /*
		*/ if year==2005 , r  first endog(dif_TTB_5)
	
	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
	
	outreg2   `difX' dif_TTB_`x' using `outregfile', nolabel `replace' /*
				*/cttop(`restrict', `year', sigma=`s',IV TTB w sections) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' ,/*				
				*/ "F-Stat 1st Stage", e(widstat), "Over ID Restrict(p-val)",e(jp))

* ADV base + TTB, MFA + SECTION constrained**
constraint 1 dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'
local difX unc_pre dif_advalorem_mfn_`x' dif_MFA_`x' dif_TTB_`x' dif_ln_tcost_`x'


xi: cnsreg dif_ln_imp_`x' `difX' /*
		*/ i.section /*
		*/ if year==2005  , r  constraint(1)


	
	outreg2   `difX'  using `outregfile', nolabel `replace' /*
				*/cttop(CONSTRAINED, `year', sigma=`s',sections) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", 1 )



/*** Table A3 Panel B ****/
				
				
/*PANEL B*/

/* AD VALOREM EQUIVALENT */
local outregfile tableA3_panelB.out
	local restrict "UNCONSTRAINED"
	local replace replace 

	local s=3
	
	
*ADV baseline
local difX unc_pre dif_advalorem_mfn_`x' dif_ln_tcost_`x'
	
	
	
	local restrict "UNCONSTRAINED"	
	
	reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  , r  
	
	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

	
	outreg2   `difX'  using `outregfile',  `replace' keep(unc_pre)/*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )

	local replace		
	reg dif_ln_imp_`x' `difX' i.section/*
		*/ if year==2005  , r  
	
		test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

	
	outreg2   `difX'  using `outregfile',  `replace' keep(unc_pre)/*
				*/cttop(`restrict', `year', sigma=`s',section dummies) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )

	
*Outlier Robust Reg*

*ADV base rreg

	rreg dif_ln_imp_`x' `difX' /*
		*/ if year==2005 
		
		
	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

		outreg2     using `outregfile', nolabel `replace' keep(unc_pre) /*
				*/cttop(RobustREG , `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat( "Restriction (p-val)", `r(p)')
				
	local replace
	
*ADV base RREG + sections

	rreg dif_ln_imp_`x' `difX' /*
		*/ i.section /*
		*/ if year==2005 
		
	
	test dif_advalorem_mfn_`x'=((`s')/(`s'-1))*dif_ln_tcost_`x'

	
	outreg2     using `outregfile', nolabel `replace' keep(unc_pre)/*
				*/cttop(RobustREG , `year', sigma=`s', section dummies) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)')
				
** Selection (ln growth) OLS in midpoint growth measure **

local difX unc_pre dif_advalorem_mfn_5  dif_ln_tcost_hybrid_5
	
	reg dif_imports0_5 `difX' /*
		*/ if year==2005 , r  
	
	test dif_advalorem_mfn_`x' = `s'/(`s'-1)*dif_ln_tcost_hybrid_`x'
	outreg2   `difX'  using `outregfile', nolabel `replace' keep(unc_pre) /*
				*/cttop(midpoint growth, `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat( "Restriction (p-val)", `r(p)')
				
				
	reg dif_imports0_5 `difX' i.section/*
		*/ if year==2005 , r  
	
	test dif_advalorem_mfn_`x' = `s'/(`s'-1)*dif_ln_tcost_hybrid_`x'
	outreg2   `difX'  using `outregfile', nolabel `replace' keep(unc_pre) /*
				*/cttop(midpoint growth, `year', sigma=`s', section dummies) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat( "Restriction (p-val)", `r(p)')
	
*AVE included on baseline

	


local difX unc_pre_ave dif_ave_total_mfn_`x'  dif_ln_tcost_`x'
	
	reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  , r  
		
	test dif_ave_total_mfn_`x' =((`s')/(`s'-1))*dif_ln_tcost_`x'	
	
	outreg2   `difX'  using `outregfile', nolabel `replace' keep(unc_pre_ave) /*
				*/cttop(`restrict', `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)", `r(p)' )
	
	
				
* AVE base + SECTION

	reg dif_ln_imp_`x' `difX' i.section /*
		*/ if year==2005 , r  
		
	test dif_ave_total_mfn_`x' =((`s')/(`s'-1))*dif_ln_tcost_`x'	

		
	outreg2   `difX'  using `outregfile', nolabel `replace' keep(unc_pre_ave) /*
				*/cttop(`restrict', `year', sigma=`s',section dummies) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat( "Restriction (p-val)", `r(p)')
				
		

		
		
/** Processing  Trade Robust, drop HS2==84,85**/

gen hs2=real(substr(hs6hs1,1,2)	)
		
local difX unc_pre dif_advalorem_mfn_`x'  dif_ln_tcost_`x'
	
*ADV base + drop processing (hs84,85)
	
	
	reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005  & hs2!=84 & hs2!=85 , r  

	test dif_advalorem_mfn_`x'=(`s'/(`s'-1))*dif_ln_tcost_`x'
	
	outreg2   `difX'  using `outregfile', nolabel `replace' keep(unc_pre) /*
				*/cttop(drop hs2=84-85, `year', sigma=`s',) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)",`r(p)')
	local replace		
	
* ADV base + section+drop processing (hs84,85)

 reg dif_ln_imp_`x' `difX' /*
		*/ i.section /*
		*/ if year==2005  & hs2!=84 & hs2!=85, r  

	test dif_advalorem_mfn_`x'=(`s'/(`s'-1))*dif_ln_tcost_`x'
	
	outreg2   `difX'  using `outregfile', nolabel `replace' keep(unc_pre)/*
				*/cttop(drop hs2=84-85, `year', sigma=`s', section dummies) bfmt(fc) coefastr level(95) se br  nocons /*
				*/addstat("Restriction (p-val)",`r(p)')
		
		


exit


