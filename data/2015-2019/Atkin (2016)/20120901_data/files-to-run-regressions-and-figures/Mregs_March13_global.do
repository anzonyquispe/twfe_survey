qui {





clear 
cap clear matrix
cap clear mata
set mem 1000m
set matsize 10000
set maxvar 32000
set  more off
pause on

if "`c(os)'"=="Unix" {
global scratch="/home/fac/da334/Data/Mexico/Stata10/"
global dirnet="/home/fac/da334/Work/Mexico/regout/"
}

if "`c(os)'"=="Windows" {
global dirnet="C:/Work/Mexico/Revision/regout/"
if "${scratch2}"=="C:/Data/Mexico_rarelyused/Stata10/" {
global scratch="C:/Data/Mexico/Stata10/"
global scratch2="C:/Data/Mexico_rarelyused/Stata10/"
}
else{
global scratch="C:/Data/Mexico/Stata10/"
global scratch2="C:/Data/Mexico/Stata10/"
}
global dirtemp="C:/Scratch/"
global dir="C:/Work/Mexico/"
global graphdir="C:/Work/Mexico/Revision/Graphs/"
global dircode="C:/Work/Mexico/Revision/New_code/"
global dirrev="C:/Work/Mexico/Revision/regout/"
}

if "${twostagelinear}"=="1" |  "${sexmix}"=="1" |  "${ivonly}"=="1" {
set mem 4000m
}

local counter=0

noi local alwaysif=""

noi local yeartrend="yobexp"

*these should be changed if want pure ZM's or data needs run beyond dec1999
local cenyear=2000
global munwork="yes"

if  `cenyear'==2000 {
local yearend=1999
}
else if  `cenyear'==2006 {
local yearend=2000
}

/**=============================================================**/
*Sexes, Industries, Ages
/**=============================================================**/

sleep 1000

/**SEXES**/
local sexinteract=${sexinteract}

if "`sexinteract'"=="1"  {
set mem 4000m
}

foreach sexx in  $sexx {


foreach edit in "" {
local edit2=substr("`edit'",11,1)
global gender= "`sexx'"
global gender3=substr("${gender}",1,1)
global gender4=substr("${gender}",1,1)
local lgender= "`sexx'"
local lgender3=substr("${gender}",1,1)
local lgender4=substr("${gender}",1,1)
local lgender5=subinstr("${gender}","female","fem",.)
if "${gender}"=="emp" {
global gender4=""
local lgender4=""
}



*this code is just to get the allages regs to work
local allages=${allages}
if `allages'==1 {
local file "${file}" 
local regname=`"${regname}"'
cap erase "${dirtemp}elrd_`regname'.xml"
cap erase "${dirtemp}elrd_`regname'.txt"
cap postclose dog
postfile dog str50 rhs str50 shocker str50 lhs str50 industry  str50 catch age agefirst str20 type value str244 iffy  using "${dirtemp}AllAges_`regname'.dta", replace every(1)
}



*to make sure the right mpop is being called
if "${mpop}"=="" {
global mpop "mp"
}

if regexm("${file}","skill")==1 | "`file'"=="_3digit"  | regexm("${file}","eric_16")==1  | regexm("${file}","eric_1516")==1 | regexm("${file}","exporter_new")==1 {
local mpopend="${mpop}"
}
else {
local mpopend="${mpop}op"
}

local mpoppure="${mpop}"




/**Industry List**/
*local indlist="20"
foreach indlist in   $indlist {



/**AGES OF EXPOSURES**/
foreach aget in  $aget  {
if length("`aget'")==4 { 
local ageplus1=(real(substr("`aget'",1,2))+1)*100+(real(substr("`aget'",-2,2))+1)
local ageplus2=(real(substr("`aget'",1,2))+2)*100+(real(substr("`aget'",-2,2))+2)
}

/**=============================================================**/
*File Names
/**=============================================================**/

/**File Used**/
local file "${file}" 
local combo "`cenyear'"
*local combo="combo"  if need other census year data included in averages. Otherwise local combo="`cenyear'"
*this should be _allyears if need lots of years
local regdata "${scratch2}reg2year_mw${munwork}_`combo'_july11`file'.dta"
local linear=`"${linear}"'

/**Regression File Name**/


if `allages'!=1  {
local regname=`"${regname}"'
cap erase "${dirtemp}elrd_`regname'.xml"
cap erase "${dirtemp}elrd_`regname'.txt"
}


noi di "**************************************************"
noi di "File being generated: `regname'"
noi di "**************************************************"



local counter=0

/**=============================================================**/
*Variables
/**=============================================================**/

/**LHS Variables**/
foreach reglist in    $reglist   {   

/**RHS Variables**/
foreach shocker in $shocker  { 
foreach interactlist in $interactlist  {  // `lgender'00 For this to work need inston=0 and needs only one age of exposure or else fails (or may fail, not sure).
*these variables are seperately interacted with each component of shocker and pull the indlist from above: e.g. `lgender'00, migprop (prop migrants in ind), migpropform (prop migrants in formal sector in ind), migpropall (proportion of migrants in all sectors), migpropmanuf (prop mig in manuf 20)

if "$interactlist"!="" {

cap discard
cap clear  mata 

}

foreach controlinteract in $controlinteract {

/**=============================================================**/
*Specification Options
/**=============================================================**/

/**RHS Remainder**/
local remainder=${remainder}
local sexremainder=${sexremainder}
*this takes the value 1 if the remainder term is uses sex specific jobs or all jobs
foreach remainderon in $remainderon {
*this includes a remainder of jobs term. these can be 50 or 00 jobs


/**LAGS of LHS**/
if "l1`reglist'"=="l1`lgender3'clyrschl" {
local lagtastic `" "" "l1`reglist' l2`reglist' l3`reglist' l4`reglist'" "'   
}
else {
local lagtastic `" ""   "l1`reglist' l2`reglist' l3`reglist' l4`reglist'"   "l1eclyrschl l2eclyrschl l3eclyrschl l4eclyrschl" "'
}
foreach lags in  `lagtastic'   { 

/**EXPOSURE LIST OPTIONS**/
*switch out code if:
*1) 2 year exposure ages which are less than age 10 (e.g. 78 or 910)
if length("`aget'")==3 { 
local agefirst=real(substr("`aget'",1,1))
local agesecond=real(substr("`aget'",-2,2))
}
else if length("`aget'")==2 & `aget'>30 { 
local agefirst=real(substr("`aget'",1,1))
local agesecond=real(substr("`aget'",-1,1))
}
else { 
local agefirst=real(substr("`aget'",1,2))
local agesecond=real(substr("`aget'",-2,2))
}

local yobmin1991=1992-`agefirst'
local yobmin1990=1991-`agefirst'
local yobmin1989=1990-`agefirst'
local yobmin1988=1989-`agefirst'
local yobmin1987=1988-`agefirst'
local yobmin1986=1987-`agefirst'
local yobmin1985=1986-`agefirst'

local yobmaxm2=`yearend' - `agefirst'-3
*this also lops off the last two year when progressa came into being. yobexp>yobmaxm2 were exposed

/**Regression Sample**/
local iflist `" ${iflist} "'   
local mexicocity=${mexicocity}
*if this is 1, then mexico city is included in sample and placed in morelos. Otherwise it is no loaded
local weightsquare=${weightsquare}
*if weightsquare=1, then i use the square of muni weights so that it is reprasentative and ocntrols for measurement error
local weightyrschl=${weightyrschl}
*if this takes the value 1 then `gender3'clwtyrschl used as weights instead of LHS variable. Useful for dropout as lhs. 

local controlinsert1 "${controlinsert1}"
local controlinsert2 "${controlinsert2}"
local controlinsert3 "${controlinsert3}"
local controlinsert4 "${controlinsert4}"
local laganything "${laganything}"
local randomuse "${randomuse}"
local interactuse "${interactuse}"
*if i want to stick some lag or intial value or mean into the controls, stick it in both laganything and then controlinsert 

local residualreg="${residualreg}"
*if this is 1-run residual graph but need only one rhs...

/**Estimates Include Municiplaity Linear Time Trend or No State Fixed Effects**/
local lineartrendon=${lineartrendon}
*this tunrs on the linear municipality time trend
local nostatefe=${nostatefe}
*this tunrs on the "no state-time fixed effects" specification
local lineartrendstatefeon=${lineartrendstatefeon}
*this removes the state-time fixed effects everywhere and replaces them with time fixed effects and runs linear trend
local firstdif=${firstdif}
*this turns on Arrelano Bond with first dif. For this to work need inston=0.
local noyearfe=${noyearfe}
*this tunrs on the "no state-time fixed effects" specification with not even any year fixed effects
local catchupon=${catchupon}
local catchlag="${catchlag}"
local catchlist="${catchlist}"
*this turns on catchup specifications. With lags this includes the l.`catchlist'*yobexp*i.state. Without lages this includes l.`catchlist'(avreage over `catchlag' years before sample)*yobexp*i.state. Defaults to lag of two for dependent variable.
local laglevelinteract="${laglevelinteract}"
*if this is 1 then all the interact list are lagged by two periods. useful for employment levels
local finalrfspec=${finalrfspec}
*this only runs the final reduced form specs for every regression (currently fe catchup)
local nofeatall="${nofeatall}"
*if this is one, then i run 5 alterante specifications sequentially dropping fixed effects. Only works with finalrfspec==_linear and no interactions and statefe on

/**Estimates Include IV Estimate, and Instrument Choice**/
macro drop _ins*
local inston=${inston} 
*this turns on IV regression (=1)
local ivonly=${ivonly}
*this means that only the IV regs are reported if=1 (not OLS and RF as well)
local bartikon=${bartikon}
*this turns on bartik. 0=off, 1=on, 2=both bartik and large expansion instruments, 3=bartik for levels, delta 50 for changes, 4=Export style bartik
local bartype="${bartype}"
*type of bartik instrument  LI0 is  initial state level growth, LI0R is with your mun removed
local exptype="${exptype}"

/**Additional Controls**/
local control = "${control}"
local control2 = "${control2}"
*control 2 is not loaded from data so can stick in complicated interactions of variables loaded elsewhere

/**=============================================================**/
/**=============================================================**/






*would have to change instruments here
tokenize `shocker'
forval n=1/100 {
cap local insexp=subinstr("``n''","00","50",.)
cap local insbar=subinstr("``n''","`lgender'00","`bartype'`lgender'00",.) 
local instrument0 "`instrument0' `insexp'" 
local instrument1 "`instrument1' `insbar'"
local instrument2 "`instrument2' `insexp' `insbar'"
}

// may11
local instrument3: subinstr local shocker "delta`lgender'00" "delta`lgender'50", all
local instrument3: subinstr local instrument3 "`lgender'00" "`bartype'`lgender'00", all
// june11
local instrument4: subinstr local shocker "`lgender'" "`lgender'`exptype'", all
local instrument "`instrument`bartikon''"

if `inston'==1 {
noi di "Instruments for `shocker': `instrument'"
}



local regweight=regexr("`reglist'","cl","clwt")
local regweight=regexr("`regweight'","clwtva","clwt")
local regweight=regexr("`regweight'","clwtcv","clwt")
local regweight=regexr("`regweight'","clwtsd","clwt")
local regweightinc="`regweight'"
*these are weights are the cohort size of whatever lhs is, the second two lines mean that when variance of coefficient of variations are used, the normal wt is used, these are fixed weights of size of cohort with educ data

if `weightyrschl'==1 {
local regweight="`lgender3'clwtyrschl"
local regweightinc=""
}




/**Additional Variables to be loaded**/
local contvar "munmatch rhhincomepc2000 region1 region2 ruralper progper progper10 `control'  *cl*yrschl"
*these are control variables



cap drop l?`lhs' mean?l`lhs'
macro drop _rhs*

local shock1=word("`shocker'",1)
local shock2=substr("`shocker'",1,3)




local agebands="`aget'"

*catchlag and catchlist default to 2 and lhs
if "`catchlag'"=="" {
local catchlag="2"
}
if "`catchlist'"=="" {
local catchlist="`reglist'"
}

local catchweight=regexr("`catchlist'","cl","clwt")
local catchweight=regexr("`catchweight'","clwtva","clwt")
local catchweight=regexr("`catchweight'","clwtcv","clwt")
local catchweight=regexr("`catchweight'","clwtsd","clwt")

if `weightyrschl'==1 {
local catchweight="`lgender3'clwtyrschl"
}

*=============================================================











local prew=""
local changes="delta"
*this should be delta if doing changes, and empty if doing levels


foreach ages in `agebands' {
foreach shock in `shocker' {
foreach indust in `indlist'  {
local rhskeep "`rhskeep' q`ages'`prew'`shock'`indust'`mpopend'"
}
}
}


local controlinteractkeep ""
local controlschool=0
local controlinteractxxx ""
local controlinteractxxx: subinstr local controlinteract "c." " ", all
local controlinteractxxx: subinstr local controlinteractxxx "#" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "i." " ", all
local controlinteractxxx: subinstr local controlinteractxxx "ib3." " ", all

*these are for weighted/unweighted medians opf ioteraction term
local controlinteractxxx: subinstr local controlinteractxxx "uw2c1" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "uw2c2" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "uw3c1" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "uw3c2" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "uw3c3" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "w2c1" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "w2c2" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "w3c1" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "w3c2" " ", all
local controlinteractxxx: subinstr local controlinteractxxx "w3c3" " ", all
tokenize `controlinteractxxx'
forval n=1/100 {
if regexm("``n''","migprop")!=1 & regexm("``n''","school")!=1 & regexm("``n''","ind")!=1 & regexm("``n''","female")!=1 & "``n''"!="" & regexm("``n''","othe")!=1 & regexm("``n''","atgrade")!=1 ///
& regexm("``n''","schatt")!=1 & regexm("``n''","prop")!=1  & regexm("``n''","empdw")!=1 & regexm("``n''","empdv")!=1 & regexm("``n''","yrschldrop")!=1 ///
& regexm("``n''","complex")!=1 & regexm("``n''","empd2w")!=1 & regexm("``n''","empd2v")!=1 & regexm("``n''","empd3w")!=1 & regexm("``n''","empd3v")!=1 ///
& regexm("``n''","empd4w")!=1 & regexm("``n''","empd4v")!=1 & regexm("``n''","empd5w")!=1 & regexm("``n''","empd5v")!=1 & regexm("``n''","poq")!=1 ///
& regexm("``n''","inq")!=1 & regexm("``n''","diq")!=1 & regexm("``n''","^msc")!=1 & regexm("``n''","^mexp")!=1  & regexm("``n''","^mdrho")!=1 /// 
& regexm("``n''","tot")!=1  & regexm("``n''","^dim")!=1   & regexm("``n''","^dam")!=1    & regexm("``n''","^dis")!=1    & regexm("``n''","^das")!=1 {


local controlinteractkeep "``n'' `controlinteractkeep'"
}
if regexm("``n''","school")==1 {
local controlschool=1
}
}
*this is in a indicator for whether the 5 an 2 year initial schooling averages need to be created


*for wages, the controllist variable has no emp because it is transfrodmed.
local controlinteractkeep: subinstr local controlinteractkeep "dempmeanw" "dempw", all
local controlinteractkeep: subinstr local controlinteractkeep "dempmeanv" "dempv", all

local controlinteractkeep: subinstr local controlinteractkeep "dempmeantw" "dempw", all
local controlinteractkeep: subinstr local controlinteractkeep "dempmeantv" "dempv", all

