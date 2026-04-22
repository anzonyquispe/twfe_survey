quietly {
* Program Name : bypobox1.do

local pathpgs    "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars    "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"

*******************************************************************************
*
*	Merge by 5-digit Zip Code and Exact P.O. BOX number (based on Address1)
*
*******************************************************************************


	noi di
	noi di in green "Performing Matching by Zip and exact P.O.Box 1 number  ...."
	noi di in green "Algorithm started at " c(current_time)
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	gen lowcaseadd1=lower(address1)
	split lowcaseadd1, gen(stub)
	gen add=stub1+stub2+stub3+stub4+stub5+stub6+stub7+stub8
	
	gen trimadd=trim(add)
	
	*Takes care of P.O. BOX vs P O BOX vs R.D. BOX  vs R D BOX issues
	do `pathpgs'poboxer.do
	
	gen addressX5=substr(trimadd,1,5)
	gen pobox_flag=0
	replace pobox_flag=1 if addressX5=="pobox"|addressX5=="rdbox"
	drop stub* add trimadd
	replace lowcaseadd1=subinstr(lowcaseadd1,"p.o. box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p.o.box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p o box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p. o. box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"po box ","pobox ",1)
	split lowcaseadd1, gen(stub) 
	gen pobox=stub1+stub2
	replace pobox=subinstr(pobox,",","",.)
	replace pobox=subinstr(pobox,"'","",.)
	replace pobox=subinstr(pobox,";","",.)
	replace pobox=subinstr(pobox,":","",.)
	replace pobox=subinstr(pobox,".","",.)
	replace pobox=subinstr(pobox,"\","",.)
	replace pobox=subinstr(pobox,"/","",.)
	replace pobox=subinstr(pobox,"#","",.)
	replace pobox=subinstr(pobox,"-","",.)
	replace pobox=subinstr(pobox,"_","",.)
	replace pobox=subinstr(pobox,"%","",.)
	replace pobox=subinstr(pobox,"!","",.)
	replace pobox=subinstr(pobox,"$","",.)	
	replace pobox=subinstr(pobox,"*","",.)
	replace pobox=subinstr(pobox,"^","",.)
	replace pobox=subinstr(pobox,"(","",.)
	replace pobox=subinstr(pobox,")","",.)	
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==3
	replace zip=9999999999999 if zip==.
	keep if pobox_flag==1
	sort zip pobox
	keep zip pobox naeyc_id
	saveold `pathnaeyc'naeyc_clean.dta, replace

	use `pathcensus'concat.dta , clear
	gen jnumber = _n
	sort stgeo msa ctygeo cfn year jnumber
	gen census_rec=_n
*	sort census_rec
*	merge census_rec using `pathcensus'census_notmatched.dta
*	tab _merge
*	keep if _merge==3
	
	
	
	rename zip5 zip
	destring zip, replace
	gen address1 = street
	gen lowcaseadd1=lower(address1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p.o. box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p.o.box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p o box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"p. o. box ","pobox ",1)
	replace lowcaseadd1=subinstr(lowcaseadd1,"po box ","pobox ",1)
	split lowcaseadd1, gen(stub) 
	gen pobox=stub1+stub2
	replace pobox=subinstr(pobox,",","",.)
	replace pobox=subinstr(pobox,"'","",.)
	replace pobox=subinstr(pobox,";","",.)
	replace pobox=subinstr(pobox,":","",.)
	replace pobox=subinstr(pobox,".","",.)
	replace pobox=subinstr(pobox,"\","",.)
	replace pobox=subinstr(pobox,"/","",.)
	replace pobox=subinstr(pobox,"#","",.)
	replace pobox=subinstr(pobox,"-","",.)
	replace pobox=subinstr(pobox,"_","",.)
	replace pobox=subinstr(pobox,"%","",.)
	replace pobox=subinstr(pobox,"!","",.)
	replace pobox=subinstr(pobox,"$","",.)	
	replace pobox=subinstr(pobox,"*","",.)
	replace pobox=subinstr(pobox,"^","",.)
	replace pobox=subinstr(pobox,"(","",.)
	replace pobox=subinstr(pobox,")","",.)	
	keep pobox year street cfn zip census_rec /* this is for fast testing only */
	sort zip pobox year
	merge zip pobox using `pathnaeyc'naeyc_clean.dta,  _merge(mergebypobox1)
	tab mergebypobox1
	keep if mergebypobox1==3
	keep census_rec naeyc_id
	saveold `pathcensus'mergebypobox1, replace
	keep naeyc_id
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta
	tab _merge
	keep if _merge==2 /* leaves in naeyc_notmatched those obs not matchd yet */
	keep naeyc_id 
	sort naeyc_id 
	saveold `pathnaeyc'naeyc_notmatched.dta, replace
	
	* Updates Census not matched list
*	use `pathcensus'mergebypobox1, replace
*	keep census_rec
*	sort census_rec
*	merge census_rec using `pathcensus'census_notmatched.dta
*	tab _merge
*	keep if _merge==2 /* leaves in census_notmatched those obs not matchd yet */
*	keep census_rec 
*	sort census_rec 
*	saveold `pathcensus'census_notmatched.dta, replace	
	
	
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
