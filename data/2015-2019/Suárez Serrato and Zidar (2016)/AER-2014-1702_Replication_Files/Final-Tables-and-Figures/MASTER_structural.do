*Paths
global revision 		   "/Users/johnwieselthier/Desktop/Final Tables and Figures/" /* Change this path to run file */
global CMD_tablepath	   "$revision/out/Tables/CMD" /* Structural estimates outpath */
global CMD_graphpath 	   "$revision/out/Figures/CMD" /* Contour pies, etc. (structural) */
global dopath              "$revision/do"
global dtapath             "$revision/dta"
	
clear
set more off

/*
*********************************************************
*1. Construct Datasets used for Structural Estimates
*********************************************************
do "$dopath/prep/prep_ILS_1_shocks_3_parm.do"
do "$dopath/prep/prep_ILS_3_shocks_6_parm_housing.do"
do "$dopath/prep/prep_ILS_3_shocks_7_parm_housing.do"
*/

*********************************************************
*2. Main Paper Structural estimation
*********************************************************
do "$dopath/CMD/ILS_1_shocks_3_parm.do" 
do "$dopath/CMD/ILS_3_shocks_6_parm_housing.do"
do "$dopath/CMD/ILS_3_shocks_7_parm_housing.do"

*********************************************************
*3. Appendix Structural estimation
*********************************************************
do "$dopath/Appendix/CMD_appendix/ILS_3_shocks_6_parm_housing_091815_v2.do"
do "$dopath/Appendix/CMD_emp/ILS_3_shocks_6_parm_housing_091815_v2.do"
