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
******
insheet using "$data/Hydro Plants/HydroStationList_withStateAllocations.csv", comma names clear case
repl_conf station = "R P SAGAR" if station=="R.P. SAGAR"
save "$work/HydroStationList_withStateAllocations.dta", replace
   

insheet using "$data/Hydro Plants/Global Observatory/hydro_plant_types_new.csv", comma names clear double
keep station state_final type_final  xcoord ycoord
replace state_final = upper(trim(state_final))
replace station = upper(trim(station))
replace type = lower(trim(type))
rename state_final state
rename type_final hydro_type
duplicates drop
replace state ="UTTAR PRADESH" if state=="UP"
replace state ="HIMACHAL PRADESH" if state=="HP"
replace state ="JAMMU AND KASHMIR" if state=="J&K"
replace state ="MADHYA PRADESH" if state=="MP"
replace xcoord=round(xcoord, .001)
replace ycoord=round(ycoord, .001)
tempfile hydrotype
save `hydrotype'


insheet using "$data/Hydro Plants/Performance/Generation Performance of HE Stations_1996_cleaned.csv", comma names clear
drop detail 
*drop if actualgenerationmu==. // generationmw are listed only at the plant level, but we do want to get all capacity at that plant.
replace actualgenerationmu=0 if actualgenerationmu==. // missings are actually zero generation
tostring totalmw actualgenerationmu generationtargetmu, replace force
cap drop v*
tempfile temp
save `temp'


insheet using "$data/Hydro Plants/Performance/Generation Performance of HE Stations_1997_cleaned.csv", comma names clear
drop detail 
*drop if actualgenerationmu==. // generationmw are listed only at the plant level, but we do want to get all capacity at that plant.
destring actualgenerationmu, replace
replace actualgenerationmu=0 if actualgenerationmu==. // missings are actually zero generation
tostring totalmw actualgenerationmu generationtargetmu, replace force
cap drop v*
tempfile temp2
save `temp2'

insheet using "$data/Hydro Plants/Performance/Generation Performance of HE Stations_1998_cleaned.csv", comma names clear
*drop if actualgenerationmu==. // generationmw are listed only at the plant level, but we do want to get all capacity at that plant.
drop if nodata==1 //for this year, plants under 20MW are not reported, so we dont want to assign them as zeros later on, so drop them outright
drop nodata
reshape long actualgenerationmu , i(station) j(year)
keep if year==1998 //because this sheet has other years that were kept around
destring actualgenerationmu, replace
replace actualgenerationmu=0 if actualgenerationmu==. // missings are actually zero generation
tostring  actualgenerationmu , replace force
cap drop v*
tempfile temp3
save `temp3'


insheet using "$data/Hydro Plants/Performance/Generation Performance of HE Stations_2000_2001_cleaned.csv", comma names clear
*drop if actualgenerationmu==. // generationmw are listed only at the plant level, but we do want to get all capacity at that plant.
reshape long actualgenerationmu generationtargetmu overtarget, i(station totalmw) j(year)
destring actualgenerationmu generationtargetmu , replace
drop if actualgenerationmu==. &totalmw==. & generationtargetmu==. //this gets rid of those with no reporting in one year so that the associated MW don't get dragged through
replace actualgenerationmu=0 if actualgenerationmu==. // missings are actually zero generation
drop if totalmw==0
tostring totalmw actualgenerationmu generationtargetmu, replace force
cap drop v*
tempfile temp4
save `temp4'


insheet using "$data/Hydro Plants/Performance/Performance of Hydro Power Stations_adjusted.csv", comma names clear
drop if drop==1 //those getting dropped are duplicate entries from the manual entry
drop drop adjusted //adjusted is just an internal flag if the original hand entry was wrong and has since been changed
append using `temp'
append using `temp2'
append using `temp3'
append using `temp4'
drop  generationtargetmu overtarget
replace station = upper(trim(station))
replace totalmw = "400" if totalmw=="Koteshwar" //this is a typo so i assign capacity to the same as subsequent year
drop if actual=="N.A"
destring actualgener, replace
destring totalmw, gen(HydroMW_micro) // HydroMW_microdata
duplicates drop
merge m:1 station using `hydrotype', keep(1 3) 
	assert _m==3
	drop _m
drop if state=="DROP"
drop if state=="BHUTAN"
drop if state=="UNK"  // | hydro_type=="unk"

replace HydroMW_micro = . if  HydroMW_micro	== -99999 |  HydroMW_micro ==-9999
replace actualgenerationmu= . if actualgenerationmu==-99999 | actualgenerationmu==-9999

*now fill in with last known or next known capacity before collapses--this saves a little data eventually
replace HydroMW_micro	=HydroMW_micro[_n-1] if (HydroMW_micro==. | HydroMW_micro==0) & station==station[_n-1]
gsort station -year
replace HydroMW_micro	=HydroMW_micro[_n-1] if (HydroMW_micro==. | HydroMW_micro==0) & station==station[_n-1]
gsort station +year
*these must be dropped
*drop if HydroMW_micro==-99999
assert HydroMW_micro>=0 | mi(HydroMW_micro)
assert actual>=0 | mi(actual)


