set more off
clear
use "$dtapath/Tables/Appendix_Table15.dta", clear

local Xcontrols1  = "i.year i.fe_group"
local Xcontrols2  = "bartik i.year i.fe_group"
local Xcontrols3  = "dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols4  = "d_keep_itc_state i.year i.fe_group"
local Xcontrols5  = "d_corp_ext i.year i.fe_group"
local Xcontrols6  = "bartik d_keep_itc_state dtotalexpenditure_pop  d_corp_ext  i.year i.fe_group"


xi: reg dest_nets d_keeprate `Xcontrols1' [aw=epop], cluster(fips_state) r
outreg2 using Appendix_Table15, label tex(frag) replace ctitle($ \beta^E $) bdec(2) sdec(2) drop(_I* o.*)

forv spec=2/6{
xi: reg dest_nets d_keeprate `Xcontrols`spec'' [aw=epop], cluster(fips_state) r
outreg2 using Appendix_Table15, label tex(frag) append ctitle($ \beta^E $) bdec(2) sdec(2) drop(_I* o.*)
}

