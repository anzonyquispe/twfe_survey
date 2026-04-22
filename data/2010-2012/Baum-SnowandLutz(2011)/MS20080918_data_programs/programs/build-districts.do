/**
build-districts.do

This do-file builds information on the number of 
school districts in each MSA and incorporates information
on district enrollment, etc collected by Welch & Light generously
provided by Sarah Reber on central and the largest suburban school 
district for each MSA in 1970, 1980 and 1990.  

The resulting data set has census counts on the central district given
its geography and district composition in each year.  
Information from the districts themselves originally collected by W&L 
and Reber maintain the same set of districts over time.  
For example, Louisville & Jefferson County consolidated in the 1970s.
The 1970 observation for this MSA has enrollment info for the consolidation
of the two districts but population from the census of the Louisville
central district area only.

This do-file has 8 sections:

1. Establish sample using GIS data
2. Establish common core + deseg data
3. 1970 Census School District File
4. 1980 Census School District File
5. 1990 Census School District File
6. Append Together Census School District Data & Clean Up
7. Merge on desegregation / common core data
8. Label Variables

Input Data Files:
../gis/segsamp_cbd.dta              - To establish sample of central districts
../data/welch_ccd/welch_long.dta    - Common Core / Welch & Light data
../data/ccdb/county4070.dta         - County Data Books 1940-1970 used for 1970 MD districts
../data/district70/district70.dta   - 1970 Census school district data file
../data/district80/district80.dta   - 1980 Census school district data file
../data/district80/district90.dta   - 1990 Census school district data file

Output Data File:
../data/districtpan.dta             - Data set of central districts, one obs per 
					central district in 1960,1970,1980 and 1990

**/

clear
set more off
set mem 100m
capture log close
log using build-districts.log, replace text


************* 1. Establish Sample ***********************
****** This is the city surrounding each MSA's CBD ******

use ../gis/segsamp_cbd.dta

gen statefips = real(first_stat)
gen place = real(first_plac)
rename first_name cbdname

do ../data/xwalk/place-change-code60.do

sort statefips place
merge statefips place using ../data/xwalk/place-codes.dta
tab _merge
keep if _merge==3
drop _merge

keep statefips place placefips areaname
sort statefips place placefips

save ccsamp.dta, replace

clear
use ../data/welch_ccd/welch_long.dta
sort leaid
by leaid: keep if _n==1
keep leaid
expand 53
sort leaid
by leaid: gen year = _n+54
sort leaid year
save temp.dta, replace

/************ 2.  Clean Common Core/Welch & Light Data ******************
This data set includes the 124 districts investigated by Welch & Light 
The CCD does not include info on all districts in all years ************/

use ../data/welch_ccd/welch_long.dta

*** Create every year/district combination
sort leaid year
merge leaid year using temp.dta
tab _merge
drop _merge

** Fix Wilmington, DE
replace state = 10 if leaid ==  9999999
replace south = 1 if leaid ==  9999999
gen west = (region==4)
replace west = . if region==.

/** We want data from the school years including 
April of census years: 69-70, 79-80, 89-90 **/

gen white69 = white if year==69
gen black69 = black if year==69
gen stu69 = tot if year==69
gen white79 = white if year==79
gen black79 = black if year==79
gen stu79 = tot if year==79
gen white89 = white if year==89
gen black89 = black if year==89
gen stu89 = tot if year==89
drop tot

sort leaid imp state 
by leaid: replace imp = imp[1]
by leaid: replace major = major[1]
by leaid: replace south = south[1]
by leaid: replace state = state[1]

gen deseg = (year>=imp)
replace deseg = -1 if year==imp-1

