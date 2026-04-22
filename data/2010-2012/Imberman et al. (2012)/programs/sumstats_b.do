**SUMMARY STATISTICS FOR 2005-06***

clear
set mem 6g
set matsize 2000
set more off
cd /work/i/imberman/imberman/



*LOAD DATA
use katrina_data_with_evacs, clear
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

f

*DROP STUDENTS WITH NO SCHOOL LISTED
drop if campus == .


  *GENERATE RACE DUMMIES  (A VALUE OF 1 IS NATIVE AMERICAN BUT ONLY 1000 OBS OVER ALL YEARS)
  gen white = ethnicity_2 == 5 
  gen asian = ethnicity_2 == 2

gen free_redlunch = freelunch + redlunch

# delimit ;
  foreach var of varlist female white hisp black asian free_redlunch atrisk katrina_frac_campus katrina_frac_grade
	taks_sd_min_math
	taks_sd_min_read
	perc_attn
	infrac {;

        sum `var' if katrina == 0 & year == 2005;
	sum `var' if katrina == 1 & year == 2005;
  };


  **SCHOOL WEIGHTED ALL;
  egen enrollment = sum(unit), by(campus year katrina);
  egen anykatrina = max(katrina), by(campus year);

  gen school_weight = 1/enrollment;
  foreach var of varlist female white hisp black asian free_redlunch atrisk katrina_frac_campus katrina_frac_grade
	taks_sd_min_math
	taks_sd_min_read
	perc_attn
	infrac {;

        sum `var' [aw = school_weight] if katrina == 0 & year == 2005;
	sum `var' [aw = school_weight] if katrina == 1 & year == 2005;
  };
 

 **SCHOOL WEIGHTED ANY KATRINA;
  foreach var of varlist female white hisp black asian free_redlunch atrisk katrina_frac_campus katrina_frac_grade
	taks_sd_min_math
	taks_sd_min_read
	perc_attn
	infrac {;

        sum `var' [aw = school_weight] if katrina == 0 & year == 2005 & anykatrina == 1;
	sum `var' [aw = school_weight] if katrina == 1 & year == 2005 & anykatrina == 1;
  };
 


# delimit cr

**OBSERVATION COUNTS

*NATIVES

*ELEM
tab year if grade <= 5 & infractions != . & linfractions != . & katrina == 0
tab year if grade <= 5 & taks_sd_min_math != . & ltaks_sd_min_math != . & taks_sd_min_math_quartile != .  & katrina == 0
tab year if grade <= 5 & taks_sd_min_read != . & ltaks_sd_min_read != . & taks_sd_min_read_quartile != .  & katrina == 0


*MIDHIGH
tab year if grade > 5 & infractions != . & linfractions != .  & katrina == 0
tab year if grade > 5 & taks_sd_min_math != . & ltaks_sd_min_math != . & taks_sd_min_math_quartile != .  & katrina == 0
tab year if grade > 5 & taks_sd_min_read != . & ltaks_sd_min_read != . & taks_sd_min_read_quartile != .  & katrina == 0



*EVACS

*ELEM
tab year if grade <= 5 & infractions != . & katrina == 1
tab year if grade <= 5 & taks_sd_min_math != .  & katrina == 1
tab year if grade <= 5 & taks_sd_min_read != . & katrina == 1


*MIDHIGH
tab year if grade > 5 & infractions != .  & katrina == 1
tab year if grade > 5 & taks_sd_min_math != . & katrina == 1
tab year if grade > 5 & taks_sd_min_read != . & katrina == 1

**COUNT # OF SCHOOLS
unique campus if katrina == 0 & year == 2005
unique campus if katrina == 1 & year == 2005

*# OF SCHOOLS W/ POSITIVE EVAC SHARE
unique campus if katrina == 0 & year == 2005 & katrina_frac_campus > 0
unique campus if katrina == 1 & year == 2005 & katrina_frac_campus > 0

***COLLAPSE TO SCHOOL-GRADE LEVEL
keep if taks_sd_min_math_quartile != .
keep if katrina == 0

collapse (mean) katrina_frac*, by(campus grade year)

 foreach var of varlist katrina_frac_campus katrina_frac_grade {

        sum `var' if year == 2005 & grade <= 5, detail
        sum `var' if year == 2005 & grade > 5, detail
  }

