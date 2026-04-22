#delimit;
clear;
cap log close;
log using disch91.log,replace;
set mem 900m;

/* version B */

infix qtr 35 year 36-37 typ 1 county 392-393 agecat 10-11 gender 16 
racecat 17-18 source 38-39 type 40-41 ins 53-54 mdchcfa 381-382 str 
eecode1 356-360 str eecode2 361-365 str eecode3 366-370 str eecode4 
371-375 str ddiag1 68-72 str ddiag2 73-77 str ddiag3 78-82 
str ddiag4 83-87 ctyhosp 4-5 using dschrg91.raw;

keep if typ==1;

tab qtr; 
tab year;
save temp91.dta,replace;
tab county;
tab agecat;
tab eecode1;
tab racecat;
list  ddiag1 in 1/10;
tab ins;

drop if agecat<4 | agecat>9;

count if county~=ctyhosp;
tab county if county~=ctyhosp;
tab ctyhosp if county~=ctyhosp;


gen female=gender==2;
replace female=. if gender>2;

gen er=source==12;
gen mcaid=ins==2;
gen indigent=(ins==9 | ins==10 | ins==12);

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

tab ecode1;
tab ecode2;

gen fips=6000+county*2-1;

gen race=racecat if racecat<=3;
replace race=4 if racecat==5;
replace race=5 if racecat==4 | racecat==6;
replace race=. if racecat==7;


do ecode;


gen pregass=preg*assault;
gen pregsui=preg*suicide;
gen pregunint=preg*unint;

gen age=1 if agecat==4;
replace age=2 if agecat==5 | agecat==6;
replace age=3 if agecat>=7 & agecat<=9;

label define agel 1 15_24 2 25_44 3 45_64;
label values age agel;

summ preg*;



keep age race fips female preg* er mcaid indigent poor assault* suicide
mvdriver mvped anyinj batter unint gun cut fight poison drown strang;


collapse (sum) preg* er assault* suicide mv* anyinj batter unint gun cut 
fight poison drown strang, by (fips race age female poor);

sort fips race age female poor;

gen year=1991;

save disch91.dta,replace;
desc;
summ;
clear;
 

