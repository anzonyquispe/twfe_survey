#delimit;

	*Reformat ID vars so they are consistent with those of the main files*; 

tostring newid, replace;
	
tempvar len_newid_m1;
gen `len_newid_m1' = length(newid) - 1;
	
gen int_num = substr(newid, -1, .);
replace newid = substr(newid, 1, `len_newid_m1');

	*Subscript check_variables*;

foreach variable of global all_checkvars {; rename `variable' `variable'_check; };
compress;
   
	 *Drop extra variables*;

local id "newid int_num pre1986 ref_mo ref_yr";
keep  `id' region tdet_*_tia *_check;

exit;