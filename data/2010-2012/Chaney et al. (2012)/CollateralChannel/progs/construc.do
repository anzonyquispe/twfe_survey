clear matrix
clear mata
clear	
set mem 900m
set mat 800
cap log close
set more 1

******************************************************************************************
*******THIS .do file CONSTRUCT THE MAIN DATASET USED IN THE PAPER ***********************
******* "THE COLLATERAL CHANNEL" by Chaney et al.  ***************************************
******************************************************************************************

****************************************************************************************************************
******************CREATION OF A DATASET WITH INFORMATION ON PRICES**********************************************
****************************************************************************************************************

***this requires to extract housing price index from OFHEO, both at the state and the MSA level.

***********************
***AT THE STATE LEVEL
***********************

***housing_data is residential real estate data from OFHEO at the state level
insheet using "../data/housing_data.txt", names tab clear

***we take as yearly index the average index among the 4 quarters in the year
collapse (mean) index, by(state year)
ren index index_state

****redefine state variable to make it consistent across dataset
gen st=1 if state=="AL"
replace st=2 if state=="AK"
replace st=4 if state=="AZ"
replace st=5 if state=="AR"
replace st=6 if state=="CA"
replace st=8 if state=="CO"
replace st=9 if state=="CT"
replace st=10 if state=="DE"
replace st=11 if state=="DC"
replace st=12 if state=="FL"
replace st=13 if state=="GA"
replace st=15 if state=="HI"
replace st=16 if state=="ID"
replace st=17 if state=="IL"
replace st=18 if state=="IN"
replace st=19 if state=="IA"
replace st=20 if state=="KS"
replace st=21 if state=="KY"
replace st=22 if state=="LA"
replace st=23 if state=="ME"
replace st=24 if state=="MD"
replace st=25 if state=="MA"
replace st=26 if state=="MI"
replace st=27 if state=="MN"
replace st=28 if state=="MS"
replace st=29 if state=="MO"
replace st=30 if state=="MT"
replace st=31 if state=="NE"
replace st=32 if state=="NV"
replace st=33 if state=="NH"
replace st=34 if state=="NJ"
replace st=35 if state=="NM"
replace st=36 if state=="NY"
replace st=37 if state=="NC"
replace st=38 if state=="ND"
replace st=39 if state=="OH"
replace st=40 if state=="OK"
replace st=41 if state=="OR"
replace st=42 if state=="PA"
replace st=44 if state=="RI"
replace st=45 if state=="SC"
replace st=46 if state=="SD"
replace st=47 if state=="TN"
replace st=48 if state=="TX"
replace st=49 if state=="UT"
replace st=50 if state=="VT"
replace st=51 if state=="VA"
replace st=53 if state=="WA"
replace st=54 if state=="WV"
replace st=55 if state=="WI"
replace st=56 if state=="WY"
replace st=60 if state=="AS"
replace st=66 if state=="GU"
replace st=69 if state=="MP"
replace st=72 if state=="PR"
replace st=78 if state=="VI"
drop if st==.
drop state
ren st state

****we normalize 2006 price index as 1 in 2006
cap drop var1
cap drop var2
gen var1=index_state if year==2006
egen var2=max(var1),by(state)
replace index_state=index_state/var2
drop var1 var2

****store this in temporary file temp1
sort state year
save "../output/temp1",replace



***********************
***AT THE MSA LEVEL
***********************


***housing_data_MSA is residential real estate data from OFHEO at the MSA level

insheet using "../data/housing_data_MSA.txt", tab names clear

