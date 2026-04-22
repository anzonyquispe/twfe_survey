/* 
/
Code for looking at analysis of ASI

Allan Collard-Wexler First Version: May 4 2013 Current Version: November
4 2014

POST AER RR Version: Cobb Douglas Switch

*/

capture cd "C:\Users\Hunt\Dropbox\India Power Shortages\matlab"
capture cd ~/Dropbox/India_Power_Shortages/matlab


clear 
set more off 
set mem 500m 
*set linesize 200


* Weighted Version
quietly do asi_predictions_analysis6.do

* UnWeighted Version
quietly do asi_predictions_analysis5.do



// Cost of a Generator (in per year rental per KW in Rupees)
// 
// Numbers for Generator Costs
	// From Prices Data (gen_returns_to_scale1.do)
	/*
	. sum rental_lprice_per

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
rental_lpr~r |       223    10.00366    .4139228   9.364491    11.3553

. reg rental_lprice lcapacity, cluster(brand)

Linear regression                                      Number of obs =     223
                                                       F(  1,     7) =  243.09
                                                       Prob > F      =  0.0000
                                                       R-squared     =  0.9314
                                                       Root MSE      =  .29808

                                  (Std. Err. adjusted for 8 clusters in brand)
------------------------------------------------------------------------------
             |               Robust
rental_lpr~e |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
   lcapacity |   .7919832    .050796    15.59   0.000     .6718698    .9120967
       _cons |   11.14503   .2532105    44.01   0.000     10.54629    11.74378
------------------------------------------------------------------------------
*/
	
	
	global sigma_0_a=10.00366
	global sigma_1_a=1

	global sigma_0_b=11.14503
	global sigma_1_b=.7919832

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

global graphit=0

cd simulation_asi_inputs_dec2014

// 0) Full Base 

// Generator 

global graphit=1
global p_e_s=7
global sigma_0=$sigma_0_d
global sigma_1=$sigma_1_d

// --------------------------------------------------------------------------------
global filename="ASI_Prediction2005_7.csv"
// Hunt look into this function. 
asi_predictions_analysis6

matrix bigmatprice=e(b)
matrix base=e(b)
matrix bigmatbase=e(b)

sum delta*, detail

/*gen change_materials=ln(m_shortage)-ln(m_no_shortage)
gen change_labor=ln(l_shortage)-ln(l_no_shortage)
gen change_output=ln(y_shortage)-ln(y_no_shortage)


reg change_materials delta_psp
reg change_materials delta_psp if (zero_generation_flag==1)
reg change_materials delta_psp if (zero_generation_flag==0)

reg change_labor delta_psp
reg change_labor delta_psp if (zero_generation_flag==1)
reg change_labor delta_psp if (zero_generation_flag==0)


gen tfp_no_shortage=ln(y_no_shortage)-alpha_m*ln(m_no_shortage)-alpha_l*ln(l_no_shortage)-alpha_e*ln(e_grid_no_shortage+e_self_no_shortage)-alpha_k*ln(k)


gen tfp_shortage=ln(y_shortage)-alpha_m*ln(m_shortage)-alpha_l*ln(l_shortage)-alpha_e*ln(e_grid_shortage+e_self_shortage)-alpha_k*ln(k)

cap drop diff_tfp
gen diff_tfp=tfp_shortage-tfp_no_shortage

reg diff_tfp delta_psp

*/

global graphit=1

cd ..

// Hunt: Graphs tk
cap drop lcapital
gen lcapital=log10(k)


// Original Graph
lpoly profit_diff_shortage  ltotperson if ltotperson<=4, ///
	degree(0) noscatter   bwidth(0.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium)) 
	

cap graph export "ShortageEffectsbyPlantSize.pdf", as(pdf) replace


// Now with Capital 
lpoly profit_diff_shortage    lcapital if lcapital>5 & lcapital<8.5, ///
	degree(0) noscatter   bwidth(1.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))
	
