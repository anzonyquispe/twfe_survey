quietly {
* Program Name : by9digitzip.do

local pathpgs    "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars    "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"

*******************************************************************************
*
*	Merge by 9-digit Zip Code 
*
*******************************************************************************


	noi di
	noi di in green "Performing Matching by 9 digit Zip Code...."
	noi di in green "Algorithm started at " c(current_time)
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==3
	keep if zip9_flag==1
	keep zip9 naeyc_id
	sort zip9
	saveold `pathnaeyc'naeyc_clean.dta, replace

	use `pathcensus'concat.dta , clear
	gen jnumber = _n
	sort stgeo msa ctygeo cfn year jnumber
	gen census_rec=_n
*sort census_rec
*merge census_rec using `pathcensus'census_notmatched.dta
*tab _merge
*keep if _merge==3	

	rename zip9 strzip9
	destring strzip9, gen (zip9)

	keep zip9 census_rec year
	sort zip9 year
	merge zip9 using `pathnaeyc'naeyc_clean.dta,  _merge(mergebyzip9)
	tab mergebyzip9
	keep if mergebyzip9==3
	keep census_rec naeyc_id
	
	* Outputs the contribution of this matching procedure
	saveold `pathcensus'mergebyzip9, replace
	
	* Updates NAEYC not matched list
	keep naeyc_id
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==2 /* leaves in naeyc_notmatched those obs not matchd yet */
	keep naeyc_id 
	sort naeyc_id 
	saveold `pathnaeyc'naeyc_notmatched.dta, replace
	
* Updates Census not matched list
*use `pathcensus'mergebyzip9, replace
*keep census_rec
*sort census_rec
*merge census_rec using `pathcensus'census_notmatched.dta
*tab _merge
*keep if _merge==2 /* leaves in census_notmatched those obs not matchd yet */
*keep census_rec 
*sort census_rec 
*saveold `pathcensus'census_notmatched.dta, replace	
	
noi 	di 
noi 	di in green " Done !"
noi 	di in green "Algorithm finished at " c(current_time)
noi 	di
noi 	di in yellow "---------------------------------------------------------------"
noi 	di in yellow "So far there are " $denom-_N " matched observations out of $denom"
noi 	di in yellow "Matching rate so far is: " ($denom-_N)/$denom
noi 	di in yellow "---------------------------------------------------------------"
noi 	di


	
}
