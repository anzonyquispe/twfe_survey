


use replication_appxdata2,clear


		local outregfile tableA4

		
		 
xtset hs6

local keepvars "unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5  ln_mean_kl_00  "		


local var " ln_mean_kl" 


	*set sample to obs where KL measure available
	
	qui reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   `var'_00  
	keep if e(sample)


local replace replace


	*baseline on sample with KL measure*
		*w/o sections*
		reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   , r  	
		

	*test tc/tar constraint*
	test dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
	local tctar=`r(p)'		
						
		
					
*baseline constrained*
		
		constraint 1 dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5


		*w/o sections - no capital control to check*
		cnsreg dif_ln_imp_5 unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5  , r  	constraint(1)
		

				outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(constrained, CHINA , , , robust SE)/*
					*/ addstat( "TC/TAR constr (pval)", `tctar' )
				
		local replace
		
		
		*w/o sections*
		reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   `var'_00  , r  	
		

		*test tc/tar constraint*
		test dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
		local tctar=`r(p)'		
						
		cnsreg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   `var'_00  , r  	constraint(1)
		

				outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(constrained, CHINA , , , robust SE)/*
					*/ addstat( "TC/TAR constr (pval)", `tctar' )
					
		local replace
		
		*w/ section dummies*

	
		reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   `var'_00  i.section, r  	
		
		*test tc/tar constraint*
		test dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
		local tctar=`r(p)'	
		
		cnsreg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   `var'_00  i.section , r  constraint(1)

		
		outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(constrained, CHINA , ,sections , robust SE)/*
					*/ addstat( "TC/TAR constr (pval)", `tctar' )

					
	*continuous demeaned interaction*
		
		sum ln_mean_kl_00 if e(sample)
	
		capture drop center_ln_mean_kl
	
		gen double center_ln_mean_kl=ln_mean_kl_00-`r(mean)'
		
		gen unc_pre_Xcenter_ln_mean_kl=unc_pre*center_ln_mean_kl
		
		*w/o sections*
		reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   `var'_00  unc_pre_Xcent , r  	
		

		*test tc/tar constraint*
		test dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
		local tctar=`r(p)'		

		
		constraint 1 dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
		
		
		cnsreg dif_ln_imp_5  unc_pre dif_advalorem_mfn_5 dif_ln_tcost_5  `var'_00 unc_pre_Xcent , r  	constraint(1)
		
		

				
		outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' unc_pre_Xcent) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(unconstrained, CHINA , , , robust SE) /*
					*/addstat("TC/TAR constr (pval)", `tctar' )
		
		
		*w/ section dummies*
		reg dif_ln_imp_5 unc_pre dif_advalorem_mfn_5 dif_ln_tcost_5  `var'_00 unc_pre_Xcent    i.section , r  	

		

		*test tc/tar constraint*
		test dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
		local tctar=`r(p)'

				
		constraint 1 dif_advalorem_mfn_5 =1.5*dif_ln_tcost_5
				
		cnsreg dif_ln_imp_5  unc_pre dif_advalorem_mfn_5 dif_ln_tcost_5  `var'_00 unc_pre_Xcent   i.section , r  	constraint(1)

		


		
		outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' unc_pre_Xcent) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(constrained, CHINA , ,sections , robust SE) /*
					*/addstat("TC/TAR constr (pval)", `tctar' )
					
					
					
exit

