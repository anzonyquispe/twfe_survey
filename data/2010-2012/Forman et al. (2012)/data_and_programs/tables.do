clear

*log using aer20090145, replace

use countyyear.dta


global controls lnpop pctblk1990 pctunivp1990 pctHSp1990 pctbelowPL1990 medhhinc1990 carnegie1_enr frac_in_eng_prog npatent1980s frprof pct65p1990 netmig95
global change change_totalpop change_pctblk change_pctunivp change_pctHSp change_pct65 change_netmig

*BASIC STATS 
summ weekwage if year==1995 & surv_deeppost95==0
summ weekwage if year==1995 & surv_deeppost95~=0
summ weekwage if year==2000 & surv_deeppost00==0
summ weekwage if year==2000 & surv_deeppost00~=0

*TABLE 1: SUMMARY STATS
summ lnweekwage lnemp lnest surv_deeppost00 indivhomeinternet00_cty missing iv_othcprogrammerswt iv_first_p iv_cost iv_num_a iv_num_b iv_competitiondeep iv_bartik $controls $change if year==2000

clear

global controls lnpop pctblk1990 pctunivp1990 pctHSp1990 pctbelowPL1990 medhhinc1990 carnegie1_enr frac_in_eng_prog npatent1980s frprof pct65p1990 netmig95
global change change_totalpop change_pctblk change_pctunivp change_pctHSp change_pct65 change_netmig

use countygrowth, clear
summ wagediff empdiff estdiff surv_deeppost00 indivhomeinternet00_cty missing iv_othcprogrammerswt iv_first_p iv_cost iv_num_a iv_num_b iv_competitiondeep iv_bartik $controls $change if year==2000


*TABLE 2: MAIN EFFECTS--OLS/PANEL
regress wagediff surv_deeppost00, robust
outreg using table2, se 3aster  bdec(4) replace
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change , robust
outreg using table2, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 surv_pcperemp00 surv_shalpost00  indivhomeinternet00_cty missing $controls $change ,  robust
outreg using table2, se 3aster  bdec(4) append


*TABLE 3: HIGH INCOME, ETC--OLS/PANEL
regress wagediff  surv_deeppost00 highinc2000 inc_dum_surv_deeppost00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) replace
regress wagediff  surv_deeppost00 higheduc2000 educ_dum_surv_deeppost00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highind2000 ind_dum_surv_deeppost00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highpop2000 pop_dum_surv_deeppost00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) append

regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000  inc_dum_surv_deeppost00 educ_dum_surv_deeppost00 pop_dum_surv_deeppost00 ind_dum_surv_deeppost00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) append
*
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 inc_dum_surv_deeppost00 educ_dum_surv_deeppost00 pop_dum_surv_deeppost00 ind_dum_surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00  $controls $change , robust
outreg using table3, se 3aster  bdec(4) append



*TABLE 4: MAIN EFFECTS--INSTRUMENTAL VARIABLES--STAGE ONE--
*TABLE 4: MAIN EFFECTS--INSTRUMENTAL VARIABLES--STAGE TWO--INCLUDES HAUSMAN TESTS AND HANSEN J-TESTS
*INSTRUMENTAL VARIABLES

regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  avgdmest $controls $change
estimates store ols

*OTHER PROGRAMMERS SAME FIRMS OTHER LOCATIONS
ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt )  indivhomeinternet00_cty missing  avgdmest $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) replace
estat firststage
quietly ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt )  indivhomeinternet00_cty missing  avgdmest $controls $change
hausman . ols

*BARTIK
ivregress liml wagediff (surv_deeppost00= iv_bartik)  indivhomeinternet00_cty missing  avgdmest $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) append
estat firststage
quietly ivregress liml wagediff (surv_deeppost00= iv_bartik)  indivhomeinternet00_cty missing  avgdmest $controls $change
hausman . ols

