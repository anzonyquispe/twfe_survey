******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
*********************************************************
* THIS FILE:
*   Appends years 1995-2002 of the ABI
*   Merges Ralf Martin's capital stock estimates for the same period
*   Input:  ARD standard variables data sets
*	      Ralf's capstock_08.dta
*   Output: "all_clean.dta"
*******************************************************

clear 
set mem 500m
/*
gen temp =.
forvalues y=1995(1)1996{
foreach var in cng pdg{
append using "W:\ard_std_vars3\results\pdat`y'`var'.dta"
}
}

forvalues y=1997(1)2003{
foreach var in cng pdg cag mtg prg reg stg whg{
append using "W:\ard_std_vars3\results\pdat`y'`var'.dta"
}
}
drop temp
destring dlink, gen(ruref)
destring dlink, replace
so ruref year
save "wallpaper_2003.dta", replace
*/

cd "H:\Raffaella\ICT\Files_March_07\1.Merge&Clean"
u wallpaper_2003,clear
so ruref year
gen emp=emp_pit
replace emp=emp_ya if year<1997
keep emp year sic92 region ruref  dlink_ref2 gva_mp gva_fc egrp_ref totlabcost emp_ya go ncapex totpurch matfuel intmed indust_services f_own emp_admin telecom_services Computer_services Subsidies emp_pit matpurch Internet_EDI_purchases Internet_EDI_sales Website software_investment
sort  dlink_ref2 year

*last
merge  dlink_ref2 year using "capstock_06_2003.dta"
* keep only selected, with missing or existing capital stock
drop if _m==2
*keep if  _merge==3
 
drop _merge  dlink_ref2
sort ruref year
rename sic92 sic_abi
*replace sic_abi = sic_abi*10 if sic_abi==1421 | sic_abi==1429 | sic_abi==1500 | sic_abi==1410

* Introduce 2003 changes in sic codes
replace sic_abi= 27350 if year==2003 & sic_abi[_n-1]==27350 & sic_abi==27100
replace sic_abi= 40200 if year==2003 & (sic_abi==40210 |sic_abi==40220)
replace sic_abi= 51650 if year==2003 & (sic_abi==51860 |sic_abi==51870)
replace sic_abi= 52482 if year==2003 & sic_abi==52487 
replace sic_abi= 63120 if year==2003 & (sic_abi==63121 |sic_abi==63122 | sic_abi==63123 | sic_abi==63129)
replace sic_abi= 66010 if year==2003 & (sic_abi==66011 |sic_abi==66012)
replace sic_abi= 66030 if year==2003 & (sic_abi==66031 |sic_abi==66032)
replace sic_abi= 72200 if year==2003 & (sic_abi==72210 |sic_abi==72220)
replace sic_abi= 74119 if year==2003 & (sic_abi==74112 |sic_abi==74113 | sic_abi==74119)
gen sic = sic_abi


*****************************************************
* Create dummies for manufacturing and services
*****************************************************
gen sic2=int(sic/1000)
gen sic3=int(sic/100) 
gen sic4=int(sic/10)

gen manuf=0
replace manuf=1 if sic2>=15 & sic2<=37
replace manuf=. if sic2==.

* sic 40 41 and 45 are NOT services
replace manuf=. if sic2==40 | sic2==41 | sic2==45 |sic2==14 | sic2==2 | sic2==11
rename Subsidies _Subsidies

*****************************************************
* Deflators
*****************************************************
* Services
so sic year
merge sic year using "ppi2000s.dta"
drop if _m==2
gen serv_all =. 
replace serv_all=0.993 if year==1996
replace serv_all=0.970 if year==1997
replace serv_all=0.983 if year==1998
replace serv_all=0.982 if year==1999
replace serv_all=1 if year==2000
replace serv_all=1.029 if year==2001
replace serv_all=1.049 if year==2002
replace serv_all=1.077 if year==2003
replace ppi2000s=serv_all if ppi2000s==. & manuf==0
drop serv_all _m
* Missing obs in 1995

* Manufacturing
* Here we have more detailed def, sic4
so sic4 year
merge sic4 year using ppi2000_4dig_clean.dta
drop if _m==2
drop _m
so sic2 year

merge sic2 year using ppi2000m.dta
drop if _m==2
drop _m
gen manuf_all =.
replace manuf_all=0.948 if year==1995
replace manuf_all=0.972 if year==1996
replace manuf_all=0.981 if year==1997
replace manuf_all=0.981 if year==1998
replace manuf_all=0.985 if year==1999
replace manuf_all=1.00 if year==2000
replace manuf_all=0.997 if year==2001
replace manuf_all=0.998 if year==2002
replace manuf_all=1.1013 if year==2003

