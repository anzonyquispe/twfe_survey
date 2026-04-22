#delimit;
**************************************************************************************************************
* supplanalysis_hhsurveydata.do
* 
* estimates effects of electrification on employment (intensive and extensive margin) and wages
* using cross sectional hh survey data from ohs 95, ohs 97, ohs 99, September LFS 01.
* Produces TABLE 7 in main paper, FIGURES 2A and 2B

* all data may be obtained from statistics south africa or (with relevant permissions) from DataFirst at the University of Cape Town
**************************************************************************************************************
/* The dataset provided here is the cleaned version containing multiple waves of the OHS and LFS. 

Sample selection: for each dataset, I select workers in rural KZN who are African, age 20-60.

Variable construction: I define the following variables as consistently as possibly over the waves: 

edyears = years of education starting at 0 up to 12 for completed high school, and 11/12/15 years for post matric qualifications
age 
gender= male or female
perswgt = person weight 
elec= indicator for whether household uses electric lighting as main source of lighting
work = extensive margin definition of work, i.e. work in the past week (an official definition)
hoursusual = usual hours of work per week if hours <98 and if adult is a worker  (I eliminates outliers). 
monthlyearn = for workers, self-reported income converted to monthly quantity using self-reported pay frequencies. 
monthlyearn is imputed for workers who only give an income bracket; i impute the middle of the income bracket
wage = for workers, weekly income/weekly usual hours of work per week = hourly wage
md = magisterial district
*/;

* set up extraction;
cap program drop extractnostar;
program define extractnostar;
	outreg2 $list1 $list2 using "$temp\result_$y.out",
	nolabel se noaster bdec(6) rdec(3)
	$addstat $which;
end;
#delimit cr


use "$data\hhsurveydata.dta", clear
drop if year==1996
tab year, gen(t)
sort year hhid
gen hhmark=1 if hhid!=hhid[_n-1]
gen temp=elec if hhmark==1

replace hours=. if work==0

* create mean md eleclighting rate
egen mdelec=mean(temp), by(md_code year)
gen mdelec2=mdelec

* some md's are not covered in some years
* exclude all these md's from each year of analysis - they have few/no rural african hhs
tab md_code year

#delimit;
replace mdelec2=. if 
(md_code==513|
md_code==519|
md_code==524|
md_code==527|
md_code==530|
md_code==540|
md_code==543|
md_code==544);
#delimit cr

tab year, sum(mdelec)
tab year, sum(mdelec2)
* use mdelec2 in regressions: excluding the mds that have some missing obs

gen trend=year-1995
recode trend (2=1) (4=2) (6=3)

gen female=1 if sex==0
replace female=0 if sex==1
gen femtrend=female*trend
gen femmdelec=female*mdelec2

gen femt1=t1*female
gen femt2=t2*female
gen femt3=t3*female
gen femt4=t4*female


***************************************
* Figure 2: Trends in employment and wages by sex and year
***************************************
/* These graphs are for the sample of African men and women 20-59 who report
that they work and report income/earnings values per month in the LFS and the OHS between 1995 
and 2001. These workers live in rural areas of KZN*/

* graphs with proper s.e. bars
cap program drop graphbetas
program define graphbetas
lincom _cons
matrix menwork=[r(estimate),r(se)]
lincom _cons+t2
matrix menwork=[menwork\r(estimate),r(se)]
lincom _cons+t3
matrix menwork=[menwork\r(estimate),r(se)]
lincom _cons+t4
matrix menwork=[menwork\r(estimate),r(se)]

lincom _cons+female
matrix femwork=[r(estimate),r(se)]
lincom _cons+female+t2+femt2
matrix femwork=[femwork\r(estimate),r(se)]
lincom _cons+female+t3+femt3
matrix femwork=[femwork\r(estimate),r(se)]
lincom _cons+female+t4+femt4
matrix femwork=[femwork\r(estimate),r(se)]

matrix list menwork
matrix list femwork
end

** work and wages at district level 
reg work female t2 t3 t4 femt2 femt3 femt4, robust cluster(md_code)
global list1="female t2 t3 t4 femt2 femt3 femt4"
global which="replace"
extractnostar
graphbetas
global which="append"
reg logwage female t2 t3 t4 femt2 femt3 femt4, robust cluster(md_code)
extractnostar
graphbetas

******************************************************************************
* regressions for general trends across high and low mdelec areas
******************************************************************************
* Separately for men and women: 
* compare places with high and low mdelec
* without and with mdfe and mdrend, overall trend and female*trend 
* absorb all possible other sort of variation , look at coeff on female*mdelec

cd "$temp\"
global which="replace"
global xvar="age age2 edyears"
global list1="mdelec2 trend"
global fe="md2-md46 mdtrend2-mdtrend46"
global list2=""
global qualiff="if female==1"
global qualifm="if female==0"
global yvars="work hoursusual logwage logearning"
global se = "robust cluster(md_code)"
global wt ="[aw=perswgt]"

foreach one of global yvars {
	preserve
	global y="`one'"
	xi: reg $y $xvar if mdelec2!=. [aw=perswgt]
	predict eresid if e(sample), resid
	collapse eresid mdelec2 $wt , by(trend md_code female)
	global which="replace"
	gen femtrend=female*trend	
	tab md_code, gen(md)
	local i = 1
	while `i'<=46 {
		gen mdtrend`i'=md`i'*trend		
		local i = `i'+1
	}
	gen femelec=female*mdelec2

	xi: reg eresid $list1 $qualiff, $se /* OLS */
	sum mdelec2 eresid if e(sample)
	extractnostar
	global which="append"
	xi: reg eresid $list1 $fe $qualiff, $se /* FE */
	extractnostar
	sum mdelec2 eresid if e(sample)
	xi: reg eresid $list1 $qualifm, $se /* OLS */
	sum mdelec2 eresid if e(sample)
	extractnostar
	xi: reg eresid $list1 $fe $qualifm, $se /* FE */
	sum mdelec2 eresid if e(sample)
	extractnostar

	global list2="femelec female femtrend"
	xi: reg eresid $list1 $list2, $se	/* OLS, male and female combined */
	sum mdelec2 eresid if e(sample)
	extractnostar

	di "JOINT F TEST FOR OLS MODEL"
	test femelec mdelec2
	test femelec + mdelec2 = 0

	xi: reg eresid $list1 $list2 $fe, $se /* FE, male and female combined */
	sum mdelec2 eresid if e(sample)
	extractnostar
	global which="replace"
	global list2=""
	tab trend if e(sample), sum(mdelec2)
	codebook md_code if e(sample)

	di "JOINT F TEST FOR FE MODEL"
	test femelec mdelec2
	test femelec + mdelec2 = 0
	restore
}

clear
exit

