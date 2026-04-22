clear
clear matrix
set more off
local datadir1 = "C:\Dropbox\Documents\1. Research\7. Data work\China"
local datadir2 = "C:\Dropbox\Shared\WTO\Luhang\to Jo\2014-April"
local datadir3 = "C:\Dropbox\Shared\WTO\pf estimation CD"

local temp: tempfile
 
***************************
* get protection measures *
***************************
use "../analysis-2014/protection-measures", clear
keep    tariff_* maxtariff_* cic_adj year
for var tariff_* maxtariff_*: replace X=X/100
for var tariff_* maxtariff_*: bysort cic_adj (year): gen lX=X[_n-1]
replace maxtariff_o = tariff_output if maxtariff_o==.  /* 10 obs. in 2007 */
keep if year>=1998 & year<=2007
rename ltariff_output ltar_o
rename ltariff_input  ltar_i
rename lmaxtariff_o   lmaxt_o
rename lmaxtariff_i   lmaxt_i
sort cic_adj year 
save `temp', replace

*****************
* get imt dummy *
*****************
use "../analysis-2014/cicadj_BEC&FTC", clear
egen maxcat = rmax(pbec_imt pbec_cap pbec_cmp)
gen imt= pbec_imt==maxcat
gen cap= pbec_cap==maxcat
* 3724 (mini-cars) 3762 (ships) imt==cap, better classify as cap
replace cap=0 if imt==1
for any 3724 3762: replace imt=0 if cic_adj==X
keep cic_adj imt cap
sort cic_adj
merge cic_adj using `temp'
drop if _m==1
drop _merge
sort cic_adj 
save `temp', replace

*****************
* get PF coef.  *
*****************
use "Luhang-5estimates\betaALL5versions.dta", clear
keep cic_adj beta*
sort cic_adj
merge cic_adj using `temp'
drop if _merge==2
drop _merge
sort cic_adj year
save `temp', replace


*********************
* get new deflators *
*********************
* new deflators 
use "alternative output deflators, 101216.dta"
merge cic_adj using "alternative io input deflators, 101216.dta"
reshape long input_d output_d, i(cic_adj) j(year)
rename  input_d deflator_input_new
rename output_d deflator_output_new
for var deflator*: egen MX=mean(X) if cic_adj==2010|cic_adj==2011|cic_adj==2012, by(year)
for var deflator*: replace X=MX if X==.
replace deflator_output=deflator_input if deflator_output==. & cic_adj==3352 /* 1 change */
replace deflator_output=deflator_input if deflator_output==0 & cic_adj==3352 /* 6 change */
drop if cic_adj==.
drop M* _merge
sort cic_adj year
merge cic_adj year using `temp'
drop if _merge==1
drop _merge
sort cic_adj year
save `temp', replace


***********************
* get firm-level data *
***********************
use "`datadir2'\firm-level5.dta", clear
egen wagebill =rsum(wage nonwage)
keep firm year cic_adj input output employment real_cap wagebill bdat export ownership province deflator*

rename ownership ownership_old
sort  firm year
merge firm year using ../analysis-2015/ownership.dta
drop if _merge==1 
drop if _merge==2 
drop _merge
sort firm year

keep firm year cic_adj input output employment real_cap wagebill bdat export ownership province deflator*

