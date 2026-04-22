*This generates all the key tables:
qui {
clear
cap clear matrix
set mem 1000m
set matsize 10000
set maxvar 10000
set  more off

if "`c(os)'"=="Unix" {
global scratch="/home/fac/da334/Data/Mexico/Stata10/"
global dirnet="/home/fac/da334/Work/Mexico/regout/"
}

if "`c(os)'"=="Windows" {
global dirnet="C:/Work/Mexico/regout/"
global scratch="C:/Data/Mexico/Stata10/"
global dirtemp="C:/Scratch/"
global dir="C:/Work/Mexico/"
global dircode="C:/Work/Mexico/Revision/New_code/"
global dirrev="C:/Work/Mexico/Revision/regout/"
}



*First I set up the basic globals:
/**=============================================================**/
*Sexes, Industries, Ages
/**=============================================================**/
/**SEXES**/
global sexx "emp" 
global sexinteract=0
*if this takes the value 1, and sexx is emp and interactions are femaale, i do sex interactions with mun-fem fixed effects and i.year-sex*state FE
global indlist  `" "19" "' 
/**AGES OF EXPOSURES**/
global aget  "`mainage'"   
/**MPOP TYPE**/
global mpop "mp"  // this takes mp if used interpolated populations and cp if use basleine populations.
/**=============================================================**/
*File Names
/**=============================================================**/
/**File Used**/
global file "_skillcharbytype"
/**Regression File Name**/
global regname=`"`namer'`rfname'_\`sexx'_\`aget'\`file'_MainXXX_\`indlist'"'
/**Do I want multiple seperate age regs in same table**/
global allages=0
/**=============================================================**/
*Variables
/**=============================================================**/
/**LHS Variables**/
global reglist   `"\`lgender3'clyrschl"'     
/**Weights**/
global weightyrschl=0
*takes the value 1 if want \`lgender3'clyrschl as weights even if LHS is different
/**RHS Variables**/
global shocker `" "delta\`lgender'50" "'  
global interactlist `""""'
global laglevelinteract=0
*this is the type of lag used for the interaction. 0=no lag, 1=2 year lag, 2=initial level
global controlinteract `""""'
global controlinsert ""
global codeinsert1 ""
global codeinsert2 ""
global codeinsert3 ""
global codeinsert4 ""
global laganything ""
*if i want to stick some lag or intial value or mean into the controls, stick it in both laganything and then controlinsert 
*inserts code or extra control just before regs are run
/**=============================================================**/
*Specification Options
/**=============================================================**/
/**RHS Remainder**/
global remainder=13 // could be 99 in old terminologfy
global sexremainder=1
*this takes the value 1 if the remainder term is uses sex specific jobs or all jobs
global remainderon "0" 
*this includes a remainder of jobs term. these can be 50 or 00 jobs
/**Regression Sample**/
global iflist `" "if muncenso!=12" "'  //  "if muncenso!=12 & yobexp<=\`yobmin1990'" 
global mexicocity=0
global weightsquare=0
/**Estimates Include Municiplaity Linear Time Trend or No State Fixed Effects**/
global lineartrendon=1
*this tunrs on the linear municipality time trend
global nostatefe=0
*this tunrs on the "no state-time fixed effects" specification
global lineartrendstatefeon=0
*this removes the state-time fixed effects everywhere and replaces them with time fixed effects and runs linear trend
global firstdif=0
*this turns on Arrelano Bond with first dif. For this to work need inston=0.
global noyearfe=0
*this tunrs on the "no state-time fixed effects" specification with not even any year fixed effects
global catchupon=1
global catchlag=2
global catchlist="" //  "\`lgender3'clyrschl" 
*this turns on catchup specifications. With lags this includes the l.`catchlist'*yobexp*i.state. Without lages this includes l.`catchlist'(avreage over `catchlag' years before sample)*yobexp*i.state. Defaults to lag of two for dependent variable.
global finalrfspec=1
*this only runs the final reduced form specs for every regression (currently fe catchup or linear)
global nofeatall=0
*if this is one, then i run 5 alterante specifications sequentially dropping fixed effects. Only works with finalrfspec==_linear and no interactions and statefe on
global manual=0
global linear="_linear"
*this is _linear for rf linear specification, and blank for catchup
global residualreg=0
*if this is 1-run residual graph but need only one rhs...
/**Estimates Include IV Estimate, and Instrument Choice**/
global inston=0 
*this turns on IV regression (=1)
global ivonly=0
*this means that only the IV regs are reported if=1 (not OLS and RF as well)
global bartikon=0
*this turns on bartik. 0=off, 1=on, 2=both bartik and large expansion instruments, 3=bartik for levels, delta 50 for changes, 4=Export style bartik
global bartype="bar5rg"
*type of bartik instrument  LI0 is  initial state level growth, LI0R is with your mun removed
*global bartype bar0Rst bar0st  bar0Rrg bar0rg  bar0R bar0 
global exptype="dr2expm_"
*this is the type of export data used in in the hanson style iv
/**Additional Controls**/
global control = ""
global control2 = ""
*control 2 is not loaded from data so can stick in complicated interactions of variables loaded elsewhere
/**=============================================================**/
/**=============================================================**/
local seed = clock( c(current_time), "hms" )
set seed `seed'
local rnum=floor(runiform()*1000)
copy "${dircode}Mregs_March13_global.do" "${dirtemp}temp`rnum'Mregs_March13_global.do", replace
*copy "${dir}Mregs_Sept11_global_linear.do" "${dirtemp}temp`rnum'Mregs_Sept11_global_linear.do", replace

if ${finalrfspec}==1 {
local rfname=""
}



*here I loop over the population measure, the trends, the weights and the lag on the catchup trend

foreach looper1 in cp  {  // this takes mp if used interpolated populations and cp if use basleine populations.
foreach looper2 in "_linear"  {  //  "_catchup" "_linear" "_notrend"  "_pretrend"
foreach looper3 in 1 {  // 1 for wtyrschl, 0 for standard weight which is equal to wt`lhs'
foreach looper4 in 2 {  // catchlag-2 is standard (means previous two period averages used)

global mpop "`looper1'"
global linear "`looper2'"
global weightyrschl=`looper3'
global catchlag=`looper4'


local feenstra "alt16"   // use Jan2016_Heterogeneity_regs_cen90_final_altdelta.do if want column 13


foreach agey in agey  {
foreach lagfav in  9  {  // 19 gives us column 12

foreach yrstart in 90 {
foreach wager in  ve  { // we gives us column 11
foreach mainspec  in  e9s   { 
foreach export in  26  {  

foreach perclist in   scz3  {  

foreach percrho in none  { 


foreach agespan in  16  {

*local perclist "scz3"
foreach delta1 in  5 { 
foreach delta2 in "" {




local ifster "" 



if "`agey'"=="agey" {
local notagey="agez"
}
else {
local notagey="agey"
}


local namer "Jan2016`agespan'_`yrstart'_`perclist'_`feenstra'_d`delta1'`delta2'_`export'_`mainspec'_`agey'_`wager'_`lagfav'"
local middle "_none"
if `agespan'==1516 {
local filend "" 
}
if `agespan'==16 {
local filend "_1yrexp" 
}
local mainage "`agespan'"  // replace with 1516 is 2yrexp
local longages "10 11 12 13 14 15 16 17 18 19 20 21 22"








***********************************************************************************************
*Table 7 heterogenity
***********************************************************************************************

local namez "`namer'"

foreach nonexport in  13   { 

local namer "`namez'cf_`nonexport'"


*note this goes wrong if more than 35 variants 

global nonexportpure=`export'+1


local delta "0.`delta1'"

****first counterfactual



#delimit ;
local interactlist `" 

"
(eclyrschlprop99_1990-(eschatgrade`agey'_90_14-eschatgrade`agey'_90_15))
`delta'*(eclyrschlprop78_1990-(eschatgrade`agey'_90_12-eschatgrade`agey'_90_13))
(eclyrschlprop1212_1990*`delta'+(eschatgrade`agey'_90_17-eschatgrade`agey'_90_18)*(1-`delta'))
`delta'*(eclyrschlprop1011_1990*`delta'+(eschatgrade`agey'_90_15-eschatgrade`agey'_90_16)*(1-`delta'))
`delta'*(eclyrschlprop99_1990-(eschatgrade`agey'_90_14-eschatgrade`agey'_90_15))
`delta'*(eclyrschlprop1212_1990*`delta'+(eschatgrade`agey'_90_17-eschatgrade`agey'_90_18)*(1-`delta'))
"




"';      
#delimit cr

foreach perc in `perclist' {
foreach interactee in  `interactlist'   {
foreach lagtype in `lagfav'  {  
foreach wage in `wager'  { 
foreach type in    e  {  // 
foreach sklgeo in   s {  // 
foreach lhs in d  {
foreach wagepre in "d"  {  // d is vanilla, dm is demeaned by mun "dm" 
*this just restricts to the shocks that have working skill results
 

if regexm("`type'9`sklgeo'","`mainspec'")==1   {

if   ( ("`wage'"=="ve" | "`wage'"=="we" ) & ("`type'"=="e" | "`type'"=="a" | "`type'"=="d"))  {




if "`type'"=="e" {
local typemig="a"
noi di "atype"
}
else if "`type'"=="n" {
local typemig="m" 
noi di "mtype"
}
else {
}



local perced=regexr("`perc'","sc","s")
local mperced=regexr("`perc'","sc","")


local stripinteract: subinstr local interactee "(1-" " ", all
local stripinteract: subinstr local stripinteract "(" "", all
local stripinteract: subinstr local stripinteract ")" "", all
local stripinteract: subinstr local stripinteract "+1/2" "", all
local stripinteract: subinstr local stripinteract "/2" "/", all
local stripinteract: subinstr local stripinteract "^2" "", all
local stripinteract: subinstr local stripinteract "/" " ", all
local stripinteract: subinstr local stripinteract "*" " ", all
local stripinteract: subinstr local stripinteract "+1" " ", all
local stripinteract: subinstr local stripinteract "+" " ", all
local stripinteract: subinstr local stripinteract "-" " ", all
local stripinteract: subinstr local stripinteract "0.15" "", all
local stripinteract: subinstr local stripinteract "0.1" "", all
local stripinteract: subinstr local stripinteract "0.25" "", all
local stripinteract: subinstr local stripinteract "0.2" "", all
local stripinteract: subinstr local stripinteract "0.35" "", all
local stripinteract: subinstr local stripinteract "0.3" "", all
local stripinteract: subinstr local stripinteract "0.45" "", all
local stripinteract: subinstr local stripinteract "0.4" "", all
local stripinteract: subinstr local stripinteract "0.55" "", all
local stripinteract: subinstr local stripinteract "0.5" "", all
local stripinteract: subinstr local stripinteract "0.65" "", all
local stripinteract: subinstr local stripinteract "0.6" "", all
local stripinteract: subinstr local stripinteract "0.9" "", all


*get unique list from repeated list
local stripinteractunique ""
tokenize `stripinteract'
forval n=1/100 {
if strmatch("`stripinteractunique'","*``n''*")!=1 {
local stripinteractunique "`stripinteractunique' ``n''"
}
}




global laglevelinteract=`lagtype' 
local interactee1: word 1 of `interactee'
local interactee2: word 2 of `interactee'
local interactee3: word 3 of `interactee'
local interactee4: word 4 of `interactee'
local interactee5: word 5 of `interactee'
local interactee6: word 6 of `interactee'
cap local interactee7: word 7 of `interactee'
cap local interactee8: word 8 of `interactee'
global laganything `"`stripinteractunique'"'
*global laganything `"`interactee1' `interactee2' `interactee3'"'

local snamer "`interactee1' `interactee2' `interactee3' `interactee5'"
local nameinteract: subinstr local snamer " " "_", all
local nameinteract: subinstr local nameinteract "/" "#", all
local nameinteract: subinstr local nameinteract "*" "@", all
local nameinteract: subinstr local nameinteract "." "", all
local nameinteract: subinstr local nameinteract "_90_" "", all
local nameinteract: subinstr local nameinteract "eclyrschlprop" "p", all
local nameinteract: subinstr local nameinteract "eschatgradeage" "a", all
local nameinteract: subinstr local nameinteract "eschattage" "s", all
local nameinteract: subinstr local nameinteract "eclhhincomepclnwin" "iw", all
local nameinteract: subinstr local nameinteract "eclhhincomepcln" "i", all
local nameinteract: subinstr local nameinteract "nmig" "nm", all
local nameinteract: subinstr local nameinteract "old" "o", all
local nameinteract: subinstr local nameinteract "_q16`lhs'emp5013cp" "", all
local nameinteract: subinstr local nameinteract "_q16`lhs'emp0013cp" "", all



global export="`export'"
global nonexport=`nonexport'

global norhs=1
global sexx "emp" 
global indlist   `" "`nonexport'" "' 
global iflist `"   "if muncenso!=12 & yobexp>=\`yobmin1990' `ifster'" "' 
global aget  "`mainage'"   
global file "_genericskill_wages3c_cen90`filend'"
global reglist   `"\`lgender3'clyrschl"' 
global regname=`"`namer'_`rfname'_\`sexx'_\`aget'_`looper1'`looper2'`looper3'`looper4'_`lagtype'_\`indlist'_`nameinteract'"'
#delimit ;
global shocker `"    
"`lhs'\`lgender'\`lgender3'`perc'c1`type'9`sklgeo'_50 `lhs'\`lgender'\`lgender3'`perc'c2`type'9`sklgeo'_50"  
"' ; 
global randomuse "
q\`aget'`lhs'\`lgender'50`export'${mpop}
q\`aget'`lhs'\`lgender'50${nonexportpure}${mpop}
q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c??9`sklgeo'_50${nonexportpure}${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c??9`sklgeo'_50`export'${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c??9`sklgeo'_50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'*`wage'`perced'c??9`sklgeo'_50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'*`wage'`perced'c??9`sklgeo'_50`export'${mpop} 
q\`aget'`lhs'\`lgender'*`wage'`perced'c??9`sklgeo'_50${nonexportpure}${mpop} 
";
global interactuse "
`stripinteractunique'
";
#delimit cr


*noi di "`stripinteractunique'"



global codeinsert38 "cap mvencode q*`lhs'emp*`nonexport'${mpop} if q\`aget'`lhs'\`lgender'50`nonexport'${mpop}==0, mv(0) override"
*fills in missing shocks when 0 shocks


global codeinsert40 "cap mvencode eschatgradeage?_90*, mv(0) override"
global codeinsert41 "cap mvencode eschatgradeage_90*, mv(0) override"
*gen complex interactions. note must go after 40 to ensure they run after the demeaning (they are functions of initial values)
global codeinsert42 "cap gen complex1=`interactee1'"
global codeinsert43 "cap gen complex2=`interactee2'"
global codeinsert44 "cap gen complex3=`interactee3'"
global codeinsert45 "cap gen complex4=`interactee4'"

*so need to ignore complex, then generate complex above, allowing a new use command that pull schatts and props directly.
global codeinsert46 "gen complex5=`interactee5'"
global codeinsert47 "gen complex6=`interactee6'"
global codeinsert48 "cap gen complex7=`interactee7'"
global codeinsert49 "cap gen complex8=`interactee8'"



local w1=substr("`wage'",1,1)

local main3=substr("`mainspec'",3,1)

if  "`perc'"=="scz3" | "`perc'"=="scx3" {
global file "_genericskill_`feenstra'_cen90`filend'"



#delimit ;
global controlinteract   `"  



"q\`aget'`lhs'\`lgender'50`export'${mpop}"

"q\`aget'`lhs'\`lgender'50`export'${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c2`type'9`sklgeo'_50`export'${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c3`type'9`sklgeo'_50`export'${mpop}"

"q\`aget'`lhs'\`lgender'50`export'${mpop}
q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`export'${mpop}
q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`export'${mpop}
q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`export'${mpop}"


"q\`aget'`lhs'\`lgender'50`export'${mpop}
c.q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`export'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`export'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`export'${mpop}#c.complex3
c.q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`export'${mpop}#c.complex4"



"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}"

"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c2`type'9`sklgeo'_50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'\`lgender3'`perc'c3`type'9`sklgeo'_50`nonexport'${mpop}"

"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`nonexport'${mpop}"


"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
c.q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
c.q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex4"




"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
q\`aget'`lhs'\`lgender'50`export'${mpop}"



"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
c.q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
c.q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex4
q\`aget'`lhs'\`lgender'50`export'${mpop}"


"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
c.q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex5
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
c.q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex6
q\`aget'`lhs'\`lgender'50`export'${mpop}"

"';
#delimit cr





}
if  "`perc'"=="scz4" {
global file "_genericskill_`feenstra'_cen90`filend'"



#delimit ;
global controlinteract   `"  


"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
c.q\`aget'`lhs'\`lgender'`wage'`perced'c1`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'`wage'`perced'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'`wage'`perced'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
c.q\`aget'`lhs'\`lgender'`wage'`perced'c4`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
q\`aget'`lhs'\`lgender'50`export'${mpop}"




"q\`aget'`lhs'\`lgender'50`nonexport'${mpop}
c.q\`aget'`lhs'\`lgender'\`lgender3'`perc'c1`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'\`lgender3'`perc'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex1
c.q\`aget'`lhs'\`lgender'\`lgender3'`perc'c2`type'9`sklgeo'_50`nonexport'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'\`lgender3'`perc'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex2
c.q\`aget'`lhs'\`lgender'\`lgender3'`perc'c3`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
c.q\`aget'`lhs'\`lgender'\`lgender3'`perc'c4`type'9`sklgeo'_50`nonexport'${mpop}#c.complex3
q\`aget'`lhs'\`lgender'50`export'${mpop}"



"';
#delimit cr


}



global counterfactsimple=1
global iflist `"   "if muncenso!=12 & yobexp>=\`yobmin19`yrstart'' `ifster'" "' 



cap noi do "${dirtemp}temp`rnum'Mregs_March13_global.do"
global randomuse ""
global controlinteract   `"  "" "'
global counterfactsimple=0

}
}
}
}
}
}
}
}
}
}

}
*end of nonexport




}
}
}
}
}
}
}
}
}


}
*en dof export

}
}
}
}

*end of looper

}
*end qui
sleep 1000
exit, STATA clear

