clear
set more off

use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
sort fips_state year

merge fips_state year using "$datapath_final/ForStateFigures_decade_09-23-2014.dta"
drop if _merge != 3
drop _merge

tempfile data
save `data'

use "$dropbox/Local_Econ_Corp_Tax/Data/State Corp Tax Rules/State Corp Tax Deductability Data/deductibility.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)
rename fips fips_state
replace deduct = 2 if deduct == 1 /* For factor variables, since values don't actually matter */
replace deduct = 1 if deduct == 0.5
tempfile data_deduct
sort fips_state year
save `data_deduct'


use "$dropbox/Local_Econ_Corp_Tax/Data/State Corp Tax Rules/State Corp Tax Deductability Data/GRT.dta", clear
rename fips fips_state
keep if inlist(year, 1980, 1990, 2000, 2010)
gen decade=1
replace decade=2 if year==1990
replace decade=3 if year==2000
replace decade=4 if year==2010
tsset fips_state decade	
g Dgrt=D.grt
tempfile data_grt
sort fips_state year
save `data_grt'

use `data', clear
sort fips_state year
merge fips_state year using `data_deduct'
drop if _merge != 3 /* 1470 observations merged perfectly */
drop _merge
sort fips_state year
merge fips_state year using `data_grt'
drop if _merge != 3
drop _merge

tsset conspuma decade 
g DSalesTaxRate=D.SalesTaxRate
g Dincome_rate_fam=D.income_rate_fam 


keep epop fips_state year conspuma dadjlwage dpop dadjlrent dest GovParty_D GovParty_I GovParty_R year fe_group throwback combined ///
	SalesTaxRate DSalesTaxRate income_rate_fam dtotalexpenditure_pop rev_corptax_gdp bartik deduct grt d_bus_dom2 Dincome_rate_fam

saveold "$dtapath/Tables/Appendix_Table20.dta", replace
