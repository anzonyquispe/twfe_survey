#delimit;
macro drop _all;

		*--------------------------------------------------*;	
	      	* This program derives variables relating to the   *; 
	        * funding source of past and present vehicle       *:
	        * purchases, which it then adds to the main cex    *:
	        * minimum wage dataset.			           *;
	        *  						   *:	
	        * The underlying source of this information is     *;  
	       	* the <ovb> file, which corresponds to the survey  *;
	        * module that asks detailed questions about all    *;
	        * owned vehicles (11B). 			   *;
	        *						   *;	
	      	* Written by Dan DiFranco on 10-8-10    	   *;     							   *;
	   	*--------------------------------------------------*;

	* Settings *;

global main_dir     "D:\large_datasets";		*Houses a copy of ces_int_82_08_v2010;
global ovb_dir      "C:\Projects\cashin_cex_fordan\Inputs";
global update11_dir "C:\Projects\cashin_cex_fordan\References\2011m7_checkdata\update";

global ovb_ilist   "qyear seqno vehicyb veheqtln vehnewu vehpurmo vehpuryr  vfinstat";
global ovb_vtypes  "car truckvansuv motorhome camperv1 camperv2 camperv3 mcyclemoped boatwm boatwom other"; 

global ovb_start    2009;
global ovb_end      2009;

global update 2011m7;

	* Main *;

forvalues year = $ovb_start/$ovb_end 

	{; 
	
	do D3_S_addyear `year' main_version ${update}; 

	compress;
	
	save CD3_ces_heqdetail_`year'v1, replace;
	
	do D3_S_addyear `year' check_version ${update}; 

		*--------- For this version, keep only the variables that are -----------*;  
		*--------- needed to conduct the cross-tabulations in A2. ---------------*;
	
	keep newid int_num ref_mo ref_yr vehq newcars usedcars newtrucks usedtrucks newmcycles usedmcycles
 	     boat_wom camper mcamperc boat_wm pmcamper otherveh ovb_*;
		
	compress;

	save CD3_ces_heqdetail_`year'v2, replace;
		
	}; 

exit;