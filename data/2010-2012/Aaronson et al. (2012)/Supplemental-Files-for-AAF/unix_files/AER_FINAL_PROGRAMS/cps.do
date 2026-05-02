// Program to replicate Aaronson, Agarwal, French Minimum Wage Results
// that use the Current Population Survey. 

cd "/users/jdavis/home/minwage/replication"

clear all
set mem 3g
capture log close

log using id-prepare_79.log, replace

use ogr_select.dta

********* DATA RESTRICTIONS **********
keep if year>=1979 & year<=2007

***********************************************
* Variable Fixes that Are No Longer Necessary *
***********************************************
replace hhid = trim(hhid)
replace stname=trim(stname)

*********************************************
* Drop Periods Where Matching is Impossible *
*********************************************
drop if mis==4 & year==1984 & month>=7 & month<=12 
drop if mis==8 & year==1985 & month>=7 & month<=12
drop if mis==4 & year==1985 & month>=1 & month<=9
drop if mis==8 & year==1986 & month>=1 & month<=9
drop if mis==4 & year==1994 & month>=6 & month<=12
drop if mis==8 & year==1995 & month>=6 & month<=12
drop if mis==4 & year==1995 & month>=1 & month<=8
drop if mis==8 & year==1996 & month>=1 & month<=8

*Drop if data aren't usable
drop if  age==-1 & relhd==-1 & lineno==-1
drop if  age==. & relhd==. & lineno==.
count if age==. | age==-1 | relhd==-1 | relhd==. |lineno==-1|lineno==.

drop if length(hhid)<8


********* Generate State FIPS Variable **************

*fix a bug with Maine and New Hampshire 
replace stname = substr(stname, 1, 5) if substr(stname, 1, 5)=="Maine" 
replace stname = substr(stname, 1, 13) if substr(stname, 1, 13)=="New Hampshire" 

gen state = "" 
 replace state="01"  if stname=="Alabama" 
 replace state="02"  if stname=="Alaska" 
 replace state="04"  if stname=="Arizona" 
 replace state="05"  if stname=="Arkansas" 
 replace state="06"  if stname=="California" 
 replace state="08"  if stname=="Colorado" 
 replace state="09"  if stname=="Connecticut" 
 replace state="10"  if stname=="Delaware" 
 replace state="11" if stname=="Washington, D.C." 
 replace state="12" if stname=="Florida" 
 replace state="13" if stname=="Georgia" 
 replace state="15" if stname=="Hawaii" 
 replace state="16" if stname=="Idaho" 
 replace state="17" if stname=="Illinois" 
 replace state="18" if stname=="Indiana" 
 replace state="19" if stname=="Iowa" 
 replace state="20" if stname=="Kansas" 
 replace state="21" if stname=="Kentucky" 
 replace state="22" if stname=="Louisiana" 
 replace state="23" if stname=="Maine" 
 replace state="24" if stname=="Maryland" 
 replace state="25" if stname=="Massachusetts" 
 replace state="26" if stname=="Michigan" 
 replace state="27" if stname=="Minnesota" 
 replace state="28" if stname=="Mississippi" 
 replace state="29" if stname=="Missouri" 
 replace state="30" if stname=="Montana" 
 replace state="31" if stname=="Nebraska" 
 replace state="32" if stname=="Nevada" 
 replace state="33" if stname=="New Hampshire" 
 replace state="34" if stname=="New Jersey" 
 replace state="35" if stname=="New Mexico" 
 replace state="36" if stname=="New York" 
 replace state="37" if stname=="North Carolina" 
 replace state="38" if stname=="North Dakota" 
 replace state="39" if stname=="Ohio" 
 replace state="40" if stname=="Oklahoma" 
 replace state="41" if stname=="Oregon" 
 replace state="42" if stname=="Pennsylvania" 
 replace state="44" if stname=="Rhode Island" 
 replace state="45" if stname=="South Carolina" 
 replace state="46" if stname=="South Dakota" 
 replace state="47" if stname=="Tennessee" 
 replace state="48" if stname=="Texas" 
 replace state="49" if stname=="Utah" 
 replace state="50" if stname=="Vermont" 
 replace state="51" if stname=="Virginia" 
 replace state="53" if stname=="Washington" 
 replace state="54" if stname=="West Virginia" 
 replace state="55" if stname=="Wisconsin" 
 replace state="56" if stname=="Wyoming" 
tab stname if state==""
drop stname 

 gen mon = string(month) 
 replace mon = "0"+mon if month < 10 