**here we fix names
bys station year: g rank=_N
tab rank
*br if rank>1
count

collapse (sum) HydroMW_micro actual, by(state station year hydro_type xcoord ycoord) //this collapses entries of different units in sample plant in a couple places into single obs by plant-year  //
replace  HydroMW_micro = . if year==1998 //so these do not show up as zeroes since we dont have the info for 1998
assert _N==3852
preserve
import excel "$data/Hydro Plants/Global Observatory/clean_plant_names.xlsx", sheet("Sheet1") firstrow clear case(lower)
keep station state group group_type
duplicates drop
bys station state: g rank=_N
assert rank==1
drop rank
tempfile temp
save `temp'
restore
merge m:1 station state using `temp', keep(1 3)
	assert _m==3
	drop _m
g station_orig = station
replace station = group if group!=""
replace hydro_type = group_type if group_type!=""

replace state = "WEST BENGAL" if station=="JALDHAKA, MASSANJORE AND RAMMAM COMPLEX"
replace state = "UTTARAKHAND" if station=="MOHAMADPUR, PATHRARI AND NIRGAJANI COMPLEX"

*check uniqueness
preserve 
keep station state
duplicates drop
bys station: g rank=_N
assert rank==1 if state!=""
restore
****end check uniqueness

gsort station +year
bys station: g rank=_n
g flag = actualgenerationmu==0 & rank==1
replace flag = flag[_n-1] if  actualgenerationmu==0 & flag[_n-1]==1 & station==station[_n-1]  //next line gets rid of the set of leading observations with zero generation that appear in the data before plants started producing (for example: br if station=="SARDAR SAROVAR COMPLEX" before the next line)
drop if flag
drop rank flag
drop group group_type

**set up unique coordinates to be used within combined plant reportings based on location of largest sub-plant
gsort state station -HydroMW_micro -year
bys state station : g index=_n
g xcoord_max = xcoord if index==1
g ycoord_max = ycoord if index==1
bys state station: egen xcoord_final = mean(xcoord_max)
bys state station: egen ycoord_final = mean(ycoord_max)

replace xcoord = xcoord_final
replace ycoord = ycoord_final
assert !mi(xcoord) & !mi(ycoord) //no plants are missing coordinates


collapse (sum) HydroMW_micro actual, by(state station year hydro_type ycoord xcoord) //this collapses by complex after fixing names 
assert _N==3051
replace HydroMW_micro = . if year ==1998

***check into fluctutions within group
preserve
keep if year>=1992 & year<=2010
collapse (mean) mean=HydroMW_micro (sd) sd=HydroMW_micro, by(station)
g check = sd/mean
drop if check<0.01 | check==.
gsort - check
outsheet using "$work/within station variance check.csv", comma names replace
restore
*** end check

***fix MW availability for 1998 here
gsort station year
replace HydroMW_micro = HydroMW_micro[_n+1] if HydroMW_micro==. & year==1998 & station==station[_n+1]
replace HydroMW_micro = HydroMW_micro[_n-1] if HydroMW_micro==. & year==1998 & station==station[_n-1]
***

*** Get capacity factor
gen CF = actualgenerationmu/8.760/HydroMW_micro // 8760 hours/year, 1000 MW/GW gives 8.760.



*define
	* The below makes RunOfRiver missing if hydro_type == "unk"
g RunOfRiver = hydro_type=="barrage with run-of-river generation" | hydro_type=="run-of-river" | hydro_type=="dam with run-of-river generation" if hydro_type!="unk"
*g Dam = hydro_type=="dam on a canal" | hydro_type=="dam on a lake"| hydro_type=="dam on river with reservoir" | hydro_type=="dam" 
*g OtherHydroType = RunOfRiver==0 & Dam==0

keep if year>=1992


replace state ="UTTARANCHAL" if state=="UTTARAKHAND"

**set up crossed dataset
bys station state year: g rank=_N
	assert rank==1
	drop rank
	assert _N==2612
	
*keep just the years for analysis
keep if year>=1992 & year<=2010
bys station state: egen firstyear = min(year)
bys station state: egen lastyear = max(year)
	assert !mi(firstyear) & !mi(lastyear)
	tempfile stationsinfo
	save `stationsinfo'
*stations base
keep station state firstyear lastyear xcoord ycoord
duplicates drop
tempfile stationsbase
save `stationsbase'
*years base
clear
set obs 19
g year=_n+1991
assert year>=1992 & year<=2010
cross using `stationsbase'
bys station state firstyear lastyear: g rank=_N
	assert rank==19 //is square by year
	drop rank
	count //assert _N==
drop if year>lastyear //pare off the years outside observed span that were introduced by crossing

	* 1992 is fully missing. Temporarily replace firstyear=1992 in order to get a 1992 year that duplicates 1993.
	replace firstyear = 1992 if firstyear==1993
	drop if year<firstyear //pare off the years outside observed span that were introduced by crossing
	replace firstyear = 1993 if firstyear==1992

merge 1:1 station state year firstyear lastyear using `stationsinfo', assert(1 3) //1s will be the new obs input by the squaring; these are very few
	count if _m==1
	assert r(N)==156 //out of 2746 -- very few
	tab year _m //most in 1992 by construction, else 98 by nature of that year's data
	br if _m==1 & year!=1992 & year!=1998
	*gen imputed_plant_year = _m==1 //note that none of the capacity or production data has yet been imputed
	drop _m

