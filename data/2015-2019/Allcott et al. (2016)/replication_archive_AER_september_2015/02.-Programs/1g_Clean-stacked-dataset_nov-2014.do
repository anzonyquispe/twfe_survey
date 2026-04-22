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
cap program drop checkmerge3
program define checkmerge3
	drop if _merge==2
	assert _merge==3
	drop _merge
end

****run prep routines
qui do "$do/subroutines/0. Process Output Deflator Series.do"
qui do "$do/subroutines/0. Process Input Deflator Series.do"
qui do "$do/subroutines/0. Process natl gdp deflator.do"
qui do "$do/subroutines/Clean state codes.do"
qui do "$do/subroutines/create supernics.do"
qui do "$do/subroutines/get backward (seller) electricity intensity.do"
qui do "$do/subroutines/get forward (buyer) electricity intensity.do"

use "$intdata/ASI 1992-2010_stacked.dta", clear

***********FIX MULTIPLIER SCALING
replace mult = mult/100 if year<1998

***********DEMULTIPLY YEARS 1993-1997 (according to tech docs these are premultiplied)
qui foreach var of varlist  numfact fcapopen-  stfgcl {
replace `var' = `var'/mult if year>=1993 & year<=1997
}
***********SCHEME CODES
g scheme_final=0
replace scheme=1 if year<=1996 & (schcode==1 | schcode==3 | schcode==6 | schcode==2 | schcode==7)
replace scheme=1 if year==1997 & schcode==1
replace scheme=1 if schcode==1 & year>=1998
lab def scheme 0 "Sample" 1 "Census"
lab values scheme_final scheme
tab year scheme_final
*drop schcode


*********OPEN CLOSED CODES
bys year: tab opclcode
g openclose_final=0
replace openclose_final = 1 if opclcode==1 & year>=1998
replace openclose_final = 1 if opclcode!=1 & year==1997
replace openclose_final = 1 if opclcode!=0 & year<=1996
lab def openclosed 0"Open" 1"Closed"
label values openclose_final openclosed

*****CLEAR OUT OBS REPORTED AS CLOSED
tab openclose_final
tab openclose_final, nola
keep if openclose_final==0
drop openclose_final

*********ORGANIZATION CODE
bys year: tab orgcode, mi


***********STATE CODES
merge m:1 stcode year using "$work/statecodes", 
drop if _m==2 
****DROP A SMALL NUMBER OF OBSERVATIONS WITH
****STATE CODES THAT CANNOT BE IDENTIFIED
drop if _m==1
drop _m
drop stcode
drop if state=="SIKKIM" | state=="Sikkim" //sikkim is only surveyed in 2009-10; drop
	***FIX STATES TO CONCORD OVER TIME
	tab state, mi
	g state_consistent=state
	replace state_consistent="UTTAR PRADESH" if state=="UTTARANCHAL"
	replace state_consistent="MADHYA PRADESH" if state=="CHHATTISGARH"
	replace state_consistent="BIHAR" if state=="JHARKHAND"

***outsheet master state list
preserve
keep state
duplicates drop
save "$work/statelist.dta",replace
restore

****nics are now concorded in new data
bys year: sum nic87, d
**********FIX NICS & SELECT MANUFACTURING ONLY
replace nic87=floor(nic87/10) if year<1998
drop if nic87>=390 & nic87<.
count if nic87==.
drop if nic87==.
replace nic87=279 if nic87==278 //this is an errant nic code; replace into neighbor

***********FIX NIC87 CODES WITH MULT:MULT CONCORDANCES IN NIC2==23, 24, 25
***********CONCORDANCE FROM 98 FORWARDS GROUPS ALL COTTON TEXTILES SUBINDUSTRIES INTO ONE 3DIGIT CODE (SAME FOR GARMENTS AND SYNTHETIC TEXTILES)---MUST APPLY THIS TO DATA ORIGINALLY IN NIC1987
forval i=3/5 {
replace nic87=2`i'0 if nic87>=2`i'1 &nic87<=2`i'9
}


	
***********perform cleaning 
foreach var of varlist fcapopen fcapclose labcost total_bonus qelecpur fuels qeleccons velecsold velecpur qelecprod  qelecsold matls grsale {
g neg_`var'_flag= `var'<0
replace `var' = 0 if `var'<0
}

foreach var of varlist fcapclose totpersons matls grsale {
g zero_`var'_flag=`var'==0
}



replace qelecprod=0 if qelecprod==. & year>=1998

g nic3digit=nic87

********OTHER CLEANING
g fuelelec=fuels + velecpur if year>=1993
replace fuelelec=fuels if year<1993


