version 15.0
clear all
set more off
set scheme s1color

****************************
* Produce numbers in table 2
****************************

prog main

	plot_2000_census
 	plot_1990_census
end

prog plot_2000_census

	* Check counts of Infutor population by age group against 2000 census
	plot_age, yr(2000) ds("SF1a")

	* Check share of occupied housing units by year built against 2000 census
	plot_yearbuilt, yr(2000) ds("SF3a") ///
		varlist("own_1980_2000 own_1960_1979 own_1950_1959 own_1940_1949 own_1939e ren_1980_2000 ren_1960_1979 ren_1950_1959 ren_1940_1949 ren_1939e built_1980_2000 built_1960_1979 built_1950_1959 built_1940_1949 built_1939e") ///
		desclist(`""1980-2000" "1960-1979" "1950-1959" "1940-1949" "1939 and earlier" "1980-2000" "1960-1979" "1950-1959" "1940-1949" "1939 and earlier" "1980-2000" "1960-1979" "1950-1959" "1940-1949" "1939 and earlier""') mscale(0.2)
end 

prog plot_1990_census

	* Check counts of Infutor population by age group against 1990 census
	plot_age, yr(1990) ds("SF1a")

	* Check share of occupied housing units by year built against 1990 census
	plot_yearbuilt, yr(1990) ds("SF3a") ///
		varlist("own_1970_1990 own_1950_1969 own_1940_1949 own_1939e ren_1970_1990 ren_1950_1969 ren_1940_1949 ren_1939e built_1970_1990 built_1950_1969 built_1940_1949 built_1939e") ///
		desclist(`""1970-1990" "1950-1969" "1940-1949" "1939 and earlier" "1970-1990" "1950-1969" "1940-1949" "1939 and earlier" "1970-1990" "1950-1969" "1940-1949" "1939 and earlier""') mscale(0.2)
end

prog plot_age
	syntax, yr(str) ds(str) [usecode(str)]

	use "data/infutor/infutor_`yr'`ds'`usecode'.dta", replace
	
	* Plot raw number in each age group
	tokenize "18+ 18-29 30-39 40-49 50-59 60-69 70-79 80+"
	loc age_group "18p 18_29 30_39 40_49 50_59 60_69 70_79 80p"
	forval num = 1/8 {
		loc group: word `num' of `age_group'

		qui reg pop_`group'_infutor pop_`group'_census
		loc slope: di %4.3f _b[pop_`group'_census]
		loc se: di %4.3f _se[pop_`group'_census]
		
		loc r2: display %4.3f e(r2)
		loc nobs = e(N)

		scatter pop_`group'_infutor pop_`group'_census, msymbol(Oh) mcolor(gs6) ///
			|| lfitci pop_`group'_infutor pop_`group'_census, ///
			clpattern(dash) clcolor(blue) aspectratio(1) ///
			|| function y = x,  ra(pop_`group'_census) ///
			clpat(dash) lcolor(orange_red) ///
			legend(order(2 3 4) label(4 "45 degree") size(small) symxsize(11)) ///
			xtitle("Census Population ``num''") ///
			ytitle("Infutor Population ``num''") ///
			xsize(4) ysize(4) ///
			note(`"{&beta} = `slope' (`se')"' ///
			     `"R{sup:2} = `r2'"' ///
			     `"Obs = `=string(`nobs',"%4.0f")'"', position(10) ring(0) linegap(1.5))

		graph export "output/census_check_`yr'/pop_`group'.pdf", replace
	}
end

prog plot_yearbuilt
	* Could plot yearbuilt shares for owner- and renter-occupied units separately
	syntax, yr(str) ds(str) varlist(str) desclist(str) [mscale(real 0.4) usecode(str) type(str)]

	use "data/infutor/infutor_`yr'`ds'`usecode'.dta", clear	
	drop if tot_owner_occ_infutor < 100 | tot_rent_occ_infutor < 100

	tokenize `"`desclist'"'
	foreach var of local varlist {

		qui reg frac_`var'_infutor frac_`var'`type'_census [aw=tot_occ`type'_census]
		loc slope: di %4.3f _b[frac_`var'`type'_census]
		loc se: di %4.3f _se[frac_`var'`type'_census]
		
		loc r2: display %4.3f e(r2)
		loc nobs = e(N)

		scatter frac_`var'_infutor frac_`var'`type'_census [aw=tot_occ`type'_census], ///
			msymbol(Oh) mcolor(gs6) msize(*`mscale') ///
			|| lfitci frac_`var'_infutor frac_`var'`type'_census [aw=tot_occ`type'_census], ///
			clpattern(dash) clcolor(blue) aspectratio(1) ///
			|| function y = x, ra(frac_`var'`type'_census) clpat(dash) ///
			lcolor(orange_red) ///
			legend(order(2 3 4) label(4 "45 degree") size(small) symxsize(11)) ///
			xtitle("Census Fraction Built `1'") ///
			ytitle("Infutor Fraction Built `1'") ///
			xsize(4) ysize(4) ///
			note(`"{&beta} = `slope' (`se')"' ///
			     `"R{sup:2} = `r2'"' ///
			     `"Obs = `=string(`nobs',"%4.0f")'"', position(10) ring(0) linegap(1.5))

		graph export "output/census_check_`yr'/frac_`var'`type'.pdf", replace
		mac shift
	}
end

main




