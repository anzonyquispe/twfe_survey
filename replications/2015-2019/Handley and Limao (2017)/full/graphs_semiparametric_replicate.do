
set more off



	use replication_maindata1,clear
	
	rename rat_2000 rat
	
	gen minusratio_3=-rat^3


***non-linear***

	keep if year==2005


**semiparametric regression: **

	capture drop f
	capture drop y_part
	capture drop _merge

	
	
set more off
/*test function form log linear approx vs any funtion of ratio*/

**NOTE THAT THIS CAN TAKES LONG depending on machine***
		
**create local variable for seed*
		local state=2013

/* section dummies */
	
	/*set seed*/
	set seed `state'	

	qui xi: reg dif_ln_imp_5 minusratio_3 dif_ln_tcost_5 dif_advalorem_mfn_5 i.section if year==2005 , r
	capture drop yhat mean_y_hat_no_unc yplot 
	predict yhat 
	egen  mean_y_hat_no_unc =mean(yhat-_b[minusratio_3]*minusratio_3) if e(sample)
	gen yplot = mean_y_hat_no_unc +_b[minusratio_3]*minusratio_3 		

		/* note that yplot is passed directly to the semipar_nl ado file to
		overlay the linear fit plot and that the variable in gen() option is
		used as the name of the graph that is internally saved*/

/*esimate and graph */

xi: semipar_nl dif_ln_imp_5  dif_ln_tcost_5 dif_advalorem_mfn_5 i.section if year==2005  , nonpar(minusratio_3) xtitle("") gen(smooth_semi_section_minusratio3) kernel(epanechnikov) ci  robust 

graph export figure4c.pdf, as(pdf) replace
rm smooth_semi_section_minusratio3.gph

/****** PRICE INDEX VERSION *****/


capture drop f
capture drop y_part
capture drop _merge

**NOTE THAT THIS TAKES LONG***
		
		**create local variable for seed*
		local state=2013

	
*local bootn 500
		

*section dummies*
	
	/*set seed*/
	set seed `state'	

	qui xi: reg ldif_ln_pindex_hs6_total  minusratio_3 dif_ln_tcost_5 dif_advalorem_mfn_5 i.section if year==2005 & trim_025tails==1 & pindex_sample==1, r
	capture drop yhat mean_y_hat_no_unc yplot 
	predict yhat 
	egen  mean_y_hat_no_unc =mean(yhat-_b[minusratio_3]*minusratio_3) if e(sample)
	gen yplot = mean_y_hat_no_unc +_b[minusratio_3]*minusratio_3 		

		/* note that yplot is passed directly to the semipar_nl ado file to
		overlay the linear fit plot and that the variable in gen() option is
		used as the name of the graph that is internally saved*/
		
set more off
/*potential graph: smooth_semi_section.gph*/
	xi: semipar_nl ldif_ln_pindex_hs6_total   dif_ln_tcost_5 dif_advalorem_mfn_5 i.section if year==2005 & trim_025tails==1 , nonpar(minusratio_3) xtitle("") gen(semipar_section_minusratio3price) kernel(epanechnikov) ci  robust

	

graph export figure4d.pdf, as(pdf) replace
rm semipar_section_minusratio3price.gph



exit