/* 
***THE FOLLOWING IS DONE BECAUSE THERE IS NO VELECPUR IN YEARS PRIOR TO 1993 SO CANT BACK 
***OFF NON-ELEC FUELS SPENDING FOR THOSE YEARS SO CANT DEFINE FUELS CONSISTENTLY ACROSS 
***YEARS; SO CLEAN OUT; REFER TO HUNTS EMAIL 30 MARCH 2013 "UPDATES TO DATA PREP CODE" FOR MORE 
***THIS HAS BEEN ADJUSTED TO ACCOUNT FOR THE DETAILED RECORD LAYOUT DATA NEWLY PURCHASED FOR 93 & 94; NOW ONLY 92 SUMMARY DATA DOESNT HAVE VELECPUR
replace fuels =. if year<1993
*/
/* Back back off purchased electricity from fuels in 1992 */
*get median purchase price in 1993
sum fuels if year==1992, d //higher median makes sense--includes elec purchased
sum fuels if year==1993, d
g check = velecpur/qelecpur if year==1993 //unit electricity cost
sum check, d
*multiply by qelecpur in 1992
g velecpur2 = r(p50)*qelecpur if year==1992
*subtract off fuels in 1992
replace fuels = fuels-velecpur2 if year==1992 & (fuels-velecpur2)>0 //latter condition keeps from assigning about 25% of obs to have negative fuels values; doing this, distributions look OK; not doing this, they look way off
sum fuels if year==1992, d //see progression
sum fuels if year==1993, d
sum fuels if year==1994, d
drop check velecpur2

**********merge in deflators
merge m:1 nic3digit year using "$data/Deflators/final input deflator.dta"
checkmerge3

merge m:1 nic3digit year using "$data/Deflators/final output deflator.dta"
checkmerge3
drop nic3digit


****merge in capital deflator
preserve
insheet using "$data/Deflators/RBI Capital Formation Accounts.csv", comma names clear
tab year
keep year capital_deflator 
replace year = substr(year,1,4)
destring year, replace
tempfile capdefl
save `capdefl'
restore
merge m:1 year using `capdefl'
checkmerge3

	
****merge in electricity deflator
preserve
insheet using "$data/Deflators/electricity deflator_RBI.csv", comma names clear
keep year electricity_deflator 
g base=electricity_deflator if year=="2004-05"
egen basedefl=sum(base)
replace electricity_deflator=electricity_deflator/basedefl*100
drop base*
replace year = substr(year,1,4)
destring year, replace
tempfile elecdefl
save `elecdefl'
restore
merge m:1 year using `elecdefl'
checkmerge3
	
****merge in statewise gdp deflator
merge m:1 state year using "$work/state gdp deflator.dta"
checkmerge3

merge m:1 year using "$work/gdp_defl_natl.dta"
checkmerge3
***ALL ACCOUNTS NOW IN 2004-05 BASE YEAR REAL RS AS OF 18 MARCH 2013
cap drop rank 
cap drop _m
duplicates drop


****MATCH IN POST1998 PANEL IDS TO EARLIER YEARS
*assert statename==state
merge m:1 state_consistent permid using "$work/1998 matched Panel IDs.dta"
tab _m
drop if _m==2
replace permid_1998=permid if year>=1998
g permid_1997=permid if _m==1 & year<=1997
rename permid permid_orig
drop _m


*******MERGE IN SUPERNICS
***criteria: 100 plantyear obs per group min after all the subsequent drops
merge m:1 nic87 using "$work/supernics"
checkmerge3


compress
label data "TSXC ASI92-10;Sample&Census"
save "$intdata/clean stacked ASI 1992-2010.dta", replace
use "$intdata/clean stacked ASI 1992-2010.dta", clear

*********IDENTIFY AND DROP OUT COST SHARE OUTLIERS; DROP PLANTS WITH NO GRSALES
*********RUNNING THE FOLLOWING CODE WILL AFFECT 
*********THE AGGREGATE CALCULATED FIGURES WHICH WE HAVE MATCHED WELL TO REPORTED FIGURES
*********IF WANT TO COLLAPSE DATA TO COMPARE TO PUBLISHED FIGURES
*********DO NOT RUN THE REMAINDER OF THIS CODE & JUST SAVE THE DATASET HERE
local count_orig=_N


*****CLEAR OUT OBS REPORTING NO SALES
count if grsale==. | grsale<=2
tab year if (grsale==. | grsale<=2) & scheme_final==1

local nosales=r(N)
drop if grsale==. | grsale<=2


*****CLEAR OUT OBSERVATIONS WITH HIGH COST SHARES
****CUTOFFS: LABOR, MATERIALS: CLEAN ANY >2
****CUTOFFS: ELECTRICITY: CLEAN ANY >1
****HERE WE CLEAN ONLY INPUTS REPORTED AS COSTS BUT NOT PHYSICAL QUANTITIES (LIKE TOTPERSONS & QELECPUR---THOSE ARE CLEANED LATER)
g ecostshare=velecpur/grsale
sum ecostshare, d
count
count if ecostshare>1 & !mi(ecostshare)
local ecost_out=r(N)

g fuelelecshare=fuelelec/grsale
local fecost_out=r(N)

g labcost2=labcost
replace labcost2=0 if labcost==.
g lcostshare=labcost2/grsale
sum lcostshare, d
count if lcostshare>2 & !mi(lcostshare)
local lcost_out=r(N)

g matls2=matls
replace matls2=0 if matls==.
g mcostshare=matls2/grsale
sum mcostshare, d
count if mcostshare>2 & !mi(mcostshare)
local mcost_out=r(N)

g fuels2=fuels
replace fuels2=0 if fuels==.
g fcostshare=fuels2/grsale
sum fcostshare, d
count if fcostshare>2 & !mi(fcostshare)
local fcost_out=r(N)


replace velecpur=. if ecostshare>1 & !mi(ecostshare)
replace fuelelec=. if fuelelecshare>1 & !mi(fuelelecshare)
replace labcost=. if lcostshare>2 & !mi(lcostshare)
replace matls=. if mcostshare>2 & !mi(mcostshare)
replace fuels=. if fcostshare>2 & !mi(fcostshare)




