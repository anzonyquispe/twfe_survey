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
************************************************************************
****************************
***	temp data
****************************
*21 Sept 2014: added temp loop to include CY 2010 and 2011 grid received since last iteration
qui forval year=1990/2011 {
clear
noi dis `year'
insheet using "$data/NCC/Temperature Grid/MeanT/MeanT`year'.TXT"
format v1 %-200s
g index=_n

***clean up blocks
drop if strpos(v1,"DAILY MEAN TEMPARATURE")>0 /*chops off block headers since I will read this in fixed format later */
drop if strpos(v1,"DAILY MEAN TEMPERATURE")>0 /*chops off block headers since I will read this in fixed format later */
drop if strpos(v1,"66.5   67.5   68.5   69.5   70.5   71.5   72.5   73.5   74.5   75.5   76.5   77.5   78.5   79.5   80.5")>0 /*chops off block headers since I will read this in fixed format later */

***dictionary back in
outfile using "$work/`year'.raw", replace nolabel noquote wide 
clear
infile using "$data/NCC/Temperature Grid/MeanT/dictionary.dct", using("$work/`year'.raw")
erase "$work/`year'.raw"

***clean up and reshape
reshape long _, i(month dayno day lat) j(lon) string
	rename _ meantemp
	drop if meantemp=="99.90" /*NB--this line is not dropping non-india coordinates */
	foreach i in lat lon {
	foreach j in N E {
	replace `i'=subinstr(`i',"`j'","",.)
	}
	}
	destring _all, replace
		format meantemp %8.2f /*this just asserts temp was converted to numeric, otherwise the loop will kick*/
		
	replace lon=lon/10
	g date=date(string(month)+"-"+string(day)+"-"+"`year'","MDY")
	format date %d
	order date
	drop dayno
	tempfile _`year'
	save `_`year''
}



use `_1990', clear
forval year=1991/2010 {
append using `_`year''
}

compress
save "$work/tempgrid_base.dta", replace

************************
***rainfall data
***********************
***note that 2011 and 2012 data are still in YET ANOTHER format--this code will break if applied to those year
qui forval year=1990/2010 {
clear
noi dis `year'
insheet using "$data/NCC/Rainfall Grid/data/ascii/drf_`year'.prt"
format v1 %-200s
g index=_n

***flag day records
replace v1=subinstr(v1,"Day =","Day=",.)
g d=trim(subinstr(v1,"Day=","",.)) if strpos(v1,"Day=")>0
	qui tab d
	assert r(N)==365 | r(N)==366 /*this is just a check to make sure all dates are captured with the previous string command */
	replace d=d[_n-1] if d==""
	drop if strpos(v1,"Day=")>0
	g month=month(date(d+"-`year'","DMY"))
	g day=substr(d,1,strpos(d,"-")-1)
		destring day, replace
		drop d
	
***clean up blocks
drop if strpos(v1,"66.5E 67.5E 68.5E 69.5E 70.5E 71.5E 72.5E 73.5E 74.5E 75.5E 76.5E")>0 /*chops off block headers since I will read this in fixed format later */
drop if strpos(v1,"66.5E  67.5E  68.5E  69.5E  70.5E  71.5E  72.5E  73.5E  74.5E  75.5E")>0 //this does the same for differently-formatted years 2008-2010

replace v1=subinstr(v1,"9.5N","09.5N",.) if substr(v1,1,4)=="9.5N" /*properly aligns*/
replace v1=subinstr(v1,"8.5N","08.5N",.) if substr(v1,1,4)=="8.5N" /*properly aligns*/

g lat=substr(v1,1,strpos(v1,"N"))
replace v1=substr(v1,strpos(v1,"N")+1,.)
order index  month day lat


***dictionary back in
outfile using "$work/`year'.raw", replace nolabel noquote wide 
clear
if `year' < 2008 {
infile using "$data/NCC/Rainfall Grid/data/ascii/dictionary.dct", using("$work/`year'.raw")
}
else {
infile using "$data/NCC/Rainfall Grid/data/ascii/dictionary20082012.dct", using("$work/`year'.raw")
	foreach var of varlist _* {
		replace `var' = "" if trim(`var')=="-99.9"
		}
}
erase "$work/`year'.raw"

***clean up and reshape
reshape long _, i( index month day lat) j(lon) string
	rename _ rainfall
	drop if rainfall=="" /*NB--this line is not dropping zero reported rainfall---this drops non-india coordinates */
	drop index
	foreach i in lat lon {
	foreach j in N E {
	replace `i'=subinstr(`i',"`j'","",.)
	}
	}
	destring _all, replace
		format rainfall %8.2f /*this just asserts rainfall was converted to numeric, otherwise the loop will kick*/
		
	replace lon=lon/10
	g date=date(string(month)+"-"+string(day)+"-"+"`year'","MDY")
	format date %d
	order date
	g year=`year'
	tempfile _`year'
	save `_`year''
}

