/*==============================================================================
  CHECK_VARS: Munshi and Rosenzweig (2016)
  "Networks and Misallocation: Insurance, Migration, and the Rural-Urban Wage Gap"
  AER 106(1), 46-98

  Purpose: Check if data has panel structure suitable for twowayfeweights
==============================================================================*/

clear all
set more off

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Munshi and Rosenzweig (2016)/data"

* --- Table 6 data ---
di _n "============================================================"
di "  TABLE 6 DATA: table6.dta"
di "============================================================"
use "$datadir/table6.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Looking for panel dimensions (group and time variables) ---"
* Check if there are any year/time variables
ds *year* *time* *period* *wave* *round* *t *yr*
di _n "--- Variable list ---"
ds

di _n "--- Key variables summary ---"
cap summarize mig pminc jpminc cvsq village castecode total icrisat, detail

di _n "--- Village distribution ---"
cap tab village, missing

di _n "--- Unique groups ---"
cap qui tab village
cap di "Villages (potential G): " r(r)
cap qui tab castecode
cap di "Castes: " r(r)

* --- Table 8a data ---
di _n "============================================================"
di "  TABLE 8A DATA: table8a.dta"
di "============================================================"
use "$datadir/table8a.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Looking for panel dimensions ---"
ds *year* *time* *period* *wave* *round* *t *yr*
di _n "--- Variable list ---"
ds

di _n "--- Key variables summary ---"
cap summarize dpout10 pdinc10 state, detail

* --- Structural estimation data ---
di _n "============================================================"
di "  STRUCTURAL DATA: migstructure_final_dups_cleaned_with_cons_land.dta"
di "============================================================"
use "$datadir/replication-files/migstructure_final_dups_cleaned_with_cons_land.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Looking for panel dimensions ---"
ds *year* *time* *period* *wave* *round* *t *yr*
di _n "--- Variable list ---"
ds

di _n "============================================================"
di "  CONCLUSION: Check if any dataset has G x T panel structure"
di "============================================================"
