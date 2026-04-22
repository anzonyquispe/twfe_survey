clear
set mem 80m
set more off
set matsize 150

/* This program generates the results reported in Tables 1 and 10 */

use Industry.dta
xi: reg xb1992 i.sectorII
global ssII "_IsectorII_*"


/* TABLE 1 */

sum tbw1991 tbw1992  Targbraw92 tab1992_inputs DTWAw dtaw_inputs

/* TABLE 10 */


/* PANEL A: OLS */

# delimit ;

drop if tbw1991==.;

areg dlog_xb_9692 dtbw1992, a(sectorII) r;

areg dlog_xb_9692 dtbw1992 DTWAw dtaw_inputs  
sigma log_K_L_us_avg80 log_Ls_L_us_avg80, a(sectorII) r;

areg dlog_xb_9692 dtbw1992 DTargbraw92 dtab1992_inputs 
sigma log_K_L_us_avg80 log_Ls_L_us_avg80 , a(sectorII) r;

reg dlog_xb_9692 dtbw1992,  r;

reg dlog_xb_9692 dtbw1992 DTWAw dtaw_inputs  
sigma log_K_L_us_avg80 log_Ls_L_us_avg80,  r;

reg dlog_xb_9692 dtbw1992 DTargbraw92 dtab1992_inputs 
sigma log_K_L_us_avg80 log_Ls_L_us_avg80 ,  r;

/* PANEL B: IV and PANEL C: FIRST STAGE */


ivregress  2sls   dlog_xb_9692  (dtbw1992= tbw1991) $ssII, vce(robust) first ;
estat firststage;

ivregress  2sls dlog_xb_9692  (dtbw1992= tbw1991) 
DTWAw dtaw_inputs 
sigma log_K_L_us_avg80 log_Ls_L_us_avg80 $ssII,  vce(robust) first;
estat firststage;

ivregress  2sls dlog_xb_9692  (dtbw1992= tbw1991) 
DTargbraw92 dtab1992_inputs 
sigma log_K_L_us_avg80 log_Ls_L_us_avg80 $ssII,  vce(robust) first ;
estat firststage;

ivregress  2sls   dlog_xb_9692  (dtbw1992= tbw1991) , vce(robust) first;
estat firststage;

ivregress  2sls dlog_xb_9692  (dtbw1992= tbw1991) 
DTWAw dtaw_inputs 
sigma log_K_L_us_avg80 log_Ls_L_us_avg80 ,  vce(robust) first;
estat firststage;

ivregress  2sls dlog_xb_9692  (dtbw1992= tbw1991) 
DTargbraw92 dtab1992_inputs 
sigma log_K_L_us_avg80 log_Ls_L_us_avg80 ,  vce(robust) first;
estat firststage;


