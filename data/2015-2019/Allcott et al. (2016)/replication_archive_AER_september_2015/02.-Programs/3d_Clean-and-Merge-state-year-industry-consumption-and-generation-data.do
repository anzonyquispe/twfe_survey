************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************
/* GET CROSSWALK */
insheet using "$data\From Deepak\Captive Power\CaptivePowerStateCrosswalk.csv",comma names clear
replace state = "GOA DAMAN AND DIU" if state=="GOA"
replace state = "GOA DAMAN AND DIU" if state=="DAMAN AND DIU"
save "$intdata\CaptivePowerStateCrosswalk.dta", replace

************************************************************************
************************************************************************
/* GET CAPTIVE POWER DATA */
insheet using "$data\From Deepak\Captive Power\Energy consumption (GWh), year-wise, state-wise, industry-wise\Energy consumption (GWh), year-wise, state-wise, industry-wise.csv", comma names clear
replace stateuts=trim(stateuts)
foreach var of varlist aluminium-totalcalculated {
rename `var' _`var'
}
destring _all, replace
reshape long _, i(stateuts year) j(industry) string
rename _ eleccons
tempfile cons	
save `cons'



insheet using "$data\From Deepak\Captive Power\Gross Electricity Generation State-Wise Industry-Wise\Gross Electricity Generation State-Wise Industry-Wise .csv", comma names clear
replace state="Chhattisgarh" if state=="Chattishgarh"
replace state="Jammu & Kashmir" if state=="Jammu & kashmir"
replace state=trim(state)
foreach var of varlist aluminium-totalcalculated {
rename `var' _`var'
tostring _`var', replace force
replace _`var'="." if _`var'=="Neg."
replace _`var'="." if _`var'=="Neg"
destring _`var', replace
}

reshape long _, i(stateuts year) j(industry) string
rename _ elecgen
merge 1:1 state year industry using `cons'
	assert _m==3
	drop _m


	
/* Get state totals */	
** Added by Hunt 3-20
keep if industry=="totalcalculated"
drop industry

** Temporarily make missing data that are incomplete
replace elecgen = . if year==1993
replace eleccons = . if year==1990|year==1993

** Make missing data from small states that generate outlying values of ElecGen_Cons_CEA
	* These are based on visual inspection using the graphs below. (Hunt 4-25-2013)
foreach var in elecgen eleccons {
	replace `var' = . if state=="JAMMU AND KASHMIR"|state=="LAKSHADWEEP"|state=="MEGHALAYA"|state=="NAGALAND"
}

replace state = "Goa, Daman & Diu" if stateuts=="Goa"
replace state = "Goa, Daman & Diu" if stateuts=="Goa, Daman & Diu"
replace state = "Goa, Daman & Diu" if stateuts=="Daman & Diu"

collapse (sum) elecgen eleccons, by(stateuts year)

gen ElecGen_Cons_CEA = elecgen/eleccons
merge m:1 state using "$intdata/CaptivePowerStateCrosswalk.dta", nogen keep(match master)
drop stateuts
save "$intdata/ShareElecSelfGen_CEA.dta", replace





