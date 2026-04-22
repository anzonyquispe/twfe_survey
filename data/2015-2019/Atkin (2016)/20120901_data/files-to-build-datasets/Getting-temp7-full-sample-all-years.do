
*the state is a little sketchy as some municipalities when I change them, they change state
*what i have done is taken the original muncenso zm state for the migration drop


*note I have a new set of graphs


clear 
set mem 6000m
set matsize 5000
set maxvar 30000



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
}




*-----------------------------------------------





*-----------------------------------------------
*global cutoff=50
*local lcutoff=50

global zone="ZM"
global munwork="yes"


*-----------------------------------------------

*these are exposure years
*age 13 is first age I have cohort data for at present (redo censo create for younger ages)

*this is where restricted smaple must be made

*variable to rename year
global agestart=12
local ageend=90

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="drop if cenyear==2006"
*these dropvars below may involve geographical info
global dropvar4="drop if muncenso==12 "

global dropvar5=""






global dropvar6="`edit'"
*SCHEDIT: global dropvar6="keep if yrschl>5 & yrschl<13 & schatt!=1"
*-----------------------------------------------
*local expo=2
*this is how many years I average. So for age 15, with exposure=2, I average 15 and 16
*doesnt work with local. But only have to change weighted average of cohorts

noi local lhslist="yrschl2 yrschl  incearn"

noi local varlist=""



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


noi local lhslist="yrschl2 yrschl  incearn"


use  muncenso mgrate5 urban hrswrk1 educmx empstatd sex mx00a_imss occ ind* muncenso  hlthcov  cenyear age schatt empstatd  `lhslist' `varlist' wtper muncensoZM mig5mun${zone} `yeartrend' bplmx    using "${censodir}mexico_censo_05_regready${agestart}.dta", clear



forvalues i = `agestart1'/`ageend' {
*keep if cenyear==2000  



drop if muncenso${zone}==12
append using "${censodir}mexico_censo_05_regready`i'.dta", keep(muncenso mgrate5 urban hrswrk1 hlthcov educmx empstatd sex mx00a_imss occ ind* muncenso sex  cenyear age schatt empstatd   `lhslist' `varlist' wtper muncensoZM mig5mun${zone} `yeartrend' bplmx )
}


drop if muncenso${zone}==12

*note the ages must be changed in this



cap replace incearn=. if incearn==99999998 | incearn==99999999
cap gen incearnall=incearn
replace incearnall=0 if incearn==. 
cap gen incearnln=log(incearn)
cap gen hhincomepcln=log(hhincomepc)




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

*drop cenyear mgrate5 
*drop if tot${variable}${gender2}${gender}${cutoff}${industry}==0 



gen migrant=0 if  ( (muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew) & cenyear==2000 ) |  ( (mgrate5==10 | mgrate5==11) & (bplmx==stateold | bplmx==statenew) & (cenyear==1990|cenyear==1996) )  |  ( (mgrate5==10 | mgrate5==11) & (cenyear==2006) ) 
replace migrant=1 if migrant==.

pause on
pause here 


gen inc2000=incearn/(0.9742856) if cenyear==2000
replace inc2000=incearn/(1000*0.1708465) if cenyear==1990
replace inc2000=incearn/(0.4402919) if cenyear==1996
*from quarterly cpi on oecd site






do "${dir}industry_to_imss_classification.do"

do  "${dir}Occupation_codes_2digit.do"
drop occ


gen lninc2000=log(inc2000)







gen indimss3=24 if indimss==4 | indimss==2
replace indimss3=33 if indimss==3 | indimss==6
replace indimss3=34 if indimss==5 | indimss==1
replace indimss3=7 if indimss==7 
replace indimss3=29 if indimss==11|indimss==12 |indimss==13 
replace indimss3=26 if indimss==9|indimss==10|indimss==14

gen indimss2=23 if indimss==3 | indimss==6 |indimss==5 | indimss==1
replace indimss2=24 if indimss==4 | indimss==2
replace indimss2=7 if indimss==7 
replace indimss2=36 if indimss==11|indimss==12 |indimss==13 | indimss==9|indimss==10|indimss==14


label define indimss 2 "Low-Tech Non-Export Manuf." 4 "High-Tech Non-Export Manuf." 33 "Low-Tech Export Manuf." 34 "High-Tech Export Manuf." 29 "Professional Services" 26 "Commerce Etc." 7 "Construction" 36  "Services" 23 "Exported Manuf." 24 "Non-Exported Manuf." 
 
label values indimss2 indimss
label values indimss3 indimss


*replace wtper=round(wtper)

sort muncenso

if "${munwork}"=="yes" {
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(state regio*)  _merge(_mergematch)
}
else {
merge  muncenso using "${dir}mungeogZM.dta" ,  keep(state regio*)  _merge(_mergematch)
}

*keep if schatt==0
*dropping all currently at school
*keep if age>14 & age<55
drop if muncenso==12
*sum lninc2000 if cenyear==2000 &  muncenso!=12 & muncenso!=13066 & muncenso!=13075 & muncenso!=20434 & sex==1 & age>15 & age<29 [w=wtper]

sum lninc2000 if cenyear==2000   & sex==1 & age>15 & age<29 [w=wtper]


gen wtper2=round(wtper)





gen techsch=210 if educmx>=210 & educmx<220
replace techsch=220 if educmx>=220 & educmx<230
replace techsch=310 if educmx>=310 & educmx<320
replace techsch=320 if educmx>=320 & educmx<330
label values techsch educmxlbl

keep  lninc2000 age educmx techsch empstatd cenyear yrschl wtper wtper2 mx00a_imss sex ind indimss indimss3 indimss2 regio* schatt empstatd state muncenso migrant urban hrswrk1 occ2 bluecollar hlthcov
}
save "${workdir}temp7.dta", replace

pause on
pause here 



egen migprop=wtmean(migrant) if mx00a_imss==1, by(muncenso indimss3) weight(wtper)
egen tag=tag(muncenso indimss3) if mx00a_imss==1

keep if tag==1

keep muncenso indimss3 migprop


reshape wide   migprop ,i(muncenso) j( indimss3)
mvencode migprop*, mv(0) override

sort muncenso


save "${dir}mig_industry_counts.dta", replace

*these are migrants as a proportion of total working population in formal sector in that municipality in 2000.

