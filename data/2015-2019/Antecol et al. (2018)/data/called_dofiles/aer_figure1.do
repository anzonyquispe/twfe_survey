clear 
set more off
use aer_acs

*This file creates Figure 1 and contains individuals born in 1970 who are 30 in the 2000 Census or 40 in the 2010 American Community Survey
keep if educ==11
keep if uhrswork>=30 & uhrswork!=.

gen female=1 if sex==2
replace female=0 if sex==1

gen law=1 if occ2010==2100
gen dr=1 if occ2010==3060
gen postsecondary=1 if occ2010==2200
gen business=1 if occ2010>=0010 & occ2010<=0950
		* includes all business and finance occupation codes
gen group=1 if law==1
replace group=2 if dr==1
replace group=3 if postsecondary==1
replace group=4 if business==1
keep if group!=.

sort year age group
by year age group: gen ngroup = 1 if _n==1
replace ngroup = sum(ngroup)

gen p75=.
 qui forvalues i = 1/8 { 
	sum incwage [w=perwt] if ngroup == `i', detail 
	replace p75 = r(p75) if ngroup == `i' 
 }

gen top_25=1 if incwage>=p75
gen top_25_female=top_25*female if top_25!=. & female!=.
by year age group: gen n=_N

collapse female top_25_female (count) n [pw=perwt], by(year age group)

graph bar  female top_25_female, over(group, label(labsize(vsmall)) relabel(1 "Lawyers" 2 "Doctors" 3 `""Postsecondary" "Teachers""' 4 "Business")) over(age, relabel(1 "Age 30" 2 "Age 40")) ytitle("Share Female") legend(label(1 "All Workers") label(2 "Top 25% of Earners")) bar(1, color(navy)) bar(2, color(dkorange)) saving(fig1, replace)



