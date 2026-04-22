clear
set more off

/************/
/*** Data ***/
/************/

use "$raw/nets_est_scaling_factors.dta", clear
keep if inlist(year, 1990, 2000, 2010)
tempfile nets_data
save `nets_data'

*"Final data" set for merge

use "$datapath_final/ForTables_decade_09-23-2014.dta",clear
merge 1:1 conspuma year using `nets_data'
tab _merge
drop if _merge == 2 /* Only lose 6 out of 496 conspumas from NETS data */
drop _merge

tempfile data
save `data'

*Other variables to draw in
use "$datapath_final/ForTables_annual_09-23-2014.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)
keep conspuma year est
merge 1:1 conspuma year using `data'
sort conspuma year
bysort conspuma: replace singlestate_rat = singlestate_rat[_n+1] if missing(singlestate_rat) /* Assume 1980 ratio = 1990 ratio, since we don't have data for 1980 */
drop _merge 


*LHS Variables

sort conspuma year
tsset conspuma year

g est_nets = singlestate_rat*est /* Proxy for # of single-state establishments */
g dest_nets = ln(est_nets) - ln(L10.est_nets)

g N=dpop
g W=dadjlwage
g R=dadjlrent
g L=demp

*RHS Variables

g d_keeprate=d_bus_dom2

label var d_keeprate            "$ \Delta \ln $ Net-of-Business-Tax Rate"
label var bartik                "Bartik"
label var d_keep_itc_state      "$ \Delta $ State ITC"
label var dtotalexpenditure_pop "$ \Delta \ln $ Gov Expend/Capita"
label var d_corp_ext			"Change in Other States' Taxes"
label var N						"dpop"
label var W						"dadjlwage"
label var R						"dadjklrent"
label var L						"demp"

*Output dataset

drop if year == 1980 /* For conformity; doesn't actually matter since the change between 1980-1990 is represented in 1990 */
keep dest_nets N W R L d_keeprate bartik d_keep_itc_state dtotalexpenditure_pop d_corp_ext fips_state epop ///
	year fe_group

saveold "$dtapath/Tables/Appendix_Table15.dta", replace

