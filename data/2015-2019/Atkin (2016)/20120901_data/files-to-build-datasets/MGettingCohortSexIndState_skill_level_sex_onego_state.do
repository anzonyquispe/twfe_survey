***march 2013: two changes, uses my more detailed imss2cen90 codes and aggregates to state rather than 1 dig for the 1 dig variable.


/**
this file takes the census and works out how skilled  the various hcode industries are bsed on the relative skills of people in that industry

can do this a few ways:
1. Do it by cohort
2. Do it by sex

but what should the relative skill be relative to? Relative to all people or just employed people? 
Relative to all cohcorts or just their cohort? So many questions. 
Obviously the finer I dig, the more empty cells and the more interpolation I will need. Can I do this with a regression?



**/



qui {



local starttime=c(current_time)

clear all
set mem 4000m
set matsize 11000
set maxvar 32767




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





use if cenyear==1990 | cenyear==2000 using "${workdir}temp7.dta", clear

keep if age>15 & age<40 &   yrschl!=.
*note these are not just employed people!  (previously had empstatd==110 &)
drop if muncenso==12


 


gen experience2=age-16 if yrschl<=9
replace experience2=age-yrschl-6 if yrschl==10
replace experience2=age-yrschl-6 if yrschl>10 & yrschl<19
*this is nonlinear but matches up to  tab age if yrschl==11 & indimss4!=. when we get hike
gen experience2sq=experience2*experience2


gen rur=1 if urban==1
replace rur=0 if urban==2



gen ind90=ind if cenyear==1990
gen ind00=ind if cenyear==2000

sort ind00
merge ind00 using "${dir}ind00_hcode_David.dta", _merge(_mergeHCODE00) keep(hcode00 hindustry_2)
sort ind90
merge ind90 using "${dir}ind90_hcode_David.dta", _merge(_mergeHCODE90) keep(hcode90)
gen hcode=hcode90  if cenyear==1990
replace hcode=hcode00 if cenyear==2000

replace hcode00=1000 if mx00a_imss==2 & hcode00!=.
replace hcode00=. if mx00a_imss==. | mx00a_imss==9
*so now hcode00 takes a value of 1000 if informal




replace hrswrk1=. if hrswrk1>990



foreach yr in 1990 2000 {
gen lninc2000`yr'=lninc2000 if cenyear==`yr' & hrswrk1>=20 & hrswrk1<=150
winsor lninc2000`yr', gen(wlninc`yr') p(0.05)
*winsorize income at top and bottom tails
}



*this is per hour for workers
foreach yr in 1990 2000 {
gen lnworkwage`yr'=log(exp(lninc2000`yr')/hrswrk1) if   (empstatd==120 | empstatd==110)
winsor lnworkwage`yr', gen(wlnworkwage`yr') p(0.05) 
}



// Change this if want hourly wage or total income....

local wage "_hourly"

if "`wage'"=="_hourly" {
gen wg=wlnworkwage2000 if cenyear==2000
replace wg=wlnworkwage1990 if cenyear==1990
gen vg=wlninc2000 if cenyear==2000
replace vg=wlninc1990 if cenyear==1990
}
else {
gen wg=wlninc2000 if cenyear==2000
replace wg=wlninc1990 if cenyear==1990
}



cap drop wlninc2000 wlnworkwage2000
cap drop wlninc1990  wlnworkwage1990







noi di "3"



gen schlz3cat1=(yrschl<9) if yrschl!=. 
gen schlz3cat2=(yrschl>=9 & yrschl<12) if yrschl!=. 
gen schlz3cat3=(yrschl>=12) if yrschl!=.

gen schlz3cat=1 if  yrschl!=. & (yrschl<9)
replace schlz3cat=2 if  yrschl!=. & (yrschl>=9 & yrschl<12)
replace schlz3cat=3 if  yrschl!=. & (yrschl>=12)
*these schlz measures use less than 9, between 9 and 12 and greater or equal to 12.






gen sample=1 if age>15 & age<29 & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
*sample of employed youths
gen mark=1 if mx00a_imss==1 & age>15 & age<29 & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
*this is my sample of youths employed in formal sector. Mark is my formal sample (2000)

gen mark2=1 if mx00a_imss==1 & age>15 & age!=.  & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
gen sample2=1 if age>15 & age!=.  & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
*this includes all those above 15. Mark is my formal sample (2000)

gen mark3=1 if mx00a_imss==1 & age>15 & age<39  & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
gen sample3=1 if age>15 & age<39  & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
*this includes all those above 15 and less than 39 (so these guys are 29 in 1990). Mark is my formal sample (2000)


gen form=1 if  age>15 & age<29 & empstatd==110 & hrswrk1>=20 & hrswrk1<=150  &  hlthcov!=60 &  hlthcov!=. &  hlthcov!=99
gen nform=1 if mx00a_imss==2 & age>15 & age<29 & empstatd==110 & hrswrk1>=20 & hrswrk1<=150  & hlthcov==60
*formal informal (not actually since some of these have other hlthcov)


gen samplenform=sample


***********all is formal in 2000
replace sample=mark if cenyear==2000
replace sample2=mark2 if cenyear==2000

gen agecat=1 if (age<=18) & age!=. 
replace agecat=2 if (age>18 & age<=21) & age!=. 
replace  agecat=3 if (age>21 & age<=24) & age!=. 
replace  agecat=4 if (age>24 & age<29)  & age!=.
replace  agecat=5 if (age>=29)  & age!=.







compress
save "${tempdir}temp_munperc.dta", replace

**/









*now the main event

#delimit ;
local varlist "sch nonmigrant 
schlz3cat1 schlz3cat2 schlz3cat3 
vnschlz3cat1 vnschlz3cat2 vnschlz3cat3
veschlz3cat1 veschlz3cat2 veschlz3cat3
";
#delimit cr





use "${tempdir}temp_munperc.dta", clear

local regionchoice "state"

levelsof `regionchoice'
local statelist=r(levels)
*so I split it into states for speed
local statelist="1 2 3 4 5 6 7 8 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32"


noi di "States in this run: `statelist'"

 

foreach yrly in  2000  {  // 1990

foreach sexy in ""   { // "fem" "male"





noi di "Year: `yrly', Sex: `sexy'"
noi di "`regionchoice':" 
foreach state in `statelist' {


noi di _c "`state', " 



use if cenyear==`yrly' &  `regionchoice'==`state' using "${tempdir}temp_munperc.dta", clear



if "`sexy'"=="male" {
keep if sex==1
}

if "`sexy'"=="fem" {
keep if sex==2
}



*keep if empstatd==110
*now just look at employees.

gen hcode1dig=floor(hcode/100)
*this gets me my missing value as the hcode1dig average

*keep if sample==1


rename bluecollar blue
rename yrschl sch
gen mig=migrant
*rename binschl sbin
gen nonmigrant=1-migrant
gen mnonmigrant=nonmigrant if migrant==0

gen blue2cat1=blue
gen blue2cat2=1-blue

foreach thinger in sch blue2cat1 blue2cat2 schlz3cat1 schlz3cat2 schlz3cat3 {
cap gen m`thinger'=`thinger'  if migrant==0
}
*this will be used for migrant coding below




cap drop agecat



gen mvg=vg if migrant==0
gen mwg=wg if migrant==0

noi di "wage start" 
*now I get mean wages by group (for state)
foreach wage in wg vg mvg mwg {
gen `wage'all=`wage' if samplenform==1
*egen count`wage'=count(`wage'all), by(cenyear age sch state)
egen all`wage'=wtmean(`wage'all), by(cenyear age sch muncenso) weight(wtper)
egen all`wage'blue2cat=wtmean(`wage'all), by(cenyear blue muncenso) weight(wtper)
cap egen all`wage'schlz3cat=wtmean(`wage'all), by(cenyear schlz3cat muncenso) weight(wtper)




gen `wage'manuf=`wage' if samplenform==1 & hcode90<400 & hcode90>=300
*egen count`wage'=count(`wage'manuf), by(cenyear age sch state)
egen manuf`wage'=wtmean(`wage'manuf), by(cenyear age sch muncenso) weight(wtper)
egen manuf`wage'blue2cat=wtmean(`wage'manuf), by(cenyear blue muncenso) weight(wtper)
cap egen manuf`wage'schlz3cat=wtmean(`wage'manuf), by(cenyear schlz3cat muncenso) weight(wtper)


gen `wage'exp=`wage' if samplenform==1 & experience2<=5 & experience2>=0
egen exp`wage'=wtmean(`wage'exp), by(cenyear age sch muncenso) weight(wtper)
egen exp`wage'blue2cat=wtmean(`wage'exp), by(cenyear blue muncenso) weight(wtper)
cap egen exp`wage'schlz3cat=wtmean(`wage'exp), by(cenyear schlz3cat muncenso) weight(wtper)


gen `wage'expmanuf=`wage' if samplenform==1 & experience2<=5 & experience2>=0 & hcode90<400 & hcode90>=300
egen expmanuf`wage'=wtmean(`wage'expmanuf), by(cenyear age sch muncenso) weight(wtper)
egen expmanuf`wage'blue2cat=wtmean(`wage'expmanuf), by(cenyear blue muncenso) weight(wtper)
cap egen expmanuf`wage'schlz3cat=wtmean(`wage'expmanuf), by(cenyear schlz3cat muncenso) weight(wtper)



gen `wage'bxp=`wage' if samplenform==1 & experience2<=3 & experience2>=0
egen bxp`wage'=wtmean(`wage'bxp), by(cenyear age sch muncenso) weight(wtper)
egen bxp`wage'blue2cat=wtmean(`wage'bxp), by(cenyear blue muncenso) weight(wtper)
cap egen bxp`wage'schlz3cat=wtmean(`wage'bxp), by(cenyear schlz3cat muncenso) weight(wtper)


gen `wage'bxpmanuf=`wage' if samplenform==1 & experience2<=3 & experience2>=0 & hcode90<400 & hcode90>=300
egen bxpmanuf`wage'=wtmean(`wage'bxpmanuf), by(cenyear age sch muncenso) weight(wtper)
egen bxpmanuf`wage'blue2cat=wtmean(`wage'bxpmanuf), by(cenyear blue muncenso) weight(wtper)
cap egen bxpmanuf`wage'schlz3cat=wtmean(`wage'bxpmanuf), by(cenyear schlz3cat muncenso) weight(wtper)


gen `wage'cxp=`wage' if samplenform==1 & experience2<=5 & experience2>=-1
egen cxp`wage'=wtmean(`wage'cxp), by(cenyear age sch muncenso) weight(wtper)
egen cxp`wage'blue2cat=wtmean(`wage'cxp), by(cenyear blue muncenso) weight(wtper)
cap egen cxp`wage'schlz3cat=wtmean(`wage'cxp), by(cenyear schlz3cat muncenso) weight(wtper)


gen `wage'cxpmanuf=`wage' if samplenform==1 & experience2<=5 & experience2>=-1 & hcode90<400 & hcode90>=300
egen cxpmanuf`wage'=wtmean(`wage'cxpmanuf), by(cenyear age sch muncenso) weight(wtper)
egen cxpmanuf`wage'blue2cat=wtmean(`wage'cxpmanuf), by(cenyear blue muncenso) weight(wtper)
cap egen cxpmanuf`wage'schlz3cat=wtmean(`wage'cxpmanuf), by(cenyear schlz3cat muncenso) weight(wtper)

}




cap drop schl*cat 


*now I get the wages divided by various avergaes
foreach thinger of varlist  schl*cat? blue2cat?  {   // a
local cats=regexr("`thinger'",".$","")
foreach wage in wg vg  {
local wshort=regexr("`wage'",".$","")
gen wt`wshort'i`thinger'=wtper*`thinger'
gen wt`wshort'e`thinger'=wtper*`thinger'
gen wt`wshort'n`thinger'=wtper*`thinger'
gen wt`wshort'g`thinger'=wtper*`thinger'
gen wt`wshort'm`thinger'=wtper*`thinger'
gen wt`wshort'j`thinger'=wtper*`thinger'
gen wt`wshort'k`thinger'=wtper*`thinger'
gen wt`wshort'b`thinger'=wtper*`thinger'
gen wt`wshort'c`thinger'=wtper*`thinger'
gen `wshort'g`thinger'=exp(`wage')/exp(all`wage') if `thinger'>0 & sample==1
gen `wshort'i`thinger'=exp(`wage')/exp(exp`wage') if `thinger'>0 & sample==1
gen `wshort'j`thinger'=exp(`wage')/exp(manuf`wage') if `thinger'>0 & sample==1
gen `wshort'n`thinger'=exp(`wage')/exp(all`wage'`cats') if `thinger'>0 & sample==1
gen `wshort'e`thinger'=exp(`wage')/exp(exp`wage'`cats') if `thinger'>0 & sample==1
gen `wshort'm`thinger'=exp(`wage')/exp(manuf`wage'`cats') if `thinger'>0 & sample==1
gen `wshort'k`thinger'=exp(`wage')/exp(expmanuf`wage'`cats') if `thinger'>0 & sample==1
gen `wshort'c`thinger'=exp(`wage')/exp(cxp`wage'`cats') if `thinger'>0 & sample==1
gen `wshort'b`thinger'=exp(`wage')/exp(bxp`wage'`cats') if `thinger'>0 & sample==1

gen wtm`wshort'i`thinger'=wtper*m`thinger'
gen wtm`wshort'e`thinger'=wtper*m`thinger'
gen wtm`wshort'n`thinger'=wtper*m`thinger'
gen wtm`wshort'g`thinger'=wtper*m`thinger'
gen wtm`wshort'm`thinger'=wtper*m`thinger'
gen wtm`wshort'j`thinger'=wtper*m`thinger'
gen wtm`wshort'k`thinger'=wtper*m`thinger'
gen wtm`wshort'b`thinger'=wtper*m`thinger'
gen wtm`wshort'c`thinger'=wtper*m`thinger'
gen m`wshort'g`thinger'=exp(m`wage')/exp(allm`wage') if m`thinger'>0 & sample==1
gen m`wshort'i`thinger'=exp(m`wage')/exp(expm`wage') if m`thinger'>0 & sample==1
gen m`wshort'j`thinger'=exp(m`wage')/exp(manufm`wage') if m`thinger'>0 & sample==1
gen m`wshort'n`thinger'=exp(m`wage')/exp(allm`wage'`cats') if m`thinger'>0 & sample==1
gen m`wshort'e`thinger'=exp(m`wage')/exp(expm`wage'`cats') if m`thinger'>0 & sample==1
gen m`wshort'm`thinger'=exp(m`wage')/exp(manufm`wage'`cats') if m`thinger'>0 & sample==1
gen m`wshort'k`thinger'=exp(m`wage')/exp(expmanufm`wage'`cats') if m`thinger'>0 & sample==1
gen m`wshort'c`thinger'=exp(m`wage')/exp(cxpm`wage'`cats') if m`thinger'>0 & sample==1
gen m`wshort'b`thinger'=exp(m`wage')/exp(bxpm`wage'`cats') if m`thinger'>0 & sample==1
}
}

drop all*g exp*g manuf*g all*g*cat exp*g*cat manuf*g*cat 

noi di "wage prepared" 






*normal, migrant, experience and include informal: lets do all of these seperately
foreach var in `varlist' `varlisth' `varlistf' {

*here i adjust teh wieghts when using wages os that individuals on the boundry are weighted less (for perc*cat their values were shrunk rather than their weights)

if regexm("`var'","^w")==1 | regexm("`var'","^v")==1  {
gen wtperx=wt`var'
}
else {
gen wtperx=wtper
}


*gen wtperx=wtper

*not clear I want to exclude migrants. These are the jobs available. if mainly migrants jobs are crappy-why look at weirdo local wages.
*if crappy migrant wage then I should find no effect
if `yrly'==2000 {

}


if `yrly'==1990 | `yrly'==2000 {

foreach geog in state muncenso {
local geogshort=substr("`geog'",1,1)

egen xindm`var'nor_`geogshort'=wtmean(`var') if sample==1 , by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'nor_`geogshort'wt=total(wtperx) if sample==1 , by(hcode cenyear `geog')
egen xindm`var'nor_`geogshort'ct=count(wtperx) if sample==1 , by(hcode cenyear `geog')

egen xindm`var'exp_`geogshort'=wtmean(`var') if sample==1 & experience2<=5 & experience2>=0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'exp_`geogshort'wt=total(wtperx) if sample==1 & experience2<=5 & experience2>=0, by(hcode cenyear `geog')
egen xindm`var'exp_`geogshort'ct=count(wtperx) if sample==1 & experience2<=5 & experience2>=0, by(hcode cenyear `geog')

egen xindm`var'mig_`geogshort'=wtmean(m`var') if sample==1 & migrant==0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'mig_`geogshort'wt=total(wtperx) if sample==1 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'mig_`geogshort'ct=count(wtperx) if sample==1 & migrant==0, by(hcode cenyear `geog')

egen xindm`var'bne_`geogshort'=wtmean(`var') if sample==1  & experience2<=3 & experience2>=0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'bne_`geogshort'wt=total(wtperx) if sample==1 & experience2<=3 & experience2>=0 , by(hcode cenyear `geog')
egen xindm`var'bne_`geogshort'ct=count(wtperx) if sample==1 & experience2<=3 & experience2>=0 , by(hcode cenyear `geog')

egen xindm`var'cne_`geogshort'=wtmean(`var') if sample==1  & experience2<=5 & experience2>=-1, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'cne_`geogshort'wt=total(wtperx) if sample==1 & experience2<=5 & experience2>=-1 , by(hcode cenyear `geog')
egen xindm`var'cne_`geogshort'ct=count(wtperx) if sample==1 & experience2<=5 & experience2>=-1 , by(hcode cenyear `geog')




*this is really mig and experience
egen xindm`var'inf_`geogshort'=wtmean(m`var') if sample==1 & migrant==0 & experience2<=5 & experience2>=0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'inf_`geogshort'wt=total(wtperx) if sample==1 & experience2<=5 & experience2>=0 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'inf_`geogshort'ct=count(wtperx) if sample==1 & experience2<=5 & experience2>=0 & migrant==0, by(hcode cenyear `geog')

egen xindm`var'bme_`geogshort'=wtmean(m`var') if sample==1 & migrant==0 & experience2<=3 & experience2>=0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'bme_`geogshort'wt=total(wtperx) if sample==1 & experience2<=3 & experience2>=0 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'bme_`geogshort'ct=count(wtperx) if sample==1 & experience2<=3 & experience2>=0 & migrant==0, by(hcode cenyear `geog')

egen xindm`var'cme_`geogshort'=wtmean(m`var') if sample==1 & migrant==0 & experience2<=5 & experience2>=-1, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'cme_`geogshort'wt=total(wtperx) if sample==1 & experience2<=5 & experience2>=-1 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'cme_`geogshort'ct=count(wtperx) if sample==1 & experience2<=5 & experience2>=-1 & migrant==0, by(hcode cenyear `geog')


egen xindm`var'dme_`geogshort'=wtmean(m`var') if sample==1 & migrant==0 & experience2<=5 & experience2>=0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'dme_`geogshort'wt=total(wtperx) if sample==1 & experience2<=5 & experience2>=0 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'dme_`geogshort'ct=count(wtperx) if sample==1 & experience2<=5 & experience2>=0 & migrant==0, by(hcode cenyear `geog')



egen xindm`var'fme_`geogshort'=wtmean(m`var') if sample==1 & migrant==0 & experience2<=3 & experience2>=0, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'fme_`geogshort'wt=total(wtperx) if sample==1 & experience2<=3 & experience2>=0 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'fme_`geogshort'ct=count(wtperx) if sample==1 & experience2<=3 & experience2>=0 & migrant==0, by(hcode cenyear `geog')

egen xindm`var'eme_`geogshort'=wtmean(m`var') if sample==1 & migrant==0 & experience2<=5 & experience2>=-1, by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'eme_`geogshort'wt=total(wtperx) if sample==1 & experience2<=5 & experience2>=-1 & migrant==0, by(hcode cenyear `geog')
egen xindm`var'eme_`geogshort'ct=count(wtperx) if sample==1 & experience2<=5 & experience2>=-1 & migrant==0, by(hcode cenyear `geog')




egen xindm`var'old_`geogshort'=wtmean(`var') if sample2==1 , by(hcode cenyear `geog') weight(wtperx)
egen xindm`var'old_`geogshort'wt=total(wtperx) if sample2==1 , by(hcode cenyear `geog')
egen xindm`var'old_`geogshort'ct=count(wtperx) if sample2==1 , by(hcode cenyear `geog')

}


}


*now i get the max
foreach dink of varlist xindm`var'*_m xindm`var'*_mwt xindm`var'*_mct {
egen x`dink'=max(`dink'), by(hcode cenyear muncenso)
}
foreach dink of varlist xindm`var'*_s xindm`var'*_swt xindm`var'*_sct {
egen x`dink'=max(`dink'), by(hcode cenyear state)
}


drop xind*
renpfix xxind xind


foreach geog in state muncenso {
local geogshort=substr("`geog'",1,1)

gen indm`var'nor_`geogshort'=xindm`var'nor_`geogshort' 


*this is now actually state


gen indm`var'exp_`geogshort'=xindm`var'exp_`geogshort' 
replace indm`var'exp_`geogshort'=indm`var'nor_`geogshort' if indm`var'exp_`geogshort'==. 


gen indm`var'mig_`geogshort'=xindm`var'mig_`geogshort' 
replace indm`var'mig_`geogshort'=indm`var'nor_`geogshort' if indm`var'mig_`geogshort'==. 

*this is mig with experiance
gen indm`var'inf_`geogshort'=xindm`var'inf_`geogshort'
replace indm`var'inf_`geogshort'=indm`var'exp_`geogshort' if indm`var'inf_`geogshort'==.
replace indm`var'inf_`geogshort'=indm`var'mig_`geogshort' if indm`var'inf_`geogshort'==.


gen indm`var'dme_`geogshort'=xindm`var'dme_`geogshort'
replace indm`var'dme_`geogshort'=indm`var'mig_`geogshort' if indm`var'dme_`geogshort'==.


gen indm`var'old_`geogshort'=xindm`var'old_`geogshort'


gen indm`var'cne_`geogshort'=xindm`var'cne_`geogshort' 
replace indm`var'cne_`geogshort'=indm`var'nor_`geogshort' if indm`var'cne_`geogshort'==. 

gen indm`var'bne_`geogshort'=xindm`var'bne_`geogshort' 
replace indm`var'bne_`geogshort'=indm`var'nor_`geogshort' if indm`var'bne_`geogshort'==. 

gen indm`var'cme_`geogshort'=xindm`var'cme_`geogshort'
replace indm`var'cme_`geogshort'=indm`var'cne_`geogshort' if indm`var'cme_`geogshort'==.
replace indm`var'cme_`geogshort'=indm`var'mig_`geogshort' if indm`var'cme_`geogshort'==.

gen indm`var'bme_`geogshort'=xindm`var'bme_`geogshort'
replace indm`var'bme_`geogshort'=indm`var'bne_`geogshort' if indm`var'bme_`geogshort'==.
replace indm`var'bme_`geogshort'=indm`var'mig_`geogshort' if indm`var'bme_`geogshort'==.


gen indm`var'eme_`geogshort'=xindm`var'cme_`geogshort'
replace indm`var'eme_`geogshort'=indm`var'mig_`geogshort' if indm`var'eme_`geogshort'==.


gen indm`var'fme_`geogshort'=xindm`var'bme_`geogshort'
replace indm`var'fme_`geogshort'=indm`var'mig_`geogshort' if indm`var'fme_`geogshort'==.





gen indm`var'infpur_`geogshort'=xindm`var'inf_`geogshort'
gen indm`var'norpur_`geogshort'=xindm`var'nor_`geogshort' 
gen indm`var'exppur_`geogshort'=xindm`var'exp_`geogshort'
gen indm`var'migpur_`geogshort'=xindm`var'mig_`geogshort' 
gen indm`var'oldpur_`geogshort'=xindm`var'old_`geogshort'
*so these pure values do not allow measures from similar one digit industries.
}



renvars xind*_?wt, presub(x z)
renvars xind*_?ct, presub(x z)
drop x*

if `yrly'==2000 {

}
if `yrly'==1990 {


}


drop wtperx

}

 



*****************************************************

egen tag=tag(cenyear muncenso hcode) 



keep if tag==1



save "${tempdir}Skill_Wage_short_percentiles`yrly'_by_Mun_industry_temp`sexy'_`state'_hcode.dta", replace

*from state
}

**/






local statelist="1 2 3 4 5 6 7 8 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32"


keep if _n<1
foreach state in `statelist' {
append using "${tempdir}Skill_Wage_short_percentiles`yrly'_by_Mun_industry_temp`sexy'_`state'_hcode.dta"

}


fillin cenyear muncenso hcode

egen statex=max(state), by(muncenso)
replace state=statex if _fillin==1

egen region1x=max(region1), by(muncenso)
replace region1=region1x if _fillin==1
drop statex region1x

drop hcode1dig
gen hcode1dig=floor(hcode/100)
 
*first replace state ones with the max in cenyear hcode state (not clear what this does for state values-i guess it helps with the fillin)
foreach thing of varlist ind*nor_s ind*inf_s ind*exp_s ind*old_s ind*mig_s  ind*cne_s ind*cme_s ind*bne_s ind*bme_s ind*dme_s  { // ind*eme_s ind*fme_s	
local munthing=regexr("`thing'","s$","m")
local counthing=regexr("`thing'","s$","c")
egen y`thing'=max(`thing'), by(cenyear hcode state) 
replace `thing'=y`thing' if `thing'==.
replace `munthing'=y`thing' if `munthing'==.

*this generates a _c ending version that excludes locations where less than 5 observations in hcode_censo average.
gen `counthing'=`munthing' 
replace  `counthing'=`thing' if z`munthing'ct<=4
gen z`counthing'wt=z`munthing'wt
replace z`counthing'wt=. if z`munthing'ct<=4

drop y`thing'
}
		
noi di "A"

*now replace with hcode1 if still missing. call it t . only for state types.										     
foreach thing of varlist ind*nor_s ind*inf_s ind*exp_s ind*old_s ind*mig_s  ind*cne_s ind*cme_s ind*bne_s ind*bme_s ind*dme_s   {	// ind*eme_s ind*fme_s							     
local munthing=regexr("`thing'","s$","tt")											     
egen y`thing'=wtmean(`thing'), by(cenyear hcode1dig state) weight(z`thing'wt)											     
egen yy`thing'=wtmean(`thing'), by(cenyear hcode region1) weight(z`thing'wt)
egen yyy`thing'=wtmean(`thing'), by(cenyear hcode) weight(z`thing'wt)

*replace `thing'=y`thing' if `thing'==.
gen `munthing'=`thing'
replace  `munthing'=y`thing' if `munthing'==.
replace `munthing'=yy`thing' if `munthing'==.
replace `munthing'=yyy`thing' if `munthing'==.

drop y`thing' 
drop yy`thing' yyy`thing'
}

noi di "B"
		
*now replace with region or national if still missing											     
foreach thing of varlist ind*nor_? ind*inf_? ind*exp_? ind*old_? ind*mig_? ind*cne_? ind*cme_? ind*bne_? ind*bme_?  ind*dme_?  { // ind*eme_? ind*fme_? 								     
											     
*egen y`thing'=wtmean(`thing'), by(cenyear hcode1dig state) weight(z`thing'wt)											     
egen yy`thing'=wtmean(`thing'), by(cenyear hcode region1) weight(z`thing'wt)
egen yyy`thing'=wtmean(`thing'), by(cenyear hcode) weight(z`thing'wt)

