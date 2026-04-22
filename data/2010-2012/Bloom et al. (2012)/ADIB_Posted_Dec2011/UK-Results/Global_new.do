***************************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
***************************
* THIS DO FILE PREPARES DATA AND GENERATES REGRESSIONS FOR GLOBAL SIZE RESULTS
set more 1
version 9.2 

/*
clear
set mem 1000m
use "H:\Raffaella\ICT\Data\data_oct16", replace
cap drop paradise
gen paradise = (f_own==49| f_own==65|f_own==73|f_own==93|f_own==131|f_own==277|f_own==371|f_own==833)
drop if paradise==1
keep if ln_khard~=. & ln4~=. & ln_TM~=. & ln_K_not~=.
replace manuf=1 if manuf==.
ge single=Dgroup==0
ge D_us=single*du_usa_mu
ge D_oth=single*du_oth_mu
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
keep ruref year du_dom du_usa_mu du_oth_mu single D_us D_oth Hd*  age manuf age_t mode_reg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu myc IT1 new_egrp_ref
*xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1,  cluster (ruref) abs(ruref)
so ruref year
cd "H:\Raffaella\ICT\Data\
save global.dta,replace
keep ruref year
so ruref year
save global0.dta,replace


* Merge with ardict, find true size of establishments
* Register file is created in takoevers
use "H:\Raffaella\ICT\Data\\register", clear
keep ruref year sel_emp egrp_ref
so ruref year
drop if ruref==ruref[_n-1] & year==year[_n-1]
cap drop _merge
merge ruref year using "H:\Raffaella\ICT\Data\global0.dta"
* Find true size of enterprise group
bys egrp_ref year: egen max_m=max(_m)
keep if max_m==3
bys egrp_ref year: egen tot_emp_egrp=sum(sel_emp)
ta _m
keep if _m==3
drop _m
replace tot_emp_egrp =. if tot_emp_egrp ==0
so ruref year
merge ruref year using global
ta _m
* This beacause I want to use it only for domestic uk firms
replace tot_emp_egrp =. if du_dom==0
ge emp=exp(ln_N)
ge ln_tot_emp = ln(tot_emp_egr-emp)
ge int_size  = ln_khard*ln_tot_emp
ge int_size2 = ln_khard*(tot_emp_egr-emp)
so ruref year
save "H:\Raffaella\ICT\Data\global1", replace
*/

cd "T:\ceriba\amadeus\do\raffaella\"
**** from here with global size
*use "T:\ceriba\amadeus\data\dlink_ref2Xyear\global1.dta", clear
use "global1.dta", clear
*mmerge ruref using temp/regs001a, unmatched(master) umatch(dlink_ref2) ukeep(ln_uo_turnover FAMEmerge_id bigfirm_id)
cap drop _m
ren  ruref dlink_ref2
so dlink_ref2
merge dlink_ref2 using ARD2ult_ownUOdata001a
drop if _m==2
gen ln_uo_turnover=ln(uo_turnover)

*********
* Regressions to run
*********
set matsize 4000

local size "ln_uo_turnover"
cap dummygen valid_FAME_id if uo_turnover~=.
cap gen bigfirm_id=valid_FAME_id
*do not know what this does
*replace ln_uo_turnover=. if du_dom~=1 & bigfirm_id~=1
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"

ge size=`size'
ge size_int=ln_khard*size
keep if IT1==1 & size~=.

/*
**** make extra variables
* execute this if divided by l
foreach vvv in ln4 ln_TM ln_K_not  ln_khard int_us_mu int_oth_mu size_int{
  replace `vvv'=`vvv'-ln_N
}
*/

ren dlink ruref

so ruref
compress
sa global_new,replace

cap log c
log using global_new,replace t
u global_new,replace
set matsize 2000
global  control2 "du_usa_mu du_oth_mu single D_us D_oth Hd*  "
xi i.myc i.age*manuf i.age_t*manuf manuf i.mode_reg

**** fixed effects
*NO GLOBAL SIZE
areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu _I* $control2 if IT1==1 & size~=.,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*INCLUDE GLOBAL SIZE
areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size size_int _I* $control2 if IT1==1 & size~=.,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu


**** just industry dummies
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu  $control if IT1==1 & size~=.,  cluster (ruref) abs(myc)
test int_us_mu=int_oth_mu
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size $control if IT1==1 & size~=.,  cluster (ruref) abs(myc)
test int_us_mu=int_oth_mu
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size size_int  $control if IT1==1 & size~=.,  cluster (ruref) abs(myc)
test int_us_mu=int_oth_mu


* To use also domestic
ge size1 = size
replace size1 = tot_emp_egrp if du_dom==1
ge size1_int=ln_khard*size1
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1 & size1~=.,  cluster (ruref) abs(ruref)
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size1 i.myc $control if IT1==1 & size1~=.,  cluster (ruref) abs(ruref)
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size1 size1_int i.myc $control if IT1==1 & size1~=.,  cluster (ruref) abs(ruref)


* If sample too small - starting from data with domestic size as well
ge size2=size1
replace size2=0 if size1==.
ge size2_int=ln_khard*size2
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1 & size1~=.,  cluster (ruref) abs(ruref)
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size2 i.myc $control if IT1==1 & size1~=.,  cluster (ruref) abs(ruref)
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu size2 size2_int i.myc $control if IT1==1 & size1~=.,  cluster (ruref) abs(ruref)


log c

stop

