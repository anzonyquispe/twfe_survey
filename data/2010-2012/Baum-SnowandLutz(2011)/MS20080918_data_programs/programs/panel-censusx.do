/**
panel-censusx.do

This program takes census tract & county data from 1960-1990 
and creates a panel data set that has for each MSA tract, CC 
and MSA demographic and school enrollment information.  It 
then merges on districtpan.dta which has information from W&L
and the school district census tabulations.

It creates the two datasets dis70pan.dta and dis00pan.dta.  The
former uses 1970 school district geographies and the latter uses
2000 school district geographies.

This do-file is broken up into the following parts and readies
data sets to be combined as follows:
1. 1960 census
	a. tracts
	b. counties
	c. additional hand-entered data on counties & districts
2. 1970 census
	a. tracts
	b. counties
3. 1980 census
	a. tracts
	b. counties
4. 1990 census
	a. tracts
	b. counties
5. Panel data
	a. counties to MSAs => msapan.dta
	b. Organize School Districts in Sample
	c. tracts => tractpan.dta
6. Create Derivative data sets from tract data
	a. dis70pan.dta
	b. dis00pan.dta
7. Combine data sources to generate the final district/MSA level data sets
	a. data on county-level districts not tracted in 1960
	b. dis70panx.dta
	c. dis00panx.dta
**/

clear
set more off
set mem 400m
capture log close
log using panel-censusx.log, replace text


************************** 1. 1960 *******************************

*** 1a. 1960 NHGIS Tracts Data

*** A set of tracts in Tampa, FL have incorrect data from NHGIS -- use alternate source
use ../data/cenpan/tracts60.dta
keep if statefips==12 & cnty==29 & tracta>=45 & tracta<=57
** Drop cv tract
drop if tracta==49 & pop==44
sort tracta
keep tracta wm* wf* white black other public* grade*
save temp60t.dta, replace

use ../data/cenpan/nhgist60.dta

gen tracta = real(substr(GISJOIN,-3,3))
replace tracta = . if substr(GISJOIN,1,6)~="120057"
sort tracta
merge tracta using temp60t.dta, update replace
tab _merge
drop _merge

gen year = 1960

** Create Demographic Variables
gen pop04w = wm04+wf04
gen pop59w = wm59+wf59
gen pop1014w = wm1014+wf1014
gen pop1519w = wm1519+wf1519
gen pop2024w = wm2024+wf2024
gen pop2529w = wm2529+wf2529
gen pop3034w = wm3034+wf3034
gen pop3539w = wm3539+wf3539
gen pop4044w = wm4044+wf4044
gen pop4549w = wm4549+wf4549
gen pop5054w = wm5054+wf5054
gen pop5559w = wm5559+wf5559
gen pop6064w = wm6064+wf6064
gen pop6569w = wm6569+wf6569
gen pop7074w = wm7074+wf7074
gen pop75upw = wm75up+wf75up

** Since don't observe data for blacks in 1960, use other and adjust below
gen pop04b = om04+of04 
gen pop59b = om59+of59
gen pop1014b = om1014+of1014
gen pop1519b = om1519+of1519
gen pop2024b = om2024+of2024
gen pop2529b = om2529+of2529
gen pop3034b = om3034+of3034
gen pop3539b = om3539+of3539
gen pop4044b = om4044+of4044
gen pop4549b = om4549+of4549
gen pop5054b = om5054+of5054
gen pop5559b = om5559+of5559
gen pop6064b = om6064+of6064
gen pop6569b = om6569+of6569
gen pop7074b = om7074+of7074
gen pop75upb = om75up+of75up

gen pop04t = pop04w+pop04b
gen pop59t = pop59w+pop59b
gen pop1014t = pop1014w+pop1014b
gen pop1519t = pop1519w+pop1519b
gen pop2024t = pop2024w+pop2024b
gen pop2529t = pop2529w+pop2529b
gen pop3034t = pop3034w+pop3034b
gen pop3539t = pop3539w+pop3539b
gen pop4044t = pop4044w+pop4044b
gen pop4549t = pop4549w+pop4549b
gen pop5054t = pop5054w+pop5054b
gen pop5559t = pop5559w+pop5559b
gen pop6064t = pop6064w+pop6064b
gen pop6569t = pop6569w+pop6569b
gen pop7074t = pop7074w+pop7074b
gen pop75upt = pop75upw+pop75upb

** Rescale "black" numbers by black/(black+other)
replace pop04b = pop04b*(black/(black+other)) 
replace pop59b = pop59b*(black/(black+other)) 
replace pop1014b = pop1014b*(black/(black+other)) 
replace pop1519b = pop1519b*(black/(black+other)) 
replace pop2024b = pop2024b*(black/(black+other)) 
replace pop2529b = pop2529b*(black/(black+other)) 
replace pop3034b = pop3034b*(black/(black+other)) 
replace pop3539b = pop3539b*(black/(black+other)) 
replace pop4044b = pop4044b*(black/(black+other)) 
replace pop4549b = pop4549b*(black/(black+other)) 
replace pop5054b = pop5054b*(black/(black+other)) 
replace pop5559b = pop5559b*(black/(black+other)) 
replace pop6064b = pop6064b*(black/(black+other)) 
replace pop6569b = pop6569b*(black/(black+other)) 
replace pop7074b = pop7074b*(black/(black+other)) 
replace pop75upb = pop75upb*(black/(black+other)) 

** Rename and rescale school attendance variables
rename publicelem publicelemt
gen publicelemb = publicelemt*(pop59b+pop1014b)/(pop59t+pop1014t)
gen publicelemw = publicelemt*(pop59w+pop1014w)/(pop59t+pop1014t)
gen privatelemt = gradeelem-publicelemt
gen privatelemb = (privatelemt)*(pop59b+pop1014b)/(pop59t+pop1014t)
gen privatelemw = (privatelemt)*(pop59w+pop1014w)/(pop59t+pop1014t)

rename publichs publichst
gen publichsb = publichst*(pop1519b)/(pop1519t)
gen publichsw = publichst*(pop1519w)/(pop1519t)
gen privatehst = gradehs-publichst
gen privatehsb = (privatehst)*(pop1519b)/(pop1519t)
gen privatehsw = (privatehst)*(pop1519w)/(pop1519t)

*** Calculate median family income
gen incdt = fincu1k+finc1k2k+finc2k3k+finc3k4k+finc4k5k+finc5k6k+finc6k7k+finc7k8k+finc8k9k+finc9k10k+finc10k15k+finc15k25k+finco25k
*** For the purpose of incomes, assume that black and other are the same
gen incdb = fincou1k+finco1k2k+finco2k3k+finco3k4k+finco4k5k+finco5k6k+finco6k7k+finco7k8k+finco8k9k+finco9k10k+fincoo10k
gen incdw = incdt-incdb

gen pu1k = fincu1k/incdt
gen p1k2k = finc1k2k/incdt
gen p2k3k = finc2k3k/incdt
gen p3k4k = finc3k4k/incdt
gen p4k5k = finc4k5k/incdt
gen p5k6k = finc5k6k/incdt
gen p6k7k = finc6k7k/incdt
gen p7k8k = finc7k8k/incdt
gen p8k9k = finc8k9k/incdt
gen p9k10k = finc9k10k/incdt
gen p10k15k = finc10k15k/incdt
gen p15k25k = finc15k25k/incdt
gen po25k = finco25k/incdt
gen inct = .
#delimit ;
replace inct = 1000*.5/pu1k if inct==. & pu1k>=.5;
replace inct = 1000+1000*(.5-pu1k)/p1k2k if inct==. & pu1k+p1k2k>=.5;
replace inct = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if inct==. & pu1k+p1k2k+p2k3k>=.5;
replace inct = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if inct==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace inct = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace inct = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace inct = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace inct = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace inct = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace inct = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace inct = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/p10k15k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k>=.5;
replace inct = 15000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k)/p15k25k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k>=.5;
replace inct = 25000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k-p15k25k)/po25k
if inct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k+po25k>=.5;
#delimit cr

drop p*k*
gen pu1k = fincou1k/incdb
gen p1k2k = finco1k2k/incdb
gen p2k3k = finco2k3k/incdb
gen p3k4k = finco3k4k/incdb
gen p4k5k = finco4k5k/incdb
gen p5k6k = finco5k6k/incdb
gen p6k7k = finco6k7k/incdb
gen p7k8k = finco7k8k/incdb
gen p8k9k = finco8k9k/incdb
gen p9k10k = finco9k10k/incdb
gen po10k = fincoo10k/incdb
gen incb = .
#delimit ;
replace incb = 1000*.5/pu1k if incb==. & pu1k>=.5;
replace incb = 1000+1000*(.5-pu1k)/p1k2k if incb==. & pu1k+p1k2k>=.5;
replace incb = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if incb==. & pu1k+p1k2k+p2k3k>=.5;
replace incb = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if incb==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace incb = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace incb = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace incb = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace incb = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace incb = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace incb = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace incb = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if incb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;
#delimit cr

drop p*k*
gen pu1k = (fincu1k-fincou1k)/incdw
gen p1k2k = (finc1k2k-finco1k2k)/incdw
gen p2k3k = (finc2k3k-finco2k3k)/incdw
gen p3k4k = (finc3k4k-finco3k4k)/incdw
gen p4k5k = (finc4k5k-finco4k5k)/incdw
gen p5k6k = (finc5k6k-finco5k6k)/incdw
gen p6k7k = (finc6k7k-finco6k7k)/incdw
gen p7k8k = (finc7k8k-finco7k8k)/incdw
gen p8k9k = (finc8k9k-finco8k9k)/incdw
gen p9k10k = (finc9k10k-finco9k10k)/incdw
gen po10k = (finc10k15k+finc15k25k+finco25k-fincoo10k)/incdw
gen incw = .
#delimit ;
replace incw = 1000*.5/pu1k if incw==. & pu1k>=.5;
replace incw = 1000+1000*(.5-pu1k)/p1k2k if incw==. & pu1k+p1k2k>=.5;
replace incw = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if incw==. & pu1k+p1k2k+p2k3k>=.5;
replace incw = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if incw==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace incw = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace incw = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace incw = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace incw = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace incw = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace incw = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace incw = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if incw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;

keep GISJOIN white black other pop*t pop*w pop*b 
pub*w pub*b pub*t pri*w pri*b pri*t inc* finc* year;
#delimit cr

gen areakey = substr(GISJOIN,1,2)+substr(GISJOIN,4,.)
gen statefips = real(substr(areakey,1,2))
gen cntyfips = real(substr(areakey,3,3))
*** We are not saving the tract codes from 1960

