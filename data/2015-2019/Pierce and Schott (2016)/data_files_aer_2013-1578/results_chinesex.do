/*    


This program generates the results for Table 3 from "The Surprisingly Swift Decline of 
U.S. Manufacturing Employment" by Justin R. Pierce and Peter K. Schott

The datasets used in this paper are created in data_create.do



*/



clear
clear matrix
set more off
set mem 6g


*1 Get spread ready: need to take averages at the six-digit level to match with chinese transactions
use input/tar_val.dta", clear
gen miss = spread==.
tab year miss
drop miss
drop if spread==.
replace spread=0 if spread<0
gen double hs6num = int(hs8num/100)
collapse (mean) spread, by(hs6num year)
rename spread s6_
reshape wide s6_, i(hs6num) j(year)
rename hs6num hs6
sort hs6
save interim/temp_tar_val_6_wide, replace


*2 Assemble and clean raw chinese transactions data from Khandelwal et al. 2013
*
*  Spread matches 95% of hs6, representing 97 % of value
*
*  ownership types
*  0	missing	
*  1	state-owned	
*  2	collective-owned	
*  3	other	
*  4	Private-Domestic	
*  5	Foreign-Exclusive-Owned	
*  6	Joint-Venture (China&Foreign, Joint Investment)	
*  7	Joint-Venture (China&Foreign, Joint Operating)	
*
*  shipment types
*  10	general trade		
*  11	stuff donated by international organizations or the foreign country		
*  12	other donated stuff		
*  13	compensation trade		
*  14	assembling trade		
*  15	processing trade		
*  16	Consignment trade		
*  19	petty trade in the border areas		
*  20	Processing and Assembling Trade		
*  22	exporting due to domestic firm's Contracting Foreign Projects		
*  23	lease trade		
*  25	imported by foregin parents as investment goods		
*  27	imported stuff for further processing		
*  30	barter trade (goods exchange for goods)		
*  31	tariff-free trade		
*  33	Bonded Warehouse and Goods 		
*  34	Entrepot Trade by Bonded Area		
*  35	imported machines by firms in Export Processing Zones"		
*  39	others		
*


*2.1 create basic file
use input\data_2000_0,clear
forval i = 2001/2005 {
	append using d:\data\china_transactions\data_`i'_0
}
gen hs6s     = substr(hs_id,1,6)
collapse (sum) value, by(hs6s party_id shipment_id ownership year countrycode) fast
destring hs6s, force g(hs6)
gen double v000 = v/1000000
sort hs6
merge m:1 hs6 using  interim/temp_tar_val_6_wide, keepus(s6_1999)
tab _merge
drop if _merge==2
table _merge, c(count hs6 sum value) f(%18.0fc)
drop _merge
table ownership year, c(sum v000) f(%10.0fc)
table shipment year, c(sum v000) f(%10.0fc)
save interim/xchn_01, replace 

*2.2 create several files used in regressions below

*2.2.1 collapse by 3 ownership types and shipment type  
use interim/xchn_01, clear
gen o = .
replace o=1 if ownership>=1 & ownership<=2
replace o=2 if ownership==4
replace o=3 if ownership>=5
keep if shipment==10 | shipment==14 | shipment==15
egen n  = tag(party_id o shipment hs6s country year)
collapse (sum) value n (mean) s6_1999, by(o shipment hs6s year countrycode) fast
foreach x in value n {
	gen l`x' = ln(`x')
}
gen f    = o==1
gen u    = countrycode==9000
gen s    = s6_1999
gen us   = u*s6_1999
foreach x in u s us {
	gen `x'_f    = `x'*f
}	
forvalues y=2001(1)2005 {
	gen y`y'   = year==`y'
	gen sy`y'  = s*y`y'
	gen uy`y'  = u*y`y'
	gen usy`y' = u*s*(year==`y')	
	foreach x in f {
		gen sy`y'_`x'  = s*y`y'*`x'
		gen uy`y'_`x'  = u*y`y'*`x'
		gen usy`y'_`x' = u*s*(year==`y')*`x'	
	}
}
gen post = year>=2001
foreach x in s u us {
	gen `x'_after       = `x'*post
	gen `x'_f_after     = `x'_f*post
}
gen f_after = f*post
xi i.countrycode, noomit
drop if s6==.
save interim/xchn_02_simple_o3_s3, replace 


