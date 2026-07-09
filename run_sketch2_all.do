/*==============================================================================
  run_sketch2_all.do
  Run classify_sketch2 on every paper's panel_GTD.dta (21 papers).
  Data loaded from: $twfe_root/panels_GTD/<wave>/<folder>/panel_GTD.dta
  Output:           $twfe_root/reports/sketch2_results.dta
==============================================================================*/

clear all
set more off
cap log close _all

* --------------------------------------------------------------------------
* User-detection block
* --------------------------------------------------------------------------
if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root   "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
    global papers_root "/Users/anzony.quisperojas/Documents/GitHub/papers_economic"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root   "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    global papers_root "C:/Users/Usuario/Documents/GitHub/papers_economic"
}
else {
    di as error "Unknown user `c(username)'."
    di as error "Add your paths to the user-detection block at the top of this file."
    exit 198
}

cap mkdir "$twfe_root/reports"
log using "$twfe_root/reports/sketch2_all.log", text replace

* --------------------------------------------------------------------------
* Load ado
* --------------------------------------------------------------------------
do "$twfe_root/classify_sketch2.ado"
adopath + "$twfe_root"

global panels_GTD "$twfe_root/panels_GTD"

* --------------------------------------------------------------------------
* Paper list
* --------------------------------------------------------------------------

* Wave 1: 2010–2012  (Acemoglu, Bagwell, Simcoe excluded)
local waves1   "2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012"
local folders1 `""Algan and Cahuc (2010)" "Baum-SnowandLutz(2011)" "Besley and Mueller (2012)" "Dinkelman (2011)" "Duranton and Turner (2011)" "Enikolopov et al. (2011)" "Faye and Niehaus (2012)" "Forman et al. (2012)" "Gentzkow et al. (2011)" "Hornbeck (2012)" "Moser and Voena (2012)" "Wang (2011)" "Zhang and Zhu (2011)""'
local n1 = 13

* Wave 2: 2015–2019
local waves2   "2015-2019 2015-2019 2015-2019 2015-2019 2015-2019 2015-2019 2015-2019 2015-2019"
local folders2 `""Antecol et al. (2018)" "Berman et al. (2017)" "Burgess et al. (2015)" "Donaldson (2018)" "Favara and Imbs (2015)" "Fetzer (2019)" "Kaur (2019)" "Suárez Serrato and Zidar (2016)""'
local n2 = 8

* --------------------------------------------------------------------------
* postfile: one row per paper
* --------------------------------------------------------------------------
tempfile tmp
postfile handle         ///
    str60  paper        ///
    str10  wave         ///
    str30  design       ///
    int    design_code  ///
    byte   had_stayers  ///
    str30  estimator    ///
    using `tmp', replace

* --- Wave 1 ---------------------------------------------------------------
forvalues i = 1/`n1' {
    local wave   : word `i' of `waves1'
    local folder : word `i' of `folders1'
    local dta    "$panels_GTD/`wave'/`folder'/panel_GTD.dta"

    di _n as text "================================================================"
    di    as text "  [`i'/21] `folder' (`wave')"
    di    as text "================================================================"

    local des   "FAILED"
    local est   ""
    local code  = -1
    local hs    = 0

    cap noisily {
        use "`dta'", clear
        classify_sketch2 Y G T D
        local des  "`r(design)'"
        local est  "`r(estimator)'"
        local code  = r(design_code)
        local hs    = r(had_stayers)
    }
    if _rc {
        di as error "  --> classify_sketch2 failed (rc=`_rc')"
        local des   "FAILED"
        local est   ""
        local code  = -1
        local hs    = 0
    }

    post handle ("`folder'") ("`wave'") ("`des'") (`code') (`hs') ("`est'")
}

* --- Wave 2 ---------------------------------------------------------------
forvalues i = 1/`n2' {
    local wave   : word `i' of `waves2'
    local folder : word `i' of `folders2'
    local dta    "$panels_GTD/`wave'/`folder'/panel_GTD.dta"
    local j = `n1' + `i'

    di _n as text "================================================================"
    di    as text "  [`j'/21] `folder' (`wave')"
    di    as text "================================================================"

    local des   "FAILED"
    local est   ""
    local code  = -1
    local hs    = 0

    cap noisily {
        use "`dta'", clear
        classify_sketch2 Y G T D
        local des  "`r(design)'"
        local est  "`r(estimator)'"
        local code  = r(design_code)
        local hs    = r(had_stayers)
    }
    if _rc {
        di as error "  --> classify_sketch2 failed (rc=`_rc')"
        local des   "FAILED"
        local est   ""
        local code  = -1
        local hs    = 0
    }

    post handle ("`folder'") ("`wave'") ("`des'") (`code') (`hs') ("`est'")
}

postclose handle

* --------------------------------------------------------------------------
* Build final dataset
* --------------------------------------------------------------------------
use `tmp', clear

label define design_lbl     ///
    1  "CLA"                ///
    2  "SAD"                ///
    3  "HAD with stayers"   ///
    4  "SSFSD"              ///
    5  "SFSD"               ///
    6  "HAD w/o stayers"    ///
    8  "OTHER"              ///
    -1 "FAILED", replace
label values design_code design_lbl

label var paper        "Paper name"
label var wave         "Publication wave"
label var design       "classify_sketch2: design label"
label var design_code  "classify_sketch2: design code (1=CLA 2=SAD 3=HAD-stayers 4=SSFSD 5=SFSD 6=HAD 8=OTHER)"
label var had_stayers  "1 if HAD with stayers"
label var estimator    "Recommended estimator"

sort wave paper
save "$twfe_root/reports/sketch2_results.dta", replace

* --------------------------------------------------------------------------
* Summary
* --------------------------------------------------------------------------
di _n as text "================================================================"
di    as text "  RESULTS: classify_sketch2 — 21 papers"
di    as text "================================================================"
list paper wave design design_code, sep(0) noobs abbrev(30)

di _n as text "Counts by design:"
tab design, sort

di _n "Results saved to: $twfe_root/reports/sketch2_results.dta"
cap log close
