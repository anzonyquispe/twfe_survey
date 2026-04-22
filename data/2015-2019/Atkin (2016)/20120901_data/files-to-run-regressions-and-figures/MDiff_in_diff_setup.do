
*March 2013: this file runs the diff in diff type regressions using the census data and changes occuring in 1990 and 2000.
clear all
set more off

set mem 7500m
set matsize 10000
set maxvar 32000


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
global dirrev="C:/Work/Mexico/Revision/New_code/"
global scratch="C:/Scratch/"
global regout="C:/Work/Mexico/Revision/regout/"
}

global zone="ZM"
global munwork="yes"

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3=""
*these dropvars below may involve geographical info

global dropvar4=""
*global dropvar4="drop if muncenso==12 "
*mexico city drop

if "${munwork}"=="yes"  {
global dropvar5="keep if ((muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew) & cenyear==2000) | (mgrate5==10 & cenyear==1990 )"
}
else if "${munwork}"=="no"  {
global dropvar5="keep if (muncenso==mig5mun${zone} & bplmx==state & cenyear==2000) | (mgrate5==10 & cenyear==1990 )"
}

global dropvar6=""


local herf="cen90"



*first get firm data in wide form ready for merge

*now take firm data
use year muncenso deltaemp50* emp00* emp50* emp?50* using   "${firmdir}newind`herf'_simpleMerge_skill", clear     
sort muncenso

if "${munwork}"=="yes" {
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(*munpop15_49*   regio* munmatch) nokeep _merge(_merge10)
sort muncenso
merge muncenso using "${dir}muncenso_incomeMerge", _merge(_mergeincrank) keep(rhhincomepc2000)
sort muncenso
merge muncenso using "${dir}progressa_muncensoZM", _merge(_mergeprogresa) 
}
else {
merge  muncenso using "${dir}mungeogZM.dta" ,  keep(*munpop15_49*  regio* munmatch) nokeep _merge(_merge10)
sort muncenso
merge muncenso using "${dir}muncenso_incomeZM", _merge(_mergeincrank) keep(rhhincomepc2000)
}


renpfix female fem

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




local stublist ""
qui ds *310
*this will not work for subsets
*noi di "`r(varlist)'"
local stubs "`r(varlist)'"
tokenize `stubs'

forval n=1/2000 {
local `n'=regexr("``n''","310","")
local stublist `stublist' ``n''
if "``n''"!=""{
local stubliststar `stubliststar' ``n''*
}
}

foreach thing in `stublist' {
if "`herf'"=="" {
cap gen `thing'10=`thing'110	+	`thing'112	+	`thing'210	+	`thing'211	+	`thing'220	+	`thing'230	+	`thing'239	
cap gen `thing'11=`thing'310	+	`thing'311	+	`thing'312	+	`thing'314	+	`thing'315	+	`thing'321	+	`thing'322	+	`thing'323	+	`thing'324	+	`thing'325	+	`thing'326	+	`thing'330	+	`thing'331	+	`thing'332	+	`thing'333	+	`thing'335	+	`thing'336	+	`thing'337	
cap gen `thing'12=`thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	
cap gen `thing'13=`thing'110	+	`thing'112	+	`thing'210	+	`thing'211	+	`thing'220	+	`thing'230	+	`thing'239	+	`thing'310	+	`thing'311	+	`thing'312	+	`thing'314	+	`thing'315	+	`thing'321	+	`thing'322	+	`thing'323	+	`thing'324	+	`thing'325	+	`thing'326	+	`thing'330	+	`thing'331	+	`thing'332	+	`thing'333	+	`thing'335	+	`thing'336	+	`thing'337	+ 	`thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	
cap gen `thing'18=`thing'310	+	`thing'311	+	`thing'312	+	`thing'314	+	`thing'315	+	`thing'321	+	`thing'322	+	`thing'323	+	`thing'324	+	`thing'325	+	`thing'326	+	`thing'330	+	`thing'331	+	`thing'332	+	`thing'333	+	`thing'335	+	`thing'336	+	`thing'337	+ 	`thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	
cap gen `thing'14=   `thing'310    +   `thing'326    +   `thing'325    +    `thing'311    +   `thing'321    +   `thing'322    +   `thing'324    +   `thing'330    +   `thing'323 
cap gen `thing'19=   `thing'335    +   `thing'332    +   `thing'333   +   `thing'331 +   `thing'337 +    `thing'315        +   `thing'336    +   `thing'314       +   `thing'312   


