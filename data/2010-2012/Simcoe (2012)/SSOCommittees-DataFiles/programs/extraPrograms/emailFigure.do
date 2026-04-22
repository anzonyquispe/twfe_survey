set scheme s2mono

** Choose WG Listserv Data-set (different msg screening criteria)
*insheet using stata/email_panel.out, n clear
insheet using stata/email_panel_replies.out, n clear
*insheet using stata/email_panel_gt4.out, n clear

* Variable Defs
recode msgcom-afloth (.=0)
gen ttlusrs = usrcom+ usrnet+ usrorg+ usredu+ usrgov+ usrcctld+ usroth
gen ttlafls = aflcom +aflnet+ aflorg+ afledu+ aflgov+ aflcctld+ afloth

* Sample Frame and Collapse
gen wgCount = 1
gen mn = monthly(month,"my")
drop if (mn < monthly("Jan1993","my") | mn > monthly("Jun2004","my"))
collapse (sum) ttlmsgs ttlusrs ttlafls msgcom msgnet wgCount aflcom aflnet usrcom usrnet, by(mn)

* Generate Alternative Measures (U=User;A=Affiliation;M=Message)
gen msgPerMonth = ttlmsgs/wgCount
gen mpcom = msgcom/ttlmsgs
gen upcom = usrcom/ttlusrs
gen apcom = aflcom/ttlafls
gen upcom2 = (usrcom+usrnet)/ttlusrs
lowess upcom2 mn, bw(.10) gen(uphat)

gen linePct = 100*uphat
gen dotPct = 100*upcom2
format mn %tmCY
twoway (line linePct mn) (scatter dotPct mn, msymbol(O)), ytitle("Suit-to-beard Percentage"  "(Private-sector / Total IETF Participants)" " ") xtitle("Year") ylabel(, format(%9.0f)) legend(lab(1 "Local Polynomial") lab(2 "Monthly Suit-to-Beard" ))
graph export figures/suitToBeard.pdf,replace
