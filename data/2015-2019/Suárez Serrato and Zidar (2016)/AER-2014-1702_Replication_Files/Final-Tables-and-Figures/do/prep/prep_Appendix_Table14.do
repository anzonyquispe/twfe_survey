clear
set more off

use "$datapath_misalloc/misallocation_paneldata.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)
rename fipstate fips_state
sort fips_state year
tsset fips_state year
g d_y = ln(priceBLS) - ln(L10.priceBLS)
tempfile misallocation
save `misallocation'

*Merging
use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
sort fips_state year
merge m:1 fips_state year using `misallocation'
drop if _merge != 3
drop _merge

keep d_y priceBLS conspuma fips_state year epop fe_group d_keep_itc_state dtotalexpenditure_pop bartik d_corp_ext d_bus_dom2

saveold "$dtapath/Tables/Appendix_Table14.dta", replace
