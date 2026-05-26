/*==============================================================================
  classify_loop.do — Classify all 24 papers automatically via loop

  For each paper:
    1. Load panel_GTD.dta
    2. Detect G, T, D variables from their labels (prefix "G:", "T:", "D:")
    3. Run classify_design G T D
    4. Append result to classify_results_loop.txt

  Run with:
    "D:/era_data2/StataMP-64.exe" -b do "C:/Users/Usuario/Documents/GitHub/twfe_survey/classify_loop.do"
==============================================================================*/

clear all
set more off

* --- Paths ---
local basedir "C:/Users/Usuario/Documents/GitHub/twfe_survey"
adopath + "D:/era_data2/ado/plus"
adopath + "`basedir'"

* --- Output file ---
local resfile "`basedir'/classify_results_loop.txt"
cap file close fh
file open fh using "`resfile'", write replace
file write fh "paper|G|T|D|Y|design|subtype" _n
file close fh

* ==============================================================================
*  Build list of all 24 papers:  wave \ folder
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
local p`n_papers' "Suárez Serrato and Zidar (2016)"

di _n "Total papers to process: `n_papers'"
assert `n_papers' == 24


* ==============================================================================
*  MAIN LOOP
* ==============================================================================
local n_ok   = 0
local n_fail = 0

forvalues i = 1/`n_papers' {

    local pname "`p`i''"
    local wname "`w`i''"
    local dtapath "`basedir'/replications/`wname'/`pname'/panel_GTD.dta"

    di _n _n ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    di ">>> PAPER `i': `pname'"
    di ">>> File: `dtapath'"
    di ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    * --- Load panel ---
    cap confirm file "`dtapath'"
    if _rc {
        di as error "   FILE NOT FOUND: `dtapath'"
        local ++n_fail
        continue
    }

    cap noisily use "`dtapath'", clear
    if _rc {
        di as error "   FAILED TO LOAD: `dtapath'"
        local ++n_fail
        continue
    }

    * --- Auto-detect G, T, D, Y from variable labels ---
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

    * --- Validate detection ---
    if "`gvar'" == "" | "`tvar'" == "" | "`dvar'" == "" {
        di as error "   COULD NOT DETECT G/T/D variables for `pname'"
        di as error "   G=`gvar'  T=`tvar'  D=`dvar'"
        local ++n_fail
        continue
    }

    di "   Detected:  G = `gvar'   T = `tvar'   D = `dvar'   Y = `yvar'"

    * --- Run classify_design ---
    local d "FAILED"
    local s ""
    cap noisily {
        classify_design `gvar' `tvar' `dvar'
        local d "`r(design)'"
        local s "`r(subtype)'"
    }

    di ">>> RESULT `pname': `d' `s'"

    * --- Append to output ---
    cap file close fh
    file open fh using "`resfile'", write append
    file write fh "`pname'|`gvar'|`tvar'|`dvar'|`yvar'|`d'|`s'" _n
    file close fh

    local ++n_ok
}


* ==============================================================================
*  SUMMARY
* ==============================================================================
di _n _n "==============================================================="
di "  CLASSIFICATION LOOP COMPLETE"
di "  Processed: `n_ok' OK,  `n_fail' FAILED,  Total: `n_papers'"
di "  Results:   `resfile'"
di "==============================================================="

cap file close fh
type "`resfile'"

di _n "DONE."
