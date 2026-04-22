* this reads in the school level reports on Student Performace Scores from LA website
* merges in percent katrina in 2006 to ask whether percent katrina is correlated with pre-levels or trends

clear
set mem 700m
capture log close



cd "C:\katrina\sps"

log using la_school_level_log, text replace
set more off




use 1999.dta
gen year=1999
append using 2000.dta
replace year=2000 if year==.

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

replace year = year + 2
sort sitecode year

merge sitecode year using school_level_means, nokeep
keep if _merge == 3


foreach var of varlist percent_katrinaTIMESERIES2 Kfraction* {
  replace `var' = 0 if year < 2004
}


*GENERATE AVERAGE OF MATH & ELA KFRACTION SHARES
egen Kfraction_Q1 = rmean(Kfraction_mathQ1 Kfraction_elaQ1)
egen Kfraction_Q2 = rmean(Kfraction_mathQ2 Kfraction_elaQ2)
egen Kfraction_Q3 = rmean(Kfraction_mathQ3 Kfraction_elaQ3)
egen Kfraction_Q4 = rmean(Kfraction_mathQ4 Kfraction_elaQ4)



xi i.year

areg sps percent_katrinaTIMESERIES2 _I* if Kfraction_Q1 != ., absorb(sitecode) cluster(sitecode)
areg sps Kfraction_Q1 Kfraction_Q2 Kfraction_Q3 Kfraction_Q4 _I*, absorb(sitecode) cluster(sitecode)


areg sps percent_katrinaTIMESERIES2 _I* free_lunchA male black hisp asian gryr* if Kfraction_Q1 != ., absorb(sitecode) cluster(sitecode)
areg sps Kfraction_Q1 Kfraction_Q2 Kfraction_Q3 Kfraction_Q4 _I* free_lunchA male black hisp asian gryr*, absorb(sitecode) cluster(sitecode)





log close

f







summ sps change_sps

by year,sort: summ sps change_sps


reg percent_katrinaTIMESERIES2 change_sps, robust 

endsas;
* areg sps percent_k
atrinaTIMESERIES2, absorb(sitecode) cluster(sitecode)








