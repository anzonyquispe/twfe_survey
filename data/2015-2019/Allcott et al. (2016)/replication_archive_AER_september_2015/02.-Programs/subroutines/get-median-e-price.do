/* get median e price.do */
* This file collapses to median e price, then fits based on state and year indicators.
	* This fit (instead of just using medians) does two things:
		* It eliminates noise in the estimated annual medians.
		* It allows us to predict prices in years when they may not be observed (i.e. before 1995).

		
gen Rs_kWh_it = velecpur_defl/qelecpur
replace Rs_kWh_it = . if velecpur_defl ==0

gen Rs_kWh_nom = velecpur_nominal/qelecpur
replace Rs_kWh_nom = . if velecpur_nominal ==0

save "$intdata/temp", replace

**********AFTER DROPPING PRODUCTIVITY OUTLIERS, REESTIMATE MEDIAN COST SHARES, ETC AND REPOST IN
**********CALCULATE AND POST IN COST SHARES AND LAMBDA --run this section to generate the merge file if anything about underlying data has changed




collapse (median) Rs_kWh_it grsale_defl Rs_kWh_nom grsale_nominal, by(state year)
drop grsale_defl grsale_nominal
rename Rs_kWh_it Rs_kWh_median
rename Rs_kWh_nom Rs_kWh_nom_median
encode state, gen(statenum)
reg Rs_kWh_median i.statenum i.year, robust
predict Rs_kWh_fitted // Note that this will predict pre-1995 prices based on the omitted year. 

reg Rs_kWh_nom_median i.statenum i.year, robust
predict Rs_kWh_nom_fitted // Note that this will predict pre-1995 prices based on the omitted year. 


** Do another fit only with states 
reg Rs_kWh_median i.statenum, robust, if year>=2001
predict Rs_kWh_statefit

reg Rs_kWh_nom_median i.statenum, robust, if year>=2001
predict Rs_kWh_nom_statefit

drop statenum

save "$work/median real E price_state year.dta", replace


use "$intdata/temp.dta", clear


merge m:1 state year using "$work/median real E price_state year.dta", keep(match master) nogen
	* This imports several different values of Rs_kWh. Use the state fitted value for now - the year-wise trends are not fully believable.
rename Rs_kWh_statefit Rs_kWh
drop Rs_kWh_nom
rename Rs_kWh_nom_statefit Rs_kWh_nom


