******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
*********************************************************
* THIS FILE GENERATES QICE ICT CAPITAL STOCKS
** Part 1: Appends all qcex datasets
** Inputs:  cpx200XqY.dta X=1,2; Y=1,2,3,4 (as created via stat transfer from original CSV files
** Outputs: qcex_all_quarters.dta
**********************************************************
cd "H:\Raffaella\ICT\Files_March_07\0.ICT STOCKS\QICE"
clear
set mem 200m
foreach y in 2001 2002 2003{
forvalues q=1(1)4{
use "Originals\cpx`y'q`q'.dta",clear
drop quarter year
gen quarter = `q'
gen year = `y'
save, replace
}
}

** Append all
clear
gen temp=.
foreach y in 2001 2002 2003{
forvalues q=1(1)4{
append using "Originals\cpx`y'q`q'.dta"
}
}
drop temp
order ruref year quarter
so ruref year quarter
save "qcex_all_quarters.dta", replace

**********************************************************************
* Part. 2
* Rename the IT variables and drop other data
* inputs:  temp\qcex_all_quarters.dta, ie the appended quarterly data
* outputs: qcex_lite.dta
***********************************************************************

rename q694   sw
rename q694_t sw_t
rename q694_e sw_e

rename q695   hw_acquisitions
rename q695_t hw_acquisitions_t
rename q695_e hw_acquisitions_e

rename q696   hw_disposals
rename q696_t hw_disposals_t
rename q696_e hw_disposals_e

keep ruref sic92  quarter year sw sw_t sw_e hw_acquisitions hw_acquisitions_t hw_acquisitions_e hw_disposals hw_disposals_t hw_disposals_e

sort ruref year quarter
save "qcex_lite.dta", replace

************************************************************************
* Part 3
* creates annual values of all investments for firms from quarterly data
* Inputs:  qcex_lite.dta
* Outputs: temp\quaterly_annualised.dta
************************************************************************
*** We sum the variables over the quarters of the year.
*** By setting quarter to 1, when summing, "quarter" becomes the number of quarters the firms are
*** observed for over a year

recode sw_t 2/11= 0
recode hw_disposals_t 2/11= 0
recode hw_acquisitions_t 2/11= 0
recode quarter *=1
replace sic92 = int(sic92/10) if sic92==11200 | sic92==65221 | sic92==65231 | sic92==66010 | sic92==75120 | sic92==65239
replace sic92 = sic92*10 if sic92==141

* Adjust sic92 to have always the same sic over the years
bys ruref year: replace sic92=sic92[_n-1] if sic92~=sic92[_n-1] & ruref==ruref[_n-1] & year==year[_n-1]
collapse (sum) sw sw_t hw_acquisitions hw_acquisitions_t hw_disposals hw_disposals_t quarter (mean) sic92, by(ruref year)

**Total investment for the year is now given by the sw, hw_acquisitions etc vbls.
**Observations for which *_t==4 correspond to observations for which the RU was sampled
**in every quarter of the year and answered.
**Observations for which quarter==4 correspond to observations for which the RU was sampled
**in every quarter of the year (but did not necessarily answer all quarters).
**********

sort ruref year quarter
save "quarterly_annualised_long.dta", replace

*********************************************************************
** Part 4
** Build capital stocks                 
*******************************************************************
*  Now fill in so that we have space to extrapolate
local i = _N+1
set obs `i'
replace year = 2001 in `i'
replace ruref = ruref[_n-1] in `i'

fillin ruref year
rename _fillin expansionFillin
label variable expansionFillin "Fillin of missing years in squaring QCEX"
sort ruref year

* We need to address a problem of duplication of rurefs in 2000
drop if year!=year[_n-1]+1 & ruref == ruref[_n-1]
*need to fill in the sic codes too...

replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref

so ruref year

************************************************************
** Interpolations
** A. Treating zeros as actual values not as missing values
************************************************************
* Generate net investments
replace hw_disposals=0 if hw_disposals==.
gen hw_net= hw_acquisitions - hw_disposals
sort ruref year

by ruref: ipolate sw year, gen(pred_sw) 
by ruref: ipolate hw_net year, gen(pred_hw)
 
* Dummy to keep track of interpolations
gen ip_sw=(sw==. & pred_sw~=.)
gen ip_hw=(hw_net==. & pred_hw~=.)

/*
** B. Treating zeros as missing values
gen sw_zero=sw
replace sw_zero=. if sw==0 
gen hw_zero=hw_acquisitions
replace hw_zero=. if hw_acquisitions==0
by ruref: ipolate sw_zero year, gen(pred_sw_zero) 
by ruref: ipolate hw_zero year, gen(pred_hw_zero) 
*/

*******************************************************
** Adjust Sic codes to merge with NISEC              
*******************************************************
gen sic =int(sic92/100)  
gen manuf=0
replace manuf=1 if sic>=15 & sic<=37
replace manuf=. if sic==.

save "quarterly_annualised_long.dta", replace


*******************************************************
** Merge NISEC K/I ratios                            **
*******************************************************
clear
use "quarterly_annualised_long.dta",clear
sort sic year
merge sic year using nisec.dta
drop if _m==2
drop _m
drop if ruref == .

**************************************
** Create the Capital Stocks 
**************************************

* Deflators
* Note 2002 is extrapolated starting from 1998
* Note 2003 is as 2002
gen def_h = . 
replace def_h =3.607 if year==1995
replace def_h =2.778 if year==1996
replace def_h =2.053 if year==1997
replace def_h =1.501 if year==1998
replace def_h =1.153 if year==1999
replace def_h =1.000 if year==2000
replace def_h =0.805 if year==2001
replace def_h =0.555 if year==2002
replace def_h =0.555 if year==2003

gen def_s=.
replace def_s =1.079 if year==1995
replace def_s =1.064 if year==1996
replace def_s =1.004 if year==1997
replace def_s =0.976 if year==1998
replace def_s =0.979 if year==1999
replace def_s =1.000 if year==2000
replace def_s =1.010 if year==2001
replace def_s =1.022 if year==2002
replace def_s =1.022 if year==2003


* Real investments
gen pred_sw_def = pred_sw/def_s
gen pred_hw_def = pred_hw/def_h
save "qice_pro.dta", replace

*******************************************************
* Build capital stock using employment weights
*******************************************************
clear 
set mem 500m
gen temp =.
forvalues y=1998(1)2003{
foreach var in cng pdg cag mtg prg reg stg whg{
append using "W:\ard_std_vars3\results\pdat`y'`var'.dta"
}
}
destring dlink, gen(ruref)
gen id=1
keep ruref year sel_emp id
save "wallpap_dat.dta", replace

