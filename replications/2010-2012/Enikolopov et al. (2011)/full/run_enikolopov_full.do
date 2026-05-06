* =============================================================================
* Enikolopov, Petrova & Zhuravskaya (2011)
* Media and Political Persuasion: Evidence from Russia
* AER, 101(7), 3253-3285
* FULL REPLICATION: Aggregate + Individual level results
* =============================================================================

clear all
set more off
set maxvar 10000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Enikolopov et al. (2011)/Replication"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Enikolopov et al. (2011)/full"

cap which outreg2
if _rc ssc install outreg2, replace

cd "$datadir"

log using "$outdir/run_enikolopov_full.log", text replace

* =============================================================================
* PART 1: AGGREGATE LEVEL RESULTS
* =============================================================================
di _n "=========================================================="
di _n "PART 1: AGGREGATE LEVEL RESULTS"
di _n "=========================================================="

use "NTV_Aggregate_Data.dta", clear

* ---- Globals exactly as in original ----
global socioec "population98_* wage1998_* Gorod doctors_pc1998 nurses1998"
global basic "pension98 wage98_ln logpop98 retired98 unempl98 pop_change98"
global vote95 "Votes_NDR_1995 Votes_DVR_1995 Votes_Yabloko_1995 Votes_KPRF_1995 Votes_LDPR_1995 Turnout1995"
global vote99 "Votes_Edinstvo_1999 Votes_OVR_1999 Votes_SPS_1999 Votes_Yabloko_1999 Votes_KPRF_1999 Votes_LDPR_1999 Turnout1999"
global vote03 "Votes_Edinstvo_2003 Votes_SPS_2003 Votes_Yabloko_2003 Votes_KPRF_2003 Votes_LDPR_2003 Turnout_2003"

* ---- Create polynomial variables exactly as original ----
forvalues x=2/5 {
    cap noi gen tvmaxtveloss5050powerA`x' = tvmaxtveloss5050powerA^`x'
    cap noi gen tvmaxtvflosspowerA`x' = tvmaxtvflosspowerA^`x'
}

forvalues x=1/5 {
    cap noi gen population98_`x' = population1998^`x'
    cap noi gen population96_`x' = population1996^`x'
    cap noi gen wage1998_`x' = wage98^`x'
    cap noi gen wage1996_`x' = wage96^`x'
}

xi i.region

* ---- Define sample ----
local cond "if region!=5 & region!=6"
qui areg Votes_Edinstvo_1999 Watch_OLS $socioec `cond', absorb(region) robust
cap drop Sample
gen Sample = e(sample)

* ---- Summary stats ----
gen wage98s = wage98*1000
gen pension98s = pension98*1000

egen samp = rownonmiss(population1998 pop_change98 migr98 wage98 pension98 retired98 unempl98 farmers98 crime_rate98 $vote99)
sum Watch_probit if samp>0, d
gen NTV_High1999 = (Watch_probit>r(p50)) if Watch_probit!=.

* =============================================================================
* TABLE 1: Correlates of NTV (from original, referenced as "TABLE 1")
* =============================================================================
di _n "===== TABLE 1: Correlates of NTV ====="

xi i.region

di _n "--- Col 1: Vote 95 only ---"
areg NTV1999 $vote95, absorb(region) cluster(region)
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0

di _n "--- Col 2: Pop+wage linear ---"
areg NTV1999 population98_1 wage1998_1 Gorod, absorb(region) cluster(region)
test population98_1=wage1998_1=Gorod=0

di _n "--- Col 3: Pop+wage polynomials ---"
areg NTV1999 population98_* wage1998_* Gorod, absorb(region) cluster(region)
test population98_1=population98_2=population98_3=population98_4=population98_5=0
local Fpop=r(F)
test wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=0
local Fwage=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=Gorod=0

di _n "--- Col 4: Polynomials + vote95 ---"
areg NTV1999 population98_* wage1998_* Gorod $vote95, absorb(region) cluster(region)
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0
local F1=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=0
local Fpop=r(F)
test wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=0
local Fwage=r(F)

di _n "--- Col 5: Full controls ---"
areg NTV1999 $vote95 $socioec pop_change98 migr98 retired98 unempl98 farmers98 crime_rate98, absorb(region) cluster(region)
test Votes_KPRF_1995=Votes_LDPR_1995=Votes_NDR_1995=Votes_Yabloko_1995=Votes_DVR_1995=Turnout1995=0
local F1=r(F)
test population98_1=population98_2=population98_3=population98_4=population98_5=wage1998_1=wage1998_2=wage1998_3=wage1998_4=wage1998_5=Gorod
local F2=r(F)

di _n "--- Col 6: With NTV1997 ---"
areg NTV1999 NTV1997 $vote95 $socioec pop_change98 migr98 retired98 unempl98 farmers98 crime_rate98, absorb(region) cluster(region)

* =============================================================================
* TABLE 2: Baseline - NTV on 1999 vote shares
* =============================================================================
di _n "===== TABLE 2: NTV on 1999 Vote Shares ====="

local cond "if region!=5 & region!=6"
local clust "cluster(region)"
foreach var in Votes_Edinstvo_1999 Votes_OVR_1999 Votes_SPS_1999 Votes_Yabloko_1999 Votes_KPRF_1999 Votes_LDPR_1999 Turnout1999 {
    di _n "--- `var' without vote95 ---"
    areg `var' Watch_probit $socioec `cond', absorb(region) robust `clust'

    di _n "--- `var' with vote95 ---"
    areg `var' Watch_probit $socioec $vote95 `cond', absorb(region) robust `clust'
}