gen num = string(hhnum)
 
gen uhhid = state+hhid+num+mon if (year < 2003) | (year==2003 & mis==8) | (year==2003 & mis==4 & month<5) | (year==2004 & mis==8 & month<5) | (year==2004 & mis==4 & month<5) | (year==2005 & mis==8 & month<5) 
replace uhhid = state+hhid+mon if (year==2003 & mis==4 & month>=5) | (year==2004 & mis==8 & month>=5) 
replace uhhid = state+hhid+hhid2+mon if (year==2004 & mis==4 & month>=5) | (year==2005 & mis==8 & month>=5) | (year==2005 & mis==4) | (year >2005) 


* Note that there are some observations where hhnum is a valid missing,
* we assume that this corresponds to the same family once the other id variables
* (_hhid month state lineno and year) are matched. If we drop all of these
* observations, the sample size is slightly smaller but the results do not change
* in a meaningful way.				
replace hhnum = 0 if (year==2003 & mis==4 & month>=5 | year==2004 & mis==8 & month>=5) | (year==2004 & mis==4 & month>=5 | year==2005 & mis==4 | year==2005 & month>=5 & mis==8 | year>2005)
 
 gen _hhid = ""
 replace _hhid = hhid if (year<2004 | year==2004 & mis==8 | year==2004 & mis==4 & month<5 | year==2005 & mis==8 & month<5)
 replace _hhid = hhid+hhid2 if (year==2004 & mis==4 & month>=5 | year==2005 & mis==4 | year==2005 & month>=5 & mis==8 | year>2005)
 global id "_hhid month state hhnum lineno year"


************************
* Check for duplicates *
************************
duplicates tag $id, gen(dup)
tab year
tab year if dup~=0
gen duphh = 1 if dup>0 & (relhd==1 | relhd==2)
bysort _hhid month state hhnum year: egen drophh = min(duphh)
drop if drophh==1
drop if dup>0 
drop dup duphh drophh

******************************************
* Create Household Weights for 1979-1988 *
******************************************

/**********************************************************
 * From CPS Utilities hhwgt entry: 					      *
 * The final household weight equals the weight of the    *
 * wife in a husband-wife household and it equals the     *
 * weight of the reference person in all other households.*
 **********************************************************/
 
 *Wife is spouse in husband-wife household
 gen temp = wgt if relhd==3 & female==1 & year<1989 & hhwgt==.
 bysort _hhid month state hhnum year: egen htemp = min(temp)
 replace hhwgt = htemp if year<1989 & hhwgt==.
 drop temp htemp
 
 *Reference person if not in a husband-wife household
 gen temp = wgt if (relhd==1 | relhd==2)  & year<1989 & hhwgt
 bysort _hhid month state hhnum year: egen htemp = min(temp)
 replace hhwgt = htemp if year<1989 & hhwgt==.
 drop temp htemp
 
 tab year if hhwgt~=.
 tab year if hhwgt==.
 drop if hhwgt==.
 
 sort $id
 save ogr_uhhid-minwage_79.dta, replace
 log close


 log using cps_match.log, replace

 clear
 use ogr_uhhid-minwage_79.dta

 
*  Drop all boarders/roomers housemate/roommate since we assume they don't  contribute to the head's and head's relatives' finances
 drop if relhd>14

**** Generate Count of Kids and Adults ****
gen child=. 
gen adult=. 
 replace child=1 if age<18 
 replace adult=1 if age>=18 

bysort _hhid month state hhnum year: egen kids=count(child)
bysort _hhid month state hhnum year: egen adults=count(adult)
drop child adult


*********
* Wages *
*********

replace ernhr = ernhr/100 if ernhr~=-1
gen wage = ernhr if ernhr~=-1

gen hours = .
replace hours = hoursu1 if year>=1994 & hoursu1>=0  //Usual weekly hours at main job
replace hours = hours1 if year>=1994 & hoursu1==-4 & hours1>=0 // Hours last week at main job if usual hours vary
replace hours = ernush if year<1994 & ernush>=0 // Usual hours worked per week

drop ernhr hoursu1 hours1 ernush 

gen qtrincome = wage*hours*13 //Weekly Wage * 13 since 13 weeks per quarter
label var qtrincome "Hourly Wage x Usual Hours Per Week x 13"

********************
* Household Income *
********************

bysort _hhid month state hhnum year : egen hincqtr = total(qtrincome)

