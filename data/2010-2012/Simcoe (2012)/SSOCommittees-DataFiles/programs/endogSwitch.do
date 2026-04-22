*** Extra Variables & Constraints
do programs/newSwitch

g lnSTB = log(stbafl1yr)
g st_lnSTB = lnSTB * strfc
qui tab techarea, gen(aDum)
qui tab pubCohort, gen(yDum)
drop aDum1 yDum1 

local controls lsize lcmsgs lwgidnow aut2 aut3
local st_controls st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3

constraint 1 [eq1 = eq2]: aDum2 aDum3 aDum4 aDum5 aDum6 
constraint def 2 [theta1]_cons=0 
constraint def 3 [theta2]_cons=0 
constraint 4 [eq1 = eq2]: yDum2 yDum3 yDum4 yDum5 yDum6 yDum7 yDum8 yDum9 yDum10
constraint 5 [eq1 = eq2]: yDum2 yDum3 yDum4 yDum5 yDum6 yDum7 yDum8 yDum9 yDum10 yDum11

**********************************
****** Results in the Paper *******
**********************************

log using tables/endogSwitch.log, replace
*******************************************
* Matched Sample Endogenous Switching Model
*******************************************
** Get Starting Values
qui xi: reg lnDur lnSTB lwgipr othDum `controls' i.techarea i.pubCohort if strfc, cluster(wg) 
mat tmp1 = e(b)
qui xi: reg lnDur lnSTB lwgipr othDum `controls' i.techarea i.pubCohort if nsrfc, cluster(wg) 
mat tmp2 = e(b)
qui xi: probit strfc anyKeys lKeys lnSTB lwgipr othDum `controls' i.techarea i.pubCohort if ((strfc|nsrfc) & cSample==1), cluster(wg)
mat tmp3 = e(b)
matrix stval = tmp1, tmp2, tmp3, 0, 0, 0, 0 

* Maximum Likelihood Estimation
ml model lf newSwitch (lnDur = lnSTB lwgipr othDum `controls' aDum* yDum*) (lnSTB lwgipr othDum `controls' aDum* yDum*) (anyKeys lKeys lnSTB lwgipr othDum `controls' aDum* yDum*) /lns1 /lns2 /theta1 /theta2 if ((strfc|nsrfc) & cSample==1), cluster(wg) constraint(1 4)
ml init stval, copy
ml maximize, difficult
est store switch1

* Hypothesis Tests
test [eq1 = eq2]: lnSTB
test [eq1 = eq2]: lwgipr 
test [eq1 = eq2]: othDum
test [eq3]: anyKeys lKeys
test [theta1]_cons [theta2]_cons
display %8.2f tanh([theta1]_cons) %8.2f tanh([theta2]_cons)
testnl (tanh([theta1]_cons) = 0) (tanh([theta2]_cons) = 0)

* Regression Statistics
qui testparm aDum*
display  "TechArea Effects   " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm yDum*
display  "PubCohort Effects  " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm `controls'
display  "ControlVar Effects " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
tab exiType if e(sample)


*******************************************
* Full Sample Endogenous Switching Model
*******************************************
* Maximum Likelihood Estimation
ml model lf newSwitch (lnDur = lnSTB lwgipr othDum `controls' aDum* yDum*) (lnSTB lwgipr othDum `controls' aDum* yDum*) (anyKeys lKeys lnSTB lwgipr othDum `controls' aDum* yDum*) /lns1 /lns2 /theta1 /theta2, cluster(wg)
ml init stval, copy
ml maximize, difficult
est store switch2

* Hypothesis Tests
test [eq1 = eq2]: lnSTB
test [eq1 = eq2]: lwgipr 
test [eq1 = eq2]: othDum
test [eq3]: anyKeys lKeys
test [theta1]_cons [theta2]_cons
display %8.2f tanh([theta1]_cons) %8.2f tanh([theta2]_cons)
testnl (tanh([theta1]_cons) = 0) (tanh([theta2]_cons) = 0)

* Regression Statistics
qui testparm aDum*
display  "TechArea Effects   " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm yDum*
display  "PubCohort Effects  " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm `controls'
display  "ControlVar Effects " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
tab exiType if e(sample)

estout  _all, cells(b(fmt(2)) se(par fmt(2) star)) stats(N df_m, fmt(0 %8.2f 0 0)) drop(`controls' aDum* yDum* _cons) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.01)
log close
est clear


*********************************
****** Unreported Results *******
*********************************

log using tables/olsKeywords.log, replace
***********************************************
* Keywords are Correlated with NS Dealys
***********************************************
** WG Covariates
qui xi: reg lnDur lnSTB lwgipr othDum anyKeys lKeys `controls' i.techarea i.pubCohort if strfc & cSample, cluster(wg) 
est store ols1
test anyKeys lKeys
qui xi: reg lnDur lnSTB lwgipr othDum anyKeys lKeys `controls' i.techarea i.pubCohort if nsrfc & cSample, cluster(wg)
est store ols2
test anyKeys lKeys
qui xi: reg ttlDur stbafl1yr lwgipr othDum anyKeys lKeys `controls' i.techarea i.pubCohort if strfc & cSample, cluster(wg) 
est store ols3
test anyKeys lKeys
qui xi: reg ttlDur stbafl1yr lwgipr othDum anyKeys lKeys `controls' i.techarea i.pubCohort if nsrfc & cSample, cluster(wg)
est store ols4
test anyKeys lKeys

estout  _all, cells(b(fmt(3)) se(par fmt(3) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`controls' _I* _cons) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.01)
est clear


***********************************************
* Two-Step (Heckit) Estimates in Logs and Levels
***********************************************
qui xi: probit strfc anyKeys lKeys lnSTB lwgipr othDum `controls' i.techarea i.pubCohort if ((strfc|nsrfc) & cSample == 1), cluster(wg)
predict fitted, xb
mfx, nose 
g st_millsTerm = strfc*normalden(fitted)/normal(fitted) 
g ns_millsTerm = nsrfc*normalden(fitted)/(1-normal(fitted)) 

qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_orgDum st_eduDum stbafl1yr lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort*i.strfc if ((strfc|nsrfc) & cSample==1 & match_samp2==1), cluster(wg)
est store col1
qui xi: reg ttlDur st_stbafl1yr st_lwgipr st_orgDum st_eduDum stbafl1yr lwgipr othDum st_millsTerm ns_millsTerm `st_controls' `controls' i.techarea i.pubCohort*i.strfc if ((strfc|nsrfc) & cSample==1 & match_samp2==1), cluster(wg)
est store col2
test st_millsTerm ns_millsTerm

qui xi: reg lnDur st_lnSTB st_lwgipr st_orgDum st_eduDum lnSTB lwgipr othDum `st_controls' `controls' i.techarea i.pubCohort*i.strfc if ((strfc|nsrfc) & cSample==1 & match_samp2==1), cluster(wg)
est store col3
qui xi: reg lnDur st_lnSTB st_lwgipr st_orgDum st_eduDum lnSTB lwgipr othDum st_millsTerm ns_millsTerm `st_controls' `controls' i.techarea i.pubCohort*i.strfc if ((strfc|nsrfc) & cSample==1 & match_samp2==1), cluster(wg)
est store col4
test st_millsTerm ns_millsTerm

estout  _all, cells(b(fmt(3)) se(par fmt(3) star)) order(st_stbafl1yr st_lnSTB) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(`controls' _I* _cons) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.01)
est clear


*********************************
* Full Sample Constrained Exogenous Switching Model
*********************************
ml model lf newSwitch (lnDur = lnSTB lwgipr othDum `controls' aDum* yDum*) (lnSTB lwgipr othDum `controls' aDum* yDum*) (anyKeys lKeys lnSTB lwgipr othDum `controls' aDum* yDum*) /lns1 /lns2 /theta1 /theta2, cluster(wg) constraint(1 2 3 5)
ml init stval, copy
ml maximize, difficult

* Hypothesis Tests
test [eq3]: anyKeys lKeys
test [eq1 = eq2]: lnSTB
test [eq1 = eq2]: lwgipr 
test [eq1 = eq2]: othDum

* Regression Statistics
qui testparm aDum*
display  "TechArea Effects   " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm yDum*
display  "PubCohort Effects  " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm `controls'
display  "ControlVar Effects " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
tab exiType if e(sample)


*********************************
* Endogenous Switching Model on Common Support
*********************************
ml model lf newSwitch (lnDur = lnSTB lwgipr othDum `controls' aDum* yDum*) (lnSTB lwgipr othDum `controls' aDum* yDum*) (anyKeys lKeys lnSTB lwgipr othDum `controls' aDum* yDum*) /lns1 /lns2 /theta1 /theta2 if (match_samp2==1), cluster(wg) constraint(1 5)
ml init stval, copy
ml maximize, difficult

* Hypothesis Tests
test [eq3]: anyKeys lKeys
test [eq1 = eq2]: lnSTB
test [eq1 = eq2]: lwgipr 
test [eq1 = eq2]: othDum
display %8.2f tanh([theta1]_cons) %8.2f tanh([theta2]_cons)
testnl (tanh([theta1]_cons) = 0) (tanh([theta2]_cons) = 0)

* Regression Statistics
qui testparm aDum*
display  "TechArea Effects   " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm yDum*
display  "PubCohort Effects  " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
qui testparm `controls'
display  "ControlVar Effects " %8.2f r(chi2)  %8.2f r(p)   %8.2f r(df)
tab exiType if e(sample)

log close
