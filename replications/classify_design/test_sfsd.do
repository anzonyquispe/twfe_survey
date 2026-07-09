* test_sfsd.do
* Generate a SFSD dataset (non-binary, varying first-switch timing) and
* verify classify_design returns "SFSD" with subtype "SSFSD".
clear all
set more off
cap log close _all

local here : pwd
adopath + "`here'"
log using "test_sfsd.log", text replace

* --- 100 groups, 10 periods; D in {0,1,2,3} -----------------------------
*     Baseline _D_g1 cycles in {0,1,2,3} so we have variation in baseline.
*     Within each baseline value, half the groups switch at t=4 and half at t=8
*     (so Var(F_g | _D_g1) > 0 → SSFSD). Up-switchers cap at 3, down-switcher
*     (baseline 3) decreases by 1.
set seed 33333
set obs 100
gen g = _n
gen D_baseline = mod(g - 1, 3) + 1        // baselines 1, 2, 3 (no zero)
gen Fg = cond(g <= 50, 4, 8)               // first 50 switch at 4, next 50 at 8
                                            // (independent of baseline → SSFSD)

expand 10
bysort g: gen t = _n
gen D = D_baseline
replace D = D_baseline + 1 if t >= Fg & D_baseline < 3
replace D = D_baseline - 1 if t >= Fg & D_baseline == 3

gen Y = g/100 + t/10 + 0.3*D + rnormal()

save "test_sfsd.dta", replace

classify_design g t D

di _n "[test_sfsd] r(design) = `r(design)'  r(subtype) = `r(subtype)'"
assert "`r(design)'"  == "SFSD"
assert "`r(subtype)'" == "SSFSD"
di "[test_sfsd] PASS"

log close
