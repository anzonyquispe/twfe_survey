* Define the location of the main folder on your computer *
global mypath "X:\EthnicFavouritism\AER-FINAL\replication\main-tables-figures"

**************************************************
**************************************************
* This do-file creates Appendix Figure A3 and A4 *
**************************************************
**************************************************

*******************************************************************************************************************************
*******************************************************************************************************************************
*** Appendix Figure A3: "Road Expenditure in Kenyan Districts for the Largest Ethnic Groups and Other Groups, 1963-2011" ******
*******************************************************************************************************************************
*******************************************************************************************************************************

use "$mypath\kenya_roads_exp", clear
gen group = "other"
foreach X in kikuyu  kalenjin {
replace group = "`X'" if `X'_share62 >= 0.5
}
replace group = "kambaluhyaluo" if kamba_share62 >= 0.5 | luhya_share62 >= 0.5  | luo_share62 >= 0.5 
collapse (sum) droadexp_tot pop1962 area, by(group year)
sort year group
bysort year: egen droadexp_country = sum(droadexp_tot)
gen roadexp_share = droadexp_tot / droadexp_country*100
replace group = "1. Kikuyu Districts" if group == "kikuyu"
replace group = "2. Kalenjin Districts" if group == "kalenjin"
replace group = "3. Kamba, Luhya and Luo Districts" if group == "kambaluhyaluo"
replace group = "4. Other Districts" if group == "other"
bysort year: egen pop1962_country = sum(pop1962)
gen pop1962_share = pop1962/pop1962_country*100
gen exp_dens_share = roadexp_share / pop1962_share
keep if year >= 1963 & year <= 2011
twoway (connected exp_dens_share year if group == "1. Kikuyu Districts", lwidth(medthick) msize(small)) (connected exp_dens_share year if group == "2. Kalenjin Districts", lwidth(medthick) msize(small) msymbol(square) lpattern(dash)) (line exp_dens_share year if group == "3. Kamba, Luhya and Luo Districts", lwidth(thick) lpattern(longdash_dot) lcolor(orange)) (line exp_dens_share year if group == "4. Other Districts", lcolor(gs8) lwidth(medthick) lpattern(solid)), ytitle(Share of Road Dvt Expenditure Share [d,t] / Pop. Share [d, 1962], size(medsmall)) ytitle(, margin(small)) xtitle(., size(zero)) yline(1, lpattern(solid) lcolor(gs10)) xline(1969.916667 1992.916667) xline(1978.666667 2002.916667, lpattern(vshortdash)) legend(order(1 "Kikuyu Districts" 2 "Kalenjin Districts" 3 "Kamba, Luhya and Luo Districts" 4 "Other Districts") rows(2) span) xlabel(#5) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
graph export "$mypath\kenya_regressions\figure_A3.png", replace width(2620) height(1908)
* We use graph editor to edit the figure (the legend box and y-title need to be adjusted) *

****************************************************************************************************************
****************************************************************************************************************
*** Appendix Figure A4: "Number of Road Articles in The Daily Nation and The Standard Newspapers, 1985-2010" ***
****************************************************************************************************************
****************************************************************************************************************

use "$mypath\kenya_roads_exp", clear
keep if year >= 1985 & year <= 2010
keep year nation standard
bysort year: keep if _n == 1

twoway (connected nation year), ytitle(.) ytitle(, size(.) color(white)) ylabel(0(20)100) xtitle(.) xtitle(, size(zero) color(white)) xline(1992.9, lpattern(solid)) xline(2002.9, lpattern(shortdash)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
graph export "$mypath\kenya_regressions\figure_A4_top.png", replace width(2620) height(1908)

twoway (connected standard year, lcolor(white)) (connected standard year), ytitle(.) ytitle(, size(.) color(white)) ylabel(0(20)100) xtitle(.) xtitle(, size(zero) color(white)) xline(1992.9, lpattern(solid)) xline(2002.9, lpattern(shortdash)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) legend(order(1 "The Daily Nation" 2 "The Standard"))
graph export "$mypath\kenya_regressions\figure_A4_bottom.png", replace width(2620) height(1908)

************************************************************************************************************************
************************************************************************************************************************
************************************************END OF DO FILE *********************************************************
************************************************************************************************************************
************************************************************************************************************************