gen ppi2000=ppi2000_4
replace ppi2000=ppi2000m if ppi2000_4==. & manuf==1
replace ppi2000=manuf_all if ppi2000_4==. & ppi2000m==. & manuf==1
* Use overall manufacturing deflator for sectors such as construction...
replace ppi2000=manuf_all if sic2==45
drop manuf_all  ppi2000_4

* Generate overall deflator
gen def=.
replace def = ppi2000 if manuf==1 
replace def = ppi2000 if sic4==4010 | sic4==4020 | sic4==4100 | sic4==1412 | sic4==1421 | sic4==1440 | sic4==1450
replace def = ppi2000 if sic2==45
replace def = ppi2000s if manuf==0

* This is intended only for sic 40 and 14 (we have some data)
bys sic2 year: egen ave_def=mean(ppi2000) 
replace def = ave_def if def==. & sic2==40 | sic2==14
 
* See if there are duplications after the merge
so ruref year
drop if ruref==ruref[_n-1] & year==year[_n-1]
drop if ruref==ruref[_n+1] & year==year[_n+1]

* Generate deflated output values
gen gva_fc_def = gva_fc/def
gen go_def = go/def


**********************************
* Adding percentage of all multinationals in sic4 
**********************************
so sic4 
merge sic4 using "f_own_all_new.dta"
drop if _m==2
drop _m 

* Regions
ge region2 = region
so ruref year
replace region2=region[_n-1] if region~=region[_n-1] & region==. & region[_n-1]~=. & ruref==ruref[_n-1]
replace region2=region2[_n+1] if region2==. & region2[_n+1]~=.  & ruref==ruref[_n+1]

ge se=region2==1
ge nw=region2==7
ge north=region2==8
ge yorks=region2==6
ge emid=region2==5
ge wmid=region2==4
ge eanglia=region2==2
ge sw=region2==3
ge wales=region2==9
ge scot=region2==10
rename region region_old
rename region2 region
compress
save "temp.dta", replace


clear
set mem 1000m
use "temp.dta", clear
************************************
* Adding group info
************************************
destring egrp_ref, replace
keep ruref year egrp_ref
sort egrp_ref year
merge egrp_ref year using count_dlink_all
drop if _merge==2
drop _merge
so ruref year
save "group.dta", replace

clear
set mem 1000m
use "temp.dta", clear
so ruref year
merge ruref year using "group.dta"
drop _merge
save "temp.dta", replace

*******************************************************
* Adding the register info (age, age_cens and new_egrp_ref)
*******************************************************
keep ruref year
so ruref year
merge ruref year using "register1.dta"
drop if _merge==2
drop _merge
so ruref year
save "all_clean_reg_2.dta", replace

clear
use "temp.dta", clear
so ruref year
merge ruref year using "all_clean_reg_2.dta"
drop _merge
save "temp.dta", replace


****************************************************
* Adding multinational dummy
****************************************************
/*
clear
set mem 500m
use "W:\afdi\results\multinats_panel.dta", clear
replace ownpc1=0 if ownpc1==.
replace ownpc2=0 if ownpc2==.
replace ownpc3=0 if ownpc3==.
replace ownpc4=0 if ownpc4==.
replace ownpc5=0 if ownpc5==.
replace ownpc6=0 if ownpc6==.
gen mult=.
replace mult=0 if (ownpc1+ownpc2+ownpc3+ownpc4+ownpc5+ownpc6)<=50
replace mult=1 if ukmult==1
replace mult=1 if (ownpc1+ownpc2+ownpc3+ownpc4+ownpc5+ownpc6)>=50
keep new_egrp_ref ukmult mult year
so new_egrp_ref year
save "multi.dta", replace
*/

u "temp.dta", clear
so ruref year
drop if ruref==ruref[_n-1] & year==year[_n-1]
drop if ruref==ruref[_n+1] & year==year[_n+1]
so new_egrp_ref year
merge new_egrp_ref year using "multi.dta"
drop if _merge==2
drop _merge
so ruref year
drop if ruref==ruref[_n-1] & year==year[_n-1]
drop if ruref==ruref[_n+1] & year==year[_n+1]


****** Note changes in code in 2003
ge f_own_03=f_own 
so f_own_03
merge f_own_03 using "isocode.dta"
replace f_own=f_own_02 if _m==3
drop if _m==2
drop _m
drop f_own_02 f_own_03
 
