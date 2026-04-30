/*==============================================================================
  CHECK_VARS: Faye and Niehaus (2012)
  "Political Aid Cycles"
  AER 102(7), 3516-3530

  Verifica: 111102_oda_final_data_big5_commit_080107_unvotes_term.dta
  Variables para Table 2 (main results)
==============================================================================*/

clear all
set more off
cap * log close _all

local datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Faye and Niehaus (2012)/data_analysis/data"

* NOTE: log auto-created by Stata -b mode

di "=============================================="
di "  CHECK_VARS: Faye and Niehaus (2012)"
di "=============================================="

* Try .dta first
cap use "`datadir'/111102_oda_final_data_big5_commit_080107_unvotes_term.dta", clear
if _rc != 0 {
    di "DTA failed, trying CSV..."
    insheet using "`datadir'/111102_oda_final_data_big5_commit_080107_unvotes_term.csv", clear
}

di "Raw N = " _N
desc, short

* Key variables
di _n "--- Key variables ---"
foreach v in wbcode_donor wbcode_recipient year oda odapair_commit i_elecex unvotes p_unvotes_elecex {
    cap confirm variable `v'
    if _rc == 0 {
        qui sum `v'
        di "`v': N=" r(N) " mean=" %12.4f r(mean) " min=" %12.4f r(min) " max=" %12.4f r(max)
    }
    else {
        di "`v': MISSING — trying lowercase..."
        * Try exact case variations
        cap confirm variable `=lower("`v'")'
        if _rc == 0 {
            di "  Found as `=lower("`v'")'"
        }
    }
}

* Panel structure
di _n "--- Panel structure ---"
qui tab year
di "Years (T): " r(r)
tab year

* Create pair ID
cap confirm variable wbcode_donor
if _rc == 0 {
    egen pair_id = group(wbcode_donor wbcode_recipient)
}
else {
    * Try alternative names
    cap egen pair_id = group(d r)
}
qui tab pair_id
di "Donor-Recipient pairs (G): " r(r)

* Donors
cap tab wbcode_donor
cap tab d

* Treatment
di _n "--- Treatment: i_elecex ---"
cap tab i_elecex, missing

di _n "--- ODA variable ---"
cap sum oda
cap sum odapair_commit

di _n "=============================================="
di "  CHECK_VARS COMPLETE"
di "=============================================="

* log close _all
