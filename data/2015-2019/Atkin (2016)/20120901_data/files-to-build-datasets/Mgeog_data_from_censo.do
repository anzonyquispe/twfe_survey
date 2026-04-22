
global censodir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_censo\"
global firmdir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_ss_Stata\"
global workdir="C:\Stata10\"
*local inddir="C:\Documents and Settings\datkin\Desktop\Stata9files\"
*local inddir="C:\Documents and Settings\datkin\Desktop\mexico_ss_Stata\"
local inddir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_ss_Stata\"
global dir="H:\Mexico\"
*global dir="C:\Hdrive\\Mexico\"

global dirnet="/n/homeserver2/user2a/datkin/Mexico/"

*local dir="/n/homeserver2/user2a/datkin/Mexico/"
*local dir="H:\Mexico\"

do "${dir}munpop_changes.do"


clear
set mem 900m

set more off




*this bit gets stuff out of census. Since I dont actually use this data at present i will skip it
*it needs to be updated if I want to use it
/*
use "/var/scratch/datkin/mexico_censo_05_full.dta", clear

keep munimx wtper year lit age urban sex


*This file prepares censo_05 for use 
replace munimx=20319 if munimx==20318
*This turns the two municipios that are San Pedro Mixtepec - distr. 22 and San Pedro Mixtepec - distr. 26 into one to match IMSS

do "/n/homeserver2/user2a/datkin/Mexico/munimxchanges.do"
*this gets us to 1990 municipality lists

rename munimx muncenso




egen xlit2000=total(wtper) if year==2000 & lit==2 & age>31, by(muncenso)
egen lit2000=max(xlit2000), by(muncenso)
egen xilit2000=total(wtper) if year==2000 & lit==1 & age>31, by(muncenso)
egen ilit2000=max(xilit2000), by(muncenso)
gen lit_32up_2000=lit2000/(lit2000 + ilit2000)
drop lit2000 ilit2000

egen xurbanpop2000=total(wtper) if year==2000 & urban==2, by(muncenso)
egen urbanpop2000=max(xurbanpop2000), by(muncenso)
egen xmunpop2000=total(wtper) if year==2000, by(muncenso)
egen munpop2000=max(xmunpop2000), by(muncenso)
egen xmalemunpop15_49_2000=total(wtper) if age>14 & age<50 & sex==1 & year==2000, by(muncenso)
egen xfemalemunpop15_49_2000=total(wtper) if age>14 & age<50 & sex==2 & year==2000, by(muncenso)
egen malemunpop15_49_2000=max(xmalemunpop15_49_2000), by(muncenso)
egen femalemunpop15_49_2000=max(xfemalemunpop15_49_2000), by(muncenso)
egen xmalemunpop2000=total(wtper) if sex==1 & year==2000, by(muncenso)
egen xfemalemunpop2000=total(wtper) if sex==2 & year==2000, by(muncenso)
egen malemunpop2000=max(xmalemunpop2000), by(muncenso)
egen femalemunpop2000=max(xfemalemunpop2000), by(muncenso)

egen xlit1990=total(wtper) if year==1990 & lit==2 & age>21, by(muncenso)
egen lit1990=max(xlit1990), by(muncenso)
egen xilit1990=total(wtper) if year==1990 & lit==1 & age>21, by(muncenso)
egen ilit1990=max(xilit1990), by(muncenso)
gen lit_22up_1990=lit1990/(lit1990 + ilit1990)
drop lit1990 ilit1990


egen xurbanpop1990=total(wtper) if year==1990 & urban==2, by(muncenso)
egen urbanpop1990=max(xurbanpop1990), by(muncenso)
egen xmunpop1990=total(wtper) if year==1990, by(muncenso)
egen munpop1990=max(xmunpop1990), by(muncenso)
egen xmalemunpop15_49_1990=total(wtper) if age>14 & age<50 & sex==1 & year==1990, by(muncenso)
egen xfemalemunpop15_49_1990=total(wtper) if age>14 & age<50 & sex==2 & year==1990, by(muncenso)
egen malemunpop15_49_1990=max(xmalemunpop15_49_1990), by(muncenso)
egen femalemunpop15_49_1990=max(xfemalemunpop15_49_1990), by(muncenso)
egen xmalemunpop1990=total(wtper) if sex==1 & year==1990, by(muncenso)
egen xfemalemunpop1990=total(wtper) if sex==2 & year==1990, by(muncenso)
egen malemunpop1990=max(xmalemunpop1990), by(muncenso)
egen femalemunpop1990=max(xfemalemunpop1990), by(muncenso)
*this gets population measures (by sex if working, whole pop otherwise)

mvencode urbanpop* , mv(0) override
*/

