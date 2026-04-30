/*==============================================================================
  FAYE AND NIEHAUS (2012) - "Political Aid Cycles"
  American Economic Review, 102(7), 3516-3530

  Pipeline: STEP 1 Data -> STEP 2 Replicate Table 2 -> STEP 3 twowayfeweights -> STEP 4 LaTeX

  Original analysis in R (analysis_allR_v3.r):
    data.base <- demean(data.base, "p")  # within-pair demeaning
    fm.main.I <- ols(oda ~ i_elecex + yeardums, data=data.base)
  This is equivalent to pair FE + year FE = TWFE.

  Stata equivalent:
    xtreg oda i_elecex i.year, fe i(pair_id) cluster(pair_id)

  Treatment: i_elecex = 1 if executive election year in recipient
  Unit FE: pair_id (donor x recipient pair)
  Time FE: year (1975-2003)
  Outcome: oda (ODA commitments, 2004 USD)
==============================================================================*/

clear all
set more off
set matsize 5000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Faye and Niehaus (2012)/data_analysis/data"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Faye and Niehaus (2012)"
global latexdir "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex/2010-2012/Faye and Niehaus (2012)"

* NOTE: log is auto-created by Stata -b mode (run_twowayfe.log)

* Install packages if needed
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace

cap which reghdfe
if _rc ssc install reghdfe, replace

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
  Replicate the R estsample() function:
  1. Drop missing on key vars
  2. Drop pairs with gaps in time series
==============================================================================*/

* Try DTA first, fall back to CSV
cap use "$datadir/111102_oda_final_data_big5_commit_080107_unvotes_term.dta", clear
if _rc != 0 {
    di "DTA load failed, trying CSV..."
    insheet using "$datadir/111102_oda_final_data_big5_commit_080107_unvotes_term.csv", clear
}

di _n "=== RAW DATA ==="
di "Observations: " _N
desc, short

* Identify variable names (may differ by case)
* The R code uses: oda, i_elecex, unvotes, p_unvotes_elecex, year, wbcode_donor, wbcode_recipient
* Check what we have
cap confirm variable oda
if _rc != 0 {
    cap confirm variable odaPair_commit
    if _rc == 0 {
        gen oda = odaPair_commit
        di "Created oda from odaPair_commit"
    }
    else {
        cap confirm variable odapair_commit
        if _rc == 0 {
            gen oda = odapair_commit
            di "Created oda from odapair_commit"
        }
    }
}

* Create pair ID
cap confirm variable wbcode_donor
if _rc == 0 {
    egen pair_id = group(wbcode_donor wbcode_recipient)
    local dvar "wbcode_donor"
    local rvar "wbcode_recipient"
}
else {
    cap confirm variable d
    if _rc == 0 {
        * Variables might be named d and r from CSV
        egen pair_id = group(d r)
        local dvar "d"
        local rvar "r"
    }
}

di "Created pair_id from `dvar' x `rvar'"
qui tab pair_id
di "Total pairs: " r(r)

* --- Sample construction following R estsample() ---
* Step 1: Drop missing on key variables
* R code line 174: estsample(data, c("unvotes","i_elecex","p_unvotes_elecex",
*   "unvotes_rt","unvotes_resid","p_unvotes_rt_elecex",
*   "p_unvotes_resid_elecex","oda","p","d","r","year"))
local keyvars "oda i_elecex unvotes p_unvotes_elecex"
local before = _N
foreach v of local keyvars {
    cap confirm variable `v'
    if _rc == 0 {
        drop if missing(`v')
    }
    else {
        di "WARNING: variable `v' not found"
    }
}
di "Dropped " `before' - _N " obs with missing key vars. N = " _N

* Step 2: Drop pairs with gaps (R estsample logic)
* maxyear - minyear + 1 == nobs per pair
bys pair_id: egen minyear = min(year)
bys pair_id: egen maxyear = max(year)
bys pair_id: gen pobs = _N
gen nogap = (maxyear - minyear + 1 == pobs)
local before2 = _N
keep if nogap == 1
di "Dropped " `before2' - _N " obs from pairs with gaps. N = " _N
drop minyear maxyear pobs nogap

* Panel structure
di _n "--- Panel structure ---"
qui tab pair_id
local n_pairs = r(r)
di "Donor-Recipient pairs (G): " `n_pairs'
qui tab year
local n_years = r(r)
di "Years (T): " `n_years'
tab year
di "N = " _N

