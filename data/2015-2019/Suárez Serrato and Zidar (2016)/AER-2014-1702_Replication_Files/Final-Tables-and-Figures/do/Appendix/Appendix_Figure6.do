clear
set more off
*********************************************************
*1. Histogram program
*********************************************************

capture program drop fig_hist_nozeros
program define fig_hist_nozeros
syntax, var(varname) figname(name) xtitle(string)
 
	use "$dtapath/Figures/Appendix_Figure6.dta", clear

	hist `var' if abs(`var')!=0, freq ///
	xtitle(`xtitle') ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white)) 	
graph export "$append_graphpath/`figname'.pdf", replace
end 

*********************************************************
*2. Execute
*********************************************************
use "$dtapath/Figures/Appendix_Figure6.dta", clear
  
*Appendix Figure 6a
fig_hist_nozeros, /// 
 var(d_corporate_rate) /// 
 figname(Appendix_Figure6a) /// 
 xtitle(Ten Year Change in Statutory State Corporate Tax Rate)
 
*Appendix Figure 6b
fig_hist_nozeros, /// 
 var(d_payroll) /// 
 figname(Appendix_Figure6b) /// 
 xtitle(Ten Year Change in Payroll Apportionment Weight)
  
 
