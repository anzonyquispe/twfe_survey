#delimit;

	*****************************************************************************;
	* Lists of variables/uccs to import. fmli_ & mtbi checkvars will eventually *;
	* be used to check against the original file to make sure the new and old   *;
	* programs produce the same output. (The actual target variables are        *;
	* defined within the sequence). tdet_keeplist define the uccs corresponding *; 
	* to the trade-in allowance target variables, while test_keeplist 	    *;
	* correspond to the expn vars in mtbi_checkvars.			    *;
	*****************************************************************************;

global fmli_checkvars age_ref fincbtax fam_size;
global mtbi_checkvars newcars usedcars newtrucks usedtrucks; 

global all_checkvars ${fmli_checkvars} ${mtbi_checkvars};

global tdet_keeplist
	
	"450116
	 460116
	 450216
	 460907
	 450226
	 460908
	 600127
	 600128
	 600137
	 600138";
	 	 
global test_keeplist

	"450110
	 460110
	 450210
	 460901";
	 
global full_keeplist ${tdet_keeplist} ${test_keeplist};	 
	
exit;