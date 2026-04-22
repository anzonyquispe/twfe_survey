******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
*********************************************************
* THIS FILE:
* Builds Software capital stocks from ARD data
* Using deflated NIESR data
* 
*********************************************************
*   Appends years 1995-2002 of the ABI
*   Merges Ralf Martin's capital stock estimates for the same period
*   Input:  ARD standard variables data sets
*	      Ralf's capstock_06.dta
*   Output: "T:\ONS\Giles_Gale\Raffaella\ardict.dta"
*******************************************************
/*clear
set mem 500m
gen temp=.
forvalues y=2000(1)2003{
foreach var in cng pdg cag mtg prg reg stg whg{
append using "W:\ard_std_vars3\results\pdat`y'`var'.dta"
}
}
destring dlink, gen(ruref)
destring dlink, replace
so ruref year
keep  year sic92 region dlink_ref2 software_investment emp Comp
rename dlink ruref
rename software_investment softinv_ard
sort ruref year
save "Soft1.dta", replace
*/

*************************************************************** 
** 2. Building the Capital stocks
** Takes the IT investment data, fills in to rectangularise 
** the dataset, and uses NIESR data to compute initial values
** of the firm level capital stocks
****************************************************************

cd "H:\Raffaella\ICT\Files_March_07\0.ICT STOCKS\ARD"
u "Soft1.dta", replace
*  Now fill in so that we have space to extrapolate
local i = _N+1
set obs `i'
replace year = 2000 in `i'
replace ruref = ruref[_n-1] in `i'

fillin ruref year
rename _fillin expansionFillin
label variable expansionFillin "Fillin of missing years"
sort ruref year

*need to fill in the sic codes too...
replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n-1] if sic92[_n-1]!=. & sic92==. & ruref[_n-1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref
replace sic92 = sic92[_n+1] if sic92[_n+1]!=. & sic92==. & ruref[_n+1]==ruref

replace sic92 = sic92*10 if sic92==1410 | sic92==1421 | sic92==1429 | sic92==1500
* generate 2 digits sic code to merge with niesr
gen sic = int(sic92/1000)
gen manuf=0
replace manuf=1 if sic>=15 & sic<=37
replace manuf=. if sic==.

*******************************************************
** Interpolate missing values                        **
*******************************************************
sort ruref year
by ruref: ipolate softinv_ard year, gen(pred_sard) 
save "Soft.dta", replace


*******************************************************
** Merge NISEC K/I ratios -generated in qice         **
*******************************************************
use "Soft.dta",clear
sort sic year
merge sic year using nisec.dta
drop if _m==2
drop _m
drop if ruref == .
save Soft.dta, replace

***********************************************************************************
** Create the Capital Stocks                                                     **

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
gen pred_sard_def = pred_sard/def_s
save "Soft_new.dta", replace

*******************************************************
* Try to build capital stock using different weights
*******************************************************

****** Now alternative methods 

use "Soft_new.dta", clear
rename emp sel_emp
so ruref year
rename pred_sard pred_sw 
rename pred_sard_def pred_sw_def
drop if pred_sw==.


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
gen cs_s= Comp if pred_sw_def~=. & pred_sw_def~=0
bys sic year: egen sum_cs_s = sum(cs_s) if pred_sw_def~=. & pred_sw_def~=0 & Comp~=.
gen weight_s = Comp/sum_cs_s
*/

gen e_s= sel_emp if pred_sw_def~=. & pred_sw_def~=0 & sel_emp>=0
bys sic year: egen sum_e_s = sum(e_s) if pred_sw_def~=. & pred_sw_def~=0 & sel_emp>=0
gen weight_s_e = sel_emp/sum_e_s

* Normalization weigths
/* Computer services
gen pred_sw_def_sel_cs = pred_sw_def if pred_sw_def~=. & pred_sw_def~=0 & Comp~=.
bys sic year: egen sum_sw_inv_cs=sum(pred_sw_def_sel_cs) if pred_sw_def~=. & pred_sw_def~=0 & Comp~=.
*/

* Employment
gen pred_sw_def_sel = pred_sw_def if pred_sw_def~=. & pred_sw_def~=0 & sel_emp~=.
bys sic year: egen sum_sw_inv=sum(pred_sw_def_sel) if pred_sw_def~=. & pred_sw_def~=0 & sel_emp~=.

egen fyear1Sa=min(year) if pred_sw~=. & pred_sw~=0,by(ruref)
egen fyearSa=min(fyear1Sa),by(ruref)

egen fyear1S=min(year) if pred_sw~=.,by(ruref)
egen fyearS=min(fyear1S),by(ruref)

******************************************
* New Capital Stock
******************************************
gen ksoftware_new_ard  = 0.66*capital_sw_l* weight_s_e + pred_sw_def  if year==fyearSa & pred_sw_def~=0
*gen ksoftware_new_ard  = 0.66*software_new_l* weight_s*sum_sw_inv_cs + pred_sw_def  if year==fyearSa & pred_sw_def~=0
gen ksoftware_new2_ard = 0.66*software_new_l*weight_s_e*sum_sw_inv + pred_sw_def  if year==fyearSa & pred_sw_def~=0

so ruref year
by ruref:replace ksoftware_new_ard=0.66*ksoftware_new_ard[_n-1]+pred_sw_def if year>fyearS
by ruref:replace ksoftware_new2_ard=0.66*ksoftware_new2_ard[_n-1]+pred_sw_def if year>fyearS

******************************************
* Previous capital stock
******************************************
gen ksoftware_ard =(pred_sw_def)*software_new if year==fyearS & pred_sw>=0
so ruref year
by ruref:replace ksoftware_ard=0.66*ksoftware_ard[_n-1]+pred_sw_def if year>fyearS

replace ksoftware_ard=. if ksoftware_ard<0
replace ksoftware_new_ard=. if ksoftware_new_ard<0
replace ksoftware_new2_ard=. if ksoftware_new2_ard<0

***********************************************************************************
** Series to keep for overall merging
*********************************************************************************** 
drop softinv_ard
rename pred_sw_def softinv_ard
rename pred_sw softinv_ard_curr

keep sic92 ruref year  softinv* ksoftware*  
drop ksoftware_new_ard
rename sic92 sic_ard

lab var softinv_ard "Interpolated Software Investment from ard, deflated"
lab var ksoftware_ard "Software Capital, ard"
drop if  softinv_ard==. & ksoftware_ard==.
so ruref year
save "ardmerge.dta", replace




