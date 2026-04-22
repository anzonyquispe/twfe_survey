* TABLE 2
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

clear
set mem 50m
set more off
local root="results"
local opt="comma bracket se nocons nonotes"

local outpath="`root'"+"/table2.xls"

********************************************************************************************************
qui {
use data, clear

* PANEL A
xi: reg lwage expsales i.year i.isicmain, cluster(firmid)
outreg2 expsales using `outpath', replace `opt' ctitle(Wage) addnote(Regressions include industry and year effects) title(OLS Regressions)

xi: reg lwage Exports_high1 i.year i.isicmain, cluster(firmid)
outreg2 Exports_high1 using `outpath', append `opt' ctitle(Wage)

xi: reg lwage Exports_high1 expsales i.year i.isicmain, cluster(firmid)
outreg2 expsales Exports_high1 using `outpath', append `opt' ctitle(Wage)

* PANEL B
xi: reg skillp expsales i.year i.isicmain, cluster(firmid)
outreg2 expsales using `outpath', append `opt' ctitle(Sharenonprod)

xi: reg skillp Exports_high1 i.year i.isicmain, cluster(firmid)
outreg2 Exports_high1 using `outpath', append `opt' ctitle(Sharenonprod)

xi: reg skillp Exports_high1 expsales i.year i.isicmain, cluster(firmid)
outreg2 expsales Exports_high1 using `outpath', append `opt' ctitle(Sharenonprod)
}
clear
********************************************************************************************************
