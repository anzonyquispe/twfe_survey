**THIS ANALYSIS IS SIMILAR TO THAT DONE IN HOXBY AND WEINGARTH (2005) IN THAT IT INTERACTS THE FRACTION EVACUEE IN EACH QUARTILE BASED ON  2005 SCORE 
*WITH THE QUARTILE OF THE NATIVE STUDENT IN 2004 - THIS WILL ALLOW US TO TEST FOR THE EXISTENCE OF BOUTIQUE/BAD-APPLE/SHINING-LIGHT MODELS

*UNRESTRICTED VALUE-ADDED REGRESSIONS

*ASSESSESS SWITCHING & LEAVING BEHAVIOR

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

  *IDENTIFY IF STUDENT SWITCHES SCHOOLS
  gen switch = f.campus != campus & f.campus != .

  *IDENTIFY IF STUDENT LEAVES DISTRICT
  gen leave = f.campus == .

  *IDENTIFY MAXIMUM GRADE FOR A CAMPUS
  drop maxgrade
  egen maxgrade = max(grade), by (campus year)

  *IDENTIFY SWITCHERS NOT IN MAXGRADE
  gen switch_nomaxgrade = switch if grade < maxgrade & maxgrade != .

  *IDENTIFY LEAVERS NOT IN MAXGRADE
  gen leave_nomaxgrade = leave if grade < maxgrade & maxgrade != .

  *DROP 12TH GRADE FROM THE SAMPLE
  drop if grade == 12

  *DROP 2006-07
  drop if year == 2006

  *KEEP ONLY GRADE LEVEL BEING ANALYSED IN SAMPLE
  keep if `grade' == 1
  
  
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


  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES
  xi i.grade*i.year

  *DISPLAY GRADE LEVEL IN LOG FILE
  di " "
  di "`grade'"
  di " "

  *COUNTER FOR DEPENDENT VARIABLE
  local depvarid 0



*RUN LINEAR MODEL
  di ""
  di "POOLED LINEAR MODEL"
  di ""

  # delimit ;
  foreach var of varlist switch switch_nomaxgrade leave leave_nomaxgrade {;
	sum `var' if year <= 2004;

	areg `var'  katrina_frac_grade female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*, cluster(campus) absorb(campus);
  };


*SPLIT BY PRE-KATRINA QUARTILES;
foreach test in "avg" {;
  forvalues quart = 1/4 {;
	foreach var of varlist switch switch_nomaxgrade leave leave_nomaxgrade {;
	  sum `var' if year <= 2004 & taks_sd_min_`test'_quartile == `quart';
	  areg `var'  katrina_frac_grade female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if taks_sd_min_`test'_quartile == `quart', cluster(campus) absorb(campus);
	};
  };
};



*CLOSE QUARTILE LOOP;
};


