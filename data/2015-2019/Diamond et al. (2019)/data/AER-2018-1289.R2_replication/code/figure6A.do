version 15.0
clear all
set more off
set scheme s1color
set matsize 1000

*************
* Figure 6A
*************

prog main
	use if is_owner==0 using "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear
	keep if year_first_nonmiss <= 1993
	reg_main, cl(id) ownstub(ren)
end

prog reg_main
	syntax, cl(str) ownstub(str)

	global base_sample_treat yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & inlist(year,1990,2000,2010,2011,2012,2013) & age_in1993>=20 & age_in1993<=65 & treat==1
	global base_sample_control yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & inlist(year,1990,2000,2010,2011,2012,2013) & age_in1993>=20 & age_in1993<=65 & treat==0
	
	* Treament effects on multi-family res (2-4) units
	eststo clear
	loc sample_smallmulti ($base_sample_treat | $base_sample_control) & use_code_treat==3
	
	reg_treat hinc     if `sample_smallmulti', cl(`cl')
	save_coefmat, coefmat(est1) baselevelpos(1)
	reg_treat pcol     if `sample_smallmulti', cl(`cl')
	save_coefmat, coefmat(est2) baselevelpos(1)
	reg_treat mhmval   if `sample_smallmulti', cl(`cl')
	save_coefmat, coefmat(est3) baselevelpos(1)
	reg_treat punemp   if `sample_smallmulti', cl(`cl')
	save_coefmat, coefmat(est4) baselevelpos(1)

	plot_coef, m1(est1) m2(est2) m3(est3) m4(est4)  ///
		lab1(Median Household Income) ///
		lab2(Share College) ///
		lab3(Median House Value) ///
		lab4(Share Unemployed) ///
	smpstub(smallmulti) ownstub(`ownstub')
end

prog reg_treat
	syntax varname [if], CLustvar(str)
	
	* Treatment zipcode by year FE
	eststo: reghdfe `varlist' io0b1990.treat_year `if', absorb(i.year#i.yrs_at_curr93 zip_year id) vce(cluster `clustvar')

	* Mean of dependent variable in control group in pre-treatment period
	qui sum `varlist' `if' & year==1990 & treat==0
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

	matrix `coefmat' = [B', lb', ub']
	loc rownames 1990.treat_year 
	foreach yr of numlist 2000 2010/2013 {
		loc rownames `rownames' `yr'.treat_year
	}
	matrix rownames `coefmat' = `rownames'
	matrix drop V B se lb ub
end

prog plot_coef
	syntax, m1(str) m2(str) m3(str) m4(str)  lab1(str) lab2(str) lab3(str) lab4(str)  smpstub(str) ownstub(str) [postfix(str)]

	coefplot (matrix(`m1'[,1]), ci((`m1'[,2] `m1'[,3])) lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), bylabel(`lab1') ///
		|| (matrix(`m2'[,1]), ci((`m2'[,2] `m2'[,3])) lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), bylabel(`lab2') ///
		|| (matrix(`m3'[,1]), ci((`m3'[,2] `m3'[,3])) lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), bylabel(`lab3') ///
		|| (matrix(`m4'[,1]), ci((`m4'[,2] `m4'[,3])) lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), bylabel(`lab4') ///
		||, keep(*.treat_year) levels(90) ///
		relocate(2000.treat_year=6 2010.treat_year=11 2011.treat_year=12 2012.treat_year=13 2013.treat_year=14) ///
		xlabel(1 "1990" 6 "2000" 11 "2010" 12 "2011" 13 "2012" 14 "2013", labsize(vsmall)) ///
		yla(, ang(h) labsize(small)) ///
		yline(0, lcolor(black) lwidth(vthin)) vertical baselevels ///
		byopts(row(5) yrescale compact) ///
		ysize(5.5) xsize(3.5) ///
		subtitle(, size(small) bcolor(white) bmargin(tiny))
	graph export "output/treat_`smpstub'_`ownstub'_tractvar`postfix'.pdf", replace  
end

main
