#delimit;
macro drop _all;

	*------------ Settings --------------------*;

global start_yr 1982;			*This should be 1982 in the final run; 
global end_yr   1990; 			*This should be 1990 in the final run;

global syf_root "O:\PROJ_LIB\IBEX\Program_Files\Single_Year_Files";
global iraw_branch "Rawdata\CEX_Interview";

include D2_G_lists; 

	*--------------- Main --------------------*;

	   *---- Create yearly files -----*;

do D2_S_pull_fmli;     *Creates and saves I_fmli_<start_yr>_<end_yr>;	

do D2_S_pull_mtbi;     *Creates and saves I_mtbi_<start_yr>_<end_yr>;

do D2_S_calc_expn;     *Takes in I_mtbi_<start_yr>_<end_yr> and creates I_expn_<start_yr>_<end_yr>;

	   *------ Collate yearly files---*;

use I2_expn_${start_yr}_${end_yr}, clear;

merge m:1 newid pre1986 using I2_fmli_${start_yr}_${end_yr}; keep if _merge == 3; drop _merge;

do D2_S_misc_reformat.do; 	*Among other changes, <<newid>> &  <<pre1986>> now uniquely identify cus;

save CD2_aug10_additions_${start_yr}_${end_yr}, replace;

exit;