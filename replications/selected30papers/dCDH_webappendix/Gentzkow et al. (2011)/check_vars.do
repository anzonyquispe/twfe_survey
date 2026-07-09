cap log close _all
* --- Auto-detect user / set repo paths --------------------------------
* Add a branch with your OS username if you're a new collaborator.
if "`c(username)'" == "anzony.quisperojas" {
    global twfe_root   "/Users/anzony.quisperojas/Documents/GitHub/twfe_survey"
    global papers_root "/Users/anzony.quisperojas/Documents/GitHub/papers_economic"
}
else if "`c(username)'" == "Usuario" {
    global twfe_root   "C:/Users/Usuario/Documents/GitHub/twfe_survey"
    global papers_root "C:/Users/Usuario/Documents/GitHub/papers_economic"
}
else {
    di as error "Unknown user `c(username)'. Add your repo paths to the user-detection block at the top of this dofile."
    exit 198
}
* ---------------------------------------------------------------------

log using "${twfe_root}/replications/2010-2012/Gentzkow et al. (2011)/check_vars.log", text replace

use "${twfe_root}/data/2010-2012/Gentzkow et al. (2011)/20091316_data/temp/voting_cnty_clean.dta", clear

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
