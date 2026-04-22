# delimit;
clear;
set mem 500m;
set more off;
est clear;

/**************************************************************************************

This file is intended to replicate regression results presented in Tables 2-5. The starting
point for this program is the dataset emy_simherf.dta which is a Stata dataset organized at the 
Employer-Market-Year level. This is created by the program dataset_create.do. All results 
are written to a results subdirectory. The program also contains code for creating Appendix
Table 2.

***************************************************************************************/

use emy_simherf, clear;

tsset uniqmkt year;
sort uniqmkt year;

ge sifrac_lag = l.sifrac;
ge sifrac_diff = sifrac - sifrac_lag;

gen m99incr98 = diff99max * (year==1998);
gen m99incr99 = diff99max * (year==1999);
gen m99incr00 = merger99incr * (year==2000);
gen m99incr01 = merger99incr * (year==2001);
gen m99incr02 = merger99incr * (year==2002);
gen m99incr03 = merger99incr * (year==2003);
gen m99incr04 = merger99incr * (year==2004);
gen m99incr05 = merger99incr * (year==2005);
gen m99incr06 = merger99incr * (year==2006);

ge txpost = texas * (year>=2001);

gen m99incr_post03 = merger99incr * (year>=2003);

ge apsh99_sim_post = apsh99*m99incr;
ge apsh99_post = apsh99*(year>=2001);
ge apsh99_sim = apsh99*diff99max;

ge apsh99_sim01 = apsh99*m99incr01;
ge apsh99_sim02 = apsh99*m99incr02;
ge apsh99_sim03 = apsh99*m99incr03;
ge apsh99_sim04 = apsh99*m99incr04;
ge apsh99_sim05 = apsh99*m99incr05;
ge apsh99_sim06 = apsh99*m99incr06;

ge apsh99_post01 = apsh99*(year==2001);
ge apsh99_post02 = apsh99*(year==2002);
ge apsh99_post03 = apsh99*(year==2003);
ge apsh99_post04 = apsh99*(year==2004);
ge apsh99_post05 = apsh99*(year==2005);
ge apsh99_post06 = apsh99*(year==2006);

ge sim_sifrac99 = m99incr * sifrac99;
ge post_sifrac99 = sifrac99 * (year>=2001); 

/**************************************************************************************
				TABLE 2: OLS REGRESSIONS 
***************************************************************************************/

est clear;
xi: areg lorig_diff lagherf demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
i.year , cluster(mktcode) a(mktcode);
est store ols_base;

xi: areg lorig_diff lagherf demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
i.year i.mktcode , cluster(mktcode) a(uniqnum);
est store ols_emplfe;

xi: areg lorig_diff lagherf demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi indfrac_diff 
hmofrac_diff ppofrac_diff plandesign_diff i.year i.mktcode , cluster(mktcode) a(uniqnum);
est store ols_full;

estout *  using "results/Table2.txt", cells (b(star fmt(%9.4f)) se(par)) 
keep(lagherf demofactor_diff sifrac_diff  llnaapcc luerate lhosp_hhi indfrac_diff hmofrac_diff 
ppofrac_diff plandesign_diff , relax ) style(fixed) stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) 
starlevels(* 0.10 ** 0.05 *** .01) legend label replace;

/**************************************************************************************
				TABLE 4: REDUCED FORM REGRESSIONS 
***************************************************************************************/

est clear;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
i.year if year<=2002 & texas==0, cluster(mktcode) a(mktcode);
est store base;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
i.year i.mktcode if year<=2002 & texas==0, cluster(mktcode) a(uniqcode);
est store base_emplFE;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff  i.year i.mktcode if year<=2002 
& texas==0, cluster(mktcode) a(uniqcode);
est store full;

xi: areg lorig_diff m99incr99 m99incr00 m99incr01 m99incr02 demofactor_diff sifrac_diff llnaapcc 
luerate lhosp_hhi indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff  i.year i.mktcode if year<=2002 
& texas==0, cluster(mktcode) a(uniqcode);
est store full_indivyrs;

xi: areg lorig_diff m99incr txm99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
est store tx_full;

xi: areg lorig_diff m99incr txm99incr txpost demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
est store tx_full2;

estout *  using "results/Table4.txt", cells (b(star fmt(%9.4f)) se(par)) 
keep(m99incr txm99incr txpost m99incr99 m99incr00 m99incr01 m99incr02 demofactor_diff sifrac_diff llnaapcc luerate 
lhosp_hhi indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff , relax ) style(fixed)
stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) starlevels(* 0.10 ** 0.05 *** .01) legend label replace;
 
