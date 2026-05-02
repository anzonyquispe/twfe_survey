**************************************************
** Master replication file for Bloom, Sadun, Van Reenen (2012)
** "Americans Do IT Better: US Multinationals and the Productivity Miracle"
** AER, 102(1), 167-201
** Partial replication: European results only
** (UK data adib_data_10.dta not available — requires ONS restricted access)
**************************************************

cd "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Bloom et al. (2012)/full"

capture log close _all
log using run_all_output.log, replace text

set more off
capture set mem 100m
set matsize 2000

capture ssc install estout, replace

display "============================================="
display "Bloom et al. (2012) — Partial Replication"
display "European Results Only"
display "============================================="

display ""
display "Running Table6_C2.do (Table 6 + Appendix Table C2)..."
capture noisily do Table6_C2.do

display ""
display "Running TableA5.do (Appendix Table A5)..."
capture noisily do TableA5.do

display ""
display "Running TableA6.do (Appendix Table A6)..."
capture noisily do TableA6.do

display ""
display "Running Figures.do (Figures 3A, 3B)..."
capture noisily do Figures.do

display ""
display "============================================="
display "Replication complete."
display "Tables replicated: 6, C2, A5, A6 (European)"
display "Figures replicated: 3A, 3B"
display "Missing: Tables 1-5, A2, A9, C1 (require UK data)"
display "============================================="

graph close _all
log close _all
exit
