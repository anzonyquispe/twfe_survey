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
keep year fips GOS corporate_rate taxratesales est
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
*3. conspuma tax rates and RHS
*********************************************************
use "$datapath_final/ForTables_annual_09-23-2014.dta", clear
keep year conspuma d_ln_bus_dom2  fe_group pop wgt 
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
foreach dataset in salestaxrev {
	sort fipstate year
	merge 1:1 fipstate year using `data_`dataset''
	tab _merge
	drop _merge
}

tempfile data_state_outcomes
sort fipstate year
save `data_state_outcomes'

*********************************************************
*2. Conspuma SPINE
*********************************************************
use "$dropbox/Local_Econ_Corp_Tax/Data/FINAL DATA/ForTables_annual_09-23-2014.dta", clear
keep year conspuma fips_state 
rename fips_state fipstate
sort fipstate year
merge m:1 fipstate year using `data_state_outcomes'
drop if _merge==2
drop _merge

sort conspuma year
merge 1:1 conspuma year using `data_conspuma_RHS'
drop if _merge==2
drop _merge

*********************************************************
*4. Gen outcomes
*********************************************************
tsset conspuma year

foreach var in salestaxrev GOS{
	g `var'_E=`var'/est
	g ln_`var'_E=ln(`var'_E)
	*g ln_`var'=ln(`var')
	g g_`var'=ln(`var')-ln(L1.`var')
	g g_`var'_E=ln(`var'_E)-ln(L1.`var'_E)
}


sort conspuma year
saveold "$dtapath/profit_validation_annual.dta", replace


