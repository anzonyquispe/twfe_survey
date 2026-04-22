quietly {
* Program Name : dropper.do

local pathpgs    "/rdcprojects/la00296/programs/"
local pathnaeyc  "/rdcprojects/la00296/data/outside/"
local pathcensus "/rdcprojects/la00296/data/csr/Juan/"
local allvars    "stgeo msa ein lfobase tax_xmpt non_pft revenue payroll payroll_q1 n_employ expense zip5 name1 name2 street plce st zip9 ctygeo pstreet pplce pst pzip type_o einssl name2a month_op n_estab"

*******************************************************************************
*
*	After trying several matching procedures
*       now drop centers with initial accreditation after 1998 &
*	centers with valid application date but no initial accreditation & 
* 	centers not accredited in any of the relevant years
*
*******************************************************************************


	noi di
	noi di in green "Dropping centers suspected of being new centers...."
	noi di
	use `pathnaeyc'naeyc_clean_orig.dta , clear
	sort naeyc_id
	merge naeyc_id using `pathnaeyc'naeyc_notmatched.dta

	tab _merge
	keep if _merge==3

	gen dropper=0
	
	* Mo's suggestion 1: To drop centers with initial accreditation after 1998 (only if applic date>1998)
	
	replace dropper=1 if applic_date!="" & e_applic_date>=mdy(01,01,1998) & e_init_accredit!=. & e_init_accredit >=mdy(01,01,1998) 
	
	* Mo's suggestion 2: To drop centers with no initial accreditation (only if applic date>1998)

	replace dropper=2 if applic_date!="" & e_applic_date>=mdy(01,01,1998) & e_init_accredit==.

	* Mo's suggestion 3: To drop centers with neither initial accreditation nor application dates

	replace dropper=3 if e_init_accredit==. & applic_date==""
	
	* Mo's suggestion 4: To drop centers without accreditation in 1987, 1992 & 1997

	gen A=1
	replace A=0 if dropper==0 & acc_status_1987_1d==0 & acc_status_1992_1d==0 & acc_status_1997_1d==0
	
	
	label define dropperlabel 0 "not dropped" 1 "init accred>1998 & applic >1998" 2 "no init accred & applic > 1998" 3 "no applic nor init accred dates"
	label values dropper dropperlabel
	label define Alabel 0 "Not accreditted in 1987, 1992 nor 1997" 1 "Accredited in at least one of these years"
	label values A Alabel
	
noi tab dropper
noi tab A if dropper==0
noi di
noi di "Centers not accreditted in 1987, 1992 nor 1997 are dropped, too"
noi di
	
	preserve
	keep if dropper==1|dropper==2|dropper==3|dropper==4|(dropper==4 & A==0)
	keep naeyc_id dropper
	sort naeyc_id
	global newdenom = $denom - _N
	saveold `pathnaeyc'dropper.dta, replace	
	restore
	
	keep if dropper==0 & A==1
	keep naeyc_id
	sort naeyc_id
	saveold `pathnaeyc'naeyc_notmatched.dta, replace
noi di
noi di "The new adjusted matching rate is " ($newdenom-_N)/$newdenom
noi di
noi di "A list of centers not matched yet was saved on naeyc_notmatched.dta"
noi di
noi di "A list of dropped centers  was saved on naeyc_dropped.dta"

	
}
