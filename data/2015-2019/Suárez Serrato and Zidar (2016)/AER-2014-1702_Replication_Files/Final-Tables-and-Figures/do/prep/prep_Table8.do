clear all 
set more off
set mem 4g

*********************************************************
*0.Map Conspumas to States
*********************************************************
	use "$dropbox/Local_Econ_Corp_Tax/Data/Regional Crosswalk Data/Conspuma2CTY/consp2cty9-22-13.dta", clear
	drop county_fips 
	duplicates drop
	rename state_fips fips_state
	tempfile data_conspuma
	sort conspuma
	save `data_conspuma'

*********************************************************
*1.Elasticity of Local Tax wrt State Tax
*********************************************************
*a. local tax rate
	use "$datapath_tax/t_bus_ms_9-22-13.dta", clear
	keep year conspuma t_e t_e_pay_domestic t_e_prop_domestic
	tempfile data_local_t_e
	sort conspuma year
	save `data_local_t_e'

*b. state corp tax rate
		use "$datapath_tax/statecorptaxdata_8-23-13.dta", clear
		keep corporate_rate fips_state year payroll property
		tempfile data_state_tax
		sort fips_state year
		save `data_state_tax'
		
		*add tax base changes
		
		insheet using "$dropbox/Local_Econ_Corp_Tax/Data/State ITC Data/cwdata_extract_for_zidar.csv", clear
		rename fipstate fips_state
		drop state
		label var itc_state "State Investment Tax Credit Rate"
		tempfile data_itc_all
		sort fips_state year
		save `data_itc_all'

		use `data_state_tax', clear
		sort fips_state year
		merge fips_state year using `data_itc_all'
		drop if _merge==2
		tsset fips_state year
		replace itc_state=L4.itc_state if year==2010
		drop _merge
		
		sort fips_state year
		save `data_state_tax', replace
		
		
*c. theta X activity weights for each factor

	*****************************************
	*c1. sales
	*****************************************
		
		********************************************************
		*c1.2 pull in income
		*********************************************************
		*do /Users/owenzidar/Dropbox/Local_Econ_Corp_Tax/Programs/Conspuma Programs/Conspuma Figures/simple bivariate graphs.do
		use "$datapath_conspuma/t_e Analysis/agg_conspuma_10-15-13.dta", clear
		keep year conspuma income payroll sales fips_state est state
		egen tot_income=total(income), by( year)
		gen s_income_c=income/tot_income
		egen s_income=total(s_income),by(year fips_state)
		gen thetaXa_sales=(sales/100) * s_income
		keep year conspuma income s_income thetaXa_sales est state 
		tempfile data_t_e_sales_domestic
		sort conspuma year
		save `data_t_e_sales_domestic' 
		
		
	*****************************************
	*c2. property and payroll
	*****************************************	
	* use `data_local_t_e', clear


	*****************************************
	*d. Merge components
	*****************************************
		use `data_local_t_e', clear
		sort conspuma 
		merge conspuma using `data_conspuma'
		tab _merge
		*drop DC
		drop if _merge==2
		drop _merge
		
		sort fips_state year
		merge fips_state year using `data_state_tax'
		*missing for 2011 and 2012
		tab _merge
		drop if _merge==2
		drop _merge
		
		sort conspuma year
		merge conspuma year using `data_t_e_sales_domestic' 
		*missing for 2011 and 1977 and two conspumas 485, 488
		tab _merge
		keep if _merge==3
		drop _merge
		
	*****************************************
	*e. Compute Elasticity of Local Tax wrt State Tax
	*****************************************
	*FROM 
	*gen t_e_pay_domestic=a_payroll* t_w; where t_w= (corporate_rate)*(payroll/100) and t_e_pay was collapsed to conspuma year

	gen a_pay_c=(t_e_pay_domestic/(corporate_rate)*(payroll/100))
	egen a_pay=total(a_pay_c), by(year fips_state)
	
	gen a_prop_c=(t_e_prop_domestic/(corporate_rate)*(property/100))
	egen a_prop=total(a_prop_c), by(year fips_state)
	
	gen thetaXa_pay=a_pay*(payroll/100) 
	gen thetaXa_prop=a_prop*(property/100) 

/*
	*Need to calculate d a_pay/ d t_s
		* d l_c/d_t_e 
		
	reg a_pay corporate_rate
	gen elas_pay_taxS =_b[corporate_rate]	
	gen elas_taxc_taxS=(1-corporate_rate/100)/(1-t_e/100)*(thetaXa_sales+ thetaXa_pay+thetaXa_prop + corporate_rate*(2*(payroll/100)*elas_pay_taxS))

*/

gen ln_t_c=ln(1-t_e/100)
gen ln_t_s=ln(1-corporate_rate/100)

reg ln_t_c ln_t_s
gen elas_taxc_taxS= _b[ln_t_s]	

*********************************************************
*2.Elasticity of State Establishmnt share wrt State Tax
*********************************************************
* a. need 1.Elasticity of Local Tax wrt State Tax
* b. E_c

	egen tot_est =total(est),by(year)
	gen E_c=est/tot_est

* c. E_s
	egen E_s =total(E_c),by(fips_state year)

*some are missing, but these should be zero to totaling in the next step corrects for this properly
gen wgted_elas=(E_c/E_s)*elas_taxc_taxS
egen sum_wgted_elas=total(wgted_elas), by(fips_state year)

gen conspuma_elas_factor_noapport=(1-E_c)
gen state_elasticity_factor_noapport=(1-E_s)
gen state_elasticity_factor_apport=(1-E_s)*sum_wgted_elas


sort conspuma year
save "$datapath_final/data_laffer.dta", replace

tempfile data_laffer
sort conspuma year
save `data_laffer'

*********************************************************
*3. Make LAFFER Table
*********************************************************

use "$datapath_final/st_corptaxrevshare.dta", clear
keep if year==2010
tempfile data_shares
sort year fips_state
save `data_shares'
clear
use `data_laffer'
* merge in rev shares
sort year fips_state
merge year fips_state using `data_shares'
drop _merge
keep if year>2009



egen tag=tag(fips_state year)
keep if tag==1
keep state fips_state year E_s corporate_rate share_perstocorp property payroll
*bring in c-corp share
sort fips_state
merge fips_state using "$dropbox/Local_Econ_Corp_Tax/Data/State CBP/stateCBP_laffershares.dta"
tab _merge
*drop dc
drop if fips_state==11
rename s_emp_st s_ccorp


saveold "$dtapath/Tables/Table8.dta", replace 
