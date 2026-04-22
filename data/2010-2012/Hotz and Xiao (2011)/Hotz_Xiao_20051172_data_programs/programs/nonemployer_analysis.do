* Last Updated Jan 2009
* For AER revision: the effects of MQS on non-employers
* what's new: add family home MQS

clear
capture log close
set mem 50m
set matsize 120
set more off

local pathnonemployer "C:\work\thesis\daycare\ccrdc\nonemployer\"
local pathreg "C:\work\thesis\daycare\ccrdc\reg\"
local pathcensus "C:\work\thesis\daycare\ccrdc\popcensus\"

log using `pathnonemployer'analysis1.log, replace

***************************************************************************************************
* Module 1: nonemployer analysis at the state level. Data 1987, 1992, 1997

noi di "Merging nonemployer & Regulation datasets by STATE and year"
noi di

use `pathreg'reg.dta, clear
rename state st
forvalues y=83/96 {
replace year=19`y' if year==`y'
		  }
replace year=1997 if year==1996
replace year=1987 if year==1986 & st=="WA"
keep if year==1987|year==1992|year==1997
drop if st=="CWLA"
sort st year

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

replace rat`i'fh=. if rat`i'fh==99
gen scrat`i'fh=0 if rat`i'fh==.
replace scrat`i'fh=1/rat`i'fh if rat`i'fh!=.
}
gen scrat=(scrat0dc+scrat1dc+scrat2dc+scrat3dc+scrat4dc+scrat5dc)/6 
gen scratfh=(scrat0fh+scrat1fh+scrat2fh+scrat3fh+scrat4fh+scrat5fh)/6 

gen no_scrat=(scrat==0)
gen no_scrat0dc=(scrat0dc==0)
gen no_scratfh=(scratfh==0)
gen no_scrat0fh=(scrat0fh==0)

* generate education index. treating miss values and 0 as educ=0.
*Note sometimes one or two of the three ed*dc are zeros  
replace edddc=0 if edddc==.
replace edtdc=0 if edtdc==.
replace edadc=0 if edadc==.

* note for family homes there are no teachers and assistants.
replace eddfh=0 if eddfh==.

*gen educ=(edddc+edtdc+edadc)/3 
* edadc are often not regulated 
gen educ=(edddc+edtdc)/2   
  
* generate a dummy variable for no staff-education requirements 
gen no_educ=(educ==0)  
* generate a dummy variable for no director education requirements 
gen no_edddc=(edddc==0) 
gen no_eddfh=(eddfh==0) 

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

gen year1992=(year==1992)
gen year1997=(year==1997)

saveold `pathreg'reg_2007revised.dta, replace

use `pathnonemployer'state\nonemp_st_w1987.dta, clear
keep estab ecvalue year state num_st
rename state st
sort st year
merge st year using `pathreg'reg_2007revised.dta
drop if _merge==2
drop _merge 

* merge in STATE level demographics data
sort num_st year
merge num_st year using `pathnonemployer'state\c1987_state_clean.dta 
drop if _merge==2
drop _merge

sort num_st year
merge num_st year using `pathnonemployer'state\c1992_state_clean.dta, update 
drop if _merge==2
drop _merge

sort num_st year
merge num_st year using `pathnonemployer'state\c1997_state_clean.dta, update 
drop if _merge==2
drop _merge 


* 07/17/2007 revision: rescale m_income and under5 by 1/1000. 

replace estab=estab/1000
gen estab_over_under5=estab/(under5/1000)

scalar cpi97 = 160.5 
scalar cpi92 = 140.3 
scalar cpi87 = 113.6 

replace ecvalue=ecvalue*cpi97/cpi87 if year==1987
replace ecvalue=ecvalue*cpi97/cpi92 if year==1992 
replace ecvalue=ecvalue*cpi97/cpi97 if year==1997 
replace ecvalue=ecvalue/1000

