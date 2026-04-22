
*the state is a little sketchy as some municipalities when I change them, they change state
*what i have done is taken the original muncenso zm state for the migration drop

*make sure winsor is installed





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



foreach sexy in "" "male" "fem"  {




use if age>8 & age<25 using "${workdir}temp7.dta", clear





if "`sexy'"=="male" {
keep if sex==1
}

if "`sexy'"=="fem" {
keep if sex==2
}




*note these are not just employed people!  (previously had empstatd==110 &)
*drop if muncenso==12



gen atgrade=(age-6==yrschl)


 
foreach thinger in age  { 
egen atgrade`thinger'=wtmean(atgrade), by(muncenso cenyear `thinger') weight(wtper)
egen total`thinger'=total(wtper), by(muncenso cenyear `thinger')
egen atgrade`thinger'nmig=wtmean(atgrade) if migrant==0, by(muncenso cenyear `thinger') weight(wtper)
egen total`thinger'nmig=total(wtper) if migrant==0, by(muncenso cenyear `thinger')
sort migrant
egen tag=tag(muncenso cenyear `thinger')
keep if tag
keep muncenso cenyear `thinger' atgrade`thinger'* total`thinger'*
}

save  "${dir}atgrade_byMun_Age_long_`sexy'.dta", replace



gen age2=.
gen atgradeage2=.
gen atgradeagenmig2=.
gen totalage2=.
gen totalagenmig2=.


levelsof age
foreach ager in `r(levels)' {

local ager1=`ager'+1

replace age2=`ager'`ager1' if age==`ager'

egen xatgradeage2=wtmean(atgradeage) if age==`ager' | age==`ager1', by(muncenso cenyear) weight(totalage)
egen xtotalage2=total(totalage) if age==`ager' | age==`ager1', by(muncenso cenyear)
egen xatgradeagenmig2=wtmean(atgradeagenmig) if age==`ager' | age==`ager1' , by(muncenso cenyear) weight(totalagenmig)
egen xtotalagenmig2=total(totalagenmig) if age==`ager' | age==`ager1', by(muncenso cenyear)

foreach X in atgradeage2 atgradeagenmig2 totalage2 totalagenmig2 {
replace `X'=x`X' if age==`ager'
drop x`X'
}


}

renvars atgrade* total* , postfix(Y)
renvars , sub(2Y X)

gen census="_90_" if cenyear==1990
replace census="_00_" if cenyear==2000
replace census="_96_" if cenyear==1996
drop cenyear age

reshape wide  atgradeageY atgradeagenmigY totalageY totalagenmigY atgradeageX atgradeagenmigX totalageX totalagenmigX , i(muncenso age2) j(census) string


qui ds *_
local stubs "`r(varlist)'"
reshape wide  `stubs' , i(muncenso) j(age2)



renvars *Y*, postdrop(2)


renvars *X*, sub(X )
renvars *Y*, sub(Y )


local subber ""
foreach varx of var atgrade*_00_* {

local subber=regexr("`varx'","00","90")

local subber2=regexr("`varx'","00","9000")
gen `subber2'=(`subber'+`varx')/2


}


if "`sexy'"=="male" {
renvars atg* tot* , prefix(m)
}

if "`sexy'"=="fem" {
renvars atg* tot* , prefix(f)
}

sort muncenso

save  "${dir}atgrade_byMun_Age_wide_`sexy'.dta", replace


}


use "${dir}atgrade_byMun_Age_wide_.dta", clear
keep muncenso atgrade*
renpfix atgrade eatgrade

sort muncenso
merge muncenso using "${dir}atgrade_byMun_Age_wide_male.dta"
keep muncenso eatgrade* matgrade*

sort muncenso
merge muncenso using "${dir}atgrade_byMun_Age_wide_fem.dta"
keep muncenso eatgrade* matgrade* fatgrade*

sort muncenso
merge muncenso using "${dir}atgrade_byMun_Age_wide_.dta"
keep muncenso eatgrade* matgrade* fatgrade* atgrade*


foreach varx of var *atgrade* {
cap gen `varx'=`varx'
cap gen `varx'qu=`varx'-`varx'*`varx'
cap gen `varx'sq=`varx'*`varx'
cap gen `varx'nm=normalden(`varx',0.5,0.25)
cap gen `varx'nm2=normalden(`varx',0.5,0.5)
}


foreach beg in  atgradeage {
foreach cenyr in 90 00 {
forval n=12/20 {
local np1=`n'+1
cap gen `beg'_`cenyr'_`n'm`np1'=`beg'_`cenyr'_`n'-`beg'_`cenyr'_`np1'
cap gen e`beg'_`cenyr'_`n'm`np1'=`beg'_`cenyr'_`n'-`beg'_`cenyr'_`np1'
}
}
}


sort muncenso



save  "${dir}atgrade_byMun_Age_wide.dta", replace

