{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww13440\viewh19460\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 clear\
set more 1\
savereg, clear\
capture log close\
log using qdynamic_2001hosp.log,replace\
\
*REGRESSIONS FOR THE 2001 POLICY CHANGE\
\
use monthlydata\
\
drop if year>2001\
\
*Multiply anyhosp by 10,000\
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
gen ppo=ppo1==1|ppo2==1\
gen treat1=ppo==1 & trend==1\
gen treat2=ppo==1 & (trend==2|trend==3|trend==4)\
gen treat3=ppo==1 & (trend==5|trend==6|trend==7)\
gen treat4=ppo==1 & (trend==8|trend==9|trend==10)\
gen treat5=ppo==1 & (trend==11|trend==12|trend==13)\
gen treat6=ppo==1 & (trend==14|trend==15|trend==16)\
gen treat7=ppo==1 & (trend==17|trend==18|trend==19)\
gen treat8=ppo==1 & (trend==20|trend==21|trend==22)\
gen treat9=ppo==1 & (trend==23|trend==24)\
drop treat4\
\
xtgls anyhosp treat1-treat9  pdum* tdum* [w=obs] if basic==0, i(plans) t(trend) corr(psar1) panels(het)\
savereg treat1\
savereg treat2\
savereg treat3\
savereg treat5\
savereg treat6\
savereg treat7\
savereg treat8\
savereg treat9\
\
table2a 1 "supp plans - omitted period: -6<t<-4" 1 8 "Any hosp" "t=-13" "-12<t<-10" "-9<t<-7" "-3<t<-1" "1<t<3" "4<t<6" "7<t<9" "10<t<11"\
savereg, clear\
}