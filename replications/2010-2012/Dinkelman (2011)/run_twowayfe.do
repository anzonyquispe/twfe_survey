cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dinkelman (2011)/run_twowayfe.log", text replace
set more off

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Dinkelman (2011)/20080791_dataset/data/matched_censusdata.dta", clear
keep if largearea == 1
di "Sample N = " _N

global x1 "kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0"

di "============================================="
di "TABLE 4 REPLICATION"
di "============================================="

di _n "--- Col 1: OLS, no controls ---"
reg d_prop_emp_f T, robust cluster(placecode0)
local b_ols1 = _b[T]
local se_ols1 = _se[T]
local n_ols1 = e(N)

di _n "--- Col 3: OLS, controls + district FE ---"
xi: reg d_prop_emp_f T $x1 i.dccode0, robust cluster(placecode0)
local b_ols3 = _b[T]
local se_ols3 = _se[T]
local n_ols3 = e(N)

di _n "--- Col 5: IV, no controls ---"
ivregress 2sls d_prop_emp_f (T = mean_grad_new), robust cluster(placecode0) first
local b_iv5 = _b[T]
local se_iv5 = _se[T]
local n_iv5 = e(N)

di _n "--- Col 7: IV, controls + district FE ---"
xi: ivregress 2sls d_prop_emp_f (T = mean_grad_new) $x1 i.dccode0, robust cluster(placecode0) first
local b_iv7 = _b[T]
local se_iv7 = _se[T]
local n_iv7 = e(N)

di _n "--- Male: OLS+FE ---"
xi: reg d_prop_emp_m T $x1 i.dccode0, robust cluster(placecode0)
local b_ols3m = _b[T]
local se_ols3m = _se[T]

di _n "--- Male: IV+FE ---"
xi: ivregress 2sls d_prop_emp_m (T = mean_grad_new) $x1 i.dccode0, robust cluster(placecode0)
local b_iv7m = _b[T]
local se_iv7m = _se[T]

* --- Reshape to 2-period panel ---
di _n "============================================="
di "RESHAPING TO 2-PERIOD PANEL"
di "============================================="

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Dinkelman (2011)/20080791_dataset/data/matched_censusdata.dta", clear
keep if largearea == 1
keep placecode0 dccode0 T mean_grad_new prop_emp_f0 prop_emp_f1 prop_emp_m0 prop_emp_m1 $x1

gen comm_id = _n
local N_comm = _N

expand 2
sort comm_id
by comm_id: gen year = cond(_n == 1, 1996, 2001)

gen prop_emp_f = cond(year == 1996, prop_emp_f0, prop_emp_f1)
gen prop_emp_m = cond(year == 1996, prop_emp_m0, prop_emp_m1)
gen D = cond(year == 2001, T, 0)

xtset comm_id year, delta(5)
di "Panel: " _N " obs = " `N_comm` " communities x 2 periods"

* --- Levels TWFE regression ---
reg prop_emp_f D i.comm_id i.year, cluster(placecode0)
di "TWFE beta = " _b[D]
di "TWFE se   = " _se[D]

* --- twowayfeweights ---
di _n "============================================="
di "TWOWAYFEWEIGHTS - Female Employment"
di "============================================="

cap noisily twowayfeweights prop_emp_f comm_id year D, type(feTR)
local tw_rc1 = _rc
if `tw_rc1` == 0 | `tw_rc1` == 402 {
    local tw_beta1  = e(beta)
    mat _M1 = e(M)
    local tw_npos1  = _M1[1,1]
    local tw_nneg1  = _M1[2,1]
    local tw_ntot1  = `tw_npos1` + `tw_nneg1`
    local tw_pneg1 : di %5.1f (100 * `tw_nneg1` / `tw_ntot1`)
    di _n "Beta TWFE     = " `tw_beta1`
    di "# pos weights = " `tw_npos1`
    di "# neg weights = " `tw_nneg1`
    di "% neg weights = " `tw_pneg1` "%"
}
else {
    di "twowayfeweights FAILED with rc = " `tw_rc1`
    local tw_beta1  = .
    local tw_npos1  = .
    local tw_nneg1  = .
    local tw_pneg1  = "N/A"
}

di _n "============================================="
di "TWOWAYFEWEIGHTS - Male Employment"
di "============================================="

cap noisily twowayfeweights prop_emp_m comm_id year D, type(feTR)
local tw_rc2 = _rc
if `tw_rc2` == 0 | `tw_rc2` == 402 {
    local tw_beta2  = e(beta)
    mat _M2 = e(M)
    local tw_npos2  = _M2[1,1]
    local tw_nneg2  = _M2[2,1]
    local tw_ntot2  = `tw_npos2` + `tw_nneg2`
    local tw_pneg2 : di %5.1f (100 * `tw_nneg2` / `tw_ntot2`)
    di _n "Beta TWFE     = " `tw_beta2`
    di "# pos weights = " `tw_npos2`
    di "# neg weights = " `tw_nneg2`
    di "% neg weights = " `tw_pneg2` "%"
}
else {
    di "twowayfeweights FAILED with rc = " `tw_rc2`
    local tw_beta2  = .
    local tw_npos2  = .
    local tw_nneg2  = .
    local tw_pneg2  = "N/A"
}

* --- Summary ---
di _n "============================================="
di "SUMMARY"
di "============================================="
di "Table 4 replication:"
di "  Female OLS (no ctrl): beta = " %7.4f `b_ols1` " (" %7.4f `se_ols1` ")"
di "  Female OLS+FE:        beta = " %7.4f `b_ols3` " (" %7.4f `se_ols3` ")"
di "  Female IV (no ctrl):  beta = " %7.4f `b_iv5` " (" %7.4f `se_iv5` ")"
di "  Female IV+FE:         beta = " %7.4f `b_iv7` " (" %7.4f `se_iv7` ")"
di ""
di "twowayfeweights (female): rc = " `tw_rc1`
if `tw_rc1` == 0 | `tw_rc1` == 402 {
    di "  beta = " `tw_beta1` ", # pos = " `tw_npos1` ", # neg = " `tw_nneg1` ", % neg = " `tw_pneg1` "%"
}
di "twowayfeweights (male): rc = " `tw_rc2`
if `tw_rc2` == 0 | `tw_rc2` == 402 {
    di "  beta = " `tw_beta2` ", # pos = " `tw_npos2` ", # neg = " `tw_nneg2` ", % neg = " `tw_pneg2` "%"
}

log close