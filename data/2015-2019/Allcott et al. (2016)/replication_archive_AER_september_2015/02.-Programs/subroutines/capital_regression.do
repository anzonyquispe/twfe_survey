/*

Allan Collard-Wexler
September 17 2014
Project: Indian Power Generation, Post AER 

Program to estimate production function
*/


clear all
*cd "~/Dropbox/India_Power_Shortages/05. Intermediate Datasets" //adjusted SOC

// Code to run GMM estimator

*-------------------------------------BEGIN MATA PROGRAM--------------------------------------------*
mata:

void GMM_CRIT(todo,betas,PHI,PHI_lag,K,K_lag,Z,W,crit,g,H)
{
CONST=J(rows(PHI),1,1)
// Gross Output Criterion Function
	OMEGA=PHI-K*betas'
	OMEGA_lag=PHI_lag-K_lag*betas'
	OMEGA_lag_pol=(CONST,OMEGA_lag,OMEGA_lag:^2)
//	OMEGA_lag_pol=(CONST,OMEGA_lag,OMEGA_lag:^2,OMEGA_lag:*K_lag)
//	OMEGA_lag_pol=(CONST,OMEGA_lag,OMEGA_lag:^2,K_lag,OMEGA_lag:*K_lag)
//	OMEGA_lag_pol=(CONST,OMEGA_lag)
	g_b = invsym(OMEGA_lag_pol'OMEGA_lag_pol)*OMEGA_lag_pol'OMEGA
	XI=OMEGA-OMEGA_lag_pol*g_b
	crit=(Z'XI)'*W*(Z'XI)
}
end
*-----------------------------------------END MATA PROGRAM---------------------------------------*

*---------------------------------------------------------------------------------------------------------------*
*                      ACF GROSS OUTPUT
*                     with survival control
*---------------------------------------------------------------------------------------------------------------*


cap program drop abond_capital
program abond_capital, eclass

preserve
capture drop if $dropglobal

// Gross Output Criterion Function
mata: C=st_data(.,("const"))
mata: PHI=st_data(.,("tdlnY"))
mata: PHI_lag=st_data(.,("LtdlnY"))
mata: Z=st_data(.,("lnK"))
mata: K=st_data(.,("lnK"))
mata: K_lag=st_data(.,("LlnK"))
// Weighting Matrix
//mata: W=invsym(Z'Z)
mata: W=I(cols(Z))
mata: S=optimize_init()

mata: optimize_init_evaluator(S, &GMM_CRIT())
mata: optimize_init_evaluatortype(S,"d0")
mata: optimize_init_technique(S, "nm")
mata: optimize_init_nmsimplexdeltas(S, 0.1)
mata: optimize_init_which(S,"min")

// These starting values come from OLS Version
mata: optimize_init_params(S,(0.0))
mata: optimize_init_argument(S, 1, PHI)
mata: optimize_init_argument(S, 2, PHI_lag)
mata: optimize_init_argument(S, 3, K)
mata: optimize_init_argument(S, 4, K_lag)
mata: optimize_init_argument(S, 5, Z)
mata: optimize_init_argument(S, 6, W)

// Minimize Criterion
mata: p=optimize(S)
mata: p
mata: st_matrix("beta_k",p)

restore
matrix beta_k=beta_k[1,1]
mat colnames beta_k = beta_k
ereturn post beta_k
//scalar beta_k=beta_k[1,1]
end
*-----------------------------------------END ESTIMATOR---------------------------------------*


// Data file
use panelgroup year lshare_leontief mshare_leontief lnY lnM lnL lnK nic87 nic87_super using "$work/temp.dta" , clear //adjusted SOC
drop if lshare_leontief+mshare_leontief >.95 //added SOC
/*
plant panel identifier: panelgroup
beta_m : mshare_leontief
beta_l : lshare_leontief
y_it : lnY
m_it : lnM
l_it ; lnL
k_it : lnK
*/

xtset panelgroup year
// How we get coefficients
gen beta_m=mshare_leontief
gen beta_l=lshare_leontief
g gamma = eshare_final

// Transformed output net of labor and material contribution
gen tdlnY=lnY-beta_l*lnL-beta_m*lnM

// Make Lags
gen LtdlnY=L.tdlnY
gen LlnK=L.lnK

gen const=1
drop if LlnK==. | lnK==. | LtdlnY==. | tdlnY==.

count
// OLS Version
reg tdlnY lnK
qreg tdlnY lnK

// Output Variable
// global y="lsumdpv_all"

// Run Program
global dropglobal=""


*log using capital_estimation.log, replace //adjusted SOC
*abond_capital
*bootstrap , reps(50) seed(12345): abond_capital
*log close //adjusted SOC


g betak = .
g sebetak = .
encode nic87_super, g(snic2)
levelsof snic2, local(supernic)
foreach j of local supernic {
dis "RUNNING FOR `j' `j' `j' `j'"
global dropglobal "snic2!=`j'"
display "$dropglobal"
bootstrap , reps(50) seed(12345): abond_capital
estimates store estnic`i'
replace betak = _b[beta_k] if snic2== `j'
replace sebetak = _se[beta_k] if snic2== `j'
}


disp("end")
drop snic2
save "$work/temp2.dta", replace
