
*the state is a little sketchy as some municipalities when I change them, they change state
*what i have done is taken the original muncenso zm state for the migration drop

*make sure winsor is installed

clear 
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
global tempdir="C:\Scratch\"
global workdir="C:\Data\Mexico\Stata10\"
local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
}


set more off






*foreach edit in "" "keep if yrschl>6"{

*foreach edit in "" {

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
global agestart=8
local ageend=39

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
*SCHEDIT: global dropvar6="keep if yrschl>5 & yrschl<13 & schatt!=1"
*-----------------------------------------------
*local expo=2
*this is how many years I average. So for age 15, with exposure=2, I average 15 and 16
*doesnt work with local. But only have to change weighted average of cohorts

noi local lhslist="dropq10"


noi local varlist="incearn"
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

use  muncenso empstatd  sex mig5mun mig5munZM mgrate5 schatt cenyear age   bplmx  mx00a_imss ind3 ind sector  leftsch educmx  `lhslist' `varlist' wtper muncensoZM  `yeartrend' hrswrk1 urban chdeathrate married chborn hcode  using "${censodir}mexico_censo_05_regready${agestart}.dta", clear
${dropvar1}
${dropvar2}
${dropvar3}


forvalues i = `agestart1'/`ageend' {

append using "${censodir}mexico_censo_05_regready`i'.dta", keep(muncenso empstatd sex mig5mun mig5munZM  mgrate5 schatt cenyear age   bplmx  mx00a_imss ind3 ind sector  leftsch educmx   `lhslist' `varlist' wtper muncensoZM  `yeartrend' hrswrk1 urban chborn chdeathrate hcode married  )
${dropvar1}
${dropvar2}
${dropvar3}


}




*now I take my income etc variables (of various sorts) and get the ready to use 


cap replace incearn=. if incearn==99999998 | incearn==99999999
cap replace inctot=. if inctot==9999997 | inctot==9999998
cap gen incearnln=log(incearn)
cap gen inctotln=log(inctot)

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






#delimit ;
local  lhslistedit `"dropq10"';

local  varlistedit `"incearntrim"';
#delimit cr

noi di "mean list: `lhslistedit'"
noi di "variance list: `varlistedit'"




if "${zone}"=="ZM" {
drop muncenso
rename muncensoZM muncenso
}




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

compress




foreach var in `lhslistedit'   {
gen byte  ecl`var'=.
gen byte  mcl`var'=.
gen byte  fcl`var'=.

gen byte  eclwt`var'=.
gen byte  mclwt`var'=.
gen byte  fclwt`var'=.
}


foreach var in `varlistedit' {
gen byte ecl`var'=.
gen byte  mcl`var'=.
gen byte  fcl`var'=.

gen byte  eclwt`var'=.
gen byte  mclwt`var'=.
gen byte  fclwt`var'=.

gen byte  eclva`var'=.
gen byte  mclva`var'=.
gen byte  fclva`var'=.

gen byte  eclsd`var'=.
gen byte  mclsd`var'=.
gen byte  fclsd`var'=.

gen byte  eclcv`var'=.
gen byte  mclcv`var'=.
gen byte  fclcv`var'=.
}




egen mungroup=group(muncenso)


sort mungroup
save "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta", replace




qui sum mungroup
local munnum=r(max)

noi di "Number of municipalities=`munnum'"
noi di "================================"
noi di "Municipality:"
noi di "================================"_n

forvalues i = 1/`munnum' {
noi di _c"`i' "
use if mungroup==`i' using "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta", clear




foreach var in `lhslistedit'  {
forvalues j = `agestart1'/`ageend1' {

summarize `var' [w=wtper] if age==`j'
replace ecl`var' = r(mean) if age==`j'
replace eclwt`var' = r(sum_w) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==1
replace mcl`var' = r(mean) if age==`j' 
replace mclwt`var' = r(sum_w) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==2
replace fcl`var' = r(mean) if age==`j' 
replace fclwt`var' = r(sum_w) if age==`j'

}
}


foreach var in `varlistedit' {
forvalues j = `agestart1'/`ageend1' {

summarize `var' [w=wtper] if age==`j'
replace ecl`var' = r(mean) if age==`j'
replace eclwt`var' = r(sum_w) if age==`j'
replace eclva`var' = r(Var) if age==`j'
replace eclsd`var' = r(sd) if age==`j'
replace eclcv`var' = r(sd)/r(mean) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==1
replace mcl`var' = r(mean) if age==`j' 
replace mclwt`var' = r(sum_w) if age==`j'
replace mclva`var' = r(Var) if age==`j'
replace mclsd`var' = r(sd) if age==`j'
replace mclcv`var' = r(sd)/r(mean) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==2
replace fcl`var' = r(mean) if age==`j' 
replace fclwt`var' = r(sum_w) if age==`j'
replace fclva`var' = r(Var) if age==`j'
replace fclsd`var' = r(sd) if age==`j'
replace fclcv`var' = r(sd)/r(mean) if age==`j'

}
}










keep muncenso mungroup age yobexp ecl*  mcl* fcl*

egen tagmunage=tag( muncenso age )
keep if tagmunage==1

drop tagmunage

save "${tempdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta", replace

}
*from i
noi di _n"================================"











use "${tempdir}regtempcohortusingmw${munwork}_`cenyear'1.dta", clear
forvalues i = 2/`munnum' {
append using "${tempdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta"
erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta"
}



noi di _n"========================="
noi di "Append Complete"
noi di "========================="








sort muncenso yobexp

save "${workdir}cohortmeans_newdrops_mw${munwork}_`cenyear'.dta", replace


erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'1.dta"
cap erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta"

}



