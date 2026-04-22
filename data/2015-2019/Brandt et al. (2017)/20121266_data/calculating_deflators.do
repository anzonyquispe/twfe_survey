
set more off

**********************
* preparing the data *
**********************

* need cic_table.dta, 1998.dta, 1999.dta, ..., 2003.dta in current directory 

use cic_table.dta, clear
gen cic = string(old)
sort cic
save old_cic.dta, replace

use cic_table.dta, clear
gen cic=string(new)
sort cic
save new_cic.dta, replace

forvalues i = 1998/2002 {

	use `i'.dta, clear
	sort cic
	joinby cic using old_cic.dta
	duplicates drop id, force
	rename con con`i'
	rename cur cur`i'
	rename cic_adj cic`i'
	keep  id con`i' cur`i' cic`i'
	sort id
	save `i'.10.dta, replace 

}

use 2003.dta, clear
sort cic
joinby cic using new_cic.dta
duplicates drop id, force
rename con con2003
rename cur cur2003
rename cic_adj cic2003
keep  id con2003 cur2003 cic2003
sort id
save 2003.10.dta, replace 


***********************************
* calculating benchmark deflators *
***********************************

* cutting as outliers those observations for which the price change differs by more than half of the standard deviation from the mean

forvalues i = 1998/2002 {

	use `i'.10.dta, clear
	local j = `i' + 1
	merge id using `j'.10.dta
	keep if _merge == 3
	drop _merge
	drop if con`i' == 0|cur`i' == 0|con`j' == 0|cur`j' == 0
	gen a`i' = 100*cur`i'/con`i'
	gen a`j' = 100*cur`j'/con`j'
	gen index`j' = 100*a`j'/a`i'
	save tmp1.dta, replace

	gen b = index`j'	
	collapse (mean) index`j' (sd) b, by (cic`i')
	rename index`j' cic_mean
	rename b cic_sd
	save tmp2.dta, replace

	use tmp1.dta, clear
	joinby cic`i' using tmp2.dta
	drop if index`j'>(cic_mean+0.5*cic_sd)|index`j'<(cic_mean-0.5*cic_sd)
	save tmp3.dta, replace

	collapse (sum) cur`j', by (cic`i')
	rename cur`j' total`j'
	joinby cic`i' using tmp3.dta
	gen c = index`j'*cur`j'/total`j'
	collapse (sum) c, by(cic`i')
	rename c index`j'
	rename cic`i' cic
	save index`j'.dta, replace
}

use index1999.dta, clear
merge cic using index2000.dta
drop _merge
sort cic
merge cic using index2001.dta
drop _merge
sort cic
merge cic using index2002.dta
drop _merge
sort cic
merge cic using index2003.dta

gen deflator1999 = index1999
gen deflator2000 = index2000*deflator1999/100
gen deflator2001 = index2001*deflator2000/100
gen deflator2002 = index2002*deflator2001/100
gen deflator2003 = index2003*deflator2002/100

keep cic deflator*
sort cic

save benchmark_deflators.dta, replace


*************************************
* calculating alternative deflators *
*************************************

* cutting as outliers those observations for which the price change differs by more than one standard deviation from the mean

forvalues i = 1998(1)2002 {

	use `i'.10.dta, clear
	local j = `i' + 1
	merge id using `j'.10.dta
	keep if _merge == 3
	drop _merge
	drop if con`i' == 0|cur`i' == 0|con`j' == 0|cur`j' == 0
	gen a`i' = 100*cur`i'/con`i'
	gen a`j' = 100*cur`j'/con`j'
	gen index`j' = 100*a`j'/a`i'
	save tmp1.dta, replace

	gen b = index`j'	
	collapse (mean) index`j' (sd) b, by (cic`i')
	rename index`j' cic_mean
	rename b cic_sd
	save tmp2.dta, replace

	use tmp1.dta, clear
	joinby cic`i' using tmp2.dta
	drop if index`j'>(cic_mean+cic_sd)|index`j'<(cic_mean-cic_sd)
	save tmp3.dta, replace

	collapse (sum) cur`j', by (cic`i')
	rename cur`j' total`j'
	joinby cic`i' using tmp3.dta
	gen c = index`j'*cur`j'/total`j'
	collapse (sum) c, by(cic`i')
	rename c index`j'
	rename cic`i' cic
	save index`j'.dta, replace
}

use index1999.dta, clear
merge cic using index2000.dta
drop _merge
sort cic
merge cic using index2001.dta
drop _merge
sort cic
merge cic using index2002.dta
drop _merge
sort cic
merge cic using index2003.dta

gen deflator1999 = index1999
gen deflator2000 = index2000*deflator1999/100
gen deflator2001 = index2001*deflator2000/100
gen deflator2002 = index2002*deflator2001/100
gen deflator2003 = index2003*deflator2002/100

keep cic deflator*
sort cic

save alternative_deflators.dta, replace

exit
