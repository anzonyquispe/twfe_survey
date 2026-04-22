******************
* Figure D.2
* Number of firms
******************

clear all
set more off, perm

global MainDir "C:\Users\NARITOMI\Work\Replication" /*put in XX the main directory*/
cd "$MainDir\Data\"

// Prepare data

use MainData_reprev.dta, clear

		************* Get month and year ************
		gen date_taxref=date_taxref_n
		format date_taxref %tm

		gen auxdate=dofm(date_taxref_n)
		format auxdate %d
		gen month=month(auxdate)
		gen year=year(auxdate)
		drop auxdate
		
	* flag firms that have zero revenue or missing revenue
	bys year id_: gen flfirm_Rev_all=sum(Rev_allp99)
	gen Dflagid_firmRev_all=(flfirm_Rev_all==0|flfirm_Rev_all==.)

	* flag firms that are active
	gen flag_pos=1 if Dflagid_firmRev_all!=1
	
	* flag one obs per firm and year 
	bys id_ year: gen x_firm=1 if _n==1
	
	* restrict attention to active firms 
	gen x_firmRev_allpos=x_firm 
	replace x_firmRev_allpos=0 if flag_pos!=1
 
  
* count number of active firms by sector 
collapse (sum)x_firmRev_allpos, by(cnae year treatRW)

isid cnae year

* means by ear and sector group

		bys treat year: egen grx_firmRev_allpos=mean(x_firmRev_allpos)	
		gen lngrx_firmRev_allpos=ln(grx_firmRev_allpos)
		gen lnx_firmRev_allpos=ln(x_firmRev_allpos)

* tag for graph
egen tagg=tag(treat year)


* create DD
gen post=0
replace post=1 if year>=2007
gen dd=treat*post


// Figure D2: graph and coefficient
	
	*Graph
	sort year
	local z x_firmRev_allpos
				twoway scatter  lngr`z' year if treat==1 &tagg==1& year>=2004&year<=2011, c(l)  lpattern(solid) lcolor(back) lwidth(thin) mcolor(back) msize(small) ///
				|| scatter  lngr`z' year if treat==0&tagg==1&year>=2004&year<=2011, c(l) msymbol(oh) lpattern(dash) lcolor(gray) lwidth(thin) mcolor(gray) msymbol(oh) ///
					legend(order(1 "Retail"  2 "Wholesale") rows(1) size(small))   ///
					legend(region(lstyle(none))) title("") xline(2007,  lpattern(dash) lwidth(thin))  xline(2008,  lpattern(dash) lwidth(thin)) ///  
					xlabel(2004[1]2011) ytitle("`z'") xtitle("") ylabel(, grid) ymtick(, grid) xmtick(, grid) ///
					graphregion(fcolor(white)) saving(temp/`z', replace)
					

	*Coefficient 
	areg ln`z' dd i.year if year>=2004&year<=2011, absorb(cnae)  vce(cluster cnae)
	outreg2  dd using "Results\FigureD2", nolabel bracket excel   coefastr se replace		


			
 