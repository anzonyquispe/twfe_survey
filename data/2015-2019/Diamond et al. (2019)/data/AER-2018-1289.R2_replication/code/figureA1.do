version 15.0
clear all
set more off
set scheme s1color
set matsize 1000

********************
* Appendix Figure 1
********************

prog main

	use if is_owner==0 using "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear

	//main regresion sample
	global base_sample_treat yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990  & treat==1
	global base_sample_control yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & treat==0
	keep if ($base_sample_treat | $base_sample_control) & (use_code_treat==3)
	keep if age_in1993>=20 & age_in1993<=65

	//merge in racial classification
	merge m:1 id using "data/impute_race/renter_proxied_final_robust", assert(2 3) keep(3) keepus(race) nogen

	rename zip_treat zipcode
	drop zip_year
	egen zip_year=group(zipcode year)

	//dummy for minority
	gen minority = (race~=1) & ~mi(race)

	keep if ~mi(race)

	gen treat_post_race = treat*post*race
	gen treat_post_minority = treat*post*minority

	//value labels
	label define TREAT_POST_RACE 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian"
	label values treat_post_race TREAT_POST_RACE

	label define TREAT_POST_MINORITY 0 "White" 1 "Minority"
	label values treat_post_minority TREAT_POST_MINORITY

	label define TREAT_POST 1 "White"
	label values treat_post TREAT_POST

	reg_did same_parcel, xtitle(Same Address)
	reg_did insf, xtitle(In SF)

end

prog reg_did
	syntax varname, xtitle(str)

	matrix B = J(5,3,.)
	matrix colnames B = b lb90 ub90
	matrix rownames B = "White" "Black" "Hispanic" "Asian" "Minorities"

	reghdfe `varlist' io0.treat_post io0b1.treat_post_race, absorb(i.year#i.yrs_at_curr93#i.race i.zip_year#i.race id) vce(cluster id)

	//baseline: white
	loc lb _b[1.treat_post]-invttail(e(df_r),0.05)*_se[1.treat_post]
	loc ub _b[1.treat_post]+invttail(e(df_r),0.05)*_se[1.treat_post]
	matrix B[1,1] = _b[1.treat_post], `lb', `ub'

	//differential effect: black
	loc lb _b[2.treat_post_race]-invttail(e(df_r),0.05)*_se[2.treat_post_race]
	loc ub _b[2.treat_post_race]+invttail(e(df_r),0.05)*_se[2.treat_post_race]
	matrix B[2,1] = _b[2.treat_post_race], `lb', `ub'

	//differential effect: hispanic
	loc lb _b[3.treat_post_race]-invttail(e(df_r),0.05)*_se[3.treat_post_race]
	loc ub _b[3.treat_post_race]+invttail(e(df_r),0.05)*_se[3.treat_post_race]
	matrix B[3,1] = _b[3.treat_post_race], `lb', `ub'

	//differential effect: Asian
	loc lb _b[4.treat_post_race]-invttail(e(df_r),0.05)*_se[4.treat_post_race]
	loc ub _b[4.treat_post_race]+invttail(e(df_r),0.05)*_se[4.treat_post_race]
	matrix B[4,1] = _b[4.treat_post_race], `lb', `ub'

	reghdfe `varlist' io0.treat_post io0.treat_post_minority, absorb(i.year#i.yrs_at_curr93#i.minority i.zip_year#i.minority id) vce(cluster id)

	//differential effect: minorities
	loc lb _b[1.treat_post_minority]-invttail(e(df_r),0.05)*_se[1.treat_post_minority]
	loc ub _b[1.treat_post_minority]+invttail(e(df_r),0.05)*_se[1.treat_post_minority]
	matrix B[5,1] = _b[1.treat_post_minority], `lb', `ub'

	coefplot matrix(B[,1]), ci((B[,2] B[,3])) ciopts( lcolor(navy*0.8)) mlcolor(navy*0.8) mfcolor(navy*.6) ///
		mlabel format(%9.2g) mlabposition(12) mlabgap(*2) mlabcolor(navy*0.8) ///
		ylabel(1 "White" 2 "Differential Effect: Black" 3 "Differential Effect: Hispanic" 4 "Differential Effect: Asian" 5 "Differential Effect: Minorities", labsize(small)) ///
		xline(0, lstyle(grid)) xtitle("`xtitle'")
	graph export "output/did_`varlist'_renter_race_hetero_robust.pdf", replace
	matrix drop B

end

main
