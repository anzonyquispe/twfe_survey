/*==============================================================================
  copy_panels_GTD.do
  Copy panel_GTD.dta for the 21 selected papers into a consolidated folder.

  Destination structure:
    $twfe_root/panels_GTD/2010-2012/<folder>/panel_GTD.dta
    $twfe_root/panels_GTD/2015-2019/<folder>/panel_GTD.dta
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
* Create destination directories
* --------------------------------------------------------------------------
cap mkdir "$twfe_root/panels_GTD"
cap mkdir "$twfe_root/panels_GTD/2010-2012"
cap mkdir "$twfe_root/panels_GTD/2015-2019"

* --------------------------------------------------------------------------
* Copy Wave 1
* --------------------------------------------------------------------------
forvalues i = 1/`n1' {
    local wave   : word `i' of `waves1'
    local folder : word `i' of `folders1'
    local src    "$twfe_root/replications/`wave'/`folder'/panel_GTD.dta"
    local dst    "$twfe_root/panels_GTD/`wave'/`folder'"

    cap mkdir "`dst'"

    di as text "[`i'/21] `folder' (`wave')"
    cap copy "`src'" "`dst'/panel_GTD.dta", replace
    if _rc {
        di as error "  WARNING: could not copy (rc=`_rc') — source may not exist."
    }
    else {
        di as text "  → copied."
    }
}

* --------------------------------------------------------------------------
* Copy Wave 2
* --------------------------------------------------------------------------
forvalues i = 1/`n2' {
    local wave   : word `i' of `waves2'
    local folder : word `i' of `folders2'
    local src    "$twfe_root/replications/`wave'/`folder'/panel_GTD.dta"
    local dst    "$twfe_root/panels_GTD/`wave'/`folder'"
    local j = `n1' + `i'

    cap mkdir "`dst'"

    di as text "[`j'/21] `folder' (`wave')"
    cap copy "`src'" "`dst'/panel_GTD.dta", replace
    if _rc {
        di as error "  WARNING: could not copy (rc=`_rc') — source may not exist."
    }
    else {
        di as text "  → copied."
    }
}

di _n as result "Done. Files written to: $twfe_root/panels_GTD/"
