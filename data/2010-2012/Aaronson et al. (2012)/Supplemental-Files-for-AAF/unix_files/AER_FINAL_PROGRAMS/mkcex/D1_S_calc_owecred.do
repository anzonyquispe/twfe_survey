#delimit;

	********************************************************************************;
	* Adjust cycling to ensure we capture data for cus who had their 2nd interview *;
	* prior to the sequence start date, as well as cus who had their 5th	       *; 	
        * interview after the sequence end date.				       *;
        ********************************************************************************;

local start_oclyr = ${start_lyr} - 1;
if ${end_lyr} ~= ${bls_endyr} {; local end_oclyr = ${end_lyr} + 1; };
		         else {; local end_oclyr = ${end_lyr}; }; 

forvalues lyr = `start_oclyr'/`end_oclyr' 
{;
forvalues q = 1/4
{;
	
	local syr: piece 2 2 of "`lyr'"; 

	use ${syf_root}\\`lyr'\\${iraw_branch}\mtbi`syr'`q'.dta, clear;
	keep if inlist(ucc, "006001", "006002");
	
	gen owe_cred2 = cost if ucc == "006001";
	gen owe_cred5 = cost if ucc == "006002";
	
	gen mtbi_source = "`syr'`q'";
	
	gen pre1986 = 0; replace pre1986 = 1 if `lyr' < 1986;	
	
	tempfile owecred_`syr'`q'; 

	save `owecred_`syr'`q''; 
		
};
};

	* Append owe_cred info *;

 
clear;
gen dummy = .;

forvalues lyr = `start_oclyr'/`end_oclyr' 
{;
forvalues q = 1/4
{;

	local syr: piece 2 2 of "`lyr'"; 

	append using `owecred_`syr'`q'';

};
};

drop dummy;

	******************************************************************************;
	* Amount owed to creditors only appears on at most one observation	     *;	
	* for the household. Apply this value to each observation for the household. *;
	*									     *;	
	* To identify the same CU over different quarters, create a variable for     *;	 
	* interview number. Then, strip newid of its interview number  		     *;
	* (the last digit of newid).						     *;
	******************************************************************************;

tempvar s_newid len_newid_m1 int_num cuid;

tostring newid, gen(`s_newid');
	gen `len_newid_m1' = length(`s_newid') - 1;
	gen `int_num' = substr(`s_newid', -1, .);
	gen `cuid'   = substr(`s_newid', 1, `len_newid_m1');
	
assert `int_num' == "2" if owe_cred2 ~= .; 
assert `int_num' == "5" if (owe_cred5 ~= . & `cuid' ~= "72008");
	assert `cuid' == "72008" if `int_num' == "4";
	replace owe_cred5 = . if `int_num' == "4";   *Eariler versions adjust for this anomaly;	 

collapse (sum) owe_cred2 owe_cred5, by(`cuid' pre1986);

	*************************************************************************
	* <<isid `cuid' pre1986 `int_num' ref_yr ref_mo>> not necessarily true  *;
	* before the collapse, as cus may report cc debt on more than one cc in *;
	* a given interview.  							*;
	*************************************************************************

label var owe_cred2 "Total amount owed to creditors, 2nd interview"; 
label var owe_cred5 "Total amount owed to creditors, 5th interview"; 

gen newid = `cuid';

sort newid pre1986;

save CM1_owecred_${start_syr}_${end_syr}, replace;

exit;