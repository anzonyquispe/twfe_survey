capture program drop newSwitch
program newSwitch
	version 8.2
	args lnf xb1 xb2 xb3 lns1 lns2 theta1 theta2 
	
	quietly {

	tempvar L_s L_n L_c sig1 sig2 rho1 rho2 rr1 rr2

	gen double `sig1' 	= exp(`lns1')
	gen double `sig2' 	= exp(`lns2')
	gen double `rho1' 	= tanh(`theta1')
	gen double `rho2' 	= tanh(`theta2')
	gen double `rr1'	= 1/sqrt(1-`rho1'^2)
	gen double `rr2'	= 1/sqrt(1-`rho2'^2)

	tempvar eps1 eps2 eta1 eta2 lf1 const1 const2
	generate double `eps1' = $ML_y1 - `xb1'
	generate double `eps2' = $ML_y1 - `xb2'

	generate double `eta1' = (`xb3' +  `eps1' * `rho1'/`sig1')*`rr1' 
	generate double `eta2' = (`xb3' +  `eps2' * `rho2'/`sig2')*`rr2'
	replace `eta1'=-37 if (`eta1'<-37)
	replace `eta2'= 37 if (`eta2'> 37)

	generate double `const1'=0.5*ln(2*_pi*`sig1'^2)
	generate double `const2'=0.5*ln(2*_pi*`sig2'^2) 

	generate double `L_s' = ln(norm(`eta1'))-`const1'-0.5*(`eps1'/`sig1')^2
	generate double `L_n' = ln(norm(-`eta2'))-`const2'-0.5*(`eps2'/`sig2')^2
	generate double `L_c' = ln(binorm(`xb3',-`eps1'/`sig1',`rho1') + binorm(-`xb3',-`eps2'/`sig2',-`rho2'))

	** exiType Variable categorizes data
	replace `lnf' =  `L_s'
	replace `lnf' =  `L_n' if (exiType == 3)
	replace `lnf' =  ln(exp(`L_s') + exp(`L_n')) if (exiType == 2)
	replace `lnf' =  `L_c' if (exiType == 1)	
	}
end



