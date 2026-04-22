*RUNS PLACEBO TEST ON 03-04 AND 04-05 APPLYING 05-06 KATRINA COUNTS TO 04-05 DATA


clear
set mem 3g
set matsize 2000
set more off



*LOAD HISD DATA
use /work/i/imberman/imberman/katrina_data, clear

*KEEP ONLY THOSE WHO HAVE GRADES LISTED AND THUS WERE ENROLLED IN LATE OCTOBER OF THE YEAR
drop if grade == .

*KEEP 2005 ONLY
keep if year == 2005

collapse (mean) katrina_frac_grade, by(campus)
save /work/i/imberman/imberman/temp.dta, replace

# delimit ;

*REGRESSIONS;

local gradenum 0;

*LOOP OVER GRADE LEVEL;
foreach grade in "elem"  "midhigh"{;

  *INCREASE COUNTER FOR GRADELEVEL (1 = ELEM, 2 = MIDHIGH);
  local gradenum = `gradenum' + 1;

  *OPEN KATRINA DATA;
  use /work/i/imberman/imberman/katrina_data.dta, clear;
  xtset id year;

  # delimit cr
  *GENEARATE TEST SCORE LAGS FROM PRE-KATRINA YEARS
  foreach var of varlist taks_sd_min_math taks_sd_min_read perc_attn infractions {
  gen l`var' = .
  gen lagyears_`var' = .
  foreach lag of numlist 1/5 {
    replace lagyears_`var' = `lag' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2003
    replace l`var' = l`lag'.`var' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2003
  }
  tab lagyears_`var', gen(lagyears_`var'_)
  forvalues gap = 1/4 {
    gen l`var'_`gap' = lagyears_`var'_`gap'*l`var'
  }
  }


  *KEEP ONLY 2003-04 AND 2004-05
  keep if year >= 2003 & year <= 2004

 
  *MERGE IN KATRINA FRACTION DATA
  sort campus
  drop _merge
  drop katrina_frac_grade
  merge campus using /work/i/imberman/imberman/temp.dta, nokeep
  replace katrina_frac_grade = 0 if year == 2003

  
  *MERGE IN QUARTILE DATA
  capture drop katrina*median*
  sort id year
  merge id year using /work/i/imberman/imberman/pre_katrina_quartiles_placebo.dta, _merge(_mergequartile) nokeep
 
  
  *KEEP ONLY GRADE LEVEL BEING ANALYSED IN SAMPLE
  keep if `grade' == 1


  # delimit ;
  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES;
  xi i.grade*i.year;

  *DISPLAY GRADE LEVEL IN LOG FILE;
  di " ";
  di "`grade'";
  di " ";

  *COUNTER FOR DEPENDENT VARIABLE;
  local depvarid 0;



  *LOOP OVER DEPENDENT VARIABLES;
  foreach subject of varlist taks_sd_min_math taks_sd_min_read {;

	areg `subject' katrina_frac_grade l`subject'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `subject'_quartile != ., cluster(campus) absorb(campus);

  };
  foreach subject of varlist perc_attn infrac {;
    
	areg `subject' katrina_frac_grade l`subject'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*, cluster(campus) absorb(campus);

  };

 *LOOP OVER QUARTILES;
 foreach quartile of numlist 1/4 {;
 
  di "" ;
  di "QUARTILE `quartile'";
  di "";

	foreach var of varlist taks_sd_min_math taks_sd_min_read {;
		areg `var' katrina_frac_grade  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var'_quartile == `quartile', cluster(campus) absorb(campus);
	};

  *CLOSE QUARTILE LOOP;
  };


*CLOSE GRADELEVEL LOOP;
};
