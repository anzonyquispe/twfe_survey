*********************************************************************************
* This program extracts the family weight variables from the NBER's SIPP files. *
* http://www.nber.org/data/sipp.html                                            *
*********************************************************************************

clear
set more off
set mem 2g

foreach yy in 96 01 04 08 {

local cc "20"
if `yy'==96 local cc "19"

local nwaves 12
if `yy'==01 local nwaves 9
if `yy'==08 local nwaves 4

forv x=1/`nwaves' {
 !gunzip /data/sipp/`cc'`yy'/sipp`yy'w`x'.dta.gz
 use spanel ssuid eentaid epppnum lgtmon swave wffinwgt using /data/sipp/`cc'`yy'/sipp`yy'w`x'.dta
 !gzip /data/sipp/`cc'`yy'/sipp`yy'w`x'.dta
 keep if mod(lgtmon,4)==0
 tempfile weights`yy'w`x'
 save `weights`yy'w`x''
}

use `weights`yy'w1'
forv x=2/`nwaves' {
append using `weights`yy'w`x''
}
ren ssuid su_id
ren eentaid pp_entry
ren epppnum pp_pnum 
ren swave wave

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

sort spanel su_id pp_entry pp_pnum wave
tempfile weights`yy'
save sipp_weights`yy', replace

}


use panel su_id pp_entry pp_pnum f4_wgt f8_wgt f12_wgt f16_wgt f20_wgt f24_wgt f28_wgt f32_wgt f36_wgt ///
                                 fwgt4 fwgt8 fwgt12 fwgt16 fwgt20 fwgt24 fwgt28 fwgt32 fwgt36 ///
								 using ~/home/sipp/weights
forv mon = 4(4)36 {
gen wffinwgt`mon' = .
replace wffinwgt`mon' = f`mon'_wgt if f`mon'_wgt~=. & wffinwgt`mon'==.
replace wffinwgt`mon' = fwgt`mon' if fwgt`mon'~=. & wffinwgt`mon'==.
drop f`mon'_wgt fwgt`mon'
}
ren panel spanel
reshape long wffinwgt, i(spanel su_id pp_entry pp_pnum) j(lgtmon)
gen wave = lgtmon/4
drop lgtmon
sort spanel su_id pp_entry pp_pnum wave
tempfile weights8693
save `weights8693'

foreach yy in 96 01 04 08 {
append using sipp_weights`yy'
}
sort spanel su_id pp_entry pp_pnum wave
save rep_sipp_weights.dta, replace
exit