/** table6.do

This do-file generates Table 6, IVing for the
dissimilarity index with the desegregation indicator.

**/


#delimit;
clear all;
set mem 500m;
set trace off;
set more off;
set linesize 255;
capture log close;
log using table6.log, replace;

* set the data to be used;
local data = "../data/dis70panx.dta";

*********************************;
* Census Data Based Regressions	*;
*********************************;

use `data', clear;

keep if major==1;
replace imp = imp + 1900;

*** Make Measures Consistent Over Time;
replace publicelemhsw = publicelemw + publichsw if year ~= 1990;
replace publicelemhsb = publicelemb + publichsb if year ~= 1990;
replace publicelemhst = publicelemt + publichst if year ~= 1990;
replace privatelemhsw = privatelemw + privatehsw if year ~= 1990;
replace privatelemhsb = privatelemb + privatehsb if year ~= 1990;
replace privatelemhst = privatelemt + privatehst if year ~= 1990;

*** Create Treatment Variables;
gen imp_post    = (year >= imp);
gen impost_4    = (year >=  imp + 4);
gen nonsouth = (south==0);
local varlist  = "nonsouth south west";
for var  `varlist' : gen imp_post_X = imp_post*X;
for var  `varlist' : gen impost_4_X = impost_4*X;

*** Prepare Dependent Variables;
gen lnwpu = ln(publicelemhsw);
gen lnbpu = ln(publicelemhsb);
gen lnwpr = ln(privatelemhsw);
gen lnbpr = ln(privatelemhsb);
gen lnwto = ln(white);
gen lnbto = ln(black);

* recode based on the data in Cascio et. al.;
replace disd = 1 if year == 1960 &  south == 1   & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40);
replace disdm4 = 1 if year == 1960 &  south == 1 & (state ~= 10 & state ~= 24 & state ~= 21 & state ~= 29 & state ~= 54 & state ~= 40);

gen disd_south = disd*south;
gen disd_nonsouth = disd*(1-south);
gen disdm4_south = disdm4*south;
gen disdm4_nonsouth = disdm4*(1-south);



 disp " "; disp "***************************************** TABLE 6: TEXT ONLY ***********************************************"; disp " ";
 ** diss and exp results for text;
 sum disd, det;
 sum disd if year == 1970, det;
 tabstat disd, by(year) stat(mean);
 xi: xtreg disd      imp_post i.year*i.south                     , fe i(leaid) cluster(leaid);

 *** First Stage for Whites (drop relevant collinear variables to help Stata);
 xi: xtreg disd imp_post imp_post_west i.year*i.south i.year*i.west                    , fe i(leaid) cluster(leaid);
 test imp_post imp_post_west;
 xi: xtreg disd_south    imp_post_south i.year if south==1, fe i(leaid) cluster(leaid);
 test imp_post_south;
 xi: xtreg disd_nonsouth imp_post_nonsouth imp_post_west i.year*i.west if south==0, fe i(leaid) cluster(leaid);
 test imp_post_nonsouth imp_post_west;

 *** First Stage for Blacks (drop relevant collinear variables to help Stata);
 xi: xtreg disdm4 impost_4 impost_4_west i.year*i.south i.year*i.west, fe i(leaid) cluster(leaid);
 test  impost_4 impost_4_west;
 xi: xtreg disdm4_south    impost_4_south i.year if south==1, fe i(leaid) cluster(leaid);
 test impost_4_south;
 xi: xtreg disdm4_nonsouth impost_4_nonsouth impost_4_west i.year*i.west if south==0, fe i(leaid) cluster(leaid);
 test impost_4_nonsouth impost_4_west;

foreach r in pu to pr {;

 **************************;
 * White Outcomes         *;
 **************************;
 disp " "; disp " "; disp "******************************* White Outcomes, Table 6 *******************************"; disp " "; disp " ";
 disp " "; disp " "; disp "******************************* OUTCOME: `r'            *******************************"; disp " "; disp " ";
 xi: ivregress 2sls lnw`r' (disd=imp_post imp_post_west ) i.year*i.south i.year*i.west  i.leaid, cluster(leaid);
 if "`r'"=="pu" {;
  outreg2 disd using table6w.out, bdec(2) se nor2 nocons replace;
 }; 
 else {;
  outreg2 disd using table6w.out, bdec(2) se nor2 nocons append;
 };
 
 xi: ivregress 2sls lnw`r' (disd_south disd_nonsouth=imp_post_south imp_post_nonsouth imp_post_west) i.year*i.south i.year*i.west  i.leaid, cluster(leaid);
 outreg2 disd_south disd_nonsouth using table6w.out, bdec(2) se nor2 nocons append;

};

foreach r in pu to pr {;

 **************************;
 * Black Outcomes         *;
 **************************;
 disp " "; disp " "; disp "******************************* Black Outcomes, Table 6 *******************************"; disp " "; disp " ";
 disp " "; disp " "; disp "******************************* OUTCOME: `r'            *******************************"; disp " "; disp " ";
 xi: ivregress 2sls lnb`r' (disdm4=impost_4 impost_4_west) i.year*i.south i.year*i.west  i.leaid, cluster(leaid);
 if "`r'"=="pu" {;
  outreg2 disdm4 using table6b.out, bdec(2) se nor2 nocons replace;
 }; 
 else {;
  outreg2 disdm4 using table6b.out, bdec(2) se nor2 nocons append;
 };

 xi: ivregress 2sls lnb`r' (disdm4_south disdm4_nonsouth=impost_4_south impost_4_nonsouth impost_4_west) i.year*i.south i.year*i.west  i.leaid, cluster(leaid);
 outreg2 disdm4_south disdm4_nonsouth using table6b.out, bdec(2) se nor2 nocons append;

};

log close;

