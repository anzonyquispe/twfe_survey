/** 
figure1.do

Creates Numbers for Figure 1
N. Baum-Snow & B. Lutz

Updated 6-3-2010
**/

clear
set mem 400m

capture log close
log using figure1.log, replace text


******* 1. Ready Metro Area (Central District + Suburban) Data *********

use ../data/dis70panx.dta

*** Only keep MSAs for which we have 4 decades of data
egen minyr = min(year), by(msa)
drop if minyr==1970
egen obs60 = max((year==1960 & white~=.)), by(msa)
drop if obs60==0

gen pop = (white+black+other)/1000000
replace mpop = (mwhite+mblack+mother)/1000000
replace black = black/1000000
replace white = white/1000000
replace mblack = mblack/1000000
replace mwhite = mwhite/1000000

gen rwhite = mwhite-white
gen rblack = mblack-black
gen rpop = mpop-pop

tab year

*Enrolled Children Counts
gen ewhite = (publicelemw+publichsw+privatelemw+privatehsw)/1000000
replace ewhite = (publicelemhsw+privatelemhsw)/1000000 if year==1990
gen eblack = (publicelemb+publichsb+privatelemb+privatehsb)/1000000
replace eblack = (publicelemhsb+privatelemhsb)/1000000 if year==1990
gen epop = (publicelemt+publichst+privatelemt+privatehst)/1000000
replace epop = (publicelemhst+privatelemhst)/1000000 if year==1990

gen emwhite = (mpublicelemw+mpublichsw+mprivatelemw+mprivatehsw)/1000000
replace emwhite = (mpublicelemhsw+mprivatelemhsw)/1000000 if year==1990
gen emblack = (mpublicelemb+mpublichsb+mprivatelemb+mprivatehsb)/1000000
replace emblack = (mpublicelemhsb+mprivatelemhsb)/1000000 if year==1990
gen empop = (mpublicelemt+mpublichst+mprivatelemt+mprivatehst)/1000000
replace empop = (mpublicelemhst+mprivatelemhst)/1000000 if year==1990

gen erwhite = emwhite-ewhite 
gen erblack = emblack-eblack 
gen erpop = empop-epop 

*Private Enrolled Children Counts
gen pwhite = (privatelemw+privatehsw)/1000000
replace pwhite = (privatelemhsw)/1000000 if year==1990
gen pblack = (privatelemb+privatehsb)/1000000
replace pblack = (privatelemhsb)/1000000 if year==1990
gen ppop = (privatelemt+privatehst)/1000000
replace ppop = (privatelemhst)/1000000 if year==1990

gen pmwhite = (mprivatelemw+mprivatehsw)/1000000
replace pmwhite = (mprivatelemhsw)/1000000 if year==1990
gen pmblack = (mprivatelemb+mprivatehsb)/1000000
replace pmblack = (mprivatelemhsb)/1000000 if year==1990
gen pmpop = (mprivatelemt+mprivatehst)/1000000
replace pmpop = (mprivatelemhst)/1000000 if year==1990

gen prwhite = pmwhite-pwhite 
gen prblack = pmblack-pblack 
gen prpop = pmpop-ppop 



************ 2. Report Metro Area Data **********************

***************    Output for Figure 1  *****************************
*********** Data for 92 Sample Metro Areas *************************
keep if major==1
*Sample Sizes, Pop
table year, contents(n pop n epop n ppop)
table year, contents(n rwhite n erwhite n prwhite)
*Total Populations (Panel A)
table year, contents(sum white sum black sum pop) format(%15.4f)
table year, contents(sum rwhite sum rblack sum rpop) format(%15.4f)
*Sample Sizes, Enrolled Pop
table year, contents(n pop n epop n ppop)
table year, contents(n rwhite n erwhite n prwhite)
*Enrolled Pop Counts (Panel B)
table year, contents(sum ewhite sum eblack sum epop) format(%15.4f)
table year, contents(sum erwhite sum erblack sum erpop) format(%15.4f)
****************************************************************


********** 3. United States Metro Area Data & Output  *******************

use ../data/cntypan.dta,clear

*Population
replace pop = (white+black+other)/1000000
replace black = black/1000000
replace white = white/1000000

*Enrolled Children Counts
gen ewhite = (publicelemw+publichsw+privatelemw+privatehsw)/1000000
replace ewhite = (publicelemhsw+privatelemhsw)/1000000 if year==1990
gen eblack = (publicelemb+publichsb+privatelemb+privatehsb)/1000000
replace eblack = (publicelemhsb+privatelemhsb)/1000000 if year==1990
gen epop = (publicelemt+publichst+privatelemt+privatehst)/1000000
replace epop = (publicelemhst+privatelemhst)/1000000 if year==1990

replace privatelemhsw = privatelemhsw/1000000
replace privatelemhsb = privatelemhsb/1000000

*************** Figure 1, For whole US *****************
*Total Pop Counts
table year, contents(sum white sum black sum pop) format(%15.4f)
*Enrolled Pop Counts
*1960 enrollment data is incomplete
table year if year>1960, contents(sum ewhite sum eblack sum epop) format(%15.4f)
***************************************************************

clear


******* 4. Report 1960 Enrolled pop counts from Census Microdata ******

use school raceg perwt using ../data/ipums/cenext60.dta

keep if school == 2
collapse (sum) perwt, by(raceg)

replace perwt = perwt/1000000
********* Table 1 Panel B, Columns 7-9 ******************
list
*********************************************************


log close


