/**
readin_80stf3f

This do-file reads in the 1980 census data stf 3 f, which
is basic census published tables aggregated to school
districts.

The basic data and program structures are similar to 
~/tracts/1980/readin_80stf4b.do
**/

clear
set more off
capture log close
log using readin_80stf4f.log, replace text
set mem 500m


#delimit ;
infix
str5 fileid 1-5
sumrlvl 10-11
str1 psad 29
str1 sdlvl 30
statefips 34-35
smsa 36-39
cntyfips 40-42
district 83-87
str40 name 145-184
str20 ccode 185-204

pop 253-261
sampop 280-288

str13 cname 11620-11632 
str2 st 11633-11634
zipcode 11635-11639
extra 11640-11646

using 03518-0001-Data.txt;
#delimit cr

** Areas not assigned to a district
drop if district==66666

keep if sumrlvl==40

label variable psad "A if county part"
label variable sdlvl "Elementary, Secondary or Unified"

save district80.dta, replace


log close
