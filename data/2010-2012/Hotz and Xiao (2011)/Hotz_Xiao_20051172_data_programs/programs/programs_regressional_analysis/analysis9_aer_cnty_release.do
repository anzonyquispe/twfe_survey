/* Last Updated July 2007, for AEA revision request 
 
 What's new: 
 1) cluster at the year_st level instead of year_zip level (but don't forget to run a year_zip (and a state only!) clustering version for comparison with previous results) 
 2) dummy out for no scrat and educ requirements. no requirement==1, ow=0. 
 3) Try other MQS variables. Try including one regulating at a time for robustness.
    good within state variation: inspdc visitdc aiddc crimdc; cdhrsddc expddc ongoddc ongohddc; cdhrstdc
 4) minor sample adjustment.    
 5) The differenial impact of MQS in wealthy vs poor markets. Try log_income or poverty
 6) Change wagerate=payroll per employee. For unincorporated firms, alternative definition for n_employ=n_employ+1 or 2.
 7) firm and establishment fixed effects. Q: how to deal with unbalanced panel?  for firm fixed effects, how to deal with state-fixed effects
 8) change edtdc to edddc because edddc has more within state variation.
 9) The differenial impact of MQS on chains, new entrants, and accreditted establishments.

To do: 	1) logit model for exit and accredit
	2) county and zip codes group aggregation
	3) environment index as instruments
	4) prepare all the summary statistics tables for disclosure
	5) try alternative definition for chain: chain=(chainNestab>a certain number)?
	6) use new c1990_clean and c2000_clean?
	7) more stuff coming ....and more
*/ 

