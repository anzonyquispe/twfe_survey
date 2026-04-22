*************************************************************************
* Estimation algorithm for estimation of production function by Olley-Pakes 1996
* Series version 
*
* version h
*
* Thomas Buettner 5/11/03 (preliminary)
*
*
*
* global macros required as inputs:
* 
*	THROUGHOUT:
* 	
*	if		IF statement to be included in all estimation commands
*	opqui		=1 if only summary output is to be displayed
*
*	STAGE 1:	OLS with series expansions
*
*	s1y		dependent variable stage 1	(value added)	
*	s1x		independent variables of interest for stage 1 (other than series terms)
*			these DO NOT enter the estimate of `phi' in later stages
*	s1x2		other linear variables that DO NOT enter the estimate of `phi'. 
*			(will be treated as variables of interest but parameters will not be saved)
*	s1x3		other linear variables that DO enter the estimate of `phi' linearly.
*			(parameters will not be saved)
*
*	s1var 	varlist for series expansion for stage 1 for the estimate of `phi'
*	s1o		order of series expansion for stage 1
* 
*
*	STAGE 2:	PROBIT to control for selection bias
*	
*	opselect	=0 if selection stage is NOT required
*			=1 for series expansion or order s2o in variables in macro s2var
*			=2 for series expansion of order s2o in 'phi' and macro s3x
*	s2y		dependent variable for stage 2 probit regressions
*	s2x		independent variables other than series terms (e.g. time dummies)
*	s2var		valist for series expansion for stage 2
*	s2o		order of series expansion for stage 2
*
*
*	STAGE 3:    NLLS to recover parameters of quasi-fixed inputs
*	
*	s3x		independent variable of interest for stage 3 (observable state variables, e.g. capital)
*	s3z		additional independent variables stage 3 - do not enter the series terms
* 	s3var		variables (such as R&D) to enter the series terms in stage 3 in addition to `phi' and `phat' 
*	s3o		order of series expansion for phi and phat and variables in $s3var inside the NLLS of stage 3
*	s3init	matrix of initial values for stage 3 (default==zeros)
* 	s3grid	string containing starting point, stepsize, and endpoint for gridsearch
*			in usual STATA notation (e.g. global s3grid="0(.2)1")
*			only works if there is only one independent variable (for now)	
*	s3delta	string containing sequence of deltas for NLLS routine (default="4e-7")
*			(delta = relative changes in parameters to compute derivative)
*	s3options	other options for NLLS routine (if desired)
*
*
* 	OUTPUT:
*
*	opsrc		return code for OPS; 1 if there has been a problem 
*			(e.g. missing standard errors in probit regression)
*
*	opsb		name of matrix to save coefficients
*	omega		variable to save productivity estimates
*
*     s3rssmat    vector of residual sum of squares over s3grid 
*	s3rss		residual sum of squares for stage 3
*	s3nobs	number of observations in stage 3
*	s3sample	indicator variable equal to one if this observation and its lag enters stage 3
*			(useful for bootsrapping; sums to s3nobs)		 
*	s1phi		`phi' from first stage

capture program drop ops
program define ops, eclass
	
	version 7
	global opsrc=0	
	sort i t

	********************************************************************************************
	* series expansions for stage 1

	tempname i j k w v m n opqui
	if "$opqui"=="1"{
		local opqui="qui"
	}
	else {
		local opqui=" "
	}

	local w: word count $s1var
	tokenize $s1var


	tempvar s1var_0
	g byte `s1var_0'=_cons

	local v=0
	mat `m'=0
	forv i=1(1)`w' {
		forv k=0(1)`v' {
			if `m'[`k'+1,1]<$s1o {
				local n=$s1o-`m'[`k'+1,1]
				forv j=1(1)`n' {
					local v=`v'+1				
					tempvar s1var_`v'
					qui g double `s1var_`v''=`s1var_`k''*(``i''^`j')
					mat `m'=`m' \ (`m'[`k'+1,1]+`j')
				}
			}
		}	
	}

	********************************************************************************************
	* stage 1: OLS of s1y on s1x and series terms
	
	if "`opqui'"=="" {	
	noi di
	noi di
	noi di
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di in gr "Olley-Pakes stage 1: OLS to get coefficients for variable factors "
	noi di
	noi di in ye "$if"
	noi di
	noi di in gr "Dependent variable: 		" in ye " $s1y "
	noi di in gr "Independent variables: 		" in ye " $s1x "
	noi di in gr "Polynomial expansion in:		" in ye " $s1var "	
	noi di in gr "Order of polynomial expansion:	" in ye " $s1o "			
	noi di in gr "______________________________________________________________________________"
	}
	tempname if
	
	tempvar yhat phi s3y esample
	tempname b1 b2 bi bj