*****ADDITIONAL CLEANING---CLEAN FIELDS IF IMPLIED COST SHARE FROM PHYSICAL Q TOO HIGH
g impl_totpersonsshare=totpersons*1000/grsale   
replace totpersons=. if impl_totpersonsshare>1 & !mi(impl_totpersonsshare) /*this wage of 1000rs per year is arbitrary and quite lenient */

g impl_elecqconsshare=qeleccons*4.5 / grsale    
g impl_elecqconsshare1 = (qelecprod+qelecpur)*4.5 / grsale

foreach var in qeleccons qelecprod qelecpur {
	replace `var' = . if (impl_elecqconsshare>1 & !mi(impl_elecqconsshare)) | (impl_elecqconsshare1>1 & !mi(impl_elecqconsshare1))
}


******CLEAN OUT INDIVIDUAL ERRONEOUS OBSERVATIONS
replace totpersons = . if totpersons == 234900
replace totpersons = . if totpersons == 973308

*if multiple cost share outliers or implied cost share outliers then make sales missing
foreach i in impl_totpersonsshare impl_elecqconsshare ecostshare {
g `i'_flagZ=`i'>1 & !mi(`i')
}
foreach i in lcostshare mcostshare fcostshare {
g `i'_flagZ=`i'>2 & !mi(`i')
}
egen outflags=rowtotal(*_flagZ)
replace grsale=. if outflags>1

foreach var of varlist grsale {
drop if `var'==0 | 	`var'==. | `var'<3
}


drop *costshare labcost2 matls2 outflags *_flagZ

replace qeleccons=. if qeleccons==0 & nonelecind!=1 // These zeros are focused on particular years, so they are probably in fact missings, not true zeros. Furthermore, we probably do not want in the sample any manufacturing plant that truly consumes zero electricity anyway.
replace qelecpur=qeleccons-qelecprod if qelecpur==.  // This will make qelecpur = 0 in 4300 cases.
replace qelecprod=qeleccons-qelecpur if qelecprod==. // This does nothing, but just for symmetry.
replace qeleccons=qelecprod+qelecpur if qeleccons==.&qelecprod+qelecpur!=0 // This also appears to do nothing, but also for symmetry.
replace qelecprod = . if qelecprod==0&qeleccons==.&qelecpur==. // These are data points that are imported as "missing or zero" and called zero. But if qeleccons and qelecpur are also missing, then it seems more likely that qelecprod is missing instead of zero.

gen electricity_out = cond(year<=1996,qeleccons+qelecsold,qeleccons)
gen electricity_in = cond(year<=1996,qelecprod+qelecpur+qelecsold,qelecprod+qelecpur)
gen flag = cond(electricity_out/electricity_in>1.1|electricity_out/electricity_in<0.9,1,0)
replace flag = 0 if (electricity_out==0&electricity_in==0)|(electricity_out<1000)&(electricity_in<1000)
replace flag = 0 if qelecprod==.&qelecpur==.&qeleccons!=. // This changes no cases.
foreach var of varlist qelecprod qelecpur qelecsold qeleccons {
replace `var' = . if flag==1
}
drop flag electricity_out electricity_in

 

local count_final=_N
dis "orig count `count_orig'"
dis "no reported sales `nosales'"
dis "ecost outliers `ecost_out'"
dis "lcost outliers `lcost_out'"
dis "mcost outliers `mcost_out'"
dis "final count `count_final'"



*****DEFLATE ACCOUNTS, 2004-05 BASE YEAR
g grsale_defl=grsale/deflator*100
g matls_defl=matls/input_deflator*100

g fcapopen_defl=fcapopen/(capital_deflator) /*the deflator base is 2004, dividing by .540512 would put as base 1993 */
g fcapclose_defl=fcapclose/(capital_deflator) /*the deflator base is 2004, dividing by .540512 would put as base 1993 */
g grocc_inv_defl=gross_investment/(capital_deflator) /*the deflator base is 2004, dividing by .540512 would put as base 1993 */
g velecsold_defl= velecsold/electricity_deflator*100
g velecpur_defl= velecpur/gdp_defl_natl /* this is the only deflation that is done using a NATIONAL deflator not specific to product or industry */
g fuels_defl= fuels/electricity_deflator*100
g fuelelec_defl= fuelelec/electricity_deflator*100
g labcost_defl = labcost/gdp_defl_natl
*keep the separate fuels_noSG variable, which is max(0,fuels-qelecprod*7.0)
g fuels_noSG_defl = max(0,fuels_defl-qelecprod*7.0*!mi(qelecprod)) //make sure is positive
replace fuels_noSG_defl = . if fuels_defl==.
g matls_fuels_defl = matls_defl + fuels_defl //materials plus fuels without taking off selfgen expenditures
g matls_fuels_noSG_defl = max(0,matls_defl + fuels_defl-7.0*qelecprod)  //materials plus fuels taking off selfgen expenditures
replace matls_fuels_noSG_defl = . if matls_defl==.

foreach i in grsale matls  fcapopen fcapclose gross_investment velecsold velecpur fuels fuelelec labcost {
rename `i' `i'_nominal
}

*********************
*****set the panel
*********************
//this is now old code; the new release of the ASI panel data USES THE SAME ID SCHEME AS THE pre-1998 data
//just need to clear the state codes off the 1998+ years 
//so keep this old processing to ensure that this is the case (that the panels match between the two methods)
//this change will allow us to capture many of more of sample scheme plants across years which couldnt be matched just in 1998
***adjust <1997-format permids to ensure they will not spuriously overlap with any >=1998-format permids
tostring permid_1997, replace
replace permid_1997=permid_1997+"_1997"
tostring permid_1998, replace
replace permid_1998=permid_1998+"_1998"

***now post new 1997 permids into permid1998
replace permid_1998=permid_1997 if permid_1998=="._1998"
drop permid_1997

***	check uniqueness---we know that at least one year has the permids cleared out for sample scheme plants
gsort state_consistent  permid_1998 year
bys state_consistent  permid_1998 year: g rank=_N
bys year: tab rank, mi
drop rank
***the odd year is 1995-96

***this is the code to use the new permids
g permid2=permid_orig
replace permid2=floor(permid2/100) if year>=1998	//clear off last two digits (state codes) from 1998+ years of data

//visual inspection
order state_con permid_1998 permid_orig permid2 year scheme_final
gsort state_con permid_1998 permid_orig permid2 year 
g same_aslast_1998=permid_1998==permid_1998[_n-1]
g same_aslast_new=permid2==permid2[_n-1]
g same_aslast_check=same_aslast_1998!=same_aslast_new
order same_aslast*, after(permid2)
tab same_aslast_check scheme_final  //dont worry too much about the flags in census, as it has to do with the sort order & plants switching between census and sample
//by inspection, definitely use the new codes, apply same methodology to remove dupes as before
drop permid_1998 same_aslast*
rename permid2 permid_final

*** clear out erroneous the dupes from the panel (treat as plants that can not (will not) be matched across years)
*assign made-up nonrepeated unique ids into permid1998 for nonuniq permids
g dummypermid=_n*100000 //this puts the dummy permids outside the range of any existing real permid
bys state_con permid_final year: g rank=_N
tab rank
//these are largely concentrated in the earlier years of data, and there is no obvious pattern as to how to treat:
//multiple plants under same id? revision to underlying accounts and original entry not removed? or one preferenced over the other? No response from MOSPI on how to treat. Either way, is only tiny fraction of sample.
replace permid_final=dummypermid if rank>1  
drop  dummypermid rank


********IDENTIFY THE PLANT PANEL
tab scheme_final, mi
assert permid_final!=.
tab year


egen panelgroup=group(state_consistent permid_final)
xtset panelgroup year

bys panelgroup: g masterrank=_N
tab masterrank
tab masterrank if scheme_final==0
tab masterrank if scheme_final==1

****this must be done right before the alpha subprograms are called
encode nic87_super, g(snic)
g nic2=substr(string(nic87),1,2)

***** Get median electricity price
include "$do/subroutines/get median e price.do" 

***** CLEAN ELECTRICITY VARIABLES
include "$do/subroutines/Clean Electricity Variables.do"


save "$work/temp2", replace
erase "$intdata/clean stacked ASI 1992-2010.dta"
**********CALCULATE AND POST IN COST SHARES AND LAMBDA
use "$work/temp2", clear
include "$do/subroutines/Estimate median alphas_qreg_supernic_Nov2014.do" 
save "$work/M and L shares from qreg_step1_Nov2014", replace

use "$work/temp2.dta", clear
**/

merge m:1 snic year using "$work/M and L shares from qreg_step1_Nov2014", assert(3) nogen keepusing(mshare_final lshare_final betak_CRS_final eshare_final)

*****DROP PRODUCTIVITY OUTLIERS MORE THAN 3.5 DIFFERENCE FROM MEDIAN PRODUCTIVITY
g lnY=ln(grsale_defl+1)
g lnK=ln(fcapclose_defl+1)
g lnL=ln(totpersons+1)
	replace lnL=ln(totemp+1) if totpersons==. & totemp!=. //for some reason, totpersons is null in 98 and 99?
g lnM=ln(matls_defl+1)
g lnM_fuels_orig=ln(matls_fuels_defl+1)
g lnM_fuels_noSG_orig=ln(matls_fuels_noSG_defl+1)
g lnF=ln(fuels_defl+1)
g lnF_noSG =ln(fuels_noSG_defl+1)
g lnE=ln(qeleccons+1)
g lnFE=ln(fuelelec_defl+1)

gen lnlabcost_defl = ln(labcost_defl+1)
save "$work/temp2", replace
*****CALCULATE PRODUCTIVITY TERM
g lnW=lnY-mshare_final*lnM-lshare_final*lnL- betak_CRS_final*lnK -eshare_final*lnE
g lnW2=lnY-mshare_final*lnM-lshare_final*lnL- betak_CRS_final*lnK
pwcorr lnW lnW2
bys year: sum lnW, d
sum lnW, d
*****DROP PRODUCTIVITY OUTLIERS
sum lnW, d
cap drop check
g check = abs(r(p50)-lnW)>3.5 & lnW!=.
tab check
sum lnW, d
drop if abs(r(p50)-lnW)>3.5 & lnW!=. //this drops a few outliers
assert _N==615721
drop  lnW lnW2 mshare_final lshare_final betak_CRS_final eshare_final check
save "$work/temp2", replace
**********AFTER DROPPING PRODUCTIVITY OUTLIERS, REESTIMATE MEDIAN COST SHARES, ETC AND REPOST IN
**********CALCULATE AND POST IN COST SHARES AND LAMBDA
do "$do/subroutines/Estimate median alphas_qreg_supernic_Nov2014.do" 
save "$work/M and L shares from qreg_Nov2014_step2", replace

use "$work/temp2.dta", clear

merge m:1 snic year using "$work/M and L shares from qreg_Nov2014_step2", assert(3) nogen keepusing(mshare_final lshare_final eshare_final lambda_final)
save "$work/temp2.dta", replace

*****Run CD nonCRS extraction for alphaK here
include "$do/subroutines/capital_regression_CDnoCRS.do"
tempfile temp
save `temp'
use "$work/temp2", clear
merge m:1 nic87_super using `temp', keepusing(betak) assert(1 3) nogen
//here i am posting in the median nonCRS capital coefficient when nonCRS capital coefficient is negative; flag was made just above
qui sum betak, d
replace betak=r(p50) if betak<0 | betak==. //latter captures one industry that gets dropped altogether from the GMM routine for having very high L+M share
*****CALCULATE PRODUCTIVITY TERM
g lnW=lnY-mshare_final*lnM-lshare_final*lnL-betak*lnK -eshare_final*lnE
label var lnW "Cobb-Douglas, no CRS assumption"
renvars mshare_final lshare_final betak /  mshare_CD lshare_CD betak_CDnoCRS
save "$work/temp2", replace


*****CALCULATE PRODUCTIVITY TERM: CD with CRS (input alphas from from all plants, alphaK = 1-alphaM-alphaL)
g betak_CDwCRS = 1 - mshare_CD - lshare_CD -eshare_final
sum betak_CDwCRS, d
replace betak_CDwCRS = r(p1) if betak_CDwCRS<0
assert  betak_CDwCRS>0.0
g lnW_CDwCRS=lnY-mshare_CD*lnM-lshare_CD*lnL-betak_CDwCRS*lnK -eshare_final*lnE
label var lnW_CDwCRS "Cobb-Douglas, with CRS assumption"
*****CALCULATE PRODUCTIVITY TERM:CD but treat matls diff (input alphas from all plants but using different materials term, alphaK from GMM estimation on all plants with different materials term)
**first get two different materials coefficients
save "$work/temp2", replace
do "$do/subroutines/Estimate median alphas_qreg_supernic_altMatls_Nov2014.do" 
save "$work/M and L shares from qreg_Nov2014_step3", replace

use "$work/temp2.dta", clear

merge m:1 snic year using "$work/M and L shares from qreg_Nov2014_step3", assert(3) nogen keepusing(mshare_fuels_final mshare_fuels_noSG_final )
save "$work/temp2.dta", replace

***then get nonCRS capital coefficients using each
*first for mshare_fuels_final
use "$work/temp2.dta",clear
g mshare_final = mshare_fuels_final
g lshare_final = lshare_CD
save "$work/temp2.dta", replace
use "$work/temp2.dta",clear
include "$do/subroutines/capital_regression_CDnoCRS.do"
tempfile temp
save `temp'
use "$work/temp2", clear
merge m:1 nic87_super using `temp', keepusing(betak) assert(1 3)
replace betak = betak_CDwCRS if _m==1 //for a few industries that get dropped based on the 95% criteria now being exceeded in the capital coef process
drop _m
//here i am posting in the median nonCRS capital coefficient when nonCRS capital coefficient is negative; flag was made just above
qui sum betak, d
replace betak=r(p50) if betak<0
rename betak betak_matls_fuels
save "$work/temp2.dta", replace
***then get nonCRS capital coefficients using each
*first for mshare_fuels_noSG_final
replace mshare_final = mshare_fuels_noSG_final
save "$work/temp2.dta", replace
include "$do/subroutines/capital_regression_CDnoCRS.do"
tempfile temp
save `temp'
use "$work/temp2", clear
merge m:1 nic87_super using `temp', keepusing(betak) assert(1 3)
replace betak = betak_CDwCRS if _m==1 //for a few industries that get dropped based on the 95% criteria now being exceeded in the capital coef process
drop _m
//here i am posting in the median nonCRS capital coefficient when nonCRS capital coefficient is negative; flag was made just above
qui sum betak, d
replace betak=r(p50) if betak<0
rename betak betak_matls_fuels_noSG
drop mshare_final lshare_final
save "$work/temp2.dta", replace



***then calculate productivity
**first clean the new lnM measures if there is an issue with missing fuels or elec
replace lnM_fuels_orig = lnM if mi(lnM_fuels_orig) & !mi(lnM) //this will post back in lnM when fuels is missing -- so missing fuels has no effect on the calculation
g lnW_M_fuels=lnY-mshare_fuels_final*lnM_fuels_orig-lshare_CD*lnL-betak_matls_fuels*lnK -eshare_final*lnE
label var lnW_M_fuels "Cobb-Douglas, no CRS assumption, alternative materials including fuels"

replace lnM_fuels_noSG_orig = lnM_fuels_orig if mi(lnM_fuels_noSG_orig) & !mi(lnM_fuels_orig)
g lnW_M_fuels_noSG=lnY-mshare_fuels_noSG_final*lnM_fuels_noSG_orig-lshare_CD*lnL-betak_matls_fuels_noSG*lnK -eshare_final*lnE
label var lnW_M_fuels "Cobb-Douglas, no CRS assumption, alternative materials including fuels and backing off selfgen elec cost"



save "$work/temp2", replace
*****Extract Leontief coefficients
use "$work/temp2", clear
do "$do/subroutines/Estimate median alphas_qreg_supernic_Nov2014_leontief.do" 
save "$work/M and L shares from qreg_Nov2014_leontief", replace

use "$work/temp2.dta", clear

merge m:1 snic year using "$work/M and L shares from qreg_Nov2014_leontief", assert(1 3) keepusing(mshare_leontief lshare_leontief eshare_leontief betak_leontief_CRS  lambda_leontief)
count if _m==1
assert r(N)==14 //only 14 are lost from no estimated coefs in this case; is fine
drop _merge

g lnW_leontief_CRS=lnY-mshare_leontief*lnM-lshare_leontief*lnL-betak_leontief_CRS*lnK
label var lnW_leontief_CRS "Leontief with CRS assumption"
save "$work/temp2.dta", replace

***FINAL VARIANT: Leontief, no CRS (input alphas from nongenerators only, alphaK from GMM estimation on nongenerators only, adjust coefficients by 1/[1-electricityshare])
include "$do/subroutines/capital_regression_Leontief_noCRS.do"
tempfile temp
save `temp'
use "$work/temp2", clear
merge m:1 nic87_super using `temp', keepusing(betak_leontief_noCRS) assert(1 3) nogen
//here i am posting in the median nonCRS capital coefficient when nonCRS capital coefficient is negative; flag was made just above
qui sum betak_leontief_noCRS, d
count if betak_leontief_noCRS<0
replace betak_leontief_noCRS=r(p50) if betak_leontief_noCRS<0 |  betak_leontief_noCRS==.
*****CALCULATE PRODUCTIVITY TERM
g lnW_leontief_noCRS=lnY-mshare_leontief*lnM-lshare_leontief*lnL-betak_leontief_noCRS*lnK
label var lnW_leontief_noCRS "Leontief, no CRS assumption"
save "$work/temp2", replace

***unconditional median cost share extraction
tempfile temp
save `temp'
do "$do/subroutines/1h_Extract median alphas_direct_supernic_Nov2014.do" 
save "$work/M and L shares from qreg_Nov2014_unc", replace
use `temp', clear

merge m:1 snic using "$work/M and L shares from qreg_Nov2014_unc", assert(3) keepusing(mshare_unc lshare_unc betak_CRS_unc) nogen
g lnW_CDwCRS_unc =lnY-mshare_unc*lnM-lshare_unc*lnL-betak_CRS_unc*lnK -eshare_final*lnE  


/* Generate Profit variable */
gen Profit = (grsale_nominal-matls_nominal-labcost_nominal-fuelelec_nom)/gdp_defl_natl
gen lnProfit = ln((grsale_nominal-matls_nominal-labcost_nominal-fuelelec_nom)/gdp_defl_natl)


/* THIS WILL ASSIGN THE POST2000 NEW SPLIT STATES BACKWARDS IN ORDER TO KEEP THE 
PANELID CONSISTENT WITHIN THE CLUSTER (REQMT OF XTREG) WHILE AVOIDING REDUCTION IN THE # OF CLUSTERS */
gsort panelgroup -year
bys panelgroup: g rank=_n
bys panelgroup: g rank2=_N
tab state
replace state=state[_n-1] if panelgroup==panelgroup[_n-1] & rank!=1  
tab state

** Also do the same for supernics and nic2. Generate a variable snicc, for "constant supernic." The code below assigns the last supernic backwards.
g nic2num=real(substr(string(nic87),1,2)) // Generate the nic2num

foreach indlevel in snic nic2num {
	gen `indlevel'c = `indlevel'
	gsort panelgroup -year
	replace `indlevel'c=`indlevel'c[_n-1] if panelgroup==panelgroup[_n-1] & rank!=1  
}
drop rank rank2

**********************************************************************
**********************************************************************
cap log c
log using "$work/inspect changes in log accounts.txt", t replace
*******INSPECT DISTRIBUTION OF CHANGES IN LOG ACCOUNTS
foreach i in Y K L M F E {
gsort panelgroup +year
g dln`i' = d.ln`i'
sum dln`i', d
sum dln`i' if dln`i'<r(p95) & dln`i'>r(p5), d
winsor dln`i' , generate(wdln`i') p(0.025)
sum wdln`i', d
drop wdln`i'
}
cap log c

gsort panelgroup +year
sum dlnE if qeleccons==0 , d
sum dlnE if  qeleccons[_n-1]==0 & panelgroup==panelgroup[_n-1], d
sum dlnE if qeleccons!=0 & qeleccons[_n-1]!=0  & panelgroup==panelgroup[_n-1], d   /*THIS LOOKS REASONABLE */
sum dlnE if abs(dlnE)<3.5, d   /*BY CONSTRUCTION THIS LOOKS EVEN MORE REASONABLE */


** Generate flags
gsort panelgroup +year
bys panelgroup: g rank=_n
bys panelgroup: g rank2=_N

foreach i in lnK lnW lnY lnL lnE lnF lnF_noSG lnM lnqelecprod lnqelecpur lnqelecsold lnvelecsold_defl lnW_CRS  lnW_CDwCRS lnW_M_fuels lnW_M_fuels_noSG lnW_leontief_CRS lnW_leontief_noCRS lnW_CDwCRS_unc lnFE lnlabcost_defl lnProfit {
	g `i'_flag=0
	gsort panelgroup +year
	g forw_d`i'=`i'-`i'[_n+1] if panelgroup==panelgroup[_n+1]
	g back_d`i'=`i'-`i'[_n-1] if panelgroup==panelgroup[_n-1]

	* Gen 2 levels of this flagging: cutoff 1.5 and 3.5 within one variable
	foreach j in 1.5 3.5 {
		replace `i'_flag=`j' if back_d`i'>`j'&forw_d`i'>`j' & !mi(forw_d`i') & !mi(back_d`i') // Large increase
		replace `i'_flag=`j' if back_d`i'<-`j'&forw_d`i'<-`j' & !mi(forw_d`i') & !mi(back_d`i') // Large decrease
		replace `i'_flag=`j' if forw_d`i'>`j'&rank==1 & !mi(forw_d`i') 
		replace `i'_flag=`j' if back_d`i'>`j'&rank==rank2 & !mi(back_d`i') 
	}
}
drop rank*



