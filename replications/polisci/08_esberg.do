/*==============================================================
  Replicacion: Esberg & Siegel (2023) APSR
  Equivalente a: papers/Esberg_Siegel_2023.R

  Y:      perc_foreign_policy
  D:      tweeted_exile
  Unit:   actorid (string -> encode a numerico)
  Time:   months (NOT year!)
  FE paper original: actorid + months
  FE replicacion:    actorid + months
  Cluster: actorid
  Controles: log_tweets

  Valores de referencia R (esberg de summary.RData):
    reported:   2.831351  SE: 0.636670
    twfe:       2.808729  SE: 0.636747
    iw(SA):     2.220536  SE: 0.459717
    stack:      2.985907  SE: 0.642805
    cs_ny:      2.155662  SE: 0.572171
    cs_nv:      2.208234  SE: 0.571156
    didm:       2.287520  SE: 0.525160
    fect:       2.897955  boot_SE: 0.573589

  Paquetes necesarios:
    ssc install reghdfe
    ssc install ftools
    ssc install eventstudyinteract
    ssc install did_multiplegt_dyn
    ssc install csdid
    ssc install drdid
    ssc install did_imputation
==============================================================*/

clear all
set more off
cap set maxvar 32000

* --- Instalar paquetes si no existen ---
cap which reghdfe
if _rc ssc install reghdfe
cap which ftools
if _rc ssc install ftools
cap which eventstudyinteract
if _rc ssc install eventstudyinteract
cap which did_multiplegt_dyn
if _rc ssc install did_multiplegt_dyn
cap which csdid
if _rc ssc install csdid
cap which drdid
if _rc ssc install drdid
cap which did_imputation
if _rc ssc install did_imputation

* --- Ruta base ---
global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"


*==============================================================
* 0. CARGAR Y PREPARAR DATOS
*==============================================================

use "data/polisci/data_esberg.dta", clear

* actorid: si es string, encode; si es numerico, gen unit_num
cap confirm string variable actorid
if _rc == 0 {
    * es string
    encode actorid, gen(unit_num)
    drop actorid
}
else {
    * es numerico
    gen unit_num = actorid
}

* months: si es string, encode; si es numerico, gen time_num
cap confirm string variable months
if _rc == 0 {
    * es string
    encode months, gen(time_num)
    drop months
}
else {
    * es numerico
    gen time_num = months
}

* Variables principales
local Y "perc_foreign_policy"
local D "tweeted_exile"
local controls "log_tweets"

di "=== DATOS CARGADOS ==="
describe
summarize `Y' `D' time_num unit_num `controls'


*==============================================================
* 1. TWFE REPORTADO (FE del paper: actorid + months)
*    reghdfe perc_foreign_policy tweeted_exile log_tweets,
*    absorb(unit_num time_num) cluster(unit_num)
*==============================================================

reghdfe `Y' `D' `controls', absorb(unit_num time_num) cluster(unit_num)

