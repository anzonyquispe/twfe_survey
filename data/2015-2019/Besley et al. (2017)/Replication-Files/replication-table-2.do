
***** Municipal public finances************
use "\\micro.intra\Projekt\P0624$\P0624_Gem\Data Extraction and Files\Data files\financial outcomes.dta", clear

*define electionperiod variable, exclude election years 
replace electionyear=1998 if year==1999 |year==2000 |year==2001 
replace electionyear=2002 if year==2003 |year==2004 |year==2005 
replace electionyear=2006 if year==2007 |year==2008 |year==2009 
replace electionyear=2010 if year==2011 |year==2012 |year==2013
ren sol_incpens_kon solvency 
* Average levels excluding election years
	collapse (mean) result solvency, by(electionyear m_id)
	bysort : egen avg_result = mean() if period !=.
	bysort electionyear m_id: egen avg_sol = mean() if period !=.

	* Generate categorical variables for economic performance
	gen res123 = 1 if result<=1
	replace res123 = 2 if result>1 & 	result<=2
	replace res123 = 3 if result>2 & result!=.
	sum final_solavg
	*drop sol123
	gen sol123 = 1 if solvency<=0
	replace sol123 = 2 if solvency>0 & 	solvency<=20
	replace sol123 = 3 if solvency>20 & solvency!=.
	bysort year: tab sol123
	
	* the sum of the two is the combined score
	gen solres2_6 = sol123+res123
	
	
	*keep relevant variables
	keep solres2_6  final_solavg final_resavg m_id electionyear
	save economic_outcomes, replace

	*Open data set with survey data on citizen satisfaction
	use "municipal service quality.dta", clear

	* define electionperiods
	
	gen  electionyear=2002 if year==2004 |year==2005 |year==2006
	replace electionyear=2006 if year==2007 |year==2008 |year==2009 |year==2010
	replace electionyear=2010 if year==2011 |year==2012 |year==2013 |year==2014
	
	ren m_visatvrdenojd_med_hel happy_total
	ren kommunkod m_id
	
	*measure average for electionperiod
		collapse (mean) happy_total, by(m_id electionyear)
	
	tsset m_id electionyear
	tsfill, full
	
	save satisfaction.dta, replace
	
	*Open complaints data
	
	use "complaint data.dta", clear
	
	*define electionperiod variable
	gen  electionyear=1994 if year==1995 |year==1996 |year==1997|year==1998
	replace electionyear=1998 if year==1999 |year==2000 |year==2001 |year==2002
	replace electionyear=2002 if year==2003 |year==2004 |year==2005 |year==2006
	replace electionyear=2006 if year==2007 |year==2008 |year==2009 |year==2010
	replace electionyear=2010 if year==2011 |year==2012 |year==2013
	drop if electionyear ==.
	
	ren kommunkod m_id
	ren critique no_crit
	**if there is an obsrvation there is also an complain, define indicator for a complaint
	gen no_complaints=1

	*measure the number of complaints and critiques in each electionperiod
	collapse (sum) no_crit no_complaints, by(m_id electionyear)
	
	tsset m_id electionyear
	tsfill, full

*define Swedish variables to allow matching with population data
	gen valar=electionyear
	gen llkk = m_id
	
	joinby valar llkk using "kommundata.dta", unmatched(both)
	drop if _merge==2
	
	***meausre complaints per capita
	gen crit_pop = no_crit/befolkning
	gen compl_pop = no_complaints/befolkning

	*keep relevant variables
	keep  crit_pop compl_pop electionyear m_id
	save complaints, replace
 
	
 *** open file with political data********************
use "politicians.dta" , clear

*join with competence measure
joinby p_id using "\\micro.intra\projekt\P0624$\P0624_Gem\Data Extraction and Files\Data files\income residual.dta", unmatched(master) _merge(_merge2)


gen electionyear=ar
ren vald elected


keep if elected ==1

*normalize income residual within each part and define dummy for being above party median
foreach var in inc_res {

gen `var'_nom=.
foreach parti in S V M C K G F{
egen `var'_nom_b=std(`var') if parti_initial =="`parti'"
replace `var'_nom= `var'_nom_b if parti_initial =="`parti'"
drop `var'_nom_b
}
gen `var'_d= `var'_nom>0 if  `var'_nom!=. 
}

*keep only chair party
keep if chair_party==1

*define dummy for being in top_3
gen top3=rank_ind<=3 if rank_ind!=.

*define competence variables used in regressions

gen chair_comp_all=inc_res_d
gen chair_comp_top3	=inc_res_d if top_3==1

*collapse data to municipality and electionperiod, take average of competence measure

collapse (mean) chair_comp_all chair_comp_top3	, by (m_id electionyear)
	
*add outcomes

joinby m_id electionyear using "economic_outcomes.dta", unmatched(master) _merge(_merge)

joinby m_id electionyear using "satisfaction.dta", unmatched(master) _merge(_merge2)

joinby m_id electionyear using "complaints.dta", unmatched(master) _merge(_merge3)
	
	**Table 2
reg final_resavg chair_comp_all
outreg2 chair_comp_all using table_2, ctitle(DELETE) excel dec (3)se replace

foreach outcome in happy_total crit_pop compl_pop solres2_6 result solvency    {
	foreach x in 	chair_comp_all chair_comp_top3 {
		xi: reg `outcome' `x' i.electionyear, cluster(m_id)
		outreg2 `x' using table_2, ctitle(`outcome' `x') excel dec (3)se append
	}
}

	
	
	
