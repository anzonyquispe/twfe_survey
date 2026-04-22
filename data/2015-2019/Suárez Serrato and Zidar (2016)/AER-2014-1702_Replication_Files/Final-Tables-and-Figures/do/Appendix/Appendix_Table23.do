clear
set more off


use "$dtapath/Tables/Appendix_Table23.dta", replace 
set seed 10502

*********************************************************
*1. Select parameter values, LHS and RHS variables
*********************************************************
local alpha=.3
local delta_gamma=.9
******************
* LHS VARIABLES 
*****************
g v1=dadjlwage
g v2=dpop
g v3=dadjlrent
*g v3=dadjlvalueh
*g v3 =dmlvalueh
g v4=dest

******************
* RHS VARIABLES 
*****************
g tax= d_bus_dom2
*g tax= d_corp_orig /*old RHS tax rate (for table 8a)*/
*g tax = d_t_corp_fed
*g tax = d_t_corp_fed_effective


******************
* Specifications
*****************
local specnum=10
local Xcontrols1 = "GovParty_D GovParty_I GovParty_R  i.year i.fe_group"
local Xcontrols2 = "SalesTaxRate i.year i.fe_group"
local Xcontrols3 = "DSalesTaxRate i.year i.fe_group"
local Xcontrols4 = "income_rate_fam i.year i.fe_group"
local Xcontrols5 = "Dincome_rate_fam i.year i.fe_group"
local Xcontrols6 = "dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols7 = "rev_corptax_gdp i.year i.fe_group"
local Xcontrols8 = "rev_corptax_gdp dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols9 = "bartik i.year i.fe_group"
local Xcontrols10= "i.grt i.year i.fe_group"


