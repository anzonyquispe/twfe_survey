/*==============================================================================
  BURGESS, JEDWAB, MIGUEL, MORJARIA & PADRÓ I MIQUEL (2015)
  "The Value of Democracy: Evidence from Road Building in Kenya"
  American Economic Review, 105(6), 1817-1851

  Pipeline:
    STEP 1: Data exploration & verification
    STEP 2: Replicate Table 1 Col 1 (baseline TWFE)
    STEP 3: twowayfeweights decomposition (feTR + fdTR)
    STEP 4: Export LaTeX tables

  dCDH REStat Web Appendix:
    Not binary and/or not staggered design. No dynamic effects.
    Treatment: president (coethnic of president indicator)
    Panel: ~41 districts x ~49 years (1963-2011)
    Y = exp_dens_share (road expenditure density share)
    D = president (president's coethnic dummy, non-binary/time-varying)
    G = distnum (district identifier)
    T = year
==============================================================================*/

clear all
set more off
cap log close _all

* --- Paths ---
global datadir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Burgess et al. (2015)/AER_2013_1031_replication/main-tables-figures"
global outdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Burgess et al. (2015)"
global texdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex/2015-2019/Burgess et al. (2015)"

cap mkdir "$texdir"

cap log using "$outdir/run_twowayfe.log", text replace name(detail)

* --- Install packages ---
cap which estout
if _rc ssc install estout, replace
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace


/*==============================================================================
  STEP 1: DATA EXPLORATION
==============================================================================*/

di _n "============================================================"
di "  STEP 1: DATA EXPLORATION"
di "============================================================"

use "$datadir/kenya_roads_exp", clear

di _n "--- Dataset dimensions ---"
di "Observations: " _N
desc, short

di _n "--- Panel structure ---"
qui tab distnum
di "Districts (G): " r(r)
qui tab year
di "Years (T): " r(r)

di _n "--- Treatment variable: president ---"
tab president, missing
summarize president, detail

di _n "--- Outcome variable: exp_dens_share ---"
summarize exp_dens_share, detail

di _n "--- Year range ---"
summarize year, detail

di _n "--- Treatment variation over time ---"
* Check how treatment varies across districts and years
preserve
collapse (mean) president, by(distnum)
summarize president
di _n "  Mean president share across districts: " %6.4f r(mean)
di "  SD: " %6.4f r(sd)
di "  Min: " r(min) " Max: " r(max)
restore

di _n "--- Treatment changes over time ---"
preserve
collapse (mean) president, by(year)
di "  Treatment mean by year (first and last 5):"
list year president in 1/5
di "..."
local N = _N
list year president in `=`N'-4'/`N'
restore

di _n "--- Key control variables ---"
cap summarize presidentMP multiparty pop1962_t area_t urbrate1962_t, detail

di _n "--- multiparty indicator ---"
tab multiparty year if year >= 1990 & year <= 1995


/*==============================================================================
  STEP 2: REPLICATE TABLE 1 — Baseline TWFE
  Table 1 Col (1) Panel A: areg exp_dens_share president i.year, absorb(distnum)
  Table 1 Col (1) Panel B: areg exp_dens_share president presidentMP multiparty i.year, absorb(distnum)
==============================================================================*/

di _n "============================================================"
di "  STEP 2: REPLICATE TABLE 1"
di "============================================================"

* === Column (1) Panel A: No interaction ===
di _n "--- Table 1, Column 1, Panel A (baseline TWFE) ---"
xi: areg exp_dens_share president i.year, absorb(distnum) robust cluster(distnum)
est store t1c1a
local b_pres_a = _b[president]
local se_pres_a = _se[president]
local N_a = e(N)
local r2_a = e(r2_a)

di _n "  COEFF president (Panel A): " %8.4f `b_pres_a' " (" %6.4f `se_pres_a' ")"
di "  N = " `N_a' ", adj R2 = " %6.4f `r2_a'

* === Column (1) Panel B: With interaction ===
di _n "--- Table 1, Column 1, Panel B (interaction with multiparty) ---"
xi: areg exp_dens_share president presidentMP multiparty i.year, absorb(distnum) robust cluster(distnum)
est store t1c1b
local b_pres_b = _b[president]
local se_pres_b = _se[president]
local b_presMP = _b[presidentMP]
local se_presMP = _se[presidentMP]
local N_b = e(N)
local r2_b = e(r2_a)

