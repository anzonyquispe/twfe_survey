*this file decides the groups that getting_muni_firm_data_industry.do spits out data in.
*getting_firm_exposure takes these groups as long as they are numbered 1 to 99 and deals with them



*gen grupo2=string(grupo,"%04.0f")
/*
replace grupo2=regexr(grupo2,"[0-9][0-9][0-9]$","")
destring grupo2, replace
replace grupo2=10 if grupo==0
*/
*replace grupo2=regexr(grupo2,"[0-9][0-9]$","")
*destring grupo2, replace
*replace grupo2=98 if grupo==0
*format grupo2 %02.0f
*drop grupo 
*rename grupo2 grupo


gen grupo2=string(grupo,"%04.0f")
replace grupo2=regexr(grupo2,"[0-9][0-9]$","")
destring grupo2, replace
format grupo2 %02.0f

gen grupo3=1 if grupo2==35 | grupo==3301 | grupo==3302
* 1: Basic manufacturing that is exported (metal products and pottery, ) 
replace grupo3=2 if grupo2==20 | grupo2==21 | grupo2==22
* 2: Food, drink, tobacco manufacture
replace grupo3=3 if grupo2==23 | grupo2==24 | grupo2==25
* 3: Textiles, shoes and leather
replace grupo3=4 if grupo2==30 | grupo2==31 | grupo2==34 | grupo2==28 | grupo2==29 | grupo2==32 | (grupo>3303 & grupo<=3317) 
* 4: Heavy Industy (chemicals, petroleum, metal,paper and publishing, plastic and non exported mineral products)
replace grupo3=5 if grupo2>35 & grupo<3909
* 5: Electrical and Transport Equipment and Toys, Clocks, Scientific Equip 
replace grupo3=6 if grupo2>25 & grupo2<28
* 6: Wood and Furniture
replace grupo3=7 if grupo2>39 & grupo2<50
* 7: Construction
replace grupo3=8 if (grupo2>49 & grupo2<60)  | (grupo2>10 & grupo2<15)
* 8: Water and Energy and Mining
replace grupo3=9 if (grupo2>59 & grupo2<70)
* 9: Commerce
replace grupo3=10 if grupo2>69 & grupo2<80
* 10: Transport Services and Communications
replace grupo3=11 if grupo2>79 & grupo2<83
* 11: Services to Finance
replace grupo3=12 if grupo2==84
* 12: Professional and Technical Services
replace grupo3=13 if grupo2>89 & grupo2<100
* 13: Medical, Educational and Administrative Services
replace grupo3=14 if grupo2==83 | (grupo2>84 & grupo2<90)
* 14: Rental Services, food preperation, lodging, domestic and recreational services
replace grupo3=15 if grupo3==. & grupo!=. 
* 15: Other Firms
replace grupo3=16 if grupo==3909 | grupo==3910
* 16: Other Manufacturing
replace grupo3=17 if grupo2==1 | grupo2==2 | grupo2==3 | grupo2==4 | grupo2==5
* 17: Agriculture and other food primary


/**
*my 5 catagories i use in mcohort_avg_firm files... here just for reference
gen ind=24 if grupo3==2 | grupo3==4
replace ind=26 if grupo3==9 | grupo3==10 | grupo3==14
replace ind=29 if grupo3==11 | grupo3==12  | grupo3==13 
replace ind=33 if grupo3==3 | grupo3==6
replace ind=34 if grupo3==1 | grupo3==5
**/



/*

gen grupo3=1 if grupo2==32 | grupo2==33 | grupo2==35 | grupo2==28 | grupo2==29 
* 1: Basic manufacturing (metal, plastic and mineral products, paper and publishing) and other 
replace grupo3=2 if grupo2==20 | grupo2==21 | grupo2==22
* 2: Food, drink, tobacco manufacture
replace grupo3=3 if grupo2==23 | grupo2==24 | grupo2==25
* 3: Textiles, shoes and leather
replace grupo3=4 if grupo2==30 | grupo2==31 | grupo2==34 
* 4: Heavy Industy (chemicals, petroleum, metal)
replace grupo3=5 if grupo2>35 & grupo<3909
* 5: Electrical and Transport Equipment and Toys, Clocks, Scientific Equip 
replace grupo3=6 if grupo2>25 & grupo2<28
* 6: Wood and Furniture
replace grupo3=7 if grupo2>39 & grupo2<50
* 7: Construction
replace grupo3=8 if grupo2>49 & grupo2<60
* 8: Water and Energy and Mining
replace grupo3=9 if (grupo2>59 & grupo2<70) | (grupo2>10 & grupo2<15)
* 9: Commerce
replace grupo3=10 if grupo2>69 & grupo2<80
* 10: Transport Services and Communications
replace grupo3=11 if grupo2>79 & grupo2<83
* 11: Services to Finance
replace grupo3=12 if grupo2==84
* 12: Professional and Technical Services
replace grupo3=13 if grupo2>89 & grupo2<100
* 13: Medical, Educational and Administrative Services
replace grupo3=14 if grupo2==83 | (grupo2>84 & grupo2<90)
* 14: Rental Services, food preperation, lodging, domestic and recreational services
replace grupo3=15 if grupo3==. & grupo!=. 
* 15: Other Firms
replace grupo3=16 if grupo==3909 | grupo==3910
* 16: Other Manufacturing
replace grupo3=17 if grupo2==1 | grupo2==2 | grupo2==3 | grupo2==4 | grupo2==5
* 17: Agriculture and other food primary
*/




/*
gen grupo3=1 if grupo2==1 | grupo2==2 | grupo2==3 | grupo2==4 | grupo2==5
replace grupo3=2 if grupo2==20 | grupo2==21 | grupo2==22
replace grupo3=3 if grupo2==23 | grupo2==24 | grupo2==25
replace grupo3=4 if grupo2>29 & grupo2<35
replace grupo3=5 if grupo2>34 & grupo2<40
replace grupo3=6 if grupo2>25 & grupo2<30
replace grupo3=7 if grupo2>39 & grupo2<50
replace grupo3=8 if grupo2>49 & grupo2<60
replace grupo3=9 if grupo2>59 & grupo2<70
replace grupo3=10 if grupo2>69 & grupo2<80
replace grupo3=11 if grupo2>79 & grupo2<83
replace grupo3=12 if grupo2==84
replace grupo3=13 if grupo2>89 & grupo2<100
replace grupo3=14 if grupo2==83 | (grupo2>84 & grupo2<90)
replace grupo3=15 if grupo3==. & grupo!=. 
*/



drop grupo grupo2
rename grupo3 grupo


/*
gen grupo3=1 if grupo2==1 | grupo2==2 | grupo2==3 | grupo2==4 | grupo2==4 | grupo2==5
replace grupo3=2 if (grupo2>10 & grupo2<15) | (grupo2>39 & grupo2<52)
replace grupo3=3 if (grupo2>19 & grupo2<40) 
replace grupo3=4 if (grupo2>59 & grupo2<77) | (grupo2>85 & grupo2<89)
replace grupo3=5 if (grupo2>80 & grupo2<86)
replace grupo3=6 if (grupo2>90 & grupo2<100)
replace grupo3=7 if grupo2==89


drop grupo grupo2
rename grupo3 grupo
*/
