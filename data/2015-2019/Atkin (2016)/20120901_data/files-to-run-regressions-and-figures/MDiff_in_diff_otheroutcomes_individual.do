/**
*this file generates:
Tshort_byyear_manyage_1990_individualq__shocked_26.pdf (Figure 6)
Tshort_byyear_manyage_bothyr_individualq__shocked_26.pdf (Figure C.4)
Tind16171819_byyear_1990_individualind__shocked_26.pdf (Figure C.6)
TparentsXcross_byyear_schatt_1990_individualq_interaction__shocked_26.pdf (Figure C.7)
as well as Table C.2 and C.4 with the raw coefficient which all of whcih appear in the paper or appendix.
**/



*shell taskkill /im StataMP-64.exe /f

cap log close
log using "C:/Work/Mexico/Revision/regout/log_dga_jan2016.txt", replace text



*this kills all stat windows (presumably including this one)

*March 2013: this file runs the diff in diff type regressions using the census data and changes occuring in 1990 and 2000.

set more off
clear all
set mem 4500m
set matsize 10000
set maxvar 32000
set more off


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
global dirrev="C:/Work/Mexico/Revision/New_code/"
global scratch="D:/Scratch/"
global dirgraph="C:/Work/Mexico/Revision/Graphs/Rev2/"
global regout="C:/Work/Mexico/Revision/regout/"
}











***************************************************
*All outcomes
***************************************************










foreach ind in 26    { // 46 16

local ind2=`ind'+1
local ind3=`ind'-1

local ind4=`ind'+2
*this is manuf unsepcified
local ind5=`ind'+3
*this is other unsepcified

local bottom=11
local top=20


use if age>`bottom' & age<`top' & muncenso!=12 using "${scratch}Diff_in_Diff_2000_1990_individual.dta", clear

 

cap drop ind19
cap drop ind29 
cap drop ind49
cap drop ind18
cap drop ind28 
cap drop ind48

mvencode ind`ind' ind`ind2' ind`ind3'  ind12 ind10 if indall!=. , mv(0) override

*this is clearly in services but not sufficiently specified
replace ind12=1 if indall==1 & ind90==60099

*from "missing ind90 categories to 26_"  sheet of concordance spreadhseet
replace ind`ind'=0 if indall==1 & ind90==31099
replace ind`ind3'=1 if indall==1 & ind90==31099

replace ind`ind'=0 if indall==1 & ind90==32099
replace ind`ind3'=1 if indall==1 & ind90==32099

replace ind`ind'=0 if indall==1 & ind90==32199
replace ind`ind3'=1 if indall==1 & ind90==32199

replace ind`ind'=0 if indall==1 & ind90==32299
replace ind`ind3'=1 if indall==1 & ind90==32299

replace ind`ind'=0 if indall==1 & ind90==32399
replace ind`ind3'=1 if indall==1 & ind90==32399

if `ind'==26 | `ind'==46 {
replace ind`ind'=1 if indall==1 & ind90==31399
replace ind`ind3'=0 if indall==1 & ind90==31399

replace ind`ind'=1 if indall==1 & ind90==32499
replace ind`ind3'=0 if indall==1 & ind90==32499

}




gen ind`ind5'=0 if indall!=. 
replace ind`ind5'=1 if indall==1 & ind90==99999
*not specificed
gen ind`ind4'=indall-ind12-ind10-ind`ind'-ind`ind3'-ind`ind5'
*manuf not specified





local other=regexr("16 26","`ind'","")

local other2=regexr("17 27","`ind2'","")

local other3=regexr("15 25","`ind3'","")

local other4=regexr("19 29","`ind4'","")

foreach droper in `other' `other2' `other3'  {
cap drop *`droper'cp*
cap drop *emp`droper'*
cap drop *`droper'?*
cap drop *ind`droper'
}



*compress

 

****
*slim down ideal specification
local schatt "schatt"  // show schooling effects
local ind`ind' "ind`ind' propnsind`ind'"  // prop of cohort with jobs in that industry rises
local indother "ind`ind' ind`ind2' ind`ind3' ind`ind4' ind`ind5' ind12 ind10  indblue indwhite"  // prop of cohort with jobs in other industries does not 
local indotherpropns "propnsind`ind' propnsind`ind2'  propnsind`ind3' propnsind12 propnsind10 propnsindblue propnsindwhite"  // prop of cohort with jobs in other industries does not 
local indotherprop "propind`ind' propind`ind2' propind`ind3' propind12 propind10 propindblue propindwhite"  // prop of cohort with jobs in other industries does not 
local employ "indall indother indunemploy"  // slightly increase in prop employed all together, unemployment?
local informal "ind`ind'formimss ind`ind'informimss propnsind`ind'formimss propnsind`ind'informimss"


*local long "schatt employanyns indall ind19 ind14 indother indunemploy  propnsindall propnsind19 propnsind14 propnsindother propnsindunemploy"  // show schooling effects
local long "schatt indall ind`ind' ind`ind2' indother indunemploy" // show schooling effects

local short "schatt indall ind`ind'" // show schooling effects

local grade "schatgradey schatgradea" // at grade measures
local schoolmeasure_list "schatt"  // for parents regs this goes on lefthand side

local parents "famind`ind' sibIind`ind' famindall momindall" // show parental employment effects

local parentscross "famind`ind' sibratioind`ind' famindall momindall" // show parental employment effects

local school "yrschl"


********Strategy 4. Some sort of multi-year specification (can only do in 1990 if want forward lags)




