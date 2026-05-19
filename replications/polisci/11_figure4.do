/*==============================================================
  Replicar Figura 4: Comparison of Estimates (Staggered Cases)
  Equivalente a: code/3_plot.R lineas 67-148

  Input:  replications/polisci/output/summary.dta
  Output: replications/polisci/output/fig4_coefficients.pdf
          replications/polisci/output/fig4_zscores.pdf

  La Figura 4 muestra para cada paper (fila):
    - Diferentes simbolos por estimador (8 metodos)
    - Panel A: Eje X = estimate / reported_se (coeficiente normalizado)
    - Panel B: Eje X = z-score real (estimate / own_se)
    - Zona gris = |valor| < 1.96
    - Negro = significativo, Rojo = no significativo

  FIXES aplicados:
  - Z-scores reales (estimate/own_se) en panel B (antes usaba c_*)
  - Coloreo por significancia (negro/rojo) como en R
  - Signo flipped para que todos apunten positivos
==============================================================*/

clear all
set more off

global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"

use "replications/polisci/output/summary.dta", clear

*==============================================================
* 1. PREPARAR DATOS
*==============================================================

* Ordenar por |z_reported| (como en R: s <- s[order(abs(s$z.reported)), ])
gen abs_z = abs(z_reported)
sort abs_z
gen y_pos = _n
local N = _N

* Signo del reported (para que todos apunten en la misma direccion)
gen sign_rep = sign(z_reported)

* Normalizar coeficientes por signo (panel A)
foreach var in z_reported c_twfe c_fect c_iw c_stack c_cs_notyet c_cs_never c_didm {
    replace `var' = `var' * sign_rep
}

* Normalizar z-scores reales por signo (panel B)
foreach var in z_twfe z_fect z_iw z_stack z_cs_notyet z_cs_never z_didm {
    replace `var' = `var' * sign_rep
}

* Labels para eje Y
cap which labmask
if _rc {
    * labmask no disponible, usar labels manuales
    forvalues i = 1/`N' {
        local pname = paper[`i']
        label define ylab `i' "`pname'", add
    }
    label values y_pos ylab
}
else {
    labmask y_pos, values(paper)
}


*==============================================================
* 2. FIGURA 4a: COEFFICIENTS (estimate / reported_se)
*    R: fig4_est_st_coef.pdf
*
*    Cada metodo tiene un simbolo distinto.
*    Color: negro si |valor| > 1.96, rojo si no.
*    Para lograr colores condicionales en Stata, separamos cada
*    serie en dos: significativa (negro) y no significativa (rojo).
*==============================================================

* Generar variables de significancia para panel A (coeficientes)
* Significativo si |valor| > 1.96 -> negro, sino rojo
foreach m in twfe fect iw stack cs_notyet cs_never didm {
    gen c_`m'_sig   = c_`m' if abs(c_`m') > 1.96
    gen c_`m'_nosig = c_`m' if abs(c_`m') <= 1.96
}
* z_reported siempre significativo visualmente (reported)
gen z_rep_sig   = z_reported if abs(z_reported) > 1.96
gen z_rep_nosig = z_reported if abs(z_reported) <= 1.96

