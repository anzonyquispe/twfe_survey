clear
set more off


use "$datapath_final/ForTables_decade_09-23-2014.dta", clear

keep dadjlwage dpop dadjlrent dest d_bus_dom2 year fe_group fips_state dtotalexpenditure_pop ///
	bartik epop d_corp_orig d_esrate

saveold "$dtapath/Tables/Table5.dta", replace
