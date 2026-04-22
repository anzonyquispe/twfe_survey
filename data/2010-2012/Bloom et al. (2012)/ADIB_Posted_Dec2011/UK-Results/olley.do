***************************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
***************************
* THIS FILE GENERATES THE FOLLOWING REGRESSION TABLES:
* TABLE C1 
***************************
clear
set mem 256m
set more 1
version 9.2
u adib_data, clear
keep if IT1==1

* All variables are in levels (not in per employee terms)
replace ln_khard=ln(khard)
replace ln4=ln(go)
replace ln_TM=ln(totpurch)
replace ln_K_not=ln(rcapstk95-khard)
replace ln_K=ln(rcapstk95)
replace int_us_mu=du_usa_mu*ln_khard
replace int_oth_mu=du_oth_mu*ln_khard

keep ruref  rig* _Imanuf*  _Imanuf_1-_ImanXage_1_24 manuf_age_t ln_I* du_dom year single manuf IT1  sic* ln4 ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu Dgroup Hd* se-wales  age* mode* myc* ncapex hardinv ln_K emp ln_go_agg
keep if ln_khard~=.
drop if ln_TM==.
drop if ln_I_non_ict==. | ln_I_ict==.

cap drop dyear
so ruref year
qui by ruref:ge dyear=year-year[_n-1]
egen mdyr=max(dyear),by(ruref)
replace mdyr=-99 if dyear==.
tab dyear
cap drop dyear
so ruref year
qui by ruref:ge dyear=year-year[_n-1]
tab dyear
so ruref year
ge one=1
egen noj=sum(one),by(ruref)
qui by ruref:ge A_age1=age[_n-1]
ge  new=(A_age1~=. & noj>2)



* Generate deviations from sic3 year
foreach var of varlist ln_go_agg ln_K  ln4 ln_TM ln_K_not ln_N ln_khard  single Hdummy_bsci Hdummy_qice Hdummy_far du_usa_mu du_oth_mu rig1-rig10 age age_t  _Imanuf_1-_ImanXage_1_24 manuf_age_t int_us_mu int_oth_mu  se-wales   ln_I_ict ln_I_non_ict  { 
cap drop m_`var' 
cap drop A_`var'
ge pro_`var'=`var' if new==1
bys myc: egen m_`var'=mean(`var') 
ge A_`var'=`var'-m_`var' 
drop m_`var' pro_`var'
label var A_`var' "`var' dev"
}

replace year=year-10
egen ind2=group(sic2)
egen ind3=group(sic3)
egen ind4=group(sic4)

cap drop one noj
ge one=1
egen noj=sum(one),by(ruref)
so noj ruref year
order ruref year ind*  ln4 ln_TM ln_K_not ln_N ln_khard  single Hdummy_bsci Hdummy_qice Hdummy_far du_usa_mu du_oth_mu rig1-rig10 age age_t  _Imanuf_1-_ImanXage_1_24 manuf_age_t int_us_mu int_oth_mu  se-wales   ln_I_ict ln_I_non_ict  
sa "op_march2010",replace

u "op_march2010", clear
ge a=1
ge b=(IT1==1)
ge c=(IT1==0)
ge d=(du_usa_mu==1)
ge e=(du_oth_mu==1)
ge f=(du_dom==1)

ge g=(b==1&d==1)
ge h=(b==1&e==1)
ge l=(b==1&f==1)

ge m=(c==1&d==1)
ge n=(c==1&e==1)
ge o=(c==1&f==1)
save "op_reg_march2010", replace


* RUN IT JUST FOR IT INTENSIVE WITH DIFFERENT REPLICATIONS
cap log c
log using "oplog_oct2010", text replace


foreach var of varlist g-l{
u "op_reg_march2010", clear
keep if `var'==1

egen i=group(ruref)
*ge i=ruref
ge t=year

sort i t
tsset i  t
qui by i: g t0=t[1]
qui by i: g t1=t[_N]

sort t

table t, c(n i)
tab t,ge(D)
mac def DT " D2 D3 D4 "

*************************
* construct variables 

xi i.t
sort i t

g logk=A_ln_K_not
g logy=A_ln4
g time=t-1989
g time2=time^2
g time3=time^3
g time4=time^4

ge logl=A_ln_N 
g llogl=L.logl
g l2logl=L2.logl
global if=" "
	
*	STAGE 1:
global s1y=	"A_ln4 "		/* 	dependent variable stage 1	(value added)	*/
global s1x	=	"A_ln_N A_ln_TM   A_ln_go_agg "	/* 	variables of interest for stage 1 (other than series terms)*/
global s1x3	=	"  $DT  "	      /* 	control variables for stage 1 (other than series terms)*/
/*check lag on k - kt or kt-1?*/
global s1var=  "A_ln_K_not A_ln_I_non_ict  A_ln_khard A_ln_I_ict  "	/*	varlist for series expansion for stage 1*/
global s1o=	4  	/*	order of series expansion for stage 1*/

*	STAGE 2:
global s2y=	"x"			/*	dependent variable for stage 2 probit regressions*/

global s2x=	"	time "			/*	independen variables other than series terms (e.g. time dummies)*/
global s2var= "logk logi time "	/*	valist for series expansion for stage 2*/
global s2o=	3			/*	order of series expansion for stage 2*/
global opselect = 0             /*=0 if no selection*/

*	STAGE 3:
global	s3x=	" A_ln_K_not A_ln_khard  "		/*	independent variable for stage 3 */
global	s3z=	" A_age A_age_t A_du_usa_mu A_du_oth_mu $DT"  /*	independent variable for stage 3 */
*global	s3z=	"   A_age A_age_t  A_Dgroup  $DT"  /*	independent variable for stage 3 */

*global	s3z=	"  time "        /*	independent variable for stage 3 */
global	s3var=" "		/*	independent variable for stage 3 */
global	s3var=" "		/*	independent variable for stage 3 */
global	s3o=	4                /*	order of series expansion for phi and phat inside the NLLS of stage 3*/
global 	s3grid="0(.05)1"
global 	s3delta="1e-4 1e-7"

* 	OUTPUT:
global 	opsb="b"				/*	name of matrix to save coefficients*/
global omega="omega"	                /*	variable to save productivity estimates*/

***************************************
* do Olley-Pakes --- 3 stage procedure

qui do "ops-h1.do"

ops

so i t
qui by i:ge domega=omega-omega[_n-1]


* HERE LOOP FOR REPLICATIONS
foreach g in  200  {
display "SECTOR IS `var', `g' REPLICATIONS"
set seed 1234
bs "ops" _b,cluster(i) reps(`g') dots
}
ta year, ge(yy)
areg A_ln4 A_ln_TM A_ln_K_not A_ln_N A_ln_khard A_ln_go_agg  A_du_usa_mu A_du_oth_mu yy* if e(sample),abs(ruref) cluster (ruref)

}
cap log c
stop

