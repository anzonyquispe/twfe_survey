/*==============================================================================
  ENIKOLOPOV, PETROVA & ZHURAVSKAYA (2011) - "Media and Political Persuasion:
  Evidence from Russia"
  American Economic Review, 101(7), 3253-3285

  Pipeline: STEP 1 Data -> STEP 2 Table 3 Panel FE -> STEP 3 twowayfeweights -> STEP 4 LaTeX

  dCDH Web Appendix #17: Table 3, Regression 1, feTR, fuzzy design
  "The stable groups assumption is not satisfied: the share of people having
   access to NTV strictly increases in all regions between 1995 and 1999."
  Treatment of interest: whether a person has access to NTV (varies within
  subregion x year cells). Fuzzy design.

  dCDH find: beta_fe = 6.65 (SE=1.40)
    918 positive weights (47.4%), 1,020 negative weights (52.6%)
    sigma_fe = 0.91, sigma_fe_bar = 1.23

  Specification (Table 3, Panel FE):
    Votes_jst = alpha_s + delta_t + beta * NTV_access_st + eps_st
    xtreg Y Watch_probit_ _I*, fe i(tik_id) cluster(tik_id)
    Sample: year in {1995, 1999}, region!=5 & region!=6

  Panel: ~1,900 subregions x 2 election years (1995, 1999)
==============================================================================*/

clear all
set more off
set matsize 2000
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Enikolopov et al. (2011)"
global datadir  "$paperdir/Replication"
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
  Load aggregate-level data and reshape to panel (1995, 1999).
  Following original Aggregate_level_results_Replication.do exactly.
==============================================================================*/

use "$datadir/NTV_Aggregate_Data.dta", clear

di _n "=== RAW DATA SUMMARY ==="
di "Observations: " _N
desc, short

* Create polynomial variables (following original code)
forvalues x = 2/5 {
    gen population98_`x' = population1998^`x'
    gen population96_`x' = population1996^`x'
    gen wage1998_`x' = wage98^`x'
    gen wage1996_`x' = wage96^`x'
}
gen population98_1 = population1998
gen population96_1 = population1996
gen wage1998_1 = wage98
gen wage1996_1 = wage96

* Define globals
global socioec "population98_* wage1998_* Gorod doctors_pc1998 nurses1998"

* --- Sample restriction (same as original) ---
drop if Votes_Edinstvo_1999 == .
di "After dropping missing Edinstvo_1999: " _N " subregions"

* --- Prepare variables for reshape ---
* Harmonize party names across elections (DVR 1995 -> SPS 1999)
rename Votes_DVR_1995 Votes_SPS_1995

* Create Watch_probit by year (0 in 1995, actual in 1999)
gen Watch_probit_1995 = 0
rename Watch_probit Watch_probit_1999

* Turnout variable name harmonization
cap rename Turnout_2003 Turnout2003
cap rename Turnout1995 Turnout_1995
cap rename Turnout1999 Turnout_1999
cap gen Turnout_1995 = Turnout1995
cap gen Turnout_1999 = Turnout1999

* Population and wage by year
rename logpop98 logpop1999
rename logpop96 logpop1995
rename wage98_ln logwage1999
rename wage96_ln logwage1995

di _n "=== TREATMENT SUMMARY ==="
di "Watch_probit_1995 (NTV access 1995): always 0"
summ Watch_probit_1995
di "Watch_probit_1999 (NTV access 1999):"
summ Watch_probit_1999

* --- Reshape to long panel ---
reshape long Watch_probit_ Votes_SPS_ Turnout_ Votes_Yabloko_ ///
    Votes_KPRF_ Votes_LDPR_ logpop logwage, i(tik_id) j(_j)

* Create year dummies
xi i._j

di _n "=== PANEL DATA SUMMARY ==="
di "Observations: " _N
qui tab tik_id
di "Subregions: " r(r)
di "Election years: 1995, 1999 (and 2003 if present)"
di ""
di "Treatment variable: Watch_probit_"
summ Watch_probit_ if _j == 1995
summ Watch_probit_ if _j == 1999
di ""
di "--- Sample for analysis: _j != 2003, region != 5,6 ---"
count if _j != 2003
di "  Observations for analysis: " r(N)


/*==============================================================================
  STEP 2: TABLE 3 -- PANEL FIXED EFFECTS (1995-1999)
  Dep var: vote share for various parties
  FE: subregion (tik_id) + year (_j)
  Treatment: Watch_probit_ (NTV access share)
  Sample: _j != 2003

  dCDH verification target: beta_fe = 6.65 (SE = 1.40)
==============================================================================*/

di _n "=============================================="
di    "TABLE 3: PANEL FIXED EFFECTS (1995-1999)"
di    "=============================================="

local cond "if _j != 2003"
local i = 0

foreach var of varlist Votes_SPS_ Votes_Yabloko_ Votes_KPRF_ Votes_LDPR_ Turnout_ {
    local i = `i' + 1
    di _n "--- `var' ---"
    xtreg `var' Watch_probit_ _I* `cond', fe i(tik_id) cluster(tik_id)
    local b_`i'  = _b[Watch_probit_]
    local se_`i' = _se[Watch_probit_]
    local nn_`i' = e(N)
    local ng_`i' = e(N_g)
    di "  beta(Watch_probit_) = " %7.2f `b_`i'' " (" %5.2f `se_`i'' ")"
    di "  N = " `nn_`i'' ", subregions = " `ng_`i''
}

