clear
set more off
cd "$graphpath"

use "$dtapath/Figures/Figure3.dta", clear

hist sales_wgt, freq by(year, graphregion(fcolor(white)) note("")) ///
	yti("Number of States") color(navy) 
	
graph export "Figure3.pdf", replace

