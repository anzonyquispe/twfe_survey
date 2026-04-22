set more off
cd "/Users/mac/Dropbox/Work\NTV\Data\Replication\"
use NTV_Individual_Data.dta, clear

* create list of controls
global socioec="logpop98 pop_change98 migr98 pension98  wage98_ln retired98 unempl98  farmers98 crime_rate98  "
global basic="logpop98  wage98_ln    "
global sociodem="male age educ1 married consump"

global sociodem1995="male1995 age1995 educ1995 married1995 "
global basic1995="logpop95  wage95_ln"

forvalues x=2/5 {

g  tvmaxtvflosspowerA`x'=tvmaxtvflosspowerA^`x'
}


********************* Summary statistics (TABLE A1)
qui reg vote_reported Watches_NTV_1999   $sociodem $basic [pweight=kishweig],  robust cluster(tik_id)
gen sample=e(sample)

local intended_vote="int_OVR int_Unity  int_SPS  int_Yabloko  int_KPRF int_Zhir int_Against int_vote"
local reported_vote="vote_OVR vote_Unity vote_SPS vote_Yabloko vote_KPRF  vote_Zhir vote_Against vote_reported"
tabstat  Watches_NTV_1999  NTV_received `intended_vote' `reported_vote'  $sociodem knowl NewspapersPolitics RadioPolitics  if sample==1 [aweight=kishweig], statistics (mean sd n)  columns (statistics) 
*tabstat  NTV_received if sample==1 [aweight=kishweig], statistics (mean sd n)  columns (statistics) by(NTV1999  )


local opt="replace"

foreach var in Watches_NTV_1999 `intended_vote' `reported_vote' $sociodem NewspapersPolitics RadioPolitics {
	quietly reg `var' NTV1999 if region!=77 & region!=78 [aweight=kishweig], robust cluster(tik_id) 
	outreg2 using "SummarybyNTV.xls"  ,   bdec(3) tdec (3) bracket p  `opt'
	local opt="append"
}
************* first stage (TABLE 6)
local opt="replace"
foreach watch in  Watches_NTV_1999 {

	quietly reg `watch' tvmaxtveloss5050powerA    $sociodem $basic [pweight=kishweig] if vote_OVR!=., robust  
	quietly test tvmaxtveloss5050powerA 
	local F=r(F)
	outreg2 using "first_stage_loss.xls",   bdec(3) se bracket `opt' addstat("F-statistics",`F')
	local opt="append"


	quietly probit  `watch' tvmaxtveloss5050powerA  $sociodem $basic [pweight=kishweig] if vote_OVR!=., robust 
	
	quietly test tvmaxtveloss5050powerA 
	outreg2 using "first_stage_loss.xls",   bdec(3) se bracket `opt' addstat("chi2",r(chi2))

	quietly reg `watch' tvmaxtveloss5050powerA  $sociodem $basic   int_Unity int_OVR int_SPS int_Yabloko int_KPRF int_Zhir  [pweight=kishweig] if vote_OVR!=., robust  
	quietly test tvmaxtveloss5050powerA 
	local F=r(F)
	outreg2 using "first_stage_loss.xls",   bdec(3) se bracket `opt' addstat("F-statistics",`F')

	quietly probit  `watch' tvmaxtveloss5050powerA  $sociodem $basic  int_Unity int_OVR int_SPS int_Yabloko int_KPRF int_Zhir  [pweight=kishweig] if vote_OVR!=., robust  
	quietly test tvmaxtveloss5050powerA 
	outreg2 using "first_stage_loss.xls",   bdec(3) se bracket `opt' addstat("chi2",r(chi2))

}

************* reported vote  regressions (TABLE 7)

set more off
local opt="replace"
foreach party in  Unity  OVR  SPS Yabloko KPRF  Zhir reported  {



	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic) [pweight=kishweig], difficult
	quietly test tvmaxtveloss5050powerA
	local chi=r(chi2)
	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic) [pweight=kishweig], cluster(tik_id) difficult
	local clusters=e(N_clust)
	margins, dydx( Watches_NTV_1999 ) predict (pmarg1) force
	matrix A=r(b) 
	matrix B=r(V)
	local marg=A[1,1]
	local margstderr=sqrt(B[1,1])
	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic) [pweight=kishweig], cluster(tik_id) difficult
	outreg2 using "reported_vote_loss.xls",  bdec(3) se bracket `opt' addstat("chi2",`chi', "Marginal effect",`marg',"Marginal effect stnd error",`margstderr',"Number of clusters", `clusters' )
    local opt="append"


	qui probit vote_`party' Watches_NTV_1999   $sociodem $basic [pweight=kishweig],  robust cluster(tik_id) 
	local clusters=e(N_clust)
	margins, dydx( Watches_NTV_1999 ) force
	matrix A=r(b) 
	matrix B=r(V)
	local marg=A[1,1]
	local margstderr=sqrt(B[1,1])
	probit vote_`party' Watches_NTV_1999   $sociodem $basic [pweight=kishweig],  robust cluster(tik_id) 
	outreg2 using "reported_vote_loss.xls",  bdec(3) se bracket `opt' addstat("Marginal effect",`marg', "Marginal effect stnd error",`margstderr', "Number of clusters",  `clusters')
}






****************************************************************************************
**************** intention to vote  regressions  (part of TABLE 8)


set more off

local opt="replace"
foreach party in  Unity OVR  SPS Yabloko KPRF   Zhir vote{

	biprobit (int_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic) [pweight=kishweig], difficult	
	quietly test tvmaxtveloss5050powerA
	local chi=r(chi2)
	biprobit (int_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic) [pweight=kishweig], difficult	cluster(tik_id) 
	local clusters=e(N_clust)
	margins, dydx( Watches_NTV_1999 ) predict (pmarg1) force
	matrix A=r(b) 
	matrix B=r(V)
	local marg=A[1,1]
	local margstderr=sqrt(B[1,1])
	biprobit (int_`party' = Watches_NTV_1999 $sociodem $basic) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic) [pweight=kishweig], difficult	cluster(tik_id) 
	outreg2 using "intention_vote_loss.xls",  bdec(3) se bracket `opt' aster(se) addstat("chi2",`chi', "Marginal effect",`marg',"Marginal effect stnd error",`margstderr',"Number of clusters", `clusters') 
    local opt="append"	

}



