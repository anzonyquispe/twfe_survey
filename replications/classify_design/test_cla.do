* test_cla.do
* Generate a CLA dataset and verify classify_design returns "CLA".
clear all
set more off
cap log close _all

local here : pwd
adopath + "`here'"
log using "test_cla.log", text replace

* --- Build the panel: 100 groups, 10 periods, 50 treated at t=6 -----------
set seed 11111
set obs 100
gen g = _n
gen treated_g = (g <= 50)
expand 10
bysort g: gen t = _n
gen D = (treated_g == 1 & t >= 6)

* Outcome: group + time FE + treatment effect + noise
gen Y = g/100 + t/10 + 0.5*D + rnormal()

save "test_cla.dta", replace

* --- Classify ------------------------------------------------------------
classify_design g t D

* --- Assert --------------------------------------------------------------
di _n "[test_cla] r(design) = `r(design)'"
assert "`r(design)'" == "CLA"
di "[test_cla] PASS"

log close
