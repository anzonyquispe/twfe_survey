*! classify_design v0.1  (2026-05-19)
*! Classify a (G, T, D) panel into one of:
*!   CLA  - Classical DID
*!   SAD  - Staggered Adoption Design
*!   SFSD - Staggered First Switch Design  (subtype: SSFSD or RSFSD)
*!   HAD  - Heterogeneous Adoption Design
*! Falls through to "Other" if none of the above match.
*!
*! Syntax:
*!   classify_design g t D
*!
*! Returned scalars / locals:
*!   r(design)   - "CLA" | "SAD" | "SFSD" | "HAD" | "Other"
*!   r(subtype)  - "SSFSD" | "RSFSD"  (only when r(design) == "SFSD")
*!
*! Variables generated (kept in dataset, prefixed with _):
*!   _G _T _D                          - ranked group/time + treatment
*!   _diff_D                           - D - L.D within group
*!   _D_g1                             - baseline treatment (D at first period)
*!   _F_g                              - first-switch time; T_max + 1 if never
*!   _ever_change                      - 1 if group ever switched
*! Design-specific:
*!   CLA  : _T0, _treated_group
*!   SAD  : _ever_treated
*!   SFSD : _design_subtype
*!   HAD  : _t_star, _D_star, _dose_positive, _design_HAD

