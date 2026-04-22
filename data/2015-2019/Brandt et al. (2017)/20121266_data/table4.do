clear
set more off
gen year=.
local temp: tempfile
save `temp', replace

use firm-level-ready, clear
	drop if firm==.
	drop if  tfp==.
	for any output input \ any o i: rename tariff_X tariff_Y


drop tfpB-tfpE
* use either of these statements to generate the two panels with the same program
rename tfpA tfp
*rename mum1 tfp
	
	drop if cic_adj==4124   /* too few obs & 1 year missing */
	drop if cic_adj==4039   /* first 4 years missing */
	local tempmiss: tempfile
	save `tempmiss', replace
	gen missing=.
	for any 2530 2664 3315 3317 3319 3321 3322 3329 3331 3352 3663 3762 4020: replace missing=1 if cic_adj==X
	keep if missing==1 & year==2002
	replace year=year-1
	drop missing
	append using `tempmiss'
	replace maxtariff_o=tariff_o if maxtariff_o==.
	save `tempmiss', replace

forvalues t0 = 1998(3)2001 {
	use `tempmiss', clear
	local t1=`t0'+3
	if `t1'==2004 {
		local t1=2007
		}
	keep if year==`t0'|year==`t1'

	egen    sdcic4=sd(cic_adj), by(firm)
	drop if sdcic4>0&sdcic4~=.

	egen TQ = sum(outputr) if tfp~=., by(year cic_adj)
	gen qshare1=outputr/TQ if tfp~=.
	
	keep firm year qshare1 tfp tariff_* maxtariff_* deflator_output_4d cic_adj TQ
	bysort firm (year): replace cic_adj=cic_adj[_n+1] if cic_adj[_n+1]~=.
	reshape wide   qshare1 tfp tariff_* maxtariff_* deflator_output_4d TQ, i(firm) j(year)

	gen mqshare1=(qshare1`t0'+qshare1`t1')/2
	for any `t0' `t1':egen TtfpX =sum(qshare1X*tfpX), by(cic_adj)
					   gen dtfp  =(Ttfp`t1'-Ttfp`t0')

	egen term1 =sum((            mqshare1       )*(tfp`t1'- tfp`t0')), by(cic_adj)
	egen term2=sum((qshare1`t1'- qshare1`t0'   )*((tfp`t0'+tfp`t1')/2-Ttfp`t0')), by(cic_adj)
	egen term4  =sum( qshare1`t1'*(qshare1`t0'==.)*(tfp`t1'-Ttfp`t0')), by(cic_adj)
	egen term5  =sum(-qshare1`t0'*(qshare1`t1'==.)*(tfp`t0'-Ttfp`t0')), by(cic_adj)
	egen TERM   =rsum(term1 term2 term4 term5)

	egen   N=count(tfp`t1'), by(cic_adj)
	rename TQ`t1' TQ
	for var tariff_* maxtariff_* N TQ deflator_output_4d*: egen MX=mean(X), by(cic_adj)
	gen dtariff_o   =(   Mtariff_o`t1' - Mtariff_o`t0')
	gen dtariff_i   =(   Mtariff_i`t1' - Mtariff_i`t0')
	gen dmaxtariff_o=(Mmaxtariff_o`t1' - Mmaxtariff_o`t0')
	gen dmaxtariff_i=(Mmaxtariff_i`t1' - Mmaxtariff_i`t0')
	gen ddeflator_o =log(Mdeflator_output_4d`t1' / Mdeflator_output_4d`t0')
	
	sort TERM
	bysort cic_adj (dtariff_o): keep if _n==1
	keep   cic_adj term* TERM dtariff_* dmaxtariff* ddeflator_o MTQ MN
	gen year=`t1'
	append using `temp'
	save `temp', replace
}

gen cic2=floor(cic_adj/100)

*use either of these two commands to generate both panels with the same program
*for var TERM term1 term2 term4 term5: xtivreg X (dtariff_o dtariff_i = dmaxtariff_o dmaxtariff_i), i(cic3) fe      \ estimates store IVX
for var TERM term1 term2 term4 term5: ivreg   X (dtariff_o dtariff_i = dmaxtariff_o dmaxtariff_i) [weight=MTQ] \ estimates store IVX
estimates table IVTERM IVterm1 IVterm2 IVterm4 IVterm5, keep(dtariff_o dtariff_i) b(%5.3f) star(.01 .05 .1) stats(N r2)
estimates table IVTERM IVterm1 IVterm2 IVterm4 IVterm5, keep(dtariff_o dtariff_i) b(%5.3f) se(%5.3f) stats(N r2)
