clear
set more off

/* Annual */

use "$dtapath/Tables/Table3a.dta", clear

 #delimit ;
	sutex year ln_pop ln_emp ln_est payroll sales property corporate_rate d_corp_orig esrate*post d_esrate bus_dom d_bus_dom2 [aw=pop] if year>1979 &year<2011, 
	lab nocheck key(Table3) file(Table3.tex) digits(1) 
 	minmax title("Summary Statistics: 1980-2010") replace; 
 	#delimit cr
 
 

/* Decadal */

use "$dtapath/Tables/Table3b.dta", clear

 #delimit ;
	sutex year dpop dest dadjlwage dadjlrent d_corp_orig d_esrate d_bus_dom2 bartik dtotalexpenditure_pop [aw=epop] if year>1979 &year<2011, 
	lab nobs nocheck key(Table3) file(Table3.tex) digits(1) 
 	minmax title("Summary STatistics: 1980-2010") append; 
 	#delimit cr

