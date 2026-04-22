************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"

************************************************************************
************************************************************************
*****1992-93
#delim ;
use in9293.dta, clear ;
***flag non-elec industries (BRICK); 
g nonelecind = nic87==2304 ;
g start=""; g end=""; order start
stcode
distcode
orgcode
owncode
opclcode
numfact
nic87
inityr
runslno
permid
mult
schcode
fcapopen
fcapclose
grcapform
mdays
totpersons
totwrkrs
totemp
wages 
salaries
bonusemp
conpf
labcost
bonuswrkrs  
qelecpur
fuels
qelecprod
qelecsold
velecsold
qeleccons
grsale
matls
nonelecind
end ; keep start-end; drop start end ;
g year=1992;
rename grcapform gross_investment ;
save asi_in9293set.dta, replace ;


*****1993-94 & 1994-95
*****1993-94 & 1994-95
*****1993-94 & 1994-95
/*



*/
*****1995-96 & 1996-97
*****1995-96 & 1996-97
*****1995-96 & 1996-97
#delim ;
foreach i in 9394 9495 9596 9697 {;
use asi`i'.dta, clear;

g start=""; g end=""; order start
stcode
ruralurbancode
statedistblk
orgcode
owncode
opclcode
numfact
nic87
inityr
runslno
permid
mult
schcode
fcapopen
fcapclose
grossactualaddition
work_men_avg
work_women_avg
work_child_avg
work_cont_avg
supervis_avg
other_avg
workingprops
unpaidfamilyemp
coopemp
totpersons
total_wages
total_bonus
total_addl_labcost
total_addl_labcost2
wages_workers
wages_supervis
wages_oth
bonus_workers
bonus_supervis
bonus_oth
qcoalcons
vcoalcons
qlignitecons
vlignitecons
qcoalgascons
vcoalgascons
qliqpetrcons
vliqpetrcons
qnatgascons
vnatgascons
qpetrolcons
vpetrolcons
qdieselcons
vdieselcons
qfurnaceoilcons
vfurnaceoilcons
qotheroilcons
votheroilcons
qwoodcons
vwoodcons
qbiomasscons
vbiomasscons
qelecpur
velecpur
qlubeoilcons
vlubeoilcons
qwatercons
vwatercons
fuels
qelecprod
qelecsold
velecsold
qeleccons
grsale
matls
nonelecind
end ; keep start-end; drop start end ; egen labcost=rowtotal(total_wages total_bonus total_addl_labcost total_addl_labcost2) ;
if `i'==9596 {; g year=1995; }; else if `i'==9394 {; g year=1993; }; else if `i'==9495 {; g year=1994; }; else {; g year=1996; };
;
rename grossactualaddition gross_investment;
save asi_asi`i'set.dta, replace ;
};





*****1997-98
*****1997-98
*****1997-98
#delim ;
use asi9798.dta, clear;
g start=""; g end=""; order start
stcode
ruralurbancode
distcode
orgcode
owncode
opclcode
numfact
nic87
inityr
runslno
permid
mult
schcode
fcapopen
fcapclose
work_men_avg
work_men_wage
work_men_bonus
work_women_avg
work_women_wage
work_women_bonus
work_child_avg
work_child_wage
work_child_bonus
work_cont_avg
work_cont_wage
work_cont_bonus
supervis_avg
supervis_wage
supervis_bonus
other_avg
other_wage
other_bonus
workingprops
unpaidfamilyemp
coopemp
totpersons
total_wages
total_bonus
total_addl_labcost
qcoalcons 
vcoalcons 
votherfuelcons 
voilcons
qelecpur
velecpur
fuels
qelecprod
velecsold
qeleccons
grsale
Export
totalinpplusrent
matls
rmstop
rmstcl
sfgstop
sfgstcl
stfgop
stfgcl
nonelecind
end ; keep start-end; drop start end ;  egen labcost=rowtotal(total_wages total_bonus total_addl_labcost) ;
g year=1997;
save asi_asi9798set.dta, replace ;



*****1998-2007
/*
empChildAverage
empChildWages
empChildBonus
empbonus
inputAddElecReqQuantity
*/
#delim ;
use "$intdata/1998-2010panel_full.dta", clear;
egen fuel = rowtotal(inputCoalConsumedValue inputGasConsumedValue inputOilConsumedValue inputOtherConsumedValue);
egen eleccons=rowtotal(inputElecGenQuantity inputElecPurchaseQuantity);
egen materials = rowtotal(inputTotalValue importTotalValue);
replace materials = materials - fuel ;
g start=""; g end=""; order start
state
year
newlocation
neworg
newown
newopen
NoF
nic3digit
Inprcode
dsl
emult2
schcode
fixedTotalNetOpen
fixedTotalNetClose
empTotalDaysManuf
empMaleAverage
empMaleWages
empMaleBonus
empFemaleAver~e
empFemaleWages
empFemaleBonus
empContractAv~e
empContractWa~s
empContractBo~s
empSuperviseA~e
empSuperviseW~s
empSuperviseB~s
empOtherAverage
empOtherWages
empOtherBonus
empSubtotalAv~e
empWorkersAverage
empTotalAverage
empTotalWages

empTotalProvi~t
inputCoalCons~y
inputCoalCons~e
inputElecPurchaseQuantity
inputElecPurchaseValue
fuel
inputElecGenQuantity 
receiptsElect~y
eleccons

productTotalGrossValue

materials
workingStockMatsOpen
workingStockMatsClose

workingStockSFGOpen
workingStockSFGClose

workingStockFGOpen
workingStockFGClose
nonelecind

