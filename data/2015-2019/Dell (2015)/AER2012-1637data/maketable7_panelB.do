capture log close
clear
clear matrix
set mem 2g
set more off, permanently
set matsize 10000


insheet using ./congestion/OptFlows0.csv, comma clear
g time=0
rename v1 id_municipio
sort id_municipio time
rename v2 flows
save temp0, replace

forvalues i = 1/11 {
	insheet using ./congestion/OptFlows`i'.csv, comma clear
	g time=`i'
	rename v1 id_municipio
	rename v2 flows
	sort id_municipio time
	save temp`i', replace
}

use temp0, clear
forvalues i = 1/11 {
	append using temp`i'
}

***--------Drop producing muns

mmerge id_mun using producers, type(n:1)
keep if _merge==1
drop _merge
	
***---Drop muns that themselves have close PAN victories between the start of the Calderon administration and 2008 (those in the 2007-2008 close RD sample + 13 muns in Yucatan that don't have half a year of pre-period data but had elections at the beginning of this period)

mmerge id_mun using CloseElec, type(n:1)
keep if _merge==1
drop _merge 

***-convert to month x municipality panel
mmerge time using MakePathPanel, type(n:n)
drop _merge
save PredPath, replace

*****************************************
**---Get baseline outcome data
*****************************************

**----merge with data on drug trade related homicides 

mmerge id_m YMEv using dtrh, type(1:1)
keep if _merge==3

g deathsx=(Muertes_T/pob_t)*100000*12
g DummyDeaths=Muertes_T
replace DummyDeaths=1 if Muertes_T>1

keep id_mun YMEv deathsx DummyD id_est pob_t time flows

**----Quantities confiscated data
mmerge id_mun YMEvent using seizures, type(1:1)
keep if _merge==3
drop _merge

*Log value measures
replace ValueFor=ln(ValueFor+1)
replace ValueDom=ln(ValueDom+1)

tsset id_mun YMEv

*Flows dummy
g DummyFlows=flows
replace DummyFlows=1 if DummyFlows>0

g flow1=0
replace flow1=1 if flows==1

g flow_g1=0
replace flow_g1=1 if (flows>1 & flows!=.)

*Month x state FE

tab YMEvent, gen (moEv)
local nummonths = r(r) - 1

tab id_estado, gen (stEv)
local numstates=r(r)-1

foreach M of num 1/`nummonths' {
	foreach S of num 1/`numstates' {
		quietly g YMoST`S'_`M'=stEv`S'*moEv`M'
	}
}

g statemonth=string(id_estado)+"_"+string(YMEv)
encode statemonth, g(SMnum)	

**********----------Regressions

*dtr hom
summ DummyDeaths 
local mean = r(mean)

cgmreg DummyDeaths DummyFlows YMoST* i.id_mun, cluster(id_mun SMnum) 
outreg2 DummyFlows using table7b, excel less(0) nocons replace bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtr hom
summ deathsx [aw=pob_t]
local mean = r(mean)

cgmreg deathsx DummyFlows YMoST* i.id_mun [aw=pob_t], cluster(id_mun SMnum) 
outreg2 DummyFlows using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtrh hom - count

summ deathsx [aw=pob_t]
local mean = r(mean)

cgmreg deathsx flows YMoST* i.id_mun [aw=pob_t], cluster(id_mun SMnum) 
outreg2 flows using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')


*dtrh hom: 0, 1, >1

summ DummyDeaths 
local mean = r(mean)

cgmreg DummyDeaths flow1 flow_g1 YMoST* i.id_mun, cluster(id_mun SMnum) 
outreg2 flow1 flow_g1 using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtrh hom: 0, 1, >1

summ deathsx [aw=pob_t]
local mean = r(mean)

cgmreg deathsx flow1 flow_g1 YMoST* i.id_mun [aw=pob_t], cluster(id_mun SMnum) 
outreg2 flow1 flow_g1 using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*limited sample

mmerge id_mun using BorderPanVictory, type(n:1)
keep if _merge==1 
drop _merge


*dtr hom
summ DummyDeaths 
local mean = r(mean)

cgmreg DummyDeaths DummyFlows YMoST* i.id_mun, cluster(id_mun SMnum) 
outreg2 DummyFlows using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtr hom
summ deathsx [aw=pob_t]
local mean = r(mean)

cgmreg deathsx DummyFlows YMoST* i.id_mun [aw=pob_t], cluster(id_mun SMnum) 
outreg2 DummyFlows using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtrh hom - count

summ deathsx [aw=pob_t]
local mean = r(mean)

cgmreg deathsx flows YMoST* i.id_mun [aw=pob_t], cluster(id_mun SMnum) 
outreg2 flows using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtrh hom: 0, 1, >1

summ DummyDeaths 
local mean = r(mean)

cgmreg DummyDeaths flow1 flow_g1 YMoST* i.id_mun, cluster(id_mun SMnum) 
outreg2 flow1 flow_g1 using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

*dtrh hom: 0, 1, >1

summ deathsx [aw=pob_t]
local mean = r(mean)

cgmreg deathsx flow1 flow_g1 YMoST* i.id_mun [aw=pob_t], cluster(id_mun SMnum) 
outreg2 flow1 flow_g1 using table7b, excel less(0) nocons append bdec(3) adds(Clusters, e(N_clus1), "Mean", `mean')

