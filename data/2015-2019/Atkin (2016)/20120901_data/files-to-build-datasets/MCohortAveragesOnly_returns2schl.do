
*this file generates retrurns to schooling at teh cohort level to see how these changed over time


*the state is a little sketchy as some municipalities when I change them, they change state
*what i have done is taken the original muncenso zm state for the migration drop

*make sure winsor is installed

clear all
set mem 7000m
set matsize 10000
set maxvar 10000



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
local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
}


set more off








local cenyear=2000
*this should be changed to 2006 if want the 2005 survey data
local yearend=1999
*if my firm data goes beyond this, change here to 2005

local edit2=substr("`edit'",11,1)

*-----------------------------------------------





*-----------------------------------------------
*global cutoff=50
*local lcutoff=50

global zone="ZM"
global munwork="yes"


*-----------------------------------------------
global exposure=""
*local years="7 9 11 13 15 16 18"
*local years="15 16"
*these are exposure years

*note the censo data is done on a year by year cohort basis so this is irrelevant here





*this is where restricted smaple must be made

*variable to rename year
global agestart=14
local ageend=40

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="keep if cenyear==`cenyear'"
*these dropvars below may involve geographical info

global dropvar4=""
*global dropvar4="drop if muncenso==12 "
*mexico city drop

if "${munwork}"=="yes" & `cenyear'==2000 {
global dropvar5="keep if (muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew)"
}
else if "${munwork}"=="no" & `cenyear'==2000 {
global dropvar5="keep if muncenso==mig5mun${zone} & bplmx==state"
}
else {
global dropvar5="keep if mgrate5==10"
}


global dropvar6="`edit'"
*-----------------------------------------------
*local expo=2
*this is how many years I average. So for age 15, with exposure=2, I average 15 and 16
*doesnt work with local. But only have to change weighted average of cohorts

noi local lhslist="yrschl2 yrschl drop7 drop10 drop13 sector3"


noi local varlist="incearn inctot hhincomepc hhincome"
*these variables I find weighted log variances



noi local control = ""
noi local control2 = ""
noi local alwaysif=""
noi local yeartrend="yobexp"
noi local iffy=""
*include if command


local counter=0
local agestart1=${agestart}+1
local ageend1=`ageend'-1
*=====================================================







qui {




*this code brings in the regready stuff and gets cohort averages

use  muncenso empstatd  sex mig5mun mig5munZM mgrate5 schatt cenyear age   bplmx  mx00a_imss ind3 sector  leftsch educmx  `lhslist' `varlist' wtper muncensoZM  `yeartrend' hrswrk1 urban chdeathrate married chborn  using "${censodir}mexico_censo_05_regready${agestart}.dta", clear

forvalues i = `agestart1'/`ageend' {

append using "${censodir}mexico_censo_05_regready`i'.dta", keep(muncenso empstatd sex mig5mun mig5munZM  mgrate5 schatt cenyear age   bplmx  mx00a_imss ind3 sector  leftsch educmx   `lhslist' `varlist' wtper muncensoZM  `yeartrend' hrswrk1 urban chborn chdeathrate married  )
}




*now I take my income etc variables (of various sorts) and get the ready to use 



cap replace incearn=. if incearn==99999998 | incearn==99999999
cap replace inctot=. if inctot==9999997 | inctot==9999998
cap gen incearnln=log(incearn)
cap gen inctotln=log(inctot)


replace hrswrk1=. if hrswrk1>990

cap gen incearnlnhrs=incearnln if hrswrk1>20 & hrswrk1!=.
cap gen incworklnhrs=incearnln if hrswrk1>20 & hrswrk1!=. & (empstatd==120 | empstatd==110)
*these are my prefferred measure for people working more than 20 hours a week, and people in employment

cap gen incearnlnhrs2=incearnln if hrswrk1>20 & hrswrk1<80
cap gen incworklnhrs2=incearnln if hrswrk1>20 & hrswrk1<80 & (empstatd==120 | empstatd==110)
*these are my prefferred measure for people working more than 20 hours a week, and people in employment

cap gen incearnlnwage2=log(incearn/hrswrk1) if hrswrk1>20 & hrswrk1<80
cap gen incworklnwage2=log(incearn/hrswrk1) if hrswrk1>20 & hrswrk1<80 & (empstatd==120 | empstatd==110)
*these are my prefferred measure for people working more than 20 hours a week, and people in employment

cap gen incearnlnwage=log(incearn/hrswrk1) 
cap gen incworklnwage=log(incearn/hrswrk1) if   (empstatd==120 | empstatd==110)
*these are my prefferred measure for people working more than 20 hours a week, and people in employment

