clear
clear mata
clear matrix
set mem 800m

****this program creates adj_price.dta
****it is used as an inflator for the initial value of real estate assets
***it uses the state level real estate price index until 1975
*** and then the CPI
use "../output/base_demo",replace
keep index_state state year
gen price_93=index_state if year==1993
egen PRICE_93=max(price_93),by(state)
***price are Normalized to 1 in 1993
gen index_norm=index_state/PRICE_93
duplicates drop state year, force
sort state year
save "../output/temp",replace

***us_cpi_adj is the yearly inflation rate from the U.S. Department Of Labor Bureau of Labor Statistics
insheet using "../data/us_cpi_adj.txt", names tab clear
expand 51 
sort year
by year: gen state=_n
replace state=53 if state==3
replace state=54 if state==7
replace state=55 if state==14
replace state=56 if state==43

sort state year
merge 1:1 state year using "../output/temp"

sort state year
replace index_norm=index_norm[_n+1]*growth[_n+1] if year==1974&state[_n+1]==state

forvalues i=1(1)48{
local j=1974-`i'
replace index_norm=index_norm[_n+1]*growth[_n+1] if year==`j'&state[_n+1]==state
}

ren index_norm adj93
ren year yearbuy
keep state yearbuy adj93
sort state yearbuy
save "../output/adj_price",replace 
