*THIS FILE CONDUCTS BASELINE OLS REGRESSIONS OF TEST SCORE DIFFERENCES B/W KATRINA EVACUEES AND NON-EVACUEES IN THE SAME SCHOOL

 clear
 set mem 3g
 set matsize 2000
 set more off


*LOAD HISD DATA
use /work/i/imberman/imberman/katrina_data_with_evacs, clear
xtset id year

  *GENEARATE TEST SCORE LAGS FROM PRE-KATRINA YEARS
  foreach var of varlist taks_sd_min_math taks_sd_min_read perc_attn infractions {
  gen l`var' = .
  gen lagyears_`var' = .
  foreach lag of numlist 1/5 {
    replace lagyears_`var' = `lag' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2004
    replace l`var' = l`lag'.`var' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2004
  }
  tab lagyears_`var', gen(lagyears_`var'_)
  forvalues gap = 1/4 {
    gen l`var'_`gap' = lagyears_`var'_`gap'*l`var'
  }
  }

  
  *MERGE IN KATRINA MEDIAN DATA & QUARTILE DATA
  capture drop katrina*median*
  sort id year
  merge id year using /work/i/imberman/imberman/pre_katrina_quartiles.dta, _merge(_mergequartile) nokeep



*DROP STUDENTS WITH NO SCHOOL LISTED
drop if campus == .


# delimit ;

xi i.grade*i.year i.campus;
xtset id year;

***ALL STUDENTS***;
local type 1;
local gradelevel 0;

