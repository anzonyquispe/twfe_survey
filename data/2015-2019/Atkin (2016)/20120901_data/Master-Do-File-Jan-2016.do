/**
This file explains how to go from the raw census and firm data to the final datasets, and then how to run the various regressions and generate the tables in the paper.
**/

*----------------------------------------------------------------------------------------------------------------------------
Starting with the Census Data (to calculate commuting-zone cohort level schooling averages for LHS of main specification):
******************************
Mcenso05_create.do
*This file takes the raw Mexican census data extract (from IPUMSI) and creates the individual dataset used to calculate commuting-zone cohort level schooling averages etc.

*This file uses 3 ipumsi data extracts with relevant variables
mexico_censo_05.dta
mexico_censo_10.dta
mexico_censo_11.dta
mexico_censo_15.dta
*which are themselves formed from:
datkin_princeton_edu_005.dat (extract from IPUMSI website)
datkin_princeton_edu_0010.dat (extract from IPUMSI website)
datkin_princeton_edu_0011.dat (extract from IPUMSI website)
datkin_princeton_edu_0015.dat (extract from IPUMSI website)
datkin_princeton_edu_005.do   (do file to convert to dta, also detailing variables in extract)
datkin_princeton_edu_0010.do  (do file to convert to dta, also detailing variables in extract) 
datkin_princeton_edu_0011.do  (do file to convert to dta, also detailing variables in extract)
datkin_princeton_edu_0015.do  (do file to convert to dta, also detailing variables in extract)

*Also uses municipality codes 
munimxchanges.do 
zonamet.dta

*Also uses industry codes
ind00_hcode_David.dta
ind90_hcode_David.dta

*The following files then calculate the actual commuting-zone cohort level schooling averages (as well as drop out rates, attendance rates, returns to school etc.) that are used as LHS variables in my main regressions. 
MCohortAveragesOnly.do
MCohortAveragesOnly_returns2schl.do
MCohortAveragesOnly_newdrops.do
MCohortAveragesOnly_forDifInDif.do
MAtgradeAverages.do
MAtschgradeAverages.do

*The following files take the census data above and create to working files, temp7.dta and temp9.dta, used for calculating various wage and schooling variables used as interactions of for descriptive statistics.
Getting temp7 full sample all years.do
Getting temp9 full sample all years.do





*----------------------------------------------------------------------------------------------------------------------------
Now moving on to Firm Data (to calculate export employment shocks for LHS of main specification):
***************************	
Mbuildingfirmdata.do
*this file takes the raw annual IMSS data acessed at ITAM, calcs1985.dta-calcs2000.dta, and saves it as a single file. The raw data procides the number of employees by gender at every IMSS registered firm on dec 31 of every year between 1984 and 1999 (matched to their industry, municipality, and a unique firm id).

MFirm_to_mun_industry.do
*this files take the imss dataset and creates large single firm export shocks. 
MFirm_to_mun_industry_cen90.do 
*the same as above but using more diaggregated industry codes that can match to 1990 census.
MFirm_to_mun_industry_herfacen90.do 
*the same as above but using the highly agglomarteade (and less highly agglomerated) industry codes used in Appendix D.

MInegi_Exporter_Merge_New.do
*This file creates similar export employment shock measures using Mexican firm census data (the EIM and EIA) obtained from Jim Tybout (84-90) and INEGI.

*All these files use a variety of inputs (in the datasets and concordance folder) 






*----------------------------------------------------------------------------------------------------------------------------
Putting Census and Firms Together
************************
MCohort_Firm_Merge_simple_loop.do
*This file takes the firm data and the MFinalReg_IndCat_genericskill***.do file and forms the reg2yr dataset that I run main regressions on.
MCohort_Firm_Merge_redo_exporters_new.do
*Same as above but for the INEGI export data and the Maquiladora data.
MFinalReg_IndCat_genericskill***.do
*These files are called by MCohort_Firm_Merge_simple_loop.do and generates the various industry aggregates to obtain aggregate shocks, and also generates skill interactions where relevant. 

