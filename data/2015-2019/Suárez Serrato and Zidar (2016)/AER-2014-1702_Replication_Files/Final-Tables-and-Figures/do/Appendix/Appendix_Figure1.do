clear
set more off

use "$dtapath/Figures/Appendix_Figure1.dta"

cd "$append_graphpath"

tempfile data
save `data'

keep if fipstate <30 /* States up to Missouri */


line corporate_rate year, by(statename, graphregion(fcolor(white)) note("")) ///
	yti("Number of States") color(navy) 
graph export "Appendix_Figure1a.pdf", replace


use `data', clear
keep if fipstate >=30 /* Remaining states */

line corporate_rate year, by(statename, graphregion(fcolor(white)) note("")) ///
	yti("Number of States") color(navy) 
graph export "Appendix_Figure1b.pdf", replace
