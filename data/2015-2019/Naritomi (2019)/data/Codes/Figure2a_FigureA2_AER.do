*************************
* Figure 2a and Figure A2
* Raw data
*************************
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/
cd "$MainDir\Data\

// Prepare data

use SectorData, clear

* create date in readable format for graph
gen time=date_taxref_n
format time %tm
			
* create an "other" category
gen treatRW_all= treatRW
replace treatRW_all=2 if treatRW==. //if not retail or wholesale

* tag observations for graphs
egen tagg=tag(treatRW_all time)

* scale for figure
bys treatRW date_taxref_n: egen agr_Rev_allp99=mean(Rev_allp99)
bys treatRW date_taxref_n: gen index_Rev_allp99=1 if _n==1
bys treatRW: egen auxscRev_allp99=mean(Rev_allp99) if date_taxref_n<=tm(2007m10)
bys treatRW: egen scaleRev_allp99=max(auxscRev_allp99)
gen sRev_allp99=agr_Rev_allp99/scaleRev_allp99
drop aux* scale agr* scale*
	

// Figure 2a

	twoway scatter sRev_allp99 time if index_Rev_allp99==1&treatRW_all==1, c(l) lpattern(solid) lcolor(back) lwidth(thin) mcolor(back) msize(small) ///
	||scatter sRev_allp99 time if index_Rev_allp99==1&treatRW_all==0,  c(l) lpattern(solid) lcolor(gray) lwidth(thin) mcolor(gray) msymbol(oh) ///
	legend(order(1 "Retail"  2 "Wholesale") rows(1) size(small)) saving(temp/Figure2a, replace) ///
	legend(region(lstyle(none))) xline(580, lpattern(dash) lcolor(red) lwidth(thin) )  xline(573, lpattern(dash) lcolor(red) lwidth(thin) ) xline(587, lpattern(solid) lcolor(red) lwidth(thin) ) ///
	ylabel(, grid) ymtick(, grid) xmtick(, grid) xlabel(528[5]623,labsize(small) valuelabel angle(vert)) ///
	graphregion(fcolor(white))  
	
// Figure A2
	
	twoway scatter sRev_allp99 time if index_Rev_allp99==1&treatRW_all==1, c(l) lpattern(solid) lcolor(back) lwidth(thin) mcolor(back) msize(small) ///
	||scatter sRev_allp99 time if index_Rev_allp99==1&treatRW_all==0,  c(l) lpattern(solid) lcolor(gray) lwidth(thin) mcolor(gray) msymbol(oh) ///
	||scatter sRev_allp99 time if index_Rev_allp99==1&treatRW_all==2,  c(l) lpattern(dash) lcolor(black) lwidth(thin) mcolor(black) msymbol(x) ///
	legend(order(1 "Retail"  2 "Wholesale" 3 "Other sectors")  rows(1) size(small)) saving(temp/FigureA2, replace) ///
	legend(region(lstyle(none))) xline(580, lpattern(dash) lcolor(red) lwidth(thin) )  xline(573, lpattern(dash) lcolor(red) lwidth(thin) ) xline(587, lpattern(solid) lcolor(red) lwidth(thin) ) ///
	ylabel(, grid) ymtick(, grid) xmtick(, grid) xlabel(528[5]623,labsize(small) valuelabel angle(vert)) ///
	graphregion(fcolor(white))  
	
	
