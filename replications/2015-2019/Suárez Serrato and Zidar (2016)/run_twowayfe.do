/*=============================================================================
  TWFE Weight Decomposition: Suárez Serrato and Zidar (2016)
  "Who Benefits from State Corporate Tax Cuts? A Local Labor Markets
   Approach with Heterogeneous Firms"
  AER 106(9), 2582-2624

  Main TWFE spec: Table 4, Panel A, Column 1
  xi: reg E d_keeprate i.year i.fe_group [aw=epop], cluster(fips_state) r

  Treatment: d_keeprate (change in log net-of-business-tax rate, continuous)
  Unit FE: fe_group (state groupings)
  Time FE: year (decadal periods)
  Outcome: E (employment changes)
  Weights: epop (employment population)
  Clustering: fips_state
=============================================================================*/

clear all
set more off
cap log close _all

* ─── STEP 1: Load data ───────────────────────────────────────────────────────
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Suárez Serrato and Zidar (2016)/AER-2014-1702_Replication_Files/Final-Tables-and-Figures/dta/Tables"

use "$datadir/Table4.dta", clear

di _n "============================================================"
di "  STEP 1: DATA EXPLORATION"
di "============================================================"
di "Observations: " _N
desc, short
desc

* Panel structure
di _n "--- Panel dimensions ---"
qui tab fe_group
local n_groups = r(r)
di "Groups (fe_group): " `n_groups'
qui tab year
local n_years = r(r)
di "Years:             " `n_years'
tab year

* Check treatment variable
di _n "--- Treatment: d_keeprate ---"
sum d_keeprate, detail
* Check if binary or continuous
qui count if d_keeprate == 0 | d_keeprate == 1
qui count
local pct_binary = .
cap {
    qui count if inlist(d_keeprate, 0, 1)
    local n_binary = r(N)
    qui count if !missing(d_keeprate)
    local n_nonmiss = r(N)
    local pct_binary = 100 * `n_binary' / `n_nonmiss'
}
di "  % obs that are 0 or 1: " %5.1f `pct_binary' "% (continuous if low)"

* Outcomes
di _n "--- Outcomes ---"
sum E N W R, detail

* Weights
di _n "--- Weights: epop ---"
sum epop, detail

* State clustering variable
di _n "--- Clustering: fips_state ---"
qui tab fips_state
di "States: " r(r)

* ─── STEP 2: Replicate Table 4, Panel A, Column 1 ────────────────────────────
di _n "============================================================"
di "  STEP 2: TABLE 4A, COLUMN 1 REPLICATION"
di "  xi: reg E d_keeprate i.year i.fe_group [aw=epop], cluster(fips_state) r"
di "============================================================"

xi: reg E d_keeprate i.year i.fe_group [aw=epop], cluster(fips_state) r

local beta_t4c1 = _b[d_keeprate]
local se_t4c1   = _se[d_keeprate]
local n_t4c1    = e(N)
local r2_t4c1   = e(r2)

di _n "--- Table 4A Col 1 Results ---"
di "  beta(d_keeprate) = " %9.4f `beta_t4c1'
di "  se(d_keeprate)   = " %9.4f `se_t4c1'
di "  N                = " `n_t4c1'
di "  R2               = " %9.4f `r2_t4c1'

* Also replicate Panel B Col 1 (N = population changes)
xi: reg N d_keeprate i.year i.fe_group [aw=epop], cluster(fips_state) r
local beta_N = _b[d_keeprate]
local se_N   = _se[d_keeprate]

* Panel B Col 3 (W = wages)
xi: reg W d_keeprate i.year i.fe_group [aw=epop], cluster(fips_state) r
local beta_W = _b[d_keeprate]
local se_W   = _se[d_keeprate]

* Panel B Col 5 (R = rents)
xi: reg R d_keeprate i.year i.fe_group [aw=epop], cluster(fips_state) r
local beta_R = _b[d_keeprate]
local se_R   = _se[d_keeprate]

di _n "--- All Panel A/B Col 1 (baseline) ---"
di "  E: " %9.2f `beta_t4c1' " (" %9.2f `se_t4c1' ")"
di "  N: " %9.2f `beta_N' " (" %9.2f `se_N' ")"
di "  W: " %9.2f `beta_W' " (" %9.2f `se_W' ")"
di "  R: " %9.2f `beta_R' " (" %9.2f `se_R' ")"

* ─── STEP 3: twowayfeweights decomposition ───────────────────────────────────
di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "  G = fe_group, T = year, D = d_keeprate"
di "============================================================"

* Rename conflicting variables (twowayfeweights uses W internally)
rename W _W_wages
rename N _N_pop
rename R _R_rents
rename L _L_emp

