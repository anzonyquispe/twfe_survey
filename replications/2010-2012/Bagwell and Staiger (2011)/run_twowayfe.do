/*==============================================================================
  BAGWELL & STAIGER (2011) - "What Do Trade Negotiators Negotiate About?
  Empirical Evidence from the World Trade Organization"
  AER, 101(4), 1238-1273

  Pipeline: STEP 1 Data → STEP 2 Table 3A OLS → STEP 3 twowayfeweights → STEP 4 LaTeX

  Regression specification (from Basic1.R):
    lm(TariffFinal ~ Import + TariffBase + as.factor(HS) + as.factor(Country) - 1)
    Stata: reg ... ibn.HS2 i.country_num, noconstant vce(robust)
    - noconstant + ibn.HS2 gives uncentered R², matching R's lm(... -1)
    - TariffFinal = WBND if available, else BND
    - TariffBase  = WMFN if available, else MFN
    - Import in millions (Import/1000)
    - HC1 robust standard errors
    - Drop if BND missing, Import<=0 or missing
    - Drop HS2 industries with <=2 observations
==============================================================================*/

clear all
set more off
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Bagwell and Staiger (2011)"
global datadir  "$paperdir/20061172_data"
global outdir   "$paperdir"

log using "$outdir/run_twowayfe.log", text replace

* Install packages if needed
cap which estout
if _rc ssc install estout, replace
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace


/*==============================================================================
  STEP 1: IMPORT AND CLEAN DATA
==============================================================================*/

import delimited using "$datadir/MainData.txt", delimiter(" ") clear

* Check variable names
desc

* Handle NA values - some columns may be imported as strings due to "NA"
* Force destring all numeric variables
foreach var of varlist mfn bnd wmfn wbnd import mismatch herf share {
    cap confirm string variable `var'
    if !_rc {
        destring `var', replace force
    }
}

* Create dependent variable: TariffFinal = WBND if available, else BND
gen TariffFinal = wbnd
replace TariffFinal = bnd if TariffFinal == .
label var TariffFinal "WTO Final Bound Rate"

* Create base tariff: TariffBase = WMFN if available, else MFN
gen TariffBase = wmfn
replace TariffBase = mfn if TariffBase == .
label var TariffBase "Pre-accession MFN Tariff"

* Create import in millions (matching R code: Import/1000)
gen Import_M = import / 1000
label var Import_M "Imports (millions)"

* Create HS2 code (first 2 digits of 6-digit HS product code)
gen HS2 = floor(product / 10000)
label var HS2 "HS2 Industry Code"

* Create MisMatch in millions (for Table 4 extension)
gen MisMatch_M = mismatch / 1000
label var MisMatch_M "Outsiders' Imports (millions)"

* Display raw data summary
summ product TariffFinal TariffBase Import_M HS2


/*==============================================================================
  STEP 1b: SAMPLE RESTRICTIONS (matching Basic1.R)
==============================================================================*/

* Drop observations without tariff bindings
drop if bnd == .

* Drop if Import is missing or <= 0
drop if Import_M == . | Import_M <= 0

* Drop if TariffFinal or TariffBase missing
drop if TariffFinal == .
drop if TariffBase == .

* Drop HS2 industries with <= 2 observations
bysort HS2: gen nobs_hs2 = _N
drop if nobs_hs2 <= 2
drop nobs_hs2

* Encode Country as numeric
encode country, gen(country_num)

* Summary after cleaning
di _n "=== SAMPLE AFTER CLEANING ==="
tab country_num
tab HS2
summ TariffFinal TariffBase Import_M
di "Number of observations: " _N


/*==============================================================================
  STEP 2: TABLE 3A OLS REGRESSIONS
  Equation (15a): τ_gc^WTO = α_G + α_c + β₁ τ_gc^BR + β₂ V_gc^BR + ε_gc
  R: lm(TariffFinal ~ Import + TariffBase + as.factor(HS) + as.factor(Country) - 1)
  Stata: reg ... ibn.HS2 i.country_num, noconstant vce(robust)
  noconstant + ibn gives uncentered R², matching R's lm(... -1)
  Paper Table 3A: R²=0.804 for All, 0.763 for HS0, etc.
==============================================================================*/

set matsize 2000

di _n "=============================================="
di    "TABLE 3A: OLS REGRESSIONS"
di    "=============================================="

* Helper program: compute significance stars from t-stat
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

