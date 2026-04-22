clear
set more off


use "$datapath_final/ForTables_decade_09-23-2014.dta"
keep dest d_bus_dom2 year fips_state conspuma

saveold "$dtapath/Figures/Appendix_Figure10.dta", replace
