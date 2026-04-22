
*****************************************************************
* This do-file develops a panel dataset to identify states that
* impose a gross receipts tax on businesses (based on Book of States)
*****************************************************************

** Minimum taxes and franchise taxes not based on gross receipts
** are excluded. Only states whose GRTs are included in the 
** Book of States notes are included.

* New Mexico, Delaware, Virginia, and Washington are reported to 
* have GRTs but are not included in the Book of States tables.

*****************************************************************
* 1. Use state-year variables to build panel
*****************************************************************

* Import tax rate and revenue data (1963-2012)
* Keep only state and year variables
use "$datapath/cit_rate_revenue.dta", clear
keep year st fips

*****************************************************************
* 2. Identify state-years where gross receipts are taxed
*****************************************************************

* Generate dummy variable to represent GRT indicator
* Default is 0, no gross receipt tax
gen grt=0
gen grt_rate=0

drop if year <1976

****************************
* Biennial changes until 2002
****************************

* No GRTs reported prior to 1982

* 1982: (reportedly enacted in 1980)
replace grt=1 if (st=="UT" & year>=1982) 
// for corporations not required to pay income or franchise taxes
replace grt_rate=0.06 if (st=="UT" & year>=1982) 
// graduates up to 6% on receipts in excess of $5 billion

* 1984:
replace grt_rate=0.01 if (st=="UT" & year>=1984)
// graduates up to 1% on receipts in excess of $1 billion

* No changes in 1986

* 1988:
replace grt=0 if (st=="UT" & year>=1988)
replace grt_rate=0 if (st=="UT" & year>=1988)

* No changes in 1990, 1992, 1994, 1996

* 1998:
replace grt=1 if (st=="HI" & year>=1998)
replace grt_rate=0.005 if (st=="HI" & year>=1998)
// Alternate tax of 0.5% of gross annual sales

* No changes in 2000

****************************
* Annual changes after 2002
****************************

* No changes in 2002, 2003

* Excluding NJ's GRT from 2004 onward ("AMA" based on gross receipts)
// In New Jersey, small businesses with annual entire net income under 
// $100,000 pay a tax rate of 7.5%; businesses with income under
// $50,000 pay 6.5%. The minimum Corporation Business Tax is based on
// New Jersey gross receipts. It ranges from $500 for a corporation with
// gross receipts less than $100,000, to $2,000 for a corporation with gross
// receipts of $1 million or more.

* 2005:
replace grt=1 if (st=="OH" & year>=2005)
// Appropriate rate is unclear: "A $50 to $1,000 minimum
// tax applies, depending on worldwide gross receipts."

* 2006: (Ohio)
replace grt_rate=0.0026 if (st=="OH" & year>=2006)
// The Commercial Activity Tax (CAT) equals $150 for gross receipts 
// between $150,000 and $1 million, plus 0.26% of gross receipts 
// over $1 million. The CAT applies to 23% of receipts through 
// March 31, and 40% for the remainder of the year. 

* 2007: (Ohio)
// The CAT applies to 40% of receipts through March 31, and 60%
// for the remainder of the year.

* 2008:
// Minimum tax of $175. Or, an annual Limited Liability Tax for all
// corporations with over $3 million in gross receipts.  The LLET is 
// the lesser of $0.095 per $100 of the Kentucky gross receipts; 
// or $0.75 per $100 of the Kentucky gross profits.

replace grt=1 if (st=="MI" & year>=2008)
replace grt_rate=0.008 if (st=="MI" & year>=2008)
// First $45,000 of tax base exempt. Plus, 0.8% of modified gross 
// receipts (receipts less purchases from other firms) on
// receipts of $350,000 or more.

* Ohio:
// The CAT applies to 60% of receipts through March 31, and 80%
// for the remainder of the year.

replace grt=1 if (st=="TX" & year>=2008)
replace grt_rate=0.01 if (st=="TX" & year>=2008)
// Texas imposes a Franchise Tax, known as the margin tax. It is imposed at
// 1.0% (0.5% for retail or wholesale entities) of gross revenues over $300,000,
// with a variable discount allowed for businesses with revenues between
// $300,000 to $900,000.

* 2009:
* Kentucky:
// Corporations must also pay the LLET, which is the lesser of 0.095% of 
// gross receipts or 0.75% of gross profits.  Tax phases in b/w $3M and $6M
// of gross receipts or profits -- minimum tax of $175.

* Ohio:
// CAT is phased in through 2010, while corporate income tax is phased out.
// B/W April 08 and March 09, the CAT rate is 0.208%.  Beginning April 09,
// the CAT rate is 0.26% (fully phased in). For tax year 2009, companies owe 
// 20% of corporate income tax liability -- beginning 2010, fully phased out.

* 2010:
* Kentucky LLET expires

* Oregon:
replace grt=1 if (st=="OR" & year>=2010)
replace grt_rate=0.0025 if (st=="OR" & year>=2010)
// Taxpayers with $100,000 or less in Oregon gross sales and no property
// in the state pay a tax equal to 0.25% of gross sales

* Connecticut:
// A 10% surcharge is imposed in tax years 2009, 2010, and 2011 for
// corporations with gross sales of $100 million or more who are not paying
// the minimum tax of $250.  The surcharge is based on business tax liability.

* Idaho:
// Idaho’s minimum tax on a corporation is $20. The $10 Permanent
// Building Fund Tax must be paid by each corporation in a unitary group
// filing a combined return. Taxpayers with gross sales in Idaho under
// $100,000, and with no property or payroll in Idaho, may elect to pay 1%
// on such sales (instead of the tax on net income).

* Montana:
// The minimum tax per corporation is $50; the $50 minimum applies
// to each corporation included on a combined tax return. Taxpayers with
// gross sales in Montana of $100,000 or less may pay an alternative tax of
// 0.5% on such sales, instead of the net income tax.

* 2011:
replace grt=0 if (st=="HI" & year>=2011)
replace grt_rate=0 if (st=="HI" & year>=2011)
// Hawaii taxes capital gains at 4%. Financial institutions pay a franchise
// tax of 7.92% of taxable income (in lieu of the corporate income
// tax and general excise taxes).

replace grt=0 if (st=="OR" & year>=2011)
replace grt_rate=0 if (st=="OR" & year>=2011)

// Oregon’s minimum tax for C corporations depends on the Oregon
// sales of the filing group. The minimum tax ranges from $150 for corporations
// with sales under $500,000, up to $100,000 for companies with sales
// of $100 million or above.

* 2012:
replace grt=0 if (st=="MI" & year>=2012)
replace grt_rate=0 if (st=="MI" & year>=2012)

*****************************************************************
* 3. Output final panel to Dropbox
*****************************************************************

save "$outpath/GRT.dta", replace
