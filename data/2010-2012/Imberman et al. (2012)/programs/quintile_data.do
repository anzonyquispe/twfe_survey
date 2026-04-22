***CREATES DATASET WITH NATIVE STUDENT QUARTILES***

clear
set mem 3g
set matsize 2000
set more off

set seed 10563

  *OPEN TEMPORARY DATAFILE SAVED EARLIER IN PROGRAM
  use /work/i/imberman/imberman/hisd_data.dta, clear

  *GENERATE AVERAGE OF MATH & READING
  gen taks_sd_min_avg = (taks_sd_min_math + taks_sd_min_read)/2

  *GENERATE SCORES FOR EACH YEAR
  foreach depvar of varlist taks_sd_min_math taks_sd_min_read taks_sd_min_avg{
     forvalues year = 2003/2006 {
      gen temp = `depvar' if year == `year'
      egen `depvar'_`year' = max(temp), by(id)
      drop temp
     }
  }

  *IDENTIFY NATIVE STUDENTS' PRE-KATRINA QUINTILE
    foreach var of varlist taks_sd_min_math taks_sd_min_read taks_sd_min_avg{	
	gen `var'_split = `var'_2004
	replace `var'_split = `var'_2003 if `var'_split == .
	bysort grade year: quantiles `var'_split , gen(`var'_quintile) nq(5) stable
    }
  
  *SET TO MISSING FOR YEARS AND GRADES WITHOUT A CRITICAL MASS OF STUDENTS
  replace taks_sd_min_math_quintile = . if grade < 3
  replace taks_sd_min_math_quintile = . if grade == 3 & year == 2005
  replace taks_sd_min_math_quintile = . if grade == 3 & year == 2006
  replace taks_sd_min_math_quintile = . if grade == 4 & year == 2006

  replace taks_sd_min_read_quintile = . if grade < 3
  replace taks_sd_min_read_quintile = . if grade == 3 & year == 2005
  replace taks_sd_min_read_quintile = . if grade == 3 & year == 2006
  replace taks_sd_min_read_quintile = . if grade == 4 & year == 2006


  replace taks_sd_min_avg_quintile = . if grade < 3
  replace taks_sd_min_avg_quintile = . if grade == 3 & year == 2005
  replace taks_sd_min_avg_quintile = . if grade == 3 & year == 2006
  replace taks_sd_min_avg_quintile = . if grade == 4 & year == 2006

 

  keep id grade year *quintile*
  sort id year
  save /work/i/imberman/imberman/pre_katrina_quintiles.dta, replace

