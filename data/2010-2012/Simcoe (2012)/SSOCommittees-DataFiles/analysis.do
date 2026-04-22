clear all
set mem 600M
set matsize 600
set more off
capture log close

******** Sample Definition *******
use data/idLevel

* Exclude General & User Services Area WG's
drop if (techarea == 0 | techarea == 2 | techarea == 9)
* Drop BCP's, Historic RFCs, Draft Standards & Internet Standards
drop if (rfctype == 1 | rfctype == 2 | rfctype == 7 | rfctype == 4)
* Keep IDs with Revisions >=1
keep if (age>1)

* Main Sample: Working Group IDs with reliable Email Data
drop if (!wgDum | pubCohort < 1993 | pubCohort > 2003)

* Dummy for Robustness to Censoring of DV (Truncated at 5.5 Years)
gen cSample = (pubCohort <= 2002 & ttlDur <= 2007)

******** Variable Creation *******
* Dependent Variables
replace ttlDur = ttlDur+15
gen lnDur = log(ttlDur)

** ID-Level Variables
* Taking Logs
g lsize = ln(1+filesize)
g size2 = lsize^2
g lKeys = log(1+rfcKeyCnt)
g anyKeys = (rfcKeyCnt>0)
g logEmails = ln(1+idTtlMentions)

* Affiliation Dummies
g orgDum = (n_org > 0)
g eduDum = (n_edu > 0)
g govDum = (n_gov > 0)
gen comNet = (n_com>0 | n_net>0)
g othDum = max(eduDum, orgDum)
g nonUS = (!usAuth & forAuth)
g collab = (n_affil>1)
g aut2 = n_affil==2
g aut3 = n_affil>2

** WG-Level Variables
gen lwgidnow = ln(1+wgIdNow)
gen lwgidttl = ln(1+wgIdCnt)
gen lwgipr = ln(1+cumWgIpr)
gen lmsgs = ln(1+ttlmsg1yr)
gen lcmsgs = ln(1+cummsgs)
gen lwgorgs = ln(1+cumWgOrg2)

** RFC-Level Variables
g ttlCites = patCites + pubCites + rfcCites
g logPages = log(1+rfcPages)
g logAllCites = log(1+ttlCites)
g logPatCites = log(1+patCites)
g logPubCites = log(1+pubCites)
g logRfcCites = log(1+rfcCites)
g logBackCites = log(1+backCites)
g logStBackCites = log(1+stBackCites)
g logNsBackCites = log(1+nsBackCites)

** Standards-Track Interactions
foreach VAR in stbafl1yr stbusr1yr stbmsg1yr stbaflcum stbaflrpl stbaflall logEmails stbEmail lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs n_affil priorwgc lsize size2 orgDum eduDum govDum othDum logBackCites logPages pubCohort collab lnDur stbLagAfl aut2 aut3 {
	qui gen st_`VAR' = (1-nsrfc) * `VAR'
}

** Cohorts and Other Group-Level Dummies 
egen areaYr = group(techarea pubCohort)
egen areaType = group(techarea strfc)
g rfcYr = yofd(dofm(monthly(rfcPubDate,"my")))
bysort wg : egen wgCohort = min(yofd(date))
sort series


******** Regression Models *********
do programs/matching
do programs/olsMainRegs
do programs/olsRobust
do programs/olsInteractions
do programs/endogSwitch

***** Summary Stats & Figures ******
do programs/sumstats
do programs/figures

***** Appendices ******/
do programs/citeCounts
do programs/refExtras