di _n "  COEFF president (Panel B): " %8.4f `b_pres_b' " (" %6.4f `se_pres_b' ")"
di "  COEFF presidentMP: " %8.4f `b_presMP' " (" %6.4f `se_presMP' ")"
di "  N = " `N_b' ", adj R2 = " %6.4f `r2_b'

* Test president + presidentMP = 0
test president + presidentMP = 0
local p_sum = r(p)
di "  p-value (president + presidentMP = 0): " %6.4f `p_sum'

* === Column (4) Panel A: Full controls ===
di _n "--- Table 1, Column 4, Panel A (full controls) ---"
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t ///
    wage_employment_t value_cashcrops_t i.MomKam|year i.border|year ///
    dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
est store t1c4a
local b_pres_c4a = _b[president]
local se_pres_c4a = _se[president]

di _n "  COEFF president (Col 4, Panel A): " %8.4f `b_pres_c4a' " (" %6.4f `se_pres_c4a' ")"

* === Column (4) Panel B: Full controls + interaction ===
di _n "--- Table 1, Column 4, Panel B (full controls + interaction) ---"
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t ///
    urbrate1962_t earnings_t wage_employment_t value_cashcrops_t ///
    i.MomKam|year i.border|year dist2nairobi_t i.year, ///
    absorb(distnum) robust cluster(distnum)
est store t1c4b
local b_pres_c4b = _b[president]
local se_pres_c4b = _se[president]
local b_presMP_c4 = _b[presidentMP]
local se_presMP_c4 = _se[presidentMP]

di _n "  COEFF president (Col 4, Panel B): " %8.4f `b_pres_c4b' " (" %6.4f `se_pres_c4b' ")"
di "  COEFF presidentMP (Col 4): " %8.4f `b_presMP_c4' " (" %6.4f `se_presMP_c4' ")"

test president + presidentMP = 0
local p_sum_c4 = r(p)

di _n "  ==============================="
di "  VERIFICATION Table 1:"
di "  Col 1 Panel A: president = " %8.4f `b_pres_a' " (" %6.4f `se_pres_a' ")"
di "  Col 1 Panel B: president = " %8.4f `b_pres_b' " (" %6.4f `se_pres_b' ")"
di "                 presidentMP = " %8.4f `b_presMP' " (" %6.4f `se_presMP' ")"
di "  Col 4 Panel A: president = " %8.4f `b_pres_c4a' " (" %6.4f `se_pres_c4a' ")"
di "  Col 4 Panel B: president = " %8.4f `b_pres_c4b' " (" %6.4f `se_pres_c4b' ")"
di "                 presidentMP = " %8.4f `b_presMP_c4' " (" %6.4f `se_presMP_c4' ")"
di "  ==============================="


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  For twowayfeweights:
  Y = exp_dens_share, G = distnum, T = year, D = president
  president is non-binary (it varies by district and changes over time
  as different presidents from different ethnic groups take power)

  We use feTR since this is a FE regression (areg with absorb).
==============================================================================*/

di _n "============================================================"
di "  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION"
di "============================================================"

* Data is already at district-year level, no need to collapse
di "  Data at district x year level: " _N " obs"
qui tab distnum
di "  Districts (G): " r(r)
qui tab year
di "  Years (T): " r(r)

di _n "  Treatment distribution:"
tab president, missing

* Initialize locals
local tw_beta_fe  = .
local tw_npos_fe  = .
local tw_nneg_fe  = .
local tw_pct_fe   = "0.0"

* --- feTR ---
di _n "============================================================"
di "  feTR (Fixed Effects — Regression 1)"
di "============================================================"
cap noisily twowayfeweights exp_dens_share distnum year president, type(feTR) summary_measures
local tw_rc_fe = _rc

