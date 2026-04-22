* TABLE 9
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
local outpath="`root'"+"/table09"
global regnumber=1

* --- Column 1 -----------------------------------
use data, clear
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
global var1 = "expsales Sales_high1"
global instruments = "sharebrazil1_* avgerate"
global var2 = "lsales"
global var3 = "i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 2 -----------------------------------
use data, clear
drop if increased==0
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

* --- Column 3 -----------------------------------
use data, clear
drop if increased==1
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

* --- Column 4 -----------------------------------
use data, clear
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
global var1 = "expsales"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 5 -----------------------------------
use data, clear
gen High=(Exports_high1>0)
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace
 
global dependent = "lwage"
global var1 = "exporter"
global instruments = "avgerate"
qui do _boot

global dependent = "skillp"
qui do _boot

* --- Column 6 -----------------------------------
global dependent = "lwage"
global var1 = "exporter High"
global instruments = "sharebrazil1_* avgerate"
qui do _boot

global dependent = "skillp"
qui do _boot

outsheet using `outpath'.csv, comma replace
********************************************************************************************************
clear
capture erase maindata.dta
capture erase tempg.dta
capture erase chart.dta
