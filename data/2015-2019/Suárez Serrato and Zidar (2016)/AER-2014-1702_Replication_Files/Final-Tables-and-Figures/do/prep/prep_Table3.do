/* Annual */

use  "$datapath_final/ForTables_annual_09-23-2014.dta", clear

*make consistent list of conspumas with full data; these are conspuma that are represented in both sets.
drop if conspuma ==540
drop if conspuma ==541
drop if conspuma ==542
label var year "Year"
label var ln_pop "Log Population: $ \ln N_{c,t} $ "
label var ln_emp "Log Employment: $ \ln L_{c,t} $ "
label var ln_est "Log Establishments: $ \ln E_{c,t} $"
label var payroll "Payroll Apportionment Weight: $ \theta^w_{s,t} $"
label var property "Property Apportionment Weight: $ \theta^\rho_{s,t} $"
label var sales "Sales Apportionment Weight: $ \theta^x_{s,t} $"
label var corporate_rate "Rate: $ \tau^c_{s,t} $"
label var d_corp_orig "\% Change in Net-of-Rate: $\widehat{1- \tau^c}_{s,t,t-1} $"
label var esrate_agg_post "Rate: $ \tau^i_{s,t} $"
label var d_esrate "\% Change in Net-of-Rate: $\widehat{1- \tau^i}_{s,t,t-1} $ "
label var bus_dom "Rate: $ \tau^b_{c,t} $"
label var d_bus_dom2 "\% Change in Net-of-Rate: $\widehat{1- \tau^b}_{c,t,t-1} $  $"

keep pop conspuma year ln_pop ln_emp ln_est payroll property sales corporate_rate d_corp_orig esrate_agg_post d_esrate bus_dom d_bus_dom2

saveold "$dtapath/Tables/Table3a.dta", replace

/* Decadal */

use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
drop if epop==.

foreach v in "dpop" "dest" "dadjlwage" "dadjlrent" "d_corp_orig" "d_esrate" "d_bus_dom2"  "bartik" {
replace `v'=`v'*100
}

label var year "Year"
label var dpop "\% Change in Population: $ \hat{N}_{c,t,t-10} $  "
label var dest "\% Change in Establishments: $ \hat{E}_{c,t,t-10} $   "
label var dadjlwage "\% Change in Adjusted Wages: $ \hat{w}_{c,t,t-10} $   "
label var dadjlrent "\% Change in Adjusted Rents: $ \hat{r}_{c,t,t-10} $  "
label var d_corp_orig "\% Change in Net-of-Corp.-Rate: $\widehat{1- \tau^c}_{s,t,t-10} $"
label var d_esrate "\% Change in Net-of-Pers.-Rate: $\widehat{1- \tau^i}_{s,t,t-10} $ "
label var d_bus_dom2 "\% Change in Net-of-Bus.-Rate: $\widehat{1- \tau^b}_{c,t,t-10}   $"
label var bartik "\% Bartik Shock: $\widehat{\text{Bartik}}_{c,t,t-10} $"
label var dtotalexpenditure_pop "\% Change in Gov. Expend./ Capita $ \Delta \ln G_{c,t,t-10}$"

keep epop conspuma year dpop dest dadjlwage dadjlrent d_corp_orig d_esrate d_bus_dom2 bartik dtotalexpenditure_pop

saveold "$dtapath/Tables/Table3b.dta", replace
