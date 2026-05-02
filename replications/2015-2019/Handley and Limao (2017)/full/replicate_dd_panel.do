


use "replication_appxdata5",clear



/* DOUBLE DIFFERENCES and Pre-accession trends*/
xtset hs6 year
	
			local x=5
			local year=2005

			local prex=3
			local preyear=`year'-`x'-1 
			
			local outregfile tableA7.out
local replace replace

	    gen dd_`x'=(ln(imports)-ln(L`x'.imports))/`x' - (ln(L6.imports)-ln(L9.imports))/3 if ye==`year'
	    gen unc_2000=unc_pre/`x' if ye==`year'
	    gen dd_tc`x'=(ln_tcost-L`x'.ln_tcost)/`x' - (L6.ln_tcost-L9.ln_tcost)/3 if ye==`year'
		
		
		
	      gen dd_adv`x'=(advalorem_mfn-L`x'.advalorem_mfn)/`x' - (L6.advalorem_mfn-L9.advalorem_mfn)/3 if ye==`year'
		
	    gen dd_TTB`x'=(TTB-L5.TTB)/5 - (L6.TTB-L9.TTB)/3 if ye==`year'
	    gen dd_MFA`x'=(MFA-L5.MFA)/5 - (L6.MFA-L9.MFA)/3 if ye==`year'

		gen predefined=(L9.unc_adv_mfn_col2_zero!=.)
	
		
		/*set sample*/
		qui reg  dd_5 unc_2000  dd_adv5 dd_tc5  if year==`year'  &  out_tc_`prex'_`preyear'~=1 , r
				
		capture drop ddsample common		
		gen ddsample =1 if e(sample)
		bysort hs6: egen common=min(ddsample)
	
	
		/* unified pre and post sample */
		
		rreg  dd_5 unc_2000 dd_adv5 dd_tc5  if year==`year' &  out_tc_`prex'_`preyear'~=1 & predefined==1 , nolog tune(6)
				outreg2  test_5   dd_adv5 dd_tc5  using `outregfile', nolabel replace /*
					*/cttop(unconstrained, rreg 2005 5 lag, pre-period sample) bfmt(fc) coefastr level(95) se br nocons  
		 
		rreg  dd_5 unc_2000  dd_adv5 dd_tc5 dd_TTB5 dd_MFA5 if year==`year'  &  out_tc_`prex'_`preyear'~=1 & predefined==1 , nolog tune(6)
				outreg2  test_5   dd_adv5 dd_tc5 dd_TTB5 dd_MFA5  using `outregfile', nolabel append /*
					*/cttop(unconstrained, rreg 2005 5 lag, pre-period sample) bfmt(fc) coefastr level(95) se br nocons  

					
					
					
/*Falsification check for effect in pre-period */
xtset hs6 year
local x=3
		local year=1999
capture drop dif_TTB_3
capture drop dif_MFA_3
		gen dif_TTB_3= TTB-L3.TTB	
		gen dif_MFA_3= MFA-L3.MFA
		capture drop test_3
		gen unc_1996=L`x'.unc_adv_mfn_col2_zero

		
	**pre regression**
		
		rreg dif_ln_imp_`x' unc_1996 dif_advalorem_mfn_`x' dif_ln_tcost_`x'   if year==`year' & common==1 , tune(6)
			outreg2  test_`x' dif_advalorem_mfn_`x' dif_ln_tcost_`x' using `outregfile', nolabel append /*
				*/cttop(pre unconstrained rreg, `year', lag `x') bfmt(fc) coefastr level(95) se br nocons 


		rreg dif_ln_imp_`x' unc_1996 dif_advalorem_mfn_`x' dif_ln_tcost_`x'   dif_MFA_`x' dif_TTB_`x'   if year==`year' & common==1 , tune(6)
			outreg2  test_`x' dif_advalorem_mfn_`x' dif_ln_tcost_`x' dif_MFA_`x' dif_TTB_`x' using `outregfile', nolabel append /*
				*/cttop(pre unconstrained rreg, `year', lag `x') bfmt(fc) coefastr level(95) se br nocons 

