**This makes Table 1 and Figure 6
 
 
 *** open file with political data********************
use "politicians.dta" , clear
 *** join with data on birthyear and sex********************


joinby p_id using "\\micro.intra\projekt\P0624$\P0624_Gem\Data Extraction and Files\Data files\Birthyear_sex.dta", unmatched(master) _merge(_merge)

 *** join with data on income residual********************
 
joinby p_id using "\\micro.intra\projekt\P0624$\P0624_Gem\Data Extraction and Files\Data files\income residual.dta", unmatched(master) _merge(_merge2)
 *** join with data on enlistment scores




sort p_id electionperiod
gen remain_list =nrinom[_n+1]!=. & p_id[_n+1]==p_id & electionperiod!=electionperiod[_n+1] & (electionperiod[_n+1]-electionperiod)<5

keep if elected ==1


* enlistment variables have the value zero when missing, we recode this here
foreach var of varlist leader iq {
replace `var' =. if `var'==0
}


* here we take the z-score of each of the cincome residual within each party and
* define a define a dummy for the individual having a score above the median
foreach var in inc_res {

gen `var'_nom=.
foreach parti in S V M C K G F{
egen `var'_nom_b=std(`var') if parti_initial =="`parti'"
replace `var'_nom= `var'_nom_b if parti_initial =="`parti'"
drop `var'_nom_b
}
gen `var'_d= `var'_nom>0 if  `var'_nom!=. 
}

*define dummyyfor being a woman
gen woman= sex==2 if kon!=.

* define dummies for being one of the three highest ranked politicans in the party, or one of the followers
gen etop3=rank_ind>3 if rank_ind!=.
gen top3=rank_ind<=3 if rank_ind!=.

*define ranking variable than only looks at the ranking amongst the men
bysort llkk parti_initial electionperiod: egen man_rank=rank(rank_ind) if woman==0, track

**define dummy for being one of the three highest ranked men
gen top3_man= man_rank<=3 if man_rank!=.


*define dummy for being a female leader
gen woman_leader= woman==1 & nrinom_hl==1



*create measure of quota bite and a mesure of having a female leader in 1991

bysort parti_initial m_id:  egen w_share_91s_b= mean(woman) if parti_initial=="S" & electionperiod==1991
bysort parti_initial m_id:  egen w_share_94s_b= mean(woman) if parti_initial=="S" & electionperiod==1994

gen w_lead_91s_b= woman_leader if parti_initial=="S" & electionperiod==1991

foreach var in w_lead_91s  w_share_94s w_share_91s  {
bysort parti_initial m_id: egen `var' =max(`var'_b)
}
gen qb= w_share_94s-w_share_91s


egen m_p=group(parti_initial m_id)

 egen m_c=group(inc_res_d  m_id)




*Define variables used in the differenc in difference and triple difference specifications
foreach year in 1982 1985 1988 1991  1994 1998 2002 2006 2010 2014{
 gen el_d_`year'= electionperiod==`year'
 }
 
 foreach year in 1982 1985 1988 1991 1994 1998 2002 2006 2010 2014{
 gen qb_el_d_`year'= qb*el_d_`year'
 }

  foreach year in 1982 1985   1991 1994 1998 2002 2006 2010 2014{
 gen qb_comp_el_d_`year'= qb*el_d_`year'* inc_res_d 
 }
 
 foreach year in 1982 1985 1991  1994 1998 2002 2006 2010 2014{
 gen el_comp_d_`year'=el_d_`year'* inc_res_d 
 }
 


 


*regression estimates for Figure 6*****
	xi: areg remain_list qb_el_d_1982 qb_el_d_1985 qb_el_d_1991- qb_el_d_2014 el_d_1982 el_d_1985 el_d_1991- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & woman==0 & top3==1 & inc_res_d==0, abs(m_id) cluster(m_id)  robust
	outreg2  qb_el_d_1982 qb_el_d_1985 qb_el_d_1991- qb_el_d_2014 el_d_1982 el_d_1985 el_d_1991- el_d_2014 using figure_6, ctitle(mediocre ) excel nocons dec(3) se replace
	xi: areg remain_list qb_el_d_1982 qb_el_d_1985 qb_el_d_1991- qb_el_d_2014 el_d_1982 el_d_1985 el_d_1991- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & woman==0 & top3==1  & inc_res_d==1, abs(m_id) cluster(m_id)  robust
	outreg2  qb_el_d_1982 qb_el_d_1985 qb_el_d_1991- qb_el_d_2014 el_d_1982 el_d_1985 el_d_1991- el_d_2014  using figure_6, ctitle(competent ) excel nocons dec(3) se append
	xi: areg remain_list qb_comp_el_d_1982- qb_comp qb_el_d_1982- qb_el_d_2014 el_d_1982- el_d_2014 if  w_share_94s>.40 & w_lead_91s==0 & woman==0 & top3==1, abs(m_c) cluster(m_id)  robust
	outreg2  qb_el_d_1982- qb_el_d_2014 using figure_6, ctitle(tripple ) excel nocons dec(3) se append

 


****Analysis for Table 1***********
	foreach var in top_rank elec_next pers_share_parti {
		gen `var'_reg =`var'*100
	}
	
	reg pers_share_parti_reg inc_res_d, cluster(m_id)
	outreg2 using table1, dec(2) excel replace
	areg pers_share_parti_reg inc_res_d, cluster(m_id) abs(nrinom_hl)
	outreg2 using table1, dec(2) excel append
	
	reg elec_next_reg inc_res_d, cluster(m_id)
	outreg2 using table1, dec(2) excel append
	areg elec_next_reg inc_res_d, cluster(m_id) abs(nrinom_hl)
	outreg2 using table1, dec(2) excel append
	
	reg nrinom_hl inc_res_d, cluster(m_id)
	outreg2 using table1, dec(2) excel append
	reg top_rank_reg inc_res_d, cluster(m_id)
	outreg2 using table1, dec(2) excel append
	
	reg iq_nom inc_res_d, cluster(m_id)
	outreg2 using table1, dec(2) excel append
	reg leader_nom inc_res_d, cluster(m_id)
	outreg2 using table1, dec(2) excel append
	

