/* GetRainfallVariables.do */
* This subroutine takes the local `rainvar' and creates variables from it. 
	* This will create a state mean, so the dataset must already be limited to 1992-2010.
	* `rainvar' is either `rain' or `rainU'

** Levels
gen ln`rainvar' = ln(`rainvar')
foreach var in `rainvar' { // ln`rainvar'
	bysort state: egen mean_`var'= mean(`var')
	gen PD_`var' = cond(`var'>=mean_`var',`var'-mean_`var',0) // PD = Positive Deviation
	gen ND_`var' = cond(`var'<mean_`var',mean_`var'-`var',0) // ND = Negative Deviation
	gen byte AboveMean_`var' = cond(`var'>=mean_`var',1,0)
}

** Percentile-based bins (cutoffs at the 25th, 50th, 75th percentiles)
foreach dev in P N {
	sum `dev'D_`rainvar' if `dev'D_`rainvar'>0, detail
	gen byte `dev'D_`rainvar'_b1 = cond(`dev'D_`rainvar'>0&`dev'D_`rainvar'<=r(p25),1,0)
	gen byte `dev'D_`rainvar'_b2 = cond(`dev'D_`rainvar'>r(p25)&`dev'D_`rainvar'<=r(p50),1,0)
	gen byte `dev'D_`rainvar'_b3 = cond(`dev'D_`rainvar'>r(p50)&`dev'D_`rainvar'<=r(p75),1,0)
	gen byte `dev'D_`rainvar'_b4 = cond(`dev'D_`rainvar'>r(p75),1,0)
	* (above 30 is already created above)
}

** 50 mm bins
foreach dev in P N {	
	gen byte `dev'D_`rainvar'_b005 = cond(`dev'D_`rainvar'>0&`dev'D_`rainvar'<=0.05,1,0)
	gen byte `dev'D_`rainvar'_b0510 = cond(`dev'D_`rainvar'>0.05&`dev'D_`rainvar'<=0.10,1,0)
	gen byte `dev'D_`rainvar'_b1015 = cond(`dev'D_`rainvar'>0.10&`dev'D_`rainvar'<=0.15,1,0)
	gen byte `dev'D_`rainvar'_b1520 = cond(`dev'D_`rainvar'>0.15&`dev'D_`rainvar'<=0.20,1,0)
	gen byte `dev'D_`rainvar'_b2025 = cond(`dev'D_`rainvar'>0.20&`dev'D_`rainvar'<=0.25,1,0)
	gen byte `dev'D_`rainvar'_b25 = cond(`dev'D_`rainvar'>0.25,1,0)
}

** 60mm bins
foreach dev in P N {	
	gen byte `dev'D_`rainvar'_b006 = cond(`dev'D_`rainvar'>0&`dev'D_`rainvar'<=0.06,1,0)
	gen byte `dev'D_`rainvar'_b0612 = cond(`dev'D_`rainvar'>0.06&`dev'D_`rainvar'<=0.12,1,0)
	gen byte `dev'D_`rainvar'_b1218 = cond(`dev'D_`rainvar'>0.12&`dev'D_`rainvar'<=0.18,1,0)
	gen byte `dev'D_`rainvar'_b1824 = cond(`dev'D_`rainvar'>0.18&`dev'D_`rainvar'<=0.24,1,0)
	gen byte `dev'D_`rainvar'_b24 = cond(`dev'D_`rainvar'>0.24,1,0)
}

** 100mm bins
foreach dev in P N {	
	gen byte `dev'D_`rainvar'_b010 = cond(`dev'D_`rainvar'>0&`dev'D_`rainvar'<=0.10,1,0)
	gen byte `dev'D_`rainvar'_b1020 = cond(`dev'D_`rainvar'>0.10&`dev'D_`rainvar'<=0.20,1,0)
	gen byte `dev'D_`rainvar'_b2030 = cond(`dev'D_`rainvar'>0.20&`dev'D_`rainvar'<=0.30,1,0)
	gen byte `dev'D_`rainvar'_b30 = cond(`dev'D_`rainvar'>0.30,1,0)
}

