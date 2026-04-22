/*

Program to Estimate Cost of Generators

Allan Collard-Wexler

October 1 2014

*/

cd ~/Dropbox/India_Power_Shortages/matlab/
clear all
set more off
set mem 500m
set linesize 200


// (assuming a ten year life)
global gen_lifespan=10

// Price of Self-Generated Power
// Source: World Bank Survey
global p_e_s=7
// Price of Grid Power
global p_e_g=4.5

// Hours of production: 6 hours a day
global hours_prod=6*365


global graphit=1

cd simulation_asi_inputs_dec2014

// Generator 

global graphit=1
global p_e_s=7
global elasticity=-10
global filename="ASI_Prediction2005_7.csv"


clear
insheet using $filename

// Keep plants that are not in exogenous generation industries
keep if exog_gen_industry==0

g kshare_Y=fcapclose/grsale_defl
               * trim outliers
               replace kshare_Y = . if kshare_Y>20 //

cap drop if $droplist
//noisily des
foreach x of varlist year-y_no_generator {
destring `x', replace force
} 

//---------------------------------------------------------------------------------------
// 0) Prep Work
//---------------------------------------------------------------------------------------

cap destring e_grid_no_generator, replace force
cap destring e_grid_generator, replace force


sum delta_psp, meanonly
scalar shortage=r(mean)

drop if messedupcompute==-2

//---------------------------------------------------------------------------------------
// 1) Dollar Per Megawatt to make indifference between generator and no-generator
//---------------------------------------------------------------------------------------
replace e_self_shortage=e_self_shortage/$p_e_s
replace e_self_no_shortage=e_self_no_shortage/$p_e_s

replace e_grid_shortage=e_grid_shortage/$p_e_g
replace e_grid_no_shortage=e_grid_no_shortage/$p_e_g

gen total_power=e_self_shortage + e_grid_shortage

// Size of Required Generator
gen gen_size= total_power/($hours_prod)


//---------------------------------------------------------------------------------------
// 1.5) Profits of a Generator, Cost of These
//---------------------------------------------------------------------------------------
gen profit_no_shortage=y_no_shortage-p_m * m_no_shortage -p_l *  l_no_shortage-$p_e_g* e_grid_no_shortage-$p_e_s* e_self_no_shortage
gen profit_shortage=y_shortage-p_m* m_shortage-p_l* l_shortage-$p_e_g* e_grid_shortage-$p_e_s* e_self_shortage

gen has_gen=(zero_generation_flag==1)


gen log_gen_size=log(gen_size)
reg zero_generation_flag log_gen_size 

gen log_k=log(k)
mata: LOG_K=st_data(.,("log_k"))
mata: LOG_G=st_data(.,("log_gen_size"))


// Show these
mata: GENERATOR=st_data(.,("has_gen"))
mata: cov_data_k=variance((GENERATOR,LOG_K))
mata: cov_data_k[2,1]
mata: cov_data_g=variance((GENERATOR,LOG_G))
mata: cov_data_g[2,1]
mata: mean(GENERATOR)


//---------------------------------------------------------------------------------------
// 2.0) Code to run GMM estimator
//---------------------------------------------------------------------------------------

*-------------------------------------BEGIN MATA PROGRAM--------------------------------------------*
mata:

void GMM_CRIT1(todo,betas,GENERATOR,PROFIT_GEN,PROFIT_NO_GEN,GEN_SIZE,LOG_K,LOG_G,crit,g,H)
{
GEN_COSTS=exp(betas[1,1]):*(GEN_SIZE)
PREDICTED_GEN=PROFIT_GEN:>(PROFIT_NO_GEN+GEN_COSTS)
cov_hat_k=variance((PREDICTED_GEN,LOG_K))
cov_data_k=variance((GENERATOR,LOG_K))

cov_hat_g=variance((PREDICTED_GEN,LOG_G))
cov_data_g=variance((GENERATOR,LOG_G))


// SCORE
//xi=(mean(PREDICTED_GEN)-mean(GENERATOR)),(cov_hat_k[2,1]-cov_data_k[2,1]),(cov_hat_g[2,1]-cov_data_g[2,1])
xi=(mean(PREDICTED_GEN)-mean(GENERATOR))

crit=10000:*(xi*xi')
}


void GMM_CRIT2(todo,betas,GENERATOR,PROFIT_GEN,PROFIT_NO_GEN,GEN_SIZE,LOG_K,LOG_G,crit,g,H)
{
GEN_COSTS=exp(betas[1,1]):*(GEN_SIZE):^betas[1,2]
PREDICTED_GEN=PROFIT_GEN:>(PROFIT_NO_GEN+GEN_COSTS)
cov_hat_k=variance((PREDICTED_GEN,LOG_K))
cov_data_k=variance((GENERATOR,LOG_K))

cov_hat_g=variance((PREDICTED_GEN,LOG_G))
cov_data_g=variance((GENERATOR,LOG_G))


// SCORE
//xi=(mean(PREDICTED_GEN)-mean(GENERATOR)),(cov_hat_k[2,1]-cov_data_k[2,1]),(cov_hat_g[2,1]-cov_data_g[2,1])
xi=(mean(PREDICTED_GEN)-mean(GENERATOR)),(cov_hat_g[2,1]-cov_data_g[2,1])

crit=10000:*(xi*xi')

}


end

*-----------------------------------------END MATA PROGRAM---------------------------------------*


// Program 
cap program drop gen_cost_estimator
program gen_cost_estimator, eclass

capture drop if $dropglobal

* Load Data
mata: LOG_K=st_data(.,("log_k"))
mata: LOG_G=st_data(.,("log_gen_size"))
mata: GENERATOR=st_data(.,("has_gen"))
mata: PROFIT_GEN=st_data(.,("profit_generator"))
mata: PROFIT_NO_GEN=st_data(.,("profit_no_generator"))
mata: GEN_SIZE=st_data(.,("gen_size"))

* Setup Optimizer
mata: S3=optimize_init()
mata: optimize_init_evaluator(S3, &GMM_CRIT2())
mata: optimize_init_evaluatortype(S3,"d0")
mata: optimize_init_technique(S3, "nm")
mata: optimize_init_nmsimplexdeltas(S3, 1)
mata: optimize_init_which(S3,"min")

* These starting values come from Regressions on Generators Costs
mata: optimize_init_params(S3,(12,0.8))
mata: optimize_init_argument(S3, 1, GENERATOR)
mata: optimize_init_argument(S3, 2, PROFIT_GEN)
mata: optimize_init_argument(S3, 3, PROFIT_NO_GEN)
mata: optimize_init_argument(S3, 4, GEN_SIZE)
mata: optimize_init_argument(S3, 5, LOG_K)
mata: optimize_init_argument(S3, 6, LOG_G)

* Minimize Criterion

mata: p3=optimize(S3)
mata: p3

forval i=1/4 {
mata: optimize_init_params(S3,p3)
mata: p3=optimize(S3)
mata: p3

mata: GEN_COSTS=exp(p3[1,1]):*(GEN_SIZE):^p3[1,2]
mata: PREDICTED_GEN=PROFIT_GEN:>(PROFIT_NO_GEN+GEN_COSTS)
mata: cov_hat_k=variance((PREDICTED_GEN,LOG_K))
mata: cov_data_k=variance((GENERATOR,LOG_K))

mata: cov_hat_g=variance((PREDICTED_GEN,LOG_G))
mata: cov_data_g=variance((GENERATOR,LOG_G))

mata: genpredvec=(mean(PREDICTED_GEN),mean(GENERATOR))

mata: genpredvec
mata: cov_hat_g[2,1],cov_data_g[2,1]
mata: cov_hat_k[2,1],cov_data_k[2,1]
}


mata: st_matrix("sigmas2",p3)



mat colnames sigmas2 = sigma_0, sigma_1
ereturn post sigmas2
end


gen_cost_estimator


log using estimate_cost_gens_results.log, replace

bootstrap , reps(50) seed(12345): gen_cost_estimator

log close

matrix cost_not_linear=e(b)


// Program 
cap program drop gen_cost_estimator_linear
program gen_cost_estimator_linear, eclass

capture drop if $dropglobal

// Load Data
mata: LOG_K=st_data(.,("log_k"))
mata: LOG_G=st_data(.,("log_gen_size"))
mata: GENERATOR=st_data(.,("has_gen"))
mata: PROFIT_GEN=st_data(.,("profit_generator"))
mata: PROFIT_NO_GEN=st_data(.,("profit_no_generator"))
mata: GEN_SIZE=st_data(.,("gen_size"))

// Setup Optimizer
mata: S3=optimize_init()
mata: optimize_init_evaluator(S3, &GMM_CRIT1())
mata: optimize_init_evaluatortype(S3,"d0")
mata: optimize_init_technique(S3, "nm")
mata: optimize_init_nmsimplexdeltas(S3, 1)
mata: optimize_init_which(S3,"min")

// These starting values come from Regressions on Generators Costs
mata: optimize_init_params(S3,10)
mata: optimize_init_argument(S3, 1, GENERATOR)
mata: optimize_init_argument(S3, 2, PROFIT_GEN)
mata: optimize_init_argument(S3, 3, PROFIT_NO_GEN)
mata: optimize_init_argument(S3, 4, GEN_SIZE)
mata: optimize_init_argument(S3, 5, LOG_K)
mata: optimize_init_argument(S3, 6, LOG_G)

// Minimize Criterion

mata: p3=optimize(S3)
mata: p3

forval i=1/4 {

mata: GEN_COSTS=exp(p3[1,1]):*(GEN_SIZE)
mata: PREDICTED_GEN=PROFIT_GEN:>(PROFIT_NO_GEN+GEN_COSTS)
mata: genpredvec=(mean(PREDICTED_GEN),mean(GENERATOR))
mata: genpredvec
mata: optimize_init_params(S3,p3)
mata: p3=optimize(S3)
mata: p3
}


mata: st_matrix("sigmas2",p3)



mat colnames sigmas2 = sigma_0
ereturn post sigmas2
end


log using estimate_cost_gens_results.log, append

bootstrap , reps(50) seed(12345): gen_cost_estimator_linear

log close



//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
// Compare to Leontieff Version
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------

cd ..
cd simulation_asi_inputs_oct2014_leontieff
// Generator 

global graphit=1
global p_e_s=7
global filename="ASI_Prediction2005_7.csv"
clear
insheet using $filename


g kshare_Y=fcapclose/grsale_defl
               * trim outliers
               replace kshare_Y = . if kshare_Y>20 //

cap drop if $droplist
//noisily des
foreach x of varlist year-y_no_generator {
destring `x', replace force
} 

