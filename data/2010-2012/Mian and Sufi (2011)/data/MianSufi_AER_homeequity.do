clear
set more 1
set matsize 4000
set maxvar 15000
set logtype text
capture log close
set mem 700m
clear

global AER "C:\Documents and Settings\asufi\My Documents\Work\housingshock\AERFinal"
cd "$AER"

log using "$AER\MianSufi_AER_homeequity.log", replace

*********************************
*******  PROGRAMS/MACROS ********
*********************************
do "$AER\ProgramDefsHousingShock"
global censusvars "vac white black educ_lths educ_hs unemp pov urban" 
global incxvars "logpcw2002 logpcw9700 logpcw0002 logpcw0206 logpcp2002 logpcp9700 logpcp0002 logpcp0206 logtempl2002 logtempl9700 logtempl0002 logtempl0206"
global keepobs "moved_1997_1999==0 & owner3_1997>=1 & elasticity~=."
global keepobsCS "moved_1997_1999==0 & owner3_1997>=1 & elasticity~=. & logcsi0206!=. & logall0206!=."


*********************************************
******** REQUIRED DATA FILES          *******
*********************************************

*THE FOLLOWING 8 DATA SETS ARE USED TO CREATE FIGURES AND TABLES
*houseanal_temp_8mv.dta
*houseanal_temp_8ma.dta
*houseanal_temp_8mvCS.dta
*houseanal_temp_8miCS.dta
*houseanal_temp_8maCS.dta
*houseanal_temp_8msvCS.dta
*houseanal_temp_8mmvCS.dta
*houseanal_temp_8mtvCS.dta

*the end of the file names reveal how the data were sorted before grouping into groups of 5.
*_8mv means sorted by 1997 zipcode, whether the individual moved between 1997 and 1999, and then vantage score
*_8ma is same as first two, then age
*_8mi is same as first two, then 2008 estimated income
*_8msv is same as first two, then gender, then vantage score
*_8mmv is same as first two, then year moved, then vantage score
*_8mtv is same as first two, then number of mortgage accounts, then vantage score
*the CS stands for Cross-Sectional, meaning the data have been reshaped from a panel to a cross-section

*PROPRIETARY DATA
*In the construction of the above data sets, three of the data providers
*do not allow sharing of the data for free. We can only provide the above data sets
*to another researcher if we have explicit permission from the following data providers.
*Researchers will likely have to pay the data providers for access.
*
*EQUIFAX
*The individual and zip code level data are from EQUIFAX. Please contact
*Lori Pete at EQUIFAX (lori.pete@equifax.com)
*
*
*FISERV CASE SHILLER WEISS
*The zip code level house price indices are from FCSW. Please contact
*Cameron Rogers FISERV (cameron.rogers@fiserv.com)
*
*
*ZIP-CODES.COM
*Data matching zipcodes to CBSAs are from zip-codes.com. If you show
*proof of purchase of ths standard US Zip Code Database, that will
*be sufficient.
*
*
*We are willing to share the above data sets if researchers obtain explicit
*permission from Equifax and FCSW for the data. As mentioned before, we imagine
*that researchers will have to pay for some or all of these data.
*
*
*Atif Mian and Amir Sufi, June 2010


*********************************************
******** RESULTS                      *******
*********************************************


*******************
***** TABLES ******
*******************

*Data Intro numbers
use "$AER\houseanal_temp_8mvCS", clear
keep if logcsi0206!=. & logall0206!=.
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals

use "$AER\houseanal_temp_8mvCS", clear
keep if elasticity!=. & logcsi0206!=. & logall0206!=.
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals

use "$AER\houseanal_temp_8mvCS", clear
keep if elasticity!=. & logcsi0206!=. & logall0206!=. & owner3_1997>=1
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals

use "$AER\houseanal_temp_8mvCS", clear
keep if elasticity!=. & logcsi0206!=. & logall0206!=. & owner3_1997>=1 & moved_1997_1999==0
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals


***** TABLE I: Summary Stats By Elasticity
use "$AER\houseanal_temp_8mvCS", clear
replace age=age-11
keep if $keepobsCS
# delimit ;
tabstat allamount1997 homeamount1997 homevalmed1997 logall9802 logall0206 loghome9802 loghome0206
d2iallw1997win d2iallw9802win d2iallw0206win alldefrate1997 alldefrate9806 alldefrate0608 
vantage1997 ccardutil1997 age male inc2008 logcsi9802 logcsi0206 elasticity
logpcw0206 logpcp0206 logtempl0206 under659
, stat(n mean p50 sd) c(s);
# delimit cr
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals


**** TABLE II: IV of home-price channel, using across MSA variation
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
keep elasticity d2i* logall0206 logcsi0206 saiz* d2iallw1997win van* ccardutil* loginc* inc* male* age* cbsa_code $incxvars $censusvars d2iall*
replace vantage1997=vantage1997/100
xi: reg logcsi0206 elasticity, cluster(cbsa_code)
xi: ivreg logall0206 (logcsi0206=elasticity), cluster(cbsa_code)
xi: ivreg logall0206  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg logall0206  (logcsi0206=elasticity) i.van97p2 i.inc08p2 i.d2i97p2 i.agep2 male, cluster(cbsa_code)
xi: ivreg logall0206 (logcsi0206=elasticity) i.van97p2 i.inc08p2 i.d2i97p2 i.agep2 male $incxvars $censusvars, cluster(cbsa_code)
xi: ivreg d2iallw0206win (logcsi0206=elasticity), cluster(cbsa_code)
xi: ivreg d2iallw0206win  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg d2iallw0206win  (logcsi0206=elasticity) i.van97p2 i.inc08p2 i.d2i97p2 i.agep2 male, cluster(cbsa_code)
xi: ivreg d2iallw0206win (logcsi0206=elasticity) i.van97p2 i.inc08p2 i.d2i97p2 i.agep2 male $incxvars $censusvars, cluster(cbsa_code)


**** TABLE III: Marginal propensity to borrow in dollars
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
xi: reg equity0206 elasticity homevalmed2002, cluster(cbsa_code)
xi: ivreg all0206 (equity0206=elasticity)homevalmed2002 , cluster(cbsa_code)
xi: ivreg all0206  (equity0206=elasticity)  homevalmed2002 vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg all0206  (equity0206=elasticity) homevalmed2002 i.van97p2 i.inc08p2 i.d2i97p2 i.agep2 male, cluster(cbsa_code)
xi: ivreg all0206 (equity0206=elasticity) homevalmed2002 i.van97p2 i.inc08p2 i.d2i97p2 i.agep2 male $incxvars $censusvars, cluster(cbsa_code)


**** TABLE IV: Who responds more to home-price shocks?
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 d2iallw1997win loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
xi: ivreg logall0206 (logcsi0206 HPvantage1997=elasticity SZvantage1997) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male , cluster(cbsa_code)
xi: ivreg logall0206 (logcsi0206 HPccardutil1997=elasticity SZccardutil1997) vantage1997 ccardutil1997 loginc08 d2iallw1997win  age male , cluster(cbsa_code)
use "$AER\houseanal_temp_8mvdCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 d2iallw1997win loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
xi: ivreg logall0206 (logcsi0206 HPd2iallw1997win=elasticity SZd2iallw1997win) vantage1997 ccardutil1997 loginc08 d2iallw1997win  age male , cluster(cbsa_code)
*income
use "$AER\houseanal_temp_8miCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
pwcorr vantage1997 ccardutil1997 loginc08
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
xi: ivreg logall0206 (logcsi0206 HPloginc08=elasticity SZloginc08) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
*age
use "$AER\houseanal_temp_8maCS", clear
replace age=age-11
keep if $keepobsCS
replace vantage1997=vantage1997/100
pwcorr vantage1997 ccardutil1997 age
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
gen age65p=age>=65
replace age65p=. if age==.
xi: ivreg logall0206 (logcsi0206 HPage=elasticity SZage) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
*sex
use "$AER\houseanal_temp_8msvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
pwcorr vantage1997 ccardutil1997 male
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
xi: ivreg logall0206 (logcsi0206 HPmale= elasticity SZmale) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)



*TABLE V: EXCLUSION RESTRICTION TABLE
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
gen pcwshock=logpcw0206-logpcw9802
gen pcpshock=logpcp0206-logpcp9802
gen templshock=logtempl0206-logtempl9802
*Panel A
egen Ztag=tag(zipcode)
keep if Ztag==1
regress logpcp0206 elasticity, cluster(cbsa_code)
regress logpcw0206 elasticity, cluster(cbsa_code)
regress logtempl0206 elasticity, cluster(cbsa_code)
regress pcpshock elasticity, cluster(cbsa_code)
regress pcwshock elasticity, cluster(cbsa_code)
regress templshock elasticity, cluster(cbsa_code)
*Panel B: homeowners
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
xi: ivreg loghome0206 (logcsi0206=elasticity), cluster(cbsa_code)
xi: ivreg loghome0206 (logcsi0206 HPvantage1997=elasticity SZvantage1997) vantage1997 , cluster(cbsa_code)
xi: ivreg logcc0206 (logcsi0206=elasticity), cluster(cbsa_code)
xi: ivreg logcc0206 (logcsi0206 HPvantage1997=elasticity SZvantage1997) vantage1997, cluster(cbsa_code)
*Panel C: renters
use "$AER\houseanal_temp_8mmvCS", clear
keep if moved_1997_1999==0 & moved_1999_2001==0 &  owner3_1997==0 & elasticity~=. & aggcsi2000~=.
egen maxhomeamount=rmax(homeamount1997 homeamount1998 homeamount1999 homeamount2000 homeamount2001 homeamount2002 homeamount2003 homeamount2004 homeamount2005 homeamount2006)
keep if maxhomeamount==0
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
xi: ivreg logall0206 (logcsi0206=elasticity), cluster(cbsa_code)
xi: ivreg logall0206 (logcsi0206 HPvantage1997=elasticity SZvantage1997) vantage1997, cluster(cbsa_code)