********POST IN ADDITIONAL GENERATION VARIABLES
gen SGS = qelecprod/qeleccons // Self-generation share
	replace SGS = min(SGS,1) if SGS!=.
	replace SGS  = max(SGS,0) if SGS!=.

g elec_producer=qelecprod>0 & qelecprod!=.
replace elec_producer=. if qelecprod==.
gsort panelgroup year

bys panelgroup: egen anyyearEprod=sum(elec_producer)
bys panelgroup: gen cumEprodyrs=sum(elec_producer)
g selfgen_beforeT=cumEprodyrs>0   

	assert anyyearEprod!=.
	replace anyyearEprod=1 if anyyearEprod>0
	tab anyyearEprod, mi

gsort panelgroup year



*****CHECK PANEL
cap drop masterrank
bys panelgroup: g masterrank=_N
tab masterrank


*** MERGE MECS DATA 
rename nic87 nic87_1 // This is the first numerical nic87 3-digit code within the supernic. 
merge m:1 nic87_1 using "$work/supernic_MECSdata.dta", keep(match master) keepusing(NAICS) nogen
rename nic87_1 nic87_2 // Second numerical code
preserve
use "$work/supernic_MECSdata.dta", clear
drop if nic87_2==.
tempfile MECStemp
save `MECStemp'
restore
merge m:1 nic87_2 using `MECStemp', keep(match master match_up) keepusing(NAICS) nogen update
* Then actually merge the MECS data
merge m:1 NAICS using "$work/MECSdata.dta", assert(3) keep(match master) keepusing(prod_cons_MECS) nogen
rename nic87_2 nic87
drop NAICS

