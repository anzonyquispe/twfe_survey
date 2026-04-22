/*==============================================================================
  MOSER & VOENA (2012) - "Compulsory Licensing: Evidence from the Trading
  with the Enemy Act"
  American Economic Review, 102(1), 396-427

  Pipeline: STEP 1 Data -> STEP 2 Table 2 -> STEP 3 twowayfeweights -> STEP 4 LaTeX

  dCDH Web Appendix #22: Table 2, Regression 1 with controls, feTR
  "The stable groups assumption is satisfied: there are patent classes
   where no patent was licensed." Sharp design.

  Specification (Table 2 Col 1):
    count_usa_ct = alpha_c + gamma_t + beta*treat_ct + delta*count_for_2_ct + eps
    xtreg count_usa treat count_for_2 td*, fe i(class_id) robust cluster(class_id)

  Panel: 7,248 patent classes x 65 years (1875-1939) = 471,120 obs
  Treatment: compulsory licensing of German-owned chemical patents post-1918
  Outcome: number of US patents in each patent class-year
==============================================================================*/

clear all
set more off
set matsize 5000
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Moser and Voena (2012)"
global datadir  "$paperdir/compulsory_licensing_replication"
global outdir   "$paperdir"

log using "$outdir/run_twowayfe.log", text replace

* Install packages if needed
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace

* Helper program: significance stars from t-stat
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
  Load patent class x year panel. Treatment = licensed class indicator.
==============================================================================*/

use "$datadir/chem_patents_maindataset.dta", clear

di _n "=== DATA SUMMARY ==="
di "Observations: " _N
desc, short
di ""
di "--- Panel structure ---"
qui tab class_id
di "Patent classes (G): " r(r)
qui tab grntyr
di "Years (T): " r(r)
di ""
di "--- Treatment: treat (licensed class indicator) ---"
tab treat
di ""
di "--- Outcome: count_usa (US patents per class-year) ---"
summ count_usa, detail
di ""
di "--- Controls ---"
summ count_for count_for_2

* Create year dummies (following original code exactly)
forvalues x = 1876/1939 {
    gen td_`x' = 0
    qui replace td_`x' = 1 if grntyr == `x'
}


/*==============================================================================
  STEP 2: TABLE 2 -- EFFECTS OF COMPULSORY LICENSING ON US PATENTING
  Dep var: count_usa (number of US patents in class c, year t)

  Col 1: treat + count_for_2 (quadratic foreign patents)
  Col 2: treat + count_for (linear foreign patents)
  Col 3: treat only (no controls)
  Col 4: count_cl + count_for (CL count as treatment)
  Col 5: count_cl + count_cl_2 + count_for (CL polynomial)
  Col 6: count_cl (no controls)
==============================================================================*/

di _n "=============================================="
di    "TABLE 2: EFFECTS OF COMPULSORY LICENSING"
di    "=============================================="

