version 15.0
clear all
set more off
set scheme s1mono
set matsize 1000

*=============================
* Table 7 & associated figures
*=============================

prog main
	use "data/infutor/panel_for_parcel_regs.dta", clear

	glo smpl1 year>=1990 & use_code == 3 & ((yearbuilt_orig>=1900 & yearbuilt_orig<=1990) | bltfuture_treat==1)
	glo smpl2 year>=1990 & use_code2 == 3 & ((yearbuilt_orig>=1900 & yearbuilt_orig<=1990) | bltfuture_treat==1)

	*==============
	* Population
	*==============
	
	drop year_cat treat_year_cat
	gen year_cat = 1 if year<=1994
	replace year_cat = 2 if year>=1995 & year<=2000
	replace year_cat = 3 if year>=2001 & year<=2006
	replace year_cat = 4 if year>=2007
	gen treat_year_cat = treat*year_cat
	
	* Note the shifting in labeling, treating 1994 as baselevel, but it represents omitting 1993
	capture label drop treat_year_catl
	label define treat_year_catl 0 "\quad 0" 1 "\quad 1989-1993" 2 "\quad 1994-1999" 3 "\quad 2000-2005" 4 "\quad Post 2006"
	label values treat_year_cat treat_year_catl
	
	eststo clear
	reg_parcel_year pop_n2_w if ${smpl1} & high_rent==1 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est1) baselevelpos(5) maxyr(2013)
	
	reghdfe pop_n2_w io0b1.treat_year_cat if ${smpl1} & high_rent==1 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", replace 
	putexcel A1 = "Population/Average Population 1990-1994"
	putexcel B1 = `=string($beta1,"%4.3f")'
	putexcel C1 = `=string($se1,"%4.3f")'
	
	* Note x-label is shifted by one year
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Population/Avg Pop 90-94) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_pop2_highrent.pdf", replace

	eststo clear
	reg_parcel_year pop_n2_w if ${smpl1} & high_rent==0 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est2) baselevelpos(5) maxyr(2013)
	
	reghdfe pop_n2_w io0b1.treat_year_cat if ${smpl1} & high_rent==0 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", replace 
	putexcel A1 = "Population/Average Population 1990-1994"
	putexcel B1 = `=string($beta1,"%4.3f")'
	putexcel C1 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Population/Avg Pop 90-94) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_pop2_lowrent.pdf", replace
	
	*==============
	* Renters
	*==============

	eststo clear
	reg_parcel_year ren_n2_w if ${smpl1} & high_rent==1 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est1) baselevelpos(5) maxyr(2013)
	
	reghdfe ren_n2_w io0b1.treat_year_cat if ${smpl1} & high_rent==1 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", modify
	putexcel A2 = "Renters/Average Population 1990-1994"
	putexcel B2 = `=string($beta1,"%4.3f")'
	putexcel C2 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Renters/Avg Pop 90-94) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren2_highrent.pdf", replace

	eststo clear
	reg_parcel_year ren_n2_w if ${smpl1} & high_rent==0 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est2) baselevelpos(5) maxyr(2013)
	
	reghdfe ren_n2_w io0b1.treat_year_cat if ${smpl1} & high_rent==0 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", modify
	putexcel A2 = "Renters/Average Population 1990-1994"
	putexcel B2 = `=string($beta1,"%4.3f")'
	putexcel C2 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Renters/Avg Pop 90-94) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren2_lowrent.pdf", replace
	
	*========================
	* Renters in RC buildings
	*========================

	eststo clear
	reg_parcel_year ren_n2_rc if ${smpl1} & high_rent==1 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est1) baselevelpos(5) maxyr(2013)
	
	reghdfe ren_n2_rc io0b1.treat_year_cat if ${smpl1} & high_rent==1 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", modify
	putexcel A3 = "Renters in Rent-Controlled Buildings/Average Population 1990-1994"
	putexcel B3 = `=string($beta1,"%4.3f")'
	putexcel C3 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Renters in Rent-Controlled Buildings) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren2_rc_highrent.pdf", replace

	eststo clear
	reg_parcel_year ren_n2_rc if ${smpl1} & high_rent==0 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est2) baselevelpos(5) maxyr(2013)
	
	reghdfe ren_n2_rc io0b1.treat_year_cat if ${smpl1} & high_rent==0 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", modify
	putexcel A3 = "Renters in Rent-Controlled Buildings/Average Population 1990-1994"
	putexcel B3 = `=string($beta1,"%4.3f")'
	putexcel C3 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Renters in Rent-Controlled Buildings) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren2_rc_lowrent.pdf", replace
	
	*========================
	* Renters in Redevelopped buildings
	*========================

	eststo clear
	reg_parcel_year ren_n2_norc if ${smpl1} & high_rent==1 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est1) baselevelpos(5) maxyr(2013)
	
	reghdfe ren_n2_norc io0b1.treat_year_cat if ${smpl1} & high_rent==1 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", modify
	putexcel A4 = "Renters in Redeveloped Buildings/Average Population 1990-1994"
	putexcel B4 = `=string($beta1,"%4.3f")'
	putexcel C4 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Renters in Redeveloped Buildings) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren2_norc_highrent.pdf", replace

	eststo clear
	reg_parcel_year ren_n2_norc if ${smpl1} & high_rent==0 & year<=2013, cl(parcel)
	save_coefmat, coefmat(est2) baselevelpos(5) maxyr(2013)
	
	reghdfe ren_n2_norc io0b1.treat_year_cat if ${smpl1} & high_rent==0 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", modify
	putexcel A4 = "Renters in Redeveloped Buildings/Average Population 1990-1994"
	putexcel B4 = `=string($beta1,"%4.3f")'
	putexcel C4 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Renters in Redeveloped Buildings) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_ren2_norc_lowrent.pdf", replace
	
	*========================
	* Owners
	*========================

	eststo clear
	reg_parcel_year own_n2_w if ${smpl1} & high_rent==1 & year<=2013, cl(parcel)	
	save_coefmat, coefmat(est1) baselevelpos(5) maxyr(2013)
	
	reghdfe own_n2_w io0b1.treat_year_cat if ${smpl1} & high_rent==1 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", modify
	putexcel A5 = "Owners/Average Population 1990-1994"
	putexcel B5 = `=string($beta1,"%4.3f")'
	putexcel C5 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Owners/Avg Pop 90-94) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_own2_highrent.pdf", replace

	eststo clear
	reg_parcel_year own_n2_w if ${smpl1} & high_rent==0 & year<=2013, cl(parcel)	
	save_coefmat, coefmat(est2) baselevelpos(5) maxyr(2013)
	
	reghdfe own_n2_w io0b1.treat_year_cat if ${smpl1} & high_rent==0 & year<=2013, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", modify
	putexcel A5 = "Owners/Average Population 1990-1994"
	putexcel B5 = `=string($beta1,"%4.3f")'
	putexcel C5 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) drop(1990.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Owners/Avg Pop 90-94) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_own2_lowrent.pdf", replace 

	*==============
	* Conversions
	*==============

	eststo clear
	reg_parcel_year2 convert_anything if ${smpl2} & high_rent==1, cl(parcel)	
	save_coefmat, coefmat(est1) baselevelpos(4)
	
	drop year_cat treat_year_cat
	gen year_cat = 1 if year<=1993
	replace year_cat = 2 if year>=1994 & year<=1999
	replace year_cat = 3 if year>=2000 & year<=2005
	replace year_cat = 4 if year>=2006
	gen treat_year_cat = treat*year_cat
	
	capture label drop treat_year_catl
	label define treat_year_catl 0 "\quad 0" 1 "\quad 1990-1993" 2 "\quad 1994-1999" 3 "\quad 2000-2005" 4 "\quad Post 2006"
	label values treat_year_cat treat_year_catl
	
	reghdfe convert_anything io0b1.treat_year_cat if ${smpl2} & high_rent==1, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", modify
	putexcel A6 = "Conversion"
	putexcel B6 = `=string($beta1,"%4.3f")'
	putexcel C6 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Conversion) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_convert_highrent.pdf", replace 
	
	eststo clear
	reg_parcel_year2 convert_anything if ${smpl2} & high_rent==0, cl(parcel)	
	save_coefmat, coefmat(est2) baselevelpos(4)
	
	reghdfe convert_anything io0b1.treat_year_cat if ${smpl2} & high_rent==0, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", modify
	putexcel A6 = "Conversion"
	putexcel B6 = `=string($beta1,"%4.3f")'
	putexcel C6 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Conversion) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_convert_lowrent.pdf", replace
	
	*========================
	* Cumulative Add/Alter/Repair per Unit
	*========================
	
	eststo clear
	reg_parcel_year2 acc_permit3_n if ${smpl1} & high_rent==1, cl(parcel)	
	save_coefmat, coefmat(est1) baselevelpos(4)

	reghdfe acc_permit3_n io0b1.treat_year_cat if ${smpl1} & high_rent==1, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_highrent.xlsx", modify
	putexcel A7 = "Cumulative Add/Alter/Repair per Unit"
	putexcel B7 = `=string($beta1,"%4.3f")'
	putexcel C7 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est1[,1]), ci((est1[,2] est1[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Cumulative Add/Alter/Repair per Unit) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_acc_permit3_n_highrent.pdf", replace 
	
	eststo clear
	reg_parcel_year2 acc_permit3_n if ${smpl1} & high_rent==0, cl(parcel)	
	save_coefmat, coefmat(est2) baselevelpos(4)
	
	reghdfe acc_permit3_n io0b1.treat_year_cat if ${smpl1} & high_rent==0, absorb(i.year_cat##i.zipcode parcel) vce(cluster parcel)
	glo beta1=_b[4.treat_year_cat]
	glo se1=_se[4.treat_year_cat]
	
	putexcel set "output/treat_smallmulti_lowrent.xlsx", modify
	putexcel A7 = "Cumulative Add/Alter/Repair per Unit"
	putexcel B7 = `=string($beta1,"%4.3f")'
	putexcel C7 = `=string($se1,"%4.3f")'
	
	coefplot (matrix(est2[,1]), ci((est2[,2] est2[,3])) ///
		lcolor(gs5) recast(line) lwidth(*2) ciopts(recast(rline) lcolor(gs5) lpattern(dash))), ///
		keep(*.treat_year) ///
		xlabel(1 "1990" 6 "1995" 11 "2000" 16 "2005" 21 "2010" 26 "2015", labsize(small)) ///
		yla(, ang(h)) yline(0, lcolor(black) lwidth(vthin)) ///
		vertical baselevels ytitle(Cumulative Add/Alter/Repair per Unit) ///
		note(`"{&beta} = `=string($beta1,"%4.3f")' (`=string($se1,"%4.3f")')"', position(10) ring(0) size(medsmall) margin(medium))
	graph export "output/treat_smallmulti_acc_permit3_n_lowrent.pdf", replace 
end

prog reg_parcel_year	
	syntax varname [if], CLustvar(str)
	
	* Zipcode by year FE
	eststo: reghdfe `varlist' io0b1994.treat_year `if', absorb(i.year##i.zipcode parcel) vce(cluster `clustvar')
end

prog reg_parcel_year2	
	syntax varname [if], CLustvar(str)
	
	* Zipcode by year FE using 1993 as baselevel
	eststo: reghdfe `varlist' io0b1993.treat_year `if', absorb(i.year##i.zipcode parcel) vce(cluster `clustvar')
end

prog save_coefmat
	syntax, coefmat(str) baselevelpos(str) [maxyr(integer 2016)]

	matrix V = e(V)
	matrix B = e(b)

	matrix se = J(1, `=colsof(B)', 0)
	forvalues i = 1(1)`=colsof(B)'{ 
		mat se[1, `i'] = cond(~mi(sqrt(V[`i', `i'])), sqrt(V[`i', `i']), 0)
	}
	matrix lb = J(1, `=colsof(B)', 0)
	matrix ub = J(1, `=colsof(B)', 0)

	* 90% CI
	forvalues i = 1(1)`=colsof(B)' {
		matrix lb[1, `i'] = B[1, `i'] - invttail(e(df_r),0.05) * se[1, `i']
		matrix ub[1, `i'] = B[1, `i'] + invttail(e(df_r),0.05) * se[1, `i']
	}

	matrix B  = [B, 0]
	matrix lb = [lb, 0]
	matrix ub = [ub, 0]

	forvalues i = `=colsof(B)'(-1)`baselevelpos' {
		local j = `i' - 1
		if `i' == `baselevelpos' {
			matrix B[1, `i'] = 0
			matrix lb[1, `i'] = 0
			matrix ub[1, `i'] = 0
		}
		else {
			matrix B[1, `i']  = B[1, `j']
			matrix lb[1, `i'] = lb[1, `j']
			matrix ub[1, `i'] = ub[1, `j']
		}
	}

	matrix `coefmat' = [B', lb', ub']
	loc rownames 1990.treat_year 
	forval yr = 1991/`maxyr' {
		loc rownames `rownames' `yr'.treat_year
	}
	matrix rownames `coefmat' = `rownames'
	matrix drop V B se lb ub
end

main