* Treatment variation
di _n "--- Treatment: i_elecex ---"
tab i_elecex
bys pair_id: egen ever_elec = max(i_elecex)
qui tab pair_id if ever_elec == 1
di "Pairs with at least one election: " r(r)
qui tab pair_id if ever_elec == 0
di "Pairs with no elections: " r(r)
drop ever_elec

di _n "--- Outcome: oda ---"
sum oda, detail

* Set panel
xtset pair_id year


/*==============================================================================
  STEP 2: REPLICATE TABLE 2
  R code line 188: fm.main.I <- ols(oda ~ i_elecex + yeardums, data=data.base)
  After within-pair demeaning = pair FE + year FE
  R uses 3-way clustered SE (donor, recipient, year) via mwc_3way
  We use pair_id clustering for twowayfeweights compatibility
==============================================================================*/

di _n "=============================================="
di    "TABLE 2 REPLICATION"
di    "=============================================="

* --- Col I: Pair FE + Year FE ---
di _n "--- Col I: Pair FE + Year FE (TWFE) ---"
xtreg oda i_elecex i.year, fe i(pair_id) cluster(pair_id)
local b_c1  = _b[i_elecex]
local se_c1 = _se[i_elecex]
local n_c1  = e(N)
local ng_c1 = e(N_g)
di "  beta(i_elecex) = " %9.4f `b_c1' " (" %7.4f `se_c1' ")"
di "  N = " `n_c1' ", pairs = " `ng_c1'
estimates store c1

* --- Col IV: Add UN votes interaction ---
di _n "--- Col IV: Pair FE + Year FE + unvotes + interaction ---"
cap xtreg oda i_elecex unvotes p_unvotes_elecex i.year, fe i(pair_id) cluster(pair_id)
if _rc == 0 {
    local b_c4  = _b[i_elecex]
    local se_c4 = _se[i_elecex]
    local b_c4_uv = _b[p_unvotes_elecex]
    local se_c4_uv = _se[p_unvotes_elecex]
    local n_c4  = e(N)
    di "  beta(i_elecex) = " %9.4f `b_c4' " (" %7.4f `se_c4' ")"
    di "  beta(UN*elec)  = " %9.4f `b_c4_uv' " (" %7.4f `se_c4_uv' ")"
    local c4_ok = 1
    estimates store c4
}
else {
    di "  Col IV regression failed"
    local c4_ok = 0
}


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- feTR ---
di _n "=== feTR: oda ~ i_elecex ==="
cap scalar drop nplus nminus beta sumpositive sumnegative
cap noisily twowayfeweights oda pair_id year i_elecex, type(feTR) summary_measures
local rc_fetr = _rc

local fetr_ok = 0
if `rc_fetr' == 0 | `rc_fetr' == 402 {
    cap local fetr_beta = e(beta)
    cap mat M = e(M)
    if _rc == 0 {
        local fetr_npos = el(M,1,1)
        local fetr_nneg = el(M,2,1)
        local fetr_ok = 1
    }
    else {
        cap local fetr_npos = scalar(nplus)
        cap local fetr_nneg = scalar(nminus)
        if `fetr_npos' != . & `fetr_nneg' != . {
            local fetr_ok = 1
        }
    }
}
else {
    cap local fetr_beta = scalar(beta)
    cap local fetr_npos = scalar(nplus)
    cap local fetr_nneg = scalar(nminus)
    if `fetr_npos' != . & `fetr_nneg' != . {
        local fetr_ok = 1
    }
}

if `fetr_ok' == 1 {
    local fetr_pneg = 100 * `fetr_nneg' / (`fetr_npos' + `fetr_nneg')
    di _n "feTR: beta=" %9.4f `fetr_beta' " npos=" %6.0f `fetr_npos' " nneg=" %6.0f `fetr_nneg' " %neg=" %5.1f `fetr_pneg' "%"
}
else {
    di "feTR: FAILED (rc=`rc_fetr')"
}

* --- fdTR ---
di _n "=== fdTR: oda ~ i_elecex ==="
cap scalar drop nplus nminus beta sumpositive sumnegative
cap noisily twowayfeweights oda pair_id year i_elecex, type(fdTR) summary_measures
local rc_fdtr = _rc

