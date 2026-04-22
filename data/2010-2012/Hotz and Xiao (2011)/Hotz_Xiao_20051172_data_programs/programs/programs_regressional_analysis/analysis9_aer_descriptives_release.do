/* Last Updated July 2007, for AEA revision request 
 
 What's new: 
 1) cluster at the year_st level instead of year_zip level (but don't forget to run a year_zip (and a state only!) clustering version for comparison with previous results) 
 2) dummy out for no scrat and educ requirements. no requirement==1, ow=0. Also tried different definition
 for no education requirements---8 years for missing requirements. Results are robust
 3) Try other MQS variables. Try including one regulating at a time for robustness.
    good within state variation: inspdc visitdc aiddc crimdc; cdhrsddc expddc ongoddc ongohddc; cdhrstdc
 4) minor sample adjustment.    
 5) The differenial impact of MQS in wealthy vs poor markets. Try income or poverty
 6) Change wagerate=payroll per employee. For unincorporated firms, alternative definition for n_employ=n_employ+1 or 2.
 7) firm and establishment fixed effects. Q: how to deal with unbalanced panel?  for firm fixed effects, how to deal with state-fixed effects
 8) change edtdc to edddc because edddc has more within state variation.
 9) The differenial impact of MQS on chains, new entrants, and accreditted establishments.
 10) tried new c1990_clean and c2000_clean, which will lose 7 estab-year obs. Results almost no difference.
 11 instead of using edtdc for single MQS, used edddc because it has more within state variation. Results
 robust
 12) Tried using environment index as instrument. Results no good. 
To do: 	1) logit model for exit and accredit. Need both coefficients marginal effects reported.
	3) try alternative definition for chain: chain=(chainNestab>=5)?
*/ 

quietly { 
clear all 
capture log close 
set mem 2000m 
set matsize 500 
set more off 
 
local pathjuan 		"/rdcprojects/la00296/data/csr/Juan/"
local pathdemog 	"/rdcprojects/la00296/data/outsidemo/"
local pathpgs3  	"/rdcprojects/la00296/disclosure/July2007/" 
local pathdisclose 	"/rdcprojects/la00296/disclosure/July2007/" 
local pathoutside	"/rdcprojects/la00296/data/outside/" 


log using `pathpgs3'analysis9_aer_descriptives.log, replace 
} 

*************************************************************************************************** 
* Module 1: get data ready 
 
* For exit regressions: merge 2000 demographics with 1992 Cencus so year 1992 has both 1990 and 2000 demographics. 
* For an establishment exit at t+1 (we code exit=1 at time t), we need to use demographics at t+1 
 
use `pathdemog'c2000_clean.dta, clear 
gen year_mo=2000 
gen badzip=match(zipcode,"*X*") 
drop if badzip==1 
drop badzip 
destring zipcode, gen(num_zip5) 
drop if num_zip5==. 
drop zipcode 

local demog "pct_black pct_hisp hh_size m_income pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural under5" 
 
keep num_zip5 year_mo `demog' 
 
foreach var of local demog { 
	rename `var' `var'00 
} 
 
sort num_zip5 year_mo 
 
save `pathdemog'c2000_limited.dta, replace 
 
use `pathjuan'fully_merged.dta, clear 
 
* Keep only records from the Census data file 
keep if census_concat==1
*AE: not a state 
drop if st=="AE"
 
gen year_mo=2000 if year==1992 
 
