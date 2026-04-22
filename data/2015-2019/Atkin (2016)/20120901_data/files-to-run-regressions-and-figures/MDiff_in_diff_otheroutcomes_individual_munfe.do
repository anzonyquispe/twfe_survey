
/**
*this file generates
Tshort_byyear_manyage_1990_individualq__all_munfe_26.pdf (Figure C.4)
and Table C.3 which appears in paper
**/

clear all
set mem 7500m
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
global scratch="C:/Scratch/"
global dirgraph="C:/Work/Mexico/Revision/Graphs/"
global regout="C:/Work/Mexico/Revision/regout/"
}


foreach ind in 26    { //

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





local other=regexr("16 26 46","`ind'","")

local other2=regexr("17 27 47","`ind2'","")

local other3=regexr("15 25 45","`ind3'","")

local other4=regexr("19 29 49","`ind4'","")

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
local schoolmeasure_list "schatgradey schatgradea"  // for parents regs this goes on lefthand side


local parents "famind`ind' famindall momindall" // show parental employment effects

local school "yrschl"




********Strategy 4. Some sort of multi-year specification (can only do in 1990 if want forward lags)


foreach sample in "all" "shocked"   { // "podemp"

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

foreach po in ""  {  // "po"

local agestart=12

foreach table in short   indother  {  // short     grade     long  schatt ind19 indother employ  informal indother indotherprop indotherpropns

local fileend "individualq_`po'_`sample'_munfe_`ind'"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml"
cap erase "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.txt"

foreach lhs in ``table'' {  //  



cap drop agex
gen agex=ageyear if age<=19 & age>=`agestart' & cenyear==1990   `samp'
areg `lhs' ibn.agex `samp3' ///
i12.age#c.`po'deltaemp50`ind'cp_1992   ///
i13.age#c.`po'deltaemp50`ind'cp_1992   ///
i14.age#c.`po'deltaemp50`ind'cp_1992   ///
i15.age#c.`po'deltaemp50`ind'cp_1992   ///
i17.age#c.`po'deltaemp50`ind'cp_1992   ///
i18.age#c.`po'deltaemp50`ind'cp_1992   ///
i19.age#c.`po'deltaemp50`ind'cp_1992   ///
i12.age#c.`po'deltaemp50`ind'cp_1991   ///
i13.age#c.`po'deltaemp50`ind'cp_1991   ///
i14.age#c.`po'deltaemp50`ind'cp_1991   ///
i15.age#c.`po'deltaemp50`ind'cp_1991   ///
i17.age#c.`po'deltaemp50`ind'cp_1991   ///
i18.age#c.`po'deltaemp50`ind'cp_1991   ///
i19.age#c.`po'deltaemp50`ind'cp_1991   ///
i12.age#c.`po'deltaemp50`ind'cp_1990   ///
i13.age#c.`po'deltaemp50`ind'cp_1990   ///
i14.age#c.`po'deltaemp50`ind'cp_1990   ///
i15.age#c.`po'deltaemp50`ind'cp_1990   ///
i17.age#c.`po'deltaemp50`ind'cp_1990   ///
i18.age#c.`po'deltaemp50`ind'cp_1990   ///
i19.age#c.`po'deltaemp50`ind'cp_1990   ///
i12.age#c.`po'deltaemp50`ind'cp_1989   ///
i13.age#c.`po'deltaemp50`ind'cp_1989   ///
i14.age#c.`po'deltaemp50`ind'cp_1989   ///
i15.age#c.`po'deltaemp50`ind'cp_1989   ///
i17.age#c.`po'deltaemp50`ind'cp_1989   ///
i18.age#c.`po'deltaemp50`ind'cp_1989   ///
i19.age#c.`po'deltaemp50`ind'cp_1989   ///
i12.age#c.`po'deltaemp50`ind'cp_1988   ///
i13.age#c.`po'deltaemp50`ind'cp_1988   ///
i14.age#c.`po'deltaemp50`ind'cp_1988   ///
i15.age#c.`po'deltaemp50`ind'cp_1988   ///
i17.age#c.`po'deltaemp50`ind'cp_1988   ///
i18.age#c.`po'deltaemp50`ind'cp_1988   ///
i19.age#c.`po'deltaemp50`ind'cp_1988   ///
i12.age#c.`po'deltaemp50`ind'cp_1987   ///
i13.age#c.`po'deltaemp50`ind'cp_1987   ///
i14.age#c.`po'deltaemp50`ind'cp_1987   ///
i15.age#c.`po'deltaemp50`ind'cp_1987   ///
i17.age#c.`po'deltaemp50`ind'cp_1987   ///
i18.age#c.`po'deltaemp50`ind'cp_1987   ///
i19.age#c.`po'deltaemp50`ind'cp_1987   ///
if age<=19 & age>=`agestart'  [aweight=wtper], a(muncenso_cenyear) cluster(muncenso_cenyear)
drop agex
outreg2 using "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'" , excel nonotes nocons ctitle("`lhs'") 

gen sample=e(sample)
egen group=group(muncenso) if sample==1
noi sum group
drop group sample


forval yr=1987/1992 {
foreach n of numlist `agestart'/15 17/19 {
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

foreach n of numlist `agestart'/15 17/19 {
gen age_`n'=.
}

forval yr=1987/1992 {
foreach n of numlist `agestart'/15 17/19 {
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


twoway line age_12 age_13 age_14 age_15  age_17  age_18 age_19  year_midpoint if year>=1987 & year<=1992 , lpattern(dash dot dash_dot shortdash shortdash_dot longdash longdash_dot "_--") lwidth(thin thin thin thin thin thin thin thin)   ///
legend(col(4) label(1 "age 12") label(2 "age 13") label(3 "age 14") label(4 "age 15") label(5 "age 17") label(6 "age 18") label(7 "age 19")) ///
title("`lhsneat'") ///
note("") ytitle("") xtitle("") saving("${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'", replace) xlab(1987(1)1993) xline(1990.2)  ylab(-2(2)2)
graph export "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.pdf", replace
graph export "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.emf", replace




restore


}

local comblist ""
local comblist16 ""
foreach lhs in ``table'' {
local comblist `"`comblist' "${dirgraph}I`lhs'_byyear_manyage_1990_`fileend'.gph""'
local comblist16 `"`comblist16' "${dirgraph}I`lhs'_byyear_16_1990_`fileend'.gph""'
}


grc1leg `comblist' , ring(3) xcommon ycommon col(3) iscale(0.67) imargin(0 2 2)   l1title("Deviations (relative to effects at age 16)") b1title("Year of export employment shock")
cap graph save "${dirgraph}T`table'_byyear_manyage_1990_`fileend'.gph", replace
cap graph export "${dirgraph}T`table'_byyear_manyage_1990_`fileend'.pdf", replace
cap graph export "${dirgraph}T`table'_byyear_manyage_1990_`fileend'.emf", replace

copy "${scratch}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml" "${regout}July2014_`ind'_Diff_in_Diff_`table'_1990_v`fileend'.xml", replace
}

**/











}
*po

}
*sample

}


exit, STATA clear












































