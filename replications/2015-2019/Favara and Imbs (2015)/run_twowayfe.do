/*=============================================================================
  TWFE Weight Decomposition: Favara and Imbs (2015)
  "Credit Supply and the Price of Housing"
  AER 105(3), 958-992

  Main TWFE spec: Table 4, Column 1
  xtreg Dl_hpi Linter_bra yr* [aw=w1], fe cl(state_n)

  Treatment: Linter_bra (lagged interstate branching deregulation, binary)
  Panel: county x year
  Outcome: Dl_hpi (change in log house price index)
  Weights: w1 (analytical weights)
  Clustering: state_n
=============================================================================*/

clear all
set more off
cap log close _all

* ─── STEP 1: Load and merge data ─────────────────────────────────────────────
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Favara and Imbs/20121416_1data/data"

use "$datadir/hmda.dta", clear
merge 1:1 county year using "$datadir/hp_dereg_controls.dta", nogen keep(1 3)
merge 1:1 county year using "$datadir/call.dta", nogen keep(1 3)

di _n "============================================================"
di "  STEP 1: DATA EXPLORATION"
di "============================================================"
di "Observations: " _N
desc, short

* Panel structure
qui tab county
local n_counties = r(r)
qui tab year
local n_years = r(r)
di _n "Counties (G): " `n_counties'
di "Years (T):    " `n_years'
di "Panel:        " `n_counties' " x " `n_years'

* Treatment variable
di _n "--- Treatment: Linter_bra ---"
sum Linter_bra, detail
tab Linter_bra, missing

* Outcome variable
di _n "--- Outcome: Dl_hpi ---"
sum Dl_hpi, detail

* Weights
di _n "--- Weights: w1 ---"
sum w1, detail

* Check yr* variables exist
cap ds yr*
if _rc != 0 {
    di _n "WARNING: yr* variables not found. Generating year dummies..."
    qui tab year, gen(yr)
}
else {
    di _n "yr* variables found in data"
    ds yr*
}

* ─── STEP 2: Replicate Table 4, Column 1 ─────────────────────────────────────
di _n "============================================================"
di "  STEP 2: TABLE 4, COLUMN 1 REPLICATION"
di "  xtreg Dl_hpi Linter_bra yr* [aw=w1], fe cl(state_n)"
di "============================================================"

xtset county year
xtreg Dl_hpi Linter_bra yr* [aw=w1], fe cl(state_n)

local beta_t4c1 = _b[Linter_bra]
local se_t4c1   = _se[Linter_bra]
local n_t4c1    = e(N)
local r2_t4c1   = e(r2_w)

di _n "--- Table 4 Col 1 Results ---"
di "  beta(Linter_bra) = " %9.4f `beta_t4c1'
di "  se(Linter_bra)   = " %9.4f `se_t4c1'
di "  N                = " `n_t4c1'
di "  R2 (within)      = " %9.4f `r2_t4c1'

* ─── STEP 3: twowayfeweights decomposition ───────────────────────────────────
di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "============================================================"

* --- 3a. feTR ---
di _n "--- feTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights Dl_hpi county year Linter_bra, type(feTR) weight(w1) summary_measures
local twfe_rc = _rc

local fetr_ok = 0
local fetr_beta = .
local fetr_npos = .
local fetr_nneg = .
local fetr_sumpos = .
local fetr_sumneg = .
local fetr_sens1 = .
local fetr_sens2 = .

if `twfe_rc' == 0 {
    * Command succeeded: capture from e(M) matrix
    local fetr_ok = 1
    cap local fetr_beta    = e(beta)
    cap local fetr_npos    = el(e(M),1,1)
    cap local fetr_nneg    = el(e(M),2,1)
    cap local fetr_sumpos  = el(e(M),1,2)
    cap local fetr_sumneg  = el(e(M),2,2)
    cap local fetr_sens1   = e(lb_se_te)
    cap local fetr_sens2   = e(lb_se_te2)
}
else {
    * Fallback: try global scalars (computed before crash)
    di "  twowayfeweights returned rc=`twfe_rc', trying fallback scalars..."
    cap local fetr_beta    = scalar(beta)
    cap local fetr_npos    = scalar(nplus)
    cap local fetr_nneg    = scalar(nminus)
    cap local fetr_sumpos  = scalar(sumplus)
    cap local fetr_sumneg  = scalar(summinus)
    if `fetr_npos' != . & `fetr_nneg' != . {
        local fetr_ok = 1
        di "  Fallback OK: captured from global scalars"
    }
    else {
        di "  Fallback FAILED"
    }
}

