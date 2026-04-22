************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

************************************************************************
************************************************************************
***THIS CODE IS BASED OFF HUNT'S IMPORTASI .DO FILE FROM PREVIOUS WORK
***USED TO FIND & EXTRACT LINE ITEMS IN THE DATA BLOCKS

do "$do/subroutines/extract 1998 panelIDs_new.do"

/* 1998-1999 Data */
*** Block A;
# delimit ;
clear;
use in9899_a.dta;
gen begyr=1998;
gen endyr=1999;

* First fix some NIC98 codes in the data for 1998, based on the 4-digit sampling code. 1400-1500 is correct (ag,hunting,fishery) but everything 
* else that has less than five digits is missing or shortened.;
replace nic98 = nic98_4*10 if nic98<10000&(nic98>=1500|nic98<1400);

sort dsl;
save "$work/temp.dta", replace;

*** Block B;
#delimit ;
clear;
use in9899_b.dta;

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;

*** Block C;
* Note that a couple of these can't be read, but they are not used; 
#delimit ;
clear;
use in9899_c.dta;
keep if Serial==9;

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;

** Block D: Working Capital and Loans;
# delimit ;
clear;
use in9899_d.dta; 

/*
gen dsl = real(substr(v1,4,5));
gen Serial = real(substr(v1,9,2));


gen opening = real(subinstr(substr(v1,11,12)," ","0",12));
replace opening = -1*real(subinstr(subinstr(substr(v1,11,12)," ","0",12),"-","0",1)) if opening == .;

gen closing = real(subinstr(substr(v1,23,12)," ","0",12));
replace closing = -1*real(subinstr(subinstr(substr(v1,23,12)," ","0",12),"-","0",1)) if closing == .;
*/
gen Block ="D" /* to recycle the old code */;
gen rmstop = cond(Block=="D"&Serial==4,opening,.);
gen rmstcl = cond(Block=="D"&Serial==4,closing,.);
gen sfgstop = cond(Block=="D"&Serial==5,opening,.);
gen sfgstcl = cond(Block=="D"&Serial==5,closing,.);
gen stfgop = cond(Block=="D"&Serial==6,opening,.);
gen stfgcl = cond(Block=="D"&Serial==6,closing,.);
gen invopen = cond(Block=="D"&Serial==7,opening,.);
gen invclose = cond(Block=="D"&Serial==7,closing,.);


collapse (sum) rmstop rmstcl sfgstop sfgstcl stfgop stfgcl invopen invclose, by(dsl) ;

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;



*** Block E: Labor;
#delimit ;
clear;
use in9899_e.dta;

gen men = cond(slno==1,averagenumber,0);
gen women = cond(slno==2,averagenumber,0);
gen children = cond(slno==3,averagenumber,0);
gen contractors = cond(slno==5,averagenumber,0);
gen white = cond(slno==7,averagenumber,0);
gen otheremp = cond(slno==8,averagenumber,0);
gen totpersons = cond(slno==9,averagenumber,0);
collapse (sum) men women children contractors white otheremp totpersons, by(dsl);

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;

*** Block F: Other Expenses;
#delimit ;
clear;
use in9899_f.dta;

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;

/** Block G (Other output/Receipts);
* Note that this needs to be read in as text and deciphered as below,
as there is a minus in the middle of many of the columns, plus missing columns in the data;
* So replace all spaces with zeros, and multiply by -1 anything that has a minus sign.

# delimit ;
clear;
insheet using "ASI/98-99/block98g.txt", comma clear;
gen dsl = real(substr(v1,4,5));

gen servinc = real(subinstr(substr(v1,9,12)," ","0",12));
replace servinc = -1*real(subinstr(subinstr(substr(v1,9,12)," ","0",12),"-","0",1)) if servinc == .;

gen incrstsfg = real(subinstr(substr(v1,21,12)," ","0",12));
replace incrstsfg = -1*real(subinstr(subinstr(substr(v1,21,12)," ","0",12),"-","0",1)) if incrstsfg == .;

gen velecsold = real(subinstr(substr(v1,33,12)," ","0",12));
replace velecsold = -1*real(subinstr(subinstr(substr(v1,33,12)," ","0",12),"-","0",1)) if velecsold == .;

gen ownconstr = real(subinstr(substr(v1,45,12)," ","0",12));
replace ownconstr = -1*real(subinstr(subinstr(substr(v1,45,12)," ","0",12),"-","0",1)) if ownconstr == .;

gen otherop = real(subinstr(substr(v1,69,12)," ","0",12));
replace otherop = -1*real(subinstr(subinstr(substr(v1,69,12)," ","0",12),"-","0",1)) if otherop == .;

gen vsamecond = real(subinstr(substr(v1,81,12)," ","0",12));
replace vsamecond = -1*real(subinstr(subinstr(substr(v1,81,12)," ","0",12),"-","0",1)) if vsamecond == .;

drop v1;

sort dsl; 
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;
*/

