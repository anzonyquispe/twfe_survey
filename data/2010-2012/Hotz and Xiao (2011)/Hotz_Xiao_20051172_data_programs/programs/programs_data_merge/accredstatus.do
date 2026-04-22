* *******************************************************************************************************************
* Program Name: accredstatus.do
* Written By  : Juan Pantano (July / August 2004)

* Description: This program generates 3 dummy variables to define accreditation status in 1987, 1992 & 1997

* Note: accreditation dummies for 1987,1992 & 1997 are assigned a value ==1 if
*       the establishemt was accredited at least one day, at least 91 days or at least 182 days in the relevant year.
* 	Accreditation days are defined using range given by "init_accredit" & "valid_until" 
*       net of overlaping lapsing and closing spells.
* Note: Some centers have valid accreditations dates but not valid_until or extend_until information and have deferred (D) status
*       I treat them as never having accreditation.
* Note: Necessary changes to addresses &  name concatenations are performed inside matching code at CCRDC
* 
* Stil to Do: Deal with multiple entries in lapse_from / lapse_to variables
* 	      Adjust valid_until with extend _until  when appropiate.
* *******************************************************************************************************************

*clear all               
*capture log close       
*local pathnaeyc "C:\Juan\Hotz\ChildCare\NAEYCdata\"
local pathpgs    "/rdcprojects/la00296/programs/"
*log using `pathnaeyc'accredstatus.log, replace

	                        
* Inputs NAEYC data from Mo's excel file (converted into csv file)
* insheet using `pathnaeyc'naeyc_clean.csv, comma
                        
* Deletes non-US centers
drop if cntry!=""       
drop if st=="AE"
drop if st=="AA"
drop if st=="PR"
                        
* Deletes centers with weird accreditation dates
drop if naeyc_id==198205|naeyc_id==282694|naeyc_id==277727

* Deletes centers with weird valid_until dates
# delimit ;
drop if naeyc_id==279389|naeyc_id==279648|naeyc_id==279689|naeyc_id==279702|naeyc_id==279732
       |naeyc_id==279785|naeyc_id==279833|naeyc_id==279888|naeyc_id==279928|naeyc_id==279961
       |naeyc_id==280372|naeyc_id==282081|naeyc_id==274724|naeyc_id==274761|naeyc_id==274895
       |naeyc_id==274952|naeyc_id==276175|naeyc_id==276222|naeyc_id==276236|naeyc_id==277685
       |naeyc_id==277731|naeyc_id==277748;
# delimit cr

* Initializes dummies for lapsing and closing centers
gen lapses=0
gen closed=0

* Takes care of multiple lapsed from/lapsed to entries
split lapse_from if lapse_from !="" , gen(lapse_from_)
split lapse_to   if lapse_to   !="" , gen(lapse_to_)

* Converts date variables into STATA internal date format
gen e_applic_date  =date(applic_date,"mdy") if applic_date !=""
gen e_valid_until  =date(valid_until  ,"mdy") if valid_until   !=""
gen e_init_accredit=date(init_accredit,"mdy") if init_accredit !=""
gen e_extend_until =date(extend_until ,"mdy") if extend_until  !=""
gen e_close_date   =date(close_date   ,"mdy") if close_date    !=""
gen e_lapse_from_1 =date(lapse_from_1 ,"mdy") if lapse_from_1  !=""
gen e_lapse_from_2 =date(lapse_from_2 ,"mdy") if lapse_from_2  !=""
gen e_lapse_from_3 =date(lapse_from_3 ,"mdy") if lapse_from_3  !=""
gen e_lapse_to_1   =date(lapse_to_1   ,"mdy") if lapse_to_1    !=""
gen e_lapse_to_2   =date(lapse_to_2   ,"mdy") if lapse_to_2    !=""

* Imputes accreditation dates for those with valid "until_date" & appropiate status
replace e_init_accredit=e_valid_until-365*3 if init_accredit=="" & valid_until!="" & ( accredit_status=="A"|accredit_status=="D"|accredit_status=="E")

