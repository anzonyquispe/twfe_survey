







* this file gets new municipality lists where I merge municipalities wher emore than 10% of population work somewhere else.
*needs reg ready cohort data broken down by ages



clear 
set mem 1300m
set matsize 2000
set maxvar 15000



set more off




if "`c(os)'"=="Unix" {
local inddir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global dir "/home/fac/da334/Work/Mexico/"
global dirmaq "/home/fac/da334/Work/Mexico/Maquiladora Data/"
}

if "`c(os)'"=="Windows" {
local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
global dirmaq="C:\Work\Mexico\Maquiladora Data\"
global censodir="C:\Data\Mexico\mexico_censo\"
global dir="C:\Work\Mexico\"
global workdir="C:\Data\Mexico\Stata10\"
global firmdir="C:\Data\Mexico\mexico_ss_Stata\"
}










local yearend=2000
*this is the last year of firm data I end up using
*change to 2006 if use the 2006 data




*-----------------------------------------------





*-----------------------------------------------
*global cutoff=50
*local lcutoff=50

global zone="ZM"



*-----------------------------------------------


*this is where restricted smaple must be made

*variable to rename year
global agestart=12
local ageend=55

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="keep if cenyear==2000"

global dropvar4=""

*these dropvars below may involve geographical info and don't cover the workmun info

*-----------------------------------------------


local counter=0


local agestart1=${agestart}+1
local ageend1=`ageend'-1

*=====================================================


use cenyear muncenso${zone} munwork${zone} wtper    using "${workdir}mexico_censo_05_regready${agestart}.dta", clear

forvalues i = `agestart1'/`ageend' {

append using "${workdir}mexico_censo_05_regready`i'.dta", keep(cenyear muncenso${zone} munwork${zone} wtper ) nolabel
}

*note the ages must be changed in this









if "${zone}"=="ZM" {

rename muncensoZM muncenso


rename munworkZM munwork
}

${dropvar1}
${dropvar2}
${dropvar3}
${dropvar4}
















*note this is total pop not working pop


keep muncenso munwork wtper 




egen munworkwt=total(wtper), by(muncenso munwork)


egen tagmunwork=tag( muncenso munwork )
keep if tagmunwork==1
drop tagmunwork

egen munworktot=total(munworkwt), by(muncenso)
gen munworkrat=munworkwt/munworktot

*this stops mexico city counting as a nearbye municipality. Bit worried about what that would be doing to bias the data.
*drop if munwork==12

*keep muncenso mungroup munworkwt munwork munworkrat
keep muncenso  munworkwt munwork munworkrat

compress




gen tenperc=1 if  munworkrat>=0.1 &  muncenso!= munwork

replace tenperc=0 if  muncenso==munwork

egen countmunwork=count(munwork) if tenperc!=.,by(munwork)
egen countmuncenso=count(muncenso) if tenperc!=.,by(muncenso)

drop if tenperc==.


save "${workdir}munworkdatatemp1.dta", replace

egen tagmun=tag(muncenso)
keep if tagmun==1
keep muncenso countmuncenso 
rename countmuncenso munworksends

rename muncenso munwork
sort munwork
save "${workdir}munworkdatatemp2.dta", replace


use "${workdir}munworkdatatemp1.dta", clear
egen tagmun=tag(munwork)
keep if tagmun==1
keep munwork countmunwork 
rename countmunwork munworkrecieves
sort munwork
save "${workdir}munworkdatatemp4.dta", replace

rename munworkrecieves muncensorecieves



rename  munwork muncenso
sort muncenso
save "${workdir}munworkdatatemp3.dta", replace


















use "${workdir}munworkdatatemp1.dta", clear

sort munwork 
merge munwork using "${workdir}munworkdatatemp2.dta", nokeep 
drop _merge

sort munwork 
merge munwork using "${workdir}munworkdatatemp4.dta", nokeep 
drop _merge

sort muncenso 
merge muncenso using "${workdir}munworkdatatemp3.dta", nokeep 
drop _merge




*now any municipality with a value of 1 for countmunwork and countmuncenso should not be changed.
gen newmun=muncenso if tenperc!=. & countmunwork==1 & countmuncenso==1
gen type=1 if tenperc!=. & countmunwork==1 & countmuncenso==1


