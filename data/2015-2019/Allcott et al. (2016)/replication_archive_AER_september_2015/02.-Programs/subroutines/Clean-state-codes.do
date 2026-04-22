
tempfile temp

insheet using "$data/ASI/ASI_state codes_1974-2010.csv", comma names clear
destring _all, replace
reshape long v_, i(state) j(code) string
g start=substr(trim(code),1,4)
g end=substr(trim(code),5,4)
destring start end, replace
drop code
forval i = 1974/2010 {
preserve
keep if `i'>=start & `i'<=end
g year=`i'
drop start end
cap append using `temp'
save `temp', replace
restore
}

use `temp', clear
rename v stcode
drop if stcode==.

replace state="GOA DAMAN AND DIU" if state=="GOA" | state=="DAMAN AND DIU"
replace state="ARUNACHAL PRADESH" if state=="ARUNCHAL PRADESH"
duplicates drop

save "$work/statecodes.dta", replace
