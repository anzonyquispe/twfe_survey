/******************************************************************************
** Make MSA-year level data for figure 4
** Inputs: HH_firm_MSA_year.dta and HH_firm_MSA_year_9909.dta
** These datasets contain firm-MSA-year information on PCs etc. They were cleaned in a previous program.
*******************************************************************************/
*{{{
use "$HH/HH_firm_MSA_year.dta", clear
append using "$HH/HH_firm_MSA_year_9909"

***recode NECTAs
*{{{
			qui replace msa = 	70600	if msa==	12300	//Augusta-Waterville, ME
			qui replace msa = 	70750	if msa==	12620	//Bangor, ME
			qui replace msa = 	70900	if msa==	12700	//Barnstable Town, MA
			qui replace msa = 	71050	if msa==	12740	//Barre, VT
			qui replace msa = 	71350	if msa==	13540	//Bennington, VT
			qui replace msa = 	71500	if msa==	13620	//Berlin, NH-VT
			qui replace msa = 	71500	if msa==	13620	//Berlin, NH-VT
			qui replace msa = 	71650	if msa==	14460	//Boston-Cambridge-Quincy, MA-NH
			qui replace msa = 	71950	if msa==	14860	//Bridgeport-Stamford-Norwalk, CT
			qui replace msa = 	72400	if msa==	15540	//Burlington-South Burlington, VT
			qui replace msa = 	72500	if msa==	17200	//Claremont, NH
			qui replace msa = 	72700	if msa==	18180	//Concord, NH
			qui replace msa = 	73450	if msa==	25540	//Hartford-West Hartford-East Hartford, CT
			qui replace msa = 	73750	if msa==	28300	//Keene, NH
			qui replace msa = 	73900	if msa==	29060	//Laconia, NH
			qui replace msa = 	74350	if msa==	30100	//Lebanon, NH-VT
			qui replace msa = 	74650	if msa==	30340	//Lewiston-Auburn, ME
			qui replace msa = 	74950	if msa==	31700	//Manchester-Nashua, NH
			qui replace msa = 	75700	if msa==	35300	//New Haven-Milford, CT
			qui replace msa = 	76450	if msa==	35980	//Norwich-New London, CT
			qui replace msa = 	76600	if msa==	38340	//Pittsfield, MA
			qui replace msa = 	76750	if msa==	38860	//Portland-South Portland-Biddeford, ME
			qui replace msa = 	77200	if msa==	39300	//Providence-New Bedford-Fall River, RI-MA
			qui replace msa = 	77500	if msa==	40500	//Rockland, ME
			qui replace msa = 	77650	if msa==	40860	//Rutland, VT
			qui replace msa = 	78100	if msa==	44140	//Springfield, MA
			qui replace msa = 	78400	if msa==	45860	//Torrington, CT
			qui replace msa = 	79300	if msa==	48740	//Willimantic, CT
			qui replace msa = 	79600	if msa==	49340	//Worcester, MA

*}}}
ren emple sum_emp

keep if year==2000 | year==2002 | year==2004 | year==2006 | year==2008 | year==2010 | year==2012 | year==2014

gen temp = sum_emp if year==2002 | year==2004 | year==2006
bysort siteid: egen mtemp = mean(temp)

gen pc_norm_fill = totpc/mtemp
drop temp mtemp

**employment matching to 2006
gen hasmatch = pc_norm!=.
tab hasmatch
tab hasmatch [aw=sum_emp]

bysort siteid: egen Nyrs = nvals(year)
tab Nyrs if pc_norm_fill!=.

collapse hasmatch pc_norm_fill (rawsum) sum_emp [aw=sum_emp], by(msa year)

merge m:1 msa using "$data_output/msa_LF_2006"
**merge equals 1 or 2 only for micro areas
drop if _merge==2
drop _merge

merge m:1 msa using "$data_output/bartiks"
assert _merge!=2
**_merge=1 for micro areas, drop them
keep if _merge==3
egen helper = nvals(msa)
sum helper
assert r(mean)==381
drop helper
drop _merge 

ren shock_mean_sa_bartik9010 shock9010
ren shock_sa_bartik9010 shock_bw_9010
ren shock_mean_sa_level9010 level_9010
ren shock_mean_sa_bartik19010 shock1_9010 

foreach year of numlist 1999 2000 2002 2003 2004 2006 2008 2009 2010 2012 2014 {
	gen shock9010`year' = shock9010*(year==`year')
}


***bring in ACS controls again so they are available in all years
merge m:1 msa using "$data_output/ACSvars0506_msa"
	drop if _merge==2
	gen M_ACS = (_merge==1)
	foreach var of varlist ACS* {
		replace `var' = 0 if M_ACS==1
	}
	capture drop miss_ACS
	drop _merge

**MSA-level change from 2006
foreach var in pc_norm_fill {
	gen temp = `var' if year==2006
	bysort msa: egen mtemp = mean(temp)
	gen ch`var' = `var' - mtemp
	drop temp mtemp
}

gen weight = lf2006



***summary statistics for context
bysort year: sum pc_norm_fill [aw=weight], d
bysort year: sum chpc_norm_fill [aw=weight], d

save "$data_output/workingHH_msa_year", replace
*}}}
/*
/******************************************************************************
** Make firm-level crosswalk for HH<->BG
** Inputs: HH_firm_MSA_year.dta and HH_firm_MSA_year_9909.dta
** These datasets contain firm-MSA-year information on PCs etc. They were cleaned in a previous program.
**
** start with firms in both datasets that match in both pre- and post-periods
**	1. regularize HH names like we did in BG, removing spaces, punctuation, common abbreviations, etc.
**	2. look for exact matches
**	3. for non-matches, find most common (and therefore non-unique) words, find matches removing common words one-byone
**  4. make last work singular to get additional matches
**  5. match by hand for first 10 letters
**	6. regularize univ/university
*******************************************************************************/
*{{{
************************************************************************
**0. get samples that match backwards and forwards in both datasets and clean HH firm names
*{{{
***get firms in both pre- and post-periods
use "$HH/HH_firm_MSA_year.dta", replace
append using "$HH/HH_firm_MSA_year_9909"
collapse (sum) emple, by(company year)
reshape wide emple, i(company) j(year)
gen innit = (emple2002!=. | emple2004!=. | emple2006!=.) & (emple2010!=. | emple2012!=. | emple2014!=.)
display "REPORT: companies in HH matching pre- and post-periods"
display "unweighted"
tab innit
display "weighted by 2006 employment"
tab innit [aw=emple2006]
gen prewt = emple2006
replace prewt = emple2004 if prewt==.
replace prewt = emple2002 if prewt==.
display "weighted by employment in any non-missing pre-year"
tab innit [aw=prewt]
drop prewt
keep if innit==1
drop innit


***clean employer names as we did in BG (remove spaces, punctuation, abbreviations)
preserve
	keep company
	ren company employer
	duplicates drop
	gen employer_orig=employer
	*{{{
		**clean and standardize employers	
		replace employer = proper(employer)
		replace employer = trim(employer)
		egen helper = group(employer)
		display "number of unique employers"
		sum helper
		drop helper
		
		**1. replace all "&"s with "And "s with ""
		replace employer = subinstr(employer, "&", "", .)  
		replace employer = subinstr(employer, "And ", "", .)
		*replace "And" that comes at the end
		**how many could we potentially be replacing?
		display "number of possible Incs to replace"
		gen hasand = regexm(employer, "And")
		tab hasand
		replace employer = reverse(employer)
		gen loc_and = strpos(employer, "dnA")
		display "number actually replaced"
		replace employer = subinstr(employer, "dnA","",1) if loc_and==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting &s"
		sum helper
		drop helper hasand loc_and

		**2. replace Inc, Incorporated etc. with nothing
		replace employer = subinstr(employer, "Incorporated", "", .)
		replace employer = subinstr(employer, "Inc.", "", .)
		replace employer = subinstr(employer, "Inc ", "", .)
		*also replace if "Inc" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Incs to replace"
		gen hasinc = regexm(employer, "Inc")
		tab hasinc
		replace employer = reverse(employer)
		gen loc_inc = strpos(employer, "cnI")
		display "number actually replaced"
		replace employer = subinstr(employer, "cnI","",1) if loc_inc==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting INCS"
		sum helper
		drop helper loc_inc hasinc

		**3. fix Corporation
		replace employer = subinstr(employer, "Corporation","",.)
		replace employer = subinstr(employer, "Corp.","",.)
		replace employer = subinstr(employer, "Corp ","",.)
		*also replace if "Corp" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Corp to replace"
		gen hascorp = regexm(employer, "Corp")
		tab hascorp
		replace employer = reverse(employer)
		gen loc_corp = strpos(employer, "proC")
		display "number actually replaced"
		replace employer = subinstr(employer, "proC","",1) if loc_corp==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting Corp"
		sum helper
		drop helper hascorp loc_corp

		**4. fix Company
		replace employer = subinstr(employer, "Company","",.)
		replace employer = subinstr(employer, "Co.","",.)
		replace employer = subinstr(employer, "Co ","",.)
		replace employer = subinstr(employer, "Comp.","",.)
		replace employer = subinstr(employer, "Comp ","",.)
		*also replace if "Co" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Co to replace"
		gen hasco = regexm(employer, "Co")
		tab hasco
		replace employer = reverse(employer)
		gen loc_co = strpos(employer, "oC")
		display "number actually replaced"
		replace employer = subinstr(employer, "oC","",1) if loc_co==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		*also replace if "Comp" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Comp to replace"
		gen hascomp = regexm(employer, "Comp")
		tab hascomp
		replace employer = reverse(employer)
		gen loc_comp = strpos(employer, "pmoC")
		display "number actually replaced"
		replace employer = subinstr(employer, "pmoC","",1) if loc_comp==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		
		
		egen helper = group(employer)
		display "number of unique employers, correcting Co"
		sum helper
		drop helper hasco loc_co hascomp loc_comp

		**5. Llp Llc
		replace employer = subinstr(employer, "Llp","",.)
		replace employer = subinstr(employer, "L L P","",.)
		replace employer = subinstr(employer, "Llc","",.)
		replace employer = subinstr(employer, "L L C","",.)
		replace employer = subinstr(employer, "Ltd","",.)
		replace employer = subinstr(employer, "L T D","",.)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping Llp Llc"
		sum helper
		drop helper

		**6. USA or Us followed by a space or at the end or American or America any time
		replace employer = subinstr(employer, "Usa ","",.)
		replace employer = subinstr(employer, "Us ","",.)
		replace employer = subinstr(employer, "American","",.)
		replace employer = subinstr(employer, "Americas","",.)
		replace employer = subinstr(employer, "America's","",.)
		replace employer = subinstr(employer, "America","",.)
		*also replace if "Usa" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Usa to replace"
		gen hasusa = regexm(employer, "Usa")
		tab hasusa
		replace employer = reverse(employer)
		gen loc_usa = strpos(employer, "asU")
		display "number actually replaced"
		replace employer = subinstr(employer, "asU","",1) if loc_usa==1
		drop hasusa loc_usa
		gen hasus = regexm(employer,"sU")
		tab hasus
		gen loc_us = strpos(employer, "sU")
		display "number actually replaced"
		replace employer = subinstr(employer, "sU","",1) if loc_us==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping USA"
		sum helper
		drop helper loc_us hasus

		**7. Partnerships
		replace employer = subinstr(employer, "Partnerships","",.)
		replace employer = subinstr(employer, "Partners ","",.)
		replace employer = subinstr(employer, "Part.","",.)
		*also replace if "Partners" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Usa to replace"
		gen haspartners = regexm(employer, "Partners")
		tab haspartners
		replace employer = reverse(employer)
		gen loc_partners = strpos(employer, "srentraP")
		display "number actually replaced"
		replace employer = subinstr(employer, "srentraP","",1) if loc_partners==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping Partners"
		sum helper
		drop helper loc_partners haspartners

		**8. Associates
		replace employer = subinstr(employer, "Associates","",.)
		replace employer = subinstr(employer, "Assoc.","",.)
		replace employer = subinstr(employer, "Assoc ","",.)
		*also replace if "Partners" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Assoc to replace"
		gen hasassoc = regexm(employer, "Assoc")
		tab hasassoc
		replace employer = reverse(employer)
		gen loc_assoc = strpos(employer, "cossA")
		display "number actually replaced"
		replace employer = subinstr(employer, "cossA","",1) if loc_assoc==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping Partners"
		sum helper
		drop helper loc_assoc hasassoc

		**9. International
		replace employer = subinstr(employer, "International", "", .)
		replace employer = subinstr(employer, "Int.", "", .)
		replace employer = subinstr(employer, "Int ", "", .)
		*also replace if "Int" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Ints to replace"
		gen hasint = regexm(employer, "Int")
		tab hasint
		replace employer = reverse(employer)
		gen loc_int = strpos(employer, "tnI")
		display "number actually replaced"
		replace employer = subinstr(employer, "tnI","",1) if loc_int==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting INTS"
		sum helper
		drop helper loc_int hasint
		
		**9. replace all punctuation with spaces and then get rid of extra spaces
		replace employer = subinstr(employer, "."," ",.)
		replace employer = subinstr(employer, ","," ",.)
		replace employer = subinstr(employer, ","," ",.)
		replace employer = subinstr(employer, "?"," ",.)
		replace employer = subinstr(employer, ";"," ",.)
		replace employer = subinstr(employer, "!"," ",.)
		replace employer = subinstr(employer, "@"," ",.)
		replace employer = subinstr(employer, "#"," ",.)
		replace employer = subinstr(employer, "$"," ",.)
		replace employer = subinstr(employer, "%"," ",.)
		replace employer = subinstr(employer, "*"," ",.)
		replace employer = subinstr(employer, "/"," ",.)
		replace employer = subinstr(employer, ")"," ",.)
		replace employer = subinstr(employer, "("," ",.)
		replace employer = subinstr(employer, "}"," ",.)
		replace employer = subinstr(employer, "{"," ",.)
		replace employer = subinstr(employer, "["," ",.)
		replace employer = subinstr(employer, "]"," ",.)
		replace employer = subinstr(employer, "\"," ",.)
		replace employer = subinstr(employer, "'"," ",.)
		replace employer = subinstr(employer, "|"," ",.)
		replace employer = subinstr(employer, "-"," ",.)
		replace employer = subinstr(employer, "_"," ",.)
		replace employer = subinstr(employer, "="," ",.)
		replace employer = subinstr(employer, ":"," ",.)
		replace employer = subinstr(employer, "^"," ",.)

		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, removing punctuation"
		sum helper
		drop helper

		replace employer = proper(employer)
*}}}
	keep employer employer_orig
	ren employer employer_temp
	ren employer_orig employer
	tempfile cleannames
	save `cleannames', replace
restore

ren company employer
merge m:1 employer using `cleannames'
assert _merge==3
drop _merge
ren employer employer_orig
ren employer_temp employer

collapse (sum) emple*, by(employer)
keep if employer!=""
gen emp_nospace = subinstr(employer," ","",.)
replace emp_nospace = lower(emp_nospace)

preserve
	keep emp_nospace employer emple2006 emple2010
	duplicates drop
	ren employer company
	save "$HH/crosswalk_company_emp_nospace", replace
restore

bysort emp_nospace: gen counter = _N
tab counter
collapse (sum) emple*, by(emp_nospace) 
save "$HH/HH_empnames", replace
	

***keep only BG firms that post in 2007 and at least 1 subsequent year
use "$data_output/BG_hasfirm_employer_msa_year", clear
collapse (sum) npostings, by(emp_nospace year)
reshape wide npostings, i(emp_nospace) j(year)
gen innit = npostings2007!=. & (npostings2010!=. | npostings2011!=. | npostings2012!=. | npostings2013!=. | npostings2014!=. | npostings2015!=.)
display "REPORT: companies in BG matching to 2010-2015 year"
tab innit
tab innit [aw=npostings2007]
keep if innit==1
drop innit
	
bysort emp_nospace: gen counter = _N
tab counter
collapse (sum) npostings*, by(emp_nospace)
tempfile allfirmsBG
save `allfirmsBG', replace
*}}}
***********************************************************************

**********************************************************************
***1. Exact matches
**********************************************************************
*{{{
***matches
display "REPORT 1: exact matches"
merge 1:1 emp_nospace using "$HH/HH_empnames"
tab _merge [aw=npostings2007]
tab _merge [aw=emple2006]
	
export delim emp_nospace npostings2007 using "$data_output/BGnonmatches" if _merge==1, replace
export delim emp_nospace emple2006 using "$data_output/HHnonmatches" if _merge==2, replace
	
gen nomatchBG = (_merge==1)
gen nomatchHH = (_merge==2)
drop _merge

save "$data_output/BG_HH_all", replace
	
use "$data_output/BG_HH_all", clear
keep if nomatchBG==0 & nomatchHH==0
drop nomatch*
duplicates tag emp_nospace, gen(dup)
assert dup==0
drop dup
	
gen matchID=_n
sum matchID, d
local last = r(max)
display "last = `last'"
	
gen exact = 1
save "$data_output/temp_BGmatches", replace
d
save "$data_output/temp_HHmatches", replace
d
		
use "$data_output/BG_HH_all", clear
keep if nomatchBG==1 | nomatchHH==1
save "$data_output/temp_nomatches", replace
*}}}	

************************************************************************
***2. omit common words one-by-one
************************************************************************
*{{{
**HH often has an extra word "insurance" "hotel" group" omit one-by-one and get new matches
foreach word in insurance group hotel center services service the systems system construction products department church electric club bank community industries inn manufacturing clinic auto office management technologies technology enterprises solutions association communications  restaurant restaurants {
	use "$data_output/temp_nomatches", clear
	keep if nomatchBG==1 
	gen temp_emp = subinstr(emp_nospace,"`word'","",.)
	***keep all employer names
	preserve
	keep temp_emp emp_nospace 
	duplicates drop
	tempfile crosswalkBG
	save `crosswalkBG', replace
	restore
	collapse (sum) npostings*, by(temp_emp)
	merge 1:m temp_emp using `crosswalkBG'
	assert _merge==3
	drop _merge
	bysort temp_emp: gen counter = _n
	ren emp_nospace BGemp_nospace
	reshape wide BGemp_nospace, i(temp_emp) j(counter)
	tempfile BG
	save `BG', replace
		
	use "$data_output/temp_nomatches", clear
	keep if nomatchHH==1 
	gen temp_emp = subinstr(emp_nospace,"`word'","",.)
	***get new crosswalk
	preserve
	keep emp_nospace temp_emp
	duplicates drop
	tempfile crosswalkHH
	save `crosswalkHH', replace
	restore
	collapse (sum) emple*, by(temp_emp)
	merge 1:m temp_emp using `crosswalkHH'
	assert _merge==3
	drop _merge
	bysort temp_emp: gen counter = _n
	ren emp_nospace HHemp_nospace
	reshape wide HHemp_nospace, i(temp_emp) j(counter)
		
	merge 1:1 temp_emp using `BG'
	list temp_emp BGemp_nospace1  HHemp_nospace1 HHemp_nospace2 if _merge==3, sep(0)
	
	count if _merge==3
	local helper = r(N)
	if `helper'>0 {
		preserve
		keep if _merge==3
		drop _merge
		gen index = _n
		tempfile matches
		save `matches', replace
		
		use `matches', clear
		keep temp_emp BG* index
		reshape long BGemp_nospace, i(temp_emp) j(counter)
		keep if BGemp_nospace!=""
		ren BGemp_nospace emp_nospace
		gen matchID=`last' + index
		list
		drop temp_emp counter index
		gen common=1
		append using "$data_output/temp_BGmatches"
		save "$data_output/temp_BGmatches", replace

		use `matches', clear
		keep temp_emp HH* index
		reshape long HHemp_nospace, i(temp_emp) j(counter)
		keep if HHemp_nospace!=""
		ren HHemp_nospace emp_nospace
		gen matchID=`last' + index
		list 
		drop temp_emp counter index
		sum matchID
		local last = r(max)
		display "last = `last'"
		gen common=1
		append using "$data_output/temp_HHmatches"
		save "$data_output/temp_HHmatches", replace
		
		restore
		keep if _merge==1 | _merge==2
		gen nomatchHH = (_merge==1)
		gen nomatchBG = (_merge==2)
		drop _merge
		
		***make long so that program will run for next word replace
		reshape long BGemp_nospace HHemp_nospace, i(temp_emp) j(counter)
		drop if BGemp_nospace=="" & HHemp_nospace==""
		***non-matches so will only have BG or HH name
		assert BGemp_nospace=="" if HHemp_nospace!=""
		assert BGemp_nospace!="" if HHemp_nospace==""
		gen emp_nospace = BGemp_nospace
		replace emp_nospace = HHemp_nospace if emp_nospace==""
		drop counter temp_emp BGemp_nospace HHemp_nospace
		
		***this dataset does not have the original employer or company variables
		***dataset will also have screwed up npostings and emples, just replace with originals later
		save "$data_output/temp_nomatches", replace
	}
		
}
*}}}

********************************************************************************
***3. make last word singluar and see if there are additional matches
*******************************************************************************
*{{{
	use "$data_output/temp_nomatches", replace
	keep if nomatchBG==1
	gen length = length(emp_nospace)
	gen temp = substr(emp_nospace,length,.)
	assert temp!=""
	gen until = length-1
	gen temp_emp = substr(emp_nospace,1,until) if temp=="s"
	replace temp_emp = emp_nospace if temp_emp==""
	drop length temp until
	
	**keep all employer names
	preserve
	keep temp_emp emp_nospace
	duplicates drop
	tempfile crosswalkBG
	save `crosswalkBG', replace
	restore
	collapse (sum) npostings*, by(temp_emp)
	merge 1:m temp_emp using `crosswalkBG'
	assert _merge==3
	drop _merge
	bysort temp_emp: gen counter = _n
	ren emp_nospace BGemp_nospace
	reshape wide BGemp_nospace, i(temp_emp) j(counter)
	tempfile BG
	save `BG', replace

	use "$data_output/temp_nomatches", clear
	keep if nomatchHH==1 
	gen length = length(emp_nospace)
	gen temp = substr(emp_nospace,length,.)
	assert temp!=""
	gen until = length-1
	gen temp_emp = substr(emp_nospace,1,until) if temp=="s"
	replace temp_emp = emp_nospace if temp_emp==""
	drop length temp until
	
	***get new crosswalk
	preserve
	keep emp_nospace temp_emp
	duplicates drop
	tempfile crosswalkHH
	save `crosswalkHH', replace
	restore
	collapse (sum) emple*, by(temp_emp)
	merge 1:m temp_emp using `crosswalkHH'
	assert _merge==3
	drop _merge
	bysort temp_emp: gen counter = _n
	ren emp_nospace HHemp_nospace
	reshape wide HHemp_nospace, i(temp_emp) j(counter)
		
	merge 1:1 temp_emp using `BG'
	list temp_emp BGemp_nospace1  HHemp_nospace1 HHemp_nospace2 if _merge==3, sep(0)
		preserve
		keep if _merge==3
		drop _merge
		gen index = _n
		tempfile matches
		save `matches', replace
		
		use `matches', clear
		keep temp_emp BG* index
		reshape long BGemp_nospace, i(temp_emp) j(counter)
		keep if BGemp_nospace!=""
		ren BGemp_nospace emp_nospace
		gen matchID=`last' + index
		list
		drop temp_emp counter index
		gen singular = 1
		append using "$data_output/temp_BGmatches"
		save "$data_output/temp_BGmatches", replace

		use `matches', clear
		keep temp_emp HH* index
		reshape long HHemp_nospace, i(temp_emp) j(counter)
		keep if HHemp_nospace!=""
		ren HHemp_nospace emp_nospace
		gen matchID=`last' + index
		list 
		drop temp_emp counter index
		sum matchID
		local last = r(max)
		gen singular = 1
		append using "$data_output/temp_HHmatches"
		save "$data_output/temp_HHmatches", replace
		
	restore
	keep if _merge==1 | _merge==2
	gen nomatchHH = (_merge==1)
	gen nomatchBG = (_merge==2)
	drop _merge
	***make long so that program will run for next word replace
	reshape long BGemp_nospace HHemp_nospace, i(temp_emp) j(counter)
	drop if BGemp_nospace=="" & HHemp_nospace==""
	***non-matches so will only have BG or HH name
	assert BGemp_nospace=="" if HHemp_nospace!=""
	assert BGemp_nospace!="" if HHemp_nospace==""
	gen emp_nospace = BGemp_nospace
	replace emp_nospace = HHemp_nospace if emp_nospace==""
	drop counter temp_emp BGemp_nospace HHemp_nospace
		
	***this dataset does not have the original employer or company variables
	***dataset will also have screwed up npostings and emples, just replace with originals later
	save "$data_output/temp_nomatches", replace
*}}}	


********************************************************************************
***4. align univ and university
*******************************************************************************
*{{{
	use "$data_output/temp_nomatches", replace
	keep if nomatchBG==1
	gen temp_emp = subinstr(emp_nospace,"university","univ",.)
	
	**keep all employer names
	preserve
	keep temp_emp emp_nospace
	duplicates drop
	tempfile crosswalkBG
	save `crosswalkBG', replace
	restore
	collapse (sum) npostings*, by(temp_emp)
	merge 1:m temp_emp using `crosswalkBG'
	assert _merge==3
	drop _merge
	bysort temp_emp: gen counter = _n
	ren emp_nospace BGemp_nospace
	reshape wide BGemp_nospace, i(temp_emp) j(counter)
	tempfile BG
	save `BG', replace

	use "$data_output/temp_nomatches", clear
	keep if nomatchHH==1 
	gen temp_emp = subinstr(emp_nospace,"university","univ",.)
	
	***get new crosswalk
	preserve
	keep emp_nospace temp_emp
	duplicates drop
	tempfile crosswalkHH
	save `crosswalkHH', replace
	restore
	collapse (sum) emple*, by(temp_emp)
	merge 1:m temp_emp using `crosswalkHH'
	assert _merge==3
	drop _merge
	bysort temp_emp: gen counter = _n
	ren emp_nospace HHemp_nospace
	reshape wide HHemp_nospace, i(temp_emp) j(counter)
		
	merge 1:1 temp_emp using `BG'
	list temp_emp BGemp_nospace1  HHemp_nospace1 HHemp_nospace2 if _merge==3, sep(0)

	preserve
		keep if _merge==3
		drop _merge
		gen index = _n
		tempfile matches
		save `matches', replace
		
		use `matches', clear
		keep temp_emp BG* index
		reshape long BGemp_nospace, i(temp_emp) j(counter)
		keep if BGemp_nospace!=""
		ren BGemp_nospace emp_nospace
		gen matchID=`last' + index
		list
		drop temp_emp counter index
		gen univ=1
		append using "$data_output/temp_BGmatches"
		save "$data_output/temp_BGmatches", replace

		use `matches', clear
		keep temp_emp HH* index
		reshape long HHemp_nospace, i(temp_emp) j(counter)
		keep if HHemp_nospace!=""
		ren HHemp_nospace emp_nospace
		gen matchID=`last' + index
		list 
		drop temp_emp counter index
		sum matchID
		local last = r(max)
		gen univ=1
		append using "$data_output/temp_HHmatches"
		save "$data_output/temp_HHmatches", replace
		
	restore
	keep if _merge==1 | _merge==2
	gen nomatchHH = (_merge==1)
	gen nomatchBG = (_merge==2)
	drop _merge
	***make long so that program will run for next word replace
	reshape long BGemp_nospace HHemp_nospace, i(temp_emp) j(counter)
	drop if BGemp_nospace=="" & HHemp_nospace==""
	***non-matches so will only have BG or HH name
	assert BGemp_nospace=="" if HHemp_nospace!=""
	assert BGemp_nospace!="" if HHemp_nospace==""
	gen emp_nospace = BGemp_nospace
	replace emp_nospace = HHemp_nospace if emp_nospace==""
	drop counter temp_emp BGemp_nospace HHemp_nospace
		
	***this dataset does not have the original employer or company variables
	***dataset will also have screwed up npostings and emples, just replace with originals later
	save "$data_output/temp_nomatches", replace
*}}}	


*********************************************************************
***5. matches from first 10 letters and find real matches
**only look by hand for BG employers with at least 50 ads (miss about 1/3 of possible matches)
*******************************************************************
*{{{
use "$data_output/temp_nomatches", clear
keep if nomatchBG==1
gen temp = substr(emp_nospace,1,10)
keep temp emp_nospace npostings2007
**sort in alphabetical order
sort temp emp_nospace
by temp: gen counter = _n
by temp: egen totpost = sum(npostings2007)
drop npostings2007
ren emp_nospace BGemp

***obs with tons of common names prob not matches so drop those with tons
bysort temp: gen all = _N
sum all, d
keep if all<10
drop all
reshape wide BGemp, i(temp) j(counter)
tempfile BG
save `BG', replace

use "$data_output/temp_nomatches", clear
keep if nomatchHH==1
gen temp = substr(emp_nospace,1,10)
keep temp emp_nospace
sort temp emp_nospace
by temp: gen counter = _n
sum counter 
local until = r(max)
ren emp_nospace HHemp
***obs with tons of common names prob not matches so drop those with tons
bysort temp: gen all = _N
sum all, d
keep if all<10
drop all

reshape wide HHemp, i(temp) j(counter)

merge 1:1 temp using `BG'
keep if _merge==3


order temp totpost BGemp1 BGemp2 BGemp3 HHemp1 HHemp2 HHemp3 BGemp4
gsort -totpost

export delim "$data_output/matches10", replace


/******************************************************************************
***bring in actual matches and align ID
****************************************************************************/
use "$data_output/temp_BGmatches", clear
assert matchID!=.
sum matchID
local last = r(max)

import delim "$data_output/matches10_clean.txt", clear
*capture drop v*
keep if bgemp!=""
ren bgemp emp_nospace
drop hhemp temp
ren matchid matchID
replace matchID = `last'+matchID
preserve
gen first10=1
append using "$data_output/temp_BGmatches"
save "$data_output/temp_BGmatches", replace
restore
merge 1:1 emp_nospace using "$data_output/temp_nomatches"
drop if _merge==3
drop _merge
save "$data_output/temp_nomatches", replace

import delim "$data_output/matches10_clean.txt", clear
*drop v*
keep if hhemp!=""
ren hhemp emp_nospace
drop bgemp temp
ren matchid matchID
replace matchID = `last'+matchID
preserve
gen first10=1
append using "$data_output/temp_HHmatches"
save "$data_output/temp_HHmatches", replace
restore
merge 1:1 emp_nospace using "$data_output/temp_nomatches"
drop if _merge==3
drop _merge
save "$data_output/temp_nomatches", replace
*}}}


******************************************************************************
****Now bring everything together  
*******************************************************************************
*{{{
use "$data_output/temp_BGmatches", clear

foreach var in common exact singular univ first10 {
*foreach var in common exact first10 singular top100 univ {
	replace `var' = 0 if `var'==.
}
assert common + exact + singular + univ + first10 ==1
drop npostings*

merge 1:1 emp_nospace using `allfirmsBG'
assert _merge==2 | _merge==3
gen nomatch = _merge==2
****types of matches
bysort emp_nospace: gen counter = _N
assert counter==1
drop counter
gen match_type = -9 if nomatch==1
replace match_type = 1 if exact==1
replace match_type = 2 if singular==1
replace match_type = 3 if common==1
replace match_type = 4 if univ==1
replace match_type = 5 if first10==1
assert match_type!=.
label define type 1 "exact" 2 "singular" 3 "common" 4 "univ" 5 "first10"
label values match_type type
display "match type, weighted and unweighted"
tab match_type
tab match_type [aw=npostings2007]
tab match_type [aw=npostings2010]

keep if nomatch==0
drop nomatch
display "only among matches"
tab match_type
tab match_type [aw=npostings2007]
tab match_type [aw=npostings2010]

keep matchID emp_nospace match_type
save "$HH/matchID_employer_allyrs2", replace

use "$data_output/temp_HHmatches", clear
drop emple*
merge 1:m emp_nospace using "$HH/crosswalk_company_emp_nospace"
assert _merge==2 | _merge==3
gen nomatch = _merge==2
****types of matches
bysort company: gen counter = _N
assert counter==1
drop counter
gen match_type = -9 if nomatch==1
replace match_type = 1 if exact==1
replace match_type = 2 if singular==1
replace match_type = 3 if common==1
replace match_type = 4 if univ==1
*replace match_type = 5 if top100==1
replace match_type = 5 if first10==1
assert match_type!=.
label define type 1 "exact" 2 "singular" 3 "common" 4 "univ" 5 "first10" -9 "no matach"
label values match_type type
display "match type, weighted and unweighted"
tab match_type
tab match_type [aw=emple2006]
tab match_type [aw=emple2010]

keep if nomatch==0
drop nomatch
display "only among matches"
tab match_type
tab match_type [aw=emple2006]
tab match_type [aw=emple2006]
keep matchID company match_type
ren match_type HHmatch_type
save "$HH/matchID_company_allyrs2", replace
*}}}

*}}}
*/
/******************************************************************************
** Get firm-level capital vars from HH
** Inputs: HH_firm_MSA_year.dta and HH_firm_MSA_year_9909.dta
** (These datasets contain firm-MSA-year information on PCs etc. They were cleaned in a previous program.)
** matchID_company_allyrs2.dta -- crosswalk made above
*******************************************************************************/
*{{{
use "$HH/HH_firm_MSA_year.dta", clear
append using "$HH/HH_firm_MSA_year_9909"

***clean employer names
	preserve
	keep company
	ren company employer
	duplicates drop
	gen employer_orig=employer
	*{{{
		**clean and standardize employers	
		replace employer = proper(employer)
		replace employer = trim(employer)
		egen helper = group(employer)
		display "number of unique employers"
		sum helper
		drop helper
		
		**1. replace all "&"s with "And "s with ""
		replace employer = subinstr(employer, "&", "", .)  
		replace employer = subinstr(employer, "And ", "", .)
		*replace "And" that comes at the end
		**how many could we potentially be replacing?
		display "number of possible Incs to replace"
		gen hasand = regexm(employer, "And")
		tab hasand
		replace employer = reverse(employer)
		gen loc_and = strpos(employer, "dnA")
		display "number actually replaced"
		replace employer = subinstr(employer, "dnA","",1) if loc_and==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting &s"
		sum helper
		drop helper hasand loc_and

		**2. replace Inc, Incorporated etc. with nothing
		replace employer = subinstr(employer, "Incorporated", "", .)
		replace employer = subinstr(employer, "Inc.", "", .)
		replace employer = subinstr(employer, "Inc ", "", .)
		*also replace if "Inc" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Incs to replace"
		gen hasinc = regexm(employer, "Inc")
		tab hasinc
		replace employer = reverse(employer)
		gen loc_inc = strpos(employer, "cnI")
		display "number actually replaced"
		replace employer = subinstr(employer, "cnI","",1) if loc_inc==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting INCS"
		sum helper
		drop helper loc_inc hasinc

		**3. fix Corporation
		replace employer = subinstr(employer, "Corporation","",.)
		replace employer = subinstr(employer, "Corp.","",.)
		replace employer = subinstr(employer, "Corp ","",.)
		*also replace if "Corp" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Corp to replace"
		gen hascorp = regexm(employer, "Corp")
		tab hascorp
		replace employer = reverse(employer)
		gen loc_corp = strpos(employer, "proC")
		display "number actually replaced"
		replace employer = subinstr(employer, "proC","",1) if loc_corp==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting Corp"
		sum helper
		drop helper hascorp loc_corp

		**4. fix Company
		replace employer = subinstr(employer, "Company","",.)
		replace employer = subinstr(employer, "Co.","",.)
		replace employer = subinstr(employer, "Co ","",.)
		replace employer = subinstr(employer, "Comp.","",.)
		replace employer = subinstr(employer, "Comp ","",.)
		*also replace if "Co" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Co to replace"
		gen hasco = regexm(employer, "Co")
		tab hasco
		replace employer = reverse(employer)
		gen loc_co = strpos(employer, "oC")
		display "number actually replaced"
		replace employer = subinstr(employer, "oC","",1) if loc_co==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		*also replace if "Comp" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Comp to replace"
		gen hascomp = regexm(employer, "Comp")
		tab hascomp
		replace employer = reverse(employer)
		gen loc_comp = strpos(employer, "pmoC")
		display "number actually replaced"
		replace employer = subinstr(employer, "pmoC","",1) if loc_comp==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		
		
		egen helper = group(employer)
		display "number of unique employers, correcting Co"
		sum helper
		drop helper hasco loc_co hascomp loc_comp

		**5. Llp Llc
		replace employer = subinstr(employer, "Llp","",.)
		replace employer = subinstr(employer, "L L P","",.)
		replace employer = subinstr(employer, "Llc","",.)
		replace employer = subinstr(employer, "L L C","",.)
		replace employer = subinstr(employer, "Ltd","",.)
		replace employer = subinstr(employer, "L T D","",.)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping Llp Llc"
		sum helper
		drop helper

		**6. USA or Us followed by a space or at the end or American or America any time
		replace employer = subinstr(employer, "Usa ","",.)
		replace employer = subinstr(employer, "Us ","",.)
		replace employer = subinstr(employer, "American","",.)
		replace employer = subinstr(employer, "Americas","",.)
		replace employer = subinstr(employer, "America's","",.)
		replace employer = subinstr(employer, "America","",.)
		*also replace if "Usa" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Usa to replace"
		gen hasusa = regexm(employer, "Usa")
		tab hasusa
		replace employer = reverse(employer)
		gen loc_usa = strpos(employer, "asU")
		display "number actually replaced"
		replace employer = subinstr(employer, "asU","",1) if loc_usa==1
		drop hasusa loc_usa
		gen hasus = regexm(employer,"sU")
		tab hasus
		gen loc_us = strpos(employer, "sU")
		display "number actually replaced"
		replace employer = subinstr(employer, "sU","",1) if loc_us==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping USA"
		sum helper
		drop helper loc_us hasus

		**7. Partnerships
		replace employer = subinstr(employer, "Partnerships","",.)
		replace employer = subinstr(employer, "Partners ","",.)
		replace employer = subinstr(employer, "Part.","",.)
		*also replace if "Partners" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Usa to replace"
		gen haspartners = regexm(employer, "Partners")
		tab haspartners
		replace employer = reverse(employer)
		gen loc_partners = strpos(employer, "srentraP")
		display "number actually replaced"
		replace employer = subinstr(employer, "srentraP","",1) if loc_partners==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping Partners"
		sum helper
		drop helper loc_partners haspartners

		**8. Associates
		replace employer = subinstr(employer, "Associates","",.)
		replace employer = subinstr(employer, "Assoc.","",.)
		replace employer = subinstr(employer, "Assoc ","",.)
		*also replace if "Partners" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Assoc to replace"
		gen hasassoc = regexm(employer, "Assoc")
		tab hasassoc
		replace employer = reverse(employer)
		gen loc_assoc = strpos(employer, "cossA")
		display "number actually replaced"
		replace employer = subinstr(employer, "cossA","",1) if loc_assoc==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, Dropping Partners"
		sum helper
		drop helper loc_assoc hasassoc

		**9. International
		replace employer = subinstr(employer, "International", "", .)
		replace employer = subinstr(employer, "Int.", "", .)
		replace employer = subinstr(employer, "Int ", "", .)
		*also replace if "Int" is at the END of the string
		**how many could we potentially be replacing?
		display "number of possible Ints to replace"
		gen hasint = regexm(employer, "Int")
		tab hasint
		replace employer = reverse(employer)
		gen loc_int = strpos(employer, "tnI")
		display "number actually replaced"
		replace employer = subinstr(employer, "tnI","",1) if loc_int==1
		replace employer = reverse(employer)
		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, correcting INTS"
		sum helper
		drop helper loc_int hasint
		
		**9. replace all punctuation with spaces and then get rid of extra spaces
		replace employer = subinstr(employer, "."," ",.)
		replace employer = subinstr(employer, ","," ",.)
		replace employer = subinstr(employer, ","," ",.)
		replace employer = subinstr(employer, "?"," ",.)
		replace employer = subinstr(employer, ";"," ",.)
		replace employer = subinstr(employer, "!"," ",.)
		replace employer = subinstr(employer, "@"," ",.)
		replace employer = subinstr(employer, "#"," ",.)
		replace employer = subinstr(employer, "$"," ",.)
		replace employer = subinstr(employer, "%"," ",.)
		replace employer = subinstr(employer, "*"," ",.)
		replace employer = subinstr(employer, "/"," ",.)
		replace employer = subinstr(employer, ")"," ",.)
		replace employer = subinstr(employer, "("," ",.)
		replace employer = subinstr(employer, "}"," ",.)
		replace employer = subinstr(employer, "{"," ",.)
		replace employer = subinstr(employer, "["," ",.)
		replace employer = subinstr(employer, "]"," ",.)
		replace employer = subinstr(employer, "\"," ",.)
		replace employer = subinstr(employer, "'"," ",.)
		replace employer = subinstr(employer, "|"," ",.)
		replace employer = subinstr(employer, "-"," ",.)
		replace employer = subinstr(employer, "_"," ",.)
		replace employer = subinstr(employer, "="," ",.)
		replace employer = subinstr(employer, ":"," ",.)
		replace employer = subinstr(employer, "^"," ",.)

		replace employer = trim(employer)
		replace employer = itrim(employer)
		egen helper = group(employer)
		display "number of unique employers, removing punctuation"
		sum helper
		drop helper

		replace employer = proper(employer)
*}}}
	keep employer employer_orig
	ren employer employer_temp
	ren employer_orig employer
	tempfile cleannames
	save `cleannames', replace
	restore
	ren company employer
	merge m:1 employer using `cleannames'
	assert _merge==3
	drop _merge
	ren employer employer_orig
	ren employer_temp company

****collapse to unique company name
ren emple sum_emp
collapse (rawsum) sum_emp totpc [aw=sum_emp], by(company msa year)

***recode NECTAs
*{{{
			qui replace msa = 	70600	if msa==	12300	//Augusta-Waterville, ME
			qui replace msa = 	70750	if msa==	12620	//Bangor, ME
			qui replace msa = 	70900	if msa==	12700	//Barnstable Town, MA
			qui replace msa = 	71050	if msa==	12740	//Barre, VT
			qui replace msa = 	71350	if msa==	13540	//Bennington, VT
			qui replace msa = 	71500	if msa==	13620	//Berlin, NH-VT
			qui replace msa = 	71500	if msa==	13620	//Berlin, NH-VT
			qui replace msa = 	71650	if msa==	14460	//Boston-Cambridge-Quincy, MA-NH
			qui replace msa = 	71950	if msa==	14860	//Bridgeport-Stamford-Norwalk, CT
			qui replace msa = 	72400	if msa==	15540	//Burlington-South Burlington, VT
			qui replace msa = 	72500	if msa==	17200	//Claremont, NH
			qui replace msa = 	72700	if msa==	18180	//Concord, NH
			qui replace msa = 	73450	if msa==	25540	//Hartford-West Hartford-East Hartford, CT
			qui replace msa = 	73750	if msa==	28300	//Keene, NH
			qui replace msa = 	73900	if msa==	29060	//Laconia, NH
			qui replace msa = 	74350	if msa==	30100	//Lebanon, NH-VT
			qui replace msa = 	74650	if msa==	30340	//Lewiston-Auburn, ME
			qui replace msa = 	74950	if msa==	31700	//Manchester-Nashua, NH
			qui replace msa = 	75700	if msa==	35300	//New Haven-Milford, CT
			qui replace msa = 	76450	if msa==	35980	//Norwich-New London, CT
			qui replace msa = 	76600	if msa==	38340	//Pittsfield, MA
			qui replace msa = 	76750	if msa==	38860	//Portland-South Portland-Biddeford, ME
			qui replace msa = 	77200	if msa==	39300	//Providence-New Bedford-Fall River, RI-MA
			qui replace msa = 	77500	if msa==	40500	//Rockland, ME
			qui replace msa = 	77650	if msa==	40860	//Rutland, VT
			qui replace msa = 	78100	if msa==	44140	//Springfield, MA
			qui replace msa = 	78400	if msa==	45860	//Torrington, CT
			qui replace msa = 	79300	if msa==	48740	//Willimantic, CT
			qui replace msa = 	79600	if msa==	49340	//Worcester, MA

*}}}

merge m:1 company using "$HH/matchID_company_allyrs2"
assert _merge!=2
keep if _merge==3
drop _merge
assert matchID!=.
drop if msa==.

**aggregate over msas
collapse totpc (rawsum) sum_emp [aw=sum_emp], by(matchID year)

keep sum_emp matchID year totpc

gen temp = totpc if year==2006
bysort matchID: egen mtemp = mean(temp)
gen chtotpc = totpc-mtemp
drop temp mtemp

keep if chtotpc!=.

reshape wide totpc chtotpc sum_emp, i(matchID) j(year)

gen num = 0
gen denom = 0
foreach year in 2010 2012 2014 {
	replace denom = denom + 1 if totpc`year'!=.
	replace num = num + totpc`year' if totpc`year'!=.
}
gen post_full = num/denom
drop num denom

foreach var in totpc sum_emp {
	gen num = 0
	gen denom = 0
	foreach year of numlist 2002 2004 2006 {
		replace denom = denom + 1 if `var'`year'!=.
		replace num = num + `var'`year' if `var'`year'!=.
	}
	gen ave_`var' = num/denom
	drop num denom
}


gen chprepost_fill = (post_full - ave_totpc)/ave_sum_emp

xtile Q = chprepost_fill , nq(200)

gen chHH_trim = chprepost_fill if Q<196 & Q>5


keep sum_emp* matchID chprepost_fill chHH_trim

save "$data_output/workingHH_firm", replace

*}}}
