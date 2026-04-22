******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
*********************************************************
* THIS FILE:
* GENERATES OVERALL ICT SERIES BY MERGING QICE, FAR, BSCI DATA
* MERGES ICT DATA WITH ARD
* CLEANS DATA

clear
set mem 500m

*****************************************************
**   Part 2  
**   Creates the ICT capital stocks data set
*****************************************************
/*
clear
run "2.BSCI_new.do"
clear
run "1.QICE_new.do"
clear
run "3.ARD_new.do"
clear
*run T:\ONS\Giles_Gale\Raffaella\FAR\FAR.do

*/


*************************************************************
**  Part 3 
**  Merging ICT data                                  ********
*************************************************************
cd "H:\Raffaella\ICT\Files_March_07\0.ICT STOCKS\"
clear
use "BSCI\bscimerge.dta", clear
sort ruref year
merge ruref year using FAR\farmerge.dta
drop _merge
sort ruref year
merge ruref year using QICE\qicemerge.dta
drop _merge
sort ruref year
merge ruref year using ARD\ardmerge.dta
drop  _merge
sort ruref year
save "ictmerge.dta", replace


***************************************************************
** Part 4
** Merge with ARD and capstock data                              **
***************************************************************
clear
set mem 1000m
use "ictmerge.dta", clear
compress
so ruref year
cd "H:\Raffaella\ICT\Files_March_07\1.Merge&Clean\"
merge ruref year using "all_clean"
rename _merge ardict_merge
keep if ardict_merge==3
drop if ruref==.
so ruref year

************************************
* Generate aggregate ICT variables and dummies
************************************
* Investment series in current prices, need it to compare with input output tables
gen hardinv_curr = hardinv_bsci_curr
replace hardinv_curr = hardinv_qice_curr if hardinv_curr==0 & hardinv_qice_curr~=. & hardinv_qice_curr~=0
replace hardinv_curr = hardinv_qice_curr if hardinv_curr==. & hardinv_qice_curr~=. & hardinv_qice_curr~=0

*replace softinv_ard_curr=. if softinv_ard_curr<0
gen softinv_curr = softinv_bsci_curr
replace softinv_curr = softinv_qice_curr if softinv_curr==. & softinv_qice_curr~=0 & softinv_qice_curr~=.
replace softinv_curr = softinv_qice_curr if softinv_curr==0 & softinv_qice_curr~=0 & softinv_qice_curr~=.
replace softinv_curr = softinv_ard_curr if softinv_curr==. & softinv_ard_curr~=0 & softinv_ard_curr~=.
replace softinv_curr = softinv_ard_curr if softinv_curr==0 & softinv_ard_curr~=0 & softinv_ard_curr~=.

* Now in constant prices
gen hardinv = hardinv_bsci
replace hardinv = hardinv_qice if hardinv==0 & hardinv_qice~=. & hardinv_qice~=0
replace hardinv = hardinv_qice if hardinv==. & hardinv_qice~=. & hardinv_qice~=0
gen IHdummy_bsci=(hardinv_bsci~=.)*(hardinv_bsci~=0)
gen IHdummy_qice= (hardinv_bsci==. | hardinv_bsci==0)*(hardinv_qice~=.)*(hardinv_qice~=0) 
replace IHdummy_bsci=. if hardinv==.
replace IHdummy_qice=. if hardinv==.
replace IHdummy_bsci=1 if (hardinv_bsci==0 & hardinv_qice==0) | (hardinv_bsci==0 & hardinv_qice==.)
replace IHdummy_qice=0 if hardinv_bsci==0 & hardinv_qice==0

