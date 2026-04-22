clear
set more off


use "$datapath_final/conspuma-dec-092313", clear

keep year census_div dest dpop dadjlrent dadjlwage d_bus_dom2 ///
	epop state_fips fips_state

saveold "$dtapath/CMD/ILS_1_shocks_3_parm.dta", replace
