**** Local Macro to Hold List of Control Variables ****
set linesize 200
local controls lsize lcmsgs lwgidnow aut2 aut3
local st_controls st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3

log using tables/olsMainRegs.log, t replace
**************************************
*  Main Table (WG-Level Analysis)
**************************************
** Col 1: Straight OLS Diff-in-diffs
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & cSample==1), cluster(wg)
est store col1
qui testparm `st_controls' `controls' 
display  "Controls Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) 
qui testparm _Ipub*                                                 
display  "PubCohort Effect   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) 
qui testparm _Itech*                                                
display  "TechArea Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)
display "Model dof           " %8.0f e(df_m)  
display "R-square            " %8.2f e(r2)


** Col 2: P-score Matched Diff-in-diffs 
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc)  & match_samp2  & cSample==1), cluster(wg)
est store col2
qui testparm `st_controls' `controls' 
display  "Controls Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) 
qui testparm _Ipub*                                                 
display  "PubCohort Effect   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) 
qui testparm _Itech*                                                
display  "TechArea Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) 
tab strfc if e(sample)
display "Model dof           " %8.0f e(df_m)  
display "R-square            " %8.2f e(r2)


** Col 3: Matched Diff-in-diffs with WG FEs
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & match_samp2 & cSample==1), fe i(wg) robust
est store col3
qui testparm `st_controls' `controls' 
display  "Controls Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
display  "WG Fixed Effects   " %8.2f e(N_g)  %8.2f Ftail(e(df_a),e(df_r),e(F_f))
tab strfc if e(sample)
display "Model dof           " %8.0f e(df_m)
display "R-square            " %8.2f e(r2)


** Col 4: IV Selection Model
qui xi: probit strfc anyKeys lKeys stbafl1yr lwgipr othDum `controls' i.techarea i.pubCohort if ((strfc|nsrfc) & cSample)
predict stHat

foreach X in st_stbafl1yr st_lwgipr st_othDum {
	g `X'_save = `X'
}
foreach X in `controls' {
	g stHat_`X' = stHat * `X'
}

replace st_stbafl1yr = (stbafl1yr-72.98) * strfc
replace st_lwgipr = (lwgipr-7.313) * strfc
replace st_othDum = (othDum-0.2487) * strfc

g stHat_stbafl1yr = stHat * (stbafl1yr-72.98)
g stHat_lwgipr = stHat * (lwgipr-7.313)
g stHat_othDum = stHat * (othDum-0.2487)

xi: ivreg2 ttlDur (st_stbafl1yr st_othDum strfc = stHat stHat_stbafl1yr stHat_othDum) stbafl1yr lwgipr othDum `controls' i.techarea i.pubCohort if ((strfc|nsrfc) & cSample==1), cluster(wg) gmm2s ffirst endog(strfc st_stbafl1yr st_othDum)

*xi: ivreg2 ttlDur (st_stbafl1yr st_lwgipr st_othDum strfc = stHat stHat_*) stbafl1yr lwgipr othDum `controls' i.techarea i.pubCohort if ((strfc|nsrfc) & cSample==1), cluster(wg) gmm2s ffirst endog(strfc st_stbafl1yr st_othDum st_lwgipr)

est store col4
qui testparm `st_controls' `controls' 
display  "Controls Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
qui testparm _Itech*                                                
display  "TechArea Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df)
tab strfc if e(sample)
display "Model dof           " %8.0f e(df_m)
display "R-square            " %8.2f e(r2)

foreach X in st_stbafl1yr st_lwgipr st_othDum {
	drop `X'
	g `X' = `X'_save
	drop `X'_save
}


** Col 5: RE Standards Only
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum `controls' i.pubCohort i.techarea if ((strfc) & cSample==1), re i(wg) cluster(wg)
est store col5
qui testparm `controls' 
display  "Controls Effects   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
qui testparm _Ipub*
display  "PubCohort Effect   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
qui testparm _Itech*
display  "techArea Effect   " %8.2f r(F)  %8.2f r(p)   %8.2f r(df) %8.2f r(df_r)
*display  "WG Fixed Effects   " %8.2f e(N_g)  %8.2f Ftail(e(df_a),e(df_r),e(F_f))
*tab strfc if e(sample)
display "Model dof           " %8.0f e(df_m)
display "R-square            " %8.2f e(r2)

estout  _all, cells(b(fmt(1)) se(par fmt(1) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`st_controls' `controls' _I* strfc _cons) style(tex) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001)

*******************
** Hausman Tests **
******************* 
** Column 3: Matched Diff-diffs ** 
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort strfc if ((strfc|nsrfc) & match_samp2 & cSample==1), i(wg)
est store H1
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort strfc if ((strfc|nsrfc) & match_samp2 & cSample==1), fe i(wg)
est store H2
hausman H2 H1, sigmaless

*** Clustered RE Estimates
xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum stbafl1yr lwgipr othDum `st_controls' `controls' i.pubCohort i.techarea strfc if ((strfc|nsrfc) & match_samp2 & cSample==1), re i(wg) cluster(wg)

** Column 5: Standards Only ** 
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum `controls' i.techarea i.pubCohort if (strfc & cSample==1), re i(wg)
est store H1
qui xi: xtreg ttlDur st_stbafl1yr st_lwgipr st_othDum `controls' i.pubCohort if (strfc & cSample==1), fe i(wg)
est store H2
hausman H2 H1, sigmaless

drop stHat*
est clear 
log close
