/**
cln-seggis-all.do

This do-file cleans the GIS data in this directory.
Each file is all the census tracts from each year 
spatially joined to the following layers in the following order:

The 60,70,80 and 90 data include the full set of tracts nationally
and have not been clipped. 

1. Unified school districts in 1970
2. Secondary school districts in 1970 
3. Unified school districts in 2000
4. Secondary school districs in 2000
5. CBDs
6. Full 1970 tract geography

Each spatial merge has a distance associated with it.  In the case
of merges 1-4, a distance of 0 means that the tract falls inside the
listed district.  Distances will be nonzero for secondary if the tract
is in a unified district and vice-versa.  Checks performed in the code
below confirm that each tract falls within a district in 1970 and 2000.
For merge 5, the distance field shows the distance to the nearest CBD
of which there is one per metropolitan area.

**/

clear
set more off
set mem 250m

capture log close
log using cln-seggis-all.log, replace text


****************** 1960 ************************

use jn60_all6.dta
gen year = 1960

*** Drop Places that are not real tracts
drop if substr(gisjoin,-6,.)=="nodata"

*** Create areakey identifier
gen areakey = substr(gisjoin,1,2)+substr(gisjoin,4,.)

*** 1970 Districts
rename stdis sdu70
replace sdu70 = . if distance>0
rename stdis_1 sds70
replace sds70 = . if distance_1>0

*** 2000 School Districts
gen sdu_st = real(state) if distance_2==0
gen sdu_code = real(sd_u) if distance_2==0
gen sdu_name=name if distance_2==0
gen sdu_area=area if distance_2==0
** Only keep the inner part of Wilmington, DE for the city
replace sdu_code = 88888 if sdu_st==10 & sdu_code==200 & sdu_area>160000000
gen sds_st = real(state_1) if distance_3==0
gen sds_code = real(sd_s) if distance_3==0
gen sds_name = name_1 if distance_3==0

rename distance_4 cbd_dis
rename first_name cbd_name
gen cbd_state = real(first_stat)
rename x_coord_1 x_cbd
rename y_coord_1 y_cbd 

rename distance_5 tr70_dis

save t60.dta, replace


******************* 1970 *************************

use jn70_all6.dta,clear
gen year = 1970

/****** List all tracts without a school district:  These fall
in districts of fewer than 300 students and thus are not 
identified in the 70 geographic reference file or because of bad
spatial merging to the 90 district data  *******/
tab state if distance>0 & distance_1>0 & state~=24 
tab state if distance_2>0 & distance_3>0 

*** 1970 Districts
rename stdis sdu70
replace sdu70 = . if distance>0
rename stdis_1 sds70
replace sds70 = . if distance_1>0

*** 2000 School Districts
gen sdu_st = real(state_1) if distance_2==0
gen sdu_code = real(sd_u) if distance_2==0
gen sdu_name=name if distance_2==0
gen sdu_area=area_1 if distance_2==0
** Only keep the inner part of Wilmington, DE for the city
replace sdu_code = 88888 if sdu_st==10 & sdu_code==200 & sdu_area>160000000
gen sds_st = real(state_2) if distance_3==0
gen sds_code = real(sd_s) if distance_3==0
gen sds_name = name_1 if distance_3==0

rename distance_4 cbd_dis
rename first_name cbd_name
gen cbd_state = real(first_stat)
rename x_coord_1 x_cbd
rename y_coord_1 y_cbd 

rename distance_5 tr70_dis

save t70.dta, replace


****************** 1980 ************************

use tr80_area.dta
sort areakey
save tr80_area.dta, replace

use jn80_all6.dta, clear
gen year = 1980

*** Merge on tract areas
sort areakey
merge areakey using tr80_area.dta
tab _merge
drop _merge

*** 1970 School Districts
rename stdis sdu70
replace sdu70 = . if distance>0
rename stdis_1 sds70
replace sds70 = . if distance_1>0

*** 2000 School Districts
gen sdu_st = real(state_1) if distance_2==0
gen sdu_code = real(sd_u) if distance_2==0
gen sdu_name=name if distance_2==0
gen sdu_area=area_1 if distance_2==0
** Only keep the inner part of Wilmington, DE for the city
replace sdu_code = 88888 if sdu_st==10 & sdu_code==200 & sdu_area>160000000
gen sds_st = real(state_2) if distance_3==0
gen sds_code = real(sd_s) if distance_3==0
gen sds_name = name_1 if distance_3==0

rename distance_4 cbd_dis
rename first_name cbd_name
gen cbd_state = real(first_stat)
rename x_coord_1 x_cbd
rename y_coord_1 y_cbd 