cap gen `thing'15=`thing'310    +   `thing'326    +   `thing'325    +    `thing'311    +   `thing'321    +   `thing'322    +   `thing'324    +   `thing'330    +   `thing'323 +   `thing'312 +    `thing'315 
cap gen `thing'16=`thing'335    +   `thing'332    +   `thing'333   +   `thing'331 +   `thing'337        +   `thing'336    +   `thing'314   
cap gen `thing'17=`thing'13-`thing'16
cap gen `thing'36=`thing'335    +   `thing'332    +   `thing'333    +   `thing'337        +   `thing'336    +   `thing'314        
cap gen `thing'37=`thing'13-`thing'36

*somewhat crude
cap gen `thing'56=`thing'335    +   `thing'332    +   `thing'333         +   `thing'336    +   `thing'314         
*somewhat crude
cap gen `thing'57=`thing'13-`thing'56

}

if "`herf'"=="cen90" {


cap gen `thing'11=`thing'320    +   `thing'323    +   `thing'324    +   `thing'325    +   `thing'326    +   `thing'347    +   `thing'348    +   `thing'349    +   `thing'350    +   `thing'351    +   `thing'352    +   `thing'353    +   `thing'354    +   `thing'355    +   `thing'356    +   `thing'357	+	`thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308    +   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317    +   `thing'318    +   `thing'319    +   `thing'321    +   `thing'322    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331    +   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340    +   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346
cap gen `thing'12=`thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	
cap gen `thing'13=`thing'110	+	`thing'112	+	`thing'210	+	`thing'211	+	`thing'220	+	`thing'230	+	`thing'239	+	`thing'320    +   `thing'323    +   `thing'324    +   `thing'325    +   `thing'326    +   `thing'347    +   `thing'348    +   `thing'349    +   `thing'350    +   `thing'351    +   `thing'352    +   `thing'353    +   `thing'354    +   `thing'355    +   `thing'356    +   `thing'357	+	`thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308    +   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317    +   `thing'318    +   `thing'319    +   `thing'321    +   `thing'322    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331    +   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340    +   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346	+ `thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	
cap gen `thing'18=`thing'320    +   `thing'323    +   `thing'324    +   `thing'325    +   `thing'326    +   `thing'347    +   `thing'348    +   `thing'349    +   `thing'350    +   `thing'351    +   `thing'352    +   `thing'353    +   `thing'354    +   `thing'355    +   `thing'356    +   `thing'357	+	`thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308    +   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317    +   `thing'318    +   `thing'319    +   `thing'321    +   `thing'322    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331    +   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340    +   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346	+ `thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	
cap gen `thing'16=`thing'320    +   `thing'323    +   `thing'324    +   `thing'325    +   `thing'326    +   `thing'347    +   `thing'348    +   `thing'349    +   `thing'350    +   `thing'351    +   `thing'352    +   `thing'353    +   `thing'354    +   `thing'355    +   `thing'356    +   `thing'357
cap gen `thing'15=`thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308    +   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317    +   `thing'318    +   `thing'319    +   `thing'321    +   `thing'322    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331    +   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340    +   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346
cap gen `thing'17=`thing'110	+	`thing'112	+	`thing'210	+	`thing'211	+	`thing'220	+	`thing'230	+	`thing'239	+ `thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308    +   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317    +   `thing'318    +   `thing'319    +   `thing'321    +   `thing'322    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331    +   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340    +   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346	+ `thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	




*have a cut off of 8 periods out of 16
cap gen `thing'26=`thing'320   +   `thing'322   +   `thing'323    +   `thing'324    +   `thing'325       +   `thing'347    +   `thing'348    +   `thing'349  ///
+   `thing'350    +   `thing'351    +   `thing'352    +   `thing'353    +   `thing'354    +   `thing'355    +   `thing'356    +   `thing'357

