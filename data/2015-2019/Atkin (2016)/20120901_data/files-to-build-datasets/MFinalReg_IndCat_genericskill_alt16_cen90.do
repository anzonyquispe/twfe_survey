
* so this is the key file for forming my service and manufacturing sector form the 40 odd hcodes, as well as doing all the industry level interactions.
* the local `listhcode' is pulled from this file, depending on what interaction terms I choose.


/**----------------------------------------------------------------------**/
*here I chose the variables I pull form the various wide files with hcoded means	
*if these get too long then it fails to do subtitutions properly, so split up.
*so check this. There should be no asterisks appearing in output (if there are, shorten one of the strings)
qui {
							

if "$dircode"=="" {
global dircode="C:/Work/Mexico/Revision/New_code/"
}

/**
Note:
For the adjusted measures:
migadj: require migadj in skill3cat and mig in skill3cat_wages, becomes m 
infadj: require infadj in skill3cat and inf in skill3cat_wages, becomes a
will go wrong if include adj values inside the wages!

inf is non-migrant low experience.
also cannot do pure inf or pure mig wage specification with current code

**/

#delimit ;

local listskill3cat190 "  
indmschlz3cat1exp9s_*    indmschlz3cat2exp9s_* 	   indmschlz3cat3exp9s_* 
";





local listskill3cat190_wages "  
indmveschlz3cat1exp9s_*    indmveschlz3cat2exp9s_* 	   indmveschlz3cat3exp9s_* 
indmweschlz3cat1exp9s_*    indmweschlz3cat2exp9s_* 	   indmweschlz3cat3exp9s_* 
";



local listskill3cat190_malewages " 
indhveschlz3cat1exp9s_*    indhveschlz3cat2exp9s_* 	   indhveschlz3cat3exp9s_*  
indhweschlz3cat1exp9s_*    indhweschlz3cat2exp9s_* 	   indhweschlz3cat3exp9s_*
";



#delimit cr



/*

*/







/**
If using the code90 spec, then cant use the 2cat or 4cat types since there were too many of them to reshape. They are saved with subscript "oddcat" if want them.
**/



*so sc are the school variables, wp wage premia, sp skill premia. The new mun averages are ps and mw. Plain skill bins are sc 
*normal, migrant, experience and include informal: lets do all of these seperately
*so sc are the school variables, wp wage premia, sp skill premia. The new mun averages are ps and mw. Plain skill bins are sc 
*normal, migrant, experience and include informal: lets do all of these seperately
#delimit ;
local listinteract "`listskill3cat190' `listskill3cat190_wages' `listskill3cat190_malewages'" ; 
#delimit cr

local listinteract: subinstr local listinteract "*" "", all

local listnicexpmpopx: subinstr local listnicexpmpop "*" "", all
local listnicexpmpopx2: subinstr local listnicexpmpopx "ind" "", all





foreach thing in deltaemp  {
foreach interact in `listinteract'  {
include "${dircode}MFinalReg_IndCat_cleannames.do"
}
}

foreach thing in deltaemp  {
foreach interact in  `listnicexpmpopx2'  {
noi di "`thing'`interact'_"
}
}

}
*add pause here to see the variables




local clean ""

 
/**----------------------------------------------------------------------**/


