/*----------------------------------------------------------
This file generates a data set for use in establiushing whether or not firms are maquiladoras.
It is a firm level database.



The following files should be in the directory below:
INPUTS:
calcsfullclean.dta  (in /scratch/datkin)
replaceB01_B14withDF.do (in H:/Mexico)
getting_muni_firm_data_grupo_catagories.do (in H:/Mexico)

OUTPUTS:
new_cut`cut'ind.dta

FIRM CUTOFF:
Don't want all firms. Lets assume an establishment is something 
that employs x or more people in at least one year 1985-2000
Set x as local variable called cut.
------------------------------------------------------------
*/

*local cut=5

if "`c(os)'"=="Unix" {
local tempdir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
local dir "/home/fac/da334/Work/Mexico/"
local dirmaq "/home/fac/da334/Work/Mexico/Maquiladora Data/"
}

if "`c(os)'"=="Windows" {
local tempdir="C:\Data\Mexico\mexico_ss_Stata\"
local dir="C:\Work\Mexico\"
local dirmaq="C:\Work\Mexico\Maquiladora Data\"
}


global cutlist="0"
*this must be ascending



local yearend=2000
*change if extend data


clear
set mem 1800m

set maxvar 32767


set matsize 11000


set more off



/**


use "`tempdir'calcsfullclean.dta"
*save "`tempdir'calcsfullclean.dta", replace
*egen minemploy=min(employ), by(firmid)


*this is the full dataset in long form with establishments never as large as the cut excluded.


qui do "`dir'replaceB01_B14withDF.do"
*this turns the many municipalities coded B01_B14 into DF looking munis (begin with 9)
*qui do "`dir'munchanges.do"
*this makes all munis match the 1990's census and changes a few firms that moved
*this is only been done for large firms with maxemploy>49 in both locations.
cap replace firmid=	A0833446_10	if firmid==	Y9410159_10
cap replace firmid=	E2811309_10	if firmid==	Y7210012_10
cap replace firmid=	E3310012_10	if firmid==	Y7510026_10
cap replace firmid=	F1111751_10	if firmid==	Y8310009_10
cap replace firmid=	L0910079_10	if firmid==	Y8510001_10
cap replace firmid=	L0910134_10	if firmid==	Y8510018_10
cap replace firmid=	L0910049_10	if firmid==	Y8510010_10
cap replace firmid=	M4711418_10	if firmid==	Y7110559_10
cap replace firmid=	A0815906_10	if firmid==	Y9410054_10
cap replace firmid=	A0851052_10	if firmid==	Y9410379_10
cap replace firmid=	A0814544_10	if firmid==	Y9410048_10
cap replace firmid=	E2812712_10	if firmid==	Y7210367_19
*cap replace muncenso=	15070	if firmid==	Y7410120_10
*cap replace muncenso=	15025	if firmid==	Y7410058_10
cap replace firmid=	C3911192_10	if firmid==	Y7410120_10
cap replace firmid=	C2912183_10	if firmid==	Y7410058_10
*this moves firms directly. Can use firm exposure to do the munchanges
*note these firms will belong to two different municipalites depending on the year




*now I merge in group codes (originally from "`dir'getting_muni_firm_data_grupo_catagories.do")

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




gen state=string(muncenso,"%05.0f")
replace state=regexr(state,"[0-9][0-9][0-9]$","")
destring state, replace
format state %02.0f
do "`dir'region_labels.do"



egen firm=group(firmid)

preserve

keep firm firmid
egen tag=tag(firm)
keep if tag==1
drop tag


sort firm
save "`tempdir'Firm_to_FirmID_match.dta", replace

restore

drop firmid munimss maqind region1 region2 


rename male emp1
rename female emp2
rename employ emp0

order firm year emp0 emp1 emp2

compress

reshape long emp, i(firm year) j(sex) 

label define sexlbl 0 "both" 1 "male" 2 "female"
label values sex sexlbl





*here I add my maquiladora industry to match with industry data on INEGI website (12 cats) and maquiladora division to match with annual state data on INegi Website (6 cats)

gen maqdivision=1 if grupo2==20 | grupo2==21 | grupo2==22
gen maqindustry=11 if grupo2==20 | grupo2==21 | grupo2==22
* 2: Food, drink, tobacco manufacture

replace maqdivision=2 if grupo2==23 | grupo2==24 | grupo2==25
replace maqindustry=5 if grupo2==23 | grupo2==24
replace maqindustry=7 if grupo2==25
* 3: Textiles, shoes and leather

replace maqdivision=3 if grupo2>25 & grupo2<28
replace maqindustry=4 if grupo2==26 | grupo2==27 | grupo2==35 
* 6: Wood and Furniture


replace maqdivision=5 if grupo2==30 | grupo2==31 | grupo2==32  
replace maqindustry=10 if grupo2==30
* 4: Heavy Industy (chemicals, petroleum, metal,paper and publishing, plastic and non exported mineral products)



replace maqdivision=8 if grupo2==35 | grupo2==36 | grupo2==37   | grupo2==38 
replace maqindustry=1 if grupo2==38
replace maqindustry=2 if grupo==3904 | grupo==3905

*replace maqindustry=3 if grupo2==37
*replace maqindustry=6 if grupo2==36
*replace maqindustry=8 if grupo2==36/37
*unfortunately assmebly is seperated from manufcaturing in the maq induistry codes but not in the IMSS codes. So have to group all electrical stuff together under 8
replace maqindustry=8 if grupo2==36 | grupo2==37
* 5: Electrical and Transport Equipment and Toys, Clocks, Scientific Equip


replace maqindustry=9 if grupo2==28 | grupo2==29  | grupo2==31  | grupo2==32 | grupo2==33  | grupo2==34 | (grupo>3905 & grupo<=3999) | (grupo>=3900 & grupo<=3903) 
replace maqdivision=9 if grupo2==28 | grupo2==29 | grupo2==33  | grupo2==34 | grupo2==39 
* 16: Other Manufacturing



*need to match municipalities, states and ensure that the incomming industry data has catagory 3 and 6 changed to catagory 8 due to imss non overlap.


*I have made Mexico DF and Mexico 15000
replace muncenso=15000 if (muncenso>8999 & muncenso<10000) |  (muncenso>14999 & muncenso<16000) 


save "`tempdir'CalcsMaqTemp.dta", replace

**/


