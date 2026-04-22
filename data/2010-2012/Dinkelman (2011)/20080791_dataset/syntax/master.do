* master.do
* replication files: jan 2011

******set working dirs ***********
* CHANGE THIS LOCAL to point to your folder
local here "\research\projects\electricity\replicationfiles"
global data "`here'\data"
global syntax "`here'\syntax"
global temp "`here'\temp"

clear
clear matrix
set mem 700m
set matsize 2500
set more off

cap log close
log using "$temp\analysis1_$S_DATE.log", replace

****************************
/*produces
Tables 1-6, 8-9
output for Figure 1 and 3
Appendix 2 Figure 1 and Tables 1-3
Appendix 3 Table 1, 2, 7, 8
Appendix 4 Table 4 */
do "$syntax\mainanalysis_communitydata.do"

/* produces
Table 7 and Figure 2 for main paper*/
do "$syntax\supplanalysis_hhsurveydata.do" 

/* set up for estimating standard errors corrected for spatial correlation - Appendix 3*/
do "$syntax\cr_varnameslist.do"		/*creates a dummy dataset containing varnames and senames for use in the output of supplanalysis_spatialse.do */
do "$syntax\x_ols_td.ado"				/* programs for constructing s.e. corrected for spatial correlation with OLS*/
do "$syntax\x_gmm_td.ado"				/* programs for constructing s.e. corrected for spatial correlation with IV*/

/* produces
Appendix 3 Tables 4-6: main results with s.e. corrected for spatial correlation*/
* warning: this file takes a long time to run
do "$syntax\supplanalysis_spatialse.do" 

/* produces
output for Appendix 2 Figure 2
Appendix 3 Table 8
Appendix 4 table 1-3*/
do "$syntax\other.do" 				

log close
exit
