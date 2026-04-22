
decode techarea, gen(areaName)
replace areaName = "ops" if areaName == "o&m"

**** Local Macros to Hold Control Variables List
local controls lsize lcmsgs lwgidnow aut2 aut3
local st_controls st_lsize st_lcmsgs st_lwgidnow st_aut2 st_aut3 

**** Gen Interaction Terms
*gen stb_oth = stbafl1yr*othDum
*gen st_stboth = stb_oth * strfc

gen stb_org = stbafl1yr*orgDum
gen stb_edu = stbafl1yr*eduDum
gen st_stborg = stb_org * strfc
gen st_stbedu = stb_edu * strfc

g nsEffect = stbafl1yr
foreach area in app int ops rtg sec tsv {
	qui gen stX`area' = stbafl1yr * strfc * (areaName == "`area'")
	qui gen nsX`area' = stbafl1yr * (areaName == "`area'")
}

g yrGrp = 1993 + 2 * floor((pubCohort - 1993)/2)
forval yr = 1993(2)2001 {
	gen stStb_`yr' = stbafl1yr * strfc * (yrGrp == `yr')
	gen nsStb_`yr' = stbafl1yr * (yrGrp == `yr')
}

log using tables/olsInteractions.log, replace
**************************************
*      STB-DotOrg Interactions  	    *
**************************************
*qui xi: reg ttlDur st_stbafl1yr st_othDum st_stboth `st_controls' i.pubCohort i.techarea if ((strfc) & cSample==1), cluster(wg)
qui xi: reg ttlDur st_stbafl1yr st_orgDum st_stborg st_eduDum st_stbedu `st_controls' i.pubCohort i.techarea if ((strfc) & cSample==1), cluster(wg)
est store col1 

*qui xi: reg ttlDur st_stbafl1yr st_othDum st_stboth stbafl1yr othDum strfc stb_oth `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample==1), cluster(wg)
*test st_stboth
*test stb_oth
qui xi: reg ttlDur st_stbafl1yr st_orgDum st_stborg st_eduDum st_stbedu stbafl1yr orgDum eduDum strfc stb_org stb_edu `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample==1), cluster(wg)
testparm stb_org stb_edu
est store col2

tab strfc if e(sample)

*qui xi: xtreg ttlDur st_stbafl1yr st_othDum st_stboth stbafl1yr othDum strfc stb_oth `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample==1), fe i(wg) r
*qui xi: xtreg ttlDur st_stbafl1yr st_orgDum st_stborg st_eduDum st_stbedu stbafl1yr orgDum eduDum strfc stb_org stb_edu `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample==1), fe i(wg) r
*est store col2FE


**************************************
*      TechArea Interactions  	     *
**************************************
qui xi: reg ttlDur stX* st_othDum `st_controls' i.pubCohort i.techarea if ((strfc) & cSample), cluster(wg)
est store col3

qui xi: reg ttlDur stX* nsX* othDum st_othDum `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample), cluster(wg)
est store col4 
testparm nsX*
*foreach area in app ops rtg sec tsv {
*	test stXint = stX`area'
*}
tab strfc if e(sample)

*qui xi: xtreg ttlDur stX* nsX* `controls' `st_controls' i.pubCohort*strfc i.techarea*strfc if ((strfc|nsrfc) & cSample), fe i(wg) r
*est store col4FE
*tab strfc if e(sample)


************************************
*      Cohort Interactions         *
************************************
qui xi: reg ttlDur stStb_* othDum  `controls' i.pubCohort i.techarea if (strfc & cSample), cluster(wg)
est store col5
tab strfc if e(sample)

* Models with Time-Varying Baseline
qui xi: reg ttlDur stStb_* nsStb_* othDum st_othDum `controls' `st_controls' i.pubCohort*strfc i.techarea if ((strfc|nsrfc) & cSample), cluster(wg)
est store col6
testparm nsStb_*
tab strfc if e(sample)

estout _all, cells(b(fmt(1)) se(par fmt(1) star)) stats(N r2 df_m N_g, fmt(0 %8.2f 0 0)) drop(strfc st_stbafl1yr stbafl1yr st_orgDum st_eduDum orgDum eduDum othDum st_othDum stb_* _I* _cons `controls' `st_controls' nsX* nsStb_*) order(st_stborg st_stbedu stXapp stXtsv stXint stXrtg stXsec stXops stStb_1993 stStb_1995 stStb_1997 stStb_1999 stStb_2001) style(tex) starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)

drop stX* nsX* stStb_* nsStb_* stb_* st_stb*

log close