cap graph export "ShortageEffectsbyCapitalSize.pdf", as(pdf) replace
	
lpoly profit_loss_if_no_gens    lcapital if lcapital>5 & lcapital<9, generate(x_lcapital y_profit_loss_no_gen) degree(0) noscatter   bwidth(1.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))	

lpoly profit_diff_shortage    lcapital if lcapital>5 & lcapital<9, generate(x_lcapital2 y_profit_loss) degree(0) noscatter   bwidth(1.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))	 

label variable y_profit_loss "Profit Loss due to shortages"
label variable y_profit_loss_no_gen "Profit Loss due to shortages -- no firms have generators"
label variable x_lcapital "Log Capital"
label variable x_lcapital2 "Log Capital"


*set scheme lean2
line y_profit_loss_no_gen x_lcapital, lcolor("blue") || line y_profit_loss x_lcapital, lcolor("red") legend(size(medlarge) pos(6)) title(Simulated Effects of Shortages by Plant Size) ytitle("Percent Profit Loss") 
cap graph export "ShortageEffectsbyPlantSize_Capital.pdf", as(pdf) replace


// Employment as x variable
lpoly profit_loss_if_no_gens ltotperson if ltotperson>=0 & ltotperson<=4, generate(x_ltot y_profit_loss_no_gen_tot) degree(0) noscatter   bwidth(0.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))	

lpoly profit_diff_shortage ltotperson if ltotperson>=0 & ltotperson<=4, generate(x_ltot2 y_profit_loss_tot2) degree(0) noscatter   bwidth(0.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))	

label variable y_profit_loss_tot2 "Profit loss"
label variable y_profit_loss_no_gen_tot "Profit loss if no generators"
label variable x_ltot "log10(Number of Employees)"
label variable x_ltot2 "log10(Number of Employees)"

*set scheme lean2
twoway (line y_profit_loss_tot2 x_ltot2, lcolor(black) lwidth(medthick)) ///
	(line y_profit_loss_no_gen_tot x_ltot, lcolor(blue) lp(_) lwidth(medthick)),  ///
	graphregion(color(white) lwidth(medium))  /// title(Simulated Effects of Shortages by Plant Size) 
	ytitle("Percent Profit Loss")  xsc(r(0)) legend(size(medlarge) pos(6)  region(lstyle(thick)))
cap	graph save "$analyses/ProfitLossandSize", replace
	
cap graph export "ShortageEffectsbyPlantSize_TEmp.pdf", as(pdf) replace

/*graph combine "$analyses/ElecProducerandSize" "$analyses/ProfitLossandSize", ///
	graphregion(color(white)) // title("Associations with State Average Shortage")
graph export "$analyses/PlantSize.pdf", as(pdf) replace
*/

lpoly profit_diff_shortage  ltotperson if ltotperson<=4, ///
	degree(0) noscatter   bwidth(0.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium)) 



// New Endogenous Graph
lpoly profit_loss_endogeneous  lcapital if lcapital>5 & lcapital<9, ///
	degree(0) noscatter   bwidth(1.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))
	

cap graph export "ShortageEffectsbyPlantSize_endogenous_irs.pdf", as(pdf) replace


// Graph of Predicted and Actual Generator Uptake
lpoly buy_generator ltotperson if ltotperson>=1 & ltotperson<=4, generate(x_ltot3 y_gen_predicted_uptake) degree(0) noscatter   bwidth(0.5)  lineopts(lwidth(thick)) ///
	title(Simulated Generator Uptake by Plant Size) ///
	graphregion(color(white) lwidth(medium))	


lpoly zero_generation_flag  ltotperson if ltotperson>=1 & ltotperson<=4, generate(x_ltot4 y_gen_data_uptake) degree(0) noscatter   bwidth(0.5)  lineopts(lwidth(thick)) ///
	title(Generator Uptake by Plant Size) ///
	graphregion(color(white) lwidth(medium))	

	
	