foreach sample in   "shocked" "podemp" "all" {  //

if "`sample'"=="shocked" {
local samp "& podemp`ind'_m101234==1"
local samp2 "& podemp`ind'_m0123==1"
local samp3 ""
local samp4 ""
}
else if "`sample'"=="all" {
local samp ""
local samp2 ""
local samp3 ""
local samp4 ""
}
else if "`sample'"=="podemp" {
local samp ""
local samp2 ""
local samp3 "ibn.age#c.podemp`ind'_m101234"
local samp4 "ibn.age#c.podemp`ind'_m0123"
}

foreach po in ""  { // 





***** This is my favored specficiation



local agestart=12

foreach table in short {  //  
local fileend "individualq_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=19 & age>=`agestart' & cenyear==1990   `samp'
reg `lhs' ibn.agex  `samp3' ///
ibn.age#c.`po'deltaemp50`ind'cp_1987   ///
ibn.age#c.`po'deltaemp50`ind'cp_1988   ///
ibn.age#c.`po'deltaemp50`ind'cp_1989   ///
ibn.age#c.`po'deltaemp50`ind'cp_1990   ///
ibn.age#c.`po'deltaemp50`ind'cp_1991   ///
ibn.age#c.`po'deltaemp50`ind'cp_1992   ///
if age<=19 & age>=`agestart'  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}Nov2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 


gen sample=e(sample)
egen group=group(muncenso) if sample==1
noi sum group
drop group sample



forval yr=1987/1992 {
forval n=`agestart'/19 {
local demp`ind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
}
}

local testlist1 ""
forval yr=1990/1992 {
forval n=`agestart'/19 {
local testlist1 "`testlist1' `n'.age#c.`po'deltaemp50`ind'cp_`yr'"
}
}
noi di "1990/92 Test"
noi testparm `testlist1' 

/*

       F( 16,   163) =    2.16
            Prob > F =    0.0081

*/



foreach yr in 1989 1990 1991  1992 {
local testlist`yr' ""
forval n=`agestart'/19 {
local testlist`yr' "`testlist`yr'' `n'.age#c.`po'deltaemp50`ind'cp_`yr'"
}
noi di "`yr' Test"
noi testparm `testlist`yr'' 
}




preserve
clear
set obs 20
gen year=_n+1985
gen year_2dig=year-1900
gen year_midpoint=year+0.5
gen year_midpoint_2dig=year-1900+.5

forval n=`agestart'/19 {
gen age_`n'=.
}

forval yr=1987/1992 {
forval n=`agestart'/19 {
replace age_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}



if "`lhs'"=="schatt" {
local lhsneat "Attending school"
}
else if "`lhs'"=="schatgradey" {
local lhsneat "At grade and at school"
}
else if "`lhs'"=="schatgradea" {
local lhsneat "At grade"
}
else if "`lhs'"=="indall" {
local lhsneat "Working"
}
else if "`lhs'"=="ind`ind'" {
local lhsneat "Working in exports"
}
else {
local lhsneat "ind`ind'"
}


twoway line age_12 age_13 age_14 age_15  age_17  age_18 age_19  year_midpoint if year>=1987 & year<=1992 , lpattern(dash dot dash_dot shortdash shortdash_dot longdash longdash_dot "_--") lwidth(thin thin thin thin thin thin thin thin)  || ///
line age_16  year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue) legend(col(4)) ///
title("`lhsneat'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2) ylab(-2(2)4) yscale(range(-2.7)) ///
legend(order(1 2 3 4 8 5 6 7) label(1 "age 12") label(2 "age 13") label(3 "age 14") label(4 "age 15") label(5 "age 17") label(6 "age 18") label(7 "age 19") label(8 "age 16") cols(8)  symxsize(10) size(small))
cap graph export "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.emf", replace

 

twoway line age_16  year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue)  ///
title("`lhsneat'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.emf", replace


restore


}




local comblist ""
local comblist16 ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.gph""'
local comblist16 `"`comblist16' "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.gph""'
}


grc1leg `comblist' , ring(3) xcommon col(3) iscale(0.67) imargin(0 2 2)   l1title("Deviations") b1title("Year of export employment shock")
cap graph save "${dirgraph}T`table'_byyear_manyage_1990_`fileend'.gph", replace
cap graph export "${dirgraph}T`table'_byyear_manyage_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}T`table'_byyear_manyage_1990_`fileend'.emf", replace
*% DGA 12/28/15: then made manual edits to graph in graph editor



graph combine `comblist16' , xcommon  ycommon col(3) iscale(0.67) imargin(0 2 2)  l1title("Deviations") b1title("Year of export employment shock")
cap graph save "${dirgraph}T`table'_byyear_16_1990_`fileend'.gph", replace
cap graph export "${dirgraph}T`table'_byyear_16_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}T`table'_byyear_16_1990_`fileend'.emf", replace

cap copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml", replace
}

**/



****same strategy but extend period for IV justification:
*** this doesnt help much... very noisy in 1993, comment out for now

