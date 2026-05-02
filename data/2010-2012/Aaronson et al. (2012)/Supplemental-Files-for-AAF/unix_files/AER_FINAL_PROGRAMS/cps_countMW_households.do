*************************************************
* Number of U.S. households with S>=0.2 in 2006 *
*************************************************

clear all
set mem 3g
capture log close

* Use subset of variables from 2006 CPS Outgoing Rotations
use ogr_select.dta if year==2006

ren aernwk _ernwk

*Drop if data aren't usable
drop if  age==-1 & relhd==-1 & lineno==-1
drop if  age==. & relhd==. & lineno==.
count if age==. | age==-1 | relhd==-1 | relhd==. |lineno==-1|lineno==.

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

*************************
* Create a household id *
*************************

gen mon = string(month) 
replace mon = "0"+mon if month < 10 
gen num = string(hhnum)
gen uhhid =state+hhid+hhid2+mon  
replace hhnum = 0
gen _hhid = hhid+hhid2
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

* Count of observations with and without household weight
tab year if hhwgt~=.
tab year if hhwgt==.
drop if hhwgt==.
 
sort $id

 
* Drop all boarders/roomers housemate/roommate since we assume they don't  contribute to the head's and head's relatives' finances
drop if relhd>14

**** Generate Count of Kids and Adults ****
gen child= 1 if age<18
bysort _hhid month state hhnum year: egen kids=count(child)
gen adult= 1 if age>=18 & age<.
bysort _hhid month state hhnum year: egen adults=count(adult)
drop child adult

*********
* Wages *
*********
gen hours = .
replace hours = hoursu1 if  hoursu1>=0  //Usual weekly hours at main job
replace hours = hours1 if  hoursu1==-4 & hours1>=0 // Hours last week at main job if usual hours vary

replace ernhr = ernhr/100 if ernhr~=-1
gen wage = ernhr if ernhr~=-1

*_wage imputes hourly wage using weekly earnings/hours, so salaried workers are included
gen _wage = wage
replace _wage = _ernwk / hours if ernhr==-1
su wage _wage

drop ernhr hoursu1 hours1 ernush 

gen qtrincome = wage*hours*13 //Weekly Wage * 13 since 13 weeks per quarter
label var qtrincome "Hourly Wage x Usual Hours Per Week x 13"

gen _qtrincome = _wage*hours*13 //Weekly Wage * 13 since 13 weeks per quarter
label var _qtrincome "Imp Hourly Wage x Usual Hours Per Week x 13"

********************
* Household Income *
********************

bysort _hhid month state hhnum year : egen hincqtr = total(qtrincome)

* Use midpoint of family income ranges
gen finc = .
 replace finc = 2500   if (faminc==1) 
 replace finc = 6250   if (faminc==2)
 replace finc = 8750   if (faminc==3) 
 replace finc = 11250  if (faminc==4) 
 replace finc = 13750  if (faminc==5) 
 replace finc = 17500  if (faminc==6)
 replace finc = 22500  if (faminc==7)
 replace finc = 27500  if (faminc==8)
 replace finc = 32500  if (faminc==9)
 replace finc = 37500  if (faminc==10)
 replace finc = 45000  if (faminc==11)
 replace finc = 55000  if (faminc==12)
 replace finc = 67500  if (faminc==13)
 replace finc = 87500  if (faminc==14)
 replace finc = 125000 if (faminc==15)
 replace finc = 150000 if (faminc==16)

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

count 


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
by _hhid month state hhnum year: egen ties1=count(hasminrelhd) 
tab ties1 

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
drop if person==.

************************************************
* Transform Data in to Household Level Dataset *
************************************************  

*Wage
gen w1 = wage if (person==1 )
gen w2 = wage if (person==2 )

*Wage (All Workers)
gen _w1 = _wage if person==1
gen _w2 = _wage if person==2

*Quarterly Income
gen qi1 = qtrincome if person==1
gen qi2 = qtrincome if person==2				  

*Quarterly Income
gen _qi1 = _qtrincome if person==1
gen _qi2 = _qtrincome if person==2				  

*Hours
gen h1 = hours if person==1
gen h2 = hours if person==2				  

*Employment
gen e1 = (mlr==1 | mlr==2) if ~missing(mlr) & (person==1)
gen e2 = (mlr==1 | mlr==2) if ~missing(mlr) & (person==2)				  


* Now Fill in Variables Generated Above for Everyone in the Household
sort _hhid month state hhnum year
by _hhid month state hhnum year : egen wage1 = max(w1)
by _hhid month state hhnum year : egen wage2 = max(w2)
by _hhid month state hhnum year : egen _wage1 = max(_w1)
by _hhid month state hhnum year : egen _wage2 = max(_w2)
by _hhid month state hhnum year : egen qtrincome1 = max(qi1)
by _hhid month state hhnum year : egen qtrincome2 = max(qi2)
by _hhid month state hhnum year : egen _qtrincome1 = max(_qi1)
by _hhid month state hhnum year : egen _qtrincome2 = max(_qi2)
by _hhid month state hhnum year : egen hrs1 = max(h1)
by _hhid month state hhnum year : egen hrs2 = max(h2)
by _hhid month state hhnum year : egen emp1 = max(e1)
by _hhid month state hhnum year : egen emp2 = max(e2)

