******************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
************************
* THIS FILE PERFORMS LAST STEPS OF DATA PREPARATION TO GENERATE UK RESULTS
* Generate logs, interaction terms, dummies
* Merge with LFS Skills data
******************
cd "T:\LSE\Raffaella_Sadun\ADIB\1.Merge&Clean"
clear
set matsize 4000
set mem 500m
set more off, perm

use "ardict", clear
so ruref year
drop if ruref==ruref[_n-1] & year==year[_n-1]

gen ln_K_not= ln(rcapstk95-khard)
gen ln_K_not_s= ln(rcapstk95-ksoft)
gen ln_K_not_a= ln(rcapstk95-khard-ksoft)
gen lnK_N= ln_K_not- ln_N
gen ln4=ln(go)

cap drop IT*
ge IT1 =(sic2==18 | sic2==22 | sic2==29 | sic2==31 & sic3~=313 | sic2==33  & sic3~=331 | sic3==351 | sic3==353 | sic3==351 | sic3==359 | sic2==36 | sic2==37 | sic2==51 |sic2==52 | sic2==65 | sic2==66 | sic2==67 | sic2==71 | sic2==73 | sic3==741 | sic3==742 | sic3==743)
ge IT_prod = (sic2==30 | sic3==313 | sic3==321 | sic3 ==322 | sic3==323 | sic3 ==331 | sic2==64 | sic2==72)

ge int_multi=ln_khard*multi
ge int_us_mu =ln_khard*du_usa_mu
ge int_oth_mu=ln_khard*du_oth_mu

* Software
ge int_us_mu_s=ln_ksoft*du_usa_mu
ge int_oth_mu_s=ln_ksoft*du_oth_mu

ge int_K_us = ln_K_not*du_usa_mu
ge int_TM_us = ln_TM*du_usa_mu
ge int_N_us = ln_N*du_usa_mu
ge int_K_oth = ln_K_not*du_oth_mu
ge int_TM_oth = ln_TM*du_oth_mu
ge int_N_oth = ln_N*du_oth_mu

tab region, ge(rig)
ge double  myc2=year*100+sic2
ge double  myc=year*10000+sic4
ge double  myc3=year*1000+sic3

* E-Commerce survey
so ruref year
merge ruref year using "people_using.dta"
keep if _m==1 | _m==3
drop _m

ge ln_ecomm      =ln(lict*emp)
ge int_ecomm_us  =du_usa_mu*ln_ecomm
ge int_ecomm_oth =du_oth_mu*ln_ecomm


* Translog interactions
foreach var in ln_khard ln_K_not ln_N ln_TM {
ge `var'_sq=(`var')*(`var')
}
ge kict_K =ln_khard*ln_K_not
ge kict_TM=ln_khard*ln_TM
ge kict_N =ln_khard*ln_N
ge k_N    =ln_K_not*ln_N
ge k_TM   =ln_K_not*ln_TM
ge TM_N   =ln_TM*ln_N
ge int_usa_mu_sq = ln_khard_sq*du_usa_mu
ge int_oth_mu_sq = ln_khard_sq*du_oth_mu

ge int_w_us=ln_W*du_usa_mu
ge int_w_oth=ln_W*du_oth_mu

* Alternative way of expressing khard
ge prop = khard/rcapstk95
ge prop_us=prop*du_usa_mu
ge prop_oth=prop*du_oth_mu
ge ln_wagebill=ln(totlabcost)
ge wage = totlabcost/emp
ge ln_wage=ln(wage)
ge int_wage_us= ln_wage*du_usa_mu
ge int_wage_oth= ln_wage*du_oth_mu


* Merge with skills
* Prepare sic codes for merging with lfs
gen sic4_lfs = sic4
replace sic4_lfs = 4500 if sic4>4510 & sic4<4551
replace sic4_lfs = 5000 if sic4==5010 | sic==5030 | sic4==5050
replace sic4_lfs = 5110 if sic4>5110 & sic4<5120
replace sic4_lfs = 5120 if sic4>5120 & sic4< 5171
replace sic4_lfs = 5210 if sic4>5210 & sic4< 5269
gen sic3_lfs = int(sic4_lfs/10)

