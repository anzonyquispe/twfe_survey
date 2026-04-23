cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Dahl and Lochner (2012)/check_vars.log", text replace

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Dahl and Lochner (2012)/MS20050400_data/main.dta", clear

desc, short
di "N obs = " _N

foreach v in d02mathread d02inc012nontax d02eitcsim411new x0 x1 x2 x3 x4 x5 male yrsbirth ddd1 ddd3 black hispanic momid esamp0 estsamp year idchild {
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

di "=== EITC variables ==="
cap ds *eitc*
di "=== D02 variables ==="
cap ds *d02*
di "=== DDD variables ==="
cap ds *ddd*
di "=== SAMP variables ==="
cap ds *samp*
di "=== MATH/READ variables ==="
cap ds *math* *read* *rer* *rec* *piat* *pia*

cap xtset
di "Panel xtset rc = " _rc

log close