sort num_zip5 year_mo 
merge num_zip5 year_mo using `pathdemog'c2000_limited.dta 
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
pct_unemploy00 pct_whome00 long_comm00 pct_rural00 under500 num_zip5; 
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
* year_st and year_zip is created for clustering  
 
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
***********************************************;
*Juan: this needs disclosure ;

#delimit cr

**********
* Table 51
**********

* 51-a)
tab chain year


*******************************
*Disclosure Code for Table 51-a 
*******************************

foreach year of numlist 1987 1992 1997 	{
 
	su payroll if chain==0 & year==`year'
	scalar sumyear`year'_chain0=r(sum) 
	preserve
	keep if chain==0 & year==`year'
	collapse (sum) payroll, by(num_ein year)
	scalar T51a_`year'_chain0_N =_N
	gsort -payroll 
	if sumyear`year'_chain0 != 0 scalar T51acr`year'_0 = (payroll[1]+payroll[2])/sumyear`year'_chain0
	di "----------------------------------------------------" 
	di "N  for Table 51a Year=`year' - chain = 0 : " T51a_`year'_chain0_N 
	di "CR for Table 51a Year=`year' - chain = 0 : " T51acr`year'_0 
	di "----------------------------------------------------"
	restore
	
	su payroll if chain==1 & year==`year'
	scalar sumyear`year'_chain1=r(sum)
	preserve 
	keep if chain==1 & year==`year' 
	collapse (sum) payroll, by(num_ein year)
	scalar T51a_`year'_chain1_N =_N
	gsort -payroll
	if sumyear`year'_chain1 != 0 scalar T51acr`year'_1 = (payroll[1]+payroll[2])/sumyear`year'_chain1 
	di "----------------------------------------------------"
	di "N  for Table 51a Year=`year' - chain = 1 : " T51a_`year'_chain1_N 
	di "CR for Table 51a Year=`year' - chain = 1 : " T51acr`year'_1 
	di "----------------------------------------------------"	
	restore
}



* 51-b)
su chainNestab if chain==0

*******************************
*Disclosure Code for Table 51-b 
*------------------------------

	su payroll if chain==0 & chainNestab != .
	scalar sum_chain0=r(sum)
	preserve
	keep if chain==0 & chainNestab != .
	collapse (sum) payroll, by(num_ein year)
	scalar T51b_N =_N
	gsort -payroll 
	if sum_chain0 != 0 scalar T51bcr = (payroll[1]+payroll[2])/sum_chain0
	di "----------------------------------------------------" 
	di "N  for Table 51b  - chain = 0 : " T51b_N 
	di "CR for Table 51b  - chain = 0 : " T51bcr 
	di "----------------------------------------------------"	
	restore

*******************************

* 51-c)
su chainNestab if chain==1, detail

*******************************
*Disclosure Code for Table 51-c 
*------------------------------
* only reporting mean and median
* therefore similar procedure

	su payroll if chain==1 & chainNestab != .
	scalar sum_chain1=r(sum)
	preserve
	keep if chain==1 & chainNestab != .
	collapse (sum) payroll, by(num_ein year)
	scalar T51c_N =_N
	gsort -payroll 
	if sum_chain1 != 0 scalar T51ccr = (payroll[1]+payroll[2])/sum_chain1
	di "----------------------------------------------------" 
	di "N  for Table 51b  - chain = 0 : " T51c_N 
	di "CR for Table 51b  - chain = 0 : " T51ccr 
	di "----------------------------------------------------"	
	restore

*******************************

sort year

* 51-d)
by year: su chainNestab if chain==0

*******************************
*Disclosure Code for Table 51-d 
*------------------------------

foreach year of numlist 1987 1992 1997 	{
 
	su payroll if chain==0 & year==`year' & chainNestab != .
	scalar sumyear`year'_chain0=r(sum)
	preserve
	keep if chain==0 & year==`year' & chainNestab != .
	collapse (sum) payroll, by(num_ein year)
	scalar T51d`year'_N =_N
	gsort -payroll 
	if sumyear`year'_chain0 != 0 scalar T51dcr`year'_0 = (payroll[1]+payroll[2])/sumyear`year'_chain0
	di "----------------------------------------------------" 
	di "N  for Table 51d  - chain = 0 - Year = `year' : " T51d`year'_N 
	di "CR for Table 51d  - chain = 0 - Year = `year' : " T51dcr`year'_0
	di "----------------------------------------------------"
	restore

}

*******************************

* 51-e)
by year: su chainNestab if chain==1, detail

*******************************
*Disclosure Code for Table 51-e 
*------------------------------
* only reporting mean and median
* therefore similar procedure

foreach year of numlist 1987 1992 1997 	{
 
	su payroll if chain==1 & year==`year' & chainNestab != .
	scalar sumyear`year'_chain1=r(sum)
	preserve
	keep if chain==1 & year==`year' & chainNestab != .
	collapse (sum) payroll, by(num_ein year)
	scalar T51e`year'_N =_N
	gsort -payroll 
	if sumyear`year'_chain1 != 0 scalar T51ecr`year'_1 = (payroll[1]+payroll[2])/sumyear`year'_chain1
	di "----------------------------------------------------" 
	di "N  for Table 51d  - chain = 0 - Year = `year' : " T51e`year'_N 
	di "CR for Table 51d  - chain = 0 - Year = `year' : " T51ecr`year'_1
	di "----------------------------------------------------"
	restore

}


*******************************

* 51-f)
tab chainNestab year if chainNestab>=50


*******************************
*Disclosure Code for Table 51-f 
*------------------------------

* Non-Disclosable
* Too few chains with more than 50 establishments

*******************************


*tab chainNestab chain 
*tab chainNestab year 
*tab chainNestab

* If a chain is accredited at a given year, are all its affiliated establishments accredited?

gen acc_chain=accredit*chain
egen acc_chainNestab= sum(acc_chain), by (num_ein year) 
gen pct_acc_chain=acc_chainNestab/chainNestab if chain==1
sort year

* 51-g)

by year: su chainNestab acc_chainNestab pct_acc_chain if chain==1
local varlist51g "chainNestab acc_chainNestab pct_acc_chain"

*******************************
*Disclosure Code for Table 51-g 
*------------------------------

foreach year of numlist 1987 1992 1997 	{
	
	foreach var of local varlist51g {
 
		su payroll if chain==1 & year==`year' & `var' !=.
		scalar sum`year'_`var'_chain1=r(sum)
		preserve
		keep       if chain==1 & year==`year' & `var' !=.
		collapse (sum) payroll, by(num_ein year)
		scalar T51g`year'_`var'_N =_N
		gsort -payroll
		if sum`year'_`var'_chain1 != 0 scalar T51gcr`year'_`var'_1 = (payroll[1]+payroll[2])/sum`year'_`var'_chain1
		di "----------------------------------------------------" 
		di "N  for Table 51g  - chain = 1 - Year = `year' - `var' : " T51g`year'_`var'_N 
		di "CR for Table 51g  - chain = 1 - Year = `year' - `var' : " T51gcr`year'_`var'_1
		di "----------------------------------------------------"	
		restore
	}
}