replace softinv_ard=. if softinv_ard<0
gen softinv = softinv_bsci
replace softinv = softinv_qice if softinv==. & softinv_qice~=0 & softinv_qice~=.
replace softinv = softinv_qice if softinv==0 & softinv_qice~=0 & softinv_qice~=.
replace softinv = softinv_ard if softinv==. & softinv_ard~=0 & softinv_ard~=.
replace softinv = softinv_ard if softinv==0 & softinv_ard~=0 & softinv_ard~=.
gen ISdummy_bsci=(softinv_bsci~=.)*(softinv_bsci~=0)
gen ISdummy_qice=(softinv_bsci==. | softinv_bsci==0)*(softinv_qice~=0)*(softinv_qice~=.)
gen ISdummy_ard = (softinv_bsci==. | softinv_bsci==0)*(softinv_qice==. | softinv_qice==0)*(softinv_ard~=.)*(softinv_ard~=0)

replace ISdummy_bsci=. if softinv==.
replace ISdummy_qice=. if softinv==.
replace ISdummy_ard=. if softinv==.
replace ISdummy_bsci=1 if (softinv_bsci==0 & softinv_qice==0 & softinv_ard==0) | (softinv_bsci==0 & softinv_qice==. & softinv_ard==0)|(softinv_bsci==0 & softinv_qice==0 & softinv_ard==.)
replace ISdummy_bsci=1 if (softinv_bsci==0 & softinv_qice==. & softinv_ard==.)

******************************
* For capital stocks only (inv is in constant prices)
**************************************
local vars "bsci qice far ard"
foreach var of local vars{
		replace ksoftware_`var'=. if ksoftware_`var'<0 & ksoftware_`var'~=. 
		replace ksoftware_`var'=. if ksoftware_`var'>rcapstk95 & ksoftware_`var'~=. & rcapstk95~=.
}
local vars "bsci qice far "
foreach var of local vars{
		replace khardware_`var'=. if khardware_`var'<0 & khardware_`var'~=. 
		replace khardware_`var'=. if khardware_`var'>rcapstk95 & khardware_`var'~=. & rcapstk95~=.
}
/*
local vars "bsci qice ard"
foreach var of local vars{
		replace ksoftware_new_`var'=. if ksoftware_new_`var'<0 & ksoftware_new_`var'~=. 
		replace ksoftware_new_`var'=. if ksoftware_new_`var'>rcapstk95 & ksoftware_new_`var'~=. & rcapstk95~=.
}
local vars "bsci qice "
foreach var of local vars{
		replace khardware_new_`var'=. if khardware_new_`var'<0 & khardware_new_`var'~=. 
		replace khardware_new_`var'=. if khardware_new_`var'>rcapstk95 & khardware_new_`var'~=. & rcapstk95~=.
}

*/

local vars "bsci qice ard"
foreach var of local vars{
		replace ksoftware_new2_`var'=. if ksoftware_new2_`var'<0 & ksoftware_new2_`var'~=. 
		replace ksoftware_new2_`var'=. if ksoftware_new2_`var'>rcapstk95 & ksoftware_new2_`var'~=. & rcapstk95~=.
}
local vars "bsci qice "
foreach var of local vars{
		replace khardware_new2_`var'=. if khardware_new2_`var'<0 & khardware_new2_`var'~=. 
		replace khardware_new2_`var'=. if khardware_new2_`var'>rcapstk95 & khardware_new2_`var'~=. & rcapstk95~=.
}

**********************************

gen khard = khardware_bsci
replace khard = khardware_qice if khard==0 & khardware_qice~=. & khardware_qice~=0
replace khard = khardware_qice if khard==. & khardware_qice~=. & khardware_qice~=0
replace khard = khardware_far if khard==0 & khardware_far~=. & khardware_far~=0
replace khard = khardware_far if khard==. & khardware_far~=. & khardware_far~=0

gen Hdummy_bsci=(khardware_bsci~=.)*(khardware_bsci~=0)
gen Hdummy_qice= (khardware_bsci==. | khardware_bsci==0)*(khardware_qice~=.)*(khardware_qice~=0) 
gen Hdummy_far = (khardware_bsci==. | khardware_bsci==0)*(khardware_qice==. | khardware_qice==0)*(khardware_far~=.)*(khardware_far~=0)

