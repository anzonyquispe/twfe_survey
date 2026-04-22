*NOTE THIS IS IN ADIB_AER\RESULTS SUB-DIRECTORY. TO RUN YOU NEED TO COPY DATA FILES FROM ADIB_AER\DATA 
***************************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
***************************
global F9 do "t:\ceriba\stata_files\copymarked.do";
global F10 do "H:\_markedF10.do";
adopath +t:\ceriba\stata_files\ado
adopath +t:\ceriba\stata_files\ado\stb\
adopath +t:\ceriba\stata_files\projects
adopath + x:\code\stat-transfer-setup\ 
adopath +X:\code\ado\xtabond
adopath +X:\code\ado\
adopath +T:\Ceriba\climatelevy\do

set more 1
version 9.2
cap log c

log using "ADIB_Alltables_Nov2010c", replace t

**************
* TABLE 1. 
**************
clear
forvalues z=1(1)3{
use "adib_data_10", clear
keep if year==2001 & samp==1
if `z'==1{
local s "US Multinationals"
}
if `z'==2{
local s "Other Multinationals (including UK)"
}
if `z'==3{
local s "UK domestic"
}
keep if nat==`z' 
save temp_`z', replace

clear
foreach h in mean sd count {
use "temp_`z'", clear
collapse (`h') emp_dev gva_fc_L_dev go_L_dev rcapstk95_L_dev totpurch_L_dev khard_L_dev 
gen x="`h'"
save  "`h'_`z'_Tab3", replace
}

clear
gen temp=.
foreach h in mean sd count {
append using "`h'_`z'_Tab3"
}
gen str30 zname="`s'"
save All_`z'_Tab3, replace
}

clear
gen temp=.
forvalues z=1(1)3{
append using "All_`z'_Tab3"
}
drop temp
outsheet using Table1.xls, replace

forvalues z=1(1)3{
cap cap erase "All_`z'_Tab3.dta"
cap erase "temp_`z'.dta"
}
forvalues z=1(1)3{
foreach h in count mean sd{
cap erase "`h'_`z'_Tab3.dta"
}
}

**************
* TABLE A2 - Panel A
**************
foreach z in mean median sd{
use "adib_data_10", clear
keep if year==2001 & samp==1
collapse (`z') emp go gva_fc khard gva_fc_L go_L totpurch_L rcapstk95_L khard_L totpurch_GY totlabcost_GY rcapstk95_GY khard_GY Dgroup
gen x="`z'"
save  "`z'_Tab2", replace
}

clear
gen temp=.
foreach z in mean median sd{
append using "`z'_Tab2"
}
drop temp
outsheet using TableA2a_panelA.xls, replace

foreach z in mean median sd{
cap erase "`z'_Tab2.dta"
}

**************
* TABLE A2 - Panel B
**************
forvalues it=0(1)1{
use adib_data_10.dta, clear
keep if samp==1 & year==2001 
drop ln_khard
gen ln_khard=ln(khard)
keep if IT1==`it'
save sum4_`it'.dta, replace

forvalues z=1(1)3{
use sum4_`it', clear
*local a=`z'+1
if `z'==1{
local s "US Multinationals"
}
if `z'==2{
local s "Other Multinationals (including UK)"
}
if `z'==3{
local s "UK domestic"
}
keep if nat==`z' 
save temp_`z'_`it', replace

clear
foreach h in mean sd count{
use "temp_`z'_`it'", clear
collapse (`h')  khard_y ln_khard
gen x="`h'"
save  "`h'_`z'_newtab_`it'", replace
}

clear
gen temp=.
foreach h in  mean sd count{
append using "`h'_`z'_newtab_`it'"
}
gen str30 zname="`s'"
gen IT=`it'
save All_`z'_newtab_`it', replace
}
}

clear
gen temp=.
forvalues it=0(1)1{
forvalues z=1(1)3{
append using "All_`z'_newtab_`it'"
}
drop temp
}
save Stat0, replace


* ALL SECTORS, MNE's
forvalues z=1(1)3{
use adib_data_10.dta, clear
keep if samp==1 & year==2001 
*local a=`z'+1
if `z'==1{
local s "US Multinationals"
}
if `z'==2{
local s "Other Multinationals (including UK)"
}
if `z'==3{
local s "UK domestic"
}
keep if nat==`z' 
save temp_`z', replace

