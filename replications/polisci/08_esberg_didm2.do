/* Test: DID_M para Esberg con TODOS los effects (75) */

clear all
set more off
cap set maxvar 32000

global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"

use "data/polisci/data_esberg.dta", clear

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

bysort unit_num: egen treat_mean = mean(`D')
drop if treat_mean == 1
drop treat_mean

gen _ts = time_num if `D' == 1
bysort unit_num: egen FirstTreat = min(_ts)
replace FirstTreat = 0 if missing(FirstTreat)
drop _ts

gen rel_time = time_num - FirstTreat if FirstTreat > 0
gen treat = (FirstTreat > 0)

* Calcular max effects real
summ rel_time if rel_time >= 0 & !missing(rel_time)
local n_effects = r(max)
di "=== Comenzando DID_M con `n_effects' effects ==="

cap noi did_multiplegt_dyn `Y' unit_num time_num `D', ///
    effects(`n_effects') placebo(0) cluster(unit_num) ///
    controls(`controls') graph_off

if _rc == 0 {
    scalar didm_est = .
    scalar didm_se  = .
    cap scalar didm_est = e(effect_average)
    cap scalar didm_se  = e(se_effect_average)
    if missing(scalar(didm_est)) {
        cap scalar didm_est = _b[Av_tot_eff]
        cap scalar didm_se  = _se[Av_tot_eff]
    }
    di ""
    di "=== DID_M (all effects) ==="
    di "ATT: " scalar(didm_est)
    di "SE:  " scalar(didm_se)
    di "(R ref:    2.287520  SE: 0.525160)"
}
else {
    di "DID_M FALLO con rc = " _rc
}
