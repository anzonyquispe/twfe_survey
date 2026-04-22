{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww14280\viewh17580\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 version 8.1\
clear\
set more 1\
savereg, clear\
capture program drop makegraph\
capture log close\
log using qdynamic_2002office.log,replace\
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
*Treatment occurs at trend=12\
gen treat1=(hmo1==1|hmo2==1) & (trend==1|trend==2)\
gen treat2=(hmo1==1|hmo2==1) & (trend==3|trend==4|trend==5)\
gen treat3=(hmo1==1|hmo2==1) & (trend==6|trend==7|trend==8)\
gen treat4=(hmo1==1|hmo2==1) & (trend==9|trend==10|trend==11)\
gen treat5=(hmo1==1|hmo2==1) & (trend==12|trend==13|trend==14)\
gen treat6=(hmo1==1|hmo2==1) & (trend==15|trend==16|trend==17)\
gen treat7=(hmo1==1|hmo2==1) & (trend==18|trend==19|trend==20)\
gen treat8=(hmo1==1|hmo2==1) & (trend==21|trend==21|trend==23)\
gen treat9=(hmo1==1|hmo2==1) & (trend==24|trend==25|trend==26)\
gen treat10=(hmo1==1|hmo2==1) & (trend==27|trend==28|trend==29)\
gen treat11=(hmo1==1|hmo2==1) & (trend==30|trend==31|trend==32)\
drop treat3\
\
\
xtgls officehmo treat1-treat11 pdum* tdum* [w=obs] if basic==0, corr(psar1) i(plans) t(trend) panels(heteroskedastic)\
\
savereg treat1\
savereg treat2\
savereg treat4\
savereg treat5\
savereg treat6\
savereg treat7\
savereg treat8\
savereg treat9\
savereg treat10\
savereg treat11\
\
\
table2a 1 "Dynamic - supp plans - omitted period: -6<t<-4" 1 10 "office visits" "-11<t<-10" "-9<t<-7" "-3<t<-1" "1<t<3" "4<t<6" "7<t<9" "10<t<12" "13<t<15" "16<t<18" "19<t<21"\
\
savereg, clear\
\
}