quietly { 
clear all 
capture log close 
set mem 2000m 
set matsize 500 
set more off 
 
local pathjuan 		"/rdcprojects/la00296/data/csr/Juan/"
local pathdemog 	"/rdcprojects/la00296/data/outsidemo/cnty/"
local pathpgs3  	"/rdcprojects/la00296/disclosure/July2007/cnty/" 
local pathdisclose 	"/rdcprojects/la00296/disclosure/July2007/cnty/" 
local pathoutside	"/rdcprojects/la00296/data/outside/" 


log using `pathpgs3'analysis9_aer_cnty.log, replace 
} 

*************************************************************************************************** 
* Module 1: get data ready 
 
* For exit regressions: merge 2000 demographics with 1992 Cencus so year 1992 has both 1990 and 2000 demographics. 
* For an establishment exit at t+1 (we code exit=1 at time t), we need to use demographics at t+1 
 
use `pathdemog'c2000_cnty_clean.dta, clear 
gen year_mo=2000
 
*gen badzip=match(zipcode,"*X*") 
*drop if badzip==1 
*drop badzip 
*destring zipcode, gen(num_zip5) 
*drop if num_zip5==. 
*drop zipcode 

local demog "pct_black pct_hisp hh_size m_income pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural under5" 
 
* keep num_zip5 year_mo `demog' 
  keep county   year_mo `demog'
 
foreach var of local demog { 
	rename `var' `var'00 
} 
 
sort county year_mo
 
save `pathdemog'c2000_cnty_limited.dta, replace

* get county level demographics ready
* ==================================
use `pathdemog'c2000_cnty_clean.dta, clear
gen yeardemocen=2000
* gen badzip=match(zipcode,"*X*")
* drop if badzip==1
* drop badzip
* destring zipcode, gen(zip)
* drop if zip==.
* drop zipcode
* rename zip zipcode
append using `pathdemog'c1990_cnty_clean.dta
replace yeardemocen=1990 if yeardemocen==.
* describe
* rename zipcode num_zip5
* by num_zip5  yeardemocen, sort: gen bertrand=_n
  by county    yeardemocen, sort: gen bertrand=_n
keep if bertrand==1
* sort num_zip5 yeardemocen
  sort county   yeardemocen
saveold `pathdemog'demog_appended, replace


use `pathjuan'fully_merged.dta, clear

*************************************
* drop zip code demographics
drop state_no pop hh_size m_income pct_rural pct_black pct_hisp under5 n_infant n_toddler n_presch age_1_2 age_3_4 n_schage pct_freign mobility pct_fh_c pct_over60 long_comm pct_whome pct_nursery pct_kdgarden college pct_unemploy pct_nolabor f_parttime pct_f_nwork pct_pvty pct_over55 bertrand

* Put fully_merged.dta's county variable ready for match
rename county countyname
gen county=stgeo+ctygeo
destring county, replace
sort county yeardemocen

* Merge in County level demographics

merge county yeardemocen using `pathdemog'demog_appended.dta
rename _merge merge_census_naeyc_demogcnty
tab merge_census_naeyc_demogcnty


*************************************

* Keep only records from the Census data file 
keep if census_concat==1 
drop if st=="AE"/*AE: not a state */ 
 
gen year_mo=2000 if year==1992 
 
* sort num_zip5 year_mo
  sort county   year_mo
 
* merge num_zip5 year_mo using `pathdemog'c2000_limited.dta 
  merge county   year_mo using `pathdemog'c2000_cnty_limited.dta 

drop if _merge==2 
drop _merge 
 
 
* Keep variables needed for analysis 
 
# delimit ; 
keep stgeo msa ein cfn lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 
plce st ctygeo pst pzip einssl year month_op n_estab census_rec 
naeyc_id city county init_accredit 
valid_until extend_until close_date accredit_status n_staff n_children n_groups licensed n_sites 
acc_status_1987_1d acc_status_1987_3m acc_status_1987_6m 
acc_status_1992_1d acc_status_1992_3m acc_status_1992_6m 
acc_status_1997_1d acc_status_1997_3m acc_status_1997_6m 
zip merge_census_naeyc pop age_1_2 age_3_4 m_income pct_rural pct_black pct_hisp under5 n_infant 
n_schage hh_size pct_fh_c pct_over55 pct_freign mobility long_comm pct_whome college pct_unemploy 
pct_nolabor f_parttime pct_f_nwork pct_pvty n_toddler n_presch pct_over60 merge_census_naeyc_demog 
preddc edddc cdhrsddc expddc healdc crimdc agetdc pretdc edtdc cdhrstdc exptdc ongoddc ongohddc
ageadc preadc edadc cdhrsadc expadc aiddc curricdc equipdc 
fooddc inftdc outftdc size0dc size1dc size2dc size3dc size4dc size5dc rat0dc rat1dc rat2dc rat3dc 
rat4dc rat5dc insurdc inspdc visitdc
pct_black00 pct_hisp00 hh_size00 m_income00 pct_pvty00 college00 pct_fh_c00 pct_f_nwork00 
pct_unemploy00 pct_whome00 long_comm00 pct_rural00 under500 num_zip5
county;
# delimit cr 
 
 
* Describe data 
des 

 * step 1: fill in missing values for accreditation status 
local acc "acc_status_1987_1d acc_status_1987_3m  acc_status_1987_6m acc_status_1992_1d acc_status_1992_3m  acc_status_1992_6m acc_status_1997_1d acc_status_1997_3m  acc_status_1997_6m " 
 
foreach var of local acc { 
	replace `var'=0 if `var'==. 
} 
 
* generate accredit variable. Criterion: accredited for 3 months in a given year
gen accredit=0 
replace accredit=1 if year==1987 & acc_status_1987_3m==1 
replace accredit=1 if year==1992 & acc_status_1992_3m==1 
replace accredit=1 if year==1997 & acc_status_1997_3m==1 
 
* step 2: clean Census data

* perform string to numeric transformation 

destring cfn, gen(num_cfn)
destring ein, gen(num_ein) 
destring stgeo, gen(num_st) 
gen year_st=num_st+0.01*(year-1986) 
*gen year_zip=num_zip5+0.01*(year-1986) 
/* year_st and year_zip is created for clustering */ 
 
rename n_staff n_staff_s 
gen n_staff=real(n_staff_s) 
rename n_children n_children_s 
gen n_children=real(n_children_s) 
rename n_groups n_groups_s 
gen n_groups=real(n_groups_s) 
 
drop n_staff_s n_children_s n_groups_s 
 
# delimit ; 
 
* generate chain indicator;
sort num_ein year; 
by num_ein year, sort: gen auxchain = _n; 
egen chainNestab= max(auxchain), by (num_ein year); 
gen chain=0; 
replace chain=1 if chainNestab>1; 

* for firm fixed effects;
sort num_ein; 
by num_ein, sort: gen aux_ein = _n; 
egen n_ein= max(aux_ein), by (num_ein);
gen panel_ein=(n_ein>1); 

gen exit_aux_ein=0;
by num_ein, sort: replace exit_aux_ein= _n if year==1987 | year==1992;
egen exit_n_ein= max(exit_aux_ein), by (num_ein); 
gen exit_panel_ein=(exit_n_ein>1); 

***********************************************
**** 2nd Referee's question: Chain Accredit ***
***********************************************
*Juan: this needs disclosure ;

tab chain year; 
su chainNestab if chain==0; 
su chainNestab if chain==1, detail;
sort year;
by year: su chainNestab if chain==0;
by year: su chainNestab if chain==1, detail;
tab chainNestab year if chainNestab>=200;

*tab chainNestab chain; 
*tab chainNestab year; 
*tab chainNestab;

* If a chain is accredited at a given year, are all its affiliated establishments accredited? ;
gen acc_chain=accredit*chain;
egen acc_chainNestab= sum(acc_chain), by (num_ein year); 
gen pct_acc_chain=acc_chainNestab/chainNestab if chain==1;
sort year;
by year: su chainNestab acc_chainNestab pct_acc_chain if chain==1;

************************************************;

***********************************************
**** 2nd Referee's question: Missing Expense***
***********************************************
*Juan: this needs disclosure ;
 
gen expenfreq=0 if expense!=. ; 
replace expenfreq=1 if expense>0 & expense!=. ; 
tab expenfreq ; 
tab expenfreq year ; 
 
gen expense2= expense ; 
replace expense2=. if expense==0 ; 
 
* converting to real terms (base 97) ; 
 
scalar cpi97 = 160.5 ; 
scalar cpi92 = 140.3 ; 
scalar cpi87 = 113.6 ; 
 
gen revenueR=. ; 
replace revenueR= revenue*cpi97/cpi87 if year==1987 ; 
replace revenueR= revenue*cpi97/cpi92 if year==1992 ; 
replace revenueR= revenue*cpi97/cpi97 if year==1997 ; 
gen payrollR=. ; 
replace payrollR= payroll*cpi97/cpi87 if year==1987 ; 
replace payrollR= payroll*cpi97/cpi92 if year==1992 ; 
replace payrollR= payroll*cpi97/cpi97 if year==1997 ; 
gen expenseR=. ; 
replace expenseR= expense*cpi97/cpi87 if year==1987 ; 
replace expenseR= expense*cpi97/cpi92 if year==1992 ; 
replace expenseR= expense*cpi97/cpi97 if year==1997 ; 
gen expense2R=. ; 
replace expense2R= expense2*cpi97/cpi87 if year==1987 ; 
replace expense2R= expense2*cpi97/cpi92 if year==1992 ; 
replace expense2R= expense2*cpi97/cpi97 if year==1997 ; 
 
# delimit cr 

***********************************************
**** 2nd Referee's question: CFN continuity ***
***********************************************
*Juan: this needs disclosure 

xtdes, i(num_cfn) t(year) 

* for establishment fixed effects
sort num_cfn year
by num_cfn, sort: gen aux_cfn= _n
egen n_cfn= max(aux_cfn), by (num_cfn)
gen panel_cfn=(n_cfn>1) 
* note, because of missing establishment attributes and demographics, later on in regressions we have still have a single establishment even if panel_cfn>1 

gen exit_aux_cfn=0
by num_cfn, sort: replace exit_aux_cfn= _n if year==1987 | year==1992
egen exit_n_cfn= max(exit_aux_cfn), by (num_cfn) 
gen exit_panel_cfn=(exit_n_cfn==2) 

/*drop observations with abnormal patterns, eg. the same cfn shows up twice a year. Only a few obs */
drop if n_cfn>3 | exit_n_cfn>2 

su n_ein panel_ein exit_n_ein exit_panel_ein n_cfn panel_cfn exit_n_cfn exit_panel_cfn
by year, sort: su n_ein panel_ein exit_n_ein exit_panel_ein n_cfn panel_cfn exit_n_cfn exit_panel_cfn
 
/* generate numeric firm attributes for establishment-level regressional analysis */ 
gen inc=(lfobase=="0") 
gen individual=(lfobase=="1") 
gen partnership=(lfobase=="2") 
gen if_tax_xpt=(tax_xmpt=="1") 
gen partyear=(month_op<6)  /* can also use 9 months as the cutoff */
 
gen prolR_per_w=payrollR/n_employ  /* payroll per employee/worker */
gen expR_per_w=expenseR/n_employ  /*Real expense per employee */ 
gen exp2R_per_w=expense2R/n_employ  /*Real expense2 per employee */ 
gen revR_per_w=revenueR/n_employ  /*revenue per employee  */ 
gen pft2R=revenueR-payrollR 
gen pftR_per_w2=pft2R/n_employ  /* a 2nd definition for profit per worker because expense data is no good */ 

/* consider that possibility that owners work on site. note the oweners should be on the payroll */
gen n_employ2=n_employ*(partnership==0 & individual==0)+(n_employ+2)*(partnership==1)+(n_employ+1)*(individual==1)
 
/* clean demographics */ 

local demog "pct_black pct_hisp hh_size m_income pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural under5" 
foreach var of local demog { 
	replace `var'00=`var' if year==1987 
}

/*gen ln_m_inc00=log(m_income00)
replace ln_m_inc00=log(m_income00+0.01) if m_income00==0
gen ln_under500=log(under500)
replace ln_under500=log(under500+1) if under500==0
gen ln_m_inc=log(m_income)
replace ln_m_inc=log(m_income+0.01) if m_income==0
gen ln_under5=log(under5)
replace ln_under5=log(under5+1) if under5==0 */

* 07/17/2007 revision: rescale m_income and under5 by 1/1000. 
gen ln_m_inc00=m_income00/1000
gen ln_under500=under500/1000
gen ln_m_inc=m_income/1000
gen ln_under5=under5/1000

gen pct_child=under5/pop 

gen year1992=(year==1992) 
gen year1997=(year==1997)


* step 3: create MQS index

/*****

* a manual way to fill in the missing regulation data: using 1988/1991 data 
* Used this in analysis9; give it up for analysis9_aer 
* will do this for robustness check. 
 
replace edddc=14 if year==1987 & st=="DE" 
replace edddc=14 if year==1987 & st=="HI" 
replace edddc=16 if year==1987 & st=="LA" 
replace edddc=12 if year==1987 & (st=="MA" | pst=="MA") 
replace edddc=14 if year==1987 & st=="MT" 
replace edddc=16 if (year==1987 | year==1992) & st=="RI" 
 
replace edtdc=14 if year==1987 & st=="DE" 
replace edtdc=12 if year==1987 & st=="HI" 
replace edtdc=0 if year==1987 & st=="LA" 
replace edtdc=12 if year==1987 & (st=="MA" | pst=="MA") 
replace edtdc=0 if year==1987 & st=="MT" 
replace edtdc=12 if (year==1987 | year==1992) & st=="RI" 
 
replace edadc=0 if year==1987 & st=="DE" 
replace edadc=0 if year==1987 & st=="HI" 
replace edadc=0 if year==1987 & st=="LA" 
replace edadc=12 if year==1987 & (st=="MA" | pst=="MA") 
replace edadc=0 if year==1987 & st=="MT" 
replace edadc=12 if (year==1987 | year==1992) & st=="RI"    

* DE: rat regulation missing in 1987. Use 1988 data *
replace rat0dc=4 if year==1987 & st=="DE" 
replace rat1dc=7 if year==1987 & st=="DE" 
replace rat2dc=10 if year==1987 & st=="DE" 
replace rat3dc=12 if year==1987 & st=="DE" 
replace rat4dc=15 if year==1987 & st=="DE" 
replace rat5dc=25 if year==1987 & st=="DE"   
 
* HI:  rat0 or rat1 regulation missing in 1987. Use 1991 data
replace rat0dc=4 if year==1987 & st=="HI" 
replace rat1dc=6 if year==1987 & st=="HI" 
 
* LA: rat regulation missing in 1987. Use 1991 data
replace rat0dc=6 if year==1987 & st=="LA" 
replace rat1dc=8 if year==1987 & st=="LA" 
replace rat2dc=12 if year==1987 & st=="LA" 
replace rat3dc=14 if year==1987 & st=="LA" 
replace rat4dc=16 if year==1987 & st=="LA" 
replace rat5dc=20 if year==1987 & st=="LA" 
 
* MT: rat regulation missing in 1987. Use 1991 data
replace rat0dc=4 if year==1987 & st=="MT" 
replace rat1dc=4 if year==1987 & st=="MT" 
replace rat2dc=8 if year==1987 & st=="MT" 
replace rat3dc=8 if year==1987 & st=="MT" 
replace rat4dc=10 if year==1987 & st=="MT" 
replace rat5dc=10 if year==1987 & st=="MT" 
  
* Note the following is added by JP see MX's email from 3/25/2005 
* MS : rat is 99 in 1987. 
replace rat0dc=4 if year==1987 & st=="MS" 
replace rat1dc=5 if year==1987 & st=="MS" 
replace rat2dc=9 if year==1987 & st=="MS" 
replace rat3dc=12 if year==1987 & st=="MS" 
replace rat4dc=14 if year==1987 & st=="MS" 
replace rat5dc=20 if year==1987 & st=="MS"  

************/

* WA in 1987: Use Anna Aizer's data (chcare_aizer.xls) to fill in.
replace edddc=0 if year==1987 & st=="WA" 
replace edtdc=0 if year==1987 & st=="WA"   
replace edadc=0 if year==1987 & st=="WA" 
replace rat0dc=4 if year==1987 & st=="WA" 
replace rat1dc=7 if year==1987 & st=="WA" 
replace rat2dc=10 if year==1987 & st=="WA" 
replace rat3dc=10 if year==1987 & st=="WA" 
replace rat4dc=10 if year==1987 & st=="WA" 
replace rat5dc=10 if year==1987 & st=="WA" 

* staff-child ratio MQS, treating missing values and 99 as scrat=0.
foreach i of numlist 0(1)5 {
replace rat`i'dc=. if rat`i'dc==99
gen scrat`i'dc=0 if rat`i'dc==.
replace scrat`i'dc=1/rat`i'dc if rat`i'dc!=.
}
gen scrat=(scrat0dc+scrat1dc+scrat2dc+scrat3dc+scrat4dc+scrat5dc)/6 

gen no_scrat=(scrat==0)
gen no_scrat0dc=(scrat0dc==0)

/* generate education index. treating miss values and 0 as educ=0.
Note sometimes one or two of the three ed*dc are zeros */ 
replace edddc=0 if edddc==.
replace edtdc=0 if edtdc==.
replace edadc=0 if edadc==.

*gen educ=(edddc+edtdc+edadc)/3 
gen educ=(edddc+edtdc)/2  /* edadc are often not regulated */ 
  
/* generate a dummy variable for no staff-education requirements */ 
gen no_educ=(educ==0)  
gen no_edddc=(edddc==0) /* generate a dummy variable for no director education requirements */ 

*try implicit education requirement later. 8 years is the min of edadc.
*replace edddc=8 if edddc==0
*replace edtdc=8 if edtdc==0
*replace edadc=8 if edadc==0 
*replace educ=(edddc+edtdc+edadc)/3 
 
* add in MQS variables with good within state variation
replace insurdc=0 if insurdc==. /*There is NOT enough within state variation in insurdc */
replace inspdc=0 if inspdc==.
replace visitdc=0 if visitdc==.
replace crimdc=0 if crimdc==.
replace aiddc=0 if aiddc==.

replace cdhrsddc=0 if cdhrsddc==.
replace cdhrsddc=cdhrsddc/100 /*rescale cdhrsddc by 1/100 */
replace expddc=0 if expddc==.
replace ongoddc=0 if ongoddc==.
replace ongohddc=0 if ongohddc==.
replace cdhrstdc=0 if cdhrstdc==.
replace cdhrstdc=cdhrstdc/100 /*rescale cdhrstdc by 1/100 */

* Interactions of MQS with ln_m_inc 
gen scrat_incm=scrat*ln_m_inc 
gen no_scrat_incm=no_scrat*ln_m_inc
gen educ_incm=educ*ln_m_inc 
gen no_educ_incm=no_educ*ln_m_inc 
gen scrat0dc_incm=scrat0dc*ln_m_inc 
gen no_scrat0dc_incm=no_scrat0dc*ln_m_inc 
gen edddc_incm=edddc*ln_m_inc 
gen no_edddc_incm=no_edddc*ln_m_inc 

gen scrat_incm00=scrat*ln_m_inc00 
gen no_scrat_incm00=no_scrat*ln_m_inc00
gen educ_incm00=educ*ln_m_inc00 
gen no_educ_incm00=no_educ*ln_m_inc00 
gen scrat0dc_incm00=scrat0dc*ln_m_inc00 
gen no_scrat0dc_incm00=no_scrat0dc*ln_m_inc00 
gen edddc_incm00=edddc*ln_m_inc00
gen no_edddc_incm00=no_edddc*ln_m_inc00 

* Interactions of MQS with pct_pvty
gen scrat_pvty=scrat*pct_pvty 
gen no_scrat_pvty=no_scrat*pct_pvty
gen educ_pvty=educ*pct_pvty 
gen no_educ_pvty=no_educ*pct_pvty 
gen scrat0dc_pvty=scrat0dc*pct_pvty 
gen no_scrat0dc_pvty=no_scrat0dc*pct_pvty 
gen edddc_pvty=edddc*pct_pvty
gen no_edddc_pvty=no_edddc*pct_pvty 

gen scrat_pvty00=scrat*pct_pvty00
gen no_scrat_pvty00=no_scrat*pct_pvty00
gen educ_pvty00=educ*pct_pvty00 
gen no_educ_pvty00=no_educ*pct_pvty00 
gen scrat0dc_pvty00=scrat0dc*pct_pvty00 
gen no_scrat0dc_pvty00=no_scrat0dc*pct_pvty00
gen edddc_pvty00=edddc*pct_pvty00
gen no_edddc_pvty00=no_edddc*pct_pvty00 


* step 4: define variables: entry, exit; aggregate at the COUNTY level
* In analysis9, employee turnover is not the right measure for turnover. Disregard all results on employment turnover

sort cfn year 
by cfn: gen yrorder_a=_n 
gen entry=. 
replace entry=1 if year==1992 & yrorder_a==1 
replace entry=1 if year==1997 & yrorder_a==1 
 
gsort cfn -year 
by cfn: gen yrorder_d=_n 
gen exit=. 
replace exit=1 if year==1987 & yrorder_d==1 
replace exit=1 if year==1992 & yrorder_d==1 
 
* aggregate entry and exit to COUNTY level 
sort county year 
by county year: egen n_entry=sum(entry) 
by county year: egen n_exit=sum(exit) 
by county year: egen n_estb_cty=count(num_cfn) 
by county year: egen n_accredit=sum(accredit) 
by county year: egen employ_cty=sum(n_employ) 
by county year: egen employ2_cty=sum(n_employ2)
by county year: gen ctyorder=_n 
 
replace entry=0 if entry==. & year!=1987 
replace exit=0  if exit ==. & year!=1997  
  
 
**************************************************************** 
* Added by JP on 4/13/2005 
* Merges number of accreditted center in each zip-year 
* computed from original NAEYC data 
* Modififed by JP on 7/16/2007 for county-zip year
**************************************************************** 

preserve
keep county num_zip5
sort num_zip5 county
by num_zip5, sort: gen justone=_n
keep if justone==1
sort num_zip5 county
saveold `pathjuan'cty_zip_bridge.dta, replace
restore

preserve
use `pathoutside'naeyc_clean_orig.dta, clear
rename county cnty_name
keep acc_status_1987_3m acc_status_1992_3m acc_status_1997_3m zip naeyc_id
rename zip num_zip5 
sort num_zip5 naeyc_id
merge num_zip5 using `pathjuan'cty_zip_bridge.dta
tab _merge
keep if _merge==3 | _merge==1
rename acc_status_1987_3m acc_status1987 
rename acc_status_1992_3m acc_status1992 
rename acc_status_1997_3m acc_status1997
reshape long acc_status, i(naeyc_id) j(year) 
drop naeyc_id 
sort county year 
by county year: egen n_accredit_orig=sum(acc_status) 
keep county year n_accredit_orig
collapse n_accredit_orig , by (year county)
sort county year
saveold `pathjuan'accredit_orig_cnty.dta, replace
restore
 
sort county year 
merge county year using `pathjuan'accredit_orig_cnty.dta
tab _merge 
rename _merge april_merge 
replace n_accredit_orig = 0 if n_accredit_orig == . 
 
preserve
collapse n_accredit_orig n_accredit, by (year county) 
su n_accredit_orig n_accredit , detail 
restore
 
**************************************************************** 
 
 
tab exit if year==1987 
tab entry if year==1992 
tab exit if year==1992 
tab entry exit if year==1992, row col cell 
tab entry if year==1997 
 
su entry exit accredit prolR_per_w revR_per_w pftR_per_w2 
sort year 
 
*********** 
* Table 3 * 
*********** 
 
by year: su entry exit accredit prolR_per_w revR_per_w pftR_per_w2 
  
************************************************ 
*Disclosure Code for Table 3 
************************************************ 
*** Deleted by AR *** 
***********************************************; 
  
/*replace prolR_per_w=log(prolR_per_w) 
replace revR_per_w=log(revR_per_w) 
replace pftR_per_w2=log(pftR_per_w2) */ 
 
# delimit ; 
/* Summary Statistics  
tab st; 
tab lfobase; 
tab tax_xmpt; 
tab non_pft; /* there are 3 categories. Not clear about definition */
tab month_op; 
tab licensed;  /*too many missing values. not usable */ 
 
su inc individual partnership if_tax_xpt partyear chain n_employ n_employ2 revenueR payrollR 
 
expenseR expense2R expR_per_w exp2R_per_w revR_per_w prolR_per_w pftR_per_w2 
n_estab n_staff n_children n_groups n_sites 
acc_status_1987_1d acc_status_1987_3m acc_status_1987_6m 
acc_status_1992_1d acc_status_1992_3m acc_status_1992_6m 
acc_status_1997_1d acc_status_1997_3m acc_status_1997_6m 
 
pop under5 n_infant age_1_2 age_3_4 n_schage n_toddler n_presch 
pct_over60 pct_over55 pct_freign mobility pct_nolabor f_parttime 
pct_black pct_hisp hh_size m_income ln_m_inc pct_pvty college pct_fh_c pct_unemploy pct_whome long_comm pct_rural 
 
preddc edddc cdhrsddc expddc healdc crimdc agetdc pretdc edtdc cdhrstdc exptdc ageadc preadc edadc cdhrsadc expadc aiddc curricdc equipdc fooddc inftdc outftdc size0dc size1dc size2dc size3dc size4dc size5dc rat0dc rat1dc rat2dc rat3dc rat4dc rat5dc insurdc inspdc; */ 
  
/* year by year descriptive statistics */ 
*Juan, the folowing tabulation needs disclosure;

sort year; 
by year: tab lfobase; 
by year: tab tax_xmpt; 
by year: tab non_pft; 
by year: tab month_op; 
by year: tab licensed; 
 
*********** 
* Table 2 * 
***********; 
 
by year: su inc individual partnership if_tax_xpt partyear chain n_employ n_employ2 revenueR payrollR 
 
expenseR expense2R expR_per_w exp2R_per_w revR_per_w prolR_per_w pftR_per_w2 
n_estab n_staff n_children n_groups n_sites 
acc_status_1987_1d acc_status_1987_3m acc_status_1987_6m 
acc_status_1992_1d acc_status_1992_3m acc_status_1992_6m 
acc_status_1997_1d acc_status_1997_3m acc_status_1997_6m 
 
pop under5 n_infant age_1_2 age_3_4 n_schage n_toddler n_presch 
pct_over60 pct_over55 pct_freign mobility pct_nolabor f_parttime 
pct_black pct_hisp hh_size m_income ln_m_inc pct_pvty college pct_fh_c pct_unemploy pct_whome long_comm pct_rural 
pct_black00 pct_hisp00 hh_size00 ln_m_inc00 pct_pvty00 college00 ln_under500 pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00  
 
preddc edddc cdhrsddc expddc healdc crimdc agetdc pretdc edtdc cdhrstdc exptdc ageadc preadc edadc cdhrsadc expadc aiddc curricdc equipdc fooddc inftdc outftdc size0dc size1dc size2dc size3dc size4dc size5dc rat0dc rat1dc rat2dc rat3dc rat4dc rat5dc insurdc inspdc
scrat0dc scrat1dc scrat2dc scrat3dc scrat4dc scrat5dc scrat no_scrat no_scrat0dc educ no_educ no_edddc; 
 
 
************************************************; 
*Disclosure Code for Table 2; 
************************************************; 
*** Deleted by AR ***
***********************************************; 
 
 
 
*******************************; 
keep if pct_black!=. & pct_hisp!=. & hh_size!=. & ln_m_inc!=. & pct_pvty!=. & college!=. & ln_under5!=. & pct_fh_c!=. & pct_f_nwork!=. & pct_unemploy!=. & pct_whome!=. & long_comm!=. & pct_rural!=. ; 

* Juan, this following summary table needs disclosure;
 
by year: su inc individual partnership if_tax_xpt partyear chain n_employ n_employ2 revenueR payrollR 
 
expenseR expense2R expR_per_w exp2R_per_w revR_per_w prolR_per_w pftR_per_w2 
n_estab n_staff n_children n_groups n_sites 
acc_status_1987_1d acc_status_1987_3m acc_status_1987_6m 
acc_status_1992_1d acc_status_1992_3m acc_status_1992_6m 
acc_status_1997_1d acc_status_1997_3m acc_status_1997_6m 
 
pop under5 n_infant age_1_2 age_3_4 n_schage n_toddler n_presch 
pct_over60 pct_over55 pct_freign mobility pct_nolabor f_parttime 
pct_black pct_hisp hh_size ln_m_inc pct_pvty college pct_fh_c pct_unemploy pct_whome long_comm pct_rural 
pct_black00 pct_hisp00 hh_size00 ln_m_inc00 pct_pvty00 college00 ln_under500 pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00  
 
preddc edddc cdhrsddc expddc healdc crimdc agetdc pretdc edtdc cdhrstdc exptdc ageadc preadc edadc cdhrsadc expadc aiddc curricdc equipdc fooddc inftdc outftdc size0dc size1dc size2dc size3dc size4dc size5dc rat0dc rat1dc rat2dc rat3dc rat4dc rat5dc insurdc inspdc
scrat0dc scrat1dc scrat2dc scrat3dc scrat4dc scrat5dc scrat no_scrat no_scrat0dc educ no_educ no_edddc; 
 
# delimit cr 
 
************ 
* Table 50 
************ 
 
tab lfobase tax_xmpt, cell row col 
 
*********************************************** 
*Disclosure Code for Table 50 
*********************************************** 
*** Deleted by AR ***
*********************************************** 
 
tab lfobase tax_xmpt if year==1987, cell row col 
tab lfobase tax_xmpt if year==1992, cell row col 
tab lfobase tax_xmpt if year==1997, cell row col 
 
*Disclosure Code for Table (50 by year tabs) 
******************************************** 
foreach y of numlist 1987 1992 1997	{ 
foreach num of numlist 0 1 2 3 4 9 	{ 
	su payroll if tax_xmpt=="0" & lfobase=="`num'" & year==`y' 
	preserve 
	keep if tax_xmpt=="0" & lfobase=="`num'" & year==`y' 
	scalar sumlfo`num'_xmpt0=r(sum) 
	gsort -payroll 
	if sumlfo`num'_xmpt0 != 0 scalar T50cr`num'_0_`y'= (payroll[1]+payroll[2])/sumlfo`num'_xmpt0 
	restore 
 
	su payroll if tax_xmpt=="1" & lfobase=="`num'" & year==`y' 
	preserve 
	keep if tax_xmpt=="1" & lfobase=="`num'" & year==`y' 
	scalar sumlfo`num'_xmpt1=r(sum) 
	gsort -payroll 
	if sumlfo`num'_xmpt1 != 0 scalar T50cr`num'_1_`y'= (payroll[1]+payroll[2])/sumlfo`num'_xmpt1 
	restore 
					} 
					} 
 
**************************************************************************************************** 
* Module 2: establishment level analysis 
 
quietly { 
gen gsize_reg=1/size0dc 
replace gsize_reg=0 if size0dc==. 
gen cdhrs100=cdhrstdc/100 
 
* Small Loop to generate state dummies !!! Because xi does not work !!! 
 
forvalues s=1/56 { 
gen d_state`s'=0 
replace d_state`s'=1 if num_st==`s' 
} 
 
