/*  SS_sims_reg_fe.do   -   
    This file runs the OLS and HH Fixed Effects regressions 
    for a particular hike-age (timing of the minimum wage hike)

    This file is called 3 times by SS_all_regs.do
*/

clear
clear matrix

set mem 500m
set more 1

*if want to call several runs from another stata code, as in SS_all_regs.do, then this part should be used
local nohike `1'
local hike   `2'

*if want to run this file stand-alone, use this instead.
*local nohike 571
*local hike 571

*hikeperiod = 16  64 128 for new ages
if mod(`hike',10)==1 local hikeperiod 16
if mod(`hike',10)==2 local hikeperiod 64
if mod(`hike',10)==3 local hikeperiod 128
di "hikeperiod = " `hikeperiod'


use "C:\Research\minwage\results\Results_`nohike'_nohike\sims\consM.dta"
*use "D:\RESULTS_minwage\Results_`nohike'_nohike\sims\consM.dta"
gen hike = 0
replace sim_id=sim_id*10


append using "C:\Research\minwage\results\Results_`hike'_hike\sims\consM.dta"
*append using "D:\RESULTS_minwage\Results_`hike'_hike\sims\consM.dta"
replace hike = 1 if hike == .


*keep if period > (`hikeperiod' -3)
*keep if period < (`hikeperiod' +3)
keep if period > (`hikeperiod' -3)
keep if period < (`hikeperiod' +2)
tab period

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

gen period2 = period*period


sort sim_id period

by sim_id: egen periodmean = mean(period)
by sim_id: egen period2mean = mean(period2)

gen periodfe = period - periodmean 
gen period2fe = period2 - period2mean 

gen minwage = 5.50
replace minwage = 6.50 if period >= `hikeperiod' & hike == 1

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

* Old mimicing Dan's regression
* qreg cons minwagefe qfe1-qfe3 periodfe period2fe, quant(0.1)
* New removing quarters since there is no seasonality in our model
/*qreg totconfe minwagefe periodfe, quant(0.1)
qreg totconfe minwagefe periodfe, quant(0.2)
qreg totconfe minwagefe periodfe, quant(0.3)
qreg totconfe minwagefe periodfe, quant(0.4)
qreg totconfe minwagefe periodfe, quant(0.5)
qreg totconfe minwagefe periodfe, quant(0.6)
qreg totconfe minwagefe periodfe, quant(0.7)
qreg totconfe minwagefe periodfe, quant(0.8)
qreg totconfe minwagefe periodfe, quant(0.9)
qreg totconfe minwagefe periodfe, quant(0.95)

*no fixed effects
qreg totalcon minwage period, quant(0.1)
qreg totalcon minwage period, quant(0.2)
qreg totalcon minwage period, quant(0.3)
qreg totalcon minwage period, quant(0.4)
qreg totalcon minwage period, quant(0.5)
qreg totalcon minwage period, quant(0.6)
qreg totalcon minwage period, quant(0.7)
qreg totalcon minwage period, quant(0.8)
qreg totalcon minwage period, quant(0.9)
qreg totalcon minwage period, quant(0.95)
*/


/*Income Regs*
reg y minwage period
reg yfe minwagefe periodfe*/

* OLS
reg cons minwage period
   global cons_OLS=_b[minwage]
reg investm minwage period
   global inv_OLS=_b[minwage]

* Fixed Effect
reg consfe minwagefe periodfe
   global cons_FE=_b[minwagefe]
reg invfe minwagefe periodfe
   global inv_FE=_b[minwagefe]


di " " $cons_OLS " " $inv_OLS " " $cons_FE " " $inv_FE

*log close
*clear

