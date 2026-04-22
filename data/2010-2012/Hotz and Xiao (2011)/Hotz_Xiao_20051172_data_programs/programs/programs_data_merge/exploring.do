clear
set mem 50m
use "C:\Juan\Hotz\ChildCare\NAEYCdata\naeyc_clean.dta", clear

foreach var of varlist  naeyc_id- dup_zip {
rename  `var' Y`var'
			}



drop if cntry !="" 					/*drop all non-US records*/
gen name= Yname1 + " " +Yname2 				/*concatenates name1 and name2 */
sort address2
gen id_address2=_n if  Yaddress2!=""
list  id_address2 Yaddress2  Yaddress1 if  Yaddress2 !=""
						/*Make necessary changes so "address1" is the street address as sometimes address2 contains the street address*/


gen weird=0

gen e_application=date(applic_date, "mdy")
gen application_year=year(e_application)
tab application_year
replace weird=1 if (application_year>2003 |  application_year<1985) & application_year !=.

gen e_initaccredit=date(init_accredit, "mdy")
gen init_accredit_year=year(e_initaccredit)
tab init_accredit_year
replace weird=1 if (init_accredit_year>2003 |  init_accredit_year<1985) & init_accredit_year !=.

 drop if weird==1

*list aux applicationdate applicationYear if  (applicationYear>2003 |  applicationYear<1986) & applicationYear!=.
*list aux applicationdate applicationYear if  (applicationYear>2003 |  applicationYear<1985) & applicationYear!=.
*list aux  applicationdate  applicationYear  initlaccreddate validuntildate extenduntildate programclosedate annualreptrecvd accreditationstatus

gen   lowercasename= lower(name)
split  lowercasename, gen(stub)
gen   lowercasenamenoblanks= stub1+ stub2+ stub3 +stub4 +stub5 +stub6 +stub7 +stub8 +stub9 +stub10+ stub11
drop stub*
gen 

*gen ratio=  ofchildren/ofstaff
*su ratio, detail
*hist ratio if ratio <50