fixedTotalGrossAdd



end ; keep start-end; drop start end ;

#delim cr
rename state stcode
rename newlocation ruralurbancode
rename neworg orgcode
rename newown owncode
rename newopen opclcode
rename NoF numfact
rename nic3digit nic87
rename Inprcode inityr
rename dsl permid
rename emult2 mult
rename fixedTotalNetOpen fcapopen
rename fixedTotalNetClose fcapclose
rename empTotalDaysManuf mdays

rename empMaleAverage work_men_avg
rename empMaleWages work_men_wage
rename empMaleBonus work_men_bonus
rename empFemaleAver~e work_women_avg
rename empFemaleWages work_women_wage
rename empFemaleBonus work_women_bonus
/*
rename empChildAverage work_child_avg
rename empChildWages work_child_wage
rename empChildBonus work_child_bonus
*/
rename empContractAv~e work_cont_avg
rename empContractWa~s work_cont_wage
rename empContractBo~s work_cont_bonus
rename empSuperviseA~e supervis_avg
rename empSuperviseW~s supervis_wage
rename empSuperviseB~s supervis_bonus
rename empOtherAverage other_avg
rename empOtherWages other_wage
rename empOtherBonus other_bonus
rename empSubtotalAv~e totwrkrs
rename empWorkersAverage totemp
rename empTotalAverage totpersons
rename empTotalWages total_wages
*rename empbonus total_bonus
rename empTotalProvi~t total_addl_labcost
rename inputCoalCons~y qcoalcons 
rename inputCoalCons~e vcoalcons 
rename inputElecPurchaseQuantity qelecpur
rename inputElecPurchaseValue velecpur
rename fuel fuels
rename inputElecGenQuantity qelecprod
rename receiptsElect~y velecsold
rename eleccons qeleccons
rename productTotalGrossValue grsale
rename materials matls
rename workingStockMatsOpen rmstop
rename workingStockMatsClose rmstcl
rename workingStockSFGOpen sfgstop
rename workingStockSFGClose sfgstcl
rename workingStockFGOpen stfgop
rename workingStockFGClose stfgcl


rename fixedTotalGrossAdd gross_investment


egen labcost=rowtotal(total_wages *bonus total_addl_labcost) 

* replace fuels =fuels-velecpur if velecpur!=. /*this line is outdated based on new data build processing, see code at beginning of this section generating fuels*/
//19 obs in state=="08" in 1998 have dashes in the third character of their dsl--unclear why. they also all have "B" tagged as the end fo the original dsl, and not "F". delete out these dashes-->wont match to other years.
g permid2=substr(permid,1,7)
replace permid2=subinstr(permid2,"-","",.)
destring permid2, replace
destring stcode, replace
destring nic87, replace
drop permid
rename permid permid
save asi_plant_panel_cleanset.dta, replace 


*****run collection of 1998 panel ids for later merge
include "$do/subroutines/1d_Merge Blocks of 98-99.do"


*******************APPEND ALL YEARS TOGETHER
use asi_in9293set.dta, clear
append using asi_asi9394set.dta
append using asi_asi9495set.dta
append using asi_asi9596set.dta
append using asi_asi9697set.dta
append using asi_asi9798set.dta
append using asi_plant_panel_cleanset.dta
order year ruralurbancode statedistblk, after(stcode)

qui compress
/*
foreach x of varlist  fcapopen-   totalinpplusrent {
	replace `x' = 0 if `x' == .
}
*/

#delim ;
replace totwrkrs =work_men_avg + work_women_avg + work_child_avg if year>1994 &year<1998 ;
replace totemp =totwrkrs + work_cont_avg if year>1994 &year<1998 ;
replace total_wages=wages+salaries if year<1995 ; drop wages salaries ;
replace total_bonus=bonusemp if year<1995; drop bonusemp;
replace total_addl_labcost=conpf if year<1995; drop conpf; 
*replace labcost =total_wages + total_bonus + total_addl_labcost +total_addl_labcost2 if year>1994 ;
replace wages_workers=work_men_wage+work_women_wage+work_cont_wage if year>1996 ;
/*
replace wages_supervis=supervis_wage if year>1996 ;
replace wages_oth=other_wage if year>1996 ;
replace bonus_workers=work_men_bonus+work_women_bonus+work_cont_bonus if year>1996 ;
replace bonus_supervis=supervis_bonus if year>1996 ;
replace bonus_oth=other_bonus if year>1996 ;
*/
replace voilcons=votheroilcons+vlubeoilcons+vfurnaceoilcons+vdieselcons+vpetrolcons if year ==1995 | year==1996;
replace grsale = grsale+Export if year==1997; drop Export;
#delim cr

** In 96-97 and before, the questionnaires differ: qelecprod is asked as qelec produced for own use and for re-sale. After that year, qelecprod is electricity produced for own input use.
	* This line makes qelecprod equal to qelecprod for own input use if in the early years, but it doesn’t do the replacement if qelecsold>qelecprod, which would suggest that the facility reported qelecprod for its own input use.
	replace qelecprod=qelecprod-qelecsold if year<=1996 & qelecprod>=qelecsold & qelecprod!=. & qelecsold!=. 

save "$intdata/ASI 1992-2010_stacked.dta", replace


***erase files no longer needed
erase in9293.dta
erase asi_in9293set.dta
foreach i in 9394 9495 9596 9697 9798 {
erase asi`i'.dta
erase asi_asi`i'set.dta
}
erase "$intdata/1998-2010panel_full.dta"
erase asi_plant_panel_cleanset.dta
