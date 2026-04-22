 quietly {
* Program Name : byname43.do

local pathpgs "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"


*******************************************************************************
*
*	Merge by 5-digit Zip Code and first X CHARACTERS of Name1212
*
*******************************************************************************

* Zip and Name1212 matching loop
****************************


*forvalues j=$J/38 {
*	local i=41-`j'+3
	noi di
	noi di in green "Performing Matching by Zip and first 4 characters (1st word) and 3 characters (2nd word) of Bussiness Name 1212...."
	noi di in green "Algorithm started at " c(current_time)
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	
	*Takes care of "The" issue in center names
	do `pathpgs'the.do
	
	gen concaname=name1+name2
	gen lowcaseconcaname=lower(concaname)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,",","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"'","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,";","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,":","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,".","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"/","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"#","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"-","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"_","",.)
	split lowcaseconcaname, gen(stub)
	gen stub1_4=substr(stub1,1,4)
	gen stub2_3=substr(stub2,1,3)

	*gen name=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub9+stub10
	gen name = stub1_4+stub2_3
	gen name43=trim(name)
	

	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==3
	replace zip=9999999999999 if zip==.
	sort zip name43
	keep zip name43 naeyc_id
	saveold `pathnaeyc'naeyc_clean.dta, replace

	use `pathcensus'concat.dta , clear
	gen jnumber = _n
	sort stgeo msa ctygeo cfn year jnumber
	gen census_rec=_n
	rename zip5 zip
	destring zip, replace
	
	*Takes care of "The" issue in center names
	do `pathpgs'the.do
	
	gen concaname=name1+name2
	gen lowcaseconcaname=lower(concaname)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,",","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"'","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,";","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,":","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,".","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"/","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"#","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"-","",.)
	replace lowcaseconcaname=subinstr(lowcaseconcaname,"_","",.)
	split lowcaseconcaname, gen(stub)
	gen stub1_4=substr(stub1,1,4)
	gen stub2_3=substr(stub2,1,3)

	*gen name=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub8+stub9+stub10+stub11+stub12+stub13+stub14
	gen name= stub1_4+stub2_3
	gen name43=trim(name)

	keep name43 year street cfn zip census_rec /* this is for fast testing only */
	sort zip name43 year
	merge zip name43 using `pathnaeyc'naeyc_clean.dta,  _merge(mergebyname43)
	tab mergebyname43
	keep if mergebyname43==3
	keep census_rec naeyc_id
	saveold `pathcensus'mergebyname43, replace
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
*	}
}
