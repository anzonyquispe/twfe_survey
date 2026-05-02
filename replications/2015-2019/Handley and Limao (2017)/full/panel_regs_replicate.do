

use replication_appxdata6,clear

local outregfile tableA8.out
local replace replace
local restrict "UNCONSTRAINED"


*gen pre and post variables, allowing uncertainty to vary by  year.
gen post=(year>2001)
gen post_X_unc=unc_adv_mfn_col2_zero_sig*post
gen pre_X_unc=unc_adv_mfn_col2_zero_sig*(1-post)
	
	
	
reghdfe ln_imp advalorem_mfn ln_tcost _IyeaXfix_1996 _IyeaXfix_1997 _IyeaXfix_1998 _IyeaXfix_1999 _IyeaXfix_2001 _IyeaXfix_2002 _IyeaXfix_2003 _IyeaXfix_2004 _IyeaXfix_2005 _IyeaXfix_2006   /*
		*/  , ab(hs6 section_yr ) cluster(hs6 section_yr)

		
test _b[advalorem_mfn]=1.5*_b[ln_tcost]	
local tarcon=r(p)

outreg2 advalorem_mfn ln_tcost _IyeaXfix_* using `outregfile', nolabel `replace' /*
				*/cttop(`restrict', sigma=3, section*yr FE, hs FE, "cluster(hs6 yr*section)" , "fixed@2000 unc") bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", `tarcon')
				
local replace

/** NOW FIX COEFF PRE AND POST PERIOD ***/				
				

reghdfe ln_imp advalorem_mfn ln_tcost pre_X_unc post_X_unc   /*
		*/ , ab(hs6 section_yr) cluster(hs6 section_yr)
	
		
test _b[advalorem_mfn]=1.5*_b[ln_tcost]	
local tarcon=r(p)

outreg2 advalorem_mfn ln_tcost pre_X_unc post_X_unc using `outregfile', nolabel `replace' /*
				*/cttop(`restrict', sigma=3, section*yr FE, hs FE, "cluster(hs yr*section )" ,  "pre vs post") bfmt(fc) coefastr level(95) se br  cons /*
				*/addstat("Restriction (p-val)", `tarcon')

exit
