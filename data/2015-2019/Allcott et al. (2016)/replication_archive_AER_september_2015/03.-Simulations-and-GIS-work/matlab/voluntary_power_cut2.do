/* 

Code for looking at analysis of ASI
Voluntary Reduction Contracts

Allan Collard-Wexler
First Version: March 21 2014
Current Version: 


*/


clear
set more off
set mem 500m
set linesize 200

//cap cd ~/Dropbox/India_Power_Shortages/matlab/
//cap cd "C:\Users\Hunt\Dropbox\India Power Shortages\matlab"

quietly do asi_predictions_analysis5.do


// Cost of a Generator (in per year rental per KW in Rupees)
// 
// Numbers for Generator Costs
	// From Prices Data (gen_returns_to_scale1.do) Note: 0.80 Power
	// Conversion factor from KVA to KW Note: Rupee to US Dollar
	// Exchange Rate: 50 to 1. Note: Discount Rate leads to 10 to 1
	// relationship between rental cost and purchase price of generator.
	global sigma_0_a=5.357671+ln(50/(10*0.8)) 
	global sigma_1_a=1

	global sigma_0_b=6.499042+ln(50/(10*0.8)) 
	global sigma_1_b=0.7919834

	// From Estimation on Generator Use (estimate_cost_generators2)
	/*
	/
Bootstrap results                               Number of obs      =     33871
                                                Replications       =        50

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    sigma_0, |   10.67198   .1862945    57.29   0.000     10.30684    11.03711
     sigma_1 |   .8286772   .0065594   126.33   0.000      .815821    .8415334
------------------------------------------------------------------------------
Bootstrap results                               Number of obs      =    
33829 Replications       =        50

Bootstrap results                               Number of obs      =     33871
                                                Replications       =        50

------------------------------------------------------------------------------
             |   Observed   Bootstrap                         Normal-based
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     sigma_0 |   9.918365   .0230766   429.80   0.000     9.873136    9.963595
------------------------------------------------------------------------------

	*/

	global sigma_0_c=9.918365 
	global sigma_1_c=1

	global sigma_0_d=10.67198 
	global sigma_1_d=0.8286772


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

// 0) Full Base 

// Generator 

global sigma_0=$sigma_0_d
global sigma_1=$sigma_1_d
// Reduction in Total Power Consumption
global reduction=0.071

// Curtailment level: 14 % or one day a week 
global curtailement=0.14

cd simulation_asi_inputs_dec2014

// 0) Full Base 

// Generator 

global graphit=1
// Shortages 14%
global filename="ASI_Prediction14pct.csv"
// Hunt look into this function. 
asi_predictions_analysis5
matrix bigmatprice=e(b)
matrix base=e(b)

// Drop a plant with 100 times more power than anyone else
drop if panelgroup==121040


// Figure out at what price per MW I would be indifferent.
gen profitloss_per_mw=profit_diff_shortage/e_grid_no_shortage
drop if profitloss_per_mw==.


// Target to reach 7.1 percent drop
egen POWER_SUM=total(qeleccons)
gen reduced_POWER_SUM=POWER_SUM*(1-$reduction)

// Reduction per plant if curtailed
gen curtailed_power_percent=1+(e_grid_shortage-e_grid_no_shortage)/e_grid_no_shortage
gen curtailed_qeleccons= curtailed_power_percent*qeleccons

// Sort Plants by their loss
gsort + profitloss_per_mw

// Running Sum
gen not_curtailed_power_sum=sum(qeleccons)


// Sort Plants by their loss
gsort - profitloss_per_mw

// Running Sum
gen curtailed_power_sum=sum(curtailed_qeleccons)

gen test=sum(qeleccons)

gen economy_power= curtailed_power_sum+ not_curtailed_power_sum

gen obsnums=_n

line economy_power obsnums

gen curtailed=(economy_power <reduced_POWER_SUM)

tab curtailed
sum obsnum if curtailed
scalar pivotal=r(min)

// Results
gen curt_pctshortage=pctshortage*curtailed
gen curt_diff_tfp = diff_tfp*curtailed
gen curt_profit_diff_shortage = profit_diff_shortage*curtailed


log using Results_Curtailment.log, replace
sum curtailed
sum obsnum if curtailed

sum curtailed if zero==1
sum curtailed if zero==0

// Sum up profits from curtailment
sum pctshortage diff_tfp  profit_diff_shortage if curtailed

sum curt_pctshortage curt_diff_tfp curt_profit_diff_shortage 
sum curt_pctshortage curt_diff_tfp curt_profit_diff_shortage  if zero==1
sum curt_pctshortage curt_diff_tfp curt_profit_diff_shortage  if zero==0


/*contract to clear the market. Under this counterfactual policy, revenue,
TFPR, and variable profit losses average only tk, tk, and tk percent,
respectively. These losses are much smaller than the 4.6, 1.6, and 6.8
percent reported in Column 1 of Table [table.model.vs.iv].*/

log close




