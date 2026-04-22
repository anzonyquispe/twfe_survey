/********************************
* supplanalysis_spatialse.do

This file reproduces the main results of the paper and corrects for spatial 
interdependence of the error terms using conley's s.e. corrections.

The do file calls x_ols_td.ado and x_gmm_td.do to generate the conley s.e.'s.

x_ols_td and x_gmm_td are slightly modified versions of x_ols.ado and x_gmm_ado (written by Jean-Pierre Dube), 
adjusted to store the output in a way that makes it easier to create tables. 

For the census data: sp_lat sp_long are the coordinates
cutoffs are varied between 0.01 and 1 degress
* range of lat is 29.2 to 32.7
* range of long is 26.9 to 30.7

* data used is the main analysis sample
********************************/
clear
use "$data\matched_censusdata.dta", clear
* PRODUCE THESE RESULTS FOR LARGE PLACES ONLY
keep if largearea==1

tab dccode0, gen(district)

* convert long to positive measure
gen sp_longpos=-1*sp_long

gen c1=sp_lat
gen c2=sp_longpos
gen const=1

****************************
* set up variables here
****************************
local x1 kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0
local x2 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
local xadd d_prop_waterclose d_prop_flush
local district district2 district3 district4 district5 district6 district7 district8 district9 district10


*********** loop over cutoff values *********************
* smallest = 0.1; largest =1; loop in increments of 0.1
*********************************************************

*********************************************************
* APPENDIX 2: TABLE 4: first stage
*********************************************************
local i = 0.1
local c = 1
while `i'<=1 {
	cap drop cutoff*
	gen cutoff1=`i'
	gen cutoff2=`i'

	* GENERATE ALL FS RESULTS
	global label="1_`c'"
	preserve
	x_ols_td c1 c2 cutoff1 cutoff2 T mean_grad_new const, coord(2) xreg(2)
	restore
	global label="2_`c'"
	preserve
	x_ols_td c1 c2 cutoff1 cutoff2 T mean_grad_new const `x1' `x2', coord(2) xreg(12)
	restore
	global label="3_`c'"
	preserve
	x_ols_td c1 c2 cutoff1 cutoff2 T mean_grad_new const `x1' `x2' `district', coord(2) xreg(21)
	restore
	global label="4_`c'"
	preserve
	x_ols_td c1 c2 cutoff1 cutoff2 T mean_grad_new const `x1' `x2' `district' `xadd' , coord(2) xreg(23)
	restore
	global label="5_`c'"
	preserve
	keep if prop_elec0==0
	x_ols_td c1 c2 cutoff1 cutoff2 T mean_grad_new const `x1' `x2' `district' `xadd' , coord(2) xreg(23)
	restore

	preserve
	clear
	use "$temp\varnames_ols.dta", clear
	local j = 1
	while `j'<=5 {
		merge id using "$temp\spatialse_`j'_`c'.dta"
		drop _merge
		sort id
		erase "$temp\spatialse_`j'_`c'.dta"
		local j = `j'+1
	}
	save "$temp\spatialse_table4_c`c'.dta", replace
	restore

	* LOOP OVER CUTOFFS
	local i = `i'+0.1
	local c = `c'+1
}

