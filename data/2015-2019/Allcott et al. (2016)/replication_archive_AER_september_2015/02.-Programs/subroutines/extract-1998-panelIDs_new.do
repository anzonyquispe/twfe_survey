************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

************************************************************************
************************************************************************
use "$work/asi_plant_panel_cleanset.dta", clear
keep if year==1998
qui {
noi count
# delim cr
	***********STATE CODES
	merge m:1 stcode year using "$work/statecodes"
	drop if _m==2
	drop if _m==1
noi count
	drop _m
	rename state statename
	tab statename


drop if grsale==. | grsale<2
noi count

keep if opclcode==0
noi count
}

*nic98_4 inityr 

g state_consistent=statename
replace state_consistent="BIHAR" if statename=="JHARKHAND"
replace state_consistent="MADHYA PRADESH" if statename=="CHHATTISGARH"
replace state_consistent="UTTAR PRADESH" if statename=="UTTARANCHAL" 



bys state_consistent schcode grsale fcapopen fcapclose : g rank2=_N
tab rank2
drop if rank>1
drop rank
keep state_consistent  schcode grsale fcapopen fcapclose permid
foreach i in grsale fcapopen fcapclose {
replace `i' = 0 if `i'==.
}
rename permid permid_1998
count

save asi_plant_panel_cleanset_formatch.dta, replace 
