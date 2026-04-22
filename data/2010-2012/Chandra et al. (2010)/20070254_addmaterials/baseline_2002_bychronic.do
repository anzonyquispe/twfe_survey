{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww17760\viewh16920\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 clear\
set more 1\
savereg, clear\
capture log close\
log using baseline_2002_bychronic.log,replace\
\
\
*REGRESSIONS FOR THE 2002 OFFICE VISIT POLICY CHANGE\
\
use monthlydata_bychronic\
\
drop if year==2000\
drop if year==2001 & month==1\
\
foreach x in any hypertension hypercholest asthma diabetes arthritis depression gastritis none \{\
*Multiply dep vars by 10000\
replace anyhosp_`x'=anyhosp_`x'*10000\
\}\
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
* OFFICE VISITS\
foreach x in any hypertension hypercholest asthma diabetes arthritis depression gastritis none \{\
xtgls officehmo_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_totalpay_o_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_netpay_o_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_mcare_o_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans" 4 9 "Visits" "TotalPay" "InsPay" "McarePay" "Any chronic condn" "Hypertension" "Hypercholest" "Asthma" "Diabetes" "Arthritis" "Depression" "Gastritis" "None"\
savereg, clear\
\
*HOSP\
\
foreach x in any hypertension hypercholest asthma diabetes arthritis depression gastritis none \{\
xtgls anyhosp_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_totalpay_h_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_netpay_h_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
xtgls imputed_mcare_h_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans" 4 9 "AnyHosp" "TotalPay" "InsPay" "McarePay" "Any chronic condn" "Hypertension" "Hypercholest" "Asthma" "Diabetes" "Arthritis" "Depression" "Gastritis" "None"\
savereg, clear\
\
* DROP IMMEDIATE PRE- AND POST- PERIOD, SO THAT OUR ESTIMATES DON'T REFLECT TIMING\
\
drop if year==2001 & month>=10\
drop if year==2002 & month<=3\
\
*OFFICE VISITS\
foreach x in any hypertension hypercholest asthma diabetes arthritis depression gastritis none \{\
xtgls officehmo_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_totalpay_o_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_netpay_o_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_mcare_o_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans - EXCLUDE T-1 & T+1" 4 9 "Visits" "TotalPay" "InsPay" "McarePay" "Any chronic condn" "Hypertension" "Hypercholest" "Asthma" "Diabetes" "Arthritis" "Depression" "Gastritis" "None"\
savereg, clear\
\
*HOSP\
\
foreach x in any hypertension hypercholest asthma diabetes arthritis depression gastritis none \{\
xtgls anyhosp_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_totalpay_h_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_netpay_h_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
xtgls imputed_mcare_h_`x' treat  pdum* tdum* [w=obs_`x'] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic) force\
savereg treat\
\
\}\
\
table2a 1 "DD - supplemental plans - EXCLUDES T-1 & T+1" 4 9 "AnyHosp" "TotalPay" "InsPay" "McarePay" "Any chronic condn" "Hypertension" "Hypercholest" "Asthma" "Diabetes" "Arthritis" "Depression" "Gastritis" "None"\
savereg, clear\
}