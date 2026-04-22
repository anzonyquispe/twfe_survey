#delimit;
****************************************************;
* mainanalysis_communitydata.do;
* t. dinkelman;
* replication version: jan 2011;
****************************************************;
/* The construction of the main data set is explained in the text and Data Appendix. Briefly, it combines:
Community census data (variable totals and proportions) extracted from the 100% Census for 1996 and 2001
matched (using ArcGis) to:
- geographic measures of community land gradient, distance to the nearest road and town, and distance to the electricity grid in 1996 (all measures created in arcgis)
- administrative data on the location and year of Eskom projects taking places across rural KZN
- number of schools from the 1995 and 2000 Schools Register of Needs
- a measure of political heterogeneity constructed from the fraction of votes won by each party in the 2000 municipal elections 

The Census "sub-place" defines the community. 

The sample here consists of all communities located in tribal KZN that are not defined by census geography as:
- beaches, nature/game reserves, prisons, mines and collieries
- part of the durban metro region
- communities with zero population in either year

In addition, I exclude a subset of these tribal areas that received Eskom projects prior to 1996 - this sample
is the placebo sample.
*/;

* set the output folder;
cd "$temp";

******************* SET UP **********************;
use "$data\matched_censusdata.dta", clear;

* sample restriction to areas with at least 100 adults in both years;
* REMOVE THIS COMMAND IF RUNNING OVER ENTIRE SAMPLE THAT INCLUDES VERY SMALL AREAS;
keep if largearea==1;


******************* DEFINE TREATMENT **********************;
global treatment1="T";
*****************************************************************;

******************* DEFINE MAIN YVARS **********************;
global y1 = "d_prop_emp_f d_prop_emp_m";
******************* YVARS **********************;

******************* DEFINE XVARS **********************;
* list of outreg variables;
global list= "";
global list2= "";
global list3= "";

* x's are measured at baseline 1996 (suffix=0);
global x1 ="kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0";
global xadd="d_prop_waterclose d_prop_flush";

* define district and and cluster vars;
global districtfe="dccode0";
global cluster="placecode0";
global correctse="robust cluster(placecode0)";

* create total populations in each period;
gen adult_africans0=adult_african_f0 + adult_african_m0;
gen adult_africans1=adult_african_f1 + adult_african_m1;
******************* DEFINE XVARS **********************;

******************* DEFINE IVS **********************;
global iv = "mean_grad_new";
******************* DEFINE IVS **********************;


******************* DEFINE STATISTICS TO BE CAPTURED **********************;
* for first stage;
global addstat1="addstat(F-stat: all IV's =0:, r(F),Prob>F:,r(p))";
******************* DEFINE STATISTICS TO BE CAPTURED **********************;

********************* DEFINE EXTRACTION ROUTINE  *****************;
* extracts output from multiple regressions for use in excel/tex;
cap program drop extract;
program define extract;
	outreg2 $list1 $list2 using "result_$stage$yvar$label.out",
	nolabel se bdec(3) rdec(3)
	$addstat $which;
end;

* second type of extraction routine, without significance stars;
cap program drop extractnostar;
program define extractnostar;
	outreg2 $list1 $list2 using "result_$stage$yvar$label.out",
	nolabel se noaster bdec(6) rdec(3)
	$addstat $which;
end;
********************* DEFINE EXTRACTION ROUTINE *****************;

********************* DEFINE FIRST STAGE PROGRAM *****************;
cap program drop firststage;
program define firststage ;
	****************************************************************************;
	* Firststage for yvariable "$yvar";
	***************************************************************************;
	global list1="";
	global list2="";
	global addstat="$addstat1";
	global correctse = "robust cluster($cluster)";
	
	global which="replace";
	global list1 ="$iv";
	xi: reg $yvar $iv, $correctse;
	test $iv;
	extract;
	sum $yvar $iv if e(sample);

	global which="append";

	global list1 ="$iv $x1";
	xi: reg $yvar $iv $x1, $correctse;
	test $iv;
	extract;
	sum $yvar $iv if e(sample);

	xi: reg $yvar $iv $x1 i.$districtfe, $correctse;
	test $iv;
	extract;

	global list2 ="$xadd";
	xi: reg $yvar $iv $x1 $xadd i.$districtfe, $correctse;
	test $iv;
	extract;
