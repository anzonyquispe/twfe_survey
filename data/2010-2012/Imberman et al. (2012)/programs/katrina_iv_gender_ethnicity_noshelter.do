*RUNS FIRST-STAGE & REDUCED FORM REGRESSIONS USING VARIOUS INSTRUMENT CANDIDATES


clear
set mem 3g
set matsize 2000
set more off

*REGRESSIONS

*USE DELIMITER TO ALLOW COMMANDS TO SPREAD LINES
# delimit ;


*COUNTERS ALLOW ME TO GENERATE UNIQUE IDENTIFIERS FOR EACH REGRESSION THAT CAN LATER BE SORTED IN A WAY THAT IS EASILY TRANSFERABLE TO EXCEL DATA TABLES;
*COUNTER FOR GRADE LEVEL;
local gradenum 0;
 
cd /work/i/imberman/imberman;
capture rm outreg_gender_ethnicity.txt;
capture rm outreg_gender_ethnicity.xml;
capture rm outreg_gender_ethnicity.xls;


*LOOP OVER GRADE LEVEL;
foreach grade in "elem" "midhigh"{;

  *INCREASE COUNTER FOR GRADELEVEL (1 = ELEM, 2 = MIDHIGH);
  local gradenum = `gradenum' + 1;

  *OPEN TEMPORARY DATAFILE SAVED EARLIER IN PROGRAM;
  use /work/i/imberman/imberman/katrina_data.dta, clear;
  xtset id year;

  *GENEARATE TEST SCORE LAGS FROM PRE-KATRINA YEARS;
  foreach var of varlist taks_sd_min_math taks_sd_min_read perc_attn infractions {;
  gen l`var' = .;
  gen lagyears_`var' = .;
  foreach lag of numlist 1/5 {;
    replace lagyears_`var' = `lag' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2004;
    replace l`var' = l`lag'.`var' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2004;
  };
  tab lagyears_`var', gen(lagyears_`var'_);
  forvalues gap = 1/4 {;
    gen l`var'_`gap' = lagyears_`var'_`gap'*l`var';
  };
  };

  *OPTION TO TAKE RANDOM SAMPLE FOR PROGRAM TESTING;
  *set seed 300083;
  *gsample 5, percent wor cluster(id);

  *KEEP ONLY GRADE LEVEL BEING ANALYSED IN SAMPLE;
  keep if `grade' == 1;

  *MERGE IN KATRINA MEDIAN DATA & QUARTILE DATA;
  capture drop katrina*median*;
  sort id year;
  merge id year using /work/i/imberman/imberman/pre_katrina_quartiles.dta, _merge(_mergequartile) nokeep;

  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES;
  xi i.grade*i.year;

  *DISPLAY GRADE LEVEL IN LOG FILE;
  di " ";
  di "`grade'";
  di " ";

  *COUNTER FOR DEPENDENT VARIABLE;
  local depvarid 0;

*LOOP OVER GENDER {;
forvalues gender = 0/1 {;

  *LOOP OVER DEPENDENT VARIABLES;
  foreach subject of varlist taks_sd_min_math taks_sd_min_read {;
    
	*INCREASE COUNTER FOR DEPENDENT VARIABLE;
	local depvarid = `depvarid' + 1;


	*OLS - LIMIT TO ZONED SCHOOLS B/C LEASEABLE SPACE ONLY APPLY TO ZONED SCHOOLS;
	*ALSO WHILE SOME SHELTER STUDENTS ENROLL IN NON-ZONED SCHOOOLS, THIS WOULD NOT BE AN INVOLUNTARY ASSIGNMENT;

		*DISPLAY REGRESSION TYPE IN LOG FILE;
    		di " " ;
    		di "OLS ";
    		di " ";

		*CONDUCT REGRESSION;
		areg `subject' katrina_frac_campus l`subject'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if female == `gender' & `subject'_quartile != ., cluster(campus) absorb(campus);
		outreg2 katrina_frac_campus using outreg_gender_ethnicity, excel nocons bdec(2);


  *CLOSE DEPVAR LOOP;
  };

  *LOOP OVER DEPENDENT VARIABLES;
  foreach subject of varlist perc_attn infrac {;
    
	*INCREASE COUNTER FOR DEPENDENT VARIABLE;
	local depvarid = `depvarid' + 1;


	*OLS - LIMIT TO ZONED SCHOOLS B/C LEASEABLE SPACE ONLY APPLY TO ZONED SCHOOLS;
	*ALSO WHILE SOME SHELTER STUDENTS ENROLL IN NON-ZONED SCHOOOLS, THIS WOULD NOT BE AN INVOLUNTARY ASSIGNMENT;

		*DISPLAY REGRESSION TYPE IN LOG FILE;
    		di " " ;
    		di "OLS ";
    		di " ";

		*CONDUCT REGRESSION;
		areg `subject' katrina_frac_campus l`subject'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if female == `gender', cluster(campus) absorb(campus);
		outreg2 katrina_frac_campus using outreg_gender_ethnicity, excel nocons bdec(2);


  *CLOSE DEPVAR LOOP;
  };

*CLOSE GENDER LOOP;
};





*LOOP OVER ETHNICITY/RACE;
*3 - BLACK, 4 - HISP, 5 - WHITE;
forvalues race = 3/5 {;

  *LOOP OVER DEPENDENT VARIABLES;
  foreach subject of varlist taks_sd_min_math taks_sd_min_read {;
    
	*INCREASE COUNTER FOR DEPENDENT VARIABLE;
	local depvarid = `depvarid' + 1;


	*OLS - LIMIT TO ZONED SCHOOLS B/C LEASEABLE SPACE ONLY APPLY TO ZONED SCHOOLS;
	*ALSO WHILE SOME SHELTER STUDENTS ENROLL IN NON-ZONED SCHOOOLS, THIS WOULD NOT BE AN INVOLUNTARY ASSIGNMENT;

		*DISPLAY REGRESSION TYPE IN LOG FILE;
    		di " " ;
    		di "OLS ";
    		di " ";

		*CONDUCT REGRESSION;
		areg `subject' katrina_frac_campus l`subject'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if ethnicity == `race' & `subject'_quartile != ., cluster(campus) absorb(campus);
		outreg2 katrina_frac_campus using outreg_gender_ethnicity, excel nocons bdec(2);

  *CLOSE DEPVAR LOOP;
  };

  *LOOP OVER DEPENDENT VARIABLES;
  foreach subject of varlist perc_attn infrac {;
    
	*INCREASE COUNTER FOR DEPENDENT VARIABLE;
	local depvarid = `depvarid' + 1;


	*OLS - LIMIT TO ZONED SCHOOLS B/C LEASEABLE SPACE ONLY APPLY TO ZONED SCHOOLS;
	*ALSO WHILE SOME SHELTER STUDENTS ENROLL IN NON-ZONED SCHOOOLS, THIS WOULD NOT BE AN INVOLUNTARY ASSIGNMENT;

		*DISPLAY REGRESSION TYPE IN LOG FILE;
    		di " " ;
    		di "OLS ";
    		di " ";

		*CONDUCT REGRESSION;
		areg `subject' katrina_frac_campus l`subject'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if ethnicity == `race', cluster(campus) absorb(campus);
		outreg2 katrina_frac_campus using outreg_gender_ethnicity, excel nocons bdec(2);

  *CLOSE DEPVAR LOOP;
  };

*CLOSE RACE LOOP;
};

*CLOSE GRADELEVEL LOOP;
};