gen ecvalue_per_estab=ecvalue/estab

gen ln_m_inc=m_income/1000
gen ln_under5=under5/1000
gen pct_child=under5/pop 

* Interactions of MQS with ln_m_inc 
gen scrat_incm=scrat*ln_m_inc 
gen no_scrat_incm=no_scrat*ln_m_inc
gen educ_incm=educ*ln_m_inc 
gen no_educ_incm=no_educ*ln_m_inc 
gen scrat0dc_incm=scrat0dc*ln_m_inc 
gen no_scrat0dc_incm=no_scrat0dc*ln_m_inc 
gen edddc_incm=edddc*ln_m_inc 
gen no_edddc_incm=no_edddc*ln_m_inc 

* Interactions of MQS with pct_pvty
gen scrat_pvty=scrat*pct_pvty 
gen no_scrat_pvty=no_scrat*pct_pvty
gen educ_pvty=educ*pct_pvty 
gen no_educ_pvty=no_educ*pct_pvty 
gen scrat0dc_pvty=scrat0dc*pct_pvty 
gen no_scrat0dc_pvty=no_scrat0dc*pct_pvty 
gen edddc_pvty=edddc*pct_pvty
gen no_edddc_pvty=no_edddc*pct_pvty 

su
* for clustering
gen year_st=year+0.01*num_st

* dependent variable: # of nonemployers
local k=36 
local idv "pct_black pct_hisp hh_size ln_m_inc college ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 
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

local dep_st "estab estab_over_under5 ecvalue ecvalue_per_estab"

foreach var of local dep_st {
	
	reg `var' `vars_dc0' year1992 year1997
	outreg using `pathnonemployer'st_`var', se 3aster bracket bdec(3) title("st_`var'") replace  

	forvalues i=1/`k' {
	
		reg `var' `vars_dc`i'', cluster(year_st)
		outreg using `pathnonemployer'st_`var', se 3aster bracket bdec(3) append
		reg `var' `vars_dc`i'' year1992 year1997, cluster(year_st) 
		outreg using `pathnonemployer'st_`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'', absorb(num_st) cluster(year_st) 
		outreg using `pathnonemployer'st_`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'' year1992 year1997, absorb(num_st) cluster(year_st) 
		outreg using `pathnonemployer'st_`var', se 3aster bracket bdec(3) append 	
	}
	
} 


keep st num_st
duplicates drop st, force
sort st
save `pathnonemployer'st_num_st.dta, replace

**********


***************************************************************************************************
* Module 2: merge nonemployer data with regulation data by MSA
* nonemployer data at the MSA level are only available for 1992 and 1997

use `pathnonemployer'MSA\nonemp_msa_1992_1997.dta, clear
sort msa pmsa year
by msa pmsa: replace msa_name=msa_name[_n+1] if _n==1
* correct incomplete names in 1992 data. If a msa only shows up in 1992 or 1997, st=missing
gen st=substr(msa_name, -6,2) if substr(msa_name, -4,4)==" MSA" & substr(msa_name, -7,1)~="-"
replace st=substr(msa_name, -7,2) if st=="" & substr(msa_name, -3,3)=="MSA" & substr(msa_name, -8,1)~="-"
* CMSA and PMSA sometimes cover multiple states

* merge in MSA level demographics data
merge msa pmsa year using `pathcensus'MSA\c1990_cmsa_msa_pmsa_clean.dta 
drop if _merge==2
drop _merge

sort msa pmsa year
merge msa pmsa year using `pathcensus'MSA\c2000_cmsa_msa_pmsa_clean.dta, update 
drop if _merge==2
drop _merge GEO_ID geo_id2 sumlev geocomp cmsa_msa_pmsaSTR cmsa_msa_pmsa SUMLEVEL geoname GEO_NAME