*** GENERATE OTHER VARIABLES
encode state, gen(statenum)


* Fuel cost and self- generation variables and flags
gen lnFE_Y = ln((fuelelec_defl+1)/grsale_defl)
gen lnF_Y = ln((fuels_defl+1)/grsale_defl)

gen lnFE_Y_flag = lnY_flag+lnF_flag+lnE_flag
gen lnF_Y_flag = lnY_flag+lnF_flag
gen SGS_flag = lnqelecprod_flag+lnE_flag


*construct differentiated labor shares (share contracted+unpaid, share white collar)
g laborshare_contracted=work_cont_avg/totpersons
sum laborshare_contracted, d
replace laborshare_contracted = 0 if laborshare_contracted==. & !mi(totpersons)
replace laborshare_contracted =. if laborshare_contracted >1

g laborshare_whitecollar = supervis_avg/totpersons
sum laborshare_whitecollar , d
replace laborshare_whitecollar = 0 if laborshare_whitecollar ==. & !mi(totpersons)
replace laborshare_whitecollar =. if laborshare_whitecollar >1


*merge in input and output industries' lambdas
g nic3digit=nic87
merge m:1 nic3digit using "$work/output elec intensity.dta", keep(1 3) assert(3) nogen
merge m:1 nic3digit using "$work/input elec intensity.dta", keep(1 3) assert(3) nogen

