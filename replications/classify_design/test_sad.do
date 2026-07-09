* test_sad.do
* Generate a SAD dataset (binary, staggered) and verify classify_design returns "SAD".
clear all
set more off
cap log close _all

local here : pwd
adopath + "`here'"
log using "test_sad.log", text replace

* --- Build the panel: 100 groups, 10 periods, switch dates in {4, 6, 8}
*     plus a never-treated cohort ------------------------------------------
set seed 22222
set obs 100
gen g = _n
gen Fg = .
replace Fg = 4  if g <= 25
replace Fg = 6  if g >  25 & g <= 50
replace Fg = 8  if g >  50 & g <= 75
replace Fg = 11 if g >  75            // never treated

expand 10
bysort g: gen t = _n
gen D = (t >= Fg)                     // binary, absorbing, multiple switch dates

* Outcome: group + time FE + treatment effect + noise
gen Y = g/100 + t/10 + 0.4*D + rnormal()

save "test_sad.dta", replace

* --- Classify ------------------------------------------------------------
classify_design g t D

di _n "[test_sad] r(design) = `r(design)'"
assert "`r(design)'" == "SAD"
di "[test_sad] PASS"

log close
