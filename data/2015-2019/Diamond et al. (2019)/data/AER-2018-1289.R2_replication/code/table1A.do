version 15.0
clear all
set more off

*****************
* Table 1 Panel A
*****************

prog main
	sumstats_reg_sample
end

prog sumstats_reg_sample
	
	use "data/infutor/infutor_panel_treat_1994_cleaned.dta", clear

	global reg_smp yr_built_treat>=1900 & yr_built_treat<=1990 & year>=1990 ///
		& age_in1993>=20 & age_in1993<=65 & use_code_treat==3 ///
		& is_owner==0 & yrs_at_curr93<=14
	keep if $reg_smp
	
	global demo age_in1993
	global depvar insf same_zip same_parcel years_at_current
	
	* Variable labels
	lab var age_in1993 "Age in 1993"
	lab var years_at_current "Years at Address"
	lab var insf "In SF"
	lab var same_zip "Same Zipcode"
	lab var same_parcel "Same Address"

	*======================
	* sumstats for treated
	*======================

	preserve

	keep if treat==1
	loc outstub treat

	eststo clear
	
	estpost su $demo if year==1993, d
	est store A
		
	esttab A using "output/sumstats_indiv_panel_`outstub'.csv", ///
		replace wide plain ///
		refcat(age_in1993 "Demographics", nolabel) ///
		cells((mean(fmt(3) label("Mean")) ///
		sd(fmt(3) label("S.D.")) )) ///
		label wrap nonum gaps noobs nomtitles
		
	estpost su $depvar if year>=1990 & year<=1993, d
	est store B
	
	esttab B using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(insf "Residency (1990-1993)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	estpost su $depvar if year>=1994 & year<=2016, d
	est store C
	
	esttab C using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(insf "Residency (1994-2016)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	lab var age_in1993 "No. Persons"
	estpost su $demo if year==1993, d
	est store D
	
	esttab D using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		cells((count(fmt(0)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles

	restore

	*======================
	* sumstats for control
	*======================

	preserve

	keep if treat==0
	loc outstub control

	eststo clear
	
	estpost su $demo if year==1993, d
	est store A
		
	esttab A using "output/sumstats_indiv_panel_`outstub'.csv", ///
		replace wide plain ///
		refcat(age_in1993 "Demographics", nolabel) ///
		cells((mean(fmt(3) label("Mean")) ///
		sd(fmt(3) label("S.D.")) )) ///
		label wrap nonum gaps noobs nomtitles
		
	estpost su $depvar if year>=1990 & year<=1993, d
	est store B
	
	esttab B using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(insf "Residency (1990-1993)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	estpost su $depvar if year>=1994 & year<=2016, d
	est store C
	
	esttab C using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(insf "Residency (1994-2016)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	lab var age_in1993 "No. Persons"
	estpost su $demo if year==1993, d
	est store D
	
	esttab D using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		cells((count(fmt(0)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles

	restore

	*=====================================
	* difference between treat and control
	*=====================================

	loc outstub diff

	eststo clear
	eststo A: reg age_in1993 i.treat if year==1993

	esttab A using "output/sumstats_indiv_panel_`outstub'.csv", ///
		replace wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Age in 1993") ///
		refcat(1.treat "Demographics", nolabel) ///
		label wrap nonum noobs nomtitles
	
	eststo clear
	eststo B1: reg insf i.treat if year>=1990 & year<=1993

	esttab B1 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "In SF") ///
		refcat(1.treat "Residency (1990-1993)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo B2: reg same_zip i.treat if year>=1990 & year<=1993

	esttab B2 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Same Zipcode") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo B3: reg same_parcel i.treat if year>=1990 & year<=1993

	esttab B3 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Same Address") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo B4: reg years_at_current i.treat if year>=1990 & year<=1993

	esttab B4 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Years at Address") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo C1: reg insf i.treat if year>=1994 & year<=2016

	esttab C1 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "In SF") ///
		refcat(1.treat "Residency (1994-2016)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo C2: reg same_zip i.treat if year>=1994 & year<=2016

	esttab C2 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Same Zipcode") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo C3: reg same_parcel i.treat if year>=1994 & year<=2016

	esttab C3 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Same Address") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo clear
	eststo C4: reg years_at_current i.treat if year>=1994 & year<=2016

	esttab C4 using "output/sumstats_indiv_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Years at Address") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles
end 

main
