** GetPredicted.do
	* This gets jackknifed predicted values of variables at the state level to construct the instrument
	* Due the the years, this works only for LGBR variables - req and avail
	* Chhattisgarh begins in 2001, but Uttaranchal and Jharkhand begin in 2002

bysort year: egen Nationalreq=sum(req)
gen RestofIndia = Nationalreq-req
gen State_RestofIndia = req/RestofIndia
bysort state: egen meanState_RestofIndia = mean(State_RestofIndia)
bysort state: egen meanState_RestofIndia_pre2000 = mean(State_RestofIndia) if year<=2000
bysort state: egen meanState_RestofIndia_post2001 = mean(State_RestofIndia) if year>=2001
	bysort state: egen meanState_RestofIndia_pre2001 = mean(State_RestofIndia) if year<=2001
	bysort state: egen meanState_RestofIndia_post2002 = mean(State_RestofIndia) if year>=2002

* for state that do not split, use the average across all years
gen Predreq_comb = meanState_RestofIndia * RestofIndia

* for states that do split, use the average for the relevant years
	* Ch begins in 2001 
replace Predreq_comb = cond(year>=2001,meanState_RestofIndia_post2001*RestofIndia,meanState_RestofIndia_pre2000*RestofIndia) ///
	if state=="MADHYA PRADESH"|state=="CHHATTISGARH"
	
	* Jh and Uttaranchal begin in 2002
replace Predreq_comb = cond(year>=2002,meanState_RestofIndia_post2002*RestofIndia,meanState_RestofIndia_pre2001*RestofIndia) ///
	if state == "BIHAR"|state=="JHARKHAND"|state=="UTTAR PRADESH"|state=="UTTARANCHAL"

	
** Jackknifed prediction for the balanced set of states
gen Predreq_bal=Predreq_comb

* for newly-created states, impute based on post-split share
replace Predreq_bal = meanState_RestofIndia * (Nationalreq*(1-meanState_RestofIndia)) ///
	if inlist(state,"CHHATTISGARH")&year<=2000
	
replace Predreq_bal = meanState_RestofIndia * (Nationalreq*(1-meanState_RestofIndia)) ///
	if inlist(state,"JHARKHAND","UTTARANCHAL")&year<=2001

* for the states that were split from, subtract the amount imputed to their new states
forvalues year=1992/2001 {
	if `year'!=2001 { // Separate data available for MP/Ch in 2001
		sum Predreq_bal if state=="CHHATTISGARH"&year==`year'
		replace Predreq_bal=Predreq_bal-r(mean) if state=="MADHYA PRADESH"&year==`year'
	}
	
	sum Predreq_bal if state=="JHARKHAND"&year==`year'
	replace Predreq_bal=Predreq_bal-r(mean) if state=="BIHAR"&year==`year'
	
	sum Predreq_bal if state=="UTTARANCHAL"&year==`year'
	replace Predreq_bal=Predreq_bal-r(mean) if state=="UTTAR PRADESH"&year==`year'
	
}
drop meanState_RestofIndia meanState_RestofIndia_pre2000 meanState_RestofIndia_post2001 ///
	meanState_RestofIndia_pre2001 meanState_RestofIndia_post2002 State_RestofIndia RestofIndia
	
