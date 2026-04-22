clear matrix
clear mata
clear
set more 1
set mem 1500m
set mat 800
cap log close

*** this table generates the main regression analyses in "The Collateral Channel", by Chaney et al.
***standard errors for IV regressions are bootstrapped in a separate .do file. (bootstrap.do)
/**************************************************************************************************************/
/******************************************** REGRESSION ANALYSIS	 ******************************************/
/**************************************************************************************************************/
use "../output/dataset_final",clear

***log results in reg.log
log using "../output/reg.log",append

************************************************************************************
**********Summary statistics: TABLE 1 (almost all of it)
************************************************************************************
tabstat inv inv2 inv3 inv_adj cash q leverage ltdebt_issuance ltdebt_reduction net_debt st_issuance RE_value RE_value_msa RE_value_off index_state index_msa offprice elasticity, stats(mean median sd p25 p75 n)
tabstat REAL_ESTATE0 roa age lasset if year==1993, stats(mean median sd p25 p75 n)


************************************************************************************
***INVESTMENT REGRESSIONS         ****************************************
************************************************************************************
xi: areg inv RE_value index_state yr*, a(gvkey) cl(id)
estimates store A0

xi: areg inv RE_value index_state i.ageq*index_state i.roaq*index_state i.assetq*index_state  i.state*index_state i.sic2*index_state  yr*, a(gvkey) cl(id)
estimates store A1

xi: areg inv RE_value index_state cash qm i.ageq*index_state i.roaq*index_state i.assetq*index_state i.state*index_state i.sic2*index_state  yr*, a(gvkey) cl(id)
estimates store A2

xi: areg inv RE_value_msa index_msa cash qm i.ageq*index_msa i.roaq*index_msa i.assetq*index_msa i.state*index_msa i.sic2*index_msa  yr*, a(gvkey) cl(id2)
estimates store A3

xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr*, a(gvkey) cl(id2)
estimates store A4

xi: areg inv RE_value_off_p1 offprice_p1 cash qm i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
estimates store A5

cap drop dum
gen dum=REAL_ESTATE0*offprice
xi: areg inv dum REAL_ESTATE0 offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr*, a(gvkey) cl(id2)
estimates store A6

cap drop dum
gen dum=REAL_ESTATE0*offprice_p1
xi: areg inv dum REAL_ESTATE0 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
estimates store A7

