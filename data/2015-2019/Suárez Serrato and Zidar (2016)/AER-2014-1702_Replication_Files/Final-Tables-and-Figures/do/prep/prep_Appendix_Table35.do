clear
set more off

*National annual unemployment rate crosswalk; source BLS.
import delim "$dropbox/Local_Econ_Corp_Tax/Programs/Final Tables and Figures/Revision/John tables/SeriesReport-20150731105051_1e6170.csv", varnames(nonames) rowrange(13) colrange(:2) clear
rename v1 year
rename v2 natl_unemp_rate
sort year
tempfile natl_unemp_temp
save `natl_unemp_temp'

use "$datapath_misalloc/misallocation_paneldata.dta", clear
sort year
merge year using `natl_unemp_temp'
drop _merge
sort fipstate year
tsset fipstate year

local threshold=.5 /*Change threshold for change if you want*/

*count tax changes
sort fipstate year
tsset fipstate year
foreach tax in income_rate_avg corporate_rate payroll {
g I_D_`tax'=(abs(`tax'-L1.`tax')>=`threshold')
}
keep if year>=1978 & year<=2010

g other_corp =. /*Generating other state corp by year*/
by year, sort: gen tempid = _n 
summarize tempid
quietly forvalues i = 1/`r(max)' { 
	gen include = 1 if tempid != `i' 
	egen othertemp = sum(corporate_rate * include), by(year) 
	replace other_corp = othertemp if tempid == `i' 
	drop include othertemp
}
egen num_states = max(tempid)
gen other_corp_rate = other_corp/num_states

sort fipstate year
g income_pc= GDP/pop /*Income per capita*/
g income_pc_growth = income_pc/L1.income_pc /*Growth*/

keep I_D_corporate_rate other_corp_rate corporate_rate income_rate_avg payroll income_pc_growth natl_unemp_rate year fipstate


saveold "$dtapath/Tables/Appendix_Table35.dta", replace