*now merge the non zm's into ZM's (no two zm's merge at least for 10% cutoffs. check for 5)
*this only merges places that don't also send people to other places
replace newmun=munwork if tenperc!=. & countmunwork>1 & countmuncenso==2 & munworksends==1 & muncenso!=munwork & muncensorecieves==1
replace type=2 if tenperc!=. & countmunwork>1 & countmuncenso==2 & munworksends==1 & muncensorecieves==1 & muncenso!=munwork
* this codes as type 2 anything where municipality sends just to one other, who does not send to anyone else. This
*merges making the sending municipality the same as the recieving



*now we deal with more difficult situation where mun send people in two different situations

replace newmun=munwork if tenperc!=. & countmunwork>1 & countmuncenso==3 & muncenso!=munwork & munworksends==1 & muncensorecieves==1
replace type=3 if tenperc!=. & countmunwork>1 & countmuncenso==3 & munworksends==1 & muncensorecieves==1 & muncenso!=munwork
*this takes places that send to two municipalities and gives it the code of the recieving municipality if the sending municipality recieves from no one
*and the recieving municipality does not send (case 2). This produces two muns as I will split weights between


*now this is the ZM's or the places where people commute to but no one commutes from
replace newmun=munwork if tenperc!=. & countmunwork>1 & countmuncenso==1 & munworksends==1 & muncensorecieves>1
replace type=4 if tenperc!=. & countmunwork>1 & countmuncenso==1 & munworksends==1 & muncensorecieves>1
*this names muns where they recieve but do not send




egen countnewmun=count(newmun), by(muncenso)



replace newmun=muncenso if countnewmun==0 & muncenso==munwork & countmunwork==1  & muncensorecieves==1
replace type=5 if countnewmun==0 & muncenso==munwork & countmunwork==1  & muncensorecieves==1
*in sandwich case this labels the initial sender on chain its own mun

gen oldmun=muncenso
 
replace newmun=muncenso if countnewmun==0 & muncenso!=munwork & countmunwork==2 & muncensorecieves==1 & munworksends==2 &  munworkrecieves==2 
replace oldmun=munwork if countnewmun==0 & muncenso!=munwork & countmunwork==2 & muncensorecieves==1 & munworksends==2 &  munworkrecieves==2 
replace type=6 if countnewmun==0 & muncenso!=munwork & countmunwork==2 & muncensorecieves==1 & munworksends==2 &  munworkrecieves==2 
*this takes the middle sandwich case and splits it into the the two fringes. weights will need to be halved

replace newmun=munwork if countnewmun==0 & muncenso!=munwork & countmunwork>1 & muncensorecieves==2 & munworksends==1 &  munworkrecieves>1 
replace oldmun=muncenso if countnewmun==0 & muncenso!=munwork & countmunwork>1 & muncensorecieves==2 & munworksends==1 &  munworkrecieves>1 
replace type=7 if countnewmun==0 & muncenso!=munwork & countmunwork>1 & muncensorecieves==2 & munworksends==1 &  munworkrecieves>1  


*special ones
replace newmun=munwork if muncenso==15042 & munwork==15048
replace newmun=muncenso if muncenso==15048 & munwork==15048
replace type=8 if muncenso==15042 & munwork==15048
replace type=8 if muncenso==15048 & munwork==15048
*these need to be halved

replace newmun=30 if muncenso==19010 & munwork==30
replace newmun=30 if muncenso==19037 & munwork==19037
replace type=9 if muncenso==19010 & munwork==30
replace type=9 if muncenso==19037 & munwork==19037

replace newmun=54 if muncenso==31052 & munwork==54
replace newmun=31052 if muncenso==31052 & munwork==31052
replace newmun=31052 if muncenso==31082 & munwork==31082
replace newmun=31052 if muncenso==31072 & munwork==31072
replace type=10 if muncenso==31052 & munwork==54
replace type=10 if muncenso==31052 & munwork==31052
replace type=10 if muncenso==31072 & munwork==31072
replace type=10 if muncenso==31082 & munwork==31082
*these need to be halved

egen countnewmun2=count(newmun), by(oldmun)

drop if newmun==.
drop if oldmun==.

keep oldmun newmun countnewmun2
rename oldmun muncenso
rename newmun muncensonew
rename countnewmun2 splitters

sort muncenso 
save "${dir}munworkdatageog.dta", replace


egen mig5munZMnew=max(muncensonew) , by(muncenso)
egen mig5munZMnew2=min(muncensonew) if splitters==2, by(muncenso)
drop splitters
rename muncenso mig5munZM
drop muncensonew
sort mig5munZM
save "${dir}munworkdatamig5mun.dta", replace


use "${dir}munworkdatageog.dta", clear
sort muncenso
merge muncenso using  "${dir}mungeogZM.dta", nokeep keep(state) _merge(_merge22)
rename muncenso muncensoold
rename muncensonew muncenso
rename state stateold
sort muncenso
merge muncenso using  "${dir}mungeogZM.dta", nokeep keep(state) _merge(_merge2)
rename state statenew
rename muncenso muncensonew

gen nomatch=1 if stateold!=statenew
sort nomatch

egen tagmunold=tag(muncensoold)
keep if tagmunold==1
keep muncensoold stateold statenew


sort muncensoold
save "${dir}munworkdataoldstates.dta", replace




local yearend=2000

use "${dir}munworkdatageog.dta", clear

*this generates all the years from 1985-1999 so that the fillin works
gen year=1985

forval i=1986/`yearend' {
replace year=`i' if _n==`yearend'+1-`i'
}

egen oldnew=concat(muncenso muncensonew), punct(_)
fillin oldnew year

egen xmuncenso=max(muncenso), by(oldnew)
egen xmuncensonew=max(muncensonew), by(oldnew)
egen xsplitters=max(splitters), by(oldnew)

drop muncenso muncensonew splitters
renpfix x
keep muncenso muncensonew year splitters

sort muncenso year
save "${dir}munworkdatafirm.dta", replace

