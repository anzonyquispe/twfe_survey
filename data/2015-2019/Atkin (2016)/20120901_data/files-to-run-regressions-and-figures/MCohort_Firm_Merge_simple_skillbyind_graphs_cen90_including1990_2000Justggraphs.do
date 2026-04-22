
clear all


*******************************
local listfirme "deltaemp"  //  emp hireemp newemp maqemp maqeemp maqecemp 
local listfirmf ""
local listfirmm ""
*******************************


*this determines which MFinalReg_IndCat`special'.do file is run. Final `file' has _allyear added if more than 2 years
*******************************
local special="_genericskill_altshort16_hcode" // _skillcharbytype
****************************************

****presumably this needs creating... once I have a nice preferred specification I guess...


*this determines whether the herfindahl measures convereted to hcodes are merged in
*******************************
local herf="" // 
*******************************


*******************************
*local years="10 11 12 13 14 15 16 17 18 19 20 21 22 23" 
local years="16" 

*******************************



*needs to be global as do file run in middle here
local  listfirm "`listfirme' `listfirmm' `listfirmf'"
global listfirm "`listfirme' `listfirmm' `listfirmf'"
foreach word in $listfirm {
local listfirmstar "`listfirmstar' `word'*"
}

*this creates keeplist like above but from list firm
local keepliste ""
foreach word in `listfirme' {
local keepliste "`keepliste' `word'00* `word'50*"
}

foreach word in `listfirmm' {
local keeplistm "`keeplistm' `word'50*"
}

foreach word in `listfirmf' {
local keeplistf "`keeplistf' `word'50*"
}
local keeplist " `keepliste' `keeplistm' `keeplistf' "


clear matrix
clear 
set mem 3000m
set matsize 10000
set maxvar 30000




if "`c(os)'"=="Unix" {
global censodir="/home/fac/da334/Data/Mexico/mexico_censo/"
global firmdir="/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global dir="/home/fac/da334/Work/Mexico/"
global workdir="/home/fac/da334/Data/Mexico/Stata10/"
global dirnet="/home/fac/da334/Work/Mexico/"
}


if "`c(os)'"=="Windows" {
global censodir="C:\Data\Mexico\mexico_censo\"
global firmdir="C:\Data\Mexico\mexico_ss_Stata\"
global workdir="C:\Data\Mexico\Stata10\"
*local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
global dir2="C:/Work/Mexico/Revision/"
global dirrev="C:/Work/Mexico/Revision/New_code/"
global dirgraph="C:/Work/Mexico/Revision/Graphs/"
global tempdir="C:/Scratch/"
}




set more off

if "`herf'"=="cen90" {
global herf2="_cen90"
}
else {
global herf2=""
}
*this is used inside MFinalreg to call the cen90 merge files.


/**-----------------------------------------------
-----------------------------------------------**/




*don't make these lists too long or else stata has trouble with a string that long and it wont allow all my substitution commmands
*it is vital emp00* goes not first and with at least two spaces before. this is because in keeplisteex i need to do the mep var seperately as want it lagged and stuff for the instrument.


*this is the variables that i create in firm file

*this creates keeplist like above but from list firm
local keepliste ""
foreach word in `listfirm' {
local keepliste "`keepliste' `word'00* `word'50*"
}

foreach word in `listfirmm' {
local keeplistm "`keeplistm' `word'50*"
}

foreach word in `listfirmf' {
local keeplistf "`keeplistf' `word'50*"
}





/**-----------------------------------------------
-----------------------------------------------**/


local cenyear=2000
*this should be changed to 2006 if want the 2005 survey data
local yearend=1999
*if my firm data goes beyond this, change here to 2005

local edit2=substr("`edit'",11,1)

global zone="ZM"
global munwork="yes"

global exposure=""
local onlyoneyearexposure=1
*these are years of exposure

*variable to rename year
global agestart=6
local ageend=45

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="keep if cenyear==`cenyear'"
*these dropvars below may involve geographical info
global dropvar4="drop if muncenso==12 "

if "${munwork}"=="yes" & `cenyear'==2000 {
global dropvar5="keep if (muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew)"
}
else if "${munwork}"=="no" & `cenyear'==2000 {
global dropvar5="keep if muncenso==mig5mun${zone} & bplmx==state"
}
else {
global dropvar5="keep if mgrate5==10"
}


global dropvar6="`edit'"

noi local control = ""
noi local control2 = ""
noi local alwaysif=""
noi local yeartrend="yobexp"
noi local iffy=""
*include if command


local counter=0
local agestart1=${agestart}+1
local ageend1=`ageend'-1
*=====================================================



use "${workdir}cohortmeans_mw${munwork}_`cenyear'.dta", clear



keep muncenso yobexp eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl eclyrschlprop011 eclyrschlprop11 eclyrschlprop78 eclyrschlprop1011 eclyrschlprop1012 eclyrschlprop9 eclyrschlprop99 eclyrschlprop1212

merge 1:1  muncenso yobexp using "${workdir}cohortmeans_mw${munwork}_1990_postfix.dta" ,  keepusing(eclyrschlprop78_1990 eclyrschlprop1011_1990 eclyrschlprop99_1990 eclyrschlprop1212_1990) keep(match master) generate(_merge10ss)
sort muncenso


sort muncenso

if "${munwork}"=="yes" {
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(*munpop15_49* state  regio* munmatch) nokeep _merge(_merge10)
sort muncenso
merge muncenso using "${dir}muncenso_incomeMerge", _merge(_mergeincrank) keep(rhhincomepc2000)
sort muncenso
merge muncenso using "${dir}progressa_muncensoZM", _merge(_mergeprogresa) 
}
else {
merge  muncenso using "${dir}mungeog${zone}.dta" ,  keep(*munpop15_49* state  regio* munmatch) nokeep _merge(_merge10)
sort muncenso
merge muncenso using "${dir}muncenso_income${zone}", _merge(_mergeincrank) keep(rhhincomepc2000)
}


*state ruralper1990 urbanpop* *munpop*  regio* maqind
drop _merge10
drop _mergeincrank
cap renpfix female fem




*for my preffered interactions specification I look at 5 year initial from before 1990 (so 85-89, or yobexp>=75 so i want yobexp between 70 and 74)
*also can do this starting in 1986 (so 85-89, or yobexp>=71 so i want yobexp between 66 and 70)
*also gets weighted and unweighted cats by percentiles.

foreach span in "1965 1969" "1968 1971" "1969 1972" {   
 

local yrbeg=word("`span'",1)
local yrend=word("`span'",2)
local yrgap=`yrend'-`yrbeg'+1
local yrin=`yrend'+16-1900

foreach thinger in 99 99_1990 1212 1212_1990 78 78_1990 1011 1011_1990 {

egen in`yrgap'p`yrin'eclyrschlprop`thinger'=wtmean(eclyrschlprop`thinger') if yobexp<=`yrend' & yobexp>=`yrbeg', by(muncenso) weight(eclwtyrschl)

egen maxin`yrgap'p`yrin'eclyrschlprop`thinger'=max(in`yrgap'p`yrin'eclyrschlprop`thinger'), by (muncenso)
replace in`yrgap'p`yrin'eclyrschlprop`thinger'=maxin`yrgap'p`yrin'eclyrschlprop`thinger'
drop maxin`yrgap'p`yrin'eclyrschlprop`thinger'

}

egen in`yrgap'p`yrin'eclyrschl=wtmean(eclyrschl) if yobexp<=`yrend' & yobexp>=`yrbeg', by(muncenso) weight(eclwtyrschl)

egen maxin`yrgap'p`yrin'eclyrschl=max(in`yrgap'p`yrin'eclyrschl), by (muncenso)
replace in`yrgap'p`yrin'eclyrschl=maxin`yrgap'p`yrin'eclyrschl
drop maxin`yrgap'p`yrin'eclyrschl


}

 


