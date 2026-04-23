/*==============================================================================
  Simcoe (2012) — "Standard Setting Committees"
  AER 102(1), 305-336

  Replication of Table 4 Cols 1-3 + twowayfeweights decomposition
  dCDH Web Appendix #21: Table 4, Cols 1-3
    Regression 1 with controls. Sharp design. Stable groups NOT satisfied.

  Treatment: Suit-share × S-track interaction (st_stbafl1yr)
  Y: ttlDur (days from submission to disposal)
  G: techarea (Cols 1-2) / wg (Col 3)
  T: pubCohort (submission year)
==============================================================================*/

clear all
set more off
cap log close _all

* ---------- Paths ---------------------------------------------------------
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Simcoe (2012)/SSOCommittees-DataFiles"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Simcoe (2012)"

cap log using "$outdir/run_twowayfe_detail.log", text replace name(detail)

* ==========================================================================
*  1. DATA PREPARATION  (from analysis.do)
* ==========================================================================
use "$datadir/data/idLevel", clear

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

* --- Variable Creation ---
replace ttlDur = ttlDur+15
gen lnDur = log(ttlDur)

* ID-Level Variables
gen lsize = ln(1+filesize)
gen size2 = lsize^2
gen lKeys = log(1+rfcKeyCnt)
gen anyKeys = (rfcKeyCnt>0)
gen logEmails = ln(1+idTtlMentions)

* Affiliation Dummies
gen orgDum = (n_org > 0)
gen eduDum = (n_edu > 0)
gen govDum = (n_gov > 0)
gen comNet = (n_com>0 | n_net>0)
gen othDum = max(eduDum, orgDum)
gen nonUS = (!usAuth & forAuth)
gen collab = (n_affil>1)
gen aut2 = n_affil==2
gen aut3 = n_affil>2

* WG-Level Variables
gen lwgidnow = ln(1+wgIdNow)
gen lwgidttl = ln(1+wgIdCnt)
gen lwgipr = ln(1+cumWgIpr)
gen lmsgs = ln(1+ttlmsg1yr)
gen lcmsgs = ln(1+cummsgs)
gen lwgorgs = ln(1+cumWgOrg2)

* RFC-Level Variables
gen ttlCites = patCites + pubCites + rfcCites
gen logPages = log(1+rfcPages)
gen logAllCites = log(1+ttlCites)
gen logPatCites = log(1+patCites)
gen logPubCites = log(1+pubCites)
gen logRfcCites = log(1+rfcCites)
gen logBackCites = log(1+backCites)
gen logStBackCites = log(1+stBackCites)
gen logNsBackCites = log(1+nsBackCites)

* Standards-Track Interactions
foreach VAR in stbafl1yr stbusr1yr stbmsg1yr stbaflcum stbaflrpl stbaflall ///
    logEmails stbEmail lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs n_affil ///
    priorwgc lsize size2 orgDum eduDum govDum othDum logBackCites logPages ///
    pubCohort collab lnDur stbLagAfl aut2 aut3 {
    qui gen st_`VAR' = (1-nsrfc) * `VAR'
}

* Cohorts and Other Group-Level Dummies
egen areaYr = group(techarea pubCohort)
egen areaType = group(techarea strfc)
cap gen rfcYr = yofd(dofm(monthly(rfcPubDate,"my")))
bysort wg : egen wgCohort = min(yofd(date))
sort series

* ==========================================================================
*  2. MATCHING  (from matching.do)
* ==========================================================================
replace stbLagUsr = 100 * stbLagUsr
gen pubC2 = (pubCohort - 1993)^2
gen wgC2 = (wgCohort - 1993)^2
gen cumId2 = lwgidttl^2
gen cumMsg2 = lcmsgs^2
gen Id2 = lwgidnow^2
gen Msg2 = lmsgs^2

local wgvars stbafl1yr stbLagUsr lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs cumId2 cumMsg2 Id2
local idvars n_affil priorwgc lsize orgDum eduDum govDum

qui xi: probit strfc `wgvars' `idvars' i.techarea pubCohort pubC2 wgCohort wgC2 ///
    if ((strfc|nsrfc) & cSample == 1), robust
predict yhat

