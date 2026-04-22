************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

************************************************************************
************************************************************************
****MAKE EVERY PAIRWISE COMBINATION OF NIC3 1987
use "$data/IOtables/14Sept_IOConc_updt.dta", clear
drop if iott==.
drop if nic3==.
keep  iottsector nic3digit
rename iottsector buyer
rename nic3digit nic3buyer
tempfile temp
save `temp'
rename buyer seller
rename nic3buyer nic3seller
cross using `temp'
order buyer nic3buyer seller nic3seller
sort buyer nic3buyer seller nic3seller

tempfile master
save `master'

****INPUT IO MATRIX, MAKE LONG
use "$data/IOtables/16Oct_IO8990_Forward", clear
order  commodity iottsector
rename iottsector seller
reshape long io, i( commodity seller) j(buyer)
rename io inputshare
drop commodity
tempfile iomatrix_iott
save `iomatrix_iott'


use `master', clear
merge m:1 buyer seller using `iomatrix_iott', assert(3) nogen
drop seller buyer
rename nic3seller src
reshape wide inputshare, i(nic3buyer) j(src)

egen total=rowtotal(inputshare*)
foreach var of varlist inputshare* {
replace `var' = `var'/total
}
drop total

	qui desc
	assert r(k)==182+1
	assert r(N)==182

rename nic3buyer nic3digit
gsort nic3digit

mkmat   inputshare200-inputshare389, matrix(A)  	

*****CALCULATE THE MATRIX
**THE IO MATRIX (A) IS 182x182
**THE ELECTRICITY SHARES MATRIX IS (SHOULD BE) 182x1
keep nic3digit
duplicates drop
gsort nic3digit
count
***merge in snic match
rename nic3digit nic87
merge m:1 nic87 using "$work/supernics", keep(1 3) nogen
tempfile snicbase
save `snicbase'

use "$work/M and L shares from qreg.dta", clear 
collapse (mean) lambda_final, by(snic)
decode snic, g(nic87_super)
drop snic
tempfile lambdamatch
save `lambdamatch'

use `snicbase'
merge m:1 nic87_super using `lambdamatch', assert(1 3) nogen
replace lambda_final = 0 if lambda_final==. //just allows the matrix to be calculated if no data for that nic anyway
assert _N==182 /* = 182x1 */
rename nic87 nic3digit 
drop  nic87_super
gsort nic3digit

mkmat lambda_final, matrix(T) /*this should be a 182 X 1 matrix */
matrix C=A*T
svmat C, name(input_lambda)
drop lambda_final
rename input_lambda input_lambda

save "$work/input elec intensity.dta", replace
