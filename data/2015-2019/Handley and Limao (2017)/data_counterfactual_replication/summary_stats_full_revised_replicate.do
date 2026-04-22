
clear *
clear all
set more off

***create some levels in logs tariff variables for summary stat table***


use replication_maindata1,replace

	local x=5
	local difX "unc_pre dif_advalorem_mfn_`x' dif_ln_tcost_`x'  advalorem_mfn_2000 advalorem_col2_2000"
	
	reg dif_ln_imp_`x' `difX' /*
		*/ if year==2005 , r  
	
	capture drop regsamp
	gen regsamp=e(sample)
	
	*sum advalorem_mfn advalorem_col2 ln_tcost if e(sample)
	
	di "share of total trade 2005 on baseline regression sample"
	sum regsamp [aw=imports] if year==2005
	local totsh2005=r(mean)
	
	di "share of total trade 2005 on baseline regression sample"
	sum regsamp [aw=L5.imports] if year==2005
	local totsh2000=r(mean)
	
	di "share of total growth in baseline sample is share of total trade: "`totsh2005'


	
	
/*do t-test across terciles*/

xtile unc_3=unc_pre if e(sample),n(3)
recode unc_3 (2=3)
gen tsample=e(sample)

label def bins 1 "Low" 3 "High"
label val unc_3 bins
label var unc_3 "Low Uncertainty (bottom tercile) and High Uncertainty (top 2 terciles)"


di "Summary across low vs med/hi uncertainty"
tab unc_3  if e(sample),   sum(dif_ln_imp_5)

replace ldif_ln_pindex_hs6_total=. if (pindex_sample!=1 | trim_025tails!=1)
replace dif_ln_num_prod_`x'=.  if  prod_reg_sample!=1

/*t-test reported in sumstats table
** are computed here and fed into the notes**/

ttest dif_ln_imp_`x' if tsample==1, by(unc_3) unequal
local import_t=round(`r(t)',.01)

ttest ldif_ln_pindex_hs6_total if pindex_sample==1 & trim_025tails==1, by(unc_3) unequal
local pindex_t=round(`r(t)',.01)

ttest dif_ln_num_prod_`x' if prod_reg_sample==1, by(unc_3) unequal
local prod_t=round(`r(t)',.01)


estpost tabstat dif_ln_imp_`x' ldif_ln_pindex_hs6_total dif_ln_num_prod_`x' advalorem_mfn_2000 advalorem_col2_2000 ratio_col2 unc_pre  dif_advalorem_mfn_5 dif_ln_tcost_5 if e(sample), by(unc_3) s(me sd) col(stat)



esttab, main(mean) aux(sd) nostar unstack nonote nomtitle nonumber b(2) label /*
	*/ addnotes("t-stat for high vs low differences for imports (`import_t'), prices (`pindex_t'), and varieties (`prod_t')")
esttab using table1.csv, main(mean) aux(sd) nostar unstack nonote nomtitle nonumber replace plain brack b(2) label /*
	*/ addnotes("t-stat for high vs low differences for imports (`import_t'), prices (`pindex_t'), and varieties (`prod_t')")


exit
