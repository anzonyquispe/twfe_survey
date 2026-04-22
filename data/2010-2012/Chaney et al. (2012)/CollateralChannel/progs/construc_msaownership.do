
****This program creates msaownership.dta
****this sample is used in the main regression analysis
****it defines msaownership in 1997 from 10k information and not from compustat
****it is merged with COMPUSTAT for years >=1997.
clear 
clear matrix
clear mata
set more 1
set mem 900m
cap log close

**** we start from headquarter_1997, which has headquarter ownership information for the 1997 cross-section
use "../data/headquarter_1997", replace
********define city variable to be able to merge with fips
gen cityname2=lower(cityofprop)+", "+ lower(stateofprop) 
sort cityname2
save "../output/temp2",replace

****merge with zip2 to retrieve fips
insheet using "../data/zip2.csv", comma names clear
gen cityname2=lower(cityaliasmixedcase)+", "+ lower(state)
duplicates drop cityname2 state, force 
sort cityname2
merge 1:m cityname2 using "../output/temp2"

****merge to get msacode
keep if _m==3
drop _m
gen fips=statefips*1000+countyfips
sort fips
save "../output/temp2",replace

use "../data/msa_fips",replace
sort fips
merge 1:m fips using "../output/temp2"
drop _m
destring msacode, force replace
sort gvkey 
save "../output/temp2",replace

***keep firms with only 1 headquarters
egen n=sum(1),by(gvkey)
keep if n==1

collapse (max) owner_10k msacode,by(gvkey)

**** we expand the dataset so that it has the firm-year format. where years go from 1993 to 2007
destring msacode, force replace
sort msacode
gen ident=_n
expand 15
sort ident
quietly by ident: gen year=_n+1992
***temp2 is gvkey/year sample of owner_10k and relevant msacode
sort msacode year
save "../output/temp2", replace
*****************************************************************************************************
****Take the dataset with commercial real estate prices
*****************************************************************************************************
insheet using "../not for diffusion/commercial_price_data.txt", names tab clear
collapse (mean) offprice ,by(msacode year)
sort msacode year
***we construct offprice index which is an index of real estate price at the MSA level
cap drop var1
gen var1=offprice  if year==2006
cap drop var2
egen var2=max(var1),by(msacode)
gen offprice_index=offprice/var2
drop var1 var2

*****************************************************************************************************
********************merge with first stage data				******************************
******************************************************************************************************
sort msacode year
merge 1:1 msacode year using "../output/first_stage"
drop if _m==2
drop _m

*****************************************************************************************************
********************merge with temp2. gvkey/year sample of owner_10k and relevant msacode ************
******************************************************************************************************
merge 1:m msacode year using "../output/temp2"
drop if _m==1
drop _m

sort gvkey year
***save as local
save "../output/local", replace

*****************************************************************************************************
********************Construc compustat sample to merge with 10k ownership and price data ************
******************************************************************************************************

use "../output/compu_data",replace

***we drop 2008 (only few observations)
drop if year==2008

drop offprice* msacode

***We want to match with 10K info retrieved for the 1997 cross-section. We thus keep firms that are created before 1997
egen myear=min(year),by(gvkey)
drop if myear>1997
**********************************************************************************************************
***************We now restrict the sample to firms after 1997 		**************************************
**********************************************************************************************************
keep if year>=1997

**********************************************************************************************************
***************INITIAL REAL ESTATE HOLDING		 *******************************
**********************************************************************************************************
sort gvkey year
quietly by gvkey: gen REAL_ESTATE0=RE_total[1]
gen owner_compu=REAL_ESTATE0>0 if REAL_ESTATE0~=.

**********************************************************************************************************
***************Control variables (quintile of asset age, roa and leverage) *******************************
**********************************************************************************************************

xtile assetq=asset if year==1997, nq(5)
sort gvkey year
by gvkey: replace assetq=assetq[1]

xtile ageq=age if year==1997, nq(5)
sort gvkey year
by gvkey: replace ageq=ageq[1]

xtile roaq=roa if year==1997, nq(5)
sort gvkey year
by gvkey: replace roaq=roaq[1]


***create dummy variable for these categorical variables
tab ageq, gen(qage)
tab roaq, gen(qroa) 
tab assetq, gen(qasset)
tab sic2, gen(industry)
tab state, gen(st)
tab year, gen(yr)


*****************************************************************************************************
********************merge with local, 10k info sample					******************************
******************************************************************************************************
duplicates drop gvkey year, force 
sort gvkey year
merge 1:1  gvkey year using "../output/local"
drop if _m==2
drop _m

***clustering levels
egen id=group(msa year)
label var id "msa year cluster"

sort gvkey year
save  "../output/msaownership",replace

erase "../output/temp2.dta"
erase "../output/local.dta"

