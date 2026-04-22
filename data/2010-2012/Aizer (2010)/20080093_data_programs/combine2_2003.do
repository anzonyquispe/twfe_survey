#delimit;
clear;
cap log close;
log using combine2_2003.log,replace;
set mem 1700m;

/* combines 2001-2003 discharge data with 1990-2000 hospital discharge 
data cadisch/hosp2.dta - creates assaults and collapses
resulting data is hosp2_2003.dta */

clear;
local z=2001;
while `z'<=2003 {; 
use rawdisch`z'.dta;
desc;
keep if typ_care==1;

gen female=sex=="2";
replace female=. if sex==".";
drop if female==.;

drop if agecat20r<5 | (agecat20r>14 & agecat20r<.);

gen src=string(adm_src);
gen source=substr(src,3,1 );
gen er=source=="1";
list adm_src source in 1/10;

drop source adm_src src;

gen mcaid=pay_cat==2;
gen indigent=.;
replace indigent=1 if (pay_cat==5 | pay_cat==7 | pay_cat==8);

gen poor=(mcaid==1 | ind==1);
replace poor=. if pay_cat==. | pay_cat==0;

gen preg=mdc==14;
drop mdc pay_cat;


rename diag_p ddiag0;
rename odiag1 ddiag1;
rename odiag2 ddiag2;
rename odiag3 ddiag3;
rename odiag4 ddiag4;

local x=0;
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



rename ecode_p eecode0;
rename ecode1 eecode1;
rename ecode2 eecode2;
rename ecode3 eecode3;
rename ecode4 eecode4;

local x=0;
while `x'<=4 {;
gen y`x'=substr(eecode`x', 2,4);

gen ecode`x'=real(y`x');
replace ecode`x'=ecode`x'*10 if ecode`x'<999;
drop y`x';
local x=`x'+1;
};

drop eecode*;

gen cty=real(patcnty);
tab cty;

gen fips=6000+cty*2-1;
drop patcnty cty;


replace race="5" if race=="3";
replace race="3" if ethncty=="1";
tab race;
gen racer=real(race);
list race racer in 1/10;
drop race;
rename racer race;

do ecode03


#delimit;
gen pregass=preg*assault;
gen pregsui=preg*suicide;
gen pregunint=preg*unint;

gen age=1 if agecat20r>=5 & agecat20r<=6;
replace age=2 if agecat20r>=7 & agecat20r<=10;
replace age=3 if agecat20r>=11 & agecat20r<=14;


label define agel 1 15_24 2 25_44 3 45_64;
label values age agel;

keep age race fips female preg* er mcaid indigent poor assault* suicide
mvdriver mvped batter unint anyinj gun cut fight strang drown poison ;



tab race;
tab age;
tab fips;
tab female;
tab poor;

/* keep only 15-44 year olds*/

keep if age==1 | age==2;

collapse (sum) batter assault* mvdriver mvped anyinj er suicide unint
pregass, by (fips race female);

gen year=`z';

save temp`z'.dta,replace;
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
sort fips year race;

save mtemp`z'.dta,replace;
clear;
use temp`z'.dta if female==1;

rename assault fassault;
rename assaultng fassaultng;
rename mvdriver fmvdriver;
rename mvped fmvped;
rename anyinj fanyinj;
rename er fer;
rename suicide fsuicide;
rename unint funint;


drop female;
sort fips year race;
merge fips year race using mtemp`z'.dta;
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

save disch`z'_2.dta,replace;
clear;
erase temp`z'.dta;
erase mtemp`z'.dta;

local z=`z'+1;
};




clear;

use hosp1990-1999.dta;

tab age;

/* keep only 15-44 year olds*/
keep if age==1 | age==2;

collapse (sum) fassault massault fassaultng massaultng mmvdriver fmvdriver 
mmvped fmvped manyinj fanyinj mer fer msuicide fsuicide funint munint, by 
(fips year race);


/* datasets with only women age 15-44*/

append using disch2001_2.dta;
append using disch2002_2.dta;
append using disch2003_2.dta;


sort fips year race;
save hosp2_2003.dta,replace;
tab year;
tab fips;
tab race;
table year, c (mean fassault);


 