save temp60t.dta, replace


** 1b. NHGIS Data for counties

*** Read in income, enrollment data from the aggregated census tract data
use temp60t
collapse (sum) finc* public*, by(statefips cntyfips)
rename publicelemt xpublicelemt
rename publicelemw xpublicelemw
rename publicelemb xpublicelemb
rename publichst xpublichst
rename publichsw xpublichsw
rename publichsb xpublichsb

sort statefips cntyfips
save tempx.dta, replace

*** Ready hand-entered data on enrollment
clear
insheet using ../data/handenter/county_1960_enroll.csv, names comma

** These are counties with fewer than 1000 nonwhites
gen mis_nw_60 = totalelemnw == "*"

#delimit ;
for var totalelemnw
	publicelemnw
	totalhsnw
	publichsnw : destring X, replace force;
** Nonwhites < 1000 are suppressed - assume they are 0;
for var totalelemnw
	publicelemnw
	totalhsnw
	publichsnw : replace X = 0 if X == .;
#delimit cr

gen publicelemw = publicelemt-publicelemnw
gen privatelemnw = totalelemnw-publicelemnw
gen privatelemt = totalelemt-publicelemt
gen privatelemw = privatelemt-privatelemnw
gen publichsw = publichst-publichsnw
gen privatehsnw = totalhsnw-publichsnw
gen privatehst = totalhst-publichst
gen privatehsw = privatehst-privatehsnw

#delimit ;
keep statefips cntyfips publicelemw publicelemnw publicelemt
privatelemt privatelemnw privatelemw
publichsw publichsnw publichst
privatehst privatehsnw privatehsw;
#delimit cr

** Miami-Dade County Changed Codes -- Fix For Merge Below
replace cntyfips = 25 if cntyfips == 86 & statefips==12

sort statefips cntyfips
save temp60c.dta, replace

** The rest of the county data is straight from NHGIS
use ../data/cenpan/nhgisc60.dta

gen year = 1960

** White pop by age already available

gen pop75upw = pop7579w+pop8084w+pop85upw

gen pop04t = pop04o+pop04w
gen pop59t = pop59o+pop59w
gen pop1014t = pop1014o+pop1014w
gen pop1519t = pop1519o+pop1519w
gen pop2024t = pop2024o+pop2024w
gen pop2529t = pop2529o+pop2529w
gen pop3034t = pop3034o+pop3034w
gen pop3539t = pop3539o+pop3539w
gen pop4044t = pop4044o+pop4044w
gen pop4549t = pop4549o+pop4549w
gen pop5054t = pop5054o+pop5054w
gen pop5559t = pop5559o+pop5559w
gen pop6064t = pop6064o+pop6064w
gen pop6569t = pop6569o+pop6569w
gen pop7074t = pop7074o+pop7074w
gen pop75upt = (pop7579o+pop8084o+pop85upo)+(pop7579w+pop8084w+pop85upw)
drop pop7579w pop8084w pop85upw

** Rescale other numbers by black/(black+other)
gen pop04b = pop04o*(black/(black+other)) 
gen pop59b = pop59o*(black/(black+other)) 
gen pop1014b = pop1014o*(black/(black+other)) 
gen pop1519b = pop1519o*(black/(black+other)) 
gen pop2024b = pop2024o*(black/(black+other)) 
gen pop2529b = pop2529o*(black/(black+other)) 
gen pop3034b = pop3034o*(black/(black+other)) 
gen pop3539b = pop3539o*(black/(black+other)) 
gen pop4044b = pop4044o*(black/(black+other)) 
gen pop4549b = pop4549o*(black/(black+other)) 
gen pop5054b = pop5054o*(black/(black+other))
gen pop5559b = pop5559o*(black/(black+other))
gen pop6064b = pop6064o*(black/(black+other))
gen pop6569b = pop6569o*(black/(black+other))
gen pop7074b = pop7074o*(black/(black+other))
gen pop75upb = (pop7579o+pop8084o+pop85upo)*(black/(black+other)) 
drop pop7579o pop8084o pop85upo

/* The 1960 county data from NHGIS does not have much on school
attendance:  All it has is fraction of elementary students attending
private school.  It does not have full attendance numbers.
Instead we use hand-entered or tract data that is merged in and processed here.*/ 
drop pctprivelem gradeelem 

** Merge on hand-entered county data
gen statefips = real(substr(GISJOIN,1,2))
gen cntyfips = real(substr(GISJOIN,4,3))
** The wrong county fips code is in for South Norfolk City, VA
replace cntyfips = 785 if GISJOIN=="5107805"
sort statefips cntyfips
merge statefips cntyfips using temp60c.dta
tab _merge
** should be 1 & 3
drop _merge

** Merge on tract-derived county data
sort statefips cntyfips
merge statefips cntyfips using tempx.dta
tab _merge
drop _merge

*** Calculate Estimates for Blacks
gen privatelemb = privatelemnw*(pop59b+pop1014b)/(pop59o+pop1014o)
replace privatelemb = 0 if privatelemnw==0
gen privatehsb = privatehsnw*(pop1519b)/(pop1519o)
replace privatehsb = 0 if privatehsnw==0
gen publicelemb = publicelemnw*(pop59b+pop1014b)/(pop59o+pop1014o)
replace publicelemb = 0 if publicelemnw==0
gen publichsb = publichsnw*(pop1519b)/(pop1519o)
replace publichsb = 0 if publicelemnw==0

#delimit ;
keep statefips cntyfips white black other pop*t pop*w pop*b 
pub*w pub*b pub*t pri*w pri*b pri*t finc* year;
#delimit cr

sort statefips cntyfips
save temp60c.dta, replace

*** Get % Manufacturing employment
use ../data/ccdb/county4070.dta
keep if year==60
keep statefips cntyfips empman emp name
drop if emp==. | emp==0
*** Fix county changes that matter for MSAs
replace cntyfips = 186 if cntyfips==193 & statefips==29
replace cntyfips = 129 if cntyfips==550 & statefips==51
replace cntyfips = 59 if cntyfips==600 & statefips==51
replace cntyfips = 175 if cntyfips==620 & statefips==51
collapse (sum) empman emp, by(statefips cntyfips)
sort statefips cntyfips
merge statefips cntyfips using temp60c.dta
tab statefips _merge if _merge<3
l statefips cntyfips if _merge==1
drop if _merge==1
drop _merge
sort statefips cntyfips
save temp60c.dta, replace

/**** 1c. Ready Hand-Entered Data from the 1960 Census 
for 2 Untracted Non-County Districts, 1 County District
Left Out of the County Data Set (Roanoke City, VA) and  
Income Data for All Untracted 1960 Central Districts
****/

*** Enrollment data For 2 Untracted Non-County Districts
clear
use ../data/handenter/1960_ad_data.dta
** Keep only Lawton, OK, Amarillo, TX & Roanoke VA
keep if leaid==4017250|leaid==4808130|leaid==5103300
*** variables with b suffix have been calculated already using XXnw*black/(black+other)
gen privatelemt = privatelemw+privatelemnw
gen privatehst = privatehsw+privatehsnw
rename popo other
#delimit ;
keep leaid year mname imp major south region white black other incw incb
publicelemb publicelemw publicelemt publichsb publichsw publichst 
privatelemw privatelemb privatelemt privatehsw privatehsb privatehst;
#delimit cr
sort leaid year
save tempadd.dta, replace

*** Separate Out the Roanoake City Obs to Add to County Data
keep if leaid==5103300
drop leaid mname imp major south region
gen statefips=51
gen cntyfips=770
sort statefips cntyfips
merge statefips cntyfips using temp60c.dta, update
tab _merge
drop _merge
save temp60c.dta, replace

*** Create the Lawton/Amarillo Data Set
use tempadd.dta, clear
drop if leaid==5103300
sort leaid year
save tempadd.dta, replace

**** Get Income For All Central Districts
clear
use ../data/handenter/1960_ad_data.dta
*** Drop Fayetteville, NC -- no longer in sample
drop if leaid==3700011
keep leaid year incw incb 
sort leaid year
save tempinc60.dta, replace

*** This is data on the age distribution of the population by race
clear 
use ../data/handenter/am_law_age.dta

*** Merge on Lawton, Amarillo's enrollment and race data
sort leaid
merge leaid using tempadd.dta
tab _merge
keep if _merge==3
drop _merge

gen pop04b = (pop04t-pop04w)*black/(black+other)
gen pop59b = (pop59t-pop59w)*black/(black+other)
gen pop1014b = (pop1014t-pop1014w)*black/(black+other)
gen pop1519b = (pop1519t-pop1519w)*black/(black+other)
gen pop2024b = (pop2024t-pop2024w)*black/(black+other)
gen pop2529b = (pop2529t-pop2529w)*black/(black+other)
gen pop3034b = (pop3034t-pop3034w)*black/(black+other)
gen pop3539b = (pop3539t-pop3539w)*black/(black+other)
gen pop4044b = (pop4044t-pop4044w)*black/(black+other)
gen pop4549b = (pop4549t-pop4549w)*black/(black+other)
gen pop5054b = (pop5054t-pop5054w)*black/(black+other)
gen pop5559b = (pop5559t-pop5559w)*black/(black+other)
gen pop6064b = (pop6064t-pop6064w)*black/(black+other)
gen pop6569b = (pop6569t-pop6569w)*black/(black+other)
gen pop7074b = (pop7074t-pop7074w)*black/(black+other)
gen pop75upb = (pop75upt-pop75upw)*black/(black+other)

sort leaid year
save am_law_agex.dta, replace


************************** 2. 1970 *****************************

*** 2a. 1970 Tracts

use ../data/cenpan/tracts70.dta

** Create Demographic Variables
gen pop04t = mpopl31+mpop341+fpopl31+fpop341
gen pop59t = mpop51+mpop61+mpop791+fpop51+fpop61+fpop791
gen pop1014t = mpop10131+mpop141+fpop10131+fpop141
gen pop1519t = mpop151+mpop161+mpop171+mpop181+mpop191+fpop151+fpop161+fpop171+fpop181+fpop191
gen pop2024t = mpop201+mpop211+mpop22241+fpop201+fpop211+fpop22241
gen pop2529t = mpop25291+fpop25291
gen pop3034t = mpop30341+fpop30341
gen pop3539t = mpop35391+fpop35391
gen pop4044t = mpop40441+fpop40441
gen pop4549t = mpop45491+fpop45491
gen pop5054t = mpop50541+fpop50541
gen pop5559t = mpop55591+fpop55591
gen pop6064t = mpop60611+fpop60611+mpop62641+fpop62641
gen pop6569t = mpop65691+fpop65691
gen pop7074t = mpop70741+fpop70741
gen pop75upt = mpop75up1+fpop75up1

