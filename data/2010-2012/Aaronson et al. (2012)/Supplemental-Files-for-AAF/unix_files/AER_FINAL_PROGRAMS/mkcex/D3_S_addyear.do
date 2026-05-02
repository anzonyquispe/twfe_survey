#delimit;
	
local proc_lyr `1';
local proc_lyr_p1 = `proc_lyr' + 1;
local proc_syr: piece 2 2 of "`proc_lyr'";

local version `2';
cap assert inlist("`version'", "main_version", "check_version"); 
if _rc ~= 0 {; di as error "Please specify version as <main_version> or <check_version>"; crash; };   
	
local update `3';
assert inlist("`update'", "2010m10", "2011m7");	     
	
	************* Read in yearly ovb files  *******************;
	
	*----------------------------------------------------------*;
	* Import instructions are conditional on year. 	           *;   	
	*						           *;	
	* Note that the <vfinance> and <fin_inst> variables 	   *;
	* are useful for differentiating <no> responses to the     *;
	* home equity question from <missing> ones, as they're     *;
	* both part of the skip pattern that leads up to it.       *;
	* <vfinance> is, however, unavailable prior to 2003Q2,     *;
	* and <fin_inst> is unavailable in 2008. As such,          *;
	* observations for these years are more likely to be       *;
	* assigned to the <missing> home equity category than      *;
	* years for which we have access to the full skip pattern. *;	  
	*----------------------------------------------------------*;

		*-------------- 2002 & Prior -------------*; 

if `proc_lyr' <= 2002 

 	{;

        use newid  ${ovb_ilist} fin_inst using ${ovb_dir}/ovb`proc_syr', clear; 
	
	gen vfinance = ""; 			
							
	};					
	
	       *------------- 2004 (Special Case) --------*;	 	

if `proc_lyr' == 2004  

	{;

		*------------------------------------------------------------------------------*;
		* Pulling in records from the ovb05 file, as cross-checks with the main file   *;
		* suggest that the obv04 file is missing some of the 2005q1 records that       *;
		* pertain to the 2004 reference period.			 		       *;  	
		*									       *;
		* (Note that tabulating <qyear> in the ovb04 and ovb05 makes it appear as      *;	  
		* though it is the ovb05 file that is missing records. However, 	       *;	
		* cross tabulating the total vehicle count implied by the 04 and 05 ovb files  *;	
		* with <vehq> from the respective fmli files suggests that the problem file    *;	
		* is in fact ovb04. It must be that, even though ovb05 has a lower than        *;	
		* expected record count for 2005q1, it captures those records that overlap     *; 
		* with the 2005 reference period.)					       *;
		*------------------------------------------------------------------------------*;	
		
	use newid  ${ovb_ilist}  vfinance fin_inst using ${ovb_dir}/ovb04, clear; 	
	
	isid newid seqno;
	
	append using ${ovb_dir}/ovb05, keep(newid ${ovb_ilist} vfinance fin_inst);					
		
	drop if inlist(qyear, "20052", "20053", "20054", "20061");  

		*-----------------------------------------------------------------------------------*;
		* newid & seqno should uniquely identify records across years. There are some       *; 
		* cases where appending ovb05 data results in duplicates with respect to 	    *;
		* newid & seqno. They appear to be true duplicates in the sense that all the other  *; 
		* imported fields (except, for some reason, <vehpurmo>) also match. 		    *;		 
		*-----------------------------------------------------------------------------------*;  
		  
	foreach variable of varlist * {; local check_fields `check_fields' `variable'; };	  

	local skip_fields "qyear newid seqno vehpurmo";  
	
	local check_fields: list local(check_fields) - local(skip_fields);    
	
	foreach check_field of local check_fields 

				{;
		
				bysort newid seqno: assert `check_field' == `check_field'[_n-1] if _n ~= 1;
							
				};  	

		*----------------------------------------------------------------------------------*;
		* There are some cases where the purchase month associated with what appears 	   *;
		* to be the same vehicle does not match. Fortunately, this only happens 14 times.  *;
		* In these cases, keep the latest non-missing purchase month so that, in the worst *;
		* case scenario, a vehicle is tagged as new when it should be tagged as already	   *;
		* in inventory.									   *;
		*----------------------------------------------------------------------------------*;

	bysort newid seqno: gen vehpurmo_conflict = 1 if vehpurmo ~= vehpurmo[_n-1] & _n ~= 1;
	quietly count if vehpurmo_conflict == 1;
	assert `r(N)' == 14;
	drop vehpurmo_conflict;

	gsort newid seqno vehpurmo, mfirst;

	by newid seqno: keep if _n == _N;
        
	isid newid seqno; 
	
	};
		
		*----------- 2003 & 2005-2007  ------------*;
	
if inlist(`proc_lyr', 2003, 2005, 2006, 2007)
	
	{; 
	
	use newid ${ovb_ilist} vfinance fin_inst using ${ovb_dir}/ovb`proc_syr', clear; 
	
	if `proc_lyr' == 2003 
	
		{;
	
		assert vfinance == "" if qyear == "20031";
		quietly count if vfinance ~= "" & qyear == "20032";
		assert r(N) ~= 0;
		
		};
		
	};
	
		*---------- 2008 & 2009 ---------------------*;

