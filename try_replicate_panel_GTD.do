/*==============================================================================
  try_replicate_panel_GTD.do

  For each of the 24 papers in comparativo_completo:
    1. Load panel_GTD.dta
    2. Auto-detect G, T, D, Y from variable labels ("G:", "T:", "D:", "Y:")
    3. Print data summary (N, n_groups, n_periods, D range, within-variation)
    4. Try spec A: reghdfe Y D, absorb(G T) vce(cluster G)
    5. Try spec B: reghdfe Y D, absorb(G T) vce(robust)        [if A fails]
    6. Try spec C: xtreg Y D i.T_int, fe i(G) vce(cluster G)  [if B fails]
    7. Report: beta, SE, p-value, R2, status, diagnostic notes

  Outputs:
    reports/try_replicate.log   — full diagnostic log
    reports/try_replicate.csv   — machine-readable summary (one row per paper)

  Run from Stata:
    do "$twfe_root/try_replicate_panel_GTD.do"
  or batch:
    stata -b do "/full/path/to/try_replicate_panel_GTD.do"
==============================================================================*/

clear all
set more off
cap log close _all

* ============================================================================
* 0. USER DETECTION
* ============================================================================
if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root "C:/Users/Usuario/Documents/GitHub/twfe_survey"
}
else {
    di as error "Unknown user: `c(username)'. Add your repo path to the block above."
    exit 198
}

* Add ado path for classify_design.ado and other local ados
adopath + "$twfe_root"

* Install reghdfe and ftools if not present
cap which reghdfe
if _rc {
    di "Installing reghdfe..."
    ssc install reghdfe, replace
    ssc install ftools,  replace
}

log using "$twfe_root/reports/try_replicate.log", text replace

di _n "================================================================"
di "  TRY REPLICATE PANEL_GTD — `c(current_date)' `c(current_time)'"
di "  Root: $twfe_root"
di "  Spec A: reghdfe Y D, absorb(G T) vce(cluster G)"
di "  Spec B: reghdfe Y D, absorb(G T) vce(robust)"
di "  Spec C: xtreg   Y D i.T_int, fe i(G) vce(cluster G)"
di "================================================================"

* ============================================================================
* 1. PAPER LIST (24 papers — same order as comparativo_completo.tex)
* ============================================================================
local n_papers = 0

local wave1 "2010-2012"
local wave2 "2015-2019"

