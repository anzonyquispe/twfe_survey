clear
set more off

use temp, clear
keep  firm year cic_adj outputr tfp
sort  firm year
merge firm year using restructured
drop _merge
quietly for var firm year cic_adj outputr: drop if X==.
reshape wide cic_adj outputr tfp restructuring, i(firm) j(year)
reshape long cic_adj outputr tfp restructuring, i(firm) j(year)

bysort firm (year): gen sampleentry=(outputr~=.) & outputr[_n-1]==.
egen test=sum(sampleentry), by(firm)

egen minyear=min(year) if outputr~=., by(firm)
egen maxyear=max(year) if outputr~=., by(firm)
gen entry=1 if year==minyear & minyear>1998
gen exit =1 if year==maxyear & maxyear<2007

by firm: ipolate outputr year, gen(Poutputr)
drop if Poutputr==.
by firm: ipolate cic_adj year, gen(Pcic_adj)

bysort firm (year): replace cic_adj=Pcic_adj if cic_adj==. & Pcic_adj==cic_adj[_n-1] & Pcic_adj==cic_adj[_n+1]
egen SDcic_adj=sd(cic_adj), by(firm)
replace cic_adj=Pcic_adj if SDcic_adj==0 & cic_adj==.

by firm (year): gen switchin =1 if entry~=1 & cic_adj~=cic_adj[_n-1] & cic_adj~=. & year~=1998
by firm (year): gen switchout=1 if exit~ =1 & cic_adj~=cic_adj[_n+1] & cic_adj~=. & year~=2007

                    gen active   =1 if Poutputr~=.
bysort firm (year): gen incumbent=1 if Poutputr~=. & Poutputr[_n-1]~=. & switchin ~=1
bysort firm (year): gen survivor =1 if Poutputr~=. & Poutputr[_n+1]~=. & switchout~=1
for var active incumbent survivor: replace X=. if cic_adj==.
drop if cic_adj==.

collapse (sum) active incumbent survivor entry exit switchin switchout restructuring, by(cic_adj year)

sort  cic_adj year
merge cic_adj year using protection-measures
for var tariff* maxtariff*: replace X=X/100
for var tariff* maxtariff*: bysort cic_adj (year): gen LX=X[_n-1]
drop if _merge==2
drop    _merge
drop fdi* ntb* any* lin* total

tabulate year, gen(YY)

gen R1active=log(active)/10
gen R2active=R1active
for var entry exit switchin switchout restructuring: gen R1X=X/active
for var entry      switchin                        : gen R2X=X/incumbent
for var       exit          switchout restructuring: gen R2X=X/survivor
 
for var R1*: xtivreg X (Ltariff_output = Lmaxtariff_o) Ltariff_input YY* if X<1, i(cic_adj) fe \ estimates store X
for var R2*: xtivreg X (Ltariff_output = Lmaxtariff_o) Ltariff_input YY* if X<1, i(cic_adj) fe \ estimates store X
for var R1*: xtivreg X ( tariff_output =  maxtariff_o)  tariff_input YY* if X<1, i(cic_adj) fe \ estimates store CX
for var R1*: xtreg   X  Ltariff_output                 Ltariff_input YY* if X<1, i(cic_adj) fe \ estimates store OX
for var R1*: xtivreg X (Ltariff_output = Lmaxtariff_o) Ltariff_input YY* if X<1 & year>=2001, i(cic_adj) fe \ estimates store PX

estimates table R1active R1entry R1exit R1switchin R1switchout R1restructuring, keep(Ltariff_o Ltariff_i) b(%5.3f) se(%5.3f) stats(N r2)
estimates table R2active R2entry R2exit R2switchin R2switchout R2restructuring, keep(Ltariff_o Ltariff_i) b(%5.3f) se(%5.3f) stats(N r2)
estimates table CR1active CR1entry CR1exit CR1switchin CR1switchout CR1restructuring, keep( tariff_o  tariff_i) b(%5.3f) se(%5.3f) stats(N r2)
estimates table OR1active OR1entry OR1exit OR1switchin OR1switchout OR1restructuring, keep(Ltariff_o Ltariff_i) b(%5.3f) se(%5.3f) stats(N r2)
estimates table PR1active PR1entry PR1exit PR1switchin PR1switchout PR1restructuring, keep(Ltariff_o Ltariff_i) b(%5.3f) se(%5.3f) stats(N r2)

