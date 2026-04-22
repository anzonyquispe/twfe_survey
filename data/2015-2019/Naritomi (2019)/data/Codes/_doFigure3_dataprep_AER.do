***********************************************************************
* Build the data for Event Study around the time of the first complaint  
***********************************************************************
clear all
set more off, perm
set matsize 3000

cd "$MainDir\Data\"


/////////////////////////////////////////////
///// Prepare panel with first complaint data
/////////////////////////////////////////////


// Create a dataset with the first complaint only

*Load panel data with complaints by firm
use "FirmCompl", clear

	* identify first complaint 
	bys id_tx: egen first_compl=min(date_taxref_n) //the firm is only in the data when it receives a complaint; so the first date it is in the data is the date of the first complaint
	keep id_tx first_compl
	duplicates drop
	rename first_compl date_taxref_n
	
	* merge back to the complaints data and only keep data on the first complaint
	merge 1:1 id_tx date_taxref_n using "FirmCompl"
	keep if _merge==3
	drop _merge

save first_compl_firm, replace


// Match the first complaint data with the firm-level panel with outcomes
use "MainData_reprev", clear

merge 1:1 id_tx date_taxref_n using "first_compl_firm"
drop if _merge==2

** flag first complaints 
gen first_compl=0
replace first_compl=1 if _merge==3

** record the date of the first complaint
gen date_compl=date_taxref_n if _merge==3
bys id_tx: egen datefirstcompl=max(date_compl)

drop _merge 

** clean the data
drop if lastdata<576 //droping firms that exited before January 2008
replace date_compl=. if date_compl<584 //before August it was impossible to file complaints - any positive number is an error (very few cases)
drop if date_taxref_n>623 //there are a few data points after the period of analysis (after Dec. 2011)


** save data to create propensity scores
save "Pscore_compl_firm", replace


///////////////////////////////////////////////////////////////////
///// Prepare panel around each event-time for all first complaints
///////////////////////////////////////////////////////////////////


* Create a dataset for each event from 2009m7 - 2011m6
forvalues d=594(1)617 { 

use "Pscore_compl_firm", clear


* Flag fist complaint at date d (0 is never received a complaint up to that point)	
gen firstcompl_`d'=0
replace firstcompl_`d'=1 if datefirstcompl==`d'
drop if datefirstcompl<`d' //drop all that had a complaint before that date 

bys id_tx: egen treat=max(firstcompl_`d') //flag firms that are treated at date d 

*** getting covariates from the registry
merge m:1 id_tx using "cs_registry_cl"
assert _merge!=1
keep if _merge==3
drop _merge


* Drop sectors that do not have any complaint
gen XX_`d'=first_compl if date_taxref==`d'
bys cnae: egen compl_cnae=total(XX_`d')
drop if compl_cnae==0 
drop compl_cnae


* Restric sample to firms that exist and are active all 6 months before and after the first complaint

	* exclude lines with revenue=0 or total number of rec==0
	drop if Rev_all==0|total_rec==0

	* for firms with complaints at time t, restrict to those that have obs for all peridos (6 months before and after)
	gen de=date_taxref_n-datefirstcompl
	keep if de<=6&de>=-6 | de==.
	 
	* drop if there are gaps in the panel
	sort id_tx date_taxref_n
	bys id_tx: gen x=date_taxref_n[_n]-date_taxref_n[_n-1]
	assert x>0
	bys id_tx: egen gap=max(x)
	drop if gap>1
	drop x gap


* 10% Random sample of the group that received no first complaint at time d 
	*Note: That results may differ a bit from the paper depending on this step as the random sample may be different	
preserve
	keep if treat==0 //only consider the non-treated
	keep id_tx
	duplicates drop
	count
	sample 10
	save "sample_nofirst_compl_`d'_micro", replace
restore

merge m:1 id_tx using sample_nofirst_compl_`d'_micro  
gen  sample_nocompl=1 if _merge==3
drop _merge 

keep if sample_nocompl==1|treat==1 //keep the treated and a sample of non-treated

*creating dummies for main types of firm registration 
gen nj_limpart=0 //'Sociedade Empresária Limitada'
replace nj_limpart=1 if cod_natureza_juridica_rfb==2062
gen nj_indentrp=0 //'Empresário (Individual)'
replace nj_indentrp=1 if cod_natureza_juridica_rfb==2135
gen nj_SAF=0 //'Sociedade Anônima Fechada'
replace nj_SAF=1 if cod_natureza_juridica_rfb==2054
gen nj_SAA=0 //'Sociedade Anônima Aberta'
replace nj_SAA=1 if cod_natureza_juridica_rfb==2046
gen nj_other=0
replace nj_other=1 if cod_natureza_juridica_rfb!=2046&cod_natureza_juridica_rfb!=2054&cod_natureza_juridica_rfb!=2135&cod_natureza_juridica_rfb!=2062

* create lag versions of 
tsset id_tx date_taxref_n
foreach x in Rev_allp99 total_rec NumRec NumCons {
gen `x'_2=`x' ^2
gen `x'_3=`x' ^3
gen L`x' =L.`x' 
gen L2`x' =L2.`x' 
gen L3`x' =L3.`x' 
}
foreach x in Rev_allp99 total_rec NumRec NumCons {
foreach y in L L2 L3{
gen `y'`x'_2=`y'`x' ^2
gen `y'`x'_3=`y'`x' ^3
}
}

keep if date_taxref==`d'

global x_nofactor location year_born nplants nj* L* L2* L3*

keep firstcompl_`d' Rev_allp99 total_rec NumRec NumCons ${x_nofactor} cnae id_tx  
gen event=`d'

duplicates drop
save "PS_first_compl_firmdata_`d'_micro", replace
}


/////////////////////////////////////////////////
///// Estimate a propensity score for each event 
/////////////////////////////////////////////////


******** Pscore for each first complaint event 2009m7 and 2011m6
forvalues d=594(1)617 {  

use "PS_first_compl_firmdata_`d'_micro", clear
isid id_tx
gen treat=firstcompl_

**Pscore with logit
xi: logit treat  ${x_nofactor} i.cnae 

predict double pscore 

*Predict pscore & replace values outside common support
				bys firstcompl_ : egen aux1=max(pscore)
				bys firstcompl_ : egen aux2=min(pscore)
				egen ubound=min(aux1)
				egen lbound=max(aux2)
				replace pscore=. if pscore>ubound | pscore<lbound
				gen dpscore=(pscore!=.) 
				drop aux*
				
*Generate pscore quartiles	
				xtile q_ps = pscore, nq(4)
				keep if q_ps!=. & pscore!=.
				
			*check pscores
			local var pscore
			twoway histogram `var'  if firstcompl_==1,   blcolor(gs12) bfcolor(gs11)   ///	
				|| histogram `var' if firstcompl_==0,  blcolor(black) bfcolor(none)  ///	
				legend(order(1 "complaint" 2 "no complaint") size(small)) ///
				xlabel() ylabel(,labsize(small) noticks ) graphregion(color(white))
				graph save "temp\ps_first_compl_`d'_micro", replace


keep id_tx pscore q_ps firstcompl_`d'
gen compl_date=`d'
isid id_tx
save "ps_first_compl_`d'_micro", replace
}
