/*=============================================================================
  CHECK_VARS: Fetzer (2019)
  "Did Austerity Cause Brexit?"
  AER 109(11), 3849-3886

  Purpose: Verify data structure and key variables for TWFE decomposition
  Main TWFE spec: Table 1, Panel A, Column 1
  reghdfe pct_votes_UKIP temp, absorb(id ryr) vce(cl id) nocons
  where temp = post2010 * totalimpact_finlosswap
=============================================================================*/

clear all
set more off
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Fetzer (2019)/data-files"

di _n "============================================================"
di "  DATASET: DISTRICT.dta"
di "============================================================"
use "$datadir/DISTRICT.dta", clear
di "Observations: " _N
desc, short

di _n "--- Key variables ---"
cap ds id year ryr post2010 pct_votes_UKIP UKIPPct totalimpact_finlosswap
if _rc == 0 {
    di "All key variables found"
}
else {
    di "MISSING key variables!"
    ds *id* *year* *ryr* *post* *total* *UKIP* *ukip*
}

di _n "--- Panel structure ---"
qui tab id
di "Districts (id): " r(r)
qui tab year
di "Years: " r(r)
tab year

di _n "--- ryr (region x year FE) ---"
cap tab ryr
if _rc != 0 {
    di "ryr variable not found, checking alternatives..."
    cap ds *ryr* *region* *gor*
}
else {
    qui tab ryr
    di "Region-year groups: " r(r)
}

di _n "--- Treatment: post2010 ---"
cap tab post2010, missing
if _rc != 0 di "post2010 not found"

di _n "--- Treatment: totalimpact_finlosswap ---"
cap sum totalimpact_finlosswap, detail
if _rc != 0 di "totalimpact_finlosswap not found"

di _n "--- Outcome: pct_votes_UKIP ---"
cap sum pct_votes_UKIP, detail
if _rc != 0 di "pct_votes_UKIP not found"

di _n "--- Outcome: UKIPPct ---"
cap sum UKIPPct, detail
if _rc != 0 di "UKIPPct not found"

di _n "--- Create temp = post2010 * totalimpact_finlosswap ---"
cap gen temp = post2010 * totalimpact_finlosswap
if _rc == 0 {
    sum temp, detail
    count if temp != 0 & !missing(temp)
    di "Non-zero treatment obs: " r(N)
}
else {
    di "Cannot create temp variable"
}

di _n "============================================================"
di "  CONCLUSION"
di "============================================================"

* Done