replace Hdummy_bsci=. if khard==.
replace Hdummy_qice=. if khard==.
replace Hdummy_far =. if khard==.
replace Hdummy_bsci=1 if (khardware_bsci==0 & khardware_qice==0 & khardware_far==0) | (khardware_bsci==0 & khardware_qice==. & khardware_far==0)|(khardware_bsci==0 & khardware_qice==0 & khardware_far==.)
replace Hdummy_bsci=1 if (khardware_bsci==0 & khardware_qice==. & khardware_far==.)

gen ksoft = ksoftware_bsci
replace ksoft = ksoftware_qice if ksoft==0 & ksoftware_qice~=. & ksoftware_qice~=0
replace ksoft = ksoftware_qice if ksoft==. & ksoftware_qice~=. & ksoftware_qice~=0
replace ksoft = ksoftware_far if ksoft==0 & ksoftware_far~=. & ksoftware_far~=0
replace ksoft = ksoftware_far if ksoft==. & ksoftware_far~=. & ksoftware_far~=0
replace ksoft = ksoftware_ard if ksoft==0 & ksoftware_ard~=. & ksoftware_ard~=0
replace ksoft = ksoftware_ard if ksoft==. & ksoftware_ard~=. & ksoftware_ard~=0

gen Sdummy_bsci=(ksoftware_bsci~=.)*(ksoftware_bsci~=0)
gen Sdummy_qice= (ksoftware_bsci==. | ksoftware_bsci==0)*(ksoftware_qice~=.)*(ksoftware_qice~=0) 
gen Sdummy_far = (ksoftware_bsci==. | ksoftware_bsci==0)*(ksoftware_qice==. | ksoftware_qice==0)*(ksoftware_far~=.)*(ksoftware_far~=0)
gen Sdummy_ard = (ksoftware_bsci==. | ksoftware_bsci==0)*(ksoftware_qice==. | ksoftware_qice==0)*(ksoftware_far==. | ksoftware_far==0)*(ksoftware_ard~=.)*(ksoftware_ard~=0)
replace Sdummy_bsci=. if ksoft==.
replace Sdummy_qice=. if ksoft==.
replace Sdummy_far =. if ksoft==.
replace Sdummy_ard =. if ksoft==.

replace Sdummy_bsci=1 if (ksoftware_bsci==0 & ksoftware_qice==0 & ksoftware_far==0 & ksoftware_ard==0) | (ksoftware_bsci==0 & ksoftware_qice==. & ksoftware_far==0 & ksoftware_ard==0)|(ksoftware_bsci==0 & ksoftware_qice==. & ksoftware_far==0 & ksoftware_ard==.)|(ksoftware_bsci==0 & ksoftware_qice==0 & ksoftware_far==. & ksoftware_ard==0)
replace Sdummy_bsci=1 if (ksoftware_bsci==0 & ksoftware_qice==. & ksoftware_far==. & ksoftware_ard==0 )|(ksoftware_bsci==0 & ksoftware_qice==. & ksoftware_far==. & ksoftware_ard==. ) | (ksoftware_bsci==0 & ksoftware_qice==0 & ksoftware_far==. & ksoftware_ard==.)

