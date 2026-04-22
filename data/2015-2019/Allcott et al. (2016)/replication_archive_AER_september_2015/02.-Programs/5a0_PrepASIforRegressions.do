/* 5c0_PrepASIforRegressions.do */

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

include "$do/Subroutines/DefineGlobals.do"
************************************************************************
************************************************************************
** All weather variables (for merging and differencing)
global AllWeatherVars = "CDD65 rain lnrain ?D_rain_b* PD_rain ND_rain AboveMean_rain rainU lnrainU ?D_rainU_b* PD_rainU ND_rainU AboveMean_rainU"
global AllInstVars = "CapAdd1_Inst C1Hydro_Ins* Hydro_Ins*"
global Moderators = "ElecIntensive sniclambda anyyearEprod LargeK medianlnK"
global AltTFPRVars = "lnW_M_fuels lnW_M_nofuels lnW_CDwCRS lnW_leontief_CRS lnW_CDwCRS_unc lnW_CDnoCRS_sizetrend"

use "$intdata/ASIpanel_fulldataset_Nov2014.dta", replace

** Rename productivity variables
rename lnW lnW_M_nofuels
rename lnW_flag lnW_M_nofuels_flag
rename lnW_M_fuels_noSG lnW
rename lnW_M_fuels_noSG_flag lnW_flag



/* Data Prep */
** Get dyear and year_1
sort panelgroup year
** dyear. This is the time interval
gen dyear = year - year[_n-1] if panelgroup==panelgroup[_n-1] 
gen year_1 = year[_n-1] if panelgroup==panelgroup[_n-1]


** Merge agricultural productivity
merge m:1 state year using "$work\state-level indicators 1992-2010.dta", ///
	keep(match master) nogen keepusing(agprod000ton_Complete) //  agprod000ton
	gen lnagprod000ton = ln(agprod000ton_Complete+1)

** Merge shortage instruments
merge m:1 state year using "$intdata/Shortage Instruments_new.dta", keepusing(SplitGroup _G* $AllWeatherVars /// 
		$AllInstVars) keep(match master match_up match_con) nogen update replace


** Merge Shortages
gen state_orig=state

* 
replace state="BIHAR" if state=="JHARKHAND" & year<=2001
replace state="MADHYA PRADESH" if state=="CHHATTISGARH" & year<=2000
replace state="UTTAR PRADESH" if state=="UTTARANCHAL" & year<=2001

merge m:1 state year using "$work\PDPM-PSP Merged.dta", keep(match master) keepusing(Shortage PeakShortage avail pm) nogen

* Merge Shortage in initial year 
rename Shortage Shortage_orig
rename PeakShortage PeakShortage_orig
gen year_orig = year
replace year = max(inityr,1992) // Crucial: this replaces 1992 as the initial year. Fair under the assumption that shortages were fairly static before then, and or capital stock re-adjusted around that time after liberalization.
merge m:1 state year using "$work\PDPM-PSP Merged.dta", keep(match master) keepusing(Shortage PeakShortage) nogen

rename Shortage InitYrShortage
rename PeakShortage InitYrPeakShortage


replace year = max(inityr-1,1992)
merge m:1 state year using "$work\PDPM-PSP Merged.dta", keep(match master) keepusing(Shortage PeakShortage) nogen
rename Shortage InitYr_1Shortage
rename PeakShortage InitYr_1PeakShortage
gen LInitYrShortage = (InitYr_1Shortage+InitYrShortage)/2