/* Get fips variable ready  for merge with LEC data 
 
gen st_code_string=string(num_st) 
gen concatfips=st_code_string + ctygeo 
gen fips=real(concatfips) 
 
* Merge in LEC data 
 
sort fips year 
merge fips year using /rdcprojects/la00296/data/outside/lec/lecformerge.dta 
tab _merge 
 
* Interactions of education requirement with LEC (Local Economic Conditions) 
 
gen edddc_college        = edddc*college 
gen edddc_sh_e_services  = edddc*sh_e_services 
gen edddc_rel_wage       = edddc*w_to_e_servicesR/w_to_e_manufR 
 
gen educ_college        = educ*college 
gen educ_sh_e_services  = educ*sh_e_services 
gen educ_rel_wage       = educ*w_to_e_servicesR/w_to_e_manufR 

gen rel_wage=w_to_e_servicesR/w_to_e_manufR  */

* drop "sh_e_services rel_wage" from the regressor list. These two variables are too endogenenous to be included. 

* k: the number of specification

local k=36
local kX6=216

}
 





****************************************************************************************** 
 
save `pathdisclose'auxiliardata_cnty.dta, replace 
 
 
************************************************************************************************************************************************************************************** 
 
 
* Module 3: COUNTY level analysis
 
quietly {
 
keep if ctyorder==1 /* keep unique county-year combos */ 
 
sort county year 
by county: gen cty_yr_order=_n 

* gen entry_cty=n_entry/n_estb_cty 
 
* the following way to define entry rate will lose zipcodes who do not show up in the _n-1 year; but this definition is based on previous literature 
* need to check how many observations we lose here. 

  gen entry_cty=n_entry/n_estb_cty[_n-1] if cty_yr_order!=1 
* gen entry_cty=n_entry/n_estb_cty       if cty_yr_order!=1 

gen exit_cty=n_exit/n_estb_cty 
 
gen accre_cty=n_accredit/n_estb_cty 
gen accre_cty_orig=n_accredit_orig/n_estb_cty 
 
gen emp_dens=employ_cty/under5 
replace emp_dens=employ_cty/(under5+1) if under5==0 
gen est_dens=n_estb_cty/under5 
replace est_dens=n_estb_cty/(under5+1) if under5==0 

} 
 
*********** 
* Table 4 * 
*********** 
 
sort year 
by year: su n_estb_cty est_dens employ_cty employ2_cty n_entry entry_cty n_exit exit_cty n_accredit accre_cty n_accredit_orig  accre_cty_orig emp_dens
 
* Table 4 Addendum 
* ---------------- 
by year: su n_accredit_orig  accre_cty_orig if accre_cty_orig<=1 
 

*********** 
* Table 5 * 
*********** 

by year, sort: su pop pct_black pct_hisp hh_size m_income ln_m_inc pct_pvty college under5 ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural under500 ln_under500 pct_black00 pct_hisp00 hh_size00 m_income00 ln_m_inc00 pct_pvty00 college00  pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00 


* Again no need to do disclosure analysis because this is at COUNTY level 
 
****************************************************************************************** 
local exit_idv "pct_black00 pct_hisp00 hh_size00 ln_m_inc00 college00 ln_under500 pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00"  
local idv "pct_black pct_hisp hh_size ln_m_inc college ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 
local idv_nologu5 "pct_black pct_hisp hh_size ln_m_inc college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 

local exit_idv_pvty "pct_black00 pct_hisp00 hh_size00 pct_pvty00 college00 ln_under500 pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00"  
local idv_pvty "pct_black pct_hisp hh_size pct_pvty college ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 
local idv_nologu5_pvty "pct_black pct_hisp hh_size pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 

local exit_vars_dc0 "scrat no_scrat educ no_educ scrat_incm00 no_scrat_incm00 educ_incm00 no_educ_incm00 scrat_pvty00 no_scrat_pvty00 educ_pvty00 no_educ_pvty00 scrat0dc no_scrat0dc edddc no_edddc scrat0dc_incm00 no_scrat0dc_incm00 edddc_incm00 no_edddc_incm00 scrat0dc_pvty00 no_scrat0dc_pvty00 edddc_pvty00 no_edddc_pvty00 inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `exit_idv' pct_pvty00"