/**
*now to get industry data in right format for merge
**/
clear
use "`dirmaq'industry_monthly.dta"

gen maqindustry=sector

replace maqindustry=8 if sector==3 | sector==6

foreach var in  Admin ObrFem ObrMale Plants Tecnic TotalEmp {
egen x`var'=total00(`var'), by(year month maqindustry)
drop `var'
rename x`var' `var'
}

egen tag=tag(year month maqindustry)
keep if tag==1
drop tag

*just take dec figure
keep if month==12
drop month
drop sector Admin ObrFem ObrMale  Tecnic
*only keep total employemnt

*gen sex=0

rename TotalEmp EmpIndMo
rename Plants PlantsIndMo





sort  maqindustry year

save "`dirmaq'industry_monthly_maqindustryedit.dta", replace



/**
now to get monthly municipality data in right format to merge
**/
clear
use "`dirmaq'municipios.dta"

rename plants PlantsMunMo
rename emp EmpMunMo
keep if month==12
drop month

*I have made Mexico DF and Mexico 15000
gen muncenso=	2002	 if muni==	1
replace muncenso=	2003	 if muni==	2
replace muncenso=	2004	 if muni==	3
replace muncenso=	5002	 if muni==	4
replace muncenso=	5025	 if muni==	5
replace muncenso=	5035	 if muni==	6
replace muncenso=	8037	 if muni==	7
replace muncenso=	8019	 if muni==	8
replace muncenso=	15000	 if muni==	9
replace muncenso=	14039	 if muni==	10
replace muncenso=	19026	 if muni==	11
replace muncenso=	19039	 if muni==	12
replace muncenso=	26002	 if muni==	13
replace muncenso=	26043	 if muni==	14
replace muncenso=	28032	 if muni==	15
replace muncenso=	28022	 if muni==	16
replace muncenso=	28027	 if muni==	17
/*			
1	Mexicali, B. C.		
2	Tecate, B.C.		
3	Tijuana, B. C.		
4	Acuña, Coah.		
5	Piedras Negras, Coah		
6	Torreón, Coah		
7	Juárez, Chih		
8	Chihuahua, Chih		
9	México y Distrito Federal		
10	Guadalajara, Jal		
11	Guadalupe, N.L.		
12	Monterrey, N. L.		
13	Agua Prieta, Son.		
14	Nogales, Son.		
15	Reynosa, Tamps.		
16	Matamoros, Tamps.		
17	Nuevo Laredo		
*/