`opqui'	reg $s1y $s1x $s1x2 $s1x3 `s1var_1' - `s1var_`v'' $if
	qui g byte `esample'=e(sample)

	mat `b1'=e(b)
	qui predict double `yhat' if e(sample), xb
	drop `s1var_1' - `s1var_`v''

	tokenize $s1x

	qui reg $s1y $s1x $s1x2		/* regression serves only to find number of parameters in $s1x and $s1x2 !!! */
	mat `bi'=colsof(e(b))-1
	mat `bi'=`b1'[1,1..`bi'[1,1]]

	*** construct variables for other stages
	qui mat score double `phi'=`bi' if `esample'
	qui g double `s3y'=$s1y-`phi' if `esample'
	qui replace  `phi'=`yhat'-`phi'
	if "$s1phi"~=""{
		capture drop $s1phi
		qui g double $s1phi=`phi'
	}

	*** keep only parameters of interest, i.e. coefficients on variables in $s1x
	qui reg $s1y $s1x 		/* regression serves only to find number of parameters in $s1x !!! */
	mat `bi'=colsof(e(b))-1
	mat `b1'=`b1'[1,1..`bi'[1,1]]



if "$opselect"=="" {global opselect=1}
if $opselect==1 {

	********************************************************************************************
	* series expansions for stage 2

	local w: word count $s2var
	tokenize $s2var

	tempvar s2var_0
	g byte `s2var_0'=_cons

	local v=0
	mat `m'=0
	forv i=1(1)`w' {
		forv k=0(1)`v' {
			if `m'[`k'+1,1]<$s2o {
				local n=$s2o-`m'[`k'+1,1]
				forv j=1(1)`n' {
					local v=`v'+1				
					tempvar s2var_`v'
					qui g double `s2var_`v''=`s2var_`k''*(``i''^`j')
					mat `m'=`m' \ (`m'[`k'+1,1]+`j')
				}
			}
		}	
	}

	********************************************************************************************
	* 2nd stage: Probit of exit on series terms and $s2x 
	if "`opqui'"==""{
	noi di
	noi di
	noi di
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di in gr "Olley-Pakes stage 2: Probit "
	noi di
	noi di in ye "$if"
	noi di
	noi di in gr "Dependent variable: 		" in ye " $s2y "
	noi di in gr "Independent variables: 		" in ye " $s2x "
	noi di in gr "Polynomial expansion in:		" in ye " $s2var "	
	noi di in gr "Order of polynomial expansion:	" in ye " $s2o "			
	noi di in gr "______________________________________________________________________________"
	}
	

	tempvar phat
	`opqui'	probit $s2y $s2x `s2var_1' - `s2var_`v'' $if
	qui predict double `phat' if e(sample) ,p
	
	`opqui'	tab $s2y if e(sample)
	
	drop `s2var_1' - `s2var_`v''
	local x="(in h and P):"


	tempname V 
	mat `V'=e(V)
	global opsrc=diag0cnt(`V')>0
	if $opsrc>0 {
		noi di in gr "______________________________________________________________________________"
		noi di
		noi di in gr "MISSING STANDARD ERROS IN PROBIT REGRESSION!!! EXITING PROGRAMME "
		noi di in gr "______________________________________________________________________________"
		noi di	
		exit
	}


}
else if $opselect==2 {

	********************************************************************************************
	* series expansions in phi and k for stage 2

	forv i=0(1)$s2o {
		local j=$s2o-`i'
		forv j=0(1)`j' {
			if `i'~=0|`j'~=0 {
				tempvar s2var_`i'_`j'
				qui g double `s2var_`i'_`j''=$s3x^`i'*`phi'^`j'
			}
		}
	}


	********************************************************************************************
	* 2nd stage: Probit of exit on series terms and $s2x 
	if "`opqui'"==""{
	noi di
	noi di
	noi di
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di in gr "Olley-Pakes stage 2: Probit "
	noi di
	noi di in ye "$if"
	noi di
	noi di in gr "Dependent variable: 		" in ye " $s2y "
	noi di in gr "Independent variables: 		" in ye " $s2x "
	noi di in gr "Polynomial expansion in:		" in ye " phi $s3x "	
	noi di in gr "Order of polynomial expansion:	" in ye " $s2o "			
	noi di in gr "______________________________________________________________________________"
	}


	tempvar phat
	`opqui'	probit $s2y $s2x `s2var_0_1' - `s2var_${s2o}_0' $if
	qui predict double `phat' if e(sample) ,p
	tab $s2y if e(sample)
	drop `s2var_0_1' - `s2var_${s2o}_0'
	local x="(in h and P):"


	tempname V 
	mat `V'=e(V)
	global opsrc=diag0cnt(`V')>0
	if $opsrc>0 {
		noi di in gr "______________________________________________________________________________"
		noi di
		noi di in gr "MISSING STANDARD ERROS IN PROBIT REGRESSION!!! EXITING PROGRAMME "
		noi di in gr "______________________________________________________________________________"
		noi di	
		exit
	}


}

