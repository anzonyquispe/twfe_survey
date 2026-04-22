******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
*********************************************************
* THIS FILE GENERATES BSCI ICT CAPITAL STOCKS
****************************************************************************
* 1. Building the Lite Files 
* Creates 'Lite' files for 1999 - 2002
* Renames the relevant vbls for 1999 to the corresponding 2000 names
* Appends all data
* Inputs:   bsci2000.dta
*		bsci2001.dta
*		bsci2002.dta
*		bsci1999.dta
*		bsci1998.dta
* Outputs:  temp\2000lite.dta
*		temp\2001lite.dta
*		temp\2002lite.dta
*		temp\1999lite.dta
*	
****************************************************************************

cd "H:\Raffaella\ICT\Files_March_07\0.ICT STOCKS\BSCI"

* create the "lite" versions for years 2000,1,2,3
clear
set mem 700m
use "bsci2000.dta", clear
keep ruref sic92 size q19 q19_t q19_e q20 q20_t q20_e q25 q25_t q25_e q80 q80_t q80_e q81_t q81_e q82 q82_t  q82_e q83 q83_t q83_e q90 q90_t q90_e q91 q91_t q91_e
gen year = 2000
save "temp\2000lite.dta", replace

use "bsci2001.dta", clear
keep ruref sic92 size q19 q19_t q19_e q20 q20_t q20_e q25 q25_t q25_e q80 q80_t q80_e q81_t q81_e q82 q82_t  q82_e q83 q83_t q83_e q90 q90_t q90_e q91 q91_t q91_e
gen year = 2001
save "temp\2001lite.dta", replace

use "bsci2002.dta", clear
keep ruref sic92 size q19 q19_t q19_e q20 q20_t q20_e q25 q25_t q25_e q80 q80_t q80_e q81_t q81_e q82  q82_t  q82_e q83 q83_t q83_e q90 q90_t q90_e q91 q91_t q91_e  q116 q116_t q116_e
gen year = 2002
save "temp\2002lite.dta", replace

use "bsci2003.dta", clear
keep ruref sic92 size q19 q19_t q19_e q20 q20_t q20_e q25 q25_t q25_e q80 q80_t q80_e q81_t q81_e q82  q82_t  q82_e q83 q83_t q83_e q90 q90_t q90_e q91 q91_t q91_e  q116 q116_t q116_e
gen year = 2003
save "temp\2003lite.dta", replace

* create 1999'lite'
use "bsci1999.dta", clear
keep ruref sic92 _4010 _4020 _4070 _3001a _3001d _3002a _3002d _3221a _3221d
gen year = 1999
* change names and data types
rename _4010 q19
rename _4020 q20
rename _4070 q25
rename _3001a q80
rename _3001d q81
rename _3002a q82
rename _3002d q83
rename _3221a q90
rename _3221d q91
destring q19, replace
destring q20, replace
destring q25, replace
destring q80, replace
destring q81, replace
destring q82, replace
destring q83, replace
destring q90, replace
destring q91, replace
save "temp\1999lite.dta", replace

*create 1998
clear
insheet using "bsci_1998.csv",clear
keep ruref sic92 q4_soft q30020a q30020d
gen year = 1998
rename q4_soft q25
rename q30020a q82
rename q30020d q83
destring q25, replace
destring q82, replace
destring q83, replace
save "temp\1998lite.dta", replace

* append all
clear
gen temp=.
app using "temp\1998lite.dta"
app using "temp\1999lite.dta"
app using "temp\2000lite.dta"
app using "temp\2001lite.dta"
app using "temp\2002lite.dta"
app using "temp\2003lite.dta"
sort ruref
save "temp\1998-2003_bsci.dta", replace


***************************************************
* Recode zeros as missings whenever we have the info
***************************************************
replace q25 =. if q25==0 & year ==1999
replace q82 =. if q82==0 & year ==1999
replace q25 =. if q25_t!=1 & year != 1999
replace q82 =. if q82_t!=1 & year != 1999
sort ruref year
save "BSCIlite.dta", replace


