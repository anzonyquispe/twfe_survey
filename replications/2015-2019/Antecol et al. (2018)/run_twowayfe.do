/*==============================================================================
  ANTECOL, BEDARD & STEARNS (2018) - "Equal but Inequitable: Who Benefits
  from Gender-Neutral Tenure Clock Stopping Policies?"
  American Economic Review, 108(9), 2420-2441

  Pipeline:
    STEP 1: Data exploration & verification
    STEP 2: Replicate Table 2 main regression
    STEP 3: Replicate Table 4 Col 5 (no female interactions = clean TWFE)
    STEP 4: twowayfeweights decomposition (feTR)
    STEP 5: Export LaTeX tables

  dCDH REStat Web Appendix:
    Binary, staggered design. Estimates dynamic effects.
    Treatment: gender-neutral clock stopping policy (gncs), binary
    Panel: ~50 universities x ~25 cohort years (individuals nested within)
    Y = tenure_policy_school (binary: tenure at policy university)
    D = gncs (binary: gender-neutral clock stopping policy in place)
    G = pol_u (university identifier)
    T = pol_job_start (year hired at policy university)
==============================================================================*/

clear all
set more off
cap log close _all

* --- Paths ---
global datadir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Antecol et al. (2018)/data"
global outdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Antecol et al. (2018)"
global texdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex/2015-2019/Antecol et al. (2018)"

cap log using "$outdir/run_twowayfe_detail.log", text replace name(detail)

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

use "$datadir/aer_primarysample.dta", clear

di _n "--- Dataset dimensions ---"
di "Observations: " _N
desc, short

di _n "--- Panel structure ---"
qui tab pol_u
di "Universities (G): " r(r)
qui tab pol_job_start
di "Job start years (T): " r(r)

di _n "--- Treatment variables ---"
tab gncs, missing
tab focs, missing
tab gncs focs, missing

di _n "--- Treatment timing (gncs adoption) ---"
* How many university-year cells
preserve
collapse (mean) gncs focs tenure_policy_school, by(pol_u pol_job_start)
di "University x Year cells: " _N
qui tab pol_u
di "Universities: " r(r)
qui tab pol_job_start
di "Year cohorts: " r(r)
tab gncs, missing
tab focs, missing
restore

di _n "--- Outcome variable ---"
summarize tenure_policy_school, detail

di _n "--- Key control variables ---"
summarize female phd_rank post_doc, detail

di _n "--- Gender distribution ---"
tab female


/*==============================================================================
  STEP 2: REPLICATE TABLE 2 — Main Results
  Specification: reg tenure ~ policy_vars controls i.year*i.female i.univ*i.female
  This is the full interacted specification (separate FE by gender)
==============================================================================*/

di _n "============================================================"
di "  STEP 2: REPLICATE TABLE 2"
di "============================================================"

local ulist phd_rank phd_rank_miss post_doc ug_students grad_students ///
    faculty full_av_salary assist_av_salary revenue female_ratio ///
    full_ratio faculty_miss revenue_miss female_ratio_miss full_ratio_miss
local plist focs f_focs gncs f_gncs focs0 f_focs0 gncs0 f_gncs0

xi: reg tenure_policy_school `plist' `ulist' ///
    i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)

est store table2

