* calpers drug coding
clear
set more off
set mat 800
local dir "~/Data/Calpers/"
cd `dir'
capture log close
log using drugmerge.log, replace
set mem 7500m




* make a table of drug classes
use `dir'ndcdata
encode drugclass, gen(class)
encode name, gen(drug) 
encode ingredient, gen(tmp)
drop name drugclass ingredient
rename tmp ingredient
gen foo=class
table class, c(mean foo)
sort ndccode
save er_ndcdataformerge, replace


* Read in Rx claims data  and merge with NDC data
clear
use `dir'drugs_contact
capture drop _merge
compress
sort ndccode
merge ndccode using `dir'er_ndcdataformerge
tab _merge
drop if _merge==2
gen merge=_merge==3
* set merge=missing for missing data.
replace merge=. if (plan==3|plan==4) & year==2000
* Table below tells us what fraction of obs were match to NDC codes.
tab plancode  year, sum(merge) nofreq nost
tab plancode  year if _merge==3
gen haveclass=class!=. 
replace haveclass=. if ((plan==3|plan==4) & year==2000)
tab plancode  year, summ (haveclass) nofreq nost
drop haveclass

gen imputed_inspay=imputed_totalpay-copay
* Note: several of the drugs with _merge==3 don't have a "class of drug" associated with them (~n=4,000,000)
* Solution:  recover modal class for each  drug. Then merge this onto obs with missing class.
* Note: we can't impute class to drugs w/ _merge==1 using by(ingredient) because ingredient info is only avail for _merge==3
*       we can't impute class to drugs w/ _merge using name or ingredient, as we don't have the name of the drug for those w/ _merge==1 (ndctext is not the name of drug)
tab _merge if class==. 
egen tmpclass=mode(class), by(drug)  maxmode
replace class=tmpclass if class==. & _merge==3
tab _merge if class==. 
* Now repeat using ingredient: assign modeal class of drug by ingredient
drop tmpclass
egen tmpclass=mode(class), by(ingredient)  maxmode
replace class=tmpclass if class==. & _merge==3
tab _merge if class==. 
gen haveclass=class!=.
replace haveclass=. if ((plan==3|plan==4) & year==2000)
tab plancode  year, summ (haveclass) nofreq nost

* Code drugs for chronic disease cohorts
* chronicdrug=1 if class==25| class ==32| class ==33| class ==51
* chronicdrug=2 if class == 1| class ==5 | class ==24| class ==59| class ==63| class ==43| class ==88
* chronicdrug=3 if class ==102
* chronicdrug=4 if class ==28
* chronicdrug=5 if class ==87
* chronicdrug=6 if class ==61
* replace chronicdrug=7 if class ==27| class ==117
* 1 "Drugs for Depression, Bipolar Disporder and Affective Disorders" 2 "Drugs for Hypertension" 3 "Drugs for Hypercholesterolemia" 4 "Drugs for Asthma" /*
*/ 5 "Drugs for Gastritis and Peptic Ulcers" 6 "Drugs for Diabetes" 7 "Drugs for Osteo-Arthritis" 
*label values chronicdrug chronicdrug
* label var chronicdrug "Chronic Condition Treating Drug"
gen nchronic= depression+hypertension+hyperchol+asthma+ gastritis + diabetes+arthritis
gen nochronic=nchronic==0
gen somechronic=nchronic!=0


*Determine whether drug is a new drug or a refill (based on class of drug): Data already has this based on actual NDC code (called new and refill)
* Remember to drop plancode 3/4 data and first 6 months of data for regs based on these vars
sort personid class year month
by personid class: gen byte newclass=_n==1
gen byte refillclass=newclass==0
replace newclass=. if class==.
replace refillclass=. if class==.
bysort year month: summ new refill
compress


* code importance of drug
egen importance1=anymatch(class), values(3 11 13 14 23 24 26 28 29 30 31 32 37 38 44 45 48 49 50 51 56 60 61 66 67 70 71 76 89 103 110 119 126 129 130 134 135 140 142 151)
egen importance2=anymatch(class), values(1    5  6 12 22 35 41 43 58 59 63 64 65 68 72 78 79 87 88 91 93 94 95 96 97 98 99 100 101 102 104 105 106 112 114 116 118 136 144)
gen importance=3
replace importance=1 if importance1==1
replace importance=2 if importance2==1
label var importance "Type of Drug"
label define importance 1 "Acute Meds" 2 "Chronic Meds" 3 "Lifestyle Meds"
label values importance importance

