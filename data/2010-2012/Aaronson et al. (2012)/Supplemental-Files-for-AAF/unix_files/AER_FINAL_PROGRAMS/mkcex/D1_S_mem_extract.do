#delimit;

*********************************************************************************************************;
* There do not appear to be year-specific procedures/variables in this file, aside from the pre-86 flag *;
*********************************************************************************************************;

if ${end_lyr} ~= ${bls_endyr} {; local end_memlyr = ${end_lyr} + 1; }; 	*Adjust end of date range to capture cus; 
		         else {; local end_memlyr = ${end_lyr}; };      *that were asked about their q4 expenditures;
		         						*in q1 of the following year; 
			
clear;
gen y = .;
save CM1_mem_ces_int_${start_syr}_${end_syr}.dta, replace;


/*
** Read in the quarterly member files. Append each quarterly
** file to previous files.
** Note: As of 3/23/2007, I don't have data for 1985. I have not
** been able to track down the quarterly ASCII member file for 1985
*/;

forvalues lyr = $start_lyr/`end_memlyr' 
	
	{;
		
	local yr: piece 2 2 of "`lyr'";
		
	foreach q of numlist 1/4 
		
		{;
		
		if `lyr' >= 1996 {; use ${syf_root}\\`lyr'\\${iraw_branch}\memi`yr'`q'.dta, clear; };
		
		if `lyr' >= 1990 & `lyr' <= 1995 
			{; global passthru_lyr = `lyr';  global passthru_qtr = `q'; 
			   do D1_ES_import_memfiles_90to95.do; };
		
		if `lyr' < 1990
				{; di "error -- code to import original ascii files does not exist for years prior to 1990"; 
				   crash; };
      		
      		display "`yr'`q'";
      
		if (`lyr' == 2004 | `lyr' == 2005) {; rename salaryxm salaryx; }; *salaryxm, the imputed version of salaryx,; 
									          *replaced salaryx in 2004Q1. In 2006, salaryx was;
									          *readded to the rawdata. Thus datasets after 2006;
									          *contain both versions of salary;
		if (`lyr' >= 2006) {; drop salaryxm; };
		
		keep newid 
				 cu_code 
				 salaryx;
				 
	        *keep if [_n] < 10;

		destring cu_code, replace;

		/*
		** Keep only earnings of the reference person and spouse
		*/
		keep if (cu_code == 1 | cu_code == 2);

		sort newid 
				 cu_code;

		by newid: gen salary1 = salaryx[1];
		by newid: gen salary2 = salaryx[2];
		label var salary1 "Head pre-tax wage or salary income over past 12 months";
		label var salary2 "Spouse pre-tax wage or salary income over past 12 months";

		drop cu_code
				 salaryx;

		by newid: keep if [_n] == 1;
		
		*su;
		
		/*
		** Generate a dummy variable signifying whether the observation comes before
		** or after 1986. In 1986, the newid variable started over at 1. Thus, some
		** newid's before 1986 may be the same as those after. In order to keep these
		** separate, we need a dummy variable specifying whether the observation came
		** before or after 1986.
		*/
      		gen pre1986 = (`yr' >= 82 & `yr' < 86);
      
		/*
		** Append to previous quarterly files
		*/
		append using CM1_mem_ces_int_${start_syr}_${end_syr}.dta;

		cap drop y;

		save CM1_mem_ces_int_${start_syr}_${end_syr}.dta, replace;
		
		};
	
	};

compress;
sort newid pre1986;
save CM1_mem_ces_int_${start_syr}_${end_syr}.dta, replace;

exit;