local controlinteractkeep: subinstr local controlinteractkeep "dempdtw" "dempw", all
local controlinteractkeep: subinstr local controlinteractkeep "dempdtv" "dempv", all

local controlinteractkeep: subinstr local controlinteractkeep "dwe" "we", all
local controlinteractkeep: subinstr local controlinteractkeep "dwi" "wi", all
local controlinteractkeep: subinstr local controlinteractkeep "dwn" "wn", all
local controlinteractkeep: subinstr local controlinteractkeep "dwm" "wm", all
local controlinteractkeep: subinstr local controlinteractkeep "dwj" "wj", all
local controlinteractkeep: subinstr local controlinteractkeep "dwg" "wg", all
local controlinteractkeep: subinstr local controlinteractkeep "dwk" "wk", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanwi" "dempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanwn" "dempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanwm" "dempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanwj" "dempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanwg" "dempwg", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanwe" "dempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwe" "we", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwi" "wi", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwn" "wn", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwm" "wm", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwj" "wj", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwg" "wg", all
local controlinteractkeep: subinstr local controlinteractkeep "dmwk" "wk", all

*for wages, the controllist variable has no emp because it is transfrodmed.
local controlinteractkeep: subinstr local controlinteractkeep "dve" "ve", all
local controlinteractkeep: subinstr local controlinteractkeep "dvi" "vi", all
local controlinteractkeep: subinstr local controlinteractkeep "dvn" "vn", all
local controlinteractkeep: subinstr local controlinteractkeep "dvm" "vm", all
local controlinteractkeep: subinstr local controlinteractkeep "dvj" "vj", all
local controlinteractkeep: subinstr local controlinteractkeep "dvg" "vg", all
local controlinteractkeep: subinstr local controlinteractkeep "dvk" "vk", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanvi" "dempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanvn" "dempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanvm" "dempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanvj" "dempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanvg" "dempvg", all
local controlinteractkeep: subinstr local controlinteractkeep "dmeanve" "dempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dmve" "ve", all
local controlinteractkeep: subinstr local controlinteractkeep "dmvi" "vi", all
local controlinteractkeep: subinstr local controlinteractkeep "dmvn" "vn", all
local controlinteractkeep: subinstr local controlinteractkeep "dmvm" "vm", all
local controlinteractkeep: subinstr local controlinteractkeep "dmvj" "vj", all
local controlinteractkeep: subinstr local controlinteractkeep "dmvg" "vg", all
local controlinteractkeep: subinstr local controlinteractkeep "dmvk" "vk", all

*for wages, the controllist variable has no emp because it is transfrodmed.
local controlinteractkeep: subinstr local controlinteractkeep "dhcwe" "dhcempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcwi" "dhcempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcwn" "dhcempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcwm" "dhcempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcwj" "dhcempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcwg" "dhcempwg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanwi" "dhcempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanwn" "dhcempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanwm" "dhcempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanwj" "dhcempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanwg" "dhcempwg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanwe" "dhcempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmwe" "dhcempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmwi" "dhcempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmwn" "dhcempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmwm" "dhcempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmwj" "dhcempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmwg" "dhcempwg", all

*for wages, the controllist variable has no emp because it is transfrodmed.
local controlinteractkeep: subinstr local controlinteractkeep "dhcve" "dhcempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcvi" "dhcempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcvn" "dhcempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcvm" "dhcempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcvj" "dhcempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcvg" "dhcempvg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanvi" "dhcempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanvn" "dhcempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanvm" "dhcempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanvj" "dhcempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanvg" "dhcempvg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmeanve" "dhcempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmve" "dhcempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmvi" "dhcempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmvn" "dhcempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmvm" "dhcempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmvj" "dhcempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhcmvg" "dhcempvg", all

*for wages, the controllist variable has no emp because it is transfrodmed.
local controlinteractkeep: subinstr local controlinteractkeep "dhawe" "dhaempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dhawi" "dhaempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhawn" "dhaempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhawm" "dhaempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhawj" "dhaempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhawg" "dhaempwg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanwi" "dhaempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanwn" "dhaempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanwm" "dhaempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanwj" "dhaempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanwg" "dhaempwg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanwe" "dhaempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamwe" "dhaempwe", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamwi" "dhaempwi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamwn" "dhaempwn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamwm" "dhaempwm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamwj" "dhaempwj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamwg" "dhaempwg", all

*for wages, the controllist variable has no emp because it is transfrodmed.
local controlinteractkeep: subinstr local controlinteractkeep "dhave" "dhaempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dhavi" "dhaempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhavn" "dhaempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhavm" "dhaempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhavj" "dhaempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhavg" "dhaempvg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanvi" "dhaempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanvn" "dhaempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanvm" "dhaempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanvj" "dhaempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanvg" "dhaempvg", all
local controlinteractkeep: subinstr local controlinteractkeep "dhameanve" "dhaempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamve" "dhaempve", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamvi" "dhaempvi", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamvn" "dhaempvn", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamvm" "dhaempvm", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamvj" "dhaempvj", all
local controlinteractkeep: subinstr local controlinteractkeep "dhamvg" "dhaempvg", all

if "${sexmix}"=="1" {
local controlinteractkeep ""
}

if "`interactlist'"!="" {
foreach X in "" "1" "2" "3" "4" "5" "6"  {
local interactrun`X' ""
local interactkeep`X' ""
}

foreach interactthing in `interactlist' {
	if  regexm("`interactthing'","stat")==1  {
		foreach interact in `interactthing' {
		foreach indust in `indlist'  {
		local interactrun1 "`interactrun1' `interact'`indust'"
		}
		}
	}
	else if regexm("`interactthing'","school")==1  | regexm("`interactthing'","migprop")==1 | regexm("`interactthing'","atgrade")==1 | regexm("`interactthing'","schatt")==1 | regexm("`interactthing'","yobexp")==1 | regexm("`interactthing'","year")==1 | regexm("`interactthing'","female")==1 | regexm("`interactthing'","region")==1 | regexm("`interactthing'","prop")==1 | regexm("`interactthing'","period")==1 | regexm("`interactthing'","yrschldrop")==1  {
			foreach interact in `interactthing' {
			*foreach indust in `indlist'  {
			local interactrun2 "`interactrun2' `interact'"
			*}
			}
	}
	else if regexm("`interactthing'","clyrschl")==1 & regexm("`interactthing'","clyrschldrop")!=1 {
					foreach interact in `interactthing' {
					*foreach indust in `indlist'  {
					local interactrun6 "`interactrun6' `interact'"
					local interactkeep6 "`interactkeep6' `interact'"
					*}
					}
	}
	else if regexm("`interactthing'","`remainder'")==1 | regexm("`interactthing'","020")==1 | regexm("`interactthing'","099")==1  | regexm("`interactthing'","013")==1  | regexm("`interactthing'","011")==1 {
		foreach ages in `agebands' {
		foreach interact in `interactthing' {
		foreach indust in `indlist'  {
		local interactkeep3 "`interactkeep3' q`ages'`prew'`interact'`mpopend'"
		local interactrun3 "`interactrun3' q`ages'`prew'`interact'`mpopend'"
		}
		}
		}
	}
	else if regexm("`interactthing'","ind")==1  {
			foreach interact in `interactthing' {
			foreach indust in `indlist'  {
			local interactrun4 "`interactrun4' `interact'`indust'"
			}
			}
	}
	else{
		foreach ages in `agebands' {
		foreach interact in `interactthing' {
		foreach indust in `indlist'  {
		local interactkeep5 "`interactkeep5' q`ages'`prew'`interact'`indust'`mpopend'"
		local interactrun5 "`interactrun5' q`ages'`prew'`interact'`indust'`mpopend'"
		}
		}
		}
	}
}


	
	local interactrun "`interactrun1' `interactrun2' `interactrun3' `interactrun4' `interactrun5' `interactrun6'"
	local interactkeep "`interactkeep1' `interactkeep2' `interactkeep3' `interactkeep4' `interactkeep5' `interactkeep6'"



}

if `remainderon'==1 | `remainderon'==2 {
foreach indust in `remainder'  {
foreach ages in `agebands' {
foreach shock in `shocker' {
if regexm("`shock'","new")!=1 & regexm("`shock'","fire")!=1 & regexm("`shock'","hire")!=1  & regexm("`shock'","expan")!=1  & regexm("`shock'","`lgender'x")!=1 {
local shock`remainder'00=subinstr("`shock'","50","00",.)
local shock`remainder'50=subinstr("`shock'","00","50",.)
local rhs`remainder' "`rhs`remainder'' q`ages'`prew'`shock`remainder'00'`indust'`mpopend' q`ages'`prew'`shock`remainder'50'`indust'`mpopend'"
local rhs`remainder'no50 "`rhs`remainder'no50' q`ages'`prew'`shock`remainder'00'`indust'`mpopend'"
}
else if regexm("`shock'","new")==1   {
local shock`remainder'00=subinstr("`shock'","50","00",.)
local shock`remainder'00=subinstr("`shock`remainder'00'","new","",.)
local shock`remainder'50=subinstr("`shock'","00","50",.)
local shock`remainder'50=subinstr("`shock`remainder'50'","new","",.)
local rhs`remainder' "`rhs`remainder'' q`ages'`prew'`shock`remainder'00'`indust'`mpopend' q`ages'`prew'`shock`remainder'50'`indust'`mpopend'"
local rhs`remainder'no50 "`rhs`remainder'no50' q`ages'`prew'`shock`remainder'00'`indust'`mpopend'"
}
else if regexm("`shock'","hire")==1 {
local shock`remainder'00=subinstr("`shock'","50","00",.)
local shock`remainder'00=subinstr("`shock`remainder'00'","hire","",.)
local shock`remainder'50=subinstr("`shock'","00","50",.)
local shock`remainder'50=subinstr("`shock`remainder'50'","hire","",.)
local rhs`remainder' "`rhs`remainder'' q`ages'`prew'`shock`remainder'00'`indust'`mpopend' q`ages'`prew'`shock`remainder'50'`indust'`mpopend'"
local rhs`remainder'no50 "`rhs`remainder'no50' q`ages'`prew'`shock`remainder'00'`indust'`mpopend'"
}
else if regexm("`shock'","`lgender'x")==1 & "`file'"!="_exporters" {
local shock`remainder'00=subinstr("`shock'","50","00",.)
local shock`remainder'00=subinstr("`shock`remainder'00'","`lgender'x","`lgender'",.)
local shock`remainder'50=subinstr("`shock'","00","50",.)
local shock`remainder'50=subinstr("`shock`remainder'50'","`lgender'x","`lgender'",.)
local rhs`remainder' "`rhs`remainder'' q`ages'`prew'`shock`remainder'00'`indust'`mpopend' q`ages'`prew'`shock`remainder'50'`indust'`mpopend'"
local rhs`remainder'no50 "`rhs`remainder'no50' q`ages'`prew'`shock`remainder'00'`indust'`mpopend'"
}
}

if regexm("${file}","skill")==1 {
local rhs`remainder'emp "`rhs`remainder'emp' q`ages'`prew'demp00`indust'`mpopend' q`ages'`prew'demp50`indust'`mpopend' q`ages'`prew'emp00`indust'`mpopend' q`ages'`prew'emp50`indust'`mpopend'"
local rhs`remainder'empno50 "`rhs`remainder'empno50' q`ages'`prew'demp00`indust'`mpopend'  q`ages'`prew'emp00`indust'`mpopend'"
}
else {
local rhs`remainder'emp "`rhs`remainder'emp' q`ages'`prew'deltaemp00`indust'`mpopend' q`ages'`prew'deltaemp50`indust'`mpopend' q`ages'`prew'emp00`indust'`mpopend' q`ages'`prew'emp50`indust'`mpopend'"
local rhs`remainder'empno50 "`rhs`remainder'empno50' q`ages'`prew'deltaemp00`indust'`mpopend'  q`ages'`prew'emp00`indust'`mpopend'"

}


}
}
}

if  "`file'"=="_exporters" {
local rhs`remainder'="`rhs`remainder'no50' q*delta`lgender'0013`mpoppure' "
}

if regexm("`shocker'","fem")==1 & regexm("`shocker'","male")==1 & `sexremainder'!=1 {
local rhs`remainder'="`rhs`remainder'emp'"
}

if regexm("`shocker'","fem")==1 & regexm("`shocker'","male")==1 & `sexremainder'!=1 & "`file'"=="_exporters" {
local rhs`remainder'="`rhs`remainder'empno50' q*delta`lgender'0013`mpoppure' "
}


if `inston'==1 {
foreach ages in `agebands' {
foreach shock in `instrument' {
foreach indust in `indlist'  {
local rhsinst "`rhsinst' q`ages'`prew'`shock'`indust'`mpopend'"
}
}
}
}



local yobmin=1986 - `agefirst'-10
local yobmax=`yearend' - `agesecond'
local yobmaxm2=`yobmax' - 2

local yobminind=1986 - `agefirst'






local uselist "muncenso state yobexp age ?clyrschl ?clwtyrschl  `rhs`remainder'' `reglist'  `rhskeep' `interactkeep' `controlinteractkeep' `rhsinst' `randomuse'  `regweight' `contvar' "


if "`sexinteract'"=="1" & "`sexx'"=="emp" {
local uselistm: subinstr local uselist "`lgender'`lgender3'" "malem", all
local uselistm: subinstr local uselistm "`lgender'" "male", all
local uselistm: subinstr local uselistm "`lgender3'cl" "mcl", all
local uselistf: subinstr local uselist "`lgender'`lgender3'" "femf", all
local uselistf: subinstr local uselistf "`lgender'" "fem", all
local uselistf: subinstr local uselistf "`lgender3'cl" "fcl", all
local uselist "`uselist' `uselistm' `uselistf'"
}
*so here I bring in other sexes for key variables so that I can reshape later

if regexm("`reglist'","clrs")==1 | regexm("`reglist'","1990")==1 | regexm("`reglist'","xtinc")==1  | regexm("`reglist'","prop")==1  | regexm("`reglist'","drop69")==1 | regexm("`reglist'","drop912")==1 | regexm("`reglist'","ind")==1 | regexm("`reglist'","drops")==1 | regexm("`reglist'","dropw")==1 | regexm("`reglist'","dropr")==1  {
local uselist: subinstr local uselist "`reglist'" "", all
local uselist: subinstr local uselist "`regweight'" "", all

}


if "${manual}"=="1" {


noi di  `"use `uselist' if yobexp>=`yobmin' & yobexp<=`yobmax' & muncenso!=12 using "`regdata'", clear"'

noi di "weights `weightyrschl'"

}




if `mexicocity'==1 {
noi use `uselist' if yobexp>=`yobmin' & yobexp<=`yobmax' using "`regdata'", clear
replace state=17 if state==9
*places Mexico city in Morelos
}
else {
noi use `uselist' if yobexp>=`yobmin' & yobexp<=`yobmax' & muncenso!=12 using "`regdata'", clear
}

*age band 15 requires 14 year olds and above. No actually 15 years and above since dont know education for 2000 yet.
*age band 19 requires 32 year olds and below


foreach enx in  "q" {
foreach yez in 7 10 13 {
cap replace ecldrop`enx'`yez'=. if age<`yez'+6
cap replace fcldrop`enx'`yez'=. if age<`yez'+6
cap replace mcldrop`enx'`yez'=. if age<`yez'+6
}
}
******