*** Fill out dissimilarity index
sort leaid year
by leaid: gen new = (disd==. & disd[_n-1]~=.)
by leaid: replace new = 1 if disd~=. & disd[_n-1]==.
by leaid: gen spell = sum(new)
sort leaid spell year
by leaid spell: gen num = _n
by leaid spell: gen tot = _N
replace tot = 0 if disd~=.
replace spell = 0 if disd~=.
** Clear cut cases
gsort leaid -year
by leaid: replace disd = disd[_n+1] if disd==. & disd[_n+1]~=. & tot>1 & num==1 & deseg==deseg[_n+1]
by leaid: replace disd = disd[_n+2] if disd==. & disd[_n+2]~=. & tot>3 & num==2 & deseg==deseg[_n+2]
by leaid: replace disd = disd[_n+3] if disd==. & disd[_n+3]~=. & tot>5 & num==3 & deseg==deseg[_n+3]
sort leaid year
by leaid: replace disd = disd[_n+1] if disd==. & disd[_n+1]~=. & tot>1 & num==tot & deseg==deseg[_n+1]
by leaid: replace disd = disd[_n+2] if disd==. & disd[_n+2]~=. & tot>3 & num==tot-1 & deseg==deseg[_n+2]
by leaid: replace disd = disd[_n+3] if disd==. & disd[_n+3]~=. & tot>5 & num==tot-2 & deseg==deseg[_n+3]
** Avg at 1
by leaid: replace disd = .5*disd[_n+1]+.5*disd[_n-1] if tot==1 & deseg==deseg[_n-1] & deseg==deseg[_n+1]
by leaid: replace disd = disd[_n+1] if disd==. & tot==1 & deseg==deseg[_n+1]
by leaid: replace disd = disd[_n-1] if disd==. & tot==1 & deseg==deseg[_n-1]
** Avg at 3
by leaid: replace disd = .5*disd[_n+2]+.5*disd[_n-2] if tot==3 & num==2 & deseg==deseg[_n-2] & deseg==deseg[_n+2]
by leaid: replace disd = disd[_n+2] if disd==. & tot==3 & num==2 & deseg==deseg[_n+2]
by leaid: replace disd = disd[_n-2] if disd==. & tot==3 & num==2 & deseg==deseg[_n-2]
** Avg at 5
by leaid: replace disd = .5*disd[_n+3]+.5*disd[_n-3] if tot==5 & num==3 & deseg==deseg[_n-3] & deseg==deseg[_n+3]
by leaid: replace disd = disd[_n+3] if disd==. & tot==5 & num==3 & deseg==deseg[_n+3]
by leaid: replace disd = disd[_n-3] if disd==. & tot==5 & num==3 & deseg==deseg[_n-3]
drop new spell num tot

** Do the same for dissimilarity index - white/nonwhite 
sort leaid year
by leaid: gen new = (dis_wn==. & dis_wn[_n-1]~=.)
by leaid: replace new = 1 if dis_wn~=. & dis_wn[_n-1]==.
by leaid: gen spell = sum(new)
sort leaid spell year
by leaid spell: gen num = _n
by leaid spell: gen tot = _N
replace tot = 0 if dis_wn~=.
replace spell = 0 if dis_wn~=.
gsort leaid -year
by leaid: replace dis_wn = dis_wn[_n+1] if dis_wn==. & dis_wn[_n+1]~=. & tot>1 & num==1 & deseg==deseg[_n+1]
by leaid: replace dis_wn = dis_wn[_n+2] if dis_wn==. & dis_wn[_n+2]~=. & tot>3 & num==2 & deseg==deseg[_n+2]
by leaid: replace dis_wn = dis_wn[_n+3] if dis_wn==. & dis_wn[_n+3]~=. & tot>5 & num==3 & deseg==deseg[_n+3]
sort leaid year
by leaid: replace dis_wn = dis_wn[_n+1] if dis_wn==. & dis_wn[_n+1]~=. & tot>1 & num==tot & deseg==deseg[_n+1]
by leaid: replace dis_wn = dis_wn[_n+2] if dis_wn==. & dis_wn[_n+2]~=. & tot>3 & num==tot-1 & deseg==deseg[_n+2]
by leaid: replace dis_wn = dis_wn[_n+3] if dis_wn==. & dis_wn[_n+3]~=. & tot>5 & num==tot-2 & deseg==deseg[_n+3]
** Avg at 1
by leaid: replace dis_wn = .5*dis_wn[_n+1]+.5*dis_wn[_n-1] if tot==1 & deseg==deseg[_n-1] & deseg==deseg[_n+1]
by leaid: replace dis_wn = dis_wn[_n+1] if dis_wn==. & tot==1 & deseg==deseg[_n+1]
by leaid: replace dis_wn = dis_wn[_n-1] if dis_wn==. & tot==1 & deseg==deseg[_n-1]
** Avg at 3
by leaid: replace dis_wn = .5*dis_wn[_n+2]+.5*dis_wn[_n-2] if tot==3 & num==2 & deseg==deseg[_n-2] & deseg==deseg[_n+2]
by leaid: replace dis_wn = dis_wn[_n+2] if dis_wn==. & tot==3 & num==2 & deseg==deseg[_n+2]
by leaid: replace dis_wn = dis_wn[_n-2] if dis_wn==. & tot==3 & num==2 & deseg==deseg[_n-2]
** Avg at 5
by leaid: replace dis_wn = .5*dis_wn[_n+3]+.5*dis_wn[_n-3] if tot==5 & num==3 & deseg==deseg[_n-3] & deseg==deseg[_n+3]
by leaid: replace dis_wn = dis_wn[_n+3] if dis_wn==. & tot==5 & num==3 & deseg==deseg[_n+3]
by leaid: replace dis_wn = dis_wn[_n-3] if dis_wn==. & tot==5 & num==3 & deseg==deseg[_n-3]
drop new spell num tot

