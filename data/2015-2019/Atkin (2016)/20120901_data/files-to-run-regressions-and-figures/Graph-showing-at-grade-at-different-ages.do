

use C:\Data\Mexico\Stata10\temp9.dta , clear
keep if  muncenso!=12 & migrant==0  & age<20

 

*this is based on last weeks employment rather than a direct question
gen schatt2=(empstatd==330)
replace schatt2=schatt if empstatd==999


gen employ=1 if  empstatd>=100 &  empstatd<134
replace employ=0 if  (empstatd>=200 &  empstatd<330) | empstatd==380

gen employ2=(empstatd>=100 & empstatd<=133 & hrswrk1>20 & hrswrk1<100)
replace employ2=. if empstatd==999
replace employ2=1 if empstatd>=100 & empstatd<=133 & (hrswrk1==. |  hrswrk1==998)

*this is based on last weeks employment rather than a direct question
gen schatt3=schatt
replace schatt3=0 if empstatd>=100 & empstatd<=133
replace schatt3=schatt if empstatd==999


gen schatt4=schatt
replace schatt4=0 if hrswrk1>20 & hrswrk1<100
replace schatt4=schatt if empstatd==999

gen schattwork=(schatt==1 & empstatd>=100 & empstatd<=133)
replace schattwork=. if schatt==. | empstatd==999

gen schattwork2=(schatt==1 & hrswrk1>=1 & hrswrk1<=200)
replace schattwork2=. if schatt==. | empstatd==999


gen atgrade=(age-6==yrschl)
gen atgradeatschool=(age-6==yrschl & schatt==1)
replace atgradeatschool=. if schatt==. | yrschl==.
gen atgradeatschool3=(age-6==yrschl & schatt3==1)
replace atgradeatschool3=. if schatt3==. | yrschl==.

local vlist "atgrade atgradeatschool atgradeatschool3 schatt schatt2 schatt3 schattwork schattwork2 employ employ2"

collapse `vlist' [pw=wtper], by(age cenyear) 

reshape wide `vlist', i(age) j(cenyear)

tsset age

foreach bend in 1990 2000 {

gen d_atgradecombo`bend'=atgrade`bend'-l1.atgradeatschool`bend'
gen r_atgradecombo`bend'=(atgradeatschool`bend'/l1.atgrade`bend')

gen d_atgradecombo3`bend'=atgrade`bend'-l1.atgradeatschool3`bend'
gen r_atgradecombo3`bend'=(atgrade`bend'/l1.atgradeatschool3`bend')

foreach thing in `vlist' {
gen d_`thing'`bend'=`thing'`bend'-l1.`thing'`bend'
gen r_`thing'`bend'=(`thing'`bend'/l1.`thing'`bend')
}
}



twoway line d_schatt31990 d_atgrade1990  d_employ21990 age if age>=12 , yaxis(1) lpattern(solid dash dash_dot) || ///
line r_atgradecombo31990  age if age>=12 ,  yaxis(2) lpattern(longdash) ///
xtitle("Age") ytitle("Change in Proportion of Age Cohort" "Compared to Previous Age Cohort",  size(small)) ///
ytitle("Estimated Completion Rate", axis(2) size(small)) ///
xlabel(12(1)19, labsize(small)) ylabel(0.6(.1)1, axis(2) labsize(small)) ylabel(, labsize(small))   xsize(6.5)  ysize(2) scale(1.5) graphregion(margin(0)) ///
legend(order(1 2 3 4) cols(4)  label(1 "Attending School" ) label(2 "At Correct Grade-for-Age" )  label(3 "Employed" )  label(4 "Estimated Completion Rate" ) size(small)) 
graph save "C:\Work\Mexico\Revision\Graphs\Grade_completion_rate_rich_wide.gph", replace
graph  export  "C:\Work\Mexico\Revision\Graphs\Grade_completion_rate_rich_wide.pdf", replace




