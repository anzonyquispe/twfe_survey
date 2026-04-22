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



/**
problem... 

getting only non-maq identification on the 2nd 3rd 4th pass etc. this should not be the case:
1st pass: impossible to get -1's
2nd pass: impossible to get 1's
3rd pass: 1's apossible as non-maq's being removed, lowering rowsum below sum in certain cases. Not sure how we are getting -1's removed (as seems to be the case). Possibly an error.
*should work now, at least it does on test file
**/



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

qui {


clear
set mem 1800m

set maxvar 32767


set matsize 11000


set more off


local splits=9
local splits1=10
*this is how many bits i divide my data into

forval tolerance = 0.9(0.05)1 {
local tolend=`tolerance'*100
*(for labelling purposes) 
*this is proportion of firms or employment that must be Maquiladora for me to assume all firms in that average are maquiladora firms.



local firmfinal=.



*this needs to be run first to get the file in with the ordering etc.

use "`tempdir'Maquiladora_idreg_dataset_large.dta", clear
aorder firm*

*i create 10 marks for use with splitting up the file later
qui d
drop   year muncenso Sumtype maqdivision state maqindustry
local firmtotal=r(k)-2
local section=ceil((r(k)-2)/`splits1')
di "`section'"
forval n=0/`splits' {
gen mark`n'=.
local start=`n'*`section'+1
move mark`n' firm`start'
}
order Sum Sumstat
gen mark`splits1'=.
*final mark goes at end
save "`tempdir'Maquiladora_idreg_dataset_input1_`tolend'.dta", replace



*here is where my iterative process starte:

forval iteration=1/10{
*forval iteration=3/5{

no di "Iteration `iteration'"
*cap {


if `firmfinal'!=0 {

use "`tempdir'Maquiladora_idreg_dataset_input`iteration'_`tolend'.dta", clear
erase "`tempdir'Maquiladora_idreg_dataset_input`iteration'_`tolend'.dta"



egen Rowsum=rowtotal(firm*)
gen  pemp=Sum/Rowsum if Sumstat=="Emp"
gen  pplant=Sum/Rowsum if Sumstat=="Plant"



preserve
*now I drop all rows where (almost) all the firms are maquiladoras or if no maqs in row
drop if (pemp>=`tolerance' & pemp!=.) | (pplant>=`tolerance' & pplant!=.) | Sum==0
drop Rowsum pemp pplant
order Sum Sumstat
save "`tempdir'Maquiladora_idreg_dataset_matrix`iteration'_`tolend'.dta", replace
restore




order pemp pplant
keep pemp pplant firm* mark*
gen id=_n
order id pemp pplant




/*
so maybe iterative procedure....
start by taking out all firms who are likely maquiladoras (say proportion of firms=0.9)
then i need to recalculate averages with these firms removed. shrink the size of the matrix

so below is pretty good, gets MaqIndicator which is equal to 1 if one row has greater than 90% employment. That is about 1/3rd of th 15,000 firms.... Although if I start with 10,000 firms this may be a larger proportion. I can then call all these firms maquiladoras, and recalculate all the aggregates with the remaining firms, then redo the process until it stops. At this point possibly Hongda's strategy may work.

Or perhaps better is to make them each 0.9 of a mqauiladora (if the proportion of jobs=0.9). But I think the aim is to make the matrix smaller so want to assign 1's and 0's.

*/






forval n=0/`splits' {

preserve


local ends=`n'+1
local start=`n'
keep id pemp pplant mark`start'- mark`ends'



lookfor firm

if "`r(varlist)'"!="" {


qui reshape long firm, i(id) j(firmid)
*if firm>0 then this firm entered in that particular aggregate so keep that agg for that firm
drop if firm==0 | firm==.
drop firm

count

if `r(N)'>0 {

qui reshape wide pemp pplant, i(firmid) j(id)

egen max=rowmax(pemp* pplant*)
egen mean=rowmean(pemp* pplant*)
egen min=rowmin(pemp* pplant*)

egen maxemp=rowmax(pemp*)
egen meanemp=rowmean(pemp*)
egen minnemp=rowmin(pemp*)

egen maxplant=rowmax(pplant*)
egen meanplant=rowmean(pplant*)
egen minplant=rowmin(pplant*)

*so my rough criteria for a firm is: maquiladora=1 if max proportion>0.9. Then maq probability is a function of max and mean plant and emp if less than this. Max is better, as is plant.)
gen MaqIndicatorFirm=1 if  max>=`tolerance' & max!=.
replace MaqIndicatorFirm=0 if max==.
replace MaqIndicatorFirm=0 if max==0
gen MaqBinary=0 
replace MaqBinary=1 if MaqIndicatorFirm==1 
replace MaqBinary=-1 if min==0 & MaqIndicatorFirm!=1 
*so just employment binary

}
*from if rn

else {
use "`tempdir'TempMaqInd_blank.dta", clear
save "`tempdir'TempMaqInd`n'.dta", replace
}


}
*from if varlist

else {
use "`tempdir'TempMaqInd_blank.dta", clear
save "`tempdir'TempMaqInd`n'.dta", replace
}
*from splits



save "`tempdir'TempMaqInd`n'.dta", replace
restore
}






noi di "merge"
clear 
use "`tempdir'TempMaqInd0.dta"
erase "`tempdir'TempMaqInd0.dta"
forval n=1/`splits' { 
noi di "`n'  "
append using "`tempdir'TempMaqInd`n'.dta"
erase "`tempdir'TempMaqInd`n'.dta"
}
drop if firm==.




order firmid Maq* m*

keep firmid MaqBinary
rename firmid firm
sort firm
save "`tempdir'Maquiladora_indicator_dataset_rough_iteration`iteration'_`tolend'.dta", replace
*this is ready to be merged into `tempdir'Maquiladora_Firm_to_FirmID_match.dta with only ones kept


noi count


local firmlist`iteration' ""
*this gets a list, firmlist, of all the firms that are Maquiladoras, which will be needed to remove them from the averages and drop them form the new matrix
forval n=1/`r(N)'  {
	if MaqBinary[`n']==1 | MaqBinary[`n']==-1 {
	*noi di "`n'"
	local firmid=firm[`n']
	local firmlist`iteration' "`firmlist`iteration'' firm`firmid'"
	}
}

