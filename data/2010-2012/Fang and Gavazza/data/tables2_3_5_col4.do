

* this file creates: 
* 1- specification (4) in Table 2; 
* 2- specification (4) in Table 3; 
* 3- specification (4) in Table 5. 
* change local dir1 and local dir2 below

local dir1="c:\ag562\research\health\AERfiles"

local dir2="c:\ag562\research\health\AERfiles\meps"


clear
set more off

capture log close





cd `dir1'

clear
set mem 500m
set matsize 1000

set maxvar 20000

do firms4.do

cd `dir2'





use h12, clear

gen panel = 1
gen year  = 1996

ren ttlpnx ttlp
ren educyr96 educyear
ren age96x age

renvars, postsub(1 31)
renvars, postsub(2 42)
renvars, postsub(96 )
renvars, postsub(96x x)
renvars, postsub(1x 31x)

ren rtehlth31 rthlth31
ren begrefd31 begrfd31
ren begrefm31 begrfm31
ren begrefy31 begrfy31
ren famsize31 famsze31
ren ddnowrk31 ddnwrk31

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx

save d1996, replace


use h20, clear
ren age97x age
ren ttlp97x ttlp
ren educyr97 educyear

renvars, postsub(97 )
renvars, postsub(97x x)


gen year = 1997

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa marryx

save d1997, replace

use h28, clear
ren age98x age
ren ttlp98x ttlp
ren educyr98 educyear

renvars, postsub(98 )
renvars, postsub(98x x)


gen year = 1998

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa marryx

save d1998, replace

use h38, clear
ren age99x age
ren ttlp99x ttlp
renvars, postsub(99 )
renvars, postsub(99x x)


gen year = 1999

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx

save d1999, replace

use h50, clear

ren age00x age
ren ttlp00x ttlp
renvars, postsub(00 )
renvars, postsub(00x x)


gen year = 2000

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx

save d2000, replace

use h60, clear

ren age01x age
ren ttlp01x ttlp
renvars, postsub(01 )
renvars, postsub(01x x)


gen year = 2001

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx

save d2001, replace

use h70, clear
ren age02x age
ren ttlp02x ttlp
renvars, postsub(02 )
renvars, postsub(02x x)
gen year = 2002

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx


save d2002, replace

use h79, clear
ren age03x age
ren ttlp03x ttlp
renvars, postsub(03 )
renvars, postsub(03x x)
gen year = 2003

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx


save d2003, replace

use h89, clear
ren age04x age
ren ttlp04x ttlp
renvars, postsub(04 )
renvars, postsub(04x x)
gen year = 2004

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx


save d2004, replace

use h97, clear
ren ttlp05x ttlp
ren age05x age
ren educyr educyear

renvars, postsub(05 )
renvars, postsub(05x x)
gen year = 2005

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 ///
     numemp31 age tottch union31 sex msa ddnwrk31 marryx

save d2005, replace



use d2005, clear

local i = 1996
while `i'<2005 {
append using d`i'
compress

local i=`i'+1
}

compress

save mepsall, replace


use mepsall, clear

egen idd = group(duid pid panel)

tsset idd year

gen born = dobyy
gen born2 = int(dobyy/10)

replace region31 = . if region31<0

replace indcat31 = cind31 if year<2002

**** check with file firms4.do how "information" industry is coded
recode indcat31 (5=6) (6=5) (7=4) (8=7) (9=11) (10=9) (11=10) (12=8) (13=12) (15=13) if year>=2002


drop if selfcm31==1

recode sex      (2=0)

replace stjbyy31 =. if stjbyy31<0
replace stjbyy31 = stjbyy31 + 1900 if year<=1997

replace totexp=.        if totexp<0
replace offer31x=.  	if offer31x<0
replace educyear=.  	if educyear<0
replace ttlp=.      	if ttlp<0
replace region=.        if region<0
replace rthlth31=.  	if rthlth31<0
replace obdrv=.         if obdrv<0
*replace stjbyy31=.     if year-panel~=1995
replace racex =. 		if racex<0
replace famsze31 =.	if famsze31 <0
replace numemp31 = .    if numemp31 <0
replace age = .		if age <0
replace tottch=.        if tottch<0
replace union31=.       if union31<0
replace ddnwrk31=.      if ddnwrk31<0
replace marryx=.      	if marryx<0


gen edicat = 1 if educyear<12 | educyear==.
replace edicat = 2 if edicat~=1   & educyear<=12
replace edicat = 3 if (edicat~=1 | edicat~=2) & educyear<16
replace edicat = 4 if (edicat~=1 | edicat~=2 | edicat~=3) & educyear>=16





egen id = group(born2 indcat31 region31 sex) 

egen id2 = group(indcat31 region31)


sort year

merge year using `dir1'\gdpdefl

