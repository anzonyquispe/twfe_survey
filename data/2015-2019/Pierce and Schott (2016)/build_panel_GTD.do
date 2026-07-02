/*
  Pierce and Schott (2016) - "The Surprisingly Swift Decline of US Manufacturing Employment"
  Table 1 - Panel GTD Construction

  Using PUBLIC data from replication package:
  - naics5809.dta (NBER-CES Manufacturing Industry Database → Y variable)
  - bbg_fam_drop_50_n6_2.dta (NAICS 6-digit to industry family concordance)
  - gaps_by_naics6_20150722_fam50.dta (NTR gap = D treatment variable)
  - robustness_ntr_fam50_true_adj.dta (applied NTR tariff rate)
  - robustness_union_fam50.dta (union membership)
  - robustness_contract_fam50.dta (contractibility)
  - robustness_chn_tariff_fam50_true.dta (Chinese tariff changes)
  - robustness_matp_fam50.dta (antidumping/trade protection)
  - robustness_mfa_fam50_yr.dta (MFA quota exposure)

  Table 1 specification (results_main.do):
    Col 0: reg  lemp s1999_post [aw=emp1990], cl(fam50) robust
    Col 1: areg lemp s1999_post d???? [aw=emp1990], a(fam50) cl(fam50) robust
    Col 2: areg lemp s1999_post lkl1990_post lsl1990_post d???? [aw=emp1990], a(fam50) cl(fam50) robust
    Col 3: areg lemp s1999_post lkl1990_post lsl1990_post contract_post dr_post
                 atp_post sfw_mwt_sum_new ntr mem d???? [aw=emp1990], a(fam50) cl(fam50) robust

  NOTE: Original paper uses LBD (restricted Census) for employment.
        We substitute NBER-CES public data (naics5809.dta) following
        the same approach used in data_create.do lines 270-282.
        Results will have same TWFE structure (G,T,D) but different magnitudes.
*/

clear all
set more off

local datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Pierce and Schott (2016)/data_files_aer_2013-1578"
local outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Pierce and Schott (2016)"

log using "`outdir'/build_panel_GTD.log", replace

* ============================================================================
* STEP 1: Load NBER-CES and map to industry families
*         (Following data_create.do lines 270-282)
* ============================================================================

di "=== STEP 1: Loading NBER-CES and mapping to industry families ==="

use "`datadir'/naics5809.dta", clear
keep year naics emp prode cap piinv

* Real capital stock (following data_create.do: gen rk=cap/piinv)
gen rk = cap/piinv

* Rename for concordance merge (concordance uses n6, not naics)
rename naics n6

* Merge with industry family concordance
sort n6
merge m:1 n6 using "`datadir'/bbg_fam_drop_50_n6_2.dta"
di "=== Concordance merge results ==="
tab _merge
drop if _merge == 2
keep if _merge == 3
drop _merge

* Keep only constant manufacturing industries
keep if con50 == 1

* Keep analysis years (1990-2007, same as original)
keep if year >= 1990 & year <= 2007

di "=== After filtering: con50==1, years 1990-2007 ==="
di "Observations: " _N
tab year

* ============================================================================
* STEP 2: Collapse to industry family × year level
* ============================================================================

di "=== STEP 2: Collapsing to fam50 × year ==="

collapse (sum) emp prode rk, by(fam50 year)

* Generate Y variable: log employment
gen lemp = ln(emp)

* Generate capital-labor and skill-labor ratios (controls)
gen lkl = ln(rk/emp)
gen lsl = ln((emp - prode)/emp)

di "=== Industry-year panel ==="
di "Observations: " _N
di "Unique industries: "
egen _tag = tag(fam50)
count if _tag == 1
drop _tag
tab year

* ============================================================================
* STEP 3: Generate 1990 initial values for weights and controls
*         (Following data_create.do lines 491-498)
* ============================================================================

di "=== STEP 3: Generating 1990 initial values ==="

