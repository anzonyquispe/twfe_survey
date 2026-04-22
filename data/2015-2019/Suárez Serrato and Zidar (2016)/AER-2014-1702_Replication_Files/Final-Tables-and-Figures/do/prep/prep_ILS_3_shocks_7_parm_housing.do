clear
set more off


use "$datapath_final/conspuma-dec-092313", clear

keep fips* state* census_div dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate ///
	epop year

saveold "$dtapath/CMD/ILS_3_shocks_7_parm_housing.dta", replace
