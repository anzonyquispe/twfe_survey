/*

This program generates the main data files used to generate the tables and figures 
from "The Surprisingly Swift Decline of U.S. Manufacturing Employment" by
Justin R. Pierce and Peter K. Schott

Input files
	
	Restricted use
		lbd????
		cmf????prod.dta
		cmf????
		raw_stata_m_10_????
		robustness_chinese_subsidy_per_sales
		robustness_chinese_exp_lic

	Public
		bbg_fam_drop_50_s4_2 
		bbg_fam_drop_50_n6_2
		temp_50_n6
		gaps_by_naics6_20150722_fam50
		robustness_chn_tariff_fam50_true
		robustness_union_fam50
		robustness_matp_fam50
		robustness_contract_fam50
		robustness_mfa_fam50_yr
		robustness_ntr_fam50_true_adj
		robustness_chinese_subsidy_per_sales
		robustness_chinese_exp_lic
		robustness_revealed_t0_t1_fam50_yr
		robustness_rgdp_yr
		robustness_trefler_fam50_yr
		sic5809
		naics5809
		hts_concordances_20101020_199201_200707_8
		tar_val
		mfa8404
		hs_mfa_phase_20111208
		hs8c_revealed_tariffs_20140519
		robustness_ct_xr
		uscode_uncode_wbcode_feenstra
		wb_reer_20140603

*/



clear all
set more off



*1 Create annual LBD manufacturing employment file 

*1.1 convert native industry SIC and then NAICS codes in lbd to "families" of industries that are constant 
*    across this jump
quietly {
forvalues b=1989/2007 {

	use lbdnum firstyear lastyear firmid yr emp pay flaga cbp_bestsic cbp_bestnaics sic naics bestsic bestnaics using $input/lbd`b' if flaga~="D", clear

	gen snaics         = substr(naics,1,6)
	gen ssic           = substr(sic,1,4)
	gen sbestnaics     = substr(bestnaics,1,6)
	gen sbestsic       = substr(bestsic,1,4)
	drop naics sic bestnaics bestsic 
	
	destring snaics    , force g(naics)
	destring ssic      , force g(sic)
	destring sbestnaics, force g(bestsic)
	destring sbestsic  , force g(bestnaics)

	if yr<2002 {
			
		merge m:1 sic using $input/bbg_fam_drop_50_s4_2, keepusing(family con50 lib50)
		drop if _merge==2
		drop _merge
		rename con50 con50t
		rename lib50 lib50t
		rename family familyt
		gen fammiss=familyt==.
		table fammiss, c(sum emp) f(%20.0fc)
		drop fammiss
		
		noisily display ["part1 `b'"]

		merge m:1 bestsic using $input/bbg_fam_drop_50_s4_2, keepusing(family con50 lib50)
		drop if _merge==2
		replace con50t=con50 if con50t==. & con50!=.
		replace lib50t=lib50 if lib50t==. & lib50!=.
		replace familyt=family if familyt==. & family!=.
		gen fammiss=familyt==.
		table fammiss, c(sum emp) f(%20.0fc)
		drop fammiss
		drop _merge con50 lib50 family
		
		noisily display ["part2 `b'"]

		merge m:1 bestnaics using $input/bbg_fam_drop_50_n6_2, keepusing(family con50 lib50)
		drop if _merge==2
		replace con50t=con50 if con50t==. & con50!=.
		replace lib50t=lib50 if lib50t==. & lib50!=.
		replace familyt=family if familyt==. & family!=.
		gen fammiss=familyt==.
		table fammiss, c(sum emp) f(%20.0fc)
		drop fammiss
		drop _merge con50 lib50 family
		rename con50t con50
		rename lib50t lib50
		rename familyt fam50
		
		noisily display ["part3 `b'"]

	}
	if yr>=2002 {
			
		merge m:1 naics using $input/bbg_fam_drop_50_n6_2, keepusing(family con50 lib50)
		drop if _merge==2
		drop _merge
		rename con50 con50t
		rename lib50 lib50t
		rename family familyt
		gen fammiss=familyt==.
		table fammiss, c(sum emp) f(%20.0fc)
		drop fammiss
		
		noisily display ["part1 `b'"]

		merge m:1 bestnaics using $input/bbg_fam_drop_50_n6_2, keepusing(family con50 lib50)
		drop if _merge==2
		replace con50t=con50 if con50t==. & con50!=.
		replace lib50t=lib50 if lib50t==. & lib50!=.
		replace familyt=family if familyt==. & family!=.
		gen fammiss=familyt==.
		table fammiss, c(sum emp) f(%20.0fc)
		drop fammiss
		drop _merge con50 lib50 family
		
		noisily display ["part2 `b'"]

		merge m:1 bestsic using $input/bbg_fam_drop_50_s4_2, keepusing(family con50 lib50)
		drop if _merge==2
		replace con50t=con50 if con50t==. & con50!=.
		replace lib50t=lib50 if lib50t==. & lib50!=.
		replace familyt=family if familyt==. & family!=.
		gen fammiss=familyt==.
		table fammiss, c(sum emp) f(%20.0fc)
		drop fammiss
		drop _merge con50 lib50 family
		rename con50t con50
		rename lib50t lib50
		rename familyt fam50

		noisily display ["part3 `b'"]
	}
	save $interim/t`b', replace
 }
}


*1.2 assemble above into single dataset
use lbdnum firstyear lastyear firmid yr emp con50 fam50 flaga pay cbp_bestsic cbp_bestnaics sic naics using $interim/t1989 if flaga~="D", clear
forvalues y=1990/2007 {
	display ["`y'"]
	append using $interim/t`y', keep(lbdnum firstyear lastyear firmid yr emp con50 fam50 flaga pay cbp_bestsic cbp_bestnaics sic naics)
	drop if flaga=="D"
}

*eliminate the erroneous (or death) observations we never want to keep 
drop if pay>100000 & pay/emp>200 & pay!=. & emp!=.
drop if emp>30000 & emp!=.
drop if yr<=2001 & cbp_bestsic!=1 
drop if yr>=2002 & cbp_bestnaics!=1 
drop if lbdnum==""
drop cbp_bestsic cbp_bestnaics pay flaga
rename yr year

*other drops
*
*	con50==. 	can't match to industry
*	con50==0
*	con50mean==.	always outside manuf
*	pkeep==1	never outside manuf
*
egen con50mean=mean(con50), by(lbdnum)
gen pkeep=con50mean==1

drop if con50==.
drop if con50mean==0
drop if con50==0
keep if pkeep==1

duplicates tag lbdnum year, g(i)
tab i
drop i
save $interim/true_fam_lbd_plant, replace  /*same as rev2_true_emp*/


*create identifiers for summing employment by industry in next section
clear all
use $interim/true_fam_lbd_plant
egen minyr=min(year), by(lbdnum)
gen t1=.
replace t1=fam50 if year==minyr
egen fam50minyr=mean(t1), by(lbdnum)
drop t1
egen maxyr=max(year), by(lbdnum)
gen t1=.
replace t1=fam50 if year==maxyr
egen fam50maxyr=mean(t1), by(lbdnum)
drop t1

*check how many plants change their family
egen i1 = tag(lbdnum)
gen i2 = fam50minyr~=fam50maxyr
tab i2 if i1==1
drop i1 i2

*get family for 1999 or closest thereto for extensive margin
gen t1=.
replace t1=fam50 if year==1999
replace t1=fam50minyr if minyr>1999
replace t1=fam50maxyr if maxyr<1999
egen fam501999=mean(t1), by(lbdnum)
drop t1
compare fam501999 fam50
save $interim/true_fam_lbd_plant_01, replace


*clean up
forvalues t=1990(1)2007 {
	zipfile t`t'.dta, saving(t`t', replace)
}


*1.3 aggregate above plant data to industries 
clear all
use $interim/true_fam_lbd_plant_01
collapse (sum) emp, by(fam50minyr year)
rename fam50minyr fam50
rename emp empfam50minyr
save $interim/fam50minyremp, replace

clear all
use $interim/true_fam_lbd_plant_01
collapse (sum) emp, by(fam501999 year)
rename fam501999 fam50
rename emp empfam501999
save $interim/fam501999emp, replace

clear all
use $interim/true_fam_lbd_plant
collapse (sum) emp, by(fam50 year)
merge 1:1 fam50 year using $interim/fam50minyremp
tab _merge
drop _merge
merge 1:1 fam50 year using $interim/fam501999emp
tab _merge 
drop _merge
drop if fam50==.  /*****/
save $interim/true_fam_lbd, replace

*clean up
erase $interim/fam50minyremp.dta
erase $interim/fam501999emp.dta



*1.4 add ohter covariates to the plant file 
use $input/naics5809.dta, clear
keep year naics emp prode cap piinv
gen rk=cap/piinv
rename naics n6
sort n6 year
merge m:1 n6 year using $interim/temp_fam50_n6_year
keep if _merge==3
collapse (sum) emp prode rk, by(fam50 year)
gen lkl=ln(rk/emp)
gen lsl=ln((emp-prode)/emp)
rename emp bbg_emp
keep fam50 year lkl lsl bbg_emp
save $interim/robustness_capskill_fam50, replace

clear all
use $interim/true_fam_lbd_plant if year>=1990 & pkeep==1
drop pkeep con50mean

*get family and emp for 1999 or closest thereto
egen double minyr=min(year), by(lbdnum)
egen double maxyr=max(year), by(lbdnum)
foreach x in fam50 {
	gen t1=.
	replace t1=`x' if year==minyr
	egen double `x'minyr=mean(t1), by(lbdnum)
	drop t1
	gen t1=.
	replace t1=`x' if year==maxyr
	egen double `x'maxyr=mean(t1), by(lbdnum)
	drop t1
	gen t1=.
	replace t1=`x' if year==1999
	replace t1=`x'minyr if minyr>1999
	replace t1=`x'maxyr if maxyr<1999
	egen double `x'1999=mean(t1), by(lbdnum)
	drop t1
}
rename fam50 fam50tv
rename fam501999 fam50
gen lemp=ln(emp)
gen post=year>=2001

*merge in constant manufacturing sample
merge m:1 fam50 using $interim/temp_50_n6, keepus(con50)
drop if _merge==2
drop _merge

