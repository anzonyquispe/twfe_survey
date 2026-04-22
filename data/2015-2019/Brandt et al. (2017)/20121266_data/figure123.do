clear
local temp: tempfile
*local tempdir1 = "C:\OFFICE\1. Research\7. Data work\China"
local tempdir1 = "C:\Dropbox\Documents\1. Research\6. Data work\China"

****************************************************
* Figures: measures of protection *
****************************************************
use "`tempdir1'\data_industry\tariff\tariffs-by-year-cic_adj.dta", clear
save `temp', replace
	* add 1995
	keep if year==1994|year==1996
	collapse (mean) tariff_input tariff_output, by(cic_adj)
	gen year=1995
	append using `temp'
sort cic_adj year
save `temp', replace

use "`tempdir1'\data_industry\FDI\fdi", clear
drop if cic_adj==4310
sort  cic_adj year
merge cic_adj year using `temp'
drop _merge
for var fdi_prohibited fdi_restricted: bysort cic_adj (year): replace X=X[_n-1] if X==.
sort cic_adj year
save `temp', replace

use "`tempdir1'\data_industry\NTB\ntb", clear
sort  cic_adj year
merge cic_adj year using `temp'
drop _merge

* any_tariff cutoff?:
* 10% =11th percentile in 1992
*     =18th percentile in 1995
*     =50th percentile in 1992-1997
egen any_fdi = rmax(fdi_prohibited fdi_restricted)
gen  any_tar = (tariff_output>15 & tariff_output~=.)
* any_ntb already defined -- ratio of ntb_hs8/total_hs8 declines from 5.471% to 0.042%
sort  cic_adj year
save `temp', replace


****************************************************
* Figure 2: different measures of protection *
****************************************************
for var any*: egen MX=mean(X), by(year)
table year if year>=1995 & year<=2007, c(mean Many_fdi mean Many_ntb mean Many_tar) f(%5.3f)
*copied in excel and made figure there
*bar chart in Stata only seems to work for 1 y-series
*twoway bar Many_fdi Many_ntb Many_tar year if year>=1995 & year<=2007 & cic_adj==1310

preserve
keep year cic_adj tariff* max*
sort year cic_adj
save `temp', replace
restore


******************************
* figure 1: tariff evolution *
******************************
use "`tempdir1'\industry-level-1995-2007.dta", clear
keep year cic_adj input output
sort year cic_adj
merge year cic_adj using `temp'

gen ms = input/output
egen CIC_ADJ=group(cic_adj)
quietly for num 1/424: impute ms year if CIC_ADJ==X&year>=1995&year<=1999, gen(msX) 
quietly for num 1/424: replace ms=msX if ms==. & CIC_ADJ==X
drop ms1-ms424 
gen erp=(tariff_output - ms*tariff_input)/(1-ms)
drop input ms

replace maxtariff_o = tariff_output if maxtariff_o==.
replace maxtariff_i = tariff_input  if maxtariff_i==.

gen y=log(output)
quietly for num 1/424: impute y year if CIC_ADJ==X&year>=1994&year<=2007, gen(outputX) 
quietly for num 1/424: replace output=exp(outputX) if output==. & CIC_ADJ==X
drop y output1-output424 CIC_ADJ
for any output input: bysort year (tariff_X   ): gen TX =sum(output)
for any o      i    : bysort year (maxtariff_X): gen TMX=sum(output)
                      bysort year (erp        ): gen Te =sum(output)
egen TOToutput=max(Toutput), by(year)
for any output input: gen  SHX =TX /TOToutput
for any o      i    : gen  SHMX=TMX/TOToutput
                      gen  SHe =Te /TOToutput

for any o i \ any output input: bysort year (   tariff_Y): gen Q25X  =tariff_Y    if SHY >=0.25 & SHY[_n-1] <0.25
for any o i \ any output input: bysort year (   tariff_Y): gen Q50X  =tariff_Y    if SHY >=0.50 & SHY[_n-1] <0.50
for any o i                   : bysort year (maxtariff_X): gen QM50X =maxtariff_X if SHMX>=0.50 & SHMX[_n-1]<0.50
for any o i \ any output input: bysort year (   tariff_Y): gen Q75X  =tariff_Y    if SHY >=0.75 & SHY[_n-1] <0.75
                                bysort year (   erp     ): gen Q50e  =erp         if SHe >=0.50 & SHe[_n-1] <0.50
label var Q50o  "Output tariff (median)"
label var QM50o "Max output tariff (median)"
label var Q50i  "Input tariff (median)"
label var Q50e  "Effective rate of protection"
egen MQ75o=mean(Q75o), by(year)

twoway (rarea Q25o MQ75o year if year>=1994 & year<=2007, fcolor(gs14) lcolor(gs14) xlabel(1995 1997 1999 2001 2003 2005 2007) scheme(s1color)) (line Q50o QM50o Q25i Q75i Q50i year if year>=1994 & year<=2007, lpattern(solid dot dash dash solid) lcolor(gs10 gs10 gs0 gs0 gs0) lwidth(thick medthick medium medium medium)), legend(label(1 "Output tariff (IQ range)") label(2 "Output tariff (Median)") label(3 "Max output tariff (Med)") label(4 "Input tariff  (IQ range)") label(6 "Input tariff  (Median)") order(2 6 1 4 3))


*****************************
* figure 3: exogeneity      *
*****************************
keep year cic_adj tariff_output*
reshape wide tariff_output, i(cic_adj) j(year)
gen degree45=tariff_output1992
gen dtariff_output_0792 = tariff_output2007 - tariff_output1992
gen dtariff_output_0701 = tariff_output2007 - tariff_output2001
regress dtariff_output_0792 tariff_output1992 if tariff_output1992<140
predict Pdt1
regress dtariff_output_0701 tariff_output2001 if tariff_output2001<140
predict Pdt1b
gen Pdt2 = 10 - tariff_output1992
gen Pdt2b= 10 - tariff_output2001
twoway (scatter dtariff_output_0792 tariff_output1992 if tariff_output1992<=140, mcolor(navy)) (line Pdt1  Pdt2  tariff_output1992 if tariff_output1992<=140, sort lpattern(solid dash) lcolor(navy black)), xlabel(0(20)140) ylabel(-120(20)20) legend(off) xtitle("1992 import tariff", margin(medsmall) size(medlarge)) ytitle("Import tariff change: 1992-2007", margin(medsmall) size(medlarge)) name(fullsample, replace) scheme(s1color)
twoway (scatter dtariff_output_0701 tariff_output2001 if tariff_output2001<=140, mcolor(navy)) (line Pdt1b Pdt2b tariff_output2001 if tariff_output2001<=140, sort lpattern(solid dash) lcolor(navy black)), xlabel(0(20)60)  ylabel(-50 (20)20) legend(off) xtitle("2001 import tariff", margin(medsmall) size(medlarge)) ytitle("Import tariff change: 2001-2007", margin(medsmall) size(medlarge)) name(postWTO, replace) scheme(s1color)
graph combine fullsample postWTO, col(1) xsize(3.5) note("Notes: Observations are 4-digit manufacturing sectors. Dashed line has slope -1." "           Solid line is regression with slope -0.84 above, and -0.46 below.", size(small)) scheme(s1color)

*final version
graph combine fullsample postWTO, col(1) xsize(3.5) scheme(s1color)
