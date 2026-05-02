clear all

set mem 3g

* Notes:
*  allbal=ddebt+mtgbal+helbal+autobal
* try allbal2=debt+mtgbal+helbal+autobal
* No state dummies because they don't vary within accounts, so they are captured by fixed effect.



log using table5_less20k.log, replace

***************************
* Table 5 - Less than 20k *
***************************
use minwage_less20k if goodacct==1

replace allbal = allbal-ddebt+debt
replace allbal_nomtg = allbal_nomtg-ddebt+debt

areg autobal minwage md*, absorb(account_id) cluster(account_id)
areg helbal minwage md*, absorb(account_id) cluster(account_id)
areg mtgbal minwage md*, absorb(account_id) cluster(account_id)
areg ddebt minwage md*, absorb(account_id) cluster(account_id)
areg debt minwage md*, absorb(account_id) cluster(account_id)
areg allbal minwage md*, absorb(account_id) cluster(account_id)
areg allbal_nomtg minwage md*, absorb(account_id) cluster(account_id)

log close
log using table5_more20k.log, replace

***************************
* Table 5 - More than 20k *
***************************
clear
use minwage_more20k if goodacct==1

replace allbal = allbal-ddebt+debt
replace allbal_nomtg = allbal_nomtg-ddebt+debt

areg autobal minwage md*, absorb(account_id) cluster(account_id)
areg helbal minwage md*, absorb(account_id) cluster(account_id)
areg mtgbal minwage md*, absorb(account_id) cluster(account_id)
areg ddebt minwage md*, absorb(account_id) cluster(account_id)
areg debt minwage md*, absorb(account_id) cluster(account_id)
areg allbal minwage md*, absorb(account_id) cluster(account_id)
areg allbal_nomtg minwage md*, absorb(account_id) cluster(account_id)

log close

log using creditcard_table_a1.log, replace
************
* Table A1 *
************
clear
use minwage_less20k if goodacct==1

su income1 fico1 ofrut_bal_ct ofbal1 helbal mtgbal autobal
su helbal if helbal>0
su mtgbal if mtgbal>0
su autobal if autobal>0

clear
use minwage_more20k

su income1 fico1 ofrut_bal_ct ofbal1 helbal mtgbal autobal
su helbal if helbal>0
su mtgbal if mtgbal>0
su autobal if autobal>0

log close

log using fig3_less20k.log, replace


****************************
* Figure 3 - Less Than 20k *
****************************
clear
use minwage_figure3_less20k if goodacct==1

replace allbal = allbal-ddebt+debt
replace allbal_nomtg = allbal_nomtg-ddebt+debt

areg allbal_nomtg mw9ld mw8ld mw7ld mw6ld mw5ld mw4ld mw3ld mw2ld mw1ld minwage mw1 mw2 mw3 mw4 mw5 mw6 mw7 mw8 ///
 mw9 mw10 mw11 mw12 mw13 mw14 mw15 mw16 mw17 mw18 mw19 mw20 mw21 mw22 mw23 mw24 mw25 mw26 mw27 mw28 mw29 ///
 md*, absorb(account_id) cluster(account_id)
  
  *3 Quarters before minimum wage increase
 lincom mw9ld + mw8ld + mw7ld
 
 *2 Quarters before minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld
 
  *1 Quarter before minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld
 
 *Quarter of minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + mw2
 
 *1 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5
 
 *2 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 
 
 *3 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11
 
 *4 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 
 
  *5 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 
 
  *6 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20
 
 *7 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20 + mw21 + mw22 + mw23

 
 *8 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20 + mw21 + mw22 + mw23 + mw24 + mw25 + mw26
				 
 *9 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20 + mw21 + mw22 + mw23 + mw24 + mw25 + mw26 + ///
				 mw27 + mw28 + mw29 
				 
				 
log close
log using fig3_more20k.log, replace
****************************
* Figure 3 - More Than 20k *
****************************
clear
use minwage_figure3_less20k if goodacct==1
 
replace allbal = allbal-ddebt+debt
replace allbal_nomtg = allbal_nomtg-ddebt+debt