local fileskill "${file}"
if regexm("`file'","skill")==1 {
local fileskill "_skillchar"
}


if regexm("`reglist'","clrs")==1   {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_returns2school_combo_mw${munwork}_`cenyear'.dta", keep(`reglist' `regweightinc') _merge(_mergers)
drop _mergers
pause on
pause here 
}


if regexm("`reglist'","xtinc")==1   {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_incomeonly2_mw${munwork}_`cenyear'.dta", keep(`reglist' `regweightinc') _merge(_mergers)
drop _mergers
}

if regexm("`reglist'","drops")==1 | regexm("`reglist'","dropw")==1 | regexm("`reglist'","dropr")==1  {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_newdrops_mw${munwork}_`cenyear'.dta", keep(`reglist' `regweightinc') _merge(_mergers)
drop _mergers
}

if regexm("`reglist'","prop.*ns")!=1 & regexm("`reglist'","prop")==1  & regexm("`reglist'","ind")!=1  {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_`cenyear'.dta", keep(`reglist' `regweightinc') _merge(_mergers)
drop _mergers
*noi di "mergein A `reglist' `regweightinc'"
}

if regexm("`reglist'","ind")==1   {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_ind_mw${munwork}_`cenyear'.dta", keep(`reglist' `regweightinc') _merge(_mergers)
drop _mergers
}


if regexm("`reglist'","1990")==1   {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_1990_postfix.dta", keep(`reglist' `regweightinc') _merge(_mergers)
drop _mergers
}





*this load smigrant interaction data 
if regexm("`interactlist'","migprop")==1  {  // | regexm("`controlinteract'","migprop")==1  this messes up with migprop in interactuse

*generated in "Getting skill by sector building on temp7 full sample_original_allyears migprop.do"


*these rae generated in \Mexico\Revision\New_code\MCohortAveragesOnly_forDifInDif.do and use new industries
merge m:1 muncenso using "${dir}mig_industry_counts_cen90_2000.dta", generate(_mergeeee)
drop _mergeeee
merge m:1 muncenso using "${dir}mig_industry_counts_cen90_1990.dta", generate(_mergeeee)
drop _mergeeee

foreach X of varlist migprop* {
replace `X'=0 if `X'==.
*this is crude as I replace missing migs with 0. there are about 500 municipalities missing presumably where there is no manufcatuirngs. check this.
}
}

if regexm("`interactlist'","stat")==1 | regexm("`controlinteract'","stat")==1 {
sort muncenso
merge muncenso using "${dir}Stats_by_indimss3_mun_wide.dta"
drop _merge
}




if regexm("`interactlist'","prop")==1 & regexm("`interactlist'","migprop")!=1 {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_`cenyear'.dta", keep(`interactlist') _merge(_mergers)
drop _mergers
}




if regexm("`interactlist'","mdrhoscz3")==1 | regexm("`controlinteract'","mdrhoscz3")==1 | regexm("`interactlist'","mscz3c")==1 | regexm("`controlinteract'","mscz3c")==1 | regexm("`interactlist'","mexpscz3")==1 | regexm("`controlinteract'","mexpscz3")==1 {
merge m:1 muncenso using "${dir}/Revision/mun4merge_schlz3cat_exp_v2.dta", generate(_mergers)
drop _mergers
}

if regexm("`interactlist'","mdrhoschl")==1 | regexm("`controlinteract'","mdrhoschl")==1 | regexm("`interactlist'","mschl")==1 | regexm("`controlinteract'","mschl")==1 | regexm("`interactlist'","mexpschl")==1 | regexm("`controlinteract'","mexpschl")==1 {
merge m:1 muncenso using "${dir}/Revision/mun4merge_yrschl_exp_v2.dta", generate(_mergers)
drop _mergers
}

 


if regexm("`interactlist'","prop")!=1 & regexm("`controlinteract'","prop")==1 & regexm("`controlinteract'","migprop")!=1 {


local propinteract ""
tokenize "`controlinteractxxx'"
forval n=1/100 {
if regexm("``n''","prop")==1 {
local propinteract "``n'' `propinteract'"
}
}
*noi di "`schattinteract'"
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_`cenyear'.dta", keep(`propinteract') _merge(_mergers)
drop _mergers
*noi di "mergein C `propinteract'"
}

if regexm("`interactlist'","schldrop")==1  {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_droponly_mw${munwork}_`cenyear'.dta", keep(`interactlist') _merge(_mergers)
drop _mergers
}


if regexm("`interactlist'","schatt")==1  {
sort muncenso
merge muncenso using "${dir}Schatt_byMun_Age_wide.dta", keep(`interactlist')
drop _merge
}

if regexm("`interactlist'","atgrade")==1 & regexm("`interactlist'","schatgrade")!=1  {
sort muncenso
merge muncenso using "${dir}atgrade_byMun_Age_wide.dta", keep(`interactlist')
drop _merge
}

if regexm("`interactlist'","schatgrade")==1  {
sort muncenso
merge muncenso using "${dir}schatgrade_byMun_Age_wide.dta", keep(`interactlist')
drop _merge
}






if regexm("`interactlist'","schldrop")!=1 & regexm("`controlinteract'","schldrop")==1  {

local propinteract ""
tokenize "`controlinteractxxx'"
forval n=1/100 {
if regexm("``n''","schldrop")==1 {
local propinteract "``n'' `propinteract'"
}
}
*noi di "`schattinteract'"
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_droponly_mw${munwork}_`cenyear'.dta", keep(`propinteract') _merge(_mergers)
drop _mergers
}


if regexm("`interactlist'","schatt")!=1 & regexm("`controlinteract'","schatt")==1 {



local schattinteract ""
tokenize "`controlinteractxxx'"
forval n=1/100 {
if regexm("``n''","schatt")==1 {
local schattinteract "``n'' `schattinteract'"
}
}
sort muncenso
merge muncenso using "${dir}Schatt_byMun_Age_wide.dta", keep(`schattinteract')
drop _merge
}



if regexm("`interactlist'","atgrade")!=1 & regexm("`controlinteract'","atgrade")==1 & regexm("`controlinteract'","schatgrade")!=1 {

local atgradeinteract ""
tokenize "`controlinteractxxx'"
forval n=1/100 {
if regexm("``n''","atgrade")==1 {
local atgradeinteract "``n'' `atgradeinteract'"
}
}
*noi di "`atgradeinteract'"
sort muncenso
merge muncenso using "${dir}atgrade_byMun_Age_wide.dta", keep(`atgradeinteract')
drop _merge
}


if regexm("`interactlist'","schatgrade")!=1 & regexm("`controlinteract'","schatgrade")==1 {

local schatgradeinteract ""
tokenize "`controlinteractxxx'"
forval n=1/100 {
if regexm("``n''","schatgrade")==1 {
local schatgradeinteract "``n'' `schatgradeinteract'"
}
}
*noi di "`atgradeinteract'"
sort muncenso
merge muncenso using "${dir}schatgrade_byMun_Age_wide.dta", keep(`schatgradeinteract')
drop _merge
}






if regexm("`interactlist'","ind")==1 & regexm("`indlist'","20")!=1 {
sort muncenso
merge muncenso using "${dir}Skill_Wage_by_Mun_industry_indimss3_wide.dta", keep(`interactrun4')
drop _merge
}

if regexm("`interactlist'","ind")==1 & regexm("`indlist'","20")==1  {
sort muncenso
merge muncenso using "${dir}Skill_Wage_by_Mun_industry_indimss1_wide.dta", keep(`interactrun4')
drop _merge
}


*noi di "`interactuse'"

***here is bring in random interactions. can only use either props or schattagegrades
foreach user in `interactuse' {

if regexm("`user'","schatgrade")==1 {
sort muncenso 
merge  muncenso using "${dir}schatgrade_byMun_Age_wide.dta", keep(`user') _merge(_mergers)
drop _mergers
}
if regexm("`user'","prop")==1 & regexm("`user'","migprop")!=1  {
*noi di "prop `user'"
if regexm("`user'","1990")==1 {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_1990_postfix.dta", keep(`user') _merge(_mergers)
drop _mergers
}
else {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_`cenyear'.dta", keep(`user') _merge(_mergers)
drop _mergers
}
*noi di "mergein D `user'"
}
if regexm("`user'","migprop")==1  {
if regexm("`user'","2000")==1 {
merge m:1 muncenso using "${dir}mig_industry_counts_cen90_2000.dta", generate(_mergeeee) keepusing(`user')
drop _mergeeee
}
if regexm("`user'","1990")==1 {
merge m:1 muncenso using "${dir}mig_industry_counts_cen90_1990.dta", generate(_mergeeee) keepusing(`user')
drop _mergeeee
}
foreach X of varlist migprop* {
replace `X'=0 if `X'==.
*this is crude as I replace missing migs with 0. there are about 500 municipalities missing presumably where there is no manufcatuirngs. check this.
}

}

if regexm("`user'","schatt")==1  {
sort muncenso
merge muncenso using "${dir}Schatt_byMun_Age_wide.dta", keep(`user')
drop _merge
}
if regexm("`user'","income")==1  {
sort muncenso yobexp
merge  muncenso yobexp using "${scratch}cohortmeans_mw${munwork}_`cenyear'.dta", keep(`user') _merge(_mergers)
drop _mergers
}


foreach zip in dim dam dimt damt  dis das dist dast {
if regexm("`user'","`zip'_q")==1  {
merge m:1 muncenso using "${dir}/Revision/delta_by_mun.dta", generate(_mergers) keepusing(`user')
drop _mergers
}
}




}



if `weightsquare'==1 {
replace `regweight'=`regweight'*`regweight'
}


egen xxmeanschool=wtmean(eclyrschl), by(muncenso) weight(eclwtyrschl)
gen xxdog=1
egen xxtot=total(xxdog) , by(yobexp)
gsort - xxtot
egen xxtag=tag(muncenso)
egen xxschoolrank=rank(xxmeanschool) if xxtag==1
egen schoolrank=max(xxschoolrank), by(muncenso)
*this is all so that i make sure the schoorank is done where the largest sample is presnet (e.g all 1808 munis)
*highest value ranked 1808 (or 1809 if df included)
drop xx*
sort muncenso yobexp


gen progyear=1 if yobexp>`yobmaxm2'
replace progyear=0 if yobexp<=`yobmaxm2'
*this means it is a year when population is exposed to progressa
gen progexpose=progyear*progper10

gen ruryob=ruralper*yobexp
gen ruryob2=ruryob*ruryob


gen year=yobexp+`agesecond' 
gen yearsq=year*year
char year[omit] 1993

foreach num in `indlist' { 
cap mvencode q`agebands'pdelta*00`num'`mpopend'  q`agebands'ndelta*00`num'`mpopend' , mv(0)
}


gen `yeartrend'sq=`yeartrend'*`yeartrend'
sort muncenso



foreach ages in `agebands' {
foreach shock in `shocker' {
foreach indust in `indlist' {
local rhslist`ages' "`rhslist`ages'' q`ages'`prew'`shock'`indust'`mpopend'"
}
}
}


foreach ages in `agebands' {
foreach shock in `shocker' {
foreach indust in `indlist' {
local rhslist`ages'`shock' "`rhslist`ages'`shock'' q`ages'`prew'`shock'`indust'`mpopend'"
}
}
}


*new when change remainder (see below)
foreach ages in `agebands' {
foreach shock in `shocker' {
local rhslist`ages'`shock' "`rhslist`ages'`shock''"
}
}


local deltaid=0
local levelid=0

* so now i use level if not a delta variable and delta otherwise and subtract off all the shock from `remainder'
if `remainderon'==1 | `remainderon'==2 {
foreach ages in `agebands' {

	foreach shock in `shocker' {
	foreach type in `rhslist`ages'`shock'' {
	if regexm("`shock'","delta")==1 | regexm("`shock'","expan")==1 | regexm("`shock'","d`lgender'")==1 {
	local rhsplus`ages'remdelta "`rhsplus`ages'remdelta' - `type'"
	local deltaid=1
	}
	else if regexm("`shock'","delta")==0 & regexm("`shock'","expan")==0 & regexm("`shock'","d`lgender'")==0 {
	local rhsplus`ages'remlevel "`rhsplus`ages'remlevel' - `type'"
	local levelid=1
	}
	
	}
	}

cap gen q`ages'`prew'd`lgender'00rest`mpopend'=q`ages'`prew'd`lgender'00`remainder'`mpopend' `rhsplus`ages'remdelta'
cap gen q`ages'`prew'd`lgender'50rest`mpopend'=q`ages'`prew'd`lgender'50`remainder'`mpopend' `rhsplus`ages'remdelta'

cap gen q`ages'`prew'`lgender'00rest`mpopend'=q`ages'`prew'`lgender'00`remainder'`mpopend' `rhsplus`ages'remlevel'
cap gen q`ages'`prew'`lgender'50rest`mpopend'=q`ages'`prew'`lgender'50`remainder'`mpopend' `rhsplus`ages'remlevel'

cap gen q`ages'`prew'demp00rest`mpopend'=q`ages'`prew'demp00`remainder'`mpopend' `rhsplus`ages'remdelta'
cap gen q`ages'`prew'demp50rest`mpopend'=q`ages'`prew'demp50`remainder'`mpopend' `rhsplus`ages'remdelta'

cap gen q`ages'`prew'emp00rest`mpopend'=q`ages'`prew'emp00`remainder'`mpopend' `rhsplus`ages'remlevel'
cap gen q`ages'`prew'emp50rest`mpopend'=q`ages'`prew'emp50`remainder'`mpopend' `rhsplus`ages'remlevel'


if `levelid'==1 & `deltaid'==1 {
local rhslist`ages'remend "q`ages'`prew'd`lgender'00rest`mpopend' q`ages'`prew'`lgender'00rest`mpopend'"
local rhsil`ages'remend "q`ages'`prew'd`lgender'50rest`mpopend' q`ages'`prew'`lgender'50rest`mpopend'"
}
else if `levelid'==0 & `deltaid'==1 {
local rhslist`ages'remend "q`ages'`prew'd`lgender'00rest`mpopend'"
local rhsil`ages'remend "q`ages'`prew'd`lgender'50rest`mpopend'"
}
else if `levelid'==1 & `deltaid'==0 {
local rhslist`ages'remend "q`ages'`prew'`lgender'00rest`mpopend'"
local rhsil`ages'remend "q`ages'`prew'`lgender'50rest`mpopend'"
}



*so here I overrule the above code and make sure it is an emp remainder term if both male and female jobs on rhs
if regexm("`shocker'","fem")==1 & regexm("`shocker'","male")==1 & `sexremainder'!=1 {
if `levelid'==1 & `deltaid'==1 {
local rhslist`ages'remend "q`ages'`prew'deltaemp00rest`mpopend' q`ages'`prew'emp00rest`mpopend'"
local rhsil`ages'remend "q`ages'`prew'deltaemp50rest`mpopend' q`ages'`prew'emp50rest`mpopend'"
}
else if `levelid'==0 & `deltaid'==1 {
local rhslist`ages'remend "q`ages'`prew'deltaemp00rest`mpopend'"
local rhsil`ages'remend "q`ages'`prew'deltaemp50rest`mpopend'"
}
else if `levelid'==1 & `deltaid'==0 {
local rhslist`ages'remend "q`ages'`prew'emp00rest`mpopend'"
local rhsil`ages'remend "q`ages'`prew'emp50rest`mpopend'"
}
}

}
}








