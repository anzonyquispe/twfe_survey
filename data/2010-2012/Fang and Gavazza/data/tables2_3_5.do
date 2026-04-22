clear


* this file creates: 
* 1- the summary statistics on MEPS data reported in Table 1; 
* 2- specifications (1), (2) and (3) in Table 2; 
* 3- specifications (1), (2) and (3) in Table 3; 
* 4- specifications (1), (2) and (3) in Table 5. 
* change local dir1 and local dir2 below

set more off

capture log close

local dir1="c:\ag562\research\health\AERfiles"
local dir2="c:\ag562\research\health\AERfiles\meps"



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


keep duid pid panel year dobyy region31 cind31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31





save d1996, replace


use h20, clear
ren age97x age
ren ttlp97x ttlp
ren educyr97 educyear

renvars, postsub(97 )
renvars, postsub(97x x)


gen year = 1997

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa marryx begrfm31

save d1997, replace

use h28, clear
ren age98x age
ren ttlp98x ttlp
ren educyr98 educyear

renvars, postsub(98 )
renvars, postsub(98x x)


gen year = 1998

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa marryx begrfm31

save d1998, replace

use h38, clear
ren age99x age
ren ttlp99x ttlp
renvars, postsub(99 )
renvars, postsub(99x x)


gen year = 1999

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31

save d1999, replace

use h50, clear

ren age00x age
ren ttlp00x ttlp
renvars, postsub(00 )
renvars, postsub(00x x)


gen year = 2000

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31

save d2000, replace

use h60, clear

ren age01x age
ren ttlp01x ttlp
renvars, postsub(01 )
renvars, postsub(01x x)


gen year = 2001

keep duid pid panel year dobyy region31 cind31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31

save d2001, replace

use h70, clear
ren age02x age
ren ttlp02x ttlp
renvars, postsub(02 )
renvars, postsub(02x x)
gen year = 2002

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31


save d2002, replace

use h79, clear
ren age03x age
ren ttlp03x ttlp
renvars, postsub(03 )
renvars, postsub(03x x)
gen year = 2003

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31


save d2003, replace

use h89, clear
ren age04x age
ren ttlp04x ttlp
renvars, postsub(04 )
renvars, postsub(04x x)
gen year = 2004

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31


save d2004, replace

use h97, clear
ren ttlp05x ttlp
ren age05x age
ren educyr educyear

renvars, postsub(05 )
renvars, postsub(05x x)
gen year = 2005

keep duid pid panel year dobyy region31 indcat31 selfcm31 stjbmm31 stjbyy31 totexp offer31x educyear ttlp region rthlth31 obdrv racex famsze31 numemp31 age tottch union31 sex msa ddnwrk31 marryx begrfm31

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

gen tenure = year - stjbyy31
sum tenure



egen y_r = group(year region31)

gen male  = sex
gen ltenu = log(.01+tenure)
gen lmexp = log(.01+totexp)
gen inc   = ttlp/10000
gen inc2  = ttlp2/10000
gen md2   = (obdrv==0)
gen mhi   = offer31x 

gen wh = (racex==1 & year>=2002) | (racex==5 & year<2002)
gen bl = (racex==2 & year>=2002) | (racex==4 & year<2002)
gen marry = (marryx==1)

gen ff250   = (numemp31>=250 & numemp31<=500)
gen ff50    = (numemp31>=50  & numemp31<250)
gen ff10   	= (numemp31>=10  & numemp31<50)




keep if indcat31>=0 
keep if indcat31 == 1 | indcat31 == 2 | indcat31 == 3 | indcat31 == 4 | indcat31 == 5 | indcat31 == 6 | indcat31 == 7  | indcat31 == 8 | indcat31 == 9 | indcat31 == 10| indcat31 == 11| indcat31 == 12| indcat31 == 13| indcat31 == 14 | indcat31 == 15 




recode indcat31 (8/10 = 11) if year<1999


drop if id==.

sort year indcat31 region31


sort  year indcat31 region31
merge year indcat31 region31 using `dir1'\firmsall

drop _m



bysort idd year: gen d=_N
drop if d>1

tsset idd year
sort idd year

gen iv1 = est_deaths
gen iv2 = est_death_r
gen iv3 = emp_deaths
gen iv4 = emp_death_r

gen iv5 = est_deaths*male
gen iv6 = est_death_r*male
gen iv7 = emp_deaths*male
gen iv8 = emp_death_r*male 

gen iv9 = est_deaths*age
gen iv10 = est_death_r*age
gen iv11 = emp_deaths*age
gen iv12 = emp_death_r*age


gen iv13 = est_deaths*educyear 
gen iv14 = est_death_r*educyear 
gen iv15 = emp_deaths*educyear 
gen iv16 = emp_death_r*educyear 


local i = 1
while `i'<17 {
gen l1iv`i' = l.iv`i'
gen l2iv`i' = l2.iv`i'

local i = `i' +1
}







egen id3 = group(indcat31 region31 year)


capture log close



********** Table 2

xi: reg lmexp  ltenu age age2 age3 educyear inc inc2 male wh bl marry famsze31 ff250 ff50 ff10 union31 i.y_r, robust

xi: ivreg2    lmexp  age age2 age3 educyear inc inc2 male wh bl marry famsze31 ff250 ff50 ff10 union31  i.y_r (ltenu = iv1 iv2 iv3 iv4 iv7 iv11),  cue robust

xi: ivreg2    d.lmexp  d.age d.age2 d.age3 d.educyear d.inc d.inc2 d.marry d.famsze31 d.ff250 d.ff50 d.ff10 d.union31 i.y_r  (d.ltenu = iv1 iv2 iv3 iv4 iv9 iv11 l1iv1 l1iv2 l1iv3 l1iv4 l1iv9),   gmm2s  robust






******** Table 3

xi: reg md2  ltenu age age2 age3 educyear inc inc2 male wh bl marry famsze31 ff250 ff50 ff10 union31 i.y_r, robust

xi: ivreg2    md2  age age2 age3 educyear inc inc2 male wh bl marry famsze31 ff250 ff50 ff10 union31  i.y_r (ltenu = iv*),  gmm2s robust

xi: ivreg2    d.md2  d.age d.age2 d.age3 d.educyear d.inc d.inc2 d.marry d.famsze31 d.ff250 d.ff50 d.ff10 d.union31 i.y_r (d.ltenu = iv1 iv2 iv3 iv4 iv7 iv11 l1iv1 l1iv3),   cue robust





***************** Table 5

xi: reg mhi  ltenu age age2 age3 educyear inc inc2 male wh bl marry famsze31 ff250 ff50 ff10 union31 i.y_r, robust

xi: ivreg2    mhi  age age2 age3 educyear inc inc2 male wh bl marry famsze31 ff250 ff50 ff10 union31  i.y_r (ltenu = iv*),  gmm2s robust

xi: ivreg2    d.mhi  d.age d.age2 d.age3 d.educyear d.inc d.inc2 d.marry d.famsze31 d.ff250 d.ff50 d.ff10 d.union31 i.y_r (d.ltenu = iv1 iv2 iv3 iv4 iv7 iv11 l1iv1 l1iv3),   gmm2s robust









