{\rtf1\ansi\ansicpg1252\cocoartf949\cocoasubrtf350
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww17440\viewh15440\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\ql\qnatural\pardirnatural

\f0\fs24 \cf0 #delimit;\
clear;\
capture log close;\
set mem 3000m;\
set more 1;\
log using master_bycontact.log, replace;\
\
/*\
*************;\
* DRUG DATA *;\
*************;\
\
foreach x in 1 2 3 4 5 6 7 8 \{;\
use ../rawdata/drugs_part`x'.dta;\
\
rename col1 personid;\
rename col2 relation;\
rename col3 sex;\
rename col4 dob;\
rename col5 plancode;\
rename col6 location;\
rename col8 claimid;\
rename col9 incdate;\
rename col10 provtype;\
rename col11 provplace;\
rename col12 proc;\
rename col13 proccode;\
rename col14 network;\
rename col15 charge;\
rename col16 deduct;\
rename col17 coins;\
rename col18 copay;\
rename col19 netpay;\
rename col20 ndccode;\
rename col21 ndctext;\
rename col22 mailretail;\
rename col23 provloc;\
rename col24 plan;\
*rename col25 revcode;\
\
keep personid plancode ndccode claimid incdate\
     charge deduct coins copay netpay ndctext mailretail;\
compress;\
\
gen byte mail=mailretail=="M";\
replace mail=. if mailretail=="~";\
drop mailretail;\
\
*Collapse to claim level;\
count;\
*Count each claimid-drug combination as a separate contact\
i.e. if there are 2 drugs on one claim, it counts as 2 contacts;\
\
sort claimid ndccode plancode personid incdate ndctext;\
collapse (sum) charge deduct coins copay netpay (max) mail,\
          by(claimid ndccode plancode personid incdate ndctext);\
count;\
\
*Generate month & year variables;\
gen month=month(incdate);\
gen year=year(incdate);\
drop incdate;\
\
drop if year==1999;\
drop if year==2003 & month>=10;\
\
count;\
\
*Drop individuals who are not in our final data set;\
drop plancode;\
sort personid year month;\
merge personid year month using ../data/elig_recoded;\
tab _merge;\
keep if _merge==3;\
drop dob sex _merge;\
\
count;\
\
*Copay will include coinsurance;\
replace copay=copay+coins;\
drop coins;\
compress;\
\
desc;\
tab plancode year, missing;\
\
\
save ../data/drugs_contact`x'.dta, replace;\
\};\
clear;\
\
exit;\
*/\
/*\
use ../data/drugs_contact1.dta;\
append using ../data/drugs_contact2.dta;\
append using ../data/drugs_contact3.dta;\
append using ../data/drugs_contact4.dta;\
append using ../data/drugs_contact5.dta;\
append using ../data/drugs_contact6.dta;\
append using ../data/drugs_contact7.dta;\
append using ../data/drugs_contact8.dta;\
\
keep claimid ndccode plancode year month charge deduct copay netpay personid ndctext agegroup mail;\
compress;\
\
sort personid agegroup claimid ndccode plancode year month ndctext;\
collapse (sum) charge deduct copay netpay (max) mail,\
          by(personid agegroup claimid ndccode plancode year month ndctext);\
count;\
drop claimid;\
\
*Impute total charges;\
replace charge=. if plancode~=6 & plancode~=8;\
summ charge, detail;\
egen imputed_drug=mean(charge), by(ndccode);\
*For those that have missing values, assign average of $72.77;\
replace imputed_drug=72.77 if imputed_drug==.;\
drop charge;\
summ imputed_drug, detail;\
\
*Impute total payments;\
gen totalpay=netpay+copay+deduct;\
count;\
count if totalpay==.;\
replace totalpay=. if plancode~=6 & plancode~=8;\
summ totalpay, detail;\
egen imputed_totalpay=mean(totalpay), by(ndccode);\
*for those that have missing values, assign average of $65.75;\
replace imputed_totalpay=65.75 if imputed_totalpay==.;\
drop totalpay;\
summ imputed_totalpay, detail;\
corr imputed_totalpay imputed_drug;\
\
count;\
compress;\
desc;\
\
*Determine whether it is a new drug or a refill;\
sort personid ndccode year month;\
by personid ndccode: gen byte new=_n==1;\
gen byte refill=new==0;\
replace new=. if ndccode=="~"|ndccode=="";\
replace refill=. if ndccode=="~"|ndccode=="";\
bysort year month: summ new refill;\
\
*Add indicators for chronic conditions;\
sort personid;\
merge personid using ../data/chronic;\
tab _merge;\
drop if _merge==2;\
drop _merge;\
\
*Add Charlson score based on all claims;\
sort personid;\
merge personid using ../data/charlson;\
tab _merge;\
drop if _merge==2;\
drop _merge;\
\
tab plancode year, missing;\
save ../data/drugs_contact.dta, replace;\
exit;\
*/\
\
***************************************;\
* FACILITY DATA FOR OUTPATIENT CLAIMS *;\
***************************************;\
/*\
use ../data/dtl1.dta;\
append using ../data/dtl2.dta;\
append using ../data/dtl3.dta;\
\
keep if provplace=="Outpatient Hospital"|provplace=="Outpatient, NOS"|\
        provplace=="Ambulatory Surgical Center";\
\
sort personid plancode claimid incdate;\
collapse (sum) charge, by(personid plancode claimid incdate) fast;\
\
save ../data/dtl_out_contact;\
*/\
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
*Copay will include copayment & coinsurance;\
replace copay=copay+coins;\
drop coins;\
\
*Generate indicators for outpatient claims;\
gen byte outpatient=provplace=="Outpatient Hospital"|provplace=="Outpatient, NOS";\
gen byte asc=provplace=="Ambulatory Surgical Center";\
\
*Don't count inpatient "stays" for "laboratory examinations";\
replace outpatient=1 if dxdx=="Laboratory Examination";\
\
*Don't count outpatient visit if appears to be inpatient;\
replace outpatient=0 if dayscount>0;\
replace asc=0 if dayscount>0;\
\
*Only keep outpatient claims;\
keep if outpatient==1|asc==1;\
\
*Collapse to claim level;\
count;\
keep deduct* copay* claimid personid plancode incdate;\
sort claimid personid plancode incdate;\
collapse (sum) deduct* copay*,\
          by(claimid personid plancode incdate);\
count;\
\
save ../data/fac_out`x'.dta, replace;\
clear;\
\};\
exit;\
*/\
/*\
use ../data/fac_out1;\
append using ../data/fac_out2;\
append using ../data/fac_out3;\
\
*Generate month & year variables;\
gen month=month(incdate);\
gen year=year(incdate);\
\
drop if year==1999;\
drop if year==2003 & month>=10;\
drop if year==2000 & (plancode==3|plancode==4);\
tab plancode;\
\
*Collapse to date incurred;\
sort personid claimid plancode incdate month year;\
collapse (sum) copay deduct,\
         by(personid claimid plancode incdate month year);\
tab plancode;\
compress;\
\
*Add in charge data;\
sort personid plancode claimid incdate;\
merge personid plancode claimid incdate using ../data/dtl_out_contact;\
tab _merge;\
keep if _merge==3;\
drop _merge;\
\
*Drop individuals who are not in our final data set;\
drop plancode;\
sort personid year month;\
merge personid year month using ../data/elig_recoded;\
tab _merge;\
drop if _merge~=3;\
drop dob sex _merge dec2000 changed changeperson agegroup;\
count;\
\
gen byte outhosp=1;\
rename copay copay_outhosp;\
rename deduct deduct_outhosp;\
\
tab plancode year, missing;\
save ../data/fac_out_contact.dta, replace;\
exit;\
*/\
\
*************;\
* PROF DATA *;\
*************;\
/*\
foreach x in  1 2 3 4 5 6 7 /* 8 9 10 11 12 13 14 */ \{;\
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
*Drop certain claims that are not consistently reported in plancode 3/4;\
drop if (provtype=="Psychiatry"|provtype=="Psychologist"|provtype=="Therapists (Supportive)")\
         & (plancode==3|plancode==4);\
\
*Drop certain claims that are problematic in plan #2;\
drop if provtype=="Hearing Labs"|provtype=="Health Educatory/Agency"\
& (plancode==1|plancode==2);\
\
keep personid plancode claimid incdate charge\
     deduct coins copay provplace provtype proc;\
compress;\
\
*Office visit measure;\
gen office=provplace=="Office";\
gen out=provplace=="Outpatient, NOS"|provplace=="Outpatient Hospital";\
\
*Copay will include coinsurance;\
replace copay=copay+coins;\
drop coins;\
\
*Collapse to claim level - allowing for fact that incdate is\
 sometimes different within claims;\
count;\
sort claimid personid plancode incdate office;\
collapse (sum) charge deduct copay (max) out,\
          by(claimid personid plancode incdate office);\
count;\
\
tab office out;\
\
*Generate month & year variables;\
gen month=month(incdate);\
gen year=year(incdate);\
\
drop if year<=1999;\
drop if year==2003 & month>=10;\
count;\
\
*Drop plancode so that new, recoded plancode takes precedence;\
drop plancode;\
\
*Drop individuals who are not in our final data set;\
sort personid year month;\
merge personid year month using ../data/elig_recoded;\
tab _merge;\
keep if _merge==3;\
drop dob sex _merge;\
\
count;\
\
tab plancode year, missing;\
\
compress;\
save ../data/prof_contact`x'.dta, replace;\
desc;\
clear;\
\};\
\
\
use ../data/prof_contact1.dta;\
append using ../data/prof_contact2.dta;\
append using ../data/prof_contact3.dta;\
append using ../data/prof_contact4.dta;\
append using ../data/prof_contact5.dta;\
append using ../data/prof_contact6.dta;\
append using ../data/prof_contact7.dta;\
append using ../data/prof_contact8.dta;\
append using ../data/prof_contact9.dta;\
append using ../data/prof_contact10.dta;\
append using ../data/prof_contact11.dta;\
append using ../data/prof_contact12.dta;\
append using ../data/prof_contact13.dta;\
append using ../data/prof_contact14.dta;\
*Append data on hospital-based outpatient visits;\
append using ../data/fac_out_contact;\
\
replace outhosp=0 if outhosp==.;\
replace out=0 if out==.;\
replace office=0 if office==.;\
replace copay=0 if copay==.;\
replace deduct=0 if deduct==.;\
replace copay_outhosp=0 if copay_outhosp==.;\
replace deduct_outhosp=0 if deduct_outhosp==.;\
\
compress;\
\
*Collapse to claim level again - allowing for fact that incdate is\
 sometimes different within claims;\
count;\
sort personid claimid plancode incdate year month office;\
collapse (sum) charge deduct* copay* (max) out*,\
          by(personid claimid plancode incdate year month office);\
count;\
\
*Make "out" and "outhosp" mutually exclusive.  We will only count as office visits those outpatient claims with no associated facility claim;\
tab out outhosp;\
replace out=0 if outhosp==1;\
replace copay_outhosp=copay+copay_outhosp if out==1 & outhosp==1;\
replace deduct_outhosp=deduct+deduct_outhosp if out==1 & outhosp==1;\
replace copay=0 if out==1 & outhosp==1;\
replace deduct=0 if out==1 & outhosp==1;\
replace out=0 if outhosp==1;\
\
*Combine "out" and "office";\
tab out office;\
replace office=max(office, out);\
drop out;\
\
sort personid claimid plancode incdate year month office;\
collapse (sum) charge deduct* copay* (max) outhosp,\
          by(personid claimid plancode incdate year month office);\
\
count;\
drop incdate;\
compress;\
sort year month;\
\
tab plancode year if charge==0;\
drop if charge==0;\
\
*Generate variables exclusively for office visits;\
gen copay_o=copay if office==1;\
gen deduct_o=deduct if office==1;\
\
*Already have variables for outpatient (hosp-based) visits;\
replace copay_outhosp=. if outhosp==0;\
replace deduct_outhosp=. if outhosp==0;\
\
tab plancode year, missing;\
\
*ONLY KEEP OFFICE VISITS;\
keep if office==1;\
\
save ../data/prof_contact.dta, replace;\
exit;\
*/\
\
}