local exit_vars_dc1 "scrat `exit_idv'"
local exit_vars_dc2 "scrat no_scrat `exit_idv'"
local exit_vars_dc3 "educ `exit_idv'"
local exit_vars_dc4 "educ no_educ `exit_idv'"
local exit_vars_dc5 "scrat educ `exit_idv'"
local exit_vars_dc6 "scrat no_scrat educ no_educ `exit_idv'"
local exit_vars_dc7 "scrat scrat_incm00 educ educ_incm00 `exit_idv'"
local exit_vars_dc8 "scrat scrat_incm00 no_scrat no_scrat_incm00 educ educ_incm00 no_educ no_educ_incm00 `exit_idv'"
local exit_vars_dc9 "scrat scrat_pvty00 educ educ_pvty00 `exit_idv_pvty'"
local exit_vars_dc10 "scrat scrat_pvty00 no_scrat no_scrat_pvty00 educ educ_pvty00 no_educ no_educ_pvty00 `exit_idv_pvty'"

local exit_vars_dc11 "scrat0dc `exit_idv'"
local exit_vars_dc12 "scrat0dc no_scrat0dc `exit_idv'"
local exit_vars_dc13 "edddc `exit_idv'"
local exit_vars_dc14 "edddc no_edddc `exit_idv'"
local exit_vars_dc15 "scrat0dc edddc `exit_idv'"
local exit_vars_dc16 "scrat0dc no_scrat0dc edddc no_edddc `exit_idv'"
local exit_vars_dc17 "scrat0dc scrat0dc_incm00 edddc edddc_incm00 `exit_idv'"
local exit_vars_dc18 "scrat0dc scrat0dc_incm00 no_scrat0dc no_scrat0dc_incm00 edddc edddc_incm00 no_edddc no_edddc_incm00 `exit_idv'"
local exit_vars_dc19 "scrat0dc scrat0dc_pvty00 edddc edddc_pvty00 accredit `exit_idv_pvty'"
local exit_vars_dc20 "scrat0dc scrat0dc_pvty00 no_scrat0dc no_scrat0dc_pvty00 edddc edddc_pvty00 no_edddc no_edddc_pvty00 `exit_idv_pvty'"

