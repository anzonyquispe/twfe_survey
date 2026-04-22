version 15.0
clear all
cap log close
set more off

*==========================
* Table 3
* Online Appendix Table A1 
* Online Appendix Table A2
*==========================

prog main

	sumstats_reg_sample_race
	validate_race_against_nbhd_attr, smpstub(all)
end

prog sumstats_reg_sample_race
	
	use "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear

	* main regresion sample
	global reg_smp yr_built_treat>=1900 & yr_built_treat<=1990 & year>=1990 ///
		& age_in1993>=20 & age_in1993<=65 & use_code_treat==3 ///
		& is_owner==0 & yrs_at_curr93<=14
	keep if $reg_smp
	
	* merge in racial classification
	merge m:1 id using "data/impute_race/renter_proxied_final", assert(2 3) keep(3) keepus(race pr_final) nogen
	
	* dummy for minority
	gen minority = (race~=1) & ~mi(race)
	
	replace race = 7 if race==5 //there is one obs
	replace race = 7 if mi(race)
	replace pr_final = . if race==7
	
	label drop RACE
	label define RACE 1 "White" ///
                  2 "Black" ///
                  3 "Hispanic" ///
                  4 "Asian" ///
                  5 "AIAN" ///
                  6 "Multi-Racial" ///
				  7 "Unclassified"
	label values race RACE

	* drops Unclassified race
	drop if race==7
	
	*==========================================
	* Table 3 Column 5
	* Table A1 Column 1 & 2
	*==========================================

	* breakdown of racial classification
	tab2xl race if year==1993 using "output/sumstats_indiv_panel_race1", col(1) row(1) replace 
	
	*==================
	* Table A1 Column 3
	*==================

	* mean of the final racial probability by race
	eststo clear
	estpost tabstat pr_final if year==1993, by(race)

	esttab using "output/sumstats_indiv_panel_race2.csv", ///
		replace plain ///
		cells(mean(fmt(3) label("Mean"))) ///
		label wrap nonum noobs nomtitles
	
end

