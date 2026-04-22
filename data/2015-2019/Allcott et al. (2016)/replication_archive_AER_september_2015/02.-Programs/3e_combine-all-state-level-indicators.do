/* 3e_combine all state-level indicators.do */

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
***************************************************************************
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

include "$do/Subroutines/DefineGlobals.do"
************************************************************************************
************************************************************************************

************************************************************************************
************************************************************************************

use "$intdata/Shortage Instruments_new.dta", clear

merge 1:1 state year using "$intdata/World Bank Enterprise Survey/WBESStateShortageMeasures.dta", keep(match master) nogen

merge 1:1 state year using "$intdata/ShareElecSelfGen_CEA.dta", keep(match master) nogen

merge 1:1 state year using "$work\state gdp and gdppc figs_const & curr.dta", keep(match master) nogen

	* Get a balanced panel of agprod. 
	gen agprod000ton_Complete = agprod000ton
		* In these data the split happens in 2000, not 2001, so actually need to re-combine in 2000 so that the SplitGroup variables correctly control.
		sum agprod000ton_Complete if (state=="CHHATTISGARH"|state=="MADHYA PRADESH")&year==2000
		replace agprod000ton_Complete = r(sum) if (state=="MADHYA PRADESH")&year==2000
		
		sum agprod000ton_Complete if (state=="BIHAR"|state=="JHARKHAND")&year==2000
		replace agprod000ton_Complete = r(sum) if (state=="BIHAR")&year==2000
	
		sum agprod000ton_Complete if (state=="UTTARANCHAL"|state=="UTTAR PRADESH")&year==2000
		replace agprod000ton_Complete = r(sum) if (state=="UTTAR PRADESH")&year==2000
	
	replace agprod000ton_Complete = . if inlist(state,"CHHATTISGARH","JHARKHAND","UTTARANCHAL")&year==2000

	local splitvars = "agprod000ton_Complete"
	include "$do/subroutines/ReplaceWithJointPreSplit.do"
	
	* For A&N, just use the 2000 value for missing years 1992-1999
	gsort state -year
	replace agprod000ton_Complete = agprod000ton_Complete[_n-1] if state=="ANDAMAN AND NICOBAR ISLANDS" & agprod000ton_Complete==.

	* For D&N Haveli, just use Maharashtra
	forvalues year = 1992/2010 {
		sum agprod000ton_Complete if state=="MAHARASHTRA"&year==`year'
		replace agprod000ton_Complete = r(mean) if state=="DADRA AND NAGAR HAVELI" & year==`year'
	}
	
*merge 1:1 state year using "$work\median real E price_state year.dta", keep(match master) nogen
*rename Rs_kWh_med temp
rename SGS SGS_WBES
merge 1:1 state year using "$intdata/State-Level ASI_Nov2014.dta", keep(match master) nogen ///
	keepusing(NumberofEstablishments Rs_kWh_med SGS lnF_Y lnFE_Y lnM lnL lnY lnW)


gen statelabel = proper(state)
replace statelabel = subinstr(statelabel,"And","and",.) if strpos(statelabel,"Andhra")==0

replace statelabel = "Andaman and Nicobar Islands" if strpos(statelabel,"andaman")!=0
replace statelabel = "Goa, Daman, and Diu" if statelabel=="Goa Daman and Diu"
replace statelabel = "Uttarakhand" if statelabel=="Uttaranchal"


save "$work\state-level indicators 1992-2010.dta", replace


**************************************************************************************
/* Create dataset for first-stage tests */

use "$work\state-level indicators 1992-2010.dta", replace
encode state, gen(statenum)

*** Data Prep
foreach var in req avail Rs_kWh_med HydroGWh gdp_const {
	gen ln`var' = ln(`var')
}
foreach var in agprod000ton {
	gen ln`var' = ln(`var'+1)
}
	


sort state year
foreach var of varlist lnreq lnavail Shortage C1Hydro_Ins* Hydro_Inst* lnY SGS lnM lnFE_Y CapAd*_Inst annual_rainfallMWMeters_mm rainU lnrainU ///
	lnrain CDD65 lnagprod000ton lnRs_kWh_med lngdp_const $RainfallBins rain ///
	HydroGWh { // HydroMW_rainfall_UDel
	gen d`var' = `var'-`var'[_n-1] if state==state[_n-1] 
}

** Split group changes
levelsof SplitGroup, local(levels)
local levels = subinstr("`levels'","0","",.)
foreach g in `levels' {
	gen byte _dG`g' =  _G`g'-_G`g'[_n-1] if state==state[_n-1]
}


*** Label variables 

label var dShortage "Shortage" 

foreach var of varlist *Hydro_Inst* {
	label var `var' "Hydro"
}
foreach var of varlist *C*Inst* {
	label var `var' "Hydro \& New Supply"
}

	
	gen early = cond(year<=2000,1,0)
	gen statenumxearly = early*100+statenum
	
	gen period = 1 if year<=1997
	replace period = 2 if year>=1998
	replace period = 3 if year>=2005
	gen statenumxperiod = period*100 + statenum

label var Hydro_Inst_basic "Hydro Generation/Assessed Demand"
label var dlnrain "ln(Rainfall)"
label var dCDD65 "Cooling Degrees"
label var dlnagprod000ton "ln(Agri Output)"


xtset statenum year

compress
save "$work/state-level dataset for first stages.dta", replace

