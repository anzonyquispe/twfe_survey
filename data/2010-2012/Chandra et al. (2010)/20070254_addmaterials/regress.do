{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww16480\viewh16760\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 #delimit;\
clear;\
set mem 6000m;\
set matsize 9500;\
set more 1;\
capture log close;\
log using regress.log, replace;\
\
use ../data/mergeddata;\
compress;\
\
*Indicator for basic plans;\
gen byte basic=plancode==1|plancode==5|plancode==3|plancode==7;\
\
*Calculate age as of 1/1/2000;\
gen byte day=1;\
gen dayofobs=mdy(month,day,year);\
drop day;\
\
egen newdob=min(dob), by(personid);\
gen jan1=mdy(1,1,2000);\
gen daysoflife=dayofobs-newdob;\
gen age=daysoflife/365.25;\
gen age2=age^2;\
*Age as of Jan. 1, 2000;\
gen daysonjan1=jan1-newdob;\
gen agejan1=daysonjan1/365.25;\
drop jan1 daysoflife;\
\
*Medicare hosp payments are imputed from Dartmouth data - Ins payments\
 are imputed from our data.  Cost-sharing is actual person-specific data;\
*For basic plans, we imputed total hosp payments and then subtracted\
 actual cost-sharing to obtain imputed insurance payments;\
gen imputed_totalpay_hosp=imputed_mcare_hosp+imputed_netpay+costshare_hosp if basic==0;\
replace imputed_totalpay_hosp=totalpay_hosp_basic if basic==1;\
replace imputed_netpay=imputed_totalpay_hosp-costshare_hosp if basic==1;\
replace imputed_mcare_hosp=. if basic==1;\
rename imputed_netpay imputed_netpay_hosp;\
drop totalpay_hosp_basic;\
\
*For office visits, Medicare payment is 80% of the total payment and insurance\
payment is 20% of the total payment minus any cost-sharing;\
drop imputed_netpay_office;\
gen imputed_mcare_office=imputed_totalpay_office*.8 if basic==0;\
gen imputed_netpay_office=(imputed_totalpay_office*.2)-costshare_office if basic==0;\
replace imputed_netpay_office=imputed_totalpay_office-costshare_office if basic==1;\
\
compress;\
\
tab year;\
\
save regressiondata, replace;\
exit;\
clear;\
\
\
\
use regressiondata;\
\
/*\
*Create a data set by income category;\
*COMMENT THIS CODE OUT WHEN CREATING THE FULL DATA SET;\
keep year month plancode drugclaim officehmo basic imputed* anyhosp income ;\
\
sort year month plancode basic income;\
collapse (mean) office* anyhosp imputed* (count) obs=drugclaim, by(year month plancode basic income) fast;\
\
gen byte hmo1=plancode==1|plancode==2;\
gen byte hmo2=plancode==3|plancode==4;\
gen byte ppo1=plancode==5|plancode==6;\
gen byte ppo2=plancode==7|plancode==8;\
drop plancode;\
sort year month ppo1 ppo2 hmo1 hmo2 basic;\
save monthlydata_income, replace;\
exit;\
*/\
\
/*\
*Create a data set by chronic condition - supplemental plans;\
*COMMENT THIS CODE OUT WHEN CREATING THE FULL DATA SET;\
keep if basic==0;\
keep year month plancode officehmo basic anyhosp\
     hypertension-gastritis drugclaim imputed_totalpay_hosp imputed_mcare_hosp imputed_netpay_hosp\
     imputed_totalpay_office imputed_netpay_office imputed_mcare_office;\
\
gen byte none=hypertension==0 & hypercholest==0 & asthma==0 & diabetes==0\
    & arthritis==0 & depression==0 & gastritis==0;\
gen byte any=hypertension==1|hypercholest==1|asthma==1|diabetes==1|\
    arthritis==1|depression==1|gastritis==1;\
\
rename imputed_netpay_office imputed_netpay_o;\
rename imputed_mcare_office imputed_mcare_o;\
rename imputed_totalpay_office imputed_totalpay_o;\
\
rename imputed_netpay_hosp imputed_netpay_h;\
rename imputed_mcare_hosp imputed_mcare_h;\
rename imputed_totalpay_hosp imputed_totalpay_h;\
\
foreach x in officehmo anyhosp imputed_totalpay_o imputed_totalpay_h\
        imputed_netpay_o imputed_netpay_h imputed_mcare_o imputed_mcare_h \{;\
gen `x'_hypertension=`x' if hypertension==1;\
gen `x'_hypercholest=`x' if hypercholest==1;\
gen `x'_asthma=`x' if asthma==1;\
gen `x'_diabetes=`x' if diabetes==1;\
gen `x'_arthritis=`x' if arthritis==1;\
gen `x'_depression=`x' if depression==1;\
gen `x'_gastritis=`x' if gastritis==1;\
gen `x'_none=`x' if none==1;\
gen `x'_any=`x' if any==1;\
\};\
\
sort year month plancode;\
collapse (mean) office* anyhosp* imputed*\
         (sum) obs_hypertension=hypertension obs_hypercholest=hypercholest\
         obs_diabetes=diabetes obs_arthritis=arthritis\
         obs_depression=depression obs_gastritis=gastritis obs_asthma=asthma obs_none=none obs_any=any,\
         by(year month plancode) fast;\
\
compress;\
\
gen basic=0;\
gen byte hmo1=plancode==1|plancode==2;\
gen byte hmo2=plancode==3|plancode==4;\
gen byte ppo1=plancode==5|plancode==6;\
gen byte ppo2=plancode==7|plancode==8;\
drop plancode;\
sort year month ppo1 ppo2 hmo1 hmo2 basic;\
save monthlydata_bychronic, replace;\
exit;\
*/\
\
/*\
*Create a data set by Charlson index;\
*COMMENT THIS CODE OUT WHEN CREATING THE FULL DATA SET;\
\
keep year month plancode drugclaim officehmo\
          basic anyhosp imputed_totalpay* imputed_netpay* imputed_mcare* charlson;\
\
gen charlsoncat=0 if charlson==0;\
replace charlsoncat=13 if charlson==1|charlson==2|charlson==3;\
replace charlsoncat=419 if charlson>=4;\
drop charlson;\
\
sort year month plancode basic charlsoncat;\
collapse (mean) drugclaim office* anyhosp imputed* (count) obs=drugclaim, by(year month plancode basic charlsoncat) fast;\
\
gen byte hmo1=plancode==1|plancode==2;\
gen byte hmo2=plancode==3|plancode==4;\
gen byte ppo1=plancode==5|plancode==6;\
gen byte ppo2=plancode==7|plancode==8;\
drop plancode;\
sort year month ppo1 ppo2 hmo1 hmo2 basic;\
save monthlydata_bycharlson, replace;\
exit;\
*/\
\
*Intensive margin for hospitalizations;\
replace dayscount=. if anyhosp==0;\
\
compress;\
\
*Create a data set of means by month and plan;\
keep year month plancode drugclaim officehmo costshare_office\
     dayscount basic anyhosp\
     imputed_totalpay* imputed_mcare* imputed_netpay*;\
compress;\
sort year month plancode basic;\
collapse (mean) drugclaim office* any* dayscount\
          imputed_totalpay* imputed_mcare* imputed_netpay* costshare_office\
          (count) obs=drugclaim, by(year month plancode basic) fast;\
\
gen byte hmo1=plancode==1|plancode==2;\
gen byte hmo2=plancode==3|plancode==4;\
gen byte ppo1=plancode==5|plancode==6;\
gen byte ppo2=plancode==7|plancode==8;\
drop plancode;\
sort year month ppo1 ppo2 hmo1 hmo2 basic;\
save monthlydata, replace;\
exit;\
*/\
\
*Create by-contact means for out-of-pocket cost, by plan and month;\
use ../data/prof_contact.dta;\
keep year month plancode office copay_o deduct_o;\
\
gen oop_o=copay_o+deduct_o;\
\
append using ../data/drugs_contact;\
\
keep year month plancode copay* deduct* oop*;\
rename copay copay_drug;\
rename deduct deduct_drug;\
gen oop_drug=copay_drug+deduct_drug;\
\
gen basic=plancode==1|plancode==5|plancode==3|plancode==7;\
\
sort year month plancode basic;\
collapse (mean) copay* deduct* oop*, by(year month plancode basic);\
\
gen byte hmo1=plancode==1|plancode==2;\
gen byte hmo2=plancode==3|plancode==4;\
gen byte ppo1=plancode==5|plancode==6;\
gen byte ppo2=plancode==7|plancode==8;\
drop plancode;\
\
*Combine by-contact means with mean number of office visits, etc;\
sort year month ppo1 ppo2 hmo1 hmo2 basic;\
merge year month ppo1 ppo2 hmo1 hmo2 basic using monthlydata;\
tab _merge;\
drop _merge;\
save monthlydata, replace;\
}