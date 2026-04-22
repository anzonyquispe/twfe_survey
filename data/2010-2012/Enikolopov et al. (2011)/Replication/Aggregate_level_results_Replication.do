set more off
cd "/Users/mac/Dropbox/Work\NTV\Data\Replication\"
use NTV_Aggregate_Data.dta, clear

global socioec="population98_*   wage1998_* Gorod  doctors_pc1998 nurses1998    "
global basic="pension98 wage98_ln logpop98 retired98 unempl98  pop_change98 "

global vote95="Votes_NDR_1995 Votes_DVR_1995 Votes_Yabloko_1995 Votes_KPRF_1995 Votes_LDPR_1995 Turnout1995"
global  vote99="Votes_Edinstvo_1999 Votes_OVR_1999 Votes_SPS_1999  Votes_Yabloko_1999  Votes_KPRF_1999  Votes_LDPR_1999  Turnout1999"
global  vote03="Votes_Edinstvo_2003   Votes_SPS_2003 Votes_Yabloko_2003 Votes_KPRF_2003  Votes_LDPR_2003  Turnout_2003 "

forvalues x=2/5 {
g  tvmaxtveloss5050powerA`x'=tvmaxtveloss5050powerA^`x'
g  tvmaxtvflosspowerA`x'=tvmaxtvflosspowerA^`x'
}

forvalues x=1/5 {
g population98_`x'=population1998^`x'
g population96_`x'=population1996^`x'
g wage1998_`x'=wage98^`x'
g wage1996_`x'=wage96^`x'
}
xi i.region


local cond="if region!=5 & region!=6 "
qui areg Votes_Edinstvo_1999   Watch_OLS  $socioec `cond', absorb(region) robust 
capture drop Sample
gen Sample=e(sample)

 *summary statistics


gen wage98s=wage98*1000
gen pension98s=pension98*1000

egen samp=rownonmiss(population1998 pop_change98 migr98  wage98 pension98 retired98 unempl98  farmers98 crime_rate98    $vote99 )
sum Watch_probit if samp>0, d
gen NTV_High1999=(Watch_probit>r(p50)) if Watch_probit!=.

*Summary statistics (TABLE A2)
tabstat  population1998 pop_change98 migr98  wage98s pension98s retired98 unempl98  farmers98 crime_rate98  , statistics (mean sd count) columns (statistics)
codebook  $socioec ,c
tabstat population1998  pop_change98 migr98 wage98s  pension98s retired98 unempl98  farmers98 crime_rate98 , statistics (mean sd count) columns (statistics) by (NTV_High1999)
local opt="replace"
foreach var in logpop98 pop_change98 migr98 pension98s  wage98s retired98 unempl98  farmers98 crime_rate98 {
	quietly reg `var' NTV_High1999 if samp>0, robust
	outreg2 using "AggregateSummarybyNTV.xls",  bdec(3) tdec(3) bracket p  `opt'
	local opt="append"
}




quietly tabstat $vote95 , statistics (mean sd count) columns (statistics)
quietly codebook $vote95 ,c
tabstat $vote95 , statistics (mean sd count) columns (statistics) by (NTV_High1999)
foreach var in $vote95 {
	quietly reg `var' NTV_High1999 if samp>0, robust
	outreg2 using "AggregateSummarybyNTV.xls",  bdec(3)  bracket p `opt'
	local opt="append"
}

quietly tabstat $vote99 , statistics (mean sd count) columns (statistics)
codebook $vote99 ,c
tabstat $vote99 , statistics (mean sd count) columns (statistics) by (NTV_High1999)
foreach var in $vote99  {
	quietly reg `var' NTV_High1999 if samp>0, robust
	outreg2 using "AggregateSummarybyNTV.xls",  bdec(3) bracket p `opt'
	local opt="append"
}

quietly tabstat Votes_Edinstvo_2003 Votes_SPS_2003 Votes_Yabloko_2003   Votes_KPRF_2003  Votes_LDPR_2003  Turnout_2003  , statistics (mean sd count) columns (statistics)
codebook  Votes_Edinstvo_2003 Votes_SPS_2003 Votes_Yabloko_2003   Votes_KPRF_2003  Votes_LDPR_2003  Turnout_2003   ,c
tabstat  Votes_Edinstvo_2003 Votes_SPS_2003 Votes_Yabloko_2003   Votes_KPRF_2003  Votes_LDPR_2003  Turnout_2003  , statistics (mean sd count) columns (statistics) by (NTV_High1999)
foreach var in  Votes_Edinstvo_2003 Votes_SPS_2003 Votes_Yabloko_2003   Votes_KPRF_2003  Votes_LDPR_2003  Turnout_2003   {
	quietly reg `var' NTV_High1999 if samp>0, robust
	outreg2 using "AggregateSummarybyNTV.xls",  bdec(3) bracket p `opt'
	local opt="append"
}
*/






****correlates of NTV (TABLE 1)


xi i.region

areg NTV1999 $vote95 , absorb(region) cluster(region)
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0
outreg2 using "correlates_NTV.xls", replace   bdec(4) bracket se addstat("F-statistics, electoral", r(F))


areg NTV1999  population98_1 wage1998_1  Gorod    , absorb(region) cluster(region) 
test population98_1=wage1998_1=Gorod=0
outreg2 using "correlates_NTV.xls", append  bdec(4) bracket se addstat("F-statistics, polynomial", r(F))




areg NTV1999  population98_*   wage1998_* Gorod    , absorb(region) cluster(region) 
test population98_1=population98_2=population98_3=population98_4=population98_5=0
local Fpop=r(F)
test wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=0
local Fwage=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=Gorod=0
outreg2 using "correlates_NTV.xls", append  bdec(4) bracket se addstat("F-statistics, population polynomial", `Fpop', "F-statistics, wage polynomial", `Fwage', "F-statistics, polynomial", r(F))

