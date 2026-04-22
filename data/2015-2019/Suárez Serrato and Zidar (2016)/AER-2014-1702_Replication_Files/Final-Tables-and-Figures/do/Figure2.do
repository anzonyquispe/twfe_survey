clear
set more off
cd "$graphpath"

use "$dtapath/Figures/Figure2.dta", clear
keep if year == 2012

***************
*1. Figure 2A
***************

foreach state of numlist 32 46 48 53 56 {
	replace total_change_corp = . if statefips == `state' /* Placeholder for states that never have a corporate tax rate */
}

maptile total_change_corp, geo(state) geoid(statefips) ndf(gs7) ///
	cutv(1 2 3 5 7) spopt(legend(lab(1 "Never Tax") ///
	lab(2 "[0,1]") lab(3 "(1,2]") lab(4 "(2,3]") lab(5 "(3,5]") lab(6 "(5,7]") lab(7 "(7,9]")))

graph export "Figure2a.pdf", replace


***************
*2. Figure 2B
***************

foreach state of numlist 32 46 48 53 56 {
	replace corporate_rate = . if statefips == `state' /* Placeholder for states that never have a corporate tax rate */
}

maptile corporate_rate, geo(state) geoid(statefips) ndf(gs7) ///
	cutv(6 7.5 8.5) spopt(legend(lab(1 "Never Tax") ///
	lab(2 "(0,6]") lab(3 "(6,7.5]") lab(4 "(7.5,8.5]") lab(5 "(8.5,12]")))
graph export "Figure2b.pdf", replace