*replace `thing'=y`thing' if `thing'==.
replace `thing'=yy`thing' if `thing'==.
replace `thing'=yyy`thing' if `thing'==.

*drop y`thing' 
drop yy`thing' yyy`thing'
}

renvars *_tt, postsub(tt t)


noi di "C"

foreach var in `varlist' `varlisth' `varlistf' {
foreach geog in state muncenso count t {
local geogshort=substr("`geog'",1,1)
gen indm`var'migadj_`geogshort'=indm`var'mig_`geogshort'*indmnonmigrantnor_`geogshort'
*this is the proportion multiplied by percentage of total jobs. should be the total number of non-migrant jobs of different types


gen indm`var'infadj_`geogshort'=indm`var'inf_`geogshort'*indmnonmigrantexp_`geogshort'
*this is the proportion multiplied by percentage of total jobs. should be the total number of non-migrant jobs of different types

gen indm`var'cmeadj_`geogshort'=indm`var'cme_`geogshort'*indmnonmigrantcme_`geogshort'
*this is the proportion multiplied by percentage of total jobs. should be the total number of non-migrant jobs of different types
gen indm`var'bmeadj_`geogshort'=indm`var'bme_`geogshort'*indmnonmigrantbme_`geogshort'
*this is the proportion multiplied by percentage of total jobs. should be the total number of non-migrant jobs of different types

gen indm`var'dmeadj_`geogshort'=indm`var'dme_`geogshort'*indmnonmigrantdme_`geogshort'
*this is the proportion multiplied by percentage of total jobs. should be the total number of non-migrant jobs of different types




}
}



