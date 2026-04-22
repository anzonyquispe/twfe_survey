#delimit;
log using makeall03_aer.log,replace;
set mem 900m;
set matsize 800;


/* merge:

hosp2_2003.dta - assaults
demogb03.dta - population counts
cadv_2003.dta - intimate and non-intimate violence
unempinc03.dta - unemployment and income 
mmigration.dta - immigration data
ccenroll.dta - college enrollment data
clinicall.dta - primary care clinic data
malearrests1990-2003.dta - male arrests for domestic violence
shelters.dta - DV shelter data
drugs1990-2003.dta - admissions for drug rehab data

*/


use hosp2_2003.dta;

sort fips year race;
merge fips year race using demogb03.dta;
tab _merge;
keep if _merge==3;
drop _merge;

sort fips year race;
merge fips year race using cadv_2003.dta;
tab _merge;
drop _merge;

sort fips year;
merge fips year using immigration.dta;
tab _merge;
drop _merge;

sort fips year;
merge fips year using unempinc03.dta;
tab _merge;
drop _merge;

drop if year<1990 | year>2003;


replace batter=0 if batter==.;

gen fassuni_r=(fassault+funint)*100000/fempop;
gen massuni_r=(massault+munint)*100000/malepop;

gen fass_r=fassault*100000/fempop;
gen mass_r=massault*100000/malepop;

gen fmv=fmvdriver+fmvped;
gen mmv=mmvdriver+mmvped;


gen lfmv=ln(fmv); 
gen lmmv=ln(mmv);
label var lfmv "Ln(female mv)";
label var lmmv "Ln(male mv)";

gen fmv_r=fmv*10000/fempop;
gen fsui_r=fsuicide*100000/fempop;
gen msui_r=msuicide*100000/malepop;

gen funi_r=funint*100000/fempop;
gen muni_r=munint*100000/malepop;

gen fass_er=fassault/fer;
gen mass_er=massault/fer;

gen fass_inj=fassault/fanyinj;
gen mass_inj=massault/manyinj;

gen fnainj=fanyinj-fassault-batter;
gen lfnainj=ln(fnainj);
label var fnainj "Female non-assault injuries";
label var lfnainj "Ln(female non-assault injuries)";

gen mnainj=manyinj-massault;
gen lmnainj=ln(mnainj);
label var mnainj "Male non-assault injuries";
label var lmnainj "Ln(male non-assault injuries)";


gen fnaer_r=(fer-fassault)*100000/fempop;
gen fnainj_r=(fanyinj-fassault-batter)*100000/fempop;

gen mnaer_r=(mer-massault)*100000/malepop;
gen mnainj_r=(manyinj-massault)*100000/malepop;

gen fass_m=fassault/massault;

gen lfass=ln(fassault);
gen lmass=ln(massault);

sort fips race year;
by fips race: gen laglfass=lfass[_n-1];
by fips race: gen laglmass=lmass[_n-1];
by fips race: gen laglfmv=lfmv[_n-1];
label var laglfass "Lag ln(female assaults)";
label var laglmass "Lag ln(male assaults)";
label var laglfmv "Lag ln(female mv)";

gen lmnainj_r=ln((manyinj-massault)*100000/malepop);
gen lfnainj_r=ln((fanyinj-fassault)*100000/fempop);
gen lfnainj_m=ln((fanyinj-fassault)/(manyinj-massault));


/* no gun*/

gen fassng_r=fassaultng*100000/fempop;
gen massng_r=massaultng*100000/malepop;
gen lfassng=ln(fassaultng);
gen lmassng=ln(massaultng);

gen lfassng_m=lfassng/lmassng;

gen fassng_inj=fassaultng/fanyinj;
gen massng_inj=massaultng/manyinj;
gen fassng_er=fassaultng/fer;
gen massng_er=massaultng/fer;
gen fassng_m=fassaultng/massaultng;


gen lpercap=ln(percapinc);
gen limmig=ln(immigra);

cap drop fipsyr;
gen double fipsyr=fips+(year-1900)/1000;


tab race;
gen white=race==1;
gen black=race==2;
gen hisp=race==3;
gen asian=race==4;

