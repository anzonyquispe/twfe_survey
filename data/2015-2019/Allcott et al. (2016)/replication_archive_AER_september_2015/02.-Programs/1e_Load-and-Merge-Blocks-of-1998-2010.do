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
**loop through the read in
qui forval year = 1998/2007 {
noi dis "`year'  `year'  `year'  `year'  `year'  `year'"
include "$do/Panel Data Read in Programs/ASI1998_2007_Conversion_to_Stata.do"
}

qui forval year = 2008/2010 {
noi dis "`year'  `year'  `year'  `year'  `year'  `year'"
include "$do/Panel Data Read in Programs/ASI`year'_Conversion_to_Stata.do"
}



*there are dupe dsl in 1998-2007
*this will cause reshaping problems within the blocks, so need to drop them before they are a problem
*these programs automate this process of identifying and then dropping within each block
cap program drop finduniq
program define finduniq
	preserve
	keep dsl
	bys dsl: g rank=_N
	tab rank
	keep if rank>1
	if _N>0 {
	duplicates drop
	}
	drop rank
	save "$work/dupes", replace
	restore	
end

cap program drop mergeuniq

program define mergeuniq
	merge m:1 dsl using "$work/dupes", keep(master match)
	drop if _m==3
	drop _m
end

*loop through the processing
tempfile temp set
qui forval year = 1998/2010 {
noi dis "`year'  `year'  `year'  `year'  "
use "$work/BLA`year'.dta", clear
rename FACT_ID dsl
rename A3 scheme
rename A4 industryFrame
rename A5 industryFrame5
rename A9 rural
rename A10 rosro
rename A11 NoF
rename A12 openClosed
rename MWDAYS daysManuf
rename NWDAYS daysNonManuf
rename WDAYS wkgdays
rename COSTOP costProduction
cap rename EXPORTSHARE exportshare
rename MULT emult2
finduniq
mergeuniq
save `temp', replace


use "$work/BLB`year'.dta", clear
rename FACT_ID dsl
rename B02 org
rename B03 ownership
cap rename B04 unitsCompany /* DOES NOT APPLY TO 2010-11*/
rename B07 Inprcode
rename B08F acctYearFrom
rename B08T acctYearTo
rename B09 monthsOperation
rename B10 computerAccounts
rename B11 computerFloppy
cap rename B05 origPMinv /* DOES NOT APPLY TO 2010-11 or earlier years*/
cap rename B06 ISOcert
mergeuniq
merge 1:1 dsl using `temp', nogen
save `temp', replace



use "$work/BLC`year'.dta", clear
rename FACT_ID dsl
rename C_I3 GrossOpen
rename C_I4 GrossRevalue
rename C_I5 GrossAdd
rename C_I6 GrossDeduct
rename C_I7 GrossClose
rename C_I8 DeprBegin
rename C_I9 DeprDuring
rename C_I11 DeprEnd
rename C_I12 NetOpen
rename C_I13 NetClose
*cap rename C_I10 AdjSoldDisc
cap drop C_I10 

//originally written for 08-10 data, this section has been checked & is good when applied to the 98-07 data
decode C_I1, g(field)
drop C_I1 BLK MULT
replace field="Plant" if field=="Plant & Machinery"
replace field="Transport" if field=="Transport equipment"
replace field="Computer" if field=="Computer equipment including software"
replace field="Other" if field=="Others"
replace field="Inprogress" if field=="Capital work in progress"
replace field="Subtotal" if field=="Sub-total (2 to 7)"
replace field="Total" if field=="Total (1+8+9)"
replace field="Pollution" if field=="Pollution Control Equipment"

replace field="fixed"+field

mergeuniq
*@AdjSoldDisc 
reshape wide  @GrossOpen @GrossRevalue @GrossAdd @GrossDeduct @GrossClose @DeprBegin @DeprDuring  @DeprEnd @NetOpen @NetClose, i(dsl) j(field) string

compress
merge 1:1 dsl using `temp', nogen
save `temp', replace


use "$work/BLD`year'.dta", clear
rename FACT_ID dsl
decode D_I1, g(field)
drop D_I1 BLK MULT
rename  D_I3 Open
rename D_I4 Close

//originally written for 08-10 data, this section has been checked & is good when applied to the 98-07 data  
replace field="Materials" if field=="Raw Materials & Components and Packing materials"
replace field="Fuels" if field=="Fuels & Lubricants"
replace field="Spares" if field=="Spares, Stores & Others"
replace field="StockMats" if field=="Sub-total (1 to 3)"
replace field="StockSFG" if field=="Semi-finished goods/work in progress"
replace field="StockFG" if field=="Finished goods"
replace field="Inventory" if field=="Total inventory ( 4 to 6)"
replace field="Cash" if field=="Cash in Hand in Hand & at Bank"
replace field="SundryDebtors" if field=="Sundry Debtors"
replace field="OtherAssets" if field=="Other current assets"
replace field="TotalAssets" if field=="Total current assets (7 to 10)"
replace field="SundryCreditors" if field=="Sundry Creditors"
replace field="Overdraft" if field=="Over draft, cash credit, other short Terms loan from Banks & other financial Institutions"
replace field="OtherLiabilities" if field=="Other current liabilities"
replace field="TotalLiabilities" if field=="Total current liabilities (12 to 14)"
replace field="Capital" if field=="Working capital (11 minus 15)"
replace field="Loans" if field=="Outstanding loans (excluding Interest but including deposits)"

replace field="working"+field

mergeuniq

reshape wide  @Open @Close , i(dsl) j(field) string

compress
merge 1:1 dsl using `temp', nogen
save `temp', replace


use "$work/BLE`year'.dta", clear
rename FACT_ID dsl
decode E_I1, g(field)

if `year' >=2008 {
	assert E_I6==0 | E_I6==. if E_I1==10 /* this is a remnant in the data of an old serial #10. It should not be here so make sure it is always empty and remove so extra vars are not created */
	drop if E_I1==10
	}
drop E_I1 BLK MULT
rename  E_I3 DaysManuf
rename E_I4 DaysNonManuf
rename E_I5 Days
rename E_I6 Average
rename E_I7 DaysPaid
rename E_I8 Wages
rename E_I10 Bonus
rename E_I11 Provident
rename E_I12 Welfare

**this was originally written for 2008+; checked and ADJUSTED to work properly for <2007 also
replace field="Male" if field=="Male Workers employed directly"
replace field="Female" if field=="Female Workers employed directly"
replace field="Subtotal" if field=="Sub-total (1+2)" | field=="Sub-total (1+2+3)" 
replace field="Contract" if field=="Workers employed through contractors"
replace field="Workers" if field=="Total Workers (3+4)" | field=="Total Workers (4+5)"
replace field="Supervise" if field=="Supervisory & managerial staff"
replace field="Other" if field=="Other employees"
replace field="Unpaid" if field=="Unpaid family members/proprietor/Coop. members"
replace field="Total" if field=="Total employees (5+6+7+8)" | field=="Total employees (6+7+8+9)"

replace field="emp"+field

mergeuniq

reshape wide @DaysManuf @DaysNonManuf @Days @Average @DaysPaid @Wages @Bonus @Provident @Welfare, i(dsl) j(field) string

compress
merge 1:1 dsl using `temp', nogen
save `temp', replace
	

use "$work/BLF`year'.dta", clear
rename FACT_ID dsl

rename F1 expenseOthersWork
rename F2A expenseMaintainBuilding
rename F2B expenseMaintainPlant
rename F3 expenseOperExpenses
rename F4 expenseNonOperExpenses
rename F5 expenseInsurance
rename F6 expenseRentPlant
rename F7 expenseTotal
rename F8 expenseRentBuilding
rename F9 expenseRentLand
rename F10 expenseInterest
rename F11 expenseOtherGoods

compress
mergeuniq
merge 1:1 dsl using `temp', nogen
save `temp', replace

	

use "$work/BLG`year'.dta", clear
rename FACT_ID dsl	

rename G1 receiptsServices
rename G2 receiptsSemiFinishedChange
rename G3 receiptsElectricity
rename G4 receiptsOwnConst
rename G5 receiptsGoodsNet
rename G6 receiptsRentPlant
rename G8 receiptsTotal
rename G9 receiptsRentBuilding
rename G10 receiptsLandRent
rename G11 receiptsInterest
rename G12 receiptsOtherGoods
*cap rename G7 receiptsSubsidies
cap drop G7

compress
mergeuniq
merge 1:1 dsl using `temp', nogen
save `temp', replace


use "$work/BLH`year'.dta", clear
rename FACT_ID dsl
rename H_I3 ASICC
rename H_I4 Unit
rename H_I5 Quantity
rename H_I6 Value
rename H_I7 RatePerUnit

decode H_I1, g(field)
replace field = string(H_I1) if field=="" & !mi(H_I1)
drop H_I1 BLK MULT

***field names already standardized in the encoding within years -- no need to clean up
replace field="input"+field
mergeuniq
reshape wide @ASICC @Unit @Quantity @Value @RatePerUnit, i(dsl) j(field) string

compress
merge 1:1 dsl using `temp', nogen
save `temp', replace



use "$work/BLI`year'.dta", clear
rename FACT_ID dsl
drop if I_I1>7 /*after 2001 plants could report more inputs beyond top 5; drop those since it happens so rarely & not comportable with earlier years */
rename I_I3 ASICC
rename I_I4 Unit
rename I_I5 Quantity
rename I_I6 Value
rename I_I7 RatePerUnit

tostring I_I1, g(field)
drop I_I1 BLK MULT
replace field="Other" if field=="6"
replace field="Total" if field=="7"
replace field="import"+field
reshape wide @ASICC @Unit @Quantity @Value @RatePerUnit, i(dsl) j(field) string

compress
mergeuniq
merge 1:1 dsl using `temp', nogen
save `temp', replace


use "$work/BLJ`year'.dta", clear
rename FACT_ID dsl
drop if J_I1>12 /*after 2001 plants could report more outputs beyond top 10; drop those since it happens so rarely & not comportable with earlier years */

rename J_I3 ASICC
rename J_I4 Unit
rename J_I5 QuantityMade
rename J_I6 QuantitySold
rename J_I7 GrossValue
rename J_I8 ExciseDuty
rename J_I9 SalesTax
rename J_I10 OtherExpense
rename J_I11 TotalExpense
rename J_I12 NetValue
rename J_I13 ExFactoryValue

tostring J_I1, g(field)
drop J_I1 BLK MULT
replace field="Other" if field=="11"
replace field="Total" if field=="12"
replace field="product"+field
mergeuniq
reshape wide @ASICC @Unit @QuantityMade @QuantitySold @GrossValue @ExciseDuty @SalesTax @OtherExpense @TotalExpense @NetValue @ExFactoryValue, i(dsl) j(field) string

compress
merge 1:1 dsl using `temp', nogen
save `temp', replace


drop YEAR BLK

g year=`year'

if `year' >=1999 {
append using `set'
}

save `set', replace
noi tab year, mi

foreach block in A B C D E F G H I J {
erase "$work/BL`block'`year'.dta"
}

}


