capture log close
clear
set matsize 3000
set more off

********drug homicide rate
use table2, clear 

keep if drughom!=.

*collapse to pre/post/ld periods
g T=.
replace T=-1 if (postInn==0 & postElec==0) 
replace T=1 if postInn==1
replace T=0 if postElec==1

g deathsx=(drughom/pob_t)*100000*12

collapse (mean) pob_total deathsx PANwin spread, by(T id_mun)

keep if abs(spread)<.055

tempfile tempdata
save `tempdata', replace


forvalues T=-1/1 {
	use `tempdata', clear
	keep if T==`T'
	save temp`T', replace

	lpoly deathsx spread if (spread>0 & spread<.05) [aw=pob_tot], kernel(rectangle) bwidth(.05) degree(2)  generate(x s) se(se) 
	keep x s se 
	drop if x==.
	save RD, replace

	use temp`T', clear
	lpoly deathsx spread if (spread<0 & spread>-.05) [aw=pob_tot], kernel(rectangle) bwidth(.05) degree(2)  generate(x s) se(se) nograph
	keep x s se 
	drop if x==.
	append using RD
	
	g ciplus=s+1.96*se
	g ciminus=s-1.96*se
	keep if abs(x)<.05
	save RD, replace

	
	*---generate bins for taking averages---*
	
	use temp`T', replace
	keep if abs(spread)<.05
	
	gen bin5=.
	foreach X of num 0(.005).05 {
		di "`X'"
		replace bin=-`X' if (spread>=-`X' & spread<(-`X'+.005) & spread<0)
		replace bin=`X' if (spread>`X' & spread<=(`X'+.005))
	}
	tab bin5
	
	drop if bin5==.
	collapse deathsx spread [aw=pob_total], by(bin5)
	
	append using RD
	
	twoway (connected s x if x>0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) /*
	*/(connected ciplus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/(connected ciminus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/(connected s x if x<0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) /*
	*/(connected ciplus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/(connected ciminus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/ (scatter deathsx spread, sort msize(med)xline(0) mcolor(black)), /*
	*/ legend(off) graphregion(color(white)) /*
	*/ ytitle("Drug homicide rate") xlabel(-0.05(0.05)0.05) xsc(r(-.05 .05)) ylabel(-20(20)80) ysc(r(-20 80)) xtitle(PAN margin of victory) /*
	*/xline(0, lpattern(shortdash) lc(black)) ylab(,nogrid) /*
	  */ saving(Fig3.gph,replace)
	graph export fig3_`T'.eps, replace
}



********drug homicide indicator
use table2, clear 

keep if drughom!=.

*indicator
g deathsx=0
replace deathsx=1 if drughom>0

*collapse to pre/post/ld periods
g T=.
replace T=-1 if (postInn==0 & postElec==0) 
replace T=1 if postInn==1
replace T=0 if postElec==1

collapse (mean) pob_total deathsx PANwin spread, by(T id_mun)

keep if abs(spread)<.055

tempfile tempdata
save `tempdata', replace


forvalues T=-1/1 {
	use `tempdata', clear
	keep if T==`T'
	save temp`T', replace

	lpoly deathsx spread if (spread>0 & spread<.05), kernel(rectangle) bwidth(.05) degree(2)  generate(x s) se(se) 
	keep x s se 
	drop if x==.
	save RD, replace

	use temp`T', clear
	lpoly deathsx spread if (spread<0 & spread>-.05), kernel(rectangle) bwidth(.05) degree(2)  generate(x s) se(se) nograph
	keep x s se 
	drop if x==.
	append using RD
	
	g ciplus=s+1.96*se
	g ciminus=s-1.96*se
	keep if abs(x)<.05
	save RD, replace

	
	*---generate bins for taking averages---*
	
	use temp`T', replace
	keep if abs(spread)<.05
	
	gen bin5=.
	foreach X of num 0(.005).05 {
		di "`X'"
		replace bin=-`X' if (spread>=-`X' & spread<(-`X'+.005) & spread<0)
		replace bin=`X' if (spread>`X' & spread<=(`X'+.005))
	}
	tab bin5
	
	drop if bin5==.
	collapse deathsx spread, by(bin5)
	
	append using RD
	
	twoway (connected s x if x>0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) /*
	*/(connected ciplus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/(connected ciminus x if x>0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/(connected s x if x<0, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medthick)) /*
	*/(connected ciplus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/(connected ciminus x if x<0, sort msymbol(none) clcolor(black) clpat(shortdash) clwidth(thin)) /*
	*/ (scatter deathsx spread, sort msize(med)xline(0) mcolor(black)), /*
	*/ legend(off) graphregion(color(white)) /*
	*/ ytitle("Monthly probability of drug-related homicide") xlabel(-0.05(0.05)0.05) xsc(r(-.05 .05)) ylabel(0(.2)1) ysc(r(0 1)) xtitle(PAN margin of victory) /*
	*/xline(0, lpattern(shortdash) lc(black)) ylab(,nogrid) /*
	  */ saving(Fig3_ind.gph,replace)
	graph export fig3_ind_`T'.eps, replace
}

