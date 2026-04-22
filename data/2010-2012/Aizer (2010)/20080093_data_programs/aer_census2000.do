#delimit;
log using aer_census2000.log,replace;
set mem 1000m;

use census2000.dta;
desc;

drop if age<15 | age>64;
keep if gq==1 | gq==2;

rename race raceg;
rename hispan hispang;
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


/* assign industries: service, retail, construction, manufacturing, 
to match with naics codes*/


rename ind indold;
gen naics2=substr(indnaics,1,2);
gen ind=real(naics2);
list ind indnaics indold in 1/10;

tab indold;
tab ind;
drop if ind==0 | ind==99 | ind==. | ind==92;
tab ind;

gen fem_11=0 if fem==1;
replace fem_11=1 if fem==1 & ind==11;
gen fem_21=0 if fem==1;
replace fem_21=1 if fem==1 & ind==21;
gen fem_22=0 if fem==1;
replace fem_22=1 if fem==1 & ind==22;
gen fem_23=0 if fem==1;
replace fem_23=1 if fem==1 & ind==23;
gen fem_31=0;
replace fem_31=1 if fem==1 & (ind>=31 & ind<=33);
gen fem_42=0 if fem==1;
replace fem_42=1 if fem==1 & ind==42;
gen fem_44=0 if fem==1;
replace fem_44=1 if fem==1 & (ind>=44 & ind<=45);
gen fem_48=0 if fem==1;
replace fem_48=1 if fem==1 & (ind>=48 & ind<=49);
gen fem_51=0 if fem==1;
replace fem_51=1 if fem==1 & ind==51;
gen fem_52=0 if fem==1;
replace fem_52=1 if fem==1 & ind==52;
gen fem_53=0 if fem==1;
replace fem_53=1 if fem==1 & ind==53;

gen fem_54=0 if fem==1;
replace fem_54=1 if fem==1 & ind==54;

gen fem_55=0 if fem==1;
replace fem_55=1 if fem==1 & ind==55;

gen fem_56=0 if fem==1;
replace fem_56=1 if fem==1 & ind==56;

gen fem_61=0 if fem==1;
replace fem_61=1 if fem==1 & ind==61;
gen fem_62=0 if fem==1;
replace fem_62=1 if fem==1 & ind==62;

gen fem_71=0 if fem==1;
replace fem_71=1 if fem==1 & ind==71;

gen fem_72=0 if fem==1;
replace fem_72=1 if fem==1 & ind==72;

gen fem_81=0 if fem==1;
replace fem_81=1 if fem==1 & ind==81;

gen fem_92=0 if fem==1;
replace fem_92=1 if fem==1 & ind==92;

tab ind;

/* male*/

gen male=(fem==0);
replace fem=male;

gen male_11=0 if fem==1;
replace male_11=1 if fem==1 & ind==11;
gen male_21=0 if fem==1;
replace male_21=1 if fem==1 & ind==21;
gen male_22=0 if fem==1;
replace male_22=1 if fem==1 & ind==22;
gen male_23=0 if fem==1;
replace male_23=1 if fem==1 & ind==23;
gen male_31=0;
replace male_31=1 if fem==1 & (ind>=31 & ind<=33);
gen male_42=0 if fem==1;
replace male_42=1 if fem==1 & ind==42;
gen male_44=0 if fem==1;
replace male_44=1 if fem==1 & (ind>=44 & ind<=45);
gen male_48=0 if fem==1;
replace male_48=1 if fem==1 & (ind>=48 & ind<=49);
gen male_51=0 if fem==1;
replace male_51=1 if fem==1 & ind==51;
gen male_52=0 if fem==1;
replace male_52=1 if fem==1 & ind==52;
gen male_53=0 if fem==1;
replace male_53=1 if fem==1 & ind==53;

gen male_54=0 if fem==1;
replace male_54=1 if fem==1 & ind==54;

gen male_55=0 if fem==1;
replace male_55=1 if fem==1 & ind==55;

gen male_56=0 if fem==1;
replace male_56=1 if fem==1 & ind==56;
gen male_61=0 if fem==1;
replace male_61=1 if fem==1 & ind==61;
gen male_62=0 if fem==1;
replace male_62=1 if fem==1 & ind==62;
gen male_71=0 if fem==1;
replace male_71=1 if fem==1 & ind==71;

gen male_72=0 if fem==1;
replace male_72=1 if fem==1 & ind==72;

gen male_81=0 if fem==1;
replace male_81=1 if fem==1 & ind==81;

gen male_92=0 if fem==1;
replace male_92=1 if fem==1 & ind==92;

replace fem=(male==0);

keep if educ<=2;
keep if labforce==2;

save temp.dta,replace;

rename fem female;
tab ind;

save tempbartik.dta,replace;
tab ind;

collapse (mean) fem_* male_*, by (fips racecat);

renpfix fem_ femhs_;
renpfix male_ malehs_;

rename racecat race;
sort fips race;
save censusrace2000.dta,replace;