use `_1990', clear
forval year=1991/2010 {
append using `_`year''
}

compress
save "$work/rainfallgrid_base.dta", replace

use "$work/rainfallgrid_base.dta", clear
merge 1:1 date lat lon using "$work/tempgrid_base.dta", keep(match master using )
	tab year _m
	drop _m

save "$work/temp-rainfallgrid_base1.dta", replace
erase "$work/rainfallgrid_base.dta"
erase "$work/tempgrid_base.dta"

use "$work/temp-rainfallgrid_base1.dta", clear

**put temp into deg F
replace meantemp=meantemp*9/5+32
sum meantemp, d
** Calculate HDD and CDD from different bases
forvalues base = 55(5)80 {
gen HDD`base' = cond(meantemp!=.,max(0,`base'-meantemp),.)
gen CDD`base' = cond(meantemp!=.,max(0,meantemp-`base'),.)
}

*** Collapse to monthly level by gridpoint -- ADDED OCT 2014
g count=1
collapse (sum) count HDD* CDD* rainfall, by(year month lat lon)
bys lat lon year: g rank=_N
tab rank //a small percent of gridpoint-years dont have all 12 months---assume missings were zero based on inspection of rainfall in adjacent months
drop rank
save "$work/NCC_Rainfall_Temp_Month.dta", replace


*****************************************************
****CREATE STATE BY GRIDPOINT BY YEAR BY MONTH, MAKE ADJUSTMENTS AND AGGREGATE
*****************************************************
***construct and then cross by state file
****construct base india grid
***lat
clear
set obs  30
g lat=6.5+_n
tempfile lat
save `lat'
rename lat lon
replace lon=67.5+_n
tempfile lon
save `lon'
rename lon id
set obs 35
replace id=_n
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

//the following allows points to be assigned to D&N Haveli and Chandigarh
replace minY=30.5 if id==6
replace minX = 76.5 if id==6

replace minY=20.5 if id==8
replace maxY=20.5 if id==8
replace minX = 72.5 if id==8

***keep gridpoint-state pair if gridpoint is within max ranges of lat and long for state
keep if (lon>=minX &lon<=maxX &lat>=minY & lat<=maxY) | (id==10 & lat==28.5 & (lon==76.5 | lon==77.5))  /*by visual inspection this looks good, latter condition keeps delhi which is between gridpoints */

	
keep id  lat lon
merge m:1 id using indiastatesdb, keepusing(NAME_1) assert(2 3) nogenerate keep(match)

drop id 
rename NAME_1 state

//to get nonzero for Lak -- just change one gridpoint to make matchable
repl_conf lat=10.5 if state=="Lakshadweep" & lat==8.5 & lon==72.5
repl_conf lon = 76.5 if state=="Lakshadweep"  & lat==10.5 & lon==73.5


tab state
g himalaya = 0
foreach state in "Jammu and Kashmir" "Himachal Pradesh" "Uttaranchal" "Sikkim" "Assam" "Arunachal Pradesh" {
repl_conf himalaya=1 if state=="`state'"
}

tempfile states
save `states'
count
***pare down years and collapse to annual data by grid
use "$work/NCC_Rainfall_Temp_Month.dta", clear
joinby lat lon using `states',  unmatched(none)
assert _N==146599

***adjust year to be by FY or Rainfall Year depending on state
replace year=year-1 if month<=3 & himalaya==0 /*year is now FY not CY for non-himalayan states: April(t) to Mar(t+1) for FY(t) -- this is official FY definition */
replace year=year+1 if month>=11 & himalaya==1 /*year is now snowfall year not CY for himalayan states: Nov(t-1) to Oct(t) for FY(t)*/
drop himalaya
keep if year >=1992 & year<=2010


*** Collapse to annual level by gridpoint and state
collapse (sum) count HDD* CDD* rainfall, by(year lat lon state)

**checks on Lak
qui sum rainfall if state=="Lakshadweep", meanonly
assert r(mean)>0 & r(mean)!=.

* Dividing by days available puts in units of average per day, which makes the regression results look prettier. Daily average CDDs.
foreach var of varlist HDD* CDD* {
	replace `var' = `var'/count
}
drop count

* Rainfall is in MM, put into meters
replace rainfall=rainfall/1000

gsort state lat lon year


****collapse mean of available annual gridpoints within state and year for merge into ASI data
collapse (mean)  HDD* CDD* rain=rainfall, by(state year)
bys state: g rank=_N
tab rank
assert state =="Andaman and Nicobar" if rank<19
drop rank

*fill in andamans
qui foreach i in 1999 2004 2007 2008 2009 2010 {
count 
local count =r(N) +1
set obs `count'
replace state = "Andaman and Nicobar" if _n==_N
replace year = `i' if _n==_N
}

bys state: g rank=_N
assert rank==19
bys state year: g rank2=_N
assert rank2==1
drop rank*

/*post in A&N Data from UDel dataset from southern Burma*/
merge 1:1 state year using "$work/ANrainfall_Udel", assert(1 4 5) nogen update replace

* A&N Islands is missing degree days for some years.
	* Impute with the previous year's value
foreach var of varlist ?DD* {
	replace `var' = `var'[_n-1] if `var'==. & state=="Andaman and Nicobar"
}

/* Get state averages and deviations */
local rainvar = "rain"
include "$do/subroutines/GetRainfallVariables.do"


replace state = upper(trim(state))
replace state="GOA DAMAN AND DIU" if state=="DAMAN AND DIU"
replace state="PONDICHERRY" if state=="PUDUCHERRY"
replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="ANDAMAN AND NICOBAR"
save "$work/state-year NCC rainfall temp.dta", replace