foreach var of varlist incearn* incwork* inctot* {
winsor `var', gen(`var'win) p(0.01)
winsor `var', gen(`var'winz) p(0.05)
}

cap gen incearntrim=incearn
sum incearn if  incearn>0 & incearn< 99999998 & (empstatd==120 | empstatd==110)  & age>15 & age<56, d
cap replace incearntrim=r(p99) if incearn>r(p99)
cap gen incearntriml=log(incearntrim)
*this is the 99th percentile from sum incearn if cenyear==2000 & incearn>0 & incearn< 99999998, d
*this trims the top at the 99th percentile and replaces it with p99 value

cap gen incworktriml=incearntrim if (empstatd==120 | empstatd==110)
cap replace incworktriml=log(incworktriml) 
*this drops those not at work

cap replace incearntrim=. if schatt==1
*drops those also at school



cap gen hhincomepcln=log(hhincomepc)
cap winsor hhincomepcln, gen(hhincomepclnwin) p(0.01)
*now get get household income per capita


cap gen hhincomeln=log(hhincome)
cap winsor hhincomeln, gen(hhincomelnwin) p(0.01)
*now get get household income 


cap gen yrschlp6=yrschl if yrschl>6
cap gen yrschlp9=yrschl if yrschl>9
cap gen yrschl2fin=yrschl2
cap replace yrschl2fin=. if schatt==1 & yrschl<=12



gen sectorind=sector3
*this is proportion of cohort in manufacturing
*1 is all, 0 is none
gen sectorindform=sector3
replace sectorindform=0 if  mx00a_imss!=1
*this is proportion of cohort in formal sector manufacturing, *1 is all, 0 is none

gen propind=sector3
replace propind=. if sector==0
*this is proportion of employed cohort in manufacturing
*1 is all, 0 is none

gen propindform=sector3
replace propindform=. if sector==0
replace propindform=. if  mx00a_imss!=1
*this is proportion of formal sector jobs in manufacturing among employed cohort

gen posearn=incearn
replace posearn=1 if incearn>0 & incearn!=.
*this is proportion of population earning wages. 1 is all.





gen employ=1 if  empstatd>=100 &  empstatd<134
replace employ=0 if  (empstatd>=200 &  empstatd<330) | empstatd==380
*this is whether or not employed (excluding those at school according to empstatd-some of these guys are at school according to school)

gen employns=employ
replace employns=. if schatt==0
*this is whether or not employed (excluding those at school according to schatt)


gen leftfin=0 if (leftsch>0 & leftsch<43) | (leftsch>43 & leftsch<48)
replace leftfin=1 if leftsch==20
*this is proportion who say reason for leaving school is financial considerations

gen proptech=0 if (educmx>200 & educmx<230) | (educmx>300 & educmx<390)
replace proptech=1 if (educmx>200 & educmx<220) | (educmx>300 & educmx<320)
*this is proportion of people whose attainment is secondary school (lower or upper) who take tech track as opposed to general track.


local wagelist "incearnln inctotln inctotlnwin inctotlnwinz incearnlnhrs incworklnhrs incearnlnhrswin incworklnhrswin incearnlnhrswinz incworklnhrswinz  incearntriml incworktriml incearnlnwage2win incearnlnwage2winz incearnlnwagewin incearnlnwagewinz incworklnwage2win incworklnwage2winz incworklnwagewin incworklnwagewinz"
local wagelistns "incearnlnns inctotlnns inctotlnwinns inctotlnwinzns incearnlnhrsns incworklnhrsns incearnlnhrswinns incworklnhrswinns incearnlnhrswinzns incworklnhrswinzns incearntrimlns incworktrimlns incearnlnwage2winns incearnlnwage2winzns incearnlnwagewinns incearnlnwagewinzns incworklnwage2winns incworklnwage2winzns incworklnwagewinns incworklnwagewinzns"
local wagelist612 "incearnln612 inctotln612 inctotlnwin612 inctotlnwinz612 incearnlnhrs612 incworklnhrs612 incearnlnhrswin612 incworklnhrswin612 incearnlnhrswinz612 incworklnhrswinz612 incearntriml612 incworktriml612 incearnlnwage2win612 incearnlnwage2winz612 incearnlnwagewin612 incearnlnwagewinz612 incworklnwage2win612 incworklnwage2winz612 incworklnwagewin612 incworklnwagewinz612"



foreach vars in `wagelist' {
gen `vars'ns=`vars' if schatt==0
gen `vars'612=`vars' if yrschl>=6 & yrschl<=12
}