** Do the same for exposure index - white/nonwhite 
sort leaid year
by leaid: gen new = (exp_wtotb==. & exp_wtotb[_n-1]~=.)
by leaid: replace new = 1 if exp_wtotb~=. & exp_wtotb[_n-1]==.
by leaid: gen spell = sum(new)
sort leaid spell year
by leaid spell: gen num = _n
by leaid spell: gen tot = _N
replace tot = 0 if exp_wtotb~=.
replace spell = 0 if exp_wtotb~=.
gsort leaid -year
by leaid: replace exp_wtotb = exp_wtotb[_n+1] if exp_wtotb==. & exp_wtotb[_n+1]~=. & tot>1 & num==1 & deseg==deseg[_n+1]
by leaid: replace exp_wtotb = exp_wtotb[_n+2] if exp_wtotb==. & exp_wtotb[_n+2]~=. & tot>3 & num==2 & deseg==deseg[_n+2]
by leaid: replace exp_wtotb = exp_wtotb[_n+3] if exp_wtotb==. & exp_wtotb[_n+3]~=. & tot>5 & num==3 & deseg==deseg[_n+3]
sort leaid year
by leaid: replace exp_wtotb = exp_wtotb[_n+1] if exp_wtotb==. & exp_wtotb[_n+1]~=. & tot>1 & num==tot & deseg==deseg[_n+1]
by leaid: replace exp_wtotb = exp_wtotb[_n+2] if exp_wtotb==. & exp_wtotb[_n+2]~=. & tot>3 & num==tot-1 & deseg==deseg[_n+2]
by leaid: replace exp_wtotb = exp_wtotb[_n+3] if exp_wtotb==. & exp_wtotb[_n+3]~=. & tot>5 & num==tot-2 & deseg==deseg[_n+3]
** Avg at 1
by leaid: replace exp_wtotb = .5*exp_wtotb[_n+1]+.5*exp_wtotb[_n-1] if tot==1 & deseg==deseg[_n-1] & deseg==deseg[_n+1]
by leaid: replace exp_wtotb = exp_wtotb[_n+1] if exp_wtotb==. & tot==1 & deseg==deseg[_n+1]
by leaid: replace exp_wtotb = exp_wtotb[_n-1] if exp_wtotb==. & tot==1 & deseg==deseg[_n-1]
** Avg at 3
by leaid: replace exp_wtotb = .5*exp_wtotb[_n+2]+.5*exp_wtotb[_n-2] if tot==3 & num==2 & deseg==deseg[_n-2] & deseg==deseg[_n+2]
by leaid: replace exp_wtotb = exp_wtotb[_n+2] if exp_wtotb==. & tot==3 & num==2 & deseg==deseg[_n+2]
by leaid: replace exp_wtotb = exp_wtotb[_n-2] if exp_wtotb==. & tot==3 & num==2 & deseg==deseg[_n-2]
** Avg at 5
by leaid: replace exp_wtotb = .5*exp_wtotb[_n+3]+.5*exp_wtotb[_n-3] if tot==5 & num==3 & deseg==deseg[_n-3] & deseg==deseg[_n+3]
by leaid: replace exp_wtotb = exp_wtotb[_n+3] if exp_wtotb==. & tot==5 & num==3 & deseg==deseg[_n+3]
by leaid: replace exp_wtotb = exp_wtotb[_n-3] if exp_wtotb==. & tot==5 & num==3 & deseg==deseg[_n-3]
drop new spell num tot