tempfile data
sort conspuma year
tsset conspuma year
save `data'


forv spec=1/`specnum' {
use `data', clear


*********************************************************
*3. Run regressions for each outcome
*********************************************************
reg v1 i.fips_state `Xcontrols`spec''  [aw=epop]
local df=e(df_r)

forv i=1/4{

	if `i'==5  {
	xi: reg v`i' tax i.fips_state `Xcontrols`spec'' [aw=epop]
	estimates store R`i'
	}
	
	else{ 
	
	xi: reg v`i' tax i.fips_state `Xcontrols`spec'' [aw=epop]
	estimates store R`i'
	}
	
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
	
		*add stars
		local b_I_W_tstat=r(estimate)/r(se)
		local b_I_W_df=`df'
		local b_I_W_pval=tprob(`b_I_W_df', abs(`b_I_W_tstat'))

		gen stars="" in 1
		replace stars="*" if (`b_I_W_pval'<=.1) & (`b_I_W_pval'>=.05) in 1
		replace stars="**" if (`b_I_W_pval'<=.05) & (`b_I_W_pval'>=.01) in 1
		replace stars="***" if (`b_I_W_pval'<.01) in 1
		local b_I_W=string(round(`b_I_W',.01))+stars[1]
		local se_I_W=string(round(`se_I_W',.01))
		drop stars

	disp "Incidence: Landowners"
	lincom _b[R3_mean:tax]
	local b_I_L=round(100*r(estimate))/100
	local se_I_L=round(100*r(se))/100
	
		*add stars
		local b_I_L_tstat=r(estimate)/r(se)
		local b_I_L_df=`df'
		local b_I_L_pval=tprob(`b_I_L_df', abs(`b_I_L_tstat'))

		gen stars="" in 1
		replace stars="*" if (`b_I_L_pval'<=.1) & (`b_I_L_pval'>=.05) in 1
		replace stars="**" if (`b_I_L_pval'<=.05) & (`b_I_L_pval'>=.01) in 1
		replace stars="***" if (`b_I_L_pval'<.01) in 1
		local b_I_L=string(round(`b_I_L',.01))+stars[1]
		local se_I_L=string(round(`se_I_L',.01))
		drop stars

	disp "Incidence: Firm Owners"
	nlcom  1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')
	matrix A=r(b)
	matrix B=r(V)
	local b_I_F= round(100*A[1,1])/100
	local se_I_F=round(100*B[1,1]^.5)/100
	
		*add stars
		local b_I_F_pval=2*ttail(`df',abs(`b_I_F'/`se_I_F'))
		
		gen stars="" in 1
		replace stars="*" if (`b_I_F_pval'<=.1) & (`b_I_F_pval'>=.05) in 1
		replace stars="**" if (`b_I_F_pval'<=.05) & (`b_I_F_pval'>=.01) in 1
		replace stars="***" if (`b_I_F_pval'<.01) in 1
		local b_I_F=string(round(`b_I_F',.01))+stars[1]
		local se_I_F=string(round(`se_I_F',.01))
		drop stars

	disp "Share of Incidence: Workers"
	nlcom (_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	matrix A=r(b)
	matrix B=r(V)
	local b_s_W=round(100*A[1,1])/100
	local se_s_W=round(100*B[1,1]^.5)/100
	disp  `b_s_W'
	
		*add stars
		local b_s_W_pval=2*ttail(`df',abs(`b_s_W'/`se_s_W'))
		
		gen stars="" in 1
		replace stars="*" if (`b_s_W_pval'<=.1) & (`b_s_W_pval'>=.05) in 1
		replace stars="**" if (`b_s_W_pval'<=.05) & (`b_s_W_pval'>=.01) in 1
		replace stars="***" if (`b_s_W_pval'<.01) in 1
		local b_s_W=string(round(`b_s_W',.01))+stars[1]
		local se_s_W=string(round(`se_s_W',.01))
		drop stars

	disp "Share of Incidence: Landowners"
	nlcom (_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	matrix A=r(b)
	matrix B=r(V)
	local b_s_L=round(100*A[1,1])/100
	local se_s_L=round(100*B[1,1]^.5)/100
	disp  `b_s_L'
	
		*add stars
		local b_s_L_pval=2*ttail(`df',abs(`b_s_L'/`se_s_L'))
		
		gen stars="" in 1
		replace stars="*" if (`b_s_L_pval'<=.1) & (`b_s_L_pval'>=.05) in 1
		replace stars="**" if (`b_s_L_pval'<=.05) & (`b_s_L_pval'>=.01) in 1
		replace stars="***" if (`b_s_L_pval'<.01) in 1
		local b_s_L=string(round(`b_s_L',.01))+stars[1]
		local se_s_L=string(round(`se_s_L',.01))
		drop stars

	disp "Share of Incidence: Firm Owners"
	nlcom ( 1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	matrix A=r(b)
	matrix B=r(V)
	local b_s_F=round(100*A[1,1])/100
	local se_s_F=round(100*B[1,1]^.5)/100
	
		*add stars
		local b_s_F_pval=2*ttail(`df',abs(`b_s_F'/`se_s_F'))
		
		gen stars="" in 1
		replace stars="*" if (`b_s_F_pval'<=.1) & (`b_s_F_pval'>=.05) in 1
		replace stars="**" if (`b_s_F_pval'<=.05) & (`b_s_F_pval'>=.01) in 1
		replace stars="***" if (`b_s_F_pval'<.01) in 1
		local b_s_F=string(round(`b_s_F',.01))+stars[1]
		local se_s_F=string(round(`se_s_F',.01))
		drop stars

	disp "Test Firm Owners Share =0 AND Workers share=100"
	testnl ((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )-1)=( 1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
	disp r(p)
	disp r(chi2)
	local ConventionalViewTest_p=round(100*r(p))/100
	local ConventionalViewTest_chi=round(100*r(chi2))/100



*********************************************************
*5. Column for Table
*********************************************************
	gen agent="Worker" in 1
	replace agent="Landowner" in 3
	replace agent="Firmowner" in 5

	replace agent="Worker Share" in 7
	replace agent="Landowner Share" in 9
	replace agent="Firmowner Share" in 11

	replace agent="W=100 and F=0 Chi2" in 13

	disp "`spec'"
	disp "``b_I_W'"
	gen b`spec'="`b_I_W'"  in 1
	replace b`spec'="`b_I_L'"  in 3
	replace b`spec'="`b_I_F'"  in 5
			
	replace b`spec'="(" + "`se_I_W'" + ")" in 2
	replace b`spec'="(" + "`se_I_L'" + ")" in 4
	replace b`spec'="(" + "`se_I_F'" + ")" in 6

	replace b`spec'= "`b_s_W'" in 7
	replace b`spec'= "`b_s_L'" in 9	
	replace b`spec'= "`b_s_F'" in 11

	replace b`spec'= "(" + "`se_s_W'" + ")" in 8
	replace b`spec'= "(" + "`se_s_L'" + ")" in 10
	replace b`spec'= "(" + "`se_s_F'" + ")" in 12

	replace b`spec'= "`ConventionalViewTest_chi'" in 13
	replace b`spec'= "`ConventionalViewTest_p'" in 14


	gen rowid=_n

	keep b`spec' agent rowid
	drop if rowid > 14
	drop agent
	sort rowid
	tempfile results_`spec'
	save `results_`spec''
}


*********************************************************
*6. Bring all specifications into one table
*********************************************************
use `results_1', clear
forv spec=2/`specnum' {
sort rowid
merge 1:1 rowid using `results_`spec''
tab _merge
drop _merge
}
gen agent="Workers $ \dot{w} - \alpha \dot{r}$" in 1
replace agent="Landowners $ \dot{r}$" in 3
replace agent="Firmowners $ \dot{\pi}$" in 5

replace agent="Worker Share" in 7
replace agent="Landowner Share" in 9
replace agent="Firmowner Share" in 11
replace agent="$ \chi^{2} $ of ($ S^{W} $ = 100\% and $ S^{F} $ = 0\%)" in 13

drop rowid
order agent b1 b2 b3 b4

listtex using "Appendix_Table23.tex", replace rstyle(tabular)