local fdtr_ok = 0
if `rc_fdtr' == 0 | `rc_fdtr' == 402 {
    cap local fdtr_beta = e(beta)
    cap mat M = e(M)
    if _rc == 0 {
        local fdtr_npos = el(M,1,1)
        local fdtr_nneg = el(M,2,1)
        local fdtr_ok = 1
    }
    else {
        cap local fdtr_npos = scalar(nplus)
        cap local fdtr_nneg = scalar(nminus)
        if `fdtr_npos' != . & `fdtr_nneg' != . {
            local fdtr_ok = 1
        }
    }
}
else {
    cap local fdtr_beta = scalar(beta)
    cap local fdtr_npos = scalar(nplus)
    cap local fdtr_nneg = scalar(nminus)
    if `fdtr_npos' != . & `fdtr_nneg' != . {
        local fdtr_ok = 1
    }
}

if `fdtr_ok' == 1 {
    local fdtr_pneg = 100 * `fdtr_nneg' / (`fdtr_npos' + `fdtr_nneg')
    di _n "fdTR: beta=" %9.4f `fdtr_beta' " npos=" %6.0f `fdtr_npos' " nneg=" %6.0f `fdtr_nneg' " %neg=" %5.1f `fdtr_pneg' "%"
}
else {
    di "fdTR: FAILED (rc=`rc_fdtr')"
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
file write texfile "\caption{Replication of Table 2 --- Faye and Niehaus (2012)}" _n
file write texfile "\label{tab:fayeniehaus_replication}" _n

if `c4_ok' == 1 {
    file write texfile "\begin{tabular}{lcc}" _n
    file write texfile "\toprule" _n
    file write texfile " & Col I & Col IV \\" _n
    file write texfile " & (Baseline) & (UN alignment) \\" _n
    file write texfile "\midrule" _n
    file write texfile "\multicolumn{3}{l}{\textit{Dep.\ var.: ODA commitments (2004 USD)}} \\" _n
}
else {
    file write texfile "\begin{tabular}{lc}" _n
    file write texfile "\toprule" _n
    file write texfile " & Col I \\" _n
    file write texfile " & (Baseline) \\" _n
    file write texfile "\midrule" _n
    file write texfile "\multicolumn{2}{l}{\textit{Dep.\ var.: ODA commitments (2004 USD)}} \\" _n
}
file write texfile "\addlinespace" _n

* Election row
local b1 : di %9.4f `b_c1'
local b1 = strtrim("`b1'")
_stars `b_c1' `se_c1'
local s1 "`r(s)'"
local sse1 : di %7.4f `se_c1'
local sse1 = strtrim("`sse1'")

if `c4_ok' == 1 {
    local b4 : di %9.4f `b_c4'
    local b4 = strtrim("`b4'")
    _stars `b_c4' `se_c4'
    local s4 "`r(s)'"
    local sse4 : di %7.4f `se_c4'
    local sse4 = strtrim("`sse4'")

    file write texfile "Executive Election & `b1'`s1' & `b4'`s4' \\" _n
    file write texfile " & (`sse1') & (`sse4') \\" _n

    * UN interaction
    local buv : di %9.4f `b_c4_uv'
    local buv = strtrim("`buv'")
    _stars `b_c4_uv' `se_c4_uv'
    local suv "`r(s)'"
    local seuv : di %7.4f `se_c4_uv'
    local seuv = strtrim("`seuv'")

    file write texfile "\addlinespace" _n
    file write texfile "UN Alignment \$\times\$ Election & & `buv'`suv' \\" _n
    file write texfile " & & (`seuv') \\" _n
}
else {
    file write texfile "Executive Election & `b1'`s1' \\" _n
    file write texfile " & (`sse1') \\" _n
}

file write texfile "\addlinespace" _n

if `c4_ok' == 1 {
    file write texfile "Pair FE & Y & Y \\" _n
    file write texfile "Year FE & Y & Y \\" _n
    local nfmt : di %9.0fc `n_c1'
    local nfmt = strtrim("`nfmt'")
    local gfmt : di %6.0fc `ng_c1'
    local gfmt = strtrim("`gfmt'")
    file write texfile "Observations & `nfmt' & `nfmt' \\" _n
    file write texfile "Pairs & `gfmt' & `gfmt' \\" _n
    file write texfile "\bottomrule" _n
    file write texfile "\multicolumn{3}{p{0.85\linewidth}}{\footnotesize" _n
}
else {
    file write texfile "Pair FE & Y \\" _n
    file write texfile "Year FE & Y \\" _n
    local nfmt : di %9.0fc `n_c1'
    local nfmt = strtrim("`nfmt'")
    local gfmt : di %6.0fc `ng_c1'
    local gfmt = strtrim("`gfmt'")
    file write texfile "Observations & `nfmt' \\" _n
    file write texfile "Pairs & `gfmt' \\" _n
    file write texfile "\bottomrule" _n
    file write texfile "\multicolumn{2}{p{0.85\linewidth}}{\footnotesize" _n
}

