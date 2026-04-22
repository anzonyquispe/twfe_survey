clear
set more off

use "$datapath_misalloc/misallocation_paneldata.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)

keep sales_wgt year fipstate


saveold "$dtapath/Figures/Figure3.dta", replace
