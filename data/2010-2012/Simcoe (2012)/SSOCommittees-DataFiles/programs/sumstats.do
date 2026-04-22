log using tables/sumtables.log, replace
**************************
*   Table 1: Cohort Outcomes
**************************
bysort wg pubCohort : gen wgFlag = (_n==1)
tab pubCohort if wgFlag
tab pubCohort exiType

tabstat ttlDur if (exiType == 4), by(pubCohort) stats(mean median) format(%9.0f)
tabstat ttlDur if (exiType == 3), by(pubCohort) stats(mean median) format(%9.0f)
tabstat ttlDur if (exiType == 2), by(pubCohort) stats(mean median) format(%9.0f)


**************************
*   Table 2: Summary Stats
**************************
qui tab techarea, gen(adum)
replace rfcCites = . if !rfcDum
replace patCites = . if !rfcDum
replace pubCites = . if !rfcDum

local topPanel ttlDur age logEmails strfc nsrfc rfcCites patCites pubCites logPages anyKeys lKeys
local midPanel stbafl1yr lwgipr orgDum eduDum othDum  
local botPanel pubCohort lmsgs lcmsgs lwgidnow lwgidttl lwgorgs lsize n_affil priorwgc comNet govDum adum1 adum2 adum3 adum4 adum5 adum6 

format %8.2f `topPanel' `midPanel' `botPanel'
sum `topPanel' `midPanel' `botPanel', f sep(0)


**************************
*   Table 3: Matching
**************************
local testVars ttlDur age logEmails rfcCites patCites pubCites anyKeys lKeys logPages stbafl1yr lwgipr orgDum eduDum  othDum pubCohort lmsgs lcmsgs lwgidnow lwgidttl lwgorgs lsize n_affil priorwgc govDum comNet
local XVars stbafl1yr lwgipr orgDum eduDum othDum pubCohort lmsgs lcmsgs lwgidnow lwgidttl lwgorgs lsize n_affil priorwgc govDum comNet

*** Full Sample
display "T-tests for PS=NST"
foreach X in `testVars' {
	quietly ttest `X' if (exiType>2 & cSample == 1 & stbafl1yr!=.), by(exiType) unpaired unequal
	display %9.2f r(mu_2)-r(mu_1) %9.2f r(mu_1) %9.2f r(mu_2)  %9.2f r(p) "  `X'"
}
tab strfc if (exiType>2 & cSample == 1 & stbafl1yr!=.)
hotelling `XVars'  if (strfc|nsrfc) & cSample == 1, by(strfc) notable

*** Matched Sample
display "T-tests for PS=NST"
foreach X in `testVars' {
	quietly ttest `X' if (exiType>2 & match_samp2==1 & cSample == 1), by(exiType) unpaired unequal
	display %9.2f r(mu_2)-r(mu_1) %9.2f r(mu_1) %9.2f r(mu_2)  %9.2f r(p) "  `X'"
}
tab strfc if (exiType>2 & match_samp2 & cSample == 1)
hotelling `XVars'  if (strfc|nsrfc) & match_samp2==1 & cSample == 1, by(strfc) notable
log close

*** Working Group Publication Count Stats ***
bysort wg: gen fwg = (_n==1)
by wg : egen wgidttl = sum(1)
by wg : egen wgrfcttl = sum(exiType>=3)
by wg : egen wgstrfc = sum(exiType==4)
by wg : egen wgnsrfc = sum(exiType==3)

replace wgidttl  = 15 if wgidttl >15
replace	wgrfcttl = 15 if wgrfcttl >15
replace	wgstrfc  = 5 if wgstrfc > 5
replace	wgnsrfc  = 5 if wgnsrfc >5

tab wgidttl if fwg
tab wgrfcttl if fwg

log using tables/wgRfcCounts.log, replace
tab wgstrfc wgnsrfc if fwg
log close
