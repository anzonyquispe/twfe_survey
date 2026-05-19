/* Test: Solo Sun & Abraham para Esberg (datos mensuales, capado ±12) */

clear all
set more off
cap set maxvar 32000

global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"

use "data/polisci/data_esberg.dta", clear

* Preparar unit_num y time_num
cap confirm string variable actorid
if _rc == 0 {
    encode actorid, gen(unit_num)
    drop actorid
}
else {
    gen unit_num = actorid
}

cap confirm string variable months
if _rc == 0 {
    encode months, gen(time_num)
    drop months
}
else {
    gen time_num = months
}

local Y "perc_foreign_policy"
local D "tweeted_exile"
local controls "log_tweets"

* Preprocesamiento
bysort unit_num: egen treat_mean = mean(`D')
drop if treat_mean == 1
drop treat_mean

gen _ts = time_num if `D' == 1
bysort unit_num: egen FirstTreat = min(_ts)
replace FirstTreat = 0 if missing(FirstTreat)
drop _ts

gen rel_time = time_num - FirstTreat if FirstTreat > 0
gen treat = (FirstTreat > 0)

di "=== Obs: " _N " ==="
di "=== Comenzando Sun & Abraham (±12) ==="

* SUN & ABRAHAM
gen never_treat = (FirstTreat == 0)

summ rel_time if treat == 1
local tmin = max(r(min), -12)
local tmax = min(r(max), 12)
di "Rango rel_time capado: `tmin' a `tmax'"

local relvars ""
forvalues k = `tmin'/`tmax' {
    if `k' != -1 {
        gen _rt`=`k'+100' = (rel_time == `k')
        replace _rt`=`k'+100' = 0 if missing(_rt`=`k'+100')
        local relvars "`relvars' _rt`=`k'+100'"
    }
}

local postvars ""
forvalues k = 0/`tmax' {
    local postvars "`postvars' _rt`=`k'+100'"
}

eventstudyinteract `Y' `relvars' `controls', ///
    cohort(FirstTreat) control_cohort(never_treat) ///
    absorb(unit_num time_num) vce(cluster unit_num)

* ATT agregado ponderado
local n_post = `tmax' + 1
matrix _sa_wts = J(`n_post', 2, 0)
local _row = 1
forvalues k = 0/`tmax' {
    qui count if rel_time == `k'
    matrix _sa_wts[`_row', 1] = `k' + 100
    matrix _sa_wts[`_row', 2] = r(N)
    local _row = `_row' + 1
}

mata:
    b = st_matrix("e(b_iw)")
    V = st_matrix("e(V_iw)")
    names = st_matrixcolstripe("e(b_iw)")
    wts = st_matrix("_sa_wts")

    w = J(1, cols(b), 0)
    total_n = 0
    for (j = 1; j <= rows(wts); j++) total_n = total_n + wts[j,2]

    for (i = 1; i <= cols(b); i++) {
        nm = strtrim(names[i, 2])
        if (substr(nm, 1, 3) == "_rt") {
            num = strtoreal(substr(nm, 4, .))
            if (num >= 100 & num < .) {
                for (j = 1; j <= rows(wts); j++) {
                    if (wts[j,1] == num) {
                        w[i] = wts[j,2] / total_n
                        break
                    }
                }
            }
        }
    }

    att = w * b'
    se_att = sqrt(w * V * w')

    st_numscalar("sa_est", att)
    st_numscalar("sa_se", se_att)
end
matrix drop _sa_wts

di ""
di "=== SUN & ABRAHAM (±12) ==="
di "ATT: " sa_est
di "SE:  " sa_se
di "(R ref:    2.220536  SE: 0.459717)"
