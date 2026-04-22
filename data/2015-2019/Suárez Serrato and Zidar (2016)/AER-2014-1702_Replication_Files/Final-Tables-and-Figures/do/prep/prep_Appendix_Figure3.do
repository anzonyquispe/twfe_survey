clear
set more off

use "$dropbox/Local_Econ_Corp_Tax/Data/FINAL DATA/state_outcome_data.dta"
keep stateabbrev fips
tempfile data_statenames
rename fips fips_state
sort fips 
save `data_statenames'

use "$dropbox/Local_Econ_Corp_Tax/Data/State Tax Rate Data/statecorptaxdata_8-23-13.dta", clear
sort fips
merge fips using `data_statenames'
drop if _merge==2
duplicates drop
rename state statefull
rename stateabbrev state

drop property _merge

keep if inlist(year, 1980,2010)

gen t=0 if year==1980
replace t=1 if year==2010

tsset fips t
gen Dcorp=D.corporate_rate /* Change in Corporate rate */
gen Dsales=D.sales /* Change in Sales rate */

keep if year==2010


saveold "$dtapath/Figures/Appendix_Figure3.dta", replace

