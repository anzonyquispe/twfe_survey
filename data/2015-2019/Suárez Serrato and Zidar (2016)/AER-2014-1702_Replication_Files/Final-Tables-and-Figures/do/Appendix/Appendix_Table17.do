clear
set more off
local tablename="Appendix_Table17"

set seed 10


*********************************************************
*********************************************************
*0. PROGRAM to make one column of incidence table
*********************************************************
*********************************************************

capture program drop RFincidence

program RFincidence
syntax, tax(varname) alpha(real) delta_gamma(real) spec(real) gamma(real) epd(real) y4(varname)

use "$dtapath/Tables/Appendix_Table17.dta", clear

*********************************************************
*1. Select LHS and RHS variables
*********************************************************
******************
* LHS VARIABLES 
*****************

g y1 = dadjlwage
g y2 = dpop
g y3 = dadjlrent
g y4 = `y4'
******************
* RHS VARIABLES 
*****************
*`tax'
******************
* Specifications
*****************
local Xcontrols1  = "i.year i.fe_group"
local Xcontrols2  = "i.year i.fe_group"
local Xcontrols3  = "i.year i.fe_group"
local Xcontrols4  = "bartik i.year i.fe_group"
local Xcontrols5  = "bartik d_esrate i.year i.fe_group"
local Xcontrols6  = "i.year i.fe_group"

*********************************************************
*2. Run regressions for each outcome
*********************************************************
reg y1 `Xcontrols`spec''  [aw=epop]
local df=e(df_r)

