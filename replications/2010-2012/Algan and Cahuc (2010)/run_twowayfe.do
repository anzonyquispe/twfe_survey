/*==============================================================================
  ALGAN & CAHUC (2010) - "Inherited Trust and Growth"
  AER, 100(5), 2060-2092

  Pipeline completo:
    STEP 1: Replicar Figure 4 (FD regression: change_gdpk ~ change_trust)
    STEP 2: Replicar Table VI Col 1 (Within FE: gdpk ~ trustgss + country FE)
    STEP 3: twowayfeweights decomposition
    STEP 4: Export LaTeX tables con estout

  Web appendix dCDH (2020):
    "Figure 4 presents a regression of changes in income per capita from
     1935 to 2000 on changes in inherited trust over the same period and
     a constant. This regression corresponds to Regression 2."
    => fdTR for twowayfeweights

  Panel: 24 countries x 2 periods (1935, 2000)
  Y = gdpk_diffswd_good (GDP per capita relative to Sweden)
  D = trustgss (inherited trust from GSS)
==============================================================================*/

clear all
set more off
cap log close _all

* --- Paths ---
global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Algan and Cahuc (2010)"
global outdir   "C:/Users/Usuario/Documents/GitHub/papers_economic/Algan and Cahuc (2010)"

log using "$outdir/run_twowayfe.log", text replace

* --- Force install packages ---
cap ado uninstall estout
ssc install estout, replace

cap ado uninstall twowayfeweights
ssc install twowayfeweights, replace
which twowayfeweights

/*==============================================================================
  STEP 1: REPLICATE FIGURE 4
  README_PROGRAM.do line 376:
    reg change_gdpk change_trust if period==2000 & Nsample1935==0
  Paper: coef ~ 32,238, R² = 0.43, N = 24
==============================================================================*/

use "$paperdir/AER_MACRO.dta", clear

* Keep 1935-2000 sample
keep if period19352000 == 1

di _n "============================================================"
di "  STEP 1: REPLICATE FIGURE 4"
di "============================================================"
tab cty period
summarize trustgss gdpk_diffswd_good

* Generate first-differences (matching README lines 370-375)
sort cty period
gen gdpk_lag1     = gdpk_diffswd_good[_n-1] if cty==cty[_n-1]
gen trustgss_lag1 = trustgss[_n-1]           if cty==cty[_n-1]
gen change_trust  = trustgss - trustgss_lag1           if period==2000
gen change_gdpk   = gdpk_diffswd_good - gdpk_lag1     if period==2000

* Show data for figure
list cty change_trust change_gdpk if period==2000, clean noobs

* --- Figure 4 regression ---
di _n "============================================================"
di "  FIGURE 4: reg change_gdpk change_trust"
di "  Expected: coef = 32,238 | R2 = 0.43 | N = 24"
di "============================================================"

reg change_gdpk change_trust if period==2000 & Nsample1935==0
est store fig4

* Add extra stats for LaTeX
estadd local period "1935--2000" : fig4
estadd local countries "24" : fig4
estadd local spec "First Differences" : fig4

* Verify match
di _n "  VERIFICATION:"
di "  Coef:  " %12.1f _b[change_trust]   "  (paper: 32,238)"
di "  R2:    " %12.4f e(r2)              "  (paper: 0.43)"
di "  N:     " e(N)                       "  (paper: 24)"

* --- Generate scatter plot (Figure 4) ---
twoway (scatter change_gdpk change_trust if Nsample1935==0 & period==2000, ///
        mlabel(cty) mlabsize(vsmall) msize(small) mcolor(navy)) ///
       (lfit change_gdpk change_trust if Nsample1935==0 & period==2000, ///
        lcolor(cranberry) lwidth(medium)), ///
    ytitle("Change in Income relative to Sweden: 2000-1935", size(small)) ///
    xtitle("Change in Inherited Trust: 2000-1935", size(small)) ///
    title("Figure 4: Algan & Cahuc (2010)", size(medium)) ///
    note("R{superscript:2} = 0.43, N = 24") ///
    legend(off) scheme(s2color)
graph export "$outdir/figure4.png", replace width(1400) height(1000)


/*==============================================================================
  STEP 2: REPLICATE TABLE VI (Within-country FE)
  README_PROGRAM.do lines 361-365
==============================================================================*/

di _n "============================================================"
di "  STEP 2: TABLE VI (Within-country FE)"
di "============================================================"

encode cty, gen(cty_num)

