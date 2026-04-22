clear
set more off


use "$dtapath/Tables/Appendix_Table26.dta", clear
set seed 10504

*********************************************************
*1. Select parameter values, LHS and RHS variables
*********************************************************
local alpha=.3 /* Baseline parameter values */
local delta_gamma=.75
******************
* LHS VARIABLES 
*****************
g v1 = dadjlwage
g v2 = dpop
g v3 = dadjlrent
*g v3 = dadjlvalueh
*g v3 = dmlvalueh
g v4 = dest

******************
* RHS VARIABLES 
*****************
g tax = d_bus_dom2
	
******************
* Specifications
*****************
local specnum=4
local Xcontrols1 = "i.year i.fe_group"
local Xcontrols2 = "i.year i.fips_state"
local Xcontrols3 = "dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols4 = "bartik i.year i.fe_group"

tempfile data
save `data'

forv spec=1/`specnum' {
	use `data', clear
	*********************************************************
	*2. Drop states for robustness test
	*********************************************************
	*drop if stateabbrev=="TX"
	*drop if stateabbrev=="OH"
	*drop if stateabbrev=="MI"
	*drop if stateabbrev=="AK"

	*********************************************************
	*3. Run regressions for each outcome
	*********************************************************
	forv i=1/4{
		xi: reg v`i' tax `Xcontrols`spec''  [aw=epop]
		estimates store R`i'
	}
	suest R1 R2 R3 R4 , vce(cluster fips_state)


	*********************************************************
	*4. Point Estimates and Shares
	*********************************************************
	disp "Point Estimates"

	disp "Incidence: Workers"
	lincom _b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]
	local b_I_W=round(100*r(estimate))/100
	local se_I_W=round(100*r(se))/100
	
	disp "Incidence: Landowners"
	lincom _b[R3_mean:tax]
	local b_I_L=round(100*r(estimate))/100
	local se_I_L=round(100*r(se))/100

	disp "Incidence: Firm Owners"
	nlcom  1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')
	matrix A=r(b)
	matrix B=r(V)
	local b_I_F= round(100*A[1,1])/100
	local se_I_F=round(100*B[1,1]^.5)/100

	disp "Share of Incidence: Workers"
	nlcom (_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	matrix A=r(b)
	matrix B=r(V)
	local b_s_W=round(100*A[1,1])/100
	local se_s_W=round(100*B[1,1]^.5)/100
	disp  `b_s_W'

	disp "Share of Incidence: Landowners"
	nlcom (_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	matrix A=r(b)
	matrix B=r(V)
	local b_s_L=round(100*A[1,1])/100
	local se_s_L=round(100*B[1,1]^.5)/100
	disp  `b_s_L'

	disp "Share of Incidence: Firm Owners"
	nlcom ( 1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	matrix A=r(b)
	matrix B=r(V)
	local b_s_F=round(100*A[1,1])/100
	local se_s_F=round(100*B[1,1]^.5)/100

	disp "Test Firm Owners Share =0 AND Workers share=100"
	testnl ((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )-1)=( 1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	disp r(p)
	disp r(chi2)
	local ConventionalViewTest_p=round(100*r(p))/100
	local ConventionalViewTest_chi=round(100*r(chi2))/100

	*********************************************************
	*5. Column for Table
	*********************************************************
	gen agent="Workers" in 1
	replace agent="Landowners" in 3
	replace agent="Firmowners" in 5

	replace agent="SE Workers" in 2
	replace agent="SE Landowners" in 4
	replace agent="SE Firmowners" in 6

	replace agent="W=100 and F=0 Chi2" in 7


	gen b`spec'=string(`b_I_W')  in 1
	replace b`spec' = string(`b_I_W')+"*" in 1 if abs(`b_I_W'/`se_I_W') > 1.65
	replace b`spec' = string(`b_I_W')+"**" in 1 if abs(`b_I_W'/`se_I_W') > 1.96
	replace b`spec' = string(`b_I_W')+"***" in 1 if abs(`b_I_W'/`se_I_W') > 2.58
	
	replace b`spec'=string(`b_I_L')  in 3
	replace b`spec' = string(`b_I_L')+"*" in 3 if abs(`b_I_L'/`se_I_L') > 1.65
	replace b`spec' = string(`b_I_L')+"**" in 3 if abs(`b_I_L'/`se_I_L') > 1.96
	replace b`spec' =string(`b_I_L')+"***" in 3 if abs(`b_I_L'/`se_I_L') > 2.58
	
	replace b`spec'=string(`b_I_F')  in 5
	replace b`spec' = string(`b_I_F')+"*" in 5 if abs(`b_I_F'/`se_I_F') > 1.65
	replace b`spec' = string(`b_I_F')+"**" in 5 if abs(`b_I_F'/`se_I_F') > 1.96
	replace b`spec' = string(`b_I_F')+"***" in 5 if abs(`b_I_F'/`se_I_F') > 2.58
			
	replace b`spec' = "(" + string(`se_I_W') + ")" in 2
	replace b`spec'= "(" + string(`se_I_L') + ")" in 4
	replace b`spec'= "(" + string(`se_I_F') + ")" in 6

	gen Share`spec'= string(`b_s_W') in 1
	replace Share`spec' = string(`b_s_W')+"*" in 1 if abs(`b_s_W'/`se_s_W') > 1.65
	replace Share`spec' = string(`b_s_W')+"**" in 1 if abs(`b_s_W'/`se_s_W') > 1.96
	replace Share`spec' = string(`b_s_W')+"***" in 1 if abs(`b_s_W'/`se_s_W') > 2.58
	
	replace Share`spec'= string(`b_s_L') in 3
	replace Share`spec' = string(`b_s_L')+"*" in 3 if abs(`b_s_L'/`se_s_L') > 1.65
	replace Share`spec' = string(`b_s_L')+"**" in 3 if abs(`b_s_L'/`se_s_L') > 1.96
	replace Share`spec' = string(`b_s_L')+"***" in 3 if abs(`b_s_L'/`se_s_L') > 2.58
	
	replace Share`spec'= string(`b_s_F') in 5
	replace Share`spec' = string(`b_s_F')+"*" in 5 if abs(`b_s_F'/`se_s_F') > 1.65
	replace Share`spec' = string(`b_s_F')+"**" in 5 if abs(`b_s_F'/`se_s_F') > 1.96
	replace Share`spec' = string(`b_s_F')+"***" in 5 if abs(`b_s_F'/`se_s_F') > 2.58

	replace Share`spec'= "(" + string(`se_s_W') + ")" in 2
	replace Share`spec'= "(" + string(`se_s_L') + ")" in 4
	replace Share`spec'= "(" + string(`se_s_F') + ")" in 6

	replace Share`spec'=string(`ConventionalViewTest_chi') in 7
	replace Share`spec'=string(`ConventionalViewTest_p') in 8

	gen rowid=_n
	gen blankspace = . /*Kept for automatic formatting with listtex (for table 4 of paper)*/

	keep b`spec' agent rowid Share`spec' blankspace
	drop if Share`spec'==""
	drop agent
	sort rowid
	tempfile results_`spec'
	save `results_`spec''	
}


*********************************************************
*7. Bring all specifications into one table
*********************************************************


use `results_1', clear
forv spec=2/`specnum' {
	sort rowid
	merge 1:1 rowid using `results_`spec''
	tab _merge
	drop _merge
}
gen agent="Workers" in 1
replace agent="" in 2
replace agent="Landowners" in 3
replace agent="" in 4
replace agent="Firmowners" in 5
replace agent="" in 6
replace agent="$ \chi^{2} $ of ($ S^{W} $ = 100\% and $ S^{F} $ = 0\%)" in 7
replace agent = "P-value" in 8

drop rowid
order agent b1 b2 b3 b4 blankspace Share1 Share2 Share3 Share4
listtex using "Appendix_Table26.tex", replace rstyle(tabular)
