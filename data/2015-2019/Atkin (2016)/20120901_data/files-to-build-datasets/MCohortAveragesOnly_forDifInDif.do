
*the state is a little sketchy as some municipalities when I change them, they change state
*what i have done is taken the original muncenso zm state for the migration drop

*make sure winsor is installed

clear 
set mem 7000m
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
global tempdir="C:\Scratch\"
global workdir="C:\Data\Mexico\Stata10\"
local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
}


set more off







foreach cenyear in  1990 { // 2000 
*this should be changed to 2006 if want the 2005 survey data
local yearend=1999
*if my firm data goes beyond this, change here to 2005

local edit2=substr("`edit'",11,1)

*-----------------------------------------------





*-----------------------------------------------
*global cutoff=50
*local lcutoff=50

global zone="ZM"
global munwork="yes"


*-----------------------------------------------
global exposure=""
*local years="7 9 11 13 15 16 18"
*local years="15 16"
*these are exposure years

*note the censo data is done on a year by year cohort basis so this is irrelevant here





*this is where restricted smaple must be made

*variable to rename year
global agestart=8
local ageend=39

global dropvar1=""
*keep if urban==2
global dropvar2=""
global dropvar3="keep if cenyear==`cenyear'"
*these dropvars below may involve geographical info

global dropvar4=""
*global dropvar4="drop if muncenso==12 "
*mexico city drop




global dropvar6="`edit'"
*SCHEDIT: global dropvar6="keep if yrschl>5 & yrschl<13 & schatt!=1"
*-----------------------------------------------
*local expo=2
*this is how many years I average. So for age 15, with exposure=2, I average 15 and 16
*doesnt work with local. But only have to change weighted average of cohorts

noi local lhslist="yrschl2 yrschl"


noi local varlist="incearn inctot hhincomepc hhincome"
*these variables I find weighted log variances



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







qui {




*this code brings in the regready stuff and gets cohort averages

use  muncenso empstatd  sex mig5mun mig5munZM mgrate5 schatt cenyear age hlthcov  bplmx  mx00a_imss ind3 ind sector  leftsch educmx  `lhslist' `varlist' wtper muncensoZM  `yeartrend' hrswrk1 urban chdeathrate married chborn hcode  using "${censodir}mexico_censo_05_regready${agestart}.dta", clear
${dropvar1}
${dropvar2}
${dropvar3}


forvalues i = `agestart1'/`ageend' {

append using "${censodir}mexico_censo_05_regready`i'.dta", keep(muncenso empstatd sex mig5mun mig5munZM  mgrate5 schatt cenyear age hlthcov  bplmx  mx00a_imss ind3 ind sector  leftsch educmx   `lhslist' `varlist' wtper muncensoZM  `yeartrend' hrswrk1 urban chborn chdeathrate hcode married  )
${dropvar1}
${dropvar2}
${dropvar3}


}




*now I take my income etc variables (of various sorts) and get the ready to use 


cap replace incearn=. if incearn==99999998 | incearn==99999999
cap replace inctot=. if inctot==9999997 | inctot==9999998
cap gen incearnln=log(incearn)
cap gen inctotln=log(inctot)

cap gen incearntrim=incearn
sum incearn if  incearn>0 & incearn< 99999998 & (empstatd==120 | empstatd==110)  & age>15 & age<56, d
cap replace incearntrim=r(p99) if incearn>r(p99)
cap gen incearntriml=log(incearntrim)
*this is the 99th percentile from sum incearn if cenyear==2000 & incearn>0 & incearn< 99999998, d
*this trims the top at the 99th percentile and replaces it with p99 value

cap gen incworktriml=incearntrim if (empstatd==120 | empstatd==110)
cap replace incworktriml=log(incworktriml) 
*this drops those not at work

cap replace incearntrim=. if schatt==1
*drops those also at school




cap gen incearnlnhrs=incearnln if hrswrk1>20
cap gen incworklnhrs=incearnln if hrswrk1>20 & (empstatd==120 | empstatd==110)
*these are my prefferred measure for people working more than 20 hours a week, and people in employment

cap winsor incearnlnhrs, gen(incearnlnhrswin) p(0.01)
cap winsor incworklnhrs, gen(incworklnhrswin) p(0.01)
cap winsor inctotln, gen(inctotlnwin) p(0.01)
*now winsorize these

if "`cenyear'"=="2000" {
local inclist "incearntrim incearnlnhrswin incworklnhrswin inctotlnwin"
}
if "`cenyear'"=="1990" {
local inclist "incearntrim incearnlnhrswin incworklnhrswin"
}



gen posearn=incearn
replace posearn=1 if incearn>0 & incearn!=.
*this is proportion of population earning wages. 1 is all.




gen informal=(hlthcov==60)
replace informal=. if hlthcov==99 | hlthcov==.

gen formal_imss=(mx00a_imss==1)
replace formal_imss=. if hlthcov==99


gen employ=1 if  empstatd>=100 &  empstatd<134
replace employ=0 if  (empstatd>=200 &  empstatd<330) | empstatd==380
*this is whether or not employed (excluding those at school according to empstatd-some of these guys are at school according to school)

gen employns=employ
replace employns=. if schatt==0
*this is whether or not employed (excluding those at school according to schatt)


gen employany=1 if  empstatd>=100 &  empstatd<134
replace employany=0 if  (empstatd>=200 &  empstatd<999)
*this is whether or not employed (including those at school as unemployed)

gen employanyns=employany
replace employanyns=0 if schatt==1 & empstatd!=0
*this is whether or not employed (including those at school as unemployed according to schatt)



gen leftfin=0 if (leftsch>0 & leftsch<43) | (leftsch>43 & leftsch<48)
replace leftfin=1 if leftsch==20
*this is proportion who say reason for leaving school is financial considerations

gen proptech=0 if (educmx>200 & educmx<230) | (educmx>300 & educmx<390)
replace proptech=1 if (educmx>200 & educmx<220) | (educmx>300 & educmx<320)
*this is proportion of people whose attainment is secondary school (lower or upper) who take tech track as opposed to general track.





/**
11: All Manuf
12: All services
13: All IMSS jobs
14: NEM2 (export2 definition, less conservative as includes industries with 40% exports like shoes etc.)

15: NEM1 (export1 definition, conservative as doesnt include industries with 40% exports like shoes etc.)
16: EM1  (export1 definition, conservative as doesnt include industries with 40% exports like shoes etc.)
18: Manuf + Services
19: EM2 (export2 definition, less conservative as includes industries with 40% exports like shoes etc.)
**/



if "`cenyear'"=="2000" {
*these are original codes
gen ind10=1 if (hcode==110	|	hcode==112	|	hcode==210	|	hcode==211	|	hcode==220	|	hcode==230	|	hcode==239	) & employ==1
gen ind11=1 if (hcode==310	|	hcode==311	|	hcode==312	|	hcode==314	|	hcode==315	|	hcode==321	|	hcode==322	|	hcode==323	|	hcode==324	|	hcode==325	|	hcode==326	|	hcode==330	|	hcode==331	|	hcode==332	|	hcode==333	|	hcode==335	|	hcode==336	|	hcode==337	) & employ==1
gen ind12=1 if (hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	) & employ==1
gen ind13=1 if (hcode==110	|	hcode==112	|	hcode==210	|	hcode==211	|	hcode==220	|	hcode==230	|	hcode==239	|	hcode==310	|	hcode==311	|	hcode==312	|	hcode==314	|	hcode==315	|	hcode==321	|	hcode==322	|	hcode==323	|	hcode==324	|	hcode==325	|	hcode==326	|	hcode==330	|	hcode==331	|	hcode==332	|	hcode==333	|	hcode==335	|	hcode==336	|	hcode==337	| 	hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	) & employ==1
gen ind18=1 if (hcode==310	|	hcode==311	|	hcode==312	|	hcode==314	|	hcode==315	|	hcode==321	|	hcode==322	|	hcode==323	|	hcode==324	|	hcode==325	|	hcode==326	|	hcode==330	|	hcode==331	|	hcode==332	|	hcode==333	|	hcode==335	|	hcode==336	|	hcode==337	| 	hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	) & employ==1
gen ind14=1 if (  hcode==310    |   hcode==326    |   hcode==325    |    hcode==311    |   hcode==321    |   hcode==322    |   hcode==324    |   hcode==330    |   hcode==323 ) & employ==1
gen ind19=1 if (  hcode==335    |   hcode==332    |   hcode==333   |   hcode==331 |   hcode==337 |    hcode==315        |   hcode==336    |   hcode==314       |   hcode==312   ) & employ==1


gen ind15=1 if (  hcode==310    |   hcode==326    |   hcode==325    |    hcode==311    |   hcode==321    |   hcode==322    |   hcode==324    |   hcode==330    |   hcode==323 |   hcode==312 |    hcode==315 ) & employ==1
gen ind16=1 if (  hcode==335    |   hcode==332    |   hcode==333   |   hcode==331 |   hcode==337        |   hcode==336    |   hcode==314    ) & employ==1      


gen ind26=1 if (  hcode==335    |   hcode==332    |   hcode==333   |   hcode==331   |   hcode==314   |   hcode==315      |   hcode==336  |   hcode==337     ) & employ==1   & cenyear==2000    
gen ind27=1 if ind13==1 & ind26!=1 & employ==1    & cenyear==2000  

gen ind25=1 if ind11==1 & ind26!=1 & employ==1    & cenyear==2000



}

if "`cenyear'"=="1990" {
gen ind90=ind if cenyear==1990
sort ind90
merge ind90 using "${dir}ind90_hcode_David.dta", _merge(_mergeHCODE90) keep(imms2cen90)
*this is cen90 code
gen ind10=1 if (imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	) & employ==1
gen ind11=1 if (imms2cen90==320    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357	|	imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346) & employ==1
gen ind12=1 if (imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	) & employ==1
gen ind13=1 if (imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	|	imms2cen90==320    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357	|	imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	| imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	) & employ==1
gen ind18=1 if (imms2cen90==320    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357	|	imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	| imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	) & employ==1
gen ind16=1 if (imms2cen90==320    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357) & employ==1
gen ind15=1 if (imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346) & employ==1
gen ind14=1 if (imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346) & employ==1
gen ind19=1 if (imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==320    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==341    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357) & employ==1


*have a cut off of 8 periods out of 16
gen ind26=1 if (imms2cen90==320   |   imms2cen90==322   |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325       |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349  ///
|   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357)  & employ==1 & cenyear==1990

gen ind27=1 if ( imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308 ///
|   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317  ///
|   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321   |   imms2cen90==326    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331  ///
|   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340  ///
|   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	| imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|  ///
imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	| ///
imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	| ///
imms2cen90==939	| imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	)  & employ==1 & cenyear==1990



gen  ind25=1 if ind11==1 & ind26!=1 & employ==1    & cenyear==1990


}



gen indall=1 if employ==1


local indylist ""
foreach n in 10 11 12 13 18 14 15 16 19 26  all {
replace ind`n'=0 if ind`n'==. & (empstatd>0 &  empstatd<999) 
*this takes value 1 if in that industry and zero for everyone else (including at school and at work)

gen ind`n'formimss=ind`n'
replace ind`n'formimss=0 if ind`n'formimss==1 &  mx00a_imss!=1
replace ind`n'formimss=. if mx00a_imss==9 // this is code for unknown

gen ind`n'form=ind`n'
replace ind`n'form=0 if ind`n'form==1 & informal==1
replace ind`n'form=. if informal==. // this is code for unknown
*this takes value 1 if both in that industry and formal, and zero for everyone else (including at school and at work)



*now just proportions of economically active
gen propind`n'=ind`n'
replace propind`n'=. if  employ==0 | employ==.

gen propind`n'form=ind`n'form
replace propind`n'form=. if  employ==0 | employ==.

gen propind`n'formimss=ind`n'formimss
replace propind`n'formimss=. if  employ==0 | employ==.

*now just proportions of not at school
gen propnsind`n'=ind`n'
replace propnsind`n'=. if  schatt==1 | employ==.

gen propnsind`n'form=ind`n'form
replace propnsind`n'form=. if  schatt==1 | employ==.

gen propnsind`n'formimss=ind`n'formimss
replace propnsind`n'formimss=. if  schatt==1 | employ==.


local indylist "`indylist' ind`n' ind`n'form ind`n'formimss propind`n' propind`n'form propind`n'formimss propnsind`n' propnsind`n'form propnsind`n'formimss"
}
*the ind and propind measures are:
*ind is proportion of people saying what their current situation is that are in ind`n' (and formal)
*propind is proportion of economically active that are in ind`n' (and formal)










#delimit ;
local  lhslistedit `"
posearn employ employns employany employanyns schatt leftfin proptech chdeathrate married chborn informal formal_imss  
yrschl2 `inclist'
`indylist' "';

local  varlistedit `"yrschl"';
#delimit cr

noi di "mean list: `lhslistedit'"
noi di "variance list: `varlistedit'"



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
*${dropvar5}
noi count
${dropvar6}



gen migrant=0 if  ( (muncenso==mig5mun${zone} | muncenso==mig5mun${zone}new2)  & (bplmx==stateold | bplmx==statenew) & cenyear==2000 ) |  ( (mgrate5==10 | mgrate5==11) & (bplmx==stateold | bplmx==statenew) & (cenyear==1990|cenyear==1996) )  |  ( (mgrate5==10 | mgrate5==11) & (cenyear==2006) ) 
replace migrant=1 if migrant==.

*so this is only non-migrants!!!!!!!!!!!!!!!!!!




noi tab migrant


*here is get migprop variables

preserve
keep if employ==1





foreach ends in 11 13 16 26  {
replace ind`ends'=. if ind`ends'==0
if "`cenyear'"=="2000" {
egen xmigpropform`ends'=wtmean(migrant) if mx00a_imss==1 & employ==1, by(muncenso ind`ends') weight(wtper)
egen migpropform_`cenyear'_`ends'=max(xmigpropform`ends'), by(muncenso)
drop xmigpropform`ends'
}
egen xmigprop`ends'=wtmean(migrant) if employ==1 , by(muncenso ind`ends') weight(wtper)
egen migprop_`cenyear'_`ends'=max(xmigprop`ends'), by(muncenso)
drop xmigprop`ends'
}

egen tag=tag(muncenso)
keep if tag==1
keep muncenso migprop*
save "${dir}mig_industry_counts_cen90_`cenyear'.dta", replace