*****************************************************





keep ind* muncenso hcod* cenyear region* state




keep cenyear muncenso hcode  ind*nor_? ind*pur_?  ind*mig_? ind*exp_? ind*old_? ind*migadj_? ind*inf_? ind*infadj_? ind*bne_? ind*cne_?  ind*?me_? ind*?meadj_? 



save  "${workdir}Skill_Wage_Cohort_percentiles`yrly'_by_Mun_industry_long`sexy'_bothsexes_hcode_combo_newexp3_informal.dta", replace

**/

*now for 3cats






use "${workdir}Skill_Wage_Cohort_percentiles`yrly'_by_Mun_industry_long`sexy'_bothsexes_hcode_combo_newexp3_informal.dta", clear

replace cenyear=9 if cenyear==1990
replace cenyear=2 if cenyear==2000


cap drop *1digpur* 
cap drop *exppur* *oldpur* *migpur* *infpur*
*cap drop *4cat*
cap drop indmw*
cap drop indmv*


cap drop *me_t
cap drop *meadj_t
cap drop *ne_t
cap drop *neadj_t
cap drop *_t
cap drop *old*
cap drop *nonmigrant*
cap drop *_m


ds ind*
local vars "`r(varlist)'"
reshape wide `vars' , i(muncenso hcode) j(cenyear)


 

cap renvars ind*_s9 , postsub(_s9 9s)
cap renvars ind*_m9 , postsub(_m9 9m)
cap renvars ind*_c9 , postsub(_c9 9c)
cap renvars ind*_t9 , postsub(_t9 9t)

cap renvars ind*_s2 , postsub(_s2 2s)
cap renvars ind*_m2 , postsub(_m2 2m)
cap renvars ind*_c2 , postsub(_c2 2c)
cap renvars ind*_t2 , postsub(_t2 2t)

renvars ind*, postfix(_)
ds ind*
local vars "`r(varlist)'"
reshape wide `vars' , i(muncenso) j(hcode)

renvars ind*pur*, presub(ind Xnd)

*mvencode ind?wi* ind?wn* , mv(1) override



mvencode ind* , mv(0) override
*so missing values (e.g. no industry ata ll) are replaced with zeroes here.

renvars Xnd*pur* , presub(Xnd ind)

cap renvars *migadjpur* , sub(mig m)

cap renvars *infadjpur* , sub(inf i)


if "`sexy'"=="male" {
renpfix indm indh
}

