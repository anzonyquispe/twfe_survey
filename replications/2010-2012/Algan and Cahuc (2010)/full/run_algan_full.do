* =============================================================================
* Algan & Cahuc (2010)
* Inherited Trust and Growth
* AER, 100(5), 2060-2092
* FULL REPLICATION: Micro Tables I, III, IV, VIII, XIII; Macro Tables V-VII, IX-XI, XIV-XV
* =============================================================================

clear all
set more off
set maxvar 10000

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2010-2012/Algan and Cahuc (2010)"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2010-2012/Algan and Cahuc (2010)/full"

cd "$datadir"

cap log close _all
log using "$outdir/run_algan_full.log", text replace

* =============================================================================
* PART 1: MICRO ESTIMATES
* =============================================================================
di _n "=========================================================="
di _n "PART 1: MICRO ESTIMATES"
di _n "=========================================================="

use "AER_MICRO.dta", clear

* -- Generation dummies --
cap drop gen2 gen3 gen4 coh2000 coh1935
gen gen2=(nativegp==0 & nativep<=0.5 & native==1)
gen gen3=(nativegp<=0.5 & nativep==1 & native==1 & nativegp!=. & nativep!=.)
gen gen4=(nativegp>0.5 & nativep==1 & native==1 & nativegp!=. & nativep!=.)

gen coh2000=((gen2==1 & naiss>=1910) | (gen3==1 & naiss>=1935) | (gen4==1 & naiss>=1960))
gen coh1935=((gen2==1 & naiss<1910) | (gen3==1 & naiss<1935) | (gen4==1 & naiss<1960))

