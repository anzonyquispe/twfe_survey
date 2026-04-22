quietly {
* Program Name : bystateandname2112.do

local pathpgs "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"

*******************************************************************************
*
*	Merge by STATE and First X CHARACTERS of Bussiness Name 2112
*
*******************************************************************************


* STATE and Business name 2112 matching loop
*********************************************

*local i=1
forvalues j=$J/38 {
	local i=41-`j'
	noi di
	noi di in green "Performing Matching by STATE and first " `i' " characters of Bussiness Name 2112...."
	noi di in green "Algorithm started at " c(current_time)
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	gen concaname=name2+name1
	gen lowcaseconcaname=lower(concaname)
	split lowcaseconcaname, gen(stub)
	gen name=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub9+stub10
	gen trimname=trim(name)
	gen nameX`i'=substr(trimname,1,`i')
	
	do `pathpgs'numstate.do
		
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==3
	replace zip=9999999999999 if zip==.
	sort numstate nameX`i'
	keep  if zip==9999999999999			/* because state + name matching is only for those that do not have zip*/
	keep numstate nameX`i' naeyc_id
	saveold `pathnaeyc'naeyc_clean.dta, replace


	use `pathcensus'concat.dta , clear
	sort stgeo msa ctygeo cfn year
	gen census_rec=_n
	rename zip5 zip
	destring zip, replace
	gen concaname=name1+name2
	gen lowcaseconcaname=lower(concaname)
	split lowcaseconcaname, gen(stub)
	gen name=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub8+stub9+stub10+stub11+stub12+stub13+stub14
	gen trimname=trim(name)
	gen nameX`i'=substr(trimname,1,`i')

	gen numstate=real(stgeo)

	keep nameX`i' year street cfn numstate zip census_rec /* this is for fast testing only */
	sort numstate nameX`i' year
	merge numstate nameX`i' using `pathnaeyc'naeyc_clean.dta,  _merge(mergebynameandstate`i')
	tab mergebynameandstate`i'
	keep if mergebynameandstate`i'==3
	keep census_rec naeyc_id
	saveold `pathcensus'mergebyname2112andstate_`i', replace
	keep naeyc_id
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==2 /* leaves in naeyc_notmatched those obs not matchd yet */
	keep naeyc_id 
	sort naeyc_id 
	saveold `pathnaeyc'naeyc_notmatched.dta, replace
noi 	di 
noi 	di in green " Done !"
noi 	di in green "Algorithm finished at " c(current_time)
noi 	di
noi 	di in yellow "---------------------------------------------------------------"
noi 	di in yellow "So far there are " 30280-_N " matched observations out of 30280"
noi 	di in yellow "Matching rate so far is: " (30280-_N)/30280
noi 	di in yellow "---------------------------------------------------------------"
noi 	di
	}

}
