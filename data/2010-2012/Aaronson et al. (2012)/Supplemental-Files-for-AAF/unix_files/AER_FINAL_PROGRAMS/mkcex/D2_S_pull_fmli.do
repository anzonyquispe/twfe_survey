#delimit;

local check_vars ${fmli_checkvars}; 
local endyr_p1 = ${end_yr} + 1;

 		*Pull id vars, region, and a few checkvars*;

forvalues year = $start_yr/`endyr_p1'
{;
local syr = `year' - 1900; 
forvalues q = 1/4
{;
	
	use newid region `check_vars' using  ${syf_root}\\`year'\\${iraw_branch}\fmli`syr'`q', clear;
	
	gen pre1986 = 0; replace pre1986 = 1 if `year' <= 1985;	
	
	assert inlist(region, "1", "2", "3", "4", ""); 
		
	tempfile fmli_extract_`year'`q'; 
	save  `fmli_extract_`year'`q'';

};
};
		*Append quarterly Files*;

clear;
gen dummy = .;

forvalues year = $start_yr/`endyr_p1'
{;
local syr = `year' - 1900; 
forvalues q = 1/4 
{; 

	append using `fmli_extract_`year'`q''; 

};
};

drop dummy;

isid newid pre1986;

save I2_fmli_${start_yr}_${end_yr}, replace;

exit;