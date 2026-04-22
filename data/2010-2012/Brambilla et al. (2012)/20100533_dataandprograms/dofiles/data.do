* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

* This file reads the original matched plants-customs data and merging with additional information creates working datasets
* It saves two files: data.dta (used to create all tables) and datalong.dta (for Table 1)


clear
set mem 500m
set more off

* Read matched firms-customs data
use ../datafiles/firmdata, clear

* 2 digit industry indicators (Table 4)
gen isic2=real(substr(string(isicmain), 1, 2))

save data1, replace


**********************************************
* Drop firms with missing info
**********************************************

* Mark firms with data on workers for 1998
gen a=1 if year==1998 & workers~=.
	egen b=sum(a), by(firmid)
	replace b=1 if b>0 & b~=.
* Mark firms with data on workers for either 1999 or 2000 (and 1998)
gen c=1 if year~=1998 & workers~=.
	egen d=sum(c), by(firmid)
	replace b=0 if d==0 | d==.
* Merge marked firms with main data and keep firms with data in 1998 and either 1999 or 2000 or both (b==1)
bys firmid: drop if _n>1
keep firmid b
sort firmid
save temp, replace
use data1, clear
sort firmid
merge firmid using temp
drop _merge
keep if b==1
drop b
erase temp.dta

******************************************************************
* Some firm level regression variables
******************************************************************

* -- LHS variables

gen lwage = log(avgwage)
gen skillp = workers_nprod/(workers_prod+workers_nprod)
label variable lwage "Log average wage"
label variable skillp "Share of skilled workers"

gen lwork = log(workers)
gen lskill = log(workers*skillp)
gen lunskill = log(workers*(1-skillp))
label variable lwork "Log Workers"
label variable lskill "Log Skilled Workers"
label variable lunskill "Log Unskilled Workers"

* -- RHS variables (not related to country of destination)

gen lsales = log(sales)
gen expsales = Exports/sales
label variable lsales "Log Sales"
label variable expsales "Exports / Sales"

* -- Export dummies

gen exporter=(exports>0)
label variable exporter "Exporter indicator"

egen exporter2=sum(exports), by(firmid)
replace exporter2=1 if exporter2>0
label variable exporter2 "Firm exported sometime during sample period"

******************************************************************
* Variables related to countries of destination
******************************************************************

sort isocode
merge isocode using ../datafiles/countryclass
table _merge
drop if _merge==2
drop _merge

sort firmid year
save data1, replace

* -- High income exports

gen income_high1=1 if (WBincomeclass==3 | WBincomeclass==4 | WBincomeclass==2)
replace income_high1=0 if income_high1==.
label variable income_high1 "Country of destination is high income 1"

gen exports_high = exports/Exports*income_high1
egen Exports_high1=sum(exports_high), by(firmid year)
replace Exports_high1=0 if Exports==0
drop exports_high
label variable Exports_high1 "Share of exports to high income countries 1"

* --  High income exports, second definition (Table 8)

gen income_high2=1 if (WBincomeclass==3 | WBincomeclass==4)
replace income_high2=0 if income_high2==.
label variable income_high2 "Country of destination is high income 2"

gen exports_high = exports/Exports*income_high2
egen Exports_high2=sum(exports_high), by(firmid year)
replace Exports_high2=0 if Exports==0
drop exports_high
label variable Exports_high2 "Share of exports to high income countries 2"

* -- High income sales (Table 9)

gen Sales_high1=Exports_high1*expsales
gen Sales_high2=Exports_high2*expsales

sort firmid isocode year
save data1, replace

* -- High income exports with linguistic ties (Spain, Italy, Portugal) (Table 12)

gen income_high3=1 if (WBincomeclass==3 | WBincomeclass==4) & (isocode=="ESP" | isocode=="ITA" | isocode=="PRT")
replace income_high3=0 if income_high3==.

gen exports_high = exports/Exports*income_high3
egen Exports_high3=sum(exports_high), by(firmid year)
replace Exports_high3=0 if Exports==0
drop exports_high income_high3
label variable Exports_high3 "Share of exports to ESP, ITA, PRT"

bys firmid year: drop if _n>1
gen a=Exports_high3/Exports_high2
replace a=0 if Exports_high2==0 | a==.
gen b=(a>=0.75)
 egen c=sum(b), by(firmid)
 gen spanish=(c>0)
 drop a b c
label variable spanish "ESP+ITA+PRT/High Income exp >= 0.75"

bys firmid: drop if _n>1
keep firmid spanish*
sort firmid
save newtemp, replace
use data1, clear
merge firmid using newtemp
drop _merge

save data1, replace

* -- Language proximity (Table 12)

