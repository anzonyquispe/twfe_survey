******* this file replicates table 6 in the paper, plus the BHPS summary statistics of Table 1


clear



set mem 500m
set matsize 1500
set maxvar 10000
set more off


local dir3="c:\ag562\research\health\AERfiles\BHPS\stata8"

cd `dir3'

use  eindresp, clear

sort ehid
merge ehid using ehhresp, uniqus sort

tab _m
keep if _m==3
drop _m

gen eyear =1995

renvars, presub(e )

save d1995, replace



use  findresp, clear

sort fhid
merge fhid using fhhresp, uniqus sort

tab _m
keep if _m==3
drop _m

gen fyear =1996

renvars, presub(f )

save d1996, replace


use  gindresp, clear

sort ghid
merge ghid using ghhresp, uniqus sort

tab _m
keep if _m==3
drop _m

gen gyear =1997

renvars, presub(g )

save d1997, replace


use  hindresp, clear

sort hhid
merge hhid using hhhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen hyear = 1998

renvars, presub(h )

save d1998, replace

use  iindresp, clear

sort ihid
merge ihid using ihhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen iyear = 1999

renvars, presub(i )

save d1999, replace



use  jindresp, clear

sort jhid
merge jhid using jhhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen jyear = 2000

renvars, presub(j )

save d2000, replace



use  kindresp, clear

sort khid
merge khid using khhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen kyear = 2001

renvars, presub(k )

save d2001, replace



use  lindresp, clear

sort lhid
merge lhid using lhhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen lyear = 2002

renvars, presub(l )

save d2002, replace

use  mindresp, clear

sort mhid
merge mhid using mhhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen myear =2003

renvars, presub(m )

save d2003, replace


use  nindresp, clear

sort nhid
merge nhid using nhhresp, uniqus sort

tab _m
keep if _m==3
drop _m


gen nyear =2004

drop nqfed* ntrain nxdts naidxhh

renvars, presub(n )

save d2004, replace



use d2004, clear

append using  d2003
append using  d2002
append using  d2001
append using  d2000
append using  d1999
append using  d1998
append using  d1997
append using  d1996
append using  d1995


gen scend_b   = scend
gen plbornd_b = plbornd

drop scend

keep pid age region cjsten scend_b fihhmn fihhyr orgmb mlstat hl2gp jbsoc hhsize xrwght year

sort pid

merge pid using xwavedat

tab  _m
drop _m

sort pid

merge pid using xwaveid

tab  _m
drop _m


gen age2=age^2
gen age3=age^3

gen england  = region<=16
gen wales    = region==17
gen scotland = region==18
gen london   = region==1 | region==2

replace cjsten=. if cjsten<0
gen tenure = (cjsten/365)
gen logt = log(1+(cjsten/365))
gen white = race ==1
gen black = race>=2 & race<=4

replace scend = scend_b if scend ==-8


keep if scend>=0
gen college = fetype>=4 & fetype<=5
gen somec   = fetype>=1 & fetype<=3
gen logy = log(fihhmn)

replace fihhyr=fihhyr/10000

gen fihhyr2 = fihhyr ^2

gen eduy = 15 if college==1
replace eduy = 14 if somec ==1
replace eduy = 12 if college ==0 & scend==0 & scend>=18
replace eduy = min(12,scend - 6) if eduy==.

gen male = sex==1
gen union = orgmb==1

gen married = mlstat == 1

gen md2 = (hl2gp==1)


gen soc1 = int(jbsoc/100)

gen dob1 = doby
replace dob1 = 1935 if doby<=1935

gen dob2 = int(dob1/5)

egen clus = group(male plbornd dob2 year)


bysort clus: gen nins = _N
replace clus = 10000 if nins<=5

bysort clus: egen logt_ins = mean(1+(cjsten/365))

replace logt_ins = log(logt_ins)

keep if age>=18 & age<=65






tsset pid year

bysort pid: gen np=_N

drop if np==1

xi: reg md2 logt age age2 age3 fihhyr fihhyr2 white eduy married hhsize union male england wales scotland i.year,  robust 

xi: ivreg md2 (logt = logt_ins) age age2 age3 fihhyr fihhyr2 white eduy married hhsize union male england wales scotland i.year,  cluster(clus) 


xi: xtivreg2 md2 (logt = logt_ins) age age2 age3 fihhyr fihhyr2 white eduy married hhsize union male england wales scotland i.year, fe robust

xi: xtabond2 md2  l.md2 l(0/1).(logt age age2 age3 eduy fihhyr fihhyr2 white married hhsize union male england wales scotland) i.year,   ///
    gmmstyle(md2, collapse lagl(2 4))   iv(l(0/1).(age age2 age3 eduy fihhyr fihhyr2 white married hhsize union male england wales scotland) i.year)  ///
    gmm(logt_ins, collapse lag(2 3))  robust two

gen c=1 if e(sample)

sum md2 tenure age eduy fihhyr male white black married hhsize union if c==1

erase d2003.dta
erase d2002.dta
erase d2001.dta
erase d2000.dta
erase d1999.dta
erase d1998.dta
erase d1997.dta

