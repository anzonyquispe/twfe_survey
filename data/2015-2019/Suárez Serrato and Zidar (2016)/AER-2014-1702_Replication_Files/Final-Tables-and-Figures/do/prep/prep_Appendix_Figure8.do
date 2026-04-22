clear
set more off

use "$datapath_final/ForTables_annual_09-23-2014.dta"

keep d_ln_bus_dom2 year fe_group wgt pop g_pop emp g_emp fips_state conspuma

saveold "$dtapath/Figures/Appendix_Figure8.dta", replace


