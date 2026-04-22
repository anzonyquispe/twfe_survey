*first starting with year 1990 ind codes:

gen ind90=ind if cenyear==1990
gen indimss=. if ind90==0 
replace indimss=17 if ind90>0 & ind90<20000 		
replace indimss=1 if  ind90==32201 | (ind90>=32401 & ind90<=32404)		
replace indimss=2 if ind90>=31001 & ind90<=31099 		
replace indimss=3 if ind90>=31101 & ind90<=31211		
replace indimss=4 if (ind90>=32101 & ind90<= 32132) | (ind90>=32301 & ind90<=32399) | (ind90>=32001 & ind90<=32099) | (ind90>=32141 & ind90<=32199) | (ind90>=32202 & ind90<=32299)	
replace indimss=5 if ind90>=32411 & ind90<=32500 		
replace indimss=6 if ind90>=31301 & ind90<=31399 		
replace indimss=7 if ind90>=42001 & ind90<=42999 		
replace indimss=8 if (ind90>=41000 & ind90<=41999) | (ind90>=20001 & ind90<=20999) 		
replace indimss=9 if ind90>=50001 & ind90<=50200		
replace indimss=10 if ind90>=60001 & ind90<=60999 		
replace indimss=11 if ind90>=70001 & ind90<=70100 		
replace indimss=12 if ind90>=83001 & ind90<=83099 		
replace indimss=13 if (ind90>=81000 & ind90<=82302) | (ind90>=83101 & ind90<=83199)		
replace indimss=14 if (ind90>=84001 & ind90<=85999) | (ind90>=70201 & ind90<=70999)		
replace indimss=15 if ind90==99999 		
replace indimss=16 if ind90==32999 		
drop ind90

gen ind00=ind if cenyear==2000
replace indimss=. if ind00==0 
replace indimss=17 if ind00>0 & ind00<120 		
replace indimss=1 if  ind00==331		
replace indimss=2 if ind00>=310 & ind00<=311 		
replace indimss=3 if ind00>=312 & ind00<=315		
replace indimss=4 if  ind00==330 | (ind00>=321 & ind00<=326) 		
replace indimss=5 if (ind00>=332 & ind00<=335) | (ind00==337) 		
replace indimss=6 if ind00==320 | ind00==336 		
replace indimss=7 if ind00>=230 & ind00<=239		
replace indimss=8 if ind00>=210 & ind00<=222 		
replace indimss=9 if ind00>=430 & ind00<=469		
replace indimss=10 if ind00>=480 & ind00<=516 		
replace indimss=11 if ind00>=520 & ind00<=529		
replace indimss=12 if ind00>=540 & ind00<=564 		
replace indimss=13 if (ind00>=610 & ind00<=623) | (ind00>=930 & ind00<=939)		
replace indimss=14 if (ind00>=530 & ind00<=539) | (ind00>=710 & ind00<=816)		
replace indimss=15 if ind==999		
replace indimss=16 if  ind00==339
drop ind00
*note ceramics is in 326 but can not be split from glass, concrete etc so included in non exportables heavy industry 4