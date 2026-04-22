/*

This program generates the results for Table 3 from "The Surprisingly Swift Decline of 
U.S. Manufacturing Employment" by Justin R. Pierce and Peter K. Schott

The datasets used in this paper are created in data_create.do

Files needed to run this program:
1. hts_concordances_20101020_199701_200707_6.dta - Concordance of HS6 product codes over time
2. tar_val.dta - Contains NTR gap (labeled "spread" in the file) at HS8-level
3. hscombined_isicrev3.csv - HS to ISIC Rev 3 concordance available from WITS (World Bank), 
   wits.worldbank.org/wits/product_concordance.html
4. unido_emp_isic4.csv - UNIDO employment data at country-ISIC Rev 3-year-level. Data are publicly 
   available but require a subscription, and therefore are not provided.  The data are typically 
   available at university libraries.


*/



clear all
set more off
cd "[directory]"



**1 - Calculate NTR Gap at ISIC Rev 3 level

*1.1 - Prep the HS6 over time concordance (associates time-consistent HS6 "families" with obsolete and new HS6 codes)
use hts_concordances_20101020_199701_200707_6.dta, clear
keep obsolete setyr
drop if obsolete==.
duplicates drop 
sort obsolete
save temp_obsolete6, replace	
use hts_concordances_20101020_199701_200707_6.dta, clear
keep new setyr
drop if new==.
duplicates drop 
sort new
save temp_new6, replace

*1.2 - Calculate NTR gaps at HS6 family level
use tar_val.dta, clear
rename hs8 shs8
destring shs8, force g(hs8)
gen double hs6=int(hs8/100)
rename spread s
replace s=0 if s<0
recast double s 
collapse (mean) s, by(hs6 year)
reshape wide s, i(hs6) j(year)
sort hs6
save temp_hs6_spread, replace
*merge in obsolete-code family identifiers
rename hs obsolete
merge 1:1 obsolete using temp_obsolete6, keepusing(setyr)
rename setyr setyr1
tab _merge
drop if _merge==2
drop _merge
rename obsolete hs
*merge in new-code family identifiers
rename hs new
sort new
merge 1:1 new using temp_new6, keepusing(setyr)
tab _merge
rename setyr setyr2
drop if _merge==2
drop _merge
rename new hs
keep hs s1999 setyr1 setyr2
*Create a new hs variable that is equal to setyr when appropriate
replace hs=setyr1 if setyr1!=.
replace hs=setyr2 if setyr2!=.
rename hs hs6fam
collapse (mean) s1999, by(hs6fam)
save hs6fam_gap, replace


*1.3 - Prep the HS6-ISIC4 Rev. 3 concordance
*Concordance is from WITS (World Bank): wits.worldbank.org/wits/product_concordance.html
clear all
insheet using hscombined_isicrev3.csv
keep hscombinedproductcode isicrevision3productcode
rename hscombinedproductcode hs
rename isicrevision3productcode isic
tostring hs, g(hs_str)
tostring isic, g(isic_str)
replace hs_str="0"+hs_str if hs<=99999
replace isic_str="0"+isic_str if isic<=999
gen isic2=substr(isic_str,1,2)
destring isic2, force replace
*Identify manufacturing industry codes
gen manuf=isic2>=15& isic2<=37
drop isic2
save hs6comb_isicrev3, replace

*1.4 - Calculate ISIC Rev. 3-level NTR Gaps
clear all
use hs6comb_isicrev3
*merge in obsolete-code family identifiers
rename hs obsolete
merge 1:1 obsolete using temp_obsolete6, keepusing(setyr)
rename setyr setyr1
tab _merge
drop if _merge==2
drop _merge
rename obsolete hs
*merge in new-code family identifiers
rename hs new
sort new
merge new using temp_new6, keep(setyr)
tab _merge
rename setyr setyr2
drop if _merge==2
drop _merge
rename new hs
*replace HS6 with setyr where appropriate
replace hs=setyr1 if setyr1!=.
replace hs=setyr2 if setyr2!=.
rename hs hs6fam
save hs6fam_isic, replace
*Merge in hs6fam-level gap data
merge m:1 hs6fam using hs6fam_gap
drop if _merge==2
*collapse gap data to the ISIC-level
collapse (mean) s1999, by(isic_str manuf)
*Keep only manufacturing
keep if manuf==1
save isic_gap_manuf, replace


**2 - Format Employment data from UNIDO INDSTAT4
*Data are publicly available but require a subscription; these are typically available at university libraries

