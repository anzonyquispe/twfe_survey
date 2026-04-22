{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww13520\viewh15340\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 clear\
set more 1\
savereg, clear\
capture log close\
log using baseline_2002hosp.log,replace\
\
*REGRESSIONS FOR THE 2002 POLICY CHANGE\
\
use monthlydata\
\
drop if year==2000\
drop if year==2001 & month==1\
\
*Multiply anyhosp by 10000\
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
foreach x in anyhosp dayscount imputed_totalpay_hosp imputed_netpay_hosp imputed_mcare_hosp  \{\
xtgls `x'  treat  pdum* tdum* [w=obs] if basic==0, i(plans) t(trend) corr(psar1) panels(het)\
savereg treat\
\}\
\
table2a 1 "DD - supplemental plans" 1 5 "DD" "Any hosp" "Hosp days" "TotalPay hosp" "InsPay hosp" "McarePay hosp" \
savereg, clear\
\
* DROP IMMEDIATE PRE- AND POST- PERIOD, SO THAT OUR ESTIMATES DON'T REFLECT TIMING\
\
drop if year==2001 & month>=10\
drop if year==2002 & month<=3\
\
foreach x in anyhosp dayscount imputed_totalpay_hosp imputed_netpay_hosp imputed_mcare_hosp \{\
xtgls `x'  treat  pdum* tdum* [w=obs] if basic==0, i(plans) t(trend) corr(psar1) panels(het) force\
savereg treat\
\}\
\
table2a 1 "DD - supplemental plans - EXCLUDES T-1 AND T+1" 1 5 "DD" "Any hosp" "Hosp days" "TotalPay hosp" "InsPay hosp" "McarePay hosp" \
savereg, clear\
\
\
exit\
}