clear
set more off

use "$datapath_misalloc/misallocation_paneldata.dta", clear
rename fipstate statefips
tsset statefips year
keep if year >= 1979
gen delta_corp = corporate_rate - L1.corporate_rate
drop if delta_corp == .
gen delta_corp_indicator = (delta_corp != 0) /* == 1 if a change occured */
by statefips: egen total_change_corp = sum(delta_corp_indicator) /* Total number of corporate rate changes since 1979 by state */

keep statefips year delta_corp corporate_rate delta_corp_indicator total_change_corp

saveold "$dtapath/Figures/Figure2.dta", replace

