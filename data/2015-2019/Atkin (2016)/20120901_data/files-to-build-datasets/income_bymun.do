



clear 
set mem 1300m
set matsize 2000
set maxvar 10000



set more off


global censodir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_censo\"
global firmdir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_ss_Stata\"
global workdir="C:\Stata10\"
*local inddir="C:\Documents and Settings\datkin\Desktop\Stata9files\"
*local inddir="C:\Documents and Settings\datkin\Desktop\mexico_ss_Stata\"
local inddir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_ss_Stata\"
global dir="H:\Mexico\"
global dirnet="/n/homeserver2/user2a/datkin/Mexico/"
*global dir="C:\Hdrive\Mexico\"




local edit2=substr("`edit'",11,1)

*-----------------------------------------------





*-----------------------------------------------
*global cutoff=50
*local lcutoff=50

global zone="ZM"



*-----------------------------------------------
global exposure=""
local years="13/20 25/28"
*these are exposure years

*this is where restricted smaple must be made

*variable to rename year
global agestart=23
local ageend=50

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="drop if cenyear==1990"
*these dropvars below may involve geographical info
global dropvar4="drop if muncenso==12 "
global dropvar5="keep if (muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew)"
global dropvar6="`edit'"
*SCHEDIT: global dropvar6="keep if yrschl>5 & yrschl<13 & schatt!=1"
*-----------------------------------------------
local ma=2
*this is the moving average component. For a three period MA - MA=2, for a 1 period, MA=1


noi local lhslist="inctot incearn hhincomepc hhincome"


noi local varlist=""
*noi local varlist="inctot incearn hhincome hhincomepc"
*these variables I find weighted log variances



noi local control = ""
noi local control2 = ""
noi local alwaysif=""
noi local yeartrend="yobexp"
noi local iffy=""
*include if command


local counter=0

*=====================================================







local varlist2 "muncenso sex  cenyear age"


use  `varlist2'  `lhslist' `varlist' wtper muncensoZM  `yeartrend'     using "${workdir}mexico_censo_05_regready${agestart}.dta", clear
local agestart1=${agestart}+1
local ageend1=`ageend'-1
forvalues i = `agestart1'/`ageend' {

append using "${workdir}mexico_censo_05_regready`i'.dta", keep(`varlist2'  `lhslist' `varlist' wtper muncensoZM  `yeartrend')
}




cap replace incearn=. if incearn==99999998 | incearn==99999999
cap gen incearnpurge=incearn if incearn>0 


if "${zone}"=="ZM" {
drop muncenso
rename muncensoZM muncenso
}






sort muncenso
joinby muncenso using "${dir}munworkdatageog.dta", unm(u)

rename muncenso muncensoold
rename muncensonew muncenso

replace wtper=wtper/splitters
/*
sort muncensoold
merge  muncensoold using "${dir}munworkdataoldstates.dta" ,  keep(statenew stateold) nokeep _merge(_mergestate)
*/




foreach varty in `lhslist'  {
gen `varty'2000=`varty' if cenyear==2000
gen `varty'1990=`varty' if cenyear==1990
egen m`varty'2000=wtmean(`varty'2000), by(muncenso) weight(wtper)
egen m`varty'1990=wtmean(`varty'1990), by(muncenso) weight(wtper)
replace `varty'2000=. if `varty'2000==0
replace `varty'1990=. if `varty'1990==0
egen m`varty'2000purg=wtmean(`varty'2000), by(muncenso) weight(wtper)
egen m`varty'1990purg=wtmean(`varty'1990), by(muncenso) weight(wtper)
}


*this section gets average incomes at municipality level for credit constraints usage

keep m*

egen tagmun=tag(muncenso)
keep if tagmun==1
drop tagmun

foreach varty in `lhslist'  {
egen r`varty'2000=rank(m`varty'2000)
egen r`varty'1990=rank(m`varty'1990)
egen r`varty'2000purg=rank(m`varty'2000purg)
egen r`varty'1990purg=rank(m`varty'1990purg)
}



sort muncenso
save "${dir}muncenso_incomeMerge", replace









use  `varlist2'  `lhslist' `varlist' wtper muncensoZM  `yeartrend'     using "${workdir}mexico_censo_05_regready${agestart}.dta", clear
local agestart1=${agestart}+1
local ageend1=`ageend'-1
forvalues i = `agestart1'/`ageend' {

append using "${workdir}mexico_censo_05_regready`i'.dta", keep(`varlist2'  `lhslist' `varlist' wtper muncensoZM  `yeartrend')
}

*note the ages must be changed in this

*drop if munmatch!=1 & muncensoZM>55



cap replace incearn=. if incearn==99999998 | incearn==99999999
cap gen incearnpurge=incearn if incearn>0 


if "${zone}"=="ZM" {
drop muncenso
rename muncensoZM muncenso
}

foreach varty in `lhslist'  {
gen `varty'2000=`varty' if cenyear==2000
gen `varty'1990=`varty' if cenyear==1990
egen m`varty'2000=wtmean(`varty'2000), by(muncenso) weight(wtper)
egen m`varty'1990=wtmean(`varty'1990), by(muncenso) weight(wtper)
replace `varty'2000=. if `varty'2000==0
replace `varty'1990=. if `varty'1990==0
egen m`varty'2000purg=wtmean(`varty'2000), by(muncenso) weight(wtper)
egen m`varty'1990purg=wtmean(`varty'1990), by(muncenso) weight(wtper)
}


*this section gets average incomes at municipality level for credit constraints usage

keep m*

egen tagmun=tag(muncenso)
keep if tagmun==1
drop tagmun

foreach varty in `lhslist'  {
egen r`varty'2000=rank(m`varty'2000)
egen r`varty'1990=rank(m`varty'1990)
egen r`varty'2000purg=rank(m`varty'2000purg)
egen r`varty'1990purg=rank(m`varty'1990purg)
}



sort muncenso
save "${dir}muncenso_incomeZM", replace

