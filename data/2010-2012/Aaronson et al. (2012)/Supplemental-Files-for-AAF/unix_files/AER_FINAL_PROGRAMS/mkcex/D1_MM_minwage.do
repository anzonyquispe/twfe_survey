#delimit;
clear;
macro drop _all;
set mem 700m;

****************************************************************************************************;
* File naming conventions:									   *;
* <<D1>> = Dataset 1, <<MM>> = Master file, <<S>> = Subfile, <<G>> = Global definer;		   *;		 
*												   *;	
* Note that programs draw from CEX data in the O: drive -- to access this data, please request     *;
* read-only access to O:\PROJ_LIB\IBEX from Ken or Sean.					   *;
*												   *;
* To add years of data, first update the end_lyr and end_syr global macros to reflect the most     *;
* recent year of CEX data. Next, check the definitions of the demographic variables in the         *;
* D1_S_fam_extract subprogram to make sure they have not changed since the last run of data.       *;
* If they have changed, take care to update the file in such a way that prior years of data        *;
* are not affected.          							 		   *;
*												   *;
* Note that, as of 8-2010, this program will only process data going back to 1990, as some of the  *; 
* variables from the fmli and memi files have not yet been imported from the original ASCII files. *;
****************************************************************************************************;

************************************** Settings **********************************************************************;

global syf_root    "O:\PROJ_LIB\IBEX\Program_Files\Single_Year_Files";
global iraw_branch "Rawdata\CEX_Interview";
global adden_dir   "C:\Projects\cashin_cex_fordan\Inputs"; 

global start_lyr 1991; global start_syr 91;  *Date range to be processed -- should be 1991 in the final run; 	
global end_lyr   2009; global end_syr   09;

global bls_endyr 2009; 			     *The most recent year of cex data available -- the last quarter
					     *of this year will be incomplete;

do D1_G_ucc_keeplist.do;		     *Defines the uccs that should be kept in the sums file;

************************************* Main ***************************************************************************;

	   *-------Extract Member, Family and Characteristics Into Separate Files---------*;
	
do D1_S_mem_extract.do; 	*creates CM1_mem_ces_int_[startyr]_[endyr] from memi files; 
do D1_S_fam_extract.do;		*creates CM1_fam_ces_int_[startyr]_[endyr] from fmli files; 

	***************************************************************************;
	* Expenditure data is processed by year in order to avoid memory issues   *;
	* while working on the desktop. The two exceptions are, which must be 	  *;
	* processed while all years are appended in order to accomodate the panel *;
	* nature of those variables.						  *;
	*									  *;
	* Describe files in more detail here.					  *;
	***************************************************************************;

do D1_S_calc_owecred.do;       *creates CM1_owecredit_int_[startyr]_[endyr] from mtbi files; 

forvalues exp_year = $start_lyr/$end_lyr
	
	{;
		
	do D1_S_exp_extract `exp_year';     
		       
	do D1_S_exp_reshape `exp_year';                   
	
	do D1_S_exp_sums    `exp_year';	  	       
		
	};  

	*-------------- Combine the above files into yearly files-------------------------*;

forvalues year = $start_lyr/$end_lyr

	{;

	di as yellow "*-------- Combining files for `year' ---------------*";

	use CM1_summed_`year', clear; 	
	
	**************************************************************************;
	* There are seven cases where there exists an observation for a CU       *;
	* on the member and family file, but not the expenditure file. I delete  *;
	* these observations.							 *;
	**************************************************************************;
			
	merge m:1 newid pre1986 using CM1_fam_ces_int_${start_syr}_${end_syr}.dta; keep if _merge == 3; drop _merge; 
		
	merge m:1 newid pre1986 using CM1_mem_ces_int_${start_syr}_${end_syr}.dta; 
		rename _merge exp_to_mem_merge;
		drop if exp_to_mem_merge == 2;
		drop owe_cred2 owe_cred5; 
		
	do D1_S_misc_formatting.do;	*<<newid>> &  <<pre1986>> now uniquely identify cus;
	
	merge m:1 newid pre1986 using CM1_owecred_${start_syr}_${end_syr}; 
		rename _merge exp_to_ocinfo_merge;
		drop if exp_to_ocinfo_merge == 2; 
		do D1_S_owecred_adj;		
		drop exp_*_merge;
		
	save CD1_ces_int_`year'.dta, replace;
		
	};
	
exit;