gen pop04w = mpopl32+mpop342+fpopl32+fpop342
gen pop59w = mpop52+mpop62+mpop792+fpop52+fpop62+fpop792
gen pop1014w = mpop10132+mpop142+fpop10132+fpop142
gen pop1519w = mpop152+mpop162+mpop172+mpop182+mpop192+fpop152+fpop162+fpop172+fpop182+fpop192
gen pop2024w = mpop202+mpop212+mpop22242+fpop202+fpop212+fpop22242
gen pop2529w = mpop25292+fpop25292
gen pop3034w = mpop30342+fpop30342
gen pop3539w = mpop35392+fpop35392
gen pop4044w = mpop40442+fpop40442
gen pop4549w = mpop45492+fpop45492
gen pop5054w = mpop50542+fpop50542
gen pop5559w = mpop55592+fpop55592
gen pop6064w = mpop60612+fpop60612+mpop62642+fpop62642
gen pop6569w = mpop65692+fpop65692
gen pop7074w = mpop70742+fpop70742
gen pop75upw = mpop75up2+fpop75up2

gen pop04b = mpopl33+mpop343+fpopl33+fpop343
gen pop59b = mpop53+mpop63+mpop793+fpop53+fpop63+fpop793
gen pop1014b = mpop10133+mpop143+fpop10133+fpop143
gen pop1519b = mpop153+mpop163+mpop173+mpop183+mpop193+fpop153+fpop163+fpop173+fpop183+fpop193
gen pop2024b = mpop203+mpop213+mpop22243+fpop203+fpop213+fpop22243
gen pop2529b = mpop25293+fpop25293
gen pop3034b = mpop30343+fpop30343
gen pop3539b = mpop35393+fpop35393
gen pop4044b = mpop40443+fpop40443
gen pop4549b = mpop45493+fpop45493
gen pop5054b = mpop50543+fpop50543
gen pop5559b = mpop55593+fpop55593
gen pop6064b = mpop60613+fpop60613+mpop62643+fpop62643
gen pop6569b = mpop65693+fpop65693
gen pop7074b = mpop70743+fpop70743
gen pop75upb = mpop75up3+fpop75up3

** Avg Income for those 14+ (looks like should be multiplied by 10)
gen inct = 10*(maginc14up1+faginc14up1)/(mpop141+fpop141+pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt)
gen incw = 10*(maginc14up2+faginc14up2)/(mpop142+fpop142+pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw)
gen incb = 10*(maginc14up3+faginc14up3)/(mpop143+fpop143+pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb)

gen incdt = mpop141+fpop141+pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt
gen incdw = mpop142+fpop142+pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw
gen incdb = mpop143+fpop143+pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb

rename eschpub1 publicelemt
rename hschpub1 publichst
gen privatelemt = eschpar1+eschpri1
gen privatehst = hschpar1+hschpri1
rename eschpub2 publicelemw
rename hschpub2 publichsw
gen privatelemw = eschpar2+eschpri2
gen privatehsw = hschpar2+hschpri2
rename eschpub3 publicelemb
rename hschpub3 publichsb
gen privatelemb = eschpar3+eschpri3
gen privatehsb = hschpar3+hschpri3

keep statefips cntyfips tract white black other inc* pop*t pop*w pop*b pub* pri*
gen year = 1970
sort statefips cntyfips tract 
save temp70t.dta, replace

**** 2b. 1970 Counties

use ../data/cenpan/cnty70.dta

** Create Demographic Variables
gen pop04t = mpopl31+mpop341+fpopl31+fpop341
gen pop59t = mpop51+mpop61+mpop791+fpop51+fpop61+fpop791
gen pop1014t = mpop10131+mpop141+fpop10131+fpop141
gen pop1519t = mpop151+mpop161+mpop171+mpop181+mpop191+fpop151+fpop161+fpop171+fpop181+fpop191
gen pop2024t = mpop201+mpop211+mpop22241+fpop201+fpop211+fpop22241
gen pop2529t = mpop25291+fpop25291
gen pop3034t = mpop30341+fpop30341
gen pop3539t = mpop35391+fpop35391
gen pop4044t = mpop40441+fpop40441
gen pop4549t = mpop45491+fpop45491
gen pop5054t = mpop50541+fpop50541
gen pop5559t = mpop55591+fpop55591
gen pop6064t = mpop60611+fpop60611+mpop62641+fpop62641
gen pop6569t = mpop65691+fpop65691
gen pop7074t = mpop70741+fpop70741
gen pop75upt = mpop75up1+fpop75up1

gen pop04w = mpopl32+mpop342+fpopl32+fpop342
gen pop59w = mpop52+mpop62+mpop792+fpop52+fpop62+fpop792
gen pop1014w = mpop10132+mpop142+fpop10132+fpop142
gen pop1519w = mpop152+mpop162+mpop172+mpop182+mpop192+fpop152+fpop162+fpop172+fpop182+fpop192
gen pop2024w = mpop202+mpop212+mpop22242+fpop202+fpop212+fpop22242
gen pop2529w = mpop25292+fpop25292
gen pop3034w = mpop30342+fpop30342
gen pop3539w = mpop35392+fpop35392
gen pop4044w = mpop40442+fpop40442
gen pop4549w = mpop45492+fpop45492
gen pop5054w = mpop50542+fpop50542
gen pop5559w = mpop55592+fpop55592
gen pop6064w = mpop60612+fpop60612+mpop62642+fpop62642
gen pop6569w = mpop65692+fpop65692
gen pop7074w = mpop70742+fpop70742
gen pop75upw = mpop75up2+fpop75up2

gen pop04b = mpopl33+mpop343+fpopl33+fpop343
gen pop59b = mpop53+mpop63+mpop793+fpop53+fpop63+fpop793
gen pop1014b = mpop10133+mpop143+fpop10133+fpop143
gen pop1519b = mpop153+mpop163+mpop173+mpop183+mpop193+fpop153+fpop163+fpop173+fpop183+fpop193
gen pop2024b = mpop203+mpop213+mpop22243+fpop203+fpop213+fpop22243
gen pop2529b = mpop25293+fpop25293
gen pop3034b = mpop30343+fpop30343
gen pop3539b = mpop35393+fpop35393
gen pop4044b = mpop40443+fpop40443
gen pop4549b = mpop45493+fpop45493
gen pop5054b = mpop50543+fpop50543
gen pop5559b = mpop55593+fpop55593
gen pop6064b = mpop60613+fpop60613+mpop62643+fpop62643
gen pop6569b = mpop65693+fpop65693
gen pop7074b = mpop70743+fpop70743
gen pop75upb = mpop75up3+fpop75up3

** Avg Income for those 14+ (looks like should be multiplied by 10)
gen inct = 10*(maginc14up1+faginc14up1)/(mpop141+fpop141+pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt)
gen incw = 10*(maginc14up2+faginc14up2)/(mpop142+fpop142+pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw)
gen incb = 10*(maginc14up3+faginc14up3)/(mpop143+fpop143+pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb)

gen incdt = mpop141+fpop141+pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt
gen incdw = mpop142+fpop142+pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw
gen incdb = mpop143+fpop143+pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb

rename eschpub1 publicelemt
rename hschpub1 publichst
gen privatelemt = eschpar1+eschpri1
gen privatehst = hschpar1+hschpri1
rename eschpub2 publicelemw
rename hschpub2 publichsw
gen privatelemw = eschpar2+eschpri2
gen privatehsw = hschpar2+hschpri2
rename eschpub3 publicelemb
rename hschpub3 publichsb
gen privatelemb = eschpar3+eschpri3
gen privatehsb = hschpar3+hschpri3

keep statefips cntyfips white black other inc* pop*t pop*w pop*b pub* pri*
gen year = 1970
sort statefips cntyfips
save temp70c.dta, replace


*********************** 3. 1980 *************************

** 3a. 1980 Tracts
use ../data/cenpan/tracts80.dta

gen pop04t = popl30+pop340
gen pop59t = pop50+pop60+pop790
gen pop1014t = pop10110+pop12130+pop140
gen pop1519t = pop150+pop16170+pop180+pop190
gen pop2024t = pop200+pop210+pop22240
gen pop2529t = pop25290
gen pop3034t = pop30340
gen pop3539t = pop35390
gen pop4044t = pop40440
gen pop4549t = pop45490
gen pop5054t = pop50540
gen pop5559t = pop55590
gen pop6064t = pop60610+pop62640
gen pop6569t = pop65690
gen pop7074t = pop70740
gen pop75upt = pop75790+pop80840+pop85up0

gen pop04w = popl31+pop341
gen pop59w = pop51+pop61+pop791
gen pop1014w = pop10111+pop12131+pop141
gen pop1519w = pop151+pop16171+pop181+pop191
gen pop2024w = pop201+pop211+pop22241
gen pop2529w = pop25291
gen pop3034w = pop30341
gen pop3539w = pop35391
gen pop4044w = pop40441
gen pop4549w = pop45491
gen pop5054w = pop50541
gen pop5559w = pop55591
gen pop6064w = pop60611+pop62641
gen pop6569w = pop65691
gen pop7074w = pop70741
gen pop75upw = pop75791+pop80841+pop85up1

gen pop04b = popl32+pop342
gen pop59b = pop52+pop62+pop792
gen pop1014b = pop10112+pop12132+pop142
gen pop1519b = pop152+pop16172+pop182+pop192
gen pop2024b = pop202+pop212+pop22242
gen pop2529b = pop25292
gen pop3034b = pop30342
gen pop3539b = pop35392
gen pop4044b = pop40442
gen pop4549b = pop45492
gen pop5054b = pop50542
gen pop5559b = pop55592
gen pop6064b = pop60612+pop62642
gen pop6569b = pop65692
gen pop7074b = pop70742
gen pop75upb = pop75792+pop80842+pop85up2

rename scelpub0 publicelemt
rename schspub0 publichst
gen privatelemt = scelchu0+scelpri0
gen privatehst = schschu0+schspri0
rename scelpub1 publicelemw
rename schspub1 publichsw
gen privatelemw = scelchu1+scelpri1
gen privatehsw = schschu1+schspri1
rename scelpub2 publicelemb
rename schspub2 publichsb
gen privatelemb = scelchu2+scelpri2
gen privatehsb = schschu2+schspri2

