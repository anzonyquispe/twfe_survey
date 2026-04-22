* Define the location of the main folder on your computer *
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\main-tables-figures"

**************************************************************************************************
* This do-file first creates the appendix tables for the paper: Table A4 - A10 *******************
**************************************************************************************************

**********************************************************
* REGRESSIONS FOR ONLINE APPENDIX: E - ADDITIONAL TABLES *
**********************************************************

********************************************************************************************************************
********************************************************************************************************************
*** Appendix Table A4: "Counterfactual Road Expenditure, Ethnicity and Democratic Change in Kenya, 1964-2002" ******
********************************************************************************************************************
********************************************************************************************************************

* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1) Panel A: counterfactual based on population only
xi: areg exp_dens_share_pop_6402 president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if year >= 1964 & year <= 2002, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_A4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: interaction, counterfactual based on population only
xi: areg exp_dens_share_pop_6402 president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if year >= 1964 & year <= 2002, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A: no interaction, counterfactual based on distance only
xi: areg exp_dens_share_dist president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypathtable_A4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: interaction, counterfactual based on distance only
xi: areg exp_dens_share_dist president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3) Panel A: no interaction, counterfactual based on population and distance
xi: areg exp_dens_share_mp_6402 president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if year >= 1964 & year <= 2002, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B: interaction, counterfactual based on population and distance
xi: areg exp_dens_share_mp_6402 president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if year >= 1964 & year <= 2002, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0


***********************************************************************************************************************************************
***********************************************************************************************************************************************
*** Appendix Table A5: "Road Expenditure, Ethnicity and Democratic Changes in Kenya: Robustness to Excluding Selected Districts, 1963-2011" ***
***********************************************************************************************************************************************
***********************************************************************************************************************************************
* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1) Panel A: no interaction, excluding White Highlands districts
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if highlands == 0, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: interaction, excluding White Highlands districts
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if highlands == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A : no interaction, excluding Nairobi and adjacent districts
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if nairobidist == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: interaction, excluding Nairobi and adjacent districts
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if nairobidist == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3) Panel A: no interaction, excluding districts on the Mombasa-Kampala corridor
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if MomKam == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B: interaction, excluding districts on the Mombasa-Kampala corridor
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if MomKam == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4) Panel A: no interaction, excluding districts on the Nairobi-Kampala highway
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if NaiKam == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (4) Panel B: interaction, excluding districts on the Nairobi-Kampala highway
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if NaiKam == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (5) Panel A: no interaction, excluding five richest districts in 1962
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if five_richest == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (5) Panel B: interaction, excluding five richest districts in 1962
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year if five_richest == 0, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0


*********************************************************************************
*********************************************************************************
*** Appendix Table A6: "Robustness Checks with Different Dependent Variables" ***
*********************************************************************************
*********************************************************************************
* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1) Panel A: no interaction, population share as the denominator
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: no interaction, population share as the denominator
xi: areg exp_dens_share presshare pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel A: interaction, population share as the denominator
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel B: interaction, population share as the denominator
xi: areg exp_dens_share presshare presshareMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare presshareMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test presshare + presshareMP = 0

* Column (3) Panel A: no interaction, area share as the denominator
xi: areg exp_dens_share2 president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B: no interaction, area share as the denominator
xi: areg exp_dens_share2 presshare pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (4) Panel A: interaction, area share as the denominator
xi: areg exp_dens_share2 president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4) Panel B: interaction, area share as the denominator
xi: areg exp_dens_share2 presshare presshareMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare presshareMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test presshare + presshareMP = 0

* We use the data set with paved road construction as the dependent variable
use "$mypath\kenya_roads_pav", clear

* Column (5) Panel A: no interaction, population share as the denominator
xi: areg change_paved_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (5) Panel B: no interaction, population share as the denominator
xi: areg change_paved_share presshare pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (6) Panel A: interaction, population share as the denominator
xi: areg change_paved_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (6) Panel B: interaction, population share as the denominator
xi: areg change_paved_share presshare presshareMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare presshareMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test presshare + presshareMP = 0

* Column (7) Panel A: no interaction, area share as the denominator
xi: areg change_paved_share2 president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (7) Panel B: no interaction, area share as the denominator
xi: areg change_paved_share2 presshare pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (8) Panel A: interaction, area share as the denominator
xi: areg change_paved_share2 president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (8) Panel B: interaction, area share as the denominator
xi: areg change_paved_share2 presshare presshareMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 presshare presshareMP using "$mypath\table_A6.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test presshare + presshareMP = 0


****************************************************************************
****************************************************************************
*** Appendix Table A7: "Robustness Checks with Different Specifications" ***
****************************************************************************
****************************************************************************
set matsize 800
* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear
* we launch the do-file that will allow us to estimate Conley standard errors
* source for the dof-file: Rappaport, Jordan (2007). "Moving to Nice Weather." Regional Science and Urban Economics 37, 3 (May), pp. 375-398
run "$mypath\gls_sptl.do"

