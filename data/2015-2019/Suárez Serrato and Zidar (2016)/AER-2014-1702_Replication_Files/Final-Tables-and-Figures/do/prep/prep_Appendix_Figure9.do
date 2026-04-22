clear
set more off

use "$dtapath/profit_validation_annual.dta"

keep d_ln_bus_dom year fe_group wgt pop g_GOS GOS fipstate conspuma

saveold "$dtapath/Figures/Appendix_Figure9.dta", replace