tab year
***set useful openclosed code for quick drop later
g newopen= openClosed!=1
tab newopen

*generate these after checking definition
g newlocation=rural

tab ownership
tab ownership, nola
g newown = 1 if ownership==1
	replace newown=2 if ownership==2
	replace newown=3 if ownership==6
	replace newown=4 if ownership==3
	replace newown=5 if ownership==5
	replace newown=6 if ownership==4

tab org
tab org, nola
g neworg = 1 if org==1
	replace neworg=2 if org==2
	replace neworg=3 if org==3
	replace neworg=4 if org==4
	replace neworg=5 if org==5
	replace neworg=6 if org==7
	replace neworg=7 if org==10
	replace neworg=8 if org==19 | org==9 | org==6
		


***extract state
g state=substr(dsl,6,2)
tab state year, mi
destring state, replace
drop if state=="4F" | state=="F" //there are 140 records in 2006 that have dsl codes that are shortened and thus the state code extraction is no good -- there is no obvious fix to these (missing leading zeros, etc.) and not easily matched with records form other years, so drop)
	assert length(dsl)==8 // ensures all the other dsl are the right length
	
***drop null fields that occur due to reshapes (greyed out cells in the questionnaire matrix blocks)
ds, has(type numeric)
foreach x in `r(varlist)' {
count if `x' ==0 | `x'==.
	if r(N)==_N {
	drop `x' 
	dis "DROPPED `x'"
	}
	else {
	dis "`x' IS OK"
	}
}
save "$work/temp", replace
****crosswalk nics here
****do crosswalk outside main dataset to save on processing time due to several merges on many obs & adding several string columns making the dataset big
***do for 2008+ back to 2004 nics
keep industryFrame5 year
duplicates drop
g nic408=string(industryFrame5) if year>=2008
replace nic408="0"+nic408 if length(nic408)==4 & year>=2008
replace nic408=substr(nic408,1,4) if year>=2008
merge m:1 nic408 using "$data/NIC crosswalk/NIC0408Crosswalk_4digit.dta", keepusing(nic04_4) keep(1 3) gen(_m0)
	assert _m0==3 if year>=2008

	
