clear
set more off

use "$dtapath/Tables/Appendix_Table30.dta"

*Parameter values (base) :
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
*g tax= d_corp_orig




/*****************************/
/* Specifications for levels */
/*****************************/
local specnum=16
/* local Xcontrols1 = "GovParty_D GovParty_I GovParty_R  i.year i.fe_group"
local Xcontrols2 = "throwback combined i.year i.fe_group"
local Xcontrols3 = "SalesTaxRate i.year i.fe_group"
local Xcontrols4 = "DSalesTaxRate i.year i.fe_group"
local Xcontrols5 = "income_rate_fam i.year i.fe_group"
local Xcontrols6 = "Dincome_rate_fam i.year i.fe_group"
local Xcontrols7 = "dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols8 = "rev_corptax_gdp i.year i.fe_group"
local Xcontrols9 = "rev_corptax_gdp dtotalexpenditure_pop i.year i.fe_group"
local Xcontrols10 = "bartik i.year i.fe_group"
local Xcontrols11 = "i.deduct i.year i.fe_group"
local Xcontrols12 = "i.grt i.year i.fe_group" */
local Xcontrols13 = "taxratesales i.year i.fe_group"
local Xcontrols14 = "esrate_agg_post i.year i.fips_state"
local Xcontrols15 = "proptax i.year i.fe_group"
local Xcontrols16 = "taxratesales esrate_agg_post proptax i.year i.fe_group"


tempfile data
sort conspuma year
tsset conspuma year
save `data'

forv spec=13/`specnum' {
use `data', clear

*********************************************************
* Drop states for robustness test
*********************************************************
*drop if stateabbrev=="TX"
*drop if stateabbrev=="OH"
*drop if stateabbrev=="MI"
*drop if stateabbrev=="AK"

*********************************************************
* Run regressions for each outcome
*********************************************************
forv i=1/4{
xi: reg v`i' tax `Xcontrols`spec''  [aw=epop]
estimates store R`i'
}
suest R1 R2 R3 R4 , vce(cluster fips_state)

*********************************************************
* Point Estimates and Shares
*********************************************************
disp "Point Estimates for " `spec' " "

gen stars = ""


