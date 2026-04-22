***********
* Figure 4b
* Deposits
***********
clear all
set more off
# delimit cr

global MainDir "XX\Replication" /* replace XX with the directory path*/
cd "$MainDir\Data"


// Create an aggregate data on the deposits claimed by consumers by calendar month

use deposits, clear

collapse (sum) total_deposited, by(date_taxref_n)

 			gen date_taxref=date_taxref
			format date_taxref %tm 	

// Convert to millions of USD
gen Deposited=total_deposited/2000000


// Figure 4b
sort date_taxref_n
twoway scatter Deposited date_taxref , c(1) msize(small) lcolor(navy) lwidth(medium) mcolor(navy) ///
graphregion(color(white)) ///
xlabel(591(6)624 , labsize(small) ) ylabel(, labsize(small) noticks) ///
ytitle("millions of US$", size(small)) xtitle("") ///
xline(591, lpattern(dash)) xline(597, lpattern(dash)) xline(603, lpattern(dash)) ///
 xline(609, lpattern(dash)) xline(615, lpattern(dash)) xline(621, lpattern(dash))