*Together these files spit out the data file used Jan2016_Master_regs_cen90_final.do to run the regressions. These are of the form reg2year_mwyes_2000_july11_genericskill_xxx_1yrexp.dta depending on the xxx in the MFinalReg_IndCat_genericskill***.do file. These are:
reg2year_mwyes_2000_july11_genericskill_none_cen90_1yrexp.dta (for main specifications)
reg2year_mwyes_2000_july11_genericskill_feenstra4exppworker_cen90_1yrexp.dta (for Table 4)
reg2year_mwyes_2000_july11_genericskill_expyrbyyr_cen90_1yrexp.dta (for Table 4)
reg2year_mwyes_2000_july11_exporters_new_1516_16.dta (for Table 4)
reg2year_mwyes_2000_july11_genericskill_skillsexinitial86_cen90_1yrexp.dta (for Table 5)
reg2year_mwyes_2000_july11_genericskill_none_cen90_allyear_1yrexp.dta (for figures 4 and 5)
reg2year_mwyes_2000_july11_genericskill_alt16_cen90_1yrexp.dta (for Table 7)                     
reg2year_mwyes_2000_july11_genericskill_delta6b_cen90_1yrexp.dta (for Table 7) 
reg2year_mwyes_2000_july11_genericskill_herfa_herfacen90_1yrexp.dta (for Table 7) 

MgetDeltasbyIndMun.do
*This file get alternative datas used in Table 7 via the delta6b files above.

MGettingCohortSexIndState_skill_level_sex_onego_state.do
*This file obtains the various interactions used in Table 7 and Figure 8 (state-industry level skill measures and wages from the 1990 and 2000 census)







*----------------------------------------------------------------------------------------------------------------------------
Other files generating inputs:
************************
Mgeog_data_from_censo.do
*This generates geography data used as inputs (population,region, state etc). The census geog data I dont actually use.
Mgetting_merged_munworkmuni.do
*This is the file that works out munis where more than 10% of the population work nearbye to obtain commuting zones.
income_bymun.do 
*calculates income by municipality and saves it as muncenso_incomeZM.dta
Feenstra_to_IMSS_Data_v2.do
*Takes Mexican export data from Feenstra's website, and calculates exports per worker by industry used in Col 1 of Table 4
MMaquiladoraGeneratorData_large.do
MMaquiladora_rough_and_ready.do 
*These two files generates approximate maquialdora classification from IMSS jobs and maquiladora publications.







*----------------------------------------------------------------------------------------------------------------------------
Files Used to Run Regressions:
*********************

---------------------------------
Jan2016_Master_regs_cen90_final.do
*This do file produces all the regressions and the main figures in the paper (bar Figures 1-3 and 8, see below). The file is clearly annotated specifying whcih Table or Figure is created where in the file.

The file calls a number of other imprtant do files:
Mregs_March13_global.do
*This file compiles on the fly the appropriate dataset required to run the regressions and then runs them, with the options called in the Jan2016_Master_regs_cen90_final.do file.
Jan2016_LongChange_1990_2000.do
* This file runs the long change regressions in Table 3.
Jan2016_Heterogeneity_regs_cen90_final.do
Jan2016_Heterogeneity_regs_cen90_final_altdelta.do
Jan2016_Heterogeneity_regs_cen90_final_herfa.do
* These files produce the regressions in Table 7.
MDiff_in_diff_setup.do 
MDiff_in_diff_otheroutcomes_individual.do 
MDiff_in_diff_otheroutcomes_individual_munfe.do
* These files produce Figures 6, C.4, C.5, C.6, C.7, Table C.2, C.3, C.4 Cross Section analysis.
ageofexposure_regs.do
* This file uses coeffcients generated by teh regressions in Jan2016_Master_regs_cen90_final.do to prodcue Figures 4, 5 and 7.
---------------------------------

---------------------------------
total_jobs_graphs_maq_Jan2016.do
*This file produces Figure 1
---------------------------------

---------------------------------
Exploring_changing_skill_histograms_1990_2000.do
*This file produces Figure 2 and Figure C.2
---------------------------------

---------------------------------
Graph showing at grade at different ages.do
*This file produces Figure 3
---------------------------------

---------------------------------
MCohort_Firm_Merge_simple_skillbyind_graphs_cen90_including1990_2000Justggraphs.do
*This file produces Figure 8 and C.9
---------------------------------

---------------------------------
Graphs of industry export status.do
*This file produces Figure C.1
---------------------------------









