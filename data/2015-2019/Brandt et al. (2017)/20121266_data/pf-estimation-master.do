clear
clear matrix
clear mata
set matsize 10000
set trace off

set more off
set mem 2g

*********************************	
***Five versions of estimation***
*********************************	

*all versions with the following specifications details
*(1) DLW method
*(2) OLS estimates as initial values for GMM 
*(3) use materials to construct the inverse function
*(4) do not trim the sample
*(5) include 1998 observations in the first stage(line 127)
*(6) exclude observations of new entries in their first year after 1998 

do DLW-3input.do

*A: benchmark labor measure employment
global version="A"
do "pf estimation"

*B: labor measure deflated wagebill
global version="B"
do "pf estimation"

*C: new deflators 
global version="C"
do "pf estimation"

*D: 4-digit cic
global version="D"
do "pf estimation"

*save coef estimates
foreach v in A B C D {
	matrix beta`v'=beta`v'1
	if "`v'"~="D" {
		forval n=2/29 {
			matrix beta`v'=beta`v'\beta`v'`n'
		}
	}
	
	if "`v'"=="D" {
		forval n=2/424 {
			matrix beta`v'=beta`v'\beta`v'`n'
		}
	}
	
	clear
	svmat beta`v'
	if "`v'"~="D" gen gcic2=_n
	if "`v'"=="D" gen gcic4=_n		
	save beta`v',replace
}

*************************************************	
***BS standard error for the benchmark version***
*************************************************	
do DLW-3input.do
do "pf estimation block bs sd"

use pfcoef_BS.dta,clear
collapse (mean) c_coef=CD0 mcoef=CDm lcoef=CDl kcoef=CDk (sd) c_se=CD0 mse=CDm lse=CDl kse=CDk,by(cc)
gen cic2=cc+12
replace cic2=cic2+1 if cic2>=38
reshape long c_ m l k,i(cic2 cc bad) j(est) s

tostring m l k c_,replace force
for any m l k c_: replace X="("+substr(X,1,4)+")" if est=="se"
for any m l k c_: replace X=substr(X,1,4) if est=="coef"
for any m l k c_: replace X=subinstr(X,".","0.",.)

order cic2 m l k