drop muni
*gen sex=0

sort muncenso year

save "`dirmaq'municipio_monthly_maqindustryedit.dta", replace



/**
*now to get annual state and monthly state industry  data in right format to merge
**/
use "`dirmaq'entidades_annual_edit.dta"

/* This gets the entidades_annual data to have teh monthly figures only for the total catagory (0)
foreach dog in total_dec hombres_dec mujeres_dec total_obreros_dec homres_obreros_dec mujeres_obreros_dec total_technicos_dec hombres_technicos_dec mujeres_technicos_dec total_admin_dec hombres_admin_dec mujeres_admin_dec month enactivo_dec _merge  {
replace `dog'=. if division!=0
}
*/


gen state2=	1	if state==	1
replace state2=	2	if state==	2
replace state2=	3	if state==	3
replace state2=	4	if state==	22
replace state2=	5	if state==	4
replace state2=	8	if state==	5
replace state2=	9	if state==	9
replace state2=	10	if state==	6
replace state2=	11	if state==	7
replace state2=	12	if state==	23
replace state2=	13	if state==	24
replace state2=	14	if state==	8

replace state2=	17	if state==	25
replace state2=	19	if state==	12
replace state2=	21	if state==	13
replace state2=	22	if state==	26
replace state2=	24	if state==	14
replace state2=	25	if state==	15
replace state2=	26	if state==	16
replace state2=	28	if state==	17
replace state2=	29	if state==	27
replace state2=	30	if state==	28
replace state2=	31	if state==	18
replace state2=	32	if state==	19

*mexico city and DF coded 9
replace state2=	9	if state==	11
replace state2=	9	if state==	10
replace state2=	9	if state==	9

decode state, gen(statename)
replace statename="México y Distrito Federal" if statename=="Distrito Federal"
replace statename="México y Distrito Federal" if statename=="México"
labmask  state2, values(statename)
drop state
rename state2 state



foreach var in  ebi_total  total_dec hombres_dec mujeres_dec enactivo_dec {
egen x`var'=total00(`var'), by(year state division)
drop `var'
rename x`var' `var'
}

egen tag=tag(year state division)
keep if tag==1
drop tag




keep  year ebi_total division state total_dec hombres_dec mujeres_dec enactivo_dec 
rename division maqdivision
*reshaping long
renvars *dec , prefix(dec)
*renvars *dec , postdro(4)
rename  ebi_total decebi_total
reshape long dec, i( year maqdivision state) string
rename _j type
rename dec value
reshape wide value, i( type maqdivision state) j(year)

