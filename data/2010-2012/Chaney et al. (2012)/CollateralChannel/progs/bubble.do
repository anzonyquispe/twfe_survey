clear
clear mata
clear matrix
set mem 1g

****we first retrieve the msacode for the headquarter ownership information contained in headquarter_2000
use "../data/headquarter_2000",replace
********define city variable to be able to merge with fips
gen cityname2=lower(cityofprop)+", "+ lower(stateofprop) 
sort cityname2
save "../output/temp2",replace

****merge with zip2 to retrieve fips
insheet using "../data/zip2.csv", comma names clear
gen cityname2=lower(cityaliasmixedcase)+", "+ lower(state)
***for a given cityname2, we keep the county code with the most appearances
cap drop n_alias
egen n_alias=sum(1),by(cityname2 countyfips)
cap drop N_alias
egen N_alias=max(n_alias), by(cityname2)
keep if n_alias==N_alias
drop n_alias N_alias
duplicates drop cityname2 state, force 
sort cityname2
merge 1:m cityname2 using "../output/temp2"

****merge with msa_fips to get msacode
keep if _m==3
drop _m
gen fips=statefips*1000+countyfips
sort fips
save "../output/temp2",replace

use "../data/msa_fips",replace
sort fips
merge 1:m fips using "../output/temp2"
keep if _m==3
drop _m
destring msacode, force replace
sort msacode year
save "../output/temp",replace


**** merge with base_demo to get elasticity of land supply  and compute msa level price growth.
use offprice elasticity msacode year using "../output/base_demo",replace
sort msacode year
***price growth between 2000 and 2006
quietly by msacode: gen dprice=offprice - offprice[_n-6] if year==2006&msacode==msacode[_n-6]&year[_n-6]==2000
sort msacode year
keep if year==2006
sort msacode

***merge with temp to obtain combined dataset with RE prices, elasticity, headquarter ownership.
merge 1:m msacode using "../output/temp"
drop if _m==1
drop _m
sort gvkey msacode
sort gvkey 
save "../output/temp",replace

***merge with msacode info from compustat to help in the selection process of multi-headquarter firms.
*** when there are multiple headquarters, we keep only those located in COMPUSTAT headquarter's MSA.
use gvkey year msacode  using "../output/compu_data",replace
keep if year==2001|year==2002|year==2000
keep gvkey msacode 
duplicates drop gvkey msacode, force
ren msacode msacode_compu
sort gvkey
merge 1:m gvkey using "../output/temp"
drop if _m==1
drop _m
***samemsa is a dummy equal to 1 if 10k msa= compustat msa
gen samemsa=msacode==msacode_compu if msacode~=.
***n is number of headquarter per firm.
egen n=sum(headquarter),by(gvkey)
***dum is dummy variable for headquarters that have same compustat and 10k msa
gen dum=headquarter==1&samemsa==1
***nn is the number of buildings that have dum=1
egen nn=sum(dum),by(gvkey)

****SELECTION of headquarters in case of multiple headquarter ownership
**** we keep headquarters when there is only one headquarter
**** or when there is only one headquarter located in the compustat msa
keep if (n==1&headquarter==1)|(nn==1&n>1&n~=.&dum==1)

***keep only relevant information
ren msacode msacode_10k
keep gvkey owner_hq msacode_10k elasticity* areaof dprice  
sort gvkey
save "../output/temp", replace

***************************************************************************************
************************CONSTRUCT ADEQUATE COMPUSTAT SAMPLE ********************** 
***************************************************************************************

***start from COMPUSTAT sample
use gvkey year ppe asset ppem capex ltdebt stdebt msacode using  "../output/compu_data",replace

***keep only data from 2000 to 2006.
keep if year>=2000
keep if year<=2006
duplicates drop gvkey year, force
sort gvkey year
***merge with our sample of headquarter info and RE prices.
merge m:1 gvkey  using "../output/temp"
keep if _m==3
sort gvkey year

egen n_capex=sum(capex~=.),by(gvkey)

****aggregate capex over the period =cumulative sum of CAPEX over the years
cap drop scapex
egen scapex=sum(capex),by(gvkey)
cap drop CAP
*** CAP is aggregate capex over initial asset
sort gvkey year
quietly by gvkey: gen CAP=scapex/asset[1] if year[1]==2000
clean CAP
*** lasset0 is log(initial asset)
cap drop lasset0
quietly by gvkey: gen lasset0=ln(asset[1])

*** quart are quartile of land supply elasticity
cap drop quart
xtile quart=elasticity if year==2006, nq(4)
***ddebt is increase in debt normalized by asset
cap drop ddebt
quietly by gvkey: gen ddebt=(ltdebt+stdebt-ltdebt[1]-stdebt[1])/(asset[1]) if year[1]==2000
clean ddebt

***dasset is increase in debt normalized by asset
cap drop dasset
quietly by gvkey: gen dasset=(asset-asset[1])/(asset[1]) if year[1]==2000
clean dasset