** Do the same for exposure index - nonwhite/white 
sort leaid year
by leaid: gen new = (exp_btotw==. & exp_btotw[_n-1]~=.)
by leaid: replace new = 1 if exp_btotw~=. & exp_btotw[_n-1]==.
by leaid: gen spell = sum(new)
sort leaid spell year
by leaid spell: gen num = _n
by leaid spell: gen tot = _N
replace tot = 0 if exp_btotw~=.
replace spell = 0 if exp_btotw~=.
gsort leaid -year
by leaid: replace exp_btotw = exp_btotw[_n+1] if exp_btotw==. & exp_btotw[_n+1]~=. & tot>1 & num==1 & deseg==deseg[_n+1]
by leaid: replace exp_btotw = exp_btotw[_n+2] if exp_btotw==. & exp_btotw[_n+2]~=. & tot>3 & num==2 & deseg==deseg[_n+2]
by leaid: replace exp_btotw = exp_btotw[_n+3] if exp_btotw==. & exp_btotw[_n+3]~=. & tot>5 & num==3 & deseg==deseg[_n+3]
sort leaid year
by leaid: replace exp_btotw = exp_btotw[_n+1] if exp_btotw==. & exp_btotw[_n+1]~=. & tot>1 & num==tot & deseg==deseg[_n+1]
by leaid: replace exp_btotw = exp_btotw[_n+2] if exp_btotw==. & exp_btotw[_n+2]~=. & tot>3 & num==tot-1 & deseg==deseg[_n+2]
by leaid: replace exp_btotw = exp_btotw[_n+3] if exp_btotw==. & exp_btotw[_n+3]~=. & tot>5 & num==tot-2 & deseg==deseg[_n+3]
** Avg at 1
by leaid: replace exp_btotw = .5*exp_btotw[_n+1]+.5*exp_btotw[_n-1] if tot==1 & deseg==deseg[_n-1] & deseg==deseg[_n+1]
by leaid: replace exp_btotw = exp_btotw[_n+1] if exp_btotw==. & tot==1 & deseg==deseg[_n+1]
by leaid: replace exp_btotw = exp_btotw[_n-1] if exp_btotw==. & tot==1 & deseg==deseg[_n-1]
** Avg at 3
by leaid: replace exp_btotw = .5*exp_btotw[_n+2]+.5*exp_btotw[_n-2] if tot==3 & num==2 & deseg==deseg[_n-2] & deseg==deseg[_n+2]
by leaid: replace exp_btotw = exp_btotw[_n+2] if exp_btotw==. & tot==3 & num==2 & deseg==deseg[_n+2]
by leaid: replace exp_btotw = exp_btotw[_n-2] if exp_btotw==. & tot==3 & num==2 & deseg==deseg[_n-2]
** Avg at 5
by leaid: replace exp_btotw = .5*exp_btotw[_n+3]+.5*exp_btotw[_n-3] if tot==5 & num==3 & deseg==deseg[_n-3] & deseg==deseg[_n+3]
by leaid: replace exp_btotw = exp_btotw[_n+3] if exp_btotw==. & tot==5 & num==3 & deseg==deseg[_n+3]
by leaid: replace exp_btotw = exp_btotw[_n-3] if exp_btotw==. & tot==5 & num==3 & deseg==deseg[_n-3]
drop new spell num tot

*** Dissim & Exposure Indices 
sort leaid year
gen disd55 = disd if year==55
gen disd56 = disd if year==56
gen disd58 = disd if year==58
gen disd59 = disd if year==59
gen disd60 = disd if year==60
gen disd69 = disd if year==69
gen disd70 = disd if year==70
gen disd65 = disd if year==65
gen disd66 = disd if year==66
gen disd68 = disd if year==68
gen disd79 = disd if year==79
gen disd80 = disd if year==80
gen disd75 = disd if year==75
gen disd76 = disd if year==76
gen disd78 = disd if year==78
gen disd89 = disd if year==89
gen disd90 = disd if year==90
gen disd85 = disd if year==85
gen disd86 = disd if year==86
gen disd88 = disd if year==88
gen dis_wn55 = dis_wn if year==55
gen dis_wn56 = dis_wn if year==56
gen dis_wn58 = dis_wn if year==58
gen dis_wn59 = dis_wn if year==59
gen dis_wn60 = dis_wn if year==60
gen dis_wn69 = dis_wn if year==69
gen dis_wn70 = dis_wn if year==70
gen dis_wn65 = dis_wn if year==65
gen dis_wn66 = dis_wn if year==66
gen dis_wn68 = dis_wn if year==68
gen dis_wn79 = dis_wn if year==79
gen dis_wn80 = dis_wn if year==80
gen dis_wn75 = dis_wn if year==75
gen dis_wn76 = dis_wn if year==76
gen dis_wn78 = dis_wn if year==78
gen dis_wn89 = dis_wn if year==89
gen dis_wn90 = dis_wn if year==90
gen dis_wn85 = dis_wn if year==85
gen dis_wn86 = dis_wn if year==86
gen dis_wn88 = dis_wn if year==88
gen expos55 = exp_wtotb if year==55
gen expos60 = exp_wtotb if year==60
gen expos65 = exp_wtotb if year==65
gen expos69 = exp_wtotb if year==69
gen expos70 = exp_wtotb if year==70
gen expos75 = exp_wtotb if year==75
gen expos79 = exp_wtotb if year==79
gen expos80 = exp_wtotb if year==80
gen expos85 = exp_wtotb if year==85
gen expos89 = exp_wtotb if year==89
gen expos90 = exp_wtotb if year==90
gen expos_bw55 = exp_btotw if year==55
gen expos_bw60 = exp_btotw if year==60
gen expos_bw65 = exp_btotw if year==65
gen expos_bw69 = exp_btotw if year==69
gen expos_bw70 = exp_btotw if year==70
gen expos_bw75 = exp_btotw if year==75
gen expos_bw79 = exp_btotw if year==79
gen expos_bw80 = exp_btotw if year==80
gen expos_bw85 = exp_btotw if year==85
gen expos_bw89 = exp_btotw if year==89
gen expos_bw90 = exp_btotw if year==90

