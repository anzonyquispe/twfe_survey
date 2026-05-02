#delimit;

*State flag is year dependent;
*Demographic variables at bottom of file should be checked for consistency;

if ${end_lyr} ~= ${bls_endyr} {; local end_famlyr = ${end_lyr} + 1; }; 	*Adjust end of date range to capture cus; 
		         else {; local end_famlyr = ${end_lyr}; };      *that were asked about their q4 expenditures;
		         						*in q1 of the following year; 
		         						
		         						

clear;
gen y = .;
save CM1_fam_ces_int_${start_syr}_${end_syr}.dta, replace;

	forvalues lyr = $start_lyr/`end_famlyr' 
	
		{;
		
		local yr: piece 2 2 of "`lyr'";
		foreach q of numlist 1/4 
		
			{;
		
			display `yr'`q';
			
			if `lyr' >= 1996 {; use ${syf_root}\\`lyr'\\${iraw_branch}\fmli`yr'`q'.dta, clear; };
			
			if `lyr' >= 1994 & `lyr' <= 1995 
				{; global passthru_lyr = `lyr'; global passthru_qtr = `q'; 
				   do D1_ES_import_famfiles_94to95.do; };
			
			if `lyr' >= 1990 & `lyr' <= 1992 
			
				{; global passthru_lyr = `lyr'; global passthru_qtr = `q'; 
				   do D1_ES_import_famfiles_90to92.do; };
					
			if `lyr' == 1993 {; global passthru_lyr = `lyr'; global passthru_qtr = `q'; 
				   	    do D1_ES_import_famfiles_93.do; };
			
			
			
			if `lyr' < 1990
				{; di "error -- code to import original ascii files does not exist for years prior to 1990"; 
				   crash; };
			          		
            		if ((`lyr' == 2003 & `q' > 1) | `lyr' >= 2004) 
            		
            			{; 
            			
            			rename horref1 origin1;
            			rename horref2 origin2;
            			
            			};
            		
            		*non-imputed versions of fsalaryx, prinearn, inclossa, & inclossb not available in 2004 or 2005;
            		
      			if (`lyr' == 2004 | `lyr' == 2005)
      			
      				{;
      			
      				rename fsalarym fsalaryx;
      				rename prinernm prinearn;
      				rename inclosam inclossa;
      				rename inclosbm inclossb;
      	      
      	      			};
      	      	      	      	 
      	      	      	      	      	      
      			/*
      			** State flag is not available until 1996 and is deleted in 2005
      			*/
      
      			cap gen state_     = "D" if ((`lyr' >= 1982 & `lyr' <= 1995) | `lyr' >= 2005);
      			replace state_ = "T" if ((`lyr' >= 1982 & `lyr' <= 1995) | `lyr' >= 2005) & (state == "" | state == ".");
      			replace state_ = "R" if (`lyr' >= 2005) & (state == "01" | state == "06" | state == "13" |
						      state == "18" | state == "21" | state == "26" |																		
						      state == "27" | state == "28" | state == "32" |																		
						      state == "37" | state == "39" | state == "41" |																		
						      state == "47" | state == "48" | state == "51" |																		
						      state == "55");																		
           		
           		assert inlist(region, "1", "2", "3", "4", "");
           		
           		
			keep newid
					 state
					 state_
					 region
					 inclossa
					 inclossb
					 compbnd
					 compbndx
					 compckg
					 compckgx
					 compsav
					 compsavx
					 compsec
					 compsecx
					 finincx
					 secestx
					 usbndx
					 respstat
					 savacctx
					 ckbkactx
					 fincbtax
					 fincatax
					 fsalaryx
					 incweek1
					 incweek2
					 inc_hrs1
					 inc_hrs2
					 cutenure
					 ref_race
					 race2
					 origin1
					 origin2
					 sex_ref
					 age_ref
					 age2
					 marital1
					 educ_ref
					 educa2
					 no_earnr
					 earncomp
					 prinearn
					 vehq
					 incomey1
					 incomey2
					 nonincmx
					 intearnx
					 finlwt21
					 fam_size
					 perslt18
					 qintrvmo;
					 
			label var state    "State of residence";
			label var state_   "State Flag (D-unaltered, T-suppressed, R-recode)";
			label var region   "Region (1-Northeast 2-Midwest 3-South 4-West)"; 
			label var respstat "Complete income reporters?";
			label var fincbtax "Total CU income before taxes past 12 months";
			label var fincatax "Total CU income after taxes past 12 months";
			label var fsalaryx "Total CU wage or salary income before past 12 months";
			label var incweek1 "Head number of weeks worked past 12 months";
			label var incweek2 "Spouse number of weeks worked past 12 months";
			label var inc_hrs1 "Head hours of work per week";
			label var inc_hrs2 "Spouse hours of work per week";
			label var cutenure "Homeowner";
			label var sex_ref  "Sex of head";
			label var age_ref  "Age of head";
			label var age2     "Age of spouse";
			label var marital1 "Marital status";
			label var no_earnr "Number of earners in CU";
			label var earncomp "Composition of earners";
			label var prinearn "Member number of principal earner";
			label var vehq     "Number of owned vehicles";
			label var incomey1 "Head income source";
			label var incomey2 "Spouse income source";
			label var nonincmx "Other money receipts excluded from fincbtax";
			label var finlwt21 "CU weight";
			label var fam_size "Number of members in CU";
			label var perslt18 "Number of children less than 18 in CU";
			label var ckbkactx "Total amount in checking, brokerage and other similar accounts";
			label var compbnd  "More or less than last year - U.S. Savings bonds";
			label var compbndx "How much more or less - U.S. Savings bonds";
			label var compckgx "How much more or less - checking";
			label var compsav  "More or less than last year - Savings";
			label var compsavx "How much more or less in savings account";
			label var compsec  "More or less than last year - Securities";
			label var compsecx "How much more or less than last year - Securities";
			label var savacctx "Total amount in savings, savings and loans, credit unions and similar accts";
			label var secestx  "Estimated value of securities (stocks, mutual funds, private or govt bonds, Trea";
			label var usbndx   "Total amount in U.S. Savings bonds";
			label var finincx  "Financial income";
			label var inclossa "Income from boarders";
			label var inclossb "Income from rental units";
			label var compckg  "More or less than last year - checking";
			label var intearnx "Interest income";

			*keep if [_n] < 10;
			
			foreach var of varlist state respstat cutenure ref_race race2 origin1 origin2 sex_ref marital1 
			                       educ_ref educa2 earncomp prinearn incomey1 incomey2 compbnd compckg
			                       compsav compsec {; destring `var', replace; };  
			
			gen year = 1900 + `yr' if `yr' >= 82;
			replace year = 2000 + `yr' if `yr' < 82;
			
			gen quarter = `q';
			
			/*
			** Recode variables that change over time so that they are consistent from year to year
			** (ref_race, race2, origin1, origin2)
			** a) ref_race. race2
			**   1) White
			**   2) Black
			**   3) American Indian, Aleut, Eskimo
			**   4) Asian-Pacific Islander
			**   5) Other
			** b) origin1, origin2 will be used to create a Hispanicity 
			**   0) Not of Hispanic origin
			**   1) Hispanic origin 
			** c) educ_ref, educa2
			**   1) Elementary (1-8 yrs.)
			**	 2) High school, less than H.S. graduate
			**	 3) High school graduate
			**	 4) College, less than college graduate
			**	 5) College graduate
			**	 6) Graduate school
			**	 7) Never attended school
			** d) incomey1, incomey2
			**   1)  An employee of a private company,            
			**	     business or individual working               
			**			 for wages or salary                          
			**	 2)  A federal government employee                
			**	 3)  A state government employee                  
			**	 4)  A local government employee                  
			**	 5)  Self-employed in own business,               
			**			 professional practice or farm                
			**	 6)  Working w/o pay in family                    
			**			 business or farm
			*/
			replace ref_race = 4 if ref_race == 5 & ((year == 2003 & quarter > 1) | year >= 2004);
			replace ref_race = 5 if ref_race == 6 & ((year == 2003 & quarter > 1) | year >= 2004);
			
			replace ref_race = 8 if ref_race == 3 & year <= 1987;
			replace ref_race = 9 if ref_race == 4 & year <= 1987;
			replace ref_race = 4 if ref_race == 8 & year <= 1987;
			replace ref_race = 3 if ref_race == 9 & year <= 1987;
			
			replace race2 = 4 if race2 == 5 & ((year == 2003 & quarter > 1) | year >= 2004);
			replace race2 = 5 if race2 == 6 & ((year == 2003 & quarter > 1) | year >= 2004);
					
			replace race2 = 8 if race2 == 3 & year <= 1987;
			replace race2 = 9 if race2 == 4 & year <= 1987;
			replace race2 = 4 if race2 == 8 & year <= 1987;
			replace race2 = 3 if race2 == 9 & year <= 1987;
						
				***************************************************************************;
				* Note that hisp_ref and hisp2 were added to the fmli files in 2009	  *;
				* For the sake of consistency and simplicity, still using the derived	  *;
				* measure. (see A3_2011m7_checks.log for details). In other words,	  *;
				* <hisp2> always refers to the derived variable, as opposed to the bls    *;	
				* variable that is available starting 2009.				  *;
				***************************************************************************;		
						
			gen hisp1 = 0;		
			replace hisp1 = 1 if origin1 == 2 & (year < 2003 | (year == 2003 & quarter == 1));
			replace hisp1 = 1 if origin1 <= 8 & ((year == 2003 & quarter > 1) | year >= 2004);
			
					
			gen hisp2 = 0;
			replace hisp2 = 1 if origin2 == 2 & (year < 2003 | (year == 2003 & quarter == 1));
			replace hisp2 = 1 if origin2 <= 8 & ((year == 2003 & quarter > 1) | year >= 2004);
				
			
			replace educ_ref = 1 if educ_ref == 10 & year > 1995;
			replace educ_ref = 2 if educ_ref == 11 & year > 1995;
			replace educ_ref = 3 if educ_ref == 12 & year > 1995;
			replace educ_ref = 4 if (educ_ref == 13 | educ_ref == 14) & year > 1995;
			replace educ_ref = 5 if educ_ref == 15 & year > 1995;
			replace educ_ref = 6 if (educ_ref == 16 | educ_ref == 17) & year > 1995;
			replace educ_ref = 7 if educ_ref == 00 & year > 1995;
			label var educ_ref "Head educational attainment (1994 CES code)";

			replace educa2 = 1 if educa2 == 10 & year > 1995;
			replace educa2 = 2 if educa2 == 11 & year > 1995;
			replace educa2 = 3 if educa2 == 12 & year > 1995;
			replace educa2 = 4 if (educa2 == 13 | educa2 == 14) & year > 1995;
			replace educa2 = 5 if educa2 == 15 & year > 1995;
			replace educa2 = 6 if (educa2 == 16 | educa2 == 17) & year > 1995;
			replace educa2 = 7 if educa2 == 00 & year > 1995;
			
			replace educa2 = 1 if educa2 >= 1 & educa2 <= 8 & year <= 1987;
			replace educa2 = 2 if educa2 >= 9 & educa2 <= 11 & year <= 1987;
			replace educa2 = 3 if educa2 == 12 & year <= 1987;
			replace educa2 = 4 if educa2 >= 21 & educa2 <= 23 & year <= 1987;
			replace educa2 = 5 if educa2 == 24 & year <= 1987;
			replace educa2 = 6 if educa2 >= 31 & educa2 <= 32 & year <= 1987;
			replace educa2 = 7 if educa2 == 00 & year <= 1987;			
			label var educa2 "Spouse educational attainment (1994 CES code)";
			
			replace incomey1 = 5 if incomey1 == 3 & ((year == 1984 & quarter == 1)| year < 1984);
			replace incomey1 = 6 if incomey1 == 4 & ((year == 1984 & quarter == 1)| year < 1984);

			replace incomey2 = 5 if incomey2 == 3 & ((year == 1984 & quarter == 1)| year < 1984);
			replace incomey2 = 6 if incomey2 == 4 & ((year == 1984 & quarter == 1)| year < 1984);
			
			/*
			** Race/Ethnicity
			** 1 - White, 2 - Black, 3 - Hispanic, 4 - Other
			*/
			gen raceeth1 = 3 if hisp1 == 1;
			replace raceeth1 = 1 if ref_race == 1 & raceeth1 == .;
			replace raceeth1 = 2 if ref_race == 2 & raceeth1 == .;
			replace raceeth1 = 4 if (ref_race > 2 & ref_race != .) & raceeth1 == .;
			label var raceeth1 "Head Race/Ethnicity (1-W 2-B 3-H 4-O)"; 
			
			gen raceeth2 = 3 if hisp1 == 1;
			replace raceeth2 = 1 if race2 == 1 & raceeth2 == .;
			replace raceeth2 = 2 if race2 == 2 & raceeth2 == .;
			replace raceeth2 = 4 if (race2 > 2 & race2 != .) & raceeth2 == .;
			label var raceeth2 "Spouse Race/Ethnicity (1-W 2-B 3-H 4-O)";
						
			*su;
			   
			drop ref_race
			     race2
			     hisp1
			     hisp2
			     year
			     quarter
			     origin1
			     origin2;
			 
			 
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
						
			append using CM1_fam_ces_int_${start_syr}_${end_syr}.dta;

			cap drop y;
			
			save CM1_fam_ces_int_${start_syr}_${end_syr}.dta, replace;

		};
	
	};	
	
	isid newid;  *newid should be unique in this sub-dataset, but for some reason, it occassionally produces duplicates;
		     *This error is hard to trace because it rarely occurs;
	compress;
	sort newid
	     pre1986;
	save CM1_fam_ces_int_${start_syr}_${end_syr}.dta, replace;
	
exit;