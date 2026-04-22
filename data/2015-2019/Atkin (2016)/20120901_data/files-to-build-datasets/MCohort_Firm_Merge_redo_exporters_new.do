


qui {


*this brings in the cohort data from MCohortAveragesOnly and merges it with the firm data created by  MFirm_to_mun_industry.do.
*this is where teh 2 or 1 year average is created and the final industry caatgories.

*Bartik instrument is also calculated.

clear all
set mem 1500m
set matsize 10000
set maxvar 10000




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
local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
}




set more off


/**-----------------------------------------------
-----------------------------------------------**/
local special="_exporters_new"
*this is the type of file I am creating

local years="15 16"
*these are exposure years



*don't make these lists too long or else stata has trouble with a string that long and it wont allow all my substitution commmands
*it is vital emp00* goes not first and with at least two spaces before. this is because in keeplisteex i need to do the mep var seperately as want it lagged and stuff for the instrument.




*(from old file
local keepliste "emp00* all00* ski00* usk00* all_expa00* deltanexb00* deltamaq00* deltaskib00* deltauskb00*  deltanxa00*  deltanxb00* delta2nexb00* delta2maq00* delta2skib00* delta2uskb00*  delta2nxa00*  delta2nxb00*"
local keepliste2 "  deltaemp00*     deltaall00*     deltaall_expa00*  deltaall_expb00* deltaski00*     deltaski_expa00* deltaski_expb00* deltausk00*     deltausk_expa00* deltausk_expb00* deltamaq00*     deltaempx00*    deltanex00*     deltanexa00*    deltanmqa00*    deltaskia00*    deltauska00*    deltaexpa00*    deltaskinxa00*  deltausknxa00*  deltanxa00*     deltanexb00*    deltanmqb00*    deltaskib00*    deltauskb00*    deltaexpb00*    deltaskinxb00*  deltausknxb00*  deltanxb00*"
local keepliste3 "  deltaempImaq00*    delta2all00*     delta2all_expa00*  delta2all_expb00* delta2ski00*     delta2ski_expa00* delta2ski_expb00* delta2usk00*     delta2usk_expa00* delta2usk_expb00* delta2maq00*     delta2empx00*    delta2nex00*     delta2nexa00*    delta2nmqa00*    delta2skia00*    delta2uska00*    delta2expa00*    delta2skinxa00*  delta2usknxa00*  delta2nxa00*     delta2nexb00*    delta2nmqb00*    delta2skib00*    delta2uskb00*    delta2expb00*    delta2skinxb00*  delta2usknxb00*  delta2nxb00*"



local interactlist ""
*this is needed to create pdeltaemp`interactlist' etc terms at bottom of file. only if non standrad terms are put in above is this needed
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

*these are years of exposure

*variable to rename year
global agestart=6
local ageend=45

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="keep if cenyear==`cenyear'"
*these dropvars below may involve geographical info
*global dropvar4="drop if muncenso==12 "
global dropvar4=""


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

*local combo="combo"
local combo="`cenyear'"
*for using just 2000 census average data 
*combo uses data combining 2000 means and means that also use older data

use "${workdir}cohortmeans_mw${munwork}_`combo'.dta", clear

sort muncenso yobexp
merge  muncenso yobexp using "${workdir}cohortmeans_returns2school_mw${munwork}_`combo'.dta", keep(ecl* fcl* mcl*) _merge(_mergers)

sort muncenso yobexp
merge  muncenso yobexp using "${workdir}cohortmeans_quartiles_mw${munwork}_`cenyear'.dta", keep(ecl* fcl* mcl*) _merge(_mergers2)


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


drop _merge10
drop _mergeincrank
cap renpfix female fem









local keeplist " `keepliste'  "
local keeplist2 " `keepliste2'  "
local keeplist3 " `keepliste3'  "



foreach yearset of num `years'  {
*s now we get seperate two year averages for whatever years are here. e.g. in 15 16 case we get 15/16 and 16/17

local yearplus1=`yearset' + 1
local twoyearset="`yearset' `yearplus1'"

*so I bring in the data, years is 15 16 now, and then essentially all I am doing is labelling them with a q15, q16 type thing in the twoyearset as i am bring in in the merge data for firms, i am bringing it in at different years..

foreach yearvar of num `twoyearset'  {


gen year=yobexp + `yearvar' 
replace year=. if year>`yearend' | year<1985


foreach sex in "male" "fem" "" {
replace `sex'munpop15_49_1995=(`sex'munpop15_49_1990+`sex'munpop15_49_2000)/2 if `sex'munpop15_49_1995==0


*this is where i am - this needs to be corrected and then firm data needs to be put past 2000 and then change the whole file to 2005
*want mid year population really... 2000 and 1990 are in feb, 2005 and 1995 are in october and november respectively
gen `sex'munpop15_49=`sex'munpop15_49_1990+(year+0.25-1990)*((`sex'munpop15_49_1995-`sex'munpop15_49_1990)/5.5) if year<=1995
replace `sex'munpop15_49=`sex'munpop15_49_1995+(year-0.25-1995)*((`sex'munpop15_49_2000-`sex'munpop15_49_1995)/4.5) if year>1995 & year<2000
replace `sex'munpop15_49=`sex'munpop15_49_2000+(year+0.25-2000)*((`sex'munpop15_49_2005-`sex'munpop15_49_2000)/5.5) if year>=2000 
replace `sex'munpop15_49=1 if `sex'munpop15_49<1

gen x`sex'munpop15_49_1990=`sex'munpop15_49_1990
replace x`sex'munpop15_49_1990=. if `sex'munpop15_49==.
}


rename munpop15_49 empmunpop15_49
rename xmunpop15_49_1990 xempmunpop15_49_1990
gen xxempmunpop15_49_1990=munpop15_49_1990

sort year muncenso

if "${munwork}"=="yes" {
merge year muncenso  using "${firmdir}newind_simpleMerge`special'.dta" ,nokeep keep(`keeplist2' `keeplist3') _merge(merge2)
drop merge2
}
else {
merge year muncenso  using "${firmdir}newind_simple${zone}`special'.dta" ,nokeep keep(`keeplist2' `keeplist3') _merge(_merge2`yearvar')
}





*tsset  muncenso age


noi di "========================="
noi di "Year `yearvar' half way"
noi di "========================="





global keeplistex: subinstr local keepliste "*" "", all

global keeplistex2: subinstr local keepliste2 "*" "", all

global keeplistex3: subinstr local keepliste3 "*" "", all


*this is where the industry catagories are determined. It depends on the file coming in what I do with these. for the standard one I take my indsutry codes that run 1-16
*for skill I use the davidcode and have a much finer split,.,.
*maq and maqskill have these splits borken by maq and non maq






tsset  muncenso year
*this is code to get instrument of existing jobs interactd with national job growth. there is a second part below and i need to add nat to teh list of variables









foreach type of var   `keepliste2'  {
gen ZZZ`type'mpop15_49=`type'/(empmunpop15_49)
gen ZZZ`type'cpop15_49=`type'/(xempmunpop15_49_1990)
gen ZZZ`type'gpop15_49=`type'/(xxempmunpop15_49_1990)
cap drop `type'
}


foreach type of var   `keepliste3'  {
gen `type'mpop15_49=`type'/(empmunpop15_49)
gen `type'cpop15_49=`type'/(xempmunpop15_49_1990)
gen `type'gpop15_49=`type'/(xxempmunpop15_49_1990)
cap drop `type'
}

renpfix ZZZ







rename malemunpop15_49 q`yearvar'malemunpop15_49 
rename femmunpop15_49 q`yearvar'femmunpop15_49 
rename empmunpop15_49 q`yearvar'empmunpop15_49 

drop x*munpop*

foreach var in   all ski usk new delta close hire fire emp male0 male1 fem1 male5 fem0 fem5 firm peso dpeso dnfirm nfirm  dn50firm n50firm nat {
foreach prefix in ""  {
cap renpfix `prefix'`var' q`yearvar'`prefix'`var'
}
}


drop year
cap drop _merge`yearvar'




}
*end of twoyearset
*now have two years for each variable, q15 and q16... will add them







local keeplistx " $keeplistex $keeplistmx $keeplistfx "
local keeplistx2 " $keeplistex2 $keeplistmx2 $keeplistfx2 "
local keeplistx3 " $keeplistex3 $keeplistmx3 $keeplistfx3 "

*this is where I add together two years and average them for firm data. NOte these are NOT averaged, just added
foreach type in  `keeplistx' `keeplistx2' `keeplistx3'  {
forval num=0/999 { 
cap gen v`yearset'`yearplus1'`type'`num'mpop=q`yearset'`type'`num'mpop15_49+q`yearplus1'`type'`num'mpop15_49
cap gen v`yearset'`type'`num'mpop=q`yearset'`type'`num'mpop15_49
cap drop q`yearset'`type'`num'mpop15_49
cap drop q`yearplus1'`type'`num'mpop15_49

cap gen v`yearset'`yearplus1'`type'`num'cpop=q`yearset'`type'`num'cpop15_49+q`yearplus1'`type'`num'cpop15_49
cap gen v`yearset'`type'`num'cpop=q`yearset'`type'`num'cpop15_49
cap drop q`yearset'`type'`num'cpop15_49
cap drop q`yearplus1'`type'`num'cpop15_49

cap gen v`yearset'`yearplus1'`type'`num'gpop=q`yearset'`type'`num'gpop15_49+q`yearplus1'`type'`num'gpop15_49
cap gen v`yearset'`type'`num'gpop=q`yearset'`type'`num'gpop15_49
cap drop q`yearset'`type'`num'gpop15_49
cap drop q`yearplus1'`type'`num'gpop15_49
}
}







*this is where I add together two years of munpop data.
foreach catty in emp male fem { 
gen v`yearset'`yearplus1'`catty'munpop=(q`yearset'`catty'munpop15_49 + q`yearplus1'`catty'munpop15_49)/2
gen v`yearset'`catty'munpop=q`yearset'`catty'munpop15_49
drop q`yearset'`catty'munpop15_49 q`yearplus1'`catty'munpop15_49
}

renpfix v`yearset'`yearplus1' z`yearset'`yearplus1'
renpfix v`yearset' z`yearset'





cap drop q`yearset'* q`yearplus1'*
cap drop yearcount`yearset' year`yearset'
cap drop *nat*
cap drop *emp*i
cap drop *lmpop* *impop*
*get rid of all the q variables that i dont need or want



}
*end of year













}
*end of quiet






tsset  muncenso yobexp


gen fpclwtyrschl=d.fclwtyrschl/l.fclwtyrschl
gen mpclwtyrschl=d.mclwtyrschl/l.mclwtyrschl
gen epclwtyrschl=d.eclwtyrschl/l.eclwtyrschl


tsset  muncenso age


sort muncenso yobexp

renpfix z q
*renvars q*, postsub(mpop mpop15_49)

*These are the change in the proportion of workers with more than 9 years of schoooling (5years or less experience)
*if this is higher, then skills went up more and we should expect less dropout. So coefficieent in schooling reg on interaction should be positive.
*estimated in Exploring changes in skill histograms
local de24=.0863758
local de33=.0728881
local de34=.1289444
local de26=.1522416
local de29=.1069824

*These are the change in the skill premium of 12 over 9 years of schoooling from "Getting skill by sector building on temp7 full sample_original_allyears_ind3codes.do" (5years or less experience)
*if this is higher, then skill return went up more and we should expect less dropout. So coefficieent in schooling reg on interaction should be positive.
*estimated in Exploring changeing returns 1990 2000
local ds24=.0190823
local ds33=-.1460476
local ds34=-.0168826
local ds26=-.0279523
local ds29=-.0233789

/**
ind	de	ds	timecoef
24	0.0863758	0.0190823	-1.818
33	0.0728881	-0.1460476	-0.437
34	0.1289444	-0.0168826	-0.846
26	0.1522416	-0.0279523	-2.755
29	0.1069824	-0.0233789	-1.945
**/




compress 



save "${workdir}reg2year_mw${munwork}_`cenyear'_july11`special'_1516_16.dta", replace


