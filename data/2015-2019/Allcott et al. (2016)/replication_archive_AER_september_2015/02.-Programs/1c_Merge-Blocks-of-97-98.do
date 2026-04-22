************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

************************************************************************
************************************************************************

***THIS CODE IS BASED OFF HUNT'S IMPORTASI .DO FILE FROM PREVIOUS WORK
***USED TO FIND & EXTRACT LINE ITEMS IN THE DATA BLOCKS
/* 1997-1998 Data */ 
*** Block A

clear
use in9798_11.dta
gen begyr=1997
gen endyr=1998

sort  nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

***** Block C: Assets and Inventory
*** 21

clear
use in9798_21.dta

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace


***** Block C: Assets and Inventory
*** 23

clear
use in9798_23.dta

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace



****** Block D (Employment)
*** 31

clear
use in9798_31.dta

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

*** 32

clear
use in9798_32.dta

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

*** 33

clear
use in9798_33.dta

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace


** Block E (Output)
* Part 1: RC 41

clear
use in9798_41.dta

gen otherop = vsamecond + velecsold + servinc + ownconstr

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

* Part 2: RC 42
/* skip this. "other receipts" here is not the sum of other output. this is just rents and dividends. not used

clear
use in9798_42.dta

sort  nic87 runslno stcode permid schcode
merge  nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort  nic87 runslno stcode permid schcode
save "$work/temp.dta", replace
*/

*** Block F: Other Expenses
*** 51
* We technically don't need this now, as we'll get total input directly from Block 52.

clear
use in9798_51.dta

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

*** 52

clear
use in9798_52.dta

* To be consistent with other years, need to keep rent out of total inputs.
gen totinp = totalinpplusrent-rent

sort nic87 runslno stcode permid schcode
merge nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

*** Block G: Input Items (Indigenous??)

clear
use in9798_61.dta

foreach var in qeleccons veleccons voilcons qcoalcons vcoalcons votherfuelcons qelecprod qelecpur velecpur {
gen `var' = 0
}

forvalues i=1/3 {
replace qeleccons = qeleccons + qcons`i' if itemcode`i' == 99904

****IN 1997, QELECPUR IS DEFINITELY OFF BY FACTOR OF 1000 RELATIVE TO OTHER YEARS; OTHER SERIES LOOK OK
replace qeleccons = qeleccons + qcons`i'*1000 if itemcode`i'==99905

replace veleccons = veleccons + vcons`i' if itemcode`i' == 99904|itemcode`i'==99905

replace qelecprod = qelecprod + qcons`i' if itemcode`i' == 99904
****IN 1997, QELECPUR IS DEFINITELY OFF BY FACTOR OF 1000 RELATIVE TO OTHER YEARS; OTHER SERIES LOOK OK
replace qelecpur = qelecpur + qcons`i'*1000 if itemcode`i' == 99905
replace velecpur = velecpur + vcons`i' if itemcode`i' == 99905

replace voilcons = voilcons + vcons`i' if itemcode`i' == 99906

replace qcoalcons = qcoalcons + qcons`i' if itemcode`i' == 99907
replace vcoalcons = vcoalcons + vcons`i' if itemcode`i' == 99907

replace votherfuelcons = votherfuelcons + vcons`i' if itemcode`i' == 99204

}


** Collapse to one observation per factory
collapse (sum) qeleccons veleccons voilcons qcoalcons vcoalcons votherfuelcons  qelecprod qelecpur velecpur , by(nic87 runslno stcode permid schcode)
*gen fuels = veleccons + vcoalcons + voilcons + votherfuelcons
gen fuels = vcoalcons + voilcons + votherfuelcons

sort  nic87 runslno stcode permid schcode
merge  nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort  nic87 runslno stcode permid schcode
save "$work/temp.dta", replace


*** Block I: Product and By-Products

clear
use in9798_81.dta
* This keeps only the "total" amount:
keep if itemcode == 99930

sort  nic87 runslno stcode permid schcode
merge  nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort  nic87 runslno stcode permid schcode
save "$work/temp.dta", replace

*** Block J: Distributive Expenses

clear
use in9798_91.dta
* nb this is clearly total of distributive expenses, as "total" corresponds closely to sales + excise taxes. but the number is big.

sort  nic87 runslno stcode permid schcode
merge  nic87 runslno stcode permid schcode using "$work/temp.dta"
drop _merge
sort  nic87 runslno stcode permid schcode

** Finish prepping dataset

foreach var in  exciseduty salestax distrexp qmanufactured efv qsold grsale qeleccons veleccons voilcons qcoalcons vcoalcons votherfuelcons fuels otherexp6 rent totalinpplusrent v14 v15 v16 totinp h_itotalinput purchasevsamecond otherexp1 otherexp2 otherexp3 otherexp4 otherexp5 Export vsamecond velecsold servinc ownconstr outputownconsumption otherop workingprops unpaidfamilyemp coopemp totpersons depn fcapopen fcapclose rmstop rmstcl sfgstop sfgstcl stfgop stfgcl fodrsl {
	replace `var' = 0 if `var'==.
}




** Prepare for ComputeSums.do by standardizing with other years.
gen matls = totinp - fuels

*replace otheremp = otheremp+unpaidfamilyemp+coopemp
gen additiontogrossfcfromrevaluation = 0
* This here is not needed, but it should be correct
gen totalotherexp = otherexp1+otherexp2+otherexp3+otherexp4+otherexp5+otherexp6 

gen invopen =  rmstop + sfgstop + stfgop
gen invclose =  rmstcl + sfgstcl + stfgcl

* See formula for Value of Products and By Products in tp00.xls. It is EFV output + increase in stock of semi-finished goods + value of own construction
* Note that this year we don't observe all the components, but the below are the ones that we have
* gen ValProdByProd = efv + ownconst  (don't do this, instead standardize to go into ComputeSums.do  
gen incrstsfg = 0


***flag non-elec industries (BRICK)
g nonelecind = nic87==2304

save asi9798.dta, replace
foreach blk in 11 21 23 31 32 33 41 42 51 52 61 71 81 91 {
cap erase in9798_`blk'.dta
}
