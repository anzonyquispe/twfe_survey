/* Construct Hydro Instruments */
* Now that data are prepped and merged, calculate the instruments

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

include "$do/Subroutines/DefineGlobals.do"
************************************************************************************
************************************************************************************	
	
	
use "$work/shortages_base", replace


**********************************************************************************
**********************************************************************************


/* PREP WORK */
*** Get predicted MW
rename HydroMW HydroMW_comb

** Do for both comb and balanced case
	* comb means treating the pre-split states as a combined state, while bal means treating them separately.
foreach case in comb bal {
	gen RestofIndiaHydroMW_`case' = IndiaHydroMW-HydroMW_`case'
	gen State_RestofIndiaHydroMW_`case' = HydroMW_`case'/RestofIndiaHydroMW_`case'
	bysort state: egen meanState_RestofIndiaHydroMW = mean(State_RestofIndiaHydroMW_`case')
	gen PredHydroMW_`case' = meanState_RestofIndiaHydroMW*RestofIndiaHydroMW_`case'
	drop  meanState_RestofIndiaHydroMW
}

rename HydroMW_comb HydroMW

bysort state: egen meanState_RestofIndiaHydroMW_0 = mean(State_RestofIndiaHydroMW_comb) if year<=2000
bysort state: egen meanState_RestofIndiaHydroMW_1 = mean(State_RestofIndiaHydroMW_comb) if year>=2001

replace PredHydroMW_comb = cond(year>=2001,meanState_RestofIndiaHydroMW_1*RestofIndiaHydroMW_comb,meanState_RestofIndiaHydroMW_0*RestofIndiaHydroMW_comb) ///
	if state == "BIHAR"|state=="JHARKHAND"|state=="UTTAR PRADESH"|state=="UTTARANCHAL"|state=="MADHYA PRADESH"|state=="CHHATTISGARH"

drop State_RestofIndiaHydroMW_* RestofIndiaHydroMW_*
	
/* Rainfall-based CF */
gen HydroCF_rain = rainU
gen HydroCF_basinrain = Allocated_rainfallMWMeters // Rainfall data are essentially used to predict Capacity Factors


/* Get CF from combined run-of-river and hydro reservoirs */
	* This bases on mean allocated capacity. 
bysort state: egen meanAllocatedRecentResCap = mean(AllocatedRecentResCap)
bysort state: egen meanAllocatedHydroMW_micro_run = mean(AllocatedHydroMW_micro_run)
gen ShareRes = meanAllocatedRecentResCap/(meanAllocatedRecentResCap+meanAllocatedHydroMW_micro_run)
gen ShareRun = meanAllocatedHydroMW_micro_run/(meanAllocatedRecentResCap+meanAllocatedHydroMW_micro_run)

gen HydroCF_r0 = ShareRes*HydroCF_res_dev + ShareRun*HydroCF_run_dev // rr means res and run-of-river

* Fully use one if the other is missing
replace HydroCF_r0 = HydroCF_res_dev if HydroCF_res_dev!=. & HydroCF_run_dev==.
replace HydroCF_r0 = HydroCF_run_dev if HydroCF_run_dev!=. & HydroCF_res_dev==.


* This bases on mean allocated capacity and imputed zeros when missing. This has the most powerful first stages
gen HydroCF_res_dev0 = cond(HydroCF_res_dev!=.,HydroCF_res_dev,0)
gen HydroCF_run_dev0 = cond(HydroCF_run_dev!=.,HydroCF_run_dev,0)
gen HydroCF_rr = ShareRes*HydroCF_res_dev0 + ShareRun*HydroCF_run_dev0 // rr means res and run-of-river

	* If a series is ALWAYS missing for state, then use the other
replace HydroCF_rr = HydroCF_res_dev if meanAllocatedHydroMW_micro_run==.
replace HydroCF_rr = HydroCF_run_dev if meanAllocatedRecentResCap==.


drop ShareRes ShareRun meanAllocatedRecentResCap meanAllocatedHydroMW_micro_run



***************************************************************************
/* HYDRO INSTRUMENTS */
/*  Basic instrument: Hydro production/Predicted sales */
** Using original prediction
gen Hydro_Inst_orig = HydroGWh/(PredGWhSold_orig) // This is very close to just HydroGWh/TotalGWh, but it doesn't depend on TotalGWh, which is endogenous.

** Using CEA assessed demand
gen Hydro_Inst_basic = HydroGWh/req

** Using consumption
gen Hydro_Inst_con = HydroGWh/TotalEnergySold

** Using predicted consumption
gen Hydro_Inst_Pcon = HydroGWh/(PredGWhSold_comb) // This is very close to just HydroGWh/TotalGWh, but it doesn't depend on TotalGWh, which is endogenous.


** Using predicted requirement
gen Hydro_Inst = HydroGWh/(Predreq_comb) 


local splitvars = "Hydro_Inst_orig Hydro_Inst_basic Hydro_Inst_con Hydro_Inst_Pcon Hydro_Inst"
include "$do/subroutines/ReplaceWithJointPreSplit.do"

foreach var in `splitvars' {
	replace `var' = 0 if `var'==. // This replaces four observations of A&N Islands that have missing HydroGWh because the plant did not report in the CEA data.
}

