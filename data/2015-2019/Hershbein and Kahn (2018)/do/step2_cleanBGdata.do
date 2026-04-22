
/****************************************************************************
** Input: postings_firm2_16.dta						  **
** This dataset contains MSA-occ-firm-year ad summary statistics, cleaned in a previous program.
****************************************************************************/
*{{{
use "$data_output/postings_firm2_16.dta", clear

capture drop _merge

**keep non-missing firms
count 
keep if Mfirm==0
drop if employer==""
drop if employer==" "
count

**removing spaces actually generates a few thousand matches across employer that did not do in raw data grab
gen emp_nospace = subinstr(employer," ","",.)
replace emp_nospace = lower(emp_nospace)

assert soc!=. & msa!=.


bysort emp_nospace: egen mode_sector = mode(sector), min
bysort emp_nospace: egen mode_naics3 = mode(naics3), min
	
collapse yrschl* yrsexp* mode_sector mode_naics3 (sum) M* DD* SKILL* edu_reqd exp_reqd deg12 deg14 deg16 deg18 deg21 exp_less1 exp1_2 exp3_5 exp5_10 exp11_plus (rawsum) npostings, by(msa year soc emp_nospace)
ren mode_sector sector
ren mode_naics3 naics3



***MSA labor force in 2006
merge m:1 msa using "$data_output/msa_LF_2006"
drop if _merge==2
drop _merge

**bring in shock variables
merge m:1 msa using "$data_output/bartiks"
***the msas that don't merge are micro areas, drop them
drop if _merge==1
assert _merge==3
drop _merge

ren shock_mean_sa_bartik9010 shock9010
ren shock_sa_bartik9010 shock_bw_9010
ren shock_mean_sa_level9010 level_9010
ren shock_mean_sa_bartik19010 shock1_9010 

	
display "just metro areas that don't match"
**number of msa's
egen Nmsas = group(msa)
sum Nmsas
drop Nmsas

merge m:1 msa using "$data_output/ACSvars0506_msa"
	drop if _merge==2
	gen M_ACS = (_merge==1)
	foreach var of varlist ACS* {
		replace `var' = 0 if M_ACS==1
	}
	capture drop miss_ACS
	drop _merge


***make sure employer-soc-msa-date are unique observations
bysort emp_nospace soc msa year: gen helper = _N
assert helper==1
drop helper


display "number of unique employer names"
capture drop helper
gen helper = emp_nospace if Mfirm==0
egen Nfirms = group(helper)
sum Nfirms
drop helper Nfirms

*****keep firms with at least 10 ads
capture drop counter
bysort emp_nospace: egen counter = sum(npostings)
gen keepit = (counter>10)
tab keepit
tab keepit [fw=npostings]
keep if keepit==1
drop keepit counter


**the weight preserves the relative size of firm-occs within date
** and size of msa's across dates
bysort year msa: egen tot_obs = sum(npostings)
gen rel_occsize = npostings/tot_obs
gen weight = lf2006*rel_occsize
drop rel_occsize tot_obs


****dependent variables
gen ed = edu_reqd/npostings
gen exp = exp_reqd/npostings
assert edu_reqd==deg12 + deg14 + deg16 + deg18 + deg21

ren yrschl_condl yed
ren yrsexp_condl yexp


assert npostings!=0
gen lnpostings = log(npostings)
assert exp_reqd == exp_less1 + exp1_2 + exp3_5 + exp5_10 + exp11_plus

foreach deg of numlist 12 16 18 21 {
	gen share`deg' = deg`deg'/npostings
}

gen ed_more = share18 + share21

gen share_l1 = exp_less1/npostings
gen share1_2 = exp1_2/npostings
gen share3_5 = exp3_5/npostings
gen share5_10 = exp5_10/npostings
gen share11_plus = exp11_plus/npostings
	gen share1_5 = share_l1 + share1_2 + share3_5
	gen share_plus = share5_10 + share11_plus
gen exp_more = share5_10 + share11_plus
gen exp_low = share_l1 + share1_2

***Skillz variables
gen share_Mskills = Mskills/npostings
gen nSKILLS = npostings- Mskills
assert nSKILLS>=0 & nSKILLS!=. 

foreach var of varlist DD* SKILL* {
	gen share_`var' = `var'/npostings
	gen share_`var'_int = `var'/nSKILLS
	drop `var'
}
ren share_DDcognitive_int cog
ren share_DDcomp_all_int comp_all

***sector, note not unique within employer
replace sector = -99 if sector==.

*}}}
saveold "$data_output/BG_hasfirm_employer_soc_msa_year", replace


/****************************************************************************
** Collapse employer data to:
**soc msa level
** msa level
**sector msa level
**sector soc msa level
****************************************************************************/
*{{{
local coll1 = "msa"
local coll2 = "msa soc"
local coll3 = "msa emp_nospace"
local coll4 = "msa sector"
local coll5 = "msa sector soc"
foreach collapse in 1 2 3 4 5 {
	use "$data_output/BG_hasfirm_employer_soc_msa_year", clear

	**aggregate to specified level
	collapse shock9010 level_9010 shock_bw_9010 shock1_9010 ACS* M_ACS lf2006 yed yexp ed exp share12 share16 ed_more share3_5 exp_more exp_low share_Mskills cog comp_all  (rawsum) npostings [aw=npostings], by(`coll`collapse'' year)

	assert npostings!=0	
	gen lnpostings = log(npostings)

	
	**npostings/tot_obs = 1 if collapse to msa-year level
	bysort msa year: egen tot_obs = sum(npostings)
	gen rel_occsize = npostings/tot_obs
	gen weight = lf2006*rel_occsize
	drop rel_occsize tot_obs

	foreach year of numlist 2010/2015 {
		foreach shock in shock9010 shock_bw_9010 shock1_9010 level_9010  {
			gen `shock'`year' = `shock'*(year==`year')
		}
	}

	***get ch vars from 2007 at the collapse level
	foreach var in ed exp yed yexp cog comp_all share12 share16 share3_5 ed_more exp_more exp_low {
		gen temp = `var' if year==2007
		bysort `coll`collapse'': egen mtemp = mean(temp)
		gen ch`var' = `var' - mtemp
		drop temp mtemp
		**not always a match depending on aggregation
	}

	if `collapse' == 1 {	
		save "$data_output/BG_hasfirm_msa_year", replace
	}
	if `collapse' == 2 {	
		save "$data_output/BG_hasfirm_soc_msa_year", replace
	}
	if `collapse' == 3 {	
		save "$data_output/BG_hasfirm_employer_msa_year", replace
	}
	if `collapse' == 4 {	
		save "$data_output/BG_hasfirm_sector_msa_year", replace
	}
	if `collapse' == 5 {	
		save "$data_output/BG_hasfirm_sector_soc_msa_year", replace
	}
	
}
	
*}}}

/****************************************************************************
** Input: postings_soc2_16.dta						  **
** This dataset contains MSA-occ-year ad summary statistics, cleaned in a previous program.
****************************************************************************/

/****************************************************************************
** Full data, MSA-Occ-Date-level					  **
**	(excludes micro areas)						  **
****************************************************************************/
*{{{
use "$data_output/postings_soc2_16.dta", clear

capture drop _merge

assert soc!=. & msa!=.

***MSA labor force in 2006
merge m:1 msa using "$data_output/msa_LF_2006"
drop if _merge==2
drop _merge

**bring in shock variables
merge m:1 msa using "$data_output/bartiks"
***the msas that don't merge are micro areas, drop them
drop if _merge==1
assert _merge==3
drop _merge

ren shock_mean_sa_bartik9010 shock9010
ren shock_sa_bartik9010 shock_bw_9010
ren shock_mean_sa_level9010 level_9010
ren shock_mean_sa_bartik19010 shock1_9010 

	
display "just metro areas that don't match"
**number of msa's
egen Nmsas = group(msa)
sum Nmsas
drop Nmsas


merge m:1 msa using "$data_output/ACSvars0506_msa"
	drop if _merge==2
	gen M_ACS = (_merge==1)
	foreach var of varlist ACS* {
		replace `var' = 0 if M_ACS==1
	}
	capture drop miss_ACS
	drop _merge


