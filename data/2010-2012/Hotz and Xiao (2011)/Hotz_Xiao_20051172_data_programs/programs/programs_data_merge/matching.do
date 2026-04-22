clear all
set mem 500m
set more off
local pathpgs    "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathdemog  "/rdcprojects/la00296/data/outside/"
local pathreg    "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars    "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"
*global J = 1	/* full version. Takes about 3 to 4 hours to run */
global J = 38	/* fast version. Takes about 20 minutes to run */

capture log close
log using `pathpgs'matching.log , replace

**********

* To send the stata job in batch mode type ...
* nohup stata -b do /rdcprojects/la00296/programs/matching.do

* Here I use STATA string functions to put the data ready to be merged
* everything in lower cases, splits, extractions, concatenations, renaming ..etc
* The same should is done in the naeyc data before merging
 
*		master data: census
* 		using data : naey
*                                 _merge==1    obs. from master data                      
*                                 _merge==2    obs. from using data                       
*                                 _merge==3    obs. from both master and using data    
*
*
*		-1. 9 digit zipcode
*		 0. POBOX
*		 1. address
*		 2. address2	
*		 3. name1212
*		 4. name2121
*		 5. name1221
*		 6. name2112
*		 7. state & address
*	 	 8. state & address2
*		 9. state & name1212
*		10. state & name2121
*		11. state & name1221
*		12. state & name2112	

* Drop suspected duplicate records in census data

use `pathcensus'concat.dta, clear
capture drop joenumber
by cfn year, sort : gen joenumber = _n
drop if joenumber>1 & joenumber !=.
saveold `pathcensus'concat.dta, replace
gen jnumber = _n
sort stgeo msa ctygeo cfn year jnumber
gen census_rec=_n
keep  census_rec
sort census_rec
saveold `pathcensus'census_notmatched.dta, replace


clear
insheet using `pathnaeyc'naeyc_clean_orig.csv , comma

rename zip zip_hyphen
replace zip_hyphen=lower(zip_hyphen)
split zip_hyphen, parse(-) gen(stub)
*gen zip_nohyphen =subinstr(zip_hyphen,"-","",.)
gen zip9_flag    =match(zip_hyphen,"*-*")
gen str_zip9     =stub1+stub2 if zip9_flag==1
destring str_zip9, generate(zip9) ignore("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z")
gen zip5= real(stub1)
rename zip5 zip
drop stub1 stub2

by name1 address1 init_accredit, sort: gen monumber=_n if name1!="" & address1!="" & init_accredit!=""
drop if monumber!=. & monumber>1

qui do `pathpgs'accredstatus.do
global denom = _N

sort naeyc_id
saveold `pathnaeyc'naeyc_clean_orig.dta , replace
use `pathnaeyc'naeyc_clean_orig.dta , clear

keep naeyc_id
sort naeyc_id
saveold `pathnaeyc'naeyc_notmatched.dta, replace

do `pathpgs'by9digitzip.do
do `pathpgs'bypobox1.do
do `pathpgs'bypobox2.do
do `pathpgs'byaddress1.do
do `pathpgs'byaddress2.do

do `pathpgs'byname43.do
*do `pathpgs'byname1212.do
*do `pathpgs'byname2121.do
*do `pathpgs'byname1221.do
*do `pathpgs'byname2112.do
*do `pathpgs'bystateandaddress1.do
*do `pathpgs'bystateandaddress2.do
*do `pathpgs'bystateandname1212.do
*do `pathpgs'bystateandname2121.do
*do `pathpgs'bystateandname1221.do
*do `pathpgs'bystateandname2112.do

do `pathpgs'dropper.do


*  Append all the mergeby datasets into a crosswalk
*  file that links each naeyc_id to a census rec
*  (combination of cfn and year)
****************************************************

use `pathcensus'mergebyzip9, clear
gen contrib_by  = 1
append using `pathcensus'mergebypobox1
replace contrib_by = 2 if contrib_by==.
append using `pathcensus'mergebypobox2
replace contrib_by = 3 if contrib_by==.
append using `pathcensus'mergebyaddress1_4
replace contrib_by = 4 if contrib_by==.
append using `pathcensus'mergebyaddress2_4
replace contrib_by = 5 if contrib_by==.
append using `pathcensus'mergebyname43
replace contrib_by = 6 if contrib_by==.

*append using `pathcensus'mergebyname1212_6
*replace contrib_by = 6 if contrib_by==.
*append using `pathcensus'mergebyname2121_6
*replace contrib_by = 7 if contrib_by==.
*append using `pathcensus'mergebyname1221_6
*replace contrib_by = 8 if contrib_by==.
*append using `pathcensus'mergebyname2112_6
*replace contrib_by = 9 if contrib_by==.
*append using `pathcensus'mergebyaddress1andstate_3
*append using `pathcensus'mergebyaddress2andstate_3
*append using `pathcensus'mergebyname1212andstate_3
*append using `pathcensus'mergebyname2121andstate_3
*append using `pathcensus'mergebyname1221andstate_3
*append using `pathcensus'mergebyname2112andstate_3

***