* Industry labels
local lab0  "All"
local lab1  "HS0"
local lab2  "HS1"
local lab3  "HS2"
local lab4  "HS3"
local lab5  "HS4"
local lab6  "HS5"
local lab7  "HS6"
local lab8  "HS7"
local lab9  "HS8"
local lab10 "HS9"

* Industry product code bounds
local lo0 = 0
local hi0 = 1000000
forvalues j = 1/10 {
    local lo`j' = (`j' - 1) * 100000
    local hi`j' = `j' * 100000
}

* Initialize result storage
forvalues k = 0/10 {
    local b1_`k' = .
    local se1_`k' = .
    local b2_`k' = .
    local se2_`k' = .
    local r2_`k' = .
    local nn_`k' = 0
}

* --- Run regressions: All + 10 industries ---
forvalues k = 0/10 {
    * Build if-condition (empty for All)
    if `k' == 0 {
        local ifcond ""
    }
    else {
        local ifcond "if product >= `lo`k'' & product < `hi`k''"
    }

    di _n "--- `lab`k'' ---"
    qui count `ifcond'
    local nn_`k' = r(N)

    if `nn_`k'' > 20 {
        * Check TariffBase variance for subsample
        qui summ TariffBase `ifcond'
        local tvar = r(Var)
        local has_base = (`tvar' > 0)

        if `has_base' {
            cap noisily qui reg TariffFinal Import_M TariffBase ///
                ibn.HS2 i.country_num `ifcond', noconstant vce(robust)
        }
        else {
            cap noisily qui reg TariffFinal Import_M ///
                ibn.HS2 i.country_num `ifcond', noconstant vce(robust)
        }

        if !_rc & e(N) > 0 {
            if `has_base' {
                local b1_`k' = _b[TariffBase]
                local se1_`k' = _se[TariffBase]
            }
            local b2_`k' = _b[Import_M]
            local se2_`k' = _se[Import_M]
            local r2_`k' = e(r2)
            local nn_`k' = e(N)

            if `has_base' {
                di "  beta1 (TariffBase): " %9.4f `b1_`k'' " (" %7.4f `se1_`k'' ")"
            }
            di "  beta2 (Import_M):   " %9.4f `b2_`k'' " (" %7.4f `se2_`k'' ")"
            di "  R2:                 " %9.3f `r2_`k''
            di "  N:                  " %9,0gc `nn_`k''
        }
        else {
            di "  Regression failed"
            local nn_`k' = 0
        }
    }
    else {
        di "  Insufficient observations (`nn_`k'')"
        local nn_`k' = 0
    }
}

* --- Verification against paper ---
di _n "=============================================="
di    "VERIFICATION vs Paper Table 3A (OLS)"
di    "=============================================="
di "Sample   Our_R2   Paper_R2   Our_beta2   Paper_beta2"
di "All    " %7.3f `r2_0' "    0.804    " %9.4f `b2_0' "    -0.0044"
di "HS0    " %7.3f `r2_1' "    0.763    " %9.4f `b2_1' "    -0.0733"
di "HS1    " %7.3f `r2_2' "    0.783    " %9.4f `b2_2' "    -0.0476"
di "HS2    " %7.3f `r2_3' "    0.651    " %9.4f `b2_3' "    -0.0001"
di "HS3    " %7.3f `r2_4' "    0.868    " %9.4f `b2_4' "    -0.0044"
di "HS4    " %7.3f `r2_5' "    0.919    " %9.4f `b2_5' "    -0.0059"
di "HS5    " %7.3f `r2_6' "    0.955    " %9.4f `b2_6' "    -0.0055"
di "HS6    " %7.3f `r2_7' "    0.974    " %9.4f `b2_7' "    -0.0134"
di "HS7    " %7.3f `r2_8' "    0.906    " %9.4f `b2_8' "    -0.0111"
di "HS8    " %7.3f `r2_9' "    0.872    " %9.4f `b2_9' "    -0.0044"
di "HS9    " %7.3f `r2_10' "    0.886    " %9.4f `b2_10' "    -0.0112"


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION
  Y = TariffFinal, G = HS2, T = country_num, D = Import_M
  Controls = TariffBase
  Type = feTR (fixed effects, continuous treatment)
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

di _n "--- Type: feTR (Fixed Effects) ---"
cap noisily twowayfeweights TariffFinal HS2 country_num Import_M, ///
    type(feTR) controls(TariffBase)