** Drag back data for 1992
gsort state station year
foreach var in hydro_type HydroMW_micro RunOfRiver {
	replace `var' = `var'[_n+1] if year==1992 & year[_n+1]==1993 & station==station[_n+1] & state==state[_n+1]
	replace `var' = `var'[_n-1] if year==2008& year[_n-1]==2007& station==station[_n-1] & state==state[_n-1] & station=="SEWA 3"
}

repl_conf actualgenerationmu	= 0 if station=="SEWA 3" & year==2008
repl_conf CF = 0 if station=="SEWA 3" & year==2008
	
//output unique hydro station list with coordinates
preserve
keep state station xcoord ycoord
duplicates drop
bys state station: g rank=_N
assert rank==1
drop rank
gsort state station
g index=_n
order index
outsheet using "$work/hydro_stations_list_v2.csv", comma names replace
restore

save "$work/Hydro Plant Generation Microdata.dta", replace


********************************************************************************
********************************************************************************
/* RAINFALL BY DAM BASIN */
//create base basinwise dataset of station gridpoints by month
clear
set obs 12
g month =_n
tempfile month
save `month'
set obs 19
rename  month year
replace year = _n+1991
cross using `month'
save `month', replace

//create matrix of plant-by-month obs
use "../GIS_Work/rain_hydro_merge3.dta", clear //this is the list of gridpoints per plant basin
*assign single nearest gridpoint when missing
repl_conf lat =  round(hydro_lat,.5)-.25+.5*(hydro_lat>round(hydro_lat,.5)) if lat==.
repl_conf lon =  round(hydro_lon,.5)-.25+.5*(hydro_lon>round(hydro_lon,.5)) if lon==.
repl_conf lon = 84.25 if lat== 18.75 & lon==85.25 //fixes one place assigned to nearest single gridpoint but not in rainfall data
repl_conf lon = 80.25 if lat== 13.25 & lon==93.25 //gets A&N to have something; later, this should be changed to Burma
drop hydro_lat hydro_long hydro_id
*replace hydro_id = hydro_id+1 //somehow this got adjusted in the GIS processing; bringing back to original
duplicates drop
assert _N==1687 //just the number, not square
tempfile temp2
save `temp2'

keep station state
duplicates drop
tempfile stationsmatch
save `stationsmatch'


use "$work/Hydro Plant Generation Microdata.dta", clear
*bys station: egen firstyear=min(year)
assert xcoord!=. & ycoord!=.
keep station state firstyear
duplicates drop
assert _N==188 //188 stations
cross using `month' //observe every station in every yearXmonth
gsort station year month	
assert _N==42864 //188 stations * 19 years * 12 months
	***check merge will work
	preserve
	keep station state
	duplicates drop
	merge 1:1 station state using `stationsmatch', assert(3) nogen
	restore

joinby station state using `temp2'


assert _N==384636 //just the number, not square
bys station state lat lon: g rank=_N
assert rank==228 //check balanced panel by station and gridpoint (12 months*19 years=228)
drop rank



merge m:1 lat lon year month using  "$work/Udel_rainfall_halfdeg_monthly.dta", keepusing(_rainfall) keep(1 3)
assert _m==3
drop _m
gsort station year month lat lon

save "$work/station-basin-gridpoint by month w rainfall.dta", replace

collapse (sum) _rainfall, by(station state lat lon year) //annual sums (across months) by gridpoint
collapse (mean) _rainfall, by(station state year) //annual mean rainfall within basin across gridpoints
*g double annual_rainfallMW = _rainfall*hydro_MW_final/1000000 //weighted by capacity per basin, and div by mm to make smaller
save "$work/hydrobasin-year MWMeters.dta", replace

*******************************************************************************************
/* Collapse station rainfall to the ResScheme level (Reservoir Schemes per the CEA inflows data) */
	* This is used to impute rainfall in 2000 when the Reservoir inflows are missing.
** Get crosswalk from reservoir scheme to hydro station name (for matching rainfall) 
import excel "$data/CEA/Hydro/crosswalk stations to reservoirs.xlsx", sheet("crosswalk cols A C from pic") firstrow clear
duplicates drop
drop if station==""
save "$intdata/crosswalk stations to reservoirs.dta", replace


use "$work/hydrobasin-year MWMeters.dta", replace
merge m:1 station using "$intdata/crosswalk stations to reservoirs.dta", keep(match master) nogen
drop if ResScheme==""
collapse (sum) ResRainfall = _rainfall, by(ResScheme year) // hydro_MW_final
save "$work/Reservoir Rainfall.dta", replace
**********************************************************************************