cap gen `thing'27=`thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308 ///
+   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317  ///
+   `thing'318    +   `thing'319    +   `thing'321   +   `thing'326    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331  ///
+   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340  ///
+   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346	+ `thing'430	+	`thing'433	+	`thing'465	+	`thing'467	+	`thing'469	+	`thing'480	+	`thing'483	+	`thing'487	+	`thing'490	+	`thing'511	+	`thing'520	+	`thing'530	+	`thing'540	+	`thing'562	+	`thing'610	+	`thing'620	+	`thing'710	+	`thing'720	+	`thing'721	+	`thing'810	+	`thing'815	+	`thing'939	+ `thing'110	+	`thing'112	+	`thing'210	+	`thing'211	+	`thing'220	+	`thing'230	+	`thing'239	

cap gen `thing'25=`thing'301    +   `thing'302    +   `thing'303    +   `thing'304    +   `thing'305    +   `thing'306    +   `thing'307    +   `thing'308 ///
+   `thing'309    +   `thing'310    +   `thing'311    +   `thing'312    +   `thing'313    +   `thing'314    +   `thing'315    +   `thing'316    +   `thing'317  ///
+   `thing'318    +   `thing'319    +   `thing'321   +   `thing'326    +   `thing'327    +   `thing'328    +   `thing'329    +   `thing'330    +   `thing'331  ///
+   `thing'332    +   `thing'333    +   `thing'334    +   `thing'335    +   `thing'336    +   `thing'337    +   `thing'338    +   `thing'339    +   `thing'340  ///
+   `thing'341    +   `thing'342    +   `thing'343    +   `thing'344    +   `thing'345    +   `thing'346	



}
drop `thing'???
}





foreach typer in  delta*emp* dh*emp* fire*emp* new*emp*  hire*emp* naq*emp* maq*emp* hcemp?0* haemp?0* emp?50* emp?0* hcemp*cat* haemp*cat* emp*cat* empmn* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(empmunpop15_49)
  gen X`type'cp=`type'/(xempmunpop15_49_1990)  
 drop `type'
}
}
}

foreach typer in h*male* dh*male* delta*male* new*male* fire*male* hire*male* maq*male* naq*male* male?0* male*cat* malemn* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(malemunpop15_49)
  gen X`type'cp=`type'/(xmalemunpop15_49_1990)
drop `type'
}
}
}

foreach typer in h*fem* dh*fem* delta*fem*   new*fem* fire*fem*  hire*fem* maq*fem* naq*fem* fem?0* fem*cat* femmn* {
cap  d `typer'
if _rc==0 {
foreach type of var  `typer' {
 gen X`type'mp=`type'/(femmunpop15_49)
  gen X`type'cp=`type'/(xfemmunpop15_49_1990) 
drop `type'
}
}
}


renpfix X





keep year muncenso `stubliststar'

renvars `stubliststar', postfix(_)
 


ds year muncenso, not

reshape wide `r(varlist)' , i(muncenso) j(year)



save "${scratch}temp_firm_stuff.dta", replace

keep muncenso delta*50?6cp*  delta*50?7cp* delta*50?5cp*   emp00?5cp_19?6 emp0012cp_19?6 emp00?7cp_19?6 emp00?6cp_19?6 deltaemp50??cp_????
compress
save "${scratch}temp_firm_stuff_supershort.dta", replace



use "${workdir}cohortmeans_DifInDif_mwyes_1990.dta" , clear
gen cenyear=1990
append using "${workdir}cohortmeans_DifInDif_mwyes_2000.dta"
replace cenyear=2000 if cenyear==.
*save "${scratch}cohortmeans_mwyes_2000_1990.dta", replace




sort muncenso

if "${munwork}"=="yes" {
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(*munpop15_49*  state  regio* munmatch) nokeep _merge(_merge10)
sort muncenso
merge muncenso using "${dir}muncenso_incomeMerge", _merge(_mergeincrank) keep(rhhincomepc2000)
sort muncenso
merge muncenso using "${dir}progressa_muncensoZM", _merge(_mergeprogresa) 
}
else {
merge  muncenso using "${dir}mungeogZM.dta" ,  keep(*munpop15_49*  regio* munmatch) nokeep _merge(_merge10)
sort muncenso
merge muncenso using "${dir}muncenso_incomeZM", _merge(_mergeincrank) keep(rhhincomepc2000)
}

renpfix malemunpop munpopmale
renpfix femalemunpop munpopfem
renpfix  munpop15_49  munpopemp15_49



 

merge m:1 muncenso  using "${scratch}temp_firm_stuff.dta" 
drop _merge

merge 1:1 muncenso age cenyear  using "${dir}atgrade_byMun_Age_long_.dta", keepusing(atgrade*) keep(master match)
drop _merge
merge 1:1 muncenso age cenyear  using "${dir}schatgrade_byMun_Age_long_.dta", keepusing(schatgrade*) keep(master match)
drop _merge




gen ageyear=age+cenyear*10

egen muncenso_cenyear=group(muncenso cenyear)

xtset muncenso ageyear

levelsof age
foreach X in `r(levels)' {
gen age`X'=(age==`X')
}

