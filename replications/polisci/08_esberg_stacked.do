/* Test: Solo Stacked DID para Esberg (datos mensuales) */

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
di "=== Comenzando Stacked DID ==="

* STACKED DID
tempfile maindata
save `maindata'

levelsof FirstTreat if FirstTreat > 0, local(cohorts)

tempfile stacked
local first_stack = 1

foreach g of local cohorts {
    use `maindata', clear
    keep if FirstTreat == `g' | FirstTreat == 0
    gen stack = `g'

    if `first_stack' == 1 {
        save `stacked', replace
        local first_stack = 0
    }
    else {
        append using `stacked'
        save `stacked', replace
    }
}

use `stacked', clear
di "=== Obs stacked: " _N " ==="

egen st_unit = group(stack unit_num)
egen st_time = group(stack time_num)

reghdfe `Y' `D' `controls', absorb(st_unit st_time) cluster(st_unit)

di ""
di "=== STACKED DID ==="
di "Estimate: " _b[`D']
di "SE:       " _se[`D']
di "(R ref:    2.985907  SE: 0.642805)"