file write texfile " \textit{Notes:} Pair = donor\$\times\$recipient. Original analysis" _n
file write texfile " in R with 3-way clustered SE (donor, recipient, year)." _n
file write texfile " Here: SE clustered by pair. *** p<0.01, ** p<0.05, * p<0.10.}" _n

if `c4_ok' == 1 {
    file write texfile "\end{tabular}" _n
}
else {
    file write texfile "\end{tabular}" _n
}
file write texfile "\end{table}" _n

file close texfile
di "  -> table2_replication.tex created"


* ===== TWOWAYFEWEIGHTS TABLE =====
cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{TWFE Weight Decomposition --- Faye and Niehaus (2012)}" _n
file write texfile "\label{tab:fayeniehaus_twowayfe}" _n
file write texfile "\begin{tabular}{lcc}" _n
file write texfile "\toprule" _n
file write texfile " & feTR & fdTR \\" _n
file write texfile "\midrule" _n

* feTR column
if `fetr_ok' == 1 {
    local bf : di %9.4f `fetr_beta'
    local bf = strtrim("`bf'")
    local npf : di %6.0f `fetr_npos'
    local npf = strtrim("`npf'")
    local nnf : di %6.0f `fetr_nneg'
    local nnf = strtrim("`nnf'")
    local pnf : di %5.1f `fetr_pneg'
    local pnf = strtrim("`pnf'")
}
else {
    local bf "--"
    local npf "--"
    local nnf "--"
    local pnf "--"
}

* fdTR column
if `fdtr_ok' == 1 {
    local bd : di %9.4f `fdtr_beta'
    local bd = strtrim("`bd'")
    local npd : di %6.0f `fdtr_npos'
    local npd = strtrim("`npd'")
    local nnd : di %6.0f `fdtr_nneg'
    local nnd = strtrim("`nnd'")
    local pnd : di %5.1f `fdtr_pneg'
    local pnd = strtrim("`pnd'")
}
else {
    local bd "--"
    local npd "--"
    local nnd "--"
    local pnd "--"
}

file write texfile "\$\hat{\beta}_{TWFE}\$ & `bf' & `bd' \\" _n
file write texfile "Positive weights & `npf' & `npd' \\" _n
file write texfile "Negative weights & `nnf' & `nnd' \\" _n
file write texfile "\% Negative & `pnf'\% & `pnd'\% \\" _n
file write texfile "\addlinespace" _n
file write texfile "Treatment & \multicolumn{2}{c}{Executive election (binary)} \\" _n
file write texfile "Unit (G) & \multicolumn{2}{c}{Donor\$\times\$Recipient pair} \\" _n
file write texfile "Time (T) & \multicolumn{2}{c}{Year (1975--2003)} \\" _n
file write texfile "Design & \multicolumn{2}{c}{Staggered (elections in different years)} \\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{3}{p{0.85\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} Decomposition following de Chaisemartin and" _n
file write texfile " D'Haultf\oe uille (2020). Pair FE + Year FE.}" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"


* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/fayeniehaus_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Faye and Niehaus (2012)}\\" _n
file write texfile "{\large Political Aid Cycles}\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 102(7), 3516--3530}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table2_replication}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> fayeniehaus_tables.tex created"


/*==============================================================================
  STEP 5: SUMMARY
==============================================================================*/

di _n "=============================================="
di    "  FINAL SUMMARY: Faye and Niehaus (2012)"
di    "=============================================="
di ""
di "Table 2, Col I (baseline): beta(i_elecex) = " %9.4f `b_c1' " (" %7.4f `se_c1' ")"
if `c4_ok' == 1 {
    di "Table 2, Col IV (UN align): beta(i_elecex) = " %9.4f `b_c4' " (" %7.4f `se_c4' ")"
    di "                            beta(UN*elec)  = " %9.4f `b_c4_uv' " (" %7.4f `se_c4_uv' ")"
}
di ""
if `fetr_ok' == 1 {
    di "feTR: npos=" %6.0f `fetr_npos' " nneg=" %6.0f `fetr_nneg' " %neg=" %5.1f `fetr_pneg' "%"
}
if `fdtr_ok' == 1 {
    di "fdTR: npos=" %6.0f `fdtr_npos' " nneg=" %6.0f `fdtr_nneg' " %neg=" %5.1f `fdtr_pneg' "%"
}
di ""
di "Output: table2_replication.tex, table_twowayfeweights.tex, fayeniehaus_tables.tex"
di "=============================================="

* log close _all
