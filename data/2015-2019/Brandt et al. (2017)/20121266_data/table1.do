local datadir1 = "C:\Dropbox\Documents\1. Research\7. Data work\China"
local datadir2 = "C:\Dropbox\Private\New Data\China"
local datadir3 = "C:\Dropbox\Shared\WTO\pf estimation CD"
local temp: tempfile

***************************
* get protection measures *
***************************
use "../analysis-2014/protection-measures", clear
sort cic_adj year
save `temp', replace


*********************
* get sectoral TFP1 *
*********************
use "../analysis-2014/industry-level-1995-2007", clear

gen Routput=output/deflator_output
gen Rinput =input /deflator_input
gen Rva = (va+input)/deflator_output - input/deflator_input
egen MRva=min(Rva), by(cic_adj)
replace Rva=va/deflator_output if MRva<0
for var Rva Routput Rinput employment real_cap \ any v q m l k: gen Y=log(X)
drop Rva Routput Rinput real_cap deflator*

gen ws1=(wage+nonwage)/va     
gen ws2=(wage+nonwage)/output
replace ws1 = ws1 + (1-ws1)/6 /* in between original (30%) and 50% of VA */
gen ms2=input/output
gen vs2=ws2+ms2
for var ws1 vs2: egen P01X=pctile(X), p(1)
for var ws1 vs2: egen P99X=pctile(X), p(99)
for var ws1 vs2: replace X = P01X if X<P01X
for var ws1 vs2: replace X = P99X if X>P99X & X~=.
gen diff2=(ws2+ms2)-vs2
gen wratio2=ws2/(ws2+ms2)
replace ws2=ws2-diff2* wratio2
replace ms2=ms2-diff2*(1-wratio2)
* check whether ks2 is not negative
*gen ks2=1-ws2-ms2
for var ws* ms*: egen MX=mean(X), by(year)
drop wage nonwage va output input vs2 P01* P99* diff2 wratio2

gen tfp1 = q-(ws2+Mws2)/2*l-(1-(ws2+Mws2)/2-(ms2+Mms2)/2)*k - (ms2+Mms2)/2*m
keep  cic_adj year tfp* export
sort  cic_adj year
merge cic_adj year using `temp'
drop if cic_adj==4310
drop _merge
sort cic_adj year 
save `temp', replace


***************************
* aggregate sectoral TFP2 *
***************************
* 1995
use "`datadir2'\1995.dta", clear
keep if type=="10" | revenue>=5000 | output>=5000 
gen CIC=real(cic)
drop cic
rename CIC cic
keep cic employment input output real_cap
gen   year=1995
sort  year cic
merge year cic using "`datadir1'\data_industry\concordance\concordance-by-year"
keep if _merge==3
drop _merge cic
drop if cic_adj==4310
sort year cic_adj
local temp2: tempfile
save `temp2', replace
use "`datadir1'\data_industry\finaldefl\deflators-by-year-cic_adj"
keep if year==1995
keep cic_adj year deflator_input_1d deflator_output_1d
for any input output: rename deflator_X_1d deflator_X
sort  year cic_adj
merge year cic_adj using `temp2'
drop if _merge==1
drop    _merge
gen q = log(output/deflator_output)
gen m = log(input/ deflator_input)
gen k = log(real_cap/103)
gen l = log(employment)
gen outputr=output/deflator_output
drop if l==. | q==. | k==. | m==. | cic_adj==.
keep cic_adj year employment output outputr real_cap l q k m 

* 1998-2008
append using "`datadir3'\firm_level_data-inverseMATERIALS-DLW_CD-laborwagebillr-trimNO.dta"
drop cic2
gen  cic2=floor(cic_adj/100) if year>=1995

drop if firm==. & year>1995
egen    cic2_change=sd(cic2), by(firm)
drop if cic2_change>0&cic2_change~=. & year>1995
drop    cic2_change
drop cic2
gen  cic2=floor(cic_adj/100)

