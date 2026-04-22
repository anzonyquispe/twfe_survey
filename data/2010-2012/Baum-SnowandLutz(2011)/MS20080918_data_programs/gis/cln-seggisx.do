/**
cln-seggisx.do

This do-file cleans the GIS data in this directory.
Each file is all the census tracts from each year 
spatially joined to the following layers in the following order:

The tracts in 60,70,80 and 90 are only those that overlap in 
geography with tracts as of 1970.  Therefore, there are some
tracts in 1980 and 1990 that are missing in the input data sets
tr80_joins.dta and tr90_joins.dta.  We incorporate these mostly
suburban tracts at the very end, built using cln-seggis-all.do.`

1. Unified school districts in 1970
2. Secondary school districts in 1970 
3. Unified school districts in 2000
4. Secondary school districs in 2000
5. CBDs

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
log using cln-seggisx.log, replace text


****************** 1960 ************************

use tr60_joins.dta
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

save t60.dta, replace


******************* 1970 *************************

use tr70_joins.dta,clear
gen year = 1970

/****** List all tracts without a school district:  These fall
in districts of fewer than 300 students and thus are not 
identified in the 70 geographic reference file            *******/ 
tab state if distance>0 & distance_1>0 & state~=24 
tab state if distance_2>0 & distance_3>0 

*** 1970 Districts
rename stdis sdu70
replace sdu70 = . if distance>0
rename stdis_1 sds70
replace sds70 = . if distance_1>0

*** One tract has bad areakey
replace areakey = "48245001400" if areakey==""

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

save t70.dta, replace


****************** 1980 ************************

use trclp80_areas.dta
sort areakey
save trclp80_areas.dta, replace

use tr80_joins.dta, clear
gen year = 1980

sort areakey
merge areakey using trclp80_areas.dta
tab _merge
drop _merge

*** Clipping created one tract listed twice 
drop if areakey=="55139000900" & fid_1==862

*** 1970 School Districts
rename stdis sdu70
replace sdu70 = . if distance>0
rename stdis_1 sds70
replace sds70 = . if distance_1>0

*** One tract was missing in the 70 relationship file -- fix 
replace sdu70 = 4809660 if areakey=="48245001400"

*** 2000 School Districts
gen sdu_st = real(state_1) if distance_2==0
gen sdu_code = real(sd_u) if distance_2==0
gen sdu_name=name if distance_2==0
gen sdu_area=area if distance_2==0
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

save t80.dta, replace


********************* 1990 ***********************

use trclp90_areas.dta
sort gisjoin2
save trclp90_areas.dta, replace
 
use tr90_joins.dta, clear
gen year = 1990

sort gisjoin2
merge gisjoin2 using trclp90_areas.dta
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


********** Combine, Assign MSAs and Select Sample *************

append using t80.dta
append using t70.dta
append using t60.dta

keep areakey year x_coord y_coord *cbd* sdu* sds* tract_area

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

/** Drop tracts with bad spatial locations:
In 1970, a bunch of tracts are placed in the Pacific Ocean. 
These are "crews of vessels" with no meaningful spatial
location information and thus should not be included in central
district counts as they do not match up spatially over time.
These locations are added back into metro areas at the end of
this do-file along with other regions not tracted in 1970**/
tab year if x_coord<-2000000 & y_coord>1350000
drop if x_coord<-2000000 & y_coord>1350000


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
label variable tract_area "Area of tract polygon"

*** Append on full version of the tract data set
gen samp00 = 0
append using panel-seggis-all.dta
replace samp00 = 1 if samp00==.
tab year samp00

sort areakey year samp00
by areakey year: replace tr70_dis = tr70_dis[2]
*** Determine Which tracts to keep -- clipped (70 geog) or non-clipped (00 geog)
gen keepobs = samp00
/*** In 1960 and 1970, there are no ex-1970 tracted regions to worry about so always use
the clipped tract centroids if the original centroids are not in a tracted location ***/
by areakey year: replace keepobs = 1-keepobs if tr70_dis>0 & year<=1970 & _N==2
/*** Use clipped tract centroid if at least 10% of unclipped tract area and unclipped
centroid is not in the 70 tracted area -- usually b/c of different coast delineations ***/
egen areaclip = max(tract_area*(1-samp00)), by(areakey year)
egen areaall = max(tract_area*samp00), by(areakey year)
by areakey year: replace keepobs = 1-keepobs if areaclip/areaall>0.10 & year>1970 & _N==2 & tr70_dis>0

by areakey year: replace keepobs=1 if _N==1
keep if keepobs==1
replace cv = 0 if cv==.

drop keepobs areaclip areaall sdu_area

tab year

compress
save panel-seggisx.dta, replace

erase t60.dta
erase t70.dta
erase t80.dta

log close

