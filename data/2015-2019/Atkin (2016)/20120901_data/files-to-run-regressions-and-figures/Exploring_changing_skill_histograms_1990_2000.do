
*this file plots distribution of edication by industry

clear matrix
clear 
set mem 5000m
*set matsize 11000
*set maxvar 30000
set more off


if "`c(os)'"=="Unix" {
global firmdir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global inddir "/home/fac/da334/Data/Mexico/mexico_ss_Stata/"
global dir "/home/fac/da334/Work/Mexico/"
global dirmaq "/home/fac/da334/Work/Mexico/Maquiladora Data/"
}


if "`c(os)'"=="Windows" {
global censodir="C:\Data\Mexico\mexico_censo\"
global firmdir="C:\Data\Mexico\mexico_ss_Stata\"
*global workdir="C:\Data\Mexico\Stata10\"
global workdir="C:\Work\Mexico\"  
*local inddir="C:\Data\Mexico\mexico_ss_Stata\"
global dir="C:\Work\Mexico\"
global dirrev="C:/Work/Mexico/Revision/New_code/"
global dirgraph="C:/Work/Mexico/Revision/Graphs/Rev2/"
global tempdir="C:/Scratch/"
global resultdir="C:\Work\Mexico\Revision\regout\"
}






*here I get muni weights for reweightuing
*local dataspan "age>15 & age<34"



use if age>14 & age<51 & (cenyear==2000 | cenyear==1990) using "${workdir}temp7.dta", clear



gen experience2=age-16 if yrschl<=9
*replace experience2=age-yrschl-7 if yrschl==10
replace experience2=age-yrschl-6 if yrschl==10
replace experience2=age-yrschl-6 if yrschl>10 & yrschl<19
*this is nonlinear but matches up to  tab age if yrschl==11 & indimss4!=. when we get hike
local experience="all"

gen ind90=ind if cenyear==1990
gen ind00=ind if cenyear==2000

sort ind00
merge ind00 using "${dir}ind00_hcode_David.dta", _merge(_mergeHCODE00) keep(hcode00 hindustry_2)
sort ind90
merge ind90 using "${dir}ind90_hcode_David.dta", _merge(_mergeHCODE90) keep(hcode90 imms2cen90)


gen hcode=hcode00 if cenyear==2000
replace hcode=hcode90  if cenyear==1990

replace hcode00=1000 if mx00a_imss==2 & hcode00!=.
replace hcode00=. if mx00a_imss==. | mx00a_imss==9
*so now hcode00 takes a value of 1000 if informal

replace hrswrk1=. if hrswrk1>990



gen ind2000=.

replace ind2000=26 if  hcode==314 | hcode==315 | hcode==336    |   hcode==332    |   hcode==333   |   hcode==331 |   hcode==337 |   hcode==335

replace ind2000=250 if  hcode==310	|	hcode==311	|	hcode==312	|	hcode==321	|	hcode==322	| hcode==323	|	hcode==324	|	hcode==325	|	hcode==326	|	hcode==330	

replace ind2000=2400 if   hcode==110	|	hcode==112	|	hcode==210	|	hcode==211	|	hcode==220	|	hcode==230	|	hcode==239	| 	hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	



*this is cen90 code
gen ind1990=.

replace ind1990=26 if  imms2cen90==320   |   imms2cen90==322   |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325       |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349  ///
|   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357


replace ind1990=250 if  imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308 ///
|   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317  ///
|   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321   |   imms2cen90==326    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331  ///
|   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340  ///
|   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	

replace ind1990=2400 if   imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	| imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	



********nov13 added
gen v2ind2000_10=1 if hcode==112	|	hcode==210	|	hcode==211	|	hcode==220	|	hcode==230	|	hcode==239		
gen v2ind2000_12=1 if hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	
gen v2ind2000_14=1 if    hcode==310    |   hcode==326    |   hcode==325    |    hcode==311    |   hcode==321    |   hcode==322    |   hcode==324    |   hcode==330    |   hcode==323 
gen v2ind2000_19=1 if    hcode==335    |   hcode==332    |   hcode==333   |   hcode==331 |   hcode==337 |    hcode==315        |   hcode==336    |   hcode==314       |   hcode==312   

gen v2ind2000_15=1 if   hcode==310    |   hcode==326    |   hcode==325    |    hcode==311    |   hcode==321    |   hcode==322    |   hcode==324    |   hcode==330    |   hcode==323 |   hcode==312 |    hcode==315 
gen v2ind2000_16=1 if    hcode==335    |   hcode==332    |   hcode==333   |   hcode==331 |   hcode==337        |   hcode==336    |   hcode==314          


