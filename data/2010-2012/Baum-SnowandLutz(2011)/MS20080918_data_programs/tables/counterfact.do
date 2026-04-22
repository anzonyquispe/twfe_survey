/** 
Generates counterfactual trends in the central district level data.
**/

clear

capture log close
log using counterfact.log, replace text

use ../data/dis70panx.dta

** Only keep major plan MSAs
keep if major==1

replace black = black/1000000
replace white = white/1000000
replace other = other/1000000

tab year

*Enrolled Children Counts
gen ewhitepub = (publicelemw+publichsw)/1000000
replace ewhitepub = (publicelemhsw)/1000000 if year==1990
gen ewhitepri = (privatelemw+privatehsw)/1000000
replace ewhitepri = (privatelemhsw)/1000000 if year==1990
gen eblackpub = (publicelemb+publichsb)/1000000
replace eblackpub = (publicelemhsb)/1000000 if year==1990
gen eblackpri = (privatelemb+privatehsb)/1000000
replace eblackpri = (privatelemhsb)/1000000 if year==1990
gen eotherpub = (publicelemt+publichst)/1000000-ewhitepub-eblackpub
replace eotherpub = (publicelemhst)/1000000-ewhitepub-eblackpub if year==1990
gen eotherpri = (privatelemt+privatehst)/1000000-ewhitepri-eblackpri
replace eotherpri = (privatelemhst)/1000000-ewhitepri-eblackpri if year==1990
gen eother = (publicelemt+publichst+privatelemt+privatehst)/1000000-ewhitepub-ewhitepri-eblackpub-eblackpri
replace eother = (publicelemhst+privatelemhst)/1000000-ewhitepub-ewhitepri-eblackpub-eblackpri if year==1990

**** Actual Numbers
*Total Pop
gen pop = white+black+other
table year, contents(sum white sum black sum pop) format(%15.4f)
drop pop
*Enrolled Pop
gen ewhite = ewhitepub+ewhitepri
gen eblack = eblackpub+eblackpri
gen epop = ewhite+eblack+eother
table year, contents(sum ewhite sum eblack sum epop) format(%15.4f)
drop ewhite eblack epop
*Private Enrolled Pop
gen epoppri = ewhitepri+eblackpri+eotherpri
table year, contents(sum ewhitepri sum eblackpri sum epoppri) format(%15.4f)
drop epoppri
*Public Enrolled Pop
gen epoppub = ewhitepub+eblackpub+eotherpub
table year, contents(sum ewhitepub sum eblackpub sum epoppub) format(%15.4f)
drop epoppub

**** Generate Counterfactual Estimates
replace imp = imp+1900
gen imp_postw = (year>=imp)
gen imp_postb = (year>imp+3)

*** Compute Counterfactuals for MSA/YEAR Combos
replace white = white+.12*white if imp_postw==1 & south==1
replace white = white-.04*white if imp_postw==1 & south==0
replace black = black+.01*black if imp_postb==1 & south==1
replace black = black-.12*black if imp_postb==1 & south==0

replace ewhitepub = ewhitepub+.14*ewhitepub if imp_postw==1 & south==1
replace ewhitepub = ewhitepub+.08*ewhitepub if imp_postw==1 & south==0
replace eblackpub = eblackpub-.00*eblackpub if imp_postb==1 & south==1
replace eblackpub = eblackpub-.20*eblackpub if imp_postb==1 & south==0

replace ewhitepri = ewhitepri+.04*ewhitepri if imp_postw==1 & south==1
replace ewhitepri = ewhitepri-.16*ewhitepri if imp_postw==1 & south==0
replace eblackpri = eblackpri+.45*eblackpri if imp_postw==1 & south==1
replace eblackpri = eblackpri+.10*eblackpri if imp_postw==1 & south==0

*Total Pop Counts
gen pop = white+black+other
table year, contents(sum white sum black sum pop) format(%15.4f)

*Enrolled Pop Counts
gen ewhite = ewhitepub+ewhitepri
gen eblack = eblackpub+eblackpri
gen epop = ewhite+eblack+eother
table year, contents(sum ewhite sum eblack sum epop) format(%15.4f)

*Private School Enrolled Counts
gen epoppri = ewhitepri+eblackpri+eotherpri
table year, contents(sum ewhitepri sum eblackpri sum epoppri) format(%15.4f)

*Public School Enrolled Counts
gen epoppub = ewhitepub+eblackpub+eotherpub
table year, contents(sum ewhitepub sum eblackpub sum epoppub) format(%15.4f)


