/*==============================================================================
  BAUM-SNOW AND LUTZ (2011) - "School Desegregation, School Choice,
  and Changes in Residential Location Patterns by Race"
  American Economic Review, 101(7), 3019-3046

  Pipeline: STEP 1 Data -> STEP 2 Replicate Tables 2,4 -> STEP 3 twowayfeweights -> STEP 4 LaTeX

  TWFE Specification (Table 2, Col 1):
    xtreg lnwpu imp_post i.year*i.south, fe i(leaid) cluster(leaid)

  Simplified for twowayfeweights (drop year*south interaction):
    xtreg lnwpu imp_post i.year, fe i(leaid) cluster(leaid)

  Treatment: imp_post = I(year >= desegregation year)
  Unit FE: leaid (school district)
  Time FE: year (1960, 1970, 1980, 1990)
  Outcome: lnwpu = ln(white public K-12 enrollment)
==============================================================================*/

clear all
set more off
set matsize 5000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Baum-SnowandLutz(2011)/MS20080918_data_programs/data"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Baum-SnowandLutz(2011)"
global latexdir "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex/2010-2012/Baum-SnowandLutz(2011)"

* NOTE: log is auto-created by Stata -b mode (run_twowayfe.log)

* Install packages if needed
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace

cap which reghdfe
if _rc ssc install reghdfe, replace

cap which estout
if _rc ssc install estout, replace

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
  Following tables2to5.do variable creation pipeline
==============================================================================*/

use "$datadir/dis70panx.dta", clear

di _n "=== RAW DATA ==="
di "Observations: " _N

* Keep major desegregation districts
keep if major==1
replace imp = imp + 1900

* Make enrollment measures consistent over time
replace publicelemhsw = publicelemw + publichsw if year ~= 1990
replace publicelemhsb = publicelemb + publichsb if year ~= 1990
replace publicelemhst = publicelemt + publichst if year ~= 1990
replace privatelemhsw = privatelemw + privatehsw if year ~= 1990
replace privatelemhsb = privatelemb + privatehsb if year ~= 1990
replace privatelemhst = privatelemt + privatehst if year ~= 1990

* Create treatment variables
gen imp_post    = (year >= imp)
gen impost_0_3  = (year >= imp) & (year <= imp + 3)
gen impost_4    = (year >= imp + 4)
gen nonsouth    = (south==0)

* Create outcomes
gen lnwpu = ln(publicelemhsw)
gen lnbpu = ln(publicelemhsb)
gen lnwpr = ln(privatelemhsw)
gen lnbpr = ln(privatelemhsb)
gen lnwto = ln(white)
gen lnbto = ln(black)

di _n "--- Panel structure ---"
qui tab leaid
local n_units = r(r)
di "School districts (G): " `n_units'
qui tab year
local n_periods = r(r)
di "Years (T): " `n_periods'
tab year
di "N = " _N

di _n "--- Treatment variation ---"
tab year imp_post
bys leaid: egen ever_treated = max(imp_post)
qui tab leaid if ever_treated == 1
di "Districts ever treated: " r(r)
qui tab leaid if ever_treated == 0
di "Districts never treated: " r(r)

di _n "--- Outcomes ---"
sum lnwpu lnbpu lnwpr lnbpr lnwto lnbto


/*==============================================================================
  STEP 2: REPLICATE TABLE 2 AND TABLE 4
  Table 2 Col 1: White Public, imp_post, year*south FE
  Table 4 Col 1: Black Public, imp_post, year*south FE
==============================================================================*/

di _n "=============================================="
di    "TABLE REPLICATION"
di    "=============================================="

* --- Table 2, Col 1: White public enrollment ---
di _n "--- Table 2, Col 1: White Public ---"
di "  Original spec: xtreg lnwpu imp_post i.year*i.south, fe i(leaid) cluster(leaid)"
xi: xtreg lnwpu imp_post i.year*i.south, fe i(leaid) cluster(leaid)
local b_t2c1  = _b[imp_post]
local se_t2c1 = _se[imp_post]
local n_t2c1  = e(N)
local ng_t2c1 = e(N_g)
di "  beta = " %7.4f `b_t2c1' " (" %5.4f `se_t2c1' "), N = " `n_t2c1'
estimates store t2c1