cap {
sort muncenso
merge m:1 muncenso using "${workdir}Initial_SexRatios_from_IMSS_data${herf2}.dta", generate(_merge9999)  keepusing(muncenso `listsexcatinitial') 
drop _merge9999
}


cap {
sort muncenso year
merge m:1 muncenso year using "${workdir}Annual_SexRatios_from_IMSS_data${herf2}.dta", generate(_merge9998)  keepusing(muncenso `listsexcatannual') 
drop _merge9998
}

cap {
sort muncenso year
merge m:1  muncenso  year using "${workdir}Hirefire_SexRatios_from_IMSS_data${herf2}.dta", generate(_merge9997)  keepusing(muncenso `listsexcathirefire') 
drop _merge9997
}


cap {
sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles2000_by_Mun_industry_wide_bothsexes${herf2}.dta", //
_merge(_merge9999)  keep(muncenso `listskillcat120' `listskillcat220' `listskillcat320' `listskillcat420') 
drop _merge9999
}



cap {
sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_3cats_combo_newexp.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat190') 
drop _merge9999
}


sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_5cats_combo_newexp.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat290') 
drop _merge9999






sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_2cats_combo_newexp.dta", generate(_merge9999)  keepusing(muncenso `listskill2cat190' ) 
drop _merge9999

sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_2cats_combo.dta", generate(_merge9999)  keepusing(muncenso `listskill2cat290') 
drop _merge9999

sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_3cats_wages_newexp.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat190_wages'  ) 
drop _merge9999

sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_3cats_wages_renewexp.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat390_wages'  ) 
drop _merge9999

cap {
sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_5cats_wages_newexp.dta", generate(_merge9999)  keepusing(muncenso  `listskill3cat290_wages') 
drop _merge9999
}


cap {
sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_2cats_wages_newexp.dta", generate(_merge9999)  keepusing(muncenso `listskill2cat190_wages' `listskill2cat290_wages') 
drop _merge9999
}


sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_widemale_bothsexes${herf2}_3cats_wages_newexpw.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat190_malewages') 
drop _merge9999


cap {
sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_widefem_bothsexes${herf2}_3cats_wages_newexpw.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat190_femwages') 
drop _merge9999
}



cap {
gen id=1
sort id
merge id using "${workdir}Skill_coefs1990_by_industry_wide_cen90.dta", _merge(_coefskill) keep(id `listcoefskill1' `listcoefskill2' `listcoefskill3')
drop _coefskill id
}






cap {
sort muncenso
merge muncenso using "${workdir}Skill_Wage_by_Mun_industry_wide.dta", _merge(indschmerge) keep(muncenso `listskillwagem1' `listskillwagem2' `listskillwagem3' `listskillwagem4')
drop indschmerge

cap mvencode `listskillwagem1' `listskillwagem2' `listskillwagem3' `listskillwagem4' , mv(0) override

}


cap {
sort muncenso
merge muncenso using "${dir}Variance_by_industry_mun_wide.dta", _merge(_merge9999)  keep(muncenso `listvar') 
drop _merge9999

cap mvencode `listvar', mv(0) override
}

cap {
sort muncenso
merge muncenso using "${dir}Transitionp_by_industry_mun_wide.dta", _merge(_merge9999) keep(muncenso `listtrans') 
drop _merge9999

cap mvencode `listtrans' , mv(0) override
}



cap {
sort muncenso
merge muncenso using "${dir}Stats_by_industry_mun_wide_skill.dta", _merge(_merge11) keep(muncenso `liststats') 
drop _merge11

cap mvencode `liststats' , mv(0) override
}

cap {
gen marker=1
sort marker
merge marker using "${dir}Skill_by_industry_allyears_wide.dta", _merge(indschmerge) keep(marker `listskill1' `listskill2')
drop indschmerge


sort marker
merge marker using "${dir}wage_skill_prem_wide.dta", _merge(indschmerge) keep(marker `listwprem1' `listwprem2' `listwprem3'  `listwprem4') 
drop indschmerge
}

cap {
sort marker
merge marker using "${dir}Nicita_hcode_exports8699_wide.dta", _merge(_merge9999) keep(marker `listnicita') 
drop _merge9999
}

cap {
sort marker
merge marker using "${dir}Growth_by_industry_wide.dta", _merge(_merge9999) keep(marker `listgrowth') 
drop _merge9999
}

cap {
sort marker year
merge marker using "${dir}Mgrowth_by_industry_wide.dta", _merge(_merge9999) keep(marker `listmgrowth') 
drop _merge9999
}





cap {
sort marker
merge marker using "${dir}Variance_by_industrympop_wide.dta", _merge(_merge9999) keep(marker `listvarmpop') 
drop _merge9999
}

cap {
sort year
merge year using "${dir}Nicita_ExportsOnly_wide.dta", _merge(_merge9999) keep(year `listnicexpmpop') 
drop _merge9999

sort year
merge year using "${dir}Nicita_ExportsPWOnly_wide.dta", _merge(_merge9999) keep(year `listnicexppw') 
drop _merge9999
}




drop marker



*******************
*this bit depends on codes I want to go to at the end

foreach thing in $listfirm  {
foreach cut in 00 50 {

if "${herf2}"=="" {
* gen `thing'`cut'10=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	
cap gen `thing'`cut'11=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	
cap gen `thing'`cut'12=`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'13=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+	`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'18=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'14=   `thing'`cut'310    +   `thing'`cut'326    +   `thing'`cut'325    +    `thing'`cut'311    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'324    +   `thing'`cut'330    +   `thing'`cut'323 
cap gen `thing'`cut'19=   `thing'`cut'335    +   `thing'`cut'332    +   `thing'`cut'333   +   `thing'`cut'331 +   `thing'`cut'337 +    `thing'`cut'315        +   `thing'`cut'336    +   `thing'`cut'314       +   `thing'`cut'312   
}




if "${herf2}"=="_cen90" {

cap gen `thing'`cut'11=`thing'`cut'320    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357	+	`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346
cap gen `thing'`cut'13=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+	`thing'`cut'320    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357	+	`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346	+ `thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'16=`thing'`cut'320    +   `thing'`cut'323    +   `thing'`cut'324    +   `thing'`cut'325    +   `thing'`cut'326    +   `thing'`cut'347    +   `thing'`cut'348    +   `thing'`cut'349    +   `thing'`cut'350    +   `thing'`cut'351    +   `thing'`cut'352    +   `thing'`cut'353    +   `thing'`cut'354    +   `thing'`cut'355    +   `thing'`cut'356    +   `thing'`cut'357
cap gen `thing'`cut'15=`thing'`cut'301    +   `thing'`cut'302    +   `thing'`cut'303    +   `thing'`cut'304    +   `thing'`cut'305    +   `thing'`cut'306    +   `thing'`cut'307    +   `thing'`cut'308    +   `thing'`cut'309    +   `thing'`cut'310    +   `thing'`cut'311    +   `thing'`cut'312    +   `thing'`cut'313    +   `thing'`cut'314    +   `thing'`cut'315    +   `thing'`cut'316    +   `thing'`cut'317    +   `thing'`cut'318    +   `thing'`cut'319    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'327    +   `thing'`cut'328    +   `thing'`cut'329    +   `thing'`cut'330    +   `thing'`cut'331    +   `thing'`cut'332    +   `thing'`cut'333    +   `thing'`cut'334    +   `thing'`cut'335    +   `thing'`cut'336    +   `thing'`cut'337    +   `thing'`cut'338    +   `thing'`cut'339    +   `thing'`cut'340    +   `thing'`cut'341    +   `thing'`cut'342    +   `thing'`cut'343    +   `thing'`cut'344    +   `thing'`cut'345    +   `thing'`cut'346

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

}




}
}


local listhcode ""

xtset muncenso year



noi di "Here: `listnicexpcreate'"


cap drop total* 
cap drop prop*



foreach interact in `listinteract' {
foreach thing in $listfirm  {

include "${dircode}MFinalReg_IndCat_cleannames.do"
local listhcode "`listhcode' `thing'`abbrev'`ends'_"

noi di "`interact', `thing'`abbrev'`ends'_`cut'11" 



*******************
*this bit depends on codes I want to go to at the end


foreach cut in 00 50 {


*Problem: 1) why dont pa3cat and wnpa3cat have the same missing cells- if so then could just set all missing interacts to zero and jobs would drop out.
*really want to have same sample in the non interatced and interacted if want to run in same regression. this is now done with teh z variables


*might be right up against length constarint... the X rename wont work

*for wage cat measures I must interact the number of jobs with the wage ratio in that job. Note wage measures must come before prop measures as prop is deleted after run thourgh
if regexm("`interact'","ind.w.*cat.*")==1 | regexm("`interact'","ind.v.*cat.*")==1 | regexm("`interact'","ind.a.*cat.*")==1 {
local propinteract=regexr("`interact'","w.","")
local propinteract=regexr("`propinteract'","v.","")
local propinteract=regexr("`propinteract'","indmage","indm")
local propinteract=regexr("`propinteract'","indhage","indh")
local propinteract=regexr("`propinteract'","indfage","indf")
local propinteract=regexr("`propinteract'","migpur","madjpur")
local propinteract=regexr("`propinteract'","mig","migadj")
local propinteract=regexr("`propinteract'","infpur","iadjpur")
local propinteract=regexr("`propinteract'","inf","infadj")
local propinteract=regexr("`propinteract'","cme","cmeadj")
local propinteract=regexr("`propinteract'","dme","dmeadj")
local propinteract=regexr("`propinteract'","bme","bmeadj")
local propinteract=regexr("`propinteract'","schlx","schlz")

*local propinteract=regexr("`propinteract'","exp","nor")
*why this?
*since the adj wages have been multiplied by proportion of migrant jobs, we will be doing this twice if multiply both. so take one off the skill shock.
*this requires I have infadj in skill shocks and inf in wage shocks

if regexm("`interact'","indh*")==1 {
local propinteract=regexr("`propinteract'","indh","indm")
}
*so if male wages just use total emp to multiply.





		if "${herf2}"=="" {
		* gen `thing'`abbrev'`ends'_`cut'10=`thing'`cut'110*`interact'110*`propinteract'110	+	`thing'`cut'112*`interact'112*`propinteract'112	+	`thing'`cut'210*`interact'210*`propinteract'210	+	`thing'`cut'211*`interact'211*`propinteract'211	+	`thing'`cut'220*`interact'220*`propinteract'220	+	`thing'`cut'230*`interact'230*`propinteract'230	+	`thing'`cut'239*`interact'239*`propinteract'239	
		cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'310*`interact'310*`propinteract'310	+	`thing'`cut'311*`interact'311*`propinteract'311	+	`thing'`cut'312*`interact'312*`propinteract'312	+	`thing'`cut'314*`interact'314*`propinteract'314	+	`thing'`cut'315*`interact'315*`propinteract'315	+	`thing'`cut'321*`interact'321*`propinteract'321	+	`thing'`cut'322*`interact'322*`propinteract'322	+	`thing'`cut'323*`interact'323*`propinteract'323	+	`thing'`cut'324*`interact'324*`propinteract'324	+	`thing'`cut'325*`interact'325*`propinteract'325	+	`thing'`cut'326*`interact'326*`propinteract'326	+	`thing'`cut'330*`interact'330*`propinteract'330	+	`thing'`cut'331*`interact'331*`propinteract'331	+	`thing'`cut'332*`interact'332*`propinteract'332	+	`thing'`cut'333*`interact'333*`propinteract'333	+	`thing'`cut'335*`interact'335*`propinteract'335	+	`thing'`cut'336*`interact'336*`propinteract'336	+	`thing'`cut'337*`interact'337*`propinteract'337	
		cap gen `thing'`abbrev'`ends'_`cut'12=`thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	
		cap gen `thing'`abbrev'`ends'_`cut'13=`thing'`cut'110*`interact'110*`propinteract'110	+	`thing'`cut'112*`interact'112*`propinteract'112	+	`thing'`cut'210*`interact'210*`propinteract'210	+	`thing'`cut'211*`interact'211*`propinteract'211	+	`thing'`cut'220*`interact'220*`propinteract'220	+	`thing'`cut'230*`interact'230*`propinteract'230	+	`thing'`cut'239*`interact'239*`propinteract'239	+	`thing'`cut'310*`interact'310*`propinteract'310	+	`thing'`cut'311*`interact'311*`propinteract'311	+	`thing'`cut'312*`interact'312*`propinteract'312	+	`thing'`cut'314*`interact'314*`propinteract'314	+	`thing'`cut'315*`interact'315*`propinteract'315	+	`thing'`cut'321*`interact'321*`propinteract'321	+	`thing'`cut'322*`interact'322*`propinteract'322	+	`thing'`cut'323*`interact'323*`propinteract'323	+	`thing'`cut'324*`interact'324*`propinteract'324	+	`thing'`cut'325*`interact'325*`propinteract'325	+	`thing'`cut'326*`interact'326*`propinteract'326	+	`thing'`cut'330*`interact'330*`propinteract'330	+	`thing'`cut'331*`interact'331*`propinteract'331	+	`thing'`cut'332*`interact'332*`propinteract'332	+	`thing'`cut'333*`interact'333*`propinteract'333	+	`thing'`cut'335*`interact'335*`propinteract'335	+	`thing'`cut'336*`interact'336*`propinteract'336	+	`thing'`cut'337*`interact'337*`propinteract'337	+ 	`thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	
		cap gen `thing'`abbrev'`ends'_`cut'18=`thing'`cut'310*`interact'310*`propinteract'310	+	`thing'`cut'311*`interact'311*`propinteract'311	+	`thing'`cut'312*`interact'312*`propinteract'312	+	`thing'`cut'314*`interact'314*`propinteract'314	+	`thing'`cut'315*`interact'315*`propinteract'315	+	`thing'`cut'321*`interact'321*`propinteract'321	+	`thing'`cut'322*`interact'322*`propinteract'322	+	`thing'`cut'323*`interact'323*`propinteract'323	+	`thing'`cut'324*`interact'324*`propinteract'324	+	`thing'`cut'325*`interact'325*`propinteract'325	+	`thing'`cut'326*`interact'326*`propinteract'326	+	`thing'`cut'330*`interact'330*`propinteract'330	+	`thing'`cut'331*`interact'331*`propinteract'331	+	`thing'`cut'332*`interact'332*`propinteract'332	+	`thing'`cut'333*`interact'333*`propinteract'333	+	`thing'`cut'335*`interact'335*`propinteract'335	+	`thing'`cut'336*`interact'336*`propinteract'336	+	`thing'`cut'337*`interact'337*`propinteract'337	+ 	`thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	
		cap gen `thing'`abbrev'`ends'_`cut'14=   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'325*`interact'325*`propinteract'325    +    `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'323*`interact'323*`propinteract'323 
		cap gen `thing'`abbrev'`ends'_`cut'19=   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333   +   `thing'`cut'331*`interact'331*`propinteract'331 +   `thing'`cut'337*`interact'337*`propinteract'337 + `thing'`cut'315*`interact'315*`propinteract'315        +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'314*`interact'314*`propinteract'314       +   `thing'`cut'312*`interact'312*`propinteract'312   
		}
		
		if "${herf2}"=="_cen90" {
		
		if regexm("`interact'","ind.a.*cat.*")==1 {
		noi di "gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'320*`interact'320*`propinteract'320"
		}

		if regexm("`interact'","ind.v.*cat.*")==1 {
		noi di "gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'320*`interact'320*`propinteract'320"
		}
		
		cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'320*`interact'320*`propinteract'320    +   `thing'`cut'323*`interact'323*`propinteract'323    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'325*`interact'325*`propinteract'325    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'347*`interact'347*`propinteract'347    +   `thing'`cut'348*`interact'348*`propinteract'348    +   `thing'`cut'349*`interact'349*`propinteract'349    +   `thing'`cut'350*`interact'350*`propinteract'350    +   `thing'`cut'351*`interact'351*`propinteract'351    +   `thing'`cut'352*`interact'352*`propinteract'352    +   `thing'`cut'353*`interact'353*`propinteract'353    +   `thing'`cut'354*`interact'354*`propinteract'354    +   `thing'`cut'355*`interact'355*`propinteract'355    +   `thing'`cut'356*`interact'356*`propinteract'356    +   `thing'`cut'357*`interact'357*`propinteract'357	+	`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308    +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317    +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340    +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346
		cap gen `thing'`abbrev'`ends'_`cut'13=`thing'`cut'110*`interact'110*`propinteract'110	+	`thing'`cut'112*`interact'112*`propinteract'112	+	`thing'`cut'210*`interact'210*`propinteract'210	+	`thing'`cut'211*`interact'211*`propinteract'211	+	`thing'`cut'220*`interact'220*`propinteract'220	+	`thing'`cut'230*`interact'230*`propinteract'230	+	`thing'`cut'239*`interact'239*`propinteract'239	+	`thing'`cut'320*`interact'320*`propinteract'320    +   `thing'`cut'323*`interact'323*`propinteract'323    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'325*`interact'325*`propinteract'325    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'347*`interact'347*`propinteract'347    +   `thing'`cut'348*`interact'348*`propinteract'348    +   `thing'`cut'349*`interact'349*`propinteract'349    +   `thing'`cut'350*`interact'350*`propinteract'350    +   `thing'`cut'351*`interact'351*`propinteract'351    +   `thing'`cut'352*`interact'352*`propinteract'352    +   `thing'`cut'353*`interact'353*`propinteract'353    +   `thing'`cut'354*`interact'354*`propinteract'354    +   `thing'`cut'355*`interact'355*`propinteract'355    +   `thing'`cut'356*`interact'356*`propinteract'356    +   `thing'`cut'357*`interact'357*`propinteract'357	+	`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308    +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317    +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340    +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346	+ `thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	
		cap gen `thing'`abbrev'`ends'_`cut'16=`thing'`cut'320*`interact'320*`propinteract'320    +   `thing'`cut'323*`interact'323*`propinteract'323    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'325*`interact'325*`propinteract'325    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'347*`interact'347*`propinteract'347    +   `thing'`cut'348*`interact'348*`propinteract'348    +   `thing'`cut'349*`interact'349*`propinteract'349    +   `thing'`cut'350*`interact'350*`propinteract'350    +   `thing'`cut'351*`interact'351*`propinteract'351    +   `thing'`cut'352*`interact'352*`propinteract'352    +   `thing'`cut'353*`interact'353*`propinteract'353    +   `thing'`cut'354*`interact'354*`propinteract'354    +   `thing'`cut'355*`interact'355*`propinteract'355    +   `thing'`cut'356*`interact'356*`propinteract'356    +   `thing'`cut'357*`interact'357*`propinteract'357
		cap gen `thing'`abbrev'`ends'_`cut'15=`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308    +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317    +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340    +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346
		cap gen `thing'`abbrev'`ends'_`cut'17=`thing'`cut'110*`interact'110*`propinteract'110	+	`thing'`cut'112*`interact'112*`propinteract'112	+	`thing'`cut'210*`interact'210*`propinteract'210	+	`thing'`cut'211*`interact'211*`propinteract'211	+	`thing'`cut'220*`interact'220*`propinteract'220	+	`thing'`cut'230*`interact'230*`propinteract'230	+	`thing'`cut'239*`interact'239*`propinteract'239	+ `thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308    +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317    +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340    +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346	+ `thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	


*have a cut off of 8 periods out of 16
cap gen `thing'`abbrev'`ends'_`cut'26=`thing'`cut'320*`interact'320*`propinteract'320   +   `thing'`cut'322*`interact'322*`propinteract'322   +   `thing'`cut'323*`interact'323*`propinteract'323    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'325*`interact'325*`propinteract'325       +   `thing'`cut'347*`interact'347*`propinteract'347    +   `thing'`cut'348*`interact'348*`propinteract'348    +   `thing'`cut'349*`interact'349*`propinteract'349   +   `thing'`cut'350*`interact'350*`propinteract'350    +   `thing'`cut'351*`interact'351*`propinteract'351    +   `thing'`cut'352*`interact'352*`propinteract'352    +   `thing'`cut'353*`interact'353*`propinteract'353    +   `thing'`cut'354*`interact'354*`propinteract'354    +   `thing'`cut'355*`interact'355*`propinteract'355    +   `thing'`cut'356*`interact'356*`propinteract'356    +   `thing'`cut'357*`interact'357*`propinteract'357

cap gen `thing'`abbrev'`ends'_`cut'27=`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308  +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317   +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321   +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331   +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340   +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346	+ `thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	+ `thing'`cut'110*`interact'110*`propinteract'110	+	`thing'`cut'112*`interact'112*`propinteract'112	+	`thing'`cut'210*`interact'210*`propinteract'210	+	`thing'`cut'211*`interact'211*`propinteract'211	+	`thing'`cut'220*`interact'220*`propinteract'220	+	`thing'`cut'230*`interact'230*`propinteract'230	+	`thing'`cut'239*`interact'239*`propinteract'239	

cap gen `thing'`abbrev'`ends'_`cut'25=`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308  +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317   +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321   +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331   +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340   +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346	

	
		}



		/*
		if regexm("`interact'","ind.w.*cat.*pur.*")==1 | regexm("`interact'","ind.v.*cat.*pur.*")==1 {
		forval n=100/999 {
		cap drop `interact'`n' `propinteract'`n'
		cap rename X`interact'`n' `interact'`n'
		cap rename X`propinteract'`n' `propinteract'`n'
		}
		}
		*/
}
else {
	if regexm("`interact'","pur")==1 {
	forval n=100/999 {
	cap gen X`interact'`n'=`interact'`n'
	*cap replace `interact'`n'=0 if `thing'`cut'`n'==0 & `interact'`n'==.
	cap replace `interact'`n'=0 if `interact'`n'==.
	}
	}
		if "${herf2}"=="" {
		* gen `thing'`abbrev'`ends'_`cut'10=`thing'`cut'110*`interact'110	+	`thing'`cut'112*`interact'112	+	`thing'`cut'210*`interact'210	+	`thing'`cut'211*`interact'211	+	`thing'`cut'220*`interact'220	+	`thing'`cut'230*`interact'230	+	`thing'`cut'239*`interact'239	
		cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'310*`interact'310	+	`thing'`cut'311*`interact'311	+	`thing'`cut'312*`interact'312	+	`thing'`cut'314*`interact'314	+	`thing'`cut'315*`interact'315	+	`thing'`cut'321*`interact'321	+	`thing'`cut'322*`interact'322	+	`thing'`cut'323*`interact'323	+	`thing'`cut'324*`interact'324	+	`thing'`cut'325*`interact'325	+	`thing'`cut'326*`interact'326	+	`thing'`cut'330*`interact'330	+	`thing'`cut'331*`interact'331	+	`thing'`cut'332*`interact'332	+	`thing'`cut'333*`interact'333	+	`thing'`cut'335*`interact'335	+	`thing'`cut'336*`interact'336	+	`thing'`cut'337*`interact'337	
		cap gen `thing'`abbrev'`ends'_`cut'12=`thing'`cut'430*`interact'430	+	`thing'`cut'433*`interact'433	+	`thing'`cut'465*`interact'465	+	`thing'`cut'467*`interact'467	+	`thing'`cut'469*`interact'469	+	`thing'`cut'480*`interact'480	+	`thing'`cut'483*`interact'483	+	`thing'`cut'487*`interact'487	+	`thing'`cut'490*`interact'490	+	`thing'`cut'511*`interact'511	+	`thing'`cut'520*`interact'520	+	`thing'`cut'530*`interact'530	+	`thing'`cut'540*`interact'540	+	`thing'`cut'562*`interact'562	+	`thing'`cut'610*`interact'610	+	`thing'`cut'620*`interact'620	+	`thing'`cut'710*`interact'710	+	`thing'`cut'720*`interact'720	+	`thing'`cut'721*`interact'721	+	`thing'`cut'810*`interact'810	+	`thing'`cut'815*`interact'815	+	`thing'`cut'939*`interact'939	
		cap gen `thing'`abbrev'`ends'_`cut'13=`thing'`cut'110*`interact'110	+	`thing'`cut'112*`interact'112	+	`thing'`cut'210*`interact'210	+	`thing'`cut'211*`interact'211	+	`thing'`cut'220*`interact'220	+	`thing'`cut'230*`interact'230	+	`thing'`cut'239*`interact'239	+	`thing'`cut'310*`interact'310	+	`thing'`cut'311*`interact'311	+	`thing'`cut'312*`interact'312	+	`thing'`cut'314*`interact'314	+	`thing'`cut'315*`interact'315	+	`thing'`cut'321*`interact'321	+	`thing'`cut'322*`interact'322	+	`thing'`cut'323*`interact'323	+	`thing'`cut'324*`interact'324	+	`thing'`cut'325*`interact'325	+	`thing'`cut'326*`interact'326	+	`thing'`cut'330*`interact'330	+	`thing'`cut'331*`interact'331	+	`thing'`cut'332*`interact'332	+	`thing'`cut'333*`interact'333	+	`thing'`cut'335*`interact'335	+	`thing'`cut'336*`interact'336	+	`thing'`cut'337*`interact'337	+ 	`thing'`cut'430*`interact'430	+	`thing'`cut'433*`interact'433	+	`thing'`cut'465*`interact'465	+	`thing'`cut'467*`interact'467	+	`thing'`cut'469*`interact'469	+	`thing'`cut'480*`interact'480	+	`thing'`cut'483*`interact'483	+	`thing'`cut'487*`interact'487	+	`thing'`cut'490*`interact'490	+	`thing'`cut'511*`interact'511	+	`thing'`cut'520*`interact'520	+	`thing'`cut'530*`interact'530	+	`thing'`cut'540*`interact'540	+	`thing'`cut'562*`interact'562	+	`thing'`cut'610*`interact'610	+	`thing'`cut'620*`interact'620	+	`thing'`cut'710*`interact'710	+	`thing'`cut'720*`interact'720	+	`thing'`cut'721*`interact'721	+	`thing'`cut'810*`interact'810	+	`thing'`cut'815*`interact'815	+	`thing'`cut'939*`interact'939	
		cap gen `thing'`abbrev'`ends'_`cut'18=`thing'`cut'310*`interact'310	+	`thing'`cut'311*`interact'311	+	`thing'`cut'312*`interact'312	+	`thing'`cut'314*`interact'314	+	`thing'`cut'315*`interact'315	+	`thing'`cut'321*`interact'321	+	`thing'`cut'322*`interact'322	+	`thing'`cut'323*`interact'323	+	`thing'`cut'324*`interact'324	+	`thing'`cut'325*`interact'325	+	`thing'`cut'326*`interact'326	+	`thing'`cut'330*`interact'330	+	`thing'`cut'331*`interact'331	+	`thing'`cut'332*`interact'332	+	`thing'`cut'333*`interact'333	+	`thing'`cut'335*`interact'335	+	`thing'`cut'336*`interact'336	+	`thing'`cut'337*`interact'337	+ 	`thing'`cut'430*`interact'430	+	`thing'`cut'433*`interact'433	+	`thing'`cut'465*`interact'465	+	`thing'`cut'467*`interact'467	+	`thing'`cut'469*`interact'469	+	`thing'`cut'480*`interact'480	+	`thing'`cut'483*`interact'483	+	`thing'`cut'487*`interact'487	+	`thing'`cut'490*`interact'490	+	`thing'`cut'511*`interact'511	+	`thing'`cut'520*`interact'520	+	`thing'`cut'530*`interact'530	+	`thing'`cut'540*`interact'540	+	`thing'`cut'562*`interact'562	+	`thing'`cut'610*`interact'610	+	`thing'`cut'620*`interact'620	+	`thing'`cut'710*`interact'710	+	`thing'`cut'720*`interact'720	+	`thing'`cut'721*`interact'721	+	`thing'`cut'810*`interact'810	+	`thing'`cut'815*`interact'815	+	`thing'`cut'939*`interact'939	
		*note this staretgy cannot deal with interactions of the sort (indw11dif310/indw13dif310). Those should be premade above. But can put in indmean`cut' type variable so `cut' will be pulled from above
		cap gen `thing'`abbrev'`ends'_`cut'14=   `thing'`cut'310*`interact'310    +   `thing'`cut'326*`interact'326    +   `thing'`cut'325*`interact'325    +    `thing'`cut'311*`interact'311    +   `thing'`cut'321*`interact'321    +   `thing'`cut'322*`interact'322    +   `thing'`cut'324*`interact'324    +   `thing'`cut'330*`interact'330    +   `thing'`cut'323*`interact'323 
		cap gen `thing'`abbrev'`ends'_`cut'19=   `thing'`cut'335*`interact'335    +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333   +   `thing'`cut'331*`interact'331 +   `thing'`cut'337*`interact'337 + `thing'`cut'315*`interact'315        +   `thing'`cut'336*`interact'336    +   `thing'`cut'314*`interact'314       +   `thing'`cut'312*`interact'312   
		}
		
		if "${herf2}"=="_cen90" {

		cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'320*`interact'320    +   `thing'`cut'323*`interact'323    +   `thing'`cut'324*`interact'324    +   `thing'`cut'325*`interact'325    +   `thing'`cut'326*`interact'326    +   `thing'`cut'347*`interact'347    +   `thing'`cut'348*`interact'348    +   `thing'`cut'349*`interact'349    +   `thing'`cut'350*`interact'350    +   `thing'`cut'351*`interact'351    +   `thing'`cut'352*`interact'352    +   `thing'`cut'353*`interact'353    +   `thing'`cut'354*`interact'354    +   `thing'`cut'355*`interact'355    +   `thing'`cut'356*`interact'356    +   `thing'`cut'357*`interact'357	+	`thing'`cut'301*`interact'301    +   `thing'`cut'302*`interact'302    +   `thing'`cut'303*`interact'303    +   `thing'`cut'304*`interact'304    +   `thing'`cut'305*`interact'305    +   `thing'`cut'306*`interact'306    +   `thing'`cut'307*`interact'307    +   `thing'`cut'308*`interact'308    +   `thing'`cut'309*`interact'309    +   `thing'`cut'310*`interact'310    +   `thing'`cut'311*`interact'311    +   `thing'`cut'312*`interact'312    +   `thing'`cut'313*`interact'313    +   `thing'`cut'314*`interact'314    +   `thing'`cut'315*`interact'315    +   `thing'`cut'316*`interact'316    +   `thing'`cut'317*`interact'317    +   `thing'`cut'318*`interact'318    +   `thing'`cut'319*`interact'319    +   `thing'`cut'321*`interact'321    +   `thing'`cut'322*`interact'322    +   `thing'`cut'327*`interact'327    +   `thing'`cut'328*`interact'328    +   `thing'`cut'329*`interact'329    +   `thing'`cut'330*`interact'330    +   `thing'`cut'331*`interact'331    +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333    +   `thing'`cut'334*`interact'334    +   `thing'`cut'335*`interact'335    +   `thing'`cut'336*`interact'336    +   `thing'`cut'337*`interact'337    +   `thing'`cut'338*`interact'338    +   `thing'`cut'339*`interact'339    +   `thing'`cut'340*`interact'340    +   `thing'`cut'341*`interact'341    +   `thing'`cut'342*`interact'342    +   `thing'`cut'343*`interact'343    +   `thing'`cut'344*`interact'344    +   `thing'`cut'345*`interact'345    +   `thing'`cut'346*`interact'346
		cap gen `thing'`abbrev'`ends'_`cut'13=`thing'`cut'110*`interact'110	+	`thing'`cut'112*`interact'112	+	`thing'`cut'210*`interact'210	+	`thing'`cut'211*`interact'211	+	`thing'`cut'220*`interact'220	+	`thing'`cut'230*`interact'230	+	`thing'`cut'239*`interact'239	+	`thing'`cut'320*`interact'320    +   `thing'`cut'323*`interact'323    +   `thing'`cut'324*`interact'324    +   `thing'`cut'325*`interact'325    +   `thing'`cut'326*`interact'326    +   `thing'`cut'347*`interact'347    +   `thing'`cut'348*`interact'348    +   `thing'`cut'349*`interact'349    +   `thing'`cut'350*`interact'350    +   `thing'`cut'351*`interact'351    +   `thing'`cut'352*`interact'352    +   `thing'`cut'353*`interact'353    +   `thing'`cut'354*`interact'354    +   `thing'`cut'355*`interact'355    +   `thing'`cut'356*`interact'356    +   `thing'`cut'357*`interact'357	+	`thing'`cut'301*`interact'301    +   `thing'`cut'302*`interact'302    +   `thing'`cut'303*`interact'303    +   `thing'`cut'304*`interact'304    +   `thing'`cut'305*`interact'305    +   `thing'`cut'306*`interact'306    +   `thing'`cut'307*`interact'307    +   `thing'`cut'308*`interact'308    +   `thing'`cut'309*`interact'309    +   `thing'`cut'310*`interact'310    +   `thing'`cut'311*`interact'311    +   `thing'`cut'312*`interact'312    +   `thing'`cut'313*`interact'313    +   `thing'`cut'314*`interact'314    +   `thing'`cut'315*`interact'315    +   `thing'`cut'316*`interact'316    +   `thing'`cut'317*`interact'317    +   `thing'`cut'318*`interact'318    +   `thing'`cut'319*`interact'319    +   `thing'`cut'321*`interact'321    +   `thing'`cut'322*`interact'322    +   `thing'`cut'327*`interact'327    +   `thing'`cut'328*`interact'328    +   `thing'`cut'329*`interact'329    +   `thing'`cut'330*`interact'330    +   `thing'`cut'331*`interact'331    +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333    +   `thing'`cut'334*`interact'334    +   `thing'`cut'335*`interact'335    +   `thing'`cut'336*`interact'336    +   `thing'`cut'337*`interact'337    +   `thing'`cut'338*`interact'338    +   `thing'`cut'339*`interact'339    +   `thing'`cut'340*`interact'340    +   `thing'`cut'341*`interact'341    +   `thing'`cut'342*`interact'342    +   `thing'`cut'343*`interact'343    +   `thing'`cut'344*`interact'344    +   `thing'`cut'345*`interact'345    +   `thing'`cut'346*`interact'346	+ `thing'`cut'430*`interact'430	+	`thing'`cut'433*`interact'433	+	`thing'`cut'465*`interact'465	+	`thing'`cut'467*`interact'467	+	`thing'`cut'469*`interact'469	+	`thing'`cut'480*`interact'480	+	`thing'`cut'483*`interact'483	+	`thing'`cut'487*`interact'487	+	`thing'`cut'490*`interact'490	+	`thing'`cut'511*`interact'511	+	`thing'`cut'520*`interact'520	+	`thing'`cut'530*`interact'530	+	`thing'`cut'540*`interact'540	+	`thing'`cut'562*`interact'562	+	`thing'`cut'610*`interact'610	+	`thing'`cut'620*`interact'620	+	`thing'`cut'710*`interact'710	+	`thing'`cut'720*`interact'720	+	`thing'`cut'721*`interact'721	+	`thing'`cut'810*`interact'810	+	`thing'`cut'815*`interact'815	+	`thing'`cut'939*`interact'939	
		cap gen `thing'`abbrev'`ends'_`cut'16=`thing'`cut'320*`interact'320    +   `thing'`cut'323*`interact'323    +   `thing'`cut'324*`interact'324    +   `thing'`cut'325*`interact'325    +   `thing'`cut'326*`interact'326    +   `thing'`cut'347*`interact'347    +   `thing'`cut'348*`interact'348    +   `thing'`cut'349*`interact'349    +   `thing'`cut'350*`interact'350    +   `thing'`cut'351*`interact'351    +   `thing'`cut'352*`interact'352    +   `thing'`cut'353*`interact'353    +   `thing'`cut'354*`interact'354    +   `thing'`cut'355*`interact'355    +   `thing'`cut'356*`interact'356    +   `thing'`cut'357*`interact'357
		cap gen `thing'`abbrev'`ends'_`cut'15=`thing'`cut'301*`interact'301    +   `thing'`cut'302*`interact'302    +   `thing'`cut'303*`interact'303    +   `thing'`cut'304*`interact'304    +   `thing'`cut'305*`interact'305    +   `thing'`cut'306*`interact'306    +   `thing'`cut'307*`interact'307    +   `thing'`cut'308*`interact'308    +   `thing'`cut'309*`interact'309    +   `thing'`cut'310*`interact'310    +   `thing'`cut'311*`interact'311    +   `thing'`cut'312*`interact'312    +   `thing'`cut'313*`interact'313    +   `thing'`cut'314*`interact'314    +   `thing'`cut'315*`interact'315    +   `thing'`cut'316*`interact'316    +   `thing'`cut'317*`interact'317    +   `thing'`cut'318*`interact'318    +   `thing'`cut'319*`interact'319    +   `thing'`cut'321*`interact'321    +   `thing'`cut'322*`interact'322    +   `thing'`cut'327*`interact'327    +   `thing'`cut'328*`interact'328    +   `thing'`cut'329*`interact'329    +   `thing'`cut'330*`interact'330    +   `thing'`cut'331*`interact'331    +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333    +   `thing'`cut'334*`interact'334    +   `thing'`cut'335*`interact'335    +   `thing'`cut'336*`interact'336    +   `thing'`cut'337*`interact'337    +   `thing'`cut'338*`interact'338    +   `thing'`cut'339*`interact'339    +   `thing'`cut'340*`interact'340    +   `thing'`cut'341*`interact'341    +   `thing'`cut'342*`interact'342    +   `thing'`cut'343*`interact'343    +   `thing'`cut'344*`interact'344    +   `thing'`cut'345*`interact'345    +   `thing'`cut'346*`interact'346
		cap gen `thing'`abbrev'`ends'_`cut'17=`thing'`cut'110*`interact'110	+	`thing'`cut'112*`interact'112	+	`thing'`cut'210*`interact'210	+	`thing'`cut'211*`interact'211	+	`thing'`cut'220*`interact'220	+	`thing'`cut'230*`interact'230	+	`thing'`cut'239*`interact'239	+ `thing'`cut'301*`interact'301    +   `thing'`cut'302*`interact'302    +   `thing'`cut'303*`interact'303    +   `thing'`cut'304*`interact'304    +   `thing'`cut'305*`interact'305    +   `thing'`cut'306*`interact'306    +   `thing'`cut'307*`interact'307    +   `thing'`cut'308*`interact'308    +   `thing'`cut'309*`interact'309    +   `thing'`cut'310*`interact'310    +   `thing'`cut'311*`interact'311    +   `thing'`cut'312*`interact'312    +   `thing'`cut'313*`interact'313    +   `thing'`cut'314*`interact'314    +   `thing'`cut'315*`interact'315    +   `thing'`cut'316*`interact'316    +   `thing'`cut'317*`interact'317    +   `thing'`cut'318*`interact'318    +   `thing'`cut'319*`interact'319    +   `thing'`cut'321*`interact'321    +   `thing'`cut'322*`interact'322    +   `thing'`cut'327*`interact'327    +   `thing'`cut'328*`interact'328    +   `thing'`cut'329*`interact'329    +   `thing'`cut'330*`interact'330    +   `thing'`cut'331*`interact'331    +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333    +   `thing'`cut'334*`interact'334    +   `thing'`cut'335*`interact'335    +   `thing'`cut'336*`interact'336    +   `thing'`cut'337*`interact'337    +   `thing'`cut'338*`interact'338    +   `thing'`cut'339*`interact'339    +   `thing'`cut'340*`interact'340    +   `thing'`cut'341*`interact'341    +   `thing'`cut'342*`interact'342    +   `thing'`cut'343*`interact'343    +   `thing'`cut'344*`interact'344    +   `thing'`cut'345*`interact'345    +   `thing'`cut'346*`interact'346	+ `thing'`cut'430*`interact'430	+	`thing'`cut'433*`interact'433	+	`thing'`cut'465*`interact'465	+	`thing'`cut'467*`interact'467	+	`thing'`cut'469*`interact'469	+	`thing'`cut'480*`interact'480	+	`thing'`cut'483*`interact'483	+	`thing'`cut'487*`interact'487	+	`thing'`cut'490*`interact'490	+	`thing'`cut'511*`interact'511	+	`thing'`cut'520*`interact'520	+	`thing'`cut'530*`interact'530	+	`thing'`cut'540*`interact'540	+	`thing'`cut'562*`interact'562	+	`thing'`cut'610*`interact'610	+	`thing'`cut'620*`interact'620	+	`thing'`cut'710*`interact'710	+	`thing'`cut'720*`interact'720	+	`thing'`cut'721*`interact'721	+	`thing'`cut'810*`interact'810	+	`thing'`cut'815*`interact'815	+	`thing'`cut'939*`interact'939	



*have a cut off of 8 periods out of 16
cap gen `thing'`abbrev'`ends'_`cut'26=`thing'`cut'320*`interact'320   +   `thing'`cut'322*`interact'322   +   `thing'`cut'323*`interact'323    +   `thing'`cut'324*`interact'324    +   `thing'`cut'325*`interact'325       +   `thing'`cut'347*`interact'347    +   `thing'`cut'348*`interact'348    +   `thing'`cut'349*`interact'349   +   `thing'`cut'350*`interact'350    +   `thing'`cut'351*`interact'351    +   `thing'`cut'352*`interact'352    +   `thing'`cut'353*`interact'353    +   `thing'`cut'354*`interact'354    +   `thing'`cut'355*`interact'355    +   `thing'`cut'356*`interact'356    +   `thing'`cut'357*`interact'357

cap gen `thing'`abbrev'`ends'_`cut'27=`thing'`cut'301*`interact'301    +   `thing'`cut'302*`interact'302    +   `thing'`cut'303*`interact'303    +   `thing'`cut'304*`interact'304    +   `thing'`cut'305*`interact'305    +   `thing'`cut'306*`interact'306    +   `thing'`cut'307*`interact'307    +   `thing'`cut'308*`interact'308  +   `thing'`cut'309*`interact'309    +   `thing'`cut'310*`interact'310    +   `thing'`cut'311*`interact'311    +   `thing'`cut'312*`interact'312    +   `thing'`cut'313*`interact'313    +   `thing'`cut'314*`interact'314    +   `thing'`cut'315*`interact'315    +   `thing'`cut'316*`interact'316    +   `thing'`cut'317*`interact'317   +   `thing'`cut'318*`interact'318    +   `thing'`cut'319*`interact'319    +   `thing'`cut'321*`interact'321   +   `thing'`cut'326*`interact'326    +   `thing'`cut'327*`interact'327    +   `thing'`cut'328*`interact'328    +   `thing'`cut'329*`interact'329    +   `thing'`cut'330*`interact'330    +   `thing'`cut'331*`interact'331   +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333    +   `thing'`cut'334*`interact'334    +   `thing'`cut'335*`interact'335    +   `thing'`cut'336*`interact'336    +   `thing'`cut'337*`interact'337    +   `thing'`cut'338*`interact'338    +   `thing'`cut'339*`interact'339    +   `thing'`cut'340*`interact'340   +   `thing'`cut'341*`interact'341    +   `thing'`cut'342*`interact'342    +   `thing'`cut'343*`interact'343    +   `thing'`cut'344*`interact'344    +   `thing'`cut'345*`interact'345    +   `thing'`cut'346*`interact'346	+ `thing'`cut'430*`interact'430	+	`thing'`cut'433*`interact'433	+	`thing'`cut'465*`interact'465	+	`thing'`cut'467*`interact'467	+	`thing'`cut'469*`interact'469	+	`thing'`cut'480*`interact'480	+	`thing'`cut'483*`interact'483	+	`thing'`cut'487*`interact'487	+	`thing'`cut'490*`interact'490	+	`thing'`cut'511*`interact'511	+	`thing'`cut'520*`interact'520	+	`thing'`cut'530*`interact'530	+	`thing'`cut'540*`interact'540	+	`thing'`cut'562*`interact'562	+	`thing'`cut'610*`interact'610	+	`thing'`cut'620*`interact'620	+	`thing'`cut'710*`interact'710	+	`thing'`cut'720*`interact'720	+	`thing'`cut'721*`interact'721	+	`thing'`cut'810*`interact'810	+	`thing'`cut'815*`interact'815	+	`thing'`cut'939*`interact'939	+ `thing'`cut'110*`interact'110	+	`thing'`cut'112*`interact'112	+	`thing'`cut'210*`interact'210	+	`thing'`cut'211*`interact'211	+	`thing'`cut'220*`interact'220	+	`thing'`cut'230*`interact'230	+	`thing'`cut'239*`interact'239	

cap gen `thing'`abbrev'`ends'_`cut'25=`thing'`cut'301*`interact'301    +   `thing'`cut'302*`interact'302    +   `thing'`cut'303*`interact'303    +   `thing'`cut'304*`interact'304    +   `thing'`cut'305*`interact'305    +   `thing'`cut'306*`interact'306    +   `thing'`cut'307*`interact'307    +   `thing'`cut'308*`interact'308  +   `thing'`cut'309*`interact'309    +   `thing'`cut'310*`interact'310    +   `thing'`cut'311*`interact'311    +   `thing'`cut'312*`interact'312    +   `thing'`cut'313*`interact'313    +   `thing'`cut'314*`interact'314    +   `thing'`cut'315*`interact'315    +   `thing'`cut'316*`interact'316    +   `thing'`cut'317*`interact'317   +   `thing'`cut'318*`interact'318    +   `thing'`cut'319*`interact'319    +   `thing'`cut'321*`interact'321   +   `thing'`cut'326*`interact'326    +   `thing'`cut'327*`interact'327    +   `thing'`cut'328*`interact'328    +   `thing'`cut'329*`interact'329    +   `thing'`cut'330*`interact'330    +   `thing'`cut'331*`interact'331   +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333    +   `thing'`cut'334*`interact'334    +   `thing'`cut'335*`interact'335    +   `thing'`cut'336*`interact'336    +   `thing'`cut'337*`interact'337    +   `thing'`cut'338*`interact'338    +   `thing'`cut'339*`interact'339    +   `thing'`cut'340*`interact'340   +   `thing'`cut'341*`interact'341    +   `thing'`cut'342*`interact'342    +   `thing'`cut'343*`interact'343    +   `thing'`cut'344*`interact'344    +   `thing'`cut'345*`interact'345    +   `thing'`cut'346*`interact'346	



		

		}		
		
		
	if regexm("`interact'","pur")==1 {
	forval n=100/999 {
	cap drop `interact'`n'
	cap rename X`interact'`n' `interact'`n'
	}
	}
}

}




*may run into to trouble if some of my ind variables end 00110 etc...
}
cap drop `interact'???

}

foreach cut in 00 50 {
drop *`cut'???
}


*this drops all the non matching sex specific skill shocks

cap drop *male*f??cat*
cap drop *fem*m??cat*
cap drop *male*e??cat*
cap drop *fem*e??cat*

cap drop *male*f?cat*
cap drop *fem*m?cat*
cap drop *male*e?cat*
cap drop *fem*e?cat*



cap drop ind*
*drop  ?exp* exp* ??exp*


cap drop *?femm*c*
cap drop *?feme*c*
cap drop *?malee*c*
cap drop *?malef*c*


cap d *?empe?*c*
if _rc==0 {
foreach varx of varlist *?empe?*c* {  //  *emp*e??cat*


local stripa=regexr("`varx'","empe","empp")
local stripb=regexr("`varx'","empe","femf")
local stripc=regexr("`varx'","empe","malem")
local stripd=regexr("`varx'","emp.*_","emp")
local stripe=regexr("`varx'","emp.*_","fem")
local stripf=regexr("`varx'","emp.*_","male")
cap gen `stripa'=(`stripb'+`stripc')*(`stripd'/(`stripe'+`stripf'))
*so i add male and female together so that sex specific skill data used. then i scale it up since some of the empoyees have no sex reported.
}
}


global listhcode "`listhcode' `listnicexpcreate'"


noi di "${listhcode}"









