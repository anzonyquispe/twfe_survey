clear
set more off


use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
sort fips_state year

merge fips_state year using "$datapath_final/ForStateFigures_decade_09-23-2014.dta"
drop if _merge != 3
drop _merge

tempfile data
save `data'

*run /do/prep/inputs/build_deductible.do
use "$dropbox/Local_Econ_Corp_Tax/Data/State Corp Tax Rules/State Corp Tax Deductability Data/deductibility.dta", clear
keep if inlist(year, 1980, 1990, 2000, 2010)
rename fips fips_state
replace deduct = 2 if deduct == 1 /* For factor variables, since values don't actually matter */
replace deduct = 1 if deduct == 0.5 /* for very small number of states that had partial deductability */
tempfile data_deduct
sort fips_state year
save `data_deduct'

*run /do/prep/inputs/build_GRT.do
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


*Wilson's R&D tax credit variable by state year (for control)

tempfile data
save `data', replace

import excel "$dropbox/Local_Econ_Corp_Tax/AER Revisions R2/r&d_user_cost_1963-2011/R&D user cost, 1963-2011.public.xlsx", sheet("rd_long") cellrange(A7:V2505) clear
keep B C P
rename (B C P) (fips_state year rec_val)
label var rec_val "R&D statutory credit rate" 
keep if inlist(year, 1990, 2000, 2010) 

merge 1:m fips_state year using `data' /* lose alaska, dc, hawaii */
drop if _merge != 3
drop _merge

*Investment tax credit

tempfile data
save `data', replace

use "$dropbox/Local_Econ_Corp_Tax/AER Revisions R2/Investment Tax Credit/itc_data.080714.dta", clear
keep fips year itc_state
rename fips fips_state
keep if inlist(year, 1990, 2000, 2010)

merge 1:m fips_state year using `data' /* lose alaska, dc, hawaii */
drop if _merge != 3
drop _merge

*Adjusted for deductibility

tempfile data
save `data', replace

use "$dropbox/State Taxes and Misallocation/Data/Final Dataset/fed_tax_rates.dta", clear
keep if inlist(year,1980, 1990, 2000, 2010)
replace t_corp_fed = t_corp_fed/100 /*Rescale*/
replace t_corp_fed_effective = t_corp_fed_effective/100
tempfile data_fed_rates
save `data_fed_rates'

use `data'
sort year fips_state
merge year using `data_fed_rates'
drop if _merge != 3
drop _merge

sort conspuma decade
tsset conspuma decade
g d_t_corp_fed = (1 - corporate_rate - t_corp_fed) - (1 - L1.corporate_rate - L1.t_corp_fed)
replace d_t_corp_fed = (1 - corporate_rate)*(1 - t_corp_fed) - (1 - L1.corporate_rate)*(1 - L1.t_corp_fed) if deduct == 2 /*Change for state-years with deduct*/
g d_t_corp_fed_effective = (1 - corporate_rate - t_corp_fed_effective) - (1 - L1.corporate_rate - L1.t_corp_fed_effective)
replace d_t_corp_fed_effective = (1 - corporate_rate)*(1 - t_corp_fed_effective) - (1 - L1.corporate_rate)*(1 - L1.t_corp_fed_effective) if deduct == 2


keep epop fips_state year conspuma dadjlwage dpop dadjlrent dest GovParty_D GovParty_I GovParty_R year fe_group throwback combined ///
	SalesTaxRate DSalesTaxRate income_rate_fam dtotalexpenditure_pop rev_corptax_gdp bartik deduct grt d_bus_dom2 Dincome_rate_fam ///
	corporate_rate t_corp_fed d_t_corp_fed d_t_corp_fed_effective rec_val itc_state 
	
*Additional tax base controls
tempfile data
save `data', replace

*data from the state tax handbooks
*run /do/prep/inputs/build_state_tax_handbook_digitization.do
use "$dropbox/Local_Econ_Corp_Tax/AER Revisions R2/state_tax_digitization/data_clean/data_imputed.dta", clear
keep if inlist(Year, 1990, 2000, 2010)
rename (fipsstate Year) (fips_state year)

merge 1:m fips_state year using `data' /* lose alaska, dc, hawaii */
drop if _merge != 3
drop _merge


*Output data

saveold "$dtapath/Tables/Appendix_Table19.dta", replace