levelsof age
foreach X in `r(levels)' {
foreach Y in `r(levels)' {
if `X'-`Y'==-1 {
gen age`X'`Y'=(age==`X'|age==`Y')
}
}
}



foreach ind in 26 46 25 45 16 15 12 13 {
*create shocks I can use over both rounds
gen deltaemp50`ind'cp_1yearm1=deltaemp50`ind'cp_1999 if cenyear==2000
replace deltaemp50`ind'cp_1yearm1=deltaemp50`ind'cp_1989 if cenyear==1990

gen deltaemp50`ind'cp_1yearm2=deltaemp50`ind'cp_1998 if cenyear==2000
replace deltaemp50`ind'cp_1yearm2=deltaemp50`ind'cp_1988 if cenyear==1990

gen deltaemp50`ind'cp_1yearm3=deltaemp50`ind'cp_1997 if cenyear==2000
replace deltaemp50`ind'cp_1yearm3=deltaemp50`ind'cp_1987 if cenyear==1990

gen deltaemp50`ind'cp_1yearm4=deltaemp50`ind'cp_1996 if cenyear==2000
replace deltaemp50`ind'cp_1yearm4=deltaemp50`ind'cp_1986 if cenyear==1990

gen deltaemp50`ind'cp_1yearm0=deltaemp50`ind'cp_2000 if cenyear==2000
replace deltaemp50`ind'cp_1yearm0=deltaemp50`ind'cp_1990 if cenyear==1990

gen deltaemp50`ind'cp_1yearp2=deltaemp50`ind'cp_1991 if cenyear==1990
gen deltaemp50`ind'cp_1yearp3=deltaemp50`ind'cp_1992 if cenyear==1990
gen deltaemp50`ind'cp_1yearp4=deltaemp50`ind'cp_1993 if cenyear==1990


gen emp00`ind'cp_1yearm4=emp00`ind'cp_1996 if cenyear==2000
replace emp00`ind'cp_1yearm4=emp00`ind'cp_1986 if cenyear==1990

*also create multi year shocks
gen deltaemp50`ind'cp_2yearm1=deltaemp50`ind'cp_1999+deltaemp50`ind'cp_1998 if cenyear==2000
replace deltaemp50`ind'cp_2yearm1=deltaemp50`ind'cp_1989 + deltaemp50`ind'cp_1988 if cenyear==1990

gen deltaemp50`ind'cp_3yearm1=deltaemp50`ind'cp_1999+deltaemp50`ind'cp_1998 + deltaemp50`ind'cp_1997 if cenyear==2000
replace deltaemp50`ind'cp_3yearm1=deltaemp50`ind'cp_1989 + deltaemp50`ind'cp_1988 + deltaemp50`ind'cp_1987  if cenyear==1990

gen deltaemp50`ind'cp_4yearm1=deltaemp50`ind'cp_1999+deltaemp50`ind'cp_1998 + deltaemp50`ind'cp_1997+deltaemp50`ind'cp_1996 if cenyear==2000
replace deltaemp50`ind'cp_4yearm1=deltaemp50`ind'cp_1989 + deltaemp50`ind'cp_1988 + deltaemp50`ind'cp_1987+deltaemp50`ind'cp_1986  if cenyear==1990