if `tw_rc_fe' == 0 | `tw_rc_fe' == 402 {
    local tw_beta_fe  = e(beta)
    mat _M = e(M)
    local tw_npos_fe  = _M[1,1]
    local tw_nneg_fe  = _M[2,1]
    local tw_sumpos   : di %8.4f _M[1,2]
    local tw_sumneg   : di %8.4f _M[2,2]

    di _n "  feTR results:"
    di "  beta     = " %10.6f `tw_beta_fe'
    di "  pos wgts = " `tw_npos_fe' " (sum = `tw_sumpos')"
    di "  neg wgts = " `tw_nneg_fe' " (sum = `tw_sumneg')"
    if `tw_npos_fe' + `tw_nneg_fe' > 0 {
        local tw_pct_fe : di %5.1f 100*`tw_nneg_fe'/(`tw_npos_fe'+`tw_nneg_fe')
        di "  % neg    = `tw_pct_fe'%"
    }
}
else {
    di as error "  feTR failed with rc=`tw_rc_fe'. Using manual fallback."

    * Manual feTR decomposition
    qui reg exp_dens_share president i.distnum i.year
    local tw_beta_fe = _b[president]

    * Compute weights manually via FE residual
    qui reg president i.distnum i.year
    predict eps_D, residual

    gen w_gt = eps_D

    qui count if w_gt > 1e-10 & !missing(w_gt)
    local tw_npos_fe = r(N)
    qui count if w_gt < -1e-10 & !missing(w_gt)
    local tw_nneg_fe = r(N)

    if `tw_npos_fe' + `tw_nneg_fe' > 0 {
        local tw_pct_fe : di %5.1f 100*`tw_nneg_fe'/(`tw_npos_fe'+`tw_nneg_fe')
    }
    else {
        local tw_pct_fe = "0.0"
    }

    di "  beta_fe      = " %10.6f `tw_beta_fe'
    di "  Positive wgts: `tw_npos_fe'"
    di "  Negative wgts: `tw_nneg_fe'"
    di "  % negative   = `tw_pct_fe'%"

    drop eps_D w_gt
}

* --- fdTR ---
di _n "============================================================"
di "  fdTR (First Differences — Regression 2)"
di "============================================================"
cap noisily twowayfeweights exp_dens_share distnum year president, type(fdTR) summary_measures
local tw_rc_fd = _rc

local tw_beta_fd = .
local tw_npos_fd = .
local tw_nneg_fd = .
local tw_pct_fd = "n/a"

if `tw_rc_fd' == 0 | `tw_rc_fd' == 402 {
    local tw_beta_fd  = e(beta)
    mat _Mfd = e(M)
    local tw_npos_fd  = _Mfd[1,1]
    local tw_nneg_fd  = _Mfd[2,1]
    di _n "  fdTR results:"
    di "  beta     = " %10.6f `tw_beta_fd'
    di "  pos wgts = " `tw_npos_fd'
    di "  neg wgts = " `tw_nneg_fd'
    if `tw_npos_fd' + `tw_nneg_fd' > 0 {
        local tw_pct_fd : di %5.1f 100*`tw_nneg_fd'/(`tw_npos_fd'+`tw_nneg_fd')
        di "  % neg    = `tw_pct_fd'%"
    }
}
else {
    di as error "  fdTR failed with rc=`tw_rc_fd'"
}


/*==============================================================================
  STEP 4: SUMMARY
==============================================================================*/

di _n "============================================================"
di "  SUMMARY"
di "============================================================"
di "  # pos weights (feTR) = " `tw_npos_fe'
di "  # neg weights (feTR) = " `tw_nneg_fe'
di "  % neg weights (feTR) = `tw_pct_fe'%"
di "  beta (feTR)          = " %10.6f `tw_beta_fe'
if `tw_beta_fd' != . {
    di "  beta (fdTR)          = " %10.6f `tw_beta_fd'
    di "  # pos weights (fdTR) = " `tw_npos_fd'
    di "  # neg weights (fdTR) = " `tw_nneg_fd'
    di "  % neg weights (fdTR) = `tw_pct_fd'%"
}


/*==============================================================================
  STEP 5: EXPORT LATEX TABLES
==============================================================================*/

di _n "============================================================"
di "  STEP 5: LaTeX EXPORT"
di "============================================================"

* ===================================================================
* TABLE A: Table 1 replication (key coefficients)
* ===================================================================