//---------------------------------------------------------------------------------------
// 0) Prep Work
//---------------------------------------------------------------------------------------

cap destring e_grid_no_generator, replace force
cap destring e_grid_generator, replace force


sum delta_psp, meanonly
scalar shortage=r(mean)

drop if messedupcompute==-2

//---------------------------------------------------------------------------------------
// 1) Dollar Per Megawatt to make indifference between generator and no-generator
//---------------------------------------------------------------------------------------
replace e_self_shortage=e_self_shortage/$p_e_s
replace e_self_no_shortage=e_self_no_shortage/$p_e_s

replace e_grid_shortage=e_grid_shortage/$p_e_g
replace e_grid_no_shortage=e_grid_no_shortage/$p_e_g

gen total_power=e_self_shortage + e_grid_shortage

// Size of Required Generator
gen gen_size= total_power/($hours_prod)


//---------------------------------------------------------------------------------------
// 1.5) Profits of a Generator, Cost of These
//---------------------------------------------------------------------------------------
gen profit_no_shortage=y_no_shortage-p_m * m_no_shortage -p_l *  l_no_shortage-$p_e_g* e_grid_no_shortage-$p_e_s* e_self_no_shortage
gen profit_shortage=y_shortage-p_m* m_shortage-p_l* l_shortage-$p_e_g* e_grid_shortage-$p_e_s* e_self_shortage

