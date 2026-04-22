************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************

insheet using "$data\CEA\EnergyandPeak\Peak Demand final.csv", comma names clear
cap drop v*

replace state = trim(upper(state))
tab state

replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="ANDAMAN- NICOBAR"
replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="ANDAMAN- NICOBAR#"
replace state="ANDHRA PRADESH" if state=="ANDHRAPRADESH"
replace state="ARUNACHAL PRADESH" if state=="ARUNACHAL PR."
replace state="CHHATTISGARH" if state=="CHATTISGARH"
replace state="DADRA AND NAGAR HAVELI" if state=="DADAR NAGAR HAVELI"
replace state="GOA DAMAN AND DIU" if state=="GOA"
replace state="GOA DAMAN AND DIU" if state=="DAMAN AND DIU"
replace state="GOA DAMAN AND DIU" if state=="DAMAN & DIU"
replace state="JAMMU AND KASHMIR" if state=="JAMMU & KASHMIR"
replace state="PONDICHERRY" if state=="PONDICHENY"
replace state="WEST BENGAL AND SIKKIM" if state=="W.BENGAL + SIKKIM"
replace state="WEST BENGAL AND SIKKIM" if state=="WEST BENGAL + SIKKIM"
tab state

replace  peakdemandmw=correction_pd if correction_pd !=.
replace  peakmetmw=correction_pm if correction_pm!=.
drop correction*
duplicates drop

collapse (sum) peakdemandmw peakmetmw, by(state year)
bysort state year: g rank=_N
assert rank==1
drop rank

preserve
keep if state=="WEST BENGAL AND SIKKIM"
replace state="SIKKIM"
tempfile sk
save `sk'
restore
append using `sk'
replace state="WEST BENGAL" if state=="WEST BENGAL AND SIKKIM"


save "$work\pdpm_early.dta", replace



insheet using "$data\CEA\EnergyandPeak\Energy Requirement.csv", comma names clear
cap drop v*
replace state = trim(upper(state))
tab state

replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="ANDAMAN- NICOBAR"
replace state="ANDAMAN AND NICOBAR ISLANDS" if state=="ANDAMAN- NICOBAR#"
replace state="ARUNACHAL PRADESH" if state=="ARUNACHAL PR."
replace state="CHHATTISGARH" if state=="CHATTISGARH"
replace state="DADRA AND NAGAR HAVELI" if state=="D.N. HAVELI"
replace state="DADRA AND NAGAR HAVELI" if state=="D.N.HAVELI"
replace state="DADRA AND NAGAR HAVELI" if state=="DADAR NAGAR HAVELI (*)"
replace state="GOA DAMAN AND DIU" if state=="DAMAN & DIU"
replace state="GOA DAMAN AND DIU" if state=="DAMAN & DIU (*)"
replace state="GOA DAMAN AND DIU" if state=="GOA"
replace state="JAMMU AND KASHMIR" if state=="JAMMU & KASHMIR"
replace state="LAKSHADWEEP" if state=="LAKSHADWEEP#"
replace state="PONDICHERRY" if state=="PONDICHENY"
replace state="WEST BENGAL AND SIKKIM" if state=="W.BENGAL + SIKKIM"
replace state="WEST BENGAL AND SIKKIM" if state=="WEST BENGAL + SIKKIM"
tab state

 replace requirementmu=correction_req  if correction_req !=.
 replace availabilitymu=correction_avail if correction_avail!=.
 drop correction*

collapse (sum) requirementmu availabilitymu, by(state year)
bysort state year: g rank=_N
assert rank==1
drop rank

preserve
keep if state=="WEST BENGAL AND SIKKIM"
replace state="SIKKIM"
tempfile sk
save `sk'
restore
append using `sk'
replace state="WEST BENGAL" if state=="WEST BENGAL AND SIKKIM" //a couple of years they are reported together & is adjusted later on; majority of requirement and production here will be from WB; firm data do not have Sikkim anyway

save "$work\ra_early.dta", replace
