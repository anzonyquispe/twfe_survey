******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
*********************************************************
* THIS FILE GENERATES FAR ICT CAPITAL STOCKS
**  Input  :FAR.dta
**	      invdeflators.dta
**  Output :2000capstock.dta 
********************************************************************
clear
set mem 100m

cd "H:\Raffaella\ICT\Files_March_07\0.ICT STOCKS\FAR"

use "FAR.dta"
gen yy=real(year)
replace yy = 1999 if year =="Pre 2000"
replace yy = 1996 if year =="Pre 1997"
replace yy = 1994 if year =="Pre 1995"
replace yy = 1991 if year =="Pre 1992"
replace yy = 1989 if year =="Pre 1990"
replace yy = 1985 if year =="Pre 1986"
replace yy = 1984 if year =="Pre 1985"
replace yy = 1981 if year =="Pre 1982"
replace yy = 1979 if year =="Pre 1980"
replace yy = 1975 if year =="Pre 1976"
replace yy = 1974 if year =="Pre 1975"
replace yy = 1972 if year =="Pre 1973"
replace yy = 1969 if year =="Pre 1970"
drop year
rename yy year
sort sic year

*  Price deflators
merge sic year using "invdeflators.dta"
drop if _merge==2
drop _merge
sort ruref year

*  Get depreciation rates
gen comp_dep = (1-0.34)^(2000-year)
gen soft_dep = (1-0.34)^(2000-year)
gen vehic_dep = (1-0.2)^(2000-year)
gen plant_dep = (1-0.15)^(2000-year)
gen build_dep = (1-0.02)^(2000-year)
gen land_dep = 1

*  Put it all together to get net values of investment at 2000 prices
*  invNet2000 = historic_cost*(100/Prabhat_price_deflator)*compound_deprecation_rate
gen compNet = computers*(100/c_def)*comp_dep
gen softNet = software*(100/s_def)*soft_dep
gen vehicNet = vehicles*(100/v_def)*vehic_dep
gen plantNet = plant*(100/p_def)*plant_dep
gen buildNet = buildings*(100/b_def)*build_dep
gen landNet = land*(100/b_def)*land_dep

*  Need this later: save as temporary file.
save temp1.dta, replace

*  Now sum it all up and it's done
collapse (sum) compNet softNet vehicNet plantNet buildNet landNet, by(ruref)
*  (this operation turns missing vals to 0)
recode compNet softNet vehicNet plantNet buildNet landNet (0=.)

*  Change names to emphasise metamorphosis into capstocks:
rename compNet khardwarec
rename softNet ksoftwarec
rename vehicNet vehicles
rename plantNet plant
rename buildNet buildings
rename landNet land
gen year=2000
sort ruref year
******************************************************************
save 2000capstock, replace
******************************************************************

*  Now we turn to the problem of estimating IT capital in other years
*  Input (section) :2000capstock.dta 
*			  temp1.dta  - file saved as part of first part of this do file
*  Output (section): FAR_ITcapstocks.dta


use temp1.dta, clear
keep if year > 1994
keep ruref sic year compNet softNet
sort ruref year

*  Merge the 2000 capital stock estimates
merge ruref year using 2000capstock.dta
keep ruref sic year khardwarec ksoftwarec compNet softNet

*  Calculate the implied capstocks given our assumptions
*working backwards...
gsort ruref -year
by ruref: replace khardwarec = (khardwarec[_n-1]-compNet[_n-1])/0.66 if khardwarec[_n-1]!=.
by ruref: replace ksoftwarec = (ksoftwarec[_n-1]-softNet[_n-1])/0.66 if ksoftwarec[_n-1]!=.

sort ruref year
*  Save the finished data set
save FAR_ITcapstocks, replace



*****************************************************************
** Prepare file for merging                                    **
*****************************************************************

* Convert in thousands of pounds
gen compNet1=compNet/1000
gen softNet1=softNet/1000
gen khardwarec1=khardwarec/1000
gen ksoftwarec1=ksoftwarec/1000


rename compNet1 hardinv_far
rename softNet1 softinv_far
rename khardwarec1 khardware_far
rename ksoftwarec1 ksoftware_far
keep ruref year khardware_far ksoftware_far
lab var khardware_far "Hardware Capital, FAR"
lab var ksoftware_far "Software Capital,FAR"
so ruref year
save farmerge.dta, replace
