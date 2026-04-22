**** Variable Creation ****
g lnAge = log(age)
g st_lnAge = lnAge * (1-nsrfc)
g rfcSample = (rfcYr<=2005 & rfcYr>=1994 & stbafl1yr !=.)
capture g lnStb = log(stbafl1yr)
capture g st_lnStb = lnStb * (1-nsrfc)
capture g lnStbEmail = log(stbEmail)
capture g st_lnStbEmail = lnStbEmail * (1-nsrfc)

local controls n_affil lsize priorwgc 
local st_controls st_n_affil st_lsize st_priorwgc

*** Time-Since-Publication-as-RFC Polynomial
g ctM1 = monthly("Jun2008","my") - monthly(rfcPubDate,"my")
g ctM2 = ctM1^2 
g ctM3 = ctM1^3
g ctM4 = ctM1^4

drop if (!strfc & !nsrfc)

gsort wg -date
by wg : g futRfcs = sum(1)
by wg : egen totMonths = sum(ctM1)
by wg : egen totRFC = sum(1)
by wg : egen totCites = sum(ttlCites)
g cpmOth = log((totCites - ttlCites + 1) / (totMonths-ctM1))

log using tables/citeCounts.log, replace

***********************
*   Poisson Models    *
***********************
qui xi: poisson ttlCites lnStb st_lnStb logEmails cpmOth ctM* i.techarea i.pubCohort*strfc `controls' `st_controls' if ((strfc|nsrfc) & rfcSample), cluster(wg)
est store col1
qui testparm _Itech*
display  "techArea Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm ctM*
display  "PubMonth Effect    " %8.2f r(p)   %8.2f r(df) 
qui testparm `controls' `st_controls'
display  "Controls Effect    " %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)
test lnStb + st_lnStb = 0

qui xi: poisson ttlCites lnDur st_lnDur logEmails cpmOth ctM* i.techarea i.pubCohort*strfc `controls' `st_controls'  if ((strfc|nsrfc) & rfcSample), cluster(wg)
est store col2
qui testparm _Itech*
display  "techArea Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm ctM*
display  "PubMonth Effect    " %8.2f r(p)   %8.2f r(df) 
qui testparm `controls' `st_controls'
display  "Controls Effect    " %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)
test lnDur + st_lnDur = 0 

qui xi: poisson ttlCites lnStb st_lnStb lnDur st_lnDur logEmails cpmOth ctM* i.techarea i.pubCohort*strfc `controls' `st_controls'  if ((strfc|nsrfc) & rfcSample), cluster(wg)
est store col3
qui testparm _Itech*
display  "techArea Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm ctM*
display  "PubMonth Effect    " %8.2f r(p)   %8.2f r(df) 
qui testparm `controls' `st_controls'
display  "Controls Effect    " %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)

*************************
*   WG Fixed Effects    *
*************************

qui xi: xtpqml ttlCites st_lnStb lnStb logEmails ctM* i.pubCohort*strfc `controls' `st_controls' if ((strfc|nsrfc) & rfcSample), fe i(wg)
est store col4
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm ctM*
display  "PubMonth Effect    " %8.2f r(p)   %8.2f r(df) 
qui testparm `controls' `st_controls'
display  "Controls Effect    " %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)
test lnStb + st_lnStb = 0

qui xi: xtpqml ttlCites st_lnDur lnDur logEmails ctM* i.pubCohort*strfc `controls' `st_controls'  if ((strfc|nsrfc) & rfcSample), fe i(wg)
est store col5
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm ctM*
display  "PubMonth Effect    " %8.2f r(p)   %8.2f r(df) 
qui testparm `controls' `st_controls'
display  "Controls Effect    " %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)
test lnDur + st_lnDur = 0 

qui xi: xtpqml ttlCites st_lnStb lnStb st_lnDur lnDur logEmails ctM* i.pubCohort*strfc `controls' `st_controls'  if ((strfc|nsrfc) & rfcSample), fe i(wg)
est store col6
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(p)   %8.2f r(df) 
qui testparm ctM*
display  "PubMonth Effect    " %8.2f r(p)   %8.2f r(df) 
qui testparm `controls' `st_controls'
display  "Controls Effect    " %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 ll df_m N_g, fmt(0 %8.2f 0 0)) drop(_I* ctM* `controls' `st_controls' strfc) order(lnStb st_lnStb lnDur st_lnDur cpmOth logEmails) style(tex)

log close