quietly summ yhat if (strfc & ttlDur<=2007 & e(sample)), d
gen lbar2 = r(p5)
quietly summ yhat if (nsrfc & ttlDur<=2007 & e(sample)), d
gen ubar2 = r(p95)
gen match_samp2 = ((yhat > lbar2) & (yhat < ubar2))

drop lbar2 ubar2 yhat

* ==========================================================================
*  3. TABLE 4 REPLICATION — Cols 1, 2, 3
* ==========================================================================
local controls    lsize lcmsgs lwgidnow aut2 aut3
local st_controls st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3

di _n "=============================================="
di    "  TABLE 4 — REPLICATION"
di    "=============================================="

* --- Col 1: Full OLS Diff-in-diffs ---
di _n ">>> Col 1: Full OLS <<<"
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    `st_controls' `controls' i.techarea i.pubCohort strfc ///
    if ((strfc|nsrfc) & cSample==1), cluster(wg)
est store col1
di "  st_stbafl1yr = " %8.4f _b[st_stbafl1yr] "  SE = " %8.4f _se[st_stbafl1yr]
di "  N = " e(N) "  R2 = " %6.4f e(r2)

* --- Col 2: Matched OLS Diff-in-diffs ---
di _n ">>> Col 2: Matched OLS <<<"
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    `st_controls' `controls' i.techarea i.pubCohort strfc ///
    if ((strfc|nsrfc) & match_samp2 & cSample==1), cluster(wg)
est store col2
di "  st_stbafl1yr = " %8.4f _b[st_stbafl1yr] "  SE = " %8.4f _se[st_stbafl1yr]
di "  N = " e(N) "  R2 = " %6.4f e(r2)

* --- Col 3: Matched OLS with WG FEs ---
di _n ">>> Col 3: Matched FE <<<"
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    `st_controls' `controls' i.pubCohort strfc ///
    if ((strfc|nsrfc) & match_samp2 & cSample==1), fe i(wg) robust
est store col3
di "  st_stbafl1yr = " %8.4f _b[st_stbafl1yr] "  SE = " %8.4f _se[st_stbafl1yr]
di "  N = " e(N) "  N_g = " e(N_g) "  R2 = " %6.4f e(r2)

* ==========================================================================
*  4. TWOWAYFEWEIGHTS — Col 1 (G=techarea, T=pubCohort)
* ==========================================================================
di _n "=============================================="
di    "  TWOWAYFEWEIGHTS DECOMPOSITION"
di    "=============================================="

* --- feTR for Col 1 (Full OLS, G=techarea) ---
di _n ">>> feTR — Col 1 (G=techarea, T=pubCohort, D=st_stbafl1yr) <<<"

