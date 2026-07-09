
clear all
set more off
cap log close _all

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

global logdir   "$twfe_root/replications"


do "$twfe_root/classify_did.ado"

log using "$logdir/all_replications.log", text replace

** Acemoglu 20111 panelgtd is perfect
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Acemoglu et al. (2011)"
use "$outdir/panel_GTD.dta", clear
reghdfe  Y c.D##ib1.T, abs( G T ) // replicates column 4 unweighted for all observations
classify_did Y G T D



** Algan 2010 // panel gtd perfect
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Algan and Cahuc (2010)"
use "$outdir/panel_GTD.dta", clear
did_multiplegt_dyn Y G T D
did_had Y G T D

tab T 

tab D if T ==1 
bys G: egen vart = sd(D)
xtset G T 
gen lagD = L.D
replace lagD = 0 if lagD ==.
gen diffD = D- lagD

bys G: egen vart = sd(D)

bys G: egen vart = sd(D)




reg Y D i.G, nocons
bys G: egen vart = sd(D)
hist D if vart == 0

drop if vart == 0
classify_did Y G T D
did_multiplegt_dyn Y G T D, continuous(0)


** Simcoe 2012 panelgtd requires these controls to replicate results
do "$twfe_root/classify_did.ado"
global outdir  "$twfe_root/replications/2010-2012/Simcoe (2012)"
use "$outdir/panel_GTD.dta", clear
reghdfe  Y D TR DOSE  nsrfc-st_aut3 , abs( FE T  ) cluster(G)
classify_did Y G T D
did_multiplegt_dyn  Y G T D




** enikolopov 2011 // panel gtd perfect
do "$twfe_root/classify_did.ado"
global paperdir "$twfe_root/data/2010-2012/Enikolopov et al. (2011)"
global outdir   "$twfe_root/replications/2010-2012/Enikolopov et al. (2011)"
use "$outdir/panel_GTD.dta", clear
stute_test Y D
did_had Y G T D, yatchew
bys G: egen vart = sd(D)
replace vart = 0 if vart == .
drop if vart == 0


classify_did Y G T D
did_multiplegt_dyn  Y G T D, continuous(1)


** Forman et al. 2012 // panel gtd perfect
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Forman et al. (2012)"
use "$outdir/panel_GTD.dta", clear
save "$outdir/panel_GTD.dta", replace
replace Y = 0 if T == 1
bys T: sum Y


did_multiplegt_dyn  Y G T D
tab D if T == 1
tab D if T == 2

gen aux =  T == 2 & D == 0
bys G: egen meanaux = mean(aux)
drop if meanaux == 1

reghdfe Y D, absorb( T ) cluster (G)
bys G: egen vart = sd(D)
drop if vart == 0
did_had Y G T D


// count if D == 0 & T == 2
// count if D == 0 & T == 1 
// drop if D == 0 & T == 2
did_multiplegt_dyn Y G T D, continuous(2)
classify_did Y G T D


** Baum Snowandlutz 2011 // panel gtd perfect
global outdir  "$twfe_root/replications/2010-2012/Baum-SnowandLutz(2011)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb( G T ) cluster(G)
classify_did Y G T D
did_multiplegt_dyn Y G T D, effects(4) placebo(3)


** Besley & Muller 2012 // panel gtd perfect
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Besley and Mueller (2012)"
use "$outdir/panel_GTD.dta", clear
tab D if T == 1
tab D if T == 2
reghdfe Y D, absorb( G T ) cluster(G)
bys G: egen vart = sd(D)
xtset G T 
gen lagD = L.D
replace lagD = 0 if lagD ==.
gen diffD = D- lagD

bys G: egen vart = sd(D)

bys G: egen vart = sd(D)
drop if vart == 0
did_had Y G T D
classify_did Y G T D
did_multiplegt_dyn Y G T D, effects(4) placebo(3)


** Dinkelman missing // panel gtd perfect
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Dinkelman (2011)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb( G T ) cluster(cluster)
tab 
classify_did Y G T D
did_multiplegt_dyn Y G T D, effects(4) placebo(3)


** Faye & Niehaus
global outdir  "$twfe_root/replications/2010-2012/Faye and Niehaus (2012)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb( G T ) cluster(G)
classify_did Y G T D
did_multiplegt_dyn Y G T D, effects(4) placebo(3)

xtset G T 
gen lagD = L.D
replace lagD = 0 if lagD ==.
gen diffD = D- lagD

** Gentzkow is missing but it has correct clasification
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Gentzkow et al. (2011)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb( FE1 ) cluster(G)
areg  Y D, absorb( FE1 ) cluster(G)
classify_did Y G T D
did_multiplegt_dyn Y G T D, effects(4) placebo(3)





// ** Bagwell Panel is perfect but this is not twfe
// global outdir   "$twfe_root/replications/2010-2012/Bagwell and Staiger (2011)"
// use "$outdir/panel_GTD.dta", clear
// reghdfe Y D control1, absorb( G T ) cluster(G)
// classify_did Y G T D
// tab T D
// did_multiplegt_stat Y G T D



