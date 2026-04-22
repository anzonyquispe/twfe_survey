* Stata do file for results in "State Misallocation and Housing Prices: Theory and Evidence from China" 

use data_aersubmit.dta

***			***
*** Table 2 ***
***			***

* estimate the degree of mismatch

sort hhidc year id
* Table 2, Column 1
xi: regress logapt_rentval logwage_broadhh_ logtot_assets age_head age_head2 age_head3 eduyr_head i.province*i.year if year<=1993 & apt_nonmrkt==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), cluster(hhidc)
predict pred_logapt_rentval if year<=1993 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), xb

* Table 2 Column 2
xi: regress logapt_rentval logwage_broadhh_ logtot_assets  age_head age_head2 age_head3 eduyr_head i.province*i.year if year>1993 & apt_nonmrkt93==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), cluster(hhidc)
predict postpred_logapt_rentval if year>1993 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), xb

gen log_mismatch_post = postpred_logapt_rentval - logapt_rentval
gen log_mismatch = pred_logapt_rentval - logapt_rentval  

***			***
*** Table 3 ***
***			***

* Table 3 Column 1 *
sum log_mismatch if apt_nonmrkt==1
sum log_mismatch if apt_nonmrkt==0
regress log_mismatch apt_nonmrkt 

* Table 3 Column 2 *
sum log_mismatch_post if apt_nonmrkt93==1
sum log_mismatch_post if apt_nonmrkt93==0
regress log_mismatch_post apt_nonmrkt93 

gen mpre = log_mismatch if year<=1993

bysort hhidc: egen log_mismatchpre = mean(mpre)
gen mpre_aptnon = log_mismatch if year<=1993 & apt_nonmrkt==1
bysort province: egen log_mismatchpre_prov = mean(mpre_aptnon)

bysort province year: egen logapt_rentval_prov = mean(logapt_rentval)
drop mpre* 

sort hhidc year id


***		    ***
*** Table 4 ***
***			***


gen abs_mismatch = abs(log_mismatchpre)

* Table 4, Column 1
xi:dprobit move_attrit abs_mismatch age_head age_head2 eduyr_head i.year i.province if hhidc==hhidc[_n-1] & year!=year[_n-1] & apt_nonmrkt[_n-1]==1 & regime2==0,cluster(hhidc)  vce(bootstrap, reps(200))

* Table 4, Column 2
xi:dprobit move_attrit abs_mismatch age_head age_head2 eduyr_head i.year i.province if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt93==1 & regime2==1,cluster(hhidc) vce(bootstrap, reps(200))



***			***
*** Table 5 ***
***			***

* Table 5 Column 1 
xi: regress logapt_sqm i.regime2*log_mismatchpre  logwage_broadhh logtot_assets  age_head age_head2 age_head3 eduyr_head  i.province*i.year if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt93==1, cluster(hhidc) vce(bootstrap, reps(200))

tab year, gen(yrdum)
gen log_mismatchpre_1991 = log_mismatchpre*yrdum2
gen log_mismatchpre_1993 = log_mismatchpre*yrdum3
gen log_mismatchpre_1997 = log_mismatchpre*yrdum4
gen log_mismatchpre_2000 = log_mismatchpre*yrdum5
gen log_mismatchpre_2004 = log_mismatchpre*yrdum6

* Table 5 Column 2
xi: regress logapt_sqm log_mismatchpre_1991 log_mismatchpre_1993 log_mismatchpre_1997  log_mismatchpre_2000 log_mismatchpre_2004 log_mismatchpre logwage_broadhh logtot_assets  age_head age_head2 age_head3 eduyr_head i.province*i.year if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt93==1, cluster(hhidc) vce(bootstrap, reps(200))


* Table 5 Columns 3-10
foreach var in apt_toiletin apt_water_house apt_electric no_excreta {
	xi: regress `var' i.regime2*log_mismatchpre  logwage_broadhh logtot_assets  age_head age_head2 age_head3 eduyr_head i.province*i.year if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt93==1, cluster(hhidc) vce(bootstrap, reps(200))
	xi: regress `var' log_mismatchpre_1991 log_mismatchpre_1993 log_mismatchpre_1997  log_mismatchpre_2000 log_mismatchpre_2004 log_mismatchpre  logwage_broadhh logtot_assets  age_head age_head2 age_head3 eduyr_head i.province*i.year if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt93==1, cluster(hhidc) vce(bootstrap, reps(200))
}