*** Block H: Input Items;
# delimit ;
clear;
use in9899_h.dta;
** Note that some of the 9990? and 9920? itemcodes are only four digits long, as they are missing the zero. This could be fixed if ever needed;

gen qeleccons = cond(slno==10|slno==11,qcons,0);
gen veleccons = cond(slno==10|slno==11,vcons,0);
gen voilcons = cond(slno==12,vcons,0);
gen qcoalcons = cond(slno==13,qcons,0);
gen vcoalcons = cond(slno==13,vcons,0);
gen votherfuelcons = cond(slno==14,vcons,0);

gen htotalinput = cond(slno==17,vcons,0);

collapse (sum) qeleccons veleccons voilcons qcoalcons vcoalcons votherfuelcons htotalinput, by(dsl);

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;

/* Block I: Imported Items */; 
# delimit ;
clear;
use in9899_i.dta;
keep if slno==7;
keep dsl vcons;
rename vcons itotalinput;

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
sort dsl;
save "$work/temp.dta", replace;


*** Block J: Product and By-Products;
# delimit ;
clear;
use in9899_j.dta;
* This keeps only the "total" amount:;
keep if slno == 12;

sort dsl;
merge dsl using "$work/temp.dta";
drop _merge;
*save asi9899.dta, replace;

** Finish prepping dataset;
# delimit ;
**servinc  incrstsfg velecsold ownconstr  otherop  vsamecond totalotherexp purchasevsamecond  ;
foreach var in  qmanufactured qsold grsale exciseduty salestax others distrexp nsv efv itotalinput
men women children contractors white otheremp totpersons rmstop rmstcl sfgstop sfgstcl stfgop stfgcl invopen invclose grossopening   additiontogrossfcfromrevaluation grossactualaddition grossdeductionandadj grossclosing depn fcapopen fcapclose  {;
	replace `var' = 0 if `var'==.;
};


*include ComputeSums.do;

erase "$work/temp.dta";

# delim cr
qui {
noi count
	***********STATE CODES
	g year=1997
	merge m:1 stcode year using "$work/statecodes"
	drop if _m==2
	drop if _m==1
noi count
	drop _m
	rename state statename
	tab statename
	
drop if grsale==. | grsale<2
noi count


tab opclcode, mi
keep if opclcode==1
noi count
}

g state_consistent=statename
replace state_consistent="BIHAR" if statename=="JHARKHAND"
replace state_consistent="MADHYA PRADESH" if statename=="CHHATTISGARH"
replace state_consistent="UTTAR PRADESH" if statename=="UTTARANCHAL" 


*nic98_4 inityr 

bys state_consistent schcode grsale fcapopen fcapclose : g rank2=_N
tab rank2 
drop if rank2>1
keep state_consistent schcode grsale fcapopen fcapclose permid
count
merge 1:1 state_consistent schcode grsale fcapopen fcapclose  using asi_plant_panel_cleanset_formatch.dta

preserve
keep if _m==3
tempfile matched cap
save `matched'
restore

foreach i in grsale fcapopen fcapclose  {
g `i'_cap=`i'
}

***loop get all possible matches
drop if _m==3
foreach i in grsale fcapopen fcapclose  {
replace `i'_cap=floor(`i'_cap/10)
}
preserve
keep if _m==2
drop _m grsale fcapopen fcapclose permid
save `cap', replace
restore
keep if _m==1
drop permid_1998
drop _m
noi merge 1:1 state_consistent schcode grsale_cap fcapopen_cap fcapclose_cap using `cap'
tab _m
count if _m!=3
assert r(N)==4 // there are only four nonmatches between both datasets
keep if _m==3
append using `matched'
drop *_cap

///note that the new firm IDs use the old formats---they are almost exactly the same except for the state code! (except for 16 records in RAJ & 1 in TN
g check = substr(string(permid_1998),1,length(string(permid_1998))-2)
destring check, replace
g check2=check==permid
tab check2
tab state_con if check2==0
drop _m check check2
//well--use the matching anyway, at least for the 17 extra records


bys state_consistent permid: g rank=_N
tab rank
tab rank schcode
drop if rank==2 /*this ensures uniqueness of the plants. we lose about 80 plants in the census scheme, probably due to an original entry typo incurring a dupe panel ID*/

drop rank

keep state_consistent perm*
foreach blk in a b c d e f g h i j {
cap erase in9899_`blk'.dta
}
save "$work/1998 matched Panel IDs.dta", replace



