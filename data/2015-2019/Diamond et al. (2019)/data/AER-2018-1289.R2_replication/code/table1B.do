version 15.0
clear all
set more off

*****************
* Table 1 Panel B
*****************

prog main
	sumstats_reg_sample, treat(1) outstub(treat)
	sumstats_reg_sample, treat(0) outstub(control)
	sumstats_reg_sample2
end

prog sumstats_reg_sample
	syntax, treat(integer) outstub(str)
	
	use if treat==`treat' using "data/infutor/panel_parcel_year_cleaned.dta", clear

	global reg_smp year>=1990 & use_code == 3 & ((yearbuilt_orig>=1900 & yearbuilt_orig<=1990) | bltfuture_treat==1)
	keep if $reg_smp
	
	global depvar convert_anything
	global pop pop_n2 ren_n2 ren_n2_rc ren_n2_norc own_n2
	global permit acc_permit3_n has_acc_permit3
 	
	* Variable labels
	lab var convert_anything "Conversion"
	lab var pop_n2 "Population/Avg Pop 90-94"
	lab var ren_n2 "Renters/Avg Pop 90-94"
	lab var ren_n2_rc   "Renters in Rent-Controlled Buildings/Avg Pop 90-94"
	lab var ren_n2_norc "Renters in Redeveloped Buildings/Avg Pop 90-94"
	lab var own_n2 "Owners/Avg Pop 90-94"
	lab var acc_permit3_n "Cumulative Add/Alter/Repair per Unit"
	lab var has_acc_permit3 "Ever Received Add/Alter/Repair"
	
	eststo clear
	
	estpost su $depvar if year>=1990 & year<=1993, d
	est store A
		
	esttab A using "output/sumstats_parcel_panel_`outstub'.csv", ///
		replace wide plain ///
		refcat(convert_anything "Residency (1990-1993)", nolabel) ///
		cells((mean(fmt(3) label("Mean")) ///
		sd(fmt(3) label("S.D.")) )) ///
		label wrap nonum gaps noobs nomtitles
		
	estpost su $depvar if year>=1994 & year<=2016, d
	est store B
	
	esttab B using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(convert_anything "Residency (1994-2016)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
		
	estpost su $pop if year>=1990 & year<=1993, d
	est store C
	
	esttab C using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(pop_n2 "Population (1990-1993)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	estpost su $pop if year>=1994 & year<=2016, d
	est store D
	
	esttab D using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(pop_n2 "Population (1994-2016)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	estpost su $permit if year>=1990 & year<=1993, d
	est store E
	
	esttab E using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(acc_permit3_n "Permits (1990-1993)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	estpost su $permit if year>=1994 & year<=2016, d
	est store F
	
	esttab F using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		refcat(acc_permit3_n "Permits (1994-2016)", nolabel) ///
		cells((mean(fmt(3)) ///
		sd(fmt(3)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
	
	lab var convert_anything "No. Parcels"
	estpost su convert_anything if year==1993, d
	est store G
	
	esttab G using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		cells((count(fmt(0)) )) ///
		collabels(none) ///
		label wrap nonum gaps noobs nomtitles
end

prog sumstats_reg_sample2

	*=====================================
	* difference between treat and control
	*=====================================

	use "data/infutor/panel_parcel_year_cleaned.dta", clear

	global reg_smp year>=1990 & use_code == 3 & ((yearbuilt_orig>=1900 & yearbuilt_orig<=1990) | bltfuture_treat==1)
	keep if $reg_smp

	loc outstub diff
	
	eststo clear
	
	eststo A: reg convert_anything i.treat if year>=1990 & year<=1993

	esttab A using "output/sumstats_parcel_panel_`outstub'.csv", ///
		replace wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Conversion") ///
		refcat(1.treat "Residency (1990-1993)", nolabel) ///
		label wrap nonum noobs nomtitles
		
	eststo B: reg convert_anything i.treat if year>=1994 & year<=2016

	esttab B using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Conversion") ///
		refcat(1.treat "Residency (1994-2016)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles
		
	eststo C1: reg pop_n2 i.treat if year>=1990 & year<=1993
	
	esttab C1 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Population/Avg Pop 90-94") ///
		refcat(1.treat "Population (1990-1993)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo C2: reg ren_n2 i.treat if year>=1990 & year<=1993
	
	esttab C2 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Renters/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo C3: reg ren_n2_rc i.treat if year>=1990 & year<=1993
	
	esttab C3 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Renters in Rent-Controlled Buildings/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo C4: reg ren_n2_norc i.treat if year>=1990 & year<=1993
	
	esttab C4 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Renters in Redeveloped Buildings/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo C5: reg own_n2 i.treat if year>=1990 & year<=1993
	
	esttab C5 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Owners/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo D1: reg pop_n2 i.treat if year>=1994 & year<=2016
	
	esttab D1 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Population/Avg Pop 90-94") ///
		refcat(1.treat "Population (1994-2016)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo D2: reg ren_n2 i.treat if year>=1994 & year<=2016
	
	esttab D2 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Renters/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo D3: reg ren_n2_rc i.treat if year>=1994 & year<=2016
	
	esttab D3 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Renters in Rent-Controlled Buildings/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo D4: reg ren_n2_norc i.treat if year>=1994 & year<=2016
	
	esttab D4 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Renters in Redeveloped Buildings/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo D5: reg own_n2 i.treat if year>=1994 & year<=2016
	
	esttab D5 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Owners/Avg Pop 90-94") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles
	
	eststo E1: reg acc_permit3_n i.treat if year>=1990 & year<=1993
	
	esttab E1 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Cumulative Add/Alter/Repair per Unit") ///
		refcat(1.treat "Permits (1990-1993)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo E2: reg has_acc_permit3 i.treat if year>=1990 & year<=1993
	
	esttab E2 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Ever Received Add/Alter/Repair") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles
	
	eststo F1: reg acc_permit3_n i.treat if year>=1994 & year<=2016
	
	esttab F1 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Cumulative Add/Alter/Repair per Unit") ///
		refcat(1.treat "Permits (1994-2016)", nolabel) ///
		collabels(none) ///
		label wrap nonum noobs nomtitles

	eststo F2: reg has_acc_permit3 i.treat if year>=1994 & year<=2016
	
	esttab F2 using "output/sumstats_parcel_panel_`outstub'.csv", ///
		append wide plain ///
		b(3) se(3) ///
		keep(1.treat) nobaselevels ///
		coeflabels(1.treat "Ever Received Add/Alter/Repair") ///
		collabels(none) ///
		label wrap nonum noobs nomtitles
end

main
