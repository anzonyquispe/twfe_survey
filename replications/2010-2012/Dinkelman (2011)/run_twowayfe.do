/*==============================================================================
  DINKELMAN (2011) - "The Effects of Rural Electrification on Employment:
  New Evidence from South Africa"
  American Economic Review, 101(7), 3078-3108

  Pipeline:
    STEP 1: Replicate Table 4 (OLS + IV, female + male employment)
    STEP 2: Reshape to 2-period panel for twowayfeweights
    STEP 3: twowayfeweights decomposition (feTR)
    STEP 4: Export LaTeX tables

  dCDH Web Appendix:
    Table 4 Cols 1, 3. Regression 1 (feTR).
    Cross-sectional first-differences design.

  Data: matched_censusdata.dta, largearea==1 subsample
  Y = d_prop_emp_f (change in female employment rate, 1996-2001)
  D = T (electrification treatment)
  IV = mean_grad_new (terrain gradient)
==============================================================================*/

clear all
set more off
cap log close _all

* --- Paths ---
global datadir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Dinkelman (2011)/20080791_dataset/data"
global outdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dinkelman (2011)"
global texdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex/2010-2012/Dinkelman (2011)"

log using "$outdir/run_twowayfe.log", text replace
set more off

* --- Install packages ---
cap which estout
if _rc ssc install estout, replace
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace


/*==============================================================================
  STEP 1: REPLICATE TABLE 4
==============================================================================*/

di _n "============================================================"
di "  STEP 1: REPLICATE TABLE 4"
di "============================================================"

use "$datadir/matched_censusdata.dta", clear
keep if largearea == 1
di "Sample N = " _N

global x1 "kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0"

* --- Col 1: OLS, no controls ---
di _n "--- Col 1: OLS, no controls ---"
di "  Expected: beta = -0.004, SE = 0.005"
reg d_prop_emp_f T, robust cluster(placecode0)
est store col1
local b_ols1 = _b[T]
local se_ols1 = _se[T]
local n_ols1 = e(N)

estadd local controls "No" : col1
estadd local distfe   "No" : col1
estadd local method   "OLS" : col1

di "  beta = " %8.4f `b_ols1' " SE = " %8.4f `se_ols1'

* --- Col 3: OLS, controls + district FE ---
di _n "--- Col 3: OLS, controls + district FE ---"
di "  Expected: beta = 0.000, SE = 0.005"
xi: reg d_prop_emp_f T $x1 i.dccode0, robust cluster(placecode0)
est store col3
local b_ols3 = _b[T]
local se_ols3 = _se[T]
local n_ols3 = e(N)

estadd local controls "Yes" : col3
estadd local distfe   "Yes" : col3
estadd local method   "OLS" : col3

di "  beta = " %8.4f `b_ols3' " SE = " %8.4f `se_ols3'

* --- Col 5: IV, no controls ---
di _n "--- Col 5: IV, no controls ---"
di "  Expected: beta = 0.025, SE = 0.045"
ivregress 2sls d_prop_emp_f (T = mean_grad_new), robust cluster(placecode0) first
est store col5
local b_iv5 = _b[T]
local se_iv5 = _se[T]
local n_iv5 = e(N)

estadd local controls "No" : col5
estadd local distfe   "No" : col5
estadd local method   "IV" : col5

di "  beta = " %8.4f `b_iv5' " SE = " %8.4f `se_iv5'

* --- Col 7: IV, controls + district FE ---
di _n "--- Col 7: IV, controls + district FE ---"
di "  Expected: beta = 0.090, SE = 0.054"
xi: ivregress 2sls d_prop_emp_f (T = mean_grad_new) $x1 i.dccode0, robust cluster(placecode0) first
est store col7
local b_iv7 = _b[T]
local se_iv7 = _se[T]
local n_iv7 = e(N)

estadd local controls "Yes" : col7
estadd local distfe   "Yes" : col7
estadd local method   "IV" : col7

di "  beta = " %8.4f `b_iv7' " SE = " %8.4f `se_iv7'

* --- Male placebo: OLS+FE ---
di _n "--- Male: OLS+FE ---"
xi: reg d_prop_emp_m T $x1 i.dccode0, robust cluster(placecode0)
local b_ols3m = _b[T]
local se_ols3m = _se[T]

* --- Male placebo: IV+FE ---
di _n "--- Male: IV+FE ---"
xi: ivregress 2sls d_prop_emp_m (T = mean_grad_new) $x1 i.dccode0, robust cluster(placecode0)
local b_iv7m = _b[T]
local se_iv7m = _se[T]

