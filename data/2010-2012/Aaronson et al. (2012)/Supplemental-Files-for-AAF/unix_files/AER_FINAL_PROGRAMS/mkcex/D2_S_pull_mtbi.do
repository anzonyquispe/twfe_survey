#delimit;

   		*Pull id vars, region, and a few checkvars*;

local endyr_p1 = ${end_yr} + 1;

forvalues year = $start_yr/`endyr_p1'
{;
local syr = `year' - 1900; 
forvalues q = 1/4
{;
	
	use ${syf_root}\\`year'\\${iraw_branch}\mtbi`syr'`q', clear;
	
	gen pre1986 = 0; replace pre1986 = 1 if `year' <= 1985;	
		
	destring ref_mo ref_yr, replace;
	replace ref_yr = ref_yr + 1900;
	
	************************************************************************************;
	* Identify & delete interview month 4 in order to be consistent with original file *;
	************************************************************************************;
	
		sort newid
		     ref_yr
		     ref_mo;
	     
		by newid: gen month_plus_12 = ref_mo;
		by newid: replace month_plus_12 = ref_mo + 12 if ref_mo < 10 & `q' == 1;
	
		by newid: gen qtr_month = 1 +  month_plus_12 - month_plus_12[1];
		
		drop if qtr_month == 4;
	
	*----------------------------------------------------------------------------------*;
	
	************************************************************************************;
	* Divide unique newid-ref_mo-ref_yr combinations into those with an associated	   * 
	* relevant ucc and those without an associated ucc. (This will allow us to work    *;
	* around desktop memory contraints, and will greatly speed up the reshape step     *;
	* in the next subprogram.) 							   *;
	************************************************************************************;
	
	gen relucc_flag = 0;
	foreach ucc of global full_keeplist {; replace relucc_flag = 1 if ucc == "`ucc'"; };
			
	gen  placeholder_flag = 0;
	sort newid pre1986 ref_yr ref_mo relucc_flag;
	by   newid pre1986 ref_yr ref_mo: replace placeholder_flag = 1 if _n == _N & relucc_flag == 0;
	
	keep if relucc_flag == 1 | placeholder_flag == 1;
			
	tempfile mtbi_extract_`year'`q'; 
	save    `mtbi_extract_`year'`q'';

};
};

		*Append quarterly Files*;

clear;
gen dummy = .;

forvalues year = $start_yr/`endyr_p1'
{;
forvalues q = 1/4 
{; 
	
	append using `mtbi_extract_`year'`q''; 

};
};

drop dummy;

keep if (ref_yr >= ${start_yr} & ref_yr <= ${end_yr});

save I2_mtbi_${start_yr}_${end_yr}, replace;

exit;