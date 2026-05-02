#delimit;

local proclyr `1';	*i.e., the year being processed;
 
local id_vars "newid ref_yr ref_mo qtr_month tot_exp pre1986";

*-------------------------- Collapse into Year-Month Files -----------------------------*;

 forvalues month = 1/12

	{; 	

	if `month' == 12 & `proclyr' == 2009 {; continue; };

	use I1_exp_ces_int_`proclyr'.dta if ref_yr == `proclyr' & ref_mo == `month', clear;
		
	bysort newid: assert qtr_month[_n] == qtr_month[_n-1] if _n ~= 1;
	bysort newid: assert tot_exp[_n]   == tot_exp[_n-1]   if _n ~= 1;
	assert pre1986 == 0;
		
	levels ucc, local(codes);

	foreach code of local codes {; gen exp_`code' = exp_ if ucc == "`code'"; };
	
	di "Collapsing expenditure data for `proclyr'M`month'";		*Each collapse takes about two minutes;

	collapse (sum) exp_*, by(`id_vars');
	save I1_reshaped_`proclyr'_`month', replace;

	};		


*---------------------------- Append Year-Month Files -----------------------------------*;

clear;
gen dummy = .;

forvalues month = 1/12
	
	{;
	
	if `month' == 12 & `proclyr' == 2009 {; continue; };

	di "Appending expenditure data for `proclyr'M`month'";		
	
	append using I1_reshaped_`proclyr'_`month';	
		
	};

drop dummy;
drop exp_;

save I1_sums_ready_`proclyr'.dta, replace;

exit;