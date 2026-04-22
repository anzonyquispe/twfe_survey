/*==============================================================================
  WANG (2011) - "State Misallocation and Housing Prices:
  Theory and Evidence from China"
  AER, 101(5), 2081-2107

  Pipeline: STEP 0 Generate mismatch → STEP 1 Table 5 Panel A →
           STEP 2 twowayfeweights → STEP 3 LaTeX

  Table 5 Panel A - Parsimonious specification, Equation (15):
    F_it = α₀ + α₁(Post_t × Δ_i) + α₂ Post_t + α₃ Δ_i + α₄ X_it + ε_it

  Where:
    F_it = housing services (log floor space, toilet, water, electric, excreta)
    Post_t = regime2 (1 if year > 1993)
    Δ_i = log_mismatchpre (prereform housing mismatch)
    X_it = log income, log assets, age cubic, education, province*year FE

  Sample: households in state-owned housing in 1993 (apt_nonmrkt93==1)
  SE: bootstrapped, clustered by household (200 reps)

  twowayfeweights: feTR (sharp design, per dCDH web appendix #12)
    G = province, T = year, D = Post × Δ
==============================================================================*/

clear all
set more off
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Wang (2011)"
global datadir  "$paperdir/aer_wang_data_files"
global outdir   "$paperdir"

log using "$outdir/run_twowayfe.log", text replace

* Install packages if needed
cap which estout
if _rc ssc install estout, replace
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace


/*==============================================================================
  STEP 0: GENERATE MISMATCH VARIABLE (replicating Table 2 data prep)

  The mismatch Δ_i measures the gap between the housing a household WOULD
  have chosen in a free market vs what they actually got under state allocation.
  Estimated from a hedonic regression on private-market households (pre-reform).
==============================================================================*/

use "$datadir/data_aersubmit.dta", clear

sort hhidc year id

di _n "=== STEP 0: Generate mismatch variable ==="
di "Observations loaded: " _N

* --- Table 2 Column 1: Pre-reform hedonic regression ---
* Regress log rental value on household characteristics + province*year FE
* Sample: pre-reform (year<=1993), private market (apt_nonmrkt==0),
*         one obs per household-year
di _n "--- Table 2 Col 1: Pre-reform hedonic (private market) ---"
xi: regress logapt_rentval logwage_broadhh logtot_assets ///
    age_head age_head2 age_head3 eduyr_head ///
    i.province*i.year ///
    if year<=1993 & apt_nonmrkt==0 & ///
    (hhidc!=hhidc[_n-1] | year!=year[_n-1]), cluster(hhidc)

di "  N = " e(N) "  R2 = " %5.3f e(r2)
di "  Paper Table 2 Col 1: N=1212, R2=0.17"
di "  beta(logwage): " %7.4f _b[logwage_broadhh] " (paper: 0.142)"

* Predict log rental value for ALL pre-reform obs (including state housing)
predict pred_logapt_rentval if year<=1993 & ///
    (hhidc!=hhidc[_n-1] | year!=year[_n-1]), xb

* Mismatch = predicted market value - actual value
* Positive mismatch = household consumes LESS housing than market would assign
gen log_mismatch = pred_logapt_rentval - logapt_rentval

* --- Generate household-level prereform mismatch (Δ_i) ---
gen mpre = log_mismatch if year<=1993
bysort hhidc: egen log_mismatchpre = mean(mpre)
drop mpre

di _n "--- Mismatch variable summary ---"
summ log_mismatchpre if apt_nonmrkt93==1, detail
di "  Paper Table 3: mean mismatch (state housing) = 0.150"

* --- Generate interaction term: Post × Δ ---
gen post_mismatch = regime2 * log_mismatchpre
label var post_mismatch "Post × Mismatch"
label var log_mismatchpre "Prereform Mismatch (Δ_i)"

* Province is already numeric
gen province_num = province

* Mark the analysis sample (one obs per household-year)
sort hhidc year id
gen first_hhyr = (hhidc!=hhidc[_n-1] | year!=year[_n-1])


