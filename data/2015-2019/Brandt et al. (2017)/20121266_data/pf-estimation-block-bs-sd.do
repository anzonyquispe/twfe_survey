
*****************************************
*data for production function estimation*
*****************************************
local usedata=".../firm-level5.dta"
local industrydata=".../industry-level-1995-2007-lag.dta"

local newoutputd="alternative output deflators 101216.dta"
local newinputd="alternative io input deflators 101216.dta"

local savepath="..."

****************
*temp files*
****************
local estsample:tempfile
local tempapp:tempfile

*********************
*bootstrapping setup*
*********************
local B=100

*************************************************************************************
******************
*Data Preparation*
******************
use "`usedata'", clear
merge m:1 year cic_adj using "`industrydata'"
tab _merge
drop if _merge==2
drop _merge

drop if wage==0 | employment==0 

*************
* Variables *
*************
gen inputr =input /deflator_input_4d
gen outputr=output/deflator_output_4d
gen var    =output/deflator_output_4d - inputr
egen wagebill =rsum(wage nonwage)
gen wagebillr=wagebill/deflator_output_4d

for any q y k l m  \ var outputr var real_cap `labormeasure' inputr : gen  X=log(Y)

gen expdummy = (export>0 & export~=.)
keep firm year q y k l m cic_adj expdummy ownership province wagebillr inputr input tariff* employment var outputr output deflator_*put_4d
sort firm year
duplicates drop firm year,force

for var q l k m: bysort firm (year): gen X_lag = X[_n-1]
for var l k m l_lag k_lag m_lag: gen X2=X^2
for any m l m_lag l_lag: gen Xk=X*k
for any m l m_lag l_lag: gen Xk_lag=X*k_lag
for any m m_lag \ any l l_lag: gen XY=X*Y
gen mlk=l*m*k
gen m_lagl_lagk_lag=m_lag*l_lag*k_lag
gen m_lagl_lagk=m_lag*l_lag*k

quietly forvalues ll = 0/3 {
	local kmax = 3 - `ll'
	forvalues kk = 0/`kmax' {
		local mmax = 3 - `ll' - `kk'
		forvalues mm = 0/`mmax' {
			gen NON`ll'`kk'`mm'=(l^`ll')*(k^`kk')*(m^`mm')
			gen EXP`ll'`kk'`mm'=(l^`ll')*(k^`kk')*(m^`mm')*expdummy

			gen OUTPUTTARIFF`ll'`kk'`mm'=(l^`ll')*(k^`kk')*(m^`mm')*tariff_output_l1
			gen INPUTTARIFF`ll'`kk'`mm'=(l^`ll')*(k^`kk')*(m^`mm')*tariff_input_l1

		}
	}
}	

**********
* Sample *
**********
gen missing=y+k+l+m
bysort firm (year): gen missing_lag=missing[_n-1]

gen cic2=floor(cic_adj/100)
egen gcic2 =group(cic2)
egen gcic4=group(cic_adj)
egen SDcic=sd(cic2), by(firm)

drop if missing==. | (missing_lag==. & year~=1998)
*just to exclude partial year observation; keep all 1998 observations though; still useful in the first stage
drop if SDcic~=0

drop missing missing_lag SDcic

tsset firm year
save `estsample'
*************************
*End of Data Preparation*
*************************
*/

* Estimate production functiosn by sectors

sum gcic2

forvalues cc = 1/`r(max)' {  

	use `estsample', clear

	keep if gcic2==`cc'
	matrix beta$version`cc'=J(`B',4,0)
	
	forval b=1/`B' {
		*BS
		preserve
		
			bsample,cluster(firm)
	
			capture xi: areg q NON* EXP* OUTPUTTARIFF* INPUTTARIFF* i.ownership i.year i.province,absorb(cic_adj)
			if _rc==2001 continue
			qui predict phi
			qui gsort firm + year
			
			bysort firm: gen phi_lag=L.phi
			qui drop _I*
			qui gen const=1
			for var q l_lag k phi phi_lag: qui drop if X==.
	
			*OLS
			qui xi: regress q m l k i.cic_adj i.ownership i.year i.province
			for any m l k : qui gen OLSX=_b[X]
			qui gen OLSConst=_b[_c]	
	
			*Initial values for GMM
			for any m l k : qui gen initialX=OLSX
			qui gen initialConst=OLSConst	
	
			qui `specification'
			for num 1/4: matrix beta$version`cc'[`b',X]=beta_`specification'[1,X]	
	
		*BS
		restore
	}
}

forval cc=1(1)29 {
	clear
	set obs `B'
	for any 0 m l k  \ num 1/4: gen CDX=beta$version`cc'[1,Y]
	forval n=2(1)`B' {
		for any 0 m l k \ num 1/4: qui replace CDX=beta$version`cc'[`n',Y] in `n'
	}
	gen cc=`cc'
	if `cc'~=1 append using `tempapp'
	save `tempapp',replace
}

save "`savepath'/pfcoef_BS.dta"
