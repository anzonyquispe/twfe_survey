/*=============================================================================
  CHECK_VARS: Donaldson (2018)
  "Railroads of the Raj: Estimating the Impact of Transportation Infrastructure"
  AER 108(4-5), 899-934

  Purpose: Verify data structure and key variables for TWFE decomposition
  Main TWFE spec: Table 4, Column 1
  reghdfe ln_realincome RAIL, absorb(distid year) vce(cluster distid)
=============================================================================*/

clear all
set more off
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Donaldson (2018)/web_materials"

di _n "============================================================"
di "  DATASET 1: income.dta"
di "============================================================"
cap use "$datadir/Data/income/income.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
    di _n "--- Panel structure ---"
    cap qui tab distid
    di "Districts: " r(r)
    cap qui tab year
    di "Years: " r(r)
    cap tab year
    cap sum realincome, detail
}
else {
    di "FAILED to load income.dta"
}

di _n "============================================================"
di "  DATASET 2: RAIL dummies.dta"
di "============================================================"
cap use "$datadir/Data/maps/RAIL dummies.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
    cap tab RAIL, missing
}
else {
    di "FAILED to load RAIL dummies.dta"
}

di _n "============================================================"
di "  MERGED DATASET"
di "============================================================"
use "$datadir/Data/income/income.dta", clear
sort distid year
merge 1:1 distid year using "$datadir/Data/maps/RAIL dummies.dta"
tab _merge
keep if _merge == 3
drop _merge

gen ln_realincome = log(realincome)

di _n "--- Panel structure (merged) ---"
qui tab distid
di "Districts: " r(r)
qui tab year
di "Years: " r(r)
tab year

di _n "--- Treatment: RAIL ---"
tab RAIL, missing

di _n "--- Outcome: ln_realincome ---"
sum ln_realincome, detail

di _n "--- Treatment variation ---"
bys distid: egen ever_rail = max(RAIL)
bys distid: egen never_rail = min(RAIL)
gen switcher = (ever_rail == 1 & never_rail == 0)
qui tab distid if ever_rail == 0
di "Never-treated districts: " r(r)
qui tab distid if ever_rail == 1 & never_rail == 1
di "Always-treated districts: " r(r)
qui tab distid if switcher == 1
di "Switcher districts: " r(r)

di _n "============================================================"
di "  CONCLUSION"
di "  Data available. TWFE spec identified: Table 4, Col 1"
di "  reghdfe ln_realincome RAIL, absorb(distid year) vce(cl distid)"
di "  Binary treatment (RAIL), suitable for twowayfeweights"
di "============================================================"