end;
********************* DEFINE FIRST STAGE PROGRAM *****************;

********************* DEFINE SECOND STAGE PROGRAM *****************;
cap program drop secondstage;
program define secondstage;
	******************************************************;
	* OLS REGRESSIONS FOR OUTCOME MEASURE $yvar;
	******************************************************;
	global type="ols";
	global which="replace";
	global list1="";
	global list2="";

	sum $yvar;

	global list1="$mainx";
	di "reg $yvar $mainx, $correctse";
	reg $yvar $mainx, $correctse;
	extractnostar;

	sum $yvar $mainx if e(sample);
	global which="append";
	estimates store ols1;

	global list1="$mainx $x1";
	di "xi: reg $yvar $mainx $x1,$correctse ";
	reg $yvar $mainx $x1,$correctse ;
	extractnostar;

	di "xi: areg $yvar $mainx $x1 ,$correctse abs($districtfe)";
	xi: reg $yvar $mainx $x1 i.$districtfe $qualif,$correctse ;
	extractnostar;

	global list2="$xadd";
	di "xi: areg $yvar $mainx $x1 $xadd, $correctse ab($districtfe)";
	xi: reg $yvar $mainx $x1 $xadd i.$districtfe,$correctse ; 
	extractnostar;

	global list1="$iv";
	global list2="$x1 $xadd";
	di "areg $yvar $iv $x1 $xadd i.$districtfe, $correctse ";
	xi: reg $yvar $iv $x1 $xadd i.$districtfe, $correctse ;
	extractnostar;
	global type="iv";

	global list1="$mainx";
	global list2="";
	di "ivregress $yvar ($ivstatement),$correctse";
	ivreg2 $yvar ($ivstatement), $correctse;
	extractnostar;

	global list1 ="$mainx $x1";
	di "ivregress $yvar ($ivstatement) $x1 ,$correctse";
	xi: ivreg $yvar ($ivstatement) $x1 ,  $correctse;
	extractnostar;

	di "ivregress $yvar ($ivstatement) $x1 i.$districtfe ,$correctse";
	xi: ivreg $yvar ($ivstatement) $x1 i.$districtfe ,  $correctse;
	extractnostar;

	global list2="$xadd";
	di "ivregress $yvar ($ivstatement) $x1 $xadd i.$districtfe ,$correctse";
	xi: ivreg $yvar ($ivstatement) $x1 $xadd i.$districtfe ,  $correctse;
	extractnostar;

	global list1="";
	global list2="";
end;
********************* DEFINE SECOND STAGE PROGRAM *****************;



********************* DEFINE AR-CI PROGRAM *****************;
* computes output for generating anderson-rubin confidence intervals by hand, following hansen and chernosukov (2007);
* grid search over range of 'acceptable' beta's;
* acceptable range = values in the confidance bands that the canned routine spits out;
* set these values specific to each outcome for which you are estimating these regressions;
* get the c.i. region that is corrected for clustering.;
* this may be difft to stata's clr output (canned routine) which does not correct for clustering;
cap program drop artest;
program define artest;
	global which="replace";
	global list1="$iv";
	global list2="";
	local b=$b;
	while `b'<=$max {;
		gen eresid=$yvar-`b'*$mainx;	
		xi: reg eresid $iv $x1 i.dccode0, $correctse;
		global addstat="ctitle(beta0 is `b')";
		global stage="artest1";
		extractnostar;
		xi: reg eresid $iv $x1 $xadd i.dccode0, $correctse;
		global stage="artest2";
		extractnostar;
		global which="append";
		drop eresid;
		local b=`b'+0.05;
	};
end;
********************* DEFINE AR-CI PROGRAM *****************;


****************** FIGURE 1: FUEL USE OVER TIME ***************;
tabstat prop_wood0 prop_eleccook0 prop_elec0 prop_candles0, by(T); 
tabstat prop_wood1 prop_eleccook1 prop_elec1 prop_candles1, by(T); 
* create graph in excel;
****************** FIGURE 1: FUEL USE OVER TIME ***************;

****************** FIGURE 3: CAPTURE OUTCOME VARS AND TREATMENTS for MAPPING ***************;
* note: export this data to a dbf file, read in to arcgis along with the KZN boundaries to create Fig 1A and Fig 1B
local var ="T mean_grad_new";
foreach one of local var {;
	outsheet spcode `one' using "$temp\elec_cov_maps_`one'.out", replace;
};
outsheet spcode if largearea==1 using "$temp\maps_sample.out", replace;
****************** FIGURE 1: CAPTURE OUTCOME VARS AND TREATMENTS for MAPPING ***************;


