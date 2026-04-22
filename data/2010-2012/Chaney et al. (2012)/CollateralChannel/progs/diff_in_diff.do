clear matrix
clear mata 
clear	
set mem 900m
set mat 800
set more 1
cap log close


/**************************************************************************************************************************************************************/
/********************TO GET THE SAMPLE OF PURCHASERS WE START WITH COMPUSTAT IN 1984, FIRST YEAR WHERE REAL ESTATE INFORMATIONS ARE AVAILABLE******************/
/**************************************************************************************************************************************************************/

***compu_data is a COMPUSTAT extract from 1981 to 2008 with relevant accounting data 
use "../output/compu_data",clear

***generate dummies for years
tab year, gen(yr)

/************************************************************************************************************************************/
/********************************************Generation of the sample of purchasers      ********************************************/
/************************************************************************************************************************************/

***first post treatment observation is when real estate goes from 0 to >0 in current period
sort gvkey year
quietly by gvkey: gen post_treated=1 if RE_total>0&RE_total~=.&RE_total[_n-1]==0&gvkey[_n-1]==gvkey

***Then post treatment is one if previous post_treatment is one and RE_total is still >0
sort gvkey year
forvalues i=1(1)30{
quietly by gvkey: replace post_treated=1 if RE_total>0&RE_total~=.&post_treated[_n-1]==1&gvkey[_n-1]==gvkey&year==year[_n-1]+1
}
***first pre treatment is one when real estate goes from 0 to >0 next period
quietly by gvkey: replace post_treated=0 if RE_total==0&RE_total[_n+1]>0&RE_total[_n+1]~=.&gvkey[_n+1]==gvkey
***then pre treatment is zero when real estate is still 0 and next period pre-treatment is 0
forvalues i=1(1)30{
quietly by gvkey: replace post_treated=0 if RE_total==0&post_treated[_n+1]==0&gvkey[_n+1]==gvkey&year==year[_n+1]-1
}
** a firm is treated if it has some non missing post-treated (ie there is one purchase)
gen treated=1 if post_treated~=.

***the control group is the set of firms which never purchases RE
cap drop temp
egen temp=max(RE_total),by(gvkey)
replace treated=0 if temp==0

****purch is a dummy equal to 1 when a firm purchases RE
sort gvkey year
quietly by gvkey: gen purch=RE_total>0&RE_total~=.&RE_total[_n-1]==0&year==year[_n-1]+1

***PURCH is the number of acquisitions of RE (firm acquires then divest then buys again)
egen PURCH=sum(purch), by(gvkey)
***when firms have multiple purchases we only keep the observations corresponding to the first one, provided the firm
***starts in sample with 0 holdings of RE
gen year_purch=year if purch==1
sort gvkey year
quietly by gvkey: gen year_div=year if RE_total==0&RE_total[_n-1]~=.&RE_total[_n-1]>0&year==year[_n-1]+1
gsort gvkey year_div
by gvkey: gen myear_div2=year_div[2] if year_div[2]~=.
egen myear_purch=min(year_purch),by(gvkey)
egen myear_div=min(year_div),by(gvkey)
keep if PURCH==1|PURCH==0|(PURCH>=2&PURCH~=.&year<myear_div&myear_purch<myear_div&myear_div~=.)


***we only keep purchasers with at least 2 years of data before and after the purchase 
cap drop n1
cap drop n2
egen n1=sum(offprice~=.&cash~=.&qm~=.&inv~=.) if post_treated==1,by(gvkey)
egen n2=sum(offprice~=.&cash~=.&qm~=.&inv~=.) if post_treated==0,by(gvkey)
egen N1=max(n1),by(gvkey)
egen N2=max(n2),by(gvkey)
replace treated=. if treated==1&((N1<2&N1~=.)|(N2<2&N2~=.)|N1==.|N2==.)
replace post_treated=. if treated==.
drop n1 N1 n2 N2


***define the relevant level of clustering 
cap drop id
egen id=group(msacode year)

***define the interactions to test significance between purchasers and non-purchasers
cap drop dum
gen dum=1 if treated==0
replace dum=0 if post_treated==0
forvalues i=1(1)24{
gen dumyr`i'=dum*yr`i'
}

egen ppp=group(gvkey post_treated)
forvalues i=1(1)24{
gen postyr`i'=post_treated*yr`i'
}

log using "../output/reg.log", append

************************************************************************************
***INVESTMENT REGRESSIONS: The case of purchasers 		   ************************
************************************************************************************

xi: areg inv offprice yr* cash qm if treated==0, a(gvkey) cl(id)
estimates store dd1

xi: areg inv offprice yr* cash qm if post_treated==0, a(gvkey) cl(id)
estimates store dd2

xi: areg inv offprice yr* cash qm if post_treated==1, a(gvkey) cl(id)
estimates store dd3

****test of significance between dd1 and dd2
xi: areg inv i.dum*offprice  yr* dumyr* i.dum*cash i.dum*qm, a(gvkey) cl(id)

****test of significance between dd2 and dd3
xi: areg inv i.post_treated*offprice  yr* postyr* i.post_treated*cash i.post_treated*qm if treated==1, a(ppp) cl(id)

xi: areg deltaltdebt offprice yr* cash qm if treated==0, a(gvkey) cl(id)
estimates store dd4
xi: areg deltaltdebt offprice yr* cash qm if post_treated==0, a(gvkey) cl(id)
estimates store dd5
xi: areg deltaltdebt offprice yr* cash qm if post_treated==1, a(gvkey) cl(id)
estimates store dd6

****test of significance between dd4 and dd5
xi: areg deltaltdebt i.dum*offprice  yr* dumyr* i.dum*cash i.dum*qm, a(gvkey) cl(id)

****test of significance between dd2 and dd3
xi: areg deltaltdebt i.post_treated*offprice  yr* postyr* i.post_treated*cash i.post_treated*qm if treated==1, a(ppp) cl(id)

estout dd1 dd2 dd3 dd4 dd5 dd6, cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(offprice cash qm) stats(N r2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)

cap log close



