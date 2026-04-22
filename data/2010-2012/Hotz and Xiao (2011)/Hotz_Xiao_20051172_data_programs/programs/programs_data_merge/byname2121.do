quietly {
* Program Name : byname2121.do

local pathpgs "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"


*******************************************************************************
*
*	Merge by 5-digit Zip Code and first X CHARACTERS of Name2121
*
*******************************************************************************

* Zip and Name2121 matching loop
********************************


forvalues j=$J/38 {
	local i=41-`j'+3
	noi di
	noi di in green "Performing Matching by Zip and first " `i' " characters of Bussiness Name 2121...."
	noi di in green "Algorithm started at " c(current_time)
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	
	*Takes care of "The" issue in center names
	do `pathpgs'the.do
	
	gen concaname=name2+name1			/* <==== Here is the difference  */
	gen lowcaseconcaname=lower(concaname)
	split lowcaseconcaname, gen(stub)
	gen name=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub9+stub10
	gen trimname=trim(name)
	replace trimname=subinstr(trimname,",","",.)
	replace trimname=subinstr(trimname,"'","",.)
	replace trimname=subinstr(trimname,";","",.)
	replace trimname=subinstr(trimname,":","",.)
	replace trimname=subinstr(trimname,".","",.)
	replace trimname=subinstr(trimname,"\","",.)
	replace trimname=subinstr(trimname,"/","",.)
	replace trimname=subinstr(trimname,"#","",.)
	replace trimname=subinstr(trimname,"-","",.)
	replace trimname=subinstr(trimname,"_","",.)
	gen nameX`i'=substr(trimname,1,`i')
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==3
	replace zip=9999999999999 if zip==.
	sort zip nameX`i'
	keep zip nameX`i' naeyc_id
	saveold `pathnaeyc'naeyc_clean.dta, replace

	use `pathcensus'concat.dta , clear
	gen jnumber = _n
	sort stgeo msa ctygeo cfn year jnumber
	gen census_rec=_n
	rename zip5 zip
	destring zip, replace
	
	*Takes care of "The" issue in center names
	do `pathpgs'the.do
	
	gen concaname=name2+name1
	gen lowcaseconcaname=lower(concaname)
	split lowcaseconcaname, gen(stub)
	gen name=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub8+stub9+stub10+stub11+stub12+stub13+stub14
	gen trimname=trim(name)
	replace trimname=subinstr(trimname,",","",.)
	replace trimname=subinstr(trimname,"'","",.)
	replace trimname=subinstr(trimname,";","",.)
	replace trimname=subinstr(trimname,":","",.)
	replace trimname=subinstr(trimname,".","",.)
	replace trimname=subinstr(trimname,"\","",.)
	replace trimname=subinstr(trimname,"/","",.)
	replace trimname=subinstr(trimname,"#","",.)
	replace trimname=subinstr(trimname,"-","",.)
	replace trimname=subinstr(trimname,"_","",.)	
	gen nameX`i'=substr(trimname,1,`i')
	keep nameX`i' year street cfn zip census_rec /* this is for fast testing only */
	sort zip nameX`i' year
	merge zip nameX`i' using `pathnaeyc'naeyc_clean.dta,  _merge(mergebyname`i')
	tab mergebyname`i'
	keep if mergebyname`i'==3
	keep census_rec naeyc_id
	saveold `pathcensus'mergebyname2121_`i', replace
	keep naeyc_id
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==2 /* leaves in naeyc_notmatched those obs not matchd yet */
	keep naeyc_id 
	sort naeyc_id 
	saveold `pathnaeyc'naeyc_notmatched.dta, replace
	noi di
	noi di in green " Done !"
	noi di in green "Algorithm finished at " c(current_time)
	noi di
	noi 	di
	noi 	di in yellow "--------------------------------------------------------------"
	noi 	di in yellow "So far there are " $denom-_N " matched observations out of $denom"
	noi 	di in yellow "Matching rate so far is: " ($denom-_N)/$denom
	noi 	di in yellow "--------------------------------------------------------------"
	noi 	di
	}
}
