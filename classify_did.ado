*! classify_did v0.2 (2026-07-01)
*! Classify a (G, T, D) panel into: CLA, SAD, SSFSD, SFSD, HAD, SSD, OTHER
*!
*! Syntax:  classify_did Y G T D [, book(#)]
*!   Y       = outcome (display only; not used for classification)
*!   G       = group identifier
*!   T       = time identifier (need not be consecutive; normalised internally)
*!   D       = treatment variable (numeric)
*!   book(1) = textbook mode (DEFAULT). Before classifying SSFSD/SFSD, drops
*!             pure-control stayers (d_baseline==0 & Fg==Tplus1) and tests
*!             whether the remaining switchers form a HAD design.  If yes,
*!             returns "HAD" with r(had_stayers)==1.  Set book(0) to skip.
*!
*! Returns (via r()):
*!   r(design)      - "CLA"|"SAD"|"SSFSD"|"SFSD"|"HAD"|"SSD"|"OTHER"
*!   r(estimator)   - "did_multiplegt_dyn"|"did_had"|"did_multiplegt_stat"
*!   r(had_stayers) - 1 if classified as HAD via the stayer-drop path, else 0
*!   r(design_code) - numeric scalar encoding the classification:
*!                      1=CLA  2=SAD  3=HAD-with-stayers  4=SSFSD
*!                      5=SFSD  6=HAD-w/o-stayers  7=SSD  8=OTHER
*!
*! Notes:
*!   - Prints Clement's sketch_did_design messages verbatim.
*!   - Always-treated groups (d_baseline>0) excluded from sd_Fg (Option B).
*!   - HAD condition (revised): sd_first_change>0 AND exactly one unique D
*!     value before t* per group (constant pre-treatment at any level).
*!   - Dataset is fully preserved; no variables added to the caller's data.

program define classify_did, rclass
    version 13
    syntax varlist(min=4 max=4 numeric) [, BOOK(integer 1)]

    tokenize `varlist'
    local Y  "`1'"
    local G  "`2'"
    local T  "`3'"
    local D  "`4'"

    di _n as text "===== classify_did ====="
    di    as text "  Outcome: `Y'"
    di    as text "  Group  : `G'"
    di    as text "  Time   : `T'"
    di    as text "  Treat  : `D'"
    if `book' di as text "  Mode   : book=1 (HAD-with-stayers check ON)"
    else      di as text "  Mode   : book=0 (HAD-with-stayers check OFF)"

    preserve

    * --- Keep only needed variables; drop missing IDs ---
    keep `Y' `G' `T' `D'
    drop if missing(`G') | missing(`T')

    * --- Normalize G and T to consecutive integer indices ---
    egen __G = group(`G')
    egen __T = group(`T')
    gen  __D  = `D'
    drop `G' `T' `D'
    * (keep `Y' in the working dataset for potential future use; not used in classification)

    * --- Balance the panel (Clement step 1) ---
    fillin __G __T
    capture drop _fillin

    * --- Scalar bounds ---
    qui sum __T
    scalar __Tplus1 = r(max) + 1
    scalar __Tmin   = r(min)

    * --- Drop groups whose treatment is always missing ---
    gen __tdnm = __T * (__D != .) + __Tplus1 * (__D == .)
    bysort __G: egen __firstt_dnm = min(__tdnm)
    drop if __firstt_dnm == __Tplus1
    drop __tdnm __firstt_dnm

    * --- Baseline treatment: D at first observed period per group ---
    gen  __dbase_tmp = __D if __T == __Tmin
    bysort __G: egen __d_baseline = min(__dbase_tmp)
    drop __dbase_tmp

    * --- Always-treated flag (d_baseline > 0) [Option B] ---
    gen __always_treated = (__d_baseline > 0)

    * --- Fg: first T where D changes from baseline (Tplus1 if never) ---
    gen  __tc = __T if __D != . & __D != __d_baseline
    replace __tc = __Tplus1 if missing(__tc)
    bysort __G: egen __Fg = min(__tc)
    drop __tc

    * --- d_Fg and first_change ---
    gen  __d_Fg_tmp = __D if __T == __Fg
    bysort __G: egen __d_Fg = min(__d_Fg_tmp)
    drop __d_Fg_tmp
    gen __first_change = __d_Fg - __d_baseline

    * --- Drop groups where D missing just before Fg (Clement step) ---
    gen  __dmiss = (__D == .) if __T == __Fg - 1
    bysort __G: egen __dmiss_atFgm1 = min(__dmiss)
    drop if __dmiss_atFgm1 == 1
    drop __dmiss __dmiss_atFgm1

    * ---------------------------------------------------------------
    * sd_Fg: SD of Fg among non-always-treated groups (Option B).
    * Fallback: if ALL non-always-treated groups are never-switchers
    * (Fg = Tplus1 for every one of them), the treatment variation lives
    * entirely inside the always-treated groups (e.g. a continuous dose
    * that varies within treated units over time, with pure-control units
    * at D = 0 forever).  In that case we include all groups.
    * ---------------------------------------------------------------
    qui sum __Fg if __always_treated == 0
    if r(N) == 0 {
        di _n as result "All groups are always-treated (d_baseline > 0). Design: OTHER."
        restore
        return local  design       "OTHER"
        return local  estimator    "did_multiplegt_stat"
        return scalar had_stayers  = 0
        return scalar design_code  = 8
        exit
    }
    scalar __sd_Fg    = cond(missing(r(sd)),   0, r(sd))
    scalar __Fg_notAT = cond(missing(r(mean)), __Tplus1, r(mean))

    * Scalar flag: 1 = fell back to including AT groups in the analysis
    scalar __incl_AT = 0

    if __sd_Fg == 0 & abs(__Fg_notAT - __Tplus1) < 1e-6 {
        * All non-always-treated groups never switch — include AT groups.
        di _n as text ///
            "(Note: all non-always-treated groups are never-switchers. " ///
            "Including always-treated groups in the classification.)"
        scalar __incl_AT = 1
        qui sum __Fg
        scalar __sd_Fg = cond(missing(r(sd)), 0, r(sd))
    }

    * ---------------------------------------------------------------
    * Result locals (accumulated through nested ifs; single exit point)
    * ---------------------------------------------------------------
    local __design      ""
    local __estimator   ""
    local __had_stayers 0

    * ==============================================================
    * BRANCH A: sd_Fg == 0  (same timing or nobody switches)
    * ==============================================================
    if __sd_Fg == 0 {

        qui sum __Fg if __always_treated == 0, meanonly
        scalar __Fg_val = r(mean)
        local __Fg_disp = string(scalar(__Fg_val), "%g")

        * Clement's message
        di _n as text ///
            "Your design is not a Staggered First Switch Design: all groups " ///
            "experience their first treatment change at period `__Fg_disp'. " ///
            "You cannot use the did_multiplegt_dyn package to estimate the treatment's effect."

        * ----- A1: Nobody ever switches -----
        if __Fg_val == __Tplus1 {
            di _n as result "No group ever switches treatment. Design: OTHER."
            local __design    "OTHER"
            local __estimator "did_multiplegt_stat"
        }
        else {
            * Some groups switch (all at the same date t* = __Fg_val)

            * sd_first_change among non-always-treated
            qui sum __first_change if __always_treated == 0
            scalar __sd_fc = cond(missing(r(sd)), 0, r(sd))

            * Clement's HAD / not-HAD messages
            if __sd_fc > 0 {
                di _n as text ///
                    "All groups experience their first treatment change at period " ///
                    "`__Fg_disp', but the magnitude of that change varies across groups. " ///
                    "Then, your design is an Heterogeneous Adoption Design. You may be able " ///
                    "to use the did_had package to estimate the treatment's effect, " ///
                    "see Chapter 7 of the DID textbook of de Chaisemartin and D'Haultfoeuille " ///
                    "for further details."
            }
            else {
                di _n as text ///
                    "All groups experience their first treatment change at period " ///
                    "`__Fg_disp', and the magnitude of that change does not vary across groups. " ///
                    "Then, your design is not an Heterogeneous Adoption Design, so you cannot " ///
                    "use the did_had package to estimate the treatment's effect."
            }

            * ----- A2: HAD check (REVISED condition) -----
            * sd_first_change > 0  AND  each group has exactly 1 unique D value before t*
            if __sd_fc > 0 {
                scalar __t_star = __Fg_val

                * Count distinct D values per group in pre-treatment periods
                gen  __pre_D    = __D if __T < __t_star & __always_treated == 0
                bysort __G __pre_D: gen __pdrk = _n
                gen  __isfirst  = (__pdrk == 1 & !missing(__pre_D))
                bysort __G: egen __n_uniq_pre = total(__isfirst)
                drop __pre_D __pdrk __isfirst

                qui sum __n_uniq_pre if __always_treated == 0
                * had_ok: every group has exactly 1 unique pre-treatment D value
                scalar __had_ok = (!missing(r(min)) & r(max) <= 1 & r(min) >= 1)
                drop __n_uniq_pre

                if __had_ok {
                    di _n as result ///
                        "Your dataset corresponds to Design HAD " ///
                        "(Heterogeneous Adoption Design)."
                    di    as text  ///
                        "  Common treatment date t* = `__Fg_disp'." ///
                        "  Pre-treatment D is constant within each group (any level)."
                    local __design    "HAD"
                    local __estimator "did_had"
                }
            }

            * ----- A3: SSD check (only if not already classified) -----
            if "`__design'" == "" {

                qui xtset __G __T
                gen __fd_D   = __D - L.__D
                gen __fd_abs = abs(__fd_D)
                bysort __T: egen __min_sw = min(__fd_abs)
                bysort __T: egen __max_sw = max(__fd_abs)
                gen __sw_stay = (__max_sw > 0 & __min_sw == 0)
                qui sum __sw_stay
                scalar __ssd = r(max)
                drop __fd_D __fd_abs __min_sw __max_sw __sw_stay

                if __ssd == 1 {
                    di _n as text ///
                        "Your design is a Switchers and Stayers Design: there is at least " ///
                        "one pair of consecutive time periods (t-1, t) between which there " ///
                        "is at least one switcher, whose treatment changes, and one stayer, " ///
                        "whose treatment does not change. Then, if you are ready to assume " ///
                        "that lagged treatments do not affect the current outcome beyond a " ///
                        "pre-determined lag, you can use the did_multiplegt_stat package to " ///
                        "estimate the treatment's effect. See Section 8.4 of the DID textbook " ///
                        "of de Chaisemartin and D'Haultfoeuille for further details."
                    di _n as result ///
                        "Your dataset corresponds to Design SSD " ///
                        "(Switchers and Stayers Design)."
                    local __design    "SSD"
                    local __estimator "did_multiplegt_stat"
                }
                else {
                    di _n as text ///
                        "Your design is not a Switchers and Stayers Design: there is no pair " ///
                        "of consecutive time periods (t-1, t) between which there is at least " ///
                        "one switcher, whose treatment changes, and one stayer, whose treatment " ///
                        "does not change. Then, you cannot use the did_multiplegt_stat package " ///
                        "to estimate the treatment's effect."
                    di _n as result "Design: OTHER."
                    local __design    "OTHER"
                    local __estimator "did_multiplegt_stat"
                }
            }
        }
    }

    * ==============================================================
    * BRANCH B: sd_Fg > 0  (staggered timing across groups)
    * ==============================================================
    else {

        * Check binary: D takes only {d_min, d_max} values
        qui sum __D
        scalar __d_max = r(max)
        scalar __d_min = r(min)
        gen __bin_chk = (__D == __d_max | __D == __d_min) if !missing(__D)
        qui sum __bin_chk
        scalar __binary = (r(mean) == 1)
        drop __bin_chk

        * Check absorbing: D stays at d_Fg for all t > Fg
        gen __abs_chk = (__D == __d_Fg) if __T > __Fg & !missing(__D)
        qui sum __abs_chk
        scalar __absorbing = cond(missing(r(min)), 1, r(min) == 1)
        drop __abs_chk

        * Clement's staggered message
        di _n as text ///
            "Your design is a Staggered First Switch Design, where groups " ///
            "experience their first treatment change at different points in time. " ///
            "You can use the did_multiplegt_dyn package to estimate the treatment's effect, " ///
            "see Section 8.3 of the DID textbook of de Chaisemartin and D'Haultfoeuille " ///
            "for further details. If you are ready to assume that lagged treatments do not " ///
            "affect the current outcome beyond a pre-determined lag, you can also use the " ///
            "did_multiplegt_stat package, see Section 8.4 of the DID textbook."

        * ----- B1: Binary AND absorbing -----
        if __binary == 1 & __absorbing == 1 {

            * sd of Fg among switchers only (Fg < Tplus1)
            * Respect the __incl_AT fallback: include AT groups if flagged.
            if __incl_AT {
                qui sum __Fg if __Fg < __Tplus1
            }
            else {
                qui sum __Fg if __Fg < __Tplus1 & __always_treated == 0
            }
            scalar __sd_Fg_sw = cond(missing(r(sd)), 0, r(sd))

            if __sd_Fg_sw == 0 {
                * All switchers adopt at the same date → CLA (stayers exist since sd_Fg > 0)
                di _n as text ///
                    "Your design is a Classical DID Design, with an absorbing and binary " ///
                    "treatment, and no variation in treatment timing. You can use a static " ///
                    "TWFE regression and/or an event-study TWFE regression to estimate the " ///
                    "treatment's effect, see Chapter 3 of the DID textbook of de Chaisemartin " ///
                    "and D'Haultfoeuille for further details."
                di _n as result ///
                    "Your dataset corresponds to Design CLA (Classical DID)."
                di    as text ///
                    "  Note: CLA requires untreated/never-treated control groups. " ///
                    "  Verify their presence before using did_multiplegt_dyn without controls."
                local __design    "CLA"
                local __estimator "did_multiplegt_dyn"
            }
            else {
                * Switchers have different adoption dates → SAD
                di _n as text ///
                    "Your design is a Staggered Adoption Design, with an absorbing and binary " ///
                    "treatment, and variation in treatment timing. You can for instance use the " ///
                    "csdid, did_multiplegt_dyn, or did2s package to estimate the treatment's " ///
                    "effect, see Chapter 6 of the DID textbook of de Chaisemartin and " ///
                    "D'Haultfoeuille for further details."
                di _n as result ///
                    "Your dataset corresponds to Design SAD (Staggered Adoption Design)."
                local __design    "SAD"
                local __estimator "did_multiplegt_dyn"
            }
        }

        * ----- B2: Non-binary or non-absorbing (SFSD branch) -----
        else {

            * ----- B2a: HAD-with-stayers check (book=1 only) ----------------
            * Logic: pure-control stayers (d_baseline==0 & Fg==Tplus1) may be
            * hiding a HAD structure among the switchers.  Drop them temporarily
            * and test HAD conditions on the remaining groups.
            if `book' {

                gen __is_stayer = (__d_baseline == 0 & __Fg == __Tplus1)

                * sd_Fg among non-stayers (all obs, repeated per T — only the
                * == 0 / > 0 distinction matters)
                qui sum __Fg if !__is_stayer
                scalar __sd_Fg_ns   = cond(missing(r(sd)),   0, r(sd))
                scalar __Fg_mean_ns = cond(missing(r(mean)), __Tplus1, r(mean))

                if __sd_Fg_ns == 0 & __Fg_mean_ns < __Tplus1 {
                    * All non-stayers switch at the same date → HAD candidate

                    qui sum __first_change if !__is_stayer
                    scalar __sd_fc_ns = cond(missing(r(sd)), 0, r(sd))

                    if __sd_fc_ns > 0 {
                        * Heterogeneous doses → check unique pre-treatment D per group
                        scalar __t_star_ns = __Fg_mean_ns
                        local  __ts_disp   = string(scalar(__t_star_ns), "%g")

                        gen  __pre_D_ns = __D if __T < __t_star_ns & !__is_stayer
                        bysort __G __pre_D_ns: gen __pdrk_ns = _n
                        gen  __isfirst_ns  = (__pdrk_ns == 1 & !missing(__pre_D_ns))
                        bysort __G: egen __n_uniq_pre_ns = total(__isfirst_ns)
                        drop __pre_D_ns __pdrk_ns __isfirst_ns

                        qui sum __n_uniq_pre_ns if !__is_stayer
                        scalar __had_ok_ns = (!missing(r(min)) & r(max) <= 1 & r(min) >= 1)
                        drop __n_uniq_pre_ns

                        if __had_ok_ns {
                            di _n as result ///
                                "Your dataset corresponds to Design HAD with Stayers."
                            di    as text ///
                                "  Common treatment date t* = `__ts_disp'."
                            di    as text ///
                                "  Pure-control stayers (d_baseline=0, never-switchers) " ///
                                "are present but the switchers satisfy HAD conditions."
                            di    as text ///
                                "  Recommended estimator: did_had."
                            local __design      "HAD"
                            local __estimator   "did_had"
                            local __had_stayers  1
                        }
                    }
                }
                drop __is_stayer
            }

            * ----- B2b: SSFSD vs SFSD (runs when book=0 OR HAD not detected) -
            if "`__design'" == "" {

            * Within-baseline-treatment SD of Fg (SSFSD vs SFSD/continuous)
            * Note: include all groups here (not just non-always-treated) so the
            * "groups with same d_baseline share a switch date" pattern is detectable.
            bysort __d_baseline: egen __sd_Fg_dbase = sd(__Fg)
            qui sum __sd_Fg_dbase
            scalar __sd_Fg_dbase_val = cond(missing(r(mean)), 0, r(mean))
            drop __sd_Fg_dbase

            if __sd_Fg_dbase_val == 0 {
                * Groups with same d_baseline all switch at same date → continuous option
                di _n as text ///
                    "While your design is a Staggered First Switch Design, where groups " ///
                    "experience their first treatment change at different points in time, " ///
                    "groups with the same period-one treatment all experience their first " ///
                    "treatment change at the same date, perhaps because the period-one " ///
                    "treatment is a continuously distributed variable (groups all have " ///
                    "different period-one treatments). Then, you can still use the " ///
                    "did_multiplegt_dyn package to estimate the treatment's effect, but " ///
                    "you need to specify the continuous option, see Section 8.3.5.1 of " ///
                    "the DID textbook of de Chaisemartin and D'Haultfoeuille."
                di _n as result ///
                    "Your dataset corresponds to Design SFSD (Relaxed SFSD)."
                local __design    "SFSD"
                local __estimator "did_multiplegt_dyn"
            }
            else {
                * Variation in Fg within baseline groups → Strict SFSD
                di _n as result ///
                    "Your dataset corresponds to Design SSFSD (Strict Staggered First Switch Design)."
                di    as text ///
                    "  Use did_multiplegt_dyn. Switch timing varies " ///
                    "  within groups that share the same baseline treatment."
                local __design    "SSFSD"
                local __estimator "did_multiplegt_dyn"
            }

            }  /* end if "`__design'" == "" (B2b SSFSD/SFSD block) */
        }
    }

    * ---------------------------------------------------------------
    * Single exit point: restore dataset and return results
    * ---------------------------------------------------------------
    restore

    * --- Full design label and numeric code (computed at single exit point) --
    * r(design) carries all information: HAD is split into "HAD with stayers"
    * vs "HAD w/o stayers" so callers can use it directly in tables / Excel.
    local __design_label "`__design'"
    if "`__design'" == "HAD" & `__had_stayers'   local __design_label "HAD with stayers"
    if "`__design'" == "HAD" & !`__had_stayers'  local __design_label "HAD w/o stayers"

    local __design_code = 8
    if "`__design'" == "CLA"                     local __design_code = 1
    if "`__design'" == "SAD"                     local __design_code = 2
    if "`__design_label'" == "HAD with stayers"  local __design_code = 3
    if "`__design'" == "SSFSD"                   local __design_code = 4
    if "`__design'" == "SFSD"                    local __design_code = 5
    if "`__design_label'" == "HAD w/o stayers"   local __design_code = 6
    if "`__design'" == "SSD"                     local __design_code = 7
    * (OTHER stays 8)

    di _n as result "========================================="
    di    as result "  CLASSIFICATION : `__design_label' (code=`__design_code')"
    di    as result "  ESTIMATOR      : `__estimator'"
    di    as result "========================================="

    return local  design       "`__design_label'"
    return local  estimator    "`__estimator'"
    return scalar had_stayers   = `__had_stayers'
    return scalar design_code   = `__design_code'

end