gen finc = .
 replace finc = 2500   if (year>=1994 & faminc==1) | (year<1994 & faminc==0)
 replace finc = 6250   if (year>=1994 & faminc==2) | (year<1994 & faminc==1)
 replace finc = 8750   if (year>=1994 & faminc==3) | (year<1994 & faminc==2)
 replace finc = 11250  if (year>=1994 & faminc==4) | (year<1994 & faminc==3)
 replace finc = 13750  if (year>=1994 & faminc==5) | (year<1994 & faminc==4)
 replace finc = 16250  if (year<1994 & faminc==5 )
 replace finc = 18750  if (year<1994 & faminc==6 )
 replace finc = 17500  if (year>=1994 & faminc==6)
 replace finc = 22500  if (faminc==7)
 replace finc = 27500  if (faminc==8)
 replace finc = 32500  if (faminc==9)
 replace finc = 37500  if (faminc==10)
 replace finc = 45000  if (faminc==11)
 replace finc = 62500  if (year<1994 & faminc==12)
 replace finc = 55000  if (year>=1994 & faminc==12)
 replace finc = 67500  if (year>=1994 & faminc==13)
 replace finc = 75000  if (year<1994 & faminc==13) | (year>=1994 & year<=2002 & faminc==14) | (year==2003 & month<10 & faminc==14)
 replace finc = 87500  if (year==2003 & month>=10 & faminc==14) | (year>=2004 & faminc==14)
 replace finc = 125000 if (year==2003 & month>=10 & faminc==15) | (year>=2004 & faminc==15)
 replace finc = 150000 if (year==2003 & month>=10 & faminc==16) | (year>=2004 & faminc==16)

gen fincqtr = finc/4

gen f1 = max(hincqtr, fincqtr)
bysort _hhid month state hhnum year : egen F1 = max(f1)
label var F1 "Maximum Household/Family Income across all Household Members"
gen diff = F1-hincqtr

count if diff
count if diff==0
count if diff~=0 & diff~=.
summ diff if diff~=0, detail
summ hincqtr, detail
summ F1, detail

drop diff faminc finc fincqtr f1

count //ogr_next1_79 count
save ogr_next1_79, replace


use ogr_next1_79
******************************************************************************
* Identify Household Head and Highest Earner Who is Over 18 and Not the Head *
******************************************************************************

***************************
* Identify Household Head *
***************************
gen householdhead = 1 if relhd==1 | relhd==2
by _hhid month state hhnum year: egen ties=count(householdhead)
tab ties
drop ties

by _hhid month state hhnum year: egen minlineno_hh = min(lineno) if householdhead==1
gen ishh = 1 if householdhead==1 & lineno==minlineno_hh
by _hhid month state hhnum year: egen ties=count(ishh) 
tab ties
drop ties

***********************
* Identify "Person 2" *
***********************

*Combine husband and wife codes in to one spouse code to be consistent across years
replace relhd = 3 if year>=1989 & year<=1993 & relhd==4

gen nonhead18orover = .
replace nonhead18orover = 1 if relhd~=1 & relhd~=2 & age>=18

*Max Wage of Non-Household Head Over 18
by _hhid month state hhnum year : egen nonheadmaxwage = max(wage) if nonhead18orover==1
gen nonheadhasmaxwage = 1 if float(wage)==float(nonheadmaxwage) & nonhead18orover==1
by _hhid month state hhnum year : egen multiples = count(nonheadhasmaxwage)

*Break Ties by Choosing Person with minimum Relationship to Head Code
by _hhid month state hhnum year : egen minrelhd = min(relhd) if float(wage)==float(nonheadmaxwage) & nonhead18orover==1
gen hasminrelhd = 1 if relhd==minrelhd & nonhead18orover==1



*Count Number of People Who Have Minimum Relationship Code
by _hhid month state hhnum year: egen ties1=count(hasminrelhd) // This is a little different - Old code used count of people with max wage and who are over 18 -> works out the same
tab ties1 // Still a lot of ties

*Minimum Line Number of 18+ Group with Maximum Wage
by _hhid month state hhnum year: egen minlineno_p2 = min(lineno) if float(wage)==float(nonheadmaxwage) & nonhead18orover==1
gen hasminlineno_p2 = 1 if lineno==minlineno_p2
by _hhid month state hhnum year: egen ties2=count(hasminlineno_p2)
tab ties2