* Report key coefficients (as in paper's Table 2)
di _n "  TABLE 2 KEY COEFFICIENTS (lincom):"

di _n "  GNCS effect on MEN (4+ years):"
lincom gncs
local gncs_men_b = r(estimate)
local gncs_men_se = r(se)

di _n "  GNCS effect on WOMEN (4+ years):"
lincom gncs + f_gncs
local gncs_women_b = r(estimate)
local gncs_women_se = r(se)

di _n "  FOCS effect on MEN (4+ years):"
lincom focs
local focs_men_b = r(estimate)
local focs_men_se = r(se)

di _n "  FOCS effect on WOMEN (4+ years):"
lincom focs + f_focs
local focs_women_b = r(estimate)
local focs_women_se = r(se)

di _n "  Gender difference in GNCS effect (male - female):"
lincom -f_gncs

di _n "  ==============================="
di "  VERIFICATION Table 2:"
di "  GNCS men:   " %8.4f `gncs_men_b' " (" %6.4f `gncs_men_se' ")"
di "  GNCS women: " %8.4f `gncs_women_b' " (" %6.4f `gncs_women_se' ")"
di "  FOCS men:   " %8.4f `focs_men_b' " (" %6.4f `focs_men_se' ")"
di "  FOCS women: " %8.4f `focs_women_b' " (" %6.4f `focs_women_se' ")"
di "  N = " e(N) ", R2 = " %6.4f e(r2)
di "  ==============================="


/*==============================================================================
  STEP 3: REPLICATE TABLE 4 COL 5 — Clean TWFE (no female interactions)
  This is the specification suitable for twowayfeweights:
  reg tenure ~ gncs focs gncs0 focs0 f_gncs f_focs f_gncs0 f_focs0
               controls female i.pol_job_start i.pol_u
  = standard TWFE with university FE + year FE
==============================================================================*/

di _n "============================================================"
di "  STEP 3: TABLE 4 COL 5 (Clean TWFE)"
di "============================================================"

xi: reg tenure_policy_school `plist' `ulist' female ///
    i.pol_job_start i.pol_u, cluster(pol_u)

est store table4c5

di _n "  TABLE 4 COL 5 KEY COEFFICIENTS:"
di "  Raw gncs coefficient: " %8.4f _b[gncs] " (" %6.4f _se[gncs] ")"
di "  Raw focs coefficient: " %8.4f _b[focs] " (" %6.4f _se[focs] ")"
di "  N = " e(N) ", R2 = " %6.4f e(r2)

lincom gncs
lincom gncs + f_gncs
lincom focs
lincom focs + f_focs

di _n "  Table 4 Col 5 GNCS on men: " %8.4f _b[gncs] " (" %6.4f _se[gncs] ")"
di "  Table 4 Col 5 GNCS on women: "
lincom gncs + f_gncs


/*==============================================================================
  STEP 4: TWOWAYFEWEIGHTS DECOMPOSITION

  For twowayfeweights, we need: Y, G, T, D at the G*T level.
  D = gncs is binary and varies at university x year level.
  We collapse to university-year level for the decomposition.

  We use feTR since this is a FE regression (Regression 1 in dCDH).
==============================================================================*/

di _n "============================================================"
di "  STEP 4: TWOWAYFEWEIGHTS DECOMPOSITION"
di "============================================================"

* Collapse to university-year level for clean twowayfeweights
preserve
collapse (mean) tenure_policy_school gncs focs female, by(pol_u pol_job_start)

di "  Collapsed to G x T cells: " _N " obs"
qui tab pol_u
di "  Universities (G): " r(r)
qui tab pol_job_start
di "  Years (T): " r(r)

di _n "  Treatment distribution at G x T level:"
tab gncs, missing

* Initialize locals
local tw_beta_fe  = .
local tw_npos_fe  = .
local tw_nneg_fe  = .
local tw_pct_fe   = "0.0"

* --- feTR ---
di _n "============================================================"
di "  feTR (Fixed Effects — Regression 1)"
di "============================================================"
cap noisily twowayfeweights tenure_policy_school pol_u pol_job_start gncs, type(feTR) summary_measures
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

    * Manual feTR decomposition (dCDH Theorem 1)
    * For binary treatment, weight = (D_gt - D_bar_g) / sum((D_gt - D_bar_g)^2)
    * but this is for the simple regression Y ~ D + G_fe + T_fe

    qui reg tenure_policy_school gncs i.pol_u i.pol_job_start
    local tw_beta_fe = _b[gncs]

    * Compute weights manually
    bysort pol_u: egen D_bar_g = mean(gncs)
    bysort pol_job_start: egen D_bar_t = mean(gncs)
    qui summ gncs
    local D_bar = r(mean)

    * FE residual of D on G and T dummies
    qui reg gncs i.pol_u i.pol_job_start
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

    drop D_bar_g D_bar_t eps_D w_gt
}

