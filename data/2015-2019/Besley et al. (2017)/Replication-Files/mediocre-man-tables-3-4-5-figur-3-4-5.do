**This makes Tables 3, 4 and 5, Figures 3, 4, and 5
 
 
 * open file with political data********************
use "politicians.dta" , clear
 * join with data on birthyear and sex********************


joinby p_id using "\\micro.intra\projekt\P0624$\P0624_Gem\Data Extraction and Files\Data files\Birthyear_sex.dta", unmatched(master) _merge(_merge)

 * join with data on income residual********************
 
joinby p_id using "\\micro.intra\projekt\P0624$\P0624_Gem\Data Extraction and Files\Data files\income residual.dta", unmatched(master) _merge(_merge2)
 * join with data on enlistment scores

gen electionperiod=ar
ren vald elected


keep if elected ==1

*rename enlistment variables
ren pprf_befl leader
ren pprf_pgrp iq

* enlistment variables have the value zero when missing, we recode this here
foreach var of varlist leader iq {
replace `var' =. if `var'==0
}


* here we take the z-score of each of the competence measures within each party and
* define a define a dummy for the individual having a score above the mean within the party
foreach var in inc_res iq leader{

gen `var'_nom=.
foreach parti in S V M C K G F{
egen `var'_nom_b=std(`var') if parti_initial =="`parti'"
replace `var'_nom= `var'_nom_b if parti_initial =="`parti'"
drop `var'_nom_b
}
gen `var'_d= `var'_nom>0 if  `var'_nom!=. 
}

ren Kon sex

*define dummy for woman
gen woman= sex==2 if kon!=.

* define dummies for being one of the three highest ranked politicans in the party, or one of the followers
gen etop3=rank_ind>3 if rank_ind!=.
gen top3=rank_ind<=3 if rank_ind!=.

*Define ranking variable than only looks at the ranking amongst the men
bysort llkk parti_initial electionperiod: egen man_rank=rank(rank_ind) if woman==0, track

**define dummy for being one of the three highest ranked men
gen top3_man= man_rank<=3 if man_rank!=.

*** We will tmeasure  the mean of each of our competence measure for each of our sample-
*The first step of this process is to take the measure for each relevant subpopulation
foreach var in inc_res_nom inc_res_d iq_d leader_d leader  {
	gen `var'_w=`var' if woman==1
	gen `var'_m=`var' if woman==0
 }

foreach var in inc_res_nom inc_res_d iq_d leader_d leader iq{
	foreach int of varlist etop3 top3{
		gen `var'_`int'_w=`var' if woman==1 & `int'==1
		gen `var'_`int'_m=`var' if woman==0 & `int'==1
		gen `var'_`int'=`var' if `int'==1
	}
 }
 

 *define dummy for being a female leader
gen woman_leader= woman==1 & nrinom_hl==1

*we define the mean of each variable by collapsing the data based on party, municipality and election period
collapse (mean)  woman_leader inc_res_nom-iq_top3_loss   leader  iq  (sum)elected, by(electionperiod llkk  parti_initial)

**create measures of  the social democrats having a female leader in 1991, and their share of women in 1994

gen w_share_91s_b= woman if parti_in=="S" & electionperiod==1991
gen w_share_94s_b= woman if parti_in=="S" & electionperiod==1994
gen w_lead_91s_b= woman_lead if parti_in=="S" & electionperiod==1991

foreach var in w_lead_91s w_share_91s_b w_share_94s_b   {
bysort m_id: egen `var' =max(`var'_b)
}
* define quota bite
gen qb= w_share_94s-w_share_91s


***define lag of key variables
sort m_id parti_initial electionperiod
foreach var in woman inc_res_nom  inc_res_d  iq_d leader_d  leader iq ///
 iq_top3 inc_res_nom_top3  inc_res_d_top3  iq_d_top3  leader_d_top3  leader_top3  iq_top3{
	gen `var'_lag= `var'[_n-1] if m_id[_n-1]==m_id & parti_initial==parti_initial[_n-1]

}

*define indicator for municipality and party
egen m_p=group(parti_initial m_id)

*define variable sused in the difference in difference specifications
foreach year in 1982 1985 1988 1994 1998 2002 2006 2010 2014{
	gen el_d_`year'= electionperiod==`year'
 }
 
 foreach year in 1982 1985 1988 1994 1998 2002 2006 2010 2014{
	gen qb_el_d_`year'= qb*el_d_`year'
 }


gen post_quota= electionperiod>1991
gen qb_post_quota= qb* post_quota

*define dummy for social democrats 
gen dum_s= parti_in=="S"

*define variable to measure change in the share of women
gen woman_ch = woman-woman_lag

 ***Data for figure 3****
log using wshare_elec, replace
	bysort valar: sum woman if parti_initial =="S"
	bysort valar: sum woman if parti_initial =="M"
	bysort valar: sum woman if parti_initial =="C"
