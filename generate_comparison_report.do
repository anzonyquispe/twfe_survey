/*==============================================================================
  generate_comparison_report.do

  For each of 24 papers:
    1. Run classify_design.ado  -> classification result
    2. Run twowayfeweights      -> individual weights + histogram
    3. Run sketch_did_design.do -> Clement's classification

  Outputs:
    - reports/comparison/comparison_report.tex  (LaTeX -> PDF)
    - reports/comparison/summary_comparison.xlsx
    - reports/comparison/comparison_results.csv
    - reports/comparison/histograms/hist_*.png

  Run:
    "D:/era_data2/StataMP-64.exe" -b do "C:/Users/Usuario/Documents/GitHub/twfe_survey/generate_comparison_report.do"
==============================================================================*/

clear all
set more off
cap log close _all
cap log close _sketch

global basedir "C:/Users/Usuario/Documents/GitHub/twfe_survey"
global outdir  "$basedir/reports/comparison"
global imgdir  "$outdir/histograms"

adopath + "D:/era_data2/ado/plus"
adopath + "$basedir"

cap mkdir "$outdir"
cap mkdir "$imgdir"

log using "$outdir/generate_comparison_report.log", text replace

* ==============================================================================
*  PAPER LIST (24 papers — same as classify_loop.do)
* ==============================================================================
local n_papers = 0