foreach ages in `agebands' {
foreach shock in `instrument' {
foreach indust in `indlist' {
local rhsinstl`ages' "`rhsinstl`ages'' q`ages'`prew'`shock'`indust'`mpopend'"
}
}
}

foreach ages in `agebands' {
foreach shock in `instrument' {
foreach indust in `indlist' {
local rhsil`ages'`shock' "`rhsil`ages'`shock'' q`ages'`prew'`shock'`indust'`mpopend'"
}
}
}



foreach ages in `agebands' {
foreach shock in `instrument' {
local rhsil`ages'`shock' "`rhsil`ages'`shock''"
}
}


foreach ages in `agebands' {
foreach shock in `shocker' {
local rhslist1 " `rhslist1' "`rhslist`ages'`shock'' " "

}
}




foreach ages in `agebands' {
foreach shock in `instrument' {
local rhsinstl1 " `rhsinstl1' "`rhsil`ages'`shock'' " "

}
}





foreach ages in `agebands' {
foreach shock in `shocker' {
local rhslist2 " `rhslist2' `rhslist`ages'`shock'' "
}
if `remainderon'==1{
local rhslist2 " `rhslist2' `rhslist`ages'remend' "
}

if `remainderon'==2{
local rhslist2 " `rhslist2' `rhsil`ages'remend' "
}

}


foreach ages in `agebands' {
foreach shock in `instrument' {
local rhsinstl2 " `rhsinstl2' `rhsil`ages'`shock'' "
}
if `remainderon'==1{
local rhsinstl2 " `rhsinstl2' `rhsil`ages'remend' "
}

}



local rhslist "  "`rhslist2'" "
"'





local rhsinstl "  "`rhsinstl2'" "

foreach rhs in     `rhslist'    { 

foreach rhsinst in     `rhsinstl'    { 

foreach lhs in `reglist' {
	
foreach iffy in `iflist' {

local iffya=regexr("`iffy'","&","")


local counter=1+`counter'
if `counter'==1 {
local append="replace"
}
else {
local append=""
}



cap renvars , subs(hire`lgender4'`lgender'05 delta`lgender')
cap renvars , subs(fire`lgender4'`lgender'05 fire`lgender')
cap renvars , subs(delta`lgender'05 delta`lgender')


tokenize `rhs'
forval n=1/100 {
cap local `n'=subinstr("``n''","hire`lgender4'`lgender'05","delta`lgender'",.)
cap local `n'=subinstr("``n''","fire`lgender4'`lgender'05","fire`lgender'",.)
cap local `n'=subinstr("``n''","delta`lgender'05","delta`lgender'",.)
cap local `n'=subinstr("``n''","deltafem05","deltafem",.)
cap local `n'=subinstr("``n''","deltamale05","deltamale",.)
cap local `n'=subinstr("``n''","deltaemp05","deltaemp",.)
}


local rhs2 ""

forval n=1/100 {
local rhs2 `rhs2' ``n''
}



tsset  muncenso yobexp
// may11 added lags
*note that I should remove fe with lags
forval lno=1/5 {
cap gen l`lno'`lhs'=l`lno'.`lhs'
cap gen l`lno'`regweight'=l`lno'.`regweight'
cap gen l`lno'`lgender3'clyrschl=l`lno'.`lgender3'clyrschl
cap gen f`lno'`lhs'=f`lno'.`lhs'
cap gen f`lno'`regweight'=f`lno'.`regweight'
cap gen f`lno'`lgender3'clyrschl=f`lno'.`lgender3'clyrschl
}

cap gen `yeartrend'z=`yeartrend'



*set bases for region
fvset base 3 region1
fvset base 3 region2
char region1[omit] 3
char region2[omit] 3


			 *get this ready for cluster sample issues
			cap drop meaneclwtyrschl
			local listeree ""
			foreach dog in `rhs2' {
			local listeree "`listeree'  & `dog'!=."
			}
			egen meaneclwtyrschl=mean(eclwtyrschl) if `lhs'!=. `listeree', by(muncenso)
			cap drop badclusterschl
			
			gen badclusterschl=0
		
			foreach bad in 	 20431 20442 20478 20529 20547 20562 20563  { // 20431 20442 20478 20496 20512 20522 20529 20547 20562 20563 
			replace badclusterschl=1 if	muncenso==`bad'
			}
			
		
			
			cap gen initialschl=eclyrschl
		

if "${delta_estimate}"=="1" {
*this is where I calculate locations specific deltas

cap drop d??_q`aget'demp*
cap drop d???_q`aget'demp*

if "${delta_type}"=="dam" {

foreach geog in muncenso {
levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50${nonexport}${mpop} `rhs2' {
gen da`geocode'_`indy'=.
gen da`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if `geog'==`mun'
cap replace da`geocode'_`indy'=_b[l.`indy'] if  `geog'==`mun'
cap replace da`geocode't_`indy'=da`geocode'_`indy'
cap replace da`geocode't_`indy'=1 if  da`geocode'_`indy'!=. & da`geocode'_`indy'>1
cap replace da`geocode't_`indy'=0 if  da`geocode'_`indy'!=. & da`geocode'_`indy'<0
}
noi di "`indy' `geog' done"
}
}

}
if "${delta_type}"=="das" {
foreach geog in state  {
levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50${nonexport}${mpop} `rhs2' {
gen da`geocode'_`indy'=.
gen da`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if `geog'==`mun'
cap replace da`geocode'_`indy'=_b[l.`indy'] if  `geog'==`mun'
cap replace da`geocode't_`indy'=da`geocode'_`indy'
cap replace da`geocode't_`indy'=1 if  da`geocode'_`indy'!=. & da`geocode'_`indy'>1
cap replace da`geocode't_`indy'=0 if  da`geocode'_`indy'!=. & da`geocode'_`indy'<0
}
noi di "`indy' `geog' done"
}
}

}

if "${delta_type}"=="dis" {
foreach geog in state  {
levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50${nonexport}${mpop} `rhs2' {
gen di`geocode'_`indy'=.
gen di`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if year<1990 & `geog'==`mun'  
cap replace di`geocode'_`indy'=_b[l.`indy']  if `geog'==`mun' 
cap replace di`geocode't_`indy'=di`geocode'_`indy'
cap replace di`geocode't_`indy'=1 if  di`geocode'_`indy'!=. & di`geocode'_`indy'>1
cap replace di`geocode't_`indy'=0 if  di`geocode'_`indy'!=. & di`geocode'_`indy'<0
}

noi di "`indy' `geog' done"
}
}

}

if "${delta_type}"=="dim" {
foreach geog in  muncenso {
levelsof `geog'
local munlist "`r(levels)'"
local geocode=substr("`geog'",1,1)
foreach indy in   q`aget'demp50${nonexport}${mpop} `rhs2' {
gen di`geocode'_`indy'=.
gen di`geocode't_`indy'=.
foreach mun of local munlist {
cap reg `indy' l.`indy' if year<1990 & `geog'==`mun'  
cap replace di`geocode'_`indy'=_b[l.`indy']  if `geog'==`mun' 
cap replace di`geocode't_`indy'=di`geocode'_`indy'
cap replace di`geocode't_`indy'=1 if  di`geocode'_`indy'!=. & di`geocode'_`indy'>1
cap replace di`geocode't_`indy'=0 if  di`geocode'_`indy'!=. & di`geocode'_`indy'<0
}
noi di "`indy' `geog' done"
}
}

}





}
*end of delat estimate










local codeinsert1=`"${codeinsert1}"'
local codeinsert2=`"${codeinsert2}"'
local codeinsert3=`"${codeinsert3}"'
local codeinsert4=`"${codeinsert4}"'
local codeinsert5=`"${codeinsert5}"'
local codeinsert6=`"${codeinsert6}"'
local codeinsert7=`"${codeinsert7}"'
local codeinsert8=`"${codeinsert8}"'
local codeinsert9=`"${codeinsert9}"'
local codeinsert10=`"${codeinsert10}"'
local codeinsert11=`"${codeinsert11}"'
local codeinsert12=`"${codeinsert12}"'
local codeinsert13=`"${codeinsert13}"'
local codeinsert14=`"${codeinsert14}"'
local codeinsert15=`"${codeinsert15}"'
local codeinsert16=`"${codeinsert16}"'
local codeinsert17=`"${codeinsert17}"'
local codeinsert18=`"${codeinsert18}"'
local codeinsert19=`"${codeinsert19}"'
local codeinsert20=`"${codeinsert20}"'
local codeinsert21=`"${codeinsert21}"'
local codeinsert22=`"${codeinsert22}"'
local codeinsert23=`"${codeinsert23}"'
local codeinsert24=`"${codeinsert24}"'
local codeinsert25=`"${codeinsert25}"'
local codeinsert26=`"${codeinsert26}"'
local codeinsert27=`"${codeinsert27}"'
local codeinsert28=`"${codeinsert28}"'
local codeinsert29=`"${codeinsert29}"'
local codeinsert30=`"${codeinsert30}"'
local codeinsert31=`"${codeinsert31}"'
local codeinsert32=`"${codeinsert32}"'
local codeinsert33=`"${codeinsert33}"'
local codeinsert34=`"${codeinsert34}"'
local codeinsert35=`"${codeinsert35}"'
local codeinsert36=`"${codeinsert36}"'
local codeinsert37=`"${codeinsert37}"'
local codeinsert38=`"${codeinsert38}"'
local codeinsert39=`"${codeinsert39}"'
local codeinsert40=`"${codeinsert40}"'
local codeinsert41=`"${codeinsert41}"'
local codeinsert42=`"${codeinsert42}"'
local codeinsert43=`"${codeinsert43}"'
local codeinsert44=`"${codeinsert44}"'
local codeinsert45=`"${codeinsert45}"'
local codeinsert46=`"${codeinsert46}"'
local codeinsert47=`"${codeinsert47}"'
local codeinsert48=`"${codeinsert48}"'
local codeinsert49=`"${codeinsert49}"'
local codeinsert50=`"${codeinsert50}"'
local codeinsert51=`"${codeinsert51}"'
local codeinsert52=`"${codeinsert52}"'
local codeinsert53=`"${codeinsert53}"'
local codeinsert54=`"${codeinsert54}"'
local codeinsert55=`"${codeinsert55}"'
local codeinsert56=`"${codeinsert56}"'
local codeinsert57=`"${codeinsert57}"'
local codeinsert58=`"${codeinsert58}"'
local codeinsert59=`"${codeinsert59}"'
local codeinsert60=`"${codeinsert60}"'
local codeinsert61=`"${codeinsert61}"'
local codeinsert62=`"${codeinsert62}"'
local codeinsert63=`"${codeinsert63}"'
local codeinsert64=`"${codeinsert64}"'
local codeinsert65=`"${codeinsert65}"'
local codeinsert66=`"${codeinsert66}"'
local codeinsert67=`"${codeinsert67}"'
local codeinsert68=`"${codeinsert68}"'
local codeinsert69=`"${codeinsert69}"'

`codeinsert1'
`codeinsert2'
`codeinsert3'
`codeinsert4'
`codeinsert5'
`codeinsert6'
`codeinsert7'
`codeinsert8'
`codeinsert9'
`codeinsert10'
`codeinsert11'
`codeinsert12'
`codeinsert13'
`codeinsert14'
`codeinsert15'
`codeinsert16'
`codeinsert17'
`codeinsert18'
`codeinsert19'
`codeinsert20'
`codeinsert21'
`codeinsert22'
`codeinsert23'
`codeinsert24'
`codeinsert25'
`codeinsert26'
`codeinsert27'
`codeinsert28'
`codeinsert29'
`codeinsert30'
`codeinsert31'
`codeinsert32'
`codeinsert33'
`codeinsert34'
`codeinsert35'
`codeinsert36'
`codeinsert37'
`codeinsert38'

cap drop period1 period2 period3
gen period1=(year<1990 & year>=1986)
gen period2=(year>=1990 & year<1995)
gen period3=(year>=1995 & year<2000)

cap drop periodz0 periodz1 periodz2 periodz3
gen periodz0=(year==1986)
gen periodz1=(year<1992 & year>1986)
gen periodz2=(year>=1992 & year<1996)
gen periodz3=(year>=1996 & year<2000)

cap drop `lgender3'meanschool
cap drop `lgender3'meanschooll?
cap drop `lgender3'meanschooll?sq
egen `lgender3'meanschool=wtmean(`lgender3'clyrschl) if yobexp>=`yobminind' & yobexp<=`yobmax', by(muncenso) weight(`lgender3'clwtyrschl)
*this is mean school prior to 1986 (initial levels) either 2 year or 5 year averages

foreach X in 1 2 5 {
egen x`lgender3'meanschooll`X'=wtmean(`lgender3'clyrschl) if yobexp<`yobminind' & yobexp>=`yobminind'-`X', by(muncenso) weight(`lgender3'clwtyrschl)
egen `lgender3'meanschooll`X'=max(x`lgender3'meanschooll`X'), by(muncenso)
drop x`lgender3'meanschooll`X'
gen `lgender3'meanschooll`X'sq=`lgender3'meanschooll`X'*`lgender3'meanschooll`X'
}

foreach X in `indlist' {
foreach Y in school retschool schooll1 retschooll1 schooll2 retschooll2 schooll5 retschooll5 {
cap gen `lgender3'mean`Y'`X'=`lgender3'mean`Y'
}
}





if "${sexmix}"=="1" {
gen muncensonosex=muncenso
gen statenosex=state
}




*this gets 2 and 5 year average lags
if regexm("`laganything'","prop1012")==1 | regexm("`laganything'","prop911")==1 {
foreach mid in prop1012  prop911 {
foreach X in 1 2 5 {
cap egen x`lgender3'mean`mid'l`X'=wtmean(`lgender3'clyrschl`mid') if yobexp<`yobminind' & yobexp>=`yobminind'-`X', by(muncenso) weight(`lgender3'clwtyrschl)
cap egen `lgender3'mean`mid'l`X'=max(x`lgender3'mean`mid'l`X'), by(muncenso)
cap drop x`lgender3'mean`mid'l`X'
cap gen `lgender3'mean`mid'l`X'sq=`lgender3'mean`mid'l`X'*`lgender3'mean`mid'l`X'
}
}
}


		if "`iffy'"=="" {
		local ifsterx "if muncenso!=."
		}
		else {
		local ifsterx "`iffy'"
		}





if "`laglevelinteract'"=="9" {
foreach thingymabob of varlist `interactrun' `laganything' {
if regexm("`thingymabob'","mig")!=1 & regexm("`thingymabob'","school")!=1  & regexm("`thingymabob'","yobexp")!=1 & regexm("`thingymabob'","female")!=1   & regexm("`thingymabob'","schattage")!=1 & regexm("`thingymabob'","atgradeage")!=1 {

local rhsname=word("`rhs2'",1)
cap egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
gen xyearfirstob=yobexp if firstob[_n+5]==1
egen yearfirstob=max(xyearfirstob), by(muncenso)
cap drop xyearfirstob  
cap drop firstob
cap egen x`thingymabob'in5=wtmean(`thingymabob') if yobexp<yearfirstob & yobexp>=yearfirstob-5, by(muncenso) weight(`lgender3'clwtyrschl)
cap egen xxx`thingymabob'in5=max(x`thingymabob'in5), by(muncenso)
cap drop `thingymabob' x`thingymabob'in5 yearfirstob
cap drop yearfirstob
}
}
}
*this takes 5 years before initial value (and takes 5 year average)  of what ever is in interact.
*would be something like 5p85



