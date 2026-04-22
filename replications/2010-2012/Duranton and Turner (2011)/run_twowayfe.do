/*==============================================================================
  DURANTON & TURNER (2011) - "The Fundamental Law of Road Congestion:
  Evidence from US Cities"
  American Economic Review, 101(6), 2616-2652

  Pipeline: STEP 1 Data → STEP 2 Table 5A OLS → STEP 3 twowayfeweights → STEP 4 LaTeX

  dCDH Web Appendix #13: Table 5, Regression 2 (FD), sharp design, fdTR
  "The stable groups assumption is presumably satisfied: it is likely that
   between each pair of consecutive decades, there are some MSAs where the
   kilometers of roads do not change."

  Specification (column 1):
    Δln(VKT_IH) = β·Δln(lane_km_IH) + decade_dummy + ε,  cl(MSA)

  Panel: 228 MSAs × 2 pooled first differences (1983-93, 1993-03) = 456 obs
  Paper target: Col 1 β = 1.04 (0.05), R² = 0.87
==============================================================================*/

clear all
set more off
set matsize 2000
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Duranton and Turner (2011)"
global datadir  "$paperdir/data"
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
  Load wide data (275 MSAs × 213 vars), apply sample restrictions,
  compute first differences, reshape to long panel.
  Following original Duranton_Turner_AER_2010.do exactly.
==============================================================================*/

use "$datadir/Duranton_Turner_AER_2010.dta", clear

di _n "=== RAW DATA ==="
di "Observations: " _N
desc, short

* --- Sample restriction (same as original) ---
drop if l_ln_km_IH_83 == 0
di "After dropping l_ln_km_IH_83==0: " _N " MSAs remain"

* --- Rescale geography for display (same as original) ---
replace elevat_range_msa = elevat_range_msa / 1000
replace ruggedness_msa   = ruggedness_msa / 1000
replace heating_dd       = heating_dd / 100
replace cooling_dd       = cooling_dd / 100

* Save clean wide data BEFORE renames (for twowayfeweights in STEP 3)
tempfile clean_wide
save `clean_wide'

* --- Rename sprawl for reshape ---
rename sprawl_1992 sprawl_2003
rename sprawl_1976 sprawl_1993

* --- Generate first differences in wide format ---
gen Dl_ln_IH_1993  = l_ln_km_IH_93 - l_ln_km_IH_83
gen Dl_ln_IH_2003  = l_ln_km_IH_03 - l_ln_km_IH_93
gen Dl_vmt_IH_1993 = l_vmt_IH_93   - l_vmt_IH_83
gen Dl_vmt_IH_2003 = l_vmt_IH_03   - l_vmt_IH_93
gen Dl_pop_1993    = l_pop90        - l_pop80
gen Dl_pop_2003    = l_pop00        - l_pop90

* --- Rename lagged level variables for reshape ---
*     l_vmt_IH_1993 = 1983 level (lag for 83→93 FD period)
*     l_vmt_IH_2003 = 1993 level (lag for 93→03 FD period)
rename l_vmt_IH_83 l_vmt_IH_1993
rename l_vmt_IH_93 l_vmt_IH_2003

* --- Rename time-varying demographics for reshape ---
rename S_somecollege_80 S_somecollege_1993
rename S_somecollege_90 S_somecollege_2003
rename l_mean_income_80 l_mean_income_1993
rename l_mean_income_90 l_mean_income_2003
rename S_poor_80         S_poor_1993
rename S_poor_90         S_poor_2003
rename S_manuf83         S_manuf_1993
rename S_manuf93         S_manuf_2003

* --- Reshape to long panel (2 FD periods: 1993, 2003) ---
reshape long Dl_ln_IH Dl_vmt_IH l_vmt_IH ///
    sprawl S_somecollege l_mean_income S_poor S_manuf ///
    Dl_pop, i(msa) j(year _1993 _2003)

* Set panel identifier
iis msa

* Define control variable macros (same as original .do)
local geography    "elevat_range_msa ruggedness_msa heating_dd cooling_dd sprawl"
local demographics "S_somecollege l_mean_income seg1980_ghetto S_poor S_manuf"
local population   "l_pop80 l_pop70 l_pop60 l_pop50 l_pop40 l_pop30 l_pop20"
local census_div   "div1 div2 div3 div4 div5 div6 div7 div8 div9"

* Create convenience aliases for IH road type (same as original)
gen Dl_vmt = Dl_vmt_IH
gen Dl_ln  = Dl_ln_IH
gen l_vmt  = l_vmt_IH

di _n "=== PANEL DATA SUMMARY ==="
di "Observations: " _N
qui tab msa
di "MSAs: " r(r)
di "Periods: " _N / r(r)
summ Dl_vmt Dl_ln Dl_pop l_vmt


/*==============================================================================
  STEP 2: TABLE 5 PANEL A — OLS FIRST DIFFERENCES
  Dependent variable: Δln VKT for interstate highways, entire MSAs

  Paper verification targets:
    Col 1: β=1.04 (0.05), R²=0.87, N=456
    Col 2: β=1.05 (0.05), Δpop=0.34 (0.10), R²=0.87
    Col 3: β=1.02 (0.04), R²=0.89
    Col 4: β=1.00 (0.04), R²=0.90
    Col 5: β=0.93 (0.04), R²=0.91
    Col 6: β=1.09 (0.06), R²=0.91, N=205 (lane↑>5%)
    Col 7: β=0.90 (0.06), R²=0.94, N=205
    Col 8: β=0.82 (0.09), R²=0.69, N=115 (lane↓>5%)
    Col 9: β=1.03 (0.05), R²=0.91 (MSA FE)
    Col10: β=1.03 (0.05), R²=0.94 (MSA FE)
==============================================================================*/

di _n "=============================================="
di    "TABLE 5 PANEL A: OLS FIRST DIFFERENCES"
di    "=============================================="

* Initialize storage
forvalues k = 1/10 {
    local b_`k'      = .
    local se_`k'     = .
    local b_pop_`k'  = .
    local se_pop_`k' = .
    local b_vmt_`k'  = .
    local se_vmt_`k' = .
    local r2_`k'     = .
    local nn_`k'     = 0
}

* --- Column 1: Basic ---
di _n "--- Column 1: Basic ---"
xi: reg Dl_vmt Dl_ln i.year, cl(msa) robust
local b_1  = _b[Dl_ln]
local se_1 = _se[Dl_ln]
local r2_1 = e(r2)
local nn_1 = e(N)
di "  beta(Dl_ln) = " %7.4f `b_1' " (" %5.4f `se_1' "), R2 = " %5.2f `r2_1' ", N = " `nn_1'

