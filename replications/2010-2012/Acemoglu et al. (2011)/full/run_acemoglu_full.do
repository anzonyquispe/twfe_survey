* =============================================================================
* Acemoglu, Cantoni, Johnson & Robinson (2011)
* The Consequences of Radical Reform: The French Revolution
* AER, 101(7), 3286-3307
* FULL REPLICATION: Tables 2-6
* =============================================================================

clear all
set more off
set maxvar 10000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Acemoglu et al. (2011)/20100816_replication10"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Acemoglu et al. (2011)/full"

* Install required packages
cap which outreg2
if _rc ssc install outreg2, replace
cap which xtabond2
if _rc ssc install xtabond2, replace
cap which xtivreg2
if _rc ssc install xtivreg2, replace
cap which ivreg2
if _rc ssc install ivreg2, replace
cap which ranktest
if _rc ssc install ranktest, replace

cd "$datadir"

log using "$outdir/run_acemoglu_full.log", text replace

* =============================================================================
* TABLE 2: Summary Statistics
* =============================================================================
di _n "===== TABLE 2: Summary Statistics ====="

use "20100816_replication_dataset.dta", clear
keep if year==1700 | year==1750 | year==1800 | year==1850 | year==1875 | year==1900
drop yr1880 yr1885 yr1895 yr1905 yr1910

gen napoleon = (fpresence>0)

log using "$outdir/table2.log", text replace name(t2)

format urbrate %9.2f

di _n "===== Panel A: West of Elbe, by Treatment ====="
di _n "--- All West of Elbe ---"
by year, sort: sum urbrate if westelbe==1 [aweight=totalpop1750], format
di _n "--- Napoleon (treated) ---"
by year, sort: sum urbrate if westelbe==1 & napoleon==1 [aweight=totalpop1750], format
di _n "--- No Napoleon (control) ---"
by year, sort: sum urbrate if westelbe==1 & napoleon==0 [aweight=totalpop1750], format

di _n "--- Covariates: West of Elbe ---"
sum protestant latitude longitude distpa if westelbe==1 [aweight=totalpop1750]
sum protestant latitude longitude distpa if westelbe==1 & napoleon==1 [aweight=totalpop1750]
sum protestant latitude longitude distpa if westelbe==1 & napoleon==0 [aweight=totalpop1750]

di _n "===== Panel B: All Germany ====="
by year, sort: sum urbrate [aweight=totalpop1750], format
by year, sort: sum urbrate if napoleon==1 [aweight=totalpop1750], format
by year, sort: sum urbrate if napoleon==0 [aweight=totalpop1750], format

sum protestant latitude longitude distpa [aweight=totalpop1750]
sum protestant latitude longitude distpa if napoleon==1 [aweight=totalpop1750]
sum protestant latitude longitude distpa if napoleon==0 [aweight=totalpop1750]

log close t2

* =============================================================================
* TABLE 3: Panel Fixed Effects
* =============================================================================
di _n "===== TABLE 3: Panel Fixed Effects ====="

log using "$outdir/table3.log", text replace name(t3)

sort id year

* Column 1: West of Elbe, weighted
di _n "--- Table 3, Column 1: West of Elbe, weighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* ///
    if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test1=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table3_results.xls", ctitle("Col 1: W.Elbe, wgt") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test1') ///
    replace

* Column 2: West of Elbe, unweighted
di _n "--- Table 3, Column 2: West of Elbe, unweighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* ///
    if westelbe==1, fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test2=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table3_results.xls", ctitle("Col 2: W.Elbe, unwgt") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test2')

* Column 3: All Germany, weighted
di _n "--- Table 3, Column 3: All Germany, weighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* ///
    [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test3=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table3_results.xls", ctitle("Col 3: All, wgt") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test3')

* Column 4: All Germany, unweighted
di _n "--- Table 3, Column 4: All Germany, unweighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, ///
    fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test4=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table3_results.xls", ctitle("Col 4: All, unwgt") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test4')

log close t3

* =============================================================================
* TABLE 4: Robustness - Covariates and GMM
* =============================================================================
di _n "===== TABLE 4: Robustness ====="

log using "$outdir/table4.log", text replace name(t4)

* Column 1: Exclude Berlin
di _n "--- Table 4, Column 1: Exclude Berlin ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    yr* if westelbe==1 & id~=2 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 1: Excl Berlin") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test') replace

