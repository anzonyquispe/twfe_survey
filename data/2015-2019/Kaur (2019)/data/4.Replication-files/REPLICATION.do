/* This do file contains the code to replicate all the main exhibits
in Kaur, "Nominal Wage Rigidity in Village Labor Markets".

The paper uses 3 datasets, each of which is contained in this directory: 
- World Bank Climate and Agriculture data (data_wb_replication.dta)
- National Sample Survey data (data_nss_replication.dta)
- Fairness Norms Survey data collected by Kaur (data_fairness_replication.dta)

The below do-file calls each relevant dataset and shows the code to replicate
the main tables.

*/


*************** World Bank data - Main Exhibits ***************
clear
use data_wb_replication.dta

* Table 1
reg lwage i.dist i.year amons80 bmons20, cluster(regionyr)
reg lwage i.dist i.year lamons80 lbmons20, cluster(regionyr)
reg lwage i.dist i.year lamons80 lbmons20 if amons80==0 & bmons20==0, cluster(regionyr)

* Table 2
reg lwage i.dist i.year pos nonpos_neg pn pz, cluster(regionyr)
reg lwage i.dist i.year l2pos l3pos pos nonpos_neg pn pz, cluster(regionyr)

* Table 3
reg lwage i.dist i.year pos posXavginf nonpos_neg nonpos_negXavginf pn pnXavginf pz pzXavginf, cluster(regionyr)
reg lwage i.dist i.year l2pos l3pos pos posXavginf nonpos_neg nonpos_negXavginf pn pnXavginf pz pzXavginf, cluster(regionyr)
reg lwage i.dist i.year pos posXhinf nonpos_neg nonpos_negXhinf pn pnXhinf pz pzXhinf, cluster(regionyr)
reg lwage i.dist i.year l2pos l3pos pos posXhinf nonpos_neg nonpos_negXhinf pn pnXhinf pz pzXhinf, cluster(regionyr)

* Figure 2
* Distribution of nominal wage changes
histogram pctchange_n2, w(0.025) frac xtit("Percentage Change in Nominal Wage") ytit("Fraction of Observations") tit("Nominal Wage Changes")
* Distribution of real wage changes
histogram pctchange_r2, w(0.025) frac xtit("Percentage Change in Real Wage") ytit("Fraction of Observations") yscale(range(0(.05).25)) ylabel(0(.05).25) tit("Real Wage Changes")



*************** NSS data - Main Exhibits ***************
clear
use data_nss_replication.dta

* Table 1
reg lwage i.dist i.year amons80 bmons20 [w=mult*totdays], cluster(regionyr)
reg lwage i.dist i.year lamons80 lbmons20 [w=mult*totdays], cluster(regionyr)
reg lwage i.dist i.year lamons80 lbmons20 [w=mult*totdays] if amons80==0, cluster(regionyr)

* Table 2
reg lwage i.dist i.year pos nonpos_neg pn pz [w=mult*totdays], cluster(regionyr)
reg lwage i.dist i.year l2pos l3pos pos nonpos_neg pn pz [w=mult*totdays], cluster(regionyr)
reg lwage i.dist i.year l2pos l3pos pos nonpos_neg pn pz [w=mult*totdays] if usualab1==1, cluster(regionyr)
reg lwage i.dist i.year l2pos l3pos i.quarter land i.sex educ pos nonpos_neg pn pz [w=mult*totdays], cluster(regionyr)

* Table 4
* Panel A
reg agemp i.dist i.year lpos if lpc!=. [w=mult], cluster(regionyr)
reg agemp i.dist i.year l2pos l3pos lpos if lpc!=. [w=mult], cluster(regionyr)
reg agemp i.dist i.year l2pos l3pos lpc lpc_2 lpos lposXlpc if lpc!=. [w=mult], cluster(regionyr)
reg hiredemp i.dist i.year l2pos l3pos lpc lpc_2 lpos lposXlpc if lpc!=. [w=mult], cluster(regionyr)
* Panel B
reg agemp i.dist i.year pos nonpos_neg pn pz if lpc!=. [w=mult], cluster(regionyr)
reg agemp i.dist i.year l2pos l3pos pos nonpos_neg pn pz if lpc!=. [w=mult], cluster(regionyr)
reg agemp i.dist i.year l2pos l3pos lpc lpc_2 pos posXlpc nonpos_neg nonpos_negXlpc pn pnXlpc pz pzXlpc [w=mult] , cluster(regionyr)
reg hiredemp i.dist i.year l2pos l3pos lpc lpc_2 pos posXlpc nonpos_neg nonpos_negXlpc pn pnXlpc pz pzXlpc [w=mult] , cluster(regionyr)

* Table 5
reg hhagemp i.dist i.year lpc_cat_1 lpc_cat_2 lpos lposXlpc_cat_1 lposXlpc_cat_2 if amons80==0 [w=mult], cluster(regionyr)
	test lpos + lposXlpc_cat_1 = 0
reg hhlabemp i.dist i.year lpc_cat_1 lpc_cat_2 lpos lposXlpc_cat_1 lposXlpc_cat_2 if amons80==0 [w=mult], cluster(regionyr)
	test lpos + lposXlpc_cat_1 = 0
reg hhownemp i.dist i.year lpc_cat_1 lpc_cat_2 lpos lposXlpc_cat_1 lposXlpc_cat_2 if amons80==0 [w=mult], cluster(regionyr)
	test lpos + lposXlpc_cat_1 = 0


*************** Fairness survey data ***************
clear
use fairness_replication.dta

* Table 6

/* 
Notes:
This table just presents simple tabulations of the unfq* variables in the
fairness survey replication dataset (fairness_replication.dta). 

Results in the table are presented separately for workers (respondent_type=="L")
and employers (respondent_type=="F"). 

Appendix D in the Online appendices contains the questionnaire showing all 
questions asked in the survey, some of which are presented in Table 6 of 
the main paper, and others which are presented in Appendix Table 20.

Note that the variables in the dataset correspond to the question number of the
survey questionnaire (e.g. variable q1a is the response to Question 1a in the
survey questionnaire that is included in the online appendices).  

*/