************************************************

***********************************************
**** 2nd Referee's question: Missing Expense***
***********************************************
* Juan: this needs disclosure 
 
gen expenfreq=0 if expense!=.  
replace expenfreq=1 if expense>0 & expense!=.

**********
* Table 52
**********

* 52-a)
tab expenfreq 

*******************************
*Disclosure Code for Table 52-a 
*------------------------------
*** Deleted by AR ***
*******************************

* 52-b)
tab expenfreq year

*******************************
*Disclosure Code for Table 52-b 
*------------------------------
*** Deleted by AR ***
*******************************
 
gen expense2= expense  
replace expense2=. if expense==0  
 
* converting to real terms (base 97)  
 
scalar cpi97 = 160.5  
scalar cpi92 = 140.3  
scalar cpi87 = 113.6  
 
gen revenueR=.  
replace revenueR= revenue*cpi97/cpi87 if year==1987  
replace revenueR= revenue*cpi97/cpi92 if year==1992  
replace revenueR= revenue*cpi97/cpi97 if year==1997  
gen payrollR=.  
replace payrollR= payroll*cpi97/cpi87 if year==1987  
replace payrollR= payroll*cpi97/cpi92 if year==1992  
replace payrollR= payroll*cpi97/cpi97 if year==1997  
gen expenseR=.  
replace expenseR= expense*cpi97/cpi87 if year==1987  
replace expenseR= expense*cpi97/cpi92 if year==1992  
replace expenseR= expense*cpi97/cpi97 if year==1997  
gen expense2R=.  
replace expense2R= expense2*cpi97/cpi87 if year==1987  
replace expense2R= expense2*cpi97/cpi92 if year==1992  
replace expense2R= expense2*cpi97/cpi97 if year==1997  
 
