*encode nic87_super, g(snic)
preserve
*drop if nic87==.
*keep if nic2=="23" | nic2=="24"
keep nic2 nic87_super  snic year
replace year = year-1992
duplicates drop
g mshare=.
g mshare_super=.
g mshare_yrtrend=.
g mshare_2dig=.
g mshare_yrtrend_2dig=.

g mshareps0=.
g mshareps0_super=.
g mshareps0_yrtrend=.
g mshareps0_2dig=.
g mshareps0_yrtrend_2dig=.

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
save "$work\sharecapture", replace


****SELECT DATASET DOWN TO FIRMS WITH FULL ACCOUNTS (YKLM ETC)
restore
*keep if nic2=="23"| nic2=="24"



g matlsshare_Y=matls_nominal/(grsale_nominal)
g matlsshareps0_Y=(matlsps0_nominal)/(grsale_nominal)
g laborshare_Y=labcost_nominal/(grsale_nominal)
g elecshare_Y=velecpur_nominal/(grsale_nominal)
*g elecshare_Y=(qeleccons * Rs_kWh_nom)/(grsale_nominal)
g lambda=(qeleccons)/(grsale_defl)

replace year = year-1992



local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
	xi: qreg matlsshare_Y year i.snic if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
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
	qreg matlsshare_Y year if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local mshare2_2dig_`l'=_b[_cons]
	local mshare_yrtrend_2dig_`l'=_b[year]
	}
preserve
use "$work\sharecapture", clear
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
save "$work\sharecapture", replace
restore	





local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
	xi: qreg matlsshareps0_Y year i.snic if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local mshareps02_`l'=_b[_cons]
	local mshareps0_yrtrend_`l'=_b[year]
	levelsof snic if nic2=="`l'", local(supernic)
	foreach j of local supernic {
		dis `j'
		local mshareps0_`j'=0
		cap local mshareps0_`j'=_b[_Isnic_`count']
		local count=`count'+1
		dis `mshareps0_`j''
		dis `mshareps0_`j''+`mshareps02_`l''
		}
	qreg matlsshareps0_Y year if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local mshareps02_2dig_`l'=_b[_cons]
	local mshareps0_yrtrend_2dig_`l'=_b[year]
	}
preserve
use "$work\sharecapture", clear
levelsof nic2, local(levels)

 
foreach l of local levels {
dis `l'
dis "`l'"
replace mshareps0=`mshareps02_`l'' if nic2=="`l'"
replace mshareps0_yrtrend=`mshareps0_yrtrend_`l'' if nic2=="`l'"
replace mshareps0_2dig=`mshareps02_2dig_`l'' if nic2=="`l'"
replace mshareps0_yrtrend_2dig=`mshareps0_yrtrend_2dig_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace mshareps0_super=`mshareps0_`j'' if snic==`j'
}
g mshareps0_final=mshareps0+mshareps0_super+mshareps0_yrtrend*year
save "$work\sharecapture", replace
restore	