by leaid: gen lagdisd1 = disd if year==imp-1
by leaid: gen lagdisd2 = disd if year==imp-2
gen disdimp = disd if year==imp
by leaid: gen leaddisd1 = disd if year==imp+1
by leaid: gen leaddisd2 = disd if year==imp+2
by leaid: gen leaddisd3 = disd if year==imp+3
by leaid: gen leaddisd4 = disd if year==imp+4
by leaid: gen leaddisd5 = disd if year==imp+5

by leaid: gen lagexpos1 = exp_wtotb if year==imp-1
by leaid: gen lagexpos2 = exp_wtotb if year==imp-2
gen exposimp = exp_wtotb if year==imp
by leaid: gen leadexpos1 = exp_wtotb if year==imp+1
by leaid: gen leadexpos2 = exp_wtotb if year==imp+2
by leaid: gen leadexpos3 = exp_wtotb if year==imp+3
by leaid: gen leadexpos4 = exp_wtotb if year==imp+4
by leaid: gen leadexpos5 = exp_wtotb if year==imp+5

collapse (mean) *55 *56 *66 *76 *86 *59 *58 *60 *69 *79 *89 *70 *80 *90 *68 *78 *88 *65 *75 *85 *imp* major south west region lead* lag*, by(leaid state)
drop imp_* msa90

sort leaid 
save ccd.dta, replace 

drop south west region lead* lag* disdimp exposimp

*** Create a copy with different variable names to be used for largest suburban district 
rename leaid leaidsub
rename white69 white69sub
rename black69 black69sub
rename stu69 stu69sub
rename white79 white79sub
rename black79 black79sub
rename stu79 stu79sub
rename white89 white89sub
rename black89 black89sub
rename stu89 stu89sub
rename disd69 disd69sub
rename disd79 disd79sub
rename disd89 disd89sub
rename expos69 expos69sub
rename expos79 expos79sub
rename expos89 expos89sub
rename imp impsub
rename major majorsub

sort leaidsub
save ccdsub.dta, replace


************ 3. Clean Districts Data from 1970 ******************

/*** Generate MD districts for 1970 separately using data from the 1970 
County Data Book because MD was not released in the 1970 school 
district census data.  Fortunately, MD has all county-level districts. ***/

use ../data/ccdb/county4070.dta
keep if year==70
keep if statefips==24

keep statefips cntyfips name pop 
gen district = _n
gen place = -9
*** This is for Baltimore, MD
replace place = 25 if cntyfips==510
replace district = 90 if cntyfips==510

save md-districts.dta, replace

/********* Create Main 1970 District Data ********************************
This data set is indexed by county/place combos.  Therefore any school 
district spanning places gets more than one record and needs to be combined ***/

use ../data/district70/district70.dta

** There is no point worrying about school districts in areas with no people
drop if pop==0 | district==99999

** Keep only elementary or unified school districts
keep if type==1|type==2

** Add MD data 
append using md-districts.dta 

** Fix bad place codes
do ../data/xwalk/place-change-code70.do

** Identify central city districts
sort statefips place
merge statefips place using ccsamp.dta
tab _merge

*** Set these variables to . for suburban districts
replace place = . if _merge==1
replace placefips = . if _merge==1
replace areaname = "" if _merge==1
drop _merge

** Create population in each school district/place combination (keeping name of largest pop area)
sort statefips cntyfips district place placefips areaname pop
by statefips cntyfips district place placefips areaname: replace name = name[_N]
collapse (sum) pop, by(statefips cntyfips district place placefips areaname name)

/** Appropriately recode to suburban districts partly in cities
that span counties or that are not the largest in the city (Phoenix case)  **/
** Atlanta spans 2 counties
replace place = . if statefips==13 & cntyfips==89 & district==1740
** Kansas City, MO spans 3 counties
replace place = . if statefips==29 & place==2220 & district~=16410
** Phoenix 
replace place = . if statefips==4 & place==260 & district~=6300
** Fort Worth
replace place = . if statefips==48 & place==1500 & district==15900
** Houston
replace place = . if statefips==48 & place==1975 & district~=23640
** Huntington, WV
replace place = . if statefips==54 & place==760 & district~=180
** Oklahoma City
replace place = . if statefips==40 & place==1815 & district~=22770
** Shreveport
replace place = . if statefips==22 & place==1240 & district~=300

/*** If central city has multiple school districts, assign the 
             largest by population to be the central district ***/
sort statefips cntyfips place pop district
by statefips cntyfips place: gen tobs = _N
by statefips cntyfips place: gen obs = _n

*** Set these variables to .
replace place = . if obs < tobs
replace placefips = . if obs < tobs
replace areaname = "" if obs < tobs
drop obs tobs

gen year = 1970
save temp70d.dta, replace


