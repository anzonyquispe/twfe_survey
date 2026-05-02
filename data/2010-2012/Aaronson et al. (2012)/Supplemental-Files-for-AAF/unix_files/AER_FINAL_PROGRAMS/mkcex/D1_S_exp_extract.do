#delimit;

**************************************************************************************;
* Enumerate scope of exp data to be extracted --  by the end of this process, 	     *;	
* information identifying the mtbi files that need to be pulled for a given ref_yr   *;
* will be stored in  local macro <<mtbi_files>> as a list of strings that can	     *;
* be easily parsed using the <tokenize> function.				     *;				
* 										     *;
* Note that q4 of the most recent year for which data is available will always 	     *;
* be incomplete.		 						     *;
**************************************************************************************;

local proclyr `1';			local procsyr:    piece 2 2 of "`proclyr'";
forvalues q = 1/4 {; local file`q' `proclyr'_`procsyr'_`q'; };

local proclyr_p1 = `proclyr' + 1;       local procsyr_p1: piece 2 2 of "`proclyr_p1'";
local file5 `proclyr_p1'_`procsyr_p1'_1;
 
if `proclyr' ~= ${bls_endyr} {; local mtbi_files `file1' `file2' `file3' `file4' `file5'; };
if `proclyr' == ${bls_endyr} {; local mtbi_files `file1' `file2' `file3' `file4'; };

