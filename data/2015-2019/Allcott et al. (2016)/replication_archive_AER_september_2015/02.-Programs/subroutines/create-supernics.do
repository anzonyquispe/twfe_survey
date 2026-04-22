

insheet using "$root/03. Analyses/excel programming sheets/Create SuperNICs3.csv", comma names clear
drop count*
tostring nic87*, replace
forval i = 1/3 {
replace nic87_`i'="" if nic87_`i'=="."
}
g nic87_super=nic87_1+nic87_2+nic87_3

forval i = 1/3 {
preserve
keep nic87_`i' nic87_super
drop if nic87_`i'==""
rename nic87_`i' nic87
tempfile _`i'
save `_`i''
restore
}

use `_1', clear
forval i = 2/3 {
append using `_`i''
}
destring nic87, replace
gsort nic87

save "$work/supernics.dta", replace

