cd "$dopath"
clear all
set mem 100m
set matsize 800
set more off

do CMD/postmoments_simple.ado

use "$dtapath/CMD/ILS_1_shocks_3_parm.dta", clear  

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
	// FEs 
	    local x `*'
	    
	    scalar epsilon = `epsilon'
	    scalar gamma = `gamma'	
		scalar alpha = `alpha'	

		reg `dpop' `dtax' `x' [`weight' `exp']
		est sto `dpop'
		reg `dwage' `dtax' `x' [`weight' `exp']
		est sto `dwage'
		reg `drent' `dtax' `x' [`weight' `exp']
		est sto `drent'
		reg `dest' `dtax' `x' [`weight' `exp']
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
			} 
		mat pi = pi[1,2...]
		mat mt = pi*0
		
		mat li pi
		
		mat V = (0)
		forval i = 1/4 { 
			forval j = 1/4 { 
				mat V = (V,Vt[(`i'-1)*s_k+1,(`j'-1)*s_k+1])
			}
		}
				
		mat V = V[1,2...]
		
		mata: st_matrix("V", rowshape( st_matrix("V")', 4) )
		mat li V 
		
		local N = e(N) 
		
		mat theta = (5,1,2)

		mat rb= J(1,3,0)
		mat rV = J(3,3,0)
		mat Q = 0 

		mata: mycmd(st_matrix("theta"))

		scalar Q = el(Q,1,1)
		scalar Qdof =1
		scalar pval = 1 - chi2(Qdof,Q)
		
		matrix colnames rb = sigma_F sigma_W eta
		matrix colnames rV = sigma_F sigma_W eta
		matrix rownames rV = sigma_F sigma_W eta

		ereturn post rb rV, obs(`N')

		mat rb = (e(b),J(1,11,0))
		mat rV = (e(V),J(3,11,0) \ J(11,14,0) ) 

qui { 
		local eld "(gamma*(epsilon+1-1/_b[sigma_F])-1)" 		
		local els "((1+_b[eta]-alpha)/(_b[sigma_W]*(1+_b[eta])+alpha)) " 		
		local tw  "((-1/((epsilon+1)*_b[sigma_F]))/( `els'-`eld' ))" 
		local tr "((1+`els')/(1+_b[eta]))*`tw'"
		local trw "(`tw'-alpha*`tr')"
//		local tpi "(1-(1-gamma)*(epsilon+1)+ gamma*(epsilon+1)*`tw' ) "
// For intermediiate goods
		local tpi "((1-0.9*gamma*(epsilon+1) + gamma*(epsilon+1)*`tw' ) )"		
		local tot_w "(`tr'+`trw'+`tpi')"
		local s_land "`tr'/`tot_w'"
		local s_work "`trw'/`tot_w'"
		local s_firm "`tpi'/`tot_w'"		

		// Micro elas 
		nlcom 1/_b[sigma_W] 		
		mat rb[1,4] = r(b)
		mat rV[4,4] = r(V)
		// Macro elas 
		nlcom `els' 		
		mat rb[1,5] = r(b)
		mat rV[5,5] = r(V)
		// Micro elas 
		nlcom gamma*(epsilon+1)-1 		
		mat rb[1,6] = r(b)
		mat rV[6,6] = r(V)
		// Macro elas 
		nlcom `eld' 		
		mat rb[1,7] = r(b)
		mat rV[7,7] = r(V)
		// tilde w  
		nlcom `tw'
		mat rb[1,8] = r(b)
		mat rV[8,8] = r(V)
		// tilde r  
		nlcom `tr'
		mat rb[1,9] = r(b)
		mat rV[9,9] = r(V)
		// tilde rw  
		nlcom `trw'
		mat rb[1,10] = r(b)
		mat rV[10,10] = r(V)
		// tilde pi  
		nlcom `tpi'
		mat rb[1,11] = r(b)
		mat rV[11,11] = r(V)
		// share to land 
		nlcom `s_land'
		mat rb[1,12] = r(b)
		mat rV[12,12] = r(V)
		// share to workers 
		nlcom `s_work'
		mat rb[1,13] = r(b)
		mat rV[13,13] = r(V)
		// share to firms 
		nlcom `s_firm'
		mat rb[1,14] = r(b)
		mat rV[14,14] = r(V)

		matrix colnames rb = sigma_f sigma_w eta  micro_els macro_els  micro_eld macro_eld tilde_w tilde_r tilde_r_w tilde_pi share_L share_W share_F
		matrix colnames rV = sigma_f sigma_w eta  micro_els macro_els  micro_eld macro_eld tilde_w tilde_r tilde_r_w tilde_pi share_L share_W share_F
		matrix rownames rV = sigma_f sigma_w eta  micro_els macro_els  micro_eld macro_eld tilde_w tilde_r tilde_r_w tilde_pi share_L share_W share_F

}
		ereturn post rb rV, obs(`N')

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
		external pi, iV, epsilon, gamma, alpha

		gamma = st_numscalar("gamma")		
		alpha = st_numscalar("alpha")		
		epsilon = st_numscalar("epsilon")
		pi = st_matrix("pi") 	
		V = st_matrix("V")
		iV = cholinv(V)
//		iV = diag(J(1,4,1))
		init = st_matrix("theta")
		S = optimize_init()
		optimize_init_evaluator(S, &i_crit()) 
		optimize_init_which(S, "min") 
		optimize_init_evaluatortype(S, "d1") 
		optimize_init_params(S, init)
		optimize_init_conv_warning(S, "on")		
//		optimize_init_technique(S, "bfgs 10 dfp 10 ")
		optimize_init_technique(S, "nm 10")
		optimize_init_nmsimplexdeltas(S,0.50*J(1,cols(3),1))
		p = optimize(S)
	
		p
	
		chi=optimize_result_value(S)
		chi = (chi) 
	//	chi 
	
		gra = J(3,4,0) 

		c=p
	//	c[1]=exp(c[1])
	//	p=c
		
		c = (c,epsilon,gamma)
		a=alpha
		els = ((1+c[3])-a)/(c[2]*(1+c[3])+a)	
		eld = (c[5]*(c[4]+1-1/c[1])-1)	
		tw = (-1/((c[4]+1)*c[1]))/(els - eld )
		eta = c[3]
		
		s_w = c[2]
		s_f = c[1]


grad=( (gamma*((a + s_w + eta*s_w)*(eta - a + 1) + epsilon*(a + s_w + eta*s_w)*(eta - a + 1)) - (eta - a + 1)*(eta + s_w + eta*s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, ((eta - a + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(gamma + s_f + eta*gamma + eta*s_f - gamma*s_f - epsilon*gamma*s_f - eta*gamma*s_f - epsilon*eta*gamma*s_f))/(s_f*(gamma*(epsilon - 1/s_f + 1) - 1)*(epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*(gamma*(s_w + 1) - s_f*(s_w + 1)*(gamma + epsilon*gamma - 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (gamma*(epsilon + 1)*(a + s_w + eta*s_w)^2 - (eta + 1)*(s_w + 1)*(a + s_w + eta*s_w))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (s_f*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(a*s_f*(s_w + 1))/((epsilon + 1)*(s_f + eta*s_f + s_f*s_w - gamma*(s_f + epsilon*s_f - 1)*(a + s_w + eta*s_w) + eta*s_f*s_w)^2) )
grad=(grad, -((s_w + 1)^2 - gamma*((s_w + epsilon*s_w)*(s_w + 1) + a*(epsilon + 1)*(s_w + 1)) + eta*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (gamma*(s_f + epsilon*s_f - 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(s_f*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)) + gamma*s_w*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(a*gamma - s_w - eta - eta*s_w + gamma*s_w + a*epsilon*gamma + epsilon*gamma*s_w + eta*gamma*s_w + epsilon*eta*gamma*s_w - 1)^2/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(gamma*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*gamma*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
		
		
grad = rowshape(grad,4)
//grad
gra = grad'
//gra


		pV=cholinv(gra*iV*gra')
		 
		pV 
		
	mt = -(-(eta - a + 1)/(s_f*(epsilon + 1)*(a - eta + a*eld + eld*s_w + eld*eta*s_w - 1)) , //
		-(a + s_w + eta*s_w)/(s_f*(epsilon + 1)*(a - eta + a*eld + eld*s_w + eld*eta*s_w - 1)) , //
		-(s_w + 1)/(s_f*(epsilon + 1)*(a - eta + a*eld + eld*s_w + eld*eta*s_w - 1))		   , //
		1/(s_f*(epsilon + 1)) + (gamma*(a + s_w + eta*s_w))/(s_f*(epsilon + 1)*(a*s_f - s_f - eta*s_f + a*eld*s_f + eld*s_f*s_w + eld*eta*s_f*s_w)) )
		
		st_replacematrix("mt",mt)		 	 
		st_replacematrix("Q",chi)
		st_replacematrix("rb",p)
		st_replacematrix("rV",pV)		
	}
void i_crit(todo,b,crit,g,H)
	{ 
		external pi, iV, epsilon, gamma, alpha
		m = J(1,4,0)

		c=b	
		c = (c,epsilon,gamma)
	//	c[1]=exp(c[1])
		a=alpha
		els = ((1+c[3])-a)/(c[2]*(1+c[3])+a)	
		eld = (c[5]*(c[4]+1-1/c[1])-1)	
		tw = (-1/((c[4]+1)*c[1]))/(els - eld )
		eta = c[3]
		
		s_w = c[2]
		s_f = c[1]

		mt = (-(eta - a + 1)/(s_f*(epsilon + 1)*(a - eta + a*eld + eld*s_w + eld*eta*s_w - 1)) , //
			 -(a + s_w + eta*s_w)/(s_f*(epsilon + 1)*(a - eta + a*eld + eld*s_w + eld*eta*s_w - 1)) , //
			 -(s_w + 1)/(s_f*(epsilon + 1)*(a - eta + a*eld + eld*s_w + eld*eta*s_w - 1))		   , //
				1/(s_f*(epsilon + 1)) + (gamma*(a + s_w + eta*s_w))/(s_f*(epsilon + 1)*(a*s_f - s_f - eta*s_f + a*eld*s_f + eld*s_f*s_w + eld*eta*s_f*s_w)) )

				
				
		m = pi+mt		
		
		//m[2]=0
	//	pi 
	//	-m+pi
	
		crit = m*iV*m'  		 		

				if (todo == 1) { 

grad=( (gamma*((a + s_w + eta*s_w)*(eta - a + 1) + epsilon*(a + s_w + eta*s_w)*(eta - a + 1)) - (eta - a + 1)*(eta + s_w + eta*s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, ((eta - a + 1)*(gamma + s_f - gamma*s_f - epsilon*gamma*s_f)*(gamma + s_f + eta*gamma + eta*s_f - gamma*s_f - epsilon*gamma*s_f - eta*gamma*s_f - epsilon*eta*gamma*s_f))/(s_f*(gamma*(epsilon - 1/s_f + 1) - 1)*(epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*(gamma*(s_w + 1) - s_f*(s_w + 1)*(gamma + epsilon*gamma - 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (gamma*(epsilon + 1)*(a + s_w + eta*s_w)^2 - (eta + 1)*(s_w + 1)*(a + s_w + eta*s_w))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (s_f*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(a*s_f*(s_w + 1))/((epsilon + 1)*(s_f + eta*s_f + s_f*s_w - gamma*(s_f + epsilon*s_f - 1)*(a + s_w + eta*s_w) + eta*s_f*s_w)^2) )
grad=(grad, -((s_w + 1)^2 - gamma*((s_w + epsilon*s_w)*(s_w + 1) + a*(epsilon + 1)*(s_w + 1)) + eta*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (gamma*(s_f + epsilon*s_f - 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(s_f*((s_w + 1)^2 - gamma*(s_w + epsilon*s_w)*(s_w + 1)) + gamma*s_w*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(a*gamma - s_w - eta - eta*s_w + gamma*s_w + a*epsilon*gamma + epsilon*gamma*s_w + eta*gamma*s_w + epsilon*eta*gamma*s_w - 1)^2/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, -(gamma*(eta + 1)*(eta - a + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
grad=(grad, (a*gamma*(s_w + 1))/((epsilon + 1)*(s_f + a*gamma + eta*s_f + gamma*s_w + s_f*s_w - a*gamma*s_f + eta*gamma*s_w + eta*s_f*s_w - gamma*s_f*s_w - a*epsilon*gamma*s_f - epsilon*gamma*s_f*s_w - eta*gamma*s_f*s_w - epsilon*eta*gamma*s_f*s_w)^2) )
		
				
grad = rowshape(grad,4)

			g = 2*m*iV*grad
			
		//	g[1]=g[1]*c[1]
				
				}
		
		
	} 		
	
end

***** Post Moments
set more off
cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2 _Iy* _Ife*  [aw=epop], cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.3)
scalar N = 1470
scalar name = "one"
postmoments_simple 

esttab moment* using "$CMD_tablepath/moments_tax_3.csv", ///
 se(3) b(3) replace star(* 0.10 ** 0.05 *** 0.01) stat(Chi ChiPval ATest_TStat ATest_pval) mtitles("Empirical" "Predicted")

*** Structural Table
cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2 _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_1

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2 _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.15) alpha(.65)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_2

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2 _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-2.5) gamma(.25) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_3

cmdestjoint dest dpop dadjlrent dadjlwage d_bus_dom2 _Iy* _Ife*  [aw=epop], ///
cluster(state_fips) epsilon(-4) gamma(.15) alpha(.3)
test (share_F == 0) (share_W == 1) 
estadd scalar p_joint = r(p)
est sto est_4

esttab est_* using "$CMD_tablepath/struct_tax_3.csv", ///
b(3) se(3) replace star(* 0.10 ** 0.05 *** 0.01) stat(Q pval gamma epsilon alpha p_joint)