local exit_vars_dc21 "inspdc `exit_idv'"
local exit_vars_dc22 "visitdc `exit_idv'"
local exit_vars_dc23 "aiddc `exit_idv'"
local exit_vars_dc24 "crimdc `exit_idv'"
local exit_vars_dc25 "cdhrsddc `exit_idv'"
local exit_vars_dc26 "expddc `exit_idv'"
local exit_vars_dc27 "ongoddc `exit_idv'"
local exit_vars_dc28 "ongohddc `exit_idv'"
local exit_vars_dc29 "scrat educ inspdc `exit_idv'"
local exit_vars_dc30 "scrat no_scrat educ no_educ inspdc `exit_idv'"
local exit_vars_dc31 "scrat0dc edddc inspdc `exit_idv'"
local exit_vars_dc32 "scrat0dc no_scrat0dc edddc no_edddc inspdc `exit_idv'"
local exit_vars_dc33 "scrat educ inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `exit_idv'"
local exit_vars_dc34 "scrat no_scrat educ no_educ inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `exit_idv'"
local exit_vars_dc35 "scrat0dc edddc inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `exit_idv'"
local exit_vars_dc36 "scrat0dc no_scrat0dc edddc no_edddc inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `exit_idv'"

local vars_dc0  "scrat no_scrat educ no_educ scrat_incm no_scrat_incm educ_incm no_educ_incm scrat_pvty no_scrat_pvty educ_pvty no_educ_pvty scrat0dc no_scrat0dc edddc no_edddc scrat0dc_incm no_scrat0dc_incm edddc_incm no_edddc_incm scrat0dc_pvty no_scrat0dc_pvty edddc_pvty no_edddc_pvty inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv' pct_pvty"

