* =============================================================================
* Dahl & Lochner (2012)
* The Impact of Family Income on Child Achievement: Evidence from the EITC
* AER, 102(5), 1927-1956
* PARTIAL REPLICATION: State variable set to 0 (restricted NLSY)
* =============================================================================

clear all
set more off
set maxvar 10000
set matsize 800
cap log close _all

global data "C:/dahl_data"
global prog "$data"
global out  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dahl and Lochner (2012)/full"

cap which taxsim9
if _rc {
    di "NOTE: taxsim9 not installed. Installing..."
    cap noi net install taxsim9, from("http://taxsim.nber.org/stata/taxsim9")
}

cd "$data"

log using "$out/run_dahl_full.log", text replace

* =============================================================================
* Step 1: TAXSIM-EITC (may require internet for TAXSIM)
* =============================================================================
di _n "=========================================================="
di _n "STEP 1: TAXSIM-EITC"
di _n "=========================================================="

cap noi do "$prog/taxsim-eitc.do"
if _rc {
    di "WARNING: taxsim-eitc.do failed with rc=" _rc
    di "Attempting to proceed with existing data..."
}

* Re-set globals (sub-.do calls clear all)
cap log close _all
global data "C:/dahl_data"
global prog "$data"
global out  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dahl and Lochner (2012)/full"
cd "$data"
log using "$out/run_dahl_full.log", text append

* =============================================================================
* Step 2: Merge school-welfare
* =============================================================================
di _n "=========================================================="
di _n "STEP 2: MERGE SCHOOL-WELFARE"
di _n "NOTE: State variable = 0 (restricted NLSY), results will be partial"
di _n "=========================================================="

cap noi do "$prog/merge-school-welfare.do"
if _rc {
    di "WARNING: merge-school-welfare.do failed with rc=" _rc
}

* Re-set globals
cap log close _all
global data "C:/dahl_data"
global prog "$data"
global out  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dahl and Lochner (2012)/full"
cd "$data"
log using "$out/run_dahl_full.log", text append

* =============================================================================
* Step 3: Make variables
* =============================================================================
di _n "=========================================================="
di _n "STEP 3: MAKE VARIABLES"
di _n "=========================================================="

cap noi do "$prog/makevars.do"
if _rc {
    di "WARNING: makevars.do failed with rc=" _rc
}

* Re-set globals
cap log close _all
global data "C:/dahl_data"
global prog "$data"
global out  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dahl and Lochner (2012)/full"
cd "$data"
log using "$out/run_dahl_full.log", text append

* =============================================================================
* Step 4: Regressions
* =============================================================================
di _n "=========================================================="
di _n "STEP 4: REGRESSIONS"
di _n "=========================================================="

cap noi do "$prog/regressions.do"
if _rc {
    di "WARNING: regressions.do failed with rc=" _rc
}

di _n "===== ALL STEPS COMPLETE ====="

cap log close _all
