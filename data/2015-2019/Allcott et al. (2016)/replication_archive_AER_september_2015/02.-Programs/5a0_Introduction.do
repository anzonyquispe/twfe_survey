/* Introduction.do */

************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************
************************************************
/* GRAPH: SHORTAGE EFFECTS ACROSS COUNTRIES FROM WBES */
import excel "$data\World Development Indicators\ic.frm.outg.zs_Indicator_en_excel_v2.xls", sheet("Data") clear

rename A Country
drop if _n<=3
destring AT, gen(RevenueLost2002) force
destring AU, gen(RevenueLost2003) force
destring AV, gen(RevenueLost2004) force
destring AW, gen(RevenueLost2005) force
destring AX, gen(RevenueLost2006) force
destring AY, gen(RevenueLost2007) force
destring AZ, gen(RevenueLost2008) force
destring BA, gen(RevenueLost2009) force
destring BB, gen(RevenueLost2010) force
destring BC, gen(RevenueLost2011) force
destring BD, gen(RevenueLost2012) force
destring BE, gen(RevenueLost2013) force

egen RevenueLost = rowmean(RevenueLost*)
keep Country RevenueLost*
drop if RevenueLost==.

** Rename countries
replace Country = "Gambia" if strpos(Country,"Gambia")!=0
replace Country = "Yemen" if strpos(Country,"Yemen")!=0
replace Country = "Syria" if strpos(Country,"Syria")!=0

keep if RevenueLost>=7 | Country=="India"



graph hbar RevenueLost, over(Country, sort(1) label(labsize(small))  ) ///
	ytitle(Percent of Revenues Reported Lost to Poor Electricity) ///
	graphregion(color(white) lwidth(medium))
	
	graph export "$analyses/SelfReportedLossesbyCountry.pdf", as(pdf) replace
	
*