* Table VI Col 1: FE with noconstant (exact README)
xi: reg gdpk_diffswd_good trustgss i.cty_num if period19352000==1, noconstant
est store tab6_col1
estadd local ctyfe "Yes" : tab6_col1
estadd local period "1935--2000" : tab6_col1

* Table VI Col 2: FE + lagged income
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 i.cty_num if period19352000==1, noconstant
est store tab6_col2
estadd local ctyfe "Yes" : tab6_col2
estadd local period "1935--2000" : tab6_col2

* Table VI Col 4: FE + lagged income + polity
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 polity2diff i.cty_num if period19352000==1, noconstant
est store tab6_col4
estadd local ctyfe "Yes" : tab6_col4
estadd local period "1935--2000" : tab6_col4

di _n "  TABLE VI SUMMARY:"
est restore tab6_col1
di "  Col 1 (trust only):     " %10.1f _b[trustgss]
est restore tab6_col2
di "  Col 2 (+ lagged GDP):   " %10.1f _b[trustgss]
est restore tab6_col4
di "  Col 4 (+ polity):       " %10.1f _b[trustgss]


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION
  dCDH: "This regression corresponds to Regression 2" => fdTR
  But we also run feTR for the TWFE (Table VI) interpretation
==============================================================================*/

di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS"
di "============================================================"

* Create clean integer period
gen period_num = 1 if period == 1935
replace period_num = 2 if period == 2000

di _n "--- Variable check ---"
tab period_num
summarize cty_num period_num trustgss gdpk_diffswd_good

* --- fdTR (First Difference = Figure 4's Regression 2) ---
* NOTE: fdTR requires T>=3 (needs variation across differenced periods).
* With T=2, there is only ONE first-difference per group => no weight variation.
* twowayfeweights returns "invalid syntax" (rc=198) with T=2 for fdTR.
* We still attempt it but expect failure.
di _n "============================================================"
di "  fdTR (Regression 2 = Figure 4)"
di "  NOTE: T=2 panel — fdTR not applicable (requires T>=3)"
di "============================================================"
cap noisily twowayfeweights gdpk_diffswd_good cty_num period_num trustgss, type(fdTR)
if _rc == 0 | _rc == 402 {
    local tw_beta_fd   = e(beta)
    local tw_npos_fd   = e(num_pos_weights)
    local tw_nneg_fd   = e(num_neg_weights)
    di "  fdTR succeeded: beta=`tw_beta_fd', pos=`tw_npos_fd', neg=`tw_nneg_fd'"
}
else {
    di "  fdTR not available with T=2 (rc=" _rc "). Using feTR only."
    local tw_beta_fd   = .
    local tw_npos_fd   = .
    local tw_nneg_fd   = .
}

di _n "============================================================"
di "  fdTR with summary_measures"
di "============================================================"
cap noisily twowayfeweights gdpk_diffswd_good cty_num period_num trustgss, type(fdTR) summary_measures

* --- feTR (Fixed Effects = Table VI's Regression 1) ---
di _n "============================================================"
di "  feTR (Regression 1 = Table VI)"
di "============================================================"
cap noisily twowayfeweights gdpk_diffswd_good cty_num period_num trustgss, type(feTR)
if _rc == 0 | _rc == 402 {
    * rc=402 means negative weights found — results ARE stored, capture them
    local tw_beta_fe   = e(beta)
    local tw_npos_fe   = e(num_pos_weights)
    local tw_nneg_fe   = e(num_neg_weights)
    di "  feTR succeeded (rc=" _rc "): beta=`tw_beta_fe', pos=`tw_npos_fe', neg=`tw_nneg_fe'"
}
else {
    di as error "  feTR failed with rc = " _rc
    local tw_beta_fe   = .
    local tw_npos_fe   = .
    local tw_nneg_fe   = .
}

di _n "============================================================"
di "  feTR with summary_measures"
di "============================================================"
cap noisily twowayfeweights gdpk_diffswd_good cty_num period_num trustgss, type(feTR) summary_measures

* --- Manual feTR decomposition (twowayfeweights fails with T=2) ---
* Following dCDH (2020): w_{g,t} = (D_{g,t} - D_bar_g) / Σ (D_{g,t} - D_bar_g)^2
if `tw_npos_fe' == . {
    di _n "============================================================"
    di "  MANUAL feTR weight decomposition (T=2 fallback)"
    di "============================================================"

    * Compute demeaned treatment
    bysort cty_num: egen D_bar_g = mean(trustgss)
    gen D_demean = trustgss - D_bar_g
    gen D_demean2 = D_demean^2
    qui summ D_demean2
    local denom = r(sum)
    gen w_gt = D_demean / `denom'

    * Beta_fe from within regression
    qui reg gdpk_diffswd_good trustgss i.cty_num
    local tw_beta_fe = _b[trustgss]

    * Count positive/negative weights
    qui count if w_gt > 0 & w_gt < .
    local tw_npos_fe = r(N)
    qui count if w_gt < 0
    local tw_nneg_fe = r(N)

    * Sum of weights
    qui summ w_gt if w_gt > 0
    local sumpos : di %6.4f r(sum)
    qui summ w_gt if w_gt < 0
    local sumneg : di %6.4f r(sum)
    local sumtot : di %6.4f `sumpos' + `sumneg'

    di "  β_fe = " %10.1f `tw_beta_fe'
    di "  Positive weights: `tw_npos_fe' (Σ = `sumpos')"
    di "  Negative weights: `tw_nneg_fe' (Σ = `sumneg')"
    di "  Total weights:    " `tw_npos_fe' + `tw_nneg_fe' " (Σ = `sumtot')"

    drop D_bar_g D_demean D_demean2 w_gt
}


