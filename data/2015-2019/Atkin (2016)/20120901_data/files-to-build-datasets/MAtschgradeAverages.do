



clear all
set mem 5000m
set matsize 11000
set maxvar 30000



set more off
matrix drop  _all



if "`c(os)'"=="Unix" {
global firmdir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global inddir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global dir "/home/fac/da334/Work/Mexico/"
global dirmaq "/home/fac/da334/Work/Mexico/Maquiladora Data/"
}

if "`c(os)'"=="Windows" {
global censodir="C:/Data/Mexico/mexico_censo/"
global firmdir="C:/Data/Mexico/mexico_ss_Stata/"
global workdir="C:/Data/Mexico/Stata10/"
global inddir="C:/Data/Mexico/mexico_ss_Stata/"
global dir="C:/Work/Mexico/"
global dirwages="C:/Work/wages/"
global dirmaq="C:/Work/Mexico/Maquiladora Data/"
global tempdir="C:/Scratch/"
}



foreach sexy in  "" "male" "fem" {






use if age>9 & age<25 using "${workdir}temp9.dta", clear





if "`sexy'"=="male" {
keep if sex==1
}

if "`sexy'"=="fem" {
keep if sex==2
}




*note these are not just employed people!  (previously had empstatd==110 &)
*drop if muncenso==12




gen notatgrade=(age-6>yrschl)
gen notatgradex=(age-7>yrschl)

*this is the proportion of cohort that is both at school & not at grade.
gen schatgrade=(notatgrade==1 & schatt==1)
*replace schatgrade=. if schatt==0
gen schatgradex=(notatgradex==1 & schatt==1)

*this is the proportion of cohort that is both at school & at grade.
gen schatgradey=(notatgrade==0 & schatt==1)
*replace schatgrade=. if schatt==0
gen schatgradez=(notatgradex==0 & schatt==1)


*this is the proportion of cohort that is both at school & at grade.
gen schatgradea=(age-6<=yrschl)
*replace schatgrade=. if schatt==0
gen schatgradeb=(age-7<=yrschl)





foreach thinger in age  { 
egen schatgrade`thinger'=wtmean(schatgrade), by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'x=wtmean(schatgradex), by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'y=wtmean(schatgradey), by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'z=wtmean(schatgradez), by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'a=wtmean(schatgradea), by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'b=wtmean(schatgradeb), by(muncenso cenyear `thinger') weight(wtper)
egen total`thinger'=total(wtper), by(muncenso cenyear `thinger')
egen schatgrade`thinger'nmig=wtmean(schatgrade) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'xnmig=wtmean(schatgradex) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'ynmig=wtmean(schatgradey) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'znmig=wtmean(schatgradez) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'anmig=wtmean(schatgradea) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen schatgrade`thinger'bnmig=wtmean(schatgradeb) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen total`thinger'nmig=total(wtper) if migrant==0, by(muncenso cenyear `thinger')
sort migrant
egen tag=tag(muncenso cenyear `thinger')
keep if tag
keep muncenso cenyear `thinger' schatgrade`thinger'* total`thinger'*
}

save  "${dir}schatgrade_byMun_Age_long_`sexy'.dta", replace
**/

use  "${dir}schatgrade_byMun_Age_long_`sexy'.dta", clear


gen age2=.
gen schatgradeage2=.
gen schatgradeagenmig2=.
gen schatgradeagex2=.
gen schatgradeagez2=.
gen schatgradeagey2=.
gen schatgradeagea2=.
gen schatgradeageb2=.
gen schatgradeagexnmig2=.
gen schatgradeageynmig2=.
gen schatgradeageznmig2=.
gen schatgradeageanmig2=.
gen schatgradeagebnmig2=.
gen totalage2=.
gen totalagenmig2=.


levelsof age
foreach ager in `r(levels)' {

local ager1=`ager'+1

replace age2=`ager'`ager1' if age==`ager'

egen xschatgradeage2=wtmean(schatgradeage) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xschatgradeagex2=wtmean(schatgradeagex) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xschatgradeagey2=wtmean(schatgradeagey) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xschatgradeagez2=wtmean(schatgradeagez) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xschatgradeagea2=wtmean(schatgradeagea) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xschatgradeageb2=wtmean(schatgradeageb) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xtotalage2=total(totalage) if age==`ager' | age==`ager1', by(muncenso cenyear)
egen xschatgradeagenmig2=wtmean(schatgradeagenmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xschatgradeagexnmig2=wtmean(schatgradeagexnmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xschatgradeageynmig2=wtmean(schatgradeageynmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xschatgradeageznmig2=wtmean(schatgradeageznmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xschatgradeageanmig2=wtmean(schatgradeageanmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xschatgradeagebnmig2=wtmean(schatgradeagebnmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xtotalagenmig2=total(totalagenmig) if age==`ager' | age==`ager1', by(muncenso cenyear)

foreach X in schatgradeage2 schatgradeagenmig2 totalage2 totalagenmig2 schatgradeagex2 schatgradeagexnmig2 schatgradeagey2 schatgradeageynmig2 schatgradeagez2 schatgradeageznmig2 schatgradeagea2 schatgradeageanmig2 schatgradeageb2 schatgradeagebnmig2 {
replace `X'=x`X' if age==`ager'
drop x`X'
}


}
*/


renvars schatgrade* total* , postfix(Y)
renvars , sub(2Y X)

gen census="_90_" if cenyear==1990
replace census="_00_" if cenyear==2000
replace census="_96_" if cenyear==1996
drop cenyear age

reshape wide schatgradeageY schatgradeagenmigY schatgradeagexY schatgradeagexnmigY schatgradeageyY schatgradeageynmigY schatgradeagezY schatgradeageznmigY schatgradeageaY schatgradeageanmigY schatgradeagebY schatgradeagebnmigY totalageY totalagenmigY schatgradeageX schatgradeagenmigX schatgradeagexX schatgradeagexnmigX schatgradeageyX schatgradeageynmigX schatgradeagezX schatgradeageznmigX schatgradeageaX schatgradeageanmigX schatgradeagebX schatgradeagebnmigX totalageX totalagenmigX , i(muncenso age2) j(census) string



qui ds *_
local stubs "`r(varlist)'"
reshape wide  `stubs' , i(muncenso) j(age2)



renvars *Y*, postdrop(2)


renvars *X*, sub(X )
renvars *Y*, sub(Y )


local subber ""
foreach varx of var schatgrade*_00_* {

local subber=regexr("`varx'","00","90")

local subber2=regexr("`varx'","00","9000")
gen `subber2'=(`subber'+`varx')/2


}


if "`sexy'"=="male" {
renvars schatg* tot* , prefix(m)
}

if "`sexy'"=="fem" {
renvars schatg* tot* , prefix(f)
}

sort muncenso

save  "${dir}schatgrade_byMun_Age_wide_`sexy'.dta", replace


}


use "${dir}schatgrade_byMun_Age_wide_.dta", clear
keep muncenso schatgrade*
renpfix schatgrade eschatgrade

sort muncenso
merge muncenso using "${dir}schatgrade_byMun_Age_wide_male.dta"
keep muncenso eschatgrade* mschatgrade*

sort muncenso
merge muncenso using "${dir}schatgrade_byMun_Age_wide_fem.dta"
keep muncenso eschatgrade* mschatgrade* fschatgrade*

sort muncenso
merge muncenso using "${dir}schatgrade_byMun_Age_wide_.dta"
keep muncenso eschatgrade* mschatgrade* fschatgrade* schatgrade*


foreach varx of var *schatgrade* {
cap gen `varx'=`varx'
cap gen `varx'qu=`varx'-`varx'*`varx'
cap gen `varx'sq=`varx'*`varx'
cap gen `varx'nm=normalden(`varx',0.5,0.25)
cap gen `varx'nm2=normalden(`varx',0.5,0.5)
}


foreach beg in  schatgradeage schatgradeagex schatgradeagey schatgradeagez schatgradeagea schatgradeageb {
foreach cenyr in 90 00 {
forval n=11/20 {
local np1=`n'+1
cap gen `beg'_`cenyr'_`n'm`np1'=`beg'_`cenyr'_`n'-`beg'_`cenyr'_`np1'
cap gen e`beg'_`cenyr'_`n'm`np1'=`beg'_`cenyr'_`n'-`beg'_`cenyr'_`np1'
}
}
}


sort muncenso



save  "${dir}schatgrade_byMun_Age_wide.dta", replace