local keeplist " `keepliste' `keeplistm' `keeplistf' "

local keeplist_actualnames ""
foreach word in `listfirme' `listfirmm' `listfirmf' {
local keeplist_actualnames "`keeplist_actualnames' `word'"
}

local keeplist_actualnames=subinstr("`keeplist_actualnames'","hire","deltahire",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","fire","deltafire",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","new","deltanew",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqemp","deltaempImaq",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqeemp","deltaempImaqe",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqecemp","deltaempImaqec",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqemp","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqeemp","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqecemp","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqmale","deltamaleImaq",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqemale","deltamaleImaqe",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqecmale","deltamaleImaqec",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqmale","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqemale","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqecmale","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqfem","deltafemImaq",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqefem","deltafemImaqe",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","maqecfem","deltafemImaqec",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqfem","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqefem","",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","nmaqecfem","",.)
local keeplist_actualnamesX ""
foreach word in `keeplist_actualnames' {
local keeplist_actualnamesX "`keeplist_actualnamesX' *`word'*"
}


foreach yearset of num `years'  {
*s now we get seperate two year averages for whatever years are here. e.g. in 15 16 case we get 15/16 and 16/17


local yearplus1=`yearset' + 1
local twoyearset="`yearset' `yearplus1'"
if `onlyoneyearexposure'==1 {
local twoyearset="`yearset'"
}

*so I bring in the data, years is 15 16 now, and then essentially all I am doing is labelling them with a q15, q16 type thing in the twoyearset as i am bring in in the merge data for firms, i am bringing it in at different years..


foreach yearvar of num `twoyearset'  {



gen year=yobexp + `yearvar' 
replace year=. if year>`yearend' | year<1979


foreach sex in "male" "fem" "" {
replace `sex'munpop15_49_1995=(`sex'munpop15_49_1990+`sex'munpop15_49_2000)/2 if `sex'munpop15_49_1995==0


