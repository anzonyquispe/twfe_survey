version 15.0
clear all
set more off
set scheme s1color

***********
* Figure 2
***********

prog main

	* Check home ownership rates in Infutor against 2000 census
	plot_ownership, yr(2000) ds("SF3a") mscale(0.2)
	* Check home ownership rates in Infutor against 2000 census
	plot_ownership, yr(2000) ds("SF3a") mscale(0.2)
end

prog plot_ownership
	syntax, yr(str) ds(str) [mscale(real 0.4) usecode(str) type(str)]

	use "data/infutor/infutor_`yr'`ds'`usecode'.dta", clear	
	drop if tot_owner_occ_infutor < 100 | tot_rent_occ_infutor < 100

	qui reg own_rate_infutor own_rate`type'_census [aw=tot_occ`type'_census]
	loc slope: di %4.3f _b[own_rate`type'_census]
	loc se: di %4.3f _se[own_rate`type'_census]
	
	loc r2: display %4.3f e(r2)
	loc nobs = e(N)
		
	scatter own_rate_infutor own_rate`type'_census [aw=tot_occ`type'_census], ///
		msymbol(Oh) mcolor(gs6) msize(*`mscale') ///
		|| lfitci own_rate_infutor own_rate`type'_census [aw=tot_occ`type'_census], ///
		clpattern(dash) clcolor(blue) aspectratio(1) ///
		|| function y = x,  ra(own_rate`type'_census) clpat(dash) ///
		lcolor(orange_red) ///
		legend(order(2 3 4) label(4 "45 degree") size(small) symxsize(11)) ///
		xtitle("Census Ownership Rate") ///
		ytitle("Infutor Ownership Rate") ///
		xsize(4) ysize(4) ///
		note(`"{&beta} = `slope' (`se')"' ///
		     `"R{sup:2} = `r2'"' ///
		     `"Obs = `=string(`nobs',"%4.0f")'"', position(10) ring(0) linegap(1.5))

	graph export "output/census_check_`yr'/own_rate`type'_`ds'.pdf", replace	
end

main