di _n "  VERIFICATION Table 4:"
di "  Col 1 (OLS):     " %8.4f `b_ols1'  " (" %6.4f `se_ols1' ")"
di "  Col 3 (OLS+FE):  " %8.4f `b_ols3'  " (" %6.4f `se_ols3' ")"
di "  Col 5 (IV):      " %8.4f `b_iv5'   " (" %6.4f `se_iv5'  ")"
di "  Col 7 (IV+FE):   " %8.4f `b_iv7'   " (" %6.4f `se_iv7'  ")"
di "  Male OLS+FE:     " %8.4f `b_ols3m'  " (" %6.4f `se_ols3m' ")"
di "  Male IV+FE:      " %8.4f `b_iv7m'   " (" %6.4f `se_iv7m'  ")"


/*==============================================================================
  STEP 2: RESHAPE TO 2-PERIOD PANEL
==============================================================================*/

di _n "============================================================"
di "  STEP 2: RESHAPING TO 2-PERIOD PANEL"
di "============================================================"

use "$datadir/matched_censusdata.dta", clear
keep if largearea == 1
keep placecode0 dccode0 T mean_grad_new prop_emp_f0 prop_emp_f1 prop_emp_m0 prop_emp_m1 $x1

gen comm_id = _n
scalar N_comm = _N

expand 2
sort comm_id
by comm_id: gen year = cond(_n == 1, 1996, 2001)

gen prop_emp_f = cond(year == 1996, prop_emp_f0, prop_emp_f1)
gen prop_emp_m = cond(year == 1996, prop_emp_m0, prop_emp_m1)
gen D = cond(year == 2001, T, 0)

xtset comm_id year, delta(5)
di "Panel: " _N " obs = " scalar(N_comm) " communities x 2 periods"

* --- Levels TWFE regression ---
di _n "--- TWFE levels regression ---"
reg prop_emp_f D i.comm_id i.year, cluster(placecode0)
local twfe_beta = _b[D]
local twfe_se   = _se[D]
di "TWFE beta = " %8.4f `twfe_beta'
di "TWFE se   = " %8.4f `twfe_se'
di "  (should match Col 1 OLS: " %8.4f `b_ols1' ")"


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION
==============================================================================*/

di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "============================================================"

* Initialize locals
local tw_beta1  = .
local tw_npos1  = .
local tw_nneg1  = .
local tw_pneg1  = "N/A"
local tw_beta2  = .
local tw_npos2  = .
local tw_nneg2  = .
local tw_pneg2  = "N/A"

* --- feTR: Female employment ---
di _n "--- feTR: Female Employment ---"
cap noisily twowayfeweights prop_emp_f comm_id year D, type(feTR)
local tw_rc1 = _rc
if `tw_rc1' == 0 | `tw_rc1' == 402 {
    local tw_beta1  = e(beta)
    mat _M1 = e(M)
    local tw_npos1  = _M1[1,1]
    local tw_nneg1  = _M1[2,1]
    local tw_ntot1  = `tw_npos1' + `tw_nneg1'
    local tw_pneg1 : di %5.1f (100 * `tw_nneg1' / `tw_ntot1')
    di _n "  Beta TWFE     = " `tw_beta1'
    di "  # pos weights = " `tw_npos1'
    di "  # neg weights = " `tw_nneg1'
    di "  % neg weights = " `tw_pneg1' "%"
}
else {
    di as error "  twowayfeweights (female) FAILED with rc = " `tw_rc1'
    di "  Using manual fallback..."

    * Manual feTR: w_gt = (D_it - D_bar_i) / sum((D_it - D_bar_i)^2)
    bysort comm_id: egen D_bar_g = mean(D)
    gen D_demean = D - D_bar_g
    gen D_demean2 = D_demean^2
    qui summ D_demean2
    local denom = r(sum)
    gen w_gt = D_demean / `denom'

    qui xtreg prop_emp_f D, fe
    local tw_beta1 = _b[D]

    qui count if w_gt > 0 & w_gt < .
    local tw_npos1 = r(N)
    qui count if w_gt < 0
    local tw_nneg1 = r(N)
    local tw_ntot1 = `tw_npos1' + `tw_nneg1'
    if `tw_ntot1' > 0 {
        local tw_pneg1 : di %5.1f (100 * `tw_nneg1' / `tw_ntot1')
    }

    di "  Beta TWFE (manual) = " %10.6f `tw_beta1'
    di "  # pos weights      = " `tw_npos1'
    di "  # neg weights      = " `tw_nneg1'
    di "  % neg weights      = " `tw_pneg1' "%"
    drop D_bar_g D_demean D_demean2 w_gt
}

