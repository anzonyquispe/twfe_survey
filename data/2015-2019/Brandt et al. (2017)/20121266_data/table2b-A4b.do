clear
set matsize 5000
local temp: tempfile

local datadir1 "C:\Dropbox\Documents\1. Research\6. Data work\China"

clear
set more off
local temphscic:tempfile
local beccic:   tempfile

* Data prep *
use "`datadir1'\data_industry\concordance\HS-CIC.dta",clear
replace cic_adj=2010 if cic_adj==2012 | cic_adj==2011
keep cic_adj hs02_6
rename hs02_6 hs02
duplicates drop
tostring hs02,replace
save `temphscic'

use "..\Luhang-trade\hs02bec.dta",clear
tostring hs02,replace
merge 1:m hs02 using `temphscic'
drop if _merge==1
tab _merge
drop _merge
drop if cic_adj==.
destring hs02,replace
************************************************************************************
gen nes = bec=="7"   | bec=="n/a"
gen mat = bec=="111" | bec=="112" | bec=="21"  | bec=="31"  
gen imt = bec=="121"              | bec=="22"  | bec=="322" | bec=="42"  | bec=="53"
gen cap = bec=="41"  | bec=="51"  | bec=="521" | bec=="522"
gen cons= bec=="122" | bec=="61"  | bec=="62"  | bec=="63"  
************************************************************************************
local beclist = "mat imt cap cons"
collapse (count) n02=hs02 (sum) `beclist' nes, by(cic_adj)
sort cic_adj
for z in any `beclist' nes: gen pbec_z=z/n02*100
rename n02 n_6dhs02_bec
keep cic_adj pbec_*
format pbec_* %3.0f
for z in varlist pbec*: gen Dz=z>=50 & z~=.
renpfix Dpbec D50
egen temp=rowtotal(D50_*)
keep if temp~=0 & D50_nes~=1
drop D50_nes
drop if cic_adj==.
sort cic_adj
save `beccic'

**tariff and deflator
use  year cic_adj tariff* deflator* using "`datadir1'\industry-level-1995-2007", clear
sort cic_adj year

* deflator 2007
for any input output:                        replace deflator_X_4d=deflator_X_1d                     if year==1995
for any input output: bysort cic_adj (year): replace deflator_X_4d=deflator_X_4d[_n-1]*deflator_X_2d/deflator_X_2d[_n-1] if year==2007   
for any input output: bysort cic_adj (year): replace deflator_X_1d=deflator_X_1d[_n-1]*deflator_X_2d/deflator_X_2d[_n-1] if year==2007   

drop if year<1995|year==1996|year==1997
sort cic_adj year
save `temp', replace


* new deflators 
use "alternative output deflators, 101216.dta"
merge cic_adj using "alternative io input deflators, 101216.dta"
reshape long input_d output_d, i(cic_adj) j(year)
rename  input_d deflator_input_new
rename output_d deflator_output_new
for var deflator*: egen MX=mean(X) if cic_adj==2010|cic_adj==2011|cic_adj==2012, by(year)
for var deflator*: replace X=MX if X==.
replace deflator_output=deflator_input if deflator_output==. & cic_adj==3352 /* 1 change */
replace deflator_output=deflator_input if deflator_output==0 & cic_adj==3352 /* 6 change */
drop if cic_adj==.
drop M* _merge
sort cic_adj year
save "alternative deflators long", replace
erge cic_adj year using `temp'
drop if _merge==1
drop _merge

for z in varlist deflator*: gen Lz=log(z)

keep Ldeflator* deflator* tariff* cic_adj year
merge m:1 cic_adj using `beccic'
tab _merge
drop _merge
sort year cic_adj
save `temp', replace

* get instrument *
use "..\instrument\tariffIV.dta", clear
keep  year cic_adj maxtariff_o maxtariff_i
sort  year cic_adj
merge year cic_adj using `temp'
replace maxtariff_o = tariff_output if year==1995
replace maxtariff_i = tariff_input  if year==1995
drop if _merge==1 
drop _merge

gen D50_all    =1
gen post_tariff    = tariff_output * (year>=2001)
gen post_maxtariff = maxtariff_o   * (year>=2001)

* OLS
for any all mat imt cap cons, pause: xtreg Ldeflator_output_4d tariff_o yy* if year>=1998 & year<=2007 & D50_X==1, i(cic_adj) fe    \ estimates store O11X
estimates table O11all O11mat O11imt O11cap O11cons, keep(tariff_output) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table O11all O11mat O11imt O11cap O11cons, keep(tariff_output) b(%5.3f) se(%5.3f)

* IV
for any all mat imt cap cons, pause: xtivreg Ldeflator_output_1d (tariff_o = maxtariff_o) yy* if year>=1998 & year<=2007 & D50_X==1, i(cic_adj) fe    \ estimates store C11X
for any all mat imt cap cons, pause: xtivreg Ldeflator_output_4d (tariff_o = maxtariff_o) yy* if year>=1998 & year<=2004 & D50_X==1, i(cic_adj) fe    \ estimates store C22X
for any all mat imt cap cons, pause: xtivreg Ldeflator_output_4d (tariff_o = maxtariff_o) yy* if year>=1998 & year<=2007 & D50_X==1, i(cic_adj) fe    \ estimates store C33X
for any all mat imt cap cons, pause: xtivreg Ldeflator_output_4d (tariff_o post_tariff = maxtariff_o post_maxtariff) yy* if year>=1998 & year<=2007 & D50_X==1, i(cic_adj) fe    \ estimates store C44X
for any all mat imt cap cons, pause: xtivreg Ldeflator_output_ne (tariff_o = maxtariff_o) yy* if year>=1998 & year<=2007 & D50_X==1, i(cic_adj) fe    \ estimates store C55X
for var Ldeflator_output_ne tariff_o maxtariff_o yy*: egen MX=mean(X), by(cic_adj)
for var Ldeflator_output_ne tariff_o maxtariff_o yy*:  gen DX=X-MX
for any all mat imt cap cons: ivreg DLdeflator_output_ne (Dtariff_o = Dmaxtariff_o) Dyy* if year>=1998 & year<=2007 & D50_X==1, cluster(cic_adj) \ estimates store CC55X

estimates table C11all C11mat C11imt C11cap C11cons, keep(tariff_output) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table C11all C11mat C11imt C11cap C11cons, keep(tariff_output) b(%5.3f) se(%5.3f)
estimates table C22all C22mat C22imt C22cap C22cons, keep(tariff_output) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table C22all C22mat C22imt C22cap C22cons, keep(tariff_output) b(%5.3f) se(%5.3f)
estimates table C33all C33mat C33imt C33cap C33cons, keep(tariff_output) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table C33all C33mat C33imt C33cap C33cons, keep(tariff_output) b(%5.3f) se(%5.3f)
estimates table C44all C44mat C44imt C44cap C44cons, keep(tariff_output post_tariff) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table C44all C44mat C44imt C44cap C44cons, keep(tariff_output post_tariff) b(%5.3f) se(%5.3f)
estimates table C55all C55mat C55imt C55cap C55cons, keep(tariff_output) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table C55all C55mat C55imt C55cap C55cons, keep(tariff_output) b(%5.3f) se(%5.3f)
estimates table CC55all CC55mat CC55imt CC55cap CC55cons, keep(Dtariff_output) b(%5.3f) star(.01 .05 .1) stats(N)
estimates table CC55all CC55mat CC55imt CC55cap CC55cons, keep(Dtariff_output) b(%5.3f) se(%5.3f)