gen v2ind2000_26=1 if  hcode==314 | hcode==315 | hcode==336    |   hcode==332    |   hcode==333   |   hcode==331 |   hcode==337 |   hcode==335

gen v2ind2000_27=1 if   hcode==110	|	hcode==112	|	hcode==210	|	hcode==211	|	hcode==220	|	hcode==230	|	hcode==239	| hcode==310	|	hcode==311	|	hcode==312	|	hcode==321	|	hcode==322	| hcode==323	|	hcode==324	|	hcode==325	|	hcode==326	|	hcode==330	| 	hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	

gen v2ind2000_25=1 if  hcode==310	|	hcode==311	|	hcode==312	|	hcode==321	|	hcode==322	| hcode==323	|	hcode==324	|	hcode==325	|	hcode==326	|	hcode==330	

gen v2ind2000_24=1 if   hcode==110	|	hcode==112	|	hcode==210	|	hcode==211	|	hcode==220	|	hcode==230	|	hcode==239	| 	hcode==430	|	hcode==433	|	hcode==465	|	hcode==467	|	hcode==469	|	hcode==480	|	hcode==483	|	hcode==487	|	hcode==490	|	hcode==511	|	hcode==520	|	hcode==530	|	hcode==540	|	hcode==562	|	hcode==610	|	hcode==620	|	hcode==710	|	hcode==720	|	hcode==721	|	hcode==810	|	hcode==815	|	hcode==939	



gen v2ind1990_26=1 if  imms2cen90==320   |   imms2cen90==322   |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325       |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349  ///
|   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357

gen v2ind1990_27=1 if  imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308 ///
|   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317  ///
|   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321   |   imms2cen90==326    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331  ///
|   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340  ///
|   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	| imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	| imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	

gen v2ind1990_25=1 if  imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308 ///
|   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317  ///
|   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321   |   imms2cen90==326    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331  ///
|   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340  ///
|   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	

gen v2ind1990_24=1 if   imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	| imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	


gen v2ind1990_10=1 if imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239		
gen v2ind1990_12=1 if imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	
gen v2ind1990_13=1 if imms2cen90==110	|	imms2cen90==112	|	imms2cen90==210	|	imms2cen90==211	|	imms2cen90==220	|	imms2cen90==230	|	imms2cen90==239	|	imms2cen90==320    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357	|	imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346	| imms2cen90==430	|	imms2cen90==433	|	imms2cen90==465	|	imms2cen90==467	|	imms2cen90==469	|	imms2cen90==480	|	imms2cen90==483	|	imms2cen90==487	|	imms2cen90==490	|	imms2cen90==511	|	imms2cen90==520	|	imms2cen90==530	|	imms2cen90==540	|	imms2cen90==562	|	imms2cen90==610	|	imms2cen90==620	|	imms2cen90==710	|	imms2cen90==720	|	imms2cen90==721	|	imms2cen90==810	|	imms2cen90==815	|	imms2cen90==939	
gen v2ind1990_16=1 if imms2cen90==320    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357
gen v2ind1990_15=1 if imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==341    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346
gen v2ind1990_19=1 if imms2cen90==317    |   imms2cen90==318    |   imms2cen90==319    |   imms2cen90==320    |   imms2cen90==321    |   imms2cen90==322    |   imms2cen90==323    |   imms2cen90==324    |   imms2cen90==325    |   imms2cen90==326    |   imms2cen90==341    |   imms2cen90==347    |   imms2cen90==348    |   imms2cen90==349    |   imms2cen90==350    |   imms2cen90==351    |   imms2cen90==352    |   imms2cen90==353    |   imms2cen90==354    |   imms2cen90==355    |   imms2cen90==356    |   imms2cen90==357
gen v2ind1990_14=1 if imms2cen90==301    |   imms2cen90==302    |   imms2cen90==303    |   imms2cen90==304    |   imms2cen90==305    |   imms2cen90==306    |   imms2cen90==307    |   imms2cen90==308    |   imms2cen90==309    |   imms2cen90==310    |   imms2cen90==311    |   imms2cen90==312    |   imms2cen90==313    |   imms2cen90==314    |   imms2cen90==315    |   imms2cen90==316    |   imms2cen90==327    |   imms2cen90==328    |   imms2cen90==329    |   imms2cen90==330    |   imms2cen90==331    |   imms2cen90==332    |   imms2cen90==333    |   imms2cen90==334    |   imms2cen90==335    |   imms2cen90==336    |   imms2cen90==337    |   imms2cen90==338    |   imms2cen90==339    |   imms2cen90==340    |   imms2cen90==342    |   imms2cen90==343    |   imms2cen90==344    |   imms2cen90==345    |   imms2cen90==346
gen v2ind1990_17=1 if v2ind1990_13==1 & v2ind1990_16!=1


