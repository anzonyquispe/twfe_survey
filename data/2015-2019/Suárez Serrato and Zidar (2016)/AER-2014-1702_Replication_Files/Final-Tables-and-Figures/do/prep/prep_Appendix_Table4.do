clear
set more off

use "$datapath_misalloc/misallocation_paneldata.dta", clear 
rename fipstate fips_state

merge 1:m fips_state year using "$datapath_final/ForTables_annual_09-23-2014.dta"
drop if _merge != 3

collapse corporate_rate, by(taxratesales esrate_agg_post proptax fips_state year)

keep corporate_rate taxratesales esrate_agg_post proptax fips_state year

saveold "$dtapath/Tables/Appendix_Table4.dta", replace