# delimit cr 

***********************************************
**** 2nd Referee's question: CFN continuity ***
***********************************************
* Juan: this needs disclosure 

**********
* Table 53
**********

* 53-a)
xtdes, i(num_cfn) t(year) 

*******************************
*Disclosure Code for Table 53-a
*------------------------------
*** Deleted by AR ***
*******************************


**********
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

*drop observations with abnormal patterns, eg. the same cfn shows up twice a year. Only a few obs 
drop if n_cfn>3 | exit_n_cfn>2 

* 53-b)
su n_ein panel_ein exit_n_ein exit_panel_ein n_cfn panel_cfn exit_n_cfn exit_panel_cfn

*******************************
*Disclosure Code for Table 53-b 
*------------------------------
*** Deleted by AR ***
*******************************

* 53-c)
by year, sort: su n_ein panel_ein exit_n_ein exit_panel_ein n_cfn panel_cfn exit_n_cfn exit_panel_cfn

*******************************
*Disclosure Code for Table 53-c 
*------------------------------
*** Deleted by AR ***
*******************************
 
* generate numeric firm attributes for establishment-level regressional analysis 
gen inc=(lfobase=="0") 
gen individual=(lfobase=="1") 
gen partnership=(lfobase=="2") 
gen if_tax_xpt=(tax_xmpt=="1") 
* can also use 9 months as the cutoff
gen partyear=(month_op<6)  
 
gen prolR_per_w=payrollR/n_employ  
gen expR_per_w=expenseR/n_employ   
gen exp2R_per_w=expense2R/n_employ  
gen revR_per_w=revenueR/n_employ  
gen pft2R=revenueR-payrollR 
* a 2nd definition for profit per worker because expense data is no good 
gen pftR_per_w2=pft2R/n_employ 

* consider that possibility that owners work on site. note the oweners should be on the payroll 
gen n_employ2=n_employ*(partnership==0 & individual==0)+(n_employ+2)*(partnership==1)+(n_employ+1)*(individual==1)
 
* clean demographics 

local demog "pct_black pct_hisp hh_size m_income pct_pvty college pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural under5" 
foreach var of local demog { 
	replace `var'00=`var' if year==1987 
} 

*gen ln_m_inc00=log(m_income00)
*replace ln_m_inc00=log(m_income00+0.01) if m_income00==0
*gen ln_under500=log(under500)
*replace ln_under500=log(under500+1) if under500==0
*gen ln_m_inc=log(m_income)
*replace ln_m_inc=log(m_income+0.01) if m_income==0
*gen ln_under5=log(under5)
*replace ln_under5=log(under5+1) if under5==0 

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

* generate education index. treating miss values and 0 as educ=0.
*Note sometimes one or two of the three ed*dc are zeros  
replace edddc=0 if edddc==.
replace edtdc=0 if edtdc==.
replace edadc=0 if edadc==.

*gen educ=(edddc+edtdc+edadc)/3 
* edadc are often not regulated 
gen educ=(edddc+edtdc)/2   
  
* generate a dummy variable for no staff-education requirements 
gen no_educ=(educ==0)  
* generate a dummy variable for no director education requirements 
gen no_edddc=(edddc==0) 

*try implicit education requirement later. 8 years is the min of edadc.
* tried this for zip code level results. Results very robust.
*replace edddc=8 if edddc==0
*replace edtdc=8 if edtdc==0
*replace edadc=8 if edadc==0 
*replace educ=(edddc+edtdc+edadc)/3
 
