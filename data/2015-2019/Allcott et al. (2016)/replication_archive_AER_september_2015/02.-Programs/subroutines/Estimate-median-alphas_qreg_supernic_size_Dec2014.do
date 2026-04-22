
use "$intdata/ASIpanel_fulldataset_Nov2014.dta", replace

preserve
keep nic2 nic87_super  snic year
replace year = year-1992
duplicates drop
foreach input in mshare lshare eshare lambda {
g `input'=.
g `input'_super=.
g `input'_yrtrend=.
g `input'_sizetrend=.
g `input'_sizetrendSE=.
}

gsort nic2 year
save "$work/sharecapture_size", replace


****SELECT DATASET DOWN TO FIRMS WITH FULL ACCOUNTS (YKLM ETC)
restore

g mshare_Y=(matls_fuels_noSG_defl*input_deflator/100)/(grsale_nominal)
g lshare_Y=labcost_nominal/(grsale_nominal)
g eshare_Y=velecpur_nominal/(grsale_nominal)
g lambda_Y=(qeleccons)/(grsale_defl)
*cap drop lnL
*g lnL=ln(totpersons+1)
*	replace lnL=ln(totemp+1) if totpersons==. & totemp!=. //for some reason, totpersons is null in 98 and 99?
bys panelgroup: egen med_lnY = median(lnY)

replace year = year-1992

keep mshare_Y lshare_Y eshare_Y snic nic87_super nic2 year lambda_Y med_lnY panelgroup
foreach input in mshare lshare eshare lambda {
local count = 1
levelsof nic2, local(levels) 
foreach l of local levels {
	xi: qreg2 `input'_Y med_lnY year i.snic if nic2=="`l'", cluster(panelgroup)
	local `input'2_`l'=_b[_cons]
	local `input'_yrtrend_`l'=_b[year]
	local `input'_sizetrend_`l'=_b[med_lnY]
	local `input'_sizetrendSE_`l'=_se[med_lnY]
	levelsof snic if nic2=="`l'", local(supernic)
	foreach j of local supernic {
		dis `j'
		local `input'_`j'=0
		cap local `input'_`j'=_b[_Isnic_`count']
		local count=`count'+1
		dis ``input'_`j''
		dis ``input'_`j''+``input'2_`l''
		}
	}
preserve
use "$work/sharecapture_size", clear
levelsof nic2, local(levels)
foreach l of local levels {
dis `l'
dis "`l'"
replace `input'=``input'2_`l'' if nic2=="`l'"
replace `input'_yrtrend=``input'_yrtrend_`l'' if nic2=="`l'"
replace `input'_sizetrend=``input'_sizetrend_`l'' if nic2=="`l'"
replace `input'_sizetrendSE=``input'_sizetrendSE_`l'' if nic2=="`l'"
}

levelsof snic, local(supernic)
foreach j of local supernic {
dis `j'
dis "`j'"
replace `input'_super=``input'_`j'' if snic==`j'
}
g `input'_final=`input'+`input'_super+`input'_yrtrend*year

save "$work/sharecapture_size", replace
restore	
}

use  "$work/sharecapture_size",clear
replace year = year+1992
save "$work/sharecapture_size", replace

use  "$work/sharecapture_size",clear
foreach input in mshare lshare eshare lambda {
g `input'_t = abs(`input'_sizetrend/`input'_sizetrendSE)
}

scatter mshare_t mshare_sizetrend || scatter lshare_t lshare_sizetrend || scatter eshare_t eshare_sizetrend , ///
 yline(1.96) xtitle(coefficient) ytitle(t-stat) legend(lab(1 "Materials") lab(2 "Labor") lab(3 "Electricity")) ///
 title(coefficients and t-stats on med_lnY term) subtitle(in revenue share median regressions by 2-digit industry)