* code how essential the drug is
egen essential1=anymatch(class), values(1 3 22 24 31 32 41 43 44 49 51 58 59 61 63 65 68 76 77 78 88 97 103 144 151)
egen essential2=anymatch(class), values(42 52 73 115 117 133 137 145 152)
gen essential=3
replace essential=1 if essential1==1
replace essential=2 if essential2==1
label var essential "Type of Drug"
label define essential 1 "Essential" 2 "Symptom Relief" 3 "Other--not classified"
label values essential essential



* label some vars
gen basicplan=plancode==1|plancode==3|plancode==5|plancode==7
label var basic "Type of Plan"
label define basicplan 0 "Suppl Plan" 1 "Basic Plan"
label values basicplan basicplan
label define plan 1 "Basic" 2 "Supp" 3 "Basic" 4 "Supp" 5 "Basic" 6 "Supp" 7 "Basic" 8 "Supp"
label values plan plan
gen ppo=plancode>=5
gen hmo=!ppo
gen     plan4=1 if plancode==1 | plancode==2
replace plan4=2 if plancode==3| plancode==4
replace plan4=3 if plancode==5| plancode==6
replace plan4=4 if plancode==7| plancode==8
egen timetrend=group (year month)
gen post=(ppo==1 & timetrend>13) | (ppo==0 & timetrend>24)
gen postppo=timetrend>13
gen posthmo=timetrend>24
gen treat=(hmo & timetrend>24) | (ppo & timetrend>13)

* classify drugs into tiers based on copays in after 2002
gen copay2002=copay if post