***			***
*** Table 6 ***
***			***

gen reg2_mismatch = regime2*log_mismatchpre_prov

* Table 6 Column 1
xi: areg logworth_persqm reg2_mismatch i.year apt_toiletin apt_electric no_excreta apt_water_house i.apt_age i.apt_watersource if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt!=1, absorb(hhidc) cluster(province) vce(bootstrap, reps(200))
* Table 6 Column 2
xi: areg logworth_persqm i.year*log_mismatchpre_prov apt_toiletin apt_electric no_excreta apt_water_house i.apt_age i.apt_watersource if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt!=1, absorb(hhidc) cluster(province) vce(bootstrap, reps(200))
* Table 6 Column 3
xi: areg logworth_persqm reg2_mismatch i.year apt_toiletin apt_electric no_excreta apt_water_house i.apt_age i.apt_watersource reg2_loggdp93 reg2_logpop93  if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt!=1, absorb(hhidc) cluster(province) vce(bootstrap, reps(200))
* Table 6 Column 4
xi: areg logworth_persqm i.year*log_mismatchpre_prov apt_toiletin apt_electric no_excreta apt_water_house i.apt_age i.apt_watersource yrd*_log*  if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt!=1, absorb(hhidc) cluster(province) vce(bootstrap, reps(200))


***		 	***
*** Table 7 ***
***			***
xi: regress apt_rentval wage_broadhh tot_assets  age_head age_head2 age_head3 eduyr_head i.province*i.year if apt_nonmrkt==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), cluster(hhidc)


***		 	***
*** Table 8 ***
***			***
local alpha0 = 1- _b[wage_broadhh] 
gen add_up0=.
foreach var in  tot_assets  age_head age_head2 age_head3 eduyr_head _Iprovincea23 _Iprovincea32 _Iprovincea37 _Iprovincea41 _Iprovincea42 _Iprovincea43 _Iprovincea45 _Iprovincea52 _Iyear_1991 _Iyear_1993 _Iyear_1997 _Iyear_2000 _Iyear_2004  _IproXyea_23_1991 _IproXyea_23_1993 _IproXyea_23_1997 _IproXyea_23_2000 _IproXyea_23_2004 _IproXyea_32_1991 _IproXyea_32_1993 _IproXyea_32_1997 _IproXyea_32_2000 _IproXyea_32_2004 _IproXyea_37_1991 _IproXyea_37_1993 _IproXyea_37_1997 _IproXyea_37_2000 _IproXyea_37_2004 _IproXyea_41_1991 _IproXyea_41_1993 _IproXyea_41_1997 _IproXyea_41_2000 _IproXyea_41_2004 _IproXyea_42_1991 _IproXyea_42_1993 _IproXyea_42_1997 _IproXyea_42_2000 _IproXyea_42_2004 _IproXyea_43_1991 _IproXyea_43_1993 _IproXyea_43_1997 _IproXyea_43_2000 _IproXyea_43_2004 _IproXyea_45_1991 _IproXyea_45_1993 _IproXyea_45_1997 _IproXyea_45_2000 _IproXyea_45_2004 _IproXyea_52_1991 _IproXyea_52_1993 _IproXyea_52_1997 _IproXyea_52_2000 _IproXyea_52_2004  _cons {
	replace add_up0 = `var'*_b[`var']
}


* Separating Prices and Quantities  
gen price = .
gen province_year = province*10000+year

foreach yy in 1989 1991 1993 1997 2000 2004 {
	foreach xx in 21 23 32 37 41 42 43 45 52 {
		gen _Iprovince__`xx'`yy'=.
	}
}
sort hhidc year id   
xi: areg logapt_rentval  logapt_sqm i.apt_age apt_electric no_excreta apt_water_house apt_toiletin i.apt_watersource i.province_year if apt_nonmrkt==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), absorb(hhidc) cluster(hhidc) 
predict resid, residuals
predict quantity, xb

foreach var of varlist  _Iprovince_a* {
	local last = substr("`var'", -6, 6)
	drop _Iprovince__`last'
	rename  _Iprovince_a`last'  _Iprovince__`last'  
} 