label define indcatz 10 "Other (not manuf. or serv.)" 11 "Manufacturing" 12 "Services" 13 "All Jobs"  14 "Non-Export Manuf. (old)" 15 "Non-Export Manuf." 16 "Export Manuf." 17 "Non Manufact." 18 "Manuf. and Services" 19 "Export Manuf. (old)" 25 "Non-Export Manuf." 26 "Export Manuf." 24 "Other Industries" 27 "Other Industries"





**cen90 codes
gen indcat=ind2000
replace indcat=ind1990 if cenyear==1990
gen indcatall=indcat
replace indcatall=20 if (cenyear==1990 & imms2cen90!=.) |  (cenyear==2000 & hcode!=.)







gen indcat_formal=indcat
replace indcat_formal=9999 if hlthcov==60
replace indcat_formal=. if hlthcov==99
replace indcat_formal=. if mx00a_imss!=1 & indcat_formal!=9999
*so these are informal workers in informal ind, and imss workers in other ind (so exclude pemex etc workers)

gen indcat_formal2cat=indcat_formal
replace indcat_formal2cat=2400 if indcat_formal2cat==250

gen indcatall_formal=indcatall
replace indcatall_formal=9999 if hlthcov==60
replace indcatall_formal=. if hlthcov==99
replace indcatall_formal=. if mx00a_imss!=1 & indcat_formal!=9999

gen indcatall_formalbyind=indcatall
replace indcatall_formalbyind=indcatall+70 if hlthcov==60 & indcatall!=.
replace indcatall_formalbyind=. if hlthcov==99
replace indcatall_formalbyind=. if mx00a_imss!=1 & indcat_formal<70

label define indcatx 14 "Non-Export Manuf." 19 "Export Manuf." 120 "Services" 9999 "Informal Jobs (Not Insured)" 20 "Other Sectors" 84 "Informal Non-Export Manuf." 89 "Informal Export Manuf." 82 "Informal Services" 90 "Informal Other Sectors"  2400 "Other Formal Sector Jobs" 250 "Non-Export Manufacturing" 26 "Export Manufacturing"
label values indcat indcatx
label values indcatall indcatx
label values indcat_formal indcatx
label values indcatall_formal indcatx
label values indcatall_formalbyind indcatx
label values indcat_formal2cat indcatx

local lab9999 "Informal Jobs (Not Insured)"
local lab2400 "Other Formal Sector Jobs"
local lab250 "Non-Export Manufacturing"
local lab26 "Export Manufacturing"
    



gen sample=1 if age>15 & age<29 & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
gen sampleall=1 if age>15 & age<29 & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150
gen sampleexp=1 if age>15 & age<29 & empstatd==110 & hcode!=. & hrswrk1>=20 & hrswrk1<=150 & experience2<=5 & experience2>=0 
*sample of employed youths





drop if yrschl==.
*drop if indimss9==.


gen allcats=1


*************************************************************************************************************************

*graphs

local labyrschl `" 6 "6" 9 "9" 12 "12" 16.5 "16/17" "'
local labschlz4cat `" 1 "0-8" 2 "9-11" 3 "12-15" 4 "16+" "'
local labschlz3cat `" 1 "0-8" 2 "9-11" 3 "12+" "'
local labrelyrschlcat `" 1 "<0.65" 2 "0.65-0.9" 3 "0.9-1.15" 4 ">1.15" "'
local lababsyrschlcat `" 1 "<-3" 2 "-3to-1" 3 "-1to1" 4 ">1" "'
local labblue2cat `" 1 "Blue Collar" 2 "White Collar" "'

local labage `"16(2)28"'
local titage "Age"
local tityrschl "Years of Schooling"


foreach samp in all  {  // 
foreach indcat in     indcat_formal  indcat_formal2cat { //
foreach school in  yrschl age {  //  
preserve




local experience="`samp'"
keep if sample`samp'==1


drop if `indcat'==.