*People who are 18+, Have Maximum Wage and Have a Wage Value for the 2nd year
sort _hhid month state hhnum lineno mis
gen fwage = wage[_n+1] if mis==4 & mis[_n+1]==8 & _hhid[_n+1]==_hhid & month[_n+1]==month & state[_n+1]==state & hhnum[_n+1]==hhnum & lineno[_n+1]==lineno & year+1==year[_n+1]
gen choose_p2 = 1 if float(wage)==float(nonheadmaxwage) & nonhead18orover==1 & fwage~=.
sort _hhid month state hhnum year
by _hhid month state hhnum year: egen ties3 = count(choose_p2)
tab ties3, missing


* Break Ties among people with wage in both periods, max wage in first period
by _hhid month state hhnum year: egen minlineno_p2_b = min(lineno) if choose_p2==1
gen _temp = 1 if choose_p2==1 & lineno==minlineno_p2_b
by _hhid month state hhnum year: egen ties4 = count(_temp)
tab ties4
drop _temp ties4


gen person = .
replace person = 1 if ishh==1 //Household Head Equals Household Head with minimum Line Number

replace person = 2 if ties1==1 & hasminrelhd==1 // Person 2 Case 1 - Unique Person with Max Wage and Minimum Relhd
replace person = 2 if ties1>1 & ties1<. & ties3==1 & choose_p2==1 // Person 2 Case 2 - Unique Person with Max Wage and Non-Missing Wage in Both Periods
replace person = 2 if ties1>1 & ties1<. & ties3>1 & ties3<. & lineno==minlineno_p2_b // Person 2 Case 3 - Person with Max Wage, Non-Missing Wage in Both Periods, Minimum Line Number of this group
replace person = 2 if ties1>1 & ties1<. & ties3==0 & lineno==minlineno_p2 // Person 2 Case 4 - All Person 2 Candidates Missing Wage in 2nd Period, Take Minimum Line Number
// Fixed error in case 4 - had ties3==. instead of 0, stata won't allow ties3 to be .

//Other version of person for replication purpopses
gen _person = .
replace _person = 1 if ishh==1
replace _person = 2 if multiples==1 & hasminrelhd==1
replace _person = 2 if multiples>1 & multiples<. & ties3==1 & choose_p2==1
replace _person = 2 if multiples>1 & multiples<. & ties3>1 & ties3<. & lineno==minlineno_p2_b
replace _person = 2 if multiples>1 & multiples<. & ties3==. & lineno==minlineno_p2

tab person _person, missing
drop _person

gen head = 0
replace head = 1 if person==1

//Confirm one last time that only one "person 1" and one "person 2" in each household
gen person1 = 1 if person==1
gen person2 = 1 if person==2
by _hhid month state hhnum year: egen nperson1 = count(person1)
by _hhid month state hhnum year: egen nperson2 = count(person2)
gen npersons = nperson1+nperson2

tab nperson1
tab nperson2
tab npersons mis, missing

drop person1 nperson1 person2 nperson2
drop nonhead18orover nonheadmaxwage minrelhd hasminrelhd ties* minlineno_p2 hasminlineno_p2 minlineno_p2_b choose_p2

count
save ogr_next2_79, replace

drop if mis==4 & person==.

************
* Matching *
************
sort _hhid month state hhnum lineno year 
foreach var of varlist _hhid month state hhnum lineno female nonwhite person npersons {
 gen l`var' = `var'[_n-1]
}

gen dhead = head-head[_n-1]
gen dyear = year-year[_n-1]
gen dage = age-age[_n-1]
gen dmis = mis-mis[_n-1]

gen match = .
 replace match = 1 if _hhid==l_hhid & month==lmonth & state==lstate & hhnum==lhhnum & lineno==llineno ///
                      & female==lfemale & nonwhite==lnonwhite & dmis==4 & dyear==1 & (dage==0 | dage==1) ///
					  & npersons==lnpersons & (lperson==1 | lperson==2) & (dhead==0 | (lperson==2 & head==1))
					  
tab year match if mis==8, missing
count if match==. & mis==8

save temp_matched.dta, replace
log close

log using cps_cleanhhdata.log, replace

use temp_matched.dta
* Drop people who weren't matched
gen fmatch = match[_n+1]
drop if match==. & fmatch==.
drop fmatch match

gen dperson = person-person[_n-1] if mis==8
tab dperson if mis==8, missing
drop dperson 

count
save ogr_next3_79, replace


use ogr_next3_79.dta
************************************************
* Transform Data in to Household Level Dataset *
************************************************  

