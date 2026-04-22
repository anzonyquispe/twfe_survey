** Variable Creation
g lCumUsrs = log(areaCumUsrs)
egen wgType = group(wg strfc) 

**** Local Macro to Hold List of Control Variables ****
local controls lsize lmsgs lcmsgs lwgidnow govDum aut2 aut3
local st_controls st_lsize st_lmsgs st_lcmsgs st_lwgidnow st_govDum st_aut2 st_aut3

set linesize 200
log using tables/ivModels.log, t replace
*******************************************
*      Robustness : IV Models
*******************************************
** Col 1: IV for stbafl with Lags
xi: ivreg2 ttlDur (st_stbafl1yr = stbLagAfl) `st_controls' i.techarea i.pubCohort if (strfc & cSample), endog(st_stbafl1yr) robust cluster(wg) first
est store col1

** Col 2: IV Diff in Diffs
xi: ivreg2 ttlDur (st_stbafl1yr stbafl1yr = stbLagAfl st_stbLagAfl) `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & match_samp2 & cSample), endog(st_stbafl1yr stbafl1yr) robust cluster(wg) first
est store col2
tab strfc if e(sample)

** Col 3: XTIV for stbafl with areaGrowth
xi: xtivreg2 ttlDur (st_stbafl1yr = areaAflGrowth stbLagAfl) `st_controls' i.pubCohort if (strfc & cSample), fe i(wg) endog(st_stbafl1yr) cluster(wg) first
est store col3

*******************************
/*   Set up WG-Year Data     */
*******************************
keep if (strfc | nsrfc) & ttlDur <= 2007

g cellSize = 1
collapse (mean) ttlDur lnDur age stbafl1yr st_stbafl1yr lwgipr st_lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs rfcDum (max) techarea (sum) cellSize, by(wg strfc pubCohort)
egen wgType = group(wg strfc)
tab cellSize

bysort wg strfc : egen wgTypCnt = sum(1)
by wg strfc : gen wgFlag = (_n== 1)
tab wgTypCnt strfc if wgFlag 

***************************
/*        XTREG          */
***************************
xi: xtreg ttlDur strfc st_stbafl1yr stbafl1yr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs i.pubCohort, fe i(wg) robust
est store col4
tab strfc if e(sample)

xtset wgType pubCohort
xi: xtreg ttlDur st_stbafl1yr stbafl1yr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs i.pubCohort, fe i(wgType) robust
est store col5
tab strfc if e(sample)

***************************
/*   Arellano Bond       */
***************************

xtset wgType pubCohort
xi: xtabond ttlDur i.pubCohort if strfc, lags(1) endog(st_stbafl1yr)
est store col6

xi: xtabond ttlDur i.pubCohort, lags(1) endog(stbafl1yr st_stbafl1yr)
est store col7

estout  _all, cells(b(fmt(1)) se(par fmt(1) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I* _cons) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)

log close

