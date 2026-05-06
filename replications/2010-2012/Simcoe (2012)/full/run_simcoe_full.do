* =============================================================================
* Simcoe (2012)
* Standard Setting Committees: Consensus Governance for Shared Technology Platforms
* AER, 102(1), 305-336
* FULL REPLICATION: Main tables and robustness
* =============================================================================

clear all
set more off
set maxvar 10000
set matsize 2000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Simcoe (2012)/SSOCommittees-DataFiles"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Simcoe (2012)/full"

* Install required packages
cap which ivreg2
if _rc ssc install ivreg2, replace
cap which ranktest
if _rc ssc install ranktest, replace
cap which estout
if _rc ssc install estout, replace

* Create output subdirectories
cap mkdir "$outdir/tables"
cap mkdir "$outdir/figures"

cd "$datadir"

log using "$outdir/run_simcoe_full.log", text replace

* =============================================================================
* SAMPLE DEFINITION (from analysis.do)
* =============================================================================
di _n "===== SAMPLE DEFINITION ====="

use data/idLevel, clear

* Exclude General & User Services Area WGs
drop if (techarea == 0 | techarea == 2 | techarea == 9)
* Drop BCPs, Historic RFCs, Draft Standards & Internet Standards
drop if (rfctype == 1 | rfctype == 2 | rfctype == 7 | rfctype == 4)
* Keep IDs with Revisions >=1
keep if (age>1)
* Main Sample: Working Group IDs with reliable Email Data
drop if (!wgDum | pubCohort < 1993 | pubCohort > 2003)
* Dummy for Robustness to Censoring
gen cSample = (pubCohort <= 2002 & ttlDur <= 2007)

* Variable Creation
replace ttlDur = ttlDur+15
gen lnDur = log(ttlDur)

* ID-Level Variables
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

* WG-Level Variables
gen lwgidnow = ln(1+wgIdNow)
gen lwgidttl = ln(1+wgIdCnt)
gen lwgipr = ln(1+cumWgIpr)
gen lmsgs = ln(1+ttlmsg1yr)
gen lcmsgs = ln(1+cummsgs)
gen lwgorgs = ln(1+cumWgOrg2)

* RFC-Level Variables
g ttlCites = patCites + pubCites + rfcCites
g logPages = log(1+rfcPages)
g logAllCites = log(1+ttlCites)
g logPatCites = log(1+patCites)
g logPubCites = log(1+pubCites)
g logRfcCites = log(1+rfcCites)
g logBackCites = log(1+backCites)
g logStBackCites = log(1+stBackCites)
g logNsBackCites = log(1+nsBackCites)

* Standards-Track Interactions
foreach VAR in stbafl1yr stbusr1yr stbmsg1yr stbaflcum stbaflrpl stbaflall logEmails stbEmail lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs n_affil priorwgc lsize size2 orgDum eduDum govDum othDum logBackCites logPages pubCohort collab lnDur stbLagAfl aut2 aut3 {
    qui gen st_`VAR' = (1-nsrfc) * `VAR'
}

* Cohorts and Group-Level Dummies
egen areaYr = group(techarea pubCohort)
egen areaType = group(techarea strfc)
g rfcYr = yofd(dofm(monthly(rfcPubDate,"my")))
bysort wg : egen wgCohort = min(yofd(date))
sort series

di _n "Sample size: "
count
di "Standards-track:"
count if strfc
di "Non-standards:"
count if nsrfc

* =============================================================================
* MATCHING (from programs/matching.do)
* =============================================================================
di _n "===== PROPENSITY SCORE MATCHING ====="

replace stbLagUsr = 100 * stbLagUsr
g pubC2 = (pubCohort - 1993)^2
g wgC2 = (wgCohort - 1993)^2
g cumId2 = lwgidttl^2
g cumMsg2 = lcmsgs^2
g Id2 = lwgidnow^2
g Msg2 = lmsgs^2

local wgvars stbafl1yr stbLagUsr lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs cumId2 cumMsg2 Id2
local idvars n_affil priorwgc lsize orgDum eduDum govDum
local rfcvars logPages logBackCites logEmails stbEmail obsDum updDum lwgipr lwgidnow lwgidttl lwgorgs

qui xi: probit strfc `wgvars' `idvars' i.techarea pubCohort pubC2 wgCohort wgC2 if ((strfc|nsrfc) & cSample == 1), robust
predict yhat
g psw = yhat
replace psw = 1-psw if nsrfc

