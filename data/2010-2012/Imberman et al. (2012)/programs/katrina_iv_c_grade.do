*RUNS FIRST-STAGE & REDUCED FORM REGRESSIONS USING VARIOUS INSTRUMENT CANDIDATES


clear
set mem 3g
set matsize 2000
set more off

*REGRESSIONS

*USE DELIMITER TO ALLOW COMMANDS TO SPREAD LINES
# delimit ;


*OPEN UP FILE THAT WILL COLLECT REGRESSION RESULTS INTO A DATASET;
  postfile ivregs int(gradelevel reg depvarid indepvarid) 
	str40 (grade regdesc depvar indepvar instrument statname) 
	float(stat tstat obs) 
	using /work/i/imberman/imberman/postfiles/ivregs.dta, replace;


*COUNTERS ALLOW ME TO GENERATE UNIQUE IDENTIFIERS FOR EACH REGRESSION THAT CAN LATER BE SORTED IN A WAY THAT IS EASILY TRANSFERABLE TO EXCEL DATA TABLES;
*COUNTER FOR GRADE LEVEL;
local gradenum 0;

*LOOP OVER GRADE LEVEL;
foreach grade in "elem" "midhigh"{;

  *INCREASE COUNTER FOR GRADELEVEL (1 = ELEM, 2 = MIDHIGH);
  local gradenum = `gradenum' + 1;

  *OPEN TEMPORARY DATAFILE SAVED EARLIER IN PROGRAM;
  use /work/i/imberman/imberman/katrina_data.dta, clear;

  *OPTION TO TAKE RANDOM SAMPLE FOR PROGRAM TESTING;
  *set seed 300083;
  *gsample 5, percent wor cluster(id);

  *KEEP ONLY GRADE LEVEL BEING ANALYSED IN SAMPLE;
  keep if `grade' == 1;

  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES;
  xi i.grade*i.year i.campus;

  *DISPLAY GRADE LEVEL IN LOG FILE;
  di " ";
  di "`grade'";
  di " ";

  *COUNTER FOR DEPENDENT VARIABLE;
  local depvarid 0;

  *LOOP OVER DEPENDENT VARIABLES;
  foreach subject of varlist taks_sd_min_math taks_sd_min_read perc_attn infrac {;
    
	*INCREASE COUNTER FOR DEPENDENT VARIABLE;
	local depvarid = `depvarid' + 1;

	*OLS
		*DISPLAY REGRESSION TYPE IN LOG FILE;
    		di " " ;
    		di "OLS - ZONED";
    		di " ";

		*CONDUCT REGRESSION;
		reg `subject' katrina_frac_grade female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*, cluster(campus);
		
    		*REGRESSION TYPE COUNTER;
	    	local reg 1;
 
	*2SLS - COMBINED INSTRUMETNS - USE ALL 3 INSTRUMENTS TOGETHER;
	
		local indepvarid 0;
		local instrument "katrina_frac_noRGB_9_13_05";
		local reg = `reg' + 1;

		di " ";
        	di "`instrument'";
        	di " ";

		*FIRST STAGE;
      			
			di " " ;
      			di "first stage";
      			di " ";
      			reg katrina_frac_grade `instrument' female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `subject' !=., cluster(campus);

			*F-TEST OF JOINT SIGNIFICANCE OF EXCLUDED INSTRUMENTS;
			test `instrument';

		*SECOND STAGE - USE IVREG2 TO GET TEST OF ENDOGENEITY OF THE OLS ESTIMATES;
			
			di " ";
	      		di "2SLS";
      			di " ";

			local reg = `reg' + 1;

      			ivreg2 `subject' (katrina_frac_grade = `instrument') female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*, 
				cluster(campus) noid endog(katrina_frac_grade) partial(_I*) small;



  *CLOSE DEPVAR LOOP;
  };

*CLOSE GRADELEVEL LOOP;
};
