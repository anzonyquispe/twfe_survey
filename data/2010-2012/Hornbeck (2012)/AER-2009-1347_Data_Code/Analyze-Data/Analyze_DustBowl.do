clear all
set more off
set matsize 6000
set mem 500m
capture log close
capture clear
pause on


/*
***********************************************************************************
***********************************************************************************
																				
This do file uses the "DustBowl_All_base1910.dta" county-level panel dataset (i.e. unit of observation = county-year pair) 
of all 1910 counties that was created with the "Generate_DustBowl.do" file to perform the analyses contained in "The Enduring 
Impact of the American Dust Bowl:  Short and Long-run Adjustments to Environmental Catastrophe"

***********************************************************************************
***********************************************************************************
*/

*set log
log using Analyze_DustBowl.log, replace

*declare temporary datasets
tempfile /*sample counties*/ db_sample /*bank data*/ pre_merge_bank pre_merge_bank2 pre_merge_ICPSR_data bank_analysis pre_interaction_bank pre_interaction_ICPSR pre_regression_bank /*appendix data*/ climateiv

*set directory to current folder, which contains all of the needed data
*cd " "



***********************************************************************************
***																				***
***				Clean the data													***
***																				***
***********************************************************************************


*import the DustBowl county-year panel dataset that uses 1910 boundaries
use DustBowl_All_base1910.dta, clear

*** create sample ***
	/*keep only the 12 Dust Bowl states*/
	keep if state==8|state==19|state==20|state==27|state==30|state==31|state==35|state==38|state==40|state==46|state==48|state==56
	drop if year==1935

*** IDs ***
sort fips year
	/*for any county-year pairs missing a county acres value, assign the nearest value for the county*/
	by fips: replace county_acres = county_acres[_n+1] if county_acres==.
	by fips: replace county_acres = county_acres[_n+1] if county_acres==.
	by fips: replace county_acres = county_acres[_n-1] if county_acres==.

/*create state names*/
gen     sname = "Colorado" if state==8
replace sname = "Iowa" if state==19
replace sname = "Kansas" if state==20
replace sname = "Minnesota" if state==27
replace sname = "Montana" if state==30
replace sname = "Nebraska" if state==31
replace sname = "New Mexico" if state==35
replace sname = "North Dakota" if state==38
replace sname = "Oklahoma" if state==40
replace sname = "South Dakota" if state==46
replace sname = "Texas" if state==48
replace sname = "Wyoming" if state==56

*** Generate outcome and control variables ***
	/*farmland*/
		/*restrict sample to only county-year pairs with data on acres of farmland*/
		drop if farmland==.
		/*create fraction of county-year pair acres that are farmland*/
		gen farmland_a = farmland/county_acres
	/*cropland*/
		/*create fraction of farmland that is cropland*/
		gen cropland_f = cropland/farmland
		/*create fraction of cropland that is fallow-- for only counties with more than 1000 acres of cropland*/
		gen fallow_c = cropland_fallow/cropland if cropland>1000
	/*farm size*/
		/*create average farm size variable*/
		gen avsize = farmland/farms
		/*create farms per acre */
		gen farms_a = farms/county_acres
	/*population*/	
		/*create population per acre*/
		gen population_a = population/county_acres
		/*create fraction of population that lives in rural areas*/
		gen fraction_rural = population_rural/population
		/*create fraction of population that lives on a farm*/
		gen fraction_farm = population_farm/population
	/*value of farms*/
		/*create log of value of farm land and buildings per acre*/
		gen value_landbuildings_f = ln(value_landbuildings/farmland)
		/*Drop two outlier errors*/
		replace value_landbuildings_f = . if value_landbuildings_f<-1
		/*create log of value of farmland per acre*/
		gen value_land_f = ln(value_land/farmland)
		/*revenue*/
		/*fill in missing value of animal products using 1940 base*/
		replace value_animalproducts = value_animalproducts_base1940 if (year==1920|year==1925|year==1930)&value_animalproducts==.
		replace value_all = value_crops+value_animalproducts if (year==1920|year==1925|year==1930)&value_all==.
		/*create log of revenue of farmland per acre*/
		gen value_revenue_f = ln(value_all/farmland)

		/*acres of crops*/
		/*all corn*/
		egen corn_a = rsum(corn_grain_a corn_silage_a)
		/*all grains*/
		egen obr_a = rsum(oats_a barley_a rye_a)
		/*create fraction of cropland in each particular crop*/
		foreach i of varlist hay_a wheat_a corn_a cotton_a obr_a {
			gen `i'_c = `i'/cropland if cropland>1000
			replace `i'_c = 0 if `i'_c==.
		}
	/*livestock per acre*/
	foreach i of varlist cows pigs chickens {
		gen `i'_a = `i'/county_acres
	replace `i'_a = 0 if `i'_a==.
	}
	/*make tenant farmland all the farmland that's not owned or managed*/
	replace farmland_tenant = farmland-farmland_own-farmland_manager if farmland_tenant==.
	

***********************************************************************************
***																				***
***				Finalize the sample												***
***																				***
***********************************************************************************
	
*** Balance sample and key variables ***	
		replace cropland = . if year > 1974
		replace value_crops=. if year>1964
		replace pasture = . if year>1964
		replace population = . if year==1997
		replace value_revenue_f = . if year==1997
		replace value_landbuildings_f = . if year==1974
		replace value_all = . if year==1997
		replace value_landbuildings = . if year==1974
		
		/*count the number of years for which we have data for each county on the following variables:*/
		sort fips
			/*value of all land and buildings*/
			by fips: egen balance_value_landbuildings_f= count(value_landbuildings_f)
			drop if balance_value_landbuildings_f!=15
			/*revenue*/
			by fips: egen balance_value_revenue_f = count(value_revenue_f)
			drop if balance_value_revenue_f!=15
			/*cropland*/
			by fips: egen balance_cropland = count(cropland)
			drop if balance_cropland!=10
			/*population*/
			by fips: egen balance_population = count(population)
			drop if balance_population!=9
			/*rural population*/
			by fips: egen balance_population_rural = count(population_rural)
			drop if balance_population_rural!=8
			drop balance_value_landbuildings_f balance_value_revenue_f balance_cropland balance_population balance_population_rural
			
*** Drop "Non-Plains" counties in these states
		drop if frac_grassland_tot <.5
*** Drop non-contiguous counties failing the grassland restriction
		drop if fips == 48043 | fips == 48243 | fips == 35013 | fips == 35017 | fips == 30007

*** create dataset with two variables: fips and sample flag
preserve
keep if year==1930
gen db_sample = 1
keep fips db_sample
save `db_sample', replace 
/*output vector of counties in sample -- currently commented out*/
*outsheet using db_sample.csv, comma replace
restore

***************************************************************************************************
****																							***
****			Construct dummy and weighting variable for analysis								***
****																							***
***************************************************************************************************

*** Generate weights - based on 1930 farmland acres and population ***
gen farmland_w = farmland if year==1930
gen population_w = population if year==1930
sort fips year
by fips: egen farmland_weight = max(farmland_w)
drop farmland_w
by fips: egen population_weight = max(population_w)
drop population_w

*** Generate dummy variables ***
	/*state-year ID variable*/
	gen double id_stateyear = state*10000+year

	/*erosion-by-year*/
		/*medium erosion*/
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte m1_1_`year' = 0
			replace m1_1_`year'=m1_1 if year==`year'
		}
		/*high erosion*/
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte m1_2_`year' = 0
			replace m1_2_`year'=m1_2 if year==`year'
		}

*** Save dataset ***
save preanalysis_1910.dta, replace
clear


***********************************************************************************
***																				***
***				Conduct Analysis (i.e. generate tables and figures)				***
***																				***
***********************************************************************************


***********************************************************************************
***				Table 1.  Mean County Characteristics							***
***********************************************************************************


/*open the 1910 border dataset*/
use preanalysis_1910.dta, clear

/*keep only the 1930 characteristics*/
keep if year == 1930

/*create per 100 variables*/
gen population_a_100 = population_a*100
gen farms_a_100 = farms_a*100

*dummy regressions to start output file
reg value_landbuildings_f m1_1_1930 [aweight=farmland_weight], robust
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(dummy) 2aster replace
	
/*calculate averages and differences for table - except for average size because we want less decimal places for it*/
foreach var of varlist value_landbuildings_f value_land_f value_revenue_f farmland_a cropland_f population_a_100 fraction_rural fraction_farm farms_a_100 corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
	/*column (1): all counties averages*/
	sum `var' [aweight=farmland_weight]
	/*columns (2) and (3): difference between medium/high erosion and low erosion*/
	areg `var' 	m1_1_1930 m1_2_1930 [aweight=farmland_weight], absorb(state) robust
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(`var'_t1_23) addstat(n_fe_less_1, e(df_a)) 2aster append
	/*column (4): (3) - (2)*/
	nlcom (col4: _b[m1_2_1930]-_b[m1_1_1930]), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(`var'_t1_4) 2aster append
}

/*calculate average and difference for average size - different number of decimal places*/
	/*summary stats (columm (1)))*/
	sum avsize [aweight=farmland_weight]
	/*regression: columns 2, 3*/
	areg avsize m1_1_1930 m1_2_1930 [aweight=farmland_weight], absorb(state) robust
	outreg2 using Analysis_DustBowl.xls, dec(0) ctitle(avsize_t1_23) addstat(n_fe_less_1, e(df_a)) 2aster append
	/*column (4): (3) - (2)*/
	nlcom (col4: _b[m1_2_1930]-_b[m1_1_1930]), post
	outreg2 using Analysis_DustBowl.xls, dec(0) ctitle(avsize_t1_4) 2aster append




	
***********************************************************************************
***				Figure 1.  Aggregate Changes in Agriculture and Population		***
***********************************************************************************

*import data and aggregate to nation-year level
use preanalysis_1910.dta, clear
keep year farmland population value_landbuildings value_all
gen nation = 1
collapse (sum) farmland population value_landbuildings value_all, by(nation year)

*** create year dummies for this dataset ***
foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
	gen byte year_`year' = (year==`year')
}

*** run regressions ***
	/*A. Log farmland*/
	gen lnfarmland = ln(farmland)
	reg lnfarmland year_*, noc
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig1_lnfarmland) noaster append

	/*B. log population*/
	gen lnpopulation = ln(population)
	reg lnpopulation year_*, noc
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig1_lnpopulation) noaster append

	/*C. log value of land and buildings on farms, without CPI adjustment*/
	gen ln_value_landbuildings = ln(value_landbuildings)
	reg ln_value_landbuildings year_*, noc
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig1_ln_value_landbuildings) noaster append

	/*D. log agricultural revenues, per county acre, without PPI adjustment*/
	gen ln_value_all = ln(value_all)
	reg ln_value_all year_*, noc
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig1_ln_value_all) noaster append



	
***********************************************************************************
***				Figure 3 and Table 2.  Analysis of Land Values and Revenue		***
***********************************************************************************

***********************************************************************************
***				Construct Control Variables 									***
***********************************************************************************

/*bring in cleaned data*/	
use preanalysis_1910.dta, clear

