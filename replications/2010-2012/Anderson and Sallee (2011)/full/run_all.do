**************************************************
** Master replication file for Anderson and Sallee (2011)
** "Using Reduced-Form Models to Generate Structural Parameters"
** AER Papers & Proceedings
** Partial replication: CAFE compliance data only
** (transactions1.dta proprietary — not available)
**************************************************

cd "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Anderson and Sallee (2011)/full"

capture log close _all
log using run_all_output.log, replace text

set more off

display "============================================="
display "Anderson and Sallee (2011) — Partial Replication"
display "============================================="
display ""
display "Running cafe_compliance_behavior.do (Tables 1-2, Figures 1-5)..."

capture noisily do cafe_compliance_behavior.do

display ""
display "Running cafe_compliance_costs.do (Table 8)..."

capture noisily do cafe_compliance_costs.do

display ""
display "============================================="
display "Replication complete."
display "Tables replicated: 1, 2, 8 (of 8 total)"
display "Figures replicated: 1-5 (of 6 total)"
display "Missing: Tables 3-7, Figure 6 (require transactions1.dta)"
display "============================================="

graph close _all
log close _all
exit
