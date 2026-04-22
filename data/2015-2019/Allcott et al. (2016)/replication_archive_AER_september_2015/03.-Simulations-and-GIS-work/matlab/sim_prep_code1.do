/* 

Stata Code to process ASCII Files for Matlab 

Allan Collard-Wexler
First Version: Jan 3 2013

files provided by Stephen OC
*/

clear
set more off

local export_list="year delta_psp delta_pdpm k alpha_m alpha_l alpha_k alpha_e omega zero_selfgen_flag p p_m p_l  panelgroup scheme_dummy grsale_defl   totpersons    qeleccons fcapclose matls_defl any snic_hc exog_gen_industry mult"

cd simulation_asi_inputs_dec2014

//--------------------------------------------------------------------------------------
// Yearly Data.
forval x=1992/2010 {
clear
insheet using ASIpanelfields_forsimulation_`x'.csv

drop if omega==. 
drop if k==. 

/*%  Columns 1 through 8
%    'year'    'delta_PSP'    'delta_PDPM'    'K'    'alpha_m'    'alpha_l'    'alpha_K'
%  Columns 9 through 16
%    'OMEGA'    'gamma'    'gamma_g'    'gamma_s' zero_selfgen_flag   'p'    'p_m'    'p_l'*/

egen state_num=group(state)
gen scheme_dummy=(scheme_final=="Census")

rename exog_gen_industry exog_ind
gen exog_gen_industry=0
replace exog_gen_industry=1 if exog_ind=="chemicals"
replace exog_gen_industry=2 if exog_ind=="petroleum&petroleum_products"
replace exog_gen_industry=3 if exog_ind=="pulp&paper"
replace exog_gen_industry=4 if exog_ind=="sugar"

drop exog_ind


// Replace negative values
replace delta_psp=0.000001 if delta_psp<0
replace delta_pdpm=0.000001 if delta_pdpm<0


gen sum_alpha=alpha_e+alpha_m+alpha_l

// Material, Capital, Electricity, Labor Components set to mean if too big.
replace alpha_l=0.07 if sum_alpha>0.94
replace alpha_k=0.14 if sum_alpha>0.94
replace alpha_m=0.71 if sum_alpha>0.94
replace alpha_e=0.02 if sum_alpha>0.94


outsheet `export_list' using  ASIpanelfields_forsimulation_`x'_edit.csv, replace

}


//--------------------------------------------------------------------------------------
// Do a few other checks 
clear
insheet using ASIpanelfields_forsimulation_2005.csv

egen state_num=group(state)
gen scheme_dummy=(scheme_final=="Census")

rename exog_gen_industry exog_ind
gen exog_gen_industry=0
replace exog_gen_industry=1 if exog_ind=="chemicals"
replace exog_gen_industry=2 if exog_ind=="petroleum&petroleum_products"
replace exog_gen_industry=3 if exog_ind=="pulp&paper"
replace exog_gen_industry=4 if exog_ind=="sugar"

drop exog_ind


// Replace negative values
replace delta_psp=0.000001 if delta_psp<0
replace delta_pdpm=0.000001 if delta_pdpm<0

// Material, Capital, Labor Components
replace alpha_l=0.07 if alpha_m>0.89
replace alpha_k=0.08 if alpha_m>0.89
replace alpha_m=0.85 if alpha_m>0.89
replace alpha_e=0.05 if alpha_m>0.89


// Halve Shortages
replace delta_psp=0.5*delta_psp
replace delta_pdpm=0.5*delta_pdpm

outsheet `export_list' using  ASIpanelfields_halve.csv, replace



// 3% , 7%, 20% 
replace delta_psp=0.03
replace delta_pdpm=0.03

outsheet `export_list' using  ASIpanelfields_3pct.csv, replace

replace delta_psp=0.07
replace delta_pdpm=0.07

outsheet `export_list' using  ASIpanelfields_7pct.csv, replace

replace delta_psp=0.14
replace delta_pdpm=0.14

outsheet `export_list' using  ASIpanelfields_14pct.csv, replace

replace delta_psp=0.20
replace delta_pdpm=0.20

outsheet `export_list' using  ASIpanelfields_20pct.csv, replace

replace delta_psp=0.001
replace delta_pdpm=0.001

outsheet `export_list' using  ASIpanelfields_0pct.csv, replace

replace delta_psp=0.1
replace delta_pdpm=0.1

outsheet `export_list' using  ASIpanelfields_10pct.csv, replace


replace delta_psp=0.05
replace delta_pdpm=0.05

outsheet `export_list' using  ASIpanelfields_5pct.csv, replace

replace delta_psp=0.15
replace delta_pdpm=0.15

outsheet `export_list' using  ASIpanelfields_15pct.csv, replace

replace delta_psp=0.20
replace delta_pdpm=0.20

outsheet `export_list' using  ASIpanelfields_20pct.csv, replace


disp('All Done')