noi di "Known: `firmlist`iteration''" 

 count

local maqfirmlist`iteration' ""
*this gets a list, firmlist, of all the firms that are Maquiladoras, which will be needed to remove them from the averages and drop them form the new matrix
forval n=1/`r(N)'  {
	if MaqBinary[`n']==1  {
	*noi di "`maqfirmlist`iteration''" 
	local firmid=firm[`n']
	local maqfirmlist`iteration' "`maqfirmlist`iteration'' firm`firmid'"
	}
}

noi di "Maq: `maqfirmlist`iteration''" 







*so now I bring back original matrix with rows of all maquiladoras removed


use "`tempdir'Maquiladora_idreg_dataset_matrix`iteration'_`tolend'.dta", clear
erase "`tempdir'Maquiladora_idreg_dataset_matrix`iteration'_`tolend'.dta"


if "`maqfirmlist`iteration''"=="" {
gen maqsum=0
}
else {
egen maqsum=rowtotal(`maqfirmlist`iteration'')
}

if "`firmlist`iteration''"!="" {
drop `firmlist`iteration''
}


gen NewSum=Sum-maqsum
drop Sum maqsum
rename NewSum Sum

replace Sum=0 if Sum<0

/***********

*so these Zeroes need to be removed and marked as non maq firms. this should have been done
*how to do this!
not even sure this is what i want to do. why am i getting so many negative numbers?
**************/

order Sum Sumstat

local iterationp1=`iteration'+1

save "`tempdir'Maquiladora_idreg_dataset_input`iterationp1'_`tolend'.dta", replace
*so this is the new input file with all the row dropped where all firms are maqs., and all maq colums dropped.


qui d
local firmfinal=r(k)-2-`splits1'-1
*11 is for the 11 marks or 10 +1 if splits1=10
noi di "Original Firms:`firmtotal', Firms after iteration `iteration':`firmfinal'"

}
*end if firmfinal!=0




}
*end of iteration





use "`tempdir'Maquiladora_Firm_to_FirmID_match_large.dta", clear

forval iteration=1/10{
cap {
sort  firm
merge firm using "`tempdir'Maquiladora_indicator_dataset_rough_iteration`iteration'_`tolend'.dta"
erase "`tempdir'Maquiladora_indicator_dataset_rough_iteration`iteration'_`tolend'.dta"
rename MaqBinary MaqBinary`iteration'
drop _merge
}
}


mvdecode MaqBinary*, mv(0)
egen MaqBinary=rowmax(MaqBinary*)
order firmid  MaqBinary
sort firmid


noi save "`dirmaq'MaquiladoraEstimates_rough_new`tolend'.dta", replace



}
*end of tolerance loop

} 
*end of qui


*this forms the data set with the maquila data.
*do "`dir'Mgetting_muni_firm_data_industry_maquiladora.do"



