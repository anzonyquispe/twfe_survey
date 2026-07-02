/*=============================================================================
  TWFE Weight Decomposition: Pierce and Schott (2016)
  "The Surprisingly Swift Decline of US Manufacturing Employment"
  AER 106(7), 1632-1662

  Main TWFE spec: Table 1, Column 1
  areg lemp s1999_post d1991-d2007 [aw=emp1990], a(fam50) cl(fam50) robust

  Treatment: s1999_post (NTR gap x post-PNTR, continuous)
  Unit FE: fam50 (industry family)
  Time FE: year (1990-2007, via dummies d1991-d2007)
  Outcome: lemp (log employment, NBER-CES)
  Weight: emp1990 (1990 employment level)

  NOTE: Original paper uses restricted Census LBD data.
        We substitute NBER-CES public data (naics5809.dta).
        TWFE structure (G,T,D) identical; magnitudes differ.
=============================================================================*/

clear all
set more off
cap log close _all
set matsize 5000

adopath + "C:/Users/Usuario/Documents/GitHub/twfe_survey"

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Pierce and Schott (2016)"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Pierce and Schott (2016)"
global texdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Pierce and Schott (2016)"

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
qui tab fam50
local n_groups = r(r)
qui tab year
local n_years = r(r)
di "Industry families (G): " `n_groups'
di "Years (T): " `n_years'
di "Panel: " `n_groups' " x " `n_years' " = " `n_groups' * `n_years'

di _n "--- Treatment: s1999_post (NTR gap x post) ---"
sum s1999_post, detail

di _n "--- Outcome: lemp (log employment) ---"
sum lemp, detail

di _n "--- Weight: emp1990 ---"
sum emp1990, detail

* =============================================================================
* STEP 2: Replicate Table 1
* =============================================================================
di _n "============================================================"
di "  STEP 2: TABLE 1 REPLICATION"
di "============================================================"

* --- Col 1: Industry FE + Year dummies (main TWFE spec) ---
di _n "--- Table 1, Col 1: areg lemp s1999_post d???? [aw=emp1990], a(fam50) ---"
areg lemp s1999_post d1991-d2007 [aw=emp1990], a(fam50) cl(fam50) robust

local beta_c1 = _b[s1999_post]
local se_c1   = _se[s1999_post]
local n_c1    = e(N)
local r2_c1   = e(r2)
local t_c1    = `beta_c1' / `se_c1'
local stars_c1 = ""
if abs(`t_c1') > 2.576      local stars_c1 = "***"
else if abs(`t_c1') > 1.960 local stars_c1 = "**"
else if abs(`t_c1') > 1.645 local stars_c1 = "*"

di "  beta = " %9.4f `beta_c1' " `stars_c1'"
di "  se   = " %9.4f `se_c1'
di "  N    = " `n_c1'
di "  R2   = " %6.4f `r2_c1'

* --- Col 2: + capital/skill controls ---
di _n "--- Table 1, Col 2: + lkl1990_post lsl1990_post ---"
areg lemp s1999_post lkl1990_post lsl1990_post d1991-d2007 [aw=emp1990], a(fam50) cl(fam50) robust

local beta_c2 = _b[s1999_post]
local se_c2   = _se[s1999_post]
local n_c2    = e(N)
local r2_c2   = e(r2)
local t_c2    = `beta_c2' / `se_c2'
local stars_c2 = ""
if abs(`t_c2') > 2.576      local stars_c2 = "***"
else if abs(`t_c2') > 1.960 local stars_c2 = "**"
else if abs(`t_c2') > 1.645 local stars_c2 = "*"

local beta_lkl_c2 = _b[lkl1990_post]
local se_lkl_c2   = _se[lkl1990_post]
local beta_lsl_c2 = _b[lsl1990_post]
local se_lsl_c2   = _se[lsl1990_post]

di "  beta(s1999_post)  = " %9.4f `beta_c2' " `stars_c2'"
di "  se(s1999_post)    = " %9.4f `se_c2'

* --- Col 3: + all robustness controls ---
di _n "--- Table 1, Col 3: + all controls ---"
areg lemp s1999_post lkl1990_post lsl1990_post contract_post dr_post ///
     atp_post sfw_mwt_sum_new ntr mem d1991-d2007 [aw=emp1990], a(fam50) cl(fam50) robust

local beta_c3 = _b[s1999_post]
local se_c3   = _se[s1999_post]
local n_c3    = e(N)
local r2_c3   = e(r2)
local t_c3    = `beta_c3' / `se_c3'
local stars_c3 = ""
if abs(`t_c3') > 2.576      local stars_c3 = "***"
else if abs(`t_c3') > 1.960 local stars_c3 = "**"
else if abs(`t_c3') > 1.645 local stars_c3 = "*"

di "  beta(s1999_post)  = " %9.4f `beta_c3' " `stars_c3'"
di "  se(s1999_post)    = " %9.4f `se_c3'

* =============================================================================
* STEP 3: twowayfeweights decomposition
* =============================================================================
di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "  Y = lemp, G = fam50, T = year, D = s1999_post"
di "  weight = emp1990"
di "============================================================"

* --- 3a. feTR ---
di _n "--- feTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights lemp fam50 year s1999_post, type(feTR) weight(emp1990) summary_measures
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
cap noisily twowayfeweights lemp fam50 year s1999_post, type(fdTR) weight(emp1990) summary_measures
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
classify_design fam50 year s1999_post

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

* --- Table 1 replication ---
cap file close texfile
file open texfile using "$texdir/table1_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Pierce and Schott (2016), Table 1}" _n
file write texfile "\label{tab:pierce_schott_t1}" _n
file write texfile "\begin{adjustbox}{max width=\textwidth}" _n
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile " & (1) & (2) & (3) \\" _n
file write texfile " & Log Emp & Log Emp & Log Emp \\" _n
file write texfile "\midrule" _n

* s1999_post row
file write texfile "NTR Gap $\times$ Post"
file write texfile " & " %9.4f (`beta_c1') "`stars_c1'"
file write texfile " & " %9.4f (`beta_c2') "`stars_c2'"
file write texfile " & " %9.4f (`beta_c3') "`stars_c3'"
file write texfile " \\" _n

* SE row
file write texfile " & (" %9.4f (`se_c1') ")"
file write texfile " & (" %9.4f (`se_c2') ")"
file write texfile " & (" %9.4f (`se_c3') ")"
file write texfile " \\" _n

file write texfile "\addlinespace" _n

* Controls indicators
file write texfile "Industry family FE & Yes & Yes & Yes \\" _n
file write texfile "Year dummies & Yes & Yes & Yes \\" _n
file write texfile "Factor intensity controls & No & Yes & Yes \\" _n
file write texfile "Trade/institutional controls & No & No & Yes \\" _n
file write texfile "Weights (emp 1990) & Yes & Yes & Yes \\" _n

file write texfile "\midrule" _n

* N and R2
file write texfile "N & " %9.0fc (`n_c1') " & " %9.0fc (`n_c2') " & " %9.0fc (`n_c3') " \\" _n
file write texfile "$R^2$ & " %6.4f (`r2_c1') " & " %6.4f (`r2_c2') " & " %6.4f (`r2_c3') " \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{4}{p{0.90\linewidth}}{\footnotesize" _n
file write texfile "\textit{Notes:} Replication using NBER-CES public data (original uses restricted Census LBD). " _n
file write texfile "NTR Gap is the difference between non-NTR and NTR tariff rates as of 1999. " _n
file write texfile "Robust standard errors clustered by industry family in parentheses. " _n
file write texfile "*** $p<0.01$, ** $p<0.05$, * $p<0.10$.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{adjustbox}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table1_replication.tex"

* --- twowayfeweights table ---
cap file close texfile
file open texfile using "$texdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition: Pierce and Schott (2016)}" _n
file write texfile "\label{tab:pierce_schott_weights}" _n
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
file write texfile "Spec: industry family FE + year FE. " _n
file write texfile "$Y$ = log employment (NBER-CES). " _n
file write texfile "$D$ = NTR Gap $\times$ Post (continuous). " _n
file write texfile "$G$ = industry family. $T$ = year (1990--2007). " _n
file write texfile "Weighted by 1990 employment.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_twowayfeweights.tex"

* --- Master LaTeX document ---
cap file close texfile
file open texfile using "$texdir/pierce_schott_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage[margin=1in]{geometry}" _n
file write texfile "\usepackage{booktabs,caption,adjustbox,amsmath,amsfonts}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n

file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Pierce and Schott (2016)}\\" _n
file write texfile "{\large The Surprisingly Swift Decline of US Manufacturing Employment}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 106(7), 1632--1662}" _n
file write texfile "\end{center}" _n _n

file write texfile "\vspace{1em}" _n _n

file write texfile "\input{table1_replication}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n

file write texfile "\end{document}" _n

file close texfile
di "  Saved: pierce_schott_tables.tex"

* =============================================================================
* STEP 5: Final summary
* =============================================================================
di _n "============================================================"
di "  FINAL SUMMARY: Pierce and Schott (2016)"
di "============================================================"
di "  Table 1 Replication (NBER-CES data)"
di "------------------------------------------------------------"
di "  Col 1: beta = " %9.4f `beta_c1' " `stars_c1'  (se = " %9.4f `se_c1' ")"
di "  Col 2: beta = " %9.4f `beta_c2' " `stars_c2'  (se = " %9.4f `se_c2' ")"
di "  Col 3: beta = " %9.4f `beta_c3' " `stars_c3'  (se = " %9.4f `se_c3' ")"
di "  N = " `n_c1' " (" `n_groups' " industries x " `n_years' " years)"
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
