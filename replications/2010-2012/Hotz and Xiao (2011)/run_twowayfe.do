/*=============================================================================
  TWFE Weight Decomposition: Hotz and Xiao (2011)
  "The Role of Minimum Quality Standards in the Child Care Market"
  AER 101(5), 1775-1805

  Main TWFE spec: nonemployer_analysis.do Module 1 (state-level)
  areg estab scrat educ [controls] year1992 year1997, absorb(num_st) cluster(year_st)

  Treatment: scrat (staff-child ratio index, continuous)
             educ  (education requirement index, continuous)
  Unit FE: num_st (state)
  Time FE: year (1987, 1992, 1997)
  Outcome: estab (nonemployer establishments, thousands)

  Table reference: Table 3 in dCDH Web Appendix
  Spec vars_dc5: scrat educ + demographics
=============================================================================*/

clear all
set more off
cap log close _all
set matsize 800

adopath + "C:/Users/Usuario/Documents/GitHub/twfe_survey"

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Hotz and Xiao (2011)"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Hotz and Xiao (2011)"
global texdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Hotz and Xiao (2011)"

log using "$outdir/run_twowayfe.log", replace

* =============================================================================
* STEP 1: Load panel_GTD.dta
* =============================================================================
di _n "============================================================"
di "  STEP 1: DATA PREPARATION"
di "============================================================"

use "$datadir/panel_GTD.dta", clear

di "Panel obs: " _N

