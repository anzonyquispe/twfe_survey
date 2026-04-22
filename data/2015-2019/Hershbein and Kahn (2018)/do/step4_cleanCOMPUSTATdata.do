
/*
/****************************************************************************
** 1. clean COMPUSTAT data						   							**
**	extracted from WRDS in August, 2017
****************************************************************************/
*{{{
import delim using "$raw_comp/COMPUSTAT_extract_8_2017.txt", clear
drop consol popsrc datafmt

sum
*dvintf rarely available so drop
drop dvintf

***year
gen year = floor(datadate/10000)
assert year>=1999 & year<=2017
drop if year==2015

**get down to 1 obs per firm, don't know why there are more, just average key vars
**a lot of times all 4 key variables are missing
drop if (ppent==. & ci==. & capx==. & dpc==.) | (ppent==0 & capx==0 & dpc==0)
duplicates tag gvkey datadate ppent ci capx dpc, gen(tag)
tab tag
assert tag==0
drop tag
duplicates drop gvkey datadate ppent ci capx dpc, force
duplicates tag gvkey fyear ppent ci capx dpc, gen(tag)
assert tag==0
drop tag

bysort gvkey fyear: gen counter = _n
assert counter==1
drop counter


drop datadate year indfmt

reshape wide curcd ci dvt ebit emp revt costat dvpsx_f mkvalt ppent capx dpc ib, i(gvkey) j(fyear)

	label var 	gvkey 	"unique Compustat ID"
	label var 	tic 	"company ticker symbol"	
	label var 	conm 	"company name"
	label var 	naics 	"6-digit NAICS"

foreach year of numlist 1999/2016 {
	label var 	curcd`year' 	"currency CAD=canadian, USD=american"
	label var 	ci`year' 	"comprehensive income -- total"
	label var 	dvt`year' 	"dividends - total"
	label var 	ebit`year' 	"earnings before interest and taxes"
	label var 	emp`year' 	"employees"
	label var 	revt`year'	 "Revenue"
	label var 	costat`year' 	"Company status, A=active, I-inactive"
	label var 	dvpsx_f`year' 	"dividends per share -- ex-date fiscal"
	label var 	mkvalt`year' 	"market value -- total fiscal"
	label var 	capx`year'	"capital expenditures"
	label var 	dpc`year'	"depreciation and amortization (cash flow)"
	label var	ib`year'	"income before extraordinary items (cash flow)"
	label var	ppent`year'	"propert, plant, and equipment -- total (net)"
}
save "$data_output/COMPUSTATvars8_17", replace
*}}}

/****************************************************************************
** Match COMPUSTAT names to firm names in BG				  **
**	1. clean COMPUSTAT names to match my BG cleaning (incorporated, etc.)
**	2. get BG data and keep valid firms for 2007-2010 change analysis
**		must have 5 ads in each of 2007 and 2010
**	3. get exact matches
**	4. use clean and match winpure algorithm on non-matched data w 95% match probability
**	5. use Deming match on the rest
****************************************************************************/
*{{{
**#1 clean COMPUSTAT names
*{{{
use "$data_output/COMPUSTATvars8_17", clear
keep conm gvkey
duplicates drop
gen employer = conm
***clean compustat names
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

gen emp_nospace = subinstr(employer," ","",.)
replace emp_nospace = lower(emp_nospace)

keep conm gvkey emp_nospace
bysort emp_nospace: gen counter = _N

list if counter==3, sep(0)
list if counter==2, sep(0)
**there are a bunch that get merged together that look like the same company
drop counter
bysort emp_nospace: gen counter = _n
reshape wide conm gvkey, i(emp_nospace) j(counter)

tempfile compnames
save `compnames', replace
*}}}


**#2 BG data, keep firms with at least 1 ad in each of 2007 and another year
*{{{
use "$data_output/BG_hasfirm_employer_msa_year", clear
assert emp_nospace!=""
assert emp_nospace!=" "
gen temp = (year==2007)
bysort emp_nospace: egen has07 = sum(temp) if year==2007
bysort emp_nospace: egen Nyears = nvals(year)
gen innit = (has07>0 & Nyears>=2)
display "share of weighted obs in change sample"
sum innit [aw=weight]
egen helper = nvals(emp_nospace)
display "number of unique employer names"
sum helper
drop helper
egen helper = nvals(emp_nospace) if innit==1
display "number of employers in 2007 and later year change sample"
sum helper

keep if innit==1
drop innit

***new weight in this sample
**the weight preserves the relative size of firm-occs within date
** and size of msa's across dates
drop weight
bysort year msa: egen tot_obs = sum(npostings)
gen rel_occsize = npostings/tot_obs
gen weight = lf2006*rel_occsize
drop rel_occsize tot_obs

tempfile chsample
save `chsample', replace
*}}}

**#3 get exact matches -- by removing spaces we get a few more matches
*{{{
use `chsample', clear
keep emp_nospace
duplicates drop

display "# employer matches with exact names (after cleaning)"
merge 1:1 emp_nospace using `compnames'
preserve
keep if _merge==3
***very few gvkey2's and one gvkey3 just keep the first
ren gvkey1 gvkey_exact
keep emp_nospace gvkey_exact
tempfile matches
save `matches', replace
*}}}

**#4 keep dataset of non-matches to use in clean and match algorithm
*{{{
restore, preserve
keep if _merge==1
keep emp_nospace
duplicates drop
export delim using "$data_output/BGnames_NM2_16_aug17", replace
restore, preserve
keep if _merge==2
keep gvkey* emp_nospace
duplicates drop
export delim using "$data_output/COMPnames_NM2_16_aug17", replace
***winpure match generates duplicate groups -- either matches across datasets or matches within dataset. keep matches across
import delim using "$data_output/matchesBG_2_16_aug17.txt", clear
ren v1 dupegroup
ren v2 employerBG
bysort dupegroup: gen counter = _n
reshape wide employerBG, i(dupegroup) j(counter)
tempfile NMBG
save `NMBG', replace
import delim using "$data_output/matchesCOMP_2_16_aug17.txt", clear
ren v1 dupegroup
ren v2 employerCOMP
sort dupegroup employerCOMP
by dupegroup: gen counter = _n
ren v3 gvkey
**almost no gvkey2 just drop
drop v* 
reshape wide employerCOMP gvkey, i(dupegroup) j(counter)
display "compustat companies merging with BG among non-exact matches"
merge 1:1 dupegroup using `NMBG'
assert _merge==3
***those with multiple matches are likely to be incorrect, look and clean here

**put match in subscript 1
sort dupegroup
list dupegroup employerCOMP1 employerCOMP2 employerCOMP3 employerBG1 employerBG2 if employerCOMP2!="", sep(0)
**none of these look like matches to me
drop if employerCOMP2!=""

**none of these with triple+ matches look like matches
list dupegroup employerCOMP1  employerBG1 employerBG2 employerBG3 if employerBG3!="", sep(0)
drop if employerBG3!=""

**there are a couple of correct matches here, but only in the 1 spot
list employerBG1 employerBG2 employerCOMP1 if employerBG2!="", sep(0)
replace employerBG2="" if dupegroup==67
replace employerBG2="" if dupegroup==1352
replace employerBG2="" if dupegroup==1449

local obs = _N
local newobs = `obs' + 1
set obs `newobs'
replace employerBG1 = "intercontinentalhotelgroup" in `newobs'
sum gvkey1 if employerCOMP1=="intercontinentalhotelsgrp"
replace gvkey1 = r(mean) in `newobs'
replace employerCOMP1 = "intercontinentalhotelsgrp" in `newobs'
replace employerBG2="" if dupegroup==1492

local obs = _N
local newobs = `obs' + 1
set obs `newobs'
replace employerBG1 = "petrostoppingcenters" in `newobs'
sum gvkey1 if employerCOMP1=="petrostoppingcenterslp"
replace gvkey1 = r(mean) in `newobs'
replace employerCOMP1 = "petrostoppingcenterslp" in `newobs'
replace employerBG2="" if dupegroup==2102

drop if employerBG2==""



***vast majority have only one gvkey so assign that for all, make long by BG name
keep gvkey1 employerBG1
ren gvkey1 gvkey_fuzzy
ren employerBG1 emp_nospace
drop if emp_nospace==""
tempfile fuzzy
save `fuzzy', replace

*}}}

**#5 get Deming matches
*{{{
use "$data_output/CS_BG_merge_final", clear
drop if CS_only==1 | BG_only==1
keep employer gvkey
***need to clean employer here too...woops
***clean compustat names
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
drop if employer ==""
drop if employer==" "

gen emp_nospace = subinstr(employer," ","",.)
replace emp_nospace = lower(emp_nospace)

keep emp_nospace gvkey 
duplicates drop
***only 1 employer has multiple gvkeys, just keep the first one
bysort emp_nospace: egen nkey = nvals(gvkey)
tab nkey
bysort emp_nospace: gen counter = _n
reshape wide gvkey, i(emp_nospace) j(counter)
ren gvkey1 gvkey_DD
keep emp_nospace gvkey_DD
duplicates drop
tempfile davidmerge
save `davidmerge', replace

use `chsample', clear
keep emp_nospace
duplicates drop
merge 1:1 emp_nospace using `matches'
assert _merge!=2
drop _merge
merge 1:1 emp_nospace using `fuzzy'
assert _merge!=2
drop _merge
merge 1:1 emp_nospace using `davidmerge'
**_merge==2 if in DD dataset and not the 2007-2010 firm obs dataset
drop if _merge==2
drop _merge

display "#employer matches with exact"
gen gvkey = gvkey_exact
sum gvkey
gen match_type = 1 if gvkey!=.
display "#employer matches with fuzzy match"
replace gvkey = gvkey_fuzzy if gvkey==.
sum gvkey
replace match_type = 2 if gvkey!=. & match_type==.
display "# employer matches with Deming"
replace gvkey = gvkey_DD if gvkey==.
sum gvkey
replace match_type = 3 if gvkey!=. & match_type==.

keep if gvkey!=.
keep emp_nospace gvkey match_type
duplicates drop
save "$data_output/BG_COMP_map_aug17", replace
*}}}

**#6 merge in my match and deming for residual matches
*{{{
use `chsample', clear
merge m:1 emp_nospace using "$data_output/BG_COMP_map_aug17"
assert _merge!=2
drop _merge

**keep only BG obs
assert npostings>0 & npostings!=.

***how many observations and firms match?
display "weighted obs not matching to compustat"
gen Mcomp = (gvkey==.)
tab Mcomp [aw=weight]

display "# firms total and matching"
egen Nfirms = nvals(emp_nospace)
sum Nfirms
egen Nfirms_comp = nvals(emp_nospace) if gvkey!=.
sum Nfirms_comp

keep if gvkey!=.

***bring in Compustat vars
merge m:1 gvkey using "$data_output/COMPUSTATvars8_17"
tab gvkey if _merge==1
**lots of firms in compustat that do not match to BG - _merge==2
**3 firms do not match to my new extract, _merge==1, not enough to care about
keep if _merge==3
drop _merge

***new weight in this sample
**the weight preserves the relative size of firm-occs within date
** and size of msa's across dates
drop weight
bysort year msa: egen tot_obs = sum(npostings)
gen rel_occsize = npostings/tot_obs
gen weight = lf2006*rel_occsize
drop rel_occsize tot_obs

tab match_type [aw=weight]

save "$data_output/data_inCOMP_employer_msa_year2", replace
*}}}

*}}}
*/
***make Compustat working data
*{{{
**restricted to Compustat firms that match BG
use "$data_output/BG_COMP_map_aug17", clear
assert gvkey!=.
assert emp_nospace!=""

***bring in Compustat vars
merge m:1 gvkey using "$data_output/COMPUSTATvars8_17"
tab gvkey if _merge==1
**lots of firms in compustat that do not match to BG - _merge==2
**3 firms do not match to my new extract, _merge==1, not enough to care about
keep if _merge==3
drop _merge

ren match_type COMPmatch_type
gen capital_change = ppent2010/ppent2006

gen num = 0
gen denom = 0
foreach year in 2010 2012 2014 {
	replace denom = denom + 1 if ppent`year'!=.
	replace num = num + ppent`year' if ppent`year'!=.
}
gen post_full = num/denom
drop num denom

foreach var in ppent {
	gen num = 0
	gen denom = 0
	foreach year of numlist 2002 2004 2006 {
		replace denom = denom + 1 if `var'`year'!=.
		replace num = num + `var'`year' if `var'`year'!=.
	}
	gen ave_`var' = num/denom
	drop num denom
}


gen comp_prepost_fill = post_full/ave_ppent

keep capital_change emp_nospace COMPmatch_type comp_prepost_fill

save "$data_output/workingCOMP_firm", replace

*}}}