*Wage
gen w1 = wage if (person==1 & mis==4) | (lperson==1 & mis==8)
gen w2 = wage if (person==2 & mis==4) | (lperson==2 & mis==8)

*Quarterly Income
gen qi1 = qtrincome if (person==1 & mis==4) | (lperson==1 & mis==8)
gen qi2 = qtrincome if (person==2 & mis==4) | (lperson==2 & mis==8)				  

*Hours
gen h1 = hours if (person==1 & mis==4) | (lperson==1 & mis==8)
gen h2 = hours if (person==2 & mis==4) | (lperson==2 & mis==8)				  

*Employment
gen e1 = (mlr==1 | mlr==2) if ~missing(mlr) & ((person==1 & mis==4) | (lperson==1 & mis==8))
gen e2 = (mlr==1 | mlr==2) if ~missing(mlr) & ((person==2 & mis==4) | (lperson==2 & mis==8))				  


* Now Fill in Variables Generated Above for Everyone in the Household
sort _hhid month state hhnum year
by _hhid month state hhnum year : egen wage1 = max(w1)
by _hhid month state hhnum year : egen wage2 = max(w2)
by _hhid month state hhnum year : egen qtrincome1 = max(qi1)
by _hhid month state hhnum year : egen qtrincome2 = max(qi2)
by _hhid month state hhnum year : egen hrs1 = max(h1)
by _hhid month state hhnum year : egen hrs2 = max(h2)
by _hhid month state hhnum year : egen emp1 = max(e1)
by _hhid month state hhnum year : egen emp2 = max(e2)

gen miss1 = 1 if qtrincome1==.
gen miss2 = 1 if qtrincome2==.
 replace qtrincome1 = 0 if qtrincome1==.
 replace qtrincome2 = 0 if qtrincome2==.



*Create Weight
gen wt1 = wgt if person==1 & mis==4
by _hhid month state hhnum year: egen wgt1 = max(wt1) if mis==4
drop wt1

*************************************
* Generate Variables for Exclusions *
*************************************
by _hhid month state hhnum year: egen npersons_matched = count(month)

gen firstyear = .
replace firstyear = year if mis==4
replace firstyear = year-1 if mis==8

*Self Employed
by _hhid month state hhnum year: egen hselfemp = max(selfemp)

*Age of Household Head - This was modified to account for households where only 2nd person is matched
gen age1 = age if person==1
replace age1 = age if person==2 & npersons_matched==1 
replace age1 = age if lperson==2 & npersons_matched==1 & person==. 
by _hhid month state hhnum year: egen agehead = max(age1)

count if missing(agehead)
count if missing(agehead) & mis==4
gen noagehead = agehead==.
bysort _hhid month state hhnum firstyear: egen _noagehead = max(noagehead)
list  _hhid month state hhnum year mis person agehead age dage if _noagehead==1
drop _noagehead noagehead

*Household Head Has No College at Start of the Sample
gen nocollege = . 
replace nocollege = 1 if person==1 & edgrp<=2 & mis==4
replace nocollege = 0 if person==1 & edgrp>=3 & mis==4
bysort _hhid month state hhnum year: egen nocollege1 = max(nocollege)


*Limit Sample to One Household Member
sort  _hhid month state hhnum year lineno
by _hhid month state hhnum year: keep if lineno==lineno[1]

ds

*keep _hhid month state hhnum year mis ///
	 wage1 wage2 hincqtr qtrincome1 qtrincome2 hrs1 hrs2 emp1 emp2 F1 ///
	 kids adults hselfemp agehead nocollege1  ///
	 hhwgt wgt1 miss1 miss2
	 

	 
count
save ogr_next4_79, replace


use ogr_next4_79
*******************************
* Bring in State Minimum Wage *
*******************************

destring state, replace
sort state year month
merge state year month using mw7909a, keep(minwage)
tab _m
drop if _m==2




************* GENERATE S *****************
* The share of income coming from jobs   *
* paying less than 120% of minimum wage. *
******************************************

gen ratio1 = wage1/minwage if mis==4
gen ratio2 = wage2/minwage if mis==4

gen earnmw1 = 0
replace earnmw1 = 1 if ratio1<=1.2
replace earnmw1 = . if ratio1==. & ratio2==.

gen earnmw2 = 0
replace earnmw2 = 1 if ratio2<=1.2
replace earnmw2 = . if ratio1==. & ratio2==.