* =============================================================================
* TABLE 4: Placebo 1995
* =============================================================================
di _n "===== TABLE 4: Placebo 1995 ====="

local cond "if Sample==1"
local clust "cluster(region)"
foreach var in $vote95 {
    di _n "--- `var' ---"
    areg `var' Watch_probit $socioec `cond', absorb(region) robust `clust'
}

* =============================================================================
* TABLE 5: Placebo 2003
* =============================================================================
di _n "===== TABLE 5: Placebo 2003 ====="

local cond "if Sample==1"
local clust "cluster(region)"
qui areg Votes_SPS_2003 Watch_probit $socioec $vote95 `cond', absorb(region) robust
cap drop sample
gen sample = e(sample)
local cond "if sample==1"

foreach var in $vote03 {
    di _n "--- `var' without controls ---"
    areg `var' Watch_probit $socioec $vote95 `cond', absorb(region) robust `clust'

    di _n "--- `var' no vote95 ---"
    areg `var' Watch_probit $socioec `cond', absorb(region) robust `clust'

    di _n "--- `var' with vote99 ---"
    areg `var' Watch_probit $socioec $vote99 `cond', absorb(region) robust `clust'
}
drop sample

* =============================================================================
* TABLE 3: Panel FE (1995-1999)
* =============================================================================
di _n "===== TABLE 3: Panel Fixed Effects ====="

drop if Votes_Edinstvo_1999 == .
cap rename Turnout_2003 Turnout2003
cap rename logpop98 logpop1999
cap rename logpop96 logpop1995
cap rename wage98_ln logwage1999
cap rename wage96_ln logwage1995

rename Votes_DVR_1995 Votes_SPS_1995
gen Watch_probit_2003 = Watch_probit
gen Watch_probit_1995 = 0
rename Watch_probit Watch_probit_1999

reshape long Watch_probit_ Votes_SPS_ Turnout Votes_Yabloko_ Votes_KPRF_ Votes_LDPR_ logpop logwage, i(tik_id)
xi i._j

local cond "if _j!=2003"
foreach var of varlist Votes_SPS_ Votes_Yabloko_ Votes_KPRF_ Votes_LDPR_ Turnout {
    di _n "--- Panel FE: `var' ---"
    xtreg `var' Watch_probit_ _I* `cond', fe i(tik_id) cluster(tik_id)
}

di _n "===== AGGREGATE RESULTS COMPLETE ====="

* =============================================================================
* PART 2: INDIVIDUAL LEVEL RESULTS
* =============================================================================
di _n "=========================================================="
di _n "PART 2: INDIVIDUAL LEVEL RESULTS"
di _n "=========================================================="

use "$datadir/NTV_Individual_Data.dta", clear

* Globals from original
global socioec "logpop98 pop_change98 migr98 pension98 wage98_ln retired98 unempl98 farmers98 crime_rate98"
global basic "logpop98 wage98_ln"
global sociodem "male age educ1 married consump"
global sociodem1995 "male1995 age1995 educ1995 married1995"
global basic1995 "logpop95 wage95_ln"

forvalues x=2/5 {
    cap noi gen tvmaxtvflosspowerA`x' = tvmaxtvflosspowerA^`x'
}

* =============================================================================
* TABLE A1: Summary Statistics (Individual)
* =============================================================================
di _n "===== TABLE A1: Individual Summary Statistics ====="

qui reg vote_reported Watches_NTV_1999 $sociodem $basic [pweight=kishweig], robust cluster(tik_id)
cap drop sample
gen sample = e(sample)

local intended_vote "int_OVR int_Unity int_SPS int_Yabloko int_KPRF int_Zhir int_Against int_vote"
local reported_vote "vote_OVR vote_Unity vote_SPS vote_Yabloko vote_KPRF vote_Zhir vote_Against vote_reported"
tabstat Watches_NTV_1999 NTV_received `intended_vote' `reported_vote' $sociodem knowl NewspapersPolitics RadioPolitics if sample==1 [aweight=kishweig], statistics(mean sd n) columns(statistics)

