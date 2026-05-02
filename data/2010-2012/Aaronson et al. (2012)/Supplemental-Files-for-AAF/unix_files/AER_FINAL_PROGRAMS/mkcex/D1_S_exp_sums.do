#delimit;

local proclyr `1';

*There do not appear to be year specific procedures/variables in this file, aside from the uccs need to be 
*added for certain years (if this needs to take place, it should be obvious);
*Should we look for additional uccs that should be included in the definition of aggregate categories?;
*Some uccs added to both housing_exp and durables. These need to be subtracted from durables to create dur_less_house;

use I1_sums_ready_`proclyr'.dta, clear;

foreach ucc of global ucc_keeplist {; cap gen `ucc' = .; };	*Define variables as missing if not found in the dataset;
								*These will evenutally be redefined as being zero;

	
keep newid  pre1986 ref_yr ref_mo qtr_month tot_exp ${ucc_keeplist}; *Keep only housing, durable, transportation, clothing, 
								     *and total expenditure variables;
			 
	
foreach var of varlist exp* tot_exp {; replace `var' = 0 if `var' == .; }; *Set missing expenditure values to zero;
	
	/*
	** Subtract market value of home from total expenditures.
	** Add mortgage principal reductions (which are negative values).
	*/
	
	rename exp_800721 vhome;
	rename exp_790920 mortprinop;
	rename exp_830201 mortprinh;
	rename exp_830202 mortprinvh;
	rename exp_006001 owe_cred2;
	rename exp_006002 owe_cred5;
	
	rename exp_450116 tdet_newcars_tia;
	rename exp_460116 tdet_usedcars_tia;
	rename exp_450216 tdet_newtrucks_tia;
	rename exp_460907 tdet_usedtrucks_tia;
	rename exp_450226 tdet_newmcycles_tia;
	rename exp_460908 tdet_usedmcycles_tia;
	
	rename exp_870101 tdet_newcartrkvan_pnf;
	rename exp_870102 tdet_newcartrkvan_dpmt;
	rename exp_870103 tdet_newcartrkvan_finchrg;
	rename exp_870104 tdet_newcartrkvan_princhrg;
	
	rename exp_870201 tdet_usedcartrkvan_pnf;
	rename exp_870202 tdet_usedcartrkvan_dpmt;
	rename exp_870203 tdet_usedcartrkvan_finchrg;
	rename exp_870204 tdet_usedcartrkvan_princhrg;
	
	rename exp_870301 tdet_mcycles_pnf;
	rename exp_870302 tdet_mcycles_dpmt;
	rename exp_870303 tdet_mcycles_finchrg;
	rename exp_870304 tdet_mcycles_princhrg;
	
	rename exp_870401 tdet_boat_wom_pnf;
	rename exp_870402 tdet_boat_wom_dpmt;
	rename exp_870403 tdet_boat_wom_finchrg;
	rename exp_870404 tdet_boat_wom_princhrg;
	rename exp_600127 tdet_boat_wom_tia;
	
	rename exp_870501 tdet_camper_pnf;
	rename exp_870502 tdet_camper_dpmt;
	rename exp_870503 tdet_camper_finchrg;
	rename exp_870504 tdet_camper_princhrg;
	rename exp_600128 tdet_camper_tia;
	
	rename exp_870601 tdet_mcamperc_pnf;
	rename exp_870602 tdet_mcamperc_dpmt;
	rename exp_870603 tdet_mcamperc_finchrg;
	rename exp_870604 tdet_mcamperc_princhrg;
	rename exp_600137 tdet_mcamperc_tia;	
	
	rename exp_870605 tdet_pmcamper_pnf;
	rename exp_870606 tdet_pmcamper_princhrg;
	rename exp_870607 tdet_pmcamper_finchrg;
	rename exp_870608 tdet_pmcamper_dpmt;
	rename exp_600143 tdet_pmcamper_tia;
	    		
	rename exp_870701 tdet_boat_wm_pnf;
	rename exp_870702 tdet_boat_wm_dpmt;
	rename exp_870703 tdet_boat_wm_finchrg;
	rename exp_870704 tdet_boat_wm_princhrg;
	rename exp_600138 tdet_boat_wm_tia;
	
	rename exp_870801 tdet_otherveh_pnf;
	rename exp_870802 tdet_otherveh_princhrg;
	rename exp_870803 tdet_otherveh_finchrg;
	rename exp_870804 tdet_otherveh_dpmt;	
	rename exp_600144 tdet_otherveh_tia;			
	
	egen tdet_total = rsum(tdet_*);
	replace tot_exp = tot_exp - vhome + mortprinop + mortprinh + mortprinvh - owe_cred2 - owe_cred5 - tdet_total;
	drop tdet_total;
	
	****************** Differentiate between Missing and Zero for tdet variables  ******;

			 *Make sure all tdet vars are accounted for*;
	
	local all_tdet_vars; foreach variable of varlist tdet_* {; local all_tdet_vars `all_tdet_vars' `variable'; };
	local check_tdet_list ${existed_in_1982}  ${phased_in_1991} ${added_1994};
	
	assert `: list check_tdet_list === all_tdet_vars' == 1;		
				
				*Apply Changes*;
				
	foreach variable of global phased_in_1991 
	
		{; 
		
		assert `variable' == 0 if (ref_yr <= 1990 | (ref_yr == 1991 & ref_mo <=9));
		replace `variable' = . if (ref_yr <= 1990 | (ref_yr == 1991 & ref_mo <=9));
				
		assert `variable' == 0  if ref_yr == 1991 & ref_mo == 10 & inlist(qtr_month, 2, 3, 4);
		replace `variable' = .  if ref_yr == 1991 & ref_mo == 10 & inlist(qtr_month, 2, 3, 4);
		
		assert `variable' == 0  if ref_yr == 1991 & ref_mo == 11 & inlist(qtr_month, 3, 4);
		replace `variable' = .  if ref_yr == 1991 & ref_mo == 11 & inlist(qtr_month, 3, 4);
		
		assert `variable' == 0  if ref_yr == 1991 & ref_mo == 12 & inlist(qtr_month, 4);
		replace `variable' = .  if ref_yr == 1991 & ref_mo == 12 & inlist(qtr_month, 4);
		
		};	
		
	foreach variable of global added_1994
	
		{;
		
		assert (`variable' == 0 | `variable' == .) if ref_yr <= 1993;
		replace `variable' = . if ref_yr <= 1993;
		
		};
		
	foreach variable of global dropped_1994
	
		{;
		
		assert `variable' == 0 if ref_yr >= 1994;
		replace `variable' = . if ref_yr >= 1994;
		
		};
		
	************************************************************************************;	
	
	/*
	** Market value of home must be multiplied by 12 to get
	** actual value of home
	*/
	replace vhome = vhome * 12;
	
	/*
	** Mortgage payments (interest and principal)
	** Principal is a negative value, so subtract to get total interest and principal payments.
	*/
	gen mortpay = exp_220311 + exp_220312 - (mortprinop + mortprinh + mortprinvh);
	

******************************* I. All Durables, non-durables, & non HH-related durables ***************************;  


	*more detailed durables categories;
	*based mostly on cex aggregations;
	
	
	*  r. section 8 furnishings and hh items  (i separate into furniture, floorwindow, and otherhhitems);
	    gen hh_furniture  = 
		exp_290210 +	/* Sofas  */  
		exp_290310 +	/* Living room chairs                                                                                    			 */
		exp_290320 +	/* Living room tables                                                                                    			 */
		exp_290440 +	/* Modular wall units, shelves or cabinets; other living room, family or recreation room furniture       			 */
		exp_290110 +	/* Mattresses and springs                                                                                			 */
		exp_290120 +	/* Other bedroom furniture                                                                               			 */
		exp_290410 +	/* All kitchen and dining room furniture                                                                 			 */
		exp_290420 +	/* Infants’ furniture                                                                                    			 */
		exp_290430 +	/* Patio, porch, or outdoor furniture                                                                    			 */
		exp_320901 +	/* Office furniture for home use                                                                         			 */
		exp_340904;	*Rental of furniture;
		
		
	    gen just_furniture =   exp_600210;	*Ping-Pong, pool tables, other similar recreation room items,;
	    					*general sports equipment, and...;  
	
	
		
	    gen furniture = hh_furniture + just_furniture; 
	
	    gen hh_floorwindow = 
		exp_230131 +	/* INSTALLED WALL TO WALL CARPETING REPLACEMENT RENTER                                                   			 */
		exp_230132 +	/* INSTALLED WALL TO WALL CARPETING REPLACEMENT OWNED                                                    			 */
		exp_230133 +	/* Installed and non-installed replacement wall to wall carpeting for owned homes                        			 */
		exp_230134 +	/* Installed and non-installed original wall to wall carpeting for rental homes                          			 */
		exp_320110 +	/* ROOMSIZE RUGS AND OTHER NON-PERMANENT FLOOR COVERINGS                                                 			 */
		exp_320111 +	/* Carpet squares for owned and rented homes (Non-Permanent)                                             			 */
		exp_320161 +	/* NON-INSTALLED WALL TO WALL CARPETING AND CARPET SQUARES RENTER                                        			 */
		exp_320162 +	/* Non-installed wall to wall carpeting (replacement) and carpet squares – homeowner                     			 */
		exp_320163 +	/* Installed and non-installed replacement wall to wall carpeting for rental homes                       			 */
		exp_280210 +	/* Curtains and drapes                                                            			 */
		exp_320120;	*Venetian blinds, window shades and other window coverings;
		
	    gen floorwindow = hh_floorwindow;  	*All floorwindow items are hh items;
	
	    gen hh_otherhhitems = 
		exp_320130 +	/* Infants’ equipment                                                                                    			 */
		exp_320150 +	/* Outdoor equipment                                                                                     			 */
		exp_320210 +	/* Clocks, deleted 2007Q2                                                                                                			 */
		exp_320220 +	/* Lamps and other lighting fixtures                                                                     			 */
		exp_320230 +	/* OTHER HOUSEHOLD DECORATIVE ITEMS (1980-81)                                                            			 */
		exp_320231 +	/* Other household decorative items, deleted 2007Q2                                                                      			 */
		exp_320233 +    /* Clocks and other household decorative items, new 2007Q2 */
		exp_320904 +	/* Closet storage items                                                                                  			 */
		exp_430130 +	/* Travel items, including luggage, and luggage carriers                                                 			 */
		exp_320310 +	/* Plastic dinnerware                                                                                    			 */
		exp_320320 +	/* China and other dinnerware                                                                            			 */
		exp_320330 +	/* Stainless, silver and other flatware                                                                  			 */
		exp_320340 +	/* Glassware                                                                                             			 */
		exp_320350 +	/* Silver serving pieces                                                                                 			 */
		exp_320360 +	/* Serving pieces other than silver                                                                      			 */
		exp_320370 +	/* Non-electric cookware                                                                                 			 */
		exp_280110 +	/* Bathroom linens                                                                                       			 */
		exp_280120 +	/* Bedroom linens                                                                                        			 */
		exp_280130 +	/* Kitchen and dining room linens                                                                        			 */
		exp_280900 +	/* Other linens                                                                                          			 */
		exp_280220 +	/* Slipcovers, decorative pillows, and cushions                                                          			 */
		exp_280230 +	/* Sewing materials for slipcovers, curtains, and other home handiwork                                   			 */
		exp_320903;	/* Fresh flowers or potted plants    */;
		
	     gen otherhhitems = hh_otherhhitems; 	*all otherhhitems are hh items; 
	
	*  o. section 6 appliances, hh equipment, and other selected items;
	     gen hh_appl_big =                                         
	     
	        exp_230117 +	/* Built-in dishwasher, garbage disposal, or range hood for jobs considered replacement or               			 */
		exp_230118 +	/* Same as 230117 - owned home                                                                           			 */
		exp_300111 +	/* Purchase and installation of refrigerator or home freezer – renter                                    			 */
		exp_300112 +	/* Purchase and installation of refrigerator or home freezer – homeowner                                 			 */
		exp_300211 +	/* Purchase and installation of clothes washer – renter                                                  			 */
		exp_300212 +	/* Purchase and installation of clothes washer – homeowner                                               			 */
		exp_300221 +	/* Purchase and installation of clothes dryer – renter                                                   			 */
		exp_300222 +	/* Purchase and installation of clothes dryer – homeowner                                                			 */
		exp_300311 +	/* Purchase and installation of cooking stove, range or oven, excl. microwave – renter                   			 */
		exp_300312 +	/* Purchase and installation of cooking stove, range or oven, excl. microwave – homeowner                			 */
		exp_300321 +	/* Purchase and installation of microwave oven – renter                                                  			 */
		exp_300322 +	/* Purchase and installation of microwave oven – homeowner                                               			 */
		exp_300331 +	/* Purchase and installation of portable dishwasher – renter                                             			 */
		exp_300332; 	/* Purchase and installation of portable dishwasher – homeowner */;                                          			 
	
	      gen appl_big = hh_appl_big; *All large appliances are considered to be hh items;
	
	
	*  p. section 6 appliances, hh equipment, and other selected items  (i separate into electronics, fun stuff, and mischhequip);
	
	  gen hh_electronics = 
	  
	        exp_690210 +	/* Telephone answering devices                                                                           			 */
	  	exp_690220 +	/* Calculators                                                                                           			 */
		exp_690230 +	/* Typewriters and other office machines for non-business use 								  	 */
	    	exp_690111 +	/* Computers, computer systems, and related hardware for non-business use                                			 */
	  	exp_690112 +	/* Computer software and accessories for non-business use                                                			 */
	  	exp_690310 +    /* Installation for computers, added 2007Q2 											 */ 
	  	exp_690115 +	/* Personal digital assistants                                                                           			 */
	  	exp_690117 +    /* Portable memory, added 2009Q2 */
	  	exp_320232;	/* Telephones and accessories */;                                                                            		
	  	
	  gen just_electronics =  
		exp_310110 +	/* Black and white TV, and combinations of TV with other items                                           			 */
		exp_310120 +	/* Color TV console and combinations of TV; large screen color TV projection equipment; color            			 */
		exp_310130 +	/* Color TV (portable and table models)                                                                  			 */
		exp_310140 +	/* Televisions                                                                                           			 */
		exp_310210 +	/* VCR, video disc player, video camera, and camcorder                                                   			 */
		exp_310220 +	/* Video cassettes, tapes, and discs                                                                     			 */
		exp_310230 +	/* TV computers games and computer game software                                                         			 */
		exp_310311 +	/* Radio                                                                                                 			 */
		exp_310313 +	/* Tape recorder and player                                                                              			 */
		exp_310314 +	/* Digital audio players                                                                                 			 */
		exp_310320 +	/* Sound components, component systems, and compact disc sound systems                                   			 */
		exp_310330 +	/* ACCESSORIES AND OTHER SOUND EQUIPMENT                                                                 			 */
		exp_310333 +	/* Accessories and other sound equipment including phonographs                                           			 */
		exp_310312 +	/* PHONOGRAPHS                                                                                           			 */
		exp_270310 +	/* Cable, satellite, or community antenna service;                                           			 */
		exp_690110 +	/* COMPUTERS FOR NON-BUSINESS USE                                                                        			 */
                exp_270311 +    /* Satellite radio service, added 2007Q2											 */
		exp_310334 +	/* Satellite dishes                                                                                      			 */
		exp_690330 +    /* Installation for satellite TV equipment */
		exp_340610 +	/* Repair of television, radio, and sound equipment, excluding installed in vehicles                     			 */
		exp_340902 +	/* Rental of televisions                                                                                 			 */
		exp_620916 +    /* Rental of video or computer hardward or software, added 2007Q2 */
		exp_690320 +    /* Installation for TVs, new 2007Q2 */
		exp_690340 +    /* Installation of sound systems, new 2007Q2  */
		exp_690350 +    /* Installation of other video or sound systems, new 2007Q2 */ 
		exp_340905; 	/* Rental of VCR, radio, and sound equipment – see 310210, 310311-310330     */;
	
	  gen electronics = just_electronics + hh_electronics;
	
	
	
	  gen just_funstuff = 
		exp_610130 +	/* Musical instruments, supplies, and accessories                                                        			 */
		exp_620904 +	/* Rental and repair of musical instruments, supplies, and accessories                                   			 */
		exp_600310 +	/* Bicycles                                                                                              			 */
		exp_600410 +	/* Camping equipment                                                                                     			 */
		exp_600420 +	/* Hunting and fishing equipment                                                                         			 */
		exp_600430 +	/* Winter sports equipment                                                                               			 */
		exp_600900 +	/* WATER SPORTS EQUIPMENT                                                                                			 */
		exp_600901 +	/* Water sports equipment                                                                                			 */
		exp_600902 +	/* Other sports equipment                                                                                			 */
		exp_600110 +	/* Outboard motor                                                                                        			 */
		exp_610110 +	/* Toys, games, arts, crafts, tricycles, and battery powered riders                                      			 */
		exp_610120 +	/* Playground equipment                                                                                  			 */
		exp_310340 +	/* Records, CDs, audio tapes                                                                             			 */
		exp_310341 +	/* Compact discs, tapes, videos, or records purchased from a club                                        			 */
		exp_310342 +	/* Compact discs, tapes, needles, or records not from a club                                             			 */
		exp_620912; 	/* Rental of video cassettes, tapes, and discs                                                           			 */;
	
	   gen funstuff = just_funstuff; *All funstuff is just_funstuff;
		
	   gen hh_mischhequip = 
		exp_320521 +	/* Small electrical kitchen appliances                                                                   			 */
		exp_690241 +	/* Purchases and rentals of smoke alarms and detectors – renter                                          			 */
		exp_690242 +	/* Same as 690241 – owned home                                                                           			 */
		exp_690243 +	/* Same as 690241 – owned vacation home                                                                  			 */
		exp_690244 +	/* Other household appliances – renter                                                                   			 */
		exp_320511 +	/* Electric floor cleaning equipment                                                                     			 */
		exp_320512 +	/* Sewing machines                                                                                       			 */
		exp_320410 +	/* Lawnmowing equipment and other yard machinery                                                         			 */
		exp_320420 +	/* Power tools                                                                                           			 */
		exp_320902 +	/* Non-power tools                                                                                       			 */
		exp_300411 +	/* Window air conditioner – renter                                                                       			 */
		exp_300412 +	/* Window air conditioner – homeowner                                                                    			 */
		exp_320522 + 	/* Portable heating and cooling equipment */  
		exp_690245;	*Same as 690244 – homeowner; 
	
	
	    gen just_mischhequip = 
	
 		exp_610230; 	/* Photographic equipment  */	
 		 
 
 	    gen mischhequip = hh_mischhequip + just_mischhequip;
 	    
		*--- Individual Variables for durable tranportation items -----*;
		
		
		
	gen newcars = exp_450110;     * New cars (net outlay); 
	gen usedcars = exp_460110;    * Used cars (net outlay);
	gen newtrucks = exp_450210;   * New trucks or vans (net outlay);
	gen usedtrucks = exp_460901;  * Used trucks or vans (net outlay);
	gen newmcycles = exp_450220;  * New motorcycles, motor scooters, or mopeds (net outlay);
	gen usedmcycles = exp_460902; * Used motorcycles, motor scooters, or mopeds (net outlay); 
	gen boat_wom = exp_600121;    * Boat without motor or non camper-type trailer, such as for boat or cycle (net outlay); 
	gen camper = exp_600122;      * Trailer-type or other attachable-type camper (net outlay);                             
	gen mcamperc = exp_600131;    * MOTORIZED CAMPER COACH AND OTHER VEHICLES, dropped after 1993;                                            
	gen boat_wm = exp_600132;     * Boat with motor (net outlay);                                                          
	gen pmcamper = exp_600141;    * Purchase of motorized camper, added 1993;                                                          
	gen otherveh = exp_600142;    * Purchase of other vehicle, added 1993; 	
		
	gen commute_durable = newcars + usedcars + newtrucks + usedtrucks + newmcycles + usedmcycles;
	gen noncommute_durable = boat_wom + camper + mcamperc + boat_wm + pmcamper + otherveh;                                                                       			
        gen transp = commute_durable + noncommute_durable;
	
gen durable_exp = furniture + floorwindow + otherhhitems + appl_big + electronics + funstuff + mischhequip + transp;
gen non_durable_exp = tot_exp - durable_exp;
gen housing_durable = hh_furniture + hh_floorwindow + hh_appl_big + hh_electronics + hh_mischhequip + hh_otherhhitems;
gen dur_less_hous = durable_exp - housing_durable;


************************************** II. Work Related Expenditures *********************************************;


	gen ccare_exp = exp_340210 +	 /*	BABYSITTING OR OTHER HOME CARE FOR CHILDREN                                                                       */
	                exp_340211 +	 /*	Babysitting or other child care in your own home                                                                  */
	                exp_340212 +	 /*	Babysitting or other child care in someone else’s home                                                            */
	                exp_670310;		 /*	Housekeeping service, incl. management fees for maid service in condos                                            */;
			
	gen transp_nondurable = 																																																
	                 exp_450310 +	 /*	Basic lease charge (car lease)                                                                     								*/
	                 exp_450313 +    /*	Cash down payment (car lease)                                                                      								*/
	                 exp_450314 +	 /*	Termination fee (car lease)                                                                        								*/
	                 exp_450410 +	 /*	Basic lease charge (truck/van lease)                                                               								*/
	                 exp_450413 +  /*	Cash down payment (truck/van lease)                                                                								*/
	                 exp_450414 +  /*	Termination fee (truck/van lease)                                                                  								*/
	                 exp_470111 +  /*	Gasoline                                                                                           								*/
	                 exp_470112 +  /*	Diesel fuel                                                                                        								*/
	                 exp_470113	+	 /*	Gasoline on out-of-town trips                                                                      							*/
	                 exp_470211 +	 /*	Motor oil                                                                                          								*/
	                 exp_470212 +  /*	Motor oil on out-of-town trips                                                                     								*/
	                 exp_470220 +	 /*	Coolant/antifreeze, brake & transmission fluids, additives, and radiator/cooling system            								*/
	                 exp_480110 +  /*	Tires (new, used or recapped); replacement and mounting of tires, including tube                   								*/
	                 exp_480211 +	 /*	TUBES FOR TIRES, BATTERIES, AIR CONDITIONERS, AND ANY OTHER VEHICLE EQUIPMENT                      								*/
	                 exp_480212 +	 /*	Vehicle products and services                                                                      								*/
	                 exp_480213 +	 /*	Vehicle parts, equipment, and accessories                                                          								*/
			 exp_480214 +  /*	Vehicle audio equipment excluding labor                                                            								*/
			 exp_480215 +  /*	Vehicle video equipment                                                                            								*/
			 exp_490110 +	 /*	Body work, painting, repair and replacement of upholstery, vinyl/convertible top, and glass,       								*/
			 exp_490211 +	 /*	Clutch and transmission repair                                                                     								*/
		         exp_490212 +  /*	Drive shaft and rear-end repair                                                                    								*/
			 exp_490220 +  /*	BRAKE WORK, EXCLUDING BRAKE ADJUSTMENT                                                            								*/
			 exp_490221 +	 /*	Brake work                                                                                         								*/
			 exp_490231 +  /*	Steering or front end repair                                                                       								*/
			 exp_490232 +  /*	Cooling system repair                                                                              								*/
			 exp_490311 +  /*	Motor tune-up                                                                                      								*/
			 exp_490312 +  /*	Lubrication and oil changes                                                                        								*/
			 exp_490313 +	 /*	Front end alignment, wheel balance and rotation                                                    								*/
			 exp_490314 +	 /*	Shock absorber replacement                                                                         								*/
			 exp_490315 +  /*	BRAKE ADJUSTMENT                                                                                   								*/
			 exp_490317 +	 /*	MINOR REPAIRS AND SERVICES OUT-OF-TOWN TRIPS                                                       								*/
			 exp_490318 +  /*	Repair tires and miscellaneous repair work, such as battery charge, wash, wax, repair and          								*/
			 exp_490319 +  /*	Vehicle air conditioner repair                                                                     								*/
			 exp_490411	+  /*	Exhaust system repair                                                                              								*/
			 exp_490412	+	 /*	Electrical system repair                                                                           							*/
			 exp_490413 +	 /*	Motor repair and replacement                                                                       								*/
			 exp_490500 +	 /*	Purchase and installation of vehicle accessories, incl. audio                                      								*/
			 exp_490501 +	 /*	Vehicle accessories including labor                                                                								*/
			 exp_490502 +	 /*	Vehicle audio equipment including labor                                                            								*/
			 exp_490900 +  /*	Auto repair service policy                                                                         								*/
			 exp_500110 +  /*	Vehicle insurance                                                                                  								*/
			 exp_510110 +  /*	Automobile finance charges                                                                         								*/
			 exp_510901 +  /*	Truck or van finance charges                                                                       								*/
			 exp_510902 +  /*	Motorcycle finance charges                                                                         								*/
			 exp_520110 +	 /*	STATE AND LOCAL VEHICLE REGISTRATION                                                               								*/
			 exp_520111 +	 /*	State vehicle registration                                                                         								*/
			 exp_520112 +  /*	Local vehicle registration                                                                         								*/
			 exp_520310 +  /*	Driver’s license                                                                                   								*/
			 exp_520410 +  /*	Vehicle inspection                                                                                 								*/
			 exp_520511 +  /*	Auto rental, excl. trips                                                                           								*/
			 exp_520512 +  /*	Auto rental on out-of-town trips                                                                   								*/
			 exp_520521 +	 /*	Truck or van rental, excl. trips                                                                   								*/
			 exp_520522	+  /*	Truck or van rental on out-of-town trips                                                           								*/
			 exp_520530 +	 /*	PARKING FEES, INCLUDING GARAGES, METERS, LOT FEES, EXCLUDING THAT INCLUDED IN                      								*/
			 exp_520531 +	 /*	Parking fees at garages, meters, and lots excl. fees that are costs of property ownership          								*/
			 exp_520532 +	 /*	Parking fees on out-of-town trips                                                                  								*/
			 exp_520541 +	 /*	Tolls or electronic toll passes                                                                    								*/
			 exp_520542 +	 /*	Tolls on out-of-town trips                                                                         								*/
			 exp_520550 +	 /*	Towing charges (excl. contracted or pre-paid)                                                      								*/
			 exp_520560 +	 /*	Global positioning services                                                                        								*/
			 exp_520902 +	 /*	Motorcycle, motor scooter, or moped rental                                                         								*/
			 exp_520903 +  /*	Aircraft rental                                                                                    								*/
			 exp_520905 +  /*	Same as 520902 – out-of-town trips                                                                 								*/
			 exp_520906 +  /*	Aircraft rental on out-of-town trips                                                               								*/
			 exp_530110 +	 /*	Airline fares on out-of-town trips                                                                 								*/
			 exp_530210 +	 /*	Intercity bus fares on out-of-town trips                                                           								*/
			 exp_530311 +  /*	Intracity mass transit fares                                                                       								*/
			 exp_530312 +  /*	Local transportation (excl. taxis) on out-of-town trips                                            								*/
			 exp_530411 +  /*	Taxi fares on out-of-town trips                                                                    								*/
			 exp_530412 +  /*	Taxi fares and limousine service (not on trips)                                                    								*/
			 exp_530510 +  /*	Intercity train fares on out-of-town trips                                                         								*/
			 exp_530901 +	 /*	Ship fares on out-of-town trips                                                                    								*/
			 exp_530902 +  /*	Private school bus                                                                                 								*/
			 exp_620113 +  /*	Membership fees for automobile service clubs                                                       								*/
			 exp_850300;	 /*	Finance charges on other vehicles */;	
	
	gen transp_exp = commute_durable + transp_nondurable;
	
	gen clothing_exp = exp_360110 +  /* Men’s suits                                                                                    									*/
	                   exp_360120 +  /* Men’s sport coats                                                                              									*/
	                   exp_360210 +  /* Men’s coats, jackets, and furs                                                                 									*/
	                   exp_360311 +  /* Men’s underwear                                                                                									*/
	                   exp_360312 +  /* Men’s hosiery                                                                                  									*/
	                   exp_360320 +  /*	Men’s nightwear                                                                                									*/
			   exp_360330 +  /*	Men’s accessories                                                                              									*/
			   exp_360340 +  /*	Men’s sweaters and vests                                                                       									*/
			   exp_360350 +  /*	Men’s active sportswear                                                                        									*/
			   exp_360410 +  /*	Men’s shirts                                                                                   									*/
			   exp_360511 +  /*	Men’s pants, deleted 2007Q2                                                                                    									*/
			   exp_360512 +	 /*	Men’s shorts and shorts sets, excl. athletic, deleted 2007Q2                                                   									*/
                     	   exp_360513 +  /* Men’s pants and shorts, added 2007Q2 									*/
                     	   exp_360901 +  /*	Men’s uniforms                                                                                 									*/
                     	   exp_360902 +  /*	Men’s other clothing, incl. costumes                                                           									*/
                     	   exp_370110 +  /*	Boys’ coats, jackets, and furs                                                                 									*/
                     	   exp_370120 +  /*	Boys’ sweaters                                                                                 									*/
                     	   exp_370130 +  /*	Boys’ shirts                                                                                   									*/
                     	   exp_370211 +  /*	Boys’ underwear                                                                                									*/
                     	   exp_370212 +  /*	Boys’ nightwear                                                                                									*/
                     	   exp_370213 +	 /*	Boys’ hosiery                                                                                  									*/
			   exp_370220 +  /*	Boys’ accessories                                                                              									*/
			   exp_370311	+  /*	Boys’ suits, sport coats, and vests                                                            									*/
			   exp_370312	+  /*	Boys’ pants, deleted 2007Q2                                                                                    									*/
			   exp_370313 +  /*	Boys’ shorts and shorts sets, excl. athletic, deleted 2007Q2                                                   									*/
			   exp_370314 +  /*	Boys’ pants and shorts, added 2007Q2																*/
			   exp_370901 +	 /*	BOYS' UNIFORMS AND ACTIVE SPORTSWEAR                                                           									*/
			   exp_370902 +  /*	Boys’ other clothing, incl. costumes                                                           									*/
			   exp_370903 +	 /*	Boys’ uniforms                                                                                 									*/
			   exp_370904 +  /*	Boys’ active sportswear                                                                        									*/
			   exp_380110 +  /*	Women’s coats, jackets, and furs                                                               									*/
			   exp_380210 +  /*	Women’s dresses                                                                                									*/
			   exp_380311 +  /*	Women’s sport coats and tailored jackets                                                       									*/
			   exp_380312 +  /*	Women’s vests, sweaters, and sweater sets                                                      									*/
			   exp_380313 +  /*	Women’s shirts, tops, and blouses                                                              									*/
			   exp_380320 +	 /*	Women’s skirts and culottes                                                                    									*/
			   exp_380331 +  /*	Women’s pants, deleted 2007Q2                                                                                  									*/
			   exp_380332 +  /*	Women’s shorts and shorts sets, excl. athletic, deleted 2007Q2                                                 									*/
			   exp_380333 +  /* 	Women’s pants and shorts, added 2007Q2															        */
			   exp_380340 +  /*	Women’s active sportswear                                                                      									*/
			   exp_380410 +  /*	Women’s nightwear                                                                              									*/
			   exp_380420 +  /*	Women’s undergarments                                                                          									*/
			   exp_380430 +	 /*	Women’s hosiery                                                                                									*/
			   exp_380510 +  /*	Women’s suits                                                                                  									*/
			   exp_380901	+  /*	Women’s accessories                                                                            									*/
			   exp_380902 +  /*	Women’s uniforms                                                                               									*/
			   exp_380903 +  /*	Women’s other clothing, incl. costumes                                                         									*/
			   exp_390110 +  /*	Girls’ coats, jackets, and furs                                                                									*/
			   exp_390120 +  /*	Girls’ dresses and suits                                                                       									*/
			   exp_390210 +  /*	Girls’ sport coats, tailored jackets, shirts, blouses, sweaters, sweater sets, and vests       									*/
			   exp_390221 +  /*	Girls’ skirts, culottes, and pants, deleted 2007Q2                                                             									*/
			   exp_390222 +  /*	Girls’ shorts and shorts sets, excl. athletic, deleted 2007Q2                                                  									*/
			   exp_390223 +  /*   	Girls’ skirts, pants, and shorts, new 2007Q2																*/
			   exp_390230 +	 /*	Girls’ active sportswear                                                                       									*/
			   exp_390310 +  /*	Girls’ undergarments and nightwear                                                             									*/
			   exp_390321 +  /*	Girls’ hosiery                                                                                 									*/
			   exp_390322 +  /*	Girls’ accessories                                                                             									*/
			   exp_390901 +  /*	Girls’ uniforms                                                                                									*/
			   exp_390902 +  /*	Girls’ other clothing, incl. costumes                                                          									*/
			   exp_400110 +  /*	Men’s footwear                                                                                 									*/
			   exp_400210 +	 /*	Boys’ footwear                                                                                 									*/
			   exp_400220 +	 /*	Girls’ footwear                                                                                									*/
			   exp_400310 +  /*	Women’s footwear                                                                               									*/
			   exp_410110 +	 /*	Infants’ coats, jackets, and snowsuits                                                         									*/
			   exp_410111 +	 /*	INFANT COATS, JACKETS, AND SNOWSUITS (from section 9B of the questionnaire)                    									*/
			   exp_410112 +  /*	INFANT COATS, JACKETS, AND SNOWSUITS (from section 9A of the questionnaire)                    									*/
			   exp_410120 +	 /*	Infants’ dresses and other outerwear                                                           									*/
			   exp_410121	+	 /*	INFANT DRESSES AND OUTERWEAR 9B                                                                									*/
			   exp_410122 +  /*	INFANT DRESSES AND OUTERWEAR 9A                                                                									*/
			   exp_410130	+	 /*	Infants’ undergarments, incl. diapers                                                          									*/
			   exp_410131 +	 /*	INFANT UNDERGARMENTS 9B, INCLUDING DIAPERS                                                     									*/
			   exp_410132 +	 /*	INFANT UNDERGARMENTS 9A, INCLUDING DIAPERS                                                     									*/
			   exp_410140 +	 /*	Infants’ sleeping garments                                                                     									*/
			   exp_410141 +	 /*	INFANT SLEEPING GARMENTS 9B                                                                    									*/
			   exp_410142 +  /*	INFANT SLEEPING GARMETS 9A                                                                     									*/
			   exp_410901 +  /*	Infants’ accessories, hosiery, and footwear                                                    									*/
			   exp_410903 +  /*	INFANT ACCESSORIES 9A                                                                          									*/
			   exp_410904 +  /*	INFANT HOSIERY, FOOTWEAR, AND OTHER CLOTHING 9A                                                									*/
			   exp_420110 +  /*	Sewing materials for making clothes                                                            									*/
			   exp_420120 +  /*	Sewing notions, patterns                                                                       									*/
			   exp_430110 +  /*	Watches                                                                                        									*/
			   exp_430120 +  /*	Jewelry                                                                                        									*/
			   exp_440110 +  /*	Shoe repair and other shoe services                                                            									*/
			   exp_440120 +	 /*	Apparel laundry and dry cleaning – coin-operated                                               									*/
			   exp_440130 +  /*	Alteration, repair, and tailoring of apparel and accessories                                   									*/
			   exp_440140 +  /*	Clothing rental                                                                                									*/
			   exp_440150 +  /*	Watch and jewelry repair                                                                       									*/
			   exp_440210 +  /*	Apparel laundry and dry cleaning – not coin-operated                                           									*/
			   exp_440900;	 /*	Clothing storage */;

gen work_exp = ccare_exp + transp_exp + clothing_exp;

*************************************** III. HH Expenditures ****************************************************;

gen housing_nondurable =  
			exp_210110 +	/* Rent of dwelling                                                                                            */
			exp_210210 +	/* Lodging away from home on trips                                                                             */
			exp_210310 +	/* Housing for someone at school                                                                               */
			exp_210901 +	/* Ground rent - owned home                                                                                    */
			exp_210902 +	/* Ground rent - owned vacation home                                                                           */
			exp_220111 +	/* FIRE AND EXTENDED COVERAGE OWNED                                                                            */                                         
			exp_220112 +	/* FIRE AND EXTENDED COVERAGE OWNED VACATION                                                                   */                                         
			exp_220121 +	/* Homeowners insurance - owned home includeng fire and extended coverage; management                          */
			exp_220122 +	/* Same as 220121 - owned vacation home, vacation coops                                                        */
			exp_220211 +	/* Property taxes - owned home; management fees for property taxes in coops (non-vacation)                     */
			exp_220212 +	/* Same as 220211 - owned vacation home, vacation coops                                                        */
			exp_220311 +	/* Mortgage interest - owned home; portion of management fees for repayment of loans in                        */
			exp_220312 +	/* Same as 220311 - owned vacation home; vacation coops                                                        */
			exp_220313 +	/* Interest on home equity loan - owned home                                                                   */
			exp_220314 +	/* Interest on home equity loan - owned vacation home                                                          */
			exp_220321 +	/* Penalty charges on special or lump-sum mortgage payment - owned home, deleted 2007Q2                        */
			exp_220322 +	/* Penalty charges on special or lump-sum mortgage payment - owned vacation home, deleted 2007Q2               */
			exp_220901 +	/* Parking at owned home; management fees for parking in condos and coops (non-vacation)                       */
			exp_220902 +	/* Parking at owned vacation home, vacation condos and coops                                                   */
			exp_230111 +	/* REPAIR OR MAINTENANCE SERVICES RENTER                                                                       */                                     
			exp_230112 +	/* Contractors labor and material costs, and cost of supplies rented for inside and outside                    */
			exp_230113 +	/* Same as 230112 for plumbing or water heating installations and repairs                                      */
			exp_230114 +	/* Same as 230112 for electrical work and heating or air - conditioning jobs (incl. service                    */
			exp_230115 +	/* Same as 230112 for roofing, gutters, or downspouts                                                          */
			exp_230116 +	/* OTHER REPAIR OR MAINTENANCE SERVICES OWNED                                                                  */                                          
			exp_230119 +	/* REPAIR AND MAINTENANCE SERVICES OWNED VACATION                                                              */                                             
			exp_230121 +	/* Contractors' labor and material costs, and cost of supplies rented for repair or replacement of             */
			exp_230122 +	/* Contractors' labor and material costs, and cost of supplies rented for repair or replacement of             */
			exp_230123 +	/* Same as 230122 - owned vacation home; vacation condos and coops                                             */
			exp_230141 +	/* Service contract charges and cost of maintenance or repair for built-in dishwasher, garbage                 */
			exp_230142 +	/* Same as 230141 - owned home and vacation home                                                               */
			exp_230150 +	/* Repair or maintenance services (renter)                                                                     */
			exp_230151 +	/* Other repair or maintenance services (owned)                                                                */
			exp_230152 +	/* Repair and remodeling services (owned vacation)                                                             */
			exp_230901 +	/* Property management fees - owned home; condos and coops (non-vacation)                                      */
			exp_230902 +	/* Same as 230901 - owned vacation home; vacation condos and coops                                             */
			exp_240111 +	/* Cost of paint, wallpaper, and supplies purchased for inside and outside painting and papering               */
			exp_240112 +	/* Same as 240111 - for jobs considered replacement or maintenance/repair - owned home                         */
			exp_240113 +	/* Same as 240112 - owned vacation home                                                                        */
			exp_240121 +	/* Cost of equipment purchased for inside and outside painting and papering - renter                           */
			exp_240122 +	/* Same as 240121 - for jobs considered replacement or maintenance/repair - owned home                         */
			exp_240123 +	/* Same as 240122 - owned vacation home                                                                        */
			exp_240211 +	/* Cost of supplies purchased for plastering, paneling, roofing and gutters, siding, windows,                  */
			exp_240212 +	/* Cost of supplies purchased for plastering, paneling, siding, windows, screens, doors,                       */
			exp_240213 +	/* Cost of supplies purchased for roofing, gutters, or downspouts for jobs considered                          */
			exp_240214 +	/* Same as 240212-240213 - owned vacation home                                                                 */
			exp_240221 +	/* Cost of supplies purchased for masonry, brick or stucco work; portion of cost of supplies                   */
			exp_240222 +	/* Same as 240221 for jobs considered replacement or maintenance/repair - owned home                           */
			exp_240223 +	/* Same as 240222 - owned vacation home                                                                        */
			exp_240311 +	/* Cost of supplies purchased for plumbing or water heating installations and repairs - renter                 */
			exp_240312 +	/* Same as 240311 for jobs considered replacement or maintenance/repair - owned home                           */
			exp_240313 +	/* Same as 240312 - owned vacation home                                                                        */
			exp_240321 +	/* Cost of supplies purchased for electrical work, heating or air conditioning jobs - renter                   */
			exp_240322 +	/* Same as 240321 for jobs considered replacement or maintenance/repair - owned home                           */
			exp_240323 +	/* Same as 240322 - owned vacation home                                                                        */
			exp_250111 +	/* Fuel oil - renter                                                                                           */
			exp_250112 +	/* Fuel oil - owned home; portion of management fees for utilities in condos and coops (non                    */
			exp_250113 +	/* Same as 250112 - owned vacation home; vacation condos and coops                                             */
			exp_250114 +	/* Fuel oil - rented vacation property                                                                         */
			exp_250211 +	/* Gas, bottled or tank - renter                                                                               */
			exp_250212 +	/* Gas, bottled or tank - owned home                                                                           */
			exp_250213 +	/* Gas, bottled or tank - owned vacation home                                                                  */
			exp_250214 +	/* Gas, bottled or tank - rented vacation property                                                             */
			exp_250221 +	/* Coal - renter                                                                                               */
			exp_250222 +	/* Coal - owned home                                                                                           */
			exp_250223 +	/* Coal - owned vacation home                                                                                  */
			exp_250224 +	/* Coal - rented vacation property                                                                             */
			exp_250901 +	/* Wood, kerosene, and other fuels - renter                                                                    */
			exp_250902 +	/* Wood, kerosene, and other fuels - owned home                                                                */
			exp_250903 +	/* Wood, kerosene, and other fuels - owned vacation home                                                       */
			exp_250904 +	/* Wood, kerosene, and other fuels - rented vacation property                                                  */
			exp_250911 +	/* Other fuels – renter                                                                                        */
			exp_250912 +	/* Other fuels – owned home                                                                                    */
			exp_250913 +	/* Other fuels – owned vacation home                                                                           */
			exp_250914 +	/* Other fuels – rented vacation property                                                                      */
			exp_260111 +	/* Electricity – renter                                                                                        */
			exp_260112 +	/* Electricity – owned home; portion of management fees for utilities in condos and coops (nonvacation)        */
			exp_260113 +	/* Same as 260112 – owned vacation home; vacation condos and coops                                             */
			exp_260114 +	/* Electricity – rented vacation property                                                                      */
			exp_260211 +	/* Natural or utility gas – renter                                                                             */
			exp_260212 +	/* Natural or utility gas – owned home; portion of management fees for utilities in condos and                 */
			exp_260213 +	/* Same as 260212 – owned vacation home; vacation condos and coops                                             */
			exp_260214 +	/* Natural or utility gas – rented vacation property                                                           */
			exp_270000 +	/* TELEPHONE SERVICE NOT SPECIFIED                                                                             */
			exp_270101 +	/* Residential telephone or pay phones                                                                         */
			exp_270102 +	/* Cellular phone service                                                                                      */
			exp_270103 +	/* Pager services, deleted 2006Q2                                                                              */
			exp_270104 +	/* Phone cards                                                                                                 */
			exp_270105 +    /* Voice over IP telephone service, added 2007Q2							       */
			exp_270211 +	/* Water and sewerage maintenance – renter                                                                     */
			exp_270212 +	/* Water and sewerage maintenance – owned home; portion of management fees for utilities in                    */
			exp_270213 +	/* Same as 270212 – owned vacation home; vacation condos and coops                                             */
			exp_270214 +	/* Water and sewerage maintenance – rented vacation property                                                   */
			exp_270411 +	/* Trash and garbage collection – renter                                                                       */
			exp_270412 +	/* Trash and garbage collection – owned home; management fees for trash collection in                          */
			exp_270413 +	/* Same as 270412 – owned vacation home; vacation condos and coops                                             */
			exp_270414 +	/* Trash and garbage collection – rented vacation property                                                     */
			exp_270901 +	/* Septic tank cleaning – renter                                                                               */
			exp_270902 +	/* Septic tank cleaning – owned home                                                                           */
			exp_270903 +	/* Septic tank cleaning – owned vacation home                                                                  */
			exp_270904 +	/* Septic tank cleaning – rented vacation property                                                             */
			exp_320611 +	/* Cost of supplies purchased for insulation and other improvements/repairs; materials and                     */
			exp_320612 +	/* Cost of supplies purchased for insulation and other improvements/repairs for jobs considered                */
			exp_320613 +	/* Cost of supplies purchased for insulation and other improvements/repairs for jobs considered                */
			exp_320621 +	/* Cost of supplies purchased for repair or replacement of hard surfaced flooring – renter                     */
			exp_320622 +	/* Cost of supplies purchased for repair or replacement of hard surfaced flooring for jobs                     */
			exp_320623 +	/* Same as 320622 – owned vacation home                                                                        */
			exp_320631 +	/* Cost of supplies purchased for landscaping – renter                                                         */
			exp_320632 +	/* Cost of supplies purchased for landscaping for jobs considered replacement or                               */
			exp_320633 +	/* Same as 320632 – owned vacation home                                                                        */
			exp_330511 +	/* Cost of materials purchased for termite and pest control for jobs considered replacement or                 */
			exp_340210 +	/* BABYSITTING OR OTHER HOME CARE FOR CHILDREN                                                                 */
			exp_340211 +	/* Babysitting or other child care in your own home                                                            */
			exp_340212 +	/* Babysitting or other child care in someone else’s home                                                      */
			exp_340310 +	/* Housekeeping service, incl. management fees for maid service in condos                                      */
			exp_340410 +	/* Gardening and lawn care services, incl. management fees for lawn care in coops and                          */
			exp_340420 +	/* Water softening service                                                                                     */
			exp_340510 +	/* Moving, storage, and freight express                                                                        */
			exp_340520 +	/* Non-clothing household laundry or dry cleaning – not coin-operated                                          */
			exp_340530 +	/* Non-clothing household laundry or dry cleaning – coin-operated                                              */
			exp_340620 +	/* Repair of household appliances, excl. garbage disposal, range hood, and built-in dishwasher                 */
			exp_340630 +	/* Furniture repair, refinishing, or reupholstering                                                            */
			exp_340901 +	/* Rental or repair of equipment and other yard machinery, power and non-power tools                           */
			exp_340903 +	/* Miscellaneous home services and small repair jobs not already specified                                     */
			exp_340906 +	/* Care for invalids, convalescents, handicapped or elderly persons in the CU                                  */
			exp_340907 +	/* Rental and installation of household equipment – see 300111-300332                                          */
			exp_340908 +	/* Rental of office equipment for non-business use – see 320232, 690111, 690112, 690210-                       */
			exp_340910 +	/* Adult day care centers                                                                                      */
			exp_340911 +	/* Management fees for security, incl. guards and alarm systems in coops and condos (nonvacation)              */
			exp_340912 +	/* Management fees for security, incl. guards and alarm systems in coops and condos                            */
			exp_340914 +	/* Services for termite/pest control maintenance                                                               */
			exp_340915 +	/* Service fee expenditures for home security systems                                                          */
			exp_350110 +	/* Tenant’s insurance                                                                                          */
			exp_670310 +	/* Other expenses for day care centers and nursery schools, including tuition                                  */
			exp_690113 +	/* Repair of computers, computer systems, and related equipment for non-business use                           */
			exp_690114 +	/* Computer information services                                                                               */
			exp_790690 +	/* Cost of supplies purchased for dwellings and additions being built, finishing basement or                   */
			exp_800710 +	/* Rent received as pay                                                                                        */
			exp_880110 +	/* Interest on line of credit home equity loan – owned home                                                    */
			exp_880310 +	/* Interest on line of credit home equity loan – owned vacation home                                           */
			exp_990900 +	/* Rental and installation of dishwasher, disposal, and range hood                                             */
			exp_990910 +	/* Cost of supplies purchased by consumer unit for termite or                                                  */
			exp_990920 +	/* Cost of supplies purchased for dwellings and additions being built, finishing basement or                   */
			exp_990930 +	/* Cost of supplies purchased finishing basement or attic, remodeling rooms or building outdoor                */
			exp_990940;		/* Same as 990930 - owned vacation home        							       */;                       

gen housing_exp = housing_nondurable + housing_durable;

******************************************* Trim dataset and label variables ****************************************;

																
	 keep newid 
	     pre1986 
	     ref_yr 
	     ref_mo 
	     qtr_month 
	     tot_exp 
	     vhome 
	     mortpay 
	     housing_exp 
	     durable_exp 
	     non_durable_exp 
	     dur_less_hous 
	     ccare_exp 
	     transp_exp 
	     clothing_exp 
	     work_exp 
	     furniture 
	     floorwindow 
	     otherhhitems 
	     appl_big 
	     electronics 
	     funstuff 
	     mischhequip 
	     transp 
	     owe_cred2 
	     owe_cred5
	     newcars
	     usedcars
	     newtrucks
	     usedtrucks
	     newmcycles
	     usedmcycles
	     boat_wm
	     boat_wom
	     camper
	     otherveh
	     pmcamper
	     mcamperc
	     tdet_*; 
	  
	      label var newid "Consumer Unit Identifier"; 
	      label var pre1986 "Before 1986 dummy"; 
	      label var ref_yr "Year in which purchase made"; 
	      label var ref_mo "Month in which purchase made"; 
	      label var tot_exp "Total monthly CU expenditure"; 
	      label var vhome "Market value of home (annualized)"; 
	      label var mortpay "Mortgage interest and principal payments"; 
	      label var housing_exp "Monthly CU housing expenditure"; 
	      label var durable_exp "Monthly CU durable expenditure"; 
	      label var non_durable_exp "Monthly CU expenditure on non-durables"; 
	      label var ccare_exp "Monthly CU child care expenses"; 
	      label var transp_exp "Monthly CU transportation expenses"; 
	      label var clothing_exp "Monthly CU clothing expenses"; 
	      label var work_exp "Monthly CU work-related expenses"; 
	      label var dur_less_hous "Monthly CU expenditure on durables, exlcuding housing"; 
	      label var furniture "furniture expenditures"; 
	      label var floorwindow "expenditures on flooring and windows"; 
	      label var otherhhitems "other hh item expenditures"; 
	      label var appl_big "large appliance expenditures"; 
	      label var electronics "electronic expenditures"; 
	      label var funstuff "expenditures on music, toys, sporting equipment, etc"; 
	      label var mischhequip "expenditures on random hh equipment"; 
	      label var transp "expenditures on cars, trucks, boats and the like"; 
	      label var owe_cred2 "Total amount owed to creditors, 2nd interview"; 
	      label var owe_cred5 "Total amount owed to creditors, 5th interview"; 
	      label var newcars "New cars";
	      label var usedcars "Used cars";
	      label var newtrucks "New trucks or vans";
	      label var usedtrucks "Used trucks or vans";
	      label var newmcycles "New motorcycles, motor scooters, or mopeds (net outlay)";
	      label var usedmcycles "Used motorcycles, motor scooters, or mopeds (net outlay)";
	      label var boat_wm "Boat with motor (net outlay)";
	      label var boat_wom "Boat without motor or non camper-type trailer, such as for boat or cycle (net outlay)";
	      label var camper "Trailer-type or other attachable-type camper (net outlay)";
	      label var otherveh "Purchase of other vehicle";
	      label var pmcamper "Purchase of motorized camper (referred to as <motor home> after 2007Q2)";	  
	      label var mcamperc "MOTORIZED CAMPER COACH AND OTHER VEHICLES";
	
	sort newid
	     pre1986
			 ref_yr
			 ref_mo;

save CM1_summed_`proclyr', replace;    
		
exit;