preserve
keep if ((strfc|nsrfc) & cSample==1)
* Drop obs with missing values in any regression variable
foreach v in ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3 lsize lcmsgs lwgidnow aut2 aut3 strfc {
    drop if missing(`v')
}

cap noisily twowayfeweights ttlDur techarea pubCohort st_stbafl1yr, type(feTR) ///
    controls(st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3 ///
    lsize lcmsgs lwgidnow aut2 aut3 strfc) summary_measures
local tw_rc_fe1 = _rc

if `tw_rc_fe1' == 0 | `tw_rc_fe1' == 402 {
    local tw_beta_fe1  = e(beta)
    mat _M1 = e(M)
    local tw_npos_fe1  = _M1[1,1]
    local tw_nneg_fe1  = _M1[2,1]
    local tw_pctN_fe1 : di %5.1f 100 * `tw_nneg_fe1' / (`tw_npos_fe1' + `tw_nneg_fe1')
    di "  beta_TWFE  = " %10.6f `tw_beta_fe1'
    di "  # pos wgts = " `tw_npos_fe1'
    di "  # neg wgts = " `tw_nneg_fe1'
    di "  % negative = " `tw_pctN_fe1' "%"
}
else {
    di "  feTR Col 1 FAILED with rc = `tw_rc_fe1'"
    local tw_beta_fe1  = .
    local tw_npos_fe1  = .
    local tw_nneg_fe1  = .
    local tw_pctN_fe1  = "---"
}
restore

* --- feTR for Col 3 (Matched FE, G=wg) ---
di _n ">>> feTR — Col 3 (G=wg, T=pubCohort, D=st_stbafl1yr) <<<"

preserve
keep if ((strfc|nsrfc) & match_samp2 & cSample==1)
foreach v in ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3 lsize lcmsgs lwgidnow aut2 aut3 strfc {
    drop if missing(`v')
}

cap noisily twowayfeweights ttlDur wg pubCohort st_stbafl1yr, type(feTR) ///
    controls(st_lwgipr st_othDum stbafl1yr lwgipr othDum ///
    st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3 ///
    lsize lcmsgs lwgidnow aut2 aut3 strfc) summary_measures
local tw_rc_fe3 = _rc

if `tw_rc_fe3' == 0 | `tw_rc_fe3' == 402 {
    local tw_beta_fe3  = e(beta)
    mat _M3 = e(M)
    local tw_npos_fe3  = _M3[1,1]
    local tw_nneg_fe3  = _M3[2,1]
    local tw_pctN_fe3 : di %5.1f 100 * `tw_nneg_fe3' / (`tw_npos_fe3' + `tw_nneg_fe3')
    di "  beta_TWFE  = " %10.6f `tw_beta_fe3'
    di "  # pos wgts = " `tw_npos_fe3'
    di "  # neg wgts = " `tw_nneg_fe3'
    di "  % negative = " `tw_pctN_fe3' "%"
}
else {
    di "  feTR Col 3 FAILED with rc = `tw_rc_fe3'"
    local tw_beta_fe3  = .
    local tw_npos_fe3  = .
    local tw_nneg_fe3  = .
    local tw_pctN_fe3  = "---"
}
restore

* ==========================================================================
*  5. LATEX TABLE — Table 4 Replication
* ==========================================================================
di _n "=============================================="
di    "  GENERATING LATEX TABLES"
di    "=============================================="

tempname fh
file open `fh' using "$outdir/table4_replication.tex", write replace

file write `fh' "\begin{table}[htbp]\centering" _n
file write `fh' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `fh' "\caption{Table 4---Conflict, Concessions, and Coordination Delay (Simcoe, 2012)}" _n
file write `fh' "\begin{tabular}{l*{3}{c}}" _n
file write `fh' "\toprule" _n
file write `fh' "            &\multicolumn{1}{c}{(1)}&\multicolumn{1}{c}{(2)}&\multicolumn{1}{c}{(3)}\\" _n
file write `fh' "            &  Full OLS  & Matched OLS & Matched FE \\" _n
file write `fh' "\midrule" _n

* Col 1
est restore col1
local b1 : di %8.1f _b[st_stbafl1yr]
local s1 : di %8.1f _se[st_stbafl1yr]
local p1 = 2*ttail(e(df_r), abs(_b[st_stbafl1yr]/_se[st_stbafl1yr]))
local st1 = cond(`p1'<.001,"****",cond(`p1'<.01,"***",cond(`p1'<.05,"**",cond(`p1'<.1,"*",""))))
local n1 = e(N)
local r1 : di %5.2f e(r2)

* Col 2
est restore col2
local b2 : di %8.1f _b[st_stbafl1yr]
local s2 : di %8.1f _se[st_stbafl1yr]
local p2 = 2*ttail(e(df_r), abs(_b[st_stbafl1yr]/_se[st_stbafl1yr]))
local st2 = cond(`p2'<.001,"****",cond(`p2'<.01,"***",cond(`p2'<.05,"**",cond(`p2'<.1,"*",""))))
local n2 = e(N)
local r2 : di %5.2f e(r2)

* Col 3
est restore col3
local b3 : di %8.1f _b[st_stbafl1yr]
local s3 : di %8.1f _se[st_stbafl1yr]
local p3 = 2*ttail(e(df_r), abs(_b[st_stbafl1yr]/_se[st_stbafl1yr]))
local st3 = cond(`p3'<.001,"****",cond(`p3'<.01,"***",cond(`p3'<.05,"**",cond(`p3'<.1,"*",""))))
local n3 = e(N)
local r3 : di %5.2f e(r2)
local ng3 = e(N_g)

file write `fh' "Suit-share $\times$ S-track & `b1'`st1' & `b2'`st2' & `b3'`st3' \\" _n
file write `fh' "            &  (`s1')  &  (`s2')  &  (`s3')  \\" _n
file write `fh' "\midrule" _n
file write `fh' "R-squared   & `r1' & `r2' & `r3' \\" _n
file write `fh' "Observations& `n1' & `n2' & `n3' \\" _n
file write `fh' "WG FEs      &  No  &  No  & `ng3' \\" _n
file write `fh' "Tech area FEs& Yes & Yes  &  No  \\" _n
file write `fh' "Cohort FEs  & Yes  & Yes  & Yes  \\" _n
file write `fh' "Matched sample& No & Yes  & Yes  \\" _n
file write `fh' "\bottomrule" _n
file write `fh' "\multicolumn{4}{p{0.9\textwidth}}{\footnotesize " _n
file write `fh' "Dependent variable: total days from submission to disposal. " _n
file write `fh' "Panel: Internet Drafts submitted to IETF Working Groups, 1993--2003. " _n
file write `fh' "Only Suit-share $\times$ S-track interaction shown; " _n
file write `fh' "additional controls as in original paper. " _n
file write `fh' "Standard errors clustered by WG in parentheses. " _n
file write `fh' "**** p$<$0.001, *** p$<$0.01, ** p$<$0.05, * p$<$0.1.}\\" _n
file write `fh' "\end{tabular}" _n
file write `fh' "\end{table}" _n

file close `fh'

* ==========================================================================
*  6. LATEX TABLE — twowayfeweights
* ==========================================================================
tempname fh2
file open `fh2' using "$outdir/table_twowayfeweights.tex", write replace

file write `fh2' "\begin{table}[htbp]" _n
file write `fh2' "\centering" _n
file write `fh2' "\caption{Two-Way Fixed Effects Decomposition (de Chaisemartin \& D'Haultf\oe uille, 2020)}" _n
file write `fh2' "\label{tab:simcoe_twfe}" _n
file write `fh2' "\begin{tabular}{lcc}" _n
file write `fh2' "\toprule" _n
file write `fh2' " & Col 1 (techarea) & Col 3 (WG) \\" _n
file write `fh2' "\midrule" _n
file write `fh2' "\multicolumn{3}{l}{\textit{Panel A: Specification}} \\[3pt]" _n
file write `fh2' "Regression type & OLS & FE \\" _n
file write `fh2' "Dependent variable & \multicolumn{2}{c}{Total days} \\" _n
file write `fh2' "Treatment variable & \multicolumn{2}{c}{Suit-share $\times$ S-track} \\" _n
file write `fh2' "Group FE & Tech area & Working group \\" _n
file write `fh2' "Time FE  & \multicolumn{2}{c}{Publication cohort} \\[6pt]" _n
file write `fh2' "\multicolumn{3}{l}{\textit{Panel B: Weight Decomposition}} \\[3pt]" _n

if `tw_rc_fe1' == 0 | `tw_rc_fe1' == 402 {
    local bstr1 : di %10.4f `tw_beta_fe1'
    file write `fh2' "$\hat{\beta}_{TWFE}$ & `bstr1' "
}
else {
    file write `fh2' "$\hat{\beta}_{TWFE}$ & --- "
}

if `tw_rc_fe3' == 0 | `tw_rc_fe3' == 402 {
    local bstr3 : di %10.4f `tw_beta_fe3'
    file write `fh2' "& `bstr3' \\" _n
}
else {
    file write `fh2' "& --- \\" _n
}

if `tw_rc_fe1' == 0 | `tw_rc_fe1' == 402 {
    file write `fh2' "\# positive weights & `tw_npos_fe1' "
}
else {
    file write `fh2' "\# positive weights & --- "
}
if `tw_rc_fe3' == 0 | `tw_rc_fe3' == 402 {
    file write `fh2' "& `tw_npos_fe3' \\" _n
}
else {
    file write `fh2' "& --- \\" _n
}

if `tw_rc_fe1' == 0 | `tw_rc_fe1' == 402 {
    file write `fh2' "\# negative weights & `tw_nneg_fe1' "
}
else {
    file write `fh2' "\# negative weights & --- "
}
if `tw_rc_fe3' == 0 | `tw_rc_fe3' == 402 {
    file write `fh2' "& `tw_nneg_fe3' \\" _n
}
else {
    file write `fh2' "& --- \\" _n
}

if `tw_rc_fe1' == 0 | `tw_rc_fe1' == 402 {
    file write `fh2' "\% negative weights & `tw_pctN_fe1'\% "
}
else {
    file write `fh2' "\% negative weights & --- "
}
if `tw_rc_fe3' == 0 | `tw_rc_fe3' == 402 {
    file write `fh2' "& `tw_pctN_fe3'\% \\[6pt]" _n
}
else {
    file write `fh2' "& --- \\[6pt]" _n
}

file write `fh2' "\multicolumn{3}{l}{\textit{Panel C: Classification (dCDH Web Appendix)}} \\[3pt]" _n
file write `fh2' "Design & \multicolumn{2}{c}{Sharp} \\" _n
file write `fh2' "Stable groups & \multicolumn{2}{c}{Not satisfied} \\" _n
file write `fh2' "\bottomrule" _n
file write `fh2' "\end{tabular}" _n
file write `fh2' "" _n
file write `fh2' "\vspace{6pt}" _n
file write `fh2' "\begin{minipage}{0.92\textwidth}" _n
file write `fh2' "\footnotesize" _n
file write `fh2' "\textit{Notes:} Panel B reports the weight decomposition of the TWFE estimator " _n
file write `fh2' "following de Chaisemartin \& D'Haultf\oe uille (2020). " _n
file write `fh2' "The treatment variable is Suit-share $\times$ S-track (continuous). " _n
file write `fh2' "Negative weights indicate the TWFE coefficient may not recover " _n
file write `fh2' "a convex combination of causal effects under heterogeneous treatment effects. " _n
file write `fh2' "Col 1 uses technology area as group FE; Col 3 uses working group FE." _n
file write `fh2' "\end{minipage}" _n
file write `fh2' "\end{table}" _n

file close `fh2'

* ==========================================================================
*  7. WRAPPER DOCUMENT
* ==========================================================================
tempname fh3
file open `fh3' using "$outdir/simcoe_tables.tex", write replace

file write `fh3' "\documentclass[12pt]{article}" _n
file write `fh3' "\usepackage{booktabs,caption,geometry,amsmath}" _n
file write `fh3' "\geometry{margin=1in}" _n
file write `fh3' "\captionsetup{labelsep=endash, font=normalsize, justification=centering}" _n
file write `fh3' "\begin{document}" _n
file write `fh3' "" _n
file write `fh3' "\begin{center}" _n
file write `fh3' "{\Large\bfseries Simcoe (2012)}\\" _n
file write `fh3' "{\large Standard Setting Committees:}\\" _n
file write `fh3' "{\large Consensus Governance for Shared Technology Platforms}\\" _n
file write `fh3' "\vspace{0.5em}" _n
file write `fh3' "{\normalsize \textit{American Economic Review}, 102(1), 305--336}" _n
file write `fh3' "\end{center}" _n
file write `fh3' "" _n
file write `fh3' "\vspace{1em}" _n
file write `fh3' "" _n
file write `fh3' "\section*{1. Table 4 Replication}" _n
file write `fh3' "" _n
file write `fh3' "We replicate columns 1--3 of Table 4 from the original paper." _n
file write `fh3' "The dependent variable is total days from Internet Draft submission to disposal." _n
file write `fh3' "The treatment variable is the interaction of Suit-share" _n
file write `fh3' "(a measure of commercial participation) with a standards-track indicator." _n
file write `fh3' "" _n
file write `fh3' "\input{table4_replication}" _n
file write `fh3' "" _n
file write `fh3' "\clearpage" _n
file write `fh3' "" _n
file write `fh3' "\section*{2. Two-Way FE Weights Analysis}" _n
file write `fh3' "" _n
file write `fh3' "We apply the decomposition of de Chaisemartin \& D'Haultf\oe uille (2020)" _n
file write `fh3' "to assess whether the TWFE estimator assigns negative weights." _n
file write `fh3' "" _n
file write `fh3' "\input{table_twowayfeweights}" _n
file write `fh3' "" _n
file write `fh3' "\section*{3. Conclusion}" _n
file write `fh3' "" _n
file write `fh3' "The dCDH web appendix classifies this paper as a sharp design" _n
file write `fh3' "where the stable groups assumption is \textit{not} satisfied." _n
file write `fh3' "The treatment (Suit-share $\times$ S-track) varies continuously," _n
file write `fh3' "meaning it is unlikely that any committee has distributional conflict" _n
file write `fh3' "equal to zero across all time periods." _n
file write `fh3' "" _n
file write `fh3' "\end{document}" _n

file close `fh3'

di _n "=============================================="
di    "  DONE — all files written to $outdir"
di    "=============================================="

cap log close detail