/**************************************************************************************
				TABLE 5: OLS, RF, IV & FIRST STAGE REGRESSIONS 
***************************************************************************************/
est clear;

* We start with the RF spec (col 2) and estimate the first stage (col 1) on the same sample;

xi: areg lorig_diff m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff i.year i.mktcode if year<=2002 & texas==0, cluster(mktcode) 
a(uniqcode);
est store rf;
ge sample1 = e(sample);

xi: areg lagherf m99incr demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi indfrac_diff hmofrac_diff 
ppofrac_diff plandesign_diff i.year i.mktcode if year<=2002 & texas==0 & sample1==1, a(uniqnum) robust;
est store first;

xi: xtivreg lorig_diff (lagherf = m99incr) demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff i.year i.mktcode if year<=2002 & texas==0, i(uniqnum) fe;

est store iv;

xi: xtreg lorig_diff lagherf demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi
indfrac_diff hmofrac_diff ppofrac_diff plandesign_diff i.year i.mktcode if year<=2002 & texas==0, i(uniqnum) fe;
est store ols;

estout *  using "results/Table 5.txt", cells (b(star fmt(%9.4f)) se(par)) 
keep(m99incr lagherf demofactor_diff sifrac_diff llnaapcc luerate lhosp_hhi indfrac_diff hmofrac_diff
ppofrac_diff plandesign_diff , relax ) style(fixed) stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) 
starlevels(* 0.10 ** 0.05 *** .01) legend label replace;
est drop *;
/**************************************************************************************
				APPENDIX TABLE 2: OTHER DEP VARS
***************************************************************************************/

tsset uniqmkt year;
sort uniqmkt year;

	xi: areg hmofrac_diff m99incr txm99incr llnaapcc luerate lhosp_hhi 
	i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
	est store m1;

	xi: areg indfrac_diff m99incr txm99incr llnaapcc luerate lhosp_hhi 
	i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
	est store m2;

	xi: areg ppofrac_diff m99incr txm99incr llnaapcc luerate lhosp_hhi 
	i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
	est store m3;

	xi: areg sifrac_diff m99incr txm99incr llnaapcc luerate lhosp_hhi 
	i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
	est store m4;

	xi: areg plandesign_diff m99incr txm99incr llnaapcc luerate lhosp_hhi 
	i.year i.mktcode if year<=2002, cluster(mktcode) a(uniqcode);
	est store m5;

	estout *  using "OATable2.txt", cells (b(star fmt(%9.4f)) 
	se(par)) keep(m99incr txm99incr , relax ) style(fixed)
	stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) starlevels(* 0.10 ** 0.05 *** .01) legend label replace;

	est drop *;



/**************************************************************************************
				TABLE 3: FIRST STAGE REGRESSIONS (MARKET-YEAR LEVEL)
***************************************************************************************/

*First collapse data to Market-year level;

collapse herf lagherf fourfirm lagfourfirm merger99incr diff99max txmerger99incr texas demofactor_diff indfrac_diff
hmofrac_diff ppofrac_diff plandesign_diff, by (mktcode year);

* Merging on market year covariates;
sort mktcode year;
merge mktcode year using mktyrcov;tab _m; drop _m; 
ge lnaapcc = ln(aapcc);

ge txpost00 = texas * (year>=2000);
gen m99incr = merger99incr * (year>=2001 & year!=.);
gen m99incr99 = diff99max * (year==1999);
gen m99incr00 = diff99max * (year==2000);
gen m99incr01 = merger99incr * (year==2001);
gen m99incr02 = merger99incr * (year==2002);
gen m99incr03 = merger99incr * (year==2003);
gen m99incr04 = merger99incr * (year==2004);
gen m99incr05 = merger99incr * (year==2005);
gen m99incr06 = merger99incr * (year==2006);

xi: areg herf m99incr99 m99incr00 m99incr01 m99incr02 m99incr03 i.year if texas==0 & year<=2003, a(mktcode) robust;
est store m1;
xi: areg herf merger99incr i.year if texas==0 & year<=2001, a(mktcode) robust;
est store m2;
xi: areg herf merger99incr txmerger99incr i.year if  year<=2001, a(mktcode) robust;
est store m3;
xi: areg herf merger99incr txmerger99incr txpost00 i.year if  year<=2001, a(mktcode) robust;
est store m4;

estout *  using "results/Table3.txt",cells (b(star fmt(%9.4f)) se(par)) keep(m99incr99 m99incr00 m99incr01 
m99incr02 m99incr03 merger99incr txmerger99incr txpost00, relax ) style(fixed) 
stats(r2 N,fmt(%9.4f %9.0g) labels(R-Squared)) starlevels( * 0.10 ** .05 *** .01) legend label replace;
est drop *;