* merge the results over cutoffs
preserve
use "$temp\spatialse_table4_c1.dta", clear
sort id
local c = 2
while `c'<=10 { 	
	merge id using "$temp\spatialse_table4_c`c'.dta"
	drop _merge
	sort id
	erase "$temp\spatialse_table4_c`c'.dta"
	local c = `c'+1
}
erase "$temp\spatialse_table4_c1.dta"
save "$temp\spatialse_table4.dta", replace
outsheet using "$temp\spatialse_table4.out", replace
restore




*********************************************************
* table 5: effects for energy use (with and without controls)
*********************************************************
local y d_prop_elec d_prop_candles d_prop_wood d_prop_eleccook 

foreach one of local y {
	local c = 1
	local i = 0.1
	while `i'<=1 {
		cap drop cutoff*
		gen cutoff1=`i'
		gen cutoff2=`i'
		global label="1_`c'"
		preserve
		keep if `one'!=.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const, coord(2) xreg(2)
		restore
		global label="2_`c'"
		preserve
		keep if `one'!=.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district' `xadd', coord(2) xreg(23)
		restore
		global label="3_`c'"
		preserve
		keep if `one'!=.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' mean_grad_new const `x1' `x2' `district' `xadd', coord(2) xreg(23)
		restore
		global label="4_`c'"
		preserve
		keep if `one'!=.
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const mean_grad_new const, coord(2) xreg(2) inst(2)
		restore
		global label="5_`c'"
		preserve
		keep if `one'!=.
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district' `xadd' mean_grad_new const `x1' `x2' `district' `xadd' , coord(2) xreg(23) inst(23)
		restore

		preserve
		clear
		use "$temp\varnames_iv.dta", clear
		local j = 1
		while `j'<=5 {
			merge id using "$temp\spatialse_`j'_`c'.dta"
			drop _merge
			sort id
			erase "$temp\spatialse_`j'_`c'.dta"
			local j = `j'+1
		}
		save "$temp\spatialse_`one'_c`c'.dta", replace
		restore

		* LOOP OVER CUTOFFS for same yvar
		local i = `i'+0.1
		local c = `c' + 1	
	}

	* merge datasets
	preserve
	use "$temp\spatialse_`one'_c1.dta", clear
	sort id
	local c=2
	while `c'<=10 { 	
		merge id using "$temp\spatialse_`one'_c`c'.dta"
		drop _merge
		sort id
		erase "$temp\spatialse_`one'_c`c'.dta"
		local c = `c' + 1
	}
	erase "$temp\spatialse_`one'_c1.dta"
	save "$temp\spatialse_`one'.dta", replace
	outsheet using "$temp\spatialse_`one'.out", replace
	restore

* LOOP OVER YVARS
}


* water
local one = "d_prop_waterclose"
	local i = 0.1
	local c=1
	while `i'<=1 {
		cap drop cutoff*
		gen cutoff1=`i'
		gen cutoff2=`i'

		global label="1_`c'"
		preserve
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const, coord(2) xreg(2)
		restore
		global label="2_`c'"
		preserve
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T cons `x1' `x2' `district' d_prop_flush, coord(2) xreg(22)
		restore
		global label="3_`c'"
		preserve
		x_ols_td c1 c2 cutoff1 cutoff2 `one' mean_grad_new const `x1' `x2' `district' d_prop_flush, coord(2) xreg(22)
		restore
		global label="4_`c'"
		preserve
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const mean_grad_new const, coord(2) xreg(2) inst(2)
		restore
		global label="5_`c'"
		preserve
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district' d_prop_flush mean_grad_new const `x1' `x2' `district' d_prop_flush, coord(2) xreg(22) inst(22)
		restore

		preserve
		clear
		use "$temp\varnames_iv.dta", clear
		local j = 1
		while `j'<=5 {
			merge id using "$temp\spatialse_`j'_`c'.dta"
			drop _merge
			sort id
			erase "$temp\spatialse_`j'_`c'.dta"
			local j = `j'+1
		}
		save "$temp\spatialse_`one'_c`c'.dta", replace
		restore

		* LOOP OVER CUTOFFS for same yvar
		local i = `i'+0.1
		local c = `c' + 1	
	}

* merge datasets
preserve
use "$temp\spatialse_`one'_c1.dta", clear
sort id
local c=2
while `c'<=10 { 	
	merge id using "$temp\spatialse_`one'_c`c'.dta"
	drop _merge	
	sort id
	erase "$temp\spatialse_`one'_c`c'.dta"
	local c = `c' + 1
}
erase "$temp\spatialse_`one'_c1.dta"
save "$temp\spatialse_`one'.dta", replace
outsheet using "$temp\spatialse_`one'.out", replace
restore


* d_prop_flush
local one = "d_prop_flush"
	local i = 0.1
	local c=1
	while `i'<=1 {
		cap drop cutoff*
		gen cutoff1=`i'
		gen cutoff2=`i'

		global label="1_`c'"
		preserve
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const, coord(2) xreg(2)
		restore
		global label="2_`c'"
		preserve
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T cons `x1' `x2' `district' d_prop_waterclose, coord(2) xreg(22)
		restore
		global label="3_`c'"
		preserve
		x_ols_td c1 c2 cutoff1 cutoff2 `one' mean_grad_new const `x1' `x2' `district' d_prop_waterclose, coord(2) xreg(22)
		restore
		global label="4_`c'"
		preserve
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const mean_grad_new const, coord(2) xreg(2) inst(2)
		restore
		global label="5_`c'"
		preserve
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district' d_prop_waterclose mean_grad_new const `x1' `x2' `district' d_prop_waterclose, coord(2) xreg(22) inst(22)
		restore

		preserve
		clear
		use "$temp\varnames_iv.dta", clear
		local j = 1
		while `j'<=5 {
			merge id using "$temp\spatialse_`j'_`c'.dta"
			drop _merge
			sort id
			erase "$temp\spatialse_`j'_`c'.dta"
			local j = `j'+1
		}
		save "$temp\spatialse_`one'_c`c'.dta", replace
		restore

		* LOOP OVER CUTOFFS for same yvar
		local i = `i'+0.1
		local c = `c' + 1	
	}

