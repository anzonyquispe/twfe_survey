clear
set more off

/************/
/*** Data ***/
/************/

use "$raw/nets_est_scaling_factors.dta", clear
keep if inlist(year, 1990, 2000, 2010)
tempfile nets_data
save `nets_data'

use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
merge 1:m year conspuma using `nets_data' /* Lose 6 conspuma out of 496 */
drop if _merge == 2
drop _merge

sort conspuma year
tsset conspuma year

*note that est_nets is the single state share times dest
g dest_nets = singlestate_rat*dest

drop if year == 1980

keep dadjlwage dpop dadjlrent year fe_group bartik d_esrate dest_nets d_bus_dom2 ///
	d_corp_orig epop fips_state

saveold "$dtapath/Tables/Appendix_Table17.dta", replace