gen lang=0
replace lang=1 if isocode=="BOL"| isocode=="CHL"| isocode=="COL"| isocode=="CRI"| isocode=="CUB"| isocode=="DOM"| isocode=="ECU"| isocode=="ESP"| isocode=="MEX"| isocode=="NIC"| isocode=="PAN"| isocode=="PER"| isocode=="PRY"| isocode=="URY"| isocode=="VEN"
replace lang=2 if isocode=="BRA" | isocode=="ITA" | isocode=="PRT"
gen lang2=(lang==1 | lang==2)

gen exports_lang2=exports*lang2/Exports
egen Exports_lang2=sum(exports_lang2), by(firmid year)
replace Exports_lang2=0 if Exports==0
drop exports_lang2 lang2 lang

sort firmid isocode year
save data1, replace

* -- Cultural proximity (Table 12)

gen southam=0
replace southam=1 if isocode=="BRA" | isocode=="URY" | isocode=="CHL" | isocode=="PRY" | isocode=="BOL"
replace southam=2 if isocode=="GUY" | isocode=="VEN" | isocode=="COL" | isocode=="PER" | isocode=="ECU" | isocode=="SUR"
gen southam2=(southam==1 | southam==2)
gen exports_southam2=exports*southam2/Exports
egen Exports_southam2=sum(exports_southam2), by(firmid year)
replace Exports_southam2=0 if Exports==0
drop exports_southam2 southam2 southam
sort firmid isocode year
save data1, replace

* -- Increased exports to high income (Table 9)

gen exphigh=Exports_high1*Exports
bys firmid year: drop if _n>1
keep firmid year exphigh
reshape wide exphigh, i(firmid) j(year)
gen delta=exphigh2000-exphigh1998
replace delta=0 if delta==.
gen increased=(delta>0)
replace increased=2 if (exphigh1998==0 & exphigh1999==0 & exphigh2000==0)
keep firmid increased
sort firmid
save newtemp, replace
use data1, clear
merge firmid using newtemp
drop _merge
save data1, replace

* -- Increased exports to high income, second definition (Appendix)

gen exphigh=Exports_high2*Exports
bys firmid year: drop if _n>1
keep firmid year exphigh
reshape wide exphigh, i(firmid) j(year)
gen delta=exphigh2000-exphigh1998
replace delta=0 if delta==.
gen increased2=(delta>0)
replace increased2=2 if (exphigh1998==0 & exphigh1999==0 & exphigh2000==0)
keep firmid increased2
sort firmid
save newtemp, replace
use data1, clear
sort firmid
merge firmid using newtemp
drop _merge

compress
sort firmid year
save data1, replace
save datalong, replace

*******************************************************
* Construct instruments related to exports to Brazil  
*******************************************************

use data1, clear

* -- Share to Brazil in 1998

gen bb1=(isocode=="BRA" & year==1998)
gen bb2=bb1*exports/Exports
egen bb3=max(bb2), by(firmid)
gen sharebra1=bb3
replace sharebra1=0 if sharebra1==.
drop bb1 bb2 bb3
label variable sharebra1 "Share of Brazil in exports, 1998"

gen bb1=(isocode=="BRA" & year==1998)
gen bb2=bb1*exports/sales
egen bb3=max(bb2), by(firmid)
gen sharebra2=bb3
replace sharebra2=0 if sharebra2==.
drop bb1 bb2 bb3
label variable sharebra2 "Share of Brazil in sales, 1998"

* Non-parametric instrument (year dummies)

gen sharebrazil1_99=sharebra1
gen sharebrazil1_00=sharebra1
replace sharebrazil1_99 = 0 if year==2000 | year==1998
replace sharebrazil1_00 = 0 if year==1999 | year==1998
label variable sharebrazil1_99 "Share BRA exports * 1999"
label variable sharebrazil1_00 "Share BRA exports * 2000"

gen sharebrazil2_99=sharebra2
gen sharebrazil2_00=sharebra2
replace sharebrazil2_99 = 0 if year==2000 | year==1998
replace sharebrazil2_00 = 0 if year==1999 | year==1998
label variable sharebrazil2_99 "Share BRA sales * 1999"
label variable sharebrazil2_00 "Share BRA sales * 2000"

* -- Exchange rate instrument (montly average, data from IMF)

gen sharebrazil3_1=sharebra1
replace sharebrazil3_1=sharebrazil3_1*1.331458 if year==1998
replace sharebrazil3_1=sharebrazil3_1*1.959593 if year==1999
replace sharebrazil3_1=sharebrazil3_1*1.83012 if year==2000
label variable sharebrazil3_1 "Share BRA exports * erate"

