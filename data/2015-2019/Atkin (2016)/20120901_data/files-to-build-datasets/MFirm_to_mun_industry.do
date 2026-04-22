/*----------------------------------------------------------
MFirm_to_mun_industry.do

This takes calcsfull clean and merges in Maquiladora classifications from MMaquiladora_rough_and_ready.do.
Then it calculates different employment measures as well as interaction terms at the firm level.
I then aggregate over IMSS industry codes and save as firmdata_munindtotals.dta, and seperately over 3digit sic codes and save as firmdata_hcodeindtotals.dta.
Finally, I merge this data into the municipalities used in paper (ZM, Merge).

The final outputs are saved as newind_simpleXY.dta Where X=(ZM,Merge, ) and Y=( ,_skill). Y="_skill" are the hcode (sic 3digit), Y="" are the original codes (mycodes)  


INPUTS:
calcsfullclean.dta  (in Data\Mexico\mexico_ss_Stata\)
replaceB01_B14withDF.do (in H:/Mexico)
getting_muni_firm_data_grupo_catagories.do (in H:/Mexico)
munchanges.do (in H:/Mexico)
munworkdatafirm.dta (in H:/Mexico)
MaquiladoraEstimates_rough_new100.dta
IMSS_Hcode_David.dta
zonamet.dta

OUTPUTS:
newind_simpleXY.dta Where X=(ZM,Merge, ) and Y=( ,_skill).

FIRM CUTOFF:
Don't want all firms. Lets assume an establishment is something 
that employs x or more people in at least one year 1985-2000
Set x as local variable called cut.
------------------------------------------------------------
*/


/**
This file replaces Mgetting_muni_firm_data_industry and Mgetting_firm_exposure
**/


if "`c(os)'"=="Unix" {
local tempdir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
local dir "/home/fac/da334/Work/Mexico/"
local dirmaq "/home/fac/da334/Work/Mexico/Maquiladora Data/"
}

if "`c(os)'"=="Windows" {
local tempdir="C:/Data/Mexico/mexico_ss_Stata/"
local dir="C:/Work/Mexico/"
local dirmaq="C:/Work/Mexico/Maquiladora Data/"
}



global cutlist="50 100"
*this must be ascending







local yearend=2000
*change if extend data


clear
set mem 10000m
set maxvar 30000


set more off




use "`tempdir'calcsfullclean.dta"



