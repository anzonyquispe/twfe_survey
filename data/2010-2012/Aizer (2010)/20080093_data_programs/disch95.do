#delimit;
clear;
cap log close;
log using disch95.log,replace;
set mem 900m;

/* 1995 - 1997*/

local z=95;
while `z'<=97{;

infix typ 7 county 22-23 agecat 8-9 gender 14 racecat 16 ethn 15 source 38
type 39 ins 44-45 mdchcfa 88-89 mdcapr 93-94 str eecode1 58-62 str eecode2
64-68 str eecode3 70-74 str eecode4 76-80 str ddiag1 110-114 str ddiag2
124-128 str ddiag3 130-134 str ddiag4 136-140 using 
dschrg`z'.raw;

keep if typ==1;

gen year=1900+`z';

tab county;
tab agecat;
tab gender;
tab racecat;
tab ins;
tab mdchcfa;

gen female=gender==2;
replace female=. if gender>2;
drop if female==.;
drop if agecat==.;
drop if racecat==7;

drop if agecat<4 | agecat>9;

gen er=source==1;
gen mcaid=ins==2;
gen indigent=(ins==11 | ins==4 | ins==12);

gen poor=mcaid==1 | ind==1;
replace poor=. if ins==.;

gen preg=mdchcfa==14;


local x=1;
while `x'<=4 {;
gen one`x'=substr(ddiag`x',1,1);
tab one`x';
replace ddiag`x'="" if one`x'=="V" | one`x'=="v" | one`x'=="E" | 
one`x'=="e";
gen diag`x'=real(ddiag`x');
replace diag`x'=diag`x'*10 if diag`x'<10000;
replace diag`x'=diag`x'*100 if diag`x'<1000;
replace preg=1 if diag`x'>=63000 & diag`x'<=67799;

local x=`x'+1;
};

tab preg;

local x=1;
while `x'<=4 {;
gen y`x'=substr(eecode`x', 2,4);
gen ecode`x'=real(y`x');
replace ecode`x'=ecode`x'*10 if ecode`x'<999;
local x=`x'+1;
};

gen fips=6000+county*2-1;

gen race=racecat if racecat<=2;
replace race=4 if racecat==4;
replace race=5 if racecat==3 | racecat==5;
replace race=. if racecat==6;
replace race=3 if ethn==1;
replace race=2 if racecat==2;


do ecode



#delimit;
tab preg;
tab assault;
tab preg assault;

gen pregass=preg*assault;
gen pregsui=preg*suicide;
gen pregunint=preg*unint;

gen age=1 if agecat==4;
replace age=2 if agecat==5 | agecat==6;
replace age=3 if agecat>=7 & agecat<=9;

label define agel 1 15_24 2 25_44 3 45_64;
label values age agel;

keep age race fips female preg* er mcaid indigent poor assault* suicide
mvdriver mvped batter unint anyinj gun cut fight drown poison strang;

collapse (sum) preg* er assault* suicide mv* anyinj batter unint gun cut 
fight drown poison strang, by (fips race age female poor);

gen year=1900 + `z';

sort fips year race age female;
save disch`z'.dta,replace;
clear;
local z=`z'+1;
};






 
