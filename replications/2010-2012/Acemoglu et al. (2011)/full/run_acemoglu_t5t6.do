* =============================================================================
* Acemoglu et al. (2011) - CONTINUATION: Tables 5 and 6
* (Tables 2-4 already completed successfully)
* =============================================================================

clear all
set more off
set maxvar 10000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Acemoglu et al. (2011)/20100816_replication10"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Acemoglu et al. (2011)/full"

cap which outreg2
if _rc ssc install outreg2, replace
cap which xtivreg2
if _rc ssc install xtivreg2, replace
cap which ivreg2
if _rc ssc install ivreg2, replace
cap which ranktest
if _rc ssc install ranktest, replace

cd "$datadir"

log using "$outdir/run_acemoglu_t5t6.log", text replace

* =============================================================================
* TABLE 5: Cross-sectional Agriculture/Industry
* =============================================================================
di _n "===== TABLE 5: Agriculture and Industry ====="

log using "$outdir/table5.log", text replace name(t5)

use "$datadir/20100816_replication_dataset_t5.dta", clear
tsset id year
drop if year>1914

levelsof year, local(timeperiods)

local first = 1
* Agriculture: West Elbe, weighted
foreach X of local timeperiods {
    di _n "--- Table 5, Col 1, year `X' ---"
    reg agric fpresence if year==`X' & imputed==0 & westelbe==1 [aweight=pop1849], cl(state)
    if `first' == 1 {
        outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C1 yr`X'") replace
        local first = 0
    }
    else {
        outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C1 yr`X'")
    }
}

* Agriculture: West Elbe, unweighted
foreach X of local timeperiods {
    di _n "--- Table 5, Col 2, year `X' ---"
    reg agric fpresence if year==`X' & imputed==0 & westelbe==1, cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C2 yr`X'")
}

* Agriculture: All, weighted
foreach X of local timeperiods {
    di _n "--- Table 5, Col 3, year `X' ---"
    reg agric fpresence if year==`X' & imputed==0 [aweight=pop1849], cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C3 yr`X'")
}

* Industry: West Elbe, weighted
foreach X of local timeperiods {
    di _n "--- Table 5, Col 4, year `X' ---"
    reg industry fpresence if year==`X' & imputed==0 & westelbe==1 [aweight=pop1849], cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C4 yr`X'")
}

* Industry: West Elbe, unweighted
foreach X of local timeperiods {
    di _n "--- Table 5, Col 5, year `X' ---"
    reg industry fpresence if year==`X' & imputed==0 & westelbe==1, cluster(state)
    outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C5 yr`X'")
}

* Industry: All, weighted
foreach X of local timeperiods {
    di _n "--- Table 5, Col 6, year `X' ---"
    reg industry fpresence if year==`X' & imputed==0 [aweight=pop1849], cluster(state)
    outreg2 fpresence using "$outdir/table5_results.xls", br noaster ctitle("T5 C6 yr`X'")
}

log close t5

* =============================================================================
* TABLE 6: Instrumental Variables
* =============================================================================
di _n "===== TABLE 6: Instrumental Variables ====="

use "$datadir/20100816_replication_dataset.dta", clear
keep if year==1700 | year==1750 | year==1800 | year==1850 | year==1875 | year==1900
drop yr1880 yr1885 yr1895 yr1905 yr1910

log using "$outdir/table6.log", text replace name(t6)

* Column 1: Baseline weighted
di _n "--- Table 6, Column 1 ---"
xtreg urbrate yearsref yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C1 PanelA") br noaster nocons addstat(N States, e(df_a)+1) replace

cap noi xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=. & westelbe==1 [aweight=totalpop1750], fe robust cluster(id) small
cap noi outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ctitle("T6 C1 PanelB")

cap noi xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe robust cluster(id) first
cap noi outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C1 PanelC") br noaster nocons

* Column 2: Overid
di _n "--- Table 6, Column 2 ---"
xtreg urbrate yearsref yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C2 PanelA") br noaster nocons

cap noi xtivreg2 urbrate (yearsref= fpresence1850 fpresence1875 fpresence1900) yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe robust cluster(id)
cap noi outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C2 PanelC") br noaster nocons

cap noi xtivreg2 urbrate (yearsref= fpresence1850 fpresence1875 fpresence1900) yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe robust first
cap noi outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C2 PanelB") br noaster nocons

* Column 3: Unweighted
di _n "--- Table 6, Column 3 ---"
xtreg urbrate yearsref yr1750-yr1900 if westelbe==1, fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C3 PanelA") br noaster nocons

cap noi xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=. & westelbe==1, fe robust cluster(id) small
cap noi outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ctitle("T6 C3 PanelB")

cap noi xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900 if westelbe==1, fe robust cluster(id) first
cap noi outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C3 PanelC") br noaster nocons

* Column 4: All, weighted
di _n "--- Table 6, Column 4 ---"
xtreg urbrate yearsref yr1750-yr1900 [aweight=totalpop1750], fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C4 PanelA") br noaster nocons

cap noi xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=. [aweight=totalpop1750], fe robust cluster(id) small
cap noi outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ctitle("T6 C4 PanelB")

cap noi xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900 [aweight=totalpop1750], fe robust cluster(id) first
cap noi outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C4 PanelC") br noaster nocons

* Column 5: All, unweighted
di _n "--- Table 6, Column 5 ---"
xtreg urbrate yearsref yr1750-yr1900, fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C5 PanelA") br noaster nocons

cap noi xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=., fe robust cluster(id) small
cap noi outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ctitle("T6 C5 PanelB")

cap noi xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900, fe robust cluster(id) first
cap noi outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C5 PanelC") br noaster nocons

log close t6

di _n "===== TABLES 5 AND 6 COMPLETE ====="

cap log close _all
