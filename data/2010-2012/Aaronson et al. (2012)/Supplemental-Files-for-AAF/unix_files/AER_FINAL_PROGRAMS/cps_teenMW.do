*************************************
* Share of minimum wage individuals *
* who are teenagers in 2006         *
*************************************


clear all
set mem 1g
capture log close

* Subset of CPS Outgoing rotations variables
use ogr_select.dta if year==2006

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

***************
* Generate ID *
***************
gen mon = string(month) 
replace mon = "0"+mon if month < 10 
gen num = string(hhnum)
gen uhhid = state+hhid+hhid2+mon 
replace hhnum = 0 
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
drop if dup>0 
drop dup

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

*******************************
* Bring in State Minimum Wage *
*******************************

destring state, replace
sort state year month
merge state year month using mw7909a, keep(minwage)
tab _m
drop if _m==2

***********************************
* Generate Minimum Wage Indicator *
***********************************

gen ratio1 = wage/minwage

gen earnmw1 = .
replace earnmw1 = 1 if ratio1>0.6 & ratio1<=1.2 
replace earnmw1 = 0 if ratio1>1.2 & ratio1<.

**************
* Exclusions *
**************
drop if state==. | state==11
drop if age<16
drop if ratio1>=0 & ratio1<0.6
drop if ratio1>40 & ratio1<.

****** Round Weights ********
replace wgt = round(wgt)

gen teen1619 = age>=16 & age<=19 if age>15 & age<.
gen teen1617 = age>=16 & age<=17 if age>15 & age<.

su teen1619 teen1617 if earnmw1==1 [w=wgt] 

exit