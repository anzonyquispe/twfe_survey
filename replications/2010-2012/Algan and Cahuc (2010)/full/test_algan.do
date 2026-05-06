clear all
set more off
cap log close _all

cd "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Algan and Cahuc (2010)"
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Algan and Cahuc (2010)/full/test_algan.log", text replace

di "TEST: Loading micro data..."
use "AER_MICRO.dta", clear
describe, short

di "TEST: Running one regression..."
reg trust10_large age men ageedu if native==1, robust
di "TEST: Done."

log close