*now the annual stuff is mid year. So to get it end year, I create a new variable:
forval n=1990/2003 {
local np1=`n'+1
gen value2`n'=(value`n'+value`np1')/2 if type=="ebi_total"
replace value`n'=value2`n' if type=="ebi_total"
drop value2`n'
}

reshape long value, i( type maqdivision state) j(year)
keep if  value!=.
reshape wide value, i( year maqdivision state) j(type) string
renpfix value

preserve

keep if maqdivision==0
rename enactivo_dec PlantsStMo
rename hombres_dec MaleEmpStMo
rename mujeres_dec FemaleEmpStMo
rename total_dec EmpStMo
rename ebi_total EmpStAn



drop  maqdivision

sort state year

save "`dirmaq'state_monthly_maqindustryedit.dta", replace



restore

drop if  maqdivision==0
keep state year ebi_total  maqdivision
rename ebi_total EmpStAnDiv

sort state  maqdivision year

save "`dirmaq'state_annual_maqindustryedit.dta", replace












/**
local tempdir="C:\Data\Mexico\mexico_ss_Stata\"
local dir="C:\Work\Mexico\"
local dirmaq="C:\Work\Mexico\Maquiladora Data\"

*Now I have all the data and the plan is one to many merges of data onto firms and then reshape long by data type and then reshape wide by firm 
*lets start off by ignoring the gender info:
**/

use "`tempdir'CalcsMaqTemp.dta", clear

cap do "`dir'StateLabel.do"

*only manufacturing:
keep if grupo2>19 & grupo2<40
*subsample time, to make this feasible
drop if year<1990
*no maquiladora data before this


replace state=9 if state==15
*this get all MEx/DF to be in MExico city/DF state 9

*I have made Mexico DF and Mexico 15000
gen munmatch=0 
replace munmatch=1 if  muncenso==	2002	
replace munmatch=1 if  muncenso==	2003	 
replace munmatch=1 if  muncenso==	2004	 
replace munmatch=1 if  muncenso==	5002	 
replace munmatch=1 if  muncenso==	5025	 
replace munmatch=1 if  muncenso==	5035	 
replace munmatch=1 if  muncenso==	8037	 
replace munmatch=1 if  muncenso==	8019	 
replace munmatch=1 if  muncenso==	15000	 
replace munmatch=1 if  muncenso==	14039	 
replace munmatch=1 if  muncenso==	19026	 
replace munmatch=1 if  muncenso==	19039	 
replace munmatch=1 if  muncenso==	26002	 
replace munmatch=1 if  muncenso==	26043	 
replace munmatch=1 if  muncenso==	28032	 
replace munmatch=1 if  muncenso==	28022	 
replace munmatch=1 if  muncenso==	28027	 


*these are most populat states

gen statematch=0
replace statematch=1 if state==	1	
replace statematch=1 if state==	2	
replace statematch=1 if state==	3	
*replace statematch=1 if state==	4	if state==	22
replace statematch=1 if state==	5	
replace statematch=1 if state==	8	
replace statematch=1 if state==	9	
replace statematch=1 if state==	10	
replace statematch=1 if state==	11	
*replace statematch=1 if state==	12	if state==	23
*replace statematch=1 if state==	13	if state==	24
replace statematch=1 if state==	14	

*replace statematch=1 if state==	17	if state==	25
replace statematch=1 if state==	19	
replace statematch=1 if state==	21	
*replace statematch=1 if state==	22	if state==	26
replace statematch=1 if state==	24	
replace statematch=1 if state==	25	
replace statematch=1 if state==	26	
replace statematch=1 if state==	28	
*replace statematch=1 if state==	29	if state==	27
*replace statematch=1 if state==	30	if state==	28
replace statematch=1 if state==	31	
replace statematch=1 if state==	32	
*mexico city and DF coded 9
replace statematch=1 if state==	9	


*these are all the states that appear in annual data but not monthly data.
gen statematch2=statematch
replace statematch2=1 if state==	4	
replace statematch2=1 if state==	12	
replace statematch2=1 if state==	13	
replace statematch2=1 if state==	17	
replace statematch2=1 if state==	22	
replace statematch2=1 if state==	29	
replace statematch2=1 if state==	30	






/**
Here i start cutting out firms that are inlikely to be Maquiladoras.
**/


*three different inclusion rules depending if in muncmatch or statematch.
keep if (emp>19	& maxemploy>29 & munmatch==1) |  (emp>29	& maxemploy>29 & munmatch==0 & statematch==1) |  (emp>39	& maxemploy>39 & minemploy>19 & munmatch==0 & statematch==0)

drop if state==9 & (maqdivision!=2 & maqdivision!=8)
*drop Mexico city except in looking at the two divisions where it is present.
keep if statematch2==1
*drop firms in states where no annual data is even collected

drop if maqdivision!=2	 & (state==1 | state==3 | state==4 |state==10 | state==12 |state==17 | state==29 |state==32)
*drop non textile firms from all these states where only textile firms are maquiladoras

drop if (maqdivision!=2 & maqdivision!=1) 	 & (state==11 )
drop if (maqdivision!=2 & maqdivision!=8 & maqdivision!=9) 	 & ( state==14 | state==31)
drop if (maqdivision!=2 &  maqdivision!=9) 	 & (state==21)
drop if (maqdivision!=2 & maqdivision!=8 ) 	 & (state==22| state==24)
drop if (maqdivision==2) & (state==2 )
drop if (maqdivision==3) & (state==19 )
drop if (maqdivision==1) & (state==26 )
*drop other firms when state data says no firms are there (via tab state  maqdivision, nol on state_annual_maquindistry.dta)

drop if emp<19 & (maqindustry==4 | maqindustry==7 | maqindustry==9)
*highest percentage of non maq firms in maqindustry 7, followed by 4 and 9


*drop if maqshare<0.1 & emp<99
*drop all the small firms in low maq towns.


*now I prune capital city firms as thee only enter industry total aggregates. Will just slim them
drop if state==9 & minemploy<49
*so firms had to be big all the time

*cap do "`dir'region_labels.do"

/**
Here i end cutting out firms that are inlikely to be Maquiladoras.
**/


gen plant=1


sort firm
merge firm using "`tempdir'Firm_to_FirmID_match.dta", nokeep _merge(_mergefirm)
drop firm _mergefirm

egen firm=group(firmid)
preserve
keep firm firmid

egen tag=tag(firm)
keep if tag==1
drop tag

sort firm
save "`tempdir'Maquiladora_Firm_to_FirmID_match_large.dta", replace
restore
drop firmid 


sum firm
local firmtotal=r(max)
noi di "Firms:`firmtotal'"
local block=ceil(`firmtotal'/25)



preserve
keep if sex==0
*this keeps only total employees
keep  firm year emp muncenso state maqdivision maqindustry plant
sort state  maqdivision year
save "`dirmaq'Potential_maq_firms_large.dta", replace


restore
preserve
keep if sex==1
*this keeps only male employees
keep  firm year emp muncenso state maqdivision maqindustry plant
sort state year
save "`dirmaq'Potential_maq_firms_male_large.dta", replace


restore
preserve
keep if sex==2
*this keeps only female employees
keep  firm year emp muncenso state maqdivision maqindustry plant
sort state year
save "`dirmaq'Potential_maq_firms_female_large.dta", replace

restore





*so first I take the Stat Anual Div data, merge in the potential maq firms, reshape wide and then save. Will do this for other 3 sampels and then reshape long

/**
*StAnDiv
**/


use "`dirmaq'Potential_maq_firms_large.dta", clear
sort state  maqdivision year
save "`dirmaq'Potential_maq_firms_large.dta", replace


use "`dirmaq'state_annual_maqindustryedit.dta" , clear
sort state  maqdivision year
merge state  maqdivision year using "`dirmaq'Potential_maq_firms_large.dta", nokeep  _merge(_mergeStAnDiv)
keep state  maqdivision year emp plant firm  EmpStAnDiv
drop if firm==.


*this code splits the reshape into 25 blocks to speed it upp and then remerges.
noi di "block"
qui {
forval n=0/24 {
local np1=`n'+1
noi di "`np1'  "
preserve
keep if firm>`n'*`block' & firm<=`np1'*`block'
**************************
reshape wide plant emp, i(state  maqdivision year) j(firm)
**************************
mvencode plant* emp*, mv(0)
**************************
sort  state  maqdivision year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/24 {
noi di "`n'  "
merge state  maqdivision year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
sort state  maqdivision year
}
}



rename  EmpStAnDiv SumEmp
*drop state  maqdivision year
gen Sumtype="StAnDiv"
save "`tempdir'Maquiladora_append_1.dta", replace







/**
*StMo Data (includes StAn, StMoFem StMoMale)
**/

use "`dirmaq'Potential_maq_firms_large.dta", clear
sort state year
save "`dirmaq'Potential_maq_firms_large.dta", replace


*StAn
use "`dirmaq'state_monthly_maqindustryedit.dta" , clear
keep  state year EmpStAn
sort state year
merge  state year using "`dirmaq'Potential_maq_firms_large.dta", nokeep _merge(_mergeStMo)
keep  state year EmpStAn emp plant firm
drop if firm==.


*this code splits the reshape into 25 blocks to speed it upp and then remerges.
noi di "block"
qui {
forval n=0/24 {
local np1=`n'+1
noi di "`np1'  "
preserve
keep if firm>`n'*`block' & firm<=`np1'*`block'
**************************
reshape wide plant emp, i(state year) j(firm)
**************************
mvencode plant* emp*, mv(0)
**************************
sort state year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/24 {
noi di "`n'  "
merge state  year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
***************************
sort state year
****************************
}
}

rename  EmpStAn SumEmp
*drop  state year
gen Sumtype="StAn"
save "`tempdir'Maquiladora_append_2.dta", replace


use "`dirmaq'Potential_maq_firms_large.dta", clear
sort state year
save "`dirmaq'Potential_maq_firms_large.dta", replace



*StMo
use "`dirmaq'state_monthly_maqindustryedit.dta" , clear
keep  state year EmpStMo PlantsStMo
sort state year
merge state year using "`dirmaq'Potential_maq_firms_large.dta", nokeep _merge(_mergeStMo)
keep  state year EmpStMo PlantsStMo emp plant firm
drop if firm==.
drop if EmpStMo==.

*this code splits the reshape into 25 blocks to speed it upp and then remerges.
noi di "block"
qui {
forval n=0/24 {
noi di "`np1'  "
local np1=`n'+1
preserve
keep if firm>`n'*`block' & firm<=`np1'*`block'
**************************
reshape wide plant emp, i(state year) j(firm)
**************************
mvencode plant* emp*, mv(0)
**************************
sort state year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/24 {
noi di "`n'  "
merge state year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
***************************
sort state year
****************************
}
}

rename  EmpStMo SumEmp
rename PlantsStMo SumPlant
*drop  state year
gen Sumtype="StMo"
save "`tempdir'Maquiladora_append_3.dta", replace


use "`dirmaq'Potential_maq_firms_large.dta", clear
sort state year
save "`dirmaq'Potential_maq_firms_large.dta", replace


*StMoMale
use "`dirmaq'state_monthly_maqindustryedit.dta" , clear
keep  state year MaleEmpStMo
sort state year
merge state year using "`dirmaq'Potential_maq_firms_male_large.dta", nokeep _merge(_mergeStMo)
keep  state year MaleEmpStMo emp plant firm
drop if firm==.
drop if MaleEmpStMo==.

*this code splits the reshape into 25 blocks to speed it upp and then remerges.
noi di "block"
qui {
forval n=0/24 {
noi di "`np1'  "
local np1=`n'+1
preserve
keep if firm>`n'*`block' & firm<=`np1'*`block'
**************************
reshape wide plant emp, i(state year) j(firm)
**************************
mvencode plant* emp*, mv(0) override
**************************
sort state year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/24 {
noi di "`n'  "
merge state year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
***************************
sort state year
****************************
}
}

rename   MaleEmpStMo SumEmp
*drop  state year
gen Sumtype="StMoMale"
save "`tempdir'Maquiladora_append_4.dta", replace


use "`dirmaq'Potential_maq_firms_large.dta", clear
sort state year
save "`dirmaq'Potential_maq_firms_large.dta", replace



*StMoFem
use "`dirmaq'state_monthly_maqindustryedit.dta" , clear
keep  state year FemaleEmpStMo
sort state year
merge state year using "`dirmaq'Potential_maq_firms_female_large.dta", nokeep _merge(_mergeStMo)
keep  state year FemaleEmpStMo emp plant firm
drop if firm==.
drop if FemaleEmpStMo==.

*this code splits the reshape into 25 blocks to speed it upp and then remerges.
noi di "block"
qui {
forval n=0/24 {
noi di "`np1'  "
local np1=`n'+1
preserve
keep if firm>`n'*`block' & firm<=`np1'*`block'
**************************
reshape wide plant emp, i(state year) j(firm)
**************************
mvencode plant* emp*, mv(0) override
**************************
sort state year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/24 {
noi di "`n'  "
merge state  year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
***************************
sort state year
****************************
}
}

rename   FemaleEmpStMo SumEmp
*drop  state year
gen Sumtype="StMoFemale"
save "`tempdir'Maquiladora_append_5.dta", replace







/**
*IndMo
**/

use "`dirmaq'Potential_maq_firms_large.dta", clear
sort maqindustry year
save "`dirmaq'Potential_maq_firms_large.dta", replace


use "`dirmaq'industry_monthly_maqindustryedit.dta" , clear
keep  maqindustry year EmpIndMo PlantsIndMo
sort maqindustry year
merge maqindustry year using "`dirmaq'Potential_maq_firms_large.dta", nokeep _merge(_mergeIndMo)
keep  maqindustry year EmpIndMo PlantsIndMo emp plant firm
drop if firm==.


*this code splits the reshape into 25 blocks to speed it upp and then remerges.
noi di "block"
qui {
forval n=0/24 {
noi di "`np1'  "
local np1=`n'+1
preserve
keep if firm>`n'*`block' & firm<=`np1'*`block'
**************************
reshape wide plant emp, i(maqindustry year) j(firm)
**************************
mvencode plant* emp*, mv(0)
**************************
sort maqindustry year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/24 {
noi di "`n'  "
merge maqindustry year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
***************************
sort maqindustry year
****************************
}
}

rename  EmpIndMo SumEmp
rename PlantsIndMo SumPlant
*drop  maqindustry year
gen Sumtype="IndMo"
save "`tempdir'Maquiladora_append_6.dta", replace




/**
*MunMo
**/

use "`dirmaq'Potential_maq_firms_large.dta", clear
sort muncenso year
save "`dirmaq'Potential_maq_firms_large.dta", replace


use "`dirmaq'municipio_monthly_maqindustryedit.dta" , clear
keep  muncenso year EmpMunMo PlantsMunMo
sort muncenso year
merge muncenso year using "`dirmaq'Potential_maq_firms_large.dta", nokeep _merge(_mergeMunMo)
keep  muncenso year EmpMunMo PlantsMunMo emp plant firm
drop if firm==.


*this code splits the reshape into 6 blocks to speed it upp and then remerges. (24 blocks had too few firms)
noi di "block"
qui {
forval n=0/6 {
noi di "`np1'  "
local np1=`n'+1
preserve
keep if firm>`n'*4*`block' & firm<=`np1'*4*`block'
noi di "keep if firm>"`n'*4*`block' "& firm<="`np1'*4*`block'
**************************
reshape wide plant emp, i(muncenso year) j(firm)
**************************
mvencode plant* emp*, mv(0)
**************************
sort muncenso year
**************************
save "`tempdir'TempMaqfirm`n'.dta", replace
restore
}
noi di "merge"
clear 
use "`tempdir'TempMaqfirm0.dta"
forval n=1/6 {
noi di "`n'  "
merge muncenso year using "`tempdir'TempMaqfirm`n'.dta"
erase "`tempdir'TempMaqfirm`n'.dta"
drop _merge
mvencode plant* emp*, mv(0) override
***************************
sort muncenso year
****************************
}
}



rename  EmpMunMo SumEmp
rename PlantsMunMo SumPlant
*drop  muncenso year
gen Sumtype="MunMo"
save "`tempdir'Maquiladora_append_7.dta", replace





forval n=1/6 {
append using "`tempdir'Maquiladora_append_`n'.dta"
}


mvencode plant* emp*, mv(0) override



*now I make it all one data set with obs for either plants or emp
preserve
drop emp* SumEmp

rename SumPlant Sum 
renpfix plant firm
gen stat="Plant"
save "`tempdir'Maquiladora_idreg_dataset_plant_large.dta",replace

restore
drop plant* SumPlant
gen stat="Emp"
rename SumEmp Sum


renpfix emp firm

append using  "`tempdir'Maquiladora_idreg_dataset_plant_large.dta"

rename stat Sumstat

ds firm*, not
order `r(varlist)'

drop if Sum==.

*compress
save "`tempdir'Maquiladora_idreg_dataset_large.dta", replace



*this is my data set


*here I explore the data set a little bit and see if there are blocks that can be seperated:
/**
qui {
forval n=1/10000 {
cap egen colsum=total(firm`n')
if colsum[1]==0 {
noi di "Firm `n' redundant"
}

drop colsum

}
}
**/
*if nothing comes up there are no redundant firms (that don't feature in aggregaates).



/**
order SumPlant SumEmp
keep plant* emp*  SumPlant SumEmp




*now I run regressions constraining all coeffciients to be equal


forval n=1/`firmtotal'  {
noi constraint `n' [SumEmp]emp`n' = [SumPlant]plant`n'
}


reg3  (SumEmp emp*, nocons)  (SumPlant plant*, nocons), ols constr(1/`firmtotal')
matrix Maqids=e(b)



clear
svmat Maqids,  names(col)
keep emp*
gen ivar=1
reshape long emp, i(ivar) j(firm)
drop ivar
sort firm
merge firm using "`tempdir'Maquiladora_Firm_to_FirmID_match.dta", nokeep _merge(_mergefirm)
drop _mergefirm firm

rename emp MaqIndicator

sort firmid

save "`dirmaq'MaquiladoraEstimates.dta", replace

**/