* --- Column 2: + Population ---
di _n "--- Column 2: + Population ---"
xi: reg Dl_vmt Dl_ln Dl_pop i.year, cl(msa) robust
local b_2      = _b[Dl_ln]
local se_2     = _se[Dl_ln]
local b_pop_2  = _b[Dl_pop]
local se_pop_2 = _se[Dl_pop]
local r2_2     = e(r2)
local nn_2     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_2' " (" %5.4f `se_2' "), R2 = " %5.2f `r2_2'

* --- Column 3: + Lagged VKT ---
di _n "--- Column 3: + Lagged VKT ---"
xi: reg Dl_vmt Dl_ln Dl_pop l_vmt i.year, cl(msa) robust
local b_3      = _b[Dl_ln]
local se_3     = _se[Dl_ln]
local b_pop_3  = _b[Dl_pop]
local se_pop_3 = _se[Dl_pop]
local b_vmt_3  = _b[l_vmt]
local se_vmt_3 = _se[l_vmt]
local r2_3     = e(r2)
local nn_3     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_3' " (" %5.4f `se_3' "), R2 = " %5.2f `r2_3'

* --- Column 4: + Geography + Census divisions ---
di _n "--- Column 4: + Geography + Census ---"
xi: reg Dl_vmt Dl_ln Dl_pop l_vmt `geography' `census_div' i.year, cl(msa) robust
local b_4      = _b[Dl_ln]
local se_4     = _se[Dl_ln]
local b_pop_4  = _b[Dl_pop]
local se_pop_4 = _se[Dl_pop]
local b_vmt_4  = _b[l_vmt]
local se_vmt_4 = _se[l_vmt]
local r2_4     = e(r2)
local nn_4     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_4' " (" %5.4f `se_4' "), R2 = " %5.2f `r2_4'

* --- Column 5: Full controls ---
di _n "--- Column 5: Full controls ---"
xi: reg Dl_vmt Dl_ln Dl_pop l_vmt `geography' `census_div' `population' `demographics' i.year, cl(msa) robust
local b_5      = _b[Dl_ln]
local se_5     = _se[Dl_ln]
local b_pop_5  = _b[Dl_pop]
local se_pop_5 = _se[Dl_pop]
local b_vmt_5  = _b[l_vmt]
local se_vmt_5 = _se[l_vmt]
local r2_5     = e(r2)
local nn_5     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_5' " (" %5.4f `se_5' "), R2 = " %5.2f `r2_5'

* --- Column 6: Lane increases > 5%, basic ---
di _n "--- Column 6: Lane increases > 5% ---"
xi: reg Dl_vmt Dl_ln Dl_pop i.year if Dl_ln_IH > 0.05, cl(msa) robust
local b_6      = _b[Dl_ln]
local se_6     = _se[Dl_ln]
local b_pop_6  = _b[Dl_pop]
local se_pop_6 = _se[Dl_pop]
local r2_6     = e(r2)
local nn_6     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_6' " (" %5.4f `se_6' "), R2 = " %5.2f `r2_6' ", N = " `nn_6'

* --- Column 7: Lane increases > 5%, full controls ---
di _n "--- Column 7: Lane increases > 5%, full controls ---"
xi: reg Dl_vmt Dl_ln Dl_pop l_vmt `geography' `census_div' `population' `demographics' i.year if Dl_ln_IH > 0.05, cl(msa) robust
local b_7      = _b[Dl_ln]
local se_7     = _se[Dl_ln]
local b_pop_7  = _b[Dl_pop]
local se_pop_7 = _se[Dl_pop]
local r2_7     = e(r2)
local nn_7     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_7' " (" %5.4f `se_7' "), R2 = " %5.2f `r2_7' ", N = " `nn_7'