/*Generate controls based on 1930 county values*/
/*turn off log*/
qui{
	/*for each of the county-level variables in panels B, C, D, and E of Table 1, create a var_1930 variable that is populated if the year==1930*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		/*fill the 1930 value in for all other years in the fips*/
		by fips: egen c_`var' = max(`var'_1930)
		/*replace control_var_19XX with the 1930 value*/
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
/*Generate lagged controls (i.e. lcontrol) based on pre-1930 county values (1925, 1920, 1910)*/
	/*Variables in panels B-E of Table 1*/
	/*create 3 variables that take the 1925, 1920, and 1910 values for the control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	
	/*create lagged controls for all variables in panels B-E of Table 1*/
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3
			
	/*Variables in Panel A of Table 1*/
	sort fips year
	foreach var of varlist value_landbuildings_f value_revenue_f {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	
	/*lagged versions of these variables*/
	sort fips year
	foreach var of varlist value_landbuildings_f value_revenue_f {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist value_landbuildings_f value_revenue_f {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
		drop `var'_1 `var'_2 `var'_3 ycl_`var'_1 ycl_`var'_2 ycl_`var'_3
	}
}

***************************************************************************************
*** 	Create output for Figure 3 													***
***************************************************************************************

	/*Panel A - regress per-acre value of landbuildings on fraction of county in erosion areas, by year*/
	areg value_landbuildings_f m1_1_1910-m1_1_1997 /*fraction of county in medium erosion area*/ m1_2_1910-m1_2_1997 /*fraction of county in high erosion area*/ [aweight=farmland_weight] /*weight by farmland acres*/, absorb(id_stateyear) /*state-by-year fixed effects*/
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig3_panelA) addstat(n_fe_less_1, e(df_a)) noaster append
	
	/*Panel B - add controls listed in panels B-E of Table 1*/
	areg value_landbuildings_f m1_1_1910-m1_1_1997 m1_2_1910-m1_2_1997 control_* /*include controls listed in panels B-E of Table 1*/ [aweight=farmland_weight], absorb(id_stateyear)
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig3_panelB) addstat(n_fe_less_1, e(df_a)) noaster append
	
	/*Panel C - add lagged controls*/
	areg value_landbuildings_f m1_1_1910-m1_1_1997 m1_2_1910-m1_2_1997 control_* lcontrol_*  /*include lags of controls listed in panels B-E of Table 1*/ [aweight=farmland_weight], absorb(id_stateyear)
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig3_panelC) noaster append
	
	/*Panel D - add lagged outcomes*/
	areg value_landbuildings_f m1_1_1910-m1_1_1997 m1_2_1910-m1_2_1997 control_* lcontrol_*  ycl_* /*add interactions with years*/ [aweight=farmland_weight], absorb(id_stateyear)
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(fig3_panelD) addstat(n_fe_less_1, e(df_a)) noaster append


	
***************************************************************************************
*** 	Create Table 2			 													***
***************************************************************************************
			
	/*Drop controls no longer needed*/
	foreach var of varlist value_landbuildings_f value_revenue_f {
		foreach year of numlist 1910 1920 1925 1930 {
			drop ycl_`var'_`year'
			drop ycl_`var'_1_`year'
			drop ycl_`var'_2_`year'
			drop ycl_`var'_3_`year'
		}
	}

	/*For text surrounding Table 2: calculate total number of farmland acres in high and medium erosion areas*/
		/*low erosion*/
		gen farmland_1930_low = 0
		replace farmland_1930_low = farmland*m1_0 if year==1930
		egen tot_farmland_1930_low=sum(farmland_1930_low)
		sum tot_farmland_1930_low
		scalar tot_farmland_1930_low_scalar = r(mean) /*store value of total acres*/
		reg tot_farmland_1930_low /*output total*/
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_1930_farm_low) noaster append
		/*medium erosion*/
		gen farmland_1930_med=0
		replace farmland_1930_med=farmland*m1_1 if year==1930
		egen tot_farmland_1930_med=sum(farmland_1930_med)
		sum tot_farmland_1930_med
		scalar tot_farmland_1930_med_scalar = r(mean) /*store value of total acres*/
		reg tot_farmland_1930_med /*output total*/
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_1930_farm_med) noaster append
		/*high erosion*/
		gen farmland_1930_high=0
		replace farmland_1930_high=farmland*m1_2 if year==1930
		egen tot_farmland_1930_high=sum(farmland_1930_high)
		sum tot_farmland_1930_high
		scalar tot_farmland_1930_high_scalar = r(mean) /*store value of total acres*/
		reg tot_farmland_1930_high /*output total*/
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_1930_farm_high) noaster append

	/*calculate per-acre value of farmland in high and medium areas*/
	gen value_landbuildings_perfarmacre = value_landbuildings/farmland
	reg value_landbuildings_perfarmacre m1_0 m1_1 m1_2 [aweight=farmland_weight] if year==1930, noc robust
	mat b = e(b) /*store estimates in matrix*/
	scalar farmland_val_low_1930 = b[1,1] /*extract value of land in low erosion areas*/
	scalar farmland_val_med_1930 = b[1,2] /*extract value of land in medium erosion areas*/
	scalar farmland_val_high_1930= b[1,3] /*extract value of land in high erosion areas*/
	gen farmland_val_low_1930 = farmland_val_low_1930
	gen farmland_val_med_1930 = farmland_val_med_1930 
	gen farmland_val_high_1930 = farmland_val_high_1930
	/*output results*/
	foreach level in low med high {
		reg farmland_val_`level'_1930
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_1930_val_`level') noaster append
	}
	/*calculate total value of all farmland in DB counties*/
	gen farmland_val_tot_1930 = farmland_val_low_1930*tot_farmland_1930_low + farmland_val_med_1930*tot_farmland_1930_med + farmland_val_high_1930*tot_farmland_1930_high
	scalar farmland_val_tot_1930 = farmland_val_tot_1930 /*store figure*/
	reg farmland_val_tot_1930 /*output results*/
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_1930_val_tot) noaster append
		
	/*keep only observations in years between 1940 and 1992*/
	keep if year>=1940&year<1997
	/*drop fractions in eroded areas for 1974 and 1997*/
	drop m1_1_1974 m1_2_1974 m1_1_1997 m1_2_1997

	/*Drop controls no longer needed*/
		/*turn off log file*/
		qui{
			/*drop controls*/
			sort fips year
			foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
				foreach year of numlist 1910 1920 1925 1930 {
					drop control_`var'_`year'
				}
			}
			/*drop lagged controls*/
			sort fips year
			foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
				foreach year of numlist 1910 1920 1925 1930 {
					drop lcontrol_`var'_`year'
				}
				drop `var'
			}
		}

	/*Difference from 1930*/
		/*land and buildings*/
		gen dvalue_landbuildings_f = value_landbuildings_f - ycl_value_landbuildings_f
		/*revenue*/
		gen dvalue_revenue_f = value_revenue_f - ycl_value_revenue_f
		/*drop non-differences*/
		drop ycl_value_landbuildings_f ycl_value_revenue_f
	
	/*Regress change in revenue on erosion fractions to generate annual estimates to calculate persistence (all controls) for text*/
		/*run regression*/
		areg dvalue_revenue_f m1_1_1940-m1_1_1992 /*fraction of county in medium erosion*/	m1_2_1940-m1_2_1992 /*fraction of county in high erosion*/ control_* /*controls from Table 1, panels B-E*/ lcontrol_* /*lagged controls*/ ycl_* /*years interacted with controls*/ [aweight=farmland_weight] /*weight by acres*/, absorb(id_stateyear) /*state-year fixed effects*/ cluster(fips) /*SE cluster at county*/
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(fig3_rev) addstat(n_fe_less_1, e(df_a)) 2aster append
		/*store estimates*/
		est sto averaging
		
	/*calculate ratio of coefficients on high erosion variable for year X to 1940*/
	nlcom (hp_1945: _b[m1_2_1945]/_b[m1_2_1940]) (hp_1950: _b[m1_2_1950]/_b[m1_2_1940]) (hp_1954: _b[m1_2_1954]/_b[m1_2_1940]) (hp_1959: _b[m1_2_1959]/_b[m1_2_1940]) (hp_1964: _b[m1_2_1964]/_b[m1_2_1940]) (hp_1969: _b[m1_2_1969]/_b[m1_2_1940]) (hp_1978: _b[m1_2_1978]/_b[m1_2_1940]) (hp_1982: _b[m1_2_1982]/_b[m1_2_1940]) (hp_1987: _b[m1_2_1987]/_b[m1_2_1940]) (hp_1992: _b[m1_2_1992]/_b[m1_2_1940]), post
		
	/*calculate weighted averages for intervening years*/
	nlcom (hp_1940: 1*1 + 0*_b[hp_1945]) (hp_1941: 1*0.8 + 0.2*_b[hp_1945]) (hp_1942: 1*0.6 + 0.4*_b[hp_1945]) (hp_1943: 1*0.4 + 0.6*_b[hp_1945]) (hp_1944: 1*0.2 + 0.8*_b[hp_1945]) (hp_1945: 1*0 + 1*_b[hp_1945]) (hp_1946: _b[hp_1945]*0.8 + 0.2*_b[hp_1950]) (hp_1947: _b[hp_1945]*0.6 + 0.4*_b[hp_1950]) (hp_1948: _b[hp_1945]*0.4 + 0.6*_b[hp_1950]) (hp_1949: _b[hp_1945]*0.2 + 0.8*_b[hp_1950]) (hp_1950: _b[hp_1945]*0 + 1*_b[hp_1950]) (hp_1951: _b[hp_1950]*0.75 + 0.25*_b[hp_1954]) (hp_1952: _b[hp_1950]*0.5 + 0.5*_b[hp_1954]) (hp_1953: _b[hp_1950]*0.25 + 0.75*_b[hp_1954]) (hp_1954: _b[hp_1950]*0 + 1*_b[hp_1954])  (hp_1955: _b[hp_1954]*0.8 + 0.2*_b[hp_1959]) (hp_1956: _b[hp_1954]*0.6 + 0.4*_b[hp_1959]) (hp_1957: _b[hp_1954]*0.4 + 0.6*_b[hp_1959]) (hp_1958: _b[hp_1954]*0.2 + 0.8*_b[hp_1959]) (hp_1959: _b[hp_1954]*0 + 1*_b[hp_1959])  (hp_1960: _b[hp_1959]*0.8 + 0.2*_b[hp_1964]) (hp_1961: _b[hp_1959]*0.6 + 0.4*_b[hp_1964]) (hp_1962: _b[hp_1959]*0.4 + 0.6*_b[hp_1964]) (hp_1963: _b[hp_1959]*0.2 + 0.8*_b[hp_1964]) (hp_1964: _b[hp_1959]*0 + 1*_b[hp_1964])  (hp_1965: _b[hp_1964]*0.8 + 0.2*_b[hp_1969]) (hp_1966: _b[hp_1964]*0.6 + 0.4*_b[hp_1969]) (hp_1967: _b[hp_1964]*0.4 + 0.6*_b[hp_1969]) (hp_1968: _b[hp_1964]*0.2 + 0.8*_b[hp_1969]) (hp_1969: _b[hp_1964]*0 + 1*_b[hp_1969])  (hp_1970: _b[hp_1969]*(8/9) + (1/9)*_b[hp_1978]) (hp_1971: _b[hp_1969]*(7/9) + (2/9)*_b[hp_1978]) (hp_1972: _b[hp_1969]*(6/9) + (3/9)*_b[hp_1978]) (hp_1973: _b[hp_1969]*(5/9) + (4/9)*_b[hp_1978]) (hp_1974: _b[hp_1969]*(4/9) + (5/9)*_b[hp_1978]) (hp_1975: _b[hp_1969]*(3/9) + (6/9)*_b[hp_1978]) (hp_1976: _b[hp_1969]*(2/9) + (7/9)*_b[hp_1978]) (hp_1977: _b[hp_1969]*(1/9) + (8/9)*_b[hp_1978]) (hp_1978: _b[hp_1969]*(0/9) + (9/9)*_b[hp_1978])  (hp_1979: _b[hp_1978]*0.75 + 0.25*_b[hp_1982]) (hp_1980: _b[hp_1978]*0.5 + 0.5*_b[hp_1982]) (hp_1981: _b[hp_1978]*0.25 + 0.75*_b[hp_1982]) (hp_1982: _b[hp_1978]*0 + 1*_b[hp_1982])  (hp_1983: _b[hp_1982]*0.8 + 0.2*_b[hp_1987]) (hp_1984: _b[hp_1982]*0.6 + 0.4*_b[hp_1987]) (hp_1985: _b[hp_1982]*0.4 + 0.6*_b[hp_1987]) (hp_1986: _b[hp_1982]*0.2 + 0.8*_b[hp_1987]) (hp_1987: _b[hp_1982]*0 + 1*_b[hp_1987])  (hp_1988: _b[hp_1987]*0.8 + 0.2*_b[hp_1992]) (hp_1989: _b[hp_1987]*0.6 + 0.4*_b[hp_1992]) (hp_1990: _b[hp_1987]*0.4 + 0.6*_b[hp_1992]) (hp_1991: _b[hp_1987]*0.2 + 0.8*_b[hp_1992]) (hp_1992: _b[hp_1987]*0 + 1*_b[hp_1992]), post
				
	/*discount at 5%*/
	nlcom (pdv: (0.05/1.05) * (_b[hp_1940]*(1/((1+0.05)^0)) + _b[hp_1941]*(1/((1+0.05)^1)) + _b[hp_1942]*(1/((1+0.05)^2)) + _b[hp_1943]*(1/((1+0.05)^3)) + _b[hp_1944]*(1/((1+0.05)^4)) + _b[hp_1945]*(1/((1+0.05)^5)) + _b[hp_1946]*(1/((1+0.05)^6)) + _b[hp_1947]*(1/((1+0.05)^7)) + _b[hp_1948]*(1/((1+0.05)^8)) + _b[hp_1949]*(1/((1+0.05)^9)) + _b[hp_1950]*(1/((1+0.05)^10)) + _b[hp_1951]*(1/((1+0.05)^11)) + _b[hp_1952]*(1/((1+0.05)^12)) + _b[hp_1953]*(1/((1+0.05)^13)) + _b[hp_1954]*(1/((1+0.05)^14)) + _b[hp_1955]*(1/((1+0.05)^15)) + _b[hp_1956]*(1/((1+0.05)^16)) + _b[hp_1957]*(1/((1+0.05)^17)) + _b[hp_1958]*(1/((1+0.05)^18)) + _b[hp_1959]*(1/((1+0.05)^19)) + _b[hp_1960]*(1/((1+0.05)^20)) + _b[hp_1961]*(1/((1+0.05)^21)) + _b[hp_1962]*(1/((1+0.05)^22)) + _b[hp_1963]*(1/((1+0.05)^23)) + _b[hp_1964]*(1/((1+0.05)^24)) + _b[hp_1965]*(1/((1+0.05)^25)) + _b[hp_1966]*(1/((1+0.05)^26)) + _b[hp_1967]*(1/((1+0.05)^27)) + _b[hp_1968]*(1/((1+0.05)^28)) + _b[hp_1969]*(1/((1+0.05)^29)) + _b[hp_1970]*(1/((1+0.05)^30)) + _b[hp_1971]*(1/((1+0.05)^31)) + _b[hp_1972]*(1/((1+0.05)^32)) + _b[hp_1973]*(1/((1+0.05)^33)) + _b[hp_1974]*(1/((1+0.05)^34)) + _b[hp_1975]*(1/((1+0.05)^35)) + _b[hp_1976]*(1/((1+0.05)^36)) + _b[hp_1977]*(1/((1+0.05)^37)) + _b[hp_1978]*(1/((1+0.05)^38)) + _b[hp_1979]*(1/((1+0.05)^39)) + _b[hp_1980]*(1/((1+0.05)^40)) + _b[hp_1981]*(1/((1+0.05)^41)) + _b[hp_1982]*(1/((1+0.05)^42)) + _b[hp_1983]*(1/((1+0.05)^43)) + _b[hp_1984]*(1/((1+0.05)^44)) + _b[hp_1985]*(1/((1+0.05)^45)) + _b[hp_1986]*(1/((1+0.05)^46)) + _b[hp_1987]*(1/((1+0.05)^47)) + _b[hp_1988]*(1/((1+0.05)^48)) + _b[hp_1989]*(1/((1+0.05)^49)) + _b[hp_1990]*(1/((1+0.05)^50)) + _b[hp_1991]*(1/((1+0.05)^51)) + _b[hp_1992]*(1/((1+0.05)^52))*((1+0.05)/0.05)) ), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_ratio_pdv_h) 2aster append	
					
	/*restore estimates*/
	est res averaging
	
	/*calculate ratio of medium erosion to 1940 - i.e. same as above for high, except now for medium*/
	nlcom (mp_1945: _b[m1_1_1945]/_b[m1_1_1940]) (mp_1950: _b[m1_1_1950]/_b[m1_1_1940]) (mp_1954: _b[m1_1_1954]/_b[m1_1_1940]) (mp_1959: _b[m1_1_1959]/_b[m1_1_1940]) (mp_1964: _b[m1_1_1964]/_b[m1_1_1940]) (mp_1969: _b[m1_1_1969]/_b[m1_1_1940]) (mp_1978: _b[m1_1_1978]/_b[m1_1_1940]) (mp_1982: _b[m1_1_1982]/_b[m1_1_1940]) (mp_1987: _b[m1_1_1987]/_b[m1_1_1940]) (mp_1992: _b[m1_1_1992]/_b[m1_1_1940]), post

	/*calculate weighted averages for intervening years*/
	nlcom (mp_1940: 1*1 + 0*_b[mp_1945]) (mp_1941: 1*0.8 + 0.2*_b[mp_1945]) (mp_1942: 1*0.6 + 0.4*_b[mp_1945]) (mp_1943: 1*0.4 + 0.6*_b[mp_1945]) (mp_1944: 1*0.2 + 0.8*_b[mp_1945]) (mp_1945: 1*0 + 1*_b[mp_1945]) (mp_1946: _b[mp_1945]*0.8 + 0.2*_b[mp_1950]) (mp_1947: _b[mp_1945]*0.6 + 0.4*_b[mp_1950]) (mp_1948: _b[mp_1945]*0.4 + 0.6*_b[mp_1950]) (mp_1949: _b[mp_1945]*0.2 + 0.8*_b[mp_1950]) (mp_1950: _b[mp_1945]*0 + 1*_b[mp_1950]) (mp_1951: _b[mp_1950]*0.75 + 0.25*_b[mp_1954]) (mp_1952: _b[mp_1950]*0.5 + 0.5*_b[mp_1954]) (mp_1953: _b[mp_1950]*0.25 + 0.75*_b[mp_1954]) (mp_1954: _b[mp_1950]*0 + 1*_b[mp_1954])  (mp_1955: _b[mp_1954]*0.8 + 0.2*_b[mp_1959]) (mp_1956: _b[mp_1954]*0.6 + 0.4*_b[mp_1959]) (mp_1957: _b[mp_1954]*0.4 + 0.6*_b[mp_1959]) (mp_1958: _b[mp_1954]*0.2 + 0.8*_b[mp_1959]) (mp_1959: _b[mp_1954]*0 + 1*_b[mp_1959])  (mp_1960: _b[mp_1959]*0.8 + 0.2*_b[mp_1964]) (mp_1961: _b[mp_1959]*0.6 + 0.4*_b[mp_1964]) (mp_1962: _b[mp_1959]*0.4 + 0.6*_b[mp_1964]) (mp_1963: _b[mp_1959]*0.2 + 0.8*_b[mp_1964]) (mp_1964: _b[mp_1959]*0 + 1*_b[mp_1964])  (mp_1965: _b[mp_1964]*0.8 + 0.2*_b[mp_1969]) (mp_1966: _b[mp_1964]*0.6 + 0.4*_b[mp_1969]) (mp_1967: _b[mp_1964]*0.4 + 0.6*_b[mp_1969]) (mp_1968: _b[mp_1964]*0.2 + 0.8*_b[mp_1969]) (mp_1969: _b[mp_1964]*0 + 1*_b[mp_1969])  (mp_1970: _b[mp_1969]*(8/9) + (1/9)*_b[mp_1978]) (mp_1971: _b[mp_1969]*(7/9) + (2/9)*_b[mp_1978]) (mp_1972: _b[mp_1969]*(6/9) + (3/9)*_b[mp_1978]) (mp_1973: _b[mp_1969]*(5/9) + (4/9)*_b[mp_1978]) (mp_1974: _b[mp_1969]*(4/9) + (5/9)*_b[mp_1978]) (mp_1975: _b[mp_1969]*(3/9) + (6/9)*_b[mp_1978]) (mp_1976: _b[mp_1969]*(2/9) + (7/9)*_b[mp_1978]) (mp_1977: _b[mp_1969]*(1/9) + (8/9)*_b[mp_1978]) (mp_1978: _b[mp_1969]*(0/9) + (9/9)*_b[mp_1978])  (mp_1979: _b[mp_1978]*0.75 + 0.25*_b[mp_1982]) (mp_1980: _b[mp_1978]*0.5 + 0.5*_b[mp_1982]) (mp_1981: _b[mp_1978]*0.25 + 0.75*_b[mp_1982]) (mp_1982: _b[mp_1978]*0 + 1*_b[mp_1982])  (mp_1983: _b[mp_1982]*0.8 + 0.2*_b[mp_1987]) (mp_1984: _b[mp_1982]*0.6 + 0.4*_b[mp_1987]) (mp_1985: _b[mp_1982]*0.4 + 0.6*_b[mp_1987]) (mp_1986: _b[mp_1982]*0.2 + 0.8*_b[mp_1987]) (mp_1987: _b[mp_1982]*0 + 1*_b[mp_1987])  (mp_1988: _b[mp_1987]*0.8 + 0.2*_b[mp_1992]) (mp_1989: _b[mp_1987]*0.6 + 0.4*_b[mp_1992]) (mp_1990: _b[mp_1987]*0.4 + 0.6*_b[mp_1992]) (mp_1991: _b[mp_1987]*0.2 + 0.8*_b[mp_1992]) (mp_1992: _b[mp_1987]*0 + 1*_b[mp_1992]), post

	/*discount at 5%*/
	nlcom (pdv: (0.05/1.05) * (_b[mp_1940]*(1/((1+0.05)^0)) + _b[mp_1941]*(1/((1+0.05)^1)) + _b[mp_1942]*(1/((1+0.05)^2)) + _b[mp_1943]*(1/((1+0.05)^3)) + _b[mp_1944]*(1/((1+0.05)^4)) + _b[mp_1945]*(1/((1+0.05)^5)) + _b[mp_1946]*(1/((1+0.05)^6)) + _b[mp_1947]*(1/((1+0.05)^7)) + _b[mp_1948]*(1/((1+0.05)^8)) + _b[mp_1949]*(1/((1+0.05)^9)) + _b[mp_1950]*(1/((1+0.05)^10)) + _b[mp_1951]*(1/((1+0.05)^11)) + _b[mp_1952]*(1/((1+0.05)^12)) + _b[mp_1953]*(1/((1+0.05)^13)) + _b[mp_1954]*(1/((1+0.05)^14)) + _b[mp_1955]*(1/((1+0.05)^15)) + _b[mp_1956]*(1/((1+0.05)^16)) + _b[mp_1957]*(1/((1+0.05)^17)) + _b[mp_1958]*(1/((1+0.05)^18)) + _b[mp_1959]*(1/((1+0.05)^19)) + _b[mp_1960]*(1/((1+0.05)^20)) + _b[mp_1961]*(1/((1+0.05)^21)) + _b[mp_1962]*(1/((1+0.05)^22)) + _b[mp_1963]*(1/((1+0.05)^23)) + _b[mp_1964]*(1/((1+0.05)^24)) + _b[mp_1965]*(1/((1+0.05)^25)) + _b[mp_1966]*(1/((1+0.05)^26)) + _b[mp_1967]*(1/((1+0.05)^27)) + _b[mp_1968]*(1/((1+0.05)^28)) + _b[mp_1969]*(1/((1+0.05)^29)) + _b[mp_1970]*(1/((1+0.05)^30)) + _b[mp_1971]*(1/((1+0.05)^31)) + _b[mp_1972]*(1/((1+0.05)^32)) + _b[mp_1973]*(1/((1+0.05)^33)) + _b[mp_1974]*(1/((1+0.05)^34)) + _b[mp_1975]*(1/((1+0.05)^35)) + _b[mp_1976]*(1/((1+0.05)^36)) + _b[mp_1977]*(1/((1+0.05)^37)) + _b[mp_1978]*(1/((1+0.05)^38)) + _b[mp_1979]*(1/((1+0.05)^39)) + _b[mp_1980]*(1/((1+0.05)^40)) + _b[mp_1981]*(1/((1+0.05)^41)) + _b[mp_1982]*(1/((1+0.05)^42)) + _b[mp_1983]*(1/((1+0.05)^43)) + _b[mp_1984]*(1/((1+0.05)^44)) + _b[mp_1985]*(1/((1+0.05)^45)) + _b[mp_1986]*(1/((1+0.05)^46)) + _b[mp_1987]*(1/((1+0.05)^47)) + _b[mp_1988]*(1/((1+0.05)^48)) + _b[mp_1989]*(1/((1+0.05)^49)) + _b[mp_1990]*(1/((1+0.05)^50)) + _b[mp_1991]*(1/((1+0.05)^51)) + _b[mp_1992]*(1/((1+0.05)^52))*((1+0.05)/0.05)) ), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_ratio_pdv_m) 2aster append
				
	/*restore estimates*/
	est res averaging
		
	/*calculate ratio of (1) difference between high and medium in year X and (2) difference between high and medium in 1940*/ 
	nlcom (hmp_1945: (_b[m1_2_1945]-_b[m1_1_1945])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1950: (_b[m1_2_1950]-_b[m1_1_1950])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1954: (_b[m1_2_1954]-_b[m1_1_1954])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1959: (_b[m1_2_1959]-_b[m1_1_1959])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1964: (_b[m1_2_1964]-_b[m1_1_1964])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1969: (_b[m1_2_1969]-_b[m1_1_1969])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1978: (_b[m1_2_1978]-_b[m1_1_1978])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1982: (_b[m1_2_1982]-_b[m1_1_1982])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1987: (_b[m1_2_1987]-_b[m1_1_1987])/(_b[m1_2_1940]-_b[m1_1_1940])) (hmp_1992: (_b[m1_2_1992]-_b[m1_1_1992])/(_b[m1_2_1940]-_b[m1_1_1940])), post
				
	/*calculate weighted averages for intervening years*/
	nlcom (hmp_1940: 1*1 + 0*_b[hmp_1945]) (hmp_1941: 1*0.8 + 0.2*_b[hmp_1945]) (hmp_1942: 1*0.6 + 0.4*_b[hmp_1945]) (hmp_1943: 1*0.4 + 0.6*_b[hmp_1945]) (hmp_1944: 1*0.2 + 0.8*_b[hmp_1945]) (hmp_1945: 1*0 + 1*_b[hmp_1945]) (hmp_1946: _b[hmp_1945]*0.8 + 0.2*_b[hmp_1950]) (hmp_1947: _b[hmp_1945]*0.6 + 0.4*_b[hmp_1950]) (hmp_1948: _b[hmp_1945]*0.4 + 0.6*_b[hmp_1950]) (hmp_1949: _b[hmp_1945]*0.2 + 0.8*_b[hmp_1950]) (hmp_1950: _b[hmp_1945]*0 + 1*_b[hmp_1950]) (hmp_1951: _b[hmp_1950]*0.75 + 0.25*_b[hmp_1954]) (hmp_1952: _b[hmp_1950]*0.5 + 0.5*_b[hmp_1954]) (hmp_1953: _b[hmp_1950]*0.25 + 0.75*_b[hmp_1954]) (hmp_1954: _b[hmp_1950]*0 + 1*_b[hmp_1954])  (hmp_1955: _b[hmp_1954]*0.8 + 0.2*_b[hmp_1959]) (hmp_1956: _b[hmp_1954]*0.6 + 0.4*_b[hmp_1959]) (hmp_1957: _b[hmp_1954]*0.4 + 0.6*_b[hmp_1959]) (hmp_1958: _b[hmp_1954]*0.2 + 0.8*_b[hmp_1959]) (hmp_1959: _b[hmp_1954]*0 + 1*_b[hmp_1959])  (hmp_1960: _b[hmp_1959]*0.8 + 0.2*_b[hmp_1964]) (hmp_1961: _b[hmp_1959]*0.6 + 0.4*_b[hmp_1964]) (hmp_1962: _b[hmp_1959]*0.4 + 0.6*_b[hmp_1964]) (hmp_1963: _b[hmp_1959]*0.2 + 0.8*_b[hmp_1964]) (hmp_1964: _b[hmp_1959]*0 + 1*_b[hmp_1964])  (hmp_1965: _b[hmp_1964]*0.8 + 0.2*_b[hmp_1969]) (hmp_1966: _b[hmp_1964]*0.6 + 0.4*_b[hmp_1969]) (hmp_1967: _b[hmp_1964]*0.4 + 0.6*_b[hmp_1969]) (hmp_1968: _b[hmp_1964]*0.2 + 0.8*_b[hmp_1969]) (hmp_1969: _b[hmp_1964]*0 + 1*_b[hmp_1969])  (hmp_1970: _b[hmp_1969]*(8/9) + (1/9)*_b[hmp_1978]) (hmp_1971: _b[hmp_1969]*(7/9) + (2/9)*_b[hmp_1978]) (hmp_1972: _b[hmp_1969]*(6/9) + (3/9)*_b[hmp_1978]) (hmp_1973: _b[hmp_1969]*(5/9) + (4/9)*_b[hmp_1978]) (hmp_1974: _b[hmp_1969]*(4/9) + (5/9)*_b[hmp_1978]) (hmp_1975: _b[hmp_1969]*(3/9) + (6/9)*_b[hmp_1978]) (hmp_1976: _b[hmp_1969]*(2/9) + (7/9)*_b[hmp_1978]) (hmp_1977: _b[hmp_1969]*(1/9) + (8/9)*_b[hmp_1978]) (hmp_1978: _b[hmp_1969]*(0/9) + (9/9)*_b[hmp_1978])  (hmp_1979: _b[hmp_1978]*0.75 + 0.25*_b[hmp_1982]) (hmp_1980: _b[hmp_1978]*0.5 + 0.5*_b[hmp_1982]) (hmp_1981: _b[hmp_1978]*0.25 + 0.75*_b[hmp_1982]) (hmp_1982: _b[hmp_1978]*0 + 1*_b[hmp_1982])  (hmp_1983: _b[hmp_1982]*0.8 + 0.2*_b[hmp_1987]) (hmp_1984: _b[hmp_1982]*0.6 + 0.4*_b[hmp_1987]) (hmp_1985: _b[hmp_1982]*0.4 + 0.6*_b[hmp_1987]) (hmp_1986: _b[hmp_1982]*0.2 + 0.8*_b[hmp_1987]) (hmp_1987: _b[hmp_1982]*0 + 1*_b[hmp_1987])  (hmp_1988: _b[hmp_1987]*0.8 + 0.2*_b[hmp_1992]) (hmp_1989: _b[hmp_1987]*0.6 + 0.4*_b[hmp_1992]) (hmp_1990: _b[hmp_1987]*0.4 + 0.6*_b[hmp_1992]) (hmp_1991: _b[hmp_1987]*0.2 + 0.8*_b[hmp_1992]) (hmp_1992: _b[hmp_1987]*0 + 1*_b[hmp_1992]), post

	/*discount at 5%*/
	nlcom (pdv: (0.05/1.05) * (_b[hmp_1940]*(1/((1+0.05)^0)) + _b[hmp_1941]*(1/((1+0.05)^1)) + _b[hmp_1942]*(1/((1+0.05)^2)) + _b[hmp_1943]*(1/((1+0.05)^3)) + _b[hmp_1944]*(1/((1+0.05)^4)) + _b[hmp_1945]*(1/((1+0.05)^5)) + _b[hmp_1946]*(1/((1+0.05)^6)) + _b[hmp_1947]*(1/((1+0.05)^7)) + _b[hmp_1948]*(1/((1+0.05)^8)) + _b[hmp_1949]*(1/((1+0.05)^9)) + _b[hmp_1950]*(1/((1+0.05)^10)) + _b[hmp_1951]*(1/((1+0.05)^11)) + _b[hmp_1952]*(1/((1+0.05)^12)) + _b[hmp_1953]*(1/((1+0.05)^13)) + _b[hmp_1954]*(1/((1+0.05)^14)) + _b[hmp_1955]*(1/((1+0.05)^15)) + _b[hmp_1956]*(1/((1+0.05)^16)) + _b[hmp_1957]*(1/((1+0.05)^17)) + _b[hmp_1958]*(1/((1+0.05)^18)) + _b[hmp_1959]*(1/((1+0.05)^19)) + _b[hmp_1960]*(1/((1+0.05)^20)) + _b[hmp_1961]*(1/((1+0.05)^21)) + _b[hmp_1962]*(1/((1+0.05)^22)) + _b[hmp_1963]*(1/((1+0.05)^23)) + _b[hmp_1964]*(1/((1+0.05)^24)) + _b[hmp_1965]*(1/((1+0.05)^25)) + _b[hmp_1966]*(1/((1+0.05)^26)) + _b[hmp_1967]*(1/((1+0.05)^27)) + _b[hmp_1968]*(1/((1+0.05)^28)) + _b[hmp_1969]*(1/((1+0.05)^29)) + _b[hmp_1970]*(1/((1+0.05)^30)) + _b[hmp_1971]*(1/((1+0.05)^31)) + _b[hmp_1972]*(1/((1+0.05)^32)) + _b[hmp_1973]*(1/((1+0.05)^33)) + _b[hmp_1974]*(1/((1+0.05)^34)) + _b[hmp_1975]*(1/((1+0.05)^35)) + _b[hmp_1976]*(1/((1+0.05)^36)) + _b[hmp_1977]*(1/((1+0.05)^37)) + _b[hmp_1978]*(1/((1+0.05)^38)) + _b[hmp_1979]*(1/((1+0.05)^39)) + _b[hmp_1980]*(1/((1+0.05)^40)) + _b[hmp_1981]*(1/((1+0.05)^41)) + _b[hmp_1982]*(1/((1+0.05)^42)) + _b[hmp_1983]*(1/((1+0.05)^43)) + _b[hmp_1984]*(1/((1+0.05)^44)) + _b[hmp_1985]*(1/((1+0.05)^45)) + _b[hmp_1986]*(1/((1+0.05)^46)) + _b[hmp_1987]*(1/((1+0.05)^47)) + _b[hmp_1988]*(1/((1+0.05)^48)) + _b[hmp_1989]*(1/((1+0.05)^49)) + _b[hmp_1990]*(1/((1+0.05)^50)) + _b[hmp_1991]*(1/((1+0.05)^51)) + _b[hmp_1992]*(1/((1+0.05)^52))*((1+0.05)/0.05)) ), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_ratio_pdv_hm) 2aster append

				
*Group years
	/*medium erosion*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1969 = 0
	replace m1_1_1959_1969 = m1_1_1959 if year==1959
	replace m1_1_1959_1969 = m1_1_1964 if year==1964
	replace m1_1_1959_1969 = m1_1_1969 if year==1969
	gen m1_1_1978_1992 = 0
	replace m1_1_1978_1992 = m1_1_1978 if year==1978
	replace m1_1_1978_1992 = m1_1_1982 if year==1982
	replace m1_1_1978_1992 = m1_1_1987 if year==1987
	replace m1_1_1978_1992 = m1_1_1992 if year==1992
	
	/*high erosion*/
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1969 = 0
	replace m1_2_1959_1969 = m1_2_1959 if year==1959
	replace m1_2_1959_1969 = m1_2_1964 if year==1964
	replace m1_2_1959_1969 = m1_2_1969 if year==1969
	gen m1_2_1978_1992 = 0
	replace m1_2_1978_1992 = m1_2_1978 if year==1978
	replace m1_2_1978_1992 = m1_2_1982 if year==1982
	replace m1_2_1978_1992 = m1_2_1987 if year==1987
	replace m1_2_1978_1992 = m1_2_1992 if year==1992
	
*Table 2, column 1 - regress change in land value on pooled differences
	/*run regression to obtain (1) high-low and (2) medium-low coefficients*/
	areg dvalue_landbuildings_f	m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1969 m1_1_1978_1992 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1969 m1_2_1978_1992 control_* lcontrol_* ycl_* [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t2_landvalue_a) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append

		/*calculate for each level of erosion for text*/
		nlcom (medium: _b[m1_1_1940]*tot_farmland_1930_med_scalar*farmland_val_med_1930) (high:	_b[m1_2_1940]*tot_farmland_1930_high_scalar*farmland_val_high_1930) (total: _b[m1_1_1940]*tot_farmland_1930_med_scalar*farmland_val_med_1930 + _b[m1_2_1940]*tot_farmland_1930_high_scalar*farmland_val_high_1930), post
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tot_cost) 2aster append
						
		/*Calculate difference between high and medium coefficient*/
		areg dvalue_landbuildings_f m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1969 m1_1_1978_1992 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1969 m1_2_1978_1992 control_* lcontrol_* ycl_* [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
		nlcom (hm_1940: _b[m1_2_1940]-_b[m1_1_1940]) (hm_1945: _b[m1_2_1945]-_b[m1_1_1945]) (hm_1950_1954: _b[m1_2_1950_1954]-_b[m1_1_1950_1954]) (hm_1959_1969: _b[m1_2_1959_1969]-_b[m1_1_1959_1969]) (hm_1978_1992: _b[m1_2_1978_1992]-_b[m1_1_1978_1992]), post
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t2_landvalue_b) 2aster append

*Table 2, column 2 - regress change in revenue on erosion
	/*run regression to obtain coefficients for (1) high-low and (2) medium-low*/
	areg dvalue_revenue_f m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1969 m1_1_1978_1992 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1969 m1_2_1978_1992 control_* lcontrol_* ycl_* [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t2_rev_a) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append	
					
	/*Calculate difference between high and medium coefficient for coefficient on (3) high-medium*/
	nlcom (hm_1940: _b[m1_2_1940]-_b[m1_1_1940]) (hm_1945: _b[m1_2_1945]-_b[m1_1_1945]) (hm_1950_1954: _b[m1_2_1950_1954]-_b[m1_1_1950_1954]) (hm_1959_1969: _b[m1_2_1959_1969]-_b[m1_1_1959_1969]) (hm_1978_1992: _b[m1_2_1978_1992]-_b[m1_1_1978_1992]), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t2_rev_b) 2aster append

	
*Table 2, column 3
	/*Generate state fixed effects, because not able to use areg*/
	tab state, gen(state_)

	/*regress change in value of farm on erosion*/
	reg dvalue_landbuildings_f m1_1_1940 m1_2_1940 state_* control_* lcontrol_* ycl_* [aweight=farmland_weight] if year==1940, score(a)
		
	/*store estimates*/
	est sto one

	/*regress change in revenue on erosion*/
	reg dvalue_revenue_f m1_1_1940 m1_2_1940 state_* control_* lcontrol_* ycl_*  [aweight=farmland_weight] if year==1940, score(b)
		
	/*store estimates*/
	est sto two

	/*run seemingly unrelated regressions*/
	suest one two

	/*calculate ratios*/
	nlcom 	(ddd_1940: ([one_mean]m1_2_1940-[one_mean]m1_1_1940) / ([two_mean]m1_2_1940 - [two_mean]m1_1_1940)) (medium_1940: [one_mean]m1_1_1940 / [two_mean]m1_1_1940) (heavy_1940: [one_mean]m1_2_1940 / [two_mean]m1_2_1940), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t2_ratio) 2aster append

	test _b[ddd_1940]=_b[medium_1940]=_b[heavy_1940]
	nlcom (average: (_b[ddd_1940]+_b[medium_1940]+_b[heavy_1940])/3)
	
	/*run GLS*/
		mat A = [1, 1, 1]
		mat X = A'
		mat B = e(b)
		mat Y = B'
		mat V = e(V)
		mat W = syminv(V)
		mat G = (syminv(X'*W*X))*X'*W*Y
		mat H = (syminv(X'*X))*X'*V*X*(syminv(X'*X))
		mat OLSSE = cholesky(H)
		mat J = syminv(X'*W*X)
		mat GLSSE = cholesky(J)
	
	mat list G
	mat list GLSSE
	mat list H
	mat list OLSSE
	
	/*output results*/
	scalar GLS = G[1,1]
	gen GLS = GLS
	scalar GLSSE = GLSSE[1,1]
	gen GLSSE = GLSSE
	scalar OLSSE = OLSSE[1,1]
	gen OLSSE = OLSSE
	preserve
	/*export the elements of the matrices*/
	keep GLS GLSSE OLSSE
	keep if _n==1
	outsheet using Analysis_DustBowl_2.csv, comma replace
	restore
	clear
	


*********************************************************
***		Table 3.  Changes in Ag production			*****
*********************************************************

*** Column 1, Farmland Share
	/*open preanalysis dataset*/
	use preanalysis_1910.dta, clear
	
qui{
	/*create pooled erosion levels*/
	drop if year==1997 /*no 1997 data*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_1_1969_1974 = 0
	replace m1_1_1969_1974 = m1_1_1969 if year==1969
	replace m1_1_1969_1974 = m1_1_1974 if year==1974
	gen m1_1_1978_1992 = 0
	replace m1_1_1978_1992 = m1_1_1978 if year==1978
	replace m1_1_1978_1992 = m1_1_1982 if year==1982
	replace m1_1_1978_1992 = m1_1_1987 if year==1987
	replace m1_1_1978_1992 = m1_1_1992 if year==1992
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964
	gen m1_2_1969_1974 = 0
	replace m1_2_1969_1974 = m1_2_1969 if year==1969
	replace m1_2_1969_1974 = m1_2_1974 if year==1974
	gen m1_2_1978_1992 = 0
	replace m1_2_1978_1992 = m1_2_1978 if year==1978
	replace m1_2_1978_1992 = m1_2_1982 if year==1982
	replace m1_2_1978_1992 = m1_2_1987 if year==1987
	replace m1_2_1978_1992 = m1_2_1992 if year==1992

	/*generate controls for 1930 levels*/
	sort fips year
	foreach var of varlist cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged controls variables for 1930*/	
	sort fips year
	foreach var of varlist cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930 /*1925 value*/
 		by fips: gen `var'_2 = `var'[_n-2] if year==1930 /*1920 value*/
		by fips: gen `var'_3 = `var'[_n-3] if year==1930 /*1910 value*/
	}
	
	/*fill values down for each fips*/
	foreach var of varlist 	cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 { 
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	
	/*drop all other unused control variables*/
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3
	
	/*create control for fraction of county that's farmland interacted with each year*/
	sort fips year
	foreach var of varlist farmland_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	
	/*create lagged controls for fraction county that's farmland*/
	sort fips year
	foreach var of varlist farmland_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a { /*fill down*/
		by fips: egen ycl_`var'_1 = max(`var'_1)
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 { 
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
	drop `var'_1 `var'_2 `var'_3 ycl_`var'_1 ycl_`var'_2 ycl_`var'_3
	}

	/*calculate differences for all years starting with 1940*/
	keep if year>=1940
	gen dfarmland_a = farmland_a - ycl_farmland_a
	drop ycl_farmland_a
}
	
/*regress difference in farmland acres on erosion years*/
areg dfarmland_a m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_1_1969_1974 m1_1_1978_1992 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 m1_2_1969_1974 m1_2_1978_1992 control_* lcontrol_* ycl_* [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_farmland_a) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Farmland") 2aster append



*** Column 2, Log Crop Productivity
	/*import preanalysis dataset*/
	use preanalysis_1910.dta, clear

qui{
	/*generate cropland and pastureland weights*/
	gen cropland_w = cropland if year==1930
	gen pasture_w = pasture if year==1930
	gen cp_w = (cropland+pasture) if year==1930
	sort fips year
	by fips: egen cropland_weight = max(cropland_w) /*fill down*/
	by fips: egen pasture_weight = max(pasture_w)
	by fips: egen cp_weight = max(cp_w)
	drop cropland_w pasture_w cp_w

	/*calculate productivities*/
	gen cropland_p = ln(value_crops/cropland)
	gen animal_p = ln(value_animalproducts/pasture)
	gen crop_allocation = cropland/(pasture+cropland)

	/*create erosion-year variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964

	/*create control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 { 
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 { 
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create interacted year-control variables*/
	sort fips year
	foreach var of varlist cropland_p {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 { 
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}

	/*create lagged interacted year-control variables*/
	sort fips year
	foreach var of varlist cropland_p {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
	}
	foreach var of varlist cropland_p {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 { 
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
		}
		drop `var'_1 ycl_`var'_1
	}

	/*keep only observations in 1940 and beyond*/
	keep if year>=1940
	/*create difference in productivity between time t and t-1*/
	gen dcropland_p = cropland_p - ycl_cropland_p
	drop ycl_cropland_p
	
}

/*run regression to calculate colum 2*/
areg dcropland_p m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 control_* lcontrol_* ycl_* [aweight=cropland_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_cropland_p) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Cropland") 2aster append

*** Column 3, Log Pasture Productivity

/*import data*/
use preanalysis_1910.dta, clear

qui{	
	/*create cropland and pastureland weights*/
	gen cropland_w = cropland if year==1930
	gen pasture_w = pasture if year==1930
	gen cp_w = (cropland+pasture) if year==1930
	sort fips year
	by fips: egen cropland_weight = max(cropland_w)
	by fips: egen pasture_weight = max(pasture_w)
	by fips: egen cp_weight = max(cp_w)
	drop cropland_w pasture_w cp_w

	/*create productivities*/
	gen cropland_p = ln(value_crops/cropland)
	gen animal_p = ln(value_animalproducts/pasture)
	gen crop_allocation = cropland/(pasture+cropland)

	/*create erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964

	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create year-interacted control variables*/
	sort fips year
	foreach var of varlist animal_p {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	
	/*create lagged year-interacted control variables*/
	sort fips year
	foreach var of varlist animal_p {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
	}
	foreach var of varlist animal_p {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
		}
	drop `var'_1 ycl_`var'_1
	}

	/*keep if year is 1940 or beyond*/
	keep if year>=1940
	/*create difference outcome*/
	gen danimal_p = animal_p - ycl_animal_p
	drop ycl_animal_p
}

/*run regression to calculate column 3*/
areg danimal_p m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 control_* lcontrol_* ycl_* [aweight=pasture_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_animal_p) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Pasture") 2aster append
			
			
*** Column 4, Land Share in Cropland

/*import data*/
use preanalysis_1910.dta, clear

qui{
	/*create crop and pasture weighting variables*/
	gen cropland_w = cropland if year==1930
	gen pasture_w = pasture if year==1930
	gen cp_w = (cropland+pasture) if year==1930
	sort fips year
	by fips: egen cropland_weight = max(cropland_w)
	by fips: egen pasture_weight = max(pasture_w)
	by fips: egen cp_weight = max(cp_w)
	drop cropland_w pasture_w cp_w

	/*calculate crop allocation*/
	gen cropland_p = ln(value_crops/cropland)
	gen animal_p = ln(value_animalproducts/pasture)
	gen crop_allocation = cropland/(pasture+cropland)

	/*create erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964

	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create year-interacted control variables*/
	sort fips year
	foreach var of varlist crop_allocation {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}


	/*create lagged year-interacted control variables*/
	sort fips year
	foreach var of varlist crop_allocation {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
	}
	foreach var of varlist crop_allocation {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
		}
		drop `var'_1 ycl_`var'_1
	}

	/*keep if year is 1940 or beyond*/
	keep if year>=1940
	/*calculate differences*/
	gen dcrop_allocation = crop_allocation - ycl_crop_allocation
	drop ycl_crop_allocation
}	

/*run regression to calculate colum 4*/
areg dcrop_allocation m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 control_* lcontrol_* ycl_* [aweight=cp_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_crop_allocation) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "(2) + (3)") 2aster append


