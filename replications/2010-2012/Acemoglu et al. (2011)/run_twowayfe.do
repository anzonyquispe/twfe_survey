/*==============================================================================
  ACEMOGLU, CANTONI, JOHNSON & ROBINSON (2011)
  "The Consequences of Radical Reform: The French Revolution"
  American Economic Review, 101(7), 3286-3307

  Pipeline: STEP 1 Data → STEP 2 Table 3 → STEP 3 twowayfeweights → STEP 4 LaTeX

  dCDH Web Appendix #14: Table 3, Regression 1 (FE), sharp design, feTR
  "The stable groups assumption is satisfied as there are several polities
   that did not experience any year of French presence."

  Specification (Table 3 Col 1):
    urbrate_jt = α_j + γ_t + Σ_s β_s × fpresence_j × I(t=s) + ε_jt
    Sample: westelbe==1, [aweight=totalpop1750], cluster(id)

  Panel: 13 polities × ~5.7 years ≈ 74 obs (West of Elbe, weighted)
         19 polities × ~5.7 years ≈ 109 obs (All, weighted)
==============================================================================*/

clear all
set more off
cap log close _all

global paperdir "C:/Users/Usuario/Documents/GitHub/papers_economic/Acemoglu et al. (2011)"
global datadir  "$paperdir/20100816_replication10"
global outdir   "$paperdir"

log using "$outdir/run_twowayfe.log", text replace

* Install packages if needed
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace
cap which gtools
if _rc ssc install gtools, replace

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
  Load panel of 19 pre-unitary German polities, 1700-1900
  Treatment: fpresence = years of French military/administrative presence
==============================================================================*/

use "$datadir/20100816_replication_dataset.dta", clear

* Keep only the 6 time periods used in Tables 3-4
keep if year==1700 | year==1750 | year==1800 | year==1850 | year==1875 | year==1900

* Drop unused year dummies
cap drop yr1880 yr1885 yr1895 yr1905 yr1910

* Create napoleon indicator (treated vs control)
gen napoleon = (fpresence > 0)

di _n "=== DATA SUMMARY ==="
di "Total observations: " _N
di ""
di "--- Panel structure ---"
tab year
di ""
di "--- Treatment variable: years of French presence ---"
summ fpresence
tab fpresence if year==1800
di ""
di "--- West of Elbe sample ---"
count if westelbe==1
di "  West of Elbe obs: " r(N)
qui tab id if westelbe==1 & year==1700
di "  West of Elbe polities: " r(r)
di ""
di "--- Treated vs Control (West of Elbe, at 1800) ---"
tab napoleon if westelbe==1 & year==1800
di ""
di "--- Outcome: urbanization rate ---"
summ urbrate
di ""
di "--- Weights: 1750 total population ---"
summ totalpop1750

sort id year


/*==============================================================================
  STEP 2: TABLE 3 — URBANIZATION IN GERMANY
  Dep var: urbanization rate (urbrate)
  FE regression with polity and year fixed effects

  Paper verification targets:
    Col 1 (West, weighted):   fpresence×1900 = 0.634 [0.408], N=74, 13 states
    Col 2 (West, unweight):   fpresence×1900 = 0.529 [0.401], N=74, 13 states
    Col 3 (All, weighted):    fpresence×1900 = 0.503 [0.376], N=109, 19 states
    Col 4 (All, unweight):    fpresence×1900 = 0.506 [0.423], N=109, 19 states
    p-value joint post-1800:  0.0532 / 0.463 / 0.0205 / 0.214
==============================================================================*/

di _n "=============================================="
di    "TABLE 3: URBANIZATION IN GERMANY"
di    "=============================================="

* Year labels for iteration
local yrlist "1750 1800 1850 1875 1900"

* Initialize storage
forvalues k = 1/4 {
    forvalues j = 1/5 {
        local b`j'_`k'  = .
        local se`j'_`k' = .
    }
    local nn_`k'   = 0
    local ns_`k'   = 0
    local pval_`k' = .
}

* --- Column 1: West of Elbe, weighted ---
di _n "--- Column 1: West of Elbe, Weighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* ///
    if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local pval_1 = r(p)
local nn_1 = e(N)
local ns_1 = e(df_a) + 1
forvalues j = 1/5 {
    local yr : word `j' of `yrlist'
    local b`j'_1  = _b[fpresence`yr']
    local se`j'_1 = _se[fpresence`yr']
}
di "  fpresence1900 = " %7.3f `b5_1' " [" %5.3f `se5_1' "]"
di "  N = " `nn_1' ", States = " `ns_1' ", p-val post-1800 = " %6.4f `pval_1'

* --- Column 2: West of Elbe, unweighted ---
di _n "--- Column 2: West of Elbe, Unweighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* ///
    if westelbe==1, fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local pval_2 = r(p)
local nn_2 = e(N)
local ns_2 = e(df_a) + 1
forvalues j = 1/5 {
    local yr : word `j' of `yrlist'
    local b`j'_2  = _b[fpresence`yr']
    local se`j'_2 = _se[fpresence`yr']
}
di "  fpresence1900 = " %7.3f `b5_2' " [" %5.3f `se5_2' "]"
di "  N = " `nn_2' ", States = " `ns_2' ", p-val post-1800 = " %6.4f `pval_2'

