/* ReplaceWithJointPreSplit.do */
* This replaces pre-split data with the data from the joint state

********************
* Note: the below would need to be modified if additional data (e.g. on temperatures or other CEA data) are added

/* Drag CEA lagged capacity addition, outage, and hydro data backwards for states that split */
	* Note: This means that we will have data for these states before the split, but we need to omit the year when the split happens when doing the differencing estimators!
	* Note: Because we have the plant names for the outage data, we do not need to do this - the outage data already have the final state name
		* This is also true for the weather data - we have the eventual state locations of the weather stations.

sum year
local minyear = r(min)
foreach var of varlist `splitvars' {  // Note that none of the observed reservoir inflows are in a split state, except for one in Uttaranchal which is unobserved until 2005. What this does is drag back the imputed Hydro_Inst data for HydroInflow_Inst
	forvalues year = `minyear'/2003 { // Note: these different variables start in different years, e.g. the capacity data start in 2002 for Jharkhand but the thermal outage data start in 2001. The Hydro_InstFD doesn't start until 2003 because it requires HydroMW for year t-1 and the HydroMW doesn't start until 2002.
		* Bihar/Jharkhand
		sum `var' if state=="BIHAR" & year == `year'
		replace `var' = r(mean) if state=="JHARKHAND" & year==`year' & `var' == .
		* Chhattisgarh/MP
		sum `var' if state=="MADHYA PRADESH" & year==`year'
		replace `var' = r(mean) if state=="CHHATTISGARH" & year==`year' & `var' == .
		* Uttaranchal/UP
		sum `var' if state=="UTTAR PRADESH" & year==`year'
		replace `var' = r(mean) if state=="UTTARANCHAL" & year==`year' & `var' == .
	}
}
