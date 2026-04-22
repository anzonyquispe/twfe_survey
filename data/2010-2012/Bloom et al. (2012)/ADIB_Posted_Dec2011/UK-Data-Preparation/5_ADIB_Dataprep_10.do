***************************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
***************************
* THIS FILE GENERATES SMALLER DATASET TO BE SAVED IN AER DIRECTORY
***************************

clear
set more 1
set matsize 4000
set mem 500m
u data_glo_march2010, clear
drop if sic2==85 | sic2==80 | sic2==75
replace ncapex=. if ncapex<0
ge s_h = ksoft/khard
ge totp_va=totpurch/gva_fc
cap drop paradise
gen paradise = (f_own==49| f_own==65|f_own==73|f_own==93|f_own==131|f_own==277|f_own==371|f_own==833)
drop if paradise==1

global keep "khard sic2 ncapex se-wales rig* sic4 IT1 khard_y ln_khard du_usa_mu du_oth_mu du_dom sic3 hardinv year go gva_fc gva_fc_def gva_fc rcapstk95 emp khard totpurch yy* totlabcost age Dgroup egrp_ref IT_prod  ent_emp"
global keep_1 "mode_reg int_us_mu int_oth_mu ln_N age_t ln4 ln_TM ln_K_not ruref myc single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
global keep_2 "ln_K ln_Y int_N_us int_N_oth int_TM_us int_TM_oth int_K_us int_K_oth"
global keep_3 "ln_TM_sq ln_K_not_sq ln_N_sq ln_khard_sq  kict* k_* TM_N"
global keep_4 "D_ue D_nonue du_non_ue_mu du_ue_mu int_ue_mu int_non_ue_mu int_us_mu"
global keep_5 "ln_khard_ecomm int_us_mu_ecomm int_oth_mu_ecomm"

xi: keep region $keep $keep_1 $keep_2 $keep_3 $keep_4 $keep_5

reg gva_fc_def rcapstk95 emp khard totpurch yy* hardinv
gen samp=e(sample)==1

* Deviations from sic3 year mean 
local vars "gva_fc go rcapstk95  khard  totpurch"
foreach var of local vars{
	gen `var'_L = `var'/emp if year==2001 & samp==1
	bys sic3 year: egen `var'_L_sic4y = mean(`var'_L)
	gen `var'_L_dev = `var'_L/(`var'_L_sic4y)*100 
	drop `var'_L_sic4y
}

local vars "emp"
foreach var of local vars{
	gen `var'_2001 = `var' if year==2001 & samp==1
	bys sic3 year: egen `var'_2001_sic4y = mean(`var'_2001)
	gen `var'_dev = `var'_2001/(`var'_2001_sic4y)*100 
	drop `var'_2001 `var'_2001_sic4y
}
local vars "totpurch totlabcost rcapstk95 khard"
foreach var of local vars{
	gen `var'_GY = `var'/go
}

gen nat=.
replace nat=1 if du_usa_mu==1
replace nat=2 if du_oth_mu==1
replace nat=3 if du_dom==1 
gen nat1= "1. USA"
gen nat2= "2. Other Multi (UK included)"
gen nat3= "3. UK domestic"



so sic4
merge sic4 using gosic4agg
drop if _m==2
drop _m
gen ln_go_agg=ln(sic4go)

label var sic4go "Sum of gross output SIC4 level"
label var ln_go_agg "ln sum of gross output SIC4 level"

cap drop rig*
ta mode_reg, gen(rig)
xi i.manuf*i.age
ge manuf_age_t=manuf*age_t

* This is for OP
ge ln_I_non_ict =ln(ncapex)
ge ln_I_ict=ln(hardinv)
lab var ln_I_non_ict "ln non IT investment"
lab var ln_I_ict "ln IT investment"


lab var ln_khard "ln IT capital per employee"
lab var ln4 "ln gross output per employee"
lab var ln_TM "ln materials per employee"
lab var ln_K_not "ln non IT capital per employee"
lab var ln_Y "ln value added per employee"