******************** 4. 1980 Districts ***********************

use ../data/district80/district80.dta

** There is no point worrying about school districts in areas with no people
drop if pop==0 

** Keep only elementary or unified school districts
keep if sdlvl=="E"|sdlvl=="U"|sdlvl=="1"|sdlvl=="3"
rename sdlvl type

keep statefips cntyfips district name cname type pop

gen year = 1980
save temp80d.dta, replace


*********** 5. 1990 Districts

use ../data/district90/district90.dta,clear
keep if type=="E"|type=="U"
rename AGENCYNO district

drop if statefips<1|statefips>56
rename NAME89 name
rename MEMBER89 students

keep statefips cntyfips district type name students
gen year = 1990


********** 6. Combine Districts and Assign Other Variables

append using temp80d
append using temp70d

*** Assign MSA Codes
do ../data/xwalk/msa-code.do
** Additional MSA for Worcester, MA
replace msa = 9240 if statefips==25 & cntyfips==27
drop if msa==-9
** Coded for cntyfips=0
drop if msa==0

*** Count the number of districts in each MSA
sort msa year statefips district
gen numdis = 0
by msa year: replace numdis = 1 if _n==1
by msa year: replace numdis = 1 if (district~=district[_n-1]|statefips~=statefips[_n-1]) & _n>1

/*** Assign placefips/place/areaname codes to CC school districts
Note: there is always 1 or 0 nonmissing place obs per msa ******/
sort msa statefips district place year
by msa statefips district: replace place = place[1] if place[1]~=.
by msa statefips district: replace placefips=placefips[1] if place[1]~=.
by msa statefips district: replace areaname=areaname[1] if place[1]~=.

/**** Fill in place/placefips/areaname codes for remaining years for districts that
changed names over time or are too complicated to automate.  Note that we maintain
old district counts before consolidation, after which we set consol=1         ******/
*Modesto, CA (split into Elementary and Secondary for 1990 only, only count elem)
replace place = 1790 if msa==5170 & district==25130
*Binghamton
replace place = 325 if msa==960 & (district==4830|district==4870)
*Fort Worth
replace place = 1500 if msa==2800 & district==19700
*Kansas City Mo
replace place = 2220 if msa==3760 & district==16400
*Knoxville TN Consolidated to Knox County b/t 1980 and 1990
gen consol = 0
replace place = 760 if statefips==47 & cntyfips==93 & year==1990
replace consol = 1 if msa==3840 & place==760 & year==1990
*Louisville => Jefferson County b/t 1970 and 1980
replace place = 1230 if msa==4520 & district==2990
replace consol = 1 if msa==4520 & district==2990 & year>=1980 
*Raleigh, NC => Wake County b/t 1970 and 1980
replace place = 2020 if statefips==37 & cntyfips==183 & year>1970
replace consol = 1 if msa==6640 & district==4720
*Fayetteville, NC => Cumberland County b/t 1980 and 1990
replace consol = 1 if msa==2560 & district==11
replace place = 910 if msa==2560 & district==11
*Rockford, IL
replace place = 4965 if msa==6880 & district==34510
* St. Louis
replace place = 3875 if statefips==29 & district==29280 
* Tucson
replace place = 320 if msa==8520 & district==8800
* Portland, OR
replace place = 905 if statefips==41 & district==10040
* Wilmington, DE got split into 3 districts in 1978 
* Then in 1981, a fourth district was created
replace place = 255 if statefips==10 & cntyfips==3 & district ~= 80 & district ~= 29 & year>=1980
replace consol = 1 if statefips == 10 & place==255 & year>=1980 

*** Drop MSAs with no CC data observed
egen xx = max(place), by(msa)
drop if xx==.

sort msa statefips cntyfips place year name

*** Confirm that except for Wilmington, DE there is exactly 1 CC district per MSA/year
egen maxdis = max(district) if place~=., by(msa year)
egen mindis = min(district) if place~=., by(msa year)
l msa year statefips cntyfips place name district if mindis~=maxdis & place~=.
drop maxdis mindis

** Create variables for total cc and msa population and students
gen ccdpop = pop if place~=. 
gen tdispop = pop 
gen ccdstu = student if place~=.
gen tdisstu = students

/** Create code for central district to merge with other data set
    The common core data set uses a modern (1990) district code **/
gen ccst = statefips if place~=. & year==1990
gen ccdis = district if place~=. & year==1990
gen double leaid = (ccst*100000) + ccdis
/** We observe a desegregation order in 1969 for the suburban Cumberland County, not the
city Fayetteville NC district, though the two subsequently merged.  Therefore,
it is important that the central district leaid be for Fayetteville city district only **/
replace leaid = 3701470 if msa==2560