*2.2.2 collapse by 3 ownership types and shipment type  
use interim/xchn_01, clear
gen o = .
replace o=1 if ownership>=1 & ownership<=2
replace o=2 if ownership==4
replace o=3 if ownership>=5
keep if shipment==10 | shipment==14 | shipment==15
replace shipment=99 if shipment==14 | shipment==15
egen n  = tag(party_id o shipment hs6s country year)
collapse (sum) value n (mean) s6_1999, by(o shipment hs6s year countrycode) fast
foreach x in value n {
	gen l`x' = ln(`x')
}
gen f    = o==1
gen u    = countrycode==9000
gen s    = s6_1999
gen us   = u*s6_1999
foreach x in u s us {
	gen `x'_f    = `x'*f
}	
forvalues y=2001(1)2005 {
	gen y`y'   = year==`y'
	gen sy`y'  = s*y`y'
	gen uy`y'  = u*y`y'
	gen usy`y' = u*s*(year==`y')	
	foreach x in f {
		gen sy`y'_`x'  = s*y`y'*`x'
		gen uy`y'_`x'  = u*y`y'*`x'
		gen usy`y'_`x' = u*s*(year==`y')*`x'	
	}
}
gen post = year>=2001
foreach x in s u us {
	gen `x'_after       = `x'*post
	gen `x'_f_after     = `x'_f*post
}
gen f_after = f*post
xi i.countrycode, noomit
drop if s6==.
save interim/xchn_02_simple_o3_s2, replace 



*2.2.3 collapse by 3 ownership types and 1 shipment type  
use interim/xchn_01, clear
gen o = .
replace o=1 if ownership>=1 & ownership<=2
replace o=2 if ownership==4
replace o=3 if ownership>=5
keep if shipment==10 | shipment==14 | shipment==15
replace shipment=99 
egen n  = tag(party_id o shipment hs6s country year)
collapse (sum) value n (mean) s6_1999, by(o shipment hs6s year countrycode) fast
foreach x in value n {
	gen l`x' = ln(`x')
}
gen f    = o==1
gen u    = countrycode==9000
gen s    = s6_1999
gen us   = u*s6_1999
foreach x in u s us {
	gen `x'_f    = `x'*f
}	
forvalues y=2001(1)2005 {
	gen y`y'   = year==`y'
	gen sy`y'  = s*y`y'
	gen uy`y'  = u*y`y'
	gen usy`y' = u*s*(year==`y')	
	foreach x in f {
		gen sy`y'_`x'  = s*y`y'*`x'
		gen uy`y'_`x'  = u*y`y'*`x'
		gen usy`y'_`x' = u*s*(year==`y')*`x'	
	}
}
gen post = year>=2001
foreach x in s u us {
	gen `x'_after       = `x'*post
	gen `x'_f_after     = `x'_f*post
}
gen f_after = f*post
xi i.countrycode, noomit
drop if s6==.
save interim/xchn_02_simple_o3_s1, replace 


*2.2.4 collapse by 1 ownership types and 4 shipment types  
use interim/xchn_01, clear
gen o=1
keep if ownership==1 | ownership==2 | ownership==4 | ownership>=5
keep if shipment==10 | shipment==14 | shipment==15
save temp1, replace

use temp1, clear
drop if shipment==10
replace shipment=99
save temp2, replace

use temp1, clear
append using temp2
egen n  = tag(party_id o shipment hs6s country year)
collapse (sum) value n (mean) s6_1999, by(o shipment hs6s year countrycode) fast
foreach x in value n {
	gen l`x' = ln(`x')
}
gen f    = o==1
gen u    = countrycode==9000
gen s    = s6_1999
gen us   = u*s6_1999
foreach x in u s us {
	gen `x'_f    = `x'*f
}	
forvalues y=2001(1)2005 {
	gen y`y'   = year==`y'
	gen sy`y'  = s*y`y'
	gen uy`y'  = u*y`y'
	gen usy`y' = u*s*(year==`y')	
	foreach x in f {
		gen sy`y'_`x'  = s*y`y'*`x'
		gen uy`y'_`x'  = u*y`y'*`x'
		gen usy`y'_`x' = u*s*(year==`y')*`x'	
	}
}
gen post = year>=2001
foreach x in s u us {
	gen `x'_after       = `x'*post
	gen `x'_f_after     = `x'_f*post
}
gen f_after = f*post
xi i.countrycode, noomit
drop if s6==.
save interim/xchn_02_simple_o1_s4, replace 


*2.2.5 collapse by 1 ownership types and 1 shipment types  
use interim/xchn_01, clear
keep if ownership==1 | ownership==2 | ownership==4 | ownership>=5
keep if shipment==10 | shipment==14 | shipment==15
gen o=1
replace shipment=99
egen n  = tag(party_id o shipment hs6s country year)
collapse (sum) value n (mean) s6_1999, by(o shipment hs6s year countrycode) fast
foreach x in value n {
	gen l`x' = ln(`x')
}
gen f    = o==1
gen u    = countrycode==9000
gen s    = s6_1999
gen us   = u*s6_1999
foreach x in u s us {
	gen `x'_f    = `x'*f
}	
forvalues y=2001(1)2005 {
	gen y`y'   = year==`y'
	gen sy`y'  = s*y`y'
	gen uy`y'  = u*y`y'
	gen usy`y' = u*s*(year==`y')	
	foreach x in f {
		gen sy`y'_`x'  = s*y`y'*`x'
		gen uy`y'_`x'  = u*y`y'*`x'
		gen usy`y'_`x' = u*s*(year==`y')*`x'	
	}
}
gen post = year>=2001
foreach x in s u us {
	gen `x'_after       = `x'*post
	gen `x'_f_after     = `x'_f*post
}
gen f_after = f*post
xi i.countrycode, noomit
drop if s6==.
save interim/xchn_02_simple_o1_s1, replace 


