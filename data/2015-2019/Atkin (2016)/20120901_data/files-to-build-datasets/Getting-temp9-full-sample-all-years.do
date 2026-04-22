


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

*this is where restricted smaple must be made

*variable to rename year
global agestart=8
local ageend=25

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="drop if cenyear==2006"
*these dropvars below may involve geographical info
global dropvar4="drop if muncenso==12 "

global dropvar5=""





global dropvar6="`edit'"

*-----------------------------------------------
*local expo=2
*this is how many years I average. So for age 15, with exposure=2, I average 15 and 16
*doesnt work with local. But only have to change weighted average of cohorts

noi local lhslist="yrschl2 yrschl  incearn"


noi local varlist=""

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


noi local lhslist="yrschl2 yrschl  incearn"


use  muncenso mgrate5 urban hrswrk1 educmx empstatd sex mx00a_imss occ ind* muncenso  hlthcov  cenyear age schatt empstatd  `lhslist' `varlist' wtper muncensoZM mig5mun${zone} `yeartrend' bplmx    using "${censodir}mexico_censo_05_regready${agestart}.dta", clear



forvalues i = `agestart1'/`ageend' {
*keep if cenyear==2000  



drop if muncenso${zone}==12
append using "${censodir}mexico_censo_05_regready`i'.dta", keep(muncenso mgrate5 urban hrswrk1 hlthcov educmx empstatd sex mx00a_imss occ ind* muncenso sex  cenyear age schatt empstatd   `lhslist' `varlist' wtper muncensoZM mig5mun${zone} `yeartrend' bplmx )
}

*keep if cenyear==2000
drop if muncenso${zone}==12

*note the ages must be changed in this

*drop if munmatch!=1 & muncensoZM>55


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




gen migrant=0 if  ( (muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew) & cenyear==2000 ) |  ( (mgrate5==10 | mgrate5==11) & (bplmx==stateold | bplmx==statenew) & (cenyear==1990|cenyear==1996) )  |  ( (mgrate5==10 | mgrate5==11) & (cenyear==2006) ) 
replace migrant=1 if migrant==.



sort muncenso

if "${munwork}"=="yes" {
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(state regio*)  _merge(_mergematch)
}
else {
merge  muncenso using "${dir}mungeogZM.dta" ,  keep(state regio*)  _merge(_mergematch)
}

drop if muncenso==12



gen wtper2=round(wtper)







*lpoly  lninc2000 age if cenyear==2000 & yrschl==9 & indimss2==22 & sex==1 [fweight=wtper], lpattern(solid) lcolor(dknavy) noscatter title("") ytitle("Log Income (Year 2000 Peso)") addplot(lpoly lninc2000 age if cenyear==2000 & yrschl==9 & indimss2==36 & sex==1 & age>17 [fweight=wtper], lpattern(solid) lcolor(eltgreen)   || lpoly  lninc2000 age if cenyear==1990 & yrschl==9 & indimss2==22 & sex==1 [fweight=wtper],lpattern(dash) lcolor(dknavy) || lpoly lninc2000 age if cenyear==1990 & yrschl==9 & indimss2==36 & sex==1 & age>17 [fweight=wtper],lpattern(dash) lcolor(eltgreen) ) legend( label(1 "High-Tech, 2000, S=9") label(2 "Services, 2000, S=12") label(3 "High-Tech, 1990, S=9") label(4 "Services, 1990, S=12") )
*graph save ${dir}wageprof, replace





*lpoly  lninc2000 age if cenyear==2000 & yrschl==9 & indimss2==22 & sex==1 & age>15  [fweight=wtper],    lpattern(solid) lcolor(dknavy) noscatter title("") ytitle("Log Monthly Income (Year 2000 Peso)") addplot(lpoly lninc2000 age if cenyear==2000 & yrschl==9 & indimss3==29 & sex==1 & age>18 [fweight=wtper],   lpattern(solid) lcolor(eltgreen) || lpoly  lninc2000 age if cenyear==1990 & yrschl==9 & indimss2==22 & sex==1 & age>15  [fweight=wtper],   lpattern(dash) lcolor(dknavy) || lpoly lninc2000 age if cenyear==1990 & yrschl==9 & indimss3==29 & sex==1 & age>18 [fweight=wtper],    lpattern(dash) lcolor(eltgreen) ) legend( label(1 "High-Tech, 2000, S=9") label(2 "Prof. Services, 2000, S=12") label(3 "High-Tech, 1990, S=9") label(4 "Prof. Services, 1990, S=12") )

*lpoly  lninc2000 age if cenyear==2000 & yrschl==9 & indimss3==34 & sex==1 & age>15  [fweight=wtper], bw(1.5)   lpattern(solid) lcolor(dknavy) noscatter title("") ytitle("Log Monthly Income (Year 2000 Peso)") addplot(lpoly lninc2000 age if cenyear==2000 & yrschl==12 & indimss3==29 & sex==1 & age>18 [fweight=wtper], bw(1.5)  lpattern(solid) lcolor(eltgreen) || lpoly  lninc2000 age if cenyear==1990 & yrschl==9 & indimss3==34 & sex==1 & age>15  [fweight=wtper], bw(1.5)  lpattern(dash) lcolor(dknavy) || lpoly lninc2000 age if cenyear==1990 & yrschl==12 & indimss3==29 & sex==1 & age>18 [fweight=wtper],   bw(1.5) lpattern(dash) lcolor(eltgreen) ) legend( label(1 "High-Tech, 2000, S=9") label(2 "Prof. Services, 2000, S=12") label(3 "High-Tech, 1990, S=9") label(4 "Prof. Services, 1990, S=12") )

*graph save ${dirwages}wageprof2, replace
*change axis and get rid of kernal info






gen techsch=210 if educmx>=210 & educmx<220
replace techsch=220 if educmx>=220 & educmx<230
replace techsch=310 if educmx>=310 & educmx<320
replace techsch=320 if educmx>=320 & educmx<330
label values techsch educmxlbl

keep   age educmx techsch empstatd cenyear yrschl wtper wtper2 sex regio* schatt empstatd state muncenso migrant urban hrswrk1 
}
save "${workdir}temp9.dta", replace

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