clear
foreach h in  mean sd count{
use "temp_`z'", clear
collapse (`h')  khard_y  ln_khard 
gen x="`h'"
save  "`h'_`z'_newtab", replace
}

clear
gen temp=.
foreach h in  mean sd count{
append using "`h'_`z'_newtab"
}
gen str30 zname="`s'"
save All_`z'_newtab, replace
}

clear
gen temp=.
forvalues z=1(1)3{
append using "All_`z'_newtab"
}
drop temp
save Stat1, replace

* ALL firms
forvalues it=0(1)1{
use adib_data_10.dta, clear
keep if samp==1 & year==2001 
keep if IT1==`it'
save temp_`it', replace

clear
foreach h in  mean sd count{
use "temp_`it'", clear
collapse (`h') ln_khard khard_y 
gen x="`h'"
save  "`h'_newtab_`it'", replace
}

clear
gen temp=.
foreach h in  mean  sd count{
append using "`h'_newtab_`it'"
}
gen IT=`it'
save All_newtab_`it', replace
}

clear
gen temp=.
forvalues it=0(1)1{
append using "All_newtab_`it'"
}
drop temp
save Stat2, replace

* ALL SECTORS, ALL FIRMS
clear
foreach h in  mean  sd count {
use adib_data_10.dta, clear
keep if samp==1 & year==2001 
collapse (`h') khard_y ln_khard  
gen x="`h'"
save  "`h'_newtab", replace
}

clear
gen temp=.
foreach h in mean sd count {
append using "`h'_newtab"
}
save Stat3, replace


clear
gen temp=.
forvalues y=0(1)3{
append using "Stat`y'"
}
drop temp
replace IT=99 if IT==.
replace zname = "All firms" if zname==""
reshape wide ln_khard khard_y , i(x zname) j(IT)
so zname x
order khard_y99 khard_y0 khard_y1 ln_khard99 ln_khard0 ln_khard1
outsheet using TableA2a_panelB.xls, replace

foreach var in count mean sd median {
cap erase `var'_newtab.dta
forvalues y=1(1)3{
cap erase `var'_`y'_newtab.dta
forvalues z=0(1)1{
cap erase `var'_`y'_newtab_`z'.dta
cap erase `var'_newtab_`z'.dta
}
}
}


forvalues z=0(1)1{
forvalues y=1(1)3{
cap cap erase temp_`y'_`z'
cap cap erase temp_`y'
}
}



*******
* TABLE 2
*******
clear
set matsize 4000
set mem 500m

global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"

u adib_data_10, replace
* col 1
xi:  areg ln4 ln_TM ln_K_not ln_N $control, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N du_usa_mu du_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base) replace

* col 2
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard $control, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base) append

* col 3
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu $control, rob cluster (ruref) abs(myc)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base) append

* col 4
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu  $control if IT1==1,  cluster (ruref) abs(myc)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base - IT1) append

* col 5
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu  $control if IT1==0,  cluster (ruref) abs(myc)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base - IT0) append

* col 6 (fixed effects)
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base - fe) append

* col 7 (fixed effects)
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) append

* col 8 (fixed effects)
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==0,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3.out", bdec(4) coefastr se 3aster ct(base - fe - IT0) append
**stcmd delim "TABLE3.out" excel TABLE2.xls




********************
* TABLE 3 - Robustness tests on the UK production functiom
********************
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
global  control3 "du_usa_mu du_ue_mu du_non_ue_mu Dgroup D_us D_ue D_nonue Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"


* col 1: Baseline on IT1 sample
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu i.myc $control if IT1==1, rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE4.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) replace

* col 2: Value Added
xi: areg  ln_Y ln_K_not ln_N ln_khard  int_us_mu int_oth_mu i.myc $control if IT1==1 & e(sample)==1, rob cluster (ruref) abs(ruref)
test du_usa_mu=du_oth_mu
test int_us_mu=int_oth_mu
**outreg ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE4.out", bdec(4) coefastr se 3aster ct(value added - fe - IT1) append

* col 3: All inputs nteracted 
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu int_N_us int_N_oth int_TM_us int_TM_oth int_K_us int_K_oth i.myc $control if IT1==1, rob cluster (ruref) abs(ruref)
test du_usa_mu=du_oth_mu
test int_us_mu=int_oth_mu
test  int_K_us =int_K_oth= int_TM_us =int_TM_oth= int_N_us =int_N_oth=0
test  int_K_us = int_TM_us = int_N_us =0
test  int_K_oth = int_TM_oth = int_N_oth =0
**outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu int_N_us int_N_oth int_TM_us int_TM_oth int_K_us int_K_oth using "TABLE4.out", bdec(4) coefastr se 3aster ct(all int - fe - IT1) append

* col 4: E-commerce survey, see below

* col 5: Translog 
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu ln_TM_sq ln_K_not_sq ln_N_sq ln_khard_sq  kict* k_* TM_N i.myc $control if IT1==1, abs(ruref) rob cluster (ruref)
test du_usa_mu=du_oth_mu
test int_us_mu=int_oth_mu
test ln_TM_sq ln_K_not_sq ln_N_sq ln_khard_sq k_N k_TM TM_N kict_K kict_N kict_TM
**outreg ln_TM ln_K_not ln_N ln_khard du_usa_mu du_oth_mu int_us_mu int_oth_mu ln_TM_sq ln_K_not_sq ln_N_sq ln_khard_sq  kict* k_* TM_N using "TABLE4.out", bdec(4) coefastr se 3aster ct(translog - fe - IT1) append

* col 6: EU and non EU multinationals
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_ue_mu int_non_ue_mu int_us_mu i.myc $control3 if IT1==1, rob cluster (ruref) abs(ruref)
test du_usa_mu=du_ue_mu
test du_usa_mu=du_non_ue_mu
test int_ue_mu=int_non_ue_mu=int_us_mu
test int_ue_mu=int_us_mu
test int_non_ue_mu=int_us_mu
**outreg ln_TM ln_K_not ln_N ln_khard  du_ue_mu du_non_ue_mu du_usa_mu  int_ue_mu int_non_ue_mu int_us_mu using "TABLE4.out", bdec(4) coefastr se 3aster ct(non ue multi - fe - IT1) append
**stcmd delim "TABLE4.out" excel "TABLE3.xls"

*** COL (4) TABLE 3
* Ecommerce in per capita spec is fine with sic3 dummies
use "adib_data_10", replace
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
 
xi: areg  ln4 ln_TM ln_K ln_N ln_khard_ecomm int_us_mu_ecomm int_oth_mu_ecomm $control if IT1==1, abs(myc) cluster(ruref)
test int_us_mu_ecomm=int_oth_mu_ecomm
test du_usa_mu=du_oth_mu
**outreg ln_TM ln_K ln_N ln_khard_ecomm int_us_mu_ecomm int_oth_mu_ecomm du_usa_mu du_oth_mu using "ecomm.out", bdec(4) coefastr se 3aster ct(ecomm - myc - IT1) replace
**stcmd delim "ecomm.out" excel "ecomm.xls"


*****
* TABLE 4: UK Intensity Equations
*****
use "adib_data_10", replace
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
qui xi:areg ln4 ln_TM ln_K_not ln_N $control, rob cluster (ruref) abs(myc)
keep if e(sample)
* Just replace in lab terms, control for gross output
global  control_i "single  Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
gen ln_go=ln(go)


* col 1
xi:  areg ln_khard ln_go du_usa_mu du_oth_mu , rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg du_usa_mu du_oth_mu using "int.out", bdec(4) coefastr se 3aster ct(raw-all) replace

* col 2
xi: areg ln_khard  ln_go  du_usa_mu du_oth_mu if IT1==1, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg du_usa_mu du_oth_mu using "int.out", bdec(4) coefastr se 3aster ct(raw_IT1) append

* col 3
xi: areg  ln_khard ln_go  du_usa_mu du_oth_mu if IT1==0, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg du_usa_mu du_oth_mu using "int.out", bdec(4) coefastr se 3aster ct(raw_IT0) append

* col 4
xi: areg  ln_khard ln_go  du_usa_mu du_oth_mu $control_i, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg du_usa_mu du_oth_mu using "int.out", bdec(4) coefastr se 3aster ct(controls_all) append

* col 5
xi: areg  ln_khard ln_go  du_usa_mu du_oth_mu $control_i if IT1==1, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
**outreg du_usa_mu du_oth_mu using "int.out", bdec(4) coefastr se 3aster ct(controls_IT1) append

* col 6
xi: areg  ln_khard ln_go  du_usa_mu du_oth_mu $control_i if IT1==0, rob cluster (ruref) abs(myc)
test du_usa_mu=du_oth_mu
*outreg du_usa_mu du_oth_mu using "int.out", bdec(4) coefastr se 3aster ct(controls_IT0) append
*stcmd delim "int.out" excel "TABLE4.xls"




**********
* TABLE 5
**********
clear 
set mem 500m

global  controls "D_us D_oth single  i.region i.manuf|age  i.manuf|age_t yy* i.max_sic2*i.year  Hd* i.prob_t i.prob_f proc"
global  out "bdec(4)  coefastr se 3aster"

u adib_data_takeovers, replace

* col 1: BEFORE
xi:reg ln4 ln_TM ln_N ln_K_not ln_khard take_us_before take_oth_bef  du_oth_nat_bef du_usa_nat_bef i.prob_f i.prob_t proc $controls if (pre==1),  cluster(ruref)
test take_us_before= take_oth_before
*outreg ln_TM ln_N ln_K_not ln_khard take_us_before take_oth_before   using TABLE5new.out, ct(bef - control for nat) $out replace

* col 2: BEFORE
 xi:reg ln4 ln_TM ln_N ln_K_not ln_khard   int_us_before int_oth_before take_us_before take_oth_before  du_oth_nat_bef du_usa_nat_bef  $controls if (pre==1),  cluster(ruref) 
test take_us_before= take_oth_before
test int_us_before= int_oth_before
*outreg ln_TM ln_N ln_K_not ln_khard  int_us_before int_oth_before take_us_before take_oth_before  using TABLE5new.out, $out  ct(before - control for nat) append

* col 3: AFTER
 xi:reg ln4 ln_TM ln_N ln_K_not ln_khard  take_us_after take_oth_after $controls if (post==1),  cluster(ruref) 
test take_us_afte= take_oth_after
*outreg ln_TM ln_N ln_K_not ln_khard take_us_after take_oth_after   using TABLE5new.out, $out ct(after) append

* col 4: AFTER
 xi:reg ln4 ln_TM ln_N ln_K_not ln_khard int_us_after int_oth_after  take_us_after take_oth_after $controls if (post==1),  cluster(ruref) 
test take_us_afte= take_oth_after
test int_us_after=int_oth_after
*outreg ln_TM ln_N ln_K_not ln_khard take_us_after take_oth_after int_us_after int_oth_after  using TABLE5new.out, $out ct(after) append

* col 5: AFTER
 xi:reg ln4 ln_TM ln_N ln_K_not ln_khard dist_1_oth dist_2_oth  dist_1_us dist_2_us dist_1_us_ict dist_2_us_ict dist_1_oth_ict dist_2_oth_ict  $controls if (post==1),  cluster(ruref) 
*outreg ln_TM ln_N ln_K_not ln_khard dist_1_oth dist_2_oth  dist_1_us dist_2_us   dist_1_oth_ict dist_2_oth_ict dist_1_us_ict dist_2_us_ict  using TABLE5new.out, $out ct(after) append
test dist_1_us=dist_1_oth
test dist_2_us=dist_2_oth
test dist_1_us_ict=dist_1_oth_ict
test dist_2_us_ict=dist_2_oth_ict

* col 6: AFTER - Only domestic takeovers
xi:reg ln4 ln_TM ln_N ln_K_not ln_khard   dist_1_us dist_2_us   dist_1_us_ict dist_2_us_ict     $controls if (post==1)&m_dom_take==1&take_dom_after==0,  cluster(ruref) 
*outreg ln_TM ln_N ln_K_not ln_khard dist_1_us dist_2_us   dist_1_us_ict dist_2_us_ict   using TABLE5new.out, $out ct(after) append
*stcmd delim TABLE5new.out excel TABLE5new.xls

* Pool to test
xi: reg ln4  take_us_bef take_us_after take_oth_bef take_oth_after i.post*ln_TM  i.post*ln_N  i.post*ln_K_not  i.post*ln_khard du_oth_nat_bef du_usa_nat_bef  $controls_int if (pre==1|post==1), cluster(ruref)  
test take_us_bef=take_us_afte
test take_oth_bef=take_oth_afte
test ( take_us_afte-take_us_bef)=(take_oth_afte-take_oth_bef)

xi:  reg ln4 i.post*ln_TM i.post*ln_N i.post*ln_K_not i.post*ln_khard du_oth_nat_bef du_usa_nat_bef take_us_bef  take_us_after take_oth_bef  take_oth_after int_us_before int_us_after int_oth_before int_oth_after  $controls_int if (pre==1|post==1), cluster(ruref)  
test take_us_bef=take_us_afte
test take_oth_bef=take_oth_afte
test ( take_us_afte-take_us_bef)=(take_oth_afte-take_oth_bef)
test int_us_before=int_us_after
test int_oth_before=int_oth_after
test ( int_us_afte-int_us_before)=(int_oth_afte-int_oth_bef)


*****************
* RESULTS MENTIONED IN TEXT
*****************

******
* Klette Griliches test - Industry output as additional regressor
*****
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
clear
set mem 500m
u "adib_data_10", replace
keep if IT1==1
so sic4
merge sic4 using gosic4agg
drop if _m==2
drop _m
gen int_usa_go=du_usa_mu*ln_go_agg
gen int_oth_go=du_oth_mu*ln_go_agg
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"

xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "sic4.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) replace
xi: areg  ln4 ln_go_agg ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_go_agg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "sic4.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) append
xi: areg  ln4 ln_go_agg int_usa_go int_oth_go ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1,  cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
test int_usa_go=int_oth_go
*outreg ln_go_agg int_usa_go int_oth_go ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "sic4.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) append
*stcmd delim "sic4.out" excel SIC4agg.xls


**************************
* Production functions by SUBSECTORS
***************************
u "adib_data_10", replace

egen g_sic=group(sic2)
bys sic2: egen ob=count(ruref)
replace sic2=100 if ob<60
ta sic2
global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"


xi:areg  ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu $control i.myc, rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using industry.out, bdec(4) coefastr se 3aster ct(sic`var') replace

* Now all sectors
foreach var in 14	15	17	18	20	21	22	24	25	26	27	28	29	30	31	32	33	34	35	36	45	50	51	52	55	60	61	62	63	64	67	70	71	72	73	74	90	91	92	93	100{
display "SIC CODE `var'"
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu $control i.myc if sic2==`var', rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using industry.out, bdec(4) coefastr se 3aster ct(sic`var') append
}

*stcmd delim "industry.out" excel "industry.xls"

* ICT producting sectors


* ICT producing sectors
u "adib_data_10", replace
replace IT_prod=0 if IT1==1
keep if IT1==0

* Fixed effects
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu i.myc $control if IT1==0 , rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "industry_ITprod.out", bdec(4) coefastr se 3aster ct(IT0 ITprod0) replace

* By subsectors
preserve
keep if IT_prod==0
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu i.myc $control if IT1==0 & IT_prod==0, rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "industry_ITprod.out", bdec(4) coefastr se 3aster ct(IT0 ITprod0) append
restore
preserve
keep if IT_prod==1
xi: areg ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu i.myc $control if IT1==0 & IT_prod==1, rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "industry_ITprod.out", bdec(4) coefastr se 3aster ct(IT0 ITprod1) append
restore
*stcmd delim industry.out excel industry.xls


******************
* Aggregate obs at the Enterprise Group level ("Firm" in paper)
********************
* A: Check results when everything is CLUSTERED up at the entref level
u "adib_data_10", replace
replace egrp_ref="unknown" if egrp_ref==""

preserve
keep if IT1==1
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1,  cluster (egrp_ref) abs(ruref)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3_egrp_cluster.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) append
restore



* B. NOW AGGREGATE EVERYTHING UP AT EGRP REF LEVEL

* BEFORE COLLAPSING MAKE SURE WE ONLY KEEP FIRMS WITH ALL INPUTS
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu  $control,  cluster (egrp_ref) abs(myc)
keep if e(sample)==1
bys year egrp_ref: egen x=count(ruref)
tab x

* Sum all outputs and inputs at the EGRP level
collapse (sum) tot_emp=emp (max) IT1 age age_t manuf myc Hd* mode_reg (min) single (mean) go emp rcapstk95 totpurch du_usa_mu du_oth_mu khard (mean) ent_emp, by(egrp_ref year)
gen share=tot_emp/ent_emp
su share,d
cap drop new_sha
ge new_sha=share
replace new_sha=1 if share>1 & share!=.
bys egrp_ref: egen mean_share=mean(share)

gen ln_sha=ln(1+share)
gen ln4    	       = ln(go/emp)
gen ln_K_not    	 = ln((rcapstk95-khard)/emp)
gen ln_N    	 = ln(emp)
gen ln_TM  	  	 = ln(totpurch/emp)
gen ln_khard 	 = ln(khard/emp)
gen int_us_mu	 = du_usa_mu*ln_khard
gen int_oth_mu 	 = du_oth_mu*ln_khard
gen D_us	 	 = single * du_usa_mu
gen D_oth 	 	 = single * du_oth_mu

keep if IT1==1
xi: areg  ln4 ln_TM ln_K_not ln_N ln_khard int_us_mu int_oth_mu i.myc $control if IT1==1 [aw=share] ,  cluster (egrp_ref) abs(egrp_ref)
test int_us_mu=int_oth_mu
test du_usa_mu=du_oth_mu
*outreg ln_TM ln_K_not ln_N ln_khard  du_usa_mu du_oth_mu int_us_mu int_oth_mu using "TABLE3_egrp.out", bdec(4) coefastr se 3aster ct(base - fe - IT1) append

*stcmd delim "TABLE3_egrp.out" excel "TABLE3_egrp.xls"

log c
stop




