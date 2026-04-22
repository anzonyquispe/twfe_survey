**************************************************************
**************************************************************
*****   	do-file 1_PersDat_G.do         		 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Preparation of worker data 
** Aggregation level: Workers 
 
//  Preliminaries 
pause on
set more off
local sound qui
capture log close
log using "${log}/1_PersDat_${pro}_${sam}.log", replace

`sound' {

	foreach wave of global wave {
		
		// Load worker data
		use "${orig}/liab_qm2_9308_v1_pers_`wave'.dta", clear

		// Merge industy information 
		merge m:1 betnr jahr using "${orig}/liab_qm2_9308_v1_btr_basis.dta", keepusing(ao_bula w73_3_gen az_ges az_ges_vz) keep(3) nogen

		// Merge special file containing municipal firm location
		merge m:1 betnr using "${orig}\liab_qm2_9308_v1_bhp_7510vorab_m06_bst_v1_`wave'", keepusing(ao_gem) keep(3) nogen

		sort persnr

		// Select relevant workers
		* Employed
		keep if quelle == 1

		* FirmID is filled
		drop if idnum == -5

		* Firm must be part of Establishment Panel
		keep if betr_st == 1

		* Regular jobs, subject to social security
		keep if erwstat == 101

		* Drop workers in education
		drop if stib == 0

		* If multiple obs per worker: keep the one with highest wage
		gsort persnr -tentgelt
		by persnr: keep if _n==1

		// Define key variables
		* monthly wage censored
		drop if tentgelt <= 0 // implausbile or missing
		
		// Factor tranforming days into months (provided by IAB)
		if `wave'==2010 local dm_factor = 5500/180.82
		if `wave'==2009 local dm_factor = 5400/177.53
		if `wave'==2008 local dm_factor = 5300/173.77	
		if `wave'==2007 local dm_factor = 5250/172.60
		if `wave'==2006 local dm_factor = 5250/172.60
		if `wave'==2005 local dm_factor = 5200/170.96
		if `wave'==2004 local dm_factor = 5150/168.85
		if `wave'==2003 local dm_factor = 5100/167.67
		if `wave'==2002 local dm_factor = 4500/147.95
		if `wave'==2001 local dm_factor = 8700/286.03
		if `wave'==2000 local dm_factor = 8600/281.97
		if `wave'==1999 local dm_factor = 8500/279.45
		if `wave'==1998 local dm_factor = 8400/276.16
		if `wave'==1997 local dm_factor = 8200/269.59
		if `wave'==1996 local dm_factor = 8000/262.30
		if `wave'==1995 local dm_factor = 7800/256.44
		if `wave'==1994 local dm_factor = 7600/249.44
		if `wave'==1993 local dm_factor = 7200/236.71
		
		gen double wage = tentgelt * `dm_factor'
		label variable wage        "monthly wage"
		drop if wage == .
		
		gen double lwage = log(wage)
		lab variable lwage "log monthly wage"
		
		* State
		rename ao_bula bl

		* East/West
		gen west = bl <= 10
		lab var west "region"
		label define west_lb 1 "west" 0 "east"
		label values west west_lb

		* Sex
		gen male = frau == 0
		label define sexlb 0 "female" 1 "male"  , replace
		label value male sexlb
		lab var male "gender"

		* Age 
		gen age = `wave' - gebjahr
		drop if age < 16
		drop if age >= 65
		lab var age 	"age"

		* Age group
		gen age_gr = . 
		replace age_gr = 1 if inrange(age,16,30)
		replace age_gr = 2 if inrange(age,31,50)
		replace age_gr = 3 if inrange(age,51,64)
		label var age_gr "age group"
		label define agelb 1 "young" 2 "mid-aged" 3 "old" , replace
		label value age_gr agelb

		* Tenure
		gen tenure = tage_bet 		/ 365
		lab var tenure "tenure"
		
		* Sector: disaggregate definition
		gen aggr_bran = .
		replace aggr_bran = 1 	if inrange(w73_3_gen,0,31) | w73_3_gen == 40 | inrange(w73_3_gen,50,80) | inrange(w73_3_gen,130,146)
		// Landwirtschaft, Energie, Bergbau

		replace aggr_bran = 2 	if inrange(w73_3_gen,90,110) | inrange(w73_3_gen,130,132) | inrange(w73_3_gen,170,200) | inrange(w73_3_gen,220,221) | inrange(w73_3_gen,400,401)  | inrange(w73_3_gen,430,433) 
		// Güterproduktion

		replace aggr_bran = 3 	if inrange(w73_3_gen,230,240) | inrange(w73_3_gen,260,300)
		// Stahl- und Leichtmetallbau, Maschinenbau

		replace aggr_bran = 4 	if inrange(w73_3_gen,210,211) | inrange(w73_3_gen,301,379) 		
		// Stahlverformung, Fahrzeugbau, Gerätebau

		replace aggr_bran = 5 	if w73_3_gen == 120 | inrange(w73_3_gen,150,162) | inrange(w73_3_gen,380,390) | inrange(w73_3_gen,410,421) | inrange(w73_3_gen,440,530)		
		// Konsumgütergewerbe

		replace aggr_bran = 6 	if inrange(w73_3_gen,540,581)
		// Nahrungs- und Genussmittelgewerbe

		replace aggr_bran = 7 	if inrange(w73_3_gen,590,601)
		// Baugewerbe (Haupt)

		replace aggr_bran = 8 	if w73_3_gen == 250 | inrange(w73_3_gen,610,616)	
		// Baugewerbe (Ausbau)

		replace aggr_bran = 9 	if inrange(w73_3_gen,620,621)
		// Großhandel

		replace aggr_bran = 10 	if inrange(w73_3_gen,622,625) | w73_3_gen == 850
		// Einzelhandel

		replace aggr_bran = 11 	if inrange(w73_3_gen,630,683) 		
		// Verkehr und Nachrichtenübermittlung

		replace aggr_bran = 12 	if inlist(w73_3_gen,690, 691, 721, 774, 851, 861, 862, 863, 865 ) | inrange(w73_3_gen,790,830) 
		// Wirtschaftsbezogene Dienstleistungen

		replace aggr_bran = 13 	if inlist(w73_3_gen,700,703,720,722,730,731,844,845,860,864,900,997) | inrange(w73_3_gen,770,773) | inrange(w73_3_gen,760,773) 
		// Haushaltsbezogene Dienstleistungen 

		replace aggr_bran = 14 	if inrange(w73_3_gen,740,758) | inrange(w73_3_gen,710,712) |inrange(w73_3_gen,780,785) | inrange(w73_3_gen,953,954) 		
		// Heime, Krankenhäuser, Erziehung

		replace aggr_bran = 15 	if inlist(w73_3_gen,842,843) | inrange(w73_3_gen,870,890) | inrange(w73_3_gen,701,702)		
		// (Straßen)Reinigung, Verbände, Organisa-tionen 

		replace aggr_bran = 16 	if inrange(w73_3_gen,910,930) | inrange(w73_3_gen,760,764) | inlist(w73_3_gen,840,841,940) 
		// Öffentliche Verwaltung, Sozialversiche-rung


		label define abranche_lb 	1 "agriculture" 2 "durables" 3 "steel" 4 "car"  ///
						5 "non-durables" 6 "food" 7 "construction" 8 "restauration" ///
						9 "wholesale" 10 "trade" 11 "traffic" 12 "consulting"  ///
						13 "services" 14 "hospitals" 15 "organisations" 16 "public" 17 "financial services" ///
						, replace
		label values aggr_bran abranche_lb
		
		* Sector: Baseline definition
		gen branche = .	
		replace branche = 1 if inlist(aggr_bran,2,3,4,5,6) 		//  manufacturing
		replace branche = 2 if inlist(aggr_bran,7,8) 		 	//  construction
		replace branche = 3 if inlist(aggr_bran,9,10)			//  traffic
		replace branche = 4 if inlist(aggr_bran,11,12,13,17) 		//  trade/services

		replace branche = 5 if inlist(aggr_bran,14,15,16)  		//  public
		replace branche = 6 if inlist(aggr_bran,1) 			//  mining, agriculture, energy
		label variable branche "sector"
		label define branche_lb 1 "manufacturing" 2 "construction" 3 "traffic" 4 "services" 5 "public sector" 6 "agri mine ener"  , replace
		label values branche branche_lb

		drop aggr_bran
		drop if branche == .	
		
		* Sector: Broad definition
		gen broad_sec = .
		replace broad_sec = 1 if inlist(branche,1,2) 
		replace broad_sec = 2 if inlist(branche,3,4) 
		label variable broad_sec "sector"
		label define bbranche_lb 1 "manufacturing" 2 "services" , replace
		label values broad_sec bbranche_lb
		
		* Liability to LBT
		#delimit ;
			gen nogew = 0;
			replace nogew = 1     if inlist(w73_3_gen, 12, 20, 
			30, 31, 50, 51, 60, 80, 561, 630, 710, 711, 712, 740, 
			741, 742, 743, 744, 745, 746, 747, 748, 750, 751, 752, 753, 754, 
			755, 760, 761, 762, 764, 765, 773, 774, 780, 781, 782, 783, 784, 785, 790, 800, 841, 843, 
			845, 862, 864, 871, 872, 880, 881, 882, 883, 890, 900, 910, 911, 912, 
			920, 921, 930, 940, 950, 951, 952, 953, 954, 995, 996, 997, 998);

			* replace nogew = 1     if inlist(w73_3_gen, 0, 1, 10, 11, 12, 20, 
			30, 31, 40, 50, 51, 60, 80, 561, 630, 690, 710, 711, 712, 740, 
			741, 742, 743, 744, 745, 746, 747, 748, 750, 751, 752, 753, 754, 
			755, 764, 765, 773, 780, 781, 782, 783, 784, 785, 790, 800, 841, 843, 
			845, 862, 864, 871, 872, 880, 881, 882, 883, 890, 900, 910, 911, 912, 
			920, 921, 930, 940, 950, 951, 952, 953, 954, 995, 996, 997, 998);

		#delimit cr

		replace nogew = 1 if (branche == 5 | branche == 6) // public sector and agriculture		
		label var nogew "firm liability"
		label define placelb 0 "liable" 1 "not liable", replace
		label value nogew placelb

		* Employment type: full time vs. part-time/marginal employment
		gen emp_gr = 1				// default: full time
		replace emp_gr = 2 if inlist(stib, 8,9) // Part-time 
		* Marginal employment defined via wage
		if `wave'==2008   replace emp_gr = 2 if tentgelt <= 13.11 + 3 		//sic!
		if `wave'==2007   replace emp_gr = 2 if tentgelt <= 13.15 + 3 
		if `wave'==2006   replace emp_gr = 2 if tentgelt <= 13.15 + 3  
		if `wave'==2005   replace emp_gr = 2 if tentgelt <= 13.15 + 3  
		if `wave'==2004   replace emp_gr = 2 if tentgelt <= 13.11 + 3  
		if `wave'==2003   replace emp_gr = 2 if tentgelt <= (13.15*(9/12) + 10.68*(3/12))+ 3 
		if `wave'==2002   replace emp_gr = 2 if tentgelt <= 10.68 + 3
		if `wave'==2001   replace emp_gr = 2 if tentgelt <= 20.71/1.95583 + 3 
		if `wave'==2000   replace emp_gr = 2 if tentgelt <= 20.66/1.95583 + 3 
		if `wave'==1999   replace emp_gr = 2 if tentgelt <= 20.71/1.95583 + 3 

		if `wave'==1998   replace emp_gr = 2 if tentgelt <= 17.1/1.95583  + 3 & west==0
		if `wave'==1997   replace emp_gr = 2 if tentgelt <= 17.1/1.95583  + 3 & west==0 
		if `wave'==1996   replace emp_gr = 2 if tentgelt <= 16.39/1.95583 + 3 & west==0 
		if `wave'==1995   replace emp_gr = 2 if tentgelt <= 15.45/1.95583 + 3 & west==0 
		if `wave'==1994   replace emp_gr = 2 if tentgelt <= 14.47/1.95583 + 3 & west==0 
		if `wave'==1993   replace emp_gr = 2 if tentgelt <= 12.82/1.95583 + 3 & west==0 

		if `wave'==1998   replace emp_gr = 2 if tentgelt <= 20.38/1.95583  + 3 & west==1
		if `wave'==1997   replace emp_gr = 2 if tentgelt <= 20.05/1.95583  + 3 & west==1
		if `wave'==1996   replace emp_gr = 2 if tentgelt <= 19.34/1.95583  + 3 & west==1 
		if `wave'==1995   replace emp_gr = 2 if tentgelt <= 19.07/1.95583  + 3 & west==1 
		if `wave'==1994   replace emp_gr = 2 if tentgelt <= 18.41/1.95583  + 3 & west==1 
		if `wave'==1993   replace emp_gr = 2 if tentgelt <= 17.42/1.95583  + 3 & west==1

		label variable emp_gr "empyloment type"
		label define emp_gr_lb 1 "full time" 2 "part time" , replace
		label values emp_gr emp_gr_lb

		* Skill
		gen ski_gr = .
		replace ski_gr = 1 if bild == 5 | bild == 6 | bild == 26 | bild == 27 
		replace ski_gr = 2 if bild == 4 | bild == 3 | bild == 2 | bild == 22 | bild == 23 | bild == 24 | bild == 25
		replace ski_gr = 3 if bild == 1 | bild == 0 | bild == 21
		replace ski_gr = 1 if stib == 3 & ski_gr == .  // master craftsmen
		replace ski_gr = 2 if (stib == 2 | stib == 4) & ski_gr == .  // skilled worker or employee but not a employed master craftsmen
		replace ski_gr = 3 if stib == 1 & ski_gr == .  // unskilled worker
		drop if ski_gr == .
		label variable ski_gr "qualification"
		label define ski_gr_lb 1 "high skilled" 2 "medium skilled" 3 "low skilled", replace
		label values ski_gr ski_gr_lb

		* Occupation (Blue Collar, White Collar) 
		gen occ_gr =.
		replace occ_gr = 1 if beruf >= 11  & beruf <= 22 			//Aggriculture (Fishing, Farming)
		replace occ_gr = 2 if beruf == 31  | beruf == 32 			//Aggricultural Engineering
		replace occ_gr = 1 if beruf >= 41  & beruf <= 549			//Craftsmen 
		replace occ_gr = 2 if beruf >= 601 & beruf <= 621			//Engeneering
		replace occ_gr = 1 if beruf >= 622 & beruf <= 634			//Technicians, Laborartory assistants
		replace occ_gr = 2 if beruf == 635					//Engeneering Draftsmen
		replace occ_gr = 1 if beruf == 666					//Rehabilitand
		replace occ_gr = 2 if beruf == 681					//Wholesale Merchants
		replace occ_gr = 2 if beruf == 682					//Vendor
		replace occ_gr = 2 if beruf == 683 | beruf == 684			//Publishing Merchant, Druggist
		replace occ_gr = 2 if beruf >= 685 & beruf <= 686			//Gas Station Attendant, Assistant
		replace occ_gr = 2 if beruf == 687 | beruf == 688			//Sales Representative
		replace occ_gr = 2 if beruf >= 691 & beruf <= 706			//Merchants, Advertising Experts, Landlords
		replace occ_gr = 1 if beruf >= 711 & beruf <= 716			//Driver, Conductor, Road Maintainence 
		replace occ_gr = 1 if beruf >= 721 & beruf <= 726			//Commissioned Officier, Deck Workers, Skippers, Air Traffic
		replace occ_gr = 1 if beruf >= 731 & beruf <= 733			//Post Services, Radio Operator
		replace occ_gr = 2 if beruf == 734 | beruf == 741			//Magaziner/Lagerverwalter, Telephone Operator
		replace occ_gr = 1 if beruf >= 742 & beruf <= 744			//Mover, Storekeeper
		replace occ_gr = 2 if beruf >= 751 & beruf <= 772			//Business Man, Auditor, Admin
		replace occ_gr = 1 if beruf == 773					//Cashier
		replace occ_gr = 2 if beruf >= 774 & beruf <= 784			//Trained Assistant
		replace occ_gr = 1 if beruf >= 791 & beruf <= 805			//Watchman, Soldier, Police, Fireman, Health Services
		replace occ_gr = 2 if beruf >= 811 & beruf <= 823			//Judical Officer, Lawyer
		replace occ_gr = 2 if beruf >= 831 & beruf <= 838			//Artist
		replace occ_gr = 2 if beruf >= 841 & beruf <= 844			//Physician, Pharmacists, 
		replace occ_gr = 2 if beruf >= 851 & beruf <= 893			//Nurse, Social Worker, Teacher, Scientists
		replace occ_gr = 1 if beruf == 901 | beruf == 902			//Hair dresser etc.
		replace occ_gr = 2 if beruf >= 911 & beruf <= 923			//Barkeeper, Administrator
		replace occ_gr = 1 if beruf >= 924 & beruf <= 937			//Cleaning Service
		replace occ_gr = 1 if beruf >= 971 & beruf <= 997			//Azubis, Praktikanten, Arbeitskräfte ohne Angabe

		label define occ_gr_lb 1 "blue collar" 2 "white collar"
		label values occ_gr occ_gr_lb		
		label variable occ_gr "collar type"

		* Wage censored workers, ceilings provided by IAB
		gen grenze_w =. 
		if `wave'==2010 replace grenze_w = 180.82
		if `wave'==2009 replace grenze_w = 177.53
		if `wave'==2008 replace grenze_w = 173.77
		if `wave'==2007 replace grenze_w = 172.6
		if `wave'==2006 replace grenze_w = 172.6
		if `wave'==2005 replace grenze_w = 170.96
		if `wave'==2004 replace grenze_w = 168.85
		if `wave'==2003 replace grenze_w = 167.67
		if `wave'==2002 replace grenze_w = 147.95
		if `wave'==2001 replace grenze_w = 286.03/1.95583
		if `wave'==2000 replace grenze_w = 281.97/1.95583
		if `wave'==1999 replace grenze_w = 279.45/1.95583
		if `wave'==1998 replace grenze_w = 276.16/1.95583
		if `wave'==1997 replace grenze_w = 269.59/1.95583
		if `wave'==1996 replace grenze_w = 262.30/1.95583
		if `wave'==1995 replace grenze_w = 256.44/1.95583
		if `wave'==1994 replace grenze_w = 249.44/1.95583
		if `wave'==1993 replace grenze_w = 236.71/1.95583

		gen grenze_o =. 
		if `wave'==2010 replace grenze_o = 152.88
		if `wave'==2009 replace grenze_o = 149.59
		if `wave'==2008 replace grenze_o = 147.54	 //no mistake: it decrease from 2007 to 2008	
		if `wave'==2007 replace grenze_o = 149.59
		if `wave'==2006 replace grenze_o = 144.66
		if `wave'==2005 replace grenze_o = 144.66
		if `wave'==2004 replace grenze_o = 142.62
		if `wave'==2003 replace grenze_o = 139.73
		if `wave'==2002 replace grenze_o = 123.29
		if `wave'==2001 replace grenze_o = 240.00/1.95583
		if `wave'==2000 replace grenze_o = 232.79/1.95583
		if `wave'==1999 replace grenze_o = 236.71/1.95583
		if `wave'==1998 replace grenze_o = 230.14/1.95583
		if `wave'==1997 replace grenze_o = 233.42/1.95583
		if `wave'==1996 replace grenze_o = 222.95/1.95583
		if `wave'==1995 replace grenze_o = 210.41/1.95583
		if `wave'==1994 replace grenze_o = 193.97/1.95583
		if `wave'==1993 replace grenze_o = 174.25/1.95583

		gen grenze = grenze_w * (west==1) + grenze_o *(west==0) // combine East and West
		replace grenze = grenze - 3

		/* Es wird empfohlen, die auf der nachfolgenden Seite
		abgedruckten Grenzen um weitere zwei bis drei DM (Euro) nach unten (obere
		Grenze) bzw. oben (untere Grenze) zu korrigieren, weil sich bereits kurz vor
		der Beitragsbemessungsgrenze in den IAB-Personendaten Häufungspunkte
		befinden. Jacobebbinghaus (2008), p. 42 */

		gen cens=0
		replace cens=1 if tentgelt >= grenze		//decision made by comapring daily wages
		lab var cens "wage is top-coded"
		replace grenze = grenze * `dm_factor'  		// monthly value of ceiling

		replace wage 	= grenze 	if cens == 1 	// Adjust censored wages accordingly
		replace lwage 	= ln(grenze) 	if cens == 1    // Adjust censored wages accordingly
		drop grenze*		

		* Real wage (2008=100)
		if `wave' == 1993 replace wage = wage / 0.781
		if `wave' == 1994 replace wage = wage / 0.803
		if `wave' == 1995 replace wage = wage / 0.817
		if `wave' == 1996 replace wage = wage / 0.828
		if `wave' == 1997 replace wage = wage / 0.844
		if `wave' == 1998 replace wage = wage / 0.853
		if `wave' == 1999 replace wage = wage / 0.857
		if `wave' == 2000 replace wage = wage / 0.870
		if `wave' == 2001 replace wage = wage / 0.886
		if `wave' == 2002 replace wage = wage / 0.900
		if `wave' == 2003 replace wage = wage / 0.909
		if `wave' == 2004 replace wage = wage / 0.924
		if `wave' == 2005 replace wage = wage / 0.938
		if `wave' == 2006 replace wage = wage / 0.953
		if `wave' == 2007 replace wage = wage / 0.975
		if `wave' == 2008 replace wage = wage / 1.000
		replace lwage = ln(wage)

		label variable jahr "year"
		
		// Select variables
		keep persnr jahr idnum ao_gem bl wage - cens 

		// Save data for each wave
		sort persnr
		compress
		tempfile pers`wave'
		save `pers`wave''

	} // wave

	// Combine all waves to one worker dataset
	use `pers${start_year}', clear	
	foreach w of global wave_rest {
		append using `pers`w''
	} // foreach w

	// Generate vars using panel and test data consistency
	* Gender changers
	bysort persnr: egen minsex = min(male) 
	by     persnr: egen maxsex = max(male) 
	drop if minsex != maxsex
	drop minsex maxsex
		
	* Never-censored workers
	by persnr: egen mincens  = min(cens)
	by persnr: egen maxcens  = max(cens)
	gen nevercens = mincens == maxcens & maxcens == 0
	drop mincens maxcens cens
	label var nevercens "never censored wages"
		
	* Correct coding mistakes in BHP (slight deviation from boundary definition to tax data)
	replace ao_gem = 16061116 if inlist(ao_gem,16061009,16061042,16061073)				// Am Ohmberg
	replace ao_gem = 16062064 if inlist(ao_gem,16062001, 16062015, 16062055, 16062057, 16062017)	// Heringen, Helme
	replace ao_gem = 16066042 if inlist(ao_gem,16066031)						// Herpf
    
    	drop if jahr == 1997 
	
	// Extract firm data from individual panel and collapse to firm level (to be used in 2_BetrDat_G.do)
	preserve
	local firmvars branche broad_sec nogew
	collapse `firmvars' , by(idnum jahr) fast
	compress
	save "${data}/1_PersDat_firminfo_${pro}_${sam}.dta", replace
	
	// Save worker panel
	restore
	drop `firmvars'
	compress
	noi summ
	
	save "${data}/1_PersDat_panelI_${pro}_${sam}.dta", replace
	
} // sound

log close


***