gen deltaemp50`ind'cp_2yearm3=deltaemp50`ind'cp_1997+deltaemp50`ind'cp_1996 if cenyear==2000
replace deltaemp50`ind'cp_2yearm3=deltaemp50`ind'cp_1987+deltaemp50`ind'cp_1986 if cenyear==1990



forval z=1/4 {
forval n=1/4 {
cap {
gen posdeltaemp50`ind'cp_`z'yearm`n'=(deltaemp50`ind'cp_`z'yearm`n'>0)
replace posdeltaemp50`ind'cp_`z'yearm`n'=. if  deltaemp50`ind'cp_`z'yearm`n'==.
}
}
}
}



mvdecode *form* if cenyear==1990, mv(0)


gen age2=age*age

gen constant=1




foreach ind in 16  26 46 25 45 12 {  // 
gen podemp`ind'=(deltaemp50`ind'cp_2yearm1>0) if  cenyear==2000
replace podemp`ind'=(deltaemp50`ind'cp_2yearm1>0) if  cenyear==1990

gen podemp`ind'_m0=(deltaemp50`ind'cp_1yearm0>0) 
gen podemp`ind'_m1=(deltaemp50`ind'cp_1yearm1>0) 
gen podemp`ind'_m2=(deltaemp50`ind'cp_1yearm2>0) 
gen podemp`ind'_m3=(deltaemp50`ind'cp_1yearm3>0) 
gen podemp`ind'_m4=(deltaemp50`ind'cp_1yearm4>0) 


gen podemp`ind'_m0123=(podemp`ind'_m0==1 | podemp`ind'_m1==1 | podemp`ind'_m2==1 | podemp`ind'_m3==1) 
gen podemp`ind'_m01234=(podemp`ind'_m0==1 | podemp`ind'_m1==1 | podemp`ind'_m2==1 | podemp`ind'_m3==1 | podemp`ind'_m4==1) 
gen podemp`ind'_m10123=(podemp`ind'_m0==1 | podemp`ind'_m1==1 | podemp`ind'_m2==1 | podemp`ind'_m3==1 | deltaemp50`ind'cp_1991>0) 
gen podemp`ind'_m101234=(podemp`ind'_m0==1 | podemp`ind'_m1==1 | podemp`ind'_m2==1 | podemp`ind'_m3==1 | deltaemp50`ind'cp_1991>0 | deltaemp50`ind'cp_1992>0) 



*the ind and propind measures are:
*ind is proportion of people saying what their current situation is that are in ind`n' (and formal for indform)
*propind is proportion of economically active that are in ind`n' 
*propindns is proportion of those not at school that are in ind`n' 
*propindform is proportion of economically active that are in ind`n' and are formal 

*indall is proportion of people employed
*indallform is proportion of people employed formally
*employ is whether or not employed (excluding those at school according to empstatd-some of these guys are at school according to school)
*employns is whether or not employed (excluding those at school according to schatt)
*employany is whether or not employed (including those at school as unemployed)
*employanyns is whether or not employed (including those at school as unemployed according to schatt)

*variables:
/*
1. eclschatt : should be more likely to be at school
2. eclind19 eclind19formimss eclpropind19 eclpropnsind19 eclpropind19formimss eclpropnsind19formimss : should be more likely to work in ind19
3. eclind14 eclind14formimss eclpropind14 eclpropnsind14 eclpropind14formimss eclpropnsind14formimss : not more likely to be in other sectors (and what changes)
4. eclindallform eclpropindallform eclpropnsindallform eclinformal eclformal_imss : less likely to be informal
5. eclindall eclposearn employ employns employany employanyns : more likely to be employed
*/



cap gen eclind`ind'informimss = eclind`ind' - eclind`ind'formimss  // informal same industry
cap gen eclpropnsind`ind'informimss = eclpropnsind`ind' - eclpropnsind`ind'formimss  // informal same industry

cap gen eclindother = eclindall - eclind`ind' // different industry
cap gen eclpropnsindother = eclpropnsindall - eclpropnsind`ind' // different industry

cap gen eclindotherform = eclindallform - eclind`ind'form // different industry formal
cap gen eclpropnsindotherform = eclpropnsindallform - eclpropnsind`ind'form // different industry formal

cap gen eclindotherinform = eclindother - eclindotherform // different industry informal
cap gen eclpropnsindotherinform = eclpropnsindother - eclpropnsindotherform // different industry informal

cap gen eclindunemploy = 1 - eclemployanyns - eclschatt // unemployed (e.g. not employed minus at school)
cap gen eclpropnsindunemploy = 1 - eclemployns // unemployed (e.g. not employed minus at school)
}

save  "${scratch}Diff_in_Diff_2000_1990.dta", replace






***************
*now the same but individual level data





*First I get the parental data into the right shape
local parentlist "cenyear serial pernum age  occ ind  mx00a_imss  hlthcov yrschl  hrswrk1 empstatd hcode incearn sex schatt"
local agestart=10
local agestart1=`agestart'+1
local ageend=90


