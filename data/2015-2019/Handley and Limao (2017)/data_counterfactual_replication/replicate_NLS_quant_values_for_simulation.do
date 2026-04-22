

clear all
	
	
set more off

use replication_maindata1, clear

local year=2005	
local x=5

	
	local outregfile table6.out
	local replace replace 

	
	xtset hs6 year
	
	
***non-linear***

gen lag_imports00=L5.imports
	keep if year==2005

	*since much depends on the transport cost, which pins down k 
	*and k shows up in all other coefficients we need to make sure that k is not
	*biased by outliers in transport costs, particularly given that the latter
	*are sometimes measured with error**
	
	qui reg dif_ln_imp_5  dif_ln_tcost_5 dif_advalorem_mfn_5 rat_2000 if year==2005 
	
		
	gen olssample=1 if e(sample)
	
	
	egen p25=pctile(dif_ln_tcost_5)  if e(sample), p(25)
	egen p75=pctile(dif_ln_tcost_5)  if e(sample), p(75)
	gen double inner=p25-3*(p75-p25)
	gen double outer =p75+3*(p75-p25)
	
	*confirm
	sum inner outer

	
	*scalar
	sum inner 
	scalar inner=r(mean)
	sum outer
	scalar outer=r(mean)
	
local replace replace	
	

*no section, restrict sigma=3*
		constraint 1 dif_ln_tcost_5*3/2= dif_advalorem_mfn_5
	
/* col 1*/	

reg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 if  dif_ln_tcost_5>inner & dif_ln_tcost_5<outer  & year==2005,r 

	

cnsreg dif_ln_imp_5  unc_pre dif_ln_tcost_5 dif_advalorem_mfn_5 if  dif_ln_tcost_5>inner & dif_ln_tcost_5<outer  & year==2005,r constraint(1)

local olscoeff=_b[unc_pre]
local k_ols=-_b[dif_ln_tcost_5]

capture drop regsamp
gen regsamp=e(sample)
	

/* col 2*/		

nl (dif_ln_imp_5 = {alpha=1} - (({k=3}-(3-1))/(3-1))*ln(1+{gamma=1}*rat_2000^(3))  -{k=3}*dif_ln_tcost_5  -{k=3}*(3/(3-1))*dif_advalorem_mfn_5   ) if dif_ln_tcost_5>inner & dif_ln_tcost_5<outer , vce(r) variables(rat_2000 dif_ln_tcost_5 dif_advalorem_mfn_5)

	

					

				*average margin -what we compute in spreadhseet*
				margins, exp(((_b[/k]-3+1)/(3-1))*ln((1+_b[/gamma]*rat_2000^3)/(1+_b[/gamma])))
				matrix bmat=r(b)
				local nlmean=bmat[1,1]
				matrix bvar=r(V)
				local nlse=bvar[1,1]^.5

				**derive the equivalent of the beta_gamma coefficient we estimate in baseline and use to calculate impact on exports and show it is significant and approximately the same**
				nlcom ((_b[/k]-3+1)/(3-1))*_b[/gamma]
				matrix bmat=r(b)
				local unc_lin=bmat[1,1]
				matrix bvar=r(V)
				local unc_lin_se=bvar[1,1]^.5
			
				*tariff coefficient*
				nlcom -((_b[/k])*3/(3-1))
				matrix bmat=r(b)
				local tar_lin=bmat[1,1]
				matrix bvar=r(V)
				local tar_lin_se=bvar[1,1]^.5

				*transport cost coefficient*
				nlcom -(_b[/k])
				matrix bmat=r(b)
				local tc_lin=bmat[1,1]
				matrix bvar=r(V)
				local tc_lin_se=bvar[1,1]^.5
				


capture drop imptarwt
gen imptarwt=exp(advalorem_mfn)*imports

capture drop ln_tarinc
gen ln_tarinc=ln(1/rat_2000)

sum ln_tarinc if e(sample)

sum ln_tarinc [aw=imptarwt] if e(sample)

local inctar=r(mean)

display "Import weighted tariff increase: `inctar'"

local imppen=0.045