* add in MQS variables with good within state variation
replace insurdc=0 if insurdc==. 
*There is NOT enough within state variation in insurdc 
replace inspdc=0 if inspdc==.
replace visitdc=0 if visitdc==.
replace crimdc=0 if crimdc==.
replace aiddc=0 if aiddc==.

replace cdhrsddc=0 if cdhrsddc==.
*rescale cdhrsddc by 1/100
replace cdhrsddc=cdhrsddc/100 
replace expddc=0 if expddc==.
replace ongoddc=0 if ongoddc==.
replace ongohddc=0 if ongohddc==.
replace cdhrstdc=0 if cdhrstdc==.
*rescale cdhrstdc by 1/100 
replace cdhrstdc=cdhrstdc/100 

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

* step 4: define variables: entry, exit; aggregate at the zip level
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
 
* aggregate entry and exit to zip code level 
sort zip5 year 
by zip5 year: egen n_entry=sum(entry) 
by zip5 year: egen n_exit=sum(exit) 
by zip5 year: egen n_estb_zip=count(num_cfn) 
by zip5 year: egen n_accredit=sum(accredit) 
by zip5 year: egen employ_zip=sum(n_employ) 
by zip5 year: egen employ2_zip=sum(n_employ2)
by zip5 year: gen ziporder=_n 
 
replace entry=0 if entry==. & year!=1987 
replace exit=0 if exit==. & year!=1997  
  
 
**************************************************************** 
* Added by JP on 4/13/2005 
* Merges number of accreditted center in each zip-year 
* computed from original NAEYC data 
**************************************************************** 
 
preserve 
use `pathoutside'naeyc_clean_orig.dta, clear 
keep acc_status_1987_3m acc_status_1992_3m acc_status_1997_3m zip naeyc_id 
rename zip num_zip5 
rename acc_status_1987_3m acc_status1987 
rename acc_status_1992_3m acc_status1992 
rename acc_status_1997_3m acc_status1997 
reshape long acc_status, i(naeyc_id) j(year) 
drop naeyc_id 
sort num_zip5 year 
by num_zip5 year: egen n_accredit_orig=sum(acc_status) 
keep num_zip5 year n_accredit_orig 
collapse n_accredit_orig , by (year num_zip5) 
sort num_zip5 year 
saveold `pathjuan'accredit_orig.dta, replace 
restore 
 