egen meancopaypost=mean(copay2002), by(plancode drug) 
* var above will be used for static vs. dynamic copay changes-- it's ok to use plancode for computing copay means
egen modalcopay02= mode(copay2002), by(plancode drug) maxmode
tab  modalcopay02 plancode
* classify each drug into a tier based on POST tier (for this reason it doesn't matter what the pre-policy change copay was for these drugs)
gen     drugtier=1 if modalcopay==5 | modalcopay==10  
replace drugtier=2 if modalcopay==15| modalcopay==25
replace drugtier=3 if modalcopay==30| modalcopay==45
label define drugtier 1 "Generic" 2 "Formulary" 3 "Non-Formulary, Retail"
label value  drugtier drugtier
tab plancode drugtier, r missing
* now sweep data for drugs that were not assigned a tier and assign min modal copay, and modal copay across plans
egen modalcopay02b=mode(copay2002), by(plancode drug) minmode
gen missingtier1=drugtier==.
replace drugtier=1 if (modalcopay02b==5 | modalcopay02b==10) & drugtier==.
replace drugtier=2 if (modalcopay02b==15| modalcopay02b==25) & drugtier==.
replace drugtier=3 if (modalcopay02b==30| modalcopay02b==45) & drugtier==.
tab plancode drugtier, r missing
replace modalcopay02= modalcopay02b if missingtier1 & (modalcopay02b==5| modalcopay02b== 10| modalcopay02b==15| modalcopay02b==25| modalcopay02b==30| modalcopay02b==45) 
* tab below looks at whether we still have claims for drugs that have a copay below the post copay. Test for this is relatively weak: look at whether #of claims falls to zero (or close)
gen copaypost=copay if post==1
gen copaypre =copay if post==0
egen mediancopaypost=median(copaypost), by(plancode)
egen mediancopaypre= median(copaypre),  by(plancode)
gen belowpostcopay=(imputed_drug< mediancopaypost) & (imputed_drug>mediancopaypre)
table timetrend plancode, c(mean belowpostcopay)

* replace mail order copays in preperiod with retail copays
gen modalcopay02retail=modalcopay02
replace modalcopay02retail=30 if modalcopay02retail==45
replace modalcopay02retail=15 if modalcopay02retail==25
replace modalcopay02retail=5  if modalcopay02retail==10
compress

* define alternative treatment groups: for PPOs policy change, take each drug in the PPO formulary tier for one of the PPOs and look for corresponding drug in the HMO data.
* For HMO policy change, define drugs using one of the HMO tiers
capture drop tmp
gen tmpppo_basic=drugtier if plancode==7
gen tmpppo_supp=drugtier if plancode==8
gen tmphmo_basic=drugtier if plancode==1
gen tmphmo_supp=drugtier if plancode==2

egen ppodrugtier_basic=mean(tmpppo_basic), by (drug)
egen ppodrugtier_supp=mean(tmpppo_supp) , by (drug)
egen hmodrugtier_basic=mean(tmphmo_basic), by (drug)
egen hmodrugtier_suppp=mean(tmpppo_supp), by (drug)

gen ppodrugtier=.
replace ppodrugtier=ppodrugtier_basic if basic 
replace ppodrugtier=ppodrugtier_supp if !basic 
gen hmodrugtier=.
replace hmodrugtier=hmodrugtier_basic if basic 
replace hmodrugtier=hmodrugtier_supp if !basic



* look at #claims that we are throwing out (those where merge is not 3, or class is not defined)
count
* Number below is # claims that we have class data for
count if _merge==3 & class!=.
* Number below is # claims that we have class data for, and are able to assign to a drug tier
count if _merge==3 & class!=. & drugtier!=.
keep  if _merge==3 & class!=. & drugtier!=.
compress
save drugs, replace




foreach classification in ppodrugtier hmodrugtier  {
use drugs 
gen one=1
collapse (count) one  (sum) imputed_totalpay (sum) imputed_inspay (sum) new (sum) refill (sum) newclass (sum) refillclass , by(plancode year month `classification') fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace one =one*1.46895 if year==2002 & month==12 & plancode==5
replace one =one*1.47155 if year==2002 & month==12 & plancode==6
replace one =one*1.4707  if year==2002 & month==12 & plancode==7
replace one =one*1.4673  if year==2002 & month==12 & plancode==8
replace imputed_totalpay =imputed_totalpay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_totalpay =imputed_totalpay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_totalpay =imputed_totalpay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_totalpay =imputed_totalpay*1.4673  if year==2002 & month==12 &  plancode==8

replace imputed_inspay =imputed_inspay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_inspay =imputed_inspay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_inspay =imputed_inspay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_inspay =imputed_inspay*1.4673  if year==2002 & month==12 &  plancode==8
save erplanby`classification', replace
}






          
* First create plan*month level data by class, name, and importance of drug
clear
foreach classification in donut2000 everindonut countdonut importance essential drugtier ppodrugtier hmodrugtier  {
use drugs 
gen one=1
collapse (count) one  (sum) imputed_totalpay (sum) imputed_inspay (sum) new (sum) refill (sum) newclass (sum) refillclass , by(plancode year month `classification') fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace one =one*1.46895 if year==2002 & month==12 & plancode==5
replace one =one*1.47155 if year==2002 & month==12 & plancode==6
replace one =one*1.4707  if year==2002 & month==12 & plancode==7
replace one =one*1.4673  if year==2002 & month==12 & plancode==8
replace imputed_totalpay =imputed_totalpay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_totalpay =imputed_totalpay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_totalpay =imputed_totalpay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_totalpay =imputed_totalpay*1.4673  if year==2002 & month==12 &  plancode==8

replace imputed_inspay =imputed_inspay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_inspay =imputed_inspay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_inspay =imputed_inspay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_inspay =imputed_inspay*1.4673  if year==2002 & month==12 &  plancode==8
save erplanby`classification', replace
}






clear
use drugs 
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) totavgtotpaypd=imputed_totalpay, by(plancode year month) fast
sort plancode year month
save copay, replace

clear
use drugs 
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) avgtotpaypd=imputed_totalpay, by(plancode year month importance) fast
rename copay copaybyimp
rename modalcopay02 modalcopaybyimp
rename modalcopay02retail modalcopay02retailbyimp 
rename meancopaypost meancopaypostbyimp
sort plancode year month importance
save copaybyimportance, replace

clear
use drugs 
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) avgtotpaypd=imputed_totalpay, by(plancode year month essential) fast
rename copay copaybyess
rename modalcopay02 modalcopaybyess
rename modalcopay02retail modalcopay02retailbyess
rename meancopaypost meancopaypostbyess
sort plancode year month essential
save copaybyessential, replace




clear
use drugs 
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) avgtotpaypd=imputed_totalpay, by(plancode year month drugtier) fast
rename copay copaybydrugtier
rename modalcopay02 modalcopaybydrugtier
rename modalcopay02retail modalcopay02retailbydrugtier
rename meancopaypost meancopaypostbydrugtier
sort plancode year month drugtier
save copaybydrugtier, replace


