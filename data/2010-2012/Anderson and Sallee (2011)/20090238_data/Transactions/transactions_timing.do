*********************
***** FILE INFO *****
*********************
* Name: transactions_timing
* Author: Soren Anderson
* Date: May 28, 2010
* Description:



*************************
***** PRELIMINARIES *****
*************************
clear
cd
cd "Y:/Biofuels/FFV CAFE/Transactions"
log using transactions_timing.txt, replace text
set more off
set mem 800m



use transactions1
keep if sample==1



***************************************************
***** GENERATE ALTERNATIVE MEASURES OF TIMING *****
***************************************************

* GENERATE TIME RELATIVE TO FIRST SALE OF SAME VEHICLE TYPE
gen datem=ym(year,month)
egen datemin=min(datem), by(group)
gen dater=datem-datemin+1
tab dater, gen(dater)

* GENERATE PRODUCTION DATE
gen mdate=date-daystoturn
gen mmonth=month(mdate)
gen myear=year(mdate)
tab mmonth, gen(mmonth)

* GENERATE TIME RELATIVE TO FIRST PRODUCTION OF SAME VEHICLE TYPE
gen mdatem=ym(myear,mmonth)
egen mdatemin=min(mdatem), by(group)
gen mdater=mdatem-mdatemin+1
tab mdater, gen(mdater)



***************************************************************************************
***** ONLINE APPENDIX FOOTNOTE: FFV PRODUCTION IS CORRELATED WITH GASOLINE PRICES *****
***************************************************************************************

* GENERATE MONTHLY DATE VARIABLE
gen time = ym(year,month)

* WITHOUT STATE DUMMIES
xtreg ffv pg mdater2-mdater48, i(group) fe cluster(time) nonest
tab state, gen(statedum)

* WITH STATE DUMMIES
xtreg ffv pg mdater2-mdater48 statedum2-statedum51, i(group) fe cluster(time) nonest



************************************************************************************************
***** SECTION III.C: DISCUSSION OF WHY FFVS APPEAR TO SPEND FEWER DAYS ON THE DEALER'S LOT *****
************************************************************************************************

* TIME ON THE LOT DECREASES DURING THE MODEL YEAR
xtreg daystoturn mdater, i(group) fe
xtreg daystoturn mdater2-mdater48, i(group) fe

* PROBABILITY OF BEING AN FFV INCREASES DURING THE MODEL YEAR
xtreg ffv mdater, i(group) fe
xtreg ffv mdater2-mdater48, i(group) fe

* FFVS SPEND THE SAME NUMBER OF DAYS ON LOT AS GASOLINE VEHICLES *PRODUCED* AT SAME TIME
egen group_timing = group(group state mdatem)
xtreg daystoturn ffv, i(group_timing) fe cluster(group_timing)



*****************************************************************************
***** FOOTNOTE 16: TIMING OF FFV PRODUCTION DURING MODEL YEAR (TABLES) ******
*****************************************************************************

* GENERATE FLEET VARIABLE
gen fleet="LT" if (bodytype==3 | bodytype==5 | bodytype==7 | bodytype==8 | bodytype==9)
replace fleet="DP" if fleet==""

* GENERATE MFR VARIABLE
gen mfr="GMC" if make=="BUICK" | make=="CHEVROLET" | make=="GMC"
replace mfr="FMC" if make=="FORD" | make=="LINCOLN" | make=="MAZDA" | make=="MERCURY" 
replace mfr="DCC" if make=="CHRYSLER" | make=="DODGE" | make=="JEEP" | make=="PLYMOUTH"
replace mfr="NIS" if make=="NISSAN"

* FFV SHARES IN 6-MONTH INTERVALS BASED ON PRODUCTION DATE, BY MODEL YEAR, MFR, AND FLEET
forvalues t=1/4 {
	gen ffv_`t'=ffv*100 if mdater>(`t'-1)*6 & mdater<=`t'*6
	format ffv_`t' %9.0f
}
gen ffv_5=ffv*100
format ffv_5 %9.0f
table modelyear fleet mfr, c(mean ffv_1 mean ffv_2 mean ffv_3 mean ffv_4 mean ffv_5)

* SAME AS ABOVE BUT MORE DETAIL: MONTH-BY-MONTH FOR SPECIFIC MODELS/DISPLACEMENTS
* EXPLORE FFV PRODUCTION IN MODEL YEARS WHERE AUTOMAKERS EXCEEDED CAP (FORD AND GM IN 2003-2006)
bysort mfr fleet modelyear model_name: tab mdater ffv
bysort mfr fleet modelyear displacement: tab mdater ffv



*****************************************************************************
***** FOOTNOTE 16: TIMING OF FFV PRODUCTION DURING MODEL YEAR (FIGURE) ******
*****************************************************************************

* GENERATE PDFS AND CDFS FOR FFV AND GASOLINE PRODUCTION MONTH
keep if modelyear>=2000 & modelyear<=2006
tab mdater
tab mdater ffv
keep mdater ffv sample
egen group=group(mdater ffv)

collapse (count) sample (median) mdater ffv, by(group)
drop group
reshape wide sample, i(mdater) j(ffv)
ren sample0 gas
ren sample1 ffv

sort mdater
gen cdfffv=sum(ffv)
gen cdfgas=sum(gas)
gen cdftot=cdfffv+cdfgas

sum cdftot
gen pdfffv=ffv/r(max)

sum cdfffv
replace cdfffv=cdfffv/r(max)

sum cdftot
gen pdfgas=gas/r(max)

sum cdfgas
replace cdfgas=cdfgas/r(max)

* FIGURE: PDF OF GASOLINE AND ETHANOL PRODUCTION DURING MODEL YEAR
scatter pdfgas pdfffv mdater if mdater<=24, legend(ring(0) position(10) region(lstyle(none) fcolor(none)) cols(1) label(2 "Flexible-fuel vehicles") label(1 "Gasoline vehicles") rowgap(0) keygap(*.2) symxsize(*.5)) ylabel(0(.01).06) xlabel(0(2)24) sort c(l l) msymbol(none none) lcolor(black black) lpattern(solid shortdash) scheme(s1manual) xtitle("Production month") ytitle("Share of total production") 
graph export timing_pdf.eps, as(eps) preview(off) fontface(Arial) replace



log close
exit