*** Column 5, Log Wheat Productivity

/*import data*/
use preanalysis_1910.dta, clear

qui{
	/*create erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_1_1969_1974 = 0
	replace m1_1_1969_1974 = m1_1_1969 if year==1969
	replace m1_1_1969_1974 = m1_1_1974 if year==1974
	gen m1_1_1978_1992 = 0
	replace m1_1_1978_1992 = m1_1_1978 if year==1978
	replace m1_1_1978_1992 = m1_1_1982 if year==1982
	replace m1_1_1978_1992 = m1_1_1987 if year==1987
	replace m1_1_1978_1992 = m1_1_1992 if year==1992
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964
	gen m1_2_1969_1974 = 0
	replace m1_2_1969_1974 = m1_2_1969 if year==1969
	replace m1_2_1969_1974 = m1_2_1974 if year==1974
	gen m1_2_1978_1992 = 0
	replace m1_2_1978_1992 = m1_2_1978 if year==1978
	replace m1_2_1978_1992 = m1_2_1982 if year==1982
	replace m1_2_1978_1992 = m1_2_1987 if year==1987
	replace m1_2_1978_1992 = m1_2_1992 if year==1992

	/*calculate log productivities and weights*/
	sort fips
	foreach i in wheat hay {
		gen ln`i'_p = ln(`i'_y/`i'_a)
		gen `i'_w = `i'_a if year==1930
		by fips: egen `i'_weight = max(`i'_w)
		by fips:  egen balance_`i' = count(ln`i'_p)
	}

	/*calculate wheat share of hay and wheat acres*/
	gen hay_wheat = hay_a+wheat_a
	gen wshare_haywheat = wheat_a/hay_wheat
	gen hay_wheat_w = hay_wheat if year==1930
	sort fips
	by fips: egen hay_wheat_weight = max(hay_wheat_w)

	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}	
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3

	/*create year-interacted control variables*/
	sort fips year
	foreach var of varlist lnwheat_p {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	
	/*create lagged year-interacted control variables*/
	sort fips year
	foreach var of varlist lnwheat_p {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist lnwheat_p {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
		drop `var'_1 ycl_`var'_1 `var'_2 ycl_`var'_2 `var'_3 ycl_`var'_3
	}

	/*keep only years 1940 and beyond*/
	keep if year>=1940
	
	/*create differences*/
	gen dlnwheat_p = lnwheat_p - ycl_lnwheat_p
	drop ycl_lnwheat_p
}
	
/*run regression for column 5*/ 
areg dlnwheat_p m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_1_1969_1974 m1_1_1978_1992 m1_1_1997 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 m1_2_1969_1974 m1_2_1978_1992 m1_2_1997 control_* lcontrol_* ycl_* if balance_wheat==17 & balance_hay==15 [aweight=wheat_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_lnwheat_p) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Wheat") 2aster append



*** Column 6, Log Hay Productivity

/*import data*/
use preanalysis_1910.dta, clear

qui{
	/*calculate erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_1_1969_1974 = 0
	replace m1_1_1969_1974 = m1_1_1969 if year==1969
	replace m1_1_1969_1974 = m1_1_1974 if year==1974
	gen m1_1_1978_1992 = 0
	replace m1_1_1978_1992 = m1_1_1978 if year==1978
	replace m1_1_1978_1992 = m1_1_1982 if year==1982
	replace m1_1_1978_1992 = m1_1_1987 if year==1987
	replace m1_1_1978_1992 = m1_1_1992 if year==1992
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964
	gen m1_2_1969_1974 = 0
	replace m1_2_1969_1974 = m1_2_1969 if year==1969
	replace m1_2_1969_1974 = m1_2_1974 if year==1974
	gen m1_2_1978_1992 = 0
	replace m1_2_1978_1992 = m1_2_1978 if year==1978
	replace m1_2_1978_1992 = m1_2_1982 if year==1982
	replace m1_2_1978_1992 = m1_2_1987 if year==1987
	replace m1_2_1978_1992 = m1_2_1992 if year==1992

	/*calculate weights and productivities*/	
	sort fips
	foreach i in wheat hay {
		gen ln`i'_p = ln(`i'_y/`i'_a)
		gen `i'_w = `i'_a if year==1930
		by fips: egen `i'_weight = max(`i'_w)
		by fips:  egen balance_`i' = count(ln`i'_p)
	}

	/*calculate outcome variables*/
	gen hay_wheat = hay_a+wheat_a
	gen wshare_haywheat = wheat_a/hay_wheat
	gen hay_wheat_w = hay_wheat if year==1930
	sort fips
	by fips: egen hay_wheat_weight = max(hay_wheat_w)

	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1  population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}	
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3

	/*create year interaction control variables*/
	sort fips year
	foreach var of varlist lnhay_p {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}

	/*create lagged year-interaction control variables*/
	sort fips year
	foreach var of varlist lnhay_p {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist lnhay_p {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
		drop `var'_1 ycl_`var'_1 `var'_2 ycl_`var'_2 `var'_3 ycl_`var'_3
	}

	/*keep if year is at least 1940*/
	keep if year>=1940
	
	/*create differences*/
	gen dlnhay_p = lnhay_p - ycl_lnhay_p
	drop ycl_lnhay_p
}
	
