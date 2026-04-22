***********************************************************
** Auxiliary file to create DFL weights for Fig A6 analysis 
***********************************************************

* generate treatment dummy
gen treat=1 	if sample_treat==1
replace treat=0 if sample_ctrl==1
tab treat, mis

* ensure common support and exclude outliers in terms of quantity of lottery tickets (qtdebilhetes)
drop if qtdebilhetes>40 // 40 lottery tickets is the minimal p99 value held by the control group in a lottery draw

* create month var
gen auxdate = dofm(date_taxref_n)
format auxdate %d
gen month=month(auxdate)
gen year=year(auxdate)
drop auxdate

*****************************************************
*groups being reweighted: treatment-event
gen yrmonthwon = (year*1000)+(month*10)+treat //converts the year variable (2002) into a year+month+treatment (2002021 or 2002020)

*the value of $dflbyvar that all  $dflbyvar groups are supposed to be reweighted to resemble:
gen yrmonth = (year*1000)+(month*10)+1  //I need to rewight each group for each event; if it was one event I would set 2005071 the value of $dflbyvar that all $dflbyvar groups are supposed to be reweighted to resemble

*original weight
gen one=1	

*****************************************************

* create an identifier that is id-cons + event_date
format iddest %25.0g
		*br iddest
gen double ID_iddest=1000*iddest
format  ID_iddest %25.0g
gen double ID_comb=ID_iddest+date_taxref_n
format  ID_comb %25.0g

* create cells of lottery dates and lottery ticket holding
gen double XXX=1000*qtdebilhetes
gen double lot_tix=XXX+date_taxref_n
drop X*

* add control group
merge 1:1 ID_comb using sample_ctrl_10
keep if _merge==3|win==1
drop _merge	


// Prepare to generate DFL weights	
capture drop zz* _merge tempdflorigwgt

***General code:
global dflbyvar = "yrmonthwon" 
global dflorigwgt = "one" // original weight (should be set to a var equal to 1 if no original weight); lagged revenue
global balanceacrossdflbyvar=0
global dflvarlist = "qtdebilhetes" // $dflvarlist = list of all vars that the the $dflbyvar groups are being reweighted on
global dflbyvarbasegroup = "yrmonth" 

capture drop _merge dfl zz*
sort $dflvarlist $dflbyvar
save ${file}, replace

use ${file}, clear
collapse (sum) $dflorigwgt, by($dflvarlist $dflbyvar $dflbyvarbasegroup)
drop if qtdebilhetes==.
isid ${dflvarlist} ${dflbyvar} // dflbyvarbasegroup should not add any obs
save ${file}2, replace

	forvalue lottery=2009061(10)2009121{
	global lottery=`lottery'
	do "$MainDir\Codes\aux_programs\dfl_aux.do"
	}

	forvalue lottery=2010011(10)2010121{
	global lottery=`lottery'
	do "$MainDir\Codes\aux_programs\dfl_aux.do"
	}

	forvalue lottery=2011011(10)2011061{
	global lottery=`lottery'
	do "$MainDir\Codes\aux_programs\dfl_aux.do"
	}
	
set more off
# delimit cr

****Restrict attention to lotteries for which I can observe 6 months before and 6 months after:2009m6 - 2011m6
use ${file}2009061, clear
set more off

	forvalue lottery=2009071(10)2009121{
	append using ${file}`lottery'
	drop month year yrmonthwon yrmonth date_taxref date_lotref
	}

	forvalue lottery=2010011(10)2010121{
	append using ${file}`lottery'
	drop month year yrmonthwon yrmonth date_taxref date_lotref
	}

	forvalue lottery=2011011(10)2011061{
	append using ${file}`lottery'
	drop month year yrmonthwon yrmonth date_taxref date_lotref
	}

save "DFL_${file}", replace

**** construct a dataset with only ids from T and C of the lottery
use "DFL_${file}", clear
keep iddest
duplicates drop

merge 1:m iddest using "ConsDF_bal_lot" //balanced panel of NFP receipts; includes all consumers
drop if _merge!=3
drop _merge

save ${file}DF_PF1yrlot, replace


*** creating one dataset for each lottery

forvalues y=593(1)617 {

use "DFL_${file}", clear
keep if date_taxref_n==`y'
drop sorteio date_lotref
foreach x in sumprize nprize qtdebilhetes treat dfl{
rename `x' `x'`y'
}
order iddest date_taxref_n
rename date_taxref_n event`y'
save ${file}lot`y', replace

*** find participants in lottery `y' in the receipts data
keep iddest 
isid iddest
merge 1:m iddest using ${file}DF_PF1yrlot //already balanced
drop if _merge!=3
drop _merge

*** merge with lottery data
merge m:1 iddest using ${file}lot`y'
drop if _merge!=3
drop _merge

*** create count of months since lottery event
gen de`y'=date_taxref_n-event`y'
keep if de`y'>=-6 & de`y'<=12 

save ${file}lot`y'_micro, replace

foreach x in NumRecp99 ValueRecp99 {
gen p50`x'`y'=`x'
rename `x' `x'`y'
}

*** Collapse for graph
#delimit ;
collapse (mean) NumRecp99 ValueRecp99 
(median) p50*
[w=dfl], by(treat de) fast
;
#delimit cr

save ${file}lot`y', replace
} 

****ERASE FILES
	forvalue lottery=2009061(10)2009121{
	erase ${file}`lottery'.dta
	}

	forvalue lottery=2010011(10)2010121{
	erase ${file}`lottery'.dta
	}
	
	forvalue lottery=2011011(10)2011061{
	erase ${file}`lottery'.dta
	}
	
erase ${file}.dta	
erase ${file}2.dta
erase ${file}3.dta
erase ${file}DF_PF1yrlot.dta

}


//////////////////////////////////
// Append lotteries for panel data
//////////////////////////////////

foreach l in 10 20 30 50 250 1000{
global fileprize prize_`l'
 
*** Organize data for appending
forvalues x=593(1)617 {
	use ${fileprize}lot`x'_micro.dta, clear
	count
	gen event_date=`x'
	foreach w in treat dfl de{
	rename `w' `w'
	}

	save ${fileprize}lot`x'_micro_long.dta, replace
}


use ${fileprize}lot593_micro_long.dta, clear
drop  event593 ID_iddest ID_comb 
keep if de<=6&de>=-3 //look at 6 months after and three months before lottery event
forvalues y=594(1)617 {
append using ${fileprize}lot`y'_micro_long.dta  		
keep if de<=6&de>=-3 
drop  event`y' ID_iddest ID_comb 
}    
    
save "lot_micro_long_${fileprize}.dta", replace
