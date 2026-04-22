/*==============================================================================
  HORNBECK (2012) - "The Enduring Impact of the American Dust Bowl:
  Short- and Long-Run Adjustments to Environmental Catastrophe"
  American Economic Review, 102(4), 1477-1507

  Pipeline: STEP 1 Data -> STEP 2 Table 2 -> STEP 3 twowayfeweights -> STEP 4 LaTeX

  dCDH Web Appendix #26: Table 2, Regression 1 with controls, feTR
  "The stable groups assumption is satisfied: many counties have 0% of
   their land situated in medium or high erosion regions."
  Fuzzy design: treatments are whether a piece of land is in high/medium
  erosion, varying within (county,year) cells.

  Specification (Table 2 Col 1, simplified for TWFE):
    Y_ct = alpha_c + gamma_t + beta * D_post_ct + eps_ct
    where D_post = m1_2 * I(year > 1930)

  Full paper spec uses state x year FE and many controls (areg with
  absorb(id_stateyear)), but twowayfeweights requires county + year FE.

  Panel: 779 counties x 18 years (1910-1997) in 12 Dust Bowl states
  Treatment: share of county land in high erosion regions (m1_2)
==============================================================================*/

clear all
set more off
set matsize 5000
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Hornbeck (2012)"
global datadir  "$paperdir/AER-2009-1347_Data_Code/Analyze-Data"
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
  Follows original Analyze_DustBowl.do variable creation pipeline:
  1. Keep 12 Dust Bowl states, drop 1935
  2. Create outcome: value_landbuildings_f = ln(value_landbuildings/farmland)
  3. Balance sample (15 years of non-missing outcome)
  4. Drop non-Plains counties (frac_grassland_tot < 0.5)
  5. Create farmland_weight (1930 farmland acres)
  6. Create id_stateyear
  7. Create time-varying treatment D_post
==============================================================================*/

use "$datadir/DustBowl_All_base1910.dta", clear

di _n "=== RAW DATA SUMMARY ==="
di "Observations: " _N
desc, short

* Keep only 12 Dust Bowl states (following original code line 45)
keep if state==8|state==19|state==20|state==27|state==30|state==31| ///
        state==35|state==38|state==40|state==46|state==48|state==56

* Drop year 1935 (not used in main analysis)
drop if year == 1935

* Drop missing farmland (line 72)
drop if farmland == .

* Fill in missing county_acres (lines 51-53)
sort fips year
by fips: replace county_acres = county_acres[_n+1] if county_acres==.
by fips: replace county_acres = county_acres[_n+1] if county_acres==.
by fips: replace county_acres = county_acres[_n-1] if county_acres==.

* Create outcome variable: log value of farmland+buildings per acre (line 94)
gen value_landbuildings_f = ln(value_landbuildings/farmland)
* Drop outlier errors (line 96)
replace value_landbuildings_f = . if value_landbuildings_f < -1

* Balance sample: need 15 years of non-missing value_landbuildings_f
* (following original lines 131-158, simplified)
replace value_landbuildings_f = . if year==1974
sort fips
by fips: egen balance_vlf = count(value_landbuildings_f)
drop if balance_vlf != 15
drop balance_vlf

* Drop non-Plains counties (line 161)
cap drop if frac_grassland_tot < .5
* Drop non-contiguous counties (line 163)
cap drop if fips==48043 | fips==48243 | fips==35013 | fips==35017 | fips==30007

* Generate farmland weight: 1930 baseline farmland acres (lines 182-186)
gen farmland_w = farmland if year==1930
sort fips year
by fips: egen farmland_weight = max(farmland_w)
drop farmland_w

* Generate state x year ID (line 192)
gen double id_stateyear = state*10000 + year