*this is where i am - this needs to be corrected and then firm data needs to be put past 2000 and then change the whole file to 2005
*want mid year population really... 2000 and 1990 are in feb, 2005 and 1995 are in october and november respectively
gen `sex'munpop15_49=`sex'munpop15_49_1990+(year+0.25-1990)*((`sex'munpop15_49_1995-`sex'munpop15_49_1990)/5.5) if year<=1995
replace `sex'munpop15_49=`sex'munpop15_49_1995+(year-0.25-1995)*((`sex'munpop15_49_2000-`sex'munpop15_49_1995)/4.5) if year>1995 & year<2000
replace `sex'munpop15_49=`sex'munpop15_49_2000+(year+0.25-2000)*((`sex'munpop15_49_2005-`sex'munpop15_49_2000)/5.5) if year>=2000 
replace `sex'munpop15_49=1 if `sex'munpop15_49<1
}

rename munpop15_49 empmunpop15_49


sort year muncenso
preserve
if "${munwork}"=="yes" {
use `keeplist_actualnamesX' year muncenso using  "${firmdir}newind`herf'_simpleMerge_skill.dta", clear
cap renvars *deltahire* , sub(deltahire hire)
cap renvars *deltafire* , sub(deltafire fire)
cap renvars *deltanew* , sub(deltanew new)

	foreach xer of var delta*Imaq* {
	local namer=regexr("`xer'","Imaqec","")
	local namer=regexr("`namer'","Imaqe","")
	local namer=regexr("`namer'","Imaq","")
	gen n`xer'=`namer'-`xer' 	
	}

cap renvars delta*Imaqec* , sub(delta maqec)
cap renvars maq*Imaqec* , sub(Imaqec )
cap renvars ndelta*Imaqec* , sub(delta maqec)
cap renvars nmaq*Imaqec* , sub(Imaqec )

cap renvars delta*Imaqe* , sub(delta maqe)
cap renvars maq*Imaqe* , sub(Imaqe )
cap renvars ndelta*Imaqe* , sub(delta maqe)
cap renvars nmaq*Imaqe* , sub(Imaqe )

cap renvars delta*Imaq* , sub(delta maq)
cap renvars maq*Imaq* , sub(Imaq ) 
cap renvars ndelta*Imaq* , sub(delta maq)
cap renvars nmaq*Imaq* , sub(Imaq ) 

save "${firmdir}newind`herf'_simpleMerge_skill_temp.dta", replace
}
else {
use  `keeplist_actualnamesX' year muncenso using  "${firmdir}newind`herf'_simple${zone}_skill.dta", clear
cap renvars *deltahire* , sub(deltahire hire)
cap renvars *deltafire* , sub(deltafire fire)
cap renvars *deltanew* , sub(deltanew new)

	foreach xer of var delta*Imaq* {
	local namer=regexr("`xer'","Imaqec","")
	local namer=regexr("`namer'","Imaqe","")
	local namer=regexr("`namer'","Imaq","")
	gen n`xer'=`namer'-`xer' 	
	}

cap renvars delta*Imaqec* , sub(delta maqec)
cap renvars maq*Imaqec* , sub(Imaqec )
cap renvars ndelta*Imaqec* , sub(delta maqec)
cap renvars nmaq*Imaqec* , sub(Imaqec )

cap renvars delta*Imaqe* , sub(delta maqe)
cap renvars maq*Imaqe* , sub(Imaqe )
cap renvars ndelta*Imaqe* , sub(delta maqe)
cap renvars nmaq*Imaqe* , sub(Imaqe )

cap renvars delta*Imaq* , sub(delta maq)
cap renvars maq*Imaq* , sub(Imaq ) 
cap renvars ndelta*Imaq* , sub(delta maq)
cap renvars nmaq*Imaq* , sub(Imaq ) 
save "${firmdir}newind`herf'_simple${zone}_skill_temp.dta", replace
}
restore
* so here I rename deltahire hire and delat*Imaq maq* so that it fits as variable names get a bit long!

if "${munwork}"=="yes" {
merge year muncenso  using "${firmdir}newind`herf'_simpleMerge_skill_temp.dta" ,nokeep keep(`keeplist') _merge(_merge`yearvar')
erase "${firmdir}newind`herf'_simpleMerge_skill_temp.dta"
}
else {
merge year muncenso  using "${firmdir}newind`herf'_simple${zone}_skill_temp.dta" ,nokeep keep(`keeplist') _merge(_merge`yearvar')
erase "${firmdir}newind`herf'_simple${zone}_skill_temp.dta"
}


foreach var in   emp male fem firm {
cap mvencode  `var'*  if _merge`yearvar'==1 & (year>=1985 | year<=`yearend'), mv(0) override
}

foreach var in   delta hire fire new maq naq {
cap mvencode  `var'*  if _merge`yearvar'==1 & (year>=1986 | year<=`yearend'), mv(0) override
}

foreach var in   deltapeso {
cap mvencode  `var'*  if  (year>=1986 | year<=`yearend'), mv(0) override
}


noi di "========================="
noi di "Year `yearvar' half way"
noi di "========================="


cap drop _merge`yearvar'

global keeplistex=subinstr("`keepliste'","*","",.)
global keeplistmx=subinstr("`keeplistm'","*","",.)
global keeplistfx=subinstr("`keeplistf'","*","",.)

tsset  muncenso year




noi do "${dirrev}MFinalReg_IndCat`special'.do"




/*
This is where the industries are formed. Need to put them into the MFinalReg_IndCat_skillbytype.do code if want more industries.
*/



*this is where the industry catagories are determined. It depends on the file coming in what I do with these. for the standard one I take my indsutry codes that run 1-16
*for skill I use the davidcode and have a much finer split,.,.
*maq and maqskill have these splits borken by maq and non maq
local listhcode "${listhcode}"


noi di "========================="
noi di "Industry Interactions: `listhcode'"
noi di "========================="
noi di "Firm Interactions: `listfirm'"
noi di "========================="

 







keep if year!=.
drop  yobexp


tab year



****
*cheeky code that change maq variables into new industry codes (81 82 and 83)
cap {
foreach X of varlist deltaemp*13 {
local nameto=regexr("`X'","13$","81")
local nameto=regexr("`nameto'","13$","81")
local namefrom=regexr("`X'","deltaemp","maqemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}

cap {
foreach X of varlist deltaemp*13  {
local nameto=regexr("`X'","13$","82")
local nameto=regexr("`nameto'","13$","82")
local namefrom=regexr("`X'","deltaemp","maqeemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}

cap {
foreach X of varlist deltaemp*13  {
local nameto=regexr("`X'","13$","83")
local nameto=regexr("`nameto'","13$","83")
local namefrom=regexr("`X'","deltaemp","maqecemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}




foreach var of varlist `listfirmstar' {
gen `var'cp=`var'/munpop15_49_1990
}



foreach n of numlist 10/25 30/45 50/99  {
cap  drop *deltaemp*`n'
}





renvars *cp, prefix(cp)
renvars *cp, postsub(cp )







egen emeanschool=mean(eclyrschl), by(muncenso)

gen schooll5=eclyrschl if year<=1985 & year>1980
egen emeanschooll5=mean(schooll5), by(muncenso)
drop schooll5


 merge m:1 muncenso using "${dir}schatgrade_byMun_Age_wide.dta", generate(Schatgrade_merge) keepusing(eschatgradeagez_90_1? eschatgradeagey_90_1? eschatgradeagez_00_1? eschatgradeagey_00_1?)
merge m:1 muncenso using "${dir}Schatt_byMun_Age_wide.dta", generate(Schatt_merge) keepusing(eschattage_90_16 eschattage_00_16)



local intlist " in4p88complex1ay in5p85complex1ay in4p87complex1ay in4p88complex2ay in5p85complex2ay in4p87complex2ay in4p88complex3ay in5p85complex3ay in4p87complex3ay in4p88complex4ay in5p85complex4ay in4p87complex4ay"


local agey "agey"
local delta=0.5
foreach intro in in5p85 { // in4p88 in4p87 
gen `intro'complex1ay=(`intro'eclyrschlprop99-(eschatgrade`agey'_00_14-eschatgrade`agey'_00_15))
gen `intro'complex2ay=(`intro'eclyrschlprop78-(eschatgrade`agey'_00_12-eschatgrade`agey'_00_13))
gen `intro'complex3ay=(`intro'eclyrschlprop1212*`delta'+(eschatgrade`agey'_00_17-eschatgrade`agey'_00_18)*(1-`delta'))
gen `intro'complex4ay=(`intro'eclyrschlprop1011*`delta'+(eschatgrade`agey'_00_15-eschatgrade`agey'_00_16)*(1-`delta'))	
gen `intro'complex5ay=(`intro'eclyrschlprop1212)	
gen `intro'complex6ay=(`intro'eclyrschlprop1212)
}






foreach thing in `intlist' {  // 


 
_pctile `thing' if year<2000 & year>1985 [aw=eclwtyrschl],  percentiles(33.33 66.666)
gen `thing'_3wcat1=(`thing'<=`r(r1)')
gen `thing'_3wcat2=(`thing'>`r(r1)' & `thing'<`r(r2)')
gen `thing'_3wcat3=(`thing'>=`r(r2)')

_pctile `thing' if year==1999 ,  percentiles(33.33 66.666)
gen `thing'_3uwcat1=(`thing'<=`r(r1)')
gen `thing'_3uwcat2=(`thing'>`r(r1)' & `thing'<`r(r2)')
gen `thing'_3uwcat3=(`thing'>=`r(r2)')

_pctile `thing'  if year<2000 & year>1985 [aw=eclwtyrschl],  percentiles(50)
gen `thing'_2wcat1=(`thing'<=`r(r1)')
gen `thing'_2wcat2=(`thing'>`r(r1)')

_pctile `thing' if year==1999 ,  percentiles(50)
gen `thing'_2uwcat1=(`thing'<=`r(r1)')
gen `thing'_2uwcat2=(`thing'>`r(r1)')

}




*what is the correct measure for effect size? 
*Number of people on the dropout margin, should this be proportion or difference (particularly when i get atgrade).





cap d hire*
if _rc==0 {
local lister "delta*emp???? hire*emp????    cpdelta*emp???? cphire*emp????"
local intlistcat2 "delta*emp*2c* hire*emp*2c*  cpdelta*emp*2c* cphire*emp*2c*"
local intlistcat3 "delta*emp*3c* hire*emp*3c* cpdelta*emp*3c* cphire*emp*3c* "
}
else {
local lister "delta*emp????   cpdelta*emp???? "
local intlistcat2 "delta*emp*2c*   cpdelta*emp*2c* "
local intlistcat3 "delta*emp*3c*  cpdelta*emp*3c* "

}



foreach var of varlist `lister' {
local counter=1
foreach thing in  `intlist' {
gen Z`counter'`var'=`var'*`thing'
local Z`counter'="`thing'"
local counter=`counter'+1
}
}

*i change the cat number to mark the cross with the interaction category
cap d delta*emp*2c*
if _rc==0 {
foreach var of varlist `intlistcat2' {
local counter=1
foreach thing in  `intlist' {
gen Z`counter'_`var'=`var'*`thing'_2uwcat1
renvars Z`counter'_`var', sub(2c 2cu1)
gen Z`counter'_`var'=`var'*`thing'_2uwcat2
renvars Z`counter'_`var', sub(2c 2cu2)
gen Z`counter'_`var'=`var'*`thing'_2wcat1
renvars Z`counter'_`var', sub(2c 2cw1)
gen Z`counter'_`var'=`var'*`thing'_2wcat2
renvars Z`counter'_`var', sub(2c 2cw2)

gen Q`counter'_`var'=`var'*`thing'_3uwcat1
renvars Q`counter'_`var', sub(2c 2cu1)
gen Q`counter'_`var'=`var'*`thing'_3uwcat2
renvars Q`counter'_`var', sub(2c 2cu2)
gen Q`counter'_`var'=`var'*`thing'_3uwcat3
renvars Q`counter'_`var', sub(2c 2cu3)
gen Q`counter'_`var'=`var'*`thing'_3wcat1
renvars Q`counter'_`var', sub(2c 2cw1)
gen Q`counter'_`var'=`var'*`thing'_3wcat2
renvars Q`counter'_`var', sub(2c 2cw2)
gen Q`counter'_`var'=`var'*`thing'_3wcat3
renvars Q`counter'_`var', sub(2c 2cw3)


renpfix Z`counter'_ Z`counter'
renpfix Q`counter'_ Z`counter'3
local counter=`counter'+1
}
}
}


cap d delta*emp*3c*
if _rc==0 {
foreach var of varlist `intlistcat3' {
local counter=1
foreach thing in  `intlist' {
gen Z`counter'_`var'=`var'*`thing'_3uwcat1
renvars Z`counter'_`var', sub(3c 3cu1)
gen Z`counter'_`var'=`var'*`thing'_3uwcat2
renvars Z`counter'_`var', sub(3c 3cu2)
gen Z`counter'_`var'=`var'*`thing'_3uwcat3
renvars Z`counter'_`var', sub(3c 3cu3)
gen Z`counter'_`var'=`var'*`thing'_3wcat1
renvars Z`counter'_`var', sub(3c 3cw1)
gen Z`counter'_`var'=`var'*`thing'_3wcat2
renvars Z`counter'_`var', sub(3c 3cw2)
gen Z`counter'_`var'=`var'*`thing'_3wcat3
renvars Z`counter'_`var', sub(3c 3cw3)
renpfix Z`counter'_ Z`counter'
local counter=`counter'+1
}
}
}







cap d emp* hire*
if _rc==0 {
keep year muncenso region1 region2 state empmunpop15_49 Z* emp* *hire* *delta* eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl eclyrschlprop1011 eclyrschlprop1012
order year muncenso region1 region2 state empmunpop15_49 Z* emp* *hire* *delta* eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl eclyrschlprop1011 eclyrschlprop1012
}
else {
keep year muncenso region1 region2 state empmunpop15_49 Z* *delta* eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl eclyrschlprop1011 eclyrschlprop1012
order year muncenso region1 region2 state empmunpop15_49 Z* *delta* eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl eclyrschlprop1011 eclyrschlprop1012

}

*cap drop *18
*dont need manuf+services
drop if year==1985
drop if year==2000
drop if muncenso==12
*there are still small differences in the totals of all jobs and my categories, presumably because some guys in missing job cats are not categorized (e.g. 339).





save "${tempdir}temp_industry_skill_jobs_mw${munwork}_`cenyear'_july11`special'bytype_allyear.dta", replace

*these data allow me to run regressions testing various differences in means




  
noi di "load temp data"


use "${tempdir}temp_industry_skill_jobs_mw${munwork}_`cenyear'_july11`special'bytype_allyear.dta"
 
 
	 

 


cap d emp* hire* 
if _rc==0 {
collapse (sum)  *delta* emp* *hire*    (mean) muncenso region1 region2 state eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl, by(year)
save "${tempdir}temp_industry_skill_jobs_mw${munwork}_`cenyear'_july11`special'bytype_allyear_collapse.dta", replace
}
else {
collapse (sum)  *delta* emp*   (mean) muncenso region1 region2 state eclyrschl mclyrschl fclyrschl eclwtyrschl mclwtyrschl fclwtyrschl, by(year)
save "${tempdir}temp_industry_skill_jobs_mw${munwork}_`cenyear'_july11`special'bytype_allyear_collapse.dta", replace
}

}
}
*two eyar set







