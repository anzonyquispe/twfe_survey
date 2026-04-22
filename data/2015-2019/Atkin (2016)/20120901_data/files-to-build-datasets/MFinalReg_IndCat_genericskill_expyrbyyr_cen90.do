
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
Wage percentage measures must go before the percentages tehmselves as the percentages get dropped after use and are needed for wage premia.
The wage variables, with w replaced by z are the jobs by skill level having dropped jobs for whcih pur wage data not available
**/




#delimit ;
local listskill3cat190 "  
indmschlz3cat1exp9s_*    indmschlz3cat2exp9s_* 	   indmschlz3cat3exp9s_* 
";



local listskill3cat190_wages "  
indmveschlz3cat1exp9s_*    indmveschlz3cat2exp9s_* 	   indmveschlz3cat3exp9s_* 
";




#delimit cr













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
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_3cats_combo.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat190' `listskill3cat290') 
drop _merge9999
}

cap {
sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_2cats_combo.dta", generate(_merge9999)  keepusing(muncenso `listskill2cat190' `listskill2cat290') 
drop _merge9999
}


sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_3cats_wages.dta", generate(_merge9999)  keepusing(muncenso `listskill3cat190_wages'  `listskill3cat290_wages') 
drop _merge9999



cap {
sort muncenso
merge m:1 muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_bothsexes${herf2}_2cats_wages.dta", generate(_merge9999)  keepusing(muncenso `listskill2cat190_wages' `listskill2cat290_wages') 
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
merge year using "${dir}Nicita_ExportsPWOnly_wide.dta", _merge(_merge9998) keep(year `listnicexppw') 
drop _merge9998
}



merge m:1 year using "${dir}Trade Production and Protection\Update\Update_Export_data_Wide.dta", generate(_merge9997) 
drop _merge9997







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

gen `thing'`cut'17=`thing'`cut'110*(1-exp5_110)	+	`thing'`cut'112*(1-exp5_112)	+	`thing'`cut'210*(1-exp5_210)	+	`thing'`cut'211*(1-exp5_211)	+	`thing'`cut'220*(1-exp5_220)	+	`thing'`cut'230*(1-exp5_230)	+	`thing'`cut'239*(1-exp5_239)	+	`thing'`cut'320*(1-exp5_320)    +   `thing'`cut'323*(1-exp5_323)    +   `thing'`cut'324*(1-exp5_324)    +   `thing'`cut'325*(1-exp5_325)    +   `thing'`cut'326*(1-exp5_326)    +   `thing'`cut'347*(1-exp5_347)    +   `thing'`cut'348*(1-exp5_348)    +   `thing'`cut'349*(1-exp5_349)    +   `thing'`cut'350*(1-exp5_350)    +   `thing'`cut'351*(1-exp5_351)    +   `thing'`cut'352*(1-exp5_352)    +   `thing'`cut'353*(1-exp5_353)    +   `thing'`cut'354*(1-exp5_354)    +   `thing'`cut'355*(1-exp5_355)    +   `thing'`cut'356*(1-exp5_356)    +   `thing'`cut'357*(1-exp5_357)	+	`thing'`cut'301*(1-exp5_301)    +   `thing'`cut'302*(1-exp5_302)    +   `thing'`cut'303*(1-exp5_303)    +   `thing'`cut'304*(1-exp5_304)    +   `thing'`cut'305*(1-exp5_305)    +   `thing'`cut'306*(1-exp5_306)    +   `thing'`cut'307*(1-exp5_307)    +   `thing'`cut'308*(1-exp5_308)    +   `thing'`cut'309*(1-exp5_309)    +   `thing'`cut'310*(1-exp5_310)    +   `thing'`cut'311*(1-exp5_311)    +   `thing'`cut'312*(1-exp5_312)    +   `thing'`cut'313*(1-exp5_313)    +   `thing'`cut'314*(1-exp5_314)    +   `thing'`cut'315*(1-exp5_315)    +   `thing'`cut'316*(1-exp5_316)    +   `thing'`cut'317*(1-exp5_317)    +   `thing'`cut'318*(1-exp5_318)    +   `thing'`cut'319*(1-exp5_319)    +   `thing'`cut'321*(1-exp5_321)    +   `thing'`cut'322*(1-exp5_322)    +   `thing'`cut'327*(1-exp5_327)    +   `thing'`cut'328*(1-exp5_328)    +   `thing'`cut'329*(1-exp5_329)    +   `thing'`cut'330*(1-exp5_330)    +   `thing'`cut'331*(1-exp5_331)    +   `thing'`cut'332*(1-exp5_332)    +   `thing'`cut'333*(1-exp5_333)    +   `thing'`cut'334*(1-exp5_334)    +   `thing'`cut'335*(1-exp5_335)    +   `thing'`cut'336*(1-exp5_336)    +   `thing'`cut'337*(1-exp5_337)    +   `thing'`cut'338*(1-exp5_338)    +   `thing'`cut'339*(1-exp5_339)    +   `thing'`cut'340*(1-exp5_340)    +   `thing'`cut'341*(1-exp5_341)    +   `thing'`cut'342*(1-exp5_342)    +   `thing'`cut'343*(1-exp5_343)    +   `thing'`cut'344*(1-exp5_344)    +   `thing'`cut'345*(1-exp5_345)    +   `thing'`cut'346*(1-exp5_346)	+ `thing'`cut'430*(1-exp5_430)	+	`thing'`cut'433*(1-exp5_433)	+	`thing'`cut'465*(1-exp5_465)	+	`thing'`cut'467*(1-exp5_467)	+	`thing'`cut'469*(1-exp5_469)	+	`thing'`cut'480*(1-exp5_480)	+	`thing'`cut'483*(1-exp5_483)	+	`thing'`cut'487*(1-exp5_487)	+	`thing'`cut'490*(1-exp5_490)	+	`thing'`cut'511*(1-exp5_511)	+	`thing'`cut'520*(1-exp5_520)	+	`thing'`cut'530*(1-exp5_530)	+	`thing'`cut'540*(1-exp5_540)	+	`thing'`cut'562*(1-exp5_562)	+	`thing'`cut'610*(1-exp5_610)	+	`thing'`cut'620*(1-exp5_620)	+	`thing'`cut'710*(1-exp5_710)	+	`thing'`cut'720*(1-exp5_720)	+	`thing'`cut'721*(1-exp5_721)	+	`thing'`cut'810*(1-exp5_810)	+	`thing'`cut'815*(1-exp5_815)	+	`thing'`cut'939*(1-exp5_939)	
cap gen `thing'`cut'15=`thing'`cut'320*(1-exp5_320)    +   `thing'`cut'323*(1-exp5_323)    +   `thing'`cut'324*(1-exp5_324)    +   `thing'`cut'325*(1-exp5_325)    +   `thing'`cut'326*(1-exp5_326)    +   `thing'`cut'347*(1-exp5_347)    +   `thing'`cut'348*(1-exp5_348)    +   `thing'`cut'349*(1-exp5_349)    +   `thing'`cut'350*(1-exp5_350)    +   `thing'`cut'351*(1-exp5_351)    +   `thing'`cut'352*(1-exp5_352)    +   `thing'`cut'353*(1-exp5_353)    +   `thing'`cut'354*(1-exp5_354)    +   `thing'`cut'355*(1-exp5_355)    +   `thing'`cut'356*(1-exp5_356)    +   `thing'`cut'357*(1-exp5_357)	+	`thing'`cut'301*(1-exp5_301)    +   `thing'`cut'302*(1-exp5_302)    +   `thing'`cut'303*(1-exp5_303)    +   `thing'`cut'304*(1-exp5_304)    +   `thing'`cut'305*(1-exp5_305)    +   `thing'`cut'306*(1-exp5_306)    +   `thing'`cut'307*(1-exp5_307)    +   `thing'`cut'308*(1-exp5_308)    +   `thing'`cut'309*(1-exp5_309)    +   `thing'`cut'310*(1-exp5_310)    +   `thing'`cut'311*(1-exp5_311)    +   `thing'`cut'312*(1-exp5_312)    +   `thing'`cut'313*(1-exp5_313)    +   `thing'`cut'314*(1-exp5_314)    +   `thing'`cut'315*(1-exp5_315)    +   `thing'`cut'316*(1-exp5_316)    +   `thing'`cut'317*(1-exp5_317)    +   `thing'`cut'318*(1-exp5_318)    +   `thing'`cut'319*(1-exp5_319)    +   `thing'`cut'321*(1-exp5_321)    +   `thing'`cut'322*(1-exp5_322)    +   `thing'`cut'327*(1-exp5_327)    +   `thing'`cut'328*(1-exp5_328)    +   `thing'`cut'329*(1-exp5_329)    +   `thing'`cut'330*(1-exp5_330)    +   `thing'`cut'331*(1-exp5_331)    +   `thing'`cut'332*(1-exp5_332)    +   `thing'`cut'333*(1-exp5_333)    +   `thing'`cut'334*(1-exp5_334)    +   `thing'`cut'335*(1-exp5_335)    +   `thing'`cut'336*(1-exp5_336)    +   `thing'`cut'337*(1-exp5_337)    +   `thing'`cut'338*(1-exp5_338)    +   `thing'`cut'339*(1-exp5_339)    +   `thing'`cut'340*(1-exp5_340)    +   `thing'`cut'341*(1-exp5_341)    +   `thing'`cut'342*(1-exp5_342)    +   `thing'`cut'343*(1-exp5_343)    +   `thing'`cut'344*(1-exp5_344)    +   `thing'`cut'345*(1-exp5_345)    +   `thing'`cut'346*(1-exp5_346)
cap gen `thing'`cut'16=`thing'`cut'320*(exp5_320)    +   `thing'`cut'323*(exp5_323)    +   `thing'`cut'324*(exp5_324)    +   `thing'`cut'325*(exp5_325)    +   `thing'`cut'326*(exp5_326)    +   `thing'`cut'347*(exp5_347)    +   `thing'`cut'348*(exp5_348)    +   `thing'`cut'349*(exp5_349)    +   `thing'`cut'350*(exp5_350)    +   `thing'`cut'351*(exp5_351)    +   `thing'`cut'352*(exp5_352)    +   `thing'`cut'353*(exp5_353)    +   `thing'`cut'354*(exp5_354)    +   `thing'`cut'355*(exp5_355)    +   `thing'`cut'356*(exp5_356)    +   `thing'`cut'357*(exp5_357)	+	`thing'`cut'301*(exp5_301)    +   `thing'`cut'302*(exp5_302)    +   `thing'`cut'303*(exp5_303)    +   `thing'`cut'304*(exp5_304)    +   `thing'`cut'305*(exp5_305)    +   `thing'`cut'306*(exp5_306)    +   `thing'`cut'307*(exp5_307)    +   `thing'`cut'308*(exp5_308)    +   `thing'`cut'309*(exp5_309)    +   `thing'`cut'310*(exp5_310)    +   `thing'`cut'311*(exp5_311)    +   `thing'`cut'312*(exp5_312)    +   `thing'`cut'313*(exp5_313)    +   `thing'`cut'314*(exp5_314)    +   `thing'`cut'315*(exp5_315)    +   `thing'`cut'316*(exp5_316)    +   `thing'`cut'317*(exp5_317)    +   `thing'`cut'318*(exp5_318)    +   `thing'`cut'319*(exp5_319)    +   `thing'`cut'321*(exp5_321)    +   `thing'`cut'322*(exp5_322)    +   `thing'`cut'327*(exp5_327)    +   `thing'`cut'328*(exp5_328)    +   `thing'`cut'329*(exp5_329)    +   `thing'`cut'330*(exp5_330)    +   `thing'`cut'331*(exp5_331)    +   `thing'`cut'332*(exp5_332)    +   `thing'`cut'333*(exp5_333)    +   `thing'`cut'334*(exp5_334)    +   `thing'`cut'335*(exp5_335)    +   `thing'`cut'336*(exp5_336)    +   `thing'`cut'337*(exp5_337)    +   `thing'`cut'338*(exp5_338)    +   `thing'`cut'339*(exp5_339)    +   `thing'`cut'340*(exp5_340)    +   `thing'`cut'341*(exp5_341)    +   `thing'`cut'342*(exp5_342)    +   `thing'`cut'343*(exp5_343)    +   `thing'`cut'344*(exp5_344)    +   `thing'`cut'345*(exp5_345)    +   `thing'`cut'346*(exp5_346)

cap gen `thing'`cut'27=`thing'`cut'110*(1-exp25_110)	+	`thing'`cut'112*(1-exp25_112)	+	`thing'`cut'210*(1-exp25_210)	+	`thing'`cut'211*(1-exp25_211)	+	`thing'`cut'220*(1-exp25_220)	+	`thing'`cut'230*(1-exp25_230)	+	`thing'`cut'239*(1-exp25_239)	+	`thing'`cut'320*(1-exp25_320)    +   `thing'`cut'323*(1-exp25_323)    +   `thing'`cut'324*(1-exp25_324)    +   `thing'`cut'325*(1-exp25_325)    +   `thing'`cut'326*(1-exp25_326)    +   `thing'`cut'347*(1-exp25_347)    +   `thing'`cut'348*(1-exp25_348)    +   `thing'`cut'349*(1-exp25_349)    +   `thing'`cut'350*(1-exp25_350)    +   `thing'`cut'351*(1-exp25_351)    +   `thing'`cut'352*(1-exp25_352)    +   `thing'`cut'353*(1-exp25_353)    +   `thing'`cut'354*(1-exp25_354)    +   `thing'`cut'355*(1-exp25_355)    +   `thing'`cut'356*(1-exp25_356)    +   `thing'`cut'357*(1-exp25_357)	+	`thing'`cut'301*(1-exp25_301)    +   `thing'`cut'302*(1-exp25_302)    +   `thing'`cut'303*(1-exp25_303)    +   `thing'`cut'304*(1-exp25_304)    +   `thing'`cut'305*(1-exp25_305)    +   `thing'`cut'306*(1-exp25_306)    +   `thing'`cut'307*(1-exp25_307)    +   `thing'`cut'308*(1-exp25_308)    +   `thing'`cut'309*(1-exp25_309)    +   `thing'`cut'310*(1-exp25_310)    +   `thing'`cut'311*(1-exp25_311)    +   `thing'`cut'312*(1-exp25_312)    +   `thing'`cut'313*(1-exp25_313)    +   `thing'`cut'314*(1-exp25_314)    +   `thing'`cut'315*(1-exp25_315)    +   `thing'`cut'316*(1-exp25_316)    +   `thing'`cut'317*(1-exp25_317)    +   `thing'`cut'318*(1-exp25_318)    +   `thing'`cut'319*(1-exp25_319)    +   `thing'`cut'321*(1-exp25_321)    +   `thing'`cut'322*(1-exp25_322)    +   `thing'`cut'327*(1-exp25_327)    +   `thing'`cut'328*(1-exp25_328)    +   `thing'`cut'329*(1-exp25_329)    +   `thing'`cut'330*(1-exp25_330)    +   `thing'`cut'331*(1-exp25_331)    +   `thing'`cut'332*(1-exp25_332)    +   `thing'`cut'333*(1-exp25_333)    +   `thing'`cut'334*(1-exp25_334)    +   `thing'`cut'335*(1-exp25_335)    +   `thing'`cut'336*(1-exp25_336)    +   `thing'`cut'337*(1-exp25_337)    +   `thing'`cut'338*(1-exp25_338)    +   `thing'`cut'339*(1-exp25_339)    +   `thing'`cut'340*(1-exp25_340)    +   `thing'`cut'341*(1-exp25_341)    +   `thing'`cut'342*(1-exp25_342)    +   `thing'`cut'343*(1-exp25_343)    +   `thing'`cut'344*(1-exp25_344)    +   `thing'`cut'345*(1-exp25_345)    +   `thing'`cut'346*(1-exp25_346)	+ `thing'`cut'430*(1-exp25_430)	+	`thing'`cut'433*(1-exp25_433)	+	`thing'`cut'465*(1-exp25_465)	+	`thing'`cut'467*(1-exp25_467)	+	`thing'`cut'469*(1-exp25_469)	+	`thing'`cut'480*(1-exp25_480)	+	`thing'`cut'483*(1-exp25_483)	+	`thing'`cut'487*(1-exp25_487)	+	`thing'`cut'490*(1-exp25_490)	+	`thing'`cut'511*(1-exp25_511)	+	`thing'`cut'520*(1-exp25_520)	+	`thing'`cut'530*(1-exp25_530)	+	`thing'`cut'540*(1-exp25_540)	+	`thing'`cut'562*(1-exp25_562)	+	`thing'`cut'610*(1-exp25_610)	+	`thing'`cut'620*(1-exp25_620)	+	`thing'`cut'710*(1-exp25_710)	+	`thing'`cut'720*(1-exp25_720)	+	`thing'`cut'721*(1-exp25_721)	+	`thing'`cut'810*(1-exp25_810)	+	`thing'`cut'815*(1-exp25_815)	+	`thing'`cut'939*(1-exp25_939)	
cap gen `thing'`cut'25=`thing'`cut'320*(1-exp25_320)    +   `thing'`cut'323*(1-exp25_323)    +   `thing'`cut'324*(1-exp25_324)    +   `thing'`cut'325*(1-exp25_325)    +   `thing'`cut'326*(1-exp25_326)    +   `thing'`cut'347*(1-exp25_347)    +   `thing'`cut'348*(1-exp25_348)    +   `thing'`cut'349*(1-exp25_349)    +   `thing'`cut'350*(1-exp25_350)    +   `thing'`cut'351*(1-exp25_351)    +   `thing'`cut'352*(1-exp25_352)    +   `thing'`cut'353*(1-exp25_353)    +   `thing'`cut'354*(1-exp25_354)    +   `thing'`cut'355*(1-exp25_355)    +   `thing'`cut'356*(1-exp25_356)    +   `thing'`cut'357*(1-exp25_357)	+	`thing'`cut'301*(1-exp25_301)    +   `thing'`cut'302*(1-exp25_302)    +   `thing'`cut'303*(1-exp25_303)    +   `thing'`cut'304*(1-exp25_304)    +   `thing'`cut'305*(1-exp25_305)    +   `thing'`cut'306*(1-exp25_306)    +   `thing'`cut'307*(1-exp25_307)    +   `thing'`cut'308*(1-exp25_308)    +   `thing'`cut'309*(1-exp25_309)    +   `thing'`cut'310*(1-exp25_310)    +   `thing'`cut'311*(1-exp25_311)    +   `thing'`cut'312*(1-exp25_312)    +   `thing'`cut'313*(1-exp25_313)    +   `thing'`cut'314*(1-exp25_314)    +   `thing'`cut'315*(1-exp25_315)    +   `thing'`cut'316*(1-exp25_316)    +   `thing'`cut'317*(1-exp25_317)    +   `thing'`cut'318*(1-exp25_318)    +   `thing'`cut'319*(1-exp25_319)    +   `thing'`cut'321*(1-exp25_321)    +   `thing'`cut'322*(1-exp25_322)    +   `thing'`cut'327*(1-exp25_327)    +   `thing'`cut'328*(1-exp25_328)    +   `thing'`cut'329*(1-exp25_329)    +   `thing'`cut'330*(1-exp25_330)    +   `thing'`cut'331*(1-exp25_331)    +   `thing'`cut'332*(1-exp25_332)    +   `thing'`cut'333*(1-exp25_333)    +   `thing'`cut'334*(1-exp25_334)    +   `thing'`cut'335*(1-exp25_335)    +   `thing'`cut'336*(1-exp25_336)    +   `thing'`cut'337*(1-exp25_337)    +   `thing'`cut'338*(1-exp25_338)    +   `thing'`cut'339*(1-exp25_339)    +   `thing'`cut'340*(1-exp25_340)    +   `thing'`cut'341*(1-exp25_341)    +   `thing'`cut'342*(1-exp25_342)    +   `thing'`cut'343*(1-exp25_343)    +   `thing'`cut'344*(1-exp25_344)    +   `thing'`cut'345*(1-exp25_345)    +   `thing'`cut'346*(1-exp25_346)
cap gen `thing'`cut'26=`thing'`cut'320*(exp25_320)    +   `thing'`cut'323*(exp25_323)    +   `thing'`cut'324*(exp25_324)    +   `thing'`cut'325*(exp25_325)    +   `thing'`cut'326*(exp25_326)    +   `thing'`cut'347*(exp25_347)    +   `thing'`cut'348*(exp25_348)    +   `thing'`cut'349*(exp25_349)    +   `thing'`cut'350*(exp25_350)    +   `thing'`cut'351*(exp25_351)    +   `thing'`cut'352*(exp25_352)    +   `thing'`cut'353*(exp25_353)    +   `thing'`cut'354*(exp25_354)    +   `thing'`cut'355*(exp25_355)    +   `thing'`cut'356*(exp25_356)    +   `thing'`cut'357*(exp25_357)	+	`thing'`cut'301*(exp25_301)    +   `thing'`cut'302*(exp25_302)    +   `thing'`cut'303*(exp25_303)    +   `thing'`cut'304*(exp25_304)    +   `thing'`cut'305*(exp25_305)    +   `thing'`cut'306*(exp25_306)    +   `thing'`cut'307*(exp25_307)    +   `thing'`cut'308*(exp25_308)    +   `thing'`cut'309*(exp25_309)    +   `thing'`cut'310*(exp25_310)    +   `thing'`cut'311*(exp25_311)    +   `thing'`cut'312*(exp25_312)    +   `thing'`cut'313*(exp25_313)    +   `thing'`cut'314*(exp25_314)    +   `thing'`cut'315*(exp25_315)    +   `thing'`cut'316*(exp25_316)    +   `thing'`cut'317*(exp25_317)    +   `thing'`cut'318*(exp25_318)    +   `thing'`cut'319*(exp25_319)    +   `thing'`cut'321*(exp25_321)    +   `thing'`cut'322*(exp25_322)    +   `thing'`cut'327*(exp25_327)    +   `thing'`cut'328*(exp25_328)    +   `thing'`cut'329*(exp25_329)    +   `thing'`cut'330*(exp25_330)    +   `thing'`cut'331*(exp25_331)    +   `thing'`cut'332*(exp25_332)    +   `thing'`cut'333*(exp25_333)    +   `thing'`cut'334*(exp25_334)    +   `thing'`cut'335*(exp25_335)    +   `thing'`cut'336*(exp25_336)    +   `thing'`cut'337*(exp25_337)    +   `thing'`cut'338*(exp25_338)    +   `thing'`cut'339*(exp25_339)    +   `thing'`cut'340*(exp25_340)    +   `thing'`cut'341*(exp25_341)    +   `thing'`cut'342*(exp25_342)    +   `thing'`cut'343*(exp25_343)    +   `thing'`cut'344*(exp25_344)    +   `thing'`cut'345*(exp25_345)    +   `thing'`cut'346*(exp25_346)




}






*not in 16 are in 19:
* +   `thing'`cut'321 322    317 318 319 341 






}
}