*2.2.6 collapse by 1 ownership types and 2 shipment types  
use interim/xchn_01, clear
gen o=1
keep if ownership==1 | ownership==2 | ownership==4 | ownership>=5
keep if shipment==10 | shipment==14 | shipment==15
replace shipment=99 if shipment==14 | shipment==15
save temp1, replace

use temp1, clear
drop if shipment==10
replace shipment=99
save temp2, replace

use temp1, clear
append using temp2
egen n  = tag(party_id o shipment hs6s country year)
collapse (sum) value n (mean) s6_1999, by(o shipment hs6s year countrycode) fast
foreach x in value n {
	gen l`x' = ln(`x')
}
gen f    = o==1
gen u    = countrycode==9000
gen s    = s6_1999
gen us   = u*s6_1999
foreach x in u s us {
	gen `x'_f    = `x'*f
}	
forvalues y=2001(1)2005 {
	gen y`y'   = year==`y'
	gen sy`y'  = s*y`y'
	gen uy`y'  = u*y`y'
	gen usy`y' = u*s*(year==`y')	
	foreach x in f {
		gen sy`y'_`x'  = s*y`y'*`x'
		gen uy`y'_`x'  = u*y`y'*`x'
		gen usy`y'_`x' = u*s*(year==`y')*`x'	
	}
}
gen post = year>=2001
foreach x in s u us {
	gen `x'_after       = `x'*post
	gen `x'_f_after     = `x'_f*post
}
gen f_after = f*post
xi i.countrycode, noomit
drop if s6==.
save interim/xchn_02_simple_o1_s2, replace 






*3 regs using hsdfe (https://github.com/sergiocorreia/reghdfe)
*  (https://ideas.repec.org/c/boc/bocode/s457874.html)

use interim/xchn_02_simple_o1_s1, clear
egen hs6=group(hs6s)
quietly reg lvalue y????
drop if e(sample)==0
drop _Ic* y200?* sy200?* uy200?* usy200?* y200?*
egen cp = group(countrycode hs6s)
egen yp = group(year        hs6s)
egen cy = group(countrycode year)
save interim/xchn_02_simple_o1_s1_hsdfe, replace

use interim/xchn_02_simple_o1_s2, clear
egen hs6=group(hs6s)
quietly reg lvalue y????
drop if e(sample)==0
drop _Ic* y200?* sy200?* uy200?* usy200?* y200?*
egen cp = group(countrycode hs6s)
egen yp = group(year        hs6s)
egen cy = group(countrycode year)
save interim/xchn_02_simple_o1_s2_hsdfe, replace

use interim/xchn_02_simple_o3_s1, clear
egen hs6=group(hs6s)
quietly reg lvalue y????
drop if e(sample)==0
drop _Ic* y200?* sy200?* uy200?* usy200?* y200?*
egen cp = group(countrycode hs6s)
egen yp = group(year        hs6s)
egen cy = group(countrycode year)
save interim/xchn_02_simple_o3_s1_hsdfe, replace




*4 run regressions

*4.1 (o1 s1)
use interim/xchn_02_simple_o1_s1_hsdfe, clear
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
*outreg2 us_after u s us s_after u_after using ehr1c1.txt, replace noaster noparen 
outreg2 us_after using e.txt, replace noaster noparen 

*4.2 (o1 s2)
use interim/xchn_02_simple_o1_s2_hsdfe, clear
keep if shipment_id==10
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o1_s2_hsdfe, clear
keep if shipment_id==99
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

*4.3 (o3 s1)
use interim/xchn_02_simple_o3_s1_hsdfe, clear
keep if o==1
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s1_hsdfe, clear
keep if o==2
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s1_hsdfe, clear
keep if o==3
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 


*4.4 (o3,s2)
use interim/xchn_02_simple_o3_s2_hsdfe, clear
keep if o==1 & shipment_id==10
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s2_hsdfe, clear
keep if o==1 & shipment_id==99
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s2_hsdfe, clear
keep if o==2 & shipment_id==10
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s2_hsdfe, clear
keep if o==2 & shipment_id==99
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s2_hsdfe, clear
keep if o==3 & shipment_id==10
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 

use interim/xchn_02_simple_o3_s2_hsdfe, clear
keep if o==3 & shipment_id==99
reghdfe lvalue us_after u s us s_after u_after, absorb(cp yp cy) vce(cluster cp) fast v(1) dropsi
outreg2 us_after using e.txt, append noaster noparen 