local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
levelsof snic if nic2=="`l'", local(supernic)	
	xi: qreg laborshare_Y year i.snic if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local lshare2_`l'=_b[_cons]
	local lshare_yrtrend_`l'=_b[year]
	local count = 1
	foreach j of local supernic {
		local lshare_`j'=0
		cap local lshare_`j'=_b[_Isnic_`count']
		local count=`count'+1
		}
	qreg laborshare_Y year if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local lshare2_2dig_`l'=_b[_cons]
	local lshare_yrtrend_2dig_`l'=_b[year]

	}

preserve
use "$work\sharecapture", clear
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
save "$work\sharecapture", replace
restore	
	

local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
levelsof snic if nic2=="`l'", local(supernic)	
	xi: qreg lambda year i.snic if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local lambda2_`l'=_b[_cons]
	local lambda_yrtrend_`l'=_b[year]
	local count = 1
	foreach j of local supernic {
		local lambda_`j'=0
		cap local lambda_`j'=_b[_Isnic_`count']
		local count=`count'+1
		}
	qreg lambda year if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local lambda2_2dig_`l'=_b[_cons]
	local lambda_yrtrend_2dig_`l'=_b[year]

	}

preserve
use "$work\sharecapture", clear
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
replace lambda_super=`lshare_`j'' if snic==`j'
}
g lambda_final=lambda+lambda_super+lambda_yrtrend*year
save "$work\sharecapture", replace
restore	

	
local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
levelsof snic if nic2=="`l'", local(supernic)
	xi: qreg elecshare_Y year i.snic if nic2=="`l'" & year>4 & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local eshare2_`l'=_b[_cons]
	local eshare_yrtrend_`l'=_b[year]
	local count = 1
	foreach j of local supernic {
		local eshare_`j'=0
		cap local eshare_`j'=_b[_Isnic_`count']
		local count=`count'+1
		}
	qreg elecshare_Y year if nic2=="`l'" & scheme_final==1 &  (qelecprod<=0 | qelecprod==.)
	local eshare2_2dig_`l'=_b[_cons]
	local eshare_yrtrend_2dig_`l'=_b[year]
	}
	

use "$work\sharecapture", clear
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
g mshareps0_final_2dig=mshareps0_2dig+mshareps0_yrtrend_2dig*year
g lshare_final_2dig=lshare_2dig+lshare_yrtrend_2dig*year
g eshare_final_2dig=eshare_2dig+eshare_yrtrend_2dig*year
g lambda_final_2dig=lambda_2dig+lambda_yrtrend_2dig*year


save "$work\sharecapture", replace
use "$work\sharecapture", clear
g alphaK_final=1-mshare_final-lshare_final-eshare_final
g alphaK_2dig=1-mshare_final_2dig-lshare_final_2dig-eshare_final_2dig

g flag = alphaK_final<0 | lshare_final<0 | mshare_final<0 | eshare_final<0
replace mshare_final=mshare_final_2dig if flag
replace mshareps0_final=mshareps0_final_2dig if flag | mshareps0_final<0 
replace lshare_final=lshare_final_2dig if flag
replace alphaK_final=alphaK_2dig if flag
replace eshare_final=eshare_final_2dig if eshare_final<0
drop flag

replace mshare_final = mshare_final /(mshare_final+lshare_final) if alphaK_final <0
replace lshare_final = lshare_final /(mshare_final+lshare_final) if alphaK_final <0
replace mshareps0_final = mshareps0_final /(mshareps0_final+lshare_final) if alphaK_final <0
replace alphaK_final=.001 if alphaK_final <0

gsort nic87_super +year

replace lambda_final=lambda_final_2dig if lambda_final<0

*need to do this for cobbdouglass & leontief differences 1st and 2nd
*this is the right way to do leontief alphaK
g mshare_leontief=mshare_final/(1-eshare_final)
g mshareps0_leontief=mshareps0_final/(1-eshare_final)
g lshare_leontief=lshare_final/(1-eshare_final)
g alphaK_leontief=.9-mshare_leontief-lshare_leontief
g alphaK_leontief_CES=1-mshare_leontief-lshare_leontief
g alphaK_leontief_eps4=.75-mshare_leontief-lshare_leontief


g mshare_final_2dig_leontief=mshare_final_2dig/(1-eshare_final_2dig)
g mshareps0_final_2dig_leontief=mshareps0_final_2dig/(1-eshare_final_2dig)
g lshare_final_2dig_leontief=lshare_final_2dig/(1-eshare_final_2dig)
g alphaK_2dig_leontief=.9-mshare_final_2dig_leontief-lshare_final_2dig_leontief
g alphaK_2dig_leontief_CES=1-mshare_final_2dig_leontief-lshare_final_2dig_leontief
g alphaK_2dig_leontief_eps4=.75-mshare_final_2dig_leontief-lshare_final_2dig_leontief


