clear
set mem 200m
set more off

*local tempdir="/var/scratch/datkin/"
*local dir="/n/homeserver2/user2a/datkin/Mexico/"


local tempdir="C:\Users\datkin\Desktop\WORK\Mexico\mexico_ss_Stata\"
local dir="H:\Mexico\"

local yearend=2000
*change this if get more data

/*----------------------------------------------------------
The following files should be in the directory above:
INPUTS:
calcs1985.dta-calcs2000.dta
labelindustry.do
gencensomun.do
labelcensomun.do


OUTPUTS:
This file produces three outputs.
calcsfullclean.dta - this is the full data set in long form

		 	      
These files are inputs into getting_muni_firm_data.do which gets 
usable municipal averages.
------------------------------------------------------------
*/

forval year=1985/`yearend'{

use "`tempdir'calcs`year'.dta", clear
egen firmid=concat(registro mod), punct(_)
drop registro mod
gen year=`year'
compress
save "`tempdir'calcs`year'edit.dta", replace
}

clear
set mem 700m

use "`tempdir'calcs1985edit.dta", clear

forval year=1986/`yearend'{
append using "`tempdir'calcs`year'edit.dta"
erase "`tempdir'calcs`year'edit.dta"
}


*here file calcsfulledit.dta was created



gen employ= male+ female+ unknown

drop unknown
*this can be backed out from total-male-female and is of no independent interest.

egen maxemploy=max(employ), by(firmid)
egen minemploy=min(employ), by(firmid)



*now for firms without municipality data I pull the codes from the first three digits of firmid
gen nomun=0
replace nomun=1 if mun==""
replace mun=substr(firmid,1,3) if nomun==1
*I should try dropping these for robustness

*seemingly all firms have consistant info for mun and grupo over time
*would think municipalities would change over time but seems not

qui{

do "`dir'labelindustry.do"



do "`dir'gencensomun.do"
do "`dir'labelcensomun.do"
}

rename mun munimss

label value muncenso mun

save "`tempdir'calcsfullclean.dta", replace

