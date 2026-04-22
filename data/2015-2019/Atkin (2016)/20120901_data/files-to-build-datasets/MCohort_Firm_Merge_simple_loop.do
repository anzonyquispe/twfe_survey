*this is a cleaned version which should work but cannot generate bartik etc. to get that stuff have to go back to old code
*also old interaction codes are better run elsewhere a shad more flecibility for multiple types of interaction


foreach spec in none { // herfa  none multiind feenstra4 expyrbyyr   sexinitialshort 
foreach yrexp in  1   { // 0 0 1 0 -------- 1 is single year exposure 
foreach yearlistx in  "5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23"  {   //  "15"  


if `yrexp'==1 & "`yearlistx'"=="15" {
local yearlist="16"
}
else {
local yearlist="`yearlistx'"
}


*this determines whether the herfindahl measures convereted to hcodes are merged in
*******************************
*local herf="finecen90" // herf2imss cen90 leave balnk for hcode
local herf="cen90" // herf2imss cen90 leave balnk for hcode
*local herf="herfacen90"
*local herf="hybrid" 



if "`spec'"=="none" & "`yearlistx'"=="15" {
*these are the firm variables
*******************************
local listfirme "deltaemp hireemp emp empx fireemp newemp maqemp maqeemp maqecemp devemp rfifemp" // "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "deltafem" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "deltamale" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","bartik0c")==1 & "`yearlistx'"=="15" {
*these are the firm variables
*******************************
local listfirme "emp empx fem male femx malex" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","bartik[1-9]c")==1  & "`yearlistx'"=="15" & regexm("`spec'","annual")!=1 {

*these are the firm variables
*******************************
local listfirme "emp empx fem male femx malex" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","bartik[1-9]c")==1  & "`yearlistx'"=="15" & regexm("`spec'","annual")==1 {

*these are the firm variables
*******************************
local listfirme "deltaemp emp empx" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","bartik")==1  & "`yearlistx'"=="15" & regexm("`spec'","annual")==1 {

*these are the firm variables
*******************************
local listfirme "deltaemp emp empx fem femx male malex" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","bartik[1-9]hf")==1  & "`yearlistx'"=="15" {

*these are the firm variables
*******************************
local listfirme "emp empx" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","edit16")==1  & "`yearlistx'"=="15"  {

*these are the firm variables
*******************************
local listfirme "deltaemp emp" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if (regexm("`spec'","altemp16")==1 )  & "`yearlistx'"=="15"  {  // | regexm("`spec'","hybrid")==1 

*these are the firm variables
*******************************
local listfirme "emp empx fem male femx malex" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","herfa")==1 & "`yearlistx'"=="15" {
*these are the firm variables
*******************************
local listfirme "deltahfaemp" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else if regexm("`spec'","herfb")==1 & "`yearlistx'"=="15" {
*these are the firm variables
*******************************
local listfirme "deltahfbemp" // fem male femx malex "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}
else {
*these are the firm variables
*******************************
local listfirme "deltaemp" // "maqemp nmaqemp maqeemp nmaqeemp maqecemp nmaqecemp" "deltaemp maqemp naqemp hireemp emp  maqemp hireemp fireemp newemp"
local listfirmf "" // "deltafem maqfem naqfem hirefem fem"
local listfirmm "" // "deltamale maqmale naqmale hiremale male"
*******************************
}



/**-----------------------------------------------
-----------------------------------------------**/
*this brings in the cohort data from MCohortAveragesOnly and merges it with the firm data created by MGettingFirmExposure type files.
*this is where teh 2 or 1 year average is created and the final industry caatgories.





*this determines which MFinalReg_IndCat`special'.do file is run. Final `file' has _allyear added if more than 2 years
*******************************

if "`herf'"=="cen90" {
local special="_genericskill_`spec'_`herf'" // _skillcharbytype
}
else if "`herf'"=="finecen90" {
local special="_genericskill_`spec'_`herf'" // _skillcharbytype
}
else if "`herf'"=="herfacen90" {
local special="_genericskill_`spec'_`herf'" // _skillcharbytype
}
else if "`herf'"=="herfbcen90" {
local special="_genericskill_`spec'_`herf'" // _skillcharbytype
}
else if "`herf'"=="hybrid" {
local special="_genericskill_`spec'_hybrid" // _skillcharbytype
}
else {
local special="_genericskill_`spec'_hcode" 
}
*******************************




*local herf="cen90" // herf2imss cen90
*******************************

*******************************
local years="`yearlist'"   
*******************************


local quantileson=0
*include quantiles or proportions in different school cats

local oneyearexposure=`yrexp'
*include single year exposure vars
local onlyoneyearexposure=`yrexp'
*include only a single year exposure vars (both should be 1 if want this)

local indlhs=0
*include industry left hand sides (e.g. prop in manuf)

local spillovers=0

*this includes additional LHS variables that are contained in different files

/**-----------------------------------------------
-----------------------------------------------**/




qui {


clear matrix
clear 
set mem 8000m
set matsize 10000
set maxvar 32767

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
global dircode="C:/Work/Mexico/Revision/New_code/"
global dirrev="C:/Work/Mexico/Revision/regout/"
global scratch "C:\Scratch\"
}

set more off


if "`herf'"=="cen90" {
global herf2="_cen90"
}
else if "`herf'"=="finecen90" {
global herf2="_finecen90"
}
else if "`herf'"=="hybrid" {
global herf3="_cen90"
global herf2="_finecen90"
}
else if "`herf'"=="herfacen90" {
global herf2="_herfacen90"
}
else if "`herf'"=="herfbcen90" {
global herf2="_herfbcen90"
}
else {
global herf2="_hcode"
}
*this is used inside MFinalreg to call the cen90 merge files.

local return2schlon=0
*include returns to school-now in mregs file instead

*old notes:

*have removed bartik and this file is very ad hoc and last minute. have crudly added the industry interactions in the FinalRegINd_skillchar file, and then had to manually enter t all the terms in the summation loop below...
*note, if I make the variabel names too long, whole file breaks... a bit of aproblme


*the interacti list is industry measures. these can be longer than i need as they are all capped


if length("`years'")>5 {
local allyear "_allyear"
}
else {
local allyear ""
}

*needs to be global as do file run in middle here
local  listfirm "`listfirme' `listfirmm' `listfirmf'"
global listfirm "`listfirme' `listfirmm' `listfirmf'"
foreach word in $listfirm {
local listfirmstar "`listfirmstar' `word'*"
}

*this creates keeplist like above but from list firm
local keepliste ""
foreach word in `listfirme' {
if "`spec'"=="none" & "`yearlistx'"=="15" {
local keepliste "`keepliste' `word'00* `word'50* `word'100*"   // `word'100*
}
else {
local keepliste "`keepliste' `word'00* `word'50*"   // `word'100*
}
}

foreach word in `listfirmm' {
local keeplistm "`keeplistm' `word'50*"
}

foreach word in `listfirmf' {
local keeplistf "`keeplistf' `word'50*"
}
local keeplist " `keepliste' `keeplistm' `keeplistf' "

