* =============================================================================
* Forman, Goldfarb & Greenstein (2012)
* The Internet and Local Wages: A Puzzle
* AER, 102(1), 556-575
* FULL REPLICATION: Tables 1-5, Appendix Tables A1-A15, Figures 1-2
* =============================================================================

clear all
set more off
set maxvar 10000
cap log close _all

* --- Auto-detect user / set repo paths --------------------------------
* Add a branch with your OS username if you're a new collaborator.
if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root   "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
    global papers_root "/Users/anzony.quisperojas/Documents/GitHub/papers_economic"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root   "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    global papers_root "C:/Users/Usuario/Documents/GitHub/papers_economic"
}
else {
    di as error "Unknown user `c(username)'. Add your repo paths to the user-detection block at the top of this dofile."
    exit 198
}
* ---------------------------------------------------------------------

global datadir "${twfe_root}/data/2010-2012/Forman et al. (2012)/data_and_programs"
global outdir  "${twfe_root}/replications/2010-2012/Forman et al. (2012)/full"

* Install required packages
cap which outreg
if _rc ssc install outreg, replace
cap which outreg2
if _rc ssc install outreg2, replace

cd "$datadir"

log using "$outdir/run_forman_full.log", text replace

global controls lnpop pctblk1990 pctunivp1990 pctHSp1990 pctbelowPL1990 medhhinc1990 carnegie1_enr frac_in_eng_prog npatent1980s frprof pct65p1990 netmig95
global change change_totalpop change_pctblk change_pctunivp change_pctHSp change_pct65 change_netmig

* =============================================================================
* TABLE 1: Summary Statistics
* =============================================================================
di _n "===== TABLE 1: Summary Statistics ====="
log using "$outdir/table1.log", text replace name(t1)

use countygrowth, clear
summ wagediff empdiff estdiff surv_deeppost00 indivhomeinternet00_cty missing iv_othcprogrammerswt iv_first_p iv_cost iv_num_a iv_num_b iv_competitiondeep iv_bartik $controls $change if year==2000

log close t1

* =============================================================================
* TABLE 2: Main Effects - OLS
* =============================================================================
di _n "===== TABLE 2: Main Effects OLS ====="
log using "$outdir/table2.log", text replace name(t2)

use countygrowth, clear

di _n "--- Col 1: No controls ---"
regress wagediff surv_deeppost00, robust

di _n "--- Col 2: With controls ---"
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing $controls $change, robust

di _n "--- Col 3: With PC and shallow ---"
regress wagediff surv_deeppost00 surv_pcperemp00 surv_shalpost00 indivhomeinternet00_cty missing $controls $change, robust

log close t2

* =============================================================================
* TABLE 3: Heterogeneous Effects
* =============================================================================
di _n "===== TABLE 3: Heterogeneous Effects ====="
log using "$outdir/table3.log", text replace name(t3)

use countygrowth, clear

di _n "--- Col 1: High income ---"
regress wagediff surv_deeppost00 highinc2000 inc_dum_surv_deeppost00 $controls $change, robust

di _n "--- Col 2: High education ---"
regress wagediff surv_deeppost00 higheduc2000 educ_dum_surv_deeppost00 $controls $change, robust

di _n "--- Col 3: High industry ---"
regress wagediff surv_deeppost00 highind2000 ind_dum_surv_deeppost00 $controls $change, robust

di _n "--- Col 4: High population ---"
regress wagediff surv_deeppost00 highpop2000 pop_dum_surv_deeppost00 $controls $change, robust

di _n "--- Col 5: All interactions ---"
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 inc_dum_surv_deeppost00 educ_dum_surv_deeppost00 pop_dum_surv_deeppost00 ind_dum_surv_deeppost00 $controls $change, robust

di _n "--- Col 6: All high combined ---"
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00 $controls $change, robust

di _n "--- Col 7: All interactions + combined ---"
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 inc_dum_surv_deeppost00 educ_dum_surv_deeppost00 pop_dum_surv_deeppost00 ind_dum_surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00 $controls $change, robust

log close t3

* =============================================================================
* TABLE 4: IV Regressions
* =============================================================================
di _n "===== TABLE 4: IV Regressions ====="
log using "$outdir/table4.log", text replace name(t4)

use countygrowth, clear

di _n "--- OLS baseline for Hausman ---"
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing avgdmest $controls $change
estimates store ols

di _n "--- Col 1: Other programmers IV ---"
ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt) indivhomeinternet00_cty missing avgdmest $controls $change, first vce(robust)

di _n "--- Col 2: Bartik IV ---"
ivregress liml wagediff (surv_deeppost00= iv_bartik) indivhomeinternet00_cty missing avgdmest $controls $change, first vce(robust)

di _n "--- Col 3: ARPANET IV ---"
ivregress gmm wagediff (surv_deeppost00=iv_num_a) indivhomeinternet00_cty missing avgdmest $controls $change, first vce(robust)

di _n "--- Col 4: All IVs ---"
ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt iv_num_a iv_bartik) indivhomeinternet00_cty missing avgdmest $controls $change, first vce(robust)

* Overid test
cap noi estat overid

* Heterogeneous IV
di _n "--- Heterogeneous IV ---"
gen ivd_num_a = iv_num_a*allhigh
gen ivd_othcp = iv_othcp*allhigh
gen ivd_bartik = iv_bartik*allhigh

regress wagediff surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change
estimates store ols2

di _n "--- Col 5: Other programmers interacted ---"
cap noi ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_othcprogrammerswt ivd_othcp) highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change, first vce(robust)

di _n "--- Col 6: Bartik interacted ---"
cap noi ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_bartik ivd_bartik) highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change, first vce(robust)

di _n "--- Col 7: ARPANET interacted ---"
cap noi ivregress gmm wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_num_a ivd_num_a) highinc2000 higheduc2000 highind2000 highpop2000 allhigh $controls $change, first vce(robust)

di _n "--- Col 8: All IVs interacted ---"
cap noi ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_othcprogrammerswt iv_num_a iv_bartik ivd_othcp ivd_num_a ivd_bartik) highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change, first vce(robust)

log close t4

* =============================================================================
* TABLE 5: Additional Outcomes (employment, establishments, 1999-2005)
* =============================================================================
di _n "===== TABLE 5: Additional Outcomes ====="
log using "$outdir/table5.log", text replace name(t5)

use countygrowth, clear

di _n "--- Col 1: Employment growth ---"
regress empdiff surv_deeppost00 indivhomeinternet00_cty missing $controls $change, robust

di _n "--- Col 2: Employment + allhigh ---"
regress empdiff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00 $controls $change, robust

* 1999-2005 wage growth
use countyyear.dta, clear
replace medhhinc1990=medhhinc1990/1000
replace npatent1980s=npatent1980s/1000
replace netmig95=netmig95/1000
keep if year==2005|year==1999

sort county year
gen wagediff=lnweekwage-lnweekwage[_n-1]
gen empdiff=lnemp-lnemp[_n-1]
gen estdiff=lnest-lnest[_n-1]
replace change_netmig=netmig-netmig[_n-1]
replace change_netmig=change_netmig/1000
keep if year==2005
gen educ_inc_ind_pop_dum_surv_deep05=allhigh*surv_deeppost00

di _n "--- Col 3: Wage growth 1999-2005 ---"
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing $controls $change, robust

di _n "--- Col 4: Wage growth 1999-2005 + allhigh ---"
regress wagediff surv_deeppost00 highinc higheduc highind highpop allhigh educ_inc_ind_pop_dum_surv_deep05 $controls $change, robust

log close t5

di _n "===== ALL TABLES COMPLETE ====="

cap log close _all