******* New stocks
/*
gen khard2 = khardware_new_bsci
replace khard2 = khardware_new_qice if khard2==0 & khardware_new_qice~=. & khardware_new_qice~=0
replace khard2 = khardware_new_qice if khard2==. & khardware_new_qice~=. & khardware_new_qice~=0
replace khard2 = khardware_far if khard2==0 & khardware_far~=. & khardware_far~=0
replace khard2 = khardware_far if khard2==. & khardware_far~=. & khardware_far~=0

gen Hdummy_new_bsci=(khardware_new_bsci~=.)*(khardware_new_bsci~=0)
gen Hdummy_new_qice= (khardware_new_bsci==. | khardware_new_bsci==0)*(khardware_new_qice~=.)*(khardware_new_qice~=0) 
gen Hdummy_new_far = (khardware_new_bsci==. | khardware_new_bsci==0)*(khardware_new_qice==. | khardware_new_qice==0)*(khardware_far~=.)*(khardware_far~=0)

replace Hdummy_new_bsci=. if khard2==.
replace Hdummy_new_qice=. if khard2==.
replace Hdummy_new_far =. if khard2==.
replace Hdummy_new_bsci=1 if (khardware_new_bsci==0 & khardware_new_qice==0 & khardware_far==0) | (khardware_new_bsci==0 & khardware_new_qice==. & khardware_far==0)|(khardware_new_bsci==0 & khardware_new_qice==0 & khardware_far==.)
replace Hdummy_new_bsci=1 if (khardware_new_bsci==0 & khardware_new_qice==. & khardware_far==.)

gen ksoft2 = ksoftware_new_bsci
replace ksoft2 = ksoftware_new_qice if ksoft2==0 & ksoftware_new_qice~=. & ksoftware_new_qice~=0
replace ksoft2 = ksoftware_new_qice if ksoft2==. & ksoftware_new_qice~=. & ksoftware_new_qice~=0
replace ksoft2 = ksoftware_far if ksoft2==0 & ksoftware_far~=. & ksoftware_far~=0
replace ksoft2 = ksoftware_far if ksoft2==. & ksoftware_far~=. & ksoftware_far~=0
replace ksoft2 = ksoftware_new_ard if ksoft2==0 & ksoftware_new_ard~=. & ksoftware_new_ard~=0
replace ksoft2 = ksoftware_new_ard if ksoft2==. & ksoftware_new_ard~=. & ksoftware_new_ard~=0

gen Sdummy_new_bsci=(ksoftware_new_bsci~=.)*(ksoftware_new_bsci~=0)
gen Sdummy_new_qice= (ksoftware_new_bsci==. | ksoftware_new_bsci==0)*(ksoftware_new_qice~=.)*(ksoftware_new_qice~=0) 
gen Sdummy_new_far = (ksoftware_new_bsci==. | ksoftware_new_bsci==0)*(ksoftware_new_qice==. | ksoftware_new_qice==0)*(ksoftware_far~=.)*(ksoftware_far~=0)
gen Sdummy_new_ard = (ksoftware_new_bsci==. | ksoftware_new_bsci==0)*(ksoftware_new_qice==. | ksoftware_new_qice==0)*(ksoftware_far==. | ksoftware_far==0)*(ksoftware_new_ard~=.)*(ksoftware_new_ard~=0)
replace Sdummy_new_bsci=. if ksoft2==.
replace Sdummy_new_qice=. if ksoft2==.
replace Sdummy_new_far =. if ksoft2==.
replace Sdummy_new_ard =. if ksoft2==.

replace Sdummy_new_bsci=1 if (ksoftware_new_bsci==0 & ksoftware_new_qice==0 & ksoftware_far==0 & ksoftware_new_ard==0) | (ksoftware_new_bsci==0 & ksoftware_new_qice==. & ksoftware_far==0 & ksoftware_new_ard==0)|(ksoftware_new_bsci==0 & ksoftware_new_qice==. & ksoftware_far==0 & ksoftware_new_ard==.)|(ksoftware_new_bsci==0 & ksoftware_new_qice==0 & ksoftware_far==. & ksoftware_new_ard==0)
replace Sdummy_new_bsci=1 if (ksoftware_new_bsci==0 & ksoftware_new_qice==. & ksoftware_far==. & ksoftware_new_ard==0 )|(ksoftware_new_bsci==0 & ksoftware_new_qice==. & ksoftware_far==. & ksoftware_new_ard==. ) | (ksoftware_new_bsci==0 & ksoftware_new_qice==0 & ksoftware_far==. & ksoftware_new_ard==.)
*****************************************
*/

gen khard3 = khardware_new2_bsci
replace khard3 = khardware_new2_qice if khard3==0 & khardware_new2_qice~=. & khardware_new2_qice~=0
replace khard3 = khardware_new2_qice if khard3==. & khardware_new2_qice~=. & khardware_new2_qice~=0
replace khard3 = khardware_far if khard3==0 & khardware_far~=. & khardware_far~=0
replace khard3 = khardware_far if khard3==. & khardware_far~=. & khardware_far~=0