foreach yy in 1989 1991 1993 1997 2000 2004 {
	foreach xx in 21 23 32 37 41 42 43 45 52 {
		sum _Iprovince__`xx'`yy' 
		local hold = r(mean) 
		if `hold' !=. {
			xi: qui areg logapt_rentval  logapt_sqm i.apt_age apt_electric no_excreta apt_water_house apt_toiletin i.apt_watersource i.province_year if apt_nonmrkt==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), absorb(hhidc) cluster(hhidc) 
			replace price =  _b[_Iprovince_a`xx'`yy']*_Iprovince_a`xx'`yy' if year==`yy' & province==`xx'
			replace quantity = quantity - _b[_Iprovince_a`xx'`yy']&_Iprovince_a`xx'`yy' if year==`yy' & province==`xx' 
		}
	}
}
gen pos_price = exp(price)

gen quantity_housing = apt_rentval / pos_price 

replace quantity = quantity + resid

* now done with separation

gen utility_undersubs_pre3 = ((wage_broadhh - apt_rentval + add_up0 )^`alpha0') *(quantity_housing^(1-`alpha0')) if year<=1993 

xi: regress apt_rentval wage_broadhh tot_assets  age_head age_head2 age_head3 eduyr_head i.province*i.year if apt_nonmrkt==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1]), cluster(hhidc)

gen ph_optimal = _b[wage_broadhh]*(wage_broadhh+rent_subsidy_amt) + add_up0
gen h_optimal = ph_optimal / pos_price

gen utility_cashtransfer_pre3 = ((wage_broadhh + rent_subsidy_amt -ph_optimal + add_up0 )^`alpha0') *(h_optimal^(1-`alpha0')) if year<=1993 

gen utility_post3 = ((wage_broadhh - apt_rentval + add_up0 )^`alpha0') *(quantity_housing^(1-`alpha0')) if year>1993 


gen holder = wage_broadhh if year==1993
gen holdd = rent_subsidy_amt if year==1993
bysort hhidc: egen wage_broadhhpre = mean(holder)
bysort hhidc: egen rent_subsidy_pre = mean(holdd)
drop holder holdd


gen ph_oldwage = _b[wage_broadhh]*(wage_broadhhpre+rent_subsidy_pre) + add_up0
gen h_oldwage = ph_oldwage / pos_price



gen utility_constincm_post3 = ((wage_broadhhpre - ph_oldwage + add_up0)^`alpha0') *(h_oldwage^(1-`alpha0')) if year>1993 

sort hhidc year id 
* table 8 row 1: comparing utility of pre-reform state residents with housing allotment 
sum utility_undersubs_pre3  if apt_nonmrkt==1  & (hhidc!=hhidc[_n-1] | year!=year[_n-1])
* counterfactual
sum utility_cashtransfer_pre3  if apt_nonmrkt==1  & (hhidc!=hhidc[_n-1] | year!=year[_n-1])
tabstat utility_post3 if (hhidc!=hhidc[_n-1] | year!=year[_n-1]), by(apt_nonmrkt93)

* table 8 row 2 
sum utility_undersubs_pre3 if apt_nonmrkt==0 & (hhidc!=hhidc[_n-1] | year!=year[_n-1])

* table 8 row 3: compare total utility of all residents pre-reform 
sum utility_undersubs_pre3 if (hhidc!=hhidc[_n-1] | year!=year[_n-1])
* with utility of all residents post-reform
sum utility_post3 if (hhidc!=hhidc[_n-1] | year!=year[_n-1])



***					 ***
*** Appendix Table 1 ***
***					 ***

sort hhidc year id

* AppendixTable 1 Column 1 
xi: regress logapt_rentval logapt_sqm i.apt_age apt_electric no_excreta apt_water_house apt_toiletin i.apt_watersource i.year i.province if hhidc!=hhidc[_n-1] | year!=year[_n-1], cluster(hhidc)

* AppendixTable 1 Column 2
xi: regress logapt_rentval logapt_sqm i.apt_age apt_electric no_excreta apt_water_house apt_toiletin i.apt_watersource i.year i.province if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt==0, cluster(hhidc)

* AppendixTable 1 Column 3
xi: regress logapt_rentval logapt_sqm i.apt_age apt_electric no_excreta apt_water_house apt_toiletin i.apt_watersource i.year i.province if (hhidc!=hhidc[_n-1] | year!=year[_n-1]) & apt_nonmrkt==1, cluster(hhidc)