prog validate_race_against_nbhd_attr

	syntax, smpstub(str)

	use if is_owner==0 using "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear

	* main regresion sample
	global base_sample_treat yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990  & treat==1
	global base_sample_control yr_built_treat>=1900 & yr_built_treat<=1990 & yrs_at_curr93<=14 & year>=1990 & treat==0
	keep if ($base_sample_treat | $base_sample_control) & (use_code_treat==3)
	keep if age_in1993>=20 & age_in1993<=65

	* merge in racial classification
	merge m:1 id using "data/impute_race/renter_proxied_final", assert(2 3) keep(3) keepus(race) nogen
	keep if ~mi(race)

	* merge in census blk of 2010 address of the 1994 RC cohort
	keep if year==2010
	keep id race
	merge 1:1 id using "data/impute_race/infutor_panelist_address_2010_geocoded.dta", assert(2 3) keep(3) keepus(blk_full blkgrp_full tract_full) nogen

	gen GeoInd = blk_full
	* drop individuals whose 2010 address cannot be geocoded successfully
	drop if mi(GeoInd)

	* merge in census blk level racial distributions from 2010 census if available
	merge m:1 GeoInd using "data/impute_race/blk_attr_over18_dec10", assert(2 3) keep(3) nogen
	drop here*
	count if mi(geo_pr_white)

	replace GeoInd = blkgrp_full
	* merge in census blkgrp level racial distributions from 2010 census if available
	* update missing values in master data with values from using
	merge m:1 GeoInd using "data/impute_race/blkgrp_attr_over18_dec10", assert(2 3 4 5) keep(3 4 5) nogen update
	drop here*
	count if mi(geo_pr_white)

	label drop RACE
	label define RACE 1 "White" ///
                  2 "Black" ///
                  3 "Hispanic" ///
                  4 "Asian" ///
                  5 "AIAN" ///
                  6 "Multi-Racial"
	label values race RACE

	*=====================
	* Table 3 Columns 1-4
	*=====================

	* summarize share of each race at block level, by race
	eststo clear
	estpost tabstat geo_pr_white geo_pr_black geo_pr_hispanic geo_pr_api if inlist(race,1,2,3,4), by(race) stat(mean) nototal
	esttab using "output/sumstats_blk10_attr_`smpstub'.csv", replace ///
		cells((geo_pr_white(fmt(3) label("Share White")) ///
		       geo_pr_black(fmt(3) label("Share Black")) ///
			   geo_pr_hispanic(fmt(3) label("Share Hispanic")) ///
			   geo_pr_api(fmt(3) label("Share Asian")) )) ///
			   label nonum noobs nomtitles

	*=====================
	* Table A2
	*=====================

	drop if ~inlist(race,1,2,3,4)
	eststo clear
	eststo: reg geo_pr_white ib2.race
	eststo: reg geo_pr_black ib2.race
	eststo: reg geo_pr_hispanic ib2.race
	eststo: reg geo_pr_api ib2.race

	esttab using "output/reg_blk10_attr_`smpstub'.tex", replace ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	keep(*.race) nobaselevels ///
	stats(r2 N, fmt(3 0) layout(@ @) ///
	labels(`"\(R^{2}\)"' `"Observations"')) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	label wrap booktabs collabels(none) ///
	mtitles("Share White" "Share Black" "Share Hispanic" "Share Asian")
end

prog sumstats_census90_sf_tenant_race

	//use 1990 census
	use if year==1990 using "data/census/usa_00012.dta", clear

	//SF
	keep if city==6290

	//age 20-65
	keep if inrange(age, 20, 65)

	//renters
	keep if ownershp==2

	//use code
	*lab list UNITSSTR
	/*
		   0 n/a
		   1 mobile home or trailer
		   2 boat, tent, van, other
		   3 1-family house, detached
		   4 1-family house, attached
		   5 2-family building
		   6 3-4 family building
		   7 5-9 family building
		   8 10-19 family building
		   9 20-49 family building
		  10 50+ family building
	*/
	gen usecode=.a if unitsstr==0
	replace usecode=1 if inlist(unitsstr,1,2)
	replace usecode=2 if inlist(unitsstr,3,4)
	replace usecode=3 if inlist(unitsstr,5,6)
	replace usecode=4 if unitsstr>=7 & ~mi(unitsstr)

	label define USECODE .a "Usecode unknown" ///
				 1 "Other" ///
				 2 "Single Family" ///
				 3 "Small-multi Family" ///
				 4 "Large-multi Family"	
	label values usecode USECODE

	//break out hispanic as separate category in ethnicity
	gen hispanic = (hispan~=0)

	drop race
	gen race = 1 if racesing==1 & hispanic==0
	replace race = 2 if racesing==2 & hispanic==0
	replace race = 3 if hispanic==1
	replace race = 4 if racesing==4 & hispanic==0
	replace race = 5 if inlist(racesing,3,5) & hispanic==0

	cap label drop RACE
	label define RACE 1 "White" ///
				  2 "Black" ///
				  3 "Hispanic" ///
				  4 "Asian" ///
				  5 "Other"
	label values race RACE

	*===================
	* Table 3 Column 6
	* Table A1 Column 4
	*===================
		
	tab2xl race if usecode==3 [fw=perwt] using "output/sumstats_census90_sf_tenant_race", col(1) row(1) replace 

end

prog sumstats_census10_sf_tenant_race

	//use 2010 census
	use if year==2010 using "data/census/usa_00012.dta", clear

	//SF
	keep if city==6290

	//age 20-65
	keep if inrange(age, 20, 65)

	//renters
	keep if ownershp==2

	//use code
	*lab list UNITSSTR
	/*
		   0 n/a
		   1 mobile home or trailer
		   2 boat, tent, van, other
		   3 1-family house, detached
		   4 1-family house, attached
		   5 2-family building
		   6 3-4 family building
		   7 5-9 family building
		   8 10-19 family building
		   9 20-49 family building
		  10 50+ family building
	*/
	gen usecode=.a if unitsstr==0
	replace usecode=1 if inlist(unitsstr,1,2)
	replace usecode=2 if inlist(unitsstr,3,4)
	replace usecode=3 if inlist(unitsstr,5,6)
	replace usecode=4 if unitsstr>=7 & ~mi(unitsstr)

	label define USECODE .a "Usecode unknown" ///
				 1 "Other" ///
				 2 "Single Family" ///
				 3 "Small-multi Family" ///
				 4 "Large-multi Family"
	label values usecode USECODE

	//break out hispanic as separate category in ethnicity
	gen hispanic = (hispan~=0)

	drop race
	gen race = 1 if racesing==1 & hispanic==0
	replace race = 2 if racesing==2 & hispanic==0
	replace race = 3 if hispanic==1
	replace race = 4 if racesing==4 & hispanic==0
	replace race = 5 if inlist(racesing,3,5) & hispanic==0

	cap label drop RACE
	label define RACE 1 "White" ///
				  2 "Black" ///
				  3 "Hispanic" ///
				  4 "Asian" ///
				  5 "Other"
	label values race RACE

	*===================
	* Table 3 Column 7
	*===================

	tab2xl race if usecode==3 [fw=perwt] using "output/sumstats_census10_sf_tenant_race", col(1) row(1) replace

end

main