gen Hdummy_new2_bsci=(khardware_new2_bsci~=.)*(khardware_new2_bsci~=0)
gen Hdummy_new2_qice= (khardware_new2_bsci==. | khardware_new2_bsci==0)*(khardware_new2_qice~=.)*(khardware_new2_qice~=0) 
gen Hdummy_new2_far = (khardware_new2_bsci==. | khardware_new2_bsci==0)*(khardware_new2_qice==. | khardware_new2_qice==0)*(khardware_far~=.)*(khardware_far~=0)

replace Hdummy_new2_bsci=. if khard3==.
replace Hdummy_new2_qice=. if khard3==.
replace Hdummy_new2_far =. if khard3==.
replace Hdummy_new2_bsci=1 if (khardware_new2_bsci==0 & khardware_new2_qice==0 & khardware_far==0) | (khardware_new2_bsci==0 & khardware_new2_qice==. & khardware_far==0)|(khardware_new2_bsci==0 & khardware_new2_qice==0 & khardware_far==.)
replace Hdummy_new2_bsci=1 if (khardware_new2_bsci==0 & khardware_new2_qice==. & khardware_far==.)

gen ksoft3 = ksoftware_new2_bsci
replace ksoft3 = ksoftware_new2_qice if ksoft3==0 & ksoftware_new2_qice~=. & ksoftware_new2_qice~=0
replace ksoft3 = ksoftware_new2_qice if ksoft3==. & ksoftware_new2_qice~=. & ksoftware_new2_qice~=0
replace ksoft3 = ksoftware_far if ksoft3==0 & ksoftware_far~=. & ksoftware_far~=0
replace ksoft3 = ksoftware_far if ksoft3==. & ksoftware_far~=. & ksoftware_far~=0
replace ksoft3 = ksoftware_new2_ard if ksoft3==0 & ksoftware_new2_ard~=. & ksoftware_new2_ard~=0
replace ksoft3 = ksoftware_new2_ard if ksoft3==. & ksoftware_new2_ard~=. & ksoftware_new2_ard~=0

gen Sdummy_new2_bsci=(ksoftware_new2_bsci~=.)*(ksoftware_new2_bsci~=0)
gen Sdummy_new2_qice= (ksoftware_new2_bsci==. | ksoftware_new2_bsci==0)*(ksoftware_new2_qice~=.)*(ksoftware_new2_qice~=0) 
gen Sdummy_new2_far = (ksoftware_new2_bsci==. | ksoftware_new2_bsci==0)*(ksoftware_new2_qice==. | ksoftware_new2_qice==0)*(ksoftware_far~=.)*(ksoftware_far~=0)
gen Sdummy_new2_ard = (ksoftware_new2_bsci==. | ksoftware_new2_bsci==0)*(ksoftware_new2_qice==. | ksoftware_new2_qice==0)*(ksoftware_far==. | ksoftware_far==0)*(ksoftware_new2_ard~=.)*(ksoftware_new2_ard~=0)
replace Sdummy_new2_bsci=. if ksoft3==.
replace Sdummy_new2_qice=. if ksoft3==.
replace Sdummy_new2_far =. if ksoft3==.
replace Sdummy_new2_ard =. if ksoft3==.

replace Sdummy_new2_bsci=1 if (ksoftware_new2_bsci==0 & ksoftware_new2_qice==0 & ksoftware_far==0 & ksoftware_new2_ard==0) | (ksoftware_new2_bsci==0 & ksoftware_new2_qice==. & ksoftware_far==0 & ksoftware_new2_ard==0)|(ksoftware_new2_bsci==0 & ksoftware_new2_qice==. & ksoftware_far==0 & ksoftware_new2_ard==.)|(ksoftware_new2_bsci==0 & ksoftware_new2_qice==0 & ksoftware_far==. & ksoftware_new2_ard==0)
replace Sdummy_new2_bsci=1 if (ksoftware_new2_bsci==0 & ksoftware_new2_qice==. & ksoftware_far==. & ksoftware_new2_ard==0 )|(ksoftware_new2_bsci==0 & ksoftware_new2_qice==. & ksoftware_far==. & ksoftware_new2_ard==. ) | (ksoftware_new2_bsci==0 & ksoftware_new2_qice==0 & ksoftware_far==. & ksoftware_new2_ard==.)


