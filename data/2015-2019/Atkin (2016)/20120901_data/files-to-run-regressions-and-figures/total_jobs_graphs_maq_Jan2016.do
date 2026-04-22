



if "`c(os)'"=="Unix" {
local tempdir="/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
local dir="/home/fac/da334/Work/Mexico/"
}

if "`c(os)'"=="Windows" {
local dir="C:\Work\Mexico\"
local tempdir="C:\Data\Mexico\mexico_ss_Stata\"
local dirgraph="C:\Work\Mexico\Revision\Graphs\"
}


clear
set mem 1000m



use muncenso year emp00* empImaq00* deltaemp50*  deltaemp00*  deltaempImaq50* deltaempImaq00* deltaempImaqe50* deltaempImaqe00* deltaempImaqec50* deltaempImaqec00*  using "`tempdir'newindcen90_simpleMerge_skill.dta", clear


local lister "emp00 empImaq00 deltaemp50  deltaemp00 deltaempImaq50 deltaempImaq00 deltaempImaqe50 deltaempImaqe00 deltaempImaqec50 deltaempImaqec00"



local listermttot: subinstr local lister " " " mttot", all
*local listermttot=regexr("`lister'"," "," mttot")
local listermttot "mttot`listermttot'"



drop if muncenso==12 




foreach thing in `lister'  {







local cut ""

cap gen `thing'`cut'11=`thing'`cut'320    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357	+	`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346
cap gen `thing'`cut'13=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+	`thing'`cut'320    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357	+	`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346	+ `thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'16=`thing'`cut'320    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357
cap gen `thing'`cut'15=`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346
cap gen `thing'`cut'19=`thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'320    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'341    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357

cap gen `thing'`cut'17=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+ `thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346	+ `thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	


*have a cut off of 8 periods out of 16
cap gen `thing'`cut'26=`thing'`cut'320   +   `thing'`cut'322   +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325       +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349  ///
+   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357

cap gen `thing'`cut'27=`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308 ///
+   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317  ///
+   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321   +   `thing'`cut'326    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331  ///
+   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340  ///
+   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346	+ `thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	+ `thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	

cap gen `thing'`cut'25=`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308 ///
+   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317  ///
+   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321   +   `thing'`cut'326    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331  ///
+   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340  ///
+   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346	

cap gen `thing'`cut'24=`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	+ `thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	




drop `thing'`cut'???

}




forval n=10/99 {
foreach type in  `lister'  {
cap egen mttot`type'`n'=total(`type'`n'), by(year)
}
}


egen tag=tag(year)
keep if tag==1
keep year mttot*


reshape long  `listermttot' ,i(year) j(ind)

sort ind year

drop if year==1985


drop if year==2000



local lab19 "Export Manufacturing"
local lab33 "Low-Tech Export Manuf."
local lab34 "Mid-Tech Export Manuf."
local lab26 "Export Manufacturing"
local lab25 "Non-Export Manufacturing"
local lab24 "Other Industries"
local lab27 "Other Industries"


egen tot=total(mttotdeltaemp00), by(ind)
egen totmaq=total( mttotdeltaempImaq00 ), by(ind)
egen totmaqe=total( mttotdeltaempImaqe00 ), by(ind)
mean tot totmaq totmaqe, over(ind)
pause on
pause here 
egen tot50=total(mttotdeltaemp50), by(ind)
egen totmaq50=total( mttotdeltaempImaq50 ), by(ind)
mean tot50 tot, over(ind)


foreach var of varlist mttot* {
replace `var'=`var'/1000
}


foreach type in 26 25 24  {
twoway  (bar mttotdeltaemp00 year if ind==`type', fcolor(edkblue)) (bar mttotdeltaempImaq00 year if ind==`type', fcolor(eltblue)), title("`lab`type''") ytitle("") xtitle("") xlabel(1986 "1986" 1988 "1988"  1990 "1990" 1992 "1992" 1994 "1994" 1996 "1996" 1998 "1998") legend( size(small) label(1 "Change in Formal Employment") label(2 "Change in Maquiladora Employment"))   xsize(5.5) ysize(3.2)  // ylabel(0 50 100 150 200 250) yscale(range(-20 265))
graph save "`dirgraph'maqjobgrowth_deltaemp00_`type'", replace
local gcomlist2 "`gcomlist2' "`dirgraph'maqjobgrowth_deltaemp00_`type'.gph""
}

grc1leg   `gcomlist2' , col(3) ycom iscale(0.5) l1title("Employment Change (1000's)",  margin(small) size(medium)) b1title("Year", margin(small) size(medium) xoffset(0) yoffset(0) ) ring(3)
graph save "`dirgraph'maqjobgrowthcombo_deltaemp00", replace
graph export   "`dirgraph'maqjobgrowthcombo3cat_deltaemp00.eps", replace





























preserve

foreach type in  fem00 male00 emp00 {
cap gen ettot`type'expratio=mttot`type'97/mttot`type'99
replace ettot`type'expratio=0 if mttot`type'97==0 & mttot`type'99==0
cap gen ettot`type'exp34ratio=mttot`type'34/mttot`type'99
replace ettot`type'exp34ratio=0 if mttot`type'34==0 & mttot`type'99==0
}

egen tagmun=tag(muncenso)
keep if tagmun==1
keep ettot* muncenso mttot*99 mttot*97


sort ettotemp00expratio
gen munexportratio=_n

keep munexportratio muncenso ettotemp00expratio
label variable ettotemp00expratio "Proportion of Total Annual Jobs in Export Industries"
sort muncenso



pause on
pause here 

restore
*forval n=1/99 {
foreach n in 24 33 34 26 29 {
foreach type in  fem00 male00 emp00 {
cap egen tttot`type'`n'=total(`type'`n'), by(year)
}
}
egen tagyear=tag(year)
keep if tagyear==1


keep tttot* year

browse  year tttotemp0024 tttotemp0033 tttotemp0034 tttotemp0026 tttotemp0029

pause on
pause here


/*
gen totalfem=tttotfem0023+tttotfem0024
gen exratio=tttotfem0023/(tttotfem0023+tttotfem0024)
browse year tttotfem0023 totalfem  exratio
*/

/**
browse  year tttotemp002 tttotemp0033 tttotemp0022 tttotemp007 tttotemp0036

twoway line  tttotemp002 tttotemp0033 tttotemp0022 tttotemp007 tttotemp0036   year
**/