* Column 2: Protestant interaction
di _n "--- Table 4, Column 2: Protestant interaction ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    protestant1* yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
testparm protestant1*
local testcov=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 2: Protestant") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test', ///
    p-value joint signif covariate, `testcov')

* Column 3: Latitude interaction
di _n "--- Table 4, Column 3: Latitude interaction ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    latitude1* yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
testparm latitude1*
local testcov=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 3: Latitude") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test', ///
    p-value joint signif covariate, `testcov')

* Column 4: Longitude interaction
di _n "--- Table 4, Column 4: Longitude interaction ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    longitude1* yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
testparm longitude1*
local testcov=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 4: Longitude") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test', ///
    p-value joint signif covariate, `testcov')

* Column 5: Distance to Paris interaction
di _n "--- Table 4, Column 5: Distance to Paris ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    distpa1* yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
testparm distpa*
local testcov=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 5: Dist Paris") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test', ///
    p-value joint signif covariate, `testcov')

* Column 6: Territories interaction
di _n "--- Table 4, Column 6: Territories ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    territories1* yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
testparm territories1*
local testcov=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 6: Territories") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test', ///
    p-value joint signif covariate, `testcov')

* Column 7: Initial urbanization interaction
di _n "--- Table 4, Column 7: Initial Urbanization ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    urbanization17501* yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local test=r(p)
testparm urbanization17501*
local testcov=r(p)
outreg2 fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 7: Init Urban") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test', ///
    p-value joint signif covariate, `testcov')

* Column 8: GMM (Arellano-Bond)
di _n "--- Table 4, Column 8: GMM ---"
preserve
keep if year==1700 | year==1750 | year==1800 | year==1850 | year==1900
replace year=year/50
sort id year
tsset id year

xtabond2 urbrate L.urbrate fpresence1800 fpresence1850 fpresence1900 yr* if westelbe==1 ///
    [aweight=totalpop1750], gmm(L.urbrate) iv(yr* fpresence1800 fpresence1850 fpresence1900) ///
    robust noleveleq
test fpresence1850 fpresence1900
local test=r(p)
outreg2 L.urbrate fpresence1800 fpresence1850 fpresence1900 ///
    using "$outdir/table4_results.xls", ctitle("Col 8: GMM") br noaster nocons ///
    addstat(Number of States, e(df_a)+1, p-value joint signif after 1800,`test')
restore

log close t4

* =============================================================================
* TABLE 5: Cross-sectional Agriculture/Industry
* =============================================================================
di _n "===== TABLE 5: Agriculture and Industry ====="

log using "$outdir/table5.log", text replace name(t5)

preserve
clear
use "$datadir/20100816_replication_dataset_t5.dta"
tsset id year
drop if year>1914

levelsof year, local(timeperiods)

* Agriculture columns
foreach X of local timeperiods {
    di _n "--- Table 5, Col 1, year `X' ---"
    reg agric fpresence if year==`X' & imputed==0 & westelbe==1 [aweight=pop1849], cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", ///
        br noaster ctitle("T5 Col1 yr`X'") replace
}

foreach X of local timeperiods {
    di _n "--- Table 5, Col 2, year `X' ---"
    reg agric fpresence if year==`X' & imputed==0 & westelbe==1, cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", ///
        br noaster ctitle("T5 Col2 yr`X'")
}

foreach X of local timeperiods {
    di _n "--- Table 5, Col 3, year `X' ---"
    reg agric fpresence if year==`X' & imputed==0 [aweight=pop1849], cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", ///
        br noaster ctitle("T5 Col3 yr`X'")
}

* Industry columns
foreach X of local timeperiods {
    di _n "--- Table 5, Col 4, year `X' ---"
    reg industry fpresence if year==`X' & imputed==0 & westelbe==1 [aweight=pop1849], cl(state)
    outreg2 fpresence using "$outdir/table5_results.xls", ///
        br noaster ctitle("T5 Col4 yr`X'")
}

foreach X of local timeperiods {
    di _n "--- Table 5, Col 5, year `X' ---"
    reg industry fpresence if year==`X' & imputed==0 & westelbe==1, cluster(state)
    outreg2 fpresence using "$outdir/table5_results.xls", ///
        br noaster ctitle("T5 Col5 yr`X'")
}

foreach X of local timeperiods {
    di _n "--- Table 5, Col 6, year `X' ---"
    reg industry fpresence if year==`X' & imputed==0 [aweight=pop1849], cluster(state)
    outreg2 fpresence using "$outdir/table5_results.xls", ///
        br noaster ctitle("T5 Col6 yr`X'")
}

restore

log close t5

* =============================================================================
* TABLE 6: Instrumental Variables
* =============================================================================
di _n "===== TABLE 6: Instrumental Variables ====="

log using "$outdir/table6.log", text replace name(t6)