use "${tempdir}temp_industry_skill_jobs_mw${munwork}_`cenyear'_july11`special'bytype_allyear_collapse.dta", clear


*cap drop  *podelta* 
cap drop  *nedelta* 
cap drop  *fire*


cap drop empmunpop15_49



*****************

local stublist ""
qui ds *26
local stubs "`r(varlist)'"
tokenize `stubs'
forval n=1/2000 {
local `n'=regexr("``n''","26","")
local stublist `stublist' ``n''
}

noi di "`stublist'"

foreach X in `stublist' {

}



********************
 


local stublist ""
qui ds *26
local stubs "`r(varlist)'"
tokenize `stubs'
forval n=1/2000 {
local `n'=regexr("``n''","26","")
local stublist `stublist' ``n''
}


reshape long `stublist' , i(year muncenso region1 region2 state) j(industry)





*cap rename empmunpop15_49 xempmunpop15_49

local stublist ""
qui ds *50
local stubs "`r(varlist)'"
tokenize `stubs'
forval n=1/2000 {
local `n'=regexr("``n''","50","")
local stublist `stublist' ``n''
}

noi di "`stublist'"



reshape long `stublist' , i(year muncenso region1 region2 state industry ) j(cutoff) string
destring cutoff, replace



*I think Z?3 is only for 2 cat variables where may want to do 2*3
  *works up to here...


foreach beg in "po" "ne" "cp" "cppo" "cpne" "" {
foreach mid in delta hire fire maq maqe maqec deltahfc deltahfa {
foreach end in emp male fem {
cap rename `beg'`mid'`end' `beg'`mid'`end'all
forval n=1/18 {
cap rename Z`n'`beg'`mid'`end' Z`n'`beg'`mid'`end'all
cap gen Z`n'3`beg'`mid'`end'all=Z`n'`beg'`mid'`end'all
}
}
}
}
cap rename emp empall





*for wage variables, creat ratios to get means:
cap {
foreach var of varlist *deltaempv*  {

local dumpster=regexr("`var'","emp.","emp")
local dumpster=regexr("`dumpster'","sz","scz")

local dumpster2=regexr("`var'","empv","empvv")
local dumpster2=regexr("`dumpster2'","empw","empww")
*gen `dumpster2'=`var'/`dumpster'

egen X1`dumpster2'=total(`var'), by(industry cutoff)
egen X2`dumpster2'=total(`dumpster'), by(industry cutoff)
gen `dumpster2'=X1`dumpster2'/X2`dumpster2'
drop X1`dumpster2' X2`dumpster2'

}
}

cap {
foreach var of varlist  *deltaempw* {

local dumpster=regexr("`var'","emp.","emp")
local dumpster=regexr("`dumpster'","sz","scz")

local dumpster2=regexr("`var'","empv","empvv")
local dumpster2=regexr("`dumpster2'","empw","empww")
*gen `dumpster2'=`var'/`dumpster'

egen X1`dumpster2'=total(`var'), by(industry cutoff)
egen X2`dumpster2'=total(`dumpster'), by(industry cutoff)
gen `dumpster2'=X1`dumpster2'/X2`dumpster2'
drop X1`dumpster2' X2`dumpster2'

}
}


local stublist ""
qui ds *all
local stubs "`r(varlist)'"
tokenize `stubs'
forval n=1/2000 {
local `n'=regexr("``n''","all","")
local stublist `stublist' ``n''
}

noi di "`stublist'"




