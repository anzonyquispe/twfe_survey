*****************************************************************
* This do-file develops a panel dataset to identify rules re:
* deductibility of state corporate taxes from federal taxes
*****************************************************************

*****************************************************************
* 1. Use state-year variables to build panel
*****************************************************************

* Import tax rate and revenue data (1963-2012)
* Keep only state and year variables
use "$datapath/cit_rate_revenue.dta", clear
keep year st fips

*****************************************************************
* 2. Identify state-years where deductibility is permitted
*****************************************************************

* Generate dummy variable to represent deductibility
* Default is 0, not permitted
gen deduct=0

drop if year <1976

****************************
* Biennial changes until 2002
****************************

* 1976:
replace deduct=1 if st=="AL"
replace deduct=1 if st=="AZ"
replace deduct=1 if st=="LA"
replace deduct=1 if st=="MO"
replace deduct=1 if st=="ND"
replace deduct=1 if st=="SD"
replace deduct=1 if st=="UT"

// "Limited to 10 percent of net income"
replace deduct=1 if st=="WI" 

// "50 percent of federal income tax deductible"
replace deduct=0.5 if st=="IA"

* 1978:
replace deduct=0 if (st=="UT" & year>=1978)
replace deduct=0 if (st=="WI" & year>=1978)

* No changes in 1980, 1982, 1984, 1986, 1988

* 1990:
replace deduct=0 if (st=="SD" & year>=1990)

* 1992:
replace deduct=0 if (st=="AZ" & year>=1992)

* 1994:
replace deduct=0.5 if (st=="MO" & year>=1994)

* No changes in 1996, 1998, 2000

****************************
* Annual changes after 2002
****************************

* No changes between 2002-08

** 2009 excludes federal deductibility for North Dakota, possibly an error of omission.

* No changes between 2010-12

*****************************************************************
* 3. Output final panel to Dropbox
*****************************************************************

save "$outpath/deductibility.dta", replace
