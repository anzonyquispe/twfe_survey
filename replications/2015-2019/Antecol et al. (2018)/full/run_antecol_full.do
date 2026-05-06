* =============================================================================
* Antecol, Bedard & Stearns (2018)
* Equal but Inequitable: Who Benefits from Gender-Neutral
*   Tenure Clock Stopping Policies?
* AER, 108(9), 2420-2441
* FULL REPLICATION: Tables 2-9 and Figures 1-2
* =============================================================================

clear all
set more off
set matsize 8000
set maxvar 10000
cap log close _all

global datadir "C:/Users/Usuario/Documents/GitHub/twfe_survey/data/2015-2019/Antecol et al. (2018)/data"
global outdir  "C:/Users/Usuario/Documents/GitHub/twfe_survey/replications/2015-2019/Antecol et al. (2018)/full"

* Create output subdirectory for Stata outputs
cap mkdir "$outdir/output"

cd "$datadir"

log using "$outdir/run_antecol_full.log", text replace

* Define control variable lists (used across tables)
local ulist phd_rank phd_rank_miss post_doc ug_students grad_students faculty full_av_salary assist_av_salary revenue female_ratio full_ratio faculty_miss revenue_miss female_ratio_miss full_ratio_miss
local plist focs f_focs gncs f_gncs focs0 f_focs0 gncs0 f_gncs0
local extralist top_pubs7 mean_ca7 PUBS7 max_csstops max_csstops_miss

* =============================================================================
* FIGURE 1: Gender composition by profession
* =============================================================================
di _n "===== FIGURE 1 ====="

log using "$outdir/figure1.log", text replace name(fig1)

clear
use aer_acs

keep if educ==11
keep if uhrswork>=30 & uhrswork!=.

gen female=1 if sex==2
replace female=0 if sex==1

gen law=1 if occ2010==2100
gen dr=1 if occ2010==3060
gen postsecondary=1 if occ2010==2200
gen business=1 if occ2010>=0010 & occ2010<=0950
gen group=1 if law==1
replace group=2 if dr==1
replace group=3 if postsecondary==1
replace group=4 if business==1
keep if group!=.

sort year age group
by year age group: gen ngroup = 1 if _n==1
replace ngroup = sum(ngroup)

gen p75=.
qui forvalues i = 1/8 {
    sum incwage [w=perwt] if ngroup == `i', detail
    replace p75 = r(p75) if ngroup == `i'
}

gen top_25=1 if incwage>=p75
gen top_25_female=top_25*female if top_25!=. & female!=.
by year age group: gen n=_N

collapse female top_25_female (count) n [pw=perwt], by(year age group)

