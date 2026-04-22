use C:\TOT_Project\AER-Data\NonLinearData.dta

xi i.country
rename _Icountry_2 c2
rename _Icountry_3 c3
rename _Icountry_4 c4
rename _Icountry_5 c5

/* Left column of Table 7*/
log using blwreg.log, replace
xi: ivregress gmm tarifffinal tariffbase c2 c3 c4 c5 i.hs (logn = logniv)
log close

/* Right column of Table 7*/
log using herfreg.log, replace
xi: ivregress gmm tarifffinal tariffbase c2 c3 c4 c5 i.hs (logn theta = logniv thetaiv)
log close