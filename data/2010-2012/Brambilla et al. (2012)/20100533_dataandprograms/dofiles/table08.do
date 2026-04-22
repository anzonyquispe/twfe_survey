* TABLE 8
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
local outpath="`root'"+"/table8"
global regnumber=1

global var1 = "expsales Exports_high2"
global instruments = "sharebrazil1_* avgerate"

* --- Panel A ----------------------------------------
global dependent = "lwage"
* Column 1
global var2=""
global var3="i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot
* Column 2
global var3="i.year*i.isicmain trend3 trend1"
qui do _boot
* Column 3
global var2="lsales"
global var3="i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot

* --- Panel A ----------------------------------------
global dependent = "skillp"
* Column 1
global var2=""
global var3="i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot
* Column 2
global var3="i.year*i.isicmain trend3 trend1"
qui do _boot
* Column 3
global var2="lsales"
global var3="i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot

outsheet using `outpath'.csv, comma replace
********************************************************************************************************
clear
capture erase maindata.dta
capture erase tempg.dta
capture erase chart.dta
