/** tablesA2andA3.do

This do-file runs regressions at the central district/year
level (A2) and MSA level (A3) producing results for Tables 2-5.

**/


#delimit;
clear all;
set mem 500m;
set trace off;
set more off;
set linesize 255;
capture log close;
log using tablesA2andA3.log, replace;

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
replace mpublicelemhsw = mpublicelemw + mpublichsw if year ~= 1990;
replace mpublicelemhsb = mpublicelemb + mpublichsb if year ~= 1990;
replace mpublicelemhst = mpublicelemt + mpublichst if year ~= 1990;
replace mprivatelemhsw = mprivatelemw + mprivatehsw if year ~= 1990;
replace mprivatelemhsb = mprivatelemb + mprivatehsb if year ~= 1990;
replace mprivatelemhst = mprivatelemt + mprivatehst if year ~= 1990;

*** Create Treatment Variables;
gen imp_post    = (year >= imp);
gen impost_0_3  = (year >=  imp) & (year <= imp + 3);
gen impost_4    = (year >=  imp + 4);
gen imp_pre23   = (year < imp & year>=imp-2);
gen nonsouth = (south==0);
local varlist  = "nonsouth south";
for var  `varlist' : gen imp_post_X = imp_post*X;
for var  `varlist' : gen impost_0_3_X = impost_0_3*X;
for var  `varlist' : gen impost_4_X = impost_4*X;
for var  `varlist' : gen imp_pre23_X = imp_pre23*X;

*** Create Control Variables;
gen p_black = publicelemhsb / publicelemhst;
gen p_man = mempman/memp;
for var area marea inct incb incw p_man: gen lnX = ln(X);
for var p_black lnarea lnmarea lninct lnincb lnincw numdis
    : bysort leaid : egen X_b = sum(X * (year == 1970));
replace numdis_b = numdis_b / 1000;
for var p_black lnincb lnincw p_man
    : bysort leaid : egen X_6b = sum(X * (year == 1960));
local base60 = "i.year|p_black_6b i.year|lnarea_b i.year|lnmarea_b i.year|numdis_b i.year|lnincw_6b i.year|lnincb_6b i.year|p_man_6b";

*** Prepare Dependent Variables;
gen lnwpu = ln(publicelemhsw);
gen lnbpu = ln(publicelemhsb);
gen lnwpr = ln(privatelemhsw);
gen lnbpr = ln(privatelemhsb);
gen lnwto = ln(white);
gen lnbto = ln(black);
gen lnwte = ln(publicelemhsw + privatelemhsw);
gen lnbte = ln(publicelemhsb + privatelemhsb);

gen lnmwpu = ln(mpublicelemhsw);
gen lnmbpu = ln(mpublicelemhsb);
gen lnmwpr = ln(mprivatelemhsw);
gen lnmbpr = ln(mprivatelemhsb);
gen lnmwto = ln(mwhite);
gen lnmbto = ln(mblack);

***************************************************;
********* Generate Regression Results *************;
***************************************************;

 **************************************************************;
 * Total enrollment (public plus private)  Outcomes, Table A2 *;
 **************************************************************;
 foreach r in te {;
  xi: xtreg lnw`r' imp_post                         i.year*i.south		, fe i(leaid) cluster(leaid);
  outreg2 imp_post using tableA2.out, bdec(2) se nor2 nocons replace;
  xi: xtreg lnw`r' imp_post_south imp_post_nonsouth i.year*i.south		, fe i(leaid) cluster(leaid);
  outreg2 imp_post_south imp_post_nonsouth using tableA2.out, bdec(2) se nor2 nocons append;
  test imp_post_south = imp_post_nonsouth;

  xi: xtreg lnb`r' impost_4                         i.year*i.south              , fe i(leaid) cluster(leaid);
  outreg2 impost_4  using tableA2.out, bdec(2) se nor2 nocons append;
  xi: xtreg lnb`r' impost_4_south impost_4_nonsouth i.year*i.south              , fe i(leaid) cluster(leaid);
  outreg2 impost_4_south impost_4_nonsouth using tableA2.out, bdec(2) se nor2 nocons append;
  test impost_4_south = impost_4_nonsouth;
 };

************************;
 * Metro, Table A3	*;
 ************************;

 foreach r in pu pr to {;

 ***************************;
 * White Outcomes, Table A3*;
 ***************************;
 disp " "; disp " "; disp "******************************* White Outcomes, Table A3 *******************************"; disp " "; disp " ";
 disp " "; disp " "; disp "******************************* OUTCOME: `r'             *******************************"; disp " "; disp " ";

 xi: xtreg lnmw`r' imp_post_south imp_post_nonsouth i.year*i.south		, fe i(leaid) cluster(leaid);
 if "`r'"=="pu" {;
   outreg2 imp_post_south imp_post_nonsouth using tableA3.out, bdec(2) se nor2 nocons replace;
 };
 else {;
   outreg2 imp_post_south imp_post_nonsouth using tableA3.out, bdec(2) se nor2 nocons append;
 };


 };

 foreach r in pu pr to {;

 ***************************;
 * Black Outcomes, Table A3*;
 ***************************;
 disp " "; disp " "; disp "******************************* Black Outcomes, Table A3 *******************************"; disp " "; disp " ";
 disp " "; disp " "; disp "******************************* OUTCOME: `r'             *******************************"; disp " "; disp " ";

 xi: xtreg lnmb`r' imp_post_south imp_post_nonsouth impost_4_south impost_4_nonsouth i.year*i.south, fe i(leaid) cluster(leaid);
 outreg2 imp_post_south imp_post_nonsouth impost_4_south impost_4_nonsouth using tableA3.out, bdec(2) se nor2 nocons append;

 };

log close;

