
*this file runs the long change regression in Table 3.


clear all
set mem 6500m
set matsize 10000
set maxvar 32000




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
global resultdir="C:\Work\Mexico\Revision\regout\"
global tempdir="C:\Scratch\"
}


global zone="ZM"
global munwork="yes"



set more off





use "${workdir}cohortmeans_mwyes_2000.dta", clear
keep if age==16
gen cenyear=2000
keep cenyear age muncenso *schatt* *yrschl* 
merge 1:1 muncenso age cenyear  using "${dir}atgrade_byMun_Age_long_.dta", keepusing(atgrade*) keep(master match)
drop _merge
merge 1:1 muncenso age cenyear  using "${dir}schatgrade_byMun_Age_long_.dta", keepusing(schatgrade*) keep(master match)
drop _merge
save "${tempdir}cut_cohortmeans_mwyes_2000.dta", replace

use "${workdir}cohortmeans_mwyes_1990.dta", clear
keep if age==15
gen cenyear=1990
keep cenyear age muncenso *schatt* *yrschl*  
merge 1:1 muncenso age cenyear  using "${dir}atgrade_byMun_Age_long_.dta", keepusing(atgrade*) keep(master match)
drop _merge
merge 1:1 muncenso age cenyear  using "${dir}schatgrade_byMun_Age_long_.dta", keepusing(schatgrade*) keep(master match)
drop _merge
replace cenyear=1991
save "${tempdir}cut_cohortmeans_mwyes_1991.dta", replace

use "${workdir}cohortmeans_mwyes_1990.dta", clear
keep if age==17
gen cenyear=1990
keep cenyear age muncenso *schatt* *yrschl*  
*drop*10*
merge 1:1 muncenso age cenyear  using "${dir}atgrade_byMun_Age_long_.dta", keepusing(atgrade*) keep(master match)
drop _merge
merge 1:1 muncenso age cenyear  using "${dir}schatgrade_byMun_Age_long_.dta", keepusing(schatgrade*) keep(master match)
drop _merge
replace cenyear=1989
save "${tempdir}cut_cohortmeans_mwyes_1989.dta", replace

use "${workdir}cohortmeans_mwyes_1990.dta", clear
keep if age==18
gen cenyear=1990
keep cenyear age muncenso *schatt* *yrschl*  
*drop*10*
merge 1:1 muncenso age cenyear  using "${dir}atgrade_byMun_Age_long_.dta", keepusing(atgrade*) keep(master match)
drop _merge
merge 1:1 muncenso age cenyear  using "${dir}schatgrade_byMun_Age_long_.dta", keepusing(schatgrade*) keep(master match)
drop _merge
replace cenyear=1988
save "${tempdir}cut_cohortmeans_mwyes_1988.dta", replace

use "${workdir}cohortmeans_mwyes_1990.dta", clear
keep if age==16
gen cenyear=1990
keep cenyear age muncenso *schatt* *yrschl* 
*drop*10*
merge 1:1 muncenso age cenyear  using "${dir}atgrade_byMun_Age_long_.dta", keepusing(atgrade*) keep(master match)
drop _merge
merge 1:1 muncenso age cenyear  using "${dir}schatgrade_byMun_Age_long_.dta", keepusing(schatgrade*) keep(master match)
drop _merge
append using "${tempdir}cut_cohortmeans_mwyes_2000.dta"
append using "${tempdir}cut_cohortmeans_mwyes_1991.dta"
append using "${tempdir}cut_cohortmeans_mwyes_1989.dta"
append using "${tempdir}cut_cohortmeans_mwyes_1988.dta"

renpfix atgrade eclatgrade
renpfix schatgrade eclschatgrade