forvalues k=5/41 {
append using `pathcensus'mergebyaddress1_`k'
replace contrib_by = `k'+2 if contrib_by==.
append using `pathcensus'mergebyaddress2_`k'
replace contrib_by = `k'+2.5 if contrib_by==.
		 }
*local h=`k'+2
*append using `pathcensus'mergebyname1212_`h'
*replace contrib_by = `k'+5.6 if contrib_by==.
*append using `pathcensus'mergebyname2121_`k'
*replace contrib_by = `k'+5.7 if contrib_by==.
*append using `pathcensus'mergebyname1221_`k'
*replace contrib_by = `k'+5.8 if contrib_by==.
*append using `pathcensus'mergebyname2112_`k'
*replace contrib_by = `k'+5.9 if contrib_by==.

****


*append using `pathcensus'mergebyaddress1andstate_`k'
*append using `pathcensus'mergebyaddress2andstate_`k'
*append using `pathcensus'mergebyname1212andstate_`k'
*append using `pathcensus'mergebyname2121andstate_`k'
*append using `pathcensus'mergebyname1221andstate_`k'
*append using `pathcensus'mergebyname2112andstate_`k'

* Drops low quality lowest quality matches when multiple naeyc_ids are matched to the same census_rec

sort census_rec contrib_by
egen highestq=min(contrib_by) , by(census_rec)
keep if highestq==contrib_by
by census_rec, sort: gen moandjuan=_n
keep if moandjuan==1
noi saveold `pathcensus'crosswalk, replace


noi di
noi di "Merging Census & NAEYC datasets through the crosswalk...."
noi di
clear
set mem 500m
use `pathnaeyc'naeyc_clean_orig.dta, clear
rename name1 naeyc_name1
rename name2 naeyc_name2
rename st naeyc_st
sort naeyc_id
saveold `pathnaeyc'naeyc_data.dta, replace
use `pathcensus'concat.dta, clear
gen census_concat=1
count if census_concat==1
gen jnumber = _n
sort stgeo msa ctygeo cfn year jnumber
gen census_rec = _n
sort census_rec

* Merges census to crosswalk
merge census_rec using `pathcensus'crosswalk.dta
rename _merge merge_census_crosswalk
tab merge_census_crosswalk
* Filling in the panel structure where missing.
* Each NAEYC_id should be linked to all the time series information
* for a given CFN and not just to the time period given by census_rec
egen m_naeyc_id=max(naeyc_id) , by (cfn)
rename naeyc_id naeyc_id_match
drop naeyc_id_match
rename m_naeyc_id naeyc_id
sort naeyc_id
merge naeyc_id using `pathnaeyc'naeyc_data.dta
rename _merge merge_census_naeyc
tab merge_census_naeyc
count if census_concat==1
saveold `pathcensus'census_naeyc.dta, replace
noi di "Done !"
noi di
noi di


noi di "Merging Census/NAEYC & demographic census datasets by county and assigned year (yeardemocen)"
local pathpgs    "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathdemog  "/rdcprojects/la00296/data/outside/"
local pathreg    "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
use `pathdemog'c2000_clean.dta, clear
gen yeardemocen=2000
gen badzip=match(zipcode,"*X*")
drop if badzip==1
drop badzip
destring zipcode, gen(zip)
drop if zip==.
drop zipcode
rename zip zipcode
append using `pathdemog'c1990_clean.dta
replace yeardemocen=1990 if yeardemocen==.
describe
rename zipcode num_zip5
by num_zip5  yeardemocen, sort: gen bertrand=_n
keep if bertrand==1
sort num_zip5 yeardemocen
saveold `pathdemog'demog_appended, replace
use `pathcensus'census_naeyc.dta, clear
gen yeardemocen=.
replace yeardemocen=1990 if year==1987|year==1992
replace yeardemocen=2000 if year==1997
* Put zip variable ready for match
destring zip5, gen (num_zip5)
count if census_concat==1
sort num_zip5 yeardemocen
merge num_zip5 yeardemocen using `pathdemog'demog_appended.dta
rename _merge merge_census_naeyc_demog
tab merge_census_naeyc_demog
count if census_concat==1
saveold `pathcensus'census_naeyc_demog.dta, replace
noi di "Done !"
noi di
noi di




noi di "Merging Census/NAEYC/Demographics & Regulation datasets by STATE and year"
noi di
use `pathreg'reg.dta, clear
forvalues y=83/96 {
replace year=19`y' if year==`y'
		  }
replace year=1997 if year==1996
keep if year==1987|year==1992|year==1997
gen st = state
drop if st=="CWLA"
do `pathpgs'numstate.do
drop st
tab numstate
sort numstate year
saveold `pathreg'regulation.dta, replace
use `pathcensus'census_naeyc_demog.dta, clear
* Put state variable ready for match
destring stgeo, gen(numstate)
tab numstate
sort numstate year
merge numstate year using `pathreg'regulation.dta
rename _merge fullmerge
tab fullmerge
count if census_concat==1
saveold `pathcensus'fully_merged.dta, replace
noi di "Done !"
noi di
noi di

use `pathcensus'fully_merged.dta, clear
describe
su
**********
log close
