clear
cap clear matrix
set mem 1000m
set matsize 10000
set maxvar 10000
set  more off

if "`c(os)'"=="Unix" {
global scratch="/home/fac/da334/Data/Mexico/Stata10/"
global dirnet="/home/fac/da334/Work/Mexico/regout/"
}

if "`c(os)'"=="Windows" {
global dirnet="C:/Work/Mexico/Revision/"
global scratch="C:/Data/Mexico/Stata10/"
global dirtemp="C:/Scratch/"
global dir="C:/Work/Mexico/"
}



****these are table 5 regs for many different drop measures (but no schooling measures)

*******************************FINAL: this gets my dropout age figure
use  "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_July14_cen90_final_megalist_26_Table_5__emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta", clear
replace value=0.217 if rhs=="q11demp5026cp"	& shocker=="demp50" &	lhs=="ecldropq10" &	industry=="26" &	catch=="Linear" &	age==11 &	agefirst==11 &	type=="se" 
*this se was missing---got it by dropping state==1	
*append using "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_May14_cen90_final_26_Table_5_p08_emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta"
append using "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_May14_cen90_final_26_Table_5p08__emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta"

gen regtype="26" 
append using "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_Oct14_cen90_final_26_Table_5_79prop__emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta"
replace regtype="26" if regtype==""

drop if lhs=="ecldropq10"
append using "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_Feb15_cen90_final_26_Table_5_reghdfe2__emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta"
replace regtype="26" if regtype==""
**/





***these are Tabel 11 regs****
/**
*******************************FINAL: this gets my differential export non export figure******
use "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_May14_cen90_final_26_Table_11x_nx27__emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta", clear
append using "C:\My Dropbox\Work\Mexico\Revision\regout\AllAges_Oct14_cen90_final_26_Table_11x_79_nx27__emp__genericskill_none_cen90_allyear_1yrexp_cp_linear12_.dta"
gen regtype="26_27"
gen  post90=regexm(iffy,"yobexp") 
gen addexport=1 
gen interaction="none" 
gen yez=1990-age
tostring yez, replace
gen sub=substr(iffy,-5,.)
replace sub=subinstr(sub," ","",.)
gen post89=(yez==sub) 
replace post90=post90+post89
**/










gen twoyear="no" if age<=50
replace twoyear="yes" if age>50

gen quantile=subinstr(lhs,"eclyrschl","",.)
replace quantile=subinstr(quantile,"prop","p",.)
replace quantile=subinstr(quantile,"ecldrop","drop",.)
replace quantile="ols" if lhs=="eclyrschl"
replace quantile="sd" if lhs=="eclsdyrschl"
replace quantile="cv" if lhs=="eclcvyrschl"
gen ind=substr(rhs,-4,2)
*gen ind=substr(rhs,-6,2)
destring ind, replace 

gen shocktype=word(shocker,1)
replace shocktype="alljobs" if shocktype=="demp50" 
replace shocktype="alljobsha" if shocktype=="dhaemp50" 
replace shocktype="alljobshc" if shocktype=="dhcemp50"
replace shocktype=subinstr(shocktype,"demp","",.)
replace shocktype=subinstr(shocktype,"dhaemp","",.)
replace shocktype=subinstr(shocktype,"dhcemp","",.)
replace shocktype=subinstr(shocktype,"_50","",.)
replace shocktype=regexr(shocktype,"cat[0-9]*","cat")
replace shocktype=regexr(shocktype,"c[0-9]","")

gen shock=regexr(rhs,"^q[0-9]*demp","")
replace shock=regexr(rhs,"^q[0-9]*dh?emp","")
replace shock=regexr(shock,"_50[0-9]*mp","")
replace shock=regexr(shock,"50[0-9]*mp","alljobs")
replace shock=regexr(shock,"_50[0-9]*cp","")
replace shock=regexr(shock,"50[0-9]*cp","alljobs")






gen skilljob=shock
replace skilljob="1: <=25th Pctile Job"  	if shock=="p3cat1n20"
replace skilljob="2: 25-75th Pctile Job"  if shock=="p3cat2n20"
replace skilljob="3: >75th Pctile Job"  	if shock=="p3cat3n20"