foreach mtbi_id of local mtbi_files {; tempfile I_extract_`mtbi_id'; }; 

******************************************************************************************;
* Read in quarterly expenditure files. Note that there do not appear to be year-specific *;
* procedures/variables in this file, aside from the pre-86 flag 			 *;	
******************************************************************************************;
foreach mtbi_id of local mtbi_files

	{;

	tokenize "`mtbi_id'", parse("_");
	args lyr pc1 syr pc2 q; 
		
	use ${syf_root}\\`lyr'\\${iraw_branch}\mtbi`syr'`q'.dta, clear;
	keep newid 
	     ucc 
	     cost 
	     ref_mo 
	     ref_yr;
		
		
	destring ref_mo 
	         ref_yr, replace;
		  
		  /*
		  ** Some of the reference years are two-digit years rather than four digit. Make
		  ** two-digit numbers into four-digit numbers
		  */
		  replace ref_yr = 1900 + ref_yr if ref_yr < 100;
		  
		  /*
		  ** Interview month - We need to know the interview month because the 4th reference month
		  ** on a quarterly dataset does not include expenditure data. It does include the total amount
		  ** owed to creditors, which we need. Below, we will apply the total amount owed to creditors
		  ** in the 4th month of an interview to all months for which a CU is observed, and then delete
		  ** the 4th month observation.
		  */
		  sort newid
		       ref_yr
		       ref_mo;
		       
		  by newid: gen month_plus_12 = ref_mo;
		  by newid: replace month_plus_12 = ref_mo + 12 if ref_mo < 10 & `q' == 1;
		  
		  by newid: gen qtr_month = 1 +  month_plus_12 - month_plus_12[1];
		  label var qtr_month "Month number on quarterly dataset";
		  
		  
		  *******************************************************************************************;
		  * Drop month 4 observation for each quarterly dataset. It does not contain expenditure    *;
		  * information, and the credit information it contains is accounted for in calc_owecred.do *;
		  *******************************************************************************************;
		  
		  drop if qtr_month == 4;		  
		  		  
		  drop month_plus_12;

			/*
			** Set UCC's that are not considered expenditures by CES to zero so that they do not register as expenditures
			** when we sum over UCC's below
			*/									/* Amount owed to creditors normally set to zero. I will subtract it from tot_exp later */
			replace cost = 0 if /* ucc == "006001"| */	/* Total amount owed to creditors, 2nd interview																						   													*/
													/* ucc == "006002"| */	/* Total amount owed to creditors, 5th interview																							 													*/
													ucc == "006003"|	/* Total amount owed to creditors, 2nd interview, asked first quarter, current year (2004)		 													*/
													ucc == "006004"|	/* Total amount owed to creditors, 5th interview, asked first quarter, current year (2004)		 													*/
													ucc == "006005"|	/* Total amount owed to creditors, 2nd interview, asked first quarter, current year + 1 (2005) 													*/
													ucc == "006006"|	/* Total amount owed to creditors, 5th interview, asked first quarter, current year +1 (2005)	 													*/
													ucc == "220511"|  /* Non-installed wall-to-wall carpeting (original), homeowner (** Deleted in 1999 **)  				 													*/
													ucc == "220512"|  /* Cost of supplies purchased for jobs considered addition, alteration, or new construction in 													*/
													ucc == "220513"|  /* Same as 220512 - owned vacation home																												 													*/
													ucc == "220611"|	/* Contractors' labor and material costs, and cost of supplies rented for jobs considered      													*/
													ucc == "220612"|  /* Built-in dishwasher, garbage disposal, or range hood for jobs considered addition, alterati 													*/
													ucc == "220614"|  /* Installed wall to wall carpeting (original), homeowner (** Deleted in 1999 **)              													*/
													ucc == "220615"|	/* Same as 220611 - owned vacation home & vacation condos and coops                             													*/
													ucc == "220616"|  /* Installed and non-installed original wall to wall carpeting for owned homes                 													*/
												     /* ucc == "450116"| *//* Trade-in allowance for new cars																																											*/
												     /* ucc == "450216"| *//* Trade-in allowance for new trucks or vans																																						*/
												     /*	ucc == "450226"| *//* Trade-in allowance for new motorcycles, motor scooters, or mopeds																										*/
													ucc == "450311"|	/* Charges other than basic lease, such as insurance or maintenance (car lease)																					*/
													ucc == "450312"|  /* Trade-in allowance (car lease)																																												*/
													ucc == "450411"|  /* Charges other than basic lease, such as insurance or maintenance (truck/van lease)																		*/
													ucc == "450412"|	/* Trade-in allowance (truck/van lease)																																									*/
												     /* ucc == "460116"|  *//* Trade-in allowance for used cars																																											*/
												     /*	ucc == "460907"|  *//* Trade-in allowance for used trucks or vans																																						*/
                         									     /* ucc == "460908"|  *//* Trade-in allowance for used motorcycles, motor scooters, or mopeds  																									*/
												     /* ucc == "600137"|  *//* Trade-in allowance for motorized camper-coach or other vehicles (** Deleted in 1994 **)                              */
												     /*	ucc == "600127"|  *//* Trade in allowance for boat without motor or non camper-type trailer, such as for boat or                            */
												     /*	ucc == "600128"|  *//* Trade-in allowance for trailer-type or other attachable-type camper																									*/
												     /*	ucc == "600138"|  *//* Trade-in allowance for boat with motor																																								*/
												     /*	ucc == "600143"|  *//* Trade in allowance, motorized camper																																									*/
												     /*	ucc == "600144"|  *//* Trade in allowance, other vehicle																																										*/
													ucc == "790610"|  /* Contractors' labor and material costs, cost of supplies rented or purchased for jobs        													*/
													ucc == "790611"|  /* Same as 220612 - other properties																												   													*/
													ucc == "790620"|  /* Management fees for capital improvements - other properties																 													*/
													ucc == "790630"|  /* Special assessments for services and capital improvements - other properties								 													*/
													ucc == "790640"|  /* Same as 790620 for management, security, and parking - other properties                     													*/
													ucc == "790710"|	/* Purchase price of property excluding cost of common areas - other properties                													*/
													ucc == "790720"|  /* Amount of purchase price for shares in common areas or recreational facilities - other properties (deleted 1991)     */
													ucc == "790730"|  /* Closing costs - other properties                                                            													*/
													ucc == "790810"|	/* Selling price or trade-in value - other properties																					 													*/
													ucc == "790820"|  /* Principal amount of trust holding for new purchaser - other properties	(**deleted in 2000**)													*/
													ucc == "790830"|  /* Total selling expenses - other properties																									 													*/
													ucc == "790840"|  /* Other charges in sale of other properties (**deleted in 1991 Q1**)																										*/
													ucc == "790910"|	/* Special or lump-sum mortgage payments - other properties																		 													*/
													/* Value of mortgage principal normally would be set to zero. Instead, I will subtract it from tot_exp later. */
													/* ucc == "790920"|	*//* Reduction of mortgage principal - other properties																					 													*/
													ucc == "790930"|	/* Original mortgage amount (mortgage obtained during current quarter's interview) - other		 													*/
													ucc == "790940"|	/* Reduction of principal on lump sum home equity loan - other properties											 													*/
													ucc == "790950"|	/* Original amount of lump sum home equity loan - other properties (loan obtained during			 													*/
													/* Value of home below normally would be set to zero. Instead, I will subtract it from tot_exp later */
													/* ucc == "800721"|	*/ /* Market value of owned home																																	 													*/
													ucc == "800803"|  /* Cash gifts to non-CU members & contributions to organizations                                                         */
													ucc == "810101"|	/* Purchase price of property excluding cost of common areas – owned home											 													*/
													ucc == "810102"|	/* Purchase price of property excluding cost of common areas – owned vacation home						 													*/
													ucc == "810201"|  /* Amount of purchase price for shares in common areas or recreational facilities - owned home (**deleted 1991 Q1**)    */
													ucc == "810202"|  /* Amount of purchase price for shares in common areas or recreational facilities - owned vacation home (**deleted 1991 Q1**)    */
													ucc == "810301"|  /* Closing costs – owned home																																	 													*/
													ucc == "810302"|  /* Closing costs – owned vacation home																												 													*/
													ucc == "810400"|  /* Trip expenses for persons outside the CU																										 													*/
													ucc == "820101"|	/* Selling price or trade-in value – owned home																								 													*/
													ucc == "820102"|	/* Selling price or trade-in value – owned vacation home																			 													*/
													ucc == "820201"|  /* Principal amount of trust holding for new purchaser - owned home (**deleted in 2000**)      													*/
													ucc == "820202"|  /* Principal amount of trust holding for new purchaser - owned vacation home (deleted in 2000) 													*/
													ucc == "820301"|  /* Total selling expenses – owned home																												 													*/
													ucc == "820302"|  /* Total selling expenses – owned vacation home                                                													*/
													ucc == "820401"|  /* Other charges in sale of owned home (**deleted in 1991 Q1**)																													*/
													ucc == "820402"|  /* Other charges in sale of owned vacation home (**deleted in 1991 Q1**)																													*/
													ucc == "830101"|	/* Special or lump-sum mortgage payments – owned home																					 													*/
													
													ucc == "830102"|	/* Special or lump-sum mortgage payments – owned vacation home																 													*/
													/* Value of mortgage principal would normally be set to zero. Instead, I will subtract it from tot_exp later. */
													/* ucc == "830201"|	*//* Reduction of mortgage principal – owned home & portion of management fees for repayment			 													*/
													/* ucc == "830202"|	*//* Same as 830201 – owned vacation home & vacation coops																				 													*/
													ucc == "830203"|	/* Reduction of principal on lump sum home equity loan – owned home														 													*/
													ucc == "830204"|	/* Reduction of mortgage principal, lump sum home equity loan – owned vacation home						 													*/
													ucc == "830301"|	/* Original mortgage amount (mortgage obtained during current quarter’s interview) – owned		 													*/
													ucc == "830302"|	/* Original mortgage amount (mortgage obtained during current quarter’s interview) – owned		 													*/
													ucc == "830303"|	/* Original amount of lump sum home equity loan (loan obtained during current quarter’s				 													*/
													ucc == "830304"|	/* Original amount of lump sum home equity loan (loan obtained during current quarter’s				 													*/
													ucc == "840101"|  /* Amount for special assessment for roads, streets, or similar purposes not included in			 													*/
													ucc == "840102"|  /* Amount for special assessment for roads, streets, or similar purposes not included in       													*/
													ucc == "850100";	/* Reduction of principal on vehicle loan																											 													*/

			replace cost = 0 if ucc == "850200"|	/* Amount borrowed excluding interest on vehicle loan																					 													*/
													ucc == "860100"|	/* Amount automobile sold or reimbursed																												 													*/
													ucc == "860200"|	/* Amount truck or van sold or reimbursed																											 													*/
													ucc == "860300"|  /* Amount motorized camper-coach or other vehicle sold or (** Deleted in 1994 **)                                       */
													ucc == "860301"|	/* Amount motorized camper sold or reimbursed																									 													*/
													ucc == "860302"|	/* Amount other vehicle sold or reimbursed																										 													*/
													ucc == "860400"|	/* Amount trailer-type or other attachable-type camper sold or reimbursed											 													*/
													ucc == "860500"|	/* Amount motorcycle, motor scooter, or moped sold or reimbursed															 													*/
													ucc == "860600"|	/* Amount boat with motor sold or reimbursed																									 													*/
													ucc == "860700"|	/* Amount boat without motor or non camper-type trailer, such as for or cycle sold or					 													*/
													/* ucc == "870101"|	*//* New cars, trucks, or vans (net outlay), purchase not financed															 													*/
													/* ucc == "870102"|	*//* Cash downpayment for new cars, trucks, or vans, purchase financed													 													*/
													/* ucc == "870103"|  *//* Finance charges on loans for new cars, trucks, or vans 																		 													*/
													/* ucc == "870104"|  *//* Principal paid on loans for new cars, trucks, or vans																		   													*/
													/* ucc == "870201"|	*//* Used cars, trucks, or vans (net outlay), purchase not financed															 													*/
													/* ucc == "870202"|  *//* Cash downpayment for used cars, trucks, or vans, purchase financed                          													*/
													/* ucc == "870203"|  *//* Finance charges on loans for used cars, trucks, or vans																		 													*/
													/* ucc == "870204"|  *//* Principal paid on loans for used cars, trucks, or vans		                                   													*/
													/* ucc == "870301"|	*//* Motorcycles, motor scooters, or mopeds (net outlay), purchase not financed									 													*/
													/* ucc == "870302"|  *//* Cash downpayment for motorcycles, motor scooters, or mopeds, purchase financed							 													*/
													/* ucc == "870303"|  *//* Finance charges on loans for motorcycles, motor scooters, or mopeds												 													*/
													/* ucc == "870304"|  *//* Principal paid on loans for motorcycles, motor scooters, or mopeds													 													*/
													/* ucc == "870401"|	*//* Boat without motor or non camper-type trailer, such as for boat or cycle (net outlay), 		 													*/
													/* ucc == "870402"|	*//* Cash downpayment for boat without motor, or non camper-type trailer, such as for boat or		 													*/
													/* ucc == "870403"|	*//* Finance charges on loans for boat without motor or non camper- type trailer, such as for bo 													*/
													/* ucc == "870404"|	*//* Principal paid on loans for boat without motor, or non camper-trailer, such as for boat or  													*/
													/* ucc == "870501"|	*//* Trailer-type or other attachable-type camper (net outlay), purchase not financed						 													*/
													/* ucc == "870502"|	*//* Cash downpayment for trailer-type or other attachable-type camper, purchase financed				 													*/
													/* ucc == "870503"|	*//* Finance charges on loans for trailer-type or other attachable-type camper            			 													*/
													/* ucc == "870504"|	*//* Principal paid on loans for trailer-type or other attachable-type camper         					 													*/
													/* ucc == "870601"|     *//* Motorized camper-coach or other vehicles (net outlay), (** Deleted in 1994 **) 																		  */
													/* ucc == "870602"|     *//* Cash downpayment for motorized camper-coach or other (** Deleted in 1994 **) 																		    */
													/* ucc == "870603"|     *//* Finance charges on loans for motorized camper-coach or other (** Deleted in 1994 **) 																*/
													/* ucc == "870604"|     *//* Principal paid on loans for motorized camper-coach or other (** Deleted in 1994 **) 																	*/
													/* ucc == "870605"|	*//* Purchase of motorized camper, not financed																									 													*/
													/* ucc == "870606"|	*//* Principal, motorized camper, financed     																									 													*/
													/* ucc == "870607"|	*//* Interest, motorized camper, financed  																											 													*/
													/* ucc == "870608"|	*//* Downpayment, motorized camper, financed																										 													*/
													/* ucc == "870701"|	*//* Boat with motor (net outlay), purchase not financed																				 													*/
													/* ucc == "870702"|	*//* Cash downpayment for boat with motor, purchase financed																		 													*/
													/* ucc == "870703"|	*//* Finance charges on loans for boat with motor																								 													*/
													/* ucc == "870704"|	*//* Principal paid on loans for boat with motor																								 													*/
													/* ucc == "870801"|	*//* Purchase of other vehicle, not financed																										 													*/
													/* ucc == "870802"|	*//* Principal, other vehicle, financed																													 													*/
													/* ucc == "870803"|	*//* Interest, other vehicle, financed																													 													*/
													/* ucc == "870804"|	*//* Downpayment, other vehicle, financed																												 													*/
													ucc == "880120"|	/* Reduction of principal on line of credit home equity loan – owned home											 													*/
													ucc == "880220"|	/* Reduction of principal on line of credit home equity loan – other properties								 													*/
													ucc == "880320"|	/* Reduction of principal on line of credit home equity loan – owned vacation home						 													*/
													ucc == "910050"|	/* Rental equivalence of owned home																														 													*/
													ucc == "910101"|        /* Rental equivalence for vacation home not available for rent, added 2007Q2 */
													ucc == "910102"|        /* Rental equivalence for vacation home available for rent, added 2007Q2 */
													ucc == "910103"|        /* Rental equivalence for timeshares, added 2007Q2 */
													ucc == "910104"|        /* CPI Adjusted Rental Equivalence of vacation home */
													ucc == "910105"|        /* CPI Adjusted Rental Equivalence of home not available for rent */
													ucc == "910106"|        /* CPI Adjusted Rental Equivalence of home available for rent */
													ucc == "910107"|        /* CPI Adjusted Rental Equivalence for timeshares */ 
													ucc == "910060"|	/* Estimated monthly rental value of time share - owned vacation home or recreational property (** Deleted in 1999 **) 	*/
													ucc == "910070"|	/* Estimated monthly rental value of owned vacation home or recreational property, not time	(** Deleted in 1999 **)     */
													ucc == "910080"|	/* Rent received for time share - owned vacation home or recreational property (** Deleted in 1999 **)              		*/
													ucc == "910090"|	/* Rent received for owned vacation home or recreational property, not time share	(** Deleted in 1999 **)								*/
													ucc == "910100"|	/* Rental equivalence of owned vacation home																									 													*/
													ucc == "990950";	/* Contractors' labor and material costs, and cost of supplies rented for dwellings and additi 													*/
      
      /*
			** Sum up total monthly expenditures for each CU
			*/
			sort newid
					 ref_yr
					 ref_mo
					 ucc;

			by newid ref_yr ref_mo: egen tot_exp = sum(cost);

			*su tot_exp, detail;

			*list in 1/100; 

			/*
			** Create flags for expenditures on housing, durables, and transportation.
			** Keep only expenditures on housing and expenditures on durables. Also,
			** keep the first observation for each CU in case the CU has no expenditures
			** on housing or durables. Note that household furnishings and equipment
			** fall under both housing and durables. I flag them under housing.
			*/
			gen housing_flag = 0;
			replace housing_flag = 1 if (ucc == "220311")|
																	(ucc == "220313")|
																	(ucc == "220321")|
																	(ucc == "880110")|
																	(ucc == "220211")|
																	(ucc == "210901")|
																	(ucc == "220111")|
																	(ucc == "220121")|
																	(ucc == "220901")|
																	(ucc == "230112")|
																	(ucc == "230113")|
																	(ucc == "230114")|
																	(ucc == "230115")|
																	(ucc == "230122")|
																	(ucc == "230142")|
																	(ucc == "230116")|
																	(ucc == "230151")|
																	(ucc == "230901")|
																	(ucc == "240112")|
																	(ucc == "240122")|
																	(ucc == "240212")|
																	(ucc == "240213")|
																	(ucc == "240222")|
																	(ucc == "240312")|
																	(ucc == "240322")|
																	(ucc == "320612")|
																	(ucc == "320622")|
																	(ucc == "320632")|
																	(ucc == "340911")|
																	(ucc == "990930")|
																	(ucc == "210110")|
																	(ucc == "230121")|
																	(ucc == "230141")|
																	(ucc == "230111")|
																	(ucc == "230150")|
																	(ucc == "240111")|
																	(ucc == "240121")|
																	(ucc == "240211")|
																	(ucc == "240221")|
																	(ucc == "240311")|
																	(ucc == "240321")|
																	(ucc == "320611")|
																	(ucc == "320621")|
																	(ucc == "320631")|
																	(ucc == "350110")|
																	(ucc == "790690")|
																	(ucc == "990920")|
																	(ucc == "800710")|
																	(ucc == "210210")|
																	(ucc == "210310")|
																	(ucc == "210902")|
																	(ucc == "220112")|
																	(ucc == "220122")|
																	(ucc == "220212")|
																	(ucc == "220312");
			replace housing_flag = 1 if (ucc == "220314")|
																	(ucc == "220322")|
																	(ucc == "220902")|
																	(ucc == "230123")|
																	(ucc == "230119")|
																	(ucc == "230152")|
																	(ucc == "230902")|
																	(ucc == "240113")|
																	(ucc == "240123")|
																	(ucc == "240214")|
																	(ucc == "240223")|
																	(ucc == "240313")|
																	(ucc == "240323")|
																	(ucc == "320613")|
																	(ucc == "320623")|
																	(ucc == "320633")|
																	(ucc == "340912")|
																	(ucc == "880310")|
																	(ucc == "990940")|
																	(ucc == "260211")|
																	(ucc == "260212")|
																	(ucc == "260213")|
																	(ucc == "260214")|
																	(ucc == "260111")|
																	(ucc == "260112")|
																	(ucc == "260113")|
																	(ucc == "260114")|
																	(ucc == "250111")|
																	(ucc == "250112")|
																	(ucc == "250113")|
																	(ucc == "250114")|
																	(ucc == "250211")|
																	(ucc == "250212")|
																	(ucc == "250213")|
																	(ucc == "250214")|
																	(ucc == "250221")|
																	(ucc == "250222")|
																	(ucc == "250223")|
																	(ucc == "250224")|
																	(ucc == "250901")|
																	(ucc == "250902")|
																	(ucc == "250903")|
																	(ucc == "250904")|
																	(ucc == "250911")|
																	(ucc == "250912")|
																	(ucc == "250913")|
																	(ucc == "250914")|
																	(ucc == "270000")|
																	(ucc == "270101")|
																	(ucc == "270102")|
																	(ucc == "270103")|
																	(ucc == "270104")|
																	(ucc == "270105")|
																	(ucc == "270211")|
																	(ucc == "270212")|
																	(ucc == "270213")|
																	(ucc == "270214")|
																	(ucc == "270411")|
																	(ucc == "270412")|
																	(ucc == "270413")|
																	(ucc == "270414")|
																	(ucc == "270901")|
																	(ucc == "270902")|
																	(ucc == "270903");
			replace housing_flag = 1 if (ucc == "270904")|
																	(ucc == "340310")|
																	(ucc == "340410")|
																	(ucc == "340420")|
																	(ucc == "340520")|
																	(ucc == "340530")|
																	(ucc == "340903")|
																	(ucc == "340906")|
																	(ucc == "340910")|
																	(ucc == "340914")|
																	(ucc == "340915")|
																	(ucc == "340210")|
																	(ucc == "340211")|
																	(ucc == "340212")|
																	(ucc == "670310")|
																	(ucc == "990910")|
																	(ucc == "330511")|
																	(ucc == "340510")|
																	(ucc == "340620")|
																	(ucc == "340630")|
																	(ucc == "340901")|
																	(ucc == "340907")|
																	(ucc == "340908")|
																	(ucc == "690113")|
																	(ucc == "690114")|
																	(ucc == "990900")|
																	(ucc == "280110")|
																	(ucc == "280120")|
																	(ucc == "280130")|
																	(ucc == "280210")|
																	(ucc == "280220")|
																	(ucc == "280230")|
																	(ucc == "280900")|
																	(ucc == "290110")|
																	(ucc == "290120")|
																	(ucc == "290210")|
																	(ucc == "290310")|
																	(ucc == "290320")|
																	(ucc == "290410")|
																	(ucc == "290420")|
																	(ucc == "290430")|
																	(ucc == "290440")|
																	(ucc == "230132")|
																	(ucc == "320162")|
																	(ucc == "230133")|
																	(ucc == "230131")|
																	(ucc == "320161")|
																	(ucc == "230134")|
																	(ucc == "320110")|
																	(ucc == "320111")|
																	(ucc == "320163")|
																	(ucc == "230117")|
																	(ucc == "230118")|
																	(ucc == "300111")|
																	(ucc == "300112")|
																	(ucc == "300211")|
																	(ucc == "300212")|
																	(ucc == "300221");
			replace housing_flag = 1 if (ucc == "300222")|
				(ucc == "300311")|
				(ucc == "300312")|
				(ucc == "300321")|
				(ucc == "300322")|
				(ucc == "300331")|
				(ucc == "300332")|
				(ucc == "300411")|
				(ucc == "300412")|
				(ucc == "320511")|
				(ucc == "320512")|
				(ucc == "320310")|
				(ucc == "320320")|
				(ucc == "320330")|
				(ucc == "320340")|
				(ucc == "320350")|
				(ucc == "320360")|
				(ucc == "320370")|
				(ucc == "320521")|
				(ucc == "320522")|
				(ucc == "320120")|
				(ucc == "320130")|
				(ucc == "320150")|
				(ucc == "320210")|
				(ucc == "320233")|
				(ucc == "320220")|
				(ucc == "320230")|
				(ucc == "320231")|
				(ucc == "320232")|
				(ucc == "320410")|
				(ucc == "320420")|
				(ucc == "320901")|
				(ucc == "320902")|
				(ucc == "320903")|
				(ucc == "320904")|
				(ucc == "340904")|
				(ucc == "430130")|
				(ucc == "690110")|
				(ucc == "690111")|
				(ucc == "690117")|
				(ucc == "690310")|
				(ucc == "690112")|
				(ucc == "690115")|
				(ucc == "690210")|
				(ucc == "690220")|
				(ucc == "690230")|
				(ucc == "690241")|
				(ucc == "690242")|
				(ucc == "690243")|
				(ucc == "690244")|
				(ucc == "690245");

			gen durable_flag = 0;
			replace durable_flag = 1 if (ucc == "450110")|
				(ucc == "450210")|
				(ucc == "460110")|
				(ucc == "460901")|
				(ucc == "450220")|
				(ucc == "460902")|
				(ucc == "270310")|
				(ucc == "270311")|
				(ucc == "310110")|
				(ucc == "690320")|
				(ucc == "690330")|
				(ucc == "690340")|
				(ucc == "690350")|
				(ucc == "310120")|
				(ucc == "310130")|
				(ucc == "310140")|
				(ucc == "310210")|
				(ucc == "310220")|
				(ucc == "310230")|
				(ucc == "310311")|
				(ucc == "310313")|
				(ucc == "310314")|
				(ucc == "310320")|
				(ucc == "310330")|
				(ucc == "310312")|
				(ucc == "310333")|
				(ucc == "310334")|
				(ucc == "310340")|
				(ucc == "310341")|
				(ucc == "310342")|
				(ucc == "340610")|
				(ucc == "620916")|
				(ucc == "340902")|
				(ucc == "340905")|
				(ucc == "610130")|
				(ucc == "620904")|
				(ucc == "620912")|
				(ucc == "610110")|
				(ucc == "610120")|
				(ucc == "600110")|
				(ucc == "600121")|
				(ucc == "600122")|
				(ucc == "600132")|
				(ucc == "600131")|
				(ucc == "600141")|
				(ucc == "600142")|
				(ucc == "600210")|
				(ucc == "600310")|
				(ucc == "600410")|
				(ucc == "600420")|
				(ucc == "600430")|
				(ucc == "600900")|
				(ucc == "600901")|
				(ucc == "600902")|
																	(ucc == "610230");
																	
			gen transp_flag = 0;
			replace transp_flag	= 1 if (ucc == "450110")|
																 (ucc == "450210")|
																 (ucc == "460110")|
																 (ucc == "460901")|
																 (ucc == "450220")|
																 (ucc == "460902")|
																 (ucc == "470111")|
																 (ucc == "470112")|
																 (ucc == "470113")|
																 (ucc == "470211")|
																 (ucc == "470212")|
																 (ucc == "510110")|
																 (ucc == "510901")|
																 (ucc == "510902")|
																 (ucc == "850300")|
																 (ucc == "470220")|
																 (ucc == "480110")|
																 (ucc == "480211")|
																 (ucc == "480212")|
																 (ucc == "480213")|
																 (ucc == "480214")|
																 (ucc == "480215")|
																 (ucc == "490110")|
																 (ucc == "490211")|
																 (ucc == "490212")|
																 (ucc == "490220")|
																 (ucc == "490221")|
																 (ucc == "490231")|
																 (ucc == "490232")|
																 (ucc == "490311")|
																 (ucc == "490312")|
																 (ucc == "490313")|
																 (ucc == "490314")|
																 (ucc == "490315")|
																 (ucc == "490317")|
																 (ucc == "490318")|
																 (ucc == "490319")|
																 (ucc == "490411")|
																 (ucc == "490412")|
																 (ucc == "490413")|
																 (ucc == "490500")|
																 (ucc == "490501")|
																 (ucc == "490502")|
																 (ucc == "490900")|
																 (ucc == "500110")|
																 (ucc == "450310")|
																 (ucc == "450313");
			replace transp_flag	= 1 if (ucc == "450314")|
																 (ucc == "450410")|
																 (ucc == "450413")|
																 (ucc == "450414")|
																 (ucc == "520110")|
																 (ucc == "520111")|
																 (ucc == "520112")|
																 (ucc == "520310")|
																 (ucc == "520410")|
																 (ucc == "520511")|
																 (ucc == "520512")|
																 (ucc == "520521")|
																 (ucc == "520522")|
																 (ucc == "520530")|
																 (ucc == "520531")|
																 (ucc == "520532")|
																 (ucc == "520541")|
																 (ucc == "520542")|
																 (ucc == "520550")|
																 (ucc == "520560")|
																 (ucc == "520902")|
																 (ucc == "520903")|
																 (ucc == "520905")|
																 (ucc == "520906")|
																 (ucc == "620113")|
																 (ucc == "530110")|
																 (ucc == "530210")|
																 (ucc == "530312")|
																 (ucc == "530411")|
																 (ucc == "530510")|
																 (ucc == "530901")|
																 (ucc == "530311")|
																 (ucc == "530412")|
																 (ucc == "530902");			
																 
			gen clothing_flag = 0;
			replace clothing_flag = 1 if (ucc == "360110")|
																	 (ucc == "360120")|
																	 (ucc == "360210")|
																	 (ucc == "360311")|
																	 (ucc == "360312")|
																	 (ucc == "360320")|
																	 (ucc == "360330")|
																	 (ucc == "360340")|
																	 (ucc == "360350")|
																	 (ucc == "360410")|
																	 (ucc == "360511")|
																	 (ucc == "360513")|
																	 (ucc == "370314")| 
																	 (ucc == "380333")|
																	 (ucc == "390223")|										 
																	 (ucc == "360512")|
																	 (ucc == "360901")|
																	 (ucc == "360902")|
																	 (ucc == "370110")|
																	 (ucc == "370120")|
																	 (ucc == "370130")|
																	 (ucc == "370211")|
																	 (ucc == "370212")|
																	 (ucc == "370213")|
																	 (ucc == "370220")|
																	 (ucc == "370311")|
																	 (ucc == "370312")|
																	 (ucc == "370313")|
																	 (ucc == "370901")|
																	 (ucc == "370902")|
																	 (ucc == "370903")|
																	 (ucc == "370904")|
																	 (ucc == "380110")|
																	 (ucc == "380210")|
																	 (ucc == "380311")|
																	 (ucc == "380312")|
																	 (ucc == "380313")|
																	 (ucc == "380320")|
																	 (ucc == "380331")|
																	 (ucc == "380332")|
																	 (ucc == "380340")|
																	 (ucc == "380410")|
																	 (ucc == "380420")|
																	 (ucc == "380430")|
																	 (ucc == "380510")|
																	 (ucc == "380901")|
																	 (ucc == "380902")|
																	 (ucc == "380903")|
																	 (ucc == "390110")|
																	 (ucc == "390120")|
																	 (ucc == "390210");
			replace clothing_flag = 1 if (ucc == "390221")|
																	 (ucc == "390222")|
																	 (ucc == "390230")|
																	 (ucc == "390310")|
																	 (ucc == "390321")|
																	 (ucc == "390322")|
																	 (ucc == "390901")|
																	 (ucc == "390902")|
																	 (ucc == "410110")|
																	 (ucc == "410111")|
																	 (ucc == "410112")|
																	 (ucc == "410120")|
																	 (ucc == "410121")|
																	 (ucc == "410122")|
																	 (ucc == "410130")|
																	 (ucc == "410131")|
																	 (ucc == "410132")|
																	 (ucc == "410140")|
																	 (ucc == "410141")|
																	 (ucc == "410142")|
																	 (ucc == "410901")|
																	 (ucc == "410903")|
																	 (ucc == "410904")|
																	 (ucc == "400110")|
																	 (ucc == "400210")|
																	 (ucc == "400220")|
																	 (ucc == "400310")|
																	 (ucc == "420110")|
																	 (ucc == "420120")|
																	 (ucc == "430110")|
																	 (ucc == "430120")|
																	 (ucc == "440110")|
																	 (ucc == "440120")|
																	 (ucc == "440130")|
																	 (ucc == "440140")|
																	 (ucc == "440150")|
																	 (ucc == "440210")|
																	 (ucc == "440900");  			
					
			gen vhome_flag = 0;
			replace vhome_flag = 1 if (ucc == "800721");
			
			gen mort_flag = 0;
			replace mort_flag = 1 if (ucc == "220311")|
			                         (ucc == "220312")|
			                         (ucc == "790920")|
			                         (ucc == "830201")|
			                         (ucc == "830202");
			
			gen tdet_flag = 0;
			replace tdet_flag = 1 if  ucc == "870101"|
						  ucc == "870102"|
						  ucc == "870103"|
						  ucc == "870104"|
						  ucc == "870201"|
						  ucc == "870202"|
						  ucc == "870203"|
						  ucc == "870204"|
						  ucc == "870301"|
						  ucc == "870302"|
						  ucc == "870303"|
						  ucc == "870304"|
						  ucc == "870401"|
						  ucc == "870402"|
						  ucc == "870403"|
						  ucc == "870404"|
						  ucc == "870501"|
						  ucc == "870502"|
						  ucc == "870503"|
						  ucc == "870504"|						  
						  ucc == "870601"|
						  ucc == "870602"|
						  ucc == "870603"|
						  ucc == "870604"|
						  ucc == "870605"|
						  ucc == "870606"|
						  ucc == "870607"|
						  ucc == "870608"|						  
						  ucc == "870701"|
						  ucc == "870702"|
						  ucc == "870703"|
						  ucc == "870704"|
						  ucc == "870801"|
						  ucc == "870802"|
						  ucc == "870803"|
						  ucc == "870804"|
						  ucc == "450116"|
						  ucc == "460116"|
						  ucc == "450216"|
						  ucc == "460907"|
						  ucc == "450226"|
						  ucc == "460908"|
						  ucc == "600138"|
						  ucc == "600128"|
						  ucc == "600127"|
						  ucc == "600137"|
						  ucc == "600144"|
						  ucc == "600143";
			                         			
			gen cred_flag = 0;
			replace cred_flag = 1 if (ucc == "006001")|
			                         (ucc == "006002");

      /*
      ** Note: No flag needed for child care since those UCC's covered
      **       by housing flag.
      */
			by newid ref_yr ref_mo: keep if [_n]  == 1| 
						housing_flag  == 1|													
						durable_flag  == 1|													
						transp_flag   == 1|													
						clothing_flag == 1|													
						vhome_flag    == 1|													
						mort_flag     == 1|													
						cred_flag     == 1|
						tdet_flag     == 1; 													 

			by newid ref_yr ref_mo ucc: egen exp_ = sum(cost);

			*list newid ref_yr ref_mo ucc cost exp_ tot_exp in 1/200;

			/*
			** Keep last UCC observation, which includes the monthly expenditure by CU
			** on item-specific housing or durable expenditure
			*/
			by newid ref_yr ref_mo ucc: keep if [_n] == [_N];
				
  		*list newid ref_yr ref_mo ucc cost exp_ tot_exp in 1/200;
  		
			/*
			** Drop variables not needed anymore
			*/
			drop cost
		       *flag;
  		
			/*
			** Generate a dummy variable signifying whether the observation comes before
			** or after 1986. In 1986, the newid variable started over at 1. Thus, some
			** newid's before 1986 may be the same as those after. In order to keep these
			** separate, we need a dummy variable specifying whether the observation came
			** before or after 1986.
			*/
      	gen pre1986 = (`syr' >= 82 & `syr' < 86);
      
      	di "Saving exp extract for mtbi quarter `lyr'Q`q'. Currently obtaining data for `proclyr'";
			
	save `I_extract_`mtbi_id'';		
	
	};


	************ Append each quarterly file to form a complete year of data *******************;
	
clear;
gen dummy = .;

foreach mtbi_id of local mtbi_files {; append using `I_extract_`mtbi_id''; };

drop dummy;

save I1_exp_ces_int_`proclyr'.dta, replace;

exit;