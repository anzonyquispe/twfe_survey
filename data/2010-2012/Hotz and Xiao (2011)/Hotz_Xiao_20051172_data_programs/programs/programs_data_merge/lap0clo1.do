* program name : lap0clo1

# delimit ;

local lap0clo1 "lapses==0 & closed==1 & ";

	replace accredays$year = 0 	                            if    `lap0clo1' accre_spell_$year==1 & close_spell_$year==1;
	replace accredays$year = 0                                  if    `lap0clo1' accre_spell_$year==2 & close_spell_$year==1;
	replace accredays$year = 0                                  if    `lap0clo1' accre_spell_$year==3 & close_spell_$year==1;
	replace accredays$year = 0                                  if    `lap0clo1' accre_spell_$year==4 & close_spell_$year==1;
	replace accredays$year = 0                                  if    `lap0clo1' accre_spell_$year==5 & close_spell_$year==1;
	replace accredays$year = 0                                  if    `lap0clo1' accre_spell_$year==6 & close_spell_$year==1;
	                                                                             
	replace accredays$year = 0	 			    if    `lap0clo1' accre_spell_$year==1 & close_spell_$year==3;
	replace accredays$year = e_valid_until-mdy(01,01,$year)     if    `lap0clo1' accre_spell_$year==2 & close_spell_$year==3 & e_close_date > e_valid_until;
	replace accredays$year = e_close_date-mdy(01,01,$year)      if    `lap0clo1' accre_spell_$year==2 & close_spell_$year==3 & e_close_date < e_valid_until;	
	replace accredays$year = 0				    if    `lap0clo1' accre_spell_$year==3 & close_spell_$year==3 & e_close_date < e_init_accredit;
	replace accredays$year = e_close_date-e_valid_until         if    `lap0clo1' accre_spell_$year==3 & close_spell_$year==3 & e_close_date > e_init_accredit
				  							 		             		 & e_close_date < e_valid_until;
	replace accredays$year = e_valid_until-e_init_accredit      if    `lap0clo1' accre_spell_$year==3 & close_spell_$year==3 & e_close_date > e_valid_until;	
	replace accredays$year = 0				    if    `lap0clo1' accre_spell_$year==4 & close_spell_$year==3 & e_close_date < e_init_accredit;
	replace accredays$year = e_close_date-e_init_accredit       if    `lap0clo1' accre_spell_$year==4 & close_spell_$year==3 & e_close_date > e_init_accredit;	
	replace accredays$year = 0	 			    if    `lap0clo1' accre_spell_$year==5 & close_spell_$year==3;
	replace accredays$year = e_close_date-mdy(01,01,$year)      if    `lap0clo1' accre_spell_$year==6 & close_spell_$year==3;
	                                                                             
	replace accredays$year = 0	 			    if    `lap0clo1' accre_spell_$year==1 & close_spell_$year==5;
	replace accredays$year = e_valid_until-mdy(01,01,$year)     if    `lap0clo1' accre_spell_$year==2 & close_spell_$year==5;
	replace accredays$year = e_valid_until-e_init_accredit      if    `lap0clo1' accre_spell_$year==3 & close_spell_$year==5;
	replace accredays$year = mdy(01,01,$year+1)-e_init_accredit if    `lap0clo1' accre_spell_$year==4 & close_spell_$year==5;
	replace accredays$year = 0	 			    if    `lap0clo1' accre_spell_$year==5 & close_spell_$year==5;
	replace accredays$year = 365 			            if    `lap0clo1' accre_spell_$year==6 & close_spell_$year==5;

# delimit cr
