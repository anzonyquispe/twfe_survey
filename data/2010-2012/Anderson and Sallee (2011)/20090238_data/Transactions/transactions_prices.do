*********************
***** FILE INFO *****
*********************
* Name: transactions_prices
* Author: Soren Anderson
* Date: May 28, 2010
* Description:



*************************
***** PRELIMINARIES *****
*************************
clear
cd
cd "Y:/Biofuels/FFV CAFE/Transactions"
log using transactions_prices.txt, replace text
set more off
set mem 800m



use transactions1



****************************************
***** TABLE 3: SUMMARY STATISTICS  *****
****************************************
tabstat ffv price msrp manurebate daystoturn loandealer irate downpay monthly lterm tradein tradebal age female e85pen if sample==1, s(mean sd min max n) format column(statistics)



***********************************************
***** TABLE 4: FFVS IN ESTIMATION SAMPLE  *****
***********************************************
tab model_num ffv if sample==1

* ANCILLARY INFO
tab model_num count if price~=. 			/* BY MODEL NAME: NUMBER OF UNIQUE VINS PER SPECIFIC VEHICLE TYPE */
tab model_num ffvvar if price~=. & count==2	/* BY MODEL NAME: DOES SPECIFIC VEHICLE TYPE HAVE VARIATION IN FFV? */
tab year ffv if sample==1				/* BY MODEL YEAR: FFVS AND GASOLINE VEHICLES IN ESTIMATION SAMPLE */



*******************************************************
***** TABLE 6: FFV PREMIUM AND RELATED DISCUSSION *****
*******************************************************
* (1) MAIN RESULTS
codebook group_all if sample==1 & ffvvar2==1 & price~=.
xtreg price ffv if sample==1, i(group_all) fe cluster(group_all)

* ALTERNATIVELY CLUSTERED SES (MENTIONED IN TABLE NOTE)
xtreg price ffv if sample==1, i(group_all) fe cluster(group_notimes)
xtreg price ffv if sample==1, i(group_all) fe cluster(group_nostate)
xtreg price ffv if sample==1, i(group_all) fe cluster(group)
xtreg price ffv if sample==1, i(group_all) fe cluster(state)

* (2) CASH SALES
codebook group_all if sample==1 & type==1 & ffvvar2==1 & price~=.
xtreg price ffv if sample==1 & type==1, i(group_all) fe cluster(group_all)
gen sample_cash = e(sample)

* ALTERNATIVELY CLUSTERED SES (MENTIONED IN TABLE NOTE)
xtreg price ffv if sample==1 & type==1, i(group_all) fe cluster(group_notimes)
xtreg price ffv if sample==1 & type==1, i(group_all) fe cluster(group_nostate)
xtreg price ffv if sample==1 & type==1, i(group_all) fe cluster(group)
xtreg price ffv if sample==1 & type==1, i(group_all) fe cluster(state)

* MSRP (MENTIONED IN FOOTNOTE 25)
codebook group_all if sample==1 & ffvvar2==1 & msrp~=.
xtreg msrp ffv if sample==1, i(group_all) fe cluster(group_all)
gen sample_msrp = e(sample)

* MAIN RESULTS ON MSRP SAMPLES (MENTIONED IN FOOTNOTE 25)
xtreg price ffv if sample_msrp==1, i(group_all) fe cluster(group_all)

* MANUFACTURER REBATE (RELEVANT TO DISCUSSION IN FOOTNOTE 23)
codebook group_all if sample==1 & ffvvar2==1 & manurebate~=.
xtreg manurebate ffv if sample==1, i(group_all) fe cluster(group_all)

* MAIN RESULTS ON CASH SALES SAMPLE
xtreg price ffv if sample_cash==1, i(group_all) fe cluster(group_all)

* ALL FFV MODELS (INCLUDING THOSE WITH 1 OR 3+ VINS PER SPECIFIC VEHICLE TYPE)
codebook group_all if ffvvar2==1 & price~=.
xtreg price ffv, i(group_all) fe cluster(group_all)



****************************************************
***** TABLE 7: ARE FFV TRANSACTIONS DIFFERENT? *****
****************************************************
* (1) DAYS ON LOT
codebook group_all if sample==1 & ffvvar2==1 & daystoturn~=.
xtreg daystoturn ffv if sample==1, i(group_all) fe cluster(group_all)

* (2) DEALER LOAN?
codebook group_all if sample==1 & ffvvar2==1 & loandealer~=.
xtreg loandealer ffv if sample==1, i(group_all) fe cluster(group_all)

* (3) INTEREST RATE
codebook group_all if sample==1 & ffvvar2==1 & irate~=.
xtreg irate ffv if sample==1, i(group_all) fe cluster(group_all)

* (4) TOTAL DOWN
codebook group_all if sample==1 & ffvvar2==1 & downpay~=.
xtreg downpay ffv if sample==1, i(group_all) fe cluster(group_all)

* (5) MONTHLY PAYMENT
codebook group_all if sample==1 & ffvvar2==1 & monthly~=.
xtreg monthly ffv if sample==1, i(group_all) fe cluster(group_all)

* (6) LOAN TERM
codebook group_all if sample==1 & ffvvar2==1 & lterm~=.
xtreg lterm ffv if sample==1, i(group_all) fe cluster(group_all)

* (7) TRADE AUTO?
codebook group_all if sample==1 & ffvvar2==1 & tradein~=.
xtreg tradein ffv if sample==1, i(group_all) fe cluster(group_all)

* (8) TRADE BALANCE
codebook group_all if sample==1 & ffvvar2==1 & tradebal~=.
xtreg tradebal ffv if sample==1, i(group_all) fe cluster(group_all)

* (9) AGE OF BUYER
codebook group_all if sample==1 & ffvvar2==1 & age~=.
xtreg age ffv if sample==1, i(group_all) fe cluster(group_all)

* (10) FEMALE BUYER?
codebook group_all if sample==1 & ffvvar2==1 & female~=.
xtreg female ffv if sample==1, i(group_all) fe cluster(group_all)



log close
exit