*** Identify the largest suburban district
sort msa year place tdisstu 
by msa year place: gen subst = statefips if _n==_N
by msa year place: gen subdis = district if _n==_N
replace subst = . if place~=. | year~=1990
replace subdis = . if place~=. | year~=1990
gen leaidsub = (subst*100000) + subdis

** Create one observation per msa/year
sort msa areaname
by msa: replace areaname = areaname[_N]
gsort msa year place -pop -students
by msa year: replace name = name[1]
collapse (sum) ccdstu ccdpop tdis* numdis (max) consol leaid leaidsub, by(msa name areaname year)

** Fraction of pop or students in msa that are in the central district
gen fraction = ccdpop/tdispop
replace fraction = ccdstu/tdisstu if year==1990


************* 7. Add Desegregation Data *****************

*** Merge on Deseg Data for Central Cities
sort msa leaid
by msa: replace leaid = leaid[1]
*Wilmington, DE
replace leaid = 9999999 if msa==9160
sort leaid 

merge leaid using ccd.dta
tab _merge

** Add desegregation data for a few CC districts
*Gary, Albuquerque & NYC & Modesto, CA never had deseg plans
replace imp = 999 if msa==200|msa==2960|msa==5600|msa==5170
** Only keep MSAs with desegregation data about the central district
drop if imp==. | _merge==2
drop _merge

*** Merge on Deseg Data for Largest Suburban District
sort msa leaidsub
by msa: replace leaidsub = leaidsub[1]
sort leaidsub
merge leaidsub using ccdsub.dta
tab _merge
drop if _merge==2
drop _merge

**** Add on a 1960 cross-section
sort msa year
save ../data/districtpan.dta, replace
keep if year==1970
replace year = 1960
replace numdis = .
replace fraction = .
replace ccdpop = .
replace tdispop = .
append using ../data/districtpan.dta

**** Panel the year-indexed variables
gen disd = .
replace disd = disd59 if year==1960
replace disd = disd69 if year==1970
replace disd = disd79 if year==1980
replace disd = disd89 if year==1990
gen dis_wn = .
replace dis_wn = dis_wn59 if year==1960
replace dis_wn = dis_wn69 if year==1970
replace dis_wn = dis_wn79 if year==1980
replace dis_wn = dis_wn89 if year==1990
gen disdT = .
replace disdT = disd60 if year==1960
replace disdT = disd70 if year==1970
replace disdT = disd80 if year==1980
replace disdT = disd90 if year==1990
gen dis_wnT = .
replace dis_wnT = dis_wn60 if year==1960
replace dis_wnT = dis_wn70 if year==1970
replace dis_wnT = dis_wn80 if year==1980
replace dis_wnT = dis_wn90 if year==1990
gen disdm1 = .
replace disdm1 = disd58 if year==1960
replace disdm1 = disd68 if year==1970
replace disdm1 = disd78 if year==1980
replace disdm1 = disd88 if year==1990
gen disdm3 = .
replace disdm3 = disd56 if year==1960
replace disdm3 = disd66 if year==1970
replace disdm3 = disd76 if year==1980
replace disdm3 = disd86 if year==1990
gen dis_wnm3 = .
replace dis_wnm3 = dis_wn56 if year==1960
replace dis_wnm3 = dis_wn66 if year==1970
replace dis_wnm3 = dis_wn76 if year==1980
replace dis_wnm3 = dis_wn86 if year==1990
gen disdm4  = .
replace disdm4 = disd55 if year==1960
replace disdm4 = disd65 if year==1970
replace disdm4 = disd75 if year==1980
replace disdm4 = disd85 if year==1990
gen dis_wnm4 = .
replace dis_wnm4 = dis_wn55 if year==1960
replace dis_wnm4 = dis_wn65 if year==1970
replace dis_wnm4 = dis_wn75 if year==1980
replace dis_wnm4 = dis_wn85 if year==1990