local b_pres_a_s : di %8.2f `b_pres_a'
local se_pres_a_s : di %8.2f `se_pres_a'
local b_pres_b_s : di %8.2f `b_pres_b'
local se_pres_b_s : di %8.2f `se_pres_b'
local b_presMP_s : di %8.2f `b_presMP'
local se_presMP_s : di %8.2f `se_presMP'
local b_pres_c4a_s : di %8.2f `b_pres_c4a'
local se_pres_c4a_s : di %8.2f `se_pres_c4a'
local b_pres_c4b_s : di %8.2f `b_pres_c4b'
local se_pres_c4b_s : di %8.2f `se_pres_c4b'
local b_presMP_c4_s : di %8.2f `b_presMP_c4'
local se_presMP_c4_s : di %8.2f `se_presMP_c4'
local N_a_s : di %8.0fc `N_a'
local r2_a_s : di %5.2f `r2_a'

cap file close texfile
file open texfile using "$outdir/table1_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Table 1---Road Expenditure, Ethnicity and Democratic Change (Burgess et al., 2015)}" _n
file write texfile "\label{tab:burgess_table1}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & Column (1) & Column (4) \\" _n
file write texfile " & Baseline & Full controls \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel A: No interaction}} \\[3pt]" _n
file write texfile "President's coethnic & `b_pres_a_s' & `b_pres_c4a_s' \\" _n
file write texfile " & [`se_pres_a_s'] & [`se_pres_c4a_s'] \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel B: Interaction with multiparty era}} \\[3pt]" _n
file write texfile "President's coethnic & `b_pres_b_s' & `b_pres_c4b_s' \\" _n
file write texfile " & [`se_pres_b_s'] & [`se_pres_c4b_s'] \\" _n
file write texfile "President $\times$ Multiparty & `b_presMP_s' & `b_presMP_c4_s' \\" _n
file write texfile " & [`se_presMP_s'] & [`se_presMP_c4_s'] \\[6pt]" _n
file write texfile "\midrule" _n
file write texfile "District FE & \multicolumn{2}{c}{Yes} \\" _n
file write texfile "Year FE & \multicolumn{2}{c}{Yes} \\" _n
file write texfile "Observations & \multicolumn{2}{c}{`N_a_s'} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.85\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Dependent variable: road expenditure density share. " _n
file write texfile "``President's coethnic'' is a dummy equal to one if a district's " _n
file write texfile "plurality ethnic group is the same as the president's ethnic group. " _n
file write texfile "Column (4) adds controls interacted with time trends " _n
file write texfile "(population, area, urbanization rate, earnings, employment, cash crops, " _n
file write texfile "main highway, border, distance to Nairobi). " _n
file write texfile "Robust standard errors clustered at the district level in brackets." _n
file write texfile "\end{minipage}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table1_replication.tex created"

* ===================================================================
* TABLE B: twowayfeweights summary
* ===================================================================

local tw_beta_fe_s : di %10.6f `tw_beta_fe'
local tw_beta_fe_s = strtrim("`tw_beta_fe_s'")
local tw_npos_fe_s : di %4.0f `tw_npos_fe'
local tw_npos_fe_s = strtrim("`tw_npos_fe_s'")
local tw_nneg_fe_s : di %4.0f `tw_nneg_fe'
local tw_nneg_fe_s = strtrim("`tw_nneg_fe_s'")

if "`tw_pct_fe'" == "" local tw_pct_fe = "0.0"

if `tw_beta_fd' != . {
    local tw_beta_fd_s : di %10.6f `tw_beta_fd'
    local tw_beta_fd_s = strtrim("`tw_beta_fd_s'")
    local tw_npos_fd_s : di %4.0f `tw_npos_fd'
    local tw_npos_fd_s = strtrim("`tw_npos_fd_s'")
    local tw_nneg_fd_s : di %4.0f `tw_nneg_fd'
    local tw_nneg_fd_s = strtrim("`tw_nneg_fd_s'")
    if "`tw_pct_fd'" == "" local tw_pct_fd = "n/a"
}
else {
    local tw_beta_fd_s = "---"
    local tw_npos_fd_s = "---"
    local tw_nneg_fd_s = "---"
    local tw_pct_fd    = "---"
}

cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:burgess_twfe}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & FE (feTR) & FD (fdTR) \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel A: Specification}} \\[3pt]" _n
file write texfile "Regression type & Fixed Effects & First Differences \\" _n
file write texfile "Dependent variable & \multicolumn{2}{c}{Road expenditure density share} \\" _n
file write texfile "Treatment variable & \multicolumn{2}{c}{President's coethnic (non-binary)} \\" _n
file write texfile "Panel & \multicolumn{2}{c}{Districts $\times$ years (1963--2011)} \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel B: Weight Decomposition}} \\[3pt]" _n
file write texfile "$\hat{\beta}_{TWFE}$ & `tw_beta_fe_s' & `tw_beta_fd_s' \\" _n
file write texfile "\# positive weights & `tw_npos_fe_s' & `tw_npos_fd_s' \\" _n
file write texfile "\# negative weights & `tw_nneg_fe_s' & `tw_nneg_fd_s' \\" _n
file write texfile "\% negative weights & `tw_pct_fe'\% & `tw_pct_fd'\% \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel C: Classification (dCDH Web Appendix)}} \\[3pt]" _n
file write texfile "Design & \multicolumn{2}{c}{Not binary and/or not staggered} \\" _n
file write texfile "Dynamic effects & \multicolumn{2}{c}{No} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.92\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Panel B reports the weight decomposition of the TWFE estimator " _n
file write texfile "following de Chaisemartin \& D'Haultf\oe uille (2020). " _n
file write texfile "The treatment variable is a dummy equal to one if a district's plurality " _n
file write texfile "ethnic group matches the president's ethnic group. Treatment varies as " _n
file write texfile "different presidents from different ethnic groups take power. " _n
file write texfile "Negative weights indicate that the TWFE coefficient may not recover " _n
file write texfile "a convex combination of causal effects under heterogeneous treatment effects." _n
file write texfile "\end{minipage}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ===================================================================
* MASTER DOCUMENT
* ===================================================================

cap file close fulltex
file open fulltex using "$outdir/burgess_tables.tex", write replace

file write fulltex "\documentclass[12pt]{article}" _n
file write fulltex "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write fulltex "\geometry{margin=1in}" _n
file write fulltex "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write fulltex "\begin{document}" _n _n

file write fulltex "\begin{center}" _n
file write fulltex "{\Large\bfseries Burgess, Jedwab, Miguel, Morjaria \& Padr\'o i Miquel (2015)}\\" _n
file write fulltex "{\large The Value of Democracy: Evidence from}\\" _n
file write fulltex "{\large Road Building in Kenya}\\" _n
file write fulltex "\vspace{0.5em}" _n
file write fulltex "{\normalsize \textit{American Economic Review}, 105(6), 1817--1851}" _n
file write fulltex "\end{center}" _n _n
file write fulltex "\vspace{1em}" _n _n

file write fulltex "\section*{1. Table 1 Replication}" _n _n
file write fulltex "We replicate the main results from Table 1, which estimates the effect " _n
file write fulltex "of being the president's coethnic on a district's share of road " _n
file write fulltex "development expenditure in Kenya (1963--2011). " _n
file write fulltex "The regression includes district fixed effects and year fixed effects, " _n
file write fulltex "with standard errors clustered at the district level. " _n
file write fulltex "Panel B adds an interaction between the president's coethnic " _n
file write fulltex "indicator and the multiparty era (post-1992)." _n _n

file write fulltex "\input{table1_replication}" _n _n
file write fulltex "\clearpage" _n _n

file write fulltex "\section*{2. Two-Way FE Weights Analysis}" _n _n
file write fulltex "We apply the decomposition of de Chaisemartin \& D'Haultf\oe uille (2020) " _n
file write fulltex "to the president's coethnic treatment variable. The treatment is non-binary " _n
file write fulltex "(it switches on and off as different presidents take office) and varies " _n
file write fulltex "across 41 districts over 49 years." _n _n

file write fulltex "\input{table_twowayfeweights}" _n _n

file write fulltex "\end{document}" _n

file close fulltex
di "  -> burgess_tables.tex created"

* Copy files to texdir
cap copy "$outdir/table1_replication.tex" "$texdir/table1_replication.tex", replace
cap copy "$outdir/table_twowayfeweights.tex" "$texdir/table_twowayfeweights.tex", replace
cap copy "$outdir/burgess_tables.tex" "$texdir/burgess_tables.tex", replace


di _n "============================================================"
di "  ALL DONE - Burgess et al. (2015)"
di "============================================================"
di "Output files:"
di "  1. $outdir/table1_replication.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/burgess_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "============================================================"

cap log close detail