*************************************************************** 
** 2. Building the Capital stocks
** Takes the BSCI IT investment data, fills in to rectangularise 
** the dataset, and uses NIESR data to compute initial values
** of the firm level capital stocks
****************************************************************
*  Now fill in so that we have space to extrapolate
local i = _N+1
set obs `i'
replace year = 1998 in `i'
replace ruref = ruref[_n-1] in `i'
fillin ruref year
rename _fillin expansionFillin
label variable expansionFillin "Fillin of missing years in squaring BSCI lite"

* We need to address a problem of duplication of rurefs in 1999
sort ruref year
drop if year!=year[_n-1]+1 & ruref == ruref[_n-1]
*need to fill in the sic codes too...
replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92*10 if sic92==1410

* generate 2 digits sic code to merge with niesr
gen sic = int(sic92/1000)
gen manuf=0
replace manuf=1 if sic>=15 & sic<=37
replace manuf=. if sic==.

*******************************************************
** Interpolate missing values of NET investments     **
*******************************************************
* First generate net investments for hardware (if disposals are not missing)
replace q83=0 if q83==.
gen q82_net = q82-q83

* Now interpolate net investments 
sort ruref year
by ruref: ipolate q25 year, gen(pred_q25) 
by ruref: ipolate q82_net year, gen(pred_q82)
* Dummy to keep track of interpolations
gen ip_sw=(q25==. & pred_q25~=.)
gen ip_hw=(q82_net==. & pred_q82~=.)

replace q82_net=77.18994 if year==1999 & ruref==49900189142
save "BSCIlite_expanded.dta", replace


***********************************************************
** Merge NISEC K/I ratios  - File generated in qice file **
***********************************************************
use "BSCIlite_expanded.dta
sort sic year
merge sic year using nisec.dta
drop if _m==2
drop _m
drop if ruref == .
*keep  ruref sic92 age age_t q25 q82 year q25_t q25_e q82_t q82_e sic pred_q25 pred_q82 computers software  q82_net ip*

***********************************************************************************
** Create the Capital Stocks      
***********************************************************************************
* Generate Real investments

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


gen pred_q25_def = pred_q25/def_s
gen pred_q82_def = pred_q82/def_h
save "BSCI_pro.dta", replace

*******************************************************
* Try to build capital stock using different weights
*******************************************************
* note: wallpap.dta created in qice file

*** Only for bsci
clear
use "BSCI_pro.dta", clear
ge bsci=1
keep ruref year bsci
so ruref year
merge ruref year using "H:\Raffaella\ICT\Files_March_07\0.ICT STOCKS\QICE\wallpap.dta"
keep if bsci==1
gen non_ex=1 if _m==1
so ruref year
drop _m
save "wallpap_bsci.dta", replace



use "BSCI_pro.dta", clear
rename pred_q82 pred_hw
rename pred_q25 pred_sw
rename pred_q82_def pred_hw_def
rename pred_q25_def pred_sw_def
so ruref year
merge ruref year using "wallpap_bsci.dta"
**
*drop if non_ex==1
**
drop if year<1998
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


/* Allocation weights
gen cs_h= Comp if pred_hw_def~=. & pred_hw_def~=0
gen cs_s= Comp if pred_sw_def~=. & pred_sw_def~=0
bys sic year: egen sum_cs_h = sum(cs_h) if pred_hw_def~=. & pred_hw_def~=0 & Comp~=.
gen weight_h = Comp/sum_cs_h
bys sic year: egen sum_cs_s = sum(cs_s) if pred_sw_def~=. & pred_sw_def~=0 & Comp~=.
gen weight_s = Comp/sum_cs_s
*/

so ruref year
gen e_h= sel_emp if pred_hw_def~=. & pred_hw_def~=0 & sel_emp>=0
gen e_s= sel_emp if pred_sw_def~=. & pred_sw_def~=0 & sel_emp>=0
bys sic year: egen sum_e_h = sum(e_h) if pred_hw_def~=. & pred_hw_def~=0 & sel_emp>=0
gen weight_h_e = sel_emp/sum_e_h
bys sic year: egen sum_e_s = sum(e_s) if pred_sw_def~=. & pred_sw_def~=0 & sel_emp>=0
gen weight_s_e = sel_emp/sum_e_s

* Normalization weigths
/* Computer services
gen pred_hw_def_sel_cs = pred_hw_def if pred_hw_def~=. & pred_hw_def~=0 & Comp~=.
gen pred_sw_def_sel_cs = pred_sw_def if pred_sw_def~=. & pred_sw_def~=0 & Comp~=.
bys sic year: egen sum_hw_inv_cs=sum(pred_hw_def_sel_cs) if pred_hw_def~=. & pred_hw_def~=0 & Comp~=.
bys sic year: egen sum_sw_inv_cs=sum(pred_sw_def_sel_cs) if pred_sw_def~=. & pred_sw_def~=0 & Comp~=.
*/


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
gen ksoftware_new_bsci  = 0.66*capital_sw_l* weight_s_e + pred_sw_def  if year==fyearSa & pred_sw_def~=0
gen khardware_new_bsci  = 0.66*capital_hw_l* weight_h_e + pred_hw_def if year==fyearHa & pred_hw_def~=0

*gen ksoftware_new_bsci  = 0.66*software_new_l* weight_s*sum_sw_inv_cs + pred_sw_def  if year==fyearSa & pred_sw_def~=0
*gen khardware_new_bsci  = 0.66*computers_new_l*weight_h*sum_hw_inv_cs + pred_hw_def if year==fyearHa & pred_hw_def~=0
gen ksoftware_new2_bsci = 0.66*software_new_l*weight_s_e*sum_sw_inv + pred_sw_def  if year==fyearSa & pred_sw_def~=0
gen khardware_new2_bsci = 0.66*computers_new_l*weight_h_e*sum_hw_inv + pred_hw_def if year==fyearHa & pred_hw_def~=0

so ruref year
by ruref:replace ksoftware_new_bsci=0.66*ksoftware_new_bsci[_n-1]+pred_sw_def if year>fyearSa
by ruref:replace khardware_new_bsci=0.66*khardware_new_bsci[_n-1]+pred_hw_def if year>fyearHa
by ruref:replace ksoftware_new2_bsci=0.66*ksoftware_new2_bsci[_n-1]+pred_sw_def if year>fyearSa
by ruref:replace khardware_new2_bsci=0.66*khardware_new2_bsci[_n-1]+pred_hw_def if year>fyearHa

******************************************
* Previous capital stock
******************************************
gen ksoftware_bsci =(pred_sw_def)*software_new if year==fyearS & pred_sw>=0
so ruref year
by ruref:replace ksoftware_bsci=0.66*ksoftware_bsci[_n-1]+pred_sw_def if year>fyearS

gen khardware_bsci=(pred_hw_def)*computers_new if year==fyearH & pred_hw>=0
so ruref year
by ruref:replace khardware_bsci=0.66*khardware_bsci[_n-1]+pred_hw_def if year>fyearH

replace khardware_bsci=. if khardware_bsci<0
replace ksoftware_bsci=. if ksoftware_bsci<0
replace khardware_new_bsci=. if khardware_new_bsci<0
replace ksoftware_new_bsci=. if ksoftware_new_bsci<0
replace khardware_new2_bsci=. if khardware_new2_bsci<0
replace ksoftware_new2_bsci=. if ksoftware_new2_bsci<0

***********************************************************************************
** Series to keep for overall merging
*********************************************************************************** 
rename pred_sw_def softinv_bsci
rename pred_sw softinv_bsci_curr
rename pred_hw hardinv_bsci_curr
rename pred_hw_def hardinv_bsci
keep sic92 ruref year ip* softinv* ksoftware*  hardinv* khardware* 
rename sic92 sic_bsci
drop khardware_new_bsci ksoftware_new_bsci

lab var softinv_bsci "Interpolated Software Investment from bsci, deflated"
lab var hardinv_bsci "Interpolated Hardware Investment from bsci, deflated"
lab var ksoftware_bsci "Software Capital, bsci"
lab var khardware_bsci "Hardware Capital, bsci"
lab var ip_h "Dummy =1 if interpolated investment, Hardware"
lab var ip_s "Dummy =1 if interpolated investment, Software"
rename ip_h ip_hw_bsci
rename ip_s ip_sw_bsci
drop if  softinv_bsci_curr==. & hardinv_bsci_curr==. &  khardware_bsci==. & ksoftware_bsci==.
so ruref year
save "bscimerge.dta", replace