* Merge 5-year lags of shortages
forvalues lagyear = 1/4 {
	replace year = max(year_orig-`lagyear',1992)
	merge m:1 state year using "$work\PDPM-PSP Merged.dta", keep(match master) keepusing(Shortage PeakShortage) nogen
	rename Shortage Shortage_`lagyear'
	rename PeakShortage PeakShortage_`lagyear'
}

gen Shortage_L4 = (Shortage_1+Shortage_2+Shortage_3+Shortage_4)/4

rename Shortage_orig Shortage
rename PeakShortage_orig PeakShortage

	
replace year = year_orig
drop year_orig

replace state=state_orig
drop  state_orig 


/* Generate necessary variables */
** Link to agriculture
gen byte AgriLinked = cond((nic87>=200&nic87<270)|inlist(nic87,350,353,390,393),1,0) if nic87!=. // nic87 never missing but this just makes sure.





** Drop any plants that ever have negative Profits (to avoid selection problem)
bysort panelgroup: egen minProfit=min(Profit)
replace lnProfit_flag = 3 if minProfit<0&minProfit!=. // This will cause it not to be dropped in the standard regression.
drop minProfit

* Materials and labor shares
	g M_Y=matls_nominal/grsale_nominal
	g L_Y=labcost_nominal/grsale_nominal
	gen M_Y_flag = lnM_flag+lnY_flag
	gen L_Y_flag = lnL_flag+lnY_flag
	
gen lnqelecpur_Y = ln(qelecpur/grsale_defl)
gen lambda = qeleccons/grsale_defl
gen FE_Y=(fuelelec_defl)/grsale_defl // This is the fuels+electricity cost share
gen F_Y=(fuels_defl)/grsale_defl // This is the fuels cost share

gen lnF_noSG_Y = ln((fuels_noSG_defl+1)/grsale_defl)

gen Wage = labcost_defl/totpersons

foreach var in lambda avail pm Wage {
	gen ln`var' = ln(`var') // zero lambda should be missing. zero labcost_defl often associated with positive totpersons
}
gen Neglnavail = -1*lnavail

* flags
gen lnqelecpur_Y_flag = lnqelecpur_flag+lnY_flag

gen lnF_noSG_Y_flag = lnF_noSG_flag + lnY_flag
gen lnqelecprod_Y_flag = lnqelecprod_flag + lnY_flag
gen lambda_flag = lnE_flag+lnY_flag
gen lnlambda_flag = lambda_flag
gen lnWage_flag = lnL_flag+lnlabcost_defl_flag

foreach var in investment_rate laborshare_contracted {
	gen `var'_flag = 0 // no flags for this variable
}

gen byte ElecNonProd = 1-anyyearEprod


** For heterogeneous effects regs below:
* Generate snicc and panelgroup medians
foreach var in lnK lnY lambda { // lnW lnL
	bysort panelgroup: egen median`var'_temp = median(`var') if `var'_flag==0
	bysort panelgroup: egen median`var' = mean(median`var'_temp) // this just applies the median to all observations within the panelgroup.
	drop median`var'_temp
}
sum medianlnY, detail
gen byte LargeY = cond(medianlnY>=r(p50)&medianlnY!=.,1,0)
sum medianlnK, detail
gen byte LargeK = cond(medianlnK>=r(p50)&medianlnK!=.,1,0)
replace medianlnK = medianlnK-r(mean) // demean this so that it is more easily readable in regression output


gen E_M = qeleccons/matls_defl
gen E_M_flag = lnE_flag + lnM_flag

gen E_K = qeleccons/fcapclose_defl
gen E_K_flag = lnE_flag + lnK_flag

foreach var in E_K E_M lambda lnK { // SGS alpha_K
	bysort snic: egen snic`var'_temp = mean(`var') if `var'_flag==0
	bysort snic: egen snic`var' = mean(snic`var'_temp) // this just applies the mean to all observations within the panelgroup.
	drop snic`var'_temp
}
sum sniclambda, detail
gen ElecIntensive = cond(sniclambda>=r(p50)&sniclambda!=.,1,0)

** Get snic medians
foreach var in E_K E_M lambda { // SGS
	bysort snic: egen snicmed`var'_temp = median(`var') if `var'_flag==0
	bysort snic: egen snicmed`var' = median(snicmed`var'_temp) // this just applies the mean to all observations within the panelgroup.
	drop snicmed`var'_temp
}

/* Get InSample variables */
gen byte InFESample = cond(masterrank>=2,1,0)


** Gen materials/labor ratio
gen lnM_L = lnM-lnL
gen lnM_L_flag = lnM_flag+lnL_flag


/* Get differences */
drop dlnY dlnL dlnM dlnF dlnK // This is created by 1g_Clean stacked dataset.do from d.lnY (1 year differences). It should be OK to overwrite.

sort panelgroup year
foreach var of varlist SGS lnFE_Y lnF_Y lnFE lnF lnF_noSG_Y lnY lnW lnK lnL lnM lnM_L M_Y L_Y ///
	lambda lnlambda investment_rate lnlabcost_defl laborshare_contracted lnWage ///
	$AltTFPRVars lnProfit /// 
	Shortage PeakShortage $AllInstVars Neglnavail lnpm $AllWeatherVars lnagprod000ton { 
		gen d`var' = `var'-`var'[_n-1] if panelgroup==panelgroup[_n-1] 
		capture gen l`var'_flag = `var'_flag[_n-1] if panelgroup==panelgroup[_n-1]
}