*merge in spread 
merge m:1 fam50 using $interim/gaps_by_naics6_20150722_fam50, keepus(wgap_offd31999 s1999 iodown31999 nntr1999 ntr1999)
drop if _merge==2
drop _merge

*merge in capital intensity and skill intensity
merge m:1 fam50 year using $interim/robustness_capskill_fam50, keepus(lkl lsl bbg_emp)
drop if _merge==2
drop _merge

*merge in the chinese tariff data
merge m:1 fam50 year using $interim/robustness_chn_tariff_fam50_true, keepus(r dr)
drop if _merge==2
drop _merge
		
*merge in union data
merge m:1 fam50 year using $interim/robustness_union_fam50
drop if _merge==2
drop _merge
		
*merge in atp data
merge m:1 fam50 year using $interim/robustness_matp_fam50
replace atp=0 if atp==.
drop if _merge==2
drop _merge

*merge in contractibility data
merge m:1 fam50 using $interim/robustness_contract_fam50
drop if _merge==2
drop _merge		
	
*merge in mfa with new way including fill rates and import-weighting
merge m:1 fam50 year using $interim/robustness_mfa_fam50_yr
drop if _merge==2
drop _merge
foreach x in s123 s4 s1234 sm123 sm4 sm1234 sf2001 sf2004 sf sfw2001 sfw2004 sfw sfw2001_mwt sfw2004_mwt sfw_mwt sfw2004_mwt_sum sfw_mwt_sum  {
	replace `x'_new=0 if `x'_new==.
}

*merge in ntr and dntr data
merge m:1 fam50 year using $interim/robustness_ntr_fam50_true_adj, keepus(ntr dntr)
drop if _merge==2
drop _merge		
			
*merge in Chinese subsidy data
merge m:1 fam50 using $interim/robustness_chinese_subsidy_per_sales, keepus(sub1999 sub2005 dsub)
drop if _merge==2
drop _merge	
		
*merge in chinese export licensing data
merge m:1 fam50 using $interim/robustness_chinese_exp_lic, keepus(se1999 se2003 dse)
drop if _merge==2
drop _merge	
		
*generate covariate values by year 
foreach y in emp lkl lsl {
	foreach x in 1990 minyr {
		gen i        = year==`x'
		gen t1       = `y'*i
		replace t1=. if ~i
		egen `y'`x'  = max(t1), by(lbdnum)
		drop t1 i
	}
}

egen meanemp=mean(emp), by(lbdnum)

*generate "post" interactions
foreach z in s1999 wgap_offd31999 iodown31999 nntr1999 lkl1990 lklminyr lsl1990 lslminyr contract dr dsub se1999 atp {
	gen `z'_post=`z'*post
}
		
forvalues y=1990/2007 {
	gen d`y'     = year==`y'
}

*Generate a death variable
gen death=year==maxyr
		
save $interim/lbd_plant_regression_file, replace



*1.5 do same for industry-level file
use $interim/true_fam_lbd, clear
		
gen lemp           = ln(emp)
gen lempfam50minyr = ln(empfam50minyr)
gen lempfam501999  = ln(empfam501999)

	
*merge in constant manufacturing sample
merge m:1 fam50 using $interim/temp_50_n6, keepus(con50)
drop if _merge==2
drop _merge

*merge in spread 
merge m:1 fam50 using $interim/gaps_by_naics6_20150722_fam50, keepus(iogap* wgap* s* iodown* nntr* ntr*)
drop if _merge==2
drop _merge
table fam if fam==409 | fam==451, c(mean s1999) f(%15.3fc)

*merge in capital intensity and skill intensity
merge m:1 fam50 year using $interim/robustness_capskill_fam50, keepus(lkl lsl bbg_emp)
drop if _merge==2
drop _merge

*merge in the chinese tariff data
merge m:1 fam50 year using $interim/robustness_chn_tariff_fam50_true, keepus(r dr)
drop if _merge==2
drop _merge

*merge in union data
merge m:1 fam50 year using $interim/robustness_union_fam50
drop if _merge==2
drop _merge

*merge in atp data
merge m:1 fam50 year using $interim/robustness_matp_fam50
replace atp=0 if atp==.
drop if _merge==2
drop _merge

*merge in contractibility data
merge m:1 fam50 using $interim/robustness_contract_fam50
drop if _merge==2
drop _merge		
	
*merge in mfa with new way including fill rates and import-weighting
merge 1:1 fam50 year using $interim/robustness_mfa_fam50_yr
drop if _merge==2
drop _merge
*Next line assumes that families that weren't in the MFA dataset don't have MFA
foreach x in s123 s4 s1234 sm123 sm4 sm1234 sf2001 sf2004 sf sfw2001 sfw2004 sfw sfw2001_mwt sfw2004_mwt sfw_mwt sfw2004_mwt_sum sfw_mwt_sum  {
	replace `x'_new=0 if `x'_new==.
}

*merge in ntr and dntr data
merge m:1 fam50 year using $interim/robustness_ntr_fam50_true_adj, keepus(ntr dntr)
drop if _merge==2
drop _merge		

*merge in family-year-level revealed tariff, calculated with all import programs
merge 1:1 fam50 year using $interim/robustness_revealed_t0_t1_fam50_yr
drop if _merge==2
drop _merge

*merge in Chinese subsidy data
merge m:1 fam50 using $interim/robustness_chinese_subsidy_per_sales, keepus(sub1999 sub2005 dsub)
drop if _merge==2
drop _merge	

*merge in chinese export licensing data
merge m:1 fam50 using $interim/robustness_chinese_exp_lic, keepus(se1999 se2003 dse)
drop if _merge==2
drop _merge	

*merge in gdp data
merge m:1 year using $interim/robustness_rgdp_yr
drop if _merge==2
drop _merge
		
*merge in trefler business cycle control
merge 1:1 fam50 year using $interim/robustness_trefler_fam50_yr, keepus(yhat*)
drop if _merge==2
drop _merge

*generate generic years 
sort fam50 year
duplicates drop
egen y = seq(), by(fam50)
egen check = max(y), by(fam50)

*generate initial values
foreach y in emp lkl lsl mem cov {
	foreach x in 1990 {
		gen i        = year==`x'
		gen t1       = `y'*i
		replace t1=. if ~i
		egen `y'`x'  = max(t1), by(fam50)
		drop t1 i
	}
}

*generate interaction of gdp with initial k/l and s/l for business cycle control
gen double lrgdp_lkl1990=lrgdp*lkl1990
gen double lrgdp_lsl1990=lrgdp*lsl1990		


*calculate categorical and nonlinear gap measures
sum s1999 if year==1999 & con50==1, det
egen i = tag(fam50 year)
centile s1999 if year==1990 & con50==1 & i==1, centile(10 20 30 40 50 60 70 80 90 33 67 25 75)
drop i
gen ls  = ln(s1999)
gen s10=s1999> & s1999~=.
gen s20=s1999> & s1999~=.
gen s30=s1999> & s1999~=.
gen s40=s1999> & s1999~=.
gen s50=s1999> & s1999~=.
gen s60=s1999> & s1999~=.
gen s70=s1999> & s1999~=.
gen s80=s1999> & s1999~=.
gen s90=s1999> & s1999~=.

gen s25=s1999> & s1999~=.
gen s75=s1999> & s1999~=.

gen s33=s1999> & s1999~=.
gen s67=s1999> & s1999~=.

*calculate terciles 
gen q3_2=s33==1 & s67==0 & s1999!=.
gen q3_3=s67==1          & s1999!=.

*calculate quartiles
gen q4_2=s25==1 & s50==0 & s1999!=.
gen q4_3=s50==1 & s75==0 & s1999!=.
gen q4_4=s75==1          & s1999!=.

*calculate quintiles 
gen q5_2=s20==1 & s40==0 & s1999!=.
gen q5_3=s40==1 & s60==0 & s1999!=.
gen q5_4=s60==1 & s80==0 & s1999!=.
gen q5_5=s80==1          & s1999!=.

*calculate deciles
gen decile2=s10==1 & s20==0 & s1999!=.
gen decile3=s20==1 & s30==0 & s1999!=.
gen decile4=s30==1 & s40==0 & s1999!=.
gen decile5=s40==1 & s50==0 & s1999!=.
gen decile6=s50==1 & s60==0 & s1999!=.
gen decile7=s60==1 & s70==0 & s1999!=.
gen decile8=s70==1 & s80==0 & s1999!=.
gen decile9=s80==1 & s90==0 & s1999!=.
gen decile10=s90==1         & s1999!=.

*calculate 20 percentage point bins
gen bin4_2=s1999>.2 & s1999<=.4 & s1999!=.
gen bin4_3=s1999>.4 & s1999<=.6 & s1999!=.
gen bin4_4=s1999>.6

*nonlinear
gen s_sq   = s1999^2
gen ls_sq  = ln(s_sq)
gen s_cu   = s1999^3
gen s_four = s1999^4

*generate "post" interactions
gen post=year>=2001
foreach z in s1990 s1999 nntr1990 nntr1999 lkl1990 lsl1990 contract dr dsub se1999 ///
             atp mem ntr s10 s20 s25 s30 s40 s50 s60 s70 s75 s80 s90 ///
	     decile2 decile3 decile4 decile5 decile6 decile7 decile8 decile9 decile10 ls s_sq s_cu ///
	     s_four ls_sq q3_2 q3_3 q4_2 q4_3 q4_4 q5_2 q5_3 q5_4 q5_5 bin4_2 bin4_3 bin4_4 ///
	     wgap_offd31999 iodown31999 {
	gen `z'_post=`z'*post
}

foreach z in sfw_mwt_sum_new  {
	gen `z'_post=`z'*post
}

