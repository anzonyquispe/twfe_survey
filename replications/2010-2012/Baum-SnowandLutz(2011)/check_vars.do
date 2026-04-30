/*==============================================================================
  CHECK_VARS: Baum-Snow and Lutz (2011)
  "School Desegregation, School Choice, and Changes in Residential
  Location Patterns by Race"
  AER 101(7), 3019-3046

  Verifica: dis70panx.dta — variables para Tables 2-5
==============================================================================*/

clear all
set more off
cap * log close _all

local datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Baum-SnowandLutz(2011)/MS20080918_data_programs/data"

* NOTE: log auto-created by Stata -b mode

di "=============================================="
di "  CHECK_VARS: Baum-Snow and Lutz (2011)"
di "=============================================="

use "`datadir'/dis70panx.dta", clear
di "Raw N = " _N
desc, short

* Filter to major deseg districts (as in original code)
keep if major==1
di "After keep if major==1: N = " _N

* Key variables
di _n "--- Key variables ---"
foreach v in leaid year imp south major publicelemw publichsw publicelemhsw publicelemb publichsb publicelemhsb privatelemw privatehsw privatelemhsw privatelemb privatehsb privatelemhsb white black {
    cap confirm variable `v'
    if _rc == 0 {
        qui sum `v'
        di "`v': N=" r(N) " mean=" %12.4f r(mean) " min=" %12.4f r(min) " max=" %12.4f r(max)
    }
    else {
        di "`v': MISSING"
    }
}

* Panel structure
di _n "--- Panel structure ---"
qui tab leaid
di "School districts (G): " r(r)
qui tab year
di "Years (T): " r(r)
tab year

* Treatment timing
di _n "--- Desegregation implementation year (imp) ---"
replace imp = imp + 1900
tab imp

* Treatment variable
gen imp_post = (year >= imp)
di _n "--- Treatment variable: imp_post ---"
tab imp_post
tab year imp_post

* Check enrollment variables
replace publicelemhsw = publicelemw + publichsw if year ~= 1990
replace publicelemhsb = publicelemb + publichsb if year ~= 1990
gen lnwpu = ln(publicelemhsw)
gen lnbpu = ln(publicelemhsb)

di _n "--- Outcomes ---"
sum lnwpu lnbpu

di _n "--- South indicator ---"
tab south

di _n "=============================================="
di "  CHECK_VARS COMPLETE"
di "=============================================="

* log close _all
