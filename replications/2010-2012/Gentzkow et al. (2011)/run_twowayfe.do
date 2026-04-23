cap log close _all
log using "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Gentzkow et al. (2011)/run_twowayfe.log", text replace
set more off
set matsize 5000

adopath + "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Gentzkow et al. (2011)/20091316_data/external"
loadglob using "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Gentzkow et al. (2011)/20091316_data/code/input_param.txt"
global maxwindow = 1

use "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Gentzkow et al. (2011)/20091316_data/temp/voting_cnty_clean.dta", clear

di "============================================="
di "TABLE 2 REPLICATION"
di "============================================="

define_event x, changein(numdailies) maxchange($maxchange) window(1)

areg D.prestout x_0 if mainsample, absorb(styr) cluster(cnty90)
local b_col2 = _b[x_0]
local se_col2 = _se[x_0]
local n_col2 = e(N)
local nc_col2 = e(N_clust)

areg D.prestout x_0 $demolist $misdemolist if mainsample, absorb(styr) cluster(cnty90)
local b_col3 = _b[x_0]
local se_col3 = _se[x_0]
local n_col3 = e(N)
local nc_col3 = e(N_clust)

areg D.congtout x_0 $demolist $misdemolist if mainsample & abs(D.congtout)<1, absorb(styr) cluster(cnty90)
local b_col4 = _b[x_0]
local se_col4 = _se[x_0]
local n_col4 = e(N)
local nc_col4 = e(N_clust)

di "============================================="
di "TWOWAYFEWEIGHTS"
di "============================================="

keep if mainsample == 1
di "Restricted to mainsample: N = " _N

* T=year version
cap noisily twowayfeweights prestout cnty90 year numdailies, type(feTR)
local tw_rc1 = _rc
if `tw_rc1' == 0 | `tw_rc1' == 402 {
    local tw_beta1  = e(beta)
    mat _M1 = e(M)
    local tw_npos1  = _M1[1,1]
    local tw_nneg1  = _M1[2,1]
    local tw_ntot1  = `tw_npos1' + `tw_nneg1'
    local tw_pneg1 : di %5.1f (100 * `tw_nneg1' / `tw_ntot1')
    di "T=year: beta=" `tw_beta1' ", npos=" `tw_npos1' ", nneg=" `tw_nneg1' ", %neg=" `tw_pneg1'
}
else {
    di "twowayfeweights (T=year) FAILED rc=" `tw_rc1'
    local tw_beta1  = .
    local tw_npos1  = .
    local tw_nneg1  = .
    local tw_pneg1  = "N/A"
}

* T=styr version (matches paper spec)
cap noisily twowayfeweights prestout cnty90 styr numdailies, type(feTR)
local tw_rc2 = _rc
if `tw_rc2' == 0 | `tw_rc2' == 402 {
    local tw_beta2  = e(beta)
    mat _M2 = e(M)
    local tw_npos2  = _M2[1,1]
    local tw_nneg2  = _M2[2,1]
    local tw_ntot2  = `tw_npos2' + `tw_nneg2'
    local tw_pneg2 : di %5.1f (100 * `tw_nneg2' / `tw_ntot2')
    di "T=styr: beta=" `tw_beta2' ", npos=" `tw_npos2' ", nneg=" `tw_nneg2' ", %neg=" `tw_pneg2'
}
else {
    di "twowayfeweights (T=styr) FAILED rc=" `tw_rc2'
    local tw_beta2  = .
    local tw_npos2  = .
    local tw_nneg2  = .
    local tw_pneg2  = "N/A"
}

di "============================================="
di "SUMMARY"
di "============================================="
di "Col 2: beta=" %7.4f `b_col2' " se=" %7.4f `se_col2' " N=" `n_col2'
di "Col 3: beta=" %7.4f `b_col3' " se=" %7.4f `se_col3' " N=" `n_col3'
di "Col 4: beta=" %7.4f `b_col4' " se=" %7.4f `se_col4' " N=" `n_col4'
di "twowayfe T=year: rc=" `tw_rc1'
di "twowayfe T=styr: rc=" `tw_rc2'

log close