if "`laglevelinteract'"=="19" {
foreach thingymabob of varlist `interactrun' `laganything' {
if regexm("`thingymabob'","mig")!=1 & regexm("`thingymabob'","school")!=1  & regexm("`thingymabob'","yobexp")!=1 & regexm("`thingymabob'","female")!=1   & regexm("`thingymabob'","schattage")!=1 & regexm("`thingymabob'","atgradeage")!=1 {

local rhsname=word("`rhs2'",1)
cap egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
gen xyearfirstob=yobexp if firstob[_n+2]==1
egen yearfirstob=max(xyearfirstob), by(muncenso)
cap drop xyearfirstob  
cap drop firstob
cap egen x`thingymabob'in4=wtmean(`thingymabob') if yobexp<yearfirstob & yobexp>=yearfirstob-5, by(muncenso) weight(`lgender3'clwtyrschl)
cap egen xxx`thingymabob'in4=max(x`thingymabob'in4), by(muncenso)
cap drop `thingymabob' x`thingymabob'in4 yearfirstob
cap drop yearfirstob
}
}
}
*this takes 2 years before initial value (and takes 5 year average)  of what ever is in interact.
*this corresponds to 5p88 in graphs file





local lagleveldirect ""


cap renpfix xxx



`codeinsert40'
`codeinsert41'
`codeinsert42'
`codeinsert43'
`codeinsert44'
`codeinsert45'
`codeinsert46'
`codeinsert47'
`codeinsert48'
`codeinsert49'
`codeinsert50'
`codeinsert51'
`codeinsert52'
`codeinsert53'
`codeinsert54'
`codeinsert55'
`codeinsert56'
`codeinsert57'
`codeinsert58'
`codeinsert59'
`codeinsert60'
`codeinsert61'
`codeinsert62'
`codeinsert63'
`codeinsert64'
`codeinsert65'
`codeinsert66'
`codeinsert67'
`codeinsert68'
`codeinsert69'





if "${sexmix}"=="1" {



cap renvars *dempm*  , postfix(_s0)
cap renvars *dempm*  , sub(dempm demp)

cap renvars *dempdm* , postfix(_s0)
cap renvars *dempdm*  , sub(dempdm dempde)
cap renvars *demptdm* , postfix(_s0)
cap renvars *demptdm*  , sub(demptdm demptde)

cap renvars *dmale*  , postfix(_s0)
cap renvars *dmale*  , sub(50m 50e)
cap renvars *dmale*  , sub(male emp)

cap renvars mcl*  , postfix(_s0)
cap renvars mcl*  , sub(mcl cl)

cap renvars *dempf*  , postfix(_s1)
cap renvars *dempf*  , sub(dempf demp)

cap renvars *dempdf* , postfix(_s1)
cap renvars *dempdf*  , sub(dempdf dempde)
cap renvars *demptdf* , postfix(_s1)
cap renvars *demptdf*  , sub(demptdf demptde)

cap renvars *dfem*  , postfix(_s1)
cap renvars *dfem*  , sub(50f 50e)
cap renvars *dfem*  , sub(fem emp)

cap renvars fcl*  , postfix(_s1)
cap renvars fcl*  , sub(fcl cl)


drop ecl*
*cap drop esch*

local stublist ""
qui ds *_s0
local stubs "`r(varlist)'"
tokenize `stubs'
forval n=1/2000 {
local `n'=regexr("``n''","_s0","")
local stublist `stublist' ``n''
}

*noi di "`stublist'"


reshape long `stublist' , i(`yeartrend' muncenso) j(xfemale) string

gen female=1 if  xfemale=="_s1"
replace female=0 if xfemale=="_s0"
drop xfemale



renpfix cl ecl
*renpfix sch esch

drop muncensonosex statenosex

egen munfem=group(female muncenso)
rename muncenso muncensonosex
rename munfem muncenso
tsset muncenso `yeartrend'  
***this changes the state fixed effects to be statesex fixed effects
egen statefem=group(female state)
rename state statenosex
rename statefem state



}


*this code give me male and female shocks and names them all emp so that i can interact.
*to use need sexinteract=1, sexx=emp and interact=female


if "`sexinteract'"=="1" & "`sexx'"=="emp" {



*here I take the list of variables and replace emp with male or fem
local changelist "`rhs2' `lhs' `regweight'"
local changelistm: subinstr local changelist "`lgender'`lgender3'" "malem", all
local changelistm: subinstr local changelistm "`lgender'" "male", all
local changelistm: subinstr local changelistm "`lgender3'cl" "mcl", all
local changelistf: subinstr local changelist "`lgender'`lgender3'" "femf", all
local changelistf: subinstr local changelistf "`lgender'" "fem", all
local changelistf: subinstr local changelistf "`lgender3'cl" "fcl", all



drop `changelist'


renvars `changelistm', postfix(_s0)
renvars *_s0 , sub(malem empe)
renvars *_s0 , sub(male emp) 
renvars *_s0 , presub(mcl ecl) 
renvars `changelistf', postfix(_s1)
renvars *_s1 , sub(femf empe) 
renvars *_s1 , sub(fem emp) 
renvars *_s1 , presub(fcl ecl) 


*now i get other measure which is opposite sex
foreach thing of var q*s0 {
gen x`thing'=`thing'
}
foreach thing of var q*s1 {
gen y`thing'=`thing'
}
renvars xq*s0, sub(_s0 _s1)
renvars yq*s1, sub(_s1 _s0 )
renvars xq*s1 yq*s0, sub(emp oth)
renvars xq*s1, presub(x )
renvars yq*s0, presub(y )



local stublist ""
qui ds *_s0
local stubs "`r(varlist)'"
tokenize `stubs'
forval n=1/2000 {
local `n'=regexr("``n''","_s0","")
local stublist `stublist' ``n''
}

*noi di "`stublist'"


reshape long `stublist' , i(`yeartrend' muncenso) j(xfemale) string

gen female=1 if  xfemale=="_s1"
replace female=0 if xfemale=="_s0"
drop xfemale
gen notfemale=1-female
egen munfem=group(female muncenso)
rename muncenso municipality
rename munfem muncenso
tsset muncenso `yeartrend'  



gen statefem=state*female

*note that there are also muncipality-sex fixed effects.

if "`linear'"=="_linear" {
*local control2 "`control2' i.statefem*i.`yeartrend' female"
}
else {
*local control2 "`control2' i.statefem*i.`yeartrend' female i.statefem|`yeartrend'zl`catchlag'`catchlist'"
}



}

local controlinteracttemp ""
local controlinteracttemp "`controlinteract'"
local controlinteract "`controlinteract' `controlinsert1' `controlinsert2' `controlinsert3' `controlinsert4'" 
*here i can inject any code i like



*start regs


`codeinsert39'


*IV
if `inston'==1 {

if "`lags'"=="" {

noi di "--------------------------------------------------------------------------"
noi di "xi: xtivreg2  `lhs'  `lags'  `control2' `control' `controlinteract'   i.state*i.`yeartrend' (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], fe robust cluster(muncenso)" 
noi di "--------------------------------------------------------------------------"

/*
							if "`lags'"=="" & `catchupon'==1 {
							local regtype "xtivreg2"
							local xttype "fe"
							
													local rhsname=word("`rhs2'",1)
													egen firstob=tag(muncenso) if `rhsname'!=. 
													gen xyearfirstob=`yeartrend' if firstob==1
													egen yearfirstob=max(xyearfirstob), by(muncenso)
													gen yeartimer=yobexp-yearfirstob
													drop xyearfirstob yearfirstob firstob
													foreach n in `catchlag' {
													egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
													egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
													gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
													drop xpremeanl`n' premeanl`n'
													}
													drop yeartimer
													qui xi: `regtype'  `lhs' `lags'  `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'    (`rhs2'=`rhsinst')    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
													outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("IVCATCHUP OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", e(N_clust), CD F Stat, e(cdf), KP F Stat, e(rkf))  nonotes excel nocons 
													drop `yeartrend'zl`catchlag'`catchlist' 
							
							}
*/

if  `catchupon'==0 {

noi di "--------------------------------------------------------------------------"
noi di "xi: xtivreg2  `lhs'  `lags'  `control2' `control' `controlinteract' _I* (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], fe robust cluster(muncenso) partial(_I*) "  
noi di "--------------------------------------------------------------------------"

cap gen `yeartrend'z=`yeartrend'
*this uses a linear trend and xtivreg2

xi i.muncenso|`yeartrend'z  i.state*i.`yeartrend'
noi di "running ready"
 
xtivreg2  `lhs'  `lags'  `control2' `control' `controlinteract' _I*  (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], fe robust cluster(muncenso) partial(_I*) 
outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("IVLINEAR partial `lhs' `shocker' `bartype' stated `iffy' `regweight'")   addstat("Municipalities", e(N_clust), CD F Stat, e(cdf), KP F Stat, e(rkf))   nonotes  excel nocons 

									if "$testes"=="1" {
														
														pause on
														pause here 
									}

cap drop `yeartrend'z
}

*tests for parameter equality between positive and negative coefficients
/**
foreach n in 24 33 34 26 29 {
noi test q15pdeltaemp`n'mpop15_49=q15ndeltaemp`n'mpop15_49
}
noi test q15ndeltaemp24mpop15_49 q15ndeltaemp33mpop15_49 q15ndeltaemp34mpop15_49 q15ndeltaemp26mpop15_49 q15ndeltaemp29mpop15_49
**/

}
*this runs with no fixed effects for lags
if "`lags'"!="" {

if  `catchupon'==1 {
							local regtype "ivreg2"
							local xttype ""



													if "`iffy'"=="" {
													local ifsterx "if muncenso!=."
													}
													else {
													local ifsterx "`iffy'"
													}
									
							
													cap drop premean*
													local rhsname=word("`rhs2'",1)
													egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=.  
													gen xyearfirstob=`yeartrend' if firstob==1
													egen yearfirstob=max(xyearfirstob), by(muncenso)
													gen yeartimer=yobexp-yearfirstob
													drop xyearfirstob yearfirstob firstob
													foreach n in `catchlag' {
													egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
													egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
													gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
													drop xpremeanl`n' premeanl`n'
													}
													drop yeartimer
													qui xi: `regtype'  `lhs' `lags'  `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'    (`rhs2'=`rhsinst')    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
													outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("IVCATCHUP LDV OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", e(N_clust), CD F Stat, e(cdf), KP F Stat, e(rkf))  nonotes excel nocons 
													qui xi: reg  `lhs' `lags'  `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'    `rhsinst'    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
													outreg2  `rhsinst'  `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("RFCATCHUP LDV OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")     nonotes excel nocons 
													
													drop `yeartrend'zl`catchlag'`catchlist' 
							
							}

}







}




if `ivonly'==0 & `inston'==1 {

if "`lags'"=="" {
local regtype "xtivreg2"
local xttype "fe"
}
if "`lags'"!="" {
local regtype "ivreg2"
local xttype ""
}

	*OLS
	qui xi: `regtype'  `lhs' `lags'  `rhs2' `control2' `control' `controlinteract'   i.state*i.`yeartrend'   `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("OLS `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons
	*note that & inside colum titles dont work in latex

	*Reduced Form
	qui xi: `regtype'  `lhs'  `lags' `rhsinst' `control2' `control' `controlinteract'   i.state*i.`yeartrend'   `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhsinst' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("RF `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 

	*No state fixed effects
	if `nostatefe'==1 {
	qui xi: `regtype'  `lhs'  `lags'  `control2' `control' `controlinteract'   i.`yeartrend' (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("No state fe `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 
	}
	
		*No year or state fixed effects
		if `noyearfe'==1 {
		qui xi: `regtype'  `lhs'  `lags'  `control2' `control' `controlinteract'    (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
		outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("No year fe `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 
		}
	

	

	
	*additional linear time trend
	if `lineartrendon'==1 & "`lags'"=="" {
	cap gen `yeartrend'z=`yeartrend'
	qui xi: `regtype'  `lhs'  `lags'  `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z    i.state*i.`yeartrend'   (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("IVLIN `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", e(N_clust), CD F Stat, e(cdf), KP F Stat, e(rkf))  nonotes excel nocons 
	drop `yeartrend'z
	}
	
		*additional linear time trend
		if `lineartrendstatefeon'==1 {
		cap gen `yeartrend'z=`yeartrend'
		qui xi: `regtype'  `lhs'  `lags'  `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z    i.`yeartrend'   (`rhs2'=`rhsinst')  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
		outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("OLSLINnostatFE `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
		drop `yeartrend'z
	}
	
	
	
	
				*additional trends to pick up catchup growth: this uses initial schooling if there are no LDV's while above I have a 5 year lag average that might be more sensible
				if `catchupon'==1 & "`lags'"!="" {
				cap gen `yeartrend'z=`yeartrend'
				local lagger1=word("`lags'",1)
				local lagger2=word("`lags'",2)
				gen `yeartrend'z`lagger1'=`yeartrend'*`lagger1'
				qui xi: `regtype'  `lhs' `lags'  `control2' `control' `controlinteract'    i.state*i.`yeartrend' i.state|`yeartrend'z`lagger1'   (`rhs2'=`rhsinst')     `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
				outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("IVCATCHUP `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", e(N_clust), CD F Stat, e(cdf), KP F Stat, e(rkf))  nonotes excel nocons 
				drop `yeartrend'z `yeartrend'z`lagger1'
				}
							if `catchupon'==1 & "`lags'"=="" {
													if "`iffy'"=="" {
													local ifsterx "if muncenso!=."
													}
													else {
													local ifsterx "`iffy'"
													}													
													cap drop premean*
													local rhsname=word("`rhs2'",1)
													egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=.  
													gen xyearfirstob=`yeartrend' if firstob==1
													egen yearfirstob=max(xyearfirstob), by(muncenso)
													gen yeartimer=yobexp-yearfirstob
													drop xyearfirstob yearfirstob firstob
													foreach n in `catchlag' {
													egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
													egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
													gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
													drop xpremeanl`n' premeanl`n'
													}
													drop yeartimer
													qui xi: `regtype'  `lhs' `lags'  `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'    (`rhs2'=`rhsinst')    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
													outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("IVCATCHUP OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", e(N_clust), CD F Stat, e(cdf), KP F Stat, e(rkf))  nonotes excel nocons 
													drop `yeartrend'zl`catchlag'`catchlist' 
							
							}

	
	
	
}