** Non selected
clear 
set mem 1000m
gen temp =.
forvalues y=1998(1)2003{
foreach var in cng pdg cag mtg prg reg stg whg{
append using "W:\ard_std_vars3\results\pnul`y'`var'.dta"
}
}
compress
destring dlink, gen(ruref)
so ruref year
gen id=0
keep ruref year sel_emp id
save "wallpap_nul.dta", replace

clear
use "wallpap_dat.dta", clear
append using "wallpap_nul.dta"
so ruref year
save "wallpap.dta", replace


*** ONLY FOR QICE
clear
set mem 1000m
use "qice_pro.dta", clear
keep ruref year 
gen qice=1
so ruref year
merge ruref year using "wallpap.dta"
keep if qice==1
so ruref year
gen non_ex=1 if _m==1
drop _m
save "wallpap_qice.dta", replace


use "qice_pro.dta", clear
drop hw_acquisitions_t hw_disposals_t sw_t def_h def_s
so ruref year
merge ruref year using "wallpap_qice.dta"

****
*drop if non_ex==1
*****
drop _m
so ruref year
drop if ruref==ruref[_n-1] & year==year[_n-1]
drop if ruref==ruref[_n+1] & year==year[_n+1]
 
****
gen capital_hw_2001 = capital_hw if year==2001
gen capital_sw_2001 = capital_sw if year==2001
bys ruref: egen pro=max(capital_hw_2001)
bys ruref: egen pro2=max(capital_sw_2001)
replace capital_hw_l = pro if year==2002
replace capital_sw_l = pro2 if year==2002
gen computers_new_2001 = computers_new if year==2001
gen software_new_2001 = software_new if year==2001
bys ruref: egen pro3=max(computers_new_2001)
bys ruref: egen pro4=max(software_new_2001)
replace computers_new_l = pro3 if year==2002
replace software_new_l = pro4 if year==2002
drop pro* computers_new_2001 software_new_2001 capital_hw_2001 capital_sw_2001
****