if "`sexy'"=="fem" {
renpfix indm indf
}

if "`sexy'"=="" { 
***
*slightly budget: get a sex specific shock (not skill specific)

cap ds ind*cat1h*_110 ind*cat1f*_110

if _rc==0 {
foreach zig in `r(varlist)' {
local namesub1=subinstr("`zig'","110","",1)
local namesub2=subinstr("`namesub1'","cat1","cat2",1)
local namesub3=subinstr("`namesub1'","cat1","cat3",1)
local namesub0=subinstr("`namesub1'","cat1","cat0",1)
forval n=100/999 {
cap gen `namesub0'`n'=`namesub1'`n'+`namesub2'`n'+`namesub3'`n'
}
}
}
}
sort muncenso


save  "${workdir}Skill_Wage_Cohort_percentiles`yrly'_by_Mun_industry_wide`sexy'_bothsexes_hcode_3cats_combo_newexp_informal.dta", replace

**/




*now for 3cats


* pause on
* pause 3cat




use "${workdir}Skill_Wage_Cohort_percentiles`yrly'_by_Mun_industry_long`sexy'_bothsexes_hcode_combo_newexp3_informal.dta", clear

replace cenyear=9 if cenyear==1990
replace cenyear=2 if cenyear==2000


cap drop *1digpur* 
cap drop *exppur* *oldpur* *migpur* *infpur*
*cap drop *4cat*
cap drop indms* 
cap drop indmb*

