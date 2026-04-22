use data_aersubmit.dta

sort hhidc year id 

local hhvars "hhsize tot_assets incm_hh_mon age_head eduyr_head"
local housevars "apt_rentval apt_sqm  apt_water_house apt_toiletin apt_electric no_excreta  waterplant"

foreach var in `hhvars' `housevars'{
	drop if `var'==.
}
* emp_state_couple"
tabstat `hhvars' if year==1993 & head==1, by(statehouse) stats(mean sd n)
foreach var in `hhvars' {
	regress `var' statehouse if year==1993 & head==1
}

tabstat `housevars' if year==1993 & head==1, by(statehouse) stats(mean sd n)
foreach var in `housevars' {
	regress `var' statehouse if year==1993 & head==1
}

tabstat apt_und20 if year==1991 & head==1, by(statehouse) stats(mean sd n)
regress apt_und20 statehouse if year==1991 & head==1