reshape long `stublist' , i(year muncenso region1 region2 state  industry cutoff) j(type) string




	gen cenyear=substr(type,-3,2)
     	gen migrant=substr(type,-4,1)
      	gen category=substr(type,-5,1)
      	gen typer=regexr(type,"...0_","")
	replace typer=regexr(typer,"..9m_","")
	replace typer=regexr(typer,"..9s_","")
	replace typer=regexr(typer,"..9c_","")
	replace typer=regexr(typer,"..2m_","")
	replace typer=regexr(typer,"..2s_","")
	replace typer=regexr(typer,"..2c_","")

	gen  ztyper=regexr(type,"....0_","")
	replace ztyper=regexr(ztyper,"...9m_","")
	replace ztyper=regexr(ztyper,"...9s_","")
	replace ztyper=regexr(ztyper,"...9c_","")
	replace ztyper=regexr(ztyper,"...2m_","")
	replace ztyper=regexr(ztyper,"...2s_","")
	replace ztyper=regexr(ztyper,"...2c_","")
	gen  zcategory=substr(type,-6,2)
destring  category, replace
destring  zcategory, replace force
*tostring zcategory, generate(zzcategory)
*encode zzcategory if zzcategory!=".", generate(zzzcategory)

replace category=zcategory if zcategory!=.
replace typer=ztyper if zcategory!=.
 
label define catlbl 11 "D1/S1" 12 "D1/S2" 21 "D2/S1" 22 "D2/S2" 23 "D2/S3" 13 "D1/S3" 31 "D3/S1" 32 "D3/S2" 33 "D3/S3"
label values category catlbl



noi di "`stublist'"



*so this is the total within a category over all years.
foreach cats in  `stublist' {
cap egen `cats'tot=total(`cats'), by(industry cutoff type)
cap egen `cats'tot90=total(`cats') if year>1990, by(industry cutoff type)

cap egen `cats'mean=mean(`cats'), by(industry cutoff type)
cap egen `cats'mean90=mean(`cats') if year>1990, by(industry cutoff type)
}

*so this is proportion of cat within total typer (if using total measure it is for all years rather than particular year)
foreach thing in  `stublist'  {
foreach ender in "" "tot" "tot90" {
cap egen x`thing'`ender'=total(`thing'`ender'), by(year industry cutoff migrant cenyear typer)
cap gen prop`thing'`ender'=`thing'`ender'/x`thing'`ender'
}
}





cap d hire* podemp*
if _rc==0 {
local lister "cpdeltaempmean cpdeltaempmean90 deltaempmean deltaempmean90 deltaemp deltaemptot deltaemptot90 hireemp hireemptot hireemptot90 podeltaemp podeltaemptot podeltaemptot90 nedeltaemp nedeltaemptot nedeltaemptot90 cpdeltaemp cpdeltaemptot cpdeltaemptot90 cphireemp cphireemptot cphireemptot90 cppodeltaemp cppodeltaemptot cppodeltaemptot90 cpnedeltaemp cpnedeltaemptot cpnedeltaemptot90"
}
else {
cap d hire* 
if _rc==0 {
local lister "cpdeltaempmean cpdeltaempmean90 deltaempmean deltaempmean90 deltaemp deltaemptot deltaemptot90 hireemp hireemptot hireemptot90 cpdeltaemp cpdeltaemptot cpdeltaemptot90 cphireemp cphireemptot cphireemptot90"
}
else {
local lister "cpdeltaempmean cpdeltaempmean90 deltaempmean deltaempmean90  deltaemp deltaemptot  deltaemptot90 cpdeltaemp cpdeltaemptot cpdeltaemptot90"
}
}

foreach var of varlist `lister' {

forval n=1/18 {
cap gen Z`n'D`var'= Z`n'`var'/`var'
cap gen Z`n'3D`var'= Z`n'3`var'/`var'
}


cap gen wiD`var'= wi`var'/`var'
cap gen wgD`var'= wg`var'/`var'
cap gen wnD`var'= wn`var'/`var'
cap gen viD`var'= vi`var'/`var'
cap gen vgD`var'= vg`var'/`var'
cap gen vnD`var'= vn`var'/`var'
cap gen mwiD`var'= mwi`var'/`var'
cap gen mwgD`var'= mwg`var'/`var'
cap gen mwnD`var'= mwn`var'/`var'
cap gen mviD`var'= mvi`var'/`var'
cap gen mvgD`var'= mvg`var'/`var'
cap gen mvnD`var'= mvn`var'/`var'
}







label define indimssx11 27 "Non Exports" 26 "Exports"  


gen industry2726 =industry if industry==27 | industry==26



