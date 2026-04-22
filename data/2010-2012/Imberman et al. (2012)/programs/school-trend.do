* this reads in the school level reports on Student Performace Scores from LA website
* merges in percent katrina in 2006 to ask whether percent katrina is correlated with pre-levels or trends

clear
set mem 700m
capture log close



cd "C:\katrina\sps"

log using la_school_level_log, text replace
set more off

use school_level_means, clear
 foreach var of varlist Kfraction_* percent_katrina* {
   gen temp = `var' if year == 2006
   egen temp2 = mean(temp), by (sitecode)
   replace `var' = temp2
   drop temp temp2
}
sort sitecode year
save school_means_oneyear, replace
   

use 2000.dta
gen year=2000

append using 2001.dta
replace year=2001 if year==.

append using 2002.dta
replace year=2002 if year==.

append using 2003.dta
replace year=2003 if year==.


append using 2004.dta
replace year=2004 if year==.

append using 2005.dta
replace year=2005 if year==.


destring sitecode, force replace

sort sitecode year
merge sitecode year using school_means_oneyear, nokeep
keep if _merge == 3




*GENERATE AVERAGE OF MATH & ELA KFRACTION SHARES
egen Kfraction_Q1 = rmean(Kfraction_mathQ1 Kfraction_elaQ1)
egen Kfraction_Q2 = rmean(Kfraction_mathQ2 Kfraction_elaQ2)
egen Kfraction_Q3 = rmean(Kfraction_mathQ3 Kfraction_elaQ3)
egen Kfraction_Q4 = rmean(Kfraction_mathQ4 Kfraction_elaQ4)

tab year, gen(year_)

foreach var of varlist year_2 year_3 year_4 year_5 year_6 {
  gen percent_katrina_`var' = percent_katrinaTIMESERIES2*`var'
  gen Kfraction_Q1_`var' = Kfraction_Q1*`var'
  gen Kfraction_Q2_`var' = Kfraction_Q2*`var'
  gen Kfraction_Q3_`var' = Kfraction_Q3*`var'
  gen Kfraction_Q4_`var' = Kfraction_Q4*`var'
}



xi i.year
cap rm school_trend.txt
cap rm school_trend.xls

reg sps percent_katrina_year_* _I* if Kfraction_Q1 != ., cluster(sitecode)
outreg2 percent_katrina* using school_trend.xls, excel dec(1)
reg sps Kfraction_Q1_year_* Kfraction_Q2_year_*  Kfraction_Q3_year_*  Kfraction_Q4_year_*  _I*, cluster(sitecode)
outreg2 Kfraction_* using school_trend.xls, excel dec(1)


areg sps percent_katrina_year_* _I* if Kfraction_Q1 != ., absorb(sitecode) cluster(sitecode)
outreg2 percent_katrina* using school_trend.xls, excel dec(1)
areg sps Kfraction_Q1_year_* Kfraction_Q2_year_*  Kfraction_Q3_year_*  Kfraction_Q4_year_*  _I*, absorb(sitecode) cluster(sitecode)
outreg2 Kfraction_* using school_trend.xls, excel dec(1)

areg sps percent_katrina_year_* _I* free_lunchA male black hisp asian gryr* if Kfraction_Q1 != ., absorb(sitecode) cluster(sitecode)
outreg2 percent_katrina_* using school_trend.xls, excel dec(1)

areg sps Kfraction_Q1_year_* Kfraction_Q2_year_*  Kfraction_Q3_year_*  Kfraction_Q4_year_*  _I* free_lunchA male black hisp asian gryr*, absorb(sitecode) cluster(sitecode)
outreg2 Kfraction_* using school_trend.xls, excel dec(1)





log close

f







summ sps change_sps

by year,sort: summ sps change_sps


reg percent_katrinaTIMESERIES2 change_sps, robust 

endsas;
* areg sps percent_k
atrinaTIMESERIES2, absorb(sitecode) cluster(sitecode)