ge sic_lfs = sic
replace sic_lfs = sic4_lfs*10 if sic4_lfs == 4500 | sic4_lfs==5000 | sic4_lfs==5110 | sic4_lfs==5120 | sic4_lfs ==5210
replace sic_lfs = 17510 if sic>17510 & sic<17513
replace sic_lfs = 24300 if sic>24300 & sic<24304
replace sic_lfs = 29520 if sic>29520 & sic<29524
replace sic_lfs = 55300 if sic>55300 & sic<55303
replace sic_lfs = 63300 if sic>66300 & sic<66304
replace sic_lfs = 65230 if sic>65230 & sic<65237
replace sic_lfs = 80300 if sic>80301 & sic<80304

* Merge with sic2 dataset
so sic2 region year
merge sic2 region year using LFS_2.dta
 
drop if _m==2
drop _m
ge int_usa_lfs = highest_sic2*du_usa_mu
ge int_oth_lfs = highest_sic2*du_oth_mu 
ge int_ict_lfs = highest_sic2*ln_khard 

* Sic4
so sic4
merge sic4 using f_own_all_new.dta
ta _m
drop if _m==2
drop _m
ge int_us_sic4 = ln_khard*us_sic4

 
cap drop ln_hardinv
ge ln_hardinv=ln(hardinv)
ge int_inv_us=ln_hardinv*du_usa_mu
ge int_inv_oth=ln_hardinv*du_oth_mu
cap drop ln_I
ge ln_I = ln(ncapex)


* age
ge int_age=ln_khard*age
ge ln_age=ln(age)
ge int_ln_age=ln_khard*ln_age

drop  sic_bsci  softinv_bsci hardinv_bsci ksoftware_bsci khardware_bsci khardware_far ksoftware_far sic_qice  softinv_qice hardinv_qice ksoftware_qice khardware_qice softinv_ard ksoftware_ard _Subsidies Website software_investment rncapex_v95 rncapex_b95 rncapex_pm95 rncapex_all95 sel_emp rcapstk_pm95 rcapstk_v95 rcapstk_b95 ppi2000s ppi2000m ppi2000 def ave_def count_dlink desc mult_2002 ukmult_2002 max_mult max_ukmult miss_f mi max_mi min_mi max_for min_for prob gva_fc_def_l size size1 size2 size3 size4 size5 cs_y cs_k cs_e growth_softinv_curr khard_gro ksoft_gro  ln_cs 
ge todrop =(sic2==85 | sic2==80 | sic2==75)
drop if todrop==1
ge todrop1=(sic2<15 | sic2==45)

* This is new
cap drop prob
egen msic4=mean(sic4),by(ruref)
ge dif=sic4-msic4
ge prob=dif~=0
egen maxdif=max(prob),by(ruref)
ta maxdif

egen msic22=mean(sic2),by(ruref)
ge dif2=sic2-msic22
ge prob2=dif2~=0
egen maxdif2=max(prob2),by(ruref)
bys ruref: egen mode_reg=mode(region),maxmode
bys ruref: egen max_sic3=mode(sic3),maxmode
bys ruref: egen min_sic3=mode(sic3),minmode
bys ruref: egen max_sic4=mode(sic4),maxmode
bys ruref: egen min_sic4=mode(sic4),minmode
ge max_sic2=int(max_sic3/10)
ge double max_myc3=year*1000+max_sic3
ge double min_myc3=year*1000+min_sic3
ge double max_myc=year*10000+max_sic4
ge double min_myc=year*10000+min_sic4
foreach var in max min{
ge sic3_`var'=`var'_sic3
ge sic2_`var'=int(`var'_sic3/10)
ge IT1_`var' =(sic2_`var'==18 | sic2_`var'==22 | sic2_`var'==29 | sic2_`var'==31 & sic3_`var'~=313 | sic2_`var'==33  & sic3_`var'~=331 | sic3_`var'==351 | sic3_`var'==353 | sic3_`var'==351 | sic3_`var'==359 | sic2_`var'==36 | sic2_`var'==37 | sic2_`var'==51 |sic2_`var'==52 | sic2_`var'==65 | sic2_`var'==66 | sic2_`var'==67 | sic2_`var'==71 | sic2_`var'==73 | sic3_`var'==741 | sic3_`var'==742 | sic3_`var'==743)
}
drop IT1
rename IT1_max IT1
drop myc
rename max_myc3 myc
gen paradise = (f_own==49| f_own==65|f_own==73|f_own==93|f_own==131|f_own==277|f_own==371|f_own==833)

