
insheet using "$data/Deflators/nic deflators_1994 to 2011_for processing.csv", comma names clear
tempfile late
cap drop v*
replace nic3=subinstr(nic3," ","",.)
split nic3digit,p(",")
drop nic3digit
forval i = 1/12 {
preserve
keep nic3digit`i' p*
keep if nic3digit`i'!=""
rename nic3digit`i' nic3digit
cap append using `late'
save `late', replace
restore
}
use `late', clear
destring nic3digit, replace
sort nic3digit
save `late', replace

insheet using "$data/Deflators/early series.csv", comma names clear
drop  p199495 p199596 p199697 p199798 p199899 p19992000
destring nic3, replace
merge 1:1 nic3digit using `late', assert(3) nogen

forval i=1979/2011{
rename p`i' _`i'
}

reshape long _, i(nic3digit) j(year)
rename _ deflator

***PUT EVERYTHING INTO 2004-05 RS
g base=deflator if year==2004
bys nic3digit: egen denom=sum(base)
replace deflator=deflator/denom*100
drop base denom

*drop if nic3==239 | nic3==249

save "$data/Deflators/final output deflator.dta", replace
