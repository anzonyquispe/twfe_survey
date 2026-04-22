clear
set more off


use "$dtapath/Figures/Appendix_Figure8.dta", replace
cd "$append_graphpath"

**********************
* 10 LEADS: ES
*********************
gen x=d_ln_bus_dom2	
gen fig_b=.
gen fig_se=.
	
set more off
*xi: reg g_est L(0/10)x F(1/2)x i.year i.fe_group  [aw=pop], r cluster(fips_state) 
xi: reg g_pop L(0/10)x F(1/9)x i.year i.fe_group  [aw=wgt], r cluster(fips_state) 
	
lincom F9.x 
replace fig_b=r(estimate) in 1
replace fig_se=r(se) in 1
	
lincom F9.x +F8.x 
replace fig_b=r(estimate) in 2
replace fig_se=r(se) in 2
	
lincom  F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 3
replace fig_se=r(se) in 3
	
lincom  F6.x+ F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 4
replace fig_se=r(se) in 4	
	
lincom  F5.x+ F6.x+ F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 5
replace fig_se=r(se) in 5	
	
lincom 	F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 6
replace fig_se=r(se) in 6
	
lincom 	F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 7
replace fig_se=r(se) in 7	

lincom 	F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 8
replace fig_se=r(se) in 8	

lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x 
replace fig_b=r(estimate) in 9
replace fig_se=r(se) in 9	
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x +x 
replace fig_b=r(estimate) in 10
replace fig_se=r(se) in 10	
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x +x + L1.x 
replace fig_b=r(estimate) in 11
replace fig_se=r(se) in 11	

lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x 
replace fig_b=r(estimate) in 12
replace fig_se=r(se) in 12

lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x 
replace fig_b=r(estimate) in 13
replace fig_se=r(se) in 13

lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x 
replace fig_b=r(estimate) in 14
replace fig_se=r(se) in 14
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x + L5.x
replace fig_b=r(estimate) in 15
replace fig_se=r(se) in 15
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x
replace fig_b=r(estimate) in 16
replace fig_se=r(se) in 16
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x + L7.x
replace fig_b=r(estimate) in 17
replace fig_se=r(se) in 17
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x+ L7.x + L8.x
replace fig_b=r(estimate) in 18
replace fig_se=r(se) in 18
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x+ L7.x + L8.x + L9.x
replace fig_b=r(estimate) in 19
replace fig_se=r(se) in 19
	
lincom 	F1.x+ F2.x + F3.x+ F4.x + F5.x+ F6.x+ F7.x + F8.x+ F9.x + x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x+ L7.x + L8.x+ L9.x+ L10.x
replace fig_b=r(estimate) in 20
replace fig_se=r(se) in 20


gen fig_upper=fig_b+1.645*fig_se
gen fig_lower=fig_b-1.645*fig_se

gen fig_t=_n-9 in 1/20

rename fig_b  ES3_fig_b 
rename fig_t ES3_fig_t
rename fig_upper ES3_fig_upper
rename fig_lower ES3_fig_lower	


**********************
* 10 LEADS: ES zeros
*********************

drop fig*

gen fig_b=.
gen fig_se=.
	
	set more off
	*xi: reg g_est L(0/10)x F(1/2)x i.year i.fe_group  [aw=pop], r cluster(fips_state) 
	xi: reg g_pop L(0/10)x F(1/9)x i.year i.fe_group  [aw=wgt], r cluster(fips_state) 
	
forv i=1/9{
	replace fig_b=0 in `i'
	replace fig_se=0 in `i'
}
	
lincom 	x 
replace fig_b=r(estimate) in 10
replace fig_se=r(se) in 10	
	
lincom 	x + L1.x 
replace fig_b=r(estimate) in 11
replace fig_se=r(se) in 11	

lincom 	 x + L1.x + L2.x 
replace fig_b=r(estimate) in 12
replace fig_se=r(se) in 12

