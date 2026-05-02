******************************************************************************
* Program to create SIPP extract for Aaronson, Agarwal, French Minwage Paper *
* using pre-created stata versions of the NBER SIPP files found at:          *
* http://www.nber.org/data/sipp.html                                         *
******************************************************************************


clear all
set mem 10g 
capture log close

log using sipp_makedata1.log, replace

*****************************
* Format Each Waves Dataset *
*****************************

/* 1986 and 1987  */
foreach yy in 86 87  {
clear
use su_id pp_entry pp_pnum rot hh_add* age* sex rrp* pp_mis* state* ff_inc* ff_pro* pp_inc* pp_ear* ws1_am* ws2_am* w2028* w2128* famtyp* se1_am* se2_am* s2212* s2312* using /data/sipp/19`yy'/sipp`yy'fp.dta

* Rename variables so they are is easier to work with.
foreach var in hh_add rrp age w2028 w2128 ws1_am ws2_am s2212 s2312 pp_ear ff_inc ff_pro pp_inc famtyp pp_mis se1_am se2_am {
 forv x=1/9 {
  capture ren `var'_0`x' `var'_`x'
  if _rc~=0 ren `var'0`x' `var'`x'
 }
}

*Make state variable monthly
forv x=1/32 {
 local y = ceil(`x'/4)   
 gen state`x' = state_`y'    
}
drop state_*

reshape long age_ rrp_ hh_add state pp_mis ff_inc ff_pro pp_inc pp_ear ws1_am ws2_am w2028_ w2128_ famtyp s2212_ s2312_ se1_am se2_am, i(su_id pp_entry pp_pnum) j(lgtmon)

*Drop people who were not interviewed
drop if pp_mis==0 | pp_mis==2  

gen wave = ceil(lgtmon/4)

*Make variable names consistent across panels
ren age_ age
ren rrp_ rrp
ren w2028_ hrrat1
ren w2128_ hrrat2
ren ws1_am ernam1
ren ws2_am ernam2
ren s2212_ se_hr1
ren s2312_ se_hr2
ren se1_am se_am1
ren se2_am se_am2
ren famtyp rfid

* Create Calendar Month Index
*January 1983 = 1
local startmn = 36
if `yy'==87 local startmn = 46
gen calmn = .
forv refmon=1/32 {
 replace calmn = `startmn'+`refmon'-1 if rot==2 & lgtmon==`refmon' 
 replace calmn = `startmn'+`refmon'   if rot==3 & lgtmon==`refmon'
 replace calmn = `startmn'+`refmon'+1 if rot==4 & lgtmon==`refmon'
 replace calmn = `startmn'+`refmon'+2 if rot==1 & lgtmon==`refmon'
}

gen rhcalmn = mod(calmn,12)
replace rhcalmn = 12 if rhcalmn==0
gen rhcalyr = 1983+floor((calmn-1)/12)
    
gen spanel = 19`yy'

sort spanel su_id pp_entry pp_pnum lgtmon
save mw`yy'.dta, replace
clear
}

/* 1988, 1990, 1991, 1992, 1993 */


foreach yy in 88 90 91 92 93 {

local nwaves 8
if `yy'==92 local nwaves 10
if `yy'==93 local nwaves 9
local nmonths = `nwaves'*4

* This is used to generalize variable names for small differences across waves
local e "e"
if `yy'==92 local e ""

clear
use pp_id pp_entry pp_pnum rot age* sex rrp* hh_add* pp_mis* geo_st`e'* ff_inc* ff_pro* pp_inc* pp_ear* hrrat* famnum* se_am* se_hr* ernam* using /data/sipp/19`yy'/sipp`yy'fp.dta
if `yy'==92 renpfix geo_st geo_ste

ren pp_id su_id
renpfix geo_ste state_

* Rename variables so they are easier to work with
local state ""
if `yy'==92 local state "state_"
foreach var in rrp pp_mis age famnum hh_add pp_inc pp_ear ff_inc ff_pro hrrat1 hrrat2 ernam1 ernam2 se_am1 se_am2 se_hr1 se_hr2 `state' {
 forv x=1/9 {
  capture ren `var'_0`x' `var'_`x'
  if _rc~=0 ren `var'0`x' `var'`x'
 }
}

*Make state a monthly variable
forv x=1/`nmonths' {
 local y = ceil(`x'/4)   
 gen state`x' = state_`y'    
}
drop state_*