****** Note this waiting for afdi 2003: extend 2002 info
so new_egrp_ref year
bys new_egrp_ref: gen mult_2002 = mult if year==2002
bys new_egrp_ref: gen ukmult_2002 = ukmult if year==2002
bys new_egrp_ref: egen max_mult=max(mult_2002)
bys new_egrp_ref: egen max_ukmult=max(ukmult_2002)
replace mult=max_mult if year==2003
replace ukmult=max_ukmult if year==2003
**
so ruref year
bys ruref: drop if year==year[_n-1] 
bys ruref: drop if year==year[_n+1] 
save "temp.dta", replace


****************************************
* Nationality
****************************************
clear
use "temp.dta", clear
gen miss_f=(f_own==.)
replace f_own=783 if f_own==0
replace f_own=783 if f_own==801

* Here create alternative measure with no adjustments for multi check 
gen f_own_noadj=f_own
gen ukmult_noadj=ukmult
gen mult_noadj = mult

* exploit missings between two known
so ruref year
bys ruref: replace f_own=f_own[_n-1] if f_own==. & f_own[_n-1]==f_own[_n+1] & f_own[_n-1]~=. & ruref==ruref[_n-1]
bys ruref: replace f_own=f_own[_n+1] if f_own==. & f_own[_n-1]==f_own[_n+1] & f_own[_n+1]~=. & ruref==ruref[_n+1]

* longer bridge
* forward
so ruref year
bys ruref: replace f_own=f_own[_n-1] if f_own==. & f_own[_n+1]==. & f_own[_n-1]==f_own[_n+2] & f_own[_n-1]~=. & ruref==ruref[_n+2]
bys ruref: replace f_own=f_own[_n-1] if f_own==. & f_own[_n-1]==f_own[_n+1] & f_own[_n-1]~=. & ruref==ruref[_n-1]
so ruref year
replace miss_f=0 if f_own~=.


* Extend latest available info onwards
so ruref year
cap drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
so ruref year
cap drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest
gen latest=f_own[_n-1] if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
replace f_own=latest if f_own==. & f_own[_n-1]~=. & ruref==ruref[_n-1]
drop latest

* Extend backwards
cap drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest
so ruref year
gen latest=f_own[_n+1] if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
replace f_own=latest if f_own==. & f_own[_n+1]~=. & ruref==ruref[_n+1]
drop latest

* Now f_own missings are only for ruref that never have info
replace miss_f=0 if f_own~=.
cap drop max_miss min_miss
bys ruref: egen max_miss=max(miss_f)
bys ruref: egen min_miss=min(miss_f)
*bro ruref year max_m* min_m* f_own if max_miss==1 & min_miss==0 
cap drop max_miss min_miss


* Now exploit enterprise group info
* First by year
bys new_egrp_ref year: egen mode1=mode(f_own), maxmode
replace f_own =mode1 if f_own==. & mode1~=.
gen mi=(mode==.)
bys new_egrp_ref: egen max_mi=max(mi)
bys new_egrp_ref: egen min_mi=min(mi)
*bro new_egrp ruref year f_own mode if max_mi==1 & min_mi==0

* Then by history
bys new_egrp_ref: egen mode2=mode(f_own), max
replace f_own =mode2 if f_own==. & mode2~=.

* Mis-coding
replace f_own=mode1 if f_own~=. & mode1~=.
drop mode* 

replace f_own=783 if f_own==. 
gen for=(f_own~=783)
gen usa=(f_own==805)

* Consistency in multi tags
* Quick check
bys new_egrp_ref year: egen max_for=max(for)
bys new_egrp_ref year: egen min_for=min(for)
*bro new_egrp_ref ruref year f_own if max_for==1 & min_for==0

bys new_egrp_ref year: replace ukmult=0 if ukmult==. & max_for==1
bys new_egrp_ref year: replace ukmult=0 if max_for==1 & ukmult==1 
bys new_egrp_ref year: replace ukmult=0 if ukmult==. 

gen multi=mult
bys new_egrp_ref year: replace multi=0 if ukmult==0 & max_for==0
bys new_egrp_ref year: replace multi=0 if mult==. & max_for==0
bys new_egrp_ref year: replace multi=1 if mult==. & max_for==1
bys new_egrp_ref year: replace multi=1 if ukmult==1 & max_for==0
bys new_egrp_ref year: replace multi=1 if mult==0 & max_for==1

gen du_usa_mu = usa
* gen du_uk_mu = ukmult
* Careful: here I am putting uk and non uk not us together
gen du_oth_mu= multi
replace du_oth_mu=0 if du_usa_mu==1
gen du_dom = (for==0 & multi==0)


