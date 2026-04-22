
* so this is the key file for forming my service and manufacturing sector form the 40 odd hcodes, as well as doing all the industry level interactions.
* the local `listhcode' is pulled from this file, depending on what interaction terms I choose.


/**----------------------------------------------------------------------**/
*here I chose the variables I pull form the various wide files with hcoded means	
*if these get too long then it fails to do subtitutions properly, so split up.
*so check this. There should be no asterisks appearing in output (if there are, shorten one of the strings)
qui {
				



/**
Note:
Wage percentage measures must go before the percentages tehmselves as the percentages get dropped after use and are needed for wage premia.
The wage variables, with w replaced by z are the jobs by skill level having dropped jobs for whcih pur wage data not available
**/



local listinteract ""
local listinteract: subinstr local listinteract "*" "", all

local listnicexpmpopx: subinstr local listnicexpmpop "*" "", all
local listnicexpmpopx2: subinstr local listnicexpmpopx "ind" "", all







foreach thing in deltaemp  {
foreach interact in `listinteract'  {
local clean=subinstr("`interact'","_","",.)

if regexm("`clean'","ind.w.*cat.*")==1 {
local clean=subinstr("`clean'","cat","c",.)
}

local clean=subinstr("`clean'","indmwischl","indwis",.)
local clean=subinstr("`clean'","indmwnschl","indwns",.)


local clean=subinstr("`clean'","indmwiperca","indwieo",.)
local clean=subinstr("`clean'","indfwiperca","indwifo",.)
local clean=subinstr("`clean'","indhwiperca","indwimo",.)
local clean=subinstr("`clean'","indmwnperca","indwneo",.)
local clean=subinstr("`clean'","indfwnperca","indwnfo",.)
local clean=subinstr("`clean'","indhwnperca","indwnmo",.)
local clean=subinstr("`clean'","indmwgperca","indwgeo",.)
local clean=subinstr("`clean'","indfwgperca","indwgfo",.)
local clean=subinstr("`clean'","indhwgperca","indwgmo",.)
local clean=subinstr("`clean'","indmperca","indeo",.)
local clean=subinstr("`clean'","indfperca","indfo",.)
local clean=subinstr("`clean'","indhperca","indmo",.)


local clean=subinstr("`clean'","indmwiaperca","indwiea",.)
local clean=subinstr("`clean'","indfwiaperca","indwifa",.)
local clean=subinstr("`clean'","indhwiaperca","indwima",.)
local clean=subinstr("`clean'","indmwnaperca","indwnea",.)
local clean=subinstr("`clean'","indfwnaperca","indwnfa",.)
local clean=subinstr("`clean'","indhwnaperca","indwnma",.)
local clean=subinstr("`clean'","indmwgaperca","indwgea",.)
local clean=subinstr("`clean'","indfwgaperca","indwgfa",.)
local clean=subinstr("`clean'","indhwgaperca","indwgma",.)
local clean=subinstr("`clean'","indmaperca","indea",.)
local clean=subinstr("`clean'","indfaperca","indfa",.)
local clean=subinstr("`clean'","indhaperca","indma",.)

local clean=subinstr("`clean'","indmwicperca","indwiec",.)
local clean=subinstr("`clean'","indfwicperca","indwifc",.)
local clean=subinstr("`clean'","indhwicperca","indwimc",.)
local clean=subinstr("`clean'","indmwncperca","indwnec",.)
local clean=subinstr("`clean'","indfwncperca","indwnfc",.)
local clean=subinstr("`clean'","indhwncperca","indwnmc",.)
local clean=subinstr("`clean'","indmwgcperca","indwgec",.)
local clean=subinstr("`clean'","indfwgcperca","indwgfc",.)
local clean=subinstr("`clean'","indhwgcperca","indwgmc",.)
local clean=subinstr("`clean'","indmcperca","indec",.)
local clean=subinstr("`clean'","indfcperca","indfc",.)
local clean=subinstr("`clean'","indhcperca","indmc",.)