/**
local agestart=12

foreach table in short  {  // indother indotherprop indotherpropns long  schatt ind19 indother employ  informal

local fileend "individualq_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990iv_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990iv_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=19 & age>=`agestart' & cenyear==1990   `samp'
reg `lhs' ibn.agex  `samp3' ///
ibn.age#c.`po'deltaemp50`ind'cp_1986   ///
ibn.age#c.`po'deltaemp50`ind'cp_1987   ///
ibn.age#c.`po'deltaemp50`ind'cp_1988   ///
ibn.age#c.`po'deltaemp50`ind'cp_1989   ///
ibn.age#c.`po'deltaemp50`ind'cp_1990   ///
ibn.age#c.`po'deltaemp50`ind'cp_1991   ///
ibn.age#c.`po'deltaemp50`ind'cp_1992   ///
ibn.age#c.`po'deltaemp50`ind'cp_1993   ///
ibn.age#c.`po'deltaemp50`ind'cp_1994   ///
if age<=19 & age>=`agestart'  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990iv_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 


forval yr=1986/1994 {
forval n=`agestart'/19 {
local demp`ind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
}
}


preserve
clear
set obs 20
gen year=_n+1985
gen year_2dig=year-1900
gen year_midpoint=year+0.5
gen year_midpoint_2dig=year-1900+.5

forval n=`agestart'/19 {
gen age_`n'=.
}

forval yr=1986/1994 {
forval n=`agestart'/19 {
replace age_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}

/*
twoway line age_13 age_14 age_15  age_17  age_18  year if year>=1987 & year<=1992 , lpattern(dash dash dash dash dash) lwidth(thin thin thin thin thin)  || ///
line age_16  year if year>=1987 & year<=1992 , lcolor(edkblue) ///
title("Difference in `lhs' by age" "across high and low export municipalities") ///
note("") ytitle("Difference in `lhs'") xtitle("Year of Shock") saving("${dirgraph}I`lhs'_byage_manyyear", replace) xlab(1987(1)1993) xline(1990.2)
graph export "${dirgraph}I`lhs'_byage_manyyear.pdf", replace
graph export "${dirgraph}I`lhs'_byage_manyyear.emf", replace
*/
twoway line age_12 age_13 age_14 age_15  age_17  age_18 age_19  year if year>=1986 & year<=1994 , lpattern(dash dot dash_dot shortdash shortdash_dot longdash longdash_dot "_--")  lwidth(thin thin thin thin thin thin thin thin)  || ///
line age_16  year if year>=1986 & year<=1994 , lcolor(edkblue) legend(col(4)) ///
title("`lhs'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_manyage_1990iv_`fileend'", replace) xlab(1986(1)1994) xline(1990.2)
graph export "${dirgraph}I`lhs'_byyear_manyage_1990iv_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_manyage_1990iv_`fileend'.emf", replace

 

twoway line age_16  year if year>=1986 & year<=1994 , lcolor(edkblue)  ///
title("`lhs'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990iv_`fileend'", replace) xlab(1986(1)1994) xline(1990.2)
graph export "${dirgraph}I`lhs'_byyear_16_1990iv_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_16_1990iv_`fileend'.emf", replace


restore


}

local comblist ""
local comblist16 ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_manyage_1990iv_`fileend'.gph""'
local comblist16 `"`comblist16' "${dirgraph}I`lhs'_byyear_16_1990iv_`fileend'.gph""'
}

grc1leg `comblist' , xcommon col(3) iscale(0.67) imargin(small)
graph export "${dirgraph}I`table'_byyear_manyage_1990iv_`fileend'.pdf", replace
graph export "${dirgraph}I`table'_byyear_manyage_1990iv_`fileend'.emf", replace

graph combine `comblist16' , xcommon col(3) iscale(0.67) imargin(small)
graph export "${dirgraph}I`table'_byyear_16_1990iv_`fileend'.pdf", replace
graph export "${dirgraph}I`table'_byyear_16_1990iv_`fileend'.emf", replace

copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990iv_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_1990iv_v`fileend'.xml", replace
}
**/



*******same startegy but for both cenyears
/**
local agestart=12

foreach table in short  {  //  
local fileend "individualq_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=19 & age>=`agestart'     `samp2'
reg `lhs' ibn.agex  `samp4' ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm3  ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm2   ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm1   ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm0   ///
if age<=19 & age>=`agestart'  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'" , excel nonotes nocons ctitle("`lhs' ") 

forval yr=0/3  {
forval n=`agestart'/19 {
local demp`ind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`ind'cp_1yearm`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`ind'cp_1yearm`yr']
}
}


preserve
clear
set obs 20
gen year=_n-1


forval n=`agestart'/19 {
gen age_`n'=.
}

forval yr=0/3 {
forval n=`agestart'/19 {
replace age_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}
gen myear=1-year

/*
twoway line age_13 age_14 age_15  age_17  age_18  myear if year>=0 & year<=3 , lpattern(dash dash dash dash dash) lwidth(thin thin thin thin thin)  || ///
line age_16  myear if year>=0 & year<=3  , lcolor(edkblue) ///
title("Difference in `lhs' by age" "across high and low export municipalities") ///
note("") ytitle("Difference in `lhs'") xtitle("Year of Shock") saving("${dirgraph}X`lhs'_byage_manyyear", replace) xlab(1987(1)1993) xline(1990.2)
graph export "${dirgraph}X`lhs'_byage_manyyear.pdf", replace
graph export "${dirgraph}X`lhs'_byage_manyyear.emf", replace
*/


if "`lhs'"=="schatt" {
local lhsneat "Attending school"
}
else if "`lhs'"=="schatgradey" {
local lhsneat "At grade and at school"
}
else if "`lhs'"=="schatgradea" {
local lhsneat "At grade"
}
else if "`lhs'"=="indall" {
local lhsneat "Working"
}
else if "`lhs'"=="ind`ind'" {
local lhsneat "Working in exports"
}
else {
local lhsneat "ind`ind'"
}

twoway line age_12 age_13 age_14 age_15  age_17  age_18  age_19 myear if year>=0 & year<=3 , lpattern(dash dot dash_dot shortdash shortdash_dot longdash longdash_dot "_--")  lwidth(thin thin thin thin thin thin thin thin)  || ///
line age_16  myear if year>=0 & year<=3  , lcolor(edkblue) legend(col(4)) ///
title("`lhsneat'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'", replace) xlab(-2(1)1) xline(0) ///
legend(order(1 2 3 4 8 5 6 7) label(1 "age 12") label(2 "age 13") label(3 "age 14") label(4 "age 15") label(5 "age 17") label(6 "age 18") label(7 "age 19") label(8 "age 16"))

graph export "${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'.emf", replace

twoway line age_16  myear if year>=0 & year<=3  , lcolor(edkblue)  ///
title("`lhsneat'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'", replace) xlab(-2(1)1) xline(0)
graph export "${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'.emf", replace

restore


}
local comblist ""
local comblist16 ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'.gph""'
local comblist16 `"`comblist16' "${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'.gph""'
}