areg NTV1999  population98_*   wage1998_* Gorod  $vote95  , absorb(region) cluster(region) 
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0
local F1=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=0
local Fpop=r(F)
test wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=0
local Fwage=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=Gorod=0
local F2=r(F)
outreg2 using "correlates_NTV.xls", append  bdec(4) bracket se addstat("F-statistics, electoral", `F1', "F-statistics, population polynomial", `Fpop', "F-statistics, wage polynomial", `Fwage',"F-statistics, polynomial", `F2')


areg NTV1999 $vote95  $socioec pop_change98 migr98    retired98 unempl98  farmers98 crime_rate98 , absorb(region) cluster(region)
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0
local F1=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=Gorod
local F2=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=0
local Fpop=r(F)
test wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=0
local Fwage=r(F)
test crime_rate98=migr98=retired98=unempl98=pop_change98=farmers98=nurses1998=doctors_pc1998=0
outreg2 using "correlates_NTV.xls", append  bdec(4) bracket se addstat("F-statistics, electoral", `F1', "F-statistics, population polynomial", `Fpop', "F-statistics, wage polynomial", `Fwage', "F-statistics, polynomial", `F2', "F-statistic, socioecon", r(F))

areg NTV1999 NTV1997 $vote95  $socioec pop_change98 migr98    retired98 unempl98  farmers98 crime_rate98  , absorb(region) cluster(region)
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0
local F1=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=Gorod
local F2=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=0
local Fpop=r(F)
test wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=0
local Fwage=r(F)
test crime_rate98=migr98=retired98=unempl98=pop_change98=farmers98=nurses1998=doctors_pc1998=0
outreg2 using "correlates_NTV.xls", append  bdec(4) bracket se addstat("F-statistics, population polynomial", `Fpop', "F-statistics, wage polynomial", `Fwage', "F-statistics, electoral", `F1', "F-statistics, polynomial", `F2', "F-statistic, socioecon", r(F))



*********** baseline regressions: vote and NTV (TABLE 2)

local cond="if region!=5 & region!=6 "

local opt="replace"
local clust="cluster(region)"
foreach var in Votes_Edinstvo_1999 Votes_OVR_1999 Votes_SPS_1999 Votes_Yabloko_1999    Votes_KPRF_1999   Votes_LDPR_1999  Turnout1999  {

	areg `var'  Watch_probit     $socioec `cond', absorb(region) robust `clust'
	outreg2 using "``path''baseNTVloss.xls",  bdec(2) bracket se addstat("Number of regions",  e(N_clust)) `opt'

	local opt="append"


	areg `var'  Watch_probit     $socioec $vote95  `cond', absorb(region) robust `clust'
	outreg2 using "``path''baseNTVloss.xls",  bdec(2) bracket se addstat("Number of regions",  e(N_clust)) `opt'

		
}





****************************** placebo regressions: vote 1995 and NTV  (TABLE 4)
local cond="if Sample!=. & Sample!=0"
local opt="replace"
local clust="cluster(region)"
local cond="if Sample==1"

foreach var in  $vote95 {
	areg `var'  Watch_probit  $socioec `cond', absorb(region) robust `clust'
	outreg2 using "``path''Placebo1995loss.xls",  bdec(2) bracket se addstat("Number of regions", e(df_a)+1) `opt'
      local opt="append"



	
}




****************************** placebo regressions: vote 2003  and NTV (TABLE 5)
local cond="if Sample==1"
local opt="replace"
local clust="cluster(region)"
qui:	areg Votes_SPS_2003  Watch_probit  $socioec $vote95 `cond', absorb(region) robust 
gen sample=e(sample) 
local cond="if sample==1"
foreach var in  $vote03 {
	areg `var'  Watch_probit  $socioec $vote95 `cond', absorb(region) robust `clust'
	outreg2 using "``path''Placebo2003loss.xls",  bdec(2) bracket se addstat("Number of regions", e(df_a)+1) `opt'



      local opt="append"


	areg `var' Watch_probit   $socioec `cond', absorb(region) robust `clust'
	outreg2 using "``path''Placebo2003loss.xls",  bdec(2) bracket se addstat("Number of regions", e(df_a)+1) `opt'

	areg `var' Watch_probit    $socioec $vote99  `cond', absorb(region) robust `clust'
	outreg2 using "``path''Placebo2003loss.xls",  bdec(2) bracket se addstat("Number of regions", e(df_a)+1) `opt'

}
drop sample

* Panel data results for years 1995 and 1999 (TABLE 3)


drop if Votes_Edinstvo_1999   ==.
rename  Turnout_2003  Turnout2003
rename logpop98 logpop1999
rename logpop96 logpop1995
rename wage98_ln logwage1999
rename wage96_ln logwage1995

rename Votes_DVR_1995 Votes_SPS_1995
gen Watch_probit_2003=Watch_probit 
gen Watch_probit_1995=0
rename Watch_probit  Watch_probit_1999

reshape long Watch_probit_ Votes_SPS_  Turnout Votes_Yabloko_  Votes_KPRF_ Votes_LDPR_ logpop logwage, i(tik_id)
xi i._j

local opt="replace"
local cond=" if  _j!=2003 "
foreach var of varlist Votes_SPS_ Votes_Yabloko_  Votes_KPRF_ Votes_LDPR_ Turnout {
*logpop logwage
xtreg `var' Watch_probit_  _I* `cond', fe i(tik_id) cluster (tik_id)
outreg2 using "PanelFE.xls",  bdec(2) bracket se  `opt'
local opt="append"
}
 
 
