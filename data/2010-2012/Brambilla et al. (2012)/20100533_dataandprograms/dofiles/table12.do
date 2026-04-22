* TABLE 12
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
local outpath="`root'"+"/table12"

* --- Column 1 -----------------------------------------
use data, clear
drop if spanish==1 & Exports_high1>0
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

* --- Column 2 -----------------------------------------
use data, clear
drop if spanish==0 & Exports_high1>0
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

* --- Column 3 -----------------------------------------
use data, clear
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace

use maindata, clear
global dependent = "lwage"
global var2 = "Exports_lang2 lsales"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 4 -----------------------------------------
global dependent = "lwage"
global var2 = "Exports_southam2 lsales"
qui do _boot

global dependent = "skillp"
qui do _boot

outsheet using `outpath'.csv, comma replace

********************************************************************************************************
clear
capture erase maindata.dta
capture erase tempg.dta
capture erase chart.dta