quietly summ yhat if (strfc & ttlDur<=2007 & e(sample)), d
gen lbar = r(p1)
gen lbar2 = r(p5)
quietly summ yhat if (nsrfc & ttlDur<=2007 & e(sample)), d
gen ubar = r(p99)
gen ubar2 = r(p95)
gen match_samp1 = ((yhat > lbar) & (yhat < ubar))
gen match_samp2 = ((yhat > lbar2) & (yhat < ubar2))

drop ubar* lbar* yhat

* =============================================================================
* MAIN TABLE (Table 4 in paper) - OLS Main Regressions
* =============================================================================
di _n "===== MAIN TABLE: OLS REGRESSIONS ====="

local controls lsize lcmsgs lwgidnow aut2 aut3
local st_controls st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3

log using "$outdir/tables/olsMainRegs.log", text replace name(main)

* Col 1: Straight OLS Diff-in-diffs
di _n "--- Col 1: OLS Diff-in-Diffs ---"
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample==1), cluster(wg)
est store col1
tab strfc if e(sample)
di "R-square: " %8.4f e(r2)
di "N: " e(N)

* Col 2: P-score Matched Diff-in-diffs
di _n "--- Col 2: Matched Diff-in-Diffs ---"
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & match_samp2 & cSample==1), cluster(wg)
est store col2
tab strfc if e(sample)
di "R-square: " %8.4f e(r2)

* Col 3: Matched Diff-diffs with WG FEs
di _n "--- Col 3: WG Fixed Effects ---"
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & match_samp2 & cSample==1), fe i(wg) robust
est store col3
tab strfc if e(sample)
di "R-square: " %8.4f e(r2)

* Col 5: RE Standards Only
di _n "--- Col 5: Standards Only RE ---"
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum `controls' i.pubCohort i.techarea if ((strfc) & cSample==1), re i(wg) cluster(wg)
est store col5
di "R-square: " %8.4f e(r2)

estout col1 col2 col3 col5, cells(b(fmt(1)) se(par fmt(1) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I* strfc _cons) style(tex) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)

log close main

* =============================================================================
* SUMMARY STATISTICS (Tables 1-3)
* =============================================================================
di _n "===== SUMMARY STATISTICS ====="

log using "$outdir/tables/sumstats.log", text replace name(summ)

* Table 1: Cohort outcomes
bysort wg pubCohort : gen wgFlag = (_n==1)
tab pubCohort if wgFlag
tab pubCohort exiType
tabstat ttlDur if (exiType == 4), by(pubCohort) stats(mean median) format(%9.0f)
tabstat ttlDur if (exiType == 3), by(pubCohort) stats(mean median) format(%9.0f)

* Table 2: Summary stats
qui tab techarea, gen(adum)
replace rfcCites = . if !rfcDum
replace patCites = . if !rfcDum
replace pubCites = . if !rfcDum

local topPanel ttlDur age logEmails strfc nsrfc rfcCites patCites pubCites logPages anyKeys lKeys
local midPanel stbafl1yr lwgipr orgDum eduDum othDum
local botPanel pubCohort lmsgs lcmsgs lwgidnow lwgidttl lwgorgs lsize n_affil priorwgc comNet govDum

format %8.2f `topPanel' `midPanel' `botPanel'
sum `topPanel' `midPanel' `botPanel', f sep(0)

* Table 3: Matching balance
local testVars ttlDur age logEmails rfcCites patCites pubCites anyKeys lKeys logPages stbafl1yr lwgipr orgDum eduDum othDum pubCohort lmsgs lcmsgs lwgidnow lwgidttl lwgorgs lsize n_affil priorwgc govDum comNet

di _n "--- Full Sample Balance ---"
foreach X in `testVars' {
    quietly ttest `X' if (exiType>2 & cSample == 1 & stbafl1yr!=.), by(exiType) unpaired unequal
    display %9.2f r(mu_2)-r(mu_1) %9.2f r(mu_1) %9.2f r(mu_2) %9.2f r(p) "  `X'"
}

di _n "--- Matched Sample Balance ---"
foreach X in `testVars' {
    quietly ttest `X' if (exiType>2 & match_samp2==1 & cSample == 1), by(exiType) unpaired unequal
    display %9.2f r(mu_2)-r(mu_1) %9.2f r(mu_1) %9.2f r(mu_2) %9.2f r(p) "  `X'"
}