gen tract = tract4+tract2/100

keep statefips cntyfips tract white black other aginc* pop*t pop*w pop*b pub* pri*

/*** In 1980, stf4a splits tracts across place boundaries -- recombine
because we do not have GIS data on the split geographies ***/
collapse (sum) white black other pop*t pop*w pop*b pub* pri* aginc*, by(statefips cntyfips tract)

gen inct = (aginchh15590+aginchh60640+aginchh65up0+agincgc15590+agincgc60640+agincgc65up0)/(pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt)
gen incw = (aginchh15591+aginchh60641+aginchh65up1+agincgc15591+agincgc60641+agincgc65up1)/(pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw)
gen incb = (aginchh15592+aginchh60642+aginchh65up2+agincgc15592+agincgc60642+agincgc65up2)/(pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb)
drop aginchh* agincgc*

gen incdt = pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt
gen incdw = pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw
gen incdb = pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb

gen year = 1980

sort statefips cntyfips tract
save temp80t.dta, replace

** 3b. 1980 Counties
use ../data/cenpan/cnty80.dta

gen pop04t = popl30+pop340
gen pop59t = pop50+pop60+pop790
gen pop1014t = pop10110+pop12130+pop140
gen pop1519t = pop150+pop16170+pop180+pop190
gen pop2024t = pop200+pop210+pop22240
gen pop2529t = pop25290
gen pop3034t = pop30340
gen pop3539t = pop35390
gen pop4044t = pop40440
gen pop4549t = pop45490
gen pop5054t = pop50540
gen pop5559t = pop55590
gen pop6064t = pop60610+pop62640
gen pop6569t = pop65690
gen pop7074t = pop70740
gen pop75upt = pop75790+pop80840+pop85up0

gen pop04w = popl31+pop341
gen pop59w = pop51+pop61+pop791
gen pop1014w = pop10111+pop12131+pop141
gen pop1519w = pop151+pop16171+pop181+pop191
gen pop2024w = pop201+pop211+pop22241
gen pop2529w = pop25291
gen pop3034w = pop30341
gen pop3539w = pop35391
gen pop4044w = pop40441
gen pop4549w = pop45491
gen pop5054w = pop50541
gen pop5559w = pop55591
gen pop6064w = pop60611+pop62641
gen pop6569w = pop65691
gen pop7074w = pop70741
gen pop75upw = pop75791+pop80841+pop85up1

gen pop04b = popl32+pop342
gen pop59b = pop52+pop62+pop792
gen pop1014b = pop10112+pop12132+pop142
gen pop1519b = pop152+pop16172+pop182+pop192
gen pop2024b = pop202+pop212+pop22242
gen pop2529b = pop25292
gen pop3034b = pop30342
gen pop3539b = pop35392
gen pop4044b = pop40442
gen pop4549b = pop45492
gen pop5054b = pop50542
gen pop5559b = pop55592
gen pop6064b = pop60612+pop62642
gen pop6569b = pop65692
gen pop7074b = pop70742
gen pop75upb = pop75792+pop80842+pop85up2

gen inct = (aginchh15590+aginchh60640+aginchh65up0+agincgc15590+agincgc60640+agincgc65up0)/(pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt)
gen incw = (aginchh15591+aginchh60641+aginchh65up1+agincgc15591+agincgc60641+agincgc65up1)/(pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw)
gen incb = (aginchh15592+aginchh60642+aginchh65up2+agincgc15592+agincgc60642+agincgc65up2)/(pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb)
drop aginchh* agincgc*

gen incdt = pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt
gen incdw = pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw
gen incdb = pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb

rename scelpub0 publicelemt
rename schspub0 publichst
gen privatelemt = scelchu0+scelpri0
gen privatehst = schschu0+schspri0
rename scelpub1 publicelemw
rename schspub1 publichsw
gen privatelemw = scelchu1+scelpri1
gen privatehsw = schschu1+schspri1
rename scelpub2 publicelemb
rename schspub2 publichsb
gen privatelemb = scelchu2+scelpri2
gen privatehsb = schschu2+schspri2

keep statefips cntyfips white black other pop*t pop*w pop*b pub* pri* inc*

gen year = 1980
sort statefips cntyfips 
save temp80c.dta, replace


*********************** 4. 1990 ****************************

*** 4a. 1990 tracts

use ../data/cen90/tract90.dta
gen statefips = real(substr(areakey,1,2))
gen cntyfips = real(substr(areakey,3,3))
gen tract = real(substr(areakey,6,.))/100

** Merge on the 1990 stf4a data: the census stf4 release is missing some tracts
sort statefips cntyfips tract 
merge statefips cntyfips tract using ../data/cenpan/tracts90.dta
tab _merge
** Should be all 3s, though there are some 1s
drop _merge

gen pop04t = ageu1+age1_2+age3_4
gen pop59t = age5+age6+age7_9
gen pop1014t = age10_11+age12_13+age14
gen pop1519t = age15+age16+age17+age18+age19
gen pop2024t = age20+age21+age22_24
gen pop2529t = age25_29
gen pop3034t = age30_34
gen pop3539t = age35_39
gen pop4044t = age40_44
gen pop4549t = age45_49
gen pop5054t = age50_54
gen pop5559t = age55_59
gen pop6064t = age60_61+age62_64
gen pop6569t = age65_69
gen pop7074t = age70_74
*** age70_79 is Geolytics' name for age7579
gen pop75upt = age70_79+age80_84+age85p

gen pop04w = wm_u1+wm_1_2+wm_3_4+wf_u1+wf_1_2+wf_3_4
gen pop59w = wm_5+wm_6+wm_7_9+wf_5+wf_6+wf_7_9
gen pop1014w = wm_10_11+wm_12_13+wm_14+wf_10_11+wf_12_13+wf_14
gen pop1519w = wm_15+wm_16+wm_17+wm_18+wm_19+wf_15+wf_16+wf_17+wf_18+wf_19
gen pop2024w = wm_20+wm_21+wm_22_24+wf_20+wf_21+wf_22_24
gen pop2529w = wm_25_29+wf_25_29
gen pop3034w = wm_30_34+wf_30_34
gen pop3539w = wm_35_39+wf_35_39
gen pop4044w = wm_40_44+wf_40_44
gen pop4549w = wm_45_49+wf_45_49
gen pop5054w = wm_50_54+wf_50_54
gen pop5559w = wm_55_59+wf_55_59
gen pop6064w = wm_60_61+wm_62_64+wf_60_61+wf_62_64
gen pop6569w = wm_65_69+wf_65_69
gen pop7074w = wm_70_74+wf_70_74
gen pop75upw = wm_70_79+wm_80_84+wm_85p+wf_70_79+wf_80_84+wf_85p

gen pop04b = bm_+bm_1_2+bm_3_4+bf_u1+bf_1_2+bf_3_4
gen pop59b = bm_5+bm_6+bm_7_9+bf_5+bf_6+bf_7_9
gen pop1014b = bm_10_11+bm_12_13+bm_14+bf_10_11+bf_12_13+bf_14
gen pop1519b = bm_15+bm_16+bm_17+bm_18+bm_19+bf_15+bf_16+bf_17+bf_18+bf_19
gen pop2024b = bm_20+bm_21+bm_22_24+bf_20+bf_21+bf_22_24
gen pop2529b = bm_25_29+bf_25_29
gen pop3034b = bm_30_34+bf_30_34
gen pop3539b = bm_35_39+bf_35_39
gen pop4044b = bm_40_44+bf_40_44
gen pop4549b = bm_45_49+bf_45_49
gen pop5054b = bm_50_54+bf_50_54
gen pop5559b = bm_55_59+bf_55_59
gen pop6064b = bm_60_61+bm_62_64+bf_60_61+bf_62_64
gen pop6569b = bm_65_69+bf_65_69
gen pop7074b = bm_70_74+bf_70_74
gen pop75upb = bm_70_79+bm_80_84+bm_85p+bf_70_79+bf_80_84+bf_85p

gen inct = aginc15upt/(pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop7074t+pop75upt)
gen incw = aginc15upw/(pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop7074w+pop75upw)
gen incb = aginc15upb/(pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop7074b+pop75upb)

gen incdt = pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop7074t+pop75upt
gen incdw = pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop7074w+pop75upw
gen incdb = pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop7074b+pop75upb

egen white = rsum(wm* wf*)
egen black = rsum(bm* bf*)
gen other = totpop90-white-black
rename totpop90 pop

** drop # of kindergartners
drop publick* privatek* publiccol* privatecol*
#delimit ;
keep statefips cntyfips tract areakey white black other pop pop*t pop*w pop*b 
inc* pri*b pri*w pri*t pub*b pub*w pub*t areakey;
#delimit cr
gen year=1990
sort statefips cntyfips tract 
save temp90t.dta, replace

/*** 4b. 1990 Counties
The /cen90/cnty90.dta data set has age distribution while
the stf4c data has school attendance ***/

use ../data/cen90/cnty90.dta
gen statefips = int(real(areakey)/1000)
gen cntyfips = real(areakey)-1000*statefips

** Merge on the 1990 stf4c data
sort statefips cntyfips 
merge statefips cntyfips using ../data/cenpan/cntys90.dta
tab _merge
drop _merge

gen pop04t = ageu1+age1_2+age3_4
gen pop59t = age5+age6+age7_9
gen pop1014t = age10_11+age12_13+age14
gen pop1519t = age15+age16+age17+age18+age19
gen pop2024t = age20+age21+age22_24
gen pop2529t = age25_29
gen pop3034t = age30_34
gen pop3539t = age35_39
gen pop4044t = age40_44
gen pop4549t = age45_49
gen pop5054t = age50_54
gen pop5559t = age55_59
gen pop6064t = age60_61+age62_64
gen pop6569t = age65_69
gen pop7074t = age70_74
*** age70_79 is Geolytics' name for age7579
gen pop75upt = age70_79+age80_84+age85p

gen pop04w = wm_u1+wm_1_2+wm_3_4+wf_u1+wf_1_2+wf_3_4
gen pop59w = wm_5+wm_6+wm_7_9+wf_5+wf_6+wf_7_9
gen pop1014w = wm_10_11+wm_12_13+wm_14+wf_10_11+wf_12_13+wf_14
gen pop1519w = wm_15+wm_16+wm_17+wm_18+wm_19+wf_15+wf_16+wf_17+wf_18+wf_19
gen pop2024w = wm_20+wm_21+wm_22_24+wf_20+wf_21+wf_22_24
gen pop2529w = wm_25_29+wf_25_29
gen pop3034w = wm_30_34+wf_30_34
gen pop3539w = wm_35_39+wf_35_39
gen pop4044w = wm_40_44+wf_40_44
gen pop4549w = wm_45_49+wf_45_49
gen pop5054w = wm_50_54+wf_50_54
gen pop5559w = wm_55_59+wf_55_59
gen pop6064w = wm_60_61+wm_62_64+wf_60_61+wf_62_64
gen pop6569w = wm_65_69+wf_65_69
gen pop7074w = wm_70_74+wf_70_74
gen pop75upw = wm_70_79+wm_80_84+wm_85p+wf_70_79+wf_80_84+wf_85p

