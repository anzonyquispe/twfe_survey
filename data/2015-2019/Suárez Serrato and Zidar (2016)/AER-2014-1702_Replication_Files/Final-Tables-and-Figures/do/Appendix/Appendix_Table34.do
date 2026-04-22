clear
set more off

*Payroll tax change probit

use "$dtapath/Tables/Appendix_Table34.dta", clear

gen b = ""
gen se = ""
gen indepvars = " "
gen stars="" in 1
probit I_D_payroll other_payroll_weight L(1/2).other_payroll_weight corporate_rate L(1/2).corporate_rate income_rate_avg L(1/2).income_rate_avg L(0/1).income_pc_growth L(1/2).natl_unemp_rate, vce(r) 
matrix beta=e(b)
mat error = vecdiag(cholesky(diag(vecdiag(e(V)))))
forv i = 1/13 {
	local var_pval = abs(beta[1,`i']/error[1,`i']) /*Stars definition; since probit, can use z-values as df doesn't mean anything*/
	replace stars="*" if (`var_pval'>=1.65) & (`var_pval'<=1.96) in 1
	replace stars="**" if (`var_pval'>=1.96) & (`var_pval'<=2.58) in 1
	replace stars="***" if (`var_pval'> 2.58) in 1
	replace stars = "" if (`var_pval'<1.65) in 1
	replace b = string(round(10e3*beta[1,`i'])/10e3) + stars[1] in `i'
	replace se = "(" + string(round(10e3*error[1,`i'])/10e3) + ")" in `i'
}
replace indepvars = "Mean Payroll Weight of Other States" in 1
replace indepvars = "Mean Payroll Weight of Other States ($ t-1$)" in 2
replace indepvars = "Mean Payroll Weight of Other States ($ t-2$)" in 3
replace indepvars = "Corporate Tax Rate" in 4
replace indepvars = "Corporate Tax Rate ($ t-1$)" in 5
replace indepvars = "Corporate Tax Rate ($ t-2$)" in 6
replace indepvars = "Individual Income Tax Rate" in 7
replace indepvars = "Individual Income Tax Rate ($ t-1$)" in 8
replace indepvars = "Individual Income Tax Rate ($ t-2$)" in 9
replace indepvars = "State Income Growth ($ t -1$)" in 10
replace indepvars = "State Income Growth ($ t -2$)" in 11
replace indepvars = "National Unemployment Rate ($ t-1$)" in 12
replace indepvars = "National Unemployment Rate ($ t-2$)" in 13
keep b se indepvars
drop if b == ""
order indepvars b se
listtex using "Appendix_Table34.tex", replace rstyle(tabular)
