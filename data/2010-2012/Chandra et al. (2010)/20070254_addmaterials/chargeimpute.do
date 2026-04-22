{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww14240\viewh14680\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 #delimit;\
clear;\
capture log close;\
set mem 4000m;\
set matsize 4000;\
set more 1;\
log using chargeimpute.log, replace;\
\
**************************************;\
* INPATIENT CHARGES FROM PROF CLAIMS *;\
**************************************;\
\
foreach x in  1 2 3 4 5 6 7  8 9 10 11 12 13 14 \{;\
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
keep if provplace=="Inpatient Hospital";\
\
gen costshare=copay+coins+deduct;\
\
*Merge on CCS codes;\
sort dxcode;\
merge dxcode using ../data/ccscodes.dta;\
tab _merge;\
drop if _merge==2;\
\
keep personid relation sex dob plancode recordid claimid incdate\
     charge ccscode netpay costshare;\
compress;\
\
*Collapse to claim level - allowing for fact that incdate is\
 sometimes different within claims;\
count;\
sort claimid personid incdate plancode ccscode;\
collapse (sum) charge netpay costshare,\
         by(claimid personid incdate plancode ccscode);\
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
save ../data/prof_inpimpute`x'.dta, replace;\
desc;\
clear;\
\};\
exit;\
*/\
\
/*\
use ../data/prof_inpimpute1.dta;\
append using ../data/prof_inpimpute2.dta;\
append using ../data/prof_inpimpute3.dta;\
append using ../data/prof_inpimpute4.dta;\
append using ../data/prof_inpimpute5.dta;\
append using ../data/prof_inpimpute6.dta;\
append using ../data/prof_inpimpute7.dta;\
append using ../data/prof_inpimpute8.dta;\
append using ../data/prof_inpimpute9.dta;\
append using ../data/prof_inpimpute10.dta;\
append using ../data/prof_inpimpute11.dta;\
append using ../data/prof_inpimpute12.dta;\
append using ../data/prof_inpimpute13.dta;\
append using ../data/prof_inpimpute14.dta;\
\
count;\
*Collapse to claim level (again);\
sort claimid personid incdate plancode ccscode;\
collapse (sum) charge netpay costshare,\
          by(claimid personid incdate plancode ccscode) fast;\
count;\
\
*Collapse to incurred date;\
sort personid plancode incdate ccscode;\
collapse (sum) charge netpay costshare, by(personid plancode incdate ccscode) fast;\
\
*Save and then we will merge this onto the inpatient data\
to have a more complete measure of inpatient charges;\
compress;\
rename charge charge_prof;\
rename netpay netpay_prof;\
rename costshare costshare_prof;\
sort personid plancode incdate ccscode;\
save ../data/prof_inpimpute.dta, replace;\
clear;\
\
****************;\
* FAC DTL DATA *;\
****************;\
/*\
use ../data/dtl1.dta;\
append using ../data/dtl2.dta;\
append using ../data/dtl3.dta;\
\
keep if provplace=="Inpatient Hospital"|provplace=="Birthing Center";\
\
*Merge on CCS codes;\
sort dxcode;\
merge dxcode using ../data/ccscodes.dta;\
tab _merge;\
drop if _merge==2;\
\
*Collapse to claim level;\
sort personid relation sex dob plancode claimid incdate ccscode;\
collapse (sum) charge, by(personid relation sex dob plancode claimid incdate ccscode) fast;\
\
*Collapse by incurred date/diagnosis;\
sort personid plancode incdate ccscode;\
collapse (sum) charge, by(personid plancode incdate ccscode) fast;\
\
save ../data/dtl_chargeimpute.dta, replace;\
exit;\
*/\
\
****************;\
* FAC HDR DATA *;\
****************;\
/*\
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
gen costshare=copay+coins+deduct;\
drop copay coins deduct;\
\
*Only want to deal with inpatient stays;\
keep if provplace=="Inpatient Hospital"|provplace=="Birthing Center";\
\
*Do not include inpatient "stays" with a primary diagnosis of\
 "laboratory examinations";\
drop if dxdx=="Laboratory Examination";\
\
*Merge on CCS codes;\
sort dxcode;\
merge dxcode using ../data/ccscodes.dta;\
tab _merge;\
drop if _merge==2;\
\
*Collapse to claim level;\
count;\
keep costshare netpay dayscount claimid personid plancode incdate ccscode;\
sort claimid personid plancode incdate ccscode;\
collapse (max) dayscount (sum) netpay costshare,\
          by(claimid personid plancode incdate ccscode);\
count;\
\
sort personid plancode incdate ccscode;\
collapse (max) dayscount (sum) netpay costshare,\
          by(personid plancode incdate ccscode);\
tab plancode;\
count;\
\
save ../data/fac_chargeimpute`x'.dta, replace;\
clear;\
\};\
exit;\
*/\
\
/*\
use ../data/fac_chargeimpute1;\
append using ../data/fac_chargeimpute2;\
append using ../data/fac_chargeimpute3;\
\
*Collapse by person/incurred date/diagnosis again;\
count;\
sort personid plancode incdate ccscode;\
collapse (max) dayscount (sum) netpay costshare,\
          by(personid plancode incdate ccscode);\
tab plancode;\
count;\
\
*Merge charge data;\
sort personid plancode incdate ccscode;\
merge personid plancode incdate ccscode using ../data/dtl_chargeimpute.dta;\
tab _merge;\
*_merge=1 shouldn't occur;\
*_merge=2 are likely labs and will end up with dayscount=. so drop these;\
keep if _merge==3;\
drop _merge;\
\
*Merge professional claims data that indicates an "inpatient" location;\
sort personid plancode incdate ccscode;\
merge personid plancode incdate ccscode using ../data/prof_inpimpute.dta;\
tab _merge;\
\
replace charge=0 if _merge==2;\
replace charge_prof=0 if _merge==1;\
replace charge=charge+charge_prof;\
\
replace netpay=0 if _merge==2;\
replace netpay_prof=0 if _merge==1;\
replace netpay=netpay+netpay_prof;\
drop netpay_prof;\
\
replace costshare=0 if _merge==2;\
replace costshare_prof=0 if _merge==1;\
replace costshare=costshare+costshare_prof;\
drop costshare_prof;\
\
*If professional claim occurs DURING a hospitalization (even if the\
 incurred date isn't identical), recode it to have the same incurred date\
 and ccscode as the hospitalization;\
gen profclaim=_merge==2;\
sort personid incdate profclaim;\
foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30\
        31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 \{;\
gen flag`x'=personid==personid[_n-`x'] & incdate[_n-`x']+dayscount[_n-`x']>=incdate\
    & _merge==2 & _merge[_n-`x']~=2;\
tab flag`x';\
\};\
gen anyflag=max(flag1, flag2, flag3, flag4, flag5, flag6, flag7, flag8, flag9, flag10,\
                flag11, flag12, flag13, flag14, flag15, flag16, flag17, flag18, flag19, flag20,\
                flag21, flag22, flag23, flag24, flag25, flag26, flag27, flag28, flag29, flag30,\
                flag31, flag32, flag33, flag34, flag35, flag36, flag37, flag38, flag39, flag40,\
                flag41, flag42, flag43, flag44, flag45, flag46, flag47, flag48, flag49, flag50);\
\
sort personid incdate plancode;\
list personid incdate ccscode dayscount charge in 1/100;\
tab _merge;\
keep if _merge==1|(_merge==2 & anyflag==1)|_merge==3;\
foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30\
        31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 \{;\
replace incdate=incdate[_n-`x'] if flag`x'==1;\
replace ccscode=ccscode[_n-`x'] if flag`x'==1;\
\};\
replace dayscount=0 if _merge==2;\
drop flag1-flag50;\
drop _merge;\
\
*Collapse by incurred date and CCS code, so that prof claims are incorporated\
 with the hospitalization where they occurred;\
count;\
sort personid plancode incdate ccscode;\
collapse (sum) charge charge_prof netpay costshare (max) dayscount,\
          by(personid plancode incdate ccscode);\
list in 1/100;\
tab plancode;\
count;\
\
*Generate month & year variables;\
gen month=month(incdate);\
gen year=year(incdate);\
\
drop if year<2000;\
\
*Code to assign hospital days/charges to month when actually IN hospital;\
gen chargeperday=charge/dayscount;\
gen netpayperday=netpay/dayscount;\
gen costshareperday=costshare/dayscount;\
gen charge_profperday=charge_prof/dayscount;\
drop if dayscount<0;\
drop if dayscount==.;\
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
bysort personid plancode incdate ccscode year month: replace flag=0 if _n~=_N;\
capture gen remaining=0;\
replace remaining=0;\
replace remaining=dayscount-inhospital if flag==1;\
replace month=month+1 if flag==1;\
replace year=year+1 if month==13 & flag==1;\
replace month=1 if month==13 & flag==1;\
\};\
\
replace dayscount=inhospital;\
drop inhospital flag;\
\
*Net payments for the month;\
gen netpaypermonth=netpayperday*dayscount;\
drop netpay netpayperday;\
rename netpaypermonth netpayimpute;\
\
*Cost sharing for the month;\
gen costsharepermonth=costshareperday*dayscount;\
drop costshare costshareperday;\
rename costsharepermonth costshare_hosp;\
\
*Collapse to person-month-CCScode level;\
sort personid plancode year month ccscode;\
count;\
sort personid plancode year month ccscode;\
collapse (sum) netpayimpute costshare_hosp,\
          by(personid plancode year month ccscode);\
count;\
\
drop if year<2000;\
drop if year==2003 & month>=10;\
compress;\
\
*Want to impute netpay from plancode=6/8;\
replace netpayimpute=. if plancode~=6 & plancode~=8;\
egen imputed_netpay=mean(netpayimpute), by(ccscode);\
\
*Need to know overall average net payment for a hospitalization\
 for observations with no CCS codes;\
summ netpayimpute;\
replace imputed_netpay=1334.59 if ccscode=="";\
\
*Merge on imputed Medicare payments from Dartmouth data;\
gen ccs=real(ccscode);\
drop ccscode;\
rename ccs ccscode;\
sort ccscode;\
merge ccscode using ../data/medicare_hosp.dta;\
tab _merge;\
replace imputed_mcare_hosp=7551.99 if _merge==1|ccscode==.;\
drop if _merge==2;\
\
*Collapse to person level;\
*Will keep ACTUAL cost-sharing for the month, along with IMPUTED payments;\
ort personid year month;\
collapse (sum) imputed_netpay imputed_mcare_hosp costshare_hosp,\
         by(personid year month);\
\
save ../data/fac_chargeimpute, replace;\
exit;\
*/\
\
*************;\
* PROF DATA *;\
*************;\
/*\
foreach x in 1 2 3 4 5 6 7 /* 8 9 10 11 12 13 14 */ \{;\
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
gen costshare=coins+copay+deduct;\
\
*Office visits for HMOs;\
gen officehmo=office==1;\
gen out=provplace=="Outpatient, NOS"|provplace=="Outpatient Hospital";\
\
*Merge on CCS codes;\
sort dxcode;\
merge dxcode using ../data/ccscodes.dta;\
tab _merge;\
drop if _merge==2;\
\
keep personid relation sex dob plancode recordid claimid incdate\
     charge officehmo out ccscode provtype netpay costshare;\
compress;\
\
*Drop certain claims that are not consistently reported in plancode 3/4;\
drop if (provtype=="Psychiatry"|provtype=="Psychologist"|provtype=="Therapists (Supportive)")\
         & (plancode==3|plancode==4);\
\
*Drop certain claims that are problematic in plancode 2;\
drop if provtype=="Hearing Labs"|provtype=="Health Educator/Agency"\
& (plancode==1|plancode==2);\
\
*Collapse to claim level - allowing for fact that incdate is\
 sometimes different within claims;\
count;\
sort claimid personid incdate plancode ccscode officehmo;\
collapse (sum) charge netpay costshare (max) out,\
         by(claimid personid incdate plancode ccscode officehmo);\
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
save ../data/prof_chargeimpute_`x'.dta, replace;\
desc;\
clear;\
\};\
exit;\
*/\
\
*******************************;\
* IMPUTE OFFICE VISIT CHARGES *;\
*******************************;\
\
use ../data/prof_chargeimpute1.dta;\
append using ../data/prof_chargeimpute2.dta;\
append using ../data/prof_chargeimpute3.dta;\
append using ../data/prof_chargeimpute4.dta;\
append using ../data/prof_chargeimpute5.dta;\
append using ../data/prof_chargeimpute6.dta;\
append using ../data/prof_chargeimpute7.dta;\
append using ../data/prof_chargeimpute8.dta;\
append using ../data/prof_chargeimpute9.dta;\
append using ../data/prof_chargeimpute10.dta;\
append using ../data/prof_chargeimpute11.dta;\
append using ../data/prof_chargeimpute12.dta;\
append using ../data/prof_chargeimpute13.dta;\
append using ../data/prof_chargeimpute14.dta;\
\
count;\
*Collapse to claim level (again);\
sort claimid personid incdate plancode ccscode officehmo;\
collapse (sum) charge netpay costshare (max) out,\
          by(claimid personid incdate plancode ccscode officehmo) fast;\
count;\
\
*Drop outpatient visits that are associated with a facility claim;\
*First, merge on outpatient hospital & ambulatory surgical center claims (from data set created in master.do);\
rename charge charge_prof;\
sort personid plancode incdate;\
merge personid plancode incdate using ../data/outfac.dta;\
tab _merge;\
drop charge;\
rename charge_prof charge;\
\
gen byte outhosp=outpatient==1|asc==1;\
tab outhosp _merge;\
*Want outhosp and out to be mutually exclusive i.e. either it\
is an outpatient visit with a facility claim or it isn't;\
replace out=0 if outhosp==1;\
tab out outhosp;\
\
*Redefine office visits to include professional-based outpatient visits;\
replace officehmo=max(officehmo, out);\
\
*Only keep office visits;\
keep if officehmo==1;\
tab officehmo out;\
\
*Collapse by date/ccs code;\
sort personid incdate plancode ccscode;\
collapse (sum) charge netpay costshare (max) officehmo,\
          by(personid incdate plancode ccscode) fast;\
\
*Generate year & month variables;\
gen year=year(incdate);\
gen month=month(incdate);\
\
*Drop claims with zero charges;\
tab plancode year if charge==0;\
drop if charge==0;\
compress;\
\
*Impute net pay charges from plancodes 6/8;\
gen netpayoffice=netpay;\
replace netpayoffice=. if plancode~=6 & plancode~=8;\
egen imputed_netpay_office=mean(netpayoffice), by(ccscode);\
\
*Need to know overall average net payment for observations\
 with no CCS codes;\
summ netpayoffice;\
replace imputed_netpay_office=30.99  if ccscode=="";\
\
*Impute total payments (Medicare + ins + cost-sharing).  We\
 assume that this will equal 5*(ins payment + cost-sharing)\
 since Medicare pays 80% of costs.  We use the reported charge\
 as the upper bound on total payments;\
gen totalpay=min((5*(netpay+costshare)), charge);\
replace totalpay=. if plancode~=6 & plancode~=8;\
egen imputed_totalpay_office=mean(totalpay), by(ccscode);\
\
*Need to know overall average totalpay for observations with\
 no CCS codes;\
summ totalpay;\
replace imputed_totalpay_office=119.64  if ccscode=="";\
\
*Collapse to person, month, year level;\
count;\
compress;\
sort personid month year;\
collapse (sum) imputed_netpay_office imputed_totalpay_office,\
          by(personid month year) fast;\
count;\
\
compress;\
sort personid year month;\
save ../data/prof_chargeimpute.dta, replace;\
exit;\
*/\
}