* --- Table 2, Col 1 SIMPLIFIED (for twowayfeweights) ---
di _n "--- Table 2, Col 1 SIMPLIFIED (no year*south) ---"
xtreg lnwpu imp_post i.year, fe i(leaid) cluster(leaid)
local b_t2s   = _b[imp_post]
local se_t2s  = _se[imp_post]
local n_t2s   = e(N)
di "  beta = " %7.4f `b_t2s' " (" %5.4f `se_t2s' "), N = " `n_t2s'
estimates store t2s

* --- Table 4, Col 1: Black public enrollment ---
di _n "--- Table 4, Col 1: Black Public ---"
xi: xtreg lnbpu imp_post i.year*i.south, fe i(leaid) cluster(leaid)
local b_t4c1  = _b[imp_post]
local se_t4c1 = _se[imp_post]
local n_t4c1  = e(N)
di "  beta = " %7.4f `b_t4c1' " (" %5.4f `se_t4c1' "), N = " `n_t4c1'
estimates store t4c1

* --- Table 4, Col 1 SIMPLIFIED ---
di _n "--- Table 4, Col 1 SIMPLIFIED ---"
xtreg lnbpu imp_post i.year, fe i(leaid) cluster(leaid)
local b_t4s   = _b[imp_post]
local se_t4s  = _se[imp_post]
local n_t4s   = e(N)
di "  beta = " %7.4f `b_t4s' " (" %5.4f `se_t4s' "), N = " `n_t4s'
estimates store t4s


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- feTR: White public enrollment ---
di _n "=== feTR: lnwpu ~ imp_post ==="
cap scalar drop nplus nminus beta sumpositive sumnegative
cap noisily twowayfeweights lnwpu leaid year imp_post, type(feTR) summary_measures
local rc_fetr_w = _rc

local fetr_w_ok = 0
if `rc_fetr_w' == 0 | `rc_fetr_w' == 402 {
    cap local fetr_w_beta = e(beta)
    cap mat M = e(M)
    if _rc == 0 {
        local fetr_w_npos = el(M,1,1)
        local fetr_w_nneg = el(M,2,1)
        local fetr_w_ok = 1
    }
    else {
        cap local fetr_w_npos = scalar(nplus)
        cap local fetr_w_nneg = scalar(nminus)
        if `fetr_w_npos' != . & `fetr_w_nneg' != . {
            local fetr_w_ok = 1
        }
    }
}
else {
    cap local fetr_w_beta = scalar(beta)
    cap local fetr_w_npos = scalar(nplus)
    cap local fetr_w_nneg = scalar(nminus)
    if `fetr_w_npos' != . & `fetr_w_nneg' != . {
        local fetr_w_ok = 1
    }
}

if `fetr_w_ok' == 1 {
    local fetr_w_pneg = 100 * `fetr_w_nneg' / (`fetr_w_npos' + `fetr_w_nneg')
    di _n "feTR white: beta=" %9.6f `fetr_w_beta' " npos=" %6.0f `fetr_w_npos' " nneg=" %6.0f `fetr_w_nneg' " %neg=" %5.1f `fetr_w_pneg' "%"
}
else {
    di "feTR white: FAILED (rc=`rc_fetr_w')"
}

* --- feTR: Black public enrollment ---
di _n "=== feTR: lnbpu ~ imp_post ==="
cap scalar drop nplus nminus beta sumpositive sumnegative
cap noisily twowayfeweights lnbpu leaid year imp_post, type(feTR) summary_measures
local rc_fetr_b = _rc