/*run regression to calculate column 6*/
areg dlnhay_p m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_1_1969_1974 m1_1_1978_1992 m1_1_1997 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 m1_2_1969_1974 m1_2_1978_1992 m1_2_1997 control_* lcontrol_* ycl_* if balance_wheat==17 & balance_hay==15 [aweight=hay_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_lnhay_p) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Hay") 2aster append
			
			
***Column 7, Land Share in Wheat

/*import data*/
use preanalysis_1910.dta, clear

qui{
	/*create erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_1_1969_1974 = 0
	replace m1_1_1969_1974 = m1_1_1969 if year==1969
	replace m1_1_1969_1974 = m1_1_1974 if year==1974
	gen m1_1_1978_1992 = 0
	replace m1_1_1978_1992 = m1_1_1978 if year==1978
	replace m1_1_1978_1992 = m1_1_1982 if year==1982
	replace m1_1_1978_1992 = m1_1_1987 if year==1987
	replace m1_1_1978_1992 = m1_1_1992 if year==1992
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964
	gen m1_2_1969_1974 = 0
	replace m1_2_1969_1974 = m1_2_1969 if year==1969
	replace m1_2_1969_1974 = m1_2_1974 if year==1974
	gen m1_2_1978_1992 = 0
	replace m1_2_1978_1992 = m1_2_1978 if year==1978
	replace m1_2_1978_1992 = m1_2_1982 if year==1982
	replace m1_2_1978_1992 = m1_2_1987 if year==1987
	replace m1_2_1978_1992 = m1_2_1992 if year==1992

	/*create weights and log productivities*/
	sort fips
	foreach i in wheat hay {
		gen ln`i'_p = ln(`i'_y/`i'_a)
		gen `i'_w = `i'_a if year==1930
		by fips: egen `i'_weight = max(`i'_w)
		by fips:  egen balance_`i' = count(ln`i'_p)
	}

	/*calculate share of wheat and hay in wheat*/
	gen hay_wheat = hay_a+wheat_a
	gen wshare_haywheat = wheat_a/hay_wheat
	gen hay_wheat_w = hay_wheat if year==1930
	sort fips
	by fips: egen hay_wheat_weight = max(hay_wheat_w)

	/*calcluate control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*calculate lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3

	/*calculate year interacted control variables*/
	sort fips year
	foreach var of varlist wshare_haywheat {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	
	/*calculate lagged year-interacted control variables*/
	sort fips year
	foreach var of varlist wshare_haywheat {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist wshare_haywheat {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
		drop `var'_1 ycl_`var'_1 `var'_2 ycl_`var'_2 `var'_3 ycl_`var'_3
	}

	/*keep only if year is at least 1940*/
	keep if year>=1940
	gen dwshare_haywheat = wshare_haywheat - ycl_wshare_haywheat
	drop ycl_wshare_haywheat
}

/*run regression to calculate output for column 7*/
areg dwshare_haywheat m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_1_1969_1974 m1_1_1978_1992 m1_1_1997 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 m1_2_1969_1974 m1_2_1978_1992 m1_2_1997 control_* lcontrol_* ycl_* if balance_wheat==17 & balance_hay==15 [aweight=hay_wheat_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t3_wshare_haywheat) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "(5) + (6)") 2aster append

	



