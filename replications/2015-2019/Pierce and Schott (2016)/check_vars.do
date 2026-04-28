/*=============================================================================
  CHECK_VARS: Pierce and Schott (2016)
  "The Surprisingly Swift Decline of US Manufacturing Employment"
  AER 106(7), 1632-1662

  Purpose: Check available public data for TWFE decomposition
  Main TWFE spec: Table 1, Col 1
  areg lempfam501999 s1999_post d???? [aw=emp1990], a(fam50) cl(fam50) robust

  NOTE: Main data file uses restricted Census LBD microdata
=============================================================================*/

clear all
set more off
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Pierce and Schott (2016)/data_files_aer_2013-1578"

di _n "============================================================"
di "  CHECKING PUBLIC DATA FILES"
di "============================================================"

* --- Check temp_50_n6.dta (likely main panel) ---
di _n "=== temp_50_n6.dta ==="
cap use "$datadir/temp_50_n6.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
    cap ds *emp* *s1999* *post* *fam* *year* *gap*
}
else {
    di "Failed to load"
}

* --- Check gaps dataset ---
di _n "=== gaps_by_naics6_20150722_fam50.dta ==="
cap use "$datadir/gaps_by_naics6_20150722_fam50.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
    cap ds *emp* *s1999* *post* *fam* *year* *gap*
}
else {
    di "Failed to load"
}

* --- Check bbg_fam_drop files ---
di _n "=== bbg_fam_drop_50_n6_2.dta ==="
cap use "$datadir/bbg_fam_drop_50_n6_2.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
}
else {
    di "Failed to load"
}

* --- Check robustness files for panel structure ---
di _n "=== robustness_ntr_fam50_true_adj.dta ==="
cap use "$datadir/robustness_ntr_fam50_true_adj.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
    cap ds *emp* *s1999* *post* *fam* *year* *gap* *ntr*
}
else {
    di "Failed to load"
}

di _n "=== robustness_union_fam50.dta ==="
cap use "$datadir/robustness_union_fam50.dta", clear
if _rc == 0 {
    di "Loaded OK. Obs: " _N
    desc, short
    ds
}
else {
    di "Failed to load"
}

di _n "============================================================"
di "  CONCLUSION"
di "============================================================"

* Done
