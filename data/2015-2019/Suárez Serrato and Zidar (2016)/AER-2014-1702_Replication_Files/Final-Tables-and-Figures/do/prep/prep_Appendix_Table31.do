
	
clear
set more off


*Declaring tempfile for misallocation panel

use "$datapath_misalloc/misallocation_paneldata.dta", clear
sort year
sort fipstate year
tempfile misallocation_data
save `misallocation_data'

use "$datapath_final/st_corptaxrevshare.dta", clear
rename fips_state fipstate
order fipstate year
sort fipstate year
drop Name
merge m:1 fipstate year using `misallocation_data'
drop if _merge != 3 /* Lose 112 observations from the misallocation panel; these are mostly year 2013/2014 units */
drop _merge
tsset fipstate year

keep if inlist(year, 1980, 1990, 2000, 2010)

g D_taxratesales = taxratesales - L10.taxratesales
g D_proptax = proptax - L10.proptax

tempfile misallocation_rev_2
save `misallocation_rev_2'

*Deductability
use "$dropbox/Local_Econ_Corp_Tax/Data/State Corp Tax Rules/State Corp Tax Deductability Data/deductibility.dta", clear
rename fips fips_state
tempfile data_deduct
sort fips_state year
save `data_deduct'

*Gross Receipts Taxes
use "$dropbox/Local_Econ_Corp_Tax/Data/State Corp Tax Rules/State Corp Tax Deductability Data/GRT.dta", clear
rename fips fips_state
keep if inlist(year,1980, 1990, 2000, 2010)
gen decade=1
replace decade=2 if year==1990
replace decade=3 if year==2000
replace decade=4 if year==2010
tsset fips_state decade	
g Dgrt=D.grt

tempfile data_GRT
sort fips_state year
save `data_GRT'

use  "$datapath_final/ForStateFigures_decade_09-23-2014.dta", clear
tsset fips_state decade 
g DSalesTaxRate=D.SalesTaxRate
g Dincome_rate_fam=D.income_rate_fam 

g ln_est=ln(est)
g Dlnest=ln_est-L1.ln_est
g Dlnest_lag1=L1.Dlnest
g Dlnest_lag2=L2.Dlnest
keep fips_state year stateabbrev Dlnest Dlnest_lag1 Dlnest_lag2 GovParty SalesTaxRate DSalesTaxRate income_rate_fam Dincome_rate_fam rev_corptax_gdp GovParty_D GovParty_I GovParty_R throwback combined
tempfile data_state
sort fips_state year
save `data_state'

use "$datapath_final/ForTables_annual_09-23-2014.dta", clear
sort conspuma year
tsset conspuma year
gen D_esrate_10 = esrate_agg_post - L10.esrate_agg_post
keep conspuma year fips_state esrate_agg_post D_esrate_10
sort fips_state year
tempfile data_annual
save `data_annual'

use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
sort fips_state year
merge fips_state year using `data_annual'
tab _merge
keep if _merge == 3
drop _merge


sort fips_state year
merge fips_state year using `data_state'
tab _merge
keep if _merge==3
drop _merge

sort fips_state year
merge fips_state year using `data_deduct'
tab _merge
keep if _merge==3
drop _merge

sort fips_state year
merge fips_state year using `data_GRT'
tab _merge
keep if _merge==3
drop _merge

rename fips_state fipstate /* Only utilized for merge */

merge m:1 fipstate year using `misallocation_rev_2' /* Lose year 1980, which is fine */
drop if _merge != 3
drop _merge

rename fipstate fips_state

keep dadjlwage dpop dadjlrent dest d_bus_dom2 d_corp_orig taxratesales year fe_group ///
	esrate_agg_post proptax epop fips_state conspuma ///
	D_taxratesales D_esrate_10 D_proptax


saveold "$dtapath/Tables/Appendix_Table31.dta", replace
