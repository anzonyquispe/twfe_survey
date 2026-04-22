preserve
keep nic2 nic87_super  snic year
replace year = year-1992
duplicates drop
g mshare_fuels=.
g mshare_fuels_super=.
g mshare_fuels_yrtrend=.
g mshare_fuels_2dig=.
g mshare_fuels_yrtrend_2dig=.

g mshare_fuels_noSG=.
g mshare_fuels_noSG_super=.
g mshare_fuels_noSG_yrtrend=.
g mshare_fuels_noSG_2dig=.
g mshare_fuels_noSG_yrtrend_2dig=.

gsort nic2 year
save "$work/sharecapture", replace


****SELECT DATASET DOWN TO FIRMS WITH FULL ACCOUNTS (YKLM ETC)
restore
*keep if nic2=="23"| nic2=="24"



g matlsshare_fuels_Y=(matls_nominal +fuels_nominal)/(grsale_nominal)
g matlsshare_fuels_noSG_Y=(matls_fuels_noSG_defl*input_deflator/100)/(grsale_nominal)

replace year = year-1992

keep matlsshare_fuels_Y matlsshare_fuels_noSG_Y snic nic87_super nic2 year

local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
	xi: qreg matlsshare_fuels_Y year i.snic if nic2=="`l'"
	local mshare2_`l'=_b[_cons]
	local mshare_yrtrend_`l'=_b[year]
	levelsof snic if nic2=="`l'", local(supernic)
	foreach j of local supernic {
		dis `j'
		local mshare_`j'=0
		cap local mshare_`j'=_b[_Isnic_`count']
		local count=`count'+1
		dis `mshare_`j''
		dis `mshare_`j''+`mshare2_`l''
		}
	qreg matlsshare_fuels_Y year if nic2=="`l'"
	local mshare2_2dig_`l'=_b[_cons]
	local mshare_yrtrend_2dig_`l'=_b[year]
	}
preserve
use "$work/sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace mshare_fuels=`mshare2_`l'' if nic2=="`l'"
replace mshare_fuels_yrtrend=`mshare_yrtrend_`l'' if nic2=="`l'"
replace mshare_fuels_2dig=`mshare2_2dig_`l'' if nic2=="`l'"
replace mshare_fuels_yrtrend_2dig=`mshare_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace mshare_fuels_super=`mshare_`j'' if snic==`j'
}
g mshare_fuels_final=mshare_fuels+mshare_fuels_super+mshare_fuels_yrtrend*year
save "$work/sharecapture", replace
restore	


local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
	xi: qreg matlsshare_fuels_noSG_Y year i.snic if nic2=="`l'"
	local mshare2_`l'=_b[_cons]
	local mshare_yrtrend_`l'=_b[year]
	levelsof snic if nic2=="`l'", local(supernic)
	foreach j of local supernic {
		dis `j'
		local mshare_`j'=0
		cap local mshare_`j'=_b[_Isnic_`count']
		local count=`count'+1
		dis `mshare_`j''
		dis `mshare_`j''+`mshare2_`l''
		}
	qreg matlsshare_fuels_noSG_Y year if nic2=="`l'"
	local mshare2_2dig_`l'=_b[_cons]
	local mshare_yrtrend_2dig_`l'=_b[year]
	}
preserve
use "$work/sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace mshare_fuels_noSG=`mshare2_`l'' if nic2=="`l'"
replace mshare_fuels_noSG_yrtrend=`mshare_yrtrend_`l'' if nic2=="`l'"
replace mshare_fuels_noSG_2dig=`mshare2_2dig_`l'' if nic2=="`l'"
replace mshare_fuels_noSG_yrtrend_2dig=`mshare_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace mshare_fuels_noSG_super=`mshare_`j'' if snic==`j'
}
g mshare_fuels_noSG_final=mshare_fuels_noSG+mshare_fuels_noSG_super+mshare_fuels_noSG_yrtrend*year

save "$work/sharecapture", replace
restore	

use "$work/sharecapture", clear

replace year = year+1992
keep year snic *_final


