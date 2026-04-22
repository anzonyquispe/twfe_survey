**THIS ANALYSIS IS SIMILAR TO THAT DONE IN HOXBY AND WEINGARTH (2005) IN THAT IT INTERACTS THE FRACTION EVACUEE IN EACH QUARTILE BASED ON  2005 SCORE 
*WITH THE QUARTILE OF THE NATIVE STUDENT IN 2004 - THIS WILL ALLOW US TO TEST FOR THE EXISTENCE OF BOUTIQUE/BAD-APPLE/SHINING-LIGHT MODELS

*UNRESTRICTED VALUE-ADDED REGRESSIONS

*INSTRUMENTS FOR AVG PEER SCORE WITH KATRINA SHARE --> TEST OF LIM MODEL



clear
set mem 3g
set matsize 2000
set more off
set seed 150


***OPTIONS****


*REGRESSIONS

  cd /work/i/imberman/imberman/
  capture rm outreg_quartile_grade.txt
  capture rm outreg_quartile_grade.xls
  capture rm outreg_quartile_grade.xml


  *GENERATE AVERAGE PEER SCORE
  use hisd_data.dta, clear

  gen taks_sd_min_math_nomiss = taks_sd_min_math != .
  gen taks_sd_min_read_nomiss = taks_sd_min_read != .
  gen perc_attn_nomiss = perc_attn != .
  gen infractions_nomiss = infractions != .

  foreach var of varlist taks_sd_min_math taks_sd_min_read perc_attn infractions {
    egen `var'_sum = sum(`var'), by(campus grade year)
    egen `var'_num = sum(`var'_nomiss), by(campus grade year)
    gen `var'_peer = (`var'_sum - `var')/(`var'_num - 1) if `var' != .
  }
  keep id year *_peer
  sort id year
  save /work/i/imberman/imberman/katrina_peer.dta, replace


*LOOP OVER GRADE LEVEL
foreach grade in "elem" "midhigh" {

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

  *MERGE IN PEER DATA
  sort id year
  merge id year using /work/i/imberman/imberman/katrina_peer.dta, _merge(_mergepeer) nokeep


  *GENERATE GRADE X YEAR INTERACTIONS AND SCHOOL DUMMIES
  xi i.grade*i.year i.campus

  *DISPLAY GRADE LEVEL IN LOG FILE
  di " "
  di "`grade'"
  di " "

  *COUNTER FOR DEPENDENT VARIABLE
  local depvarid 0


  *INTERACT PEER ACHIVEMENT & EVAC SHARE W/ NATIVE QUARTILES
   foreach var of varlist taks_sd_min_math taks_sd_min_read {
      gen `var'_peer_Q1 = `var'_peer*(`var'_quartile == 1)
      gen `var'_peer_Q2 = `var'_peer*(`var'_quartile == 2)
      gen `var'_peer_Q3 = `var'_peer*(`var'_quartile == 3)
      gen `var'_peer_Q4 = `var'_peer*(`var'_quartile == 4)
  }
      gen katrina_frac_grade_math_Q1 = katrina_frac_grade*(taks_sd_min_math_quartile == 1)
      gen katrina_frac_grade_math_Q2 = katrina_frac_grade*(taks_sd_min_math_quartile == 2)
      gen katrina_frac_grade_math_Q3 = katrina_frac_grade*(taks_sd_min_math_quartile == 3)
      gen katrina_frac_grade_math_Q4 = katrina_frac_grade*(taks_sd_min_math_quartile == 4)

      gen katrina_frac_grade_read_Q1 = katrina_frac_grade*(taks_sd_min_read_quartile == 1)
      gen katrina_frac_grade_read_Q2 = katrina_frac_grade*(taks_sd_min_read_quartile == 2)
      gen katrina_frac_grade_read_Q3 = katrina_frac_grade*(taks_sd_min_read_quartile == 3)
      gen katrina_frac_grade_read_Q4 = katrina_frac_grade*(taks_sd_min_read_quartile == 4)

	*MATH

        *NO QUARTILES

        *PRE KATRINA - OLS
	reg taks_sd_min_math taks_sd_min_math_peer  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if year <= 2004 & ltaks_sd_min_math != ., cluster(campus)

        *ALL YEAR - OLS
	reg taks_sd_min_math taks_sd_min_math_peer  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if  ltaks_sd_min_math != ., cluster(campus)

        *FIRST STAGE
	reg taks_sd_min_math_peer katrina_frac_grade  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if ltaks_sd_min_math != ., cluster(campus)

	*2SLS
	ivreg taks_sd_min_math (taks_sd_min_math_peer =  katrina_frac_grade)  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if  ltaks_sd_min_math != ., cluster(campus)

        *QUARTILES

	*OLS
	reg taks_sd_min_math taks_sd_min_math_peer_*   female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_math != ., cluster(campus)
	test taks_sd_min_math_peer_Q1 = taks_sd_min_math_peer_Q2 = taks_sd_min_math_peer_Q3 = taks_sd_min_math_peer_Q4

	*FIRST STAGE
	reg taks_sd_min_math_peer_Q1 katrina_frac_grade_math_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_math != ., cluster(campus)
	reg taks_sd_min_math_peer_Q2 katrina_frac_grade_math_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_math != ., cluster(campus)
	reg taks_sd_min_math_peer_Q3 katrina_frac_grade_math_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_math != ., cluster(campus)
	reg taks_sd_min_math_peer_Q4 katrina_frac_grade_math_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_math != ., cluster(campus)

	*SECOND STAGE
	ivreg taks_sd_min_math  (taks_sd_min_math_peer_Q* = katrina_frac_grade_math_Q*)   female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_math != ., cluster(campus)
	test taks_sd_min_math_peer_Q1 = taks_sd_min_math_peer_Q2 = taks_sd_min_math_peer_Q3 = taks_sd_min_math_peer_Q4


	*READ

        *NO QUARTILES

        *PRE KATRINA - OLS
	reg taks_sd_min_read taks_sd_min_read_peer  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I* if year <= 2004  if  ltaks_sd_min_read != ., cluster(campus)

        *ALL YEAR - OLS
	reg taks_sd_min_read taks_sd_min_read_peer  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)

        *FIRST STAGE
	reg taks_sd_min_read_peer katrina_frac_grade  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)

	*2SLS
	ivreg taks_sd_min_read (taks_sd_min_read_peer =  katrina_frac_grade)  female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)

	*OLS
	reg taks_sd_min_read taks_sd_min_read_peer_*   female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)
	test taks_sd_min_read_peer_Q1 = taks_sd_min_read_peer_Q2 = taks_sd_min_read_peer_Q3 = taks_sd_min_read_peer_Q4

	*FIRST STAGE
	reg taks_sd_min_read_peer_Q1 katrina_frac_grade_read_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)
	reg taks_sd_min_read_peer_Q2 katrina_frac_grade_read_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)
	reg taks_sd_min_read_peer_Q3 katrina_frac_grade_read_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)
	reg taks_sd_min_read_peer_Q4 katrina_frac_grade_read_Q* female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*  if  ltaks_sd_min_read != ., cluster(campus)

	*SECOND STAGE
	ivreg taks_sd_min_read  (taks_sd_min_read_peer_Q* = katrina_frac_grade_read_Q*)   female ethnicit_1-ethnicit_4 econdis_2-econdis_4 _I*, cluster(campus)
	test taks_sd_min_read_peer_Q1 = taks_sd_min_read_peer_Q2 = taks_sd_min_read_peer_Q3 = taks_sd_min_read_peer_Q4
  


*CLOSE GRADELEVEL LOOP
}


