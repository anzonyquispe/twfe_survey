/*

Stata script for pulling together the watersheds of hydro plants created in Arcview

Allan Collard-Wexler

First Version: October 16 2014

Current Version: November 23 2014

*/



clear all
set more off

set obs 1
gen cons=0
save rain_watershed_hydro_plant3, replace
clear

// Hydro plants
insheet using hydro_stations_list_v3.csv
rename xcoord hydro_long
rename ycoord hydro_lat

rename index hydro_id

save hydroplants, replace


// Assembly

forval i=1/188 {

clear
cd India_GIS
cd export_data

insheet using rain_map_hydro_`i'.csv 

keep lat lon hydro_plan
rename hydro_plan hydro_id

cd ..
cd ..

append using rain_watershed_hydro_plant3
save rain_watershed_hydro_plant3, replace

}

clear 
use rain_watershed_hydro_plant3

sort hydro_id

merge m:1 hydro_id using hydroplants

drop if cons==0
drop cons

drop _merge
save rain_hydro_merge3, replace


