#delimit;

	**************************************************************************;
	* Create a variable for interview number. Then, strip newid of its       *;
	* interview number (the last digit of newid) so we can combine		 *;
	* CU's over different quarters.						 *;
	**************************************************************************;

	tostring newid, replace;
	
	tempvar len_newid_m1;
	gen `len_newid_m1' = length(newid) - 1;
	
	gen int_num = substr(newid, -1, .);
	replace newid = substr(newid, 1, `len_newid_m1');
	
	*compress;
	
	replace vhome = float(vhome);

exit;