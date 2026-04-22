clear all
set more off, perm

use "data files/DISTRICT.dta"


*********************
*** FIGURE 1 PANEL A: EUROPEAN AND LOCAL ELECTION LINES 
*********************

foreach var in pct_votes_UKIP UKIPPct {

preserve

tab year if `var'!=., gen(yy_)

local rows =`r(r)'
reg `var' yy_*  [aw=pct_seats_contested_UKIP ], nocons


matrix hrid = J(`rows' ,6, 0)

global iter = 1
forvalues i=1(1)`rows' {

 lincom yy_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 * matrix hrid[$iter, 1] = `i'
 matrix hrid[$iter, 5] = `r(N)'

 global iter=$iter+1
 }

 svmat hrid

sort hrid1
keep hrid1 hrid3
rename hrid1 year
rename hrid3 `var'
duplicates drop year, force
drop if year==.
save "data files/temporary data files/summary_`var'_weight.dta", replace

restore
}


sort year

label variable pensionspendingpercapitainrealte "Pension"
label variable educationspendingrealpercapita "Education"
label variable welfaresocialprotectionpercapita "Welfare & Protection"
label variable healthcarespendingpercapita "Healthcare"


*********************
*** PANEL A FIGURE 4 
*********************

twoway (connected pensionspendingpercapitainrealte year if year>=2000, xline(2010)) (connected educationspendingrealpercapita year) (connected welfaresocialprotectionpercapita year) (connected healthcarespendingpercapita year) , scheme(s1mono) xscale(range(2000 2015)) xlabel(2000[2]2015) legend(region(lwidth(none)) cols(4)) 
graph export "figures/austerityoverall.eps",  replace



label variable QUAL_ALL_noq_sh "Share with no qualifications"
label variable RoutineOccAll_sh "Working age Share working in routine occupations"
label variable GRetailAll_sh "Working age Share working in Retail"
label variable DManufAll_sh "Working age Share working in Manufacturing"

label variable UKIPPct "EP % for UKIP"
label variable pct_votes_UKIP "Local % for UKIP"
label variable QUAL_ALL_noq_sh "% with No qual. (2001)"
label variable QUAL_ALL_lvl1_sh "% with Level 1 qualifications (2001)"
label variable QUAL_ALL_lvl2_sh "% with Level 2 qualifications (2001)"
label variable QUAL_ALL_lvl3_sh "% with Level 3 qualifications (2001)"
label variable QUAL_ALL_lvl4_plus_sh "% with Level 4 and above qualifications (2001)"
label variable QUAL_ALL_otherq_sh "% with Other qualifications (2001)"

label variable LargeemphigherManAll_sh "% working in Higher management (2001)"
label variable HigherProfOccAll_sh "% working in Higher professional occupations (2001)"

label variable LowerManagAll_sh "% working in Lower management (2001)"
label variable IntermOccAll_sh "% working in Intermediate occupations (2001)"
label variable SmallemployerAll_sh "% working in Small or own establishments (2001)"
label variable LowersupervisoryAll_sh "% working in Lower supervisory occupations (2001)"
label variable Semi_routineOccAll_sh "% working in Semi routine occupations (2001)"
label variable RoutineOccAll_sh "% working in Routine occ (2001)"
label variable LNeverworkedAll_sh "% that Never worked (2001)"
label variable LLTunemployedAll_sh "% that is Long Term Unemployed (2001)"
label variable LStudentAll_sh "% that is Studying (2001)"
label variable AAgricultureAll_sh "% working in Agriculture (2001)"
label variable CMiningAll_sh "% working in Mining (2001)"
label variable DManufAll_sh "% working in Manuf (2001)"
label variable EUtilityAll_sh "% working in Utility (2001)"
label variable FConstrAll_sh "% working in Construction (2001)"
label variable GRetailAll_sh "% working in Retail (2001)"
label variable HHotelsAll_sh "% working in Hotel and Accommodation (2001)"
label variable ITransportICTAll_sh "% working in IT and Transport (2001)"
label variable JFinancialAll_sh "% working in Finance and Insurance (2001)"
label variable KRealEstateAll_sh "% working in Real Estate (2001)"
label variable LPublicAll_sh "% working in Public sector (2001)"
label variable MEducationAll_sh "% working in Education (2001)"
label variable NHealthAll_sh "% working in Health Care (2001)"

label variable NoQualUKShareWithin "UK born pop share with No Qualifications (2001)"
label variable RoutineOccUKShareWithin "UK born Share working in Routine Occupations (2001)"
label variable DManufUKShareWithin "UK born Share working in Manufacturing (2001)"
label variable GRetailUKShareWithin "UK born Share working in Retail (2001)"


