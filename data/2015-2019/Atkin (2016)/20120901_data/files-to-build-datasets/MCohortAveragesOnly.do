*this file takes the the census data from IPUMSI and calculates averages by muni-cohort cell.

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








local cenyear=2000
*this should be changed to 2006 if want the 2005 survey data
local yearend=1999
*if my firm data goes beyond this, change here to 2005

local edit2=substr("`edit'",11,1)

*-----------------------------------------------





*-----------------------------------------------
global zone="ZM"
global munwork="yes"


*-----------------------------------------------
global exposure=""






*variable to rename year
global agestart=5
local ageend=39

global dropvar1=""
global dropvar2=""
global dropvar3="keep if cenyear==`cenyear'"
*these dropvars below may involve geographical info

global dropvar4=""


*so drop migrants

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

noi local lhslist="yrschl2 yrschl dropq10 dropq13"

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



*drop if munmatch!=1 & muncensoZM>55

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




cap gen incearnlnhrs=incearnln if hrswrk1>20
cap gen incworklnhrs=incearnln if hrswrk1>20 & (empstatd==120 | empstatd==110)
*these are my prefferred measure for people working more than 20 hours a week, and people in employment

cap winsor incearnlnhrs, gen(incearnlnhrswin) p(0.01)
cap winsor incworklnhrs, gen(incworklnhrswin) p(0.01)
cap winsor inctotln, gen(inctotlnwin) p(0.01)
*now winsorize these

cap gen hhincomepcln=log(hhincomepc)
cap winsor hhincomepcln, gen(hhincomepclnwin) p(0.01)
*now get get household income per capita


cap gen hhincomeln=log(hhincome)
cap winsor hhincomeln, gen(hhincomelnwin) p(0.01)
*now get get household income 




cap gen yrschlp6=yrschl if yrschl>6
cap gen yrschlp9=yrschl if yrschl>9
cap gen yrschlb9=yrschl if yrschl<=9
cap gen yrschlb6=yrschl if yrschl<=6

cap gen yrschlprop6=(yrschl>6) if yrschl!=.
cap gen yrschlprop9=(yrschl>9) if yrschl!=.

cap gen yrschlprop06=(yrschl<=6) if yrschl!=.
cap gen yrschlprop79=(yrschl>6 & yrschl<=9) if yrschl!=.
cap gen yrschlprop09=(yrschl<=9) if yrschl!=.
cap gen yrschlprop1012=(yrschl>9 & yrschl<=12) if yrschl!=.
cap gen yrschlprop1318=(yrschl>12 & yrschl<=18) if yrschl!=.  // this is exhaustive since education is capped at 18 in dataset
cap gen yrschlprop8=(yrschl>8) if yrschl!=.
cap gen yrschlprop11=(yrschl>11) if yrschl!=.
cap gen yrschlprop15=(yrschl>15) if yrschl!=.

cap gen yrschlprop011=(yrschl<=11) if yrschl!=.
cap gen yrschlprop1215=(yrschl>11 & yrschl<=15) if yrschl!=.
cap gen yrschlprop1618=(yrschl>15 & yrschl<=18) if yrschl!=.  // this is exhaustive since education is capped at 18 in dataset

cap gen yrschlprop08=(yrschl<=8) if yrschl!=.
cap gen yrschlprop911=(yrschl>8 & yrschl<=11) if yrschl!=.
cap gen yrschlprop1011=(yrschl>9 & yrschl<=11) if yrschl!=.
cap gen yrschlprop78=(yrschl>6 & yrschl<=8) if yrschl!=.  
cap gen yrschlprop1315=(yrschl>12 & yrschl<=15) if yrschl!=.

cap gen yrschlprop1111=(yrschl==11) if yrschl!=.
cap gen yrschlprop88=(yrschl==8) if yrschl!=.


cap gen yrschlprop66=(yrschl==6) if yrschl!=.
cap gen yrschlprop99=(yrschl==9) if yrschl!=.
cap gen yrschlprop1212=(yrschl==12) if yrschl!=.
cap gen yrschlprop05=(yrschl<=5) if yrschl!=.