************************************************

/* Fit all Hydro Capacity Factor-based instruments */

	* These instruments identify only off of capacity factors, not changes in hydro capacity
	* Note that this gives instrument = 0 when HydroMW is zero, although HydroMW doesn't include central sector plants. The consequence is that there are five state-years (3 in Manipur and 2 in Nagaland) that are set to zero even though they have actual production data (from central sector plants) in the microdata. However, these get set to zero later anyway, so it won't matter at all.
	* We could alternatively use HydroMW_micro or a prediction based on that. This would include central sector plants,
		* but this makes the biggest difference for Uttaranchal and HP, two states that don't actually consume the power
		* generated in Central sector plants. HydroMW_micro tends to register new capacity 1-2 years earlier, so that would be
		* good. On the other hand, missing plants in HydroMW_micro make this series more noisy.


** Balanced panel fits
	** This makes Hydro_Inst zero if missing observations.
	* HydroCF_basinrain is missing (thus Inst=0) iff no dams. OK
	* HydroCF_act is missing if no state or private dams (central sector reported separately). OK to make zero.
	* res_dev, all_dev, run_dev are missing (thus zero) if no observed dams or if no dams. if no observed dams then missing zero imputation is fine because that's the mean. if no dams then zero also fine.
foreach fit in res_dev run_dev rr r0 basinrain rain { // res_dev all_dev run_dev
		// If HydroMW==0, then the CF is missing. So need to make this zero in those cases. Note that in a couple of cases when HydroMW goes from 0 to positive, the instrument will also do that, which is counter to the idea of using the PredHydroMW. But it is not clear what else to do here. Also note that in TN and Uttaranchal, the Res CF dev is zero until 2005ish, then becomes non-zero as a reservoir enters the panel. The problem is that the instrument then goes from zero to something negative or positive in the first year, which will generate noise. Again I still believe that this is the best way to address this.
	** Using consumption
	gen Hydro_InstC_`fit' = cond(HydroCF_`fit'!=.,HydroCF_`fit'*PredHydroMW_bal*8.760/PredGWhSold_bal,0) 
	gen Hydro_InstN_`fit' = cond(HydroCF_`fit'!=.,HydroCF_`fit'*HydroMW*8.760/PredGWhSold_bal,0) 
	
	
	** Using req
	* Basic
	gen Hydro_InstB_`fit' = cond(HydroCF_`fit'!=.,HydroCF_`fit'*HydroMW*8.760/req,0) // Basic

	* Intermediate between basic and actual
		* Predicted req but actual MW
		gen Hydro_InstM_`fit' = cond(HydroCF_`fit'!=.,HydroCF_`fit'*HydroMW*8.760/Predreq_bal,0) 
		* Predicted MW but actual req
		gen Hydro_InstR_`fit' = cond(HydroCF_`fit'!=.,HydroCF_`fit'*PredHydroMW_bal*8.760/req,0) 

	* Actual instrument: both predicted
	gen Hydro_Inst_`fit' = cond(HydroCF_`fit'!=.,HydroCF_`fit'*PredHydroMW_bal*8.760/Predreq_bal,0) 
	
	
	
}

local splitvars = "Hydro_InstB_* Hydro_InstN_* Hydro_InstM_*" // These have missing values of HydroMW and so need to replace with joint pre-split
include "$do/subroutines/ReplaceWithJointPreSplit.do"

*******************************************************************************
*******************************************************************************





/* FIT CAPACITY CHANGE INSTRUMENTS */
/* Use average thermal CF - most of new plants in this period are actually thermal */
bysort year: egen CFPred=mean(ThermalCF)
	* Fix missing data for 1992, 1993, and 2010
	sum CFPred if year==1994
	replace CFPred = r(mean) if year==1992|year==1993
	sum CFPred if year==2009
	replace CFPred = r(mean) if year==2010

/* Get capacity change instruments */
	* PredGWhSold_comb is used because these data are for the combined states pre-split
foreach var in CapAdd CapAdd0 CapAdd1 {
	gen `var'_Inst = CFPred*`var'/Predreq_comb // PredGWhSold_comb
}


local splitvars = "CapAdd_Inst CapAdd0_Inst CapAdd1_Inst"
include "$do/subroutines/ReplaceWithJointPreSplit.do"


/* GET COMBINATIONS OF CAPACITY CHANGE INSTRUMENTS AND HYDRO INSTRUMENTS */
foreach var of varlist Hydro_Inst* {
	gen C`var' = CapAdd_Inst+`var'
	gen C0`var' = CapAdd0_Inst+`var'
	gen C1`var' = CapAdd1_Inst+`var'
}




*****************************************************************************
/* Label */
foreach var of varlist Hydro_Ins* {
	label var `var' "Hydro Instrument"
}

compress
save "$intdata/Shortage Instruments_new.dta", replace