gen sharebrazil3_2=sharebra2
replace sharebrazil3_2=sharebrazil3_2*1.331458 if year==1998
replace sharebrazil3_2=sharebrazil3_2*1.959593 if year==1999
replace sharebrazil3_2=sharebrazil3_2*1.83012 if year==2000
label variable sharebrazil3_2 "Share BRA sales * erate"

compress
save data1, replace

**********************************************
* Instruments related to average exchange rate of all trade partners
**********************************************

* -- Prepare erate and deflators

use ../datafiles/pwt
keep isocode year erate deflator
save temppwt, replace

* -- Save separate information for Argentina

keep if isocode=="ARG"
keep year deflator
rename deflator arg_def
label drop _all
sort year
save temparg, replace


* -- Merge and create real erate

use temppwt, clear
sort year
merge year using temparg
drop _merge
gen r2erate=deflator/(erate*arg_def)
drop erate
gen erate=r2erate
label variable erate "Real Exchange rate"
drop r2erate arg_def deflator
drop if erate==.
sort isocode year
reshape wide erate, i(isocode) j(year)
sort isocode
save temperate, replace

capture erase temppwt.dta
capture erase temparg.dta

* -- Merge with survey

use data1, clear
keep firmid year exports isocode sales
keep if year==1998
keep if exports~=0
keep if exports~=.
drop year

sort isocode
merge isocode using temperate

drop if _merge==2
drop if _merge==1
drop _merge

egen EE=sum(exports), by(firmid)
gen shexp98=exports/EE

gen avgerate1998=shexp98*erate1998*EE/sales
gen avgerate1999=shexp98*erate1999*EE/sales
gen avgerate2000=shexp98*erate2000*EE/sales

drop exports EE sales
collapse (sum) avgerate1998 avgerate1999 avgerate2000, by(firmid)
reshape long avgerate, i(firmid) j(year)

label variable avgerate "Sum_i shexports_i_98 * erate_i_t"
sort firmid year
save temp, replace

use data1, clear
sort firmid year
merge firmid year using temp
drop if _merge==2
replace avgerate=0 if _merge==1
drop _merge

sort firmid year isocode
save data1, replace
capture erate temperate.dta

***************************************************************************
* Initial Conditions
***************************************************************************

* -- Drop destination information

bys firmid year: drop if _n>1
drop isocode exports region WBincomeclass income_high1 income_high2

* -- Year dummies

gen year98=(year==1998)
gen year99=(year==1999)
gen year00=(year==2000)

* -- Log sales * year effects; Log sales * exchange rate

gen t = lsales
replace t=0 if year~=1998
egen trend=sum(t), by(firmid)
gen trend1=trend
replace trend1=trend1*1.331458 if year==1998
replace trend1=trend1*1.959593 if year==1999
replace trend1=trend1*1.83012 if year==2000
replace trend=0 if year==1998
gen trend2a=trend
gen trend2b=trend
replace trend2a=0 if year==2000
replace trend2b=0 if year==1999
drop trend t

* -- Exporter indicator * year effects; Exporter indicator * exchange rate

gen t = exporter
replace t=0 if year~=1998
egen trend=sum(t), by(firmid)
gen trend3=trend
replace trend3=trend3*1.331458 if year==1998
replace trend3=trend3*1.959593 if year==1999
replace trend3=trend3*1.83012 if year==2000
replace trend=0 if year==1998
gen trend4a=trend
gen trend4b=trend
replace trend4a=0 if year==2000
replace trend4b=0 if year==1999
drop trend t

compress
save data1, replace

************************************************
* Long and Short Quality Ladders (appendix)
************************************************

use ../datafiles/ladder_hs6, clear

* -- Concordance with ISIC 3

g hs = int(hs6/10000)
g hs4 = int(hs6/100)
g isic3=.

