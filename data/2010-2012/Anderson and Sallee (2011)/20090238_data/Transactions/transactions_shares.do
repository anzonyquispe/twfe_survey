*********************
***** FILE INFO *****
*********************
* Name: transactions_shares.do
* Author: Soren Anderson
* Date: May 28, 2010
* Description:



*************************
***** PRELIMINARIES *****
*************************
clear
cd
cd "Y:/Biofuels/FFV CAFE/Transactions"
log using transactions_shares.txt, replace text
set more off
set mem 800m



use transactions1
keep if sample==1



*************************************************************************************
***** SECTION III.B DISCUSSION OF FFV SHARES VERSUS STATE ETHANOL AVAILABILITY *****
*************************************************************************************

* GENERATE MAXIMUM NUMBER ETHANOL STATIONS AND PERCENT AVAILABILITY BY STATE
egen e85max = max(e85), by(state)
egen e85penmax = max(e85pen), by(state)

* WHAT FRACTION OF FFVS IN THE SAMPLE ARE SOLD IN STATES WITH ONE OR FEWER ETHANOL STATIONS?
gen onestation=1 if e85max<=1
replace onestation=0 if onestation==.
tab onestation if ffv==1

* WHAT FRACTION OF FFVS IN THE SAMPLE ARE SOLD IN STATES WITH FEWER THAN 1% ETHANOL STATIONS?
gen onepercent=1 if e85penmax<=1
replace onepercent=0 if onepercent==.
tab onepercent if ffv==1



**********************************************
***** TABLE 5: WHERE ARE FFVS ALLOCATED? *****
**********************************************

* GENERATE STATE AND MONTH DUMMIES AND CLUSTERING VARIABLE
tab state, gen(statedum)
egen cluster = group(state year month)
gen time = ym(year,month)
tab time, gen(timedum)

* (1) STATE DUMMIES EXCLUDED
xtreg ffv e85pen timedum2-timedum87, i(group) fe cluster(cluster) nonest

* (2) STATE DUMMIES INCLUDED
xtreg ffv e85pen timedum2-timedum87 statedum2-statedum51, i(group) fe cluster(cluster) nonest

* YEAR-BY-YEAR TO TEST FOR PARAMETER STABILITY OVER TIME (DISCUSSED IN FOOTNOTE 21)
bysort year: xtreg ffv e85pen timedum2-timedum87, i(group) fe cluster(cluster) nonest



*********************************************************
***** FIGURE 6: FFV SHARES AND ETHANOL AVAILABILITY *****
*********************************************************
* COLLAPSE DATA BY STATE: FFV SHARES, ETHANOL AVAILABILITY, AND TOTAL SALES
collapse (count) price (mean) ffv (max) e85 e85pen, by(state)
ren price obs
gen avail = e85pen
replace avail = 0.01 if avail==0	/* RESET ZERO ETHANOL AVAILABILITY TO 0.01% TO BE COMPATIBLE WITH LOG SCALE BELOW */
format ffv %9.1f

* CONVERT STATE NAMES TO STATE ABBREVIATIONS / ADJUST POSITIONING FOR FIGURE
gen statecodes=state
run "Dofiles/statecodes"
label values statecodes statecodes
gen pos=0
replace pos=0
* AL
replace pos=12 if state==1
* MS
replace pos=6 if state==25
* TX
replace pos=6 if state==44
* VT
replace pos=4 if state==46
* MA
replace pos=9 if state==22
* RI
replace pos=3 if state==40
* CT
replace pos=3 if state==7
* NY
replace pos=10 if state==33
* NH
replace pos=3 if state==30
* ME
replace pos=9 if state==20

* FIGURE 6
scatter ffv avail [weight = obs], xscale(log) msymbol(Oh) mcolor(gray) mlwidth(thin) msize(*1.5) || scatter ffv avail, msymbol(none) mlabel(statecodes) mlabsize(tiny) mlabv(pos) mlabgap(-1.1) scheme(s1manual) legend(off) xlabel(0.016 "0.016" 0.031 "0.031" 0.063 "0.063" 0.125 "0.125" 0.25 "0.25" 0.5 "0.5" 1 2 4 8 16) ylabel(0 0.2 0.4 0.6 0.8 1) xtitle("Ethanol availability (percent of stations)") ytitle("Flexible-fuel share")
graph export "ffvs_e85_states.eps", as(eps) preview(off) fontface(Arial) replace

* WHAT IS AVERAGE FFV SHARE FOR STATES WITH ZERO ETHANOL AVAILABILITY?
sum ffv if e85pen==0 [weight=obs]

* WHAT FRACTION OF VEHICLES ARE SOLD IN STATES WITH ZERO ETHANOL AVAILABILITY?
sum obs if e85pen==0
sum obs if e85pen>0



log close
exit

