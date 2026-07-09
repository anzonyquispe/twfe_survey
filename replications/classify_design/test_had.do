* test_had.do
* Generate a HAD dataset (common adoption period, heterogeneous dose) and
* verify classify_design returns "HAD".
clear all
set more off
cap log close _all

local here : pwd
adopath + "`here'"
log using "test_had.log", text replace

* --- 100 groups, 10 periods. D=0 for t<6. At t*=6, 30 groups stay at 0
*     and 70 groups receive a Uniform(1,10) dose. From t=6 onward the
*     dose can vary (relaxed HAD per the agreed spec). ---------------------
set seed 44444
set obs 100
gen g = _n
gen dose_init = 0
replace dose_init = runiform(1, 10) if g > 30

expand 10
bysort g: gen t = _n

gen D = 0
* At t* = 6, set D to dose_init
replace D = dose_init if t == 6
* After t*, allow some drift (kept small so the heterogeneity at t* is the
* identifying feature). Treated groups: random walk; untreated stay at 0.
sort g t
by g: gen D_post = D[6] if t >= 6
replace D = D_post + rnormal(0, 0.3) if t > 6 & D_post > 0
replace D = 0 if D < 0
drop D_post dose_init

gen Y = g/100 + t/10 + 0.4*D + rnormal()

save "test_had.dta", replace

classify_design g t D

di _n "[test_had] r(design) = `r(design)'"
assert "`r(design)'" == "HAD"
di "[test_had] PASS"

log close
