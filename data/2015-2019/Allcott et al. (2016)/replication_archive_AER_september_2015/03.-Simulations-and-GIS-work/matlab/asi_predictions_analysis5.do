/*

Program to Analyze ASI Based Simulation

look at asi_simulation4.m for details

Allan Collard-Wexler

September 24 2014

*/



capture program drop asi_predictions_analysis5
program define asi_predictions_analysis5, eclass
quietly {

//---------------------------------------------------------------------------------------
// 0) Prep Work
//---------------------------------------------------------------------------------------
clear
insheet using $filename

cap drop if $droplist
//noisily des
foreach x of varlist year-e_grid_generator {
destring `x', replace force
} 


sum delta_psp, meanonly
scalar shortage=r(mean)


// Make Logged Variables

gen ly_s=log(y_shortage)
gen ly_ns=log(y_no_shortage)

gen lm_s=log(m_shortage)
gen lm_ns=log(m_no_shortage)


gen ll_s=log(l_shortage)
gen ll_ns=log(l_no_shortage)

gen le_s=log(e_self_shortage+e_grid_shortage)
gen le_ns=log(e_grid_no_shortage)

gen lk=log(k)

// Adjust Prod Function Parameters
// Hack for leontieff version
cap gen alpha_e=0
gen prod_nos=ly_ns-alpha_l*ll_ns-alpha_m*lm_ns-alpha_k*k-alpha_e*le_ns
gen prod_s=ly_s-alpha_l*ll_s-alpha_m*lm_s-alpha_k*k-alpha_e*le_s
gen diff_tfp=100*(prod_nos-prod_s)

// Tables 

sum diff_tfp, meanonly
scalar diff_tfp=r(mean)
sum diff_tfp if zero_generation==0, meanonly
scalar diff_tfp_gen=r(mean)
sum diff_tfp if zero_generation==1, meanonly
scalar diff_tfp_nogen=r(mean)

sum pctshortage, meanonly
scalar output_loss=r(mean)

gen tot_no_shortage=sum(y_no_shortage)
gen tot_shortage=sum(y_no_shortage)

sum pctshortage [aw=grsale_defl], meanonly   
scalar output_loss_weighted=r(mean)



sum pctshortage if zero_generation==0, meanonly
scalar output_loss_gen=r(mean)

sum pctshortage if zero_generation==1, meanonly
scalar output_loss_nogen=r(mean)


replace e_self_shortage=e_self_shortage/$p_e_s
replace e_self_no_shortage=e_self_no_shortage/$p_e_s

replace e_grid_shortage=e_grid_shortage/$p_e_g
replace e_grid_no_shortage=e_grid_no_shortage/$p_e_g

noisily tab messedupcompute
drop if messedupcompute==-2

gen pct_change_mat=100*(m_no_shortage-m_shortage)/m_no_shortage
sum pct_change_mat, meanonly
scalar mat_loss=r(mean)

gen pct_self_gen=100*(e_self_shortage)/(e_self_shortage+e_grid_shortage)
replace pct_self_gen=. if pct_self_gen==0
sum pct_self_gen, meanonly
scalar self_gen_share=r(mean)







// Average Price for Power
// gen average_p_power=

gen k_bin=floor(k)

replace k_bin=13 if k_bin<13
replace k_bin=20 if k_bin>20

//---------------------------------------------------------------------------------------
// 1) Dollar Per Megawatt to make indifference between generator and no-generator
//---------------------------------------------------------------------------------------

gen profitpermwfromgenerator= (profit_generator -profit_no_generator)/(e_self_shortage + e_grid_shortage)

gen total_power=e_self_shortage + e_grid_shortage
sum total_power, detail


gen profit_percent_generator=100*(profit_generator -profit_no_generator)/profit_generator 
sum profit_percent_generator, detail
scalar profit_gens=r(p50)

// Size of Required Generator
gen gen_size= total_power/($hours_prod)
//gen gen_size= total_power/($hours_prod*delta_psp)

// Break Even cost of generators.
gen break_even_gen_cost= profitpermwfromgenerator*($hours_prod)

sum break_even_gen_cost, detail
scalar break_even_cost=r(p50)

tabstat break_even_gen_cost , by(k_bin) stat(p50 N)
bysort zero_generation_flag: sum break_even_gen_cost, detail
/*
1000 kW. $173k
500 kW $81k
60 kW $16k
It should be $.160 per watt for a big one, and maybe $0.250 per watt for a small one.
 */
// Look at fraction of plants that would purchase a generator.

//---------------------------------------------------------------------------------------
// 1.5) Profits of a Generator, Cost of These
//---------------------------------------------------------------------------------------
gen profit_no_shortage=y_no_shortage-p_m * m_no_shortage -p_l *  l_no_shortage-$p_e_g* e_grid_no_shortage
gen profit_shortage=y_shortage-p_m* m_shortage-p_l* l_shortage-$p_e_g* e_grid_shortage-$p_e_s* e_self_shortage


gen profit_diff_shortage=100*(profit_no_shortage-profit_shortage)/profit_no_shortage
sum profit_diff_shortage, meanonly
scalar profit_diff_shortage=r(mean)

sum profit_diff_shortage if zero_generation==0, meanonly
scalar profit_loss_gens=r(mean)

sum profit_diff_shortage if zero_generation==1, meanonly
scalar profit_loss_no_gens=r(mean)


// Generator versus other components
gen generator_cost=exp($sigma_0)*(gen_size^$sigma_1)

// Old Stuff
gen gen_profit_increase=100*(profit_generator-profit_no_generator)/profit_shortage
// New way to do it
gen buy_generator=(profit_generator-profit_no_generator)>generator_cost

sum buy_generator
scalar buy_generator=r(mean)
scalar buy_generator2=r(mean)


gen buy_generator_prime=(profit_generator-profit_no_generator)>(1.10*generator_cost)
sum buy_generator_prime
scalar buy_generator_prime2=r(mean)

// Weighted Average
sum  buy_generator, meanonly
scalar buy_generator_weighted=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar buy_generator_weighted=-99
}

// Covariance Gen Size and Buy Generator

// Size of Required Generator
gen log_gen_size=log(gen_size)

corr buy_generator log_gen_size, covariance
matrix A=r(C)
scalar covariance_gen_size=A[2,1]

scalar gen_elasticity=(buy_generator_prime2-buy_generator2)*10

gen lprofit_change=log((profit_generator -profit_no_generator))


//---------------------------------------------------------------------------------------
// 2) Size Distribution from Shortages versus no-shortages
//---------------------------------------------------------------------------------------

gen ratio_gen_cost_to_profit_exo=100*generator_cost/profit_shortage  if zero_generation==0
replace ratio_gen_cost_to_profit_exo=0 if zero_generation==1
//noisily sum ratio_gen_cost_to_profit_exo, detail

gen ratio_gen_cost_to_profit_endo=100*generator_cost/profit_shortage  if buy_generator==1
replace ratio_gen_cost_to_profit_endo=0 if buy_generator==0
//noisily sum ratio_gen_cost_to_profit_endo, detail



//---------------------------------------------------------------------------------------
// 3) Elasticity
//---------------------------------------------------------------------------------------

gen elasticity=100*(y_no_shortage_prime-y_no_shortage)/y_no_shortage

sum elasticity, meanonly
scalar elasticity=r(mean)

count
scalar theobs=`r(N)'

//---------------------------------------------------------------------------------------
// 4) Total Production: Endogenous generator Adoption
//---------------------------------------------------------------------------------------

gen y_endo=y_generator 
replace y_endo=y_no_generator if buy_generator==0
egen total_prod=mean(y_endo)
sum total_prod, meanonly
scalar production=r(mean)

gen e_grid_endogenous=e_grid_generator
replace e_grid_endogenous=e_grid_no_generator if buy_generator==0
egen total_grid=mean(e_grid_endogenous)
sum total_grid, meanonly
scalar grid_power=r(mean)

gen diff_endo=100*(y_no_shortage-y_endo)/y_no_shortage
sum diff_endo, meanonly
scalar diff_endo=r(mean)

sum diff_endo if buy_generator==0, meanonly
scalar diff_endo_no_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar diff_endo_no_gen=-99
}


sum diff_endo if buy_generator==1, meanonly
scalar diff_endo_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar diff_endo_gen=-99
}

