/*

Little Program for looking at Elasticities 

Allan Collard-Wexler
August 6 2015

*/

clear
set more off 
global epsilon=0.001

capture cd simulation_asi_inputs_dec2014

* File where we increase delta by epsilon (add it)
insheet using ASI_Prediction_elast.csv

gen self_share=e_self_shortage/(e_self_shortage+e_grid_shortage)
gen self_share_prime=e_self_shortage_prime/(e_self_shortage_prime+e_grid_shortage_prime)

// Make Logged Variables

gen ly_s=log(y_shortage)
gen ly_sp=log(y_shortage_prime)

gen lm_s=log(m_shortage)
gen lm_sp=log(m_shortage_prime)


gen ll_s=log(l_shortage)
gen ll_sp=log(l_shortage_prime)

gen le_s=log(e_self_shortage+e_grid_shortage)
gen le_sp=log(e_self_shortage_prime+e_grid_shortage_prime)
gen lk=log(k)

// Adjust Prod Function Parameters
gen prod_sp=ly_sp-alpha_l*ll_sp-alpha_m*lm_sp-alpha_k*k-alpha_e*le_sp
gen prod_s=ly_s-alpha_l*ll_s-alpha_m*lm_s-alpha_k*k-alpha_e*le_s
gen diff_tfp=(prod_s-prod_sp)/$epsilon

gen output_elast=(y_shortage-y_shortage_prime)/(y_shortage*$epsilon)
gen material_elast=(m_shortage-m_shortage_prime)/(m_shortage*$epsilon)
gen labor_elast=(l_shortage-l_shortage_prime)/(l_shortage*$epsilon)
gen self_gen_share_elast=(self_share-self_share_prime)/($epsilon)

capture log close
cd ..
log using elast_results.log
sum output_elast material_elast labor_elast self_gen_share_elast diff_tfp [aweight=mult]
log close


