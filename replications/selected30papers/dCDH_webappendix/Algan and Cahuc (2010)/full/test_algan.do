clear all
set more off
cap log close _all

* --- Auto-detect user / set repo paths --------------------------------
* Add a branch with your OS username if you're a new collaborator.
if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root   "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
    global papers_root "/Users/anzony.quisperojas/Documents/GitHub/papers_economic"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root   "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    global papers_root "C:/Users/Usuario/Documents/GitHub/papers_economic"
}
else {
    di as error "Unknown user `c(username)'. Add your repo paths to the user-detection block at the top of this dofile."
    exit 198
}
* ---------------------------------------------------------------------

cd "${twfe_root}/data/2010-2012/Algan and Cahuc (2010)"
log using "${twfe_root}/replications/2010-2012/Algan and Cahuc (2010)/full/test_algan.log", text replace

di "TEST: Loading micro data..."
use "AER_MICRO.dta", clear
describe, short

di "TEST: Running one regression..."
reg trust10_large age men ageedu if native==1, robust
di "TEST: Done."

log close