***make sure soc-msa-date are unique observations
bysort soc msa year: gen helper = _N
assert helper==1
drop helper


**the weight preserves the relative size of firm-occs within date
** and size of msa's across dates
bysort year msa: egen tot_obs = sum(npostings)
gen rel_occsize = npostings/tot_obs
gen weight = lf2006*rel_occsize
drop rel_occsize tot_obs


****dependent variables
gen ed = edu_reqd/npostings
gen exp = exp_reqd/npostings
assert edu_reqd==deg12 + deg14 + deg16 + deg18 + deg21

ren yrschl_condl yed
ren yrsexp_condl yexp


assert npostings!=0
gen lnpostings = log(npostings)
assert exp_reqd == exp_less1 + exp1_2 + exp3_5 + exp5_10 + exp11_plus

foreach deg of numlist 12 16 18 21 {
	gen share`deg' = deg`deg'/npostings
}

gen ed_more = share18 + share21

gen share_l1 = exp_less1/npostings
gen share1_2 = exp1_2/npostings
gen share3_5 = exp3_5/npostings
gen share5_10 = exp5_10/npostings
gen share11_plus = exp11_plus/npostings
	gen share1_5 = share_l1 + share1_2 + share3_5
	gen share_plus = share5_10 + share11_plus

gen exp_more = share5_10 + share11_plus
gen exp_low = share_l1 + share1_2

