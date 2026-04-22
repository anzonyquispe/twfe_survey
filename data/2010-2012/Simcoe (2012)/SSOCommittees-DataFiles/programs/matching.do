*log using tables/matching.log, replace

** Variable Creation and Lists 
replace stbLagUsr = 100 *stbLagUsr
g pubC2 = (pubCohort - 1993)^2
g wgC2 = (wgCohort - 1993)^2
g cumId2 = lwgidttl^2 
g cumMsg2 = lcmsgs^2 
g Id2 = lwgidnow^2
g Msg2 = lmsgs^2

local wgvars stbafl1yr stbLagUsr lwgipr lwgidnow lwgidttl lwgorgs lmsgs lcmsgs cumId2 cumMsg2 Id2
local idvars n_affil priorwgc lsize orgDum eduDum govDum 
local rfcvars logPages logBackCites logEmails stbEmail obsDum updDum lwgipr lwgidnow lwgidttl lwgorgs 

************************************
*** Matched Sample for WG Models ***
************************************
qui xi: probit strfc `wgvars' `idvars' i.techarea pubCohort pubC2 wgCohort wgC2 if ((strfc|nsrfc) & cSample == 1), robust
*mfx
testparm _Itech*
test pubCohort pubC2 
test wgCohort wgC2

est store match1
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

/* Uncomment this code for Picture ***
tab match_samp1 strfc if ((strfc|nsrfc) & ttlDur <=2007 & e(sample))
tab match_samp2 strfc if ((strfc|nsrfc) & ttlDur <=2007 & e(sample))
estout match1, cells(b(fmt(2)) se(par fmt(2) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) margin style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)

** Propensity Score Picture
set scheme s2mono
twoway kdensity yhat if (strfc & ttlDur <=2007 & e(sample)) || kdensity yhat if (nsrfc & ttlDur <=2007 & e(sample)), xtitle(" " "Pr[Standards-track | X]") xline(.4940186 .8299517) xline(.3816603  .870804, lp(dot)) ytitle("Kernel Density") legend(lab(1 "Standards") lab(2 "Nonstandards"))
graph export figures/propensity_match.pdf, replace
*End of Comments **/

drop ubar* lbar* yhat
est drop _all
*log close