grc1leg `comblist' , ring(3)  xcommon col(3) iscale(0.67) imargin(small) l1title("Deviations") b1title("Year of export employment shock")
graph export "${dirgraph}T`table'_byyear_manyage_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}T`table'_byyear_manyage_bothyr_`fileend'.emf", replace

graph combine `comblist16' , xcommon col(3) iscale(0.67) imargin(small) l1title("Deviations") b1title("Year of export employment shock")
graph export "${dirgraph}T`table'_byyear_16_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}T`table'_byyear_16_bothyr_`fileend'.emf", replace

cap copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.xml", replace

}
**/







*startegy4b: now look at parents. sample only runs to 18 because of the parent data where poploc not used


foreach table in parentscross {  // long  schatt ind19 indother employ  informal

local fileend "individualq_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=16 & age>=16 & cenyear==1990   `samp'
reg `lhs' ibn.agex  `samp3' ///
ibn.age#c.`po'deltaemp50`ind'cp_1987   ///
ibn.age#c.`po'deltaemp50`ind'cp_1988   ///
ibn.age#c.`po'deltaemp50`ind'cp_1989   ///
ibn.age#c.`po'deltaemp50`ind'cp_1990   ///
ibn.age#c.`po'deltaemp50`ind'cp_1991   ///
ibn.age#c.`po'deltaemp50`ind'cp_1992   ///
if age<=16 & age>=16  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 


forval yr=1987/1992 {
foreach n of numlist 16 { // `agestart'/18
local demp`ind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
}
}


preserve
clear
set obs 20
gen year=_n+1985
gen year_2dig=year-1900
gen year_midpoint=year+0.5
gen year_midpoint_2dig=year-1900+.5

foreach n of numlist 16 { // `agestart'/18
gen age_`n'=.
}

forval yr=1987/1992 {
foreach n of numlist 16 { // `agestart'/18
replace age_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}



twoway line age_16  year_midpoint_2dig if year>=1987 & year<=1992 , lpattern(longdash) lcolor(edkblue)  ///
title("") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990_`fileend'", replace) ylab(-2 0 2) xlab(87(1)93) xline(90.2)
graph export "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.emf", replace


restore


}

local comblist ""
local comblist16 ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.gph""'
local comblist16 `"`comblist16' "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.gph""'
}




graph combine `comblist16' , ycommon  xcommon col(3) iscale(0.67) imargin(small)  l1title("Deviations") b1title("Year of export employment shock")

graph export "${dirgraph}I`table'_byyear_16_1990_`fileend'.pdf", replace
graph export "${dirgraph}I`table'_byyear_16_1990_`fileend'.emf", replace

copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml", replace
}

**/






*******same startegy but for both cenyears
/**
local agestart=12

foreach table in parentscross {  //  schatt ind19 indother employ  informal

local fileend "individualq_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=16 & age>=16     `samp2'
reg `lhs' ibn.agex `samp4' ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm3  ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm2   ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm1   ///
ibn.age#c.`po'deltaemp50`ind'cp_1yearm0   ///
if age<=16 & age>=16  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'" , excel nonotes nocons ctitle("`lhs' ") 

forval yr=0/3  {
foreach n of numlist 16 { // `agestart'/18
local demp`ind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`ind'cp_1yearm`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`ind'cp_1yearm`yr']
}
}


preserve
clear
set obs 20
gen year=_n-1


foreach n of numlist 16 { // `agestart'/18
gen age_`n'=.
}

forval yr=0/3 {
foreach n of numlist 16 { // `agestart'/18
replace age_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}
gen myear=1-year

/*
twoway line age_13 age_14 age_15  age_17  age_18  myear if year>=0 & year<=3 , lpattern(dash dash dash dash dash) lwidth(thin thin thin thin thin)  || ///
line age_16  myear if year>=0 & year<=3  , lcolor(edkblue) ///
title("Difference in `lhs' by age" "across high and low export municipalities") ///
note("") ytitle("Difference in `lhs'") xtitle("Year of Shock") saving("${dirgraph}X`lhs'_byage_manyyear", replace) xlab(1987(1)1993) xline(1990.2)
graph export "${dirgraph}X`lhs'_byage_manyyear.pdf", replace
graph export "${dirgraph}X`lhs'_byage_manyyear.emf", replace
*/


/*
twoway line age_12 age_13 age_14 age_15  age_17  age_18   myear if year>=0 & year<=3 , lpattern(dash dot dash_dot shortdash shortdash_dot longdash longdash_dot "_--")  lwidth(thin thin thin thin thin thin thin thin)  || ///
line age_16  myear if year>=0 & year<=3  , lcolor(edkblue) legend(col(4)) ///
title("`lhs'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'", replace) xlab(-2(1)1) xline(0)
graph export "${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'.emf", replace
*/

twoway line age_16  myear if year>=0 & year<=3  , lpattern(longdash) lcolor(edkblue)  ///
title("") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'", replace) ylab(-2 0 2) xlab(-2(1)1) xline(0)
graph export "${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'.emf", replace

restore


}
local comblist ""
local comblist16 ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_manyage_bothyr_`fileend'.gph""'
local comblist16 `"`comblist16' "${dirgraph}I`lhs'_byyear_16_bothyr_`fileend'.gph""'
}

/*
grc1leg `comblist' , xcommon col(3) iscale(0.67) imargin(small)
graph export "${dirgraph}I`table'_byyear_manyage_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`table'_byyear_manyage_bothyr_`fileend'.emf", replace
*/