* merge in state regulation data
drop if st=="" | substr(msa_name, -4,4)=="CMSA"
* delete observations if it's a CMSA or (PSA which covers multiple states) or (only shows up in one year)
sort st year
merge st year using `pathreg'reg_2007revised.dta
drop if _merge==2
drop _merge

replace estab=estab/1000
gen estab_over_under5=estab/(under5/1000)

scalar cpi97 = 160.5 
scalar cpi92 = 140.3 
scalar cpi87 = 113.6 

replace ecvalue=ecvalue*cpi97/cpi87 if year==1987
replace ecvalue=ecvalue*cpi97/cpi92 if year==1992 
replace ecvalue=ecvalue*cpi97/cpi97 if year==1997 
replace ecvalue=ecvalue/1000

gen ecvalue_per_estab=ecvalue/estab

gen ln_m_inc=m_income/1000
gen ln_under5=under5/1000
gen pct_child=under5/pop 

* Interactions of MQS with ln_m_inc 
gen scrat_incm=scrat*ln_m_inc 
gen no_scrat_incm=no_scrat*ln_m_inc
gen educ_incm=educ*ln_m_inc 
gen no_educ_incm=no_educ*ln_m_inc 
gen scrat0dc_incm=scrat0dc*ln_m_inc 
gen no_scrat0dc_incm=no_scrat0dc*ln_m_inc 
gen edddc_incm=edddc*ln_m_inc 
gen no_edddc_incm=no_edddc*ln_m_inc 

* Interactions of MQS with pct_pvty
gen scrat_pvty=scrat*pct_pvty 
gen no_scrat_pvty=no_scrat*pct_pvty
gen educ_pvty=educ*pct_pvty 
gen no_educ_pvty=no_educ*pct_pvty 
gen scrat0dc_pvty=scrat0dc*pct_pvty 
gen no_scrat0dc_pvty=no_scrat0dc*pct_pvty 
gen edddc_pvty=edddc*pct_pvty
gen no_edddc_pvty=no_edddc*pct_pvty 

su

* for clustering
tostring year, replace
gen year_st=year+st

* note no_scrat and no_scrat0dc are both 0. will be dropped
* dependent variable: # of nonemployers
local k=36 
local idv "pct_black pct_hisp hh_size ln_m_inc college ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 
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

local dep_st "estab estab_over_under5 ecvalue ecvalue_per_estab"

foreach var of local dep_st {
	
	reg `var' `vars_dc0' year1992 
	outreg using `pathnonemployer'msa_`var', se 3aster bracket bdec(3) title("msa_`var'") replace  

	forvalues i=1/`k' {
	
		reg `var' `vars_dc`i'', cluster(year_st)
		outreg using `pathnonemployer'msa_`var', se 3aster bracket bdec(3) append
		reg `var' `vars_dc`i'' year1997, cluster(year_st) 
		outreg using `pathnonemployer'msa_`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'', absorb(st) cluster(year_st) 
		outreg using `pathnonemployer'msa_`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'' year1997, absorb(st) cluster(year_st) 
		outreg using `pathnonemployer'msa_`var', se 3aster bracket bdec(3) append 	
	}
	
} 


**********


***************************************************************************************************
* Module 3: merge nonemployer data with regulation data by county
* nonemployer data at the county level are only available from 1997 to 2001
* regulation data modified by Anna Aizer has data only until 2000

use `pathreg'chcare_aizer.dta, clear
sort st
merge st using `pathnonemployer'st_num_st.dta
drop _merge

forvalues y=83/99 {
replace year=19`y' if year==`y'
		  }
keep if year==1997 |year==1998 | year==1999 | year==2000
drop if st=="CWLA"
sort num_st year

* staff-child ratio MQS, treating missing values and 99 as scrat=0.
foreach i of numlist 0(1)5 {
replace rat`i'dc=. if rat`i'dc==99
gen scrat`i'dc=0 if rat`i'dc==.
replace scrat`i'dc=1/rat`i'dc if rat`i'dc!=.
}