***********************************************************************
***		Table 4: Analysis of Population and Industry				***
***********************************************************************


*** Column 1, Log Population

/*import data*/
use preanalysis_1910.dta, clear

/*create outcome variable*/
gen lnpopulation = ln(population)

qui{
	/*create grouped decade erosion variables*/
	foreach level in 1 2 {
		replace m1_`level'_1950 = m1_`level'_1945 if year==1945
		replace m1_`level'_1950 = m1_`level'_1954 if year==1954
		replace m1_`level'_1959 = m1_`level'_1959 if year==1959
		replace m1_`level'_1959 = m1_`level'_1964 if year==1964
		replace m1_`level'_1969 = m1_`level'_1969 if year==1969
		replace m1_`level'_1969 = m1_`level'_1974 if year==1974
		replace m1_`level'_1978 = m1_`level'_1978 if year==1978
		replace m1_`level'_1978 = m1_`level'_1982 if year==1982
		replace m1_`level'_1987 = m1_`level'_1987 if year==1987
		replace m1_`level'_1987 = m1_`level'_1992 if year==1992
	}
	
	/*create control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create lagged outcome variables*/		
	sort fips year
	foreach var of varlist lnpopulation {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	sort fips year
	foreach var of varlist lnpopulation {
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist lnpopulation {
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
		drop `var'_2 `var'_3 ycl_`var'_2 ycl_`var'_3
	}

	/*count number of observations with no population data*/
	tab year if lnpopulation!=.

	/*keep if year is 1940 or later*/
	keep if year>=1940
	
	/*calculate differences, which are the dependent variable in the regression*/
	gen dlnpopulation = lnpopulation - ycl_lnpopulation
	drop ycl_lnpopulation
}

/*run regression for column 1 of Table 4*/
areg dlnpopulation m1_1_1940 m1_1_1950 m1_1_1959 m1_1_1969 m1_1_1978 m1_1_1987 m1_2_1940 m1_2_1950 m1_2_1959 m1_2_1969 m1_2_1978 m1_2_1987 control_* lcontrol_* ycl_* [aweight=population_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t4_lnpopulation) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append


	
*** Column 2, Log manufacturing establishments
qui{
	/*import data*/
	use preanalysis_1910.dta, clear

	/*create outcome variable*/
	gen ln_man_est = ln(manufacturing_establishments)
	sort fips
	by fips: egen balance_man_est = count(ln_man_est)

	/*create grouped decade erosion variables*/
	foreach level in 1 2 {
		replace m1_`level'_1950 = m1_`level'_1945 if year==1945
		replace m1_`level'_1950 = m1_`level'_1954 if year==1954
		replace m1_`level'_1959 = m1_`level'_1959 if year==1959
		replace m1_`level'_1959 = m1_`level'_1964 if year==1964
		replace m1_`level'_1969 = m1_`level'_1969 if year==1969
		replace m1_`level'_1969 = m1_`level'_1974 if year==1974
		replace m1_`level'_1978 = m1_`level'_1978 if year==1978
		replace m1_`level'_1978 = m1_`level'_1982 if year==1982
		replace m1_`level'_1987 = m1_`level'_1987 if year==1987
		replace m1_`level'_1987 = m1_`level'_1992 if year==1992
	}
		
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create lagged outcome variables*/
	sort fips year
	foreach var of varlist ln_man_est {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	sort fips year
	foreach var of varlist ln_man_est {
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
	}
	foreach var of varlist ln_man_est {
		by fips: egen ycl_`var'_2 = max(`var'_2)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
		}
		drop `var'_2 ycl_`var'_2
	}

	/*keep if year at least 1940*/
	keep if year>=1940
	
	/*create differences (i.e. dependent variable)*/
	gen dln_man_est = ln_man_est - ycl_ln_man_est
	drop ycl_ln_man_est
}

/*run regressions to populate column 2 of Table 4*/
areg dln_man_est m1_1_1940 m1_1_1950 m1_1_1959 m1_1_1969 m1_1_1978 m1_1_1987 m1_2_1940 m1_2_1950 m1_2_1959 m1_2_1969 m1_2_1978 m1_2_1987 control_* lcontrol_* ycl_* if balance_man_est == 13 [aweight=population_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t4_ln_man_est) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append
	
	
	

		
*** Column 3, manufacturing workers per capita
qui{
	/*import data*/
	use preanalysis_1910.dta, clear

	/*create outcome variable*/
	gen man_wrk = manufacturing_workers/population
	sort fips
	by fips: egen balance_man_wrk = count(man_wrk)

	/*create grouped decade erosion variables*/
	foreach level in 1 2 {
		replace m1_`level'_1950 = m1_`level'_1945 if year==1945
		replace m1_`level'_1950 = m1_`level'_1954 if year==1954
		replace m1_`level'_1959 = m1_`level'_1959 if year==1959
		replace m1_`level'_1959 = m1_`level'_1964 if year==1964
		replace m1_`level'_1969 = m1_`level'_1969 if year==1969
		replace m1_`level'_1969 = m1_`level'_1974 if year==1974
		replace m1_`level'_1978 = m1_`level'_1978 if year==1978
		replace m1_`level'_1978 = m1_`level'_1982 if year==1982
		replace m1_`level'_1987 = m1_`level'_1987 if year==1987
		replace m1_`level'_1987 = m1_`level'_1992 if year==1992
	}
	
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create lagged outcome variables*/
	sort fips year
	foreach var of varlist man_wrk {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	sort fips year
	foreach var of varlist man_wrk {
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
	}
	foreach var of varlist man_wrk {
		by fips: egen ycl_`var'_2 = max(`var'_2)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
		}
		drop `var'_2 ycl_`var'_2
	}

	/*summarize outcome variable*/
	sum man_wrk [aweight=population_weight] if year==1930

	/*keep if year at least 1940*/
	keep if year>=1940
	
	/*create differences variable*/
	gen dman_wrk = man_wrk - ycl_man_wrk
	drop ycl_man_wrk
}

*run regression for column 3 of Table 4
areg dman_wrk m1_1_1940 m1_1_1950 m1_1_1959 m1_1_1969 m1_1_1978 m1_1_1987 m1_2_1940 m1_2_1950 m1_2_1959 m1_2_1969 m1_2_1978 m1_2_1987 control_* lcontrol_* ycl_* if balance_man_wrk == 7 [aweight=population_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t4_man_wrk) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append
	



*** Column 4, Unemployment Rate
qui{
	/*import data*/
	use preanalysis_1910.dta, clear

	/*create outcome variable and weights*/
	gen unemployment = unemployed/(unemployed+employed)
	gen labor_w = (employed+unemployed) if year==1930
	sort fips year
	by fips: egen labor_weight = max(labor_w)

	/*create grouped decade erosion variables*/
	foreach level in 1 2 {
		replace m1_`level'_1950 = m1_`level'_1945 if year==1945
		replace m1_`level'_1950 = m1_`level'_1954 if year==1954
		replace m1_`level'_1959 = m1_`level'_1959 if year==1959
		replace m1_`level'_1959 = m1_`level'_1964 if year==1964
		replace m1_`level'_1969 = m1_`level'_1969 if year==1969
		replace m1_`level'_1969 = m1_`level'_1974 if year==1974
		replace m1_`level'_1978 = m1_`level'_1978 if year==1978
		replace m1_`level'_1978 = m1_`level'_1982 if year==1982
		replace m1_`level'_1987 = m1_`level'_1987 if year==1987
		replace m1_`level'_1987 = m1_`level'_1992 if year==1992
	}
	
	/*create control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create lagged outcome variables*/
	sort fips year
	foreach var of varlist unemployment {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}

	/*list summary stats for unemployment in 1930*/
	sum unemployment if year == 1930 [aweight=population_weight]

	/*keep if year at least 1940*/
	keep if year>=1940
	
	/*create differences variable-- the dependent variable in the regressions*/
	gen dunemployment = unemployment - ycl_unemployment
	drop ycl_unemployment
}

*run regression to populate column 4 of Table 4
areg dunemployment m1_1_1940 m1_1_1950 m1_1_1959 m1_1_1969 m1_1_1978 m1_1_1987 m1_2_1940 m1_2_1950 m1_2_1959 m1_2_1969 m1_2_1978 m1_2_1987 control_* lcontrol_* ycl_* [aweight=population_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t4_unemployment) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append




*** Column 5, Log Retail sales per capita

*import data
use preanalysis_1910.dta, clear

qui{
	/*create grouped decade erosion variables*/
	foreach level in 1 2 {
		replace m1_`level'_1950 = m1_`level'_1945 if year==1945
		replace m1_`level'_1950 = m1_`level'_1954 if year==1954
		replace m1_`level'_1959 = m1_`level'_1959 if year==1959
		replace m1_`level'_1959 = m1_`level'_1964 if year==1964
		replace m1_`level'_1969 = m1_`level'_1969 if year==1969
		replace m1_`level'_1969 = m1_`level'_1974 if year==1974
		replace m1_`level'_1978 = m1_`level'_1978 if year==1978
		replace m1_`level'_1978 = m1_`level'_1982 if year==1982
		replace m1_`level'_1987 = m1_`level'_1987 if year==1987
		replace m1_`level'_1987 = m1_`level'_1992 if year==1992
	}
	
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a population_a cropland_f fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a population_a cropland_f fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create outcome variable*/
	gen ln_ret_out_p = ln(retail_sales/population)
	sort fips
	by fips: egen balance_ret_out_p = count(ln_ret_out_p)

	/*create lagged outcome variable*/
	sort fips year
	foreach var of varlist ln_ret_out_p {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}

	/*keep if 1940 or beyond*/
	keep if year>=1940

	/*create differences from 1930 (i.e. outcome variable in regression)*/
	gen dln_ret_out_p = ln_ret_out_p - ycl_ln_ret_out_p
	drop ycl_ln_ret_out_p
}

*run regression to populate column 5 of Table 4
areg dln_ret_out_p m1_1_1940 m1_1_1950 m1_1_1959 m1_1_1969 m1_1_1978 m1_1_1987 m1_2_1940 m1_2_1950 m1_2_1959 m1_2_1969 m1_2_1978 m1_2_1987 control_* lcontrol_* ycl_* if balance_ret_out_p == 6 [aweight=population_weight], absorb(id_stateyear) cluster(fips)
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t4_ln_ret_out_p) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append
	

	

******************************************************************************************************
***		Table 5: adjustment in areas with more/less banks, large farms, tenant, and pop density		**
***		Appendix Figure 2: Diffs in Log Banks by erosion level										**
******************************************************************************************************


*** Interaction with banks

/*import bank data*/
clear
insheet using bank.txt, tab

/*keep only county-level observations*/
keep if v1=="C"

/*rename variables*/
	/*id variables*/
	rename v5 name
	rename v3 state
	rename v212 county
	/*total deposits in county*/
	rename v8 deposits1920
	rename v9 deposits1921
	rename v10 deposits1922
	rename v11 deposits1923
	rename v12 deposits1924
	rename v13 deposits1925
	rename v14 deposits1926
	rename v15 deposits1927
	rename v16 deposits1928
	rename v17 deposits1929
	rename v18 deposits1930
	rename v19 deposits1931
	rename v20 deposits1932
	rename v21 deposits1933
	rename v22 deposits1934
	rename v23 deposits1935
	rename v24 deposits1936
	/*number of banks in county*/
	rename v42 banks1920
	rename v43 banks1921
	rename v44 banks1922
	rename v45 banks1923
	rename v46 banks1924
	rename v47 banks1925
	rename v48 banks1926
	rename v49 banks1927
	rename v50 banks1928
	rename v51 banks1929
	rename v52 banks1930
	rename v53 banks1931
	rename v54 banks1932
	rename v55 banks1933
	rename v56 banks1934
	rename v57 banks1935
	rename v58 banks1936
	/*drop unused variables*/
	drop v*

/*drop counties*/
drop if state==32 & county==1370 /*Ness, KS*/
drop if state==44 & county==1510 /*Jackson, GA*/
reshape long deposits banks, i(state county) j(year)

/*prepare for merge with ICPSR FIPS identifiers*/ 
sort state county
save `pre_merge_bank', replace

/*merge ICPSR FIPS onto banking data*/
use `pre_merge_bank', clear
merge m:1 state county using icpsr_fips.dta
keep if _merge==3
drop _merge
drop state county
sort fips
/*save for upcoming merge with pre-analysis dataset*/
save `pre_merge_bank2', replace

/*open pre-analysis dataset*/
use preanalysis_1910.dta, clear

qui{
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen lc_`var' = max(`var')
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*keep only 1930 observations*/
	keep if year==1930
}
	/*keep only the variables needed to prepare for merge with bank data*/
	keep fips m1_1_1930 m1_2_1930 farmland farmland_weight county_acres state c_* lc_*
	sort fips
	save `pre_merge_ICPSR_data', replace

/*merge with bank data*/
use `pre_merge_bank2', clear
merge m:1 fips using `pre_merge_ICPSR_data'
keep if _merge==3
drop _merge

/*create erosion variables*/
sort fips year
rename m1_1_1930 m1_1
rename m1_2_1930 m1_2
foreach year of numlist 1920(1)1936 {
	gen byte m1_1_`year' = 0
	replace m1_1_`year'=m1_1 if year==`year'
}
foreach year of numlist 1920(1)1936 {
gen byte m1_2_`year' = 0
replace m1_2_`year'=m1_2 if year==`year'
}

