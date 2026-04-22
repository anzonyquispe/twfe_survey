/*==============================================================================
  FORMAN, GOLDFARB & GREENSTEIN (2012) - "The Internet and Local Wages:
  A Puzzle"
  American Economic Review, 102(1), 556-575

  Pipeline: STEP 1 Data -> STEP 2 Table 2 OLS -> STEP 3 twowayfeweights -> STEP 4 LaTeX

  dCDH Web Appendix #23: Tables 2 and 4, Regression 2 with controls, fdTR
  "The stable groups assumption is satisfied: there are counties with no
   Internet investment in 2000." Fuzzy design: the treatment of interest is
   whether a business uses Internet, which varies within (county,year) cells.

  Specification (Table 2 Col 2):
    wagediff_i = alpha + beta * surv_deeppost00_i + X'gamma + eps_i
    where wagediff = ln(weekwage_2000) - ln(weekwage_1995)
    This is a cross-sectional first difference (Regression 2)

  For twowayfeweights: construct 2-period panel (1995, 2000)
    Period 1 (1995): D = 0 (no advanced Internet)
    Period 2 (2000): D = surv_deeppost00

  Cross-section: ~2,743 US counties
==============================================================================*/

clear all
set more off
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Forman et al. (2012)"
global datadir  "$paperdir/data_and_programs"
global outdir   "$paperdir"

log using "$outdir/run_twowayfe.log", text replace

* Install packages if needed
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace

* Helper program: significance stars
cap program drop _stars
program define _stars, rclass
    args b se
    local s ""
    if `se' > 0 & `se' < . {
        local t = abs(`b'/`se')
        if `t' > 2.576      local s "***"
        else if `t' > 1.960 local s "**"
        else if `t' > 1.645 local s "*"
    }
    return local s "`s'"
end


/*==============================================================================
  STEP 1: DATA PREPARATION
  Load cross-sectional county growth data (differences 1995-2000).
==============================================================================*/

use "$datadir/countygrowth.dta", clear

* Define control variable globals (following original tables.do)
global controls "lnpop pctblk1990 pctunivp1990 pctHSp1990 pctbelowPL1990 medhhinc1990 carnegie1_enr frac_in_eng_prog npatent1980s frprof pct65p1990 netmig95"
global change "change_totalpop change_pctblk change_pctunivp change_pctHSp change_pct65 change_netmig"

di _n "=== DATA SUMMARY ==="
di "Observations: " _N
desc, short
di ""
di "--- Outcome: wagediff (log wage difference 2000-1995) ---"
summ wagediff
di ""
di "--- Treatment: surv_deeppost00 (fraction firms with advanced Internet) ---"
summ surv_deeppost00, detail
di ""
di "--- Counties with zero Internet adoption ---"
count if surv_deeppost00 == 0
di "  N with surv_deeppost00 = 0: " r(N) " (stable groups)"
count if surv_deeppost00 == .
di "  N with surv_deeppost00 = .: " r(N) " (missing)"
di ""
di "--- Control variables ---"
summ $controls $change


/*==============================================================================
  STEP 2: TABLE 2 -- MAIN EFFECTS: OLS
  Dep var: wagediff = ln(weekwage_2000) - ln(weekwage_1995)

  Col 1: surv_deeppost00, no controls
  Col 2: surv_deeppost00 + home Internet + missing + controls + changes
  Col 3: + shallow Internet + PCs per employee
==============================================================================*/

di _n "=============================================="
di    "TABLE 2: MAIN EFFECTS -- OLS"
di    "=============================================="

* --- Column 1: No controls ---
di _n "--- Column 1: No controls ---"
regress wagediff surv_deeppost00, robust
local b_1  = _b[surv_deeppost00]
local se_1 = _se[surv_deeppost00]
local r2_1 = e(r2)
local nn_1 = e(N)
di "  beta = " %7.4f `b_1' " (" %5.4f `se_1' "), R2 = " %5.3f `r2_1' ", N = " `nn_1'

* --- Column 2: Full controls ---
di _n "--- Column 2: Full controls ---"
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing $controls $change, robust
local b_2  = _b[surv_deeppost00]
local se_2 = _se[surv_deeppost00]
local r2_2 = e(r2)
local nn_2 = e(N)
di "  beta = " %7.4f `b_2' " (" %5.4f `se_2' "), R2 = " %5.3f `r2_2' ", N = " `nn_2'

* --- Column 3: + other IT measures ---
di _n "--- Column 3: + other IT ---"
cap noisily regress wagediff surv_deeppost00 surv_pcperemp00 surv_shalpost00 ///
    indivhomeinternet00_cty missing $controls $change, robust
if !_rc {
    local b_3  = _b[surv_deeppost00]
    local se_3 = _se[surv_deeppost00]
    local r2_3 = e(r2)
    local nn_3 = e(N)
    di "  beta = " %7.4f `b_3' " (" %5.4f `se_3' "), R2 = " %5.3f `r2_3' ", N = " `nn_3'
}
else {
    local b_3  = .
    local se_3 = .
    local r2_3 = .
    local nn_3 = .
    di "  Column 3 skipped (variable not found)"
}


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  fdTR: The cross-sectional FD regression is equivalent to a 2-period
  panel with first differences. Create panel for twowayfeweights:

  Period 1 (1995): D_level = 0, DeltaY = ., DeltaD = .
  Period 2 (2000): D_level = surv_deeppost00, DeltaY = wagediff,
                   DeltaD = surv_deeppost00

  twowayfeweights DY G T DD D_level, type(fdTR) [controls(...)]

  With continuous D going from 0 to surv_deeppost00 (heterogeneous adoption),
  the FE/FD estimator assigns negative weights to counties with below-average
  Internet adoption intensity (Proposition S1 in dCDH web appendix).
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- Create 2-period panel for fdTR ---
gen county_id = _n

* Save base data
tempfile base
save `base'

* Period 1 (1995): all missing FDs, D_level = 0
keep county_id
gen period = 1995
gen DY = .
gen DD = .
gen D_level = 0
tempfile p1
save `p1'

* Period 2 (2000): FDs from data, D_level = surv_deeppost00
use `base', clear
keep county_id wagediff surv_deeppost00 $controls $change ///
    indivhomeinternet00_cty missing
gen period = 2000
gen DY = wagediff
gen DD = surv_deeppost00
gen D_level = surv_deeppost00
append using `p1'
sort county_id period

di _n "=== PANEL FOR TWOWAYFEWEIGHTS (fdTR) ==="
di "Observations: " _N
qui tab county_id
di "Counties: " r(r)
di "Periods: 2 (1995, 2000)"
di ""
di "First differences (DY, DD): non-missing at 2000 only"
count if DY != .
di "  FD observations: " r(N)
di "Treatment levels (D_level): non-missing at all periods"
count if D_level != .
di "  Level observations: " r(N)
di ""
summ DY DD D_level

* --- A1: fdTR without controls ---
di _n "=============================================="
di    "A1: fdTR -- surv_deeppost00 (no controls)"
di    "=============================================="
di "  Syntax: twowayfeweights DY county_id period DD D_level, type(fdTR)"
di ""
cap noisily twowayfeweights DY county_id period DD D_level, ///
    type(fdTR) summary_measures

* --- A2: fdTR with controls ---
di _n "=============================================="
di    "A2: fdTR -- with controls"
di    "=============================================="
di "  Adding: indivhomeinternet00_cty missing + baseline controls"
di ""
cap noisily twowayfeweights DY county_id period DD D_level, ///
    type(fdTR) ///
    controls(indivhomeinternet00_cty missing $controls $change) ///
    summary_measures

* Reload base data for LaTeX export
use `base', clear


/*==============================================================================
  STEP 4: LATEX TABLES
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* ===== TABLE 2 =====
cap file close texfile
file open texfile using "$outdir/table2.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Table 2---Internet and Wage Growth (OLS)}" _n
file write texfile "\label{tab:table2}" _n
file write texfile "\begin{tabular}{lccc}" _n
file write texfile "\toprule" _n
file write texfile " & (1) & (2) & (3) \\\\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{4}{l}{\textit{Dep.\ var.: \$\Delta\$ln(weekly wage), 1995--2000}} \\\\" _n
file write texfile "\addlinespace" _n

* Coefficients
forvalues k = 1/3 {
    if `b_`k'' < . {
        local bfmt_`k' : di %7.4f `b_`k''
        local bfmt_`k' = strtrim("`bfmt_`k''")
        _stars `b_`k'' `se_`k''
        local s_`k' "`r(s)'"
        local sfmt_`k' : di %7.4f `se_`k''
        local sfmt_`k' = strtrim("`sfmt_`k''")
    }
    else {
        local bfmt_`k' "--"
        local s_`k' ""
        local sfmt_`k' "--"
    }
}

file write texfile "Advanced Internet adoption"
file write texfile " & `bfmt_1'`s_1' & `bfmt_2'`s_2' & `bfmt_3'`s_3' \\\\" _n
file write texfile " & (`sfmt_1') & (`sfmt_2') & (`sfmt_3') \\\\" _n
file write texfile "\addlinespace" _n

file write texfile "Home Internet & & Y & Y \\\\" _n
file write texfile "Baseline controls & & Y & Y \\\\" _n
file write texfile "Change controls & & Y & Y \\\\" _n
file write texfile "Other IT measures & & & Y \\\\" _n
file write texfile "\addlinespace" _n

* R-squared
forvalues k = 1/3 {
    if `r2_`k'' < . {
        local rfmt_`k' : di %5.3f `r2_`k''
        local rfmt_`k' = strtrim("`rfmt_`k''")
    }
    else {
        local rfmt_`k' "--"
    }
}
file write texfile "\$R^2\$ & `rfmt_1' & `rfmt_2' & `rfmt_3' \\\\" _n

* N
forvalues k = 1/3 {
    if `nn_`k'' > 0 & `nn_`k'' < . {
        local nfmt_`k' : di %6.0fc `nn_`k''
        local nfmt_`k' = strtrim("`nfmt_`k''")
    }
    else {
        local nfmt_`k' "--"
    }
}
file write texfile "Observations & `nfmt_1' & `nfmt_2' & `nfmt_3' \\\\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{4}{p{0.85\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} OLS regressions. Dependent variable is the change in" _n
file write texfile " log average weekly wages from 1995 to 2000. Treatment is the fraction" _n
file write texfile " of establishments using advanced Internet in 2000." _n
file write texfile " Heteroskedasticity-robust standard errors in parentheses." _n
file write texfile " *** Significant at 1\%, ** 5\%, * 10\%.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table2.tex created"

* ===== TWOWAYFEWEIGHTS SUMMARY =====
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:twowayfe}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\toprule" _n
file write texfile "\multicolumn{2}{l}{\textit{Specification: Table 2 (fdTR)}} \\\\" _n
file write texfile "\midrule" _n
file write texfile "Regression type & First differences (fdTR) \\\\" _n
file write texfile "Dependent variable & \$\Delta\$ln(weekly wage) \\\\" _n
file write texfile "Treatment variable & Advanced Internet adoption \\\\" _n
file write texfile "Group (G) & County \\\\" _n
file write texfile "Time (T) & Year (1995, 2000) \\\\" _n
file write texfile "Design & Fuzzy (Internet use varies within county) \\\\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for detailed weight distribution}} \\\\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/forman_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Forman, Goldfarb \& Greenstein (2012)}\\\\" _n
file write texfile "{\large The Internet and Local Wages: A Puzzle}\\\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 102(1), 556--575}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table2}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> forman_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Forman et al. (2012)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table2.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/forman_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