* =============================================================================
* TABLE 6: First Stage
* =============================================================================
di _n "===== TABLE 6: First Stage ====="

* LPM
di _n "--- OLS first stage ---"
cap noi reg Watches_NTV_1999 tvmaxtveloss5050powerA $sociodem $basic [pweight=kishweig] if vote_OVR!=., robust
if _rc==0 {
    cap noi test tvmaxtveloss5050powerA
}

* Probit
di _n "--- Probit first stage ---"
cap noi probit Watches_NTV_1999 tvmaxtveloss5050powerA $sociodem $basic [pweight=kishweig] if vote_OVR!=., robust
if _rc==0 {
    cap noi test tvmaxtveloss5050powerA
}

* With intended vote
di _n "--- OLS with intended vote ---"
cap noi reg Watches_NTV_1999 tvmaxtveloss5050powerA $sociodem $basic int_Unity int_OVR int_SPS int_Yabloko int_KPRF int_Zhir [pweight=kishweig] if vote_OVR!=., robust
if _rc==0 {
    cap noi test tvmaxtveloss5050powerA
}

di _n "--- Probit with intended vote ---"
cap noi probit Watches_NTV_1999 tvmaxtveloss5050powerA $sociodem $basic int_Unity int_OVR int_SPS int_Yabloko int_KPRF int_Zhir [pweight=kishweig] if vote_OVR!=., robust
if _rc==0 {
    cap noi test tvmaxtveloss5050powerA
}

* =============================================================================
* TABLE 7: Reported Vote (biprobit + probit)
* =============================================================================
di _n "===== TABLE 7: Reported Vote ====="

foreach party in Unity OVR SPS Yabloko KPRF Zhir reported {
    di _n "--- Biprobit: vote_`party' ---"
    cap noi biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA $sociodem $basic) [pweight=kishweig], cluster(tik_id) difficult
    if _rc==0 {
        cap noi margins, dydx(Watches_NTV_1999) predict(pmarg1) force
    }

    di _n "--- Probit: vote_`party' ---"
    cap noi probit vote_`party' Watches_NTV_1999 $sociodem $basic [pweight=kishweig], robust cluster(tik_id)
    if _rc==0 {
        cap noi margins, dydx(Watches_NTV_1999) force
    }
}

* =============================================================================
* TABLE 8: Intended Vote (biprobit)
* =============================================================================
di _n "===== TABLE 8: Intended Vote ====="

foreach party in Unity OVR SPS Yabloko KPRF Zhir vote {
    di _n "--- Biprobit intention: int_`party' ---"
    cap noi biprobit (int_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA $sociodem $basic) [pweight=kishweig], cluster(tik_id) difficult
    if _rc==0 {
        cap noi margins, dydx(Watches_NTV_1999) predict(pmarg1) force
    }
}

* =============================================================================
* TABLE 8 cont: Vote differently than intended
* =============================================================================
di _n "===== TABLE 8 cont: Vote change ====="

foreach party in Unity OVR SPS Yabloko KPRF Zhir reported {
    di _n "--- Vote change: vote_`party' with intentions ---"
    cap noi biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic int_OVR- int_Against) (Watches_NTV_1999=tvmaxtveloss5050powerA $sociodem $basic int_OVR- int_Against) [pweight=kishweig], cluster(tik_id) difficult
    if _rc==0 {
        cap noi margins, dydx(Watches_NTV_1999) predict(pmarg1) force
    }

    di _n "--- Vote change: vote_`party' undecided ---"
    cap noi biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA $sociodem $basic) if int_OVR==. [pweight=kishweig], cluster(tik_id) difficult
    if _rc==0 {
        cap noi margins, dydx(Watches_NTV_1999) predict(pmarg1) force
    }
}

* =============================================================================
* TABLE A4: Individual Placebo 1995
* =============================================================================
di _n "===== TABLE A4: Individual Placebo 1995 ====="

use "$datadir/NTV_Individual_Data.dta", clear

global sociodem1995 "male1995 age1995 educ1995 married1995"
global basic1995 "logpop95 wage95_ln"

forvalues x=2/5 {
    cap noi gen tvmaxtvflosspowerA`x' = tvmaxtvflosspowerA^`x'
}

foreach party in DVR Yabloko KPRF LDPR NDR reported {
    di _n "--- Placebo 1995: Voted_`party'_1995 ---"
    cap noi probit Voted_`party'_1995 Watch_probit $sociodem1995 $basic1995 [pweight=kishweig], robust cluster(tik_id)
    if _rc==0 {
        cap noi margins, dydx(Watch_probit) force
    }
}

di _n "===== ALL TABLES COMPLETE ====="

cap log close _all