***************************************************************************************;
******************* TABLE 1: compare baseline x's by T **************************;
***************************************************************************************;
* compare value of baseline x's across T, no controls;
global yvar="";
global stage="";
global label="sumstats";
global addstat="";

global which="replace";
global list1="T";
global list2="";
tabstat $x1 mean_grad_new, by(T) s(mean sd);
foreach one of global x1 {;
	reg `one' T;
	extract;
	global which="append";
};
reg mean_grad_new T ;
extract;

* compare value of baseline x's across gradient, no controls;
global label="summstats2";
global list1="mean_grad_new";
foreach one of global x1 {;
	reg `one' mean_grad_new, $correctse;
	extract;
	global which="append";
};

* compare value of baseline x's across gradient, add in other controls;
xi: reg kms_to_subs0 mean_grad_new
baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg baseline_hhdens0 mean_grad_new 
kms_to_subs0 base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg base_hhpovrate0 mean_grad_new
kms_to_subs0 baseline_hhdens0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg prop_head_f_a0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg sexratio0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg prop_indianwhite0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 
kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg kms_to_road0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_town0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg kms_to_town0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 prop_matric_m0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg prop_matric_m0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_f0
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;

xi: reg prop_matric_f0 mean_grad_new 
kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 
d_prop_waterclose d_prop_flush i.$districtfe, $correctse;
extract;
***************************************************************************************;



***************************************************************************************;
******************* TABLE 2: diff in diff for employment outcomes ***************;
***************************************************************************************;
tabstat prop_emp_m0 prop_emp_f0 prop_emp_m1 prop_emp_f1, s(mean sd n);
tabstat prop_emp_m0 prop_emp_f0 prop_emp_m1 prop_emp_f1 if T==1, s(mean sd n);
tabstat prop_emp_m0 prop_emp_f0 prop_emp_m1 prop_emp_f1 if T==0, s(mean sd n);

global label="sumstats_dd";
global which="replace";
global list1="T";

* across column differences 1996;
reg prop_emp_f0 T;
extract;
global which="append";
reg prop_emp_m0 T;
extract;

* across column differences 2001;
reg prop_emp_f1 T;
extract;
global which="append";
reg prop_emp_m1 T;
extract;

* DD;
reg d_prop_emp_f T;
extract;
reg d_prop_emp_m T;
extract;

* across time differences;
preserve;
global list1="year";
keep prop_emp_f* prop_emp_m* spcode;
reshape long prop_emp_f prop_emp_m, i(spcode) j(year);
foreach one of varlist prop_emp_f prop_emp_m {;
	ttest `one', by(year);
	reg `one' year;
	extract;
	};
restore;
***************************************************************************************;

***************************************************************************************;
******************* TABLE 3: first stage **************************;
***************************************************************************************;
global stage="fs";
global label="";
global treatment1="T";
foreach treated of global treatment1 {;
	global mainx = "";
	global yvar = "`treated'";
	global iv = "$iv";
	global label="`treated'";
	firststage;
};
global addstat="";


***************************************************************************************;
******************* TABLE 4: employment results for men and women ***************;
***************************************************************************************;
global stage="ss";
global iv="mean_grad_new";
global yvar="d_prop_emp_f d_prop_emp_m";
foreach treated of global treatment1 {;
	global mainx="`treated'";
	foreach one of global y1 {;
		global yvar="`one'";
		global label="`treated'";
		global ivstatement="$mainx=$iv";
		secondstage;
	};
};

* construct ar confidence intervals by hand;
* to do so: open output in excel, identify the range of proposed coefficients which cannot be rejected;
global b=-0.6;
global max=1;
global treatment1="T";
foreach treated of global treatment1 {;
	global mainx="`treated'";
	global label="`treated'";
	foreach one of varlist d_prop_emp_f d_prop_emp_m {;
		global yvar="`one'";
		artest;
	};
};


