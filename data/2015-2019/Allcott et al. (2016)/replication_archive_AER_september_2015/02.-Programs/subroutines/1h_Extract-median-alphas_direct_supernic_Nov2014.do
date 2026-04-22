g matlsshare_Y=matls_nominal/(grsale_nominal)
g laborshare_Y=labcost_nominal/(grsale_nominal)
g elecshare_Y=velecpur_nominal/(grsale_nominal)


preserve
*keep if qelecprod==0 | qelecprod==.
collapse (median) mshare_2dig_unc=matlsshare_Y lshare_2dig_unc=laborshare_Y eshare_2dig_unc=elecshare_Y , by(nic2)
tempfile nic2
save `nic2'
restore

*keep if qelecprod==0 | qelecprod==.
collapse (median) mshare_unc=matlsshare_Y lshare_unc=laborshare_Y eshare_unc=elecshare_Y , by(nic2 nic87_super  snic)
merge m:1 nic2 using `nic2', assert(3) nogen

g betak_CRS_unc=1-mshare_unc-lshare_unc
g alphaK_2dig_CRS_unc=1-mshare_2dig_unc-lshare_2dig_unc


***do replacement with 2-digit estimation coefficients when any of the regular coefficients look weird 
g flag = betak_CRS_unc<0 | lshare_unc<0 | mshare_unc<0 | eshare_unc<0
replace mshare_unc=mshare_2dig_unc if flag
replace lshare_unc=lshare_2dig_unc if flag
replace betak_CRS_unc=alphaK_2dig_CRS_unc if flag
drop flag

g flag = (lshare_unc+mshare_unc)>1
replace mshare_unc=mshare_2dig_unc if flag
replace lshare_unc=lshare_2dig_unc if flag
replace betak_CRS_unc=alphaK_2dig_CRS_unc if flag
drop flag


noi dis "med shares assertion"
foreach i in mshare lshare betak_CRS {
assert `i'_unc>=0
}
assert eshare_unc>=0

drop *2dig*
keep snic *_unc