gen sharemw = (qtrincome1*earnmw1+qtrincome2*earnmw2)/F if mis==4
 replace sharemw = 1 if (qtrincome1*earnmw1+qtrincome2*earnmw2)>0 & (qtrincome1*earnmw1+qtrincome2*earnmw2)<. & F<=0

 
 
 
 
************* GENERATE S' *****************
* The share of income coming from jobs    *
* paying 120-300% of minimum wage.        *
*******************************************

gen earnmw1_120300 = 0
replace earnmw1_120300 = 1 if ratio1>1.2 & ratio1<=3
replace earnmw1_120300 = . if (ratio1<=1.2 & qtrincome1>0 & qtrincome1<. | ratio2<=1.2 & qtrincome2>0 & qtrincome2<.) | (ratio1==. & ratio2==.)

gen earnmw2_120300 = 0
replace earnmw2_120300 = 1 if ratio2>1.2 & ratio2<=3
replace earnmw2_120300 = . if (ratio1<=1.2 & qtrincome1>0 & qtrincome1<. | ratio2<=1.2 & qtrincome2>0 & qtrincome2<.) | (ratio1==. & ratio2==.)

gen sharemw_120300 = (qtrincome1*earnmw1_120300+qtrincome2*earnmw2_120300)/F if mis==4
 replace sharemw_120300 = 1 if (qtrincome1*earnmw1_120300+qtrincome2*earnmw2_120300)>0 & (qtrincome1*earnmw1_120300+qtrincome2*earnmw2_120300)<. & F<=0

 
 
 
 
 
************* GENERATE S'' ******************
* The share of income coming from jobs      *
* paying 200-300% of minimum wage.          *
*********************************************

gen earnmw1_200300 = 0
replace earnmw1_200300 = 1 if ratio1>2 & ratio1<=3
replace earnmw1_200300 = . if (ratio1<=2 & qtrincome1>0 & qtrincome1<. | ratio2<=2 & qtrincome2>0 & qtrincome2<.) | (ratio1==. & ratio2==.)

gen earnmw2_200300 = 0
replace earnmw2_200300 = 1 if ratio2>2 & ratio2<=3
replace earnmw2_200300 = . if (ratio1<=2 & qtrincome1>0 & qtrincome1<. | ratio2<=2 & qtrincome2>0 & qtrincome2<.) | (ratio1==. & ratio2==.)

gen sharemw_200300 = (qtrincome1*earnmw1_200300+qtrincome2*earnmw2_200300)/F if mis==4
 replace sharemw_200300 = 1 if (qtrincome1*earnmw1_200300+qtrincome2*earnmw2_200300)>0 & (qtrincome1*earnmw1_200300+qtrincome2*earnmw2_200300)<. & F<=0

 
 
 
 