preserve
keep age muncenso cenyear fcl*
gen sex=2
renpfix fcl cl
save "${tempdir}tempxsex2.dta", replace
restore
preserve
keep age muncenso cenyear mcl*
gen sex=1
renpfix mcl cl
save "${tempdir}tempxsex3.dta", replace
restore
keep age muncenso cenyear ecl*
gen sex=0
append using "${tempdir}tempxsex2.dta"
append using "${tempdir}tempxsex3.dta"
erase "${tempdir}tempxsex2.dta"
erase "${tempdir}tempxsex3.dta"

save "${tempdir}cut_cohortmeans_mwyes_2000_1990.dta", replace

use muncenso yobexp  region* state q16* age  using "${workdir}reg2year_mwyes_2000_july11_genericskill_none_cen90_1yrexp.dta", clear




compress


gen cenyear=2000 if yobexp==1983
replace cenyear=1990 if yobexp==1973



sort muncenso
merge m:m muncenso cenyear using "${tempdir}cut_cohortmeans_mwyes_2000_1990.dta"
drop _merge

egen muncenso_sex=group(muncenso sex)

drop if muncenso_sex==.

cap d q16*fem*fsc*

if _rc==0 {
qui {
*this makes a measure that takes teh appropraite sex value
foreach var of varlist q16*fem*fsc* {
local submale=regexr("`var'","fem","male")
local submale=regexr("`submale'","fsc","msc")
local subneut=regexr("`var'","fem","sex")
local subneut=regexr("`subneut'","fsc","ssc")
gen `subneut'=`var' if sex==2
replace  `subneut'=`submale' if sex==1
}
}
}

**/
compress
xtset muncenso_sex cenyear  


*so now I have
*A: Long changes in employment
*B: Long changes in employment (Bartik stylez)
*C:Reshape wide to have both sexes: note that I don't know the proportion of skills broken down by sex-only know proportion within sex
*at present I use the proportion within sex multiplied by sex proportions from imss
*assume for bartik that national growth rate of jobs is not sex specific



foreach ind in 26 {  
local regname "_May14_`ind'"

cap erase "${tempdir}long_change`regname'.txt"
cap erase "${tempdir}long_change`regname'.xml"

foreach schoolvar in schatt  {

*this is FD version
reg  s10.ecl`schoolvar'  s10.q16emp00`ind'cp   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel


*this is FD version  with initial level
reg  s10.ecl`schoolvar'  s10.q16emp00`ind'cp  l10.ecl`schoolvar'   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel

*this is FD version  with initial level
reg  s10.ecl`schoolvar'  s10.q16emp00`ind'cp  l11.ecl`schoolvar'   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel




*this is FD version using IV and large expansions
ivreg  s10.ecl`schoolvar'  (s10.q16emp00`ind'cp=s10.q16empx50`ind'cp)   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel ctitle("IV")




ivreg  s10.ecl`schoolvar'  (s10.q16emp00`ind'cp l10.ecl`schoolvar'=s10.q16empx50`ind'cp l11.ecl`schoolvar')     [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel ctitle("IV including lagsch")

*this is FD version using IV and large expansions and initial level
ivreg  s10.ecl`schoolvar'  (s10.q16emp00`ind'cp=s10.q16empx50`ind'cp)  l11.ecl`schoolvar'   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel ctitle("IV")



*this is FD version with only large expansions
reg  s10.ecl`schoolvar'  s10.q16empx50`ind'cp   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel


*this is FD version with only large expansions and initial level
reg  s10.ecl`schoolvar' s10.q16empx50`ind'cp l10.ecl`schoolvar'   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel

*this is FD version with only large expansions and initial level
reg  s10.ecl`schoolvar' s10.q16empx50`ind'cp l11.ecl`schoolvar'   [w=l10.eclwtschatt]
outreg2 using "${tempdir}long_change`regname'", excel





}

cap copy "${tempdir}long_change`regname'.txt" "${resultdir}long_change`regname'.txt", replace
cap copy "${tempdir}long_change`regname'.xml" "${resultdir}long_change`regname'.xml", replace

}

**/