label variable y_gen_data_uptake "Data Generator Uptake"
label variable y_gen_predicted_uptake "Predicted Generator Uptake"
label variable x_ltot3 "log10(Number of Employees)"
label variable x_ltot4 "log10(Number of Employees)"

	

twoway (line y_gen_predicted_uptake x_ltot3, lcolor(black) lwidth(medthick)) ///
	(line y_gen_data_uptake x_ltot4, lcolor(blue) lp(_) lwidth(medthick)),  ///
	graphregion(color(white) lwidth(medium))  /// title(Simulated Effects of Shortages by Plant Size) 
	ytitle("Percent Generator Uptake")  
	
cap graph export Predicted_Actual_Gen_Uptake.pdf, replace


cd simulation_asi_inputs_dec2014

// 1) Base

global graphit=0

// Endogenous Generator Adoption
// Shortages 3%
global filename="ASI_Prediction3Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=base\e(b)

// Shortages 5%
global filename="ASI_Prediction5Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=alternative_shortage\e(b) 

// Shortages 7%
global filename="ASI_Prediction7Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=alternative_shortage\e(b)

// Shortages 10%
global filename="ASI_Prediction10Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=alternative_shortage\e(b)



// Shortages 20%
global filename="ASI_Prediction20Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=alternative_shortage\e(b)

// Shortages 0%
global filename="ASI_Prediction0Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=alternative_shortage\e(b)

// Shortages halved
global filename="ASI_Prediction_halve_Pct.csv"
// Hunt look into this function. 
asi_predictions_analysis6
matrix alternative_shortage=alternative_shortage\e(b)

matrix new_alternative_shortage=alternative_shortage'

estout matrix(new_alternative_shortage, fmt(%9.3g)), noabb varwidth(24)

// --------------------------------------------------------------------------------
// Different Assumptions on Generator Costs

// Reset Price
global p_e_g=4.5

matrix bigmat_gen_cost=bigmatbase

global filename="ASI_Prediction2005_7.csv"
disp("Different Assumptions on Generator Costs")
global sigma_0=$sigma_0_c
global sigma_1=$sigma_1_c

asi_predictions_analysis6
// Hunt: Graphs tk
// New Endogenous Graph: Constant Returns to Scale
lpoly profit_loss_endogeneous  lcapital if lcapital>11 & lcapital<20, ///
	degree(0) noscatter   bwidth(1.5)  lineopts(lwidth(thick)) ///
	title(Simulated Effects of Shortages by Plant Size) ///
	graphregion(color(white) lwidth(medium))

cap graph export "ShortageEffectsbyPlantSize_endogenous_crs.pdf", as(pdf) replace


matrix bigmat_gen_cost=bigmat_gen_cost\e(b)

global sigma_0=$sigma_0_a
global sigma_1=$sigma_1_a
asi_predictions_analysis6
matrix bigmat_gen_cost=bigmat_gen_cost\e(b)


global sigma_0=$sigma_0_b
global sigma_1=$sigma_1_b
asi_predictions_analysis6
matrix bigmat_gen_cost=bigmat_gen_cost\e(b)

matrix list bigmat_gen_cost


// Reset Costs
global sigma_0=$sigma_0_d
global sigma_1=$sigma_1_d

global p_e_s=18
global filename="ASI_Prediction2005_18.csv"
asi_predictions_analysis6
matrix altprice=bigmatbase\e(b)
global p_e_s=7



matrix new_gen_cost=bigmat_gen_cost' 
estout matrix(new_gen_cost, fmt(%9.3g)), noabb varwidth(20)

// --------------------------------------------------------------------------------
// Sigma: Elasticity of Substitution
/*matrix big_elasticity=bigmatbase

global filename="ASI_Prediction2005_7_1.csv"
asi_predictions_analysis6
matrix big_elasticity=big_elasticity\e(b)


global filename="ASI_Prediction2005_7_0.5.csv"
asi_predictions_analysis6
matrix big_elasticity=big_elasticity\e(b)


global filename="ASI_Prediction2005_7_0.1.csv"
asi_predictions_analysis6
matrix big_elasticity=big_elasticity\e(b)

matrix new_big_elasticity=big_elasticity' 
estout matrix(new_big_elasticity, fmt(%9.3g)), noabb varwidth(20)
*/