* --- Wave 1 (16 papers) ---
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Acemoglu et al. (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Simcoe (2012)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Algan and Cahuc (2010)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Enikolopov et al. (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Forman et al. (2012)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Baum-SnowandLutz(2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Besley and Mueller (2012)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Dinkelman (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Faye and Niehaus (2012)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Gentzkow et al. (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Bagwell and Staiger (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Wang (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Duranton and Turner (2011)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Moser and Voena (2012)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Hornbeck (2012)"
local ++n_papers; local w`n_papers' "`wave1'"; local p`n_papers' "Zhang and Zhu (2011)"

* --- Wave 2 (8 papers) ---
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Antecol et al. (2018)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Berman et al. (2017)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Burgess et al. (2015)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Donaldson (2018)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Favara and Imbs (2015)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Fetzer (2019)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' "Kaur (2019)"
local ++n_papers; local w`n_papers' "`wave2'"; local p`n_papers' `"Suárez Serrato and Zidar (2016)"'

assert `n_papers' == 24
di "Paper list loaded: `n_papers' papers."

* ============================================================================
* 2. CSV INITIALISATION
* ============================================================================
cap file close csvfh
file open csvfh using "$twfe_root/reports/try_replicate.csv", write replace
file write csvfh "paper,wave,G,T,D,Y,N,n_G,n_T,beta,se,pval,R2_within,spec,status,notes" _n

* ============================================================================
* 3. MAIN LOOP
* ============================================================================

* Counters for final summary
local n_ok_A   = 0   /* reghdfe + cluster worked   */
local n_ok_B   = 0   /* reghdfe + robust worked     */
local n_ok_C   = 0   /* xtreg fallback worked       */
local n_failed = 0   /* all attempts failed         */

forvalues i = 1/`n_papers' {

    local pname "`p`i''"
    local wname "`w`i''"
    local dta   "$twfe_root/replications/`wname'/`pname'/panel_GTD.dta"

    di _n "================================================================"
    di "  PAPER `i'/24: `pname'"
    di "  Wave : `wname'"
    di "================================================================"

    * ------------------------------------------------------------------
    * (a) File check
    * ------------------------------------------------------------------
    cap confirm file "`dta'"
    if _rc {
        di as error "  FILE NOT FOUND: `dta'"
        file write csvfh `"`pname',`wname',,,,,.,.,.,.,.,.,.,"MISSING","panel_GTD.dta not found""' _n
        local r_status_`i' "MISSING"
        local r_beta_`i'   .
        local r_se_`i'     .
        local r_pval_`i'   .
        local ++n_failed
        continue
    }

    use "`dta'", clear

    * ------------------------------------------------------------------
    * (b) Detect G / T / D / Y from variable labels
    * ------------------------------------------------------------------
    local gvar ""
    local tvar ""
    local dvar ""
    local yvar ""

    foreach v of varlist * {
        local lab : variable label `v'
        if substr("`lab'", 1, 2) == "G:" local gvar "`v'"
        if substr("`lab'", 1, 2) == "T:" local tvar "`v'"
        if substr("`lab'", 1, 2) == "D:" local dvar "`v'"
        if substr("`lab'", 1, 2) == "Y:" local yvar "`v'"
    }

    di "  Detected: G=`gvar'  T=`tvar'  D=`dvar'  Y=`yvar'"

    if "`gvar'"=="" | "`tvar'"=="" | "`dvar'"=="" | "`yvar'"=="" {
        di as error "  LABEL DETECTION FAILED — one or more of G/T/D/Y not found"
        file write csvfh `"`pname',`wname',`gvar',`tvar',`dvar',`yvar',.,.,.,.,.,.,.,"DETECT_FAIL","Missing label prefix""' _n
        local r_status_`i' "DETECT_FAIL"
        local r_beta_`i'   .
        local r_se_`i'     .
        local r_pval_`i'   .
        local ++n_failed
        continue
    }

    * ------------------------------------------------------------------
    * (c) Data summary
    * ------------------------------------------------------------------
    local N_raw = _N
    qui tab `gvar'
    local n_G = r(r)
    qui tab `tvar'
    local n_T = r(r)

    qui sum `dvar'
    local d_min  = r(min)
    local d_max  = r(max)
    local d_mean = r(mean)
    local d_sd   = r(sd)

    di "  N=`N_raw'   Groups(`gvar')=`n_G'   Periods(`tvar')=`n_T'"
    di "  D range : [`d_min', `d_max']   mean=" %7.4f `d_mean' "   sd=" %7.4f `d_sd'

    * Within-group variation of D
    qui bysort `gvar' (`tvar'): gen _D_g1 = `dvar'[1]
    qui bysort `gvar' (`tvar'): gen _D_glast = `dvar'[_N]
    qui gen _D_within = (_D_g1 != _D_glast) if !missing(_D_g1) & !missing(_D_glast)
    qui sum _D_within
    local pct_within = 0
    if r(N) > 0 local pct_within = r(mean) * 100
    drop _D_g1 _D_glast _D_within
    di "  D within-group variation: " %5.1f `pct_within' "% of groups have it"

    if `pct_within' < 1 {
        di as text "  WARNING: D appears time-invariant in nearly all groups."
        di as text "           reghdfe may fail due to collinearity with group FE."
    }

    * Drop missing on G, T, D, Y
    qui drop if missing(`gvar') | missing(`tvar') | missing(`dvar') | missing(`yvar')
    local N_clean = _N
    if `N_clean' < `N_raw' di "  Dropped " (`N_raw'-`N_clean') " obs with missing G/T/D/Y → N=`N_clean'"

    if `N_clean' == 0 {
        di as error "  NO OBSERVATIONS after dropping missing values."
        file write csvfh `"`pname',`wname',`gvar',`tvar',`dvar',`yvar',0,`n_G',`n_T',.,.,.,.,"EMPTY","Zero obs after missings dropped""' _n
        local r_status_`i' "EMPTY"
        local r_beta_`i'   .
        local r_se_`i'     .
        local r_pval_`i'   .
        local ++n_failed
        continue
    }

    * ------------------------------------------------------------------
    * (d) Attempt A: reghdfe + cluster(G)
    * ------------------------------------------------------------------
    local beta   = .
    local se     = .
    local pval   = .
    local R2w    = .
    local status = "FAILED"
    local notes  = ""
    local spec   = ""

    di _n "  >>> Spec A: reghdfe `yvar' `dvar', absorb(`gvar' `tvar') vce(cluster `gvar')"

    cap noisily reghdfe `yvar' `dvar', absorb(`gvar' `tvar') vce(cluster `gvar')
    local rcA = _rc

    if `rcA' == 0 {
        local beta   = _b[`dvar']
        local se     = _se[`dvar']
        if `se' > 0 & `se' < . local pval = 2 * (1 - normal(abs(`beta' / `se')))
        local R2w    = e(r2)
        local status = "OK"
        local spec   = "A:reghdfe_cluster"
        local notes  = "reghdfe with cluster SE converged"
        local ++n_ok_A
    }
    else {
        di as error "  Spec A failed (rc=`rcA')"

        * ---------------------------------------------------------------
        * (e) Attempt B: reghdfe + robust
        * ---------------------------------------------------------------
        di "  >>> Spec B: reghdfe `yvar' `dvar', absorb(`gvar' `tvar') vce(robust)"
        cap noisily reghdfe `yvar' `dvar', absorb(`gvar' `tvar') vce(robust)
        local rcB = _rc

        if `rcB' == 0 {
            local beta   = _b[`dvar']
            local se     = _se[`dvar']
            if `se' > 0 & `se' < . local pval = 2 * (1 - normal(abs(`beta' / `se')))
            local R2w    = e(r2)
            local status = "OK"
            local spec   = "B:reghdfe_robust"
            local notes  = "Spec A failed (rc=`rcA'); Spec B (robust) converged"
            local ++n_ok_B
        }
        else {
            di as error "  Spec B failed (rc=`rcB')"

            * -----------------------------------------------------------
            * (f) Attempt C: xtreg fallback (requires integer T)
            * -----------------------------------------------------------
            di "  >>> Spec C: xtreg (requires balanced numeric panel — attempting)"

            * Create integer T for xtset
            qui cap drop _T_int
            qui egen _T_int = group(`tvar')
            cap xtset `gvar' _T_int
            local rcXT = _rc

            if `rcXT' == 0 {
                cap noisily xtreg `yvar' `dvar' i._T_int, fe i(`gvar') vce(cluster `gvar')
                local rcC = _rc

                if `rcC' == 0 {
                    local beta   = _b[`dvar']
                    local se     = _se[`dvar']
                    if `se' > 0 & `se' < . local pval = 2 * (1 - normal(abs(`beta' / `se')))
                    local R2w    = e(r2_within)
                    local status = "OK"
                    local spec   = "C:xtreg_cluster"
                    local notes  = "Specs A(rc=`rcA') B(rc=`rcB') failed; Spec C (xtreg) converged"
                    local ++n_ok_C
                }
                else {
                    local status = "FAILED"
                    local spec   = "none"
                    local notes  = "All specs failed: A(rc=`rcA') B(rc=`rcB') C(rc=`rcC')"
                    local ++n_failed
                }
            }
            else {
                local status = "FAILED"
                local spec   = "none"
                local notes  = "Specs A(rc=`rcA') B(rc=`rcB') failed; xtset failed (rc=`rcXT')"
                local ++n_failed
            }

            cap drop _T_int
        }
    }

    * ------------------------------------------------------------------
    * (g) Report result
    * ------------------------------------------------------------------
    if "`status'" == "OK" {
        di _n "  *** RESULT ***"
        di "  beta(`dvar') = " %14.6f `beta'
        di "  SE           = " %14.6f `se'
        if `pval' < . {
            if `pval' < 0.001     di "  p-value      = " %8.4f `pval' "  ***"
            else if `pval' < 0.05 di "  p-value      = " %8.4f `pval' "  *"
            else                  di "  p-value      = " %8.4f `pval'
        }
        if `R2w' < .              di "  R2 (within)  = " %8.4f `R2w'
        di "  N (used)     = `N_clean'"
        di "  Spec: `spec'"
        di "  Notes: `notes'"
    }
    else {
        di _n "  *** ALL SPECIFICATIONS FAILED ***"
        di "  Notes: `notes'"
    }

    * ------------------------------------------------------------------
    * (h) Write CSV row
    * ------------------------------------------------------------------
    local beta_s = string(`beta', "%14.8f")
    local se_s   = string(`se',   "%14.8f")
    local pval_s = string(`pval', "%8.4f")
    local R2w_s  = string(`R2w',  "%8.4f")

    file write csvfh `"`pname',`wname',`gvar',`tvar',`dvar',`yvar',`N_clean',`n_G',`n_T',`beta_s',`se_s',`pval_s',`R2w_s',"`spec'","`status'","`notes'""' _n

    * Store for summary
    local r_status_`i' "`status'"
    local r_spec_`i'   "`spec'"
    local r_beta_`i'   `beta'
    local r_se_`i'     `se'
    local r_pval_`i'   `pval'
    local r_gvar_`i'   "`gvar'"
    local r_dvar_`i'   "`dvar'"

} /* end forvalues i */

* ============================================================================
* 4. CLOSE CSV
* ============================================================================
file close csvfh
di _n "CSV written: $twfe_root/reports/try_replicate.csv"

* ============================================================================
* 5. SUMMARY TABLE
* ============================================================================
di _n _n "================================================================"
di "  SUMMARY — ALL 24 PAPERS"
di "================================================================"
di %3s "#" " " %36s "Paper" " " %16s "Status" " " %14s "beta(D)" " " %8s "p-val" " " "Spec"
di "----------------------------------------------------------------"

local group_ok   ""
local group_fail ""

forvalues i = 1/`n_papers' {
    local stat  "`r_status_`i''"
    local spec  "`r_spec_`i''"
    local bdisp = string(`r_beta_`i'', "%12.5f")
    local pdisp = string(`r_pval_`i'', "%6.4f")
    local pshort = substr("`p`i''", 1, 36)

    if "`stat'" == "OK" {
        di %3s "`i'" " " %36s "`pshort'" " " %16s "`stat'" " " %14s "`bdisp'" " " %8s "`pdisp'" " " "`spec'"
        local group_ok "`group_ok' `i'"
    }
    else {
        di %3s "`i'" " " %36s "`pshort'" " " %16s "`stat'" " " %14s "." " " %8s "." " " "`spec'"
        local group_fail "`group_fail' `i'"
    }
}

di "----------------------------------------------------------------"
local n_ok_total = `n_ok_A' + `n_ok_B' + `n_ok_C'
di "  OK  : `n_ok_total'  (A/cluster: `n_ok_A',  B/robust: `n_ok_B',  C/xtreg: `n_ok_C')"
di "  FAIL: `n_failed'"

* ============================================================================
* 6. GROUP LISTINGS
* ============================================================================
di _n "================================================================"
di "  GROUP 1 — AT LEAST ONE COLUMN REPLICATED"
di "================================================================"
foreach i of local group_ok {
    local bfmt = string(`r_beta_`i'', "%10.5f")
    local pfmt = string(`r_pval_`i'', "%6.4f")
    di "  [`i'] `p`i'' (`w`i'') — D=`r_dvar_`i'' — beta=`bfmt'  p=`pfmt'  (`r_spec_`i'')"
}

di _n "================================================================"
di "  GROUP 2 — NEED INSPECTION (all specs failed)"
di "================================================================"
foreach i of local group_fail {
    di "  [`i'] `p`i'' (`w`i'') — D=`r_gvar_`i'' — Status=`r_status_`i''"
}

di _n "================================================================"
di "  Log: $twfe_root/reports/try_replicate.log"
di "  CSV: $twfe_root/reports/try_replicate.csv"
di "================================================================"

log close _all