local clean=subinstr("`clean'","indmwidperca","indwied",.)
local clean=subinstr("`clean'","indfwidperca","indwifd",.)
local clean=subinstr("`clean'","indhwidperca","indwimd",.)
local clean=subinstr("`clean'","indmwndperca","indwned",.)
local clean=subinstr("`clean'","indfwndperca","indwnfd",.)
local clean=subinstr("`clean'","indhwndperca","indwnmd",.)
local clean=subinstr("`clean'","indmwgdperca","indwged",.)
local clean=subinstr("`clean'","indfwgdperca","indwgfd",.)
local clean=subinstr("`clean'","indhwgdperca","indwgmd",.)
local clean=subinstr("`clean'","indmdperca","inded",.)
local clean=subinstr("`clean'","indfdperca","indfd",.)
local clean=subinstr("`clean'","indhdperca","indmd",.)

local clean=subinstr("`clean'","indmwijperca","indwiej",.)
local clean=subinstr("`clean'","indfwijperca","indwifj",.)
local clean=subinstr("`clean'","indhwijperca","indwimj",.)
local clean=subinstr("`clean'","indmwnjperca","indwnej",.)
local clean=subinstr("`clean'","indfwnjperca","indwnfj",.)
local clean=subinstr("`clean'","indhwnjperca","indwnmj",.)
local clean=subinstr("`clean'","indmwgjperca","indwgej",.)
local clean=subinstr("`clean'","indfwgjperca","indwgfj",.)
local clean=subinstr("`clean'","indhwgjperca","indwgmj",.)
local clean=subinstr("`clean'","indmjperca","indej",.)
local clean=subinstr("`clean'","indfjperca","indfj",.)
local clean=subinstr("`clean'","indhjperca","indmj",.)

local clean=subinstr("`clean'","indmwikperca","indwiek",.)
local clean=subinstr("`clean'","indfwikperca","indwifk",.)
local clean=subinstr("`clean'","indhwikperca","indwimk",.)
local clean=subinstr("`clean'","indmwnkperca","indwnek",.)
local clean=subinstr("`clean'","indfwnkperca","indwnfk",.)
local clean=subinstr("`clean'","indhwnkperca","indwnmk",.)
local clean=subinstr("`clean'","indmwgkperca","indwgek",.)
local clean=subinstr("`clean'","indfwgkperca","indwgfk",.)
local clean=subinstr("`clean'","indhwgkperca","indwgmk",.)
local clean=subinstr("`clean'","indmkperca","indek",.)
local clean=subinstr("`clean'","indfkperca","indfk",.)
local clean=subinstr("`clean'","indhkperca","indmk",.)

