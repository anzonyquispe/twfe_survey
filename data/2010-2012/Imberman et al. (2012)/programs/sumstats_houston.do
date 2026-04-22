*THIS FILE CONDUCTS REDUCED FORM REGRESSIONS OF TEST SCORES OF NON-EVACUEES ON FRACTION OF GRADE WHO ARE EVACUEES

clear
set mem 6g
set matsize 2000
set more off
cd /work/i/imberman/hisd/katrina/


  # delimit ;
  postfile sumstats int(regtype gradelevel groupid varid) str30 (group variable statname) float (stat obs) using /work/i/imberman/hisd/katrina/postfiles/sumstats.dta, replace;
  # delimit cr



*LOAD HISD DATA
use hisd_data, clear


*KEEP ONLY THOSE WHO HAVE GRADES LISTED AND THUS WERE ENROLLED IN LATE OCTOBER OF THE YEAR
drop if grade == .

*DROP EARLY ED, PRE-K
drop if grade == -2 | grade == -1


*INITIALLY LIMIT ONLY TO 2004, 2005, 2006 UNTIL LAGGED, LEAD TEST SCORES INCORPORATED... THEN LIMIT TO 2005, 2006
keep if year >= 2004

  *LIMIT TEST SCORE DATA TO GRADES 1 - 11 SINCE 12TH GRADE IS FOR RE-TAKERS WHO PREVIOUSLY FAILED
  foreach var of varlist stanford_math_sd stanford_read_sd stanford_lang_sd {
    replace `var' = . if grade > 12 | grade < 1
  }

  *GENERATE LAGGED OUTCOMES TO LOOK AT 2004 TEST SCORE OF STUDENTS WITH MANY EVACUEES IN 2005 - CONDITIONAL ON HAVING TEST IN 2005
  tsset (id) year
  gen stanford_math_sd_lag = l.stanford_math_sd
  gen stanford_read_sd_lag = l.stanford_read_sd
  gen stanford_lang_sd_lag = l.stanford_lang_sd
  gen perc_attn_lag = l.perc_attn


  *GENERATE LEAD OUTCOMES TO LOOK AT 2006 TEST SCORE OF STUDENTS WHO HAVE 2005 TEST SCORES
  gen stanford_math_sd_lead = f.stanford_math_sd if stanford_math_sd != .
  gen stanford_read_sd_lead = f.stanford_read_sd if stanford_read_sd != .
  gen stanford_lang_sd_lead = f.stanford_lang_sd if stanford_lang_sd != .
  gen perc_attn_lead = f.perc_attn if perc_attn != .


*LIMIT TO 2005 DATA
keep if year == 2005
 
*MERGE IN SCHOOL-LEVEL KATRINA ENROLLMENT DATA
sort campus
merge campus using /work/i/imberman/hisd/katrina/katrina_enroll.dta, nokeep keep(katrina_enroll* enroll_campus_05)
tab _merge
foreach var of varlist katrina_enroll* enroll_campus_05 {
  replace `var' = . if year < 2005
}

***NOTE THAT ANY SCHOOL NOT LISTED IN THE KATRINA COUNTS SENT BY HISD IS ASSUMED TO HAVE HAD NO KATRINA STUDENTS***

  *GENERATE FRACTION OF SCHOOL KATRINA IN 2005
  *UNFORTUNATELY WE DO NOT HAVE TOTAL ENROLLMENT FOR 9/13/05 SO MUST USE ENROLLMENT AS OF LATE OCTOBER
  *SINCE SOME KATRINA STUDENTS LEAVE BEFORE THEN, GENERATE NON-KATRINA ENROLLMENT AND THEN ADD TO KATRINA_9_13 TO GET ESTIMATED ENROLLMENT FOR 9_13
  
  gen enroll_9_13_05 = enroll_campus_05 - katrina_enroll_10_31_05 + katrina_enroll_9_13_05
  gen katrina_frac_9_13_05 = katrina_enroll_9_13_05/enroll_9_13_05
  gen katrina_frac_10_31_05 = katrina_enroll_10_31_05/enroll_campus_05

  *USE INDIVIDUAL DATA TO GENERATE KATRINA COUNTS AS IN REGRESSIONS
  drop unit
  gen unit = 1
  egen katrina_count_campus = sum(katrina), by(campus year)
  egen enroll_campus = sum(unit), by(campus year)
  gen katrina_frac_campus = katrina_count_campus/enroll_campus



