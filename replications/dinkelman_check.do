cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/dinkelman_check.log", text replace

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Dinkelman (2011)/20080791_dataset/data/matched_censusdata.dta", clear

desc, short
di "N obs = " _N

* Check key variables
foreach v in T mean_grad_new d_prop_emp_f d_prop_emp_m placecode0 dccode0 largearea {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        sum `v', detail
    }
    else {
        di "`v': MISSING"
    }
}

* Check controls
foreach v in kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0 {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        sum `v'
    }
    else {
        di "`v': MISSING"
    }
}

* Check for level variables (not just differences)
ds *prop_emp*
ds d_*
ds *_96* *_01* *_1996* *_2001*

* Check if there are level outcomes (not just changes)
foreach v in prop_emp_f prop_emp_m prop_emp_f_96 prop_emp_f_01 {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        sum `v'
    }
    else {
        di "`v': MISSING"
    }
}

* Check other level variables
ds *water* *flush*
foreach v in d_prop_waterclose d_prop_flush {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        sum `v'
    }
    else {
        di "`v': MISSING"
    }
}

* How many communities? 
tab T if largearea==1
tab dccode0 if largearea==1

log close