*CYCLE OVER GRADELEVELS;
foreach grade in "elem" "midhigh" {;
  local gradelevel = `gradelevel' + 1;
  local depvarid 0;


   *CYCLE OVER OUTCOMES;
   foreach depvar of varlist taks_sd_min_math taks_sd_min_read {;
     local depvarid = `depvarid' + 1;

      *2005 ONLY;

      di "grade `grade'";
      di "`depvar'";
      di "2005 only" ;
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2005
	& (katrina == 1 | (katrina == 0 & l`depvar' != . & `depvar'_quartile != .)) , cluster(campus) ;
      local regression 1;


      *2006 ONLY;
      di "grade `grade'";
      di "`depvar'";
      di "2006";
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2006
	& (katrina == 1 | (katrina == 0 & l`depvar' != . & `depvar'_quartile != .)) , cluster(campus) ;
      local regression 2;



      *CHANGE FROM 2005 TO 2006;
      di "grade `grade'";
      di "`depvar'";
      di "CHANGE";   
      reg d.`depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1
	& (katrina == 1 | (katrina == 0 & l`depvar' != . & `depvar'_quartile != .)) , cluster(campus) ;
      local regression 3;

   } ;




   *CYCLE OVER OUTCOMES;
   foreach depvar of varlist perc_attn infrac {;
     local depvarid = `depvarid' + 1;

      *2005 ONLY;

      di "grade `grade'";
      di "`depvar'";
      di "2005 only" ;
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2005 
	& (katrina == 1 | (katrina == 0 & l`depvar' != .)) , cluster(campus);
      local regression 1;


      *2006 ONLY;
      di "grade `grade'";
      di "`depvar'";
      di "2006";
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2006
	& (katrina == 1 | (katrina == 0 & l`depvar' != .)) , cluster(campus);
      local regression 2;



      *CHANGE FROM 2005 TO 2006;
      di "grade `grade'";
      di "`depvar'";
      di "CHANGE";   
      reg d.`depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1
	& (katrina == 1 | (katrina == 0 & l`depvar' != .)) , cluster(campus);
      local regression 3;

   } ;
};

/*
*** BY GENDER **
local gradelevel 0;

***BOYS***

*CYCLE OVER GRADELEVELS;
foreach grade in "elem" "midhigh" {;
  local gradelevel = `gradelevel' + 1;
  local depvarid 0;
  local type 2;

   *CYCLE OVER OUTCOMES;
   foreach depvar of varlist stanford_math_sd stanford_read_sd stanford_lang_sd taks_sd_min_math taks_sd_min_read perc_attn infrac substance crime fighting{;
     local depvarid = `depvarid' + 1;

      *2005 ONLY;

      di "grade `grade'";
      di "`depvar'";
      di "2005 only" ;
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2005 & female == 0, cluster(campus);
      local regression 1;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("boys") ("`grade'") ("2005") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("boys") ("`grade'") ("2005") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));


      *2006 ONLY;
      di "grade `grade'";
      di "`depvar'";
      di "2006";
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2006 & female == 0, cluster(campus);
      local regression 2;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("boys") ("`grade'") ("2006") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("boys") ("`grade'") ("2006") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));


      *CHANGE FROM 2005 TO 2006;
      di "grade `grade'";
      di "`depvar'";
      di "CHANGE";   
      reg d.`depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & female == 0, cluster(campus);
      local regression 3;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("boys") ("`grade'") ("change") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("boys") ("`grade'") ("change") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));

   } ;
};



***GIRLS***
local gradelevel 0;

*CYCLE OVER GRADELEVELS;
foreach grade in "elem" "midhigh" {;
  local gradelevel = `gradelevel' + 1;
  local depvarid 0;
  local type 3;

   *CYCLE OVER OUTCOMES;
   foreach depvar of varlist taks_sd_min_math taks_sd_min_read perc_attn infrac substance crime fighting{;
     local depvarid = `depvarid' + 1;

      *2005 ONLY;

      di "grade `grade'";
      di "`depvar'";
      di "2005 only" ;
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2005 & female == 1, cluster(campus);
      local regression 1;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("girls") ("`grade'") ("2005") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("girls") ("`grade'") ("2005") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));


      *2006 ONLY;
      di "grade `grade'";
      di "`depvar'";
      di "2006";
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2006 & female == 1, cluster(campus);
      local regression 2;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("girls") ("`grade'") ("2006") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("girls") ("`grade'") ("2006") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));


      *CHANGE FROM 2005 TO 2006;
      di "grade `grade'";
      di "`depvar'";
      di "CHANGE";   
      reg d.`depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & female == 1, cluster(campus);
      local regression 3;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("girls") ("`grade'") ("change") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("girls") ("`grade'") ("change") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));

   } ;
};


/*

***AA ONLY***;

keep if ethnicity == 3;
local type 2;
local gradelevel 0;
xi: i.grade*i.year i.campus;

*CYCLE OVER GRADELEVELS;
foreach grade in "elem" "midhigh" {;
local gradelevel = `gradelevel' + 1;
local depvarid 1;

   *CYCLE OVER OUTCOMES;
   foreach depvar of varlist stanford_math_sd stanford_read_sd stanford_lang_sd taks_sd_min_math taks_sd_min_read  perc_attn infrac substance crime fighting{;
     local depvarid = `depvarid' + 1;
     
      *2005 ONLY;

      di "grade `grade'";
      di "`depvar'";
      di "2005 only" ;
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2005, cluster(campus);
      local regression 1;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("aa only") ("`grade'") ("2005") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("aa only") ("`grade'") ("2005") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));


      *2006 ONLY;
      di "grade `grade'";
      di "`depvar'";
      di "2006";
      reg `depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1 & year == 2006, cluster(campus);
      local regression 2;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("aa only") ("`grade'") ("2006") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("aa only") ("`grade'") ("2006") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));


      *CHANGE FROM 2005 TO 2006;
      di "grade `grade'";
      di "`depvar'";
      di "CHANGE";   
      reg d.`depvar' katrina  female ethnicit_2-ethnicit_5 econdis_2-econdis_4 _I*  if `grade' == 1, cluster(campus);
      local regression 3;
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("aa only") ("`grade'") ("change") 
	("`depvar'") ("") ("coef") (_b[katrina]) (_b[katrina]/_se[katrina]) (e(N));
      post katrina_nonkatrina (`type') (`gradelevel') (`regression') (`depvarid') (1) ("aa only") ("`grade'") ("change") 
	("`depvar'") ("") ("se") (_se[katrina]) (_b[katrina]/_se[katrina]) (e(N));

   } ;
};
*/

postclose katrina_nonkatrina;
use /work/i/imberman/hisd/katrina/postfiles/katrina_nonkatrina.dta, clear;
sort type  depvarid gradelevel reg statname;
outsheet using /work/i/imberman/hisd/katrina/postfiles/katrina_nonkatrina.dat, replace;