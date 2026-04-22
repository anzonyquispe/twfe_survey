**************************************************************
**************************************************************
*****   	do-file 2_BetrDat_G.do         		 *****
*  		  IAB project fdz259			     *
******    	   Replication file    	                ******
*	   Do Higher Corporate Taxes Reduce Wages?           *
*		Micro Evidence from Germany                  *
*** 		American Economic Review		   ***
**	(c) 2017 by C. Fuest, A. Peichl, S. Siegloch        **
**************************************************************
    
** Content: Preparation of firm data 
** Aggregation level: Firm
 
//  Preliminaries 
pause on
set more off
local sound qui
capture log close
tempfile tmpfirm
log using "${log}/2_BetrDat_${pro}.log", replace

`sound' {
	foreach wave of global wave {

		// Load firm-year dataset
		use "${orig}/iabbp_`wave'.dta", clear
		sort idnum

		// Generate variables
		* Employees
		if  `wave' == 2008 gen employees = p01ges08
		if  `wave' == 2007 gen employees = o01ges07
		if  `wave' == 2006 gen employees = n01ges06
		if  `wave' == 2005 gen employees = m01ges05
		if  `wave' == 2004 gen employees = l01ges04
		if  `wave' == 2003 gen employees = k01ges03
		if  `wave' == 2002 gen employees = j01ges02
		if  `wave' == 2001 gen employees = i01ges01
		if  `wave' == 2000 gen employees = h01ges00
		if  `wave' == 1999 gen employees = g01ges99
		if  `wave' == 1998 gen employees = f01ges98
		if  `wave' == 1997 gen employees = e01ges97
		if  `wave' == 1996 gen employees = d01ges96
		if  `wave' == 1995 gen employees = c02ges95
		if  `wave' == 1994 gen employees = b02ges94
		if  `wave' == 1993 gen employees = a01ges93

		gen employees_lev = employees
		replace employees = ln(employees)

		* Profitability
		if  `wave' == 2010 gen profit = r15
		if  `wave' == 2009 gen profit = q12
		if  `wave' == 2008 gen profit = p15
		if  `wave' == 2007 gen profit = o13
		if  `wave' == 2006 gen profit = n11
		if  `wave' == 2005 gen profit = m10
		if  `wave' == 2004 gen profit = l11
		if  `wave' == 2003 gen profit = k11
		if  `wave' == 2002 gen profit = j08
		if  `wave' == 2001 gen profit = i09
		if  `wave' == 2000 gen profit = h10
		if  `wave' == 1999 gen profit = g09
		if  `wave' == 1998 gen profit = f08b
		if  `wave' == 1997 gen profit = .
		if  `wave' == 1996 gen profit = .
		if  `wave' == 1995 gen profit = .
		if  `wave' == 1994 gen profit = .
		if  `wave' == 1993 gen profit = .

		 recode profit (-9 -8 6 = .)		// Until 2005, 6 was <<not applicable>>
		 recode profit (1 2 = 1) (3 = 2) (4 5 = 3)

		* Plant type (single vs multi plant)
		if `wave' == 1993 gen singlefirm = a73
		if `wave' == 1994 gen singlefirm = bz04
		if `wave' == 1995 gen singlefirm = cz04
		if `wave' == 1996 gen singlefirm = d78
		if `wave' == 1997 gen singlefirm = e69
		if `wave' == 1998 gen singlefirm = f79		
		if `wave' == 1999 gen singlefirm = g77
		if `wave' == 2000 gen singlefirm = h77
		if `wave' == 2001 gen singlefirm = i79
		if `wave' == 2002 gen singlefirm = j80
		if `wave' == 2003 gen singlefirm = k82
		if `wave' == 2004 gen singlefirm = l89
		if `wave' == 2005 gen singlefirm = m88
		if `wave' == 2006 gen singlefirm = n86
		if `wave' == 2007 gen singlefirm = o90
		if `wave' == 2008 gen singlefirm = p91

		if `wave' < 1998 recode singlefirm (2 = 3) (3 = 2)  // careful: 2 and 3 changed from 1998 onwards!
		replace singlefirm = . if singlefirm < 0

		/*	. missing
			1 eigenständiges unternehmen
			2 zentrale/hauptverwaltung
			3 niederl./filiale
			4 mittelinstanz
		*/
		recode singlefirm (2 3 4 =0)  // make it a dummy 

		* Foreign ownership
		if `wave' == 1993 gen foreignowned = .
		if `wave' == 1994 gen foreignowned = .
		if `wave' == 1995 gen foreignowned = .
		if `wave' == 1996 gen foreignowned = d77
		if `wave' == 1997 gen foreignowned = ez4
		if `wave' == 1998 gen foreignowned = f76
		if `wave' == 1999 gen foreignowned = g85
		if `wave' == 2000 gen foreignowned = h80
		if `wave' == 2001 gen foreignowned = i81
		if `wave' == 2002 gen foreignowned = j82
		if `wave' == 2003 gen foreignowned = k84
		if `wave' == 2004 gen foreignowned = l91
		if `wave' == 2005 gen foreignowned = m91
		if `wave' == 2006 gen foreignowned = n92
		if `wave' == 2007 gen foreignowned = o92
		if `wave' == 2008 gen foreignowned = p94
		if `wave' == 2009 gen foreignowned = q91
		if `wave' == 2010 gen foreignowned = r87

		replace foreignowned = 0 if foreignowned != 3
		replace foreignowned = 1 if foreignowned == 3

		* Legal form
		if `wave' == 1993 gen rechtsform = a74
		if `wave' == 1994 gen rechtsform = bz05
		if `wave' == 1995 gen rechtsform = cz05
		if `wave' == 1996 gen rechtsform = d79
		if `wave' == 1997 gen rechtsform = e70
		if `wave' == 1998 gen rechtsform = f69
		if `wave' == 1999 gen rechtsform = g78
		if `wave' == 2000 gen rechtsform = h78
		if `wave' == 2001 gen rechtsform = i80
		if `wave' == 2002 gen rechtsform = j81
		if `wave' == 2003 gen rechtsform = k83
		if `wave' == 2004 gen rechtsform = l90
		if `wave' == 2005 gen rechtsform = m89
		if `wave' == 2006 gen rechtsform = n91
		if `wave' == 2007 gen rechtsform = o87
		if `wave' == 2008 gen rechtsform = p89

		replace rechtsform = 5 if rechtsform < 0
		recode rechtsform (1 2=1) (3 4=2) (5 6 =3)

		/* 	1 einzelunternehmen
			2 personengesellschaft
			3 gmbh/gmbh&co. kg
			4 kapitalgesellschaft
			5 körpersch. d. öffentl. rechts
			6 sonstige rechtsform  (genossenschaften, vereine)
	      */


		* Collective bargaining agreement
		if `wave' == 2009 gen tarif = q39
		if `wave' == 2008 gen tarif = p59
		if `wave' == 2007 gen tarif = o81
		if `wave' == 2006 gen tarif = n79
		if `wave' == 2005 gen tarif = m52
		if `wave' == 2004 gen tarif = l64
		if `wave' == 2003 gen tarif = k72
		if `wave' == 2002 gen tarif = j30
		if `wave' == 2001 gen tarif = i67
		if `wave' == 2000 gen tarif = h42
		if `wave' == 1999 gen tarif = g50
		if `wave' == 1998 gen tarif = f59
		if `wave' == 1997 gen tarif = e57
		if `wave' == 1996 gen tarif = d49
		if `wave' == 1995 gen tarif = c62
		if `wave' == 1994 gen tarif = .
		if `wave' == 1993 gen tarif = .
		replace tarif = . if tarif < 0
		mvencode tarif, mv(3) override

		* Year indicator
		gen jahr = `wave'

		// Merge municipal ID via from individual data 
		
		* Load worker data
		preserve
		use "${orig}/liab_qm2_9308_v1_pers_`wave'", clear
		keep if quelle == 1
		keep if betr_st == 1
		drop if betnr == .
		drop if idnum == .
		drop if idnum == .z
		bysort idnum: egen be_min = min(betnr)
		bysort idnum: egen be_max = max(betnr)
		assert be_min == be_max
		bysort idnum: keep if _n == 1
		keep idnum betnr
		save `tmpfirm', replace 
		restore
		
		* Merge individual data to firm data via idnum (firm ID linking Establishment Panel and Worker data)
		merge 1:1 idnum using `tmpfirm', keepusing(betnr) keep(3) nogen   //non-matches because Betriebspanel != Betriebs-Historik-Panel
		
		* Merge muniID via betnr (fírm ID linking worker data and firm component of worker data)
		merge 1:1 betnr using "${orig}\liab_qm2_9308_v1_bhp_7510vorab_m06_bst_v1_`wave'", keepusing(ao_gem) keep(3) nogen
		
		drop betnr

		//  Labels
		label var profit 	"profitability"
		label define prof_lb 1 "good" 2 "satisfactory" 3 "poor", replace
		label values profit prof_lb

		label var singlefirm "establishment type"
		label define sgf_lb 0 "multi plant" 1 "stand alone" 	      
		label values singlefirm sgf_lb

		label var foreignowned "nationality of owner"
		label define fo_lb 0 "domestic" 1 "foreign"
		label values foreignowned fo_lb

		label var rechtsform "legal form"
		label define rf_lb 1 "noncorporate" 2 "corporate" 3 "other", replace
		label values rechtsform rf_lb

		label var tarif "collective agreement"
		label define tv_lb 1 "sector level" 2 "firm level" 3 "no agreement", replace
		label values tarif tv_lb

		label variable ao_gem "municipal identifier"
		keep idnum employees - ao_gem

		// Save data per wave
		sort idnum
		qui compress

		tempfile firm`wave'
		save `firm`wave'', replace

	} // wave


	// Combine waves to firm panel
	use `firm${start_year}', clear

	foreach w of global wave_rest {
		append using `firm`w''
	} // foreach w

	xtset idnum jahr

	// Use panel to gen vars and correct mistakes	
	* Wrong muni ID 
	replace ao_gem = 16061116 if inlist(ao_gem,16061009,16061042,16061073)				// A Ohmberg
	replace ao_gem = 16062064 if inlist(ao_gem,16062001, 16062015, 16062055, 16062057, 16062017)	// Heringen, Helme
	replace ao_gem = 16066042 if inlist(ao_gem,16066031)						// Herpf
	
	* Firms changing municipalities
	by     idnum: egen mingem = min(ao_gem)
	by     idnum: egen maxgem = max(ao_gem)
	gen nocommswitch = mingem == maxgem
	drop mingem maxgem
	label var nocommswitch "firm stays in municipality"

	* Firms changing legal form
	by     idnum: egen minrf = min(rechtsform)
	by     idnum: egen maxrf = max(rechtsform)
	gen norfswitch = minrf == maxrf
	drop minrf maxrf
	label var norfswitch "firm keeps legal status"
	
	* Firmsize
	gen byte firmsize = .
    	replace firmsize = 1 if employees_lev >= 1   & employees_lev  < 10
    	replace firmsize = 2 if employees_lev >= 10  & employees_lev  < 100
    	replace firmsize = 3 if employees_lev >= 100 & employees_lev  < 500
    	replace firmsize = 4 if employees_lev >= 500 & employees_lev  < .    
	label var firmsize "firmsize"
	
	* Lagged employment
	gen L2_employees = L2.employees 
	
	* Merge firm info from individual panel (sector)
	merge 1:1 idnum jahr using "${data}/1_PersDat_firminfo_${pro}_${sam}.dta", nogen keep(3)

	* Get initial values for firm choices
	local basics tarif singlefirm firmsize foreignowned profit branche broad_sec nogew
	foreach b of local basics {
		bysort idnum (jahr): gen tmp_`b' = `b' if _n ==1
		by idnum: egen `b'_base = mean(tmp_`b')
		drop tmp_`b'
		local get: variable  label `b'
		label var `b'_base "initial `get'"
		local get2: variable  label `b'_base
		local get3 : subinstr local get2 " (mean)" ""
		label var `b'_base "`get3'"
	}  // b
	
	// Save firm panel
	drop if jahr <= 1997		// only needed for the lagged firm variables
	compress
	noi sum
	save "${data}/2_BetrDat_panelF_${pro}.dta", replace

} // sound

log close

***