if `ivonly'==0 & `inston'==0  & `finalrfspec'!=1 {

if "`lags'"=="" {
local regtype "areg"
local xttype "a(muncenso)"
}
if "`lags'"!="" {
local lagcount=wordcount("`lags'")
local regtype "regress"
local xttype ""
}


noi di "--------------------------------------------------------------------------"
noi di "xi: `regtype'  `lhs'   `rhs2' `lags' `control2' `control' `controlinteract'   i.state*i.`yeartrend'   `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)" 
noi di "--------------------------------------------------------------------------"




	*OLS
	qui xi: `regtype'  `lhs'  `lags' `rhs2' `control2' `control' `controlinteract'   i.state*i.`yeartrend'   `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("OLSnoIV `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 
	
	*No state fixed effects
	if `nostatefe'==1 {
	qui xi: `regtype'  `lhs' `rhs2' `lags'  `control2' `control' `controlinteract'   i.`yeartrend'  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("OLSNostatefe `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 
	}
	
		*No year or state fixed effects
		if `noyearfe'==1 {
		qui xi: `regtype'  `lhs' `rhs2' `lags'  `control2' `control' `controlinteract'     `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
		outreg2 `rhs2' `controlinteract' `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("OLSNosyearfe `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 
		}
	

			*Interactlist
			if "`interactlist'"!="" {
			local interactlister ""
			local wordcountsrhs=wordcount("`rhs2'")
			local wordcountsshock=wordcount("`shocker'")
			local wordcountsind=wordcount("`indlist'")
			local starter=1
			local ender=`wordcountsind'*`wordcountsshock'-`wordcountsind'+1
			tokenize `rhs2' 
			foreach inter in `interactrun' {
				forval n=`starter'(`wordcountsind')`ender' {
				if regexm("`inter'","^i\.")!=1   & regexm("`inter'","^ib.\.")!=1 {
				local interactlister "`interactlister'  c.`inter'#c.(``n'')"
				}
				else {
				local interactlister "`interactlister'  `inter'#c.(``n'')"
				}
				}
			local starter=`starter'+1
			local ender=`ender'+1
			}
			*doesnt even work if there are two shockers (hire and fire),or maybe it does
			*say shocker=3... want 1-3 with interact 1, 4-6 with interact 2 etc  so want indlist 1 indlist 4 indlist 7 etc with first
			noi di "--------------------------------------------------------------------------"
			noi di "INTERACTION: xi: `regtype'  `lhs'  `rhs2' `interactlister' `lags' `control2' `control' `controlinteract' `lagleveldirect'  i.state*i.`yeartrend'   `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"
			noi di "--------------------------------------------------------------------------"
			
			
			
			qui xi: `regtype'  `lhs' `lags' `rhs2' `interactlister' `control2' `control' `controlinteract'  `lagleveldirect'   i.state*i.`yeartrend'   `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)
			outreg2 `rhs2' `controlinteract' `interactlister'  `lagleveldirect'  `lags'  using "${dirtemp}elrd_`regname'", title("") ctitle("Interact `lhs' `shocker' stated `iffy'  `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes  excel nocons 
			
			if `lineartrendon'==1 & "`lags'"=="" {
							cap gen `yeartrend'z=`yeartrend'
							qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister' `control2' `control' `controlinteract'  `lagleveldirect'   i.muncenso|`yeartrend'z    i.state*i.`yeartrend'    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
							outreg2 `rhs2' `controlinteract' `interactlister'  `lagleveldirect'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("InteractLIN `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
							drop `yeartrend'z
			}
			
			
						*additional trends to pick up catchup growth: this uses initial schooling if there are no LDV's while above I have a 5 year lag average that might be more sensible
						if `catchupon'==1 & "`lags'"!="" {
						cap gen `yeartrend'z=`yeartrend'
						local lagger1=word("`lags'",1)
						gen `yeartrend'z`lagger1'=`yeartrend'*`lagger1'
						qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'   `control2' `control' `controlinteract'  `lagleveldirect'    i.state*i.`yeartrend' i.state|`yeartrend'z`lagger1'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
						outreg2 `rhs2' `controlinteract'  `lags' `interactlister'  `lagleveldirect'  using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
						drop `yeartrend'z `yeartrend'z`lagger1'
						}
									if `catchupon'==1 & "`lags'"=="" {
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
									gen xyearfirstob=`yeartrend' if firstob==1
									egen yearfirstob=max(xyearfirstob), by(muncenso)
									gen yeartimer=yobexp-yearfirstob
									drop xyearfirstob yearfirstob firstob
									foreach n in `catchlag' {
									egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
									egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
									gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
									drop xpremeanl`n' premeanl`n'
									}
									drop yeartimer
									qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'   i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
									outreg2 `rhs2' `controlinteract'  `lags' `interactlister'  `lagleveldirect'   using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
									drop `yeartrend'zl`catchlag'`catchlist' 
									}
			
			
			}
			



	

	
	*additional linear time trend
	if `lineartrendon'==1 & "`lags'"=="" {
	cap gen `yeartrend'z=`yeartrend'
	qui xi: `regtype'  `lhs' `rhs2' `lags'  `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z    i.state*i.`yeartrend'    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
	outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("OLSLIN `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
	drop `yeartrend'z
	}
	
		*additional linear time trend
		if `lineartrendstatefeon'==1 & "`lags'"=="" {
		cap gen `yeartrend'z=`yeartrend'
		qui xi: `regtype'  `lhs' `rhs2' `lags'  `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z   i.`yeartrend'    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
		outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("OLSLINnostatFE `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
		drop `yeartrend'z
		}

		*Arrelano  Bond with First dif
		if `firstdif'==1 & "`lags'"!="" {
		qui xi: xtivreg2  d.`lhs' d.(`rhs2')       i.yobexp (d.(`lags') = d.l`lagcount'.(`lags') )   `iffy'  [aweight=`regweight'],fe robust cluster(muncenso)  
		outreg2 d.(`rhs2')  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("FirstdifAB `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
		}



			*additional trends to pick up catchup growth: this uses initial schooling if there are no LDV's while above I have a 5 year lag average that might be more sensible
			if `catchupon'==1 & "`lags'"!="" {
			cap gen `yeartrend'z=`yeartrend'
			local lagger1=word("`lags'",1)
			gen `yeartrend'z`lagger1'=`yeartrend'*`lagger1'
			qui xi: `regtype'  `lhs' `rhs2' `lags'  `control2' `control' `controlinteract'    i.state*i.`yeartrend' i.state|`yeartrend'z`lagger1'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
			outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
			drop `yeartrend'z `yeartrend'z`lagger1'
			}
									if `catchupon'==1 & "`lags'"=="" {
									
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
									gen xyearfirstob=`yeartrend' if firstob==1
									egen yearfirstob=max(xyearfirstob), by(muncenso)
									gen yeartimer=yobexp-yearfirstob
									drop xyearfirstob yearfirstob firstob
									foreach n in `catchlag' {
									egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
									egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
									gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
									drop xpremeanl`n' premeanl`n'
									}
									drop yeartimer
									qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
									outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
									drop `yeartrend'zl`catchlag'`catchlist' 
									}


		if `nostatefe'==1 {

			*additional trends to pick up catchup growth: this uses initial schooling if there are no LDV's while above I have a 5 year lag average that might be more sensible
			if `catchupon'==1 & "`lags'"!="" {
			cap gen `yeartrend'z=`yeartrend'
			local lagger1=word("`lags'",1)
			gen `yeartrend'z`lagger1'=`yeartrend'*`lagger1'
			qui xi: `regtype'  `lhs' `rhs2' `lags'  `control2' `control' `controlinteract'    i.state|`yeartrend'z`lagger1'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
			outreg2 `rhs2' `controlinteract'  `lags' using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP NOstateFE `lhs' `shocker' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
			drop `yeartrend'z `yeartrend'z`lagger1'
			}
						
						
															if `catchupon'==1 & "`lags'"=="" {
															if "`iffy'"=="" {
															local ifsterx "if muncenso!=."
															}
															else {
															local ifsterx "`iffy'"
															}									
															cap drop premean*
															local rhsname=word("`rhs2'",1)
															egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
															gen xyearfirstob=`yeartrend' if firstob==1
															egen yearfirstob=max(xyearfirstob), by(muncenso)
															gen yeartimer=yobexp-yearfirstob
															drop xyearfirstob yearfirstob firstob
															foreach n in `catchlag' {
															egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
															egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
															gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
															drop xpremeanl`n' premeanl`n'
															}
															drop yeartimer
															qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'   i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
															outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP OLS INITIAL NOstateFE `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
															drop `yeartrend'zl`catchlag'`catchlist' 
									}
						


		}


}






if  `finalrfspec'==1 & "`linear'"=="_linear" {
*this is linear for speed. also above




noi di "Linear Trend"

local regtype "areg"
local xttype "a(muncenso)"

if "${xtreglinear}"=="1" {
local regtype "xtivreg2"
local xttype "fe"
}

if "${twostagelinear}"=="1" {
local regtype "areg"
local xttype "a(muncenso)"
}






