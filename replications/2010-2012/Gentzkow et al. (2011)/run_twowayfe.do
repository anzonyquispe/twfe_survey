/*==============================================================================
  GENTZKOW, SHAPIRO & SINKINSON (2011) - "The Effect of Newspaper Entry
  and Exit on Electoral Politics"
  American Economic Review, 101(7), 2980-3018

  Pipeline:
    STEP 1: Replicate Table 2 Cols 2-4
    STEP 2: twowayfeweights decomposition (feTR)
    STEP 3: Export LaTeX tables

  dCDH Web Appendix:
    Tables 2-3. Regression 1 (feTR).
    Panel: ~3114 counties x 46 election years (1824-2004).
    Y = prestout (presidential turnout)
    D = numdailies (number of daily newspapers)
==============================================================================*/

clear all
set more off
cap log close _all

* --- Paths ---
global datadir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Gentzkow et al. (2011)/20091316_data"
global outdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Gentzkow et al. (2011)"
global texdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/latex/2010-2012/Gentzkow et al. (2011)"

log using "$outdir/run_twowayfe.log", text replace
set more off
set matsize 5000

* --- Install packages ---
cap which estout
if _rc ssc install estout, replace
cap which twowayfeweights
if _rc ssc install twowayfeweights, replace

* --- Load custom ado files and parameters ---
adopath + "$datadir/external"

* Manual globals from input_param.txt (loadglob fails in modern Stata)
global samplestart 1872
global sampleend 1928
global datastart 1868
global dataend 2004
global maxpolyorder 3
global maxwindow 1
global maxhorizon 40
global localgraphwindow 6
global panelvar "cnty90"
global yearvar "year"
global delta 4
global polymidpoint .5
global maxchange -9999
global demolist "D_ishare_foreign D_ishare_manuf D_ishare_male D_ishare_urb D_ishare_town D_ishare_white D_ilog_manufout_ctrl"
global misdemolist "mis_D_ishare_foreign mis_D_ishare_manuf mis_D_ishare_male mis_D_ishare_urb mis_D_ishare_town mis_D_ishare_white mis_D_ilog_manufout_ctrl"


/*==============================================================================
  STEP 1: REPLICATE TABLE 2
  Paper uses: areg D.prestout x_0 [controls], absorb(styr) cluster(cnty90)
  define_event creates x_0 = indicator for newspaper entry/exit event
==============================================================================*/

di _n "============================================================"
di "  STEP 1: REPLICATE TABLE 2"
di "============================================================"

use "$datadir/temp/voting_cnty_clean.dta", clear
di "Data loaded: " _N " obs"

define_event x, changein(numdailies) maxchange($maxchange) window(1)

* --- Col 2: No controls ---
di _n "--- Col 2: D.prestout ~ x_0, absorb(styr) ---"
areg D.prestout x_0 if mainsample, absorb(styr) cluster(cnty90)
est store col2
local b_col2 = _b[x_0]
local se_col2 = _se[x_0]
local n_col2 = e(N)
local nc_col2 = e(N_clust)
estadd local styrfe "Yes" : col2
estadd local controls "No" : col2

di "  beta = " %8.4f `b_col2' " SE = " %8.4f `se_col2' " N = " `n_col2' " clusters = " `nc_col2'

* --- Col 3: With demographic controls ---
di _n "--- Col 3: D.prestout ~ x_0 + demographics, absorb(styr) ---"
areg D.prestout x_0 $demolist $misdemolist if mainsample, absorb(styr) cluster(cnty90)
est store col3
local b_col3 = _b[x_0]
local se_col3 = _se[x_0]
local n_col3 = e(N)
local nc_col3 = e(N_clust)
estadd local styrfe "Yes" : col3
estadd local controls "Yes" : col3

di "  beta = " %8.4f `b_col3' " SE = " %8.4f `se_col3' " N = " `n_col3' " clusters = " `nc_col3'

* --- Col 4: Congressional turnout ---
di _n "--- Col 4: D.congtout ~ x_0 + demographics, absorb(styr) ---"
areg D.congtout x_0 $demolist $misdemolist if mainsample & abs(D.congtout)<1, absorb(styr) cluster(cnty90)
est store col4
local b_col4 = _b[x_0]
local se_col4 = _se[x_0]
local n_col4 = e(N)
local nc_col4 = e(N_clust)
estadd local styrfe "Yes" : col4
estadd local controls "Yes" : col4