*ARPANET
ivregress gmm wagediff (surv_deeppost00=iv_num_a )  indivhomeinternet00_cty missing  avgdmest $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) append
estat firststage
quietly ivregress gmm wagediff (surv_deeppost00=iv_num_a )  indivhomeinternet00_cty missing  avgdmest $controls $change, vce(un)
hausman . ols


ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt iv_num_a iv_bartik)  indivhomeinternet00_cty missing  avgdmest $controls $change, first vce(robust)  
outreg using table4, se 3aster  bdec(4) append
estat firststage
quietly ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt iv_first_p  iv_num_a  iv_bartik)  indivhomeinternet00_cty missing  avgdmest $controls $change
estat overid
hausman . ols




use countygrowth, clear

gen ivd_num_a =iv_num_a*allhigh
gen ivd_othcp=iv_othcp*allhigh
gen ivd_bartik= iv_bartik*allhigh
 
regress wagediff surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change
estimates store ols2

ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_othcprogrammerswt ivd_othcp )  highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) append
estat firststage, all
quietly ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_othcprogrammerswt ivd_othcp )  highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change
hausman . ols2

ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_bartik ivd_bartik)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) append
estat firststage, all
quietly ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_bartik ivd_bartik)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change
hausman . ols2

*would not converge with liml
ivregress gmm wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_num_a ivd_num_a)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh  $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) append
estat firststage, all
quietly ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_num_a ivd_num_a)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh  $controls $change, vce(un)
hausman . ols2

ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_othcprogrammerswt  iv_num_a  iv_bartik ivd_othcp  ivd_num_a  ivd_bartik)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh  avgdmest $controls $change, first vce(robust)
outreg using table4, se 3aster  bdec(4) append
estat firststage, all
quietly ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_othcprogrammerswt iv_num_a  iv_bartik ivd_othcp  ivd_num_a  ivd_bartik)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh  avgdmest $controls $change
estat overid
hausman . ols2


*TABLE 5 additional implications
regress empdiff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change , robust
outreg using table5, se 3aster  bdec(4) replace
regress empdiff  surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00  $controls $change , robust
outreg using table5, se 3aster  bdec(4) append

*REST OF TABLE 5 IS AT THE BOTTOM OF THE FILE AS USES DIFFERENT DATASET
*FIGURES 1 AND 2 ARE AT THE BOTTOM OF THE FILE AS USE DIFFERENT DATASETS


*APPENDIX TABLES (FIGURES AND REST OF TABLE 5 BELOW)
*Appendix TABLE 1: OTHER MEASURES OF IT
*Alternative weighting
regress wagediff surv_deep_newweight indivhomeinternet00_cty missing  $controls $change,  robust 
outreg using tableA1, se 3aster  bdec(4) replace

