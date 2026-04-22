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



*STANDARDIZE
use la_prepped_revisionFULL_SAMPLE.dta
drop *scale*
sort id year
merge id year using leap_scale.dta

/*
*MAKE ORIGINAL AND NEW SAMPLES CONSISTENT
replace math_scaled = . if mathSTD == .
replace ela_scaled = . if elaSTD == .
*/

keep id year katrina_sum rita katrina_district2 district_code percent_katrina grade_num math_scale ela_scale


gen cameron_calcasieu=0
replace cameron_calcasieu=1 if district_code==10 | district_code==12


* redefine katrina_district2 so that cameron and calcasieu districts are also excluded in the peer effects regressions

replace katrina_district2=1 if cameron_calcasieu==1



***********************************************
***********************************************

***************************
* redefine percent katrina
****************************
***********************************************
***********************************************
***********************************************

* create katrina_district3 which is a variable for EVER being in a katrina district

egen katrina_district3=max(katrina_district2), by(id)

replace katrina_district3=0 if katrina_district3==.

** do it within school and grade and class 
** include the Rita kids as katrina kids

capture drop percent_katrinaTIMESERIES2

**
replace katrina_sum=1 if rita==1

* make kids with missing katrina_sum 0 if katrina_district3 is 0

replace katrina_sum=0 if katrina_sum==. & katrina_district3==0



*RESTRICT TO STANDARDIZING SAMPLE TO GET MEAN & SD BY GRADE AND YEAR
egen everkatrina = max(katrina_sum), by(id)
keep if everkatrina == 0 & katrina_district2 == 0 & percent_katrina < .7

collapse (mean) math_mean= math_scale ela_mean= ela_scale (sd) math_sd=math_scale ela_sd=ela_scale, by(grade year) 
sort grade year
save la_means.dta, replace


*LOAD DATA AGAIN
use la_prepped_revisionFULL_SAMPLE.dta, clear
sort id year
merge id year using leap_scale.dta

tab _merge
drop _merge

sort grade_num year
merge grade_num year using la_means.dta
tab _merge
drop _merge


/*
*MAKE ORIGINAL AND NEW SAMPLES CONSISTENT
replace math_scaled = . if mathSTD == .
replace ela_scaled = . if elaSTD == .
*/

drop mathSTD elaSTD

*STANDARDIZE
gen mathSTD = (math_scaled - math_mean)/math_sd
gen elaSTD = (ela_scaled - ela_mean)/ela_sd

*GENERATE LAGS
drop math2*  ela2*
forvalues year = 2000/2007 {
  gen math`year'a = mathSTD if year == `year'
  egen math`year' = max(math`year'a), by(id)
  drop math`year'a

  gen ela`year'a = elaSTD if year == `year'
  egen ela`year' = max(ela`year'a), by(id)
  drop ela`year'a
}

drop math_lag* ela_lag*
sort id year
capture drop check1
gen check1=1 if id==id[_n-1]
gen math_lag=mathSTD[_n-1] if check1==1 & mathSTD!=. & mathSTD[_n-1]!=.
gen math_lagyear=year[_n-1] if check1==1 & mathSTD!=. & mathSTD[_n-1]!=.
gen math_laggrade=grade[_n-1] if check1==1 & mathSTD!=. & mathSTD[_n-1]!=.


sort id year ela_raw
gen ela_lag= elaSTD[_n-1] if check1==1 & elaSTD!=. & elaSTD[_n-1]!=.
gen ela_lagyear=year[_n-1] if check1==1 & elaSTD!=. & elaSTD[_n-1]!=.
gen ela_laggrade= grade[_n-1] if check1==1 & elaSTD!=. & elaSTD[_n-1]!=.


drop math0005 ela0005
gen math0005 = .
gen ela0005 = .
forvalues year = 2005(-1)2000 {
  replace math0005 = math`year' if math0005 == .
  replace ela0005 = ela`year' if ela0005 == .
}

sort id year
save alternative_standardization.dta, replace

