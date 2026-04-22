/** 
figure2.do

Creates Numbers for Figure 2
N. Baum-Snow & B. Lutz

**/

clear
set mem 400m

capture log close
log using figure2.log, replace text


******* 1. Ready Metro Area (Central District + Suburban) Data *********

use ../data/dis70panx.dta

*** Only keep MSAs for which we have 4 decades of data
egen minyr = min(year), by(msa)
drop if minyr==1970
egen obs60 = max((year==1960 & white~=.)), by(msa)
drop if obs60==0

keep if major==1

********* Figure 2 ******************
tab imp south if year==1960
*********************************************************


log close