***redefine some msacodes to go from div codes to CBSA code (http://www.census.gov/population/estimates/metro-city/0312msa.txt)	
replace msacode	=	14460 if msacode==	14484
replace msacode	=	14460 if msacode==	15764
replace msacode	=	37980 if msacode==	15804
replace msacode	=	16980 if msacode==	16974
replace msacode	=	19100 if msacode==	19124
replace msacode	=	19820 if msacode==	19804
replace msacode	=	19100 if msacode==	23104
replace msacode	=	31100 if msacode==	31084
replace msacode	=	33100 if msacode==	33124
replace msacode	=	35620 if msacode==	35084
replace msacode	=	35620 if msacode==	35644
replace msacode	=	41860 if msacode==	36084
replace msacode	=	37980 if msacode==	37964
replace msacode	=	41860 if msacode==	41884
replace msacode	=	31100 if msacode==	42044
replace msacode	=	42660 if msacode==	42644
replace msacode	=	42660 if msacode==	45104
replace msacode	=	47900 if msacode==	47894
replace msacode	=	33100 if msacode==	48424

***destring MSA level price index 
destring index_msa, force replace
collapse (mean) index_msa msacode, by(msa year)

***store this in temporary file temp2
sort msa year
save "../output/temp2", replace

*****elasticity is a dataset with msa-level elasticities coming from Saez
*****we merge it with temp2
use "../data/elasticity", replace
sort msacode
merge 1:n msacode using "../output/temp2"
drop if _merge==1
drop _merge
drop if msacode==.
sort msacode year
save "../output/temp2", replace

***commercial_price_data gives commercial real estate prices at the msa levels, for some MSAs. SOURCE: GLOBAL REAL ANALYTICS. 
***It is a proprietary dataset that was made available to us by Chris Mayer.
insheet using "../not for diffusion/commercial_price_data.txt", names tab clear
collapse (mean) offprice, by(msacode year)

*** we merge it with temp2
sort msacode year
merge 1:m msacode year using "../output/temp2"
drop if _merge==1
drop _merge

****we normalize price index as 1 in 2006

***index_msa
gen var1=index_msa if year==2006
egen var2=max(var1),by(msacode)
replace index_msa=index_msa/var2
drop var1 var2

***offprice 
gen var1=offprice  if year==2006
egen var2=max(var1),by(msacode)
replace offprice=offprice/var2
drop var1 var2

*** we collapse at the msacode year for the large msas that have several div codes
collapse (mean) offprice elasticity* ee index_msa, by(msacode year)
***we save this in temporary file temp2
sort msacode year
save "../output/temp2",replace

*****WE CREATE A SAMPLE WITH PRICE AND ELASTICITY INFORMATION
*****WE WILL USE THIS SAMPLE IN THE BUBBLE TABLE.
use "../data/msa_fips",replace
gen state=int(fips/1000)
destring msacode, force replace
duplicates drop msacode , force
sort msacode 
merge msacode using "../output/temp2"
drop if _merge==1
drop _merge
sort state year
merge state year using "../output/temp1"
drop _merge
sort state year
save "../output/base_demo",replace

/**************************************************************************************************************/
/************ MERGE COMPUSTAT SAMPLE WITH GEOGRAPHICAL INFORMATION*********************************************/
/**************************************************************************************************************/

***compu_panel is an extract of COMPUSTAT yearly -- available through WRDS.
use  "../not for diffusion/compu_panel",clear

***ren yeara by year to make it consistent with msa and state level datasets
ren yeara year
sort state year

***merge the compustat data with state-level info
merge m:1 state year using  "../output/temp1"
drop if _merge==2
drop _merge

sort fips

***then we merge with a sample that provides msacode/fips conversion
merge m:1 fips using  "../data/msa_fips"
drop if _merge==2
drop _merge
destring msacode, force replace
sort msacode year

***now we can properly merge the msa-level infos with compustat panel using the msacode
merge m:1 msacode year using  "../output/temp2"
drop if _merge==2
drop _merge

/****************************************************************/
/*EXCLUDING FINANCE REAL ESTATE INSURANCE AND MINING INDUSTRY****/
/****************************************************************/

drop if int(dnum/100)==64|int(dnum/100)==65|int(dnum/100)==67|int(dnum/100)==61|int(dnum/100)==62|int(dnum/100)==60|int(dnum/100)==63|int(dnum/100)==49|int(dnum/100)==10|int(dnum/100)==12|int(dnum/100)==13|int(dnum/100)==14|int(dnum/100)==15|int(dnum/100)==17
gen sic2=int(dnum/100)


/****************************************************************/
/**   EXCLUDING FIRMS INVOLVED IN MAJOR ACQUISITION DEAL   	  ***/
/****************************************************************/
gen ind=aftnt1=="AB" if aftnt1~=""
egen IND=max(ind),by(gvkey)
drop if IND==1
drop ind IND

/****************************************************************/
/**Additional screens (cf. Almeida et al. RFS)*******************/
/****************************************************************/

***at least 3 years consecutively in the sample
cap drop temp
egen temp=min(year),by(gvkey)
gen ttemp=(year==temp)|(year==temp+1)|(year==temp+2)
drop temp
egen temp=sum(ttemp),by(gvkey)
keep if temp==3
cap drop  ttemp temp

***no "holes" in a firm life
sort gvkey year
by gvkey: gen temp=year-year[_n-1]
egen ttemp=max(temp),by(gvkey)
keep if ttemp==1
cap drop ttemp temp

***store this in temporary dataset temp
sort gvkey year
save  "../output/temp",replace

/****************************************************************/
/*CREATE MAIN VARIABLES OF INTEREST	*****************************/
/****************************************************************/

****merge with birth_date.dta which is date of entry in COMPUSTAT: censored only befored 1960 
****create age variable
cap drop age 
cap drop birth
sort gvkey year
merge m:1 gvkey using  "../not for diffusion/birth_date"
drop if _m==2
drop _m
gen age=year-birth
***replace age by 33 for firms with missing age (censored for firms entering COMPUSTAT before 1960) 
replace age=33+year-1992 if birth==.

*** data 8 is property plant and equipment
ren data8 ppe
lag ppe

***data6 is total asset
ren data6 asset
***define log of assets
gen lasset=ln(asset)

***capital expenditure
ren data128 capex
lag capex

***short term debt: short term notes and current portion of long term debts due in 1 year 
ren data34 stdebt

***long term debt: debt obligations due more than 1 year from the company’s Balance Sheet
ren data9 ltdebt

***cash holdings: cash and all securities readily transferable to cash as listed in the current asset section.
ren data1 cash_holding

***common_shares: net number of all common shares outstanding at year-end for the annual file
ren data25 common_shares

***common_equity: common shareholders’ interest in the company (Common stock+capital surplus+retained earnings)
ren data60 common_equity

***deferred_taxes:the accumulated tax deferral differences between income tax expense for financial reporting and tax purposes
ren data74 deferred_taxes

***price1: Price - Calendar Year - Close 
ren data24 price

***price2: Price - Fiscal Year - Close
ren data199 price2

***ebitda: Income Before Extraordinary Items 
ren data18 ebitda

***dep_am: Depreciation and Amortization 
ren data14 dep_am

*** Cash-flows from operation: income before extraordinary items and depreciation and amortization (Kaplan&Zingales or Baker, Stein & Wurgler (2003))
gen cash_flow1=(ebitda+dep_am)

***opid: Operating income before depreciation
ren data13 opid

***Operating Activities- Net CF. !!! only defined for firms that report a statement of cash flow !!!
ren data308 op_cash_flows

***Income Before Extraordinary Item- Available for Common Equity
ren data237 income_common

***cash dividend
ren data127 cash_dividend

***stock issuance
ren data108 stock_issue

***short term debt issuance (net)
ren  data301 st_issue

***involved in major acquisition
gen ma=0
replace ma=1 if aftnt1=="AA"|aftnt1=="AB"|aftnt1=="AS"|aftnt1=="FA"|aftnt1=="FB"|aftnt1=="FC" 

***long term debt issuance 
ren  data111 lt_issue

***long term debt reduction 
ren data114 lt_reduction

***int_exp: Interest expense
ren data15 int_exp

***div_common: dividends on common stocks
ren data21 div_common

***share repurchase: Purchase of Common and Pref. Stock (MM../)
ren data115 share_repurchase

***eps: Earnings per Share (Basic) – Excluding Extraordinary Items
ren data58 eps

***income_adj_common: Income Before Extraordinary Items  Adjusted for Common Stock Equivalents
ren data20 income_adj_common


***manufacturing dummy (a firm is in manufacturing if it is always in manuf)
cap drop manuf
gen manuf=dnum>=2000&dnum<=3999 if dnum~=.

cap drop m
egen m=min(manuf),by(gvkey)
cap drop M
egen M=max(manuf),by(gvkey)
gen MANUF= 1 if manuf==1&m==M
replace MANUF=0 if manuf==0|m~=M
drop m M manuf
ren MANUF manuf

***rating 
ren data280 rating

******************************************************************************************************
***********************SOME USEFUL RATIOS*************************************************************
******************************************************************************************************

************************************************
****investment ratios***************************
************************************************

***capex over ppem
gen inv=capex/ppem
clean inv
label var inv "capex/ppem"

***average CAPX over current and next 2 years -- normalized by previous year ppe.
sort gvkey year
quietly by gvkey: gen inv_3year=(capex+capex[_n+1]+capex[_n+2])/(3*ppem) if gvkey[_n+2]==gvkey
clean inv_3year
label var inv_3year "average future capex over 3 years divided by ppem"

****cash-flows
gen cash=cash_flow1/ppem
clean cash

**** Leverage
gen leverage=(stdebt+ltdebt)/asset
clean leverage

************************************************
****measure of the market to book ratios********
************************************************

*** Following Almeida et al. 2007 RFS, or Rauh 2004 JF
gen q=(asset+(price*common_shares)-common_equity-deferred_taxes)/asset
***we lage q to use in investment regression
lag q
clean q
clean qm

************************************************
****two measures of ROA
************************************************

***following Bertrand & Schoar QJE (2003)
gen roa=(opid-dep_am)/asset
clean roa
***operating return on asset
gen op_roa=op_cash_flows/asset
clean op_roa

***dividend payout ratio, from Almeida et al.
gen div_payout=(div_common+share_repurchase)/income_adj_common

************************************************
****capital structure ratios
****because issues are often 0, distribution has more outliers 
****when using the interquartile range rule, 
**** so we use clean2 instead of clean (robust to 1 vs. 5% cutoff)
************************************************

***long term debt issuances
cap drop ltdebt_issuance
gen ltdebt_issuance=lt_issue/ppem
clean2 ltdebt_issuance

***long term debt reduction
cap drop ltdebt_reduction
gen ltdebt_reduction=lt_reduction/ppem
clean2 ltdebt_reduction

***net long term debt issuances
cap drop net_debt
gen net_debt=(lt_issue-lt_reduction)/ppem
clean2 net_debt

***net short term debt issuances
***IMPORTANT : for this variable, missing observations are = to 0 
replace st_issue=0 if st_issue==.
cap drop st_issuance
gen st_issuance=st_issue/ppem
clean2 st_issuance

****long term debt growth rate
sort gvkey year
cap drop deltaltdebt
quietly by gvkey: gen deltaltdebt=(ltdebt-ltdebt[_n-1])/ppem
clean deltaltdebt

***short term debt growth rate
quietly by gvkey: gen deltastdebt=(stdebt-stdebt[_n-1])/ppem
clean deltastdebt

***************************************************
******Real estate data from compustat**************
***************************************************

***buildings: buildings at cost
ren data263 buildings

***land: land and improvements at cost
ren data260 land

***constr_in_progress: construction in progress at cost
ren data266 constr_in_progress

***leases: leases at cost
ren data265 leases

***buildings: buildings : net
ren data155 buildings_net

***land: land and improvements: net
ren data158 land_net

***buildings: accumulated depreciation
ren data253 buildings_accdep

***leases: accumulated depreciation
ren data255 leases_accdep

***fraction of buildings claimed for depreciation
gen prop_dep= buildings_accdep/buildings

*** age of buildings based on 40 years depreciation schedule
gen age_building=int(prop_dep*40)

***rental expenses
ren data47 rental_expenses

*** natural resources at cost
ren data261 natural

*** machines at cost
ren data264 machine

*** other ppe at cost
ren data267 other

*** machine net
ren data156 machine_net

*** natural resources net
ren data157 natural_net

*** leases net
ren data159 leases_net

*** accumulated depreciation on natural resources
ren data252 natural_accdep

***accumulated depreciation on machines
ren data254 machine_accdep

***accumulated depreciation on natural construction
ren data256 constr_accdep

***accumulated depreciation on other PPE
ren data257 other_accdep

***total PPE gross
ren data7 ppe_gross

*** no need for additional COMPUSTAT raw data
drop data*

***************************************************************************************
**************************REAL ESTATE VARIABLES****************************************
***************************************************************************************

***we define total real estate assets (land+buildings+constr_in_progress)
***we start by using a residual approach to maximize number of observations
gen RE_total=ppe_gross-natural-machine-other -leases
***residuals can be <0  because of outliers, we drop these observations (59)
replace RE_total=. if RE_total<-.1
***all values of RE_total below .1 are considered 0 (rounding error -- obvious when plotting distribution of RE_total)
replace RE_total=0 if abs(RE_total)<=.1
***in case residuals are missing and we can define RE_total using some of the real estate item in PPE
replace RE_total=land+buildings+constr_in_progress if RE_total==.&buildings~=.&land~=.&constr_in_progress~=.
replace RE_total=land+buildings if RE_total==.&buildings~=.&land~=.&constr_in_progress==.
replace RE_total=land+constr_in_progress if RE_total==.&buildings==.&land~=.&constr_in_progress~=.
replace RE_total=buildings+constr_in_progress if RE_total==.&buildings~=.&land==.&constr_in_progress~=.
replace RE_total=buildings if RE_total==.&buildings~=.&land==.&constr_in_progress==.
replace RE_total=land if RE_total==.&buildings==.&land~=.&constr_in_progress==.

********************************************************
***IMPORTANT: to get more non-missing data, 
***we attribute a value of 0 to RE_total in 1993 if RE_total is 0 in 1994 and missing in 1993
********************************************************
sort gvkey year
by gvkey: replace RE_total=0 if (RE_total==.&RE_total[_n+1]==0&gvkey[_n+1]==gvkey&year[_n+1]==1994&year==1993)

***define year where "average building" was purchased and then inflate using this date.
gen yearbuy=1993-age_building if year==1993
sort state yearbuy
***adj_price is a sample which contains state level inflation rate using 
***real estate inflation when available or
***state level inflation when not available
merge m:1 state yearbuy using "../data/adj_price"
drop if _m==2
drop _m
sort gvkey year
***store this sample in compu_data
save  "../output/compu_data",replace

***we only keep years after 1993
drop if year<1993

***we drop 2008 (only few observations)
drop if year==2008

***we will not be able to recove real estate value for firms appearing after 1993. We hence suppress them from the sample
egen myear=min(year),by(gvkey)
drop if myear>1993

***define the "square feet" of properties held in 1993
*** i.e. market value of real estate in 1993 divided by price index in 1993
*** we do this for the 3 real estate price indices we have
gen RE_ft_state=(RE_total/(adj93*index_state)) if year==1993
replace RE_ft_state=0 if RE_total==0&year==1993&index_state~=.

gen RE_ft_msa=(RE_total/(adj93*index_msa)) if year==1993
replace RE_ft_msa=0 if RE_total==0&year==1993&index_msa~=.

gen RE_ft_off=(RE_total/(adj93*offprice)) if year==1993
replace RE_ft_off=0 if RE_total==0&year==1993&offprice~=.

***dummy variable equal to 1 if some properties in the first year of appearance in COMPUSTAT
sort gvkey year
by gvkey: gen REAL_ESTATE0=RE_total[1]>0 if RE_total[1]~=.

***RE_value: current market value of 1993 real estate at the state level normalized by ppem historic cost
bysort gvkey: gen RE_value=RE_ft_state[1]*index_state/ppem
clean RE_value

***RE_value_msa: current market value of 1993 real estate at the MSA level normalized by ppem historic cost
bysort gvkey: gen RE_value_msa=RE_ft_msa[1]*index_msa/ppem
clean RE_value_msa

***RE_value_off: current market value of 1993 real estate at the MSA level for offices normalized by ppem historic cost
bysort gvkey: gen RE_value_off=RE_ft_off[1]*offprice/ppem
clean RE_value_off

********************************************************************
***additional ratios using real estate variable
*******************************************************************

***ppe growth minus real estate growth
cap drop inv2
sort gvkey year
by gvkey: gen inv2=(ppe-ppem-(RE_total-RE_total[_n-1]))/ppem
clean inv2

label var inv2 "delta ppe - delta RE over ppe"

******GAN SPECIFICATION: 3 year average capex
cap drop inv3
sort gvkey year
quietly by gvkey: gen inv3=(capex+capex[_n+1]+capex[_n+2])/(3*ppem) if gvkey[_n+2]==gvkey&year[_n+2]==year+2
clean inv3

label var inv3 "next 3 years capex"

***industry-year adjusted capex
****number of firms in the industry
egen n_ind=sum(inv~=.),by(sic2 year)
***average capex/ppem in the industry including the firm
egen inv_ind=mean(inv),by(sic2 year)
***average capex/ppem in the industry excluding the firm
gen benchmark=((inv_ind*n_ind)-inv)/(n_ind-1)
gen inv_adj=inv-benchmark

**********************************************************************************************************
***************Control variables (quintile of asset age, roa) *************************************
**********************************************************************************************************

xtile assetq=asset if year==1993, nq(5)
sort gvkey year
by gvkey: replace assetq=assetq[1]

xtile ageq=age if year==1993, nq(5)
sort gvkey year
by gvkey: replace ageq=ageq[1]

xtile roaq=roa if year==1993, nq(5)
sort gvkey year
by gvkey: replace roaq=roaq[1]

***create dummy variable for these categorical variables
tab ageq, gen(qage)
tab roaq, gen(qroa) 
tab assetq, gen(qasset)
tab sic2, gen(industry)
tab state, gen(st)
tab year, gen(yr)


*** create interaction with office price index
foreach x in qage1 qage2 qage3 qage4 qage5 qasset1 qasset2 qasset3 qasset4 qasset5 qroa1 qroa2 qroa3 qroa4 qroa5 {
cap drop cont3_`x'
gen cont3_`x'=`x'*offprice
}

cap drop cont3_ind*
forvalues i=1(1)56{
gen cont3_ind`i'=industry`i'*offprice
}

cap drop cont3_st*
forvalues i=1(1)53{
gen cont3_st`i'=st`i'*offprice
}

******************************************************************************************************
********************measuring ex ante credit constraints		******************************
******************************************************************************************************
cap drop constraint*

***constraint1= top/bottom third in dividend payment / income
gen constraint1=.
forvalues i=1993(1)2007{
_pctile div_payout if year==`i', nq(10)
replace constraint1=1 if div_payout==0&year==`i'&r(r3)==0
replace constraint1=1 if div_payout<=r(r3)&year==`i'&r(r3)>0&r(r3)!=.
replace constraint1=0 if div_payout>=r(r7)&year==`i'&r(r7)!=.
}


***constraint2: year by year top/bottom third of size as log(assset)
gen constraint2=.
forvalues i=1993(1)2007{
_pctile asset if year==`i', nq(10)
replace constraint2=1 if asset<=r(r3)&year==`i'&r(r3)>0&r(r3)!=.
replace constraint2=0 if asset>=r(r7)&year==`i'&r(r7)!=.
}

***constraint3: rating of debt
gen constraint3=1 if ltdebt>0&rating==.&ltdebt~=.
replace constraint3=0 if ltdebt>0&rating~=.&ltdebt~=.

***defines interaction of constraint with control variables
cap drop const1_cont*
cap drop const2_cont*
cap drop const3_cont*

foreach x in qage1 qage2 qage3 qasset1 qasset2 qasset3 qasset4 qasset5 qroa1 qroa2 qroa3 qroa4 qroa5 {
gen const1_cont3_`x'=constraint1*`x'*offprice
gen const2_cont3_`x'=constraint2*`x'*offprice
gen const3_cont3_`x'=constraint3*`x'*offprice
}

cap drop const1_cont3_ind*
cap drop const2_cont3_ind*
cap drop const3_cont3_ind*

forvalues i=1(1)56{
gen const1_cont3_ind`i'=constraint1*industry`i'*offprice
gen const2_cont3_ind`i'=constraint2*industry`i'*offprice
gen const3_cont3_ind`i'=constraint3*industry`i'*offprice
}

cap drop const1_cont3_st*
cap drop const2_cont3_st*
cap drop const3_cont3_st*
forvalues i=1(1)53{
gen const1_cont3_st`i'=constraint1*st`i'*offprice
gen const2_cont3_st`i'=constraint2*st`i'*offprice
gen const3_cont3_st`i'=constraint3*st`i'*offprice
}


***define cluster at the gvkey constraint level (for significance of regressions split along the constraint dimension)
egen ident1=group(gvkey constraint1)
egen ident2=group(gvkey constraint2)
egen ident3=group(gvkey constraint3)

******************************************************************************************************
********************merge with first stage data				******************************************
******************************************************************************************************
***first_stage data is produced by first_stage.do
sort msacode year
merge m:1 msacode year using  "../output/first_stage"
drop if _m==2
drop _m

***create current value of 1993 real estate assets where prices are instrumented prices
sort gvkey year
forvalues i=1(1)2{
quietly by gvkey: gen RE_value_msa_p`i'=(RE_ft_msa[1]*index_msa[1]/index_msa_p`i'[1])*index_msa_p`i'/ppem
quietly by gvkey: gen RE_value_off_p`i'=(RE_ft_off[1]*offprice[1]/offprice_p`i'[1])*offprice_p`i'/ppem
}

clean RE_value_msa_p1
clean RE_value_msa_p2
clean RE_value_off_p1
clean RE_value_off_p2


*** create interaction with instrumented prices

foreach x in qage1 qage2 qage3 qage4 qage5 qasset1 qasset2 qasset3 qasset4 qasset5 qroa1 qroa2 qroa3 qroa4 qroa5 {
cap drop p_cont3_`x'
gen p_cont3_`x'=`x'*offprice_p1
}

cap drop p_cont3_ind*
forvalues i=1(1)56{
gen p_cont3_ind`i'=industry`i'*offprice_p1
}

cap drop p_cont3_st*
forvalues i=1(1)53{
gen p_cont3_st`i'=st`i'*offprice_p1
}


***defines interaction of constraint with control variables
cap drop p_const1_cont*
cap drop p_const2_cont*
cap drop p_const3_cont*

foreach x in qage1 qage2 qage3 qasset1 qasset2 qasset3 qasset4 qasset5 qroa1 qroa2 qroa3 qroa4 qroa5 {
quietly gen p_const1_cont3_`x'=constraint1*`x'*offprice_p1
quietly gen p_const2_cont3_`x'=constraint2*`x'*offprice_p1
quietly gen p_const3_cont3_`x'=constraint3*`x'*offprice_p1
}

cap drop p_const1_cont3_ind*
cap drop p_const2_cont3_ind*
cap drop p_const3_cont3_ind*

forvalues i=1(1)56{
quietly gen p_const1_cont3_ind`i'=constraint1*industry`i'*offprice_p1
quietly gen p_const2_cont3_ind`i'=constraint2*industry`i'*offprice_p1
quietly gen p_const3_cont3_ind`i'=constraint3*industry`i'*offprice_p1
}

cap drop p_const1_cont3_st*
cap drop p_const2_cont3_st*
cap drop p_const3_cont3_st*


forvalues i=1(1)53{
quietly gen p_const1_cont3_st`i'=constraint1*st`i'*offprice_p1
quietly gen p_const2_cont3_st`i'=constraint2*st`i'*offprice_p1
quietly gen p_const3_cont3_st`i'=constraint3*st`i'*offprice_p1
}

******************************************************************************************************
********************final adjustment to create database			******************************
******************************************************************************************************

***drop observations with missing real estate data
drop if RE_value==.

***clustering levels
egen id=group(state year)
label var id "state year cluster"

egen id2=group(msa year)
label var id2 "msa year cluster"

duplicates drop gvkey year, force 
sort msacode
save  "../output/temp",replace


***add population in area from 2000 census
insheet using "../data/population.txt", names tab clear
replace population=subinstr(population,",","",.)
destring population, force replace
gsort -population
gen largemsa=_n<=20
duplicates drop msacode, force 
sort msacode

***dataset_final_public is generated by construc_public
merge 1:m msacode using "../output/temp"
drop if _m==1
drop _m


***2 observations are duplicated
duplicates drop gvkey year, force
tsset gvkey year

***save this dataset in dataset_final.dta
sort gvkey year
save  "../output/dataset_final", replace


************************************************************************************************
********WE ALSO CREATE A DATASET WITH FIRMS STARTING AFTER 1993 (SURVIVORSHIP BIAS)*************
************************************************************************************************
*** we start from compu_data, created above
use  "../output/compu_data", clear
***dummy variable equal to 1 if some properties in the first year of appearance in COMPUSTAT
***note that for this sample, we can't compute RE value
*** which is why we just compute the dummy
sort gvkey year
by gvkey: gen REAL_ESTATE0=RE_total[1]>0 if RE_total[1]~=.

***control variables in quintile -- note that because of non-balanced sample, we need to take first year quintile
***rather than quintile for 1993
egen assetq=xtile(asset), by(year) nq(5)
sort gvkey year
quietly by gvkey: replace assetq=assetq[1]

egen ageq=xtile(age), by(year) nq(5)
sort gvkey year
by gvkey: replace ageq=ageq[1]

egen roaq=xtile(roa), by(year) nq(5)
sort gvkey year
by gvkey: replace roaq=roaq[1]

tab year, gen(yr)
egen id=group(state year)

egen id2=group(msa year)
label var id2 "msa year cluster"

drop if year<1993
egen myear=min(year),by(gvkey)

****merge with instrumented prices
sort msacode year
merge m:1 msacode year using  "../output/first_stage"
drop if _m==2
drop _m

***duplicated observations
duplicates drop gvkey year, force
tsset gvkey year

****save this in unbalanced.dta
sort gvkey year
save  "../output/unbalanced", replace

cap erase  "../output/temp.dta"
cap erase  "../output/temp1.dta"
cap erase  "../output/temp2.dta"

****COMMENT: there are more observations in 1994 than in 1993 because ppem is more often 0 in 1993 than in 1994 


