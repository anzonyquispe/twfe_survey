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
merge m:1 buyer seller using `iomatrix_iott'
assert _m==3
drop seller buyer _merge
rename nic3seller src
reshape wide inputshare, i(nic3buyer) j(src)

egen total=rowtotal(inputshare*)
foreach var of varlist inputshare* {
replace `var' = `var'/total //normalized share given starting table shares were column-based (i.e., normalized for forward (purchasing) industries rather than selling)
}
drop total

	qui desc
	assert r(k)==182+1
	assert r(N)==182

rename nic3buyer nic3digit
gsort nic3digit

/***MAKE INTO PROPER DIMENSIONS BY YEAR LONG
tempfile temp1
save `temp1'
	local count = 1
	qui while `count'<=29 {
	append using `temp1'
	local count = `count' +1
	}

assert _N==5400
*/
mkmat   inputshare200-inputshare389, matrix(A)  	

*****CALCULATE THE MATRIX
**THE IO MATRIX (A) IS 182x182
**THE OUTPUT DEFLATOR MATRIX IS (SHOULD BE) 182x33
use "$data/Deflators/final output deflator.dta", clear
assert _N==6006 /* = 182x33 */
bysort year: g rank=_N
assert rank==182
drop rank
reshape wide deflator, i(nic3digit) j(year)
order nic3digit
gsort nic3digit
mkmat deflator1979-deflator2011, matrix(T) /*this should be a 1024 X 1 matrix */
matrix C=A*T
svmat C, name(input_deflator)
drop deflator*
reshape long input_deflator, i(nic3digit) j(year)
replace year = year + 1978
tab year


save "$data/Deflators/final input deflator.dta", replace