local clean=subinstr("`clean'","indmwgschl","indwgs",.)
local clean=subinstr("`clean'","indmschl","inds",.)
local clean=subinstr("`clean'","migadj","m",.)
local clean=subinstr("`clean'","madj","m",.)
local clean=subinstr("`clean'","nonmigrant","nzig",.)
local clean=subinstr("`clean'","indmsch","indms",.)
local clean=subinstr("`clean'","indmwg5e","indmew",.)
local clean=subinstr("`clean'","indmwg","indmw",.)
local clean=subinstr("`clean'","indmrur","indmr",.)
local clean=subinstr("`clean'","indmmig","indmm",.)
local clean=subinstr("`clean'","indmsbin","indmb",.)
local clean=subinstr("`clean'","norpur","p",.)
local clean=subinstr("`clean'","nor","n",.)
local clean=subinstr("`clean'","inf","i",.)
local clean=subinstr("`clean'","exppw","xxppw",.)
local clean=subinstr("`clean'","expmpw","xxpmpw",.)
local clean=subinstr("`clean'","exp","e",.)
local clean=subinstr("`clean'","xxppw","exppw",.)
local clean=subinstr("`clean'","xxpmpw","expmpw",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","zig","mig",.)
local clean=subinstr("`clean'","npur","p",.)

local clean=subinstr("`clean'","sch","sc",.)
local clean=subinstr("`clean'","wage","wg",.)
local clean=subinstr("`clean'","all","a",.)
local clean=subinstr("`clean'","bin","b",.)
*local clean=subinstr("`clean'","ind","",.)
local clean=subinstr("`clean'","ageold","ao",.)
local clean=subinstr("`clean'","dif","df",.)
local clean=subinstr("`clean'","rat","rt",.)
local clean=subinstr("`clean'","df20","df2",.)
local clean=subinstr("`clean'","rt20","rt2",.)
local clean=subinstr("`clean'","df90","df9",.)
local clean=subinstr("`clean'","rt90","rt9",.)

if length("`clean'")>13 {
local clean=subinstr("`clean'","ddf","dd",.)
}

if length("`clean'")>13 {

local a1=substr("`clean'",4,1)
local a2=substr("`clean'",7,1)
local abbrev "`a1'`a2'"
local ends=substr("`clean'",-8,.)
}
else {
local abbrev=substr("`clean'",4,.)
local ends=""
}
noi di "`thing'`abbrev'`ends'_"
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




*budget gets transition probabilities. should move somewhere more sensible

cap {
sort muncenso
merge muncenso using "${dir}Skill_Wage_by_Mun_industry_wide.dta", _merge(indschmerge) keep(muncenso `listskillwagem1' `listskillwagem2' `listskillwagem3' `listskillwagem4')
drop indschmerge

cap mvencode `listskillwagem1' `listskillwagem2' `listskillwagem3' `listskillwagem4' , mv(0) override
}



cap {
sort muncenso
merge muncenso using "${dir}Variance_by_industry_mun_wide.dta", _merge(_merge9999)  keep(muncenso `listvar') 
drop _merge9999

cap mvencode `listvar', mv(0) override

sort muncenso
merge muncenso using "${dir}Transitionp_by_industry_mun_wide.dta", _merge(_merge9999) keep(muncenso `listtrans') 
drop _merge9999

cap mvencode `listtrans' , mv(0) override
}


cap {
sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles2000_by_Mun_industry_wide_nowage.dta", _merge(_merge9999)  keep(muncenso `listskillcat120' `listskillcat220' `listskillcat320' `listskillcat420') 
drop _merge9999
}


cap {
sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles2000_by_Mun_industry_widemale_nowage.dta", _merge(_merge9999)  keep(muncenso `listskillcatm120' `listskillcatm220' `listskillcatm320'  `listskillcatm420') 
drop _merge9999



sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles2000_by_Mun_industry_widefem_nowage.dta", _merge(_merge9999)  keep(muncenso `listskillcatf120' `listskillcatf220' `listskillcatf320'  `listskillcatf420') 
drop _merge9999

}

cap {

sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_wide_nowage.dta", _merge(_merge9999)  keep(muncenso `listskillcat190' `listskillcat290' `listskillcat390' `listskillcat490') 
drop _merge9999



sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_widefem_nowage.dta", _merge(_merge9999)  keep(muncenso `listskillcatf190') 
drop _merge9999





sort muncenso
merge muncenso using "${workdir}Skill_Wage_Cohort_percentiles1990_by_Mun_industry_widemale_nowage.dta", _merge(_merge9999)  keep(muncenso `listskillcatm190') 
drop _merge9999


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
}

cap {
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
}
cap {
sort year
merge year using "${dir}Nicita_ExportsPWOnly_wide.dta", _merge(_merge9999) keep(year `listnicexppw') 
drop _merge9999
}




drop marker




*******************
*this bit depends on codes I want to go to at the end

foreach thing in $listfirm  {
foreach cut in 00 50 {
cap gen `thing'`cut'11=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	
cap gen `thing'`cut'12=`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'13=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+	`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'18=`thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'314	+	`thing'`cut'315	+	`thing'`cut'321	+	`thing'`cut'322	+	`thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+	`thing'`cut'331	+	`thing'`cut'332	+	`thing'`cut'333	+	`thing'`cut'335	+	`thing'`cut'336	+	`thing'`cut'337	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	
cap gen `thing'`cut'14=   `thing'`cut'310    +   `thing'`cut'326    +   `thing'`cut'325    +    `thing'`cut'311    +   `thing'`cut'321    +   `thing'`cut'322    +   `thing'`cut'324    +   `thing'`cut'330    +   `thing'`cut'323 
cap gen `thing'`cut'19=   `thing'`cut'335    +   `thing'`cut'332    +   `thing'`cut'333   +   `thing'`cut'331 +   `thing'`cut'337 +    `thing'`cut'315        +   `thing'`cut'336    +   `thing'`cut'314       +   `thing'`cut'312   

cap gen `thing'`cut'26=  `thing'`cut'314 + `thing'`cut'315 + `thing'`cut'336    +   `thing'`cut'332    +   `thing'`cut'333   +   `thing'`cut'331 +   `thing'`cut'337 +   `thing'`cut'335

cap gen `thing'`cut'27=`thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	+ `thing'`cut'310	+	`thing'`cut'311	+	`thing'`cut'312	+	`thing'`cut'321	+	`thing'`cut'322	+ `thing'`cut'323	+	`thing'`cut'324	+	`thing'`cut'325	+	`thing'`cut'326	+	`thing'`cut'330	+ 	`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	


cap gen `thing'`cut'24=`thing'`cut'430	+	`thing'`cut'433	+	`thing'`cut'465	+	`thing'`cut'467	+	`thing'`cut'469	+	`thing'`cut'480	+	`thing'`cut'483	+	`thing'`cut'487	+	`thing'`cut'490	+	`thing'`cut'511	+	`thing'`cut'520	+	`thing'`cut'530	+	`thing'`cut'540	+	`thing'`cut'562	+	`thing'`cut'610	+	`thing'`cut'620	+	`thing'`cut'710	+	`thing'`cut'720	+	`thing'`cut'721	+	`thing'`cut'810	+	`thing'`cut'815	+	`thing'`cut'939	+ `thing'`cut'110	+	`thing'`cut'112	+	`thing'`cut'210	+	`thing'`cut'211	+	`thing'`cut'220	+	`thing'`cut'230	+	`thing'`cut'239	

}
}



local listhcode ""

xtset muncenso year



noi di "Here: `listnicexpcreate'"


cap drop total* 
cap drop prop*



foreach interact in `listinteract' {
foreach thing in $listfirm  {

local clean=subinstr("`interact'","_","",.)


if regexm("`clean'","ind.w.*cat.*")==1 {
local clean=subinstr("`clean'","cat","c",.)
}

local clean=subinstr("`clean'","indmwischl","indwis",.)
local clean=subinstr("`clean'","indmwnschl","indwns",.)


local clean=subinstr("`clean'","indmwiperca","indwieo",.)
local clean=subinstr("`clean'","indfwiperca","indwifo",.)
local clean=subinstr("`clean'","indhwiperca","indwimo",.)
local clean=subinstr("`clean'","indmwnperca","indwneo",.)
local clean=subinstr("`clean'","indfwnperca","indwnfo",.)
local clean=subinstr("`clean'","indhwnperca","indwnmo",.)
local clean=subinstr("`clean'","indmwgperca","indwgeo",.)
local clean=subinstr("`clean'","indfwgperca","indwgfo",.)
local clean=subinstr("`clean'","indhwgperca","indwgmo",.)
local clean=subinstr("`clean'","indmperca","indeo",.)
local clean=subinstr("`clean'","indfperca","indfo",.)
local clean=subinstr("`clean'","indhperca","indmo",.)


local clean=subinstr("`clean'","indmwiaperca","indwiea",.)
local clean=subinstr("`clean'","indfwiaperca","indwifa",.)
local clean=subinstr("`clean'","indhwiaperca","indwima",.)
local clean=subinstr("`clean'","indmwnaperca","indwnea",.)
local clean=subinstr("`clean'","indfwnaperca","indwnfa",.)
local clean=subinstr("`clean'","indhwnaperca","indwnma",.)
local clean=subinstr("`clean'","indmwgaperca","indwgea",.)
local clean=subinstr("`clean'","indfwgaperca","indwgfa",.)
local clean=subinstr("`clean'","indhwgaperca","indwgma",.)
local clean=subinstr("`clean'","indmaperca","indea",.)
local clean=subinstr("`clean'","indfaperca","indfa",.)
local clean=subinstr("`clean'","indhaperca","indma",.)

local clean=subinstr("`clean'","indmwicperca","indwiec",.)
local clean=subinstr("`clean'","indfwicperca","indwifc",.)
local clean=subinstr("`clean'","indhwicperca","indwimc",.)
local clean=subinstr("`clean'","indmwncperca","indwnec",.)
local clean=subinstr("`clean'","indfwncperca","indwnfc",.)
local clean=subinstr("`clean'","indhwncperca","indwnmc",.)
local clean=subinstr("`clean'","indmwgcperca","indwgec",.)
local clean=subinstr("`clean'","indfwgcperca","indwgfc",.)
local clean=subinstr("`clean'","indhwgcperca","indwgmc",.)
local clean=subinstr("`clean'","indmcperca","indec",.)
local clean=subinstr("`clean'","indfcperca","indfc",.)
local clean=subinstr("`clean'","indhcperca","indmc",.)


local clean=subinstr("`clean'","indmwidperca","indwied",.)
local clean=subinstr("`clean'","indfwidperca","indwifd",.)
local clean=subinstr("`clean'","indhwidperca","indwimd",.)
local clean=subinstr("`clean'","indmwndperca","indwned",.)
local clean=subinstr("`clean'","indfwndperca","indwnfd",.)
local clean=subinstr("`clean'","indhwndperca","indwnmd",.)
local clean=subinstr("`clean'","indmwgdperca","indwged",.)
local clean=subinstr("`clean'","indfwgdperca","indwgfd",.)
local clean=subinstr("`clean'","indhwgdperca","indwgmd",.)
local clean=subinstr("`clean'","indmdperca","inded",.)
local clean=subinstr("`clean'","indfdperca","indfd",.)
local clean=subinstr("`clean'","indhdperca","indmd",.)

local clean=subinstr("`clean'","indmwijperca","indwiej",.)
local clean=subinstr("`clean'","indfwijperca","indwifj",.)
local clean=subinstr("`clean'","indhwijperca","indwimj",.)
local clean=subinstr("`clean'","indmwnjperca","indwnej",.)
local clean=subinstr("`clean'","indfwnjperca","indwnfj",.)
local clean=subinstr("`clean'","indhwnjperca","indwnmj",.)
local clean=subinstr("`clean'","indmwgjperca","indwgej",.)
local clean=subinstr("`clean'","indfwgjperca","indwgfj",.)
local clean=subinstr("`clean'","indhwgjperca","indwgmj",.)
local clean=subinstr("`clean'","indmjperca","indej",.)
local clean=subinstr("`clean'","indfjperca","indfj",.)
local clean=subinstr("`clean'","indhjperca","indmj",.)

local clean=subinstr("`clean'","indmwikperca","indwiek",.)
local clean=subinstr("`clean'","indfwikperca","indwifk",.)
local clean=subinstr("`clean'","indhwikperca","indwimk",.)
local clean=subinstr("`clean'","indmwnkperca","indwnek",.)
local clean=subinstr("`clean'","indfwnkperca","indwnfk",.)
local clean=subinstr("`clean'","indhwnkperca","indwnmk",.)
local clean=subinstr("`clean'","indmwgkperca","indwgek",.)
local clean=subinstr("`clean'","indfwgkperca","indwgfk",.)
local clean=subinstr("`clean'","indhwgkperca","indwgmk",.)
local clean=subinstr("`clean'","indmkperca","indek",.)
local clean=subinstr("`clean'","indfkperca","indfk",.)
local clean=subinstr("`clean'","indhkperca","indmk",.)

local clean=subinstr("`clean'","indmwgschl","indwgs",.)
local clean=subinstr("`clean'","indmschl","inds",.)
local clean=subinstr("`clean'","migadj","m",.)
local clean=subinstr("`clean'","madj","m",.)
local clean=subinstr("`clean'","nonmigrant","nzig",.)
local clean=subinstr("`clean'","indmsch","indms",.)
local clean=subinstr("`clean'","indmwg5e","indmew",.)
local clean=subinstr("`clean'","indmwg","indmw",.)
local clean=subinstr("`clean'","indmrur","indmr",.)
local clean=subinstr("`clean'","indmmig","indmm",.)
local clean=subinstr("`clean'","indmsbin","indmb",.)
local clean=subinstr("`clean'","norpur","p",.)
local clean=subinstr("`clean'","nor","n",.)
local clean=subinstr("`clean'","inf","i",.)
local clean=subinstr("`clean'","exppw","xxppw",.)
local clean=subinstr("`clean'","expmpw","xxpmpw",.)
local clean=subinstr("`clean'","exp","e",.)
local clean=subinstr("`clean'","xxppw","exppw",.)
local clean=subinstr("`clean'","xxpmpw","expmpw",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","zig","mig",.)
local clean=subinstr("`clean'","npur","p",.)

local clean=subinstr("`clean'","sch","sc",.)
local clean=subinstr("`clean'","wage","wg",.)
local clean=subinstr("`clean'","all","a",.)
local clean=subinstr("`clean'","bin","b",.)
*local clean=subinstr("`clean'","ind","",.)
local clean=subinstr("`clean'","ageold","ao",.)
local clean=subinstr("`clean'","dif","df",.)
local clean=subinstr("`clean'","rat","rt",.)
local clean=subinstr("`clean'","df20","df2",.)
local clean=subinstr("`clean'","rt20","rt2",.)
local clean=subinstr("`clean'","df90","df9",.)
local clean=subinstr("`clean'","rt90","rt9",.)

if length("`clean'")>13 {
local clean=subinstr("`clean'","ddf","dd",.)
}

if length("`clean'")>13 {

local a1=substr("`clean'",4,1)
local a2=substr("`clean'",7,1)
local abbrev "`a1'`a2'"
local ends=substr("`clean'",-8,.)
}
else {
local abbrev=substr("`clean'",4,.)
local ends=""
}

noi di "`thing'`abbrev'`ends'_"

local listhcode "`listhcode' `thing'`abbrev'`ends'_"

noi di "`interact', `thing'`abbrev'`ends'_`cut'11" 



*******************
*this bit depends on codes I want to go to at the end


foreach cut in 00 50 {


*Problem: 1) why dont pa3cat and wnpa3cat have the same missing cells- if so then could just set all missing interacts to zero and jobs would drop out.
*really want to have same sample in the non interatced and interacted if want to run in same regression. this is now done with teh z variables


*might be right up against length constarint... the X rename wont work

*for wage cat measures I must interact the number of jobs with the wage ratio in that job. Note wage measures must come before prop measures as prop is deleted after run thourgh
if regexm("`interact'","ind.w.*cat.*")==1 {
local propinteract=regexr("`interact'","w.","")
local propinteract=regexr("`propinteract'","migpur","madjpur")
local propinteract=regexr("`propinteract'","mig","migadj")

	if regexm("`interact'","ind.w.*cat.*pur.*")==1 {
	local wageabbrev=regexr("`abbrev'","w","z")
	forval n=100/999 {
	*this is for norpur measures where there will be some missings
	cap gen X`interact'`n'=`interact'`n'
	cap gen X`propinteract'`n'=`propinteract'`n'
	cap replace `propinteract'`n'=0 if  `interact'`n'==.
	cap replace `interact'`n'=0 if  `interact'`n'==.
	}
	*now i create wage like variables which are cat jobs  that are sums of only the non missing observations of the cat proportions
	cap gen `thing'`wageabbrev'`ends'_`cut'11=`thing'`cut'310*`propinteract'310	+	`thing'`cut'311*`propinteract'311	+	`thing'`cut'312*`propinteract'312	+	`thing'`cut'314*`propinteract'314	+	`thing'`cut'315*`propinteract'315	+	`thing'`cut'321*`propinteract'321	+	`thing'`cut'322*`propinteract'322	+	`thing'`cut'323*`propinteract'323	+	`thing'`cut'324*`propinteract'324	+	`thing'`cut'325*`propinteract'325	+	`thing'`cut'326*`propinteract'326	+	`thing'`cut'330*`propinteract'330	+	`thing'`cut'331*`propinteract'331	+	`thing'`cut'332*`propinteract'332	+	`thing'`cut'333*`propinteract'333	+	`thing'`cut'335*`propinteract'335	+	`thing'`cut'336*`propinteract'336	+	`thing'`cut'337*`propinteract'337	
	cap gen `thing'`wageabbrev'`ends'_`cut'14=   `thing'`cut'310*`propinteract'310    +   `thing'`cut'326*`propinteract'326    +   `thing'`cut'325*`propinteract'325    +    `thing'`cut'311*`propinteract'311    +   `thing'`cut'321*`propinteract'321    +   `thing'`cut'322*`propinteract'322    +   `thing'`cut'324*`propinteract'324    +   `thing'`cut'330*`propinteract'330    +   `thing'`cut'323*`propinteract'323 
	cap gen `thing'`wageabbrev'`ends'_`cut'19=   `thing'`cut'335*`propinteract'335    +   `thing'`cut'332*`propinteract'332    +   `thing'`cut'333*`propinteract'333   +   `thing'`cut'331*`propinteract'331 +   `thing'`cut'337*`propinteract'337 + `thing'`cut'315*`propinteract'315        +   `thing'`cut'336*`propinteract'336    +   `thing'`cut'314*`propinteract'314       +   `thing'`cut'312*`propinteract'312   
	}

cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'310*`interact'310*`propinteract'310	+	`thing'`cut'311*`interact'311*`propinteract'311	+	`thing'`cut'312*`interact'312*`propinteract'312	+	`thing'`cut'314*`interact'314*`propinteract'314	+	`thing'`cut'315*`interact'315*`propinteract'315	+	`thing'`cut'321*`interact'321*`propinteract'321	+	`thing'`cut'322*`interact'322*`propinteract'322	+	`thing'`cut'323*`interact'323*`propinteract'323	+	`thing'`cut'324*`interact'324*`propinteract'324	+	`thing'`cut'325*`interact'325*`propinteract'325	+	`thing'`cut'326*`interact'326*`propinteract'326	+	`thing'`cut'330*`interact'330*`propinteract'330	+	`thing'`cut'331*`interact'331*`propinteract'331	+	`thing'`cut'332*`interact'332*`propinteract'332	+	`thing'`cut'333*`interact'333*`propinteract'333	+	`thing'`cut'335*`interact'335*`propinteract'335	+	`thing'`cut'336*`interact'336*`propinteract'336	+	`thing'`cut'337*`interact'337*`propinteract'337	
cap gen `thing'`abbrev'`ends'_`cut'14=   `thing'`cut'310*`interact'310*`propinteract'310    +   `thing'`cut'326*`interact'326*`propinteract'326    +   `thing'`cut'325*`interact'325*`propinteract'325    +    `thing'`cut'311*`interact'311*`propinteract'311    +   `thing'`cut'321*`interact'321*`propinteract'321    +   `thing'`cut'322*`interact'322*`propinteract'322    +   `thing'`cut'324*`interact'324*`propinteract'324    +   `thing'`cut'330*`interact'330*`propinteract'330    +   `thing'`cut'323*`interact'323*`propinteract'323 
cap gen `thing'`abbrev'`ends'_`cut'19=   `thing'`cut'335*`interact'335*`propinteract'335    +   `thing'`cut'332*`interact'332*`propinteract'332    +   `thing'`cut'333*`interact'333*`propinteract'333   +   `thing'`cut'331*`interact'331*`propinteract'331 +   `thing'`cut'337*`interact'337*`propinteract'337 + `thing'`cut'315*`interact'315*`propinteract'315        +   `thing'`cut'336*`interact'336*`propinteract'336    +   `thing'`cut'314*`interact'314*`propinteract'314       +   `thing'`cut'312*`interact'312*`propinteract'312   


	if regexm("`interact'","ind.w.*cat.*pur.*")==1 {
	forval n=100/999 {
	cap drop `interact'`n' `propinteract'`n'
	cap rename X`interact'`n' `interact'`n'
	cap rename X`propinteract'`n' `propinteract'`n'
	}
	}
}

else {
	if regexm("`interact'","pur")==1 {
	forval n=100/999 {
	cap gen X`interact'`n'=`interact'`n'
	cap replace `interact'`n'=0 if `interact'`n'==.
	}
	}

	cap gen `thing'`abbrev'`ends'_`cut'11=`thing'`cut'310*`interact'310	+	`thing'`cut'311*`interact'311	+	`thing'`cut'312*`interact'312	+	`thing'`cut'314*`interact'314	+	`thing'`cut'315*`interact'315	+	`thing'`cut'321*`interact'321	+	`thing'`cut'322*`interact'322	+	`thing'`cut'323*`interact'323	+	`thing'`cut'324*`interact'324	+	`thing'`cut'325*`interact'325	+	`thing'`cut'326*`interact'326	+	`thing'`cut'330*`interact'330	+	`thing'`cut'331*`interact'331	+	`thing'`cut'332*`interact'332	+	`thing'`cut'333*`interact'333	+	`thing'`cut'335*`interact'335	+	`thing'`cut'336*`interact'336	+	`thing'`cut'337*`interact'337	

	cap gen `thing'`abbrev'`ends'_`cut'14=   `thing'`cut'310*`interact'310    +   `thing'`cut'326*`interact'326    +   `thing'`cut'325*`interact'325    +    `thing'`cut'311*`interact'311    +   `thing'`cut'321*`interact'321    +   `thing'`cut'322*`interact'322    +   `thing'`cut'324*`interact'324    +   `thing'`cut'330*`interact'330    +   `thing'`cut'323*`interact'323 
	cap gen `thing'`abbrev'`ends'_`cut'19=   `thing'`cut'335*`interact'335    +   `thing'`cut'332*`interact'332    +   `thing'`cut'333*`interact'333   +   `thing'`cut'331*`interact'331 +   `thing'`cut'337*`interact'337 + `thing'`cut'315*`interact'315        +   `thing'`cut'336*`interact'336    +   `thing'`cut'314*`interact'314       +   `thing'`cut'312*`interact'312   

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
drop `interact'???

}

foreach cut in 00 50 {
drop *`cut'???
}

*this drops all the non matching sex specific skill shocks
cap drop *emp*f??cat*
cap drop *emp*m??cat*
cap drop *male*f??cat*
cap drop *fem*m??cat*
cap drop *male*e??cat*
cap drop *fem*e??cat*
cap drop *emp*f?cat*
cap drop *emp*m?cat*
cap drop *male*f?cat*
cap drop *fem*m?cat*
cap drop *male*e?cat*
cap drop *fem*e?cat*



cap drop ind*
*drop  ?exp* exp* ??exp*

cap {
foreach varx of varlist *emp*e??cat* {


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