* merge datasets
preserve
use "$temp\spatialse_`one'_c1.dta", clear
sort id
local c=2
while `c'<=10 { 	
	merge id using "$temp\spatialse_`one'_c`c'.dta"
	drop _merge
	sort id
	erase "$temp\spatialse_`one'_c`c'.dta"
	local c = `c' + 1
}
erase "$temp\spatialse_`one'_c1.dta"
save "$temp\spatialse_`one'.dta", replace
outsheet using "$temp\spatialse_`one'.out", replace
restore




*********************************************************
* APPENDIX 3: table 5 and 6: male and female employment
*********************************************************
local y d_prop_emp_f d_prop_emp_m
local y d_prop_emp_m
local x1 kms_to_subs0 baseline_hhdens0 base_hhpovrate0 prop_head_f_a0 sexratio0 prop_indianwhite0
local x2 kms_to_road0 kms_to_town0 prop_matric_m0 prop_matric_f0
local xadd d_prop_waterclose d_prop_flush
local district district2 district3 district4 district5 district6 district7 district8 district9 district10

foreach one of local y {

	local i = 0.1
	local c = 1
	while `i'<=1 {
		cap drop cutoff*
		gen cutoff1=`i'
		gen cutoff2=`i'

		global label="1_`c'"
		preserve
		drop if `one'==.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const, coord(2) xreg(2)
		restore
		global label="2_`c'"
		preserve
		drop if `one'==.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2', coord(2) xreg(12)
		restore
		global label="3_`c'"
		preserve
		drop if `one'==.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district', coord(2) xreg(21)
		restore
		global label="4_`c'"
		preserve
		drop if `one'==.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' T cons `x1' `x2' `district' `xadd', coord(2) xreg(23)
		restore
		global label="5_`c'"
		preserve
		drop if `one'==.
		x_ols_td c1 c2 cutoff1 cutoff2 `one' mean_grad_new const `x1' `x2' `district' `xadd', coord(2) xreg(23)
		restore
		global label="6_`c'"
		preserve
		drop if `one'==.
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const mean_grad_new const, coord(2) xreg(2) inst(2)
		restore
		global label="7_`c'"
		preserve
		drop if `one'==.
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' mean_grad_new const `x1' `x2', coord(2) xreg(12) inst(12)
		restore
		global label="8_`c'"
		preserve
		drop if `one'==.
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district' mean_grad_new const `x1' `x2' `district', coord(2) xreg(21) inst(21)
		restore
		global label="9_`c'"
		drop if `one'==.
		preserve
		x_gmm_td c1 c2 cutoff1 cutoff2 `one' T const `x1' `x2' `district' `xadd' mean_grad_new const `x1' `x2' `district' `xadd', coord(2) xreg(23) inst(23)
		restore

		
		preserve
		clear
		use "$temp\varnames_iv.dta", clear
	
		local j = 1
		while `j'<=9 {
			merge id using "$temp\spatialse_`j'_`c'.dta"
			drop _merge
			sort id
			erase "$temp\spatialse_`j'_`c'.dta"
			local j = `j'+1
			}
		save "$temp\spatialse_`one'_c`c'.dta", replace
		restore

		* LOOP OVER CUTOFFS for same yvar
		local i = `i'+0.1
		local c = `c' + 1	
		}

	* merge datasets
	preserve
	use "$temp\spatialse_`one'_c1.dta", clear
	sort id
	local c=2
	while `c'<=10 { 	
		merge id using "$temp\spatialse_`one'_c`c'.dta"
		drop _merge
		sort id
		erase "$temp\spatialse_`one'_c`c'.dta"
		local c = `c' + 1
		}
	erase "$temp\spatialse_`one'_c1.dta"
	save "$temp\spatialse_`one'.dta", replace
	outsheet using "$temp\spatialse_`one'.out", replace
	restore
* LOOP OVER YVARS
}
*/
clear
exit
