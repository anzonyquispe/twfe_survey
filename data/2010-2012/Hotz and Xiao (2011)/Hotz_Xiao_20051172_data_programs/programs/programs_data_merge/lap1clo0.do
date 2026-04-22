* program name : lap1clo0

# delimit ;

local lap1clo0 "lapses==1 & closed==0 & " ;

/*01*/ replace accredays$year = 0  	    		           if `lap1clo0'  accre_spell_$year==1 & lapse_spell_$year==1;
/*02*/ replace accredays$year = 0 	    			   if `lap1clo0'  accre_spell_$year==1 & lapse_spell_$year==2;
/*03*/ replace accredays$year = 0 	    			   if `lap1clo0'  accre_spell_$year==1 & lapse_spell_$year==3;
/*04*/ replace accredays$year = 0 	    			   if `lap1clo0'  accre_spell_$year==1 & lapse_spell_$year==4;
/*05*/ replace accredays$year = 0 	    			   if `lap1clo0'  accre_spell_$year==1 & lapse_spell_$year==5;
/*06*/ replace accredays$year = 0 	    			   if `lap1clo0'  accre_spell_$year==1 & lapse_spell_$year==6;
* -------------------------------------------------------------------------------------------------------------;
/*07*/ replace accredays$year = e_valid_until-mdy(01,01,$year)     if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==1;
/*08*/ replace accredays$year = e_valid_until-e_lapse_to_1         if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==2 & e_lapse_to_1   < e_valid_until;
/*08*/ replace accredays$year = 0				   if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==2 & e_lapse_to_1   > e_valid_until;
/*09*/ replace accredays$year = e_valid_until-mdy(01,01,$year)     if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==3 & e_lapse_from_1 > e_valid_until; 
/*09*/ replace accredays$year = e_lapse_from_1-mdy(01,01,$year)    if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==3 & e_lapse_from_1 < e_valid_until
				  							 		                      & e_lapse_to_1   > e_valid_until;
/*09*/ replace accredays$year =  (e_valid_until-e_lapse_to_1)      
		             +(e_lapse_from_1-mdy(01,01,$year))    if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==3 & e_lapse_to_1   < e_valid_until;
/*10*/ replace accredays$year = e_valid_until-mdy(01,01,$year)     if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==4 & e_lapse_from_1 > e_valid_until;
/*10*/ replace accredays$year = e_lapse_from_1-mdy(01,01,$year)    if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==4 & e_lapse_from_1 < e_valid_until;
/*11*/ replace accredays$year = e_valid_until-mdy(01,01,$year)     if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==5;
/*12*/ replace accredays$year = 0 	                           if `lap1clo0'  accre_spell_$year==2 & lapse_spell_$year==6;
* ---------------------------------------------------------------------------------------------------------------;
/*13*/ replace accredays$year = e_valid_until-e_init_accredit      if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==1;
/*14*/ replace accredays$year = e_valid_until-e_init_accredit      if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==2 & e_lapse_to_1   < e_init_accredit ;
/*14*/ replace accredays$year = e_valid_until-e_lapse_to_1         if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==2 & e_lapse_to_1   > e_init_accredit 
				  					 			           		      & e_lapse_to_1   < e_valid_until;
/*14*/ replace accredays$year = 0 	                           if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==2 & e_lapse_to_1   > e_valid_until;            
/*15*/ replace accredays$year = e_valid_until-e_init_accredit      if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==3 & e_lapse_to_1   < e_init_accredit;													      
/*15*/ replace accredays$year = e_valid_until-e_lapse_to_1         if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==3 & e_lapse_to_1   > e_init_accredit   
                                                                                                            		      & e_lapse_from_1 < e_init_accredit
                                                                                                            		      & e_lapse_to_1   < e_valid_until;
/*15*/ replace accredays$year =  (e_valid_until-e_lapse_to_1)      
		             +(e_lapse_from_1-e_init_accredit)     if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==3 & e_lapse_from_1 > e_init_accredit
				  					 			           		      & e_lapse_to_1   < e_valid_until;						
/*15*/ replace accredays$year = 0 	                           if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==3 & e_lapse_from_1 < e_init_accredit
                                                                                                            		      & e_lapse_to_1   > e_valid_until;	  
/*15*/ replace accredays$year = e_lapse_to_1-e_init_accredit       if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==3 & e_lapse_from_1 < e_valid_until
				  					 			           		      & e_lapse_to_1   > e_valid_until
				  					 			           		      & e_lapse_from_1 > e_init_accredit;
/*15*/ replace accredays$year = e_valid_until-e_init_accredit      if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==3 & e_lapse_from_1 > e_valid_until;                                                                   
/*16*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==4 & e_lapse_from_1 < e_init_accredit;
/*16*/ replace accredays$year = e_lapse_from_1-e_init_accredit     if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==4 & e_lapse_from_1 > e_init_accredit
				  					 				   		      & e_lapse_from_1 < e_valid_until;
/*16*/ replace accredays$year = e_valid_until-e_init_accredit      if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==4 & e_lapse_from_1 > e_valid_until;
/*17*/ replace accredays$year = e_valid_until-e_init_accredit      if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==5;
/*18*/ replace accredays$year = 0 	                           if `lap1clo0'  accre_spell_$year==3 & lapse_spell_$year==6;
* ------------------------------------------------------------------------------------------------------------;
/*19*/ replace accredays$year = mdy(01,01,$year+1)-e_init_accredit if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==1;
/*20*/ replace accredays$year = mdy(01,01,$year+1)-e_init_accredit if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==2 & e_lapse_to_1  < e_init_accredit;
/*20*/ replace accredays$year = mdy(01,01,$year+1)-e_lapse_to_1    if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==2 & e_lapse_to_1  > e_init_accredit;
/*21*/ replace accredays$year = mdy(01,01,$year+1)-e_init_accredit if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==3 & e_lapse_to_1   < e_init_accredit;
/*21*/ replace accredays$year = mdy(01,01,$year+1)-e_lapse_to_1    if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==3 & e_lapse_to_1   > e_init_accredit
				  								           		      & e_lapse_from_1 < e_init_accredit;