use "${censodir}mexico_censo_10.dta", clear
*this is 2000 census

keep wtper munimx age sex 


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







rename munimx muncenso


egen xmunpop2005=total(wtper) , by(muncenso)
egen munpop2005=max(xmunpop2005), by(muncenso)
egen xmalemunpop15_49_2005=total(wtper) if age>14 & age<50 & sex==1 , by(muncenso)
egen xfemalemunpop15_49_2005=total(wtper) if age>14 & age<50 & sex==2 , by(muncenso)
egen malemunpop15_49_2005=max(xmalemunpop15_49_2005), by(muncenso)
egen femalemunpop15_49_2005=max(xfemalemunpop15_49_2005), by(muncenso)
egen xmalemunpop2005=total(wtper) if sex==1 , by(muncenso)
egen xfemalemunpop2005=total(wtper) if sex==2 , by(muncenso)
egen malemunpop2005=max(xmalemunpop2005), by(muncenso)
egen femalemunpop2005=max(xfemalemunpop2005), by(muncenso)
drop x* age sex wtper

gen munpop15_49_2005=malemunpop15_49_2005+femalemunpop15_49_2005






egen tagmun=tag(muncenso)
drop if tagmun==0

*keep muncenso lit_32up_2000-femalemunpop1990
drop tagmun



gen state=string(muncenso,"%05.0f")
replace state=regexr(state,"[0-9][0-9][0-9]$","")
destring state, replace
format state %02.0f
do "${dir}region_labels.do"




*renpfix munpop cenmunpop
*renpfix femalemunpop cenfemalemunpop
*renpfix malemunpop cenmalemunpop

foreach num in "1990" "1995" "2000" {
sort muncenso
merge muncenso using "${dir}munpop`num'.dta", nokeep _merge(_merge10)
*merge muncenso using "H:\Mexico\munpop`num'.dta", nokeep _merge(_merge10)
drop _merge10
gen munpop`num'= malemunpop`num'+ femalemunpop`num'
gen munpop15_49_`num'= malemunpop15_49_`num'+ femalemunpop15_49_`num'
sort muncenso
}

sort muncenso
merge muncenso using "${dir}munpop1980.dta", nokeep keep(pop80 km2) _merge(_merge11)
*merge muncenso using "H:\Mexico\munpop1980.dta", nokeep keep(pop80 km2) _merge(_merge11)
rename pop80 munpop1980
drop _merge11



gen sizemunpop2000=1 if munpop2000>0 & munpop2000<5000
replace sizemunpop2000=2 if munpop2000>4999 & munpop2000<15000
replace sizemunpop2000=3 if munpop2000>14999 & munpop2000<30000
replace sizemunpop2000=4 if munpop2000>29999 & munpop2000<10000000000000000

gen sizemunpop1990=1 if munpop1990>0 & munpop1990<5000
replace sizemunpop1990=2 if munpop1990>4999 & munpop1990<15000
replace sizemunpop1990=3 if munpop1990>14999 & munpop1990<30000
replace sizemunpop1990=4 if munpop1990>29999 & munpop1990<10000000000000000

cap label define sizemunpoplbl 1 "<5000" 2 "5000 to 15000" 3 "15000 to 30000" 4 "30000+"
label values sizemunpop2000 sizemunpoplbl
label values sizemunpop1990 sizemunpoplbl

