
insheet using "$data/Deflators/gdp deflator national.csv", comma names clear
drop if gdp_defl_natl==.
replace gdp_defl_natl=gdp_defl_natl/100
save "$work/gdp_defl_natl.dta", replace
