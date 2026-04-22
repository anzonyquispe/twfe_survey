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
/* 1995-1996 and 1996-1997 Data */
/* Extended to 1993-94 and 1994-95 detailed record layouts recently purchased from ASI */
** These two years appear to be exactly identical in their data structure

foreach year in 9394 9495 9596 9697 {
*** Tab 1: 011
clear
use in`year'_011.dta

if `year'==9394 {
	gen begyr=1993
	gen endyr=1994
}

if `year'==9495 {
	gen begyr=1994
	gen endyr=1995
}

if `year'==9596 {
	gen begyr=1995
	gen endyr=1996
}
if `year'==9697 {
	gen begyr=1996
	gen endyr=1997
	** The multipliers here are in thousands instead of hundreds. Make consistent with rest of data.
	replace mult = mult/10 
	
}

sort nic87 runslno stcode schcode
save "$work/temp.dta", replace

*** Block 4: Fixed Assets
 
clear
use in`year'_040.dta
keep if slno == 13 
* Note that slno 13 is the total. There are other variables related to gross
*fixed capital in slno 14, should revisit this if using those variables.

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


*** Block 5: Working Capital and Loans
** 51: Opening
 
clear
use in`year'_053.dta

gen rmstop = rmstop1+rmstop2+rmstop3
drop rmstop?
keep if recordcat==51

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace

** 53: Closing
 
clear
use in`year'_053.dta

gen rmstop = rmstop1+rmstop2+rmstop3
drop rmstop?
keep if recordcat==53

rename rmstop rmstcl
rename sfgstop sfgstcl
rename stfgop stfgcl
rename invopen invclose

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


*** 074 (Employment)

clear
use in`year'_074.dta

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace




*** 081 & 082 (LABOUR COST)---STEVES ADDITION

clear
use in`year'_081.dta

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


clear
use in`year'_082.dta

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace



*** 91: Inputs, Fuels and Electricity Consumed
 
clear
use in`year'_091.dta


forval i = 1/4 {
preserve
keep  nic87 runslno stcode schcode linkcode *`i'
foreach j in  fuelcode qfuelcons vfuelcons { 
rename `j' `j'
}

tempfile _`i'
save `_`i''
restore
}

use `_1', clear
forval i = 2/4 {
append using `_`i''
}

if `year' ==9394 | `year'==9495 {
replace fuelcode=10000 if fuelcode==9999
}

cap drop filler*
drop if fuelcode==0
drop if fuelcode<1
drop if fuelcode>15 & fuelcode<10000
drop if fuelcode>10000

collapse (sum) qfuelcons vfuelcons, by(nic87 runslno stcode schcode linkcode fuelcode)
reshape wide qfuelcons vfuelcons, i(nic87 runslno stcode schcode linkcode) j(fuelcode)

#delim ;	
rename qfuelcons1 qcoalcons;	rename vfuelcons1 vcoalcons;
rename qfuelcons2 qlignitecons;	rename vfuelcons2 vlignitecons;
rename qfuelcons3 qcoalgascons;	rename vfuelcons3 vcoalgascons;
rename qfuelcons4 qliqpetrcons;	rename vfuelcons4 vliqpetrcons;
rename qfuelcons5 qnatgascons;	rename vfuelcons5 vnatgascons;
rename qfuelcons6 qpetrolcons;	rename vfuelcons6 vpetrolcons;
rename qfuelcons7 qdieselcons;	rename vfuelcons7 vdieselcons;
rename qfuelcons8 qfurnaceoilcons;	rename vfuelcons8 vfurnaceoilcons;
rename qfuelcons9 qotheroilcons;	rename vfuelcons9 votheroilcons;
rename qfuelcons10 qwoodcons;	rename vfuelcons10 vwoodcons;
rename qfuelcons11 qbiomasscons;	rename vfuelcons11 vbiomasscons;
rename qfuelcons12 qelecpur;	rename vfuelcons12 velecpur;
rename qfuelcons13 qlubeoilcons;	rename vfuelcons13 vlubeoilcons;
rename qfuelcons14 qwatercons;	rename vfuelcons14 vwatercons;
#delim cr	

rename vfuelcons10000 fuels
* Both electricity and water should not count as "fuels"
replace fuels=fuels-velecpur if velecpur!=.
replace fuels=fuels-vwatercons if vwatercons!=. 
** Collapse by facility across linkcodes
collapse (sum) fuels *cons *pur , by(nic87 runslno stcode schcode)

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


*** 102: Other Expenditure

clear
use in`year'_102.dta

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


** 111 (Other output/Receipts)

clear
use in`year'_111.dta

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace

*** 121: Electricity

clear
use in`year'_121.dta

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


*** 131: Materials Consumed
 
clear
use in`year'_131.dta

