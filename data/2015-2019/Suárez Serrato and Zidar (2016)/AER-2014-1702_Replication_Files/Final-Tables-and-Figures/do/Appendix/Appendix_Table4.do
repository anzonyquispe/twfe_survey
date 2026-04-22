clear
set more off

cd "$append_tablepath"

/**********************/
/* Correlation Tables */
/**********************/

use "$dtapath/Tables/Appendix_Table4.dta"

mat accum c = corporate_rate taxratesales esrate_agg_post proptax, nocons dev
mat corr = corr(c)
mat list corr

svmat corr

keep corr1-corr4
drop if corr1 == .
replace corr2 = . in 1
replace corr3 = . in 1/2
replace corr4 = . in 1/3


listtex using "Appendix_Table4a.tex", rstyle(tabular) replace


*10-year differences in rates

use "$dtapath/Tables/Appendix_Table4.dta", clear

keep if inlist(year, 1980, 1990, 2000, 2010)

sort fips_state year
tsset fips_state year

g D_corporate_rate = corporate_rate - L10.corporate_rate
g D_taxratesales = taxratesales - L10.taxratesales
g D_pers_rate = esrate_agg_post - L10.esrate_agg_post
g D_proptax = proptax - L10.proptax


mat accum c = D_corporate_rate D_taxratesales D_pers_rate D_proptax, nocons dev
mat corr = corr(c)
mat list corr

svmat corr

keep corr1-corr4
drop if corr1 == .
replace corr2 = . in 1
replace corr3 = . in 1/2
replace corr4 = . in 1/3

listtex using "Appendix_Table4b.tex", rstyle(tabular) replace