local keeplist: subinstr local keeplist "empx00* " "", all
local keeplist: subinstr local keeplist "femx00* " "", all
local keeplist: subinstr local keeplist "malex00* " "", all
*this doesn't come in a 00 varaint



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
local keeplist_actualnames=subinstr("`keeplist_actualnames'","devemp","deltaempIdev",.)
local keeplist_actualnames=subinstr("`keeplist_actualnames'","rfifemp","deltaempIrfif",.)
local keeplist_actualnamesX ""
foreach word in `keeplist_actualnames' {
local keeplist_actualnamesX "`keeplist_actualnamesX' *`word'*"
}

 

local cenyear=2000
*this should be changed to 2006 if want the 2005 survey data
local yearend=1999
*if my firm data goes beyond this, change here to 2005

local edit2=substr("`edit'",11,1)

global zone="ZM"
global munwork="yes"

global exposure=""

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

if `return2schlon'==1 {
sort muncenso yobexp
merge  muncenso yobexp using "${workdir}cohortmeans_returns2school_mw${munwork}_`cenyear'.dta", keep(ecl* fcl* mcl*) _merge(_mergers)
}

if `quantileson'==1 {
sort muncenso yobexp
merge  muncenso yobexp using "${workdir}cohortmeans_quartiles_mw${munwork}_`cenyear'.dta", keep(ecl* fcl* mcl*) _merge(_mergers2)
}
else {
drop *cl*yrschlprop*
}