log close summ

* =============================================================================
* ROBUSTNESS: Alternative STB Measures
* =============================================================================
di _n "===== ROBUSTNESS: Alternative STB ====="

log using "$outdir/tables/olsRobustSTB.log", text replace name(rob)

* Alternative STB cross-sectional
qui xi: reg ttlDur st_lwgipr st_othDum lwgipr othDum st_stbEmail stbEmail `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store altcol1
qui xi: xtreg ttlDur st_lwgipr st_othDum lwgipr othDum st_stbEmail stbEmail `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), fe i(wg) robust
est store altcol2

estout altcol1 altcol2, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)

log close rob

* =============================================================================
* ROBUSTNESS: Alternative DVs
* =============================================================================
di _n "===== ROBUSTNESS: Alternative DVs ====="

log using "$outdir/tables/olsRobustDV.log", text replace name(dv)

replace stbafl1yr = stbafl1yr/100
replace st_stbafl1yr = st_stbafl1yr/100

qui xi: reg age st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store dv1
qui xi: xtreg age st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), fe i(wg) r
est store dv2
qui xi: reg lnDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store dv3
qui xi: xtreg lnDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), fe i(wg) robust
est store dv4

estout dv1 dv2 dv3 dv4, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)

replace stbafl1yr = stbafl1yr*100
replace st_stbafl1yr = st_stbafl1yr*100

log close dv

* =============================================================================
* INTERACTIONS: Tech Area & Cohort
* =============================================================================
di _n "===== INTERACTIONS ====="

log using "$outdir/tables/olsInteractions.log", text replace name(inter)

decode techarea, gen(areaName)
replace areaName = "ops" if areaName == "o&m"

gen stb_org = stbafl1yr*orgDum
gen stb_edu = stbafl1yr*eduDum
gen st_stborg = stb_org * strfc
gen st_stbedu = stb_edu * strfc

g nsEffect = stbafl1yr
foreach area in app int ops rtg sec tsv {
    qui gen stXarea_`area' = stbafl1yr * strfc * (areaName == "`area'")
    qui gen nsXarea_`area' = stbafl1yr * (areaName == "`area'")
}

g yrGrp = 1993 + 2 * floor((pubCohort - 1993)/2)
forval yr = 1993(2)2001 {
    gen stStb_`yr' = stbafl1yr * strfc * (yrGrp == `yr')
    gen nsStb_`yr' = stbafl1yr * (yrGrp == `yr')
}

* Org/Edu interactions
di _n "--- Organization/Education Interactions ---"
qui xi: reg ttlDur st_stbafl1yr st_orgDum st_stborg st_eduDum st_stbedu `st_controls' i.pubCohort i.techarea if ((strfc) & cSample==1), cluster(wg)
est store int1

qui xi: reg ttlDur st_stbafl1yr st_orgDum st_stborg st_eduDum st_stbedu stbafl1yr orgDum eduDum strfc stb_org stb_edu `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample==1), cluster(wg)
est store int2

* TechArea interactions
di _n "--- Tech Area Interactions ---"
qui xi: reg ttlDur stXarea_* st_othDum `st_controls' i.pubCohort i.techarea if ((strfc) & cSample), cluster(wg)
est store int3

qui xi: reg ttlDur stXarea_* nsXarea_* othDum st_othDum `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample), cluster(wg)
est store int4

* Cohort interactions
di _n "--- Cohort Interactions ---"
qui xi: reg ttlDur stStb_* othDum `controls' i.pubCohort i.techarea if (strfc & cSample), cluster(wg)
est store int5

qui xi: reg ttlDur stStb_* nsStb_* othDum st_othDum `controls' `st_controls' i.pubCohort*strfc i.techarea if ((strfc|nsrfc) & cSample), cluster(wg)
est store int6

estout int1 int2 int3 int4 int5 int6, cells(b(fmt(1)) se(par fmt(1) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(strfc st_stbafl1yr stbafl1yr st_orgDum st_eduDum orgDum eduDum othDum st_othDum stb_* _I* _cons `controls' `st_controls' nsXarea_* nsStb_*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)

log close inter

di _n "===== ALL TABLES COMPLETE ====="

cap log close _all
