* TABLE 11
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

clear
set mem 50m
set matsize 1000
set more off
local root="results"

* Parameters for bootstrap replications
set seed 1
global r = 500

********************************************************************************************************
global regnumber=1
local outpath="`root'"+"/table11"

* --- Column 1 ---------------------------------------
use data, clear
keep if uvvar==1
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
global var1 = "expsales Exports_high1"
global instruments = "sharebrazil1_* avgerate"
global var2 = "lsales"
global var3 = "i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 2 ---------------------------------------
use data, clear
keep if uvvar==0
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 3 ---------------------------------------
use data, clear
drop if tc_p75==0
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 4 ---------------------------------------
use data, clear
drop if tc_p75==1
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 5 ---------------------------------------
use data, clear
keep if uvvar==1 & tc_p75==1
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 6 ---------------------------------------
use data, clear
keep if uvvar==1 & tc_p75==0
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
qui do _boot

global dependent = "skillp"
qui do _boot

outsheet using `outpath'.csv, comma replace
********************************************************************************************************
clear
capture erase maindata.dta
capture erase tempg.dta
capture erase chart.dta