***do replacement with 2-digit estimation coefficients when any of the regular coefficients look weird 
g flag = alphaK_leontief<0 | lshare_leontief<0 | mshare_leontief<0 | eshare_final<0
replace mshare_leontief=mshare_final_2dig_leontief if flag
replace mshareps0_leontief=mshareps0_final_2dig_leontief if flag | mshareps0_leontief<0 
replace lshare_leontief=lshare_final_2dig_leontief if flag
replace alphaK_leontief=alphaK_2dig_leontief if flag
replace alphaK_leontief_CES=alphaK_2dig_leontief_CES if alphaK_leontief_CES<0
replace alphaK_leontief_eps4=alphaK_2dig_leontief_eps4 if alphaK_leontief_eps4<0
drop flag

***adjust coefficients if there is still a negative capital coefficient (this happens rarely)
replace mshare_leontief = mshare_leontief /(mshare_leontief+lshare_leontief) if alphaK_leontief <0
replace lshare_leontief = lshare_leontief /(mshare_leontief+lshare_leontief) if alphaK_leontief <0
replace mshareps0_leontief = mshareps0_leontief /(mshareps0_leontief+lshare_leontief) if alphaK_leontief <0
replace alphaK_leontief=.001 if alphaK_leontief <0
replace alphaK_leontief_CES = .001 if alphaK_leontief_CES<0

forval i = 0/18 {
qui sum alphaK_leontief_eps4 if year==`i' & alphaK_leontief_eps4>0, d
replace alphaK_leontief_eps4 = r(p50) if alphaK_leontief_eps4 <=0 & year==`i'
}

***adjust robustness check capital coefficients if there is still a negative capital coefficient (this happens rarely)

noi dis "final shares assertion"
foreach i in mshare mshareps0 lshare alphaK {
assert `i'_final>=0
assert `i'_leontief>=0
}
assert eshare_final>=0
assert lambda_final>=0


replace year = year+1992
keep year snic *_final *_leontief *_leontief_eps4 *_leontief_CES
save "$work\M and L shares from qreg", replace

histogram mshare_final
graph export "$work\median matlsshare hist_new.wmf", replace
histogram lshare_final
graph export "$work\median laborshare hist_new.wmf", replace
histogram alphaK_final
graph export "$work\median Kshare hist_new.wmf", replace
histogram eshare_final
graph export "$work\median Eshare hist_new.wmf", replace
histogram lambda_final
graph export "$work\median lambda hist_new.wmf", replace

	
*sum mshare lshare alphaK	


/*


use `sharecapture', clear
levelsof nic2, local(levels)
levelsof snic, local(supernic)
 
qui foreach l of local levels {
dis `l'
dis "`l'"
replace mshare=`mshare2_`l'' if nic2=="`l'"
replace mshare_yrtrend=`mshare_yrtrend_`l'' if nic2=="`l'"
replace lshare=`lshare2_`l'' if nic2=="`l'"
replace lshare_yrtrend=`lshare_yrtrend_`l'' if nic2=="`l'"
replace eshare=`eshare2_`l'' if nic2=="`l'"
replace eshare_yrtrend=`eshare_yrtrend_`l'' if nic2=="`l'"
}
qui foreach j of local supernic {
dis `j'
dis "`j'"
replace mshare_super=`mshare_`j'' if snic==`j'
replace lshare_super=`lshare_`j'' if snic==`j'
replace eshare_super=`eshare_`j'' if snic==`j'
}
g mshare_final=mshare+mshare_super+mshare_yrtrend*year
g lshare_final=lshare+lshare_super+lshare_yrtrend*year
g eshare_final=eshare+eshare_super+eshare_yrtrend*year
*g alphaK=1-mshare_final-lshare_final-eshare_final

replace year = year+1992
save "$work\M and L shares from qreg", replace

histogram mshare_final
graph export "$work\median matlsshare hist.wmf", replace
histogram lshare_final
graph export "$work\median laborshare hist.wmf", replace
histogram alphaK
graph export "$work\median Kshare hist.wmf", replace
histogram eshare_final
graph export "$work\median Eshare hist.wmf", replace
	
sum mshare lshare alphaK	