graph combine `comblist16' ,  ycommon  xcommon col(3) iscale(0.67) imargin(small)  l1title("Deviations") b1title("Year of export employment shock")
graph export "${dirgraph}I`table'_byyear_16_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`table'_byyear_16_bothyr_`fileend'.emf", replace

cap copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_both_v`fileend'.xml", replace

}
**/





*startegy 5: look only at age 16 and contrast schatt effect to parental employment effect



local agestart=12

foreach schoolmeasure in `schoolmeasure_list' {

foreach table in parents {  // 

local fileend "individualq_interaction_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_1990_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_1990_v`fileend'.txt"

foreach lhs in ``table'' {  //  




cap drop `lhs'x
gen `lhs'x=round(`lhs') if age<=16 & age>=16 & cenyear==1990      `samp'
reg `schoolmeasure' ibn.`lhs'x  `samp3' ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1987   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1988   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1989   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1990   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1991   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1992   ///
if age<=16 & age>=16  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop `lhs'x
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 



forval yr=1987/1992 {
forval n=0/1 {
local demp`ind'_b`n'_`yr'=_b[`n'.`lhs'x#c.`po'deltaemp50`ind'cp_`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.`lhs'x#c.`po'deltaemp50`ind'cp_`yr']
}
}


preserve
clear
set obs 20
gen year=_n+1985
gen year_2dig=year-1900
gen year_midpoint=year+0.5
gen year_midpoint_2dig=year-1900+.5

forval n=0/1 {
gen `lhs'x_`n'=.
}

forval yr=1987/1992 {
forval n=0/1 {
replace `lhs'x_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}



if "`lhs'"=="famind`ind'" {
local lhsneat "Parent works in exports"
}
if "`lhs'"=="sibIind`ind'" {
local lhsneat "Family works in exports"
}
if "`lhs'"=="famindall" {
local lhsneat "Parent works"
}
if "`lhs'"=="momindall" {
local lhsneat "Mother works"
}

twoway line `lhs'x_0  year_midpoint_2dig if year>=1987 & year<=1992 , lpattern(dash) lcolor(eltblue)  || ///
line `lhs'x_1  year_midpoint_2dig if year>=1987 & year<=1992 , lcolor(edkblue) legend(col(4)) ///
title("") ///
legend(order(2 1) label(2 "Does work") label(1 "Does not work")  size(small)) ///
note("")  ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_`schoolmeasure'_1990_`fileend'", replace) ylab(-5 0 5) xlab(87(1)93) xline(90.2)
graph export "${dirgraph}I`lhs'_byyear_`schoolmeasure'_1990_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_`schoolmeasure'_1990_`fileend'.emf", replace



restore


}



local comblist ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_`schoolmeasure'_1990_`fileend'.gph""'
}

grc1leg `comblist' , ring(3) ycommon xcommon col(4) iscale(0.67) imargin(small) l1title("Deviations in school attendance at age 16") b1title("Year of export employment shock")
graph export "${dirgraph}T`table'_byyear_`schoolmeasure'_1990_`fileend'.pdf", replace
graph export "${dirgraph}T`table'_byyear_`schoolmeasure'_1990_`fileend'.emf", replace

*now I combine this with the non interacted specifications that regress the interaction on age 16

local tableparents "parentscross"
local comblist16p ""
local fileendp "individualq_`po'_`sample'_`ind'"
foreach lhs in ``tableparents'' {

local comblist16p `"`comblist16p' "${dirgraph}I`lhs'_byyear_16_1990_`fileendp'.gph""'
}

grc1leg `comblist' `comblist16p', ring(3) xcommon col(4) iscale(0.67) imargin(0.1) ///
l1title("Deviation in parent/family             Deviation in child" "   employment probability              school attendance", size(small)) ///
b1title("Year of export employment shock", size(small)) ///
title("     Parent works in exports    Family works in exports            Parent works                     Mother works",size(small)  justification(center) span)


graph export "${dirgraph}T`table'Xcross_byyear_`schoolmeasure'_1990_`fileend'.pdf", replace
graph export "${dirgraph}T`table'Xcrodd_byyear_`schoolmeasure'_1990_`fileend'.emf", replace



grc1leg `comblist' `comblist16p', ring(0) xcommon col(4) iscale(0.67) imargin(0.1) ///
l1title("Deviation in parent/family             Deviation in child" "   employment probability              school attendance", size(small)) ///
b1title("Year of export employment shock", size(small)) ///
title("     Parent works in exports    Family works in exports            Parent works                     Mother works",size(small)  justification(center) span)

graph save "${dirgraph}T`table'Xcross_byyear_`schoolmeasure'_1990_`fileend'_ring0.gph", replace
graph export "${dirgraph}T`table'Xcross_byyear_`schoolmeasure'_1990_`fileend'_ring0.pdf", replace
graph export "${dirgraph}T`table'Xcrodd_byyear_`schoolmeasure'_1990_`fileend'_ring0.emf", replace




copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_1990_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_1990_v`fileend'.xml", replace
}
}

**/






*******same startegy but for both cenyears
/**
local agestart=12

foreach schoolmeasure in `schoolmeasure_list' {

