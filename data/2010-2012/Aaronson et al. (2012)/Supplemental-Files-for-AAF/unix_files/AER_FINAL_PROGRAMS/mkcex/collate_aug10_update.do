#delimit;
macro drop _all;
cap log close;

log using cex_aug10_update, replace;
 
	*************************************************************************;
	* This program integrates various portions of the the CEX minimum wage  *;
       * dataset into a single file.						  *;
       *  										  *;
	* Please see <<cex_82010_readme.txt>> for details.  			  *;
	*************************************************************************;
   
 	*----------- Settings ------------*;

global bin       "/home/ddifranc/minwage_fordan/aug10_update/bin";
global dir_2009  "/home/ddifranc/minwage_fordan/2009_update"; 

global CD1_startyr 1991; global CD1_endyr 2008;
global CD2_startyr 1982; global CD2_endyr 1990;

global id "newid pre1986 int_num ref_mo ref_yr"; 

	*---------- Collate files  -------*;

		*--- 1991 - 2008 ---*;

clear;
gen dummy = .;

forvalues year = $CD1_startyr/$CD1_endyr {; append using ${bin}/CD1_ces_int_`year'; };
	drop dummy __000003;   
	des, short;
	assert `r(k)' == 136 ; 		*i.e.,  The original 123 variables + the 12 new trade-in allowance variables;
	tempfile CD1;				* +  the region variable;
save `CD1';

		*--- 1982 - 1990 ---*;
	
use ${dir_2009}/ces_int_82_08_v2009 if (ref_yr >= ${CD2_startyr} & ref_yr <= ${CD2_endyr}), clear;
merge 1:1 ${id} using ${bin}/CD2_aug10_additions_1982_1990; 
 	count if _merge ~= 3; 
 	assert `r(N)' == 3;					
	assert (newid == "4011" & int_num == "5") if _merge ~= 3; 	*Three exceptions, all relating to newid <<4011>>;
 	drop _merge;
 	drop *_check;
	des, short;
 	assert `r(k)' == 134; 		*two less than the 1991-2008 group, as two trade-in allowance uccs;
 	tempfile CD2;		       	*were added in 1994;
save `CD2';
		*-- Other ref_yrs --*;

use ${dir_2009}/ces_int_82_08_v2009 if (ref_yr > ${CD1_endyr} | ref_yr < ${CD2_startyr}), clear;

append using `CD1';
append using `CD2';

des, short;
assert `r(k)' == 136;
assert `r(N)' == 1946660;

compress;

save ces_int_82_08_v2010, replace;

log close;

exit;