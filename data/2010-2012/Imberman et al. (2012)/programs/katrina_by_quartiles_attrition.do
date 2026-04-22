

*************** TESTS MODELS UNDER DIFFERENT ASSUMPTIONS OF STUDENTS WHO ARE ENROLLED BUT DO NOT TAKE AN EXAM****

clear
set mem 3g
set matsize 2000
set more off

***OPTIONS****


  cd /work/i/imberman/imberman/
  capture rm outreg_quartile_grade.txt
  capture rm outreg_quartile_grade.xls
  capture rm outreg_quartile_grade.xml


*LOOP OVER GRADE LEVEL
foreach grade in "elem" "midhigh"{

  *INCREASE COUNTER FOR GRADELEVEL (1 = ELEM, 2 = MIDHIGH)
  local gradenum = `gradenum' + 1

  *OPEN KATRINA DATA
  use /work/i/imberman/imberman/katrina_data.dta, clear
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
  gen lag`var' = l.`var'
  }


  *GENERATE MINIMUM SCORES
  egen min_math = min(taks_sd_min_math), by(grade year)
  egen min_read = min(taks_sd_min_read), by(grade year)
	

  
  *MERGE IN KATRINA MEDIAN DATA & QUARTILE DATA
  capture drop katrina*median*
  /*
  sort campus year
  merge campus year using /work/i/imberman/imberman/katrina_medians.dta, _merge(_mergekatmedian) nokeep
  foreach var of varlist katrina_frac_* katrina_count_* {
    replace `var' = 0 if `var' == .
  }
  */
  sort id year
  merge id year using /work/i/imberman/imberman/pre_katrina_quartiles.dta, _merge(_mergequartile) nokeep


  *GENERATE MEAN OF BOTTOM QUARTILE
  xtset id year
  egen mean_math_Q1a = mean(taks_sd_min_math) if taks_sd_min_math_quartile == 1, by(grade year)
  egen mean_math_Q1 = max(mean_math_Q1a), by(grade year)

  egen mean_read_Q1a = mean(taks_sd_min_math) if taks_sd_min_math_quartile == 1, by(grade year)
  egen mean_read_Q1 = max(mean_read_Q1a), by(grade year)

  *KEEP ONLY GRADE LEVEL BEING ANALYSED IN SAMPLE
  keep if `grade' == 1
  

  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES
  xi i.grade*i.year

  *DISPLAY GRADE LEVEL IN LOG FILE
  di " "
  di "`grade'"
  di " "

  *COUNTER FOR DEPENDENT VARIABLE
  local depvarid 0

keep if grade != .

*DROP GRADES THAT ARE NOT TESTED & YEARS NOT COVERED
drop if grade > 11 | grade < 4
drop if grade < 5 & year == 2006
drop if year < 2003


save temp, replace


***MODEL ONE - ANY ENROLLED STUDENT WHO IS MISSING A TEST SCORE GETS THE MINIMUM SCORE IN THAT GRADE/YEAR

*RUN LINEAR MODEL
	replace taks_sd_min_math = min_math if taks_sd_min_math == .
	replace taks_sd_min_read = min_read if taks_sd_min_read == .


  di ""
  di "POOLED LINEAR MODEL"
  di ""
  # delimit ;
  foreach var of varlist taks_sd_min_math taks_sd_min_read {;
	areg `var'  katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var'_quartile != ., cluster(campus) absorb(campus);
  };
  # delimit cr

 *LOOP OVER QUARTILES
 foreach quartile of numlist 1/4 {
 
  di "" 
  di "QUARTILE `quartile'"
  di ""

  # delimit ;
  *LOOP OVER DEPENDENT VARIABLES;

     ***ALL KATRINA****;
    	
	foreach var of varlist taks_sd_min_math taks_sd_min_read {;
		areg `var' katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var'_quartile == `quartile', cluster(campus) absorb(campus);

	};



*CLOSE QUARTILE LOOP;
};
# delimit cr





***MODEL TWO - ANY ENROLLED STUDENT WHO IS MISSING A TEST SCORE GETS THEIR PRIOR YEAR LAGGED SCORE
use temp, clear
xtset id year
replace taks_sd_min_math = lagtaks_sd_min_math if taks_sd_min_math == .
replace taks_sd_min_read = lagtaks_sd_min_read if taks_sd_min_read == .

*RUN LINEAR MODEL


  di ""
  di "POOLED LINEAR MODEL"
  di ""
  # delimit ;
  foreach var of varlist taks_sd_min_math taks_sd_min_read {;
	areg `var'  katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var'_quartile != ., cluster(campus) absorb(campus);
  };
  # delimit cr;

 *LOOP OVER QUARTILES
 foreach quartile of numlist 1/4 {
 
  di "" 
  di "QUARTILE `quartile'"
  di ""

  # delimit ;
  *LOOP OVER DEPENDENT VARIABLES;

     ***ALL KATRINA****;
    	
	foreach var of varlist taks_sd_min_math taks_sd_min_read {;
		areg `var' katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var'_quartile == `quartile', cluster(campus) absorb(campus);

	};



*CLOSE QUARTILE LOOP;
};
# delimit cr



***MODEL THREE - ANY ENROLLED STUDENT WHO IS MISSING A TEST SCORE GETS THE MEAN SCORE OF 1ST QUARTILE STUDENTS
use temp, clear

replace taks_sd_min_math = mean_math_Q1 if taks_sd_min_math == .
replace taks_sd_min_read = mean_read_Q1 if taks_sd_min_read == .

*RUN LINEAR MODEL


  di ""
  di "POOLED LINEAR MODEL"
  di ""
  # delimit ;
  foreach var of varlist taks_sd_min_math taks_sd_min_read {;
	areg `var'  katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var'_quartile != ., cluster(campus) absorb(campus);
  };

 # delimit cr
 *LOOP OVER QUARTILES
 foreach quartile of numlist 1/4 {
 
  di "" 
  di "QUARTILE `quartile'"
  di ""

  # delimit ;
  *LOOP OVER DEPENDENT VARIABLES;

     ***ALL KATRINA****;
    	
	foreach var of varlist taks_sd_min_math taks_sd_min_read {;
		areg `var' katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var'_quartile == `quartile', cluster(campus) absorb(campus);

	};



*CLOSE QUARTILE LOOP;
};



*CLOSE GRADELEVEL LOOP;
};