/*==============================================================================
  STEP 4: EXPORT LATEX TABLES
==============================================================================*/

di _n "============================================================"
di "  STEP 4: LATEX EXPORT"
di "============================================================"

* ---------------------------------------------------------------
* TABLE A: Figure 4 replication (First Difference regression)
* ---------------------------------------------------------------

esttab fig4 using "$outdir/table_figure4.tex", replace ///
    cells(b(star fmt(1)) se(par fmt(1))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(r2 N period countries spec, ///
        fmt(3 0) ///
        labels("R-squared" "Observations" "Period" "Countries" "Specification")) ///
    title("Algan \& Cahuc (2010): Figure 4 --- First Difference Regression") ///
    mtitles("\$\Delta\$ GDP p.c.") ///
    varlabels(change_trust "\$\Delta\$ Inherited Trust" _cons "Constant") ///
    note("Dependent variable: Change in income per capita relative to Sweden (2000--1935)." ///
         " Standard errors in parentheses." ///
         " *** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1") ///
    booktabs nonumbers

di "  -> table_figure4.tex created"

* ---------------------------------------------------------------
* TABLE B: Table VI replication (Within-country FE)
* ---------------------------------------------------------------

esttab tab6_col1 tab6_col2 tab6_col4 using "$outdir/table_tableVI.tex", replace ///
    keep(trustgss gdpk_diffswd_good_1 polity2diff) ///
    cells(b(star fmt(1)) se(par fmt(1))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(r2 N ctyfe period, ///
        fmt(3 0) ///
        labels("R-squared" "Observations" "Country FE" "Period")) ///
    title("Algan \& Cahuc (2010): Table VI --- Within Estimates") ///
    mtitles("(1)" "(2)" "(4)") ///
    varlabels(trustgss "Inherited Trust" ///
              gdpk_diffswd_good_1 "Lagged GDP p.c." ///
              polity2diff "Political Institutions") ///
    note("Dependent variable: Income per capita relative to Sweden." ///
         " All regressions include country fixed effects (no constant)." ///
         " Panel: 24 countries, 2 periods (1935, 2000)." ///
         " *** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1") ///
    booktabs nonumbers

di "  -> table_tableVI.tex created"

* ---------------------------------------------------------------
* TABLE C: twowayfeweights summary (manual LaTeX)
* ---------------------------------------------------------------

* Get stored stats
est restore fig4
local fig4_b  : di %10.1f _b[change_trust]
local fig4_se : di %10.1f _se[change_trust]
local fig4_r2 : di %5.3f e(r2)
local fig4_N  = e(N)

est restore tab6_col1
local tab6_b  : di %10.1f _b[trustgss]
local tab6_se : di %10.1f _se[trustgss]
local tab6_r2 : di %5.3f e(r2)
local tab6_N  = e(N)

* Format twowayfeweights results
local tw_npos_fd_s : di %3.0f `tw_npos_fd'
local tw_nneg_fd_s : di %3.0f `tw_nneg_fd'
local tw_npos_fe_s : di %3.0f `tw_npos_fe'
local tw_nneg_fe_s : di %3.0f `tw_nneg_fe'

* Compute % negative
if `tw_npos_fd' != . & `tw_nneg_fd' != . {
    local tw_total_fd = `tw_npos_fd' + `tw_nneg_fd'
    if `tw_total_fd' > 0 {
        local tw_pct_neg_fd : di %5.1f 100*`tw_nneg_fd'/`tw_total_fd'
    }
    else {
        local tw_pct_neg_fd = "---"
    }
}
else {
    local tw_pct_neg_fd = "n/a"
}