*************************************
* Cleaning ICT
*************************************
*drop if khard==. & ksoft==. 
so ruref year
*local vars "khard  khard3 ksoft3 hardinv cs ksoft  softinv hardinv_curr softinv_curr "
local vars "khard  khard3 ksoft3  cs ksoft  softinv  softinv_curr "
foreach var of local vars{
		gen `var'_l = `var'[_n-1] if ruref==ruref[_n-1] & `var'~=0 & `var'[_n-1]~=0 & year==year[_n-1]+1
		gen growth_`var' = (`var'-`var'_l)/`var'_l
		gen `var'_y = `var'/gva_fc_def 
		gen `var'_k =`var'/rcapstk95
		gen `var'_e = `var'/emp
		xtile trimgro`var' = `var'_y, nq(100)
 }

so ruref year
local vars "khard   ksoft  khard3 ksoft3  "
foreach var of local vars{
		gen `var'_e_l = `var'_e[_n-1] if ruref==ruref[_n-1] & `var'_e~=0 & `var'_e[_n-1]~=0 & year==year[_n-1]+1
		gen `var'_e_gro = (`var'_e - `var'_e_l)/`var'_e_l
		gen `var'_gro = growth_`var'/growth_emp if growth_`var'~=. & growth_emp~=.
}
su ruref if ksoft~=.
su ruref if khard~=.
su ruref if khard~=. & ksoft~=.

***************************
* Clean
***************************
*local vars "khard hardinv cs hardinv_curr khard3 "
local vars "khard cs  khard3 "
foreach var of local vars{
			replace `var'=.  if trimgro`var'<=1 | trimgro`var'>=100 & trimgro`var'~=.
			replace `var'_y=. if trimgro`var'<=1 | trimgro`var'>=100 & trimgro`var'~=.
			replace `var'_e=. if trimgro`var'<=1 | trimgro`var'>=100 & trimgro`var'~=.
			drop trimgro`var' `var'_l   	
 }

local vars "ksoft  softinv softinv_curr  ksoft3"
foreach var of local vars{
			replace `var'=.  if trimgro`var'<=5 | trimgro`var'>=96 & trimgro`var'~=.
			replace `var'_y=. if trimgro`var'<=5 | trimgro`var'>=96 & trimgro`var'~=.
			replace `var'_e=. if trimgro`var'<=5 | trimgro`var'>=96 & trimgro`var'~=.
			drop trimgro`var' `var'_l  	    	

 }


su ruref if ksoft~=.
su ruref if khard~=.
su ruref if khard~=. & ksoft~=.
*drop if khard==. & ksoft==.

******************************
*** Generate variables
*****************************
gen unit_wage= totlabcost/emp
tab year,gen(yy)
gen ln_Y    = ln(gva_fc_def)
gen ln_GY   = ln(go_def)
gen ln_K    = ln(rcapstk95)
gen ln_N    = ln(emp)
gen ln_WN   = ln(totlabcost)
gen ln_W    = ln(unit_wage)
gen ln_M    = ln(matpurch)
gen ln_TM   = ln(totpurch)
gen ln_I    = ln(ncapex)

gen ln_hardinv = ln(hardinv)
gen ln_softinv = ln(softinv)
gen ln_khard = ln(khard)
gen ln_ksoft =ln(ksoft)

gen ln_khard3 = ln(khard3)
gen ln_ksoft3 =ln(ksoft3)

gen ln_hardinv_e = ln(hardinv/emp)
gen ln_cs = ln(cs)