// --------------------------------------------------------------------------------
// Years 

matrix bigmat_year=bigmatbase
// 2) Year Time Series
// File to Anaylyze
forval i=1992/2010 {
	global filename="ASI_Prediction`i'_7.csv"
	asi_predictions_analysis6
	matrix bigmat_year=bigmat_year\e(b)
}

matrix new_bigmat_year=bigmat_year' 
estout matrix(new_bigmat_year, fmt(%9.3g)), noabb varwidth(20)

// --------------------------------------------------------------------------------
// Big and Small
global droplist="totpersons>100"
global p_e_s=7
global filename="ASI_Prediction2005_7.csv"
asi_predictions_analysis6
matrix size_mat=e(b)
sum zero_gen

global droplist="totpersons<100"
global p_e_s=7
global filename="ASI_Prediction2005_7.csv"
asi_predictions_analysis6
matrix size_mat=size_mat\e(b)
sum zero_gen

// Electricity Intensive and not
sum alpha_e, detail
global median_alpha_e=r(p50)
global droplist="alpha_e<$median_alpha_e"
global gen_cost=200*52/($gen_lifespan)

global p_e_s=7
global filename="ASI_Prediction2005_7.csv"
asi_predictions_analysis6
matrix size_mat=size_mat\e(b)


global droplist="alpha_e>$median_alpha_e"
global gen_cost=200*52/($gen_lifespan)

global p_e_s=7
global filename="ASI_Prediction2005_7.csv"
asi_predictions_analysis6
matrix size_mat=size_mat\e(b)

matrix newsize=size_mat'
matrix new_big_mat_year=bigmat_year[.,1..2],bigmat_year[.,5..10]

matrix new_big_mat_year=new_big_mat_year'
// --------------------------------------------------------------------------------
// CES 
/*
ASI_Prediction2005_7_1.5.csv
ASI_Prediction2005_7_1.csv
ASI_Prediction2005_7_0.5.csv
ASI_Prediction2005_7_0.1.csv */

global droplist=""
global p_e_s=7
global filename="ASI_Prediction2005_7_0.1.csv"
asi_predictions_analysis6
matrix ces_mat=0.1,e(b)

global filename="ASI_Prediction2005_7_0.5.csv"
asi_predictions_analysis6
matrix ces_mat=ces_mat\(0.5,e(b))


global filename="ASI_Prediction2005_7_0.8.csv"
asi_predictions_analysis6
matrix ces_mat=ces_mat\(0.8,e(b))


global filename="ASI_Prediction2005_7_0.9.csv"
asi_predictions_analysis6
matrix ces_mat=ces_mat\(0.9,e(b))


global filename="ASI_Prediction2005_7.csv"
asi_predictions_analysis6
matrix ces_mat=ces_mat\(1,e(b))

global filename="ASI_Prediction2005_7_1.5.csv"
asi_predictions_analysis6
matrix ces_mat=ces_mat\(1.5,e(b))

// Add in Leontieff
global droplist=""
global p_e_s=7
cd .. 
cd simulation_asi_inputs_oct2014_leontieff
global filename="ASI_Prediction2005_7.csv"
asi_predictions_analysis5
matrix ces_mat=ces_mat\(100,e(b))





// --------------------------------------------------------------------------------
// Output 
global droplist=""

cd ..

log using simulation_results5.log, replace
estout matrix(newsize, fmt(%9.2g)), noabb varwidth(24)

estout matrix(new_alternative_shortage, fmt(%9.2g)), noabb varwidth(24)

estout matrix(new_big_mat_year, fmt(%9.2g)), noabb varwidth(20)

