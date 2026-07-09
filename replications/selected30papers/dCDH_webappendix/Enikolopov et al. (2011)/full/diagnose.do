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

log using "${twfe_root}/replications/2010-2012/Enikolopov et al. (2011)/full/diagnose.log", text replace
cd "${twfe_root}/data/2010-2012/Enikolopov et al. (2011)/Replication"
use "NTV_Aggregate_Data.dta", clear
describe, short
di _n "--- Key variables ---"
ds *population* *wage* *Watch* *NTV* *region* *tik*
di _n "--- Variable list ---"
describe
log close