label variable housing_allowance_finlosswapyr "Local Housing Allowance cut"
label variable bedroom_tax_finlosswapyr "Bedroom Tax"
label variable nondep_deductions_finlosswapyr "Non dependent deductions"
label variable benefit_cap_finlosswapyr "Household Benefit Cap"
label variable counciltaxbenefit_finlosswapyr "Council Tax Benefit Cut"
label variable disabilitylivingallow_finlosswap "Disability Living Allowance"
label variable incapacitybenefits_finlosswapyr "Incapacity Benefit Reform"
label variable childbenefit_finlosswapyr "Child Benefit Cut"
label variable taxcredits_finlosswapyr "Tax Credit Cuts"
label variable indexing_finlosswapyr "Inflation indexation"
label variable totalimpact_finlosswapyr "Total Austerity Impact"



*********************
*** SUMMARY STATISTICS TABLE A1 PANEL A
*********************

matrix Fstats = J(14,3,.)
estimates clear

local i = 1
local labels ""
foreach var in pct_votes_UKIP UKIPPct {

local label : variable label `var'
loc labels `"`labels' "`label'""'
su `var'  
	matrix Fstats[`i',3] = `r(N)'
	matrix Fstats[`i',2] = `r(sd)'
	matrix Fstats[`i',1] = `r(mean)'


local i = `i'+1
}

foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh totalimpact_finlosswapyr taxcredits_finlosswapyr childbenefit_finlosswapyr counciltaxbenefit_finlosswapyr disabilitylivingallow_finlosswap bedroom_tax_finlosswapyr {

local label : variable label `var'
loc labels `"`labels' "`label'""'

su `var'  if year==2011 
	matrix Fstats[`i',3] = `r(N)'
	matrix Fstats[`i',2] = `r(sd)'
	matrix Fstats[`i',1] = `r(mean)'

local i = `i'+1
}

matrix rownames Fstats = pct_votes_UKIP UKIPPct QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh totalimpact_finlosswapyr taxcredits_finlosswapyr childbenefit_finlosswapyr counciltaxbenefit_finlosswapyr disabilitylivingallow_finlosswap bedroom_tax_finlosswapyr

*matrix rownames Fstats = `"`labels'"'
matrix rownames Fstats = "Local election \% for UKIP" "EL \% UKIP" "\% with No qual (2001)" "\% working in Routine occ (2001)" "\% working in Retail (2001)" "\% working in Manuf (2001)" "Total Austerity Impact" "Tax Credit Cuts" "Child Benefit Cut" "Council Tax Benefit Cut" "Disability Living Allowance" "Bedroom Tax"
matrix colnames Fstats = "Mean" "SD" "N"

estout matrix(Fstats, fmt(3) ) using "tables/summary_stats.tex", unstack  replace style(tex)      

tab year, gen(yy_)



*********************
***
*** MAIN ANALYSIS STARTS HERE
***
*********************

replace pct_votes_UKIP = pct_votes_UKIP/100

*********************
*** FIGURE 4, ONLINE APPENDIX FIGURES C3, C4, C5, C10 
*********************

local partial = ""
local partialedout=""
foreach depvar in pct_votes_UKIP   {
foreach fe in "ryr"  {
foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh QUAL_ALL_otherq_sh QUAL_ALL_lvl1_sh QUAL_ALL_lvl2_sh QUAL_ALL_lvl3_sh QUAL_ALL_lvl4_plus_sh LLTunemployedAll_sh RoutineOccAll_sh Semi_routineOccAll_sh LowersupervisoryAll_sh LStudentAll_sh LowerManagAll_sh HigherProfOccAll_sh LargeemphigherManAll_sh NoQualUKShareWithin  RoutineOccUKShareWithin GRetailUKShareWithin DManufUKShareWithin MEducationAll_sh KRealEstateAll_sh GRetailAll_sh ITransportICTAll_sh FConstrAll_sh DManufAll_sh HHotelsAll_sh NHealthAll_sh {
preserve
local lab: variable label `var' 
local shorter = substr("`var'", 1,20)
forvalues i=1(1)16 {
gen yyin_`shorter'_`i' = yy_`i' * `var'
}
if("`partialout'"!="") {
local temp = subinstr("`partialout'","`var'", "",.) 
local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 
local varpartial : word `i' of `temp'
local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1- yyin_`shorter'_10 o.yyin_`shorter'_11 yyin_`shorter'_12-yyin_`shorter'_16 `partial'  , absorb(id `fe')  vce(cl id)

lincom (yyin_`shorter'_14 + yyin_`shorter'_15 + yyin_`shorter'_16)/3
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg = `r(mean)'
estadd local sd = `r(sd)'

drop fitted
lincom yyin_`shorter'_16
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg2 = `r(mean)'
estadd local sd2 = `r(sd)'

if("`partialout'"!="") {
local pp = subinstr("`partialout'"," ","-",.)
local partialedout = "-partialout-`pp'"
}
drop fitted
esttab using "tables/timeeffects/localpol`depvar'-`sample'-did-`var'`partialedout'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd avg2 sd2 N_clust1 N , labels("Avg effect" "SD" "Avg 2010-2015" "SD" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)16 {
 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 matrix hrid[$iter, 5] = `r(N)'
 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0
su hrid1
sort hrid1

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/localpol`depvar'-did-`var'`partialedout'-`fe'.eps",  replace
restore
}
}
} 



*********************
*** ONLINE APPENDIX FIGURE C6
*********************

local partial = ""
local partialedout="DManufAll_sh import_shock"
foreach depvar in pct_votes_UKIP   {
foreach fe in  "ryr" {
foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh  {
preserve
local lab: variable label `var' 
local shorter = substr("`var'", 1,20)
forvalues i=1(1)16 {
gen yyin_`shorter'_`i' = yy_`i' * `var'
}
if("`partialedout'"!="") {
local temp = subinstr("`partialedout'","`var'", "",.) 
local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 
local varpartial : word `i' of `temp'
local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1- yyin_`shorter'_10 o.yyin_`shorter'_11 yyin_`shorter'_12-yyin_`shorter'_16 `partial'  , absorb(id `fe')  vce(cl id)

lincom (yyin_`shorter'_14 + yyin_`shorter'_15 + yyin_`shorter'_16)/3
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg = `r(mean)'
estadd local sd = `r(sd)'

drop fitted
lincom yyin_`shorter'_16
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg2 = `r(mean)'
estadd local sd2 = `r(sd)'

drop fitted
esttab using "tables/timeeffects/localpol`depvar'-`sample'-did-`var'`partialedout'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd avg2 sd2 N_clust1 N , labels("Avg effect" "SD" "Avg 2010-2015" "SD" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)16 {
 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 matrix hrid[$iter, 5] = `r(N)'
 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0
su hrid1
sort hrid1
local tt = subinstr("`partialedout'"," ","-",.)
twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/localpol`depvar'-did-`var'`tt'-`fe'.eps",  replace
restore
}
}
} 


*********************
*** ONLINE APPENDIX FIGURE C7
*********************

gen samplebal = sumukip_election>=8 & ukip_election==1

local partial = ""
local partialedout=""
foreach depvar in pct_votes_UKIP   {
foreach fe in  "ryr" {
foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh {
preserve

keep if samplebal==1

local lab: variable label `var' 
local shorter = substr("`var'", 1,20)
forvalues i=1(1)16 {
gen yyin_`shorter'_`i' = yy_`i' * `var'
}
if("`partialedout'"!="") {
local temp = subinstr("`partialedout'","`var'", "",.) 
local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 
local varpartial : word `i' of `temp'
local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1- yyin_`shorter'_10 o.yyin_`shorter'_11 yyin_`shorter'_12-yyin_`shorter'_16 `partial'  , absorb(id `fe')  vce(cl id)

lincom (yyin_`shorter'_14 + yyin_`shorter'_15 + yyin_`shorter'_16)/3
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg = `r(mean)'
estadd local sd = `r(sd)'

drop fitted
lincom yyin_`shorter'_16
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg2 = `r(mean)'
estadd local sd2 = `r(sd)'

drop fitted
esttab using "tables/timeeffects/localpol`depvar'-`sample'-did-`var'`partialedout'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd avg2 sd2 N_clust1 N , labels("Avg effect" "SD" "Avg 2010-2015" "SD" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)16 {
 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 matrix hrid[$iter, 5] = `r(N)'
 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0
su hrid1
sort hrid1
local tt = subinstr("`partialedout'"," ","-",.)
twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/localpol`depvar'-did-`var'`tt'-`fe'-samplebal.eps",  replace
restore
}
}
} 


*********************
*** ONLINE APPENDIX FIGURES C8 and C9 
*********************

local partial = ""
local partialedout=""
foreach depvar in pct_votes_UKIP   {
foreach fe in "year"  {
foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh {
preserve
local lab: variable label `var' 
local shorter = substr("`var'", 1,20)
forvalues i=1(1)16 {
gen yyin_`shorter'_`i' = yy_`i' * `var'
}
if("`partialout'"!="") {
local temp = subinstr("`partialout'","`var'", "",.) 
local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 
local varpartial : word `i' of `temp'
local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1- yyin_`shorter'_10 o.yyin_`shorter'_11 yyin_`shorter'_12-yyin_`shorter'_16 `partial'  , absorb(id `fe')  vce(cl id)

lincom (yyin_`shorter'_14 + yyin_`shorter'_15 + yyin_`shorter'_16)/3
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg = `r(mean)'
estadd local sd = `r(sd)'

drop fitted
lincom yyin_`shorter'_16
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg2 = `r(mean)'
estadd local sd2 = `r(sd)'

if("`partialout'"!="") {
local pp = subinstr("`partialout'"," ","-",.)
local partialedout = "-partialout-`pp'"
}
drop fitted
esttab using "tables/timeeffects/localpol`depvar'-`sample'-did-`var'`partialedout'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd avg2 sd2 N_clust1 N , labels("Avg effect" "SD" "Avg 2010-2015" "SD" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)16 {
 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 matrix hrid[$iter, 5] = `r(N)'
 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0
su hrid1
sort hrid1

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/localpol`depvar'-did-`var'`partialedout'-`fe'.eps",  replace
restore
}
}
} 


*********************
*** FIGURE 5
*********************
replace pct_votes_UKIP = pct_votes_UKIP *100

foreach depvar in pct_votes_UKIP   {
foreach fe in "ryr"  {
foreach comb in  "bedroom_tax_finlosswapyr 2012.5"  "counciltaxbenefit_finlosswapyr 2012.5" "disabilitylivingallow_finlosswap 2010.5"  "totalimpact_finlosswapyr 2010.5" {


local var = word("`comb'",1)
local vert= word("`comb'",2)


preserve
local lab: variable label `var' 

local shorter = substr("`var'", 1,20)

forvalues i=1(1)16 {

gen yyin_`shorter'_`i' = yy_`i' * `var'
}

if("`partialout'"!="") {

local temp = subinstr("`partialout'","`var'", "",.) 

local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 

local varpartial : word `i' of `temp'

local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1- yyin_`shorter'_10 o.yyin_`shorter'_11 yyin_`shorter'_12-yyin_`shorter'_16 `partial' , absorb(id `fe')  vce(cl id)

lincom (yyin_`shorter'_14 + yyin_`shorter'_15 + yyin_`shorter'_16)/3
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg = `r(mean)'
estadd local sd = `r(sd)'

drop fitted
lincom yyin_`shorter'_16
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg2 = `r(mean)'
estadd local sd2 = `r(sd)'

if("`partialout'"!="") {
local pp = subinstr("`partialout'"," ","-",.)
local partialedout = "-partialout-`pp'"
}
drop fitted
esttab using "tables/timeeffects/localpol`depvar'-did-`var'`partialedout'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd avg2 sd2 N_clust1 N , labels("Avg effect" "SD" "Avg 2010-2015" "SD" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)16 {

 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 * matrix hrid[$iter, 1] = `i'
 matrix hrid[$iter, 5] = `r(N)'

 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0

 
su hrid1
sort hrid1

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(`vert')) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/localpol`depvar'-did-`var'`partialedout'-`fe'.eps",  replace



restore
}
}
}



*********************
*** FIGURE A4
*********************

foreach depvar in UKIPPct  {
foreach fe in "ryr"  {
foreach var in bedroom_tax_finlosswapyr counciltaxbenefit_finlosswapyr disabilitylivingallow_finlosswap  totalimpact_finlosswapyr {

preserve
local lab: variable label `var' 

local shorter = substr("`var'", 1,20)

forvalues i=1(1)16 {

gen yyin_`shorter'_`i' = yy_`i' * `var'
}

if("`partialout'"!="") {

local temp = subinstr("`partialout'","`var'", "",.) 

local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 

local varpartial : word `i' of `temp'

local partial = "`partial' i.year#c.`varpartial'"
}
}

estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_5 o.yyin_`shorter'_10 yyin_`shorter'_15  , absorb(id `fe')  vce(cl id)

lincom   yyin_`shorter'_15 
gen fitted = `r(estimate)' *  `var'
su fitted
estadd local avg = `r(mean)'
estadd local sd = `r(sd)'


esttab using "tables/timeeffects/ep-`depvar'-did-`var'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd N_clust1 N , labels("Avg" "SD" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

drop fitted

matrix hrid = J(80 ,6, 0)

global iter = 1
foreach i of numlist 5 10 15 {

 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 * matrix hrid[$iter, 1] = `i'
 matrix hrid[$iter, 5] = `r(N)'

 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0

 
su hrid1
sort hrid1

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2011)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/ep-`depvar'-did-`var'-`fe'.eps",  replace



restore
}
}
} 




*********************
*** PANEL A AND PANEL B OF TABLE 4
*********************

foreach indepvar in dchUKIPPct dchpct_votes_UKIP {
estimates clear

foreach fe in "ryr"  {
estimates clear
foreach var in totalimpact    { 

gen temp = `var'_finlosswap
gen toinstr = `indepvar'
eststo: reghdfe EU2016RefPct_Leave temp if year==2014 &temp!=. & toinstr!=. , absorb(`fe')  vce(cl id) old 
estadd ysumm

eststo: reghdfe EU2016RefPct_Leave toinstr if year==2014  &temp!=. & toinstr!=., absorb(`fe')  vce(cl id) old 
estadd ysumm

eststo: reghdfe EU2016RefPct_Leave temp toinstr if year==2014  &temp!=. & toinstr!=., absorb(`fe')  vce(cl id) old 
estadd ysumm

drop temp        
drop toinstr        

}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp","i.","",.)
global temp = subinstr("$temp","#"," ",.)

global temp = subinstr("$temp"," ","-",.)

esttab using "tables/cross-section-both-`indepvar'-$temp.tex", replace coeflabels(temp "Austerity" toinstr "$\Delta UKIP$") nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean  N , labels("Mean of DV" "Observations" ) fmt(%9.3g)) nonumbers

}
}



*********************
*** PANEL A AND PANEL B OF TABLE 1
*********************
foreach depvar in pct_votes_UKIP UKIPPct  {
estimates clear

foreach fe in "ryr" {
estimates clear
foreach var in totalimpact  taxcredits childbenefit counciltaxbenefit  disabilitylivingallow bedroom_tax  { 

gen temp = post2010 * `var'_finlosswap

eststo: reghdfe `depvar' temp, absorb(id `fe')  vce(cl id) nocons
estadd ysumm
lincom temp
gen fitted = `r(estimate)' *  `var'_finlosswap
su fitted
estadd local avg = substr("`r(mean)'",1,5) 
estadd local sd = substr("`r(sd)'",1,5)   
drop fitted
drop temp        
}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp","i.","",.)
global temp = subinstr("$temp","#"," ",.)

global temp = subinstr("$temp"," ","-",.)

esttab using "tables/did-`depvar'-$temp.tex", replace coeflabels(temp "$\mathbb{1}$(Year$>$2010) $\times$ Austerity") nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd ymean N_clust1 N , labels("Avg effect" "SD" "Mean of DV" "Local authority districts" "Observations" ) fmt(%9.3g)) nonumbers

}
}

*********************
*** PANEL A AND PANEL B OF TABLE A2
*********************

foreach depvar in pct_votes_UKIP UKIPPct  {
estimates clear

foreach fe in "ryr" {
estimates clear
foreach var in totalimpact  taxcredits childbenefit counciltaxbenefit  disabilitylivingallow bedroom_tax  { 

gen temp = post2010 * `var'_finlosswap

eststo: reghdfe `depvar' temp, absorb(id `fe' i.id#c.year)  vce(cl id) nocons
estadd ysumm
lincom temp
gen fitted = `r(estimate)' *  `var'_finlosswap
su fitted
estadd local avg = substr("`r(mean)'",1,5) 
estadd local sd = substr("`r(sd)'",1,5)   
drop fitted
drop temp        
}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp","i.","",.)
global temp = subinstr("$temp","#"," ",.)

global temp = subinstr("$temp"," ","-",.)

esttab using "tables/did-`depvar'-trend-$temp.tex", replace coeflabels(temp "$\mathbb{1}$(Year$>$2010) $\times$ Austerity") nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd ymean N_clust1 N , labels("Avg effect" "SD" "Mean of DV" "Local authority districts" "Observations" ) fmt(%9.3g)) nonumbers

}
}


*********************
*** TABLE 1 FOOTER HIGHLIGHTING CROSS CORRELATIONS
*********************

estimates clear
foreach var in totalimpact  taxcredits childbenefit counciltaxbenefit  disabilitylivingallow bedroom_tax  { 

eststo: reghdfe `var'_finlosswap , absorb(id ryr)  vce(cl id) nocons
capture confirm variable `var'_finlosswap
if !_rc {
qui su `var'_finlosswap if year==2004
estadd local avglosspop = substr(string(round(`r(mean)',.01)),1,5)
}
capture confirm variable `var'_hh_aff
if !_rc {
qui su `var'_hh_aff if year==2004
local temp = `r(mean)' * `r(N)'/1000
estadd local hhaff = round(`temp',1)		

capture confirm variable `var'_estlossyr
if !_rc {
capture confirm variable `var'_hh_aff 
if !_rc {
gen temp = `var'_estlossyr/ `var'_hh_aff * 1000000
qui su temp if year==2004
estadd local avglosshhaff = substr(string(round(`r(mean)',.01)),1,6)
drop temp
}
}


cor `var'_hh_aff_pc QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh 

matrix b = r(C)
local temp = b[2,1]
estadd local corQual = substr(string(round(`temp',.01)),1,3)	
local temp = b[3,1]
estadd local corRout = substr(string(round(`temp',.01)),1,5)
local temp = b[4,1]
estadd local corRetail = substr(string(round(`temp',.01)),1,5)
local temp = b[5,1]
estadd local corManuf = substr(string(round(`temp',.01)),1,5)
}
}
esttab using "tables/did-polled-stats-ryr.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avglosspop hhaff empt corQual corRout corRetail corManuf , labels("Avg Loss per working age adult" "Affected HH. in 1000s" "\hline \emph{Correlation with...}" "\quad No qualification share" "\quad Routine job share" "\quad Retail sector share" "\quad Manufacturing sector share") fmt(%9.3g)) nonumbers



***THE INSAMPLE ESTIMATES QUOTED IN DISCUSSION OF RESULTS IN SECTION 5.4 ARE ARRIVED AT HERE
gen post2013 = year>=2013 

foreach depvar in pct_votes_UKIP UKIPPct  {
estimates clear

foreach fe in "ryr" {
estimates clear
foreach var in totalimpact  taxcredits childbenefit counciltaxbenefit  disabilitylivingallow bedroom_tax  { 
foreach yr in 2010 2013 {
gen temp = post`yr' * `var'_finlosswap

eststo: reghdfe `depvar' temp, absorb(id `fe')  vce(cl id) nocons
lincom temp
gen fitted_val = `r(estimate)' * `var'_finlosswap
su fitted_val
estadd local avg = substr("`r(mean)'",1,5)
drop temp fitted_val 

}
}

esttab using "tables/impact-estimates-`depvar'.tex", replace  nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg  ymean N_clust1 N , labels("Avg insample effect" "Mean of DV" "Local authority districts" "Observations" ) fmt(%9.3g)) nonumbers

}
}


*********************
*** TABLE C1 
*********************

foreach fe in "ryr"   {

foreach var in  QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh { 

estimates clear 

foreach depvar in pct_votes_UKIP  pct_turnout  pct_votes_Con pct_votes_Lab pct_votes_LD     {

eststo: reghdfe `depvar'  c.post2010#c.`var' ,  absorb(id `fe' )   vce(cl id) old
estadd ysumm

}


esttab using "tables/localpol-`var'-did-`fe'.tex",   replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers substitute(% \%)
}

}



*********************
*** TABLE C2 
*********************

foreach fe in "ryr"   {

foreach var in  QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh { 

estimates clear 

foreach depvar in UKIPPct  TurnoutPct  ConPct LabPct LDPct     {

eststo: reghdfe `depvar'  c.post2010#c.`var' ,  absorb(id `fe' )   vce(cl id) old
estadd ysumm

}


esttab using "tables/europeanparliamentary-`var'-did-`fe'.tex",   replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers substitute(% \%)
}

}


*********************
*** TABLE C4 
*********************
preserve
keep if year<=2012
foreach fe in "ryr"   {

foreach var in  QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh { 

estimates clear 

foreach depvar in pct_votes_UKIP  pct_turnout  pct_votes_Con pct_votes_Lab pct_votes_LD     {

eststo: reghdfe `depvar'  c.post2010#c.`var' ,  absorb(id `fe' )   vce(cl id) old
estadd ysumm

}


esttab using "tables/localpol-`var'-did-`fe'-pre2012.tex",   replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers substitute(% \%)
}

}

restore


*********************
***
*** MULTIPLIER ESTIMATES
***
*********************

preserve

*RESCALE IN 1000 OF POUNDS
foreach var in GVA_Allindustripc GVA_Distributionpc GVA_Publicadminpc GVA_Manufacturinpc GVA_Businessserpc GVA_Constructionpc GVA_Financialanpc {
replace `var' = `var'/1000
}


replace totalimpact_finlosswap = totalimpact_finlosswap/1000


*********************
*** TABLE A3: MULTIPLIER EFFECT ESTIMATES
*********************

foreach var in totalimpact  { 
estimates clear
foreach depvar in GVA_Allindustripc GVA_Distributionpc GVA_Publicadminpc GVA_Manufacturinpc GVA_Businessserpc GVA_Constructionpc GVA_Financialanpc {

eststo: reghdfe log`depvar' c.post2010#c.`var'_finlosswap , absorb(id ryr)  vce(cl id) nocons

capture confirm variable `var'_finlosswap
if !_rc {
qui su `var'_finlosswap if e(sample)
estadd local avgloss = substr(string(round(`r(mean)',.01)),1,5)
}
qui su `depvar'
estadd local gva_size = substr(string(round(`r(mean)',0.01)),1,5)
local meandep = `r(mean)'

su `var'_finlosswap
lincom (c.post2010#c.`var'_finlosswap * `meandep')
estadd local multipliers = substr(string(round(`r(estimate)',0.01)),1,5)
local standarderror = substr(string(round(`r(se)',0.01)),1,5)
estadd local multiplierse =  "(`standarderror')"

*estadd local star = "`star'"
}

esttab using "tables/did-multipliers-`var'-ryr.tex",  replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(gva_size multipliers multiplierse N_clust1 N , labels("\hline Sector GVA" "Implied multiplier effect" " " "\hline Local election districts" "Observations" ) fmt(%9.3g)) nonumbers 
}

restore



*********************
*** FIGURE A4
*********************
local partialout=""
local partial = ""
local partialedout=""

foreach depvar in logGVA_Allindustripc  {
foreach fe in "ryr"  {
foreach var in  totalimpact_finlosswapyr {
preserve
replace `var' = `var'
local lab: variable label `var' 
local shorter = substr("`var'", 1,20)
forvalues i=1(1)16 {
gen yyin_`shorter'_`i' = yy_`i' * `var'
}
if("`partialout'"!="") {
local temp = subinstr("`partialout'","`var'", "",.) 
local count: word count `temp' 
local partial = ""
forvalues i=1(1)`count' { 
local varpartial : word `i' of `temp'
local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1- yyin_`shorter'_10 o.yyin_`shorter'_11 yyin_`shorter'_12-yyin_`shorter'_16 `partial' , absorb(id `fe')  vce(cl id)
if("`partialout'"!="") {
local pp = subinstr("`partialout'"," ","-",.)
local partialedout = "-partialout-`pp'"
}
esttab using "tables/timeeffects/`depvar'-did-`var'`partialedout'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(N_clust1 N , labels("Local election districts" "Observations" ) fmt(%9.3g)) nonumbers
matrix hrid = J(80 ,6, 0)
global iter = 1
forvalues i=1(1)16 {
 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 matrix hrid[$iter, 5] = `r(N)'

 global iter=$iter+1
 }
 svmat hrid
sort hrid1
replace hrid6 = hrid3
su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0
su hrid1
sort hrid1
twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/`depvar'-did-`var'`partialedout'-`fe'.eps",  replace
restore
}
}
} 





*********************
*** FIGURE C2 
*********************
local partial = ""
local partialedout=""
foreach depvar in UKIPPct    {
foreach fe in "ryr"  {
foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh  {
preserve
local lab: variable label `var' 
local shorter = substr("`var'", 1,20)
forvalues i=1(1)3 {
gen yyin_`shorter'_`i' = Year_`i' * `var'
}
if("`partialout'"!="") {
local temp = subinstr("`partialout'","`var'", "",.) 
local count: word count `temp' 

local partial = ""
forvalues i=1(1)`count' { 
local varpartial : word `i' of `temp'
local partial = "`partial' i.year#c.`varpartial'"
}
}

di "`partial'"
estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1  o.yyin_`shorter'_2  yyin_`shorter'_3   , absorb(id `fe')  vce(cl id)

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)3 {
 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if Year_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 matrix hrid[$iter, 5] = `r(N)'
 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0
su hrid1
sort hrid1

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/ep-`depvar'-did-`var'`partialedout'-`fe'.eps",  replace
restore
}
}
} 


*********************
*** REMAINING PANELS FIGURES AND TABLES USING WESTMINSTER ELECTION DATA 
*********************

preserve

use "data files/WESTMINSTER.dta",clear

encode pcon14cd, gen(pcon)
keep if year<2017
gen post2010 = year>2010 


*********************
*** PANEL C OF TABLE 1 AND PANEL C OF TABLE A2 
*********************

foreach depvar in ukip {
foreach fe in "ryr" "i.pcon#c.year ryr" {
estimates clear
foreach var in totalimpact  taxcredits childbenefit counciltaxbenefit  disabilitylivingallow bedroom_tax  { 

gen temp = post2010 * `var'_finloss

eststo: reghdfe `depvar' temp, absorb(pcon `fe')  vce(cl pcon) nocons
estadd ysumm

lincom temp
gen fitted = `r(estimate)' *  `var'_finloss
su fitted
estadd local avg = substr("`r(mean)'",1,5) 
estadd local sd = substr("`r(sd)'",1,5)   
drop fitted
drop temp        
}
local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp","i.","",.)
global temp = subinstr("$temp","#"," ",.)
global temp = subinstr("$temp"," ","-",.)
esttab using "tables/did-westminster-ukip-$temp.tex", replace coeflabels(temp "$\mathbb{1}$(Year$>$2010) $\times$ Austerity") nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(avg sd ymean N_clust1 N , labels("Avg effect" "SD" "Mean of DV" "Harmonized Constituencies" "Observations" ) fmt(%9.3g)) nonumbers
}
}


*********************
*** PANEL C OF TABLE A4 
*********************

sort pcon year
*2010 - 2015 difference
by pcon: gen dchukip = ukip - ukip[_n-1]

foreach indepvar in dchukip {
estimates clear

foreach fe in "Region"  {
estimates clear
foreach var in totalimpact    { 

gen temp = `var'_finloss
gen toinstr = `indepvar'

eststo: reghdfe X2016_Leave_vote  temp if year==2015 & temp!=. & toinstr!=. , absorb(`fe')  vce(cl pcon) old 
estadd ysumm

eststo: reghdfe X2016_Leave_vote  toinstr if year==2015 & temp!=. & toinstr!=., absorb(`fe')  vce(cl pcon) old 
estadd ysumm

eststo: reghdfe X2016_Leave_vote temp toinstr if year==2015& temp!=. & toinstr!=. , absorb(`fe')  vce(cl pcon) old 
estadd ysumm

drop temp        
drop toinstr        

}

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`fe'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp","i.","",.)
global temp = subinstr("$temp","#"," ",.)

global temp = subinstr("$temp"," ","-",.)

esttab using "tables/cross-section-both-`indepvar'-$temp.tex", replace coeflabels(temp "Austerity" toinstr "$\Delta UKIP$") nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean  N , labels("Mean of DV"  "Observations" ) fmt(%9.3g)) nonumbers

}
}



*********************
*** FIGURE A2 
*********************

tab year, gen(yy_)


foreach depvar in ukip  {
foreach fe in "ryr"  {
foreach var in  bedroom_tax_finlosswapyr counciltaxbenefit_finlosswapyr disabilitylivingallow_finlosswp    totalimpact_finlosswapyr {

local lab: variable label `var' 

local shorter = substr("`var'", 1,20)

forvalues i=1(1)4 {

gen yyin_`shorter'_`i' = yy_`i' * `var'
}

estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1  yyin_`shorter'_2 o.yyin_`shorter'_3 yyin_`shorter'_4  , absorb(pcon `fe')  vce(cl pcon14cd)

esttab using "tables/timeeffects/westminster-`depvar'-did-`var'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(N_clust1 N , labels("Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)4 {

 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 * matrix hrid[$iter, 1] = `i'
 matrix hrid[$iter, 5] = `r(N)'

 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0

 
su hrid1
sort hrid1

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`var'-`fe'`ext'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp"," ","-",.)

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2011)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/westminster-`depvar'-did-`var'-`fe'.eps",  replace

drop hrid*
}
}
} 




*********************
*** FIGURE C1 
*********************


foreach depvar in ukip  {
foreach fe in "ryr"  {
foreach var in  RoutineOccAll_sh DManufAll_sh GRetailAll_sh QUAL_ALL_noq_sh {

local lab: variable label `var' 

local shorter = substr("`var'", 1,20)

forvalues i=1(1)4 {

gen yyin_`shorter'_`i' = yy_`i' * `var'
}

estimates clear 
eststo: reghdfe `depvar'  yyin_`shorter'_1  yyin_`shorter'_2 o.yyin_`shorter'_3 yyin_`shorter'_4  , absorb(pcon `fe')  vce(cl pcon14cd)

esttab using "tables/timeeffects/westminster-`depvar'-did-`var'-`fe'.tex", replace nolines nomtitles fragment nowrap  label nodepvars noobs  starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(N_clust1 N , labels("Local election districts" "Observations" ) fmt(%9.3g)) nonumbers

matrix hrid = J(80 ,6, 0)

global iter = 1
forvalues i=1(1)4 {

 lincom yyin_`shorter'_`i'
 matrix hrid[$iter,3] = `r(estimate)'
 matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
 matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
 su year if yy_`i'== 1
 matrix hrid[$iter, 1] = `r(mean)'
 * matrix hrid[$iter, 1] = `i'
 matrix hrid[$iter, 5] = `r(N)'

 global iter=$iter+1
 }

 svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0

 
su hrid1
sort hrid1

local fe = subinstr("`fe'"," ","-",.)
global temp = subinstr("`var'-`fe'`ext'","##c.","-",.)
global temp = subinstr("$temp","c.","",.)
global temp = subinstr("$temp"," ","-",.)

twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2011)) (rcap hrid2 hrid4 hrid1 if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1 , yline(0,lpattern(dash) lcolor(gray)) ytitle("Coefficient estimate", axis(1))) , scheme(s1color) legend(off) xtitle("Year", size(4)) yscale(range(`miny' `maxy') )  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[3]`r(max)')  
graph export "figures/westminster-`depvar'-did-`var'-`fe'.eps",  replace

drop hrid*
}
}
} 


*********************
*** ONLINE APPENDIX TABLE C3 
*********************

foreach fe in "ryr"   {

foreach var in  QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh { 

estimates clear 

foreach depvar in ukip  turnout  con lab ld     {

eststo: reghdfe `depvar'  c.post2010#c.`var' ,  absorb(pcon `fe' )   vce(cl pcon) old
estadd ysumm

}


esttab using "tables/westminster-`var'-did-`fe'.tex",   replace nolines nomtitles  fragment nowrap   label nodepvars noobs    starlevels("" 0.10 "" 0.05 "" 0.01) collabels(none) style(tex) cells(b(star fmt(%9.3f)) se(par)) stats(ymean N_clust1 N  , labels("Mean of DV" "Local election districts" "Observations" ) fmt(%9.3g)) nonumbers substitute(% \%)
}

}

restore