sort num_zip5 year 
merge num_zip5 year using `pathjuan'accredit_orig.dta 
tab _merge 
rename _merge april_merge 
replace n_accredit_orig = 0 if n_accredit_orig == . 
 
preserve 
collapse n_accredit_orig n_accredit, by (year num_zip5) 
su n_accredit_orig n_accredit , detail 
restore 
 
**************************************************************** 

**********
* Table 54 
**********

* 54-a)
tab exit if year==1987 

*******************************
*Disclosure Code for Table 54-a 
*------------------------------
*** Deleted by AR ***
*******************************

* 54-b)
tab entry if year==1992 

*******************************
*Disclosure Code for Table 54-b 
*------------------------------
*** Deleted by AR ***
*******************************

* 54-c)
tab exit if year==1992 

*******************************
*Disclosure Code for Table 54-c 
*------------------------------
*** Deleted by AR ***
*******************************

* 54-d)
tab entry exit if year==1992, row col cell 

*******************************
*Disclosure Code for Table 54-d 
*------------------------------
*** Deleted by AR ***
*******************************

* 54-e)
tab entry if year==1997 

*******************************
*Disclosure Code for Table 54-e 
*------------------------------
*** Deleted by AR ***
*******************************

* 54-f)
su entry exit accredit prolR_per_w revR_per_w pftR_per_w2

*******************************
*Disclosure Code for Table 54-f 
*------------------------------
*** Deleted by AR ***
*******************************

sort year 
 
*********** 
* Table 3 * 
*********** 
 
by year: su entry exit accredit prolR_per_w revR_per_w pftR_per_w2
  
************************************************ 
*Disclosure Code for Table 3 
************************************************ 
*** Deleted by AR ***
*********************************************** 
  
*replace prolR_per_w=log(prolR_per_w) 
*replace revR_per_w=log(revR_per_w) 
*replace pftR_per_w2=log(pftR_per_w2)  
 
 
* year by year descriptive statistics 
* Juan, the folowing tabulation needs disclosure



**********
* Table 55
**********

sort year 

* 55-a)
by year: tab lfobase

************************************************ 
*Disclosure Code for Table 55-a 
************************************************ 
*** Deleted by AR ***
************************************************ 

* 55-b)
by year: tab tax_xmpt

************************************************ 
*Disclosure Code for Table 55-b
************************************************ 
*** Deleted by AR ***
************************************************ 

* 55-c)
by year: tab non_pft

************************************************ 
*Disclosure Code for Table 55-c
************************************************ 
*** Deleted by AR ***
************************************************ 

* 55-d)
by year: tab month_op

************************************************ 
*Disclosure Code for Table 55-d
************************************************ 
*** Deleted by AR ***
************************************************ 

* 55-e)
by year: tab licensed

************************************************ 
*Disclosure Code for Table 55-e
************************************************ 
*** Deleted by AR ***
************************************************ 
 
# delimit ;  
 
*********** 
* Table 2 * 
***********; 
 
by year: su 

inc individual partnership if_tax_xpt partyear chain n_employ n_employ2 revenueR payrollR 
expenseR expense2R expR_per_w exp2R_per_w revR_per_w prolR_per_w pftR_per_w2
 
n_estab n_staff n_children n_groups n_sites 
acc_status_1987_1d acc_status_1987_3m acc_status_1987_6m 
acc_status_1992_1d acc_status_1992_3m acc_status_1992_6m 
acc_status_1997_1d acc_status_1997_3m acc_status_1997_6m 
 
pop under5 n_infant age_1_2 age_3_4 n_schage n_toddler n_presch 
pct_over60 pct_over55 pct_freign mobility pct_nolabor f_parttime 
pct_black pct_hisp hh_size m_income ln_m_inc pct_pvty college 
pct_fh_c pct_unemploy pct_whome long_comm pct_rural 
pct_black00 pct_hisp00 hh_size00 ln_m_inc00 pct_pvty00 college00 
ln_under500 pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00  
 
preddc healdc agetdc pretdc exptdc ageadc preadc cdhrsadc expadc curricdc equipdc fooddc 
inftdc outftdc insurdc size0dc size1dc size2dc size3dc size4dc size5dc 
rat0dc rat1dc rat2dc rat3dc rat4dc rat5dc scrat0dc no_scrat0dc scrat1dc scrat2dc scrat3dc scrat4dc scrat5dc
scrat no_scrat edddc no_edddc edtdc edadc educ no_educ 
inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc cdhrstdc; 

*******************************
*Disclosure Code for Table 2 
*------------------------------;
*** Deleted by AR ***
***********************************************
# delimit ;

keep if pct_black!=. & pct_hisp!=. & hh_size!=. & ln_m_inc!=. & pct_pvty!=. & 
        college!=. & ln_under5!=. & pct_fh_c!=. & pct_f_nwork!=. & pct_unemploy!=. 
	& pct_whome!=. & long_comm!=. & pct_rural!=. ; 

* Juan, this following summary table needs disclosure;

*********
*Table 56
*********;

by year: su 

inc individual partnership if_tax_xpt partyear chain n_employ n_employ2 revenueR payrollR 
expenseR expense2R expR_per_w exp2R_per_w revR_per_w prolR_per_w pftR_per_w2 
n_estab n_staff n_children n_groups n_sites 
acc_status_1987_1d acc_status_1987_3m acc_status_1987_6m 
acc_status_1992_1d acc_status_1992_3m acc_status_1992_6m 
acc_status_1997_1d acc_status_1997_3m acc_status_1997_6m 
 
pop under5 n_infant age_1_2 age_3_4 n_schage n_toddler n_presch 
pct_over60 pct_over55 pct_freign mobility pct_nolabor f_parttime 
pct_black pct_hisp hh_size ln_m_inc pct_pvty college pct_fh_c pct_unemploy pct_whome long_comm pct_rural 
pct_black00 pct_hisp00 hh_size00 ln_m_inc00 pct_pvty00 college00 ln_under500 pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00  
 
preddc healdc agetdc pretdc exptdc ageadc preadc cdhrsadc expadc curricdc equipdc fooddc inftdc outftdc insurdc size0dc size1dc size2dc size3dc size4dc size5dc rat0dc rat1dc rat2dc rat3dc rat4dc rat5dc  
scrat0dc no_scrat0dc scrat1dc scrat2dc scrat3dc scrat4dc scrat5dc scrat no_scrat edddc no_edddc edtdc edadc educ no_educ 
inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc cdhrstdc; 
 
*******************************
*Disclosure Code for Table 56 
*------------------------------;
*** Deleted by AR ***
*******************************

 
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
*** Deleted by AR ***
**************************************************************************************************** 
* Module 2: establishment level analysis 
 

gen gsize_reg=1/size0dc 
replace gsize_reg=0 if size0dc==. 
gen cdhrs100=cdhrstdc/100 
 
* Small Loop to generate state dummies !!! Because xi does not work !!! 

 
forvalues s=1/56 { 
gen d_state`s'=0 
replace d_state`s'=1 if num_st==`s' 
} 
 


