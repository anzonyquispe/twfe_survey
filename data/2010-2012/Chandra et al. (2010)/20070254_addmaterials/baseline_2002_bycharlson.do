{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww15060\viewh14560\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 clear\
set more 1\
savereg, clear\
capture log close\
log using baseline_2002_bycharlson.log,replace\
\
\
*REGRESSIONS FOR THE 2002 OFFICE VISIT POLICY CHANGE\
\
use monthlydata_bycharlson\
\
drop if year==2000\
drop if year==2001 & month==1\
\
replace anyhosp=anyhosp*10000\
\
egen trend=group(year month)\
\
gen plan = 1 if ppo1==1\
replace plan = 2 if ppo2==1\
replace plan = 3 if hmo1==1\
replace plan = 4 if hmo2==1\
\
gen plans = plan*10 + basic\
\
tab plans, gen(pdum)\
tab trend, gen(tdum)\
\
gen treat = (hmo1==1 & trend>11) | (hmo2==1 & trend>11)\
\
gen office=officehmo\
\
*OFFICE VISITS\
\
foreach x in 0 13 419 \{\
xtgls officehmo treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_totalpay_office treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_netpay_office treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_mcare_office treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans" 4 3 "Visits" "TotalPay" "InsPay" "McarePay" "Charlson: 0" "Charlson: 1-3" "Charlson: 4+"\
savereg, clear\
\
* HOSP\
foreach x in 0 13 419 \{\
xtgls anyhosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_totalpay_hosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_netpay_hosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_mcare_hosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans" 4 3 "AnyHosp" "TotalPay" "InsPay" "McarePay" "Charlson: 0" "Charlson: 1-3" "Charlson: 4+"\
savereg, clear\
\
* DROP IMMEDIATE PRE- AND POST- PERIOD, SO THAT OUR ESTIMATES DON'T REFLECT TIMING\
\
drop if year==2001 & month>=10\
drop if year==2002 & month<=3\
\
* OFFICE - SUPPLEMENTAL\
foreach x in 0 13 419 \{\
xtgls officehmo treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_totalpay_office treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_netpay_office treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_mcare_office treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans - EXCLUDE T-1 & T+1" 4 3 "Visits" "TotalPay" "InsPay" "McarePay" "Charlson: 0" "Charlson: 1-3" "Charlson: 4+"\
savereg, clear\
\
* HOSP\
foreach x in 0 13 419 \{\
xtgls anyhosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_totalpay_hosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_netpay_hosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_mcare_hosp treat  pdum* tdum* [w=obs] if basic==0 & charlson==`x', corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
\}\
\
table2a 1 "DD - supplemental plans - EXCLUDES T-1 & T+1" 4 3 "AnyHosp" "TotalPay" "InsPay" "McarePay" "Charlson: 0" "Charlson: 1-3" "Charlson: 4+"\
savereg, clear\
}