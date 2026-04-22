#delimit;
clear;
cap log close;
log using disch98.log,replace;
set mem 1100m;

/* 1998 - 2000*/

local z=98;
while `z'<=100 {;



clear;

infix typ 7 county 22-23 agecat 8-9 gender 14 racecat 16 ethn 15 source 38
type 39 ins 44-45 mdchcfa 88-89 mdcapr 93-94 str eecode1 58-62 str eecode2
64-68 str eecode3 70-74 str eecode4 76-80 str ddiag1 110-114 str ddiag2
124-128 str ddiag3 130-134 str ddiag4 136-140 using 
dschrg`z'_1.raw;

keep if typ==1;
tab county;

save temp`z'.dta,replace;
clear;

infix typ 7 county 22-23 agecat 8-9 gender 14 racecat 16 ethn 15 source 38
type 39 ins 44-45 mdchcfa 88-89 mdcapr 93-94 str eecode1 58-62 str eecode2
64-68 str eecode3 70-74 str eecode4 76-80 str ddiag1 110-114 str ddiag2
124-128 str ddiag3 130-134 str ddiag4 136-140 using 
/users2/aaizer/dschrg`z'_2.raw;

keep if typ==1;
tab county;

append using temp`z'.dta;

*erase temp`z'.dta;

drop typ;

gen year=`z'+1900;

gen female=gender==2;
replace female=. if gender>2;
drop if female==.;
drop if agecat==.;
drop if racecat==7;
drop gender;

drop if agecat<4 | agecat>14;
drop if agecat>9 & year==1998;
drop if agecat==4 & year==1999;
drop if agecat==4 & year==2000;

tab source;

gen er=source==1;
drop source;

gen mcaid=ins==2;
gen indigent=.;
replace indigent=1 if (ins==11 | ins==4 | ins==12) & year==1998;
replace indigent=1 if (ins==5 | ins==7 | ins==8) & year==1999;
replace indigent=1 if (ins==5 | ins==7 | ins==8) & year==2000;

gen poor=(mcaid==1 | ind==1);
replace poor=. if ins==.;

gen preg=mdchcfa==14;
drop mdchcfa ins;

local x=1;
while `x'<=4 {;
gen one`x'=substr(ddiag`x',1,1);
replace ddiag`x'="" if one`x'=="V" | one`x'=="v" | one`x'=="E" | 
one`x'=="e";
gen diag`x'=real(ddiag`x');
replace diag`x'=diag`x'*10 if diag`x'<1000;
replace diag`x'=diag`x'*100 if diag`x'<100;
replace preg=1 if diag`x'>=63000 & diag`x'<=67799;
local x=`x'+1;
};

drop ddiag*;
drop diag*;


local x=1;
while `x'<=4 {;
gen y`x'=substr(eecode`x', 2,4);

gen ecode`x'=real(y`x');
replace ecode`x'=ecode`x'*10 if ecode`x'<999;
drop y`x';
local x=`x'+1;
};

drop eecode*;

gen fips=6000+county*2-1;
drop county;

gen race=racecat if racecat<=2;
replace race=4 if racecat==4;
replace race=5 if racecat==3 | racecat==5;
replace race=. if racecat==6;
replace race=3 if ethn==1;
replace race=2 if racecat==2;
drop racecat ethn;

do ecode


#delimit;
gen pregass=preg*assault;
gen pregsui=preg*suicide;
gen pregunint=preg*unint;

gen age=1 if agecat>=5 & agecat<=6 & year~=1998;
replace age=2 if agecat>=7 & agecat<=10 & year~=1998;
replace age=3 if agecat>=11 & agecat<=14 & year~=1998;

replace age=1 if agecat==4 & year==1998;
replace age=2 if agecat>=5 & agecat<=6 & year==1998;
replace age=3 if agecat>=7 & agecat<=9 & year==1998;


drop agecat;

label define agel 1 15_24 2 25_44 3 45_64;
label values age agel;

keep age race fips female preg* er mcaid indigent poor assault* suicide
mvdriver mvped batter unint anyinj gun cut fight strang drown poison;

collapse (sum) preg* er assault* suicide mv* batter unint anyinj gun cut 
fight poison drown strang, by (fips race age female poor);

gen year=1900+`z';

sort fips year race age female;
save disch`z'.dta,replace;
clear;
local z=`z'+1;
};


 