* --- Column 8: Lane decreases > 5%, full controls ---
di _n "--- Column 8: Lane decreases > 5% ---"
xi: reg Dl_vmt Dl_ln Dl_pop l_vmt `geography' `census_div' `population' `demographics' i.year if Dl_ln_IH < -0.05, cl(msa) robust
local b_8      = _b[Dl_ln]
local se_8     = _se[Dl_ln]
local b_pop_8  = _b[Dl_pop]
local se_pop_8 = _se[Dl_pop]
local r2_8     = e(r2)
local nn_8     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_8' " (" %5.4f `se_8' "), R2 = " %5.2f `r2_8' ", N = " `nn_8'

* --- Column 9: MSA fixed effects ---
di _n "--- Column 9: MSA fixed effects ---"
xi: reg Dl_vmt Dl_ln i.year i.msa, robust
local b_9  = _b[Dl_ln]
local se_9 = _se[Dl_ln]
local r2_9 = e(r2)
local nn_9 = e(N)
di "  beta(Dl_ln) = " %7.4f `b_9' " (" %5.4f `se_9' "), R2 = " %5.2f `r2_9'

* --- Column 10: MSA FE + Pop + Demographics ---
di _n "--- Column 10: MSA FE + controls ---"
xi: reg Dl_vmt Dl_ln Dl_pop `demographics' i.msa i.year, robust
local b_10      = _b[Dl_ln]
local se_10     = _se[Dl_ln]
local b_pop_10  = _b[Dl_pop]
local se_pop_10 = _se[Dl_pop]
local r2_10     = e(r2)
local nn_10     = e(N)
di "  beta(Dl_ln) = " %7.4f `b_10' " (" %5.4f `se_10' "), R2 = " %5.2f `r2_10'