drop disd56 disd66 disd76 disd86 disd59 disd69 disd79 disd89 disd60 disd70 disd80 disd90 disd55 disd65 disd75 disd85 disd58 disd68 disd78 disd88
drop dis_wn56 dis_wn66 dis_wn76 dis_wn86 dis_wn59 dis_wn69 dis_wn79 dis_wn89 dis_wn60 dis_wn70 dis_wn80 dis_wn90 dis_wn55 dis_wn65 dis_wn75 dis_wn85 dis_wn58 dis_wn68 dis_wn78 dis_wn88
gen disdsub = .
replace disdsub = disd69sub if year==1970
replace disdsub = disd79sub if year==1980
replace disdsub = disd89sub if year==1990
drop disd69sub disd79sub disd89sub
gen expos = .
replace expos = expos69 if year==1970
replace expos = expos79 if year==1980
replace expos = expos89 if year==1990
gen expos_bw = .
replace expos_bw = expos_bw69 if year==1970
replace expos_bw = expos_bw79 if year==1980
replace expos_bw = expos_bw89 if year==1990
gen exposT = .
replace exposT = expos60 if year==1960
replace exposT = expos70 if year==1970
replace exposT = expos80 if year==1980
replace exposT = expos90 if year==1990
gen expos_bwT = .
replace expos_bwT = expos_bw60 if year==1960
replace expos_bwT = expos_bw70 if year==1970
replace expos_bwT = expos_bw80 if year==1980
replace expos_bwT = expos_bw90 if year==1990
gen exposm4 = .
replace exposm4 = expos55 if year==1960
replace exposm4 = expos65 if year==1970
replace exposm4 = expos75 if year==1980
replace exposm4 = expos85 if year==1990
gen expos_bwm4 = .
replace expos_bwm4 = expos_bw55 if year==1960
replace expos_bwm4 = expos_bw65 if year==1970
replace expos_bwm4 = expos_bw75 if year==1980
replace expos_bwm4 = expos_bw85 if year==1990
drop expos69 expos79 expos89 expos60 expos70 expos80 expos90 expos55 expos65 expos75 expos85
drop expos_bw69 expos_bw79 expos_bw89 expos_bw60 expos_bw70 expos_bw80 expos_bw90 expos_bw55 expos_bw65 expos_bw75 expos_bw85
gen expossub = .
replace expossub = expos69sub if year==1970
replace expossub = expos79sub if year==1980
replace expossub = expos89sub if year==1990
drop expos69sub expos79sub expos89sub
gen white = .
replace white = white69 if year==1970
replace white = white79 if year==1980
replace white = white89 if year==1990
drop white69 white79 white89
gen whitesub = .
replace whitesub = white69sub if year==1970
replace whitesub = white79sub if year==1980
replace whitesub = white89sub if year==1990
drop white69sub white79sub white89sub
gen black = .
replace black = black69 if year==1970
replace black = black79 if year==1980
replace black = black89 if year==1990
drop black69 black79 black89
gen blacksub = .
replace blacksub = black69sub if year==1970
replace blacksub = black79sub if year==1980
replace blacksub = black89sub if year==1990
drop black69sub black79sub black89sub
gen stu = .
replace stu = stu69 if year==1970
replace stu = stu79 if year==1980
replace stu = stu89 if year==1990
drop stu69 stu79 stu89
gen stusub = .
replace stusub = stu69sub if year==1970
replace stusub = stu79sub if year==1980
replace stusub = stu89sub if year==1990
drop stu69sub stu79sub stu89sub


******************** 8.  Label Variables ******************************

label variable ccdstu "students in the central city district from Census (1990)"
label variable ccdpop "population of central city district from Census (1970-1980)"
label variable tdisstu "total district students in MSA from Census (1990)"
label variable tdispop "total district population of MSA from Census (1970-1980)"
label variable numdis "number of elem+unified districts in MSA from Census"
label variable leaid "ID Code for CC district"
label variable leaidsub "ID code for largest suburban district"
label variable white "white enrollment in 1969-1970, 1979-1980 or 1989-1990 from W&L"
label variable black "black enrollment in 1969-1970, 1979-1980 or 1989-1990 from W&L"
label variable stu "total enrollment 1969-1970, 1979-1980 or 1989-1990 from W&L"
label variable disd "dissimilarity index 1969-1970, 1979-1980 or 1989-1990 from W&L"
label variable disdT "dissimilarity index 1970-71, 1980-81 or 1990-91 from W&L"
label variable expos "w to b exposure index 1969-1970, 1979-1980 or 1989-1990 from W&L"
label variable exposT "w to bexposure index 1970-71, 1980-81 or 1990-91 from W&L"
label variable expos_bw "b to w exposure index 1969-1970, 1979-1980 or 1989-1990 from W&L"
label variable expos_bwT "b to w exposure index 1970-71, 1980-81 or 1990-91 from W&L"
label variable major "indicator for major desegregation order from w&l"
label variable imp "Desegregation order implementation year (Sep or beginning of sch yr) from W&L"
label variable fraction "fraction of pop (70-80) or students (90) in CC district from census "
label variable consol "central district includes consolidated districts-NOTE W&L data consol in all years, census data only consol in consol=1 years"
label variable lagdisd1 "diss index 1 year prior to implementation"
label variable disdimp "diss index in implementation year"
label variable leaddisd1 "diss index 1 year after implementation"
label variable lagexpos1 "exposure index 1 year prior to implementation"
label variable exposimp "exposure index in implementation year"
label variable leadexpos1 "exposure index 1 year after implementation"

sort msa year
save ../data/districtpan.dta, replace

erase temp.dta
erase temp70d.dta
erase temp80d.dta
erase md-districts.dta
erase ccsamp.dta
erase ccd.dta
erase ccdsub.dta

log close