gen has_gen=(zero_generation_flag==1)


gen log_gen_size=log(gen_size)
reg zero_generation_flag log_gen_size 

gen log_k=log(k)
mata: LOG_K=st_data(.,("log_k"))
mata: LOG_G=st_data(.,("log_gen_size"))


// Show these
mata: GENERATOR=st_data(.,("has_gen"))
mata: cov_data_k=variance((GENERATOR,LOG_K))
mata: cov_data_k[2,1]
mata: cov_data_g=variance((GENERATOR,LOG_G))
mata: cov_data_g[2,1]
mata: mean(GENERATOR)



log using estimate_cost_gens_results.log, append

disp("Leontieff Version")

bootstrap , reps(50) seed(12345): gen_cost_estimator

bootstrap , reps(50) seed(12345): gen_cost_estimator_linear

log close


matrix cost_linear=e(b),1

// Generator versus other components
gen generator_cost1=exp(cost_not_linear[1,1])*gen_size^cost_not_linear[1,2]

// New way to do it
gen buy_generator1=(profit_generator-profit_no_generator)>generator_cost1

sum buy_generator1

// Generator versus other components
gen generator_cost2=exp(cost_linear[1,1])*gen_size

// New way to do it
gen buy_generator2=(profit_generator-profit_no_generator)>generator_cost2


lpoly buy_generator2 log_gen_size if log_gen_size>0 & log_gen_size<20

lpoly buy_generator1 log_gen_size if log_gen_size>0 & log_gen_size<20

lpoly has_gen log_gen_size if log_gen_size>0 & log_gen_size<20