* --- feTR: Male employment ---
di _n "--- feTR: Male Employment ---"
cap noisily twowayfeweights prop_emp_m comm_id year D, type(feTR)
local tw_rc2 = _rc
if `tw_rc2' == 0 | `tw_rc2' == 402 {
    local tw_beta2  = e(beta)
    mat _M2 = e(M)
    local tw_npos2  = _M2[1,1]
    local tw_nneg2  = _M2[2,1]
    local tw_ntot2  = `tw_npos2' + `tw_nneg2'
    local tw_pneg2 : di %5.1f (100 * `tw_nneg2' / `tw_ntot2')
    di _n "  Beta TWFE     = " `tw_beta2'
    di "  # pos weights = " `tw_npos2'
    di "  # neg weights = " `tw_nneg2'
    di "  % neg weights = " `tw_pneg2' "%"
}
else {
    di as error "  twowayfeweights (male) FAILED with rc = " `tw_rc2'
    di "  Using manual fallback..."

    bysort comm_id: egen D_bar_g = mean(D)
    gen D_demean = D - D_bar_g
    gen D_demean2 = D_demean^2
    qui summ D_demean2
    local denom = r(sum)
    gen w_gt = D_demean / `denom'

    qui xtreg prop_emp_m D, fe
    local tw_beta2 = _b[D]

    qui count if w_gt > 0 & w_gt < .
    local tw_npos2 = r(N)
    qui count if w_gt < 0
    local tw_nneg2 = r(N)
    local tw_ntot2 = `tw_npos2' + `tw_nneg2'
    if `tw_ntot2' > 0 {
        local tw_pneg2 : di %5.1f (100 * `tw_nneg2' / `tw_ntot2')
    }

    di "  Beta TWFE (manual) = " %10.6f `tw_beta2'
    di "  # pos weights      = " `tw_npos2'
    di "  # neg weights      = " `tw_nneg2'
    di "  % neg weights      = " `tw_pneg2' "%"
    drop D_bar_g D_demean D_demean2 w_gt
}


/*==============================================================================
  STEP 4: SUMMARY
==============================================================================*/

di _n "============================================================"
di "  SUMMARY"
di "============================================================"
di "Table 4 replication:"
di "  Female OLS (no ctrl): beta = " %7.4f `b_ols1' " (" %7.4f `se_ols1' ")"
di "  Female OLS+FE:        beta = " %7.4f `b_ols3' " (" %7.4f `se_ols3' ")"
di "  Female IV (no ctrl):  beta = " %7.4f `b_iv5'  " (" %7.4f `se_iv5'  ")"
di "  Female IV+FE:         beta = " %7.4f `b_iv7'  " (" %7.4f `se_iv7'  ")"
di ""
di "twowayfeweights (female): rc = " `tw_rc1'
di "  beta = " `tw_beta1' ", # pos = " `tw_npos1' ", # neg = " `tw_nneg1' ", % neg = " `tw_pneg1' "%"
di "twowayfeweights (male): rc = " `tw_rc2'
di "  beta = " `tw_beta2' ", # pos = " `tw_npos2' ", # neg = " `tw_nneg2' ", % neg = " `tw_pneg2' "%"


/*==============================================================================
  STEP 5: EXPORT LATEX TABLES
==============================================================================*/

di _n "============================================================"
di "  STEP 5: LaTeX EXPORT"
di "============================================================"

cap mkdir "$texdir"

* ===================================================================
* TABLE A: Table 4 replication (Cols 1, 3, 5, 7)
* ===================================================================