if inrange(`proc_lyr', 2008, 2009)
	

	{;

	use newid ${ovb_ilist} vfinance using ${ovb_dir}/ovb`proc_syr', clear; 
	
	gen fin_inst = "";
	
	};
	

	******************* Process ovb files *****************************;

	      *-------------------------------------------------*;
	      * Separate recently purchased vehicles from       *; 
	      * those in inventory in an attempt to evenutally  *;
	      * match funding source details to expenditures in *;
	      * the mtbi files.                                 *;
	      *	 						*;
	      *	Note that the ovb file does not contain enough  *;
	      *	info by itself to id the timing of the cus      *;
	      * 3-mo reference period. To deal with  		*; 
	      *	this, cast a wide net to capture purchases      *;
	      *	that *might* have been puchased during the      *;
	      *	reference period, and then pare down the        *;
	      * hypothetical records based on the results of    *;
	      * the merge with the main data.			*; 	 
	      *-------------------------------------------------*; 

	    *------------------------- Timing of the interview;

assert length(qyear) == 5; 
gen iyear      = substr(qyear, 1, 4); 
gen iquarter   = substr(qyear, 5, 1); 
destring iyear iquarter, replace;
gen e_iquarter =  yq(iyear, iquarter);
				     	
gen first_emonth_ofiquarter = mofd(dofq(e_iquarter));  

	    *-------------------------- Timing of the purchase;

destring vehpurmo, gen(pur_mo);
destring vehpuryr, gen(pur_yr);

gen pur_emonth = ym(pur_yr, pur_mo);

    gen incdt = 0;    
replace incdt = 1 if pur_emonth > first_emonth_ofiquarter + 2 & pur_emonth ~= .; *Mark cases in which the purchase date is;
									         *after the interview period. This should be;
									         *a relatively rare occurrence. Note that these;
quietly	 count if incdt == 1;							 *records will be dropped eventually.;