* --- 3a. feTR for E (main outcome) ---
di _n "--- feTR decomposition (Y=E) ---"
* Clear global scalars to prevent stale values from leaking between feTR/fdTR
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights E fe_group year d_keeprate, type(feTR) weight(epop) summary_measures
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
    * Command failed (e.g. negative nat_weight): try global scalars as fallback
    * twowayfeweights computes nplus/nminus/beta BEFORE the sensitivity measure
    * that crashes — these scalars persist after cap noisily
    di "  twowayfeweights returned rc=`twfe_rc', trying fallback scalars..."
    cap local fetr_beta    = scalar(beta)
    cap local fetr_npos    = scalar(nplus)
    cap local fetr_nneg    = scalar(nminus)
    cap local fetr_sumpos  = scalar(sumplus)
    cap local fetr_sumneg  = scalar(summinus)
    if `fetr_npos' != . & `fetr_nneg' != . {
        local fetr_ok = 1
        di "  Fallback OK: captured npos/nneg/beta from global scalars"
        di "  (sensitivity measures unavailable — nat_weight has negative values)"
    }
    else {
        di "  Fallback FAILED: no global scalars available"
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
di _n "--- fdTR decomposition (Y=E) ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights E fe_group year d_keeprate, type(fdTR) weight(epop) summary_measures
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
    di "  twowayfeweights fdTR returned rc=`twfe_rc', trying fallback scalars..."
    cap local fdtr_beta    = scalar(beta)
    cap local fdtr_npos    = scalar(nplus)
    cap local fdtr_nneg    = scalar(nminus)
    cap local fdtr_sumpos  = scalar(sumplus)
    cap local fdtr_sumneg  = scalar(summinus)
    if `fdtr_npos' != . & `fdtr_nneg' != . {
        local fdtr_ok = 1
        di "  Fallback OK: captured npos/nneg/beta from global scalars"
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

local texdir "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Suárez Serrato and Zidar (2016)"

* --- Table replication ---
cap file close texfile
file open texfile using "`texdir'/table4_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Su\'{a}rez Serrato and Zidar (2016), Table 4, Column 1}" _n
file write texfile "\label{tab:ssz_t4c1}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\hline\hline" _n
file write texfile " & E & N & W & R \\" _n
file write texfile "\hline" _n
file write texfile "d\_keeprate & " %9.2f (`beta_t4c1') " & " %9.2f (`beta_N') " & " %9.2f (`beta_W') " & " %9.2f (`beta_R') " \\" _n
file write texfile " & (" %9.2f (`se_t4c1') ") & (" %9.2f (`se_N') ") & (" %9.2f (`se_W') ") & (" %9.2f (`se_R') ") \\" _n
file write texfile "\hline" _n
file write texfile "Group FE & Yes & Yes & Yes & Yes \\" _n
file write texfile "Year FE & Yes & Yes & Yes & Yes \\" _n
file write texfile "Weights & epop & epop & epop & epop \\" _n
file write texfile "Clustering & State & State & State & State \\" _n
file write texfile "N & " %9.0fc (`n_t4c1') " & " %9.0fc (`n_t4c1') " & " %9.0fc (`n_t4c1') " & " %9.0fc (`n_t4c1') " \\" _n
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
file write texfile "\caption{TWFE Weight Decomposition: Su\'{a}rez Serrato and Zidar (2016)}" _n
file write texfile "\label{tab:ssz_weights}" _n
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

* Summary measures (if available)
if `fetr_sens1' != . {
    file write texfile "\multicolumn{3}{l}{\footnotesize min $\sigma(\Delta)$ for $\beta_{fe}$ and $\Delta_{TR}=0$: " %9.4f (`fetr_sens1') "} \\" _n
}
if `fetr_sens2' != . {
    file write texfile "\multicolumn{3}{l}{\footnotesize min $\sigma(\Delta)$ for opposite sign: " %9.4f (`fetr_sens2') "} \\" _n
}
if `fetr_sens1' == . & `fetr_ok' == 1 {
    file write texfile "\multicolumn{3}{l}{\footnotesize Sensitivity measures unavailable (continuous treatment with negative values).} \\" _n
}
file write texfile "\hline" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Spec: \texttt{reg E d\_keeprate i.year i.fe\_group [aw=epop]}} \\" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Panel: state-group $\times$ decade. Treatment: $\Delta\ln$(net-of-tax rate).} \\" _n
file write texfile "\multicolumn{3}{l}{\footnotesize $\hat\beta$ from cell-mean regression (treatment varies within cells). Original $\beta=4.07$.} \\" _n
file write texfile "\multicolumn{3}{l}{\footnotesize fdTR: invalid syntax (requires level treatment variable, only first-difference available).} \\" _n
file write texfile "\hline\hline" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_twowayfeweights.tex"

* --- Master LaTeX document ---
cap file close texfile
file open texfile using "`texdir'/ssz_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage[margin=1in]{geometry}" _n
file write texfile "\usepackage{booktabs,caption}" _n
file write texfile "\begin{document}" _n
file write texfile "\section*{Su\'{a}rez Serrato and Zidar (2016): TWFE Weight Decomposition}" _n
file write texfile "\subsection*{Paper: ``Who Benefits from State Corporate Tax Cuts?'', AER 106(9)}" _n
file write texfile _n
file write texfile "\input{table4_replication}" _n
file write texfile _n
file write texfile "\input{table_twowayfeweights}" _n
file write texfile _n
file write texfile "\end{document}" _n

file close texfile
di "  Saved: ssz_tables.tex"

* ─── STEP 5: Summary ─────────────────────────────────────────────────────────
di _n "============================================================"
di "  FINAL SUMMARY: Suárez Serrato and Zidar (2016)"
di "============================================================"
di "  Table 4A, Column 1"
di "  Spec: reg E d_keeprate i.year i.fe_group [aw=epop], cl(fips_state)"
di "  beta(d_keeprate)  = " %9.4f `beta_t4c1'
di "  se(d_keeprate)    = " %9.4f `se_t4c1'
di "  N                 = " `n_t4c1'
di "  Panel: " `n_groups' " groups x " `n_years' " year-periods"
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