*MAKE KATRINA INDICATOR 0 FOR PRIOR TO 2005
replace katrina = 0 if year < 2005


  *GENERATE RACE DUMMIES  (A VALUE OF 1 IS NATIVE AMERICAN BUT ONLY 1000 OBS OVER ALL YEARS)
  gen white = ethnicity_2 == 5
  gen hisp = ethnicity_2 == 4
  gen black = ethnicity_2 == 3
  gen asian = ethnicity_2 == 2
  
  *GENERATE GRADE LEVELS 1-5, 6-8, 9-12
  gen gradelevel = .
  replace gradelevel = 1 if grade >=1 & grade <= 5
  replace gradelevel = 2 if grade >=6 & grade <= 8
  replace gradelevel = 3 if grade >=9 & grade <= 12
  replace gradelevel = 4 if grade >= 6 & grade <= 12

gen absence = 100 - perc_attn



*COLLECT SUMMARY STATISTICS
# delimit ;


*PART I - EVACUEES VS. NATIVE STUDENTS IN 2005;

  local indepvarid 1;
  foreach var of varlist female white hisp black asian grade freelunch redlunch lep gifted atrisk speced 
	taks_sd_min_math
	taks_sd_min_read
	absence
	infrac {;
     local varid = `varid' + 1;
     local groupid 1;

     *RUN UNIVARIATE REGRESSIONS OF CHARACTERISTICS ON EVACUEES CLUSTERED BY SCHOOL TO TEST FOR DIFFERENCES;
     sum `var' if year == 2005 & katrina == 0;
     sum `var' if year == 2005 & katrina == 1;
     
  };

f

*PART II - NATIVES ONLY BY LEVELS OF FRACTION KATRINA;

  *DROP KATRINA EVACUEES;
  drop if katrina == 1;

  *SEPARATE BY 0 - 3%, > 3%;
  gen katrina_category = .;
  replace katrina_category = 0 if katrina_frac_9_13_05 >= 0 & katrina_frac_9_13_05 < .03 & year == 2005;
  replace katrina_category = 1 if katrina_frac_9_13_05 >.03 & year == 2005;

local indeparid 1;
foreach gradelevel of numlist 1 4 {;
  local indepvarid 1;
    foreach var of varlist female white hisp black asian grade freelunch redlunch lep gifted atrisk speced 
	taks_sd_min_math
	taks_sd_min_read
	absence  
	infractions
	{;
     
     local varid = `varid' + 1;

     *RUN UNIVARIATE REGRESSIONS OF CHARACTERISTICS ON EVACUEES CLUSTERED BY SCHOOL TO TEST FOR DIFFERENCES;
      reg `var' katrina_category if year == 2005 & gradelevel == `gradelevel', cluster(campus);
     
     *COLLECT MEANS, STANDARD DEVIATIONS, AND T-STAT OF DIFFERENCE IN MEANS;
       local groupid 0;
       sum `var' if  year == 2005 & gradelevel == `gradelevel' & katrina_category == 0;
       post sumstats (2) (`gradelevel') (`groupid') (`varid') ("0 - 0.03") ("`var'") ("mean") (r(mean)) (r(N));
       post sumstats (2) (`gradelevel') (`groupid') (`varid') ("0 - 0.03") ("`var'") ("sd") (r(sd)) (r(N));
       post sumstats (2) (`gradelevel') (`groupid') (`varid') ("0 - 0.03") ("`var'") ("tstat") (.) (r(N));

       local groupid 1;
       sum `var' if  year == 2005 & gradelevel == `gradelevel' & katrina_category == 1;
       post sumstats (2) (`gradelevel') (`groupid') (`varid') ("> 0.03") ("`var'") ("mean") (r(mean)) (r(N));
       post sumstats (2) (`gradelevel') (`groupid') (`varid') ("> 0.03") ("`var'") ("sd") (r(sd)) (r(N));
       post sumstats (2) (`gradelevel') (`groupid') (`varid') ("> 0.03") ("`var'") ("tstat") (_b[katrina_category]/_se[katrina_category]) (r(N));

    };
};

*COUNT NUMBER OF SCHOOLS IN EACH CATEGORY;
drop unit;
gen unit = 1;
collapse (mean) unit, by(gradelevel campus katrina_category);
local varid = `varid' + 1;
foreach gradelevel of numlist 1 4 {;
  foreach group of numlist 0/1 {;
    count if gradelevel == `gradelevel' & katrina_category == `group';
    post sumstats (2) (`gradelevel') (`group') (`varid') ("") ("`var'") ("count") (r(N)) (.);
  };
};


postclose sumstats;
use /work/i/imberman/hisd/katrina/postfiles/sumstats.dta, clear;
sort regtype  groupid gradelevel varid statname;
outsheet using /work/i/imberman/hisd/katrina/postfiles/sumstats.dat, replace;