* Lapsing & Closing dummies;

replace closed    =1 if close_date !=""; 
replace lapses    =1 if lapse_from !="";

* Note: NO center has "lapse to" without "lapse from";
*       But 3044 have "lapse from" without "lapse to";
* Idea: Impute current day as "lapse_to" for those without it;
*       I need this because later algorithms need all varaibles well defined;

replace e_lapse_to_1=mdy(06,01,2003) if lapse_to_1=="" & lapse_from_1!=""
replace e_lapse_to_2=mdy(06,01,2003) if lapse_to_2=="" & lapse_from_2!=""
gen     e_lapse_to_3=mdy(06,01,2003) if                  lapse_from_3!=""


# delimit ;
                                                                                                                                                                                                                                                                          
foreach year of numlist 1987 1992 1997 {;

	gen accredays`year'=.;
	
	* Define different possible accreditation spells relative to a given year (see graph);
	
	gen accre_spell_`year'= 9;
	    
	replace accre_spell_`year'=5 if e_init_accredit==.;
	
	
	local nodot "e_init_accredit!=. & e_valid_until!=." ;

	replace accre_spell_`year'= 1 if e_init_accredit <= mdy(01,01,`year') 
				       & e_valid_until   <= mdy(01,01,`year')
				       & e_init_accredit <= e_valid_until
				       & `nodot';
				      
	replace accre_spell_`year'= 2 if e_init_accredit <= mdy(01,01,`year') 
				       & e_valid_until   >  mdy(01,01,`year')
				       & e_valid_until   <= mdy(01,01,`year'+1)
				       & `nodot';
				      
	replace accre_spell_`year'= 3 if e_init_accredit >= mdy(01,01,`year') 
				       & e_init_accredit <= mdy(01,01,`year'+1) 
				       & e_valid_until   >= mdy(01,01,`year')
				       & e_valid_until   <= mdy(01,01,`year'+1)
				       & e_init_accredit <= e_valid_until
				       & `nodot';
				      
	replace accre_spell_`year'= 4 if e_init_accredit >= mdy(01,01,`year') 
				       & e_init_accredit <= mdy(01,01,`year'+1) 
				       & e_valid_until   >= mdy(01,01,`year'+1)
				       & `nodot';
				      
	replace accre_spell_`year'= 5 if e_init_accredit >= mdy(01,01,`year'+1) 			      
				       & e_valid_until   >= mdy(01,01,`year'+1)
				       & e_init_accredit <= e_valid_until
				       & `nodot';
				      
	replace accre_spell_`year'= 6 if e_init_accredit <= mdy(01,01,`year')
				       & e_valid_until   >= mdy(01,01,1988)
				       & `nodot';
				       
	replace accre_spell_`year'=5 if e_init_accredit!=. & e_valid_until==. & accredit_status=="D" & accre_spell_`year'==9;
	replace accre_spell_`year'=5 if e_valid_until==. & accre_spell_`year'==9;	
	
	* Define different kinds of closing spells relative to a given year (see graph);
	
	gen close_spell_`year'=0;
	
	replace close_spell_`year'=1 if e_close_date<mdy(01,01,`year');
	replace close_spell_`year'=3 if e_close_date<mdy(01,01,`year'+1) & e_close_date > mdy(01,01,`year');
	replace close_spell_`year'=5 if e_close_date>mdy(01,01,`year'+1);
	
	* Define different kind of closing spells relative to a given year (see graph);
	
	gen lapse_spell_`year'=0;
	
	replace lapse_spell_`year'= 1 if (  e_lapse_from_1 <= mdy(01,01,`year')
				          & e_lapse_to_1   <= mdy(01,01,`year')
				          & e_lapse_from_1 <= e_lapse_to_1     )
				        |(  e_lapse_from_2 <= mdy(01,01,`year')
				          & e_lapse_to_2   <= mdy(01,01,`year')
				          & e_lapse_from_2 <= e_lapse_to_2     );
				      
	replace lapse_spell_`year'= 2 if (  e_lapse_from_1 <= mdy(01,01,`year')
				          & e_lapse_to_1   >  mdy(01,01,`year')
				          & e_lapse_to_1   <= mdy(01,01,`year'+1))
				        |(  e_lapse_from_2 <= mdy(01,01,`year')
				          & e_lapse_to_2   >  mdy(01,01,`year')
				          & e_lapse_to_2   <= mdy(01,01,`year'+1));
				      
	replace lapse_spell_`year'= 3 if  (  e_lapse_from_1 >= mdy(01,01,`year') 
				           & e_lapse_from_1 <= mdy(01,01,`year'+1) 
				           & e_lapse_to_1   >= mdy(01,01,`year')
				           & e_lapse_to_1   <= mdy(01,01,`year'+1)
				           & e_lapse_from_1 <= e_lapse_to_1       )
				         |(  e_lapse_from_2 >= mdy(01,01,`year')   
					   & e_lapse_from_2 <= mdy(01,01,`year'+1) 
					   & e_lapse_to_2   >= mdy(01,01,`year')   
					   & e_lapse_to_2   <= mdy(01,01,`year'+1) 
					   & e_lapse_from_2 <= e_lapse_to_2       );
				          
	replace lapse_spell_`year'= 4 if  (  e_lapse_from_1 >= mdy(01,01,`year') 
				           & e_lapse_from_1 <= mdy(01,01,`year'+1) 
				           & e_lapse_to_1   >= mdy(01,01,`year'+1))
				         |(  e_lapse_from_2 >= mdy(01,01,`year') 
				           & e_lapse_from_2 <= mdy(01,01,`year'+1) 
				           & e_lapse_to_2   >= mdy(01,01,`year'+1));
				      
	replace lapse_spell_`year'= 5 if  (  e_lapse_from_1 >= mdy(01,01,`year'+1)
				           & e_lapse_to_1   >= mdy(01,01,`year'+1)
				           & e_lapse_from_1 <= e_lapse_to_1       ) 
				         |(  e_lapse_from_2 >= mdy(01,01,`year'+1)
				           & e_lapse_to_2   >= mdy(01,01,`year'+1)
				           & e_lapse_from_2 <= e_lapse_to_2       );
				      
	replace lapse_spell_`year'= 6 if  (  e_lapse_from_1 <= mdy(01,01,`year') 
				           & e_lapse_to_1   >= mdy(01,01,`year'+1))
				         |(  e_lapse_from_2 <= mdy(01,01,`year') 
				           & e_lapse_to_2   >= mdy(01,01,`year'+1)) ;

	global year = `year' ;
	
	* Centers with no closures or lapsing periods (20728 centers);
	do `pathpgs'lap0clo0.do ;
	
	* Centers with closures but no lapsing periods (3948 centers);
	do `pathpgs'lap0clo1.do ;
	
	* Centers with lapsing periods but no closures (3892 centers);
	do `pathpgs'lap1clo0.do ;
	
	* Centers with lapsing periods and closures (1712 centers);
	do `pathpgs'lap1clo1.do ;

	* Creates accreditation Status Dummies;
	
	gen acc_status_`year'_1d=0;
	gen acc_status_`year'_3m=0;
	gen acc_status_`year'_6m=0;
	
	replace acc_status_`year'_1d=1 if accredays`year'>=1;
	replace acc_status_`year'_3m=1 if accredays`year'>=91;	
	replace acc_status_`year'_6m=1 if accredays`year'>=182;
	
					};
count if accredays1987==.;
count if accredays1992==.;
count if accredays1997==.;

tab acc_status_1987_1d acc_status_1987_3m;
tab acc_status_1992_1d acc_status_1992_3m;
tab acc_status_1997_1d acc_status_1997_3m;


*list  init_accredit lapse_from lapse_to valid_until close_date lapses closed accredays1987 if e_init_accredit <= mdy(01,01,1988)& accredays1987!=. ; 

# delimit cr

log close