gen no_scrat0dc=(scrat0dc==0)

* no need to generate MQS index because Aizer does not have edtdc after all 
    
* generate a dummy variable for no director education requirements 
gen no_edddc=(edddc==0) 

gen year1997=(year==1997)
gen year1998=(year==1998)
gen year1999=(year==1999)
gen year2000=(year==2000)

saveold `pathreg'chcare_aizer_2007revised.dta, replace

use `pathnonemployer'county\nonemp_cty_1997_2001.dta, clear
keep st county msa year estab estabf ecvalue ecvaluef
destring year, replace
drop if year==2001

drop if county=="000"
*county county and state data
*drop observations with disclosure issues
drop if estabf=="D" | ecvaluef=="D"

* merge in 2000 county level demographics data. 

egen cnty=concat(st county)
drop county
destring cnty, gen(county)
sort county
merge county using `pathcensus'county\c2000_cnty_clean.dta 
drop if _merge==2
drop _merge

destring st, gen(num_st)
sort num_st year
merge num_st year using `pathreg'chcare_aizer_2007revised.dta
drop if _merge==2
drop _merge

replace estab=estab/1000
gen estab_over_under5=estab/(under5/1000)

scalar cpi97 = 160.5 
scalar cpi92 = 140.3 
scalar cpi87 = 113.6 

replace ecvalue=ecvalue*cpi97/cpi87 if year==1987
replace ecvalue=ecvalue*cpi97/cpi92 if year==1992 
replace ecvalue=ecvalue*cpi97/cpi97 if year==1997 
replace ecvalue=ecvalue/1000

gen ecvalue_per_estab=ecvalue/estab

gen ln_m_inc=m_income/1000
gen ln_under5=under5/1000
gen pct_child=under5/pop 

* Interactions of MQS with ln_m_inc 
gen scrat0dc_incm=scrat0dc*ln_m_inc 
gen no_scrat0dc_incm=no_scrat0dc*ln_m_inc 
gen edddc_incm=edddc*ln_m_inc 
gen no_edddc_incm=no_edddc*ln_m_inc 

* Interactions of MQS with pct_pvty
gen scrat0dc_pvty=scrat0dc*pct_pvty 
gen no_scrat0dc_pvty=no_scrat0dc*pct_pvty 
gen edddc_pvty=edddc*pct_pvty
gen no_edddc_pvty=no_edddc*pct_pvty 

su

* for clustering
tostring year, replace
gen year_st=year+st

local k=20
local idv "pct_black pct_hisp hh_size ln_m_inc college ln_under5 pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural" 
local vars_dc0  "scrat0dc no_scrat0dc edddc no_edddc scrat0dc_incm no_scrat0dc_incm edddc_incm no_edddc_incm scrat0dc_pvty no_scrat0dc_pvty edddc_pvty no_edddc_pvty `idv' pct_pvty"

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


local dep_st "estab estab_over_under5 ecvalue ecvalue_per_estab"

foreach var of local dep_st {
	
	reg `var' `vars_dc0' year1998 year1999 year2000 
	outreg using `pathnonemployer'cty_`var', se 3aster bracket bdec(3) title("cty_`var'") replace  

	forvalues i=11/`k' {
	
		reg `var' `vars_dc`i'', cluster(year_st)
		outreg using `pathnonemployer'cty_`var', se 3aster bracket bdec(3) append
		reg `var' `vars_dc`i'' year1998 year1999 year2000, cluster(year_st) 
		outreg using `pathnonemployer'cty_`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'', absorb(st) cluster(year_st) 
		outreg using `pathnonemployer'cty_`var', se 3aster bracket bdec(3) append 
		areg `var' `vars_dc`i'' year1998 year1999 year2000, absorb(st) cluster(year_st) 
		outreg using `pathnonemployer'cty_`var', se 3aster bracket bdec(3) append 	
	}
	
} 
log close