cd "T:\LSE\Raffaella_Sadun\ADIB\3.Main_Results"
save "data_main_march2010", replace

*********
* Final preparation steps for main dataset
********
clear
set matsize 4000
set mem 500m
set more off, perm

global F9 do "t:\ceriba\stata_files\copymarked.do";
global F10 do "H:\_markedF10.do";
adopath +t:\ceriba\stata_files\ado
adopath +t:\ceriba\stata_files\ado\stb\
adopath +t:\ceriba\stata_files\projects
adopath + x:\code\stat-transfer-setup\ 
adopath +X:\code\ado\xtabond
adopath +X:\code\ado\
adopath +T:\Ceriba\climatelevy\do
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
global directory "T:\LSE\Raffaella_Sadun\ADIB\3.Main_Results\"
cd "$directory/"

clear
set mem 500m
use "data_main_march2010", replace
cap drop paradise
gen paradise = (f_own==49| f_own==65|f_own==73|f_own==93|f_own==131|f_own==277|f_own==371|f_own==833)
drop if paradise==1
keep if ln_khard~=.
replace manuf=1 if manuf==.
ge single=Dgroup==0
ge D_us=single*du_usa_mu
ge D_oth=single*du_oth_mu
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"

* Just replace inputs in lab terms
replace ln4=ln4-ln_N
replace ln_TM=ln_TM-ln_N
replace ln_K_not=ln_K_not-ln_N
replace ln_khard=ln_khard-ln_N
replace int_us_mu=du_usa_mu*ln_khard
replace int_oth_mu=du_oth_mu*ln_khard
replace int_TM_us=du_usa_mu*ln_TM
replace int_TM_oth=du_oth_mu*ln_TM
replace int_K_us=du_usa_mu*ln_K_not
replace int_K_oth=du_oth_mu*ln_K_not

* Translog interactions
foreach var in ln_khard ln_K_not ln_N ln_TM {
replace `var'_sq=(`var')*(`var')
}
replace kict_K =ln_khard*ln_K_not
replace kict_TM=ln_khard*ln_TM
replace kict_N =ln_khard*ln_N
replace k_N    =ln_K_not*ln_N
replace k_TM   =ln_K_not*ln_TM
replace TM_N   =ln_TM*ln_N
replace int_usa_mu_sq = ln_khard_sq*du_usa_mu
replace int_oth_mu_sq = ln_khard_sq*du_oth_mu

* Sic4
replace int_us_sic4 = ln_khard*us_sic4

* Define non UE multinationals (exclude us from sample)
ge du_ue_mu= ((for==0 & ukmult==1) | f_own==69 | f_own==197| f_own==237| f_own==241| f_own==269| f_own==349| f_own==429| f_own==521| f_own==601| f_own==693| f_own==717| f_own==553| f_own==721| f_own==351| f_own==329| f_own==41| f_own==357| f_own==421| f_own==819)
ge du_non_ue_mu = (du_ue_mu==0 & for==1)
replace du_non_ue_mu=0 if f_own==805
ge int_ue_mu    = ln_khard*du_ue_mu
ge int_non_ue_mu= ln_khard*du_non_ue_mu
ge D_ue=Dgroup*du_ue_mu
ge D_nonue=Dgroup*du_non_ue_mu

* Ecommerce data
gen ln_khard_ecomm=ln(lict)
gen int_us_mu_ecomm=du_usa_mu*ln(lict)
gen int_oth_mu_ecomm=du_oth_mu*ln(lict)

so ruref year
save data_glo_march2010, replace