foreach y in se nw north yorks emid wmid eanglia sw wales {
lab var `y' "=1 if region is `y'"
}
label var manuf_age_t "Dummy manufacturing * Dummy age trucated"
label var region "Region"
label var ncapex "Total investment"
label var ln_K "ln total capital per employee"
label var IT1 "=1 if IT intensive sector"
label var khard_y "IT capital over value added"
label var gva_fc "Value added"
label var totlabcost "Total labour costs"
label var go "Gross output"
label var emp "Employment"
label var totpurch "Materials"
label var rcapstk95 "Non IT Capital stock"
label var gva_fc_def "Value added (deflated)"
label var khard "IT capital stock"
label var age "Plant age"
label var hardinv "IT investments"
label var samp "=1 if non missing rcapstk95  khard  totpurch"
label var emp_dev "Employment"
label var go_L_dev "Gross output per employee normalized by SIC3 mean (2001)"
label var rcapstk95_L_dev "Non IT Capital stock per employee normalized by SIC3 mean (2001)"
label var gva_fc_L_dev "Value added per employee normalized by SIC3 mean (2001)"
label var khard_L_dev "IT capital stock  per employee normalized by SIC3 mean (2001)"
label var totpurch_L_dev "Materials  per employee normalized by SIC3 mean (2001)"
label var go_L "Gross output per employee (2001)"
label var rcapstk95_L "Non IT Capital stock per employee (2001)"
label var gva_fc_L "Value added per employee (2001)"
label var khard_L "IT capital stock  per employee (2001)"
label var totpurch_L "Materials  per employee (2001)"
label var du_usa_mu "=1 if US Multinational"
label var du_oth_mu "=1 if Other non US Multinational"
label var du_dom "=1 if domestic plant"
label var totpurch_GY "Share of materials in revenue"
label var totlabcost_GY "Share of labour expenditures in revenue"
label var rcapstk95_GY "Share of non_IT capital services in revenue"
label var khard_GY "Share of IT capital services in revenue"
label var ruref "Plant identifier"
label var year "Year"
label var Hdummy_bsci "=1 if IT stock from BSCI"
label var Hdummy_qice "=1 if IT stock from QICE"
label var Hdummy_far "=1 if IT stock from FAR"
label var ln_N "ln employment"
label var int_oth_mu "Other MNE dummy*ln IT capital stock per employee"
label var int_us_mu "US MNE dummy*ln IT capital stock per employee"
label var mode_reg "Region of location"
label var myc "Sic3*Year groups"
label var single "=1 if single plant firm"
label var D_us "US MNE dummy*single plant firm dummy"
label var D_oth "Other MNE dummy*single plant firm dummy"
label var int_K_us "US MNE dummy*ln non IT capital per employee"
label var int_K_oth "Other MNE dummy*ln non IT capital per employee"
label var int_TM_us "US MNE dummy*ln materials per employee"
label var int_TM_oth "Other MNE dummy*ln materials per employee"
label var int_N_us "US MNE dummy*ln employees"
label var int_N_oth "Other MNE dummy*ln employees"
label var ln_khard_sq "ln IT capital per employee - squared"
label var ln_K_not_sq "ln non IT capital per employee - squared"
label var ln_TM_sq "ln materials per employee - squared"
label var ln_N_sq "ln employees - squared"
label var kict_K "ln IT capital*ln non IT capital"
label var kict_TM "ln IT capital*ln materials"
label var kict_N "ln IT capital*ln employemnt"
label var du_ue_mu "=1 if European Multinational"
label var du_non_ue_mu "=1 if non European Multinational and non US multinational"
label var int_ue_mu "EU MNE dummy*ln IT capital stock per employee"
label var int_non_ue_mu "Non EU MNE dummy*ln IT capital stock per employee"
label var D_ue "EU MNE dummy*single plant firm dummy"
label var D_nonue "Non EU MNE dummy*single plant firm dummy"
label var ln_khard_ecomm "ln fraction of workers using computers"
label var int_us_mu_ecomm "US MNE dummy*ln fraction of workers using computers"
label var int_oth_mu_ecomm "Other MNE dummy*ln fraction of workers using computers"
label var k_N "ln non IT capital*ln employees"
label var k_TM "ln non IT capital*ln materials"
label var TM_N "ln materials*ln employees"
label var nat "1=US MNE; 2=Other MNE; 3=Domestic"
label var nat1 "US MNE dummy - string format"
label var nat2 "Other MNE dummy - string format"
label var nat3 "Domestic dummy - string format"

so ruref year
save "adib_data_10", replace

******
* PREPARE TAKEOVERS DATA
******
clear
set matsize 4000
set mem 500m
set more off, perm
u "takeovers_march2010", clear
cap log c
log using 5_takeovers.txt, text replace

