{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww15940\viewh17500\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 #delimit;\
clear;\
capture log close;\
set mem 6000m;\
set matsize 4000;\
set more 1;\
log using master.log, replace;\
\
/*\
*****************************;\
* ORIGINAL ELIGIBILITY DATA *;\
* which we will only use for*;\
* 2000                      *;\
*****************************;\
\
foreach x in 1 2 3 4 \{;\
use ../rawdata/eligibility_part`x'.dta;\
\
rename col1 personid;\
rename col2 sex;\
rename col3 dob;\
rename col4 startdate;\
rename col5 enddate;\
rename col6 effectivestart;\
rename col7 plan;\
rename col8 plancode;\
\
count;\
\
gen month=month(startdate);\
gen year=year(startdate);\
drop if year==1999|year==2004;\
\
*Drop last quarter of 2003 (b/c claims aren't complete);\
drop if year==2003 & month>=10;\
\
drop startdate enddate plan effectivestart;\
\
gen str1 sex2="M" if sex=="Male";\
replace sex2="F" if sex=="Female";\
drop sex;\
rename sex2 sex;\
\
count;\
\
compress;\
desc;\
save ../data/elig`x'.dta, replace;\
clear;\
\};\
\
\
use ../data/elig1.dta;\
append using ../data/elig2.dta;\
append using ../data/elig3.dta;\
append using ../data/elig4.dta;\
count;\
\
keep if year==2000;\
\
save ../data/elig2000, replace;\
\
clear;\
exit;\
*/\
/*\
*************************;\
* NEW ELIGIBILITY DATA  *;\
* doesn't include 2000  *;\
*************************;\
\
foreach x in 1 2 3 \{;\
use ../rawdata/elig_new`x'.dta;\
\
rename col1 personid;\
rename col2 sex;\
rename col3 dob;\
rename col4 startdate;\
rename col5 enddate;\
rename col6 plan;\
rename col7 plancode;\
\
count;\
\
gen month=month(startdate);\
gen year=year(startdate);\
drop if year==1999|year==2004;\
\
tab year month;\
\
*Drop last quarter of 2003 (b/c claims aren't complete);\
drop if year==2003 & month>=10;\
\
drop startdate enddate plan;\
\
gen str1 sex2="M" if sex=="Male";\
replace sex2="F" if sex=="Female";\
drop sex;\
rename sex2 sex;\
\
count;\
\
compress;\
desc;\
save ../data/elig_new`x'.dta, replace;\
clear;\
\};\
*/\
/*\
use ../data/elig_new1.dta;\
append using ../data/elig_new2.dta;\
append using ../data/elig_new3.dta;\
append using ../data/elig2000.dta;\
count;\
\
*There are a few duplicated observations;\
sort personid dob plancode year month;\
gen flag=personid==personid[_n+1] & dob==dob[_n+1] & plancode==plancode[_n+1]\
         & year==year[_n+1] & month==month[_n+1];\
drop if flag==1;\
drop flag;\
\
*Drop people who have gaps in enrollment;\
sort personid plancode year month;\
gen byte flag = personid==personid[_n+1] & plancode==plancode[_n+1]\
         & year==year[_n+1] & month[_n+1]-month >1;\
replace flag = 1 if personid==personid[_n+1] & plancode==plancode[_n+1]\
         & year[_n+1]-year>=1 & (month[_n+1]~=1|month~=12);\
\
*But don't want to drop people with gaps at Dec. 2000, because\
 we think this is a data error;\
gen byte dec2000 = personid==personid[_n+1] & plancode==plancode[_n+1] & year==2000 & month==11\
         & year[_n+1]==2001 & month[_n+1]==1;\
\
tab flag dec2000;\
drop if flag==1 & dec2000==0;\
drop flag;\
count;\
\
*Flag repeated observations;\
gen byte flag=personid==personid[_n+1] & year==year[_n+1] & month==month[_n+1];\
tab flag;\
drop if flag==1;\
drop flag;\
count;\
\
*Identify the number of months of any enrollment;\
sort personid;\
egen int anymonths=count(month), by(personid);\
tab anymonths;\
\
*Identify the number of months of unique enrollment;\
sort personid plancode;\
egen int nummonths=count(month), by(personid plancode);\
tab nummonths;\
\
*Only keep people who MAY have been continuously enrolled in one plan\
 for the entire period from 1/2000 to 9/2003 (allowing for the\
 exception of Dec. 2000 because we think this data is messed up);\
keep if (anymonths>=44 & nummonths>=44);\
compress;\
\
*Generate a person-level indicator for all person-months that are affected\
 by the Dec. 2000 problem;\
sort personid;\
egen persondec2000=max(dec2000), by(personid);\
replace dec2000=persondec2000;\
drop persondec2000;\
\
*Only keep people who were continuously enrolled in one plan\
 for the entire period from 1/2000 to 9/2003 (allowing for the\
 exception of Dec. 2000 because we think this data is messed up);\
keep if (anymonths==45 & nummonths==45)|(anymonths==44 & nummonths==44 & dec2000==1);\
drop anymonths nummonths;\
\
*Generate an observation for Dec. 2000 for those that are\
 currently missing an observation;\
expand 2 if dec2000==1 & year==2000 & month==11;\
sort personid year month;\
replace month=12 if year==2000 & month==11 & year[_n-1]==2000 & month[_n-1]==11 & dec2000==1;\
\
compress;\
desc;\
\
sort personid year month;\
save ../data/elig.dta, replace;\
exit;\
*/\
\
/*\
****************;\
* FAC DTL DATA *;\
****************;\
\
foreach x in 1 2 3 \{;\
use ../rawdata/dtl_part`x'.dta;\
\
rename col1 personid;\
rename col2 relation;\
rename col3 sex;\
rename col4 dob;\
rename col5 plancode;\
rename col6 location;\
rename col7 recordid;\
rename col8 linenbr;\
rename col9 claimid;\
rename col10 incdate;\
rename col11 provtype;\
rename col12 dxdx;\
rename col13 dxcode;\
rename col14 dxcode2;\
rename col15 dxcode3;\
rename col16 provplace;\
rename col17 proc;\
rename col18 proccode;\
rename col19 network;\
rename col20 charge;\
rename col21 provloc;\
rename col22 plan;\
rename col23 revcode;\
\
keep personid relation sex dob plancode recordid claimid linenbr\
     incdate charge proc proccode dxcode dxcode2 dxcode3 provplace;\
compress;\
\
sort personid relation sex dob plancode recordid claimid incdate;\
\
save ../data/dtl`x'.dta, replace;\
clear;\
\};\
exit;\
*/\
\
/*\
use ../data/dtl1.dta;\
append using ../data/dtl2.dta;\
append using ../data/dtl3.dta;\
\
sort personid relation sex dob plancode claimid incdate;\
collapse (sum) charge, by(personid relation sex dob plancode claimid incdate) fast;\
\
*Collapse by incurred date;\
*We will save a version at this point to merge to the outpatient/asc claims,\
 for computing outpatient/office visits charges in chargeimpute.do;\
sort personid plancode incdate;\
collapse (sum) charge, by(personid plancode incdate) fast;\
save ../data/dtl_outpatient;\
\
*Generate month & year variables;\
gen month=month(incdate);\
gen year=year(incdate);\
\
*Collapse to person, month, year level;\
count;\
sort personid plancode month year;\
collapse (sum) charge,\
          by(personid plancode month year) fast;\
\
save ../data/dtl.dta, replace;\
exit;\
*/\
\
/*\
****************;\
* FAC HDR DATA *;\
****************;\
\
foreach x in 1 2 3 \{;\
use ../rawdata/fac_part`x'.dta;\
\
rename col1 personid;\
rename col2 relation;\
rename col3 sex;\
rename col4 dob;\
rename col5 plancode;\
rename col6 location;\
rename col7 recordid;\
rename col8 claimid;\
rename col9 incdate;\
rename col10 provtype;\
rename col11 dayscount;\
rename col12 dxdx;\
rename col13 dxcode;\
rename col14 dxcode2;\
rename col15 dxcode3;\
rename col16 provplace;\
rename col17 network;\
rename col18 deduct;\
rename col19 coins;\
rename col20 copay;\
rename col21 netpay;\
rename col22 provloc;\
rename col23 plan;\
rename col24 lastdate;\
\
keep personid relation sex dob plancode recordid claimid incdate\
     lastdate deduct coins copay netpay provtype provplace dayscount dx*;\
compress;\
\
*Merge CCS diagnosis codes;\
*Only ~0.16% seem to have invalid icd9s;\
sort dxcode;\
merge dxcode using ../data/ccscodes;\
tab _merge;\
drop if _merge==2;\
drop _merge;\
\
*Identify Charlson comorbidity index codes;\
icd9 check dxcode, generate(problem);\
replace dxcode="" if problem>0;\
\
icd9 gen mi=dxcode, range(410* 412*);\
icd9 gen chf=dxcode, range(428* 40201 40211 40291 425* 4293);\
icd9 gen pvd=dxcode, range(441* 4439* 7854* v434* 440* 442* 443* 4471* 7854*);\
icd9 gen cvd=dxcode, range(430/437 438* 36234 7814 7843 9970 4379);\
icd9 gen dementia=dxcode, range(290* 331/3312);\
icd9 gen copd=dxcode, range(490/496 500/505 5064 4150* 4168/4169);\
icd9 gen rheum=dxcode, range(7100/7101 7104* 7140/7142 71481* 725*);\
icd9 gen ulcer=dxcode, range(531/53499);\
icd9 gen livermild=dxcode, range(5712* 5714* 5715* 5716* 5718/5719);\
icd9 gen diabetesmild=dxcode, range(250/25033 2507*);\
icd9 gen plegia=dxcode, range(342* 344*);\
icd9 gen renal=dxcode, range(582* 583/5837 585* 586* 588* V420* V451* V56*);\
icd9 gen diabetescomp=dxcode, range(2504/25099);\
icd9 gen malig=dxcode, range(140/1729 174/1958 200/20891 2730* 2733* V1046*);\
icd9 gen liversev=dxcode, range(5722/58289 4560/45629);\
icd9 gen tumor=dxcode, range(196/1991);\
icd9 gen aids=dxcode, range(042/044);\
\
icd9 check dxcode2, generate(problem2);\
replace dxcode2="" if problem2>0;\
\
icd9 gen mi2=dxcode2, range(410* 412*);\
icd9 gen chf2=dxcode2, range(428* 40201 40211 40291 425* 4293);\
icd9 gen pvd2=dxcode2, range(441* 4439* 7854* v434* 440* 442* 443* 4471* 7854*);\
icd9 gen cvd2=dxcode2, range(430/437 438* 36234 7814 7843 9970 4379);\
icd9 gen dementia2=dxcode2, range(290* 331/3312);\
icd9 gen copd2=dxcode2, range(490/496 500/505 5064 4150* 4168/4169);\
icd9 gen rheum2=dxcode2, range(7100/7101 7104* 7140/7142 71481* 725*);\
icd9 gen ulcer2=dxcode2, range(531/53499);\
icd9 gen livermild2=dxcode2, range(5712* 5714* 5715* 5716* 5718/5719);\
icd9 gen diabetesmild2=dxcode2, range(250/25033 2507*);\
icd9 gen plegia2=dxcode2, range(342* 344*);\
icd9 gen renal2=dxcode2, range(582* 583/5837 585* 586* 588* V420* V451* V56*);\
icd9 gen diabetescomp2=dxcode2, range(2504/25099);\
icd9 gen malig2=dxcode2, range(140/1729 174/1958 200/20891 2730* 2733* V1046*);\
icd9 gen liversev2=dxcode2, range(5722/58289 4560/45629);\
icd9 gen tumor2=dxcode2, range(196/1991);\
icd9 gen aids2=dxcode2, range(042/044);\
\
icd9 check dxcode3, generate(problem3);\
replace dxcode3="" if problem3>0;\
\
icd9 gen mi3=dxcode3, range(410* 412*);\
icd9 gen chf3=dxcode3, range(428* 40201 40211 40291 425* 4293);\
icd9 gen pvd3=dxcode3, range(441* 4439* 7854* v434* 440* 442* 443* 4471* 7854*);\
icd9 gen cvd3=dxcode3, range(430/437 438* 36234 7814 7843 9970 4379);\
icd9 gen dementia3=dxcode3, range(290* 331/3312);\
icd9 gen copd3=dxcode3, range(490/496 500/505 5064 4150* 4168/4169);\
icd9 gen rheum3=dxcode3, range(7100/7101 7104* 7140/7142 71481* 725*);\
icd9 gen ulcer3=dxcode3, range(531/53499);\
icd9 gen livermild3=dxcode3, range(5712* 5714* 5715* 5716* 5718/5719);\
icd9 gen diabetesmild3=dxcode3, range(250/25033 2507*);\
icd9 gen plegia3=dxcode3, range(342* 344*);\
icd9 gen renal3=dxcode3, range(582* 583/5837 585* 586* 588* V420* V451* V56*);\
icd9 gen diabetescomp3=dxcode3, range(2504/25099);\
icd9 gen malig3=dxcode3, range(140/1729 174/1958 200/20891 2730* 2733* V1046*);\
icd9 gen liversev3=dxcode3, range(5722/58289 4560/45629);\
icd9 gen tumor3=dxcode3, range(196/1991);\
icd9 gen aids3=dxcode3, range(042/044);\
\
replace mi=max(mi, mi2, mi3);\
replace chf=max(chf, chf2, chf3);\
replace pvd=max(pvd, pvd2, pvd3);\
replace cvd=max(cvd, cvd2, cvd3);\
replace dementia=max(dementia, dementia2, dementia3);\
replace copd=max(copd, copd2, copd3);\
replace rheum=max(rheum, rheum2, rheum3);\
replace ulcer=max(ulcer, ulcer2, ulcer3);\
replace livermild=max(livermild, livermild2, livermild3);\
replace diabetesmild=max(diabetesmild, diabetesmild2, diabetesmild3);\
replace plegia=max(plegia, plegia2, plegia3);\
replace renal=max(renal, renal2, renal3);\
replace diabetescomp=max(diabetescomp, diabetescomp2, diabetescomp3);\
replace malig=max(malig, malig2, malig3);\
replace liversev=max(liversev, liversev2, liversev3);\
replace tumor=max(tumor, tumor2, tumor3);\
replace aids=max(aids, aids2, aids3);\
\
drop mi2 mi3 chf2 chf3 pvd2 pvd3 cvd2 cvd3 dementia2 dementia3 copd2 copd3\
     rheum2 rheum3 ulcer2 ulcer3 livermild2 livermild3 diabetesmild2 diabetesmild3\
     plegia2 plegia3 renal2 renal3 diabetescomp2 diabetescomp3 malig2 malig3\
     liversev2 liversev3 tumor2 tumor3 aids2 aids3;\
\
*Copay will include copayment & coinsurance;\
replace copay=copay+coins;\
drop coins;\
\
*Generate indicators for ER & inpatient claims;\
gen byte er=provplace=="Emergency Room - Hospital";\
gen byte inpatient=provplace=="Inpatient Hospital";\
gen byte outpatient=provplace=="Outpatient Hospital"|provplace=="Outpatient, NOS";\
gen byte asc=provplace=="Ambulatory Surgical Center";\
gen byte birthing=provplace=="Birthing Center";\
gen byte snf=provplace=="Skilled Nursing Facility";\
\
*If inpatient diagnosis is for "laboratory examinations", recode as NOT inpatient stay;\
tab inpatient plancode if dxdx=="Laboratory Examination";\
replace inpatient=0 if dxdx=="Laboratory Examination";\
replace outpatient=1 if dxdx=="Laboratory Examination";\
drop if dxdx=="Laboratory Examination" & inpatient==1;\
\
*Need a separate measure of days in a SNF and days in a hospital;\
gen dayscount_snf=dayscount if snf==1;\
replace dayscount_snf=0 if snf==0;\
replace dayscount=0 if snf==1;\
\
*Collapse to claim level;\
count;\
keep deduct* copay* netpay dayscount* er inpatient outpatient asc birthing snf\
     mi-aids claimid personid plancode incdate;\
sort claimid personid plancode incdate;\
collapse (sum) deduct* copay* netpay (max) dayscount* er inpatient outpatient asc\
          birthing snf mi-aids,\
          by(claimid personid plancode incdate);\
count;\
\
*Collapse by person/incurred date;\
count;\
sort personid plancode incdate;\
collapse (sum) deduct* copay* netpay (max) dayscount* er inpatient outpatient asc\
          birthing snf mi-aids,\
          by(personid plancode incdate);\
tab plancode;\
count;\
\
*Don't count outpatient visit if appears to be inpatient;\
replace outpatient=0 if dayscount>0;\
replace asc=0 if dayscount>0;\
\
save ../data/fac`x'.dta, replace;\
clear;\
\};\
exit;\
*/\
\
/*\
use ../data/fac1;\
append using ../data/fac2;\
append using ../data/fac3;\
\
*Collapse by person/incurred date again;\
count;\
sort personid plancode incdate;\
collapse (sum) deduct* copay* netpay (max) dayscount* er inpatient outpatient asc\
          birthing snf mi-aids,\
          by(personid plancode incdate);\
tab plancode;\
count;\
\
/*\
*Save a version that can be merged onto professional data;\
*COMMENT OUT THIS CODE DURING ORDINARY RUNS;\
keep if outpatient==1|asc==1;\
keep personid plancode incdate outpatient asc copay deduct dayscount;\
\
sort personid plancode incdate;\
merge personid plancode incdate using ../data/dtl_outpatient.dta;\
tab _merge;\
keep if _merge==3;\
drop _merge;\
keep personid plancode incdate outpatient asc charge copay deduct;\
\
sort personid plancode incdate;\
save ../data/outfac.dta, replace;\
exit;\
*/\
\
*Generate month & year variables;\
gen month=month(incdate);\
gen year=year(incdate);\
\
drop if year<2000;\
\
*Code to assign hospital days to month when actually IN hospital;\
replace dayscount=0 if inpatient==0 & birthing==0;\
drop if dayscount<0;\
\
foreach x in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 \{;\
capture drop lastdayofmonth incday;\
capture replace dayscount=remaining;\
\
gen byte lastdayofmonth=31 if month==1|month==3|month==5|month==7|\
                              month==8|month==10|month==12;\
replace lastdayofmonth=30 if month==4|month==6|month==9|month==11;\
replace lastdayofmonth=28 if month==2;\
replace lastdayofmonth=29 if month==2 & year==2000;\
gen byte incday=day(incdate);\
replace incday=1 if `x'>0;\
\
capture gen byte inhospital=.;\
capture gen flag=1;\
replace inhospital=(lastdayofmonth-incday)+1 if (lastdayofmonth-incday)+1<dayscount & flag==1;\
replace inhospital=dayscount if (lastdayofmonth-incday)+1>=dayscount & flag==1;\
capture drop flag;\
gen flag=inhospital<dayscount;\
tab flag;\
expand 2 if flag==1;\
bysort personid plancode incdate year month: replace flag=0 if _n~=_N;\
capture gen remaining=0;\
replace remaining=0;\
replace remaining=dayscount-inhospital if flag==1;\
replace month=month+1 if flag==1;\
replace year=year+1 if month==13 & flag==1;\
replace month=1 if month==13 & flag==1;\
replace outpatient=0 if flag==1;\
replace er=0 if flag==1;\
replace asc=0 if flag==1;\
replace birthing=0 if flag==1;\
replace snf=0 if flag==1;\
replace dayscount_snf=0 if flag==1;\
replace netpay=0 if flag==1;\
\};\
\
replace dayscount=inhospital;\
drop inhospital;\
\
*Fix duplicates that lead to more hospital days than days in the month;\
*Code that gets rid of duplicate hospital days;\
capture drop incday;\
gen incday=day(incdate);\
replace incday=1 if month~=month(incdate);\
sort personid year month incday dayscount;\
gen diff=incday[_n+1]-incday if personid==personid[_n+1] & month==month[_n+1] & year==year[_n+1];\
replace diff=0 if diff==.;\
gen newdayscount=dayscount;\
replace newdayscount=diff if dayscount>diff & incday+dayscount<incday[_n+1]+dayscount[_n+1]\
                 & personid==personid[_n+1] & month==month[_n+1] & year==year[_n+1];\
replace newdayscount=0 if incday[_n-1]+dayscount[_n-1]>=incday+dayscount\
                 & personid==personid[_n-1] & month==month[_n-1] & year==year[_n-1];\
replace newdayscount=0 if incday[_n-2]+dayscount[_n-2]>=incday+dayscount\
                 & personid==personid[_n-2] & month==month[_n-2] & year==year[_n-2];\
replace newdayscount=0 if incday[_n-3]+dayscount[_n-3]>=incday+dayscount\
                 & personid==personid[_n-3] & month==month[_n-3] & year==year[_n-3];\
replace newdayscount=0 if incday[_n-4]+dayscount[_n-4]>=incday+dayscount\
                 & personid==personid[_n-4] & month==month[_n-4] & year==year[_n-4];\
replace newdayscount=0 if incday[_n-5]+dayscount[_n-5]>=incday+dayscount\
                 & personid==personid[_n-5] & month==month[_n-5] & year==year[_n-5];\
replace newdayscount=0 if incday[_n-6]+dayscount[_n-6]>=incday+dayscount\
                 & personid==personid[_n-6] & month==month[_n-6] & year==year[_n-6];\
replace newdayscount=0 if incday[_n-7]+dayscount[_n-7]>=incday+dayscount\
                 & personid==personid[_n-7] & month==month[_n-7] & year==year[_n-7];\
replace newdayscount=0 if incday[_n-8]+dayscount[_n-8]>=incday+dayscount\
                 & personid==personid[_n-8] & month==month[_n-8] & year==year[_n-8];\
replace newdayscount=0 if incday[_n-9]+dayscount[_n-9]>=incday+dayscount\
                 & personid==personid[_n-9] & month==month[_n-9] & year==year[_n-9];\
replace newdayscount=0 if incday==incday[_n+1] & incday+dayscount<incday[_n+1]+dayscount[_n+1]\
                 & personid==personid[_n+1] & month==month[_n+1] & year==year[_n+1];\
\
summ dayscount, detail;\
summ newdayscount, detail;\
summ dayscount if dayscount>0, detail;\
summ newdayscount if newdayscount>0, detail;\
\
drop dayscount;\
rename newdayscount dayscount;\
\
sort personid incdate year month;\
*Collapse to person, month, year level;\
count;\
sort personid plancode month year;\
collapse (sum) deduct* copay* netpay dayscount* er inpatient outpatient\
               birthing\
         (max) snf mi-aids,\
          by(personid plancode month year);\
count;\
\
*Top code hospital days;\
capture drop lastdayofmonth;\
capture drop flag;\
gen byte lastdayofmonth=31 if month==1|month==3|month==5|month==7|\
                              month==8|month==10|month==12;\
replace lastdayofmonth=30 if month==4|month==6|month==9|month==11;\
replace lastdayofmonth=28 if month==2;\
replace lastdayofmonth=29 if month==2 & year==2000;\
\
replace dayscount=lastdayofmonth if dayscount>lastdayofmonth & dayscount~=.;\
\
*Any hospitalizations;\
gen byte anyhosp=dayscount>0|(inpatient>0 & dayscount==0)|(birthing>0 & dayscount==0);\
\
sort personid plancode month year;\
merge personid plancode month year using ../data/dtl.dta;\
*There will be more observations in master than using data\
set, due to the code above to assign hospital days to the\
month in which they actually occur;\
tab _merge;\
drop _merge;\
\
drop if year<2000;\
drop if year==2003 & month>=10;\
\
*Merge on imputed (supp) insurance charges for hospitalizations during\
the month.  We no longer use the imputed "charges" because these were\
inflated.  The netpay data are calculated based on plans #6 & #8 in \
chargeimpute.do.  The Medicare dta are from Dartmouth.  The costsharing \
is actual person-specific cost-sharing, calculated in chargeimpute.do.  The \
cost-sharing measure is valid for basic and supp plans, since it is actual, \
not imputed;\
\
sort personid year month;\
merge personid year month using ../data/fac_chargeimpute.dta;\
bysort anyhosp: tab _merge;\
replace imputed_netpay=0 if anyhosp==0;\
replace imputed_mcare_hosp=0 if anyhosp==0;\
replace costshare_hosp=0 if anyhosp==0;\
*Some hosp claims have missing diagnosis, so we assign the average\
 cost of any hospitalization to them.  This was also calculated in\
 chargeimpute.do;\
*Some of these may be birthing centers, which are excluded from the\
 imputed charges - they are also irrelevant for the elderly!;\
replace imputed_netpay=1334.59 if anyhosp==1 & _merge==1;\
replace imputed_mcare_hosp=7551.99 if anyhosp==1 & _merge==1;\
replace costshare_hosp=. if anyhosp==1 & _merge==1;\
drop _merge;\
\
capture drop mi-aids outpatient birthing inpatient lastdayofmonth;\
\
compress;\
\
sort personid year month;\
\
save ../data/fac, replace;\
exit;\
*/\
\
\
/*\
*************;\
* PROF DATA *;\
*************;\
\
foreach x in  1 2 3 4  5 6 7  8 9  10 11 12 13 14  \{;\
use ../rawdata/prof_part`x'.dta;\
\
*We double-extracted one observation in part4/5 - delete the\
 extra extraction;\
drop in 1 if `x'==5;\
\
rename col1 personid;\
rename col2 relation;\
rename col3 sex;\
rename col4 dob;\
rename col5 plancode;\
rename col6 location;\
rename col7 recordid;\
rename col8 linenum;\
rename col9 claimid;\
rename col10 incdate;\
rename col11 provtype;\
rename col12 dxdx;\
rename col13 dxcode;\
rename col14 provplace;\
rename col15 proc;\
rename col16 proccode;\
rename col17 network;\
rename col18 charge;\
rename col19 deduct;\
rename col20 coins;\
rename col21 copay;\
rename col22 netpay;\
rename col23 provloc;\
rename col24 plan;\
rename col25 revcode;\
rename col26 lastdate;\
\
gen office=provplace=="Office";\
\
*Another office visit measure (modified to include professional-based outpatient claims below);\
gen officehmo=office==1;\
gen out=provplace=="Outpatient, NOS"|provplace=="Outpatient Hospital";\
\
*In some cases, ER visits are reported in professional data - in others,\
 they are reported in facility data;\
gen byte er=provplace=="Emergency Room - Hospital";\
gen byte er2=provtype=="Emergency Medicine"|er==1;\
replace officehmo=0 if er2==1;\
replace out=0 if er2==1;\
drop er;\
\
*Merge on CCS diagnosis codes and then measure a few chronic conditions;\
sort dxcode;\
merge dxcode using ../data/ccscodes.dta;\
tab _merge;\
drop if _merge==2;\
\
*Convert to numeric format;\
gen realccs=real(ccscode);\
drop ccscode;\
rename realccs ccscode;\
\
*Hypertension;\
gen byte hypertension=ccscode==98|ccscode==99;\
\
*Hypercholesterolemia;\
gen byte hypercholest=ccscode==53;\
\
*Asthma;\
gen byte asthma=ccscode==128;\
\
*Diabetes;\
gen byte diabetes=ccscode==49|ccscode==50;\
\
*Arthritis;\
gen byte arthritis=ccscode==203;\
\
*Depression, etc;\
gen byte depression= ccscode==69;\
\
*Gastritis, etc;\
gen byte gastritis=ccscode==138|ccscode==139|ccscode==140;\
\
summ hypertension-gastritis;\
\
*Identify Charlson comorbidity index codes;\
icd9 check dxcode, generate(problem);\
replace dxcode="" if problem>0;\
\
icd9 gen mi=dxcode, range(410* 412*);\
icd9 gen chf=dxcode, range(428* 40201 40211 40291 425* 4293);\
icd9 gen pvd=dxcode, range(441* 4439* 7854* v434* 440* 442* 443* 4471* 7854*);\
icd9 gen cvd=dxcode, range(430/437 438* 36234 7814 7843 9970 4379);\
icd9 gen dementia=dxcode, range(290* 331/3312);\
icd9 gen copd=dxcode, range(490/496 500/505 5064 4150* 4168/4169);\
icd9 gen rheum=dxcode, range(7100/7101 7104* 7140/7142 71481* 725*);\
icd9 gen ulcer=dxcode, range(531/53499);\
icd9 gen livermild=dxcode, range(5712* 5714* 5715* 5716* 5718/5719);\
icd9 gen diabetesmild=dxcode, range(250/25033 2507*);\
icd9 gen plegia=dxcode, range(342* 344*);\
icd9 gen renal=dxcode, range(582* 583/5837 585* 586* 588* V420* V451* V56*);\
icd9 gen diabetescomp=dxcode, range(2504/25099);\
icd9 gen malig=dxcode, range(140/1729 174/1958 200/20891 2730* 2733* V1046*);\
icd9 gen liversev=dxcode, range(5722/58289 4560/45629);\
icd9 gen tumor=dxcode, range(196/1991);\
icd9 gen aids=dxcode, range(042/044);\
compress;\
\
keep personid relation sex dob plancode recordid claimid incdate office\
     charge deduct coins copay netpay lastdate provplace provtype dxdx\
     officehmo out er* hypertension-gastritis mi-aids;\
compress;\
\
*Drop certain claims that are not consistently reported in plancode 3/4;\
drop if (provtype=="Psychiatry"|provtype=="Psychologist"|provtype=="Therapists (Supportive)")\
         & (plancode==3|plancode==4);\
\
*Drop certain claims that are problematic in plan #2;\
drop if provtype=="Hearing Labs"|provtype=="Health Educator/Agency" & (plancode==1|plancode==2);\
\
*Create measure of office visit cost-sharing;\
gen costshare_office=copay+coins+deduct;\
replace costshare_office=0 if officehmo==0;\
gen costshare_out=copay+coins+deduct;\
replace costshare_out=0 if out==0;\
\
*Collapse to claim level - allowing for fact that incdate is\
 sometimes different within claims;\
count;\
sort claimid personid incdate plancode;\
collapse (sum) charge deduct coins copay costshare_office costshare_out netpay\
         (max) office officehmo out er* hypertension-gastritis mi-aids,\
         by(claimid personid incdate plancode);\
count;\
\
gen year=year(incdate);\
gen month=month(incdate);\
\
drop if year<=1999;\
drop if year==2003 & month>=10;\
drop year month;\
\
count;\
compress;\
save ../data/prof`x'.dta, replace;\
desc;\
clear;\
\};\
exit;\
*/\
\
\
use ../data/prof1.dta;\
append using ../data/prof2.dta;\
append using ../data/prof3.dta;\
append using ../data/prof4.dta;\
append using ../data/prof5.dta;\
append using ../data/prof6.dta;\
append using ../data/prof7.dta;\
append using ../data/prof8.dta;\
append using ../data/prof9.dta;\
append using ../data/prof10.dta;\
append using ../data/prof11.dta;\
append using ../data/prof12.dta;\
append using ../data/prof13.dta;\
append using ../data/prof14.dta;\
\
*Copay will include coinsurance;\
replace copay=copay+coins;\
drop coins mi-aids netpay;\
compress;\
\
count;\
*Collapse to claim level (again);\
sort claimid personid incdate plancode;\
collapse (sum) charge deduct copay costshare_office costshare_out\
         (max) office* out er* hypertension-gastritis,\
          by(claimid personid incdate plancode) fast;\
count;\
\
*Drop claims with zero charges;\
drop if charge==0;\
compress;\
\
drop claimid;\
save ../data/temp, replace;\
exit;\
clear;\
*/\
/*\
use ../data/temp;\
\
*Only allow one ER visit per day;\
sort personid plancode incdate;\
collapse (sum) charge deduct copay costshare_office costshare_out\
         (max) er* hypertension-gastritis officehmo office out,\
         by(personid plancode incdate) fast;\
\
*Now want to merge on outpatient hospital & ambulatory surgical\
 center claims;\
rename charge charge_prof;\
rename copay copay_prof;\
rename deduct deduct_prof;\
sort personid plancode incdate;\
merge personid plancode incdate using ../data/outfac.dta;\
tab _merge;\
\
gen byte outhosp=outpatient==1|asc==1;\
tab outhosp _merge;\
replace out=0 if _merge==2;\
drop outpatient asc;\
*Want outhosp and out to be mutually exclusive i.e. either it\
is an outpatient visit with a facility claim or it isn't;\
replace out=0 if outhosp==1;\
replace costshare_out=0 if outhosp==1;\
tab out outhosp;\
\
*We will recode office visits to include professional-based\
 outpatient claims;\
replace officehmo=max(officehmo, out);\
replace costshare_office=costshare_office+costshare_out;\
drop office out costshare_out;\
\
replace charge=0 if _merge==1;\
replace charge_prof=0 if _merge==2;\
gen newcharge=charge+charge_prof;\
drop charge charge_prof;\
rename newcharge charge;\
\
replace copay=0 if _merge==1;\
replace copay_prof=0 if _merge==2;\
gen newcopay=copay+copay_prof;\
drop copay copay_prof;\
rename newcopay copay;\
\
replace deduct=0 if _merge==1;\
replace deduct_prof=0 if _merge==2;\
gen newdeduct=deduct+deduct_prof;\
drop deduct deduct_prof;\
rename newdeduct deduct;\
\
save ../data/temp, replace;\
exit;\
clear;\
*/\
\
/*\
use ../data/temp;\
\
*Keep new observations of outpatient visits from facility claims;\
*Set everything else to zero for these obs;\
replace costshare_office=0 if _merge==2;\
replace officehmo=0 if _merge==2;\
replace hypertension=0 if _merge==2;\
replace hypercholest=0 if _merge==2;\
replace asthma=0 if _merge==2;\
replace diabetes=0 if _merge==2;\
replace arthritis=0 if _merge==2;\
replace depression=0 if _merge==2;\
replace gastritis=0 if _merge==2;\
replace er2=0 if _merge==2;\
drop _merge;\
\
*Collapse again, so that there is no more than 1 office visit per day;\
sort personid plancode incdate;\
collapse (sum) charge deduct copay costshare_office\
         (max) er* hypertension-gastritis officehmo outhosp,\
         by(personid plancode incdate) fast;\
\
*Generate year & month variables;\
gen year=year(incdate);\
gen month=month(incdate);\
\
*Collapse to person, month, year level;\
count;\
compress;\
sort personid month year;\
collapse (sum) charge deduct copay costshare_office office* outhosp er*\
         (max) hypertension-gastritis,\
          by(personid month year) fast;\
count;\
save ../data/temp, replace;\
exit;\
\
clear;\
*/\
\
use ../data/temp;\
\
*Merge on imputed office charges;\
sort personid year month;\
merge personid year month using ../data/prof_chargeimpute.dta;\
tab _merge;\
drop if _merge==2;\
count if _merge==1 & officehmo>0;\
*Impute average value for observations with missing CCS codes;\
replace imputed_netpay_office=officehmo*30.99 if _merge==1;\
replace imputed_totalpay_office=officehmo*119.64 if _merge==1;\
drop _merge;\
\
compress;\
sort personid year month;\
save ../data/prof.dta, replace;\
exit;\
*/\
\
\
***************************;\
* MERGE DATASETS TOGETHER *;\
***************************;\
/*\
use ../data/elig;\
\
*A few members seemed to be assigned to the wrong plan (basic vs. supplemental) in the enrollment file, based on their age and copays paid.  Fix those here;\
sort personid;\
merge personid using ../data/wrongplans.dta;\
tab _merge;\
drop _merge;\
\
gen newplancode=plancode;\
replace newplancode=2 if plancode==1 & changeperson==1;\
replace newplancode=1 if plancode==2 & changeperson==1;\
replace newplancode=4 if plancode==3 & changeperson==1;\
replace newplancode=3 if plancode==4 & changeperson==1;\
replace newplancode=6 if plancode==5 & changeperson==1;\
replace newplancode=5 if plancode==6 & changeperson==1;\
replace newplancode=8 if plancode==7 & changeperson==1;\
replace newplancode=7 if plancode==8 & changeperson==1;\
gen byte changed=newplancode~=plancode;\
tab changed;\
bysort plancode: tab changed;\
drop plancode;\
rename newplancode plancode;\
compress;\
\
*Age as of Jan. 1, 2000;\
egen newdob=min(dob), by(personid);\
gen jan1=mdy(1,1,2000);\
gen daysonjan1=jan1-newdob;\
gen agejan1=daysonjan1/365.25;\
\
gen agegroup=18 if agejan1<19;\
replace agegroup=1929 if agejan1>=19 & agejan1<30;\
replace agegroup=3039 if agejan1>=30 & agejan1<40;\
replace agegroup=4049 if agejan1>=40 & agejan1<50;\
replace agegroup=5064 if agejan1>=50 & agejan1<65;\
replace agegroup=6574 if agejan1>=65 & agejan1<75;\
replace agegroup=7584 if agejan1>=75 & agejan1<85;\
replace agegroup=8599 if agejan1>=85;\
tab agegroup, missing;\
drop newdob jan1 daysonjan1 agejan1;\
compress;\
sort personid year month;\
save ../data/elig_recoded.dta, replace;\
*/\
/*\
use ../data/elig_recoded.dta;\
drop dec2000 changeperson changed;\
sort personid year month;\
merge personid year month using ../data/prof.dta;\
tab year;\
tab _merge;\
drop if _merge==2;\
replace charge=0 if _merge==1;\
replace deduct=0 if _merge==1;\
replace copay=0 if _merge==1;\
replace officehmo=0 if _merge==1;\
replace outhosp=0 if _merge==1;\
replace er=0 if _merge==1;\
replace hypertension=0 if _merge==1;\
replace hypercholest=0 if _merge==1;\
replace asthma=0 if _merge==1;\
replace diabetes=0 if _merge==1;\
replace arthritis=0 if _merge==1;\
replace depression=0 if _merge==1;\
replace gastritis=0 if _merge==1;\
replace imputed_netpay_office=0 if _merge==1;\
replace imputed_totalpay_office=0 if _merge==1;\
replace costshare_office=0 if _merge==1;\
drop _merge;\
\
rename charge charge_prof;\
rename deduct deduct_prof;\
rename copay copay_prof;\
rename er er_prof;\
\
sort personid year month;\
merge personid year month using ../data/fac.dta;\
capture drop mi-aids outpatient birthing inpatient;\
tab year;\
tab _merge;\
drop if _merge==2;\
replace charge=0 if _merge==1;\
*There are some obs that are missing charges due to the code\
 I wrote that creates observations when individuals were in\
 the hospital for stays that originated in another month;\
replace charge=0 if charge==.;\
replace deduct=0 if _merge==1;\
replace copay=0 if _merge==1;\
replace dayscount=0 if _merge==1;\
replace anyhosp=0 if _merge==1;\
replace er=0 if _merge==1;\
replace er=er_prof if plancode==1|plancode==2;\
drop er_prof;\
replace snf=0 if _merge==1;\
replace netpay=0 if _merge==1;\
replace imputed_netpay=0 if _merge==1;\
replace imputed_mcare_hosp=0 if _merge==1;\
replace costshare_hosp=0 if _merge==1;\
drop _merge;\
\
rename charge charge_fac;\
rename deduct deduct_fac;\
rename copay copay_fac;\
rename netpay netpay_fac;\
drop netpay_fac;\
\
compress;\
\
tab year;\
save ../data/mergeddata, replace;\
exit;\
clear;\
*/\
\
/*\
*RUN THIS CODE WHEN CREATING THE FINAL DATA SET;\
use ../data/mergeddata;\
capture drop changeperson changed lastdayofmonth;\
\
*Want person-specific measure of chronic illnesses;\
egen anyh1=max(hypertension), by(personid);\
egen anyh2=max(hypercholest), by(personid);\
egen anya1=max(asthma), by(personid);\
egen anyd1=max(diabetes), by(personid);\
egen anya2=max(arthritis), by(personid);\
egen anyd2=max(depression), by(personid);\
egen anyg=max(gastritis), by(personid);\
\
drop hypertension hypercholest asthma diabetes arthritis depression gastritis;\
\
rename anyh1 hypertension;\
rename anyh2 hypercholest;\
rename anya1 asthma;\
rename anyd1 diabetes;\
rename anya2 arthritis;\
rename anyd2 depression;\
rename anyg gastritis;\
\
*Merge Charlson score;\
sort personid;\
merge personid using ../data/charlson.dta;\
tab _merge;\
drop if _merge==2;\
drop _merge;\
\
save ../data/mergeddata, replace;\
exit;\
*/\
\
/*\
*CREATE DATA SET WITH CHRONIC DISEASE INDICATORS FOR\
 DRUG DATA;\
use ../data/mergeddata;\
keep if year==2000 & month==1;\
keep personid hypertension-gastritis plancode;\
gen basic=plancode==1|plancode==3|plancode==5|plancode==7;\
gen none=hypertension==0 & hypercholest==0 & asthma==0 & diabetes==0\
    & arthritis==0 & depression==0 & gastritis==0;\
gen any=hypertension==1|hypercholest==1|asthma==1|diabetes==1|arthritis==1|\
    depression==1|gastritis==1;\
\
sort personid;\
save ../data/chronic, replace;\
exit;\
*/\
\
\
}