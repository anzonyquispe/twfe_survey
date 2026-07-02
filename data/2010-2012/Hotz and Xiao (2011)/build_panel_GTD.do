/*
  Hotz and Xiao (2011) - "The Role of Minimum Quality Standards in the Child Care Market"
  State-level Panel GTD Construction (Nonemployer Analysis)

  Using PUBLIC data from replication package:
  - reg.dta (state-level childcare regulations by year)
  - nonemp_st_w1987.dta (nonemployer establishment counts by state-year)
  - c1987_state_clean.dta, c1992_state_clean.dta, c1997_state_clean.dta (demographics)

  TWFE specification from nonemployer_analysis.do:
  areg Y scrat educ [controls] year1992 year1997, absorb(num_st) cluster(year_st)
*/

clear all
set more off

local regdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Hotz and Xiao (2011)/Hotz_Xiao_20051172_data_programs/data/Regulation_data"
local nempdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Hotz and Xiao (2011)/Hotz_Xiao_20051172_data_programs/data/Childcare_nonemployer_data"
local outdir   "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Hotz and Xiao (2011)"

log using "`outdir'/build_panel_GTD.log", replace

* ============================================================================
* STEP 0: Describe key datasets
* ============================================================================

di "=== DESCRIBING reg.dta ==="
use "`regdir'/reg.dta", clear
describe
list state year edddc edtdc edadc rat0dc rat1dc inspdc visitdc crimdc aiddc in 1/10

di "=== DESCRIBING nonemp_st_w1987.dta ==="
use "`nempdir'/nonemp_st_w1987.dta", clear
describe
list in 1/10

di "=== DESCRIBING c1987_state_clean.dta ==="
use "`nempdir'/c1987_state_clean.dta", clear
describe
list in 1/5

di "=== DESCRIBING c1992_state_clean.dta ==="
use "`nempdir'/c1992_state_clean.dta", clear
describe
list in 1/5

di "=== DESCRIBING c1997_state_clean.dta ==="
use "`nempdir'/c1997_state_clean.dta", clear
describe
list in 1/5

* ============================================================================
* STEP 1: Process regulation data (from nonemployer_analysis.do lines 23-103)
* ============================================================================

use "`regdir'/reg.dta", clear
rename state st

* Fix year coding
forvalues y=83/96 {
	replace year=19`y' if year==`y'
}
replace year=1997 if year==1996
replace year=1987 if year==1986 & st=="WA"

* Keep only the 3 Census years
keep if year==1987 | year==1992 | year==1997
drop if st=="CWLA"
sort st year

* Fill in WA 1987 from Aizer data
replace edddc=0 if year==1987 & st=="WA"
replace edtdc=0 if year==1987 & st=="WA"
replace edadc=0 if year==1987 & st=="WA"
replace rat0dc=4 if year==1987 & st=="WA"
replace rat1dc=7 if year==1987 & st=="WA"
replace rat2dc=10 if year==1987 & st=="WA"
replace rat3dc=10 if year==1987 & st=="WA"
replace rat4dc=10 if year==1987 & st=="WA"
replace rat5dc=10 if year==1987 & st=="WA"