/*21*/ replace accredays$year =  (mdy(01,01,$year+1)-e_lapse_to_1)
		                +(e_lapse_from_1-e_init_accredit)  if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==3 & e_lapse_to_1   > e_init_accredit
                                                                                                           		      & e_lapse_from_1 > e_init_accredit;
/*22*/ replace accredays$year = e_lapse_from_1-e_init_accredit     if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==4 & e_lapse_from_1 > e_init_accredit;
/*22*/ replace accredays$year = 0 	                           if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==4 & e_lapse_from_1 < e_init_accredit;
/*23*/ replace accredays$year = mdy(01,01,$year+1)-e_init_accredit if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==5;
/*24*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==4 & lapse_spell_$year==6;
* --------------------------------------------------------------------------------------------------------;
/*25*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==5 & lapse_spell_$year==1;
/*26*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==5 & lapse_spell_$year==2;
/*27*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==5 & lapse_spell_$year==3;
/*28*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==5 & lapse_spell_$year==4;
/*29*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==5 & lapse_spell_$year==5;
/*30*/ replace accredays$year = 0                                  if `lap1clo0'  accre_spell_$year==5 & lapse_spell_$year==6;
* ---------------------------------------------------------------------------------------------------------;
/*31*/ replace accredays$year = 365                                if `lap1clo0'  accre_spell_$year==6 & lapse_spell_$year==1;
/*32*/ replace accredays$year = mdy(01,01,$year+1)-e_lapse_to_1    if `lap1clo0'  accre_spell_$year==6 & lapse_spell_$year==2;
/*33*/ replace accredays$year =  (mdy(01,01,$year+1)-e_lapse_to_1) 
                                +(e_lapse_from_1-mdy(01,01,$year)) if `lap1clo0'  accre_spell_$year==6 & lapse_spell_$year==3;
/*34*/ replace accredays$year = e_lapse_from_1-mdy(01,01,$year)    if `lap1clo0'  accre_spell_$year==6 & lapse_spell_$year==4;
/*35*/ replace accredays$year = 365 	                           if `lap1clo0'  accre_spell_$year==6 & lapse_spell_$year==5;
/*36*/ replace accredays$year = 0 	                           if `lap1clo0'  accre_spell_$year==6 & lapse_spell_$year==6;


# delimit cr
