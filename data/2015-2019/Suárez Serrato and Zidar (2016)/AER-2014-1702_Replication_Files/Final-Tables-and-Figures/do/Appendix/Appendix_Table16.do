*Draws output from table5.do to produce A16

local tablename="Appendix_Table16"
clear
set more off

use "$dumppath/results_1.dta", clear /* Column 1 */
keep param param1 Share*
replace param1 = Share1 in 10
drop Share*
gen order = _n
tempfile results1
save `results1', replace

use "$dumppath/results_4.dta", clear /* Column 2 */
keep param param4 Share*
replace param4 = Share4 in 10
drop Share*
gen order = _n
tempfile results4
save `results4', replace

use "$dumppath/results_5.dta", clear /* Column 3 */
keep param param5 Share*
replace param5 = Share5 in 10
drop Share*
gen order = _n
drop if missing(param5)
tempfile results5
save `results5', replace

use "$dumppath/results_6.dta", clear /* Column 4 */
keep param param6 Share*
replace param6 = Share6 in 10
drop Share*
gen order = _n
tempfile results6
save `results6', replace

*Merge
use `results1', clear
merge 1:1 order using `results4', nogen
merge 1:1 order using `results5', nogen
merge 1:1 order using `results6', nogen
replace order = 1 in 3
replace order = 2 in 4
replace order = 3 in 1
replace order = 4 in 2
sort order
drop order

*Output
listtex using "$tablepath/Appendix/`tablename'.tex", replace rstyle(tabular)