foreach X of varlist industry?* {
label values `X' indimssx11
}


replace category=1 if category==.


label data "`intlist'"

save ${tempdir}graph_file_2000v3.dta, replace


copy "${tempdir}graph_file_2000v3.dta" "${dir}graph_file_2000v3.dta"
pause on
pause here 
**/



use ${dir2}graph_file_2000v3.dta, clear

append using ${dir2}graph_file_1990.dta


local intlist " in4p88complex1ay in5p85complex1ay in4p87complex1ay in4p88complex2ay in5p85complex2ay in4p87complex2ay in4p88complex3ay in5p85complex3ay in4p87complex3ay in4p88complex4ay in5p85complex4ay in4p87complex4ay"
*this is cx list (and cx3)




label define catlbl2 1 "<9" 2 "9-11" 3 ">11" 11 "D1/S1" 12 "D1/S2" 21 "D2/S1" 22 "D2/S2" 23 "D2/S3" 13 "D1/S3" 31 "D3/S1" 32 "D3/S2" 33 "D3/S3"
*label define catlbl2 1 "Primary" 2 "Secondary" 3 "High School+" 11 "D1/S1" 12 "D1/S2" 21 "D2/S1" 22 "D2/S2" 23 "D2/S3" 13 "D1/S3" 31 "D3/S1" 32 "D3/S2" 33 "D3/S3"
label values category catlbl2



/**

local counter=1
foreach thing in  `intlist' {
local Z`counter'="`thing'"
local Z`counter'3="`thing'"
local counter=`counter'+1
}





foreach indicator in cpdeltaemp deltaemp {  // podeltaemp  hireemp  cppodeltaemp  cphireemp  $listfirm  deltahfcemp deltahfaemp
foreach section in all  {
foreach yr in al {
foreach cut in 00 50 {
foreach migrant in  "e"  {

foreach indy in   2726  {  


foreach n in  1 2 3 4 5 6 7 8 9 10 11 12 { 

cap {
#delimit ;
twoway bar   Z`n'D`indicator'tot category   if  typer=="`section'" &  cutoff==`cut' & year==1989 & migrant=="`migrant'" & cenyear=="`yr'",
by(industry`indy', col(2) title("`indicator' `indy' `Z`n''") note(""))   yscale(range(0)) xlabel(none) xtitle("")
xtitle("Industry") ytitle("`Z`n''")
xsize(9) ysize(6.5) 
saving("${dirgraph}Z`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Z`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.pdf", replace
cap graph export "${dirgraph}Z`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.emf", replace
sleep 2000

}



cap {
#delimit ;
twoway bar   Z`n'D`indicator'tot90 category   if  typer=="`section'" &  cutoff==`cut' & year==1990 & migrant=="`migrant'" & cenyear=="`yr'",
by(industry`indy', col(2) title("`indicator'tot90 `indy' `Z`n''") note(""))   yscale(range(0)) xlabel(none) xtitle("")
xtitle("Industry") ytitle("`Z`n''")
xsize(9) ysize(6.5) 
saving("${dirgraph}Z`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Z`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.pdf", replace
cap graph export "${dirgraph}Z`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.emf", replace
sleep 2000
}


}

}

}
}
}
}
}
**/




/**

local counter=1
foreach thing in  `intlist' {
local Z`counter'="`thing'"
local Z`counter'3="`thing'"
local counter=`counter'+1
}





foreach indicator in cpdeltaemp {  // deltaemp podeltaemp  hireemp  cppodeltaemp  cphireemp  $listfirm  deltahfcemp deltahfaemp
foreach section in all  {
foreach yr in al {
foreach cut in 00 50 {
foreach migrant in ""  { // 

foreach indy in   2726   {  // 

foreach n of numlist  1/3 { //  

local nong1=`n'
local nong2=`n'+3
local nong3=`n'+6
local nong4=`n'+9


cap {
#delimit ;
graph bar   Z`nong1'D`indicator'tot  Z`nong2'D`indicator'tot Z`nong3'D`indicator'tot Z`nong4'D`indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1989 & migrant=="`migrant'" & cenyear=="`yr'" & category==1, ascategory  yvaroptions(relabel(1 "Secondary+" 2 "Secondary-" 3 "High Schl+" 4 "High Schl-") label(labsize(small)))
by(industry`indy', col(2) title("`indicator' `indy' `Z`n''") note(""))   yscale(range(0))  
 ytitle("`Z`n''")
xsize(9) ysize(6.5) 
saving("${dirgraph}DensityZ`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}DensityZ`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.pdf", replace
cap graph export "${dirgraph}DensityZ`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.emf", replace
sleep 2000

}



cap {
#delimit ;
graph bar   Z`nong1'D`indicator'tot  Z`nong2'D`indicator'tot Z`nong3'D`indicator'tot Z`nong4'D`indicator'tot   if  typer=="`section'" &  cutoff==`cut' & year==1990 & migrant=="`migrant'" & cenyear=="`yr'" & category==1, ascategory  yvaroptions(relabel(1 "Secondary+" 2 "Secondary-" 3 "High Schl+" 4 "High Schl-") label(labsize(small))) 
by(industry`indy', col(2) title("`indicator'tot90 `indy' `Z`n''") note(""))   yscale(range(0))  
 ytitle("`Z`n''")
xsize(9) ysize(6.5) 
saving("${dirgraph}DensityZ`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}DensityZ`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.pdf", replace
cap graph export "${dirgraph}DensityZ`n'`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.emf", replace
sleep 2000
}


}

}

}
}
}
}
}
**/





*these are the plain skill level graphs
****************************************

local counter=1
foreach thing in  `intlist' {
local Z`counter'="`thing'"
local Z`counter'3="`thing'"
local counter=`counter'+1
}

*these are the plain skill level graphs
****************************************

foreach indicator in  cpdeltaemp  { // 
noi levelsof typer
*foreach section in `r(levels)'  {
foreach section in 	 `"escz3c"' {  // 

foreach yr in 2s  9s  { // 
foreach cut in 50 00 {
foreach migrant in  e { //


cap sum  `indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if _rc==0 {
sum  `indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if `r(N)'!=0  & r(max)!=0 {

foreach indy in   2726  {  
noi di `" typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'""'

if "`yr'"=="9s" {
local fyr="1990"
}
if "`yr'"=="2s" {
local fyr="2000"
}




*cap {
#delimit ;
graph bar   prop`indicator'tot    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(category)
by(industry`indy',  col(2) title("Skill Requirements (`fyr')",size(medsmall) ) note("") graphregion(margin(vsmall)) plotregion(margin(none)))    outergap(*.25)  
ytitle("Proportion of Job Shocks")  
xsize(9) ysize(6.5) 
saving("${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.emf", replace
*sleep 2000
*}
 

 
 

*cap {
#delimit ;
graph bar   prop`indicator'tot90    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(category)
by(industry`indy', col(2) title("Skill Requirements (`fyr')",size(medsmall)) note("") graphregion(margin(vsmall)) plotregion(margin(none)))    outergap(*.25)  
ytitle("Proportion of Job Shocks")
xsize(9) ysize(6.5) 
saving("${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.gph", replace)
;
#delimit cr 
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.emf", replace
*sleep 2000
*}



}



}
}


}
}
}
}
}



**/




local counter=1
foreach thing in  `intlist' {
local Z`counter'="`thing'"
local Z`counter'3="`thing'"
local counter=`counter'+1
}

*these are the plain wage level graphs
****************************************

foreach indicator in  cpdeltaemp  { 
noi levelsof typer
*foreach section in `r(levels)'  {
foreach section in 	 `"vvesz3c"' {  

foreach yr in 2s  9s  {
foreach cut in 50 00 {
foreach migrant in  e { 


if "`yr'"=="9s" {
local fyr="1990"
}
if "`yr'"=="2s" {
local fyr="2000"
}


cap sum  `indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if _rc==0 {
sum  `indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if `r(N)'!=0  & r(max)!=0 {

foreach indy in   2726  {  
noi di `" typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'""'







*so these are wages relative to average wage, In 2000 these are only formal job shocks (but compared to all wages).

*cap {
#delimit ;
graph bar   `indicator'mean    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(category)
by(industry`indy', col(2) title("Wage Premia (`fyr')",size(medsmall)) note("") graphregion(margin(vsmall)) plotregion(margin(none)))    outergap(*.25)   
ytitle("Wage Premia Over Average Wage")  
xsize(9) ysize(6.5) 
saving("${dirgraph}EducationMean`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}EducationMean`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.pdf", replace
cap graph export "${dirgraph}EducationMean`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.emf", replace
*sleep 2000
*}


*cap {
#delimit ;
graph bar   `indicator'mean90    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(category)
by(industry`indy', col(2) title("Wage Premia (`fyr')",size(medsmall)) note("") graphregion(margin(vsmall)) plotregion(margin(none)))    outergap(*.25)   
ytitle("Wage Premia Over Average Wage") 
xsize(9) ysize(6.5) 
saving("${dirgraph}EducationMean`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}EducationMean`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.pdf", replace
cap graph export "${dirgraph}EducationMean`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_`indicator'.emf", replace
*sleep 2000
*}



}




}
}


}
}
}
}
}







replace category=. if category<10



gen density=floor(category/10)
gen skill=category-(10*floor(category/10))



label define skill 1 "Primary" 2 "Secondary"   3 "High School+"
label values skill skill

label define density 1 "D1" 2 "D2" 3 "D3"
label values density density