/*
gen ln2=ln(rcapstk95-khard)
gen ln3= ln(rcapstk95-khard-ksoft)
gen ln4 = ln(rcapstk95-ksoft)
gen ln5 = ln(rcapstk95-khard2)
gen ln6 = ln(rcapstk95-ksoft2)

areg ln_Y ln2 ln_N ln_khard yy* Hdummy_bsci Hdummy_qice, abs(ruref) rob 
areg ln_Y ln5 ln_N ln_khard_new yy* Hdummy_new*, abs(ruref) rob 
areg ln_Y ln4 ln_N ln_ksoft yy* Sdummy_bsci Sdummy_qice Sdummy_ard , abs(ruref) rob 
areg ln_Y ln6 ln_N ln_ksoft yy* Sdummy_new* , abs(ruref) rob 
areg ln_Y ln3 ln_N ln_khard ln_ksoft yy* Sd* Hd*, abs(ruref) rob 
areg ln_Y ln_K ln_N ln_hardinv IHd* yy*, abs(ruref) rob 
areg ln_Y ln_K ln_N ln_hardinv ln_softinv ISd* IHd* yy*, abs(ruref) rob 
*/



********************************************
* Labeling variables
********************************************
rename sic_abi sic
lab var sic "5 sic industry"
lab var sic2 "2 sic industry"
lab var sic3 "3 sic industry"
lab var sic4 "4 sic industry"
lab var manuf "Dummy for manufacturing sector"
lab var gva_fc_def "GVA at factor costs, deflated"
lab var go_def "Gross Output, deflated"
lab var hardinv "Hardware investment, combined and deflated"
lab var softinv "Software investment, combined and deflated"
lab var khard "hardware capital, combined"
lab var ksoft "software capital, combined"
lab var khard3 "hardware capital, combined, using emp weights and norm"
lab var ksoft3 "software capital, combined, using emp weights and norm"
lab var Dgroup "Dummy equal to 1 if plant belongs to a group"
lab var ukmult "UK multinational"
lab var mult "Uk and non uk multinational, from AFDI"
lab var for "Dummy equal to 1 if ownership not uk (missing treated as uk)"
lab var usa  "Dummy equal to 1 if plant has ownership = 805"
lab var multi "Dummy equal to 1 if plant is uk or non us multi, ARD and AFDI"
lab var age_t "Plant age is truncated in 1980 for manuf and in 1997 for services"

**********************************
* Keep only needed
**********************************
*drop hardinv_bsci softinv_bsci ksoftware_bsci khardware_bsci khardware_far ksoftware_far softinv_qice_code hardinv_qice_code softinv_qice hardinv_qice  ksoftware_qice khardware_qice  softinv_ard ksoftware_ard emp_admin ppi2000s  ppi2000m ppi2000 def  
drop region_old  
drop emp_l growth_emp  rcapstk95_N     growth_cs growth_ksoft growth_softinv khard_e_l khard_e_gro ksoft_e_l ksoft_e_gro 
drop  growth_khard 
drop  softinv_bsci_curr hardinv_bsci_curr  ksoftware_new2_bsci khardware_new2_bsci quarter softinv_qice_curr hardinv_qice_curr  ksoftware_new2_qice khardware_new2_qice sic_ard softinv_ard_curr  ksoftware_new2_ard
drop   siclett sel_idx growth_gva_fc_def trim_rcapstk95_N trim_gva_fc_def_N ardict_merge  khard3_e_l khard3_e_gro ksoft3_e_l ksoft3_e_gro
drop if khard==. & ksoft==.  & khard3==. & ksoft3==.

foreach set in qice bsci ard far{
rename Sdummy_new2_`set' new2_Sdummy_`set'
}
foreach set in qice bsci  far{
rename Hdummy_new2_`set' new2_Hdummy_`set'
}
so ruref year
save "ardict", replace
keep ruref year du_usa_mu_noadj du_oth_mu_noadj du_dom_noadj ukmult_noadj mult_noadj
so ruref year
save "ardict_pure", replace