if `indlhs'==0 {
drop *cl*ind*
}

*this drops male and female cohort data if no male or female firm data
/*
if "`listfirmf'"=="" {
drop fcl*
}

if "`listfirmm'"=="" {
drop mcl*
}
*/

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



noi di "years: `years'"

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
replace year=. if year>`yearend' | year<1985


foreach sex in "male" "fem" "" {
replace `sex'munpop15_49_1995=(`sex'munpop15_49_1990+`sex'munpop15_49_2000)/2 if `sex'munpop15_49_1995==0
*want mid year population really... 2000 and 1990 are in feb, 2005 and 1995 are in october and november respectively
gen `sex'munpop15_49=`sex'munpop15_49_1990+(year+0.25-1990)*((`sex'munpop15_49_1995-`sex'munpop15_49_1990)/5.5) if year<=1995
replace `sex'munpop15_49=`sex'munpop15_49_1995+(year-0.25-1995)*((`sex'munpop15_49_2000-`sex'munpop15_49_1995)/4.5) if year>1995 & year<2000
replace `sex'munpop15_49=`sex'munpop15_49_2000+(year+0.25-2000)*((`sex'munpop15_49_2005-`sex'munpop15_49_2000)/5.5) if year>=2000 
replace `sex'munpop15_49=1 if `sex'munpop15_49<1
*this is needed to make sure cp measure have the same missing as mp measures
gen x`sex'munpop15_49_1990=`sex'munpop15_49_1990
replace x`sex'munpop15_49_1990=. if `sex'munpop15_49==.
}

rename munpop15_49 empmunpop15_49
rename xmunpop15_49_1990 xempmunpop15_49_1990




sort year muncenso
preserve
if "${munwork}"=="yes" {
cap use `keeplist_actualnamesX' year muncenso using  "${firmdir}newind`herf'_simpleMerge_skill.dta", clear

if "`herf'"=="hybrid" {
use `keeplist_actualnamesX' year muncenso using  "${firmdir}newindcen90_simpleMerge_skill.dta", clear
merge 1:1 year muncenso using  "${firmdir}newindfinecen90_simpleMerge_skill.dta", keepusing(`keeplist_actualnamesX') generate(merge999)
drop merge999
}



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

cap renvars delta*Idev* , sub(delta dev)
cap renvars dev*Idev* , sub(Idev ) 

cap renvars delta*Irfif* , sub(delta rfif)
cap renvars rfif*Irfif* , sub(Irfif )

sort year muncenso 
save "${scratch}newind`herf'_simpleMerge_skill_`special'temp.dta", replace
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

cap renvars delta*Idev* , sub(delta dev)
cap renvars dev*Idev* , sub(Idev ) 

cap renvars delta*Irfif* , sub(delta rfif)
cap renvars rfif*Irfif* , sub(Irfif )

sort year muncenso 
save "${scratch}newind`herf'_simple${zone}_skill_`special'temp.dta", replace
}




restore
* so here I rename deltahire hire and delat*Imaq maq* so that it fits as variable names get a bit long!




if "${munwork}"=="yes" {

merge year muncenso  using "${scratch}newind`herf'_simpleMerge_skill_`special'temp.dta" ,nokeep keep(`keeplist') _merge(_merge`yearvar')
erase "${scratch}newind`herf'_simpleMerge_skill_`special'temp.dta"
}
else {
merge year muncenso  using "${scratch}newind`herf'_simple${zone}_skill_`special'temp.dta" ,nokeep keep(`keeplist') _merge(_merge`yearvar')
erase "${scratch}newind`herf'_simple${zone}_skill_`special'temp.dta"
}

foreach var in   emp male fem firm hfa* hfc* {
cap mvencode  `var'*  if _merge`yearvar'==1 & (year>=1985 | year<=`yearend'), mv(0) override
}

foreach var in   delta hire fire new maq nmaq {
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





noi do "${dircode}MFinalReg_IndCat`special'.do"



*this is where the industry catagories are determined. It depends on the file coming in what I do with these. for the standard one I take my indsutry codes that run 1-16
*for skill I use the davidcode and have a much finer split,.,.
*maq and maqskill have these splits borken by maq and non maq
local listhcode "${listhcode}"


noi di "========================="
noi di "Industry Interactions: `listhcode'"
noi di "========================="
noi di "Firm Interactions: `listfirm'"
noi di "========================="





*this is code to get instrument of existing jobs interactd with national job growth. there is a second part below and i need to add nat to teh list of variables


noi di "only one: `onlyoneyearexposure'"




if "`spec'"=="none" & "`yearlistx'"=="15" {

***spillovers for some measures (only delta for now):
foreach sexy in emp male fem {
cap egen  Xss`sexy'munpop15_49=total(`sexy'munpop15_49), by(year state)
cap replace Xss`sexy'munpop15_49=Xss`sexy'munpop15_49-`sexy'munpop15_49
cap egen  Xsr`sexy'munpop15_49=total(`sexy'munpop15_49), by(year region1)
cap replace Xsr`sexy'munpop15_49=Xsr`sexy'munpop15_49-`sexy'munpop15_49


cap egen  Xss`sexy'munpop15_49_1990=total(x`sexy'munpop15_49_1990), by(year state)
cap replace Xss`sexy'munpop15_49_1990=Xss`sexy'munpop15_49_1990-x`sexy'munpop15_49_1990
cap egen  Xsr`sexy'munpop15_49_1990=total(x`sexy'munpop15_49_1990), by(year region1)
cap replace Xsr`sexy'munpop15_49_1990=Xsr`sexy'munpop15_49_1990-x`sexy'munpop15_49_1990




foreach typer in  delta*`sexy'* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
cap egen  ss`type'mp=total(`type'), by(year state)
cap replace ss`type'mp=(ss`type'mp-`type')/Xss`sexy'munpop15_49
cap egen  sr`type'mp=total(`type'), by(year region1)
cap replace sr`type'mp=(sr`type'mp-`type')/Xsr`sexy'munpop15_49

cap egen  ss`type'cp=total(`type'), by(year state)
cap replace ss`type'cp=(ss`type'cp-`type')/Xss`sexy'munpop15_49_1990
cap egen  sr`type'cp=total(`type'), by(year region1)
cap replace sr`type'cp=(sr`type'cp-`type')/Xsr`sexy'munpop15_49_1990

}
}
}
drop Xs*
}

cap renvars ss* sr*, sub(deltahf dh) 
renvars ss* sr*, sub(delta d) 
renvars ss* sr*, sub(cat c) 
}


cap renvars deltahf*, sub(deltahf dh) 
cap renpfix hf h


*this is where i make the  new sex stuff be specific



noi di "A"

*so now the male and female census/imss skill measures are divided by sex specicfic pops
foreach typer in deltaempm* deltaempdm* deltaemptdm*  deltaempndm* deltaempsdm* deltaemptndm* deltaemptsdm* deltaemphm* deltaempshm* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(malemunpop15_49)
  gen X`type'cp=`type'/(xmalemunpop15_49_1990)
  
 drop `type'
}
}
}

*ok so if it is demp* then i divide by emp pop not sex specific pop. use if this in MFinal...male.... and derivatives
foreach typer in demp*  {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(empmunpop15_49)
  gen X`type'cp=`type'/(xempmunpop15_49_1990)   

 drop `type'
}
}
}


foreach typer in deltaempf* deltaempdf* deltaemptdf*  deltaempndf* deltaempsdf* deltaemptndf* deltaemptsdf* deltaemphf* deltaempshf* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(femmunpop15_49)
  gen X`type'cp=`type'/(xfemmunpop15_49_1990)
 
 drop `type'
}
}
}






foreach typer in  delta*emp* dh*emp* fire*emp* new*emp* devemp* rfifemp* hire*emp* nmaq*emp* maq*emp* hcemp?0* haemp?0* a*emp* b*emp*  emp?0* emp*sc* emp*sz* emp*bl* empx?0* hcemp*cat* haemp*cat* emp*cat* empmn* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(empmunpop15_49)
  gen X`type'cp=`type'/(xempmunpop15_49_1990)   

 drop `type'
}
}
}






foreach typer in dmale* h*male* dh*male* delta*male* new*male* fire*male* hire*male* maq*male* nmaq*male* b*male* a*male* malex?0* male?0* male*cat* malemn* male*sc* male*bl* {
cap  d `typer'
if _rc==0 {

foreach type of var  `typer' {
 gen X`type'mp=`type'/(malemunpop15_49)
  gen X`type'cp=`type'/(xmalemunpop15_49_1990)
 drop `type'
}
}
}


foreach typer in dfem* h*fem* dh*fem* delta*fem*   new*fem* fire*fem*  hire*fem* maq*fem* nmaq*fem* femx?0* b*fem* a*fem* alofem* fem?0* fem*cat* femmn* fem*sc* fem*bl* {
cap  d `typer'
if _rc==0 {

foreach type of var  `typer' {
 gen X`type'mp=`type'/(femmunpop15_49)
  gen X`type'cp=`type'/(xfemmunpop15_49_1990) 
 drop `type'
}
}
}

noi di "B"

renpfix X




rename malemunpop15_49 q`yearvar'malemunpop 
rename femmunpop15_49 q`yearvar'femmunpop 
rename empmunpop15_49 q`yearvar'empmunpop 

rename xmalemunpop15_49_1990  q`yearvar'malemunpop1990 
rename xfemmunpop15_49_1990  q`yearvar'femmunpop1990 
rename xempmunpop15_49_1990  q`yearvar'empmunpop1990  


noi di "C"

gen post94=1 if year>1994 & year!=.
replace post94=0 if year<=1994

*cap renpfix deltamaleImaq deltamalemq
*cap renpfix deltafemImaq deltafemmq
*cap renpfix deltaempImaq deltaempmq

renvars _all, sub(delta q`yearvar'd)

*these names all get long, so this save 4 useful characters


foreach var in demp dmale dfem ss sr new aloemp alomale alofem amale aemp afem b5 b0 a5 a0 bslo bs aslo as bloemp blomale blofem bmale bemp bfem dh haemp hcemp close maq nmaq hire fire new emp malepa malema malemn fempa femfa femmn male0 malee feme malexe femxe femxf malexm malem femf male1 fem1 male5 malex5 femx5 fem0 fem5 firm peso dpeso dnfirm nfirm  dn50firm n50firm nat post rfif dev {
foreach prefix in ""  {
cap renpfix `prefix'`var' q`yearvar'`prefix'`var'
}
}

cap renpfix q`yearvar'malemun malemun
cap renpfix q`yearvar'femmun femmun

drop year
cap drop _merge`yearvar'


noi di "twoyearloop"

}
*end of twoyearset
*now have two years for each variable, q15 and q16... will add them


noi di "end of two year"
 

tsset  muncenso yobexp

gen year`yearset'=yobexp + `yearset'
gen yearcount`yearset'=year`yearset'-1986





foreach type of varlist  q`yearset'*mp q`yearset'*cp {
local add=regexr("`type'","^q`yearset'","q`yearplus1'")
local names=regexr("`type'","^q`yearset'","v`yearset'`yearplus1'")
local untouch=regexr("`type'","^q`yearset'","v`yearset'")
cap gen `names'=`type'+`add'
cap gen `untouch'=`type'
cap drop `type'
cap drop `add'
}






cap gen  v`yearset'`yearplus1'post94=q`yearset'post94+q`yearplus1'post94
cap gen  v`yearset'post94=q`yearset'post94


*this is where I add together two years of munpop data.
foreach catty in emp male fem { 
cap gen v`yearset'`yearplus1'`catty'munpop=(q`yearset'`catty'munpop + q`yearplus1'`catty'munpop)/2
cap gen v`yearset'`catty'munpop=q`yearset'`catty'munpop
cap drop q`yearset'`catty'munpop q`yearplus1'`catty'munpop

cap gen v`yearset'`yearplus1'`catty'munpop1990=(q`yearset'`catty'munpop1990 + q`yearplus1'`catty'munpop1990)/2
cap gen v`yearset'`catty'munpop1990=q`yearset'`catty'munpop1990
cap drop q`yearset'`catty'munpop1990 q`yearplus1'`catty'munpop1990
}



cap renpfix v`yearset'`yearplus1' z`yearset'`yearplus1'

if `oneyearexposure'==0 {
drop v`yearset'*
}
if `onlyoneyearexposure'==1 {
cap drop v`yearset'`yearplus1'*
}
cap renpfix v`yearset' z`yearset'




if "`spec'"=="none" & "`yearlistx'"=="15" {
forval num=0/999 {   // 0/99999
foreach sex in male fem emp {
foreach yearvar in `yearset'`yearplus1' `yearset' {
cap gen z`yearvar'exp`sex'00`num'mp=z`yearvar'hire`sex'00`num'mp-z`yearvar'new`sex'00`num'mp
cap gen z`yearvar'exp`sex'50`num'mp=z`yearvar'hire`sex'50`num'mp-z`yearvar'new`sex'50`num'mp
cap gen z`yearvar'deltax`sex'50`num'mp=z`yearvar'hire`sex'50`num'mp+z`yearvar'fire`sex'50`num'mp
cap gen z`yearvar'exp`sex'100`num'mp=z`yearvar'hire`sex'100`num'mp-z`yearvar'new`sex'100`num'mp
cap gen z`yearvar'deltax`sex'100`num'mp=z`yearvar'hire`sex'100`num'mp+z`yearvar'fire`sex'100`num'mp

cap gen z`yearvar'exp`sex'00`num'cp=z`yearvar'hire`sex'00`num'cp-z`yearvar'new`sex'00`num'cp
cap gen z`yearvar'exp`sex'50`num'cp=z`yearvar'hire`sex'50`num'cp-z`yearvar'new`sex'50`num'cp
cap gen z`yearvar'deltax`sex'50`num'cp=z`yearvar'hire`sex'50`num'cp+z`yearvar'fire`sex'50`num'cp
cap gen z`yearvar'exp`sex'100`num'cp=z`yearvar'hire`sex'100`num'cp-z`yearvar'new`sex'100`num'cp
cap gen z`yearvar'deltax`sex'100`num'cp=z`yearvar'hire`sex'100`num'cp+z`yearvar'fire`sex'100`num'cp

}
}
}
}
**/



cap drop q`yearset'* q`yearplus1'*
cap drop yearcount`yearset' year`yearset'
cap drop *nat*
cap drop *emp*i
cap drop *lmp* *imp* 
*get rid of all the q variables that i dont need or want



noi di "yearloop"

}
*end of year




