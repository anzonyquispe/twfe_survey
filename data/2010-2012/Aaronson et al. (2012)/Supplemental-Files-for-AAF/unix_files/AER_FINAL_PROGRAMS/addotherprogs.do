***********************************
*  combine data on state programs *
***********************************

* The file otherstateprogs.dta includes data on 
* government benefits by state and year. E-mail the authors for more information.

clear all
use otherstateprogs 
keep if year>1981
gen ur = unemploymentrate
keep state year month maxben3 aveitc maxeitc fpl_child fpl_child5 fpl_child10 fpl_child15  ur

sort state year month

merge state year month using mw7909
tab year _m
summ

sort state year month

* Drop observations that don't correspond to a state
drop if state==3 | state==7 | state==14 | state==43 | state==52

* levels
corr minwage maxeitc
corr minwage maxben3

* changes
by state: gen dmw = minwage - minwage[_n-1]
by state: gen deitc = maxeitc - maxeitc[_n-1]
by state: gen dben3 = maxben3 - maxben3[_n-1]

by state: gen d12mw = minwage - minwage[_n-12]
by state: gen d12eitc = maxeitc - maxeitc[_n-12]
by state: gen d12ben3 = maxben3 - maxben3[_n-12]

corr dmw deitc
corr dmw dben3

corr d12mw d12eitc if month==1
corr d12mw d12ben3 if month==1

corr d12mw d12eitc if month==7
corr d12mw d12ben3 if month==7

drop _merge
save mw7909a, replace

summ

exit, clear