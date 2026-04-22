************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************
***********************
***FOODGRAIN PRODUCTION SERIES (only 2001- )  -- NEW OCTOBER 3 2014
***********************
insheet using "$data/RBI/State-wise Production of Total Foodgrains in India (2001-2002 to 2013-2014 As on 15.05.2014).csv", comma names clear
reshape long _,i(state) j(year)
replace state = "Goa Daman and Diu" if trim(state)=="Goa" | trim(state)=="Daman and Diu"
replace state = "Orissa" if trim(state)=="Odisha"
replace state = "Pondicherry" if state=="Puducherry"
replace state = "Uttaranchal" if state=="Uttarakhand"
replace state = trim(upper(state))
collapse (sum) foodgrainprod000s= _, by(state year)
tempfile foodgrain
save `foodgrain'


***********************
***AGRIC PRODUCTION
***********************

insheet using "$data/RBI/TABLE 23 3A STATE-WISE PRODUCTION OF FOODGRAIN AND MAJOR NON-FOODGRAIN CROPS.csv", comma names clear
replace year=substr(year,1,4)
destring year, replace
replace state = trim(upper(state))
drop if state=="ALL INDIA" | state=="ALL STATES" | state=="UNION TERRITORIES"
replace state = "GOA DAMAN AND DIU" if state=="GOA"
replace state="JAMMU AND KASHMIR" if state=="JAMMU & KASHMIR"
g foodgrains_orig = agricuturalproduction000ton if crop=="Food Grains"
drop if crop=="Coarse Cereals" | crop=="Pulses" | crop=="Rice" | crop=="Wheat" //because food grains is a subtotal of these in the original table
collapse (sum) agprod000ton= agricuturalproduction000ton foodgrains_orig, by(state year)
keep if year >=1980 & year<=2011
tempfile agoutput
save `agoutput'

***********************
****PCGDP FIGURES
***********************

insheet using "$data/RBI/Per Cap Net State Domestic Product Factor Cost_Current.csv", comma names clear
rename stateunionterritory year
replace year = subinstr(year,"-","",.)
foreach var of varlist  andhrapradesh- puducherry {
cap replace `var' = "." if trim(`var') == "-"
cap destring `var', replace
rename `var'  _`var'
}
bys year: g rank=_N
assert rank==1
drop rank*

reshape long _, i(year) j(state) string
rename _ pcgdp_curr
tempfile pcgdp_curr
save `pcgdp_curr'

insheet using "$data/RBI/Per Cap Net State Domestic Product Factor Cost_Constant.csv", comma names clear
rename stateunionterritory year
replace year = subinstr(year,"-","",.)
replace base = subinstr(base,"-","",.)

foreach var of varlist  andhrapradesh- puducherry {
cap replace `var' = "." if trim(`var') == "-"
cap destring `var', replace
rename `var'  _`var'
}

reshape long _, i(year base) j(state) string
rename _ pcgdp_const

gsort state base year
foreach i in 0405_9900 9900_9394 8081_9394 {
g convert_mult_`i'_st=pcgdp_const if base=="conv_mult_`i'"
bys state: egen convert_mult_`i'_stA=sum(convert_mult_`i'_st)
drop convert_mult_`i'_st
}

replace pcgdp_const = pcgdp_const*convert_mult_0405_9900_stA if base=="200405"
replace base = "199900" if base=="200405"
replace pcgdp_const = pcgdp_const*convert_mult_9900_9394_stA if base=="199900"
replace base = "199394" if base=="199900"
replace pcgdp_const = pcgdp_const*convert_mult_8081_9394_stA if base=="198081"
replace base = "199394" if base=="198081"

drop convert*
drop if strpos(base,"conv_mult")>0

****UNIQUENESS
*replace pcgdp_const=round(pcgdp_const,1)
*duplicates drop
bys state year: g rank0=_n
bys state year: g rank1=_N
drop if rank0==rank1 & (pcgdp_const-pcgdp_const[_n-1])/pcgdp_const <.01 & state==state[_n-1] & year==year[_n-1]
drop if rank0==rank1 & pcgdp_const==pcgdp_const[_n-1] & state==state[_n-1] & year==year[_n-1]
drop rank0 rank1
assert base=="199394"
drop base
bys state year: g rank=_N
drop if rank==2 & pcgdp_const==.
bys state year: g rank2=_N
assert rank2==1
drop rank*

merge 1:1 state year using `pcgdp_curr'
	assert _m==3
	drop _m
	
tempfile pcgdp
save `pcgdp'


***********************
****GDP FIGURES
***********************
* Note: units are thousand crore rupees
insheet using "$data/RBI/Net State Domestic Product Factor Cost_Current.csv", comma names clear
replace year = subinstr(year,"-","",.)
foreach var of varlist  andhrapradesh- puducherry {
cap replace `var' = "." if trim(`var') == "-"
cap destring `var', replace
rename `var'  _`var'
}
bys year: g rank=_N
assert rank==1
drop rank*