log close
*density plots for figure 3
twoway (kdensity   woman_ch if electionperiod==1994 & parti_initial =="S") ///
(kdensity   woman_ch if electionperiod==1994 & parti_initial =="M") ///
(kdensity   woman_ch if electionperiod==1998 & parti_initial =="C")

 ********Table 3**************************
  
 	xi: reg inc_res_d_etop3 inc_res_d_top3_lag el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: reg inc_res_d_etop3  inc_res_d_top3 el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: reg inc_res_d_etop3 inc_res_d_top3_lag inc_res_d_top3 el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: reg inc_res_d_etop3  inc_res_d_etop3_lag inc_res_d_top3_lag el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: areg inc_res_d_etop3 inc_res_d_top3_lag el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust abs(m_id)
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: areg inc_res_d_etop3 inc_res_d_top3_lag el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust abs(m_p)
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: areg iq_etop3 iq_top3_lag el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust abs(m_id)
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append
	xi: areg leader_etop3 leader_top3_lag el_d_1982- el_d_2014 if  s_post_quota==0 & elected>7  ,  cluster(m_p)  robust abs(m_id)
    outreg2  using table_3, ctitle(inc_res_d ) excel nocons dec(3) se append


	************ Table 4****************
	xi: areg inc_res_d qb_post_quota post_quota  if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
    outreg2  qb_post_quota post_quota  using table_4, ctitle(inc_res_d ) excel nocons dec(3) se replace
	xi: areg inc_res_d qb_post_quota post_quota i.m_id*electionperiod if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
    outreg2  qb_post_quota post_quota  using table_4, ctitle(inc_res_d ) excel nocons dec(3) se append
		
	xi: areg inc_res_d_m qb_post_quota post_quota   if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
	outreg2  qb_post_quota post_quota  using table_4, ctitle(inc_res_d_m ) excel nocons dec(3) se append
	xi: areg inc_res_d_m qb_post_quota post_quota i.m_id*electionperiod  if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
	outreg2  qb_post_quota post_quota  using table_4, ctitle(inc_res_d_m ) excel nocons dec(3) se append
	
	xi: areg inc_res_d_w qb_post_quota post_quota  if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
	outreg2  qb_post_quota post_quota  using table_4, ctitle(inc_res_d_m ) excel nocons dec(3) se append
	xi: areg inc_res_d_w qb_post_quota post_quota i.m_id*electionperiod  if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
	outreg2  qb_post_quota post_quota  using table_4, ctitle(inc_res_d_m ) excel nocons dec(3) se append

	*****Estimates used for Figure 4***********************
	xi: areg inc_res_d_m qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
	outreg2  qb_el_d_1982- qb_el_d_2014 using figure_4, ctitle(inc_res_d_m ) excel nocons dec(3) se append
	xi: areg inc_res_d qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
    outreg2  qb_el_d_1982- qb_el_d_2014 using figure_4, ctitle(inc_res_d ) excel nocons dec(3) se replace
	xi: areg inc_res_d_w qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1 , abs(m_id) cluster(m_id)  robust
	outreg2  qb_el_d_1982- qb_el_d_2014 using figure_4, ctitle(inc_res_d_m ) excel nocons dec(3) se append



	********Table 5
	xi: areg inc_res_d_top3 qb_post_quota post_quota  i.m_id*electionperiod if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_post_quota post_quota using med_man_top_power, ctitle(inc_res_d_top3) excel nocons dec(3) se replace
	xi: areg inc_res_d_etop3 qb_post_quota post_quota  i.m_id*electionperiod if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_post_quota post_quota using med_man_top_power, ctitle(inc_res_d_etop3) excel nocons dec(3) se append
	xi: areg inc_res_d_top3_m qb_post_quota post_quota  i.m_id*electionperiod if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_post_quota post_quota using med_man_top_power, ctitle(inc_res_d_) excel nocons dec(3) se append
	xi: areg inc_res_d_etop3_m qb_post_quota post_quota  i.m_id*electionperiod if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_post_quota post_quota using med_man_top_power, ctitle(inc_res_d_etop3_m) excel nocons dec(3) se append

	********Estimates used for figure 5
	xi: areg inc_res_d_top3  qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_el_d_1982- qb_el_d_2014 using figure_5, ctitle(inc_res_d_ ) excel nocons dec(3) se replace
	xi: areg inc_res_d_etop3 qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_el_d_1982- qb_el_d_2014 using figure_5, ctitle(inc_res_d_etop3 ) excel nocons dec(3) se append
	xi: areg inc_res_d_top3_m qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_el_d_1982- qb_el_d_2014 using figure_5, ctitle(inc_res_d_top3_m ) excel nocons dec(3) se append
	xi: areg inc_res_d_etop3_m  qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & dum_s==1, abs(m_id) cluster(m_id)  robust
    outreg2  qb_el_d_1982- qb_el_d_2014 using figure_5, ctitle(inc_res_d_etop3_m) excel nocons dec(3) se append
	
	

 
