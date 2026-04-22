# delimit;
clear;
set mem 600m;
set more off;

/**************************************************************************************

This file is intended to replicate regression results in Online Appendix Table 3
where we look at the impact of the merge separately for Aetna-Pru Customers

***************************************************************************************/


/* We begin by identify employer-markets that are not served by Aetna Pru in 1999 */
use plandata, clear;
drop if plantype == "EPO";	

keep if year==1999;

keep uniqcode year mktcode carriercode totalemployees;
ge aetna = (carriercode == 1);
ge pru = (carriercode == 22);
egen aetnaemp_tmp1 = sum(totalemployees) if aetna==1, by(uniqcode mktcode);
egen pruemp_tmp1 = sum(totalemployees) if pru==1, by(uniqcode mktcode);

egen aetnaemp_em = mean (aetnaemp_tmp1), by(uniqcode mktcode);
egen pruemp_em = mean(pruemp_tmp1), by (uniqcode mktcode);
egen numempl_em = sum(totalemployees), by (uniqcode mktcode);

ge aetnash_em = aetnaemp_em/numempl_em;
ge prush_em = pruemp_em/numempl_em;
		
egen aetnaemp_tmp2 = sum(totalemployees) if aetna==1, by(mktcode);
egen pruemp_tmp2 = sum(totalemployees) if pru==1, by(mktcode);

egen aetnaemp_m = mean (aetnaemp_tmp2), by(mktcode);
egen pruemp_m = mean(pruemp_tmp2), by (mktcode);
egen numempl_m = sum(totalemployees), by (mktcode);

ge aetnash_m = aetnaemp_m/numempl_m;
ge prush_m = pruemp_m/numempl_m;
	
replace aetnash_em = 0 if aetnash_em==.;
replace prush_em = 0 if prush_em==.;
ge aetprush_em = aetnash_em + prush_em; 
	
replace aetnash_m = 0 if aetnash_m==.;
replace prush_m = 0 if prush_m==.;

egen aetnafirm = max(aetna), by (uniqcode mktcode);
egen prufirm = max(pru), by (uniqcode mktcode);

collapse aetnash_em aetnash_m prush_em prush_m aetprush_em aetnafirm prufirm year, by (uniqcode mktcode carriercode);

ge dum = 1;
collapse aetnash_em aetnash_m prush_em prush_m aetprush_em aetnafirm year prufirm (sum) numcarr = dum, 
by (uniqcode mktcode);
ge apfirm = aetnafirm + prufirm;

ge num_nonap = numcarr - aetnafirm - prufirm;

ge em_non_slice = numcarr==1;

ge em_no_ap = (aetnafirm==0) & (prufirm==0);
ge em_ap = 1 - em_no_ap;

keep uniqcode mktcode aetnash* prush* aetprush_em em_* year;
sort uniqcode mktcode;

save premerg_ap_1999, replace;

/*We then take our EMY level data (created by dataset_create.do) and then merge on the file created above*/

use emy_simherf, clear;
tsset uniqmkt year;
ge sifrac_diff = d.sifrac;
	
sort uniqcode mktcode;
merge uniqcode mktcode using premerg_ap_1999; 
tab _m;
ge absent_pre = _m==1; /*These are employer-mkts not present in the data in the pre-year*/

/**************************************************************************************
				APPENDIX TABLE 3
***************************************************************************************/

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi i.year if 
year<=2002 & texas==0, cluster(mktcode) a(mktcode);
est store m1;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi i.year if 
in99==1 & year<=2002 & texas==0, cluster(mktcode) a(mktcode);
est store m2;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi i.year if em_no_ap ==0 & 
year<=2002 & texas==0, cluster(mktcode) a(mktcode);
est store m3;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi i.year if em_no_ap ==1 & 
year<=2002 & texas==0, cluster(mktcode) a(mktcode);
est store m4;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi i.year i.mktcode if em_no_ap ==1 & 
year<=2002 & texas==0, cluster(mktcode) a(uniqcode);
est store m5;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi indfrac_diff hmofrac_diff
ppofrac_diff plandesign_diff i.year i.mktcode if em_no_ap ==1 & year<=2002 & texas==0, cluster(mktcode) a(uniqcode);
est store m6;	
	
estout *  using "results/OA_Table3".txt, 
cells (b(star fmt(%9.4f)) se(par)) 	keep(m99incr demofactor_diff sifrac_diff indfrac_diff hmofrac_diff
ppofrac_diff plandesign_diff , relax ) style(fixed) stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared))
starlevels(* 0.10 ** 0.05 *** .01) legend label replace;
est drop *;