******************************************
* merge with imt-dummy/tariffs/deflators *
******************************************
sort  cic_adj year
merge cic_adj year using `temp'
drop if _merge==2  
drop    _merge

* calculations *
for var output input: gen Xr =X/deflator_X_4d
for var output input: gen Xr2=X/deflator_X_new

for var outputr outputr2 employment real_cap inputr inputr2 \ any q q2 l k m m2: gen Y=log(X)

gen expdummy = (export>0 & export~=.)
gen  cic2=floor(cic_adj/100)
egen CIC =group(cic2)
drop if CIC==30  /* no tariffs */


*************************
* calculate phi for all *
*************************
* eliminated interaction with investment
quietly forvalues ll = 0/4 {
	local kmax = 4 - `ll'
	forvalues kk = 0/`kmax' {
		local mmax = 4 - `ll' - `kk'
		forvalues mm = 0/`mmax' {
			gen NON`ll'`kk'`mm'`ii'=(l^`ll')*(k^`kk')*(m^`mm')
			gen EXP`ll'`kk'`mm'`ii'=(l^`ll')*(k^`kk')*(m^`mm')*expdummy
			gen OUTPUTTARIFF`ll'`kk'`mm'`ii'=(l^`ll')*(k^`kk')*(m^`mm')*ltar_o
			gen INPUTTARIFF`ll'`kk'`mm'`ii' =(l^`ll')*(k^`kk')*(m^`mm')*ltar_i
		}
	}	
}
local temp2: tempfile
save `temp2', replace

clear
gen year=.
local phifile: tempfile
save `phifile', replace


forvalues cc = 1/29 {
	use `temp2', clear
	keep if CIC==`cc'
	quietly xi: areg q NON* EXP* OUTPUTTARIFF* INPUTTARIFF* i.ownership i.year i.province,absorb(cic_adj)
	predict phi2
	keep firm year phi2
	append using `phifile'
	sort firm year
	save `phifile', replace
	}

**********************************
* calculate tfp & markup for all *
**********************************
use `temp2', clear
sort  firm year
merge firm year using `phifile'

for var beta*:   egen MX        =mean(X)       , by(cic2)
for any c l k m: egen M4beta_X_D=mean(beta_X_D), by(cic_adj)
gen w=log(wagebill/deflator_output_4d)
for any A: gen tfpX = q  - Mbeta_c_X  -  Mbeta_m_X*m   - Mbeta_l_X*l  - Mbeta_k_X*k
for any B: gen tfpX = q  - Mbeta_c_X  -  Mbeta_m_X*m   - Mbeta_l_X*w  - Mbeta_k_X*k
for any C: gen tfpX = q2 - Mbeta_c_X  -  Mbeta_m_X*m2  - Mbeta_l_X*l  - Mbeta_k_X*k
for any D: gen tfpX = q  - M4beta_c_X -  M4beta_m_X*m  - M4beta_l_X*l - M4beta_k_X*k
for any E: gen tfpX = q  - Mbeta_c_X                   - Mbeta_l_X*l  - Mbeta_k_X*k

gen     ms1=(input/exp(phi2))*(outputr/output)
gen     ms2=(input/output)
gen     ws =(wagebill /exp(phi2))*(outputr/output)
replace ws =(wagebill /output) if ws==.
for var ms1 ms2 ws: replace X=1 if X>1
gen mum1 = log(Mbeta_m_A/ms1)
gen mum2 = log(Mbeta_m_A/ms2)
gen mul  = log(Mbeta_l_A/ws)

for var tfp* mum*: egen P1X =pctile(X), by(cic2 year) p(1)
for var tfp* mum*: egen P99X=pctile(X), by(cic2 year) p(99)
drop P1tfpD P99tfpD
for any 1 99:      egen PXtfpD=pctile(tfpD), by(cic_adj year) p(X)
for var tfp* mum*: replace X=. if X<P1X | X>P99X
keep firm year cic_adj cic2 tfp* mum1 mum2 phi ownership bdat outputr employment deflator_output_4d deflator_input_4d export province ltar_* lmaxt_* imt tariff* maxtariff*


* tfp level not comparable if firm switches 2-digit sector
egen      sdcic2=sd(cic2), by(firm)
drop if   sdcic2~=0
drop sdcic2

save firm-level-ready, replace


use firm-level-ready, clear

tabulate year, gen(YY)
egen ccyy  =group(cic_adj year)
egen sdcic4=sd(cic_adj), by(firm)
egen sdcic2=sd(cic2), by(firm)
keep if sdcic4==0
*keep if sdcic2==0

	for var export employment outputr: egen TX=sum(X), by(cic_adj year)
	for var export employment outputr \ any x l y: gen logY=log(TX)
	egen T1output=sum(outputr*(ownership==1)), by(cic_adj year)
	egen T3output=sum(outputr*(ownership==3)), by(cic_adj year)
	gen SOEshare=T1output/Toutput
	gen PRIshare=T3output/Toutput
	gen  share   =outputr/Toutputr


* first stage regression (reported in Table 1)
egen tt=tag(cic_adj year)
areg tariff_o maxtariff_o logy logl logx SOE PRI YY* if tt&year>=2002&year<=2007, absorb(cic_adj) 

for var tfp* mum1 ltar_* lmaxt_* YY* logy logl logx SOE PRI share outputr: egen MX=mean(X), by(firm)
for var tfp* mum1 ltar_* lmaxt_* YY* logy logl logx SOE PRI:  gen DX=X-MX


***************
** Table 3   **
***************
replace ccyy = cic_adj
*IV
* industry-year clustering
for var tfpA mum1:     ivregress 2sls DX (Dltar_* = Dlmaxt_*) DYY* Dlogy Dlogl Dlogx DSOE DPRI                 , cluster(ccyy) \ estimates store IV1_X
for var tfpA mum1: xi: ivregress 2sls DX (Dltar_* = Dlmaxt_*) i.cic2*i.year                                    , cluster(ccyy) \ estimates store FE1_X
for var tfpA mum1:     ivregress 2sls DX (Dltar_* = Dlmaxt_*) DYY* Dlogy Dlogl Dlogx DSOE DPRI [weight=share]  , cluster(ccyy) \ estimates store IV2_X
for var tfpA mum1: xi: ivregress 2sls DX (Dltar_* = Dlmaxt_*) i.cic2*i.year                    [weight=share]  , cluster(ccyy) \ estimates store FE2_X
for var tfpA mum1:     ivregress 2sls DX (Dltar_* = Dlmaxt_*) DYY* Dlogy Dlogl Dlogx DSOE DPRI [weight=outputr], cluster(ccyy) \ estimates store IV3_X
for var tfpA mum1: xi: ivregress 2sls DX (Dltar_* = Dlmaxt_*) i.cic2*i.year                    [weight=outputr], cluster(ccyy) \ estimates store FE3_X
for var mum1 tfpA:  estimates table IV1_X FE1_X IV2_X FE2_X IV3_X FE3_X, keep( Dltar_o  Dltar_i) b(%5.3f) star(.01 .05 .1) stats(N r2)
for var mum1 tfpA:  estimates table IV2_X FE1_X IV2_X FE2_X IV3_X FE3_X, keep( Dltar_o  Dltar_i) b(%5.3f) se(%5.3f)        stats(N r2)

* use ivreg2: two-way clustering (slow)
for var tfpA mum1: ivreg2 DX (Dltar_* = Dlmaxt_*) DYY* Dlogy Dlogl Dlogx DSOE DPRI                 , cluster(firm ccyy) \ estimates store PIV1_X
for var tfpA mum1: xi: ivreg2 DX (Dltar_* = Dlmaxt_*) i.cic2*i.year                                , cluster(firm ccyy) \ estimates store PFE1_X
for var tfpA mum1: ivreg2 DX (Dltar_* = Dlmaxt_*) DYY* Dlogy Dlogl Dlogx DSOE DPRI [weight=share]  , cluster(firm ccyy) \ estimates store PIV2_X
for var tfpA mum1: xi: ivreg2 DX (Dltar_* = Dlmaxt_*) i.cic2*i.year                [weight=share]  , cluster(firm ccyy) \ estimates store PFE2_X
for var tfpA mum1: ivreg2 DX (Dltar_* = Dlmaxt_*) DYY* Dlogy Dlogl Dlogx DSOE DPRI [weight=outputr], cluster(firm ccyy) \ estimates store PIV3_X
for var tfpA mum1: xi: ivreg2 DX (Dltar_* = Dlmaxt_*) i.cic2*i.year                [weight=outputr], cluster(firm ccyy) \ estimates store PFE3_X
for var mum1 tfpA: estimates table POLS1_X PIV1_X PFE1_X PIV2_X PFE2_X PIV3_X PFE3_X, keep(Dltar_o Dltar_i) b(%5.3f) se(%5.3f)        stats(N r2)
for var mum1 tfpA: estimates table POLS1_X PIV1_X PFE1_X PIV2_X PFE2_X PIV3_X PFE3_X, keep(Dltar_o Dltar_i) b(%5.3f) star(.01 .05 .1) stats(N r2)


***************
** Table A5   **
***************

* OLS
for var tfpA mum1:     regress DX Dltar_* DYY* Dlogy Dlogl Dlogx DSOE DPRI [weight=share]  , cluster(ccyy) \ estimates store OLS1_X
for var tfpA mum1: xi: regress DX Dltar_* i.cic2*i.year                    [weight=share]  , cluster(ccyy) \ estimates store OLS2_X
for var tfpA mum1:     ivreg2  DX Dltar_* DYY* Dlogy Dlogl Dlogx DSOE DPRI [weight=share]  , cluster(firm ccyy) \ estimates store POLS1_X
for var tfpA mum1: xi: ivreg2  DX Dltar_* i.cic2*i.year                    [weight=share]  , cluster(firm ccyy) \ estimates store POLS2_X
estimates table  OLS1_mum1  OLS2_mum1  OLS1_tfpA  OLS2_tfpA, keep( Dltar_o  Dltar_i) b(%5.3f) star(.01 .05 .1) stats(N r2)
estimates table POLS1_mum1 POLS2_mum1 POLS1_tfpA POLS2_tfpA, keep( Dltar_o  Dltar_i) b(%5.3f) se(%5.3f)        stats(N r2)


* alternative TFP
for any A B C D: xi: ivregress 2sls DtfpX (Dltar_* = Dlmaxt_*) i.cic2*i.year [weight=share], cluster(ccyy)      \ estimates store tfp_X
for any A B C D: xi: ivreg2         DtfpX (Dltar_* = Dlmaxt_*) i.cic2*i.year [weight=share], cluster(firm ccyy) \ estimates store Ptfp_X
estimates table  tfp_A  tfp_B  tfp_C  tfp_D, keep( Dltar_o  Dltar_i) b(%5.3f) star(.01 .05 .1) stats(N r2)
estimates table Ptfp_A Ptfp_B Ptfp_C Ptfp_D, keep( Dltar_o  Dltar_i) b(%5.3f) se(%5.3f)        stats(N r2)