/**



local counter=1
foreach thing in  `intlist' {
local Z`counter'="`thing'"
local Z`counter'3="`thing'"
local counter=`counter'+1
}



foreach indicator in cpdeltaemp { // 
noi levelsof typer
*foreach section in `r(levels)'  {
foreach section in 	 `"escz3cw"'  { // 

foreach yr in 2s 9s  { //
foreach cut in 50 00 {
foreach migrant in e  { //


foreach n of numlist 2 { // 1/18 13 23 33 43 53
cap sum  Z`n'`indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if _rc==0 {
sum  Z`n'`indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if `r(N)'!=0  & r(max)!=0 {


foreach indy in 2726  {  //


noi di `"typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'""'
/*
cap {
#delimit ;
twoway bar   `indicator'tot category   if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'",
by(industry`indy', col(2) title("`indicator' `indy'") note(""))   
ylabel(0 "0" 100000 "100" 200000 "200" 300000 "300" 400000 "400") xlabel(1 "<33rd %" 2 "33-66th %" 3 ">66th %")
xtitle("Local Educational Percentile of Job") ytitle("Number of Jobs (thousands)")
xsize(9) ysize(6.5) 
saving("${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.pdf", replace
cap graph export "${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.emf", replace
}
*/

****explanation:
*1. Plot the proportion of the total job shocks going to the various categories.
*2. D1 D2 and D3 are the terciles of the density measure
*3. The skill brackets are the proportion of jobs in the skill categoires (from 1990)

*so expect to see exports have a large number of mid skill jobs going to places with high density (D3)


*cap {
#delimit ;
graph bar   propZ`n'`indicator'tot    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(density) over(skill)
by(industry`indy', col(2) title("`Z`n'' `indicator' `indy' `section'`migrant'`cut'_`yr'") note(""))  
xsize(9) ysize(6.5) 
saving("${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_Z`n'`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_Z`n'`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_Z`n'`indicator'.emf", replace
*sleep 2000
*}



*cap {
#delimit ;
graph bar   propZ`n'`indicator'tot90    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(density) over(skill)
by(industry`indy', col(2) title("`Z`n'' `indicator'tot90 `indy' `section'`migrant'`cut'_`yr'") note(""))  
xsize(9) ysize(6.5) 
saving("${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_Z`n'`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_Z`n'`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_Z`n'`indicator'.emf", replace
*sleep 2000
*}




*cap {
#delimit ;
graph bar   Z`n'`indicator'tot    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(density) over(skill)
by(industry`indy', col(2) title("`Z`n'' `indicator' `indy' `section'`migrant'`cut'_`yr'") note(""))  
xsize(9) ysize(6.5) 
saving("${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_Z`n'`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_Z`n'`indicator'.pdf", replace
cap graph export "${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_Z`n'`indicator'.emf", replace
*sleep 2000
*}



*cap {
#delimit ;
graph bar   Z`n'`indicator'tot90    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(density) over(skill)
by(industry`indy', col(2) title("`Z`n'' `indicator'tot90 `indy' `section'`migrant'`cut'_`yr'") note(""))  
xsize(9) ysize(6.5) 
saving("${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_Z`n'`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_Z`n'`indicator'.pdf", replace
cap graph export "${dirgraph}EducationNum`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_Z`n'`indicator'.emf", replace
*sleep 2000
*}

/*
cap {
#delimit ;
twoway bar   prop`indicator'tot category   if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'",
by(industry`indy', col(2) title("`indicator' `indy' `section'`migrant'`cut'") note(""))  
ylabel(0(0.1)0.4) xlabel(1 "<33rd %" 2 "33-66th %" 3 ">66th %")
xtitle("Local Educational Percentile of Job") ytitle("Proportion of Jobs")
xsize(9) ysize(6.5) 
saving("${dirgraph}Education`section'`migrant'_byInd`indy'_`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_`indicator'.emf", replace
}
*/


}

/*
cap {
twoway bar    `indicator'tot category   if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'" & industry==11 , fcolor(dknavy*1) lcolor(dknavy*1) ///
|| bar    `indicator'tot category   if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"  & industry==19 , fcolor(eltblue)  lcolor(dknavy*1)  ///
|| bar    `indicator'tot category   if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"  & industry==14 , fcolor(emidblue) lcolor(dknavy*1)  ///
ylabel(0 "0" 100000 "100" 200000 "200" 300000 "300" 400000 "400") xlabel(1 "<33rd Pctile Job" 2 "33-66th Pctile Job" 3 ">66th Pctile Job") ///
xtitle("Local Educational Percentile of Job") ytitle("Number of Net New Jobs (thousands)") xsize(9) ysize(5) ///
legend(col(3) lab(1 "All Manufacturing") lab(2 "Export Industries") lab(3 "Non Export Industries")) ///
saving("${dirgraph}EducationNum`section'`migrant'_byIndComboNoHerf.gph", replace)

cap graph export "${dirgraph}EducationNum`section'`migrant'_byIndComboNoHerf_`indicator'_yr`yr'_cut`cut'.pdf", replace
cap graph export "${dirgraph}EducationNum`section'`migrant'_byIndComboNoHerf_`indicator'_yr`yr'_cut`cut'.emf", replace
}
*/


}
}
}

}
}
}
}
}





**/












cap label drop skill
replace skill=4 if skill==3

*label define skill 1 "Primary" 2 "Secondary"  3 "Secondary" 4 "High School+"
label define skill 1 "<9" 2 "9-11"  3 "9-11" 4 ">11"

label values skill skill




expand 2 if skill==2, generate(newobs)
replace skill=3 if newobs==1

cap label drop density 
replace density=density+10 if skill>2
label define density 1 "d{sub:1}{sup:1}" 2 "d{sub:1}{sup:2}" 3 "d{sub:1}{sup:3}" 11 "d{sub:2}{sup:1}" 12 "d{sub:2}{sup:2}" 13 "d{sub:2}{sup:3}"

label values density density


foreach nong in 1 2 3 {
local nong1=`nong'
local nong2=`nong'+3
local nong3=`nong'+6
local nong4=`nong'+9

foreach beg in "prop" "" {
foreach ender in "90" "" {
foreach mid in "cp" "" {

gen `beg'ZC`nong1'`mid'deltaemptot`ender'=`beg'Z`nong1'`mid'deltaemptot`ender' if skill==1
replace `beg'ZC`nong1'`mid'deltaemptot`ender'=`beg'Z`nong2'`mid'deltaemptot`ender' if skill==2 
replace `beg'ZC`nong1'`mid'deltaemptot`ender'=`beg'Z`nong3'`mid'deltaemptot`ender' if skill==3 
replace `beg'ZC`nong1'`mid'deltaemptot`ender'=`beg'Z`nong4'`mid'deltaemptot`ender' if skill==4
}
}
}
}