qui{
replace isic3=151 if hs  == 02
replace isic3=151 if hs  == 03
replace isic3=151 if hs  == 15
replace isic3=151 if hs  == 16
replace isic3=151 if hs  == 20
replace isic3=152 if hs  == 04
replace isic3=153 if hs  == 11
replace isic3=154 if hs  == 17
replace isic3=154 if hs  == 18
replace isic3=154 if hs  == 19
replace isic3=155 if hs  == 22
replace isic3=171 if hs  == 50
replace isic3=171 if hs  == 51
replace isic3=171 if hs  == 52
replace isic3=171 if hs  == 53
replace isic3=171 if hs  == 54
replace isic3=172 if hs  == 56
replace isic3=172 if hs  == 57
replace isic3=173 if hs  == 60
replace isic3=181 if hs  == 61
replace isic3=181 if hs  == 62
replace isic3=191 if hs  == 41
replace isic3=191 if hs  == 42
replace isic3=192 if hs  == 64
replace isic3=202 if hs  == 45
replace isic3=202 if hs  == 46
replace isic3=210 if hs  == 47
replace isic3=210 if hs  == 48
replace isic3=221 if hs  == 49
replace isic3=221 if hs4 == 2710 
replace isic3=221 if hs4 == 2711 
replace isic3=221 if hs4 == 2712 
replace isic3=221 if hs4 == 2713 
replace isic3=233 if hs4 == 2844
replace isic3=233 if hs4 == 2845
replace isic3=233 if hs4 == 8401
replace isic3=241 if hs  == 28
replace isic3=241 if hs  == 29
replace isic3=241 if hs  == 31
replace isic3=242 if hs  == 30
replace isic3=242 if hs  == 32
replace isic3=242 if hs  == 33
replace isic3=242 if hs  == 34
replace isic3=243 if hs  == 55
replace isic3=251 if hs  == 40
replace isic3=252 if hs  == 39
replace isic3=261 if hs  == 70
replace isic3=269 if hs  == 68
replace isic3=269 if hs  == 69
replace isic3=271 if hs  == 72
replace isic3=272 if hs  == 74
replace isic3=272 if hs  == 75
replace isic3=272 if hs  == 76
replace isic3=272 if hs  == 78
replace isic3=272 if hs  == 79
replace isic3=272 if hs  == 80
replace isic3=273 if hs4 == 7303 
replace isic3=273 if hs4 == 7325 
replace isic3=281 if hs4 == 7308 
replace isic3=281 if hs4 == 7309 
replace isic3=281 if hs4 == 7310 
replace isic3=281 if hs4 == 7311 
replace isic3=281 if hs4 == 7610 
replace isic3=281 if hs4 == 7611 
replace isic3=281 if hs4 == 7612 
replace isic3=281 if hs4 == 7613 
replace isic3=281 if hs4 == 8402 
replace isic3=289 if hs4 == 7205 
replace isic3=289 if hs4 == 7406 
replace isic3=289 if hs4 == 7504 
replace isic3=289 if hs4 == 7603 
replace isic3=289 if hs  == 82
replace isic3=291 if hs4 == 8406 
replace isic3=291 if hs6 == 840721 
replace isic3=291 if hs6 == 840729 
replace isic3=291 if hs6 == 840731 
replace isic3=291 if hs6 == 840732 
replace isic3=291 if hs6 == 840733 
replace isic3=291 if hs6 == 840734 
replace isic3=291 if hs6 == 840790 
replace isic3=291 if hs4 == 8408 
replace isic3=291 if hs4 == 8409 
replace isic3=291 if hs4 == 8410 
replace isic3=291 if hs4 == 8411 
replace isic3=291 if hs4 == 8412 
replace isic3=291 if hs4 == 8413 
replace isic3=291 if hs4 == 8414 
replace isic3=291 if hs4 == 8415 
replace isic3=291 if hs4 == 8416 
replace isic3=291 if hs4 == 8419 
replace isic3=291 if hs4 == 8423 
replace isic3=291 if hs4 == 8425 
replace isic3=291 if hs4 == 8426 
replace isic3=291 if hs4 == 8427
replace isic3=291 if hs4 == 8428 
replace isic3=291 if hs4 == 8421 
replace isic3=291 if hs4 == 8424 
replace isic3=291 if hs4 == 8420 
replace isic3=292 if hs6 == 841931 
replace isic3=292 if hs6 == 841932 
replace isic3=292 if hs6 == 842481 
replace isic3=292 if hs4 == 8422 
replace isic3=292 if hs4 == 8429 
replace isic3=292 if hs4 == 8430
replace isic3=292 if hs4 >= 8432 & hs4 <= 8485
replace isic3=292 if hs  == 93
replace isic3=293 if hs6 == 842211 
replace isic3=293 if hs6 == 842310 
replace isic3=293 if hs4 == 8450
replace isic3=293 if hs6 == 845210
replace isic3=293 if hs6 == 841821 
replace isic3=293 if hs6 == 841822 
replace isic3=293 if hs6 == 841829 
replace isic3=293 if hs6 == 842310
replace isic3=293 if hs4 == 8510
replace isic3=300 if hs4 == 8469
replace isic3=300 if hs4 == 8470
replace isic3=300 if hs4 == 8471
replace isic3=300 if hs4 == 8472
replace isic3=300 if hs4 == 8473
replace isic3=311 if hs4 == 8501 
replace isic3=311 if hs4 == 8502
replace isic3=311 if hs4 == 8503
replace isic3=311 if hs4 == 8504
replace isic3=312 if hs4 == 8535
replace isic3=312 if hs4 == 8536  
replace isic3=312 if hs4 == 8537
replace isic3=312 if hs4 == 8538
replace isic3=313 if hs4 == 8544
replace isic3=314 if hs4 == 8506
replace isic3=314 if hs4 == 8507
replace isic3=315 if hs4 == 9405
replace isic3=315 if hs4 == 8513  
replace isic3=315 if hs4 == 8539  
replace isic3=319 if hs4 == 8505
replace isic3=319 if hs4 == 8511
replace isic3=319 if hs4 == 8512  
replace isic3=319 if hs4 == 8530  
replace isic3=319 if hs4 == 8546  
replace isic3=319 if hs4 == 8547
replace isic3=319 if hs4 == 8548
replace isic3=321 if hs4 == 8540
replace isic3=321 if hs4 == 8541
replace isic3=321 if hs4 == 8542
replace isic3=321 if hs4 == 8532  
replace isic3=321 if hs4 == 8533  
replace isic3=321 if hs4 == 8534
replace isic3=322 if hs4 == 8517  
replace isic3=322 if hs4 == 8525  
replace isic3=323 if hs4 == 8527  
replace isic3=323 if hs4 == 8528  
replace isic3=323 if hs4 == 8529  
replace isic3=323 if hs4 == 8521  
replace isic3=331 if hs4 >= 9018 & hs4 <= 9030
replace isic3=332 if hs4 >= 9001 & hs4 <= 9013
replace isic3=341 if hs4 >= 8701 & hs4 <= 8706
replace isic3=341 if hs4 == 8709  
replace isic3=341 if hs4 == 8711  
replace isic3=341 if hs6 == 840820 
replace isic3=342 if hs4 == 8707  
replace isic3=342 if hs4 == 8716  
replace isic3=343 if hs4 == 8708 
replace isic3=351 if hs  == 89  
replace isic3=352 if hs  == 86
replace isic3=361 if hs  == 94
replace isic3=369 if hs4 >= 7113 & hs4 <= 7117
replace isic3=369 if hs  == 92
replace isic3=369 if hs  == 95
replace isic3=369 if hs  == 96
}
drop if isic3==.
drop hs*