** Wang 2011 Panel is perfect
do "$twfe_root/classify_did.ado"
global outdir "$twfe_root/replications/2010-2012/Wang (2011)"
use "$outdir/panel_GTD.dta", clear


reghdfe Y D regime2 log_mismatchpre logwage_broadhh-age_head3, absorb( G#T ) cluster(G)

did_multiplegt_stat Y cluster T D
did_multiplegt_dyn Y cluster T D, continuous(1)
did_multiplegt_dyn Y cluster T D
did_had Y cluster T D
classify_did Y cluster T D

collapse (mean) D Y, by(G T )
did_multiplegt_stat Y G T D
did_multiplegt_dyn Y G T D
did_multiplegt_dyn Y G T D, continuous(1)

classify_did Y G T D
did_had Y G T D



** Duranton 2011
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Duranton and Turner (2011)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D , absorb(  T) 
bys G: egen vart = sd(D)
drop if vart == 0
did_had Y G T D
classify_did Y G T D
did_multiplegt_dyn Y G T D



**** Moser and voena
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Moser and Voena (2012)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D control, absorb( G T) cluster(G)
classify_did Y G T D
did_multiplegt_dyn Y G T D



**** Hornbeck 2012
do "$twfe_root/classify_did.ado"
global outdir   "$twfe_root/replications/2010-2012/Hornbeck (2012)"
use "$outdir/panel_GTD.dta", clear
did_had Y G T D, yatchew
reghdfe Y D [aweight=farmland_weight], absorb( G T) cluster(G)
classify_did Y G T D
did_multiplegt_dyn Y G T D




** Zhang and Zhu 2011
** we are replicating only column 4 of table 3 damian needs to add all the columns
global outdir   "$twfe_root/replications/2010-2012/Zhang and Zhu (2011)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D Post TR control* , absorb( G T) 
tab T D
classify_did Y G T D
did_multiplegt_dyn Y G T D






********** 2015-2019 **********
** Antecol 2018
global outdir   "$twfe_root/replications/2015-2019/Antecol et al. (2018)"
use "$outdir/panel_GTD.dta", clear
xtset G T 
isid G T
gen lagD = L.D
gen difD = D.D
tab difD T
classify_did Y G T D
did_multiplegt_dyn Y G T D


** Berman 2017
global outdir   "$twfe_root/replications/2015-2019/Berman et al. (2017)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb(G ctryXyear) vce(cluster G)
classify_did Y G T D
did_multiplegt_dyn Y G T D, continuous(1) effects(3)



** Burguess 2015
global outdir "$twfe_root/replications/2015-2019/Burgess et al. (2015)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb(G T) vce(cluster G)
classify_did Y G T D
did_multiplegt_dyn Y G T D



** Donaldson 2015
do "$twfe_root/classify_sketch2.ado"
global outdir "$twfe_root/replications/2015-2019/Donaldson (2018)"
use "$outdir/panel_GTD.dta", clear
drop if missing(G) | missing(T)
bys G: egen D1 = min(D)
bys G: egen sdD = sd(D)
drop if sdD == 0


xtset G T
classify_did Y G T D

did_multiplegt_dyn Y G T D

gen lagD = L.D
replace lagD = 0 if  lagD == .
gen diff1 = D - lagD
 
reghdfe Y D, absorb(G T) vce(cluster G)
classify_did Y G T D
did_multiplegt_dyn Y G T D
tab D if T == 1870
tab D if T == 1880
tab T


** Favara 2015
do "$twfe_root/classify_did.ado"
global outdir "$twfe_root/replications/2015-2019/Favara and Imbs (2015)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D LDl_nloans_b-LDl_inc, absorb(G T) vce(cluster G)
classify_did Y G T D
did_multiplegt_dyn Y G T D


** Fetzer 2019
do "$twfe_root/classify_did.ado"
global outdir "$twfe_root/replications/2015-2019/Fetzer (2019)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D, absorb(G ) vce(cluster G)
classify_did Y G T D
stute_test Y D G T
did_had Y G T D, yatchew
tabstat D, by(T) stats(mean min max sd)


** Kaur 2019
do "$twfe_root/classify_did.ado"
global outdir "$twfe_root/replications/2015-2019/Kaur (2019)"
use "$outdir/panel_GTD.dta", clear
reghdfe Y D bmons20, absorb(G T) vce(cluster regionyr)
classify_did Y G T D
did_multiplegt_dyn Y G T D


** Suares Serrato and Zidar 20
do "$twfe_root/classify_did.ado"
global outdir "$twfe_root/replications/2015-2019/Suárez Serrato and Zidar (2016)"
use "$outdir/panel_GTD.dta", clear
classify_did Y G T D
did_multiplegt_dyn Y G T D, continuous(2)


reghdfe Y D [aw=epop], absorb(FE1 T) vce(cluster G)
collapse (mean) Y D, by(G T)
classify_did Y G T D
did_had Y G T D, effects(4) placebo(4)

did_multiplegt_stat Y G T D