g nic04=industryFrame5 if year>=2004 & year<2008
merge m:1 nic04 using "$data/NIC crosswalk/nic_04_87_5d.dta" ,keep(1 3) gen(_m1)
	rename nic3digit nic387_5digmerge04

replace nic04_4 =floor(industryFrame5/10) if year>=2004 & year<2008
merge m:1 nic04_4 using "$data/NIC crosswalk/nic_04_87_4d.dta", keep(1 3) gen(_m2)
rename nic3digit nic387_4digmerge04

merge m:1 nic04_4 using "$data/NIC crosswalk/nic_04_87_4d_composite.dta", keepusing(nic387) keep(1 3) gen(_m2a)
	*check matches work at least for manufacturing
	assert nic04_4<1500 | nic04_4 >=3700 if _m2a==1
	assert _m2a==3 if nic04_4>1500 & nic04_4 <3700
	rename nic387 nic387_4digmerge0804
	drop nic408 nic04_4 nic04

g nic98=industryFrame5 if year>=1998 & year<2004
merge m:1 nic98 using "$data/NIC crosswalk/nic_98_87_5d.dta" , keep(1 3) gen(_m3)
rename nic3digit nic387_5digmerge98

g nic98_4 =floor(industryFrame5/10) if year>=1998 & year<2004
merge m:1 nic98_4 using "$data/NIC crosswalk/nic_98_87_4d.dta", keep(1 3) gen(_m4)
rename nic3digit nic387_4digmerge98
drop nic98 nic98_4