collapse (mean) ladder, by(isic)
sum ladder, detail
gen lladder=(ladder>r(mean))
keep isic3 lladder
sort isic
rename lladder ladder
save ladder, replace

**********************************************
* High Variance of Unit values (Table 11)
**********************************************

use ../datafiles/comtradehs6, clear
gen uv=value/netweight
drop value netweightkg

* -- Concordance with ISIC 3

drop if hs1992 == "9999AA"
gen hs6=real(hs1992)
g hs  = int(hs6/10000)
g hs4 = int(hs6/100)
g isic3=.

qui{
replace isic3=151 if hs  == 02
replace isic3=151 if hs  == 03
replace isic3=151 if hs  == 15
replace isic3=151 if hs  == 16
replace isic3=151 if hs  == 20
replace isic3=152 if hs  == 04
replace isic3=153 if hs  == 11
replace isic3=154 if hs  == 17
replace isic3=154 if hs  == 18
replace isic3=154 if hs  == 19
replace isic3=155 if hs  == 22
replace isic3=171 if hs  == 50
replace isic3=171 if hs  == 51
replace isic3=171 if hs  == 52
replace isic3=171 if hs  == 53
replace isic3=171 if hs  == 54
replace isic3=172 if hs  == 56
replace isic3=172 if hs  == 57
replace isic3=173 if hs  == 60
replace isic3=181 if hs  == 61
replace isic3=181 if hs  == 62
replace isic3=191 if hs  == 41
replace isic3=191 if hs  == 42
replace isic3=192 if hs  == 64
replace isic3=202 if hs  == 45
replace isic3=202 if hs  == 46
replace isic3=210 if hs  == 47
replace isic3=210 if hs  == 48
replace isic3=221 if hs  == 49
replace isic3=221 if hs4 == 2710 
replace isic3=221 if hs4 == 2711 
replace isic3=221 if hs4 == 2712 
replace isic3=221 if hs4 == 2713 
replace isic3=233 if hs4 == 2844
replace isic3=233 if hs4 == 2845
replace isic3=233 if hs4 == 8401
replace isic3=241 if hs  == 28
replace isic3=241 if hs  == 29
replace isic3=241 if hs  == 31
replace isic3=242 if hs  == 30
replace isic3=242 if hs  == 32
replace isic3=242 if hs  == 33
replace isic3=242 if hs  == 34
replace isic3=243 if hs  == 55
replace isic3=251 if hs  == 40
replace isic3=252 if hs  == 39
replace isic3=261 if hs  == 70
replace isic3=269 if hs  == 68
replace isic3=269 if hs  == 69
replace isic3=271 if hs  == 72
replace isic3=272 if hs  == 74
replace isic3=272 if hs  == 75
replace isic3=272 if hs  == 76
replace isic3=272 if hs  == 78
replace isic3=272 if hs  == 79
replace isic3=272 if hs  == 80
replace isic3=273 if hs4 == 7303 
replace isic3=273 if hs4 == 7325 
replace isic3=281 if hs4 == 7308 
replace isic3=281 if hs4 == 7309 
replace isic3=281 if hs4 == 7310 
replace isic3=281 if hs4 == 7311 
replace isic3=281 if hs4 == 7610 
replace isic3=281 if hs4 == 7611 
replace isic3=281 if hs4 == 7612 
replace isic3=281 if hs4 == 7613 
replace isic3=281 if hs4 == 8402 
replace isic3=289 if hs4 == 7205 
replace isic3=289 if hs4 == 7406 
replace isic3=289 if hs4 == 7504 
replace isic3=289 if hs4 == 7603 
replace isic3=289 if hs  == 82
replace isic3=291 if hs4 == 8406 
replace isic3=291 if hs6 == 840721 
replace isic3=291 if hs6 == 840729 
replace isic3=291 if hs6 == 840731 
replace isic3=291 if hs6 == 840732 
replace isic3=291 if hs6 == 840733 
replace isic3=291 if hs6 == 840734 
replace isic3=291 if hs6 == 840790 
replace isic3=291 if hs4 == 8408 
replace isic3=291 if hs4 == 8409 
replace isic3=291 if hs4 == 8410 
replace isic3=291 if hs4 == 8411 
replace isic3=291 if hs4 == 8412 
replace isic3=291 if hs4 == 8413 
replace isic3=291 if hs4 == 8414 
replace isic3=291 if hs4 == 8415 
replace isic3=291 if hs4 == 8416 
replace isic3=291 if hs4 == 8419 
replace isic3=291 if hs4 == 8423 
replace isic3=291 if hs4 == 8425 
replace isic3=291 if hs4 == 8426 
replace isic3=291 if hs4 == 8427
replace isic3=291 if hs4 == 8428 
replace isic3=291 if hs4 == 8421 
replace isic3=291 if hs4 == 8424 
replace isic3=291 if hs4 == 8420 
replace isic3=292 if hs6 == 841931 
replace isic3=292 if hs6 == 841932 
replace isic3=292 if hs6 == 842481 
replace isic3=292 if hs4 == 8422 
replace isic3=292 if hs4 == 8429 
replace isic3=292 if hs4 == 8430
replace isic3=292 if hs4 >= 8432 & hs4 <= 8485
replace isic3=292 if hs  == 93
replace isic3=293 if hs6 == 842211 
replace isic3=293 if hs6 == 842310 
replace isic3=293 if hs4 == 8450
replace isic3=293 if hs6 == 845210
replace isic3=293 if hs6 == 841821 
replace isic3=293 if hs6 == 841822 
replace isic3=293 if hs6 == 841829 
replace isic3=293 if hs6 == 842310
replace isic3=293 if hs4 == 8510
replace isic3=300 if hs4 == 8469
replace isic3=300 if hs4 == 8470
replace isic3=300 if hs4 == 8471
replace isic3=300 if hs4 == 8472
replace isic3=300 if hs4 == 8473
replace isic3=311 if hs4 == 8501 
replace isic3=311 if hs4 == 8502
replace isic3=311 if hs4 == 8503
replace isic3=311 if hs4 == 8504
replace isic3=312 if hs4 == 8535
replace isic3=312 if hs4 == 8536  
replace isic3=312 if hs4 == 8537
replace isic3=312 if hs4 == 8538
replace isic3=313 if hs4 == 8544
replace isic3=314 if hs4 == 8506
replace isic3=314 if hs4 == 8507
replace isic3=315 if hs4 == 9405
replace isic3=315 if hs4 == 8513  
replace isic3=315 if hs4 == 8539  
replace isic3=319 if hs4 == 8505
replace isic3=319 if hs4 == 8511
replace isic3=319 if hs4 == 8512  
replace isic3=319 if hs4 == 8530  
replace isic3=319 if hs4 == 8546  
replace isic3=319 if hs4 == 8547
replace isic3=319 if hs4 == 8548
replace isic3=321 if hs4 == 8540
replace isic3=321 if hs4 == 8541
replace isic3=321 if hs4 == 8542
replace isic3=321 if hs4 == 8532  
replace isic3=321 if hs4 == 8533  
replace isic3=321 if hs4 == 8534
replace isic3=322 if hs4 == 8517  
replace isic3=322 if hs4 == 8525  
replace isic3=323 if hs4 == 8527  
replace isic3=323 if hs4 == 8528  
replace isic3=323 if hs4 == 8529  
replace isic3=323 if hs4 == 8521  
replace isic3=331 if hs4 >= 9018 & hs4 <= 9030
replace isic3=332 if hs4 >= 9001 & hs4 <= 9013
replace isic3=341 if hs4 >= 8701 & hs4 <= 8706
replace isic3=341 if hs4 == 8709  
replace isic3=341 if hs4 == 8711  
replace isic3=341 if hs6 == 840820 
replace isic3=342 if hs4 == 8707  
replace isic3=342 if hs4 == 8716  
replace isic3=343 if hs4 == 8708 
replace isic3=351 if hs  == 89  
replace isic3=352 if hs  == 86
replace isic3=361 if hs  == 94
replace isic3=369 if hs4 >= 7113 & hs4 <= 7117
replace isic3=369 if hs  == 92
replace isic3=369 if hs  == 95
replace isic3=369 if hs  == 96
}

