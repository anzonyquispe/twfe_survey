cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dinkelman (2011)/check_vars.log", text replace

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Dinkelman (2011)/20080791_dataset/data/matched_censusdata.dta", clear

desc, short
di "N obs = " _N

foreach v in T mean_grad_new d_prop_emp_f d_prop_emp_m placecode0 dccode0 largearea {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        qui sum `v'
        di "  N=" r(N) " mean=" r(mean) " min=" r(min) " max=" r(max)
    }
    else {
        di "`v': MISSING"
    }
}

foreach v in kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0 d_prop_waterclose d_prop_flush {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        qui sum `v'
        di "  N=" r(N) " mean=" r(mean)
    }
    else {
        di "`v': MISSING"
    }
}

di "=== All d_ variables ==="
cap ds d_*
di "=== All prop_emp variables ==="
cap ds *prop_emp*

foreach v in prop_emp_f_96 prop_emp_m_96 prop_emp_f_01 prop_emp_m_01 prop_emp_f0 prop_emp_m0 prop_emp_f1 prop_emp_m1 {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        qui sum `v'
        di "  N=" r(N) " mean=" r(mean)
    }
    else {
        di "`v': MISSING"
    }
}

tab T if largearea==1
tab dccode0 if largearea==1

log close
