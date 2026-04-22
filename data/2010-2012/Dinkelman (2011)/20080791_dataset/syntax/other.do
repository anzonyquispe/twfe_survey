#delimit;
************************;
* additional results for electricity paper;
* Appendix 2 Figure 2: using census 10% microdata;
* Appendix 3 Table 8: features of outmigrants;
* Appendix 4: tables 1-3;
********************************************************;

********************************************************;
************ APPENDIX 2 Figure 2:  proportion of women with kids aged <=9 *********;
********************************************************;
* Data are from 1996 Census 10% sample;
* Sample here includes rural areas of KZN, women and men of all ages;
* Data contain indicator for at least 1 child under age 9 or age7 in household;
use "$data\kidsunder9_96.dta", clear;

* keep women only;
keep if SEX==2;
collapse under7 under9, by(age);
lowess under9 age if age>=15&age<=59,
scheme(s2mono) ytitle("fraction living with young child", size(small))
title("") xtitle(age of woman) bw(0.4);
graph save "$temp\kidsunder9_96.gph", replace;
graph export "$temp\kidsunder9_96.eps", replace;
graph export "$temp\kidsunder9_96.png", replace;
clear;

#delimit;
********************************************************;
************ APPENDIX 3 Table 8:  features of outmigrants and
* stayers by hgh and low levels of elec *********;
********************************************************;
* Data are from September LFS 2002;
* Sample here includes african adults in rural kzn btwn ages 15 and 59;
* Module on migrants from the household used ot produce migration variables;
* Data contain variable notes;
use "$data\lfs02_migrantdata.dta", clear;

local x migrant educstayers educmigrant matricstayer matricmigrant workstayer workmigrant;
keep `x' highelecmd educ work pweight;

global wt="";
tabstat `x' `wt' , by(highelecmd);

* test across rows;
foreach one of local x {;
	ttest `one', by(highelecmd);
	};

* test down columns;
foreach one of varlist educ work {;
	ttest `one' if highelecmd==1, by(migrant);
	ttest `one' if highelecmd==0, by(migrant);
	ttest `one' , by(migrant);
};
clear;

************************************************************************;
************************************************************************;
******************** APPENDIX 4 ****************************************;
************************************************************************;
************************************************************************;
#delimit;

************************************************************************;
******************** APPENDIX 4 TABLE 1: OCCUPATIONS DISTRIBUTIONS***;
************************************************************************;
* Data: main analysis sample, community census data;
* pop totals, emp rates, occupation distribution;
* COMMUNITY DATA;
use "$data\matched_censusdata.dta", clear;
egen allwomen0=sum(adult_african_f0);
egen allmen0=sum(adult_african_m0);
egen allwomen1=sum(adult_african_f1);
egen allmen1=sum(adult_african_m1);

tab1 allmen* allwomen*;
tabstat prop_emp_m0, col(s) s(mean sd n);
tabstat prop_emp_m1, col(s) s(mean sd n);
tabstat prop_emp_f0, col(s) s(mean sd n);
tabstat prop_emp_f1, col(s) s(mean sd n);

* occupation distribution;
tabstat prop_occup2_*_m0, col(s) s(mean sd n);
tabstat prop_occup2_*_m1, col(s) s(mean sd n);
tabstat prop_occup2_*_f0, col(s) s(mean sd n);
tabstat prop_occup2_*_f1, col(s) s(mean sd n);
tabstat prop_miss_occup_m0, col(s) s(mean sd n);
tabstat prop_miss_occup_m1, col(s) s(mean sd n);
tabstat prop_miss_occup_f0, col(s) s(mean sd n);
tabstat prop_miss_occup_f1, col(s) s(mean sd n);
clear;