pause on
pause here 

restore


*keep only non migrants.
keep if (migrant==0 & cenyear==2000) | (mgrate5==10 & cenyear==1990)
*keep if living there 5 years before in 1990 (since this is when I am looking).


keep muncenso age sex yobexp wtper  `lhslistedit' `varlistedit'

* to run without splitters should drop them here

compress




foreach var in `lhslistedit'   {
gen byte  ecl`var'=.
gen byte  mcl`var'=.
gen byte  fcl`var'=.

gen byte  eclwt`var'=.
gen byte  mclwt`var'=.
gen byte  fclwt`var'=.
}


foreach var in `varlistedit' {
gen byte ecl`var'=.
gen byte  mcl`var'=.
gen byte  fcl`var'=.

gen byte  eclwt`var'=.
gen byte  mclwt`var'=.
gen byte  fclwt`var'=.

gen byte  eclva`var'=.
gen byte  mclva`var'=.
gen byte  fclva`var'=.

gen byte  eclsd`var'=.
gen byte  mclsd`var'=.
gen byte  fclsd`var'=.

gen byte  eclcv`var'=.
gen byte  mclcv`var'=.
gen byte  fclcv`var'=.
}




egen mungroup=group(muncenso)


sort mungroup
save "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta", replace


*pause on
*pause here 




qui sum mungroup
local munnum=r(max)

noi di "Number of municipalities=`munnum'"
noi di "================================"
noi di "Municipality:"
noi di "================================"_n