keep ur percapinc lpercap nonint immigr limmig 
fass* fna* pregass* batter* lfass* mass* mna* mmv* lmass* lfna*
lmna* race black white hisp asian year fips fipsyr fempop malepop
funi* fsui* fanyinj* manyinj* mdv fdv lag* fmv* lfmv;


label var fass_r "Female assaults";
label var mass_r "Male assaults";
label var limmig "Ln(immigration)";
label var lpercap "Ln(per capita income)";
label var black "Black";
label var hisp "Hispanic";
label var asian "Asian";




drop if fips==6000;

replace black=0 if race~=2;
replace hisp=0 if race~=3;
drop if race>4;
cap drop asian;
gen asian=race==4;
label var asian "Asian";

/* make assault variables*/

gen fnainj_m=((fanyinj-fassault)/(manyinj-massault));
gen lfass_m=ln(fass_m);
gen lfinj_m=ln(fanyinj/manyinj);
label var fnainj_r "Female/male non-assault injuries";
label var fnainj_m "Non-assault injuries";
label var mnainj_r "Non-assault injuries";
label var fass_inj "Female assaults/injuries";

replace fass_r=0 if fass_r==.;
replace mass_r=0 if mass_r==.;
replace fass_m=0 if fass_m==.;
replace fass_inj=0 if fass_inj==.;
replace mass_inj=0 if mass_inj==.;
replace fass_er=0 if fass_er==.;
replace funi_r=0 if funi_r==.;
replace fsui_r=0 if fsui_r==.;

gen lnonint=ln(nonint);
replace lnonint=0 if lnonint==.;
label var lnonint "Ln(non-intimate homicides)";
gen nonint_r=nonint*1000/(fempop+malepop);

label var nonint_r "non-intimate homicide rate per 1000";
label var mass_inj "Male Assault/Injuries";
label var lfnainj_m "Ln(female assaults/injuries/ male assaults/injuries)";
gen fass_rr=fassault/massault;


gen assratio=fassault/massault;
gen popratio=fempop/malepop;
label var popratio "female/male population";

gen assratio2=(fass_inj/mass_inj);
label var assratio2 "Female/male assaults/injuries";
label var lmass "Ln(male assaults)";
label var lfinj_m "Ln(Female injuries/male injuries)";

label var ur "Unemployment rate";

/* student data*/
cap drop _merge;
sort fips year race;
merge fips year race using ccenroll.dta;   
tab _merge;
drop _merge;

egen femstudent=rsum(femccstudent femcsstudent);
egen malestudent=rsum(maleccstudent malecsstudent);

replace femstudent=0 if femstudent==.;
replace malestudent=0 if malestudent==.;

gen lstudent=ln(femstudent/malestudent);
gen lfemstudent=ln(femstudent);
gen lmalestudent=ln(malestud);
gen studentratio=femstudent/malestudent;
label var studentratio "Female/male college students";


/* clinic data*/

cap drop _merge;
sort fips year;
merge fips year using clinicall.dta;
replace totpat=0 if _merge==1;
replace num=0 if _merge==2;
tab _merge;
drop if _merge==2;
drop _merge;

gen racepat=whitept if white==1;
replace racepat=blackpt if black==1;
replace racepat=hisppt if hisp==1;
replace racepat=asianpt if asian==1;
replace racepat=otherpt if race==5;
replace racepat=racepat/1000;

/* shelter data*/

cap drop _merge;

sort fips year;
merge fips year using shelters.dta;
tab _merge;
drop _merge;
replace num=num/fempop*1000;
label var sheltrat "DV Shelters per 10,000";
label var num "Primary Care Clinics per 1000 women";
label var totpat "Total primary care clinic patients";
label var racepat "Primary care clinic patients/1000";


