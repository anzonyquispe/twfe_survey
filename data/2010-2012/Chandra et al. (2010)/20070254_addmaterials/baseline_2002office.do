{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww17640\viewh18100\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 clear\
set more 1\
savereg, clear\
capture log close\
log using baseline_2002office.log,replace\
\
*REGRESSIONS FOR THE 2002 OFFICE VISIT POLICY CHANGE\
\
use monthlydata\
\
drop if year==2000\
drop if year==2001 & month==1\
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
sort plans year month\
\
gen pmo = plans*100+month\
tab pmo, gen(pmdum)\
\
gen copay_office=copay_o\
gen deduct_office=deduct_o\
gen oop_office=oop_o\
\
gen office=officehmo\
\
foreach x in copay_office deduct_office oop_office office imputed_totalpay_office imputed_netpay_office imputed_mcare_office \{\
xtgls `x' treat  pdum* tdum* [w=obs] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
\}\
\
table2a 1 "DD - supplemental plans" 1 7 "DD" "office copay" "office deduc" "office oop" "office visits" "Office TotalPay" "Office InsPay" "Office McarePay" \
savereg, clear\
\
* DROP IMMEDIATE PRE- AND POST- PERIOD, SO THAT OUR ESTIMATES DON'T REFLECT TIMING\
\
drop if year==2001 & month>=10\
drop if year==2002 & month<=3\
\
foreach x in copay_office deduct_office oop_office office imputed_totalpay_office imputed_netpay_office imputed_mcare_office\
costshare_office \{\
xtgls `x' treat  pdum* tdum* [w=obs] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
\}\
\
table2a 1 "DD - supplemental plans - EXCLUDE T-1 & T+1" 1 8 "DD" "office copay" "office deduc" "office oop" "office visits" "Office Totalpay" "Office InsPay" "Office McarePay" "Cost-sharing" \
savereg, clear\
}