* --- fdTR ---
di _n "============================================================"
di "  fdTR (First Differences — Regression 2)"
di "============================================================"
cap noisily twowayfeweights tenure_policy_school pol_u pol_job_start gncs, type(fdTR) summary_measures
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

restore


/*==============================================================================
  STEP 5: SUMMARY
==============================================================================*/

di _n "============================================================"
di "  SUMMARY"
di "============================================================"
di "  # pos weights = " `tw_npos_fe'
di "  # neg weights = " `tw_nneg_fe'
di "  % neg weights = `tw_pct_fe'%"
di "  beta (feTR)   = " %10.6f `tw_beta_fe'


/*==============================================================================
  STEP 6: EXPORT LATEX TABLES
==============================================================================*/

di _n "============================================================"
di "  STEP 6: LaTeX EXPORT"
di "============================================================"

* ===================================================================
* TABLE A: Table 2 replication (key coefficients)
* ===================================================================

* Store key results for LaTeX
local gncs_men_b_s : di %8.4f `gncs_men_b'
local gncs_men_se_s : di %8.4f `gncs_men_se'
local gncs_women_b_s : di %8.4f `gncs_women_b'
local gncs_women_se_s : di %8.4f `gncs_women_se'
local focs_men_b_s : di %8.4f `focs_men_b'
local focs_men_se_s : di %8.4f `focs_men_se'
local focs_women_b_s : di %8.4f `focs_women_b'
local focs_women_se_s : di %8.4f `focs_women_se'

cap file close texfile
file open texfile using "$outdir/table2_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Table 2---Main Results (Antecol, Bedard \& Stearns, 2018)}" _n
file write texfile "\label{tab:antecol_table2}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & Men & Women \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{l}{\textit{Policy Effects (4+ Years After Adoption)}} \\[3pt]" _n
file write texfile "GNCS & `gncs_men_b_s' & `gncs_women_b_s' \\" _n
file write texfile " & (`gncs_men_se_s') & (`gncs_women_se_s') \\" _n
file write texfile "FOCS & `focs_men_b_s' & `focs_women_b_s' \\" _n
file write texfile " & (`focs_men_se_s') & (`focs_women_se_s') \\[6pt]" _n
file write texfile "\midrule" _n
file write texfile "University FE $\times$ Female & \multicolumn{2}{c}{Yes} \\" _n
file write texfile "Year FE $\times$ Female & \multicolumn{2}{c}{Yes} \\" _n
file write texfile "Controls & \multicolumn{2}{c}{Yes} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.85\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Dependent variable: indicator for tenure at the policy university. " _n
file write texfile "GNCS = gender-neutral clock stopping policy. FOCS = female-only clock stopping policy. " _n
file write texfile "Coefficients are linear combinations of regression parameters. " _n
file write texfile "Standard errors clustered by university in parentheses." _n
file write texfile "\end{minipage}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table2_replication.tex created"

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
file write texfile "\label{tab:antecol_twfe}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & FE (feTR) & FD (fdTR) \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel A: Specification}} \\[3pt]" _n
file write texfile "Regression type & Fixed Effects & First Differences \\" _n
file write texfile "Dependent variable & \multicolumn{2}{c}{Tenure at policy university} \\" _n
file write texfile "Treatment variable & \multicolumn{2}{c}{GNCS policy (binary)} \\" _n
file write texfile "Panel & \multicolumn{2}{c}{Universities $\times$ cohort years} \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel B: Weight Decomposition}} \\[3pt]" _n
file write texfile "$\hat{\beta}_{TWFE}$ & `tw_beta_fe_s' & `tw_beta_fd_s' \\" _n
file write texfile "\# positive weights & `tw_npos_fe_s' & `tw_npos_fd_s' \\" _n
file write texfile "\# negative weights & `tw_nneg_fe_s' & `tw_nneg_fd_s' \\" _n
file write texfile "\% negative weights & `tw_pct_fe'\% & `tw_pct_fd'\% \\[6pt]" _n
file write texfile "\multicolumn{3}{l}{\textit{Panel C: Classification (dCDH Web Appendix)}} \\[3pt]" _n
file write texfile "Design & \multicolumn{2}{c}{Sharp (binary, staggered)} \\" _n
file write texfile "Dynamic effects & \multicolumn{2}{c}{Yes} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.92\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Panel B reports the weight decomposition of the TWFE estimator " _n
file write texfile "following de Chaisemartin \& D'Haultf\oe uille (2020). " _n
file write texfile "The treatment variable is a binary indicator for adoption of a gender-neutral " _n
file write texfile "clock stopping policy (GNCS). Data collapsed to university $\times$ year cells " _n
file write texfile "for the decomposition. " _n
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
file open fulltex using "$outdir/antecol_tables.tex", write replace