*Keep params and other weighted terms in a matrix to pass to Matlab for quantification*



local s=3

** construct params for the graph over y, varying tau1 between 1 (free trade) and average level of tau2 **

*applied MFN tariff in 2000

gen tau1=exp(advalorem_mfn_2000)
sum tau1

*applied MFN tariff in 2005
gen tau0=exp(advalorem_mfn)
sum tau0

*column 2 tariff in 2000
*****NOTE THAT "rat" term already lagged*******
gen tau2=(1/rat_2000)*tau1
sum tau2

*compute tau0hat assuming that tau0==1
gen tau0hat=(1/rat_2000)*1/tau2

sum tau0hat

sum tau2

*set max for grid*
local tau2max=`r(mean)'

*run grid of 25 points between tau1=1 and tau1=tau2*



local ymin=0.85

* will run a grid of 16 points over [.85, 1] with adjustments to y for bounds*


*initilize matrix
matrix params=J(7,25,9999)



forvalues i=1/25{

*iterate over the grid

*params for computations below*

local tau1=(`tau2max'-1)*(`i'-1)/24+1
local tau0hat=1/`tau1'
local ratgrid=`tau1'/`tau2max'
local ug=_b[/gamma]


*compute u and y terms*

local u_tilde=(1+`ug'*`ratgrid'^`s')^((_b[/k]-`s'+1)/(`s'-1))

*interaction term of tariff and unc terms for transition pindex*

local u_hat=(1/`ratgrid')^(1-`s')*`u_tilde'

*uncertainty term to power for entry computation*

local u_entry=(1+`ug'*`ratgrid'^`s')^(1/(`s'-1))


*tariff increase raised power*
local tarinc_expon=(1/`ratgrid')^(1+`tar_lin')


matrix params[2,`i']=`u_tilde'

matrix params[3,`i']=`u_hat'

matrix params[4,`i']=`u_entry'

matrix params[5,`i']=(`tau0hat')^(-`s'/(`s'-1))

matrix params[6,`i']=`tarinc_expon'

*save `tau0hat' for grid*

matrix params[1,`i']=`tau0hat'

matrix params[7,`i']=`ratgrid'

}



matrix list params

mat2txt , matrix(params) saving(quant_ygrid.txt) replace



/** construct values for baseline quantification, adjusting for change
*** in tariffs from 2000 to 2005 				*****/


*Keep params and other weighted terms in a matrix to pass to Matlab for quantification*


*initilize matrix
matrix params=J(27,1,9999)
*matrix rownames params = k b_gam_coef wt_tarchange wt_tar_tilde wt_U_tilde noadjeffect num_exp wt_u_entry wt_U_hat tau2hat U_tilde rat_sig_mean rat_sig_wtmean olscoef k_ols u_entry_unwt



*compute new values needed for endogenous entry quant*

*params for computations below*

local beta_f=0.85
local beta_h=0.90


*beta_gamma term*
local ug=_b[/gamma]
local s=3
local tar_lin=-_b[/k]*`s'/(`s'-1)
local I_init=0.045
local m=1

tempvar  tau0hat_sigexp taumean tauhat_exp tauhat_price u_tilde u_hat u_entry ratmean ratmean_sig tau2hat tau0hat tau0hat_exp imptarwt_atmean trat_wt ratmean_sig


*for consistency with risk decomp
*taumean is set to tau1 = year 2000 applied tariff
gen `taumean'=tau1

*weighted mean tariff
sum `taumean' [aw=imptarwt] if e(sample)

local tau_mean=`r(mean)'
matrix params[8,`m']=`r(mean)'

*tariff increase from MFN to mean for deterministic import change*
*this is going to be weighted by 2005 import values*
gen `tauhat_exp'=(`taumean'/tau0)^(`tar_lin')

gen `tauhat_price'=(`taumean'/tau0)^(1+`tar_lin')

sum `tauhat_exp' [aw=imptarwt] if e(sample)
local tauhat_exp_wt=`r(mean)'
matrix params[2,`m']=`r(mean)'

sum `tauhat_price' [aw=imptarwt] if e(sample)
local tauhat_p_wt=`r(mean)'
matrix params[3,`m']=`r(mean)'


*once we have the proper aggregated weighted terms to compute
* the import penetration at mean relative to 2005 trade values
* we need the mean ratio term and other u terms weighted by
* the counterfactual import levels at the mean tariff

*counterfactual import weights are just the ratio of 
*tau1 and meantau by industry raised to tariff elast
*with an adjustment to expenditure by the new mean tariff


*compute the change in prices and new deterministic mean tariff
* use to adjust imports for each hs6 tariff line.
local P_mean=(`I_init'*`tauhat_p_wt'+(1-`I_init'))^(-1/_b[/k])

*this is aggregate change in imports, used to compute change in import penetration
* in the matlabl program but just here as a reminder.
local Rhatmean=`tauhat_exp_wt'*`P_mean'^_b[/k]

*new tariff inclusive import weights by hs6
gen `imptarwt_atmean'=`taumean'*(`taumean'/tau0)^`tar_lin'*`P_mean'^_b[/k]*(imptarwt/tau0)


di "Averge import weights for C/F and 2005"
sum `imptarwt_atmean' imptarwt if e(sample)


sum tau2 [aw=`imptarwt_atmean'] if e(sample)
local tau2_mean=`r(mean)'
matrix params[4,`m']=`r(mean)'

sum tau1 [aw=`imptarwt_atmean'] if e(sample)
local tau1_mean=`r(mean)'
matrix params[5,`m']=`r(mean)'

*new tau0hat variable if tariffs decrease back to tau1 in future from mean*
gen `tau0hat'=tau0/`taumean'

*weighted tau0hat and weidhted tau0hat to exponent of (1-tariff elasticity)*
sum `tau0hat' [aw=`imptarwt_atmean'] if e(sample)
matrix params[6,`m']=`r(mean)'

gen `tau0hat_exp'=`tau0hat'^(1+`tar_lin')
sum `tau0hat_exp' [aw=`imptarwt_atmean'] if e(sample)
matrix params[12,`m']=`r(mean)'


gen `tau0hat_sigexp'=`tau0hat'^(1-`s')
sum `tau0hat_sigexp' [aw=`imptarwt_atmean'] if e(sample)
matrix params[27,`m']=`r(mean)'


local rat_mean=`tau_mean'/`tau2_mean'
matrix params[7,`m']=`rat_mean'


/*** set of terms in U at updated mean ratio term***/

gen `ratmean'=`taumean'/tau2

gen `trat_wt'=(1/`ratmean')^(1+`tar_lin')


gen `u_tilde'=(1+`ug'*`ratmean'^`s')^((_b[/k]-`s'+1)/(`s'-1))

*interaction term of tariff and unc terms for transition pindex*

gen `u_hat'=(1/`ratmean')^(1-`s')*`u_tilde'

*uncertainty term to power for entry computation*

gen `u_entry'=(1+`ug'*`ratmean'^`s')^(1/(`s'-1))


* now weight up the U terms at counterfact import levels*

sum `trat_wt' [aw=`imptarwt_atmean'] if e(sample)
matrix params[13,`m']=`r(mean)'


sum `u_tilde' [aw=`imptarwt_atmean'] if e(sample)

matrix params[9,`m']=`r(mean)'

sum `u_hat' [aw=`imptarwt_atmean'] if e(sample)

matrix params[10,`m']=`r(mean)'

sum `u_entry' [aw=`imptarwt_atmean'] if e(sample)

matrix params[11,`m']=`r(mean)'


***assign ols coeff ***
matrix params[14,1]=`olscoeff'
matrix params[15,1]=`k_ols'

*assign nls coeffs***			
matrix params[16,1]=_b[/k]
matrix params[26,1]=_b[/gamma]



****unweighted terms****


***unweighted mean change tariff from MFN to col2, tau2hat***

***unweighted mean u_hat****
sum `u_tilde' if e(sample)

matrix params[17,1]=`r(min)'
matrix params[18,1]=`r(max)'
matrix params[19,1]=`r(mean)'


gen tarinc=1/rat_2000
sum tarinc if e(sample)
matrix params[20,1]=`r(mean)'


sum `u_tilde' if e(sample)
matrix params[21,1]=`r(mean)'

sum `u_hat' if e(sample)
matrix params[22,1]=`r(mean)'

sum `u_entry' if e(sample)
matrix params[23,1]=`r(mean)'


***weighted and unweighted ratio term - no geometric mean since will only be applied to log terms***
gen `ratmean_sig'=`ratmean'^(`s')
sum `ratmean_sig' if e(sample)
matrix params[24,1]=`r(mean)'

sum `ratmean_sig' [aw=`imptarwt_atmean'] if e(sample)
matrix params[25,1]=`r(mean)'



matrix list params

mat2txt , matrix(params) saving(quant_params_new.txt) replace



/******************************************************************************
************* QUANTIFICATION OVER u & GAMMA TERMS *****************************
******************************************************************************/

*initilize matrix
matrix params=J(4,25,9999)

*compute new values needed for endogenous entry quant*

local s=3
*tariff increase raised power*
gen tarinc_expon=(1/rat_2000)^(1+`tar_lin')

*uncertainty term raised to power*

*max little is 1.61 if beta_f=.85 and beta_h=.9

local ugmax=1.61



*compute new values needed for endogenous entry quant*

*params for computations below*

local beta_f=0.85
local beta_h=0.90


*beta_gamma term*
local tar_lin=-_b[/k]*`s'/(`s'-1)
local I_init=0.045


tempvar  tau0hat_sigexp taumean tauhat_exp tauhat_price u_tilde u_hat u_entry ratmean ratmean_sig tau2hat tau0hat tau0hat_exp imptarwt_atmean trat_wt ratmean_sig


*for consistency with risk decomp
*taumean is set to tau1 = year 2000 applied tariff
gen `taumean'=tau1

*weighted mean tariff
sum `taumean' [aw=imptarwt] if e(sample)

local tau_mean=`r(mean)'

*once we have the proper aggregated weighted terms to compute
* the import penetration at mean relative to 2005 trade values
* we need the mean ratio term and other u terms weighted by
* the counterfactual import levels at the mean tariff

*counterfactual import weights are just the ratio of 
*tau1 and meantau by industry raised to tariff elast
*with an adjustment to expenditure by the new mean tariff


*compute the change in prices and new deterministic mean tariff
* use to adjust imports for each hs6 tariff line.
local P_mean=(`I_init'*`tauhat_p_wt'+(1-`I_init'))^(-1/_b[/k])

*this is aggregate change in imports, used to compute change in import penetration
* in the matlabl program but just here as a reminder.
local Rhatmean=`tauhat_exp_wt'*`P_mean'^_b[/k]

*new tariff inclusive import weights by hs6
gen `imptarwt_atmean'=`taumean'*(`taumean'/tau0)^`tar_lin'*`P_mean'^_b[/k]*(imptarwt/tau0)


di "Averge import weights for C/F and 2005"
sum `imptarwt_atmean' imptarwt if e(sample)


sum tau2 [aw=`imptarwt_atmean'] if e(sample)
local tau2_mean=`r(mean)'
*matrix params[4,`m']=`r(mean)'

sum tau1 [aw=`imptarwt_atmean'] if e(sample)
local tau1_mean=`r(mean)'
*matrix params[5,`m']=`r(mean)'

*new tau0hat variable if tariffs decrease back to tau1 in future from mean*
gen `tau0hat'=tau0/`taumean'

*weighted tau0hat and weidhted tau0hat to exponent of (1-tariff elasticity)*
*sum `tau0hat' [aw=`imptarwt_atmean'] if e(sample)
*matrix params[6,`m']=`r(mean)'

/*** set of terms in U at updated mean ratio term***/

gen `ratmean'=`taumean'/tau2

gen `trat_wt'=(1/`ratmean')^(1+`tar_lin')



forvalues i=1/25{

tempvar u_tilde u_hat u_entry
display "Loop `i' over u grid ***************************************"
*iterate over the grid
local ug=`ugmax'*(`i'-1)/24

gen `u_tilde'=(1+`ug'*`ratmean'^`s')^((_b[/k]-`s'+1)/(`s'-1))

*interaction term of tariff and unc terms for transition pindex*

gen `u_hat'=(1/`ratmean')^(1-`s')*`u_tilde'

*uncertainty term to power for entry computation*

gen `u_entry'=(1+`ug'*`ratmean'^`s')^(1/(`s'-1))

* now weight up the U terms at counterfact import levels*
/*
sum `trat_wt' [aw=`imptarwt_atmean'] if e(sample)
matrix params[13,`m']=`r(mean)'
*/


sum `u_tilde' [aw=`imptarwt_atmean'] if e(sample)

matrix params[2,`i']=`r(mean)'

sum `u_hat' [aw=`imptarwt_atmean'] if e(sample)

matrix params[3,`i']=`r(mean)'

sum `u_entry' [aw=`imptarwt_atmean'] if e(sample)

matrix params[4,`i']=`r(mean)'


matrix params[1,`i']=`ug'
}

matrix list params

mat2txt , matrix(params) saving(quant_ugrid.txt) replace


/****************************************************************************
***************  GRID OVER TARIFFS/RISK LEVELS ******************************
*****************************************************************************/

**** construct values for risk decomposition over
**** alternative odds of WTO vs Col2 states

* use lam2 to capture probability of col2
* run 24 gridpoints from 0 to 1
* odd number gives increaments of 0.05% probability including endoints

*initilize matrix
matrix params=J(14,24,9999)


****


*params for computations below*


local beta_f=0.85
local beta_h=0.90
local g=1.00414


*beta_gamma term*
local ug=_b[/gamma]
local s=3
local tar_lin=-_b[/k]*`s'/(`s'-1)
local I_init=0.045

forvalues m=1/24{

tempvar  taumean tauhat_exp tauhat_price u_tilde u_hat u_entry ratmean ratmean_sig tau2hat tau0hat tau0hat_exp imptarwt_atmean trat_wt

*mean is lam2*tau2+(1-lam2)*tau1

local lam2=(`m'-1)/20


if `m'==22{
local alpha=2
* lam2 = 1/(1+x) where x=alpha*(beta_f/(1-beta_f))*(1-beta_h)/beta_h
local lam2=1/(1+`alpha'*(`beta_f'/(1-`beta_f'))*(1-`beta_h')/`beta_h')
}

if `m'==23{
local alpha=4
* lam2 = 1/(1+x) where x=alpha*(beta_f/(1-beta_f))*(1-beta_h)/beta_h
local lam2=1/(1+`alpha'*(`beta_f'/(1-`beta_f'))*(1-`beta_h')/`beta_h')
}


if `m'==24{
local alpha=6
* lam2 = 1/(1+x) where x=alpha*(beta_f/(1-beta_f))*(1-beta_h)/beta_h
local lam2=1/(1+`alpha'*(`beta_f'/(1-`beta_f'))*(1-`beta_h')/`beta_h')
}

*compute between tau0=2005 MFN and tau2=col2
gen `taumean'=`lam2'*tau2+(1-`lam2')*tau0

*weighted mean tariff
sum `taumean' [aw=imptarwt] if e(sample)

local tau_mean=`r(mean)'
matrix params[8,`m']=`r(mean)'

*tariff increase from MFN to mean for deterministic import change*
*this is going to be weighted by 2005 import values*

*base level tariff is tau0 below*
gen `tauhat_exp'=(`taumean'/tau0)^(`tar_lin')

gen `tauhat_price'=(`taumean'/tau0)^(1+`tar_lin')

sum `tauhat_exp' [aw=imptarwt] if e(sample)
local tauhat_exp_wt=`r(mean)'
matrix params[2,`m']=`r(mean)'

sum `tauhat_price' [aw=imptarwt] if e(sample)
local tauhat_p_wt=`r(mean)'
matrix params[3,`m']=`r(mean)'


*once we have the proper aggregated weighted terms to compute
* the import penetration at mean relative to 2005 trade values
* we need the mean ratio term and other u terms weighted by
* the counterfactual import levels at the mean tariff

*counterfactual import weights are just the ratio of 
*tau1 and meantau by industry raised to tariff elast
*with an adjustment to expenditure by the new mean tariff


*compute the change in prices and new deterministic mean tariff
* use to adjust imports for each hs6 tariff line.
local P_mean=(`I_init'*`tauhat_p_wt'+(1-`I_init'))^(-1/_b[/k])

*this is aggregate change in imports, used to compute change in import penetration
* in the matlabl program but just here as a reminder.
local Rhatmean=`tauhat_exp_wt'*`P_mean'^_b[/k]

*new tariff inclusive import weights by hs6
gen `imptarwt_atmean'=`taumean'*(`taumean'/tau1)^`tar_lin'*`P_mean'^_b[/k]*(imptarwt/tau1)


di "Averge import weights for C/F and 2005"
sum `imptarwt_atmean' imptarwt if e(sample)


sum tau2 [aw=`imptarwt_atmean'] if e(sample)
local tau2_mean=`r(mean)'
matrix params[4,`m']=`r(mean)'

sum tau0 [aw=`imptarwt_atmean'] if e(sample)
local tau0_mean=`r(mean)'
matrix params[5,`m']=`r(mean)'


sum tau1 [aw=`imptarwt_atmean'] if e(sample)
local tau1_mean=`r(mean)'
matrix params[14,`m']=`r(mean)'

*new tau0hat variable if tariffs decrease back to tau0 in future from mean*
gen `tau0hat'=tau0/`taumean'

*weighted tau0hat and weidhted tau0hat to exponent of (1-tariff elasticity)*
sum `tau0hat' [aw=`imptarwt_atmean'] if e(sample)
matrix params[6,`m']=`r(mean)'

gen `tau0hat_exp'=`tau0hat'^(1+`tar_lin')
sum `tau0hat_exp' [aw=`imptarwt_atmean'] if e(sample)
matrix params[12,`m']=`r(mean)'


local rat_mean=`tau_mean'/`tau2_mean'
matrix params[7,`m']=`rat_mean'


/*** set of terms in U at updated mean ratio term***/

gen `ratmean'=`taumean'/tau2

gen `trat_wt'=(1/`ratmean')^(1+`tar_lin')


gen `u_tilde'=(1+`ug'*`ratmean'^`s')^((_b[/k]-`s'+1)/(`s'-1))

*interaction term of tariff and unc terms for transition pindex*

gen `u_hat'=(1/`ratmean')^(1-`s')*`u_tilde'

*uncertainty term to power for entry computation*

gen `u_entry'=(1+`ug'*`ratmean'^`s')^(1/(`s'-1))


* now weight up the U terms at counterfact import levels*

sum `trat_wt' [aw=`imptarwt_atmean'] if e(sample)
matrix params[13,`m']=`r(mean)'


sum `u_tilde' [aw=`imptarwt_atmean'] if e(sample)

matrix params[9,`m']=`r(mean)'

sum `u_hat' [aw=`imptarwt_atmean'] if e(sample)

matrix params[10,`m']=`r(mean)'

sum `u_entry' [aw=`imptarwt_atmean'] if e(sample)

matrix params[11,`m']=`r(mean)'

*save odds ratio*
matrix params[1,`m']=`lam2'
}

matrix list params

mat2txt , matrix(params) saving(quant_riskgrid.txt) replace



***save a few weighted tariff params from no WTO counterfactauls****

*initilize matrix
matrix params=J(3,1,9999)

sum tau0 if olssample==1
matrix params[1,1]=`r(mean)'

sum tau1 if olssample==1
matrix params[2,1]=`r(mean)'

sum tau2 if olssample==1
matrix params[3,1]=`r(mean)'

mat2txt , matrix(params) saving(tariffs_simplemeans.txt) replace


*initilize matrix
matrix params=J(3,1,9999)

sum tau0 if olssample==1
matrix params[1,1]=`r(mean)'

sum tau1 if olssample==1
matrix params[2,1]=`r(mean)'

sum tau2 if olssample==1
matrix params[3,1]=`r(mean)'

mat2txt , matrix(params) saving(tariffs_simplemeans.txt) replace



exit