noi di "do we get here 0"



tsset  muncenso yobexp

cap gen fpclwtyrschl=d.fclwtyrschl/l.fclwtyrschl
cap gen mpclwtyrschl=d.mclwtyrschl/l.mclwtyrschl
gen epclwtyrschl=d.eclwtyrschl/l.eclwtyrschl

if `onlyoneyearexposure'==1 {
cap drop z*post94
cap drop z*munpop*
}

tsset  muncenso age
sort muncenso yobexp
cap renpfix z q
*renvars q*, postsub(mp mp15_49)

renvars _all, sub(delta d)
*these names all get long, so this save 4 useful characters

noi di "do we get here 1"









****
*cheeky code that change maq variables into new industry codes (81 82 and 83)


/**

if regexm("`listfirme'","maqemp")==1 & `yrexp'==0 {
foreach X of varlist q????demp*13?? {
local nameto=regexr("`X'","13mp$","81mp")
local nameto=regexr("`nameto'","13cp$","81cp")
local namefrom=regexr("`X'","demp","maqemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}

if regexm("`listfirme'","maqeemp")==1 & `yrexp'==0 {
foreach X of varlist q????demp*13?? {
local nameto=regexr("`X'","13mp$","82mp")
local nameto=regexr("`nameto'","13cp$","82cp")
local namefrom=regexr("`X'","demp","maqeemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}

if regexm("`listfirme'","maqecemp")==1 & `yrexp'==0 {
foreach X of varlist q????demp*13?? {
local nameto=regexr("`X'","13mp$","83mp")
local nameto=regexr("`nameto'","13cp$","83cp")
local namefrom=regexr("`X'","demp","maqecemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}



if regexm("`listfirme'","maqemp")==1 & `yrexp'==1 {
foreach X of varlist q??demp*13?? {
local nameto=regexr("`X'","13mp$","81mp")
local nameto=regexr("`nameto'","13cp$","81cp")
local namefrom=regexr("`X'","demp","maqemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}


if regexm("`listfirme'","maqeemp")==1 & `yrexp'==1 {
foreach X of varlist q??demp*13?? {
local nameto=regexr("`X'","13mp$","82mp")
local nameto=regexr("`nameto'","13cp$","82cp")
local namefrom=regexr("`X'","demp","maqeemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}

if regexm("`listfirme'","maqecemp")==1 & `yrexp'==1 {
foreach X of varlist q??demp*13?? {
local nameto=regexr("`X'","13mp$","83mp")
local nameto=regexr("`nameto'","13cp$","83cp")
local namefrom=regexr("`X'","demp","maqecemp")
gen `nameto'=`namefrom'
drop `namefrom'
}
}
**/




*now this is pdemp and ndemp magic

if "`spec'"=="none" {

if length("`years'")<=5 {
*not for all year specs

*not nmaq wont work since already have maq and nmaq
foreach sex in emp male fem  {
foreach midgit in d { // maq nmaq  maqe nmaqe maqec nmaqec
foreach typer in q*`midgit'`sex'* { 
cap  d `typer'
if _rc==0 {
foreach X of varlist `typer' {
*so takes anything beginning with q and containing delta`emp' (including spillovers)
local stripa=regexm("`X'","^q.*`sex'")
local stripa=regexs(0)
*this is the q1516demp bit
local stripb=regexm("`X'","([0-9]*mp$)|([0-9]*amp$)|([0-9]*cp$)|([0-9]*acp$)")
local stripb=regexs(0)
*this is the 5019mp bit

noi di "gen p`X'=`X'*(`stripa'`stripb'>=0)"

gen po`X'=`X'*(`stripa'`stripb'>=0)
gen ne`X'=`X'*(`stripa'`stripb'<0)
*so this takes out the interaction bit

renvars poq*, sub(`midgit'`sex' po`midgit'`sex') 
renvars neq*, sub(`midgit'`sex' ne`midgit'`sex') 
renvars neq* poq*, predrop(2) 
}
}
}
}
}

}
}






if `onlyoneyearexposure'==1 {
local onlyone "_1yrexp"
}
else {
local onlyone ""
}


drop *mp




if "`herf'"=="herfacen90" {
merge 1:1 muncenso yobexp using "${workdir}reg2year_mwyes_2000_july11_genericskill_none_cen90_1yrexp.dta", keepusing(q16demp????cp) generate(_merge99)
}
if "`herf'"=="herfbcen90" {
merge 1:1 muncenso yobexp using "${workdir}reg2year_mwyes_2000_july11_genericskill_none_cen90_1yrexp.dta", keepusing(q16demp????cp) generate(_merge99)
}


noi di "compressing"
compress
noi save "${workdir}reg2year_mw${munwork}_`cenyear'_july11`special'`allyear'`onlyone'.dta", replace



noi di "========================="
noi di "Industry Interactions: `listhcode'"
noi di "========================="
noi di "Firm Interactions: `listfirm'"
noi di "========================="

}
*end of quiet


}
}




}


