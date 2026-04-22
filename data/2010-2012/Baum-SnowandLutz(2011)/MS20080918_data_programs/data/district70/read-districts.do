/* read-districts.do

NOTE: This data set does not include Maryland.
However, according to the documentation pdf file,
MD districts in 1970 were coterminous with counties.

*/

clear
set mem 100m
set more off
capture log close
log using read-districts.log, replace text

#delimit ;
infix
  STC70   1-2                                                         
  STC60   3-4                                                         
  COC70   5-7                                                         
  CTABU   8-10                                                        
  CENCC   11-11                                                       
  MCD     12-14                                                       
  PLACC   15-18                                                       
  PLATC   19-19                                                       
str2  PLASC 20-21                                                       
str1  STCAC 22-22                                                       
str4  SMSA  23-26                                                       
  URBAC   27-30                                                       
  TRAC    31-34                                                       
  UNIAP   35-35                                                       
  UNIAC   36-40                                                       
str2  STEAC 41-42                                                       
str3  ECOSC 43-45                                                       
str1  CEBDC 46-46                                                       
str30  ARNAM 47-76                                                       
  BTC     77-80                                                       
  TSC     81-82                                                       
  BLGC    83-83                                                       
str5  ENDC  84-88                                                       
str1  URRC  89-89                                                       
  WARC    90-91                                                       
  CODC    92-93                                                       
  HOUC    94-100                                                      
  POPC    101-108                                                     
  SDC     109-113                                                     
  SDTC    114-114                                                     
  ADUC    115-116                                                     
  PERC    117-119
using districts-Data.raw;                                                    
#delimit cr
                                                                      
label variable  STC70 "1970 State Code"
label variable  STC60 "1960 State Code"
label variable  COC70 "1970 County Code"
label variable  CTABU "County of Population"
label variable  CENCC "Central County Code"
label variable  MCD "Minor Civil Division"
label variable  PLACC "Place Code"
label variable  PLATC "Place Type Code"
label variable  PLASC "Place Size Code"
label variable  STCAC "Standard Consolidated Area Code"
label variable  SMSA "Standard Metro Statistical Area Code"
label variable  URBAC "Urbanized Area Code"
label variable  TRAC "Tracted Area Code"
label variable  UNIAP "Universal Area Prefix"
label variable  UNIAC "Universal Area Code"
label variable  STEAC "State Economic Area Code"
label variable  ECOSC "Economic Subregion Code"
label variable  CEBDC "Central Business District Code"
label variable  ARNAM "Area Name"
label variable  BTC "Basic Tract Code"
label variable  TSC  "Tract Suffix Code"
label variable  BLGC "Block Group Code"
label variable  ENDC "Enumeration District Code"
label variable  URRC "Urban/Rural Classification Code"
label variable  WARC "Ward Code"
label variable  CODC "Congressional District Code"
label variable  HOUC "Housing Code"
label variable  POPC "Population Code"
label variable  SDC "School District Code"
label variable  SDTC "School District Type Code"
label variable  ADUC "Administrative Unit Code"
label variable  PERC "Percent (Equivalent)"

rename STC70 statefips
rename COC70 cntyfips
rename PLACC place
rename SDC district 
rename SDTC type
rename ARNAM name

gen pop = POPC*PERC/100

** Drop vocational, etc. districts
drop if type>3

save basic70.dta,replace

egen POP = sum(pop), by(statefips cntyfips place district type)
drop pop
rename POP pop

keep statefips cntyfips place district type name pop 
sort statefips cntyfips place district type
by statefips cntyfips place district type: keep if _n==1
sort statefips place cntyfips district type 

save district70.dta, replace

use basic70.dta

rename BTC tract
rename TSC suffix

*** Keep only fully tracted districts
gen tracted = 0
replace tracted = 1 if tract~=.
sort statefips district
by statefips district: gen obs = _N
egen trobs = sum(tracted), by(statefips district)

*** Keep the geography if at least 95% of the district pop is in tracted areas
egen dispop = sum(pop), by(statefips district)
egen trdispop = sum(pop) if tracted==1, by(statefips district tracted)
sort statefips district tracted
by statefips district: replace trdispop = trdispop[_N]
replace trdispop = 0 if trobs==0
replace trobs = obs if trdispop/dispop>=.95

