#delimit;
cap log close;
clear;
log using bartik03_industry.log,replace;
set mem 550m;

/* change in industrial composition - 1990 industry wages fixed*/

use naics90.dta;
drop year;
expand 14;
sort fips;
by fips: gen year=_n;
replace year=1989+year;
tab year;

expand 5;
sort fips year;
by fips year: gen race=_n;
tab race;

label define racel 1 white 2 black 3 hisp 4 asian 5 other;
sort fips year race;
merge fips year race using gamma_linear.dta;
tab _merge;
drop _merge;


sort year;
merge year using naicsca03.dta;
tab _merge;
drop _merge;


/* need to generate weekly wages*/

gen fem_55=0;
gen male_55=0;


gen femwage=fem_11*wklywage11+fem_21*wklywage21 + fem_22*wklywage22+
fem_23*wklywage23 + fem_31*wklywage31 + fem_42*wklywage42+
fem_44*wklywage44 + fem_48*wklywage48+fem_51*wklywage51 +
fem_52*wklywage52+fem_53*wklywage53 + fem_54*wklywage54 +
fem_55*wklywage55 + fem_56*wklywage56 + fem_61*wklywage61 +
fem_62*wklywage62 + fem_71*wklywage71+fem_72*wklywage72 +
fem_81*wklywage81 + fem_92*wklywage92;

gen malewage=male_11*wklywage11 + male_21*wklywage21 + male_22*wklywage22
+ male_23*wklywage23 + male_31*wklywage31 + male_42*wklywage42+
male_44*wklywage44 + male_48*wklywage48 + male_51*wklywage51 +
male_52*wklywage52 + male_53*wklywage53 + male_54*wklywage54 +
male_55*wklywage55 + male_56*wklywage56 + male_61*wklywage61 +
male_62*wklywage62 + male_71*wklywage71 + male_72*wklywage72 +
male_81*wklywage81 + male_92*wklywage92;



label var femwage "female weekly wage - county level";
label var malewage "male weekly wage - county level";


keep fips year femwage malewage race;

rename femwage femwageind;
rename malewage malewageind;
label var femwageind "Female wage - industry changes";
label var malewageind "Male wage - industry changes";
gen lfemwageind=ln(femwageind);
gen lmalewageind=ln(malewageind);
label var lfemwageind "Ln(female wage - industry changes)";
label var lmalewageind "Ln(male wage - industry changes)";
gen ratiow_ind=femwageind/malewageind;
label var ratiow_ind "Female/male wage -industry changes";
gen difw_ind=malewageind-femwageind;
label var difw_ind "Male-female wage - industry changes";


sort fips race year;
save bartik03_industry.dta,replace;






