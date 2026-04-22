* TABLE 5
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

clear
set mem 50m
set matsize 1000
set more off
local root="results"
local opt="excel bracket se nocons nonotes"

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
* -- PANEL A
********************************************************************************************************
use maindata, clear
global regnumber=1
local outpath="`root'"+"/table5a"

global dependent = "lwage"
global var1 = "expsales Exports_high1"
global instruments = "sharebrazil1_* avgerate"

* Column 1
global var2 = ""
global var3 = ""
qui do _boot
* Column 2
global var3 = "i.year*i.isicmain"
qui do _boot
* Column 3
global var3 = "i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot
* Column 4
global var3 = "i.year*i.isicmain trend1 trend3"
qui do _boot
* Column 5
global var2 = "lsales"
global var3 = "i.year*i.isicmain trend2a trend2b trend4a trend4b"
qui do _boot

outsheet using `outpath'.csv, comma replace

* Column 6
use maindata, clear
qui xi: xtreg $dependent $var1 $var2 $var3, fe i(firmid) robust
outreg2 $var1 $var2 using results/table5_fe, replace `opt'
* Column 7
qui xi: xtreg $dependent $var1 $var2 $var3 if year~=1999, fe i(firmid) robust
outreg2 $var1 $var2 using results/table5_fe, append `opt'

********************************************************************************************************
* --PANEL B1
********************************************************************************************************
local outpath="`root'"+"/table5b.xls"
global dependent="Exports_high1"

use maindata, clear
qui xi: xtivreg lwage (expsales Exports_high1 lsales = $instruments lsales), fe i(firmid)
keep if e(sample)==1

* Column 1
qui xi: xtreg $dependent $instruments, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', replace `opt' addstat("p-value", `r')
* Column 2
qui xi: xtreg $dependent $instruments i.year*i.isicmain, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 3
qui xi: xtreg $dependent $instruments i.year*i.isicmain trend2a trend2b trend4a trend4b, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 4
qui xi: xtreg $dependent $instruments i.year*i.isicmain trend1 trend3, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 5
qui xi: xtreg $dependent $instruments lsales i.year*i.isicmain trend2a trend2b trend4a trend4b, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments lsales using `outpath', append `opt' addstat("p-value", `r')

********************************************************************************************************
* --PANEL B2
********************************************************************************************************
global dependent="expsales"

use maindata, clear
qui xi: xtivreg lwage (expsales Exports_high1 lsales = $instruments lsales), fe i(firmid)
keep if e(sample)==1

* Column 1
qui xi: xtreg $dependent $instruments, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 2
qui xi: xtreg $dependent $instruments i.year*i.isicmain, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 3
qui xi: xtreg $dependent $instruments i.year*i.isicmain trend2a trend2b trend4a trend4b, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 4
qui xi: xtreg $dependent $instruments i.year*i.isicmain trend1 trend3, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments using `outpath', append `opt' addstat("p-value", `r')
* Column 5
qui xi: xtreg $dependent $instruments lsales i.year*i.isicmain trend2a trend2b trend4a trend4b, fe i(firmid) robust
testparm $instruments
local r=r(p)
outreg2 $instruments lsales using `outpath', append `opt' addstat("p-value", `r')

********************************************************************************************************

capture erase maindata.dta
capture erase tempg.dta
capture erase chart.dta
capture erase table5b.txt
clear
