clear
set more off

*********************************************************
*Binscatter Program
*********************************************************
capture program drop Binscatter10YR
program Binscatter10YR
syntax, yvar(varname) tax(varname) figname(name) cluster(varname) ///
  ytitle(string) xtitle(string)


areg  `yvar' `tax' , absorb(year) cluster(`cluster')
matrix define M=e(b)
local A=round(100*M[1,1])/100
local B=round(100*M[1,2])/100
local se=round(_se[`tax']*100)/100

binscatter `yvar' `tax', reportreg absorb(year) ///
 ytitle("`ytitle'") xtitle("`xtitle'") ///
 note("Slope=  `A' (`se')", position(3) ring(0) size(medium)) 
graph export "`figname'.pdf", replace
end

*********************************************************
* GOS per establishment
********************************************************* 
use "$dtapath/Figures/Appendix_Figure14.dta"
cd "$append_graphpath"

local ytitle= "10 Year Log Change in GOS per Establishment"
local xtitle="10 Year Log Change in Net of Business Tax Rate"
Binscatter10YR, yvar(D10_GOS_E) tax(d_bus_dom2) figname(Appendix_Figure14) cluster(fipstate) ///
ytitle(`ytitle') xtitle(`xtitle')


