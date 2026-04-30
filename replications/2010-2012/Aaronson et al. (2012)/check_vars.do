/*==============================================================================
  CHECK_VARS: Aaronson, Agarwal, and French (2012)
  "The Spending and Debt Response to Minimum Wage Hikes"
  AER 102(7), 3111-3139

  FINDING: NOT TWFE
  - Tables 1, 2, 5 use pooled OLS and IV (ivreg2 cue/gmm2s)
    with year x region dummies. NO individual/unit fixed effects.
  - Treatment (log tenure) is endogenous, always instrumented.
  - Table 5 uses proprietary credit card data (unavailable).
  - SS_pooled_regs_fe.do uses HH FE on SIMULATED data only.
  - Empirical programs in AER_FINAL_PROGRAMS.zip (CEX/CPS/SIPP).
  - All available .do files confirm: no panel FE specification.

  STATUS: No TWFE — skip run_twowayfe.do
==============================================================================*/

clear all
set more off
cap * log close _all

* NOTE: log auto-created by Stata -b mode

di "=============================================="
di "  Aaronson et al. (2012) - NOT TWFE"
di "=============================================="
di ""
di "Paper: The Spending and Debt Response to Minimum Wage Hikes"
di "AER 102(7), 3111-3139"
di ""
di "REASON: All empirical specifications use:"
di "  - Pooled OLS with year x region FE (no unit FE)"
di "  - IV/GMM (ivreg2 cue, gmm2s) with firm death instruments"
di "  - First-differenced IV (no level FE)"
di ""
di "Code evidence:"
di "  tables2_3_5.do line 380: reg lmexp ltenu ... i.y_r, robust"
di "  tables2_3_5.do line 382: ivreg2 lmexp (ltenu=iv*) i.y_r, cue robust"
di "  tables2_3_5.do line 384: ivreg2 d.lmexp (d.ltenu=iv*) i.y_r, gmm2s"
di ""
di "Additional issues:"
di "  - Table 5 credit card data is proprietary"
di "  - AER_FINAL_PROGRAMS.zip contains main empirical code"
di "  - Data files (.gz) need decompression"
di ""
di "STATUS: No TWFE"
di "=============================================="

* log close _all