cap drop *old*
cap drop *nonmigrant*
cap drop *_m
cap drop *me_t
cap drop *meadj_t
cap drop *ne_t
cap drop *neadj_t
cap drop indm?cschl*bne*
cap drop indm?eschl*bne*
cap drop indm?bschl*cne*
cap drop indm?eschl*cne*
cap drop indm?nschl*dme*
cap drop indm?bschl*dme*
cap drop indm?cschl*dme*
cap drop indm?eschl*nor*
cap drop indm?bschl*nor*
cap drop indm?cschl*nor*
cap drop indm?bschl*exp*
cap drop indm?cschl*exp*
cap drop indm?bschl*inf*
cap drop indm?cschl*inf*
cap drop indm?bschl*mig*
cap drop indm?cschl*mig*
cap drop indm?eschl*mig*

cap drop indm?nschl*bne*
cap drop indm?nschl*cne*
cap drop indm?nschl*bme*
cap drop indm?nschl*cme*
cap drop indm?eschl*bme*
cap drop indm?eschl*cme*
cap drop indm?bschl*cme*
cap drop indm?bschl*cne*

cap drop *_t
cap drop *norpur*



ds ind*
local vars "`r(varlist)'"
reshape wide `vars' , i(muncenso hcode) j(cenyear)


 

cap renvars ind*_s9 , postsub(_s9 9s)
cap renvars ind*_m9 , postsub(_m9 9m)
cap renvars ind*_c9 , postsub(_c9 9c)
cap renvars ind*_t9 , postsub(_t9 9t)

cap renvars ind*_s2 , postsub(_s2 2s)
cap renvars ind*_m2 , postsub(_m2 2m)
cap renvars ind*_c2 , postsub(_c2 2c)
cap renvars ind*_t2 , postsub(_t2 2t)

renvars ind*, postfix(_)
ds ind*
local vars "`r(varlist)'"
reshape wide `vars' , i(muncenso) j(hcode)

cap renvars ind*pur*, presub(ind Xnd)



cap {
foreach wager of var ind?v*310  {
	local stub=subinstr("`wager'","310","3",1)
	egen m`stub'=rowmean(`stub'*)
		foreach subwager of var `stub'* {
		replace `subwager'=m`stub' if `subwager'==.
		}
	drop m`stub'	
}

