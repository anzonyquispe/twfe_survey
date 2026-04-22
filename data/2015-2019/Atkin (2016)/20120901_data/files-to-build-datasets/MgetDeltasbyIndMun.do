clear matrix
clear all
clear 
set mem 2000m
set matsize 10000
set maxvar 32767

if "`c(os)'"=="Unix" {
global censodir="/home/fac/da334/Data/Mexico/mexico_censo/"
global firmdir="/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global dir="/home/fac/da334/Work/Mexico/"
global workdir="/home/fac/da334/Data/Mexico/Stata10/"
global dirnet="/home/fac/da334/Work/Mexico/"
}

if "`c(os)'"=="Windows" {
global censodir="C:\Data\Mexico\mexico_censo\"
global firmdir="C:\Data\Mexico\mexico_ss_Stata\"
global workdir="C:\Data\Mexico\Stata10\"
*local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
global dircode="C:/Work/Mexico/Revision/New_code/"
global dirrev="C:/Work/Mexico/Revision/regout/"
global scratch "C:\Scratch\"
}

set more off



***************************first pull by municipality


use age yobexp muncenso state q16demp50*cp q16demp00*cp using "${workdir}reg2year_mwyes_2000_july11_genericskill_alt16_cen90_1yrexp.dta", clear


xtset muncenso yobexp



local mpop "cp"
local aget "16"




foreach ind of numlist 10/60  { 


cap d q`aget'demp50`ind'`mpop'

if _rc==0 {

noi di "Industry:`ind'"

foreach geog in muncenso {
qui levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50`ind'`mpop'  q`aget'demp00`ind'`mpop' {
gen da`geocode'_`indy'=.
gen da`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if `geog'==`mun'
cap replace da`geocode'_`indy'=_b[l.`indy'] if  `geog'==`mun'
cap replace da`geocode't_`indy'=da`geocode'_`indy'
cap replace da`geocode't_`indy'=1 if  da`geocode'_`indy'!=. & da`geocode'_`indy'>1
cap replace da`geocode't_`indy'=0 if  da`geocode'_`indy'!=. & da`geocode'_`indy'<0
}
noi di "`indy' `geog' done"
}
}



foreach geog in state  {
qui levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in  q`aget'demp50`ind'`mpop'  q`aget'demp00`ind'`mpop' {
gen da`geocode'_`indy'=.
gen da`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if `geog'==`mun'
cap replace da`geocode'_`indy'=_b[l.`indy'] if  `geog'==`mun'
cap replace da`geocode't_`indy'=da`geocode'_`indy'
cap replace da`geocode't_`indy'=1 if  da`geocode'_`indy'!=. & da`geocode'_`indy'>1
cap replace da`geocode't_`indy'=0 if  da`geocode'_`indy'!=. & da`geocode'_`indy'<0
}
noi di "`indy' `geog' done"
}
}




foreach geog in state  {
qui levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50`ind'`mpop'  q`aget'demp00`ind'`mpop' {
gen di`geocode'_`indy'=.
gen di`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if yobexp<1975 & `geog'==`mun'  
cap replace di`geocode'_`indy'=_b[l.`indy']  if `geog'==`mun' 
cap replace di`geocode't_`indy'=di`geocode'_`indy'
cap replace di`geocode't_`indy'=1 if  di`geocode'_`indy'!=. & di`geocode'_`indy'>1
cap replace di`geocode't_`indy'=0 if  di`geocode'_`indy'!=. & di`geocode'_`indy'<0
}

noi di "`indy' `geog' done"
}
}




foreach geog in  muncenso {
qui levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50`ind'`mpop'  q`aget'demp00`ind'`mpop' {
gen di`geocode'_`indy'=.
gen di`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if yobexp<1975 & `geog'==`mun'  
cap replace di`geocode'_`indy'=_b[l.`indy']  if `geog'==`mun' 
cap replace di`geocode't_`indy'=di`geocode'_`indy'
cap replace di`geocode't_`indy'=1 if  di`geocode'_`indy'!=. & di`geocode'_`indy'>1
cap replace di`geocode't_`indy'=0 if  di`geocode'_`indy'!=. & di`geocode'_`indy'<0
}
noi di "`indy' `geog' done"
}
}

}

}