di _n "--- Panel structure ---"
qui tab fips
di "Counties (G): " r(r)
qui tab year
di "Years (T): " r(r)
tab year
di ""
di "--- Erosion variables (treatment) ---"
di "m1_0 = share in LOW erosion (<25% topsoil loss)"
di "m1_1 = share in MEDIUM erosion (25-75% topsoil loss)"
di "m1_2 = share in HIGH erosion (>75% topsoil loss)"
summ m1_0 m1_1 m1_2
di ""
di "--- Outcome: value_landbuildings_f (log value farmland+buildings/acre) ---"
summ value_landbuildings_f
di ""
di "--- Weight: farmland_weight (county farmland acres, 1930) ---"
summ farmland_weight

* --- Create time-varying treatment ---
* D_post = m1_2 * I(year > 1930): captures post-Dust Bowl effect
* of high erosion intensity
gen D_high_post = m1_2 * (year > 1930)
gen D_med_post  = m1_1 * (year > 1930)
label var D_high_post "High erosion x post-1930"
label var D_med_post  "Medium erosion x post-1930"

di _n "--- Time-varying treatment summary ---"
di "D_high_post (m1_2 * I(year>1930)):"
tab year, summ(D_high_post)
di ""
di "D_med_post (m1_1 * I(year>1930)):"
tab year, summ(D_med_post)

* --- Sample restriction: keep counties with non-missing weight ---
drop if farmland_weight == . | farmland_weight == 0
qui tab fips
di _n "After sample restrictions: " _N " obs, " r(r) " counties"


/*==============================================================================
  STEP 2: TABLE 2 -- SHORT/LONG-RUN AGRICULTURAL ADJUSTMENTS

  Simplified TWFE specification (county + year FE):
    Y_ct = alpha_c + gamma_t + beta_h * D_high_post_ct
                              + beta_m * D_med_post_ct + eps_ct

  Notes: The full paper spec uses state x year FE, baseline controls
  interacted with year, and lagged controls. The simplified version
  below is for twowayfeweights decomposition.

  Also run the full paper spec for comparison (areg with id_stateyear).
==============================================================================*/

di _n "=============================================="
di    "TABLE 2: AGRICULTURAL ADJUSTMENTS"
di    "=============================================="

* --- Panel A: Simplified TWFE (county + year FE) ---
di _n "--- Simplified TWFE (county + year FE) ---"
di "  Used for twowayfeweights decomposition"
xtreg value_landbuildings_f D_high_post D_med_post i.year ///
    [aweight=farmland_weight], fe i(fips) cluster(fips)
local b_h1  = _b[D_high_post]
local se_h1 = _se[D_high_post]
local b_m1  = _b[D_med_post]
local se_m1 = _se[D_med_post]
local nn_1  = e(N)
local ng_1  = e(N_g)
di "  beta(D_high_post) = " %7.3f `b_h1' " (" %5.3f `se_h1' ")"
di "  beta(D_med_post)  = " %7.3f `b_m1' " (" %5.3f `se_m1' ")"
di "  N = " `nn_1' ", counties = " `ng_1'

* --- Panel B: Same without weights ---
di _n "--- Simplified TWFE, unweighted ---"
xtreg value_landbuildings_f D_high_post D_med_post i.year, ///
    fe i(fips) cluster(fips)
local b_h2  = _b[D_high_post]
local se_h2 = _se[D_high_post]
local b_m2  = _b[D_med_post]
local se_m2 = _se[D_med_post]
local nn_2  = e(N)
di "  beta(D_high_post) = " %7.3f `b_h2' " (" %5.3f `se_h2' ")"
di "  beta(D_med_post)  = " %7.3f `b_m2' " (" %5.3f `se_m2' ")"