cap gen yrschl2fin=yrschl2
cap replace yrschl2fin=. if schatt==1 & yrschl<=12





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




gen ind10=1 if (hcode==110 | hcode==112 | hcode==210 | hcode==211 | hcode==220 | hcode==230 | hcode==239) & employ==1
gen ind11=1 if (hcode==310 | hcode==311 | hcode==312 | hcode==314 | hcode==315 | hcode==321 | hcode==322 | hcode==323 | hcode==324 | hcode==325 | hcode==326 | hcode==330 | hcode==331 | hcode==332 | hcode==333 | hcode==335 | hcode==336 | hcode==337	) & employ==1
gen ind12=1 if (hcode==430 | hcode==433 | hcode==465 | hcode==467 | hcode==469 | hcode==480 | hcode==483 | hcode==487 | hcode==490 | hcode==511 | hcode==520 | hcode==530 | hcode==540 | hcode==562 | hcode==610 | hcode==620 | hcode==710 | hcode==720 | hcode==721 | hcode==810 | hcode==815 | hcode==939) & employ==1
gen ind13=1 if (hcode==110 | hcode==112 | hcode==210 | hcode==211 | hcode==220 | hcode==230 | hcode==239 | hcode==310 | hcode==311 | hcode==312 | hcode==314 | hcode==315 | hcode==321 | hcode==322 | hcode==323 | hcode==324 | hcode==325 | hcode==326 | hcode==330 | hcode==331 | hcode==332 | hcode==333 | hcode==335 | hcode==336 | hcode==337	 | 	hcode==430 | hcode==433 | hcode==465 | hcode==467 | hcode==469 | hcode==480 | hcode==483 | hcode==487 | hcode==490 | hcode==511 | hcode==520 | hcode==530 | hcode==540 | hcode==562 | hcode==610 | hcode==620 | hcode==710 | hcode==720 | hcode==721 | hcode==810 | hcode==815 | hcode==939) & employ==1
gen ind18=1 if (hcode==310 | hcode==311 | hcode==312 | hcode==314 | hcode==315 | hcode==321 | hcode==322 | hcode==323 | hcode==324 | hcode==325 | hcode==326 | hcode==330 | hcode==331 | hcode==332 | hcode==333 | hcode==335 | hcode==336 | hcode==337	 | 	hcode==430 | hcode==433 | hcode==465 | hcode==467 | hcode==469 | hcode==480 | hcode==483 | hcode==487 | hcode==490 | hcode==511 | hcode==520 | hcode==530 | hcode==540 | hcode==562 | hcode==610 | hcode==620 | hcode==710 | hcode==720 | hcode==721 | hcode==810 | hcode==815 | hcode==939) & employ==1
gen ind14=1 if (hcode==310 | hcode==326 | hcode==325 | hcode==311 | hcode==321 | hcode==322 | hcode==324 | hcode==330 | hcode==323) & employ==1
gen ind15=1 if (hcode==315 | hcode==336 | hcode==314 | hcode==312) & employ==1
gen ind16=1 if (hcode==335 | hcode==332 | hcode==333 | hcode==331 | hcode==337) & employ==1
gen ind19=1 if (hcode==335 | hcode==332 | hcode==333 | hcode==331 | hcode==337 | hcode==315 | hcode==336 | hcode==314 | hcode==312) & employ==1



local indylist ""
foreach n in 10 11 12 13 18 14 15 16 19 {
replace ind`n'=0 if ind`n'==. & (empstatd>0 &  empstatd<999) 
gen ind`n'form=ind`n'
replace ind`n'form=0 if ind`n'form==1 &  mx00a_imss!=1
*now just economically active
gen propind`n'=ind`n'
replace propind`n'=. if  employ==0 | employ==.
gen propind`n'form=ind`n'form
replace propind`n'form=. if  employ==0 | employ==.
local indylist "`indylist' ind`n' ind`n'form propind`n' propind`n'form"
}
*the ind and propind measures are:
*ind is proportion of people saying what their current situation is that are in ind`n' (and formal)
*propind is proportion of economically active that are in ind`n' (and formal)