keep if yobexp==1975
keep muncenso state da* di* 
save "${dir}/Revision/delta_by_mun.dta", replace


pause on
pause here














******************************now by 3 digit industy


*pulls in from 

use "${scratch}temprawdelta.dta", clear

qui {
forval n=340/350 {

cap d deltaemp50`n'
if _rc==0 {
noi di _c "`n'"


foreach cutz in "00" "50"  {

noi mvencode deltaemp`cutz'`n' if year>=1986 & year<=1999, mv(0) override
foreach geog in muncenso state {

levelsof `geog', local(munlist)
local geocode=substr("`geog'",1,1)

gen da`geocode'`cutz'_`n'=.
gen da`geocode'`cutz't_`n'=.

gen di`geocode'`cutz'_`n'=.
gen di`geocode'`cutz't_`n'=.

gen dt`geocode'`cutz'_`n'=.
gen dt`geocode'`cutz't_`n'=.

gen du`geocode'`cutz'_`n'=.
gen du`geocode'`cutz't_`n'=.

foreach mun of local munlist {
reg deltaemp`cutz'`n' l.deltaemp`cutz'`n' if `geog'==`mun'
replace da`geocode'`cutz'_`n'=_b[l.deltaemp`cutz'`n'] if  `geog'==`mun'
replace da`geocode'`cutz't_`n'=da`geocode'`cutz'_`n'
replace da`geocode'`cutz't_`n'=1 if  da`geocode'`cutz'_`n'!=. & da`geocode'`cutz'_`n'>1
replace da`geocode'`cutz't_`n'=0 if  da`geocode'`cutz'_`n'!=. & da`geocode'`cutz'_`n'<0
reg deltaemp`cutz'`n' l.deltaemp`cutz'`n' if year<1990 & `geog'==`mun'
replace di`geocode'`cutz'_`n'=_b[l.deltaemp`cutz'`n'] if  `geog'==`mun'
replace di`geocode'`cutz't_`n'=di`geocode'`cutz'_`n'
replace di`geocode'`cutz't_`n'=1 if  di`geocode'`cutz'_`n'!=. & di`geocode'`cutz'_`n'>1
replace di`geocode'`cutz't_`n'=0 if  di`geocode'`cutz'_`n'!=. & di`geocode'`cutz'_`n'<0


reg deltaemp`cutz'`n' l1.deltaemp`cutz'`n' l2.deltaemp`cutz'`n' l3.deltaemp`cutz'`n' if `geog'==`mun'
replace dt`geocode'`cutz'_`n'=_b[l1.deltaemp`cutz'`n']+_b[l2.deltaemp`cutz'`n']+_b[l3.deltaemp`cutz'`n'] if  `geog'==`mun'
replace dt`geocode'`cutz't_`n'=dt`geocode'`cutz'_`n'
replace dt`geocode'`cutz't_`n'=1 if  dt`geocode'`cutz'_`n'!=. & dt`geocode'`cutz'_`n'>1
replace dt`geocode'`cutz't_`n'=0 if  dt`geocode'`cutz'_`n'!=. & dt`geocode'`cutz'_`n'<0

replace du`geocode'`cutz'_`n'=_b[l3.deltaemp`cutz'`n'] if  `geog'==`mun'
replace du`geocode'`cutz't_`n'=du`geocode'`cutz'_`n'
replace du`geocode'`cutz't_`n'=1 if  du`geocode'`cutz'_`n'!=. & du`geocode'`cutz'_`n'>1
replace du`geocode'`cutz't_`n'=0 if  du`geocode'`cutz'_`n'!=. & du`geocode'`cutz'_`n'<0

}

}
}

preserve
keep if year==1995
keep muncenso state da* di* du* dt*
save "${scratch}delta_byind`n'.dta", replace
restore


}
}
}


pause on
pause ready to merge

use  "${scratch}delta_byind110.dta", clear
forval n=111/999 {

cap merge 1:1 muncenso using "${scratch}delta_byind`n'.dta", generate(_merge666)
cap drop _merge666
}

foreach var of varlist da* di* {
gen c`var'=`var'^3
}

renpfix cda db
renpfix cdi dj

save  "${dir}/Revision/delta_by_mun_ind.dta", replace

die here
