#delimit;
log using aer_census1990.log,replace;
set mem 1000m;

use census.dta;
desc;

drop if age<15 | age>64;
keep if gq==1 | gq==2;


tab raceg;
gen racecat=1 if raceg==1;
replace racecat=2 if raceg==2;
replace racecat=3 if (hispang>0 & hispang<=4);
replace racecat=4 if (raceg==4 | raceg==5 | raceg==6);
replace racecat=5 if (raceg==7 | raceg==3);

label define racel 1 white 2 black 3 hisp 4 asian 5 other;
label values racecat racel;

gen educ=1 if educ99<=9;
replace educ=2 if educ99==10;
replace educ=3 if educ99>=11 & educ99<=13;
replace educ=4 if educ99>=14;
label define educl 1 lths 2 HS 3 somecol 4 coll;
label values educ educl;

/* gender*/
gen fem=(sex==2);

/* assign fips codes*/
sort puma;
merge puma using pumas.dta;
tab _merge;
keep if _merge==3;
drop _merge;

save temp.dta,replace;

keep if fips==6103;
replace fips=6011;
append using temp.dta;
save temp.dta,replace;
keep if fips==6103;
replace fips=6021;
append using temp.dta;
save temp.dta,replace;
keep if fips==6045;
replace fips=6033;
append using temp.dta;
save temp.dta,replace;
keep if fips==6093;
replace fips=6015;
append using temp.dta;
save temp.dta,replace;
keep if fips==6057;
replace fips=6063;
append using temp.dta;
save temp.dta,replace;
keep if fips==6093;
replace fips=6049;
append using temp.dta;
save temp.dta,replace;
keep if fips==6101;
replace fips=6115;
append using temp.dta;
save temp.dta,replace;

tab ind;
drop if ind==992; /* unemployed*/
drop if ind==. | ind==0;


/* assign industries: service, retail, construction, manufacturing, 
 to match with naics codes*/

gen fem_11=0 if fem==1;
replace fem_11=1 if fem==1 & ind >0 & ind<=32;
gen fem_21=0 if fem==1;
replace fem_21=1 if fem==1 & ind>=40 & ind<=50;
gen fem_22=0 if fem==1;
replace fem_22=1 if fem==1 & ind>=450 & ind<=472;
gen fem_23=0 if fem==1;
replace fem_23=1 if fem==1 & ind==60;
gen fem_31=0;
replace fem_31=1 if fem==1 & ind>=100 & ind<=392;
gen fem_42=0 if fem==1;
replace fem_42=1 if fem==1 & ind>=500 & ind<=571;
gen fem_44=0 if fem==1;
replace fem_44=1 if fem==1 & ind>=580 & ind<=691;
replace fem_44=0 if fem==1 & ind==641;
gen fem_48=0 if fem==1;
replace fem_48=1 if fem==1 & ind>=400 & ind<=432;
gen fem_51=0 if fem==1;
replace fem_51=1 if fem==1 & ind>=440 & ind<=442;
gen fem_52=0 if fem==1;
replace fem_52=1 if fem==1 & ind>=700 & ind<=711;
gen fem_53=0 if fem==1;
replace fem_53=1 if fem==1 & ind==712;

gen fem_54=0 if fem==1;
replace fem_54=1 if fem==1 & ind==721;
replace fem_54=1 if fem==1 & ind==731;
replace fem_54=1 if fem==1 & ind==732;
replace fem_54=1 if fem==1 & ind==740;
replace fem_54=1 if fem==1 & ind==841;
replace fem_54=1 if fem==1 & ind>=882  & ind<=893;

gen fem_56=0 if fem==1;
replace fem_56=1 if fem==1 & ind==722;
replace fem_56=1 if fem==1 & ind==741;

gen fem_61=0 if fem==1;
replace fem_61=1 if fem==1 & ind>=842 & ind<=861;
gen fem_62=0 if fem==1;
replace fem_62=1 if fem==1 & ind>=812 & ind<=840;
replace fem_62=1 if fem==1 & (ind>=862 & ind<=863);
replace fem_62=1 if fem==1 & ind==870;
replace fem_62=1 if fem==1 & ind==871;

gen fem_71=0 if fem==1;
replace fem_71=1 if fem==1 & ind>=800 & ind<=810;
replace fem_71=1 if fem==1 & ind==872;

gen fem_72=0 if fem==1;
replace fem_72=1 if fem==1 & ind==641;
replace fem_72=1 if fem==1 & ind==762;
replace fem_72=1 if fem==1 & ind==770;

gen fem_81=0 if fem==1;
replace fem_81=1 if fem==1 & ind>=742 & ind<=751;
replace fem_81=1 if fem==1 & (ind==760 | ind==761 | ind==752);
replace fem_81=1 if fem==1 & ind>=771 & ind<=791;
replace fem_81=1 if fem==1 & ind>=873 & ind<=881;