* --- Column 3: All polities, weighted ---
di _n "--- Column 3: All polities, Weighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr* ///
    [aweight=totalpop1750], fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local pval_3 = r(p)
local nn_3 = e(N)
local ns_3 = e(df_a) + 1
forvalues j = 1/5 {
    local yr : word `j' of `yrlist'
    local b`j'_3  = _b[fpresence`yr']
    local se`j'_3 = _se[fpresence`yr']
}
di "  fpresence1900 = " %7.3f `b5_3' " [" %5.3f `se5_3' "]"
di "  N = " `nn_3' ", States = " `ns_3' ", p-val post-1800 = " %6.4f `pval_3'

* --- Column 4: All polities, unweighted ---
di _n "--- Column 4: All polities, Unweighted ---"
xtreg urbrate fpresence1750 fpresence1800 fpresence1850 fpresence1875 fpresence1900 yr*, ///
    fe i(id) cluster(id)
test fpresence1850 fpresence1875 fpresence1900
local pval_4 = r(p)
local nn_4 = e(N)
local ns_4 = e(df_a) + 1
forvalues j = 1/5 {
    local yr : word `j' of `yrlist'
    local b`j'_4  = _b[fpresence`yr']
    local se`j'_4 = _se[fpresence`yr']
}
di "  fpresence1900 = " %7.3f `b5_4' " [" %5.3f `se5_4' "]"
di "  N = " `nn_4' ", States = " `ns_4' ", p-val post-1800 = " %6.4f `pval_4'

* --- Verification against paper ---
di _n "=============================================="
di    "VERIFICATION vs Paper Table 3"
di    "=============================================="
di "                    Col1(Paper)  Col1(Ours)  Col3(Paper)  Col3(Ours)"
di "fpresence x 1750    -0.491     " %8.3f `b1_1' "       -0.488     " %8.3f `b1_3'
di "fpresence x 1800    -0.247     " %8.3f `b2_1' "       -0.268     " %8.3f `b2_3'
di "fpresence x 1850    -0.160     " %8.3f `b3_1' "       -0.221     " %8.3f `b3_3'
di "fpresence x 1875     0.402     " %8.3f `b4_1' "        0.266     " %8.3f `b4_3'
di "fpresence x 1900     0.634     " %8.3f `b5_1' "        0.503     " %8.3f `b5_3'
di "p-val post-1800      0.0532    " %8.4f `pval_1' "       0.0205    " %8.4f `pval_3'
di "N                    74         " %5.0f `nn_1' "          109       " %5.0f `nn_3'
di "States               13         " %5.0f `ns_1' "          19        " %5.0f `ns_3'


/*==============================================================================
  STEP 3: TWOWAYFEWEIGHTS DECOMPOSITION

  Treatment: fpresence × year interactions (multiple treatments)
  Strategy: use fpresence1900 as main D, others as other_treatments()
  Also test simplified D_post = fpresence × I(year >= 1850)

  feTR decomposition: Y = urbrate, G = id, T = year
==============================================================================*/

di _n "=============================================="
di    "TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- Approach 1: Col 1 spec with other_treatments (West, weighted) ---
di _n "=============================================="
di    "A1: feTR — fpresence1900 with other_treatments"
di    "    Sample: West of Elbe, weighted by 1750 pop"
di    "=============================================="
di "  Syntax: twowayfeweights urbrate id year fpresence1900 if westelbe==1,"
di "          type(feTR) other_treatments(...) weight(totalpop1750)"
di ""
cap noisily twowayfeweights urbrate id year fpresence1900 if westelbe==1, ///
    type(feTR) ///
    other_treatments(fpresence1750 fpresence1800 fpresence1850 fpresence1875) ///
    weight(totalpop1750) summary_measures

* --- Approach 2: Simplified post-treatment variable ---
di _n "=============================================="
di    "A2: feTR — D_post = fpresence x I(year >= 1850)"
di    "    Simpler specification for weight decomposition"
di    "=============================================="
gen D_post = fpresence * (year >= 1850)
label var D_post "French presence x post-1850"

di "  D_post summary (West of Elbe only):"
tab D_post if westelbe==1

di ""
di "  First verify the FE regression with D_post:"
xtreg urbrate D_post yr* if westelbe==1 [aweight=totalpop1750], fe i(id) cluster(id)
di "  beta(D_post) = " %7.4f _b[D_post] " (" %5.4f _se[D_post] "), N = " e(N)

di ""
cap noisily twowayfeweights urbrate id year D_post if westelbe==1, ///
    type(feTR) weight(totalpop1750) summary_measures

* --- Approach 3: All polities, weighted (Col 3 spec) ---
di _n "=============================================="
di    "A3: feTR — fpresence1900, all polities (Col 3)"
di    "=============================================="
cap noisily twowayfeweights urbrate id year fpresence1900, ///
    type(feTR) ///
    other_treatments(fpresence1750 fpresence1800 fpresence1850 fpresence1875) ///
    weight(totalpop1750) summary_measures

