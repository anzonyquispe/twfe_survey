# delimit;
clear;
set mem 600m;
set more off;

/**************************************************************************************

This file is intended to replicate regression results in Table 6, which uses data from 
the Occupational Employment Statistics (OES) survey. We begin by using the sample of
workers in healthcare related occupations and then merge on our simulated
HHI measures created in the program dataset.do.

This program also includes the code for generating the results in Online Appendix Table 5
which breaks down the OES results by Nurse category.
***************************************************************************************/

use All_29000_Occupations_1997_2006, clear;

*We drop obs with occ code 29000 as this is the overall aggregate;
drop if occ_code==290000|market==.|tot_emp==0;

*We replace occupation codes for certain obs where it is missing in the original data;
replace occ_code = 291067 if occ_title == "Physicians and Surgeons" & occ_code==.;
replace occ_code = 292061 if occ_title == "Licensed Practical Nurses" & occ_code==.;

/*We now collapse the main variables to the level of occupation-market-year*/
collapse a_mean (rawsum) tot_emp [w=tot_emp], by(occ_code occ_title market year);

rename market mktcode;

/*We categorize occupations into physicians and nurses*/
ge phys = 0;
replace phys = 1 if  occ_code == 291020 | occ_code == 291062|
occ_code == 291063 | occ_code == 291064 | occ_code == 291065 |occ_code == 291066 | occ_code == 291067 | occ_code == 291081;
ge nurse = 0;
replace nurse = 1 if occ_code==291111|occ_code==292061;

save tmp_oes_omy, replace;

*Creating dummy codes to facilitate collapse;
replace occ_code=9999 if phys==1;
replace occ_code=10000 if nurse==1;

collapse a_mean phys nurse (rawsum) tot_emp [w=tot_emp], by(occ_code mktcode year);

/*We merge onto this file a file containing long diffs of the market-year covariates*/
sort mktcode ;
merge mktcode using mktlevelvar_9902; 
drop if _m==2; drop _m;

xi i.year;
ge ln_amean = ln(a_mean);

egen in99 = max(year==1999), by(occ_code mktcode);
egen in97 = max(year==1997), by(occ_code mktcode);
rename tot_emp num_phys;
ge totearnings = num_phys * a_mean;
ge lntotearn = ln(totearnings);
ge lnnumphys = ln(num_phys);

foreach var of varlist  ln_amean lnnumphys lntotearn{;
/*Changes in the dependent variable*/

	sort mktcode occ_code year;

	bysort mktcode occ_code: ge tmp`var'1997 = `var' if year==1997;
	bysort mktcode occ_code: ge tmp`var'1998 = `var' if year==1998;
	bysort mktcode occ_code: ge tmp`var'1999 = `var' if year==1999;
	bysort mktcode occ_code: ge tmp`var'2002 = `var' if year==2002;
	bysort mktcode occ_code: ge tmp`var'2001 = `var' if year==2001;

	egen `var'1997 = max(tmp`var'1997), by (mktcode occ_code);
	egen `var'1998 = max(tmp`var'1998), by (mktcode occ_code);
	egen `var'1999 = max(tmp`var'1999), by (mktcode occ_code);
	egen `var'2002 = max(tmp`var'2002), by (mktcode occ_code);
	egen `var'2001 = max(tmp`var'2001), by (mktcode occ_code);

	ge d`var'9798 = `var'1998 - `var'1997;
	ge d`var'9901 = `var'2001 - `var'1999;
	ge d`var'9902 = `var'2002 - `var'1999;
	drop tmp*;
};

egen avgtotemp = mean(num_phys), by(mktcode occ_code);

*We merge on the simulated HHI measure;
sort mktcode year;
merge mktcode year using simherf, nokeep; drop _m;

ge simherfphys = merger99incr * phys;
ge simherfnurse = merger99incr * nurse;

drop if occ_code==.; 

compress;

save oes_omy_data, replace;

/**************************************************************************************
				TABLE 6: OES REGRESSIONS 
***************************************************************************************/

xi:reg dln_amean9902 merger99incr phys simherfphys nurse simherfnurse dlhosp_hhi9902  if in99==1 & texas==0 
& year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store earnings_base;

xi:reg dln_amean9902 merger99incr dln_amean9798 phys simherfphys nurse simherfnurse dlhosp_hhi9902  
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store earnings_trends;

xi:reg dln_amean9902 merger99incr dln_amean9798 phys simherfphys nurse simherfnurse dlhosp_hhi9902 i.occ_code
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store earnings_full;