egen regionsize2000=concat(region1 sizemunpop2000)
egen regionsize2_2000=concat(region2 sizemunpop2000)
egen regionsize1990=concat(region1 sizemunpop1990)
egen regionsize2_1990=concat(region2 sizemunpop1990)

destring regionsize2*, replace
cap label define regionsize2lbl 21 "North Tiny" 22 "North Small" 23 "North Med" 24 "North Large" 31 "Center Tiny" 32 "Center Small" 33 "Center Med" 34 "Center Large" 61 "South Tiny" 62 "South Small" 63 "South Med" 64 "South Large"
label values regionsize2_2000 regionsize2lbl
label values regionsize2_1990 regionsize2lbl



*gen ruralper1990=urbanpop1990/cenmunpop1990
gen popdens=munpop1990/km2 
gen popdensindex=1 if popdens<=20
replace popdensindex=2 if popdens>20 & popdens<=50
replace popdensindex=3 if popdens>50 & popdens<=125
replace popdensindex=4 if popdens>125 & popdens<=100000000000000




egen regsizerural3=concat(region2 popdensindex)
destring regsizerural3, replace
cap label define regsizerural3lbl 21 "North Tiny" 22 "North Small" 23 "North Med" 24 "North Large" 31 "Center Tiny" 32 "Center Small" 33 "Center Med" 34 "Center Large" 61 "South Tiny" 62 "South Small" 63 "South Med" 64 "South Large"
label values regsizerural3 regsizerural3lbl

rename muncenso munimx
do "${dir}munmatch.do"
rename munimx muncenso 









sort muncenso

merge muncenso using ${dir}distance2border.dta, nokeep keep(distfron) _merge(_mergedistfron)
drop _mergedistfron
sort muncenso

save "${dir}mungeog.dta", replace




drop *size*  popden*

rename muncenso munimx
sort munimx
merge munimx using "${dir}zonamet.dta", nokeep _merge(_mergeZM)
drop munimx
rename munimxZM muncenso


egen xdistfron=wtmean(distfron), by(muncenso) weight(munpop1990)
replace xdistfron=distfron if munpop1990==.
drop distfron
*this gets population weighted municipality distance from us border

foreach var of varlist *munpop*  km2 {
egen x`var'=total(`var'), by (muncenso)
drop `var'
}


egen xmunmatch=max(munmatch), by(muncenso)
drop munmatch



renpfix x 
egen tagmunyear=tag(muncenso)
drop if tagmun==0

*gen ruralper1990=urbanpop1990/cenmunpop1990
gen popdens=munpop1990/km2 
gen popdensindex=1 if popdens<=20
replace popdensindex=2 if popdens>20 & popdens<=50
replace popdensindex=3 if popdens>50 & popdens<=125
replace popdensindex=4 if popdens>125 & popdens<=100000000000000


sort muncenso
save "${dir}mungeogZM.dta", replace



noi di "note that to get munworkdatageog.dta we need mungeogZM.dta as an input"
pause on
pause here

*local dir="H:\Mexico\"
*use "`dir'mungeogZM.dta", clear



*note that to get munworkdatageog.dta we need mungeogZM.dta as an input
joinby muncenso using "${dir}munworkdatageog.dta", unm(u)





egen maxpop=max(munpop2000), by(muncensonew)
gen xstate=state if munpop2000==maxpop
drop state
egen state=max(xstate), by(muncensonew)
drop xstate
*when a municipality now straddles two states i put it in teh state with the bigger population municipality

egen xdistfron=wtmean(distfron), by(muncensonew) weight(munpop1990)
replace xdistfron=distfron if munpop1990==.
drop distfron
*this gets population weighted municipality distance from us border

foreach var of varlist *munpop*  km2 {
egen x`var'=total(`var'), by (muncensonew)
drop `var'
}

egen xmunmatch=max(munmatch), by(muncenso)
drop munmatch



renpfix x 
egen tagmunnew=tag(muncensonew)
drop if tagmunnew==0

rename muncenso muncensoold
rename muncensonew muncenso
label val  muncenso munimxlbl




sort muncenso
save "${dir}mungeogMerge.dta", replace