**** TABLE VI: What is money being used for?
*First 4 columns--moving
use "$AER\houseanal_temp_8mmvCS", clear
replace movedyear_1997=movedyear_1997-1
gen moved=movedyear_1997!=.
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
*reg on msa averages
foreach var of varlist moved logcsi0206 vantage1997 ccardutil1997 loginc08 d2iallw1997win age male {
egen M`var'=mean(`var'), by(cbsa_code)
}
egen Mtag=tag(cbsa_code)
*Panel A
reg Mmoved Mlogcsi0206 Mvantage1997 Mloginc08 Md2iallw1997win Mage Mmale if Mtag==1, cluster(cbsa_code)
ivreg moved (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg logall0206  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male if movedyear_1997<2007, cluster(cbsa_code)
xi: ivreg logall0206  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male if movedyear_1997>=2007, cluster(cbsa_code)
*Panel B: Investment properties
use "$AER\houseanal_temp_8mtvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
}
gen mortrades0697=mortrades2006-mortrades1997
gen mortrades0602=mortrades2006-mortrades2002
gen mortrades0501=mortrades2005-mortrades2001
gen mortrades0599=mortrades2005-mortrades1999
sum mortrades05?? mortradesdiff* /*just a check*/
xi: reg mortradesdiff_2001_2005  logcsi0206 vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg mortradesdiff_2001_2005  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg logall0206  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male mortradesdiff_2001_2005, cluster(cbsa_code)
xi: ivreg logall0206  (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male if mortradesdiff_2001_2005==0, cluster(cbsa_code)
*Panel C: look at credit card balances for high utilization individuals
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
keep if ccardutil1997~=.
xtile ccardutilhigh=ccardutil1997, nq(4)
keep if ccardutilhigh==4
sum ccardutil1997
xi: ivreg logall0206 (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg logcc0206 (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg d2iallw0206win (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg d2iccw0206win (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)



*******************
***** FIGURES *****
*******************


********FIGURE II: ELASTIC VERSUS INELASTIC LEVERAGE AND DEBT TO INCOME
use "$AER\houseanal_temp_8mv", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
replace allamount=allamount*s_ctanav
replace autoamount=autoamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp autoamount
temp ZYwageav
temp s_ctanav
temp aggcsi

keep *_el *_in year
collapse (sum) allamount* autoamount* s_ctanav* (mean) aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp autoamount_el
temp autoamount_in
temp aggcsi_el
temp aggcsi_in


label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var autoamount_el_logd "Elastic MSAs"
label var autoamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
label var wage_el_logd "Elastic MSAs"
label var wage_in_logd "Inelastic MSAs"


*Figure 2a: housing prices
# delimit ;
graph twoway line aggcsi_in_d aggcsi_el_d year if year>=1998,
lp(solid dash) lw(thick thick)
title("Housing price growth, relative to 2001", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
ylabel(,labsize(medsmall))
ylabel(,labsize(medsmall))
xtitle("Year", size(medsmall)) 
ytitle("Benchmarked to 2001", size(medsmall))
legend(size(medsmall));
graph save "$AER\output\FigureIIa", replace;
# delimit cr

*Figure 2c: debt growth
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Total debt growth, relative to 2001", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
ylabel(,labsize(medsmall))
ylabel(,labsize(medsmall))
xtitle("Year", size(medsmall)) 
ytitle("Benchmarked to 2001", size(medsmall))
legend(size(medsmall));
graph save "$AER\output\FigureIIc", replace;
# delimit cr

*Figure 2d: debt to income
# delimit ;
graph twoway line d2i_in_d d2i_el_d year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Change in debt to income ratio, relative to 2001", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
ylabel(,labsize(medsmall))
ylabel(,labsize(medsmall))
xtitle("Year", size(medsmall)) 
ytitle("Benchmarked to 2001", size(medsmall))
legend(size(medsmall));
graph save "$AER\output\FigureIId", replace;
# delimit cr

# delimit ;
graph combine 
"$AER\output\FigureIIa" "$AER\output\FigureIIc" "$AER\output\FigureIId", col(1) ysize(6) xsize(3.5); 
graph save "$AER\output\FigureII", replace;
# delimit cr

********FIGURE III: Cross-sectional heterogeneity in across-MSA analysis
*Credit score
use "$AER\houseanal_temp_8mv", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
keep if vantage1997oq==1
replace allamount=allamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp autoamount
temp ZYwageav
temp s_ctanav
temp aggcsi
temp hp_msa
keep *_el *_in year
collapse (sum) allamount* autoamount* s_ctanav* (mean) hp_msa* aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp autoamount_el
temp autoamount_in
temp aggcsi_el
temp aggcsi_in
temp hp_msa_el
temp hp_msa_in
label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var autoamount_el_logd "Elastic MSAs"
label var autoamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
*Figure IIIa: debt growth for low credit score
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Debt growth, 1997 Low Credit Quality Homeowners", size(small))
xlabel(1998 2000 2002 2004 2006 2008, labsize(vsmall)) 
ylabel(,labsize(vsmall))
ylabel(,labsize(vsmall))
xtitle("Year", size(vsmall)) 
ytitle("Benchmarked to 2001", size(vsmall))
legend(size(vsmall));
graph save "$AER\output\FigureIIIa", replace;

# delimit cr
use "$AER\houseanal_temp_8mv", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
keep if vantage1997oq==4
replace allamount=allamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp ZYwageav
temp s_ctanav
temp aggcsi
temp hp_msa
keep *_el *_in year
collapse (sum) allamount* s_ctanav* (mean) hp_msa* aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp aggcsi_el
temp aggcsi_in
temp hp_msa_el
temp hp_msa_in
label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
*Figure IIIb: debt growth
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Debt growth, 1997 High Credit Quality Homeowners", size(small))
xlabel(1998 2000 2002 2004 2006 2008, labsize(vsmall)) 
ylabel(-0.2 0 0.2 0.4 0.6,labsize(vsmall))
xtitle("Year", size(vsmall)) 
ytitle("Benchmarked to 2001", size(vsmall))
legend(size(vsmall));
graph save "$AER\output\FigureIIIb", replace;
# delimit cr

*CCard utilization
use "$AER\houseanal_temp_8mv", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
xtile tccardutiloq=ccardutil if year==1997, nq(4)
egen ccardutiloq=min(tccardutiloq), by(groupid)
keep if ccardutiloq==4
replace allamount=allamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp ZYwageav
temp s_ctanav
temp aggcsi
temp hp_msa
keep *_el *_in year
collapse (sum) allamount* s_ctanav* (mean) hp_msa* aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp aggcsi_el
temp aggcsi_in
temp hp_msa_el
temp hp_msa_in
label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
*Figure IIIc: debt growth
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Debt growth, 1997 High Credit Card Utilization", size(small))
xlabel(1998 2000 2002 2004 2006 2008, labsize(vsmall)) 
ylabel(,labsize(vsmall))
ylabel(,labsize(vsmall))
xtitle("Year", size(vsmall)) 
ytitle("Benchmarked to 2001", size(vsmall))
legend(size(vsmall));
graph save "$AER\output\FigureIIIc", replace;

# delimit cr
use "$AER\houseanal_temp_8mv", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
xtile tccardutiloq=ccardutil if year==1997, nq(4)
egen ccardutiloq=min(tccardutiloq), by(groupid)
keep if ccardutiloq==1
replace allamount=allamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp ZYwageav
temp s_ctanav
temp aggcsi
temp hp_msa
keep *_el *_in year
collapse (sum) allamount* s_ctanav* (mean) hp_msa* aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp aggcsi_el
temp aggcsi_in
temp hp_msa_el
temp hp_msa_in
label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
*Figure IIId: debt growth
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Debt growth, 1997 Low Credit Card Utilization", size(small))
xlabel(1998 2000 2002 2004 2006 2008, labsize(vsmall)) 
ylabel(-0.2 0 0.2 0.4 0.6,labsize(vsmall))
xtitle("Year", size(vsmall)) 
ytitle("Benchmarked to 2001", size(vsmall))
legend(size(vsmall));
graph save "$AER\output\FigureIIId", replace;
# delimit cr

*Age
use "$AER\houseanal_temp_8ma", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
keep if ageoq==4
replace allamount=allamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp ZYwageav
temp s_ctanav
temp aggcsi
temp hp_msa
keep *_el *_in year
collapse (sum) allamount* s_ctanav* (mean) hp_msa* aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp aggcsi_el
temp aggcsi_in
temp hp_msa_el
temp hp_msa_in
label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
*Figure IIIe: debt growth
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Debt growth, Old homeowners", size(small))
xlabel(1998 2000 2002 2004 2006 2008, labsize(vsmall)) 
ylabel(,labsize(vsmall))
ylabel(-0.2 0.2 0.4 0.6,labsize(vsmall))
xtitle("Year", size(vsmall)) 
ytitle("Benchmarked to 2001", size(vsmall))
legend(size(vsmall));
graph save "$AER\output\FigureIIIe", replace;

# delimit cr
use "$AER\houseanal_temp_8ma", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
keep if ageoq==1
replace allamount=allamount*s_ctanav
gen ZYwageav=WageAmt0/WageNum0
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp ZYwageav
temp s_ctanav
temp aggcsi
temp hp_msa
keep *_el *_in year
collapse (sum) allamount* s_ctanav* (mean) hp_msa* aggcsi* ZYwageav*, by(year)
gen wage_el=ZYwageav_el*s_ctanav_el
gen wage_in=ZYwageav_in*s_ctanav_in
gen d2i_el=allamount_el/wage_el
gen d2i_in=allamount_in/wage_in
replace aggcsi_el=aggcsi_el/100
replace aggcsi_in=aggcsi_in/100
capture program drop temp
program define temp
gen log`1'=log(`1')
gen t`1'_2001=`1' if year==2001
egen `1'_2001=min(t`1'_2001)
gen `1'_diff=`1'-`1'_2001
gen `1'_logdiff=ln(`1')-ln(`1'_2001)
end
temp d2i_el
temp d2i_in
temp wage_el
temp wage_in
temp allamount_el
temp allamount_in
temp aggcsi_el
temp aggcsi_in
temp hp_msa_el
temp hp_msa_in
label var allamount_el_logd "Elastic MSAs"
label var allamount_in_logd "Inelastic MSAs"
label var d2i_el_d "Elastic MSAs"
label var d2i_in_d "Inelastic MSAs"
label var aggcsi_el_d "Elastic MSAs"
label var aggcsi_in_d "Inelastic MSAs"
*Figure IIIf: debt growth
# delimit ;
graph twoway line allamount_in_logd allamount_el_logd year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Debt growth, Young Homeowners", size(small))
xlabel(1998 2000 2002 2004 2006 2008, labsize(vsmall)) 
ylabel(-0.2 0 0.2 0.4 0.6,labsize(vsmall))
xtitle("Year", size(vsmall)) 
ytitle("Benchmarked to 2001", size(vsmall))
legend(size(vsmall));
graph save "$AER\output\FigureIIIf", replace;

# delimit ;
graph combine 
"$AER\output\FigureIIIa" "$AER\output\FigureIIIb" "$AER\output\FigureIIIc" "$AER\output\FigureIIId" "$AER\output\FigureIIIf" "$AER\output\FigureIIIe",
col(2)
ysize(11)
xsize(8.5); 
graph save "$AER\output\FigureIII", replace;
# delimit cr


****FIGURE IV: TRIPLE DIFFERENCE GRAPH OF REDUCED FORM FOR WITHIN COUNTY ANALYSIS
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
sort zipcode groupid
by zipcode: gen first=_n
sort zipcode first
capture program drop temp
program define temp
local i=1999
while `i'<=2008{
gen amtgr_`i'_1998=ln(allamount`i')-ln(allamount1998)
gen hpgr_`i'_1998=ln(aggcsi`i')-ln(aggcsi1998)
gen td2ich_`i'_1998=d2iallw`i'-d2iallw1998
winsor td2ich_`i'_1998, gen(d2ich_`i'_1998) p(0.01)
drop td2ich_`i'_1998
local i=`i'+1
}
end
temp
gen inelasticity=4-elasticity
gen under659inelas=under659*inelasticity

# delimit ;
program drop _all;
program define temp;
local i=1999;
while `i'<=2008{;
xi: reg `1'_`i'_1998 under659 under659inelas i.cbsa_code, cluster(cbsa_code);
gen `1'`i'=_b[under659inelas ];
gen `1'high`i'=`1'`i'+2*_se[under659inelas ];
gen `1'low`i'=`1'`i'-2*_se[under659inelas ];
local i=`i'+1;
};
end;
temp amtgr;
temp hpgr;
temp d2ich;
keep if _n==1;
keep amtgr1999-d2ichlow2008;
expand 11;
gen year=_n+1997;
program drop _all;
program define temp;
gen k`1'=.;
gen k`1'low=.;
gen k`1'high=.;
capture replace k`1'=0 if year==1998;
capture replace k`1'low=0 if year==1998;
capture replace k`1'high=0 if year==1998;
local i=1999;
while `i'<=2008{;
capture replace k`1'=`1'`i' if year==`i';
capture replace k`1'low=`1'low`i' if year==`i';
capture replace k`1'high=`1'high`i' if year==`i';
local i=`i'+1;
};
end;
temp amtgr;
temp hpgr;
temp d2ich;
keep year
kamtgr* kd2ich* khpgr*;
# delimit ;
graph twoway line khpgr khpgrlow khpgrhigh year,
legend(off)
title("House price growth", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
lp(solid dash dash)
ylabel(,labsize(medsmall))
xtitle("Year" "(growth is cumulative since 1998)", size(medsmall))
ytitle("House price growth" "Triple difference: Subprime zip codes in inelastic MSAs" , size(small));
graph save "$AER\output\FigureIVa", replace;
# delimit ;
graph twoway line kamtgr kamtgrlow kamtgrhigh year,
legend(off)
title("Total debt growth", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
lp(solid dash dash)
ylabel(,labsize(medsmall))
xtitle("Year" "(growth is cumulative since 1998)", size(medsmall))
ytitle("Homeowner debt growth" "Triple difference: Subprime zip codes in inelastic MSAs", size(small));
graph save "$AER\output\FigureIVb", replace;
# delimit ;
graph twoway line kd2ich kd2ichlow kd2ichhigh year,
legend(off)
title("Change in total debt to income ratio", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
lp(solid dash dash)
ylabel(,labsize(medsmall))
xtitle("Year" "(Change relative to 1998)", size(medsmall))
ytitle("Homeowner debt to income" "Triple difference: Subprime zip codes in inelastic MSAs" , size(small));
graph save "$AER\output\FigureIVc", replace;
# delimit ;
graph combine "$AER\output\FigureIVa" "$AER\output\FigureIVb" "$AER\output\FigureIVc",col(1) ysize(6) xsize(3.5); 
graph save "$AER\output\FigureIV", replace;
# delimit cr


********FIGURE V: ELASTIC VERSUS INELASTIC DEFAULT RATES
use "$AER\houseanal_temp_8mv", clear
keep if $keepobs
keep if elasticityoq==1 | elasticityoq==4
replace allamount=allamount*s_ctanav
replace alldef=alldef*s_ctanav
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp alldef

keep *_el *_in year
collapse (sum) *_el *_in, by(year)
gen defrate_el=alldef_el/allamount_el
gen defrate_in=alldef_in/allamount_in

label var defrate_el "Elastic MSAs"
label var defrate_in "Inelastic MSAs"

*Figure 5a: total default rates
# delimit ;
graph twoway line defrate_in defrate_el year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("All 1997 Homeowners", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
ylabel(0 0.05 0.10,labsize(medsmall))
xtitle("Year", size(medsmall)) 
ytitle("Default rate", size(medsmall))
legend(size(medsmall));
graph save "$AER\output\FigureVa", replace;
# delimit cr

use "$AER\houseanal_temp_8mv", clear
keep if moved_1997_1999==0 & owner3_1997==1
keep if elasticityoq==1 | elasticityoq==4
keep if vantage1997oq==1
replace allamount=allamount*s_ctanav
replace alldef=alldef*s_ctanav
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp alldef

keep *_el *_in year
collapse (sum) *_el *_in, by(year)
gen defrate_el=alldef_el/allamount_el
gen defrate_in=alldef_in/allamount_in

label var defrate_el "Elastic MSAs"
label var defrate_in "Inelastic MSAs"

*Figure 5b: subprime default rates
# delimit ;
graph twoway line defrate_in defrate_el year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("Low Credit Quality 1997 Homeowners", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
ylabel(,labsize(medsmall))
xtitle("Year", size(medsmall)) 
ytitle("Default rate", size(medsmall))
legend(size(medsmall));
graph save "$AER\output\FigureVb", replace;
# delimit cr

use "$AER\houseanal_temp_8mv", clear
keep if moved_1997_1999==0 & owner3_1997==1
keep if elasticityoq==1 | elasticityoq==4
keep if vantage1997oq==4
replace allamount=allamount*s_ctanav
replace alldef=alldef*s_ctanav
capture program drop temp
program define temp
gen `1'_el=`1' if elasticityoq==4
gen `1'_in=`1' if elasticityoq==1
end
temp allamount
temp alldef

keep *_el *_in year
collapse (sum) *_el *_in, by(year)
gen defrate_el=alldef_el/allamount_el
gen defrate_in=alldef_in/allamount_in

label var defrate_el "Elastic MSAs"
label var defrate_in "Inelastic MSAs"

*Figure 5c: prime default rates
# delimit ;
graph twoway line defrate_in defrate_el year if year>=1998 & year<=2008,
lp(solid dash) lw(thick thick)
title("High Credit Quality 1997 Homeowners", size(medium))
xlabel(1998 2000 2002 2004 2006 2008, labsize(medsmall)) 
ylabel(0 0.05 0.10,labsize(medsmall))
xtitle("Year", size(medsmall)) 
ytitle("Default rate", size(medsmall))
legend(size(medsmall));
graph save "$AER\output\FigureVc", replace;

# delimit ;
graph combine 
"$AER\output\FigureVa" "$AER\output\FigureVb" "$AER\output\FigureVc", col(1) ysize(6) xsize(3.5); ; 
graph save "$AER\output\FigureV", replace;
# delimit cr



************************************
***** APPENDIX TABLES/FIGURES ******
************************************

****APPENDIX FIGURE 1: MSA HP Growth and Saiz Measure
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
egen temp=mean(logcsi0206), by(msadesc)
egen Mtag=tag(cbsa_name)
keep if Mtag==1
gsort elasticity
label var temp "House price growth"
decode cbsa_name, gen(cbsa_name2)
replace cbsa_name2=subinstr(cbsa_name2, "Metropolitan Statistical Area","",.)
replace cbsa_name2=subinstr(cbsa_name2, "Metropolitan Division","",.)
# delimit ;
graph twoway (scatter temp elasticity, mlabel(cbsa_name2) mlabs(tiny)) (lfit temp elasticity, lw(thick)),
legend(off) 
ytitle("House price growth (2002-2006)", size(medsmall)) 
xlabel(#10, labsize(small)) xtitle("Housing supply elasticity, from Saiz (2010)", size(medsmall)) 
ylabel(#10, labsize(small));
# delimit cr
graph save "$output\AFigure1", replace

***** APPENDIX FIGURE II: Non-Parametric IV plot of previous table
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS & logcsi0206!=. & logall0206!=.
keep logcsi0206 elasticity cbsa_code logall0206
xi: reg logcsi0206 elasticity, cluster(cbsa_code)
predict logcsi0206pr, xb
xi: reg logall0206 logcsi0206pr, cluster(cbsa_code)
sum logcsi0206pr
local mybw=r(sd)
mykernreg logall0206 logcsi0206pr 30 `mybw' 50 "" "" "Total debt growth 2002-2006" "Predicted house price change 2002-2006"
graph save "$AER\output\AFigure2", replace

****APPENDIX TABLES I & II: Summary Statistics by Data Screen
*Renters that do not move
use "$AER\houseanal_temp_8mvCS", clear
replace age=age-11
keep if elasticity!=. & logcsi0206!=. & logall0206!=.
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals
drop mtag ztag noofindividuals
keep if moved_1997_1999==0 & owner3_1997==0
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals
drop mtag ztag noofindividuals
# delimit ;
tabstat allamount1997 homeamount1997 logall9802 logall0206 loghome9802 loghome0206
d2iallw1997win d2iallw9802win d2iallw0206win alldefrate1997 alldefrate9806 alldefrate0608 
vantage1997 ccardutil1997 age male inc2008 logcsi9802 logcsi0206 elasticity homevalmed1997
logpcw0206 logpcp0206 logtempl0206 under659
, stat(n mean p50 sd) c(s);
*Homeowners that move
use "$AER\houseanal_temp_8mvCS", clear
replace age=age-11
keep if elasticity!=. & logcsi0206!=. & logall0206!=.
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals
drop mtag ztag noofindividuals
keep if moved_1997_1999==1 & owner3_1997>=1
egen mtag=tag(cbsa_code)
egen ztag=tag(zipcode)
tab mtag
tab ztag
egen noofindividuals=sum(s_ctanav1997)
sum noofindividuals
drop mtag ztag noofindividuals
# delimit ;
tabstat allamount1997 homeamount1997 logall9802 logall0206 loghome9802 loghome0206
d2iallw1997win d2iallw9802win d2iallw0206win alldefrate1997 alldefrate9806 alldefrate0608 
vantage1997 ccardutil1997 age male inc2008 logcsi9802 logcsi0206 elasticity homevalmed1997
logpcw0206 logpcp0206 logtempl0206 under659
, stat(n mean p50 sd) c(s);
# delimit cr

*** APPENDIX TABLE III: Motivation of Within Test/Exclusion restriction
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS & logcsi0206!=.
replace vantage1997=vantage1997/100
keep cbsa_code d2i97p2 d2iallw1997win logztotloanHP* zipcode owner3_1997 saiz* elasticity* moved_1997_1999 ccardutil1997 ccardutil97p2 equity0206 all0206 homevalmed* logcc* logall* loghome* d2i* logcsi* van* inc* loginc* age* male under* msa county msa $censusvars $incxvars
gen elasticitysubprime=elasticity*under659
egen Ztag=tag(zipcode)
gen loghp0206=(logztotloanHP2006- logztotloanHP2002)
** Panel A: HMDA credit growth
areg loghp0206 under659 if Ztag==1, absorb(cbsa_code) cluster(cbsa_code)
areg loghp0206 under659 if Ztag==1 & elasticityoq==4, absorb(cbsa_code) cluster(cbsa_code)
areg loghp0206 under659 if Ztag==1 & elasticityoq==3, absorb(cbsa_code) cluster(cbsa_code)
areg loghp0206 under659 if Ztag==1 & elasticityoq==2, absorb(cbsa_code) cluster(cbsa_code)
areg loghp0206 under659 if Ztag==1 & elasticityoq==1, absorb(cbsa_code) cluster(cbsa_code)
** Panel B: Show subprime house price effect across elasticity (QJE point #1)
areg logcsi0206 under659 if Ztag==1, absorb(cbsa_code) cluster(cbsa_code)
areg logcsi0206 under659 if Ztag==1 & elasticityoq==4, absorb(cbsa_code) cluster(cbsa_code)
areg logcsi0206 under659 if Ztag==1 & elasticityoq==3, absorb(cbsa_code) cluster(cbsa_code)
areg logcsi0206 under659 if Ztag==1 & elasticityoq==2, absorb(cbsa_code) cluster(cbsa_code)
areg logcsi0206 under659 if Ztag==1 & elasticityoq==1, absorb(cbsa_code) cluster(cbsa_code)
**Panel C: then show exclusion restriction for triple diff idea
xtile hmvalp2=homevalmed2002, nq(50)
xi: areg logall2002 elasticitysubprime under659 , absorb(cbsa_code) cluster(cbsa_code) 
xi: areg logall2002 elasticitysubprime under659 i.hmvalp2 i.van97p2 i.agep2 i.inc08p2 male , absorb(cbsa_code) cluster(cbsa_code) 
xi: areg d2iallw2002win elasticitysubprime under659 , absorb(cbsa_code) cluster(cbsa_code) 
xi: areg d2iallw2002win elasticitysubprime under659 i.hmvalp2 i.van97p2 i.agep2 i.inc08p2 male , absorb(cbsa_code) cluster(cbsa_code) 

**APPENDIX TABLE IV: Within cbsa_code Triple Difference Estimate
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
keep elasticity cbsa_code all0206 d2i97p2 d2iallw1997win equity0206 homevalmed* zipcode owner3_1997 moved_1997_1999 ccardutil1997 ccardutil97p2 logcc* logall* loghome* d2i* logcsi* van* inc* loginc* age* male under* saiz* county cbsa_code elasticity*
gen elasticitysubprime=elasticity*under659
xtile hmvalp2=homevalmed2002, nq(50)
gen csivan=logcsi0206*vantage1997
gen csicc=logcsi0206*ccardutil1997
gen ivintervan=elasticitysubprime*vantage1997
gen ivintercc=elasticitysubprime*ccardutil1997
**IV of debt growth
xi: ivreg logall0206 (logcsi0206=elasticitysubprime) under659 i.cbsa_code, cluster(cbsa_code)
xi: ivreg logall0206 (logcsi0206=elasticitysubprime) under659 homevalmed2002 vantage1997 loginc08 d2iallw1997win age male i.cbsa_code, cluster(cbsa_code) 
xi: ivreg logall0206 (logcsi0206=elasticitysubprime) under659 i.hmvalp2 i.van97p2 i.agep2 i.inc08p2 i.d2i97p2 male i.cbsa_code, cluster(cbsa_code) 
xi: ivreg d2iallw0206win (logcsi0206=elasticitysubprime) under659 i.cbsa_code, cluster(cbsa_code)
xi: ivreg d2iallw0206win (logcsi0206=elasticitysubprime) under659 homevalmed2002 vantage1997 loginc08 d2iallw1997win age male i.cbsa_code, cluster(cbsa_code) 
xi: ivreg d2iallw0206win (logcsi0206=elasticitysubprime) under659 i.hmvalp2 i.van97p2 i.agep2 i.inc08p2 i.d2i97p2 male i.cbsa_code, cluster(cbsa_code) 


******* APPENDIX TABLE V: Default Rates
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
gen U`var'=`var'*under659
}
xi: ivreg alldefrate0206 (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg alldefrate0206 (logcsi0206 HPvantage1997=elasticity SZvantage1997) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male , cluster(cbsa_code)
xi: ivreg alldefrate0206 (logcsi0206 HPccardutil1997=elasticity SZccardutil1997) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
use "$AER\houseanal_temp_8mvCS", clear
keep if $keepobsCS
replace vantage1997=vantage1997/100
foreach var of varlist vantage1997 ccardutil1997 loginc08 age male {
capture drop HP`var' SZ`var'
gen HP`var'=`var'*logcsi0206
gen SZ`var'=`var'*elasticity
gen U`var'=`var'*under659
}
xi: ivreg alldefrate0608 (logcsi0206=elasticity) vantage1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg alldefrate0608 (logcsi0206 HPvantage1997=elasticity SZvantage1997) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male, cluster(cbsa_code)
xi: ivreg alldefrate0608 (logcsi0206 HPccardutil1997=elasticity SZccardutil1997) vantage1997 ccardutil1997 loginc08 d2iallw1997win age male , cluster(cbsa_code)


