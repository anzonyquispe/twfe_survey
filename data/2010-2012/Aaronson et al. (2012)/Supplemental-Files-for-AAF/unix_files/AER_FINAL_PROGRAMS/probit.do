******************************************************************
* Program to Estimate Probability of Being a Minimum Wage Worker *
******************************************************************

clear all
set more off
set mem 1g


use mar_probit.dta
su

* PCE *
 gen pce = .
 replace pce=0.8204 if year == 1995
 replace pce=0.8383 if year == 1996
 replace pce=0.8539 if year == 1997
 replace pce=0.8621 if year == 1998
 replace pce=0.8760 if year == 1999
 replace pce=0.8978 if year == 2000
 replace pce=0.9149 if year == 2001
 replace pce=0.9274 if year == 2002
 replace pce=0.9462 if year == 2003
 replace pce=0.9710 if year == 2004
 replace pce=1.0000 if year == 2005
 replace pce=1.0275 if year == 2006
 replace pce=1.0550 if year == 2007
 replace pce=1.0903 if year == 2008

 gen incwag_nominal = incwag
 replace incwag = incwag / pce
 
* Sample Restrictions *
keep if age>=21 & age<=64
keep if hrslyr>=30
keep if ernsrc==1 | ernsrc==0 // Wages from "Wage and salary"
keep if incwag>=2000 & incwag<=100000

* Generate Covariates
gen age2 = age*age
gen age3 = age2*age
gen age4 = age3*age

gen annearn = ln(incwag) - 7
gen annearn2 = annearn*annearn
gen annearn3 = annearn2*annearn
gen annearn4 = annearn3*annearn

gen age_wage  = age*annearn
gen age_wage2 = age_wage*annearn
gen age_wage3 = age_wage2*annearn
gen age_wage4 = age_wage3*annearn


gen female_married = female*married

gen hrlywg_im = incwag/(hrslyr*wkslyr) // This should equal hrlwg
su hrlywg hrlywg_im 

* Convert State Codes to FIPS *
gen state_fips = .
replace state_fips = 1 if state==63
replace state_fips = 2 if state==94
replace state_fips = 4 if state==86 
replace state_fips = 5 if state==71
replace state_fips = 6 if state==93
replace state_fips = 8 if state==84 
replace state_fips = 9 if state==16
replace state_fips = 10 if state==51
replace state_fips = 11 if state==53
replace state_fips = 12 if state==59
replace state_fips = 13 if state==58
replace state_fips = 15 if state==95
replace state_fips = 16 if state==82 
replace state_fips = 17 if state==33
replace state_fips = 18 if state==32
replace state_fips = 19 if state==42
replace state_fips = 20 if state==47
replace state_fips = 21 if state==61
replace state_fips = 22 if state==72
replace state_fips = 23 if state==11
replace state_fips = 24 if state==52
replace state_fips = 25 if state==14
replace state_fips = 26 if state==34
replace state_fips = 27 if state==41
replace state_fips = 28 if state==64
replace state_fips = 29 if state==43
replace state_fips = 30 if state==81
replace state_fips = 31 if state==46
replace state_fips = 32 if state==88 
replace state_fips = 33 if state==12
replace state_fips = 34 if state==22
replace state_fips = 35 if state==85 
replace state_fips = 36 if state==21
replace state_fips = 37 if state==56
replace state_fips = 38 if state==44
replace state_fips = 39 if state==31
replace state_fips = 40 if state==73
replace state_fips = 41 if state==92
replace state_fips = 42 if state==23
replace state_fips = 44 if state==15
replace state_fips = 45 if state==57
replace state_fips = 46 if state==45
replace state_fips = 47 if state==62
replace state_fips = 48 if state==74
replace state_fips = 49 if state==87
replace state_fips = 50 if state==13
replace state_fips = 51 if state==54
replace state_fips = 53 if state==91
replace state_fips = 54 if state==55
replace state_fips = 55 if state==35
replace state_fips = 56 if state==83 
drop state
ren state_fips state

gen month = 3 

sort state year month
merge state year month using mw7909a.dta, keep(minwage)
tab _merge
keep if _merge==3
drop _merge
drop if minwage==. | hrlywg==.
drop if (hrlywg_im<= 0.6*minwage) | (hrlywg_im>40*minwage & hrlywg_im~=.)

gen minearner = .
replace minearner = 1 if .6*minwage < hrlywg & hrlywg<=1.2*minwage
replace minearner = 0 if hrlywg>1.2*minwage & hrlywg~=.

su hrlywg minwage if minearner==1
su hrlywg minwage if minearner==0

su minearner if incwag<10000
su minearner if incwag>=10000 & incwag<.

su minearner age age2 age3 age4 annearn annearn2 annearn3 annearn4 age_wage age_wage2 age_wage3 age_wage4 female married female_married

save probit_samp.dta, replace

version 10: probit minearner age age2 age3 age4 annearn annearn2 annearn3 annearn4 age_wage age_wage2 age_wage3 age_wage4 female married female_married  [w=wgt]

exit