areg allbal_nomtg mw9ld mw8ld mw7ld mw6ld mw5ld mw4ld mw3ld mw2ld mw1ld minwage mw1 mw2 mw3 mw4 mw5 mw6 mw7 mw8 ///
 mw9 mw10 mw11 mw12 mw13 mw14 mw15 mw16 mw17 mw18 mw19 mw20 mw21 mw22 mw23 mw24 mw25 mw26 mw27 mw28 mw29 ///
 md*, absorb(account_id) cluster(account_id)
  
  *3 Quarters before minimum wage increase
 lincom mw9ld + mw8ld + mw7ld
 
 *2 Quarters before minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld
 
  *1 Quarter before minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld
 
 *Quarter of minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + mw2
 
 *1 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5
 
 *2 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 
 
 *3 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11
 
 *4 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 
 
  *5 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 
 
  *6 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20
 
 *7 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20 + mw21 + mw22 + mw23

 
 *8 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20 + mw21 + mw22 + mw23 + mw24 + mw25 + mw26
				 
 *9 quarters after minimum wage increase
 lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + ///
				 mw2 + mw3 + mw4 + mw5 + mw6 + mw7 + mw8 + mw9 + mw10 + mw11 + mw12 + mw13 + mw14 + mw15 + ///
				 mw16 + mw17 + mw18 + mw19 + mw20 + mw21 + mw22 + mw23 + mw24 + mw25 + mw26 + ///
				 mw27 + mw28 + mw29 

log close


log using fig4_less20k.log, replace
****************************
* Figure 4 - Less Than 20k *
****************************
clear
use minwage_less20k if goodacct==1

replace allbal = allbal-ddebt+debt
replace allbal_nomtg = allbal_nomtg-ddebt+debt

sort account_id
foreach var of varlist allbal_nomtg minwage time time2 {
 by account_id: egen mean_`var' = mean(`var')
 gen fe_`var' = `var'-mean_`var'
}

sqreg fe_allbal_nomtg fe_minwage fe_time fe_time2, quantiles(.1 .2 .3 .4 .5 .6 .7 .8 .9 .95 .98)

log close


log using fig4_more20k.log, replace

****************************
* Figure 4 - More Than 20k *
****************************
clear
use minwage_more20k if goodacct==1

replace allbal = allbal-ddebt+debt
replace allbal_nomtg = allbal_nomtg-ddebt+debt

sort account_id
foreach var of varlist allbal_nomtg minwage time time2 {
 by account_id: egen mean_`var' = mean(`var')
 gen fe_`var' = `var'-mean_`var'
}

sqreg fe_allbal_nomtg fe_minwage fe_time fe_time2, quantiles(.1 .2 .3 .4 .5 .6 .7 .8 .9 .95 .98) reps(100)

log close

log using cc_newloans.log, replace
***************************
* % Increase in New Loans *
***************************
clear
use minwage_less20k if goodacct==1
tostring ext_dt, replace
gen year = substr(ext_dt,1,4)
gen month = substr(ext_dt,5,2)
destring year month, replace

gen quarter = 1 if month>=1 & month<=3
replace quarter = 2 if month>=4 & month<=6
replace quarter = 3 if month>=7 & month<=9
replace quarter = 4 if month>=10 & month<=12

collapse mw_nominal mtgbal helbal autobal, by(account_id year quarter)
sort account_id year quarter
foreach var of varlist mw_nominal mtgbal helbal autobal {
 by account_id : gen l`var' = `var'[_n-1]
}
foreach var of varlist mtgbal helbal autobal {
 gen new`var' = `var'>0 & `var'<. & l`var'==0
}
gen newloan = (newmtgbal+newhelbal+newautobal)>0 if (newmtgbal+newhelbal+newautobal)<.
gen dmw = (mw_nominal-lmw_nominal)>0 & (mw_nominal-lmw_nominal)<.

reg newloan dmw, cluster(account_id) 

log close

log using cc_delinquent.log, replace
******************************************************************
* Probability an Account is 60 Days Delinquent After MW Increase *
******************************************************************

clear
use minwage_figure3_less20k

* At least 6 months ago
gen dmw = mw_nominal~=mw6_nominal & mw6_nominal~=. & mw_nominal~=.

* Exactly 6 months ago
gen d6mw = mw_nominal~=mw6_nominal & mw5_nominal==mw_nominal & mw6_nominal~=.  & mw_nominal~=.

* Method 1
areg delinq d6mw md*, absorb(account_id) cluster(account_id)

* Method 2
areg delinq mw6 md*, absorb(account_id) cluster(account_id)

* Method 3
areg delinq mw9ld mw8ld mw7ld mw6ld mw5ld mw4ld mw3ld mw2ld mw1ld minwage mw1 mw2 mw3 mw4 mw5 mw6 mw7 mw8 ///
 mw9 mw10 mw11 mw12 mw13 mw14 mw15 mw16 mw17 mw18 mw19 mw20 mw21 mw22 mw23 mw24 mw25 mw26 mw27 mw28 mw29 ///
 md*, absorb(account_id) cluster(account_id)

*Two months after minimum wage increase
lincom mw9ld + mw8ld + mw7ld + mw6ld + mw5ld + mw4ld + mw3ld + mw2ld + mw1ld + minwage + mw1 + mw2
 
log close
exit