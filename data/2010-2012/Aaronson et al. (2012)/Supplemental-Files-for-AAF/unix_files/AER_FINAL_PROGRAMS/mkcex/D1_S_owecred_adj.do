#delimit;
	
	****************************************************************************
	* The owecred variables were separated from the expenditure sequence in    *
	* August 2010 in order to work around the desktop memory constraints that  *
	* were starting to become an issue.					   *
	*									   *		
	* These adjustments ensure that  the new design does not affect the final  *
	* output of the owecred variables.					   *; 
	*									   *;	
	* In particular, consistent with the convention that a CUs not mentioning  *; 
	* a ucc implies it is zero, the owecred variables are changed from missing *;  
	* to zero if they did not have a  match in master file. While this 	   *;
	* convention holds in almost all cases, CUs are occassionally assigned     *;
	* missing owecred values. This happens when, in a given interview,	   *;
	* a CU provides responses to member characterstics questions, but does     *;
	* mention any UCCs on the keep_list.					   *;
	****************************************************************************;

foreach ocvar in owe_cred2 owe_cred5 {; replace `ocvar' = 0 if exp_to_ocinfo_merge == 1; };
	
gen diff_owe_cred52 = owe_cred5 - owe_cred2 if (owe_cred5 > 0 & owe_cred2 > 0);
label var diff_owe_cred52 "Difference in amount owed to creditors, 2nd and 5th interview";	
	
exit;