gen pop04b = bm_+bm_1_2+bm_3_4+bf_u1+bf_1_2+bf_3_4
gen pop59b = bm_5+bm_6+bm_7_9+bf_5+bf_6+bf_7_9
gen pop1014b = bm_10_11+bm_12_13+bm_14+bf_10_11+bf_12_13+bf_14
gen pop1519b = bm_15+bm_16+bm_17+bm_18+bm_19+bf_15+bf_16+bf_17+bf_18+bf_19
gen pop2024b = bm_20+bm_21+bm_22_24+bf_20+bf_21+bf_22_24
gen pop2529b = bm_25_29+bf_25_29
gen pop3034b = bm_30_34+bf_30_34
gen pop3539b = bm_35_39+bf_35_39
gen pop4044b = bm_40_44+bf_40_44
gen pop4549b = bm_45_49+bf_45_49
gen pop5054b = bm_50_54+bf_50_54
gen pop5559b = bm_55_59+bf_55_59
gen pop6064b = bm_60_61+bm_62_64+bf_60_61+bf_62_64
gen pop6569b = bm_65_69+bf_65_69
gen pop7074b = bm_70_74+bf_70_74
gen pop75upb = bm_70_79+bm_80_84+bm_85p+bf_70_79+bf_80_84+bf_85p

gen inct = aginc15upt/(pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt)
gen incw = aginc15upw/(pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw)
gen incb = aginc15upb/(pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb)

gen incdt = pop1519t+pop2024t+pop2529t+pop3034t+pop3539t+pop4044t+pop4549t+pop5054t+pop5559t+pop6064t+pop6569t+pop7074t+pop75upt
gen incdw = pop1519w+pop2024w+pop2529w+pop3034w+pop3539w+pop4044w+pop4549w+pop5054w+pop5559w+pop6064w+pop6569w+pop7074w+pop75upw
gen incdb = pop1519b+pop2024b+pop2529b+pop3034b+pop3539b+pop4044b+pop4549b+pop5054b+pop5559b+pop6064b+pop6569b+pop7074b+pop75upb

egen white = rsum(wm* wf*)
egen black = rsum(bm* bf*)
gen other = totpop90-white-black
rename totpop90 pop

*** Calculate area in sq km
gen area = arealand/1000

drop publick* privatek* publiccol* privatecol*
#delimit ;
keep statefips cntyfips white black other pop pop*t pop*w pop*b 
pri*b pri*w pri*t pub*b pub*w pub*t inc* area;
#delimit cr
gen year=1990
sort statefips cntyfips
save temp90c.dta, replace


*********** 5. Create Panels of MSAs and Tracts ***********

**** 5a. MSAs

append using temp80c.dta
append using temp70c.dta
append using temp60c.dta

*** Assign MSA codes and collapse
run ../data/xwalk/msa-code.do
** Add Worcester, MA
replace msa = 9240 if statefips==25 & cntyfips==27

compress
sort statefips cntyfips
save ../data/cntypan.dta, replace

drop if msa==-9

*** Calculate income variables for years other than 1960
egen totincw = sum(incdw), by(msa year)
egen totincb = sum(incdb), by(msa year)
egen totinct = sum(incdt), by(msa year)
replace incw = incw*(incdw/totincw)
replace incb = incb*(incdb/totincb)
replace inct = inct*(incdt/totinct)
drop totinc*

collapse (sum) area white black other pop *t *w *b finc* emp*, by(msa year)

** Calculate 1960 incomes
*** Calculate median family income
gen xincdt = fincu1k+finc1k2k+finc2k3k+finc3k4k+finc4k5k+finc5k6k+finc6k7k+finc7k8k+finc8k9k+finc9k10k+finc10k15k+finc15k25k+finco25k
*** For the purpose of incomes, assume that black and other are the same
gen xincdb = fincou1k+finco1k2k+finco2k3k+finco3k4k+finco4k5k+finco5k6k+finco6k7k+finco7k8k+finco8k9k+finco9k10k+fincoo10k
gen xincdw = xincdt-xincdb

gen pu1k = fincu1k/xincdt
gen p1k2k = finc1k2k/xincdt
gen p2k3k = finc2k3k/xincdt
gen p3k4k = finc3k4k/xincdt
gen p4k5k = finc4k5k/xincdt
gen p5k6k = finc5k6k/xincdt
gen p6k7k = finc6k7k/xincdt
gen p7k8k = finc7k8k/xincdt
gen p8k9k = finc8k9k/xincdt
gen p9k10k = finc9k10k/xincdt
gen p10k15k = finc10k15k/xincdt
gen p15k25k = finc15k25k/xincdt
gen po25k = finco25k/xincdt
gen xinct = .
#delimit ;
replace xinct = 1000*.5/pu1k if xinct==. & pu1k>=.5;
replace xinct = 1000+1000*(.5-pu1k)/p1k2k if xinct==. & pu1k+p1k2k>=.5;
replace xinct = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xinct==. & pu1k+p1k2k+p2k3k>=.5;
replace xinct = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xinct==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xinct = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xinct = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xinct = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xinct = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xinct = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xinct = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xinct = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/p10k15k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k>=.5;
replace xinct = 15000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k)/p15k25k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k>=.5;
replace xinct = 25000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k-p15k25k)/po25k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k+po25k>=.5;
#delimit cr

drop p*k*
gen pu1k = fincou1k/xincdb
gen p1k2k = finco1k2k/xincdb
gen p2k3k = finco2k3k/xincdb
gen p3k4k = finco3k4k/xincdb
gen p4k5k = finco4k5k/xincdb
gen p5k6k = finco5k6k/xincdb
gen p6k7k = finco6k7k/xincdb
gen p7k8k = finco7k8k/xincdb
gen p8k9k = finco8k9k/xincdb
gen p9k10k = finco9k10k/xincdb
gen po10k = fincoo10k/xincdb
gen xincb = .
#delimit ;
replace xincb = 1000*.5/pu1k if xincb==. & pu1k>=.5;
replace xincb = 1000+1000*(.5-pu1k)/p1k2k if xincb==. & pu1k+p1k2k>=.5;
replace xincb = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xincb==. & pu1k+p1k2k+p2k3k>=.5;
replace xincb = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xincb==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xincb = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xincb = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xincb = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xincb = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xincb = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xincb = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xincb = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;
#delimit cr

drop p*k*
gen pu1k = (fincu1k-fincou1k)/xincdw
gen p1k2k = (finc1k2k-finco1k2k)/xincdw
gen p2k3k = (finc2k3k-finco2k3k)/xincdw
gen p3k4k = (finc3k4k-finco3k4k)/xincdw
gen p4k5k = (finc4k5k-finco4k5k)/xincdw
gen p5k6k = (finc5k6k-finco5k6k)/xincdw
gen p6k7k = (finc6k7k-finco6k7k)/xincdw
gen p7k8k = (finc7k8k-finco7k8k)/xincdw
gen p8k9k = (finc8k9k-finco8k9k)/xincdw
gen p9k10k = (finc9k10k-finco9k10k)/xincdw
gen po10k = (finc10k15k+finc15k25k+finco25k-fincoo10k)/xincdw
gen xincw = .
#delimit ;
replace xincw = 1000*.5/pu1k if xincw==. & pu1k>=.5;
replace xincw = 1000+1000*(.5-pu1k)/p1k2k if xincw==. & pu1k+p1k2k>=.5;
replace xincw = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xincw==. & pu1k+p1k2k+p2k3k>=.5;
replace xincw = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xincw==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xincw = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xincw = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xincw = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xincw = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xincw = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xincw = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xincw = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;

#delimit cr 
replace inct = xinct if year==1960
replace incb = xincb if year==1960
replace incw = xincw if year==1960
replace incdt = xincdt if year==1960
replace incdw = xincdw if year==1960
replace incdb = xincdb if year==1960
drop xinc* p*k* finc*

** Fill in areas from 1990
sort msa year
by msa: replace area = area[_N]

*** Rename variables
rename area marea
rename pop04t mpop04t
rename pop59t mpop59t
rename pop1014t mpop1014t
rename pop1519t mpop1519t
rename pop2024t mpop2024t
rename pop2529t mpop2529t
rename pop3034t mpop3034t
rename pop3539t mpop3539t
rename pop4044t mpop4044t
rename pop4549t mpop4549t
rename pop5054t mpop5054t
rename pop5559t mpop5559t
rename pop6064t mpop6064t
rename pop6569t mpop6569t
rename pop7074t mpop7074t
rename pop75upt mpop75upt

rename pop04w mpop04w
rename pop59w mpop59w
rename pop1014w mpop1014w
rename pop1519w mpop1519w
rename pop2024w mpop2024w
rename pop2529w mpop2529w
rename pop3034w mpop3034w
rename pop3539w mpop3539w
rename pop4044w mpop4044w
rename pop4549w mpop4549w
rename pop5054w mpop5054w
rename pop5559w mpop5559w
rename pop6064w mpop6064w
rename pop6569w mpop6569w
rename pop7074w mpop7074w
rename pop75upw mpop75upw

rename pop04b mpop04b
rename pop59b mpop59b
rename pop1014b mpop1014b
rename pop1519b mpop1519b
rename pop2024b mpop2024b
rename pop2529b mpop2529b
rename pop3034b mpop3034b
rename pop3539b mpop3539b
rename pop4044b mpop4044b
rename pop4549b mpop4549b
rename pop5054b mpop5054b
rename pop5559b mpop5559b
rename pop6064b mpop6064b
rename pop6569b mpop6569b
rename pop7074b mpop7074b
rename pop75upb mpop75upb

rename emp memp
rename empman mempman

