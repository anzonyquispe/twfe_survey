version 15.0
clear all
set more off
set scheme s1color
set matsize 1000

*************
* Figure 4
*************

prog main
	
	use "data/housing_inventory/clean_combined", clear
	keep if year>=1990 & year<=2016
	gen log_adj_median_rent = log(adj_median_rent)
	* detrended log real median rent
	reg log_adj_median_rent year, robust
	predict res_medrent, residual
	keep year log_adj_median_rent res_medrent
	mkmat log_adj_median_rent res_medrent, matrix(rent) rownames(year)
	
	use if is_owner==0 using "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear
	reg_main, cl(id) ownstub(ren)
end

prog reg_main
	syntax, cl(str) ownstub(str)

	global base_sample_treat yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & age_in1993>=20 & age_in1993<=65 & treat==1
	global base_sample_control yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & age_in1993>=20 & age_in1993<=65 & treat==0

	eststo clear

	* Treament effects on multi-family res (2-4) units.
	loc sample_smallmulti ($base_sample_treat | $base_sample_control) & use_code_treat==3
	keep if `sample_smallmulti'
	
	reg_treat insf                 if `sample_smallmulti', cl(`cl')
	save_coefmat, coefmat(est1) baselevelpos(4)
	
	reg_treat same_parcel          if `sample_smallmulti', cl(`cl')
	save_coefmat, coefmat(est4) baselevelpos(4)

	plot_coef, smpstub(smallmulti) ownstub(`ownstub') ymax(0.07) ymin(-0.02) ystep(0.02)
end

prog reg_treat
	syntax varname [if], CLustvar(str)

	*Zipcode of treatment address by year FE
	eststo: reghdfe `varlist' io0b1993.treat_year `if', absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster `clustvar') baselevels

	* Mean of dependent variable in control group in pre-treatment period
	qui sum `varlist' `if' & year<=1993 & treat==0
	estadd scalar depvar_mean = r(mean)
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

	matrix `coefmat' = [B', lb', ub', rent]
	loc rownames 1990.treat_year 
	forval yr = 1991/2016 {
		loc rownames `rownames' `yr'.treat_year
	}
	matrix rownames `coefmat' = `rownames'
	matrix drop V B se lb ub
end

prog plot_coef
	syntax, smpstub(str) ownstub(str) ymax(str) ymin(str) ystep(str)

	preserve
	
	clear
	svmat est1
	rename est11 insf
	rename est14 log_adj_median_rent
	rename est15 res_medrent
	
	qui corr log_adj_median_rent insf
	loc rho: di %4.3f r(rho)
		
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*1.5) ciopts(recast(rarea) lcolor(gs14) fcolor(gs14))) ///
		(matrix(est1[,5]), recast(line) noci lcolor(maroon*0.8) lpattern(dash_dot) lwidth(*1.5) axis(2)), ///
		keep(*.treat_year) xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) nooffsets vertical ///
		ytitle("Treatment Effect: In SF") ytitle("`ytitle' Log Median Rent (Detrended)", axis(2)) ///
		ylabel(`ymin'(`ystep')`ymax', labsize(small)) ylabel(-0.2(0.1)0.5, labsize(small) axis(2)) ///
		plotlabel("In SF" "Real Log Median Rent (Detrended)") ///
		legend(region(lwidth(none)) size(medsmall)) ///
		note(`"Corr = `rho'"', position(10) ring(0))
	graph export "output/treat_`smpstub'_`ownstub'_insf.pdf", replace
	
	clear
	svmat est4
	rename est41 same_address
	rename est44 log_adj_median_rent
	rename est45 res_medrent
	
	qui corr log_adj_median_rent same_address
	loc rho: di %4.3f r(rho)
	
	coefplot (matrix(est4[,1]), ci((est4[,2] est4[,3])) ///
		lcolor(gs5) recast(line) lwidth(*1.5) ciopts(recast(rarea) lcolor(gs14) fcolor(gs14))) ///
		(matrix(est4[,5]), recast(line) noci lcolor(maroon*0.8) lpattern(dash_dot) lwidth(*1.5) axis(2)), ///
		keep(*.treat_year) xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(,ang(h)) yline(0, lcolor(black) lwidth(vthin)) nooffsets vertical ///
		ytitle("Treatment Effect: Same Address") ytitle("`ytitle' Log Median Rent (Detrended)", axis(2)) ///
		ylabel(`ymin'(`ystep')`ymax', labsize(small)) ylabel(-0.2(0.1)0.5, labsize(small) axis(2)) ///
		plotlabel("Same Address" "Real Log Median Rent (Detrended)") ///
		legend(region(lwidth(none)) size(medsmall)) ///
		note(`"Corr = `rho'"', position(10) ring(0))
	graph export "output/treat_`smpstub'_`ownstub'_sameaddress.pdf", replace
	
	restore
end

main