local vars_dc1 "scrat `idv'"
local vars_dc2 "scrat no_scrat `idv'"
local vars_dc3 "educ `idv'"
local vars_dc4 "educ no_educ `idv'"
local vars_dc5 "scrat educ `idv'"
local vars_dc6 "scrat no_scrat educ no_educ `idv'"
local vars_dc7 "scrat scrat_incm educ educ_incm `idv'"
local vars_dc8 "scrat scrat_incm no_scrat no_scrat_incm educ educ_incm no_educ no_educ_incm `idv'"
local vars_dc9 "scrat scrat_pvty educ educ_pvty `idv_pvty'"
local vars_dc10 "scrat scrat_pvty no_scrat no_scrat_pvty educ educ_pvty no_educ no_educ_pvty `idv_pvty'"

local vars_dc11 "scrat0dc `idv'"
local vars_dc12 "scrat0dc no_scrat0dc `idv'"
local vars_dc13 "edddc `idv'"
local vars_dc14 "edddc no_edddc `idv'"
local vars_dc15 "scrat0dc edddc `idv'"
local vars_dc16 "scrat0dc no_scrat0dc edddc no_edddc `idv'"
local vars_dc17 "scrat0dc scrat0dc_incm edddc edddc_incm `idv'"
local vars_dc18 "scrat0dc scrat0dc_incm no_scrat0dc no_scrat0dc_incm edddc edddc_incm no_edddc no_edddc_incm `idv'"
local vars_dc19 "scrat0dc scrat0dc_pvty edddc edddc_pvty `idv_pvty'"
local vars_dc20 "scrat0dc scrat0dc_pvty no_scrat0dc no_scrat0dc_pvty edddc edddc_pvty no_edddc no_edddc_pvty `idv_pvty'"

