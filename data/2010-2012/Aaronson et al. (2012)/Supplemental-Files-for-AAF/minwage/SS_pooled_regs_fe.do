/*  SS_pooled_regs_fe.do   -   
    This file runs the OLS and HH Fixed Effects regressions 
    for the pooled sample.

    This file can be called interactively, or in another do-file,
    for a particular version number (i.e. set of parameters defined in intializations.gau)  
    by coding
      do SS_pooled_regs_fe.do ###

    The quantile regressions are also done here, if the quantreg is turned on
      do SS_pooled_regs_fe.do ### 1 
*/


clear
clear matrix

set mem 500m
set more 1


* If calling this do-file from another code/interactive session
local nohike `1'
local quantreg = `2'

* If running this do-file directly
*local nohike  581    /* Version to be run*/
*local quantreg = 1   /* Run quantile regressions */
*local quantreg = 0   /* Skip quantile regressions */

local hike16   `nohike'
local hike64  =`nohike'+1
local hike128 =`nohike'+2
local basepath = "C:\Research\minwage\results"
*local basepath = "D:\RESULTS_minwage"


use "`basepath'\Results_`hike16'_hike\sims\consM.dta"
replace sim_id=16+sim_id/10000 

append using "`basepath'\Results_`hike64'_hike\sims\consM.dta"
replace sim_id=64+sim_id/10000 if round(sim_id)==sim_id

append using "`basepath'\Results_`hike128'_hike\sims\consM.dta"
replace sim_id=128+sim_id/10000 if round(sim_id)==sim_id

gen hike = 1

append using "`basepath'\Results_`nohike'_nohike\sims\consM.dta"
replace hike = 0 if hike == .

gen hikeperiod=floor(sim_id) if hike==1
format sim_id %7.4f

**** Keep -2 periods before to 1 periods after (incl hike) ****
gen keeper=0
foreach num of numlist 16 64 128 {
 gen rel_time_`num'=(period-`num')
 replace keeper=1 if  (hikeperiod==`num' | hikeperiod==.) & rel_time_`num'>=-2 & rel_time_`num'<=1
 replace rel_time_`num'=. if rel_time_`num'<-2 | rel_time_`num'>1
}
keep if keeper

gen rel_time=max(rel_time_16,rel_time_64,rel_time_128)
drop rel_time_16 rel_time_64 rel_time_128

gen quarter = mod(period,4)
gen q1= 0
gen q2= 0
gen q3= 0

replace q1 = 1 if quarter == 1
replace q2 = 1 if quarter == 2
replace q3 = 1 if quarter == 3

egen q1mean = mean(q1)
egen q2mean = mean(q2)
egen q3mean = mean(q3)

gen qfe1 = q1 - q1mean
gen qfe2 = q2 - q2mean
gen qfe3 = q3 - q3mean

sort sim_id rel_time
by sim_id: egen timemean = mean(rel_time)
gen timefe = rel_time - timemean 

gen minwage = 5.50
replace minwage = 6.50 if rel_time >= 0 & hike == 1

by sim_id: egen minwagemean = mean(minwage)
gen minwagefe = minwage - minwagemean

by sim_id: egen consmean = mean(cons)
gen consfe = cons - consmean

by sim_id: egen invmean = mean(investm)
gen invfe = investm - invmean

by sim_id: egen ymean = mean(y)
gen yfe = y - ymean

*list sim_id period cons investm consmean invmean in 1/20, sepby(sim_id)

gen totalcon = cons + investm
by sim_id: egen totmean = mean(totalcon)
gen totconfe = totalcon - totmean

if `quantreg'==1 {
   * Old mimicing Dan's regression
   * qreg cons minwagefe qfe1-qfe3 timefe period2fe, quant(0.1)
   * New removing quarters since there is no seasonality in our model
   qreg totconfe minwagefe timefe, quant(0.1)
   qreg totconfe minwagefe timefe, quant(0.2)
   qreg totconfe minwagefe timefe, quant(0.3)
   qreg totconfe minwagefe timefe, quant(0.4)
   qreg totconfe minwagefe timefe, quant(0.5)
   qreg totconfe minwagefe timefe, quant(0.6)
   qreg totconfe minwagefe timefe, quant(0.7)
   qreg totconfe minwagefe timefe, quant(0.8)
   qreg totconfe minwagefe timefe, quant(0.9)
   qreg totconfe minwagefe timefe, quant(0.95)
   qreg totconfe minwagefe timefe, quant(0.98)

   *no fixed effects
   /*
   qreg totalcon minwage rel_time, quant(0.1)
   qreg totalcon minwage rel_time, quant(0.2)
   qreg totalcon minwage rel_time, quant(0.3)
   qreg totalcon minwage rel_time, quant(0.4)
   qreg totalcon minwage rel_time, quant(0.5)
   qreg totalcon minwage rel_time, quant(0.6)
   qreg totalcon minwage rel_time, quant(0.7)
   qreg totalcon minwage rel_time, quant(0.8)
   qreg totalcon minwage rel_time, quant(0.9)
   qreg totalcon minwage rel_time, quant(0.95)
   */
}


*Income Regs*
reg y minwage rel_time
reg yfe minwagefe timefe


* OLS
reg cons minwage rel_time
   global cons_OLS=_b[minwage]
reg investm minwage rel_time
   global inv_OLS=_b[minwage]

* Fixed Effect
reg consfe minwagefe timefe
   global cons_FE=_b[minwagefe]
reg invfe minwagefe timefe
   global inv_FE=_b[minwagefe]

di " " $cons_OLS " " $inv_OLS " " $cons_FE " " $inv_FE

*log close
*clear