program define classify_design, rclass
    version 13
    syntax varlist(min=3 max=3 numeric)

    tokenize `varlist'
    local G "`1'"
    local T "`2'"
    local D "`3'"

    di _n as text "===== classify_design ====="
    di as text "  Group  : `G'"
    di as text "  Time   : `T'"
    di as text "  Treat  : `D'"

    * --- Drop any pre-existing workspace variables -------------------------
    foreach v in _G _T _D _diff_D _D_g1 _F_g _ever_change ///
                 _T0 _treated_group _ever_treated ///
                 _design_subtype ///
                 _t_star _D_star _dose_positive _design_HAD {
        capture drop `v'
    }

    quietly {

    * --- Index G and T as ranked integers (mimics did_multiplegt_dyn) ------
    egen _G = group(`G')
    egen _T = group(`T')
    gen  _D = `D'

    * --- Collapse duplicates in (_G, _T) so xtset succeeds ----------------
    bysort _G _T: keep if _n == 1

    xtset _G _T

    sum _T, meanonly
    scalar __Tmin = r(min)
    scalar __Tmax = r(max)

    * --- _diff_D = D_{g,t} - D_{g,t-1} -------------------------------------
    gen _diff_D = _D - L._D

    * --- _D_g1 = D at first period (per group) -----------------------------
    tempvar tmp
    gen `tmp' = _D if _T == __Tmin
    bysort _G: egen _D_g1 = mean(`tmp')
    drop `tmp'

    * --- _F_g = first t where _diff_D != 0; T_max + 1 if never -------------
    tempvar tchange
    gen `tchange' = _T if _diff_D != 0 & _diff_D != .
    bysort _G: egen _F_g = min(`tchange')
    replace _F_g = __Tmax + 1 if missing(_F_g)
    drop `tchange'

    * --- _ever_change indicator -------------------------------------------
    gen _ever_change = (_F_g <= __Tmax)

    }  /* end quietly */

    * ====================== CLA test ======================================
    * Conditions (silently ignore always-treated, _D_g1 != 0):
    *   (a) all non-missing _diff_D in {0, 1} for groups with _D_g1 == 0
    *   (b) at least one group with _D_g1 == 0 and _F_g <= T_max (treated)
    *   (c) at least one group with _D_g1 == 0 and _F_g >  T_max (control)
    *   (d) all treated groups share the same _F_g (a single T_0+1)
    qui count if _D_g1 == 0 & !missing(_diff_D) & !inlist(_diff_D, 0, 1)
    local cla_binary_violations = r(N)

    qui levelsof _F_g if _D_g1 == 0 & _F_g <= __Tmax, local(__switch_dates)
    local n_switch_dates : word count `__switch_dates'

    qui count if _D_g1 == 0 & _F_g <= __Tmax
    local has_switchers   = (r(N) > 0)
    qui count if _D_g1 == 0 & _F_g >  __Tmax
    local has_controls    = (r(N) > 0)

    if `cla_binary_violations' == 0 & `has_switchers' & `has_controls' & `n_switch_dates' == 1 {

        local T0_switchval : word 1 of `__switch_dates'
        local T0_val = `T0_switchval' - 1
        gen _T0 = `T0_val'
        gen _treated_group = (_F_g <= __Tmax)

        di _n as result "Your dataset corresponds to Design CLA (Classical DID)."
        di as text     "  All treated groups switch at t = `T0_switchval' (T_0 = `T0_val')."
        di as text     "  Binary, absorbing treatment with a single common adoption date."

        return local design  "CLA"
        return scalar T0     = `T0_val'
        return scalar Tmin   = __Tmin
        return scalar Tmax   = __Tmax
        exit
    }

    * ====================== SAD test ======================================
    * Same binarity + restriction as CLA, but >= 2 distinct switch dates.
    if `cla_binary_violations' == 0 & `has_switchers' & `n_switch_dates' >= 2 {

        gen _ever_treated = (_F_g <= __Tmax)

        di _n as result "Your dataset corresponds to Design SAD (Staggered Adoption Design)."
        di as text     "  Distinct switch dates among treated groups: `n_switch_dates'."
        di as text     "  Binary, absorbing treatment with heterogeneous adoption timing."

        return local design "SAD"
        return scalar Tmin  = __Tmin
        return scalar Tmax  = __Tmax
        exit
    }

    * ====================== SFSD test =====================================
    * No binarity restriction. Use the FIX agreed with the user:
    *   Var(_F_g | _F_g <= T_max) > 0   (variation among switchers).
    qui sum _F_g if _F_g <= __Tmax
    local switch_var = cond(missing(r(Var)), 0, r(Var))
    qui count if _F_g <= __Tmax
    local n_switchers = r(N)

    if `n_switchers' >= 2 & `switch_var' > 0 {

        * Sub-classify: SSFSD if there's some _D_g1 value within which F_g varies
        tempvar within_sd
        bysort _D_g1: egen `within_sd' = sd(_F_g) if _F_g <= __Tmax
        qui sum `within_sd'
        local max_within_sd = cond(missing(r(max)), 0, r(max))
        drop `within_sd'

        if `max_within_sd' > 0 {
            gen _design_subtype = "SSFSD"
            di _n as result "Your dataset corresponds to Design SFSD (subtype: SSFSD)."
            di as text     "  Switch-timing varies conditional on baseline treatment _D_g1."
            return local design  "SFSD"
            return local subtype "SSFSD"
        }
        else {
            gen _design_subtype = "RSFSD"
            di _n as result "Your dataset corresponds to Design SFSD (subtype: RSFSD)."
            di as text     "  Switch-timing varies unconditionally but is constant within _D_g1."
            return local design  "SFSD"
            return local subtype "RSFSD"
        }

        return scalar Tmin = __Tmin
        return scalar Tmax = __Tmax
        exit
    }

    * ====================== HAD test ======================================
    * Pre-period zero + common adoption period + heterogeneous dose.
    qui sum _T if _D > 0 & !missing(_D), meanonly
    if r(N) > 0 {
        local t_star = r(min)

        * Guard: t* must be strictly after the first observed period.
        if `t_star' <= __Tmin {
            di _n as error "Design could not be classified into CLA, SAD, SFSD, or HAD."
            di as text     "  (Degenerate HAD candidate: t* = Tmin = `t_star'.)"
            return local design "Other"
            return scalar Tmin = __Tmin
            return scalar Tmax = __Tmax
            exit
        }

        * (a) D == 0 for all (g, t < t*)
        qui count if !missing(_D) & _D != 0 & _T < `t_star'
        local pre_violations = r(N)

        * (b) E(D | T == t*) > 0
        qui sum _D if _T == `t_star'
        local mean_D_tstar = cond(missing(r(mean)), 0, r(mean))

        * (c) Var(D | T == t*, D > 0) > 0
        qui sum _D if _T == `t_star' & _D > 0
        local var_D_tstar_pos = cond(missing(r(Var)), 0, r(Var))
        qui count if _T == `t_star' & _D > 0
        local n_pos_at_tstar = r(N)

        if `pre_violations' == 0 & `mean_D_tstar' > 0 & `n_pos_at_tstar' >= 2 & `var_D_tstar_pos' > 0 {

            gen _t_star = `t_star'
            tempvar dtmp
            gen `dtmp' = _D if _T == `t_star'
            bysort _G: egen _D_star = mean(`dtmp')
            drop `dtmp'
            gen _dose_positive = (_D_star > 0)
            gen _design_HAD = 1

            di _n as result "Your dataset corresponds to Design HAD (Heterogeneous Adoption Design)."
            di as text     "  Common adoption period t* = `t_star' (ranked time)."
            di as text     "  E[D|t*] = " %9.4f `mean_D_tstar' ", Var[D|t*, D>0] = " %9.4f `var_D_tstar_pos'
            di as text     "  Groups receiving a positive dose at t*: `n_pos_at_tstar'."

            return local design "HAD"
            return scalar t_star = `t_star'
            return scalar Tmin   = __Tmin
            return scalar Tmax   = __Tmax
            exit
        }
    }

    * ====================== None matched ==================================
    di _n as error "Design could not be classified into CLA, SAD, SFSD, or HAD."
    return local design "Other"
    return scalar Tmin  = __Tmin
    return scalar Tmax  = __Tmax

end