/*Generate state-by-year dummy variables*/
foreach state of numlist 8 19 20 27 30 31 35 38 40 46 48 {
	foreach year of numlist 1920(1)1936 {
		gen byte state_`state'Xyear_`year' = (year==`year'&state==`state')
	}
}

/*generate year-control interacted variables*/
foreach var of varlist c_* {
	foreach year of numlist 1920(1)1936 {
		gen nc_`var'_`year' = 0
		replace nc_`var'_`year' = `var' if year==`year'
	}
}

/*generate lagged control-year interacted variables*/
foreach var of varlist lc_* {
	foreach year of numlist 1920(1)1936 {
		gen nlc_`var'_`year' = 0
		replace nlc_`var'_`year' = `var' if year==`year'
	}
}

/*save dataset*/
save `bank_analysis', replace

/*create logs of outcome variables*/
foreach var of varlist deposits banks {
	gen ln`var' = ln(`var')
}

/*keep only those counties with a certain number of datapoints*/
sort fips
by fips: egen balance_deposits = count(lndeposits)
by fips: egen balance_banks = count(lnbanks)
keep if balance_deposits==17&balance_banks==17


/*Appendix Figure 2 data generation*/
foreach var of varlist deposits banks {
	reg ln`var' m1_1_1920-m1_1_1936 m1_2_1920-m1_2_1936 state_* nc_* nlc_*
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(app_f2_`var') noaster append
}


/*create dataset of 1928 bank data*/
use `bank_analysis', clear
keep if year==1928
keep fips banks
sort fips
save `pre_interaction_bank', replace

/*prepare ICPRS data*/
use preanalysis_1910.dta, clear
drop if year==1997

/*create control variables*/
sort fips year
foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
	gen `var'_1930 = `var' if year==1930
	by fips: egen c_`var' = max(`var'_1930)
	foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
		gen byte control_`var'_`year' = 0
		replace control_`var'_`year'=c_`var' if year==`year'
	}
	drop `var'_1930 c_`var'
}

/*create lagged control variables*/
sort fips year
foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
	by fips: gen `var'_1 = `var'[_n-1] if year==1930
	by fips: gen `var'_2 = `var'[_n-2] if year==1930
	by fips: gen `var'_3 = `var'[_n-3] if year==1930
}
foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3 cropland_f_1 population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3 corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
	by fips: egen cl_`var' = max(`var')
	foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
		gen byte lcontrol_`var'_`year' = 0
		replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
	}
	drop cl_`var' `var'
}
drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

/*save dataset*/
save `pre_interaction_ICPSR', replace


/*merge bank data with ICPSR data*/
	/*open ICPSR data*/
	use `pre_interaction_ICPSR', clear

	/*merge with FDIC bank data*/
	sort fips
	merge m:1 fips using `pre_interaction_bank'
	keep if _merge==3

	/*create outcome variables*/
	gen bnk_pre = ln(banks)
	gen tnt_pre = farmland_tenant/farmland if year==1930
	gen farm_pop_a = population_farm/farmland
	foreach var of varlist avsize farm_pop_a { 	
		gen `var'_1930_pre = .
		replace `var'_1930_pre = `var' if year==1930
		sort fips year
		by fips: egen `var'_1930 = max(`var'_1930_pre)
		drop `var'_1930_pre
	}

	/*shorten names*/
	rename avsize_1930 asz
	rename farm_pop_a_1930 fmp
	
	/*fill down*/
	sort fips
	foreach var of newlist bnk tnt {
		by fips: egen `var' = max(`var'_pre)
	}
	
	/*keep only those observations with bank data*/
	foreach var of varlist bnk tnt asz fmp {
		keep if `var'!=.
	}
	
	/*normalize so that each variable has mean = 0 and sd = 1*/
	foreach var of varlist bnk tnt asz fmp {
		egen mean_`var' = mean(`var')
		egen sd_`var' = sd(`var')
		replace `var' = ( `var' - mean_`var' )/sd_`var'
	}
	
	/*multiply the tenant and density variables by -1 to make the "less" rather than "more" variables*/
	replace tnt = tnt*-1
	replace fmp = fmp*-1
	
	/*create yearly bank and tenant variables*/
	foreach var of varlist bnk tnt asz fmp {
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte `var'_`year' = 0
			replace `var'_`year'=`var' if year==`year'
		}
		/*create bank and tenant interacted with medium erosion variables*/
		gen `var'_1 = `var'*m1_1
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte `var'_1_`year' = 0
			replace `var'_1_`year'=`var'_1 if year==`year'
		}
		/*create bank and tenant interacted with high erosion variables*/
		gen `var'_2 = `var'*m1_2
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte `var'_2_`year' = 0
			replace `var'_2_`year'=`var'_2 if year==`year'
		}
	}
	
	/*calculate share in wheat crops*/
	gen wshare = wheat_a/(wheat_a+hay_a)

	/*create weights*/
	gen hay_wheat = hay_a+wheat_a
	gen hay_wheat_w = hay_wheat if year==1930
	gen cp_w = (cropland+pasture) if year==1930
	sort fips
	by fips: egen hay_wheat_weight = max(hay_wheat_w)
	by fips: egen cp_weight = max(cp_w)

	/*create crop weights and keep if a certain amount of data*/
	gen crop_allocation = cropland/(pasture+cropland)
	replace wshare = . if year>1964
	replace crop_allocation = . if year>1964
	sort fips
	by fips: egen balance_ca = count(crop_allocation)
	by fips: egen balance_ws = count(wshare)
	keep if balance_ca==8&balance_ws==9

	/*create erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964
	
	/*create interacted erosion variables*/
	foreach var of varlist bnk tnt asz fmp {
		gen `var'_1950_1954 = 0
		replace `var'_1950_1954 = `var'_1950 if year==1950
		replace `var'_1950_1954 = `var'_1954 if year==1954
		gen `var'_1959_1964 = 0
		replace `var'_1959_1964 = `var'_1959 if year==1959
		replace `var'_1959_1964 = `var'_1964 if year==1964

		gen `var'_1_1950_1954 = 0
		replace `var'_1_1950_1954 = `var'_1_1950 if year==1950
		replace `var'_1_1950_1954 = `var'_1_1954 if year==1954
		gen `var'_1_1959_1964 = 0
		replace `var'_1_1959_1964 = `var'_1_1959 if year==1959
		replace `var'_1_1959_1964 = `var'_1_1964 if year==1964
		gen `var'_2_1950_1954 = 0
		replace `var'_2_1950_1954 = `var'_2_1950 if year==1950
		replace `var'_2_1950_1954 = `var'_2_1954 if year==1954
		gen `var'_2_1959_1964 = 0
		replace `var'_2_1959_1964 = `var'_2_1959 if year==1959
		replace `var'_2_1959_1964 = `var'_2_1964 if year==1964
	}

save `pre_regression_bank', replace


	
*** Crop_allocation (columns 1,3,5,7)

/*import data*/
use `pre_regression_bank', clear

qui{
	/*create control variables*/
	foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
		drop control_cropland_f_`year'
		drop lcontrol_cropland_f_1_`year'
	}

	/*create yearly cropland allocation variables*/
	sort fips year
	gen crop_allocation_1930 = crop_allocation if year==1930 /*create crop allocation 1930 variable*/
	by fips: egen ycl_crop_allocation = max(crop_allocation_1930) /*fill in non-1930 crop allocation with 1930 allocation*/
	foreach year of numlist 1940 1945 1950 1954 1959 1964 {
		gen byte ycl_crop_allocation_`year' = 0 /*create yearly cropland allocation variables*/
		replace ycl_crop_allocation_`year'=ycl_crop_allocation if year==`year' /*fill yearly cropland allocation variables with 1930 allocation*/
	}

	/*create lagged crop allocation variable*/
	foreach out of varlist crop_allocation {
		by fips: gen `out'_1 = `out'[_n-1] if year==1930
	}
	
	/*create yearly lagged crop allocation variable*/
	foreach out of varlist crop_allocation {
		by fips: egen ycl_`out'_1 = max(`out'_1)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 {
			gen byte ycl_`out'_1_`year' = 0
			replace ycl_`out'_1_`year'=ycl_`out'_1 if year==`year'&ycl_`out'_1!=.
		}
		drop `out'_1 ycl_`out'_1
	}

	/*interact outcome variables with crop allocation variables*/
	foreach var of varlist bnk tnt asz fmp {
		foreach out of varlist crop_allocation {
			foreach year of numlist 1940 1945 1950 1954 1959 1964 {
				gen `var'_ycl_`out'_`year'=ycl_`out'_`year'*`var'
				gen `var'_ycl_`out'_1_`year'=ycl_`out'_1_`year'*`var'
			}
		}
	}

	/*keep only if year is at least 1940*/
	keep if year>=1940
	
	/*generate differences outcome variable*/
	gen dcrop_allocation = crop_allocation - ycl_crop_allocation
	drop ycl_crop_allocation
}

	/*run regressions to generate output for columns 1,3,5,7 */
	foreach var of varlist bnk tnt asz fmp {
		areg dcrop_allocation m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 `var'_1940 `var'_1945 `var'_1950_1954 `var'_1959_1964 `var'_1_1940 `var'_1_1945 `var'_1_1950_1954 `var'_1_1959_1964 `var'_2_1940 `var'_2_1945 `var'_2_1950_1954 `var'_2_1959_1964 ycl_* `var'_ycl_* control_* lcontrol_* [aweight=cp_weight], absorb(id_stateyear) cluster(fips)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t5_`var'_crop) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Cropland + Pasture") 2aster append
	}


*** Wheat allocation (columns 3 and 6 of table 4)