if `fetr_ok' == 1 {
    local fetr_ntot = `fetr_npos' + `fetr_nneg'
    if `fetr_ntot' > 0 {
        local fetr_pneg = 100 * `fetr_nneg' / `fetr_ntot'
    }
    else {
        local fetr_pneg = 0
    }
    di _n "--- feTR Summary ---"
    di "  beta       = " %9.4f `fetr_beta'
    di "  Pos weights: " %9.0f `fetr_npos'
    di "  Neg weights: " %9.0f `fetr_nneg'
    di "  % Negative:  " %5.1f `fetr_pneg' "%"
    di "  Sum pos w:   " %9.4f `fetr_sumpos'
    di "  Sum neg w:   " %9.4f `fetr_sumneg'
    if `fetr_sens1' != . di "  min sigma(D) for zero:  " %9.4f `fetr_sens1'
    if `fetr_sens2' != . di "  min sigma(D) for opp:   " %9.4f `fetr_sens2'
}
else {
    di "feTR FAILED completely with rc=`twfe_rc'"
}

* --- 3b. fdTR ---
di _n "--- fdTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights Dl_hpi county year Linter_bra, type(fdTR) weight(w1) summary_measures
local twfe_rc = _rc

local fdtr_ok = 0
local fdtr_beta = .
local fdtr_npos = .
local fdtr_nneg = .
local fdtr_sumpos = .
local fdtr_sumneg = .
local fdtr_sens1 = .
local fdtr_sens2 = .

if `twfe_rc' == 0 {
    local fdtr_ok = 1
    cap local fdtr_beta    = e(beta)
    cap local fdtr_npos    = el(e(M),1,1)
    cap local fdtr_nneg    = el(e(M),2,1)
    cap local fdtr_sumpos  = el(e(M),1,2)
    cap local fdtr_sumneg  = el(e(M),2,2)
    cap local fdtr_sens1   = e(lb_se_te)
    cap local fdtr_sens2   = e(lb_se_te2)
}
else {
    di "  twowayfeweights fdTR returned rc=`twfe_rc', trying fallback..."
    cap local fdtr_beta    = scalar(beta)
    cap local fdtr_npos    = scalar(nplus)
    cap local fdtr_nneg    = scalar(nminus)
    cap local fdtr_sumpos  = scalar(sumplus)
    cap local fdtr_sumneg  = scalar(summinus)
    if `fdtr_npos' != . & `fdtr_nneg' != . {
        local fdtr_ok = 1
        di "  Fallback OK"
    }
    else {
        di "  Fallback FAILED"
    }
}

if `fdtr_ok' == 1 {
    local fdtr_ntot = `fdtr_npos' + `fdtr_nneg'
    if `fdtr_ntot' > 0 {
        local fdtr_pneg = 100 * `fdtr_nneg' / `fdtr_ntot'
    }
    else {
        local fdtr_pneg = 0
    }
    di _n "--- fdTR Summary ---"
    di "  beta       = " %9.4f `fdtr_beta'
    di "  Pos weights: " %9.0f `fdtr_npos'
    di "  Neg weights: " %9.0f `fdtr_nneg'
    di "  % Negative:  " %5.1f `fdtr_pneg' "%"
    di "  Sum pos w:   " %9.4f `fdtr_sumpos'
    di "  Sum neg w:   " %9.4f `fdtr_sumneg'
    if `fdtr_sens1' != . di "  min sigma(D) for zero:  " %9.4f `fdtr_sens1'
    if `fdtr_sens2' != . di "  min sigma(D) for opp:   " %9.4f `fdtr_sens2'
}
else {
    di "fdTR FAILED completely with rc=`twfe_rc'"
}

* ─── STEP 4: LaTeX output ────────────────────────────────────────────────────
di _n "============================================================"
di "  STEP 4: LaTeX OUTPUT"
di "============================================================"

local texdir "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Favara and Imbs (2015)"