foreach y in emp lkl lsl {
	gen _tmp = `y' if year == 1990
	egen `y'1990 = max(_tmp), by(fam50)
	drop _tmp
}

di "=== Weight variable emp1990 ==="
su emp1990

* ============================================================================
* STEP 4: Merge NTR gap treatment variable (D)
*         (Following data_create.do lines 413-416)
* ============================================================================

di "=== STEP 4: Merging NTR gap (treatment variable) ==="

merge m:1 fam50 using "`datadir'/gaps_by_naics6_20150722_fam50.dta", ///
	keepusing(s1999 s1990 wgap_offd31999 iodown31999 nntr1999 nntr1990)
di "=== NTR gap merge results ==="
tab _merge
drop if _merge == 2
drop _merge

di "=== Treatment variable s1999 (NTR gap) ==="
su s1999 wgap_offd31999

* ============================================================================
* STEP 5: Merge control variables from robustness files
* ============================================================================

di "=== STEP 5: Merging control variables ==="

* 5a. Applied NTR tariff rate (time-varying, fam50 × year)
sort fam50 year
merge 1:1 fam50 year using "`datadir'/robustness_ntr_fam50_true_adj.dta", ///
	keepusing(ntr dntr)
di "=== NTR tariff merge ==="
tab _merge
drop if _merge == 2
drop _merge

* 5b. Union membership (time-varying, fam50 × year)
sort fam50 year
merge 1:1 fam50 year using "`datadir'/robustness_union_fam50.dta", ///
	keepusing(mem cov)
di "=== Union merge ==="
tab _merge
drop if _merge == 2
drop _merge

* 5c. Contractibility (time-invariant, fam50 level)
merge m:1 fam50 using "`datadir'/robustness_contract_fam50.dta", ///
	keepusing(contract)
di "=== Contract merge ==="
tab _merge
drop if _merge == 2
drop _merge

* 5d. Chinese tariff changes (time-varying, fam50 × year)
sort fam50 year
merge 1:1 fam50 year using "`datadir'/robustness_chn_tariff_fam50_true.dta", ///
	keepusing(r dr)
di "=== Chinese tariff merge ==="
tab _merge
drop if _merge == 2
drop _merge

* 5e. Antidumping/trade protection (time-varying, fam50 × year)
sort fam50 year
merge 1:1 fam50 year using "`datadir'/robustness_matp_fam50.dta", ///
	keepusing(atp)
replace atp = 0 if atp == .
di "=== ATP merge ==="
tab _merge
drop if _merge == 2
drop _merge

* 5f. MFA quota exposure (time-varying, fam50 × year)
sort fam50 year
merge 1:1 fam50 year using "`datadir'/robustness_mfa_fam50_yr.dta", ///
	keepusing(sfw_mwt_sum_new)
replace sfw_mwt_sum_new = 0 if sfw_mwt_sum_new == .
di "=== MFA merge ==="
tab _merge
drop if _merge == 2
drop _merge

* ============================================================================
* STEP 6: Generate treatment interactions and time dummies
*         (Following data_create.do lines 566-581)
* ============================================================================

di "=== STEP 6: Generating treatment × post and year dummies ==="

* Post-PNTR dummy
gen post = (year >= 2001)

* Treatment × post (the key DID variable)
gen s1999_post = s1999 * post

* Control × post interactions (for Table 1 cols 2-3)
gen lkl1990_post = lkl1990 * post
gen lsl1990_post = lsl1990 * post
gen contract_post = contract * post
gen dr_post = dr * post
gen atp_post = atp * post

* Year dummies (d1991-d2007; 1990 is omitted base year)
forvalues y = 1991/2007 {
	gen d`y' = (year == `y')
}

* ============================================================================
* STEP 7: Restrict to regression sample
*         (Following data_create.do lines 617-636)
* ============================================================================

di "=== STEP 7: Restricting to regression sample ==="