local counter=1
foreach thing in  `intlist' {
local Z`counter'="`thing'"
local Z`counter'3="`thing'"
local counter=`counter'+1
}



foreach indicator in cpdeltaemp { //  
noi levelsof typer
*foreach section in `r(levels)'  {
foreach section in `"vesz3cw"' `"escz3cw"'  { //  `
foreach yr in 2s 9s   { //
foreach cut in  00 50 {
foreach migrant in e  { //

if "`yr'"=="9s" {
local fyr="1990"
}
if "`yr'"=="2s" {
local fyr="2000"
}


foreach n of numlist 2 { //
cap sum  ZC`n'`indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if _rc==0 {
sum  ZC`n'`indicator'tot if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'"
if `r(N)'!=0  & r(max)!=0 {


foreach indy in 2726  {  //

noi di `"typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'""'


****explanation:
*1. Plot the proportion of the total job shocks going to the various categories.
*2. D1 D2 and D3 are the terciles of the density measure
*3. The skill brackets are the proportion of jobs in the skill categoires (from 1990)

*so expect to see exports have a large number of mid skill jobs going to places with high density (D3)


*cap {
#delimit ;
graph bar   propZC`n'`indicator'tot    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(density, label(labsize(vsmall))) over(skill, label(labsize(small)))
by(industry`indy', col(2) title("Skill X Density at Dropout Margin (`fyr')",size(medsmall)) note("") graphregion(margin(vsmall)) plotregion(margin(none)))    outergap(*.25)   
ytitle("Proportion of Job Shocks")
xsize(9) ysize(6.5) nofill
saving("${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_ZC`n'`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_ZC`n'`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_ZC`n'`indicator'.emf", replace
*sleep 2000
*}


*cap {
#delimit ;
graph bar   propZC`n'`indicator'tot90    if  typer=="`section'" &  cutoff==`cut' & year==1999 & migrant=="`migrant'" & cenyear=="`yr'", over(density,label(labsize(vsmall))) over(skill,label(labsize(small)))
by(industry`indy', col(2) title("Skill X Density at Dropout Margin (`fyr')",size(medsmall)) note("") graphregion(margin(vsmall)) plotregion(margin(none)))    outergap(*.25)  
ytitle("Proportion of Job Shocks")
xsize(9) ysize(6.5) nofill
saving("${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_ZC`n'`indicator'.gph", replace)
;
#delimit cr
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_ZC`n'`indicator'.pdf", replace
cap graph export "${dirgraph}Education`section'_`migrant'`yr'_`cut'_byInd`indy'_p90_ZC`n'`indicator'.emf", replace
*sleep 2000
*}
**/






}



}
}
}

}
}
}
}
}





graph combine "${dirgraph}Educationescz3c_e9s_50_byInd2726_p90_cpdeltaemp.gph" "${dirgraph}Educationescz3c_e2s_50_byInd2726_p90_cpdeltaemp.gph" ///
"${dirgraph}EducationMeanvvesz3c_e9s_50_byInd2726_p90_cpdeltaemp.gph" "${dirgraph}EducationMeanvvesz3c_e2s_50_byInd2726_p90_cpdeltaemp.gph"  ///
"${dirgraph}Educationvesz3cw_e9s_50_byInd2726_p90_ZC2cpdeltaemp.gph" "${dirgraph}Educationvesz3cw_e2s_50_byInd2726_p90_ZC2cpdeltaemp.gph"  ///
, rows(3) iscale(0.5) imargin(0)  xsize(7.5) ysize(9.5) graphregion(margin(vsmall)) plotregion(margin(zero))

graph save "${dirgraph}EducationCombovesz3cw_e9se2s_50_byInd2726_p90_ZC2cpdeltaemp", replace
graph export "${dirgraph}EducationCombovesz3cw_e9se2s_50_byInd2726_p90_ZC2cpdeltaemp.pdf", replace
graph export "${dirgraph}EducationCombovesz3cw_e9se2s_50_byInd2726_p90_ZC2cpdeltaemp.emf", replace



graph combine "${dirgraph}Educationescz3c_e9s_00_byInd2726_cpdeltaemp.gph" "${dirgraph}Educationescz3c_e2s_00_byInd2726_cpdeltaemp.gph" ///
"${dirgraph}EducationMeanvvesz3c_e9s_00_byInd2726_cpdeltaemp.gph" "${dirgraph}EducationMeanvvesz3c_e2s_00_byInd2726_cpdeltaemp.gph"  ///
"${dirgraph}Educationvesz3cw_e9s_00_byInd2726_ZC2cpdeltaemp.gph" "${dirgraph}Educationvesz3cw_e2s_00_byInd2726_ZC2cpdeltaemp.gph" ///
, rows(3) iscale(0.5) imargin(0) xsize(7.5) ysize(9.5) graphregion(margin(vsmall)) plotregion(margin(zero))

graph save "${dirgraph}EducationCombovesz3cw_e9se2s_00_byInd2726_ZC2cpdeltaemp", replace
graph export "${dirgraph}EducationCombovesz3cw_e9se2s_00_byInd2726_ZC2cpdeltaemp.pdf", replace
graph export "${dirgraph}EducationCombovesz3cw_e9se2s_00_byInd2726_ZC2cpdeltaemp.emf", replace




graph combine "${dirgraph}Educationescz3c_e9s_50_byInd2726_p90_cpdeltaemp.gph" "${dirgraph}Educationescz3c_e2s_50_byInd2726_p90_cpdeltaemp.gph" ///
"${dirgraph}EducationMeanvvesz3c_e9s_50_byInd2726_p90_cpdeltaemp.gph" "${dirgraph}EducationMeanvvesz3c_e2s_50_byInd2726_p90_cpdeltaemp.gph"  ///
"${dirgraph}Educationescz3cw_e9s_50_byInd2726_p90_ZC2cpdeltaemp.gph" "${dirgraph}Educationescz3cw_e2s_50_byInd2726_p90_ZC2cpdeltaemp.gph"  ///
, rows(3) iscale(0.5) imargin(0)  xsize(7.5) ysize(9.5) graphregion(margin(vsmall)) plotregion(margin(zero))

graph save "${dirgraph}EducationComboescz3cw_e9se2s_50_byInd2726_p90_ZC2cpdeltaemp", replace
graph export "${dirgraph}EducationComboescz3cw_e9se2s_50_byInd2726_p90_ZC2cpdeltaemp.pdf", replace
graph export "${dirgraph}EducationComboescz3cw_e9se2s_50_byInd2726_p90_ZC2cpdeltaemp.emf", replace



graph combine "${dirgraph}Educationescz3c_e9s_00_byInd2726_cpdeltaemp.gph" "${dirgraph}Educationescz3c_e2s_00_byInd2726_cpdeltaemp.gph" ///
"${dirgraph}EducationMeanvvesz3c_e9s_00_byInd2726_cpdeltaemp.gph" "${dirgraph}EducationMeanvvesz3c_e2s_00_byInd2726_cpdeltaemp.gph"  ///
"${dirgraph}Educationescz3cw_e9s_00_byInd2726_ZC2cpdeltaemp.gph" "${dirgraph}Educationescz3cw_e2s_00_byInd2726_ZC2cpdeltaemp.gph" ///
, rows(3) iscale(0.5) imargin(0) xsize(7.5) ysize(9.5) graphregion(margin(vsmall)) plotregion(margin(zero))

graph save "${dirgraph}EducationComboescz3cw_e9se2s_00_byInd2726_ZC2cpdeltaemp", replace
graph export "${dirgraph}EducationComboescz3cw_e9se2s_00_byInd2726_ZC2cpdeltaemp.pdf", replace
graph export "${dirgraph}EducationComboescz3cw_e9se2s_00_byInd2726_ZC2cpdeltaemp.emf", replace






