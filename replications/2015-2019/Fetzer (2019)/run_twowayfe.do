/*=============================================================================
  TWFE Weight Decomposition: Fetzer (2019)
  "Did Austerity Cause Brexit?"
  AER 109(11), 3849-3886

  Main TWFE spec: Table 1, Panel A, Column 1
  reghdfe pct_votes_UKIP temp, absorb(id ryr) vce(cl id) nocons
  where temp = post2010 * totalimpact_finlosswap

  Treatment: temp (post-austerity × fiscal impact per capita, continuous)
  Unit FE: id (local authority district)
  Time FE: ryr (region × year)
  Outcome: pct_votes_UKIP (local election UKIP vote share)
  Clustering: id
=============================================================================*/

clear all
set more off
cap log close _all

* ─── STEP 1: Load data ─────────────────────────────────────────────────────
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Fetzer (2019)/data-files"

use "$datadir/DISTRICT.dta", clear

di _n "============================================================"
di "  STEP 1: DATA EXPLORATION"
di "============================================================"
di "Observations: " _N

* Panel structure
qui tab id
local n_districts = r(r)
qui tab year
local n_years = r(r)
qui tab ryr
local n_ryr = r(r)
di "Districts (id): " `n_districts'
di "Years:          " `n_years'
di "Region-year:    " `n_ryr'

* Create treatment variable
gen temp = post2010 * totalimpact_finlosswap

* Check treatment
di _n "--- Treatment: temp = post2010 * totalimpact_finlosswap ---"
sum temp, detail

* ─── STEP 2: Replicate Table 1, Panel A, Column 1 ──────────────────────────
di _n "============================================================"
di "  STEP 2: TABLE 1, PANEL A, COL 1 REPLICATION"
di "  reghdfe pct_votes_UKIP temp, absorb(id ryr) vce(cl id) nocons"
di "============================================================"

reghdfe pct_votes_UKIP temp, absorb(id ryr) vce(cl id) nocons

local beta_t1c1 = _b[temp]
local se_t1c1   = _se[temp]
local n_t1c1    = e(N)
local r2_t1c1   = e(r2)

di _n "--- Table 1 Panel A Col 1 Results ---"
di "  beta(temp)  = " %12.6f `beta_t1c1'
di "  se(temp)    = " %12.6f `se_t1c1'
di "  N           = " `n_t1c1'

* ─── STEP 3: twowayfeweights decomposition ──────────────────────────────────
di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "  G = id, T = ryr, D = temp"
di "============================================================"

* --- 3a. feTR ---
di _n "--- feTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights pct_votes_UKIP id ryr temp, type(feTR) summary_measures
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
    di "  beta       = " %12.6f `fetr_beta'
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
cap noisily twowayfeweights pct_votes_UKIP id ryr temp, type(fdTR) summary_measures
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
    di "  beta       = " %12.6f `fdtr_beta'
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

* ─── STEP 4: LaTeX output ──────────────────────────────────────────────────
di _n "============================================================"
di "  STEP 4: LaTeX OUTPUT"
di "============================================================"

local texdir "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Fetzer (2019)"

* --- Table replication ---
cap file close texfile
file open texfile using "`texdir'/table1_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Fetzer (2019), Table 1, Panel A, Column 1}" _n
file write texfile "\label{tab:fetzer_t1c1}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\hline\hline" _n
file write texfile " & \% UKIP (local) \\" _n
file write texfile "\hline" _n
file write texfile "$\mathbb{1}$(Year$>$2010) $\times$ Austerity & " %12.6f (`beta_t1c1') " \\" _n
file write texfile " & (" %12.6f (`se_t1c1') ") \\" _n
file write texfile "\hline" _n
file write texfile "District FE & Yes \\" _n
file write texfile "Region $\times$ Year FE & Yes \\" _n
file write texfile "Clustering & District \\" _n
file write texfile "N & " %9.0fc (`n_t1c1') " \\" _n
file write texfile "\hline\hline" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table1_replication.tex"

* --- twowayfeweights table ---
cap file close texfile
file open texfile using "`texdir'/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition: Fetzer (2019)}" _n
file write texfile "\label{tab:fetzer_weights}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\hline\hline" _n
file write texfile " & feTR & fdTR \\" _n
file write texfile "\hline" _n

* beta row
if `fetr_ok' == 1 {
    file write texfile "$\hat{\beta}_{TWFE}$ & " %12.6f (`fetr_beta') " & "
}
else {
    file write texfile "$\hat{\beta}_{TWFE}$ & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %12.6f (`fdtr_beta') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

* Positive weights
if `fetr_ok' == 1 {
    file write texfile "Positive weights & " %9.0f (`fetr_npos') " & "
}
else {
    file write texfile "Positive weights & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %9.0f (`fdtr_npos') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

* Negative weights
if `fetr_ok' == 1 {
    file write texfile "Negative weights & " %9.0f (`fetr_nneg') " & "
}
else {
    file write texfile "Negative weights & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %9.0f (`fdtr_nneg') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

* % Negative
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

* Sum weights
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

if `fetr_ok' == 1 & `fetr_sumneg' != . {
    file write texfile "$\Sigma$ negative & $-$" %9.4f (abs(`fetr_sumneg')) " & "
}
else {
    file write texfile "$\Sigma$ negative & --- & "
}
if `fdtr_ok' == 1 & `fdtr_sumneg' != . {
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
if `fetr_sens1' == . & `fetr_ok' == 1 {
    file write texfile "\multicolumn{3}{l}{\footnotesize Sensitivity measures unavailable.} \\" _n
}
file write texfile "\hline" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Spec: \texttt{reghdfe pct\_votes\_UKIP temp, absorb(id ryr) vce(cl id)}} \\" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Panel: district $\times$ year. Treatment: post-2010 $\times$ austerity impact (continuous).} \\" _n
file write texfile "\hline\hline" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_twowayfeweights.tex"

* --- Master LaTeX document ---
cap file close texfile
file open texfile using "`texdir'/fetzer_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage[margin=1in]{geometry}" _n
file write texfile "\usepackage{booktabs,caption,amsfonts}" _n
file write texfile "\begin{document}" _n
file write texfile "\section*{Fetzer (2019): TWFE Weight Decomposition}" _n
file write texfile "\subsection*{Paper: ``Did Austerity Cause Brexit?'', AER 109(11)}" _n
file write texfile _n
file write texfile "\input{table1_replication}" _n
file write texfile _n
file write texfile "\input{table_twowayfeweights}" _n
file write texfile _n
file write texfile "\end{document}" _n

file close texfile
di "  Saved: fetzer_tables.tex"

* ─── STEP 5: Summary ─────────────────────────────────────────────────────
di _n "============================================================"
di "  FINAL SUMMARY: Fetzer (2019)"
di "============================================================"
di "  Table 1, Panel A, Col 1"
di "  Spec: reghdfe pct_votes_UKIP temp, absorb(id ryr) vce(cl id)"
di "  beta(temp) = " %12.6f `beta_t1c1'
di "  se(temp)   = " %12.6f `se_t1c1'
di "  N          = " `n_t1c1'
di "  Panel: " `n_districts' " districts x " `n_years' " years (" `n_ryr' " region-year groups)"
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
