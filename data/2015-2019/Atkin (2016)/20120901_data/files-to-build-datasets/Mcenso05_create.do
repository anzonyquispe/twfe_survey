/*
---------------------------------
Mcenso05_create.do

These do file takes the raw census data in .dat form and converts it into a dta file
not including merging parental data unless mexico_censo_05_full includes it. 

For parent data run parentmerge file, then send through this file.

Then this file is taken, older people dropped and people not in municipalities covered by IMSS discarded
and a whole bunch of variable added. This file is the start of all the future regressions:

Inputs are:
3 ipumsi data extracts with relevant variables
mexico_censo_05.dta
mexico_censo_10.dta
mexico_censo_11.dta

*municipality codes 
munimxchanges.do 
zonamet.dta

*industry codes
ind00_hcode_David.dta
ind90_hcode_David.dta

Outputs are: 
mexico_censo_05_regready`i'.dta (in `workdir')
---------------------------------
*/











qui {



clear
set mem 500m
set more off
*set matsize 5000
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
global workdir="C:\Scratch\"
local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
}





forval i=5/90 {
*forval i=56/90 {

use  if age==`i'  using "${censodir}mexico_censo_11.dta", clear
gen year=1996
save "${workdir}temp_95_`i'.dta", replace
use  if age==`i'  using "${censodir}mexico_censo_10.dta", clear
gen year=2006
gen ind=.
save "${workdir}temp_05_`i'.dta", replace

*now we get rid of some people and prepare for regressions with some more variables
use  if age==`i'  using "${censodir}mexico_censo_05.dta", clear

append using "${workdir}temp_95_`i'.dta"
append using "${workdir}temp_05_`i'.dta"

erase "${workdir}temp_95_`i'.dta"
erase "${workdir}temp_05_`i'.dta"


noi di _c"`i' "

*recoding yrschl to exclude the high values that are missing data
replace yrschl=. if yrschl>18
gen yrschl2=yrschl
replace yrschl2=12 if yrschl2>12 & yrschl2<100

gen yearendschl2=year - age + 5 + yrschl2 if school!=1
gen yearendschl=year - age + 5 + yrschl if school!=1

/*
*now only get those young enough to be exposed
drop if age>40 & yearendschl2<1969 & year==1990
drop if age>50 & yearendschl2<1969 & year==2000
*/


*This file prepares censo_05_full for use 


replace munimx=20319 if munimx==20318
*This turns the two municipios that are San Pedro Mixtepec - distr. 22 and San Pedro Mixtepec - distr. 26 into one to match IMSS
gen obs=_n if munimx==15122 | munimx==30210
expand 4 if munimx==15122
expand 4 if munimx==30210
*these two municipalities  Uxpanapa and Valle de Chalco Solidaridad are formed from bits of 4 other munis. so i divide weights
gen wtpernew=wtper
replace wtpernew=wtper/4 if munimx==15122 | munimx==30210
rename wtper wtperold
rename wtpernew wtper
egen counter=seq() if munimx==15122 | munimx==30210 ,by(obs)
replace munimx=15039 if munimx==15122 & counter==1
replace munimx=15070 if munimx==15122 & counter==2
replace munimx=15025 if munimx==15122 & counter==3
replace munimx=15029 if munimx==15122 & counter==4
replace munimx=30108 if munimx==30210 & counter==1
replace munimx=30070 if munimx==30210 & counter==2
replace munimx=30091 if munimx==30210 & counter==3
replace munimx=30061 if munimx==30210 & counter==4
drop counter obs





gen ind3=ind
replace ind3=ind3/100 if year==1990 & ind3>999
gen manuf=0 if ind3!=0
replace manuf=1 if ind3>299 & ind3<400


*now we get muncenso ZM
qui do "${dir}munimxchanges.do"

sort munimx
merge munimx using ${dir}zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
rename munimxZM muncensoZM

rename munimx munimx2000
*logic is we first get all our 1985 districts, and we only merge into ZM where whole district is part of zm.
*this is because we do not have data if newly created district mergerd into zm.

*now this is where they lived 5 years ago (only for 2000 data)
gen muncenso= string( migmx2,"%02.0f") + string(  mx00a_resmun,"%03.0f") if year==2000
destring muncenso, replace
rename muncenso munimx
replace munimx=20319 if munimx==20318
*This turns the two municipios that are San Pedro Mixtepec - distr. 22 and San Pedro Mixtepec - distr. 26 into one to match IMSS
gen obs=_n if munimx==15122 | munimx==30210
expand 4 if munimx==15122
expand 4 if munimx==30210
*these two municipalities  Uxpanapa and Valle de Chalco Solidaridad are formed from bits of 4 other munis. so i divide weights
replace wtper=wtper/4 if munimx==15122 | munimx==30210
egen counter=seq() if munimx==15122 | munimx==30210 ,by(obs)
replace munimx=15039 if munimx==15122 & counter==1
replace munimx=15070 if munimx==15122 & counter==2
replace munimx=15025 if munimx==15122 & counter==3
replace munimx=15029 if munimx==15122 & counter==4
replace munimx=30108 if munimx==30210 & counter==1
replace munimx=30070 if munimx==30210 & counter==2
replace munimx=30091 if munimx==30210 & counter==3
replace munimx=30061 if munimx==30210 & counter==4
drop counter obs
qui do "${dir}munimxchanges.do"


sort munimx
merge munimx using ${dir}zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
rename munimxZM mig5munZM
rename munimx mig5mun

gen muncenso= string( mx00a_wkst,"%02.0f") + string(  mx00a_wkmun,"%03.0f") if mx00a_wkmun!=0 & mx00a_wkmun!=999 & year==2000
destring muncenso, replace
rename muncenso munimx
replace munimx=20319 if munimx==20318
*This turns the two municipios that are San Pedro Mixtepec - distr. 22 and San Pedro Mixtepec - distr. 26 into one to match IMSS
gen obs=_n if munimx==15122 | munimx==30210
expand 4 if munimx==15122
expand 4 if munimx==30210
*these two municipalities  Uxpanapa and Valle de Chalco Solidaridad are formed from bits of 4 other munis. so i divide weights
replace wtper=wtper/4 if munimx==15122 | munimx==30210
egen counter=seq() if munimx==15122 | munimx==30210 ,by(obs)
replace munimx=15039 if munimx==15122 & counter==1
replace munimx=15070 if munimx==15122 & counter==2
replace munimx=15025 if munimx==15122 & counter==3
replace munimx=15029 if munimx==15122 & counter==4
replace munimx=30108 if munimx==30210 & counter==1
replace munimx=30070 if munimx==30210 & counter==2
replace munimx=30091 if munimx==30210 & counter==3
replace munimx=30061 if munimx==30210 & counter==4
drop counter obs





qui do "${dir}munimxchanges.do"

sort munimx
merge munimx using ${dir}zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
rename munimxZM munworkZM


rename munimx munwork


rename munimx2000 muncenso

*note all the munmatches have been carried out on the changed municipalities before being ZM'd
*this is what firm data corresponds to


*this is what knocks out the non matching municpalities, because if muncensoZM==mig5munZM then

gen married=1
replace married=0 if marstd==100 | marstd==220
replace married=. if marstd==999
replace chborn=. if chborn>31
replace chsurv=. if chsurv>31
gen chdeathrate=chsurv/chborn if chborn>=chsurv

*now this is topcoded at 12 years (usual age for leaving school)
gen leftsch2=0
replace leftsch2=. if leftsch==99 | leftsch==0 | leftsch==.
replace leftsch2=1 if leftsch==20

gen yobexp= year-age-1
gen year15=yobexp+15
*this is the year they will turn 15 (or at least 10/12th will)
gen year16=yobexp+16
gen year17=yobexp+17
gen yearexp1= yobexp + 1 + 5
gen yearexp7= yobexp + 7 + 5
gen yearexp10= yobexp + 10 + 5
gen yearexp13= yobexp + 13 + 5
*these are years that would start grade 7, 10 and 13


label var yearendschl "Year in which finished school in summer (if born after cutoff and before census)"

label var yearendschl2 "Year in which finished school in summer (if born after cutoff and before census): topcoded at 12years"

rename year cenyear

gen drop1=0 if yrschl>0  & yrschl<100 & age>7 & age<10000
replace drop1=0 if yrschl==0 & school==1 & age>7 & age<10000
replace drop1=1 if yrschl==0 & school!=1 & age>7 & age<10000
*now we are on the safe side and we are not looking at delayed entry, so only kids greater than 7 are included



*assumes someone with 9 years and still at school did drop out unless they are 16 or less (see education census tables.xls for why) done better
foreach dnum of numlist 7 10 13  {
gen dropq`dnum'=0 if yrschl>`dnum'-1  & yrschl<100  // 0 if got more school or at school and young.  1 if got dnum-1
replace dropq`dnum'=0 if yrschl==`dnum'-1 & school==1 & age<=`dnum'+6
replace dropq`dnum'=1 if yrschl==`dnum'-1 & school!=1
replace dropq`dnum'=1 if yrschl==`dnum'-1 & school==1 & age>`dnum'+6
replace dropq`dnum'=. if age<`dnum'+6
}







replace sizemx=3 if sizemx==4 | sizemx==5 | sizemx==6


cap replace momyrschl=. if momyrschl>18
cap replace popyrschl=. if popyrschl>18
cap replace spyrschl=. if spyrschl>18


gen schatt=1 if school==1
replace schatt=0 if school==2 | school==3 | school==4



gen ind2= floor(ind3/10) if cenyear==2000
gen sector=	1	if ind2==	11						
replace sector=	2	if ind2==	21	| ind2==	22	| ind2==	23		
replace sector=	3	if ind2==	31	| ind2==	32	| ind2==	33		
replace sector=	4	if (ind2>	39	& ind2<	52	) | ind2==	71	 | ind2==	72
replace sector=	5	if (ind2>	51	& ind2<	60	) 			
replace sector=	6	if ind2==	61	| ind2==	62	| ind2==	93		
replace sector=	7	if ind2==	81						
replace sector= 0 	if ind3==0
forval n=0/7 {
gen sector`n'=0
replace sector`n'=1 if sector==`n'
}


gen ind90=ind if cenyear==1990
gen ind00=ind if cenyear==2000

sort ind00
merge ind00 using "${dir}ind00_hcode_David.dta", _merge(_mergeHCODE00) keep(hcode00)
drop _mergeHCODE00
sort ind90
merge ind90 using "${dir}ind90_hcode_David.dta", _merge(_mergeHCODE90) keep(hcode90)
drop _mergeHCODE90
gen hcode=hcode90  if cenyear==1990
replace hcode=hcode00 if cenyear==2000
drop hcode90 hcode00 ind90 ind00



*these do not have missing values removed
egen hhincome=sum(inctot), by(serial cenyear)
egen hhsize=count(pernum), by(serial cenyear)
gen hhincomepc=hhincome/hhsize


save "${workdir}mexico_censo_05_regready`i'.dta", replace
}



}
*end of qui




*here I add on some insurance information. Note sample serial pernum is not unique as i have split people between municipalities in the final zm split
*sample identifies are all messed up when they added new data

forval i=5/90 {



use "${workdir}mexico_censo_05_regready`i'.dta", clear

label drop samplelbl

replace sample=4845 if cenyear==2000
drop hrswrk1
*this was only merged for 1996 first time round

sort  sample serial pernum

merge  sample serial pernum  using ${censodir}mexico_censo_15 , nokeep  _merge(_mergehealth)

save "${censodir}mexico_censo_05_regready`i'.dta", replace

}



