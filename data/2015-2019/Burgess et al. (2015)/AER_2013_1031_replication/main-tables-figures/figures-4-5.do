* Define the location of the main folder on your computer *
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\main-tables-figures"

*******************************************************************************************
******* This do-file creates the figures for the paper, Figure 4 and 5 ********************
*******************************************************************************************

*************************************************************************************************
** Figure 4: "Road Expenditure in Presidential Coethnic and Non-Coethnic Districts, 1963-2011" **
*************************************************************************************************
use "$mypath\kenya_roads_exp", clear
gen group = "other"
foreach X in kikuyu  kalenjin {
replace group = "`X'" if `X'_share62 >= 0.5
}
collapse (sum) droadexp_tot pop1962 area, by(president year)
sort year president
bysort year: egen droadexp_country = sum(droadexp_tot)
gen roadexp_share = droadexp_tot / droadexp_country*100
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen exp_dens_share = roadexp_share / pop1962_share
keep if year >= 1963 & year <= 2011
twoway (connected exp_dens_share year if president == 1, lwidth(medthick) msize(small)) (connected exp_dens_share year if president == 0, lwidth(medthick) msize(small) msymbol(square) lpattern(dash)), ytitle(Share of Road Dvt Expenditure Share [d,t] / Pop. Share [d, 1962], size(medsmall)) ytitle(, margin(small)) xtitle(., size(zero)) yline(1, lpattern(solid) lcolor(gs10)) xline(1969.916667 1992.916667) xline(1978.666667 2002.916667, lpattern(vshortdash)) legend(order(1 "Coethnic Districts" 2 "Non-Coethnic Districts")) xlabel(#5) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
graph export "$mypath\figure_4.png", replace width(2620) height(1908)
* We use graph editor to edit the figure (the y-title needs to be adjusted) *

*************************************************************************************************
** Figure 5: "Road Expenditure in Kikuyu, Kalenjin and Other Ethnic Districts, 1963-2011" *******
*************************************************************************************************
use "$mypath\kenya_roads_exp", clear
gen group = "other"
foreach X in kikuyu  kalenjin {
replace group = "`X'" if `X'_share62 >= 0.5
}
collapse (sum) droadexp_tot pop1962 area, by(group year)
sort year group
bysort year: egen droadexp_country = sum(droadexp_tot)
gen roadexp_share = droadexp_tot / droadexp_country*100
replace group = "1. Kikuyu Districts" if group == "kikuyu"
replace group = "2. Kalenjin Districts" if group == "kalenjin"
replace group = "3. Other Districts" if group == "other"
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen exp_dens_share = roadexp_share / pop1962_share
keep if year >= 1963 & year <= 2011
twoway (connected exp_dens_share year if group == "1. Kikuyu Districts", lwidth(medthick) msize(small)) (connected exp_dens_share year if group == "2. Kalenjin Districts", lwidth(medthick) msize(small) msymbol(square) lpattern(dash)) (line exp_dens_share year if group == "3. Other Districts", lcolor(gs5) lwidth(medthick) lpattern(solid)), ytitle(Share of Road Dvt Expenditure Share [d,t] / Pop. Share [d, 1962], size(medsmall)) ytitle(, margin(small)) xtitle(., size(zero)) yline(1, lpattern(solid) lcolor(gs10)) xline(1969.916667 1992.916667) xline(1978.666667 2002.916667, lpattern(vshortdash)) legend(order(1 "Kikuyu Districts" 2 "Kalenjin Districts" 3 "Other Districts") rows(1) span) xlabel(#5) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
graph export "$mypath\figure_5.png", replace width(2620) height(1908)
* We use graph editor to edit the figure (the legend box and y-title need to be adjusted) *

************************************************************************************************************************
************************************************************************************************************************
************************************************END OF DO FILE *********************************************************
************************************************************************************************************************
************************************************************************************************************************