replace skilljob="1: <25th Pctile Job"  	if shock=="px3cat1n20"
replace skilljob="2: 25-75th Pctile Job"  if shock=="px3cat2n20"
replace skilljob="3: >=75th Pctile Job"  	if shock=="px3cat3n20"

replace skilljob="1: <=25th Pctile Job"  	if shock=="p4cat1n20"
replace skilljob="2: 25-50th Pctile Job"  if shock=="p4cat2n20"
replace skilljob="3: 50-75th Pctile Job"  if shock=="p4cat3n20"
replace skilljob="4: >75th Pctile Job"  	if shock=="p4cat4n20"

replace skilljob="1: Primary Jobs"  	if shock=="s3cat1n20"
replace skilljob="2: Secondary Jobs"  	if shock=="s3cat2n20"
replace skilljob="3: High School & Uni Jobs"  if shock=="s3cat3n20"

replace skilljob="1: Primary Jobs"  	if shock=="s4cat1n20"
replace skilljob="2: Secondary Jobs"  if shock=="s4cat2n20"
replace skilljob="3: High School Jobs"  if shock=="s4cat3n20"
replace skilljob="4: University Jobs"  	if shock=="s4cat4n20"

replace skilljob="0: All Jobs"  	if shocker=="demp50"

replace skilljob="1: Primary Jobs"  	if shock=="escz3c1d90" | shock=="escz3c1n90"
replace skilljob="2: Secondary Jobs"  	if shock=="escz3c2d90" | shock=="escz3c2n90"
replace skilljob="3: High School & Uni Jobs"  if shock=="escz3c3d90" | shock=="escz3c3n90"

replace skilljob="1: Primary & Secondary Jobs"  	if shock=="escy2c1d90" | shock=="escy2c1n90"
replace skilljob="2: High School & Uni Jobs"  if shock=="escy2c2d90" | shock=="escy2c2n90"

replace skilljob="1: Blue Collar Jobs"  	if shock=="ebl2c1d90" | shock=="ebl2c1n90"
replace skilljob="2: White Collar Jobs"  if shock=="ebl2c2d90" | shock=="ebl2c2n90"

label define indimssx5 24 "Non-Export Manuf." 33 "Low-Tech Export Manuf." 34 "Mid-Tech Export Manuf." 260 "Commerce Etc." 290 "Professional Services" 999 "All Other Jobs" 26 "Commerce Etc." 29 "Professional Services" 11 "Manufacturing" 40 "Services" 20 "Manufacturing" 13 "All IMSS" 90 "Other Jobs" 99 "All IMSS" 32 "Export Manuf."
label values ind indimssx5

cap gen interaction="none"
cap gen addexport=0
cap gen post90=regexm(iffy,"yobexp")
*this takes value 1 if there is a yobexp restriction in iffy
 

order agefirst twoyear skilljob ind type catch shock shocktype quantile value

 

keep agefirst twoyear skilljob regtype ind type catch shock shocktype quantile value post90 addexport interaction 



egen id=group(agefirst twoyear skilljob ind catch shock shocktype quantile regtype post90 addexport interaction)


reshape wide value ,i(id) j(type)  string

drop id


rename valueco coef_
rename valuese se_
gen ciup_=coef_ + 1.96*se_
gen cido_=coef_ - 1.96*se_
drop se_

egen id=group(agefirst twoyear ind catch shock shocktype regtype post90 addexport interaction)



reshape wide coef_ ciup_ cido_ ,i(id) j(quantile) string


*now I label variables os that they show up nicely in legends
cap label var coef_ols Ols
cap label var coef_sd SD
cap label var coef_cv CV
foreach n in 10 25 50 75 90 {
cap label var coef_q`n' "`n'th Pctile Schooling"
}
foreach n in 6 9 8 11 {
cap label var coef_p`n'log "Prop > `n' School (Logit)"
}
foreach n in 06 79 09 1012 1318 {
cap label var coef_p`n'log "Prop Between `n' School (Logit)"
}
foreach n in 6 9 8 11 {
cap label var coef_p`n' "Prop > `n' School"
}
foreach n in 06 79 09 1012 1318 {
cap label var coef_p`n' "Prop Between `n' School"
}


