** This version estimates the ILS with only taxes as shocks uses 4 moments to estimate 3 parameters
** Takes gamma and epsilon as external parameters

******* Set Global Path. Do not edit. 
*global dataoutpath "$path/Local_Econ_Corp_Tax/Data"
*global progpath "$path/Local_Econ_Corp_Tax/Programs/Conspuma Programs/Decade Analysis"
*global netspath "$path/local_econ_corp_tax/Data/County NETS data/"

cd "$dopath"
clear all 
set mem 100m
set matsize 800
set more off

do CMD/postmoments3.ado

use "$dtapath/CMD/ILS_3_shocks_6_parm_housing.dta", clear   

*rust belt states in the 1980s
gen fe_group = fips_state 
replace fe_group = 0 if year > 1990 
replace fe_group = 0 if census_div==1 
replace fe_group = 0 if census_div==2
replace fe_group = 0 if census_div==5 
replace fe_group = 0 if census_div==6 
replace fe_group = 0 if census_div==7
replace fe_group = 0 if census_div==8
replace fe_group = 0 if census_div==9

xi i.year i.fe_group

qui { 

capture program drop cmdestjoint 
prog cmdestjoint, eclass 
		version 11
		syntax varlist [if] [in]  [aw fw pw iw] [,vce(string) cluster(varname)] epsilon(real) gamma(real) alpha(real)
		marksample touse 

		tempvar sample
		
	    tokenize `varlist'
	//D 1 
	    local dest `1'
    	macro shift
	//D 2 
	    local dpop `1'
    	macro shift
	//D 3 
	    local drent `1'
    	macro shift
	//D 4
	    local dwage `1'    
	    macro shift
   	//Z  	
	    local dtax `1'    
	    macro shift
	//Z2  	
	    local bartik `1'    
	    macro shift		
	//Z3  	
	    local desrate `1'    
	    macro shift				
	// FEs 
	    local x `*'
		
	    scalar epsilon = `epsilon'
	    scalar gamma = `gamma'	  				
		scalar alpha = `alpha'	  				

		reg `dpop' `dtax' `bartik' `desrate' `x' [`weight' `exp']
		est sto `dpop'
		reg `dwage' `dtax' `bartik' `desrate' `x' [`weight' `exp']
		est sto `dwage'
		reg `drent' `dtax' `bartik' `desrate' `x' [`weight' `exp']
		est sto `drent'
		reg `dest' `dtax' `bartik' `desrate'  `x' [`weight' `exp']
		est sto `dest'	 
		suest `dpop' `dwage' `drent' `dest' , cl(`cluster')		
		
		gen `sample' = e(sample) 
		
		mat b = e(b) 
		mat Vt = e(V) 

		mat li b 
		
		scalar s_k = colsof(b)/4
		
		mat pi = (0)
		
		forval i = 1/4 { 
				mat pi = (pi,b[1,(`i'-1)*s_k+1])
				mat pi = (pi,b[1,(`i'-1)*s_k+2])
				mat pi = (pi,b[1,(`i'-1)*s_k+3])
			} 
		mat pi = pi[1,2...]
		mat mt = pi*0
		
		mat li pi
		
		mat V = (0)
		forval i = 1/4 { 
			forval j = 1/4 { 
				mat V = (V,Vt[(`i'-1)*s_k+1,(`j'-1)*s_k+1])
				mat V = (V,Vt[(`i'-1)*s_k+1,(`j'-1)*s_k+2])	
				mat V = (V,Vt[(`i'-1)*s_k+1,(`j'-1)*s_k+3])	
			}
			forval j = 1/4 { 
				mat V = (V,Vt[(`i'-1)*s_k+2,(`j'-1)*s_k+1])
				mat V = (V,Vt[(`i'-1)*s_k+2,(`j'-1)*s_k+2])	
				mat V = (V,Vt[(`i'-1)*s_k+2,(`j'-1)*s_k+3])	
			}
			forval j = 1/4 { 
				mat V = (V,Vt[(`i'-1)*s_k+3,(`j'-1)*s_k+1])
				mat V = (V,Vt[(`i'-1)*s_k+3,(`j'-1)*s_k+2])	
				mat V = (V,Vt[(`i'-1)*s_k+3,(`j'-1)*s_k+3])	
			}			
		}
				
		mat V = V[1,2...]
		
		
		
		mata: st_matrix("V", rowshape( st_matrix("V")', 12) )
		mat li V 
			
		local N = e(N) 
		
		mat theta = (.5,.6,2,.6,-.6,.4,1)

		mat rb= J(1,7,0)
		mat rV = J(7,7,0)
		mat Q = 0 

		mata: mycmd(st_matrix("theta"))

		scalar Q = el(Q,1,1)
		scalar Qdof = 5
		scalar pval = 1 - chi2(Qdof,Q)
		
		matrix colnames rb = sigma_F sigma_W eta lambda lambda_h lambda_z kappa
		matrix colnames rV = sigma_F sigma_W eta lambda lambda_h lambda_z kappa
		matrix rownames rV = sigma_F sigma_W eta lambda lambda_h lambda_z kappa

		ereturn post rb rV, obs(`N')

		
		mat rb = (e(b),J(1,11,0))
		mat rV = (e(V),J(7,11,0) \ J(11,18,0) ) 


qui { 
		local eld "(gamma*(epsilon+1-1/_b[sigma_F])-1)" 		
		local els "((1+_b[eta]-alpha)/(_b[sigma_W]*(1+_b[eta])+alpha)) " 		
		local tw  "((-1/((epsilon+1)*_b[sigma_F]))/( `els'-`eld' ))" 
		local tr "((1+`els')/(1+_b[eta]))*`tw'"
		local trw "(`tw'-alpha*`tr')"
		local tpi "(1-(1-gamma)*(epsilon+1)+ gamma*(epsilon+1)*`tw' ) "
// For intermediate goods 
		local tpi "((1-gamma*.9*(epsilon+1) + gamma*(epsilon+1)*`tw' ) )"		
		local tot_w "(`tr'+`trw'+`tpi')"
		local s_land "`tr'/`tot_w'"
		local s_work "`trw'/`tot_w'"
		local s_firm "`tpi'/`tot_w'"		

		// Micro elas 
		nlcom 1/_b[sigma_W] 		
		mat rb[1,8] = r(b)
		mat rV[8,8] = r(V)
		// Macro elas 
		nlcom `els' 		
		mat rb[1,9] = r(b)
		mat rV[9,9] = r(V)
		// Micro elas 
		nlcom gamma*(epsilon+1)-1 		
		mat rb[1,10] = r(b)
		mat rV[10,10] = r(V)
		// Macro elas 
		nlcom `eld' 		
		mat rb[1,11] = r(b)
		mat rV[11,11] = r(V)				
		// tilde w  
		nlcom `tw'
		mat rb[1,12] = r(b)
		mat rV[12,12] = r(V)
		// tilde r  
		nlcom `tr'
		mat rb[1,13] = r(b)
		mat rV[13,13] = r(V)
		// tilde rw  
		nlcom `trw'
		mat rb[1,14] = r(b)
		mat rV[14,14] = r(V)
		// tilde pi  
		nlcom `tpi'
		mat rb[1,15] = r(b)
		mat rV[15,15] = r(V)
		// share to land 
		nlcom `s_land'
		mat rb[1,16] = r(b)
		mat rV[16,16] = r(V)
		// share to workers 
		nlcom `s_work'
		mat rb[1,17] = r(b)
		mat rV[17,17] = r(V)
		// share to firms 
		nlcom `s_firm'
		mat rb[1,18] = r(b)
		mat rV[18,18] = r(V)

		matrix colnames rb = sigma_f sigma_w eta lambda lambda_h lambda_z kappa micro_els macro_els micro_eld macro_eld tilde_w tilde_r tilde_r_w tilde_pi share_L share_W share_F
		matrix colnames rV = sigma_f sigma_w eta lambda lambda_h lambda_z kappa micro_els macro_els micro_eld macro_eld tilde_w tilde_r tilde_r_w tilde_pi share_L share_W share_F
		matrix rownames rV = sigma_f sigma_w eta lambda lambda_h lambda_z kappa micro_els macro_els micro_eld macro_eld tilde_w tilde_r tilde_r_w tilde_pi share_L share_W share_F

}
		ereturn post rb rV, obs(`N') esample(`sample')

		display as text "  " 
		display as text "Gamma =" as result gamma
		display as text "Epsilon =" as result epsilon
		display as text "  " 				
		
		ereturn display
		
		ereturn scalar Q = Q
		ereturn scalar pval = pval
		ereturn scalar Chi2dof = Qdof	

		ereturn scalar gamma = `gamma'
		ereturn scalar epsilon = `epsilon'	
		ereturn scalar alpha = `alpha'	
		
		ereturn matrix moments = pi
		ereturn matrix moments_V = V
		ereturn matrix moments_pred = mt
		
		display as text "  " 
		display as text "Test of Overidentification Restrictions" 
		display as text "chi2(" as result Qdof as text " ) =  " as result Q 
		display as text "Prob > chi2 =  " as result pval

		ereturn local model "cmd" 
	    ereturn local cmd "cmdestjoint"
	    ereturn local depvar "many"
	    ereturn local title "Joint Estimates of Structural Parameters"	 
			
end		
mata:
mata clear  
void mycmd(theta) 
	{
		external pi, iV, gamma, epsilon, alpha

		gamma = st_numscalar("gamma")		
		epsilon = st_numscalar("epsilon")	
		alpha = st_numscalar("alpha")	

		pi = st_matrix("pi") 	
		V = st_matrix("V")
	// Use inverse varaince as weights
		iV = invsym(V)
	// Use identity as weights 
	// iV = diag(J(1,12,1))
	// Kill personal tax on rents 
	//	iV[9,9] = 0 
		init = st_matrix("theta")
		S = optimize_init()
		optimize_init_evaluator(S, &i_crit()) 
		optimize_init_which(S, "min") 
		optimize_init_evaluatortype(S, "d1") 
		optimize_init_params(S, init)
		optimize_init_conv_warning(S, "on")		
	//	optimize_init_technique(S, " dfp 10 bfgs 10")
		optimize_init_technique(S, "nm 100")
		optimize_init_nmsimplexdeltas(S,0.25*J(1,cols(12),1))
		p = optimize(S)
		
		chi=optimize_result_value(S)
		chi = (chi) 
		
		c=p
		
		c = (c,epsilon,gamma)
	//	c[1] = invlogit(c[1])
	//	c[2] = invlogit(c[2])
	//	c[8] = invlogit(c[8])		
	//	p=c
	
//	c[1]=exp(c[1])
//	p[1]=c[1]	
//	c[3]=exp(c[3])
//	p[3]=c[3]	
		s_f = c[1]
		s_w = c[2]
		eta = c[3]
		lambda = c[4] 	
		lambda_h = c[5] 				
		lambda_z = c[6] 							
		epsilon = c[8]
		gamma = c[9]		
		kappa = c[7]
		a=alpha	
		els = ((1+eta)-a)/(s_w*(1+eta)+a)	
		eld = (gamma*(epsilon+1-1/s_f)-1)	
		tw = (-1/((epsilon+1)*s_f))/(els - eld )		
	
		
grad=( (gamma*((a + s_w + eta*s_w)*(eta - a + 1) + epsilon*(a + s_w + eta*s_w)*(eta - a + 1)) - (eta - a + 1)*(eta + s_w + eta*s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -((eta + 1)*(eta - a + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*(gamma*(s_w + 1) - s_f*(s_w + 1)*(gamma + epsilon*gamma - 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, ((eta - a + 1)*(lambda + eta*lambda - a*gamma*lambda_z + a*eta*gamma*lambda_h) + s_w*(eta - a + 1)*(lambda + eta*lambda - gamma*lambda_z - eta*gamma*lambda_z))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((eta + 1)^2*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda - lambda*s_f + lambda_z*s_f - epsilon*lambda*s_f) - a*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda - lambda*s_f + lambda_z*s_f - eta*gamma*lambda_h - epsilon*lambda*s_f - eta*lambda_h*s_f + eta*gamma*lambda_h*s_f + epsilon*eta*gamma*lambda_h*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(a*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f + a*gamma*lambda_h - epsilon*lambda*s_f - a*gamma*lambda_h*s_f - a*epsilon*gamma*lambda_h*s_f) + a*s_w*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda + gamma*lambda_h - lambda*s_f + lambda_h*s_f + lambda_z*s_f - epsilon*lambda*s_f - gamma*lambda_h*s_f - epsilon*gamma*lambda_h*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_f + epsilon*s_f - 1)*(eta - a + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(a*eta*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(s_f*(eta - a + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*(eta - a + 1)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f - a*gamma*s_f + s_w*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f) - a*epsilon*gamma*s_f)^2 )
grad=(grad, ((eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)^2*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(a*s_w*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)^2 - a*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(gamma*s_f - s_f - gamma - a*gamma*kappa + epsilon*gamma*s_f + a*gamma*kappa*s_f + a*epsilon*gamma*kappa*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -(a*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (gamma*(epsilon + 1)*(a + s_w + eta*s_w)^2 - (eta + 1)*(s_w + 1)*(a + s_w + eta*s_w))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (s_f*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(a*s_f*(s_w + 1))/((epsilon + 1)*(s_f + eta*s_f + s_f*s_w - gamma*(s_f + epsilon*s_f - 1)*(a + s_w + eta*s_w) + eta*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -(gamma*(a + s_w + eta*s_w)*(a*lambda_z + lambda_z*s_w - a*eta*lambda_h + eta*lambda_z*s_w) - lambda*(eta + 1)*(s_w + 1)*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(a*(s_f*(eta + 1)*(lambda*s_f - lambda - lambda_z*s_f + epsilon*lambda*s_f + eta*lambda_h*s_f) - gamma*s_f*(eta + 1)*(eta*lambda_h*s_f - eta*lambda_h + epsilon*eta*lambda_h*s_f)) + s_f*(eta + 1)*(lambda + eta*lambda - lambda*s_f + lambda_z*s_f - epsilon*lambda*s_f - eta*lambda*s_f + eta*lambda_z*s_f - epsilon*eta*lambda*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (a*s_f*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f - epsilon*lambda*s_f) - gamma*(a*s_f*(a*lambda_h*s_f - a*lambda_h + a*epsilon*lambda_h*s_f) + a*s_f*s_w*(lambda_h*s_f - lambda_h + epsilon*lambda_h*s_f)) + a*s_f*s_w*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f - epsilon*lambda*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_f + epsilon*s_f - 1)*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (a*eta*s_f)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(s_f*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*(a + s_w + eta*s_w)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(s_f*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(gamma*(a*s_f*(s_f - s_w - a*kappa + s_f*s_w + a*kappa*s_f - 1) + a*epsilon*s_f*(s_f + s_f*s_w + a*kappa*s_f)) - a*s_f*(s_f + s_f*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, (a*s_f*(eta + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -((s_w + 1)^2 - gamma*((s_w + epsilon*s_w)*(s_w + 1) + a*(epsilon + 1)*(s_w + 1)) + eta*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (gamma*(s_f + epsilon*s_f - 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(s_f*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)) + gamma*s_w*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, ((s_w + 1)*(lambda + eta*lambda + lambda*s_w + eta*lambda*s_w) - gamma*((lambda_z*s_w + eta*lambda_z*s_w)*(s_w + 1) + a*(s_w + 1)*(lambda_z - eta*lambda_h)))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(gamma*(s_f + epsilon*s_f - 1)*(lambda - a*lambda - lambda*s_f + lambda_z*s_f + a*lambda*s_f - a*lambda_z*s_f - epsilon*lambda*s_f + a*epsilon*lambda*s_f) + eta*gamma*(s_f + epsilon*s_f - 1)*(lambda - lambda*s_f + lambda_z*s_f + a*gamma*lambda_h + a*lambda_h*s_f - epsilon*lambda*s_f - a*gamma*lambda_h*s_f - a*epsilon*gamma*lambda_h*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w)*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f + lambda*s_w + a*gamma*lambda_h - epsilon*lambda*s_f + gamma*lambda_h*s_w - lambda*s_f*s_w + lambda_h*s_f*s_w + lambda_z*s_f*s_w - a*gamma*lambda_h*s_f - epsilon*lambda*s_f*s_w - gamma*lambda_h*s_f*s_w - a*epsilon*gamma*lambda_h*s_f - epsilon*gamma*lambda_h*s_f*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_w + 1)*(s_f + epsilon*s_f - 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (eta*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w))/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(s_f*(s_w + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*((eta + 1)*(s_w + 1) + a*(s_w + 1)*(kappa + eta*kappa - 1)))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(gamma*(s_f + epsilon*s_f - 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_w + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w) - a*gamma*kappa*(s_f + epsilon*s_f - 1)*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, ((eta + 1)*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w))/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(a*gamma - s_w - eta - eta*s_w + gamma*s_w + a*epsilon*gamma + epsilon*gamma*s_w + eta*gamma*s_w + epsilon*eta*gamma*s_w - 1)^2/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(gamma*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*gamma*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -((lambda + eta*lambda + lambda*s_w - a*gamma*lambda_z + eta*lambda*s_w - gamma*lambda_z*s_w - eta*gamma*lambda_z*s_w + a*eta*gamma*lambda_h)*(a*gamma - s_w - eta - eta*s_w + gamma*s_w + a*epsilon*gamma + epsilon*gamma*s_w + eta*gamma*s_w + epsilon*eta*gamma*s_w - 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (a*(s_f*(gamma*(eta + 1)*(lambda - lambda_z + eta*lambda_h - eta*gamma*lambda_h) + epsilon*gamma*(lambda - eta*gamma*lambda_h)*(eta + 1)) - gamma*(lambda - eta*gamma*lambda_h)*(eta + 1)) - s_f*(gamma*(eta + 1)*(lambda - lambda_z + eta*lambda - eta*lambda_z) + epsilon*gamma*(eta + 1)*(lambda + eta*lambda)) + gamma*(eta + 1)*(lambda + eta*lambda))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (s_f*(a*gamma*(lambda - lambda_h - lambda_z + a*gamma*lambda_h) + a*epsilon*gamma*(lambda + a*gamma*lambda_h)) + s_w*(s_f*(a*gamma*(lambda - lambda_h - lambda_z + gamma*lambda_h) + a*epsilon*gamma*(lambda + gamma*lambda_h)) - a*gamma*(lambda + gamma*lambda_h)) - a*gamma*(lambda + a*gamma*lambda_h))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -((eta + 1)*(s_w + 1))/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(a*eta*gamma)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (gamma*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*(eta - a*gamma - a*epsilon*gamma + 1)*(eta - a + a*kappa + a*eta*kappa + 1) - gamma*s_w*(eta + 1)*(gamma + epsilon*gamma - 1)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (gamma*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (s_f*(a*gamma*(gamma - s_w + gamma*s_w + a*gamma*kappa - 1) + a*epsilon*gamma*(gamma + gamma*s_w + a*gamma*kappa)) - a*gamma*(gamma + gamma*s_w + a*gamma*kappa))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -(a*gamma*(eta + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )


grad = rowshape(grad,12)

pV=invsym(grad'*iV*grad)

			 
mt=( (eta - a + 1)/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, -(lambda - a*lambda + eta*lambda - lambda*s_f + lambda_z*s_f + a*lambda*s_f - a*lambda_z*s_f - epsilon*lambda*s_f - eta*lambda*s_f + eta*lambda_z*s_f + a*epsilon*lambda*s_f + a*eta*lambda_h*s_f - epsilon*eta*lambda*s_f + a*eta*gamma*lambda_h - a*eta*gamma*lambda_h*s_f - a*epsilon*eta*gamma*lambda_h*s_f)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, -((gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (a + s_w + eta*s_w)/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, (a*lambda*s_f - lambda*s_w - a*lambda - a*lambda_z*s_f - eta*lambda*s_w + lambda*s_f*s_w - lambda_z*s_f*s_w + a*epsilon*lambda*s_f + a*eta*lambda_h*s_f + epsilon*lambda*s_f*s_w + eta*lambda*s_f*s_w - eta*lambda_z*s_f*s_w + epsilon*eta*lambda*s_f*s_w)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (s_f*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (s_w + 1)/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, (lambda*s_f - lambda - lambda_z*s_f - lambda*s_w + epsilon*lambda*s_f + eta*lambda_h*s_f + lambda*s_f*s_w - lambda_z*s_f*s_w + eta*gamma*lambda_h*s_w + epsilon*lambda*s_f*s_w + eta*lambda_h*s_f*s_w - eta*gamma*lambda_h*s_f*s_w - epsilon*eta*gamma*lambda_h*s_f*s_w)/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (s_f*(eta + 1)*(s_w + 1) + a*s_f*(s_w + 1)*(kappa + eta*kappa - 1))/((a + s_w + eta*s_w)*(s_f + eta*s_f + s_f*s_w - gamma*(a*s_f - s_w - a - eta*s_w + s_f*s_w + a*epsilon*s_f + epsilon*s_f*s_w + eta*s_f*s_w + epsilon*eta*s_f*s_w) + eta*s_f*s_w)) - (s_w - kappa*s_w - eta*kappa*s_w + 1)/(a + s_w + eta*s_w) )
mt=(mt, 1/(s_f + epsilon*s_f - 1) - ((eta + 1)*(s_w + 1))/((epsilon + 1)*(s_f + epsilon*s_f - 1)*(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, -(lambda + eta*lambda + lambda*s_w - a*gamma*lambda_z + eta*lambda*s_w - gamma*lambda_z*s_w - eta*gamma*lambda_z*s_w + a*eta*gamma*lambda_h)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, -(gamma*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )

			 
mt = -mt		 
		 
		st_replacematrix("mt",mt)		 
		st_replacematrix("Q",chi)
		st_replacematrix("rb",p)
		st_replacematrix("rV",pV)		
	}
void i_crit(todo,b,crit,g,H)
	{ 
		external pi, iV, gamma, epsilon, alpha

		m = J(1,8,0)
		
		c=b
//		c[1] = exp(c[1])
	//	c[2] = invlogit(c[2])
	//	c[8] = invlogit(c[8])		
//		c[3]=exp(c[3])
	
		c = (c,epsilon,gamma)
		s_f = c[1]
		s_w = c[2]
		eta = c[3]
		lambda = c[4] 	
		lambda_h = c[5] 				
		lambda_z = c[6] 							
		epsilon = c[8]
		gamma = c[9]		
		kappa = c[7]
		a=alpha	
		els = ((1+eta)-a)/(s_w*(1+eta)+a)	
		eld = (gamma*(epsilon+1-1/s_f)-1)	
		tw = (-1/((epsilon+1)*s_f))/(els - eld )		
		
mt=( (eta - a + 1)/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, -(lambda - a*lambda + eta*lambda - lambda*s_f + lambda_z*s_f + a*lambda*s_f - a*lambda_z*s_f - epsilon*lambda*s_f - eta*lambda*s_f + eta*lambda_z*s_f + a*epsilon*lambda*s_f + a*eta*lambda_h*s_f - epsilon*eta*lambda*s_f + a*eta*gamma*lambda_h - a*eta*gamma*lambda_h*s_f - a*epsilon*eta*gamma*lambda_h*s_f)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, -((gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (a + s_w + eta*s_w)/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, (a*lambda*s_f - lambda*s_w - a*lambda - a*lambda_z*s_f - eta*lambda*s_w + lambda*s_f*s_w - lambda_z*s_f*s_w + a*epsilon*lambda*s_f + a*eta*lambda_h*s_f + epsilon*lambda*s_f*s_w + eta*lambda*s_f*s_w - eta*lambda_z*s_f*s_w + epsilon*eta*lambda*s_f*s_w)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (s_f*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (s_w + 1)/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, (lambda*s_f - lambda - lambda_z*s_f - lambda*s_w + epsilon*lambda*s_f + eta*lambda_h*s_f + lambda*s_f*s_w - lambda_z*s_f*s_w + eta*gamma*lambda_h*s_w + epsilon*lambda*s_f*s_w + eta*lambda_h*s_f*s_w - eta*gamma*lambda_h*s_f*s_w - epsilon*eta*gamma*lambda_h*s_f*s_w)/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, (s_f*(eta + 1)*(s_w + 1) + a*s_f*(s_w + 1)*(kappa + eta*kappa - 1))/((a + s_w + eta*s_w)*(s_f + eta*s_f + s_f*s_w - gamma*(a*s_f - s_w - a - eta*s_w + s_f*s_w + a*epsilon*s_f + epsilon*s_f*s_w + eta*s_f*s_w + epsilon*eta*s_f*s_w) + eta*s_f*s_w)) - (s_w - kappa*s_w - eta*kappa*s_w + 1)/(a + s_w + eta*s_w) )
mt=(mt, 1/(s_f + epsilon*s_f - 1) - ((eta + 1)*(s_w + 1))/((epsilon + 1)*(s_f + epsilon*s_f - 1)*(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)) )
mt=(mt, -(lambda + eta*lambda + lambda*s_w - a*gamma*lambda_z + eta*lambda*s_w - gamma*lambda_z*s_w - eta*gamma*lambda_z*s_w + a*eta*gamma*lambda_h)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
mt=(mt, -(gamma*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )

mt = -mt	

m = (pi-mt)'		
crit = m'*iV*m		 				

				if (todo == 1) { 

grad=( (gamma*((a + s_w + eta*s_w)*(eta - a + 1) + epsilon*(a + s_w + eta*s_w)*(eta - a + 1)) - (eta - a + 1)*(eta + s_w + eta*s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -((eta + 1)*(eta - a + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*(gamma*(s_w + 1) - s_f*(s_w + 1)*(gamma + epsilon*gamma - 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, ((eta - a + 1)*(lambda + eta*lambda - a*gamma*lambda_z + a*eta*gamma*lambda_h) + s_w*(eta - a + 1)*(lambda + eta*lambda - gamma*lambda_z - eta*gamma*lambda_z))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((eta + 1)^2*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda - lambda*s_f + lambda_z*s_f - epsilon*lambda*s_f) - a*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda - lambda*s_f + lambda_z*s_f - eta*gamma*lambda_h - epsilon*lambda*s_f - eta*lambda_h*s_f + eta*gamma*lambda_h*s_f + epsilon*eta*gamma*lambda_h*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(a*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f + a*gamma*lambda_h - epsilon*lambda*s_f - a*gamma*lambda_h*s_f - a*epsilon*gamma*lambda_h*s_f) + a*s_w*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(lambda + gamma*lambda_h - lambda*s_f + lambda_h*s_f + lambda_z*s_f - epsilon*lambda*s_f - gamma*lambda_h*s_f - epsilon*gamma*lambda_h*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_f + epsilon*s_f - 1)*(eta - a + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(a*eta*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(s_f*(eta - a + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*(eta - a + 1)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f - a*gamma*s_f + s_w*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f) - a*epsilon*gamma*s_f)^2 )
grad=(grad, ((eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)^2*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(a*s_w*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)^2 - a*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(gamma*s_f - s_f - gamma - a*gamma*kappa + epsilon*gamma*s_f + a*gamma*kappa*s_f + a*epsilon*gamma*kappa*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -(a*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (gamma*(epsilon + 1)*(a + s_w + eta*s_w)^2 - (eta + 1)*(s_w + 1)*(a + s_w + eta*s_w))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (s_f*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(a*s_f*(s_w + 1))/((epsilon + 1)*(s_f + eta*s_f + s_f*s_w - gamma*(s_f + epsilon*s_f - 1)*(a + s_w + eta*s_w) + eta*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -(gamma*(a + s_w + eta*s_w)*(a*lambda_z + lambda_z*s_w - a*eta*lambda_h + eta*lambda_z*s_w) - lambda*(eta + 1)*(s_w + 1)*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(a*(s_f*(eta + 1)*(lambda*s_f - lambda - lambda_z*s_f + epsilon*lambda*s_f + eta*lambda_h*s_f) - gamma*s_f*(eta + 1)*(eta*lambda_h*s_f - eta*lambda_h + epsilon*eta*lambda_h*s_f)) + s_f*(eta + 1)*(lambda + eta*lambda - lambda*s_f + lambda_z*s_f - epsilon*lambda*s_f - eta*lambda*s_f + eta*lambda_z*s_f - epsilon*eta*lambda*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (a*s_f*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f - epsilon*lambda*s_f) - gamma*(a*s_f*(a*lambda_h*s_f - a*lambda_h + a*epsilon*lambda_h*s_f) + a*s_f*s_w*(lambda_h*s_f - lambda_h + epsilon*lambda_h*s_f)) + a*s_f*s_w*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f - epsilon*lambda*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_f + epsilon*s_f - 1)*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (a*eta*s_f)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(s_f*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*(a + s_w + eta*s_w)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(s_f*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(gamma*(a*s_f*(s_f - s_w - a*kappa + s_f*s_w + a*kappa*s_f - 1) + a*epsilon*s_f*(s_f + s_f*s_w + a*kappa*s_f)) - a*s_f*(s_f + s_f*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, (a*s_f*(eta + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -((s_w + 1)^2 - gamma*((s_w + epsilon*s_w)*(s_w + 1) + a*(epsilon + 1)*(s_w + 1)) + eta*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (gamma*(s_f + epsilon*s_f - 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(s_f*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)) + gamma*s_w*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, ((s_w + 1)*(lambda + eta*lambda + lambda*s_w + eta*lambda*s_w) - gamma*((lambda_z*s_w + eta*lambda_z*s_w)*(s_w + 1) + a*(s_w + 1)*(lambda_z - eta*lambda_h)))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(gamma*(s_f + epsilon*s_f - 1)*(lambda - a*lambda - lambda*s_f + lambda_z*s_f + a*lambda*s_f - a*lambda_z*s_f - epsilon*lambda*s_f + a*epsilon*lambda*s_f) + eta*gamma*(s_f + epsilon*s_f - 1)*(lambda - lambda*s_f + lambda_z*s_f + a*gamma*lambda_h + a*lambda_h*s_f - epsilon*lambda*s_f - a*gamma*lambda_h*s_f - a*epsilon*gamma*lambda_h*s_f))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w)*(lambda - lambda*s_f + lambda_h*s_f + lambda_z*s_f + lambda*s_w + a*gamma*lambda_h - epsilon*lambda*s_f + gamma*lambda_h*s_w - lambda*s_f*s_w + lambda_h*s_f*s_w + lambda_z*s_f*s_w - a*gamma*lambda_h*s_f - epsilon*lambda*s_f*s_w - gamma*lambda_h*s_f*s_w - a*epsilon*gamma*lambda_h*s_f - epsilon*gamma*lambda_h*s_f*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_w + 1)*(s_f + epsilon*s_f - 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (eta*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w))/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(s_f*(s_w + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*((eta + 1)*(s_w + 1) + a*(s_w + 1)*(kappa + eta*kappa - 1)))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -(gamma*(s_f + epsilon*s_f - 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, ((s_w + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w) - a*gamma*kappa*(s_f + epsilon*s_f - 1)*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, ((eta + 1)*(s_f + gamma*s_w + s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w))/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(a*gamma - s_w - eta - eta*s_w + gamma*s_w + a*epsilon*gamma + epsilon*gamma*s_w + eta*gamma*s_w + epsilon*eta*gamma*s_w - 1)^2/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(gamma*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*gamma*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -((lambda + eta*lambda + lambda*s_w - a*gamma*lambda_z + eta*lambda*s_w - gamma*lambda_z*s_w - eta*gamma*lambda_z*s_w + a*eta*gamma*lambda_h)*(a*gamma - s_w - eta - eta*s_w + gamma*s_w + a*epsilon*gamma + epsilon*gamma*s_w + eta*gamma*s_w + epsilon*eta*gamma*s_w - 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (a*(s_f*(gamma*(eta + 1)*(lambda - lambda_z + eta*lambda_h - eta*gamma*lambda_h) + epsilon*gamma*(lambda - eta*gamma*lambda_h)*(eta + 1)) - gamma*(lambda - eta*gamma*lambda_h)*(eta + 1)) - s_f*(gamma*(eta + 1)*(lambda - lambda_z + eta*lambda - eta*lambda_z) + epsilon*gamma*(eta + 1)*(lambda + eta*lambda)) + gamma*(eta + 1)*(lambda + eta*lambda))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (s_f*(a*gamma*(lambda - lambda_h - lambda_z + a*gamma*lambda_h) + a*epsilon*gamma*(lambda + a*gamma*lambda_h)) + s_w*(s_f*(a*gamma*(lambda - lambda_h - lambda_z + gamma*lambda_h) + a*epsilon*gamma*(lambda + gamma*lambda_h)) - a*gamma*(lambda + gamma*lambda_h)) - a*gamma*(lambda + a*gamma*lambda_h))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, -((eta + 1)*(s_w + 1))/(s_f + eta*s_f + gamma*s_w + s_f*s_w - a*(gamma*s_f - gamma + epsilon*gamma*s_f) + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, -(a*eta*gamma)/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, (gamma*(a + s_w + eta*s_w))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )
grad=(grad, 0 )
grad=(grad, (gamma*(eta - a*gamma - a*epsilon*gamma + 1)*(eta - a + a*kappa + a*eta*kappa + 1) - gamma*s_w*(eta + 1)*(gamma + epsilon*gamma - 1)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (gamma*(eta + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(eta - a + a*kappa + a*eta*kappa + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, (s_f*(a*gamma*(gamma - s_w + gamma*s_w + a*gamma*kappa - 1) + a*epsilon*gamma*(gamma + gamma*s_w + a*gamma*kappa)) - a*gamma*(gamma + gamma*s_w + a*gamma*kappa))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, 0 )
grad=(grad, -(a*gamma*(eta + 1))/(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w) )

				
grad = rowshape(grad,12)

			g = 2*m'*iV*grad
		
//			g[1]=g[1]*c[1]		
//			g[3]=g[3]*c[3]				
		
				}
		
		
	} 		
	
end

}

/***************************

***** Post Moments
set more off
cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.3)

/* Test of Elasticity of housing supply  

. nlcom 1/(1+_b[eta])

       _nl_1:  1/(1+_b[eta])

------------------------------------------------------------------------------
        many |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
       _nl_1 |   .6610513   .6193895     1.07   0.286    -.5529298    1.875032
------------------------------------------------------------------------------



*/ 

scalar N = 1470
scalar name = "one"
postmoments3

esttab moment* using "$tablepath/moments_tax_6_091815.csv", ///
 se(3) b(3) replace star(* 0.10 ** 0.05 *** 0.01) stat(Chi ChiPval ATest_TStat ATest_pval) mtitles("Empirical" "Predicted")

*** Structural Table
cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_1

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.5)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_2

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.65)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_3

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.2) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_4

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.25) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_5

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-4) gamma(.15) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_6

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-4) gamma(.25) alpha(.5)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_7


esttab est_* using "$tablepath/struct_tax_6_091815.csv", ///
b(3) se(3) replace star(* 0.10 ** 0.05 *** 0.01) stat(Q pval gamma epsilon alpha p_joint)



***************************/
cd "$graphpath"

***********
* Heat Maps 
* 1- epsilon and gamma 
*********		
capture drop x_e y_* z_*
gen x_epsilon = . 
gen y_gamma = . 
gen z_chi2 = . 
gen z_pval = . 
gen z_pi = . 
gen z_workers = . 
gen z_land = . 

set more off 
local count = 1
forval  g = 0(.1).5 { 
	forval  e = 2(.5)5 { 
		
		scalar pi_n = 999
		scalar w_n = 999
		scalar l_n = 999
		scalar chi2 = 999
		scalar pval = 999
		
		replace x_epsilon = -`e' if _n == `count'
		replace y_gamma = `g' if _n == `count'	
		capture: cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
		cluster(state_fips) epsilon(-`e') gamma(`g') alpha(.3)
		capture: mat b = e(b)
		capture: scalar pi_n = b[1,18]
		capture: scalar w_n = b[1,17]		
		capture: scalar l_n = b[1,16]	
		capture: scalar chi2 = e(Q)
		capture: scalar pval = e(pval)
		
		replace z_chi2 =   chi2 if _n == `count'
		replace z_pval =  pval if _n == `count'
		replace z_pi =  pi_n if _n == `count'		
		replace z_workers =  w_n if _n == `count'
		replace z_land =  l_n if _n == `count'		
		
		local count = `count'+1
		di `count'
		est clear 
		scalar drop _all 
		ereturn clear 
	} 	
} 

replace z_pi = . if z_pval == . 

twoway (contour z_pi x_epsilon y_gamma if z_pi !=. , int(shep) ///
ccuts(0.30 0.4 0.5  0.6  0.7  0.8  0.9) ), ///
text(-2.45 .15 "{bf:*}") ///
text(-2.45 .19 "{bf: Baseline}") ///
graphregion(fcolor(white)) graphregion(color(white)) xtitle("Output Elasticity of Labor: {&gamma}") ytitle("Elasticity of Product Demand: {&epsilon}{superscript:PD}") ztitle("Share to Firm Owners") 

graph export "$CMD_graphpath/contour_pi_091815.pdf", replace



replace z_workers = . if z_pval == . 
twoway (contour z_workers x_epsilon y_gamma if z_pi !=. , int(shep) ///
ccuts(0.30 0.4 0.5  0.6  0.7  0.8  0.9) ), ///
text(-2.45 .15 "{bf:*}") ///
text(-2.45 .19 "{bf: Baseline}") ///
graphregion(fcolor(white)) graphregion(color(white)) xtitle("Output Elasticity of Labor: {&gamma}") ytitle("Elasticity of Product Demand: {&epsilon}{superscript:PD}") ztitle("Share to Workers") 
graph export "$CMD_graphpath/contour_w_091815.pdf", replace

replace z_land = . if z_pval == . 
twoway (contour z_land x_epsilon y_gamma if z_pi !=. , int(shep) ///
ccuts(0.30 0.4 0.5  0.6  0.7  0.8  0.9) ), ///
text(-2.45 .15 "{bf:*}") ///
text(-2.45 .19 "{bf: Baseline}") ///
graphregion(fcolor(white)) graphregion(color(white)) xtitle("Output Elasticity of Labor: {&gamma}") ytitle("Elasticity of Product Demand: {&epsilon}{superscript:PD}") ztitle("Share to Land Owners") 
graph export "$CMD_graphpath/contour_l_091815.pdf", replace



***********
* Contour for Alpha and epsilon
*********		
capture drop x_e y_* z_*
gen x_epsilon = . 
gen y_gamma = . 
gen z_chi2 = . 
gen z_pval = . 
gen z_pi = . 
gen z_workers = . 
gen z_land = . 

set more off 
local count = 1
forval  g = 0.(.1)1 { 
	forval  e = 2(.5)5 { 
		
		scalar pi_n = 999
		scalar w_n = 999
		scalar l_n = 999
		scalar chi2 = 999
		scalar pval = 999
		
		replace x_epsilon = -`e' if _n == `count'
		replace y_gamma = `g' if _n == `count'		
		capture: cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2  bartik d_esrate  _Iy* _Ife*  [aw=epop], ///
		cluster(state_fips) epsilon(-`e') gamma(.15) alpha(`g')
		capture: mat b = e(b)
		capture: scalar pi_n = b[1,18]
		capture: scalar w_n = b[1,17]		
		capture: scalar l_n = b[1,16]	
		capture: scalar chi2 = e(Q)
		capture: scalar pval = e(pval)
		
		replace z_chi2 =   chi2 if _n == `count'
		replace z_pval =  pval if _n == `count'
		replace z_pi =  pi_n if _n == `count'		
		replace z_workers =  w_n if _n == `count'
		replace z_land =  l_n if _n == `count'		
		
		local count = `count'+1
		di `count'
		est clear 
		scalar drop _all 
		ereturn clear 
	} 	
} 

replace z_pi = . if z_pval == . 

twoway (contour z_pi x_epsilon y_gamma if z_pi != . ,  int(shep) ccuts(.2  0.30 0.4  0.5  0.6  0.7 ) ) , ///
text(-2.5 .3 "{bf:*}") ///
text(-2.5 .4 "{bf: Baseline}") ///
graphregion(fcolor(white)) graphregion(color(white)) ///
xtitle("Housing Expenditure Share: {&alpha}") ///
ytitle("Elasticity of Product Demand: {&epsilon}{superscript:PD}") ztitle("Share to Firm Owners") 

graph export "$CMD_graphpath/contour_alpha_pi_091815.pdf", replace


replace z_workers = . if z_pval == . 
twoway (contour z_workers x_epsilon y_gamma if z_pi !=. , int(shep) ///
ccuts(0.30 0.4 0.5  0.6  0.7  0.8  0.9) ), ///
text(-2.45 .15 "{bf:*}") ///
text(-2.45 .19 "{bf: Baseline}") ///
graphregion(fcolor(white)) graphregion(color(white)) xtitle("Housing Expenditure Share: {&alpha}") ///
ytitle("Elasticity of Product Demand: {&epsilon}{superscript:PD}") ztitle("Share to Workers") 
graph export "$CMD_graphpath/contour_alpha_w_091815.pdf", replace

replace z_land = . if z_pval == . 
twoway (contour z_land x_epsilon y_gamma if z_pi !=. , int(shep) ///
ccuts(0.30 0.4 0.5  0.6  0.7  0.8  0.9) ), ///
text(-2.45 .15 "{bf:*}") ///
text(-2.45 .19 "{bf: Baseline}") ///
graphregion(fcolor(white)) graphregion(color(white)) xtitle("Housing Expenditure Share: {&alpha}") ///
ytitle("Elasticity of Product Demand: {&epsilon}{superscript:PD}") ztitle("Share to Land Owners") 
graph export "$CMD_graphpath/contour_alpha_l_091815.pdf", replace
