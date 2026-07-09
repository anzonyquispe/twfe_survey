*! classify_sketch2 v0.3 (2026-07-02)
*! Classify a (Y, G, T, D) panel by attempting to run the estimators.
*!
*! Algorithm:
*!   1. Run did_multiplegt_dyn Y G T D.
*!        Check e(N_effect_1): must be non-missing and > 0.
*!   2. If OK → compute V(Fg|Fg<=T), V(D_g1), binary, absorbing:
*!        3. V==0, V_Dg1==0, binary globally          → CLA
*!        4. V==0, V_Dg1==0, non-binary at switch date → HAD with stayers
*!        5. V>0,  binary & absorbing                  → SAD
*!        6. (none of 3-5)                             → SFSD
*!   7. If e(N_effect_1) missing/0 or dyn failed →
*!        run did_multiplegt_dyn, continuous(1); check e(N_effect_1) > 0.
*!        If OK → SFSD.
*!   8. If continuous also fails & V==0 & V_Dg1==0 → run did_had (noisily,
*!        for quasi-stayer test). If OK → HAD w/o stayers.
*!   9. Otherwise → OTHER.
*!
*! Syntax:  classify_sketch2 Y G T D
*!   T is grouped (normalised to consecutive integers) before any analysis.
*!
*! Returns (via r()):
*!   r(design)      "CLA"|"SAD"|"HAD with stayers"|"SFSD"|"HAD w/o stayers"|"OTHER"
*!   r(estimator)   "did_multiplegt_dyn"|"did_had"|""
*!   r(had_stayers) 1 if HAD detected after dropping stayers, else 0
*!   r(design_code) 1=CLA  2=SAD  3=HAD-with-stayers  4=SFSD(dyn)
*!                  5=SFSD(continuous)  6=HAD-w/o-stayers  8=OTHER

