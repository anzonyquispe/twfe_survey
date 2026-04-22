* TABLE 4
* Brambilla, Lederman and Porto, "Exports, Export Destinations and Skills," American Economic Review
* October 2011


clear
set mem 50m
set more off

* Weighted average
use datalong, clear
egen tot=sum(exports), by(year)
egen totbra=sum(exports) if isocode=="BRA", by(year)
egen tothigh=sum(exports) if (WBincomeclass==3 | WBincomeclass==4 | WBincomeclass==2), by(year)
egen shbra=mean(totbra), by(year)
egen shhigh=mean(tothigh), by(year)
replace shbra=shbra/tot
replace shhigh=shhigh/tot
bys year: keep if _n==1
keep year shbra shhigh
drop if year==.
gen isicmain=1
reshape wide shbra shhigh, i(isicmain) j(year)
order isicmain shbra1998 shbra1999 shbra2000 shhigh1998 shhigh1999 shhigh2000
save temp, replace

* Average among exporters
use datalong, clear
keep if Exports>0 & Exports~=.
egen tot=sum(exports), by(year firmid)
egen totbra=sum(exports) if isocode=="BRA", by(year firmid)
egen tothigh=sum(exports) if (WBincomeclass==3 | WBincomeclass==4 | WBincomeclass==2), by(year firmid)
egen shbra=mean(totbra), by(year firmid)
egen shhigh=mean(tothigh), by(year firmid)
replace shbra=shbra/tot
replace shhigh=shhigh/tot
bys year firmid: keep if _n==1
replace shbra=0 if shbra==.
replace shhigh=0 if shhigh==.
keep year firmid shbra shhigh
drop if year==.
collapse (mean) shbra shhigh, by(year)
drop if year==.
gen isicmain=2
reshape wide shbra shhigh, i(isicmain) j(year)
order isicmain shbra1998 shbra1999 shbra2000 shhigh1998 shhigh1999 shhigh2000
append using temp
sort isicmain
save temp, replace

* Average among all firms
use datalong, clear
egen tot=sum(exports), by(year firmid)
egen totbra=sum(exports) if isocode=="BRA", by(year firmid)
egen tothigh=sum(exports) if (WBincomeclass==3 | WBincomeclass==4 | WBincomeclass==2), by(year firmid)
egen shbra=mean(totbra), by(year firmid)
egen shhigh=mean(tothigh), by(year firmid)
replace shbra=shbra/tot
replace shhigh=shhigh/tot
bys year firmid: keep if _n==1
replace shbra=0 if shbra==.
replace shhigh=0 if shhigh==.
keep year firmid shbra shhigh
drop if year==.
collapse (mean) shbra shhigh, by(year)
drop if year==.
gen isicmain=3
reshape wide shbra shhigh, i(isicmain) j(year)
order isicmain shbra1998 shbra1999 shbra2000 shhigh1998 shhigh1999 shhigh2000
append using temp
sort isicmain
save temp, replace

* Weighted average by industry
use datalong, clear
egen tot=sum(exports), by(year firmid isic2)
egen totbra=sum(exports) if isocode=="BRA", by(year firmid isic2)
egen tothigh=sum(exports) if (WBincomeclass==3 | WBincomeclass==4 | WBincomeclass==2), by(year firmid isic2)
egen shbra=mean(totbra), by(year firmid isic2)
egen shhigh=mean(tothigh), by(year firmid isic2)
replace shbra=shbra/tot
replace shhigh=shhigh/tot
bys year firmid: keep if _n==1
replace shbra=0 if shbra==.
replace shhigh=0 if shhigh==.
keep year firmid shbra shhigh isic2
drop if year==. | isic2==. | isic2==30
collapse (mean) shbra shhigh, by(year isic2)
drop if year==.
rename isic2 isicmain
reshape wide shbra shhigh, i(isicmain) j(year)
order isicmain shbra1998 shbra1999 shbra2000 shhigh1998 shhigh1999 shhigh2000
append using temp
sort isicmain

format sh* %9.2f
outsheet using results/table04.csv, comma replace
erase temp.dta


