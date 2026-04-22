**** File imports data into Stata format

cd "/Users/mattpanhans/Dropbox (JC's Data Emporium)/state_tax_digitization/data_clean"

**** Load CCH data
import excel ../CCH_State_Tax_Handbooks/cch_data.xlsx, sheet("Sheet1") firstrow clear
drop if Year == .

foreach var of varlist FranchiseTax - FederalBonusDepreciation {
        replace `var' = strlower(`var')
        replace `var' = subinstr(`var'," ","",.)
        replace `var' = "1" if `var' == "yes"
        replace `var' = "0" if `var' == "no"
        destring `var', replace
        }

**** Merge in FIPS codes
sort Year State
bysort Year: gen num = _n
merge m:1 num using FIPStoStatecrosswalk.dta
drop if _merge == 2		// PR not matched
drop _merge
rename state state_abbr
sort Year State


**** Add missing flags or clean  variables
drop CapitalStock FollowsUDITPA

replace ACRSDepreciation = 0 if Year == 1980		// programs apply to capital put into service beginning in 1981

* Set zero years carry forward/back for states without corporate income taxes
foreach var of varlist Losscarryback Losscarryforward {
	replace `var' = 0 if State == "Nevada" | State == "South Dakota" | State == "Texas" | State == "Washington" | State == "Wyoming"
}

* Set "No" for states without corporate income taxes
foreach var of varlist FedIncomeTaxDeductible FederalIncomeasStateTaxBase ACRSDepreciation FederalBonusDepreciation {
	replace `var' = 0 if State == "Nevada" | State == "South Dakota" | State == "Texas" | State == "Washington" | State == "Wyoming"
}

replace AllowFedAccDep = 0 if Year <= 2003 & (State == "Nevada" | State == "South Dakota" | State == "Texas" | State == "Washington" | State == "Wyoming")



**** Merge in franchise tax variable from Prentice-Hall publication
preserve
import excel ../PH_All_states_tax_handbook/PH_data.xlsx, clear firstrow
keep State Year PH_FranchiseTax
drop if State == ""

replace PH_FranchiseTax = strlower(PH_FranchiseTax)
replace PH_FranchiseTax = "1" if PH_FranchiseTax == "yes"
replace PH_FranchiseTax = "0" if PH_FranchiseTax == "no"
destring PH_FranchiseTax, replace

tempfile PH_data
save `PH_data'

restore

merge 1:1 State Year using `PH_data'
drop _merge

** Fix methodological differences between CCP and PH for Franchise Tax
** So that change in data is not due solely to a change in data source
gen inconsistent = 0
replace inconsistent = 1 if Year == 1998 & FranchiseTax != PH_FranchiseTax
replace inconsistent = 1 if Year == 1999 & FranchiseTax != PH_FranchiseTax

// Maryland: CCH has yes, but it is on financial institutions only
replace FranchiseTax = 0 if State == "Maryland" & Year <= 1999

replace PH_FranchiseTax = 0 if State == "Idaho" & Year >= 1998 & Year <= 2003
replace PH_FranchiseTax = 0 if State == "Massachusetts" & Year >= 1998 & Year <= 2008
replace PH_FranchiseTax = 1 if State == "New Hampshire" & Year >= 1998
replace PH_FranchiseTax = 1 if State == "New Mexico" & Year >= 1998 & Year <= 2003
replace PH_FranchiseTax = 1 if State == "Virginia" & Year >= 1998
replace PH_FranchiseTax = 1 if State == "Washington" & Year >= 1998

replace FranchiseTax = PH_FranchiseTax if Year >= 2000
drop PH_FranchiseTax
drop inconsistent

**** Variable labels
replace AllowFedAccDep = 2 if AllowFedAccDep == .
label define yesno 0 "No" 1 "Yes" 2 "N/A"

foreach var of varlist FranchiseTax FedIncomeTaxDeductible FederalIncomeasStateTaxBase AllowFedAccDep ACRSDepreciation FederalBonusDepreciation {
label values `var' yesno
}

**** Save dataset
save data.dta, replace


**** Save dataset with imputed values for missing data
gen temp = AllowFedAccDep if Year == 2003
bysort State: egen temp2 = max(temp) if Year >= 2003
replace AllowFedAccDep = temp2 if Year >= 2003 & AllowFedAccDep == 2
drop temp temp2

save data_imputed.dta, replace


/*
**** to Check Coverage
collapse (count) Losscarryback (count) Losscarryforward (count) FranchiseTax ///
(count) FedIncomeTaxDeductible (count) FederalIncomeasStateTaxBase ///
(count) ACRSDepreciation (count) FederalBonusDepreciation (count) AllowFedAccDep, by(Year)
