/*** sub_districts.do

This do-file generates measures of suburban contact
for whites with other whites in public schools 
based on 1970 districts.

These results are reported in Section 2.3

***/


clear
set more off
set mem 500m

set matsize 2000

capture log close
log using sub_districts2.log, replace text

************ 1.  Establish Sample  **********************

use ../data/dis70panx.dta
keep if major==1
drop if imp==.
replace imp = imp+1900
keep msa year imp south area marea
compress
sort msa year
save temp3.dta, replace

use ../data/tractpanx.dta

** Drop tract area
drop area

** Drop tracts for which we don't know location
drop if cbd_dis==999999

** Put cbd-dis in KM
replace cbd_dis = cbd_dis/1000
sort msa year
merge msa year using temp3.dta
tab _merge
** Merge=1 is MSAs without major plans, Merge=2 is untracted MSA/years
keep if _merge==3
drop _merge

*** Fix data a bit and set sample
drop if black+white+other==0

keep if ccdis70==0

*** Define pop variable 
gen pop = white+black

keep if year==1970

********** 3. Create Additional Variables ******************

replace publicelemhsw = publicelemw+publichsw if year~=1990
replace publicelemhsb = publicelemb+publichsb if year~=1990
replace privatelemhsw = privatelemw+privatehsw if year~=1990
replace privatelemhsb = privatelemb+privatehsb if year~=1990

replace publicelemhsb = 0 if publicelemhsb==. & pop59b+pop1014b+pop1519b==0
replace publicelemhsb = 0 if publicelemhsb==. & black==0
replace privatelemhsb = 0 if privatelemhsb==. & pop59b+pop1014b+pop1519b==0
replace privatelemhsb = 0 if privatelemhsb==. & black==0
replace publicelemhsw = 0 if publicelemhsw==. & pop59w+pop1014w+pop1519w==0
replace publicelemhsw = 0 if publicelemhsw==. & white==0
replace privatelemhsw = 0 if privatelemhsw==. & pop59w+pop1014w+pop1519w==0
replace privatelemhsw = 0 if privatelemhsw==. & white==0

*** Restrict sample to tracts with data for both whites and blacks
drop if publicelemhsw==.|publicelemhsb==.

sort msa sdu70 sds70
collapse (sum) publicelemhsw publicelemhsb, by(msa year south sdu70 sds70)

*** Drop districts so small we don't observe their codes (usually multiple districts)
drop if sdu70==. & sds70==.

*** Fraction of District that is white
gen exposw2b = publicelemhsb/(publicelemhsw+publicelemhsb)
sum exposw2b, detail

gen exposb2w = 1-exposw2b

*** Dummy for Exposure < .1
gen D = (exposw2b<.1)

gen N = 1

*** Drop districts with 0 students as not an option
drop if publicelemhsw==0 & publicelemhsb==0

save temp.dta, replace

collapse (rawsum) sumD=D N publicelemhsw publicelemhsb (mean) mnD=D exposw2b [aw=publicelemhsw], by(msa year south)

gen frdis = sumD/N

*** Fraction of suburban districts >90% White
sum frdis, detail
sum frdis if south==0, detail
sum frdis if south==1, detail
*** Expected Probability a White Public Student in a >90% White District
sum mnD, detail
sum mnD if south==0, detail
sum mnD if south==1, detail
*** Average Fraction White across White Public Students
sum exposw2b, detail
sum exposw2b if south==0, detail
sum exposw2b if south==1, detail

drop public*

sort msa year
save sub70.dta, replace

use temp.dta, clear

collapse (mean) exposb2w [aw=publicelemhsb], by(msa year south)

sort msa year
merge msa year using sub70.dta
tab _merge
replace exposb2w = 0 if _merge==2
drop _merge

sort msa year
merge msa year using ../data/dis70panx.dta
tab _merge
keep if _merge==3

gen CCexposw2b = (publicelemb+publichsb)/(publicelemw+publichsw+publicelemb+publichsb)

*** City - Suburban Exposure of whites to blacks
gen Dexposw2b = CCexposw2b-exposw2b
sum Dexposw2b, detail
sum Dexposw2b if south==0, detail
sum Dexposw2b if south==1, detail
l mname exposw2b CCexposw2b if Dexposw2b<0

*** City - Suburban exposure of blacks to whites
gen Dexposb2w = (1-CCexposw2b)-exposb2w
sum Dexposb2w, detail
sum Dexposb2w if south==0, detail
sum Dexposb2w if south==1, detail
gen CCexposb2w = 1-CCexposw2b
l mname exposb2w CCexposb2w if Dexposb2w>0


erase temp.dta
erase temp3.dta
erase sub70.dta