************* GENERATE S''' *****************
* The share of income coming from jobs      *
* paying 120-200% of minimum wage.          *
*********************************************

gen earnmw1_120200 = 0
replace earnmw1_120200 = 1 if ratio1>1.2 & ratio1<=2
replace earnmw1_120200 = . if (ratio1<=1.2 & qtrincome1>0 & qtrincome1<. | ratio2<=1.2 & qtrincome2>0 & qtrincome2<.) | (ratio1==. & ratio2==.)

gen earnmw2_120200 = 0
replace earnmw2_120200 = 1 if ratio2>1.2 & ratio2<=2
replace earnmw2_120200 = . if (ratio1<=1.2 & qtrincome1>0 & qtrincome1<. | ratio2<=1.2 & qtrincome2>0 & qtrincome2<.) | (ratio1==. & ratio2==.)

gen sharemw_120200 = (qtrincome1*earnmw1_120200+qtrincome2*earnmw2_120200)/F if mis==4
 replace sharemw_120200 = 1 if (qtrincome1*earnmw1_120200+qtrincome2*earnmw2_120200)>0 & (qtrincome1*earnmw1_120200+qtrincome2*earnmw2_120200)<. & F<=0

 
gen tot_inc = qtrincome1 + qtrincome2

 
**** real values of income. pce deflator, chain weighted. revised in 2009.


gen pce = 0

 replace pce=0.4212 if year == 1979
 replace pce=0.4664 if year == 1980
 replace pce=0.5081 if year == 1981
 replace pce=0.5362 if year == 1982
 replace pce=0.5592 if year == 1983
 replace pce=0.5804 if year == 1984
 replace pce=0.5994 if year == 1985
 replace pce=0.6140 if year == 1986
 replace pce=0.6359 if year == 1987
 replace pce=0.6612 if year == 1988
 replace pce=0.6899 if year == 1989
 replace pce=0.7215 if year == 1990
 replace pce=0.7476 if year == 1991
 replace pce=0.7695 if year == 1992
 replace pce=0.7864 if year == 1993
 replace pce=0.8027 if year == 1994
 replace pce=0.8204 if year == 1995
 replace pce=0.8383 if year == 1996
 replace pce=0.8539 if year == 1997
 replace pce=0.8621 if year == 1998
 replace pce=0.8760 if year == 1999
 replace pce=0.8978 if year == 2000
 replace pce=0.9149 if year == 2001
 replace pce=0.9274 if year == 2002
 replace pce=0.9462 if year == 2003
 replace pce=0.9710 if year == 2004
 replace pce=1.0000 if year == 2005
 replace pce=1.0275 if year == 2006
 replace pce=1.0550 if year == 2007
 replace pce=1.0903 if year == 2008

 
 tab year if pce~=0
 tab year  
gen wage1nom = wage1
gen wage2nom = wage2

replace qtrincome1 = qtrincome1 / pce 
replace qtrincome2 = qtrincome2 / pce 
replace wage1 = wage1 / pce
replace wage2 = wage2 / pce 
replace F1 = F1 / pce 
replace hincqtr = hincqtr / pce 
replace minwage = minwage / pce 
replace tot_inc = tot_inc / pce  
 
summ hincqtr, detail 
summ qtrincome1, detail 
summ qtrincome2, detail 
summ tot_inc, detail 

gen qtr = . 
 replace qtr=1 if month>=1 & month<=3 
 replace qtr=2 if month>=4 & month<=6 
 replace qtr=3 if month>=7 & month<=9 
 replace qtr=4 if month>=10 & month<=12 

tab year, gen(y)
tab qtr, gen(q) 

count
save ogr_next5_79_300, replace

**************
* Exclusions *
**************

replace hhnum = 0 if hhnum==.
sort _hhid month state hhnum year
egen id = group(_hhid month state hhnum firstyear)
bysort id: egen seq = seq()
tab seq
drop seq
bysort id: egen seq = seq() if mis==4
tab seq
drop seq
bysort id: egen seq = seq() if mis==8
tab seq
drop seq


duplicates tag _hhid month state hhnum, generate(dup)
duplicates tag _hhid month state hhnum year, generate(dupyear)

tab dup, missing
tab dupyear, missing

gen drop = .

replace drop = 1 if state==. 
replace drop = 1 if miss1==1 & miss2==1
replace drop = 1 if hselfemp>=1
replace drop = 1 if agehead<18
replace drop = 1 if agehead>64 & agehead<.

replace drop = 1 if ratio1>=0 & ratio1<.6
replace drop = 1 if ratio1>40 & ratio1<. //Note that this is not exactly consistent with CEX, but it doesn't make a difference... probably
count if ratio1>39 & ratio1<.
replace drop = 1 if ratio2>=0 & ratio2<.6
replace drop = 1 if ratio2>40 & ratio2<. 
count if ratio2>39 & ratio2<.

gen dkids = kids[_n]-kids[_n-1]
gen dadults = adults[_n]-adults[_n-1]
replace drop = 1 if mis==8 & (abs(dkids)>2 | abs(dadults)>2) & dkids<. & dadults<.

gen fwage1 = wage1[_n+1]
gen fwage2 = wage2[_n+1]

replace drop = 1 if mis==4 & (abs(ln(fwage1)-ln(wage1))>=1.5 | abs(ln(fwage2)-ln(wage2))>=1.5) & wage1<. & wage2<. & fwage1<. & fwage2<. 
// Also not exactly the same as CEX since >1.5 in CEX

by id: egen _drop = min(drop)
tab drop mis
drop if _drop==1

count if id~=.
count if id~=. & mis==4
count if id~=. & mis==8
tab year
tab year if mis==4
tab year if mis==8

*People who should have been dropped from original CPS sample
drop _drop
*replace drop = 1 if agehead==.
replace drop = 1 if state==11
by id: egen _drop = min(drop)
tab _drop mis
drop if _drop==1

count
save ogr_next6_79_300, replace

****** Round Weights ********
replace hhwgt = round(hhwgt)
replace wgt1 = round(wgt1)

save rep_cps.dta, replace

use rep_cps

* Share of Income from Minimum Wage at Beginning of Panel
count if sharemw==.
gen firstsharemw = sharemw if mis==4
sort id year
by id: gen _firstsharemw = firstsharemw[1]
drop firstsharemw
ren _firstsharemw firstsharemw
tab mis if missing(firstsharemw)

*Share of Income from 120-300% Minimum Wage at Beginning of Panel
gen firstsharemw_120300 = sharemw_120300 if mis==4
sort id year
by id: gen _firstsharemw_120300 = firstsharemw_120300[1]
drop firstsharemw_120300
ren _firstsharemw_120300 firstsharemw_120300
tab mis if missing(firstsharemw_120300)

*Share of Income from 200-300% Minimum Wage at Beginning of Panel
gen firstsharemw_200300 = sharemw_200300 if mis==4
sort id year
by id: gen _firstsharemw_200300 = firstsharemw_200300[1]
drop firstsharemw_200300
ren _firstsharemw_200300 firstsharemw_200300
tab mis if missing(firstsharemw_200300)

*Share of Income from 120-200% Minimum Wage at Beginning of Panel
gen firstsharemw_120200 = sharemw_120200 if mis==4
sort id year
by id: gen _firstsharemw_120200 = firstsharemw_120200[1]
drop firstsharemw_120200
ren _firstsharemw_120200 firstsharemw_120200
tab mis if missing(firstsharemw_120200)

*Confirm everyone has 2 observations
by id: egen seq=seq()
by id: egen maxseq=max(seq)
drop if maxseq~=2

drop if year==1979 //1979 had been excluded from old CPS table
drop y1-y29
tab year, gen(y)

xtset id mis

capture log close
log using cps_table1.log, replace
***********
* Table 1 *
***********

*Column 2 
xtreg tot_inc minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg tot_inc minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg tot_inc minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 6 - Minimum Wage Worker = 120-300% of minimum
xtreg tot_inc minwage y1-y27 adults kids if firstsharemw_120300==0, fe cluster(id)
xtreg tot_inc minwage y1-y27 adults kids if firstsharemw_120300>0 & firstsharemw_120300<., fe cluster(id)
xtreg tot_inc minwage y1-y27 adults kids if firstsharemw_120300>=0.2 & firstsharemw_120300<., fe cluster(id)


log close

log using cps_tableA1.log, replace

************
* Table A1 *
************

*Make income annual (current quarterly)
replace tot_inc = tot_inc*4

su tot_inc firstsharemw agehead adults kids if firstsharemw==0 [w=hhwgt]
su tot_inc firstsharemw agehead adults kids if firstsharemw>=0.2 & firstsharemw<. [w=hhwgt]

log close

log using cps_tableA3.log, replace
************
* Table A3 *
************

gen tot_emp = emp1+emp2 if emp1~=. & emp2~=.
 replace tot_emp = emp1 if emp2==.
 replace tot_emp = emp2 if emp1==.
 
gen tot_hrs = hrs1+hrs2 if hrs1~=. & hrs2~=.
 replace tot_hrs = hrs1 if hrs2==.
 replace tot_hrs = hrs2 if hrs1==.

gen tot_wage = wage1+wage2 if wage1~=. & wage2~=.
 replace tot_wage = wage1 if wage2==.
 replace tot_wage = wage2 if wage1==.


*Column 1 - Employment Total 
xtreg tot_emp minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg tot_emp minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg tot_emp minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 2 - Employment Household Head
xtreg emp1 minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg emp1 minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg emp1 minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 3 - Employment Spouse
xtreg emp2 minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg emp2 minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg emp2 minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 4 - Hours Total 
xtreg tot_hrs minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg tot_hrs minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg tot_hrs minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 5 - Hours Household Head
xtreg hrs1 minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg hrs1 minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg hrs1 minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 6 - Hours Spouse
xtreg hrs2 minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg hrs2 minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg hrs2 minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 7 - Hourly Wage Total 
xtreg tot_wage minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg tot_wage minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg tot_wage minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 8 - Hourly Wage Household Head
xtreg wage1 minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg wage1 minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg wage1 minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

*Column 9 - Hourly Wage Spouse
xtreg wage2 minwage y1-y27 adults kids if firstsharemw==0, fe cluster(id)
xtreg wage2 minwage y1-y27 adults kids if firstsharemw>0 & firstsharemw<., fe cluster(id)
xtreg wage2 minwage y1-y27 adults kids if firstsharemw>=0.2 & firstsharemw<., fe cluster(id)

log close

exit