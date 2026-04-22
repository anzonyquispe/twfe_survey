#delimit;
clear;
set more off;
set mem 200m;
set matsize 800;


/* for this analysis I only had access to a few years with weekend data: 1990, 1992-1994 and 1996*/

*dataallbA.dta,replace;
desc;

drop if year>=1997;
drop if year==1991 | year==1995;

sort fips year race;
merge fips year race using ../asiannonint.dta;
tab _merge;
drop if _merge==2;
drop _merge;


gen nonint_r=nonint*100000/(fempop+malepop);

replace marr_r=marr*100000/fempop;

tab race;
replace black=0 if race~=2;
replace hisp=0 if race~=3;
cap drop asian;
gen asian=race==4;
label var asian "Asian";

/* assaults*/

gen fnainj_m=((fanyinj-fassault)/(manyinj-massault));
gen lfass_m=ln(fass_m);
gen lfinj_m=ln(fanyinj/manyinj);
replace fass_r=0 if fass_r==.;
replace mass_r=0 if mass_r==.;
replace fass_m=0 if fass_m==.;
replace fass_inj=0 if fass_inj==.;
replace mass_inj=0 if mass_inj==.;
replace fass_er=0 if fass_er==.;
replace funi_r=0 if funi_r==.;
replace fsui_r=0 if fsui_r==.;
label var mass_inj "Male assaults/injuries";

cap drop lfnainj;
gen lfnainj=ln(fanyinj-fassault);
replace lnonint=0 if lnonint==.;


label var fnainj_r "Non-assault injuries";
label var lfnainj "Ln(non-assault injuries)";
label var mnainj_r "Non-assault injuries";
label var fnainj_m "Female/male non-assault injuries";
label var fass_inj "Female assaults/injuries";
label var fass_m "Female/male assaults";
label var fass_r "Female assault rate";

drop if race>4;

table year if weekend==0 & fempop>=10000 [w=fempop], c(mean fassault mean 
massault);

table year if weekend==1 & fempop>=10000 [w=fempop], c(mean fassault mean 
massault);

table year if weekend==0 & fempop>=10000 [w=fempop], c(mean fass_r mean 
mass_r mean lfass mean lmass);
table year if weekend==1 & fempop>=10000 [w=fempop], c(mean fass_r mean 
mass_r);

table year if weekend==1 & fempop>=10000 [w=fempop], c (mean fass_r);


cap drop _merge;
sort fips year race;
merge fips year race using bartik03_aer.dta;
tab _merge;
keep if _merge==3;
drop _merge;

label var ur "Unemployment rate";

gen lfempop=ln(fempop);
label var lfempop "Ln(female population)";


tab year;
table year weekend [w=fempop] if fempop>=10000, c(mean fass_r mean ratiow_hs);

/* weekend regs*/

global wage "ratiow_hs";
global o "se bracket nocons noaster";

local x=6001;
while `x'<=6115 {;
gen cty`x'_linear=year if fips==`x';
replace cty`x'_linear=0 if fips~=`x';
local x=`x'+2;
};

gen ayear=asian*year;
gen hyear=hisp*year;
gen byear=black*year;

preserve;

table weekend [w=fempop], c (mean fass_r mean fass_inj);

gen weekendwage=$wage*weekend;
label var weekendwage "Wage ratio*weekend";

gen weeklpercap=weekend*lpercap;
label var weeklpercap "weekend*ln(per capita income)";

gen weekur=weekend*ur;
label var weekur "weekend*unemployment rate";

gen weeklfempop=weekend*lfempop;
label var weeklfempop "weekend*ln(female population)";

global race "weekend weekur weeklpercap weeklfempop black hisp asian 
lpercap lnonint ur lfnainj lfempop";

global control "i.year cty* ayear byear hyear";
global if "if fempop>=10000";


xi: areg lfass $wage weekendwage lmass $race $control  
$if [w=fempop], a (fips) cluster (fips);
outreg $wage weekendwage using table2.out,append nocons noaster bracket 
se;



sort fips race weekend year;
by fips race: gen laglfass=lfass[_n-1];

xi: areg lfass $wage weekendwage laglfass $race $control $if 
[w=fempop], a (fips) cluster (fips);
*outreg $wage weekendwage laglfass using table2.out,append nocons noaster 
bracket se;

global wage "difw_hs";
replace weekendwage=weekend*$wage;
label var weekendwage "(Male-female wage)*weekend";

xi: areg lfass $wage weekendwage lmass $race $control 
$if [w=fempop], a (fips) cluster (fips);
outreg $wage weekendwage using table2b.out,append nocons noaster bracket 
bdec(4) se;

xi: areg lfass $wage weekendwage lmass laglfass $race $control $if 
[w=fempop], a (fips) cluster (fips);
*outreg $wage weekendwage using table2b.out,append nocons noaster bracket 
bdec(4) se;