/*==============================================================================
  STEP 1: TABLE 5 PANEL A - PARSIMONIOUS SPECIFICATION

  Equation (15): F_it = α₀ + α₁(Post×Δ) + α₂ Post + α₃ Δ + α₄ X + prov*year + ε

  5 dependent variables:
    Col 1: logapt_sqm     (log floor space)
    Col 2: apt_toiletin   (flushing toilet)
    Col 3: apt_water_house (drinking water)
    Col 4: apt_electric    (electricity)
    Col 5: no_excreta      (no excreta)

  Sample: apt_nonmrkt93==1 & first obs per household-year
  SE: clustered by household (paper uses bootstrap 200 reps)
==============================================================================*/

di _n "=============================================="
di    "TABLE 5 PANEL A: PARSIMONIOUS SPECIFICATION"
di    "=============================================="

local depvars "logapt_sqm apt_toiletin apt_water_house apt_electric no_excreta"
local deplab1 "Log floor space"
local deplab2 "Flushing toilet"
local deplab3 "Drinking water"
local deplab4 "Electricity"
local deplab5 "No excreta"

* Paper values for verification (Post × Δ coefficient)
local paper_b1 = 0.21
local paper_b2 = 0.14
local paper_b3 = 0.06
local paper_b4 = -0.00
local paper_b5 = 0.05

* Paper values for N
local paper_n1 = 1867
local paper_n2 = 1919
local paper_n3 = 1918
local paper_n4 = 1914
local paper_n5 = 1903

* Paper values for R²
local paper_r1 = 0.25
local paper_r2 = 0.34
local paper_r3 = 0.35
local paper_r4 = 0.02
local paper_r5 = 0.05

set matsize 2000

* --- Run regressions ---
local k = 0
foreach dv of local depvars {
    local ++k

    di _n "--- Column `k': `deplab`k'' (`dv') ---"

    cap noisily xi: regress `dv' i.regime2*log_mismatchpre ///
        logwage_broadhh logtot_assets ///
        age_head age_head2 age_head3 eduyr_head ///
        i.province*i.year ///
        if first_hhyr==1 & apt_nonmrkt93==1, cluster(hhidc)

    if !_rc & e(N) > 0 {
        estimates store col`k'

        * Extract key coefficients
        * The interaction term from xi: is _IregXlog_m_1 or similar
        * With xi: i.regime2*log_mismatchpre, the interaction is _IregXlog_1
        local b_postmis = _b[_IregXlog_m_1]
        local se_postmis = _se[_IregXlog_m_1]
        local b_post = _b[_Iregime2_1]
        local se_post = _se[_Iregime2_1]
        local b_mis = _b[log_mismatchpre]
        local se_mis = _se[log_mismatchpre]

        di "  Post × Δ:  " %7.3f `b_postmis' " (" %5.3f `se_postmis' ")"
        di "  Post:      " %7.3f `b_post' " (" %5.3f `se_post' ")"
        di "  Δ:         " %7.3f `b_mis' " (" %5.3f `se_mis' ")"
        di "  N:         " e(N) " (paper: `paper_n`k'')"
        di "  Adj R²:    " %5.2f e(r2_a) " (paper: `paper_r`k'')"
        di "  Paper β₁:  `paper_b`k''"
    }
    else {
        di "  FAILED"
    }
}