forv i=1/4{

	if `i'==5  {
	xi: reg y`i' `tax' `Xcontrols`spec'' [aw=epop]
	estimates store R`i'
	}
	
	else{ 
	
	xi: reg y`i' `tax' `Xcontrols`spec'' [aw=epop]
	estimates store R`i'
	}
	
}
suest R1 R2 R3 R4 , vce(cluster fips_state)


*********************************************************
*3. Point Estimates and Shares
*********************************************************
disp "Point Estimates"

disp "Incidence: Workers"
lincom _b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax']
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
lincom _b[R3_mean:`tax']
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
nlcom  1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')
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
nlcom (_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax']) /((_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax'])+(_b[R3_mean:`tax'])+(1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) )
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
nlcom (_b[R3_mean:`tax']) /((_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax'])+(_b[R3_mean:`tax'])+(1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) )
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
nlcom ( 1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) /((_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax'])+(_b[R3_mean:`tax'])+(1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) )
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
testnl ((_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax']) /((_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax'])+(_b[R3_mean:`tax'])+(1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) )-1)=( 1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) /((_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax'])+(_b[R3_mean:`tax'])+(1+ (((_b[R2_mean:`tax']-_b[R4_mean:`tax'])/(_b[R1_mean:`tax']))+1)*(_b[R1_mean:`tax']-`delta_gamma')) )
disp r(p)
disp r(chi2)
local ConventionalViewTest_p=string(round(100*r(p))/100)
local ConventionalViewTest_chi=string(round(100*r(chi2))/100)

disp "Test Beta_E=Beta_N - [gamma(epd+1) -1]Beta_W"
test _b[R4_mean:`tax']=_b[R2_mean:`tax']-(`gamma'*(`epd'+1)-1)*_b[R1_mean:`tax']
disp r(p)
disp r(F)

local RestrictionTest_p=string(round(100*r(p))/100)
local RestrictionTest_F=string(round(100*r(F))/100)

disp "sigmaW"
nlcom  (_b[R1_mean:`tax'] -`alpha'*_b[R3_mean:`tax'])/_b[R2_mean:`tax']
matrix A=r(b)
matrix B=r(V)
local sigmaW= round(100*A[1,1])/100
local se_sigmaW=round(100*B[1,1]^.5)/100

		*add stars
		local sigmaW_pval=2*ttail(`df',abs(`sigmaW'/`se_sigmaW'))
		
		gen stars="" in 1
		replace stars="*" if (`sigmaW_pval'<=.1) & (`sigmaW_pval'>=.05) in 1
		replace stars="**" if (`sigmaW_pval'<=.05) & (`sigmaW_pval'>=.01) in 1
		replace stars="***" if (`sigmaW_pval'<.01) in 1
		local sigmaW=string(round(`sigmaW',.01))+stars[1]
		local se_sigmaW=string(round(`se_sigmaW',.01))
		drop stars
		
disp "sigmaF"
nlcom  `gamma'*(_b[R1_mean:`tax']/_b[R4_mean:`tax'])*(1/(_b[R4_mean:`tax']-_b[R2_mean:`tax']-_b[R1_mean:`tax']) -1)
matrix A=r(b)
matrix B=r(V)
local sigmaF= round(100*A[1,1])/100
local se_sigmaF=round(100*B[1,1]^.5)/100

		*add stars
		local sigmaF_pval=2*ttail(`df',abs(`sigmaF'/`se_sigmaF'))
		
		gen stars="" in 1
		replace stars="*" if (`sigmaF_pval'<=.1) & (`sigmaF_pval'>=.05) in 1
		replace stars="**" if (`sigmaF_pval'<=.05) & (`sigmaF_pval'>=.01) in 1
		replace stars="***" if (`sigmaF_pval'<.01) in 1
		local sigmaF=string(round(`sigmaF',.01))+stars[1]
		local se_sigmaF=string(round(`se_sigmaF',.01))
		drop stars	

disp "eta"
nlcom  (_b[R2_mean:`tax']+_b[R1_mean:`tax'])/_b[R3_mean:`tax']
matrix A=r(b)
matrix B=r(V)
local eta= round(100*A[1,1])/100
local se_eta=round(100*B[1,1]^.5)/100

		*add stars
		local eta_pval=2*ttail(`df',abs(`eta'/`se_eta'))
		
		gen stars="" in 1
		replace stars="*" if (`eta_pval'<=.1) & (`eta_pval'>=.05) in 1
		replace stars="**" if (`eta_pval'<=.05) & (`eta_pval'>=.01) in 1
		replace stars="***" if (`eta_pval'<.01) in 1
		local eta=string(round(`eta',.01))+stars[1]
		local se_eta=string(round(`se_eta',.01))
		drop stars	
		
disp "epd"
nlcom  (_b[R2_mean:`tax']+_b[R1_mean:`tax']-_b[R4_mean:`tax'])/(`gamma'*_b[R1_mean:`tax'])
matrix A=r(b)
matrix B=r(V)
local epd= round(100*A[1,1])/100
local se_epd=round(100*B[1,1]^.5)/100

		*add stars
		local epd_pval=2*ttail(`df',abs(`epd'/`se_epd'))
		
		gen stars="" in 1
		replace stars="*" if (`epd_pval'<=.1) & (`epd_pval'>=.05) in 1
		replace stars="**" if (`epd_pval'<=.05) & (`epd_pval'>=.01) in 1
		replace stars="***" if (`epd_pval'<.01) in 1
		local epd=string(round(`epd',.01))+stars[1]
		local se_epd=string(round(`se_epd',.01))
		drop stars			

*check RF coefficients
lincom _b[R1_mean:`tax']		
local betaW=string(round(100*r(estimate))/100)
local se_betaW=string(round(100*r(se))/100)

lincom _b[R2_mean:`tax']		
local betaN=string(round(100*r(estimate))/100)
local se_betaN=string(round(100*r(se))/100)

lincom _b[R3_mean:`tax']		
local betaR=string(round(100*r(estimate))/100)
local se_betaR=string(round(100*r(se))/100)

lincom _b[R4_mean:`tax']		
local betaE=string(round(100*r(estimate))/100)
local se_betaE=string(round(100*r(se))/100)				
		
*********************************************************
*4. Columns for Table
*********************************************************
gen agent="Workers" in 1
replace agent="Landowners" in 3
replace agent="Firmowners" in 5

replace agent="SE Workers" in 2
replace agent="SE Landowners" in 4
replace agent="SE Firmowners" in 6

replace agent="W=100 and F=0 Chi2" in 7
replace agent="Beta_E is Beta_N - (gamma(epd+1) -1)Beta_W" in 9

disp "`spec'"
disp "``b_I_W'"
gen b`spec'="`b_I_W'"  in 1
replace b`spec'="`b_I_L'"  in 3
replace b`spec'="`b_I_F'"  in 5

replace b`spec'="(" + "`se_I_W'" + ")" in 2
replace b`spec'="(" + "`se_I_L'" + ")" in 4
replace b`spec'="(" + "`se_I_F'" + ")" in 6

gen Share`spec'="`b_s_W'" in 1
replace Share`spec'="`b_s_L'" in 3
replace Share`spec'="`b_s_F'" in 5

replace Share`spec'="(" + "`se_s_W'" + ")" in 2
replace Share`spec'="(" + "`se_s_L'" + ")" in 4
replace Share`spec'="(" + "`se_s_F'" + ")" in 6

replace Share`spec'="`ConventionalViewTest_chi'" in 7
replace Share`spec'="`ConventionalViewTest_p'" in 8
replace Share`spec'="`RestrictionTest_F'" in 9
replace Share`spec'="`RestrictionTest_p'" in 10

gen param="Preference Dispersion $\sigma_W $"  in 1
replace param="Productivity Dispersion $\sigma_F $"  in 3
replace param="Housing Supply $ \eta $"  in 5
replace param="Product Demand $\varepsilon^{PD} $"  in 7

gen param`spec'="`sigmaW'"  in 1
replace param`spec'="`sigmaF'"  in 3
replace param`spec'="`eta'"  in 5
replace param`spec'="`epd'"  in 7

replace param`spec'="(" + "`se_sigmaW'" + ")" in 2
replace param`spec'="(" + "`se_sigmaF'" + ")" in 4
replace param`spec'="(" + "`se_eta'" + ")" in 6
replace param`spec'="(" + "`se_epd'" + ")" in 8

gen beta="W"  in 1
replace beta="N"  in 3
replace beta="R"  in 5
replace beta="E"  in 7

gen beta`spec'="`betaW'"  in 1
replace beta`spec'="`betaN'"  in 3
replace beta`spec'="`betaR'"  in 5
replace beta`spec'="`betaE'"  in 7

replace beta`spec'="(" + "`se_betaW'" + ")" in 2
replace beta`spec'="(" + "`se_betaN'" + ")" in 4
replace beta`spec'="(" + "`se_betaR'" + ")" in 6
replace beta`spec'="(" + "`se_betaE'" + ")" in 8

gen rowid=_n
gen blankspace = . /*Kept for automatic formatting with listtex (for table 4 of paper)*/

keep b`spec' agent rowid Share`spec' param param`spec' beta beta`spec' blankspace
drop if Share`spec'==""
drop agent
sort rowid
save "$dumppath/results_`spec'.dta", replace

foreach outcome in W N R E{
disp "`outcome'"
disp "`beta`outcome''"
}

use "$dtapath/Tables/Appendix_Table17.dta", clear

end


use "$dtapath/Tables/Appendix_Table17.dta", clear

*********************************************************
*********************************************************
*0.EXECUTE PROGRAM to make incidence table
*********************************************************
*********************************************************
set more off
*note that gamma is only used for panel c outcomes (i.e., the structural parameter estimates)
*note that epd is only used for paramter restriction test

*note that est_nets is the single state share times dest

RFincidence, tax(d_bus_dom2) alpha(.3)  delta_gamma(.9) spec(1) gamma(.15) epd(-2.5) y4(dest_nets)
RFincidence, tax(d_bus_dom2) alpha(.65)  delta_gamma(.9) spec(2) gamma(.15) epd(-2.5) y4(dest_nets)
RFincidence, tax(d_bus_dom2) alpha(.3)  delta_gamma(.5) spec(3) gamma(.15) epd(-2.5) y4(dest_nets)
RFincidence, tax(d_bus_dom2) alpha(.3)  delta_gamma(.9) spec(4) gamma(.15) epd(-2.5) y4(dest_nets)
RFincidence, tax(d_bus_dom2) alpha(.3)  delta_gamma(.9) spec(5) gamma(.15) epd(-2.5) y4(dest_nets)
RFincidence, tax(d_corp_orig) alpha(.3)  delta_gamma(.9) spec(6) gamma(.15) epd(-2.5) y4(dest_nets)

*********************************************************
*Bring all specifications into one table
*********************************************************
local specnum=6
		use "$dumppath/results_1.dta", clear
		forv spec=2/`specnum'{
			sort rowid
			merge 1:1 rowid using "$dumppath/results_`spec'.dta"
			tab _merge
			drop _merge
		}
		gen agent="Workers" in 1
		replace agent="" in 2
		replace agent="Landowners" in 3
		replace agent="" in 4
		replace agent="Firmowners" in 5
		replace agent="" in 6
	    *replace agent="$ \chi^{2} $ of ($ S^{W} $ = 100\% and $ S^{F} $ = 0\%)" in 7
		replace agent="$ \chi^{2} $" in 7		
		replace agent = "P-value" in 8
		replace agent="$ \Beta_E = \Beta_N - (\gamma(\varepsilon^{PD}+1) -1) \Beta_W $" in 9	
		replace agent = "P-value" in 10	
*put landowners first
g new_rowid=rowid
replace new_rowid=1 if rowid==3
replace new_rowid=2 if rowid==4
replace new_rowid=3 if rowid==1
replace new_rowid=4 if rowid==2
sort new_rowid		
		drop rowid new_rowid
		order agent b1 b2 b3 b4 b5 b6  ///
		blankspace Share1 Share2 Share3 Share4 Share* ///
		param param1 param2 param3 param4 param* ///
		beta beta1 beta2 beta3 beta4 beta*
		
		keep b1-b6 Share1-Share6 blankspace
		
		listtex if inrange(_n,1,10) using "`tablename'.tex", replace rstyle(tabular)
		
		*drop blankspace
		
		tempfile results
		save `results'
	
