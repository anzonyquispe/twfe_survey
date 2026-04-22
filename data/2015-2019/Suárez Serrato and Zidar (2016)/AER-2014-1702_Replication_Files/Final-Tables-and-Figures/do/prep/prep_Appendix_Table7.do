clear
set more off


use "$datapath_final/ForTables_decade_09-23-2014.dta", clear

keep year conspuma fips_state epop dadjlwage d_bus_dom2 d_keep_itc_state dtotalexpenditure_pop bartik d_corp_ext fe_group

saveold "$dtapath/Tables/Appendix_Table7.dta", replace
