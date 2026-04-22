/*

Allan Collard-Wexler
July 1 2014
Project: Indian Power Generation, Post AER 

Program to look at Returns to Scale for Cost of Power Generation

*/

global details=0

cd ~/Dropbox/India_Power_Shortages/matlab/

clear 


// Data file from 
// (http://www.americasgenerators.com/Diesel-Generators-Americas-Generators.aspx)
// See email from Hunt Allcott referring to it.
use AMGen_prices.dta


set scheme lean2 
scatter price capacity

capture graph export generator_scale_economies.pdf, replace

gen lcapacity=ln(capacity)
gen lprice=ln(price)

gen lprice_per=log(price/capacity)

scatter lprice lcapacity

log using generator_returns_to_scale1.log, replace
sum lprice_per
reg lprice lcapacity

reg lprice lcapacity, cluster(brand)
estimates store gen_costs
matrix gen_cost_parms=e(b)


// Robustness checks
qreg lprice lcapacity

xi: reg lprice lcapacity i.brand i.epa
xi: reg lprice lcapacity i.brand i.epa, cluster(brand)

log close



// Export Estimates.
//outsheet sigma_0_linear_genprice sigma_0_genprice sigma_1_genprice in 1, using gen_price_estimates.csv replace

// Convert Estimates
global interest_rate=0.30 // From Banerjee Duflo 2014
global power_factor=0.8 // Engineering Specs 
global rupee_dollar_exchange_rate=50 // 2014 Exchange Rate
global gen_life=10 // Ten year lifespan of a generator



gen rental_lprice=lprice+log(1/(1-($interest_rate+1/$gen_life)))+log($rupee_dollar_exchange_rate)+log(1/$power_factor)

gen rental_lprice_per=rental_lprice-lcapacity



log using generator_returns_to_scale1.log, append

display("Now Using Rental Prices in Rupees")


sum rental_lprice_per
reg rental_lprice lcapacity, cluster(brand)
estimates store gen_costs
matrix gen_cost_parms=e(b)

// Robustness checks
qreg rental_lprice lcapacity

xi: reg rental_lprice lcapacity i.brand i.epa
xi: reg rental_lprice lcapacity i.brand i.epa, cluster(brand)

log close











disp("end")