* --- Verification against paper ---
di _n "=============================================="
di    "VERIFICATION vs Paper Table 5 Panel A"
di    "=============================================="
di "Col  Our_beta  Paper_beta  Our_SE  Paper_SE  Our_R2  Paper_R2  N"
di " 1   " %5.2f `b_1'  "      1.04      " %5.2f `se_1'  "    0.05    " %5.2f `r2_1'  "    0.87    " `nn_1'
di " 2   " %5.2f `b_2'  "      1.05      " %5.2f `se_2'  "    0.05    " %5.2f `r2_2'  "    0.87    " `nn_2'
di " 3   " %5.2f `b_3'  "      1.02      " %5.2f `se_3'  "    0.04    " %5.2f `r2_3'  "    0.89    " `nn_3'
di " 4   " %5.2f `b_4'  "      1.00      " %5.2f `se_4'  "    0.04    " %5.2f `r2_4'  "    0.90    " `nn_4'
di " 5   " %5.2f `b_5'  "      0.93      " %5.2f `se_5'  "    0.04    " %5.2f `r2_5'  "    0.91    " `nn_5'
di " 6   " %5.2f `b_6'  "      1.09      " %5.2f `se_6'  "    0.06    " %5.2f `r2_6'  "    0.91    " `nn_6'
di " 7   " %5.2f `b_7'  "      0.90      " %5.2f `se_7'  "    0.06    " %5.2f `r2_7'  "    0.94    " `nn_7'
di " 8   " %5.2f `b_8'  "      0.82      " %5.2f `se_8'  "    0.09    " %5.2f `r2_8'  "    0.69    " `nn_8'
di " 9   " %5.2f `b_9'  "      1.03      " %5.2f `se_9'  "    0.05    " %5.2f `r2_9'  "    0.91    " `nn_9'
di "10   " %5.2f `b_10' "      1.03      " %5.2f `se_10' "    0.05    " %5.2f `r2_10' "    0.94    " `nn_10'


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  For fdTR, twowayfeweights needs 5 variables (NOT 4):
    twowayfeweights DeltaY G T DeltaD D_level, type(fdTR)

  Where:
    DeltaY  = first difference of outcome (missing at initial period 1983)
    G       = group (msa)
    T       = time (1983, 1993, 2003)
    DeltaD  = first difference of treatment (missing at initial period 1983)
    D_level = treatment in LEVELS (non-missing at ALL periods including 1983)

  The initial period (1983) has DeltaY=. and DeltaD=. but D_level is non-missing.
  twowayfeweights uses D_level for natural weight computation and retains the
  initial period via:  keep if (T!=.&DY!=.&DD!=.) | D_level!=.

  The internal regression matches Table 5 Col 1:
    areg DeltaY DeltaD, absorb(year)  →  same β as reg Dl_vmt Dl_ln i.year
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* Reload clean wide data (before renames/reshape)
use `clean_wide', clear

* --- Create FIRST DIFFERENCES (missing at initial period) ---
gen DY_1983 = .
gen DY_1993 = l_vmt_IH_93 - l_vmt_IH_83
gen DY_2003 = l_vmt_IH_03 - l_vmt_IH_93

gen DD_1983 = .
gen DD_1993 = l_ln_km_IH_93 - l_ln_km_IH_83
gen DD_2003 = l_ln_km_IH_03 - l_ln_km_IH_93

* --- Create TREATMENT LEVELS (non-missing at ALL periods) ---
gen D0_1983 = l_ln_km_IH_83
gen D0_1993 = l_ln_km_IH_93
gen D0_2003 = l_ln_km_IH_03

* --- Reshape to long panel (3 periods) ---
keep msa DY_* DD_* D0_*
reshape long DY_ DD_ D0_, i(msa) j(year)
rename DY_ DY
rename DD_ DD
rename D0_ D0
sort msa year

di _n "=== PANEL FOR TWOWAYFEWEIGHTS (fdTR) ==="
di "Observations: " _N
qui tab msa
di "MSAs: " r(r)
di "Periods: 3 (1983, 1993, 2003)"
di ""
di "First differences (DY, DD): non-missing at 1993, 2003 only"
count if DY != .
di "  FD observations: " r(N)
di "Treatment levels (D0): non-missing at all periods"
count if D0 != .
di "  Level observations: " r(N)
di ""
summ DY DD D0

* --- Run twowayfeweights: fdTR with 5 arguments ---
di _n "=============================================="
di    "fdTR: Baseline (no controls, matching Col 1)"
di    "=============================================="
di "  Syntax: twowayfeweights DY msa year DD D0, type(fdTR)"
di "  DY = Delta ln(VKT_IH),  DD = Delta ln(lane_km_IH)"
di "  D0 = ln(lane_km_IH) in levels"
di ""
cap noisily twowayfeweights DY msa year DD D0, type(fdTR) summary_measures

* --- Also try feTR on levels panel for comparison ---
di _n "=============================================="
di    "feTR: Levels regression (for comparison)"
di    "=============================================="

* Reload clean wide data for feTR (needs levels of Y and D)
use `clean_wide', clear

gen Y_1983 = l_vmt_IH_83
gen Y_1993 = l_vmt_IH_93
gen Y_2003 = l_vmt_IH_03
gen D_1983 = l_ln_km_IH_83
gen D_1993 = l_ln_km_IH_93
gen D_2003 = l_ln_km_IH_03

keep msa Y_* D_*
reshape long Y_ D_, i(msa) j(year)
rename Y_ Y
rename D_ D
sort msa year

