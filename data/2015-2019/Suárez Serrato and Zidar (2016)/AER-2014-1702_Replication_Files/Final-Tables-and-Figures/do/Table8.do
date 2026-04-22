clear
set more off

use "$dtapath/Tables/table8.dta", clear
keep state fips_state year E_s corporate_rate share_perstocorp s_ccorp property payroll

gen theta_s=1-((payroll+property)/100)
*********************************************************
*4. PLUG IN ESTIMATED PARAMETER VALUES AND EFFECTS
*********************************************************

** ALL SHOCKS
local sigmaF=.277
local pidot=.990
local wdot=.944
local els=.78
local Ndot=`wdot'*`els'
local t_fed=.35
/*
*ONLY BUSINESS SHOCKS
local sigmaF=.119
local pidot=1.014
local wdot=.839
local els=4.188
local Ndot=`wdot'*`els'
local t_fed=.35
*/

* epsilon of -2.5, which plus 1 X -1=1.5 and estimate of sigma F X share of c corps
gen E_dot=1/(`sigmaF'*(1.5))*s_ccorp/100
replace E_dot=E_dot*(1-E_s)
gen laffer_no_pers=(1-`t_fed')/(E_dot+`pidot')

gen laffer_pers=(1-`t_fed')/(E_dot+`pidot'+share_perstocorp*(`wdot'+`Ndot'))
gen laffer_pers_apport=laffer_pers/(1-theta_s)


sort state

keep state fips_state E_s corporate_rate share_perstocorp laffer* theta_s

foreach v in "E_s" "laffer_no_pers" "laffer_pers" "laffer_pers_apport" "theta_s" {
replace `v'=`v'*100
}

*twoway (scatter laffer_pers corporate_rate if corporate_rate>5 & laffer_pers<.1, msize(medsmall) mlabel(state) mlabsize(vsmall))

order fips_state state E_s share_perstocorp theta_s corporate_rate laffer_no_pers laffer_pers laffer_pers_apport

*export excel using "$dirout/raw_laffer_table.xlsx", firstrow(variables) replace
export excel using "$tablepath/Table8_allstates.xlsx", firstrow(variables) replace 
summ

keep if inlist(fips_state,20,35,6,51,4,48,18)
sort theta_s
*export excel using "$dirout/raw_laffer_table_selectedstates.xlsx", firstrow(variables) replace
export excel using "$tablepath/Table8.xlsx", firstrow(variables) replace 