local fetr_b_ok = 0
if `rc_fetr_b' == 0 | `rc_fetr_b' == 402 {
    cap local fetr_b_beta = e(beta)
    cap mat M = e(M)
    if _rc == 0 {
        local fetr_b_npos = el(M,1,1)
        local fetr_b_nneg = el(M,2,1)
        local fetr_b_ok = 1
    }
    else {
        cap local fetr_b_npos = scalar(nplus)
        cap local fetr_b_nneg = scalar(nminus)
        if `fetr_b_npos' != . & `fetr_b_nneg' != . {
            local fetr_b_ok = 1
        }
    }
}
else {
    cap local fetr_b_beta = scalar(beta)
    cap local fetr_b_npos = scalar(nplus)
    cap local fetr_b_nneg = scalar(nminus)
    if `fetr_b_npos' != . & `fetr_b_nneg' != . {
        local fetr_b_ok = 1
    }
}

if `fetr_b_ok' == 1 {
    local fetr_b_pneg = 100 * `fetr_b_nneg' / (`fetr_b_npos' + `fetr_b_nneg')
    di _n "feTR black: beta=" %9.6f `fetr_b_beta' " npos=" %6.0f `fetr_b_npos' " nneg=" %6.0f `fetr_b_nneg' " %neg=" %5.1f `fetr_b_pneg' "%"
}
else {
    di "feTR black: FAILED (rc=`rc_fetr_b')"
}


/*==============================================================================
  STEP 4: LATEX TABLES
==============================================================================*/

di _n "=============================================="
di    "LaTeX TABLE EXPORT"
di    "=============================================="

* ===== TABLE: Replication =====
cap file close texfile
file open texfile using "$outdir/table2_replication.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Replication of Tables 2 and 4 --- Baum-Snow and Lutz (2011)}" _n
file write texfile "\label{tab:baumsnow_replication}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & \multicolumn{2}{c}{White Public (Table 2)} & \multicolumn{2}{c}{Black Public (Table 4)} \\" _n
file write texfile " & Original & Simplified & Original & Simplified \\" _n
file write texfile " & (1) & (2) & (3) & (4) \\" _n
file write texfile "\midrule" _n

* imp_post row
local b1 : di %7.4f `b_t2c1'
local b1 = strtrim("`b1'")
_stars `b_t2c1' `se_t2c1'
local s1 "`r(s)'"
local b2 : di %7.4f `b_t2s'
local b2 = strtrim("`b2'")
_stars `b_t2s' `se_t2s'
local s2 "`r(s)'"
local b3 : di %7.4f `b_t4c1'
local b3 = strtrim("`b3'")
_stars `b_t4c1' `se_t4c1'
local s3 "`r(s)'"
local b4 : di %7.4f `b_t4s'
local b4 = strtrim("`b4'")
_stars `b_t4s' `se_t4s'
local s4 "`r(s)'"

file write texfile "Post-desegregation (imp\_post)" _n
file write texfile " & `b1'`s1' & `b2'`s2' & `b3'`s3' & `b4'`s4' \\" _n

* SE row
local se1 : di %7.4f `se_t2c1'
local se1 = strtrim("`se1'")
local se2 : di %7.4f `se_t2s'
local se2 = strtrim("`se2'")
local se3 : di %7.4f `se_t4c1'
local se3 = strtrim("`se3'")
local se4 : di %7.4f `se_t4s'
local se4 = strtrim("`se4'")

file write texfile " & (`se1') & (`se2') & (`se3') & (`se4') \\" _n
file write texfile "\addlinespace" _n
file write texfile "District FE & Y & Y & Y & Y \\" _n
file write texfile "Year FE & Y & Y & Y & Y \\" _n
file write texfile "Year \$\times\$ South FE & Y & & Y & \\" _n

local nfmt : di %6.0fc `n_t2c1'
local nfmt = strtrim("`nfmt'")
file write texfile "Observations & `nfmt' & `nfmt' & `nfmt' & `nfmt' \\" _n
local gfmt : di %4.0fc `ng_t2c1'
local gfmt = strtrim("`gfmt'")
file write texfile "Districts & `gfmt' & `gfmt' & `gfmt' & `gfmt' \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{5}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Cols (1) and (3) replicate the original paper specification" _n
file write texfile " with year\$\times\$South interactions. Cols (2) and (4) use simplified" _n
file write texfile " TWFE (district + year FE only) for weight decomposition." _n
file write texfile " Robust SE clustered by district. *** p<0.01, ** p<0.05, * p<0.10.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table2_replication.tex created"