local  lhslistedit "yrschl2 yrschl yrschl2fin"
*local  varlistedit "incearnlnwage2 incearnlnwage incearnlnhrs incworklnhrs incearnlnhrswin incworklnhrswin incearntriml incworktriml incearnlnhrsns incworklnhrsns incearnlnhrswinns incworklnhrswinns incearntrimlns incworktrimlns incearnlnhrs612 incworklnhrs612 incearnlnhrswin612 incworklnhrswin612 incearntriml612 incworktriml612"

local  varlistedit "`wagelist' `wagelistms' `wagelist612'"





if "${zone}"=="ZM" {
drop muncenso
rename muncensoZM muncenso
}

${dropvar1}
${dropvar2}
${dropvar3}



*if I want to run it without my munwork merges I need to cut out this bit, and change the migration drop above to not include the munwork municipalities

if "${munwork}"=="yes" {
sort muncenso
joinby muncenso using "${dir}munworkdatageog.dta", unm(u)

rename muncenso muncensoold
rename muncensonew muncenso



sort muncensoold
merge  muncensoold using "${dir}munworkdataoldstates.dta" ,  keep(statenew stateold) nokeep _merge(_mergestate)



sort muncenso
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(*munpop15_49* state splitters regio*) nokeep _merge(_merge10)



sort mig5munZM
merge mig5munZM using "${dir}munworkdatamig5mun.dta", nokeep _merge(_mergemigm)
rename mig5munZM mig5munZMold
rename mig5munZMnew mig5munZM


replace wtper=wtper/splitters if splitters==2
drop _mergestate
}
else {
sort muncenso
merge  muncenso using "${dir}mungeog${zone}.dta" ,  keep(state) nokeep _merge(_merge10)
}












${dropvar4}
noi count
${dropvar5}
noi count
${dropvar6}



keep muncenso age sex yobexp wtper  `lhslistedit' `varlistedit'

* to run without splitters should drop them here







foreach var in `varlistedit' {
gen eclrs`var'=.
gen mclrs`var'=.
gen fclrs`var'=.

gen eclwtrs`var'=.
gen mclwtrs`var'=.
gen fclwtrs`var'=.


}



egen mungroup=group(muncenso)


sort mungroup
save "${workdir}regtempcohortusingmw${munwork}_`cenyear'.dta", replace




*now run by municipality


qui sum mungroup
local munnum=r(max)

noi di "Number of municipalities=`munnum'"
noi di "================================"
noi di "Municipality:"
noi di "================================"_n

forvalues i = 1/`munnum' {
noi di _c"`i' "
use if mungroup==`i' using "${workdir}regtempcohortusingmw${munwork}_`cenyear'.dta", clear




foreach var in `varlistedit'  {
forvalues j = `agestart1'/`ageend1' {

cap {
reg `var' yrschl i.sex [w=wtper] if age==`j'
replace eclrs`var' = _b[yrschl] if age==`j'
sum wtper if e(sample)==1
replace eclwtrs`var' = r(sum) if age==`j'
}

cap {
reg `var' yrschl i.sex [w=wtper] if age==`j' & sex==1
replace mclrs`var' = _b[yrschl] if age==`j' 
sum wtper if e(sample)==1
replace mclwtrs`var' = r(sum) if age==`j'
}

cap {
reg `var' yrschl i.sex [w=wtper] if age==`j' & sex==2
replace fclrs`var' = _b[yrschl] if age==`j' 
sum wtper if e(sample)==1
replace fclwtrs`var' = r(sum) if age==`j'
}

}
}










keep muncenso mungroup age yobexp ecl*  mcl* fcl*

egen tagmunage=tag( muncenso age )
keep if tagmunage==1

drop tagmunage

save "${workdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta", replace

}
*from i
noi di _n"================================"











use "${workdir}regtempcohortusingmw${munwork}_`cenyear'1.dta", clear
forvalues i = 2/`munnum' {
append using "${workdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta"
erase "${workdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta"
}



noi di _n"========================="
noi di "Append Complete"
noi di "========================="


erase "${workdir}regtempcohortusingmw${munwork}_`cenyear'1.dta"
erase "${workdir}regtempcohortusingmw${munwork}_`cenyear'.dta"

*do some renaming as these names get too long
renvars *, sub(wage w)
cap renvars *rsincearnlnhrswinz612 *rsincworklnhrswinz612, sub(hrs h)

sort muncenso yobexp

save "${workdir}cohortmeans_returns2school_mw${munwork}_`cenyear'.dta", replace


}

*end of qui
