/** figure3.do

**/


clear
set mem 500m
set trace off
set more off
set linesize 255
capture log close
log using figure3.log, replace

* set the data to be used
local data = "../data/dis70panx.dta"

use `data', clear

keep if major==1
replace imp = imp + 1900

*** Create Treatment Variables
gen imp_post    = (year >= imp)
gen impost_4    = (year >=  imp + 4)

*** Create Dependent Variables
for any 04 59 1014 1519 2024  2529  3034  3539  4044  4549  5054  5559  6064  6569  7074  75up: gen lnpopXw = ln(popXw)
for any 04 59 1014 1519 2024  2529  3034  3539  4044  4549  5054  5559  6064  6569  7074  75up: gen lnpopXb = ln(popXb)

matrix whites = J(16,2,0)
matrix blacks = J(16,2,0)
matrix whitess = J(16,2,0)
matrix blackss = J(16,2,0)
matrix whitesn = J(16,2,0)
matrix blacksn = J(16,2,0)

capture program drop runregs
program define runregs

xi: xtreg lnpop`1'w imp_post i.year*i.south, fe i(leaid) cluster(leaid)
matrix whites[`2',1] = _b[imp_post]
matrix whites[`2',2] = _se[imp_post]
xi: xtreg lnpop`1'b impost_4 i.year*i.south, fe i(leaid) cluster(leaid)
matrix blacks[`2',1] = _b[impost_4]
matrix blacks[`2',2] = _se[impost_4]
xi: xtreg lnpop`1'w imp_post i.year if south==1, fe i(leaid) cluster(leaid)
matrix whitess[`2',1] = _b[imp_post]
matrix whitess[`2',2] = _se[imp_post]
xi: xtreg lnpop`1'b impost_4 i.year if south==1, fe i(leaid) cluster(leaid)
matrix blackss[`2',1] = _b[impost_4]
matrix blackss[`2',2] = _se[impost_4]
xi: xtreg lnpop`1'w imp_post i.year if south==0, fe i(leaid) cluster(leaid)
matrix whitesn[`2',1] = _b[imp_post]
matrix whitesn[`2',2] = _se[imp_post]
xi: xtreg lnpop`1'b impost_4 i.year if south==0, fe i(leaid) cluster(leaid)
matrix blacksn[`2',1] = _b[impost_4]
matrix blacksn[`2',2] = _se[impost_4]

end

runregs 04 1
runregs 59 2
runregs 1014 3
runregs 1519 4
runregs 2024 5
runregs 2529 6
runregs 3034 7
runregs 3539 8
runregs 4044 9
runregs 4549 10
runregs 5054 11
runregs 5559 12
runregs 6064 13
runregs 6569 14
runregs 7074 15
runregs 75up 16

matrix list whites
matrix list blacks
matrix list whitess
matrix list blackss
matrix list whitesn
matrix list blacksn

log close

