************************************************************************
***************SETUP CODE HEADER FOR ALL PROGRAMS***********************
************************************************************************
clear
clear matrix
clear mata
cap log close

global root "$dbroot/India Power Shortages/"
include "$root/02. Programs/00_Set_paths.do"
************************************************************************
************************************************************************
************************************************************************

use "$intdata/ASIpanel_fulldataset_Nov2014.dta",clear

replace state="BIHAR" if state=="JHARKHAND" & year<=2001
replace state="MADHYA PRADESH" if state=="CHHATTISGARH" & year<=2001
replace state="UTTAR PRADESH" if state=="UTTARANCHAL" & year<=2001

merge m:1 state year using "$work/PDPM-PSP Merged.dta", keep(match master) keepusing(Shortage PeakShortage) nogen

*keep if scheme_final==1
g gamma=(qeleccons * Rs_kWh)/(grsale_nominal)
g gamma_g=gamma/(1+SGS)
g gamma_s=2*gamma_g
rename Shortage delta_PSP
rename PeakShortage delta_PDPM
rename mshare_CD alpha_m
rename lshare_CD alpha_l
rename eshare_final alpha_e
rename betak_CDnoCRS alpha_K
rename lnW_M_fuels_noSG OMEGA
rename lnK K


*add other K coefficients
decode snic, g(snic_HC)
g zero_selfgen_flag=qelecprod==0 |  qelecprod==.
replace totpersons=totemp if totpersons==. & totemp!=. 

 keep ///
 alpha*  ///
 OMEGA K ///
 delta* ///
 gamma* ///
 zero_selfgen_flag state year snic_HC scheme_final panelgroup ///
 grsale_defl fcapclose_defl  totpersons matls_defl qeleccons mult ///
 anyyearEprod investment_rate
 
 g exog_gen_industry = ""
 repl_conf  exog_gen_industry = "sugar" if snic_HC=="206"
 repl_conf  exog_gen_industry = "sugar" if snic_HC=="207"
 repl_conf  exog_gen_industry = "chemicals" if substr(snic_HC,1,2)=="30"
 repl_conf  exog_gen_industry = "petroleum&petroleum_products" if snic_HC=="314"
 repl_conf  exog_gen_industry = "petroleum&petroleum_products" if snic_HC=="315"
 repl_conf  exog_gen_industry = "petroleum&petroleum_products" if snic_HC=="316317"
 repl_conf  exog_gen_industry = "pulp&paper" if snic_HC=="281"
 repl_conf  exog_gen_industry = "pulp&paper" if snic_HC=="282"
 repl_conf  exog_gen_industry = "pulp&paper" if snic_HC=="283"
 
 order state year snic exog_gen_industry scheme_final panelgroup ///
 grsale_defl fcapclose_defl  totpersons matls_defl qeleccons mult
 
 
drop if delta_PSP==. | delta_PDPM==.
g p=1
g p_m=1
g p_l=1

forval i = 1992(1)2010 {
preserve
keep if year==`i'
outsheet using "$root/matlab/simulation_asi_inputs_dec2014/ASIpanelfields_forsimulation_`i'.csv", comma names replace
restore
}
