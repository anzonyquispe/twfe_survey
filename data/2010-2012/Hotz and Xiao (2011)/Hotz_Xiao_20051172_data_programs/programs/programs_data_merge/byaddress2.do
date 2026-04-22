quietly {
* Program Name : byaddress2.do

local pathpgs "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"

*******************************************************************************
*
*	Merge by 5-digit Zip Code and First X CHARACTERS of Address 2
*
*******************************************************************************


* Zip and Address2 matching loop
*******************************

forvalues j=$J/38 {
	local i=41-`j'+1
	noi di
	noi di in green "Performing Matching by Zip and first " `i' " characters of Bussiness Address 2...."
	noi di in green "Algorithm started at " c(current_time)
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	
	* Create POBOX flag to exclude centers with poboxes in address matching
	gen lowcaseadd2=lower(address2)
	split lowcaseadd2, gen(stub)
	gen add=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8
	
	gen trimadd=trim(add)
	
	*Takes care of P.O. BOX vs P O BOX vs R.D. BOX  vs R D BOX issues
	do `pathpgs'poboxer.do
	
	gen addressX5=substr(trimadd,1,5)
	gen pobox_flag=0
	replace pobox_flag=1 if addressX5=="pobox"|addressX5=="rdbox"
	drop stub* add trimadd lowcaseadd2 addressX5
	
	
	gen lowcaseadd2=lower(address2)
	split lowcaseadd2, gen(stub)
	gen add=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8
	gen trimadd=trim(add)
	replace trimadd=subinstr(trimadd,",","",.)
	replace trimadd=subinstr(trimadd,"'","",.)
	replace trimadd=subinstr(trimadd,";","",.)
	replace trimadd=subinstr(trimadd,":","",.)
	replace trimadd=subinstr(trimadd,".","",.)
	replace trimadd=subinstr(trimadd,"\","",.)
	replace trimadd=subinstr(trimadd,"/","",.)
	replace trimadd=subinstr(trimadd,"#","",.)
	replace trimadd=subinstr(trimadd,"-","",.)
	replace trimadd=subinstr(trimadd,"_","",.)
	replace trimadd=subinstr(trimadd,"%","",.)
	replace trimadd=subinstr(trimadd,"!","",.)
	replace trimadd=subinstr(trimadd,"$","",.)	
	replace trimadd=subinstr(trimadd,"*","",.)
	replace trimadd=subinstr(trimadd,"^","",.)
	replace trimadd=subinstr(trimadd,"(","",.)
	replace trimadd=subinstr(trimadd,")","",.)		
	
	*Takes care of P.O. BOX vs P O BOX vs R D BOX issues
	do `pathpgs'poboxer.do
	
	
	gen addressX`i'=substr(trimadd,1,`i')
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==3
	replace zip=9999999999999 if zip==.
	keep if pobox_flag==0
	sort zip addressX`i'
	keep zip addressX`i' naeyc_id
	saveold `pathnaeyc'naeyc_clean.dta, replace

	use `pathcensus'concat.dta , clear
	gen jnumber = _n
	sort stgeo msa ctygeo cfn year jnumber
	gen census_rec=_n
	rename zip5 zip
	destring zip, replace
	gen address2 = street
	gen lowcaseadd2=lower(address2)
	split lowcaseadd2, gen(stub)
	gen add=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8+stub8+stub9+stub10+stub11
	gen trimadd=trim(add)
	replace trimadd=subinstr(trimadd,",","",.)
	replace trimadd=subinstr(trimadd,"'","",.)
	replace trimadd=subinstr(trimadd,";","",.)
	replace trimadd=subinstr(trimadd,":","",.)
	replace trimadd=subinstr(trimadd,".","",.)
	replace trimadd=subinstr(trimadd,"\","",.)
	replace trimadd=subinstr(trimadd,"/","",.)
	replace trimadd=subinstr(trimadd,"#","",.)
	replace trimadd=subinstr(trimadd,"-","",.)
	replace trimadd=subinstr(trimadd,"_","",.)
	replace trimadd=subinstr(trimadd,"%","",.)
	replace trimadd=subinstr(trimadd,"!","",.)
	replace trimadd=subinstr(trimadd,"$","",.)	
	replace trimadd=subinstr(trimadd,"*","",.)
	replace trimadd=subinstr(trimadd,"^","",.)
	replace trimadd=subinstr(trimadd,"(","",.)
	replace trimadd=subinstr(trimadd,")","",.)	
	*Takes care of P.O. BOX vs P O BOX vs R D BOX issues
	do `pathpgs'poboxer.do
	
	
	gen addressX`i'=substr(trimadd,1,`i')
	keep addressX`i' year street cfn zip census_rec /* this is for fast testing only */
	sort zip addressX`i' year
	merge zip addressX`i' using `pathnaeyc'naeyc_clean.dta,  _merge(mergebyaddress2_`i')
	tab mergebyaddress2_`i'
	keep if mergebyaddress2_`i'==3
	keep census_rec naeyc_id
	saveold `pathcensus'mergebyaddress2_`i', replace
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
noi 	di in yellow "So far there are " $denom-_N " matched observations out of $denom"
noi 	di in yellow "Matching rate so far is: " ($denom-_N)/$denom
noi 	di in yellow "---------------------------------------------------------------"
noi 	di

	}
	
}