twoway ///
    (rarea y_pos y_pos, horizontal base(0) color(gs14%50)) ///
    (scatter y_pos z_rep_sig,    msymbol(O)  msize(medium) mcolor(black)) ///
    (scatter y_pos z_rep_nosig,  msymbol(O)  msize(medium) mcolor(red)) ///
    (scatter y_pos c_twfe_sig,   msymbol(Oh) msize(medium) mcolor(black)) ///
    (scatter y_pos c_twfe_nosig, msymbol(Oh) msize(medium) mcolor(red)) ///
    (scatter y_pos c_fect_sig,   msymbol(S)  msize(small)  mcolor(black)) ///
    (scatter y_pos c_fect_nosig, msymbol(S)  msize(small)  mcolor(red)) ///
    (scatter y_pos c_iw_sig,     msymbol(+)  msize(medium) mcolor(black)) ///
    (scatter y_pos c_iw_nosig,   msymbol(+)  msize(medium) mcolor(red)) ///
    (scatter y_pos c_cs_notyet_sig,   msymbol(T) msize(small) mcolor(black)) ///
    (scatter y_pos c_cs_notyet_nosig, msymbol(T) msize(small) mcolor(red)) ///
    (scatter y_pos c_cs_never_sig,    msymbol(V) msize(small) mcolor(black)) ///
    (scatter y_pos c_cs_never_nosig,  msymbol(V) msize(small) mcolor(red)) ///
    (scatter y_pos c_stack_sig,   msymbol(X) msize(small) mcolor(black)) ///
    (scatter y_pos c_stack_nosig, msymbol(X) msize(small) mcolor(red)) ///
    (scatter y_pos c_didm_sig,    msymbol(D) msize(small) mcolor(black)) ///
    (scatter y_pos c_didm_nosig,  msymbol(D) msize(small) mcolor(red)) ///
    , ///
    xline(0, lcolor(blue) lpattern(dash) lwidth(medthick)) ///
    xline(-1.96 1.96, lcolor(gray) lpattern(dot)) ///
    ylabel(1/`N', valuelabel angle(0) labsize(vsmall)) ///
    xlabel(-2.5(2.5)10) ///
    xtitle("Estimate / Reported TWFE SE") ///
    ytitle("") ///
    legend(order(2 "Reported TWFE" 4 "TWFE (no always treated)" ///
                 6 "Imputation" 8 "IW" ///
                 10 "CSDID (not yet)" 12 "CSDID (never)" ///
                 14 "StackDID" 16 "DID_M") ///
           pos(4) col(1) size(vsmall)) ///
    scheme(s2color) ///
    note("Black = significant (|coef/rep_se| > 1.96), Red = not significant")

graph export "replications/polisci/output/fig4_coefficients.pdf", replace


*==============================================================
* 3. FIGURA 4b: Z-SCORES REALES (estimate / own_se)
*    R: fig4_est_st_z.pdf
*
*    CORRECCION: Usa z-scores reales, NO c_* (coef/reported_se)
*    z_method = estimate_method / se_method
*==============================================================

* Generar variables de significancia para panel B (z-scores reales)
foreach m in twfe fect iw stack cs_notyet cs_never didm {
    gen z_`m'_sig   = z_`m' if abs(z_`m') > 1.96
    gen z_`m'_nosig = z_`m' if abs(z_`m') <= 1.96
}

twoway ///
    (scatter y_pos z_rep_sig,    msymbol(O)  msize(medium) mcolor(black)) ///
    (scatter y_pos z_rep_nosig,  msymbol(O)  msize(medium) mcolor(red)) ///
    (scatter y_pos z_twfe_sig,   msymbol(Oh) msize(medium) mcolor(black)) ///
    (scatter y_pos z_twfe_nosig, msymbol(Oh) msize(medium) mcolor(red)) ///
    (scatter y_pos z_fect_sig,   msymbol(S)  msize(small)  mcolor(black)) ///
    (scatter y_pos z_fect_nosig, msymbol(S)  msize(small)  mcolor(red)) ///
    (scatter y_pos z_iw_sig,     msymbol(+)  msize(medium) mcolor(black)) ///
    (scatter y_pos z_iw_nosig,   msymbol(+)  msize(medium) mcolor(red)) ///
    (scatter y_pos z_cs_notyet_sig,   msymbol(T) msize(small) mcolor(black)) ///
    (scatter y_pos z_cs_notyet_nosig, msymbol(T) msize(small) mcolor(red)) ///
    (scatter y_pos z_cs_never_sig,    msymbol(V) msize(small) mcolor(black)) ///
    (scatter y_pos z_cs_never_nosig,  msymbol(V) msize(small) mcolor(red)) ///
    (scatter y_pos z_stack_sig,   msymbol(X) msize(small) mcolor(black)) ///
    (scatter y_pos z_stack_nosig, msymbol(X) msize(small) mcolor(red)) ///
    (scatter y_pos z_didm_sig,    msymbol(D) msize(small) mcolor(black)) ///
    (scatter y_pos z_didm_nosig,  msymbol(D) msize(small) mcolor(red)) ///
    , ///
    xline(0, lcolor(blue) lpattern(dash) lwidth(medthick)) ///
    xline(-1.96 1.96, lcolor(gray) lpattern(dot)) ///
    ylabel(1/`N', nolabel) ///
    xlabel(-2.5(2.5)10) ///
    xtitle("Z-Score (Estimate / Own SE)") ///
    ytitle("") ///
    legend(order(1 "Reported TWFE" 3 "TWFE (no always treated)" ///
                 5 "Imputation" 7 "IW" ///
                 9 "CSDID (not yet)" 11 "CSDID (never)" ///
                 13 "StackDID" 15 "DID_M") ///
           pos(4) col(1) size(vsmall)) ///
    scheme(s2color) ///
    note("Black = significant (|z| > 1.96), Red = not significant")

graph export "replications/polisci/output/fig4_zscores.pdf", replace

di ""
di "=== FIGURAS GUARDADAS ==="
di "  replications/polisci/output/fig4_coefficients.pdf"
di "  replications/polisci/output/fig4_zscores.pdf"
