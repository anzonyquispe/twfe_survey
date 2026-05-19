/*==============================================================
  Replicacion: Bischof & Wagner (2019) AJPS
  Equivalente a: papers/Bischof_Wagner_2019.R

  Y:      polarization
  D:      rtreatment
  Unit:   country (string -> encode a numerico)
  Time:   year
  FE paper original: country + decade (decade ya existe en datos)
  FE replicacion:    country + year
  Cluster: country
  Controles: ninguno

  Paquetes necesarios:
    ssc install reghdfe
    ssc install ftools
    ssc install eventstudyinteract
    ssc install did_multiplegt_dyn
    ssc install csdid
    ssc install drdid
    ssc install did_imputation

  VALORES DE REFERENCIA R (summary.RData):
    Reported:    0.116163  SE: 0.055776
    TWFE:        0.117473  SE: 0.058488
    SA (IW):     0.078979  SE: 0.039790
    Stack:       0.121955  SE: 0.061113
    CS_NotYet:  -0.011039  SE: 0.085444
    CS_Never:    0.000974  SE: 0.091983
    DID_M:       0.081290  SE: 0.027130
    FEct:        0.082334  SE(boot): 0.071344

  DIFERENCIAS ESPERADAS R vs Stata:
    Reported, TWFE, Stack: coincidencia exacta
    SA: leve (sunab en R vs eventstudyinteract en Stata)
    CS: grande - R usa year recodificado a factor (1-44),
        Stata usa year original (1973-2016). Ademas, versiones
        distintas de did (R) vs csdid (Stata).
    DID_M est: coincide. SE difiere (implementaciones distintas).
    Imputation est: coincide. SE difiere (R: bootstrap fect,
        Stata: analitico did_imputation).
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

use "data/polisci/data_bischof.dta", clear

* country es string, convertir a numerico
encode country, gen(unit_num)
drop country

* decade ya existe en los datos (valores 0, 1, 2...)
* year ya es numerico

* Variables principales
local Y "polarization"
local D "rtreatment"

di "=== DATOS CARGADOS ==="
describe
summarize `Y' `D' year decade unit_num


*==============================================================
* 1. TWFE REPORTADO (FE del paper: country + decade)
*    R: feols(polarization ~ rtreatment | country + decade, cluster = "country")
*==============================================================

reghdfe `Y' `D', absorb(unit_num decade) cluster(unit_num)

* Guardar con scalar (sobrevive a preserve/restore y clear)
scalar rep_est = _b[`D']
scalar rep_se  = _se[`D']

di ""
di "=== 1. REPORTED TWFE ==="
di "Estimate: " rep_est  "  (R: 0.116163)"
di "SE:       " rep_se   "  (R: 0.055776)"


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
gen _ts = year if `D' == 1
bysort unit_num: egen FirstTreat = min(_ts)
replace FirstTreat = 0 if missing(FirstTreat)
drop _ts

* 2c. Time_to_Treatment
gen rel_time = year - FirstTreat if FirstTreat > 0

* 2d. Indicador de unidad tratada
gen treat = (FirstTreat > 0)

* Verificar
tab FirstTreat treat, m
di "Obs restantes: " _N


*==============================================================
* 3. TWFE REPLICADO (sin always-treated, FE: unit + year)
*    R: twfe.point.coef()
*==============================================================

reghdfe `Y' `D', absorb(unit_num year) cluster(unit_num)

scalar twfe_est = _b[`D']
scalar twfe_se  = _se[`D']

di ""
di "=== 3. TWFE REPLICADO ==="
di "Estimate: " twfe_est  "  (R: 0.117473)"
di "SE:       " twfe_se   "  (R: 0.058488)"


*==============================================================
* 4. SUN & ABRAHAM (Interaction Weighted)
*    R: sa.point.coef() -> feols(Y ~ sunab(FirstTreat, year, att=TRUE))
*    Stata: eventstudyinteract
*==============================================================

* Indicador de nunca tratado (control cohort)
gen never_treat = (FirstTreat == 0)

* Dummies de relative time (omitiendo -1)
* Usar rango COMPLETO (sin capar) para coincidir con sunab() de R
summ rel_time if treat == 1
local tmin = r(min)
local tmax = r(max)

* Generar dummies
local relvars ""
forvalues k = `tmin'/`tmax' {
    if `k' != -1 {
        gen _rt`=`k'+100' = (rel_time == `k')
        replace _rt`=`k'+100' = 0 if missing(_rt`=`k'+100')
        local relvars "`relvars' _rt`=`k'+100'"
    }
}

* Lista de solo los post (k >= 0) para lincom despues
local postvars ""
forvalues k = 0/`tmax' {
    local postvars "`postvars' _rt`=`k'+100'"
}

* Correr Sun & Abraham
eventstudyinteract `Y' `relvars', ///
    cohort(FirstTreat) control_cohort(never_treat) ///
    absorb(unit_num year) vce(cluster unit_num)

* ATT agregado: promedio PONDERADO por # obs tratadas en cada periodo
* Usar e(b_iw) y e(V_iw) de eventstudyinteract
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
di "=== 4. SUN & ABRAHAM ==="
di "ATT: " sa_est  "  (R: 0.078979)"
di "SE:  " sa_se   "  (R: 0.039790)"
di "(Diff esperada: sunab vs eventstudyinteract)"

* Limpiar dummies
drop _rt* never_treat


*==============================================================
* 5. STACKED DID
*    R: stack.point.coef()
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
egen st_time = group(stack year)

reghdfe `Y' `D', absorb(st_unit st_time) cluster(st_unit)

scalar stack_est = _b[`D']
scalar stack_se  = _se[`D']

di ""
di "=== 5. STACKED DID ==="
di "Estimate: " stack_est  "  (R: 0.121955)"
di "SE:       " stack_se   "  (R: 0.061113)"

use `maindata', clear


*==============================================================
* 6. CALLAWAY & SANT'ANNA
*    R: cs.point.coef() -> att_gt() + aggte(type="simple")
*    Stata: csdid + estat simple
*==============================================================

* 6a. Not Yet Treated
scalar cs_ny_est = .
scalar cs_ny_se  = .
cap noi csdid `Y', ivar(unit_num) time(year) gvar(FirstTreat) notyet method(reg)
if _rc == 0 {
    estat simple
    * estat simple guarda en r(b) y r(V), NO en e(b)/e(V)
    matrix b_cs = r(b)
    matrix V_cs = r(V)
    scalar cs_ny_est = b_cs[1,1]
    scalar cs_ny_se  = sqrt(V_cs[1,1])
}

di ""
di "=== 6a. CS (Not Yet Treated) ==="
di "ATT: " cs_ny_est  "  (R: -0.011039)"
di "SE:  " cs_ny_se   "  (R:  0.085444)"
di "(Diff esperada: R usa year recodificado 1-44; version distinta did pkg)"


* 6b. Never Treated
scalar cs_nv_est = .
scalar cs_nv_se  = .
cap noi csdid `Y', ivar(unit_num) time(year) gvar(FirstTreat) method(reg)
if _rc == 0 {
    estat simple
    matrix b_cs2 = r(b)
    matrix V_cs2 = r(V)
    scalar cs_nv_est = b_cs2[1,1]
    scalar cs_nv_se  = sqrt(V_cs2[1,1])
}

di ""
di "=== 6b. CS (Never Treated) ==="
di "ATT: " cs_nv_est  "  (R: 0.000974)"
di "SE:  " cs_nv_se   "  (R: 0.091983)"
di "(Diff esperada: R usa year recodificado 1-44; version distinta did pkg)"


*==============================================================
* 7. DID_M (did_multiplegt_dyn)
*    R: get.didm.results()
*==============================================================

cap noi did_multiplegt_dyn `Y' unit_num year `D', ///
    effects(5000) placebo(0) cluster(unit_num) graph_off

if _rc == 0 {
    scalar didm_est = .
    scalar didm_se  = .
    * Intentar diferentes nombres de escalares
    cap scalar didm_est = e(effect_average)
    cap scalar didm_se  = e(se_effect_average)
    * Si no funciono, intentar desde e(b)
    if missing(scalar(didm_est)) {
        cap scalar didm_est = _b[Av_tot_eff]
        cap scalar didm_se  = _se[Av_tot_eff]
    }
    * Diagnostico
    di "DID_M estimate capturado: " scalar(didm_est)
    ereturn list
}
else {
    scalar didm_est = .
    scalar didm_se  = .
}

di ""
di "=== 7. DID_M ==="
di "ATT: " didm_est  "  (R: 0.081290)"
di "SE:  " didm_se   "  (R: 0.027130)"
di "(Est coincide. SE difiere: implementaciones distintas R vs Stata)"


*==============================================================
* 8. IMPUTATION (Borusyak et al.)
*    R: fect.coef() -> fect(method="fe")
*==============================================================

* Nunca tratados necesitan FirstTreat = .
gen FT_imp = FirstTreat
replace FT_imp = . if FirstTreat == 0

cap noi did_imputation `Y' unit_num year FT_imp, pretrend(5) minn(0)
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
di "ATT: " fect_est  "  (R: 0.082334)"
di "SE:  " fect_se   "  (R boot: 0.071344)"
di "(Est coincide. SE difiere: R usa bootstrap fect, Stata usa analitico did_imputation)"

drop FT_imp


*==============================================================
* 9. GUARDAR TODOS LOS RESULTADOS
*==============================================================

preserve
clear
set obs 8

gen paper = "bischof"
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

gen double lb = estimate - 1.96 * se
gen double ub = estimate + 1.96 * se
gen double z_score = estimate / se

di ""
di "============================================"
di "  RESULTADOS FINALES: Bischof & Wagner (2019)"
di "============================================"
list name estimate se z_score, clean

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

* --- R reference values for comparison ---
gen double r_est = .
gen double r_se  = .
replace r_est =  0.116163 in 1
replace r_est =  0.117473 in 2
replace r_est =  0.078979 in 3
replace r_est =  0.121955 in 4
replace r_est = -0.011039 in 5
replace r_est =  0.000974 in 6
replace r_est =  0.081290 in 7
replace r_est =  0.082334 in 8

replace r_se  = 0.055776 in 1
replace r_se  = 0.058488 in 2
replace r_se  = 0.039790 in 3
replace r_se  = 0.061113 in 4
replace r_se  = 0.085444 in 5
replace r_se  = 0.091983 in 6
replace r_se  = 0.027130 in 7
replace r_se  = 0.071344 in 8

gen double diff_est = estimate - r_est
gen double diff_se  = se - r_se

gen str12 match = "OK" if abs(diff_est) < 0.001
replace match = "CLOSE"    if abs(diff_est) >= 0.001 & abs(diff_est) < 0.01
replace match = "DIFF_IMP" if abs(diff_est) >= 0.01

di ""
di "=========================================================="
di "  COMPARACION STATA vs R: Bischof & Wagner (2019)"
di "=========================================================="
di ""
di "  Estimador      | Stata est  | R est      | Diff est   | Match"
di "  ---------------+------------+------------+------------+------"
forvalues i = 1/8 {
    local nm = name[`i']
    local s_e = string(estimate[`i'], "%10.6f")
    local r_e = string(r_est[`i'], "%10.6f")
    local d_e = string(diff_est[`i'], "%10.6f")
    local m   = match[`i']
    di "  `nm'" _col(20) "| `s_e' | `r_e' | `d_e' | `m'"
}

di ""
di "  Estimador      | Stata SE   | R SE       | Diff SE"
di "  ---------------+------------+------------+-----------"
forvalues i = 1/8 {
    local nm = name[`i']
    local s_s = string(se[`i'], "%10.6f")
    local r_s = string(r_se[`i'], "%10.6f")
    local d_s = string(diff_se[`i'], "%10.6f")
    di "  `nm'" _col(20) "| `s_s' | `r_s' | `d_s'"
}

di ""
di "NOTAS:"
di "  - Reported, TWFE, Stack: coincidencia exacta (OK)"
di "  - SA: leve diferencia por sunab(R) vs eventstudyinteract(Stata)"
di "  - CS: diferencia grande esperada:"
di "      R recodifica year a 1-44 con as.numeric(as.factor(year))"
di "      Stata usa year original 1973-2016"
di "      Ademas, versiones distintas del paquete did/csdid"
di "  - DID_M: estimado coincide, SE difiere (implementacion distinta)"
di "  - Imputation: estimado coincide, SE difiere"
di "      R: bootstrap SE de fect(); Stata: analitico de did_imputation"

save "$path/replications/polisci/output/bischof_estimates.dta", replace

restore
