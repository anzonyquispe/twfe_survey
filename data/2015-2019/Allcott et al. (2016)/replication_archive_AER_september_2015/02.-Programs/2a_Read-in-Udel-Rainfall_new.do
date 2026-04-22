************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************
clear
tempfile master temp
forval i = 1991/2010 {
clear
infix str lon 1-8 str lat 9-16 str _1 17-24 str _2 25-32 str _3 33-40  str _4 41-48  str _5 49-56  str _6 57-64  str _7 65-72  str _8 73-80  str _9 81-88  str _10 89-96  str _11 97-104  str _12 105-112 using "$data/UDel_Rainfall/Global2011P/precip.`i'"
g field="rainfall"
save `temp', replace
*clear
*infix str lon 1-8 str lat 9-16 str _1 17-24 str _2 25-32 str _3 33-40  str _4 41-48  str _5 49-56  str _6 57-64  str _7 65-72  str _8 73-80  str _9 81-88  str _10 89-96  str _11 97-104  str _12 105-112 using "$data/UDel_Rainfall/Global2011T/air_temp.`i'"
*g field="temp"
*append using `temp'
g year = `i'
destring lat lon, replace
*square around india
*lon 68-98
*lat 8-37
*india is in first quadrant so all values positive
keep if lon >=67.75 & lon<=98.25
keep if lat >=7.25 & lat<=37.75
cap append using `master'
save `master', replace
}

destring _*, replace
reshape long _, i(lat lon year field) j(month)
reshape wide _, i(lat lon year month) j(field) string

***get complete FY
preserve
keep if year==2010 & month<=3
replace year=2011
tempfile _2011
save `_2011'
restore
append using `_2011'

save "$work/UDel Rainfall_Month.dta", replace


**output to get set of unique gridpoints that could be matched to in GIS work
use "$work/UDel Rainfall_Month.dta",clear
keep lat lon
duplicates drop
gsort lat lon
outsheet using "$work/UDel_rainfall_gridpoints.csv", comma names replace
bys lat: g rank=_N //just shows the matrix is not square, actually corresponds to landmass
tab rank

*****************************************************
****CREATE STATE BY GRIDPOINT BY YEAR BY MONTH, MAKE ADJUSTMENTS AND AGGREGATE
*****************************************************
****construct base india grid
***lat
clear
set obs  61
g lat=6.75+(_n/2)
tempfile lat
save `lat'
rename lat lon
replace lon=67.25+(_n/2)
tempfile lon
save `lon'
clear
set obs 35 //number of states
g id=_n
cross using `lat'
cross using `lon'
gsort id lat lon
tempfile mastergridcross
save `mastergridcross'

****load shapefile  ***requires shp2dta package to be installed
shp2dta using "$root/09. Maps/01. Layer files/DIVA GIS/IND_adm1.shp", database(indiastatesdb) coordinates(indiacoord) genid(id) replace

***get span of each polygon
use indiacoord.dta, clear

***this is important: I take the RECTANGULAR set of gridpoints encompassing a state based on min/max lat & lon
collapse (min) minX=_X minY=_Y (max) maxX=_X maxY=_Y, by(_ID)
rename _ID id
tempfile xy
save `xy'

***this is the base MAX grid width for each state; now pare down crossed file 
use `mastergridcross'
merge m:1 id using `xy', assert(3) nogenerate

//the following allows points to be assigned to D&N Haveli and Chandigarh & Lakshadweep
replace minY=30.25 if id==6
replace minX = 76.25 if id==6

replace minY=20.25 if id==8
replace maxY=20.25 if id==8
replace minX = 72.25 if id==8

***keep gridpoint-state pair if gridpoint is within max ranges of lat and long for state
keep if (lon>=minX &lon<=maxX &lat>=minY & lat<=maxY) | (id==10 & lat==28.25 & (lon==76.25 | lon==77.25))  /*by visual inspection this looks good, latter condition keeps delhi which is between gridpoints */
	
keep id  lat lon
merge m:1 id using indiastatesdb, keepusing(NAME_1) assert(2 3) nogenerate keep(match)

drop id 
rename NAME_1 state

//to get nonzero for Lak -- just change one gridpoint to make matchable
repl_conf lat=10.25 if state=="Lakshadweep" & lat==8.75 & lon==72.25
repl_conf lon = 76.25 if state=="Lakshadweep"  & lat==10.25 & lon==73.25


tab state
g himalaya = 0
foreach state in "Jammu and Kashmir" "Himachal Pradesh" "Uttaranchal" "Sikkim" "Assam" "Arunachal Pradesh" {
repl_conf himalaya=1 if state=="`state'"
}
count if lat==10.25 & lon==76.25
tab state if lat==10.25 & lon==76.25
tempfile states
save `states'
count

use "$work/UDel Rainfall_Month.dta", clear
count if lat==10.25 & lon==76.25
joinby lat lon using `states',  unmatched(none)
assert _N==564975

***adjust year to be by FY or Rainfall Year depending on state
repl_conf year=year-1 if month<=3 & himalaya==0 /*year is now FY not CY for non-himalayan states: April(t) to Mar(t+1) for FY(t) -- this is official FY definition */
repl_conf year=year+1 if month>=11 & himalaya==1 /*year is now snowfall year not CY for himalayan states: Nov(t-1) to Oct(t) for FY(t)*/
drop himalaya
keep if year >=1992 & year<=2010


*** Collapse to annual level by gridpoint
g count=1
bys state lat lon year: egen count2=sum(count)
assert count2==12  //12 months per year and gridpoint
drop count*

**checks on Lak
qui sum _rainfall if state=="Lakshadweep", meanonly
assert r(mean)>0 & r(mean)!=.
tab state, sum(_rainfall)


****collapse mean of available annual gridpoints within state and year for merge into ASI data
* first collapse to annual total for each lat lon point
collapse (sum) _rainfall, by(year lat lon state)

* then collapse across gridpoints to state mean
collapse (mean) rainU = _rainfall, by(state year) // rainU = "Rainfall UDel"
replace rainU = rainU/1000 //put in meters. Was originally in mm monthly totals, summed to annual

bys state: g rank=_N
assert rank==19
drop rank

//A&N ISLANDS DATA FOR POSTING INTO NCC
preserve
keep if state=="Andaman and Nicobar"
rename rainU rain
save "$work/ANrainfall_Udel", replace
restore

/* Get state averages and deviations */
local rainvar = "rainU"
include "$do/subroutines/GetRainfallVariables.do"

replace state = upper(trim(state))
replace state="GOA DAMAN AND DIU" if state=="DAMAN AND DIU"
replace state="PONDICHERRY" if state=="PUDUCHERRY"
replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="ANDAMAN AND NICOBAR"
save "$work/state-year UDel rainfall.dta", replace




