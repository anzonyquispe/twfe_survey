# delimit;
clear;
set mem 600m;
set more off;
capture log close;

/*************************************************************************************************
This program starts from our main dataset plandata.dta(containing all plans and organized at the plan level) 
and creates the sample at the Employer-Market-Year level that we use in the rest of our analysis. 
It also creates the first-differenced versions of the dependent variables and predictors that are
used in the specifications.
 
 Abbreviations:
 SI: Self-Insured Plans
 FI: Fully-Insured Plans
 IND: Indemnity Plans

***************************************************************************************/

use plandata.dta;

drop if plantype=="EPO";

egen mktsiemp = sum(totalemployees*(instype==2)), by(mktcode year);
egen mkttotemp = sum(totalemployees), by(mktcode year);
gen siemp = totalemployees if instype==2;

* first calculate the number of firms in market-year;

sort mktcode uniqcode year;
quietly by mktcode uniqcode year: gen temp = _n;
replace temp = 0 if temp!=1;
egen numfirms = sum(temp), by(mktcode year);

* collapse number of employees by market-carrier-year to calculate herf;
* also total premium and total demo;

gen totprem = totalemployees * originalrate;
gen totdemo = totalemployees * demofactor;

collapse (mean) mktsiemp mkttotemp (sum) siemp totalemployees totprem totdemo, 
by(mktcode carriercode year numfirms);

* We calculate number of carriers and each carrier's share the latter of which will be used to compute the HHI;
sort mktcode year carriercode;
egen numcarr = count(year), by (mktcode year);
egen mktemp = sum(totalemp), by(mktcode year);
gen  carrshare = totalemp / mktemp;

gen  herf = carrshare * carrshare;

* We replace Prudential's carrier code with Aetna's code in 1999 to siumlate the merger and calculate simulated HHI;
replace carriercode = 1 if year==1999 & carriercode==22;

collapse (mean) mktsiemp mkttotemp numcarr (sum) siemp totalemployees herf totprem totdemo, 
by(mktcode carriercode year numfirms);

* We now calculate what the HHI would have been in 99 if aetna and pru were one. This will be used to constructed the Simulated HHI measure;

egen mktemp = sum(totalemp), by(mktcode year);
gen  carrshare = totalemp / mktemp;
gen simherf = carrshare * carrshare; 

* now collapse down to market year;
collapse (mean) mktsiemp mkttotemp (sum) siemp herf simherf totalemployees totprem totdemo, by(mktcode year numfirms);

* log of average premium and avg demo factor;
gen avgprem  = totprem / totalemployees;
gen lavgprem = log(totprem / totalemployees);
gen avgdemo  = totdemo / totalemployees;
gen lavgdemo = log(totdemo / totalemployees);

* We compute the diff b/w simulated and actual herf in 1999 and assign it to each market;
gen diff99 = simherf - herf if year==1999;
egen diff99max = max(diff99), by(mktcode);

* We turn our instrument "on" if year>=2000 after the merger has occurred;
gen merger99incr = diff99max * (year>=2000);

gen sifrac = mktsiemp / mkttotemp;

xi i.year;

* We create a separate indicator for Texas markets;
gen texas = (mktcode>=103.5 & mktcode<=109.5);
tab mktcode if texas==1, missing;
gen txmerger99incr = merger99incr * texas;

keep herf txmerger99incr merger99incr mktcode year texas diff99max;

sort mktcode year;
quietly by mktcode: gen lagherf = herf[_n-1];
tab year;

tsset mktcode year;
ge herf_diff = d.herf;
sort mktcode year;

/*The file simherf contains the actual and simulated HHIs for each mkt-year.*/

save simherf, replace;

/*WE now construct the firm*market*year level sample */;
use plandata.dta, clear;

gen siemp = (totalemployees * (instype==2));
gen hmoemp = (totalemployees * (plantype=="HMO"));
gen indemp = (totalemployees * (plantype=="IND"));
gen posemp = (totalemployees * (plantype=="POS"));
gen ppoemp = (totalemployees * (plantype=="PPO"));
gen ppo_indemp = (totalemployees * ((plantype=="IND")|(plantype=="PPO")));

ge aetnaemp = (totalemployees * (carriercode == 1));
ge pruemp = (totalemployees * (carriercode == 22));

ge aetna_hmoemp = aetnaemp * (plantype=="HMO");
ge pru_hmoemp = pruemp * (plantype=="HMO");

ge nonap_hmoemp = (totalemployees * (plantype=="HMO") * (carriercode!=1 & carriercode!=22));
ge nonap_posemp = (totalemployees * (plantype=="POS") * (carriercode!=1 & carriercode!=22));
ge nonap_ppoindemp = (totalemployees * (plantype=="PPO"|plantype=="IND") * (carriercode!=1 & carriercode!=22));