// Productivity Loss endogenous generators
gen tfp_endo=100*diff_tfp_no_generator if (buy_generator==0)
replace tfp_endo=100*diff_tfp_generator if (buy_generator==1)
sum tfp_endo, meanonly
scalar tfp_endo=r(mean)


sum tfp_endo if buy_generator==0, meanonly
scalar tfp_endo_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar tfp_endo_gen=-99
}
sum tfp_endo if buy_generator==1, meanonly
scalar tfp_endo_no_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar tfp_endo_no_gen=-99
}

// Profit Loss Endogenous Generators
gen pdiff_endo=100*(profit_no_shortage-profit_generator)/profit_no_shortage
replace pdiff_endo=100*(profit_no_shortage-profit_no_generator)/profit_no_shortage  if (buy_generator==0)
sum pdiff_endo, meanonly
scalar profit_endo=r(mean)


sum pdiff_endo if buy_generator==0, meanonly
scalar profit_endo_no_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar profit_endo_no_gen=-99
}


sum pdiff_endo if buy_generator==1, meanonly
scalar profit_endo_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar profit_endo_gen=-99
}

gen profit_diff_short_nobody_gen=100*(profit_no_shortage-profit_no_generator)/profit_no_shortage
sum profit_diff_short_nobody_gen, meanonly
scalar profit_diff_short_nobody_gen=r(mean)



// input cost effect
gen input_cost=100*delta_psp*(($p_e_s-$p_e_g))*alpha_e
sum input_cost if zero_generation==0, meanonly
scalar input_cost_exo=r(mean)

