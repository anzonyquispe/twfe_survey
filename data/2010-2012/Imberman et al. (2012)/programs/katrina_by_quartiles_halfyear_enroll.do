
*UNRESTRICTED VALUE-ADDED REGRESSIONS

***IDENTIFY AN EVACUEE EFFECT AND SEPARATE DISRUPTION EFFECT

***THIS MODEL USES THE AVERAGE WEEKLY EVACUEE SHARE BUT INSTEAD OF ALSO CONTROLLING FOR STANDARD DEVIATION IN EVACUEE SHARE 
***WE CONTROL FOR 1ST HALF EVAC ENTRIES AS A SHARE OF ENROLLMENT & 2ND HALF EVAC ENTRIES AS A SHARE OF ENROLLMENT


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

   *IDENTIFY WHETHER EVACUEE ENTERS IN 1ST OR 2ND HALF OF YEAR;
   gen sem1_entry = 0
   replace sem1_entry = 1  if  entry >=  date("080103","MD20Y") & entry < date("010104","MD20Y") & year == 2003
   replace sem1_entry = 1  if  entry >=  date("080104","MD20Y") & entry < date("010105","MD20Y") & year == 2004
   replace sem1_entry = 1  if  entry >=  date("080105","MD20Y") & entry < date("010106","MD20Y") & year == 2005
   replace sem1_entry = 1  if  entry >=  date("080106","MD20Y") & entry < date("010107","MD20Y") & year == 2006


   gen sem2_entry = 0
   replace sem2_entry = 1  if  entry >=  date("010104","MD20Y") & entry < date("080104","MD20Y") & year == 2003
   replace sem2_entry = 1  if  entry >=  date("010105","MD20Y") & entry < date("080105","MD20Y") & year == 2004
   replace sem2_entry = 1  if  entry >=  date("010106","MD20Y") & entry < date("080106","MD20Y") & year == 2005
   replace sem2_entry = 1  if  entry >=  date("010107","MD20Y") & entry < date("080107","MD20Y") & year == 2006

   


*COLLAPSE TO CAMPUS YEAR GRADE DATASET
  replace katrina = 0 if year < 2005

   *IDENTIFY EVACUEES WITH GIVEN ENTRY TIMES
   gen sem1_entry_kat = sem1_entry*katrina
   gen sem2_entry_kat = sem2_entry*katrina


  collapse (sum) week_* katrina_week_* (mean) sem*entry*kat, by(campus year grade)
 
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
  merge campus grade year using /work/i/imberman/imberman/weekly_enrollment.dta, keep(avg* sd* sem*) nokeep
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

	capture drop semenr.txt;
	capture drop semenr.xls;
	capture drop semenr.xml;

  	reg `var' avg_katrina_weekly_enr sem1_entry_kat sem2_entry_kat  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != . & `var'_quartile != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr sem1_entry_kat sem2_entry_kat using semenr, excel dec(2) ctitle("`var',`grade', All");

 
	 	*LOOP OVER QUARTILES;
	 	foreach quartile of numlist 1/4 {;
 
	  	di "" ;
	  	di "QUARTILE `quartile'";
	  	di "";

	 	reg `var' avg_katrina_weekly_enr  sem1_entry_kat sem2_entry_kat l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* 
			if `var' != . & `var'_quartile == `quartile', cluster(campus);
		outreg2 avg_katrina_weekly_enr  sem1_entry_kat sem2_entry_kat using semenr, excel dec(2) ctitle("`var',`grade', Quartile `quartile'");
		};


  };
 
  foreach var of varlist perc_attn infractions{;

	capture drop semenr.txt;
	capture drop semenr.xls;


        *OLS KATRINA & SD ENROLL;
  	reg `var' avg_katrina_weekly_enr  sem1_entry_kat sem2_entry_kat  l`var'_* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if `var' != ., cluster(campus);
	outreg2 avg_katrina_weekly_enr  sem1_entry_kat sem2_entry_kat using semenr, excel dec(2) ctitle("`var',`grade', All");

};
 

*CLOSE GRADELEVEL LOOP;
};