if `tw_npos_fe' != . & `tw_nneg_fe' != . {
    local tw_total_fe = `tw_npos_fe' + `tw_nneg_fe'
    if `tw_total_fe' > 0 {
        local tw_pct_neg_fe : di %5.1f 100*`tw_nneg_fe'/`tw_total_fe'
    }
    else {
        local tw_pct_neg_fe = "---"
    }
}
else {
    local tw_pct_neg_fe = "n/a"
}

cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Algan \& Cahuc (2010): Two-Way FE Weights Decomposition}" _n
file write texfile "\label{tab:algan_twfe}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & FE (Table VI) & FD (Figure 4) \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel A: Original Regression}} \\[3pt]" _n
file write texfile "Coefficient on Trust &`tab6_b' &`fig4_b' \\" _n
file write texfile " & (`tab6_se') & (`fig4_se') \\" _n
file write texfile "R-squared &`tab6_r2' &`fig4_r2' \\" _n
file write texfile "N & `tab6_N' & `fig4_N' \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel B: dCDH (2020) Decomposition}} \\[3pt]" _n
file write texfile "\# positive weights & `tw_npos_fe_s' & `tw_npos_fd_s' \\" _n
file write texfile "\# negative weights & `tw_nneg_fe_s' & `tw_nneg_fd_s' \\" _n
file write texfile "\% negative weights & `tw_pct_neg_fe'\% & `tw_pct_neg_fd'\% \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel C: Classification (dCDH Web Appendix)}} \\[3pt]" _n
file write texfile "Regression type & Regression 1 & Regression 2 \\" _n
file write texfile "Design & Sharp & Sharp \\" _n
file write texfile "Stable groups & \multicolumn{2}{c}{Satisfied} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.9\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Panel A reports the original paper's regressions. " _n
file write texfile "The FE column corresponds to Table VI Column 1 (levels with country FE). " _n
file write texfile "The FD column corresponds to Figure 4 (first differences 2000--1935). " _n
file write texfile "Panel B reports the two-way FE weights decomposition " _n
file write texfile "(de Chaisemartin \& D'Haultf\oe uille, 2020). " _n
file write texfile "Panel C reports the classification from the dCDH web appendix. " _n
file write texfile "Standard errors in parentheses." _n
file write texfile "\end{minipage}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ---------------------------------------------------------------
* STANDALONE COMPILABLE DOCUMENT
* ---------------------------------------------------------------

cap file close fulltex
file open fulltex using "$outdir/algan_cahuc_tables.tex", write replace

file write fulltex "\documentclass[12pt]{article}" _n
file write fulltex "\usepackage{booktabs}" _n
file write fulltex "\usepackage[margin=1in]{geometry}" _n
file write fulltex "\usepackage{graphicx}" _n
file write fulltex "\begin{document}" _n
file write fulltex _n
file write fulltex "\section*{Algan \& Cahuc (2010): ``Inherited Trust and Growth''}" _n
file write fulltex "\subsection*{AER, 100(5), 2060--2092}" _n
file write fulltex _n
file write fulltex "\begin{figure}[htbp]" _n
file write fulltex "\centering" _n
file write fulltex "\includegraphics[width=0.8\textwidth]{figure4.png}" _n
file write fulltex "\caption{Figure 4: Change in Inherited Trust and Change in Income (2000--1935)}" _n
file write fulltex "\end{figure}" _n
file write fulltex _n
file write fulltex "\input{table_figure4}" _n
file write fulltex "\clearpage" _n
file write fulltex "\input{table_tableVI}" _n
file write fulltex "\clearpage" _n
file write fulltex "\input{table_twowayfeweights}" _n
file write fulltex _n
file write fulltex "\end{document}" _n

file close fulltex
di "  -> algan_cahuc_tables.tex created"


di _n "============================================================"
di "  DONE - Output files:"
di "============================================================"
di "  1. $outdir/figure4.png"
di "  2. $outdir/table_figure4.tex"
di "  3. $outdir/table_tableVI.tex"
di "  4. $outdir/table_twowayfeweights.tex"
di "  5. $outdir/algan_cahuc_tables.tex  (compilable)"
di "  6. $outdir/run_twowayfe.log"
di "============================================================"

log close _all
