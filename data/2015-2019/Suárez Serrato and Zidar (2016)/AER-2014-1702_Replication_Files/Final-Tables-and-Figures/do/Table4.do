clear
set more off

use "$dtapath/Tables/Table4.dta", clear
cd "$tablepath"

*RHS Variables*

local Xcontrols1  = "i.year i.fe_group"
local Xcontrols2  = "bartik i.year i.fe_group"
local Xcontrols3  = "dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols4  = "d_keep_itc_state i.year i.fe_group"
local Xcontrols5  = "d_corp_ext i.year i.fe_group"
local Xcontrols6  = "bartik d_keep_itc_state dtotalexpenditure_pop  d_corp_ext  i.year i.fe_group"

*********************************************************
* PANEL A (Table 4A)
*********************************************************

xi: reg E d_keeprate `Xcontrols1' [aw=epop], cluster(fips_state) r
outreg2 using Table4A, label tex(frag) replace ctitle($ \beta^E $) bdec(2) sdec(2) drop(_I*)

forv spec=2/6{
xi: reg E d_keeprate `Xcontrols`spec'' [aw=epop], cluster(fips_state) r
outreg2 using Table4A, label tex(frag) append ctitle($ \beta^E $) bdec(2) sdec(2) drop(_I*)
}

*********************************************************
* PANEL B (Table 4B
*********************************************************

xi: reg N d_keeprate `Xcontrols1' [aw=epop], cluster(fips_state) r
outreg2 using Table4B, label tex(frag) replace ctitle($ \beta^N $) bdec(2) sdec(2) drop(_I*)

xi: reg N d_keeprate `Xcontrols2' [aw=epop], cluster(fips_state) r
outreg2 using Table4B, label tex(frag) append ctitle($ \beta^N $) bdec(2) sdec(2) drop(_I*)

xi: reg W d_keeprate `Xcontrols1' [aw=epop], cluster(fips_state) r
outreg2 using Table4B, label tex(frag) append ctitle($ \beta^W $) bdec(2) sdec(2) drop(_I*)

xi: reg W d_keeprate `Xcontrols2' [aw=epop], cluster(fips_state) r
outreg2 using Table4B, label tex(frag) append ctitle($ \beta^W $) bdec(2) sdec(2) drop(_I*)

xi: reg R d_keeprate `Xcontrols1' [aw=epop], cluster(fips_state) r
outreg2 using Table4B, label tex(frag) append ctitle($ \beta^R $) bdec(2) sdec(2) drop(_I*)

xi: reg R d_keeprate `Xcontrols2' [aw=epop], cluster(fips_state) r
outreg2 using Table4B, label tex(frag) append ctitle($ \beta^R $) bdec(2) sdec(2) drop(_I*)