reshape long _, i(year) j(state) string
rename _ gdp_curr
tempfile gdp_curr
save `gdp_curr'

insheet using "$data/RBI/Net State Domestic Product Factor Cost_Constant.csv", comma names clear
replace year = subinstr(year,"-","",.)
replace base = subinstr(base,"-","",.)

foreach var of varlist  andhrapradesh- puducherry {
cap replace `var' = "." if trim(`var') == "-"
cap destring `var', replace
rename `var'  _`var'
}

reshape long _, i(year base) j(state) string
rename _ gdp_const

gsort state base year
foreach i in 0405_9900 9900_9394 8081_9394 {
g convert_mult_`i'_st=gdp_const if base=="conv_mult_`i'"
bys state: egen convert_mult_`i'_stA=sum(convert_mult_`i'_st)
drop convert_mult_`i'_st
}

replace gdp_const = gdp_const*convert_mult_0405_9900_stA if base=="200405"
replace base = "199900" if base=="200405"
replace gdp_const = gdp_const*convert_mult_9900_9394_stA if base=="199900"
replace base = "199394" if base=="199900"
replace gdp_const = gdp_const*convert_mult_8081_9394_stA if base=="198081"
replace base = "199394" if base=="198081"

drop convert*
drop if strpos(base,"conv_mult")>0
****UNIQUENESS
bys state year: g rank0=_n
bys state year: g rank1=_N
drop if rank0==rank1 & (gdp_const-gdp_const[_n-1])/gdp_const <.01 & state==state[_n-1] & year==year[_n-1]
drop if rank0==rank1 & gdp_const==gdp_const[_n-1] & state==state[_n-1] & year==year[_n-1]
drop rank0 rank1
assert base=="199394"
drop base
bys state year: g rank=_N
drop if rank==2 & gdp_const==.
drop if state=="himachalpradesh" & year=="199394" & gdp_const==42 /*duplicate that is not being caught */
bys state year: g rank2=_N
assert rank2==1
drop rank*

merge 1:1 state year using `gdp_curr'
	assert _m==3
	drop _m
	

merge 1:1 state year using `pcgdp'
	assert _m==3
	drop _m
replace state=trim(state)
replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="andamannicobarislands"
replace state="ANDHRA PRADESH" if state=="andhrapradesh"
replace state="ARUNACHAL PRADESH" if state=="arunachalpradesh"
replace state="ASSAM" if state=="assam"
replace state="BIHAR" if state=="bihar"
replace state="CHANDIGARH" if state=="chandigarh"
replace state="CHHATTISGARH" if state=="chhattisgarh"


replace state="DELHI" if state=="delhi"

replace state="GOA DAMAN AND DIU" if state=="goa"
replace state="GUJARAT" if state=="gujarat"
replace state="HARYANA" if state=="haryana"
replace state="HIMACHAL PRADESH" if state=="himachalpradesh"
replace state="JAMMU AND KASHMIR" if state=="jammukashmir"
replace state="JHARKHAND" if state=="jharkhand"
replace state="KARNATAKA" if state=="karnataka"
replace state="KERALA" if state=="kerala"

replace state="MADHYA PRADESH" if state=="madhyapradesh"
replace state="MAHARASHTRA" if state=="maharashtra"
replace state="MANIPUR" if state=="manipur"
replace state="MEGHALAYA" if state=="meghalaya"
replace state="MIZORAM" if state=="mizoram"
replace state="NAGALAND" if state=="nagaland"
replace state="ORISSA" if state=="orissa"
replace state="PONDICHERRY" if state=="puducherry"
replace state="PUNJAB" if state=="punjab"
replace state="RAJASTHAN" if state=="rajasthan"
replace state="TAMIL NADU" if state=="tamilnadu"
replace state="TRIPURA" if state=="tripura"
replace state="UTTAR PRADESH" if state=="uttarpradesh"
replace state="UTTARANCHAL" if state=="uttarakhand"

replace state="WEST BENGAL" if state=="westbengal"
replace state="SIKKIM" if state=="sikkim"

collapse (sum) *gdp*, by(state year)
	
compress
destring year, replace
replace year=floor(year/100)
tab year 

g ratio=gdp_curr/gdp_const	
g base=ratio if year==2004
egen base2004=sum(base), by(state)
g gdpdefl_2004=ratio/base2004



****ALL IS IN BASE 93 -- BRING CONST ACCOUNTS TO BASE 2004
g num=gdp_const if year==2004
g denom=gdp_const if year==1993
egen num2004=sum(num), by(state)
egen denom1993=sum(denom), by(state)
g adjust9304=num2004/denom1993
replace gdp_const=gdp_const*adjust9304
replace pcgdp_const=pcgdp_const*adjust9304


preserve
drop ratio - gdpdefl_2004 adjust9304

merge 1:1 state year using `agoutput', assert(1 3) nogen
merge 1:1 state year using `foodgrain', keep(1 3) nogen

***post in new foodgrain series -- NEW OCTOBER 3 2014
pwcorr foodgrains_orig foodgrainprod000s 
replace foodgrains_orig = foodgrainprod000s if (foodgrains_orig==. | foodgrains_orig == 0) & foodgrainprod000s!=. & foodgrainprod000s!=0
drop foodgrainprod000s
pwcorr foodgrains_orig agprod000ton
rename foodgrains foodgrainprod000ton



/* Clean agricultural output data */
replace agprod000ton = . if year>=2009&agprod000ton==0
*replace foodgrainprod000ton = . if year>=2009&foodgrainprod000ton==0 //added to apply the same for foodgrain series -- but not binding
replace agprod000ton = 0 if inlist(state,"DELHI","PONDICHERRY","CHANDIGARH")
replace foodgrainprod000ton = 0 if inlist(state,"DELHI","PONDICHERRY","CHANDIGARH") //added to apply the same for foodgrain series

** For A&N Islands: impute missing agprod with foodgrain prod
replace agprod000ton = foodgrainprod000ton if state=="ANDAMAN AND NICOBAR ISLANDS"

** For Northeastern states: determine typical relationship and impute for three missing years
foreach state in "ARUNACHAL PRADESH" "GOA DAMAN AND DIU" "MANIPUR" "MEGHALAYA" "MIZORAM" "NAGALAND" "SIKKIM" "TRIPURA" {
	reg agprod000ton foodgrainprod000ton if state=="`state'"
	predict AgProdPred
	replace agprod000ton = AgProdPred if agprod000ton ==. & year>=2009&state=="`state'"

	drop AgProdPred
}
	
	
label data "RBI statewise GDP & GDPPC--constant values in base=2004 INR as of 11 may 2013"
	save "$work/state gdp and gdppc figs_const & curr.dta", replace



restore
keep state year gdpdefl_2004
preserve
keep if state=="GUJARAT"
replace state="DADRA AND NAGAR HAVELI"
tempfile temp
save `temp'
restore 
append using `temp'

	save "$work/state gdp deflator.dta", replace

