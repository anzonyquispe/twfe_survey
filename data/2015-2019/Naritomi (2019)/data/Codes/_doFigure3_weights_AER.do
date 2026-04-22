******************************************
* Create propensity score for re-weighting
******************************************
clear all
set more off, perm

cd "$MainDir\Data\"

//////////////////////
// Create DFL weights
//////////////////////

* for each first complaint event 2009m7 and 2011m6, re-weight the control group based on the pscore to match the treatment group

forvalues d=594(1)617 {

use "ps_first_compl_`d'_micro.dta", clear 

* flag if the firm got a complaint at time d and zero otherwise
gen treat=firstcompl_
gen date_compl=compl_date

* reduce the size of the data by keeping a subset of variables
isid id_tx
keep id_tx q_ps treat date_compl 
		
		************* Get month and year ************
		format date_compl %tm

		gen auxdate=dofm(date_compl)
		format auxdate %d
		gen month=month(auxdate)
		gen year=year(auxdate)
		drop auxdate

// Prepare to DFL	

* groups being reweighted: treatment-event
gen yrmonthcompl = (year*1000)+(month*10)+treat //converts the year variable (2002) into a year+month+treatment (2002021 or 2002020)

* the value of $dflbyvar that all  $dflbyvar groups are supposed to be reweighted to resemble:
gen yrmonth = (year*1000)+(month*10)+1  //I need to rewight each group for each event; if it was one event I would set 2005071 the value of $dflbyvar that all $dflbyvar groups are supposed to be reweighted to resemble

* original weight
gen one=1

capture drop zz* _merge tempdflorigwgt

global dflbyvar = "yrmonthcompl" 
global dflorigwgt = "one" // original weight (should be set to a var equal to 1 if no original weight); 
global balanceacrossdflbyvar=0
global dflvarlist = "q_ps" // $dflvarlist = list of all vars that the the $dflbyvar groups are being reweighted on
global dflbyvarbasegroup = "yrmonth" 

global file_compl dflcompl`d'_micro

capture drop _merge dfl zz*
sort $dflvarlist $dflbyvar
drop if $dflvarlist==.
save ${file_compl}, replace


// Create weights

collapse (sum) $dflorigwgt, by($dflvarlist $dflbyvar $dflbyvarbasegroup)
isid ${dflvarlist} ${dflbyvar} // dflbyvarbasegroup should not add any obs
save ${file_compl}2, replace

	keep if ${dflbyvar}==$dflbyvarbasegroup
	rename ${dflorigwgt} zzbasegroupval
	sort $dflvarlist
	save ${file_compl}3, replace
	
	use ${file_compl}2, clear
	merge m:1 ${dflvarlist} using ${file_compl}3
	drop _merge
	gen zzfactor = zzbasegroupval/$dflorigwgt
		if $balanceacrossdflbyvar!=1 {
		 bys $dflbyvar: egen zzdflbyvarsum = sum($dflorigwgt)
		 quietly sum $dflorigwgt if $dflbyvar==$dflbyvarbasegroup
		 replace zzfactor = zzfactor*(zzdflbyvarsum/r(sum))
		}
	replace zzfactor=0 if zzfactor==.
	drop $dflorigwgt
	sort $dflvarlist $dflbyvar
	
	merge 1:m ${dflvarlist} ${dflbyvar} using ${file_compl}
	drop if _merge==2
	gen dfl = zzfactor*$dflorigwgt
	drop zz* _merge
	drop one
	save ${file_compl}_main, replace


erase ${file_compl}.dta	
erase ${file_compl}2.dta
erase ${file_compl}3.dta
}



///////////////////////////
// Add DFL weights to data
///////////////////////////

forvalues d=594(1)617 {

* fetch panel data
use dflcompl`d'_micro_main, clear
keep id_tx dfl date_compl q_ps treat
merge 1:m id_tx using "Pscore_compl_firm"
drop if _merge==2 
drop _merge
keep if date_taxref_n>=tm(2008m1)

* create a panel

keep id_tx date_taxref_n dfl date_compl q_ps treat $var_outcome 
		
		
* create event - time
gen de`y'=date_taxref_n-`d'
keep if de`y'>=-6&de`y'<=6

save dflcompl`d'_micro_data, replace

* collapse for graph
#delimit ;
collapse (mean) $var_outcome
[w=dfl], by(treat de) fast
;
#delimit cr

save dflcompl`d'_micro_de, replace
} 

