preserve
keep nic2 nic87_super  snic year
replace year = year-1992
duplicates drop
g mshare=.
g mshare_super=.
g mshare_yrtrend=.
g mshare_2dig=.
g mshare_yrtrend_2dig=.

g lshare=.
g lshare_super=.
g lshare_yrtrend=.
g lshare_2dig=.
g lshare_yrtrend_2dig=.

g eshare=.
g eshare_super=.
g eshare_yrtrend=.
g eshare_2dig=.
g eshare_yrtrend_2dig=.

g lambda=.
g lambda_super=.
g lambda_yrtrend=.
g lambda_2dig=.
g lambda_yrtrend_2dig=.

gsort nic2 year
save "$work/sharecapture", replace


****SELECT DATASET DOWN TO FIRMS WITH FULL ACCOUNTS (YKLM ETC)
restore
*keep if nic2=="23"| nic2=="24"



g matlsshare_Y=matls_nominal/(grsale_nominal)
g laborshare_Y=labcost_nominal/(grsale_nominal)
g elecshare_Y=velecpur_nominal/(grsale_nominal)
g lambda=(qeleccons)/(grsale_defl)

replace year = year-1992

keep matlsshare_Y laborshare_Y elecshare_Y snic nic87_super nic2 year lambda

local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
	xi: qreg matlsshare_Y year i.snic if nic2=="`l'"
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
	qreg matlsshare_Y year if nic2=="`l'"
	local mshare2_2dig_`l'=_b[_cons]
	local mshare_yrtrend_2dig_`l'=_b[year]
	}
preserve
use "$work/sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace mshare=`mshare2_`l'' if nic2=="`l'"
replace mshare_yrtrend=`mshare_yrtrend_`l'' if nic2=="`l'"
replace mshare_2dig=`mshare2_2dig_`l'' if nic2=="`l'"
replace mshare_yrtrend_2dig=`mshare_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace mshare_super=`mshare_`j'' if snic==`j'
}
g mshare_final=mshare+mshare_super+mshare_yrtrend*year
save "$work/sharecapture", replace
restore	


local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
levelsof snic if nic2=="`l'", local(supernic)	
	xi: qreg laborshare_Y year i.snic if nic2=="`l'" 
	local lshare2_`l'=_b[_cons]
	local lshare_yrtrend_`l'=_b[year]
	local count = 1
	foreach j of local supernic {
		local lshare_`j'=0
		cap local lshare_`j'=_b[_Isnic_`count']
		local count=`count'+1
		}
	qreg laborshare_Y year if nic2=="`l'" 
	local lshare2_2dig_`l'=_b[_cons]
	local lshare_yrtrend_2dig_`l'=_b[year]

	}

preserve
use "$work/sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace lshare=`lshare2_`l'' if nic2=="`l'"
replace lshare_yrtrend=`lshare_yrtrend_`l'' if nic2=="`l'"
replace lshare_2dig=`lshare2_2dig_`l'' if nic2=="`l'"
replace lshare_yrtrend_2dig=`lshare_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace lshare_super=`lshare_`j'' if snic==`j'
}
g lshare_final=lshare+lshare_super+lshare_yrtrend*year
save "$work/sharecapture", replace
restore	


local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
levelsof snic if nic2=="`l'", local(supernic)	
	xi: qreg lambda year i.snic if nic2=="`l'" 
	local lambda2_`l'=_b[_cons]
	local lambda_yrtrend_`l'=_b[year]
	local count = 1
	foreach j of local supernic {
		local lambda_`j'=0
		cap local lambda_`j'=_b[_Isnic_`count']
		local count=`count'+1
		}
	qreg lambda year if nic2=="`l'" 
	local lambda2_2dig_`l'=_b[_cons]
	local lambda_yrtrend_2dig_`l'=_b[year]

	}

preserve
use "$work/sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace lambda=`lambda2_`l'' if nic2=="`l'"
replace lambda_yrtrend=`lambda_yrtrend_`l'' if nic2=="`l'"
replace lambda_2dig=`lambda2_2dig_`l'' if nic2=="`l'"
replace lambda_yrtrend_2dig=`lambda_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace lambda_super=`lambda_`j'' if snic==`j'
}
g lambda_final=lambda+lambda_super+lambda_yrtrend*year


save "$work/sharecapture", replace
restore	
	
local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
levelsof snic if nic2=="`l'", local(supernic)
	xi: qreg elecshare_Y year i.snic if nic2=="`l'" & year>1
	local eshare2_`l'=_b[_cons]
	local eshare_yrtrend_`l'=_b[year]
	local count = 1
	foreach j of local supernic {
		local eshare_`j'=0
		cap local eshare_`j'=_b[_Isnic_`count']
		local count=`count'+1
		}
	qreg elecshare_Y year if nic2=="`l'" & year>1 
	local eshare2_2dig_`l'=_b[_cons]
	local eshare_yrtrend_2dig_`l'=_b[year]
	}
	

use "$work/sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace eshare=`eshare2_`l'' if nic2=="`l'"
replace eshare_yrtrend=`eshare_yrtrend_`l'' if nic2=="`l'"
replace eshare_2dig=`eshare2_2dig_`l'' if nic2=="`l'"
replace eshare_yrtrend_2dig=`eshare_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace eshare_super=`eshare_`j'' if snic==`j'
}


g eshare_final=eshare+eshare_super+eshare_yrtrend*year
g mshare_final_2dig=mshare_2dig+mshare_yrtrend_2dig*year
g lshare_final_2dig=lshare_2dig+lshare_yrtrend_2dig*year
g eshare_final_2dig=eshare_2dig+eshare_yrtrend_2dig*year
g lambda_final_2dig=lambda_2dig+lambda_yrtrend_2dig*year

g betak_CRS_final=1-mshare_final-lshare_final
g betaK_2dig_CRS_final=1-mshare_final_2dig-lshare_final_2dig


save "$work/sharecapture", replace
use "$work/sharecapture", clear

g flag = lshare_final<0 | mshare_final<0 | eshare_final<0
replace mshare_final=mshare_final_2dig if flag
replace lshare_final=lshare_final_2dig if flag
replace eshare_final=eshare_final_2dig if eshare_final<0
replace betak_CRS_final=betaK_2dig_CRS_final if flag
drop flag
g flag = (lshare_final+mshare_final)>1
replace mshare_final=mshare_final_2dig if flag
replace lshare_final=lshare_final_2dig if flag
replace eshare_final=eshare_final_2dig if eshare_final<0
replace betak_CRS_final=betaK_2dig_CRS_final if flag
drop flag

replace lambda_final=lambda_final_2dig if lambda_final<0

gsort nic87_super +year



***adjust robustness check capital coefficients if there is still a negative capital coefficient (this happens rarely)

noi dis "final shares assertion"
foreach i in mshare lshare {
assert `i'_final>=0
}
assert eshare_final>=0


replace year = year+1992
keep year snic *_final

histogram mshare_final
graph export "$work/median matlsshare hist_nov2014.pdf", replace
histogram lshare_final
graph export "$work/median laborshare hist_nov2014.pdf", replace
histogram eshare_final
graph export "$work/median Eshare hist_nov2014.pdf", replace
histogram lambda_final
graph export "$work/median lambda hist_nov2014.pdf", replace
