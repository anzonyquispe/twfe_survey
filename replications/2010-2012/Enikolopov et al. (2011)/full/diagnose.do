clear all
set more off
cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Enikolopov et al. (2011)/full/diagnose.log", text replace
cd "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Enikolopov et al. (2011)/Replication"
use "NTV_Aggregate_Data.dta", clear
describe, short
di _n "--- Key variables ---"
ds *population* *wage* *Watch* *NTV* *region* *tik*
di _n "--- Variable list ---"
describe
log close
