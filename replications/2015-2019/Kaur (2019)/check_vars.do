/*=============================================================================
  CHECK VARIABLES: Kaur (2019)
  "Nominal Wage Rigidity in Village Labor Markets"
  AER 109(10), 3585-3616

  Verifies datasets and key variables for TWFE replication.
  Main spec: Table 1, Col 1 (WB data)
    reg lwage i.dist i.year amons80 bmons20, cluster(regionyr)
=============================================================================*/

clear all
set more off
cap log close _all

log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Kaur (2019)/check_vars.log", text replace

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Kaur (2019)/data/4.Replication-files"

* ─── DATASET 1: World Bank (11 MB) ──────────────────────────────────────────
di _n "============================================================"
di "  DATASET: data_wb_replication.dta"
di "============================================================"
use "$datadir/data_wb_replication.dta", clear

di "Observations: " _N
describe, short

* Key variables for Table 1
di _n "--- lwage (outcome) ---"
sum lwage, detail

di _n "--- amons80 (treatment: above monsoon 80th pctile) ---"
sum amons80, detail

di _n "--- bmons20 (other treatment: below monsoon 20th pctile) ---"
sum bmons20, detail

di _n "--- dist (unit FE) ---"
qui tab dist
di "Number of districts: " r(r)

di _n "--- year (time FE) ---"
tab year

di _n "--- regionyr (cluster variable) ---"
qui tab regionyr
di "Number of region-year clusters: " r(r)

* Check missingness for regression sample
di _n "--- Missing values check ---"
count if missing(lwage)
count if missing(amons80)
count if missing(bmons20)
count if missing(dist)
count if missing(year)
count if missing(regionyr)

* Quick Table 1 Col 1 replication
di _n "--- Quick replication: Table 1, Col 1 ---"
reg lwage i.dist i.year amons80 bmons20, cluster(regionyr)
di "  beta(amons80) = " _b[amons80]
di "  se(amons80)   = " _se[amons80]
di "  beta(bmons20) = " _b[bmons20]
di "  se(bmons20)   = " _se[bmons20]
di "  N             = " e(N)

di _n "============================================================"
di "  CHECK COMPLETE"
di "============================================================"

log close
