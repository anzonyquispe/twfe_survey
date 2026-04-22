clear
set more off

use "$datapath_final/ForTables_annual_09-23-2014.dta"

keep d_ln_bus_dom2 g_est year fe_group wgt fips_state conspuma pop emp

saveold "$dtapath/Figures/Figure4.dta", replace