drop _m
drop if year<=1995

keep if age<=65 & age>=18


replace totexp	= totexp/gdpdefl*100
replace ttlp  	= ttlp/gdpdefl*100
replace tottch	= tottch/gdpdefl*100



gen age2  = age^2
gen age3  = age^3
gen ttlp2 = ttlp^2

recode offer31x (2=0)
recode union31  (2=0)

gen tenure = year-stjbyy31
sum tenure



bysort id2 year:        egen turn = mean(tenure<=1)
bysort id2 year:        gen totind = _N
bysort region year:     gen tote = _N

*keep if age<=65 & age>=18

gen shemp = totind/tote

bysort id year: gen w       = _N

bysort id year: egen mexp   = mean(totexp) 
bysort id year: egen mlmexp = mean(log(1+totexp)) 
bysort id year: egen mch    = mean(tottch) 
bysort id year: egen vexp   = sd(totexp) 
bysort id year: egen mhi    = mean(offer31x) 
bysort id year: egen vhi    = sd(offer31x) 
bysort id year: egen medu   = mean(educyear) 
bysort id year: egen minc   = mean(ttlp/10000) 
bysort id year: egen minc2  = mean(ttlp2/10000) 
bysort id year: egen mhs    = mean(rthlth31)
bysort id year: egen mhs2   = mean(rthlth31==1|rthlth31==2)
bysort id year: egen md     = mean(obdrv)
bysort id year: egen lmd    = mean(log(1+obdrv))
bysort id year: egen md2    = mean(obdrv==0)
bysort id year: egen mage   = mean(age)
bysort id year: egen mage2  = mean(age2)
bysort id year: egen mage3  = mean(age3)
bysort id year: egen mtenu  = mean(tenure)
bysort id year: egen mltenu = mean(log(1+tenure))
bysort id year: egen dnw    = mean(ddnwrk31)
bysort id year: egen dnw2   = mean(ddnwrk31==0)


bysort id year: egen male  	= mean(sex)
bysort id year: egen whi   	= sum(offer31x~=.)
bysort id year: egen wexp  	= sum(totexp~=.)
bysort id year: egen wch   	= sum(tottch~=.)
bysort id year: egen white 	= mean((racex==1 & year>=2002) | (racex==5 & year<2002))
bysort id year: egen black 	= mean((racex==2 & year>=2002) | (racex==4 & year<2002))
bysort id year: egen f250  	= sum(numemp31>=250 & numemp31<=500)
bysort id year: egen f50   	= sum(numemp31>=50  & numemp31<250)
bysort id year: egen f10   	= sum(numemp31>=10  & numemp31<50)
bysort id year: egen totf  	= sum(numemp31~=.)
bysort id year: egen mmsa  	= mean(msa==0)
bysort id year: egen munio 	= mean(union31)
bysort id year: egen married  = mean(marryx==1)

replace f250 = f250/totf
replace f50  = f50/totf
replace f10  = f10/totf



sum mhi turn mexp if mhi~=.

collapse tenure turn totind born born2 dobyy indcat31 region31 mexp mhi mhs mhs2 md medu minc minc2 male mage mage2 mage3 whi ///
         wexp shemp vexp vhi white black tote famsze31 f250 f50 f10 mch wch mmsa munio mtenu mlmexp mltenu lmd md2 w dnw dnw2 married ///
         , by(id year)