local vars_dc21 "inspdc `idv'"
local vars_dc22 "visitdc `idv'"
local vars_dc23 "aiddc `idv'"
local vars_dc24 "crimdc `idv'"
local vars_dc25 "cdhrsddc `idv'"
local vars_dc26 "expddc `idv'"
local vars_dc27 "ongoddc `idv'"
local vars_dc28 "ongohddc `idv'"
local vars_dc29 "scrat educ inspdc `idv'"
local vars_dc30 "scrat no_scrat educ no_educ inspdc `idv'"
local vars_dc31 "scrat0dc edddc inspdc `idv'"
local vars_dc32 "scrat0dc no_scrat0dc edddc no_edddc inspdc `idv'"
local vars_dc33 "scrat educ inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv'"
local vars_dc34 "scrat no_scrat educ no_educ inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv'"
local vars_dc35 "scrat0dc edddc inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv'"
local vars_dc36 "scrat0dc no_scrat0dc edddc no_edddc inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv'"

local vars_dc0_nologu5  "scrat no_scrat educ no_educ scrat_incm no_scrat_incm educ_incm no_educ_incm scrat_pvty no_scrat_pvty educ_pvty no_educ_pvty scrat0dc no_scrat0dc edddc no_edddc scrat0dc_incm no_scrat0dc_incm edddc_incm no_edddc_incm scrat0dc_pvty no_scrat0dc_pvty edddc_pvty no_edddc_pvty inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv_nologu5' pct_pvty"

local vars_dc1_nologu5 "scrat `idv_nologu5'"
local vars_dc2_nologu5 "scrat no_scrat `idv_nologu5'"
local vars_dc3_nologu5 "educ `idv_nologu5'"
local vars_dc4_nologu5 "educ no_educ `idv_nologu5'"
local vars_dc5_nologu5 "scrat educ `idv_nologu5'"
local vars_dc6_nologu5 "scrat no_scrat educ no_educ `idv_nologu5'"
local vars_dc7_nologu5 "scrat scrat_incm educ educ_incm `idv_nologu5'"
local vars_dc8_nologu5 "scrat scrat_incm no_scrat no_scrat_incm educ educ_incm no_educ no_educ_incm `idv_nologu5'"
local vars_dc9_nologu5 "scrat scrat_pvty educ educ_pvty `idv_nologu5_pvty'"
local vars_dc10_nologu5 "scrat scrat_pvty no_scrat no_scrat_pvty educ educ_pvty no_educ no_educ_pvty `idv_nologu5_pvty'"