* Capture results if available
cap local tw_npos = e(num_pos_weights)
cap local tw_nneg = e(num_neg_weights)

di _n "--- Type: fdTR (First Differences) ---"
cap noisily twowayfeweights TariffFinal HS2 country_num Import_M, ///
    type(fdTR) controls(TariffBase)


/*==============================================================================
  STEP 4: LATEX TABLE (AER format matching Paper Table 3A)
  Layout: Row per sample (All, HS0-HS9), Columns: Sample, N, β₁, β₂, R²
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

cap file close texfile
file open texfile using "$outdir/table3a.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\small" _n
file write texfile "\caption{Table 3A---Baseline Results}" _n
file write texfile "\label{tab:table3a}" _n
file write texfile "\begin{tabular}{lrccc}" _n
file write texfile "\toprule" _n
file write texfile "& & \multicolumn{3}{c}{OLS} \\" _n
file write texfile "\cmidrule(lr){3-5}" _n
file write texfile "Sample & Observations & \$\hat{\beta}_1\$ & \$\hat{\beta}_2\$ & R\$^2\$ \\" _n
file write texfile "\midrule" _n

forvalues k = 0/10 {
    if `nn_`k'' > 0 {
        * Format N with comma
        local nfmt : di %12,0gc `nn_`k''
        local nfmt = strtrim("`nfmt'")

        * Format R²
        local r2fmt : di %5.3f `r2_`k''
        local r2fmt = strtrim("`r2fmt'")

        * Format and star beta1 (TariffBase)
        if `b1_`k'' != . {
            local b1fmt : di %7.4f `b1_`k''
            local b1fmt = strtrim("`b1fmt'")
            local se1fmt : di %7.4f `se1_`k''
            local se1fmt = strtrim("`se1fmt'")
            _stars `b1_`k'' `se1_`k''
            local s1 "`r(s)'"
        }
        else {
            local b1fmt "---"
            local se1fmt "---"
            local s1 ""
        }

        * Format and star beta2 (Import_M)
        local b2fmt : di %7.4f `b2_`k''
        local b2fmt = strtrim("`b2fmt'")
        local se2fmt : di %7.4f `se2_`k''
        local se2fmt = strtrim("`se2fmt'")
        _stars `b2_`k'' `se2_`k''
        local s2 "`r(s)'"

        * Write coefficient row
        file write texfile "`lab`k'' & `nfmt' & `b1fmt'`s1' & `b2fmt'`s2' & `r2fmt' \\" _n

        * Write SE row
        if "`b1fmt'" != "---" {
            file write texfile " & & (`se1fmt') & (`se2fmt') & \\" _n
        }
        else {
            file write texfile " & & --- & (`se2fmt') & \\" _n
        }

        * Spacing between rows
        if `k' == 0 {
            file write texfile "\addlinespace[6pt]" _n
        }
        else if `k' < 10 {
            file write texfile "\addlinespace" _n
        }
    }
}

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{5}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Standard errors are in parentheses" _n
file write texfile " (heteroskedasticity-robust)." _n
file write texfile " Industry fixed effects, \$\alpha_G\$, are at the" _n
file write texfile " two-digit HS product level." _n
file write texfile " Country fixed effects, \$\alpha_c\$, included for all estimates." _n
file write texfile " \$\hat{\beta}_1\$: pre-accession MFN tariff." _n
file write texfile " \$\hat{\beta}_2\$: import value (millions)." _n
file write texfile " Equation: \$\tau_{gc}^{WTO} = \alpha_G + \alpha_c" _n
file write texfile " + \beta_1 \tau_{gc}^{BR} + \beta_2 V_{gc}^{BR} + \epsilon_{gc}\$." _n
file write texfile " *** Significant at the 1 percent level," _n
file write texfile " ** 5 percent level, * 10 percent level.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table3a.tex created"


* --- Master document ---
cap file close texfile
file open texfile using "$outdir/bagwell_staiger_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Bagwell \& Staiger (2011)}\\" _n
file write texfile "{\large What Do Trade Negotiators Negotiate About?}\\" _n
file write texfile "{\large Empirical Evidence from the World Trade Organization}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(4), 1238--1273}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n

file write texfile "\input{table3a}" _n _n

file write texfile "\end{document}" _n
file close texfile

di "  -> bagwell_staiger_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Bagwell & Staiger (2011)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table3a.tex"
di "  2. $outdir/bagwell_staiger_tables.tex (compilable)"
di "  3. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
