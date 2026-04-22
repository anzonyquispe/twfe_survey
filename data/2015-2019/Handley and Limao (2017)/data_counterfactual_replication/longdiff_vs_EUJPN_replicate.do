

set more off

use replication_appxdata3,clear



local outregfilekeep tableA5.out
local replace replace


*US, EU and Japan separate*

foreach cc of varlist USA EU JPN{



areg dif_ln_imp_5 `cc'_dif_advalorem_mfn_5  `cc'_post_unc_pre /*
		*/ if `cc'==1,  ab(section ) vce(robust)		



outreg2  using `outregfilekeep', nolabel `replace' /*
				*/cttop(`cc' ONLY, section FE , "ROBUST SE", "MATCHED", Flex Tariff ) bfmt(fc) coefastr level(95) se br  cons 
				
local replace 
				
}

*Combine JPN, EU, and US into combined  panel*			

xtset hs6


***section*ctry + h6 FE****
		
*omit US uncertainty, *
*test that effectd on omitted group is the same*
		
qui xtreg dif_ln_imp_5  JPN_dif_advalorem_mfn_5  EU_dif_advalorem_mfn_5 USA_dif_advalorem_mfn_5  EU_post_unc_pre JPN_post_unc_pre    i.nctry#i.section   /*
		*/ ,  fe vce(robust )		

*test whether effect for EU and JPN is different*
test EU_post_unc_pre =JPN_post_unc_pre
local unccon=`r(p)'		

		
test JPN_dif_advalorem_mfn_5 = USA_dif_advalorem_mfn_5=EU_dif_advalorem_mfn_5
local tarcon = `r(p)'


*constrain tariff and unc effect to be same***
xtreg dif_ln_imp_5  dif_advalorem_mfn_5  USA_post_unc_pre   i.nctry#i.section   /*
		*/ ,  fe vce(robust )		


		
outreg2  using `outregfilekeep', nolabel `replace' keep(dif_advalorem_mfn_5  USA_post_unc_pre) /*
				*/cttop(COMBINED PANEL, hs6 FE, "cluster(hs )", "MATCHED", consrt tar, ctry*section FE ) bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("TarCoeff Equal (p-val)",`tarcon',"omitted unc coefs equal (p-val)",`unccon')
		
