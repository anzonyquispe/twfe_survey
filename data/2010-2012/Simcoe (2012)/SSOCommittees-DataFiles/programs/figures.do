set scheme s2mono

********************************
*
* Annual Average Duration
*
********************************
** Graph Median Duration by Exit Status
label def exiTypes 2 "Expired" 3 "Nonstandard" 4 "Standard"
label val exiType exiTypes

** Means
graph bar (mean) ttlDur if exiType>=3, over(exiType) over(pubCohort) asyvars ytitle("Mean Days to Consensus" " ")
graph export figures/annualMeanDuration.pdf, replace

** Medians
graph bar (median) ttlDur if exiType>=3, over(exiType) over(pubCohort) asyvars ytitle("Median Days to Consensus" " ")
graph export figures/annualMedianDuration.pdf, replace


********************************
*
* Survival Curves
*
********************************
stset ttlDur
sts graph if exiType != 1 & ttlDur < 3500, by(exiType) legend(lab(1 "Expired") lab(2 "Nonstandards") lab(3 "Standards")) title("") xtitle("Total Days") ytitle("Pr(Survive to Total Days)" " ") caption("Sample: Working Group IDs (93-03)")
graph export figures/survivalCurveDays.pdf, replace


********************************
*
* Non-parametric Diff in Diffs
*
********************************
** Local Polynomials (Lowess?)
twoway lpolyci ttlDur stbafl1yr if (exiType == 4 & ttlDur<2007 & stbafl1yr>=50), ciplot(rline)  alp(dash)  || lpolyci ttlDur stbafl1yr if (exiType == 3 & ttlDur<2007 & stbafl1yr>=50), ciplot(rline) alp(shortdash) lpat(dash) ytitle("Mean Total Days" " ") xtitle("Suit-share") legend(order(2 4) lab(2  " Standards") lab(4 "Non-standards")) caption("Kernel-weighted local polynomial with 95% CIs.")
graph export figures/diffDiffs.pdf, replace


** Box Plots
gen stbDec = floor(stbEmail/10)
label define stbDec 4 "40th" 5 "50th" 6 "60th" 7 "70th" 8 "80th" 9 "90th"
label values stbDec stbDec
graph box ttlDur if (exiType >= 3 & stbDec>=4), over(stbDec) over(exiType) noout legend(lab(3 "Nonstandards") lab(4 "Standards")) ytitle("Days to Consensus" " ") title("Delays by Suit-share Decile")
graph export figures/stbEmailBox.pdf, replace

replace stbDec = floor(stbafl1yr/10)
graph box ttlDur if (exiType >= 3 & stbDec>=4), over(stbDec) over(exiType) noout legend(lab(3 "Nonstandards") lab(4 "Standards")) ytitle("Days to Consensus" " ") title("Delays by Suit-share Decile")
graph export figures/stbAflBox.pdf, replace


** Quadratic Fitted Values
g stb2 = stbafl1yr^2
g stb3 = stbafl1yr^3

reg ttlDur stbafl1yr stb2 stb3 if (exiType == 4)  
predict stYhat if e(sample), xb
predict seyYat1 if e(sample), stdp
g tmp1 = stYhat + 2*seyYat1
g tmp2 = stYhat - 2*seyYat1

reg ttlDur stbafl1yr stb2 stb3 if (exiType == 3)  
predict nsYhat if e(sample), xb
predict seyYat2  if e(sample), stdp
g tmp3 = nsYhat + 2*seyYat2
g tmp4 = nsYhat - 2*seyYat2

sort stbafl1yr
twoway (scatter stYhat stbafl1yr if stbafl1yr >=40, legend(order(1 2) lab(1 "Standards") lab(2 "Nonstandards")) msymb(none) connect(l) lcolor(black) ylabel(,nogrid) xtitle("Suit-Share (Percent)") ytitle("Days-to-Consensus") graphregion(fcolor(white))) (scatter nsYhat stbafl1yr if stbafl1yr >=40, msymb(none) connect(l) lcolor(black) lpattern(dash)) (scatter tmp1 stbafl1yr if stbafl1yr>=40, mcolor(none) connect(l) lcolor(gs8) lpattern(shortdash)) (scatter tmp2 stbafl1yr if stbafl1yr>=40, mcolor(none) connect(l) lcolor(gs8) lpattern(shortdash)) (scatter tmp3 stbafl1yr if stbafl1yr>=40, mcolor(none) connect(l) lcolor(gs8) lpattern(shortdash)) (scatter tmp4 stbafl1yr if stbafl1yr>=40, mcolor(none) connect(l) lcolor(gs8) lpattern(shortdash)) 
graph export figures/ddCubic.pdf, replace

