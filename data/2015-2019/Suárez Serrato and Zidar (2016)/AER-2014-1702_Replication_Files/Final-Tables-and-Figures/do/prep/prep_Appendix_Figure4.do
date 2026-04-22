clear
set more off

use "$datapath_final/ForStateFigures_40year_09-23-2014.dta", clear

keep if year==2010
rename stateabbrev state
replace g_corporate_rate=0 if g_corporate_rate==.

keep estshare popshare state year


saveold "$dtapath/Figures/Appendix_Figure4.dta", replace

