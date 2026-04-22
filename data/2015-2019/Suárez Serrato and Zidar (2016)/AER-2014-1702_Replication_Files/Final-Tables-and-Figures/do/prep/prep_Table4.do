clear
set more off

use "$datapath_final/ForTables_decade_09-23-2014.dta",clear

******************
* LHS VARIABLES 
******************

g E=dest
g N=dpop
g W=dadjlwage
g R=dadjlrent
g L=demp

******************
* RHS VARIABLES 
******************
g d_keeprate=d_bus_dom2

label var d_keeprate            "$ \Delta \ln $ Net-of-Business-Tax Rate"
label var bartik                "Bartik"
label var d_keep_itc_state      "$ \Delta $ State ITC"
label var dtotalexpenditure_pop "$ \Delta \ln $ Gov Expend/Capita"
label var d_corp_ext			"Change in Other States' Taxes"
label var E						"dest"
label var N						"dpop"
label var W						"dadjlwage"
label var R						"dadjklrent"
label var L						"demp"

keep E N W R L d_keeprate bartik d_keep_itc_state dtotalexpenditure_pop d_corp_ext fips_state epop ///
	year fe_group

saveold "$dtapath/Tables/Table4.dta", replace