/* Construct Interaction Terms */
	** Moderators
		foreach var in dShortage d$Inst Shortage $Inst { 
			foreach RHSVar in $Moderators {
				gen `var'x`RHSVar' = `var'*`RHSVar'
			}
		}
		
	** Moderators interacted with weather (rainfall and CDD65)
		foreach var of varlist $dRainfallBins dCDD65 {
			foreach RHSVar in $Moderators {
				local RHSVartrim = substr("`RHSVar'",1,5)
				gen _wm_`var'_`RHSVartrim' = `var'*`RHSVar'
			}
		}
		** For fixed effects
		foreach var of varlist $RainfallBins CDD65 {
			foreach RHSVar in $Moderators {
				local RHSVartrim = substr("`RHSVar'",1,5)
				gen _wf_`var'_`RHSVartrim' = `var'*`RHSVar'
			}
		}
		
		
		
/* Label variables */
foreach var of varlist *Hydro_Inst* {
	label var `var' "Hydro"
}
foreach var of varlist *C*Inst* {
	label var `var' "Hydro \& New Supply"
}

		label var dShortagexLargeK "Shortage x Large"
		label var dShortagexmedianlnK "Shortage x ln(Capital)"
		label var dShortagexElecIntensive "Shortage x Elec Intensive"
		label var dShortagexsniclambda "Shortage x Elec Intensity"
		label var dShortagexanyyearEprod "Shortage x Self-Generator"
		
		label var ShortagexLargeK "Shortage x Large"
		label var ShortagexmedianlnK "Shortage x ln(Capital)"
		label var ShortagexElecIntensive "Shortage x Elec Intensive"
		label var Shortagexsniclambda "Shortage x Elec Intensity"
		label var ShortagexanyyearEprod "Shortage x Self-Generator"
		
		
		foreach var of varlist *Inst*xLargeK {
			label var `var' "Z x Large"
		}
		foreach var of varlist *Inst*xmedianlnK {
			label var `var' "Z x ln(Capital)"
		}
		foreach var of varlist *Inst*xElecIntensive {
			label var `var' "Z x Elec Intensive"
		}
		foreach var of varlist *Inst*xsniclambda {
			label var `var' "Z x Elec Intensity"
		}
		foreach var of varlist *Inst*xanyyearEprod {
			label var `var' "Z x Self-Generator "
		}
		
		** Specific to hydro instrument
		label var d$InstxLargeK "Hydro x Large"
		label var d$InstxmedianlnK "Hydro x ln(Capital)"
		label var d$InstxElecIntensive "Hydro x Elec Intensive"
		label var d$Instxsniclambda "Hydro x Elec Intensity"
		label var d$InstxanyyearEprod "Hydro x Self-Generator"
		
		
		
/* Label variables */
label var InitYrShortage "Entry Yr Shortage"
label var Shortage_L4 "Lag Shortage"
label var dShortage "Shortage"
label var dPeakShortage "Shortage" // So that they print out on the same line



label var dlnagprod000ton "ln(Agri Production)"
label var dlnrain "ln(Rainfall)"
label var dlnrainU "ln(Rainfall)"

label var AboveMean_rainU "Above Mean Rain"
label var PD_rainU "Rain x Above Mean"
label var ND_rainU "Rain x Below Mean"

label var drain "Rainfall"
label var drainU "Rainfall"
label var dPD_rainU "Rain x Above Mean"
label var dND_rainU "Rain x Below Mean"
label var dAboveMean_rainU "Above Mean Rain"



label var dCDD65 "Cooling Degrees"
label var CDD65 "Cooling Degrees"
label var anyyearEprod "1(Self-Generator)"
label var ElecNonProd "1(Non Self-Generator)"

*label var dNeglnavail "-1 x ln(Quantity Supplied)"
label var dNeglnavail "Shortage" // So that it compiles into the table
label var Neglnavail "Shortage" // So that it compiles into the table
label var lnavail "ln(Quantity Supplied)"
label var dlnpm "$\Delta$ ln(Peak Quantity Supplied)"


/* Other data prep */
** Get interaction groups
gen long statenumxyear = year*100+statenum
gen long statenumxyear_1 = year_1*100+statenum
gen long statenumxdyear = statenumxyear*100+dyear
gen long dyearxyear = year*100+dyear

egen nic2numxyear = group(nic2num year)



** Prep indicator variables, as ivreg2 doesn't accept factor variables
xi i.year, pre(_Y)
* Change in year
forvalues year = 1993/2010 {
	gen byte _DYyear_`year' = _Yyear_`year'
	replace _DYyear_`year' = -1 if year_1==`year'
	
	* Interactions between {_Y,_DY} and the moderators
	foreach mod in $Moderators {
		gen _yf_`year'_`mod' = _Yyear_`year' * `mod' // _yf is "year" "f"ixed effects mod
		gen _ym_`year'_`mod' = _DYyear_`year' * `mod' // _ym is "year" "mod"
	}
}

*xi i.dyearxyear, pre(_dY) // dyearxyear dummies

** Linear state trends
xi i.statenum, pre(_S)
* Change in state trend for Diff estimator
forvalues st = 2/30 {
	gen byte _DSstatenum_`st' = _Sstatenum_`st' * dyear
	* Interactions between _DS and the moderators
	foreach mod in $Moderators {
		gen _sm_`st'_`mod' = _DSstatenum_`st' * `mod' // _sm is "state" "mod"
	}
}




xi i.statenum|year, pre(_R) // These are state-specific linear trends for FE estimator
drop _Rstatenum* // I don't want the main state indicators because we already have these in _S*
	* Interactions between _Rs and the moderators
	forvalues st = 2/30 {
		foreach mod in $Moderators {
			gen _rf_`st'_`mod' = _RstaXyear_`st' * `mod' // _rf is t"r"end "fixed effects mod"
		}
	}


xi i.nic2numxyear, pre(_N)
xi i.nic2numxyear, pre(_DN)
sort panelgroup year
forvalues g=2/358 {
	replace _DNnic2numx_`g' = -1 if _DNnic2numx_`g'[_n-1]==1 & panelgroup==panelgroup[_n-1]
}


** Split Group
*xi i.SplitGroup, pre(_G) // This is already created and merged in.

** Split group changes
levelsof SplitGroup, local(levels)
local levels = subinstr("`levels'","0","",.)
sort panelgroup year
foreach g in `levels' {
	gen byte _dG`g' =  _G`g'-_G`g'[_n-1] if panelgroup==panelgroup[_n-1]
	
	* Interactions between {_G, _dG} and the moderators
	foreach mod in $Moderators {
		gen _gf_`g'_`mod' = _G`g' * `mod' // _gf is "group" "f"ixed effects moderator
		gen _gm_`g'_`mod' = _dG`g' * `mod' // _gm is "group" "mod"
	}
}

** Weight
gen Weight=mult

bysort panelgroup: gen byte NumObs = _N

compress
sort panelgroup year
save "$intdata/ASIpanel for ASI Regressions.dta", replace