/*import data*/
use `pre_regression_bank', clear

qui{
	/*drop unneeded control variables*/
	foreach var of varlist corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			drop control_`var'_`year'
		}
	}
	foreach var of newlist lcontrol_corn_a_c_1 lcontrol_wheat_a_c_1 lcontrol_hay_a_c_1 lcontrol_cotton_a_c_1 lcontrol_obr_a_c_1 lcontrol_cows_a_1 lcontrol_cows_a_2 lcontrol_cows_a_3 lcontrol_pigs_a_1 lcontrol_pigs_a_2 lcontrol_pigs_a_3 lcontrol_chickens_a_1 lcontrol_chickens_a_2 {
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			drop `var'_`year'
		}
	}

	/*create 1930 wheat allocation variable*/
	sort fips year
	gen wshare_1930 = wshare if year==1930
	by fips: egen ycl_wshare = max(wshare_1930)
	foreach year of numlist 1940 1945 1950 1954 1959 1964 {
		gen byte ycl_wshare_`year' = 0
		replace ycl_wshare_`year'=ycl_wshare if year==`year'
	}

	/*create lagged wheat share variables*/
	foreach out of varlist wshare {
		by fips: gen `out'_1 = `out'[_n-1] if year==1930
		by fips: gen `out'_2 = `out'[_n-2] if year==1930
		by fips: gen `out'_3 = `out'[_n-3] if year==1930
	}
	foreach out of varlist wshare {
		by fips: egen ycl_`out'_1 = max(`out'_1)
		by fips: egen ycl_`out'_2 = max(`out'_2)
		by fips: egen ycl_`out'_3 = max(`out'_3)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 {
			gen byte ycl_`out'_1_`year' = 0
			replace ycl_`out'_1_`year'=ycl_`out'_1 if year==`year'&ycl_`out'_1!=.
			gen byte ycl_`out'_2_`year' = 0
			replace ycl_`out'_2_`year'=ycl_`out'_2 if year==`year'&ycl_`out'_2!=.
			gen byte ycl_`out'_3_`year' = 0
			replace ycl_`out'_3_`year'=ycl_`out'_3 if year==`year'&ycl_`out'_3!=.
		}
		drop `out'_1 ycl_`out'_1 `out'_2 ycl_`out'_2 `out'_3 ycl_`out'_3
	}

	/*interact wheat share variables with outcomes*/
	foreach var of varlist bnk tnt asz fmp {
		foreach out of varlist wshare {
			foreach year of numlist 1940 1945 1950 1954 1959 1964 {
				gen `var'_ycl_`out'_`year'=ycl_`out'_`year'*`var'
				gen `var'_ycl_`out'_1_`year'=ycl_`out'_1_`year'*`var'
				gen `var'_ycl_`out'_2_`year'=ycl_`out'_1_`year'*`var'
				gen `var'_ycl_`out'_3_`year'=ycl_`out'_1_`year'*`var'
			}
		}
	}

	/*keep years 1940 and beyond*/
	keep if year>=1940
	
	/*generate differences outcome variable*/
	gen dwshare = wshare - ycl_wshare
	drop ycl_wshare
}
	
	/*run regressions to populate columns 2,4,6,8*/
	foreach var of varlist bnk tnt asz fmp {
		areg dwshare m1_1_1940 m1_1_1945 m1_1_1950_1954 m1_1_1959_1964 m1_2_1940 m1_2_1945 m1_2_1950_1954 m1_2_1959_1964 `var'_1940 `var'_1945 `var'_1950_1954 `var'_1959_1964 `var'_1_1940 `var'_1_1945 `var'_1_1950_1954 `var'_1_1959_1964 `var'_2_1940 `var'_2_1945 `var'_2_1950_1954 `var'_2_1959_1964 ycl_* `var'_ycl_* control_* lcontrol_* [aweight=hay_wheat_weight], absorb(id_stateyear) cluster(fips)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t5_`var'_wheat) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) addtext(wgt_var, "Wheat + Hay") 2aster append
	}


	
	
***************************************************************************
***		Table 6:  Estimated Differences in Government Program Payments	***
***************************************************************************

*import data
use preanalysis_1910.dta, clear

*** Panel A

qui{	
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1930 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1930 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*rename variables*/ 
	rename pcpubwor pubwor /*pubwor:  public works spending*/
	rename pcaaa aaa /*aaa: AAA spending*/
	rename pcrelief relief /*relief: relief spending*/
	rename pcndloan ndloan /*ndloan: new deal loans*/
	rename pcndins ndins /*ndins: value of loans guarenteed*/

	/*create per-acre of farmland*/
	foreach var of varlist  pubwor aaa relief ndloan ndins {
		gen `var'_f = `var'/farmland
	}
	foreach var of varlist aaa_f pubwor_f relief_f ndloan_f ndins_f {
		keep if `var'!=.
	}
	
}
/*conduct analyses*/
foreach var of varlist aaa_f pubwor_f relief_f ndloan_f ndins_f {
	/*create summary statistics for column 1*/
	sum `var' [aweight=farmland_weight]
	/*run regressions for columms 2 and 3*/
	areg `var' m1_1_1930 m1_2_1930 control_* lcontrol_* [aweight=farmland_weight], robust absorb(state)
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t6_col23_`var') addstat(n_fe_less_1, e(df_a)) 2aster append
	nlcom (col4: _b[m1_2_1930]-_b[m1_1_1930]), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t6_col4_`var') 2aster append
}

*** Panel B

/*import data*/
use preanalysis_1910.dta, clear

qui{
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1930 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1930 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create outcome variables*/
	gen government_allmoney_1992 = government_allmoney if year==1992
	gen government_crpmoney_1992 = government_crpmoney if year==1992
	
	/*make outcome variables a per-acre measurement*/
	foreach var of varlist government_allmoney_1992 government_crpmoney_1992 {
		gen `var'_f = `var'/farmland
	}
	
	/*fill down*/
	sort fips
	by fips: egen gov_allmoney_1992_f = max(government_allmoney_1992_f)
	by fips: egen gov_crpmoney_1992_f = max(government_crpmoney_1992_f)
	gen fraction_crp_1992 = gov_crpmoney_1992_f/gov_allmoney_1992_f
	keep if year==1930
	foreach var of varlist gov_allmoney_1992_f gov_crpmoney_1992_f fraction_crp_1992 {
		keep if `var'!=.
	}
}

/*conduct analyses*/
foreach var of varlist gov_allmoney_1992_f gov_crpmoney_1992_f fraction_crp_1992 {
	/*create summary statistics for column 1*/
	sum `var' [aweight=farmland_weight]
	/*run regressions for columns 2-3*/
	areg `var' m1_1_1930 m1_2_1930 control_* lcontrol_* [aweight=farmland_weight], robust absorb(state)
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t6_col23_`var') addstat(n_fe_less_1, e(df_a)) 2aster append
	/*calculate column 4*/
	nlcom (col4: _b[m1_2_1930]-_b[m1_1_1930]), post
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(t6_col4_`var') 2aster append
}	



***************************************************************************
***		Appendix Table 1: IV regressions 								***
***************************************************************************

/*merge with climate (i.e. drought) data*/
use migclim.dta, clear
rename ndmtcode county
sort state county
merge 1:1 state county using icpsr_fips.dta
keep if _merge==3
drop _merge
sort fips
save `climateiv', replace

/*merge with preanalysis data*/
use preanalysis_1910.dta, clear
merge fips using `climateiv'
keep if _merge==3
drop _merge
drop if year==1997

qui{
	/*create control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1940 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}	
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1940 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create lagged outcome variables*/
	sort fips year
	foreach var of varlist value_landbuildings_f value_revenue_f {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	sort fips year
	foreach var of varlist value_landbuildings_f value_revenue_f {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist value_landbuildings_f value_revenue_f {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		by fips: egen ycl_`var'_2 = max(`var'_2)
		by fips: egen ycl_`var'_3 = max(`var'_3)
		foreach year of numlist 1940 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
			gen byte ycl_`var'_2_`year' = 0
			replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
			gen byte ycl_`var'_3_`year' = 0
			replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
		}
		drop `var'_1 `var'_2 `var'_3 ycl_`var'_1 ycl_`var'_2 ycl_`var'_3
	}

	/*keep if year at least 1940*/
	keep if year==1940
}
	
/*create state variable*/
tab state, gen(d_state)

/*create differences (i.e. dependent) variable*/
gen dvalue_landbuildings_f = value_landbuildings_f - ycl_value_landbuildings_f
drop ycl_value_landbuildings_f

/*First-stage*/
	/*medium erosion*/
	reg m1_1_1940 mdsxd30s mdssd30s mdsmd30s pdsiav30 tmpav30 tmpsd30 mdsxd92 mdssd92 mdsmd92 pdsiav92 tmpsd92 tmpav92 d_state* control_* lcontrol_* ycl_* [aweight=farmland_weight], noc robust
	/*F-test*/
	test mdsxd30s mdssd30s mdsmd30s pdsiav30 tmpsd30 tmpav30
	outreg2 using Analysis_DustBowl.xls, dec(4) ctitle(app_t1_fs_med) addstat(F_test, e(F)) 2aster append

	/*high erosion*/
	reg m1_2_1940 mdsxd30s mdssd30s mdsmd30s pdsiav30 tmpav30 tmpsd30 mdsxd92 mdssd92 mdsmd92 pdsiav92 tmpsd92 tmpav92 d_state* control_* lcontrol_* ycl_* [aweight=farmland_weight], noc robust
	/*F-test*/
	test mdsxd30s mdssd30s mdsmd30s pdsiav30 tmpsd30 tmpav30
	outreg2 using Analysis_DustBowl.xls, dec(4) ctitle(app_t1_fs_high) addstat(F_test, e(F)) 2aster append

/*IV*/
ivregress 2sls dvalue_landbuildings_f d_state* control_* lcontrol_* ycl_* mdsxd92 mdssd92 mdsmd92 pdsiav92 tmpav92 tmpsd92 (m1_1_1940 m1_2_1940 = mdsxd30s mdssd30s mdsmd30s pdsiav30 tmpsd30 tmpav30) [aweight=farmland_weight], robust
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(app_t1_2sls) 2aster append

/*OLS*/
reg dvalue_landbuildings_f m1_1_1940 m1_2_1940 d_state* control_* lcontrol_* ycl_* mdsxd92 mdssd92 mdsmd92 pdsiav92 tmpav92 tmpsd92 [aweight=farmland_weight], robust
outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(app_t1_ols) 2aster append



**********************************************************************************
*** 	Appendix Figure 1													******
**********************************************************************************

	/*import data*/
	use DustBowl_All_base1910.dta, clear
	
	sort fips
	merge m:1 fips using `db_sample'
	replace db_sample = 0 if db_sample ==.
	
qui{
	/*calculate value of all farmland in the US and in the sample*/
	/*All of US*/
		egen tot_value_landbuildings_US = sum(value_landbuildings) if year==1930 /*calculate total value of farmland*/
		egen tot_value_landbuildings_US_1930 = max(tot_value_landbuildings_US)/*calculate total farmland value*/
		reg tot_value_landbuildings_US_1930 /*output total*/
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(tot_value_landbuildings_US_1930) noaster append
	/*just sample*/
		egen tot_value_landbuildings_DB = sum(value_landbuildings) if db_sample==1 & year==1930 /*calculate total value of farmland*/
		egen tot_value_landbuildings_DB_1930 = max(tot_value_landbuildings_DB)/*calculate total farmland value*/
		reg tot_value_landbuildings_DB_1930 /*output total*/
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(tot_value_landbuildings_DB_1930) noaster append
		
		
	/*drop years without data in other states*/
	drop if year==1935|year==1925

	/*fill in missing county acres*/
	sort fips year
	by fips: replace county_acres = county_acres[_n+1] if county_acres==.
	by fips: replace county_acres = county_acres[_n+1] if county_acres==.
	by fips: replace county_acres = county_acres[_n-1] if county_acres==.
	
	/*create state-year ids*/
	gen double id_stateyear = state*10000+year

	/*create year interacted with erosion variables*/
	foreach year of numlist 1910 1920 1930 1940 1945 1950 1954 1959 1964 1969 1978 1982 1987 1992 {
		gen byte m1_1_`year' = 0
		replace m1_1_`year'=m1_1 if year==`year'
	}
	foreach year of numlist 1910 1920 1930 1940 1945 1950 1954 1959 1964 1969 1978 1982 1987 1992 {
		gen byte m1_2_`year' = 0
		replace m1_2_`year'=m1_2 if year==`year'
	}

	/*create outcome variables*/
		/*value of all land and buildings*/
		gen value_landbuildings_f = ln(value_landbuildings/farmland)
		replace value_landbuildings_f = . if value_landbuildings_f<-1
		replace value_landbuildings_f = . if farmland<1000
		replace value_landbuildings_f = . if year==1974
		sort fips
		by fips: egen balance_value_landbuildings_f= count(value_landbuildings_f)
		drop if balance_value_landbuildings_f!=14

	/*generate weights*/
	gen farmland_w = farmland if year==1930
	sort fips year
	by fips: egen farmland_weight = max(farmland_w)
	drop farmland_w
	
	gen db_state = 0
	replace db_state = 1 if state==8|state==19|state==20|state==27|state==30|state==31|state==35|state==38|state==40|state==46|state==48|state==56
}	

/*run regressions */
	/*non-DB state counties*/
	areg value_landbuildings_f m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_weight] if db_state==0, absorb(id_stateyear)
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(app_f1_nonDBstates) noaster append
	/*DB sample counties*/
	areg value_landbuildings_f m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_weight] if db_sample==1&db_state==1, absorb(id_stateyear)
	outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(app_f1_sample) noaster append
		


*************************************************************************
*************************************************************************
***		Calculations Reported in Text								*****
*************************************************************************
*************************************************************************