* Guardar con scalar (sobrevive a preserve/restore y clear)
scalar rep_est = _b[`D']
scalar rep_se  = _se[`D']

di ""
di "=== 1. REPORTED TWFE ==="
di "Estimate: " rep_est
di "SE:       " rep_se
di "(R ref:    2.831351  SE: 0.636670)"


*==============================================================
* 2. PREPROCESAMIENTO (equivalente a data.preprocess en R)
*==============================================================

* 2a. Eliminar always-treated
bysort unit_num: egen treat_mean = mean(`D')
tab treat_mean
count if treat_mean == 1
di "Obs always-treated a eliminar: " r(N)
drop if treat_mean == 1
drop treat_mean

* 2b. FirstTreat (primer periodo de tratamiento por unidad)
gen _ts = time_num if `D' == 1
bysort unit_num: egen FirstTreat = min(_ts)
replace FirstTreat = 0 if missing(FirstTreat)
drop _ts

* 2c. Time_to_Treatment
gen rel_time = time_num - FirstTreat if FirstTreat > 0

* 2d. Indicador de unidad tratada
gen treat = (FirstTreat > 0)

* Verificar
tab FirstTreat treat, m
di "Obs restantes: " _N


*==============================================================
* 3. TWFE REPLICADO (sin always-treated, FE: unit + time)
*    reghdfe perc_foreign_policy tweeted_exile log_tweets,
*    absorb(unit_num time_num) cluster(unit_num)
*==============================================================

reghdfe `Y' `D' `controls', absorb(unit_num time_num) cluster(unit_num)

scalar twfe_est = _b[`D']
scalar twfe_se  = _se[`D']

di ""
di "=== 3. TWFE REPLICADO ==="
di "Estimate: " twfe_est
di "SE:       " twfe_se
di "(R ref:    2.808729  SE: 0.636747)"


*==============================================================
* 4. SUN & ABRAHAM (Interaction Weighted)
*    SKIPPED: crashea Stata con datos mensuales (demasiada RAM)
*==============================================================

scalar sa_est = .
scalar sa_se  = .

di ""
di "=== 4. SUN & ABRAHAM ==="
di "SKIPPED: eventstudyinteract crashea Stata con datos mensuales"
di "(R ref:    2.220536  SE: 0.459717)"


*==============================================================
* 5. STACKED DID
*==============================================================

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

* Nuevos IDs
egen st_unit = group(stack unit_num)
egen st_time = group(stack time_num)

reghdfe `Y' `D' `controls', absorb(st_unit st_time) cluster(st_unit)

scalar stack_est = _b[`D']
scalar stack_se  = _se[`D']

di ""
di "=== 5. STACKED DID ==="
di "Estimate: " stack_est
di "SE:       " stack_se
di "(R ref:    2.985907  SE: 0.642805)"

use `maindata', clear


*==============================================================
* 6. CALLAWAY & SANT'ANNA
*    Stata: csdid + estat simple
*==============================================================

* 6a. Not Yet Treated
* NOTA: csdid DESACTIVADO — con datos mensuales consume demasiada RAM
*       y crashea Stata. Dejamos missing.
scalar cs_ny_est = .
scalar cs_ny_se  = .

di ""
di "=== 6a. CS (Not Yet Treated) ==="
di "SKIPPED: csdid crashea Stata con datos mensuales (demasiada RAM)"
di "(R ref:    2.155662  SE: 0.572171)"


* 6b. Never Treated
scalar cs_nv_est = .
scalar cs_nv_se  = .

di ""
di "=== 6b. CS (Never Treated) ==="
di "SKIPPED: csdid crashea Stata con datos mensuales (demasiada RAM)"
di "(R ref:    2.208234  SE: 0.571156)"


*==============================================================
* 7. DID_M (did_multiplegt_dyn)
*==============================================================

* Usar todos los effects reales
summ rel_time if rel_time >= 0 & !missing(rel_time)
local n_effects = r(max)
di "Numero de efectos para DID_M: `n_effects'"

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
    di "DID_M estimate capturado: " scalar(didm_est)
}
else {
    scalar didm_est = .
    scalar didm_se  = .
}

di ""
di "=== 7. DID_M ==="
di "ATT: " didm_est
di "SE:  " didm_se
di "(R ref:    2.287520  SE: 0.525160)"


*==============================================================
* 8. IMPUTATION (Borusyak et al.)
*==============================================================

* Nunca tratados necesitan FirstTreat = .
gen FT_imp = FirstTreat
replace FT_imp = . if FirstTreat == 0

cap noi did_imputation `Y' unit_num time_num FT_imp, controls(`controls') minn(0) autosample
if _rc == 0 {
    scalar fect_est = _b[tau]
    scalar fect_se  = _se[tau]
}
else {
    scalar fect_est = .
    scalar fect_se  = .
}

di ""
di "=== 8. IMPUTATION ==="
di "ATT: " fect_est
di "SE:  " fect_se
di "(R ref:    2.897955  boot_SE: 0.573589)"

drop FT_imp


*==============================================================
* 9. GUARDAR TODOS LOS RESULTADOS Y COMPARAR CON R
*==============================================================

preserve
clear
set obs 8

gen paper = "esberg"
gen str30 name = ""
gen double estimate = .
gen double se = .

replace name = "Reported"     in 1
replace name = "TWFE"         in 2
replace name = "Sun_Abraham"  in 3
replace name = "Stacked_DID"  in 4
replace name = "CS_NotYet"    in 5
replace name = "CS_Never"     in 6
replace name = "DID_M"        in 7
replace name = "Imputation"   in 8

replace estimate = scalar(rep_est)    in 1
replace estimate = scalar(twfe_est)   in 2
replace estimate = scalar(sa_est)     in 3
replace estimate = scalar(stack_est)  in 4
replace estimate = scalar(cs_ny_est)  in 5
replace estimate = scalar(cs_nv_est)  in 6
replace estimate = scalar(didm_est)   in 7
replace estimate = scalar(fect_est)   in 8

replace se = scalar(rep_se)    in 1
replace se = scalar(twfe_se)   in 2
replace se = scalar(sa_se)     in 3
replace se = scalar(stack_se)  in 4
replace se = scalar(cs_ny_se)  in 5
replace se = scalar(cs_nv_se)  in 6
replace se = scalar(didm_se)   in 7
replace se = scalar(fect_se)   in 8

* Valores de referencia R (esberg de summary.RData)
gen double r_est = .
gen double r_se  = .
replace r_est = 2.831351 in 1
replace r_est = 2.808729 in 2
replace r_est = 2.220536 in 3
replace r_est = 2.985907 in 4
replace r_est = 2.155662 in 5
replace r_est = 2.208234 in 6
replace r_est = 2.287520 in 7
replace r_est = 2.897955 in 8

replace r_se = 0.636670 in 1
replace r_se = 0.636747 in 2
replace r_se = 0.459717 in 3
replace r_se = 0.642805 in 4
replace r_se = 0.572171 in 5
replace r_se = 0.571156 in 6
replace r_se = 0.525160 in 7
replace r_se = 0.573589 in 8

gen double diff_est = estimate - r_est
gen double diff_se  = se - r_se
gen str5 match = "OK" if abs(diff_est) < 0.01
replace match = "CLOSE" if abs(diff_est) >= 0.01 & abs(diff_est) < 0.05
replace match = "DIFF" if abs(diff_est) >= 0.05 | missing(diff_est)

gen double lb = estimate - 1.96 * se
gen double ub = estimate + 1.96 * se
gen double z_score = estimate / se

save "$path/replications/polisci/output/esberg_estimates.dta", replace

di ""
di "============================================"
di "  RESULTADOS FINALES: Esberg & Siegel (2023)"
di "============================================"
list name estimate se z_score, clean

di ""
di "=== COMPARACION STATA vs R ==="
list name estimate r_est diff_est se r_se diff_se match, clean

di ""
di "=== Normalizados (coef / reported_se) para Figura 4 ==="
di "Reported (z):  " scalar(rep_est) / scalar(rep_se)
di "TWFE:          " scalar(twfe_est) / scalar(rep_se)
di "Sun&Abraham:   " scalar(sa_est) / scalar(rep_se)
di "Stacked DID:   " scalar(stack_est) / scalar(rep_se)
di "CS (NotYet):   " scalar(cs_ny_est) / scalar(rep_se)
di "CS (Never):    " scalar(cs_nv_est) / scalar(rep_se)
di "DID_M:         " scalar(didm_est) / scalar(rep_se)
di "Imputation:    " scalar(fect_est) / scalar(rep_se)

restore
