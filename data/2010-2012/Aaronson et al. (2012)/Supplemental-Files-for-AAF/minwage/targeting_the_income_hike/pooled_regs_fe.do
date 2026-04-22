*** pooled_regs_fe.do

** Part 1 converts consM.txt to .dta
** data is read in inconsistently: sometimes read in as string, sometimes as number. 
** this code takes care of that.

** Part 2 does the fixed effect income regression

*---------------- PART 1 ------------------------------------------------------------------*

program check
   clear
   cd "C:\Research\minwage\targeting_the_income_hike"
   insheet period y using income_`1'.txt, comma
   describe
end

*****************

program long
   gen period2 = real(substr(period,1,5))
   drop period
   rename period2 period

   gen y2 = real(substr(y,1,10))
   drop y
   rename y2 y

   save income_`1', replace
end
*****************

program short
   save consM, replace
end

*****************

program convert
 check `1' 
 capture confirm numeric variable period
 if _rc {
   long
 }
 else {
   short
 }
 sort period, stable
 by period: gen sim_id=_n
 save income_`1', replace
end

************

convert nohike
convert hike16
convert hike64
convert hike128


*---------------- PART 2 ------------------------------------------------------------------*
************Regs ********************

clear 

use "C:\Research\minwage\targeting_the_income_hike\income_hike16.dta"
replace sim_id=16+sim_id/10000 

append using "C:\Research\minwage\targeting_the_income_hike\income_hike64.dta"
replace sim_id=64+sim_id/10000 if round(sim_id)==sim_id

append using "C:\Research\minwage\targeting_the_income_hike\income_hike128.dta"
replace sim_id=128+sim_id/10000 if round(sim_id)==sim_id

gen hike = 1

append using "C:\Research\minwage\targeting_the_income_hike\income_nohike.dta"
replace hike = 0 if hike == .

gen hikeperiod=floor(sim_id) if hike==1
format sim_id %7.4f

**** Keep -10 periods before to 10 periods after (incl hike) ****
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

by sim_id: egen ymean = mean(y)
gen yfe = y - ymean

*list sim_id period cons investm consmean invmean in 1/20, sepby(sim_id)

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


*Income Regs*
reg y minwage rel_time
reg yfe minwagefe timefe
reg yfe minwagefe timefe if hikeperiod==16 | (hikeperiod==. & period>=14 & period<=17)
reg yfe minwagefe timefe if hikeperiod==64 | (hikeperiod==. & period>=62 & period<=65)
reg yfe minwagefe timefe if hikeperiod==128 | (hikeperiod==. & period>=126 & period<=129)

clear

