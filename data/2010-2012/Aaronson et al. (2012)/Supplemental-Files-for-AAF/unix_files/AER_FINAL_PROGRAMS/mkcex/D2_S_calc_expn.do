#delimit;

	  *******************************************************************************;
	  * Process cus w- relevant and w-o relevant uccs separately in order to cut    *;
	  * down on reshape time. (Note that we still need to deal with uccs that fall  *;  
	  * outside the scope of the new variables in order to ensure unique 		*; 
	  * newid-ref_mo-ref_yr combinations are represented.)			        *;
	  *******************************************************************************;

use if placeholder_flag == 1 using I2_mtbi_${start_yr}_${end_yr}, replace;
	tempfile placeholder;
save `placeholder';  

		*Reshape*;

use if relucc_flag == 1 using I2_mtbi_${start_yr}_${end_yr}, replace;
	collapse (sum) cost, by(newid pre1986 ref_yr ref_mo ucc); 
	rename cost exp_;
	reshape wide exp_, i(newid ref_yr ref_mo pre1986) j(ucc) string;
	isid newid pre1986 ref_yr ref_mo;

append using `placeholder'; 
	isid newid pre1986 ref_yr ref_mo; 

	      *Name Target Variables*;

foreach ucc of global full_keeplist {; cap gen exp_`ucc' = .;	};
foreach ucc of global full_keeplist {; replace exp_`ucc' = 0 if exp_`ucc' == .; };
	
rename exp_450116 tdet_newcars_tia;
rename exp_460116 tdet_usedcars_tia;
rename exp_450216 tdet_newtrucks_tia;
rename exp_460907 tdet_usedtrucks_tia;
rename exp_450226 tdet_newmcycles_tia;
rename exp_460908 tdet_usedmcycles_tia;
rename exp_600127 tdet_boat_wom_tia;
rename exp_600128 tdet_camper_tia;
rename exp_600137 tdet_mcamperc_tia;	
rename exp_600138 tdet_boat_wm_tia;

	    *Name Check Variables*;

rename exp_450110 newcars;    
rename exp_460110 usedcars;   
rename exp_450210 newtrucks;  
rename exp_460901 usedtrucks; 

save I2_expn_${start_yr}_${end_yr}, replace;

exit;