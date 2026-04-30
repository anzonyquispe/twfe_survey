/*==============================================================================
  CHECK_VARS: Fang and Gavazza (2011)
  "Dynamic Inefficiencies in an Employment-Based Health Insurance System"
  AER 101(7), 3047-3077

  FINDING: NOT TWFE
  - Tables 2, 3, 5: Pooled OLS + IV (ivreg2 cue/gmm2s) on MEPS
    repeated cross-sections. Year x region FE only, no unit FE.
  - Table 4: Panel IV with RANDOM effects (xtivreg, re ec2sls)
    on HRS data. NOT fixed effects.
  - Table 6 Col 3: Panel FE with IV (xtivreg2, fe robust) on
    BHPS data. FE present but treatment is endogenous (instrumented).
    NOT simple TWFE.
  - Table 6 Col 4: Dynamic panel GMM (xtabond2).
  - NO table uses simple two-way FE OLS.

  STATUS: No TWFE — skip run_twowayfe.do
==============================================================================*/

clear all
set more off
cap * log close _all

* NOTE: log auto-created by Stata -b mode

di "=============================================="
di "  Fang and Gavazza (2011) - NOT TWFE"
di "=============================================="
di ""
di "Paper: Dynamic Inefficiencies in an Employment-Based"
di "       Health Insurance System"
di "AER 101(7), 3047-3077"
di ""
di "REASON: All empirical specifications use IV/GMM:"
di ""
di "  Tables 2,3,5 (MEPS data):"
di "    Spec 1: reg lmexp ltenu ... i.y_r, robust (pooled OLS, no unit FE)"
di "    Spec 2: ivreg2 lmexp (ltenu=iv*) i.y_r, cue robust (IV)"
di "    Spec 3: ivreg2 d.lmexp (d.ltenu=iv*) i.y_r, gmm2s (FD-IV)"
di ""
di "  Table 4 (HRS data):"
di "    xtivreg logmd (ljlten=*death_r int*), re ec2sls (RE-IV)"
di ""
di "  Table 6 (BHPS data):"
di "    Col 1: reg md2 logt ..., robust (pooled OLS, no unit FE)"
di "    Col 2: ivreg md2 (logt=logt_ins) ..., cluster (pooled IV)"
di "    Col 3: xtivreg2 md2 (logt=logt_ins) ..., fe robust (FE-IV)"
di "    Col 4: xtabond2 md2 l.md2 ... (dynamic panel GMM)"
di ""
di "Key issue: Treatment (log tenure) is always endogenous,"
di "instrumented by group-mean tenure or firm death rates."
di "No table has simple Y = a_i + g_t + b*D + e structure."
di ""
di "STATUS: No TWFE"
di "=============================================="

* log close _all