so ruref year
gen e_h= sel_emp if pred_hw_def~=. & pred_hw_def~=0 & sel_emp>=0
gen e_s= sel_emp if pred_sw_def~=. & pred_sw_def~=0 & sel_emp>=0
bys sic year: egen sum_e_h = sum(e_h) if pred_hw_def~=. & pred_hw_def~=0 & sel_emp>=0
gen weight_h_e = sel_emp/sum_e_h
bys sic year: egen sum_e_s = sum(e_s) if pred_sw_def~=. & pred_sw_def~=0 & sel_emp>=0
gen weight_s_e = sel_emp/sum_e_s

* Normalization weigths
* Employment
gen pred_hw_def_sel = pred_hw_def if pred_hw_def~=. & pred_hw_def~=0 & sel_emp~=.
gen pred_sw_def_sel = pred_sw_def if pred_sw_def~=. & pred_sw_def~=0 & sel_emp~=.
bys sic year: egen sum_hw_inv=sum(pred_hw_def_sel) if pred_hw_def~=. & pred_hw_def~=0 & sel_emp~=.
bys sic year: egen sum_sw_inv=sum(pred_sw_def_sel) if pred_sw_def~=. & pred_sw_def~=0 & sel_emp~=.

egen fyear1Sa=min(year) if pred_sw~=. & pred_sw~=0,by(ruref)
egen fyearSa=min(fyear1Sa),by(ruref)
egen fyear1Ha=min(year) if pred_hw~=. & pred_hw~=0,by(ruref)
egen fyearHa=min(fyear1Ha),by(ruref)

egen fyear1S=min(year) if pred_sw~=.,by(ruref)
egen fyearS=min(fyear1S),by(ruref)
egen fyear1H=min(year) if pred_hw~=. & pred_hw>=0,by(ruref)
egen fyearH=min(fyear1H),by(ruref)

******************************************
* New Capital Stock
******************************************
* With normalization
gen ksoftware_new2_qice = 0.66*software_new_l*weight_s_e*sum_sw_inv + pred_sw_def  if year==fyearSa & pred_sw_def~=0 
gen khardware_new2_qice = 0.66*computers_new_l*weight_h_e*sum_hw_inv + pred_hw_def if year==fyearHa & pred_hw_def~=0 

so ruref year
by ruref:replace ksoftware_new2_qice=0.66*ksoftware_new2_qice[_n-1]+pred_sw_def if year>fyearSa
by ruref:replace khardware_new2_qice=0.66*khardware_new2_qice[_n-1]+pred_hw_def if year>fyearHa

******************************************
* Previous capital stock
******************************************
gen ksoftware_qice =(pred_sw_def)*software_new if year==fyearS & pred_sw>=0
gen khardware_qice =(pred_hw_def)*computers_new if year==fyearH & pred_hw>=0

so ruref year
by ruref:replace ksoftware_qice=0.66*ksoftware_qice[_n-1]+pred_sw_def if year>fyearS
by ruref:replace khardware_qice=0.66*khardware_qice[_n-1]+pred_hw_def if year>fyearH

* drop negative stocks
replace khardware_qice=. if khardware_qice<0
replace ksoftware_qice=. if ksoftware_qice<0
replace khardware_new2_qice=. if khardware_new2_qice<0
replace ksoftware_new2_qice=. if ksoftware_new2_qice<0


***********************************************************************************
** Series to keep for overall merging
*********************************************************************************** 
rename pred_sw_def softinv_qice
rename pred_sw softinv_qice_curr

*rename sw_t softinv_qice_code
rename pred_hw hardinv_qice_curr

rename pred_hw_def hardinv_qice
*rename hw_acquisitions_t hardinv_qice_code

*keep quarter sic92 ruref year ip* softinv* ksoftware*  hardinv* khardware* 
keep quarter sic92 ruref year  softinv* ksoftware*  hardinv* khardware* ip*
rename ip_hw ip_hw_qice
rename ip_sw ip_sw_qice

rename sic92 sic_qice

lab var softinv_qice "Interpolated Software Investment from qice, deflated"
lab var hardinv_qice "Interpolated Hardware Investment from qice, deflated"
lab var ksoftware_qice "Software Capital, qice"
lab var khardware_qice "Hardware Capital, qice"
*lab var ip_h "Dummy =1 if interpolated investment, Hardware"
*lab var ip_s "Dummy =1 if interpolated investment, Software"
drop if  softinv_qice_curr==. & hardinv_qice_curr==. &  khardware_qice==. & ksoftware_qice==.
so ruref year
save "qicemerge.dta", replace