estout matrix(new_gen_cost, fmt(%9.2g)), noabb varwidth(20)
 
*estout matrix(new_big_elasticity, fmt(%9.3g)), noabb varwidth(20)

log close

disp("That's it")

// ---------------------------------------------------------------------
// ----------- Make Figures 
// 


esttab matrix(newsize) using newsize.csv, plain  replace
esttab matrix(new_big_mat_year) using new_big_mat_year.csv,  plain replace
esttab matrix(new_gen_cost) using new_gen_cost.csv,  plain replace

esttab matrix(new_alternative_shortage) using shortage_estimate.csv,  plain replace

esttab matrix(ces_mat) using ces_estimates.csv,  plain replace



clear
// Need to transpose and take out one column with shortage_estimate in excel
insheet using shortage_estimate_mod.csv
sort shortage
set scheme lean2

label variable  shortage "Shortage" 
label variable  output_loss "Output Loss"
label variable  output_loss_gen "Output Loss: No Generator" 
label variable  output_loss_nogen "Output Loss: Generators"


line output_loss shortage,  lcolor("blue") lwidth(thick) || line output_loss_gen shortage, lcolor("green") lwidth(thick) || line output_loss_nogen shortage, lcolor("red")  lwidth(thick) ytitle("Percent Output Loss") ylabel(0(10)30) legend(size(medlarge) pos(6)  region(lstyle(thick)))
graph export output_loss.pdf, replace


label variable  diff_endo "Output Loss" 
label variable  dendo_no_gen "Output Loss: No Generator" 
label variable  dendo_gen "Output Loss: Generators"

line diff_endo shortage,  lcolor("blue") lwidth(thick) || line dendo_no_gen shortage, lcolor("green") lwidth(thick) || line dendo_gen shortage,  lcolor("red") lwidth(thick) ytitle("Percent Output Loss") legend( region(lstyle(thick)) size(medlarge) pos(6)) ylabel(0(10)30)
graph export output_loss_endo.pdf, replace

label variable  buy_generator "Generator Uptake"
line buy_generator shortage , lcolor("blue") lwidth(thick)
graph export uptake.pdf, replace 


label variable  profit_diff_shortage  "Variable Profit Loss" 
label variable  profit_endo  "Variable Profit Loss" 

label variable  r_gen_cost_to_profit_exo  "Generator Cost as Fraction of Profits" 
label variable  r_gen_cost_to_profit_endo  "Generator Cost as Fraction of Profits" 

gen total_profit_loss_exo=profit_diff_shortage+r_gen_cost_to_profit_exo
label variable  total_profit_loss_exo  "Total Profit Loss" 
gen total_profit_loss_endo=profit_endo+r_gen_cost_to_profit_endo
label variable  total_profit_loss_endo  "Total Profit Loss" 

line profit_diff_shortage shortage, lcolor("blue") lwidth(thick) || line r_gen_cost_to_profit_exo shortage, lcolor("red") lwidth(thick) || line total_profit_loss_exo shortage, lcolor("green") lwidth(thick) ytitle("Percent Profit Loss")  legend(size(medlarge) pos(6)  region(lstyle(thick)))	
graph export profit_loss_exo.pdf, replace 
line profit_endo shortage, lcolor("blue") lwidth(thick)  || line r_gen_cost_to_profit_endo shortage, lcolor("red") lwidth(thick)  || line total_profit_loss_endo shortage, lcolor("green") lwidth(thick)  ytitle("Percent Profit Loss") legend(size(medlarge) pos(6)  region(lstyle(thick)))	 
graph export profit_loss_endo.pdf, replace 

// Make Year Graph 
clear
insheet using new_big_mat_year_mod.csv
sort year

label variable  output_loss "Percent Revenue Loss"
line output_loss year, lcolor("blue") lwidth(thick) ylabel(0(2)11)
graph export output_loss_by_year.pdf, replace 