clear all
insheet using unido_emp_isic4.csv
rename v2 countrycode
rename v3 year
rename v4 isiccode
rename v6 emp
keep countrycode year isiccode emp
keep if length(isiccode)==4
gen country=""
replace country="belgium" if countrycode==56
replace country="bulgaria" if countrycode==100
replace country="czechrep" if countrycode==203
replace country="denmark" if countrycode==208
replace country="germany" if countrycode==276
replace country="estonia" if countrycode==233
replace country="ireland" if countrycode==372
replace country="greece" if countrycode==300
replace country="spain" if countrycode==724
replace country="france" if countrycode==250
replace country="croatia" if countrycode==191
replace country="italy" if countrycode==380
replace country="cyprus" if countrycode==196
replace country="latvia" if countrycode==428
replace country="lithuania" if countrycode==440
replace country="luxembourg" if countrycode==442
replace country="hungary" if countrycode==348
replace country="malta" if countrycode==470
replace country="netherlands" if countrycode==528
replace country="austria" if countrycode==40
replace country="poland" if countrycode==616
replace country="portugal" if countrycode==620
replace country="romania" if countrycode==642
replace country="slovenia" if countrycode==705
replace country="slovakia" if countrycode==703
replace country="finland" if countrycode==246
replace country="sweden" if countrycode==752
replace country="uk" if countrycode==826
gen eu=country!=""
replace country="us" if countrycode==840
keep if country!=""
replace eu=0 if eu==.
destring emp, g(emp_num) force
drop emp
rename emp_num emp
save unido_emp, replace


**3. Regressions reported in Table 3

*3.1 - EU
*Note: Employment data for Cyprus and Malta are not available for any years

clear all
use unido_emp
rename isiccode isic_str
merge m:1 isic_str using isic_gap_manuf, keepusing(s1999)
table _merge, c(sum emp) f(%20.0fc)
keep if _merge==3
gen isic2=substr(isic_str,1,2)
*Drop ISIC 22, which includes publishing; not included in manufacturing under NAICS
drop if isic2=="22"
*Set countries
keep if eu==1
*Years in which employment is consistently available for EU and US
keep if year>=1997 & year<=2005
*Drop when industry-country pairs are not defined in all years
*This prevents employment being affected by country-industry pairs appearing in some years but not others
*This leads to exclusion of most data for Latvia, Lithuania, Belgium and Portugal, which are not available in all years
gen empnonmiss=emp!=.
egen totempnonmiss=total(empnonmiss), by(country isic_str)
keep if totempnonmiss==9
collapse (sum) emp (mean) s1999, by(isic_str year)
forvalues x=1998/2005 {
	gen d`x'=year==`x'
}
destring isic_str, g(isic) force
gen t1=emp if year==1997
egen emp97=mean(t1), by(isic)
gen lemp=ln(emp)
*Generate post interaction
gen post=year>=2001
gen s_post=s1999*post
save eu_reg, replace
*Regression
!rm eu_results.txt
areg lemp s_post d1998 d1999 d2000 d2001 d2002 d2003 d2004 d2005 [aw=emp97], a(isic) cl(isic) robust
outreg2 using eu_results.txt, replace noaster


*3.2 - US
*Note: US data are unavailable for years prior to 1997 and for 2003

clear all
use unido_emp
rename isiccode isic_str
merge m:1 isic_str using isic_gap_manuf, keepusing(s1999)
table _merge, c(sum emp) f(%20.0fc)
keep if _merge==3
gen isic2=substr(isic_str,1,2)
*Set countries
keep if country=="us"
*Set years
keep if year>=1997 & year<=2005
*Drop when industry-country pairs are not defined in all years
gen empnonmiss=emp!=.
egen totempnonmiss=total(empnonmiss), by(country isic_str)
keep if totempnonmiss==8
*Drop ISIC 22, which includes publishing; not included in manufacturing under NAICS
drop if isic2=="22"
forvalues x=1998/2005 {
	gen d`x'=year==`x'
}
destring isic_str, g(isic) force
gen t1=emp if year==1997
egen emp97=mean(t1), by(isic)
gen lemp=ln(emp)
*Generate post interaction
gen post=year>=2001
gen s_post=s1999*post
save us_reg, replace
*Regression
areg lemp s_post d1998 d1999 d2000 d2001 d2002 d2003 d2004 d2005 [aw=emp97], a(isic) cl(isic) robust
outreg2 using eu_results.txt, append noaster


*3.3 - U.S. and EU 3Diff

clear all
use us_reg
append using eu_reg
replace country="eu" if country==""
replace eu=1 if country=="eu"
gen us=eu==0
gen us_s1999=us*s1999
gen post_us_s=post*us*s1999
egen ind_cty_fe=group(isic us)
egen ind_yr_fe=group(isic year)
egen cty_yr_fe=group(us year)
*Regression
reghdfe lemp post_us_s [aw=emp97], absorb(ind_cty_fe ind_yr_fe cty_yr_fe) vce(cluster ind_cty_fe) fast v(1) dropsi
outreg2 using eu_results.txt, append noaster