* INDIV DATA;
* Data: uses 10% census data from 1996 and 2001;
* Sample here consists of African adults living in rural KZN;
* Data contain notes to some variables;
#delimit;
use "$data\censusmicrodata.dta", clear;
tab occ, gen(occ);
local i = 1;
while `i'<=9 {;
	replace occ`i'=0 if occ`i'==.;
	local i = `i'+1;
};

keep if age >=15 & age<=59;
keep if urban==0;

gen men=pwt if sex==0;
gen fem=pwt if sex==1;
egen allmen0=sum(men) if year==0;
egen allfem0=sum(fem) if year==0;
egen allmen1=sum(men) if year==1;
egen allfem1=sum(fem) if year==1;

sum all*;

tab year if sex==1 [aw=pwt], sum(work);
tab year if sex==0 [aw=pwt], sum(work);

tabstat occ1-occ9 if year==0 & sex==0 [aw=pwt], c(s) s(mean sd n);
tabstat occ1-occ9 if year==1 & sex==0 [aw=pwt], c(s) s(mean sd n);
tabstat occ1-occ9 if year==0 & sex==1 [aw=pwt], c(s) s(mean sd n);
tabstat occ1-occ9 if year==1 & sex==1 [aw=pwt], c(s) s(mean sd n);

clear;






* OHS AND LFS DATA;
* Data here are from the supplementary anaysis dataset;
use "$data\hhsurveydata.dta", clear;

* population totals;
tabstat menpoptotal if sex==1 & year==1996, column(s) s(mean sd n);
tabstat fempoptotal if sex==0& year==1996, column(s) s(mean sd n);

tabstat menpoptotal if sex==1 & year==2001, column(s) s(mean sd n);
tabstat fempoptotal if sex==0& year==2001, column(s) s(mean sd n);

* employment rates;
tabstat work if sex==0 & year==1996 [aw=perswgt], column(s) s(mean sd n);
tabstat work if sex==1 & year==1996 [aw=perswgt], column(s) s(mean sd n);

tabstat work if sex==0 & year==2001 [aw=perswgt], column(s) s(mean sd n);
tabstat work if sex==1 & year==2001 [aw=perswgt], column(s) s(mean sd n);

* occupational distribution;
* for women;
local i = 1;
while `i'<=9 {;
	di "1996";
	tabstat occup2_grp`i' if sex==0 & year==1996 [aw=perswgt], column(s) s(mean sd n);
	di "2001";
	tabstat occup2_grp`i' if sex==0 & year==2001 [aw=perswgt], column(s) s(mean sd n);
	local i = `i'+1;
};


* for men;
local i = 1;
while `i'<=9 {;
	di "1996";
	tabstat occup2_grp`i' if sex==1 & year==1996 [aw=perswgt], column(s) s(mean sd n);
	di "2001";
	tabstat occup2_grp`i' if sex==1 & year==2001 [aw=perswgt], column(s) s(mean sd n);
	local i = `i'+1;
};
clear;
**************************************************************************;


********************************************************;
************ APPENDIX 4 Tables 2-3:*********;
********************************************************;
* checking for correlation between employment measurement error and gradient;
* Data are a combination of Census community and individual Census data;
* Sample for census community data is the main analysis sample, aggregated up to MD level;
* Sample for census micro data is ural kzn, african adults ages 15-59, aggregated up to MD level;
* Samples are merged on magisterial district identifiers;

#delimit cr

use "$data\census_comm_indiv.dta", clear

* Is there a correlation between the individual and community data,
* in levels? 
reg prop_emp_f1_indiv prop_emp_f1_comm, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) replace
reg prop_emp_f0_indiv prop_emp_f0_comm, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg prop_emp_m1_indiv prop_emp_m1_comm, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg prop_emp_m0_indiv prop_emp_m0_comm, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append


* Do the community data do a reasonable job of predicting the individual data? 
reg fempdif_indiv fempdif_comm, ro
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg mempdif_indiv mempdif_comm, ro
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append

* Is there a correlation between gradient and Demp at the 
* community or indiv level? 
reg fempdif_comm grad_mean_indiv,ro
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg fempdif_indiv grad_mean_indiv,ro
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg mempdif_comm grad_mean_indiv,ro
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg mempdif_indiv grad_mean_indiv,ro
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append

* Are the measurement error GAPS different by gradient?
* in levels: small but significant
reg empdif_fem1 grad_mean_indiv, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg empdif_fem0 grad_mean_indiv, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg empdif_men1 grad_mean_indiv, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg empdif_men0 grad_mean_indiv, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append

* Are the employment reporting gaps over time different by gradient? NO
reg empdiff_fem grad_mean_indiv, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append
reg empdiff_men grad_mean_indiv, robust
outreg2 using "$temp\censuscheck.out", nolabel se bdec(5) rdec(3) append

clear