* --- Table replication ---
cap file close texfile
file open texfile using "`texdir'/table4_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Favara and Imbs (2015), Table 4, Column 1}" _n
file write texfile "\label{tab:favara_t4c1}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\hline\hline" _n
file write texfile " & $\Delta \ln(\text{HPI})$ \\" _n
file write texfile "\hline" _n
file write texfile "Linter\_bra & " %9.4f (`beta_t4c1') " \\" _n
file write texfile " & (" %9.4f (`se_t4c1') ") \\" _n
file write texfile "\hline" _n
file write texfile "County FE & Yes \\" _n
file write texfile "Year FE & Yes \\" _n
file write texfile "Weights & Yes (w1) \\" _n
file write texfile "Clustering & State \\" _n
file write texfile "N & " %9.0fc (`n_t4c1') " \\" _n
file write texfile "$R^2$ (within) & " %9.4f (`r2_t4c1') " \\" _n
file write texfile "\hline\hline" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table4_replication.tex"

* --- twowayfeweights table ---
cap file close texfile
file open texfile using "`texdir'/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition: Favara and Imbs (2015)}" _n
file write texfile "\label{tab:favara_weights}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\hline\hline" _n
file write texfile " & feTR & fdTR \\" _n
file write texfile "\hline" _n

if `fetr_ok' == 1 {
    file write texfile "$\hat{\beta}_{TWFE}$ & " %9.4f (`fetr_beta') " & "
}
else {
    file write texfile "$\hat{\beta}_{TWFE}$ & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %9.4f (`fdtr_beta') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

if `fetr_ok' == 1 {
    file write texfile "Positive weights & " (`fetr_npos') " & "
}
else {
    file write texfile "Positive weights & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile (`fdtr_npos') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

if `fetr_ok' == 1 {
    file write texfile "Negative weights & " (`fetr_nneg') " & "
}
else {
    file write texfile "Negative weights & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile (`fdtr_nneg') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

if `fetr_ok' == 1 {
    file write texfile "\% Negative & " %5.1f (`fetr_pneg') "\% & "
}
else {
    file write texfile "\% Negative & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %5.1f (`fdtr_pneg') "\% \\" _n
}
else {
    file write texfile "--- \\" _n
}

* Sum of weights row
if `fetr_ok' == 1 {
    file write texfile "$\Sigma$ positive & " %9.4f (`fetr_sumpos') " & "
}
else {
    file write texfile "$\Sigma$ positive & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %9.4f (`fdtr_sumpos') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

if `fetr_ok' == 1 {
    file write texfile "$\Sigma$ negative & $-$" %9.4f (abs(`fetr_sumneg')) " & "
}
else {
    file write texfile "$\Sigma$ negative & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile "$-$" %9.4f (abs(`fdtr_sumneg')) " \\" _n
}
else {
    file write texfile "--- \\" _n
}

file write texfile "\hline" _n

* Summary measures
if `fetr_sens1' != . {
    file write texfile "\multicolumn{3}{l}{\footnotesize min $\sigma(\Delta)$ for $\beta_{fe}$ and $\Delta_{TR}=0$: " %9.4f (`fetr_sens1') "} \\" _n
}
if `fetr_sens2' != . {
    file write texfile "\multicolumn{3}{l}{\footnotesize min $\sigma(\Delta)$ for opposite sign: " %9.4f (`fetr_sens2') "} \\" _n
}
file write texfile "\hline" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Spec: \texttt{xtreg Dl\_hpi Linter\_bra yr* [aw=w1], fe cl(state\_n)}} \\" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Panel: county $\times$ year. Treatment: lagged interstate branch deregulation.} \\" _n
if `fdtr_ok' == 0 {
    file write texfile "\multicolumn{3}{l}{\footnotesize fdTR: invalid syntax (treatment switches on/off).} \\" _n
}
file write texfile "\hline\hline" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_twowayfeweights.tex"

* --- Master LaTeX document ---
cap file close texfile
file open texfile using "`texdir'/favara_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage[margin=1in]{geometry}" _n
file write texfile "\usepackage{booktabs,caption}" _n
file write texfile "\begin{document}" _n
file write texfile "\section*{Favara and Imbs (2015): TWFE Weight Decomposition}" _n
file write texfile "\subsection*{Paper: ``Credit Supply and the Price of Housing'', AER 105(3)}" _n
file write texfile _n
file write texfile "\input{table4_replication}" _n
file write texfile _n
file write texfile "\input{table_twowayfeweights}" _n
file write texfile _n
file write texfile "\end{document}" _n

file close texfile
di "  Saved: favara_tables.tex"

* ─── STEP 5: Summary ─────────────────────────────────────────────────────────
di _n "============================================================"
di "  FINAL SUMMARY: Favara and Imbs (2015)"
di "============================================================"
di "  Table 4, Column 1"
di "  Spec: xtreg Dl_hpi Linter_bra yr* [aw=w1], fe cl(state_n)"
di "  beta(Linter_bra)  = " %9.4f `beta_t4c1'
di "  se(Linter_bra)    = " %9.4f `se_t4c1'
di "  N                 = " `n_t4c1'
di "  Panel: " `n_counties' " counties x " `n_years' " years"
di "------------------------------------------------------------"
if `fetr_ok' {
    di "  feTR: " %9.0f `fetr_npos' " pos, " %9.0f `fetr_nneg' " neg (" %5.1f `fetr_pneg' "% negative)"
    di "        Sum pos: " %9.4f `fetr_sumpos' "  Sum neg: " %9.4f `fetr_sumneg'
}
else {
    di "  feTR: FAILED"
}
if `fdtr_ok' {
    di "  fdTR: " %9.0f `fdtr_npos' " pos, " %9.0f `fdtr_nneg' " neg (" %5.1f `fdtr_pneg' "% negative)"
    di "        Sum pos: " %9.4f `fdtr_sumpos' "  Sum neg: " %9.4f `fdtr_sumneg'
}
else {
    di "  fdTR: FAILED"
}
di "============================================================"

* Done