* type of insurance;
drop if plantype=="EPO";

sort mktcode uniqcode carriercode year;
quietly by mktcode uniqcode carriercode year: gen numcarrs = _n;
replace numcarrs = 0 if numcarrs!=1;

gen totdemo = demofactor * totalemployees;
gen totorig = originalrate * totalemployees;
gen totpland = plandesign * totalemployees;

collapse (sum) totalemployees siemp hmoemp indemp ppoemp posemp ppo_indemp aetnaemp pruemp numcarrs totdemo nonap*
aetna_hmoemp pru_hmoemp totpland totorig, by(mktcode uniqcode year);

gen demofactor   = totdemo / totalemployees;
gen plandesign = totpland / totalemployees;
gen originalrate = totorig / totalemployees;

gen lorig = log(originalrate);

gen sifrac = siemp / totalemployees;
gen hmofrac = hmoemp / totalemployees;
gen indfrac = indemp / totalemployees;
gen ppofrac = ppoemp / totalemployees;
gen posfrac = posemp / totalemployees;
ge ppoindfrac = ppo_indemp / totalemployees;

* computing shares of Aetna and Prudential;
ge aetsh = aetnaemp/totalemployees;
ge prush = pruemp/totalemployees;
ge apsh = aetsh + prush; 

sort mktcode year;
merge mktcode year using simherf;
tab _merge;
drop _merge;

* xi i.mktcode;

gen ltotemp = log(totalemployees);

egen uniqmkt = group(uniqcode mktcode);
egen mktyear = group(mktcode year);
egen uniqyr = group (uniqcode year);

ge apsh99_tmp = apsh if year == 1999;
egen apsh99 = max(apsh99_tmp), by (uniqmkt);

ge numempl99_tmp = totalemployees if year==1999;
egen numempl99 = max(numempl99_tmp), by(uniqmkt);

ge sifrac99_tmp = sifrac if year==1999;
egen sifrac99 = max(sifrac99_tmp), by(uniqmkt);

drop *tmp;

* creating an indicator for employer-markets present in 99 and 02;
egen in99 = max(year==1999), by(uniqmkt);
egen in02 = max(year==2002), by(uniqmkt);

/* Merge on datasets that contain market-year controls: AAPCC (Medicare) cost data, Hospital HHI data and Unemployment rate data */
sort mktcode year;
merge mktcode year using aapcc97_06, nokeep;
tab _m;
drop _m;
sort mktcode year;
merge mktcode year using hosp_hhi, nokeep;
tab _m;
drop _m;
sort mktcode year;
merge mktcode year using uerate97_06, nokeep;
tab _m;
drop _m;
replace uerate=uerate/100;
replace luerate=luerate/100;
ge lnaapcc = ln(aapcc);
gen llnaapcc = ln(laapcc);

/*We compute annual changes in the variables*/

tsset uniqmkt year;
sort uniqmkt year;
foreach var of varlist lorig demofactor plandesign ltotemp luerate laapcc llnaapcc lhosp_hhi hmofrac ppofrac
posfrac indfrac {;
	ge `var'_lag = l.`var';
	ge `var'_diff = `var' - `var'_lag;
};

*Compute a version of the simulated HHI that turns on in 2001 and beyond (since our main predictor is lagged);
gen m99incr = merger99incr * (year>=2001 & year!=.);
egen uniqnum = group(uniqcode);
ge txm99incr = texas * m99incr;


/*We now compute long differences in the dependent variable and some of the independent variables*/

foreach var of varlist lorig lagherf demofactor plandesign ltotemp luerate laapcc llnaapcc lhosp_hhi 
hmofrac ppofrac posfrac indfrac {;
	sort uniqcode mktcode year;
	bysort uniqcode mktcode: ge tmp`var'1999 = `var' if year==1999;
	bysort uniqcode mktcode: ge tmp`var'2002 = `var' if year==2002;
	bysort uniqcode mktcode: ge tmp`var'2006 = `var' if year==2006;
	egen `var'1999 = max(tmp`var'1999), by (uniqmkt);
	egen `var'2002 = max(tmp`var'2002), by (uniqmkt);
	egen `var'2006 = max(tmp`var'2006), by (uniqmkt);
	ge d`var'9906 = `var'2006 - `var'1999;
	ge d`var'9902 = `var'2002 - `var'1999;
	ge d`var'0206 = `var'2006 - `var'2002;
	drop tmp*;
};

tsset uniqmkt year;
sort uniqmkt year;
compress;
save emy_simherf, replace;