if `proc_lyr' <= 2005               {; assert `r(N)' <= 80; }; 
if  inlist(`proc_lyr', 2006, 2007)  {; assert `r(N)' == 0;  }; 
if `proc_lyr' == 2008 		    {; assert `r(N)' == 1;  };	

	    *------------- Create hypothetical records for all possible ref_mos.; 
	    *------------- We can identify the valid ones later based on what merges with the main data;

if `proc_lyr' ~= 2008

	{;

	isid newid seqno;

	expand 6;
	
	bysort newid seqno: gen index = _n;

	gen adj = index - 4;

	assert inlist(adj, -3, -2, -1, 0, 1, 2);  *the earliest possible month of the reference period is three months prior to;
					    	  *the first month of the interview quarter, and the latest possible month is the;
					    	  *last month of the quarter (i.e., the first month + 2).;
	};


if `proc_lyr' == 2008

	{;

		*------------------------------------------------------------------*;
		* Create an additional hypothetical record if dealing w- 2008,     *;
		* as a small number of cus who were interviewed in 2008q4 reported *; 	
		* expenditures going back as far as June-08.			   *;  
		*------------------------------------------------------------------*;  

	isid newid seqno;
	
	expand 7;
		
	bysort newid seqno: gen index = _n;
	
	gen adj = index - 5;
	
	assert inlist(adj, -4, -3, -2, -1, 0, 1, 2); 

	};


gen ref_emonth = first_emonth_ofiquarter + adj; 

gen ref_yr = yofd(dofm(ref_emonth)); 
gen ref_mo = month(dofm(ref_emonth));

assert (pur_emonth <= ref_emonth | pur_emonth == .) if adj == 2 & incdt == 0;  *Check the end month of the reference period by;
								  	       *making sure all valid purchase dates occur on 
								  	       *or before it;  

if "`version'" == "main_version"
	
	{; 
	
	drop if pur_emonth > ref_emonth & pur_emonth ~= .;    *Make sure purchases made in the later months of the reference;
	assert incdt == 0;				      *period are not reflected in the period's earlier months; 
							      *(But retain a separate version where future purchases are kept,;
	 };						      *in order to reconcile w - <vehq> in the fmli file);
								  


	    *------------------- Create flags for vehicle type, home equity and new purchases;

		* vehicle type indicators *; 

gen car_flag           = 1   if vehicyb == "100";
gen truckvansuv_flag   = 1   if vehicyb == "110";
gen motorhome_flag     = 1   if vehicyb == "120";
gen camperv1_flag      = 1   if vehicyb == "130"; 
gen camperv2_flag      = 1   if vehicyb == "140";
gen camperv3_flag      = 1   if vehicyb == "180";	
gen mcyclemoped_flag   = 1   if vehicyb == "150";
gen boatwm_flag        = 1   if vehicyb == "160";
gen boatwom_flag       = 1   if vehicyb == "170";
gen other_flag         = 1   if vehicyb == "200";

egen   checksum   =   rsum(*_flag);
assert checksum == 1; drop checksum; 
	
		* Home Equity Indicators *;
	
gen heq_flag  = 1 if veheqtln == "1";  *Flag vehicles that were purchased, at least in part, with funds from a home equity loan;
gen valid_skip = 0;
replace valid_skip = 1 if vfinstat == "1" | vfinance == "2" | inlist(fin_inst, "1", "5", "6", "7");
gen mheq_flag = 1 if veheqtln == "" & valid_skip == 0; *Flag invalid nonresponses to the home equity question;

gen woheq_flag = 1 if heq_flag == . & mheq_flag == .;

egen checksum = rsum(heq_flag mheq_flag woheq_flag); 
assert checksum == 1; drop checksum;

		* New purchase indicators *;

gen new_flag = 1 if ref_emonth == pur_emonth;
gen old_flag = 1 if pur_emonth < ref_emonth & ref_emonth;  
gen unk_flag = 1 if pur_emonth == .;

if "`version'" == "main_version" 

	{; 
	
	egen checksum = rsum(new_flag old_flag unk_flag);  *Note that in the <check_version>, there are observations that are not;
	assert checksum == 1; 				   *flagged with any of the new purchase designations because they relate;  
	drop checksum; 					   *to purchases that occur in the future;	
	
	};    
  
 		* All inclusive flag *;
 
 gen all_flag  = 1;
 
	    *-------------- Assign vehicles to categories based on the above flags;


foreach agestat in new old unk all
{;
foreach vtype   in ${ovb_vtypes} all
{;
foreach heqstat in heq woheq mheq all
{;

	gen ovb_`agestat'_`vtype'_`heqstat' = 1 if `agestat'_flag == 1 & `vtype'_flag == 1 & `heqstat'_flag == 1;
};
};
};		

collapse (sum) ovb_*, by(newid ref_yr ref_mo);
      
              **********  Add new variables to the main dataset ********************;
	      	      
	      *-------------------------------------------------*;
	      * Reformat the identifiers so they are consistent *;
	      * with the conventions of the main file.          *;
	      *-------------------------------------------------*;

tostring newid, replace;
	
tempvar len_newid_m1;
gen `len_newid_m1' = length(newid) - 1;
	
gen   int_num = substr(newid, -1, .);
replace newid = substr(newid, 1, `len_newid_m1');

gen pre1986 = 0;

tempfile ovb_portion;
save `ovb_portion';

	     *--------------------- Merge back to the main file;
     
if "`update'" == "2010m10" {; use if ref_yr == `proc_lyr' using ${main_dir}/ces_int_82_08_v2010, clear; };	     
if "`update'" == "2011m7"  {; use ${update11_dir}\CD1_ces_int_`proc_lyr';
	   
merge 1:1 newid int_num pre1986 ref_yr ref_mo using `ovb_portion', noreport;

	drop if _merge == 2; *This should take care of, among other things, the hypothetical records that do not;
			     *overlap with the cu's reference period;

	recode _merge (1=0) (3=1), gen(ovb_merge);
	drop   _merge;

	   *----------------------------------------------------------*;
	   * Set any ovb counts that did not find a match in the      *;
	   * main dataset to zero rather than missing. 		      *;
	   *----------------------------------------------------------*;
	          
foreach ovb_var of varlist ovb_*       {; replace `ovb_var'  = 0 if `ovb_var' == .; };	 

exit;	