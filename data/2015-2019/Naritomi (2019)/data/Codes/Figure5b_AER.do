**********
*Figure 5b
*tax/gdp
**********
 
clear all
set more off
# delimit cr

global MainDir "XX\Replication" /* replace XX with the directory path*/
cd "$MainDir\Data"

// Prepare data

** merge tax data and GDP data
use "tax_bacen", clear

rename ano year
rename ICMS tax //"Arrecadação de ICMS" by the Brazilian Central Bank (BACEN)

merge 1:1 year sigla using "pib_IBGE"
drop if year==2012

** drop aggregates by region
drop if sigla=="CO"| sigla=="N"| sigla=="NE"|sigla=="Sudeste"

** flag the state of Sao Paulo
gen non_SP=1 if sigla!="SP"
replace non_SP=0 if sigla=="SP"


** Aggregate SP vs other states
foreach x in pib tax{
bys year non_SP: egen total_`x'=total(`x')
}

collapse (sum) pib tax , by(year non_SP)

** Generate outcome of tax over GDP (PIB in portuguese)
gen tax_gdp=tax/pib
drop tax pib

reshape wide tax_gdp, i(year) j(non_SP)


// Figure 6b
		
twoway || scatter tax_gdp0 year if year<2012, c(l)  mcolor(black) lcolor(black) ///
|| scatter tax_gdp1 year if year<2012 , c(l) msymbol(oh) lpattern(dash) mcolor(black) lcolor(gray) /// 
xline(2007, lpattern(dash) lcolor(red) lwidth(thin)) legend(order(1 "Sao Paulo"  2 "Brazil") rows(1) size(medlarge) region(lwidth(none) lstyle(none))) ///
graphregion(fcolor(white)) xtitle("") ytitle("Total VAT/GDP", size(medlarge) height(10)) xlabel(2004(1)2011, labsize(medlarge)) ylabel(0.025(0.025)0.1, labsize(medlarge))
