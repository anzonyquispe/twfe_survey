set more off
local outregfile tableA9.out
local replace replace

/*** China and Rest of World (ROW) sample test ****/


use replication_appxdata7,clear

*combine with ctry*section				
				
areg ldif_ln_pindex_hs6_total dif_advalorem_mfn_5 dif_ln_tcost_5 CHINA_fixunc2000 nonCH_fixunc2000 /*
	*/  ,ab(ctry_section) vce(cluster hs)



outreg2  using `outregfile', nolabel `replace' drop(i.ctry_section) /*
				*/cttop("China & ROW", , ctry*section FE, "cluster(hs )", "MATCHED", trim025 tails  ) bfmt(fc) coefastr level(95) se br  cons 

local replace



*ctry*section effects*

xtreg ldif_ln_pindex_hs6_total dif_advalorem_mfn_5 dif_ln_tcost_5 CHINA_fixunc2000  i.ctry_section /*
	*/  ,fe robust


outreg2  using `outregfile', nolabel `replace'  keep(dif_ln_tcost_5 CHINA_fixunc2000)/*
				*/cttop("China & ROW", hs6 FE, ctry*section FE, "cluster(hs )", "MATCHED",trim025 tails ) bfmt(fc) coefastr level(95) se br  cons 

	
/*** China & Taiwan Test****/

use replication_appxdata8,clear

			
areg ldif_ln_pindex_hs6_total dif_advalorem_mfn_5 dif_ln_tcost_5 CHINA_fixunc2000 nonCH_fixunc2000 /*
	*/  ,ab(ctry_section) vce(cluster hs)



outreg2  using `outregfile', nolabel `replace'  drop(i.ctry_section) /*
				*/cttop("China & Taiwan", , ctry*section FE, "cluster(hs )", "MATCHED", trim025 tails  ) bfmt(fc) coefastr level(95) se br  cons 

local replace

*ctry*section effects*

xtreg ldif_ln_pindex_hs6_total dif_advalorem_mfn_5 dif_ln_tcost_5 CHINA_fixunc2000  i.ctry_section /*
	*/  ,fe robust


outreg2  using `outregfile', nolabel `replace'  keep(dif_ln_tcost_5 CHINA_fixunc2000)/*
				*/sortvar( CHINA_fixunc2000 nonCH_fixunc2000 dif_advalorem_mfn_5 dif_ln_tcost_5) /*
				*/cttop("China & Taiwan", hs6 FE, ctry*section FE, "cluster(hs )", "MATCHED",trim025 tails ) bfmt(fc) coefastr level(95) se br  cons 