* Column 1: Baseline weighted
di _n "--- Table 6, Column 1 ---"
* Panel A: OLS
xtreg urbrate yearsref yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe i(id) ///
    robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C1 PanelA") ///
    br noaster nocons addstat(Number of States, e(df_a)+1) replace

* Panel B: First stage
xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=. & westelbe==1 ///
    [aweight=totalpop1750], fe robust cluster(id) small
outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ///
    ctitle("T6 C1 PanelB") addstat(Number of States, e(df_a)+1)

* Panel C: IV
xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900 if westelbe==1 ///
    [aweight=totalpop1750], fe robust cluster(id) first
local pvaluefstat =  Ftail(e(ardf),e(ardf_r),e(widstat))
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C1 PanelC") ///
    br noaster nocons addstat(Number of States, e(df_a)+1, F-stat first stage, e(widstat), ///
    p-value F-stat, `pvaluefstat')

* Column 2: overid
di _n "--- Table 6, Column 2 ---"
xtreg urbrate yearsref yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe i(id) ///
    robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C2 PanelA") ///
    br noaster nocons addstat(Number of States, e(df_a)+1)

xtivreg2 urbrate (yearsref= fpresence1850 fpresence1875 fpresence1900) ///
    yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C2 PanelC") ///
    br noaster nocons addstat(Number of States, e(df_a)+1)

xtivreg2 urbrate (yearsref= fpresence1850 fpresence1875 fpresence1900) ///
    yr1750-yr1900 if westelbe==1 [aweight=totalpop1750], fe robust first
local pvaluefstat =  Ftail(e(ardf),e(ardf_r),e(widstat))
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C2 PanelB") ///
    br noaster nocons addstat(Number of States, e(df_a)+1, F-stat first stage, e(widstat), ///
    p-value F-stat, `pvaluefstat', overid test, e(jp))

* Column 3: Unweighted
di _n "--- Table 6, Column 3 ---"
xtreg urbrate yearsref yr1750-yr1900 if westelbe==1, fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C3 PanelA") ///
    br noaster nocons addstat(Number of States, e(df_a)+1)

xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=. & westelbe==1, ///
    fe robust cluster(id) small
outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ///
    ctitle("T6 C3 PanelB") addstat(Number of States, e(df_a)+1)

xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900 if westelbe==1, ///
    fe robust cluster(id) first
local pvaluefstat =  Ftail(e(ardf),e(ardf_r),e(widstat))
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C3 PanelC") ///
    br noaster nocons addstat(Number of States, e(df_a)+1, F-stat first stage, e(widstat), ///
    p-value F-stat, `pvaluefstat')

* Column 4: All, weighted
di _n "--- Table 6, Column 4 ---"
xtreg urbrate yearsref yr1750-yr1900 [aweight=totalpop1750], fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C4 PanelA") ///
    br noaster nocons addstat(Number of States, e(df_a)+1)

xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=. [aweight=totalpop1750], ///
    fe robust cluster(id) small
outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ///
    ctitle("T6 C4 PanelB") addstat(Number of States, e(df_a)+1)

xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900 [aweight=totalpop1750], ///
    fe robust cluster(id) first
local pvaluefstat =  Ftail(e(ardf),e(ardf_r),e(widstat))
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C4 PanelC") ///
    br noaster nocons addstat(Number of States, e(df_a)+1, F-stat first stage, e(widstat), ///
    p-value F-stat, `pvaluefstat')

* Column 5: All, unweighted
di _n "--- Table 6, Column 5 ---"
xtreg urbrate yearsref yr1750-yr1900, fe i(id) robust cluster(id)
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C5 PanelA") ///
    br noaster nocons addstat(Number of States, e(df_a)+1)

xtivreg2 yearsref fpresenceXpostXtrend yr1750-yr1900 if urbrate~=., fe robust cluster(id) small
outreg2 fpresenceXpostXtrend using "$outdir/table6_results.xls", br noaster nocons ///
    ctitle("T6 C5 PanelB") addstat(Number of States, e(df_a)+1)

xtivreg2 urbrate (yearsref= fpresenceXpostXtrend) yr1750-yr1900, fe robust cluster(id) first
local pvaluefstat =  Ftail(e(ardf),e(ardf_r),e(widstat))
outreg2 yearsref using "$outdir/table6_results.xls", ctitle("T6 C5 PanelC") ///
    br noaster nocons addstat(Number of States, e(df_a)+1, F-stat first stage, e(widstat), ///
    p-value F-stat, `pvaluefstat')

log close t6

di _n "===== ALL TABLES COMPLETE ====="

cap log close _all