sum mhi turn mexp [fw=whi]


egen id2 = group(indcat31 region31)
keep if indcat31>=0 
keep if indcat31 == 1 | indcat31 == 2 | indcat31 == 3 | indcat31 == 4 | indcat31 == 5 | indcat31 == 6 | indcat31 == 7  | ///
        indcat31 == 8 | indcat31 == 9 | indcat31 == 10| indcat31 == 11| indcat31 == 12| indcat31 == 13| indcat31 == 14 | ///
        indcat31 == 15 


recode indcat31 (8/10 = 11) if year<1999

expand 3 if year==2005

bysort id year: gen count = _n

replace year = year+count-1 if count>1

replace mhi    = . if year>2005
replace mexp   = . if year>2005
replace mlmexp = . if year>2005
replace mage   = . if year>2005
replace mage2  = . if year>2005
replace md     = . if year>2005
replace md2    = . if year>2005
replace mch    = . if year>2005
replace mhs    = . if year>2005
replace mhs2   = . if year>2005
replace minc   = . if year>2005





drop if id==.



sort  year indcat31 region31
merge year indcat31 region31 using `dir1'\firmsall

drop _m





egen id3 = group(year indcat31 region31)


tsset id year

gen lmexp = log(1+mexp)

 
sort id year
gen w1 = (whi+l.whi)/2
gen w2 = (wexp+l.wexp)/2

gen q1 = mtenu - l.mtenu

gen q2 = mltenu - l.mltenu



*keep if year>=2002


capture log close

egen y_i = group(year indcat31)
egen y_r = group(year region31)





********* autocorrelated errors

xi: xtabond2 mhi  l.mhi  l(0/1).(mltenu mage mage2 mage3 medu minc minc2 male white black married famsze31 f250 f50 f10 munio)   ///
    i.y_r [aw=w], gmmstyle(mhi, lagl(2 6))   ///
    iv(l(0/1).( mage mage2 mage3 medu minc minc2 male white black married famsze31 f250 f50 f10 munio) i.y_r)  ///
    gmm(est_death_r emp_death_r est_deaths emp_deaths , eq(diff)  lagl(2 6) )  ///
    gmm(est_death_r emp_death_r est_deaths emp_deaths , eq(level) lagl(2 6) ) robust two 

gen cc=1 if e(sample)
sum mexp md2 tenure mltenu mhi mage medu minc male white black married famsze31 f250 f50 f10 munio [aw=w] if e(sample)




xi: xtabond2 mlmexp  l.mlmexp l(0/1).(mltenu mage mage2 mage3 medu minc minc2 male white black married famsze31 f250 f50 f10 munio)   ///
    i.y_r [aw=w] if cc==1, gmmstyle(mlmexp, lagl(2 6))   ///
    iv(l(0/1).( mage mage2 mage3 medu minc minc2 male white black married famsze31 f250 f50 f10 munio) i.y_r)  ///
    gmm(est_death_r emp_death_r est_deaths emp_deaths , eq(diff)  lagl(2 6))  ///
    gmm(est_death_r emp_death_r est_deaths emp_deaths , eq(level) lagl(2 6)) robust two 

xi: xtabond2 md2  l.md2 l(0/1).(mltenu mage mage2 mage3 medu minc minc2 male white black married famsze31 f250 f50 f10 munio)   ///
    i.y_r [aw=w] if cc==1, gmmstyle(md2, lagl(2 6))   ///
    iv(l(0/1).( mage mage2 mage3 medu minc minc2 male white black married famsze31 f250 f50 f10 munio) i.y_r)  ///
    gmm(est_death_r emp_death_r est_deaths emp_deaths , eq(diff)  lagl(2 6) )  ///
    gmm(est_death_r emp_death_r est_deaths emp_deaths , eq(level) lagl(2 6) ) robust 

