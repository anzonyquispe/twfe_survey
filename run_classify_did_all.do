/*==============================================================================
  run_classify_did_all.do
  Run classify_did AND classify_sketch2 on every paper's panel_GTD.dta.
  Output: $twfe_root/reports/classify_did_results.dta
          (one row per paper: paper, wave, plus results from both classifiers)

  Do NOT modify all_replications.do or classify_all_papers.do — this is a
  standalone script.
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
log using "$twfe_root/reports/classify_did_all.log", text replace

* --------------------------------------------------------------------------
* Load ados
* --------------------------------------------------------------------------
do "$twfe_root/classify_did.ado"
do "$twfe_root/classify_sketch2.ado"
adopath + "$twfe_root"

* --------------------------------------------------------------------------
* Paper list  (wave | folder-relative path | display name)
* --------------------------------------------------------------------------

* Wave 1: 2010–2012  (Acemoglu, Bagwell, Simcoe excluded)
local waves    "2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012 2010-2012"
local folders  `""Algan and Cahuc (2010)" "Baum-SnowandLutz(2011)" "Besley and Mueller (2012)" "Dinkelman (2011)" "Duranton and Turner (2011)" "Enikolopov et al. (2011)" "Faye and Niehaus (2012)" "Forman et al. (2012)" "Gentzkow et al. (2011)" "Hornbeck (2012)" "Moser and Voena (2012)" "Wang (2011)" "Zhang and Zhu (2011)""'
local n1 = 13

* Wave 2: 2015–2019
local waves2   "2015-2019 2015-2019 2015-2019 2015-2019 2015-2019 2015-2019 2015-2019 2015-2019"
local folders2 `""Antecol et al. (2018)" "Berman et al. (2017)" "Burgess et al. (2015)" "Donaldson (2018)" "Favara and Imbs (2015)" "Fetzer (2019)" "Kaur (2019)" "Suárez Serrato and Zidar (2016)""'
local n2 = 8

* --------------------------------------------------------------------------
* postfile: one row per paper, results from both classifiers
* --------------------------------------------------------------------------
tempfile tmp
postfile handle                 ///
    str60  paper                ///
    str10  wave                 ///
    str30  design               ///
    int    design_code          ///
    byte   had_stayers          ///
    str30  estimator            ///
    str30  design_s2            ///
    int    design_code_s2       ///
    byte   had_stayers_s2       ///
    str30  estimator_s2         ///
    using `tmp', replace

* --------------------------------------------------------------------------
* Helper macro: run both classifiers for one paper
* --------------------------------------------------------------------------
* (called inline in each forvalues loop — Stata macros can't be subroutines,
*  so we repeat the block; both loops are identical except for the counter)

* --- Wave 1 ---------------------------------------------------------------
forvalues i = 1/`n1' {
    local wave   : word `i' of `waves'
    local folder : word `i' of `folders'
    local dta    "$twfe_root/replications/`wave'/`folder'/panel_GTD.dta"

    di _n as text "================================================================"
    di    as text "  [`i'/21] `folder' (`wave')"
    di    as text "================================================================"

    * ---- classify_did -------------------------------------------------------
    local des   "FAILED"
    local est   ""
    local code  = -1
    local hs    = 0

    cap noisily {
        use "`dta'", clear
        classify_did Y G T D
        local des  "`r(design)'"
        local est  "`r(estimator)'"
        local code  = r(design_code)
        local hs    = r(had_stayers)
    }
    if _rc {
        di as error "  --> classify_did failed (rc=`_rc')"
        local des   "FAILED"
        local est   ""
        local code  = -1
        local hs    = 0
    }

    * ---- classify_sketch2 --------------------------------------------------
    local des2   "FAILED"
    local est2   ""
    local code2  = -1
    local hs2    = 0

    cap noisily {
        use "`dta'", clear
        classify_sketch2 Y G T D
        local des2  "`r(design)'"
        local est2  "`r(estimator)'"
        local code2  = r(design_code)
        local hs2    = r(had_stayers)
    }
    if _rc {
        di as error "  --> classify_sketch2 failed (rc=`_rc')"
        local des2   "FAILED"
        local est2   ""
        local code2  = -1
        local hs2    = 0
    }

    post handle                                                     ///
        ("`folder'") ("`wave'")                                     ///
        ("`des'")  (`code')  (`hs')  ("`est'")                     ///
        ("`des2'") (`code2') (`hs2') ("`est2'")
}

* --- Wave 2 ---------------------------------------------------------------
forvalues i = 1/`n2' {
    local wave   : word `i' of `waves2'
    local folder : word `i' of `folders2'
    local dta    "$twfe_root/replications/`wave'/`folder'/panel_GTD.dta"

    local j = `n1' + `i'
    di _n as text "================================================================"
    di    as text "  [`j'/21] `folder' (`wave')"
    di    as text "================================================================"

    * ---- classify_did -------------------------------------------------------
    local des   "FAILED"
    local est   ""
    local code  = -1
    local hs    = 0

    cap noisily {
        use "`dta'", clear
        classify_did Y G T D
        local des  "`r(design)'"
        local est  "`r(estimator)'"
        local code  = r(design_code)
        local hs    = r(had_stayers)
    }
    if _rc {
        di as error "  --> classify_did failed (rc=`_rc')"
        local des   "FAILED"
        local est   ""
        local code  = -1
        local hs    = 0
    }

    * ---- classify_sketch2 --------------------------------------------------
    local des2   "FAILED"
    local est2   ""
    local code2  = -1
    local hs2    = 0

    cap noisily {
        use "`dta'", clear
        classify_sketch2 Y G T D
        local des2  "`r(design)'"
        local est2  "`r(estimator)'"
        local code2  = r(design_code)
        local hs2    = r(had_stayers)
    }
    if _rc {
        di as error "  --> classify_sketch2 failed (rc=`_rc')"
        local des2   "FAILED"
        local est2   ""
        local code2  = -1
        local hs2    = 0
    }

    post handle                                                     ///
        ("`folder'") ("`wave'")                                     ///
        ("`des'")  (`code')  (`hs')  ("`est'")                     ///
        ("`des2'") (`code2') (`hs2') ("`est2'")
}

postclose handle

* --------------------------------------------------------------------------
* Build final dataset
* --------------------------------------------------------------------------
use `tmp', clear

* Value labels (shared by both design_code columns — same numeric scheme)
label define design_lbl     ///
    1  "CLA"                ///
    2  "SAD"                ///
    3  "HAD with stayers"   ///
    4  "SSFSD / SFSD(dyn)"  ///
    5  "SFSD"               ///
    6  "HAD w/o stayers"    ///
    7  "SSD"                ///
    8  "OTHER"              ///
    -1 "FAILED", replace

label values design_code   design_lbl
label values design_code_s2 design_lbl

label var paper           "Paper name"
label var wave            "Publication wave"
label var design          "classify_did: design label"
label var design_code     "classify_did: design code"
label var had_stayers     "classify_did: 1 if HAD detected after dropping stayers"
label var estimator       "classify_did: recommended estimator"
label var design_s2       "classify_sketch2: design label"
label var design_code_s2  "classify_sketch2: design code"
label var had_stayers_s2  "classify_sketch2: 1 if HAD with stayers"
label var estimator_s2    "classify_sketch2: recommended estimator"

* Flag disagreements between the two classifiers
gen byte agree = (design == design_s2)
label var agree "1 if classify_did and classify_sketch2 agree"

sort wave paper
save "$twfe_root/reports/classify_did_results.dta", replace

* --------------------------------------------------------------------------
* Summary tables
* --------------------------------------------------------------------------
di _n as text "================================================================"
di    as text "  RESULTS: classify_did vs classify_sketch2"
di    as text "================================================================"
list paper wave design design_s2 agree, sep(0) noobs abbrev(30)

di _n as text "Counts by design — classify_did:"
tab design, sort

di _n as text "Counts by design — classify_sketch2:"
tab design_s2, sort

di _n as text "Disagreements (agree == 0):"
list paper wave design design_s2 if !agree, sep(0) noobs abbrev(30)

di _n "Results saved to: $twfe_root/reports/classify_did_results.dta"
cap log close
