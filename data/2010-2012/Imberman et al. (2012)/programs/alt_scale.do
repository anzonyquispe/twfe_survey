****ALTERNATIVE STANDARDIZATION***
***USE ONLY NEVER KATRINA STUDENTS IN NON-KATRINA DISTRICTS & SCHOOLS***

clear
set mem 1900m
capture log close

set seed 10563

*COLLAPSE SCALE SCORES
use LA_leap00_09.dta
replace grade = "10" if grade == "HS"
gen grade_num = real(grade)
replace math_scaled = math_scale if math_scaled == .
replace ela_scaled = ela_scale if ela_scaled == .
replace math_scaled = . if math_scaled == 0
replace ela_scaled = . if ela_scaled == 0
collapse (min) math_scaled ela_scaled grade_num, by(id year)
drop if math_scaled == . & ela_scaled == .
sort id year
save leap_scale.dta, replace


use la_prepped_revisionFULL_SAMPLE.dta

*MERGE IN ALTERNATIVELY STANDARDIZED ACHIEVEMENT DATA
drop *STD *_lag *_lagyear *0005 math200* ela200*
sort id year
merge id year using alternative_standardization.dta
drop _merge


drop *scale*
sort id year
merge id year using leap_scale.dta


*MAKE ORIGINAL AND NEW SAMPLES CONSISTENT
replace math_scaled = . if mathSTD == .
replace ela_scaled = . if elaSTD == .


*GENERATE LAGS
drop math2*  ela2*
forvalues year = 2000/2007 {
  gen math`year'a = math_scaled if year == `year'
  egen math`year' = max(math`year'a), by(id)
  drop math`year'a

  gen ela`year'a = ela_scaled if year == `year'
  egen ela`year' = max(ela`year'a), by(id)
  drop ela`year'a
}

drop math_lag* ela_lag*
sort id year
capture drop check1
gen check1=1 if id==id[_n-1]
gen math_lag=math_scaled[_n-1] if check1==1 & math_scaled!=. & math_scaled[_n-1]!=.
gen math_lagyear=year[_n-1] if check1==1 & math_scaled!=. & math_scaled[_n-1]!=.
gen math_laggrade=grade[_n-1] if check1==1 & math_scaled!=. & math_scaled[_n-1]!=.


sort id year ela_raw
gen ela_lag= ela_scaled[_n-1] if check1==1 & ela_scaled!=. & ela_scaled[_n-1]!=.
gen ela_lagyear=year[_n-1] if check1==1 & ela_scaled!=. & ela_scaled[_n-1]!=.
gen ela_laggrade= grade[_n-1] if check1==1 & ela_scaled!=. & ela_scaled[_n-1]!=.


drop math0005 ela0005
gen math0005 = .
gen ela0005 = .
forvalues year = 2005(-1)2000 {
  replace math0005 = math`year' if math0005 == .
  replace ela0005 = ela`year' if ela0005 == .
}

sort id year
save alternative_scaled.dta, replace

