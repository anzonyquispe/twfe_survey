/*
Equal but Inequitable: Who Benefits from Gender-Neutral Tenure Clock Stopping Policies?

Antecol, Bedard, and Stearns

AER

This file creates all tables and figures in the paper
*/

clear
clear mata
clear matrix
set matsize 8000
set more off
capture log close

* set path here

***************************************************
** Figure 1. 
*************************************************** 
do called_dofiles/aer_figure1.do


***************************************************
** Figure 2. Descriptive Analysis
*************************************************** 
clear
use aer_figure2_sample
twoway line av_number0 av_number1 policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Average Number Hired") title("Average Number of Assistant Professors Hired") saving(output/temp2a, replace)
twoway line av_tenure0 av_tenure1 policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Tenure Rate") title("Tenure Rate") saving(output/temp2b, replace) 
twoway line av_top0 av_top1       policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Top-5 Publications within 7 Years") title("Average Number of Top-5 Publications within 7 Years") saving(output/temp2c, replace) 
twoway line av_pubs0 av_pubs1     policy_job_start, lpattern(- 1) xsc(r(1983 2003)) xlabel(1983(5)2003) legend(label(1 "Men") label(2 "Women")) xtitle("Year of First Job") ytitle("Non-Top-5 Publications within 7 Years") title("Average Number of Non-Top-5 Publications within 7 Years") saving(output/temp2d, replace) 

graph combine output/temp2a.gph output/temp2b.gph output/temp2c.gph output/temp2d.gph, altshrink saving(output/figure2.gph, replace)


***************************************************
* Table 2. Main Results
***************************************************
clear
use aer_primarysample

local ulist phd_rank phd_rank_miss post_doc ug_students grad_students faculty full_av_salary assist_av_salary revenue female_ratio full_ratio faculty_miss revenue_miss female_ratio_miss full_ratio_miss
local plist focs f_focs gncs f_gncs focs0 f_focs0 gncs0 f_gncs0
local extralist top_pubs7 mean_ca7 PUBS7 max_csstops max_csstops_miss

log using output/table2.log,replace
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table2_tests

log close


***************************************************
* Table 3. Event Study
***************************************************
clear
use aer_eventstudysample
 
local eventlist  pre3 f_pre3 pre2 f_pre2 pre1 f_pre1 focs0 f_focs0 focs f_focs gncs0 f_gncs0 gncs f_gncs

log using output/table3.log,replace
xi: reg tenure_policy_school `eventlist' `ulist' i.pol_job_start*i.female i.female*i.pol_u , cluster(pol_u) 
do called_dofiles/table3_tests

log close


***************************************************
* Table 4. Alternative Specifications
***************************************************
clear
use aer_primarysample

*Baseline regression:
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
log using output/table4.log,replace
*Remove control variables (ulist):
xi: reg tenure_policy_school `plist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
*Remove sample restrictions:
clear
use aer_expandedsample
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
*Add top-10 department-gender specific time dummies
clear
use aer_primarysample
gen RANK_female=RANK*10+female
xi: reg tenure_policy_school `plist' `ulist' i.pol_job_start*i.RANK_female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
*Remove female interactions
xi: reg tenure_policy_school `plist' `ulist' female i.pol_job_start i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
*Add potentially endogencous covariates in extralist
xi: reg tenure_policy_school `plist' `ulist' `extralist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests

log close


***************************************************
** Table 5. Tenure Anywhere, Time to Tenure and 
** Job Churning
***************************************************

log using output/table5.log,replace
xi: reg tenure_anywhere   `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg time_policy   `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg leave_early  `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg late_move   `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests

***Outcomes defined conditional on getting tenure at any university***
xi: reg time_to_tenure   `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg jobs_to_associate `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests

***Conditional on not getting tenure at the policy university***
xi: reg down   `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u if tenure_p==0 , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg up   `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  if tenure_p==0 , cluster(pol_u) 
do called_dofiles/table4_tests

log close


***************************************************
* Table 6. Publications
***************************************************

log using output/table6.log,replace
xi: reg top_pubs3 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg top_pubs5 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg top_pubs7 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg top_pubs9 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests

xi: reg PUBS3 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg PUBS5 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg PUBS7 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg PUBS9 `plist' `ulist' i.pol_job_start*i.female i.female*i.pol_u  , cluster(pol_u) 
do called_dofiles/table4_tests

log close


***************************************************
**  Table 7. Fertility 
***************************************************
clear 
use aer_fertilitysample

log using output/table7.log,replace 

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

log close


***************************************************
** Table 8. Balance
***************************************************
clear
use aer_primarysample

local pplist focs f_focs gncs f_gncs 
local ppplist focs gncs 

log using output/table8.log,replace
xi: reg female `ppplist' i.pol_u i.pol_job_start , cluster(pol_u) 
xi: reg phd_rank `pplist' i.female*i.pol_u i.female*i.pol_job_start  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg post_doc `pplist' i.female*i.pol_u i.female*i.pol_job_start  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg top_pubs1 `pplist' i.female*i.pol_u i.female*i.pol_job_start  , cluster(pol_u) 
do called_dofiles/table4_tests
xi: reg PUBS1 `pplist' i.female*i.pol_u i.female*i.pol_job_start  , cluster(pol_u) 
do called_dofiles/table4_tests

log close


***************************************************
* Table 9. Column 1 and 2: Can we predict policy adoption?
***************************************************
clear
use aer_predictsample

keep if year_80s==1
collapse gncs_ever focs_ever focs_pre80 private ug_student-full_ratio , by(pol_u)

log using output/table9a.log,replace
local xx ug_students grad_students faculty full_av_salary assist_av_salary revenue female_ratio full_ratio private 
foreach x of local xx {
	reg focs_ever `x' if  focs_pre80==0
	reg gncs_ever `x' 
	}
log close


***************************************************
* Table 9. Can we predict policy adoption?
* Column 3 and 4: do changes in Xs between 80-84 and 85-89 
*           predict adoption between 1990-99?
***************************************************
clear
use aer_predictsample

keep if year_80s==1

keep YEAR private gncs80 focs80 gncs85 focs85 pol_u ug_student-full_ratio 
collapse private ug_student-full_ratio gncs80 focs80 gncs85 focs85 , by(pol_u YEAR)
gen gncs=gncs80 if YEAR==1980
replace gncs=gncs85 if YEAR==1985
gen focs=focs80 if YEAR==1980
replace focs=focs85 if YEAR==1985
drop gncs80 gncs85 focs80 focs85

sort pol_u
save temp_table9,replace

clear
use aer_predictsample

keep if year_90_05==1

keep gncs_ever focs_ever focs_pre80 pol_u
collapse gncs_ever focs_ever focs_pre80 , by(pol_u)

sort pol_u
merge 1:m pol_u using temp_table9
drop _merge 

replace gncs=gncs_ever if YEAR==1985
replace focs=focs_ever if YEAR==1985

log using output/table9b.log,replace
local xx ug_students grad_students faculty full_av_salary assist_av_salary revenue female_ratio full_ratio 
foreach x of local xx {
	xi: areg focs `x' i.Y if  focs_pre80==0, absorb(pol_u)
	xi: areg gncs `x' i.Y , absorb(pol_u)
}
log close