* Column (1) Panel A: no interaction, Baseline Regression (Table 1, Column (4))
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A7.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: interaction, Baseline Regression (Table 1, Column (4))
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A7.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A: no interaction, controls interacted with year fixed effects
xi: areg exp_dens_share president i.year|pop1962 i.year|area i.year|urbrate1962 i.year|earnings i.year|wage_employment i.year|value_cashcrops i.MomKam*i.year i.border*i.year i.year|dist2nairobi i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A7.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: interaction, controls interacted with year fixed effects
xi: areg exp_dens_share president presidentMP multiparty i.year|pop1962 i.year|area i.year|urbrate1962 i.year|earnings i.year|wage_employment i.year|value_cashcrops i.MomKam*i.year i.border*i.year i.year|dist2nairobi i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A7.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3) Panel A: no interaction, control for number of year coethnic district
xi: areg exp_dens_share president president_yrs pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A7.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B: interaction, control for number of year coethnic district
xi: areg exp_dens_share president presidentMP president_yrs multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A7.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4) Panel A: no interaction, Conley standard errors (200 km)
* to create distnum and year dummies, as glssptl does not support dummies i.X*Y
xi: areg exp_dens_share i.distnum i.year, absorb(distnum)
gls_sptl exp_dens_share president: pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t MomKam_t border_t dist2nairobi_t _Idistnum_2-_Idistnum_41 _Iyear_1964-_Iyear_2011, sptlcoef(1) crdlst(centroidy centroidx) cut(200) 
* the coefficient and standard errors are inputed manually in the table from the output

* Column (4) Panel B: interaction, Conley standard errors (200 km)
gls_sptl exp_dens_share president presidentMP: pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t MomKam_t border_t dist2nairobi_t _Idistnum_2-_Idistnum_41 _Iyear_1964-_Iyear_2011, sptlcoef(1) crdlst(centroidy centroidx) cut(200) 
* the coefficient and standard errors are inputed manually in the table from the output
* the F-test is calculated manually

* Column (5) Panel A: no interaction, Conley standard errors (400 km)
gls_sptl exp_dens_share president: pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t MomKam_t border_t dist2nairobi_t _Idistnum_2-_Idistnum_41 _Iyear_1964-_Iyear_2011, sptlcoef(1) crdlst(centroidy centroidx) cut(400) 
* the coefficient and standard errors are inputed manually in the table from the output

* Column (5) Panel B: interaction, Conley standard errors (400 km)
gls_sptl exp_dens_share president presidentMP: pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t MomKam_t border_t dist2nairobi_t _Idistnum_2-_Idistnum_41 _Iyear_1964-_Iyear_2011, sptlcoef(1) crdlst(centroidy centroidx) cut(400) 
* the coefficient and standard errors are inputed manually in the table from the output
* the F-test is calculated manually


***********************************************************************************************************
***********************************************************************************************************
*** Appendix Table A8: "Road Expenditure, Democratic Change and Coalition Politics in Kenya, 1963-2011" ***
***********************************************************************************************************
***********************************************************************************************************
* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1): Baseline regression (Table 1, column (4))
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_A8.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace
test president + presidentMP = 0

* Column (2): swing effect for Kamba districts
xi: areg exp_dens_share president presidentMP kambaMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP kambaMP using "$mypath\table_A8.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3): swing effect for Luhya districts
xi: areg exp_dens_share president presidentMP luhyaMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP luhyaMP using "$mypath\table_A8.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4): swing effect for Luo districts
xi: areg exp_dens_share president presidentMP luoMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP luoMP using "$mypath\table_A8.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (5): swing effect in terms of margin of victory (difference in voting share between first party and second party in 1992 general elections)
xi: areg exp_dens_share president presidentMP margin_victoryMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP margin_victoryMP using "$mypath\table_A8.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (6): swing effect in terms of party competition herfindhal index 
xi: areg exp_dens_share president presidentMP votes_hh_indexMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP votes_hh_indexMP using "$mypath\table_A8.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

************************************************************************************
************************************************************************************
*** Appendix Table A9: "Kilometers of Paved Roads Constructed between 1964-2002" ***
************************************************************************************
************************************************************************************
* We use the data set with paved road construction as the dependent variable
use "$mypath\kenya_roads_pav", clear
collapse (sum) change_paved, by(year)
replace change_paved = round(change_paved,1)
* we export this table in excel manually 
export excel using "$mypath\table_A9.xls", firstrow(variables) replace

************************************************************************************************************************
************************************************************************************************************************
*** Appendix Table A10: "Kilometers of Paved Roads Constructed between 1964-2002 (Road Expediture Counterfactuals)" ****
************************************************************************************************************************
************************************************************************************************************************
use "$mypath\kenya_roads_exp", clear
keep if year >= 1964 & year <= 2002
collapse (sum) change_paved_exp_pop_6402, by(year)
gen change_paved = round(change_paved_exp_pop_6402,1)
drop change_paved_exp_pop_6402
* we export this table in excel manually 
export excel using "$mypath\table_A10.xls", firstrow(variables) replace

************************************************************************************************************************
************************************************************************************************************************
************************************************END OF DO FILE *********************************************************
************************************************************************************************************************
************************************************************************************************************************