* Initialize storage
forvalues k = 1/6 {
    local b_`k'  = .
    local se_`k' = .
    local nn_`k' = 0
}

* --- Column 1: treat + quadratic foreign ---
di _n "--- Column 1: treat + count_for_2 ---"
xtreg count_usa treat count_for_2 td_*, fe i(class_id) robust cluster(class_id)
local b_1  = _b[treat]
local se_1 = _se[treat]
local nn_1 = e(N)
local ng_1 = e(N_g)
di "  beta(treat) = " %7.4f `b_1' " (" %5.4f `se_1' "), N = " `nn_1' ", groups = " `ng_1'

* --- Column 2: treat + linear foreign ---
di _n "--- Column 2: treat + count_for ---"
xtreg count_usa treat count_for td_*, fe i(class_id) robust cluster(class_id)
local b_2  = _b[treat]
local se_2 = _se[treat]
local nn_2 = e(N)
di "  beta(treat) = " %7.4f `b_2' " (" %5.4f `se_2' ")"

* --- Column 3: treat only ---
di _n "--- Column 3: treat, no controls ---"
xtreg count_usa treat td_*, fe i(class_id) robust cluster(class_id)
local b_3  = _b[treat]
local se_3 = _se[treat]
local nn_3 = e(N)
di "  beta(treat) = " %7.4f `b_3' " (" %5.4f `se_3' ")"

* --- Column 4: count_cl + count_for ---
di _n "--- Column 4: count_cl + count_for ---"
xtreg count_usa count_cl count_for td_*, fe i(class_id) robust cluster(class_id)
local b_4  = _b[count_cl]
local se_4 = _se[count_cl]
local nn_4 = e(N)
di "  beta(count_cl) = " %7.4f `b_4' " (" %5.4f `se_4' ")"

* --- Column 5: count_cl polynomial + count_for ---
di _n "--- Column 5: count_cl + count_cl_2 + count_for ---"
xtreg count_usa count_cl count_cl_2 count_for td_*, fe i(class_id) robust cluster(class_id)
local b_5  = _b[count_cl]
local se_5 = _se[count_cl]
local nn_5 = e(N)
di "  beta(count_cl) = " %7.4f `b_5' " (" %5.4f `se_5' ")"

* --- Column 6: count_cl only ---
di _n "--- Column 6: count_cl, no controls ---"
xtreg count_usa count_cl td_*, fe i(class_id) robust cluster(class_id)
local b_6  = _b[count_cl]
local se_6 = _se[count_cl]
local nn_6 = e(N)
di "  beta(count_cl) = " %7.4f `b_6' " (" %5.4f `se_6' ")"


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  feTR: Y = count_usa, G = class_id, T = grntyr, D = treat
  Sharp design: many patent classes with treat=0 at all periods
  twowayfeweights handles G and T FE internally; only pass non-FE controls
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- A1: feTR with control (matching Col 2) ---
di _n "=============================================="
di    "A1: feTR -- treat with control (count_for)"
di    "=============================================="
di "  Syntax: twowayfeweights count_usa class_id grntyr treat,"
di "          type(feTR) controls(count_for) summary_measures"
di ""
cap noisily twowayfeweights count_usa class_id grntyr treat, ///
    type(feTR) controls(count_for) summary_measures

* --- A2: feTR without controls (matching Col 3) ---
di _n "=============================================="
di    "A2: feTR -- treat without controls"
di    "=============================================="
cap noisily twowayfeweights count_usa class_id grntyr treat, ///
    type(feTR) summary_measures

* --- A3: feTR with count_cl as treatment ---
di _n "=============================================="
di    "A3: feTR -- count_cl (continuous treatment)"
di    "=============================================="
cap noisily twowayfeweights count_usa class_id grntyr count_cl, ///
    type(feTR) controls(count_for) summary_measures


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
file write texfile "\small" _n
file write texfile "\caption{Table 2---Effects of Compulsory Licensing on Domestic Invention}" _n
file write texfile "\label{tab:table2}" _n
file write texfile "\begin{tabular}{lcccccc}" _n
file write texfile "\toprule" _n
file write texfile " & (1) & (2) & (3) & (4) & (5) & (6) \\\\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{7}{l}{\textit{Dep.\ var.: Number of US patents (count\_usa)}} \\\\" _n
file write texfile "\addlinespace" _n

* Treat coefficients (cols 1-3)
forvalues k = 1/3 {
    local bfmt_`k' : di %7.4f `b_`k''
    local bfmt_`k' = strtrim("`bfmt_`k''")
    _stars `b_`k'' `se_`k''
    local s_`k' "`r(s)'"
}
file write texfile "Treat (licensed class)"
file write texfile " & `bfmt_1'`s_1' & `bfmt_2'`s_2' & `bfmt_3'`s_3' & & & \\\\" _n

forvalues k = 1/3 {
    local sfmt_`k' : di %7.4f `se_`k''
    local sfmt_`k' = strtrim("`sfmt_`k''")
}
file write texfile " & (`sfmt_1') & (`sfmt_2') & (`sfmt_3') & & & \\\\" _n
file write texfile "\addlinespace" _n

* Count CL coefficients (cols 4-6)
forvalues k = 4/6 {
    local bfmt_`k' : di %7.4f `b_`k''
    local bfmt_`k' = strtrim("`bfmt_`k''")
    _stars `b_`k'' `se_`k''
    local s_`k' "`r(s)'"
}
file write texfile "No.\ licensed patents"
file write texfile " & & & & `bfmt_4'`s_4' & `bfmt_5'`s_5' & `bfmt_6'`s_6' \\\\" _n

forvalues k = 4/6 {
    local sfmt_`k' : di %7.4f `se_`k''
    local sfmt_`k' = strtrim("`sfmt_`k''")
}
file write texfile " & & & & (`sfmt_4') & (`sfmt_5') & (`sfmt_6') \\\\" _n
file write texfile "\addlinespace" _n

file write texfile "Foreign patents (quad.) & Y & & & & & \\\\" _n
file write texfile "Foreign patents (linear) & & Y & & Y & Y & \\\\" _n
file write texfile "Class FE & Y & Y & Y & Y & Y & Y \\\\" _n
file write texfile "Year FE & Y & Y & Y & Y & Y & Y \\\\" _n
file write texfile "\addlinespace" _n

local nfmt : di %12.0fc `nn_1'
local nfmt = strtrim("`nfmt'")
file write texfile "Observations & `nfmt' & `nfmt' & `nfmt' & `nfmt' & `nfmt' & `nfmt' \\\\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{7}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} All regressions include patent class and year fixed effects." _n
file write texfile " Robust standard errors clustered by patent class in parentheses." _n
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
file write texfile "\multicolumn{2}{l}{\textit{Specification: Table 2 (feTR)}} \\\\" _n
file write texfile "\midrule" _n
file write texfile "Regression type & Fixed effects (feTR) \\\\" _n
file write texfile "Dependent variable & No.\ US patents (count\_usa) \\\\" _n
file write texfile "Treatment variable & Licensed class indicator (treat) \\\\" _n
file write texfile "Group (G) & Patent class (class\_id) \\\\" _n
file write texfile "Time (T) & Grant year (1875--1939) \\\\" _n
file write texfile "Design & Sharp (many unlicensed classes) \\\\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for detailed weight distribution}} \\\\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/moser_voena_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Moser \& Voena (2012)}\\\\" _n
file write texfile "{\large Compulsory Licensing: Evidence from the}\\\\" _n
file write texfile "{\large Trading with the Enemy Act}\\\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 102(1), 396--427}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table2}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> moser_voena_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Moser & Voena (2012)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table2.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/moser_voena_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
