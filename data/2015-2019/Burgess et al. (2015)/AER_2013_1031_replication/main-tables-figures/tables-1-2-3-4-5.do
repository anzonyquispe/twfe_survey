* Define the location of the main folder on your computer *
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\main-tables-figures"

* In the "data-preparation-main-tables-figures" folder, we have used the dofile "data-preperation-main-tables-figures.do" to create the three data sets we use to run the main regressions for Kenya *
* - One data set (kenya_roads_exp) with road development expenditure as the dependent variable
* - One data set (kenya_roads_pav) with paved road construction as the dependent variable
* - One data set (kenya_roads_cabinet) with the cabinet share as the dependent variable

*******************************************************************************************
* This do-file first creates the main tables for the paper, table 1, 2, 3, 4, and 5 *******
*******************************************************************************************

*******************************************************************************************
*******************************************************************************************
*** Table 1: "Road Expenditure, Ethnicity and Democratic Change in Kenya, 1963-2011" ******
*******************************************************************************************
*******************************************************************************************

* This is the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1) Panel A: no interaction
xi: areg exp_dens_share president i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: interaction
xi: areg exp_dens_share president presidentMP  multiparty i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A: no interaction, + (Controls: Population, Area, Urbanization Rate)*trend
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: interaction, + (Controls: Population, Area, Urbanization Rate)*trend
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3) Panel A: no interaction, + (Additional Controls: Earnings, Employment, Cash Crops)*trend
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B : interaction, + (Additional Controls: Earnings, Employment, Cash Crops)*trend
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4) Panel A: no interaction, + (Additional Controls: Main Highway, Border, Dist. Nairobi)*trend
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (4) Panel B: interaction, + (Main Highway, Border, Dist. Nairobi)*trend
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (5) Panel A: no interaction, District time trends only
* we use xtreg to run this regression
* and use tsset to create the district and year fixed effects
tsset distnum year
xi: xtreg exp_dens_share president i.distnum*year, robust cluster(distnum) fe
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (5) Panel B: interaction, District time trends only
* we use xtreg to run this regression
* and use tsset to create the district and year fixed effects
tsset distnum year
xi: xtreg exp_dens_share president presidentMP multiparty i.distnum*year, robust cluster(distnum) fe
outreg2 president presidentMP using "$mypath\table_1.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

***************************************************************************************
***************************************************************************************
*** Table 2: "Road Building, Ethnicity and Democratic Change in Kenya, 1964-2002" *****
***************************************************************************************
***************************************************************************************

* We use the data set with paved road construction as the dependent variable *
use "$mypath\kenya_roads_pav", clear

* Column (1) Panel A: no interaction
xi: areg change_paved_share president i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: interaction
xi: areg change_paved_share president presidentMP  multiparty i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A: no interaction, + (Population, Area, Urbanization Rate)*trend
xi: areg change_paved_share president pop1962_t area_t urbrate1962_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: interaction, + (Population, Area, Urbanization Rate)*trend
xi: areg change_paved_share president presidentMP multiparty pop1962_t area_t urbrate1962_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3) Panel A: no interaction, + (Earnings, Employment, Cash Crops)*trend
xi: areg change_paved_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B : interaction, + (Earnings, Employment, Cash Crops)*trend
xi: areg change_paved_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4) Panel A: no interaction, + (Main Highway, Border, Dist. Nairobi)*trend
xi: areg change_paved_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (4) Panel B: interaction, + (Main Highway, Border, Dist. Nairobi)*trend
xi: areg change_paved_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (5) Panel A: no interaction, District time trends only
* we use xtreg to run this regression
* and use tsset to create the district and year fixed effects
tsset distnum year
xi: xtreg change_paved_share president i.distnum*year, robust cluster(distnum) fe
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (5) Panel B: interaction, District time trends only
* we use xtreg to run this regression
* and use tsset to create the district and year fixed effects
tsset distnum year
xi: xtreg change_paved_share president presidentMP multiparty i.distnum*year, robust cluster(distnum) fe
outreg2 president presidentMP using "$mypath\table_2.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

****************************************************************************************************
****************************************************************************************************
*** Table 3: "Counterfactual Road Building, Ethnicity and Democratic Changes in Kenya, 1964-2002 ***
****************************************************************************************************
****************************************************************************************************

* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_pav", clear

* Column (1) Panel A: counterfactual based on population only
xi: areg change_paved_sh_pop president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_3.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: counterfactual based on population only
xi: areg change_paved_sh_pop president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_3.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A: counterfactual based on distance only
xi: areg change_paved_sh_dist president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_3.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: counterfactual based on distance only
xi: areg change_paved_sh_dist president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_3.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (3) Panel A: counterfactual based on population and distance
xi: areg change_paved_sh_mp president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_3.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B: counterfactual based on population and distance
xi: areg change_paved_sh_mp president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_3.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

*******************************************************************************************************************************
*******************************************************************************************************************************
*** Table 4: "Road Expenditure, Ethnicity and Democratic Changes in Kenya: Political and Leadership Transitions, 1963-2011" *** 
*******************************************************************************************************************************
*******************************************************************************************************************************

* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1): Democracy 1963-1969
xi: areg exp_dens_share i.kikuyu i.kalenjin if year >= 1963 & year <= 1969, absorb(year) robust cluster(distnum)
outreg2 _Ikikuyu_1 _Ikalenjin_1 using "$mypath\table_4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace
test _Ikikuyu_1 = _Ikalenjin_1

* Column (2): Autocracy 1970-1978
xi: areg exp_dens_share i.kikuyu i.kalenjin if year >= 1970 & year <= 1978, absorb(year) robust cluster(distnum)
outreg2 _Ikikuyu_1 _Ikalenjin_1 using "$mypath\table_4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test _Ikikuyu_1 = _Ikalenjin_1

* Column (3): Autocracy 1979-1992
xi: areg exp_dens_share i.kikuyu i.kalenjin if year >= 1979 & year <= 1992, absorb(year) robust cluster(distnum)
outreg2 _Ikikuyu_1 _Ikalenjin_1 using "$mypath\table_4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test _Ikikuyu_1 = _Ikalenjin_1

* Column (4): Democracy 1993-2002
xi: areg exp_dens_share i.kikuyu i.kalenjin if year >= 1993 & year <= 2002, absorb(year) robust cluster(distnum)
outreg2 _Ikikuyu_1 _Ikalenjin_1 using "$mypath\table_4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test _Ikikuyu_1 = _Ikalenjin_1

* Column (5): Democracy 2003-2011
xi: areg exp_dens_share i.kikuyu i.kalenjin if year >= 2003, absorb(year) robust cluster(distnum)
outreg2 _Ikikuyu_1 _Ikalenjin_1 using "$mypath\table_4.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test _Ikikuyu_1 = _Ikalenjin_1

****************************************************************************************************
****************************************************************************************************
*** Table 5: "Role of the Vice-President, Cabinet Composition and Coalition Politics, 1963-2011" ***
****************************************************************************************************
****************************************************************************************************

* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (1) Panel A: no interaction, development expenditure
xi: areg exp_dens_share president pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) replace

* Column (1) Panel B: interaction, development expenditure
xi: areg exp_dens_share president presidentMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (2) Panel A: no interaction, development expenditure, + VP
xi: areg exp_dens_share president vp pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president vp using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (2) Panel B: interaction, development expenditure, + VP
xi: areg exp_dens_share president presidentMP vp vpMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP vp vpMP using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0
test vp + vpMP = 0

* We use the data set with the cabinet share as the dependent variable
use "$mypath\kenya_roads_cabinet", clear

* Column (3) Panel A: no interaction, cabinet share
xi: areg cabinet_index president i.year i.ethnic_group*year, absorb(ethnic_group) robust cluster(ethnic_group)
outreg2 president using "$mypath\table_5.xls", se nocons coefastr bdec(2) noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (3) Panel B: interaction, cabinet share
xi: areg cabinet_index president presidentMP i.year i.ethnic_group*year, absorb(ethnic_group) robust cluster(ethnic_group)
outreg2 president presidentMP using "$mypath\table_5.xls", se nocons coefastr bdec(2) noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (4) Panel A: no interaction, cabinet share, + VP
xi: areg cabinet_index president vp i.year i.ethnic_group*year, absorb(ethnic_group) robust cluster(ethnic_group)
outreg2 president vp using "$mypath\table_5.xls", se nocons coefastr bdec(2) noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (4) Panel B: interaction, cabinet share, + VP
xi: areg cabinet_index president presidentMP vp vpMP i.year i.ethnic_group*year, absorb(ethnic_group) robust cluster(ethnic_group)
outreg2 president presidentMP vp vpMP using "$mypath\table_5.xls", se nocons coefastr bdec(2) noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0
test vp + vpMP == 0

* We use the data set with road development expenditure as the dependent variable
use "$mypath\kenya_roads_exp", clear

* Column (5) Panel A: no interaction, development expenditure, + Kamba-Luhya-Luo 
xi: areg exp_dens_share president vp pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president vp using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (5) Panel B: no interaction, development expenditure, + Kamba-Luhya-Luo
xi: areg exp_dens_share president presidentMP kllMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP kllMP using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0

* Column (6) Panel A: no interaction, development expenditure, + swing district
xi: areg exp_dens_share president vp pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president vp using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append

* Column (6) Panel B: no interaction, development expenditure, + swing district
xi: areg exp_dens_share president presidentMP swing swingMP multiparty pop1962_t area_t urbrate1962_t earnings_t wage_employment_t value_cashcrops_t i.MomKam|year i.border|year dist2nairobi_t i.year, absorb(distnum) robust cluster(distnum)
outreg2 president presidentMP swing swingMP using "$mypath\table_5.xls", se nocons coefastr bdec(2) adjr2 noni nolabel bracket title(Effect, "") nonotes addnote("", Robust standard errors clustered at the district level in parentheses, * significant at 10%; ** significant at 5%; *** significant at 1%) append
test president + presidentMP = 0


************************************************************************************************************************
************************************************************************************************************************
************************************************END OF DO FILE *********************************************************
************************************************************************************************************************
************************************************************************************************************************
