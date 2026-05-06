* =============================================================================
* Fetzer (2019)
* Did Austerity Cause Brexit?
* AER, 109(11), 3849-3886
* PARTIAL REPLICATION: District-level analysis only (UKHLS data not included)
* =============================================================================

clear all
set more off
set maxvar 10000
global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Fetzer (2019)"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Fetzer (2019)/full"

* Install required packages
cap ssc install require, replace
cap which ftools
if _rc ssc install ftools, replace
cap which reghdfe
if _rc ssc install reghdfe, replace
cap reghdfe, compile
cap which estout
if _rc ssc install estout, replace

* Create output directories
cap mkdir "$outdir/tables"
cap mkdir "$outdir/figures"

cd "$datadir"

* Create temporary data directory
cap mkdir "data-files/temporary-data-files"

cap log close _all
log using "$outdir/run_fetzer_full.log", text replace

* =============================================================================
* DISTRICT-LEVEL ANALYSIS
* =============================================================================
di _n "=========================================================="
di _n "DISTRICT-LEVEL ANALYSIS"
di _n "=========================================================="

use "data-files/DISTRICT.dta", clear

* =============================================================================
* FIGURE 1 PANEL A: UKIP vote shares over time
* =============================================================================
di _n "===== FIGURE 1: UKIP Vote Shares ====="

foreach var in pct_votes_UKIP UKIPPct {
    preserve
    tab year if `var'!=., gen(yy_)
    local rows = `r(r)'
    reg `var' yy_* [aw=pct_seats_contested_UKIP], nocons

    di _n "--- `var' by year ---"
    forvalues i=1(1)`rows' {
        cap noi lincom yy_`i'
        if _rc==0 {
            di "  Year coef: " %9.4f r(estimate) " SE: " %9.4f r(se)
        }
    }
    restore
}

* =============================================================================
* SUMMARY STATISTICS TABLE A1
* =============================================================================
di _n "===== TABLE A1: Summary Statistics ====="

* Labels
label variable pct_votes_UKIP "Local election % for UKIP"
label variable UKIPPct "EP % for UKIP"
label variable QUAL_ALL_noq_sh "% with No qualifications (2001)"
label variable RoutineOccAll_sh "% in Routine occupations (2001)"
label variable GRetailAll_sh "% in Retail (2001)"
label variable DManufAll_sh "% in Manufacturing (2001)"
label variable totalimpact_finlosswapyr "Total Austerity Impact"

foreach var in pct_votes_UKIP UKIPPct {
    di _n "--- Summary: `var' ---"
    sum `var'
}

foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh totalimpact_finlosswapyr taxcredits_finlosswapyr childbenefit_finlosswapyr counciltaxbenefit_finlosswapyr disabilitylivingallow_finlosswap bedroom_tax_finlosswapyr {
    di _n "--- Summary: `var' (year==2011) ---"
    sum `var' if year==2011
}

* =============================================================================
* MAIN ANALYSIS: Event Study regressions (Figure 4)
* =============================================================================
di _n "===== MAIN ANALYSIS: Event Study Regressions ====="

tab year, gen(yy_)
replace pct_votes_UKIP = pct_votes_UKIP/100

foreach var in QUAL_ALL_noq_sh RoutineOccAll_sh GRetailAll_sh DManufAll_sh {
    di _n "--- reghdfe: pct_votes_UKIP on `var' x year ---"

    preserve
    local shorter = substr("`var'", 1, 20)
    forvalues i=1(1)16 {
        gen yyin_`shorter'_`i' = yy_`i' * `var'
    }

    cap noi reghdfe pct_votes_UKIP yyin_`shorter'_1- yyin_`shorter'_10 yyin_`shorter'_12-yyin_`shorter'_16, absorb(id ryr) vce(cl id)

    if _rc==0 {
        di _n "  Post-2010 coefficients:"
        forvalues i=12(1)16 {
            cap noi lincom yyin_`shorter'_`i'
            if _rc==0 {
                di "    Year `i': " %9.5f r(estimate) " (" %9.5f r(se) ")"
            }
        }
        di _n "  Average post-treatment:"
        cap noi lincom (yyin_`shorter'_14 + yyin_`shorter'_15 + yyin_`shorter'_16)/3
        if _rc==0 {
            di "    Avg: " %9.5f r(estimate) " SE: " %9.5f r(se)
        }
    }
    restore
}

* =============================================================================
* WESTMINSTER ANALYSIS (Figure 5)
* =============================================================================
di _n "===== WESTMINSTER ANALYSIS ====="

cap noi {
    use "data-files/WESTMINSTER.dta", clear

    di _n "--- Westminster data loaded ---"
    describe, short

    * Basic summary of UKIP Westminster results
    di _n "--- UKIP Westminster votes ---"
    cap noi sum UKIPPct
    cap noi tab year if UKIPPct!=.
}

di _n "===== DISTRICT ANALYSIS COMPLETE ====="
di _n "NOTE: Individual-level analysis (Tables 1-4) requires UKHLS data not included."

cap log close _all