qui {

sort firmid
merge firmid using "`dirmaq'MaquiladoraEstimates_rough_new100.dta", keep(MaqBinary) _merge(_mergemaq)	nokeep

gen MaqFirm=1 if MaqBinary==1

replace MaqFirm=0 if MaqFirm==.
*1 means it is a likely maq from my iterative procedure
drop _mergemaq MaqBinary


sort firmid
merge firmid using "`tempdir'femalefirms.dta", keep(malefirm femalefirm unifirm) _merge(_mergefemfirm)	nokeep


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


*First generate municipality/industry identifiers. This is 10 digit with first 5 digits being muni and last 4 being grupo with 0 in between
egen mungrupo=concat(muncenso grupo), format(%05.0f)
*will need to fillin to get all the zeroes






*Now want some measure of churn. 
*both of these do not take account of firms opening, closing and then reopening.
*that will require the fillin function

*Generate a variable which is called newfirm which is equal to 1 the year a new firm first appears after 1985.
sort year
egen newfirm=tag(firmid)
gen openyear=year if newfirm==1
replace newfirm=0 if year==1985


egen nfirmfirm=max(newfirm), by(firmid)
*this is only firms opening after 1985 and only new firms opening after 1985 with 50 or more employees initially


gen xpesofirm=newfirm
replace xpesofirm=0 if year<1995
egen pesofirm=max(xpesofirm), by(firmid)
drop xpesofirm
*this is only firms opening after peso crisis with 50 or more employees initially






gen agefirm=year-openyear+1
replace agefirm=. if agefirm<1

gsort- firmid year
egen seqfirm=seq(), by(firmid)
*this is age of firm in data starting with 1 for year of opening.


egen maxyear=max(year),by(firmid)
*this is final year of operation. If this is not 2000, then firm closed before end of sample period.

egen firmidg=group(firmid)
tsset firmidg seqfirm


gen disappear=year-f.year
*this is <-1 when a firm disappears for a few years
gen reappear=l.year-year
*this is <-1 when the year a firm reappears

*now I create a new observation for the last year of each firm, add one year and make employment equal to zero in that year (to get correct changes)
expand 2 if (year==maxyear & year!=`yearend') 
egen tag=tag(firmid year)
replace employ=0 if tag==0 
replace male=0 if tag==0 
replace female=0 if tag==0
replace year=year+1 if tag==0
replace agefirm=agefirm+1 if tag==0
replace newfirm=0 if tag==0
replace disappear=. if tag==0
replace reappear=-1 if tag==0
drop tag


*now I create a new observation for the last year of each firm, add one year and make employment equal to zero in that year (to get correct changes)
expand 2 if disappear<-1  
egen tag=tag(firmid year)
replace employ=0 if tag==0 
replace male=0 if tag==0 
replace female=0 if tag==0
replace year=year+1 if tag==0
replace agefirm=agefirm+1 if tag==0
replace newfirm=0 if tag==0
replace disappear=. if tag==0
replace reappear=-1 if tag==0
drop tag

*now I create a new observation for the last year of each firm, add one year and make employment equal to zero in that year (to get correct changes)
expand 2 if  reappear<-1 
egen tag=tag(firmid year)
replace employ=0 if tag==0 
replace male=0 if tag==0 
replace female=0 if tag==0
replace year=year-1 if tag==0
replace agefirm=agefirm-1 if tag==0
replace newfirm=0 if tag==0
replace disappear=-1 if tag==0
replace reappear=. if tag==0
drop tag

*now if a firm appears, disappears, a[[ears then disappears, I may be creating too many years. so dump half of these fake years
egen tagdrop=tag(firmidg year)
drop if tagdrop==0
drop tagdrop

*Generate a variable called closefirm which is equal to 1 the year a firm close donwn (e.g. the previous year was the last record of it) (not 2000).
*remember these are for final year of operation
gsort -year
egen closefirm=tag(firmid)
replace closefirm=0 if year==`yearend'

*this takes value 1 if firm closed in sample period
egen sampleclose=max(closefirm), by(firmid) 

gen timetoclose=maxyear-year+1
*years until closure



tsset firmidg year


*now after tsetting I can do the deltas
foreach type in employ male female { 
gen delta`type'=d.`type'
replace delta`type'=`type' if agefirm==1 & year!=1985

gen grow`type'=delta`type'/l.`type'
}

*now generate firm indicator and delta firm
gen firm=1 if employ>0 & employ!=.
replace firm=0 if employ==0
gen deltafirm=0
replace deltafirm=1 if agefirm==1
replace deltafirm=-1 if closefirm==1




*generate hire and fire binaries for each year
gen hirefirm=0
gen firefirm=0
replace hirefirm=1 if deltaemploy>0 & deltaemploy!=.
replace firefirm=1 if deltaemploy<0

*calculate standard deviation of employment by firm
egen sddemploy=sd(deltaemploy), by(firmid)
egen meandemploy=mean(deltaemploy), by(firmid)
egen meangrow=mean(growemploy), by(firmid)
gen cvdemploy=sddemploy/meandemploy
*maybe i want tis mean growth to be over all years not just the years the firm was around


*now here I create the firm level interaction terms:
*1. Firm Size
*2. Firm Employment Variance
*3. Firm Employment Coefficient of Variation
*4. Age of Firm
*5. Maquiladora
*6. Firm closes before end of sample period
*9. new: Fims that openend during sample period (but not necessarily that year)

foreach type in employ male female firm { 
gen delta`type'Isize=delta`type'*employ
gen delta`type'Ivar=delta`type'*sddemploy
gen delta`type'Icv=delta`type'*cvdemploy
gen delta`type'Iage=delta`type'*agefirm
gen delta`type'Imaq=delta`type'*MaqFirm
gen delta`type'Iclose=delta`type'*sampleclose
gen delta`type'Inew=delta`type'*nfirmfirm
gen delta`type'Imean=delta`type'*meangrow
gen delta`type'Imfirm=delta`type'*malefirm
gen delta`type'Iffirm=delta`type'*femalefirm
gen delta`type'Iufirm=delta`type'*unifirm
gen `type'Imaq=`type'*MaqFirm
}



egen group=group(muncenso grupo year)
sort group

save  "`tempdir'firmdata_firmtotals.dta", replace





sum group 

local split=20000
*this is the number of groups do pull in one go.... pretty quick so make it about a 10000?
local rmax=r(max)

forval n=1(`split')`rmax' {
local frog=`n'+`split'
use if group>=`n' & group<`frog' using "`tempdir'firmdata_firmtotals.dta", clear



// may11 new



*now I start with the mungrupo averages
foreach cut in 00 $cutlist {
foreach type in employ male female firm { 
foreach pre in  "delta" { 
egen x`pre'`type'`cut'_mun=total(`pre'`type') if abs(deltaemploy)>=`cut' & abs(deltaemploy)!=., by(muncenso grupo year)
egen `pre'`type'`cut'_mun=max(x`pre'`type'`cut'_mun), by(muncenso grupo year)
drop x`pre'`type'`cut'_mun
}
}
}

*now I start with the mungrupo averages: these are with sex specific jobs greater than 50 only. generates deltafemf50 for example
foreach cut in 00 $cutlist {
foreach type in male female  { 
foreach pre in  "delta" {
local stype=substr("`type'",1,1)
egen x`pre'`type'`stype'`cut'_mun=total(`pre'`type') if abs(delta`type')>=`cut' & abs(delta`type')!=., by(muncenso grupo year)
egen `pre'`type'`stype'`cut'_mun=max(x`pre'`type'`stype'`cut'_mun), by(muncenso grupo year)
drop x`pre'`type'`stype'`cut'_mun
}
}
}

*now I start with the mungrupo averages: these are levels. Note that level50 means just jobs created with more than 50 in single year. So these are levels only of expanding firms. Weird  (with z's) so empz50
foreach cut in $cutlist {
foreach type in employ male female firm employImaq maleImaq femaleImaq { 
foreach pre in ""  { 
egen x`pre'`type'z`cut'_mun=total(`pre'`type') if (abs(deltaemploy)>=`cut' & abs(deltaemploy)!=.)  , by(muncenso grupo year)
egen `pre'`type'z`cut'_mun=max(x`pre'`type'z`cut'_mun), by(muncenso grupo year)
drop x`pre'`type'z`cut'_mun
}
}
}

*now I start with the mungrupo averages: these are levels, different with 00 as no delta term on levels. so these are total levels emp50 would be at larger firms  
foreach cut in 00 $cutlist {
foreach type in employ male female firm employImaq maleImaq femaleImaq { 
foreach pre in ""  { 
egen x`pre'`type'`cut'_mun=total(`pre'`type')  if 	`pre'`type' >=`cut' & `pre'`type'!=. , by(muncenso grupo year)
egen `pre'`type'`cut'_mun=max(x`pre'`type'`cut'_mun), by(muncenso grupo year)
drop x`pre'`type'`cut'_mun
}
}
}



// new end




*now for interaction terms
foreach type of varlist delta*I* { 
foreach cut in 00 $cutlist {
egen x`type'`cut'_mun=total(`type') if abs(deltaemploy)>=`cut' & abs(deltaemploy)!=., by(muncenso grupo year)
egen `type'`cut'_mun=max(x`type'`cut'_mun), by(muncenso grupo year)
drop x`type'`cut'_mun
}
}


*now for other terms
foreach cut in 00 $cutlist {
foreach type in employ male female firm { 
foreach pre in  "delta" { 
foreach style in new peso nfirm  close hire fire {
egen x`pre'`style'`type'`cut'_mun=total(`pre'`type') if abs(deltaemploy)>=`cut' & `style'firm==1 & abs(deltaemploy)!=., by(muncenso grupo year)
egen `pre'`style'`type'`cut'_mun=max(x`pre'`style'`type'`cut'_mun), by(muncenso grupo year)
drop x`pre'`style'`type'`cut'_mun
}
}
}
}

*now for expansion or shrink
foreach cut in 00 $cutlist {
foreach type in employ male female firm { 
foreach pre in  "delta" { 
gen `pre'expan`type'`cut'_mun=`pre'hire`type'`cut'_mun-`pre'new`type'`cut'_mun
gen `pre'contr`type'`cut'_mun=`pre'fire`type'`cut'_mun-`pre'close`type'`cut'_mun
}
}
}

*new means new that year
*close means closed that year
*hire means year of hire
*fire means year of fire
*nfirm means opened after 1985
*pesofirm means opened after 1995




*Now selecting only one data point per municipality/industry per year
egen unique=tag(muncenso grupo year)
drop if unique==0
keep year mungrupo muncenso nomun grupo *_mun
renvars _all, postsub(_mun  )



save  "`tempdir'firmdata_munindtotals`n'.dta", replace


}


use "`tempdir'firmdata_munindtotals1.dta", clear
erase "`tempdir'firmdata_munindtotals1.dta"
local rmin=1+`split'

forval n=`rmin'(`split')`rmax' {
append using "`tempdir'firmdata_munindtotals`n'.dta"
erase "`tempdir'firmdata_munindtotals`n'.dta"
}





egen tagmungrupo=tag(muncenso grupo)
fillin muncenso grupo year

mvencode *0, mv(0) override

egen identify=max(tagmungrupo), by(muncenso grupo)
drop if identify!=1
drop identify
*(drops if there was never any firms in this group)


*here we have generated changes in firm numbers and employment etc...

*now I get deltax50 variables where I sume all the large changes.
*actually these seem to b just empx50 variables
sort mungrupo year
foreach vary in employ male female employImaq maleImaq femaleImaq  {
foreach cut in  $cutlist {
gen `vary'x`cut'=delta`vary'`cut'
replace `vary'x`cut'=`vary'x`cut'+ `vary'x`cut'[_n-1] if tagmungrupo!=1
}
}


save  "`tempdir'firmdata_munindtotals.dta", replace






*Now averaging over certain groups
do "`dir'getting_muni_firm_data_grupo_catagories.do"
*this replaces grupo with my 2 digit catagories

keep muncenso year grupo *0


foreach type of varlist *0 {
cap egen x`type'=total(`type'), by(muncenso year grupo)
}


egen tagmunyeargrupo=tag(muncenso year grupo)
keep if tagmunyeargrupo==1
keep muncenso year grupo x*
egen munyear=group(muncenso year)
reshape wide x* ,i(munyear) j(grupo) 
mvencode x*,mv(0) override
mvdecode xdelta*   if year==1985, mv(0)
renpfix x
drop  munyear 
sort muncenso year
save  "`tempdir'firmdata_origindtotals.dta", replace



clear
set mem 11000m



use "`tempdir'firmdata_munindtotals.dta", clear
sort grupo 
merge grupo using "`dir'IMSS_Hcode_David_new.dta", _merge(_mergehcode) nokeep
drop grupo
rename hcode grupo

keep muncenso year grupo *0

foreach type of varlist *0 {
cap egen x`type'=total(`type'), by(muncenso year grupo)
}

egen tagmunyeargrupo=tag(muncenso year grupo)
keep if tagmunyeargrupo==1
keep muncenso year grupo x*
egen munyear=group(muncenso year)
reshape wide x* ,i(munyear) j(grupo) 
mvencode x*,mv(0) override
mvdecode xdelta*   if year==1985, mv(0)
renpfix x
drop  munyear 
sort muncenso year

save  "`tempdir'firmdata_hcodeindtotals.dta", replace






use "`tempdir'firmdata_munindtotals.dta", clear
sort grupo 
merge grupo using "`dir'IMSS_Hcode_David_local.dta", _merge(_mergehcode) keep(imss2local grupo) nokeep
drop grupo
rename imss2local grupo

keep muncenso year grupo *0

foreach type of varlist *0 {
cap egen x`type'=total(`type'), by(muncenso year grupo)
}

egen tagmunyeargrupo=tag(muncenso year grupo)
keep if tagmunyeargrupo==1
keep muncenso year grupo x*
egen munyear=group(muncenso year)
reshape wide x* ,i(munyear) j(grupo) 
mvencode x*,mv(0) override
mvdecode xdelta*   if year==1985, mv(0)
renpfix x
drop  munyear 
sort muncenso year

save  "`tempdir'firmdata_hcodeimss2indtotals.dta", replace



use "`tempdir'firmdata_munindtotals.dta", clear
sort grupo 
merge grupo using "`dir'IMSS_Hcode_David_local.dta", _merge(_mergehcode) keep(hcodelocal grupo) nokeep
drop grupo
rename hcodelocal grupo

keep muncenso year grupo *0

foreach type of varlist *0 {
cap egen x`type'=total(`type'), by(muncenso year grupo)
}

egen tagmunyeargrupo=tag(muncenso year grupo)
keep if tagmunyeargrupo==1
keep muncenso year grupo x*
egen munyear=group(muncenso year)
reshape wide x* ,i(munyear) j(grupo) 
mvencode x*,mv(0) override
mvdecode xdelta*   if year==1985, mv(0)
*mvdecode xdeltapeso*   if year<1995, mv(0)
*mvdecode xclose* xfire*  if year==`yearend', mv(0)
renpfix x
drop  munyear 
sort muncenso year

save  "`tempdir'firmdata_hcodelocalindtotals.dta", replace






}
*end qui

clear
set mem 8000m


*now merge into the munis used in paper
*need to run this on both hcodes and origcodes


*first original industry codes:
*------------------------------------------------------------

use   "`tempdir'firmdata_origindtotals.dta", clear
renvars , subst(female fem)
renvars , subst(employ emp)
compress
order year muncenso
sort year muncenso
save "`tempdir'newind.dta", replace



*now we are getting the municipality list to the 1991 municipalities
do "`dir'munchanges.do"
foreach var of varlist delta* emp* firm* male* fem*  {
cap egen x`var'=total(`var'), by (muncenso year)
cap drop `var'
}

renpfix x 
egen tagmunyear=tag(muncenso year)
drop if tagmunyear==0

ls

sort muncenso
merge muncenso using `dir'mungeog, _merge(_mergegeog) keep(state)
fillin year muncenso

foreach var in emp male fem firm {
cap mvencode  `var'* , mv(0) override
}
foreach var in  delta {
cap mvdecode `var'*  if year==1985, mv(0)
}
foreach var in  deltapeso  {
cap mvdecode `var'*  if year<1995, mv(0)
}




compress
sort year muncenso
save "`tempdir'newind_simple.dta", replace


rename muncenso munimx
sort munimx
merge munimx using `dir'zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
replace munimxZM=munimx if munimxZM==.
drop munimx
rename munimxZM muncenso


replace muncenso=12 if muncenso>8999 & muncenso<10000

foreach var of varlist delta* emp* firm* male* fem*  {
cap egen x`var'=total(`var'), by (muncenso year)
cap drop `var'
}


renpfix x 
egen tagmunyear2=tag(muncenso year)
drop if tagmunyear2==0


cap drop state
cap drop _fillin

sort muncenso
merge muncenso using `dir'mungeogZM, _merge(_mergegeogzm) keep(state)
fillin year muncenso


foreach var in emp male fem firm {
cap mvencode  `var'* , mv(0) override
}
foreach var in  delta {
cap mvdecode `var'*  if year==1985, mv(0)
}
foreach var in  deltapeso  {
cap mvdecode `var'*  if year<1995, mv(0)
}

*now this gets all the firm size variables to be two digits apart from 100 which is three

compress
sort year muncenso
save "`tempdir'newind_simpleZM.dta", replace



joinby muncenso year using "`dir'munworkdatafirm.dta", unm(u)

foreach var in  delta emp male fem firm {
cap mvencode  `var'* , mv(0) override
}

foreach var of varlist delta* emp* male* fem* firm* {
replace  `var'=`var'/2 if splitters==2
}

foreach var of varlist delta* emp* male* fem* firm* {
cap egen x`var'=total(`var'), by (muncensonew year)
cap drop `var'
}


renpfix x 
egen tagmunyear3=tag(muncensonew year)
drop if tagmunyear3==0

drop muncenso
rename muncensonew muncenso


foreach var in emp male fem firm {
cap mvencode  `var'* , mv(0) override
}
foreach var in  delta {
cap mvdecode `var'*  if year==1985, mv(0)
}
foreach var in  deltapeso  {
cap mvdecode `var'*  if year<1995, mv(0)
}


*now this gets all the firm size variables to be two digits apart from 100 which is three

compress
sort year muncenso
save "`tempdir'newind_simpleMerge.dta", replace






*second hcode industry codes:
*------------------------------------------------------------


foreach typer in "" "local" "imss2" {

use   "`tempdir'firmdata_hcode`typer'indtotals.dta", clear
renvars , subst(female fem)
renvars , subst(employ emp)
compress
order year muncenso
sort year muncenso
save "`tempdir'newind`typer'_skill.dta", replace



*now we are getting the municipality list to the 1991 municipalities
do "`dir'munchanges.do"
foreach var of varlist delta* emp* firm* male* fem*  {
cap egen x`var'=total(`var'), by (muncenso year)
cap drop `var'
}


renpfix x 
egen tagmunyear=tag(muncenso year)
drop if tagmunyear==0

ls

sort muncenso
merge muncenso using `dir'mungeog, _merge(_mergegeog) keep(state)
fillin year muncenso


foreach var in emp male fem firm {
cap mvencode  `var'* , mv(0) override
}
foreach var in  delta {
cap mvdecode `var'*  if year==1985, mv(0)
}
foreach var in  deltapeso  {
cap mvdecode `var'*  if year<1995, mv(0)
}




compress
sort year muncenso
save "`tempdir'newind`typer'_simple_skill.dta", replace

rename muncenso munimx
sort munimx
merge munimx using `dir'zonamet.dta, nokeep _merge(_mergeZM)
drop _mergeZM
replace munimxZM=munimx if munimxZM==.
drop munimx
rename munimxZM muncenso


replace muncenso=12 if muncenso>8999 & muncenso<10000

foreach var of varlist delta* emp* firm* male* fem*  {
cap egen x`var'=total(`var'), by (muncenso year)
cap drop `var'
}


renpfix x 
egen tagmunyear2=tag(muncenso year)
drop if tagmunyear2==0


cap drop state
cap drop _fillin

sort muncenso
merge muncenso using `dir'mungeogZM, _merge(_mergegeogzm) keep(state)
fillin year muncenso


foreach var in emp male fem firm {
cap mvencode  `var'* , mv(0) override
}
foreach var in  delta {
cap mvdecode `var'*  if year==1985, mv(0)
}
foreach var in  deltapeso  {
cap mvdecode `var'*  if year<1995, mv(0)
}


*now this gets all the firm size variables to be two digits apart from 100 which is three

compress
sort year muncenso
save "`tempdir'newind`typer'_simpleZM_skill.dta", replace


joinby muncenso year using "`dir'munworkdatafirm.dta", unm(u)


foreach var in  delta emp male fem firm {
cap mvencode  `var'* , mv(0) override
}

foreach var of varlist delta* emp* male* fem* firm* {
replace  `var'=`var'/2 if splitters==2
}


foreach var of varlist delta* emp* male* fem* firm* {
cap egen x`var'=total(`var'), by (muncensonew year)
cap drop `var'
}


renpfix x 
egen tagmunyear3=tag(muncensonew year)
drop if tagmunyear3==0

drop muncenso
rename muncensonew muncenso


foreach var in emp male fem firm {
cap mvencode  `var'* , mv(0) override
}
foreach var in  delta {
cap mvdecode `var'*  if year==1985, mv(0)
}
foreach var in  deltapeso  {
cap mvdecode `var'*  if year<1995, mv(0)
}


*now this gets all the firm size variables to be two digits apart from 100 which is three

compress
sort year muncenso
save "`tempdir'newind`typer'_simpleMerge_skill.dta", replace




}


