g nic3_87=""
tostring industryFrame5, replace
replace industryFrame5=substr("00000"+industryFrame5,length("00000"+industryFrame5)-4,5)
***preference the 5 digit merges over 4digit merges from 2004; preference the original 4dig merge over the composite one
replace nic3_87=substr(industryFrame5,1,3) if year <1998
replace nic3_87=string(nic387_5digmerge04) if nic387_5digmerge04!=. & nic3_87==""
replace nic3_87=string(nic387_4digmerge04) if nic387_4digmerge04!=. & nic3_87==""
replace nic3_87=string(nic387_4digmerge0804) if nic387_4digmerge0804!=. & nic3_87==""
**and same for the nic98 merges
replace nic3_87=string(nic387_5digmerge98) if nic387_5digmerge98!=. & nic3_87==""
replace nic3_87=string(nic387_4digmerge98) if nic387_4digmerge98!=. & nic3_87==""
	assert length(nic3_87)==3 | length(nic3_87)==0

gen orig_3dig=substr(industryFrame5,1,3)
tab orig_3dig year if nic3_87=="" //a small number of these are manuf industries & probably should be matched  -- fix later

bysort year: tab nic3_87, mi
bysort year: count if nic3_87=="" | nic3_87=="."
keep industryFrame5 year nic3_87
replace nic3_87 = "9999" if nic3_87=="" | nic3_87=="."
tempfile temp
save `temp'
use "$work/temp", clear
tostring industryFrame5, replace
replace industryFrame5=substr("00000"+industryFrame5,length("00000"+industryFrame5)-4,5)
merge m:1 industryFrame5 year using `temp', assert(3) nogen
rename nic3_87 nic3digit

rename scheme schcode
drop MULT
compress

***flag non-elec industries (BRICK)
g nonelecind = 0
replace nonelecind=1 if year >=1998 & year<2004 & industryFrame5=="26931"
replace nonelecind=1 if year >=2004 & year<2008 & industryFrame5=="26931"
replace nonelecind=1 if year >=2008 & year<2011 & industryFrame5=="23921"

save "$intdata/1998-2010panel_full.dta", replace

erase "$work/dupes.dta"
erase "$work/temp.dta"
