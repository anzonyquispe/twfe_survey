** STB over Tech Areas Figure
insheet using tables/ixTable.txt, n clear
drop if year != .
expand 3

bysort area: g dup = _n
replace coeff = lower if dup == 2
replace coeff = upper if dup == 3

gen stackOrder = 1 if area == "app"
replace stackOrder = 2 if area == "tsv"
replace stackOrder = 3 if area == "int"
replace stackOrder = 4 if area == "rtg"
replace stackOrder = 5 if area == "ops"
replace stackOrder = 6 if area == "sec"

replace area = "Applications" if area == "app"
replace area = "Internet" if area == "int"
replace area = "Transport" if area == "tsv"
replace area = "Routing" if area == "rtg"
replace area = "Security" if area == "sec"
replace area = "Operations" if area == "ops"

graph hbox coeff, over(area, sort(stackOrder)) inten(7) medline(lcolor(black)) alsize(0) ytitle("Suit-to-Beard Coefficient (and 95% CI)")
graph export figures/stbTechAreas.wmf, replace

** STB over Years Figure 1
insheet using tables/ixTable.txt, n clear
drop if area != "" | extra == 1
twoway (scatter coeff year, connect(l) msymbol(O)) (scatter upper year, connect(l) msym(oh) lpat(dot) lcolor(gray)) (scatter lower year, connect(l) msym(oh) lpat(dot) lcolor(gray)), ytitle("Suit-to-Beard Coefficient" " ")  xtitle("Year") legend(off)
graph export figures/stbYears.wmf, replace

** STB over Years Figure 2
*insheet using tables/ixTable.txt, n clear
*keep if extra == 1
*twoway (scatter coeff year, connect(l) msymbol(O)) (scatter upper year, connect(l) msym(oh) lpat(dot) lcolor(gray)) (scatter lower year, connect(l) msym(oh) lpat(dot) lcolor(gray)), ytitle("Suit-to-Beard Coefficient" " ")  xtitle("Year") legend(off)
*graph export 