xi:reg dlnnumphys9902 merger99incr phys simherfphys nurse simherfnurse dlhosp_hhi9902  if in99==1 & texas==0 
& year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store employment_base;

xi:reg dlnnumphys9902 merger99incr dlnnumphys9798 phys simherfphys nurse simherfnurse dlhosp_hhi9902  
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store employment_trends;

xi:reg dlnnumphys9902 merger99incr dlnnumphys9798 phys simherfphys nurse simherfnurse dlhosp_hhi9902 i.occ_code 
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store employment_full;

estout *  using "results/Table6".txt, cells (b(star fmt(%9.4f)) se(par)) 
keep(merger99incr phys simherfphys nurse simherfnurse dlhosp_hhi9902 , relax ) 
style(fixed) stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) starlevels(* 0.10 ** 0.05 *** .01) 
legend label replace;
est drop *;


/* We now consider the two nurse categories (RNs and LVNs) separately */

use tmp_oes_omy, clear;

ge rn = (occ_code==291111);
ge lvn = (occ_code==292061);

replace occ_code=9999 if phys==1;

collapse a_mean phys rn lvn (rawsum) tot_emp [w=tot_emp], by(occ_code mktcode year); 

/*We merge onto this file a file containing long diffs*/
sort mktcode ;
merge mktcode using mktlevelvar_9902; 
drop if _m==2; drop _m;

xi i.year;
ge ln_amean = ln(a_mean);

egen in99 = max(year==1999), by(occ_code mktcode);
egen in97 = max(year==1997), by(occ_code mktcode);
rename tot_emp num_phys;
ge totearnings = num_phys * a_mean;
ge lntotearn = ln(totearnings);
ge lnnumphys = ln(num_phys);

foreach var of varlist  ln_amean lnnumphys lntotearn{;
/*Changes in the dependent variable*/

	sort mktcode occ_code year;

	bysort mktcode occ_code: ge tmp`var'1997 = `var' if year==1997;
	bysort mktcode occ_code: ge tmp`var'1998 = `var' if year==1998;
	bysort mktcode occ_code: ge tmp`var'1999 = `var' if year==1999;
	bysort mktcode occ_code: ge tmp`var'2002 = `var' if year==2002;
	bysort mktcode occ_code: ge tmp`var'2001 = `var' if year==2001;

	egen `var'1997 = max(tmp`var'1997), by (mktcode occ_code);
	egen `var'1998 = max(tmp`var'1998), by (mktcode occ_code);
	egen `var'1999 = max(tmp`var'1999), by (mktcode occ_code);
	egen `var'2002 = max(tmp`var'2002), by (mktcode occ_code);
	egen `var'2001 = max(tmp`var'2001), by (mktcode occ_code);

	ge d`var'9798 = `var'1998 - `var'1997;
	ge d`var'9901 = `var'2001 - `var'1999;
	ge d`var'9902 = `var'2002 - `var'1999;
	drop tmp*;
};

egen avgtotemp = mean(num_phys), by(mktcode occ_code);

sort mktcode year;
merge mktcode year using simherf, nokeep; drop _m;

ge simherfphys = merger99incr * phys;
ge simherf_rn = merger99incr * rn;
ge simherf_lvn = merger99incr *lvn;

drop if occ_code==.; 

/**************************************************************************************
				ONLINE APPENDIX TABLE 5: OES REGRESSIONS 
***************************************************************************************/

xi:reg dln_amean9902 merger99incr phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902  if in99==1 & texas==0 
& year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store earnings_base;

xi:reg dln_amean9902 merger99incr dln_amean9798 phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902  
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store earnings_trends;

xi:reg dln_amean9902 merger99incr dln_amean9798 phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902 i.occ_code
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store earnings_full;

xi:reg dlnnumphys9902 merger99incr phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902  if in99==1 & texas==0 
& year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store employment_base;

xi:reg dlnnumphys9902 merger99incr dlnnumphys9798 phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902  
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store employment_trends;

xi:reg dlnnumphys9902 merger99incr dlnnumphys9798 phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902 i.occ_code 
if in99==1 & texas==0 & year==2002 [w=avgtotemp], cluster (mktcode) robust;
est store employment_full;

estout *  using "results/OATable5.txt", cells (b(star fmt(%9.4f)) se(par)) 
keep(merger99incr phys simherfphys rn lvn simherf_rn simherf_lvn dlhosp_hhi9902 , relax ) 
style(fixed) stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) starlevels(+ 0.10 * 0.05 ** .01 *** .001) 
legend label replace;
est drop *;