lincom 	 x + L1.x + L2.x + L3.x 
replace fig_b=r(estimate) in 13
replace fig_se=r(se) in 13

lincom 	 x + L1.x + L2.x + L3.x + L4.x 
replace fig_b=r(estimate) in 14
replace fig_se=r(se) in 14
	
lincom 	 x + L1.x + L2.x + L3.x + L4.x + L5.x
replace fig_b=r(estimate) in 15
replace fig_se=r(se) in 15
	
lincom 	 x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x
replace fig_b=r(estimate) in 16
replace fig_se=r(se) in 16
	
lincom 	 x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x + L7.x
replace fig_b=r(estimate) in 17
replace fig_se=r(se) in 17
	
lincom 	 x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x+ L7.x + L8.x
replace fig_b=r(estimate) in 18
replace fig_se=r(se) in 18
	
lincom 	 x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x+ L7.x + L8.x + L9.x
replace fig_b=r(estimate) in 19
replace fig_se=r(se) in 19
	
lincom 	 x + L1.x + L2.x + L3.x + L4.x + L5.x + L6.x+ L7.x + L8.x+ L9.x+ L10.x
replace fig_b=r(estimate) in 20
replace fig_se=r(se) in 20


gen fig_upper=fig_b+1.645*fig_se
gen fig_lower=fig_b-1.645*fig_se

gen fig_t=_n-9 in 1/20

**********************
* 10 LEADS GRAPH WITH BOTH
*********************

	
*From Long Difference Table
gen LDcoeff=3.74
gen LDse=1.48
	
local graph_se=1.96
	
g LDupper=LDcoeff+`graph_se'
g LDlower=LDcoeff - `graph_se'
	
foreach v in "coeff" "se" "lower" "upper"{
	replace LD`v'=. if fig_t!=11
}	
	

*F-TEST RESULTS	
xi: reg g_pop L(0/10)x F(1/9)x i.year i.fe_group  [aw=wgt], r cluster(fips_state) 	
test L1.x=L2.x=L3.x =L4.x = L5.x =L6.x =L7.x =L8.x= L9.x =L10.x=0	
test F1.x=F2.x=F3.x =F4.x = F5.x =F6.x =F7.x =F8.x= F9.x=0	
	
	
twoway (scatter fig_b fig_t if  fig_t<21 & fig_t>-10, c(l) xline(-0.5, lc(gs11) lp(shortdash)) yline(0, lc(gs11) lp(shortdash))) ///
	(scatter fig_upper fig_t  if fig_t<21 & fig_t>-10 , lpattern(dash) lcolor(dknavy) c(l) m(i) ) ///
	(scatter fig_lower fig_t  if fig_t<21 & fig_t>-10, lpattern(dash) lcolor(dknavy) c(l) m(i) ) ///
	(scatter ES3_fig_b ES3_fig_t if  fig_t<21 & fig_t>-10, msymbol(diamond) c(l) mcolor(cranberry)  lcolor(cranberry)) ///
	(scatter ES3_fig_upper ES3_fig_t  if fig_t<21 & fig_t>-10 , lpattern(dash) lcolor(cranberry) c(l) m(i) ) ///
	(scatter ES3_fig_lower ES3_fig_t  if fig_t<21 & fig_t>-10, lpattern(dash) lcolor(cranberry) c(l) m(i) ) ///
	(scatter LDcoeff fig_t, msymbol(square) mcolor(midblue)) (rcap LDupper LDlower fig_t, lcolor(midblue) lwidth(medthick)), ///
	graphregion(fcolor(white)) ///
	xtitle("Year") ///
	ytitle("Percent") ///
	legend(order(1 4 7 8) label(1 "Cumulative Effect no leads") label(4 "Cumulative Effect w/ leads") label(7 "Long Difference Point Estimate") label(8 "95 % Confidence Interval")) 
graph export "Appendix_Figure8.pdf", replace
