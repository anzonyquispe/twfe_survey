cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Gentzkow et al. (2011)/check_vars.log", text replace

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Gentzkow et al. (2011)/20091316_data/temp/voting_cnty_clean.dta", clear

desc, short
di "N obs = " _N

foreach v in cnty90 year state styr numdailies prestout congtout presrepshare congrepshare readshare_hhld mainsample mainsample_circ {
    cap confirm variable `v'
    if _rc == 0 {
        di "`v': EXISTS"
        qui sum `v'
        di "  N=" r(N) " mean=" r(mean) " min=" r(min) " max=" r(max)
    }
    else {
        di "`v': MISSING"
    }
}

* Check panel structure
xtset
di "---"
tab year

log close
