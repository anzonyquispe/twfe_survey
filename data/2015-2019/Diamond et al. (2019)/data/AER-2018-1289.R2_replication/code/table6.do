version 14.0
clear all
set more off
set scheme s1color
set matsize 1000

*================
* Table 6
* Figure A2 & A3
*================

prog main

	use if is_owner==0 using "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear

	global base_sample_treat yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990  & treat==1
	global base_sample_control yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & treat==0
	keep if ($base_sample_treat | $base_sample_control) & (use_code_treat==3)
	keep if age_in1993>=20 & age_in1993<=65
		
	rename zip_treat zipcode
	merge m:1 zipcode year using "data/sf_rent/ziprents_imputed.dta"
	drop if _merge==2
	drop _merge

	drop zip_year
	egen zip_year=group(zipcode year)
	egen high_rent=max((rent_hat_ind>.736)*(year==2000)), by(zipcode)
	egen tag_year_treat=tag(treat year) if lnsf_rent~=.	
		
	eststo clear
	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93<=3 & high_rent==1  & age_in1993>=40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est1) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93<=3 & high_rent==1 & age_in1993>=40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta1=_b[1.treat_post]
	glo se1=_se[1.treat_post]

	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93<=3 & high_rent==1  & age_in1993<40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est2) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93<=3 & high_rent==1 & age_in1993<40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta2=_b[1.treat_post]
	glo se2=_se[1.treat_post]

	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93<=3 & high_rent==0  & age_in1993>=40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est3) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93<=3 & high_rent==0 & age_in1993>=40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta3=_b[1.treat_post]
	glo se3=_se[1.treat_post]
	
	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93<=3 & high_rent==0  & age_in1993<40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est4) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93<=3 & high_rent==0 & age_in1993<40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta4=_b[1.treat_post]
	glo se4=_se[1.treat_post]

	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93>3 & high_rent==1  & age_in1993>=40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est5) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93>3 & high_rent==1 & age_in1993>=40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta5=_b[1.treat_post]
	glo se5=_se[1.treat_post]
	
	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93>3 & high_rent==1  & age_in1993<40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est6) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93>3 & high_rent==1 & age_in1993<40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta6=_b[1.treat_post]
	glo se6=_se[1.treat_post]

	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93>3 & high_rent==0  & age_in1993>=40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est7) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93>3 & high_rent==0 & age_in1993>=40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta7=_b[1.treat_post]
	glo se7=_se[1.treat_post]
	
	eststo: reghdfe same_parcel io0b1993.treat_year if yrs_at_curr93>3 & high_rent==0  & age_in1993<40, absorb(id zip_year i.year##i.yrs_at_curr93) vce(cluster id)
	save_coefmat, coefmat(est8) baselevelpos(4)
	reghdfe same_parcel io0.treat_post if yrs_at_curr93>3 & high_rent==0 & age_in1993<40, absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster id)
	glo beta8=_b[1.treat_post]
	glo se8=_se[1.treat_post]

	plot_coef, ytitle(Same Address) yout(sameaddress) ymax(0.2) ymin(-0.25) ystep(0.1)
	matrix drop est1 est2 est3 est4 est5 est6 est7 est8
	macro drop beta1 beta2 beta3 beta4 beta5 beta6 beta7 beta8
	macro drop se1 se2 se3 se4 se5 se6 se7 se8
end

prog save_coefmat
	syntax, coefmat(str) baselevelpos(str)
	matrix V = e(V)
	matrix B = e(b)

	matrix se = J(1, `=colsof(B)', 0)
	forvalues i = 1(1)`=colsof(B)'{ 
		mat se[1, `i'] = cond(~mi(sqrt(V[`i', `i'])), sqrt(V[`i', `i']), 0)
	}
	matrix lb = J(1, `=colsof(B)', 0)
	matrix ub = J(1, `=colsof(B)', 0)

	* 90% CI
	forvalues i = 1(1)`=colsof(B)' {
		matrix lb[1, `i'] = B[1, `i'] - invttail(e(df_r),0.05) * se[1, `i']
		matrix ub[1, `i'] = B[1, `i'] + invttail(e(df_r),0.05) * se[1, `i']
	}

	matrix B  = [B, 0]
	matrix lb = [lb, 0]
	matrix ub = [ub, 0]

	forvalues i = `=colsof(B)'(-1)`baselevelpos' {
		local j = `i' - 1
		if `i' == `baselevelpos' {
			matrix B[1, `i'] = 0
			matrix lb[1, `i'] = 0
			matrix ub[1, `i'] = 0
		}
		else {
			matrix B[1, `i']  = B[1, `j']
			matrix lb[1, `i'] = lb[1, `j']
			matrix ub[1, `i'] = ub[1, `j']
		}
	}

	matrix `coefmat' = [B', lb', ub']
	loc rownames 1990.treat_year 
	forval yr = 1991/2016 {
		loc rownames `rownames' `yr'.treat_year
	}
	matrix rownames `coefmat' = `rownames'
	matrix drop V B se lb ub
end
	
prog plot_coef
	syntax, ytitle(str) yout(str) ymax(str) ymin(str) ystep(str)
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_highturnover_highrent_old_`yout'.pdf", replace
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta2,"%4.3f")' (`=string($se2,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_highturnover_highrent_young_`yout'.pdf", replace
	
	coefplot (matrix(est3[,1]), ci((est3[,2] est3[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta3,"%4.3f")' (`=string($se3,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_highturnover_lowrent_old_`yout'.pdf", replace
	
	coefplot (matrix(est4[,1]), ci((est4[,2] est4[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta4,"%4.3f")' (`=string($se4,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_highturnover_lowrent_young_`yout'.pdf", replace
	
	coefplot (matrix(est5[,1]), ci((est5[,2] est5[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta5,"%4.3f")' (`=string($se5,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_lowturnover_highrent_old_`yout'.pdf", replace
	
	coefplot (matrix(est6[,1]), ci((est6[,2] est6[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta6,"%4.3f")' (`=string($se6,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_lowturnover_highrent_young_`yout'.pdf", replace
	
	coefplot (matrix(est7[,1]), ci((est7[,2] est7[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta7,"%4.3f")' (`=string($se7,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_lowturnover_lowrent_old_`yout'.pdf", replace
	
	coefplot (matrix(est8[,1]), ci((est8[,2] est8[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(`ytitle') ylabel(`ymin'(`ystep')`ymax') ///
		note(`"{&beta} = `=string($beta8,"%4.3f")' (`=string($se8,"%4.3f")')"', position(2) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren_lowturnover_lowrent_young_`yout'.pdf", replace
end

main