di "  beta = " %8.4f `b_col4' " SE = " %8.4f `se_col4' " N = " `n_col4' " clusters = " `nc_col4'

di _n "  VERIFICATION Table 2:"
di "  Col 2: " %8.4f `b_col2' " (" %6.4f `se_col2' ") N=" `n_col2'
di "  Col 3: " %8.4f `b_col3' " (" %6.4f `se_col3' ") N=" `n_col3'
di "  Col 4: " %8.4f `b_col4' " (" %6.4f `se_col4' ") N=" `n_col4'


/*==============================================================================
  STEP 2: TWOWAYFEWEIGHTS DECOMPOSITION
  Apply to levels TWFE: prestout = county_FE + year_FE + beta*numdailies
  Restricted to mainsample
==============================================================================*/

di _n "============================================================"
di "  STEP 2: TWOWAYFEWEIGHTS DECOMPOSITION"
di "============================================================"

keep if mainsample == 1
di "Restricted to mainsample: N = " _N
qui tab cnty90
di "Counties: " r(r)
qui tab year
di "Years: " r(r)

* Initialize
local tw_beta1  = .
local tw_npos1  = .
local tw_nneg1  = .
local tw_pneg1  = "N/A"
local tw_rc1    = 999

* --- feTR with T=year ---
di _n "--- feTR: Y=prestout, G=cnty90, T=year, D=numdailies ---"
cap noisily twowayfeweights prestout cnty90 year numdailies, type(feTR)
local tw_rc1 = _rc

if `tw_rc1' == 0 | `tw_rc1' == 402 {
    local tw_beta1  = e(beta)
    mat _M1 = e(M)
    local tw_npos1  = _M1[1,1]
    local tw_nneg1  = _M1[2,1]
    local tw_ntot1  = `tw_npos1' + `tw_nneg1'
    local tw_pneg1 : di %5.1f (100 * `tw_nneg1' / `tw_ntot1')
    di _n "  Beta TWFE     = " `tw_beta1'
    di "  # pos weights = " `tw_npos1'
    di "  # neg weights = " `tw_nneg1'
    di "  % neg weights = " `tw_pneg1' "%"
}
else {
    di as error "  twowayfeweights (T=year) FAILED rc=" `tw_rc1'
    di "  Using manual fallback..."

    * Manual feTR decomposition
    qui areg numdailies i.year, absorb(cnty90)
    predict D_resid, resid
    gen D_resid2 = D_resid^2
    qui summ D_resid2
    local denom = r(sum)
    gen w_gt = D_resid / `denom'

    qui areg prestout numdailies i.year, absorb(cnty90)
    local tw_beta1 = _b[numdailies]

    qui count if w_gt > 0 & !missing(w_gt)
    local tw_npos1 = r(N)
    qui count if w_gt < 0 & !missing(w_gt)
    local tw_nneg1 = r(N)
    local tw_ntot1 = `tw_npos1' + `tw_nneg1'
    if `tw_ntot1' > 0 {
        local tw_pneg1 : di %5.1f (100 * `tw_nneg1' / `tw_ntot1')
    }

    di "  Beta TWFE (manual) = " %10.6f `tw_beta1'
    di "  # pos weights      = " `tw_npos1'
    di "  # neg weights      = " `tw_nneg1'
    di "  % neg weights      = " `tw_pneg1' "%"

    drop D_resid D_resid2 w_gt
}


/*==============================================================================
  STEP 3: SUMMARY
==============================================================================*/

di _n "============================================================"
di "  SUMMARY"
di "============================================================"
di "Table 2 replication:"
di "  Col 2: beta=" %7.4f `b_col2' " se=" %7.4f `se_col2' " N=" `n_col2'
di "  Col 3: beta=" %7.4f `b_col3' " se=" %7.4f `se_col3' " N=" `n_col3'
di "  Col 4: beta=" %7.4f `b_col4' " se=" %7.4f `se_col4' " N=" `n_col4'
di ""
di "twowayfeweights (T=year): rc=" `tw_rc1'
di "  beta=" `tw_beta1' ", npos=" `tw_npos1' ", nneg=" `tw_nneg1' ", %neg=" `tw_pneg1' "%"


/*==============================================================================
  STEP 4: EXPORT LATEX TABLES
==============================================================================*/

di _n "============================================================"
di "  STEP 4: LaTeX EXPORT"
di "============================================================"

cap mkdir "$texdir"

* ===================================================================
* TABLE A: Table 2 replication
* ===================================================================

