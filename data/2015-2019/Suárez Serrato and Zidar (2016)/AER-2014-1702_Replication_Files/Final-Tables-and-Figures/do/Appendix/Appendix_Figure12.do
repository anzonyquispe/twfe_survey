clear
set more off


use "$dtapath/Figures/Appendix_Figure12.dta"
cd "$append_graphpath"

*********************************************************
*W Binscatter
*********************************************************
gen y=dadjlwage
gen x=d_bus_dom2

areg  y x, absorb(year) cluster(fips_state)
matrix define M=e(b)
local A=round(100*M[1,1])/100
local B=round(100*M[1,2])/100
local se=round(_se[x]*100)/100

binscatter y x, reportreg absorb(year) ///
 ytitle("10 Year Log Change in Composition Adj. Wages") xtitle(" 10 Year Log Change in Net of Business Tax Rate ") ///
 note("Slope=  `A' (`se')", position(3) ring(0) size(medium)) 
graph export "Appendix_Figure12.pdf", replace