#delimit;
***************************************************************************************;
******************* TABLE 5 (second part): RULING OUT DEMAND SHOCKS ****;
***************************************************************************************;
* ruling out shocks to teacher demand;
global list2="";
global yvar="d_schools";
global which="replace";
global label="d_schools";
global list1="mean_grad_new";
xi: reg $yvar $list1 $x1 $xadd i.$districtfe, $correctse;
extractnostar;
global which="append";

* showing that indian and white employer shocks are not correated with gradient;
global list2="";
global yvar="d_prop_indianwhite";
global which="replace";
global label="d_indian";
global list1="$iv";
xi: reg $yvar $iv $x1 $xadd i.$districtfe, $correctse;
extractnostar;
***************************************************************************************;



***************************************************************************************;
******************* TABLE 6: uses hh survey data; 
* created in supplanalysis_hhsurveydata.do *****;
***************************************************************************************;


***************************************************************************************;
******************* TABLE 7: main results for services **************************;
***************************************************************************************;
sum d_prop_elec d_prop_wood d_prop_eleccook d_prop_waterclose d_prop_flush;

global table="7";
global which="replace";
global y="d_prop_elec d_prop_candles d_prop_wood d_prop_eleccook";
global stage="ss";
global iv="mean_grad_new";
foreach one of global y {;
	global mainx="T";
	global yvar="`one'";
	global ivstatement="$mainx=$iv";
	secondstage;
};

global xaddhold="$xadd";
global xadd="";
global y="d_prop_waterclose d_prop_flush";
global stage="ss";
foreach one of global y {;
	global mainx="T";
	global yvar="`one'";
	global ivstatement="$mainx=$iv";
	secondstage;
};
global xadd="$xaddhold";
***************************************************************************************;

***************************************************************************************;
******************* TABLE 8: TESTING FOR SPILLOVERS ***********************************;
***************************************************************************************;
* restricting to control places NOT close to prior or concurrent treated areas;
global mainx="T";
global stage="ss";
local list="1 5";
local i = 1 ;
while `i'<=2 {;
	local k: word `i' of `list';
	global if = "if ((nearby_T_before_`k'km==0&nearby_T_during_`k'km==0)|T==1)";
	preserve;
	keep $if;
	count;
	tab T nearby_T_during_`k'km;
	tab T nearby_T_before_`k'km;
	global mainx="T";
	foreach y of global y1 {;
		global yvar="`y'";
		global label="`y'_outside`k'km";
		global ivstatement="$mainx=$iv";
		secondstage;
	};
	restore;
	local i = `i'+1;
};
***************************************************************************************;

********************************************************************************************************;
* TABLE 9 COMPOSITION CHANGES;
********************************************************************************************************;
* change in log population, log noninmigrant pop, and change in employment excluding inmigrants;
global ynew="d_logafrican_ppl dlogpop_nomig d_prop_lfs_emp_f_nomig d_prop_lfs_emp_m_nomig";
global mainx="T";
foreach one of global ynew {;
	global yvar="`one'";
	global label="`treated'_ppl";
	global ivstatement="$mainx=$iv";
	secondstage;
};

* change in fraction men/women with matric;
global xhold="$x1";
global x1="kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0 kms_to_road0 kms_to_town0";
global stage="ss";
global which="replace";
global iv="mean_grad_new";
global yschool="d_prop_matric_f d_prop_matric_m";
global ivstatement="T=mean_grad_new";
global mainx="T";
foreach one of global yschool {;
	global yvar="`one'";
	global label="`one'";
	secondstage;
};
global x1="$xhold";	
********************************************************************************************


*********************************************************************************************
************** APPENDICES **********************************************************************
*********************************************************************************************


*******************************************************************;
************************ APPENDIX 2: HETEROGENEOUS EFFECTS ********;
*******************************************************************;
*********************** WHICH SUBGROUPS DRIVE THE LATE? ***********;
*********************** APPENDIX 2: FIGURE 1 **********************;
*********************** APPENDIX TABLES 1 and 2 *********************;
*******************************************************************;
* follow Kling (2001) and Card (1995) approach;
* summarize the information in the poverty variables;
xtile gradhalf=mean_grad_new, nq(2);
tab gradhalf, sum(mean_grad_new);
recode gradhalf (2=0);
xi: reg T base_hhpovrate0 sexratio0 prop_head_f_a0 if gradhalf==0;
predict treathat;

