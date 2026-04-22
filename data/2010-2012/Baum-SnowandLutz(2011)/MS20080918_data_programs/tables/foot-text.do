/**foot-text.do

This do-file describes various elements of the
data not evident in tables or figures
for footnotes or the body of the text

**/

clear all
set mem 300m
set more off
capture log close
log using foot-text.log, replace text

use ../data/dis70panx.dta

*** Remove MSAs for which we do not observe data in all years
egen minyr = min(year), by(msa)
drop if minyr==1970
gen bad = 1 if white==.
egen BAD = max(bad), by (msa)
drop if BAD==1
** Should be 164 obs per year
tab year

****** Footnote near beginning ***********
gen pop=white+black+other
table year, contents(sum white sum black sum pop) format(%15.0f)
gen swhite = mwhite-white
gen sblack = mblack-black
gen spop = mpop-pop
table year, contents(sum swhite sum sblack sum spop) format(%15.0f)

keep if major==1
drop if imp==.
replace imp = imp+1900

****** Results for public only rather than all students 
replace publicelemhsw = publicelemw+publichsw if year<1990
replace publicelemhsb = publicelemb+publichsb if year<1990
replace publicelemhst = publicelemt+publichst if year<1990
table year if major==1, contents(sum publicelemhsw sum publicelemhsb sum publicelemhst) format(%15.0f)
replace mpublicelemhsw = mpublicelemw+mpublichsw if year<1990
replace mpublicelemhsb = mpublicelemb+mpublichsb if year<1990
replace mpublicelemhst = mpublicelemt+mpublichst if year<1990
gen spublicelemhsw = mpublicelemhsw-publicelemhsw
gen spublicelemhsb = mpublicelemhsb-publicelemhsb
gen spublicelemhst = mpublicelemhst-publicelemhst
table year if major==1, contents(sum spublicelemhsw sum spublicelemhsb sum spublicelemhst) format(%15.0f)

******* Discussion of Dissimilarity and Exposure Index Responses, Section 2.3 *******
* recode based on the data in Cascio et. al.;
replace disd  = 1 if year == 1960 &  south == 1   & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40)
replace disdm1 = 1 if year == 1960 &  south == 1   & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40)
replace disdT = 1 if year == 1960 &  south == 1   & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40)

replace expos = 0 if year == 1960 &  south == 1   & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40)
replace exposT= 0 if year == 1960 &  south == 1   & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40)


sum disd expos if year==1960
sum disd expos if year==1960 & south==1
sum disd expos if year==1970
gen imp_posta = (year>=imp)
xi: xtreg disd   i.year*i.south imp_posta, fe i(msa) cluster(msa)
xi: xtreg disdm1 i.year*i.south imp_posta, fe i(msa) cluster(msa)
xi: xtreg disdT  i.year*i.south imp_posta, fe i(msa) cluster(msa)
xi: xtreg expos  i.year*i.south imp_posta, fe i(msa) cluster(msa)
xi: xtreg exposT i.year*i.south imp_posta, fe i(msa) cluster(msa)

*** SIZE OF CENTRAL DISTRICTS RELATIVE TO SUBURBS**
**** FOR DISCUSSION IN DATA SECTION OF PAPER ******
use ../data/dis70panx, clear
sort msa year
by msa: replace mname = mname[_N]

gen frcd = (black+white+other)/(mblack+mwhite+mother)
gen fracd = area/marea

keep msa leaid frcd fracd year mname
reshape wide frcd fracd, i(msa) j(year)

sum frcd1960, detail
sum frcd1990, detail
gsort -frcd1960
l mname frcd1960 frcd1990 fracd1960
gsort -fracd1960
l mname frcd1960 frcd1990 fracd1960
**************************************************


*** Data Appendix Assertion about Tract Data Accuracy in 1960 **********
clear
use ../data/check/tracts60c.dta

gen ratelemb = xpublicelemb/publicelemb
*** Do this adjustment to omit partially tracted counties
replace ratelemb = . if xpublicelemt~=publicelemt
gen ratelemw = xpublicelemw/publicelemw
replace ratelemw = . if xpublicelemt~=publicelemt

gen rathsb = xpublichsb/publichsb
replace rathsb = . if xpublichst~=publichst
gen rathsw = xpublichsw/publichsw
replace rathsw = . if xpublichst~=publichst

sum ratelemb rathsb
sum ratelemw rathsw


/*** Data appendix - number of districts with tracts
spanning district boundaries ***/

use ../data/dis70panx.dta, clear
keep if major==1 & year==1990
keep if cntydis==0
gen stdis = sd70
sort stdis
save temp.dta, replace

use ../data/district70/tracts_unif70.dta
sort stdis
merge stdis using temp.dta
tab _merge
l mname if _merge==2
** THis is Tucson, a secondary district
keep if _merge==3
collapse (min) pct, by(stdis)
gen m100 = (pct<100)
tab m100

erase temp.dta

log close