clear
use drugs 
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) avgtotpaypd=imputed_totalpay, by(plancode year month ppodrugtier) fast
rename copay copaybyppodrugtier
rename modalcopay02 modalcopaybyppodrugtier
rename modalcopay02retail modalcopay02retailbyppodrugtier
rename meancopaypost meancopaypostbyppodrugtier
sort plancode year month ppodrugtier
save copaybyppodrugtier, replace


clear
use drugs 
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) avgtotpaypd=imputed_totalpay, by(plancode year month hmodrugtier) fast
rename copay copaybyhmodrugtier
rename modalcopay02 modalcopaybyhmodrugtier
rename modalcopay02retail modalcopay02retailbyhmodrugtier
rename meancopaypost meancopaypostbyhmodrugtier
sort plancode year month hmodrugtier
save copaybyhmodrugtier, replace





foreach classification in donut2000 everindonut countdonut income agegroup tercile charlson {
use drugs 
rename charge_tercilef tercile
rename charlson tmp
drop charlson
gen charlson=0 if tmp==0
replace charlson=13 if tmp==1| tmp==2 | tmp==3
replace charlson=49 if tmp>=4
drop tmp
collapse (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost (mean) avgtotpaypd=imputed_totalpay, by(plancode year month `classification') fast
rename copay copayby`classification'
rename modalcopay02 modalcopayby`classification'
rename modalcopay02retail modalcopay02retailby`classification'
rename meancopaypost meancopaypostby`classification'
sort plancode year month `classification'
save copayby`classification', replace
}



foreach classification in income agegroup tercile charlson {
use drugs 
gen one=1
rename charge_tercilef tercile
rename charlson tmp
drop charlson
gen charlson=0 if tmp==0
replace charlson=13 if tmp==1 | tmp==2 | tmp==3
replace charlson=49 if tmp>=4
drop tmp
collapse (count) one  (sum) imputed_totalpay (sum) imputed_inspay, by(plancode year month importance `classification') fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace one =one*1.46895 if year==2002 & month==12 & plancode==5
replace one =one*1.47155 if year==2002 & month==12 & plancode==6
replace one =one*1.4707  if year==2002 & month==12 &  plancode==7
replace one =one*1.4673  if year==2002 & month==12 &  plancode==8
replace imputed_totalpay =imputed_totalpay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_totalpay =imputed_totalpay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_totalpay =imputed_totalpay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_totalpay =imputed_totalpay*1.4673  if year==2002 & month==12 &  plancode==8

replace imputed_inspay =imputed_inspay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_inspay =imputed_inspay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_inspay =imputed_inspay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_inspay =imputed_inspay*1.4673  if year==2002 & month==12 &  plancode==8

save erplanby`classification', replace
}




* Code drug useby agecategory and then by class, tercile and charlson.
foreach classification in  class age_tercile age_rxtercile  {
use drugs 
rename charge_tercilef tercile
rename charlson tmp
drop charlson
gen charlson=0 if tmp==0
replace charlson=13 if tmp==1 | tmp==2 | tmp==3
replace charlson=49 if tmp>=4
drop tmp
collapse (count) one  (sum) imputed_totalpay (sum) imputed_inspay, by(plancode year month agegroup `classification' ) fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace one =one*1.46895 if year==2002 & month==12 & plancode==5
replace one =one*1.47155 if year==2002 & month==12 & plancode==6
replace one =one*1.4707  if year==2002 & month==12 &  plancode==7
replace one =one*1.4673  if year==2002 & month==12 &  plancode==8
replace imputed_totalpay =imputed_totalpay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_totalpay =imputed_totalpay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_totalpay =imputed_totalpay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_totalpay =imputed_totalpay*1.4673  if year==2002 & month==12 &  plancode==8

replace imputed_inspay =imputed_inspay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_inspay =imputed_inspay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_inspay =imputed_inspay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_inspay =imputed_inspay*1.4673  if year==2002 & month==12 &  plancode==8
save erplanageby`classification', replace
}






* collapse data for drug use by chronic disease cohorts-- note that they're NOT mutually exclusive.
* First create plan*month level data by class, name, and importance of drug
clear
foreach classification in nochronic somechronic depression hypertension hyperchol asthma gastritis  diabetes arthritis  {
use drugs if `classification'==1
gen specificdrug=0
do `classification'
collapse (count) one (sum) specificdrug (mean) avgtotpaypd=imputed_totalpay (sum) imputed_totalpay (sum) imputed_inspay (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost, by(plancode year month) fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace one =one*1.46895 if year==2002 & month==12 & plancode==5
replace one =one*1.47155 if year==2002 & month==12 & plancode==6
replace one =one*1.4707  if year==2002 & month==12 & plancode==7
replace one =one*1.4673  if year==2002 & month==12 & plancode==8
replace specificdrug=specificdrug*1.46895 if year==2002 & month==12 & plancode==5
replace specificdrug=specificdrug*1.47155 if year==2002 & month==12 & plancode==6
replace specificdrug=specificdrug*1.4707  if year==2002 & month==12 & plancode==7
replace specificdrug=specificdrug*1.4673  if year==2002 & month==12 & plancode==8
replace imputed_totalpay =imputed_totalpay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_totalpay =imputed_totalpay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_totalpay =imputed_totalpay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_totalpay =imputed_totalpay*1.4673  if year==2002 & month==12 &  plancode==8

replace imputed_inspay =imputed_inspay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_inspay =imputed_inspay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_inspay =imputed_inspay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_inspay =imputed_inspay*1.4673  if year==2002 & month==12 &  plancode==8

rename copay copayby`classification'
rename modalcopay02 modalcopayby`classification'
rename modalcopay02retail modalcopay02retailby`classification'
rename meancopaypost meancopaypostby`classification'
sort plancode year month 

save erplanby`classification', replace
}




* collapse data for drug use by AGE & chronic disease cohorts-- note that they're NOT mutually exclusive (this is coding of CHRONIC by AGE: Diff from code above!)
* First create plan*month level data by class, name, and importance of drug
clear
foreach classification in nochronic somechronic depression hypertension hyperchol asthma gastritis  diabetes arthritis  {
use drugs if `classification'==1
gen specificdrug=0
do `classification'
collapse (count) one (sum) specificdrug (mean) avgtotpaypd=imputed_totalpay (sum) imputed_totalpay (sum) imputed_inspay (mean) copay (mean) modalcopay02 (mean) modalcopay02retail (mean) meancopaypost, by(plancode year month agegroup) fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace one =one*1.46895 if year==2002 & month==12 & plancode==5
replace one =one*1.47155 if year==2002 & month==12 & plancode==6
replace one =one*1.4707  if year==2002 & month==12 & plancode==7
replace one =one*1.4673  if year==2002 & month==12 & plancode==8
replace specificdrug=specificdrug*1.46895 if year==2002 & month==12 & plancode==5
replace specificdrug=specificdrug*1.47155 if year==2002 & month==12 & plancode==6
replace specificdrug=specificdrug*1.4707  if year==2002 & month==12 & plancode==7
replace specificdrug=specificdrug*1.4673  if year==2002 & month==12 & plancode==8
replace imputed_totalpay =imputed_totalpay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_totalpay =imputed_totalpay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_totalpay =imputed_totalpay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_totalpay =imputed_totalpay*1.4673  if year==2002 & month==12 &  plancode==8

replace imputed_inspay =imputed_inspay*1.46895 if year==2002 & month==12 & plancode==5
replace imputed_inspay =imputed_inspay*1.47155 if year==2002 & month==12 & plancode==6
replace imputed_inspay =imputed_inspay*1.4707  if year==2002 & month==12 &  plancode==7
replace imputed_inspay =imputed_inspay*1.4673  if year==2002 & month==12 &  plancode==8

rename copay copayby`classification'
rename modalcopay02 modalcopayby`classification'
rename modalcopay02retail modalcopay02retailby`classification'
rename meancopaypost meancopaypostby`classification'
sort plancode year month 

save erplanby`classification'_age, replace
}



* collapse data to plancode x month x importance x person  level for intensive and extensive margin coding-- then aggregate to plancode x month x importance level
use drugs 
gen one=1
collapse (count) one , by(plancode year month importance personid) fast
* when data are collapsed no obs will be created for beneficiaries with zero use, but verify that:
drop if one==0 | one==.
sort plancode year month importance personid
by   plancode year month importance: gen npersons=_N
gen drugint=.
replace drugint=one if one>0 & one!=.
* Now aggregate to the plan-month-importance level
collapse (count) drugint (max) npersons, by(plancode year month importance) fast
* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
replace drugint =drugint*1.46895 if year==2002 & month==12 & plancode==5
replace drugint =drugint*1.47155 if year==2002 & month==12 & plancode==6
replace drugint =drugint*1.4707  if year==2002 & month==12 & plancode==7
replace drugint =drugint*1.4673  if year==2002 & month==12 & plancode==8
sort plancode year month importance
save erdrugsforintensive, replace

* collapse data to plancode x month  x person  level for  extensive margin coding across all drugs 
use drugs 
gen one=1
collapse (count) one , by(plancode year month personid) fast
* when data are collapsed no obs will be created for beneficiaries with zero use, but verify that:
drop if one==0 | one==.
sort plancode year month  personid
by   plancode year month: gen npersons_all=_N
* Now aggregate to the plan-month level (this is across all categories of importance, so there's no need to add importance)
collapse  (max) npersons_all, by(plancode year month) fast
sort plancode year month 
save erdrugsforextensive, replace



* define some vars for revision: Define 4 groups of people in the pre-period: those who only took formulary drugs, those who took only generics, took both and took neither. idea is to look at each group and look at switching into the other groups. 
use drugs 
count
gen formulary=drugtier>1  
gen generic=drugtier==1 
gen hmoformulary=hmodrugtier>1  
gen hmogeneric=hmodrugtier==1 

* at this point, we have a drug level dataset: aggregate to person level
collapse (sum) one (sum) formulary (sum) generic  (sum) hmoformulary (sum) hmogeneric (mean) plancode, by(year month personid) fast
count
fillin year month personid
count
* drop extra months created in 2003
drop if year==2003 & month>9
count
egen tr=min(plancode), by(personid)
replace plancode=tr if _fillin==1
for var one formulary generic hmoformulary hmogeneric  : replace X=0 if _fillin==1 

* data is now at person month level, and contains the sum of total, formulary and generic utiliation at the person month level.
* Now classify each person in each month as being in one of 4 categories.
gen rx_none=one==0
gen rx_both=formulary>0 & generic>0 
gen rx_form=formulary>0 & generic==0 
gen rx_generic=formulary==0 & generic>0 


gen hmorx_none=one==0
gen hmorx_both=hmoformulary>0 & hmogeneric>0 
gen hmorx_form=hmoformulary>0 & hmogeneric==0 
gen hmorx_generic=hmoformulary==0 & hmogeneric>0 

egen timetrend=group (year month)
gen postppo=timetrend>13
gen posthmo=timetrend>24
gen preppo=!postppo
gen prehmo=!posthmo

* Need to impute values of drugclaims for Dec. 2002 between Dec. 21 & Dec. 31 (in PPOs), based on the historical ratio of December's total to the Dec. 1-Dec. 20 total for each plan. 
* The program that generated these ratios is drugimpute.do.  Ratios are the average of the 2000 and 2001 ratios for each plan.
foreach var of varlist one rx_none rx_both rx_form rx_generic hmorx_none hmorx_both hmorx_form hmorx_generic {
replace `var' =`var' *1.46895 if year==2002 & month==12 & plancode==5
replace `var'  =`var' *1.47155 if year==2002 & month==12 & plancode==6
replace `var'  =`var' *1.4707  if year==2002 & month==12 & plancode==7
replace `var'  =`var' *1.4673  if year==2002 & month==12 & plancode==8
}
* we don't have plancode 3/4 data for the first year. Drop these obs.
drop if (plancode==3|plancode==4) & (timetrend<=12)
save tmp, replace

* in the collapse below, use "sum" and not mean, and we'll be dividing by nobs later.
* it's tempting to use mean below because there is an obs for each person. While true, we've created an obs for each person even in plans where that person isn't enrolled.
* In other words, because we don't have equal numbers of people in each plan. Using means would be wrong.

collapse (sum) one (sum) rx_none (sum) rx_both (sum) rx_form (sum) rx_generic (sum) hmorx_none (sum) hmorx_both (sum) hmorx_form (sum) hmorx_generic, by(plancode year month) fast
* In the data below, if we divide by #persons in a plan, we get the probability of being in one of the different states (only generic, only form, both and neither).
save erdrugsforswitching, replace




