clear
set more off

use "$dtapath/profit_validation_decade.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)

keep year conspuma fipstate d_bus_dom2 D10_GOS_E

saveold "$dtapath/Figures/Appendix_Figure14.dta", replace
