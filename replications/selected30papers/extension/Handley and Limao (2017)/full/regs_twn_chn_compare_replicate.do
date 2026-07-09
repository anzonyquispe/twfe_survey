
clear all


use replication_maindata2.dta,clear


	
	local outregfile table3_panelA
	local replace replace
	
	

	local keepvars "unc_pre  dif_advalorem_mfn_5  dif_ln_tcost_5"
	
		*tercile  subsamples and restricted
	
	foreach cc in "CHINA" "TAIWAN"{	
			foreach criteria in "sunk_hs4_coeff_stat_t" {
			foreach xtile in "1"  {
			*avoid var-cov singularity by dropping sections with single obs (those w/  0are dropped by stata)*
			
			qui reg dif_ln_imp_5  unc_pre  dif_advalorem_mfn_5  dif_ln_tcost_5 i.section  if ct_twn_chn ==2 & `criteria'==`xtile' & country=="`cc'",  	
				capture drop cnt
				capture drop sample
				gen sample=1 if e(sample)
				bysort section: egen cnt = count(section) if sample==1
				
			reg dif_ln_imp_5  unc_pre  dif_advalorem_mfn_5  dif_ln_tcost_5 i.section  if ct_twn_chn ==2 & `criteria'==`xtile' & cnt>1 & country=="`cc'", r  	
				outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(unconstrained, `criteria' , tercile `xtile', `cc', section fe)
			local replace
			
			reg dif_ln_imp_5  unc_pre  dif_advalorem_mfn_5  dif_ln_tcost_5  i.section if ct_twn_chn ==2 & `criteria'~=`xtile' &  cnt>1 & `criteria'!=. & country=="`cc'", r  	
				outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(unconstrained, `criteria' , tercile~ `xtile', `cc',section fe)
				
					}
					}
				}

		
				
				
				
				
			
	local keepvars "CHINA_unc_pre  dif_advalorem_mfn_5  dif_ln_tcost_5"	
				
		/****RUN WITH EU AND taiwan COMBINED *****/
		
xtset hs6		
		foreach criteria in "sunk_hs4_coeff_stat_t" {
			
			foreach xtile in "1"  {
			*avoid var-cov singularity by dropping sections with single obs (those w/  0are dropped by stata)*
			
			qui reg dif_ln_imp_5 c. unc_pre CHINA_unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   i.section  if ct_twn_chn ==2 & `criteria'==`xtile' ,  	
				capture drop cnt
				capture drop sample
				gen sample=1 if e(sample)
				bysort section country: egen cnt = count(section) if sample==1
				
				
			xtreg dif_ln_imp_5  CHINA_unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5   i.CHINA#i.section  if ct_twn_chn ==2 & `criteria'==`xtile' &  cnt>1 , fe r  	
				outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(unconstrained, `criteria' , tercile `xtile', POOL, hs6 fe/cluster, ctry*section FE)
							
			xtreg dif_ln_imp_5  CHINA_unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5    i.section#i.CHINA  if ct_twn_chn ==2 & `criteria'~=`xtile' &  cnt>1 &   `criteria'!=. , fe r  	
				outreg2 using  `outregfile'.out,  `replace' keep(`keepvars' ) /*
					*/ bfmt(fc) coefastr level(95) se br  cons   ctitle(unconstrained, `criteria' , tercile~ `xtile', POOL, hs6 fe/cluster)	
			
					}
					}
				
				
exit