gen share_Mfirm = Mfirm/npostings


***Skillz variables
gen share_Mskills = Mskills/npostings
gen nSKILLS = npostings- Mskills
assert nSKILLS>=0 & nSKILLS!=. 

foreach var of varlist DD* SKILL* {
	gen share_`var' = `var'/npostings
	gen share_`var'_int = `var'/nSKILLS
	drop `var'
}
ren share_DDcognitive_int cog
ren share_DDcomp_all_int comp_all

	***get ch vars from 2007 at the MSA-SOC level
	foreach var in ed exp yed yexp cog comp_all share12 share16 share3_5 ed_more exp_more exp_low  lnpostings  {
		gen temp = `var' if year==2007
		bysort msa soc: egen mtemp = mean(temp)
		gen ch`var' = `var' - mtemp
		drop temp mtemp
		**not always a match depending on aggregation
	}
	
	
	foreach year of numlist 2010/2015 {
		foreach shock in shock9010 shock_bw_9010 shock1_9010 level_9010  {
			gen `shock'`year' = `shock'*(year==`year')
		}
	}



*}}}
saveold "$data_output/BG_all_soc_msa_year", replace

/****************************************************************************
** Collapse full data data to soc msa and msa level
****************************************************************************/
*{{{
local coll1 = "msa"
foreach collapse in 1 {
	use "$data_output/BG_all_soc_msa_year", clear
	
	collapse shock9010 level_9010 shock_bw_9010 shock1_9010 ACS* M_ACS lf2006 yed yexp ed exp share12 share16 ed_more share3_5 exp_more exp_low share_Mskills cog comp_all  share_Mfirm (rawsum) npostings [aw=npostings], by(`coll`collapse'' year)

	assert npostings!=0
	
	gen lnpostings = log(npostings)

	**npostings/tot_obs = 1 if collapse to msa-year level
	bysort msa year: egen tot_obs = sum(npostings)
	gen rel_occsize = npostings/tot_obs
	gen weight = lf2006*rel_occsize
	drop rel_occsize tot_obs


	foreach year of numlist 2010/2015 {
		foreach shock in shock9010 level_9010 shock_bw_9010 shock1_9010 {
			gen `shock'`year' = `shock'*(year==`year')
		}
	}

	***get ch vars from 2007 
	foreach var in ed exp yed yexp cog comp_all share12 share16 share3_5 ed_more exp_more exp_low lnpostings share_Mfirm {
		gen temp = `var' if year==2007
		bysort `coll`collapse'': egen mtemp = mean(temp)
		gen ch`var' = `var' - mtemp
		drop temp mtemp
	}

	if `collapse' == 1 {	
		save "$data_output/BG_all_msa_year", replace
	}
}
	
*}}}