* Also for non adjusted variable
replace f_own_noadj=783 if f_own_noadj==. 
gen for_noadj=(f_own_noadj~=783)
gen usa_noadj=(f_own_noadj==805)
* Quick check
bys new_egrp_ref year: egen max_for_noadj=max(for_noadj)
bys new_egrp_ref year: egen min_for_noadj=min(for_noadj)
*bro new_egrp_ref ruref year f_own if max_for==1 & min_for==0

bys new_egrp_ref year: replace ukmult_noadj=0 if ukmult_noadj==.  & max_for_noadj==1
bys new_egrp_ref year: replace ukmult_noadj=0 if max_for_noadj==1 & ukmult_noadj==1 
bys new_egrp_ref year: replace ukmult_noadj=0 if ukmult_noadj==. 

gen multi_noadj=mult_noadj
bys new_egrp_ref year: replace multi_noadj=0 if ukmult_noadj==0 & max_for_noadj==0
bys new_egrp_ref year: replace multi_noadj=0 if mult_noadj==. & max_for_noadj==0
bys new_egrp_ref year: replace multi_noadj=1 if mult_noadj==. & max_for_noadj==1
bys new_egrp_ref year: replace multi_noadj=1 if ukmult_noadj==1 & max_for_noadj==0
bys new_egrp_ref year: replace multi_noadj=1 if mult_noadj==0 & max_for_noadj==1

gen du_usa_mu_noadj = usa_noadj
* gen du_uk_mu = ukmult
* Careful: here I am putting uk and non uk not us together
gen du_oth_mu_noadj= multi_noadj
replace du_oth_mu_noadj=0 if du_usa_mu_noadj==1
gen du_dom_noadj = (for_noadj==0 & multi_noadj==0)
save "temp.dta", replace
 
**********************************
* Truncation for age
**********************************
rename age_cens age_t
bys ruref: egen prob=max(age_t)
replace age_t=1 if prob==1

*****************************************************
** Cleaning the dataset
****************************************************
adopath + "X:\code\ado"
save "temp_before.dta", replace
u "temp_before.dta", replace
count
drop if gva_fc_def<0
drop if gva_fc>go
drop if rcapstk95==.
drop if rcapstk95<0
drop if gva_fc_def==.
drop if emp==0

so ruref year

ge prod=gva_fc_def/emp

local vars "emp gva_fc_def prod"
foreach var of local vars{
		gen `var'_l = `var'[_n-1] if ruref==ruref[_n-1] & `var'~=0 & `var'[_n-1]~=0 & year==year[_n-1]+1
		gen growth_`var' = (`var'-`var'_l)/`var'_l
		xtile trimgro`var' = growth_`var', nq(100)
}

local vars "rcapstk95 gva_fc_def totpurch ncapex"
foreach var of local vars{
				gen `var'_N = `var'/emp	
				xtile trim_`var'_N = `var'_N, nq(100)
}

count
drop if (rcapstk95_N<0.1 | rcapstk95_N>1000) & rcapstk95_N~=.
drop if (gva_fc_def_N<2 | gva_fc_def_N>2000) & gva_fc_def_N~=.

local vars "emp gva_fc_def "
foreach var of local vars{
              	drop  if trimgro`var'<=1 | trimgro`var'>=100 & trimgro`var'~=.
			drop  trimgro`var' 
}

drop gva_fc_def_N
local vars "ncapex totpurch"
foreach var of local vars{
                	replace `var'=.  if trim_`var'_N <=1 | trim_`var'_N >=100 & trim_`var'_N ~=.
			replace `var'_N=. if trim_`var'_N <=1 | trim_`var'_N >=100 & trim_`var'_N ~=.
			drop `var'_N trim_`var'_N  	
}

count
rename Computer_service cs

*******************************
* Size
****************************
gen size=.
replace size=1 if emp<=50
replace size=2 if emp>50 & emp<=100
replace size=3 if emp>100 & emp<=250
replace size=4 if emp>250 & emp<=500
replace size=5 if emp>500

gen size1=(emp<=50)
label var size1 "<50"
gen size2=(emp>50 & emp<=100)
label var size2 "50<x<100"
gen size3=(emp>100 & emp<=250)
label var size3 "100<x<250"
gen size4=(emp>250 & emp<=500)
label var size4 "250<x<500"
gen size5=(emp>500)
label var size5 ">500"

so ruref year
drop sic 
save "all_clean.dta",replace











