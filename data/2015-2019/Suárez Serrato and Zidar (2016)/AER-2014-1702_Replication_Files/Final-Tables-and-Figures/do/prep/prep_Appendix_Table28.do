clear
set more off


use "$datapath_final/ForTables_decade_09-23-2014.dta", clear

******************
* LHS VARIABLES 
*****************
g v1 = dadjlwage
g v2 = dpop
g v3 = dadjlrent
g v4 = dest

******************
* RHS VARIABLES 
*****************
g tax = d_bus_dom2


sort fips_state year
tempfile tempdata1
save `tempdata1'

use "$datapath_final/ForTables_annual_09-23-2014.dta"
sort fips_state year
merge fips_state year using `tempdata1'
drop _merge

keep if inlist(year, 1988, 1989, 1990, 1998, 1999, 2000, 2008, 2009, 2010)

sort conspuma year 
tsset conspuma year

g ln_gdp = ln(gdp_state)
g Dlngdp = ln_gdp - L1.ln_gdp
g Dlngdp_lag = L1.ln_gdp - L2.ln_gdp

keep if inlist(year, 1990, 2000, 2010)

keep conspuma year fe_group fips_state Dlngdp Dlngdp_lag dtotalexpenditure_pop bartik ///
	epop v1-v4 tax

saveold "$dtapath/Tables/Appendix_Table28.dta", replace 
