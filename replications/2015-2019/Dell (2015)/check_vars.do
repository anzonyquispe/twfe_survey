/*==============================================================================
  CHECK_VARS: Dell (2015)
  "Trafficking Networks and the Mexican Drug War"
  AER 105(6), 1738-79

  Purpose: Check if any table data has TWFE structure (G FE + T FE)
  Note: Tables 1-5 appear to be RD designs. Tables 6-7 need confidential data.
==============================================================================*/

clear all
set more off

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Dell (2015)/AER2012-1637data"

* --- Table 2 data (has monthly panel) ---
di _n "============================================================"
di "  TABLE 2 DATA: table2.dta"
di "============================================================"
use "$datadir/table2.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Panel structure? ---"
cap qui tab id_mun
cap di "Municipalities (potential G): " r(r)
cap ds *year* *month* *time* *period*
di _n "--- Time variables ---"
cap tab postInn, missing
cap tab postElec, missing

di _n "--- Is there a proper time variable? ---"
ds

* --- Table 3 data (multi-election panel) ---
di _n "============================================================"
di "  TABLE 3 DATA: table3.dta"
di "============================================================"
use "$datadir/table3.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Panel structure? ---"
cap qui tab id_mun
cap di "Municipalities: " r(r)
cap qui tab elec_c
cap di "Election cycles: " r(r)

di _n "--- FE structure check ---"
di "  Table 3 collapse by id_mun elec_c -> this is a panel"
di "  But regression uses RD (spread, spreadPW), NOT group/time FE"

* --- Table 4 data ---
di _n "============================================================"
di "  TABLE 4 DATA: table4_0710.dta"
di "============================================================"
use "$datadir/table4_0710.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Check for time/group FE vars ---"
ds

* --- Table 5 data ---
di _n "============================================================"
di "  TABLE 5 DATA: table5_0710.dta"
di "============================================================"
use "$datadir/table5_0710.dta", clear
di "Observations: " _N
desc, short
desc

di _n "--- Check for drughom (redacted) ---"
cap summarize drughom
cap di "drughom available: " r(N) " non-missing"

di _n "============================================================"
di "  CONCLUSION:"
di "  Tables 1-5: Regression Discontinuity design (not TWFE)"
di "  Tables 6-7: Require confidential data (producers.dta, dtrh.dta, seizures.dta)"
di "  No TWFE specification available for decomposition"
di "============================================================"