/* incarceration data*/
cap drop _merge;
sort fips year race;
merge fips year race using caincar1990-2003.dta;
tab _merge;
drop if _merge==2;
replace admit=0 if admit==.;
replace release=0 if release==.;
replace admitage=0 if admitage==.;
replace releaseage=0 if releaseage==.;
gen incar=admit-release;
gen incarage=admitage-releaseage;
gen incar_r=incarage/malepop*10000;
summ incar incar_r;
table race, c (mean incar_r);
table year, c (mean incar_r);
label var incar_r "Incarceration flows per 10,000 males";
gen lincar=ln(incar);
label var incar "Incarceration flows";
label var lincar "Ln(incarceration flows)";

count if lincar==.;

drop _merge;
drop if year<1990;
drop if year>2003;
drop if race>4;

sort fips year;
merge fips year using malearrests1990-2003.dta;
tab _merge;
drop _merge;

gen marr=wmarr if race==1;
replace marr=bmarr if race==2;
replace marr=hmarr if race==3;
replace marr=omarr if race==4;

gen marr_r=marr/malepop;
gen lmarr=ln(marr);
label var lmarr "Ln(arrests for DV)";
label var marr "male arrests for DV";
label var marr_r "Arrest rate for DV";

sort fips race year;
by fips race: gen laglmarr=lmarr[_n-1];
label var laglmarr "Lagged ln(arrests for DV)";

gen byear=black*year;
gen ayear=asian*year;
gen hyear=hisp*year;
label var byear "Black linear time trend";
label var ayear "Asian linear time trend";
label var hyear "Hispanic linear time trend";

local x=6001;
while `x'<=6115 {;
gen cty`x'lin=0;
replace cty`x'lin=year-1989 if fips==`x';
local x=`x'+1;
};

gen totpop=malepop+fempop;
label var totpop "Total population";

gen ltotpop=ln(totpop);
label var ltotpop "Ln(total population)";


/* intimate partner homicides*/

replace fdv=0 if fdv==.;
replace mdv=0 if mdv==.;
gen tdv=fdv+mdv;

label var fdv "Female intimate partner homicide";
label var mdv "Male intimate partner homicide";
label var tdv "Total intimate partner homicide";

gen fdv_r=fdv*10000/fempop;
gen mdv_r=mdv*10000/malepop;
gen tdv_r=tdv*10000/totpop;

label var fdv_r "Rate of female intimate partner homicide";
label var mdv_r "Rate of male intimate partner homicide";
label var tdv_r "Rate of total intimate partner homicide";


gen lfdv=ln(fdv);
gen lmdv=ln(mdv);
gen ltdv=ln(tdv);
label var lfdv "Ln(female intimate partner homicide)";
label var lmdv "Ln (male intimate partner homicide)";
label var ltdv "Ln(total intimate partner homicide)";

sort fips race year;
by fips race: gen lagfdv_r=fdv_r[_n-1];
by fips race: gen lagmdv_r=mdv_r[_n-1];
by fips race: gen lagtdv_r=tdv_r[_n-1];
label var lagfdv_r "Lag female intimate partner homicide rate";
label var lagmdv_r "Lag male intimate partner homicide rate";
label var lagtdv_r "Lag total intimate partner homicide rate";

gen lmalepop=ln(malepop);
label var lmalepop "Ln(male population)";
gen lfempop=ln(fempop);
label var lfempop "Ln(female population)";
label var ltotpop "Ln (total population)";

/* add drugs data */
cap drop _merge;
sort fips year;
merge fips year using drugs1990-2003.dta;
tab _merge;
drop if _merge==2;
drop _merge;

gen drugadm=whitedrug if race==1;
replace drugadm=blackdrug if race==2;
replace drugadm=hispdrug if race==3;
replace drugadm=otherdrug if race==4;
label var drugadm "Drug admissions";
drop whitedrug blackdrug hispdrug otherdrug;
replace drugadm=0 if drugadm==.;

gen ldrug=ln(drugadm);
label var ldrug "Ln(drug admissions)";
gen drug_r=drugadm*10000/totpop;
label var drug_r "Drug admission rate";

sort fips race year;
by fips race: gen lagldrug=ldrug[_n-1];
by fips race: gen lagdrug=drugadm[_n-1];

label var lagldrug "Lagged ln(drug admissions)";
label var lagdrug "Lagged drug admissions";


save dataall03_aer.dta,replace;

clear;


