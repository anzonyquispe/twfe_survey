/* Self Generation Stylized Facts.do */

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

capture log close
log using "$logs/Self Generation Stylized Facts $date $time.log", replace
include "$do/Subroutines/DefineGlobals.do"


************************
/* STATEMENT IN PAPER */
* Indian firms generate 35% of electricity
use "$intdata/ASIpanel for ASI Regressions.dta", clear
keep if year>=1998 // keep more recent years because the data quality is better and because it matches the recent MECS data. Graph looks fundamentally the same with pre-1998 data included.
gen TotalOnsiteGeneration = qelecprod+velecsold_defl/4.5 // Median of non-zero sales prices is 4.56

collapse (sum) TotalOnsiteGeneration /* qelecprod */ qeleccons [pweight=mult]
gen ratio = TotalOnsiteGeneration/qeleccons
sum ratio

********************************************************************
********************************************************************
/* COMPARISON TO MECS DATA (US VS INDIA) */
	* Note: This figure has not been updated since summer 2013. It will not make much of a difference in the figure at all, so this is not a problem.
	* However, if updating, we would need to fix the supernic names.


*** Compare to MECS
insheet using "$data/NIC crosswalk/snicnames.csv", comma names case clear
tostring snic, gen(nic87_super)
drop snic
save "$work/snicnames.dta", replace

insheet using "$data/MECS/Table11_1.csv", comma nonames clear
drop if _n<=14|_n>=99
rename v1 NAICS
rename v3 Purchases
rename v4 TransfersIn
rename v5 TotalOnsiteGeneration
rename v6 SalesandTransfersOffsite
rename v7 NetDemand
compress 
foreach var in TotalOnsiteGeneration NetDemand {
	replace `var' = "0" if `var' == "*"|`var'=="Q" // There are 3 "Qs" here which are withheld, including textiles. The similar industries have these as zero.
}
destring NAICS TotalOnsiteGeneration NetDemand, replace force ignore(",")

** Merge some categories
	* Make 325311 all fertilizers instead of just nitrogen
foreach var in TotalOnsiteGeneration NetDemand {
	sum `var' if NAICS==325311|NAICS==325312
	replace `var' = r(mean)*2 if NAICS == 325311
}
drop if NAICS == 325312

gen prod_cons_MECS = TotalOnsiteGeneration/NetDemand
keep NAICS prod_cons_MECS NetDemand
*drop if NAICS==. // keep these because missing gives the average



save "$work/MECSdata.dta", replace 

insheet using "$data/MECS/supernic_MECSdata.csv", comma names case clear
keep NAICS nic87_? NIC1Name
save "$work/supernic_MECSdata.dta", replace


use "$intdata/ASIpanel_fulldataset.dta", clear
keep if year>=1998 // keep more recent years because the data quality is better and because it matches the recent MECS data. Graph looks fundamentally the same with pre-1998 data included.
gen TotalOnsiteGeneration = qelecprod+velecsold_defl/4.5 // Median of non-zero sales prices is 4.56
gen prod_cons_ASI_median = TotalOnsiteGeneration/qeleccons
sort nic87 snic

collapse (first) nic87 nic87_super (median) prod_cons_ASI_median (sum) TotalOnsiteGeneration qeleccons [pweight=mult], by(snic)
gen prod_cons_ASI = TotalOnsiteGeneration/qeleccons
rename nic87 nic87_1 // This is the first numerical nic87 3-digit code within the supernic. 
merge 1:1 nic87_1 using "$work/supernic_MECSdata.dta", keep(match master) keepusing(NAICS NIC1Name) nogen
rename nic87_1 nic87_2
merge 1:1 nic87_2 using "$work/supernic_MECSdata.dta", keep(match master match_up) keepusing(NAICS NIC1Name) nogen update

merge m:1 NAICS using "$work/MECSdata.dta", keep(match master) keepusing(prod_cons_MECS NetDemand) nogen
merge 1:1 nic87_super using "$work/snicnames.dta", nogen keep(match master) keepusing(SNICName)

** Add observations for 0 and 1
gen fortyfivex = 1
gen fortyfivey = 1
replace fortyfivex = 0 if _n==1
replace fortyfivey = 0 if _n==1

** Graph
* replace mlabels for clarity
replace SNICName = "" if SNICName=="Railroad Equipment" | SNICName==""
twoway (scatter prod_cons_ASI prod_cons_MECS, mlabel(SNICName) xscale(range(0 1)) ylabel(0(0.2)1) xlabel(0(0.2)1) ) ///
	(line fortyfivey fortyfivex), ///
	ytitle("India Generation/Consumption") ///
	xtitle("U.S. Generation/Consumption") ///
	graphregion(color(white) lwidth(medium)) legend(off)
if c(os) != "Windows" {
graph export "$analyses/MECSvsASI.pdf", as(pdf) replace
graph export "$analyses/MECSvsASI.emf", as(emf) replace
}
*	title("Manufacturing Electricity Generation in U.S. vs. India") ///

/* Get ProdASI_MECS dataset */
gen ProdASI_MECS = prod_cons_ASI - prod_cons_MECS
keep snic ProdASI_MECS
save "$work/ProdASI_MECS.dta", replace

* Note: on 5-3-2013, Hunt compared some of the industries that are furthest off between ASI and MECS, and the matchups seem to be correct. Ideally we would have collapsed the ASI data in a way to match the public MECS categories, but this approach allows us to display supernics, which is also useful.

**************************************************************************
**************************************************************************


/* PLANT SIZE AND SELF-GENERATION */
* See also old/Small vs Large Plants
use "$intdata/ASIpanel_fulldataset_Nov2014.dta",clear
** Drop flagged values of L, Y, qeleccons, and qelecprod
foreach var in lnL { // lnY lnL lnE lnqelecprod {
	drop if `var'_flag>0
}
collapse (mean) SGS totpersons grsale_defl elec_producer (first) snic nic2num statenum  anyyearEprod,by(panelgroup)
gen lnL = ln(totpersons)
gen lnY = ln(grsale_defl)
gen logL = log10(totpersons)
*lowess SGS lnY
*lpoly SGS lnY, degree(0) noscatter ci level(90)


** Generator Ownership and size.
lpoly anyyearEprod logL if totpersons<5000&totpersons>0, /// Very few observations past 1000, and the curve starts to bend downwards.
	degree(0) noscatter ci level(90) title("") /// // title("Self-Generation and Plant Size") 
	ytitle("Share of Plants that Self-Generate") xtitle("log10(Number of Employees)") ///
	graphregion(color(white) lwidth(medium)) legend(off) 
	graph save "$analyses/ElecProducerandSize", replace
	graph export "$analyses/ElecProducerandSize.pdf", as(pdf) replace
	

** SGS and size
* Limit to smaller than 5k totpersons. Some of the singleton observations have really high values of totpersons, and it’s not clear if this is correct. These don’t get used in the diff or FE estimators, but they would be included here.
lpoly SGS logL if totpersons<5000&totpersons>1, ///
	degree(0) noscatter ci level(90) ///
	title("Self-Generation and Plant Size") ///
	ytitle("Self-Generation Share") xtitle("log10(Number of Employees)") ///
	graphregion(color(white) lwidth(medium))
	graph export "$analyses/SGSandSize.emf", as(emf) replace
	