use `parentlist' using "${censodir}mexico_censo_05_regready`agestart'.dta", clear
keep if (cenyear==1990 | cenyear==2000)


forvalues i = `agestart1'/`ageend' {
append using "${censodir}mexico_censo_05_regready`i'.dta", keep(`parentlist')
keep if cenyear==1990 | cenyear==2000
}

do  "${dir}Occupation_codes_2digit.do"
rename bluecollar blue


*now I drop the duplicates (when I split up the municipalities)
duplicates drop cenyear serial pernum, force

*this is where i run all the employment measures
include "${dirrev}MDiff_in_diff_employment_measures.do"


save "${scratch}Temp_dffffff.dta", replace




*here i get siblings-actually total family memebers
use cenyear serial pernum ind?? indall indblue indwhite using  "${scratch}Temp_dffffff.dta", clear
egen sibcount=count(serial),by(cenyear serial)
foreach var of varlist ind*  {
egen sib`var'=total(`var'),by(cenyear serial)
replace sib`var'=sib`var'-`var' if `var'!=.
gen sibI`var'=1 if sib`var'>=1 & sib`var'!=.
replace sibI`var'=0 if sib`var'==0
gen sibratio`var'=sib`var'/(sibcount-1)
}
keep sib* cenyear serial pernum
save "${scratch}Temp_family.dta", replace 







use if sex==1 using  "${scratch}Temp_dffffff.dta", clear
ds cenyear serial pernum, not
renvars `r(varlist)', prefix(pop)
rename pernum poploc
compress
save "${scratch}Temp_dads.dta", replace
use if sex==2 using  "${scratch}Temp_dffffff.dta", clear
ds cenyear serial pernum, not
renvars `r(varlist)', prefix(mom)
rename pernum momloc
compress
save "${scratch}Temp_moms.dta", replace




local kidlist "cenyear serial pernum muncenso empstatd  yrschl sex mig5mun mig5munZM mgrate5 schatt age occ  bplmx  mx00a_imss ind  wtper muncensoZM  yobexp hrswrk1 hcode hlthcov incearn"

local agestart=12
local agestart1=`agestart'+1
local ageend=19


use `kidlist' using "${censodir}mexico_censo_05_regready`agestart'.dta", clear
keep if cenyear==1990 | cenyear==2000


