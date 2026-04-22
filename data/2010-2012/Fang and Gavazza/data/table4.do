************ this file replicates table 4, plus the HRS sumary statistics of Table 1


clear 
set more off
set mem 300m 
set maxvar 30000 


local dir1="c:\ag562\research\health\AERfiles"


cd `dir1'

use gdpdefl

keep if year>=1991

gen yy = ceil(year/2)*2

replace gdp = gdp/100

gen def = gdp+gdp[_n-1]

keep if year==yy

drop yy gdp
sort year

save defl, replace

do hrs_newinst.do

do hrs_instr1.do



# delimit ;

use r*jlind r*jlocc r*totmd r*agey_b raracem r*mstat r*govmr h*atota raedyrs r*doctim
hhidpn r*higov r*wtresp ragender r*shlt r*jlten r*iwmid r*cenreg hhid h*hhres rabplace rabyear r*cendiv r*sayret r*jnjob r*jnjob5
using rndhrs_h, clear; 		


keep r*jlind r*jlocc r*totmd r*agey_b raracem r*mstat r*govmr h*atota raedyrs r*doctim
hhidpn r*higov r*wtresp ragender r*shlt r*jlten r*iwmid r*cenreg hhid h*hhres rabplace rabyear r*cendiv r*sayret r*jnjob r*jnjob5;

# delimit cr

drop r7* h7* r8* h8*

local i =1

while `i'<=6 {

rename r`i'jlind   jlind`i'
rename r`i'jlocc   jlocc`i'
rename r`i'totmd   totmd`i'
rename r`i'agey_b  agey`i'
rename r`i'mstat   mstat`i'
rename r`i'govmr   govmr`i'
rename r`i'higov   higov`i'
rename h`i'atota   atota`i'
rename r`i'wtresp  wtresp`i'
rename r`i'shlt    shlt`i'
rename r`i'jlten   jlten`i'
rename r`i'iwmid   iwmid`i'
rename r`i'cenreg  cenreg`i'
rename h`i'hhres   hhres`i'
rename r`i'doctim  doctim`i'
rename r`i'cendiv  cendiv`i'
rename r`i'sayret  sayret`i'
rename r`i'jnjob   jnjob`i'
rename r`i'jnjob5  jnjob5`i'


