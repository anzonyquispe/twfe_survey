*********************************
* Figure 1 
* NFP Receipts and revenue shares
*********************************
clear all
set more off, perm

global MainDir "XX\Replication" /*replace XX with the main directory*/
cd "$MainDir\Data\"

// Prepare data

use NFP_byplant, clear		
		
* add up the total values of sales with NFP receipts and total revenue		
foreach x in numrecpf valuerecpfp99 Rev_allp99 {
bys treatRW date_taxref_n: egen sum_`x'=sum(`x')
}

* tag obs for graph
bys treatRW date_taxref_n: gen index_treatRW=1 if _n==1

gen date_taxref=date_taxref_n
format date_taxref %tm
sort date_taxref

// Figure 1a: Number of receipts with SSNs

gen million_sum_numrecpf=sum_numrecpf/1000000
local y million_sum_numrecpf
twoway scatter `y' date_taxref if treatRW==1&index_treatRW==1&date_taxref_n>=tm(2009m1), c(l)  lpattern(solid) lcolor(back) lwidth(thin) mcolor(back) msize(small) ///
|| scatter `y' date_taxref if treatRW==0&index_treatRW==1&date_taxref_n>=tm(2009m1),  c(l) lpattern(solid) lcolor(gray) lwidth(thin) mcolor(gray) msymbol(oh) ///
legend(order(1 "Retail"  2 "Wholesale") rows(1) size(small)) legend(region(lstyle(none)))  ///
graphregion(fcolor(white)) xtitle("") ytitle("Total number of receipts with SSN") ylabel(0[10]150,labsize(small) ) ///
saving(temp/`y', replace)


// Figure 1b: Share of Revenue covered by SSN receipts

gen share_valuesum=sum_valuerecpfp99/sum_Rev_allp99
local y share_valuesum
twoway scatter `y' date_taxref if treatRW==1&index_treatRW==1&date_taxref_n>=tm(2009m1), c(l)  lpattern(solid) lcolor(back) lwidth(thin) mcolor(back) msize(small) ///
|| scatter `y' date_taxref if treatRW==0&index_treatRW==1&date_taxref_n>=tm(2009m1), c(l) lpattern(solid) lcolor(gray) lwidth(thin) mcolor(gray) msymbol(oh) ///
legend(order(1 "Retail"  2 "Wholesale") rows(1) size(small)) legend(region(lstyle(none)))  ///
graphregion(fcolor(white))  xtitle("") ytitle("Share of reported revenue from SSN receipts") ylabel(0[.05].4,labsize(small) ) ///
saving(temp/`y', replace)