noi di "--------------------------------------------------------------------------"
*noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
*noi di "--------------------------------------------------------------------------"

						if  "`lags'"=="" & "`interactlist'"=="" & `nostatefe'!=1 {

									
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
									gen xyearfirstob=`yeartrend' if firstob==1
									egen yearfirstob=max(xyearfirstob), by(muncenso)
									gen yeartimer=yobexp-yearfirstob
									drop xyearfirstob yearfirstob firstob
									foreach n in `catchlag' {
									egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
									egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
									gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
									drop xpremeanl`n' premeanl`n'
									}
									drop yeartimer	
									
									*noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  "
									

									
									noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
									noi di "--------------------------------------------------------------------------"
									
									
																		if "`residualreg'"=="1" {
																		*only works with one rhs variable
																		noi di "Here we get residuals and make graphs"
																		drop if `rhs2'==.
																		qui xi: `regtype'  `lhs'  `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  									
																		predict double lhsresid, residuals
																		egen sdlhsresid=sd(lhsresid), by(muncenso)
																		gen nlhsresid=lhsresid/sdlhsresid									
																		qui xi: `regtype'   `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
																		predict double rhsresid, residuals
																		egen sdrhsresid=sd(rhsresid), by(muncenso)
																		gen nrhsresid=rhsresid/sdrhsresid									
																		egen meanrhs=mean(`rhs2'), by(muncenso)
																		
																		gen mun_original=muncenso
																		
																		_pctile  meanrhs, p(98.34)  // top 30
																		*_pctile  meanrhs, p(98.893805)   // top 20
																		replace muncenso=. if meanrhs<`r(r1)' | meanrhs==.
																		qui do "${dir}labelcensomun_incZM.do"
																		label values muncenso mun
 
																		twoway line  nlhsresid year ||  line  nrhsresid year, lpattern(shortdash) xlabel(1986 1990 1994 1998) ylabel(#3)  legend( symxsize(*.5) size(small) order(1 2 ) label(1 "Cohort Average Education") label(2 "Net New Export Jobs")) xtitle("Year Cohort Aged 16",size(small)) ytitle("Cohort Average Education (Normalized Residuals)", size(small))  by(muncenso, graphregion(margin(tiny)) noiyaxes yrescale note("") r1title("Net New Jobs Per Worker (Normalized Residuals)",size(small)))
																		graph save "${graphdir}residual_graph_`lhs'_`rhs2'_`linear'_top20", replace
																		graph export "${graphdir}residual_graph_`lhs'_`rhs2'_`linear'_top20.pdf", replace
																		
																		replace muncenso=mun_original
																		drop mun_original
																		*pause here
																		/*
																		replace muncenso=. if muncenso!=41
																		twoway line  nlhsresid year ||  line  nrhsresid year, lpattern(shortdash) xlabel(1987 1991 1995 1999) ylabel(#3)  legend( symxsize(*.5) size(small) order(1 2 ) label(1 "Cohort Average Education") label(2 "Net New Export Jobs")) xtitle("Year Cohort Aged 16",size(small)) ytitle("Cohort Average Education (Normalized Residuals)", size(small))  by(muncenso, graphregion(margin(tiny)) noiyaxes yrescale note("") r1title("Net New Jobs Per Worker (Normalized Residuals)",size(small)))
																		graph save "${graphdir}residual_graph_`lhs'_`rhs2'_`linear'_matamoros", replace
																		graph export "${graphdir}residual_graph_`lhs'_`rhs2'_`linear'_matamoros.pdf", replace
																		pause on
																		pause here 
																		*/
																		drop meanrhs *resid*
																		}
																		else {
									ds `lhs'
									local reallhs "`r(varlist)'"
									
									
									if "${manual}"=="1" {
									noi di `"qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"'
									pause on
									pause run regressions
									}

									


									if "${norhs}"=="1" {
									local tempfrog "`rhs2'"
									local rhs2 ""
									noi di "No RHS on: xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
									noi di "--------------------------------------------------------------------------"									
									}
			


									if "${sexmix}"=="1" & "${sexfixedeffects}"=="1" {
									local muntrendtype "muncensonosex"
									}
									else {
									local muntrendtype "muncenso"
									}


			if "${twostagelinear}"=="1" {
			

	
				
				

				
				gen okobs=1 if ${twostagestarter}
				
				gen okobs2=okobs
				
				noi di "here we go"
				local listmun ""
				local listmuns1 ""
				*local listmuns ""
				
				 
				levelsof muncenso if (okobs2!=1), local(errormunA)

				
				noi di "`errormunA'"

				qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.`muntrendtype'|`yeartrend'z    i.state*i.`yeartrend'       `iffy' & (okobs2==1) [aweight=`regweight'], `xttype' robust cluster(muncenso)  
				qui outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_zz`regname'", title("") ctitle("start")    nonotes excel nocons 				
				
									if "$testes"=="1" {
														
														pause on
														pause here 
									}				
				
				
				forval q=1/7 {
				local errormunA ""
				
				levelsof muncenso if (okobs2!=1), local(errormunA)			
				noi di "Run `q': still not working: `errormunA'"
				
				foreach nnn in 	`errormunA'    {  

					qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.`muntrendtype'|`yeartrend'z    i.state*i.`yeartrend'       `iffy' & (okobs2==1  | muncenso==`nnn') [aweight=`regweight'], `xttype' robust cluster(muncenso)  
					qui outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_zz`regname'", title("") ctitle("`nnn'")    nonotes excel nocons 									
					local se1=_se[_cons]
					if  `se1'!=0 {
						replace okobs2=1 if muncenso==`nnn'
						noi di "`nnn': pass"
						}
						else {
						noi di "`nnn': fail"
						}
				

				
								}
				
				}
				
				levelsof muncenso if (okobs!=1), local(errormunfinal)
				
				noi di "FINAL FAIL (7 reps):" 
				noi di "`errormunfinal'"
				*/

				
			pause on
			pause here 
			
			drop okobs*
			}
			
			if "$crudeiv"=="1" {
			local rhsinst=subinstr("`rhs2'","2s_50","9s_50",.)
			local rhsinst=subinstr("`rhsinst'","2c_50","9c_50",.)
			noi di "xi: xtivreg2  `lhs'  `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'    (`rhs2'=`rhsinst')   `iffy'  [aweight=`regweight'], fe robust cluster(muncenso)"
			
			qui xi: xtivreg2  `lhs'  `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'    (`rhs2'=`rhsinst')   `iffy'  [aweight=`regweight'], fe robust cluster(muncenso)  first
			outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS IV INITIAL `reallhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
	
			}
			
						if "$bartikiv"=="1" {
						local rhsinst=subinstr("`rhs2'","${pre}`lgender'","d`lgender'",.)
						local rhsinst=subinstr("`rhsinst'","x50","50",.)
						local rhsinst=subinstr("`rhsinst'","`lgender'x","`lgender'",.)
						noi di "xi: xtivreg2  `lhs'  `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'    (`rhsinst'=`rhs2')   `iffy'  [aweight=`regweight'], fe robust cluster(muncenso)"
						
						qui xi: xtivreg2  `lhs'  `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'    (`rhsinst'=`rhs2')   `iffy'  [aweight=`regweight'], fe robust cluster(muncenso)  first
						outreg2 `rhsinst' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS IV INITIAL `reallhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
				
						}			
						
									

									
									if "$manualx"=="1" {
									
									no di "qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) "
									pause on
									pause here 
									}
									

									
									*******************main event linear******************************
									
									/**
									noi di "reghdfe version"
	
									egen state`yeartrend'=group(state `yeartrend')
									gen `regweight'2=round(`regweight'*1000)
									cap replace eclwtyrschl2=. if eclwtyrschl2==0
									
																		if "$manual"=="1" {

																		
																		
																		no di "reghdfe     `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'   i.`muntrendtype'#c.`yeartrend'z     `iffy'  [aweight=`regweight'2], a(muncenso stateyobexp )  vce(cluster muncenso)"
																		
																		
																		}
									
									reghdfe     `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'   i.`muntrendtype'#c.`yeartrend'z     `iffy'  [aweight=`regweight'2], a(muncenso stateyobexp )  vce(cluster muncenso)
									drop `regweight'2
									drop state`yeartrend'
									****DGA XXXX
									**/
									
									
									qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.`muntrendtype'|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
									outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL `reallhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
									
									*******************Main event******************************
									
									
									if "$bigout"=="1" {
									outreg2  using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL `reallhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
									}
									if "$testes"=="1" {
														
														pause on
														pause here 
									}
					


					if "$counterfactsimple"=="1" {
			

					local skilllist${nonexportpure} ""
					local skillexplist${export} ""
					local skilllist${export} ""
					
					matrix A=e(b)
					
					tokenize `controlinteract' 
					*can take control lists with up to 20 variables
					forval n= 1/25 {
					local inter_`n' "``n''"
					local inter${nonexportpure}_`n': subinstr local inter_`n' "${nonexport}${mpop}" "${nonexportpure}${mpop}", all
					local inter${export}_`n': subinstr local inter_`n' "${nonexport}${mpop}" "${export}${mpop}", all
					}
					
					local wordy : word count `controlinteract'
					*if ends with exports knock that puppy off
					if regexm("``wordy''","q`aget'd${dempbit}emp50${export}${mpop}")==1 {
					noi di "export"
					local wordym1=`wordy'-1
					}
					else {
					noi di "noexport"
					local wordym1=`wordy'
					}

					forval n=1/`wordym1' {
					local skilllist${export} "`skilllist${export}'+A[1,`n']*`inter${export}_`n''"
					local skilllist${nonexportpure} "`skilllist${nonexportpure}'+A[1,`n']*`inter${nonexportpure}_`n''"
					}

					egen  q`aget'd${dempbit}emp50${nonexportpure}${mpop}wtmean=wtmean(q`aget'd${dempbit}emp50${nonexportpure}${mpop}) `iffy', weight(`regweight')
					egen  q`aget'd${dempbit}emp50${export}${mpop}wtmean=wtmean(q`aget'd${dempbit}emp50${export}${mpop}) `iffy', weight(`regweight')
					
					gen skillinteract${nonexportpure}=0`skilllist${nonexportpure}'
					gen wtskillinteract${nonexportpure}=skillinteract${nonexportpure}/q`aget'd${dempbit}emp50${nonexportpure}${mpop}wtmean
					gen skillinteract${export}=0`skilllist${export}'
					gen wtskillinteract${export}=skillinteract${export}/q`aget'd${dempbit}emp50${export}${mpop}wtmean
					
					if "$testes"=="1" {
					noi di "gen skillinteract${export}=0`skilllist${export}'"
					pause on
					pause `skilllist${export}'
					}
					
					if regexm("``wordy''","q`aget'd${dempbit}emp50${export}${mpop}")==1 {
					forval n=1/`wordy' {
					local skillexplist${export} "`skillexplist${export}'+A[1,`n']*`inter${export}_`n''"
					}
					gen skillexpinteract${export}=0`skillexplist${export}'
					gen wtskillexpinteract${export}=skillexpinteract${export}/q`aget'd${dempbit}emp50${export}${mpop}wtmean
					noi mean skillinteract${nonexportpure} wtskillinteract${nonexportpure} skillinteract${export} wtskillinteract${export} skillexpinteract${export} wtskillexpinteract${export} `iffy'  [aweight=`regweight']
					}
					else {
					noi mean skillinteract${nonexportpure} wtskillinteract${nonexportpure} skillinteract${export} wtskillinteract${export}  `iffy'  [aweight=`regweight']					
					}
					
					if "$testes"=="1" {
					noi di "gen skillexpinteract${export}=0`skillexplist${export}'"
					noi di "wtskillexpinteract${export}=skillexpinteract${export}/q`aget'd${dempbit}emp50${export}${mpop}wtmean"
					pause on
					pause `skillexplist${export}' 
					}
					
					outreg2   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL `reallhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")    nonotes excel
					drop q`aget'd${dempbit}emp50${nonexportpure}${mpop}wtmean q`aget'd${dempbit}emp50${export}${mpop}wtmean *skill*interact*
	
					}
					*from counterfact simple
					



																		}
									
															if `allages'==1 {
															foreach thinger in `rhs2' `controlinteract' {
															local contshort=substr("`controlinteract'",1,50)
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Linear") (`aget') (`agefirst') ("co") (_b[`thinger'])  ("`iffy' `contshort'")
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Linear") (`aget') (`agefirst') ("se") (_se[`thinger']) ("`iffy' `contshort'")

															}														
															}								
									
									
											*this runs through the combos stripping out the fes.
											if "`nofeatall'"=="1" { 
											qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'      i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
											outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL no linear mun trend `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
											qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'      i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
											outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL no linear mun trend no stat FE but time dummie `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
											qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
											outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL no linear mun trend no state-time dummies or time dummies `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
											qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'      i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], a(`yeartrend') robust cluster(muncenso)  
											outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL no linear mun trend no mun FE `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons  
											}									
									
									if "${norhs}"=="1" {
									local rhs2 "`tempfrog'"
									local tempfrog ""
									}
									
									drop `yeartrend'zl`catchlag'`catchlist' 
									
									}

						if "`lags'"=="" & "`interactlist'"=="" & `nostatefe'==1  {

						
															if "`iffy'"=="" {
															local ifsterx "if muncenso!=."
															}
															else {
															local ifsterx "`iffy'"
															}									
															cap drop premean*
															local rhsname=word("`rhs2'",1)
															egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
 
															gen xyearfirstob=`yeartrend' if firstob==1
															egen yearfirstob=max(xyearfirstob), by(muncenso)
															gen yeartimer=yobexp-yearfirstob
															drop xyearfirstob yearfirstob firstob
															foreach n in `catchlag' {
															egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
															egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
															gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
															drop xpremeanl`n' premeanl`n'
															}
															drop yeartimer
															if "$dropdeltaemp20zero"=="1" {
																								*egen totq1516deltaemp5020mpop=total(q1516deltaemp5020mpop), by(muncenso)
																								*drop if totq1516deltaemp5020mpop==0
																								egen mungroup=group(muncenso)
																								bsample 1000, cluster(mungroup)
															}
															

															
															noi di "qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z    i.`yeartrend'      `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
															noi di "--------------------------------------------------------------------------"
															
															qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z    i.`yeartrend'      `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
															outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL NOstateFE `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
															drop `yeartrend'zl`catchlag'`catchlist' 
															
									if "$testes"=="1" {
														
														pause on
														pause here 
									}						

						}
						
						
						

*Interactlist
			if  "`interactlist'"!="" & "`lags'"=="" {
			local interactlister ""
			local wordcountsrhs=wordcount("`rhs2'")
			local wordcountsshock=wordcount("`shocker'")
			local wordcountsind=wordcount("`indlist'")
			local wordcountsinteract=wordcount("`interactlist'")
			local starter=1
			local ender=`wordcountsind'*`wordcountsshock'-`wordcountsind'+1
			
			tokenize `rhs2' 
			local wordcountsrhsp1=`wordcountsrhs'+1
			local wordcountsrhspend=`wordcountsrhs'*`wordcountsinteract'
			
			
			forval n=`wordcountsrhsp1'/`wordcountsrhspend' {
			local numbers=`n'-`wordcountsrhs'
			local `n'="``numbers''"
			}
			*this allows multiple interactions by repeating the shocks
			
			local outreglist ""
			foreach inter in `interactrun' {
				forval n=`starter'(`wordcountsind')`ender' {
				if regexm("`inter'","^i\.")!=1   & regexm("`inter'","^ib.\.")!=1 {
				local interactlister "`interactlister'  c.`inter'#c.(``n'')"
				}
				else {
				local interactlister "`interactlister'  `inter'|``n''"
				local 5dig=substr("`inter'",3,3) 
				*local 5dig=substr("``n''",1,4)
				local outreglist "`outreglist' *`5dig'*"
				}
				}
			local starter=`starter'+1
			local ender=`ender'+1
			}
			*doesnt even work if there are two shockers (hire and fire),or maybe it does
			*say shocker=3... want 1-3 with interact 1, 4-6 with interact 2 etc  so want indlist 1 indlist 4 indlist 7 etc with first
			noi di "--------------------------------------------------------------------------"
			*noi di "INTERACTION: xi: `regtype'  `lhs'  `rhs2' `interactlister' `lags' `control2' `control' `controlinteract'   i.muncenso|`yeartrend'z    i.state*i.`yeartrend'  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"
			*noi di "--------------------------------------------------------------------------"
			
			
												if `catchupon'==1 & "`lags'"=="" {
			

									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 

												gen xyearfirstob=`yeartrend' if firstob==1
												egen yearfirstob=max(xyearfirstob), by(muncenso)
												gen yeartimer=yobexp-yearfirstob
												drop xyearfirstob yearfirstob firstob
												foreach n in `catchlag' {
												egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
												egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
												gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
												drop xpremeanl`n' premeanl`n'
												}
												drop yeartimer
												
																					
																					if "${manual}"=="1" {
																					noi di "xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"
																					
																					noi di "outreg2 `rhs2' `controlinteract'  `lags' `interactlister' `outreglist'"
																					pause on
																					pause here 
																					}
												noi di "INTERACTION: xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'   `lagleveldirect'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'         `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  "
												noi di "--------------------------------------------------------------------------"



												
												if "`sexinteract'"=="1" & "`sexx'"=="emp" {
												if ("${sextrend}"=="" | "${sexcluster}"=="" | "${sexfe}"=="" )  need_to_specify_sexcluster_sexfe_and_sextrend_globals 
												noi di "xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.${sextrend}|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], a(${sexfe}) robust cluster(${sexcluster})  "
												qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  i.${sextrend}|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], a(${sexfe}) robust cluster(${sexcluster})  
												}
												else {
												qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  										
												*qui  `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  i.muncenso#c.`yeartrend'z    i.state##i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  										
												}
												
														if "$testes"=="1" {
																noi di "controlinteract: `controlinteract'"	
																noi di "interactlister: `interactlister'"
																noi di "outreglist: `outreglist'"
																			pause on
																			pause here 
														}
												
												outreg2 `rhs2' `controlinteract'  `lags' `interactlister' `outreglist'  `lagleveldirect'   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
												drop `yeartrend'zl`catchlag'`catchlist' 

															if `allages'==1 {
															local interactlisterx: subinstr local interactlister "(" "", all
															local interactlisterx: subinstr local interactlisterx ")" "", all
															foreach thinger in `rhs2' `interactlisterx' `controlinteract' {
															local contshort=substr("`controlinteract'",1,50)
															local intshort=substr("`interactlisterx'",1,50)
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Linear") (`aget') (`agefirst') ("co") (_b[`thinger'])  ("`iffy' `contshort' `intshort'")
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Linear") (`aget') (`agefirst') ("se") (_se[`thinger']) ("`iffy' `contshort' `intshort'")
															}
															}
												
												
									
								
									
									}
			
			
			
			}
			
			
			

}








if  `finalrfspec'==1 & ("`linear'"=="" | "`linear'"=="_catchup" ) {
*this is currently catchup with not LDV
noi di "Catchup Trend"

local regtype "areg"
local xttype "a(muncenso)"


						if `catchupon'==1 & "`lags'"=="" & "`interactlist'"=="" {