disp "Incidence: Workers"
lincom _b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]
local b_I_W=round(100*r(estimate))/100
local se_I_W=round(100*r(se))/100
local z_I_W = round(100*(`b_I_W'/`se_I_W'))/100

disp "Incidence: Landowners"
lincom _b[R3_mean:tax]
local b_I_L=round(100*r(estimate))/100
local se_I_L=round(100*r(se))/100
local z_I_L = round(100*(`b_I_L'/`se_I_L'))/100

disp "Incidence: Firm Owners"
nlcom  1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')
matrix A=r(b)
matrix B=r(V)
local b_I_F=round(100*A[1,1])/100
local se_I_F=round(100*(B[1,1]^.5))/100
local z_I_F = round(100*(`b_I_F'/`se_I_F'))/100

disp "Share of Incidence: Workers"
nlcom (_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
matrix A=r(b)
matrix B=r(V)
local b_s_W=round(100*A[1,1])/100
local se_s_W=round(100*(B[1,1]^.5))/100
local z_s_W = round(100*(`b_s_W'/`se_s_W'))/100

disp "Share of Incidence: Landowners"
nlcom (_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
matrix A=r(b)
matrix B=r(V)
local b_s_L=round(100*A[1,1])/100
local se_s_L=round(100*(B[1,1]^.5))/100
local z_s_L = round(100*(`b_s_L'/`se_s_L'))/100

disp "Share of Incidence: Firm Owners"
nlcom ( 1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
matrix A = r(b)
matrix B = r(V)
local b_s_F = round(100*A[1,1])/100
local se_s_F = round(100*(B[1,1]^.5))/100
local z_s_F = round(100*(`b_s_F'/`se_s_F'))/100

disp "Test Firm Owners Share =0 AND Workers share=100"
testnl ((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax]) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )-1)=( 1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) /((_b[R1_mean:tax] -`alpha'*_b[R3_mean:tax])+(_b[R3_mean:tax])+(1+ (((_b[R2_mean:tax]-_b[R4_mean:tax])/(_b[R1_mean:tax]))+1)*(_b[R1_mean:tax]-`delta_gamma')) )
disp r(p)
disp r(chi2)
local ConventionalViewTest_p=round(10*r(p))/10
local ConventionalViewTest_chi=round(10*r(chi2))/10

drop stars

*********************************************************
* Column for Table
*********************************************************
gen agent="Workers $ \dot{w} - \alpha \dot{r}$" in 1
replace agent="Landowners $ \dot{r}$" in 3
replace agent="Firmowners $ \dot{\pi}$" in 5

replace agent="Worker Share" in 7
replace agent="Landowner Share" in 9
replace agent="Firmowner Share" in 11
replace agent="$ \chi^{2} $ of ($ S^{W} $ = 100\% and $ S^{F} $ = 0\%)" in 13

gen b`spec' = ""

replace b`spec'=string(`b_I_W')  in 1
replace b`spec'=string(`b_I_L')  in 3
replace b`spec'=string(`b_I_F')  in 5

gen stars = ""

replace b`spec'=string(`se_I_W')  in 2
replace stars="*" if (`z_I_W'>=1.65) & (`z_I_W'<=1.96) in 1
replace stars="**" if (`z_I_W'>=1.96) & (`z_I_W'<=2.58) in 1
replace stars="***" if (`z_I_W'> 2.58) in 1
replace stars = "" if (`z_I_W'<1.65) in 1
replace b`spec' = b`spec'[1] + stars[1] in 1
replace b`spec' = "(" + b`spec'[2] + ")" in 2


replace b`spec'=string(`se_I_L')  in 4
replace stars="*" if (`z_I_L'>=1.65) & (`z_I_L'<=1.96) in 3
replace stars="**" if (`z_I_L'>=1.96) & (`z_I_L'<=2.58) in 3
replace stars="***" if (`z_I_L'> 2.58) in 3
replace stars = "" if (`z_I_L'<1.65) in 3
replace b`spec' = b`spec'[3] + stars[3] in 3
replace b`spec' = "(" + b`spec'[4] + ")" in 4

replace b`spec'=string(`se_I_F')  in 6
replace stars="*" if (`z_I_F'>=1.65) & (`z_I_F'<=1.96) in 5
replace stars="**" if (`z_I_F'>=1.96) & (`z_I_F'<=2.58) in 5
replace stars="***" if (`z_I_F'> 2.58) in 5
replace stars = "" if (`z_I_F'<1.65) in 5
replace b`spec' = b`spec'[5] + stars[5] in 5
replace b`spec' = "(" + b`spec'[6] + ")" in 6

replace b`spec'=string(`b_s_W')  in 7
replace b`spec'=string(`b_s_L')  in 9
replace b`spec'=string(`b_s_F')  in 11

replace b`spec'=string(`se_s_W')  in 8
replace stars="*" if (`z_s_W'>=1.65) & (`z_s_W'<=1.96) in 7
replace stars="**" if (`z_s_W'>=1.96) & (`z_s_W'<=2.58) in 7
replace stars="***" if (`z_s_W'> 2.58) in 7
replace stars = "" if (`z_s_W'<1.65) in 7
replace b`spec' = b`spec'[7] + stars[7] in 7
replace b`spec' = "(" + b`spec'[8] + ")" in 8

replace b`spec'=string(`se_s_L')  in 10
replace stars="*" if (`z_s_L'>=1.65) & (`z_s_L'<=1.96) in 9
replace stars="**" if (`z_s_L'>=1.96) & (`z_s_L'<=2.58) in 9
replace stars="***" if (`z_s_L'> 2.58) in 9
replace stars = "" if (`z_s_L'<1.65) in 9
replace b`spec' = b`spec'[9] + stars[9] in 9
replace b`spec' = "(" + b`spec'[10] + ")" in 10

replace b`spec'=string(`se_s_F')  in 12
replace stars="*" if (`z_s_F'>=1.65) & (`z_s_F'<=1.96) in 11
replace stars="**" if (`z_s_F'>=1.96) & (`z_s_F'<=2.58) in 11
replace stars="***" if (`z_s_F'> 2.58) in 11
replace stars = "" if (`z_s_F'<1.65) in 11
replace b`spec' = b`spec'[11] + stars[11] in 11
replace b`spec' = "(" + b`spec'[12] + ")" in 12


replace b`spec'=string(`ConventionalViewTest_chi') in 13
replace b`spec'=string(`ConventionalViewTest_p') in 14

gen rowid=_n

keep b`spec' agent rowid
drop if b`spec'== ""
drop agent
sort rowid
tempfile results1_`spec'
save `results1_`spec''

}


*********************************************************
* Bring all specifications into one table
*********************************************************
use `results1_13', clear
forv spec=14/`specnum' {
sort rowid
merge 1:1 rowid using `results1_`spec''
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
order agent b13 b14 b15 b16

listtex using "Appendix_Table30.tex", replace rstyle(tabular)



