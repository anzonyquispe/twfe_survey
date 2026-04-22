*********************
***** FILE INFO *****
*********************
* Name: cafe_compliance_behavior
* Author: Soren Anderson
* Date: May 28, 2010
* Description:



*************************
***** PRELIMINARIES *****
*************************
clear
pause on
set more off
set mem 500m
cd
cd "Y:/Biofuels/FFV CAFE/CAFE compliance"
log using cafe_compliance_behavior.txt, replace text



**************************************************************************
***** TABLE 1: FUEL ECONOMY PERFORMANCE AND FLEXIBLE-FUEL PRODUCTION *****
***************************************************************************
* NOTE: PERFORM ADDITIONAL CALCULATIONS USING THIS OUTPUT IN EXCEL 

use cafe_compliance

* DROP YEARS BEFORE AMFA INCENTIVE TOOK EFFECT
drop if year<1993

* SALES-WEIGHTED GPM: CAFE STANDARD, AMFA, AND ACTUAL
format sales sales_ffv %9.2f
table mfr fleet [weight=sales], c(mean gpm_std) format(%9.5f) cellwidth(10) row
table mfr fleet [weight=sales], c(mean gpm_amfa) format(%9.5f) cellwidth(10) row
table mfr fleet [weight=sales], c(mean gpm_actual) format(%9.5f) cellwidth(10) row

* SALES: FFVS AND TOTAL
table mfr fleet, c(sum sales_ffv) format(%9.0f) cellwidth(10) col row
table mfr fleet, c(sum sales) format(%9.0f) cellwidth(10) col row
clear



*************************************************************
***** TABLE 2: HOW MANY ENGINE SIZES HAVE FFV CAPACITY? *****
*************************************************************
use cafe_compliance

* DROP YEARS BEFORE AMFA INCENTIVE TOOK EFFECT
drop if year<1993

* MAX FFV SALES BY YEAR-AUTOMAKER-FLEET-DISPLACEMENT
collapse (max) sales_ffv, by(year mfr fleet liters)

* INDICATOR IF ENGINE SIZE HAS FFVS
ren sales_ffv ffv
replace ffv = 1 if ffv>0

* FOR EACH AUTOMAKER-FLEET-YEAR, REPORT NUMBER OF FFV ENGINE SIZES AND TOTAL NUMBER OF ENGINE SIZES
keep if mfr=="DCC" | mfr=="FMC" | mfr=="GMC" | mfr=="NIS"
table year fleet if mfr=="DCC", c(sum ffv count liters)
table year fleet if mfr=="FMC", c(sum ffv count liters)
table year fleet if mfr=="GMC", c(sum ffv count liters)
table year fleet if mfr=="NIS", c(sum ffv count liters)
clear



***********************************************************************
***** TABLE 2: WHAT ARE FFV SHARES FOR ENGINES WITH FFV CAPACITY? *****
***********************************************************************
use cafe_compliance

* DROP YEARS BEFORE AMFA INCENTIVE TOOK EFFECT
drop if year<1993

* COLLAPSE DATA BY YEAR-AUTOMAKER-FLEET-DISPLACEMENT
collapse (rawsum) sales sales_ffv, by(year mfr fleet liters)
gen ffv_share=sales_ffv/sales
drop if ffv_share==0

* FOR EACH AUTOMAKER-FLEET-YEAR, REPORT MIN AND MAX FFV ENGINE SIZE (MIN-MAX IS SUFFICIENT, SINCE AT MOST TWO ENGINE SIZES WITH FFV)
keep if mfr=="DCC" | mfr=="FMC" | mfr=="GMC" | mfr=="NIS"
table year fleet if mfr=="DCC", c(min ffv_share max ffv_share)
table year fleet if mfr=="FMC", c(min ffv_share max ffv_share)
table year fleet if mfr=="GMC", c(min ffv_share max ffv_share)
table year fleet if mfr=="NIS", c(min ffv_share max ffv_share)
clear



******************************************************
***** FIGURES 1-4: FUEL ECONOMY AND AMFA CREDITS *****
******************************************************
use cafe_compliance

* CALCULATE TOTAL SALES AND SALES-WEIGHTED GPM BY MFR-YEAR-FLEET
collapse (rawsum) sales sales_amfa sales_ffv (median) cafe (mean) gpm_amfa gpm_actual [fweight=sales], by(mfr year fleet)

* CALCULATE EACH MANUFACTURER'S AMFA MPG, ACTUAL MPG, AND AMFA GAIN
gen mpg_amfa=1/gpm_amfa
gen mpg_actual=1/gpm_actual
gen dmpg=mpg_amfa-mpg_actual

* INSPECT CAFE CALCULATIONS
bysort fleet: table mfr year if year>1992, c(median mpg_actual median mpg_amfa)

* CREATE A VARIABLE MEASURING MAX CAFE INCENTIVE
* Note: Law was changed prior to 2004, extending cap at 1.2 mpg through 2010; otherwise would have changed to 0.9 starting in 2004
gen dmpg_max=1.2 if year>=1992