* Labels for table
local lbl_1 "SPS (DVR in 1995)"
local lbl_2 "Yabloko"
local lbl_3 "KPRF"
local lbl_4 "LDPR"
local lbl_5 "Turnout"


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  feTR: Y = Votes_SPS_, G = tik_id, T = _j, D = Watch_probit_
  Fuzzy design: NTV access varies within subregion x year cells

  dCDH report for this paper:
    918 positive weights (47.4%), 1020 negative weights (52.6%)
    sigma_fe = 0.91, sigma_fe_bar = 1.23
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- A1: feTR for SPS/DVR votes (main outcome) ---
di _n "=============================================="
di    "A1: feTR -- Votes_SPS_ (opposition: SPS/DVR)"
di    "=============================================="
di "  Y = Votes_SPS_, G = tik_id, T = _j, D = Watch_probit_"
di "  Sample: _j != 2003"
di ""
preserve
keep if _j != 2003
cap noisily twowayfeweights Votes_SPS_ tik_id _j Watch_probit_, ///
    type(feTR) summary_measures
restore

* --- A2: feTR for Yabloko votes ---
di _n "=============================================="
di    "A2: feTR -- Votes_Yabloko_"
di    "=============================================="
preserve
keep if _j != 2003
cap noisily twowayfeweights Votes_Yabloko_ tik_id _j Watch_probit_, ///
    type(feTR) summary_measures
restore

* --- A3: feTR for KPRF votes ---
di _n "=============================================="
di    "A3: feTR -- Votes_KPRF_"
di    "=============================================="
preserve
keep if _j != 2003
cap noisily twowayfeweights Votes_KPRF_ tik_id _j Watch_probit_, ///
    type(feTR) summary_measures
restore

* --- A4: feTR for Turnout ---
di _n "=============================================="
di    "A4: feTR -- Turnout_"
di    "=============================================="
preserve
keep if _j != 2003
cap noisily twowayfeweights Turnout_ tik_id _j Watch_probit_, ///
    type(feTR) summary_measures
restore


/*==============================================================================
  STEP 4: LATEX TABLES
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* ===== TABLE 3 =====
cap file close texfile
file open texfile using "$outdir/table3.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Table 3---Panel Fixed Effects: NTV and Voting (1995--1999)}" _n
file write texfile "\label{tab:table3}" _n
file write texfile "\begin{tabular}{lccccc}" _n
file write texfile "\toprule" _n
file write texfile " & SPS & Yabloko & KPRF & LDPR & Turnout \\\\" _n
file write texfile " & (1) & (2) & (3) & (4) & (5) \\\\" _n
file write texfile "\midrule" _n

* Write coefficients
file write texfile "NTV access share" _n

local bline " "
local sline " "
forvalues k = 1/5 {
    local bfmt : di %6.2f `b_`k''
    local bfmt = strtrim("`bfmt'")
    _stars `b_`k'' `se_`k''
    local bline "`bline' & `bfmt'`r(s)'"

    local sfmt : di %6.2f `se_`k''
    local sfmt = strtrim("`sfmt'")
    local sline "`sline' & (`sfmt')"
}
file write texfile "`bline' \\\\" _n
file write texfile "`sline' \\\\" _n

file write texfile "\addlinespace" _n
file write texfile "Subregion FE & Y & Y & Y & Y & Y \\\\" _n
file write texfile "Year FE & Y & Y & Y & Y & Y \\\\" _n
file write texfile "\addlinespace" _n

local nfmt : di %6.0fc `nn_1'
local nfmt = strtrim("`nfmt'")
local gfmt : di %6.0fc `ng_1'
local gfmt = strtrim("`gfmt'")
file write texfile "Observations & `nfmt' & `nfmt' & `nfmt' & `nfmt' & `nfmt' \\\\" _n
file write texfile "Subregions & `gfmt' & `gfmt' & `gfmt' & `gfmt' & `gfmt' \\\\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{6}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Panel FE regressions with subregion and year fixed effects." _n
file write texfile " Standard errors clustered by subregion in parentheses." _n
file write texfile " DVR (1995) mapped to SPS (1999). Treatment: share of population" _n
file write texfile " with NTV access (0 in 1995, positive in 1999)." _n
file write texfile " *** Significant at 1\%, ** 5\%, * 10\%.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table3.tex created"

* ===== TWOWAYFEWEIGHTS SUMMARY =====
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:twowayfe}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\toprule" _n
file write texfile "\multicolumn{2}{l}{\textit{Specification: Table 3 (feTR)}} \\\\" _n
file write texfile "\midrule" _n
file write texfile "Regression type & Fixed effects (feTR) \\\\" _n
file write texfile "Dependent variable & Vote share for SPS/DVR \\\\" _n
file write texfile "Treatment variable & NTV access share (Watch\_probit) \\\\" _n
file write texfile "Group (G) & Subregion (tik\_id) \\\\" _n
file write texfile "Time (T) & Election year (1995, 1999) \\\\" _n
file write texfile "Design & Fuzzy (NTV access varies within cells) \\\\" _n
file write texfile "\addlinespace" _n
file write texfile "dCDH reference values: & \\\\" _n
file write texfile "\quad Positive weights & 918 (47.4\%) \\\\" _n
file write texfile "\quad Negative weights & 1,020 (52.6\%) \\\\" _n
file write texfile "\quad \$\\hat{\\sigma}_{fe}\$ & 0.91 \\\\" _n
file write texfile "\quad \$\\bar{\\hat{\\sigma}}_{fe}\$ & 1.23 \\\\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for detailed weight distribution}} \\\\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/enikolopov_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Enikolopov, Petrova \& Zhuravskaya (2011)}\\\\" _n
file write texfile "{\large Media and Political Persuasion:}\\\\" _n
file write texfile "{\large Evidence from Russia}\\\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(7), 3253--3285}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table3}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> enikolopov_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Enikolopov et al. (2011)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table3.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/enikolopov_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