local i=`i'+1
}

ren raracem  race
ren raedyrs  educ
ren ragender gender


drop if hhidpn ==44764011 | hhidpn == 50825041 | hhidpn == 56955011 | hhidpn== 79662011 


reshape long jlind totmd agey mstat govmr atota higov wtresp shlt jlten iwmid jlocc ///
             hhres cenreg doctim cendiv sayret jnjob jnjob5, ///
             i(hhidpn) j(wave)

gen resp = 1


save resp.dta, replace
sort hhidpn resp wave

egen id = group(hhidpn resp)

sort id wave
by id wave: gen count=_n
drop if count>1
drop count
sort id wave
tsset id wave

gen ddays = iwmid - l.iwmid




tab gender if jlind~=. & agey>=67 & govmr==1 

replace atota = atota/1000000






gen double totmd_a = totmd
replace totmd_a    =. if totmd==0


sort hhidpn resp wave

sum jlind





***************

gen agey2 = agey^2
gen agey3 = agey^3


gen pose = totmd>0

set more off



gen married = mstat==1 | mstat==2

gen male = gender ==1

label var agey  	"Age"
label var agey2 	"Age Squared"
label var agey3 	"Age Cubed"
label var educ  	"Years of Education"
label var atota 	"Total Assets / 100000"
label var hhres 	"Size of Family"
label var married "Married"
label var male	"Male"


gen year = wave

recode year (1 = 1992) (2 = 1994) (3 = 1996) (4 = 1998) (5 = 2000) (6 = 2002) (7 = 2004) (8 = 2006)

sort year

merge year using defl

tab  _m
drop _m

sort year

merge year using gdpdefl

tab  _m
drop _m

replace gdpdefl = gdpdefl/100


gen loge  = log(totmd+1)
gen logee = loge 
replace logee =. if loge==0 


gen logasp     = log(1+atota)
replace logasp = 0 if logasp==.

gen logasm     = log(-(1+atota))
replace logasm = 0 if logasm==.


replace atota = atota/gdp
gen mdd = totmd/def

gen atota2 = atota^2

gen double mdd_a = mdd
replace mdd_a = . if mdd==0

gen logmd = log(1+mdd)

gen double logmd_a = logmd
replace    logmd_a = . if logmd==0

gen ljlten = log(jlten)

********

gen rabdec = int(rabyear/5)

gen college = educ>12

gen white = race==1
egen idiv = group(rabplace wave male educ white)

bysort idiv: egen mjl2      = mean(jlten)
bysort idiv: egen lmjl2     = mean(ljlten)
bysort idiv: egen mjob2     = mean(jnjob)
bysort idiv: egen mjob2_5   = mean(jnjob5)

 

gen lm  = log(mjl)
gen lm2 = log(mjl2)

gen mhs2 = (shlt==4|shlt==5)
gen mhs3 = (shlt==1|shlt==2)



sort rabplace 

merge rabplace using hrs_ins1

tab _m

gen age80 = 1980-rabyear
gen age90 = 1990-rabyear

gen int1 = age80*ic1980
gen int2 = age90*ic1990

gen int3 = college*ic1980
gen int4 = college*ic1990

gen int5 = male*ic1980
gen int6 = male*ic1990

gen int7 = white*ic1980
gen int8 = white*ic1990

gen w6 = wave==6
gen w5 = wave==5
gen w4 = wave==4
gen w3 = wave==3

gen w56 = w6+w5

gen ww= wave
recode ww (5 = 6) 

egen cy = group(cendiv wave)

/*
xi:  xtivreg logmd (ljlten = ic* int1-int8 ) agey agey2 agey3 educ atota atota2 male i.race married hhres i.cendiv w4 w6 if agey>=66 & wave>=3, re first
xi:  xtivreg mhs2  (ljlten = ic* int1-int6 ) agey agey2 agey3 educ atota atota2 male i.race married hhres i.cendiv w4 w6 if agey>=66 & wave>=3, re

gen d=e(sample)

sum mdd mhs2 jlten ljlten agey educ atota male married hhres wh bl if e(sample)

*/

gen wh = race==1
gen bl = race==2

gen manu = jlind==4 | jlind==3

ttest jlten if (jlind == 4| jlind==3 | jlind==7) & govmr==1 & agey>=66          , by(manu)
ttest mdd if (jlind == 4| jlind==3 | jlind==7) & govmr==1 & agey>=66          , by(manu)

drop _m

*recode rabplace (10=11)
*recode jlind (.=15) (.m=16) (.q=20)
*recode jlind (4=3) (11=9) (10=9) (12=9)
sort rabplace jlind

merge rabplace using hrs_newinst

tab _m

gen int11 = (age90-educ)*emp_death_r
gen int12 = (age90-educ)*est_death_r

gen int13 = educ*emp_death_r
gen int14 = educ*est_death_r

gen int15 = (male==0)*emp_death_r
gen int16 = (male==0)*est_death_r

gen int17 = educ*(male==0)*emp_death_r
gen int18 = educ*(male==0)*est_death_r



xi:  xtivreg logmd (ljlten = *death_r int13-int16) agey agey2 agey3 educ atota atota2 male i.race married hhres i.cendiv i.jlind w4 w5 w6 if agey>=66 & wave>=3, re ec2sls
xi:  xtivreg mhs2  (ljlten = *death_r int13-int16) agey agey2 agey3 educ atota atota2 male i.race married hhres i.cendiv i.jlind w4 w5 w6 if agey>=66 & wave>=3, re ec2sls

xi:  reg ljlten emp_death_r int13-int16 agey agey2 agey3 educ atota atota2 male i.race married hhres i.cendiv i.jlind w4 w5 w6 if agey>=66 & wave>=3

sum mdd mhs2 jlten ljlten agey educ atota male married hhres wh bl if e(sample)