* Construct staff-child ratio index (D variable #1)
foreach i of numlist 0(1)5 {
	replace rat`i'dc=. if rat`i'dc==99
	gen scrat`i'dc=0 if rat`i'dc==.
	replace scrat`i'dc=1/rat`i'dc if rat`i'dc!=.
}
gen scrat=(scrat0dc+scrat1dc+scrat2dc+scrat3dc+scrat4dc+scrat5dc)/6
gen no_scrat=(scrat==0)
gen no_scrat0dc=(scrat0dc==0)

* Construct education index (D variable #2)
replace edddc=0 if edddc==.
replace edtdc=0 if edtdc==.
replace edadc=0 if edadc==.
gen educ=(edddc+edtdc)/2
gen no_educ=(educ==0)
gen no_edddc=(edddc==0)

* Additional MQS variables
replace inspdc=0 if inspdc==.
replace visitdc=0 if visitdc==.
replace crimdc=0 if crimdc==.
replace aiddc=0 if aiddc==.
replace cdhrsddc=0 if cdhrsddc==.
replace cdhrsddc=cdhrsddc/100
replace expddc=0 if expddc==.
replace ongoddc=0 if ongoddc==.
replace ongohddc=0 if ongohddc==.
replace cdhrstdc=0 if cdhrstdc==.
replace cdhrstdc=cdhrstdc/100

* Time dummies
gen year1992=(year==1992)
gen year1997=(year==1997)

save "`outdir'/reg_processed.dta", replace

* ============================================================================
* STEP 2: Merge with nonemployer data (Y variables)
* ============================================================================

use "`nempdir'/nonemp_st_w1987.dta", clear
keep estab ecvalue year state num_st
rename state st
sort st year

merge st year using "`outdir'/reg_processed.dta"
drop if _merge==2
drop _merge

* ============================================================================
* STEP 3: Merge demographics (control variables)
* ============================================================================

sort num_st year
merge num_st year using "`nempdir'/c1987_state_clean.dta"
drop if _merge==2
drop _merge

sort num_st year
merge num_st year using "`nempdir'/c1992_state_clean.dta", update
drop if _merge==2
drop _merge

sort num_st year
merge num_st year using "`nempdir'/c1997_state_clean.dta", update
drop if _merge==2
drop _merge

* ============================================================================
* STEP 4: Generate analysis variables (from nonemployer_analysis.do)
* ============================================================================

* Scale establishment count
replace estab=estab/1000

* Y variable: establishments per under-5 population
gen estab_over_under5=estab/(under5/1000)

* CPI adjustment for economic value
scalar cpi97 = 160.5
scalar cpi92 = 140.3
scalar cpi87 = 113.6
replace ecvalue=ecvalue*cpi97/cpi87 if year==1987
replace ecvalue=ecvalue*cpi97/cpi92 if year==1992
replace ecvalue=ecvalue*cpi97/cpi97 if year==1997
replace ecvalue=ecvalue/1000
gen ecvalue_per_estab=ecvalue/estab

* Demographic controls (scaled as in original code)
gen ln_m_inc=m_income/1000
gen ln_under5=under5/1000
gen pct_child=under5/pop

* MQS interactions with income
gen scrat_incm=scrat*ln_m_inc
gen no_scrat_incm=no_scrat*ln_m_inc
gen educ_incm=educ*ln_m_inc
gen no_educ_incm=no_educ*ln_m_inc
gen scrat0dc_incm=scrat0dc*ln_m_inc
gen no_scrat0dc_incm=no_scrat0dc*ln_m_inc
gen edddc_incm=edddc*ln_m_inc
gen no_edddc_incm=no_edddc*ln_m_inc

* MQS interactions with poverty
gen scrat_pvty=scrat*pct_pvty
gen no_scrat_pvty=no_scrat*pct_pvty
gen educ_pvty=educ*pct_pvty
gen no_educ_pvty=no_educ*pct_pvty
gen scrat0dc_pvty=scrat0dc*pct_pvty
gen no_scrat0dc_pvty=no_scrat0dc*pct_pvty
gen edddc_pvty=edddc*pct_pvty
gen no_edddc_pvty=no_edddc*pct_pvty

* Clustering variable
gen year_st=year+0.01*num_st

* ============================================================================
* STEP 5: Create panel_GTD.dta with clear labels
* ============================================================================

* Label key variables for the TWFE survey
label var num_st      "G: State identifier"
label var year        "T: Year (1987, 1992, 1997)"
label var year1992    "T: Year 1992 dummy"
label var year1997    "T: Year 1997 dummy"
label var scrat       "D: Staff-child ratio index (avg across age groups)"
label var educ        "D: Education requirement index (avg director+teacher)"
label var no_scrat    "D: No staff-child ratio requirement (dummy)"
label var no_educ     "D: No education requirement (dummy)"
label var scrat0dc    "D: Staff-child ratio for age 0-11 months"
label var edddc       "D: Education required for director (years)"
label var inspdc      "D: Number of annual inspections"
label var visitdc     "D: Parental free access required (dummy)"
label var aiddc       "D: First-aid certification required (dummy)"
label var crimdc      "D: Criminal background check required (dummy)"
label var estab       "Y: Number of nonemployer establishments (1000s)"
label var estab_over_under5 "Y: Establishments per under-5 population"
label var ecvalue     "Y: Economic value of establishments (CPI-adj, 1000s)"
label var ecvalue_per_estab "Y: Economic value per establishment"
label var st          "State abbreviation"

* Keep relevant variables
keep num_st st year year1992 year1997 year_st ///
     scrat no_scrat educ no_educ scrat0dc no_scrat0dc edddc no_edddc ///
     inspdc visitdc aiddc crimdc cdhrsddc expddc ongoddc ongohddc ///
     estab estab_over_under5 ecvalue ecvalue_per_estab ///
     pct_black pct_hisp hh_size ln_m_inc college ln_under5 ///
     pct_fh_c pct_f_nwork pct_unemploy pct_whome long_comm pct_rural pct_pvty ///
     scrat_incm no_scrat_incm educ_incm no_educ_incm ///
     scrat0dc_incm no_scrat0dc_incm edddc_incm no_edddc_incm ///
     scrat_pvty no_scrat_pvty educ_pvty no_educ_pvty ///
     scrat0dc_pvty no_scrat0dc_pvty edddc_pvty no_edddc_pvty

order num_st st year year1992 year1997 ///
      estab estab_over_under5 ecvalue ecvalue_per_estab ///
      scrat educ no_scrat no_educ scrat0dc edddc

sort num_st year

di "=== PANEL SUMMARY ==="
di "Observations: " _N
tab year
su estab scrat educ no_scrat no_educ

save "`outdir'/panel_GTD.dta", replace

di "=== PANEL_GTD.DTA SAVED SUCCESSFULLY ==="
di "Location: `outdir'/panel_GTD.dta"
di ""
di "TWFE Specification (from nonemployer_analysis.do):"
di "  areg estab scrat educ [controls] year1992 year1997, absorb(num_st) cluster(year_st)"
di ""
di "Where:"
di "  Y = estab (nonemployer establishments, 1000s)"
di "  D = scrat (staff-child ratio), educ (education index)"
di "  G = num_st (state FE)"
di "  T = year (1987, 1992, 1997)"

log close