****interaction terms
cap drop q_quart*
tab quart, gen(q_quart)
forvalues i=1(1)4{
cap drop inter`i'
gen inter`i'=q_quart`i'*owner_hq
}
cap drop inter_price
gen inter_price=owner_hq*dprice
cap drop inter_elast
gen inter_elast=owner_hq*elasticity
drop _m

***make a temporary save -- will reuse this sample when making the graphs.
sort msacode year
save "../output/temp2",replace

log using "../output/reg.log", append


**************************************************************************
***************************REGRESSION ANALYSIS: BUBBLE *******************
**************************************************************************

xi: reg CAP inter_price owner_hq dprice if year==2006&n_capex==7,cl(msacode_10k)
estimates store A1
xi: reg CAP inter_elast owner_hq elasticity if year==2006&n_capex==7,cl(msacode_10k)
estimates store A2
xi: reg CAP inter_elast owner_hq elasticity lasset0 if year==2006&n_capex==7,cl(msacode_10k)
estimates store A3
xi: reg CAP inter2 inter3 inter4 owner_hq q_quart2 q_quart3 q_quart4 lasset0 if year==2006&n_capex==7,cl(msacode_10k)
estimates store A4

xi: reg ddebt inter_price owner_hq dprice if year==2006,cl(msacode_10k)
estimates store B1
xi: reg ddebt inter_elast owner_hq elasticity  if year==2006,cl(msacode_10k)
estimates store B2
xi: reg ddebt inter_elast owner_hq elasticity lasset0 if year==2006,cl(msacode_10k)
estimates store B3
xi: reg ddebt inter2 inter3 inter4 owner_hq q_quart2 q_quart3 q_quart4 lasset0 if year==2006,cl(msacode_10k)
estimates store B4

estout A1 A2 A3 A4 B1 B2 B3 B4, cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(inter_price inter_elast inter2 inter3 inter4 q_quart4 q_quart2 q_quart3 dprice elasticity lasset0 ) stats(N r2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)

log close


**************************************************************************
******************** BUBBLE GRAPHS ***************************************
**************************************************************************

***first we re-normalize RE price to 1 in 2000
use offprice msacode year using "../output/base_demo", clear
cap drop temp
gen temp=offprice if year==2000
egen offprice2000=max(temp),by(msacode)
replace offprice=offprice/offprice2000
keep offprice msacode year

***then we merge this with our firm-level dataset of firms with 2000 headquarter ownership info
sort msacode year
merge 1:m msacode year using  "../output/temp2"

***extend the definition of elasticity quartiles to pre-2006 years
gsort gvkey -quart 
quietly by gvkey: replace quart=quart[1]

***define initial asset
sort gvkey year
quietly by gvkey: gen asset2000=asset[1] if year[1]==2000

***define cumulative sum of firm-level capex.
cap drop CAP
sort gvkey year
quietly by gvkey: gen CAP=0 if year==2000
quietly by gvkey: replace CAP=(capex+CAP[_n-1]) if year>2000

***normalize by initial assets
replace CAP=CAP/asset2000 if year>2000
clean CAP

***ddebt is already increase in debt normalized by initial asset
***we average ddebt and CAP at the year - quartile of elasticity - owner/renter level
collapse (mean) ddebt CAP offprice, by(year quart owner_hq)

***difference out renter minus owner for increase in debt and cumulative capex
sort quart year owner_hq 
quietly by quart year: gen Ddebt=ddebt-ddebt[_n-1] if owner_hq==1&owner_hq[_n-1]==0&quart[_n-1]==quart
quietly by quart year: gen DCAP=CAP-CAP[_n-1] if owner_hq==1&owner_hq[_n-1]==0&quart[_n-1]==quart

twoway (line DCAP year if quart==1, ylabel(-.04(.02).08) legend(label(1 "Low Elasticity MSA")  subtitle(relative accumulated capex (owner vs. renter))) )   (line DCAP year if quart==4, ylabel(-.04(.02).08) legend(label(2 "High Elasticity MSA"))  ) , ytitle(Relative Accumulated Capex) 
***relative capex graph
graph export "../output/capex_relative_graph.pdf", replace 
***relative debt graph
twoway (line Ddebt year if quart==1, ylabel(-.04(.02).08) legend(label(1 "Low Elasticity MSA")  subtitle(relative debt growth (owner vs. renter))) )   (line Ddebt year if quart==4, ylabel(-.04(.02).08) legend(label(2 "High Elasticity MSA"))  ) , ytitle(Relative Debt Growth) 
graph export "../output/debt_relative_graph.pdf", replace 

****price graph
collapse (mean) offprice, by(quart year)
twoway (line offprice year if quart==1,ylabel(0.9(.1)1.6) legend(label(1 "Low elasticity")  ) )   (line offprice year if quart==4, ylabel(0.9(.1)1.6) legend(label(2 "High Elasticity"))  ) , ytitle(MSA office prices) 
graph export "../output/price_graph.pdf", replace 


erase  "../output/temp2.dta"
erase  "../output/temp.dta"