rename distance_5 tr70_dis

save t80.dta, replace


********************* 1990 ***********************

use tr90_area.dta
sort gisjoin2
save tr90_area.dta, replace

use jn90_all6.dta, clear
gen year = 1990

*** Merge on tract areas
sort gisjoin2 
merge gisjoin2 using tr90_area.dta
tab _merge
drop _merge

*** Create areakey variable
gen str areakey = substr(gisjoin2,1,2)+substr(gisjoin2,4,3)+substr(gisjoin2,8,.)
replace areakey = areakey+"00" if length(gisjoin2)==11

*** 1970 School Districts
rename stdis sdu70
replace sdu70 = . if distance>0
rename stdis_1 sds70
replace sds70 = . if distance_1>0

*** 2000 School Districts
gen sdu_st = real(state_1) if distance_2==0
gen sdu_code = real(sd_u) if distance_2==0
gen sdu_name=name if distance_2==0
gen sdu_area=area if distance_2==0
** Only keep the inner part of Wilmington, DE for the city, rename the rest to 88888
replace sdu_code = 88888 if sdu_st==10 & sdu_code==200 & sdu_area>160000000
gen sds_st = real(state_2) if distance_3==0
gen sds_code = real(sd_s) if distance_3==0
gen sds_name = name_1 if distance_3==0

rename distance_4 cbd_dis
rename first_name cbd_name
gen cbd_state = real(first_stat)
rename x_coord_1 x_cbd
rename y_coord_1 y_cbd 

rename distance_5 tr70_dis


********** Combine, Assign MSAs and Select Sample *************

append using t80.dta
append using t70.dta
append using t60.dta

keep areakey year tract_area tr70_dis x_coord y_coord *cbd* sdu* sds*

gen statefips = real(substr(areakey,1,2))
gen cntyfips = real(substr(areakey,3,3))
gen tract = real(substr(areakey,6,.))/100
gen double geoxx = statefips*1000000000+cntyfips*1000000
replace geoxx = geoxx+real(substr(areakey,6,.))
replace geoxx = int(geoxx)
replace geoxx = . if year==1960
format geoxx %17.0f

*** Assign MSAs and only keep areas within MSAs and observed CCs
do ../data/xwalk/msa-code.do
** Fix Worcester County, MA
replace msa = 9240 if statefips==25 & cntyfips==27
drop statefips cntyfips
drop if msa==-9

*** Make sure that all tracts in each MSA use the same CBD
egen mname = mode(cbd_name), by(msa)
egen mst = mode(cbd_state), by(msa)
egen mxcbd = mode(x_cbd), by(msa)
egen mycbd = mode(y_cbd), by(msa)
gen bad = 0
replace bad = 1 if cbd_name~=mname 
replace cbd_name = mname if bad==1
replace cbd_state = mst if bad==1
replace x_cbd = mxcbd if bad==1
replace y_cbd = mycbd if bad==1
replace cbd_dis = sqrt((x_coord-x_cbd)^2+(y_coord-y_cbd)^2) if bad==1
drop bad

/** Flag tracts with bad spatial locations:
A bunch of tracts are placed in the Pacific Ocean.
These are "crews of vessels" with no meaningful spatial
location information and thus should not be included in central
district counts as they do not match up spatially over time.
These locations are added back into metro areas at the end of
this do-file along with other regions not tracted in 1970**/
tab year if x_coord<-2000000 & y_coord>1350000
gen cv = (x_coord<-2000000 & y_coord>1350000)


************** Label Variables *******************

label variable x_coord "x-coordinate of tract centroid"
label variable y_coord "y-coordinate of tract centroid"
label variable x_cbd "x-coordinate of CBD"
label variable y_cbd "y-coordinate of CBD"
label variable cbd_dis "Distance to nearest 1960 CBD"
label variable cbd_name "Name of nearest 1960 CBD"
label variable cbd_state "State of nearest 1960 CBD"
label variable sdu_st "Unified school district in 2000 - statefips"
label variable sdu_code "Unified school district in 2000 - code"
label variable sdu_name "Unified school district in 2000 - name"
label variable sds_st "Secondary school district in 2000 - statefips"
label variable sds_code "Secondary school district in 2000 - code"
label variable sds_name "Secondary school district in 2000 - name"
label variable sdu70 "Unified school district, 1970"
label variable sds70 "Secondary school district, 1970"
label variable tr70_dis "Distance to 1970 tracted area"
label variable tract_area "Tract area"
label variable cv "crews of vessels tract"

compress
save panel-seggis-all.dta, replace

erase t60.dta
erase t70.dta
erase t80.dta

log close

