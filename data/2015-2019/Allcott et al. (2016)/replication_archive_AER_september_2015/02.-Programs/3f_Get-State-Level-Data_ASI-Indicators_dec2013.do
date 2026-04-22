/* Get State-Level Data.do */
* This do file takes the ASI and other data and creates a state-by-year dataset of winsorized variables.

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
use "$intdata/State-Level ASI.dta", clear

merge 1:1 state year using "$work\state-level indicators 1992-2010.dta", assert(1 3) nogen 

encode state, gen(statenum)

gen Population = gdp_curr/pcgdp_curr*10^3 // Population is in millions

rename gdp_const gdp
sort state year


** Logs
foreach var in gdp req avail pd pm {
	gen ln`var' = ln(`var')
}

** Get Natural Logs
foreach var in Shortage PeakShortage {
	gen ln`var' = cond(`var'!=., ln(max(`var',0)+1),.) // Note: conceptually we do want to have negative shortages as zero - it is not meaningful to have a negative shortage, as all of demand is being met.
}

** Percent change:
foreach var in gdp req avail pd pm {
* ln_gdp ln_req ln_avail ln_pd ln_pm { 
	gen pd_`var' = `var'/`var'[_n-1] - 1 if state==state[_n-1]&year==year[_n-1]+1&gdp!=0&gdp[_n-1]!=0
	gen pd2_`var' = `var'/`var'[_n-2] - 1 if state==state[_n-2]&year==year[_n-2]+2&gdp!=0&gdp[_n-2]!=0
	gen pd13_`var' = pd2_`var'[_n-1] if state==state[_n-1]&year==year[_n-1]+1
}
	
gen statelabel = proper(state)
replace statelabel = subinstr(statelabel,"And ","and ",.)
replace statelabel = "DVC" if statelabel=="Dvc"
*replace statelabel = subinstr(statelabel,"Pradesh","",.)

bysort state: egen meanShortage = mean(Shortage) if year>=1992&year<=2010
bysort state: egen meanPeakShortage = mean(PeakShortage) if year>=1992&year<=2010


/* Label */
label var gdp "GDP (Billion 2004 Rupees)"
label var pd2_gdp "Pct GDP Change"


/* Save */
compress
xtset statenum year
sort statenum year

save "$work/State-Level Dataset_ASI&Indicators.dta", replace
