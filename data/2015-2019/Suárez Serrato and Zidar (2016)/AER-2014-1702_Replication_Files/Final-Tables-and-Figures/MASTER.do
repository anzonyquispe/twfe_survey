*Paths
global revision 		   "/Users/johnwieselthier/Desktop/Final Tables and Figures" /* Change this path to run file */
global graphpath           "$revision/out/Figures"
global tablepath           "$revision/out/Tables"
global append_graphpath    "$revision/out/Figures/Appendix"
global append_tablepath    "$revision/out/Tables/Appendix"
global CMD_tablepath	   "$revision/out/Tables/CMD" /* Structural estimates outpath */
global dopath              "$revision/do"
global dtapath             "$revision/dta"
global dumppath            "$revision/dump"		
global raw				   "$revision/raw"
	
clear
set more off

*********************************************************
*1. Construct Datasets used for Tables and Figures
*********************************************************

/*
cd "$dopath/prep"

do "build_profit_validation_annual.do"
do "build_profit_validation_decade.do"

*Table dta files:
do "prep_Table3.do"
do "prep_Table4.do"
do "prep_Table5.do"
do "prep_Table8.do"
do "prep_Appendix_Table4.do"
do "prep_Appendix_Table6.do"
do "prep_Appendix_Table7.do"
do "prep_Appendix_Table8.do"
do "prep_Appendix_Table9.do"
do "prep_Appendix_Table10.do"
do "prep_Appendix_Table11.do"
do "prep_Appendix_Table12.do"
do "prep_Appendix_Table13.do"
do "prep_Appendix_Table14.do"
do "prep_Appendix_Table15.do"
do "prep_Appendix_Table17.do"
do "prep_Appendix_Table18.do"
do "prep_Appendix_Table19.do"
do "prep_Appendix_Table20.do"
do "prep_Appendix_Table21.do"
do "prep_Appendix_Table22.do"
do "prep_Appendix_Table23.do"
do "prep_Appendix_Table24.do"
do "prep_Appendix_Table25.do"
do "prep_Appendix_Table26.do"
do "prep_Appendix_Table27.do"
do "prep_Appendix_Table28.do"
do "prep_Appendix_Table29.do"
do "prep_Appendix_Table30.do"
do "prep_Appendix_Table31.do"
do "prep_Appendix_Table34.do"
do "prep_Appendix_Table35.do"

*Figure dta files:
do "prep_Figure2.do"
do "prep_Figure3.do"
do "prep_Figure4.do"
do "prep_Appendix_Figure1.do"
do "prep_Appendix_Figure2.do"
do "prep_Appendix_Figure3.do"
do "prep_Appendix_Figure4.do"
do "prep_Appendix_Figure5.do"
do "prep_Appendix_Figure6.do"
do "prep_Appendix_Figure8.do"
do "prep_Appendix_Figure9.do"
do "prep_Appendix_Figure10.do"
do "prep_Appendix_Figure11.do"
do "prep_Appendix_Figure12.do"
do "prep_Appendix_Figure13.do"
do "prep_Appendix_Figure14.do"
do "prep_Appendix_Figure15.do"
*/


*********************************************************
*2. Tables
*********************************************************
cd "$tablepath"

do "$dopath/Table3.do"
do "$dopath/Table4.do"
do "$dopath/Table5.do" 
do "$dopath/Table8.do"

*Appendix Tables
cd "$append_tablepath"

do "$dopath/Appendix/Appendix_Table4.do"
do "$dopath/Appendix/Appendix_Table6.do"
do "$dopath/Appendix/Appendix_Table7.do"
do "$dopath/Appendix/Appendix_Table8.do"
do "$dopath/Appendix/Appendix_Table9.do"
do "$dopath/Appendix/Appendix_Table10.do"
do "$dopath/Appendix/Appendix_Table11.do"
do "$dopath/Appendix/Appendix_Table12.do"
do "$dopath/Appendix/Appendix_Table13.do"
do "$dopath/Appendix/Appendix_Table14.do"
do "$dopath/Appendix/Appendix_Table15.do" 
do "$dopath/Appendix/Appendix_Table16.do"
do "$dopath/Appendix/Appendix_Table17.do"
do "$dopath/Appendix/Appendix_Table18.do" 
do "$dopath/Appendix/Appendix_Table19.do" 
do "$dopath/Appendix/Appendix_Table20.do"
do "$dopath/Appendix/Appendix_Table21.do" 
do "$dopath/Appendix/Appendix_Table22.do" 
do "$dopath/Appendix/Appendix_Table23.do" 
do "$dopath/Appendix/Appendix_Table24.do" 
do "$dopath/Appendix/Appendix_Table25.do" 
do "$dopath/Appendix/Appendix_Table26.do" 
do "$dopath/Appendix/Appendix_Table27.do" 
do "$dopath/Appendix/Appendix_Table28.do" 
do "$dopath/Appendix/Appendix_Table29.do" 
do "$dopath/Appendix/Appendix_Table30.do" 
do "$dopath/Appendix/Appendix_Table31.do" 
do "$dopath/Appendix/Appendix_Table34.do" 
do "$dopath/Appendix/Appendix_Table35.do" 




*********************************************************
*3. Figures
*********************************************************
cd "$graphpath"

do "$dopath/Figure2.do"
do "$dopath/Figure3.do"
do "$dopath/Figure4a.do"
do "$dopath/Figure4b.do"


*Appendix Figures
cd "$append_graphpath"

do "$dopath/Appendix/Appendix_Figure1.do"
do "$dopath/Appendix/Appendix_Figure2.do"
do "$dopath/Appendix/Appendix_Figure3.do"
do "$dopath/Appendix/Appendix_Figure4.do"
do "$dopath/Appendix/Appendix_Figure5.do"
do "$dopath/Appendix/Appendix_Figure6.do"
do "$dopath/Appendix/Appendix_Figure8.do"
do "$dopath/Appendix/Appendix_Figure9.do"
do "$dopath/Appendix/Appendix_Figure10.do"
do "$dopath/Appendix/Appendix_Figure11.do"
do "$dopath/Appendix/Appendix_Figure12.do"
do "$dopath/Appendix/Appendix_Figure13.do"
do "$dopath/Appendix/Appendix_Figure14.do"
do "$dopath/Appendix/Appendix_Figure15.do"


