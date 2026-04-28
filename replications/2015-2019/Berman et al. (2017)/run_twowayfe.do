/*=============================================================================
  TWFE Weight Decomposition: Berman et al. (2017)
  "This Mine is Mine! How Minerals Fuel Conflicts in Africa"
  AER 107(6), 1564-1610

  Main TWFE spec: Table 2, Column 2
  reg2hdfe acled main_lprice_mines, id1(cell) id2(it) [if sd_mines==0]
  Equivalent: reghdfe acled main_lprice_mines if sd_mines==0, absorb(cell it)

  Treatment: main_lprice_mines (continuous: log world price x mine indicator)
  Unit FE: cell (0.5 x 0.5 degree grid cell)
  Time FE: it (country x year)
  Outcome: acled (conflict indicator)
  Sample: cells with mine open entire period (sd_mines == 0)
  SE: Spatial HAC (Conley) — replicated here with cluster(cell) for comparison
=============================================================================*/

clear all
set more off
cap log close _all
set matsize 10000

* --- STEP 1: Load and prepare data ---
di _n "============================================================"
di "  STEP 1: DATA PREPARATION"
di "============================================================"

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Berman et al. (2017)/20150774_data"

use "$datadir/Data/BCRT_baseline.dta", clear

di "Raw obs: " _N

* Drop diamonds and tantalum (as in baseline Table 2)
drop if mainmineral == "diamond" | mainmineral == "tantalum"
di "After dropping diamond/tantalum: " _N

* Restrict to cells with mine open entire period (Col 2 condition)
keep if sd_mines == 0
di "After sd_mines == 0: " _N

* Check key variables
di _n "--- Key variables ---"
cap ds cell it year acled main_lprice_mines sd_mines
if _rc == 0 di "All key variables found"
else {
    di "MISSING variables. Available:"
    ds *cell* *it* *year* *acled* *lprice* *mines*
}

* Panel structure
qui tab cell
local n_cells = r(r)
qui tab it
local n_it = r(r)
qui tab year
local n_years = r(r)
di "Cells: " `n_cells'
di "Country-years (it): " `n_it'
di "Years: " `n_years'

di _n "--- Treatment: main_lprice_mines ---"
sum main_lprice_mines, detail

di _n "--- Outcome: acled ---"
sum acled, detail

* --- STEP 2: Replicate Table 2, Col 2 ---
di _n "============================================================"
di "  STEP 2: TABLE 2, COL 2 REPLICATION"
di "  reghdfe acled main_lprice_mines, absorb(cell it) vce(cl cell)"
di "============================================================"

reghdfe acled main_lprice_mines, absorb(cell it) vce(cluster cell)

local beta_t2c2 = _b[main_lprice_mines]
local se_t2c2   = _se[main_lprice_mines]
local n_t2c2    = e(N)
local r2_t2c2   = e(r2)

di _n "--- Table 2 Col 2 Results ---"
di "  beta(main_lprice_mines) = " %12.6f `beta_t2c2'
di "  se(main_lprice_mines)   = " %12.6f `se_t2c2'
di "  N                       = " `n_t2c2'
di "  NOTE: SEs differ from paper (cluster vs spatial HAC)"

* --- STEP 3: twowayfeweights ---
di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "  G = cell, T = it, D = main_lprice_mines"
di "============================================================"

* --- 3a. feTR ---
di _n "--- feTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights acled cell it main_lprice_mines, type(feTR) summary_measures
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
    if `fetr_sens1' != . di "  min sigma(D) for zero:  " %9.4f `fetr_sens1'
    if `fetr_sens2' != . di "  min sigma(D) for opp:   " %9.4f `fetr_sens2'
}
else {
    di "feTR FAILED completely with rc=`twfe_rc'"
}

* --- 3b. fdTR ---
di _n "--- fdTR decomposition ---"
cap scalar drop nplus nminus beta sumplus summinus
cap noisily twowayfeweights acled cell it main_lprice_mines, type(fdTR) summary_measures
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

* --- STEP 4: LaTeX output ---
di _n "============================================================"
di "  STEP 4: LaTeX OUTPUT"
di "============================================================"

local texdir "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Berman et al. (2017)"

* --- Table replication ---
cap file close texfile
file open texfile using "`texdir'/table2_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Berman et al.\ (2017), Table 2, Column 2}" _n
file write texfile "\label{tab:berman_t2c2}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\hline\hline" _n
file write texfile " & Conflict (ACLED) \\" _n
file write texfile "\hline" _n
file write texfile "Log price $\times$ mines & " %12.6f (`beta_t2c2') " \\" _n
file write texfile " & (" %12.6f (`se_t2c2') ") \\" _n
file write texfile "\hline" _n
file write texfile "Cell FE & Yes \\" _n
file write texfile "Country $\times$ Year FE & Yes \\" _n
file write texfile "SE & Cluster (cell) \\" _n
file write texfile "N & " %9.0fc (`n_t2c2') " \\" _n
file write texfile "\hline\hline" _n
file write texfile "\multicolumn{2}{l}{\footnotesize Note: Paper uses Conley spatial HAC SEs.} \\" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table2_replication.tex"

* --- twowayfeweights table ---
cap file close texfile
file open texfile using "`texdir'/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition: Berman et al.\ (2017)}" _n
file write texfile "\label{tab:berman_weights}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\hline\hline" _n
file write texfile " & feTR & fdTR \\" _n
file write texfile "\hline" _n

* beta
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
file write texfile "\multicolumn{3}{l}{\footnotesize Spec: cell FE + country$\times$year FE. Treatment: log(price)$\times$mines (continuous).} \\" _n
file write texfile "\multicolumn{3}{l}{\footnotesize Sample: cells with mine open entire period ($sd\_mines = 0$).} \\" _n
file write texfile "\hline\hline" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  Saved: table_twowayfeweights.tex"

* --- Master LaTeX ---
cap file close texfile
file open texfile using "`texdir'/berman_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage[margin=1in]{geometry}" _n
file write texfile "\usepackage{booktabs,caption,amsfonts}" _n
file write texfile "\begin{document}" _n
file write texfile "\section*{Berman et al.\ (2017): TWFE Weight Decomposition}" _n
file write texfile "\subsection*{Paper: ``This Mine is Mine!'', AER 107(6)}" _n
file write texfile _n
file write texfile "\input{table2_replication}" _n
file write texfile _n
file write texfile "\input{table_twowayfeweights}" _n
file write texfile _n
file write texfile "\end{document}" _n

file close texfile
di "  Saved: berman_tables.tex"

* --- STEP 5: Summary ---
di _n "============================================================"
di "  FINAL SUMMARY: Berman et al. (2017)"
di "============================================================"
di "  Table 2, Col 2"
di "  Spec: reghdfe acled main_lprice_mines if sd_mines==0, absorb(cell it)"
di "  beta(main_lprice_mines) = " %12.6f `beta_t2c2'
di "  se(main_lprice_mines)   = " %12.6f `se_t2c2'
di "  N                       = " `n_t2c2'
di "  Panel: " `n_cells' " cells x " `n_it' " country-years (" `n_years' " years)"
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