gen fem_92=0 if fem==1;
replace fem_92=1 if fem==1 & ind>=900 & ind<=932;
replace fem_92=1 if fem==1 & ind>=940 & ind<=942;
replace fem_92=1 if fem==1 & ind>=950 & ind<=952;
replace fem_92=1 if fem==1 & ind==960;


/* male*/

gen male=(fem==0);
replace fem=male;

gen male_11=0 if fem==1;
replace male_11=1 if fem==1 & ind >0 & ind<=32;
gen male_21=0 if fem==1;
replace male_21=1 if fem==1 & ind>=40 & ind<=50;
gen male_22=0 if fem==1;
replace male_22=1 if fem==1 & ind>=450 & ind<=472;
gen male_23=0 if fem==1;
replace male_23=1 if fem==1 & ind==60;
gen male_31=0;
replace male_31=1 if fem==1 & ind>=100 & ind<=392;
gen male_42=0 if fem==1;
replace male_42=1 if fem==1 & ind>=500 & ind<=571;
gen male_44=0 if fem==1;
replace male_44=1 if fem==1 & ind>=580 & ind<=691;
replace male_44=0 if fem==1 & ind==641;
gen male_48=0 if fem==1;
replace male_48=1 if fem==1 & ind>=400 & ind<=432;
gen male_51=0 if fem==1;
replace male_51=1 if fem==1 & ind>=440 & ind<=442;
gen male_52=0 if fem==1;
replace male_52=1 if fem==1 & ind>=700 & ind<=711;
gen male_53=0 if fem==1;
replace male_53=1 if fem==1 & ind==712;

gen male_54=0 if fem==1;
replace male_54=1 if fem==1 & ind==721;
replace male_54=1 if fem==1 & ind==731;
replace male_54=1 if fem==1 & ind==732;
replace male_54=1 if fem==1 & ind==740;
replace male_54=1 if fem==1 & ind==841;
replace male_54=1 if fem==1 & ind>=882  & ind<=893;

gen male_56=0 if fem==1;
replace male_56=1 if fem==1 & ind==722;
replace male_56=1 if fem==1 & ind==741;

gen male_61=0 if fem==1;
replace male_61=1 if fem==1 & ind>=842 & ind<=861;
gen male_62=0 if fem==1;
replace male_62=1 if fem==1 & ind>=812 & ind<=840;
replace male_62=1 if fem==1 & (ind==862 | ind==863);
replace male_62=1 if fem==1 & ind==870;
replace male_62=1 if fem==1 & ind==871;

gen male_71=0 if fem==1;
replace male_71=1 if fem==1 & ind>=800 & ind<=810;
replace male_71=1 if fem==1 & ind==872;

gen male_72=0 if fem==1;
replace male_72=1 if fem==1 & ind==641;
replace male_72=1 if fem==1 & ind==762;
replace male_72=1 if fem==1 & ind==770;

gen male_81=0 if fem==1;
replace male_81=1 if fem==1 & ind>=742 & ind<=751;
replace male_81=1 if fem==1 & (ind==761 | ind==760 | ind==752);
replace male_81=1 if fem==1 & ind>=771 & ind<=791;
replace male_81=1 if fem==1 & ind>=873 & ind<=881;

gen male_92=0 if fem==1;
replace male_92=1 if fem==1 & ind>=900 & ind<=932;
replace male_92=1 if fem==1 & ind>=940 & ind<=942;
replace male_92=1 if fem==1 & ind>=950 & ind<=952;
replace male_92=1 if fem==1 & ind==960;

replace fem=(male==0);

tab ind;

egen femnum=rsum(fem_*);
tab femnum;
tab ind if femnum==. & fem==1;
tab ind if femnum==0 & fem==1;


rename racecat race;
drop if ind==0 | ind==992 | ind==.;
drop if fips==. | race==.;
save temp.dta,replace;

/* LFP <=HS drop military*/

keep if labforce==2;
keep if educ<=2;
drop if ind==92;

rename fem female;

collapse (mean) fem_* male_*, by (fips race);

renpfix fem_ femhs_;
renpfix male_ malehs_;


label var femhs_11 "women <=HS in LF no military";
sort fips race;
save censusrace.dta,replace;

clear;
use temp.dta;

keep if labforce==2;
keep if educ<=2;

rename fem female;

collapse (mean) fem_* male_*, by (fips race);

renpfix fem_ femhs2_;
renpfix male_ malehs2_;


label var femhs2_11 "women <=HS in LF -with military";
sort fips race;
merge fips race using censusrace.dta;
tab _merge;
drop _merge;
sort fips race;
save censusrace.dta,replace;


desc;
tab race;
tab fips;
sort fips race;
expand 14;
sort fips race;
qui by fips race: gen year=_n;
replace year=1989+year;
tab year;
sort fips year race;
save censusraceyr.dta,replace;
summ;