foreach table in  parents {  //  schatt ind19 indother employ  informal

local fileend "individualq_interaction_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_both_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_both_v`fileend'.txt"

foreach lhs in ``table'' {  //  


cap drop `lhs'x
gen `lhs'x=round(`lhs') if age<=16 & age>=16    `samp2'
reg `schoolmeasure' ibn.`lhs'x  `samp4' ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1yearm3   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1yearm2   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1yearm1   ///
ibn.`lhs'x#c.`po'deltaemp50`ind'cp_1yearm0   ///
if age<=16 & age>=16  [aweight=wtper], nocons  cluster(muncenso_cenyear)
drop `lhs'x
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_both_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 



forval yr=0/3 {
forval n=0/1 {
local demp`ind'_b`n'_`yr'=_b[`n'.`lhs'x#c.`po'deltaemp50`ind'cp_1yearm`yr']
local demp`ind'_s`n'_`yr'=_se[`n'.`lhs'x#c.`po'deltaemp50`ind'cp_1yearm`yr']
}
}






preserve
clear
set obs 20
gen year=_n-1


forval n=0/1 {
gen `lhs'x_`n'=.
}

forval yr=0/3 {
forval n=0/1 {
replace `lhs'x_`n'=`demp`ind'_b`n'_`yr'' if year==`yr'
}
}


gen myear=1-year

/*
twoway line age_13 age_14 age_15  age_17  age_18  myear if year>=0 & year<=3 , lpattern(dash dash dash dash dash) lwidth(thin thin thin thin thin)  || ///
line age_16  myear if year>=0 & year<=3  , lcolor(edkblue) ///
title("Difference in `lhs' by age" "across high and low export municipalities") ///
note("") ytitle("Difference in `lhs'") xtitle("Year of Shock") saving("${dirgraph}X`lhs'_byage_manyyear", replace) xlab(1987(1)1993) xline(1990.2)
graph export "${dirgraph}X`lhs'_byage_manyyear.pdf", replace
graph export "${dirgraph}X`lhs'_byage_manyyear.emf", replace
*/

if "`lhs'"=="famind`ind'" {
local lhsneat "Parent works in exports"
}
if "`lhs'"=="famindall" {
local lhsneat "Parent works"
}
if "`lhs'"=="sibIind`ind'" {
local lhsneat "Family works in exports"
}
if "`lhs'"=="momindall" {
local lhsneat "Mother works"
}


twoway line `lhs'x_0 myear if year>=0 & year<=3 , lpattern(dash) lcolor(eltblue)  || ///
line `lhs'x_1  myear if year>=0 & year<=3  , lcolor(edkblue) legend(col(4)) ///
title("") ///
legend(order(2 1) label(2 "Does work") label(1 "Does not work") size(small)) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_`schoolmeasure'_bothyr_`fileend'", replace) ylab(-5 0 5) xlab(-2(1)1) xline(0)
graph export "${dirgraph}I`lhs'_byyear_`schoolmeasure'_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_`schoolmeasure'_bothyr_`fileend'.emf", replace

restore
}

local comblist ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_`schoolmeasure'_bothyr_`fileend'.gph""'
}

grc1leg `comblist' , ring(3) ycommon  xcommon col(4) iscale(0.67) imargin(small)  l1title("Deviations in school attendance at age 16") b1title("Year of export employment shock")
graph export "${dirgraph}T`table'_byyear_`schoolmeasure'_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}T`table'_byyear_`schoolmeasure'_bothyr_`fileend'.emf", replace


*now I combine this with the non interacted specifications that regress the interaction on age 16

local tableparents "parentscross"
local comblist16p ""
local fileendp "individualq_`po'_`sample'_`ind'"
foreach lhs in ``tableparents'' {

local comblist16p `"`comblist16p' "${dirgraph}I`lhs'_byyear_16_bothyr_`fileendp'.gph""'
}

grc1leg `comblist' `comblist16p', ring(3) xcommon col(4) iscale(0.67) imargin(medsmall) ///
l1title("Deviation in parent/family             Deviation in child" "   employment probability              school attendance", size(small)) ///
b1title("Year of export employment shock", size(small)) ///
title("     Parent works in exports    Family works in exports            Parent works                     Mother works",size(small)  justification(center) span)



graph export "${dirgraph}T`table'Xcross_byyear_`schoolmeasure'_bothyr_`fileend'.pdf", replace
graph export "${dirgraph}T`table'Xcrodd_byyear_`schoolmeasure'_bothyr_`fileend'.emf", replace



cap copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_both_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_`schoolmeasure'_both_v`fileend'.xml", replace

}
}

**/





*strategy 6: for each age plot the differen industries


local agestart=12

foreach table in indother {  //  
local fileend "individualind_`po'_`sample'_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=19 & age>=`agestart' & cenyear==1990   `samp'
reg `lhs' ibn.agex  `samp3' ///
ibn.age#c.`po'deltaemp50`ind'cp_1987   ///
ibn.age#c.`po'deltaemp50`ind'cp_1988   ///
ibn.age#c.`po'deltaemp50`ind'cp_1989   ///
ibn.age#c.`po'deltaemp50`ind'cp_1990   ///
ibn.age#c.`po'deltaemp50`ind'cp_1991   ///
ibn.age#c.`po'deltaemp50`ind'cp_1992   ///
if age<=19 & age>=`agestart'  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 


forval yr=1987/1992 {
forval n=`agestart'/19 {
local `lhs'`ind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
local `lhs'`ind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`ind'cp_`yr']
}
}

}

preserve
clear
set obs 20
gen year=_n+1985
gen year_2dig=year-1900
gen year_midpoint=year+0.5
gen year_midpoint_2dig=year-1900+.5

foreach lhs in ``table'' { 
forval n=`agestart'/19 {
gen age_`n'_`lhs'=.
}


forval yr=1987/1992 {
forval n=`agestart'/19 {
replace age_`n'_`lhs'=``lhs'`ind'_b`n'_`yr'' if year==`yr'
}
}
}



if "`lhs'"=="schatt" {
local lhsneat "Attending school"
}
else if "`lhs'"=="schatgradey" {
local lhsneat "At grade and at school"
}
else if "`lhs'"=="schatgradea" {
local lhsneat "At grade"
}
else if "`lhs'"=="indall" {
local lhsneat "Working"
}
else if "`lhs'"=="ind`ind'" {
local lhsneat "Working in exports"
}
else {
local lhsneat "ind`ind'"
}


 