forvalues y=1991/2007 {
	gen d`y'     = year==`y'
	gen d`y's	 = d`y'*s1999
	gen d`y's1990    = d`y'*s1990
	gen d`y's1999    = d`y'*s1999
	gen d`y'nntr1990    = d`y'*nntr1990
	gen d`y'nntr1999    = d`y'*nntr1999
	foreach z in ls s10 s20 s25 s30 s40 s50 s60 s70 s75 s80 s90 q3_2 q3_3 q4_2 q4_3 q4_4 q5_2 q5_3 ///
	             q5_4 q5_5 decile2 decile3 decile4 decile5 decile6 decile7 decile8 decile9 ///
		     decile10 s_sq s_cu s_four ls_sq {
		gen d`y'`z' = d`y'*`z'
	}
				
	gen d`y'up3       = d`y'*wgap_offd3_nntr1999 
	gen d`y'dn3       = d`y'*iodown3_nntr1999
	
	
	gen d`y'ntr       = d`y'*ntr
	gen d`y'nntr      = d`y'*nntr1990
	gen d`y'dntr      = d`y'*dntr
		
	gen d`y'lkl1990   = d`y'*lkl1990
	gen d`y'lsl1990   = d`y'*lsl1990		

	gen d`y'mem       = d`y'*mem
	gen d`y'r         = d`y'*r	
	gen d`y'dr        = d`y'*dr	

	gen d`y'atp          = d`y'*atp
	gen d`y'con          = d`y'*contract
	gen d`y'dsub         = d`y'*dsub	
	gen d`y'se1999       = d`y'*se1999
	gen d`y'dmem19892007 = d`y'*dmem19892007
	gen d`y'dcov19892007 = d`y'*dcov19892007
}			

noisily save $interim/io_bbg_01_true_9007_20150605, replace

*refine for regression sample
use $interim/io_bbg_01_true_9007_20150605, clear
keep if con50==1
keep if year>=1990 & year<=2007

*compute constant manuf employment
table year, c(sum emp) f(%20.0fc)

*indicator for all variables present and years we want
gen i = 1
foreach x in s1999 ntr contract dr dsub se1999 lkl lsl mem {
	replace i=0 if `x'==.
}
egen ti = total(i), by(fam50)
tab ti
keep if ti==18
save $interim/t1, replace
drop i ti
xi i.fam50 
noisily save $interim/lbd_industry_regression_file, replace

use $interim/t1, clear
collapse (mean) ti, by(fam50)
drop ti
gen check_true=1
save $interim/check_true, replace




*2 Create plant-level NTR gaps 

*2.1 refine CM product trailer data
forvalues y=1992(5)1997 {
	use $input/cmf`y'prod.dta, clear
	foreach x in tvs tvpsd tvps pv {
		rename `x' `x'_pt
	}	
	
	*merge in info from main CM files
	sort ppn 
	merge m:1 ppn using $input/cmf`y', keepusing(lbdnum firmid ar tvs)
	tab _merge
	drop if _merge==2 
	drop _merge
		
	*replace original pv_pt with synthetic pv (spv) using following rules
	*  1. drop non-manufacturing prefixes
	*  2. collapse to the SIC4 root
	*  3. apportion tvs to products according to their sum of pv
	*  4. if pv==0 then apportion the pv's equally across products
	*  5. don't drop ar till later since we want to drop firms with ar in either 
	*     year when we do the decomposition
	gen str1 prefix1 = substr(curpc,1,1)
	gen str3 suffix3 = substr(curpc,5,3)
	gen root = substr(curpc,1,4)
	
	keep if prefix1=="2" | prefix1=="3"

	drop if pv_pt<=0    
	
	collapse (sum) pv_pt (mean) tvs, by(firmid lbdnum root) 
	egen total_pv_pt = total(pv_pt), by(lbdnum)
	gen r = tvs/total_pv_pt
	gen spv = pv_pt*r
	egen total_spv = total(spv), by(lbdnum)
	compare total_spv tvs
	
	*take care of cases where all pv==0
	egen np = count(pv_pt), by(lbdnum)
	replace spv = tvs/np if total_spv==0
		
	*save with native product roots
	*save $interim/cmf`y'prod_small_root, replace
	
	*add families from pntr project and collapse
	destring root, force g(s4)
	merge m:1 s4 using $interim/bbg_fam_drop_50_s4_2, keepus(fam50)
	tab _merge 
	drop if _merge==2
	tab root if _merge==1
	drop _merge
	
	collapse (sum) spv, by(firmid lbdnum fam50)
	save $interim/cmf`y'prod_small_fam50_full, replace
}
forvalues y=2002(5)2007 {
	use $input/cmf`y'prod.dta, clear

	foreach x in tvpsd tvps pv {
		rename `x' `x'_pt
	}	

	*merge in info from main files
	sort survu_id
	merge m:1 survu_id using $input/cmf`y', keepusing(lbdnum firmid ar tvs)
	tab _merge
	drop if _merge==2
	drop _merge

	*replace original pv_pt with synthetic pv (spv) using following rules
	*  1. drop non-manufacturing prefixes
	*  2. collapse to the SIC4 root
	*  3. apportion tvs to products according to their sum of pv
	*  4. if pv==0 then apportion the pv's equally across products
	*  5. don't drop ar till later since we want to drop firms with ar in either 
	*     year when we do the decomposition
	gen str1 prefix1 = substr(naicspc,1,1)
	gen str4 suffix4 = substr(naicspc,7,4)
	gen str6 root    = substr(naicspc,1,6)
	egen np = count(pv_pt), by(lbdnum)

	keep if prefix1=="3"
	drop if pv_pt<=0   
	order  firmid lbdnum root tvs pv_pt
	collapse (sum) pv_pt (mean) tvs, by(firmid lbdnum root) 
	egen total_pv_pt = total(pv_pt), by(lbdnum)
	gen r = tvs/total_pv_pt
	gen spv = pv_pt*r
	egen total_spv = total(spv), by(lbdnum)
	compare total_spv tvs
	
	*take care of cases where all pv==0
	egen np = count(pv_pt), by(lbdnum)
	replace spv = tvs/np if total_spv<=0

	*save with native product roots
	*save $interim/cmf`y'prod_small_root, replace
	
	*add families from pntr project and collapse
	destring root, force g(n6)
	merge m:1 n6 using $interim/bbg_fam_drop_50_n6_2, keepus(fam50)
	tab _merge 
	drop if _merge==2
	tab root if _merge==1
	drop _merge

	collapse (sum) spv, by(firmid lbdnum fam50)
	save $interim/cmf`y'prod_small_fam50_full, replace
}

*2.2 compute plant level gaps using above product trailer data
forvalues y=1992(5)2007 {

	use $interim/cmf`y'prod_small_fam50_full, clear
	keep lbdnum fam50 spv 
	gen year = `y'

	merge m:1 fam50 using $interim/gaps_by_naics6_20150722_fam50, keepusing(s1999 wgap_offd31999 iodown31999)
	drop if _merge==2
	drop _merge

	egen totspv=total(spv), by(lbdnum)

	foreach x in s1999 wgap_offd31999 iodown31999 {

		*compute weights; only include pv associated with obs where gap is defined
		gen tjppv`x'=spv
		replace tjppv`x'=. if `x'==.
		egen tjptotpv`x'=total(tjppv`x'), by(lbdnum)
		gen pvweight`x'=tjppv`x'/tjptotpv`x'
		drop tjp*
	
		*replace weighted means with missing if zero
		*totaling a bunch of missing values gives a zero, when it should actually show as missing.
		egen `x'sm=mean(`x'), by(lbdnum)
		gen t`x'wm=`x'*pvweight`x'
		egen `x'wm=total(t`x'wm), by(lbdnum)
		replace `x'wm=. if `x'wm==0 & `x'sm==.
		drop t`x'wm
	}
	gen ilbd = lbdnum==""
	tab ilbd
	drop if ilbd==1
	*save $interim/pgap`y'_00, replace
	
	collapse (mean) s1999?m wgap_offd31999?m iodown31999?m (sum) spv, by(lbdnum year)

	save $interim/pgap`y'_01, replace
}

use $interim/pgap1992_01, clear
forvalues y=1997(5)2007 {
	append using $interim/pgap`y'_01
}
drop spv
save $interim/pgap, replace

*clean up
erase $interim/cmf1992prod_small_fam50_full.dta
erase $interim/cmf1997prod_small_fam50_full.dta
erase $interim/cmf2002prod_small_fam50_full.dta
erase $interim/cmf2007prod_small_fam50_full.dta
erase $interim/pgap1992_01.dta
erase $interim/pgap1997_01.dta
erase $interim/pgap2002_01.dta
erase $interim/pgap2007_01.dta
		
		
		
		
*3 Create quinquennial CM employment file

*3.1 create deflators from nber-ces public file
*    all deflation is done to 1997 base for CM
use $input/sic5809, clear
rename sic sic4
drop if sic4==.
sort sic4 year
foreach x in piship pimat piinv {
	gen t1 = year==1997
	gen t2 = t1*`x'
	egen t3 = max(t2), by(sic4)
	replace `x' = `x'/t3
	drop t1-t3
}
*create deflator for sic 3732 (missing in BBG) using those for sic 3731
save $interim/t1, replace
keep if sic4==3731
replace sic4=3732 if sic4==3731
save $interim/t3732, replace
clear all
use $interim/t1
drop if sic4==3732
append using $interim/t3732
save $interim/temp_bbg_sic, replace

clear all
use $input/naics5809
rename naics naics6
drop if naics6==.
sort naics6 year
*Now create deflators for naics 336612 (errors in BBG) simply using those for naics 336611
save $interim/t1, replace
keep if naics6==336611
replace naics6=336612 if naics6==336611
save $interim/t336612, replace
clear all
use $interim/t1
drop if naics6==336612
append using $interim/t336612
save $interim/temp_bbg_naics, replace

*3.2 refine cm files
clear all
use $interim/bbg_fam_drop_50_n6_2
save $interim/bbg_fam_drop_50_naics, replace
rename naics naics6
sort naics6
save $interim/temp_fam_naics_50, replace

clear all
use $interim/bbg_fam_drop_50_s4_2
save $interim/bbg_fam_drop_50_sic, replace
rename sic sic4
sort sic4
save $interim/temp_fam_sic_50, replace

forvalues yyyy=1997(-5)1992 {
	
	use firmid lbdnum te ind tvs va tae mr br cm numprods exp pw pe oe sw ww ow ph ar tce tme using $input/cmf`yyyy', clear
	rename ind sic4
	capture gen year=`yyyy'
	
	*add families: these temp files are created right before this loop above in order to rename
	*family to fam`n' and to create a numeric sic4 
	sort sic4
	merge m:1 sic4 using $interim/temp_fam_sic_50, keepusing(fam50 con50 lib50)
	drop if _merge==2
	gen fammiss=fam50==.
	table fammiss, c(sum te) f(%20.0fc)
	drop _merge fammiss
			
	*add deflators
	sort sic4 year
	merge m:1 sic4 year using $interim/temp_bbg_sic, keepusing(piship piinv pimat)	
	drop if _merge==2
	drop _merge

	*drops: add these from cycles program
	*the pe instead of pw bug from here and below was fixed 2012.4.6
	gen drop=0 
	replace drop=1 if sw>100000 & sw/te>200 & sw!=. & te!=.
	replace drop=1 if te>30000 & te!=.
	replace drop=1 if ww>100000 & ww/pw>200 & ww!=. & pw!=.
	replace drop=1 if pw>30000 & pw!=.
	replace drop=1 if ow>100000 & ow/oe>200 & ow!=. & oe!=.
	replace drop=1 if oe>30000 & oe!=.
	drop if drop==1
		
	*collapse and save
	keep firmid lbdnum te sic4 year pi* tvs va tae mr br cm numprods exp pe oe sw pw ww ow ph fam* con* lib* ar tce tme
	
	*compute plant attributes
	gen rtae      = tae/piinv
	gen rtce      = tce/piinv
	gen rtme      = tme/piinv
	gen rtvs      = tvs/piship
	gen rva       = va/piship
	gen rcm       = cm/pimat
	gen rtvs_te   = rtvs/te
	gen rva_te    = rva/te
	gen rtae_te   = rtae/te
	gen rcm_te    = rcm/te
	gen oe_te     = oe/te
	gen sw_te     = sw/te
	gen ww_pw     = ww/pw
	gen ow_oe     = ow/oe
	gen pw_te     = pw/te
	gen rtae_rtvs = rtae/rtvs
	gen tae_tvs   = tae/tvs
	gen rcm_rtvs  = rcm/rtvs
	gen cm_tvs    = cm/tvs	
	gen ph_te     = ph/te
	
	*Calculate real value of wages/salaries
	gen cpi1997=160.53
	gen cpi=.
	replace cpi=60.62 if year==1977
	replace cpi=96.53 if year==1982
	replace cpi=113.62 if year==1987
	replace cpi=140.31 if year==1992
	replace cpi=160.53 if year==1997
	replace cpi=179.87 if year==2002
	replace cpi=207.34 if year==2007
	gen wage_def=cpi/cpi1997
	gen rsw=sw/wage_def
	gen rww=ww/wage_def
	gen row=ow/wage_def
	gen rsw_te = rsw/te
	gen rww_pw = rww/pw
	gen row_oe = row/oe	
	
	drop if lbdnum==""
	sort lbdnum year
	table con50, c(sum te) f(%20.0fc)
	
	save $interim/tcycles_cm`yyyy', replace
}

forvalues yyyy=2007(-5)2002 {

	use firmid lbdnum te naics_new tvs va tae mr br cm numprods exp pw pe oe sw ww ow ph ar tce tme using $input/cmf`yyyy', clear	
	gen temp = substr(naics_new,1,6)
	destring temp, force g(naics6)
	capture gen year=`yyyy'
	
	*add families
	sort naics6
	merge m:1 naics6 using $interim/temp_fam_naics_50, keepusing(fam50 con50 lib50)
	drop if _merge==2
	gen fammiss=fam50==.
	table fammiss, c(sum te) f(%20.0fc)
	drop _merge fammiss
	
	*add deflators
	sort naics6 year
	merge m:1 naics6 year using $interim/temp_bbg_naics, keepusing(piship piinv pimat)	
	tab _merge
	drop if _merge==2
	drop _merge

	*drops: add these from cycles program
	*the pe instead of pw bug from here and below was fixed 2012.4.6

	gen drop=0 
	replace drop=1 if sw>100000 & sw/te>200 & sw!=. & te!=.
	replace drop=1 if te>30000 & te!=.
	replace drop=1 if ww>100000 & ww/pw>200 & ww!=. & pw!=.
	replace drop=1 if pw>30000 & pw!=.
	replace drop=1 if ow>100000 & ow/oe>200 & ow!=. & oe!=.
	replace drop=1 if oe>30000 & oe!=.
	replace drop=1 if ar==1
	drop if drop==1
		
	*collapse and save
	keep firmid lbdnum te naics6 year pi* tvs va tae mr br cm numprods exp pe oe sw pw ww ow ph fam* con* lib* ar tce tme
	
	*compute plant attributes
	gen rtae      = tae/piinv
	gen rtce      = tce/piinv
	gen rtme      = tme/piinv
	gen rtvs      = tvs/piship
	gen rva       = va/piship
	gen rcm       = cm/pimat
	gen rtvs_te   = rtvs/te
	gen rva_te    = rva/te
	gen rtae_te   = rtae/te
	gen rcm_te    = rcm/te
	gen oe_te     = oe/te
	gen sw_te     = sw/te
	gen ww_pw     = ww/pw
	gen ow_oe     = ow/oe
	gen pw_te     = pw/te
	gen rtae_rtvs = rtae/rtvs
	gen tae_tvs   = tae/tvs
	gen rcm_rtvs  = rcm/rtvs
	gen cm_tvs    = cm/tvs
	gen ph_te     = ph/te
	
	*Calculate real value of wages/salaries
	*Use 2005 as base year, because this is the base year used for BBG deflators
	gen cpi1997=160.53
	gen cpi=.
	replace cpi=60.62 if year==1977
	replace cpi=96.53 if year==1982
	replace cpi=113.62 if year==1987
	replace cpi=140.31 if year==1992
	replace cpi=160.53 if year==1997
	replace cpi=179.87 if year==2002
	replace cpi=207.34 if year==2007
	gen wage_def=cpi/cpi1997
	gen rsw=sw/wage_def
	gen rww=ww/wage_def
	gen row=ow/wage_def
	gen rsw_te = rsw/te
	gen rww_pw = rww/pw
	gen row_oe = row/oe	
	
	drop if lbdnum==""
	sort lbdnum year
	table con50, c(sum te) f(%20.0fc)
	
	save $interim/tcycles_cm`yyyy', replace
}


*3.3 compute TFP (caves et al index method)
clear all
use $interim/tcycles_cm1992
foreach x in 1997 2002 2007 {
	append using $interim/tcycles_cm`x'
}

*do some basic drops (tfp can't be calculated if any of these values are missing anyway
foreach x in tvs tae oe pw cm ww ow {
	drop if `x'==. | `x'==0
}
drop if ar==1

*calculate expenditure shares with nominal values
foreach x in ww ow cm { 
      gen s_`x' = `x'/tvs 
} 

*hand input interest rate data; Source: U.S. "Lending Rate" Series from IMF's International Financial Statistics
gen rt=.
replace rt=5.248 if year==1972
replace rt=6.824 if year==1977
replace rt=14.861 if year==1982
replace rt=8.203 if year==1987
replace rt=6.252 if year==1992
replace rt=8.442 if year==1997
replace rt=4.675 if year==2002
replace rt=8.050 if year==2007
replace rt=rt/100
gen rit=rt+0.1

gen s_tae=(rit*tae)/tvs
gen s_tae2 = 1-s_cm-s_ww-s_ow

foreach x in rtvs rtae oe pw rcm {
	gen l`x'=ln(`x')
}

*note that the mean share is time-invariant
foreach xxx in s_ow s_ww s_cm s_tae s_tae2 { 
	egen m`xxx'_fhs = mean(`xxx'), by(fam50) 
} 

gen ltfp_fhs=lrtvs-(ms_tae_fhs*lrtae)-(ms_ow_fhs*loe)-(ms_ww_fhs*lpw)-(ms_cm_fhs*lrcm)
gen ltfp_fhs2=lrtvs-(ms_tae2_fhs*lrtae)-(ms_ow_fhs*loe)-(ms_ww_fhs*lpw)-(ms_cm_fhs*lrcm)

keep lbdnum year ltfp_fhs*

sort lbdnum year
save $interim/fhs_prod, replace


*3.4 compute plant age
forvalues y=1992(5)2007 {
	clear all
	use lbdnum yr firstyear lastyear using $input/lbd`y' if lbdnum~=""
	rename yr year
	gen age=year-firstyear
	keep lbdnum year age lastyear
	save $interim/tage`y', replace
}

clear all
use $interim/tage1992
append using $interim/tage1997 $interim/tage2002 $interim/tage2007
save $interim/page, replace



*3.5 merge productivity data into CM datasets
forvalues x=1992(5)2007 {
	clear all
	use $interim/tcycles_cm`x'
	merge 1:1 lbdnum year using $interim/fhs_prod
	drop if _merge==2
	drop _merge
	save $interim/cycles_cm`x', replace
}



*3.5 convert above to families
clear all
use $interim/cycles_cm1992
append using $interim/cycles_cm1997 $interim/cycles_cm2002 $interim/cycles_cm2007

*add in new families that incorporate naics02-07 changes
drop con50 lib50 fam50
*first merge in sic file for years 1992 & 1997
rename sic4 s4
merge m:1 s4 using $interim/bbg_fam_drop_50_s4_2, keepusing(fam50 con50 lib50)
table _merge, c(sum te) f(%20.0fc)
drop if _merge==2
drop _merge
rename naics6 n6
merge m:1 n6 using $interim/bbg_fam_drop_50_n6_2, keepusing(fam50 con50 lib50) update
table _merge, c(sum te) f(%20.0fc)
drop if _merge==2
drop _merge
gen fammiss=fam50==.
table fammiss, c(sum te) f(%20.0fc)
table fammiss year, c(sum te) f(%20.0fc)
*This looks great.  The unmatched emp is in missing non-manufacturing industry codes
*tab s4 if fammiss==1 & year==1992
*tab s4 if fammiss==1 & year==1997
*tab n6 if fammiss==1 & year==2002
*tab n6 if fammiss==1 & year==2007

*drop plants that are ever outside the con50 sample
*drop plants that don't have con50 assigned because they don't get families assigned.
*These plants are either non-manufacturing or missing industry plants
replace con50=0 if con50==.
egen mincon50=min(con50), by(lbdnum)
tab mincon50, missing
table mincon50, c(sum te) f(%20.0fc)
drop if mincon50==0

*set each plant's family to the family that is closest to 1997
sort lbdnum year
egen minyr=min(year), by(lbdnum)
gen t1=.
replace t1=fam50 if year==minyr
egen fam50minyr=mean(t1), by(lbdnum)
drop t1
gen t1=.
replace t1=te if year==minyr
egen teminyr=mean(t1), by(lbdnum)
drop t1
egen maxyr=max(year), by(lbdnum)
gen t1=.
replace t1=fam50 if year==maxyr
egen fam50maxyr=mean(t1), by(lbdnum)
drop t1
gen t1=.
replace t1=fam50 if year==1997
replace t1=fam50minyr if minyr>1997 & t1==.
replace t1=fam50maxyr if maxyr<1997 & t1==.
*following line is for plants that are present before and after 1997 but not in 1997
replace t1=fam50minyr if fam50minyr!=. & t1==.
egen fam501997=mean(t1), by(lbdnum)
drop t1
rename fam50 fam50tv
rename fam501997 fam50

*merge in spread 
merge m:1 fam50 using $interim/gaps_by_naics6_20150722_fam50, keepus(iogap* wgap* s* iodown* nntr* ntr*)
drop if _merge==2
drop _merge

*merge in the chinese tariff data
merge m:1 fam50 year using $interim/robustness_chn_tariff_fam50_true, keepus(r dr)
drop if _merge==2
drop _merge
	
*merge in union data
merge m:1 fam50 year using $interim/robustness_union_fam50
drop if _merge==2
drop _merge
	
*merge in atp data
merge m:1 fam50 year using $interim/robustness_matp_fam50
replace atp=0 if atp==.
drop if _merge==2
drop _merge
	
*merge in contractibility data
merge m:1 fam50 using $interim/robustness_contract_fam50
drop if _merge==2
drop _merge		

*merge in mfa with new way including fill rates and import-weighting
merge m:1 fam50 year using $interim/robustness_mfa_fam50_yr
drop if _merge==2
drop _merge
foreach x in s123 s4 s1234 sm123 sm4 sm1234 sf2001 sf2004 sf sfw2001 sfw2004 sfw sfw2001_mwt sfw2004_mwt sfw_mwt sfw2004_mwt_sum sfw_mwt_sum  {
	replace `x'_new=0 if `x'_new==.
}

*merge in ntr and dntr data
merge m:1 fam50 year using $interim/robustness_ntr_fam50_true_adj, keepus(ntr dntr)
drop if _merge==2
drop _merge		

*merge in family-year-level revealed tariff, calculated with all import programs
merge m:1 fam50 year using $interim/robustness_revealed_t0_t1_fam50_yr
drop if _merge==2
drop _merge

*merge in Chinese subsidy data
merge m:1 fam50 using $interim/robustness_chinese_subsidy_per_sales, keepus(sub1999 sub2005 dsub)
drop if _merge==2
drop _merge	

*merge in chinese export licensing data
merge m:1 fam50 using $interim/robustness_chinese_exp_lic, keepus(se1999 se2003 dse)
drop if _merge==2
drop _merge	

*merge in gdp data
merge m:1 year using $interim/robustness_rgdp_yr
drop if _merge==2
drop _merge

*merge in trefler business cycle control
merge m:1 fam50 year using $interim/robustness_trefler_fam50_yr, keepus(yhat*)
drop if _merge==2
drop _merge

gen lkl=ln(rtae/te)
gen lsl=ln(oe/te)
gen lkpw=ln(rtae/pw)
egen tmrtae=median(rtae), by(fam50 year)
replace tmrtae=. if year!=1992
egen mrtae1992=mean(tmrtae), by(fam50)
gen lmrtae1992=ln(mrtae1992)


*generate initial levels
foreach y in te lkl lsl mem cov ltfp_fhs rtvs {
	foreach x in 1992 {
		gen i        = year==`x'
		gen t1       = `y'*i
		replace t1=. if ~i
		egen `y'`x'  = max(t1), by(lbdnum)
		drop t1 i
	}
}

foreach x in lkl lsl {
	gen `x'minyr=.
	replace `x'minyr=`x'1992 if minyr==1992
	replace `x'minyr=`x'1997 if minyr==1997
}

*merge in plant-level gap data
merge 1:1 lbdnum year using $interim/pgap, keepusing(s1999sm s1999wm wgap_offd31999sm wgap_offd31999wm ///
                                                           iodown31999sm iodown31999wm)
drop if _merge==2
drop _merge
	
gen post=year>=2002

*generate "post" interactions
foreach z in s1999 lkl1992 lsl1992 lklminyr lslminyr contract dr dsub se1999 atp wgap_offd31999 ///
             iodown31999 s1999sm s1999wm wgap_offd31999sm wgap_offd31999wm iodown31999sm iodown31999wm ///
	     lmrtae1992 {
	gen `z'_post=`z'*post
}

gen smp=s1999*lmrtae1992*post

keep lbdnum firmid year fam50* tvs te pw oe ph rtae rtce rtme rtvs rva rww rsw row ltfp_fhs ///
     ltfp_fhs1992 s1999 s1999_post lkl1992_post lsl1992_post lklminyr_post lslminyr_post lkl lsl ///
     contract_post dr_post dsub_post se1999_post atp_post sfw_mwt_sum_new mem ntr te1992 con50 post ///
     lmrtae1992 lmrtae1992_post smp lkpw wgap_offd31999 iodown31999 wgap_offd31999_post ///
     iodown31999_post teminyr s1999sm s1999wm wgap_offd31999sm wgap_offd31999wm iodown31999sm ///
     iodown31999wm s1999sm_post s1999wm_post wgap_offd31999sm_post wgap_offd31999wm_post ///
     iodown31999sm_post iodown31999wm_post teminyr  

*merge in age
merge 1:1 lbdnum year using $interim/page
drop if _merge==2
drop _merge

gen rva_te=rva/te
gen rtvs_te=rtvs/te
gen rsw_te=rsw/te
gen rww_pw=rww/pw
gen row_oe=row/oe

foreach x in te oe pw ph rtae age rva rtvs rsw rww row rva_te rtvs_te rsw_te rww_pw row_oe {
	gen l`x'=ln(`x')
}

forvalues x=1992(5)2007 {
	gen d`x'=year==`x'
}

save $interim/cm_true_plant, replace


*clean up
erase $interim/cycles_cm1992.dta
erase $interim/cycles_cm1997.dta
erase $interim/cycles_cm2002.dta
erase $interim/cycles_cm2007.dta
erase $interim/tcycles_cm1992.dta
erase $interim/tcycles_cm1997.dta
erase $interim/tcycles_cm2002.dta
erase $interim/tcycles_cm2007.dta
erase $interim/fhs_prod.dta
erase $interim/t1.dta
erase $interim/t336612.dta
erase $interim/t3732.dta



*3.6 collapse to industries
use $interim/cm_true_plant, clear
collapse (sum) tvs te pw oe ph rtae rtce rtme rtvs rva rww rsw row ///
         (mean) s1999 s1999_post contract_post dr_post dsub_post se1999_post ///
	        atp_post sfw_mwt_sum_new mem ntr con50 post wgap_offd31999 ///
		iodown31999 wgap_offd31999_post iodown31999_post lmrtae1992 ///
		lmrtae1992_post smp, by(fam50 year) fast
gen lkl=ln(rtae/te)
gen lkpw=ln(rtae/pw)
gen lsl=ln(oe/te)
gen rva_te=rva/te
gen rtvs_te=rtvs/te
gen rsw_te=rsw/te
gen rww_pw=rww/pw
gen row_oe=row/oe

*generate covariate values by year 
foreach y in te lkl lsl rtvs {
	foreach x in 1992 {
		gen i        = year==`x'
		gen t1       = `y'*i
		replace t1=. if ~i
		egen `y'`x'  = max(t1), by(fam50)
		drop t1 i
	}
}
gen lkl1992_post=lkl1992*post
gen lsl1992_post=lsl1992*post
foreach x in te oe pw ph rtae rva_te rtvs_te rsw_te rww_pw row_oe rtvs rva {
	gen l`x'=ln(`x')
}
forvalues x=1992(5)2007 {
	gen d`x'=year==`x'
}

keep if con50==1
keep if year>=1992 & year<=2007
gen i = 1
foreach x in lte loe lpw lph lrtae lkl lsl s1999_post lkl1992_post lsl1992_post contract_post dr_post ///
             dsub_post se1999_post atp_post sfw_mwt_sum_new mem ntr te1992 {
	replace i=0 if `x'==.
}

egen ti = total(i), by(fam50)
tab ti
keep if ti==4
save $interim/cm_true_fam50, replace

*save fam50 that are always present
use $interim/cm_true_fam50, clear
collapse (mean) te, by(fam50)
drop te
save $interim/cm_constant, replace



*4 Create trade dataset

*4.1 create concordances and NTR gap 

*4.1.1 concording data for 92-07 and 97-07 (from cycles)
use $input/hts_concordances_20101020_199201_200707_8, clear
keep obsolete setyr
drop if obsolete==.
capture duplicates drop 
sort obsolete
save $interim/temp_obsolete8_9207, replace	
	
use $input/hts_concordances_20101020_199201_200707_8, clear
keep new setyr
drop if new==.
duplicates drop 
sort new
save $interim/temp_new8_9207, replace

*4.1.2 get spread ready (needs to be added before adding setyr)
use $input/tar_val, clear
rename hs8 shs8
destring shs8, force g(hs8)
rename ntr_rate ntr
rename non nntr
rename spread s
keep ntr nntr s year hs8
reshape wide ntr nntr s, i(hs8) j(year)
sort hs8
save $interim/hs8_spread, replace

*4.1.3 refine raw trade data
*prep LBD files for use in matching firm identification codes across years
forvalues y=2001/2008 {
	clear all
	use firmid cfn using $input/lbd`y'
	drop if cfn=="" | firmid==""
	rename firmid firmid2
	duplicates drop cfn firmid2, force
	duplicates report cfn
	sort cfn
	save $interim/lbdt`y', replace
}

*refine raw trade data and fix firm identification codes
quietly {
 forvalues z=1992/2007 {
	noisily display "`z'"
	clear all
	use alpha1 hs1 country1 year rp type manuf_id v using $input/raw_stata_m_10_`z'
	keep if type=="1" | type=="2" | type=="5"
	gen mval   = v
	gen mrpval = v*(rp==1)
	gen malval = v*(rp==0)
	collapse (sum) mval mrpval malval, by(alpha1 hs1 country1 year rp manuf_id v) fast
	drop if alpha==.
	gen mu=alpha<=999999
	replace alpha=alpha*10000 if alpha<=999999
	rename alpha firmid
	rename firmid firmidnum
	tostring firmidnum, g(firmid)
	gen zero1="0"
	gen zero2="00"
	gen zero3="000"
	egen firmid1=concat(zero1 firmid) if firmidnum<=999999999 & firmidnum>99999999
	egen firmid2=concat(zero2 firmid) if firmidnum<=99999999 & firmidnum>9999999
	egen firmid3=concat(zero3 firmid) if firmidnum<=9999999 & firmidnum>999999
	replace firmid=firmid1 if firmidnum<=999999999 & firmidnum>99999999
	replace firmid=firmid2 if firmidnum<=99999999 & firmidnum>9999999
	replace firmid=firmid3 if firmidnum<=9999999 & firmidnum>999999
	drop firmid1 firmid2 firmid3 zero*
	if `z' <=2001 {
		save $interim/m`z'_01, replace
	}
	if `z'>=2002 {
		rename firmid cfn
		save $interim/m`z'_00, replace
	}	
 } 
}
quietly {
 forvalues z=2002/2007 {
	local p1=`z'+1
	local m1=`z'-1

	noisily display ["`z'"]

	clear all
	use $interim/m`z'_00
	keep if mu==0
	merge m:1 cfn using $interim/lbdt`z'
	tab _merge
	noisily table _merge, c(sum mval) f(%18.0fc)
	drop if _merge==2
	gen firmid=""
	replace firmid=firmid2 if _merge==3
	drop _merge
	merge m:1 cfn using $interim/lbdt`p1'
	tab _merge
	drop if _merge==2
	replace firmid=firmid2 if _merge==3 & firmid==""
	drop _merge
	merge m:1 cfn using $interim/lbdt`m1'
	tab _merge
	drop if _merge==2
	replace firmid=firmid2 if _merge==3 & firmid==""
	drop _merge
	*have the firm keep its original firmid if cfn didn't match to the LBD
	gen noid=firmid==""
	noisily table noid, c(sum mval) f(%18.0fc)
	drop noid
	replace firmid=cfn if firmid==""
	codebook firmid
	save $interim/su`z', replace
	
	*recombine mu and su firms
	clear all
	use $interim/m`z'_00
	drop if mu==0
	rename cfn firmid
	append using $interim/su`z'
	save $interim/m`z'_01, replace
 }
}
clear all
use $interim/m1992_01
forvalues z=1993/2007 {
	append using $interim/m`z'_01
}
save $interim/m19922007_01, replace

*clean up
erase $interim/su2002.dta
erase $interim/su2003.dta
erase $interim/su2004.dta
erase $interim/su2005.dta
erase $interim/su2006.dta
erase $interim/su2007.dta
erase $interim/m1992_01.dta
erase $interim/m1993_01.dta
erase $interim/m1994_01.dta
erase $interim/m1995_01.dta
erase $interim/m1996_01.dta
erase $interim/m1997_01.dta
erase $interim/m1998_01.dta
erase $interim/m1999_01.dta
erase $interim/m2000_01.dta
erase $interim/m2001_01.dta
erase $interim/m2002_01.dta
erase $interim/m2003_01.dta
erase $interim/m2004_01.dta
erase $interim/m2005_01.dta
erase $interim/m2006_01.dta
erase $interim/m2007_01.dta
erase $interim/m2002_00.dta
erase $interim/m2003_00.dta
erase $interim/m2004_00.dta
erase $interim/m2005_00.dta
erase $interim/m2006_00.dta
erase $interim/m2007_00.dta
erase $interim/lbdt2001.dta
erase $interim/lbdt2002.dta
erase $interim/lbdt2003.dta
erase $interim/lbdt2004.dta
erase $interim/lbdt2005.dta
erase $interim/lbdt2006.dta
erase $interim/lbdt2007.dta



*4.1.4 create country x year x mfa fill rate dataset for 20150916 mfa vars
*      called dmfaXfr below
use $input/mfa8404, clear
keep if year>=94 & year<=104
gen t1 = length(mfa_root)
tab t1
keep mfa_root fr year country year t1
gen mfa1 = substr(mfa_root,1 ,3) if t1>=3
gen mfa2 = substr(mfa_root,5 ,3) if t1>=7
gen mfa3 = substr(mfa_root,9 ,3) if t1>=9
gen mfa4 = substr(mfa_root,13,3) if t1>=13
gen mfa5 = substr(mfa_root,17,3) if t1>=17
gen mfa6 = substr(mfa_root,21,3) if t1>=21
replace mfa2 = "." if mfa2==""
replace mfa3 = "." if mfa3==""
replace mfa4 = "." if mfa4==""
replace mfa5 = "." if mfa5==""
replace mfa6 = "." if mfa6==""
duplicates drop
save $interim/fr_junk0, replace

foreach x in 1 2 3 4 5 6 {
	use $interim/fr_junk0, clear
	keep fr year country mfa`x'
	drop if mfa`x'=="."
	rename mfa`x' mfa
		save $interim/fr_junk`x', replace
}
foreach x in 1 2 3 4 5 {
	append using $interim/fr_junk`x'
}
duplicates drop
replace fr = fr*100
duplicates report mfa country year
save $interim/fill_03_raw, replace

use $interim/fill_03_raw, clear
collapse (mean) fr, by(mfa country year)
rename mfa smfa
destring smfa, force g(mfa)
*drop smfa fr
replace year=year+1900
*reshape wide fr_row fr_chn fr_all, i(mfa) j(year)
*merge in uscountry codes and then make any manual adjustments needed
merge m:1 country using $input/uscode_upper
tab _merge
drop if _merge==2
tab country if _merge==1
drop _merge
replace uscode=5460 if country=="BURMA"
replace uscode=5800 if country=="KOREA, SOUTH"
replace uscode=5530 if country=="LAOS"
replace uscode=5660 if country=="MACAU"
replace uscode=4359 if country=="SLOVAK REPUBLIC"
replace uscode=5200 if country=="UAE"
inspect uscode
drop smfa var2 
rename country scountry
rename uscode country1
replace fr=0 if fr==.
reshape wide fr, i(country scountry mfa) j(year) 
forvalues y=1994(1)2004 {
	replace fr`y'=0 if fr`y'==.
}
save $interim/fill_03, replace

*now match these fill rates to the the trade data
*
*  start with the full set of trade triplets from the dataset created below
*
*  then add in phases and the fill rates from above
*
*  then create mfa phase indicators
*
use country1 year hs using $interim/m19922007_01, clear
duplicates drop
save $interim/country_hs_year_1992_2007, replace

use $interim/country_hs_year_1992_2007, clear
drop year
duplicates drop
save $interim/country_hs_1992_2007, replace

use $interim/country_hs_1992_2007, clear
rename hs1 hs
merge m:1 hs using $input/hs_mfa_phase_20111208, keepus(phase mfa)
tab _merge
tab _merge phase
drop if _merge==2
drop _merge
merge m:1 country mfa using $interim/fill_03, keepus(fr*)
tab _merge
drop if _merge==2
drop _merge
rename mfa mfa_sector
gen mfa1 = phase==1
gen mfa2 = phase==2
gen mfa3 = phase==3
gen mfa4 = phase==4
gen mfa = phase>=1 & phase<=4
forvalues y=1994(1)2004 {
	replace fr`y'=0 if fr`y'==.
}
save $interim/robustness_country_hs_year_fill_rates, replace

use $interim/robustness_country_hs_year_fill_rates, clear
gen double hs8 = int(hs/100)
collapse (mean) fr* (max) mfa1 mfa2 mfa3 mfa4 mfa, by(hs8 country1)
save $interim/robustness_country_hs8_year_fill_rates, replace

*clean up
erase $interim/fr_junk0.dta
erase $interim/fr_junk1.dta
erase $interim/fr_junk2.dta
erase $interim/fr_junk3.dta
erase $interim/fr_junk4.dta
erase $interim/fr_junk5.dta
erase $interim/fr_junk6.dta
erase $interim/fill_03_raw.dta
erase $interim/fill_03.dta



*4.1.5 product-country revealed tariffs (needs to be added before adding setyr)
*   (from usitc program and folder)
use $input/hs8c_revealed_tariffs_20140519, clear
rename tall0 ta0
rename tall1 ta1
rename hs8num hs8
replace year=year-1900
sort hs8 year cty
rename cty country1
save $interim/robustness_hs8c_t, replace


*4.1.6 country-year exchange rate data 
*    (from http://www.rug.nl/research/ggdc/data/penn-world-table)
use $input/robustness_ct_xr, clear
rename cty_code country1
sort country1 year
save $interim/robustness_ct_xr, replace



*4.1.7 country-year real effective exchange rate data 
*    (from http://www.rug.nl/research/ggdc/data/penn-world-table)
use $input/uscode_uncode_wbcode_feenstra, clear
keep wbcode uscode
duplicates drop
drop if wbcode=="."
rename uscode country1
sort country1
save $interim/temp_uscode_wbcode, replace
*Note: the concordance is many uscode to 1 wbcode (there are never instances where 1 us code matches to multiple wbcode)

clear all
set obs 16
gen t1=1991
egen t2=seq()
gen year = t1+t2
drop t1 t2
cross using $interim/temp_uscode_wbcode
sort wbcode year
save $interim/temp_reer_blank, replace

use $input/wb_reer_20140603, clear
rename countrycode wbcode
drop if wbcode==""
keep wbcode yr*
reshape long yr, i(wbcode) j(year)
destring yr, force g(reer)
drop yr
save $interim/temp_reer, replace

use $interim/temp_reer_blank, clear
sort wbcode year
merge m:1 wbcode year using $interim/temp_reer, keepus(reer)
tab _merge
drop if _merge==2
drop _merge
keep country1 year reer
sort country1 year
save $interim/robustness_ct_reer, replace

erase $interim/temp_reer.dta
erase $interim/temp_uscode_wbcode.dta



*4.2 use above to assemble HS8 trade dataset

*4.2.1 merge in new-obsolete codes
use hs mval mrpval malval firmid manuf_id year country1 using $interim/m19922007_01 if year>=1992 & year<=2007, clear
gen double hs8=int(hs/100)
collapse (sum) mval mrpval malval, by(firmid manuf_id hs8 year country) fast
format hs8 %15.0fc
replace year = year-1900 
save $interim/m9207_hs8, replace

*merge in obsolete-code family identifiers
*use $interim/m9207_hs8 if _n<100, clear
use $interim/m9207_hs8, clear
rename hs8 obsolete
sort obsolete
merge m:1 obsolete using $interim/temp_obsolete8_9207, keepus(setyr)
rename setyr setyr1
tab _merge
drop if _merge==2
drop _merge
rename obsolete hs8

*merge in new-code family identifiers
rename hs8 new
sort new
merge m:1 new using $interim/temp_new8_9207, keepus(setyr)
tab _merge
rename setyr setyr2
drop if _merge==2
drop _merge
rename new hs8

*edit if setyr1~-. & setyr2~=.
gen double setyr = setyr1 
replace setyr = setyr2 if setyr==.
sort setyr
drop setyr1 setyr2

save $interim/junk_hs8_new_obs_protection, replace

use $interim/junk_hs8_new_obs_protection, clear

*merge in spread here so it is associated with all the setyrs; 
*we will make use of it again in the loop below
sort hs8
merge m:1 hs8 using $interim/hs8_spread, keepus(s1999 s1990 nntr1990 nntr1999)
tab _merge
drop if _merge==2
drop _merge

*merge in mfa dummies and fill rates here so they are associated with all the setyrs; 
*we will make use of it again in the loop below
sort hs8
merge m:1 hs8 country using $interim/robustness_country_hs8_year_fill_rates, keepus(mfa mfa1 mfa2 mfa3 mfa4 fr*)
tab _merge
drop if _merge==2
drop _merge

*merge in country-product tariffs here when ready
sort hs8 year country1
merge m:1 hs8 year country1 using $interim/robustness_hs8c_t, keepus(ta0 ta1)
tab _merge
drop if _merge==2
drop _merge

*now that merging is done, create new hs8 variable that is reset to a setyr if needed
rename hs8 hs8_original
gen double hs8 = hs8_original
replace hs8 = setyr if setyr~=. 
egen t0 = tag(hs8 year)
table year, c(sum t0)
drop t0

*check everything id double
des hs* set*

*create natural resource id: use ORIGINAL HS CODE!!!
gen hs2  = int(hs8_orig/1000000)
gen nr   = hs2<14 | (hs2>=25 & hs2<=27)
tab hs2 if nr==1

*create appropriate averages for after the collapsing below
*
*
egen i = tag(hs8_original hs8)
gen t1 = s1999*i
replace t1=. if i==0
egen checks1999 = mean(t1), by(hs8)
drop t1
gen t1 = s1990*i
replace t1=. if i==0
egen checks1990 = mean(t1), by(hs8)
gen t2 = hs2*i
replace t2=. if i==0
egen modehs2 = mode(t2), maxmode by(hs8)
drop i t1 t2 

egen i = tag(hs8_orig hs8 country year)
gen t1 = ta0 * i
replace t1=. if i==0
gen t2 = ta1 * i
replace t2=. if i==0
egen checkta0 = mean(t1), by(country1 hs8 year)
egen checkta1 = mean(t2), by(country1 hs8 year)
drop i t1 t2

*save file to recover setyr-level spreads
save $interim/m9207_setyr_00, replace

*collapse to new hs8 which have setyr in them 
use $interim/m9207_setyr_00, clear
collapse (sum) mval mrpval malval (mean) checks1999 ///
               checks1990 checkta0 checkta1 modehs2 (max) nr, by(firmid manuf_id ///
	       hs8 year country) fast
save $interim/m9207_setyr_01, replace




*4.2.2  merge in spread, fill rates, MFA dummies and XR; create firm counts
use $interim/m9207_setyr_00, clear
keep hs8 hs8_orig year setyr s* nntr* mfa*
egen i = tag(hs8_orig hs8)
save $interim/junk_setyr_spread_01, replace

use $interim/m9207_setyr_00, clear
keep hs8 hs8_orig year setyr ta0 ta1 fr* country year
egen i = tag(hs8_orig hs8 country year)
save $interim/junk_setyr_ta0_01, replace

use $interim/junk_setyr_spread_01, clear
keep if i
collapse (mean) s1999 s1990 nntr1990 nntr1999 (max) mfa mfa1 mfa2 mfa3 mfa4, by(hs8)
sum s1999, det
save $interim/junk_setyr_spread_02, replace

use $interim/junk_setyr_ta0_01, clear
keep if i
collapse (mean) ta0 ta1 fr*, by(country1 hs8 year)
sum ta0, det
save $interim/junk_setyr_ta0_02, replace



*4.2.3 merge in spread and create firm counts
use $interim/m9207_setyr_01, clear

*all firms
egen nf = tag(firmid   hs8 country year)
egen nm = tag(manuf_id hs8 country year)
gen np = 1

*rp,al firms
gen rp   = mrpval~=0
egen nf1 = tag(firmid   rp hs8 country year)
egen nm1 = tag(manuf_id rp hs8 country year)
gen nfrp = nf1==1 & rp==1
gen nfal = nf1==1 & rp==0
gen nmrp = nm1==1 & rp==1
gen nmal = nm1==1 & rp==0
gen nprp = rp==1
gen npal = rp==0

save $interim/junk_firm_counts, replace

*collapse
use $interim/junk_firm_counts, clear
collapse (sum) mval mrpval malval nf nm np nfrp nmrp nprp nfal nmal npal (mean) checks1999 ///
               checks1990 checkta0 checkta1 (max) nr, by(hs8 year country) fast
save $interim/junk_firm_counts_post, replace /*crash protection*/



*merge in spread and mfa dummies and ta0
use $interim/junk_firm_counts_post, clear
merge m:1 hs8 country1 year using $interim/junk_setyr_ta0_02, keepus(ta0 ta1 fr*)
tab _merge
drop if _merge==2
drop _merge
 
merge m:1 hs8 using $interim/junk_setyr_spread_02, keepus(s1999 s1990 nntr1990 nntr1999 mfa mfa1 mfa2 mfa3 mfa4)
tab _merge
drop if _merge==2
drop _merge

replace year=year+1900

*these are identical
compare checks1999 s1999
compare checks1990 s1990

*create vars and interactions for the regressions
replace mfa=0 if mfa==.
gen lta0  = ln(ta0)
gen lta1 = ln(ta1)


foreach x in mval mrpval malval nf nm np nfrp nmrp nprp nfal nmal npal {
	gen l`x' = ln(`x')
}

quietly {
	rename s1999 g
	gen c     = country==5700
	gen cg    = c*g
	forvalues y=1993/2007 {
		gen d`y' = year==`y'
		foreach x in c g cg {
			gen d`x'`y' = d`y'*`x'
		}
	}

	rename s1990 g90
	gen cg90    = c*g90
	forvalues y=1993/2007 {
		foreach x in cg90 {
			gen d`x'`y' = d`y'*`x'
		}
	}

}

save $interim/m9207_setyr_02, replace

*clean up
erase $interim/junk_firm_counts.dta
erase $interim/junk_firm_counts_post.dta
erase $interim/junk_hs8_new_obs_protection.dta
erase $interim/junk_setyr_spread_01.dta
erase $interim/junk_setyr_spread_02.dta
erase $interim/junk_setyr_ta0_01.dta
erase $interim/junk_setyr_ta0_02.dta
erase $interim/m19922007.dta
erase $interim/m9207_setyr_00.dta
erase $interim/m9207_setyr_01.dta
erase $interim/m9207_hs8.dta



*4.3 use above to create regression dataset for all obs 
use $interim/m9207_setyr_02, clear
des mfa*
*drop if nr==1	
keep country1 year hs8 mval nf nm np lmval lnf lnm lnp g g90 nntr1999 nntr1990 lta0 ///
     lta1 nr mfa* fr*
*20150924 - Keep only obs for which both g and g90 are defined
keep if g~=. & g90~=.

*set fill rates and mfa to zero for obs where there was no match above 
forvalues y=1994(1)2004 {
	replace fr`y'=0 if fr`y'==.
	replace mfa1=0 if mfa1==.
	replace mfa2=0 if mfa2==.
	replace mfa3=0 if mfa3==.
	replace mfa4=0 if mfa4==.
}

*merge in the exchange rate
sort country1 year
merge m:1 country1 year using $interim/robustness_ct_xr, keepus(xr)
tab _merge
drop if _merge==2
drop _merge

*merge in the real effective exchange rate
sort country1 year
merge m:1 country1 year using $interim/robustness_ct_reer, keepus(reer)
tab _merge
drop if _merge==2
drop _merge

gen lxr   = ln(xr)
gen lreer = ln(reer)

*generate regressors
quietly {
	gen c     = country==5700
	gen cg      = c*g

	forvalues y=1993/2007 {
		gen d`y'      = year==`y'
		foreach x in c g cg {
			gen d`x'`y'      = d`y'*`x'
		}
	}
}

*add post interactions
gen post=year>=2001 
foreach z in c g cg {
	gen `z'_post      =`z'*post
}


sum mfa*

*make sure mfa's are 0,1
foreach x in mfa mfa1 mfa2 mfa3 mfa4 {
	replace `x'=0 if `x'==.
	replace `x'=1 if `x'~=0
}
sum mfa*

*out of mfa by year (brambilla et al appendix table 3)
gen end93 = 0
foreach x in 2250 7990 9350 {
	replace end93=1 if country==`x'
}
gen end94 = 0
foreach x in 2450 {
	replace end94=1 if country==`x'
}
gen end97 = 0
foreach x in 2150 {
	replace end97=1 if country==`x'
}
gen end99 = 0
foreach x in 1220 {
	replace end99=1 if country==`x'
}
gen end00 = 0
foreach x in 7790 7850 {
	replace end00=1 if country==`x'
}
gen end03 = 0
foreach x in 2010 5460 {
	replace end03=1 if country==`x'
}
gen end04 = 0
foreach x in 2050 2110 2230 2410 2470 3010 3510 3550 4351 4359 4370 4550 4621 4622 4623 4794 4850 4870 4890 5130 5180 5200 5230 5250 5330 5350 5360 5380 5420 5490 5520 5530 5550 5570 5590 5600 5650 5660 5800 5820 5830 6863 7290 {
	replace end04=1 if country==`x'
}

foreach x in mfa1 mfa2 mfa3 mfa4 {
	gen d`x'   = 0
	gen d`x'fr = 0
}


*create mfa control 
*phases relaxed on jan 1 of following years for china
replace dmfa1 = 1 if mfa1==1 & country1==5700 & year>=2002
replace dmfa2 = 1 if mfa2==1 & country1==5700 & year>=2002
replace dmfa3 = 1 if mfa3==1 & country1==5700 & year>=2002
replace dmfa4 = 1 if mfa4==1 & country1==5700 & year>=2005

*for other countries
replace dmfa1 = 1 if mfa1==1 & year>=1995 & (end97==1 | end99==1 | end00==1 | end03==1 | end04==1)
replace dmfa2 = 1 if mfa2==1 & year>=1998 & (end99==1 | end00==1 | end03==1 | end04==1)
replace dmfa3 = 1 if mfa3==1 & year>=2001 & (end03==1 | end04==1)
replace dmfa4 = 1 if mfa4==1 & year>=2005 & (end04==1)

*create fill-rate mfa vars
replace dmfa1fr = fr2000 if mfa1==1 & country1==5700 & year>=2002
replace dmfa2fr = fr2000 if mfa2==1 & country1==5700 & year>=2002
replace dmfa3fr = fr2000 if mfa3==1 & country1==5700 & year>=2002
replace dmfa4fr = fr2004 if mfa4==1 & country1==5700 & year>=2005

replace dmfa1fr = fr1994 if mfa1==1 & year>=1995 
replace dmfa2fr = fr1997 if mfa2==1 & year>=1998 
replace dmfa3fr = fr2000 if mfa3==1 & year>=2001
replace dmfa4fr = fr2004 if mfa4==1 & year>=2005 

sum dmfa*

*gen interacted FE
egen hc = group(hs8 country1)
egen ht = group(hs8 year)
egen ct = group(country1 year)
egen cp = group(country hs8)

*indicator for constant obs
gen idx=0
foreach x in lmval lnf lnm lnp lta1 {
	replace idx=1 if `x'==.
}

save $interim/true_trade_regs_20150922, replace



*4.4 use above to create regression dataset for rp obs
use $interim/m9207_setyr_02, clear

*set fill rates to zero for obs where there was no match above
forvalues y=1994(1)2004 {
	replace fr`y'=0 if fr`y'==.
}

keep country1 year hs8 mrpval malval nfrp nfal nmrp nmal nprp npal lmrpval lmalval ///
     lnfrp lnfal lnmrp lnmal lnprp lnpal g g90 nntr1999 nntr1990 lta0 lta1 nr mfa* fr*
*20150924 - Keep only obs for which both g and g90 are defined
keep if g~=. & g90~=.
rename lmrpval lmvalrp
rename lmalval lmvalal
rename mrpval mvalrp
rename malval mvalal

*reshape the data for running al and rp in a single reg, otherwise don't
reshape long mval nf nm np lmval lnf lnm lnp, i(country1 year hs8 g lta0 lta1 nr) j(tipe) string
gen rp=tipe=="rp"
	

*merge in the exchange rate
sort country1 year
merge m:1 country1 year using $interim/robustness_ct_xr, keepus(xr)
tab _merge
drop if _merge==2
drop _merge

*merge in the real effective exchange rate
sort country1 year
merge m:1 country1 year using $interim/robustness_ct_reer, keepus(reer)
tab _merge
drop if _merge==2
drop _merge

gen lxr   = ln(xr)
gen lreer = ln(reer)

*gen interacted FE
egen hc = group(hs8 country1)
egen ht = group(hs8 year)
egen ct = group(country1 year)
egen cp = group(country hs8)


gen post=year>=2001 
gen post_rp=post*rp


quietly {

	gen c       = country==5700
	gen c_rp    = c*rp
	gen g_rp    = g*rp
	gen cg      = c*g
	gen cg_rp   = cg*rp

	forvalues y=1993/2007 {
		gen d`y'      = year==`y'
		gen d`y'_rp   = d`y'*rp
		
		foreach x in c g cg {
			gen d`x'`y'      = d`y'*`x'
			gen d`x'`y'_rp   = d`y'*`x'*rp
		}
	}
}

*add post interactions
foreach z in c g cg {
			gen `z'_post      =`z'*post
			gen `z'_post_rp   =`z'*post*rp
}

*make sure mfa's are 0,1
foreach x in mfa mfa1 mfa2 mfa3 mfa4 {
	replace `x'=0 if `x'==.
	replace `x'=1 if `x'~=0
}
sum mfa*

*out of mfa by year (brambilla et al appendix table 3)
gen end93 = 0
foreach x in 2250 7990 9350 {
	replace end93=1 if country==`x'
}
gen end94 = 0
foreach x in 2450 {
	replace end94=1 if country==`x'
}
gen end97 = 0
foreach x in 2150 {
	replace end97=1 if country==`x'
}
gen end99 = 0
foreach x in 1220 {
	replace end99=1 if country==`x'
}
gen end00 = 0
foreach x in 7790 7850 {
	replace end00=1 if country==`x'
}
gen end03 = 0
foreach x in 2010 5460 {
	replace end03=1 if country==`x'
}
gen end04 = 0
foreach x in 2050 2110 2230 2410 2470 3010 3510 3550 4351 4359 4370 4550 4621 4622 4623 4794 4850 4870 4890 5130 5180 5200 5230 5250 5330 5350 5360 5380 5420 5490 5520 5530 5550 5570 5590 5600 5650 5660 5800 5820 5830 6863 7290 {
	replace end04=1 if country==`x'
}

foreach x in mfa1 mfa2 mfa3 mfa4 {
	gen d`x'   = 0
	gen d`x'fr = 0
}



*create coarse mfa control (no fill rates)
*phases relaxed on jan 1 of following years for china
replace dmfa1 = 1 if mfa1==1 & country1==5700 & year>=2002
replace dmfa2 = 1 if mfa2==1 & country1==5700 & year>=2002
replace dmfa3 = 1 if mfa3==1 & country1==5700 & year>=2002
replace dmfa4 = 1 if mfa4==1 & country1==5700 & year>=2005

*for other countries
replace dmfa1 = 1 if mfa1==1 & year>=1995 & (end97==1 | end99==1 | end00==1 | end03==1 | end04==1)
replace dmfa2 = 1 if mfa2==1 & year>=1998 & (end99==1 | end00==1 | end03==1 | end04==1)
replace dmfa3 = 1 if mfa3==1 & year>=2001 & (end03==1 | end04==1)
replace dmfa4 = 1 if mfa4==1 & year>=2005 & (end04==1)

*create fill-rate mfa vars
replace dmfa1fr = fr2000 if mfa1==1 & country1==5700 & year>=2002
replace dmfa2fr = fr2000 if mfa2==1 & country1==5700 & year>=2002
replace dmfa3fr = fr2000 if mfa3==1 & country1==5700 & year>=2002
replace dmfa4fr = fr2004 if mfa4==1 & country1==5700 & year>=2005

replace dmfa1fr = fr1994 if mfa1==1 & year>=1995 
replace dmfa2fr = fr1997 if mfa2==1 & year>=1998 
replace dmfa3fr = fr2000 if mfa3==1 & year>=2001
replace dmfa4fr = fr2004 if mfa4==1 & year>=2005 

sum dmfa*

*create indicator for constant obs
gen idx=0
foreach x in lmval lnf lnm lnp lta1 {
	replace idx=1 if `x'==.
}

save $interim/true_trade_regs_20150922_rp, replace


*4.5 use above to create long-difference regression dataset (all obs)
clear all
use $interim/true_trade_regs_20150922 if year==1995 | year==2001 | year==2007
tsset cp year, delta(6)

foreach x in mval nf nm np {
	gen dl`x'=f.l`x'-l`x'
	gen dhs`x'=(f.`x'-`x')/(.5*(f.`x'+`x'))
}
	
foreach x in dmfa1 dmfa2 dmfa3 dmfa4 {
	gen d`x' = f1.`x' + `x'
	replace d`x' = 1 if d`x'>1 & d`x'~=.
}
foreach x in dmfa1fr dmfa2fr dmfa3fr dmfa4fr {
	gen d`x'     = f1.`x' - `x'
}

sum ddmfa*

*get number of obs to be consistent
drop idx
gen idx=0
foreach x in lta1 {
	replace idx=1 if `x'==.
}

save $interim/long_difference_trade_regs_20150922, replace



*4.6 use above to create long-difference regression dataset (rp obs)
clear all
use $interim/true_trade_regs_20150922_rp if rp==1
keep if year==1995 | year==2001 | year==2007
tsset cp year, delta(6)

foreach x in mval nf nm np {
	gen dl`x'=f.l`x'-l`x'
	gen dhs`x'=(f.`x'-`x')/(.5*(f.`x'+`x'))
}
	
foreach x in dmfa1 dmfa2 dmfa3 dmfa4 {
	gen d`x' = f1.`x' + `x'
	replace d`x' = 1 if d`x'>1 & d`x'~=.
}
foreach x in dmfa1fr dmfa2fr dmfa3fr dmfa4fr {
	gen d`x'     = f1.`x' - `x'
}
sum ddmfa*

*get number of obs to be consistent
drop idx
gen idx=0
foreach x in lta1 {
	replace idx=1 if `x'==.
}

save $interim/long_difference_trade_regs_20150922_rp, replace