file write fulltex "\documentclass[12pt]{article}" _n
file write fulltex "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write fulltex "\geometry{margin=1in}" _n
file write fulltex "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write fulltex "\begin{document}" _n _n

file write fulltex "\begin{center}" _n
file write fulltex "{\Large\bfseries Antecol, Bedard \& Stearns (2018)}\\" _n
file write fulltex "{\large Equal but Inequitable: Who Benefits from}\\" _n
file write fulltex "{\large Gender-Neutral Tenure Clock Stopping Policies?}\\" _n
file write fulltex "\vspace{0.5em}" _n
file write fulltex "{\normalsize \textit{American Economic Review}, 108(9), 2420--2441}" _n
file write fulltex "\end{center}" _n _n
file write fulltex "\vspace{1em}" _n _n

file write fulltex "\section*{1. Table 2 Replication}" _n _n
file write fulltex "We replicate the main results from Table 2, which estimates the effect " _n
file write fulltex "of gender-neutral (GNCS) and female-only (FOCS) tenure clock stopping " _n
file write fulltex "policies on the probability of receiving tenure at the policy university. " _n
file write fulltex "The regression includes university fixed effects interacted with gender " _n
file write fulltex "and cohort year fixed effects interacted with gender, with standard errors " _n
file write fulltex "clustered at the university level." _n _n

file write fulltex "\input{table2_replication}" _n _n
file write fulltex "\clearpage" _n _n

file write fulltex "\section*{2. Two-Way FE Weights Analysis}" _n _n
file write fulltex "We apply the decomposition of de Chaisemartin \& D'Haultf\oe uille (2020) " _n
file write fulltex "to the GNCS treatment variable. The treatment is binary (policy adopted or not) " _n
file write fulltex "and staggered (universities adopt at different times). " _n
file write fulltex "Data is collapsed to university $\times$ cohort year cells for the decomposition." _n _n

file write fulltex "\input{table_twowayfeweights}" _n _n

file write fulltex "\end{document}" _n

file close fulltex
di "  -> antecol_tables.tex created"

* Copy files to texdir
cap copy "$outdir/table2_replication.tex" "$texdir/table2_replication.tex", replace
cap copy "$outdir/table_twowayfeweights.tex" "$texdir/table_twowayfeweights.tex", replace
cap copy "$outdir/antecol_tables.tex" "$texdir/antecol_tables.tex", replace


di _n "============================================================"
di "  ALL DONE - Antecol et al. (2018)"
di "============================================================"
di "Output files:"
di "  1. $outdir/table2_replication.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/antecol_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "============================================================"

cap log close detail