* --- Wave 1: 2010-2012 (16 papers) ---
local wave1 "2010-2012"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Algan and Cahuc (2010)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Zhang and Zhu (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Bagwell and Staiger (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Wang (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Duranton and Turner (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Moser and Voena (2012)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Enikolopov et al. (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Forman et al. (2012)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Acemoglu et al. (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Hornbeck (2012)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Besley and Mueller (2012)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Simcoe (2012)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Dinkelman (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Gentzkow et al. (2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Baum-SnowandLutz(2011)"

local ++n_papers
local w`n_papers' "`wave1'"
local p`n_papers' "Faye and Niehaus (2012)"

* --- Wave 2: 2015-2019 (8 papers) ---
local wave2 "2015-2019"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Antecol et al. (2018)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Berman et al. (2017)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Burgess et al. (2015)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Donaldson (2018)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Favara and Imbs (2015)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Fetzer (2019)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' "Kaur (2019)"

local ++n_papers
local w`n_papers' "`wave2'"
local p`n_papers' `"Suárez Serrato and Zidar (2016)"'

di _n "Total papers to process: `n_papers'"
assert `n_papers' == 24

* ==============================================================================
*  INITIALIZE OUTPUT FILES
* ==============================================================================

* --- CSV ---
cap file close csvfh
file open csvfh using "$outdir/comparison_results.csv", write replace
file write csvfh "paper,wave,G,T,D,Y,n_pos,n_neg,sum_pos,sum_neg,pct_neg,classify_design,classify_subtype,sketch_design,notes" _n

* --- LaTeX main document ---
cap file close texfh
file open texfh using "$outdir/comparison_report.tex", write replace

file write texfh "\documentclass[11pt]{article}" _n
file write texfh "\usepackage[utf8]{inputenc}" _n
file write texfh "\usepackage[T1]{fontenc}" _n
file write texfh "\usepackage{booktabs,caption,geometry,graphicx,longtable,array,xcolor,float}" _n
file write texfh "\geometry{margin=0.75in}" _n
file write texfh "\captionsetup{font=small}" _n
file write texfh "\definecolor{match}{RGB}{0,128,0}" _n
file write texfh "\definecolor{mismatch}{RGB}{200,0,0}" _n
file write texfh "\begin{document}" _n _n

file write texfh "\begin{center}" _n
file write texfh "{\LARGE\bfseries TWFE Survey: Design Classification Comparison}\\\\[0.5em]" _n
file write texfh "{\large \texttt{classify\_design.ado} vs \texttt{sketch\_did\_design.do}}\\\\[0.5em]" _n
file write texfh "{\normalsize Generated: \today}\\\\[0.3em]" _n
file write texfh "{\normalsize 24 papers from AER 2010--2019}" _n
file write texfh "\end{center}" _n
file write texfh "\vspace{1em}" _n _n

* --- LaTeX summary rows (separate file for inclusion later) ---
cap file close sumfh
file open sumfh using "$outdir/summary_rows.tex", write replace

* ==============================================================================
*  MAIN LOOP — process each paper serially
* ==============================================================================
local n_ok   = 0
local n_fail = 0

forvalues i = 1/`n_papers' {

    local pname  "`p`i''"
    local wname  "`w`i''"
    local dtapath "$basedir/replications/`wname'/`pname'/panel_GTD.dta"

    di _n _n "================================================================"
    di ">>> PAPER `i'/`n_papers': `pname'"
    di ">>> Wave: `wname'"
    di "================================================================"

    * --- Check file exists ---
    cap confirm file "`dtapath'"
    if _rc {
        di as error "   FILE NOT FOUND: `dtapath'"
        local ++n_fail

        * Store failure results
        local r_gvar_`i'  ""
        local r_tvar_`i'  ""
        local r_dvar_`i'  ""
        local r_yvar_`i'  ""
        local r_npos_`i'  "."
        local r_nneg_`i'  "."
        local r_pneg_`i'  "."
        local r_spos_`i'  "."
        local r_sneg_`i'  "."
        local r_cd_`i'    "FILE_NOT_FOUND"
        local r_cs_`i'    ""
        local r_sk_`i'    "FILE_NOT_FOUND"
        continue
    }

    * ==========================================================================
    *  STEP A: Load data and detect G, T, D, Y variables
    * ==========================================================================
    use "`dtapath'", clear

    local gvar ""
    local tvar ""
    local dvar ""
    local yvar ""

    foreach v of varlist * {
        local lab : variable label `v'
        if substr("`lab'", 1, 2) == "G:" local gvar "`v'"
        if substr("`lab'", 1, 2) == "T:" local tvar "`v'"
        if substr("`lab'", 1, 2) == "D:" local dvar "`v'"
        if substr("`lab'", 1, 2) == "Y:" local yvar "`v'"
    }

    di "   G=`gvar'  T=`tvar'  D=`dvar'  Y=`yvar'"

    if "`gvar'" == "" | "`tvar'" == "" | "`dvar'" == "" {
        di as error "   CANNOT DETECT G/T/D — skipping"
        local ++n_fail
        local r_gvar_`i'  "`gvar'"
        local r_tvar_`i'  "`tvar'"
        local r_dvar_`i'  "`dvar'"
        local r_yvar_`i'  "`yvar'"
        local r_npos_`i'  "."
        local r_nneg_`i'  "."
        local r_pneg_`i'  "."
        local r_spos_`i'  "."
        local r_sneg_`i'  "."
        local r_cd_`i'    "DETECT_FAIL"
        local r_cs_`i'    ""
        local r_sk_`i'    "DETECT_FAIL"
        continue
    }

    * Store variable names
    local r_gvar_`i' "`gvar'"
    local r_tvar_`i' "`tvar'"
    local r_dvar_`i' "`dvar'"
    local r_yvar_`i' "`yvar'"

    * ==========================================================================
    *  STEP B: Run classify_design.ado
    * ==========================================================================
    di _n "--- classify_design ---"

    local cd_design "FAILED"
    local cd_subtype ""

    preserve
    cap noisily {
        classify_design `gvar' `tvar' `dvar'
        local cd_design "`r(design)'"
        local cd_subtype "`r(subtype)'"
    }
    restore

    di "   => classify_design result: `cd_design' `cd_subtype'"
    local r_cd_`i' "`cd_design'"
    local r_cs_`i' "`cd_subtype'"

    * ==========================================================================
    *  STEP C: Run twowayfeweights (with path to save individual weights)
    * ==========================================================================
    di _n "--- twowayfeweights ---"

    local tw_npos = .
    local tw_nneg = .
    local tw_spos = .
    local tw_sneg = .
    local tw_pneg = .
    local tw_ok   = 0

    * Reload clean data (classify_design was inside preserve/restore but be safe)
    use "`dtapath'", clear

    * Delete old weights and histogram files to avoid stale data from previous runs
    cap erase "$outdir/weights_`i'.dta"
    cap erase "$imgdir/hist_`i'.png"

    * --- Preprocessing for twowayfeweights ---
    * Destring if any key variable is stored as string
    foreach v in `gvar' `tvar' `dvar' `yvar' {
        cap confirm string var `v'
        if _rc == 0 {
            di "   NOTE: Destringing `v' (was string)"
            destring `v', replace force
        }
    }

    * Drop observations with missing key variables
    local pre_N = _N
    qui drop if missing(`gvar') | missing(`tvar') | missing(`dvar')
    if "`yvar'" != "" {
        qui drop if missing(`yvar')
    }
    local post_N = _N
    if `pre_N' != `post_N' {
        di "   NOTE: Dropped " `pre_N' - `post_N' " obs with missing values"
    }

    * Ensure G > 0 for factor variables
    qui sum `gvar'
    if r(min) <= 0 {
        local g_shift = abs(r(min)) + 1
        qui replace `gvar' = `gvar' + `g_shift'
        di "   NOTE: Shifted G (`gvar') by +`g_shift' to ensure positive values"
    }

    * Ensure T > 0 for factor variables
    qui sum `tvar'
    if r(min) <= 0 {
        local t_shift = abs(r(min)) + 1
        qui replace `tvar' = `tvar' + `t_shift'
        di "   NOTE: Shifted T (`tvar') by +`t_shift' to ensure positive values"
    }

    * Recast G and T to long integer (avoids float precision issues with factor vars)
    qui replace `gvar' = round(`gvar')
    qui replace `tvar' = round(`tvar')
    cap recast long `gvar', force
    cap recast long `tvar', force

    local tw_errnote ""

    cap noisily twowayfeweights `yvar' `gvar' `tvar' `dvar', type(feTR) ///
        path("$outdir/weights_`i'.dta")

    if _rc == 0 {
        cap {
            matrix _twM = e(M)
            local tw_npos = _twM[1,1]
            local tw_nneg = _twM[2,1]
            local tw_spos = _twM[1,2]
            local tw_sneg = _twM[2,2]
            local tw_total = `tw_npos' + `tw_nneg'
            if `tw_total' > 0 {
                local tw_pneg = 100 * `tw_nneg' / `tw_total'
            }
            else {
                local tw_pneg = 0
            }
            local tw_ok = 1
        }
        if _rc != 0 {
            di as error "   Could not extract e(M) matrix"
        }
    }
    else {
        local tw_errrc = _rc
        di as error "   twowayfeweights failed with rc = `tw_errrc'"
        if `tw_errrc' == 402 {
            local tw_errnote "Panel structure incompatible with TWFE weight decomposition (rc=402)"
        }
        else if `tw_errrc' == 452 {
            local tw_errnote "Negative values in factor variables (rc=452)"
        }
        else if `tw_errrc' == 109 {
            local tw_errnote "Type mismatch in variables (rc=109)"
        }
        else {
            local tw_errnote "Computation failed (rc=`tw_errrc')"
        }
    }

    di "   => Pos weights: `tw_npos'  Neg weights: `tw_nneg'  %Neg: " %5.1f `tw_pneg'

    * --- Fallback: if twowayfeweights failed but DID create a weights file,
    *     extract statistics directly from the file ---
    if `tw_ok' == 0 {
        cap confirm file "$outdir/weights_`i'.dta"
        if _rc == 0 {
            di "   NOTE: Extracting weight stats directly from weights file (fallback)"
            preserve
            cap {
                use "$outdir/weights_`i'.dta", clear
                qui count if weight > 0 & !missing(weight)
                local tw_npos = r(N)
                qui count if weight < 0 & !missing(weight)
                local tw_nneg = r(N)
                qui sum weight if weight > 0 & !missing(weight)
                local tw_spos = r(sum)
                qui sum weight if weight < 0 & !missing(weight)
                local tw_sneg = r(sum)
                local tw_total = `tw_npos' + `tw_nneg'
                if `tw_total' > 0 {
                    local tw_pneg = 100 * `tw_nneg' / `tw_total'
                    local tw_ok = 1
                    local tw_errnote "Weights extracted from file (twowayfeweights partial success)"
                }
                else {
                    local tw_pneg = .
                    local tw_npos = .
                    local tw_nneg = .
                    local tw_spos = .
                    local tw_sneg = .
                    local tw_errnote "Weights file created but all weights are zero/missing — degenerate panel (rc=109)"
                }
            }
            restore
        }
    }

    local r_npos_`i' "`tw_npos'"
    local r_nneg_`i' "`tw_nneg'"
    local r_spos_`i' = string(`tw_spos', "%9.4f")
    local r_sneg_`i' = string(`tw_sneg', "%9.4f")
    local r_pneg_`i' = string(`tw_pneg', "%5.1f")
    local r_note_`i' "`tw_errnote'"

    * ==========================================================================
    *  STEP D: Generate histogram of weights
    * ==========================================================================
    di _n "--- Histogram ---"

    local hist_ok = 0
    cap confirm file "$outdir/weights_`i'.dta"
    if _rc == 0 {
        use "$outdir/weights_`i'.dta", clear
        qui count
        local nw = r(N)

        if `nw' >= 2 {
            cap {
                local spos_fmt = string(`tw_spos', "%6.4f")
                local sneg_fmt = string(`tw_sneg', "%6.4f")
                local pneg_fmt = string(`tw_pneg', "%4.1f")

                histogram weight, bin(30) ///
                    fcolor(navy%60) lcolor(navy) ///
                    xline(0, lcolor(red) lwidth(medium) lpattern(dash)) ///
                    title("`pname'", size(medium)) ///
                    subtitle("TWFE Weights Distribution (feTR)", size(small)) ///
                    xtitle("Weight", size(small)) ytitle("Density", size(small)) ///
                    note("Pos: `tw_npos' ({&Sigma}=`spos_fmt')   Neg: `tw_nneg' ({&Sigma}=`sneg_fmt')   %Neg: `pneg_fmt'%", size(vsmall)) ///
                    scheme(s2color)
                graph export "$imgdir/hist_`i'.png", as(png) replace width(900) height(550)
                local hist_ok = 1
            }
            if _rc != 0 {
                di as error "   Histogram generation failed"
            }
        }
        else {
            di "   Only `nw' weight(s) — skipping histogram"
        }
    }
    else {
        di "   No weights file — skipping histogram"
    }

    * ==========================================================================
    *  STEP E: Run sketch_did_design.do (Clement's classification)
    *  Classify from variables created by sketch, not from log parsing
    *  (log echoes unexecuted commands which confuse text parsing)
    * ==========================================================================
    di _n "--- sketch_did_design ---"

    local sk_design "FAILED"

    use "`dtapath'", clear

    * Rename variables to g, t, d as expected by sketch_did_design.do
    cap rename `gvar' g
    cap rename `tvar' t
    cap rename `dvar' d
    if "`yvar'" != "" {
        cap rename `yvar' y_outcome
    }

    * Run sketch via log capture (keep log for reference)
    cap log close _sketch
    log using "$outdir/sketch_log_`i'.log", text replace name(_sketch)
    cap noisily do "$basedir/sketch_did_design.do"
    local sketch_rc = _rc
    cap log close _sketch

    if `sketch_rc' != 0 {
        di as error "   sketch_did_design.do failed with rc = `sketch_rc'"
    }

    * --- Classify from the variables sketch_did_design.do created ---
    * Key variable: sd_Fg (sd of first-switch date across all groups)
    * sd_Fg == 0 → all groups switch at same time → HAD / SSD / Other
    * sd_Fg >  0 → staggered timing → CLA / SAD / SFSD

    local sdFg = .
    cap {
        qui sum sd_Fg
        local sdFg = r(mean)
    }

    if `sdFg' == . {
        * sd_Fg not available — sketch probably failed
        local sk_design "FAILED"
    }
    else if `sdFg' == 0 {
        * === Branch 1: all groups switch at same time ===
        local sk_design "Other"

        * Check HAD: sd of first_change > 0?
        cap confirm var sd_first_change
        if _rc == 0 {
            qui sum sd_first_change
            if !missing(r(mean)) & r(mean) > 0 {
                local sk_design "HAD"
            }
        }

        * If not HAD, check Switchers-and-Stayers
        if "`sk_design'" == "Other" {
            cap confirm var switchers_and_stayers
            if _rc == 0 {
                qui sum switchers_and_stayers
                if !missing(r(max)) & r(max) == 1 {
                    local sk_design "SSD"
                }
            }
        }
    }
    else {
        * === Branch 2: sd_Fg > 0  (staggered switch timing) ===
        * Check binary treatment
        local is_binary = 0
        cap {
            local is_binary = scalar(binary)
        }

        * Check absorbing treatment
        local abs_ok = 0
        cap confirm var absorbing
        if _rc == 0 {
            qui sum absorbing
            if r(N) > 0 & !missing(r(min)) & r(min) == 1 {
                local abs_ok = 1
            }
        }

        if `abs_ok' == 1 & `is_binary' == 1 {
            * Binary + absorbing → CLA or SAD
            local sk_design "CLA"
            cap confirm var sd_Fg_among_switchers
            if _rc == 0 {
                qui sum sd_Fg_among_switchers
                if !missing(r(mean)) & r(mean) > 0 {
                    local sk_design "SAD"
                }
            }
        }
        else {
            * Not (binary AND absorbing) → SFSD
            local sk_design "SFSD"
        }
    }

    di "   => sketch_did_design result: `sk_design'"
    local r_sk_`i' "`sk_design'"

    * ==========================================================================
    *  STEP F: Write CSV row
    * ==========================================================================
    file write csvfh `"`pname',`wname',`gvar',`tvar',`dvar',`yvar',`tw_npos',`tw_nneg',`r_spos_`i'',`r_sneg_`i'',`r_pneg_`i'',`cd_design',`cd_subtype',`sk_design',`tw_errnote'"' _n

    * ==========================================================================
    *  STEP G: Write LaTeX section for this paper
    * ==========================================================================

    * Escape underscores for LaTeX
    local gvar_e = subinstr("`gvar'", "_", "\_", .)
    local tvar_e = subinstr("`tvar'", "_", "\_", .)
    local dvar_e = subinstr("`dvar'", "_", "\_", .)
    local yvar_e = subinstr("`yvar'", "_", "\_", .)
    local pname_e = subinstr("`pname'", "&", "\&", .)

    * Determine match color
    local matchcolor "match"
    if "`cd_design'" != "`sk_design'" {
        local matchcolor "mismatch"
    }

    file write texfh "\newpage" _n
    file write texfh `"\section*{Paper `i': `pname_e'}"' _n _n

    * Variable info table
    file write texfh "\begin{table}[H]" _n
    file write texfh "\centering" _n
    file write texfh `"\caption*{Panel structure — `pname_e'}"' _n
    file write texfh "\begin{tabular}{ll}" _n
    file write texfh "\toprule" _n
    file write texfh `"Wave & `wname' \\"' _n
    file write texfh `"Group (G) & \texttt{`gvar_e'} \\"' _n
    file write texfh `"Time (T) & \texttt{`tvar_e'} \\"' _n
    file write texfh `"Treatment (D) & \texttt{`dvar_e'} \\"' _n
    file write texfh `"Outcome (Y) & \texttt{`yvar_e'} \\"' _n
    file write texfh "\bottomrule" _n
    file write texfh "\end{tabular}" _n
    file write texfh "\end{table}" _n _n

    * Histogram — only include if twowayfeweights actually succeeded
    if `tw_ok' == 1 {
        cap confirm file "$imgdir/hist_`i'.png"
        if _rc == 0 {
            file write texfh "\begin{figure}[H]" _n
            file write texfh "\centering" _n
            file write texfh "\includegraphics[width=0.85\textwidth]{histograms/hist_`i'.png}" _n
            file write texfh `"\caption*{TWFE weight distribution — `pname_e'}"' _n
            file write texfh "\end{figure}" _n _n
        }
    }
    else {
        file write texfh "\begin{center}" _n
        if "`tw_errnote'" != "" {
            file write texfh "\fbox{\parbox{0.85\textwidth}{\small" _n
            file write texfh "\textit{Histogram not available.}\\[0.3em]" _n
            file write texfh `"\textbf{Reason:} `tw_errnote'"' _n
            file write texfh "}}" _n
        }
        else {
            file write texfh "\textit{[Histogram not available]}" _n
        }
        file write texfh "\end{center}" _n
        file write texfh "\vspace{1em}" _n _n
    }

    * Classification comparison table
    file write texfh "\begin{table}[H]" _n
    file write texfh "\centering" _n
    file write texfh `"\caption*{Classification comparison — `pname_e'}"' _n
    file write texfh "\begin{tabular}{lcc}" _n
    file write texfh "\toprule" _n
    file write texfh " & \textbf{classify\_design.ado} & \textbf{sketch\_did\_design.do} \\" _n
    file write texfh "\midrule" _n

    * Color-code the match/mismatch
    if "`cd_design'" == "`sk_design'" {
        file write texfh `"Design & \textcolor{match}{`cd_design'} & \textcolor{match}{`sk_design'} \\"' _n
    }
    else {
        file write texfh `"Design & \textcolor{mismatch}{`cd_design'} & \textcolor{mismatch}{`sk_design'} \\"' _n
    }

    if "`cd_subtype'" != "" {
        file write texfh `"Subtype & `cd_subtype' & --- \\"' _n
    }
    file write texfh "\addlinespace" _n

    local spos_f = string(`tw_spos', "%7.4f")
    local sneg_f = string(`tw_sneg', "%7.4f")
    local pneg_f = string(`tw_pneg', "%5.1f")

    file write texfh `"\# Positive weights & `tw_npos' & \\"' _n
    file write texfh `"\# Negative weights & `tw_nneg' & \\"' _n
    file write texfh `"$\Sigma$ positive & `spos_f' & \\"' _n
    file write texfh `"$\Sigma$ negative & `sneg_f' & \\"' _n
    file write texfh `"\% Negative & `pneg_f'\% & \\"' _n
    if "`tw_errnote'" != "" {
        file write texfh "\addlinespace" _n
        file write texfh `"\multicolumn{3}{p{10cm}}{\small\textit{Note: `tw_errnote'}} \\"' _n
    }
    file write texfh "\bottomrule" _n
    file write texfh "\end{tabular}" _n
    file write texfh "\end{table}" _n _n

    * --- Summary row (for the summary table at the end) ---
    local pname_short = substr("`pname_e'", 1, 35)
    file write sumfh `"`pname_short' & `gvar_e' & `dvar_e' & `pneg_f'\% & `cd_design' & `sk_design' \\"' _n

    local ++n_ok

    di _n ">>> DONE: `pname' — classify=`cd_design' sketch=`sk_design'"
}

* ==============================================================================
*  CLOSE CSV
* ==============================================================================
file close csvfh
di _n "CSV saved: $outdir/comparison_results.csv"

* ==============================================================================
*  SUMMARY TABLE IN LATEX
* ==============================================================================
file close sumfh

file write texfh "\newpage" _n
file write texfh "\section*{Summary: All 24 Papers}" _n _n

file write texfh "\begin{center}" _n
file write texfh "\small" _n
file write texfh "\begin{longtable}{p{5.5cm}llrcc}" _n
file write texfh "\toprule" _n
file write texfh "Paper & G & D & \% Neg & classify\_design & sketch\_design \\" _n
file write texfh "\midrule" _n
file write texfh "\endhead" _n
file write texfh "\input{summary_rows}" _n
file write texfh "\bottomrule" _n
file write texfh "\end{longtable}" _n
file write texfh "\end{center}" _n _n

* Legend
file write texfh "\vspace{1em}" _n
file write texfh "\noindent\textbf{Design codes:}" _n
file write texfh "\begin{itemize}" _n
file write texfh "\item \textbf{CLA} — Classical DID (single adoption date, binary treatment)" _n
file write texfh "\item \textbf{SAD} — Staggered Adoption Design (multiple adoption dates, binary)" _n
file write texfh "\item \textbf{SFSD} — Staggered First Switch Design (non-binary/non-absorbing)" _n
file write texfh "\item \textbf{HAD} — Heterogeneous Adoption Design (common adoption, heterogeneous dose)" _n
file write texfh "\item \textbf{SSD} — Switchers and Stayers Design (sketch\_did\_design only)" _n
file write texfh "\item \textbf{Other} — Does not fit the above categories" _n
file write texfh "\end{itemize}" _n _n

file write texfh "\noindent\textcolor{match}{Green} = both methods agree. " _n
file write texfh "\textcolor{mismatch}{Red} = methods disagree." _n _n

file write texfh "\end{document}" _n
file close texfh

di _n "LaTeX saved: $outdir/comparison_report.tex"

* ==============================================================================
*  EXCEL SUMMARY (putexcel)
* ==============================================================================
di _n "Generating Excel summary..."

putexcel set "$outdir/summary_comparison.xlsx", replace sheet("Summary")

* Headers
putexcel A1 = "Paper"
putexcel B1 = "Wave"
putexcel C1 = "G"
putexcel D1 = "T"
putexcel E1 = "D"
putexcel F1 = "Y"
putexcel G1 = "# Pos Weights"
putexcel H1 = "# Neg Weights"
putexcel I1 = "% Neg Weights"
putexcel J1 = "Sum Pos"
putexcel K1 = "Sum Neg"
putexcel L1 = "classify_design"
putexcel M1 = "Subtype"
putexcel N1 = "sketch_design"
putexcel O1 = "Match?"
putexcel P1 = "Notes"

putexcel A1:P1, bold border(bottom)

* Data rows
forvalues i = 1/`n_papers' {
    local row = `i' + 1

    putexcel A`row' = `"`p`i''"'
    putexcel B`row' = "`w`i''"
    putexcel C`row' = "`r_gvar_`i''"
    putexcel D`row' = "`r_tvar_`i''"
    putexcel E`row' = "`r_dvar_`i''"
    putexcel F`row' = "`r_yvar_`i''"

    * Numeric values
    cap putexcel G`row' = `r_npos_`i''
    cap putexcel H`row' = `r_nneg_`i''
    cap putexcel I`row' = `r_pneg_`i''
    cap putexcel J`row' = `r_spos_`i''
    cap putexcel K`row' = `r_sneg_`i''

    putexcel L`row' = "`r_cd_`i''"
    putexcel M`row' = "`r_cs_`i''"
    putexcel N`row' = "`r_sk_`i''"

    * Match indicator
    if "`r_cd_`i''" == "`r_sk_`i''" {
        putexcel O`row' = "YES"
    }
    else {
        putexcel O`row' = "NO"
    }

    * Notes
    putexcel P`row' = "`r_note_`i''"
}

putexcel save
di "Excel saved: $outdir/summary_comparison.xlsx"

* ==============================================================================
*  FINAL SUMMARY
* ==============================================================================
di _n _n "==============================================================="
di "  COMPARISON REPORT COMPLETE"
di "  Processed: `n_ok' OK,  `n_fail' FAILED,  Total: `n_papers'"
di "==============================================================="
di "  Outputs:"
di "    1. $outdir/comparison_results.csv"
di "    2. $outdir/comparison_report.tex"
di "    3. $outdir/summary_comparison.xlsx"
di "    4. $imgdir/hist_*.png"
di "==============================================================="
di "  Next step: compile LaTeX with"
di `"    pdflatex -output-directory="$outdir" "$outdir/comparison_report.tex""'
di "==============================================================="

* Count matches
local n_match = 0
local n_mismatch = 0
forvalues i = 1/`n_papers' {
    if "`r_cd_`i''" == "`r_sk_`i''" {
        local ++n_match
    }
    else {
        local ++n_mismatch
        di "  MISMATCH paper `i': `p`i'' — classify=`r_cd_`i'' vs sketch=`r_sk_`i''"
    }
}
di _n "  Matches: `n_match' / `n_papers'"
di "  Mismatches: `n_mismatch' / `n_papers'"

log close _all