* --- Panel C: Full paper spec with state x year FE ---
di _n "--- Full paper spec (state x year FE) ---"
cap confirm variable id_stateyear
if !_rc {
    areg value_landbuildings_f D_high_post D_med_post ///
        [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
    local b_h3  = _b[D_high_post]
    local se_h3 = _se[D_high_post]
    local b_m3  = _b[D_med_post]
    local se_m3 = _se[D_med_post]
    local nn_3  = e(N)
    di "  beta(D_high_post) = " %7.3f `b_h3' " (" %5.3f `se_h3' ")"
    di "  beta(D_med_post)  = " %7.3f `b_m3' " (" %5.3f `se_m3' ")"
}
else {
    di "  id_stateyear not found - skipping state x year FE spec"
    local b_h3  = .
    local se_h3 = .
    local b_m3  = .
    local se_m3 = .
    local nn_3  = .
}

* --- Panel D: High erosion only (no medium) ---
di _n "--- TWFE with high erosion only ---"
xtreg value_landbuildings_f D_high_post i.year ///
    [aweight=farmland_weight], fe i(fips) cluster(fips)
local b_h4  = _b[D_high_post]
local se_h4 = _se[D_high_post]
local nn_4  = e(N)
di "  beta(D_high_post) = " %7.3f `b_h4' " (" %5.3f `se_h4' ")"


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  feTR: Y = value_landbuildings_f, G = fips, T = year
  D = D_high_post (= m1_2 * I(year > 1930))
  other_treatments: D_med_post (= m1_1 * I(year > 1930))

  Sharp-like design: many counties with 0% land in high erosion (D=0 always)
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- A1: feTR with D_high_post, weighted ---
di _n "=============================================="
di    "A1: feTR -- D_high_post, weighted by farmland"
di    "=============================================="
di "  Y = value_landbuildings_f, G = fips, T = year"
di "  D = D_high_post, other = D_med_post"
di ""
cap noisily twowayfeweights value_landbuildings_f fips year D_high_post, ///
    type(feTR) other_treatments(D_med_post) ///
    weight(farmland_weight) summary_measures

* --- A2: feTR with D_high_post only, weighted ---
di _n "=============================================="
di    "A2: feTR -- D_high_post only (no other_treatments)"
di    "=============================================="
cap noisily twowayfeweights value_landbuildings_f fips year D_high_post, ///
    type(feTR) weight(farmland_weight) summary_measures

* --- A3: feTR unweighted ---
di _n "=============================================="
di    "A3: feTR -- D_high_post, unweighted"
di    "=============================================="
cap noisily twowayfeweights value_landbuildings_f fips year D_high_post, ///
    type(feTR) other_treatments(D_med_post) summary_measures


/*==============================================================================
  STEP 4: LATEX TABLES
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* ===== TABLE 2 (Simplified) =====
cap file close texfile
file open texfile using "$outdir/table2_simplified.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Table 2---Effects of Dust Bowl Erosion on Land Values (Simplified TWFE)}" _n
file write texfile "\label{tab:table2}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & Weighted & Unweighted & State\$\times\$Year FE & High only \\" _n
file write texfile " & (1) & (2) & (3) & (4) \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{5}{l}{\textit{Dep.\ var.: ln(value farmland + buildings / acre)}} \\" _n
file write texfile "\addlinespace" _n

* High erosion row
local bh1 : di %7.3f `b_h1'
local bh1 = strtrim("`bh1'")
_stars `b_h1' `se_h1'
local sh1 "`r(s)'"
local bh2 : di %7.3f `b_h2'
local bh2 = strtrim("`bh2'")
_stars `b_h2' `se_h2'
local sh2 "`r(s)'"
local bh4 : di %7.3f `b_h4'
local bh4 = strtrim("`bh4'")
_stars `b_h4' `se_h4'
local sh4 "`r(s)'"

if `b_h3' < . {
    local bh3 : di %7.3f `b_h3'
    local bh3 = strtrim("`bh3'")
    _stars `b_h3' `se_h3'
    local sh3 "`r(s)'"
}
else {
    local bh3 "--"
    local sh3 ""
}

file write texfile "High erosion \$\times\$ post-1930"
file write texfile " & `bh1'`sh1' & `bh2'`sh2' & `bh3'`sh3' & `bh4'`sh4' \\" _n

* SEs
local seh1 : di %7.3f `se_h1'
local seh1 = strtrim("`seh1'")
local seh2 : di %7.3f `se_h2'
local seh2 = strtrim("`seh2'")
local seh4 : di %7.3f `se_h4'
local seh4 = strtrim("`seh4'")

if `se_h3' < . {
    local seh3 : di %7.3f `se_h3'
    local seh3 = strtrim("`seh3'")
}
else {
    local seh3 "--"
}

file write texfile " & (`seh1') & (`seh2') & (`seh3') & (`seh4') \\" _n
file write texfile "\addlinespace" _n

* Medium erosion row
local bm1 : di %7.3f `b_m1'
local bm1 = strtrim("`bm1'")
_stars `b_m1' `se_m1'
local sm1 "`r(s)'"
local bm2 : di %7.3f `b_m2'
local bm2 = strtrim("`bm2'")
_stars `b_m2' `se_m2'
local sm2 "`r(s)'"

if `b_m3' < . {
    local bm3 : di %7.3f `b_m3'
    local bm3 = strtrim("`bm3'")
    _stars `b_m3' `se_m3'
    local sm3 "`r(s)'"
}
else {
    local bm3 "--"
    local sm3 ""
}

file write texfile "Medium erosion \$\times\$ post-1930"
file write texfile " & `bm1'`sm1' & `bm2'`sm2' & `bm3'`sm3' & \\" _n

local sem1 : di %7.3f `se_m1'
local sem1 = strtrim("`sem1'")
local sem2 : di %7.3f `se_m2'
local sem2 = strtrim("`sem2'")

if `se_m3' < . {
    local sem3 : di %7.3f `se_m3'
    local sem3 = strtrim("`sem3'")
}
else {
    local sem3 "--"
}

file write texfile " & (`sem1') & (`sem2') & (`sem3') & \\" _n
file write texfile "\addlinespace" _n

file write texfile "County FE & Y & Y & & Y \\" _n
file write texfile "Year FE & Y & Y & & Y \\" _n
file write texfile "State \$\times\$ Year FE & & & Y & \\" _n
file write texfile "Weighted (farmland) & Y & & Y & Y \\" _n
file write texfile "\addlinespace" _n

local nfmt : di %6.0fc `nn_1'
local nfmt = strtrim("`nfmt'")
local gfmt : di %6.0fc `ng_1'
local gfmt = strtrim("`gfmt'")
file write texfile "Observations & `nfmt' & `nfmt' & `nfmt' & `nfmt' \\" _n
file write texfile "Counties & `gfmt' & `gfmt' & `gfmt' & `gfmt' \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{5}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Simplified two-way FE regressions for weight decomposition." _n
file write texfile " Full paper uses state\$\times\$year FE and 1930 baseline controls." _n
file write texfile " High/Medium erosion = share of county land in high/medium erosion areas" _n
file write texfile " (from 1930s Soil Conservation Service maps)." _n
file write texfile " Robust standard errors clustered by county in parentheses." _n
file write texfile " *** Significant at 1\%, ** 5\%, * 10\%.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table2_simplified.tex created"

* ===== TWOWAYFEWEIGHTS SUMMARY =====
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:twowayfe}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\toprule" _n
file write texfile "\multicolumn{2}{l}{\textit{Specification: Table 2, simplified (feTR)}} \\" _n
file write texfile "\midrule" _n
file write texfile "Regression type & Fixed effects (feTR) \\" _n
file write texfile "Dependent variable & ln(farmland value / acre) \\" _n
file write texfile "Treatment variable & High erosion share \$\times\$ post-1930 \\" _n
file write texfile "Other treatment & Medium erosion share \$\times\$ post-1930 \\" _n
file write texfile "Group (G) & County (FIPS) \\" _n
file write texfile "Time (T) & Year (1910--1997) \\" _n
file write texfile "Design & Fuzzy (erosion varies within county) \\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for detailed weight distribution}} \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/hornbeck_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Hornbeck (2012)}\\" _n
file write texfile "{\large The Enduring Impact of the American Dust Bowl:}\\" _n
file write texfile "{\large Short- and Long-Run Adjustments to}\\" _n
file write texfile "{\large Environmental Catastrophe}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 102(4), 1477--1507}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table2_simplified}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> hornbeck_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Hornbeck (2012)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table2_simplified.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/hornbeck_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
