clear
set more off

*********************************************************
*********************************************************
*I. Build: Construct Datasets used for Tables and Figures
*********************************************************
*********************************************************

*********************************************************
*1. GOS
*********************************************************
use "$dropbox/Local_Econ_Corp_Tax/Data/STMUS/raw/20150819/misallocation_paneldata.dta", clear
keep year fips GOS corporate_rate taxratesales 
*keep year fips GOS corporate_rate est
*rename est est_stmus
tempfile data_GOS
sort fipstate year
save `data_GOS'

*********************************************************
*2. State Sales tax revenue data
*********************************************************
use "$dropbox/Local_Econ_Corp_Tax/Data/STMUS/raw/20150819/misallocation_paneldata.dta", clear
keep year fips rev_totaltaxes taxshare_rev_gensalestax
gen salestaxrev=rev_totaltaxes*taxshare_rev_gensalestax
keep fipstate year salestaxrev
tempfile data_salestaxrev
sort fipstate year
save `data_salestaxrev'
*********************************************************
*3. Sales from NETS
*********************************************************
use "$datapath_nets/nets_2013release_consp.dta", clear 
keep if inlist(year, 1980,1990, 2000, 2010)
rename sales sales_nets
rename emp emp_nets
rename num_est est_nets
tempfile data_sales_nets
sort conspuma year
save `data_sales_nets'

*********************************************************
*4. Corporate Tax Revenue Data
*********************************************************
use "$dropbox/Local_Econ_Corp_Tax/Data/STMUS/raw/20150819/misallocation_paneldata.dta", clear
keep year fips rev_totaltaxes taxshare_rev_corptax
gen corptaxrev=rev_totaltaxes*taxshare_rev_corptax
keep fipstate year corptaxrev
tempfile data_corptaxrev
sort fipstate year
save `data_corptaxrev'

*********************************************************
*5. State level est counts
*********************************************************
use "$dropbox/Local_Econ_Corp_Tax/Data/FINAL DATA/ForStateFigures_decade_09-23-2014.dta"
keep fips_state year est
rename est est_st
rename fips_state fipstate
tempfile data_est_st
sort fipstate year
save `data_est_st'

*********************************************************
*6. conspuma tax rates and RHS vars
*********************************************************
use "$datapath_final/ForTables_decade_09-23-2014.dta", clear
keep year conspuma d_bus_dom2  fe_group d_corp_orig d_keep_itc_state dtotalexpenditure_pop epop bartik d_corp_ext dest
tempfile data_conspuma_RHS
sort conspuma year
save `data_conspuma_RHS'

*********************************************************
*********************************************************
*II. Merge togher to conspuma spine
*********************************************************
*********************************************************
use `data_GOS', clear
*********************************************************
*1. Merge together state level datasets
*********************************************************
foreach dataset in salestaxrev corptaxrev est_st {
sort fipstate year
merge 1:1 fipstate year using `data_`dataset''
tab _merge
drop _merge
}

*********************************************************
*2. clean up
*********************************************************
keep if inlist(year, 1980,1990, 2000, 2010)
tempfile data_state_outcomes
sort fipstate year
save `data_state_outcomes'

*********************************************************
*3. Conspuma SPINE
*********************************************************
use "$dropbox/Local_Econ_Corp_Tax/Data/FINAL DATA/ForTables_annual_09-23-2014.dta", clear
keep year conspuma fips_state est pop 
rename fips_state fipstate
sort fipstate year
merge m:1 fipstate year using `data_state_outcomes'
drop if _merge==2
drop _merge

sort conspuma year 
merge 1:1 conspuma year using `data_sales_nets'
drop if _merge==2
drop _merge

*********************************************************
*4. Gen outcomes
*********************************************************
tsset conspuma year

g corptaxbase=corptaxrev/(corporate_rate/100)
g corptaxbase_posttax=(1-corporate_rate/100)*(corptaxrev/(corporate_rate/100))


foreach var in corptaxrev salestaxrev GOS corptaxbase corptaxbase_posttax taxratesales corporate_rate{
g `var'_E=`var'/est_st
g ln_`var'_E=ln(`var'_E)
g ln_`var'=ln(`var')
g D10_`var'=ln(`var')-ln(L10.`var')
g D10_`var'_E=ln(`var'_E)-ln(L10.`var'_E)
}

foreach var in sales_nets{
g `var'_E=`var'/est
g `var'_E2=`var'/est_nets
g ln_`var'_E=ln(`var'_E)
g ln_`var'_E2=ln(`var'_E2)
g ln_`var'=ln(`var')
g D10_`var'=ln(`var')-ln(L10.`var')
g D10_`var'_E=ln(`var'_E)-ln(L10.`var'_E)
g D10_`var'_E2=ln(`var'_E2)-ln(L10.`var'_E2)
}

sort conspuma year
merge 1:1 conspuma year using `data_conspuma_RHS'
drop if _merge==2
drop _merge


label var d_bus_dom2 " $\Delta \ln$ Net-of-Business-Tax Rate " 
label var d_keep_itc_state " $ \Delta \text{ State ITC} $ "
label var dtotalexpenditure_pop " $ \Delta \ln \text{Gov. Expend./Capita} $ "
label var bartik "Bartik"
label var d_corp_ext "Change in Other States' Taxes"
sort conspuma year
saveold "$dtapath/profit_validation_decade.dta", replace