* Require all key variables non-missing
gen _complete = 1
foreach x in s1999 ntr contract dr lkl lsl mem {
	replace _complete = 0 if `x' == .
}
egen _ti = total(_complete), by(fam50)
di "=== Completeness check ==="
tab _ti
* Keep industries with all 18 years complete
keep if _ti == 18
drop _complete _ti

di "=== Final regression sample ==="
di "Observations: " _N
egen _tag = tag(fam50)
di "Unique industries: "
count if _tag == 1
drop _tag

* ============================================================================
* STEP 8: Label and save panel_GTD.dta
* ============================================================================

di "=== STEP 8: Labeling and saving ==="

* Label key TWFE variables
label var fam50         "G: Industry family (absorbed FE)"
label var year          "T: Year (1990-2007)"
label var post          "T: Post-PNTR dummy (year >= 2001)"
label var lemp          "Y: Log employment (NBER-CES, 1000s)"
label var emp           "Y: Employment level (NBER-CES, 1000s)"
label var s1999         "D: NTR gap as of 1999 (treatment intensity)"
label var s1999_post    "D×T: NTR gap × post (main DID variable)"
label var emp1990       "W: Employment weight (1990 level)"
label var lkl           "X: Log capital-labor ratio (time-varying)"
label var lsl           "X: Log skill-labor ratio (time-varying)"
label var lkl1990       "X: Log capital-labor ratio (1990 value)"
label var lsl1990       "X: Log skill-labor ratio (1990 value)"
label var lkl1990_post  "X: Capital-labor 1990 × post"
label var lsl1990_post  "X: Skill-labor 1990 × post"
label var contract      "X: Contractibility index"
label var contract_post "X: Contractibility × post"
label var dr            "X: Change in Chinese tariff"
label var dr_post       "X: Chinese tariff change × post"
label var atp           "X: Antidumping/trade protection"
label var atp_post      "X: ATP × post"
label var ntr           "X: Applied NTR tariff rate"
label var mem           "X: Union membership rate"
label var sfw_mwt_sum_new "X: MFA quota exposure"
label var wgap_offd31999 "D: NTR gap (off-diagonal, 1999)"
label var nntr1999      "D: Non-NTR tariff rate (1999)"

* Order variables logically
order fam50 year post lemp emp s1999 s1999_post emp1990 ///
      lkl lsl lkl1990 lsl1990 lkl1990_post lsl1990_post ///
      contract contract_post dr dr_post atp atp_post ///
      ntr mem sfw_mwt_sum_new wgap_offd31999 nntr1999

sort fam50 year

* ============================================================================
* PANEL SUMMARY
* ============================================================================

di ""
di "=========================================="
di "=== PANEL SUMMARY ==="
di "=========================================="
di "Observations: " _N
tab year
su lemp s1999 s1999_post emp1990 lkl1990 lsl1990

di ""
di "=== Treatment variable distribution ==="
su s1999, detail

di ""
di "=== Employment summary ==="
su emp lemp emp1990

save "`outdir'/panel_GTD.dta", replace

di ""
di "=== PANEL_GTD.DTA SAVED SUCCESSFULLY ==="
di "Location: `outdir'/panel_GTD.dta"
di ""
di "TWFE Specification (from results_main.do Table 1):"
di "  Col 1: areg lemp s1999_post d???? [aw=emp1990], a(fam50) cl(fam50) robust"
di "  Col 2: areg lemp s1999_post lkl1990_post lsl1990_post d???? [aw=emp1990], a(fam50) cl(fam50) robust"
di "  Col 3: areg lemp s1999_post lkl1990_post lsl1990_post contract_post dr_post"
di "         atp_post sfw_mwt_sum_new ntr mem d???? [aw=emp1990], a(fam50) cl(fam50) robust"
di ""
di "Where:"
di "  Y = lemp (log employment from NBER-CES public data)"
di "  D = s1999 (NTR gap as of 1999), s1999_post = s1999 * (year>=2001)"
di "  G = fam50 (industry family FE, absorbed)"
di "  T = year dummies d1991-d2007 (base: 1990)"
di "  W = emp1990 (analytic weight)"

log close