* -- Group dummies --
foreach x in Afri Aut Bg Cd Czr Dk Fin Fra Ger Hg India Ire Ita Mx Nth Nw Pol Pt Rus Sp Swd Switz Uk Youg {
    foreach y in coh1935 coh2000 {
        cap drop `x'_`y'
        quietly gen `x'_`y' = `x'*`y'
    }
}

* =============================================================================
* TABLE I: Inherited Trust
* =============================================================================
di _n "===== TABLE I: Inherited Trust ====="

di _n "--- Full pooled regression ---"
reg trust10_large age men ageedu age2 incomegood catho pro employed inactive unemployed ///
    Afri_coh2000 Afri_coh1935 Aut_coh2000 Aut_coh1935 Bg_coh2000 Bg_coh1935 Cd_coh2000 Cd_coh1935 Czr_coh2000 Czr_coh1935 Dk_coh2000 Dk_coh1935 Fra_coh2000 Fra_coh1935 ///
    Fin_coh2000 Fin_coh1935 Ger_coh2000 Ger_coh1935 Hg_coh2000 Hg_coh1935 India_coh2000 India_coh1935 Ire_coh2000 Ire_coh1935 Ita_coh2000 Ita_coh1935 Mx_coh2000 Mx_coh1935 Nth_coh2000 Nth_coh1935 ///
    Nw_coh2000 Nw_coh1935 Pol_coh2000 Pol_coh1935 Pt_coh2000 Pt_coh1935 Rus_coh2000 Rus_coh1935 Sp_coh2000 Sp_coh1935 Swd_coh2000 Switz_coh2000 Switz_coh1935 Uk_coh2000 Uk_coh1935 Youg_coh2000 Youg_coh1935 ///
    if (coh2000==1 | coh1935==1) & cty_sample==1 & religionok==1, cluster(eth)

di _n "--- Cohort 1935 ---"
reg trust10_large age men ageedu incomegood catho pro unemployed employed ///
    Afri Aut Bg Uk Cd Czr Dk Fin Fra Ger Hg India Ire Ita Mx Nth Nw Pol Pt Rus Sp Switz Youg ///
    if cty_sample==1 & religionok==1 & coh1935, cluster(eth)
estimates store coh1935

di _n "--- Cohort 2000 ---"
reg trust10_large age men ageedu incomegood catho pro unemployed employed ///
    Afri Aut Bg Uk Cd Czr Dk Fin Fra Ger Hg India Ire Ita Mx Nth Nw Pol Pt Rus Sp Switz Youg ///
    if cty_sample==1 & religionok==1 & coh2000, cluster(eth)
estimates store coh2000

* =============================================================================
* TABLE III: Correlation inherited trust and home country trust
* =============================================================================
di _n "===== TABLE III: Trust Correlation ====="

di _n "--- Col 1: Cohort 2000 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood unemployed employed catho pro ///
    if cty_sample==1 & coh2000==1 & religionok==1, cluster(eth)

di _n "--- Col 2: Cohort 1935 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood catho pro unemployed employed ///
    if cty_sample==1 & coh1935==1 & religionok==1, cluster(eth)

di _n "--- Col 3: 4th generation 2000 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood unemployed employed catho pro ///
    if cty_sample==1 & (gen4==1 & naiss>=1960) & religionok==1, cluster(eth)

* =============================================================================
* TABLE IV: Counterfactual (random trust)
* =============================================================================
di _n "===== TABLE IV: Counterfactual ====="

di _n "--- Col 1: Random trust, cohort 2000 ---"
reg trust10_large trustwvs_rand age men ageedu incomegood unemployed employed catho pro ///
    if cty_sample==1 & ((gen2==1 & naiss>=1910) | (gen3==1 & naiss>=1935) | (gen4==1 & naiss>=1960)) & religionok==1, cluster(eth)

di _n "--- Col 2: Random trust, cohort 1935 ---"
reg trust10_large trustwvs_rand age men ageedu incomegood catho pro unemployed employed ///
    if cty_sample==1 & coh1935==1 & religionok==1, cluster(eth)

* =============================================================================
* TABLE VIII: Cohorts 1910 and 2000
* =============================================================================
di _n "===== TABLE VIII: Cohorts 1910-2000 ====="

cap drop gen2_test gen3_test gen4_test coh2000r coh1910r cty_okr
gen gen2_test=(nativegp==0 & nativep<=0.5 & native==1)
gen gen3_test=(nativegp<=0.5 & nativep>=0.5 & native==1 & nativegp!=. & nativep!=.)
gen gen4_test=(nativegp>0.5 & nativep>=0.5 & native==1 & nativegp!=. & nativep!=.)

gen coh2000r=((gen2_test==1 & naiss>1910) | (gen3_test==1 & naiss>1935) | (gen4_test==1 & naiss>1960))
gen coh1910r=((gen3_test==1 & naiss<=1910) | (gen4_test==1 & naiss<=1935))
gen cty_okr=(Afri==1 | Uk==1 | Cd==1 | Czr==1 | Dk==1 | Fra==1 | Ger==1 | Ire==1 | Ita==1 | Nth==1 | Nw==1 | Pol==1 | Sp==1 | Swd==1 | Switz==1)

foreach x in Afri Cd Czr Dk Fra Ger Ire Ita Nth Nw Pol Sp Swd Switz Uk {
    foreach y in coh2000r coh1910r {
        cap drop `x'_`y'
        quietly gen `x'_`y' = `x'*`y'
    }
}

di _n "--- Table VIII pooled ---"
reg trust10_large age men ageedu ///
    Afri_coh2000r Afri_coh1910r Uk_coh2000r Uk_coh1910r Cd_coh2000r Cd_coh1910r Czr_coh2000r Czr_coh1910r Dk_coh2000r Dk_coh1910r ///
    Fra_coh2000r Fra_coh1910r Ger_coh2000r Ger_coh1910r Ire_coh2000r Ire_coh1910r Ita_coh2000r Ita_coh1910r Nth_coh2000r Nth_coh1910r ///
    Nw_coh2000r Nw_coh1910r Pol_coh2000r Pol_coh1910r Sp_coh2000r Sp_coh1910r Swd_coh2000r Switz_coh2000r Switz_coh1910r ///
    if (coh2000r==1 | coh1910r==1) & cty_okr==1, cluster(eth)

* =============================================================================
* TABLE XIII: Subsamples
* =============================================================================
di _n "===== TABLE XIII: Subsamples ====="

di _n "--- Col 1: 2nd-3rd gen, 1935 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood catho pro unemployed employed ///
    if religionok==1 & cty_sample==1 & ((gen2==1 & naiss<1910) | (gen3==1 & naiss<1935)), cluster(eth)

di _n "--- Col 2: 4th gen, 1935 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood catho pro unemployed employed ///
    if religionok==1 & cty_sample==1 & (gen4==1 & naiss<1960), cluster(eth)

di _n "--- Col 3: 2nd-3rd gen, 2000 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood unemployed inactive employed catho pro ///
    if religionok==1 & cty_sample==1 & ((gen2==1 & naiss>=1910) | (gen3==1 & naiss>=1935)), cluster(eth)

di _n "--- Col 4: 4th gen, 2000 ---"
reg trust10_large trustwvs2000 age men ageedu incomegood unemployed employed catho pro ///
    if religionok==1 & cty_sample==1 & (gen4==1 & naiss>=1960), cluster(eth)

* =============================================================================
* PART 2: MACRO ESTIMATES
* =============================================================================
di _n "=========================================================="
di _n "PART 2: MACRO ESTIMATES"
di _n "=========================================================="

use "$datadir/AER_MACRO.dta", clear

* =============================================================================
* TABLE V: Cross-country (1935-2000)
* =============================================================================
di _n "===== TABLE V: Cross-country ====="

di _n "--- Col 1: Trust only ---"
xi: reg gdpk_diffswd_good trustgss if period19352000==1, noconstant

di _n "--- Col 2: + lagged GDP ---"
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 if period19352000==1, noconstant

di _n "--- Col 3: + polity ---"
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 polity2diff if period19352000==1, noconstant

di _n "--- Col 4: Excl. Africa ---"
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 polity2diff if period19352000==1 & cty!="Afri", noconstant

* =============================================================================
* TABLE VI: Within estimates
* =============================================================================
di _n "===== TABLE VI: Within estimates ====="

di _n "--- Col 1: Country FE ---"
xi: reg gdpk_diffswd_good trustgss i.cty if period19352000==1, noconstant

di _n "--- Col 2: + lagged GDP ---"
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 i.cty if period19352000==1, noconstant

di _n "--- Col 3: Excl. Africa ---"
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 i.cty if period19352000==1 & cty!="Afri", noconstant

di _n "--- Col 4: + polity ---"
xi: reg gdpk_diffswd_good trustgss gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

di _n "--- Col 5: Smoothed ---"
xi: reg gdpk_diffswd_goodsmooth trustgss gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

* =============================================================================
* TABLE VII: 50-year lag
* =============================================================================
di _n "===== TABLE VII: 50-year lag ====="

di _n "--- Col 1: Cross-section ---"
xi: reg gdpk_diffswd_good trustgss50yearslag, noconstant

di _n "--- Col 2: Country FE ---"
xi: reg gdpk_diffswd_good trustgss50yearslag i.cty, noconstant

di _n "--- Col 3: Full controls ---"
xi: reg gdpk_diffswd_good trustgss50yearslag gdpk_diffswd_good_1_lag75 polity2diff19502000 i.cty, noconstant

* =============================================================================
* TABLE IX-X: Cohorts 1910-2000
* =============================================================================
di _n "===== TABLE IX-X: Cohorts 1910-2000 ====="

di _n "--- Cross-section trust only ---"
xi: reg gdpk_diffswd_good trustgss_1910_2000 if Nsample1910==0 & period19102000==1, noconstant

di _n "--- + lagged GDP ---"
xi: reg gdpk_diffswd_good trustgss_1910_2000 gdpk_diffswd_good_2 if Nsample1910==0 & period19102000==1, noconstant

di _n "--- + polity ---"
xi: reg gdpk_diffswd_good trustgss_1910_2000 gdpk_diffswd_good_2 polity2diff19102000 if Nsample1910==0 & period19102000==1, noconstant

di _n "--- Country FE ---"
xi: reg gdpk_diffswd_good trustgss_1910_2000 i.cty if Nsample1910==0 & period19102000==1, noconstant

di _n "--- Country FE + GDP ---"
xi: reg gdpk_diffswd_good trustgss_1910_2000 gdpk_diffswd_good_2 i.cty if Nsample1910==0 & period19102000==1, noconstant

di _n "--- Country FE + GDP + polity ---"
xi: reg gdpk_diffswd_good trustgss_1910_2000 gdpk_diffswd_good_2 polity2diff19102000 i.cty if Nsample1910==0 & period19102000==1, noconstant

* =============================================================================
* TABLE XI: Additional Controls
* =============================================================================
di _n "===== TABLE XI: Additional Controls ====="

di _n "--- Col 1: Hard work ---"
xi: reg gdpk_diffswd_good trustgss hardwork gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

di _n "--- Col 2: Confidence business ---"
xi: reg gdpk_diffswd_good trustgss confbus gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

di _n "--- Col 3: Gov. equality ---"
xi: reg gdpk_diffswd_good trustgss gveq gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

di _n "--- Col 4: Women work ---"
xi: reg gdpk_diffswd_good trustgss womanwork gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

di _n "--- Col 5: All beliefs ---"
xi: reg gdpk_diffswd_good trustgss hardwork confbus gveq womanwork gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

* =============================================================================
* TABLE XIV: Alternative Trust Indicators
* =============================================================================
di _n "===== TABLE XIV: Alternative Trust ====="

di _n "--- Col 1: Trust 1-2-3 ---"
xi: reg gdpk_diffswd_good trust123new gdpk_diffswd_good_1 polity2diff i.cty if period19352000==1, noconstant

di _n "--- Col 2: Trust no depends ---"
xi: reg gdpk_diffswd_good trust_nodepends gdpk_diffswd_good_1 polity2diff i.cty if Nsample1935==0, noconstant

di _n "--- Col 3: Trust alternative ---"
xi: reg gdpk_diffswd_good trust_alter gdpk_diffswd_good_1 polity2diff i.cty if Nsample1935==0, noconstant

* =============================================================================
* TABLE XV: Periods 1950-2000
* =============================================================================
di _n "===== TABLE XV: Periods 1950-2000 ====="

di _n "--- Col 1: Cross-section ---"
xi: reg gdpk_diffswd_good trustgss_lag75, noconstant

di _n "--- Col 2: Country FE ---"
xi: reg gdpk_diffswd_good trustgss_lag75 i.cty, noconstant

di _n "--- Col 3: Full ---"
xi: reg gdpk_diffswd_good trustgss_lag75 gdpk_diffswd_good_1_lag75 polity2diff19502000 i.cty, noconstant

di _n "===== ALL TABLES COMPLETE ====="

cap log close _all