gen miss1 = 1 if qtrincome1==.
gen miss2 = 1 if qtrincome2==.
 replace qtrincome1 = 0 if qtrincome1==.
 replace qtrincome2 = 0 if qtrincome2==.

gen _miss1 = 1 if _qtrincome1==.
gen _miss2 = 1 if _qtrincome2==.
 replace _qtrincome1 = 0 if _qtrincome1==.
 replace _qtrincome2 = 0 if _qtrincome2==.
 
 
*Create Weight
gen wt1 = wgt if person==1 & mis==4
by _hhid month state hhnum year: egen wgt1 = max(wt1) if mis==4
drop wt1


*Limit Sample to One Household Member
sort  _hhid month state hhnum year lineno
by _hhid month state hhnum year: keep if lineno==lineno[1]

count

*******************************
* Bring in State Minimum Wage *
*******************************

destring state, replace
sort state year month
merge state year month using mw7909a, keep(minwage)
tab _merge
drop if _merge==2

************* GENERATE S *****************
* The share of income coming from jobs   *
* paying less than 120% of minimum wage. *
******************************************

gen ratio1 = wage1/minwage 
gen ratio2 = wage2/minwage 

gen earnmw1 = 0
replace earnmw1 = 1 if ratio1<=1.2
replace earnmw1 = . if ratio1==. & ratio2==.

gen earnmw2 = 0
replace earnmw2 = 1 if ratio2<=1.2
replace earnmw2 = . if ratio1==. & ratio2==.

gen sharemw = (qtrincome1*earnmw1+qtrincome2*earnmw2)/F if mis==4
 replace sharemw = 1 if (qtrincome1*earnmw1+qtrincome2*earnmw2)>0 & (qtrincome1*earnmw1+qtrincome2*earnmw2)<. & F<=0

 ************* GENERATE _S *****************
* The share of income coming from jobs   *
* paying less than 120% of minimum wage. *
******************************************

gen _ratio1 = _wage1/minwage 
gen _ratio2 = _wage2/minwage 

su _ratio1 if wage1==. & _wage1~=.

gen _earnmw1 = 0
replace _earnmw1 = 1 if _ratio1<=1.2
replace _earnmw1 = . if _ratio1==. & _ratio2==.

gen _earnmw2 = 0
replace _earnmw2 = 1 if _ratio2<=1.2
replace _earnmw2 = . if _ratio1==. & _ratio2==.

gen _sharemw = (_qtrincome1*_earnmw1+_qtrincome2*_earnmw2)/F if mis==4
 replace _sharemw = 1 if (_qtrincome1*_earnmw1+_qtrincome2*_earnmw2)>0 & (_qtrincome1*_earnmw1+_qtrincome2*_earnmw2)<. & F<=0


**************
* Exclusions *
**************

sort _hhid month state hhnum year
egen id = group(_hhid month state hhnum year)

duplicates tag _hhid month state hhnum, generate(dup)
duplicates tag _hhid month state hhnum year, generate(dupyear)

tab dup, missing
tab dupyear, missing

drop if state==. | state==11

gen use = 1 if !(miss1==1 & miss2==1)
replace use = 0 if ratio1>=0 & ratio1<.6
replace use = 0 if ratio1>40 & ratio1<. 
replace use = 0 if ratio2>=0 & ratio2<.6
replace use = 0 if ratio2>40 & ratio2<. 

gen _use = 1 if !(_miss1==1 & _miss2==1)
replace _use = 0 if _ratio1>=0 & _ratio1<.6
replace _use = 0 if _ratio1>40 & _ratio1<. 
replace _use = 0 if _ratio2>=0 & _ratio2<.6
replace _use = 0 if _ratio2>40 & _ratio2<. 


****** Round Weights ********
replace hhwgt = round(hhwgt)

**********************************************************************
* Note on household weights:                                         *
* Since we are using a full year of observations from the outgoing   *
* rotations sample (1/4 of each month's basic sample), these weights *
* should technically be divided by 3 (12*(1/4)). We do not do this   *
* because our national population estimates are off by a factor of 3 *
* after we drop our observations, so we basically are multiplying    *
* the true weights by 3 to normalize our estimates to census         *
* population estimates.                                              *
**********************************************************************

gen pop = 1

***** 2006 All Households *****
su pop if _sharemw==0 &  _use==1 [w=hhwgt] 
su pop if _sharemw>0 & _sharemw<.  & _use==1 [w=hhwgt] 
su pop if _sharemw>=0.2 & _sharemw<.  & _use==1 [w=hhwgt]

********* Share of Households with 2 Minimum Wage Earners **********

gen has2mw = .
replace has2mw = 1 if _earnmw1==1 & _earnmw2==1
replace has2mw = 0 if _earnmw1==0 & _earnmw2==1 | _earnmw1==1 & _earnmw2==0

gen has1mw = .
replace has1mw = 1 if _earnmw1==1 & _earnmw2==0 | _earnmw1==0 & _earnmw2==1
replace has1mw = 0 if _earnmw1==1 & _earnmw2==1


***** 2006 All Households *****
su has2mw if _sharemw>=0.2 & _sharemw<.  & _use==1 [w=hhwgt]


exit