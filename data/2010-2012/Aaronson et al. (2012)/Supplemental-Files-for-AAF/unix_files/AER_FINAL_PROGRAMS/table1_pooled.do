****************************************
* Program to pool CPS and SIPP for     *
* Table 1 of Aaronson, Agarwal, French *
* Minimum Wage Paper                   *
****************************************


clear
set more off
set mem 10g


*******
* CPS *
*******

use rep_cps


* Share of Income from Minimum Wage at Beginning of Panel
count if sharemw==.
gen firstsharemw = sharemw if mis==4
sort id year
by id: gen _firstsharemw = firstsharemw[1]
drop firstsharemw
ren _firstsharemw firstsharemw
tab mis if missing(firstsharemw)


drop if year==1979 //1979 had been excluded from old CPS table
drop y1-y29
drop q1 q2 q3 q4

*Make Interview Variable Names Consistent
ren mis wave

* Survey indicators
gen cps = 1
gen sipp = 0
gen cex = 0

tempfile cps
save `cps'

********
* SIPP *
********

clear
use rep_sipp2.dta
keep if year<=2007

gen tot_inc = finc*3

egen id = group(spanel su_id)

count if weight<=0 | weight==.
keep if weight>0 & weight<.

* Survey indicators
gen cps = 0
gen sipp = 1
gen cex = 0

***************************
* Create Quarter Variable *
***************************
gen qtr = .
replace qtr = 1 if month==1 | month==2 | month==3
replace qtr = 2 if month==4 | month==5 | month==6
replace qtr = 3 if month==7 | month==8 | month==9
replace qtr = 4 if month==10 | month==11 | month==12

drop y1-y24

tempfile sipp
save `sipp'

*******
* CEX *
*******

clear
use rep_ces

********************************
* Generate Necessary Variables *
********************************
gen tot_inc = qfincatax if (srvy==firstsrvy | srvy==5)

drop minwage
gen minwage = minwage12

ren firstsharemw_bt firstsharemw


* Survey indicators
gen cps = 0
gen sipp = 0
gen cex = 1

*Clear out year and quarter dummies
drop year y1-y27
drop q1 q2 q3 q4

*Make variable names consistent
ren newid id
ren srvy wave
ren yearr year

tempfile cex
save `cex'

*********************************
* Combine the SIPP, CPS and CEX *
*********************************
clear
use `sipp'
append using `cps'
append using `cex'

tab qtr, gen(q)
forv x=1/4 {
 replace q`x' = 0 if sipp==1 | cps==1
}
foreach var of varlist m2-m12 {
 replace `var' = 0 if cps==1 | cex==1
}

tab year, gen(y)
ds y*

* Interact covariates with Survey Indicators
foreach surv in cps sipp cex {
 foreach var of varlist y1-y28 q1-q3 m2-m12 adults kids {
  gen `var'_`surv' = `var'*`surv'
 }
}

ds y1_cps - kids_cex
egen newid = group(cex sipp cps id)

save pooled.dta, replace

xtset newid wave

capture log close
log using cex_cps_sipp_table1.log, replace

*Column 2 


xtreg tot_inc minwage y1-y30 q1-q3 m2-m12 adults kids y1_sipp-kids_cex if firstsharemw==0, fe cluster(newid)
xtreg tot_inc minwage y1-y30 q1-q3 m2-m12 adults kids y1_sipp-kids_cex if firstsharemw>=0.2 & firstsharemw<., fe cluster(newid)

log close

exit