twoway line age_16_ind`ind' age_16_ind`ind3' age_16_ind12  age_16_ind10 age_16_ind`ind4' age_16_ind`ind5'  year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("") ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloopnt_byyear_16_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloopnt_byyear_16_1990_`fileend'.emf", replace



twoway line age_16_ind`ind' age_16_ind`ind3'  age_16_ind12  age_16_ind10  age_16_ind`ind4' age_16_ind`ind5'  year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 16", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified")) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_16_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_16_1990_`fileend'.emf", replace


twoway line age_17_ind`ind' age_17_ind`ind3'  age_17_ind12  age_17_ind10  age_17_ind`ind4' age_17_ind`ind5' year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 17", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_17_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_17_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_17_1990_`fileend'.emf", replace



twoway line age_18_ind`ind' age_18_ind`ind3'  age_18_ind12  age_18_ind10  age_18_ind`ind4' age_18_ind`ind5' year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 18", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_18_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_18_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_18_1990_`fileend'.emf", replace


twoway line age_19_ind`ind' age_19_ind`ind3'  age_19_ind12  age_19_ind10  age_19_ind`ind4' age_19_ind`ind5' year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 19", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector")  label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_19_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_19_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_19_1990_`fileend'.emf", replace

restore

local comblist ""
foreach ageq in 16 17 18 19 {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_`ageq'_1990_`fileend'.gph""'
}

grc1leg `comblist' , ring(3) ycommon  xcommon col(2) iscale(0.67) imargin(0 2)  l1title("Deviations in industry of employment") b1title("Year of export employment shock")
graph export "${dirgraph}Tind16171819_byyear_1990_`fileend'.pdf", replace
graph export "${dirgraph}Tind16171819_byyear_1990_`fileend'.emf", replace

local comblist ""
foreach ageq in 17 18 19 {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_`ageq'_1990_`fileend'.gph""'
}

grc1leg `comblist' , ring(3) ycommon  xcommon col(3) iscale(0.67) imargin(0 2)  l1title("Deviations in industry of employment") b1title("Year of export employment shock")
graph save "${dirgraph}Tind171819_byyear_1990_`fileend'.gph", replace
graph export "${dirgraph}Tind171819_byyear_1990_`fileend'.pdf", replace
graph export "${dirgraph}Tind171819_byyear_1990_`fileend'.emf", replace









cap copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml", replace
}


**/





*strategy 6b: placebo check with other industries shocks for each age plot the differen industries



local agestart=12

foreach altind in 25 12 {


if "`sample'"=="shocked" {
local samp "& podemp`altind'_m101234==1"
local samp2 "& podemp`altind'_m01234==1"
local samp3 ""
local samp4 ""
}
else if "`sample'"=="all" {
local samp ""
local samp2 ""
local samp3 ""
local samp4 ""
}
else if "`sample'"=="podemp" {
local samp ""
local samp2 ""
local samp3 "ibn.age#c.podemp`altind'_m101234"
local samp4 "ibn.age#c.podemp`altind'_m01234"
}


foreach table in indother short {  //  grade           indother indotherprop indotherpropns long  schatt ind19 indother employ  informal


local fileend "individualind_`po'_`sample'_`altind'"
cap erase "${scratch}July2014_`altind'_Diff_in_Diff_`table'_1990_v`fileend'.xml"
cap erase "${scratch}July2014_`altind'_Diff_in_Diff_`table'_1990_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=19 & age>=`agestart' & cenyear==1990   `samp'
reg `lhs' ibn.agex  `samp3' ///
ibn.age#c.`po'deltaemp50`altind'cp_1987   ///
ibn.age#c.`po'deltaemp50`altind'cp_1988   ///
ibn.age#c.`po'deltaemp50`altind'cp_1989   ///
ibn.age#c.`po'deltaemp50`altind'cp_1990   ///
ibn.age#c.`po'deltaemp50`altind'cp_1991   ///
ibn.age#c.`po'deltaemp50`altind'cp_1992   ///
if age<=19 & age>=`agestart'  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`altind'_Diff_in_Diff_`table'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 


forval yr=1987/1992 {
forval n=`agestart'/19 {
local `lhs'`altind'_b`n'_`yr'=_b[`n'.age#c.`po'deltaemp50`altind'cp_`yr']
local `lhs'`altind'_s`n'_`yr'=_se[`n'.age#c.`po'deltaemp50`altind'cp_`yr']
}
}

}

preserve
clear
set obs 20
gen year=_n+1985
gen year_2dig=year-1900
gen year_midpoint=year+0.5
gen year_midpoint_2dig=year-1900+.5

foreach lhs in ``table'' { 
forval n=`agestart'/19 {
gen age_`n'_`lhs'=.
}


forval yr=1987/1992 {
forval n=`agestart'/19 {
replace age_`n'_`lhs'=``lhs'`altind'_b`n'_`yr'' if year==`yr'
}
}
}



if "`lhs'"=="schatt" {
local lhsneat "Attending school"
}
else if "`lhs'"=="schatgradey" {
local lhsneat "At grade and at school"
}
else if "`lhs'"=="schatgradea" {
local lhsneat "At grade"
}
else if "`lhs'"=="indall" {
local lhsneat "Working"
}
else if "`lhs'"=="ind`altind'" {
local lhsneat "Working in exports"
}
else {
local lhsneat "ind`altind'"
}


 


twoway line age_16_ind`ind' age_16_ind`ind3' age_16_ind12  age_16_ind10 age_16_ind`ind4' age_16_ind`ind5'  year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("") ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloopnt_byyear_16_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloopnt_byyear_16_1990_`fileend'.emf", replace



twoway line age_16_ind`ind' age_16_ind`ind3'  age_16_ind12  age_16_ind10  age_16_ind`ind4' age_16_ind`ind5'  year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 16", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified")) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_16_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_16_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_16_1990_`fileend'.emf", replace