*open dataset
use `pre_interaction_ICPSR', clear

*** Interaction with tenant share in farmland

	/*share of farmland that is tenant (and non-tenant)*/
	gen tenant_fshare = farmland_tenant/farmland
	gen farmland_nontenant = farmland - farmland_tenant

	/*share of tenant farmland that's cropland*/
	gen tenant_cropland = cropland_harvested_tenant/farmland_tenant
	gen nontenant_cropland = (cropland_harvested - cropland_harvested_tenant)/farmland_nontenant

	/*log of share of value per acre of tenant land*/
	gen tenant_value = ln(value_landbuildings_tenant/farmland_tenant)
	gen nontenant_value = ln((value_landbuildings - value_landbuildings_tenant) / farmland_nontenant)

	/*log of equipment per acre value of tenant land*/
	gen tenant_evalue = ln(equipment_tenant/farmland_tenant)
	gen nontenant_evalue = ln((equipment - equipment_tenant) / farmland_nontenant)

	/*keep only those counties with a certain amount of data*/
	sort fips
	foreach var of varlist tenant_fshare tenant_cropland nontenant_cropland tenant_value nontenant_value tenant_evalue nontenant_evalue {
		by fips: egen b_`var'= count(`var')
		tab b_`var'
	}
	keep if b_tenant_fshare==13
	keep if b_tenant_cropland==3
	keep if b_nontenant_cropland==3
	keep if b_tenant_value==4
	keep if b_nontenant_value==4
	keep if b_tenant_evalue==2
	keep if b_nontenant_evalue==2

	/*Generate weights*/
	foreach var of varlist farmland_tenant farmland_nontenant {
		gen `var'_w = `var' if year==1930
		sort fips year
		by fips: egen `var'_weight = max(`var'_w)
		drop `var'_w
	}

	
	/*For text*/
		/*tenant farmland share*/
		areg tenant_fshare m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(10) ctitle(AppFig2B_tenant_fshare) noaster append
	
		/*tenant share on erosion - no controls*/
		areg tenant_fshare m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_fshare_no_c) 2aster append

		/*tenant cropland on erosion-- no controls*/
		areg tenant_cropland m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_tenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_cropland_no_c) 2aster append
	
		/*tenant cropland on erosion -- with controls*/
		areg tenant_cropland m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_tenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_cropland_c) 2aster append
			
		/*non-tenant cropland -- no controls*/
		areg nontenant_cropland m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_nontenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_nontenant_cropland_no_c) 2aster append
	
		/*non-tenant cropland -- with controls*/
		areg nontenant_cropland m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_nontenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_cropland_c) 2aster append

		/*tenant value -- no controls*/
		areg tenant_value m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_tenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_value_no_c) 2aster append

		/*tenant value -- with controls*/
		areg tenant_value m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_tenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_value_c) 2aster append

		/*non-tenant value -- no controls*/
		areg nontenant_value m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_nontenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_nontenant_value_no_c) 2aster append

		/*non-tenant value -- with controls*/		
		areg nontenant_value m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_nontenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_nontenant_value_c) 2aster append

		/*tenant equipment value -- no controls*/			
		areg tenant_evalue m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_tenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_evalue_no_c) 2aster append		
			
		/*tenant equipment value -- with controls*/
		areg tenant_evalue m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_tenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_tenant_evalue_c) 2aster append
			
		/*non-tenant equipment value -- no controls*/
		areg nontenant_evalue m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 [aweight=farmland_nontenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_nontenant_evalue_no_c) 2aster append
	
		/*non-tenant equipment value -- with controls*/
		areg nontenant_evalue m1_1_1910-m1_1_1992 m1_2_1910-m1_2_1992 control_* lcontrol_* [aweight=farmland_nontenant_weight], absorb(id_stateyear)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_nontenant_evalue_c) 2aster append


*** Check state changes in population
	
	/*import data*/
	use preanalysis_1910, clear
	
	/*create population for each state-year*/
	gen double state_year = state*10000+year
	collapse year state (sum) population, by(state_year)
	
	/*drop non Census years, which have no population data*/
	drop if population==0

	/*calculate log population*/
	gen lnpopulation = ln(population)

	/*create state name variable*/
	gen sname = "Colorado" if state==8
	replace sname = "Iowa" if state==19
	replace sname = "Kansas" if state==20
	replace sname = "Minnesota" if state==27
	replace sname = "Montana" if state==30
	replace sname = "Nebraska" if state==31
	replace sname = "New Mexico" if state==35
	replace sname = "North Dakota" if state==38
	replace sname = "Oklahoma" if state==40
	replace sname = "South Dakota" if state==46
	replace sname = "Texas" if state==48
	replace sname = "Wyoming" if state==56

	/*create differences in log population*/	
	sort state year
	by state: gen pop_diff = lnpopulation - lnpopulation[_n-1]
	
	/*keep if year is 1940*/
	keep if year==1940
	list sname pop_diff


******************************************************************************
*** Additional outcomes to test using equation (1) in the text				**
***	1. value of capital machinery and equipment (footnote 34)				**
***	2. capital-labor ratio (footnote 49)									**
******************************************************************************
	

*** 1. value of capital machinery and equipment (footnote 35)

	/*import data*/
	use preanalysis_1910.dta, clear
	drop if year==1997
	
	/*generate outcome variable - not for 1978*/
	replace equipment = . if year==1978
	gen lnequip_f = ln(equipment/farmland)
	
	/*create erosion variables*/
	gen m1_1_1950_1954 = 0
	replace m1_1_1950_1954 = m1_1_1950 if year==1950
	replace m1_1_1950_1954 = m1_1_1954 if year==1954
	gen m1_1_1959_1964 = 0
	replace m1_1_1959_1964 = m1_1_1959 if year==1959
	replace m1_1_1959_1964 = m1_1_1964 if year==1964
	gen m1_1_1969_1974 = 0
	replace m1_1_1969_1974 = m1_1_1969 if year==1969
	replace m1_1_1969_1974 = m1_1_1974 if year==1974
	gen m1_1_1978_1992 = 0
	replace m1_1_1978_1992 = m1_1_1978 if year==1978
	replace m1_1_1978_1992 = m1_1_1982 if year==1982
	replace m1_1_1978_1992 = m1_1_1987 if year==1987
	replace m1_1_1978_1992 = m1_1_1992 if year==1992
	gen m1_2_1950_1954 = 0
	replace m1_2_1950_1954 = m1_2_1950 if year==1950
	replace m1_2_1950_1954 = m1_2_1954 if year==1954
	gen m1_2_1959_1964 = 0
	replace m1_2_1959_1964 = m1_2_1959 if year==1959
	replace m1_2_1959_1964 = m1_2_1964 if year==1964
	gen m1_2_1969_1974 = 0
	replace m1_2_1969_1974 = m1_2_1969 if year==1969
	replace m1_2_1969_1974 = m1_2_1974 if year==1974
	gen m1_2_1978_1992 = 0
	replace m1_2_1978_1992 = m1_2_1978 if year==1978
	replace m1_2_1978_1992 = m1_2_1982 if year==1982
	replace m1_2_1978_1992 = m1_2_1987 if year==1987
	replace m1_2_1978_1992 = m1_2_1992 if year==1992
	
	/*create control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}
	
	/*create lagged control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3 fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop 	cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3
	
	/*create lagged outcome variables*/
	sort fips year
	foreach var of varlist lnequip_f {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}
	sort fips year
	foreach var of varlist lnequip_f {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
	}
	foreach var of varlist lnequip_f {
		by fips: egen ycl_`var'_1 = max(`var'_1)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 {
			gen byte ycl_`var'_1_`year' = 0
			replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
		}
		drop `var'_1 ycl_`var'_1
	}

	
	/*keep if year is at least 1940*/
	keep if year>=1940
	
	/*create differences (i.e. dependent variable)*/
	gen dlnequip_f = lnequip_f - ycl_lnequip_f
	drop ycl_lnequip_f
		
	/*run regression to estimate changes in ag equipment*/
	areg dlnequip_f m1_1_1940-m1_1_1992 m1_2_1940-m1_2_1992 control_* lcontrol_* ycl_* [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_eq1_cap_equip) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append

		
*** 2. Labor-Capital Ratio (footnote 50)
	
	/*import data*/
	use preanalysis_1910.dta, clear

	/*create outcome variable*/
	replace equipment = . if year==1978
	gen lnlabor_capital = ln(population_farm/equipment)

	/*create control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		gen `var'_1930 = `var' if year==1930
		by fips: egen c_`var' = max(`var'_1930)
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte control_`var'_`year' = 0
			replace control_`var'_`year'=c_`var' if year==`year'
		}
		drop `var'_1930 c_`var'
	}

	/*create lagged control variables*/
	sort fips year
	foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
		by fips: gen `var'_1 = `var'[_n-1] if year==1930
		by fips: gen `var'_2 = `var'[_n-2] if year==1930
		by fips: gen `var'_3 = `var'[_n-3] if year==1930
	}
	foreach var of varlist 	farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1 cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
		by fips: egen cl_`var' = max(`var')
		foreach year of numlist 1910 1920 1925 1930 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte lcontrol_`var'_`year' = 0
			replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
		}
		drop cl_`var' `var'
	}
	drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

	/*create lagged outcome variables*/			
	sort fips year
	foreach var of varlist lnlabor_capital {
		gen `var'_1930 = `var' if year==1930
		by fips: egen ycl_`var' = max(`var'_1930)
		foreach year of numlist 1940 1945 1950 1954 1959 1964 1969 1974 1978 1982 1987 1992 1997 {
			gen byte ycl_`var'_`year' = 0
			replace ycl_`var'_`year'=ycl_`var' if year==`year'
		}
		drop `var'_1930
	}

	/*keep if year is at least 1940*/
	keep if year>=1940
	
	/*generate differences (i.e. dependent variables)*/
	gen dlnlabor_capital = lnlabor_capital - ycl_lnlabor_capital
	drop ycl_lnlabor_capital

	/*run regressions for text*/
	areg dlnlabor_capital m1_1_1910-m1_1_1997 m1_2_1910-m1_2_1997 control_* lcontrol_* ycl_* [aweight=farmland_weight], absorb(id_stateyear) cluster(fips)
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_eq1_cap_labor) addstat(n_clust, e(N_clust), n_fe_less_1, e(df_a)) 2aster append
			
	
******************************************************************************
*** Calculate Conley standard errors on 1930-1940 land value changes		**
******************************************************************************

/*import data*/
use preanalysis_1910.dta, clear

/*create control variables*/
sort fips year
foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
	gen `var'_1930 = `var' if year==1930
	by fips: egen c_`var' = max(`var'_1930)
	foreach year of numlist 1940 {
		gen byte control_`var'_`year' = 0
		replace control_`var'_`year'=c_`var' if year==`year'
	}
	drop `var'_1930 c_`var'
}
	
/*create lagged control variables*/
sort fips year
foreach var of varlist 	farmland_a cropland_f population_a fraction_rural fraction_farm farms_a avsize corn_a_c wheat_a_c hay_a_c cotton_a_c obr_a_c cows_a pigs_a chickens_a {
	by fips: gen `var'_1 = `var'[_n-1] if year==1930
	by fips: gen `var'_2 = `var'[_n-2] if year==1930
	by fips: gen `var'_3 = `var'[_n-3] if year==1930
}
foreach var of varlist farmland_a_1 farmland_a_2 farmland_a_3  cropland_f_1  population_a_2 population_a_3  fraction_rural_2 fraction_rural_3 farms_a_1 farms_a_2 farms_a_3 avsize_1 avsize_2 avsize_3  corn_a_c_1 wheat_a_c_1 hay_a_c_1 cotton_a_c_1 obr_a_c_1 cows_a_1  cows_a_2 cows_a_3 pigs_a_1 pigs_a_2 pigs_a_3 chickens_a_1 chickens_a_2 {
	by fips: egen cl_`var' = max(`var')
	foreach year of numlist 1940 {
		gen byte lcontrol_`var'_`year' = 0
		replace lcontrol_`var'_`year'=cl_`var' if year==`year'&cl_`var'!=.
	}
	drop cl_`var'
}
drop cropland_f_2 cropland_f_3 population_a_1 fraction_rural_1 fraction_farm_1 fraction_farm_2 fraction_farm_3 corn_a_c_2 corn_a_c_3 wheat_a_c_2 wheat_a_c_3 hay_a_c_2 hay_a_c_3 cotton_a_c_2 cotton_a_c_3 obr_a_c_2 obr_a_c_3 chickens_a_3

/*create lagged outcome variables*/
sort fips year
foreach var of varlist value_landbuildings_f value_revenue_f {
	gen `var'_1930 = `var' if year==1930
	by fips: egen ycl_`var' = max(`var'_1930)
	foreach year of numlist 1940 {
		gen byte ycl_`var'_`year' = 0
		replace ycl_`var'_`year'=ycl_`var' if year==`year'
	}
	drop `var'_1930
}
sort fips year
foreach var of varlist value_landbuildings_f value_revenue_f {
	by fips: gen `var'_1 = `var'[_n-1] if year==1930
	by fips: gen `var'_2 = `var'[_n-2] if year==1930
	by fips: gen `var'_3 = `var'[_n-3] if year==1930
}
foreach var of varlist value_landbuildings_f value_revenue_f {
	by fips: egen ycl_`var'_1 = max(`var'_1)
	by fips: egen ycl_`var'_2 = max(`var'_2)
	by fips: egen ycl_`var'_3 = max(`var'_3)
	foreach year of numlist 1940 {
		gen byte ycl_`var'_1_`year' = 0
		replace ycl_`var'_1_`year'=ycl_`var'_1 if year==`year'
		gen byte ycl_`var'_2_`year' = 0
		replace ycl_`var'_2_`year'=ycl_`var'_2 if year==`year'
		gen byte ycl_`var'_3_`year' = 0
		replace ycl_`var'_3_`year'=ycl_`var'_3 if year==`year'
	}
	drop `var'_1 `var'_2 `var'_3 ycl_`var'_1 ycl_`var'_2 ycl_`var'_3
}
	
/*keep if year is 1940*/
keep if year==1940
	
/*generate differences (i.e. dependent variable)*/
gen dvalue_landbuildings_f = value_landbuildings_f - ycl_value_landbuildings_f
drop ycl_value_landbuildings_f ycl_value_revenue_f

tab id_stateyear, gen(d_year_state)
		
	/*regress changes in landvalues on erosion and controls*/
	/*cluster se at fips level*/
	reg dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state* [aweight=farmland_weight], noc cluster(fips)
	outreg2 using Analysis_DustBowl.xls, dec(3) addstat(n_clust, e(N_clust)) ctitle(text_conn_se_cluster_fips) 2aster append
	/*no clustered se*/
	reg dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state* [aweight=farmland_weight], noc robust
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_se_no_cluster) 2aster append
	/*no weight, no cluster*/
	reg dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, noc robust
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_se_no_w_no_c) 2aster append
	/*no weight, no cluster, no robust se (Normal linear model - nlm)*/
	reg dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, noc
	outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_se_nlm) 2aster append

	replace x_centroid = (x_centroid+3000000)/1609.344
	rename x_centroid xaxis
	replace y_centroid = (y_centroid+2000000)/1609.344
	rename y_centroid yaxis

	/*run regressions using Conley's .ado package*/
		/*cutoff of 50 miles*/
		clear matrix
		gen cutoff1=50
		gen cutoff2=50
		x_ols xaxis yaxis cutoff1 cutoff2 dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, xreg(64) coord(2)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_50) 2aster append
		drop cutoff1 cutoff2 epsilon window dis1 dis2
		/*cutoff of 100 miles*/
		clear matrix
		gen cutoff1=100
		gen cutoff2=100
		x_ols xaxis yaxis cutoff1 cutoff2 dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, xreg(64) coord(2)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_100) 2aster append
		drop cutoff1 cutoff2 epsilon window dis1 dis2

		/*cutoff of 300 miles*/
		clear matrix
		gen cutoff1=300
		gen cutoff2=300
		x_ols xaxis yaxis cutoff1 cutoff2 dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, xreg(64) coord(2)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_300) 2aster append
		drop cutoff1 cutoff2 epsilon window dis1 dis2

		/*cutoff of 500 miles*/
		clear matrix
		gen cutoff1=500
		gen cutoff2=500
		x_ols xaxis yaxis cutoff1 cutoff2 dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, xreg(64) coord(2)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_500) 2aster append
		drop cutoff1 cutoff2 epsilon window dis1 dis2

		/*cutoff of 700 miles*/
		clear matrix
		gen cutoff1=700
		gen cutoff2=700
		x_ols xaxis yaxis cutoff1 cutoff2 dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, xreg(64) coord(2)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_700) 2aster append
		drop cutoff1 cutoff2 epsilon window dis1 dis2

		/*cutoff of 900 miles*/
		clear matrix
		gen cutoff1=900
		gen cutoff2=900
		x_ols xaxis yaxis cutoff1 cutoff2 dvalue_landbuildings_f m1_1_1940 m1_2_1940 control_* lcontrol_* ycl_* d_year_state*, xreg(64) coord(2)
		outreg2 using Analysis_DustBowl.xls, dec(3) ctitle(text_conn_900) 2aster append
		
		
log close
