clear mata
clear matrix
clear
set more 1
set mem 1500m
set mat 800

cap log close

*set program directory
cd "/Users/Thomas/Desktop/CollateralChannel/progs"

***This program generates Table 5 of "The Collateral Channel" by Chaney et al. as well as some of the 
***descriptive statistics in Table 1
***it also produces first_stage.dta, which is used in the main analysis.


****************************************************************************
*************** building IV data *******************************************
****************************************************************************


***data on mortgage rate & inflation by quarter
insheet using "../data/interest.txt", names tab clear
replace inflation=subinstr(inflation,",",".",.) 
destring inflation, replace
replace mortgage=subinstr(mortgage,",",".",.)
destring mortgage, replace
gen year=real(substr(date,1,4))
gen month=real(substr(date,6,2))
drop date
gen quarter=1+(month>3)+(month>6)+(month>9)

***data collapsed at the year level
collapse (mean) mortgage inflation,by(year )
sort year 
***save in temporary file temp.
save "../output/temp", replace 


***data on housing prices & housing supply restriction at the MSA level

insheet using "../data/housing_data_MSA.txt", tab names clear

***correct the msacode for big cities (div code for CBSA code)
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

***index_msa is originally in string because of missing data
destring index_msa, force replace

***data collapsed at the year MSA level (initially by quarter)
collapse (mean) index_msa msacode, by(msa year)

sort msacode year
save "../output/temp2", replace

*****elasticity is a dataset with msa-level elasticities coming from saez
use "../data/elasticity", replace
sort msacode
merge 1:n msacode using "../output/temp2"
drop if _merge==1
drop _merge
drop if msacode==.
sort msacode year
save "../output/temp2", replace

***commercial_price_data gives commercial real estate prices at the msa levels, for some MSAs. Comes from Mayer (industrial analytics).
insheet using "../not for diffusion/commercial_price_data.txt", names tab clear
collapse (mean) offprice indprice, by(msacode year)
sort msacode year
merge 1:n msacode year using "../output/temp2"
drop if _merge==1
drop _merge
sort msacode year
save "../output/temp2",replace


***merge with data on mortgage rates & inflation
sort year
merge m:1 year using "../output/temp"
drop if _m==2
drop _m

***we normalize office and MSA prices to be 1 in 2006
cap drop var1 
cap drop var2
gen var1=offprice if year==2006
egen var2=max(var1),by(msacode)
replace offprice=offprice/var2

cap drop var1 
cap drop var2
gen var1=index_msa if year==2006
egen var2=max(var1),by(msacode)
replace index_msa =index_msa /var2

***create real estate price growth rates for summary statistics
sort msa year
quietly by msa: gen g_indmsa=(index_msa-index_msa[_n-1])/index_msa[_n-1]
clean g_indmsa

quietly by msa: gen g_offprice=(offprice-offprice[_n-1])/offprice[_n-1]
clean g_offprice

***only interested in predicting price from 1993 on (to match COMPUSTAT sample)
keep if year>=1993

*** 30 years mortgage rates are adjusted for inflation
replace mortgage=mortgage-inflation

***save this in general log
cap log close
log using "../output/reg.log",replace

****create first instrument (inter) and predict prices (MSA and office)
cap drop inter
gen inter=elasticity*mortgage
clean inter

xi: areg index_msa inter  mortgage i.year,a(msa) cl(msa)
estimates store FS1_1
predict index_msa_p1,xbd

xi: areg offprice inter  mortgage i.year,a(msa) cl(msa)
estimates store FS1_2
predict offprice_p1,xbd


****using quartile of elasticity rather than continuous variable
tab ee, gen(ee_)
forvalues i=1(1)4{
gen inter_`i'=ee_`i'*mortgage
}

xi: areg index_msa inter_1 inter_2 inter_3 mortgage ee_* i.year,a(msa) cl(msa)
estimates store FS2_1
predict index_msa_p2,xbd

test inter_1=inter_2=inter_3=0

xi: areg offprice inter_1 inter_2 inter_3  mortgage ee_* i.year,a(msa) cl(msa)
estimates store FS2_2
predict offprice_p2,xbd

test inter_1=inter_2=inter_3=0

****First stage table: using MSA prices and office prices
estout FS1_1 FS2_1 FS1_2 FS2_2, cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(inter inter_1 inter_2 inter_3 ) stats(N ar2) starlevels(* 0.104 ** 0.054 *** .014) delimiter(&) end(\\) label style(tex)


***descriptive statistics at the city level
tabstat index_msa offprice g_indmsa g_offprice elasticity, stats(mean median sd p25 p75 n)

log close

erase "../output/temp.dta"
erase "../output/temp2.dta"

***collapse at msacode year level
collapse (mean) index_msa_p* offprice_p*, by(msacode year)

***store in first_stage.dta
sort msacode year
save "../output/first_stage",replace