sum input_cost if buy_generator==1, meanonly
scalar input_cost_endo=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar input_cost_endo=-99
}


// Post it
sum profit_diff_shortage, meanonly
scalar ratio_pdiff_exo=r(mean)

sum pdiff_endo, meanonly
scalar ratio_pdiff_endo=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar ratio_pdiff_endo=-99
}

// Generator Stuff
sum ratio_gen_cost_to_profit_exo  if ratio_gen_cost_to_profit_exo<90, meanonly
scalar r_gen_cost_to_profit_exo=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar r_gen_cost_to_profit_exo=-99
}

sum ratio_gen_cost_to_profit_exo if zero_generation==0, meanonly
scalar r_gen_cost_to_profit_exo_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar r_gen_cost_to_profit_exo_gen=-99
}

sum ratio_gen_cost_to_profit_endo  if ratio_gen_cost_to_profit_endo<90, meanonly
scalar r_gen_cost_to_profit_endo=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar r_gen_cost_to_profit_endo=-99
}

sum ratio_gen_cost_to_profit_endo  if ratio_gen_cost_to_profit_endo<90 & buy_generator==1, meanonly
scalar r_gen_cost_to_profit_endo_gen=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar r_gen_cost_to_profit_endo_gen=-99
}


//

//---------------------------------------------------------------------------------------
// 5) Producer Surplus Table 
//---------------------------------------------------------------------------------------

gen self_gen_share=e_self_shortage/(e_self_shortage+e_grid_shortage)
cap gen diff_input_cost_electricity=100*alpha_e*[($p_e_s*self_gen_share+$p_e_g*(1-self_gen_share))/$p_e_g-1]
sum diff_input_cost_electricity if ratio_gen_cost_to_profit_exo<90
scalar diff_input_cost_elec=r(mean)
local flag=r(mean)
if  `flag'==. {
scalar diff_input_cost_elec=-99
}


//---------------------------------------------------------------------------------------
// 6) Post it
//---------------------------------------------------------------------------------------


sum year
scalar years=`r(mean)'

scalar p_grid=$p_e_g
scalar p_self=$p_e_s


scalar gen_costs=r(sum)



matrix bigmat= years, p_grid, p_self, shortage, output_loss, output_loss_weighted ,output_loss_gen, output_loss_nogen , diff_tfp, diff_tfp_nogen, diff_tfp_gen, profit_diff_shortage, profit_loss_no_gens, profit_loss_gens, profit_gens, profit_diff_short_nobody_gen, break_even_cost, buy_generator, gen_elasticity, theobs, production, grid_power, diff_endo, diff_endo_no_gen, diff_endo_gen, tfp_endo, tfp_endo_gen, tfp_endo_no_gen, profit_endo, profit_endo_gen, profit_endo_no_gen, input_cost_endo, input_cost_exo, r_gen_cost_to_profit_exo, r_gen_cost_to_profit_endo, mat_loss, self_gen_share, diff_input_cost_elec,r_gen_cost_to_profit_exo_gen, r_gen_cost_to_profit_endo_gen, buy_generator_weighted, covariance_gen_size

matrix colnames bigmat= year p_e_grid p_e_self shortage output_loss output_loss_weighted  output_loss_gen output_loss_nogen diff_tfp diff_tfp_nogen diff_tfp_gen profit_diff_shortage profit_loss_no_gens profit_loss_gens  profit_percent_generator  profit_diff_short_nobody_gen break_even_cost buy_generator gen_elasticity observations production grid_power diff_endo dendo_no_gen dendo_gen tfp_endo tfp_endo_gen tfp_endo_no_gen profit_endo, profit_endo_gen, profit_endo_no_gen  input_cost_endo input_cost_exo r_gen_cost_to_profit_exo, r_gen_cost_to_profit_endo mat_loss self_gen_share diff_input_cost_elec r_gen_cost_to_profit_exo_gen  r_gen_cost_to_profit_endo_gen buy_generator_weighted covariance_gen_size

gen profit_loss_if_no_gens=100*(profit_no_shortage-profit_no_generator)/profit_no_generator

gen profit_loss_endogeneous=100*(profit_no_shortage-profit_no_generator)/profit_no_generator
replace  profit_loss_endogeneous=100*(profit_no_shortage-profit_generator)/profit_generator if buy_generator
gen ltotperson=log10(totpersons)
label variable ltotperson "log10(Number of Employees)" 
label variable profit_diff_shortage "Percent Profit Loss due to Shortages" 
label variable profit_loss_if_no_gens "Percent Profit Loss if No Plants have Generators" 
label variable profit_loss_endogeneous "Percent Profit Loss with Endogenous Plant Adoption of Generators" 

gen lcapital=log(k)
label variable lcapital "Log Capital Stock in Rupees" 

// Hunt Take a look at this section. tk
if $graphit {
 
 
}

}

disp "$filename"

matrix list bigmat
ereturn post bigmat 
end