cap rename grocc_inv_defl gross_inv_defl
g investment_rate = gross_inv_defl/fcapopen_defl
replace investment_rate =. if investment_rate <0
sum investment_rate , d
replace investment_rate =. if investment_rate >3
sum investment_rate , d


compress

label data "unbal plant panel ASI92-10"
save "$intdata/ASIpanel_fulldataset_Nov2014.dta", replace

**here get production function coefficients when including a size term
include "$do/subroutines/Estimate median alphas_qreg_supernic_size_Dec2014.do"

use "$intdata/ASIpanel_fulldataset_Nov2014.dta", clear
rename eshare_final eshare_orig //because this is what is used in later code so set aside to keep name
merge m:1 snic year using "$work/sharecapture_size", keepusing(mshare_final lshare_final eshare_final mshare_sizetrend lshare_sizetrend eshare_sizetrend) assert(3) nogen
bys panelgroup: egen med_lnY = median(lnY)
xtile quintile=lnY, n(5)
foreach i in mshare lshare eshare {
replace `i'_final = `i'_final +med_lnY*`i'_sizetrend
drop `i'_sizetrend
}
*now run the capital estimation
save "$work/temp2.dta", replace

*****Run CD nonCRS extraction for alphaK here
include "$do/subroutines/capital_regression_CDnoCRS_size.do"
tempfile temp
save `temp'
use "$work/temp2", clear
merge m:1 nic87_super quintile using `temp', keepusing(betak) assert(1 3) nogen
//here i am posting in the median nonCRS capital coefficient when nonCRS capital coefficient is negative; flag was made just above
qui sum betak, d
replace betak=r(p50) if betak<0 | betak==. //latter captures one industry that gets dropped altogether from the GMM routine for having very high L+M share

foreach i in mshare lshare eshare {
rename `i'_final `i'_sizetrend
}
rename betak betak_sizetrend

