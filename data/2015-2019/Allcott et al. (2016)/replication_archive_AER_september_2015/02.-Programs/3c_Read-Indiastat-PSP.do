************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************


foreach i in 90	87	63	59	36	28	30	17	12	4 {
clear
odbc load, dsn("Excel Files;DBQ=$data\\Indiastat\PDPM&PSP\PSP CLEAN\\`i'.xlsx") table("_`i'$")
compress
keep  Area	Year	Requirement Availability
g sheet=`i'
tempfile temp`i'
save `temp`i''
}

use `temp90', clear
foreach i in 87	63	59	36	28	30	17	12	4  {
append using `temp`i''
}

************
***	CLEAN UP
************
rename Area state
rename Year year
rename Requirement req
rename Availability avail


************
***	INSPECT
************
tab state, mi
tab year, mi

drop if state==""

************
***	CLEAN UP
************
replace state=trim(state)

replace state ="Andaman and Nicobar Islands" if state=="Andaman & Nicobar Islands #"
replace state ="Andaman and Nicobar Islands" if state=="Andaman & Nicobar#"
replace state ="Chhattisgarh" if state=="Chattisgarh"
replace state ="Chhattisgarh" if state=="Chhatisgarh"
replace state ="DVC" if state=="D.V.C"
replace state ="DVC" if state=="D.V.C."
replace state ="Dadra & Nagar Haveli" if state=="Dadar & Nagar Haveli"
replace state ="Dadra & Nagar Haveli" if state=="Dadar Nagar & Haveli"
replace state ="Dadra & Nagar Haveli" if state=="Dadar Nagar Haveli"
replace state ="Dadra & Nagar Haveli" if state=="Dadar Nagar Haveli (*)"
replace state ="Dadra & Nagar Haveli" if state=="Dadar and Nagar Haveli"
replace state ="Dadra and Nagar Haveli" if state=="Dadra & Nagar Haveli"
replace state ="Goa Daman and Diu" if state=="Daman and Diu"
replace state ="Goa Daman and Diu" if state=="Daman & Diu"
replace state ="Goa Daman and Diu" if state=="Daman & Diu (*)"
replace state ="Goa Daman and Diu" if state=="Goa"
replace state ="All India" if state=="India"
replace state ="Jammu and Kashmir" if state=="Jammu & Kashmir"
replace state ="Lakshadweep" if state=="Lakshadweep #"
replace state ="Lakshadweep" if state=="Lakshadweep#"
replace state ="North-Eastern Region" if state=="North East Region"
replace state ="North-Eastern Region" if state=="North Eastern Region"
replace state ="Orissa" if state=="Odisha"
replace state ="Pondicherry" if state=="Puducherry"
replace state ="Tamil Nadu" if state=="Tamil nadu"
replace state ="Uttaranchal" if state=="Uttarakhand"
replace state ="West Bengal and Sikkim" if state=="West Bengal + Sikkim"
replace state ="West Bengal and Sikkim" if state=="West Bengal+Sikkim"
replace state ="Kerala" if state=="kerala"

tab state, mi
replace state ="Andaman and Nicobar Islands" if state=="Andaman -Nicobar #"
replace state ="Andaman and Nicobar Islands" if state=="Andaman Nicobar Island #"
replace state ="Andaman and Nicobar Islands" if state=="Andaman and Nicobar #"
replace state ="Andaman and Nicobar Islands" if state=="Andaman and Nicobar#"
replace state ="Andaman and Nicobar Islands" if state=="Andaman and Nicobar Islands"
replace state ="Andaman and Nicobar Islands" if state=="Andaman and Nicobar Islands#"
replace state ="Andaman and Nicobar Islands" if state=="Andaman-Nicobar Islands#"
replace state ="Arunachal Pradesh" if state=="Aruachal Pradesh"
replace state ="Dadra and Nagar Haveli" if state=="D.N Haveli"
replace state ="Maharashtra" if state=="Maharastra"
replace state ="North-Eastern Region" if state=="North - Eastern Region"
replace state ="North-Eastern Region" if state=="North Eastern  Region"
replace state ="North-Eastern Region" if state=="Northern Eastern Region"


tab state, mi


************
***	DROP REGION AND INDIA TOTALS
************
drop if state=="All India"
drop if strpos(state,"Region")>0

replace state=trim(upper(state))

************
***	INSPECT OVERLAPPING SHEETS
************
bysort year: tab sheet, mi


collapse (sum) req avail, by(state year)
************
***	CALCULATE SHORTAGE PERCENT
************
g shortageMU=req-avail
g shortagepctPSP=shortageMU/req

tab year, sum(shortagepctPSP) mean
sum shortagepctPSP, d


****The following look off by an order of magnitude; change to 10X
*state	year	req	avail
*Assam	2005-2006	4051	377
*Tamil Nadu	2005-2006	547194	53853

replace avail=avail*10 if state=="Tamil Nadu" & year=="2005-2006"
replace avail=avail*10 if state=="Assam" & year=="2005-2006"
replace shortageMU=req-avail
replace shortagepctPSP=shortageMU/req

preserve
keep if state=="WEST BENGAL AND SIKKIM"
replace state="SIKKIM"
tempfile sk
save `sk'
restore
append using `sk'
replace state="WEST BENGAL" if state=="WEST BENGAL AND SIKKIM"



*****MERGE ON EARLY YEARS DATA AND CHECK CONSISTENCY WITH OVERLAPS
replace year=substr(year,1,4)
destring year, replace
merge 1:1 state year using "$work\ra_early.dta", keepusing( requirementmu availabilitymu)


g reqcheck=abs((req-requirementmu)) if _m==3
*tab reqcheck if _m==3

g availcheck=abs((avail-availabilitymu)) if _m==3
*tab availcheck if _m==3

order requirementmu, after(req)
order availabilitymu, after(avail)

*br if (reqcheck>1 & !mi(reqcheck)) | (availcheck>1 & !mi(availcheck))
count if (reqcheck>1 & !mi(reqcheck)) | (availcheck>1 & !mi(availcheck))
count if (reqcheck<1 & !mi(reqcheck)) & (availcheck<1 & !mi(availcheck))
***there are a lot of discrepancies here!!! look into original sheets

***WE GO WITH THE HAND ENTRY #S IN THESE CASES
***THEY APPEAR TO BE UPDATED & TYPO CORRECTIONS IN SOME OBVIOUS CASES
drop _m

replace req= requirementmu if  requirementmu!=.
replace avail=availabilitymu if availabilitymu!=.
drop requirementmu availabilitymu  *check



tab state

replace shortageMU=req-avail
replace shortagepctPSP=shortageMU/req


************
***	SET PANEL
************
encode state, g(state1)
xtset state1 year


***INSPECT PANEL
bysort state: g rank=_N
tab rank
bysort rank: tab state
drop rank
drop state1

merge 1:1 state year using "$work\PDPM.dta"
assert _m==3
drop _m

** Drop two years of Chhattisgarh, which are missing but still in the data.
drop if req==0&avail==0&pd==0&pm==0


rename shortagepctPSP Shortage
rename shortagepctPDPM PeakShortage
replace Shortage = max(Shortage,0) if Shortage!=.
replace PeakShortage = max(PeakShortage,0) if Shortage!=.

label var req "Requirement (GWh)"
label var avail "Availability (GWh)"
label var Shortage "Shortage"
label var pd "Peak Demand (MW)"
label var pm "Peak Met (MW)"
label var PeakShortage "Peak Shortage"


save "$work\PDPM-PSP Merged.dta", replace