for var beta*: egen MX=mean(X), by(cic2)
gen tfp = q - Mbeta_c -  Mbeta_m*m - Mbeta_l*l - Mbeta_k*k 
for num 1 99: egen PXtfp=pctile(tfp), by(cic2 year) p(X)
drop if tfp<P1tfp | tfp>P99tfp
keep firm year cic_adj tfp output outputr real_cap

drop if tfp==. | output==. | cic_adj==.

egen Toutput=sum(output), by(cic_adj year)
egen tfp2   =sum(output/Toutput*tfp), by(cic_adj year)
for var outputr real_cap: egen TX=sum(X) if year==1995, by(cic_adj year)
bysort cic_adj year (tfp2): keep if _n==1
compress
egen kqr95=mean(Treal_cap/Toutputr), by(cic_adj)
keep  cic_adj year tfp2 kqr95
sort  cic_adj year 
merge cic_adj year using `temp'
* _merge==2: 1992-1997, 2008, 1 obs. in 1999, 14 obs. in 2001
drop _merge
sort cic_adj
save `temp', replace


*****************************
* get explanatory variables *
*****************************
use "`datadir1'\data_industry\characteristics\tariffdeterminants20120313.dta"
keep cic_adj pbec* assets advertising rd klr95 emp95 p93_salesSOE blue element top4_95* prauch_con_n
for var emp95 klr95: replace X=log(X)
for var blue elem:   replace X=X*100
egen TOP4=rmean(top4_95*)
egen pbec_K=rsum(pbec_cap pbec_auto pbec_mat)
egen pbec_C=rsum(pbec_fb pbec_ndconsp pbec_dconsp)
drop top4_95* pbec_cap pbec_auto pbec_mat pbec_fb pbec_ndconsp pbec_dconsp
sort cic_adj
merge cic_adj using `temp'
drop if _merge==1
drop _merge
sort cic_adj year
save "industry-level-ready", replace


*******************************
* table 1: tariff endogeneity *
*******************************
use "industry-level-ready", clear
gen lnkqr95=log(kqr95)
for var tariff_output maxtariff_o: replace X=X/100
tsset cic_adj year
gen  dtar9=tariff_output-L9.tariff_output if year==2007
gen  dtfp9=(L9.tfp2-L12.tfp2)/3           if year==2007
gen  ltfp9=L9.tfp2                        if year==2007
gen  ltar9=L9.tariff_output               if year==2007
gen   dexp9=log(   export/L9.export )/9     if year==2007
gen  ddexp9=log(L9.export/L12.export)/3     if year==2007
gen cic2=floor(cic_adj/100)

gen cic3 = floor(cic_adj/10)
for var assets rd adv: egen MX=mean(X), by(cic3 year)
for var assets rd adv: replace MX=X if X~=.

gen interact = dtfp9 * ltfp9
quietly for var dtar* dtfp* ltfp* dexp* interact ltar9: replace X=X*100

for var ltfp9 dtfp9: egen SDX=sd(X), by(cic2)
for var ltfp9 dtfp9: gen NX=X/SDX
gen Ninteract = Ndtfp9 * Nltfp9

areg dtar9 Nltfp9                  if year==2007, a(cic2)
estimates store col1
areg dtar9        Ndtfp9           if year==2007, a(cic2)
estimates store col2
areg dtar9 Nltfp9 Ndtfp9 Ninteract if year==2007, a(cic2)
estimates store col3
areg dtar9 Nltfp9 Ndtfp9 Ninteract ddexp9 dexp9 if year==2007, a(cic2)
estimates store col4
areg dtar9 Nltfp9 Ndtfp9 Ninteract ddexp9 dexp9 pbec_imt pbec_K pbec_C prauch Massets Mrd Madv TOP4 emp95 lnkqr95 p93_salesSOE elem  if year==2007, a(cic2)
estimates store col5
estimates table col1 col2 col3 col4 col5, drop(_cons) b(%5.3f) se(%5.3f)
estimates table col1 col2 col3 col4 col5, drop(_cons) b(%5.3f) star(.1 .05 .001) stats(N r2)


