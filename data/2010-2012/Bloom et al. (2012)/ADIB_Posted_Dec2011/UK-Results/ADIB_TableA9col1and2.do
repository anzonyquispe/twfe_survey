***************************
* AMERICANS DO I.T. BETTER: US MULTINATIONALS AND THE PRODUCTIVITY MIRACLE
* N.BLOOM, R. SADUN, J. VAN REENEN
* SEPTEMBER 2010
* TABLE A9 - cols 1 and 2 only
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

log using "T:\LSE\Raffaella_Sadun\ADIB_AER\results\ADIB_Alltables_Nov2010_tableA9col1and2", replace t
clear
set matsize 4000
set mem 500m

global  control "du_usa_mu du_oth_mu single D_us D_oth Hd*  i.age*manuf i.age_t*manuf manuf i.mode_reg"
u "T:\LSE\Raffaella_Sadun\ADIB_AER\data\adib_data_10", replace
keep if IT1==1

* Retail and Wholesale
xi:areg  ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu $control i.myc if (sic2==51 | sic2==52), rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu

* All other sectors
xi:areg  ln4 ln_TM ln_K_not ln_N ln_khard  int_us_mu int_oth_mu $control i.myc if (sic2!=51 & sic2!=52), rob cluster (ruref) abs(ruref)
test int_us_mu=int_oth_mu

log close