di "  Syntax: twowayfeweights Y msa year D, type(feTR)"
di ""
cap noisily twowayfeweights Y msa year D, type(feTR) summary_measures


/*==============================================================================
  STEP 4: LATEX TABLES
  Table 5A: Columns 1-5, 9-10 (main OLS specifications)
  Table TW:  twowayfeweights decomposition summary
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* ===== TABLE 5A: OLS First Differences (Columns 1-5, 9-10) =====
cap file close texfile
file open texfile using "$outdir/table5a.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\small" _n
file write texfile "\caption{Table 5---Change in VKT as a Function of Change in Lane Kilometers (Panel A: OLS)}" _n
file write texfile "\label{tab:table5a}" _n
file write texfile "\begin{tabular}{lccccccc}" _n
file write texfile "\toprule" _n
file write texfile " & (1) & (2) & (3) & (4) & (5) & (9) & (10) \\\\" _n
file write texfile "MSA sample & All & All & All & All & All & All & All \\\\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{8}{l}{\textit{Dep.\ var.: \$\Delta\$ln VKT for interstate highways, entire MSAs}} \\\\" _n
file write texfile "\addlinespace" _n

* --- Row: Δln(IH lane km) - coefficients ---
forvalues k = 1/5 {
    local bfmt_`k' : di %5.2f `b_`k''
    local bfmt_`k' = strtrim("`bfmt_`k''")
    _stars `b_`k'' `se_`k''
    local s_`k' "`r(s)'"
}
* Cols 9 and 10
local bfmt_9 : di %5.2f `b_9'
local bfmt_9 = strtrim("`bfmt_9'")
_stars `b_9' `se_9'
local s_9 "`r(s)'"
local bfmt_10 : di %5.2f `b_10'
local bfmt_10 = strtrim("`bfmt_10'")
_stars `b_10' `se_10'
local s_10 "`r(s)'"

file write texfile "\$\Delta\$ln (IH lane km)"
file write texfile " & `bfmt_1'`s_1' & `bfmt_2'`s_2' & `bfmt_3'`s_3' & `bfmt_4'`s_4' & `bfmt_5'`s_5' & `bfmt_9'`s_9' & `bfmt_10'`s_10' \\\\" _n

* --- Row: SEs ---
forvalues k = 1/5 {
    local sfmt_`k' : di %5.2f `se_`k''
    local sfmt_`k' = strtrim("`sfmt_`k''")
}
local sfmt_9 : di %5.2f `se_9'
local sfmt_9 = strtrim("`sfmt_9'")
local sfmt_10 : di %5.2f `se_10'
local sfmt_10 = strtrim("`sfmt_10'")

file write texfile " & (`sfmt_1') & (`sfmt_2') & (`sfmt_3') & (`sfmt_4') & (`sfmt_5') & (`sfmt_9') & (`sfmt_10') \\\\" _n

* --- Row: Δln(population) - coefficients ---
local p2 : di %5.2f `b_pop_2'
local p2 = strtrim("`p2'")
_stars `b_pop_2' `se_pop_2'
local sp2 "`r(s)'"
local p3 : di %5.2f `b_pop_3'
local p3 = strtrim("`p3'")
_stars `b_pop_3' `se_pop_3'
local sp3 "`r(s)'"
local p4 : di %5.2f `b_pop_4'
local p4 = strtrim("`p4'")
_stars `b_pop_4' `se_pop_4'
local sp4 "`r(s)'"
local p5 : di %5.2f `b_pop_5'
local p5 = strtrim("`p5'")
_stars `b_pop_5' `se_pop_5'
local sp5 "`r(s)'"
local p10 : di %5.2f `b_pop_10'
local p10 = strtrim("`p10'")
_stars `b_pop_10' `se_pop_10'
local sp10 "`r(s)'"

file write texfile "\$\Delta\$ln (population)"
file write texfile " & & `p2'`sp2' & `p3'`sp3' & `p4'`sp4' & `p5'`sp5' & & `p10'`sp10' \\\\" _n

* --- Row: population SEs ---
local sep2 : di %5.2f `se_pop_2'
local sep2 = strtrim("`sep2'")
local sep3 : di %5.2f `se_pop_3'
local sep3 = strtrim("`sep3'")
local sep4 : di %5.2f `se_pop_4'
local sep4 = strtrim("`sep4'")
local sep5 : di %5.2f `se_pop_5'
local sep5 = strtrim("`sep5'")
local sep10 : di %5.2f `se_pop_10'
local sep10 = strtrim("`sep10'")

file write texfile " & & (`sep2') & (`sep3') & (`sep4') & (`sep5') & & (`sep10') \\\\" _n

* --- Row: ln(initial VKT) ---
local v3 : di %6.3f `b_vmt_3'
local v3 = strtrim("`v3'")
_stars `b_vmt_3' `se_vmt_3'
local sv3 "`r(s)'"
local v4 : di %6.3f `b_vmt_4'
local v4 = strtrim("`v4'")
_stars `b_vmt_4' `se_vmt_4'
local sv4 "`r(s)'"
local v5 : di %6.3f `b_vmt_5'
local v5 = strtrim("`v5'")
_stars `b_vmt_5' `se_vmt_5'
local sv5 "`r(s)'"

file write texfile "ln (initial VKT)"
file write texfile " & & & `v3'`sv3' & `v4'`sv4' & `v5'`sv5' & & \\\\" _n

* SEs for initial VKT
local sev3 : di %6.3f `se_vmt_3'
local sev3 = strtrim("`sev3'")
local sev4 : di %6.3f `se_vmt_4'
local sev4 = strtrim("`sev4'")
local sev5 : di %6.3f `se_vmt_5'
local sev5 = strtrim("`sev5'")

file write texfile " & & & (`sev3') & (`sev4') & (`sev5') & & \\\\" _n

file write texfile "\addlinespace" _n

* --- Control indicator rows ---
file write texfile "Geography             & & & & Y & Y & & \\\\" _n
file write texfile "Census divisions      & & & & Y & Y & & \\\\" _n
file write texfile "Socioeconomic char.   & & & & & Y & & Y \\\\" _n
file write texfile "Past populations      & & & & & Y & & \\\\" _n
file write texfile "MSA fixed effects     & & & & & & Y & Y \\\\" _n

file write texfile "\addlinespace" _n

* --- R² row ---
local r1 : di %5.2f `r2_1'
local r1 = strtrim("`r1'")
local r2 : di %5.2f `r2_2'
local r2 = strtrim("`r2'")
local r3 : di %5.2f `r2_3'
local r3 = strtrim("`r3'")
local r4 : di %5.2f `r2_4'
local r4 = strtrim("`r4'")
local r5 : di %5.2f `r2_5'
local r5 = strtrim("`r5'")
local r9 : di %5.2f `r2_9'
local r9 = strtrim("`r9'")
local r10 : di %5.2f `r2_10'
local r10 = strtrim("`r10'")

file write texfile "\$R^2\$ & `r1' & `r2' & `r3' & `r4' & `r5' & `r9' & `r10' \\\\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{8}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Robust standard errors clustered by MSA in parentheses" _n
file write texfile " (columns 1--5). Heteroskedasticity-robust in columns 9--10 (MSA fixed effects)." _n
file write texfile " 456 observations (228 MSAs \$\times\$ 2 decades) in all columns." _n
file write texfile " All regressions include a constant and decade effects." _n
file write texfile " *** Significant at 1\%, ** 5\%, * 10\%.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table5a.tex created"


* ===== TWOWAYFEWEIGHTS SUMMARY TABLE =====
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:twowayfe}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\toprule" _n
file write texfile "\multicolumn{2}{l}{\textit{Specification: Table 5 Column 1 (fdTR)}} \\\\" _n
file write texfile "\midrule" _n
file write texfile "Regression type & First differences (fdTR) \\\\" _n
file write texfile "Dependent variable & \$\Delta\$ln(VKT\textsubscript{IH}) \\\\" _n
file write texfile "Treatment variable & \$\Delta\$ln(lane km\textsubscript{IH}) \\\\" _n
file write texfile "Group (G) & MSA \\\\" _n
file write texfile "Time (T) & Decade (1983, 1993, 2003) \\\\" _n
file write texfile "Observations & 228 MSAs \$\times\$ 3 periods = 684 \\\\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for detailed weight distribution}} \\\\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"


* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/duranton_turner_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Duranton \& Turner (2011)}\\\\" _n
file write texfile "{\large The Fundamental Law of Road Congestion:}\\\\" _n
file write texfile "{\large Evidence from US Cities}\\\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(6), 2616--2652}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table5a}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> duranton_turner_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Duranton & Turner (2011)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table5a.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/duranton_turner_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
