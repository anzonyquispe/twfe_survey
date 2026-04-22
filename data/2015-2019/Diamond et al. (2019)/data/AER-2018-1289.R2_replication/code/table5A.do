version 15.0
clear all
set more off
set scheme s1color
set matsize 1000

*================
* Table 5 Panel A
*================

prog main	
	//robustness check of tenants treatment effect using individuals who lived in structures built between 1960 and 1979
	use if is_owner==0 using "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear
	reg_main, cl(id) ownstub(ren)
end

prog reg_main
	syntax, cl(str) ownstub(str)

	global base_sample_treat yr_built_treat>=1960 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & age_in1993>=20 & age_in1993<=65 & treat==1
	global base_sample_control yr_built_treat>=1960 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & age_in1993>=20 & age_in1993<=65 & treat==0

	eststo clear
		
	* Treament effects on multi-family res (2-4) units.
	loc sample_smallmulti ($base_sample_treat | $base_sample_control) & use_code_treat==3
	keep if `sample_smallmulti'
	
	reg_treat_year_cat insf        if `sample_smallmulti', cl(`cl')
	reg_treat_year_cat same_parcel if `sample_smallmulti', cl(`cl')

	write_esttab, smpstub(smallmulti) ownstub(`ownstub') ///
		mtitles(`""In SF" "Same Address""')
end

prog reg_treat_year_cat
	syntax varname [if], CLustvar(str)
	
	eststo: reghdfe `varlist' io0b1.treat_year_cat `if', absorb(i.year_cat#i.yrs_at_curr93 i.year_cat#i.zip_treat id) vce(cluster `clustvar')

	* Mean of dependent variable in control group in each period
	qui sum `varlist' `if' & year_cat==2 & treat==0
	estadd scalar depvar_mean1 = r(mean)

	qui sum `varlist' `if' & year_cat==3 & treat==0
	estadd scalar depvar_mean2 = r(mean)

	qui sum `varlist' `if' & year_cat==4 & treat==0
	estadd scalar depvar_mean3 = r(mean)
end

prog write_esttab
	syntax, smpstub(str) ownstub(str) mtitles(str)
		
	esttab using "output/treat_collapse_`smpstub'_`ownstub'_alttsmp.csv", replace wide plain ///
		cells(b(star fmt(4)) se(fmt(4))) ///
		keep(*.treat_year_cat) nobaselevels ///
		refcat(2.treat_year_cat "Treat\(\times\)Period", nolabel) ///
		stats(depvar_mean1 depvar_mean2 depvar_mean3 r2_a N, fmt(4 4 4 3 0) layout(@ @ @ @ @) ///
		labels(`"Control Mean \(1994-1999\)"' `"Control Mean \(2000-2004\)"' `"Control Mean Post 2005"' `"Adjusted \(R^{2}\)"' `"Observations"')) ///
		star(* 0.1 ** 0.05 *** 0.01) ///
		label wrap collabels(none) nonotes ///
		mtitles(`mtitles')

	eststo clear
end

main