rename white mwhite
rename black mblack
rename other mother
rename incw mincw
rename incb mincb
rename inct minct
replace mincw = . if mincw==0
replace mincb = . if mincb==0
replace minct = . if minct==0
rename incdw mincdw
rename incdb mincdb
rename incdt mincdt
rename publicelemb mpublicelemb
rename privatelemb mprivatelemb
rename publichsb mpublichsb
rename privatehsb mprivatehsb
rename publicelemw mpublicelemw
rename privatelemw mprivatelemw
rename publichsw mpublichsw
rename privatehsw mprivatehsw
rename publicelemt mpublicelemt
rename privatelemt mprivatelemt
rename publichst mpublichst
rename privatehst mprivatehst
rename publicelemhsw mpublicelemhsw
rename privatelemhsw mprivatelemhsw
rename publicelemhsb mpublicelemhsb
rename privatelemhsb mprivatelemhsb
rename publicelemhst mpublicelemhst
rename privatelemhst mprivatelemhst

** Do final fixes for MSA dataset
drop pop
gen mpop=mwhite+mblack+mother

** Recode to . many of the 0s
mvdecode mpublicelemhs? mprivatelemhs? if year<1990, mv(0)
mvdecode mpublicelem? mprivatelem? mpublichs? mprivatehs? if year==1990, mv(0)
replace mincdt = . if minct==.
replace mincdw = . if minct==.
replace mincdb = . if minct==.

compress
sort msa year
save ../data/msapan.dta, replace

**** 5b. Central Cities and School Districts

/** This data set has the place codes for all central districts
Use to generate the sample of MSAs. **/
use ../gis/cbd-schdis.dta
gen statefips = real(first_stat)
gen place = real(first_plac)
do ../data/xwalk/place-change-code60.do

** Get names and placefips codes
keep statefips place 
sort statefips place 
merge statefips place using ../data/xwalk/place-codes.dta
tab _merge
keep if _merge==3
drop _merge

** Assign MSAs
do ../data/xwalk/cc-code.do
** Worcester, MA
replace msa = 9240 if statefips==25 & placefips==82000
drop if msa==-9
compress
sort msa 
save ccsamp.dta, replace

**** Organize CC School Districts
*2000 School Districts of Central Cities
use ../gis/cbd-schdis.dta
gen sdu_st = real(state)
gen sdu_code = real(sd_u)
gen sds_st = real(state_1)
gen sds_code = real(sd_s)
replace area = area_1 if sdu_code==. 
keep area sdu_st sdu_code sds_st sds_code
sort sdu_st sdu_code sds_st sds_code
save tempccs.dta, replace 

use ../gis/cbd-schdis.dta
/** 1970 Central District Codes -- Add 5 that were not tracted in 1970
or not in the school district data **/
replace stdis = 1201080 if first_name=="Fort Myers" 
replace stdis = 1201590 if first_name=="Lakeland"
replace stdis = 2201290 if first_name=="Alexandria, LA" 
replace stdis = 2201740 if first_name=="Houma, LA" 
replace stdis = 2400090 if first_name=="Baltimore" 
rename stdis sdu70
rename stdis_1 sds70
replace area70 = area70_1 if sdu70==0
replace area70 = . if area70==0
replace sdu70 = . if sdu70==0
replace sds70 = . if sds70==0

*** These are untracted CC areas in 1970
keep sdu70 sds70 area70
sort sdu70 sds70
save tempccs70.dta, replace 


**** 5c. Tracts

use temp90t
append using temp80t
append using temp70t
append using temp60t

*** Add some 0s for missing values when possible
mvencode pop*t pub*t pri*t if pop==0, mv(0) override
mvencode pop*w pub*w pri*w if white==0, mv(0) override
mvencode pop*b pub*b pri*b if black==0, mv(0) override

**** Add MSA codes
gen stfip = statefips
gen cnfip = cntyfips
do ../data/xwalk/msa-code.do
** Worcester, MA
replace msa = 9240 if statefips==25 & cntyfips==27 
drop if msa==-9
drop statefips cntyfips
rename stfip statefips
rename cnfip cntyfips

** Merge on GIS Data Identifying School Districts (1970 & 2000 defn) of Each Tract
gen ststr = string(statefips)
replace ststr = "0"+string(statefips) if statefips<10
gen cntystr = string(cntyfips)
replace cntystr = "0"+string(cntyfips) if cntyfips<100
replace cntystr = "00"+string(cntyfips) if cntyfips<10
gen trstr = string(tract*100)
replace trstr = "0"+string(tract*100) if tract<1000
replace trstr = "00"+string(tract*100) if tract<100
replace trstr = "000"+string(tract*100) if tract<10
replace areakey = ststr+cntystr+trstr if year>1960
drop ststr cntystr trstr
sort areakey year
merge areakey year using ../gis/panel-seggisx.dta

*** Drop AK, HI
drop if statefips==2|statefips==15

*** Fix one tract omitted from 70 tract GIS data
replace sdu70 = 4809660 if areakey=="48245001400"
replace sdu70 = 4809660 if areakey=="482450B0014"

*** Fill Out Crews of Vessels indicator
replace cv = 0 if cv==.
replace cv = 1 if substr(areakey,-2,2)=="99" & year>=1970
tab _merge year
sort year areakey
/*** 1s are tracts without spatial data
One fall river, ma tract in 1960
One St. Bernard Parish, LA tract in 1970
Numerous crews of vessels tracts in later years
***/
replace pop = white+black+other
l year areakey pop if _merge==1
*** Put these tracts at the edge of metro areas as none of them are in central districts
replace cbd_dis = 999999 if _merge==1
/*** 2s are tracts with no demographic info (1960), no population (1970)
or missing from the stf4 tract data (1980) ***/
l year areakey if _merge==2
*** 2s are tracts with too little population or missing from 1960 tract data
drop if _merge==2
drop _merge

*** Assign CC Sample for 2000 data
sort sdu_st sdu_code sds_st sds_code 
merge sdu_st sdu_code sds_st sds_code using tempccs.dta
tab _merge year

** Dummy for in Central U/S 2000-defn School District
gen ccdis = 1
replace ccdis = 0 if _merge==1
drop _merge

*** Assign CC sample for 1970 Data
sort sdu70 sds70 
merge sdu70 sds70 using tempccs70.dta
tab _merge
** These are districts not tracted in 1970
drop if _merge==2

** Dummy for in Central U/S 1970-defn School District
gen ccdis70 = 1
replace ccdis70 = 0 if _merge==1
drop _merge

** These were missed in 1970 Only
** 
replace ccdis70 = 1 if statefips==24 & cntyfips==510
replace sdu70 = 2400090 if statefips==24 & cntyfips==510
** Alexandria & Ft. Myers not tracted in 70 - but both county/MSA districts
replace ccdis70 = 1 if msa==220 | msa==2700
replace sdu70 = 1201080 if msa==220
replace sdu70 = 2201290 if msa==2700
** Lakeland, FL and Houma, LA county districts also partially/not tracted in 70 
replace ccdis70 = 1 if msa==3980 
replace sdu70 = 1201590 if msa==3980
replace ccdis70 = 1 if statefips==22 & cntyfips==109
replace sdu70 = 2201740 if statefips==22 & cntyfips==109

*** Identify county districts
gen cntydis = 0
#delimit ;
replace cntydis = 1 if
(statefips==12 & cntyfips==71)
|(statefips==22 & cntyfips==79)
|(statefips==22 & cntyfips==109)
|(statefips==12 & cntyfips==9)
|(statefips==12 & cntyfips==11)
|(statefips==12 & cntyfips==99)
|(statefips==12 & cntyfips==105)
|(statefips==12 & cntyfips==127)
|(statefips==13 & cntyfips==95)
|(statefips==22 & cntyfips==19)
|(statefips==37 & cntyfips==129)
/** Roanoake City Annexed Land b/t 70 and 80**/
|(statefips==51 & cntyfips==770 & year<=1970)
|(statefips==1 & cntyfips==97)
|(statefips==1 & cntyfips==101)
|(statefips==6 & cntyfips==75)
|(statefips==11 & cntyfips==1)
|(statefips==12 & cntyfips==31)
|(statefips==12 & cntyfips==57)
|(statefips==12 & (cntyfips==25|cntyfips==86))
|(statefips==12 & cntyfips==95)
|(statefips==13 & cntyfips==21)
|(statefips==13 & cntyfips==51)
|(statefips==13 & cntyfips==215)
|(statefips==13 & cntyfips==245)
|(statefips==18 & cntyfips==163)
|(statefips==18 & cntyfips==167)
|(statefips==21 & cntyfips==67)
|(statefips==22 & cntyfips==17)
|(statefips==22 & cntyfips==33)
|(statefips==22 & cntyfips==71)
|(statefips==24 & cntyfips==510)
|(statefips==29 & cntyfips==510)
|(statefips==32 & cntyfips==3)
|(statefips==35 & cntyfips==1)
|(statefips==36 & cntyfips==5)
|(statefips==36 & cntyfips==47)
|(statefips==36 & cntyfips==61)
|(statefips==36 & cntyfips==81)
|(statefips==36 & cntyfips==85)
|(statefips==37 & cntyfips==119)
|(statefips==42 & cntyfips==101)
|(statefips==45 & cntyfips==19)
|(statefips==47 & cntyfips==37)
|(statefips==48 & cntyfips==135)
|(statefips==51 & cntyfips==710)
/**Richmond City Annexed Land Between 60 and 70 ***/
|(statefips==51 & cntyfips==760 & year>=1970)
|(statefips==54 & cntyfips==11)
|(statefips==54 & cntyfips==39)
|(statefips==54 & cntyfips==69);
#delimit cr

/*** Assign all tracts in each county-level district to 
the same district in case the gis merge didn't work well or
because of errors to the 1970 sd relationship file  
(All but 7 cases have 0 pop or are miscodes in NYC.)***/
** 1970 Districts
egen modedis = mode(sdu70), by(statefips cntyfips year)
** This shows that all central districts only have one mode
sum modedis cntydis if cntydis==1
egen modediss = mode(sds70), by(statefips cntyfips year)
replace sdu70 = modedis if cntydis==1
replace sds70 = modediss if cntydis==1
replace ccdis70 = 1 if cntydis==1
/** Put tracts outside of county districts outside of 
central districts.  These cases occur because the clip to 70
boundaries we did created some small fractions of 1980 and 1990
tracts outside of 1970 tracted areas left due to imprecision 
in the GIS data.  Because these are on the edge of metro areas, they
will not matter once this central district adjustment is done. ***/
egen maxcntydis = max(cntydis), by(msa year)
replace ccdis70 = 0 if cntydis==0 & maxcntydis==1