forvalues i = `agestart1'/`ageend' {
append using "${censodir}mexico_censo_05_regready`i'.dta", keep(`kidlist')
keep if cenyear==1990 | cenyear==2000
}


do  "${dir}Occupation_codes_2digit.do"
rename bluecollar blue

*now get right muncensos

if "${zone}"=="ZM" {
drop muncenso
rename muncensoZM muncenso
}
*if I want to run it without my munwork merges I need to cut out this bit, and change the migration drop above to not include the munwork municipalities
if "${munwork}"=="yes" {
sort muncenso
joinby muncenso using "${dir}munworkdatageog.dta", unm(u)
rename muncenso muncensoold
rename muncensonew muncenso
sort muncensoold
merge  muncensoold using "${dir}munworkdataoldstates.dta" ,  keep(statenew stateold) nokeep _merge(_mergestate)
sort muncenso
merge  muncenso using "${dir}mungeogMerge.dta" ,  keep(*munpop15_49* state splitters regio*) nokeep _merge(_merge10)

sort mig5munZM
merge mig5munZM using "${dir}munworkdatamig5mun.dta", nokeep _merge(_mergemigm)
rename mig5munZM mig5munZMold
rename mig5munZMnew mig5munZM
replace wtper=wtper/splitters if splitters==2
drop _mergestate
}
else {
sort muncenso
merge  muncenso using "${dir}mungeog${zone}.dta" ,  keep(state) nokeep _merge(_merge10)
}




${dropvar4}
noi count
${dropvar5}
noi count
${dropvar6}

drop if muncenso==12


drop  malemunpop15_49_2005- _mergemigm



cap drop _merge
*this is where i run all the employment measures
include "${dirrev}MDiff_in_diff_employment_measures.do"

cap drop _merge
*note this isn't 1:1 as some guys are duplicated to span multiple municipalities because of the commuting splits
merge m:1 cenyear serial pernum using "${scratch}Temp_family.dta", keep(match master) generate(_merge)

cap drop _merge
*note this isn't 1:1 as some guys are duplicated to span multiple municipalities because of the commuting splits
merge m:1 cenyear serial pernum using "${censodir}mexico_censo_05_parentlink.dta", keep(match master) generate(_merge)
drop _merge

*now this is ready to merge in any parent info I want... I guess I create a slimmed down version of the mexico_censo_05_regready`i'.dta
*data and merge in by cenyear serial pernum (after changing momloc and poploc to pernum at the appropriate time)
merge m:1 cenyear serial poploc using "${scratch}Temp_dads.dta", keep(match master) generate(_mergedad)
merge m:1 cenyear serial momloc using "${scratch}Temp_moms.dta", keep(match master) generate(_mergemom)



gen parents=0 if momloc==0 & poploc==0
replace parents=1  if (momloc!=0 & poploc==0) | (momloc==0 & poploc!=0)
replace parents=2 if  (momloc!=0 & poploc!=0)
replace parents=. if momloc==. & poploc==.

*now calculate average value over paernts
*local firstlast "posearn-propnsindallformimss"
ds  `firstlast'
foreach var in  `r(varlist)' {
gen fam`var'=(mom`var' + pop`var')/parents
}

compress

****this makes it super large
merge m:1 muncenso  using "${scratch}temp_firm_stuff_supershort.dta" ,keep(match master)



gen ageyear=age+cenyear*10
egen muncenso_cenyear=group(muncenso cenyear)

levelsof age
foreach X in `r(levels)' {
gen age`X'=(age==`X')
}


foreach ind in 25 26  16 12 { // 15
*create shocks I can use over both rounds
gen deltaemp50`ind'cp_1yearm1=deltaemp50`ind'cp_1999 if cenyear==2000
replace deltaemp50`ind'cp_1yearm1=deltaemp50`ind'cp_1989 if cenyear==1990

gen deltaemp50`ind'cp_1yearm2=deltaemp50`ind'cp_1998 if cenyear==2000
replace deltaemp50`ind'cp_1yearm2=deltaemp50`ind'cp_1988 if cenyear==1990

gen deltaemp50`ind'cp_1yearm3=deltaemp50`ind'cp_1997 if cenyear==2000
replace deltaemp50`ind'cp_1yearm3=deltaemp50`ind'cp_1987 if cenyear==1990

gen deltaemp50`ind'cp_1yearm4=deltaemp50`ind'cp_1996 if cenyear==2000
replace deltaemp50`ind'cp_1yearm4=deltaemp50`ind'cp_1986 if cenyear==1990

gen deltaemp50`ind'cp_1yearm0=deltaemp50`ind'cp_2000 if cenyear==2000
replace deltaemp50`ind'cp_1yearm0=deltaemp50`ind'cp_1990 if cenyear==1990

gen deltaemp50`ind'cp_1yearp2=deltaemp50`ind'cp_1991 if cenyear==1990
gen deltaemp50`ind'cp_1yearp3=deltaemp50`ind'cp_1992 if cenyear==1990
gen deltaemp50`ind'cp_1yearp4=deltaemp50`ind'cp_1993 if cenyear==1990


gen emp00`ind'cp_1yearm4=emp00`ind'cp_1996 if cenyear==2000
replace emp00`ind'cp_1yearm4=emp00`ind'cp_1986 if cenyear==1990

*also create multi year shocks
gen deltaemp50`ind'cp_2yearm1=deltaemp50`ind'cp_1999+deltaemp50`ind'cp_1998 if cenyear==2000
replace deltaemp50`ind'cp_2yearm1=deltaemp50`ind'cp_1989 + deltaemp50`ind'cp_1988 if cenyear==1990

gen deltaemp50`ind'cp_3yearm1=deltaemp50`ind'cp_1999+deltaemp50`ind'cp_1998 +deltaemp50`ind'cp_1997 if cenyear==2000
replace deltaemp50`ind'cp_3yearm1=deltaemp50`ind'cp_1989 + deltaemp50`ind'cp_1988  + deltaemp50`ind'cp_1987 if cenyear==1990
}