* Panel structure
qui tab num_st
local n_groups = r(r)
qui tab year
local n_years = r(r)
di "States (G): " `n_groups'
di "Years (T): " `n_years'
di "Panel: " `n_groups' " x " `n_years' " = " `n_groups' * `n_years'

di _n "--- Treatment 1: scrat (staff-child ratio) ---"
sum scrat, detail

di _n "--- Treatment 2: educ (education index) ---"
sum educ, detail

di _n "--- Outcome: estab (nonemployer establishments, 1000s) ---"
sum estab, detail

* =============================================================================
* STEP 2: Replicate nonemployer regressions
* =============================================================================
di _n "============================================================"
di "  STEP 2: REGRESSION REPLICATION"
di "  nonemployer_analysis.do Module 1 (state-level)"
di "============================================================"

local idv "pct_black pct_hisp hh_size ln_m_inc college ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural"

* --- Spec A: scrat + educ + demographics + year FE + state FE (vars_dc5) ---
di _n "--- Spec A: areg estab scrat educ `idv' year1992 year1997, absorb(num_st) cluster(year_st) ---"
areg estab scrat educ `idv' year1992 year1997, absorb(num_st) cluster(year_st)

local beta_scrat_a  = _b[scrat]
local se_scrat_a    = _se[scrat]
local beta_educ_a   = _b[educ]
local se_educ_a     = _se[educ]
local n_a           = e(N)
local r2_a          = e(r2)

local t_scrat_a = `beta_scrat_a' / `se_scrat_a'
local stars_scrat_a = ""
if abs(`t_scrat_a') > 2.576      local stars_scrat_a = "***"
else if abs(`t_scrat_a') > 1.960 local stars_scrat_a = "**"
else if abs(`t_scrat_a') > 1.645 local stars_scrat_a = "*"

local t_educ_a = `beta_educ_a' / `se_educ_a'
local stars_educ_a = ""
if abs(`t_educ_a') > 2.576      local stars_educ_a = "***"
else if abs(`t_educ_a') > 1.960 local stars_educ_a = "**"
else if abs(`t_educ_a') > 1.645 local stars_educ_a = "*"

di "  beta(scrat)  = " %9.4f `beta_scrat_a' " `stars_scrat_a'  (se = " %9.4f `se_scrat_a' ")"
di "  beta(educ)   = " %9.4f `beta_educ_a'  " `stars_educ_a'   (se = " %9.4f `se_educ_a'  ")"
di "  N            = " `n_a'
di "  R2           = " %6.4f `r2_a'

* --- Spec B: no demographics (stripped TWFE) ---
di _n "--- Spec B: areg estab scrat educ year1992 year1997, absorb(num_st) cluster(year_st) ---"
areg estab scrat educ year1992 year1997, absorb(num_st) cluster(year_st)

local beta_scrat_b  = _b[scrat]
local se_scrat_b    = _se[scrat]
local beta_educ_b   = _b[educ]
local se_educ_b     = _se[educ]
local n_b           = e(N)
local r2_b          = e(r2)

local t_scrat_b = `beta_scrat_b' / `se_scrat_b'
local stars_scrat_b = ""
if abs(`t_scrat_b') > 2.576      local stars_scrat_b = "***"
else if abs(`t_scrat_b') > 1.960 local stars_scrat_b = "**"
else if abs(`t_scrat_b') > 1.645 local stars_scrat_b = "*"

local t_educ_b = `beta_educ_b' / `se_educ_b'
local stars_educ_b = ""
if abs(`t_educ_b') > 2.576      local stars_educ_b = "***"
else if abs(`t_educ_b') > 1.960 local stars_educ_b = "**"
else if abs(`t_educ_b') > 1.645 local stars_educ_b = "*"

di "  beta(scrat)  = " %9.4f `beta_scrat_b' " `stars_scrat_b'"
di "  beta(educ)   = " %9.4f `beta_educ_b'  " `stars_educ_b'"

* =============================================================================
* STEP 3: twowayfeweights decomposition
* =============================================================================
di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "  Y = estab, G = num_st, T = year, D = scrat"
di "  other_treatments = educ"
di "============================================================"

* --- 3a. feTR ---
di _n "--- feTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights estab num_st year scrat, type(feTR) other_treatments(educ) summary_measures
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
    di "  twowayfeweights returned rc=`twfe_rc', trying fallback..."
    cap local fetr_beta    = scalar(beta)
    cap local fetr_npos    = scalar(nplus)
    cap local fetr_nneg    = scalar(nminus)
    cap local fetr_sumpos  = scalar(sumplus)
    cap local fetr_sumneg  = scalar(summinus)
    if `fetr_npos' != . & `fetr_nneg' != . {
        local fetr_ok = 1
        di "  Fallback OK"
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
    if `fetr_sens1' != . di "  min sigma for zero:  " %9.4f `fetr_sens1'
    if `fetr_sens2' != . di "  min sigma for opp:   " %9.4f `fetr_sens2'
}
else {
    di "feTR FAILED completely with rc=`twfe_rc'"
}

* --- 3b. fdTR ---
di _n "--- fdTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights estab num_st year scrat, type(fdTR) other_treatments(educ) summary_measures
local twfe_rc_fd = _rc

local fdtr_ok = 0
local fdtr_beta = .
local fdtr_npos = .
local fdtr_nneg = .
local fdtr_sumpos = .
local fdtr_sumneg = .
local fdtr_sens1 = .
local fdtr_sens2 = .

if `twfe_rc_fd' == 0 {
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
    di "  twowayfeweights fdTR returned rc=`twfe_rc_fd', trying fallback..."
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
    if `fdtr_sens1' != . di "  min sigma for zero:  " %9.4f `fdtr_sens1'
    if `fdtr_sens2' != . di "  min sigma for opp:   " %9.4f `fdtr_sens2'
}
else {
    di "fdTR FAILED completely with rc=`twfe_rc_fd'"
}

* =============================================================================
* STEP 3c: classify_design
* =============================================================================
di _n "============================================================"
di "  STEP 3c: CLASSIFY DESIGN"
di "============================================================"

use "$datadir/panel_GTD.dta", clear
classify_design num_st year scrat

local design  "`r(design)'"
local subtype "`r(subtype)'"
di _n "Design:  `design'"
di "Subtype: `subtype'"

* =============================================================================
* STEP 4: LaTeX output
* =============================================================================
di _n "============================================================"
di "  STEP 4: LaTeX OUTPUT"
di "============================================================"

* --- Table replication ---
cap file close texfile
file open texfile using "$texdir/table_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Hotz and Xiao (2011), Nonemployer Analysis}" _n
file write texfile "\label{tab:hotz_xiao_nonemp}" _n
file write texfile "\begin{adjustbox}{max width=\textwidth}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & (1) & (2) \\" _n
file write texfile " & No Controls & With Controls \\" _n
file write texfile "\midrule" _n

* scrat rows
file write texfile "Staff-child ratio (scrat)"
file write texfile " & " %9.4f (`beta_scrat_b') "`stars_scrat_b'"
file write texfile " & " %9.4f (`beta_scrat_a') "`stars_scrat_a'"
file write texfile " \\" _n
file write texfile " & (" %9.4f (`se_scrat_b') ")"
file write texfile " & (" %9.4f (`se_scrat_a') ")"
file write texfile " \\" _n

file write texfile "\addlinespace" _n

* educ rows
file write texfile "Education index (educ)"
file write texfile " & " %9.4f (`beta_educ_b') "`stars_educ_b'"
file write texfile " & " %9.4f (`beta_educ_a') "`stars_educ_a'"
file write texfile " \\" _n
file write texfile " & (" %9.4f (`se_educ_b') ")"
file write texfile " & (" %9.4f (`se_educ_a') ")"
file write texfile " \\" _n

file write texfile "\midrule" _n

* Controls/FE indicators
file write texfile "State FE & Yes & Yes \\" _n
file write texfile "Year dummies & Yes & Yes \\" _n
file write texfile "Demographics & No & Yes \\" _n

file write texfile "\midrule" _n

* N and R2
file write texfile "N & " %9.0f (`n_b') " & " %9.0f (`n_a') " \\" _n
file write texfile "$R^2$ & " %6.4f (`r2_b') " & " %6.4f (`r2_a') " \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{3}{p{0.85\linewidth}}{\footnotesize" _n
file write texfile "\textit{Notes:} State-level nonemployer analysis. " _n
file write texfile "Dependent variable: number of nonemployer child care establishments (thousands). " _n
file write texfile "Standard errors clustered by state-year in parentheses. " _n
file write texfile "Demographics: \% black, \% Hispanic, household size, median income, " _n
file write texfile "\% college, under-5 population, \% female-headed w/children, " _n
file write texfile "\% female not working, \% unemployed, \% work-at-home, " _n
file write texfile "long commute, \% rural. " _n
file write texfile "*** $p<0.01$, ** $p<0.05$, * $p<0.10$.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{adjustbox}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_replication.tex"

* --- twowayfeweights table ---
cap file close texfile
file open texfile using "$texdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition: Hotz and Xiao (2011)}" _n
file write texfile "\label{tab:hotz_xiao_weights}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & feTR & fdTR \\" _n
file write texfile "\midrule" _n

* beta
if `fetr_ok' == 1 {
    file write texfile "$\hat{\beta}_{fe}$ & " %9.4f (`fetr_beta') " & "
}
else {
    file write texfile "$\hat{\beta}_{fe}$ & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %9.4f (`fdtr_beta') " \\" _n
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
    file write texfile "$\sum w^+$ & " %9.4f (`fetr_sumpos') " & "
}
else {
    file write texfile "$\sum w^+$ & --- & "
}
if `fdtr_ok' == 1 {
    file write texfile %9.4f (`fdtr_sumpos') " \\" _n
}
else {
    file write texfile "--- \\" _n
}

if `fetr_ok' == 1 & `fetr_sumneg' != . {
    file write texfile "$\sum w^-$ & $-$" %9.4f (abs(`fetr_sumneg')) " & "
}
else {
    file write texfile "$\sum w^-$ & --- & "
}
if `fdtr_ok' == 1 & `fdtr_sumneg' != . {
    file write texfile "$-$" %9.4f (abs(`fdtr_sumneg')) " \\" _n
}
else {
    file write texfile "--- \\" _n
}

file write texfile "\midrule" _n

* Sensitivity measures
if `fetr_sens1' != . {
    file write texfile "\multicolumn{3}{l}{\footnotesize Min $\sigma(\Delta)$ for $\beta_{fe}=0$: " %9.4f (`fetr_sens1') "} \\" _n
}
if `fetr_sens2' != . {
    file write texfile "\multicolumn{3}{l}{\footnotesize Min $\sigma(\Delta)$ for opposite sign: " %9.4f (`fetr_sens2') "} \\" _n
}

file write texfile "\addlinespace" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Design classification: `design'" _n
if "`subtype'" != "" {
    file write texfile " (`subtype')" _n
}
file write texfile "} \\" _n

file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{p{0.85\linewidth}}{\footnotesize" _n
file write texfile "Spec: state FE + year FE. " _n
file write texfile "$Y$ = nonemployer establishments (1000s). " _n
file write texfile "$D$ = staff-child ratio index (continuous). " _n
file write texfile "Other treatment: education index. " _n
file write texfile "$G$ = state. $T$ = year (1987, 1992, 1997).}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_twowayfeweights.tex"

* --- Master LaTeX document ---
cap file close texfile
file open texfile using "$texdir/hotz_xiao_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage[margin=1in]{geometry}" _n
file write texfile "\usepackage{booktabs,caption,adjustbox,amsmath,amsfonts}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n

file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Hotz and Xiao (2011)}\\" _n
file write texfile "{\large The Role of Minimum Quality Standards}" _n
file write texfile "{\large in the Child Care Market}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(5), 1775--1805}" _n
file write texfile "\end{center}" _n _n

file write texfile "\vspace{1em}" _n _n

file write texfile "\input{table_replication}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n

file write texfile "\end{document}" _n

file close texfile
di "  Saved: hotz_xiao_tables.tex"

* =============================================================================
* STEP 5: Final summary
* =============================================================================
di _n "============================================================"
di "  FINAL SUMMARY: Hotz and Xiao (2011)"
di "============================================================"
di "  Nonemployer Analysis (state-level)"
di "------------------------------------------------------------"
di "  Spec A (with controls):"
di "    scrat: beta = " %9.4f `beta_scrat_a' " `stars_scrat_a'  (se = " %9.4f `se_scrat_a' ")"
di "    educ:  beta = " %9.4f `beta_educ_a'  " `stars_educ_a'   (se = " %9.4f `se_educ_a'  ")"
di "  Spec B (no controls):"
di "    scrat: beta = " %9.4f `beta_scrat_b' " `stars_scrat_b'  (se = " %9.4f `se_scrat_b' ")"
di "    educ:  beta = " %9.4f `beta_educ_b'  " `stars_educ_b'   (se = " %9.4f `se_educ_b'  ")"
di "  N = " `n_a' " (" `n_groups' " states x " `n_years' " years)"
di "------------------------------------------------------------"
di "  twowayfeweights:"
if `fetr_ok' {
    di "    feTR: " %9.0f `fetr_npos' " pos, " %9.0f `fetr_nneg' " neg (" %5.1f `fetr_pneg' "% negative)"
    di "          Sum pos: " %9.4f `fetr_sumpos' "  Sum neg: " %9.4f `fetr_sumneg'
}
else {
    di "    feTR: FAILED"
}
if `fdtr_ok' {
    di "    fdTR: " %9.0f `fdtr_npos' " pos, " %9.0f `fdtr_nneg' " neg (" %5.1f `fdtr_pneg' "% negative)"
    di "          Sum pos: " %9.4f `fdtr_sumpos' "  Sum neg: " %9.4f `fdtr_sumneg'
}
else {
    di "    fdTR: FAILED"
}
di "------------------------------------------------------------"
di "  Design: `design'"
if "`subtype'" != "" di "  Subtype: `subtype'"
di "============================================================"

log close