reshape long age_ rrp_ hh_add state pp_mis ff_inc ff_pro pp_inc pp_ear ernam1 ernam2 hrrat1 hrrat2 famnum se_am1 se_am2 se_hr1 se_hr2, i(su_id pp_entry pp_pnum) j(lgtmon)

//Drop people who were not interviewed
drop if pp_mis==0 | pp_mis==2  

gen wave = ceil(lgtmon/4)

*Make variable names consistent
ren age_ age
ren rrp_ rrp
ren famnum rfid

*Calendar Months
*January 1983 = 1
local startmn = 58
if `yy'==90 local startmn = 82
if `yy'==91 local startmn = 94
if `yy'==92 local startmn = 106
if `yy'==93 local startmn = 118
gen calmn = .
forv refmon=1/`nmonths' {
 replace calmn = `startmn'+`refmon'-1 if rot==2 & lgtmon==`refmon' 
 replace calmn = `startmn'+`refmon'   if rot==3 & lgtmon==`refmon'
 replace calmn = `startmn'+`refmon'+1 if rot==4 & lgtmon==`refmon'
 replace calmn = `startmn'+`refmon'+2 if rot==1 & lgtmon==`refmon'
}

gen rhcalmn = mod(calmn,12)
replace rhcalmn = 12 if rhcalmn==0
gen rhcalyr = 1983+floor((calmn-1)/12)
    
gen spanel = 19`yy'

sort spanel su_id pp_entry pp_pnum lgtmon
save mw`yy'.dta, replace
clear
}

/* 1996, 2001, 2004, 2008 */

foreach yy in 96 01 04 08 {

local cc "20"
if `yy'==96 local cc "19"

local nwaves 12
if `yy'==01 local nwaves 9
if `yy'==08 local nwaves 4

clear
forv x=1/`nwaves' {
 !gunzip /data/sipp/`cc'`yy'/sipp`yy'w`x'.dta.gz
 use spanel ssuid eentaid epppnum shhadid srot tage esex errp eppintvw tfipsst tftotinc tfprpinc tptotinc tpearn tpmsum* tpyrate* rfid tbmsum* ehrsbs* lgtmon rhcalmn rhcalyr using /data/sipp/`cc'`yy'/sipp`yy'w`x'.dta 
 !gzip /data/sipp/`cc'`yy'/sipp`yy'w`x'.dta
 
 gen wave  = `x'
 
 *Make variable names consistent
 ren ssuid su_id
 ren eentaid pp_entry
 ren epppnum pp_pnum
 ren shhadid hh_add
 ren srot rot
 ren tage age
 ren esex sex
 ren errp rrp
 ren tfipsst state
 ren tftotinc ff_inc
 ren tfprpinc ff_pro
 ren tptotinc pp_inc
 ren tpearn pp_ear
 ren tpyrate1 hrrat1
 ren tpyrate2 hrrat2
 ren tpmsum1 ernam1
 ren tpmsum2 ernam2 
 ren tbmsum1 se_am1
 ren tbmsum2 se_am2
 ren ehrsbs1 se_hr1
 ren ehrsbs2 se_hr2
 sort spanel su_id pp_entry pp_pnum lgtmon
 tempfile mw`yy'w`x'
 save `mw`yy'w`x''
} 
use `mw`yy'w1'
forv x=2/`nwaves' {
 append using `mw`yy'w`x''
}

*Drop if not interviewed
drop if eppintvw==3 | eppintvw==4

gen _su_id = string(su_id,"%12.0f")
drop su_id
ren _su_id su_id

local entry 2
local num 3
if `yy'==96 | `yy'==04 local entry 3
if `yy'==96 | `yy'==04 local num 4
gen _pp_entry = string(pp_entry,"%`entry'.0f")
drop pp_entry
ren _pp_entry pp_entry

gen _pp_pnum = string(pp_pnum,"%`num'.0f")
drop pp_pnum
ren _pp_pnum pp_pnum

tostring hh_add, replace

sort spanel su_id pp_entry pp_pnum lgtmon
save mw`yy'.dta, replace
}


********************
* Combine Datasets *
********************
clear
set mem 8g
use mw86.dta
foreach year in 87 88 90 91 92 93 96 01 04 08 {
 append using mw`year'
}

tab spanel

ren rhcalmn month
ren rhcalyr year

sort spanel su_id pp_entry pp_pnum year month
save rep_sipp1.dta, replace


log close

exit