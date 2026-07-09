* =============================================================================
* Aaronson, Agarwal & French (2012) - The Spending and Debt Response to MW Hikes
* Partial replication: CPS component (Table 2 CPS columns)
* =============================================================================

clear all
set more off
set maxvar 32767
cap log close _all

* Set working directory to where data lives
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

global datadir "${twfe_root}/data/2010-2012/Aaronson et al. (2012)/Supplemental-Files-for-AAF/unix_files"
global progdir "$datadir/AER_FINAL_PROGRAMS"
global outdir  "${twfe_root}/replications/2010-2012/Aaronson et al. (2012)/full"

* Work in the data directory (where .dta files live and intermediate files go)
cd "$datadir"

log using "$outdir/run_aaronson.log", text replace

* =============================================================================
* STEP 1: Create minimum wage dataset (mw.do)
* mw.do is self-contained, no external data needed
* =============================================================================
di _n "===== RUNNING mw.do ====="
cd "$datadir"
do "$progdir/mw.do"

* mw.do saves mw7909.dta and mw9508.dta
* cps.do needs mw7909a.dta (from addotherprogs.do which needs missing data)
* Since cps.do only uses `keep(minwage)` from mw7909a, we can just copy it
copy mw7909.dta mw7909a.dta, replace

di _n "===== mw.do DONE ====="

* =============================================================================
* STEP 2: Run CPS analysis (adapted from cps.do)
* The cps.do creates rep_cps and runs regressions logged to cps_table*.log
* =============================================================================
di _n "===== RUNNING cps.do (adapted) ====="
do "$outdir/cps_adapted.do"

di _n "===== cps.do DONE ====="

* Copy output logs to our output directory
cap copy cps_table1.log "$outdir/cps_table1.log", replace
cap copy cps_tableA1.log "$outdir/cps_tableA1.log", replace
cap copy cps_tableA3.log "$outdir/cps_tableA3.log", replace

log close
