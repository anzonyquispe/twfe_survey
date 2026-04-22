version 15.0
clear all
set more off
set scheme s1color

***********
* Figure 1
***********

prog main

	* Check counts of Infutor population 18+ against 2000 census
	plot_age, yr(2000) ds("SF1a")
	* Check counts of Infutor population 18+ against 1990 census
	plot_age, yr(1990) ds("SF1a")
end

prog plot_age
	syntax, yr(str) ds(str) [usecode(str)]

	use "data/infutor/infutor_`yr'`ds'`usecode'.dta", replace

	* Plot the raw population (after removing people under 18)
	qui reg raw_pop_infutor raw_pop_census
	loc slope: di %4.3f _b[raw_pop_census]
	loc se: di %4.3f _se[raw_pop_census]
	
	loc r2: display %4.3f e(r2)
	loc nobs = e(N)

	scatter raw_pop_infutor raw_pop_census, msymbol(Oh) mcolor(gs6) ///
		|| lfitci raw_pop_infutor raw_pop_census, ///
		clpattern(dash) clcolor(blue) aspectratio(1) ///
		|| function y = x,  ra(raw_pop_census) ///
		clpat(dash) lcolor(orange_red) ///
		legend(order(2 3 4) label(4 "45 degree") size(small) symxsize(11)) ///
		xtitle("Census Population 18+") ///
		ytitle("Infutor Population 18+") ///
		xsize(4) ysize(4) ///
		note(`"{&beta} = `slope' (`se')"' ///
		     `"R{sup:2} = `r2'"' ///
		     `"Obs = `=string(`nobs',"%4.0f")'"', position(10) ring(0) linegap(1.5))

	graph export "output/census_check_`yr'/raw_pop.pdf", replace	
end

main