noi di "--------------------------------------------------------------------------"
noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
noi di "--------------------------------------------------------------------------"
									
									
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}
									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
									gen xyearfirstob=`yeartrend' if firstob==1
									egen yearfirstob=max(xyearfirstob), by(muncenso)
									gen yeartimer=yobexp-yearfirstob
									drop xyearfirstob yearfirstob firstob
									foreach n in `catchlag' {
									egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
									egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
									gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
									drop xpremeanl`n' 
									}
									drop yeartimer	
									
											if "${manual}"=="1" {
											noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)    "
											noi di "manualstylez"
											*noi xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) 
											
											fvrevar i.state#i.`yeartrend' i.state#c.`yeartrend'zl`catchlag'`catchlist'  
											
											noi di "areg  `lhs' __* `rhs2' `lags'   `control2' `control' `controlinteract' `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)    "
											pause on
											pause here 									
											
 
											pause on
											pause here 
											set more on
											noi xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
											set more off
											pause on
											pause pre reg 
											}
									
									if "${norhs}"=="1" {
									local tempfrog "`rhs2'"
									local rhs2 ""
									noi di "No RHS on: xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.muncenso|`yeartrend'z    i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
									noi di "--------------------------------------------------------------------------"									
									}

									
									if "$manualx"=="1" {
									
									no di "	qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  "
									die like a dog in war
									pause on
									pause here 
									}

									****catchup main event******
									qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
									



											if "${manual}"=="1" {
											
											
											
													*pause on
													*pause reg run
																								pause here 
															}
									
									outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 

					if "$counterfactsimple"=="1" {

					local skilllist${nonexportpure} ""
					local skillexplist${export} ""
					local skilllist${export} ""
					
					matrix A=e(b)
					
					tokenize `controlinteract' 
					*can take control lists with up to 20 variables
					forval n= 1/25 {
					local inter_`n' "``n''"
					local inter${nonexportpure}_`n': subinstr local inter_`n' "${nonexport}${mpop}" "${nonexportpure}${mpop}", all
					local inter${export}_`n': subinstr local inter_`n' "${nonexport}${mpop}" "${export}${mpop}", all
					}
					
					local wordy : word count `controlinteract'
					*if ends with exports knock that puppy off
					if regexm("``wordy''","q`aget'd${dempbit}emp50${export}${mpop}")==1 {
					noi di "export"
					local wordym1=`wordy'-1
					}
					else {
					noi di "noexport"
					local wordym1=`wordy'
					}

					forval n=1/`wordym1' {
					local skilllist${export} "`skilllist${export}'+A[1,`n']*`inter${export}_`n''"
					local skilllist${nonexportpure} "`skilllist${nonexportpure}'+A[1,`n']*`inter${nonexportpure}_`n''"
					}
					
					egen  q`aget'd${dempbit}emp50${nonexportpure}${mpop}wtmean=wtmean(q`aget'd${dempbit}emp50${nonexportpure}${mpop}) `iffy', weight(`regweight')
					egen  q`aget'd${dempbit}emp50${export}${mpop}wtmean=wtmean(q`aget'd${dempbit}emp50${export}${mpop}) `iffy', weight(`regweight')

					gen skillinteract${nonexportpure}=0`skilllist${nonexportpure}'
					gen wtskillinteract${nonexportpure}=skillinteract${nonexportpure}/q`aget'd${dempbit}emp50${nonexportpure}${mpop}wtmean
					gen skillinteract${export}=0`skilllist${export}'
					gen wtskillinteract${export}=skillinteract${export}/q`aget'd${dempbit}emp50${export}${mpop}wtmean
					
					if regexm("``wordy''","q`aget'd${dempbit}emp50${export}${mpop}")==1 {
					forval n=1/`wordy' {
					local skillexplist${export} "`skillexplist${export}'+A[1,`n']*`inter${export}_`n''"
					}
					gen skillexpinteract${export}=0`skillexplist${export}'
					gen wtskillexpinteract${export}=skillexpinteract${export}/q`aget'd${dempbit}emp50${export}${mpop}wtmean
					noi mean skillinteract${nonexportpure} wtskillinteract${nonexportpure} skillinteract${export} wtskillinteract${export} skillexpinteract${export} wtskillexpinteract${export} `iffy'  [aweight=`regweight']
					}
					else {
					noi mean skillinteract${nonexportpure} wtskillinteract${nonexportpure} skillinteract${export} wtskillinteract${export}  `iffy'  [aweight=`regweight']					
					}

					outreg2   using "${dirtemp}elrd_`regname'", title("") ctitle("LINEAR OLS INITIAL `reallhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")    nonotes excel
					drop q`aget'd${dempbit}emp50${nonexportpure}${mpop}wtmean q`aget'd${dempbit}emp50${export}${mpop}wtmean *skill*interact*

					}
					*from counterfact simple



															
															if `allages'==1 {
															foreach thinger in `rhs2' `controlinteract' {
															local contshort=substr("`controlinteract'",1,50)
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Catchup`catchlag'") (`aget') (`agefirst') ("co") (_b[`thinger'])  ("`iffy' `contshort'")
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Catchup`catchlag'") (`aget') (`agefirst') ("se") (_se[`thinger']) ("`iffy' `contshort'")
															}														
															}									
									
									if "${norhs}"=="1" {
									local rhs2 "`tempfrog'"
									local tempfrog ""
									}
									
									drop `yeartrend'zl`catchlag'`catchlist' 
									}

		if `nostatefe'==1 {

						if `catchupon'==1 & "`lags'"==""  & "`interactlist'"=="" {
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 

															gen xyearfirstob=`yeartrend' if firstob==1
															egen yearfirstob=max(xyearfirstob), by(muncenso)
															gen yeartimer=yobexp-yearfirstob
															drop xyearfirstob yearfirstob firstob
															foreach n in `catchlag' {
															egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
															egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
															gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
															drop xpremeanl`n' premeanl`n'
															}
															drop yeartimer
															qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'   i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
													
															outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP OLS INITIAL NOstateFE `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 

															
															drop `yeartrend'zl`catchlag'`catchlist' 
						}

		}			

*Interactlist
			if `catchupon'==1 & "`interactlist'"!="" & "`lags'"=="" {
			local interactlister ""
			local wordcountsrhs=wordcount("`rhs2'")
			local wordcountsshock=wordcount("`shocker'")
			local wordcountsind=wordcount("`indlist'")
			local wordcountsinteract=wordcount("`interactlist'")
			local starter=1
			local ender=`wordcountsind'*`wordcountsshock'-`wordcountsind'+1
			
			tokenize `rhs2' 
			local wordcountsrhsp1=`wordcountsrhs'+1
			local wordcountsrhspend=`wordcountsrhs'*`wordcountsinteract'
			
			
			forval n=`wordcountsrhsp1'/`wordcountsrhspend' {
			local numbers=`n'-`wordcountsrhs'
			local `n'="``numbers''"
			}
			*this allows multiple interactions by repeating the shocks
			
			
			foreach inter in `interactrun' {
				forval n=`starter'(`wordcountsind')`ender' {
				if regexm("`inter'","^i\.")!=1   & regexm("`inter'","^ib.\.")!=1 {
				local interactlister "`interactlister'  c.`inter'#c.(``n'')"
				}
				else {
				local interactlister "`interactlister'  `inter'#c.(``n'')"
				}
				}
			local starter=`starter'+1
			local ender=`ender'+1
			}
			*doesnt even work if there are two shockers (hire and fire),or maybe it does
			*say shocker=3... want 1-3 with interact 1, 4-6 with interact 2 etc  so want indlist 1 indlist 4 indlist 7 etc with first
			noi di "--------------------------------------------------------------------------"
			noi di "INTERACTION: xi: `regtype'  `lhs'  `rhs2' `interactlister' `lags' `control2' `control' `controlinteract'  `lagleveldirect'   i.state*i.`yeartrend'  i.state|`yeartrend'zl0`reglist'  `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"
			noi di "--------------------------------------------------------------------------"
			
			
												if `catchupon'==1 & "`lags'"=="" {
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
												gen xyearfirstob=`yeartrend' if firstob==1
												egen yearfirstob=max(xyearfirstob), by(muncenso)
												gen yeartimer=yobexp-yearfirstob
												drop xyearfirstob yearfirstob firstob
												foreach n in `catchlag' {
												egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
												egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
												gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
												drop xpremeanl`n' premeanl`n'
												}
												drop yeartimer
												

														if "${manual}"=="1" {
														noi di "qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"  
														set more on
														noi xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
														set more off
														pause on
														pause here 
														}
												
												qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
												outreg2 `rhs2' `controlinteract'  `lags' `interactlister'  `lagleveldirect'  using "${dirtemp}elrd_`regname'", title("") ctitle("CATCHUP OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
												drop `yeartrend'zl`catchlag'`catchlist' 
									
															if `allages'==1 {
															local interactlisterx: subinstr local interactlister "(" "", all
															local interactlisterx: subinstr local interactlisterx ")" "", all															
															foreach thinger in `rhs2' `interactlisterx' `controlinteract' {
															local contshort=substr("`controlinteract'",1,50)
															local intshort=substr("`interactlisterx'",1,50)
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Catchup`catchlag'") (`aget') (`agefirst') ("co") (_b[`thinger'])  ("`iffy' `contshort' `intshort'")
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Catchup`catchlag'") (`aget') (`agefirst') ("se") (_se[`thinger']) ("`iffy' `contshort' `intshort'")
															}
															}
								
									
									}
			
			
			
			}
			
			
			

}





if  `finalrfspec'==1 & ("`linear'"=="pretrend" | "`linear'"=="_pretrend" ) {
*this is currently taking a linear trend estimated from difference between catchlag years before and 2 catchlag years before.
noi di "Pre-Trend"

local regtype "areg"
local xttype "a(muncenso)"

						if `catchupon'==1 & "`lags'"=="" & "`interactlist'"=="" {

noi di "--------------------------------------------------------------------------"
noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
noi di "--------------------------------------------------------------------------"
									
									
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}
									
					
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
									gen xyearfirstob=`yeartrend' if firstob==1
									egen yearfirstob=max(xyearfirstob), by(muncenso)
									gen yeartimer=yobexp-yearfirstob
									drop xyearfirstob yearfirstob firstob
									foreach n in `catchlag' {
									egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
									egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
									local n2=2*`n'
									egen xpremeanl`n2'=wtmean(`catchlist')  if yeartimer<-`n' & yeartimer>=-`n2',by(muncenso) weight(`catchweight')
									egen premeanl`n2'=max(xpremeanl`n2'), by(muncenso)									
									gen `yeartrend'zl`n'`catchlist'=`yeartrend'*(premeanl`n'-premeanl`n2')/`n'
									drop xpremeanl`n'  xpremeanl`n2' 
									}
									drop yeartimer	
									
											if "${manual}"=="1" {
											noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)    "
											pause on
											pause here 
											}
									
									qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend' i.state|`yeartrend'zl`catchlag'`catchlist'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
									outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("PRETREND OLS INITIAL `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
									
															
															if `allages'==1 {
															foreach thinger in `rhs2' `controlinteract' {
															local contshort=substr("`controlinteract'",1,50)
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Pretrend`catchlag'") (`aget') (`agefirst') ("co") (_b[`thinger'])  ("`iffy' `contshort'")
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("Pretrend`catchlag'") (`aget') (`agefirst') ("se") (_se[`thinger']) ("`iffy' `contshort'")
															}														
															}									

									
									
									drop `yeartrend'zl`catchlag'`catchlist' 
									}
}




if  `finalrfspec'==1 & ("`linear'"=="_notrend" | "`linear'"=="notrend" ) {
*this is currently catchup with not LDV
noi di "No Trend"

local regtype "areg"
local xttype "a(muncenso)"

						if `catchupon'==1 & "`lags'"=="" & "`interactlist'"=="" {

noi di "--------------------------------------------------------------------------"
noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend'       `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso) " 
noi di "--------------------------------------------------------------------------"

									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 
 
									gen xyearfirstob=`yeartrend' if firstob==1
									egen yearfirstob=max(xyearfirstob), by(muncenso)
									gen yeartimer=yobexp-yearfirstob
									drop xyearfirstob yearfirstob firstob
									foreach n in `catchlag' {
									egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
									egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
									gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
									drop xpremeanl`n' 
									}
									drop yeartimer									
											if "${manual}"=="1" {
											noi di "xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)    "
											pause on
											pause here 
											}
									
									qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'  i.state*i.`yeartrend'        `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
									outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("NO TREND OLS `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
									
															if `allages'==1 {
															foreach thinger in `rhs2'  `controlinteract' {
															local contshort=substr("`controlinteract'",1,50)
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("NO TREND OLS") (`aget') (`agefirst') ("co") (_b[`thinger'])  ("`iffy' `contshort'")
															cap post dog ("`thinger'") ("`shocker'") ("`lhs'") ("`indlist'") ("NO TREND OLS") (`aget') (`agefirst') ("se") (_se[`thinger']) ("`iffy' `contshort'")
															}														
															}															
									
									
									drop `yeartrend'zl`catchlag'`catchlist' 
									}

		if `nostatefe'==1 {

						if `catchupon'==1 & "`lags'"==""  & "`interactlist'"=="" {
									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 

															gen xyearfirstob=`yeartrend' if firstob==1
															egen yearfirstob=max(xyearfirstob), by(muncenso)
															gen yeartimer=yobexp-yearfirstob
															drop xyearfirstob yearfirstob firstob
															foreach n in `catchlag' {
															egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
															egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
															gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
															drop xpremeanl`n' premeanl`n'
															}
															drop yeartimer
															qui xi: `regtype'  `lhs' `rhs2' `lags'   `control2' `control' `controlinteract'           `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
															outreg2 `rhs2' `controlinteract'  `lags'   using "${dirtemp}elrd_`regname'", title("") ctitle("NO TREND OLS NOstateFE `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 

															
															drop `yeartrend'zl`catchlag'`catchlist' 
						}

		}			

*Interactlist
			if `catchupon'==1 & "`interactlist'"!="" & "`lags'"=="" {
			local interactlister ""
			local wordcountsrhs=wordcount("`rhs2'")
			local wordcountsshock=wordcount("`shocker'")
			local wordcountsind=wordcount("`indlist'")
			local wordcountsinteract=wordcount("`interactlist'")
			local starter=1
			local ender=`wordcountsind'*`wordcountsshock'-`wordcountsind'+1
			
			tokenize `rhs2' 
			local wordcountsrhsp1=`wordcountsrhs'+1
			local wordcountsrhspend=`wordcountsrhs'*`wordcountsinteract'
			
			
			forval n=`wordcountsrhsp1'/`wordcountsrhspend' {
			local numbers=`n'-`wordcountsrhs'
			local `n'="``numbers''"
			}
			*this allows multiple interactions by repeating the shocks
			
			
			foreach inter in `interactrun' {
				forval n=`starter'(`wordcountsind')`ender' {
				if regexm("`inter'","^i\.")!=1   & regexm("`inter'","^ib.\.")!=1 {
				local interactlister "`interactlister'  c.`inter'#c.(``n'')"
				}
				else {
				local interactlister "`interactlister'  `inter'#c.(``n'')"
				}
				}
			local starter=`starter'+1
			local ender=`ender'+1
			}
			*doesnt even work if there are two shockers (hire and fire),or maybe it does
			*say shocker=3... want 1-3 with interact 1, 4-6 with interact 2 etc  so want indlist 1 indlist 4 indlist 7 etc with first
			noi di "--------------------------------------------------------------------------"
			noi di "INTERACTION: xi: `regtype'  `lhs'  `rhs2' `interactlister' `lags' `control2' `control' `controlinteract'   `lagleveldirect'  i.state*i.`yeartrend'    `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)"
			noi di "--------------------------------------------------------------------------"
			
			
												if `catchupon'==1 & "`lags'"=="" {
			

									if "`iffy'"=="" {
									local ifsterx "if muncenso!=."
									}
									else {
									local ifsterx "`iffy'"
									}									
									cap drop premean*
									local rhsname=word("`rhs2'",1)
									egen firstob=tag(muncenso) `ifsterx' & `rhsname'!=. 

												gen xyearfirstob=`yeartrend' if firstob==1
												egen yearfirstob=max(xyearfirstob), by(muncenso)
												gen yeartimer=yobexp-yearfirstob
												drop xyearfirstob yearfirstob firstob
												foreach n in `catchlag' {
												egen xpremeanl`n'=wtmean(`catchlist')  if yeartimer<0 & yeartimer>=-`n',by(muncenso) weight(`catchweight')
												egen premeanl`n'=max(xpremeanl`n'), by(muncenso)
												gen `yeartrend'zl`n'`catchlist'=`yeartrend'*premeanl`n'
												drop xpremeanl`n' premeanl`n'
												}
												drop yeartimer
												
																					
																					if "${manual}"=="1" {
																					noi di "qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.state*i.`yeartrend'         `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  "
																					pause on
																					pause here 
																					}
												
												qui xi: `regtype'  `lhs' `rhs2' `lags' `interactlister'  `control2' `control' `controlinteract'  `lagleveldirect'  i.state*i.`yeartrend'         `iffy'  [aweight=`regweight'], `xttype' robust cluster(muncenso)  
												outreg2 `rhs2' `controlinteract'  `lags' `interactlister'  `lagleveldirect'  using "${dirtemp}elrd_`regname'", title("") ctitle("NO TREND OLS `lhs' `shocker' catch`catchlag'`catchlist' linear stated `iffy' `regweight'")   addstat("Municipalities", `e(N_clust)')  nonotes excel nocons 
												drop `yeartrend'zl`catchlag'`catchlist' 
									
								
									
									}
			
			
			
			}
			
			
 

}

























































*this adds a progressa dummy and an rural percentage indicator interacted with year dummies
				
cap drop l?`lhs'
cap drop mean?l`lhs'
local controlinteract "`controlinteracttemp'"



						}
						*iffy

			}
			*lhs					

}
				*rhsinst
					
				}
				*rhs

*}
*from bartype
}
*from lags
}
*from remainderon

}
*from contorlinteract
}
*from interactlist
}
*from shocker



}
*from reglist


cap copy "${dirtemp}elrd_`regname'.xml" "${dirrev}elrd_`regname'.xml", replace
if _rc!=0 {
sleep 10000
cap copy "${dirtemp}elrd_`regname'.xml" "${dirrev}elrd_`regname'.xml", replace
}

cap copy "${dirtemp}elrd_`regname'.txt" "${dirrev}elrd_`regname'.txt", replace
if _rc!=0 {
sleep 10000
cap copy "${dirtemp}elrd_`regname'.txt" "${dirrev}elrd_`regname'.txt", replace
}

}
*from aget

}
*from indlist
cap postclose dog
cap copy "${dirtemp}AllAges_`regname'.dta" "${dirrev}AllAges_`regname'.dta", replace

// may11



}
*from edit 


}
*from sex


}
*from qui