* --- Approach 4: All polities, D_post ---
di _n "=============================================="
di    "A4: feTR — D_post, all polities"
di    "=============================================="
cap noisily twowayfeweights urbrate id year D_post, ///
    type(feTR) weight(totalpop1750) summary_measures


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
file write texfile "\caption{Table 3---Urbanization in Germany}" _n
file write texfile "\label{tab:table3}" _n
file write texfile "\begin{tabular}{lcccc}" _n
file write texfile "\toprule" _n
file write texfile " & \multicolumn{2}{c}{West of the Elbe} & \multicolumn{2}{c}{All} \\\\" _n
file write texfile "\cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
file write texfile " & Weighted & Unweighted & Weighted & Unweighted \\\\" _n
file write texfile " & (1) & (2) & (3) & (4) \\\\" _n
file write texfile "\midrule" _n

* Row labels
local rowlbl1 "Years French presence \$\times\$ 1750"
local rowlbl2 "Years French presence \$\times\$ 1800"
local rowlbl3 "Years French presence \$\times\$ 1850"
local rowlbl4 "Years French presence \$\times\$ 1875"
local rowlbl5 "Years French presence \$\times\$ 1900"

* Write coefficient and SE rows
forvalues j = 1/5 {
    * Coefficients
    forvalues k = 1/4 {
        local bfmt_`k' : di %7.3f `b`j'_`k''
        local bfmt_`k' = strtrim("`bfmt_`k''")
        _stars `b`j'_`k'' `se`j'_`k''
        local s_`k' "`r(s)'"
    }
    file write texfile "`rowlbl`j'' & `bfmt_1'`s_1' & `bfmt_2'`s_2' & `bfmt_3'`s_3' & `bfmt_4'`s_4' \\\\" _n

    * Standard errors
    forvalues k = 1/4 {
        local sfmt_`k' : di %7.3f `se`j'_`k''
        local sfmt_`k' = strtrim("`sfmt_`k''")
    }
    file write texfile " & [`sfmt_1'] & [`sfmt_2'] & [`sfmt_3'] & [`sfmt_4'] \\\\" _n

    if `j' < 5 {
        file write texfile "\addlinespace" _n
    }
}

file write texfile "\addlinespace[6pt]" _n

* Observations row
file write texfile "Observations & `nn_1' & `nn_2' & `nn_3' & `nn_4' \\\\" _n

* Number of states
file write texfile "Number of states & `ns_1' & `ns_2' & `ns_3' & `ns_4' \\\\" _n

* p-value
forvalues k = 1/4 {
    local pfmt_`k' : di %6.4f `pval_`k''
    local pfmt_`k' = strtrim("`pfmt_`k''")
}
file write texfile "\textit{p}-value joint sig.\ after 1800 & `pfmt_1' & `pfmt_2' & `pfmt_3' & `pfmt_4' \\\\" _n

file write texfile "\bottomrule" _n
file write texfile "\multicolumn{5}{p{0.95\linewidth}}{\footnotesize" _n
file write texfile " \textit{Notes:} All regressions have full set of territory and year dummies." _n
file write texfile " Robust standard errors clustered by territory in brackets." _n
file write texfile " Weighted regressions are weighted by territories' total population in 1750." _n
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
file write texfile "Dependent variable & Urbanization rate \\\\" _n
file write texfile "Treatment variable & Years French presence \$\times\$ year \\\\" _n
file write texfile "Group (G) & Polity (territory) \\\\" _n
file write texfile "Time (T) & Year (1700--1900) \\\\" _n
file write texfile "Design & Sharp (polities with 0 French presence) \\\\" _n
file write texfile "\addlinespace" _n
file write texfile "\multicolumn{2}{l}{\textit{See log file for detailed weight distribution}} \\\\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"

* ===== MASTER DOCUMENT =====
cap file close texfile
file open texfile using "$outdir/acemoglu_tables.tex", write replace

file write texfile "\documentclass[12pt]{article}" _n
file write texfile "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write texfile "\geometry{margin=1in}" _n
file write texfile "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write texfile "\begin{document}" _n _n
file write texfile "\begin{center}" _n
file write texfile "{\Large\bfseries Acemoglu, Cantoni, Johnson \& Robinson (2011)}\\\\" _n
file write texfile "{\large The Consequences of Radical Reform:}\\\\" _n
file write texfile "{\large The French Revolution}\\\\" _n
file write texfile "\vspace{0.5em}" _n
file write texfile "{\normalsize \textit{American Economic Review}, 101(7), 3286--3307}" _n
file write texfile "\end{center}" _n _n
file write texfile "\vspace{1em}" _n _n
file write texfile "\input{table3}" _n _n
file write texfile "\input{table_twowayfeweights}" _n _n
file write texfile "\end{document}" _n

file close texfile
di "  -> acemoglu_tables.tex created"


di _n "=============================================="
di    "ALL DONE - Acemoglu et al. (2011)"
di    "=============================================="
di "Output files:"
di "  1. $outdir/table3.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/acemoglu_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "=============================================="

log close _all