*** There are some CC districts that aren't fully tracted:
*Albuquerque, NM
replace trobs = obs if statefips==35 & district==60
*Davenport, IA
replace trobs = obs if statefips==19 & district==8580
*Des Moines, IA
replace trobs = obs if statefips==19 & district==8970
*Greenville, SC
replace trobs = obs if statefips==45 & district==2310
*Oklahoma City, OK
replace trobs = obs if statefips==40 & district==22770
*Omaha, NE
replace trobs = obs if statefips==31 & district==74820
*Sioux City, IA
replace trobs = obs if statefips==19 & district==26400
*Tulsa, OK
replace trobs = obs if statefips==40 & district==30240
** MD is not in the 1970 data, so Baltimore must be dealt with elsewhere
drop if trobs<obs
drop if tract==.

keep statefips cntyfips district place type BLGC ENDC URRC WARC CODC pop name tract suffix PERC

/** Each geographic region is defined by the combination of
statefips cntyfips tract suffix BLGC place district where
PERC is the percentage of s c t s B p in the district.  First
assign each geographic region to one district of each type. **/
sort statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place type PERC 
by statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place type: keep if _n==_N

/** Now if a geographic district is assigned to both 1 (Unified) and 2/3, 
assign it to the larger (ties go to unified)**/
egen minx = min(type), by(statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place)
egen maxx = max(type), by(statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place)
gen xtype = 0
replace xtype = 1 if type==2|type==3
egen xx = max(PERC), by(statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place type)
gen xx1 = xx if type==1
gen xx2 = xx if type==2
gen xx3 = xx if type==3
egen yy1 = max(xx1), by(statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place)
egen yy2 = max(xx2), by(statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place)
egen yy3 = max(xx3), by(statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place)
replace yy1 = -9 if yy1==.
replace yy2 = -9 if yy2==.
replace yy3 = -9 if yy3==.

sort statefips cntyfips tract suffix BLGC ENDC URRC WARC CODC place type PERC
drop if type==1 & yy1<max(yy2,yy3)
drop if (type==2|type==3) & max(yy2,yy3)<=yy1

** Assign the largest pop region within tract to the whole tracti (by type)
sort statefips cntyfips tract suffix type pop
by statefips cntyfips tract suffix type: keep if _n==_N

** If type 1 and 2/3 in same tract, use bigger pop
egen yyx = max(pop), by(statefips cntyfips tract suffix type)
gen p1 = yyx if type==1
gen p2 = yyx if type==2
gen p3 = yyx if type==3
egen pp1 = max(p1), by(statefips cntyfips tract suffix)
egen pp2 = max(p2), by(statefips cntyfips tract suffix)
egen pp3 = max(p3), by(statefips cntyfips tract suffix)
replace pp1 = -9 if pp1==.
replace pp2 = -9 if pp2==.
replace pp3 = -9 if pp3==.
drop if type==1 & pp1<max(pp2,pp3)
drop if (type==2|type==3) & pp1>=max(pp2,pp3)

** Assign areakey
gen strst = string(statefips)
replace strst = "0"+strst if statefips<10
gen strcn = string(cntyfips)
replace strcn = "0"+strcn if cntyfips<100
replace strcn = "0"+strcn if cntyfips<10
gen strtr = string(tract)
replace strtr = "0"+strtr if tract<1000
replace strtr = "0"+strtr if tract<100
replace strtr = "0"+strtr if tract<10
gen strsuf = string(suffix)
replace strsuf = "0"+strsuf if suffix<10
replace strsuf = "00" if suffix==.
gen str11 areakey = strst+strcn+strtr+strsuf 

rename PERC pct
keep areakey statefips district type pct
gen stdis = statefips*100000+district
save temp.dta, replace

keep if type==1
sort areakey
compress
save tracts_unif70.dta, replace

use temp.dta,clear
keep if type==2
sort areakey
compress
save tracts_elem70.dta, replace

use temp.dta,clear
keep if type==3
sort areakey
compress
save tracts_sec70.dta, replace

log close   
erase temp.dta