esttab col2 col3 col4 using "$outdir/table2_replication.tex", replace ///
    keep(x_0) ///
    cells(b(star fmt(4)) se(par fmt(4))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(N N_clust styrfe controls, ///
        fmt(0 0) ///
        labels("Observations" "Clusters" "State $\times$ Year FE" "Demographics")) ///
    title("Table 2---Effect of Newspapers on Electoral Politics (Gentzkow et al., 2011)") ///
    mtitles("Pres.~Turnout" "Pres.~Turnout" "Cong.~Turnout") ///
    varlabels(x_0 "Newspaper entry/exit") ///
    note("Dependent variable: first difference of turnout. " ///
         "Panel: U.S. counties, 4-year election cycle intervals. " ///
         "Standard errors clustered by county in parentheses. " ///
         "*** p\$<\$0.01, ** p\$<\$0.05, * p\$<\$0.1.") ///
    booktabs nonumbers

di "  -> table2_replication.tex created"
cap copy "$outdir/table2_replication.tex" "$texdir/table2_replication.tex", replace

* ===================================================================
* TABLE B: twowayfeweights summary
* ===================================================================

local tw_beta1_s : di %10.6f `tw_beta1'
local tw_beta1_s = strtrim("`tw_beta1_s'")
local tw_npos1_s : di %6.0f `tw_npos1'
local tw_npos1_s = strtrim("`tw_npos1_s'")
local tw_nneg1_s : di %6.0f `tw_nneg1'
local tw_nneg1_s = strtrim("`tw_nneg1_s'")

if "`tw_pneg1'" == "" local tw_pneg1 = "N/A"

cap file close texfile
file open texfile using "$outdir/table_twowayfeweights.tex", write replace

file write texfile "\begin{table}[htbp]" _n
file write texfile "\centering" _n
file write texfile "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write texfile "\label{tab:gentzkow_twfe}" _n
file write texfile "\begin{tabular}{lc}" _n
file write texfile "\toprule" _n
file write texfile " & FE (feTR) \\" _n
file write texfile "\midrule" _n
file write texfile "\multicolumn{2}{l}{\textit{Panel A: Specification}} \\[3pt]" _n
file write texfile "Regression type & Fixed Effects \\" _n
file write texfile "Dependent variable & Presidential turnout \\" _n
file write texfile "Treatment variable & Number of daily newspapers \\" _n
file write texfile "Panel & Counties $\times$ election years \\[6pt]" _n
file write texfile "\multicolumn{2}{l}{\textit{Panel B: Weight Decomposition}} \\[3pt]" _n
file write texfile "$\hat{\beta}_{TWFE}$ & `tw_beta1_s' \\" _n
file write texfile "\# positive weights & `tw_npos1_s' \\" _n
file write texfile "\# negative weights & `tw_nneg1_s' \\" _n
file write texfile "\% negative weights & `tw_pneg1'\% \\" _n
file write texfile "\bottomrule" _n
file write texfile "\end{tabular}" _n
file write texfile _n
file write texfile "\vspace{6pt}" _n
file write texfile "\begin{minipage}{0.92\textwidth}" _n
file write texfile "\footnotesize" _n
file write texfile "\textit{Notes:} Panel B reports the weight decomposition of the TWFE estimator " _n
file write texfile "following de Chaisemartin \& D'Haultf\oe uille (2020). " _n
file write texfile "The treatment variable (number of daily newspapers) is discrete. " _n
file write texfile "The TWFE decomposition uses county and year fixed effects on the " _n
file write texfile "mainsample subsample." _n
file write texfile "\end{minipage}" _n
file write texfile "\end{table}" _n

file close texfile
di "  -> table_twowayfeweights.tex created"
cap copy "$outdir/table_twowayfeweights.tex" "$texdir/table_twowayfeweights.tex", replace

* ===================================================================
* MASTER DOCUMENT
* ===================================================================

cap file close fulltex
file open fulltex using "$outdir/gentzkow_tables.tex", write replace

file write fulltex "\documentclass[12pt]{article}" _n
file write fulltex "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write fulltex "\geometry{margin=1in}" _n
file write fulltex "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write fulltex "\begin{document}" _n _n

file write fulltex "\begin{center}" _n
file write fulltex "{\Large\bfseries Gentzkow, Shapiro \& Sinkinson (2011)}\\" _n
file write fulltex "{\large The Effect of Newspaper Entry and Exit}\\" _n
file write fulltex "{\large on Electoral Politics}\\" _n
file write fulltex "\vspace{0.5em}" _n
file write fulltex "{\normalsize \textit{American Economic Review}, 101(7), 2980--3018}" _n
file write fulltex "\end{center}" _n _n
file write fulltex "\vspace{1em}" _n _n

file write fulltex "\section*{1. Table 2 Replication}" _n _n
file write fulltex "We replicate columns 2--4 of Table 2 from the original paper. " _n
file write fulltex "The dependent variable is the first difference of voter turnout " _n
file write fulltex "(presidential or congressional) across U.S. counties. " _n
file write fulltex "The treatment variable captures newspaper entry and exit events. " _n
file write fulltex "All specifications absorb state $\times$ year fixed effects." _n _n

file write fulltex "\input{table2_replication}" _n _n
file write fulltex "\clearpage" _n _n

file write fulltex "\section*{2. Two-Way FE Weights Analysis}" _n _n
file write fulltex "We apply the decomposition of de Chaisemartin " _n
file write fulltex "\& D'Haultf\oe uille (2020) to the standard TWFE specification " _n
file write fulltex "(county + year FE) on the mainsample." _n _n

file write fulltex "\input{table_twowayfeweights}" _n _n

file write fulltex "\end{document}" _n

file close fulltex
di "  -> gentzkow_tables.tex created"
cap copy "$outdir/gentzkow_tables.tex" "$texdir/gentzkow_tables.tex", replace


di _n "============================================================"
di "  ALL DONE - Gentzkow et al. (2011)"
di "============================================================"
di "Output files:"
di "  1. $outdir/table2_replication.tex"
di "  2. $outdir/table_twowayfeweights.tex"
di "  3. $outdir/gentzkow_tables.tex (compilable master)"
di "  4. $outdir/run_twowayfe.log"
di "============================================================"

log close