* ===== TWOWAYFEWEIGHTS TABLE =====
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition --- Baum-Snow and Lutz (2011)}" _n
file write texfile "\label{tab:baumsnow_twowayfe}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & White Public & Black Public \\" _n
file write texfile " & (feTR) & (feTR) \\" _n
file write texfile "\midrule" _n

if `fetr_w_ok' == 1 {
    local bw : di %9.6f `fetr_w_beta'
    local bw = strtrim("`bw'")
    local npw : di %6.0f `fetr_w_npos'
    local npw = strtrim("`npw'")
    local nnw : di %6.0f `fetr_w_nneg'
    local nnw = strtrim("`nnw'")
    local pnw : di %5.1f `fetr_w_pneg'
    local pnw = strtrim("`pnw'")
}
else {
    local bw "--"
    local npw "--"
    local nnw "--"
    local pnw "--"
}

if `fetr_b_ok' == 1 {
    local bb : di %9.6f `fetr_b_beta'
    local bb = strtrim("`bb'")
    local npb : di %6.0f `fetr_b_npos'
    local npb = strtrim("`npb'")
    local nnb : di %6.0f `fetr_b_nneg'
    local nnb = strtrim("`nnb'")
    local pnb : di %5.1f `fetr_b_pneg'
    local pnb = strtrim("`pnb'")
}
else {
    local bb "--"
    local npb "--"
    local nnb "--"
    local pnb "--"
}

file write texfile "\$\hat{\beta}_{TWFE}\$ & `bw' & `bb' \\" _n
file write texfile "Positive weights & `npw' & `npb' \\" _n
file write texfile "Negative weights & `nnw' & `nnb' \\" _n
file write texfile "\% Negative & `pnw'\% & `pnb'\% \\" _n
file write texfile "\addlinespace" _n
file write texfile "Treatment & \multicolumn{2}{c}{Post-desegregation (binary)} \\" _n
file write texfile "Unit (G) & \multicolumn{2}{c}{School district (leaid)} \\" _n
file write texfile "Time (T) & \multicolumn{2}{c}{Year (1960--1990)} \\" _n
file write texfile "Design & \multicolumn{2}{c}{Staggered adoption} \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{3}{p{0.85\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Decomposition following de Chaisemartin and" _n
file write texfile " D'Haultf\oe uille (2020). Simplified TWFE (district + year FE).}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"


* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/baumsnow_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Baum-Snow and Lutz (2011)}\\" _n
file write texfile "{\large School Desegregation, School Choice, and Changes}\\" _n
file write texfile "{\large in Residential Location Patterns by Race}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(7), 3019--3046}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table2_replication}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> baumsnow_tables.tex created"


/*==============================================================================
  STEP 5: SUMMARY
==============================================================================*/

di _n "=============================================="
di    "  FINAL SUMMARY: Baum-Snow and Lutz (2011)"
di    "=============================================="
di ""
di "Table 2, Col 1 (White Public, original): beta = " %7.4f `b_t2c1' " (" %5.4f `se_t2c1' ")"
di "Table 2, Col 1 (White Public, simplified): beta = " %7.4f `b_t2s' " (" %5.4f `se_t2s' ")"
di "Table 4, Col 1 (Black Public, original): beta = " %7.4f `b_t4c1' " (" %5.4f `se_t4c1' ")"
di "Table 4, Col 1 (Black Public, simplified): beta = " %7.4f `b_t4s' " (" %5.4f `se_t4s' ")"
di ""
if `fetr_w_ok' == 1 {
    di "feTR (White): npos=" %6.0f `fetr_w_npos' " nneg=" %6.0f `fetr_w_nneg' " %neg=" %5.1f `fetr_w_pneg' "%"
}
if `fetr_b_ok' == 1 {
    di "feTR (Black): npos=" %6.0f `fetr_b_npos' " nneg=" %6.0f `fetr_b_nneg' " %neg=" %5.1f `fetr_b_pneg' "%"
}
di ""
di "Output: table2_replication.tex, table_twowayfeweights.tex, baumsnow_tables.tex"
di "=============================================="

* log close _all