g lnW_CDnoCRS_sizetrend = lnY-mshare_sizetrend*lnM-lshare_sizetrend*lnL-betak_sizetrend*lnK  -eshare_sizetrend*lnE

rename  eshare_orig eshare_final //because this is what is used in later code so keep name




** Generate flags
gsort panelgroup +year
bys panelgroup: g rank=_n
bys panelgroup: g rank2=_N
	g lnW_CDnoCRS_sizetrend_flag=0
	gsort panelgroup +year
	g forw_dlnW_CDnoCRS_sizetrend=lnW_CDnoCRS_sizetrend-lnW_CDnoCRS_sizetrend[_n+1] if panelgroup==panelgroup[_n+1]
	g back_dlnW_CDnoCRS_sizetrend=lnW_CDnoCRS_sizetrend-lnW_CDnoCRS_sizetrend[_n-1] if panelgroup==panelgroup[_n-1]

	* Gen 2 levels of this flagging: cutoff 1.5 and 3.5 within one variable
	foreach j in 1.5 3.5 {
		replace lnW_CDnoCRS_sizetrend_flag=`j' if back_dlnW_CDnoCRS_sizetrend>`j'&forw_dlnW_CDnoCRS_sizetrend>`j' & !mi(forw_dlnW_CDnoCRS_sizetrend) & !mi(back_dlnW_CDnoCRS_sizetrend) // Large increase
		replace lnW_CDnoCRS_sizetrend_flag=`j' if back_dlnW_CDnoCRS_sizetrend<-`j'&forw_dlnW_CDnoCRS_sizetrend<-`j' & !mi(forw_dlnW_CDnoCRS_sizetrend) & !mi(back_dlnW_CDnoCRS_sizetrend) // Large decrease
		replace lnW_CDnoCRS_sizetrend_flag=`j' if forw_dlnW_CDnoCRS_sizetrend>`j'&rank==1 & !mi(forw_dlnW_CDnoCRS_sizetrend) 
		replace lnW_CDnoCRS_sizetrend_flag=`j' if back_dlnW_CDnoCRS_sizetrend>`j'&rank==rank2 & !mi(back_dlnW_CDnoCRS_sizetrend) 
	}

	

	

