**THIS ANALYSIS IS SIMILAR TO THAT DONE IN HOXBY AND WEINGARTH (2005) IN THAT IT INTERACTS THE FRACTION EVACUEE IN EACH QUARTILE BASED ON  2005 SCORE 
*WITH THE QUARTILE OF THE NATIVE STUDENT IN 2004 - THIS WILL ALLOW US TO TEST FOR THE EXISTENCE OF BOUTIQUE/BAD-APPLE/SHINING-LIGHT MODELS

*UNRESTRICTED VALUE-ADDED REGRESSIONS

*USE UNSTANDARDIZED SCALE SCORES

clear
set mem 3g
set matsize 2000
set more off

***OPTIONS****


*REGRESSIONS


  cd /work/i/imberman/imberman/
  capture rm outreg_quartile.txt
  capture rm outreg_quartile.xls
  capture rm outreg_quartile.xml


*LOOP OVER GRADE LEVEL
foreach grade in "elem" "midhigh"{

  *INCREASE COUNTER FOR GRADELEVEL (1 = ELEM, 2 = MIDHIGH)
  local gradenum = `gradenum' + 1

  *OPEN KATRINA DATA
  use /work/i/imberman/imberman/katrina_data.dta, clear
  xtset id year


  *GENEARATE TEST SCORE LAGS FROM PRE-KATRINA YEARS
  foreach var of varlist taks_scale_min_math taks_scale_min_read {
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

  *
 
  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES
  xi i.grade*i.year

  *DISPLAY GRADE LEVEL IN LOG FILE
  di " "
  di "`grade'"
  di " "

  *COUNTER FOR DEPENDENT VARIABLE
  local depvarid 0


capture rm katrina_by_quartiles_va.txt
capture rm katrina_by_quartiles_va.xml

*RUN LINEAR MODEL


  di ""
  di "POOLED LINEAR MODEL"
  di ""
  # delimit ;
  foreach var in "math" "read" {;
	areg taks_scale_min_`var'  katrina_frac_grade  ltaks_scale_min_`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if taks_sd_min_`var' != . & taks_sd_min_`var'_quartile !=., cluster(campus) absorb(campus);
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
    	
  foreach var in "math" "read" {;
	areg taks_scale_min_`var'  katrina_frac_grade  ltaks_scale_min_`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if taks_sd_min_`var' != . &  taks_sd_min_`var'_quartile == `quartile', cluster(campus) absorb(campus);

	};



  *CLOSE QUARTILE LOOP;
  };


*CLOSE GRADELEVEL LOOP;
};