graph bar female top_25_female, over(group, label(labsize(vsmall)) relabel(1 "Lawyers" 2 "Doctors" 3 `""Postsecondary" "Teachers""' 4 "Business")) over(age, relabel(1 "Age 30" 2 "Age 40")) ytitle("Share Female") legend(label(1 "All Workers") label(2 "Top 25% of Earners")) bar(1, color(navy)) bar(2, color(dkorange)) saving("$outdir/output/figure1.gph", replace)
graph export "$outdir/output/figure1.png", replace width(1200)

log close fig1

* =============================================================================
* FIGURE 2: Descriptive Analysis
* =============================================================================
di _n "===== FIGURE 2 ====="

log using "$outdir/figure2.log", text replace name(fig2)

clear
use aer_figure2_sample
twoway line av_number0 av_number1 policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Average Number Hired") title("Average Number of Assistant Professors Hired") saving("$outdir/output/temp2a.gph", replace)
twoway line av_tenure0 av_tenure1 policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Tenure Rate") title("Tenure Rate") saving("$outdir/output/temp2b.gph", replace)
twoway line av_top0 av_top1       policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Top-5 Publications within 7 Years") title("Average Number of Top-5 Publications within 7 Years") saving("$outdir/output/temp2c.gph", replace)
twoway line av_pubs0 av_pubs1     policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Non-Top-5 Publications within 7 Years") title("Average Number of Non-Top-5 Publications within 7 Years") saving("$outdir/output/temp2d.gph", replace)

graph combine "$outdir/output/temp2a.gph" "$outdir/output/temp2b.gph" "$outdir/output/temp2c.gph" "$outdir/output/temp2d.gph", altshrink saving("$outdir/output/figure2.gph", replace)
graph export "$outdir/output/figure2.png", replace width(1200)

log close fig2

* =============================================================================
* TABLE 2: Main Results
* =============================================================================
di _n "===== TABLE 2: Main Results ====="

log using "$outdir/table2.log", text replace name(t2)

clear
use aer_primarysample

xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)

* Policy Effects Years 4+ FOCS or GNCS
di _n "--- Policy Effects Years 4+ ---"
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom gncs-focs
lincom gncs+f_gncs - focs - f_focs
lincom -f_focs
lincom -f_gncs

* Policy Effects Years 0-3
di _n "--- Policy Effects Years 0-3 ---"
lincom focs+focs0
lincom focs+f_focs+focs0+f_focs0
lincom gncs+gncs0
lincom gncs+f_gncs+gncs0+f_gncs0
lincom gncs+gncs0-focs-focs0
lincom gncs+f_gncs+gncs0+f_gncs0-focs-f_focs-focs0-f_focs0
lincom -f_focs-f_focs0
lincom -f_gncs-f_gncs0

log close t2

* =============================================================================
* TABLE 3: Event Study
* =============================================================================
di _n "===== TABLE 3: Event Study ====="

log using "$outdir/table3.log", text replace name(t3)

clear
use aer_eventstudysample

local eventlist pre3 f_pre3 pre2 f_pre2 pre1 f_pre1 focs0 f_focs0 focs f_focs gncs0 f_gncs0 gncs f_gncs

xi: reg tenure_policy_school `eventlist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)

* Event study tests
di _n "--- Event Study Effects ---"
lincom focs-pre1
lincom focs+f_focs-pre1-f_pre1
lincom gncs-pre1
lincom gncs+f_gncs-pre1-f_pre1
lincom gncs-focs
lincom gncs+f_gncs - focs - f_focs
lincom -f_focs+f_pre1
lincom -f_gncs+f_pre1

di _n "--- Early Effects ---"
lincom focs+focs0-pre1
lincom focs+f_focs+focs0+f_focs0-pre1-f_pre1
lincom gncs+gncs0-pre1
lincom gncs+f_gncs+gncs0+f_gncs0-pre1-f_pre1
lincom gncs+gncs0-focs-focs0
lincom gncs+f_gncs+gncs0+f_gncs0-focs-f_focs-focs0-f_focs0
lincom -f_focs-f_focs0+f_pre1
lincom -f_gncs-f_gncs0+f_pre1

di _n "--- Pre-policy Effects ---"
lincom pre3-pre1
lincom pre3+f_pre3-pre1-f_pre1
lincom pre2-pre1
lincom pre2+f_pre2-pre1-f_pre1
lincom - f_pre3+f_pre1
lincom - f_pre2+f_pre1

log close t3

* =============================================================================
* TABLE 4: Alternative Specifications
* =============================================================================
di _n "===== TABLE 4: Alternative Specifications ====="

log using "$outdir/table4.log", text replace name(t4)

* Col 1: Baseline
di _n "--- Col 1: Baseline ---"
clear
use aer_primarysample
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

* Col 2: No controls
di _n "--- Col 2: No controls ---"
xi: reg tenure_policy_school `plist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

* Col 3: Expanded sample
di _n "--- Col 3: Expanded sample ---"
clear
use aer_expandedsample
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

* Col 4: Top-10 department x gender dummies
di _n "--- Col 4: Top-10 dept x gender ---"
clear
use aer_primarysample
gen RANK_female=RANK*10+female
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.RANK_female i.female*i.pol_u, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

* Col 5: No female interactions
di _n "--- Col 5: No female interactions ---"
xi: reg tenure_policy_school `plist' `ulist' female i.pol_job_start i.pol_u, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

* Col 6: With endogenous covariates
di _n "--- Col 6: With endogenous covariates ---"
xi: reg tenure_policy_school `plist' `ulist' `extralist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

log close t4

* =============================================================================
* TABLE 5: Tenure Anywhere, Time to Tenure, Job Churning
* =============================================================================
di _n "===== TABLE 5: Outcomes ====="

log using "$outdir/table5.log", text replace name(t5)

clear
use aer_primarysample

foreach depvar in tenure_anywhere time_policy leave_early late_move {
    di _n "--- `depvar' ---"
    xi: reg `depvar' `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
    lincom focs
    lincom focs+f_focs
    lincom gncs
    lincom gncs+f_gncs
    lincom -f_focs
    lincom -f_gncs
}

* Conditional on tenure anywhere
foreach depvar in time_to_tenure jobs_to_associate {
    di _n "--- `depvar' (cond. tenure) ---"
    xi: reg `depvar' `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
    lincom focs
    lincom focs+f_focs
    lincom gncs
    lincom gncs+f_gncs
    lincom -f_focs
    lincom -f_gncs
}

* Conditional on not getting tenure at policy university
foreach depvar in down up {
    di _n "--- `depvar' (cond. no tenure) ---"
    cap noi xi: reg `depvar' `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u if tenure_p==0, cluster(pol_u)
    cap noi lincom focs
    cap noi lincom focs+f_focs
    cap noi lincom gncs
    cap noi lincom gncs+f_gncs
    cap noi lincom -f_focs
    cap noi lincom -f_gncs
}

log close t5

* =============================================================================
* TABLE 6: Publications
* =============================================================================
di _n "===== TABLE 6: Publications ====="

log using "$outdir/table6.log", text replace name(t6)

clear
use aer_primarysample

foreach depvar in top_pubs3 top_pubs5 top_pubs7 top_pubs9 PUBS3 PUBS5 PUBS7 PUBS9 {
    di _n "--- `depvar' ---"
    xi: reg `depvar' `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u, cluster(pol_u)
    lincom focs
    lincom focs+f_focs
    lincom gncs
    lincom gncs+f_gncs
    lincom -f_focs
    lincom -f_gncs
}

log close t6

* =============================================================================
* TABLE 7: Fertility
* =============================================================================
di _n "===== TABLE 7: Fertility ====="

log using "$outdir/table7.log", text replace name(t7)

clear
use aer_fertilitysample

ttest any_b if female==0 & gncs0==0, by(gncs)
ttest any_b if female==1 & gncs0==0 & focs==0, by(gncs)
ttest any_b if female==1 & focs0==0 & gncs==0, by(focs)

ttest all_b if female==0 & gncs0==0, by(gncs)
ttest all_b if female==1 & gncs0==0 & focs==0, by(gncs)
ttest all_b if female==1 & focs0==0 & gncs==0, by(focs)

ttest havekids if female==0 & gncs0==0, by(gncs)
ttest havekids if female==1 & gncs0==0 & focs==0, by(gncs)
ttest havekids if female==1 & focs0==0 & gncs==0, by(focs)

ttest numkids if female==0 & gncs0==0, by(gncs)
ttest numkids if female==1 & gncs0==0 & focs==0, by(gncs)
ttest numkids if female==1 & focs0==0 & gncs==0, by(focs)

log close t7

* =============================================================================
* TABLE 8: Balance
* =============================================================================
di _n "===== TABLE 8: Balance ====="

log using "$outdir/table8.log", text replace name(t8)

clear
use aer_primarysample

local pplist focs f_focs gncs f_gncs
local ppplist focs gncs

xi: reg female `ppplist' i.pol_u i.pol_job_start, cluster(pol_u)
xi: reg phd_rank `pplist' i.female*i.pol_u i.female*i.pol_job_start, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

xi: reg post_doc `pplist' i.female*i.pol_u i.female*i.pol_job_start, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

xi: reg top_pubs1 `pplist' i.female*i.pol_u i.female*i.pol_job_start, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

xi: reg PUBS1 `pplist' i.female*i.pol_u i.female*i.pol_job_start, cluster(pol_u)
lincom focs
lincom focs+f_focs
lincom gncs
lincom gncs+f_gncs
lincom -f_focs
lincom -f_gncs

log close t8

* =============================================================================
* TABLE 9: Predicting Policy Adoption
* =============================================================================
di _n "===== TABLE 9: Policy Prediction ====="

log using "$outdir/table9.log", text replace name(t9)

* Columns 1-2: Cross-section
clear
use aer_predictsample

keep if year_80s==1
collapse gncs_ever focs_ever focs_pre80 private ug_student-full_ratio, by(pol_u)

local xx ug_students grad_students faculty full_av_salary assist_av_salary revenue female_ratio full_ratio private
foreach x of local xx {
    di _n "--- Predicting FOCS from `x' ---"
    reg focs_ever `x' if focs_pre80==0
    di _n "--- Predicting GNCS from `x' ---"
    reg gncs_ever `x'
}

* Columns 3-4: Changes predict adoption
clear
use aer_predictsample

keep if year_80s==1
keep YEAR private gncs80 focs80 gncs85 focs85 pol_u ug_student-full_ratio
collapse private ug_student-full_ratio gncs80 focs80 gncs85 focs85, by(pol_u YEAR)
gen gncs=gncs80 if YEAR==1980
replace gncs=gncs85 if YEAR==1985
gen focs=focs80 if YEAR==1980
replace focs=focs85 if YEAR==1985
drop gncs80 gncs85 focs80 focs85

sort pol_u
save "$outdir/output/temp_table9.dta", replace

clear
use aer_predictsample
keep if year_90_05==1
keep gncs_ever focs_ever focs_pre80 pol_u
collapse gncs_ever focs_ever focs_pre80, by(pol_u)

sort pol_u
merge 1:m pol_u using "$outdir/output/temp_table9.dta"
drop _merge

replace gncs=gncs_ever if YEAR==1985
replace focs=focs_ever if YEAR==1985

foreach x of local xx {
    di _n "--- Panel: Predicting FOCS from `x' ---"
    cap noi xi: areg focs `x' i.Y if focs_pre80==0, absorb(pol_u)
    di _n "--- Panel: Predicting GNCS from `x' ---"
    cap noi xi: areg gncs `x' i.Y, absorb(pol_u)
}

log close t9

di _n "===== ALL TABLES AND FIGURES COMPLETE ====="

cap log close _all