local vars_dc11_nologu5 "scrat0dc `idv_nologu5'"
local vars_dc12_nologu5 "scrat0dc no_scrat0dc `idv_nologu5'"
local vars_dc13_nologu5 "edddc `idv_nologu5'"
local vars_dc14_nologu5 "edddc no_edddc `idv_nologu5'"
local vars_dc15_nologu5 "scrat0dc edddc `idv_nologu5'"
local vars_dc16_nologu5 "scrat0dc no_scrat0dc edddc no_edddc `idv_nologu5'"
local vars_dc17_nologu5 "scrat0dc scrat0dc_incm edddc edddc_incm `idv_nologu5'"
local vars_dc18_nologu5 "scrat0dc scrat0dc_incm no_scrat0dc no_scrat0dc_incm edddc edddc_incm no_edddc no_edddc_incm `idv_nologu5'"
local vars_dc19_nologu5 "scrat0dc scrat0dc_pvty edddc edddc_pvty `idv_nologu5_pvty'"
local vars_dc20_nologu5 "scrat0dc scrat0dc_pvty no_scrat0dc no_scrat0dc_pvty edddc edddc_pvty no_edddc no_edddc_pvty `idv_nologu5_pvty'"

local vars_dc21_nologu5 "inspdc `idv_nologu5'"
local vars_dc22_nologu5 "visitdc `idv_nologu5'"
local vars_dc23_nologu5 "aiddc `idv_nologu5'"
local vars_dc24_nologu5 "crimdc `idv_nologu5'"
local vars_dc25_nologu5 "cdhrsddc `idv_nologu5'"
local vars_dc26_nologu5 "expddc `idv_nologu5'"
local vars_dc27_nologu5 "ongoddc `idv_nologu5'"
local vars_dc28_nologu5 "ongohddc `idv_nologu5'"
local vars_dc29_nologu5 "scrat educ inspdc `idv_nologu5'"
local vars_dc30_nologu5 "scrat no_scrat educ no_educ inspdc `idv_nologu5'"
local vars_dc31_nologu5 "scrat0dc edddc inspdc `idv_nologu5'"
local vars_dc32_nologu5 "scrat0dc no_scrat0dc edddc no_edddc inspdc `idv_nologu5'"
local vars_dc33_nologu5 "scrat educ inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv_nologu5'"
local vars_dc34_nologu5 "scrat no_scrat educ no_educ inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv_nologu5'"
local vars_dc35_nologu5 "scrat0dc edddc inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv_nologu5'"
local vars_dc36_nologu5 "scrat0dc no_scrat0dc edddc no_edddc inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc `idv_nologu5'"

* market level analysis

local dep_cty "n_estb_cty employ_cty employ2_cty entry_cty accre_cty accre_cty_orig"

foreach var of local dep_cty {
	
	areg `var' `vars_dc0' year1992 year1997, absorb(num_st) cluster(year_st)
	outreg using `pathpgs3'`var', se 3aster bracket bdec(3) title("`var'") replace 

	forvalues i=1/`k' {
	
		reg `var' `vars_dc`i'', cluster(year_st)
		outreg using `pathpgs3'`var', se 3aster bracket bdec(3) append 
		reg `var' `vars_dc`i'' year1992 year1997, cluster(year_st) 
		outreg using `pathpgs3'`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'', absorb(num_st) cluster(year_st) 
		outreg using `pathpgs3'`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'' year1992 year1997, absorb(num_st) cluster(year_st) 
		outreg using `pathpgs3'`var', se 3aster bracket bdec(3) append 	
	}
	
} 


************ 
* Table 12 * 
************
 
* exit rate COUNTY level analysis

areg exit_cty `exit_vars_dc0' year1992 if year==1987 | year==1992, absorb(num_st) cluster(year_st) 
outreg using `pathpgs3'exit_cty, se 3aster bracket bdec(3) title("Exit Rate") replace  

forvalues i=1/`k' {

	reg exit_cty `exit_vars_dc`i'' if year==1987 | year==1992, cluster(year_st)
	outreg using `pathpgs3'exit_cty, se 3aster bracket bdec(3) append 
	reg exit_cty `exit_vars_dc`i'' year1992 if year==1987 | year==1992, cluster(year_st) 
	outreg using `pathpgs3'exit_cty, se 3aster bracket bdec(3) append 
	areg exit_cty `exit_vars_dc`i'' if year==1987 | year==1992, absorb(num_st) cluster(year_st) 
	outreg using `pathpgs3'exit_cty, se 3aster bracket bdec(3) append 
	areg exit_cty `exit_vars_dc`i'' year1992 if year==1987 | year==1992, absorb(num_st) cluster(year_st) 
	outreg using `pathpgs3'exit_cty, se 3aster bracket bdec(3) append

}

************ 
* Table 36 * 
************ 
 
* accreditation rate analysis with original numerator (rates < 1) 
 
areg accre_cty_orig `vars_dc0' year1992 year1997 if accre_cty_orig<=1, absorb(num_st) cluster(year_st) 
outreg using `pathpgs3'accre_cty_orig_rless1, se 3aster bracket bdec(3) title("Accreditation: County Level Regressions w/original numerator - rates < 1") replace 

forvalues i=1/`k' {

	reg accre_cty_orig `vars_dc`i'' if accre_cty_orig<=1, cluster(year_st)
	outreg using `pathpgs3'accre_cty_orig_rless1, se 3aster bracket bdec(3) append 
	reg accre_cty_orig `vars_dc`i'' year1992 year1997 if accre_cty_orig<=1, cluster(year_st) 
	outreg using `pathpgs3'accre_cty_orig_rless1, se 3aster bracket bdec(3) append 
	areg accre_cty_orig `vars_dc`i'' if accre_cty_orig<=1, absorb(num_st) cluster(year_st) 
	outreg using `pathpgs3'accre_cty_orig_rless1, se 3aster bracket bdec(3) append 
	areg accre_cty_orig `vars_dc`i'' year1992 year1997 if accre_cty_orig<=1, absorb(num_st) cluster(year_st) 
	outreg using `pathpgs3'accre_cty_orig_rless1, se 3aster bracket bdec(3) append

}

* the following dependent variables have under5 in the denominators

local dep_cty2 "est_dens emp_dens"

foreach var of local dep_cty2 {
	
	areg `var' `vars_dc0_nologu5' year1992 year1997, absorb(num_st) cluster(year_st) 
	outreg using `pathpgs3'`var'_cnty, se 3aster bracket bdec(3) title("`var'_cnty") replace  

	forvalues i=1/`k' {
	
		reg `var' `vars_dc`i'_nologu5', cluster(year_st)
		outreg using `pathpgs3'`var'_cnty, se 3aster bracket bdec(3) append 
		reg `var' `vars_dc`i'_nologu5' year1992 year1997, cluster(year_st) 
		outreg using `pathpgs3'`var'_cnty, se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'_nologu5', absorb(num_st) cluster(year_st) 
		outreg using `pathpgs3'`var'_cnty, se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'_nologu5' year1992 year1997, absorb(num_st) cluster(year_st) 
		outreg using `pathpgs3'`var'_cnty, se 3aster bracket bdec(3) append 	
	}
	
}



log close 