* Appn 2 Table 1: create quintiles of the poverty index using the cut points from the steep guys;
cap drop temp;
xtile temp=treathat if gradhalf==0, nq(5);
tab temp, sum(treathat);
sum treathat if temp==1;
gen newtreatq=1 if treathat<=r(max);
sum treathat if temp==2;
replace newtreatq=2 if treathat<r(max) & newtreatq==.;
sum treathat if temp==3;
replace newtreatq=3 if treathat<r(max) & newtreatq==.;
sum treathat if temp==4;
replace newtreatq=4 if treathat<r(max) & newtreatq==.;
sum treathat if temp==5;
replace newtreatq=5 if treathat<=r(max) & newtreatq==.;
tab newtreatq, gen(tq2);

* what is fuel use like in each disadvantage quintile? 1 is poorest, 5 is richest;
tabstat prop_wood0 prop_eleccook0 prop_elec0 , s(mean sd) by(newtreatq);
tabstat prop_paracook0 prop_gascook0 prop_elec_othcook0 , s(mean sd) by(newtreatq);


* what is lambda? lambda=P(Z|x,q)(1-P(Z|x,q), averaged within Q;
xi: reg gradhalf base_hhpovrate0 prop_head_f_a0 sexratio0 
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0 $xadd 
tq22 tq23 tq24 tq25 i.dccode0, $correctse;
predict ghat;
gen lambda2=ghat*(1-ghat);
tab newtreatq, sum(lambda2);

* what is ddelec|q,x?;
gen tqz12=tq21*gradhalf;
gen tqz22=tq22*gradhalf;
gen tqz32=tq23*gradhalf;
gen tqz42=tq24*gradhalf;
gen tqz52=tq25*gradhalf;

* using gradient as a dummy;
xi: reg T base_hhpovrate0 prop_head_f_a0 sexratio0
prop_indianwhite0 kms_to_road0 kms_to_town0 prop_matric_m0 
prop_matric_f0 $xadd tqz12 tqz22 tqz32 tqz42 tqz52 i.dccode0, $correctse;

* Appn 2 Table 2: now look at how the change in fuel use breaks down across categories;
replace prop_wood1=0 if prop_wood1==. & hhcount1>0 /*9 observations*/;
gen dwood=prop_wood1-prop_wood0;;
gen dcookelec=prop_eleccook1-prop_eleccook0;

foreach one of varlist 
d_prop_elec dcookelec dwood d_prop_emp_f d_prop_emp_m {;
	xi: reg `one' $x1 $xadd tqz12 tqz22 tqz32 tqz42 tqz52 i.dccode0, $correctse;
	outreg2 using "$temp\klingeffects_`one'", se replace;
};


**** APPX 2: FIGURE 1;
preserve;
collapse T (sd) sd_T=T (count) n_T=T,
by(newtreatq gradhalf);
twoway 
(line T newtreatq if gradhalf==1)
(line T newtreatq if gradhalf==0),
legend(order (1 "Areas of flattest slope" 1 "Areas of steepest slope"))
ytitle("change in frac. of hhs with electric lighting", size(vsmall))
xtitle("quintiles of poverty index", size(small))
scheme(s2mono);
graph save "$temp\late2.gph", replace;
graph export "$temp\late2.eps", replace;
graph export "$temp\late2.png", replace;
restore;

*******************************************************************;
* APPX 2 FIGURE 2*************************;
* created using Census micro data 10% sample in other.do;
*******************************************************************;

**************************************************************************************;
*********************** APPX 2 TABLE 3: AGE RESULTS*********************** ;
***************************************************************************************;
global which="replace";
* results for each age group of women;
local age="1519 2024 2529 3034 3539 4044 4549 5054 5559";
local sex = "f";
foreach s of local sex {;
	global which="replace";
	foreach a of local age {;
		gen d_prop_lfs2_`s'_emp_`a'=(emp_age`a'_a_`s'1/adult_african_`s'1)-(emp_age`a'_a_`s'0/adult_african_`s'0);
		noisily assert d_prop_lfs2_`s'_emp_`a'!=.;
		global yvar="d_prop_lfs2_`s'_emp_`a'";
		global label="age2_`a'_`s'";
		secondstage;
		global which="append";
	};
};
***************************************************************************************;


************************************************************************;
************************************************************************;
******************** APPENDIX 3 ****************************************;
************************************************************************;
************************************************************************;



************************************************************************;
******************** APPENDIX 3 TABLE 1: ROBUSTNESS FOR First stage ***;
************************************************************************;
* specification: including political variables;
global stage="fs";
global mainx = "";
global iv = "mean_grad_new hetindex";
global label="ivpoldelec";
global yvar="T";
global list1="$iv hetindex";
global which="replace";
firststage;

* restricting sample to areas without major roads;
preserve;
keep if count_roads==0;
global mainx="";
global iv="mean_grad_new";
global yvar="T";
global list1="$iv";
global which="replace";
firststage;
restore;
***************************************************************************************;


************************************************************************;
******************** APPENDIX 3 TABLE 2: ROBUSTNESS FOR Second Stage ***;
************************************************************************;
* robustness: adding in political variables;
global addstat="";
global stage="ss";
global label="ss_pols";
global which="replace";
global xtemp="$x1";
global x1="$x1 hetindex";
global iv="mean_grad_new";

foreach treated of global treatment1 {;
	global mainx="`treated'";
	foreach one of global y1 {;
		global yvar="`one'";
		global ivstatement="$mainx=$iv";
		secondstage;
	};
};
global x1="$xtemp";

* robustness: restrict to places without major roads
global which="replace";
global label="ss_noroads";

preserve;
drop if count_road==1;
global iv="mean_grad_new";
foreach treated of global treatment1 {;
	global mainx="`treated'";
	foreach one of global y1 {;
		global yvar="`one'";
		global ivstatement="$mainx=$iv";
		secondstage;
	};
};
restore;


************************************************************************;
******************** APPENDIX 3 TABLE 4, 5, 6: FS + SS, s.e. corrected for spatial correlation***;
************************************************************************;
* these tables are produced in aupplanalysis_spatialse.do;


************************************************************************;
******************** APPENDIX 3 TABLE 7: DIFFEERNCE IN FEMALE/MALE LFP GROWTH ***;
************************************************************************;
gen dfm=d_prop_emp_f-d_prop_emp_m;
global treatment1="T";
global yvar="dfm";
global label="menfemdifftest";
global stage="ss";
global which="replace";
foreach treated of global treatment1 {;
	global mainx="`treated'";
	global label="`treated'_menfemdifftest";
	global ivstatement="$mainx=$iv";
	secondstage;
};


********************************************************;
************ APPENDIX 3 Table 8: created in other.do*********;
********************************************************;
* uses hh survey data;
* created in other.do;


************************************************************************;
************************************************************************;
******************** APPENDIX 4 ****************************************;
************************************************************************;
************************************************************************;

********************************************************;
************ APPENDIX 4 Table 1-3:*********;
********************************************************;
* uses a combination of data;
* created in other.do;

#delimit;
***************************************************************************************;
******************* APPENDIX TABLE 4: CHECKING THE EXTENT OF MEASUREMENT ERROR *****************;
***************************************************************************************;
gen Told=1 if d_prop_elec>=0.1;
replace Told=0 if d_prop_elec<0.1;
tab T Told;
tab T Told, sum(prop_elec0) means;

* use sample only if T=1 areas had large change in prop_elec (more than 10%), if T=0 areas;
* had small change in prop_elec;
global ivstatement="T=mean_grad_new";
global stage="ss";
global mainx="T";
global which="replace";
preserve;
keep if T==Told;
foreach one of global y1 {;
	global yvar="`one'";
	global label="clean";
	secondstage;
};
restore;

* use high connection rate as marker for treatment;
global ivstatement="T=mean_grad_new";
global stage="ss";
global mainx="T";
preserve;
keep if (connectrate_during==0|connectrate_during>.8);
foreach one of global y1 {;
	global yvar="`one'";
	global label="`treated'_crate";
	secondstage;
};
restore;

clear;
***************************************************************************************;
***************************************************************************************;


*******************************************************************************************************************;
*********** TABLE 5: Placebo experiment - RELATIONSHIP BETWEEN CHANGE IN EMPLOYMENT AND GRADIENT IN EARLY TREATED AREAS;
********************************************************************************************************************;
use "$data\placebodata.dta", replace;
keep if large==1;
global which="replace";
global label="beforetest";
global list1="mean_grad_new";
xi: reg d_prop_emp_f mean_grad_new $x1 $xadd i.$districtfe if treatment_after!=., $correctse;
extractnostar;
clear;

