**********************************
* Different levels of lottery wins
* Figure A7
***********************************

//////////////////
// Raw data graphs
//////////////////

// Pool all lottery data for each lottery size in Brazilian Reais: 10 20 30 50 250 1000

foreach l in 10 20 30 50 250 1000{

global file prize_`l'

* Append data
use ${file}lot593, clear
rename treat treat
rename de de
save ${file}lot_all, replace

forvalues y=594(1)617 {
use ${file}lot`y', clear
rename de de
rename treat treat
merge 1:1 de treat using ${file}lot_all
drop _merge
save ${file}lot_all, replace
}

* Average data across event-time
use ${file}lot_all, clear
order treat de NumRec*

local x NumRecp99  
egen `x'=rowmean( `x'593 `x'594 `x'595 `x'596 `x'597 `x'598 `x'599 `x'600 `x'601 `x'602 `x'603 `x'604   ///
`x'605 `x'606 `x'607 `x'608 `x'609 `x'610 `x'611 `x'612 `x'613 `x'614 `x'615 `x'616 `x'617)

keep treat de NumRecp99  

// Figure A7

global range de>=-3&de<=6
global xl -3[1]6
global yl //12.5[2]16
global varg NumRecp99
twoway scatter ${varg} de if treat==1 &${range}, c(l) lpattern(solid) lcolor(black) lwidth(thin) mcolor(black) msize(small) ///
|| scatter ${varg} de if treat==0&${range}, c(l) lpattern(dash) lcolor(black) lwidth(thin) mcolor(black) msize(small) xline(0, lpattern(dash) lcolor(red) lwidth(thin) ) ///
xlabel(${xl},labsize(small)) ylabel(${yl},labsize(small) )  ///
xtitle("") ytitle("", size(small))  ///
legend(order(1 "Win" 2 "No Win") size(vsmall)) ///
title("",size(medium)) graphregion(color(white)) 
		graph save "temp\FigA7_`l'", replace		

}


////////////////////////////////
// Coefficients for regressions
////////////////////////////////
* DD coefficient for before vs after lottery



	* create output table to help append columns
	global fileprize prize_10
	use "lot_micro_long_${fileprize}.dta", clear
	global outfilecompl "temp\FigA7_coefs.xls"
	*gen file for tables
	set more off
	reg de de
	outreg2 using ${outfilelot}, nolabel bracket excel nonotes replace
	
foreach l in 10 20 30 50 250 1000{

// Prepare the data

global fileprize prize_`l'
use "lot_micro_long_${fileprize}.dta", clear

*** create DD and dummies for event time
gen dd=0
replace dd=1 if  treat==1&de>=0
gen post_d=(de>=0)

gen x=de+7 //create an event time variable with positive numbers

*** outcomes
replace NumRecp99=0 if NumRecp99==.	

// Regressions

	foreach c in iddest	event_date { //alternative clustering: by masked consumer id and by lottery event date

	local y in NumRecp99 
	global ini 4
	global end 13

	areg  `y' dd i.x i.date_taxref_n i.event_date treat [pw=dfl] if x>=${ini}&x<=${end}, abs(iddest) vce(cluster `c')
	outreg2 using ${outfilelot}, ctitle("`y'`l'") nolabel bracket excel nonotes append

		
	}


}
