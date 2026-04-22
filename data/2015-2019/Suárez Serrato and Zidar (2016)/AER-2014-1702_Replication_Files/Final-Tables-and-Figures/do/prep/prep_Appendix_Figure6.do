clear
set more off


use "$datapath_final/ForTables_decade_09-23-2014.dta", clear

keep d_corporate_rate d_payroll year fips_state conspuma

saveold "$dtapath/Figures/Appendix_Figure6.dta", replace
