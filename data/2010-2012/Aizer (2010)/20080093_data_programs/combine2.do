#delimit;
log using combine2.log,replace;
set mem 300m;

/* combine hospital discharge data for 1990-2000*/

use disch90.dta;
summ;

/* only half a year - need to multiply by 2*/

replace mvdriver=mvdriver*2;
replace assault=assault*2;
replace assaultng=assaultng*2;
replace mvped=mvped*2;
replace suicide=suicide*2;
replace unint=unint*2;
replace anyinj=anyinj*2;
replace er=er*2;

replace preg=preg*2;
replace pregass=pregass*2;
replace pregsui=pregsui*2;
replace pregunin=pregunin*2;

save disch902.dta,replace;


local x=91;
while `x'<=100 {;
append using disch`x'.dta;
local x=`x'+1;
};

tab year;

tab race;
tab age;
tab fips;
tab female;
tab poor;

drop if age==.;
drop if race==.;
drop if female==.;


collapse (sum) batter assault* mvdriver mvped anyinj er suicide unint
pregass, by (fips year age race female);

save temp.dta,replace;
keep if female==0;

rename assault massault;
rename assaultng massaultng;
rename mvdriver mmvdriver;
rename mvped mmvped;
rename anyinj manyinj;
rename er mer;
rename suicide msuicide;
rename unint munint;

drop female;
sort fips year race age;

save mtemp.dta,replace;
clear;
use temp.dta if female==1;

rename assault fassault;
rename assaultng fassaultng;
rename mvdriver fmvdriver;
rename mvped fmvped;
rename anyinj fanyinj;
rename er fer;
rename suicide fsuicide;
rename unint funint;


drop female;
sort fips year race age;
merge fips year race age using mtemp.dta;
tab _merge;

replace fassault=0 if fassault==.;
replace massault=0 if massault==.;

replace fassaultng=0 if fassaultng==.;
replace massaultng=0 if massaultng==.;

replace fer=0 if fer==.;
replace mer=0 if mer==.;

replace fsuicide=0 if fsuicide==.;
replace msuicide=0 if msuicide==.;

replace funint=0 if funint==.;
replace munint=0 if munint==.;

replace fmvdriver=0 if fmvdriver==.;
replace mmvdriver=0 if mmvdriver==.;

replace fmvped=0 if fmvped==.;
replace mmvped=0 if mmvped==.;

replace fanyinj=0 if fanyinj==.;
replace manyinj=0 if manyinj==.;

replace batter=0 if batter==.;

sort year;
by year: summ batter;

replace batter=. if year<1997;

drop _merge;
desc;
summ;

sort fips year race age;

save hosp2.dta,replace;

erase temp.dta;
erase mtemp.dta;

collapse (sum) fassault massault fanyinj manyinj, by (year);
sort year;
list;