* CREATE FIGURES
global mfrs "DCC FMC GMC NIS"
global fleets "LT DP IP"

global LT "Light trucks"
global DP "Domestic cars"
global IP "Import cars"

global LTmin = 18
global LTmax = 28
global DPmin = 26
global DPmax = 36
global IPmin = 26
global IPmax = 36

format mpg_amfa mpg_actual cafe %9.0f
format dmpg dmpg_max %9.1f
foreach mfr of global mfrs {
		
	display "MANUFACTURER: `mfr'" 

	foreach fleet of global fleets {

		display "FLEET: `fleet'"

		scatter mpg_amfa mpg_actual cafe year if mfr=="`mfr'" & fleet=="`fleet'" & year>=1992, legend(ring(0) position(10) region(lstyle(none) fcolor(none)) cols(1) label(1 "AMFA mpg") label(2 "Actual mpg") label(3 "Standard") rowgap(0) keygap(*.2) symxsize(*.5)) ylabel($`fleet'min(2)$`fleet'max) xlabel(1992(2)2006) sort c(l l l) msymbol(none none none) lcolor(black black black) lpattern(shortdash dot solid) scheme(s1manual) xtitle("Year")
		graph export "cafe_`mfr'_`fleet'.eps", as(eps) preview(off) fontface(Arial) replace

		*pause

		scatter dmpg dmpg_max year if mfr=="`mfr'" & fleet=="`fleet'" & year>=1992, legend(ring(0) position(10) region(lstyle(none) fcolor(none)) cols(1) label(1 "AMFA mpg gain") label(2 "Maximum mpg gain") rowgap(0) keygap(*.2) symxsize(*.5)) ylabel(0(0.3)1.8) xlabel(1992(2)2006) sort c(l l) msymbol(none none) lcolor(black black) lpattern(shortdash solid) scheme(s1manual) xtitle("Year")
		graph export "amfa_gain_`mfr'_`fleet'.eps", as(eps) preview(off) fontface(Arial) replace

		*pause
	}
}
clear



*****************************************************
***** FIGURE 5: FLEXIBLE-FUEL SHARES VERSUS MPG *****
*****************************************************
use cafe_compliance

* DROP YEARS BEFORE AMFA INCENTIVE TOOK EFFECT
drop if year<1993

* COLLAPSE ALL DATA FOR 1993-2006
collapse (rawsum) sales sales_ffv (mean) gpm_actual [fweight=sales], by(mfr fleet liters)

* CALCULATE FFV SHARE FOR EACH MODEL
gen ffv_share=sales_ffv/sales
gen ffv_share_zero=0 if ffv_share==0
replace ffv_share=. if ffv_share==0

* CREATE MILES PER GALLON
gen mpg_actual=1/gpm_actual

* RESCALE FUEL CONSUMPTION TO GALLONS PER 100 MILES
replace gpm_actual=gpm_actual*100

* MIN/MAX MPG
keep if mfr=="DCC" | mfr=="FMC" | mfr=="GMC" | mfr=="NIS"
bysort mfr fleet: sum mpg_actual, detail

* CREATE FIGURE 
global carmakers "DCC FMC GMC NIS"
global fleets "LT DP IP"
global options1 "msymbol(Oh Oh) mcolor(black gray) mlwidth(medium thin)"
global options2 "msymbol(none none) mlabel(liters liters) xlabel(10(5)40) ylabel(-.1(.1).5) scheme(s1manual) legend(off) mcolor(black) xtitle("Miles per gallon", size(large)) ytitle("Flexible-fuel share", size(large)) mlabsize(small) mlabvposition(up)"
global options3 "msymbol(Oh Oh) mcolor(black gray) mlwidth(medium thin) xlabel(10(5)40) ylabel(-.1(.1).5) scheme(s1manual) legend(off) xtitle("Miles per gallon", size(large)) ytitle("Flexible-fuel share", size(large))"

format liters %9.1f
*tab liters

sort mfr fleet gpm_actual
gen up=mod(_n,3)
replace up=up*6

* PLOT FLEXIBLE-FUEL SHARES VERSUS MPG
pause off
format ffv_share ffv_share_zero %9.1f
foreach m of global carmakers {
	foreach f of global fleets {
		*scatter ffv_share ffv_share_zero mpg_actual [w=sales] if mfr=="`m'" & fleet=="`f'" & mpg_actual>=15 & mpg_actual<=40, $options1 || scatter ffv_share ffv_share_zero mpg_actual if mfr=="`m'" & fleet=="`f'" & mpg_actual>=15 & mpg_actual<=40, $options2
		scatter ffv_share ffv_share_zero mpg_actual [w=sales] if mfr=="`m'" & fleet=="`f'" & mpg_actual>=15 & mpg_actual<=40, $options3
		graph export "ffvshare_mpg_`m'_`f'.eps", as(eps) preview(off) fontface(Arial) replace
		pause
	}
}
drop up
clear



log close
exit


