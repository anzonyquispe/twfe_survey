***************************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
***************************
* THIS FILE GENERATES THE FOLLOWING REGRESSION TABLES:
* TABLE C1 
***************************

version 9.2
cd "T:\LSE\Raffaella_Sadun\ADIB_AER
set more 1
global F9 do "t:\ceriba\stata_files\copymarked.do";
global F10 do "H:\_markedF10.do";
adopath +t:\ceriba\stata_files\ado
adopath +t:\ceriba\stata_files\ado\stb\
adopath +t:\ceriba\stata_files\projects
adopath + x:\code\stat-transfer-setup\ 
adopath +X:\code\ado\xtabond
adopath +X:\code\ado\
adopath +T:\Ceriba\climatelevy\do


clear
cap log c
set mem 500m
mata: mata set matafavor speed

u adib_data, clear

* All variables are in levels (not in per employee terms)
replace ln_khard=ln(khard)
replace ln4=ln(go)
replace ln_TM=ln(totpurch)
replace ln_K_not=ln(rcapstk95-khard)
replace ln_K=ln(rcapstk95)
replace int_us_mu=du_usa_mu*ln_khard
replace int_oth_mu=du_oth_mu*ln_khard

keep ruref year single manuf IT1  sic* sic3 sic4 sic2 rig* ln4 ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu Dgroup Hd* se-wales  age* mode* myc* ncapex hardinv 
keep if ln_khard~=.
drop if ln_TM==.

* Drop firms observed only once
bys ruref: egen g=count(ruref)
ta g
drop if g==1
 
* Keep only plants with consecutive obs 
cap drop dyear
so ruref year
qui by ruref:ge dyear=year-year[_n-1]
tab dyear
bys ruref: egen mdyr=max(dyear)
ta mdy
keep if mdyr==1
drop g
ta year, ge(yy)
bys ruref: egen g=count(ruref)
ta year g

* On subsample with exactly 5 obs
xi: qui reg ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu du_usa_mu du_oth_mu  i.manuf*i.age Hd* yy*
ge sa=e(sample)==1
bys ruref: egen g_new=count(ruref) if sa==1
keep if g_new>4

foreach var in ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu du_usa_mu du_oth_mu {
	ge lag_`var'=l.`var'
}

cap log c
log using reggmm.txt, replace text

#delimit;
xi: xtabond2 ln4 lag_ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu du_usa_mu du_oth_mu i.manuf*i.age  Hd* yy* if g_new>4 & Hdummy_far==0,
gmm(ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu du_usa_mu du_oth_mu, lag(2 5))
iv(yy*  i.manuf*i.age Hd*, eq(level))
h(1)  robust ;
test int_us_mu=int_oth_mu ;
testnl (_b[int_us_mu])/(1 - _b[lag_ln4]) = _b[int_oth_mu]/(1- _b[lag_ln4]) ;


xi: xtabond2 ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu du_usa_mu du_oth_mu lag_ln_TM lag_ln4 i.manuf*i.age  Hd* yy* if g_new>4 & Hdummy_far==0,
gmm(ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu du_usa_mu du_oth_mu, lag(2 5))
iv(yy*  i.manuf*i.age Hd*, eq(level))
h(1) robust ;
test int_us_mu=int_oth_mu;
testnl (_b[int_us_mu])/(1 - _b[lag_ln4]) = _b[int_oth_mu]/(1- _b[lag_ln4]) ;
log c;





