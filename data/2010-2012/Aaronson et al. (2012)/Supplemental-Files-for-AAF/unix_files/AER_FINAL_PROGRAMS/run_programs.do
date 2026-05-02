*******************************************
* Produce CEX, CPS and SIPP Estimates for *     
* Aaronson, Agarwal and French (2011)     *
*******************************************

* Preliminaries 
clear all
set more off

* Create dataset with all minimum wage changes
do mw.do

* Create a sas version of mw data for credit card program.
* The command "st" calls the program stat transfer.
! st mw9508.dta mw9508.sas7bdat

* Merge data on other government programs with minimum wage data
do addotherprogs.do

* Use CEX data CDs to create initial CEX dataset
*do mkcex/D1_MM_minwage.do
*do mkcex/D2_MM_pull_pre91.do
*do mkcex/D3_MM_add_heqdetail.do
*do mkcex/collate_aug10_update.do

*Create CEX extract and results
do cex.do

*Recreate CPS data and replicate results
*cps_subset.sas draws from a CPS Outgoing Rotations sample created using CPS Utilities.
! sas cps_subset.sas 
! st ogr_select.sas7bdat ogr_select.dta -o
do cps.do

*Recreate SIPP data and replicate results
do make_sipp.do
do sipp_weights.do 
do sipp.do

* Pooled version of Table 1
do table1_pooled.do

*Share of Minimum Wage Earners Who Are Teenagers
do cps_teenMW.do

*Count of Households with S>=0.2 in 2006
do cps_countMW_households.do

*Create CPS March Extract 
* mw_probit_extract.sas draws from a CPS March sample created by CPS utilities.
! sas mw_probit_extract
! st mar_probit.sas7bdat mar_probit.dta

* Probit to estimate probability of being a minimum wage earner
do probit.do

* Administrative Bank and Credit Bureau Data
* The directories in BankCredit.sas need to be changed in order to run it on another computer.
*! sas BankCredit.sas

*!st minwage_less20k.sas7bdat minwage_less20k.dta
*!st minwage_more20k.sas7bdat minwage_more20k.dta
*!st minwage_figure3_less20k.sas7bdat minwage_figure3_less20k.dta
*!st minwage_figure3_more20k.sas7bdat minwage_figure3_more20k.dta

*do creditcard.do

exit