* TABLE 10
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

clear
set mem 50m
set matsize 1000
set more off
local root="results"

* Prepare data for bootstrap replications for standard errors
set seed 1
global r = 500
use data, clear
sort firmid
save maindata, replace
bys firmid: drop if _n>1
keep firmid
sort firmid
save tempg, replace

********************************************************************************************************
local outpath="`root'"+"/table10"
global regnumber=1

global dependent = "lwage"
global var1 = "expsales Exports_high1"
global instruments = "sharebrazil1_* avgerate"

* Column1
global var2 = "skillp"
global var3 = "i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot
* Column 2
global var3 = "i.year*i.isicmain trend1 trend3"
qui do _boot
* Column 3
global var2 = "skillp lsales"
global var3 = "i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot



outsheet using `outpath'.csv, comma replace
********************************************************************************************************
clear
capture erase maindata.dta
capture erase tempg.dta
capture erase chart.dta