esttab col1 col3 col5 col7 using "$outdir/table4_replication.tex", replace ///
    keep(T) ///
    cells(b(star fmt(4)) se(par fmt(4))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(N controls distfe method, ///
        fmt(0) ///
        labels("Observations" "Controls" "District FE" "Method")) ///
    title("Table 4---Effects of Electrification on Female Employment (Dinkelman, 2011)") ///
    mtitles("(1)" "(3)" "(5)" "(7)") ///
    varlabels(T "Electrification (T)") ///
    note("Dependent variable: change in female employment rate (1996--2001). " ///
         "Sample: 1{,}816 communities (largearea==1). " ///
         "Instrument for IV: mean terrain gradient (mean\_grad\_new). " ///
         "Standard errors clustered by place in parentheses. " ///
         "*** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1.") ///
    booktabs nonumbers

di "  -> table4_replication.tex created"
cap copy "$outdir/table4_replication.tex" "$texdir/table4_replication.tex", replace

* ===================================================================
* TABLE B: twowayfeweights summary
* ===================================================================

* Format numbers
local tw_beta1_s : di %10.6f `tw_beta1'
local tw_beta1_s = strtrim("`tw_beta1_s'")
local tw_npos1_s : di %4.0f `tw_npos1'
local tw_npos1_s = strtrim("`tw_npos1_s'")
local tw_nneg1_s : di %4.0f `tw_nneg1'
local tw_nneg1_s = strtrim("`tw_nneg1_s'")

if "`tw_pneg1'" == "" local tw_pneg1 = "N/A"

local tw_beta2_s : di %10.6f `tw_beta2'
local tw_beta2_s = strtrim("`tw_beta2_s'")
local tw_npos2_s : di %4.0f `tw_npos2'
local tw_npos2_s = strtrim("`tw_npos2_s'")
local tw_nneg2_s : di %4.0f `tw_nneg2'
local tw_nneg2_s = strtrim("`tw_nneg2_s'")

if "`tw_pneg2'" == "" local tw_pneg2 = "N/A"

cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:dinkelman_twfe}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & Female & Male \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel A: Specification}} \\[3pt]" _n
file write texfile "Regression type & \multicolumn{2}{c}{Fixed Effects (feTR)} \\" _n
file write texfile "Dependent variable & Employment rate (F) & Employment rate (M) \\" _n
file write texfile "Treatment variable & \multicolumn{2}{c}{Electrification (T)} \\" _n
file write texfile "Panel & \multicolumn{2}{c}{1{,}816 communities $\times$ 2 periods} \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel B: Weight Decomposition}} \\[3pt]" _n
file write texfile "$\hat{\beta}_{TWFE}$ & `tw_beta1_s' & `tw_beta2_s' \\" _n
file write texfile "\# positive weights & `tw_npos1_s' & `tw_npos2_s' \\" _n
file write texfile "\# negative weights & `tw_nneg1_s' & `tw_nneg2_s' \\" _n
file write texfile "\% negative weights & `tw_pneg1'\% & `tw_pneg2'\% \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.92\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Panel B reports the weight decomposition of the TWFE estimator " _n
file write texfile "following de Chaisemartin \& D'Haultf\oe uille (2020). " _n
file write texfile "The original paper uses cross-sectional first differences; we reshape " _n
file write texfile "the data to a 2-period panel (1996, 2001) for the decomposition. " _n
file write texfile "With two periods and a binary treatment, the TWFE estimator mechanically " _n
file write texfile "assigns negative weights to the pre-treatment period observations." _n
file write texfile "\end{minipage}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"
cap copy "$outdir/table_twowayfeweights.tex" "$texdir/table_twowayfeweights.tex", replace

* ===================================================================
* MASTER DOCUMENT
* ===================================================================

cap file close fulltex
file open fulltex using "$outdir/dinkelman_tables.tex", write replace

file write fulltex "\documentclass[12pt]{article}" _n
file write fulltex "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write fulltex "\geometry{margin=1in}" _n
file write fulltex "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write fulltex "\begin{document}" _n _n

file write fulltex "\begin{center}" _n
file write fulltex "{\Large\bfseries Dinkelman (2011)}\\" _n
file write fulltex "{\large The Effects of Rural Electrification on Employment:}\\" _n
file write fulltex "{\large New Evidence from South Africa}\\" _n
file write fulltex "\vspace{0.5em}" _n
file write fulltex "{\normalsize \textit{American Economic Review}, 101(7), 3078--3108}" _n
file write fulltex "\end{center}" _n _n
file write fulltex "\vspace{1em}" _n _n

file write fulltex "\section*{1. Table 4 Replication}" _n _n
file write fulltex "We replicate columns 1, 3, 5, and 7 of Table 4 from the original paper. " _n
file write fulltex "The dependent variable is the change in female employment rate between " _n
file write fulltex "the 1996 and 2001 South African Censuses for 1{,}816 communities. " _n
file write fulltex "The treatment variable is electrification, instrumented by mean terrain " _n
file write fulltex "gradient in the IV specifications." _n _n

file write fulltex "\input{table4_replication}" _n _n
file write fulltex "\clearpage" _n _n

file write fulltex "\section*{2. Two-Way FE Weights Analysis}" _n _n
file write fulltex "We reshape the cross-sectional data into a 2-period panel " _n
file write fulltex "(1996, 2001) and apply the decomposition of de Chaisemartin " _n
file write fulltex "\& D'Haultf\oe uille (2020) to the TWFE estimator." _n _n

file write fulltex "\input{table_twowayfeweights}" _n _n

file write fulltex "\end{document}" _n

file close fulltex
di "  -> dinkelman_tables.tex created"
cap copy "$outdir/dinkelman_tables.tex" "$texdir/dinkelman_tables.tex", replace


di _n "============================================================"
di "  ALL DONE - Dinkelman (2011)"
di "============================================================"
di "Output files:"
di "  1. $outdir/table4_replication.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/dinkelman_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "============================================================"

log close
