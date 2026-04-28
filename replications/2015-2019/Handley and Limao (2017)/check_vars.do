/*=============================================================================
  CHECK_VARS: Handley and Limao (2017)
  "Policy Uncertainty, Trade, and Welfare: Theory and Evidence for China
   and the United States"
  AER 107(9), 2731-2783

  Purpose: Verify whether paper has a standard TWFE specification

  Finding: NO clean TWFE.
  - Tables 2-5: cross-sectional OLS (year 2005 only)
  - Table A7: long-differences with rreg (robust regression)
  - Table A8: reghdfe with hs6 + section*year FE (non-standard multi-way FE)
  - Treatment is "uncertainty" interacted with pre/post, not binary DiD
=============================================================================*/

clear all
set more off
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Handley and Limao (2017)/data_counterfactual_replication"

* --- Check main datasets ---
di _n "============================================================"
di "  DATASET 1: replication_maindata1.dta (Tables 2, 4, 5)"
di "============================================================"
use "$datadir/replication_maindata1.dta", clear
di "Observations: " _N
desc, short
cap ds *year* *yr* *time* *period*
di _n "--- Panel check ---"
cap tab year
if _rc == 0 {
    di "Year variable exists"
    tab year
}
else {
    di "No year variable"
}

* Check for unit identifier
cap ds *hs6* *product* *hs*
di _n "--- Variables ---"
ds

di _n "============================================================"
di "  DATASET 2: replication_appxdata6.dta (Table A8 - panel)"
di "============================================================"
use "$datadir/replication_appxdata6.dta", clear
di "Observations: " _N
desc, short

di _n "--- Panel structure ---"
cap tab year
if _rc == 0 {
    di "Year variable:"
    tab year
}
cap {
    qui tab hs6
    di "HS6 products: " r(r)
}

di _n "--- Variables ---"
ds

di _n "============================================================"
di "  DATASET 3: replication_appxdata5.dta (Table A7 - DD panel)"
di "============================================================"
cap use "$datadir/replication_appxdata5.dta", clear
if _rc == 0 {
    di "Observations: " _N
    desc, short
    di _n "--- Variables ---"
    ds
}
else {
    di "File not found"
}

di _n "============================================================"
di "  CONCLUSION"
di "============================================================"
di "  1. Main tables (2-5): cross-sectional analysis at year 2005"
di "     Regression: reg dif_ln_imp_5 unc_pre ..., cluster(section)"
di "     NO group or time FE in standard TWFE sense"
di ""
di "  2. Table A7 (DD panel): uses rreg (robust regression) on"
di "     long-differenced data, NOT standard TWFE"
di ""
di "  3. Table A8 (panel regs): reghdfe ln_imp ... , ab(hs6 section_yr)"
di "     Has product FE (hs6) + section*year FE"
di "     This is multi-way FE, NOT standard two-way G+T"
di "     Treatment is uncertainty*period interaction, not binary DiD"
di ""
di "  ==> NO TWFE specification available for decomposition"
di "============================================================"

* Done
