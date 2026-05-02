
set more off

use replication_appxdata4,clear


local outregfile tableA6.out
local replace replace

constraint 1 dif_advalorem_mfn_5=1.5*dif_ln_tcost_5


local keepvars "dif_ln_imp_5 dif_advalorem_mfn_5 dif_ln_tcost_5  CHINA_unc_pre nonCH_unc_pre "

**include all of RoW **
			
*combine with ctry*section				
				
areg dif_ln_imp_5 dif_advalorem_mfn_5 dif_ln_tcost_5 CHINA_unc_pre nonCH_unc_pre /*
	*/  ,ab(ctry_section) vce(cluster hs)




outreg2  using `outregfile', nolabel `replace' keep(`keepvars') /*
				*/cttop(All NonPref, , ctry*section FE, "cluster(hs )") bfmt(fc) coefastr level(95) se br  cons /*
				*/

local replace
			
*NOW ADD HS6 FE WITH  CTRY*SECTION EFFECTS*				
		

*ctry*section effects*

xtreg dif_ln_imp_5  dif_ln_tcost_5 CHINA_unc_pre  i.ctry_section /*
	*/  ,fe robust


outreg2  using `outregfile', nolabel `replace' keep(`keepvars')/*
				*/cttop(All NonPref, hs6 FE , ctry*section FE, "cluster(hs )") bfmt(fc) coefastr level(95) se br  cons 
		
	


use replication_maindata2.dta,clear

gen nonCH_unc_pre=(1-CHINA)*unc_pre

egen ctry_section=group(country section)		
areg dif_ln_imp_5 dif_advalorem_mfn_5 dif_ln_tcost_5 CHINA_unc_pre nonCH_unc_pre /*
	*/  ,ab(ctry_section) vce(cluster hs)


outreg2  using `outregfile', nolabel `replace' keep(`keepvars') /*
				*/cttop(china & twn, , ctry*section FE, "cluster(hs )") bfmt(fc) coefastr level(95) se br  cons /*
				*/

xtset hs6
xtreg dif_ln_imp_5  CHINA_unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5    i.ctry_section if ct_twn_chn ==2  , fe r  

	
	outreg2 using  `outregfile',  `replace' keep(`keepvars' ) /*
					*/cttop(china & twn, hs6 FE, ctry*section FE, "cluster(hs )") bfmt(fc) coefastr level(95) se br  cons 
					