****************************************************************************************************  
* Module 3: zip code level analysis 
 
quietly { 

* keep unique zip-year combos
keep if ziporder==1 
 
sort zip5 year 
by zip5: gen zip_yr_order=_n 
* gen entry_zip=n_entry/n_estb_zip 
 
* the following way to define entry rate will lose zipcodes who do not show up in the _n-1 year; but this definition is based on previous literature 
* need to check how many observations we lose here. 

  gen entry_zip=n_entry/n_estb_zip[_n-1] if zip_yr_order!=1 
* gen entry_zip=n_entry/n_estb_zip       if zip_yr_order!=1 
  gen  exit_zip=n_exit /n_estb_zip 
 
gen accre_zip=n_accredit/n_estb_zip
gen accre_zip_orig=n_accredit_orig/n_estb_zip 
 
gen emp_dens=employ_zip/under5 
replace emp_dens=employ_zip/(under5+1) if under5==0 
gen est_dens=n_estb_zip/under5 
replace est_dens=n_estb_zip/(under5+1) if under5==0 

} 
 
*********** 
* Table 4 * 
*********** 
 
sort year 

by year: su n_estb_zip est_dens employ_zip employ2_zip n_entry entry_zip n_exit exit_zip n_accredit accre_zip n_accredit_orig  accre_zip_orig emp_dens

* NO disclosure code is needed as this with an aggregated sample of zipcodes/years, not microdata
 
* Table 4 Addendum 
* ---------------- 
by year: su n_accredit_orig  accre_zip_orig if accre_zip_orig<=1 
 
* NO disclosure code is needed as this with an aggregated sample of zipcodes/years, not microdata 
 
*********** 
* Table 5 * 
*********** 
by year, sort: su pop pct_black pct_hisp hh_size m_income ln_m_inc pct_pvty college under5 ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural under500 ln_under500 pct_black00 pct_hisp00 hh_size00 m_income00 ln_m_inc00 pct_pvty00 college00  pct_fh_c00 pct_f_nwork00 pct_unemploy00 pct_whome00 long_comm00 pct_rural00 

* NO disclosure code is needed as this with an aggregated sample of zipcodes/years, not microdata 

clear 
log close 