** 1990 Districts
egen modesdu = mode(sdu_code), by(statefips cntyfips year)
** This shows that all central districts only have one mode
sum modesdu cntydis if cntydis==1
egen modesds = mode(sds_code), by(statefips cntyfips year)
egen modesdust = mode(sdu_st), by(statefips cntyfips year)
egen modesdsst = mode(sds_st), by(statefips cntyfips year)
egen modesduname = mode(sdu_name), by(statefips cntyfips year)
egen modesdsname = mode(sds_name), by(statefips cntyfips year)
replace sdu_code = modesdu if cntydis==1
replace sds_code = modesds if cntydis==1
replace sdu_st = modesdust if cntydis==1
replace sds_st = modesdsst if cntydis==1
replace sdu_name = modesduname if cntydis==1
replace sds_name = modesdsname if cntydis==1
replace ccdis = 1 if cntydis==1
replace ccdis = 0 if cntydis==0 & maxcntydis==1

*** Limit to Sample of relevant MSAs
sort msa
merge msa using ccsamp.dta
tab _merge
keep if _merge==3
drop _merge

drop pop mode*

sort msa year areakey
compress
save ../data/tractpanx.dta, replace


********************** 6. Create Derived Data Sets from Tracts Data ******************

****** 6a. Create 2000 Unified/Secondary School District Defn Data Set

use ../data/tractpanx.dta

** Keep only populated tracts in central districts that are not "Crews of Vessels"
keep if ccdis==1
drop if cv==1
drop if white+black+other==0

** Drop central districts not fully tracted in given year
drop if statefips==1 & cntyfips==97 & year==1960
drop if statefips==12 & cntyfips==31 & year==1960
drop if statefips==12 & cntyfips==105 & year==1970
drop if statefips==32 & cntyfips==3 & year==1960

*** Assign school district codes
gen sd_code = sdu_code
tab areaname if sd_code==.
replace sd_code = sds_code if sd_code==.
gen sd_st = sdu_st
replace sd_st = sds_st if sd_st==.
gen sd_name = sdu_name
replace sd_name = sds_name if sd_name==""

*** Make the collapse create mean incomes by forming weighted averages
egen totdw = sum(incdw), by(msa mname sd_st sd_code sd_name year)
egen totdb = sum(incdb), by(msa mname sd_st sd_code sd_name year)
egen totdt = sum(incdt), by(msa mname sd_st sd_code sd_name year)
replace incw = incw*(incdw/totdw)
replace incb = incb*(incdb/totdb)
replace inct = inct*(incdt/totdt)

sort msa mname
by msa: replace mname = mname[_N]

collapse (sum) white black other pub* pri* pop*w pop*b pop*t incw incb inct incdw incdb incdt finc* (mean) area, by(msa mname sd_st sd_code sd_name year)

** Calculate 1960 incomes
*** Calculate median family income
gen xincdt = fincu1k+finc1k2k+finc2k3k+finc3k4k+finc4k5k+finc5k6k+finc6k7k+finc7k8k+finc8k9k+finc9k10k+finc10k15k+finc15k25k+finco25k
*** For the purpose of incomes, assume that black and other are the same
gen xincdb = fincou1k+finco1k2k+finco2k3k+finco3k4k+finco4k5k+finco5k6k+finco6k7k+finco7k8k+finco8k9k+finco9k10k+fincoo10k
gen xincdw = xincdt-xincdb

gen pu1k = fincu1k/xincdt
gen p1k2k = finc1k2k/xincdt
gen p2k3k = finc2k3k/xincdt
gen p3k4k = finc3k4k/xincdt
gen p4k5k = finc4k5k/xincdt
gen p5k6k = finc5k6k/xincdt
gen p6k7k = finc6k7k/xincdt
gen p7k8k = finc7k8k/xincdt
gen p8k9k = finc8k9k/xincdt
gen p9k10k = finc9k10k/xincdt
gen p10k15k = finc10k15k/xincdt
gen p15k25k = finc15k25k/xincdt
gen po25k = finco25k/xincdt
gen xinct = .
#delimit ;
replace xinct = 1000*.5/pu1k if xinct==. & pu1k>=.5;
replace xinct = 1000+1000*(.5-pu1k)/p1k2k if xinct==. & pu1k+p1k2k>=.5;
replace xinct = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xinct==. & pu1k+p1k2k+p2k3k>=.5;
replace xinct = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xinct==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xinct = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xinct = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xinct = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xinct = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xinct = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xinct = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xinct = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/p10k15k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k>=.5;
replace xinct = 15000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k)/p15k25k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k>=.5;
replace xinct = 25000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k-p15k25k)/po25k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k+po25k>=.5;
#delimit cr

drop p*k*
gen pu1k = fincou1k/xincdb
gen p1k2k = finco1k2k/xincdb
gen p2k3k = finco2k3k/xincdb
gen p3k4k = finco3k4k/xincdb
gen p4k5k = finco4k5k/xincdb
gen p5k6k = finco5k6k/xincdb
gen p6k7k = finco6k7k/xincdb
gen p7k8k = finco7k8k/xincdb
gen p8k9k = finco8k9k/xincdb
gen p9k10k = finco9k10k/xincdb
gen po10k = fincoo10k/xincdb
gen xincb = .
#delimit ;
replace xincb = 1000*.5/pu1k if xincb==. & pu1k>=.5;
replace xincb = 1000+1000*(.5-pu1k)/p1k2k if xincb==. & pu1k+p1k2k>=.5;
replace xincb = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xincb==. & pu1k+p1k2k+p2k3k>=.5;
replace xincb = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xincb==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xincb = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xincb = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xincb = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xincb = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xincb = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xincb = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xincb = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;
#delimit cr

drop p*k*
gen pu1k = (fincu1k-fincou1k)/xincdw
gen p1k2k = (finc1k2k-finco1k2k)/xincdw
gen p2k3k = (finc2k3k-finco2k3k)/xincdw
gen p3k4k = (finc3k4k-finco3k4k)/xincdw
gen p4k5k = (finc4k5k-finco4k5k)/xincdw
gen p5k6k = (finc5k6k-finco5k6k)/xincdw
gen p6k7k = (finc6k7k-finco6k7k)/xincdw
gen p7k8k = (finc7k8k-finco7k8k)/xincdw
gen p8k9k = (finc8k9k-finco8k9k)/xincdw
gen p9k10k = (finc9k10k-finco9k10k)/xincdw
gen po10k = (finc10k15k+finc15k25k+finco25k-fincoo10k)/xincdw
gen xincw = .
#delimit ;
replace xincw = 1000*.5/pu1k if xincw==. & pu1k>=.5;
replace xincw = 1000+1000*(.5-pu1k)/p1k2k if xincw==. & pu1k+p1k2k>=.5;
replace xincw = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xincw==. & pu1k+p1k2k+p2k3k>=.5;
replace xincw = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xincw==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xincw = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xincw = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xincw = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xincw = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xincw = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xincw = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xincw = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;

#delimit cr 
replace inct = xinct if year==1960
replace incb = xincb if year==1960
replace incw = xincw if year==1960
replace incdt = xincdt if year==1960
replace incdw = xincdw if year==1960
replace incdb = xincdb if year==1960
drop xinc* p*k* finc*

sort msa year
save ../data/dis00panx.dta, replace

******** 6b. Create 1970 Unified/Secondary School District Defn Data Set

use ../data/tractpanx.dta

*** Keep only populated tracts in central districts that are not "crews of vessels"
keep if ccdis70==1
drop if cv==1
drop if white+black+other==0

** Drop central districts not fully tracted in given year
drop if statefips==1 & cntyfips==97 & year==1960
drop if statefips==12 & cntyfips==31 & year==1960
drop if statefips==12 & cntyfips==105 & year==1970
drop if statefips==32 & cntyfips==3 & year==1960

*** Assign Unified, then Secondary districts
gen sd70 = sdu70
tab areaname if sd70==.
replace sd70 = sds70 if sd70==.

sort msa mname
by msa: replace mname = mname[_N]

egen totdw = sum(incdw), by(msa mname sd70 year)
egen totdb = sum(incdb), by(msa mname sd70 year)
egen totdt = sum(incdt), by(msa mname sd70 year)
replace incw = incw*(incdw/totdw)
replace incb = incb*(incdb/totdb)
replace inct = inct*(incdt/totdt)

collapse (sum) white black other pub* pri* pop*w pop*b pop*t incw incb inct incdw incdb incdt finc* (mean) area70, by(msa mname sd70 year)

** Calculate 1960 incomes
*** Calculate median family income
gen xincdt = fincu1k+finc1k2k+finc2k3k+finc3k4k+finc4k5k+finc5k6k+finc6k7k+finc7k8k+finc8k9k+finc9k10k+finc10k15k+finc15k25k+finco25k
*** For the purpose of incomes, assume that black and other are the same
gen xincdb = fincou1k+finco1k2k+finco2k3k+finco3k4k+finco4k5k+finco5k6k+finco6k7k+finco7k8k+finco8k9k+finco9k10k+fincoo10k
gen xincdw = xincdt-xincdb

gen pu1k = fincu1k/xincdt
gen p1k2k = finc1k2k/xincdt
gen p2k3k = finc2k3k/xincdt
gen p3k4k = finc3k4k/xincdt
gen p4k5k = finc4k5k/xincdt
gen p5k6k = finc5k6k/xincdt
gen p6k7k = finc6k7k/xincdt
gen p7k8k = finc7k8k/xincdt
gen p8k9k = finc8k9k/xincdt
gen p9k10k = finc9k10k/xincdt
gen p10k15k = finc10k15k/xincdt
gen p15k25k = finc15k25k/xincdt
gen po25k = finco25k/xincdt
gen xinct = .
#delimit ;
replace xinct = 1000*.5/pu1k if xinct==. & pu1k>=.5;
replace xinct = 1000+1000*(.5-pu1k)/p1k2k if xinct==. & pu1k+p1k2k>=.5;
replace xinct = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xinct==. & pu1k+p1k2k+p2k3k>=.5;
replace xinct = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xinct==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xinct = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xinct = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xinct = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xinct = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xinct = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xinct = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xinct = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/p10k15k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k>=.5;
replace xinct = 15000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k)/p15k25k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k>=.5;
replace xinct = 25000+10000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k-p10k15k-p15k25k)/po25k
if xinct==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+p10k15k+p15k25k+po25k>=.5;
#delimit cr

