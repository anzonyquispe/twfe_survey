/*
This File runs the FE and OLS regressions for different ages, and the pooled regression, in one go.
If you want to see regression output details, e.g. with standard errors and sample size, remove the quietly.
*/

local v  671
local v2 =`v'+1
local v3 =`v'+2


include "C:\Research\minwage\SS_convert_consM.do"
convert `v' no
convert `v'
convert `v2'
convert `v3'


cd "C:\Research\minwage"


quietly do SS_sims_reg_fe.do `v' `v'
di " " $cons_OLS " " $inv_OLS " " $cons_FE " " $inv_FE

quietly do SS_sims_reg_fe.do `v' `v2'
di " " $cons_OLS " " $inv_OLS " " $cons_FE " " $inv_FE

quietly do SS_sims_reg_fe.do `v' `v3'
di " " $cons_OLS " " $inv_OLS " " $cons_FE " " $inv_FE

quietly do SS_pooled_regs_fe.do `v' 0
di " " $cons_OLS " " $inv_OLS " " $cons_FE " " $inv_FE



/*
*If running quantile regs:
cd "C:\Research\minwage"
log using sims_qregs.log, replace
do SS_pooled_regs_fe.do 671 1 /*Baseline*/
do SS_pooled_regs_fe.do 771 1 /*Baseline w/ adjustment costs, and beta adjusted to match buffer in baseline */
*/