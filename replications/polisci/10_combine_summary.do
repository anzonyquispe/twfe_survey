/*==============================================================
  Combinar estimaciones de todos los papers
  Equivalente a: code/0b_combine_data.R

  Requiere haber corrido: 01_bischof.do, 02_clayton.do, etc.
  Cada uno guarda: replications/polisci/output/{paper}_estimates.dta

  Output: replications/polisci/output/summary.dta

  FIXES aplicados:
  - Corregido rename "Sun&Abraham" -> "Sun_Abraham" (bug original)
  - Agregado z-scores reales (estimate/se de cada metodo)
  - Agregado z_reported basado en SE del reported
==============================================================*/

clear all
set more off

global path "C:/Users/Usuario/Documents/GitHub/twfe_survey"
cd "$path"

*==============================================================
* 1. APILAR TODOS LOS PAPERS
*==============================================================

local papers "bischof clayton christensen hankinson eckhouse paglayan kuipers esberg hirano trounstine hainmueller"

local first = 1
foreach p of local papers {
    local f "replications/polisci/output/`p'_estimates.dta"
    cap confirm file "`f'"
    if _rc == 0 {
        if `first' == 1 {
            use "`f'", clear
            local first = 0
        }
        else {
            append using "`f'"
        }
        di "Cargado: `p'"
    }
    else {
        di "NO ENCONTRADO: `f'"
    }
}

*==============================================================
* 2. RESHAPE: de long (1 fila por metodo) a wide (1 fila por paper)
*==============================================================

* Limpiar nombres de metodos para reshape
* FIX: usar "Sun_Abraham" (como guardan los .do), NO "Sun&Abraham"
replace name = "reported"  if name == "Reported"
replace name = "twfe"      if name == "TWFE"
replace name = "iw"        if name == "Sun_Abraham"
replace name = "stack"     if name == "Stacked_DID"
replace name = "cs_notyet" if name == "CS_NotYet"
replace name = "cs_never"  if name == "CS_Never"
replace name = "didm"      if name == "DID_M"
replace name = "fect"      if name == "Imputation"

* Reshape wide
reshape wide estimate se lb ub z_score, i(paper) j(name) string

*==============================================================
* 3. RENOMBRAR Y CALCULAR METRICAS
*==============================================================

* Renombrar columnas de estimate y se
foreach m in reported twfe iw stack cs_notyet cs_never didm fect {
    cap rename estimate`m' `m'
    cap rename se`m' `m'_se
}

* Calcular coeficientes normalizados (estimate / reported_se) para Figure 4 panel a
gen c_twfe      = twfe / reported_se
gen c_fect      = fect / reported_se
gen c_iw        = iw / reported_se
gen c_stack     = stack / reported_se
gen c_cs_notyet = cs_notyet / reported_se
gen c_cs_never  = cs_never / reported_se
gen c_didm      = didm / reported_se

* Z-score del reported (estimate / own SE)
gen z_reported  = reported / reported_se

* Z-scores REALES para cada metodo (estimate / own SE)
* Esto es lo que usa el panel de z-scores de Figure 4
gen z_twfe      = twfe / twfe_se
gen z_fect      = fect / fect_se
gen z_iw        = iw / iw_se
gen z_stack     = stack / stack_se
gen z_cs_notyet = cs_notyet / cs_notyet_se
gen z_cs_never  = cs_never / cs_never_se
gen z_didm      = didm / didm_se

*==============================================================
* 4. GUARDAR SUMMARY
*==============================================================

order paper z_reported c_twfe c_fect c_iw c_stack c_cs_notyet c_cs_never c_didm ///
      z_twfe z_fect z_iw z_stack z_cs_notyet z_cs_never z_didm
save "replications/polisci/output/summary.dta", replace

di ""
di "=== SUMMARY GUARDADO ==="
di ""
di "--- Coeficientes normalizados (estimate / reported_se) ---"
list paper z_reported c_twfe c_fect c_iw c_stack c_cs_notyet c_cs_never c_didm, clean
di ""
di "--- Z-scores reales (estimate / own_se) ---"
list paper z_reported z_twfe z_fect z_iw z_stack z_cs_notyet z_cs_never z_didm, clean
