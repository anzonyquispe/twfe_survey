* program name : lap0clo0

local lap0clo0 "lapses==0 & closed==0 & "


	replace accredays$year = 0	 			    if `lap0clo0' accre_spell_$year==1
	replace accredays$year = e_valid_until-mdy(01,01,$year)     if `lap0clo0' accre_spell_$year==2
	replace accredays$year = e_valid_until-e_init_accredit      if `lap0clo0' accre_spell_$year==3
	replace accredays$year = mdy(01,01,$year+1)-e_init_accredit if `lap0clo0' accre_spell_$year==4
	replace accredays$year = 0	 			    if `lap0clo0' accre_spell_$year==5
	replace accredays$year = 365 			            if `lap0clo0' accre_spell_$year==6
								
