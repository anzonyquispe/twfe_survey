* TABLE 3
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011

clear
set more off

* Compute share of each destination
use ../datafiles/exports, clear
egen tot=sum(value), by(year)
gen share=value/tot
drop tot
sort isocode
save temp, replace

* Merge with country characteristics (region, income group)
use ../datafiles/countryclass.dta
sort isocode
merge isocode using temp
drop if _merge==1
drop _merge
order year isocode region WBincomeclass value share
sort year isocode
save comtradedata, replace

* Lines 1-6: Main destinations
gen destination1=isocode
replace destination1="EUR" if region==1
replace destination1="OTH" if destination1~="BRA" & destination1~="USA" & destination1~="EUR" &  destination1~="URY" &  destination1~="CHL"  &  destination1~="PRY"
collapse (sum) value share, by(year destination1)
drop if destination1=="OTH"
reshape wide value share, i(destination1) j(year)
gsort -value1998
save tempa, replace

* Line 7: Total
use comtradedata, clear
collapse (sum) value, by(year)
gen destination1="tot"
gen share=1
reshape wide value share, i(destination1) j(year) 
save tempb, replace

* Lines 8-9: High Income
use comtradedata, clear
gen income_high1=(WBincomeclass==3 | WBincomeclass==4 | WBincomeclass==2)
gen income_high2=(WBincomeclass==3 | WBincomeclass==4)
gen highv1=income_high1*value
gen highs1=income_high1*share
gen highv2=income_high2*value
gen highs2=income_high2*share
collapse (sum) highv1 highs1 highv2 highs2, by(year)
reshape long highv highs, i(year) j(highincome)
rename highv value
rename highs share
reshape wide value share, i(highincome) j(year)
gen destination1="HI1" if high==1
replace destination1="HI2" if high==2
drop high
save tempc, replace

* Outsheet table
use tempa, clear
append using tempb
append using tempc
order destination1
format sh* %9.2f
format value* %9.1f
outsheet using results/table03.csv, comma replace

erase tempa.dta
erase tempb.dta
erase tempc.dta
erase temp.dta
erase comtradedata.dta