forvalues i = 1/`munnum' {
noi di _c"`i' "
use if mungroup==`i' using "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta", clear




foreach var in `lhslistedit'  {
forvalues j = `agestart1'/`ageend1' {

summarize `var' [w=wtper] if age==`j'
replace ecl`var' = r(mean) if age==`j'
replace eclwt`var' = r(sum_w) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==1
replace mcl`var' = r(mean) if age==`j' 
replace mclwt`var' = r(sum_w) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==2
replace fcl`var' = r(mean) if age==`j' 
replace fclwt`var' = r(sum_w) if age==`j'

}
}


foreach var in `varlistedit' {
forvalues j = `agestart1'/`ageend1' {

summarize `var' [w=wtper] if age==`j'
replace ecl`var' = r(mean) if age==`j'
replace eclwt`var' = r(sum_w) if age==`j'
replace eclva`var' = r(Var) if age==`j'
replace eclsd`var' = r(sd) if age==`j'
replace eclcv`var' = r(sd)/r(mean) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==1
replace mcl`var' = r(mean) if age==`j' 
replace mclwt`var' = r(sum_w) if age==`j'
replace mclva`var' = r(Var) if age==`j'
replace mclsd`var' = r(sd) if age==`j'
replace mclcv`var' = r(sd)/r(mean) if age==`j'

summarize `var' [w=wtper] if age==`j' & sex==2
replace fcl`var' = r(mean) if age==`j' 
replace fclwt`var' = r(sum_w) if age==`j'
replace fclva`var' = r(Var) if age==`j'
replace fclsd`var' = r(sd) if age==`j'
replace fclcv`var' = r(sd)/r(mean) if age==`j'

}
}










keep muncenso mungroup age yobexp ecl*  mcl* fcl*

egen tagmunage=tag( muncenso age )
keep if tagmunage==1

drop tagmunage

save "${tempdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta", replace

}
*from i
noi di _n"================================"











use "${tempdir}regtempcohortusingmw${munwork}_`cenyear'1.dta", clear
forvalues i = 2/`munnum' {
append using "${tempdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta"
erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'`i'.dta"
}



noi di _n"========================="
noi di "Append Complete"
noi di "========================="






sort muncenso yobexp

save "${workdir}cohortmeans_DifInDif_mw${munwork}_`cenyear'.dta", replace

erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'1.dta"
cap erase "${tempdir}regtempcohortusingmw${munwork}_`cenyear'.dta"



}


}
*end of cenyear

