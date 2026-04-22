****************************************
* Figure 3 and estimation of coefficient
****************************************

cd "$MainDir\Codes\"

//////////////
// Figure 3
//////////////


* append and aggregate data with event studies

use dflcompl594_micro_de, clear
forvalues d=595(1)617 {
append using dflcompl`d'_micro_de.dta
}

collapse (mean) Rev_allp99 total_rec, by(treat de) fast


* scale outcomes by pre-treatment mean
foreach y in Rev_allp99 total_rec{
bys treat de: egen sum_`y'=mean(`y')
bys treat: egen auxsc`y'=mean(`y') if de<=-1
bys treat: egen scale`y'=max(auxsc`y')
gen s`y'=sum_`y'/scale`y'
drop aux* scale*

}

* graphs
	foreach x in Rev_allp99 total_rec{
		sort de
		local y s`x'
				twoway scatter  `y' de if treat==1, c(l) msymbol(oh) lcolor(black) fcolor(black) mcolor(black) ///
				|| scatter  `y' de if treat==0, c(l)  msymbol(oh) lpattern(dash)  lcolor(gs9) fcolor(gs9) mcolor(gs9) ///
					legend(order(1 "Complaint"  2 "No complaint") size(small) rows(1)) ///
					legend(region(lstyle(none))) title("`y'", size(medium)) ///  
					xtitle("") ylabel(0.7(.1)1.3, grid) xlabel(-6[1]6,labsize(small)) ///
					graphregion(fcolor(white))  xline(0, lpattern(dash) lcolor(red) lwidth(thin) ) 
					graph save "temp\Fig3_`y'", replace
					
	}
		


		
////////////////////////////
// Estimates in Figure 3
////////////////////////////

* append event studies
use dflcompl594_micro_data, clear
forvalues d=595(1)616 {
append using dflcompl`d'_micro_data.dta
}

* restrict to a 6 month window around the event  
keep if de<=6&de>=-6

* generate DD variable before and after the event
gen dd=0
replace dd=1 if  treat==1&de>=0
gen post_d=(de>=0)

* take log of outcomes
foreach y in  Rev_allp99 total_rec{
gen ln`y'=ln(`y')	
	
}

* create a balanced panel

	*Making sure sample is balanced for each outcome; should be balanced based on data construction
	foreach y in  Rev_allp99 total_rec{
	gen YYY=(ln`y'==.)
	bys id: egen YY= max(YYY) 
	gen balsampl_`y'=(YY!=1)
	drop YY*	
	}

	*restrict to same sample across all outcomes
	gen min_sample=(balsampl_Rev_allp99==1&balsampl_total_rec==1) 


* tag obs for graph
egen tagg=tag(treat de)

* create an identifier that is firm-complaint date
egen ID_comb=concat(id_tx date_compl)
egen ID_num=group(ID_comb)	

* regressions

	*create file to store estimates
	global outfilecompl "temp\regs_micro_compl.xls"
	reg Rev_allp99 Rev_allp99
	outreg2 using ${outfilecompl}, nolabel bracket excel nonotes replace

foreach y in Rev_allp99 total_rec{
	
	local se date_compl  //cluster s.e. by date of first complaint
	areg ln`y' dd treat i.x i.date_taxref_n i.date_compl [pw=dfl] if  min_sample==1,  absorb(ID_num) vce(cluster `se') 
	outreg2 using ${outfilecompl}, nolabel bracket excel nonotes append
			
}	


		