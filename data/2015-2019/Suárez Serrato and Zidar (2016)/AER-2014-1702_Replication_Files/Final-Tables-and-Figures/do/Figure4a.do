clear
set more off

*********************************************************
*Construct Figure
*********************************************************
use "$dtapath/Figures/Figure4.dta", clear
cd "$graphpath"

gen x=d_ln_bus_dom2	

gen fig_b=.
gen fig_se=.

set more off
*xi: reg g_est L(0/10)x F(1/2)x i.year i.fe_group  [aw=wgt], r cluster(fips_state) 
xi: reg g_est L(0/10)x  i.year  i.fe_group [aw=wgt], r cluster(fips_state) 
	

	
lincom  x
replace fig_b=r(estimate) in 3
replace fig_se=r(se) in 3
	
lincom   x + L1.x 
replace fig_b=r(estimate) in 4
replace fig_se=r(se) in 4	
	
lincom   x + L1.x + L2.x 
replace fig_b=r(estimate) in 5
replace fig_se=r(se) in 5	
	
lincom 	x + L1.x + L2.x + L3.x
replace fig_b=r(estimate) in 6
replace fig_se=r(se) in 6
	
lincom 	 x + L1.x + L2.x + L3.x+ L4.x
replace fig_b=r(estimate) in 7
replace fig_se=r(se) in 7	
	
lincom 	 x + L1.x + L2.x + L3.x+ L4.x + L5.x
replace fig_b=r(estimate) in 8
replace fig_se=r(se) in 8	

lincom 	 x + L1.x + L2.x + L3.x+ L4.x + L5.x+ L6.x
replace fig_b=r(estimate) in 9
replace fig_se=r(se) in 9	
	
lincom 	 x + L1.x + L2.x + L3.x+ L4.x + L5.x+ L6.x+ L7.x
replace fig_b=r(estimate) in 10
replace fig_se=r(se) in 10	
	
lincom 	 x + L1.x + L2.x + L3.x+ L4.x + L5.x+ L6.x+ L7.x + L8.x
replace fig_b=r(estimate) in 11
replace fig_se=r(se) in 11	

lincom 	x + L1.x + L2.x + L3.x+ L4.x + L5.x+ L6.x+ L7.x + L8.x+ L9.x
replace fig_b=r(estimate) in 12
replace fig_se=r(se) in 12
	
lincom 	x + L1.x + L2.x + L3.x+ L4.x + L5.x+ L6.x+ L7.x + L8.x+ L9.x+ L10.x
replace fig_b=r(estimate) in 13
replace fig_se=r(se) in 13

gen fig_upper=fig_b+1.645*fig_se
gen fig_lower=fig_b-1.645*fig_se

gen fig_t=_n-3 in 1/13

	
twoway (scatter fig_b fig_t if  fig_t<11 & fig_t>-1, c(l) xline(-0.0, lc(gs11) lp(shortdash)) yline(0, lc(gs11) lp(shortdash))) ///
	(scatter fig_upper fig_t  if fig_t<11 & fig_t>-1 , lpattern(dash) lcolor(dknavy) c(l) m(i) ) ///
	(scatter fig_lower fig_t  if fig_t<11 & fig_t>-1, lpattern(dash) lcolor(dknavy) c(l) m(i) ), ///
	graphregion(fcolor(white)) ///
	xtitle("Year") ///
	ytitle("Percent") ///
	legend(off)
graph export "Figure4a.pdf", replace



