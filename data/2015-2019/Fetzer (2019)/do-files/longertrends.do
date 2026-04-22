***
use "data files/USOCBHPSCOMB.dta", clear


tab SIC2007Section if SIC2007Section!="NA", gen(sec_)

tab hiqual_dv_sd_num, gen(qual_)

egen rwyr = group(region year)

tab year, gen(yy_)

gen usoc = wavechar =="a" | wavechar=="b" | wavechar=="c" | wavechar =="d" | wavechar =="e" | wavechar =="f" | wavechar =="g"



gen nonretired = jbstat_sd != "retired"

gen otherincome  = fimngrs_dv-fimnlabgrs_dv-fimnsben_dv

encode SIC2007Section, gen(sic)


***ever SIC
gen emphistory =""
forvalues i=1(1)20 { 

egen maxSIC`i'  = max(sec_`i'), by(pidp)

tostring maxSIC`i', gen(tt)

replace emphistory = emphistory+tt

drop tt
}


egen idwyr = group(id wave year)


*********************
*** FIGURE 8
*********************

foreach depvar in  fimngrs_dv  fimnsben_dv fimnlabgrs_dv   {
foreach fe in "idwyr"  {
foreach var in qual_1  qual_4 {
preserve
local lab: variable label `var'  

local shorter = substr("`var'", 1,20)

forvalues i=1(1)15 {

gen yyin_`shorter'_`i' = yy_`i' * `var'
}

if("`partialout'"!="") {
local partialout = i.year#c.`partialout'
}

reghdfe `depvar'   yyin_`shorter'_1  yyin_`shorter'_2 yyin_`shorter'_3 yyin_`shorter'_4-yyin_`shorter'_15  `partialout'  if  nonretired==1 ,  absorb(pidp  `fe' )   vce(cl id)

matrix hrid = J(80 ,6, 0)

global iter  = 1
forvalues i=1(1)15 {

*if(`i'!=9) {
  lincom  yyin_`shorter'_`i'
  matrix hrid[$iter,3] = `r(estimate)'
  matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
  matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
  su year if  yy_`i'== 1
  matrix hrid[$iter, 1] = `r(mean)'
 *  matrix hrid[$iter, 1] = `i'
  matrix hrid[$iter, 5] = `r(N)'

*}
  global iter=$iter+1
  }

  svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0

 
su hrid1
sort hrid1
twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010.5)) (rcap hrid2 hrid4 hrid1  if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1  ,  ytitle("Coefficient estimate", axis(1)))  , scheme(s1color) legend(off) xtitle("Year", size(4))  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[2]`r(max)')   
graph export "figures/`depvar'-did`partialout'-`var'-`fe'.eps", replace


restore
}
}
} 



*********************
*** FIGURE A8
*********************

foreach depvar in  fimngrs_dv  fimnsben_dv fimnlabgrs_dv   {
foreach fe in "idwyr"  {
foreach var in qual_1  qual_4 {
preserve
local lab: variable label `var'  

local shorter = substr("`var'", 1,20)

forvalues i=1(1)15 {

gen yyin_`shorter'_`i' = yy_`i' * `var'
}

if("`partialout'"!="") {
local partialout = i.year#c.`partialout'
}

reghdfe `depvar'   yyin_`shorter'_1  yyin_`shorter'_2 yyin_`shorter'_3 yyin_`shorter'_4-yyin_`shorter'_15  `partialout'  if  maxSIC4!=1 & maxSIC13!=1 &  maxSIC12!=1 & nonretired==1 ,  absorb(pidp  `fe' )   vce(cl id)

matrix hrid = J(80 ,6, 0)

global iter  = 1
forvalues i=1(1)15 {

  lincom  yyin_`shorter'_`i'
  matrix hrid[$iter,3] = `r(estimate)'
  matrix hrid[$iter,2] = `r(estimate)' - 1.65 * `r(se)'
  matrix hrid[$iter,4] = `r(estimate)'+ 1.65* `r(se)'
  su year if  yy_`i'== 1
  matrix hrid[$iter, 1] = `r(mean)'
  matrix hrid[$iter, 5] = `r(N)'

  global iter=$iter+1
  }

  svmat hrid

sort hrid1
replace hrid6 = hrid3

su hrid2
local miny = `r(min)'
su hrid4
local maxy = `r(max)'
drop if hrid1==0 & hrid2==0 & hrid3==0 & hrid4==0 & hrid5==0

 
su hrid1
sort hrid1
twoway (connected hrid3 hrid1 , lpattern(dash) lcolor(gray) xline(2010.5)) (rcap hrid2 hrid4 hrid1  if hrid3!=0, lpattern(none)) (scatter hrid3 hrid1  ,  ytitle("Coefficient estimate", axis(1)))  , scheme(s1color) legend(off) xtitle("Year", size(4))  xscale(range(`r(min)' `r(max)')) xlabel(`r(min)'[2]`r(max)')   
graph export "figures/`depvar'-did`partialout'-`var'-`fe'-nevermanu.eps", replace


restore
}
}
} 