drop p*k*
gen pu1k = fincou1k/xincdb
gen p1k2k = finco1k2k/xincdb
gen p2k3k = finco2k3k/xincdb
gen p3k4k = finco3k4k/xincdb
gen p4k5k = finco4k5k/xincdb
gen p5k6k = finco5k6k/xincdb
gen p6k7k = finco6k7k/xincdb
gen p7k8k = finco7k8k/xincdb
gen p8k9k = finco8k9k/xincdb
gen p9k10k = finco9k10k/xincdb
gen po10k = fincoo10k/xincdb
gen xincb = .
#delimit ;
replace xincb = 1000*.5/pu1k if xincb==. & pu1k>=.5;
replace xincb = 1000+1000*(.5-pu1k)/p1k2k if xincb==. & pu1k+p1k2k>=.5;
replace xincb = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xincb==. & pu1k+p1k2k+p2k3k>=.5;
replace xincb = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xincb==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xincb = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xincb = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xincb = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xincb = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xincb = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xincb = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xincb = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if xincb==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;
#delimit cr

drop p*k*
gen pu1k = (fincu1k-fincou1k)/xincdw
gen p1k2k = (finc1k2k-finco1k2k)/xincdw
gen p2k3k = (finc2k3k-finco2k3k)/xincdw
gen p3k4k = (finc3k4k-finco3k4k)/xincdw
gen p4k5k = (finc4k5k-finco4k5k)/xincdw
gen p5k6k = (finc5k6k-finco5k6k)/xincdw
gen p6k7k = (finc6k7k-finco6k7k)/xincdw
gen p7k8k = (finc7k8k-finco7k8k)/xincdw
gen p8k9k = (finc8k9k-finco8k9k)/xincdw
gen p9k10k = (finc9k10k-finco9k10k)/xincdw
gen po10k = (finc10k15k+finc15k25k+finco25k-fincoo10k)/xincdw
gen xincw = .
#delimit ;
replace xincw = 1000*.5/pu1k if xincw==. & pu1k>=.5;
replace xincw = 1000+1000*(.5-pu1k)/p1k2k if xincw==. & pu1k+p1k2k>=.5;
replace xincw = 2000+1000*(.5-pu1k-p1k2k)/p2k3k if xincw==. & pu1k+p1k2k+p2k3k>=.5;
replace xincw = 3000+1000*(.5-pu1k-p1k2k-p2k3k)/p3k4k if xincw==. & pu1k+p1k2k+p2k3k+p3k4k>=.5;
replace xincw = 4000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k)/p4k5k if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k>=.5;
replace xincw = 5000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k)/p5k6k 
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k>=.5;
replace xincw = 6000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k)/p6k7k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k>=.5;
replace xincw = 7000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k)/p7k8k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k>=.5;
replace xincw = 8000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k)/p8k9k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k>=.5;
replace xincw = 9000+1000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k)/p9k10k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k>=.5;
replace xincw = 10000+5000*(.5-pu1k-p1k2k-p2k3k-p3k4k-p4k5k-p5k6k-p6k7k-p7k8k-p8k9k-p9k10k)/po10k
if xincw==. & pu1k+p1k2k+p2k3k+p3k4k+p4k5k+p5k6k+p6k7k+p7k8k+p8k9k+p9k10k+po10k>=.5;

#delimit cr 
replace inct = xinct if year==1960
replace incb = xincb if year==1960
replace incw = xincw if year==1960
replace incdt = xincdt if year==1960
replace incdw = xincdw if year==1960
replace incdb = xincdb if year==1960
drop xinc* p*k* finc*

save ../data/dis70panx.dta, replace


*********** 7. Perform Final Data Set Consolidation ******************

/**** 7a. Build county-level district data 
1)  were not tracted in 1960 and 1970 (first 3)
2) the county level districts not tracted in 1960 (next 9)
3) those tracted in all years (remaining) **/
use temp60c.dta
append using temp70c.dta
append using temp80c.dta
append using temp90c.dta 
#delimit ;
keep if 
(statefips==12 & cntyfips==71)
|(statefips==22 & cntyfips==79)
|(statefips==22 & cntyfips==109)
|(statefips==12 & cntyfips==9)
|(statefips==12 & cntyfips==11)
|(statefips==12 & cntyfips==99)
|(statefips==12 & cntyfips==105)
|(statefips==12 & cntyfips==127)
|(statefips==13 & cntyfips==95)
|(statefips==22 & cntyfips==19)
|(statefips==37 & cntyfips==129)
/** Roanoake City Annexed Land b/t 70 and 80**/
|(statefips==51 & cntyfips==770 & year<=1970)
|(statefips==1 & cntyfips==97)
|(statefips==1 & cntyfips==101)
|(statefips==6 & cntyfips==75)
|(statefips==11 & cntyfips==1)
|(statefips==12 & cntyfips==31)
|(statefips==12 & cntyfips==57)
|(statefips==12 & (cntyfips==25|cntyfips==86))
|(statefips==12 & cntyfips==95)
|(statefips==13 & cntyfips==21)
|(statefips==13 & cntyfips==51)
|(statefips==13 & cntyfips==215)
|(statefips==13 & cntyfips==245)
|(statefips==18 & cntyfips==163)
|(statefips==18 & cntyfips==167)
|(statefips==21 & cntyfips==67)
|(statefips==22 & cntyfips==17)
|(statefips==22 & cntyfips==33)
|(statefips==22 & cntyfips==71)
|(statefips==24 & cntyfips==510)
|(statefips==29 & cntyfips==510)
|(statefips==32 & cntyfips==3)
|(statefips==35 & cntyfips==1)
/**Take out NYC b/c multi-county and not in final sample**/
|(statefips==37 & cntyfips==119)
|(statefips==42 & cntyfips==101)
|(statefips==45 & cntyfips==19)
|(statefips==47 & cntyfips==37)
|(statefips==48 & cntyfips==135)
|(statefips==51 & cntyfips==710)
|(statefips==51 & cntyfips==760 & year>=1970)
|(statefips==54 & cntyfips==11)
|(statefips==54 & cntyfips==39)
|(statefips==54 & cntyfips==69);
#delimit cr

/** We want to if possible use the same tabulation
type to measure districts over time.  Only use county
tabulations if we are able to use them for all 4 periods. 
Drop counties that have missing info in 1960.**/
sort statefips cntyfips year
by statefips cntyfips: drop if publicelemt[1]==.

** Assign msa codes
gen cntydis = 1
do ../data/xwalk/msa-code.do
keep msa year white black other *w *b *t cntydis area
gen popc=white+black+other
drop *nw
sort msa year

*** We only observe area in 1990
by msa: replace area = area[_N]
gen area70 = area
save newdisc.dta, replace

** 7b. Build final version of dis70pan.dta 

** Use county data in all years for untracted counties in 1960
use ../data/dis70panx.dta,clear
sort msa year
merge msa year using newdisc.dta, update 
tab _merge year
replace cntydis = 0 if _merge==1
drop _merge

replace area = area70 if area==.
drop area70

*** Merge on District data
sort msa year
merge msa year using ../data/districtpan.dta
tab _merge
** Merge = 1 is MSAs without desegregation data on central districts
** Merge=2 is non-county central districts from 1960: Lawton, Amarillo & Modesto
drop _merge

*** Merge on 1960 Amarillo and Lawton data
sort leaid year
merge leaid year using am_law_agex.dta, update
tab _merge
replace cntydis = 0 if _merge==3
drop _merge

*** Merge on 1960 Income Data
sort leaid year
merge leaid year using tempinc60.dta, update
tab _merge
drop _merge

*** This is for districts without tract data in 1970
replace sd70 = leaid if sd70==.

*** Merge on MSA data
sort msa year
merge msa year using ../data/msapan.dta
tab _merge year
keep if _merge==3
drop _merge

*** Fix Areas
sort msa year
by msa: replace area = area[_N]
replace area = marea if area>marea & area~=.
*** Decode to missing values b/c of different variable defns in different years
mvdecode publicelemhs* privatelemhs* if year<1990, mv(0)
mvdecode publicelemw publicelemb publicelemt privatelemb privatelemw privatelemt if year==1990, mv(0)
mvdecode publichsw publichsb publichst privatehsb privatehsw privatehst if year==1990, mv(0)

*** Do some final cleanup
drop popw popb popt *nw
replace privatehsb = 0 if privatehsw==privatehst & privatehst~=.
replace privatelemb = 0 if privatelemw==privatelemt & privatelemt~=.
replace mprivatehsb = 0 if mprivatehsw==mprivatehst & mprivatehst~=.
replace mprivatelemb = 0 if mprivatelemw==mprivatelemt & mprivatelemt~=.

save ../data/dis70panx.dta, replace

** 7c. Build final version of dis00pan.dta 

use ../data/dis00panx.dta, clear
sort msa year
merge msa year using newdisc.dta, update
tab _merge year
replace cntydis = 0 if _merge==1
drop _merge

*** Merge on district level data
sort msa year
merge msa year using ../data/districtpan.dta
tab _merge
** Merge = 2 is city districts not tracted in 1960
** Merge = 1 is MSAs without desegregation data on central districts
drop _merge

*** Merge on 1960 Amarillo and Lawton data
sort leaid year
merge leaid year using am_law_agex.dta, update
tab _merge
replace cntydis = 0 if _merge==3
drop _merge

*** Merge on 1960 Income Data
sort leaid year
merge leaid year using tempinc60.dta, update
tab _merge
drop _merge

*** Merge on MSA data
sort msa year
merge msa year using ../data/msapan.dta
tab _merge
keep if _merge==3
drop _merge

*** Fix Areas
sort msa year
by msa: replace area = area[_N]
replace area = marea if area>marea & area~=.

*** Decode to missing values b/c of different variable defns in different years
mvdecode publicelemhs* privatelemhs* if year<1990, mv(0)
mvdecode publicelemw publicelemb publicelemt privatelemb privatelemw privatelemt if year==1990, mv(0)
mvdecode publichsw publichsb publichst privatehsb privatehsw privatehst if year==1990, mv(0)

*** Do some final cleanup
drop popw popb popt *nw
replace privatehsb = 0 if privatehsw==privatehst & privatehst~=.
replace privatelemb = 0 if privatelemw==privatelemt & privatelemt~=.
replace mprivatehsb = 0 if mprivatehsw==mprivatehst & mprivatehst~=.
replace mprivatelemb = 0 if mprivatelemw==mprivatelemt & mprivatelemt~=.

save ../data/dis00panx.dta, replace

erase am_law_agex.dta
erase ccsamp.dta
erase temp60c.dta
erase temp60t.dta
erase temp70c.dta
erase temp70t.dta
erase temp80c.dta
erase temp80t.dta
erase temp90c.dta
erase temp90t.dta
erase tempadd.dta
erase tempccs.dta
erase tempccs70.dta
erase tempinc60.dta
erase tempx.dta
erase newdisc.dta


log close