decode ind , gen(indname)


gen indherf=ind
#delimit ;
label define indherf 
10 "Food, beverage, tobacco" 
11 "Textiles, Clothing, Shoes" 
12 "Manufacture of furniture" 
13 "Chemical, Metals, Plastics" 
14 "Electrical Assembly" 
15 "Transport Equipment" 
16 "Other manufacturing" 
20 "Food, beverage, tobacco" 
21 "Textiles, Clothing, Shoes" 
22 "Manufacture of furniture" 
23 "Chemical, Metals, Plastics" 
24 "Electrical Assembly" 
25 "Transport Equipment" 
26 "Other manufacturing" 
50 "Food, beverage, tobacco" 
51 "Textiles, Clothing, Shoes" 
52 "Manufacture of furniture" 
53 "Chemical, Metals, Plastics" 
54 "Electrical Assembly" 
55 "Transport Equipment" 
56 "Other manufacturing" 
40 "Food, beverage, tobacco" 
41 "Textiles, Clothing, Shoes" 
42 "Manufacture of furniture" 
43 "Chemical, Metals, Plastics" 
44 "Electrical Assembly" 
45 "Transport Equipment" 
46 "Other manufacturing";
#delimit cr
label values indherf indherf
decode indherf , gen(indherfname)

gen indherf1=indherf-(floor(indherf/10))*10

gen indherf4=ind
#delimit ;
label define indherf4 
11 "Food, beverage, tobacco" 
13 "Textiles, Clothing, Shoes" 
12 "Chemical, Metals, Plastics" 
14 "Electrical Assembly, Transport Equipment" 
15 "Other manufacturing" 
21 "Food, beverage, tobacco" 
23 "Textiles, Clothing, Shoes" 
22 "Chemical, Metals, Plastics" 
24 "Electrical Assembly, Transport Equipment" 
25 "Other manufacturing" 
31 "Food, beverage, tobacco" 
33 "Textiles, Clothing, Shoes" 
32 "Chemical, Metals, Plastics" 
34 "Electrical Assembly, Transport Equipment" 
35 "Other manufacturing" ;
#delimit cr
label values indherf4 indherf4
decode indherf4 , gen(indherf4name)
gen indherf41=indherf4-(floor(indherf4/10))*10

 
*****************************************************************
*Now lets run some graphs
*****************************************************************

pause on
pause here 











*************now main effect (no skill)