save "$intdata/ASIpanel_fulldataset_Nov2014.dta", replace

erase "$work/temp2.dta"
/* dont do this until program is all set from round of edits
erase "$intdata/ASI 1992-2010_stacked.dta"
*/


/* Get State-Level Data from ASI */
use "$intdata/ASIpanel_fulldataset_Nov2014.dta",clear

/* Top-code and bottom-code variables */
	* Get median and percentiles based only on factories that have positive sales or positive value of the variable.
global StateVars = "totpersons qeleccons qelecpur qelecprod qelecsold velecpur_defl velecsold_defl grsale_defl matls_defl fuels_defl"
*global StateVars_win = "totpersons_win qeleccons_win qelecpur_win qelecprod_win qelecsold_win velecpur_defl_win velecsold_defl_win grsale_defl_win matls_defl_win"


** Get de-meaned ShareElecSelfGen
bysort panelgroup: egen m_SGS=mean(SGS)
gen dm_SGS=SGS-m_SGS

** Windsorized variables
gen Rs_kWh_win = Rs_kWh_it
sum Rs_kWh_it, detail
replace Rs_kWh_win = . if Rs_kWh_it>r(p99)|Rs_kWh_it<r(p1)

foreach var in lnY lnW lnL lnM {
	gen `var'_win = `var'
	sum `var', detail
	replace `var' = . if `var' > r(p99) | `var' < r(p1)
}

** Variables for medians
gen SGS_med = SGS
rename Rs_kWh_it Rs_kWh_med

** Get means of key variables after dropping outliers
foreach var in SGS lnF_Y lnFE_Y lnM lnL lnY lnW {
	replace `var' = . if `var'_flag>=3.5
}

** Collapse to state averages
gen NumberofEstablishments = 1 
* req avail shortageMU Shortage pd pm PeakShortage shortagePDPM
collapse (first)  Rs_kWh_median ///
	(median) Rs_kWh_med SGS_med (sum) NumberofEstablishments $StateVars ///
	(mean) SGS dm_SGS elec_producer lnF Rs_kWh_win lnY_win lnW_win lnL_win lnM_win ///
		lnF_Y lnFE_Y lnM lnL lnY lnW [pweight=mult], by(state year)

gen SGS_state = qelecprod/qeleccons
gen Rs_kWh_state = velecpur_defl/qelecpur

save "$intdata/State-Level ASI_Nov2014.dta", replace

qui do "$do/subroutines/capital_regression_ols.do" //for summary table to compare against ols estimates even though we do not use them anymor
