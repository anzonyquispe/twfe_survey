*********************************************************************************************************
*Figure A3
*Compare SP with the rest of the country 
*Retail/Wholesale from survey within SP vs. rest of the country using the PAC (Pesquisa Anual do Comercio)
*The third line in the graph ``Sao Paulo (tax data)" uses administrative data 
**********************************************************************************************************
clear all
set more off
# delimit cr

global MainDir "XX\Replication" /* replace XX with the directory path*/
cd "$MainDir\Data"


// Prepare data


//Other states
use PACdata, clear

*created a number identifier for each state
egen id=group(state)
tab state, sum(id) 
keep if id!=26 //"S�o Paulo"

*define treatment
gen treat=0 if sec=="wholesale" 
replace treat=1 if sec=="retail"|sec=="motorvehicles" //in the CNAE 2.0 used in the paper, motorvehicles is split between retail and wholesale; here is its own category and was assigned to retail

keep rb year treat
drop if treat==.

*aggregate revenue by state and sector group
collapse (sum) rb, by(year treat)


reshape wide rb, i(year) j(treat)
gen ratiorb =rb1/rb0
sum ratiorb 

save rb_aux_Other, replace



//Sao Paulo

use PACdata, clear

*created a number identifier for each state
egen id=group(state)
tab state, sum(id) 
keep if id==26 //"S�o Paulo"


*** define treatment
gen treat=0 if sec=="wholesale" 
replace treat=1 if sec=="retail"|sec=="motorvehicles" //in the CNAE 2.0 used in the paper, motorvehicles is split between retail and wholesale; here is its own category and was assigned to retail. 

keep rb year treat
drop if treat==.

collapse (sum) rb_SP=rb, by(year treat)


reshape wide rb, i(year) j(treat)
gen ratiorb_SP =rb_SP1/rb_SP0
sum ratiorb_SP 

save rb_aux_SP, replace

* merge datasets

use rb_aux_SP, clear
merge 1:1 year using "rb_aux_Other.dta"
merge 1:1 year using "rb_taxdata" //merge with admin data; not publicly available
keep if year>=2004


	foreach y in ratiorb_SP ratiorb {
	egen auxsc`y'=mean(`y') if year<=2007
	egen scale`y'=max(auxsc`y')
	gen s`y'=`y'/scale`y'
	drop aux*
	}


// Figure A3
	
				************* SP vs Other States (FIGURE 5)
				twoway scatter  ssptax year if year>=2004, c(l) lpattern(solid) lcolor(back) mcolor(back)   ///
				|| scatter  sratiorb year if year>=2004, c(l) lpattern(solid) lcolor(gray)  mcolor(gray) msymbol(d) ///
				|| scatter  sratiorb_SP year if year>=2004, c(l) lpattern(dash) lcolor(gray) mcolor(gray) msymbol(oh) ///
				legend(order(1 "Sao Paulo(tax data)"  2 "Brazil(survey data)" 3 "Sao Paulo(survey data)" ) rows(2) size(medlarge) region(lwidth(none) lstyle(none)))  ///
				xline(2007, lcolor(red) lwidth(thin) lpattern(dash) )  ///  
				xtitle("") ytitle("Retail/wholesale revenue ratio""Scaled by the pre-2007 average", size(medlarge) height(10))  ylabel(0.4(.4)1.6, grid labsize(medium)) ymtick(, grid) xmtick(, grid) ///
				graphregion(fcolor(white))  xlabel(2004(1)2010, labsize(medlarge))

				