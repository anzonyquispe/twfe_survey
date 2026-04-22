clear
set more off


use "$dtapath/profit_validation_decade.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)
gen d_y = ln(GOS_E) - ln(L10.GOS_E)

keep GOS_E d_y d_bus_dom2 fipstate year conspuma epop fe_group d_keep_itc_state dtotalexpenditure_pop bartik d_corp_ext

saveold "$dtapath/Tables/Appendix_Table10.dta", replace