*so 10 is just other, 11 is manuf, 12 is services, 13 is all, 18 is manuf and services.
*14 is NEM, 15 is LTEm, 16 is HTEM, 19 is exports


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
if regexm("`interact'","ind.w.*cat.*")==1 | regexm("`interact'","ind.v.*cat.*")==1  {
local propinteract=regexr("`interact'","w.","")
local propinteract=regexr("`propinteract'","v.","")
local propinteract=regexr("`propinteract'","migpur","madjpur")
local propinteract=regexr("`propinteract'","mig","migadj")
local propinteract=regexr("`propinteract'","infpur","iadjpur")
local propinteract=regexr("`propinteract'","inf","infadj")
local propinteract=regexr("`propinteract'","exp","nor")
*since the adj wages have been multiplied by proportion of migrant jobs, we will be doing this twice if multiply both. so take one off the skill shock.
*this requires I have infadj in skill shocks and inf in wage shocks






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
		

		cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'320*`interact'320*`propinteract'320    +   `thing'`cut'323*`interact'323*`propinteract'323    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'325*`interact'325*`propinteract'325    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'347*`interact'347*`propinteract'347    +   `thing'`cut'348*`interact'348*`propinteract'348    +   `thing'`cut'349*`interact'349*`propinteract'349    +   `thing'`cut'350*`interact'350*`propinteract'350    +   `thing'`cut'351*`interact'351*`propinteract'351    +   `thing'`cut'352*`interact'352*`propinteract'352    +   `thing'`cut'353*`interact'353*`propinteract'353    +   `thing'`cut'354*`interact'354*`propinteract'354    +   `thing'`cut'355*`interact'355*`propinteract'355    +   `thing'`cut'356*`interact'356*`propinteract'356    +   `thing'`cut'357*`interact'357*`propinteract'357	+	`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308    +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317    +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340    +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346
		cap gen `thing'`abbrev'`ends'_`cut'13=`thing'`cut'110*`interact'110*`propinteract'110	+	`thing'`cut'112*`interact'112*`propinteract'112	+	`thing'`cut'210*`interact'210*`propinteract'210	+	`thing'`cut'211*`interact'211*`propinteract'211	+	`thing'`cut'220*`interact'220*`propinteract'220	+	`thing'`cut'230*`interact'230*`propinteract'230	+	`thing'`cut'239*`interact'239*`propinteract'239	+	`thing'`cut'320*`interact'320*`propinteract'320    +   `thing'`cut'323*`interact'323*`propinteract'323    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'325*`interact'325*`propinteract'325    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'347*`interact'347*`propinteract'347    +   `thing'`cut'348*`interact'348*`propinteract'348    +   `thing'`cut'349*`interact'349*`propinteract'349    +   `thing'`cut'350*`interact'350*`propinteract'350    +   `thing'`cut'351*`interact'351*`propinteract'351    +   `thing'`cut'352*`interact'352*`propinteract'352    +   `thing'`cut'353*`interact'353*`propinteract'353    +   `thing'`cut'354*`interact'354*`propinteract'354    +   `thing'`cut'355*`interact'355*`propinteract'355    +   `thing'`cut'356*`interact'356*`propinteract'356    +   `thing'`cut'357*`interact'357*`propinteract'357	+	`thing'`cut'301*`interact'301*`propinteract'301    +   `thing'`cut'302*`interact'302*`propinteract'302    +   `thing'`cut'303*`interact'303*`propinteract'303    +   `thing'`cut'304*`interact'304*`propinteract'304    +   `thing'`cut'305*`interact'305*`propinteract'305    +   `thing'`cut'306*`interact'306*`propinteract'306    +   `thing'`cut'307*`interact'307*`propinteract'307    +   `thing'`cut'308*`interact'308*`propinteract'308    +   `thing'`cut'309*`interact'309*`propinteract'309    +   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'312*`interact'312*`propinteract'312    +   `thing'`cut'313*`interact'313*`propinteract'313    +   `thing'`cut'314*`interact'314*`propinteract'314    +   `thing'`cut'315*`interact'315*`propinteract'315    +   `thing'`cut'316*`interact'316*`propinteract'316    +   `thing'`cut'317*`interact'317*`propinteract'317    +   `thing'`cut'318*`interact'318*`propinteract'318    +   `thing'`cut'319*`interact'319*`propinteract'319    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'327*`interact'327*`propinteract'327    +   `thing'`cut'328*`interact'328*`propinteract'328    +   `thing'`cut'329*`interact'329*`propinteract'329    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'331*`interact'331*`propinteract'331    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333    +   `thing'`cut'334*`interact'334*`propinteract'334    +   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'337*`interact'337*`propinteract'337    +   `thing'`cut'338*`interact'338*`propinteract'338    +   `thing'`cut'339*`interact'339*`propinteract'339    +   `thing'`cut'340*`interact'340*`propinteract'340    +   `thing'`cut'341*`interact'341*`propinteract'341    +   `thing'`cut'342*`interact'342*`propinteract'342    +   `thing'`cut'343*`interact'343*`propinteract'343    +   `thing'`cut'344*`interact'344*`propinteract'344    +   `thing'`cut'345*`interact'345*`propinteract'345    +   `thing'`cut'346*`interact'346*`propinteract'346	+ `thing'`cut'430*`interact'430*`propinteract'430	+	`thing'`cut'433*`interact'433*`propinteract'433	+	`thing'`cut'465*`interact'465*`propinteract'465	+	`thing'`cut'467*`interact'467*`propinteract'467	+	`thing'`cut'469*`interact'469*`propinteract'469	+	`thing'`cut'480*`interact'480*`propinteract'480	+	`thing'`cut'483*`interact'483*`propinteract'483	+	`thing'`cut'487*`interact'487*`propinteract'487	+	`thing'`cut'490*`interact'490*`propinteract'490	+	`thing'`cut'511*`interact'511*`propinteract'511	+	`thing'`cut'520*`interact'520*`propinteract'520	+	`thing'`cut'530*`interact'530*`propinteract'530	+	`thing'`cut'540*`interact'540*`propinteract'540	+	`thing'`cut'562*`interact'562*`propinteract'562	+	`thing'`cut'610*`interact'610*`propinteract'610	+	`thing'`cut'620*`interact'620*`propinteract'620	+	`thing'`cut'710*`interact'710*`propinteract'710	+	`thing'`cut'720*`interact'720*`propinteract'720	+	`thing'`cut'721*`interact'721*`propinteract'721	+	`thing'`cut'810*`interact'810*`propinteract'810	+	`thing'`cut'815*`interact'815*`propinteract'815	+	`thing'`cut'939*`interact'939*`propinteract'939	
		
		
		cap gen `thing'`abbrev'`ends'_`cut'17=`thing'`cut'110*`interact'110*`propinteract'110*(1-exp5_110)	+	`thing'`cut'112*`interact'112*`propinteract'112*(1-exp5_112)	+	`thing'`cut'210*`interact'210*`propinteract'210*(1-exp5_210)	+	`thing'`cut'211*`interact'211*`propinteract'211*(1-exp5_211)	+	`thing'`cut'220*`interact'220*`propinteract'220*(1-exp5_220)	+	`thing'`cut'230*`interact'230*`propinteract'230*(1-exp5_230)	+	`thing'`cut'239*`interact'239*`propinteract'239*(1-exp5_239)	+	`thing'`cut'320*`interact'320*`propinteract'320*(1-exp5_320)    +   `thing'`cut'323*`interact'323*`propinteract'323*(1-exp5_323)    +   `thing'`cut'324*`interact'324*`propinteract'324*(1-exp5_324)    +   `thing'`cut'325*`interact'325*`propinteract'325*(1-exp5_325)    +   `thing'`cut'326*`interact'326*`propinteract'326*(1-exp5_326)    +   `thing'`cut'347*`interact'347*`propinteract'347*(1-exp5_347)    +   `thing'`cut'348*`interact'348*`propinteract'348*(1-exp5_348)    +   `thing'`cut'349*`interact'349*`propinteract'349*(1-exp5_349)    +   `thing'`cut'350*`interact'350*`propinteract'350*(1-exp5_350)    +   `thing'`cut'351*`interact'351*`propinteract'351*(1-exp5_351)    +   `thing'`cut'352*`interact'352*`propinteract'352*(1-exp5_352)    +   `thing'`cut'353*`interact'353*`propinteract'353*(1-exp5_353)    +   `thing'`cut'354*`interact'354*`propinteract'354*(1-exp5_354)    +   `thing'`cut'355*`interact'355*`propinteract'355*(1-exp5_355)    +   `thing'`cut'356*`interact'356*`propinteract'356*(1-exp5_356)    +   `thing'`cut'357*`interact'357*`propinteract'357*(1-exp5_357)	+	`thing'`cut'301*`interact'301*`propinteract'301*(1-exp5_301)    +   `thing'`cut'302*`interact'302*`propinteract'302*(1-exp5_302)    +   `thing'`cut'303*`interact'303*`propinteract'303*(1-exp5_303)    +   `thing'`cut'304*`interact'304*`propinteract'304*(1-exp5_304)    +   `thing'`cut'305*`interact'305*`propinteract'305*(1-exp5_305)    +   `thing'`cut'306*`interact'306*`propinteract'306*(1-exp5_306)    +   `thing'`cut'307*`interact'307*`propinteract'307*(1-exp5_307)    +   `thing'`cut'308*`interact'308*`propinteract'308*(1-exp5_308)    +   `thing'`cut'309*`interact'309*`propinteract'309*(1-exp5_309)    +   `thing'`cut'310*`interact'310*`propinteract'310*(1-exp5_310)    +   `thing'`cut'311*`interact'311*`propinteract'311*(1-exp5_311)    +   `thing'`cut'312*`interact'312*`propinteract'312*(1-exp5_312)    +   `thing'`cut'313*`interact'313*`propinteract'313*(1-exp5_313)    +   `thing'`cut'314*`interact'314*`propinteract'314*(1-exp5_314)    +   `thing'`cut'315*`interact'315*`propinteract'315*(1-exp5_315)    +   `thing'`cut'316*`interact'316*`propinteract'316*(1-exp5_316)    +   `thing'`cut'317*`interact'317*`propinteract'317*(1-exp5_317)    +   `thing'`cut'318*`interact'318*`propinteract'318*(1-exp5_318)    +   `thing'`cut'319*`interact'319*`propinteract'319*(1-exp5_319)    +   `thing'`cut'321*`interact'321*`propinteract'321*(1-exp5_321)    +   `thing'`cut'322*`interact'322*`propinteract'322*(1-exp5_322)    +   `thing'`cut'327*`interact'327*`propinteract'327*(1-exp5_327)    +   `thing'`cut'328*`interact'328*`propinteract'328*(1-exp5_328)    +   `thing'`cut'329*`interact'329*`propinteract'329*(1-exp5_329)    +   `thing'`cut'330*`interact'330*`propinteract'330*(1-exp5_330)    +   `thing'`cut'331*`interact'331*`propinteract'331*(1-exp5_331)    +   `thing'`cut'332*`interact'332*`propinteract'332*(1-exp5_332)    +   `thing'`cut'333*`interact'333*`propinteract'333*(1-exp5_333)    +   `thing'`cut'334*`interact'334*`propinteract'334*(1-exp5_334)    +   `thing'`cut'335*`interact'335*`propinteract'335*(1-exp5_335)    +   `thing'`cut'336*`interact'336*`propinteract'336*(1-exp5_336)    +   `thing'`cut'337*`interact'337*`propinteract'337*(1-exp5_337)    +   `thing'`cut'338*`interact'338*`propinteract'338*(1-exp5_338)    +   `thing'`cut'339*`interact'339*`propinteract'339*(1-exp5_339)    +   `thing'`cut'340*`interact'340*`propinteract'340*(1-exp5_340)    +   `thing'`cut'341*`interact'341*`propinteract'341*(1-exp5_341)    +   `thing'`cut'342*`interact'342*`propinteract'342*(1-exp5_342)    +   `thing'`cut'343*`interact'343*`propinteract'343*(1-exp5_343)    +   `thing'`cut'344*`interact'344*`propinteract'344*(1-exp5_344)    +   `thing'`cut'345*`interact'345*`propinteract'345*(1-exp5_345)    +   `thing'`cut'346*`interact'346*`propinteract'346*(1-exp5_346)	+ `thing'`cut'430*`interact'430*`propinteract'430*(1-exp5_430)	+	`thing'`cut'433*`interact'433*`propinteract'433*(1-exp5_433)	+	`thing'`cut'465*`interact'465*`propinteract'465*(1-exp5_465)	+	`thing'`cut'467*`interact'467*`propinteract'467*(1-exp5_467)	+	`thing'`cut'469*`interact'469*`propinteract'469*(1-exp5_469)	+	`thing'`cut'480*`interact'480*`propinteract'480*(1-exp5_480)	+	`thing'`cut'483*`interact'483*`propinteract'483*(1-exp5_483)	+	`thing'`cut'487*`interact'487*`propinteract'487*(1-exp5_487)	+	`thing'`cut'490*`interact'490*`propinteract'490*(1-exp5_490)	+	`thing'`cut'511*`interact'511*`propinteract'511*(1-exp5_511)	+	`thing'`cut'520*`interact'520*`propinteract'520*(1-exp5_520)	+	`thing'`cut'530*`interact'530*`propinteract'530*(1-exp5_530)	+	`thing'`cut'540*`interact'540*`propinteract'540*(1-exp5_540)	+	`thing'`cut'562*`interact'562*`propinteract'562*(1-exp5_562)	+	`thing'`cut'610*`interact'610*`propinteract'610*(1-exp5_610)	+	`thing'`cut'620*`interact'620*`propinteract'620*(1-exp5_620)	+	`thing'`cut'710*`interact'710*`propinteract'710*(1-exp5_710)	+	`thing'`cut'720*`interact'720*`propinteract'720*(1-exp5_720)	+	`thing'`cut'721*`interact'721*`propinteract'721*(1-exp5_721)	+	`thing'`cut'810*`interact'810*`propinteract'810*(1-exp5_810)	+	`thing'`cut'815*`interact'815*`propinteract'815*(1-exp5_815)	+	`thing'`cut'939*`interact'939*`propinteract'939*(1-exp5_939)	
		cap gen `thing'`abbrev'`ends'_`cut'15=`thing'`cut'320*`interact'320*`propinteract'320*(1-exp5_320)    +   `thing'`cut'323*`interact'323*`propinteract'323*(1-exp5_323)    +   `thing'`cut'324*`interact'324*`propinteract'324*(1-exp5_324)    +   `thing'`cut'325*`interact'325*`propinteract'325*(1-exp5_325)    +   `thing'`cut'326*`interact'326*`propinteract'326*(1-exp5_326)    +   `thing'`cut'347*`interact'347*`propinteract'347*(1-exp5_347)    +   `thing'`cut'348*`interact'348*`propinteract'348*(1-exp5_348)    +   `thing'`cut'349*`interact'349*`propinteract'349*(1-exp5_349)    +   `thing'`cut'350*`interact'350*`propinteract'350*(1-exp5_350)    +   `thing'`cut'351*`interact'351*`propinteract'351*(1-exp5_351)    +   `thing'`cut'352*`interact'352*`propinteract'352*(1-exp5_352)    +   `thing'`cut'353*`interact'353*`propinteract'353*(1-exp5_353)    +   `thing'`cut'354*`interact'354*`propinteract'354*(1-exp5_354)    +   `thing'`cut'355*`interact'355*`propinteract'355*(1-exp5_355)    +   `thing'`cut'356*`interact'356*`propinteract'356*(1-exp5_356)    +   `thing'`cut'357*`interact'357*`propinteract'357*(1-exp5_357)	+	`thing'`cut'301*`interact'301*`propinteract'301*(1-exp5_301)    +   `thing'`cut'302*`interact'302*`propinteract'302*(1-exp5_302)    +   `thing'`cut'303*`interact'303*`propinteract'303*(1-exp5_303)    +   `thing'`cut'304*`interact'304*`propinteract'304*(1-exp5_304)    +   `thing'`cut'305*`interact'305*`propinteract'305*(1-exp5_305)    +   `thing'`cut'306*`interact'306*`propinteract'306*(1-exp5_306)    +   `thing'`cut'307*`interact'307*`propinteract'307*(1-exp5_307)    +   `thing'`cut'308*`interact'308*`propinteract'308*(1-exp5_308)    +   `thing'`cut'309*`interact'309*`propinteract'309*(1-exp5_309)    +   `thing'`cut'310*`interact'310*`propinteract'310*(1-exp5_310)    +   `thing'`cut'311*`interact'311*`propinteract'311*(1-exp5_311)    +   `thing'`cut'312*`interact'312*`propinteract'312*(1-exp5_312)    +   `thing'`cut'313*`interact'313*`propinteract'313*(1-exp5_313)    +   `thing'`cut'314*`interact'314*`propinteract'314*(1-exp5_314)    +   `thing'`cut'315*`interact'315*`propinteract'315*(1-exp5_315)    +   `thing'`cut'316*`interact'316*`propinteract'316*(1-exp5_316)    +   `thing'`cut'317*`interact'317*`propinteract'317*(1-exp5_317)    +   `thing'`cut'318*`interact'318*`propinteract'318*(1-exp5_318)    +   `thing'`cut'319*`interact'319*`propinteract'319*(1-exp5_319)    +   `thing'`cut'321*`interact'321*`propinteract'321*(1-exp5_321)    +   `thing'`cut'322*`interact'322*`propinteract'322*(1-exp5_322)    +   `thing'`cut'327*`interact'327*`propinteract'327*(1-exp5_327)    +   `thing'`cut'328*`interact'328*`propinteract'328*(1-exp5_328)    +   `thing'`cut'329*`interact'329*`propinteract'329*(1-exp5_329)    +   `thing'`cut'330*`interact'330*`propinteract'330*(1-exp5_330)    +   `thing'`cut'331*`interact'331*`propinteract'331*(1-exp5_331)    +   `thing'`cut'332*`interact'332*`propinteract'332*(1-exp5_332)    +   `thing'`cut'333*`interact'333*`propinteract'333*(1-exp5_333)    +   `thing'`cut'334*`interact'334*`propinteract'334*(1-exp5_334)    +   `thing'`cut'335*`interact'335*`propinteract'335*(1-exp5_335)    +   `thing'`cut'336*`interact'336*`propinteract'336*(1-exp5_336)    +   `thing'`cut'337*`interact'337*`propinteract'337*(1-exp5_337)    +   `thing'`cut'338*`interact'338*`propinteract'338*(1-exp5_338)    +   `thing'`cut'339*`interact'339*`propinteract'339*(1-exp5_339)    +   `thing'`cut'340*`interact'340*`propinteract'340*(1-exp5_340)    +   `thing'`cut'341*`interact'341*`propinteract'341*(1-exp5_341)    +   `thing'`cut'342*`interact'342*`propinteract'342*(1-exp5_342)    +   `thing'`cut'343*`interact'343*`propinteract'343*(1-exp5_343)    +   `thing'`cut'344*`interact'344*`propinteract'344*(1-exp5_344)    +   `thing'`cut'345*`interact'345*`propinteract'345*(1-exp5_345)    +   `thing'`cut'346*`interact'346*`propinteract'346*(1-exp5_346)
		cap gen `thing'`abbrev'`ends'_`cut'16=`thing'`cut'320*`interact'320*`propinteract'320*(exp5_320)    +   `thing'`cut'323*`interact'323*`propinteract'323*(exp5_323)    +   `thing'`cut'324*`interact'324*`propinteract'324*(exp5_324)    +   `thing'`cut'325*`interact'325*`propinteract'325*(exp5_325)    +   `thing'`cut'326*`interact'326*`propinteract'326*(exp5_326)    +   `thing'`cut'347*`interact'347*`propinteract'347*(exp5_347)    +   `thing'`cut'348*`interact'348*`propinteract'348*(exp5_348)    +   `thing'`cut'349*`interact'349*`propinteract'349*(exp5_349)    +   `thing'`cut'350*`interact'350*`propinteract'350*(exp5_350)    +   `thing'`cut'351*`interact'351*`propinteract'351*(exp5_351)    +   `thing'`cut'352*`interact'352*`propinteract'352*(exp5_352)    +   `thing'`cut'353*`interact'353*`propinteract'353*(exp5_353)    +   `thing'`cut'354*`interact'354*`propinteract'354*(exp5_354)    +   `thing'`cut'355*`interact'355*`propinteract'355*(exp5_355)    +   `thing'`cut'356*`interact'356*`propinteract'356*(exp5_356)    +   `thing'`cut'357*`interact'357*`propinteract'357*(exp5_357)	+	`thing'`cut'301*`interact'301*`propinteract'301*(exp5_301)    +   `thing'`cut'302*`interact'302*`propinteract'302*(exp5_302)    +   `thing'`cut'303*`interact'303*`propinteract'303*(exp5_303)    +   `thing'`cut'304*`interact'304*`propinteract'304*(exp5_304)    +   `thing'`cut'305*`interact'305*`propinteract'305*(exp5_305)    +   `thing'`cut'306*`interact'306*`propinteract'306*(exp5_306)    +   `thing'`cut'307*`interact'307*`propinteract'307*(exp5_307)    +   `thing'`cut'308*`interact'308*`propinteract'308*(exp5_308)    +   `thing'`cut'309*`interact'309*`propinteract'309*(exp5_309)    +   `thing'`cut'310*`interact'310*`propinteract'310*(exp5_310)    +   `thing'`cut'311*`interact'311*`propinteract'311*(exp5_311)    +   `thing'`cut'312*`interact'312*`propinteract'312*(exp5_312)    +   `thing'`cut'313*`interact'313*`propinteract'313*(exp5_313)    +   `thing'`cut'314*`interact'314*`propinteract'314*(exp5_314)    +   `thing'`cut'315*`interact'315*`propinteract'315*(exp5_315)    +   `thing'`cut'316*`interact'316*`propinteract'316*(exp5_316)    +   `thing'`cut'317*`interact'317*`propinteract'317*(exp5_317)    +   `thing'`cut'318*`interact'318*`propinteract'318*(exp5_318)    +   `thing'`cut'319*`interact'319*`propinteract'319*(exp5_319)    +   `thing'`cut'321*`interact'321*`propinteract'321*(exp5_321)    +   `thing'`cut'322*`interact'322*`propinteract'322*(exp5_322)    +   `thing'`cut'327*`interact'327*`propinteract'327*(exp5_327)    +   `thing'`cut'328*`interact'328*`propinteract'328*(exp5_328)    +   `thing'`cut'329*`interact'329*`propinteract'329*(exp5_329)    +   `thing'`cut'330*`interact'330*`propinteract'330*(exp5_330)    +   `thing'`cut'331*`interact'331*`propinteract'331*(exp5_331)    +   `thing'`cut'332*`interact'332*`propinteract'332*(exp5_332)    +   `thing'`cut'333*`interact'333*`propinteract'333*(exp5_333)    +   `thing'`cut'334*`interact'334*`propinteract'334*(exp5_334)    +   `thing'`cut'335*`interact'335*`propinteract'335*(exp5_335)    +   `thing'`cut'336*`interact'336*`propinteract'336*(exp5_336)    +   `thing'`cut'337*`interact'337*`propinteract'337*(exp5_337)    +   `thing'`cut'338*`interact'338*`propinteract'338*(exp5_338)    +   `thing'`cut'339*`interact'339*`propinteract'339*(exp5_339)    +   `thing'`cut'340*`interact'340*`propinteract'340*(exp5_340)    +   `thing'`cut'341*`interact'341*`propinteract'341*(exp5_341)    +   `thing'`cut'342*`interact'342*`propinteract'342*(exp5_342)    +   `thing'`cut'343*`interact'343*`propinteract'343*(exp5_343)    +   `thing'`cut'344*`interact'344*`propinteract'344*(exp5_344)    +   `thing'`cut'345*`interact'345*`propinteract'345*(exp5_345)    +   `thing'`cut'346*`interact'346*`propinteract'346*(exp5_346)
		
		cap gen `thing'`abbrev'`ends'_`cut'27=`thing'`cut'110*`interact'110*`propinteract'110*(1-exp25_110)	+	`thing'`cut'112*`interact'112*`propinteract'112*(1-exp25_112)	+	`thing'`cut'210*`interact'210*`propinteract'210*(1-exp25_210)	+	`thing'`cut'211*`interact'211*`propinteract'211*(1-exp25_211)	+	`thing'`cut'220*`interact'220*`propinteract'220*(1-exp25_220)	+	`thing'`cut'230*`interact'230*`propinteract'230*(1-exp25_230)	+	`thing'`cut'239*`interact'239*`propinteract'239*(1-exp25_239)	+	`thing'`cut'320*`interact'320*`propinteract'320*(1-exp25_320)    +   `thing'`cut'323*`interact'323*`propinteract'323*(1-exp25_323)    +   `thing'`cut'324*`interact'324*`propinteract'324*(1-exp25_324)    +   `thing'`cut'325*`interact'325*`propinteract'325*(1-exp25_325)    +   `thing'`cut'326*`interact'326*`propinteract'326*(1-exp25_326)    +   `thing'`cut'347*`interact'347*`propinteract'347*(1-exp25_347)    +   `thing'`cut'348*`interact'348*`propinteract'348*(1-exp25_348)    +   `thing'`cut'349*`interact'349*`propinteract'349*(1-exp25_349)    +   `thing'`cut'350*`interact'350*`propinteract'350*(1-exp25_350)    +   `thing'`cut'351*`interact'351*`propinteract'351*(1-exp25_351)    +   `thing'`cut'352*`interact'352*`propinteract'352*(1-exp25_352)    +   `thing'`cut'353*`interact'353*`propinteract'353*(1-exp25_353)    +   `thing'`cut'354*`interact'354*`propinteract'354*(1-exp25_354)    +   `thing'`cut'355*`interact'355*`propinteract'355*(1-exp25_355)    +   `thing'`cut'356*`interact'356*`propinteract'356*(1-exp25_356)    +   `thing'`cut'357*`interact'357*`propinteract'357*(1-exp25_357)	+	`thing'`cut'301*`interact'301*`propinteract'301*(1-exp25_301)    +   `thing'`cut'302*`interact'302*`propinteract'302*(1-exp25_302)    +   `thing'`cut'303*`interact'303*`propinteract'303*(1-exp25_303)    +   `thing'`cut'304*`interact'304*`propinteract'304*(1-exp25_304)    +   `thing'`cut'305*`interact'305*`propinteract'305*(1-exp25_305)    +   `thing'`cut'306*`interact'306*`propinteract'306*(1-exp25_306)    +   `thing'`cut'307*`interact'307*`propinteract'307*(1-exp25_307)    +   `thing'`cut'308*`interact'308*`propinteract'308*(1-exp25_308)    +   `thing'`cut'309*`interact'309*`propinteract'309*(1-exp25_309)    +   `thing'`cut'310*`interact'310*`propinteract'310*(1-exp25_310)    +   `thing'`cut'311*`interact'311*`propinteract'311*(1-exp25_311)    +   `thing'`cut'312*`interact'312*`propinteract'312*(1-exp25_312)    +   `thing'`cut'313*`interact'313*`propinteract'313*(1-exp25_313)    +   `thing'`cut'314*`interact'314*`propinteract'314*(1-exp25_314)    +   `thing'`cut'315*`interact'315*`propinteract'315*(1-exp25_315)    +   `thing'`cut'316*`interact'316*`propinteract'316*(1-exp25_316)    +   `thing'`cut'317*`interact'317*`propinteract'317*(1-exp25_317)    +   `thing'`cut'318*`interact'318*`propinteract'318*(1-exp25_318)    +   `thing'`cut'319*`interact'319*`propinteract'319*(1-exp25_319)    +   `thing'`cut'321*`interact'321*`propinteract'321*(1-exp25_321)    +   `thing'`cut'322*`interact'322*`propinteract'322*(1-exp25_322)    +   `thing'`cut'327*`interact'327*`propinteract'327*(1-exp25_327)    +   `thing'`cut'328*`interact'328*`propinteract'328*(1-exp25_328)    +   `thing'`cut'329*`interact'329*`propinteract'329*(1-exp25_329)    +   `thing'`cut'330*`interact'330*`propinteract'330*(1-exp25_330)    +   `thing'`cut'331*`interact'331*`propinteract'331*(1-exp25_331)    +   `thing'`cut'332*`interact'332*`propinteract'332*(1-exp25_332)    +   `thing'`cut'333*`interact'333*`propinteract'333*(1-exp25_333)    +   `thing'`cut'334*`interact'334*`propinteract'334*(1-exp25_334)    +   `thing'`cut'335*`interact'335*`propinteract'335*(1-exp25_335)    +   `thing'`cut'336*`interact'336*`propinteract'336*(1-exp25_336)    +   `thing'`cut'337*`interact'337*`propinteract'337*(1-exp25_337)    +   `thing'`cut'338*`interact'338*`propinteract'338*(1-exp25_338)    +   `thing'`cut'339*`interact'339*`propinteract'339*(1-exp25_339)    +   `thing'`cut'340*`interact'340*`propinteract'340*(1-exp25_340)    +   `thing'`cut'341*`interact'341*`propinteract'341*(1-exp25_341)    +   `thing'`cut'342*`interact'342*`propinteract'342*(1-exp25_342)    +   `thing'`cut'343*`interact'343*`propinteract'343*(1-exp25_343)    +   `thing'`cut'344*`interact'344*`propinteract'344*(1-exp25_344)    +   `thing'`cut'345*`interact'345*`propinteract'345*(1-exp25_345)    +   `thing'`cut'346*`interact'346*`propinteract'346*(1-exp25_346)	+ `thing'`cut'430*`interact'430*`propinteract'430*(1-exp25_430)	+	`thing'`cut'433*`interact'433*`propinteract'433*(1-exp25_433)	+	`thing'`cut'465*`interact'465*`propinteract'465*(1-exp25_465)	+	`thing'`cut'467*`interact'467*`propinteract'467*(1-exp25_467)	+	`thing'`cut'469*`interact'469*`propinteract'469*(1-exp25_469)	+	`thing'`cut'480*`interact'480*`propinteract'480*(1-exp25_480)	+	`thing'`cut'483*`interact'483*`propinteract'483*(1-exp25_483)	+	`thing'`cut'487*`interact'487*`propinteract'487*(1-exp25_487)	+	`thing'`cut'490*`interact'490*`propinteract'490*(1-exp25_490)	+	`thing'`cut'511*`interact'511*`propinteract'511*(1-exp25_511)	+	`thing'`cut'520*`interact'520*`propinteract'520*(1-exp25_520)	+	`thing'`cut'530*`interact'530*`propinteract'530*(1-exp25_530)	+	`thing'`cut'540*`interact'540*`propinteract'540*(1-exp25_540)	+	`thing'`cut'562*`interact'562*`propinteract'562*(1-exp25_562)	+	`thing'`cut'610*`interact'610*`propinteract'610*(1-exp25_610)	+	`thing'`cut'620*`interact'620*`propinteract'620*(1-exp25_620)	+	`thing'`cut'710*`interact'710*`propinteract'710*(1-exp25_710)	+	`thing'`cut'720*`interact'720*`propinteract'720*(1-exp25_720)	+	`thing'`cut'721*`interact'721*`propinteract'721*(1-exp25_721)	+	`thing'`cut'810*`interact'810*`propinteract'810*(1-exp25_810)	+	`thing'`cut'815*`interact'815*`propinteract'815*(1-exp25_815)	+	`thing'`cut'939*`interact'939*`propinteract'939*(1-exp25_939)	
		cap gen `thing'`abbrev'`ends'_`cut'25=`thing'`cut'320*`interact'320*`propinteract'320*(1-exp25_320)    +   `thing'`cut'323*`interact'323*`propinteract'323*(1-exp25_323)    +   `thing'`cut'324*`interact'324*`propinteract'324*(1-exp25_324)    +   `thing'`cut'325*`interact'325*`propinteract'325*(1-exp25_325)    +   `thing'`cut'326*`interact'326*`propinteract'326*(1-exp25_326)    +   `thing'`cut'347*`interact'347*`propinteract'347*(1-exp25_347)    +   `thing'`cut'348*`interact'348*`propinteract'348*(1-exp25_348)    +   `thing'`cut'349*`interact'349*`propinteract'349*(1-exp25_349)    +   `thing'`cut'350*`interact'350*`propinteract'350*(1-exp25_350)    +   `thing'`cut'351*`interact'351*`propinteract'351*(1-exp25_351)    +   `thing'`cut'352*`interact'352*`propinteract'352*(1-exp25_352)    +   `thing'`cut'353*`interact'353*`propinteract'353*(1-exp25_353)    +   `thing'`cut'354*`interact'354*`propinteract'354*(1-exp25_354)    +   `thing'`cut'355*`interact'355*`propinteract'355*(1-exp25_355)    +   `thing'`cut'356*`interact'356*`propinteract'356*(1-exp25_356)    +   `thing'`cut'357*`interact'357*`propinteract'357*(1-exp25_357)	+	`thing'`cut'301*`interact'301*`propinteract'301*(1-exp25_301)    +   `thing'`cut'302*`interact'302*`propinteract'302*(1-exp25_302)    +   `thing'`cut'303*`interact'303*`propinteract'303*(1-exp25_303)    +   `thing'`cut'304*`interact'304*`propinteract'304*(1-exp25_304)    +   `thing'`cut'305*`interact'305*`propinteract'305*(1-exp25_305)    +   `thing'`cut'306*`interact'306*`propinteract'306*(1-exp25_306)    +   `thing'`cut'307*`interact'307*`propinteract'307*(1-exp25_307)    +   `thing'`cut'308*`interact'308*`propinteract'308*(1-exp25_308)    +   `thing'`cut'309*`interact'309*`propinteract'309*(1-exp25_309)    +   `thing'`cut'310*`interact'310*`propinteract'310*(1-exp25_310)    +   `thing'`cut'311*`interact'311*`propinteract'311*(1-exp25_311)    +   `thing'`cut'312*`interact'312*`propinteract'312*(1-exp25_312)    +   `thing'`cut'313*`interact'313*`propinteract'313*(1-exp25_313)    +   `thing'`cut'314*`interact'314*`propinteract'314*(1-exp25_314)    +   `thing'`cut'315*`interact'315*`propinteract'315*(1-exp25_315)    +   `thing'`cut'316*`interact'316*`propinteract'316*(1-exp25_316)    +   `thing'`cut'317*`interact'317*`propinteract'317*(1-exp25_317)    +   `thing'`cut'318*`interact'318*`propinteract'318*(1-exp25_318)    +   `thing'`cut'319*`interact'319*`propinteract'319*(1-exp25_319)    +   `thing'`cut'321*`interact'321*`propinteract'321*(1-exp25_321)    +   `thing'`cut'322*`interact'322*`propinteract'322*(1-exp25_322)    +   `thing'`cut'327*`interact'327*`propinteract'327*(1-exp25_327)    +   `thing'`cut'328*`interact'328*`propinteract'328*(1-exp25_328)    +   `thing'`cut'329*`interact'329*`propinteract'329*(1-exp25_329)    +   `thing'`cut'330*`interact'330*`propinteract'330*(1-exp25_330)    +   `thing'`cut'331*`interact'331*`propinteract'331*(1-exp25_331)    +   `thing'`cut'332*`interact'332*`propinteract'332*(1-exp25_332)    +   `thing'`cut'333*`interact'333*`propinteract'333*(1-exp25_333)    +   `thing'`cut'334*`interact'334*`propinteract'334*(1-exp25_334)    +   `thing'`cut'335*`interact'335*`propinteract'335*(1-exp25_335)    +   `thing'`cut'336*`interact'336*`propinteract'336*(1-exp25_336)    +   `thing'`cut'337*`interact'337*`propinteract'337*(1-exp25_337)    +   `thing'`cut'338*`interact'338*`propinteract'338*(1-exp25_338)    +   `thing'`cut'339*`interact'339*`propinteract'339*(1-exp25_339)    +   `thing'`cut'340*`interact'340*`propinteract'340*(1-exp25_340)    +   `thing'`cut'341*`interact'341*`propinteract'341*(1-exp25_341)    +   `thing'`cut'342*`interact'342*`propinteract'342*(1-exp25_342)    +   `thing'`cut'343*`interact'343*`propinteract'343*(1-exp25_343)    +   `thing'`cut'344*`interact'344*`propinteract'344*(1-exp25_344)    +   `thing'`cut'345*`interact'345*`propinteract'345*(1-exp25_345)    +   `thing'`cut'346*`interact'346*`propinteract'346*(1-exp25_346)
		cap gen `thing'`abbrev'`ends'_`cut'26=`thing'`cut'320*`interact'320*`propinteract'320*(exp25_320)    +   `thing'`cut'323*`interact'323*`propinteract'323*(exp25_323)    +   `thing'`cut'324*`interact'324*`propinteract'324*(exp25_324)    +   `thing'`cut'325*`interact'325*`propinteract'325*(exp25_325)    +   `thing'`cut'326*`interact'326*`propinteract'326*(exp25_326)    +   `thing'`cut'347*`interact'347*`propinteract'347*(exp25_347)    +   `thing'`cut'348*`interact'348*`propinteract'348*(exp25_348)    +   `thing'`cut'349*`interact'349*`propinteract'349*(exp25_349)    +   `thing'`cut'350*`interact'350*`propinteract'350*(exp25_350)    +   `thing'`cut'351*`interact'351*`propinteract'351*(exp25_351)    +   `thing'`cut'352*`interact'352*`propinteract'352*(exp25_352)    +   `thing'`cut'353*`interact'353*`propinteract'353*(exp25_353)    +   `thing'`cut'354*`interact'354*`propinteract'354*(exp25_354)    +   `thing'`cut'355*`interact'355*`propinteract'355*(exp25_355)    +   `thing'`cut'356*`interact'356*`propinteract'356*(exp25_356)    +   `thing'`cut'357*`interact'357*`propinteract'357*(exp25_357)	+	`thing'`cut'301*`interact'301*`propinteract'301*(exp25_301)    +   `thing'`cut'302*`interact'302*`propinteract'302*(exp25_302)    +   `thing'`cut'303*`interact'303*`propinteract'303*(exp25_303)    +   `thing'`cut'304*`interact'304*`propinteract'304*(exp25_304)    +   `thing'`cut'305*`interact'305*`propinteract'305*(exp25_305)    +   `thing'`cut'306*`interact'306*`propinteract'306*(exp25_306)    +   `thing'`cut'307*`interact'307*`propinteract'307*(exp25_307)    +   `thing'`cut'308*`interact'308*`propinteract'308*(exp25_308)    +   `thing'`cut'309*`interact'309*`propinteract'309*(exp25_309)    +   `thing'`cut'310*`interact'310*`propinteract'310*(exp25_310)    +   `thing'`cut'311*`interact'311*`propinteract'311*(exp25_311)    +   `thing'`cut'312*`interact'312*`propinteract'312*(exp25_312)    +   `thing'`cut'313*`interact'313*`propinteract'313*(exp25_313)    +   `thing'`cut'314*`interact'314*`propinteract'314*(exp25_314)    +   `thing'`cut'315*`interact'315*`propinteract'315*(exp25_315)    +   `thing'`cut'316*`interact'316*`propinteract'316*(exp25_316)    +   `thing'`cut'317*`interact'317*`propinteract'317*(exp25_317)    +   `thing'`cut'318*`interact'318*`propinteract'318*(exp25_318)    +   `thing'`cut'319*`interact'319*`propinteract'319*(exp25_319)    +   `thing'`cut'321*`interact'321*`propinteract'321*(exp25_321)    +   `thing'`cut'322*`interact'322*`propinteract'322*(exp25_322)    +   `thing'`cut'327*`interact'327*`propinteract'327*(exp25_327)    +   `thing'`cut'328*`interact'328*`propinteract'328*(exp25_328)    +   `thing'`cut'329*`interact'329*`propinteract'329*(exp25_329)    +   `thing'`cut'330*`interact'330*`propinteract'330*(exp25_330)    +   `thing'`cut'331*`interact'331*`propinteract'331*(exp25_331)    +   `thing'`cut'332*`interact'332*`propinteract'332*(exp25_332)    +   `thing'`cut'333*`interact'333*`propinteract'333*(exp25_333)    +   `thing'`cut'334*`interact'334*`propinteract'334*(exp25_334)    +   `thing'`cut'335*`interact'335*`propinteract'335*(exp25_335)    +   `thing'`cut'336*`interact'336*`propinteract'336*(exp25_336)    +   `thing'`cut'337*`interact'337*`propinteract'337*(exp25_337)    +   `thing'`cut'338*`interact'338*`propinteract'338*(exp25_338)    +   `thing'`cut'339*`interact'339*`propinteract'339*(exp25_339)    +   `thing'`cut'340*`interact'340*`propinteract'340*(exp25_340)    +   `thing'`cut'341*`interact'341*`propinteract'341*(exp25_341)    +   `thing'`cut'342*`interact'342*`propinteract'342*(exp25_342)    +   `thing'`cut'343*`interact'343*`propinteract'343*(exp25_343)    +   `thing'`cut'344*`interact'344*`propinteract'344*(exp25_344)    +   `thing'`cut'345*`interact'345*`propinteract'345*(exp25_345)    +   `thing'`cut'346*`interact'346*`propinteract'346*(exp25_346)
		

		
		}



}
else {
	if regexm("`interact'","pur")==1 {
	forval n=100/999 {
	cap gen X`interact'`n'=`interact'`n'
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

		cap gen `thing'`abbrev'`ends'_`cut'17=`thing'`cut'110*`interact'110*(1-exp5_110)	+	`thing'`cut'112*`interact'112*(1-exp5_112)	+	`thing'`cut'210*`interact'210*(1-exp5_210)	+	`thing'`cut'211*`interact'211*(1-exp5_211)	+	`thing'`cut'220*`interact'220*(1-exp5_220)	+	`thing'`cut'230*`interact'230*(1-exp5_230)	+	`thing'`cut'239*`interact'239*(1-exp5_239)	+	`thing'`cut'320*`interact'320*(1-exp5_320)    +   `thing'`cut'323*`interact'323*(1-exp5_323)    +   `thing'`cut'324*`interact'324*(1-exp5_324)    +   `thing'`cut'325*`interact'325*(1-exp5_325)    +   `thing'`cut'326*`interact'326*(1-exp5_326)    +   `thing'`cut'347*`interact'347*(1-exp5_347)    +   `thing'`cut'348*`interact'348*(1-exp5_348)    +   `thing'`cut'349*`interact'349*(1-exp5_349)    +   `thing'`cut'350*`interact'350*(1-exp5_350)    +   `thing'`cut'351*`interact'351*(1-exp5_351)    +   `thing'`cut'352*`interact'352*(1-exp5_352)    +   `thing'`cut'353*`interact'353*(1-exp5_353)    +   `thing'`cut'354*`interact'354*(1-exp5_354)    +   `thing'`cut'355*`interact'355*(1-exp5_355)    +   `thing'`cut'356*`interact'356*(1-exp5_356)    +   `thing'`cut'357*`interact'357*(1-exp5_357)	+	`thing'`cut'301*`interact'301*(1-exp5_301)    +   `thing'`cut'302*`interact'302*(1-exp5_302)    +   `thing'`cut'303*`interact'303*(1-exp5_303)    +   `thing'`cut'304*`interact'304*(1-exp5_304)    +   `thing'`cut'305*`interact'305*(1-exp5_305)    +   `thing'`cut'306*`interact'306*(1-exp5_306)    +   `thing'`cut'307*`interact'307*(1-exp5_307)    +   `thing'`cut'308*`interact'308*(1-exp5_308)    +   `thing'`cut'309*`interact'309*(1-exp5_309)    +   `thing'`cut'310*`interact'310*(1-exp5_310)    +   `thing'`cut'311*`interact'311*(1-exp5_311)    +   `thing'`cut'312*`interact'312*(1-exp5_312)    +   `thing'`cut'313*`interact'313*(1-exp5_313)    +   `thing'`cut'314*`interact'314*(1-exp5_314)    +   `thing'`cut'315*`interact'315*(1-exp5_315)    +   `thing'`cut'316*`interact'316*(1-exp5_316)    +   `thing'`cut'317*`interact'317*(1-exp5_317)    +   `thing'`cut'318*`interact'318*(1-exp5_318)    +   `thing'`cut'319*`interact'319*(1-exp5_319)    +   `thing'`cut'321*`interact'321*(1-exp5_321)    +   `thing'`cut'322*`interact'322*(1-exp5_322)    +   `thing'`cut'327*`interact'327*(1-exp5_327)    +   `thing'`cut'328*`interact'328*(1-exp5_328)    +   `thing'`cut'329*`interact'329*(1-exp5_329)    +   `thing'`cut'330*`interact'330*(1-exp5_330)    +   `thing'`cut'331*`interact'331*(1-exp5_331)    +   `thing'`cut'332*`interact'332*(1-exp5_332)    +   `thing'`cut'333*`interact'333*(1-exp5_333)    +   `thing'`cut'334*`interact'334*(1-exp5_334)    +   `thing'`cut'335*`interact'335*(1-exp5_335)    +   `thing'`cut'336*`interact'336*(1-exp5_336)    +   `thing'`cut'337*`interact'337*(1-exp5_337)    +   `thing'`cut'338*`interact'338*(1-exp5_338)    +   `thing'`cut'339*`interact'339*(1-exp5_339)    +   `thing'`cut'340*`interact'340*(1-exp5_340)    +   `thing'`cut'341*`interact'341*(1-exp5_341)    +   `thing'`cut'342*`interact'342*(1-exp5_342)    +   `thing'`cut'343*`interact'343*(1-exp5_343)    +   `thing'`cut'344*`interact'344*(1-exp5_344)    +   `thing'`cut'345*`interact'345*(1-exp5_345)    +   `thing'`cut'346*`interact'346*(1-exp5_346)	+ `thing'`cut'430*`interact'430*(1-exp5_430)	+	`thing'`cut'433*`interact'433*(1-exp5_433)	+	`thing'`cut'465*`interact'465*(1-exp5_465)	+	`thing'`cut'467*`interact'467*(1-exp5_467)	+	`thing'`cut'469*`interact'469*(1-exp5_469)	+	`thing'`cut'480*`interact'480*(1-exp5_480)	+	`thing'`cut'483*`interact'483*(1-exp5_483)	+	`thing'`cut'487*`interact'487*(1-exp5_487)	+	`thing'`cut'490*`interact'490*(1-exp5_490)	+	`thing'`cut'511*`interact'511*(1-exp5_511)	+	`thing'`cut'520*`interact'520*(1-exp5_520)	+	`thing'`cut'530*`interact'530*(1-exp5_530)	+	`thing'`cut'540*`interact'540*(1-exp5_540)	+	`thing'`cut'562*`interact'562*(1-exp5_562)	+	`thing'`cut'610*`interact'610*(1-exp5_610)	+	`thing'`cut'620*`interact'620*(1-exp5_620)	+	`thing'`cut'710*`interact'710*(1-exp5_710)	+	`thing'`cut'720*`interact'720*(1-exp5_720)	+	`thing'`cut'721*`interact'721*(1-exp5_721)	+	`thing'`cut'810*`interact'810*(1-exp5_810)	+	`thing'`cut'815*`interact'815*(1-exp5_815)	+	`thing'`cut'939*`interact'939*(1-exp5_939)	
		cap gen `thing'`abbrev'`ends'_`cut'15=`thing'`cut'320*`interact'320*(1-exp5_320)    +   `thing'`cut'323*`interact'323*(1-exp5_323)    +   `thing'`cut'324*`interact'324*(1-exp5_324)    +   `thing'`cut'325*`interact'325*(1-exp5_325)    +   `thing'`cut'326*`interact'326*(1-exp5_326)    +   `thing'`cut'347*`interact'347*(1-exp5_347)    +   `thing'`cut'348*`interact'348*(1-exp5_348)    +   `thing'`cut'349*`interact'349*(1-exp5_349)    +   `thing'`cut'350*`interact'350*(1-exp5_350)    +   `thing'`cut'351*`interact'351*(1-exp5_351)    +   `thing'`cut'352*`interact'352*(1-exp5_352)    +   `thing'`cut'353*`interact'353*(1-exp5_353)    +   `thing'`cut'354*`interact'354*(1-exp5_354)    +   `thing'`cut'355*`interact'355*(1-exp5_355)    +   `thing'`cut'356*`interact'356*(1-exp5_356)    +   `thing'`cut'357*`interact'357*(1-exp5_357)	+	`thing'`cut'301*`interact'301*(1-exp5_301)    +   `thing'`cut'302*`interact'302*(1-exp5_302)    +   `thing'`cut'303*`interact'303*(1-exp5_303)    +   `thing'`cut'304*`interact'304*(1-exp5_304)    +   `thing'`cut'305*`interact'305*(1-exp5_305)    +   `thing'`cut'306*`interact'306*(1-exp5_306)    +   `thing'`cut'307*`interact'307*(1-exp5_307)    +   `thing'`cut'308*`interact'308*(1-exp5_308)    +   `thing'`cut'309*`interact'309*(1-exp5_309)    +   `thing'`cut'310*`interact'310*(1-exp5_310)    +   `thing'`cut'311*`interact'311*(1-exp5_311)    +   `thing'`cut'312*`interact'312*(1-exp5_312)    +   `thing'`cut'313*`interact'313*(1-exp5_313)    +   `thing'`cut'314*`interact'314*(1-exp5_314)    +   `thing'`cut'315*`interact'315*(1-exp5_315)    +   `thing'`cut'316*`interact'316*(1-exp5_316)    +   `thing'`cut'317*`interact'317*(1-exp5_317)    +   `thing'`cut'318*`interact'318*(1-exp5_318)    +   `thing'`cut'319*`interact'319*(1-exp5_319)    +   `thing'`cut'321*`interact'321*(1-exp5_321)    +   `thing'`cut'322*`interact'322*(1-exp5_322)    +   `thing'`cut'327*`interact'327*(1-exp5_327)    +   `thing'`cut'328*`interact'328*(1-exp5_328)    +   `thing'`cut'329*`interact'329*(1-exp5_329)    +   `thing'`cut'330*`interact'330*(1-exp5_330)    +   `thing'`cut'331*`interact'331*(1-exp5_331)    +   `thing'`cut'332*`interact'332*(1-exp5_332)    +   `thing'`cut'333*`interact'333*(1-exp5_333)    +   `thing'`cut'334*`interact'334*(1-exp5_334)    +   `thing'`cut'335*`interact'335*(1-exp5_335)    +   `thing'`cut'336*`interact'336*(1-exp5_336)    +   `thing'`cut'337*`interact'337*(1-exp5_337)    +   `thing'`cut'338*`interact'338*(1-exp5_338)    +   `thing'`cut'339*`interact'339*(1-exp5_339)    +   `thing'`cut'340*`interact'340*(1-exp5_340)    +   `thing'`cut'341*`interact'341*(1-exp5_341)    +   `thing'`cut'342*`interact'342*(1-exp5_342)    +   `thing'`cut'343*`interact'343*(1-exp5_343)    +   `thing'`cut'344*`interact'344*(1-exp5_344)    +   `thing'`cut'345*`interact'345*(1-exp5_345)    +   `thing'`cut'346*`interact'346*(1-exp5_346)
		cap gen `thing'`abbrev'`ends'_`cut'16=`thing'`cut'320*`interact'320*(exp5_320)    +   `thing'`cut'323*`interact'323*(exp5_323)    +   `thing'`cut'324*`interact'324*(exp5_324)    +   `thing'`cut'325*`interact'325*(exp5_325)    +   `thing'`cut'326*`interact'326*(exp5_326)    +   `thing'`cut'347*`interact'347*(exp5_347)    +   `thing'`cut'348*`interact'348*(exp5_348)    +   `thing'`cut'349*`interact'349*(exp5_349)    +   `thing'`cut'350*`interact'350*(exp5_350)    +   `thing'`cut'351*`interact'351*(exp5_351)    +   `thing'`cut'352*`interact'352*(exp5_352)    +   `thing'`cut'353*`interact'353*(exp5_353)    +   `thing'`cut'354*`interact'354*(exp5_354)    +   `thing'`cut'355*`interact'355*(exp5_355)    +   `thing'`cut'356*`interact'356*(exp5_356)    +   `thing'`cut'357*`interact'357*(exp5_357)	+	`thing'`cut'301*`interact'301*(exp5_301)    +   `thing'`cut'302*`interact'302*(exp5_302)    +   `thing'`cut'303*`interact'303*(exp5_303)    +   `thing'`cut'304*`interact'304*(exp5_304)    +   `thing'`cut'305*`interact'305*(exp5_305)    +   `thing'`cut'306*`interact'306*(exp5_306)    +   `thing'`cut'307*`interact'307*(exp5_307)    +   `thing'`cut'308*`interact'308*(exp5_308)    +   `thing'`cut'309*`interact'309*(exp5_309)    +   `thing'`cut'310*`interact'310*(exp5_310)    +   `thing'`cut'311*`interact'311*(exp5_311)    +   `thing'`cut'312*`interact'312*(exp5_312)    +   `thing'`cut'313*`interact'313*(exp5_313)    +   `thing'`cut'314*`interact'314*(exp5_314)    +   `thing'`cut'315*`interact'315*(exp5_315)    +   `thing'`cut'316*`interact'316*(exp5_316)    +   `thing'`cut'317*`interact'317*(exp5_317)    +   `thing'`cut'318*`interact'318*(exp5_318)    +   `thing'`cut'319*`interact'319*(exp5_319)    +   `thing'`cut'321*`interact'321*(exp5_321)    +   `thing'`cut'322*`interact'322*(exp5_322)    +   `thing'`cut'327*`interact'327*(exp5_327)    +   `thing'`cut'328*`interact'328*(exp5_328)    +   `thing'`cut'329*`interact'329*(exp5_329)    +   `thing'`cut'330*`interact'330*(exp5_330)    +   `thing'`cut'331*`interact'331*(exp5_331)    +   `thing'`cut'332*`interact'332*(exp5_332)    +   `thing'`cut'333*`interact'333*(exp5_333)    +   `thing'`cut'334*`interact'334*(exp5_334)    +   `thing'`cut'335*`interact'335*(exp5_335)    +   `thing'`cut'336*`interact'336*(exp5_336)    +   `thing'`cut'337*`interact'337*(exp5_337)    +   `thing'`cut'338*`interact'338*(exp5_338)    +   `thing'`cut'339*`interact'339*(exp5_339)    +   `thing'`cut'340*`interact'340*(exp5_340)    +   `thing'`cut'341*`interact'341*(exp5_341)    +   `thing'`cut'342*`interact'342*(exp5_342)    +   `thing'`cut'343*`interact'343*(exp5_343)    +   `thing'`cut'344*`interact'344*(exp5_344)    +   `thing'`cut'345*`interact'345*(exp5_345)    +   `thing'`cut'346*`interact'346*(exp5_346)
		
		cap gen `thing'`abbrev'`ends'_`cut'27=`thing'`cut'110*`interact'110*(1-exp25_110)	+	`thing'`cut'112*`interact'112*(1-exp25_112)	+	`thing'`cut'210*`interact'210*(1-exp25_210)	+	`thing'`cut'211*`interact'211*(1-exp25_211)	+	`thing'`cut'220*`interact'220*(1-exp25_220)	+	`thing'`cut'230*`interact'230*(1-exp25_230)	+	`thing'`cut'239*`interact'239*(1-exp25_239)	+	`thing'`cut'320*`interact'320*(1-exp25_320)    +   `thing'`cut'323*`interact'323*(1-exp25_323)    +   `thing'`cut'324*`interact'324*(1-exp25_324)    +   `thing'`cut'325*`interact'325*(1-exp25_325)    +   `thing'`cut'326*`interact'326*(1-exp25_326)    +   `thing'`cut'347*`interact'347*(1-exp25_347)    +   `thing'`cut'348*`interact'348*(1-exp25_348)    +   `thing'`cut'349*`interact'349*(1-exp25_349)    +   `thing'`cut'350*`interact'350*(1-exp25_350)    +   `thing'`cut'351*`interact'351*(1-exp25_351)    +   `thing'`cut'352*`interact'352*(1-exp25_352)    +   `thing'`cut'353*`interact'353*(1-exp25_353)    +   `thing'`cut'354*`interact'354*(1-exp25_354)    +   `thing'`cut'355*`interact'355*(1-exp25_355)    +   `thing'`cut'356*`interact'356*(1-exp25_356)    +   `thing'`cut'357*`interact'357*(1-exp25_357)	+	`thing'`cut'301*`interact'301*(1-exp25_301)    +   `thing'`cut'302*`interact'302*(1-exp25_302)    +   `thing'`cut'303*`interact'303*(1-exp25_303)    +   `thing'`cut'304*`interact'304*(1-exp25_304)    +   `thing'`cut'305*`interact'305*(1-exp25_305)    +   `thing'`cut'306*`interact'306*(1-exp25_306)    +   `thing'`cut'307*`interact'307*(1-exp25_307)    +   `thing'`cut'308*`interact'308*(1-exp25_308)    +   `thing'`cut'309*`interact'309*(1-exp25_309)    +   `thing'`cut'310*`interact'310*(1-exp25_310)    +   `thing'`cut'311*`interact'311*(1-exp25_311)    +   `thing'`cut'312*`interact'312*(1-exp25_312)    +   `thing'`cut'313*`interact'313*(1-exp25_313)    +   `thing'`cut'314*`interact'314*(1-exp25_314)    +   `thing'`cut'315*`interact'315*(1-exp25_315)    +   `thing'`cut'316*`interact'316*(1-exp25_316)    +   `thing'`cut'317*`interact'317*(1-exp25_317)    +   `thing'`cut'318*`interact'318*(1-exp25_318)    +   `thing'`cut'319*`interact'319*(1-exp25_319)    +   `thing'`cut'321*`interact'321*(1-exp25_321)    +   `thing'`cut'322*`interact'322*(1-exp25_322)    +   `thing'`cut'327*`interact'327*(1-exp25_327)    +   `thing'`cut'328*`interact'328*(1-exp25_328)    +   `thing'`cut'329*`interact'329*(1-exp25_329)    +   `thing'`cut'330*`interact'330*(1-exp25_330)    +   `thing'`cut'331*`interact'331*(1-exp25_331)    +   `thing'`cut'332*`interact'332*(1-exp25_332)    +   `thing'`cut'333*`interact'333*(1-exp25_333)    +   `thing'`cut'334*`interact'334*(1-exp25_334)    +   `thing'`cut'335*`interact'335*(1-exp25_335)    +   `thing'`cut'336*`interact'336*(1-exp25_336)    +   `thing'`cut'337*`interact'337*(1-exp25_337)    +   `thing'`cut'338*`interact'338*(1-exp25_338)    +   `thing'`cut'339*`interact'339*(1-exp25_339)    +   `thing'`cut'340*`interact'340*(1-exp25_340)    +   `thing'`cut'341*`interact'341*(1-exp25_341)    +   `thing'`cut'342*`interact'342*(1-exp25_342)    +   `thing'`cut'343*`interact'343*(1-exp25_343)    +   `thing'`cut'344*`interact'344*(1-exp25_344)    +   `thing'`cut'345*`interact'345*(1-exp25_345)    +   `thing'`cut'346*`interact'346*(1-exp25_346)	+ `thing'`cut'430*`interact'430*(1-exp25_430)	+	`thing'`cut'433*`interact'433*(1-exp25_433)	+	`thing'`cut'465*`interact'465*(1-exp25_465)	+	`thing'`cut'467*`interact'467*(1-exp25_467)	+	`thing'`cut'469*`interact'469*(1-exp25_469)	+	`thing'`cut'480*`interact'480*(1-exp25_480)	+	`thing'`cut'483*`interact'483*(1-exp25_483)	+	`thing'`cut'487*`interact'487*(1-exp25_487)	+	`thing'`cut'490*`interact'490*(1-exp25_490)	+	`thing'`cut'511*`interact'511*(1-exp25_511)	+	`thing'`cut'520*`interact'520*(1-exp25_520)	+	`thing'`cut'530*`interact'530*(1-exp25_530)	+	`thing'`cut'540*`interact'540*(1-exp25_540)	+	`thing'`cut'562*`interact'562*(1-exp25_562)	+	`thing'`cut'610*`interact'610*(1-exp25_610)	+	`thing'`cut'620*`interact'620*(1-exp25_620)	+	`thing'`cut'710*`interact'710*(1-exp25_710)	+	`thing'`cut'720*`interact'720*(1-exp25_720)	+	`thing'`cut'721*`interact'721*(1-exp25_721)	+	`thing'`cut'810*`interact'810*(1-exp25_810)	+	`thing'`cut'815*`interact'815*(1-exp25_815)	+	`thing'`cut'939*`interact'939*(1-exp25_939)	
		cap gen `thing'`abbrev'`ends'_`cut'25=`thing'`cut'320*`interact'320*(1-exp25_320)    +   `thing'`cut'323*`interact'323*(1-exp25_323)    +   `thing'`cut'324*`interact'324*(1-exp25_324)    +   `thing'`cut'325*`interact'325*(1-exp25_325)    +   `thing'`cut'326*`interact'326*(1-exp25_326)    +   `thing'`cut'347*`interact'347*(1-exp25_347)    +   `thing'`cut'348*`interact'348*(1-exp25_348)    +   `thing'`cut'349*`interact'349*(1-exp25_349)    +   `thing'`cut'350*`interact'350*(1-exp25_350)    +   `thing'`cut'351*`interact'351*(1-exp25_351)    +   `thing'`cut'352*`interact'352*(1-exp25_352)    +   `thing'`cut'353*`interact'353*(1-exp25_353)    +   `thing'`cut'354*`interact'354*(1-exp25_354)    +   `thing'`cut'355*`interact'355*(1-exp25_355)    +   `thing'`cut'356*`interact'356*(1-exp25_356)    +   `thing'`cut'357*`interact'357*(1-exp25_357)	+	`thing'`cut'301*`interact'301*(1-exp25_301)    +   `thing'`cut'302*`interact'302*(1-exp25_302)    +   `thing'`cut'303*`interact'303*(1-exp25_303)    +   `thing'`cut'304*`interact'304*(1-exp25_304)    +   `thing'`cut'305*`interact'305*(1-exp25_305)    +   `thing'`cut'306*`interact'306*(1-exp25_306)    +   `thing'`cut'307*`interact'307*(1-exp25_307)    +   `thing'`cut'308*`interact'308*(1-exp25_308)    +   `thing'`cut'309*`interact'309*(1-exp25_309)    +   `thing'`cut'310*`interact'310*(1-exp25_310)    +   `thing'`cut'311*`interact'311*(1-exp25_311)    +   `thing'`cut'312*`interact'312*(1-exp25_312)    +   `thing'`cut'313*`interact'313*(1-exp25_313)    +   `thing'`cut'314*`interact'314*(1-exp25_314)    +   `thing'`cut'315*`interact'315*(1-exp25_315)    +   `thing'`cut'316*`interact'316*(1-exp25_316)    +   `thing'`cut'317*`interact'317*(1-exp25_317)    +   `thing'`cut'318*`interact'318*(1-exp25_318)    +   `thing'`cut'319*`interact'319*(1-exp25_319)    +   `thing'`cut'321*`interact'321*(1-exp25_321)    +   `thing'`cut'322*`interact'322*(1-exp25_322)    +   `thing'`cut'327*`interact'327*(1-exp25_327)    +   `thing'`cut'328*`interact'328*(1-exp25_328)    +   `thing'`cut'329*`interact'329*(1-exp25_329)    +   `thing'`cut'330*`interact'330*(1-exp25_330)    +   `thing'`cut'331*`interact'331*(1-exp25_331)    +   `thing'`cut'332*`interact'332*(1-exp25_332)    +   `thing'`cut'333*`interact'333*(1-exp25_333)    +   `thing'`cut'334*`interact'334*(1-exp25_334)    +   `thing'`cut'335*`interact'335*(1-exp25_335)    +   `thing'`cut'336*`interact'336*(1-exp25_336)    +   `thing'`cut'337*`interact'337*(1-exp25_337)    +   `thing'`cut'338*`interact'338*(1-exp25_338)    +   `thing'`cut'339*`interact'339*(1-exp25_339)    +   `thing'`cut'340*`interact'340*(1-exp25_340)    +   `thing'`cut'341*`interact'341*(1-exp25_341)    +   `thing'`cut'342*`interact'342*(1-exp25_342)    +   `thing'`cut'343*`interact'343*(1-exp25_343)    +   `thing'`cut'344*`interact'344*(1-exp25_344)    +   `thing'`cut'345*`interact'345*(1-exp25_345)    +   `thing'`cut'346*`interact'346*(1-exp25_346)
		cap gen `thing'`abbrev'`ends'_`cut'26=`thing'`cut'320*`interact'320*(exp25_320)    +   `thing'`cut'323*`interact'323*(exp25_323)    +   `thing'`cut'324*`interact'324*(exp25_324)    +   `thing'`cut'325*`interact'325*(exp25_325)    +   `thing'`cut'326*`interact'326*(exp25_326)    +   `thing'`cut'347*`interact'347*(exp25_347)    +   `thing'`cut'348*`interact'348*(exp25_348)    +   `thing'`cut'349*`interact'349*(exp25_349)    +   `thing'`cut'350*`interact'350*(exp25_350)    +   `thing'`cut'351*`interact'351*(exp25_351)    +   `thing'`cut'352*`interact'352*(exp25_352)    +   `thing'`cut'353*`interact'353*(exp25_353)    +   `thing'`cut'354*`interact'354*(exp25_354)    +   `thing'`cut'355*`interact'355*(exp25_355)    +   `thing'`cut'356*`interact'356*(exp25_356)    +   `thing'`cut'357*`interact'357*(exp25_357)	+	`thing'`cut'301*`interact'301*(exp25_301)    +   `thing'`cut'302*`interact'302*(exp25_302)    +   `thing'`cut'303*`interact'303*(exp25_303)    +   `thing'`cut'304*`interact'304*(exp25_304)    +   `thing'`cut'305*`interact'305*(exp25_305)    +   `thing'`cut'306*`interact'306*(exp25_306)    +   `thing'`cut'307*`interact'307*(exp25_307)    +   `thing'`cut'308*`interact'308*(exp25_308)    +   `thing'`cut'309*`interact'309*(exp25_309)    +   `thing'`cut'310*`interact'310*(exp25_310)    +   `thing'`cut'311*`interact'311*(exp25_311)    +   `thing'`cut'312*`interact'312*(exp25_312)    +   `thing'`cut'313*`interact'313*(exp25_313)    +   `thing'`cut'314*`interact'314*(exp25_314)    +   `thing'`cut'315*`interact'315*(exp25_315)    +   `thing'`cut'316*`interact'316*(exp25_316)    +   `thing'`cut'317*`interact'317*(exp25_317)    +   `thing'`cut'318*`interact'318*(exp25_318)    +   `thing'`cut'319*`interact'319*(exp25_319)    +   `thing'`cut'321*`interact'321*(exp25_321)    +   `thing'`cut'322*`interact'322*(exp25_322)    +   `thing'`cut'327*`interact'327*(exp25_327)    +   `thing'`cut'328*`interact'328*(exp25_328)    +   `thing'`cut'329*`interact'329*(exp25_329)    +   `thing'`cut'330*`interact'330*(exp25_330)    +   `thing'`cut'331*`interact'331*(exp25_331)    +   `thing'`cut'332*`interact'332*(exp25_332)    +   `thing'`cut'333*`interact'333*(exp25_333)    +   `thing'`cut'334*`interact'334*(exp25_334)    +   `thing'`cut'335*`interact'335*(exp25_335)    +   `thing'`cut'336*`interact'336*(exp25_336)    +   `thing'`cut'337*`interact'337*(exp25_337)    +   `thing'`cut'338*`interact'338*(exp25_338)    +   `thing'`cut'339*`interact'339*(exp25_339)    +   `thing'`cut'340*`interact'340*(exp25_340)    +   `thing'`cut'341*`interact'341*(exp25_341)    +   `thing'`cut'342*`interact'342*(exp25_342)    +   `thing'`cut'343*`interact'343*(exp25_343)    +   `thing'`cut'344*`interact'344*(exp25_344)    +   `thing'`cut'345*`interact'345*(exp25_345)    +   `thing'`cut'346*`interact'346*(exp25_346)
		


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