*************** voted differently than intended regressions and undecided (rest of TABLE 8) 
set more off


local opt="replace"
foreach party in Unity  OVR  SPS Yabloko KPRF Zhir reported {
	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic int_OVR- int_Against  ) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic int_OVR- int_Against  ) [pweight=kishweig], difficult
	quietly test tvmaxtveloss5050powerA
	local chi=r(chi2)

	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic int_OVR- int_Against  ) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic int_OVR- int_Against  ) [pweight=kishweig], difficult cluster(tik_id)
	local clusters=e(N_clust)
	margins, dydx( Watches_NTV_1999 ) predict (pmarg1) force
	matrix A=r(b) 
	matrix B=r(V)
	local marg=A[1,1]
	local margstderr=sqrt(B[1,1])
	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic int_OVR- int_Against  ) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic int_OVR- int_Against  ) [pweight=kishweig], difficult cluster(tik_id)
	outreg2 using "vote_change_loss.xls",  bdec(3) se bracket `opt' addstat("chi2",`chi', "Marginal effect",`marg',"Marginal effect stnd error",`margstderr',"Number of clusters", `clusters')
	
	local opt="append"

	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic ) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic ) if int_OVR==.  [pweight=kishweig], difficult
	quietly test tvmaxtveloss5050powerA
	local chi=r(chi2)
    biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic ) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic ) if int_OVR==.  [pweight=kishweig], difficult cluster(tik_id)
	margins, dydx( Watches_NTV_1999 ) predict (pmarg1) force
	matrix A=r(b) 
	matrix B=r(V)
	local marg=A[1,1]
	local margstderr=sqrt(B[1,1])
	biprobit (vote_`party' = Watches_NTV_1999 $sociodem $basic ) (Watches_NTV_1999=tvmaxtveloss5050powerA  $sociodem $basic ) if int_OVR==.  [pweight=kishweig], difficult cluster(tik_id)
	outreg2 using "vote_change_loss.xls",  bdec(3) se bracket `opt' addstat("chi2",`chi', "Marginal effect",`marg',"Marginal effect stnd error",`margstderr',"Number of clusters", `clusters')
}


**************************************
*Individual level placebo regression for 1995 (TABLE A4)



set more off
local opt="replace"
foreach party in  DVR Yabloko   KPRF LDPR NDR reported{

	probit Voted_`party'_1995 Watch_probit    $sociodem1995 $basic [pweight=kishweig],  robust cluster(tik_id) 
	local clusters=e(N_clust)
	mfx compute, predict (p)
	matrix A=e(Xmfx_dydx) 
	matrix B=e(Xmfx_se_dydx)
	local marg=A[1,1]
	local margstderr=B[1,1]
	outreg2 using "reported_vote_loss_1995.xls",   bdec(3) se bracket `opt' addstat("Marginal effect",`marg', "Marginal effect stnd error",`margstderr', "Number of clusters",  `clusters')
	

      local opt="append"
}



*Individual level DiD (TABLE A3)

rename Voted_DVR_1995 Voted_SPS_1995
rename  vote_reported  Voted_reported_1999
rename  vote_Zhir  Voted_LDPR_1999
rename  logpop95 logpop_1995 
rename  wage95_ln wage_ln_1995

rename  logpop98 logpop_1999 
rename  wage98_ln wage_ln_1999

foreach x in male age educ1 married  {
rename `x' `x'1999
}
rename  educ11999  educ1999
foreach x in SPS Yabloko KPRF  {
rename vote_`x' Voted_`x'_1999
}
rename kishweig kishweig1999
rename  weight  kishweig1995

keep  Voted_* kishweig* region tik_id Watch_probit  logpop_199*  wage_ln_199* male* age* educ* married* 
drop Voted_NDR_1995
gen ID=_n


reshape long Voted_KPRF_ Voted_Yabloko_ Voted_LDPR_ Voted_SPS_ Voted_reported_  logpop_  wage_ln_ male age educ married kishweig,  i(ID) j(year)
reg  Voted_reported_ Watch_probit   male age educ married logpop_ wage_ln_  
keep if e(sample)

xi i.year
*xi i.ate, pref( _A)
set more off
local opt="replace"
foreach party in   SPS Yabloko   KPRF LDPR reported {

	probit Voted_`party'_ Watch_probit   male age educ married logpop_ wage_ln_  _I*  [pweight=kishweig],  cluster(tik_id) 
	local clusters=e(N_clust)
	mfx compute, predict (p)
	matrix A=e(Xmfx_dydx) 
	matrix B=e(Xmfx_se_dydx)
	local marg=A[1,1]
	local margstderr=B[1,1]
	outreg2 Watch_probit   male age educ married logpop_ wage_ln_ using "reported_vote_loss_panel.xls",   bdec(3) se bracket `opt' addstat("Marginal effect",`marg', "Marginal effect stnd error",`margstderr', "Number of clusters",  `clusters')
	

      local opt="append"
	  
	  
}



*/

*/