** Collapse to get the value of total materials consumed, which is listed as itemcode=10000
if `year' ==9394 | `year'==9495 {
forval z = 1/4 {
replace itemcode`z'=10000 if itemcode`z'==9999
}
*replace itemcode1=10000 if itemcode1==9999
}
gen materials = cond(itemcode1==10000,vcons1,0)
forvalues c = 2/4 {
	replace materials = max(materials , (itemcode`c'==10000)*vcons`c') /*Some have the sums listed twice, usually very similar. */
}

** Collapse by facility across linkcodes
collapse (sum) materials , by(nic87 runslno stcode schcode)

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace

*** 132: Industrial Components, etc, Consumed
* note that there are two different quantity and value variables here. The second rarely appears, and it's similar to the first when it does, suggesting it's some sort of duplicate (say price before tax). So ignore the second value
 
clear
use in`year'_132.dta
if `year' ==9394 | `year'==9495 {
forval z = 1/2 {
replace itemcode`z'=10000 if itemcode`z'==9999
}
*replace itemcode1=10000 if itemcode1==9999
}
** Collapse to get the value of total materials consumed, which is listed as itemcode=10000
gen indmaterials = cond(itemcode1==10000,vcons1,0)
*replace indmaterials = cond(itemcode1==10000,vcons1b,0) if itemcode1==10000&vcons1b!=0
replace indmaterials = max(indmaterials , (itemcode2==10000)*vcons2)
*replace indmaterials = cond(itemcode2==10000,vcons2b,0) if itemcode2==10000&vcons2b!=0

** Collapse by facility across linkcodes
collapse (sum) indmaterials , by(nic87 runslno stcode schcode)

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace

*** 133: Imported Materials Consumed
 
clear
use in`year'_133.dta
if `year' ==9394 | `year'==9495 {
forval z = 1/4 {
replace itemcode`z'=10000 if itemcode`z'==9999
}
*replace itemcode1=10000 if itemcode1==9999
}
** Collapse to get the value of total imports consumed, which is listed as itemcode=10000
** We are calling imported materials itotalinput for the other years.
gen itotalinput = cond(itemcode1==10000,vcons1,0)
forvalues c = 2/4 {
	replace itotalinput = max(itotalinput , (itemcode`c'==10000)*vcons`c')
}

** Collapse by facility across linkcodes
collapse (sum) itotalinput , by(nic87 runslno stcode schcode)

sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
sort nic87 runslno stcode schcode
save "$work/temp.dta", replace


*** 141: Product and By-Products

clear
use in`year'_141.dta
if `year' ==9394 | `year'==9495 {
replace itemcode=10000 if itemcode==9999
}
keep if itemcode == 10000
	* This leaves 45k observations, but _all_ plants listed here have an itemcode==10000
* Calculate Ex-Factory Value of Output per the struc00.xls 
* NB would like to do this, but we don't have good data on qmanufactured or qsold, so instead will use NSV instead of EFV.
*drop if itemcode == 10000
*gen nsvperunit = nsv/qsold
*gen efv = nsvperunit*qmanufactured
* Some items list zero qmanufactured or qsold, so there is no way to distinguish efv from nsv if this is an error. Most that list zero for one list zero for both qman and qsold. Those that list zeros typically list positive grsale and nsv, so it appears just to be something that can't be quantified in units.
*replace efv = nsv if efv==0|efv==. 
*collapse (sum) efv nsv grsale, by(nic87 runslno stcode schcode)
gen efv = grsale - distrexp
sort nic87 runslno stcode schcode
merge nic87 runslno stcode schcode using "$work/temp.dta"
drop _merge
*save "$work/asi`year'.dta", replace

** Finish prepping dataset

foreach var in  qmanufactured qsold grsale distrexp nsv efvperunit efv itotalinput indmaterials materials qelecpur qelecprod qelecsold qeleccons ownconst workforothers servinc incrstsfg velecsold ownconstr otherop vsamecond totalotherexp purchasevsamecond fuels totpersons sfgstcl sfgstcl stfgcl invclose rmstcl sfgstop stfgop invopen rmstop slno grossopening additiontogrossfcfromrevaluation grossactualaddition grossdeductionandadj depn fcapopen fcapclose {
	replace `var' = 0 if `var'==.
}



/* Fix some problematic observations */
if `year'==9596 {
	replace fcapclose = fcapopen-depn if fcapclose>=5e+11&fcapclose!=.
}


* matls as we want it defined is all materials other than fuels
gen matls = materials + indmaterials+itotalinput


***flag non-elec industries (BRICK)
g nonelecind = nic87==2304

save "$work/asi`year'.dta", replace
erase "$work/temp.dta"
foreach blk in 011 040 053 074 081 082 091 101 102 111 121 131 132 133 141 {
cap erase in`year'_`blk'.dta
}
}  /* Close loop over `year' */ 