*missing data
mi set mlong
mi register imputed surv_deeppost00
set seed 28005
mi impute regress surv_deeppost00= $controls $change, add(30) force
mi estimate: regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change, robust /*all counties-missing by multiple imputation*/
*outreg using tableA1, se 3aster  bdec(4) append
*outreg using tableA4, se 3aster  bdec(4) append
*OUTREG DOESN'T WORK--NEED TO ENTER MANUALLY
*significance drops with multiple imputation--this is normal--the coef doesn`t change but lose significance almost by definition.

use countygrowth, clear

regress wagediff surv_deeppost00 surv_pcperemp00  indivhomeinternet00_cty missing $controls $change , robust
outreg using tableA1, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 surv_shalpost00  indivhomeinternet00_cty missing $controls $change , robust
outreg using tableA1, se 3aster  bdec(4) append




*APPENDIX TABLE 2--CONTINUOUS
regress wagediff surv_deeppost00 highinc2000 inc_surv_deeppost00 $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) replace
regress wagediff surv_deeppost00 higheduc2000 educ_surv_deeppost00  $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highind2000 ind_surv_deeppost00  $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highpop2000 pop_surv_deeppost00  $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000  inc_surv_deeppost00 educ_surv_deeppost00 pop_surv_deeppost00 ind_surv_deeppost00  $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_surv_deep00  $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 inc_surv_deeppost00 educ_surv_deeppost00 pop_surv_deeppost00 ind_surv_deeppost00 educ_inc_ind_pop_surv_deep00  $controls $change , robust 
outreg using tableA2, se 3aster  bdec(4) append


*APPENDIX TABLE 3--further robustness
*ROBUSTNESS
*two-way interactions
global controls lnpop pctblk1990 pctunivp1990 pctHSp1990 pctbelowPL1990 medhhinc1990 carnegie1_enr frac_in_eng_prog npatent1980s frprof pct65p1990 netmig95
regress wagediff surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 ind_pop_dum_surv_deeppost00 educ_ind_dum_surv_deeppost00 inc_ind_dum_surv_deeppost00 inc_pop_dum_surv_deeppost00 educ_pop_dum_surv_deeppost00 educ_inc_dum_surv_deeppost00  inc_dum_surv_deeppost00 educ_dum_surv_deeppost00 pop_dum_surv_deeppost00 ind_dum_surv_deeppost00 $controls $change , robust 
outreg using tableA3, se 3aster  bdec(4) replace
*msa only
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if msadum==1,  robust  
outreg using tableA3, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00  $controls $change if msadum==1, robust
outreg using tableA3, se 3aster  bdec(4) append
*no controls
regress wagediff surv_deeppost00 ,  robust  
outreg using tableA3, se 3aster  bdec(4) append
regress wagediff surv_deeppost00  allhigh2000 educ_inc_ind_pop_dum_surv_deep00, robust
outreg using tableA3, se 3aster  bdec(4) append



*table A4 ROBUSTNESS TO WEIGHTS
gen educ_inc_ind_pop_dum_sdeepnewwt=surv_deep_newweight*allhigh2000
gen educ_inc_ind_pop_dum_deepcty=deep_county*allhigh2000
gen educ_inc_ind_pop_dum_survdpcty=surv_deep_county*allhigh2000
gen educ_inc_ind_pop_dum_deep00=deeppost00*allhigh2000
*weight is num obs in data over num obs in census
regress wagediff surv_deep_newweight indivhomeinternet00_cty missing  $controls $change,  robust 
outreg using tableA4, se 3aster  bdec(4) replace
regress wagediff surv_deep_newweight highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_sdeepnewwt  $controls $change , robust
outreg using tableA4, se 3aster  bdec(4) append
*no weights
regress wagediff deep_county indivhomeinternet00_cty missing  $controls $change,  robust 
outreg using tableA4, se 3aster  bdec(4) append
regress wagediff deep_county highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_deepcty  $controls $change , robust
outreg using tableA4, se 3aster  bdec(4) append
*no county weights
regress wagediff surv_deep_county indivhomeinternet00_cty missing  $controls $change,  robust 
outreg using tableA4, se 3aster  bdec(4) append
regress wagediff surv_deep_county highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_survdpcty  $controls $change , robust
outreg using tableA4, se 3aster  bdec(4) append
*no time weights
regress wagediff deeppost00 indivhomeinternet00_cty missing  $controls $change, robust 
outreg using tableA4, se 3aster  bdec(4) append
regress wagediff deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_deep00  $controls $change , robust
outreg using tableA4, se 3aster  bdec(4) append




*TABLE A5 missing data
regress wagediff surv_deeppost00_all indivhomeinternet00_cty missing  $controls $change,  robust /*all counties-missing are zero*/
outreg using tableA5, se 3aster  bdec(4) replace
gen educ_inc_ind_pop_dum_survdeep00a=educ_inc_ind_pop_dum_surv_deep00
replace educ_inc_ind_pop_dum_survdeep00a=0 if educ_inc_ind_pop_dum_survdeep00a==.

regress wagediff surv_deeppost00_all highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_survdeep00a  $controls $change , robust
outreg using tableA5, se 3aster  bdec(4) append


use countygrowth, clear
mi set mlong
mi register imputed surv_deeppost00
mi impute regress surv_deeppost00= $controls $change, add(30) force
mi set mlong
*same as above
mi estimate: regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change, robust /*all counties-missing by multiple imputation*/
*outreg using tableA5, se 3aster  bdec(4) append

use countygrowth, clear
gen highall_surv_deep00=educ_inc_ind_pop_dum_surv_deep00
mi set mlong
mi register imputed  highall_surv_deep00 surv_deeppost00
mi impute monotone (regress) highall_surv_deep00 surv_deeppost00= $controls $change  highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 , add(30) force
mi estimate: regress wagediff surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 highall_surv_deep00 $controls $change, robust
*outreg using tableA5, se 3aster  bdec(4) append


use countygrowth, clear

*APPENDIX TABLE A6--ALTERNATIVE DEFINITIONS
gen pop_dum_surv_deepwide=surv_deepwide*highpop
gen inc_dum_surv_deepwide=surv_deepwide*highinc
gen ind_dum_surv_deepwide=surv_deepwide*highind
gen educ_dum_surv_deepwide =surv_deepwide*higheduc
gen all_dum_surv_deepwide =surv_deepwide*allhigh

gen pop_dum_surv_deepalt1=surv_deepalt1*highpop
gen inc_dum_surv_deepalt1=surv_deepalt1*highinc
gen ind_dum_surv_deepalt1=surv_deepalt1*highind
gen educ_dum_surv_deepalt1 =surv_deepalt1*higheduc
gen all_dum_surv_deepalt1 =surv_deepalt1*allhigh

gen pop_dum_surv_deepalt2=surv_deepalt2*highpop
gen inc_dum_surv_deepalt2=surv_deepalt2*highinc
gen ind_dum_surv_deepalt2=surv_deepalt2*highind
gen educ_dum_surv_deepalt2 =surv_deepalt2*higheduc
gen all_dum_surv_deepalt2 =surv_deepalt2*allhigh

gen pop_dum_surv_deepalt3=surv_deepalt3*highpop
gen inc_dum_surv_deepalt3=surv_deepalt3*highinc
gen ind_dum_surv_deepalt3=surv_deepalt3*highind
gen educ_dum_surv_deepalt3 =surv_deepalt3*higheduc
gen all_dum_surv_deepalt3 =surv_deepalt3*allhigh


regress wagediff  surv_deepwidewt_county indivhomeinternet00_cty missing  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) replace
regress wagediff surv_deepwide highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000  all_dum_surv_deepwide  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append

regress wagediff surv_deepalt1wt_county indivhomeinternet00_cty missing  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append
regress wagediff surv_deepalt1 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000  all_dum_surv_deepalt1  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append

regress wagediff surv_deepalt2wt_county indivhomeinternet00_cty missing  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append
regress wagediff surv_deepalt2 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000  all_dum_surv_deepalt2  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append

regress wagediff surv_deepalt3wt_county indivhomeinternet00_cty missing  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append
regress wagediff surv_deepalt3 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 all_dum_surv_deepalt3  $controls $change , robust
outreg using tableA6, se 3aster  bdec(4) append


*APPENDIX TABLE 7
pwcorr surv_deeppost00 surv_deepwide surv_deepalt1 surv_deepalt2 surv_deepalt3
*
*

*
*APPENDIX TABLE 8
*REPEAT OF TABLE 3
*

*APPENDIX TABLE 9
*REPEAT OF TABLE 4





*APPENDIX TABLE 10--other instruments for table 2
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  avgdmest $controls $change
estimates store ols


ivregress liml wagediff (surv_deeppost00=iv_first_p )  indivhomeinternet00_cty missing  avgdmest $controls $change, first vce(cluster state)
outreg using tableA10, se 3aster  bdec(4) replace
estat firststage
quietly ivregress liml wagediff (surv_deeppost00=iv_first_p )  indivhomeinternet00_cty missing  avgdmest $controls $change
hausman . ols


ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt iv_first_p iv_num_a iv_bartik)  indivhomeinternet00_cty missing  avgdmest $controls $change, first vce(cluster state)  
outreg using tableA10, se 3aster  bdec(4) append
estat firststage
quietly ivregress liml wagediff (surv_deeppost00=iv_othcprogrammerswt iv_first_p  iv_num_a  iv_bartik)  indivhomeinternet00_cty missing  avgdmest $controls $change
estat overid
hausman . ols



*APPENDIX TABLE 11--other instruments for table 3

gen ivd_num_a =iv_num_a*allhigh
gen ivd_first_p= iv_first_p*allhigh
gen ivd_othcp=iv_othcp*allhigh
gen ivd_bartik= iv_bartik*allhigh
 
regress wagediff surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh avgdmest $controls $change
estimates store ols2

ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_othcprogrammerswt  iv_num_a iv_first_p iv_bartik ivd_othcp ivd_first_p ivd_num_a  ivd_bartik)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh  avgdmest $controls $change, first vce(cluster state)
outreg using tableA11, se 3aster  bdec(4) replace
estat firststage, all
quietly ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00= iv_othcprogrammerswt iv_first_p  iv_num_a  iv_bartik ivd_othcp ivd_first_p ivd_num_a  ivd_bartik)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh  avgdmest $controls $change
estat overid
hausman . ols2

ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_first_p ivd_first_p)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh $controls $change, first vce(cluster state)
outreg using tableA11, se 3aster  bdec(4) append
estat firststage, all
quietly ivregress liml wagediff (surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00=iv_first_p ivd_first_p)  highinc2000 higheduc2000 highind2000 highpop2000 allhigh $controls $change, vce(un)
hausman . ols2


*APPENDIX TABLE 12--ADJACENT LOCAITONS
gen msa_allhigh_deeppost00=msa_allhigh*surv_deeppost00*(1-allhigh)
regress wagediff surv_deeppost00 msa_allhigh_deeppost00 educ_inc_ind_pop_dum_surv_deep00  highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000  $controls $change, robust
outreg using tableA12, se 3aster  bdec(4) replace
regress wagediff surv_deeppost00 msa_allhigh_deeppost00 inc_dum_surv_deeppost00 educ_dum_surv_deeppost00 pop_dum_surv_deeppost00 ind_dum_surv_deeppost00 educ_inc_ind_pop_dum_surv_deep00  highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 $controls $change, robust
outreg using tableA12, se 3aster  bdec(4) append

*APPENDIX TABLE 13--same as figure 2

*APPENDIX TABLE 14: ESTABLISHMENTS
regress estdiff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change , robust
outreg using tableA14, se 3aster  bdec(4) replace
regress estdiff  surv_deeppost00 highinc2000 higheduc2000 highind2000 highpop2000 allhigh2000 educ_inc_ind_pop_dum_surv_deep00  $controls $change , robust
outreg using tableA14, se 3aster  bdec(4) append

*APPENDIX TABLE 15: labor market tightness
*unemp wt
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if  pctunempwt<  .0572408 , robust
outreg using tableA15, se 3aster  bdec(4) replace
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if  pctunempwt>=  .0572408 & pctunempwt~=., robust
outreg using tableA15, se 3aster  bdec(4) append

*unemp collegewt
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if  pctunemphighskillwt< .0232496  , robust
outreg using tableA15, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if  pctunemphighskillwt>= .0232496  & pctunemphighskillwt~=., robust
outreg using tableA15, se 3aster  bdec(4) append

*Rust belt--from Wikipedia--IL, IN, OH, WI, MI, NY, NJ, PA, MD, WV
gen rustbelt=(state=="IL")|(state=="IN")|(state=="OH")|(state=="WI")|(state=="MI")|(state=="NY")|(state=="NJ")|(state=="PA")|(state=="MD")|(state=="WV")
replace rustbelt=0 if msa==2281|msa==1160|msa==875|msa==1930|msa==3640|msa==5015|msa==5190|msa==5380|msa==5480|msa==5600|msa==5640|msa==5660|msa==8040|msa==8480|msa==8880|msa==5483 /*NYC*/
replace rustbelt=0 if msa==560|msa==6160|msa==8760|msa==9160 /*Philly*/

*rust belt
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if rustbelt==1, robust
outreg using tableA15, se 3aster  bdec(4) append
*everyone else
regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change if rustbelt==0, robust
outreg using tableA15, se 3aster  bdec(4) append



********************************************************************************************


*TABLE 5--more: WAGE GROWTH 1999 TO 2005 UNRELATED TO EARLY USE OF ADVANCED INTERNET (MAYBE)
use countyyear.dta, clear
replace medhhinc1990=medhhinc1990/1000
replace npatent1980s=npatent1980s/1000
replace netmig95=netmig95/1000
keep if year==2005|year==1999

sort county year
gen wagediff=lnweekwage-lnweekwage[_n-1]
gen empdiff=lnemp-lnemp[_n-1]
gen estdiff=lnest-lnest[_n-1]

replace change_netmig=netmig-netmig[_n-1]
replace change_netmig=change_netmig/1000

keep if year==2005

gen educ_inc_ind_pop_dum_surv_deep05=allhigh*surv_deeppost00

regress wagediff surv_deeppost00 indivhomeinternet00_cty missing  $controls $change , robust
outreg using table5, se 3aster  bdec(4) append
regress wagediff surv_deeppost00 highinc higheduc highind highpop allhigh educ_inc_ind_pop_dum_surv_deep05  $controls $change , robust
outreg using table5, se 3aster  bdec(4) append



*FIGURE 2: FALSIFICATION FOR ALL DATA (APPENDIX TABLE 13)
use countyyear.dta, clear
replace medhhinc1990=medhhinc1990/1000
replace npatent1980s=npatent1980s/1000
replace netmig95=netmig95/1000

keep if year<2001
replace change_netmig=netmig-netmig[_n-1]
replace change_netmig=change_netmig/1000

 
xi i.year*change_netmig i.year*change_pct65 i.year*change_pctHSp i.year*change_pctunivp i.year*change_pctblk i.year*change_totalpop i.year*netmig95 i.year*pct65p1990 i.year*frprof i.year*npatent1980s i.year*frac_in_eng_prog i.year*carnegie1_enr i.year*medhhinc1990 i.year*pctbelowPL1990 i.year*pctHSp1990 i.year*pctunivp1990 i.year*pctblk1990 i.year*lnpop


*FIGURE 2: FALSIFICATION FOR INTERACTED DATA (APPENDIX TABLE 13)
xtreg lnweekwage surv_deeppost_* educ_inc_ind_pop_dum_surv_deep*  _I* if year<2001, i(group) fe robust
outreg using figure2, se 3aster  bdec(4) replace


*FIGURE 1: FIGURE COMPARING AMT OF GROWTH
clear
use countyyear.dta
sort year wagegrowth

gen type=wagegrowth if allhigh==0
gen type3=wagegrowth if allhigh==1
label var type "Not top county in income, education, population, and IT-intensity in 1990"
label var type3 "Top county in income, education, population, and IT-intensity in 1990"
label var surv_deeppost00 "fraction firms with advanced internet"


regress wagegrowth surv_deeppost00 if  surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000
predict fitted  if  surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000

regress type surv_deeppost00 if  surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000
predict fitted1 if  surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000


regress type3 surv_deeppost00 if  surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000
predict fitted3  if  surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000



twoway  (scatter wagegrowth surv_deeppost00, sort mcolor(black) msize(vsmall) msymbol(circle) ytitle("wage growth 1995 to 2000")) (line fitted surv_deeppost00, sort mcolor(blue)) if surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000, legend(off)
twoway  (scatter type surv_deeppost00 if allhigh==0, sort mcolor(black) msize(vsmall) msymbol(circle) ytitle("wage growth 1995 to 2000"))  (scatter type3 surv_deeppost00 if allhigh==1, sort mcolor(blue) msymbol(smtriangle_hollow)) (line fitted1  surv_deeppost00, mcolor(black) sort) (line fitted3 surv_deeppost00, mcolor(blue) sort ) if surv_deeppost00<.3 & surv_deeppost00~=0 & wagegrowth>-.5 & wagegrowth<1 & year==2000, legend(on cols(1))
*then need to adjust color manually



*log close