do "${dir}industry_to_imss_classification.do"

*so these take value 1 if work in industry and 0 if don't (even if in school)
gen ind24=1 if (indimss==2 | indimss==4) & employ==1
replace ind24=0 if ind24==. & (empstatd>0 &  empstatd<999) 

gen ind33=1 if (indimss==3 | indimss==6) & employ==1
replace ind33=0 if ind33==. & (empstatd>0 &  empstatd<999) 

gen ind34=1 if (indimss==1 | indimss==5) & employ==1
replace ind34=0 if ind34==. & (empstatd>0 &  empstatd<999) 

gen ind20=1 if (indimss>=1 & indimss<=6) & employ==1
replace ind20=0 if ind20==. &  (empstatd>0 &  empstatd<999) 

gen ind32=1 if (indimss==3 | indimss==6 | indimss==1 | indimss==5) & employ==1
replace ind32=0 if ind32==. &  (empstatd>0 &  empstatd<999) 
*so now have indicators for formal ind for all of these


foreach n in 24 33 34 20 32 {
gen ind`n'form=ind`n'
replace ind`n'form=0 if ind`n'form==1 &  mx00a_imss!=1

*now just economically active
gen propind`n'=ind`n'
replace propind`n'=. if  employ==0 | employ==.

gen propind`n'form=ind`n'form
replace propind`n'form=. if  employ==0 | employ==.

local indylist "`indylist' ind`n' ind`n'form propind`n' propind`n'form"

}

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



#delimit ;
local  lhslistedit `"dropq10 dropq13 
yrschlp6 yrschlp9 yrschlb9 yrschlb6  
yrschlprop66 yrschlprop99 yrschlprop1212 yrschlprop05 yrschlprop88 yrschlprop1111 yrschlprop6 yrschlprop9  yrschlprop06 yrschlprop79  
yrschlprop09 yrschlprop1012 yrschlprop1318 yrschlprop011 yrschlprop1215 yrschlprop1618  
yrschlprop8 yrschlprop11   yrschlprop15 yrschlprop08 yrschlprop911 yrschlprop1011 yrschlprop78 yrschlprop1315 
posearn propind propindform sectorind sectorindform employ employns schatt leftfin proptech chdeathrate married chborn  
`indylist' "';

local  varlistedit `"yrschl yrschl2 yrschl2fin incearntrim incearnlnhrswin incworklnhrswin inctotlnwin  
hhincomepcln hhincomeln hhincomepclnwin hhincomelnwin"';
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






foreach thingy of var ?clyrschlprop* {
gen `thingy'log=log(`thingy'/(1-`thingy'))
}
foreach thingy of var ?clwtyrschlprop* {
gen `thingy'log=`thingy'
}




sort muncenso yobexp

save "${workdir}cohortmeans_mw${munwork}_`cenyear'.dta", replace


erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'1.dta"
cap erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta"

*these are tighter exposure windwos just above drop cutooffss
gen ecldrop1112= eclyrschlprop1012/eclyrschlprop8
gen ecldrop89= eclyrschlprop79/(1-eclyrschlprop05)
gen ecldropv1112= eclyrschlprop1215/eclyrschlprop8
gen ecldropv89= eclyrschlprop911/(1-eclyrschlprop05)
gen ecldropy1112= eclyrschlprop1012/eclyrschlprop8
gen ecldropy89= eclyrschlprop79/(1-eclyrschlprop05)
gen ecldropq1112= eclyrschlprop1012/eclyrschlprop8
gen ecldropq89= eclyrschlprop79/(1-eclyrschlprop05)

keep yobexp muncenso *drop*
renvars *drop*, sub(drop yrschldrop)

save "${workdir}cohortmeans_droponly_mw${munwork}_`cenyear'.dta", replace

}


do "C:\Work\Mexico\Revision\New_code\MCohort_Firm_Merge_simple_loop.do"