else	{
	if "`opqui'"==""{
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di in gr "No selection stage "
	noi di in gr "______________________________________________________________________________"
	noi di
	local x="(in h)      :"
	}
}



	********************************************************************************************
	* 3rd stage: NLLS (requires program below)


	********************************************************************************************
	* check whether $s3x in $s3var
	
	local i: word count $s3x
	local j: word count $s3var
	global opnonlin=1
	
	forv k=1(1)`i' {
		local m: word `k' of $s3x
		local v=1
		forv l=1(1)`j' {
			local n: word `l' of $s3var
			local v=`v'*(`m'!=`n')

		}
		global opnonlin=$opnonlin*(`v'==0)		
	}


if "`opqui'"==""{
	noi di
	noi di
	noi di
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di in gr "Olley-Pakes stage 3: NLLS to get coefficients of quasi-fixed factors"
	noi di 
	noi di in ye "$if"
	noi di
	noi di in gr "Indep. linear variables (obs. state):	  " in ye " $s3x "
if "$s3z"~=""{
	noi di in gr "Additional linear variables:		  " in ye " $s3z "
}
if $opselect==0 {
	noi di in gr "Polynomial expansion in:			  " in ye " L.omega $s3var "	
}
else {
	noi di in gr "Polynomial expansion in:			  " in ye " L.omega L.phat $s3var "	
}
	noi di in gr "Order of polynomial expansion: 		  " in ye " $s3o "
if "$s3grid"~="" {
	noi di in gr "Grid search over:				  " in ye " $s3grid "
}
	noi di in gr "Sequence of deltas for NLLS-routine: 	  " in ye " $s3delta "
if "$s3options"~="" {
	noi di in gr "Other options for NLLS-routine:		  " in ye " $s3options "
}
	noi di in gr "______________________________________________________________________________"
}

	global s3w: word count $s3x
	global s3y="`s3y'"

	tempname opb m
	if "$opb"=="" {
		global opb="`opb'"
	}

	if "$s3init"=="" {mat $opb=J(1,$s3w,0)}
	else	      {mat $opb=$s3init}

	********************************************************************
	*** initialising series terms for stage 3
	
	if $opselect==0 {
		global s3servar="$s3var L.`phi'"
	}
	else {
		global s3servar="$s3var L.`phat' L.`phi'"
	}
	global s3servarw: word count $s3servar

	capture drop _s3v*
	local v=0
	mat `m'=0

	qui g double _s3v0=_cons if(`esample'&L.`esample')  /* include only observations which entered stage 1 and for which lags are available */
	forv i=1(1)$s3servarw {					 /* exclude observations for which lagged variables in $s3servar are unavailable */
		local j: word `i' of $s3servar
		qui replace _s3v0=. if `j'==.
	}
	
	tokenize $s3servar
	
	if $s3servarw==1 {
		global s3wphi=`v'
	}
	

	forv i=1(1)$s3servarw {
		if `i'==$s3servarw{
			global s3wphi=`v'
		}
		forv k=0(1)`v' {
			if `m'[`k'+1,1]<$s3o {
				local n=$s3o-`m'[`k'+1,1]
				forv j=1(1)`n' {
					local v=`v'+1				
					qui g double _s3v`v'=_s3v`k'*(``i''^`j')
					mat `m'=`m' \ (`m'[`k'+1,1]+`j')
				}
			}
		}	
	}
	
	mat s3mat=`m'[1..${s3wphi}+1,1]
	global s3series="_s3v1 - _s3v`v'"

	********************************************************************
	*** Grid search

	if "$s3grid"~="" {

		if $s3w>1 {
			`opqui' di
			`opqui' di in ye "Grid search supports only one independent variable in stage 3 so far !!!"	
			`opqui' di in gr
			`opqui' di in gr "Initial values for NLLS:"
			`opqui' mat li $opb, noh
		}
		else {
			`opqui' di 
			`opqui' di in gr "Running grid search over " in ye "$s3grid" in gr " for variable " in ye "$s3x" in gr "."
			`opqui' di 
	
			local j=exp(700)
			local k=0
			tempvar res 
			qui g double `res'=$s3y
			tempname s3rssmat
			forv i=$s3grid {
				global s3_$s3x=`i'
				qui nlstage3 `res' `phi'   
				qui replace `res'=($s3y-`res')^2
				sum `res', mean
				`opqui' di in gr "." _c
				mat `s3rssmat'=nullmat(`s3rssmat') \ [`i', r(sum)]
				if r(sum)<`j'{
					local j=r(sum)
					local k=`i'
				}
			}
			if "$s3rssmat"~="" {
				mat $s3rssmat=`s3rssmat'
			}

			**** graph objective function
			tempname grbeta grrss 
			mat `grbeta'=`s3rssmat'[1...,1]
			svmat `grbeta', names("`grbeta'")
			mat drop `grbeta'
			mat `grrss'=`s3rssmat'[1...,2]
			svmat `grrss', names("`grrss'")
			mat drop `grrss'
			lab var `grbeta' "beta"
			lab var `grrss' "RSS"
			local i=string(`k')
			local i=substr("`i'",1,5)
			gr `grrss' `grbeta', ti("Stage 3 objective function: Minimum at `i' ") xlab ylab
			drop `grrss' `grbeta'

			**** save starting values
			mat $opb=`k'
			`opqui' di
			`opqui' di in gr "minimum RSS: " in ye "`j'" in gr " at grid point: " in ye `k' 

		}
	}
	else {

		`opqui' di in gr "Initial values:"
		`opqui' mat li $opb, noh
	}		

	********************************************************************
	*** NLLS estimation


	****** determine series terms that are not dropped in nlstage3 at initial values 
	****** update $s3series to include only those (to keep them constant)

	tempvar s3ys omega
	qui g double `omega'=0
	forv i=1(1)$s3w {
		local x: word `i' of $s3x
		qui replace `omega'=`omega'+$opb[1,`i']*`x' $if
	}
	qui replace `omega'=`phi'-`omega' $if 	
	local v=$s3wphi
	forv k=0(1)$s3wphi {
		if s3mat[`k'+1,1]<$s3o {
			local n=$s3o-s3mat[`k'+1,1]
			forv j=1(1)`n' {
				local v=`v'+1				
				qui replace _s3v`v'=_s3v`k'*((L.`omega')^`j')
			}
		}
	}	
	tempname V
	qui mat accum `V'=$s3series, dev nocons
	mat `V'=syminv(`V')
	mat `V'=`V'*J(colsof(`V'),1,1)

	local i=rowsof(`V')
	local j=0
	global s3series=""
	forv i=1(1)`i' {
		if `V'[`i',1]~=0&`j'==0 {
			global s3series="$s3series _s3v`i'"
			local j=1
		}
		else if `V'[`i',1]==0&`j'==1 {
			local k=`i'-1
			global s3series="$s3series -_s3v`k'"
			local j=0
		}
	}
	if `j'==1 {
		local i=rowsof(`V')
		global s3series="$s3series -_s3v`i'"
	}


	****** run nlstage3

	if "$s3delta"=="" {global s3delta="4e-7"}
	local j: word count $s3delta
	forv i=1(1)`j' {
		local k: word `i' of $s3delta
		`opqui' di
		`opqui' di in gr "Step `i':  Delta= " in ye " `k' " in gr
		`opqui' di
		`opqui'	nl stage3 $s3y `phi' $s3series if(_s3v0==1), delta(`k') $s3options 
		mat $opb=e(b)
	}

	tempname b3 b4 rss nobs
	if "$s3sample"~="" {
		capture drop $s3sample
		g byte $s3sample=e(sample)
	}
	scalar `rss'=e(rss)
	scalar `nobs'=e(N)
	mat `b3'=e(b)
	mat `b4'=[`b1', `b3'[1,1..$s3w]]

	**** display coefficients of series terms
	`opqui' di
	`opqui' di in gr "Coefficients of other variables and series terms:"


	*** construct term to be substracted from `phi' at given parameter values
	tempvar s3ys omega
	local x: word 1 of $s3x
	qui g double `omega'=0
	forv i=1(1)$s3w {
		local x: word `i' of $s3x
		qui replace `omega'=`omega'+${s3_`x'}*`x' $if
	}
	qui g double `s3ys'=`s3y'-`omega'	/* dependent variable for OLS part */
	qui replace `omega'=`phi'-`omega' $if 	/* final estimate of omega */
	qui replace `omega'=. if F._s3v0==.&_s3v0==.

	*** update series terms that include `omega'=`phi'-stuff
	local v=$s3wphi
	forv k=0(1)$s3wphi {
		if s3mat[`k'+1,1]<$s3o {
			local n=$s3o-s3mat[`k'+1,1]
			forv j=1(1)`n' {
				local v=`v'+1				
				qui replace _s3v`v'=_s3v`k'*((L.`omega')^`j')
			}
		}
	}	

	*** run OLS of $s3y-linear_stuff on series terms ($s3series) and additional (linear) variables ($s3z) 

	qui reg `s3ys' $s3z $s3series if _s3v0==1 
	if "`opqui'"=="" {
		reg, noheader	
		noi di in gr " Note: SE's and df's and goodness of fit statistics are wrong !"
	}

	local i: word count $s3z
	if `i'>0 {
		mat `b3'=e(b)
		mat `b4'=`b4', `b3'[1,1..`i']
	}

	mat coln `b4'=$s1x $s3x $s3z

*	drop _s3v*

	********************************************************************************************
	* Output

	noi di 
	noi di
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di in gr "OLLEY-PAKES-Algorithm to estimate production functions - series version:"
	noi di 
	noi di in gr "Parameters specified:
	noi di in gr "	Observations included " in ye "$if"
	noi di
	noi di in gr "Stage 1: OLS with series expansion"
	noi di in gr "	Dependent variable: 			" in ye " $s1y "
	noi di in gr "	Indep. linear variables of interest:    " in ye " $s1x "
if "$s1x2"~=""{
	noi di in gr "	Other linear var's NOT entering phi:    " in ye " $s1x2 "
}
	noi di in gr "	Polynomial series expansion in (phi):	" in ye " $s1var "	
	noi di in gr "	Order of expansion:			" in ye " $s1o "			
if "$s1x3"~=""{
	noi di in gr "	Other linear var's in phi:		" in ye " $s1x3 "
}
	noi di

if $opselect {
	noi di in gr "Stage 2: Probit "
	noi di in gr "	Dependent variable: 			" in ye " $s2y "
	noi di in gr "	Independent variables: 			" in ye " $s2x "

	if $opselect==1 {
		noi di in gr "	Polynomial series expansion in:		" in ye " $s2var "	
	}
	if $opselect==2 {
		noi di in gr "  Polynomial series expansion in:		" in ye " phi $s3x "	
	}
	noi di in gr "	Order of polynomial expansion:		" in ye " $s2o "			
}
else {
	noi di in gr "No selection stage "
}
	noi di
if "$opnonlin"~="1" {
	noi di in gr "Stage 3: NLLS
	noi di in gr "	Ind. linear var's (quasi-fixed inputs):	" in ye " $s3x "
}
else {
	noi di in gr "Stage 3: NLLS - Completely nonlinear model: "
	noi di in gr "	Quasi-fixed inputs in series exp:	" in ye " $s3x "
}
if "$s3z"~=""{
	noi di in gr "	Additional linear variables:	 	" in ye " $s3z "
}

if $opselect==0 {
	noi di in gr "	Polynomial series expansion in:		" in ye " L.omega $s3var "	
}
else {
	noi di in gr "  Polynomial series expansion in:		" in ye " L.omega L.phat $s3var "	
}
	noi di in gr "	   where:				" in ye " omega=phi-($s3x)*alpha') "
	noi di in gr "	Order of expansion: 			" in ye " $s3o "

if "$s3grid"~="" {
	noi di in gr "  Grid search over:	 		" in ye " $s3grid "
}
	noi di in gr "	Sequence of deltas for NLLS-routine: 	" in ye " $s3delta "
	noi di 
if "$opb"~="`opb'" {
	noi di in gr "Parameter estimates (saved in " in ye " $opb" in gr ")"
	mat $opb=`b4'
	mat li $opb, noh
}
else {
	noi di in gr "Parameter estimates: "
	mat li `b4', noh
	global opb=""
}
	noi di

if "$s3rss"~=""{
	scalar $s3rss=`rss'
	noi di in gr "Residual SS in stage 3 (saved in " in ye " $s3rss " in gr "):   " in ye `rss'
}
else {  noi di in gr "Residual SS in stage 3: 			" in ye `rss'
}
/*
	tempname t
	qui tsset
	local i=r(panelvar)		
	qui reg $s1y `omega', cl(`i')
	local j=e(N_clust)
	noi di 
	noi di in gr "Number of firms in stage 3:	         " in ye `j'
*/
	noi di in gr "Number of observations in stage 3:	 " in ye `nobs'
        

if "$s3nobs"~=""{scalar $s3nobs=`nobs'}
if "$omega"~="" {
	noi di in gr "Productivity estimates saved in 	 	" in ye " $omega"
	
	capture drop $omega
	qui g $omega=`omega'    
   
}
	noi di in gr "______________________________________________________________________________"
	noi di
	noi di


	*****************************************************************
	* Post estimation results

	est clear
	tempname V
	local i=colsof(`b4')
	mat `V'=J(`i',`i',exp(709))
	local i: colnames(`b4')
	mat coln `V'= `i'
	mat rown `V'= `i'       
	est post `b4' `V', esample(`esample') 
	est local cmd "ops"
	est scalar N=`nobs'
*	est scalar N_clust=`j'
	est scalar rss=`rss'
	if "$opsb"~="" {
		mat $opsb=e(b)
     
       	}
 
  
end



*************************************************
* program for NLLS below:

capture program drop nlstage3
program define nlstage3
	version 7

	****** initialising parameters

	if "`1'"=="?" {
		global S_1 " " 
		forv i=1(1)$s3w {
			local x: word `i' of $s3x
			global S_1="$S_1 s3_`x'"
			global s3_`x'=$opb[1,`i']
		}
		exit
	}

	****** computation of the nonlinear function

	* `1': predicted values
	* `2': `phi'

	*** construct term to be substracted from `phi' at given parameter values
	qui replace `1'=0 $if
	forv i=1(1)$s3w {
		local x: word `i' of $s3x
		qui replace `1'=`1'+${s3_`x'}*`x' $if
	}
	
	*** update series terms that include `h'=`phi'-stuff
	tempvar h
	qui g double `h'=`2'-`1' $if		

	local v=$s3wphi
	forv k=0(1)$s3wphi {
		if s3mat[`k'+1,1]<$s3o {
			local n=$s3o-s3mat[`k'+1,1]
			forv j=1(1)`n' {
				local v=`v'+1				
				replace _s3v`v'=_s3v`k'*((L.`h')^`j')
			}
		}
	}	
	
	*** run OLS of $s3y-`1' on series terms ($s3series) and additional variables ($s3z) 
	tempvar y yhat
	if "$opnonlin"=="1" {
		qui replace `1'=0
	}
	g double `y'=$s3y-`1' 
	reg `y' $s3z $s3series 
	predict `yhat' if(e(sample)), xb

	*** return predicted values of nonlinear function 
	replace `1'=`1'+`yhat' 

end


