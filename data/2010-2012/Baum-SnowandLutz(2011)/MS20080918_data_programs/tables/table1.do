** table1.do

clear
set mem 300m

capture log close
log using table1.log, replace text

*** Establish Sample
use ../data/dis70panx.dta
keep if major==1
drop if imp==.
replace imp = imp+1900

replace publicelemhsw = publicelemw+publichsw if year~=1990
replace publicelemhsb = publicelemb+publichsb if year~=1990
replace privatelemhsw = privatelemw+privatehsw if year~=1990
replace privatelemhsb = privatelemb+privatehsb if year~=1990

gen p_privatew = privatelemhsw / (publicelemhsw + privatelemhsw)
gen p_privateb = privatelemhsb / (publicelemhsb + privatelemhsb)

gen imp_postw = (year>=imp)
gen imp_postb = (year>=imp+4)

**** PANEL A BOTTOM *******
tab year imp_postw
tab year imp_postb
***************************

********** PANEL B ***********************
tabstat  p_privatew  p_privateb,               stat(mean) by(year)
tabstat  p_privatew  p_privateb if south == 1, stat(mean) by(year)
tabstat  p_privatew  p_privateb if south ~= 1, stat(mean) by(year) 
********************************************

keep leaid msa year imp_* public* private* white black area marea numdis
compress
sort msa year
save tempss.dta, replace

gen x1 = log(publicelemhsw)
gen x2 = log(privatelemhsw)
gen x3 = log(publicelemhsb)
gen x4 = log(privatelemhsb)
gen x5 = log(white)
gen x6 = log(black)
gen x7 = area/marea 
gen x8 = numdis

keep x* leaid year

reshape long x, i(leaid year) j(varnum)

************ PANEL A TOP *****************
table varnum year, contents(mean x sd x)
******************************************


use tempss,clear
keep msa year imp_post* 
sort msa year
save tempss, replace

use ../data/tractpanx.dta

** Drop tract area
drop area

** Drop tracts for which we don't know location
drop if cbd_dis==999999

** Put cbd-dis in KM
replace cbd_dis = cbd_dis/1000
sort msa year
merge msa year using tempss.dta
tab _merge 
** Merge=1 is MSAs without major plans, Merge=2 is untracted MSA/years
keep if _merge==3
drop _merge

*** Fix data a bit and set sample
drop if black+white+other==0

*** We're Only Doing Central District Tracts
keep if ccdis70==1

*** Define pop variable
gen pop = white+black

*** Build Distance metric for 1990
egen sumpop = sum(pop) if year==1990, by(msa year)
sort msa year cbd_dis
by msa year: gen cumpop = sum(pop) if year==1990
gen dis = cumpop/sumpop if year==1990

*** Allocate locations for tracts 1960-1980
sort msa cbd_dis
by msa: replace dis = dis[_n-1] if dis==.
gsort msa -cbd_dis
by msa: replace dis = dis[_n-1] if dis==.
drop cumpop

replace publicelemhsw = publicelemw+publichsw if year~=1990
replace publicelemhsb = publicelemb+publichsb if year~=1990
replace privatelemhsw = privatelemw+privatehsw if year~=1990
replace privatelemhsb = privatelemb+privatehsb if year~=1990

replace publicelemhsb = 0 if publicelemhsb==. & pop59b+pop1014b+pop1519b==0
replace publicelemhsb = 0 if publicelemhsb==. & black==0
replace privatelemhsb = 0 if privatelemhsb==. & pop59b+pop1014b+pop1519b==0
replace privatelemhsb = 0 if privatelemhsb==. & black==0
replace publicelemhsw = 0 if publicelemhsw==. & pop59w+pop1014w+pop1519w==0
replace publicelemhsw = 0 if publicelemhsw==. & white==0
replace privatelemhsw = 0 if privatelemhsw==. & pop59w+pop1014w+pop1519w==0
replace privatelemhsw = 0 if privatelemhsw==. & white==0

*** Restrict sample to tracts with data for both whites and blacks
drop if publicelemhsw==.|publicelemhsb==.

*** Only keep needed variables
keep msa year dis white black pop imp*

gen DIS = 1 if dis>0 & dis<=.25 
replace DIS = 2 if dis>.25 & dis<=.5
replace DIS = 3 if dis>.5 & dis<=.75 
replace DIS = 4 if dis>.75 & dis<=1

********** PANEL C **************
replace pop=pop/1000000
replace white=white/1000000
replace black = black/1000000
table DIS year, contents(sum white)
table DIS year, contents(sum black)

tab imp_postw year
tab imp_postb year

sort msa year
by msa year: keep if _n==1
tab year
tab imp_postw year
tab imp_postb year


log close

erase tempss.dta