/*==============================================================================
  STEP 2: TWOWAYFEWEIGHTS DECOMPOSITION

  Per dCDH web appendix #12: sharp design, Regression 1 type (feTR)

  Y = logapt_sqm, G = province, T = year
  D = Post × Δ (continuous treatment: regime2 * log_mismatchpre)
  Controls = log_mismatchpre + household covariates

  Note: regime2 (Post) is absorbed by year FE, so NOT in controls.
        log_mismatchpre varies within province, so included as control.
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* Prepare sample for twowayfeweights
preserve
keep if first_hhyr==1 & apt_nonmrkt93==1

* Drop observations with missing key variables
drop if logapt_sqm == . | post_mismatch == . | log_mismatchpre == .
drop if logwage_broadhh == . | logtot_assets == .
drop if age_head == . | age_head2 == . | age_head3 == .
drop if eduyr_head == .

di "Observations for twowayfeweights: " _N

di _n "--- Type: feTR (Fixed Effects, sharp design) ---"
di "Y = logapt_sqm, G = province_num, T = year, D = Post × Mismatch"
cap noisily twowayfeweights logapt_sqm province_num year post_mismatch, ///
    type(feTR) controls(log_mismatchpre logwage_broadhh logtot_assets ///
    age_head age_head2 age_head3 eduyr_head)

di _n "--- Type: fdTR (First Differences, for comparison) ---"
cap noisily twowayfeweights logapt_sqm province_num year post_mismatch, ///
    type(fdTR) controls(log_mismatchpre logwage_broadhh logtot_assets ///
    age_head age_head2 age_head3 eduyr_head)

restore


/*==============================================================================
  STEP 3: LATEX TABLE (AER format matching Paper Table 5 Panel A)

  Layout: 5 columns (one per dependent variable)
  Rows: Post × Δ, Post, Δ, Year dummies, Observations, R²
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* --- Helper program for significance stars ---
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

* --- Extract stored estimates ---
forvalues k = 1/5 {
    cap estimates restore col`k'
    if !_rc {
        local n`k' = e(N)
        local r2_`k' : di %4.2f e(r2_a)

        * Post × Δ
        local b1_`k' = _b[_IregXlog_m_1]
        local se1_`k' = _se[_IregXlog_m_1]
        * Post
        local b2_`k' = _b[_Iregime2_1]
        local se2_`k' = _se[_Iregime2_1]
        * Δ
        local b3_`k' = _b[log_mismatchpre]
        local se3_`k' = _se[log_mismatchpre]

        * Year dummies (relative to base year 1989)
        foreach yr in 1991 1993 1997 2000 2004 {
            cap local b_yr`yr'_`k' = _b[_Iyear_`yr']
            if _rc local b_yr`yr'_`k' = .
            cap local se_yr`yr'_`k' = _se[_Iyear_`yr']
            if _rc local se_yr`yr'_`k' = .
        }
    }
    else {
        local n`k' = 0
    }
}

* --- Write Table 5 Panel A ---
cap file close texfile
file open texfile using "$outdir/table5a.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\small" _n
file write texfile "\caption{Table 5---Impact of Household-Level Mismatch" _n
file write texfile " on Housing Size and Quality}" _n
file write texfile "\label{tab:table5a}" _n
file write texfile "\begin{tabular}{lccccc}" _n
file write texfile "\toprule" _n
file write texfile " & Log floor space & Flushing & Drinking & Electricity & No excreta \\" _n
file write texfile " & & toilet & water & & \\" _n
file write texfile " & (1) & (2) & (3) & (4) & (5) \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{6}{l}{\textit{Panel A. Parsimonious specification}} \\" _n
file write texfile "\addlinespace[3pt]" _n

* Row: Post × Δ
local line "Post $\times$ $\Delta_i$"
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local bfmt : di %5.2f `b1_`k''
        local bfmt = strtrim("`bfmt'")
        _stars `b1_`k'' `se1_`k''
        local s "`r(s)'"
        local line "`line' & `bfmt'`s'"
    }
    else {
        local line "`line' & ---"
    }
}
file write texfile "`line' \\" _n

* SE row for Post × Δ
local line " "
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local sfmt : di %5.2f `se1_`k''
        local sfmt = strtrim("`sfmt'")
        local line "`line' & [`sfmt']"
    }
    else {
        local line "`line' & "
    }
}
file write texfile "`line' \\" _n
file write texfile "\addlinespace" _n

* Row: Post
local line "Post"
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local bfmt : di %5.2f `b2_`k''
        local bfmt = strtrim("`bfmt'")
        _stars `b2_`k'' `se2_`k''
        local s "`r(s)'"
        local line "`line' & `bfmt'`s'"
    }
    else {
        local line "`line' & ---"
    }
}
file write texfile "`line' \\" _n

local line " "
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local sfmt : di %5.2f `se2_`k''
        local sfmt = strtrim("`sfmt'")
        local line "`line' & [`sfmt']"
    }
    else {
        local line "`line' & "
    }
}
file write texfile "`line' \\" _n
file write texfile "\addlinespace" _n

* Row: Δ
local line "$\Delta_i$"
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local bfmt : di %5.2f `b3_`k''
        local bfmt = strtrim("`bfmt'")
        _stars `b3_`k'' `se3_`k''
        local s "`r(s)'"
        local line "`line' & `bfmt'`s'"
    }
    else {
        local line "`line' & ---"
    }
}
file write texfile "`line' \\" _n

local line " "
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local sfmt : di %5.2f `se3_`k''
        local sfmt = strtrim("`sfmt'")
        local line "`line' & [`sfmt']"
    }
    else {
        local line "`line' & "
    }
}
file write texfile "`line' \\" _n
file write texfile "\addlinespace" _n

* Year dummies
foreach yr in 1991 1993 1997 2000 2004 {
    local line "Year `yr'"
    forvalues k = 1/5 {
        if `n`k'' > 0 & `b_yr`yr'_`k'' != . {
            local bfmt : di %5.2f `b_yr`yr'_`k''
            local bfmt = strtrim("`bfmt'")
            _stars `b_yr`yr'_`k'' `se_yr`yr'_`k''
            local s "`r(s)'"
            local line "`line' & `bfmt'`s'"
        }
        else {
            local line "`line' & "
        }
    }
    file write texfile "`line' \\" _n

    local line " "
    forvalues k = 1/5 {
        if `n`k'' > 0 & `se_yr`yr'_`k'' != . {
            local sfmt : di %5.2f `se_yr`yr'_`k''
            local sfmt = strtrim("`sfmt'")
            local line "`line' & [`sfmt']"
        }
        else {
            local line "`line' & "
        }
    }
    file write texfile "`line' \\" _n
    file write texfile "\addlinespace" _n
}

* Observations and R²
file write texfile "\midrule" _n
local line "Observations"
forvalues k = 1/5 {
    if `n`k'' > 0 {
        local nfmt : di %12,0gc `n`k''
        local nfmt = strtrim("`nfmt'")
        local line "`line' & `nfmt'"
    }
    else {
        local line "`line' & ---"
    }
}
file write texfile "`line' \\" _n

* Write Adjusted R² row (use _char(36) for literal $ to avoid Stata macro expansion)
file write texfile "Adjusted " _char(36) "R^2" _char(36)
forvalues k = 1/5 {
    if `n`k'' > 0 {
        file write texfile " & `r2_`k''"
    }
    else {
        file write texfile " & ---"
    }
}
file write texfile " \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{6}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Standard errors clustered by household" _n
file write texfile " in brackets (paper uses bootstrapped SE, 200 reps)." _n
file write texfile " Regressions include log household income, log assets," _n
file write texfile " a cubic in the head's age, the head's education," _n
file write texfile " province-year indicators, and a constant." _n
file write texfile " Sample: households in state-owned housing in 1993." _n
file write texfile " $\Delta_i$ is the prereform housing mismatch" _n
file write texfile " (predicted $-$ actual log rental value)." _n
file write texfile " *** Significant at 1\%, ** 5\%, * 10\%.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table5a.tex created"


* --- twowayfeweights summary table ---
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition}" _n
file write texfile "\label{tab:twfe}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\toprule" _n
file write texfile "Statistic & Value \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{2}{l}{\textit{Panel: Log floor space (Column 1)}} \\" _n
file write texfile "\addlinespace" _n
file write texfile "Type & feTR (sharp design) \\" _n
file write texfile "Group ($G$) & Province \\" _n
file write texfile "Time ($T$) & Year \\" _n
file write texfile "Treatment ($D$) & Post $\times$ Mismatch \\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for full decomposition results.}} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"


* --- Master document ---
cap file close texfile
file open texfile using "$outdir/wang_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize," _n
file write texfile "  justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Wang (2011)}\\" _n
file write texfile "{\large State Misallocation and Housing Prices:}\\" _n
file write texfile "{\large Theory and Evidence from China}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}," _n
file write texfile " 101(5), 2081--2107}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n

file write texfile "\input{table5a}" _n _n
file write texfile "\clearpage" _n
file write texfile "\input{table_twowayfeweights}" _n _n

file write texfile "\end{document}" _n
file close texfile

di "  -> wang_tables.tex created"


/*==============================================================================
  VERIFICATION SUMMARY
==============================================================================*/

di _n "=============================================="
di    "VERIFICATION vs Paper Table 5 Panel A"
di    "=============================================="

forvalues k = 1/5 {
    cap estimates restore col`k'
    if !_rc {
        local our_b = _b[_IregXlog_m_1]
        di "Col `k' (`deplab`k''):"
        di "  Post×Δ: " %7.3f `our_b' " (paper: `paper_b`k'')"
        di "  N:      " e(N) " (paper: `paper_n`k'')"
        di "  R²:     " %5.2f e(r2_a) " (paper: `paper_r`k'')"
    }
}


di _n "=============================================="
di    "ALL DONE - Wang (2011)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table5a.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/wang_tables.tex (compilable)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