egen totalswt=total(wtper), by(`indcat' `school' cenyear)
egen totalwt=total(wtper), by(`indcat' cenyear)
egen tag=tag(`indcat' `school' cenyear)



keep if tag==1
keep totalswt totalwt `indcat' `school' cenyear
gen propswt=totalswt/totalwt
reshape wide propswt totalswt totalwt, i(`indcat' `school') j(cenyear)



twoway bar  propswt2000  `school' ,  by(`indcat', rows(2) ixaxes imargin(tiny) note("`indcat'_`school'")) ///
xsize(5.5) ysize(3.2)	 xlabel(`lab`school'') xtitle("Employees `tit`school''") ytitle("Proportion of Workers (2000)") yscale(range(0)) 
graph save "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000", replace
graph export "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000.pdf", replace
graph export "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000.emf", replace



local gcomlist2 ""
levelsof `indcat'

foreach type in `r(levels)'  {
twoway  (bar  propswt2000  `school' if ind==`type', fcolor(edkblue)) (bar propswt2000  `school' if ind==26, fcolor(none) lcolor(eltblue)), title("`lab`type''") ytitle("") xtitle("")  xlabel(`lab`school'') legend(off) xsize(5.5) ysize(3.2) yscale(range(0))  // ylabel(0 50 100 150 200 250) yscale(range(-20 265))
graph save "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000_ind`type'", replace
local gcomlist2 "`gcomlist2' "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000_ind`type'.gph""
}

*repeat just for 26 so has no outline
foreach type in 26  {
twoway  bar  propswt2000  `school' if ind==`type', fcolor(edkblue) , title("`lab`type''") ytitle("") xtitle("")  xlabel(`lab`school'') legend(off) xsize(5.5) ysize(3.2) yscale(range(0))  // ylabel(0 50 100 150 200 250) yscale(range(-20 265))
graph save "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000_ind`type'", replace
}


graph combine   `gcomlist2' , col(4) ycom  imargin(tiny)  l1title("Proportion of Workers (2000)",  margin(small)  size(medium)) b1title("Employees `tit`school''", margin(small) size(medium) xoffset(0) yoffset(0) )  xsize(6.5) ysize(2) iscale(0.85)
graph save "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000_ind", replace
graph export   "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_2000_ind.pdf", replace


noi di `"graph combine   `gcomlist2' , col(4) ycom  imargin(tiny)  l1title("Proportion of Workers (2000)",  margin(small)  size(medium)) b1title("Employees `tit`school''", margin(small) size(medium) xoffset(0) yoffset(0) )  xsize(6.5) ysize(2) iscale(0.8)"'



cap noi egen lessthan12=total(propswt2000) if `school'<12 , by(`indcat') 
cap noi mean lessthan12 if `school'<12 , over(`indcat')

cap noi egen lessthan19=total(propswt2000) if `school'<19 , by(`indcat') 
cap noi mean lessthan19 if `school'<19 , over(`indcat')


twoway bar  propswt2000  `school' ,  by(`indcat', rows(1) ixaxes imargin(tiny) note("")) ///
xsize(7) ysize(3)	 xlabel(`lab`school'') xtitle("Employees Years of Schooling") ytitle("Proportion of Workers (2000)") yscale(range(0))
graph save "${dirgraph}temp_educdist_`indcat'_`school'_28_nw_`experience'_2000", replace



if regexm("`indcat'","formal")!=1 {
twoway bar  propswt1990  `school' ,  by(`indcat', rows(2) ixaxes imargin(tiny) note("`indcat'_`school'")) ///
xsize(5.5) ysize(3.2)	 xlabel(`lab`school'') xtitle("Employees Years of Schooling") ytitle("Proportion of Workers (1990)") yscale(range(0))
graph save "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_1990", replace
graph export "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_1990.pdf", replace
graph export "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_1990.emf", replace

twoway bar  propswt1990  `school' ,  by(`indcat', rows(1) ixaxes imargin(tiny) note("")) ///
xsize(7) ysize(3)	 xlabel(`lab`school'') xtitle("Employees Years of Schooling") ytitle("Proportion of Workers (1990)")  yscale(range(0))
graph save "${dirgraph}temp_educdist_`indcat'_`school'_28_nw_`experience'_1990", replace



graph combine "${dirgraph}temp_educdist_`indcat'_`school'_28_nw_`experience'_1990.gph"  "${dirgraph}temp_educdist_`indcat'_`school'_28_nw_`experience'_2000.gph", xcommon rows(2) iscale(0.67) imargin(0)
graph save "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_combo_90_20", replace
graph export "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_combo_90_20.pdf", replace
graph export "${dirgraph}educdist_october2014_`indcat'_`school'_28_nw_`experience'_combo_90_20.emf", replace

erase "${dirgraph}temp_educdist_`indcat'_`school'_28_nw_`experience'_1990.gph" 
erase "${dirgraph}temp_educdist_`indcat'_`school'_28_nw_`experience'_2000.gph" 


}

restore
}
}
}