foreach twyr in  no yes {
foreach catcher in Linear Catchup2  Pretrend2  {
foreach regtype in "26" "16"  "19" "14" "19" "11" "13" {
cap {
#delimit ;
twoway 	
line ciup_ols   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0 , lpattern(dash)	lcolor(edkblue*0.7) 	xlabel(10(2)22)	||
line cido_ols   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(dash)	lcolor(edkblue*0.7)    xlabel(10(2)22)	||
connected coef_ols   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , msymbol(o) mcolor(edkblue)	lcolor(edkblue)       xlabel(8(2)22)	
xsize(9) ylabel(#4) ysize(6.5) xtitle("Age of Exposure") ytitle("Cohort Schooling")  yline(0)
legend(off)
saving("${dirnet}Graphs/Manyagesci_ols_two`twyr'_`regtype'_`catcher'.gph", replace)
note("") title("") 
;
#delimit cr
*note("`catcher' `regtype' two`twyr'") title("Job Shock") 


cap graph export "${dirnet}Graphs/Manyagesci_ols_two`twyr'_`regtype'_`catcher'.eps", replace
cap graph export "${dirnet}Graphs/Manyagesci_ols_two`twyr'_`regtype'_`catcher'.emf", replace
cap graph export "${dirnet}Graphs/Manyagesci_ols_two`twyr'_`regtype'_`catcher'.pdf", replace

pause on
pause here 
}
}
}
}


*just drop10

foreach twyr in no { // yes 
foreach regtype in "16"   { // 
foreach dropend10 in  "q"  {
foreach dropend7 in   "v"  {
foreach catcher in Linear  { // Catchup2 Pretrend2  
cap { 
#delimit ;
twoway 	line ciup_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(edkblue*0.5)	xlabel(10(2)22)	||
line cido_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'"  & post90==0 , lpattern(shortdash)	lcolor(edkblue*0.5)	xlabel(10(2)22)	||
connected coef_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'"  & post90==0  , msymbol(s) lpattern(solid)	mcolor(edkblue)	lcolor(edkblue)	xlabel(8(2)22)	
title("Job Shock")  note("`catcher' Drop`dropend' `regtype' two`twyr' drop10`dropend10' drop7`dropend7'")  xsize(9) ylabel(#3) ysize(6.5) xtitle("Age of Exposure") ytitle("Proportion of Cohort Dropping Out") yline(0)
legend(order(3) cols(3) size(small) label(5 "Grade 6 Dropout" ) label(3 "Grade 9 Dropout" ) label(7 "Grade 12 Dropout" ) )
saving("${dirnet}Graphs/Manyagesci_drop`dropend10'_0_two`twyr'_`regtype'_`catcher'.gph", replace)
;
#delimit cr
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_0_two`twyr'_`regtype'_`catcher'.eps", replace
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_0_two`twyr'_`regtype'_`catcher'.emf", replace

pause on
pause here 
}
}
}
}
}
}

**/

foreach twyr in no { // yes 


foreach dropend7 in  "v"   {
foreach dropend10 in  "q"  "`dropend7'" {  // 

foreach regtype in "26"  { // 
foreach catcher in Linear  { // Catchup2 Pretrend2  
cap { 
#delimit ;
twoway 	line ciup_drop`dropend7'7   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(eltblue*0.5)	xlabel(10(2)22)	||
line ciup_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(edkblue*0.5)	xlabel(10(2)22)	||
line cido_drop`dropend7'7   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(eltblue*0.5)	xlabel(10(2)22)	||
line cido_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'"  & post90==0 , lpattern(shortdash)	lcolor(edkblue*0.5)	xlabel(10(2)22)	||
connected coef_drop`dropend7'7   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , msymbol(o)  lpattern(solid)	mcolor(eltblue) lcolor(eltblue)	xlabel(10(2)22)	||
connected coef_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'"  & post90==0  , msymbol(s) lpattern(solid)	mcolor(edkblue)	lcolor(edkblue)	xlabel(10(2)22)	
xsize(9) ylabel(#3) ysize(6.5) xtitle("Age of Exposure") ytitle("Proportion of Cohort Dropping Out") yline(0)
legend(order(5 6) cols(3) size(small) label(5 "Grade 6 Dropout" ) label(6 "Grade 9 Dropout" ) label(7 "Grade 12 Dropout" ) )
saving("${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'.gph", replace)
note("") title("")  
;
#delimit cr
*note("`catcher' Drop`dropend' `regtype' two`twyr' drop10`dropend10' drop7`dropend7'") title("Job Shock")  
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'.eps", replace
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'.emf", replace
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'.pdf", replace


}
}
}
}
}
}




foreach twyr in no { // yes 


foreach dropend7 in  "p08" {
foreach dropend10 in  "q"   {  

foreach regtype in "26"  {  
foreach catcher in Linear  { // Catchup2 Pretrend2  
cap { 
#delimit ;
twoway 	line ciup_p08   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(eltblue*0.5)	xlabel(8(2)22)	||
line ciup_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(edkblue*0.5)	xlabel(8(2)22)	||
line cido_p08   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , lpattern(shortdash)	lcolor(eltblue*0.5)	xlabel(8(2)22)	||
line cido_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'"  & post90==0 , lpattern(shortdash)	lcolor(edkblue*0.5)	xlabel(8(2)22)	||
connected coef_p08   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==0  , msymbol(o)  lpattern(solid)	mcolor(eltblue) lcolor(eltblue)	xlabel(8(2)22)	||
connected coef_drop`dropend10'10   agefirst if  shocktype=="alljobs" & twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'"  & post90==0  , msymbol(s) lpattern(solid)	mcolor(edkblue)	lcolor(edkblue)	xlabel(8(2)22)	
xsize(12) ylabel(-0.5(0.5)0.5) ysize(6.5) scale(1.2) xtitle("Age of Exposure") ytitle("Proportion of Cohort Dropping Out") yline(0)
legend(order(6 5) cols(3) size(small) label(5 "Pre-Grade-9 Dropout" ) label(6 "Grade-9 Dropout" ) label(7 "Grade 12 Dropout" ) )
saving("${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'_wide.gph", replace)
note("") title("")  
;
#delimit cr
*old: xsize(9) ylabel(#3) ysize(6.5) 
*new: xsize(12) ylabel(-0.5(0.5)0.5) ysize(6.5) scale(1.2) 

*note("`catcher' Drop`dropend' `regtype' two`twyr' drop10`dropend10' drop7`dropend7'") title("Job Shock") 
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'_wide.eps", replace
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'_wide.emf", replace
cap graph export "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'_wide.pdf", replace

noi di "${dirnet}Graphs/Manyagesci_drop`dropend10'_`dropend7'_two`twyr'_`regtype'_`catcher'.pdf"
pause on
pause here 

}
}
}
}
}
}

************************end************************






















***********Differential effects graphs *************************** *no interactions*



gen xcoef_ols=coef_ols if ind==27
egen coef_ols27=max(xcoef_ols), by(post90 agefirst catch regtype twoyear shocktype interaction)
gen tcoef_ols=coef_ols+coef_ols27
gen tciup_ols=ciup_ols+coef_ols27
gen tcido_ols=cido_ols+coef_ols27

foreach twyr in no    {
foreach regtype in   "26_27" "26"   {
foreach catcher in Linear  {
foreach interaction in   "none"  {
foreach shocktype in alljobs alljobsha  alljobshc    { // alljobs
foreach post90 in 0 { // 1  2 
foreach pre in   "" {
*cap {



*brow coef_ols   agefirst if   twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==19
#delimit ;
twoway 	
line `pre'ciup_ols   agefirst if   twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==26, lpattern(dash)	lcolor(edkblue*0.5) 	xlabel(12(3)21)	||
line `pre'cido_ols   agefirst if   twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==26 , lpattern(dash)	lcolor(edkblue*0.5)    xlabel(12(3)21)	||
line `pre'ciup_ols   agefirst if   twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==27, lpattern(dash)	lcolor(eltblue*0.5) 	xlabel(12(3)21)	||
line `pre'cido_ols   agefirst if   twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==27 , lpattern(dash)	lcolor(eltblue*0.5)    xlabel(12(3)21)	||
connected `pre'coef_ols   agefirst if  twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==26 , msymbol(o) mcolor(edkblue)	lcolor(edkblue)       xlabel(12(3)21) 	||
connected coef_ols   agefirst if  twoyear=="`twyr'"  & regtype=="`regtype'" & catch=="`catcher'" & post90==`post90' & interaction=="`interaction'" & shocktype=="`shocktype'" & ind==27 , msymbol(s) mcolor(eltblue)	lcolor(eltblue)       xlabel(12(3)21) 	
title("")    xsize(9) xlabel(8(2)22) ylabel(-4(2)4) ysize(6.5) xtitle("Age of Exposure") ytitle("Cohort Schooling")  yline(0)
legend(order(5 6) label(5 "Export Manufacturing Job Shocks") label(6 "Other Formal Job Shocks") size(small)) note("")
saving("${dirnet}Graphs/Manyages_olsdif`pre'_`shocktype'_`interaction'_`regtype'_`catcher'_two`twyr'_post90`post90'.gph", replace)
;
#delimit cr
*note("`shocktype'_`interaction'_`regtype'_`catcher'_two`twyr'_post90`post90'")
 
cap graph export "${dirnet}Graphs/Manyages_olsdif`pre'_`shocktype'_`interaction'_`regtype'_`catcher'_two`twyr'_post90`post90'.pdf", replace
cap graph export "${dirnet}Graphs/Manyages_olsdif`pre'_`shocktype'_`interaction'_`regtype'_`catcher'_two`twyr'_post90`post90'.emf", replace

pause on
pause here
*}
}
}
}
}
}
}
}



