/*=============================================================================
  CHECK VARIABLES: Diamond et al. (2019)
  "The Effects of Rent Control Expansion on Tenants, Landlords, and Inequality:
   Evidence from San Francisco"
  AER 109(9), 3365-94

  STATUS: Sin data parcial
  The main panel dataset (infutor_panel_treat_1994_cleaned.dta) is NOT available
  in the replication package. Infutor data is proprietary/restricted access.

  Available files:
  - census/usa_00012.dta (3.3 GB) — IPUMS census microdata
  - census/ltdb_std_all_2010_adjusted.dta (758 MB) — LTDB tract-level
  - impute_race/blk_attr_over18_dec10.dta (1.3 GB) — racial block demographics
  - impute_race/blkgrp_attr_over18_dec10.dta (25 MB)
  - housing_inventory/clean_combined.dta (14 KB)

  Missing files (required for all main regressions):
  - data/infutor/infutor_panel_treat_1994_cleaned.dta (Tables 1,4,5,6,7)
  - data/infutor/infutor_*.dta (Table 2 validation)
  - data/sf_rent/ziprents_imputed.dta (Table 6)

  All TWFE specifications (Tables 4-7) use reghdfe with:
  - absorb(id year_cat#yrs_at_curr93 year_cat#zip_treat)
  - or absorb(id zip_year year#yrs_at_curr93)
  These require the missing Infutor panel data.

  CONCLUSION: Cannot replicate. Marked "Sin data parcial".
=============================================================================*/

clear all
set more off

di "============================================================"
di "  Diamond et al. (2019)"
di "  STATUS: Sin data parcial"
di "============================================================"
di ""
di "  The main panel dataset (infutor_panel_treat_1994_cleaned.dta)"
di "  is proprietary Infutor data and NOT included in the"
di "  replication package."
di ""
di "  All main regression tables (4, 5, 6, 7) require this file."
di "  Cannot proceed with TWFE weight decomposition."
di ""
di "============================================================"