global  controls "D_us D_oth single  i.region i.manuf|age  i.manuf|age_t yy* i.max_sic2*i.year  Hd* i.prob_t i.prob_f proc"
global  out "bdec(4)  coefastr se 3aster"
global  controls_int "i.post*i.D_us i.post*i.D_oth i.post*i.single i.post*man1 i.post*man2 man1 man2 i.post*i.max_sic2 i.post*i.year i.post*i.my  i.post*age i.post*age_t i.post*i.region  i.post*i.Hdummy_b  i.post*i.Hdummy_f  i.post*i.Hdummy_q i.post*i.prob_f i.post*i.prob_t i.post*i.proc"
* Pooled model to test
ge man1=manuf*age
ge man2=manuf*age_t
ge double my= max_sic2*10000+year
xi: keep region manuf ln4 ln_TM ln_N ln_K_not ln_khard  my m_dom_take take_dom_after post dist_1_us dist_2_us dist_1_us_ict dist_2_us_ict dist_1_oth_ict dist_2_oth_ict dist_1_oth dist_2_oth prob_f max_sic2 prob_t int_us_before int_oth_before  $controls_int i.prob_f i.prob_t proc int_us_after int_oth_after  take_us_after take_oth_after take_us_before take_oth_bef  du_oth_nat_bef du_usa_nat_bef i.prob_f i.prob_t proc $controls  pre ruref year
label var ruref "Plant identifier"
lab var ln_khard "ln IT capital per employee"
lab var ln4 "ln gross output per employee"
lab var ln_TM "ln materials per employee"
lab var ln_K_not "ln non IT capital per employee"
label var age "Plant age"
label var year "Year"
label var Hdummy_bsci "=1 if IT stock from BSCI"
label var Hdummy_qice "=1 if IT stock from QICE"
label var Hdummy_far "=1 if IT stock from FAR"
label var ln_N "ln employment"
label var single "=1 if single plant firm"
label var D_us "US MNE dummy*single plant firm dummy"
label var D_oth "Other MNE dummy*single plant firm dummy"
label var take_us_before "=1 if US MNE takeover"
label var take_us_after "=1 if US MNE takeover"
label var take_dom_after "=1 if domestic takeover"
label var int_us_before "US MNE takeover dummy*ln IT capital per employee"
label var int_us_after "US MNE takeover dummy*ln IT capital per employee"
label var take_oth_before "=1 if Other MNE takeover"
label var take_oth_after "=1 if Other MNE takeover"
label var int_oth_before "Other MNE takeover dummy*ln IT capital per employee"
label var int_oth_after "Other MNE takeover dummy*ln IT capital per employee"
label var manuf "=1 if manufacturing sector"
label var m_dom_take "=1 if ever taken over by a domestic firm"
label var pre "=1 if in pre takeover period"
label var post "=1 if in post takeover period"
label var max_sic2 "Modal SIC2 industry"
label var prob_t "Sum of takeover episodes in sample"
label var prob_f "=1 if ownership corresponds to ARD register panel"
label var proc "Sum of takeover episodes in sample*dummy wnership corresponds to ARD register panel"
label var dist_1_us "=1 if 1 year after US MNE takeover"
label var dist_2_us "=1 if 2 years or more after US MNE takeover"
label var dist_1_us_ict "Dummy 1 year after US MNE takeover * ln IT capital per employee"
label var dist_2_us_ict "Dummy 2 years or more after US MNE takeover * ln IT capital per employee"
label var dist_1_oth "=1 if 1 year after Other MNE takeover"
label var dist_2_oth "=1 if 2 years or more after Other MNE takeover"
label var dist_1_oth_ict "Dummy 1 year after Other MNE takeover * ln IT capital per employee"
label var dist_2_oth_ict "Dummy 2 years or more after Other MNE takeover * ln IT capital per employee"
label var du_usa_nat_bef "=1 if plant belongs to US MNE before takeover"
label var du_oth_nat_bef "=1 if plant belongs to Other MNE before takeover"
lab var man1 "Manufacturing dummy*plant age"
lab var man2 "Manufacturing dummy*plant age truncation dummy"
lab var region "Region of plant location"
label var my "Sic2*Year groups"
so ruref year
save adib_data_takeovers, replace