drop emp00??cp_19?6


*positive shocks
foreach var of varlist deltaemp5016* deltaemp5046* deltaemp5026* deltaemp5012* deltaemp5025* {
gen po`var'=(`var'>0)
replace po`var'=. if `var'==.
}


foreach indvar in 16 26 12 25 {
gen podemp`indvar'_m0123=(podeltaemp50`indvar'cp_1yearm0==1 | podeltaemp50`indvar'cp_1yearm1==1 | podeltaemp50`indvar'cp_1yearm2==1 | podeltaemp50`indvar'cp_1yearm3==1) 
gen podemp`indvar'_m01234=(podeltaemp50`indvar'cp_1yearm0==1 | podeltaemp50`indvar'cp_1yearm1==1 | podeltaemp50`indvar'cp_1yearm2==1 | podeltaemp50`indvar'cp_1yearm3==1 | podeltaemp50`indvar'cp_1yearm4==1) 
gen podemp`indvar'_m10123=(podeltaemp50`indvar'cp_1yearm0==1 | podeltaemp50`indvar'cp_1yearm1==1 | podeltaemp50`indvar'cp_1yearm2==1 | podeltaemp50`indvar'cp_1yearm3==1 | podeltaemp50`indvar'cp_1yearp2==1) 
gen podemp`indvar'_m101234=(podeltaemp50`indvar'cp_1yearm0==1 | podeltaemp50`indvar'cp_1yearm1==1 | podeltaemp50`indvar'cp_1yearm2==1 | podeltaemp50`indvar'cp_1yearm3==1 | podeltaemp50`indvar'cp_1yearp2==1 | podeltaemp50`indvar'cp_1yearp3==1) 
}






*drop deltaemp501?cp_19?? deltaemp501?cp_2000 emp001?cp_19?? emp001?cp_2000




gen notatgrade=(age-6>yrschl)
replace notatgrade=. if age==. | yrschl==.
gen notatgradex=(age-7>yrschl)
replace notatgradex=. if age==. | yrschl==.


*this is the proportion of cohort that is both at school & not at grade.
gen schatgrade=(notatgrade==1 & schatt==1)
replace schatgrade=. if notatgrade==. | schatt==.
*replace schatgrade=. if schatt==0
gen schatgradex=(notatgradex==1 & schatt==1)
replace schatgradex=. if notatgradex==. | schatt==.

*this is the proportion of cohort that is both at school & at grade.
gen schatgradey=(notatgrade==0 & schatt==1)
replace schatgradey=. if notatgrade==. | schatt==.
*replace schatgrade=. if schatt==0
gen schatgradez=(notatgradex==0 & schatt==1)
replace schatgradez=. if notatgradex==. | schatt==.

*this is the proportion of cohort that is at grade.
gen schatgradea=(age-6<=yrschl)
replace schatgradea=. if age==. | yrschl==.
*replace schatgrade=. if schatt==0
gen schatgradeb=(age-7<=yrschl)
replace schatgradeb=. if age==. | yrschl==.

compress


save  "${scratch}Diff_in_Diff_2000_1990_individual.dta", replace


cap erase "${scratch}temp_firm_stuff.dta"
cap erase "${scratch}Temp_dffffff.dta"
cap erase "${scratch}Temp_family.dta"
cap erase "${scratch}Temp_dads.dta"
cap erase "${scratch}Temp_moms.dta"