twoway line age_17_ind`ind' age_17_ind`ind3'  age_17_ind12  age_17_ind10  age_17_ind`ind4' age_17_ind`ind5' year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 17", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_17_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_17_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_17_1990_`fileend'.emf", replace



twoway line age_18_ind`ind' age_18_ind`ind3'  age_18_ind12  age_18_ind10  age_18_ind`ind4' age_18_ind`ind5' year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 18", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector") label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_18_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_18_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_18_1990_`fileend'.emf", replace


twoway line age_19_ind`ind' age_19_ind`ind3'  age_19_ind12  age_19_ind10  age_19_ind`ind4' age_19_ind`ind5' year_midpoint if year>=1987 & year<=1992 , lcolor(edkblue eltblue green red) lpattern(solid dash dash_dot shortdash longdash dot)  /// 
title("Age 19", size(medium)) ///
legend(label(1 "Export manufacturing") label(2 "Non-export manufacturing") label(3 "Service sector") label(4 "Primary sector")  label(5 "Manufacturing (insuf. specified)") label(6 "Unclassified") ) ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_19_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)
cap graph export "${dirgraph}Iindloop_byyear_19_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}Iindloop_byyear_19_1990_`fileend'.emf", replace

restore

local comblist ""
foreach ageq in 16 17 18 19 {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_`ageq'_1990_`fileend'.gph""'
}

grc1leg `comblist' , ring(3) ycommon  xcommon col(2) iscale(0.67) imargin(0 2)  l1title("Deviations in industry of employment") b1title("Year of export employment shock")
graph export "${dirgraph}Tind16171819_byyear_1990_`fileend'.pdf", replace
graph export "${dirgraph}Tind16171819_byyear_1990_`fileend'.emf", replace

local comblist ""
foreach ageq in 17 18 19 {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_`ageq'_1990_`fileend'.gph""'
}

grc1leg `comblist' , ring(3) ycommon  xcommon col(3) iscale(0.67) imargin(0 2)  l1title("Deviations in industry of employment") b1title("Year of export employment shock")
graph export "${dirgraph}Tind171819_byyear_1990_`fileend'.pdf", replace
graph export "${dirgraph}Tind171819_byyear_1990_`fileend'.emf", replace









cap copy "${scratch}July2014_`altind'_Diff_in_Diff_`table'_1990_v`fileend'.xml" "${regout}July2014_`altind'_Diff_in_Diff_`table'_1990_v`fileend'.xml", replace
}

}

**/











}
*po

}
*sample


}
*ind





***stragey 7: show iv is exogenous
*doesn't depend on lagged schatt but does on conetmporaneous





order deltaemp5026cp_???? , alphabetic


qui {
foreach ind in 26 {
foreach sample in   "shocked" "podemp" "all" {  //

if "`sample'"=="shocked" {
local samp "& podemp`ind'_m10123==1"
local samp2 "& podemp`ind'_m0123==1"
local samp3 ""
local samp4 ""
}
else if "`sample'"=="all" {
local samp ""
local samp2 ""
local samp3 ""
local samp4 ""
}
else if "`sample'"=="podemp" {
local samp ""
local samp2 ""
local samp3 "ibn.age#c.podemp`ind'_m10123"
local samp4 "ibn.age#c.podemp`ind'_m0123"
}



local agestart=16
local ageend=16

local yearstart=1987
local yearend=1993

cap drop rowmax
egen rowmax=rowmax(`po'deltaemp50`ind'cp_`yearstart'-`po'deltaemp50`ind'cp_`yearend')
cap drop agex
gen agex=ageyear if age<=`ageend' & age>=`agestart' & cenyear==1990  & rowmax>0 
noi reg schatt ibn.agex  `samp3' ///
ibn.age#c.(`po'deltaemp50`ind'cp_`yearstart'-`po'deltaemp50`ind'cp_`yearend')   ///
if age<=`ageend' & age>=`agestart'  [aweight=wtper], nocons cluster(muncenso_cenyear)
drop agex rowmax
pause on
pause here 

}
}
}



outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 


reg deltaemp50`ind'cp_1yearp2 schatt podemp`ind'_m10123  ///
if age<=16 & age>=16   & cenyear==1990   [aweight=wtper], cluster(muncenso)


reg deltaemp50`ind'cp_1yearm1 schatt podemp`ind'_m10123  ///
if age<=16 & age>=16   & cenyear==1990   [aweight=wtper], cluster(muncenso)

reg deltaemp50`ind'cp_1yearp3 schatt podemp`ind'_m10123  ///
if age<=16 & age>=16   & cenyear==1990   [aweight=wtper], cluster(muncenso)

reg deltaemp50`ind'cp_1yearm2 schatt podemp`ind'_m10123  ///
if age<=16 & age>=16   & cenyear==1990   [aweight=wtper], cluster(muncenso)



reg deltaemp50`ind'cp_1yearp2 schatt   ///
if age<=16 & age>=16   & cenyear==1990  & podemp`ind'_m10123==1  [aweight=wtper], cluster(muncenso)


reg deltaemp50`ind'cp_1yearm1 schatt   ///
if age<=16 & age>=16   & cenyear==1990  & podemp`ind'_m10123==1 [aweight=wtper], cluster(muncenso)

reg deltaemp50`ind'cp_1yearp3 schatt   ///
if age<=16 & age>=16   & cenyear==1990  & podemp`ind'_m10123==1  [aweight=wtper], cluster(muncenso)

reg deltaemp50`ind'cp_1yearm2 schatt   ///
if age<=16 & age>=16   & cenyear==1990  & podemp`ind'_m10123==1 [aweight=wtper], cluster(muncenso)








pause on
pause here 
**/

cap log close

exit, STATA clear
