************************************************************
***************		TABLE 4				********************
************************************************************
estout A0 A1 A2 A3 A4 A5 A6 A7, cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) order(dum  RE_value RE_value_msa  RE_value_off RE_value_off_p1  offprice_p1  cash qm  offprice index_state index_msa ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************

xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr* if year<=1999, a(gvkey) cl(id2)
estimates store A8
xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr* if year>=2000, a(gvkey) cl(id2)
estimates store A9

***regression on top 20 MSAs for firms not in the top quartile of initial asset size
xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice i.state*offprice i.sic2*offprice yr* if largemsa==1&assetq~=4, a(gvkey) cl(id2)
estimates store A10

xi: areg inv2 RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr*, a(gvkey) cl(id2)
estimates store A11

xi: areg inv3 RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr* , a(gvkey) cl(id2)
estimates store A12

xi: areg inv_adj RE_value_off offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr* , a(gvkey) cl(id2)
estimates store A13

***temporarily save this dataset in temp.dta
save "../output/temp",replace

*** we can now perform regressions on the unbalanced sample.
use "../output/unbalanced", clear
***define interaction dummy of OWNER and office price
cap drop dum
gen dum=REAL_ESTATE0*offprice
xi: areg inv dum REAL_ESTATE0 offprice cash qm  i.ageq*offprice i.assetq*offprice i.roaq*offprice  i.state*offprice i.sic2*offprice yr*, a(gvkey) cl(id2)
estimates store A14

***we also perform the regression with instrumented prices -- this will be included in the table where all the specifications are re-run with instrumented prices
cap drop dum
gen dum=REAL_ESTATE0*offprice_p1
xi: areg inv dum REAL_ESTATE0 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
estimates store A22

****we now use the dataset with 10k info on headquarter ownership msaownership
**** this sample is produced by construc_msaownership.do
use "../output/msaownership", clear

*****WE FIRST PROVIDE A LINE OF DESCRIPTIVE STATISTICS
tabstat owner_10k if year==1997, stats(mean median sd p25 p75 n)

***WE THEN PROVIDE THE CROSSED TABLE ON HEADQUARTER OWNERSHIP VS. COMPUSTAT OWNERSHIP INFO (TABLE 4)
tab owner_compu owner_10k if year==1997

******we also preform the dummy regression on this sample using the 10k info
drop offprice
ren offprice_index offprice

cap drop dum
gen dum=owner_10k*offprice
xi: areg inv dum owner_10k offprice cash qm i.ageq*offprice i.roaq*offprice i.assetq*offprice i.state*offprice i.sic2*offprice yr*, a(gvkey) cl(id)
estimates store A15

************************************************************
***************		TABLE 6 				 ***************
************************************************************
estout A8 A9 A10 A11 A12 A13 A14 A15 , cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(dum RE_value_off offprice  cash qm ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************

***we also perform the regression with instrumented prices -- this will be included in the table where all the specifications are re-run with instrumented prices
cap drop dum
gen dum=owner_10k*offprice_p1
xi: areg inv dum owner_10k offprice_p1 cash qm i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1 i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id)
estimates store A23

****we now re-do this previous robustness table using only instrumented prices
use "../output/temp", clear

***we redo the robustness check table with the instruments.
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr* if year<=1999, a(gvkey) cl(id2)
estimates store A16
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr* if year>=2000, a(gvkey) cl(id2)
estimates store A17
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr* if largemsa==1&assetq~=4, a(gvkey) cl(id2)
estimates store A18
xi: areg inv2 RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
estimates store A19
xi: areg inv3 RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
estimates store A20
xi: areg inv_adj RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.assetq*offprice_p1 i.roaq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1 yr*, a(gvkey) cl(id2)
estimates store A21

************************************************************
***************		APPENDIX TABLE 6		 ***************
************************************************************
estout A16 A17 A18 A19 A20 A21 A22 A23, cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(dum RE_value_off_p1 offprice_p1  cash qm ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************

**********************************************************************************
**********************ex ante credit constraints and the sensitivity of **********
*********************   investment to real estate prices *************************
**********************************************************************************

****three definitions of credit constraint: (1) dividend payout (2) size (3) bond rating when debt. 
****using office prices

****constraint1
xi: areg inv RE_value_off offprice cash qm i.ageq*offprice i.roaq*offprice i.assetq*offprice    i.state*offprice i.sic2*offprice  yr* if constraint1==1, a(gvkey) cl(id2)
estimates store B0
xi: areg inv RE_value_off offprice cash qm i.ageq*offprice i.roaq*offprice i.assetq*offprice  i.state*offprice i.sic2*offprice  yr* if constraint1==0, a(gvkey) cl(id2)
estimates store B1


****constraint2
xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.roaq*offprice i.assetq*offprice  i.state*offprice i.sic2*offprice  yr* if constraint2==1, a(gvkey) cl(id2)
estimates store B2
xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.roaq*offprice i.assetq*offprice  i.state*offprice i.sic2*offprice  yr* if constraint2==0, a(gvkey) cl(id2)
estimates store B3

****constraint3
xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.roaq*offprice i.assetq*offprice  i.state*offprice i.sic2*offprice  yr* if constraint3==1, a(gvkey) cl(id2)
estimates store B4
xi: areg inv RE_value_off offprice cash qm  i.ageq*offprice i.roaq*offprice i.assetq*offprice i.state*offprice i.sic2*offprice  yr* if constraint3==0, a(gvkey) cl(id2)
estimates store B5


***to get the significance of the difference
xi: areg inv i.constraint1*RE_value_off i.constraint1*offprice i.constraint1*cash i.constraint1*qm   cont3_qage* cont3_qasset* cont3_qroa* cont3_ind* cont3_st* const1_cont3*   yr*, a(ident1) cl(id2)
xi: areg inv i.constraint2*RE_value_off i.constraint2*offprice i.constraint2*cash i.constraint2*qm   cont3_qage* cont3_qasset* cont3_qroa* cont3_ind* cont3_st* const2_cont3*   yr*, a(ident2) cl(id2)
xi: areg inv i.constraint3*RE_value_off i.constraint3*offprice i.constraint3*cash i.constraint3*qm   cont3_qage* cont3_qasset* cont3_qroa* cont3_ind* cont3_st* const3_cont3*   yr*, a(ident3) cl(id2)

estout B0 B1 B2 B3 B4 B5  , cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(RE_value_off offprice cash qm ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)

***as a robustness, we also perform the same test using instrumented prices

****constraint1
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint1==1, a(gvkey) cl(id2)
estimates store BB0
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint1==0, a(gvkey) cl(id2)
estimates store BB1

****constraint2m

xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint2==1, a(gvkey) cl(id2)
estimates store BB2
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint2==0, a(gvkey) cl(id2)
estimates store BB3

****constraint3m

xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint3==1, a(gvkey) cl(id2)
estimates store BB4
xi: areg inv RE_value_off_p1 offprice_p1 cash qm  i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice_p1 i.sic2*offprice_p1  yr* if constraint3==0, a(gvkey) cl(id2)
estimates store BB5

************************************************************
***************		TABLE 7 				 ***************
************************************************************
estout BB0 BB1 BB2 BB3 BB4 BB5  , cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(RE_value_off_p1 offprice_p1 cash qm ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************

****to get the significance of the difference between constrained and unconstrained
renpfix p_const1_cont3 CO1
renpfix p_const2_cont3 CO2
renpfix p_const3_cont3 CO3
xi: areg inv i.constraint1*RE_value_off_p1 i.constraint1*offprice_p1 i.constraint1*cash i.constraint1*qm   p_cont3_qage* p_cont3_qasset* p_cont3_qroa* p_cont3_ind* p_cont3_st* CO1*  yr*, a(ident1) cl(id2)
xi: areg inv i.constraint2*RE_value_off_p1 i.constraint2*offprice_p1 i.constraint2*cash i.constraint2*qm   p_cont3_qage* p_cont3_qasset* p_cont3_qroa* p_cont3_ind* p_cont3_st* CO2*  yr*, a(ident2) cl(id2)
xi: areg inv i.constraint3*RE_value_off_p1 i.constraint3*offprice_p1 i.constraint3*cash i.constraint3*qm   p_cont3_qage* p_cont3_qasset* p_cont3_qroa* p_cont3_ind* p_cont3_st* CO3*  yr*, a(ident3) cl(id2)

**********************************************************************************
**********************CAPITAL STRUCTURE REGRESSIONS	*****************************
**********************************************************************************

xi: areg ltdebt_issuance RE_value_off offprice i.ageq*offprice i.roaq*offprice i.assetq*offprice   i.state*offprice i.sic2*offprice  yr*, a(gvkey) cl(id2)
estimates store C1
xi: areg ltdebt_reduction RE_value_off offprice i.ageq*offprice i.roaq*offprice i.assetq*offprice   i.state*offprice i.sic2*offprice  yr*, a(gvkey) cl(id2)
estimates store C2
xi: areg net_debt RE_value_off offprice i.ageq*offprice i.roaq*offprice i.assetq*offprice  i.state*offprice i.sic2*offprice  yr*, a(gvkey) cl(id2)
estimates store C3
xi: areg deltaltdebt RE_value_off offprice i.ageq*offprice i.roaq*offprice i.assetq*offprice  i.state*offprice i.sic2*offprice  yr*, a(gvkey) cl(id2)
estimates store C4
xi: areg st_issuance RE_value_off offprice i.ageq*offprice i.roaq*offprice i.assetq*offprice   i.state*offprice i.sic2*offprice  yr*, a(gvkey) cl(id2)
estimates store C5

************************************************************
***************		TABLE 8 				 ***************
************************************************************
estout C1 C2 C3 C4 C5  , cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(RE_value_off offprice ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************

****using instrumented prices
xi: areg ltdebt_issuance RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id2)
estimates store CC1
xi: areg ltdebt_reduction RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id2)
estimates store CC2
xi: areg net_debt RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1  i.state*offprice i.sic2*offprice_p1  yr*, a(gvkey) cl(id2)
estimates store CC3
xi: areg deltaltdebt RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id2)
estimates store CC4
xi: areg st_issuance RE_value_off_p1 offprice_p1 i.ageq*offprice_p1 i.roaq*offprice_p1 i.assetq*offprice_p1   i.state*offprice_p1 i.sic2*offprice_p1  yr*, a(gvkey) cl(id2)
estimates store CC5

************************************************************
***************		APPENDIX TABLE 8		 ***************
************************************************************
estout CC1 CC2 CC3 CC4 CC5  , cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep(RE_value_off_p1 offprice_p1 ) stats(N ar2) starlevels(* 0.104 ** 0.054 *** .014) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************

tab assetq, gen(qsset)
tab roaq, gen(qqroa)
tab ageq, gen(qqage)

**********************************************************************************************
**********************DETERMINANT OF RE OWNERSHIP ********************************************
**********************************************************************************************
xi: areg REAL_ESTATE0 qsset2-qsset5  qqroa2-qqroa5 qqage2-qqage5 st1* st2* st3* st4* st5* st6* st7* st8* st9* if year==1993, a(sic2)
estimates store E1
xi: areg RE_value qsset2-qsset5  qqroa2-qqroa5 qqage2-qqage5 st1* st2* st3* st4* st5* st6* st7* st8* st9* if year==1993, a(sic2)
estimates store E2

************************************************************
***************		TABLE 2					 ***************
************************************************************
estout E1 E2, cells(b(fmt(%9.2g) star) t(fmt(%9.2g) par)) keep( qsset* qqroa* qqage* ) stats(N ar2) starlevels(* 0.10 ** 0.05 *** .01) delimiter(&) end(\\) label style(tex)
************************************************************
************************************************************
log close

erase "../output/temp.dta"