drop if isic3==.
drop hs*

gen uvmean=uv
gen uvsd=uv
collapse (mean) uvmean (sd) uvsd, by(isic3)
gen length1=uvsd/uvmean
sum length1, detail
gen uvvar=(length1>r(p75))
keep isic3 uvvar
sort isic3

* -- Merge with ladder measures
merge isic3 using ladder
drop _merge
capture erase ladder.dta
sort isic3
save temp, replace

* -- Merge with plant information
use data1, clear
gen isic3=isicmain
sort isic3
merge isic3 using temp
drop _merge
drop isic3
sort firmid year
save data1, replace

************************************************
* Transport Costs (Table 11)
************************************************

use ../datafiles/usitc_tc, clear

* -- Concordance with ISIC 3

ren hscode hs4
g hs = int(hs4/100)
g isic3=.

qui{
replace isic3=151 if hs  == 02
replace isic3=151 if hs  == 03
replace isic3=151 if hs  == 15
replace isic3=151 if hs  == 16
replace isic3=151 if hs  == 20
replace isic3=152 if hs  == 04
replace isic3=153 if hs  == 11
replace isic3=154 if hs  == 17
replace isic3=154 if hs  == 18
replace isic3=154 if hs  == 19
replace isic3=155 if hs  == 22
replace isic3=171 if hs  == 50
replace isic3=171 if hs  == 51
replace isic3=171 if hs  == 52
replace isic3=171 if hs  == 53
replace isic3=171 if hs  == 54
replace isic3=172 if hs  == 56
replace isic3=172 if hs  == 57
replace isic3=173 if hs  == 60
replace isic3=181 if hs  == 61
replace isic3=181 if hs  == 62
replace isic3=191 if hs  == 41
replace isic3=191 if hs  == 42
replace isic3=192 if hs  == 64
replace isic3=202 if hs  == 45
replace isic3=202 if hs  == 46
replace isic3=210 if hs  == 47
replace isic3=210 if hs  == 48
replace isic3=221 if hs  == 49
replace isic3=221 if hs4 == 2710 
replace isic3=221 if hs4 == 2711 
replace isic3=221 if hs4 == 2712 
replace isic3=221 if hs4 == 2713 
replace isic3=233 if hs4 == 2844
replace isic3=233 if hs4 == 2845
replace isic3=233 if hs4 == 8401
replace isic3=241 if hs  == 28
replace isic3=241 if hs  == 29
replace isic3=241 if hs  == 31
replace isic3=242 if hs  == 30
replace isic3=242 if hs  == 32
replace isic3=242 if hs  == 33
replace isic3=242 if hs  == 34
replace isic3=243 if hs  == 55
replace isic3=251 if hs  == 40
replace isic3=252 if hs  == 39
replace isic3=261 if hs  == 70
replace isic3=269 if hs  == 68
replace isic3=269 if hs  == 69
replace isic3=271 if hs  == 72
replace isic3=272 if hs  == 74
replace isic3=272 if hs  == 75
replace isic3=272 if hs  == 76
replace isic3=272 if hs  == 78
replace isic3=272 if hs  == 79
replace isic3=272 if hs  == 80
replace isic3=273 if hs4 == 7303 
replace isic3=273 if hs4 == 7325 
replace isic3=281 if hs4 == 7308 
replace isic3=281 if hs4 == 7309 
replace isic3=281 if hs4 == 7310 
replace isic3=281 if hs4 == 7311 
replace isic3=281 if hs4 == 7610 
replace isic3=281 if hs4 == 7611 
replace isic3=281 if hs4 == 7612 
replace isic3=281 if hs4 == 7613 
replace isic3=281 if hs4 == 8402 
replace isic3=289 if hs4 == 7205 
replace isic3=289 if hs4 == 7406 
replace isic3=289 if hs4 == 7504 
replace isic3=289 if hs4 == 7603 
replace isic3=289 if hs  == 82
replace isic3=291 if hs4 == 8406 
replace isic3=291 if hs4 == 8407 
replace isic3=291 if hs4 == 8408 
replace isic3=291 if hs4 == 8409 
replace isic3=291 if hs4 == 8410 
replace isic3=291 if hs4 == 8411 
replace isic3=291 if hs4 == 8412 
replace isic3=291 if hs4 == 8413 
replace isic3=291 if hs4 == 8414 
replace isic3=291 if hs4 == 8415 
replace isic3=291 if hs4 == 8416 
replace isic3=291 if hs4 == 8419 
replace isic3=291 if hs4 == 8423 
replace isic3=291 if hs4 == 8425 
replace isic3=291 if hs4 == 8426 
replace isic3=291 if hs4 == 8427
replace isic3=291 if hs4 == 8428 
replace isic3=291 if hs4 == 8421 
replace isic3=291 if hs4 == 8424 
replace isic3=291 if hs4 == 8420 
replace isic3=292 if hs4 == 8422 
replace isic3=292 if hs4 == 8429 
replace isic3=292 if hs4 == 8430
replace isic3=292 if hs4 >= 8432 & hs4 <= 8485
replace isic3=292 if hs  == 93
replace isic3=293 if hs4 == 8450
replace isic3=293 if hs4 == 8510
replace isic3=300 if hs4 == 8469
replace isic3=300 if hs4 == 8470
replace isic3=300 if hs4 == 8471
replace isic3=300 if hs4 == 8472
replace isic3=300 if hs4 == 8473
replace isic3=311 if hs4 == 8501 
replace isic3=311 if hs4 == 8502
replace isic3=311 if hs4 == 8503
replace isic3=311 if hs4 == 8504
replace isic3=312 if hs4 == 8535
replace isic3=312 if hs4 == 8536  
replace isic3=312 if hs4 == 8537
replace isic3=312 if hs4 == 8538
replace isic3=313 if hs4 == 8544
replace isic3=314 if hs4 == 8506
replace isic3=314 if hs4 == 8507
replace isic3=315 if hs4 == 9405
replace isic3=315 if hs4 == 8513  
replace isic3=315 if hs4 == 8539  
replace isic3=319 if hs4 == 8505
replace isic3=319 if hs4 == 8511
replace isic3=319 if hs4 == 8512  
replace isic3=319 if hs4 == 8530  
replace isic3=319 if hs4 == 8546  
replace isic3=319 if hs4 == 8547
replace isic3=319 if hs4 == 8548
replace isic3=321 if hs4 == 8540
replace isic3=321 if hs4 == 8541
replace isic3=321 if hs4 == 8542
replace isic3=321 if hs4 == 8532  
replace isic3=321 if hs4 == 8533  
replace isic3=321 if hs4 == 8534
replace isic3=322 if hs4 == 8517  
replace isic3=322 if hs4 == 8525  
replace isic3=323 if hs4 == 8527  
replace isic3=323 if hs4 == 8528  
replace isic3=323 if hs4 == 8529  
replace isic3=323 if hs4 == 8521  
replace isic3=331 if hs4 >= 9018 & hs4 <= 9030
replace isic3=332 if hs4 >= 9001 & hs4 <= 9013
replace isic3=341 if hs4 >= 8701 & hs4 <= 8706
replace isic3=341 if hs4 == 8709  
replace isic3=341 if hs4 == 8711  
replace isic3=342 if hs4 == 8707  
replace isic3=342 if hs4 == 8716  
replace isic3=343 if hs4 == 8708 
replace isic3=351 if hs  == 89  
replace isic3=352 if hs  == 86
replace isic3=361 if hs  == 94
replace isic3=369 if hs4 >= 7113 & hs4 <= 7117
replace isic3=369 if hs  == 92
replace isic3=369 if hs  == 95
replace isic3=369 if hs  == 96
}

drop if isic3==.
drop hs*

bys isic3: egen timp=sum(imports)
bys isic3: egen timp_c=sum(import_charges)
gen tc=timp_c/timp

bys isic3: drop if _n>1
sum tc, detail
gen tc_p75=(tc>r(p75))
keep isic3 tc_p75
sort isic3
save tc, replace

* -- Merge with plant information
use data1, clear
gen isic3=isicmain
sort isic3
merge isic3 using tc
erase tc.dta
drop _merge
drop isic3

**********************
* Save
**********************

compress
sort firmid year
save data, replace

erase data1.dta
erase newtemp.dta
erase temp.dta
erase temperate.dta