foreach wager of var ind?v*110  {
	local stub=subinstr("`wager'","110","",1)
	egen m`stub'=rowmean(`stub'*)
		foreach subwager of var `stub'* {
		replace `subwager'=m`stub' if `subwager'==.
		}
	drop m`stub'	
}
}



mvencode ind* , mv(0) override
*so missing values (e.g. no industry ata ll) are replaced with zeroes here.

cap renvars Xnd*pur* , presub(Xnd ind)

cap renvars *migadjpur* , sub(mig m)

cap renvars *infadjpur* , sub(inf i)


if "`sexy'"=="male" {
renpfix indm indh
}

if "`sexy'"=="fem" {
renpfix indm indf
}


sort muncenso


save  "${workdir}Skill_Wage_Cohort_percentiles`yrly'_by_Mun_industry_wide`sexy'_bothsexes_hcode_3cats_wages_newexp_informal.dta", replace







}
*from sexy

pause on
pause delete? 
 foreach state in `statelist' {
 cap erase "${tempdir}Skill_Wage_short_percentiles`yrly'_by_Mun_industry_temp_`state'_hcode.dta"
 cap erase "${tempdir}Skill_Wage_short_percentiles`yrly'_by_Mun_industry_tempmale_`state'_hcode.dta"
 cap erase "${tempdir}Skill_Wage_short_percentiles`yrly'_by_Mun_industry_tempfem_`state'_hcode.dta"
}

}
*from yrly











noi di "Start Time=`starttime', End Time=`c(current_time)'"









}
*end qui


