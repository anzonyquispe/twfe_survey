set linesize 200

**** Local Macro to Hold List of Control Variables ****
local controls lsize lcmsgs lwgidnow aut2 aut3
local st_controls st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3

log using tables/olsTrends.log, t replace
*********************
* Simple Time Trends 
*********************
xi: reg ttlDur pubCohort strfc st_pubCohort if ((strfc|nsrfc) & cSample & match_samp2), robust
xi: reg ttlDur pubCohort strfc st_pubCohort if ((strfc|nsrfc) & cSample & match_samp2 & pubCohort>=1994), robust
log close


log using tables/olsRobustBigFirms.log, t replace
*******************************************
*      Robustness : Large Firm FEs
*******************************************
merge 1:1 series using data/bigFirmDummies
drop if _merge ==2

qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum aflDum* `st_controls' `controls' i.techarea i.pubCohort strfc  if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store col1
tab strfc if e(sample)
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum aflDum* `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), fe i(wg) robust
est store col2
tab strfc if e(sample)

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' aflDum* `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
drop aflDum*
est clear
log close


log using tables/olsRobustXTPoisson.log, t replace
*******************************************
*      Robustness : Poisson Models
*******************************************
g lnStb = log(stbafl1yr)
g st_lnStb = strfc*lnStb

** Full Sample
qui xi: poisson ttlDur st_lnStb st_lwgipr st_othDum lnStb lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc  if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store col1

** Matched Sample
qui xi: poisson ttlDur st_lnStb st_lwgipr st_othDum lnStb lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc  if ((strfc|nsrfc) & cSample & match_samp2 & match_samp2), cluster(wg)
est store col2

** Matched Sample FE's
qui xi: xtpqml ttlDur st_lnStb st_lwgipr st_othDum lnStb lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2 & match_samp2), fe i(wg)
est store col3

** Standards
qui xi: xtpqml ttlDur st_lnStb st_lwgipr st_othDum `st_controls' `controls' i.pubCohort strfc if (strfc & cSample & match_samp2), fe i(wg)
est store col4

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear
log close


log using tables/olsRobustSTB.log, t replace
********************************************
*      Robustness : Alternative STB Measures
********************************************
** STB Email (ID-Level)
qui xi: reg ttlDur st_lwgipr st_othDum lwgipr othDum st_stbEmail stbEmail `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), cluster(wg)
est store col1
qui xi: xtreg ttlDur st_lwgipr st_othDum lwgipr othDum st_stbEmail stbEmail `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), fe i(wg) robust
est store col2
estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear


** Cross-sectional Others
qui xi: reg ttlDur st_stbusr1yr st_lwgipr stbusr1yr lwgipr othDum st_othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2 & match_samp2), cluster(wg)
est store col2                                                                                                              
qui xi: reg ttlDur st_stbmsg1yr st_lwgipr stbmsg1yr lwgipr othDum st_othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), cluster(wg)
est store col3                                                                                                              
qui xi: reg ttlDur st_stbaflcum st_lwgipr stbaflcum lwgipr othDum st_othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), cluster(wg)
est store col4                                                                                                              
qui xi: reg ttlDur st_stbaflrpl st_lwgipr stbaflrpl lwgipr othDum st_othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), cluster(wg)
est store col5                                                                                                              
qui xi: reg ttlDur st_stbaflall st_lwgipr stbaflall lwgipr othDum st_othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), cluster(wg)
est store col6

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) order(st_stbusr1yr stbusr1yr st_stbmsg1yr stbmsg1yr st_stbaflcum stbaflcum st_stbaflrpl stbaflrpl st_stbaflall stbaflall) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear 

** WG Fixed Effects 
qui xi: xtreg ttlDur st_stbusr1yr st_lwgipr stbusr1yr lwgipr othDum st_othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), fe i(wg) robust
est store col2                                                                                                     
qui xi: xtreg ttlDur st_stbmsg1yr st_lwgipr stbmsg1yr lwgipr othDum st_othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), fe i(wg) robust
est store col3                                                                                                     
qui xi: xtreg ttlDur st_stbaflcum st_lwgipr stbaflcum lwgipr othDum st_othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), fe i(wg) robust
est store col4                                                                                                     
qui xi: xtreg ttlDur st_stbaflrpl st_lwgipr stbaflrpl lwgipr othDum st_othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), fe i(wg) robust
est store col5                                                                                                     
qui xi: xtreg ttlDur st_stbaflall st_lwgipr stbaflall lwgipr othDum st_othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)  & cSample & match_samp2), fe i(wg) robust
est store col6

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) order(st_stbusr1yr stbusr1yr st_stbmsg1yr stbmsg1yr st_stbaflcum stbaflcum st_stbaflrpl stbaflrpl st_stbaflall stbaflall) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear 
log close  

log using tables/olsRobustDV.log, t replace
*******************************************
* Alternate DV's: Age/Revisions, log(ttlDur)
*******************************************
replace stbafl1yr = stbafl1yr/100
replace st_stbafl1yr = st_stbafl1yr/100

qui xi: reg age st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum  `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store col1
qui xi: xtreg age st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), fe i(wg) r
est store col2
qui xi: reg lnDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), cluster(wg)
est store col3
qui xi: xtreg lnDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & cSample & match_samp2), fe i(wg) robust
est store col4

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear
replace stbafl1yr = stbafl1yr*100
replace st_stbafl1yr = st_stbafl1yr*100
log close


log using tables/coxHazardRobust.log, t replace
*******************************************
*      Robustness : Cox Hazard
*******************************************
replace stbafl1yr = stbafl1yr/100
replace st_stbafl1yr = st_stbafl1yr/100

stset ttlDur, failure(rfctype)
qui xi: stcox st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum  `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)), cluster(wg) nohr
tab rfctype if e(sample)
est store col1

stset ttlDur, failure(rfctype)
qui xi: stcox st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc, cluster(wg) nohr
tab rfctype if e(sample)
est store col2

qui xi: stcox st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc)), strata(wg) robust nohr
tab rfctype if e(sample)
est store col3

qui xi: stcox st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc, strata(wg) robust nohr
tab rfctype if e(sample)
est store col4

replace stbafl1yr = stbafl1yr*100
replace st_stbafl1yr = st_stbafl1yr*100

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear
log close


log using tables/quantileRobust.log, t replace
***************************
*  Quantile Regressions (Diff-diffs & Standards Only)
***************************
** Median/75th/90th
qui xi: qreg ttlDur st_stbafl1yr st_lwgipr st_othDum `st_controls' i.techarea i.pubCohort if ((strfc) & cSample & match_samp2), quantile(0.5) 
est store col1
qui xi: bsqreg ttlDur st_stbafl1yr st_lwgipr st_othDum `st_controls' i.techarea i.pubCohort if ((strfc) & cSample & match_samp2), quantile(.75) reps(200)
est store col2

qui xi: qreg ttlDur stbafl1yr lwgipr othDum `controls' i.techarea i.pubCohort if ((nsrfc) & cSample & match_samp2), quantile(0.5) 
est store col3
qui xi: bsqreg ttlDur stbafl1yr lwgipr othDum `controls' i.techarea i.pubCohort if ((nsrfc) & cSample & match_samp2), quantile(.75) reps(200)
est store col4

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I*) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
est clear
log close
