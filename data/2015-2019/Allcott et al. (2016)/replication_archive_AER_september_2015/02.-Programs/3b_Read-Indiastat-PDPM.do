************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************


foreach i in 3	11	17	23	61	65	73	91	94	100 {
clear
odbc load, dsn("Excel Files;DBQ=$data\\Indiastat\PDPM&PSP\PDPM CLEAN\\`i'.xlsx") table("_`i'$")
compress
keep  Area	Year	Peak_Demand	Peak_Met
g sheet=`i'
tempfile temp`i'
save `temp`i''
}

use `temp3', clear
foreach i in 11	17	23	61	65	73	91	94	100 {
append using `temp`i''
}

************
***	CLEAN UP
************
rename Area state
rename Year year
rename Peak_D pd
rename Peak_M pm


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
replace state ="Dadra and Nagar Haveli" if state=="Dadra & Nagar Haveli"
replace state ="Dadra and Nagar Haveli" if state=="Dadar & Nagar Haveli"
replace state ="Dadra and Nagar Haveli" if state=="Dadar Nagar & Haveli"
replace state ="Dadra and Nagar Haveli" if state=="Dadar Nagar Haveli"
replace state ="Dadra and Nagar Haveli" if state=="Dadar Nagar Haveli (*)"
replace state ="Dadra and Nagar Haveli" if state=="Dadar and Nagar Haveli"
replace state ="Goa Daman and Diu" if state=="Daman & Diu"
replace state ="Goa Daman and Diu" if state=="Daman and Diu"
replace state ="Goa Daman and Diu" if state=="Daman & Diu  (*)"
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
replace state ="Kerala" if state=="kerala"


************
***	DROP REGION AND INDIA TOTALS
************
drop if state=="All India"
drop if strpos(state,"Region")>0
tab state

************
***	INSPECT OVERLAPPING SHEETS
************
bysort year: tab sheet, mi
****>>>>>>	sheet 91 is duplicative; drop
drop if sheet==91
bysort year: tab sheet, mi



replace state = trim(upper(state))
tab state, mi


collapse (sum) pd pm , by(state year)

************
***	CALCULATE SHORTAGE PERCENT
************
g shortageMW=pd- pm
g shortagepctPDPM=shortageMW/pd

tab year, sum(shortagepct) mean

*****>>>>>2007-8 looks odd, inspect
tab shortagepct if year=="2007-2008"
*tab state if shortagepct<-7
*tab sheet if shortagepct<-7
tab year if state=="Uttaranchal", sum(pd) mean
count if state=="Uttaranchal" & year=="2007-2008"
****>>>>>IN SHEET 23, UTTARANACHAL HAS VALUES PD-PM OF 120-1150; 120 MUST BE ENTRY ERROR; 
****>>>>>PROBABLY SHOULD BE 1200 GIVEN VALUE OF 1108 IN PREVIOUS YEAR AND 1267 IN SUBSEQUENT
tab pd if state=="Uttaranchal" & year=="2007-2008"
replace pd=1200 if state=="Uttaranchal" & year=="2007-2008"
tab pd if state=="Uttaranchal" & year=="2007-2008"

replace shortageMW=pd- pm
replace shortagepct=shortageMW/pd

tab year, sum(shortagepct)

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
merge 1:1 state year using "$work\pdpm_early.dta", keepusing(peakdemandmw peakmetmw)


g PDcheck=(pd==peakdemandmw) if _m==3
tab PDcheck if _m==3

g PMcheck=(pm==peakmetmw) if _m==3
tab PMcheck if _m==3

order peakdemand, after(pd)
order peakmet, after(pm)
*br if PDcheck==0 | PMcheck==0
***WE GO WITH HAND-ENTERED # IN THESE CASES
***THEY APPEAR TO BE UPDATED & TYPO CORRECTIONS IN SOME OBVIOUS CASES
drop _m

replace pd=peakdemand if peakdemand!=.
replace pm=peakmet if peakmet!=.
drop peakdemand peakmet *check shortageMW

g shortagePDPM=pd-pm
replace shortagepctPDPM=shortagePDPM/pd

************
***	SET PANEL
************
encode state, g(state1)
xtset state1 year

***INSPECT PANEL
bysort state: g rank=_N
tab rank
bysort rank: tab state

drop state1 //sheet


save "$work\PDPM.dta", replace
