***CREATES DATASET WITH NATIVE STUDENT QUARTILES***

clear
set mem 3g
set matsize 2000
set more off

  *OPEN TEMPORARY DATAFILE SAVED EARLIER IN PROGRAM
  use /work/i/imberman/imberman/hisd_data.dta, clear

  *LIMIT TO PRE-KATRINA YEARS
  keep if year <= 2005

  *GENERATE SCORES FOR EACH YEAR
  foreach depvar of varlist taks_sd_min_math taks_sd_min_read {
     forvalues year = 2002/2003 {
      gen temp = `depvar' if year == `year'
      egen `depvar'_`year' = max(temp), by(id)
      drop temp
     }
  }

  *IDENTIFY NATIVE STUDENTS' PRE-KATRINA QUARTILE
    foreach var of varlist taks_sd_min_math taks_sd_min_read {	
	gen `var'_split = `var'_2003
	replace `var'_split = `var'_2002 if `var'_split == .
	bysort grade year: quantiles `var'_split , gen(`var'_quartile) nq(4) stable
    }

  *SET TO MISSING FOR YEARS AND GRADES WITHOUT A CRITICAL MASS OF STUDENTS
  replace taks_sd_min_math_quartile = . if grade < 3
  replace taks_sd_min_math_quartile = . if grade == 3 & year == 2004
  replace taks_sd_min_math_quartile = . if grade == 3 & year == 2005
  replace taks_sd_min_math_quartile = . if grade == 4 & year == 2005

  replace taks_sd_min_read_quartile = . if grade < 3
  replace taks_sd_min_read_quartile = . if grade == 3 & year == 2004
  replace taks_sd_min_read_quartile = . if grade == 3 & year == 2005
  replace taks_sd_min_read_quartile = . if grade == 4 & year == 2005

 

  keep id grade year *quartile*
  sort id year
  save /work/i/imberman/imberman/pre_katrina_quartiles_placebo.dta, replace