program define classify_sketch2, rclass
    version 13
    syntax varlist(min=4 max=4 numeric)

    tokenize `varlist'
    local Y  "`1'"
    local G  "`2'"
    local T  "`3'"
    local D  "`4'"

    di _n as text "===== classify_sketch2 ====="
    di    as text "  Y=`Y'  G=`G'  T=`T'  D=`D'"

    preserve
	
	* -----------------------------------------------------------------------
    * 0. Normalize T to consecutive integers (always done first)
    * -----------------------------------------------------------------------
    tempvar __Tnorm
    qui egen `__Tnorm' = group(`T')
    qui replace `T' = `__Tnorm'
    drop `__Tnorm'

    * -----------------------------------------------------------------------
    * 1. Prepare working dataset
    * -----------------------------------------------------------------------
    keep `Y' `G' `T' `D'
    drop if missing(`G') | missing(`T')

    * -----------------------------------------------------------------------
    * 0b. Ensure unique G-T pairs (collapse to means if not)
    * -----------------------------------------------------------------------
    cap isid `G' `T'
    if _rc {
        di as text "  [Note] Not unique by `G' `T' — collapsing to group-time means."
        collapse (mean) `Y' `D', by(`G' `T')
    }

    
    qui sum `T'
    local Tmax   = r(max)
    local Tplus1 = r(max) + 1
    local Tmin   = r(min)

    * -----------------------------------------------------------------------
    * 2. Baseline treatment D_g1 (D at Tmin per group)
    * -----------------------------------------------------------------------
    tempvar __d1 __Dg1
    qui bysort `G': egen `__Dg1' = min(`D')

    * -----------------------------------------------------------------------
    * 3. Fg: first T where D changes from baseline (Tplus1 if never)
    * -----------------------------------------------------------------------
    tempvar __tc __Fg
    qui gen `__tc' = `T' if `D' != . & `D' != `__Dg1'
    qui replace `__tc' = `Tplus1' if missing(`__tc')
    qui bysort `G': egen `__Fg' = min(`__tc')
	bysort `G': egen Fgaux = mean(`__Fg')
	replace `__Fg' = Fgaux if `__Fg' == . // Same Fg to all g's
	replace `__Fg' = `Tmax' + 1 if `__Fg' == . // Never switchers
    drop `__tc' Fgaux

    * -----------------------------------------------------------------------
    * 4. D_Fg: treatment value at switch date
    * -----------------------------------------------------------------------
    tempvar __dFgtmp __DFg
    qui gen  `__dFgtmp' = `D' if `T' == `__Fg'
    qui bysort `G': egen `__DFg' = min(`__dFgtmp') // Same D_Fg to all switchers g
    drop `__dFgtmp'

    * -----------------------------------------------------------------------
    * 5. Group-level summary statistics (one obs per group)
    * -----------------------------------------------------------------------
    tempvar __first
    qui bysort `G': gen `__first' = (_n == 1)

    * V(Fg | Fg <= Tmax): variance of Fg among switchers, group-level
    qui sum `__Fg' if `__first' & `__Fg' <= `Tmax' // we are working with switchers and only one observation per group
    local n_switchers = r(N)
    local V_Fg_cond   = r(Var)
    local t_star      = cond(r(N) > 0, r(mean), `Tplus1')

    * V(D_g1): variance of baseline treatment, group-level (all groups)
    qui sum `__Dg1' if `__first'
    local V_Dg1 = r(Var)

    * V(D_g1 | switchers): variance of Dg1 among switchers only (Fg <= Tmax)
    qui sum `__Dg1' if `__first' & `__Fg' <= `Tmax'
    local V_Dg1_sw   = cond(missing(r(Var)), 0, r(Var))
    local Dg1_sw_val = r(mean)          // common baseline value when V==0

    * At least one non-switcher (Fg > Tmax) has Dg1 == Dg1_sw_val
    if missing(`Dg1_sw_val') {
        local Dg1_ns_match = 0          // no switchers → condition fails
    }
    else {
        qui count if `__first' & `__Fg' > `Tmax' ///
            & !missing(`__Dg1') & abs(`__Dg1' - `Dg1_sw_val') <= 1e-8
        local Dg1_ns_match = (r(N) > 0)
    }

    * Binary: D takes only {d_min, d_max} across ALL observations FORCING TO TAKE ONLY TWO VALUES
	* THIS COULD BE FROM 4 TO 9 OR 5 TO 8 WE ARE NOT EXPLICITLY ASSUMING 0 AND 1
    qui sum `D'
    local d_max = r(max)
    local d_min = r(min)
    tempvar __bchk
    qui gen `__bchk' = (`D' == `d_max' | `D' == `d_min') if !missing(`D')
    qui sum `__bchk'
    local binary = (r(mean) == 1)
    drop `__bchk'

    * Binary at switch date: D takes only 2 values at T == t_star
    qui sum `D' if `T' == `t_star'
    if r(N) == 0 {
        local binary_at_switch = 1
    }
    else {
        local d_max_ts = r(max)
        local d_min_ts = r(min)
        tempvar __bchk_ts
        qui gen `__bchk_ts' = (`D'==`d_max_ts' | `D'==`d_min_ts') ///
            if `T' == `t_star' & !missing(`D')
        qui sum `__bchk_ts'
        local binary_at_switch = (r(mean) == 1)
        drop `__bchk_ts'
    }

    * Absorbing: after Fg, D stays at D_Fg
    tempvar __abs_chk
    qui gen `__abs_chk' = (`D' == `__DFg') if `T' > `__Fg' & !missing(`D') & !missing(`__DFg')
    qui sum `__abs_chk' if !missing(`__DFg')
    local absorbing = cond(missing(r(min)), 1, r(min) == 1)
    drop `__abs_chk'

    * ---- Drop working variables: leave only Y G T D for estimators --------
    drop `__first' `__Fg' `__Dg1' `__DFg'

    * ---- Diagnostics -------------------------------------------------------
    di as text "  n_switchers    = `n_switchers'"
    di as text "  V(Fg|Fg<=T)    = `V_Fg_cond'"
    di as text "  V(D_g1) all    = `V_Dg1'"
    di as text "  V(D_g1|sw)     = `V_Dg1_sw'  (switchers only)"
    di as text "  Dg1_sw_val     = `Dg1_sw_val'"
    di as text "  Dg1_ns_match   = `Dg1_ns_match'  (>=1 non-switcher has Dg1=Dg1_sw_val)"
    di as text "  binary (all)   = `binary'"
    di as text "  binary at t*   = `binary_at_switch'  (t*=`t_star')"
    di as text "  absorbing      = `absorbing'"

    * -----------------------------------------------------------------------
    * Classification: driven by whether estimators run
    * -----------------------------------------------------------------------
    local __design      ""
    local __estimator   ""
    local __had_stayers  0
    local __design_code  8

    * ======================== Step 1: run dyn (no options) ==================
    di _n as text "  [Step 1] did_multiplegt_dyn `Y' `G' `T' `D' ..."
    ereturn clear
    cap qui did_multiplegt_dyn `Y' `G' `T' `D'
    local __rc_dyn = _rc

    local __dyn_ok = 0
    if `__rc_dyn' == 0 {
        local __N1_dyn = e(N_effect_1)
        if !missing(`__N1_dyn') & `__N1_dyn' > 0 {
            di as text "           → OK  (e(N_effect_1)=`__N1_dyn')"
            local __dyn_ok = 1
        }
        else {
            di as text "           → ran but e(N_effect_1) missing or 0 — treated as failed"
        }
    }
    else {
        di as text "           → FAILED (rc=`__rc_dyn')"
    }

    if `__dyn_ok' {

        * --- Condition 3: CLA -----------------------------------------------
        if `V_Fg_cond' == 0 & `V_Dg1' == 0 & `binary' {
            di _n as result "Design CLA: V(Fg|Fg<=T)=0, V(D_g1)=0, binary treatment."
            local __design      "CLA"
            local __estimator   "did_multiplegt_dyn"
            local __design_code  1
        }
        * --- Condition 4: HAD with stayers -----------------------------------
        * V(Fg|Fg<=T)==0         : all switchers share the same switch date t*
        * V(Dg1|sw)==0           : switchers all start from the same baseline
        * Dg1_ns_match==1        : at least one non-switcher has Dg1 = Dg1_sw_val
        * !binary_at_switch      : treatment at t* is not binary (multi-valued)
        else if `V_Fg_cond' == 0 & `V_Dg1_sw' == 0 & `Dg1_ns_match' & !`binary_at_switch' {
            di _n as result ///
                "Design HAD with stayers: V(Fg|Fg<=T)=0, V(Dg1|sw)=0, " ///
                "non-switchers share Dg1=`Dg1_sw_val', non-binary at t*=`t_star'."
            local __design      "HAD with stayers"
            local __estimator   "did_had"
            local __had_stayers  1
            local __design_code  3
        }
        * --- Condition 5: SAD -----------------------------------------------
        else if `V_Fg_cond' > 0 & `binary' & `absorbing' {
            di _n as result ///
                "Design SAD: V(Fg|Fg<=T)>0, binary and absorbing treatment."
            local __design      "SAD"
            local __estimator   "did_multiplegt_dyn"
            local __design_code  2
        }
        * --- Condition 6: SFSD (generic) ------------------------------------
        else {
            di _n as result ///
                "Design SFSD: did_multiplegt_dyn ran; conditions 3-5 not met."
            local __design      "SSFSD"
            local __estimator   "did_multiplegt_dyn"
            local __design_code  4
        }
    }

    * ======================== dyn failed / N_effect_1 invalid → Step 7 ======
    else {

        * --- Step 7: continuous(1) ------------------------------------------
        di _n as text "  [Step 7] did_multiplegt_dyn `Y' `G' `T' `D', continuous(1) ..."
        ereturn clear
        cap qui did_multiplegt_dyn `Y' `G' `T' `D', continuous(1)
        local __rc_cont = _rc

        local __cont_ok = 0
        if `__rc_cont' == 0 {
            local __N1_cont = e(N_effect_1)
            if !missing(`__N1_cont') & `__N1_cont' > 0 {
                di as text "           → OK  (e(N_effect_1)=`__N1_cont')"
                local __cont_ok = 1
            }
            else {
                di as text "           → ran but e(N_effect_1) missing or 0 — treated as failed"
            }
        }
        else {
            di as text "           → FAILED (rc=`__rc_cont')"
        }

        if `__cont_ok' {
            di _n as result ///
                "Design SFSD (continuous): did_multiplegt_dyn continuous(1) ran."
            local __design      "SFSD"
            local __estimator   "did_multiplegt_dyn"
            local __design_code  5
        }

        * ======================== continuous also failed =====================
        else {

            * --- Step 8: HAD w/o stayers ------------------------------------
			* We  should conditioning the Dg1 only for  -- only switchers  have V(Dg1 = 0 | Fg<= Tmax)
			* For every g such that Fg >= Tmax Dg1 == Dg'1 where g' are those that Fg <= Tmax
		
            if `V_Fg_cond' == 0 & `V_Dg1' == 0 {
                di _n as text ///
                    "  [Step 8] V(Fg|Fg<=T)=0, V(D_g1)=0 → checking did_had ..."
                di    as text ///
                    "           did_had `Y' `G' `T' `D' (output shown for quasi-stayer test):"
                cap noisily did_had `Y' `G' `T' `D'
                local __rc_had = _rc
				local neffec = e(estimates)[1, 5]
				local hadpass = cond(`neffec' > 0  & `neffec' != . , 1, 0)

                if `hadpass' == 1 {
                    di _n as result "Design HAD w/o stayers: did_had ran."
                    local __design      "HAD w/o stayers"
                    local __estimator   "did_had"
                    local __had_stayers  0
                    local __design_code  6
                }
                else {
                    di as text "           did_had → FAILED (rc=`__rc_had')"
                    di _n as result "Design OTHER: did_had did not run."
                    local __design      "OTHER"
                    local __estimator   ""
                    local __design_code  8
                }
            }

            * --- Step 9: V conditions not met → OTHER -----------------------
            else {
                di _n as result ///
                    "Design OTHER: V(Fg|Fg<=T)>0 or V(D_g1)>0 and no estimator ran."
                local __design      "OTHER"
                local __estimator   ""
                local __design_code  8
            }
        }
    }

    * -----------------------------------------------------------------------
    * Exit
    * -----------------------------------------------------------------------
    restore

    di _n as result "========================================="
    di    as result "  CLASSIFICATION : `__design' (code=`__design_code')"
    di    as result "  ESTIMATOR      : `__estimator'"
    di    as result "========================================="

    return local  design       "`__design'"
    return local  estimator    "`__estimator'"
    return scalar had_stayers   = `__had_stayers'
    return scalar design_code   = `__design_code'

end
