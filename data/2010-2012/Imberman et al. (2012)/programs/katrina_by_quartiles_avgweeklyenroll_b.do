
*UNRESTRICTED VALUE-ADDED REGRESSIONS

***IDENTIFY AN EVACUEE EFFECT AND SEPARATE DISRUPTION EFFECT

***USE VARIANCE IN WEEKLY ENROLLMENT RELATIVE TO SNAPSHOT ENROLLMENT AS MEASURE OF DISRUPTION
***NEED TO USE SCHOOL LEVEL ENROLLMENT AS GRADE IS UNOBSERVED FOR STUDENTS ENTERING AFTER SNAPSHOT DATE***


clear
set mem 3g
set matsize 2000
set more off

set seed 105253

***OPTIONS****



  cd /work/i/imberman/imberman/

*GENERATE DATASET WITH DISRUPTION DATA

    
    use /work/i/imberman/imberman/hisd_data.dta, clear
    keep if year >= 2003
    drop if enter_date == "000000"
    gen entry = date(enter_date, "MD20Y")
    format entry %td
    drop if entry == .
    gen leave = date(leave_date, "MD20Y")
    format leave %td
   
   
    *DROP OBS THAT APPEAR TO HAVE INCORRECT DATA 
    drop if year == 2003 & year(entry) > 2004
    drop if year == 2004 & year(entry) > 2005
    drop if year == 2005 & (year(entry) > 2006 | (year(entry) == 2006 & month(entry) == 7))
    drop if year == 2006 & (year(entry) > 2007 | (year(entry) == 2007 & month(entry) == 8))
 
    *DROP OBS WHERE ENTRY DATE IS PRIOR TO START OF SCHOOL YEAR
    drop if entry < date("081803", "MD20Y") & year == 2003
    drop if entry < date("081604", "MD20Y") & year == 2004
    drop if entry < date("081504", "MD20Y") & year == 2005
    drop if entry < date("080706", "MD20Y") & year == 2006

    ****NOTE THAT THERE SEEMS TO BE SOME ERROR WITH THE 2006 DATA AS A LOT OF ENTRY IS LISTED AS PRIOR YEAR
    ****MY DECISION WAS TO DROP THESE OBSERVATIONS, HOWEVER I NEED TO CHECK IN REGRESSIONS THAT DROP 2006 TO MAKE SURE THIS NOT A CONCERN
  

    *GENERATE WEAKLY ENROLLMENT FIGURES FOR BOTH REGULAR & EVACUEES
    replace katrina = 0 if year < 2005
    # delimit ;
    forvalues week = 33/50 {;
	local week_ay = `week' - 32;
	gen byte week_`week_ay' = 0;
        replace week_`week_ay' = 1 if entry < date("081803", "MD20Y") + 7*`week_ay' & year == 2003 & 
		(leave >= date("081803","MD20Y") + 7*`week_ay' | leave == .);
        replace week_`week_ay' = 1 if entry < date("081604", "MD20Y") + 7*`week_ay' & year == 2004 &
		(leave >= date("081604","MD20Y") + 7*`week_ay' | leave == .);
        replace week_`week_ay' = 1 if entry < date("081505", "MD20Y") + 7*`week_ay' & year == 2005 &
		(leave >= date("081505","MD20Y") + 7*`week_ay' | leave == .);
        replace week_`week_ay' = 1 if entry < date("081406", "MD20Y") + 7*`week_ay' & year == 2006 &
		(leave >= date("081406","MD20Y") + 7*`week_ay' | leave == .);
	gen katrina_week_`week_ay' = week_`week_ay'*katrina;
   };
    forvalues week = 1/21 {;
	local week_ay = `week' + 18;
	gen byte week_`week_ay' = 0;
        replace week_`week_ay' = 1 if entry < date("081803", "MD20Y") + 7*`week_ay' & year == 2003 & 
		(leave >= date("081803","MD20Y") + 7*`week_ay' | leave == .);
        replace week_`week_ay' = 1 if entry < date("081604", "MD20Y") + 7*`week_ay' & year == 2004 &
		(leave >= date("081604","MD20Y") + 7*`week_ay' | leave == .);
        replace week_`week_ay' = 1 if entry < date("081505", "MD20Y") + 7*`week_ay' & year == 2005 &
		(leave >= date("081505","MD20Y") + 7*`week_ay' | leave == .);
        replace week_`week_ay' = 1 if entry < date("081406", "MD20Y") + 7*`week_ay' & year == 2006 &
		(leave >= date("081406","MD20Y") + 7*`week_ay' | leave == .);
	gen katrina_week_`week_ay' = week_`week_ay'*katrina;
   };
# delimit cr
   


*COLLAPSE TO CAMPUS YEAR GRADE DATASET
  replace katrina = 0 if year < 2005
  collapse (sum) week_* katrina_week_*, by(campus year grade)
 
  *REPLACE WEEKLY KATRINA COUNT W/ WEEKLY KATRINA SHARE
  egen avg_weekly_enr = rmean(week_*)
  forvalues week = 1/39 {
   replace katrina_week_`week' = katrina_week_`week'/week_`week'
   gen rel_weekly_enr_`week' = week_`week'/avg_weekly_enr
  }

  egen avg_katrina_weekly_enr = rmean(katrina_week_*)
  egen sd_weekly_enr = rsd(week_*)
  egen sd_rel_weekly_enr = rsd(rel_weekly_enr_*)
  egen sd_katrina_weekly_enr = rsd(katrina_week_*)
  sort campus grade year
  save /work/i/imberman/imberman/weekly_enrollment.dta, replace

*LOOP OVER GRADE LEVEL
foreach grade in "elem" "midhigh"{

  *INCREASE COUNTER FOR GRADELEVEL (1 = ELEM, 2 = MIDHIGH)
  local gradenum = `gradenum' + 1

  *OPEN KATRINA DATA
  use /work/i/imberman/imberman/katrina_data.dta, clear
  xtset id year

  *GENEARATE TEST SCORE LAGS FROM PRE-KATRINA YEARS
  foreach var of varlist taks_sd_min_math taks_sd_min_read perc_attn infractions {
  gen l`var' = .
  gen lagyears_`var' = .
  foreach lag of numlist 1/5 {
    replace lagyears_`var' = `lag' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2004
    replace l`var' = l`lag'.`var' if l`var' == . & l`lag'.`var' != . & l`lag'.year <= 2004
  }
  tab lagyears_`var', gen(lagyears_`var'_)
  forvalues gap = 1/4 {
    gen l`var'_`gap' = lagyears_`var'_`gap'*l`var'
  }
  }


  *MERGE IN WEEKLY ENROLLMENT DATA
  sort campus grade year
  drop _merge
  merge campus grade year using /work/i/imberman/imberman/weekly_enrollment.dta, keep(avg* sd*) nokeep
  xtset id year

  *KEEP ONLY GRADE LEVEL BEING ANALYSED IN SAMPLE
  keep if `grade' == 1
  
  *MERGE IN KATRINA MEDIAN DATA & QUARTILE DATA
  capture drop katrina*median*
  /*
  sort campus year
  merge campus year using /work/i/imberman/imberman/katrina_medians.dta, _merge(_mergekatmedian) nokeep
  foreach var of varlist katrina_frac_* katrina_count_* {
    replace `var' = 0 if `var' == .
  }
  */
  sort id year
  merge id year using /work/i/imberman/imberman/pre_katrina_quartiles.dta, _merge(_mergequartile) nokeep


  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES
  xi i.grade*i.year i.campus

  *DISPLAY GRADE LEVEL IN LOG FILE
  di " "
  di "`grade'"
  di " "

  di ""
  di "POOLED LINEAR MODEL"
  di ""

  # delimit ;


  foreach var of varlist taks_sd_min_math taks_sd_min_read {;

	capture drop avgenr_`var'.txt;
	capture drop avgenr_`var'.xls;
	capture drop avgenr_`var'.xml;

	*OLS KATRINA ONLY;
	reg `var' avg_katrina_weekly_enr  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != . & `var'_quartile != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',OLS-Mean, ALL");

	 	*LOOP OVER QUARTILES;
	 	foreach quartile of numlist 1/4 {;
 
	  	di "" ;
	  	di "QUARTILE `quartile'";
	  	di "";

		reg `var' avg_katrina_weekly_enr  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var' != . & `var'_quartile == `quartile', cluster(campus);
		outreg2 avg_katrina_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',OLS-Mean, Quartile `quartile'");
		};



        *OLS KATRINA & SD ENROLL;
  	reg `var' avg_katrina_weekly_enr sd_rel_weekly_enr  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != . & `var'_quartile != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr sd_rel_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',OLS-Mean&SD, All");

 
	 	*LOOP OVER QUARTILES;
	 	foreach quartile of numlist 1/4 {;
 
	  	di "" ;
	  	di "QUARTILE `quartile'";
	  	di "";

	 	reg `var' avg_katrina_weekly_enr  sd_rel_weekly_enr l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var' != . & `var'_quartile == `quartile', cluster(campus);
		outreg2 avg_katrina_weekly_enr sd_rel_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',OLS-Mean&SD, Quartile `quartile'");
		};


	*FIRST STAGE;
	reg sd_rel_weekly_enr avg_katrina_weekly_enr sd_katrina_weekly_enr l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != . & `var'_quartile != ., cluster(campus);
	outreg2  sd_katrina_weekly_enr avg_katrina_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',FS-Mean&SD, All");

	
	 	*LOOP OVER QUARTILES;
	 	foreach quartile of numlist 1/4 {;
 
	  	di "" ;
	  	di "QUARTILE `quartile'";
	  	di "";
		reg sd_rel_weekly_enr sd_katrina_weekly_enr  avg_katrina_weekly_enr l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var' != . & `var'_quartile == `quartile', cluster(campus);
		outreg2 sd_katrina_weekly_enr avg_katrina_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',FS-Mean&SD, Quartile `quartile'");	
		};


	*2SLS;
	ivreg `var' avg_katrina_weekly_enr ( sd_rel_weekly_enr = sd_katrina_weekly_enr)  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var'_quartile != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr sd_rel_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',SS-Mean&SD, All");

	 	*LOOP OVER QUARTILES;
	 	foreach quartile of numlist 1/4 {;
 
	  	di "" ;
	  	di "QUARTILE `quartile'";
	  	di "";
		ivreg `var' avg_katrina_weekly_enr ( sd_rel_weekly_enr = sd_katrina_weekly_enr)  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  
			if `var' != . & `var'_quartile == `quartile', cluster(campus);
		outreg2 avg_katrina_weekly_enr sd_rel_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',SS-Mean&SD, Quartile `quartile'");
		};


  };
 
  foreach var of varlist perc_attn infractions{;

	capture drop avgenr_`var'.txt;
	capture drop avgenr_`var'.xls;

	*OLS KATRINA ONLY;
	reg `var' avg_katrina_weekly_enr  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',OLS-Mean, ALL");


        *OLS KATRINA & SD ENROLL;
  	reg `var' avg_katrina_weekly_enr sd_rel_weekly_enr  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr sd_rel_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',OLS-Mean&SD, All");

	*FIRST STAGE;
	reg sd_rel_weekly_enr avg_katrina_weekly_enr sd_katrina_weekly_enr l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != ., cluster(campus);
	outreg2  sd_katrina_weekly_enr avg_katrina_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',FS-Mean&SD, All");


	*2SLS;
	ivreg `var' avg_katrina_weekly_enr ( sd_rel_weekly_enr = sd_katrina_weekly_enr)  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*, cluster(campus);
	outreg2 avg_katrina_weekly_enr sd_rel_weekly_enr using avgenr_`var', excel dec(2) ctitle("`var',SS-Mean&SD, Quartile `quartile'");
};
 

*CLOSE GRADELEVEL LOOP;
};


